#include "qspi.h"
#include "uart.h"
#include "timer.h"

int main(){
    //init_uart();

    //wait_for_us(500);
    wait_for_us(5);

    qspi_ccr ccr;
    ccr.fields.inst_value = CMD_READ;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 4;
    ccr.fields.wr_flash = 0;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    QSPI_ADR = 0x00000000;
    QSPI_CCR = ccr.bits;

    //while(!QSPI_STA);
    wait_for_us(5);

    //tekno_printf("QSPI_DR0: %x\n", QSPI_DR0);
    //wait_for(US(500));

    ccr.fields.inst_value = CMD_WREN;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 0;
    ccr.fields.wr_flash = 0;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    QSPI_CCR = ccr.bits;
    
    QSPI_ADR = 0x00000000; //0x00002000; 
    QSPI_DR0 = 0x000a0000;
    QSPI_DR1 = 0x0b000000;
    QSPI_DR2 = 0x000000c0;
    QSPI_DR3 = 0xd0000000;
    QSPI_DR4 = 0x000e0000;
    QSPI_DR5 = 0x0000f000;
    QSPI_DR6 = 0x00000000;
    QSPI_DR7 = 0x10000000;
    
    //while(!QSPI_STA);
    wait_for_us(5);

    //wait_for(US(500));

    ccr.fields.inst_value = CMD_PP;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 32;
    ccr.fields.wr_flash = 1;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    QSPI_CCR = ccr.bits;

    //while(!QSPI_STA);
    wait_for_us(5);

    //wait_for(US(500));

    ccr.fields.inst_value = CMD_RDSR1;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 1;
    ccr.fields.wr_flash = 0;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    //while(!QSPI_STA);
    wait_for_us(5);

    int value = 100;
    while((value && 0x000000ff) != 0 ) {
        QSPI_CCR = ccr.bits;
        value = QSPI_DR0;
    }

    //wait_for(US(500));

    ccr.fields.inst_value = CMD_READ;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 32;
    ccr.fields.wr_flash = 0;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    QSPI_CCR = ccr.bits;

    //while(!QSPI_STA);
    wait_for_us(5);

    //while(1);
    return 0;
}
