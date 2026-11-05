#include <stdio.h>
#include <stdlib.h>
#include "fpga_ctl.h"


// ---------------------------------------------------------
// Functions to read command line input and run the DMA test
static int read_uint(const char *prompt, uint32_t *out)
{
    char line[64];
    printf("%s", prompt);
    fflush(stdout);
    if (!fgets(line, sizeof line, stdin)) return -1;
    *out = (uint32_t)strtoul(line, NULL, 10);
    return 0;
}

// Run a DMA test: read NUM_WORDS integers, send them to the PL, and check the results
static void dma_test(void)
{
    uint32_t *tx = dma_tx_buf(), *rx = dma_rx_buf();
    int errors = 0;

    fsm_set_mode(FSM_FIFO); // Switch to FIFO mode for the DMA test

    // Fill the TX buffer with user input
    printf("\nEnter %d decimal integers.\n", NUM_WORDS);
    for (int i = 0; i < NUM_WORDS; i++) {
        char p[32];
        snprintf(p, sizeof p, "Data [%d/%d]: ", i + 1, NUM_WORDS);
        if (read_uint(p, &tx[i])) return;
    }

    // Run the DMA transfer
    if (dma_run() != 0) {
        printf("The DMA test failed.\n");
        return;
    }

    printf("\n IDX | INPUT | RECEIVED | EXPECTED | STATUS\n");
    printf("-----------------------------------------------\n");
    for (int i = 0; i < NUM_WORDS; i++) {
        uint32_t exp = transform_expected(tx[i]);
        int ok = (rx[i] == exp);
        printf(" %3d | %7u | %8u | %8u | %s\n",
               i + 1, tx[i], rx[i], exp, ok ? "OK" : "ERROR");
        if (!ok) errors++;
    }

    if (errors)
        printf("\nDMA TEST FAILED: %d of %d data values incorrect\n", errors, NUM_WORDS);
    else
        printf("\nDMA TEST PASSED: %d/%d data values correct\n", NUM_WORDS, NUM_WORDS);
}

int main(int argc, char **argv)
{
    /* Usage: sudo ./fsm_demo [file.bin]
     * With an argument: loads the bitstream and configures the clock.
     * Without an argument: assumes the PL is already loaded. */
    if (argc > 1) {
        printf("Loading %s ...\n", argv[1]);
        if (pl_load(argv[1]) != 0) {
            fprintf(stderr, "Could not load the bitstream\n");
            return 1;
        }
        if (pl_clock_init() != 0) return 1;
    }

    if (hw_init() != 0) return 1;
    fsm_set_mode(FSM_IDLE);

    for (;;) {
        uint32_t cmd, v;

        printf("\n========== FSM MENU ==========\n");
        printf("0 - Idle\n");
        printf("1 - Drift right\n");
        printf("2 - Drift left\n");
        printf("3 - Show VALUE on the LEDs\n");
        printf("4 - FIFO + DMA test\n");
        printf("9 - Exit\n");
        printf("==============================\n");
        if (read_uint("Select: ", &cmd)) break;

        switch (cmd) {
        case 0: fsm_set_mode(FSM_IDLE);  break;
        case 1: fsm_set_mode(<???>); break;
        case 2: <???>(FSM_LEFT);  break;
        case 3:
            if (read_uint("Value: ", &v)) break;
            fsm_set_value(v);
            fsm_set_mode(FSM_VALUE);
            break;
        case 4: dma_test(); break;
        case 9: fsm_set_mode(FSM_IDLE); hw_close(); return 0;
        default: printf("Invalid command\n");
        }
    }

    hw_close();
    return 0;
}
