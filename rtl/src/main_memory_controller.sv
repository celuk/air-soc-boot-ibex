// main_memory_controller.sv
`timescale 1ns / 1ps

`include "header.vh"

`define DATA   1
`define INSTRUCTION 0

module main_memory_controller (
    input wire clk_i,
    input wire rst_i,
    // Main Memory <-> Main Memory Controller
    output wire        iomem_valid,
    input  wire        iomem_ready,
    output wire [ 3:0] iomem_wstrb,
    output wire [31:0] iomem_addr,
    output wire [31:0] iomem_wdata,
    input  wire [31:0] iomem_rdata,
    // Timer <-> Main Memory Controller
    input  wire        timer_iomem_valid,
    input  wire [31:0] timer_iomem_addr,
    output wire [31:0] timer_iomem_rdata,
    // L1I <-> Main Memory Controller
    input  wire        l1i_iomem_valid,
    output wire        l1i_iomem_ready,
    input  wire [18:2] l1i_iomem_addr,
    output wire [31:0] l1i_iomem_rdata,
    // L1D <-> Main Memory Controller
    input  wire        l1d_iomem_valid,
    output wire        l1d_iomem_ready,
    input  wire [ 3:0] l1d_iomem_wstrb,
    input  wire [18:2] l1d_iomem_addr,
    input  wire [31:0] l1d_iomem_wdata,
    output wire [31:0] l1d_iomem_rdata
);
    reg switch;

    assign iomem_wstrb = timer_iomem_valid ? 4'b0 : ((switch == `DATA) ? l1d_iomem_wstrb : 4'b0);

    assign iomem_wdata = l1d_iomem_wdata;

    assign iomem_valid = timer_iomem_valid ? 1'b1 : ((switch == `INSTRUCTION) ? l1i_iomem_valid : l1d_iomem_valid);

    assign iomem_addr  = timer_iomem_valid ? timer_iomem_addr : ((switch == `INSTRUCTION) ? {8'h40,5'b0,l1i_iomem_addr,2'b0}   : {8'h40,5'b0,l1d_iomem_addr,2'b0} ) ;

    assign l1i_iomem_rdata   = iomem_rdata;
    assign l1d_iomem_rdata   = iomem_rdata;
    assign timer_iomem_rdata = iomem_rdata;

    assign l1i_iomem_ready = timer_iomem_valid ? 1'b0 : ((switch == `INSTRUCTION) ? iomem_ready : 1'b0);
    assign l1d_iomem_ready = timer_iomem_valid ? 1'b0 : ((switch == `DATA)   ? iomem_ready : 1'b0);

    always @(posedge clk_i) begin
        if(rst_i) begin
            switch <= `INSTRUCTION;
        end else begin
            case({l1i_iomem_valid,l1d_iomem_valid})
                2'b00: switch <= `INSTRUCTION;
                2'b01: switch <= `DATA;
                2'b10: switch <= `INSTRUCTION;
                2'b11: switch <=  switch;
            endcase
        end
    end

endmodule
