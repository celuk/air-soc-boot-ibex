#include "uart.h"
#include "dram.h"
#include "core_portme.h"

int main()
{
    init_uart();
    init_dram(US(500));
    unsigned int address = 0x00002FFF;
    unsigned int data = 0x1234BAEF;
 
    dram_write(address, data);

    ee_printf("data: %x\n", dram_read(0x00002FFF));

    return 0;
}
