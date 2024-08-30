// gpio_controller.sv
`timescale 1ns / 1ps

`include "header.vh"

module gpio_controller (
    input wire clk_i,
    input wire rst_i,
    
    input  wire [ 7:0] wb_adr_i,
    input  wire [31:0] wb_dat_i,
    input  wire        wb_we_i ,
    input  wire        wb_stb_i,
    input  wire [ 3:0] wb_sel_i,
    input  wire        wb_cyc_i,
    output reg         wb_ack_o,
    output reg  [31:0] wb_dat_o,

    input  [15:0] gpio_i,
    output [15:0] gpio_o

    /*
    input io1_i,
    input io2_i,
    input io3_i,
    input io4_i,
    input io5_i,
    input io6_i,
    input io7_i,
    input io8_i,
    input io9_i,
    input io10_i,
    input io11_i,
    input io12_i,
    input io13_i,
    input io14_i,
    input io15_i,
    input io16_i,

    output io1_o,
    output io2_o,
    output io3_o,
    output io4_o,
    output io5_o,
    output io6_o,
    output io7_o,
    output io8_o,
    output io9_o,
    output io10_o,
    output io11_o,
    output io12_o,
    output io13_o,
    output io14_o,
    output io15_o,
    output io16_o
    */
);



endmodule
