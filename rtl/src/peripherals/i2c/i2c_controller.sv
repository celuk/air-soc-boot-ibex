// i2c_controller.sv
`timescale 1ns / 1ps

`include "header.vh"

module i2c_controller (
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

    input  sda_i,
    output sda_o,
    input  scl_i, //buna bakılacak
    output scl_o
);

reg [31:0] wb_read_data_r = 0;
reg [31:0] wb_read_data_next_r = 0;
assign wb_dat_o = wb_read_data_r;

reg wb_ack_r = 0;
reg wb_ack_next_r = 0;
assign wb_ack_o = wb_ack_r;

reg [31:0] I2C_NBY;
reg [31:0] I2C_NBY_NEXT;
reg [31:0] I2C_ADR;
reg [31:0] I2C_ADR_NEXT;
reg [31:0] I2C_RDR;
reg [31:0] I2C_RDR_NEXT;
reg [31:0] I2C_TDR;
reg [31:0] I2C_TDR_NEXT;
reg [31:0] I2C_CFG;
reg [31:0] I2C_CFG_NEXT;

reg [7:0] write_data;
reg [7:0] read_data;
reg [2:0] num_read;
reg start;
reg rd_wr;

always @* begin
   wb_ack_next_r = 0;
   wb_read_data_next_r = 0;

   if (wb_cyc_i) begin
      if (wb_stb_i & wb_we_i & !wb_ack_o) begin // write
         case (wb_adr_i)
            8'h00: begin
               I2C_NBY_NEXT = wb_sel_i[0] ? wb_dat_i[7:0] : I2C_NBY;
               I2C_NBY_NEXT = wb_sel_i[1] ? wb_dat_i[15:8] : I2C_NBY;
               I2C_NBY_NEXT = wb_sel_i[2] ? wb_dat_i[23:16] : I2C_NBY;
               I2C_NBY_NEXT = wb_sel_i[3] ? wb_dat_i[31:24] : I2C_NBY;
               wb_ack_next_r = 1'b1;
            end
            8'h04: begin
               I2C_ADR_NEXT = wb_sel_i[0] ? wb_dat_i[7:0] : I2C_ADR;
               I2C_ADR_NEXT = wb_sel_i[1] ? wb_dat_i[15:8] : I2C_ADR;
               I2C_ADR_NEXT = wb_sel_i[2] ? wb_dat_i[23:16] : I2C_ADR;
               I2C_ADR_NEXT = wb_sel_i[3] ? wb_dat_i[31:24] : I2C_ADR;
               wb_ack_next_r = 1'b1;
            end
            8'h08: begin
               I2C_TDR_NEXT = wb_sel_i[0] ? wb_dat_i[7:0] : I2C_TDR;
               I2C_TDR_NEXT = wb_sel_i[1] ? wb_dat_i[15:8] : I2C_TDR;
               I2C_TDR_NEXT = wb_sel_i[2] ? wb_dat_i[23:16] : I2C_TDR;
               I2C_TDR_NEXT = wb_sel_i[3] ? wb_dat_i[31:24] : I2C_TDR;
               wb_ack_next_r = 1'b1;
            end
            8'h0C: begin
               I2C_CFG_NEXT = wb_sel_i[0] ? wb_dat_i[7:0] : I2C_CFG;
               I2C_CFG_NEXT = wb_sel_i[1] ? wb_dat_i[15:8] : I2C_CFG;
               I2C_CFG_NEXT = wb_sel_i[2] ? wb_dat_i[23:16] : I2C_CFG;
               I2C_CFG_NEXT = wb_sel_i[3] ? wb_dat_i[31:24] : I2C_CFG;
               wb_ack_next_r = 1'b1;
            end
            default: begin
               wb_ack_next_r = 0;
            end
         endcase
      end else if (~wb_we_i) begin // read
         case (wb_adr_i)
            8'h00: begin
               wb_read_data_next_r = I2C_NBY;
               wb_ack_next_r = 1;
            end
            8'h04: begin
               wb_read_data_next_r = I2C_ADR;
               wb_ack_next_r = 1;
            end
            8'h08: begin
               wb_read_data_next_r = I2C_RDR;
               wb_ack_next_r = 1;
            end
            8'h0C: begin
               wb_read_data_next_r = I2C_TDR;
               wb_ack_next_r = 1;
            end
            8'h10: begin
               wb_read_data_next_r = I2C_CFG;
               wb_ack_next_r = 1;
            end
            default: begin
               wb_ack_next_r = 0;
            end
         endcase
      end
   end
end

always @(posedge clk_i) begin
   if (rst_i) begin
      wb_ack_r <= 0;
      wb_read_data_r <= 0;
      I2C_NBY <= 0;
      I2C_ADR <= 0;
      I2C_RDR <= 0;
      I2C_TDR <= 0;
      I2C_CFG <= 0;
      write_data <= 0;
      read_data <= 0;
      num_read <= 0;
      start <= 0;
      rd_wr <= 0;
   end else begin
      wb_ack_r <= wb_ack_next_r;
      wb_read_data_r <= wb_read_data_next_r;
      I2C_NBY <= I2C_NBY_NEXT;
      I2C_ADR <= I2C_ADR_NEXT;
      I2C_TDR <= I2C_TDR_NEXT;
      I2C_CFG <= I2C_CFG_NEXT;
   end
end

always @(posedge clk_i) begin
   if (rst_i) begin
      start <= 0;
      rd_wr <= 0;
      write_data <= 0;
      num_read <= 0;
   end else begin
      if (I2C_CFG[0]) begin
         rd_wr <= I2C_CFG[1];
         write_data <= I2C_TDR[7:0];
         num_read <= I2C_NBY[2:0];
         start <= 1;
      end else begin
         start <= 0;
      end
   end
end

i2c_master i2c (
    .clk(clk_i),
    .rst(rst_i),
    .scl(scl_o),
    .sda_i(sda_i),
    .sda_o(sda_o),
    .address_w(I2C_ADR[6:0]),
    .rd_wr_w(rd_wr),
    .write_data_w(write_data),
    .num_read_w(num_read),
    .read_data_w(I2C_RDR),
    .start_w(start),
    .ready_w(),
    .read_ready_w(),
    .error_w()
);

endmodule

