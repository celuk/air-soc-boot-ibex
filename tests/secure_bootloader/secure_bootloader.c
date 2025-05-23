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

static const uint32_t code_ram_base_address = 0x00002000; //0x00010000;
static const uint32_t depth = 2048; //4096;
static const uint8_t word_length = 4;
static const uint32_t size = depth * word_length;

Code_ram code_ram;

#define CODE_RAM_BASE_ADDR 0x00002000 //0x00010000
#define CODE_RAM (*(volatile uint32_t*) (CODE_RAM_BASE_ADDR))

void Code_ram_init(Code_ram *self, uint32_t base_address, uint32_t size) {
    self->mem = (uint32_t *)base_address;
    self->size = size;
}

void initialize_code_ram() {
    Code_ram_init(&code_ram, code_ram_base_address, size);
}

void secure_boot()
{
    qspi_init();
    qspi_enable_quad_mode();
    uint32_t address = 0x00000000;
    uint32_t* data;
    uint32_t *key_data;

    // Phase 1: get key from root of trust
    // TODO: generate key for first time boot that would be another phase
    key_data = qspi_read_qor(address);
    if (key_data[0] == 0xFFFFFFFF) {
        return;
    }

    // Phase 2: decrypt the code by the given key
    address += (4 * 8);
    while(data[7] != 0xFFFFFFFF) {
        data = qspi_read_qor(address);

        if(data[0] == 0xFFFFFFFF) {
            break;
        }
        
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = key_data[0] ^ data[0];
        address += 4;

        if(data[1] == 0xFFFFFFFF) {
            break;
        }

        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = key_data[0] ^ data[1];
        address += 4;

        if(data[2] == 0xFFFFFFFF) {
            break;
        }
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = key_data[0] ^ data[2];
        address += 4;

        if(data[3] == 0xFFFFFFFF) {
            break;
        }
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = key_data[0] ^ data[3];
        address += 4;

        if(data[4] == 0xFFFFFFFF) {
            break;
        }
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = key_data[0] ^ data[4];
        address += 4;

        if(data[5] == 0xFFFFFFFF) {
            break;
        }
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = key_data[0] ^ data[5];
        address += 4;

        if(data[6] == 0xFFFFFFFF) {
            break;
        }
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = key_data[0] ^ data[6];
        address += 4;

        if(data[7] == 0xFFFFFFFF) {
            break;
        }
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address) = key_data[0] ^ data[7];
        address += 4;
    }
}

static inline void update_trap_vector_base_address()
{
    asm volatile (
        "li    t0, 0x2000    \n"
        "csrrw t0, mtvec,  t0 \n"
    );
}

static inline void jump_to_loaded_software()
{
    asm volatile ("j 0x2100");
}

int main()
{
    initialize_code_ram();
    secure_boot();
    update_trap_vector_base_address();
    jump_to_loaded_software();
    return 0;
}
