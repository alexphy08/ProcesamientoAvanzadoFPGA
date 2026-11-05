/* =========================================================
 * Zynq-7000 | AXI DMA | FSM Control - FreeRTOS version
 *
 * Tasks:
 *   uart_rx   (prio 3) reads the UART WITHOUT blocking and stores
 *                      the bytes in a StreamBuffer.
 *   cli       (prio 2) menu + FSM + DMA. Waits for input in
 *                      the Blocked state (does not consume CPU).
 *   heartbeat (prio 1) demonstrates that the scheduler is still
 *                      alive while the user is typing.
 *
 * Note: xil_printf is NOT thread-safe. Here, only the "cli"
 * task prints. If another task needs to print, protect it with
 * a mutex.
 * ========================================================= */
#include <stdint.h>

#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"

#include "xil_printf.h"
#include "xil_io.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "xuartps_hw.h"

/* =========================================================
 * Configuration
 * ========================================================= */
#define RX_STREAM_SIZE        128U
#define INPUT_TIMEOUT_MS      60000U   /* maximum time to type a value */
#define DMA_TIMEOUT_MS        1000U
#define KEY_ESC               0x1B

/* Convert ms to ticks, ensuring at least 1 tick */
static inline TickType_t ms_to_ticks(uint32_t ms) {
	TickType_t t = pdMS_TO_TICKS(ms);
	return (t == 0) ? 1 : t;
}

/* =========================================================
 * AXI DMA
 * ========================================================= */
#define DMA_MM2S_BASE      0x40400000U  // AXI DMA MM2S base address
#define DMA_S2MM_BASE      0x40410000U  // AXI DMA S2MM base address

#define MM2S_DMACR         0x00U        // DMA Control Register
#define MM2S_DMASR         0x04U        // DMA Status Register
#define MM2S_SA            0x18U        // Source Address
#define MM2S_LENGTH        0x28U        // Transfer Length

#define S2MM_DMACR         0x30U        // DMA Control Register
#define S2MM_DMASR         0x34U        // DMA Status Register
#define S2MM_DA            0x48U        // Destination Address
#define S2MM_LENGTH        0x58U        // Transfer Length

#define DMA_CR_RUNSTOP     0x00000001U  // Run/Stop bit
#define DMA_CR_RESET       0x00000004U  // Reset bit
#define DMA_SR_IOC         0x00001000U  // Interrupt on Completion
#define DMA_SR_ERRORS      0x00000770U  // Error flags

/* =========================================================
 * FSM AXI-Lite
 * ========================================================= */
#define FSM_CONTROL_BASEADDR  0x43C00000U
#define FSM_MODE_REG          0x00U
#define FSM_VALUE_REG         0x04U

#define FSM_MODE_IDLE         0U
#define FSM_MODE_RIGHT        1U
#define FSM_MODE_LEFT         2U
#define FSM_MODE_VALUE        3U
#define <???>                 4U

/* =========================================================
 * DMA buffers
 * Static arrays in .bss (inside the DDR managed by the linker
 * script), aligned to the A9 cache line (32 B).
 * Fixed addresses are no longer used: they could overwrite code
 * or the heap.
 * ========================================================= */
#define NUM_WORDS             16U
#define TRANSFER_BYTES        (NUM_WORDS * sizeof(uint32_t))

static volatile uint32_t tx_buffer[NUM_WORDS] __attribute__((aligned(32)));
static volatile uint32_t rx_buffer[NUM_WORDS] __attribute__((aligned(32)));

/* =========================================================
 * Shared state
 * ========================================================= */
static QueueHandle_t rx_stream;
static volatile uint32_t current_mode = FSM_MODE_IDLE;
static volatile uint32_t heartbeat_count = 0;

/* =========================================================
 * UART RX task: non-blocking read via registers
 *
 * Low-level macros (xuartps_hw.h) are used instead of
 * XUartPs_CfgInitialize() to avoid reconfiguring the UART that
 * already uses xil_printf as the console.
 *
 * The UART FIFO is 64 bytes; at 115200 baud, about 11.5 bytes/ms
 * are received, so it is polled every tick (1 ms with the default
 * configuration of 1000 Hz).
 * ========================================================= */
static void uart_rx_task(void *arg) {
	(void) arg;

	for (;;) {
		while (XUartPs_IsReceiveData(STDIN_BASEADDRESS)) {
			uint8_t c = (uint8_t) XUartPs_ReadReg(STDIN_BASEADDRESS,
					XUARTPS_FIFO_OFFSET);
			/* If the queue is full, the byte is discarded */
			xQueueSend(rx_stream, &c, 0);
		}
		vTaskDelay(1);
	}
}

/* Returns a byte, or -1 if the timeout expires. The task stays
 * in the Blocked state while waiting. */
static int console_getc(TickType_t timeout) {
	uint8_t c;

	if (xQueueReceive(rx_stream, &c, timeout) == pdTRUE) {
		return (int) c;
	}
	return -1;
}

/* =========================================================
 * FSM control
 * ========================================================= */
static void fsm_set_mode(uint32_t mode) {
	Xil_Out32(<???> + FSM_MODE_REG, mode);
	current_mode = mode;
	xil_printf("FSM MODE = %u\r\n", (unsigned int) mode);
}

static void fsm_set_value(uint32_t value) {
	Xil_Out32(FSM_CONTROL_BASEADDR + <???>, value);
	xil_printf("FSM VALUE = 0x%08x (%u)\r\n", (unsigned int) value,
			(unsigned int) value);
}

/* =========================================================
 * Read a decimal number via UART
 *
 * - Accepts CR, LF, or CR+LF as line termination.
 * - Checks for uint32_t overflow.
 * - Backspace deletes the last digit.
 * - ESC cancels.
 * - If nothing is typed within INPUT_TIMEOUT_MS, it aborts
 *   (the task never stays blocked forever).
 * ========================================================= */
#define INPUT_OK        0
#define INPUT_CANCEL   -1
#define INPUT_TIMEOUT  -2

static int console_read_uint(uint32_t *out) {
	uint32_t value = 0U;
	uint32_t ndigits = 0U;
	int discard = 0;
	int c;

	for (;;) {
		c = console_getc(ms_to_ticks(INPUT_TIMEOUT_MS));

		if (c < 0) {
			xil_printf("\r\nTimeout expired.\r\n");
			return INPUT_TIMEOUT;
		}

		if (c == KEY_ESC) {
			xil_printf("\r\nInput canceled.\r\n");
			return INPUT_CANCEL;
		}

		if (c == '\r' || c == '\n') {
			if (discard) {
				/* End of line with number out of range */
				discard = 0;
				value = 0U;
				ndigits = 0U;
				xil_printf("Enter the value again: ");
				continue;
			}
			if (ndigits == 0U) {
				/* Ignore leftover line breaks (CR+LF) */
				continue;
			}
			xil_printf("\r\n");
			*out = value;
			return INPUT_OK;
		}

		if (discard) {
			continue;
		}

		if ((c == 0x08 || c == 0x7F) && ndigits > 0U) {
			value /= 10U;
			ndigits--;
			xil_printf("\b \b");
			continue;
		}

		if (c >= '0' && c <= '9') {
			uint32_t digit = (uint32_t) (c - '0');

			if (value <= (UINT32_MAX - digit) / 10U) {
				value = value * 10U + digit;
				ndigits++;
				xil_printf("%c", c);
			} else {
				xil_printf("\r\nNumber out of range. Please try again.\r\n");
				discard = 1;
			}
		}
	}
}

/* =========================================================
 * Capture the 16 input data values
 * ========================================================= */
static int read_dma_input(void) {
	int rc;
	uint32_t v;

	xil_printf("\r\n====================================\r\n");
	xil_printf(" DMA INPUT DATA\r\n");
	xil_printf(" Enter 16 decimal integers.\r\n");
	xil_printf(" (ESC cancels)\r\n");
	xil_printf("====================================\r\n");

	for (uint32_t i = 0; i < NUM_WORDS; i++) {
		xil_printf("Data [%u/%u]: ", (unsigned int) (i + 1U),
				(unsigned int) NUM_WORDS);

		rc = console_read_uint(&v);
		if (rc != INPUT_OK) {
			return rc;
		}
		tx_buffer[i] = v;
	}

	xil_printf("\r\nInput data:\r\n");
	for (uint32_t i = 0; i < NUM_WORDS; i++) {
		xil_printf("[%u] = %u\r\n", (unsigned int) i,
				(unsigned int) tx_buffer[i]);
	}
	return INPUT_OK;
}

/* =========================================================
 * Reset DMA (with iteration limit)
 * ========================================================= */
static int dma_reset(void) {
	uint32_t guard;

	Xil_Out32(DMA_MM2S_BASE + MM2S_DMACR, <???>);
	Xil_Out32(<???> + S2MM_DMACR, DMA_CR_RESET);

	for (guard = 1000000U; guard > 0U; guard--) {
		if (!(Xil_In32(DMA_MM2S_BASE + MM2S_DMACR) & DMA_CR_RESET)
				&& !(Xil_In32(DMA_S2MM_BASE + S2MM_DMACR) & DMA_CR_RESET)) {
			return 0;
		}
	}

	xil_printf("DMA reset timeout.\r\n");
	return -1;
}

/* =========================================================
 * Wait for DMA completion
 *
 * It first checks the status immediately (the 64-byte transfer
 * ends in microseconds); if it is not ready, it yields the CPU
 * for 1 tick between reads. The timeout is measured in ticks.
 * ========================================================= */
static int dma_wait_complete(uint32_t base, uint32_t status_reg) {
	const TickType_t start = xTaskGetTickCount();
	const TickType_t limit = ms_to_ticks(DMA_TIMEOUT_MS);
	uint32_t status;

	for (;;) {
		status = Xil_In32(base + status_reg);

		if (status & DMA_SR_ERRORS) {
			xil_printf("Error DMA: base=0x%08x, SR=0x%08x\r\n",
					(unsigned int) base, (unsigned int) status);
			return -1;
		}

		if (status & DMA_SR_IOC) {
			return 0;
		}

		if ((xTaskGetTickCount() - start) >= limit) {
			xil_printf("Timeout DMA: base=0x%08x, SR=0x%08x\r\n",
					(unsigned int) base,
					(unsigned int) Xil_In32(base + status_reg));
			return -1;
		}

		vTaskDelay(1);
	}
}

/* =========================================================
 * Expected result of the PL transformer
 * Odd: x + 5    Even: x - 2   (unsigned uint32_t)
 * ========================================================= */
static uint32_t transform_expected(uint32_t x) {
	if ((x & 1U) != 0U) {
		return x + 5U;
	}
	return x - 2U;
}

/* =========================================================
 * DMA test with 16 data values entered via UART
 * Returns: 0 = OK, -1 = failure, 1 = canceled by user
 * ========================================================= */
static int run_dma_test(void) {
	uint32_t input, actual, expected;
	int errors = 0;

	if (read_dma_input() != INPUT_OK) {
		return 1;
	}

	for (uint32_t i = 0; i < NUM_WORDS; i++) {
		rx_buffer[i] = 0U;
	}

	/* Write to DDR what the DMA sees */
	Xil_DCacheFlushRange((INTPTR) tx_buffer, TRANSFER_BYTES);
	Xil_DCacheFlushRange((INTPTR) rx_buffer, TRANSFER_BYTES);

	xil_printf("\r\nResetting DMA...\r\n");
	if (dma_reset() != 0) {
		return -1;
	}

	/* Clear interrupt flags */
	Xil_Out32(DMA_MM2S_BASE + MM2S_DMASR, 0x00007000U);
	Xil_Out32(DMA_S2MM_BASE + S2MM_DMASR, 0x00007000U);

	/* Enable channels */
	Xil_Out32(DMA_S2MM_BASE + <???>, DMA_CR_RUNSTOP);
	Xil_Out32(DMA_MM2S_BASE + MM2S_DMACR, DMA_CR_RUNSTOP);

	/* S2MM first: it is ready to receive from the PL */
	xil_printf("Configuring S2MM: %u bytes...\r\n",
			(unsigned int) TRANSFER_BYTES);
	Xil_Out32(DMA_S2MM_BASE + S2MM_DA, (uint32_t) (INTPTR) rx_buffer);
	Xil_Out32(DMA_S2MM_BASE + S2MM_LENGTH, TRANSFER_BYTES);

	/* Then MM2S: sends the data to the PL */
	xil_printf("Configuring MM2S: %u bytes...\r\n",
			(unsigned int) TRANSFER_BYTES);
	Xil_Out32(DMA_MM2S_BASE + MM2S_SA, (uint32_t) (INTPTR) tx_buffer);
	Xil_Out32(DMA_MM2S_BASE + MM2S_LENGTH, TRANSFER_BYTES);

	if (dma_wait_complete(DMA_MM2S_BASE, MM2S_DMASR) != 0) {
		xil_printf("MM2S failed.\r\n");
		return -1;
	}
	xil_printf("MM2S completed.\r\n");

	if (dma_wait_complete(DMA_S2MM_BASE, S2MM_DMASR) != 0) {
		xil_printf("S2MM failed.\r\n");
		return -1;
	}
	xil_printf("S2MM completed.\r\n");

	/* Read from DDR what the DMA wrote */
	Xil_DCacheInvalidateRange((INTPTR) rx_buffer, TRANSFER_BYTES);

	xil_printf("\r\n");
	xil_printf("===============================================\r\n");
	xil_printf(" INDEX | INPUT | RECEIVED | EXPECTED | STATUS\r\n");
	xil_printf("===============================================\r\n");

	for (uint32_t i = 0; i < NUM_WORDS; i++) {
		input = tx_buffer[i];
		actual = rx_buffer[i];
		expected = transform_expected(input);

		xil_printf("  %2u   | %7u | %8u | %8u | %s\r\n",
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
	xil_printf("5 - System status\r\n");
	xil_printf("==============================\r\n");
	xil_printf("Select mode (0-5): ");
}

/* =========================================================
 * CLI task
 * ========================================================= */
static void cli_task(void *arg) {
	uint32_t value;
	int c, rc;

	(void) arg;

	xil_printf("\r\nZynq-7000 | AXI DMA | FSM Control | FreeRTOS\r\n");
	fsm_set_mode(FSM_MODE_IDLE);

	for (;;) {
		print_menu();

		/* Blocked until a character arrives */
		c = console_getc(portMAX_DELAY);
		if (c < 0) {
			continue;
		}
		xil_printf("%c\r\n", c);

		switch (c) {
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
			xil_printf("Value: ");
			if (console_read_uint(&value) == INPUT_OK) {
				fsm_set_value(value);
				fsm_set_mode(FSM_MODE_VALUE);
			}
			break;

		case '4':
			/* FIFO mode before sending the data */
			fsm_set_mode(FSM_MODE_FIFO);
			vTaskDelay(ms_to_ticks(1));

			rc = run_dma_test();
			if (rc < 0) {
				xil_printf("The DMA test failed.\r\n");
			}
			break;

		case '5':
			xil_printf("Current FSM mode: %u\r\n", (unsigned int) current_mode);
			xil_printf("Heartbeat       : %u\r\n",
					(unsigned int) heartbeat_count);
			xil_printf("Free heap       : %u bytes\r\n",
					(unsigned int) xPortGetFreeHeapSize());
			break;

		case '\r':
		case '\n':
			/* Ignore end of line */
			break;

		default:
			xil_printf("Invalid command. Use 0 to 5.\r\n");
			break;
		}
	}
}

/* =========================================================
 * Heartbeat task: if the counter keeps increasing while the
 * menu waits for a key, the system is not blocked.
 * ========================================================= */
static void heartbeat_task(void *arg) {
	(void) arg;

	for (;;) {
		heartbeat_count++;
		vTaskDelay(ms_to_ticks(500));
	}
}

/* =========================================================
 * main
 * ========================================================= */
int main(void) {
	rx_stream = xQueueCreate(RX_STREAM_SIZE, sizeof(uint8_t));
	configASSERT(rx_stream != NULL);

	<???>(uart_rx_task, "uart_rx", configMINIMAL_STACK_SIZE, NULL, 3, NULL);
	xTaskCreate(cli_task, "cli", 2048, NULL, 2, NULL);
	xTaskCreate(heartbeat_task, "heartbeat", configMINIMAL_STACK_SIZE, NULL, 1, NULL);

	vTaskStartScheduler();

	/* Only reached if there is not enough heap memory for the scheduler */
	for (;;) {
	}

	return 0;
}
