// datapath.sv
`timescale 1ns / 1ps

`include "header.vh"

module datapath(
   input clk_i,
   input rst_i,
   
   // DP --- WB
   input  [31:0] dp_addr_i,
   input  [31:0] dp_data_i,
   input  [ 3:0] dp_data_mask_i,
   input         dp_sel_i,
   output [31:0] dp_data_o,
   output        dp_stall_o,
   
   output uart_tx_o,
   input  uart_rx_i,
   
   output       qspi_cs_o,
   output       qspi_sck_o,
   output [3:0] qspi_mosi_o,
   input  [3:0] qspi_miso_i,

   input  sda_i,
   output sda_o,
   input  scl_i,
   output scl_o,
   
   input  [15:0] gpio_i,
   output [15:0] gpio_o
);

   wire [ 7:0] wb_adr;
   wire [31:0] wb_dat;
   wire        wb_we ;
   wire        wb_stb;
   wire [ 3:0] wb_sel;
   
   wire        uart_cyc;
   wire        uart_ack;
   wire [31:0] uart_dat;
   
   wire        qspi_cyc;
   wire        qspi_ack;
   wire [31:0] qspi_dat;
   
   wire        i2c_cyc;
   wire        i2c_ack;
   wire [31:0] i2c_dat;

   wire        gpio_cyc_o;
   wire        gpio_ack_i;
   wire [31:0] gpio_dat_i;

   wire        usb_cyc_o;
   wire        usb_ack_i;
   wire [31:0] usb_dat_i;

   wire        timer_cyc_o;
   wire        timer_ack_i;
   wire [31:0] timer_dat_i;

   wire        jtag_cyc_o;
   wire        jtag_ack_i;
   wire [31:0] jtag_dat_i;

   wishbone_master wm(
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .dp_addr_i      (dp_addr_i),
      .dp_data_i      (dp_data_i),
      .dp_data_mask_i (dp_data_mask_i),
      .dp_sel_i       (dp_sel_i),
      .dp_data_o      (dp_data_o),
      .dp_stall_o     (dp_stall_o),
      
      .adr_o (wb_adr),
      .dat_o (wb_dat),
      .we_o  (wb_we ),
      .stb_o (wb_stb),
      .sel_o (wb_sel),
      
      .uart_cyc_o (uart_cyc),
      .uart_ack_i (uart_ack),
      .uart_dat_i (uart_dat),
      
      .qspi_cyc_o (qspi_cyc),
      .qspi_ack_i (qspi_ack),
      .qspi_dat_i (qspi_dat),
      
      .i2c_cyc_o (i2c_cyc),
      .i2c_ack_i (i2c_ack),
      .i2c_dat_i (i2c_dat),

      .gpio_cyc_o  (gpio_cyc_o),
      .gpio_ack_i  (gpio_ack_i),
      .gpio_dat_i  (gpio_dat_i),

      .usb_cyc_o   (usb_cyc_o),
      .usb_ack_i   (usb_ack_i),
      .usb_dat_i   (usb_dat_i),
      
      .timer_cyc_o (timer_cyc_o),
      .timer_ack_i (timer_ack_i),
      .timer_dat_i (timer_dat_i),

      .jtag_cyc_o  (jtag_cyc_o),
      .jtag_ack_i  (jtag_ack_i),
      .jtag_dat_i  (jtag_dat_i)
   );
   
   uart_controller uart_controller_dut (
      .clk_i(clk_i),
      .rst_i(rst_i),

      .wb_adr_i (wb_adr[3:2]),
      .wb_dat_i (wb_dat     ),
      .wb_we_i  (wb_we      ),
      .wb_stb_i (wb_stb     ),
      .wb_sel_i (wb_sel     ),
      .wb_cyc_i (uart_cyc   ),
      .wb_ack_o (uart_ack   ),
      .wb_dat_o (uart_dat   ),
      
      .uart_rx_i  (uart_rx_i ),
      .uart_tx_o  (uart_tx_o )
   );
   
   /*
   qspi_controller qspi_controller_dut (
      .clk_i(clk_i),
      .rst_i(rst_i),

      .wb_adr_i (wb_adr[4:0]),
      .wb_dat_i (wb_dat     ),
      .wb_we_i  (wb_we      ),
      .wb_stb_i (wb_stb     ),
      .wb_sel_i (wb_sel     ),
      .wb_cyc_i (qspi_cyc   ),
      .wb_ack_o (qspi_ack   ),
      .wb_dat_o (qspi_dat   ),
      
      .qspi_miso_i(qspi_miso_i),
      .qspi_mosi_o(qspi_mosi_o),
      .qspi_cs_o(qspi_cs_o),
      .qspi_sck_o(qspi_sck_o)
   );

   i2c_controller i2c_controller_dut (
      .clk_i(clk_i),
      .rst_i(rst_i),

      .wb_adr_i (wb_adr ),
      .wb_dat_i (wb_dat ),
      .wb_we_i  (wb_we  ),
      .wb_stb_i (wb_stb ),
      .wb_sel_i (wb_sel ),
      .wb_cyc_i (i2c_cyc),
      .wb_ack_o (i2c_ack),
      .wb_dat_o (i2c_dat),
      
      .sda_i(sda_i),
      .sda_o(sda_o),
      .scl_i(scl_i),
      .scl_o(scl_o)
   );

   gpio_controller gpio_controller_dut (
       .clk_i(clk_i),
       .rst_i(rst_i),
   
       .wb_adr_i (wb_adr    ),
       .wb_dat_i (wb_dat    ),
       .wb_we_i  (wb_we     ),
       .wb_stb_i (wb_stb    ),
       .wb_sel_i (wb_sel    ),
       .wb_cyc_i (gpio_cyc_o),
       .wb_ack_o (gpio_ack_i),
       .wb_dat_o (gpio_dat_i),
   
       .gpio_i(gpio_i),
       .gpio_o(gpio_o)
   );
   
   usb_controller usb_controller_dut (
       .clk_i(clk_i),
       .rst_i(rst_i),
   
       .wb_adr_i (wb_adr   ),
       .wb_dat_i (wb_dat   ),
       .wb_we_i  (wb_we    ),
       .wb_stb_i (wb_stb   ),
       .wb_sel_i (wb_sel   ),
       .wb_cyc_i (usb_cyc_o),
       .wb_ack_o (usb_ack_i),
       .wb_dat_o (usb_dat_i)

   );
   
   timer_controller timer_controller_dut (
       .clk_i(clk_i),
       .rst_i(rst_i),
   
       .wb_adr_i (wb_adr     ),
       .wb_dat_i (wb_dat     ),
       .wb_we_i  (wb_we      ),
       .wb_stb_i (wb_stb     ),
       .wb_sel_i (wb_sel     ),
       .wb_cyc_i (timer_cyc_o),
       .wb_ack_o (timer_ack_i),
       .wb_dat_o (timer_dat_i)
   );
   
   jtag_controller jtag_controller_dut (
       .clk_i(clk_i),
       .rst_i(rst_i),
   
       .wb_adr_i (wb_adr    ),
       .wb_dat_i (wb_dat    ),
       .wb_we_i  (wb_we     ),
       .wb_stb_i (wb_stb    ),
       .wb_sel_i (wb_sel    ),
       .wb_cyc_i (jtag_cyc_o),
       .wb_ack_o (jtag_ack_i),
       .wb_dat_o (jtag_dat_i)
   );*/

endmodule
