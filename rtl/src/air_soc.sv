// air_soc.sv
`timescale 1ns / 1ps

`include "header.vh"

module air_soc (
   input wire clk_i,
   input wire rst_ni,
   
   output wire        iomem_valid,
   input  wire        iomem_ready,
   output wire [ 3:0] iomem_wstrb,
   output wire [31:0] iomem_addr,
   output wire [31:0] iomem_wdata,
   input  wire [31:0] iomem_rdata,
   
   output wire uart_tx_o,
   input  wire uart_rx_i,
   
   output wire spi_cs_o,
   output wire spi_sck_o,
   output wire spi_mosi_o,
   input  wire spi_miso_i,
   
   output wire pwm0_o,
   output wire pwm1_o

);

cv32e40p_top cv32e40p_core_ip #(
   parameter COREV_PULP = 0,
   parameter COREV_CLUSTER = 0,
   parameter FPU = 0,
   parameter FPU_ADDMUL_LAT = 0,
   parameter FPU_OTHERS_LAT = 0,
   parameter ZFINX = 0,
   parameter NUM_MHPMCOUNTERS = 1
)
(
   .clk_i (clk_i),
   .rst_ni(rst_ni)
   
);



endmodule
