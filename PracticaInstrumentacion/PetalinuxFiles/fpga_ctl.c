#define _DEFAULT_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>
#include <sys/mman.h>
#include "fpga_ctl.h"

/* DMA AXI Registers (direct mode) */
#define MM2S_DMACR 0x00       // DMA Control Register
#define MM2S_DMASR 0x04       // DMA Status Register
#define MM2S_SA    0x18       // Source Address
#define MM2S_LEN   0x28       // Transfer Length
#define S2MM_DMACR 0x30       // DMA Control Register
#define S2MM_DMASR 0x34       // DMA Status Register
#define S2MM_DA    0x48       // Destination Address
#define S2MM_LEN   0x58       // Transfer Length

#define CR_RUN     0x1        // DMA Run/Stop
#define CR_RESET   0x4        // DMA Reset
#define SR_IOC     0x1000     // Interrupt on Complete
#define SR_ERR     0x770      // Error bits (SR[12:6] + SR[3:0])

static int fd = -1;

// vectors definition for dma transfer
static volatile uint32_t *fsm, *dma_tx, *dma_rx;
static volatile uint32_t *txb, *rxb;

// function to map physical address to virtual address for DMA and FSM registers
static volatile uint32_t *map(off_t phys, size_t size)
{
    void *p = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, phys);
    return (p == MAP_FAILED) ? NULL : (volatile uint32_t *)p;
}

// inline functions to read and write to memory-mapped registers
static inline void wr(volatile uint32_t *base, uint32_t off, uint32_t v)
{
    base[off / 4] = v;
}

// inline function to read from memory-mapped registers
static inline uint32_t rd(volatile uint32_t *base, uint32_t off)
{
    return base[off / 4];
}


/* ---------------------------------------------------------
 * Initialization
 * --------------------------------------------------------- */
int hw_init(void)
{
    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) { perror("open /dev/mem"); return -1; }

    fsm    = map(FSM_BASE, 0x1000);
    dma_tx = map(DMA_MM2S_BASE, 0x1000);
    dma_rx = map(DMA_S2MM_BASE, 0x1000);
    txb    = map(TX_PHYS, 0x1000);
    rxb    = map(RX_PHYS, 0x1000);

    if (!fsm || !dma_tx || !dma_rx || !txb || !rxb) {
        perror("mmap");
        return -1;
    }
    return 0;
}

void hw_close(void)
{
    if (fd >= 0) close(fd);
    fd = -1;
}

/* ---------------------------------------------------------
 * FSM
 * --------------------------------------------------------- */
void fsm_set_mode(uint32_t mode)   { wr(fsm, 0x00, mode); }
void fsm_set_value(uint32_t value) { wr(fsm, 0x04, value); }

/* ---------------------------------------------------------
 * DMA
 * --------------------------------------------------------- */
uint32_t *dma_tx_buf(void) { return (uint32_t *)txb; }
uint32_t *dma_rx_buf(void) { return (uint32_t *)rxb; }

/* Odd: x + 5, Even: x - 2 */
uint32_t transform_expected(uint32_t x)
{
    return (x & 1U) ? x + 5U : x - 2U;
}

static int dma_wait(volatile uint32_t *base, uint32_t sr_off, const char *name)
{
    struct timespec t0, t;
    clock_gettime(CLOCK_MONOTONIC, &t0);

    for (;;) {
        uint32_t sr = rd(base, sr_off);
        if (sr & SR_ERR) {
            fprintf(stderr, "Error DMA %s: SR=0x%08x\n", name, sr);
            return -1;
        }
        if (sr & SR_IOC) return 0;

        clock_gettime(CLOCK_MONOTONIC, &t);
        if ((t.tv_sec - t0.tv_sec) > 1) {
            fprintf(stderr, "Timeout DMA %s: SR=0x%08x\n", name, sr);
            return -1;
        }
    }
}

int dma_run(void)
{
    const uint32_t bytes = NUM_WORDS * sizeof(uint32_t);

    for (int i = 0; i < NUM_WORDS; i++) rxb[i] = 0;

    /* Reset both channels */
    wr(dma_tx, MM2S_DMACR, <???>);
    wr(dma_rx, S2MM_DMACR, CR_RESET);
    while (rd(dma_tx, MM2S_DMACR) & CR_RESET) ;
    while (rd(dma_rx, S2MM_DMACR) & CR_RESET) ;

    /* Clear flags and enable channels */
    wr(dma_tx, <???>, 0x7000);
    wr(dma_rx, S2MM_DMASR, 0x7000);
    wr(dma_rx, S2MM_DMACR, CR_RUN);
    wr(dma_tx, MM2S_DMACR, <???>);

    /* S2MM first (receives), then MM2S (sends) */
    wr(dma_rx, S2MM_DA,  RX_PHYS);
    wr(dma_rx, S2MM_LEN, bytes);
    usleep(100);
    wr(dma_tx, MM2S_SA,  TX_PHYS);
    wr(dma_tx, MM2S_LEN, bytes);

    if (dma_wait(<???>, MM2S_DMASR, "MM2S")) return -1;
    if (dma_wait(dma_rx, S2MM_DMASR, "S2MM")) return -1;
    return 0;
}

// ----------------------------------------------------------
// ----------------------------------------------------------
// ----------------------------------------------------------
// ----------------------------------------------------------
// ----------------------------------------------------------
// ----------------------------------------------------------
// ----------------------------------------------------------
// ----------------------------------------------------------

/* ---------------------------------------------------------
 * Load the Bitstream and Clock 
 * --------------------------------------------------------- */
static int write_sysfs(const char *path, const char *value)
{
    FILE *f = fopen(path, "w");
    if (!f) { perror(path); return -1; }
    fputs(value, f);
    if (fclose(f) != 0) { perror(path); return -1; }
    return 0;
}

int pl_load(const char *bin_path)
{
    const char *name = strrchr(bin_path, '/');
    name = name ? name + 1 : bin_path;

    /* Copy to /lib/firmware */
    char dst[256];
    snprintf(dst, sizeof dst, "/lib/firmware/%s", name);

    FILE *in = fopen(bin_path, "rb");
    if (!in) { perror(bin_path); return -1; }
    FILE *out = fopen(dst, "wb");
    if (!out) { perror(dst); fclose(in); return -1; }

    char buf[4096];
    size_t n;
    while ((n = fread(buf, 1, sizeof buf, in)) > 0)
        fwrite(buf, 1, n, out);
    fclose(in);
    fclose(out);

    /* Program the PL (flags=0: full bitstream) */
    if (write_sysfs("/sys/class/fpga_manager/fpga0/flags", "0")) return -1;
    if (write_sysfs("/sys/class/fpga_manager/fpga0/firmware", name)) return -1;

    /* Check status */
    char state[32] = {0};
    FILE *s = fopen("/sys/class/fpga_manager/fpga0/state", "r");
    if (s) { fgets(state, sizeof state, s); fclose(s); }
    printf("fpga_manager: %s", state);

    return strncmp(state, "operating", 9) == 0 ? 0 : -1;
}

int pl_clock_init(void)
{
    int own = (fd < 0);
    if (own) {
        fd = open("/dev/mem", O_RDWR | O_SYNC);
        if (fd < 0) { perror("open /dev/mem"); return -1; }
    }

    volatile uint32_t *slcr = map(SLCR_BASE, 0x1000);
    if (!slcr) { perror("mmap SLCR"); return -1; }

    wr(slcr, 0x008, 0xDF0D);        /* SLCR_UNLOCK */
    wr(slcr, 0x170, 0x00200500);    /* FCLK0 = 100 MHz (IO PLL 1000/5/2) */
    wr(slcr, 0x900, 0xF);           /* level shifters PS<->PL */
    wr(slcr, 0x240, 0x0);           /* release PL resets */
    wr(slcr, 0x004, 0x767B);        /* SLCR_LOCK */

    munmap((void *)slcr, 0x1000);
    if (own) { close(fd); fd = -1; }
    return 0;
}