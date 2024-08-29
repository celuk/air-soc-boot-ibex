// inspired and borrowed some parts from: https://github.com/agh-riscv/pixel_riscv_soc/tree/master/sw/bootloader

#include <stdint.h>
#include "qspi.h"

typedef struct {
    uint32_t *mem;
    uint32_t size;
} Code_ram;

/*
union Code_ram_word {
    uint8_t bytes[4];
    uint32_t word;
};
*/

static const uint32_t code_ram_base_address = 0x00010000;
static const uint32_t depth = 4096;
static const uint8_t word_length = 4;
static const uint32_t size = depth * word_length;

Code_ram code_ram;

#define CODE_RAM_BASE_ADDR
#define CODE_RAM (*(volatile uint32_t*) (CODE_RAM_BASE_ADDR))

void Code_ram_init(Code_ram *self, uint32_t base_address, uint32_t size) {
    self->mem = (uint32_t *)base_address;
    self->size = size;
}

uint32_t *Code_ram_set(Code_ram *self, uint32_t address) {
    return &(self->mem[address >> 2]);
}

uint32_t Code_ram_get_size(Code_ram *self) {
    return self->size;
}

void initialize_code_ram() {
    Code_ram_init(&code_ram, code_ram_base_address, size);
}

void load_code_through_qspi()
{
    qspi_init();
    qspi_enable_quad();
    uint32_t address = 0x00000000;
    uint32_t* data; //= qspi_read_qor(address);
    for (uint32_t i = 0; i < Code_ram_get_size(&code_ram); i += 32) {
        data = qspi_read_qor(address);
        //*Code_ram_set(&code_ram, address) = data[0];
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = data[0];
        address += 4;
        //*Code_ram_set(&code_ram, address) = data[1];
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = data[1];
        address += 4;
        //*Code_ram_set(&code_ram, address) = data[2];
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = data[0];
        address += 4;
        //*Code_ram_set(&code_ram, address) = data[3];
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = data[0];
        address += 4;
        //*Code_ram_set(&code_ram, address) = data[4];
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = data[0];
        address += 4;
        //*Code_ram_set(&code_ram, address) = data[5];
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = data[0];
        address += 4;
        //*Code_ram_set(&code_ram, address) = data[6];
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = data[0];
        address += 4;
        //*Code_ram_set(&code_ram, address) = data[7];
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = data[0];
        address += 4;
    }
}

static inline void update_trap_vector_base_address()
{
    asm volatile (
        "li    t0, 0x10000    \n"
        "csrrw t0, mtvec,  t0 \n"
    );
}

static inline void jump_to_loaded_software()
{
    asm ("j 0x10100");
}

int main()
{
    initialize_code_ram();
    load_code_through_qspi();
    update_trap_vector_base_address();
    jump_to_loaded_software();
    return 0;
}



