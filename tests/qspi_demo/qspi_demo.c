#include "qspi.h"
#include "uart.h"
#include "timer.h"

int main(){
    init_uart();

    tekno_printf("basladi\n");
    tekno_printf("basladi\n");
    tekno_printf("basladi\n");

    wait_for_us(500);
    //wait_for_us(10);

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

    tekno_printf("basladi\n");
    tekno_printf("basladi\n");
    tekno_printf("basladi\n");
    wait_for_us(500);
    //wait_for_us(10);

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

    tekno_printf("READID: %x\n", QSPI_DR0);

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

    tekno_printf("READ1: %x\n", QSPI_DR0);

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_RDCR,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    tekno_printf("quad_enabled?: %x\n", QSPI_DR0);

    qspi_enable_quad_mode();

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_RDCR,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    tekno_printf("quad_enabled: %x\n", QSPI_DR0);

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

    tekno_printf("DR0: %x\n", QSPI_DR0);
    tekno_printf("DR1: %x\n", QSPI_DR1);
    tekno_printf("DR2: %x\n", QSPI_DR2);
    tekno_printf("DR3: %x\n", QSPI_DR3);
    tekno_printf("DR4: %x\n", QSPI_DR4);
    tekno_printf("DR5: %x\n", QSPI_DR5);
    tekno_printf("DR6: %x\n", QSPI_DR6);
    tekno_printf("DR7: %x\n", QSPI_DR7);

    qspi_disable_quad_mode();
    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_RDCR,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    tekno_printf("quad_disabled?: %x\n", QSPI_DR0);

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

    tekno_printf("DR0: %x\n", QSPI_DR0);
    tekno_printf("DR1: %x\n", QSPI_DR1);
    tekno_printf("DR2: %x\n", QSPI_DR2);
    tekno_printf("DR3: %x\n", QSPI_DR3);
    tekno_printf("DR4: %x\n", QSPI_DR4);
    tekno_printf("DR5: %x\n", QSPI_DR5);
    tekno_printf("DR6: %x\n", QSPI_DR6);
    tekno_printf("DR7: %x\n", QSPI_DR7);

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

    tekno_printf("DR0: %x\n", QSPI_DR0);
    tekno_printf("DR1: %x\n", QSPI_DR1);
    tekno_printf("DR2: %x\n", QSPI_DR2);
    tekno_printf("DR3: %x\n", QSPI_DR3);
    tekno_printf("DR4: %x\n", QSPI_DR4);
    tekno_printf("DR5: %x\n", QSPI_DR5);
    tekno_printf("DR6: %x\n", QSPI_DR6);
    tekno_printf("DR7: %x\n", QSPI_DR7);

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_RDCR,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    tekno_printf("quad_enabled?: %x\n", QSPI_DR0);

    qspi_enable_quad_mode();

    QSPI_ADR = 0x00000000;
    qspi_set_ccr(
        /*inst_value*/       CMD_RDCR,
        /*data_mod*/         1,
        /*wr_flash*/         0,
        /*dummy_cycle*/      0,
        /*data_size*/        0,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();
    tekno_printf("quad_enabled: %x\n", QSPI_DR0);

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
        /*dummy_cycle*/      8,
        /*data_size*/        31,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();

    QSPI_ADR = 0x00000f00;
    qspi_set_ccr(
        /*inst_value*/       CMD_QOR,
        /*data_mod*/         3,
        /*wr_flash*/         0,
        /*dummy_cycle*/      8,
        /*data_size*/        31,
        /*prescaler*/        1,
        /*clear_status_reg*/ 1
    );
    wait_for_not_busy();

    tekno_printf("DR0: %x\n", QSPI_DR0);
    tekno_printf("DR1: %x\n", QSPI_DR1);
    tekno_printf("DR2: %x\n", QSPI_DR2);
    tekno_printf("DR3: %x\n", QSPI_DR3);
    tekno_printf("DR4: %x\n", QSPI_DR4);
    tekno_printf("DR5: %x\n", QSPI_DR5);
    tekno_printf("DR6: %x\n", QSPI_DR6);
    tekno_printf("DR7: %x\n", QSPI_DR7);

    return 0;
}
