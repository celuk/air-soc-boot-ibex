// uart_controller.sv
// Borrowed from https://github.com/KASIRGA-KIZIL/tekno-kizil
`timescale 1ns / 1ps

module uart_controller (
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

   input  wire uart_rx_i,
   output wire uart_tx_o
);


   reg [31:0] wb_read_data_r;
   reg [31:0] wb_read_data_next_r;
   assign wb_dat_o = wb_read_data_r;

   reg wb_ack_r;
   reg wb_ack_next_r;
   assign wb_ack_o = wb_ack_r;

   reg [31:0] UART_CPB;
   reg [31:0] UART_STP;
   reg [31:0] UART_RDR;
   reg [31:0] UART_TDR;
   reg [31:0] UART_CFG;

   reg [31:0] UART_CPB_NEXT;
   reg [31:0] UART_STP_NEXT;
   reg [31:0] UART_RDR_NEXT;
   reg [31:0] UART_TDR_NEXT;
   reg [31:0] UART_CFG_NEXT;

   wire tx_complete;
   wire rx_complete;
   wire [7:0] uart_rx_data;
   reg tx_enable;

   always @* begin
      wb_ack_next_r = 0;
      wb_read_data_next_r = 0;
      UART_CPB_NEXT = UART_CPB;
      UART_STP_NEXT = UART_STP;
      UART_RDR_NEXT = UART_RDR;
      UART_TDR_NEXT = UART_TDR;
      UART_CFG_NEXT = UART_CFG;

      if (rx_complete) begin
         UART_RDR_NEXT = uart_rx_data;
         UART_CFG_NEXT[1] = 1;
      end
      if (UART_CFG[0] == 1 && !tx_complete) begin
         tx_enable = 1;
      end
      if (tx_complete) begin
         UART_CFG_NEXT[2] = 1;
      end

      if (wb_cyc_i) begin
         wb_ack_next_r = wb_stb_i & !wb_ack_r;
         if (wb_stb_i & wb_we_i & !wb_ack_o) begin  // write
            case (wb_adr_i)
               8'h00: begin
                  UART_CPB_NEXT[7:0]   = wb_sel_i[0] ? wb_dat_i[7:0] : UART_CPB[7:0];
                  UART_CPB_NEXT[15:8]  = wb_sel_i[1] ? wb_dat_i[15:8] : UART_CPB[15:8];
                  UART_CPB_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : UART_CPB[23:16];
                  UART_CPB_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : UART_CPB[31:24];
               end
               8'h04: begin
                  UART_STP_NEXT[7:0]   = wb_sel_i[0] ? wb_dat_i[7:0] : UART_STP[7:0];
                  UART_STP_NEXT[15:8]  = wb_sel_i[1] ? wb_dat_i[15:8] : UART_STP[15:8];
                  UART_STP_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : UART_STP[23:16];
                  UART_STP_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : UART_STP[31:24];
               end

               // UART_RDR --> Read only

               8'h0C: begin
                  UART_TDR_NEXT[7:0]   = wb_sel_i[0] ? wb_dat_i[7:0] : UART_TDR[7:0];
                  UART_TDR_NEXT[15:8]  = wb_sel_i[1] ? wb_dat_i[15:8] : UART_TDR[15:8];
                  UART_TDR_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : UART_TDR[23:16];
                  UART_TDR_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : UART_TDR[31:24];
               end
               8'h10: begin
                  UART_CFG_NEXT[7:0]   = wb_sel_i[0] ? wb_dat_i[7:0] : UART_CFG[7:0];
                  UART_CFG_NEXT[15:8]  = wb_sel_i[1] ? wb_dat_i[15:8] : UART_CFG[15:8];
                  UART_CFG_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : UART_CFG[23:16];
                  UART_CFG_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : UART_CFG[31:24];
               end
            endcase
         end else if (~wb_we_i) begin  // read
            case (wb_adr_i)
               8'h00: begin
                  wb_read_data_next_r = UART_CPB;
               end
               8'h04: begin
                  wb_read_data_next_r = UART_STP;
               end
               8'h08: begin
                  wb_read_data_next_r = UART_RDR;
               end
               8'h0C: begin
                  wb_read_data_next_r = UART_TDR;
               end
               8'h10: begin
                  wb_read_data_next_r = UART_CFG;
               end
            endcase
         end
      end
   end

   always @(posedge clk_i) begin
      if (rst_i) begin
         UART_CPB <= 32'b0;
         UART_STP <= 32'b0;
         UART_RDR <= 32'b0;
         UART_TDR <= 32'b0;
         UART_CFG <= 32'b0;
         wb_ack_r <= 1'b0;
      end else begin
         UART_CPB <= UART_CPB_NEXT;
         UART_STP <= UART_STP_NEXT;
         UART_RDR <= UART_RDR_NEXT;
         UART_TDR <= UART_TDR_NEXT;
         UART_CFG <= UART_CFG_NEXT;
         wb_ack_r <= wb_ack_next_r;
      end
   end


   uart_tx uart_tx_dut (
      .clk_i     (clk_i),
      .rst_i     (rst_i),
      .baud_div_i(UART_CPB),
      .stop_bit_i(UART_STP[1:0]),
      .we_i      (tx_enable),
      .stall_i   (~UART_CFG[0]),
      .data_i    (UART_TDR[7:0]),
      .complete_o(tx_complete),
      .tx_o      (uart_tx_o)
   );

   uart_rx uart_rx_dut (
      .clk_i     (clk_i),
      .rst_i     (rst_i),
      .baud_div_i(UART_CPB),
      .stall_i   (0),
      .data_o    (uart_rx_data),
      .complete_o(rx_complete),
      .rx_i      (uart_rx_i)
   );

endmodule
