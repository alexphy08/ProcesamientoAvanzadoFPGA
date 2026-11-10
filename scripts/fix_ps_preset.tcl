# fix_ps_preset.tcl
# Ejecutar en la consola Tcl de Vivado con el proyecto abierto:
#   source scripts/fix_ps_preset.tcl
#
# REQUISITO: tener instalados los board files de Digilent (PYNQ-Z1);
# de lo contrario el board_part y el preset del PS no se encontrarán.

# Asigna la placa PYNQ-Z1 al proyecto actual
set_property board_part www.digilentinc.com:pynq-z1:part0:1.0 [current_project]

# Abre el block design
open_bd_design [get_files hardware.bd]

# Aplica el preset de la placa al Zynq PS y exporta FIXED_IO y DDR
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
  -config {make_external "FIXED_IO, DDR" apply_board_preset "1"} [get_bd_cells processing_system7_0]

# Habilita M_AXI_GP0 y S_AXI_GP0 y fija FCLK_CLK0 a 100 MHz
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1} CONFIG.PCW_USE_S_AXI_GP0 {1} \
  CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100}] [get_bd_cells processing_system7_0]

# El preset reconfigura el PS y borra las redes de FCLK_CLK0 y FCLK_RESET0_N
# (error BD 41-758). Se reconectan relojes, resets, interfaces y direcciones;
# ese script ya valida y guarda el diseño.
source [file join [file dirname [info script]] fix_clocks_resets.tcl]
