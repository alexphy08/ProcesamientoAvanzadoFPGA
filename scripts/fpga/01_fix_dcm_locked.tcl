# 01_fix_dcm_locked.tcl
# Desconecta rst_ps7_0_100M/dcm_locked de la red de reloj FCLK_CLK0 en el
# block design "hardware" del proyecto lab_fsm, regenera el bitstream y
# exporta el XSA (con .bit) junto a lab_fsm.xpr.
#
# Uso (desde la raiz del repo, en la terminal de Vivado 2024.2):
#   vivado -mode batch -source scripts/fpga/01_fix_dcm_locked.tcl -log scripts/fpga/fix.log -nojournal
#
# No usa rutas absolutas: todo se calcula desde la ubicacion de este script.
# Es idempotente: si dcm_locked ya esta desconectado, no lo toca.

# ---------------------------------------------------------------
# a) Rutas relativas al repo
# ---------------------------------------------------------------
set script_dir [file normalize [file dirname [info script]]]
set repo_root  [file normalize [file join $script_dir .. ..]]
set xpr_file   [file join $repo_root lab_fsm lab_fsm.xpr]
set xsa_file   [file join $repo_root lab_fsm hardware_wrapper.xsa]

set clk_net_name   /processing_system7_0_FCLK_CLK0
set dcm_pin_name   rst_ps7_0_100M/dcm_locked

proc fallar {msg} {
    puts "ERROR: $msg"
    error $msg
}

if {![file exists $xpr_file]} {
    fallar "no se encuentra el proyecto: $xpr_file"
}
puts "Repo:     $repo_root"
puts "Proyecto: $xpr_file"

# ---------------------------------------------------------------
# b) Abrir proyecto y block design
# ---------------------------------------------------------------
open_project $xpr_file
set bd_file [get_files -quiet hardware.bd]
if {$bd_file eq ""} {
    fallar "el proyecto no contiene hardware.bd"
}
open_bd_design $bd_file

# ---------------------------------------------------------------
# c) Desconectar dcm_locked solo si sigue en la red de reloj
# ---------------------------------------------------------------
set dcm_pin [get_bd_pins -quiet $dcm_pin_name]
if {$dcm_pin eq ""} {
    fallar "no existe el pin $dcm_pin_name en el block design"
}

set dcm_desconectado "no"
set dcm_net [get_bd_nets -quiet -of_objects $dcm_pin]
if {$dcm_net eq ""} {
    puts "dcm_locked ya estaba desconectado: no se cambia nada."
    set dcm_desconectado "si (ya lo estaba)"
} elseif {[string trimleft [get_property NAME $dcm_net] /] eq [string trimleft $clk_net_name /]} {
    puts "dcm_locked esta conectado a $clk_net_name: desconectando..."
    disconnect_bd_net $clk_net_name $dcm_pin
    if {[get_bd_nets -quiet -of_objects $dcm_pin] ne ""} {
        fallar "dcm_locked sigue conectado tras disconnect_bd_net"
    }
    set dcm_desconectado "si"
} else {
    # Conectado a otra red (p. ej. un locked real de un clocking wizard): se respeta.
    puts "AVISO: dcm_locked esta conectado a [get_property NAME $dcm_net], no al reloj. No se toca."
    set dcm_desconectado "no (conectado a [get_property NAME $dcm_net])"
}

# ---------------------------------------------------------------
# d) Validar y guardar
# ---------------------------------------------------------------
if {[catch {validate_bd_design} err]} {
    fallar "validate_bd_design fallo. Revisa los mensaje(s) de arriba.\n$err"
}
save_bd_design
puts "Validacion del block design OK."

# ---------------------------------------------------------------
# e) Sintesis, implementacion y bitstream
# ---------------------------------------------------------------
generate_target all $bd_file
reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

set impl_run [get_runs impl_1]
set progress [get_property PROGRESS $impl_run]
set status   [get_property STATUS $impl_run]
puts "impl_1: PROGRESS=$progress STATUS=$status"
if {$progress ne "100%" || ![string match "*write_bitstream Complete*" $status]} {
    fallar "impl_1 no termino bien (STATUS=$status). Revisa lab_fsm/lab_fsm.runs/impl_1/runme.log"
}

set impl_dir [get_property DIRECTORY $impl_run]
set bit_files [glob -nocomplain -directory $impl_dir *.bit]
if {[llength $bit_files] == 0} {
    fallar "no se genero ningun .bit en $impl_dir"
}
set bit_file [lindex $bit_files 0]
puts "Bitstream: $bit_file"

set wns [get_property STATS.WNS $impl_run]
if {$wns ne "" && $wns < 0} {
    puts "AVISO: WNS negativo ($wns ns): el diseno no cumple timing."
}

# ---------------------------------------------------------------
# f) Exportar XSA con bitstream junto a lab_fsm.xpr
# ---------------------------------------------------------------
write_hw_platform -fixed -include_bit -force -file $xsa_file
if {![file exists $xsa_file]} {
    fallar "no se genero el XSA: $xsa_file"
}

# ---------------------------------------------------------------
# g) Resumen
# ---------------------------------------------------------------
puts ""
puts "================ RESUMEN ================"
puts "dcm_locked desconectado: $dcm_desconectado"
puts "validacion OK"
puts "WNS: $wns ns"
puts "Bitstream: $bit_file"
puts "XSA: $xsa_file"
puts "========================================="

close_project
