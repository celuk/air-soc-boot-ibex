#include "uart.h"

static volatile long* raw_data0 = (volatile long*)0x00020000;
static volatile long* raw_data1 = (volatile long*)0x00020004;
static volatile long* raw_data2 = (volatile long*)0x00020008;
static volatile long* raw_data3 = (volatile long*)0x0002000C;

int main()
{
    volatile long x = 0;
    while (1) {
        x = x + 1;
        if (x == 100) {
            break;
        }
    }
    (*raw_data0) = (volatile long)5;
    (*raw_data1) = (volatile long)6;
    (*raw_data2) = (volatile long)7;
    (*raw_data3) = (volatile long)x;

    int a = 5;
    int b = 7;
    uart_printf("%d", a * b);

    while (1)
        ;
}
