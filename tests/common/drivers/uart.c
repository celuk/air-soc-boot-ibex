#include "uart.h"
#include "defines.h"
//-----------------------------------------------
// print a single character.
//-----------------------------------------------
int uart_txfull(){
	uart_status uart_stat;
	uart_stat.bits = UART_STATUS;
	return uart_stat.fields.tx_full;
}

void zputchar(char c)
{
	while(uart_txfull());
	UART_WDATA = c;
}

//-----------------------------------------------
// print a string (char*).
//-----------------------------------------------

void print(const char *p)
{
	while (*p)
		zputchar(*(p++));
}

void init_uart(){
    uart_ctrl uart_control;
    uart_control.fields.tx_en = 0x1;
    uart_control.fields.rx_en = 0x1;
    uart_control.fields.baud_div = CPU_CLK / BAUD_RATE;
    UART_CTRL = uart_control.bits;
}
