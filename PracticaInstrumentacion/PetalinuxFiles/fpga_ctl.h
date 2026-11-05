#ifndef FPGA_CTL_H
#define FPGA_CTL_H

#include <stdint.h>

/* Register map based on the Address Editor of Vivado */
#define FSM_BASE        0x43C00000UL
#define DMA_MM2S_BASE   0x40400000UL
#define DMA_S2MM_BASE   0x40410000UL
#define SLCR_BASE       0xF8000000UL

/* DMA Buffers: Free Region in the kernel, *not well implemented, task for Fabian* */
#define TX_PHYS         0x1C000000UL
#define RX_PHYS         0x1C001000UL
#define NUM_WORDS       16

enum fsm_mode { FSM_IDLE = 0, FSM_RIGHT, <???>, FSM_VALUE, FSM_FIFO };

/* Load the PL (root is required) */
int  pl_load(const char *bin_path);   /* .bin (no .bit) via fpga_manager */
int  pl_clock_init(void);             /* FCLK0 = 100 MHz + resets          */

/* hardware access */
int  hw_init(void);
void hw_close(void);

/* FSM */
void fsm_set_mode(uint32_t mode);
void fsm_set_value(uint32_t value);

/* DMA */
uint32_t *dma_tx_buf(void);
uint32_t *dma_rx_buf(void);
int  dma_run(void);                   /* 0 = ok, -1 = error */
uint32_t transform_expected(uint32_t x);

#endif
