# Reparar el block design en Vivado (PYNQ-Z1)

Guía paso a paso para reconectar relojes y resets cuando el preset de la placa
dejó el diseño roto (error `BD 41-758`, pines de reloj sin conectar a `FCLK_CLK0`).

## Antes de empezar

- Vivado debe tener instalados los **board files de Digilent** (PYNQ-Z1).
- El repositorio y el proyecto deben estar en una **ruta sin espacios** (por ejemplo
  `C:\fpga\ProcesamientoAvanzadoFPGA`). Vivado falla con rutas con espacios.

## Pasos

1. **Abrir el proyecto** `lab_fsm.xpr` en Vivado (desde la ruta sin espacios).
2. En la **Tcl Console** (parte inferior de Vivado) escribe, cambiando la ruta por la tuya:
   ```tcl
   cd C:/fpga/ProcesamientoAvanzadoFPGA
   source scripts/fix_clocks_resets.tcl
   ```
   Usa `/` en las rutas, no `\`.
3. **Revisar la salida.** Debe terminar con `Total sin red: 0`. Si lista líneas
   `SIN RED (clk)` o `SIN RED (rst)`, hay pines sin conectar: conéctalos a mano en el
   diagrama o avisa al docente. Las líneas `AVISO` indican pines que no existen o que ya
   estaban conectados a otra red (el script no los toca). Comprueba también que
   `PCW_CRYSTAL_PERIPHERAL_FREQMHZ` valga 50.
4. **Refrescar `stream_transform_0`**: clic derecho sobre el bloque > *Refresh Module*
   (necesario porque cambió el VHDL).
5. **Actualizar IPs**: menú *Reports > Report IP Status*, selecciona
   `RegisterControl_leds` y pulsa *Upgrade Selected*.
6. **Generate Output Products**: en *Sources*, clic derecho sobre `hardware.bd` >
   *Generate Output Products*.
7. **Create HDL Wrapper**: clic derecho sobre `hardware.bd` > *Create HDL Wrapper* >
   *Let Vivado manage wrapper and auto-update*.
8. **Generate Bitstream** (panel *Flow Navigator* a la izquierda). Espera a que termine.
9. **Exportar hardware**: *File > Export > Export Hardware*, marca
   **Include bitstream** y guarda el `.xsa`.
10. **Commit**: haz commit de `hardware.bd` y del `.xsa` en git.

## Si vuelves a aplicar el preset

`scripts/fix_ps_preset.tcl` ya llama al final a `fix_clocks_resets.tcl`, porque el preset
reconfigura el PS y borra las redes de `FCLK_CLK0` y `FCLK_RESET0_N`. No hace falta
ejecutar ambos por separado.
