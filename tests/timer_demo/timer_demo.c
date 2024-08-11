#include "uart.h"
#include "timer.h"

int main()
{
    init_uart();
    init_timer();

    tekno_printf("%d\n", TIM_CNT);

    while(1);
}
