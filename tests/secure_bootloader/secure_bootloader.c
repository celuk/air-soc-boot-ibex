#include <stdint.h>
#include "qspi.h"
//#include "uart.h"

#define CODE_RAM_BASE_ADDR 0x00002000 //0x00010000
#define CODE_RAM (*(volatile uint32_t*) (CODE_RAM_BASE_ADDR))

void secure_boot()
{
    qspi_init();
    qspi_enable_quad_mode();
    uint32_t address = 0x00000000;
    uint32_t* data;
    uint32_t key_data[8];

    // Phase 1: get key from root of trust
    // TODO: generate key for first time boot that would be another phase
    data = qspi_read_qor(address);
    for (int i = 0; i < 8; i++) {
        key_data[i] = data[i];
    }
    if (key_data[0] == 0xFFFFFFFF) {
        return;
    }

    address += 4;

    //init_uart   ();
    //tekno_printf("key_data[0]: %x\n", key_data[0]);

    // Phase 2: decrypt the code by the given key
    //address += (4 * 8);
    while(data[7] != 0xFFFFFFFF) {
        data = qspi_read_qor(address);

        if(data[0] == 0xFFFFFFFF) {
            break;
        }
        
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address-4) = key_data[0] ^ data[0];
        address += 4;

        //tekno_printf("data[0]: %x, address: %x, key_data0: %x, dec: %x\n", data[0], address, key_data[0], key_data[0] ^ data[0]);

        if(data[1] == 0xFFFFFFFF) {
            break;
        }

        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address-4) = key_data[0] ^ data[1];
        address += 4;

        if(data[2] == 0xFFFFFFFF) {
            break;
        }
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address-4) = key_data[0] ^ data[2];
        address += 4;

        if(data[3] == 0xFFFFFFFF) {
            break;
        }
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address-4) = key_data[0] ^ data[3];
        address += 4;

        if(data[4] == 0xFFFFFFFF) {
            break;
        }
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address-4) = key_data[0] ^ data[4];
        address += 4;

        if(data[5] == 0xFFFFFFFF) {
            break;
        }
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address-4) = key_data[0] ^ data[5];
        address += 4;

        if(data[6] == 0xFFFFFFFF) {
            break;
        }
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address-4) = key_data[0] ^ data[6];
        address += 4;

        if(data[7] == 0xFFFFFFFF) {
            break;
        }
        *(volatile uint32_t*)(CODE_RAM_BASE_ADDR + address-4) = key_data[0] ^ data[7];
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
    secure_boot();
    update_trap_vector_base_address();
    jump_to_loaded_software();
    return 0;
}
