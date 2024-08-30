`timescale 1ns / 1ps
`define FILTER_LEN  4
`define WB_DATA_WIDTH  32                  // width of data bus in bits (8, 16, 32, or 64)
`define WB_ADDR_WIDTH  32                  // width of address bus in bits
`define WB_SELECT_WIDTH  (`WB_DATA_WIDTH/8)

module tb_i2c_master_slave;

    reg clk_i;
    reg rst_i;



    //master signals
 
    reg                   scl_i;           // TODO: scl reg, multi master için kullanılabilir 
    wire                  scl_o;
    reg                   sda_i;           // sda reg
    wire                  sda_o;           // sda wire
    reg       [6:0]       address_i;
    reg                   rd_wr_i;
    reg       [31:0]      write_data_i;
    reg       [2:0]       num_bytes_i;
    wire      [31:0]      read_data_o;
    reg                   start_i;
    wire                  start_aldim_o;  
    wire                  ready_o;
    wire                  read_finished_o;
    wire                  write_finished_o;
    wire                  error_o;
    reg                   sda_drive_o;

    //slave signals

    reg                         i2c_scl_i;
    wire                        i2c_scl_o;
    wire                        i2c_scl_t;
    reg                         i2c_sda_i;
    wire                        i2c_sda_o;
    wire                        i2c_sda_t;
    wire  [`WB_ADDR_WIDTH-1:0]   wb_adr_o;   // ADR_O() address
    reg   [`WB_DATA_WIDTH-1:0]   wb_dat_i;   // DAT_I() data in
    wire  [`WB_DATA_WIDTH-1:0]   wb_dat_o;   // DAT_O() data out
    wire                        wb_we_o;    // WE_O write enable wire
    wire  [`WB_SELECT_WIDTH-1:0] wb_sel_o;   // SEL_O() select wire
    wire                        wb_stb_o;   // STB_O strobe wire
    reg                         wb_ack_i;   // ACK_I acknowledge reg
    reg                         wb_err_i;   // ERR_I error reg
    wire                        wb_cyc_o;   // CYC_O cycle wire
    wire                        busy;
    wire                        bus_addressed;
    wire                        bus_active;
    reg                         enable = 1;
    reg   [6:0]                 device_address;


    /*
    sda = sda_drive ? mastersdao : slavesdao;
    masslavesdai = sda;
    sda_drşve == slavesda_t  bastır gör aynılar mı diye

    scl = masterscl && slavescl_t;
    masslcainscl = scl;
    */
    wire sda = sda_o && i2c_sda_o;
    wire scl = scl_o && i2c_scl_o; // emin değilim
    
    i2c_master master(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .scl_i(scl),           // TODO: scl reg, multi master için kullanılabilir 
        .scl_o(scl_o),
        .sda_i(sda),           // sda reg
        .sda_o(sda_o),           // sda wire
        .address_i(address_i),
        .rd_wr_i(rd_wr_i),
        .write_data_i(write_data_i),
        .num_bytes_i(num_bytes_i),
        .read_data_o(read_data_o),
        .start_i(start_i),
        .start_aldim_o(start_aldim_o),  
        .ready_o(ready_o),
        .read_finished_o(read_finished_o),
        .write_finished_o(write_finished_o),
        .error_o(error_o),
        .sda_drive_o(sda_drive_o)
    );

    i2c_slave_wbm #(
        .FILTER_LEN(4),
        .WB_DATA_WIDTH(32),
        .WB_ADDR_WIDTH(32),
        .WB_SELECT_WIDTH(4)
    ) slave(
        .clk(clk_i),
        .rst(rst_i),
        .i2c_scl_i(scl),
        .i2c_scl_o(i2c_scl_o),
        .i2c_scl_t(i2c_scl_t),
        .i2c_sda_i(sda),
        .i2c_sda_o(i2c_sda_o),
        .i2c_sda_t(i2c_sda_t),
        .wb_adr_o(wb_adr_o),
        .wb_dat_i(wb_dat_i),
        .wb_dat_o(wb_dat_o),
        .wb_we_o(wb_we_o),
        .wb_sel_o(wb_sel_o),
        .wb_stb_o(wb_stb_o),
        .wb_ack_i(wb_ack_i),
        .wb_err_i(wb_err_i),
        .wb_cyc_o(wb_cyc_o),
        .busy(busy),
        .bus_addressed(bus_addressed),
        .bus_active(bus_active),
        .enable(enable),
        .device_address(7'b1111111)
    );

    always begin
        clk_i = 1'b1;
        #5;
        clk_i = 1'b0;
        #5;
    end

    initial begin
          // Reset the system
    rst_i = 1'b1;
    #10;
    rst_i = 1'b0;

    // Başlangıçta bütün sinyalleri temizle
    scl_i = 1'b1;
    sda_i = 1'b1;
    start_i = 1'b0;
    rd_wr_i = 1'b0; // Yazma işlemi
    write_data_i = 32'b10101111000010101010111100001010; // Yazmak istediğimiz veri
    address_i = 7'b1111111; // Slave cihazının adresi
    num_bytes_i = 3'b100; // 4 byte (32 bit)

    // Master'dan slave'e veri yazma işlemi başlatılır
    #20;
    start_i = 1'b1;
    #10;
    start_i = 1'b0;

    // İşlem bitene kadar bekle
    wait (write_finished_o);
    #10;

    // Veriyi kontrol et
    if (slave.wb_dat_o == 32'b10101111000010101010111100001010) begin
        $display("Test Başarılı: Veri slave'e doğru şekilde yazıldı.");
    end else begin
        $display("Test Başarısız: Veri slave'e doğru yazılmadı.");
    end

    $stop;
    end
 



  

endmodule
