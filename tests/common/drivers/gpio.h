#ifndef GPIO_H
#define GPIO_H

#include <stdint.h>

#define GPIO_BASE_ADDR  0xFF030000
#define GPIO_IDR_OFFSET 0x00
#define GPIO_ODR_OFFSET 0x04

#define GPIO_IDR (*(volatile uint32_t*) (GPIO_BASE_ADDR + GPIO_IDR_OFFSET))
#define GPIO_ODR (*(volatile uint32_t*) (GPIO_BASE_ADDR + GPIO_ODR_OFFSET))

void gpio_set(unsigned int port, unsigned int value);
unsigned int gpio_get(unsigned int port);

#endif
