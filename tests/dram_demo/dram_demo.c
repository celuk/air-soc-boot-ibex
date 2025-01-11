#include "uart.h"
#include "dram.h"

int main()
{
    init_uart();
    init_dram();

    unsigned int address = 0x00002FFF;
    unsigned int data = 0x1234BAEF;
    dram_write(address, data);
    dram_write(0x00001FFF, 0x1234BEEF);
    dram_read(address);

    dram_write(0x00001FFF, 0xab1cd2ef);
    dram_write(0x0000100F, 0xed2f3abd);

    tekno_printf("data: %x\n", dram_read(0x00001FFF));
    tekno_printf("data: %x\n", dram_read(0x0000100F));
    tekno_printf("data: %x\n", dram_read(address));
    
    return 0;
}
