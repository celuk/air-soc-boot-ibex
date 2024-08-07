// uart.sv
`timescale 1ns / 1ps
//
`default_nettype none

module uart_controller_obi (
   input  wire        clk_i,
   input  wire        rst_ni,
   input  wire        req_i,
   input  wire        we_i,
   input  wire [ 3:0] be_i,
   output wire        gnt_o,
   input  wire [31:0] addr_i,
   input  wire [31:0] wdata_i,
   output reg         rvalid_o,
   output reg  [31:0] rdata_o,
   input  wire        rx_i,
   output wire        tx_o
);

   reg         wb_cyc_r;
   reg         wb_stb_r;
   wire        wb_ack_w;
   wire [31:0] wb_dat_o_w;

   uart_iface uart_iface_dut (
      .clk_i    (clk_i),
      .rst_i    (~rst_ni),
      .wb_adr_i (addr_i),
      .wb_dat_i (wdata_i),
      .wb_we_i  (we_i),
      .wb_stb_i (wb_stb_r),
      .wb_sel_i (be_i),
      .wb_cyc_i (wb_cyc_r),
      .wb_ack_o (wb_ack_w),
      .wb_dat_o (wb_dat_o_w),
      .uart_rx_i(rx_i),
      .uart_tx_o(tx_o)
   );

   always @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
         wb_cyc_r <= 1'b0;
         wb_stb_r <= 1'b0;
         rvalid_o <= 1'b0;
         rdata_o  <= 32'b0;
      end else begin
         if (req_i && gnt_o) begin
            wb_cyc_r <= 1'b1;
            wb_stb_r <= 1'b1;
         end else if (wb_ack_w) begin
            wb_cyc_r <= 1'b0;
            wb_stb_r <= 1'b0;
         end

         rvalid_o <= wb_ack_w;
         if (wb_ack_w) begin
            rdata_o <= wb_dat_o_w;
         end
      end
   end

   assign gnt_o = ~wb_cyc_r;

endmodule

module uart_iface (
   input  wire        clk_i,
   input  wire        rst_i,
   input  wire [31:0] wb_adr_i,
   input  wire [31:0] wb_dat_i,
   input  wire        wb_we_i,
   input  wire        wb_stb_i,
   input  wire [ 3:0] wb_sel_i,
   input  wire        wb_cyc_i,
   output reg         wb_ack_o,
   output reg  [31:0] wb_dat_o,

   input  wire uart_rx_i,
   output wire uart_tx_o
);
   reg [15:0] baud_div;

   reg tx_en;
   reg tx_we;
   wire tx_full;
   wire tx_empty;

   reg rx_en;
   reg rx_re;
   wire rx_full;
   wire rx_empty;
   wire [7:0] rx_data;

   uart_tx uart_tx_dut (
      .clk_i     (clk_i),
      .rst_i     (rst_i),
      .baud_div_i(baud_div),
      .we_i      (tx_we),
      .stall_i   (~tx_en),
      .data_i    (wb_dat_i[7:0]),
      .full_o    (tx_full),
      .empty_o   (tx_empty),
      .tx_o      (uart_tx_o)
   );

   uart_rx uart_rx_dut (
      .clk_i     (clk_i),
      .rst_i     (rst_i),
      .baud_div_i(baud_div),
      .re_i      (rx_re),
      .stall_i   (~rx_en),
      .data_o    (rx_data),
      .full_o    (rx_full),
      .empty_o   (rx_empty),
      .rx_i      (uart_rx_i)
   );


   always @(posedge clk_i) begin
      if (rst_i) begin
         wb_ack_o <= 1'b0;
         baud_div <= 16'b0;
         rx_en    <= 1'b0;
         tx_en    <= 1'b0;
         rx_re    <= 1'b0;
         tx_we    <= 1'b0;
      end else begin
         rx_re <= 1'b0;
         tx_we <= 1'b0;
         if (wb_cyc_i) begin
            wb_ack_o <= wb_stb_i & !wb_ack_o; // butun islemler 1 cycle surer ve ack sinyali cyc'dan hemen sonra gonderilir.
            case (wb_adr_i[3:0])
               4'h0: begin
                  if (wb_stb_i & wb_we_i & !wb_ack_o) begin  // SB,SH,SW buyruklarini destekle
                     tx_en    <= wb_sel_i[0] ? wb_dat_i[0] : tx_en;
                     rx_en    <= wb_sel_i[0] ? wb_dat_i[1] : rx_en;
                     baud_div <= (&wb_sel_i[3:2]) ? wb_dat_i[31:16] : baud_div;
                  end
                  wb_dat_o <= {baud_div, 14'b0, rx_en, tx_en};
               end
               4'h4: begin
                  wb_dat_o <= {28'b0, rx_empty, rx_full, tx_empty, tx_full};
               end
               4'h8: begin
                  if (wb_stb_i & !wb_ack_o) begin
                     if (~rx_empty) begin
                        wb_dat_o <= {24'b0, rx_data};
                        rx_re <= 1'b1;
                     end
                  end
               end
               4'hc: begin
                  if (wb_stb_i & wb_we_i & !wb_ack_o) begin
                     if (~tx_full) begin
                        tx_we <= wb_sel_i[0] ? 1'b1 : 1'b0;
                     end
                  end
               end
            endcase
         end
      end
   end
endmodule
