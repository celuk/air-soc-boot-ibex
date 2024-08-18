#include "gpio.h"
#include "uart.h"
#include "timer.h"

int main() {
    init_uart();

    // legal port numbers : 0 to 15
    // legal values : 0 or 1
    gpio_set(/*port*/ 1, /*value*/ 0);
    gpio_get(/*port*/ 1);
    
    init_timer();
    wait_for(5);
    gpio_set(1, 1);
    wait_for(5);
    gpio_set(1, 0);
    wait_for(5);
    gpio_set(1, 1);
    gpio_set(15, 1);

    tekno_printf("GPIO 0: %d\n", gpio_get(0));
    tekno_printf("GPIO 1: %d\n", gpio_get(1));

    //while(1);
    return 0;
}
