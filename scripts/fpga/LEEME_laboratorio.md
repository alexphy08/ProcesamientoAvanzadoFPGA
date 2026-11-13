# Guía para el laboratorio: arreglar `dcm_locked` y crear la app con DMA

Esta guía es para el PC del laboratorio, que tiene Vivado y Vitis 2024.2.
Hay que seguir los pasos en orden. Si un script falla, usa el **Plan B** (sección 5).

## Qué problema arregla

En el block design `hardware` del proyecto `lab_fsm`, el pin `dcm_locked` del bloque
`rst_ps7_0_100M` está conectado al **reloj** (`processing_system7_0_FCLK_CLK0`).
Como el reloj oscila, el bloque de reset entra y sale de reset todo el tiempo.
La solución es dejar `dcm_locked` **sin conectar**: así el IP lo toma como `1` por defecto.

Además, las apps `hola_mundo` y `app_component` se crearon sobre plataformas
(`pynq_1` y `platform`) que **no tienen el DMA**. Por eso se crea una plataforma nueva
(`hw_lab_fsm`) y una app nueva (`app_dma`).

---

## 1. Preparar el repo

```
git pull
```

Haz todo lo que sigue **desde la carpeta raíz del repo**
(la que contiene `lab_fsm/`, `project_1/` y `scripts/`).

## 2. Abrir una terminal con Vivado y Vitis

**Opción A (recomendada):** en el menú Inicio de Windows busca
**"Vivado 2024.2 Tcl Shell"** o **"Vitis 2024.2 Command Prompt"** (pueden aparecer
dentro de la carpeta *Xilinx Design Tools*). Se abre una terminal que ya reconoce
los comandos. Después ve a la carpeta del repo con `cd`, por ejemplo:

```
cd C:\Users\<usuario>\Desktop\ProyectoDeFPGA\ProcesamientoAvanzadoFPGA
```

**Opción B:** en una terminal normal (cmd), carga el entorno a mano. La ruta puede
cambiar según dónde se instaló (`C:\Xilinx` o `C:\AMDDesignTools`):

```
call C:\Xilinx\Vivado\2024.2\settings64.bat
call C:\Xilinx\Vitis\2024.2\settings64.bat
```

Para comprobarlo: `vivado -version` y `vitis -version` deben mostrar `2024.2`.

---

## 3. Paso 1: Vivado (desconectar `dcm_locked`, generar el bitstream y el XSA)

```
vivado -mode batch -source scripts/fpga/01_fix_dcm_locked.tcl -log scripts/fpga/fix.log -nojournal
```

Tarda varios minutos, porque hace la síntesis y la implementación completas. Al final
aparece un bloque `RESUMEN`. Revisa lo siguiente:

| Qué mirar | Qué debe decir |
|---|---|
| `dcm_locked desconectado:` | `si` o `si (ya lo estaba)` |
| `validacion OK` | debe aparecer (si la validación falla, el script se detiene con `ERROR:`) |
| `WNS:` | un número **>= 0**. Si es negativo, el diseño no cumple timing: avisa al profesor |
| `XSA:` | la ruta `...\lab_fsm\hardware_wrapper.xsa` |

Si algo falla, el detalle completo está en `scripts/fpga/fix.log` y en
`lab_fsm/lab_fsm.runs/impl_1/runme.log`.

---

## 4. Paso 2: Vitis (plataforma `hw_lab_fsm` y app `app_dma`)

```
vitis -s scripts/fpga/02_crear_app_dma.py
```

El script hace lo siguiente:
1. Comprueba que el XSA traiga el `.bit` (imprime `XSA OK, incluye: ...bit`).
2. Crea y compila la plataforma **`hw_lab_fsm`** dentro de `project_1`.
3. Revisa el `xparameters.h` de esa plataforma.
4. Crea la app **`app_dma`** (Empty Application), copia `main_baremetal.c` como `src/main.c` y la compila.

En el `RESUMEN` final deben aparecer estos tres valores (los números pueden variar si alguien cambió el Address Editor):

```
XPAR_AXI_DMA_RECEPTION_BASEADDR = 0x40400000
XPAR_AXI_DMA_TRANSMISSION_BASEADDR = 0x40410000
XPAR_REGISTERCONTROL_LEDS_0_S00_AXI_BASEADDR = 0x43c00000
```

También debe aparecer la ruta del `.elf` de `app_dma`.

Si el script se detiene con `ERROR: faltan en ... xparameters.h`, la plataforma no tiene el DMA.
Revisa que el paso 1 haya terminado bien.

Las líneas marcadas con `# VERIFICAR EN VITIS` dentro del script se escribieron sin
poder probarlas en Vitis. Si alguna da error, ve al Plan B.

---

## 5. PLAN B: hacerlo a mano en la interfaz gráfica

### Vivado

1. Abre Vivado 2024.2: **File > Project > Open...** y elige `lab_fsm/lab_fsm.xpr`.
2. En *Flow Navigator* (a la izquierda) haz clic en **Open Block Design**.
3. Busca el bloque **`rst_ps7_0_100M`** (Processor System Reset).
4. Haz clic derecho sobre su pin **`dcm_locked`** y elige **Disconnect Pin**.
   No toques `slowest_sync_clk` ni ningún otro pin.
5. Pulsa **Validate Design** (tecla **F6**). No debe dar errores.
6. Guarda con **Ctrl+S**.
7. En *Flow Navigator* haz clic en **Generate Bitstream**. Si pregunta por síntesis
   o implementación, acepta (**Yes / OK**) y espera a que termine.
8. Ve a **File > Export > Export Hardware...**, elige **Include bitstream** y guarda
   como `hardware_wrapper.xsa` en la carpeta `lab_fsm` (junto a `lab_fsm.xpr`).
   Si pregunta si quieres sobrescribirlo, di que sí.

### Vitis

1. Abre Vitis 2024.2 y elige **File > Open Workspace** sobre la carpeta `project_1`.
2. **File > New Component > Platform**:
   - Nombre: `hw_lab_fsm`
   - Hardware design: el `lab_fsm/hardware_wrapper.xsa` nuevo
   - Sistema operativo: `standalone`; procesador: `ps7_cortexa9_0`
   - **Finish**, y luego **Build** sobre la plataforma.
3. **File > New Component > Application**:
   - Nombre: `app_dma`
   - Plataforma: **`hw_lab_fsm`** (no `pynq_1`, no `platform`)
   - Dominio: `standalone_ps7_cortexa9_0`
   - Plantilla: **Empty Application (C)**
4. Copia el contenido de `PracticaInstrumentacion/VitisFiles/main_baremetal.c` en un
   archivo nuevo `src/main.c` dentro de `app_dma`.
5. Haz **Build** sobre `app_dma`.
6. Para comprobar el resultado, abre el `xparameters.h` de la plataforma (en el
   explorador: `hw_lab_fsm > ... > include > xparameters.h`) y busca (**Ctrl+F**)
   `XPAR_AXI_DMA_RECEPTION_BASEADDR`. Debe existir.

---

## 6. Avisos importantes

- **Al programar la placa usa `app_dma`, no `hola_mundo`.** En la configuración de
  ejecución (*Run/Debug configuration* de `app_dma`), comprueba que la plataforma y
  el bitstream sean los de **`hw_lab_fsm`**. Si apunta a otra plataforma, se carga el
  **bitstream viejo** y el DMA no funciona, aunque la app compile.
- **Si compilas `main.c` sobre `pynq_1` o `platform`, fallará a propósito** con el
  mensaje `Plataforma sin DMA: crea la app sobre la plataforma del lab_fsm (hw_lab_fsm)`.
  Esto evita que el programa compile y luego falle en la placa.
- **Por qué no se reutilizan las plataformas viejas:** los archivos `.prj` y
  `vitis-comp.json` de `pynq_1`, `platform`, `hola_mundo` y `app_component` tienen
  rutas absolutas del PC donde se crearon (p. ej. `C:/Kevin/project_1/...`). En otro
  PC esas rutas no existen. Por eso se crea una plataforma nueva desde el XSA.
