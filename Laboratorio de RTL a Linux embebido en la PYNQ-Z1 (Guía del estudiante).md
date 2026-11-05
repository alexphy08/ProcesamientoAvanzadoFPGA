# Laboratorio: de RTL a Linux embebido en la PYNQ-Z1

**Autores**: Fabian Andres Castaño Usuga, Jorge Hernán López Botero

**Curso**: Instrumentación Científica, Módulo de FPGAs y SoC.

**Guía del estudiante:** Vivado, Vitis y PetaLinux 2022.2

## Sobre esta guía

Esta guía se construyó con ayuda de Claude, un asistente de IA, a partir de un proyecto que nosotros implementamos y validamos. Su propósito es que ustedes desarrollen ese proyecto completo y nos ayuden a convertir la guía en un documento que otros estudiantes puedan replicar en el futuro.

Para eso, les pedimos que agreguen fragmentos de código, fotos de la implementación y capturas de pantalla de las configuraciones y de la creación de los proyectos. Los lugares donde se esperan están marcados como `[Captura: ...]`.

Algunos archivos que les entregaremos contienen **errores introducidos a propósito**, marcados con `<???>`. Quedarán documentados en la guía y ustedes deberán corregirlos, así Jorge y Fabian podrán ver cuánto han aprendido en el curso. Los errores intencionales están solo en los archivos de código y en el archivo de restricciones `pynq_c.xdc`; los comandos y las tablas de la guía están completos.

La guía también puede tener errores involuntarios, porque parte de ella no se probó en hardware. Si algo no funciona como se describe, anótenlo y repórtenlo: eso también mejora el documento.

Esperamos que disfruten el desafío.

## 1. Qué vas a construir

Vas a diseñar un sistema en la FPGA de la PYNQ-Z1 y a controlarlo desde el procesador ARM de tres maneras distintas: sin sistema operativo, con FreeRTOS y con Linux embebido. El **hardware es el mismo en las tres**; lo que cambia es el modelo de software.

| Sesión | Tema                                                | Resultado esperado                             |
| ------- | --------------------------------------------------- | ---------------------------------------------- |
| 1       | Hardware: RTL, IP AXI-Lite, AXI-Stream con DMA      | Archivo `hardware_wrapper.xsa` con bitstream |
| 2       | Software: bare-metal y FreeRTOS en Vitis            | Menú por UART y prueba DMA 16/16              |
| 3       | Linux: imagen PetaLinux, overlay y aplicación en C | La misma prueba DMA corriendo bajo Linux       |

### Arquitectura final

```
PS (ARM)  --AXI-Lite-->  RegisterControl_leds  --mode,val-->  fsm_controller --> 4 LEDs
   |                                                              ^
   +--AXI-Lite--> DMA MM2S --> FIFO0 --> broadcaster --+--> FIFO1 -+  (s_axis)
   |                                                    |
   +--AXI-Lite--> DMA S2MM <-- stream_transform <-------+

tick_generator --tick--> fsm_controller
```

### Mapa de direcciones

| Bloque                          | Dirección base | Tamaño |
| ------------------------------- | --------------- | ------- |
| `RegisterControl_leds`        | `0x43C00000`  | 64 KB   |
| DMA de recepción (solo MM2S)   | `0x40400000`  | 64 KB   |
| DMA de transmisión (solo S2MM) | `0x40410000`  | 64 KB   |

Registros del IP de control: **offset `0x00` = MODE** y **offset `0x04` = VALUE**.

| MODE | Estado de la FSM | Comportamiento de los LEDs                                   |
| ---- | ---------------- | ------------------------------------------------------------ |
| 0    | IDLE             | Un LED encendido                                             |
| 1    | RIGHT            | Corrimiento hacia la derecha                                 |
| 2    | LEFT             | Corrimiento hacia la izquierda                               |
| 3    | VALUE            | Muestra los 4 bits de VALUE                                  |
| 4    | DMA              | Muestra los 4 bits bajos de cada dato recibido por el stream |

El `stream_transform` aplica: **si el dato es impar, suma 5; si es par, resta 2** (aritmética de 32 bits sin signo).

### Archivos de apoyo

Tu docente te entrega estos archivos, organizados por carpeta. Los archivos de código traen huecos marcados con `<???>` que debes completar para que compilen y funcionen.

| Carpeta            | Archivos                                                                                 | Se usan en                      |
| ------------------ | ---------------------------------------------------------------------------------------- | ------------------------------- |
| `VivadoFiles`    | `tick_generator.vhd`, `fsm_controller.vhd`, `stream_transform.vhd`, `pynq_c.xdc` | Sesión 1, etapas 1 y 3         |
| `VitisFiles`     | `main_baremetal.c`                                                                     | Sesión 2, bare-metal           |
| `VitisFiles`     | `main_freertos.c`                                                                      | Sesión 2, FreeRTOS             |
| `PetalinuxFiles` | `pynq_z1.bsp`                                                                          | Sesión 3, crear la imagen      |
| `PetalinuxFiles` | `bit2bin.py`                                                                           | Sesión 3, overlay              |
| `PetalinuxFiles` | `fpga_ctl.h`, `fpga_ctl.c`, `main.c`                                               | Sesión 3, aplicación en Linux |

No se entregan `top_leds.vhd` ni los archivos del IP `RegisterControl_leds`: los construyes siguiendo la guía.

---

## 2. Sesión 1: Hardware

### 2.1 Crear el proyecto

1. Abre Vivado 2022.2 y crea un proyecto RTL llamado `lab_fsm`.
2. Selecciona la parte **xc7z020clg400-1** (PYNQ-Z1).
3. Añade los fuentes VHDL de la etapa 1.

&#91;Captura: ventana de creación del proyecto con la parte xc7z020clg400-1\]

### 2.2 Etapa 1: RTL puro con LEDs y pulsadores

Objetivo: entender la FSM sin procesador. Los switches eligen el modo y los pulsadores fijan el valor.

La FSM avanza solo con el **flanco de subida de `tick`**. El `tick_generator` cuenta ciclos de reloj y cambia el nivel de `tick` cada `HALF_PERIOD_MS` milisegundos. El número de ciclos es `(CLK_FREQ_HZ / 1000) * HALF_PERIOD_MS`, así que el parámetro `CLK_FREQ_HZ` **debe coincidir con el reloj real**. En esta etapa el reloj es el `sysclk` de la placa, de 125 MHz.

Crea `top_leds.vhd`:

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_leds is
    Port (
        sysclk : in  std_logic;
        sw     : in  std_logic_vector(1 downto 0);
        btn    : in  std_logic_vector(3 downto 0);
        led    : out std_logic_vector(3 downto 0);
        tick   : out std_logic
    );
end top_leds;

architecture Behavioral of top_leds is
    signal tick_s : std_logic;
    signal mode_s : std_logic_vector(2 downto 0);
begin
    mode_s <= '0' & sw;   -- 00 IDLE, 01 RIGHT, 10 LEFT, 11 VALUE

    u_tick : entity work.tick_generator
        generic map (CLK_FREQ_HZ => 125_000_000, HALF_PERIOD_MS => 125)
        port map (clk => sysclk, rst => '1', tick => tick_s);

    u_fsm : entity work.fsm_controller
        port map (
            clk => sysclk, rst => '1',
            mode => mode_s, tick => tick_s, val => btn,
            leds => led,
            s_axis_tdata  => (others => '0'),
            s_axis_tkeep  => (others => '0'),
            s_axis_tvalid => '0',
            s_axis_tready => open,
            s_axis_tlast  => '0'
        );

    tick <= tick_s;
end Behavioral;
```

**Antes de sintetizar**, comprueba la sintaxis de los VHDL: en la consola Tcl de Vivado ejecuta `check_syntax`. Señala los huecos `<???>` en segundos, mientras que la síntesis tarda minutos. *Este comando no se probó al preparar la guía: si en tu versión de Vivado es distinto, corrígelo aquí.*

Añade `pynq_c.xdc` como restricciones, define `top_leds` como módulo superior y genera el bitstream.

**Prueba en la placa** (Hardware Manager → Program Device):

- `sw = 00`: un LED fijo.
- `sw = 01` o `10`: el LED corre en un sentido u otro, cuatro pasos por segundo.
- `sw = 11`: los LEDs copian los pulsadores en cada flanco de `tick`.

&#91;Foto: LEDs de la placa con cada combinación de switches\]

&#91;Código: `tick_generator.vhd` y `fsm_controller.vhd` con los huecos corregidos\]

&#91;Resultado: consola Tcl con `check_syntax` sin errores\]

**Preguntas**

1. ¿Con qué frecuencia ocurre el flanco de subida de `tick`? ¿Por qué no es cada 125 ms?
2. ¿Qué pasaría si dejas `CLK_FREQ_HZ = 125_000_000` pero el reloj real fuera de 100 MHz?
3. El modo `"100"` (DMA) existe en la FSM pero no lo puedes activar con dos switches. ¿Por qué?

### 2.3 Etapa 2: la FSM como IP AXI-Lite

Objetivo: que el procesador, y ya no los switches, escriba MODE y VALUE.

1. **Tools → Create and Package New IP → Create a new AXI4 peripheral.**
2. Nombre: `RegisterControl_leds`. Deja el *vendor*, la librería y la versión por defecto (`xilinx.com`, `user`, `1.0`): así el IP queda identificado como `xilinx.com:user:RegisterControl_leds:1.0`, igual que en el diseño de referencia. Interfaz: **Lite**, esclavo, 32 bits, 4 registros.
3. Selecciona **Edit IP** y modifica los dos VHDL que generó Vivado, como se detalla debajo de esta lista.
4. En el IP Packager, pestaña **Review and Package**, pulsa **Re-Package IP**.
5. En el proyecto principal: **Settings → IP → Repository** y añade la carpeta donde se empaquetó el IP.

**Detalle del paso 3.** Añade los puertos `mode[2:0]` y `val[3:0]` y aliméntalos con los registros 0 y 1:

- En `RegisterControl_leds_v1_0_S00_AXI.vhd`: los dos puertos en la `entity`, las señales `mode_reg` y `val_reg`, y las asignaciones en la zona de lógica de usuario.
- En `RegisterControl_leds_v1_0.vhd`: los dos puertos en la `entity`, en la declaración del componente `S00_AXI` y en su instancia (`mode => mode`, `val => val`).

```vhdl
-- Puertos (entity de ambos archivos)
mode : out std_logic_vector(2 downto 0);
val  : out std_logic_vector(3 downto 0);

-- Señales (arquitectura de S00_AXI)
signal mode_reg : std_logic_vector(2 downto 0) := "000";
signal val_reg  : std_logic_vector(3 downto 0) := "0000";

-- Lógica de usuario (S00_AXI)
-- Add user logic here
mode_reg <= slv_reg0(2 downto 0);
val_reg  <= slv_reg1(3 downto 0);

mode <= mode_reg;
val  <= val_reg;
-- User logic ends
```

&#91;Captura: pestaña Review and Package del IP Packager\]

&#91;Captura: repositorio de IP añadido en Settings → IP → Repository\]

&#91;Captura: IP `RegisterControl_leds` visible en el IP Catalog\]

**Idea clave:** un IP AXI-Lite es una FSM de bus más un banco de registros. Tu lógica solo ve las señales `mode` y `val`.

### 2.4 Etapa 3: AXI-Stream, FIFO y DMA

Objetivo: mover datos entre la memoria y la FPGA sin que el procesador los copie.

Construyes el diseño de bloques a mano. Las tablas de más abajo dicen exactamente cómo debe quedar cada bloque, cómo se conectan y qué direcciones deben tener: si tu diseño no coincide con ellas, ahí está el error.

1. Crea un proyecto nuevo con la placa **PYNQ-Z1** (parte `xc7z020clg400-1`). Añade `fsm_controller.vhd`, `tick_generator.vhd` y `stream_transform.vhd` como fuentes, y el repositorio del IP `RegisterControl_leds`.
2. Crea un diseño de bloques llamado `hardware`. Añade el **ZYNQ7 Processing System** y ejecuta **Run Block Automation** para aplicar el preset de la placa.
3. En el PS habilita **M\_AXI\_GP0** y **S\_AXI\_GP0**, y comprueba que `FCLK_CLK0` esté a 100 MHz.
4. Añade el resto de bloques y configúralos según la **tabla de parámetros**. `tick_generator`, `fsm_controller` y `stream_transform` se añaden con **Add Module**.
5. Haz las conexiones de la **tabla de conexiones**. Para los enlaces AXI puedes usar **Run Connection Automation**, pero revisa después que coincidan con la tabla.
6. Marca como puertos externos `led` (4 bits) y `tick`, y renómbralos así para que coincidan con `pynq_c.xdc`. Ese archivo incluye líneas de otros puertos (`sysclk`, `sw`, `btn`) que no existen en este diseño: coméntalas.
7. Abre el **Address Editor** y compáralo con la **tabla de direcciones**. Si Vivado asignó otras, corrígelas.
8. **Validate Design** (F6) debe terminar sin errores.
9. Crea el HDL wrapper (**Let Vivado manage wrapper**): se genera `hardware_wrapper`.
10. **Generate Bitstream**.
11. **File → Export → Export Hardware**, marcando **Include bitstream**. Obtienes `hardware_wrapper.xsa`.
12. Opcional: selecciona los dos DMA, los dos FIFO, el broadcaster, `stream_transform_0` y el interconnect de memoria, y agrúpalos con **Create Hierarchy** con el nombre `DataStreamDMA`. Solo ordena el diagrama; no cambia el funcionamiento.

**Tabla de parámetros**

| Bloque                                      | Parámetro                           | Valor                                               |
| ------------------------------------------- | ------------------------------------ | --------------------------------------------------- |
| `axi_dma_reception` (AXI DMA)             | Enable Scatter Gather Engine         | Desactivado                                         |
| `axi_dma_reception` (AXI DMA)             | Enable Write Channel (S2MM)          | Desactivado: solo el canal de lectura MM2S          |
| `axi_dma_reception` (AXI DMA)             | Width of Buffer Length Register      | 8 (opcional; limita cada transferencia a 255 bytes) |
| `axi_dma_transmission` (AXI DMA)          | Enable Scatter Gather Engine         | Desactivado                                         |
| `axi_dma_transmission` (AXI DMA)          | Enable Read Channel (MM2S)           | Desactivado: solo el canal de escritura S2MM        |
| `axi_dma_transmission` (AXI DMA)          | Width of Buffer Length Register      | 8 (opcional; limita cada transferencia a 255 bytes) |
| `fifo_generator_0` y `fifo_generator_1` | Interface Type                       | AXI Stream                                          |
| `fifo_generator_0` y `fifo_generator_1` | Clocking                             | Common clock                                        |
| `fifo_generator_0` y `fifo_generator_1` | TDATA                                | 4 bytes                                             |
| `fifo_generator_0` y `fifo_generator_1` | TLAST                                | Activado                                            |
| `fifo_generator_0` y `fifo_generator_1` | TKEEP                                | Activado                                            |
| `fifo_generator_0` y `fifo_generator_1` | TUSER                                | Ancho 0                                             |
| `fifo_generator_0` y `fifo_generator_1` | Profundidad                          | 16                                                  |
| `axis_broadcaster_0`                      | Todos                                | Valores por defecto                                 |
| `axi_mem_intercon` (AXI Interconnect)     | Slave Interfaces / Master Interfaces | 2 / 1                                               |
| `ps7_0_axi_periph` (AXI Interconnect)     | Slave Interfaces / Master Interfaces | 1 / 3                                               |
| `rst_ps7_0_100M` (Processor System Reset) | Todos                                | Valores por defecto                                 |
| `tick_generator_0`                        | `CLK_FREQ_HZ`                      | 100000000                                           |

**Tabla de conexiones**

| Origen                                 | Destino                                                                                         |
| -------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `processing_system7_0/M_AXI_GP0`     | `ps7_0_axi_periph/S00_AXI`                                                                    |
| `ps7_0_axi_periph/M00_AXI`           | `RegisterControl_leds_0/S00_AXI`                                                              |
| `ps7_0_axi_periph/M01_AXI`           | `axi_dma_reception/S_AXI_LITE`                                                                |
| `ps7_0_axi_periph/M02_AXI`           | `axi_dma_transmission/S_AXI_LITE`                                                             |
| `axi_dma_reception/M_AXI_MM2S`       | `axi_mem_intercon/S00_AXI`                                                                    |
| `axi_dma_transmission/M_AXI_S2MM`    | `axi_mem_intercon/S01_AXI`                                                                    |
| `axi_mem_intercon/M00_AXI`           | `processing_system7_0/S_AXI_GP0`                                                              |
| `axi_dma_reception/M_AXIS_MM2S`      | `fifo_generator_0/S_AXIS`                                                                     |
| `fifo_generator_0/M_AXIS`            | `axis_broadcaster_0/S_AXIS`                                                                   |
| `axis_broadcaster_0/M00_AXIS`        | `stream_transform_0/s_axis`                                                                   |
| `axis_broadcaster_0/M01_AXIS`        | `fifo_generator_1/S_AXIS`                                                                     |
| `stream_transform_0/m_axis`          | `axi_dma_transmission/S_AXIS_S2MM`                                                            |
| `fifo_generator_1/M_AXIS`            | `fsm_controller_0/s_axis`                                                                     |
| `RegisterControl_leds_0/mode`        | `fsm_controller_0/mode`                                                                       |
| `RegisterControl_leds_0/val`         | `fsm_controller_0/val`                                                                        |
| `tick_generator_0/tick`              | `fsm_controller_0/tick` y puerto externo `tick`                                             |
| `fsm_controller_0/leds`              | puerto externo `led`                                                                          |
| `processing_system7_0/FCLK_CLK0`     | Entrada de reloj de todos los demás bloques, incluidos `M_AXI_GP0_ACLK` y `S_AXI_GP0_ACLK` |
| `processing_system7_0/FCLK_RESET0_N` | `rst_ps7_0_100M/ext_reset_in`                                                                 |
| `rst_ps7_0_100M/peripheral_aresetn`  | Entrada de reset de todos los bloques, incluido `fsm_controller_0/rst`                        |

**Tabla de direcciones**

| Segmento                             | Dirección base | Rango                   |
| ------------------------------------ | --------------- | ----------------------- |
| `RegisterControl_leds_0`           | `0x43C00000`  | 64 KB                   |
| `axi_dma_reception` (registros)    | `0x40400000`  | 64 KB                   |
| `axi_dma_transmission` (registros) | `0x40410000`  | 64 KB                   |
| DDR vista por cada DMA               | `0x00000000`  | 512 MB (`0x20000000`) |

El código en C usa estas tres direcciones base como constantes: si Vivado asigna otras, el programa no encontrará los registros.

&#91;Captura: Address Editor con las tres direcciones base\]

&#91;Captura: diagrama de bloques completo\]

&#91;Captura: configuración del DMA de recepción (solo el canal MM2S)\]

&#91;Captura: configuración del DMA de transmisión (solo el canal S2MM)\]

&#91;Captura: configuración de los dos FIFO AXI4-Stream\]

&#91;Captura: configuración del AXI4-Stream Broadcaster\]

&#91;Captura: jerarquía `DataStreamDMA` expandida\]

&#91;Resultado: Validate Design sin errores\]

**Qué contiene el diseño**

| Bloque                   | Función                                                    |
| ------------------------ | ----------------------------------------------------------- |
| `processing_system7_0` | ARM, DDR, UART0, SD, Ethernet, USB. `FCLK0 = 100 MHz`     |
| `axi_dma_reception`    | Lee de la DDR (MM2S) y entrega un stream                    |
| `fifo_generator_0`     | Almacena el stream de entrada (16 palabras)                 |
| `axis_broadcaster_0`   | Duplica el stream hacia dos destinos                        |
| `stream_transform_0`   | Calcula x+5 (impar) o x−2 (par)                            |
| `axi_dma_transmission` | Recibe el stream transformado y lo escribe en la DDR (S2MM) |
| `fifo_generator_1`     | Almacena la copia que va a la FSM                           |
| `fsm_controller_0`     | Muestra los datos en los LEDs cuando MODE = 4               |
| `tick_generator_0`     | `CLK_FREQ_HZ = 100 MHz` (coincide con FCLK0)              |

Los dos DMA acceden a la DDR por el puerto **S\_AXI\_GP0** del PS.

**Preguntas**

1. ¿Por qué en esta etapa `CLK_FREQ_HZ` pasó de 125 MHz a 100 MHz?
2. La FSM solo consume un dato por flanco de `tick`. ¿Cuánto tarda en mostrarse el dato 16 en los LEDs?
3. `fifo_generator_1` tiene profundidad 16. ¿Qué pasaría si se enviaran 32 palabras? Razona sobre el comportamiento del broadcaster.

---

## 3. Sesión 2: Software en Vitis

### 3.1 Crear la plataforma

1. Abre Vitis 2022.2 y crea una **plataforma** a partir de `hardware_wrapper.xsa`.
2. Añade un dominio **standalone** (bare-metal) sobre `ps7_cortexa9_0`.
3. Compila la plataforma.

&#91;Captura: plataforma compilada en Vitis\]

### 3.2 Aplicación bare-metal

Crea una aplicación vacía sobre esa plataforma y reemplaza `main.c` por `main_baremetal.c`. Completa los huecos `<???>` hasta que compile.

La DMA en modo directo funciona siempre igual: **reset → limpiar flags → activar el canal (RUN) → escribir la dirección → escribir la longitud**. Escribir la longitud arranca la transferencia.

```c
// Orden usado: primero S2MM (queda esperando datos), luego MM2S.
Xil_Out32(DMA_S2MM_BASE + S2MM_DA,     RX_BUFFER_ADDR);
Xil_Out32(DMA_S2MM_BASE + S2MM_LENGTH, TRANSFER_BYTES);
Xil_Out32(DMA_MM2S_BASE + MM2S_SA,     TX_BUFFER_ADDR);
Xil_Out32(DMA_MM2S_BASE + MM2S_LENGTH, TRANSFER_BYTES);
```

&#91;Código: secuencia de la DMA con los huecos corregidos\]

La **caché** es crítica: antes de lanzar la DMA hay que hacer `Xil_DCacheFlushRange` (escribir a la DDR lo que preparó la CPU) y, al terminar, `Xil_DCacheInvalidateRange` (descartar copias viejas para leer lo que escribió la DMA).

**Prueba:** conecta la UART (115200 8N1), ejecuta y usa el menú. La opción 4 pide 16 enteros y debe mostrar 16/16 correctos. Ejemplo: la entrada 0 produce `4294967294`, porque 0 − 2 en 32 bits sin signo hace desbordamiento.

&#91;Captura: salida por UART de la prueba DMA con 16/16 correctos\]

&#91;Resultado: salida por UART del menú y de las opciones 1, 2 y 3\]

**Preguntas**

1. ¿Qué ocurre si quitas el `Xil_DCacheInvalidateRange`? Pruébalo y explica.
2. ¿Por qué se configura primero S2MM y después MM2S?
3. `inbyte()` espera con un bucle activo. ¿Qué problema causaría en un sistema con varias tareas?

### 3.3 Migración a FreeRTOS

1. En la plataforma, añade un dominio con el SO **freertos10\_xilinx** y recompila.
2. Crea una aplicación sobre ese dominio y reemplaza `main.c` por `main_freertos.c`. Completa los huecos `<???>`.
3. Verifica en la configuración del BSP que el tick sea de 1000 Hz y el heap de al menos 64 KB.

El programa se reparte en tareas:

| Tarea         | Prioridad | Función                                                                    |
| ------------- | --------- | --------------------------------------------------------------------------- |
| `uart_rx`   | 3         | Lee el UART sin bloquear y mete cada byte en una **cola**             |
| `cli`       | 2         | Menú, FSM y DMA. Espera en estado *Blocked* hasta que llega un carácter |
| `heartbeat` | 1         | Incrementa un contador cada 500 ms                                          |

Cambios respecto a bare-metal:

- La espera de entrada ya no es activa: `cli` duerme hasta que la cola tiene datos.
- Los timeouts se miden en *ticks* y se cede la CPU con `vTaskDelay(1)`.
- Los buffers DMA son **arrays estáticos alineados a 32 bytes**, ya no direcciones fijas.
- Se mantiene el flush e invalidate de caché.
- `xil_printf` no es seguro entre hilos: imprime solo una tarea.

**Prueba:** la opción 5 muestra el contador `Heartbeat`. Pulsa la opción 5 varias veces, con pausas, mientras el menú espera: el contador debe seguir subiendo. Eso demuestra que ninguna tarea bloquea el sistema.

&#91;Captura: opción 5 mostrando el contador Heartbeat\]

&#91;Código: `uart_rx_task` y `dma_wait_complete` con los huecos corregidos\]

**Preguntas**

1. ¿Por qué `uart_rx` tiene mayor prioridad que `cli`?
2. El FIFO del UART es de 64 bytes y a 115200 baudios llegan unos 11,5 bytes por milisegundo. ¿Qué pasaría si `uart_rx` sondeara cada 10 ms?
3. ¿Qué ventaja tendría usar interrupciones en lugar de sondeo?

---

## 4. Sesión 3: Linux embebido con PetaLinux

### 4.1 Qué cambia respecto a bare-metal

| Tema                      | Bare-metal / FreeRTOS                  | Linux                                                         |
| ------------------------- | -------------------------------------- | ------------------------------------------------------------- |
| Arranque                  | `ps7_init` y FSBL cargan el programa | FSBL → U-Boot → kernel → *root filesystem*               |
| Descripción del hardware | `xparameters.h` en compilación      | **Device tree** en tiempo de arranque                   |
| Acceso a registros        | Puntero directo                        | Memoria virtual: `mmap` sobre `/dev/mem`                  |
| Caché                    | Tú haces flush e invalidate           | `/dev/mem` abierto con `O_SYNC` es **no cacheable** |
| Memoria para DMA          | Dirección fija en tu programa         | La gestiona el kernel                                         |
| Carga del bitstream       | Dentro de `BOOT.BIN`                 | FPGA Manager + overlay en tiempo de ejecución                |

### 4.2 Crear la imagen desde el BSP

El BSP ya contiene la configuración necesaria (sistema de archivos EXT4, UART, memoria y paquetes). No tienes que configurar el kernel ni el *rootfs*.

```bash
source /opt/petalinux/2022.2/settings.sh
petalinux-create -t project -s pynq_z1.bsp
cd pynq_z1
petalinux-build
```

La primera compilación completa tarda horas. Tu docente te indicará si debes usar la caché compartida (`sstate-cache`) o la imagen ya compilada.

Empaqueta `BOOT.BIN`:

```bash
petalinux-package --boot --format BIN \
  --fsbl images/linux/zynq_fsbl.elf \
  --fpga images/linux/system.bit \
  --u-boot --force
```

&#91;Captura: compilación de PetaLinux terminada sin errores\]

### 4.3 Preparar la tarjeta SD

Crea dos particiones:

- **Partición 1**, FAT32 (512 MB): copia `BOOT.BIN`, `image.ub` y `boot.scr` desde `images/linux/`.
- **Partición 2**, ext4 (resto): extrae el sistema de archivos.

```bash
sudo tar xf images/linux/rootfs.tar.gz -C /media/$USER/rootfs
sync
```

Pon el jumper de arranque en **SD**, conecta el cable micro-USB y la red, y abre la consola serie a 115200 baudios. Debes ver FSBL, U-Boot, el kernel y finalmente el prompt de login.

&#91;Foto: consola serie mostrando el arranque hasta el login\]

### 4.4 Cargar tu diseño con un overlay

El `system.bit` incluido en la imagen es el del BSP. Tu diseño se carga **en tiempo de ejecución** con un *device tree overlay*, sin recompilar nada.

**Paso 1. Convertir el bitstream.** El FPGA Manager del Zynq exige un archivo `.bin` sin la cabecera de Vivado y con los bytes de cada palabra invertidos. `bit2bin.py` lo hace:

```python
import struct, sys
d = open(sys.argv[1], 'rb').read()
i = 2 + struct.unpack('>H', d[0:2])[0] + 2
for key in b'abcd':
    assert d[i] == key
    i += 3 + struct.unpack('>H', d[i+1:i+3])[0]
assert d[i] == ord('e')
n = struct.unpack('>I', d[i+1:i+5])[0]
raw = d[i+5:i+5+n]
out = b''.join(raw[j:j+4][::-1] for j in range(0, len(raw), 4))
open(sys.argv[2], 'wb').write(out)
```

```bash
python3 bit2bin.py hardware_wrapper.bit mi_diseno.bin
hexdump -C -n 64 mi_diseno.bin
```

&#91;Resultado: salida de `hexdump` con los bytes `66 55 99 aa`\]

**Comprueba el resultado:** en el volcado deben aparecer los bytes `66 55 99 aa` cerca del inicio y **ningún texto legible**. Si ves el nombre del diseño o la fecha, el archivo todavía tiene la cabecera del `.bit`, y el kernel lo rechazará con el mensaje *Invalid bitstream, could not find a sync word*.

**Paso 2. El overlay.** Crea `mi_diseno.dts` en el PC:

```dts
/dts-v1/;
/plugin/;
/ {
    fragment@0 {
        target-path = "/fpga-full";
        __overlay__ {
            firmware-name = "mi_diseno.bin";
        };
    };
};
```

```bash
dtc -@ -I dts -O dtb -o mi_diseno.dtbo mi_diseno.dts
```

**Paso 3. Cargarlo en la placa.**

```bash
sudo cp mi_diseno.bin mi_diseno.dtbo /lib/firmware/
sudo mkdir /sys/kernel/config/device-tree/overlays/full
echo -n mi_diseno.dtbo | sudo tee /sys/kernel/config/device-tree/overlays/full/path
cat /sys/class/fpga_manager/fpga0/state
```

El estado debe ser `operating`. Si falla, `dmesg | tail` indica la causa; el error `Direct firmware load ... failed with error -2` significa que el nombre del archivo en `/lib/firmware` no coincide con `firmware-name`.

&#91;Captura: fpga\_manager/fpga0/state con el valor operating\]

Para descargarlo: `sudo rmdir /sys/kernel/config/device-tree/overlays/full`.

**Paso 4. Verificar que responde.**

```bash
sudo devmem 0x43C00000          # lee MODE
sudo devmem 0x43C00000 32 1     # RIGHT: los LEDs corren
sudo devmem 0x43C00000 32 0     # vuelve a IDLE
```

Si la lectura responde, la PL y su reloj están activos. Si la consola se queda colgada, el bitstream no se cargó.

&#91;Resultado: salida de `devmem` antes y después de escribir MODE\]

### 4.5 La aplicación en C

El código de `fpga_ctl.c` es el mismo que ya conoces, adaptado al modelo de Linux:

```c
fd  = open("/dev/mem", O_RDWR | O_SYNC);     // O_SYNC: mapeo no cacheable
fsm = mmap(NULL, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, fd, FSM_BASE);
fsm[0] = 4;                                   // MODE = FIFO
```

&#91;Código: `fpga_ctl.c` con los huecos corregidos\]

Compila y ejecuta en la placa, **sin argumentos**, porque el overlay ya cargó la PL:

```bash
gcc -O2 -Wall main.c fpga_ctl.c -o fsm_demo
sudo ./fsm_demo
```

&#91;Resultado: compilación de `fsm_demo` sin errores\]

Prueba las opciones 1, 2 y 3 (LEDs) y luego la 4. Debes obtener otra vez **16/16 datos correctos**.

&#91;Captura: prueba DMA con 16/16 datos correctos bajo Linux\]

**Preguntas**

1. ¿Por qué aquí no hace falta `Xil_DCacheFlushRange`?
2. Los buffers están en `0x1C000000`. ¿Quién decide que esa zona no la use Linux para otra cosa? (Lee la nota de la sección 5.)
3. Resume en una tabla qué cambió entre bare-metal, FreeRTOS y Linux para: acceso a registros, caché, memoria DMA y carga del bitstream.

---

## 5. Nota adicional: memoria de la DMA

En esta práctica los buffers están en `0x1C000000` y `0x1C001000`. En este sistema Linux **no reserva** esa zona: `/proc/iomem` (con `sudo`) muestra `00000000-1fffffff : System RAM`, o sea, el kernel considera suya toda la memoria. La prueba funciona porque el kernel normalmente no ha usado esas páginas todavía, pero no hay garantía.

La solución correcta es un nodo `reserved-memory` en el device tree:

```dts
reserved-memory {
    #address-cells = <1>;
    #size-cells = <1>;
    ranges;
    dma_buf: dma_buf@1c000000 {
        reg = <0x1c000000 0x100000>;
        no-map;
    };
};
```

Ese nodo se añade en `project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi` y obliga a modificar el BSP y reconstruir la imagen. No lo haremos en esta práctica, pero conviene que lo conozcas.

## 6. Problemas frecuentes

| Síntoma                                            | Causa probable                                              | Qué hacer                                                 |
| --------------------------------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------- |
| `Invalid bitstream, could not find a sync word`   | El `.bin` conserva la cabecera del `.bit`               | Repite `bit2bin.py` y revisa con `hexdump`             |
| `Direct firmware load ... error -2`               | El nombre no coincide con `firmware-name`                 | Copia el `.bin` con el nombre exacto                     |
| `devmem` o el programa se cuelga                  | La PL no está cargada                                      | Revisa `fpga0/state` y `dmesg`                         |
| `open /dev/mem: Permission denied`                | Falta `sudo`                                              | Ejecuta con `sudo`                                       |
| `/proc/iomem` muestra solo ceros                  | Falta `sudo`                                              | `sudo grep -i "system ram" /proc/iomem`                  |
| `Kernel panic ... System is deadlocked on memory` | El *rootfs* está dentro de `image.ub` y no cabe en RAM | Usa el tipo de rootfs EXT4 del BSP                         |
| `undefined reference to xStreamBuffer...`         | El BSP de FreeRTOS no incluye *stream buffers*            | Usa la versión con cola (`xQueue`)                      |
| Timeout de la DMA con `SR=0x...01`                | El canal está detenido                                     | Revisa el reset de la DMA y las conexiones AXI del diseño |
