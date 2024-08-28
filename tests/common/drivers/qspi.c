#include "qspi.h"
#include "defines.h"

void qspi_set_ccr(unsigned int inst_value, unsigned int data_mod, unsigned int wr_flash, unsigned int dummy_cycle, unsigned int data_size, unsigned int prescaler, unsigned int clear_status_reg){
    qspi_ccr ccr;
    ccr.fields.inst_value = inst_value;
    ccr.fields.data_mod = data_mod;
    ccr.fields.wr_flash = wr_flash;
    ccr.fields.dummy_cycle = dummy_cycle;
    ccr.fields.data_size = data_size;
    ccr.fields.prescaler = prescaler;
    ccr.fields.clear_status_reg = clear_status_reg;
    QSPI_CCR = ccr.bits;
}

void wait_for_not_busy() {
    qspi_sta sta;
    do {
        sta.bits = QSPI_STA;
    } while (sta.fields.busy);
}

unsigned int read_status_register(unsigned int cmd) {
    qspi_ccr ccr;
    ccr.fields.inst_value = cmd;
    ccr.fields.data_mod = 1;
    ccr.fields.wr_flash = 0;
    ccr.fields.dummy_cycle = 0;
    ccr.fields.data_size = 8;
    ccr.fields.prescaler = 1;
    ccr.fields.clear_status_reg = 0;
    
    QSPI_CCR = ccr.bits;
    wait_for_not_busy();
    
    return (unsigned int)QSPI_DR0;
}

// if wel is not set wait
void wait_for_wel_set() {
    while (!(read_status_register(CMD_RDSR1) & 0x02));
}

// if write in progress wait
void wait_for_wip_done() {
    while (read_status_register(CMD_RDSR1) & 0x01);
}

