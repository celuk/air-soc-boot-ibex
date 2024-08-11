// obi2wishbone.sv
`timescale 1ns / 1ps
//
`default_nettype none

module obi2wishbone (
   input  wire        clk_i,
   input  wire        rst_ni,
   
   input  wire        req_i,
   output wire        gnt_o,
   output reg         rvalid_o,
   output reg  [31:0] rdata_o,

   output reg wb_cyc_o,
   output reg wb_stb_o,
   input wire wb_ack_i,
   input wire [31:0] wb_dat_i
);

   always @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
         wb_cyc_o <= 1'b0;
         wb_stb_o <= 1'b0;
         rvalid_o <= 1'b0;
         rdata_o  <= 32'b0;
      end else begin
         if (req_i && gnt_o) begin
            wb_cyc_o <= 1'b1;
            wb_stb_o <= 1'b1;
         end else if (wb_ack_i) begin
            wb_cyc_o <= 1'b0;
            wb_stb_o <= 1'b0;
         end

         rvalid_o <= wb_ack_i;
         if (wb_ack_i) begin
            rdata_o <= wb_dat_i;
         end
      end
   end

   assign gnt_o = ~wb_cyc_o;

endmodule
