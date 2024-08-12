#include "uart.h"
#include "timer.h"

int main()
{
    init_uart();
    //init_timer();

    timer_set_pre(0);
    timer_set_are(55);
    timer_set_clr(0);
    timer_set_ena(1);
    timer_set_mod(1);
    timer_set_evc(0);
    
    tekno_printf("%d\n", timer_get_cnt());

    while(1);
}
