# fix_clocks_resets.tcl
# Repara las redes de reloj, reset, interfaces AXI y direcciones del block design
# "hardware" cuando el preset de la PYNQ-Z1 las ha desconectado (error BD 41-758).
#
# Uso (consola Tcl de Vivado, con el proyecto abierto):
#   cd <ruta_del_repo>
#   source scripts/fix_clocks_resets.tcl
#
# Es idempotente: solo conecta lo que esta libre y avisa de lo demas.

# ---------------------------------------------------------------
# a) Abrir el block design si no esta abierto
# ---------------------------------------------------------------
if {[catch {current_bd_design}]} {
    open_bd_design [get_files hardware.bd]
}
set ps [get_bd_cells processing_system7_0]

# ---------------------------------------------------------------
# b) Reactivar solo lo necesario en el PS (conserva el resto del preset)
# ---------------------------------------------------------------
set_property -dict [list \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
    CONFIG.PCW_USE_S_AXI_GP0 {1} \
    CONFIG.PCW_EN_CLK0_PORT {1} \
    CONFIG.PCW_EN_RST0_PORT {1} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100}] $ps

# ---------------------------------------------------------------
# c) Conecta src_pin a cada pin de dst_list solo si el destino no tiene red
# ---------------------------------------------------------------
proc connect_if_free {src_pin dst_list} {
    set src [get_bd_pins -quiet $src_pin]
    if {$src eq ""} {
        puts "AVISO: no existe el pin origen $src_pin"
        return
    }
    foreach dst_name $dst_list {
        set dst [get_bd_pins -quiet $dst_name]
        if {$dst eq ""} {
            puts "AVISO: el pin $dst_name no existe"
            continue
        }
        set dst_net [get_bd_nets -quiet -of_objects $dst]
        if {$dst_net eq ""} {
            connect_bd_net $src $dst
            puts "OK: $src_pin -> $dst_name"
        } elseif {$dst_net eq [get_bd_nets -quiet -of_objects $src]} {
            puts "Ya conectado a $src_pin: $dst_name"
        } else {
            puts "AVISO: $dst_name ya esta conectado a otra red ($dst_net); no se toca"
        }
    }
}

# ---------------------------------------------------------------
# d) Relojes -> FCLK_CLK0
# ---------------------------------------------------------------
connect_if_free processing_system7_0/FCLK_CLK0 {
    processing_system7_0/M_AXI_GP0_ACLK
    processing_system7_0/S_AXI_GP0_ACLK
    axi_dma_0/s_axi_lite_aclk
    axi_dma_0/m_axi_mm2s_aclk
    axi_dma_1/s_axi_lite_aclk
    axi_dma_1/m_axi_s2mm_aclk
    fifo_generator_0/s_aclk
    fifo_generator_1/s_aclk
    axis_broadcaster_0/aclk
    axi_interconnect_0/ACLK
    axi_interconnect_0/S00_ACLK
    axi_interconnect_0/S01_ACLK
    axi_interconnect_0/M00_ACLK
    axi_interconnect_1/ACLK
    axi_interconnect_1/S00_ACLK
    axi_interconnect_1/M00_ACLK
    axi_interconnect_1/M01_ACLK
    axi_interconnect_1/M02_ACLK
    proc_sys_reset_0/slowest_sync_clk
    RegisterControl_leds_0/s00_axi_aclk
    stream_transform_0/aclk
    tick_generator_0/clk
    fsm_controller_0/clk
}

# ---------------------------------------------------------------
# e) Resets -> FCLK_RESET0_N
# ---------------------------------------------------------------
connect_if_free processing_system7_0/FCLK_RESET0_N {
    RegisterControl_leds_0/s00_axi_aresetn
    axi_dma_0/axi_resetn
    axi_dma_1/axi_resetn
    axi_interconnect_0/ARESETN
    axi_interconnect_0/S00_ARESETN
    axi_interconnect_0/S01_ARESETN
    axi_interconnect_0/M00_ARESETN
    axi_interconnect_1/ARESETN
    axi_interconnect_1/S00_ARESETN
    axi_interconnect_1/M00_ARESETN
    axi_interconnect_1/M01_ARESETN
    axi_interconnect_1/M02_ARESETN
    axis_broadcaster_0/aresetn
    fifo_generator_0/s_aresetn
    fifo_generator_1/s_aresetn
    proc_sys_reset_0/ext_reset_in
    proc_sys_reset_0/aux_reset_in
    stream_transform_0/aresetn
    tick_generator_0/rst
}

# proc_sys_reset_0/peripheral_aresetn debe alimentar a fsm_controller_0/rst
connect_if_free proc_sys_reset_0/peripheral_aresetn {fsm_controller_0/rst}

# ---------------------------------------------------------------
# f) Interfaces AXI del PS
# ---------------------------------------------------------------
if {[get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins processing_system7_0/M_AXI_GP0]] eq ""} {
    connect_bd_intf_net [get_bd_intf_pins processing_system7_0/M_AXI_GP0] \
        [get_bd_intf_pins axi_interconnect_1/S00_AXI]
    puts "OK: M_AXI_GP0 -> axi_interconnect_1/S00_AXI"
}
if {[get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins processing_system7_0/S_AXI_GP0]] eq ""} {
    connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M00_AXI] \
        [get_bd_intf_pins processing_system7_0/S_AXI_GP0]
    puts "OK: axi_interconnect_0/M00_AXI -> S_AXI_GP0"
}

# ---------------------------------------------------------------
# g) Mapa de direcciones
# ---------------------------------------------------------------
assign_bd_address

# Fija offset y rango 64K de un segmento del espacio Data del PS buscado por nombre
proc set_ps_seg {pattern offset} {
    set found 0
    set space [get_bd_addr_spaces processing_system7_0/Data]
    foreach seg [get_bd_addr_segs -quiet -of_objects $space] {
        if {[string match $pattern [get_property NAME $seg]]} {
            set_property offset $offset $seg
            set_property range 64K $seg
            puts "OK: [get_property NAME $seg] -> $offset (64K)"
            set found 1
        }
    }
    if {!$found} {
        puts "AVISO: no se encontro segmento que coincida con $pattern"
    }
}
set_ps_seg *axi_dma_0*            0x40400000
set_ps_seg *axi_dma_1*            0x40410000
set_ps_seg *RegisterControl_leds* 0x43C00000

# Los DMA deben ver la DDR por S_AXI_GP0 (segmento GP0_DDR_LOWOCM)
foreach dma {axi_dma_0 axi_dma_1} {
    set ok 0
    foreach seg [get_bd_addr_segs -quiet -of_objects [get_bd_addr_spaces -quiet $dma/Data*]] {
        if {[string match *GP0_DDR_LOWOCM* [get_property NAME $seg]]} { set ok 1 }
    }
    if {$ok} {
        puts "OK: $dma accede a la DDR (GP0_DDR_LOWOCM)"
    } else {
        puts "AVISO: $dma no tiene segmento GP0_DDR_LOWOCM; revisa el Address Editor"
    }
}

# ---------------------------------------------------------------
# h) Verificacion
# ---------------------------------------------------------------
puts "=== Pines de reloj/reset sin red ==="
set sin_red 0
foreach tipo {clk rst} {
    foreach pin [get_bd_pins -quiet -hierarchical -filter "TYPE==$tipo"] {
        if {[get_bd_nets -quiet -of_objects $pin] eq ""} {
            puts "SIN RED ($tipo): $pin"
            incr sin_red
        }
    }
}
puts "Total sin red: $sin_red"

puts "=== Configuracion del PS ==="
foreach p {PCW_UART0_PERIPHERAL_ENABLE PCW_SD0_PERIPHERAL_ENABLE
           PCW_CRYSTAL_PERIPHERAL_FREQMHZ PCW_UIPARAM_DDR_PARTNO
           PCW_FPGA0_PERIPHERAL_FREQMHZ} {
    puts "$p = [get_property CONFIG.$p $ps]"
}
puts "(PCW_CRYSTAL_PERIPHERAL_FREQMHZ debe ser 50)"

validate_bd_design
save_bd_design
