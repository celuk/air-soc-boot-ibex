// qspi_denetleyici.v
`timescale 1ps / 1ps

`define CMD_READ   'h03
`define CMD_DOR    'h3B
`define CMD_QOR    'h6B
`define CMD_PP     'h02
`define CMD_QPP    'h32
`define CMD_SE     'hD8
`define CMD_READID 'h90
`define CMD_RDID   'h9F
`define CMD_RES    'hAB
`define CMD_RDSR1  'h05
`define CMD_RDSR2  'h07
`define CMD_RDCR   'h35
`define CMD_WRR    'h01
`define CMD_WRDI   'h04
`define CMD_WREN   'h06
`define CMD_CLSR   'h30
`define CMD_RESET  'hF0

module qspi_denetleyici (
   input clk_i,
   input rst_i,

   // wishbone interface
   input  [ 7:0] wb_adr_i,
   input  [31:0] wb_dat_i,
   input         wb_we_i,
   input         wb_stb_i,
   input  [ 3:0] wb_sel_i,
   input         wb_cyc_i,
   output        wb_ack_o,
   output [31:0] wb_dat_o,

   // QSPI i/o
   input [3:0] qspi_data_i,
   output [3:0] qspi_data_o,
   output [1:0] qspi_out_mod_o,

   output qspi_cs_o,
   output qspi_sck_o
);
   
   reg wb_ack_r;
   reg wb_ack_next_r;
   assign wb_ack_o = wb_ack_r;

   reg [31:0] wb_read_data_r;
   reg [31:0] wb_read_data_next_r;
   assign wb_dat_o = wb_read_data_r;

   // CONTROL REGISTERS
   reg [31:0] QSPI_CCR;
   reg [23:0] QSPI_ADR;
   reg [31:0] QSPI_DR0;
   reg [31:0] QSPI_DR1;
   reg [31:0] QSPI_DR2;
   reg [31:0] QSPI_DR3;
   reg [31:0] QSPI_DR4;
   reg [31:0] QSPI_DR5;
   reg [31:0] QSPI_DR6;
   reg [31:0] QSPI_DR7;
   reg        QSPI_STA;

   reg [31:0] QSPI_CCR_next;
   reg [23:0] QSPI_ADR_next;
   reg [31:0] QSPI_DR0_next;
   reg [31:0] QSPI_DR1_next;
   reg [31:0] QSPI_DR2_next;
   reg [31:0] QSPI_DR3_next;
   reg [31:0] QSPI_DR4_next;
   reg [31:0] QSPI_DR5_next;
   reg [31:0] QSPI_DR6_next;
   reg [31:0] QSPI_DR7_next;
   reg        QSPI_STA_next;

   wire [7:0] QSPI_CCR_INST = QSPI_CCR[7:0];
   wire [1:0] QSPI_CCR_DATA_MOD = QSPI_CCR[9:8];
   wire QSPI_CCR_RW = QSPI_CCR[10];
   wire [4:0] QSPI_CCR_DUMMY_CYC = QSPI_CCR[15:11];
   wire [8:0] QSPI_CCR_DATA_SIZE = QSPI_CCR[24:16];
   wire [5:0] QSPI_CCR_PRESCALER = QSPI_CCR[30:25];
   wire QSPI_CCR_CLEAR_STA = QSPI_CCR[31];

   always @* begin
      wb_ack_next_r = 1'b0;
      wb_read_data_next_r = wb_read_data_r;

      QSPI_CCR_next = QSPI_CCR;
      QSPI_ADR_next = QSPI_ADR;
      QSPI_DR0_next = QSPI_DR0;
      QSPI_DR1_next = QSPI_DR1;
      QSPI_DR2_next = QSPI_DR2;
      QSPI_DR3_next = QSPI_DR3;
      QSPI_DR4_next = QSPI_DR4;
      QSPI_DR5_next = QSPI_DR5;
      QSPI_DR6_next = QSPI_DR6;
      QSPI_DR7_next = QSPI_DR7;
      QSPI_STA_next = QSPI_STA;

      if(wb_cyc_i) begin
         wb_ack_next_r <= wb_stb_i & !wb_ack_r;
         // Write to control registers
         if(wb_stb_i & wb_we_i & !wb_ack_o) begin
            case(wb_adr_i)
               8'h00: begin
                  QSPI_CCR_next[ 7: 0] = wb_sel_i[0] ? wb_dat_i[ 7: 0] : QSPI_CCR[ 7: 0];
                  QSPI_CCR_next[15: 8] = wb_sel_i[1] ? wb_dat_i[15: 8] : QSPI_CCR[15: 8];
                  QSPI_CCR_next[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : QSPI_CCR[23:16];
                  QSPI_CCR_next[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : QSPI_CCR[31:24];
               end
               8'h04: begin
                  QSPI_ADR_next[ 7: 0] = wb_sel_i[0] ? wb_dat_i[ 7: 0] : QSPI_ADR[ 7: 0];
                  QSPI_ADR_next[15: 8] = wb_sel_i[1] ? wb_dat_i[15: 8] : QSPI_ADR[15: 8];
                  QSPI_ADR_next[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : QSPI_ADR[23:16];
               end
               8'h08: begin
                  QSPI_DR0_next[ 7: 0] = wb_sel_i[0] ? wb_dat_i[ 7: 0] : QSPI_DR0[ 7: 0];
                  QSPI_DR0_next[15: 8] = wb_sel_i[1] ? wb_dat_i[15: 8] : QSPI_DR0[15: 8];
                  QSPI_DR0_next[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : QSPI_DR0[23:16];
                  QSPI_DR0_next[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : QSPI_DR0[31:24];
               end
               8'h0C: begin
                  QSPI_DR1_next[ 7: 0] = wb_sel_i[0] ? wb_dat_i[ 7: 0] : QSPI_DR1[ 7: 0];
                  QSPI_DR1_next[15: 8] = wb_sel_i[1] ? wb_dat_i[15: 8] : QSPI_DR1[15: 8];
                  QSPI_DR1_next[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : QSPI_DR1[23:16];
                  QSPI_DR1_next[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : QSPI_DR1[31:24];
               end
               8'h10: begin
                  QSPI_DR2_next[ 7: 0] = wb_sel_i[0] ? wb_dat_i[ 7: 0] : QSPI_DR2[ 7: 0];
                  QSPI_DR2_next[15: 8] = wb_sel_i[1] ? wb_dat_i[15: 8] : QSPI_DR2[15: 8];
                  QSPI_DR2_next[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : QSPI_DR2[23:16];
                  QSPI_DR2_next[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : QSPI_DR2[31:24];
               end
               8'h14: begin
                  QSPI_DR3_next[ 7: 0] = wb_sel_i[0] ? wb_dat_i[ 7: 0] : QSPI_DR3[ 7: 0];
                  QSPI_DR3_next[15: 8] = wb_sel_i[1] ? wb_dat_i[15: 8] : QSPI_DR3[15: 8];
                  QSPI_DR3_next[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : QSPI_DR3[23:16];
                  QSPI_DR3_next[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : QSPI_DR3[31:24];
               end
               8'h18: begin
                  QSPI_DR4_next[ 7: 0] = wb_sel_i[0] ? wb_dat_i[ 7: 0] : QSPI_DR4[ 7: 0];
                  QSPI_DR4_next[15: 8] = wb_sel_i[1] ? wb_dat_i[15: 8] : QSPI_DR4[15: 8];
                  QSPI_DR4_next[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : QSPI_DR4[23:16];
                  QSPI_DR4_next[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : QSPI_DR4[31:24];
               end
               8'h1C: begin
                  QSPI_DR5_next[ 7: 0] = wb_sel_i[0] ? wb_dat_i[ 7: 0] : QSPI_DR5[ 7: 0];
                  QSPI_DR5_next[15: 8] = wb_sel_i[1] ? wb_dat_i[15: 8] : QSPI_DR5[15: 8];
                  QSPI_DR5_next[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : QSPI_DR5[23:16];
                  QSPI_DR5_next[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : QSPI_DR5[31:24];
               end
               8'h20: begin
                  QSPI_DR6_next[ 7: 0] = wb_sel_i[0] ? wb_dat_i[ 7: 0] : QSPI_DR6[ 7: 0];
                  QSPI_DR6_next[15: 8] = wb_sel_i[1] ? wb_dat_i[15: 8] : QSPI_DR6[15: 8];
                  QSPI_DR6_next[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : QSPI_DR6[23:16];
                  QSPI_DR6_next[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : QSPI_DR6[31:24];
               end
               8'h24: begin
                  QSPI_DR7_next[ 7: 0] = wb_sel_i[0] ? wb_dat_i[ 7: 0] : QSPI_DR7[ 7: 0];
                  QSPI_DR7_next[15: 8] = wb_sel_i[1] ? wb_dat_i[15: 8] : QSPI_DR7[15: 8];
                  QSPI_DR7_next[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : QSPI_DR7[23:16];
                  QSPI_DR7_next[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : QSPI_DR7[31:24];
               end

               // QSPI_STA --> Read only
            endcase
         end
         // Read from control registers
         else if(~wb_we_i) begin
            case(wb_adr_i)
               8'h00: begin wb_read_data_next_r = QSPI_CCR; end
               8'h04: begin wb_read_data_next_r = {8'h0, QSPI_ADR}; end
               8'h08: begin wb_read_data_next_r = QSPI_DR0; end
               8'h0C: begin wb_read_data_next_r = QSPI_DR1; end
               8'h10: begin wb_read_data_next_r = QSPI_DR2; end
               8'h14: begin wb_read_data_next_r = QSPI_DR3; end
               8'h18: begin wb_read_data_next_r = QSPI_DR4; end
               8'h1C: begin wb_read_data_next_r = QSPI_DR5; end
               8'h20: begin wb_read_data_next_r = QSPI_DR6; end
               8'h24: begin wb_read_data_next_r = QSPI_DR7; end
               8'h28: begin wb_read_data_next_r = {31'h0, QSPI_STA}; end
            endcase
         end
      end
   end

   always @(posedge clk_i) begin
      if(rst_i) begin
         wb_ack_r <= 1'b0;
         wb_read_data_r <= 32'h0;

         QSPI_CCR <= 0;
         QSPI_ADR <= 0;
         QSPI_DR0 <= 0;
         QSPI_DR1 <= 0;
         QSPI_DR2 <= 0;
         QSPI_DR3 <= 0;
         QSPI_DR4 <= 0;
         QSPI_DR5 <= 0;
         QSPI_DR6 <= 0;
         QSPI_DR7 <= 0;
         QSPI_STA <= 0;
      end
      else begin
         wb_ack_r <= wb_ack_next_r;
         wb_read_data_r <= wb_read_data_next_r;

         QSPI_CCR <= QSPI_CCR_next;
         QSPI_ADR <= QSPI_ADR_next;
         QSPI_DR0 <= QSPI_DR0_next;
         QSPI_DR1 <= QSPI_DR1_next;
         QSPI_DR2 <= QSPI_DR2_next;
         QSPI_DR3 <= QSPI_DR3_next;
         QSPI_DR4 <= QSPI_DR4_next;
         QSPI_DR5 <= QSPI_DR5_next;
         QSPI_DR6 <= QSPI_DR6_next;
         QSPI_DR7 <= QSPI_DR7_next;
         QSPI_STA <= QSPI_STA_next;
      end
   end

endmodule
