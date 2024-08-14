#ifndef I2C_H
#define I2C_H

#include <stdint.h>

#define I2C_BASE_ADDR  0x20020000
#define I2C_NBY_OFFSET 0x00
#define I2C_ADR_OFFSET 0x04
#define I2C_RDR_OFFSET 0x08
#define I2C_TDR_OFFSET 0x0C
#define I2C_CFG_OFFSET 0x10

#define I2C_NBY (*(volatile uint32_t*) (I2C_BASE_ADDR + I2C_NBY_OFFSET))
#define I2C_ADR (*(volatile uint32_t*) (I2C_BASE_ADDR + I2C_ADR_OFFSET))
#define I2C_RDR (*(volatile uint32_t*) (I2C_BASE_ADDR + I2C_RDR_OFFSET))
#define I2C_TDR (*(volatile uint32_t*) (I2C_BASE_ADDR + I2C_TDR_OFFSET))
#define I2C_CFG (*(volatile uint32_t*) (I2C_BASE_ADDR + I2C_CFG_OFFSET))

#endif
