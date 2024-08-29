#include "qspi.h"
#include "uart.h"
#include "timer.h"

int main(){
    //init_uart();

    //wait_for_us(500);
    wait_for_us(10);

    qspi_set_ccr(
        /*inst_value*/       CMD_RESET,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();

    wait_for_us(10);

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_READ_ID,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        1,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_READ,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        31,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_DOR,
        /*data_mod*/         2,
        /*wr_flash*/         0,
        /*dummy_cycle*/      8, // if below 50mhz it can be 0
        /*data_size*/        31,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();

    qspi_set_ccr(
        /*inst_value*/       CMD_WREN,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
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
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    wait_for_wip_done();

    qspi_set_ccr(
        /*inst_value*/       CMD_WRDI,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    wait_for_wel_down();

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_QOR,
        /*data_mod*/         3,
        /*wr_flash*/         0,
        /*dummy_cycle*/      8, // if below 50mhz it can be 0
        /*data_size*/        31,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();

    qspi_set_ccr(
        /*inst_value*/       CMD_WREN,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    wait_for_wel_set();

    // 8bit CR | 8bit SR
    QSPI_DR0 = 0x00000000; // CR[1] = 0 for single and dual mode
    qspi_set_ccr(
        /*inst_value*/       CMD_WRR,
        /*data_mod*/         1,
        /*wr_flash*/         1,
        /*dummy_cycle*/      0,
        /*data_size*/        1, // SR + CR = 2 byte
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    wait_for_wip_done();

    qspi_set_ccr(
        /*inst_value*/       CMD_WRDI,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    wait_for_wel_down();

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_READ,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        31,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();

    qspi_set_ccr(
        /*inst_value*/       CMD_WREN,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    wait_for_wel_set();

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_SE,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    wait_for_wip_done();

    qspi_set_ccr(
        /*inst_value*/       CMD_WRDI,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    wait_for_wel_down();

    qspi_set_ccr(
        /*inst_value*/       CMD_WREN,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    wait_for_wel_set();

    QSPI_DR0 = 0xaaaaaaaa;
    QSPI_DR1 = 0xaaaaaaaa;
    QSPI_DR2 = 0xaaaaaaaa;
    QSPI_DR3 = 0xaaaaaaaa;
    QSPI_DR4 = 0xaaaaaaaa;
    QSPI_DR5 = 0xaaaaaaaa;
    QSPI_DR6 = 0xaaaaaaaa;
    QSPI_DR7 = 0xaaaaaaaa;

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_PP,
        /*data_mod*/         1,
        /*wr_flash*/         1,
        /*dummy_cycle*/      0,
        /*data_size*/        31,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    wait_for_wip_done();

    qspi_set_ccr(
        /*inst_value*/       CMD_WRDI,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    wait_for_wel_down();

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_READ,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        31,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();

    return 0;
}
