# 02_crear_app_dma.py
# Crea en el workspace project_1 una plataforma NUEVA "hw_lab_fsm" a partir del
# XSA del lab_fsm (con AXI DMA) y una app "app_dma" con main_baremetal.c.
# No borra ni modifica pynq_1, platform, hardware, hola_mundo ni app_component.
#
# Uso (desde la raiz del repo, en la terminal de Vitis 2024.2):
#   vitis -s scripts/fpga/02_crear_app_dma.py
#
# Requiere haber corrido antes 01_fix_dcm_locked.tcl (genera lab_fsm/hardware_wrapper.xsa).

import glob
import os
import re
import shutil
import sys
import zipfile

import vitis

# ---------------------------------------------------------------
# a) Rutas relativas al repo
# ---------------------------------------------------------------
try:
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
except NameError:  # VERIFICAR EN VITIS: si 'vitis -s' no define __file__
    SCRIPT_DIR = os.path.dirname(os.path.abspath(sys.argv[0]))
REPO_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
WORKSPACE = os.path.join(REPO_ROOT, "project_1")
XSA_FILE = os.path.join(REPO_ROOT, "lab_fsm", "hardware_wrapper.xsa")
MAIN_SRC = os.path.join(REPO_ROOT, "PracticaInstrumentacion", "VitisFiles", "main_baremetal.c")

PLATFORM_NAME = "hw_lab_fsm"
APP_NAME = "app_dma"
CPU = "ps7_cortexa9_0"
DOMAIN = "standalone_" + CPU  # nombre por defecto del dominio standalone en 2024.x

REQUIRED_DEFINES = [
    "XPAR_AXI_DMA_RECEPTION_BASEADDR",
    "XPAR_AXI_DMA_TRANSMISSION_BASEADDR",
    "XPAR_REGISTERCONTROL_LEDS_0_S00_AXI_BASEADDR",
]


def fallar(msg):
    print("ERROR: " + msg)
    sys.exit(1)


def comprobar_xsa(xsa):
    """El XSA es un zip: comprueba que traiga el bitstream."""
    if not os.path.isfile(xsa):
        fallar("no existe el XSA: " + xsa + " (corre antes 01_fix_dcm_locked.tcl)")
    with zipfile.ZipFile(xsa) as z:
        bits = [n for n in z.namelist() if n.lower().endswith(".bit")]
    if not bits:
        fallar("el XSA no incluye .bit; reexporta con 'Include bitstream'")
    print("XSA OK, incluye: " + ", ".join(bits))


def buscar_xparameters(platform_dir):
    candidatos = glob.glob(os.path.join(platform_dir, "**", "xparameters.h"), recursive=True)
    # Preferir el del dominio standalone exportado; ignorar el del FSBL.
    candidatos = [c for c in candidatos if "fsbl" not in c.lower()]
    candidatos.sort(key=lambda c: ("export" not in c, len(c)))
    return candidatos[0] if candidatos else None


def leer_defines(xparam_file):
    valores = {}
    with open(xparam_file, encoding="utf-8", errors="replace") as f:
        texto = f.read()
    for name in REQUIRED_DEFINES:
        m = re.search(r"#define\s+" + name + r"\s+(\S+)", texto)
        valores[name] = m.group(1) if m else None
    return valores


def obtener_o_crear(client, name, crear):
    """Reutiliza el componente si ya existe (re-ejecucion del script)."""
    if os.path.isdir(os.path.join(WORKSPACE, name)):
        print("El componente '" + name + "' ya existe: se reutiliza.")
        return client.get_component(name=name)
    return crear()


# ---------------------------------------------------------------
# b) Comprobaciones previas
# ---------------------------------------------------------------
if not os.path.isdir(WORKSPACE):
    fallar("no existe el workspace: " + WORKSPACE)
if not os.path.isfile(MAIN_SRC):
    fallar("no existe " + MAIN_SRC)
comprobar_xsa(XSA_FILE)

client = vitis.create_client()
client.set_workspace(path=WORKSPACE)

try:
    # -----------------------------------------------------------
    # c) Plataforma nueva hw_lab_fsm
    # -----------------------------------------------------------
    platform = obtener_o_crear(
        client,
        PLATFORM_NAME,
        lambda: client.create_platform_component(
            name=PLATFORM_NAME,
            hw_design=XSA_FILE,
            os="standalone",
            cpu=CPU,
            domain_name=DOMAIN,  # VERIFICAR EN VITIS: en algunas versiones el dominio se nombra solo
        ),
    )
    platform.build()

    platform_dir = os.path.join(WORKSPACE, PLATFORM_NAME)
    xpfm = glob.glob(os.path.join(platform_dir, "export", "**", "*.xpfm"), recursive=True)
    if not xpfm:
        fallar("no se encontro el .xpfm de " + PLATFORM_NAME + " tras compilarla")
    xpfm = xpfm[0]
    print("Plataforma: " + xpfm)

    # Comprobar xparameters.h ANTES de compilar la app (main.c tiene #error si faltan)
    xparam = buscar_xparameters(platform_dir)
    if xparam is None:
        fallar("no se encontro xparameters.h en " + platform_dir)
    valores = leer_defines(xparam)
    faltan = [n for n, v in valores.items() if v is None]
    if faltan:
        fallar("faltan en " + xparam + ": " + ", ".join(faltan))

    # -----------------------------------------------------------
    # d) App app_dma (Empty Application, C)
    # -----------------------------------------------------------
    app = obtener_o_crear(
        client,
        APP_NAME,
        lambda: client.create_app_component(
            name=APP_NAME,
            platform=xpfm,
            domain=DOMAIN,
            template="empty_application",  # VERIFICAR EN VITIS: client.get_templates(type="EMBD_APP")
        ),
    )

    # Copiar main_baremetal.c como src/main.c
    src_dir = os.path.join(WORKSPACE, APP_NAME, "src")
    os.makedirs(src_dir, exist_ok=True)
    shutil.copyfile(MAIN_SRC, os.path.join(src_dir, "main.c"))
    print("Copiado " + MAIN_SRC + " -> " + os.path.join(src_dir, "main.c"))
    # VERIFICAR EN VITIS: si el build no ve main.c, usar en su lugar
    #   app.import_files(from_loc=os.path.dirname(MAIN_SRC), files=["main_baremetal.c"], dest_dir_in_cmp="src")
    # y renombrar a main.c.

    app.build()

    elf = glob.glob(os.path.join(WORKSPACE, APP_NAME, "build", "*.elf"))
    if not elf:
        fallar("no se genero el .elf de " + APP_NAME)

    # -----------------------------------------------------------
    # e) Resumen
    # -----------------------------------------------------------
    print("")
    print("================ RESUMEN ================")
    print("Plataforma: " + xpfm)
    print("xparameters.h: " + xparam)
    for name in REQUIRED_DEFINES:
        print("  " + name + " = " + valores[name])
    print("ELF: " + elf[0])
    print("=========================================")
finally:
    vitis.dispose()
