#include "uart.h"

int main()
{
    int a = 5;
    int b = 7;
    uart_printf("%d", a*b);

    while(1);
}
