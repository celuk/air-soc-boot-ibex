#include "qspi.h"
#include "uart.h"
#include "timer.h"

int main(){
    //init_uart();

    //wait_for_us(500);
    wait_for_us(10);

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_READ,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        31,
        /*prescaler*/        1,
        /*clear_status_reg*/ 0
    );
    wait_for_not_busy();

    qspi_set_ccr(
        /*inst_value*/       CMD_WREN,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 0
    );
    wait_for_not_busy();
    wait_for_wel_set();

    // 8bit CR | 8bit SR
    QSPI_DR0 = 0x00000200; // CR[1] = 1 for quad mode
    qspi_set_ccr(
        /*inst_value*/       CMD_WRR,
        /*data_mod*/         1,
        /*wr_flash*/         1,
        /*dummy_cycle*/      0,
        /*data_size*/        1, // SR + CR = 2 byte
        /*prescaler*/        1,
        /*clear_status_reg*/ 0
    );
    wait_for_not_busy();
    wait_for_wip_done();

    qspi_ccr ccr;
    qspi_sta sta;

    ccr.fields.inst_value = CMD_QOR;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 31;
    ccr.fields.wr_flash = 0;
    ccr.fields.data_mod = 3;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 8; // if below 50mhz it can be 0

    QSPI_ADR = 0x00000000;
    QSPI_CCR = ccr.bits;

    while(1){
        sta.bits = QSPI_STA;
        if(!sta.fields.busy){
            break;
        }
    }


    ccr.fields.inst_value = CMD_READ;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 31;
    ccr.fields.wr_flash = 0;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    // if data_size is 31 --> 32 byte and 0 address's data will start from DR7
    QSPI_ADR = 0x00000000;
    QSPI_CCR = ccr.bits;

    while(1){
        sta.bits = QSPI_STA;
        if(!sta.fields.busy){
            break;
        }
    }

    ccr.fields.inst_value = CMD_WREN;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 0;
    ccr.fields.wr_flash = 0;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    QSPI_CCR = ccr.bits;

    while(1){
        sta.bits = QSPI_STA;
        if(!sta.fields.busy){
            break;
        }
    }

    // read sr

    /*
    ccr.fields.inst_value = CMD_RDSR1;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 0;
    ccr.fields.wr_flash = 0;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    QSPI_CCR = ccr.bits;

    while(1){
        sta.bits = QSPI_STA;
        if(!sta.fields.busy){
            break;
        }
    }
    
    while(QSPI_DR0 == 0);
    */

    QSPI_ADR = 0x00000000; //0x00002000; 
    QSPI_DR0 = 0x000a0000;
    QSPI_DR1 = 0x0b000000;
    QSPI_DR2 = 0x000000c0;
    QSPI_DR3 = 0xd0000000;
    QSPI_DR4 = 0x000e0000;
    QSPI_DR5 = 0x0000f000;
    QSPI_DR6 = 0x00000000;
    QSPI_DR7 = 0x10000000;
    

    ccr.fields.inst_value = CMD_PP;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 31;
    ccr.fields.wr_flash = 1;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    //wait_for_us(150);

    QSPI_CCR = ccr.bits;

    while(1){
        sta.bits = QSPI_STA;
        if(!sta.fields.busy){
            break;
        }
    }

    ccr.fields.inst_value = CMD_WREN;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 0;
    ccr.fields.wr_flash = 0;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    QSPI_CCR = ccr.bits;

    while(1){
        sta.bits = QSPI_STA;
        if(!sta.fields.busy){
            break;
        }
    }

    ccr.fields.inst_value = CMD_READ;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 31;
    ccr.fields.wr_flash = 0;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    QSPI_ADR = 0x00000000;
    QSPI_CCR = ccr.bits;

    while(1){
        sta.bits = QSPI_STA;
        if(!sta.fields.busy){
            break;
        }
    }

    /*
    ccr.fields.inst_value = CMD_RDSR1;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 0;
    ccr.fields.wr_flash = 0;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    QSPI_CCR = ccr.bits;

    while(1){
        sta.bits = QSPI_STA;
        if(!sta.fields.busy){
            break;
        }
    }
    */

    /*
    ccr.fields.inst_value = CMD_WRDI;
    ccr.fields.prescaler = 1;
    ccr.fields.data_size = 0;
    ccr.fields.wr_flash = 0;
    ccr.fields.data_mod = 1;
    ccr.fields.clear_status_reg = 0;
    ccr.fields.dummy_cycle = 0;

    QSPI_CCR = ccr.bits;

    while(1){
        sta.bits = QSPI_STA;
        if(!sta.fields.busy){
            break;
        }
    }
    */

    //while(1);
    return 0;
}
