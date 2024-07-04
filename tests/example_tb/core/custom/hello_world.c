/*
 * Copyright 2020 ETH Zurich
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: Robert Balas <balasr@iis.ee.ethz.ch>
 */

/*
#include <stdio.h>
#include <stdlib.h>

#include "mem_stall.h"

int main(int argc, char *argv[])
{
#ifdef RANDOM_MEM_STALL
    activate_random_stall();
#endif
    printf("hello world!\n");
    return EXIT_SUCCESS;
}
*/

#include <stdio.h>
#include <stdlib.h>

#include <stdint.h>
#include <string.h>
#include <stdarg.h>
#include <stdbool.h>


void     tekno_printf    (const char *fmt, ...);
void     print           (const char *p);
int      zscan           (char *buffer, int max_size, int echo);
char     zgetchar        ();
void     zputchar        (char c);
int      strcmp          (const char *p1, const char *p2);
size_t   strlen          (const char *s);
int 	 uart_txfull	 ();
int 	 uart_rxempty	 ();

typedef union
{
	struct {
		unsigned int tx_en    : 1;
		unsigned int rx_en 	  : 1;
		unsigned int null	  : 14;
		unsigned int baud_div : 16;
	} fields;
	uint32_t bits;
}uart_ctrl;

typedef union
{
	struct {
		unsigned int tx_full  : 1;
		unsigned int rx_full  : 1;
		unsigned int tx_empty : 1;
		unsigned int rx_empty : 1;
		unsigned int null	  : 28;
	} fields;
	uint32_t bits;
}uart_status;

#define UART_CTRL        (*(volatile uint32_t*)0x20000000)
#define UART_STATUS      (*(volatile uint32_t*)0x20000004)
#define UART_RDATA       (*(volatile uint32_t*)0x20000008)
#define UART_WDATA       (*(volatile uint32_t*)0x2000000c)

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

#define CPU_CLK 60000000
#define BAUD_RATE 115200

int main(int argc, char *argv[])
{
uart_ctrl uart_control;
	uart_control.fields.tx_en = 0x1; 
	uart_control.fields.rx_en = 0x1; 
	uart_control.fields.baud_div = CPU_CLK/BAUD_RATE; 
	UART_CTRL = uart_control.bits;
	print("hello world!\n");
    while(1);
    
}

