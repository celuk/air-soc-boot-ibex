#include "uart.h"
#include "dram.h"
#include "core_portme.h"

int main()
{
    init_dram(US(500));
    unsigned int address = 0x00002FFF;
    unsigned int data = 0x1234BAEF;
 
    DRAM_ADDRESS = address;
    DRAM_DATA_WRITE = data;
    
    return 0;
}
