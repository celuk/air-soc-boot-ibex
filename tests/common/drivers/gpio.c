#include "gpio.h"

void gpio_set(unsigned int port, unsigned int value) {
    unsigned int old_value = GPIO_ODR;
    unsigned int mask = ~(1 << port);
    GPIO_ODR = (old_value & mask) | (value << port);
}

unsigned int gpio_get(unsigned int port) {
    return (GPIO_IDR >> port) & 1;
}
