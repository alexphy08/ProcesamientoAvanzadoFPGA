#include "xil_printf.h"
#include "xil_io.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "sleep.h"
#include "xuartps.h"
#include <stdint.h>

/* =========================================================
 * AXI DMA
 * ========================================================= */
#define DMA_MM2S_BASE      0x40400000U   // AXI DMA MM2S base address
#define DMA_S2MM_BASE      0x40410000U   // AXI DMA S2MM base address

#define MM2S_DMACR         0x00U         // DMA Control Register
#define MM2S_DMASR         0x04U         // DMA Status Register
#define MM2S_SA            0x18U         // Source Address
#define MM2S_LENGTH        0x28U         // Transfer Length

#define S2MM_DMACR         0x30U         // DMA Control Register
#define S2MM_DMASR         0x34U         // DMA Status Register
#define S2MM_DA            0x48U         // Destination Address
#define S2MM_LENGTH        0x58U         // Transfer Length

#define DMA_CR_RUNSTOP     0x00000001U // Run/Stop bit
#define DMA_CR_RESET       0x00000004U // Reset bit
#define DMA_SR_IOC         0x00001000U // Interrupt on Completion
#define DMA_SR_ERRORS      0x00000770U // Error flags

/* =========================================================
 * FSM AXI-Lite
 * Register 0: MODE
 * Register 1: VALUE
 * ========================================================= */
#define FSM_CONTROL_BASEADDR  0x43C00000U

#define FSM_MODE_REG          0x00U
#define FSM_VALUE_REG         0x04U

#define FSM_MODE_IDLE         0U
#define FSM_MODE_RIGHT        1U
#define <???>                 2U
#define FSM_MODE_VALUE        3U
#define FSM_MODE_FIFO         4U

/* =========================================================
 * DMA buffers
 * Each buffer occupies 16 * 4 = 64 bytes.
 * Addresses are aligned to 64 bytes and non-overlapping.
 * Verify that both regions are reserved in DDR.
 * ========================================================= */
#define NUM_WORDS             16U
#define TRANSFER_BYTES        (NUM_WORDS * sizeof(uint32_t))

static volatile uint32_t tx_buffer[NUM_WORDS] __attribute__((aligned(32)));
static volatile uint32_t rx_buffer[NUM_WORDS] __attribute__((aligned(32)));

/* =========================================================
 * FSM control
 * ========================================================= */
static void fsm_set_mode(uint32_t mode) {
	<???>(FSM_CONTROL_BASEADDR + FSM_MODE_REG, mode);
	xil_printf("FSM MODE = %u\r\n", (unsigned int) mode);
}

static void fsm_set_value(uint32_t value) {
	Xil_Out32(<???> + FSM_VALUE_REG, value);

	xil_printf("FSM VALUE = 0x%08x (%u)\r\n", (unsigned int) value,
			(unsigned int) value);
}

/* =========================================================
 * Read a decimal number via UART
 *
 * Accepts CR, LF, or CR+LF as line termination.
 * Checks for uint32_t overflow.
 * ========================================================= */
static uint32_t uart_read_uint(void) {
	uint32_t value = 0U;
	uint32_t digit;
	char c;
	int have_digit = 0;

	while (1) {
		c = inbyte();

		if (c == '\r' || c == '\n') {
			/*
			 * Ignore leftover line breaks from the
			 * previous input (for example, CR+LF).
			 */
			if (!have_digit) {
				continue;
			}

			xil_printf("\r\n");
			return value;
		}

		if (c >= '0' && c <= '9') {
			digit = (uint32_t) (c - '0');

			if (value <= (UINT32_MAX - digit) / 10U) {
				value = value * 10U + digit;
				have_digit = 1;
				xil_printf("%c", c);
			} else {
				xil_printf("\r\nNumber out of range. Please try again.\r\n");
				value = 0U;
				have_digit = 0;

				/* Discard the rest of this line. */
				while (1) {
					c = inbyte();
					if (c == '\r' || c == '\n') {
						break;
					}
				}

				xil_printf("Enter the value again: ");
			}
		}
	}
}

/* =========================================================
 * Capture the 16 input data words
 * ========================================================= */
static void read_dma_input(void) {
	xil_printf("\r\n====================================\r\n");
	xil_printf(" DMA INPUT DATA\r\n");
	xil_printf(" Enter 16 decimal integers.\r\n");
	xil_printf("====================================\r\n");

	for (uint32_t i = 0; i < NUM_WORDS; i++) {
		xil_printf("Data [%u/%u]: ", (unsigned int) (i + 1U),
				(unsigned int) NUM_WORDS);

		tx_buffer[i] = uart_read_uint();
	}

	xil_printf("\r\nInput data:\r\n");

	for (uint32_t i = 0; i < NUM_WORDS; i++) {
		xil_printf("[%u] = %u\r\n", (unsigned int) i,
				(unsigned int) tx_buffer[i]);
	}
}

/* =========================================================
 * Reset DMA
 * ========================================================= */
static void dma_reset(void) {
	Xil_Out32(DMA_MM2S_BASE + MM2S_DMACR, <???>);
	Xil_Out32(DMA_S2MM_BASE + S2MM_DMACR, DMA_CR_RESET);

	while (Xil_In32(DMA_MM2S_BASE + MM2S_DMACR) & DMA_CR_RESET) {
	}

	while (Xil_In32(DMA_S2MM_BASE + S2MM_DMACR) & DMA_CR_RESET) {
	}
}

/* =========================================================
 * Wait for DMA completion
 * ========================================================= */
static int dma_wait_complete(uint32_t base, uint32_t status_reg) {
	uint32_t status;

	for (uint32_t timeout = 0; timeout < 100000000U; timeout++) {
		status = Xil_In32(base + status_reg);

		if (status & DMA_SR_ERRORS) {
			xil_printf("Error DMA: base=0x%08x, SR=0x%08x\r\n",
					(unsigned int) base, (unsigned int) status);
			return -1;
		}

		if (status & DMA_SR_IOC) {
			return 0;
		}
	}

	xil_printf("Timeout DMA: base=0x%08x, SR=0x%08x\r\n", (unsigned int) base,
			(unsigned int) Xil_In32(base + status_reg));

	return -1;
}

/* =========================================================
 * Calculate the expected result of the PL transform
 *
 * Odd:  x + 5
 * Even: x - 2
 *
 * Arithmetic is uint32_t, just like an unsigned 32-bit
 * operation.
 * ========================================================= */
static uint32_t transform_expected(uint32_t x) {
	if ((x & 1U) != 0U) {
		return x + 5U;
	}

	return x - 2U;
}

/* =========================================================
 * DMA test with 16 data values entered via UART
 * ========================================================= */
static int run_dma_test(void) {
	uint32_t input;
	uint32_t actual;
	uint32_t expected;
	int errors = 0;

	/*
	 * Request the data first.
	 * The buffer is not modified after MM2S starts.
	 */
	read_dma_input();

	for (uint32_t i = 0; i < NUM_WORDS; i++) {
		rx_buffer[i] = 0U;
	}

	/*
	 * Prepare memory for the DMA transfers.
	 */
	Xil_DCacheFlushRange((INTPTR) tx_buffer, TRANSFER_BYTES);
	Xil_DCacheFlushRange((INTPTR) rx_buffer, TRANSFER_BYTES);

	xil_printf("\r\nResetting DMA...\r\n");
	dma_reset();

	/* Clear interrupt flags */
	Xil_Out32(<???> + MM2S_DMASR, 0x00007000U);
	Xil_Out32(DMA_S2MM_BASE + S2MM_DMASR, 0x00007000U);

	/* Enable channels */
	Xil_Out32(DMA_S2MM_BASE + S2MM_DMACR, DMA_CR_RUNSTOP);
	Xil_Out32(DMA_MM2S_BASE + <???>, DMA_CR_RUNSTOP);

	/*
	 * Configure S2MM first to receive from the PL.
	 */
	xil_printf("Configuring S2MM: %u bytes...\r\n",
			(unsigned int) TRANSFER_BYTES);

	Xil_Out32(DMA_S2MM_BASE + S2MM_DA, (uint32_t) (INTPTR) rx_buffer);
	Xil_Out32(DMA_S2MM_BASE + S2MM_LENGTH, TRANSFER_BYTES);

	usleep(100);

	/*
	 * Configure MM2S to send the data to the PL.
	 */
	xil_printf("Configuring MM2S: %u bytes...\r\n",
			(unsigned int) TRANSFER_BYTES);

	Xil_Out32(DMA_MM2S_BASE + MM2S_SA, (uint32_t) (INTPTR) tx_buffer);
	Xil_Out32(DMA_MM2S_BASE + MM2S_LENGTH, TRANSFER_BYTES);

	/* Wait for MM2S completion */
	if (dma_wait_complete(DMA_MM2S_BASE, MM2S_DMASR) != 0) {
		xil_printf("MM2S failed.\r\n");
		return -1;
	}

	xil_printf("MM2S completed.\r\n");

	/* Wait for S2MM completion */
	if (dma_wait_complete(DMA_S2MM_BASE, S2MM_DMASR) != 0) {
		xil_printf("S2MM failed.\r\n");
		return -1;
	}

	xil_printf("S2MM completed.\r\n");

	/*
	 * Invalidate the cache to read the data written
	 * by the DMA in DDR.
	 */
	Xil_DCacheInvalidateRange((INTPTR) rx_buffer, TRANSFER_BYTES);

	/*
	 * Compare each result with the transformation
	 * corresponding to the user-entered data.
	 */
	xil_printf("\r\n");
	xil_printf("===============================================\r\n");
	xil_printf(" INDEX | INPUT | RECEIVED | EXPECTED | STATUS\r\n");
	xil_printf("===============================================\r\n");

	for (uint32_t i = 0; i < NUM_WORDS; i++) {
		input = tx_buffer[i];
		actual = rx_buffer[i];
		expected = transform_expected(input);

		xil_printf("  %2d   | %7d | %8d | %8d | %s\r\n",
				(unsigned int) (i + 1U), (unsigned int) input,
				(unsigned int) actual, (unsigned int) expected,
				(actual == expected) ? "OK" : "ERROR");

		if (actual != expected) {
			errors++;
		}
	}

	xil_printf("===============================================\r\n");

	if (errors == 0) {
		xil_printf("\r\nDMA TEST PASSED: 16/16 data values correct.\r\n");
		return 0;
	}

	xil_printf("\r\nDMA TEST FAILED: %d of %u data values incorrect.\r\n",
			errors, (unsigned int) NUM_WORDS);

	return -1;
}

/* =========================================================
 * FSM menu
 * ========================================================= */
static void print_menu(void) {
	xil_printf("\r\n========== FSM MENU ==========\r\n");
	xil_printf("0 - Idle\r\n");
	xil_printf("1 - Drift right\r\n");
	xil_printf("2 - Drift left\r\n");
	xil_printf("3 - Show VALUE on the LEDs\r\n");
	xil_printf("4 - Read FIFO and show it on the LEDs + DMA test\r\n");
	xil_printf("==============================\r\n");
	xil_printf("Select mode (0-4): ");
}

/* =========================================================
 * Main program
 * ========================================================= */
int main(void) {
	char command;
	uint32_t value;

	xil_printf("\r\nZynq-7000 | AXI DMA | FSM Control\r\n");

	/* Start in idle mode */
	fsm_set_mode(FSM_MODE_IDLE);

	while (1) {
		print_menu();
		command = inbyte();
		xil_printf("%c\r\n", command);

		switch (command) {
		case '0':
			fsm_set_mode(FSM_MODE_IDLE);
			break;

		case '1':
			fsm_set_mode(<???>);
			break;

		case '2':
			fsm_set_mode(FSM_MODE_LEFT);
			break;

		case '3':
			value = uart_read_uint();
			fsm_set_value(value);
			fsm_set_mode(FSM_MODE_VALUE);
			break;

		case '4':
			/*
			 * Select FIFO mode before sending the data.
			 */
			fsm_set_mode(FSM_MODE_FIFO);
			usleep(1000);

			if (run_dma_test() != 0) {
				xil_printf("The DMA test failed.\r\n");
			}

			break;

		case '\r':
		case '\n':
			/* Ignore end-of-line */
			break;

		default:
			xil_printf("Invalid command. Use 0, 1, 2, 3, or 4.\r\n");
			break;
		}
	}

	return 0;
}
