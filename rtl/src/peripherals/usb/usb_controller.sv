// usb_cdc_controller.sv
`timescale 1ns / 1ps
`include "header.vh"

module usb_cdc_controller (
   input  wire        clk_i,
   input  wire        rst_i,
   input  wire [ 7:0] wb_adr_i,
   input  wire [31:0] wb_dat_i,
   input  wire        wb_we_i,
   input  wire        wb_stb_i,
   input  wire [ 3:0] wb_sel_i,
   input  wire        wb_cyc_i,
   output reg         wb_ack_o,
   output reg  [31:0] wb_dat_o,

   output wire dp_pu_o,
   output wire tx_en_o,
   output wire dp_tx_o,
   output wire dn_tx_o,
   input  wire dp_rx_i,
   input  wire dn_rx_i
);

   localparam VENDORID = 16'h0000;
   localparam PRODUCTID = 16'h0000;
   localparam CHANNELS = 1;
   localparam IN_BULK_MAXPACKETSIZE = 8;
   localparam OUT_BULK_MAXPACKETSIZE = 8;
   localparam BIT_SAMPLES = 4;
   localparam USE_APP_CLK = 0;
   localparam APP_CLK_FREQ = 12;

   wire [ 7:0] usb_out_data;
   wire        usb_out_valid;
   reg         usb_out_ready;
   reg  [ 7:0] usb_in_data;
   reg         usb_in_valid;
   wire        usb_in_ready;
   wire        usb_configured;
   wire [10:0] usb_frame;

   usb_cdc #(
      .VENDORID(VENDORID),
      .PRODUCTID(PRODUCTID),
      .CHANNELS(CHANNELS),
      .IN_BULK_MAXPACKETSIZE(IN_BULK_MAXPACKETSIZE),
      .OUT_BULK_MAXPACKETSIZE(OUT_BULK_MAXPACKETSIZE),
      .BIT_SAMPLES(BIT_SAMPLES),
      .USE_APP_CLK(USE_APP_CLK),
      .APP_CLK_FREQ(APP_CLK_FREQ)
   ) usb_cdc_inst (
      .clk_i(clk_i),
      .rstn_i(~rst_i),
      .app_clk_i(clk_i),
      .out_data_o(usb_out_data),
      .out_valid_o(usb_out_valid),
      .out_ready_i(usb_out_ready),
      .in_data_i(usb_in_data),
      .in_valid_i(usb_in_valid),
      .in_ready_o(usb_in_ready),
      .frame_o(usb_frame),
      .configured_o(usb_configured),
      .dp_pu_o(dp_pu_o),
      .tx_en_o(tx_en_o),
      .dp_tx_o(dp_tx_o),
      .dn_tx_o(dn_tx_o),
      .dp_rx_i(dp_rx_i),
      .dn_rx_i(dn_rx_i)
   );

   always @(posedge clk_i) begin
      if (rst_i) begin
         wb_ack_o <= 1'b0;
         usb_out_ready <= 1'b0;
         usb_in_valid <= 1'b0;
      end else begin
         usb_out_ready <= 1'b0;
         usb_in_valid  <= 1'b0;
         if (wb_cyc_i) begin
            wb_ack_o <= wb_stb_i & !wb_ack_o;
            case (wb_adr_i[3:0])
               4'h0: begin
                  wb_dat_o <= {31'b0, usb_configured};
               end
               4'h4: begin
                  wb_dat_o <= {20'b0, usb_frame, !usb_out_valid, !usb_in_ready};
               end
               4'h8: begin
                  if (wb_stb_i & !wb_ack_o) begin
                     if (usb_out_valid) begin
                        wb_dat_o <= {24'b0, usb_out_data};
                        usb_out_ready <= 1'b1;
                     end
                  end
               end
               4'hc: begin
                  if (wb_stb_i & wb_we_i & !wb_ack_o) begin
                     if (usb_in_ready) begin
                        usb_in_data  <= wb_dat_i[7:0];
                        usb_in_valid <= 1'b1;
                     end
                  end
               end
            endcase
         end
      end
   end
endmodule
