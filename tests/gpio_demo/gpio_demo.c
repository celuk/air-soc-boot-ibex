#include "gpio.h"
#include "uart.h"
#include "timer.h"

int main() {
    init_uart();

    gpio_set(1, 0);
    
    init_timer();
    wait_for_us(5);
    gpio_set(1, 1);
    wait_for_us(5);
    gpio_set(1, 0);

    tekno_printf("GPIO 0: %d\n", gpio_get(0));
    tekno_printf("GPIO 1: %d\n", gpio_get(1));

    while(1);
}
