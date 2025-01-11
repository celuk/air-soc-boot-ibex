// dram_controller.sv
`timescale 1ns / 1ps

`include "header.vh"

module dram_controller (
   input wire clk_i,
   input wire rst_i,

   input  wire [ 7:0] wb_adr_i,
   input  wire [31:0] wb_dat_i,
   input  wire        wb_we_i ,
   input  wire        wb_stb_i,
   input  wire [ 3:0] wb_sel_i,
   input  wire        wb_cyc_i,
   output reg         wb_ack_o,
   output reg  [31:0] wb_dat_o

   ,output ddr3_reset_n
   ,output ddr3_cke
   ,output ddr3_ck_p
   ,output ddr3_ck_n
   ,output ddr3_cs_n
   ,output ddr3_ras_n
   ,output ddr3_cas_n
   ,output ddr3_we_n
   ,output [2:0] ddr3_ba
   ,output [13:0] ddr3_addr
   ,output ddr3_odt
   ,output [1:0] ddr3_dm
   ,inout [1:0] ddr3_dqs_p
   ,inout [1:0] ddr3_dqs_n
   ,inout [15:0] ddr3_dq

   ,input clk100
   ,input clk_ddr
   ,input clk_ref
   ,input clk_ddr_dqs
);

   typedef struct packed {
      logic a10;
      logic a12;
      logic we_n;
      logic cas_n;
      logic ras_n;
      logic cs_n;
      logic cke;
      logic rst_n;
   } command_t;

   reg power_up_r = 1;
   wire reset_i = rst_i | ~power_up_r;

   reg [31:0] adr_r;
   reg [31:0] data_write_r;
   wire [31:0] data_read_w;
   command_t command_r;

   reg [31:0] timer_r;
   reg timer_rst_r;

   reg re_r = 0;
   reg we_r = 0;

   //reg re_r_next = 0;
   //reg we_r_next = 0;

   reg [31:0] trcd = 2;
   reg [31:0] nonseq = 16;
   reg [31:0] rwnonseq = 16;
   reg [31:0] trp = 2;
   reg [31:0] trfc = 26;
   reg [31:0] rwseq = 13;
   //reg [31:0] refcyc = 781; //2600; //500; //781;

   `ifdef ZC706
   wire [31:0]    ram_addr = adr_r;
   wire           ram_wr = we_r;
   wire [127:0]   ram_wr_data = {96'h0, data_write_r};
   wire           ram_rd = re_r;
   wire [127:0]  ram_rd_data;
   wire         ram_accept;
   wire         ram_ack;

   reg [15:0] ram_req_id = 0;

   assign data_read_w = ram_rd_data[31:0];

   ddr3_controller controller(
      // user ports
      .rst_i(reset_i),
      .clk(clk100),
      .clk_ddr(clk_ddr),
      .clk_ref(clk_ref),
      .clk_ddr_dqs(clk_ddr_dqs),
      .ram_addr(ram_addr),
      .wr_en(ram_wr),
      .wr_data(ram_wr_data),
      .rd_en(ram_rd),
      .rd_data(ram_rd_data),
      .accepted(ram_accept),
      .acked(ram_ack),
      // io ports
      .ddr3_reset_n(ddr3_reset_n),
      .ddr3_cke(ddr3_cke),
      .ddr3_ck_p(ddr3_ck_p),
      .ddr3_ck_n(ddr3_ck_n),
      .ddr3_ras_n(ddr3_ras_n),
      .ddr3_cas_n(ddr3_cas_n),
      .ddr3_we_n(ddr3_we_n),
      .ddr3_ba(ddr3_ba),
      .ddr3_addr(ddr3_addr),
      .ddr3_odt(ddr3_odt),
      .ddr3_dm(ddr3_dm),
      .ddr3_dqs_p(ddr3_dqs_p),
      .ddr3_dqs_n(ddr3_dqs_n),
      .ddr3_dq(ddr3_dq),
      .ddr3_cs_n(ddr3_cs_n)

      ,.ram_req_id(0)

      ,.trcd(trcd)
      ,.nonseq(nonseq)
      ,.rwnonseq(rwnonseq)
      ,.trp(trp)
      ,.trfc(trfc)
      ,.rwseq(rwseq)
   );
   `else
   wire [127:0]  ram_rd_data = 0;
   wire         ram_accept = 1;
   wire         ram_ack = 1;

   assign data_read_w = ram_rd_data[31:0];
   `endif

   `ifdef ZC706
   reg ram_accept_r = 0;
   reg ram_ack_r = 0;
   `else
   reg ram_accept_r = 1;
   reg ram_ack_r = 1;
   `endif

   always @(posedge clk_i) begin
       if (rst_i) begin
           timer_r <= 32'h0;

           `ifdef ZC706
           ram_accept_r <= 0;
           ram_ack_r <= 0;
           `else
           ram_accept_r <= 1;
           ram_ack_r <= 1;
           `endif
       end else begin
           if(timer_rst_r) begin
               timer_r <= 32'h0;
           end
           else begin
               timer_r <= timer_r + 32'h1;
           end

           if(ram_accept) ram_accept_r <= 1;
           else if(wb_cyc_i & ~wb_we_i & (wb_adr_i == 8'b00100000)) ram_accept_r <= 0; // ram_acc okudugu durumda sifirla
         
           if(ram_ack) ram_ack_r <= 1;
           else if(wb_cyc_i & ~wb_we_i & (wb_adr_i == 8'b00100100)) ram_ack_r <= 0;
         
         
         
           //re_r <= re_r_next;
           //we_r <= we_r_next;
           //if(wb_cyc_i & wb_stb_i & wb_we_i & !wb_ack_o & (wb_adr_i == 8'b00011000)) re_r_next <= 0;
           //else re_r <= re_r_next;
           //if(wb_cyc_i & wb_stb_i & wb_we_i & !wb_ack_o & (wb_adr_i == 8'b00011100)) we_r_next <= 0;
           //else we_r <= we_r_next;
       end
   end

   always @(posedge clk_i) begin
       if (rst_i) begin
           wb_ack_o <= 1'b0;

           adr_r <= 32'h0;
           data_write_r <= 32'h0;
           command_r <= 'h0;
           re_r <= 0;
           we_r <= 0;
           timer_rst_r <= 0;

           trcd <= 2;
           nonseq <= 16;
           rwnonseq <= 16;
           trp <= 2;
           trfc <= 26;
           rwseq <= 13;
           //refcyc <= 781; //2600; //500; //781;
           power_up_r <= 1;
       end
       else begin
       /*
           if(power_up_r == 0) begin
               adr_r <= 32'h0;
               data_write_r <= 32'h0;
               command_r <= 'h0;
               re_r <= 0;
               we_r <= 0;
               timer_rst_r <= 0;

               trcd <= 2;
               nonseq <= 16;
               rwnonseq <= 16;
               trp <= 2;
               trfc <= 26;
               refcyc <= 781;
           end
           */
           if(wb_cyc_i) begin
               wb_ack_o <= wb_stb_i & !wb_ack_o;

               if(wb_stb_i & wb_we_i & !wb_ack_o & wb_sel_i[0]) begin
                   case(wb_adr_i)
                       8'b00000000: begin // kodda 0x20030000 adresine yazilmali
                           command_r <= wb_dat_i;
                           //command_r <= wb_sel_i[0] ? wb_dat_i[ 7: 0] : command_r[ 7: 0];
                           //command_r <= wb_sel_i[1] ? wb_dat_i[8] : command_r[8];

                           //command_r <= wb_sel_i[2] ? wb_dat_i[23:16] : command_r[23:16];
                           //command_r <= wb_sel_i[3] ? wb_dat_i[31:24] : command_r[31:24];
                       end
                       8'b00000100: begin // kodda 0x20030004 adresine yazilmali
                           adr_r <= wb_dat_i;
                           //adr_r <= wb_sel_i[0] ? wb_dat_i[ 7: 0] : adr_r[ 7: 0];
                           //adr_r <= wb_sel_i[1] ? wb_dat_i[15: 8] : adr_r[15: 8];
                           //adr_r <= wb_sel_i[2] ? wb_dat_i[23:16] : adr_r[23:16];
                           //adr_r <= wb_sel_i[3] ? wb_dat_i[31:24] : adr_r[31:24];
                       end
                       8'b00001000: begin // kodda 0x20030008 adresine yazilmali
                           data_write_r <= wb_dat_i;
                           //data_write_r <= wb_sel_i[0] ? wb_dat_i[ 7: 0] : data_write_r[ 7: 0];
                           //data_write_r <= wb_sel_i[1] ? wb_dat_i[15: 8] : data_write_r[15: 8];
                           //data_write_r <= wb_sel_i[2] ? wb_dat_i[23:16] : data_write_r[23:16];
                           //data_write_r <= wb_sel_i[3] ? wb_dat_i[31:24] : data_write_r[31:24];
                       end
                       8'b00010000: begin // kodda 0x20030010
                           timer_rst_r <= wb_dat_i; // 1 ise resetle
                           //timer_rst_r <= wb_sel_i[0] ? wb_dat_i[0] : timer_rst_r;
                       end
                       8'b00011000: begin // kodda 0x20030018
                           re_r <= wb_dat_i;
                           //re_r <= wb_sel_i[0] ? wb_dat_i[0] : re_r;
                       end
                       8'b00011100: begin // kodda 0x2003001c
                           we_r <= wb_dat_i;
                           //we_r <= wb_sel_i[0] ? wb_dat_i[0] : we_r;
                       end
                       8'b00101000: begin // kodda 0x20030028
                           power_up_r <= wb_dat_i;
                           //power_up_r <= wb_sel_i[0] ? wb_dat_i[0] : power_up_r;
                       end
                       8'b0011000: begin // kodda 0x20030030
                           trcd <= wb_dat_i;
                       end
                       8'b00110100: begin // kodda 0x20030034
                           nonseq <= wb_dat_i;
                       end
                       8'b00111000: begin // kodda 0x20030038
                           rwnonseq <= wb_dat_i;
                       end
                       8'b00111100: begin // kodda 0x2003003c
                           trp <= wb_dat_i;
                       end
                       8'b01000000: begin // kodda 0x20030040
                           trfc <= wb_dat_i;
                       end
                       8'b01000100: begin // kodda 0x20030044
                           rwseq <= wb_dat_i;
                           //refcyc <= wb_dat_i;
                       end
                       default: begin
                     
                       end
                   endcase
               end
               else if(~wb_we_i) begin
                   case(wb_adr_i)
                       8'b00001100: begin // kodda 0x2003000c adresinden okunmali
                           wb_dat_o <= data_read_w;
                       end
                       8'b00010100: begin // kodda 0x20030014
                           wb_dat_o <= timer_r;
                       end
                       8'b00100000: begin // kodda 0x20030020
                           wb_dat_o <= ram_accept_r;
                       end
                       8'b00100100: begin // kodda 0x20030024
                           wb_dat_o <= ram_ack_r;
                       end
                       default: begin

                       end
                   endcase
               end
           end
           if(ram_accept & !(wb_stb_i & wb_we_i & !wb_ack_o & (wb_adr_i == 8'b00011000))) re_r <= 0;
           if(ram_accept & !(wb_stb_i & wb_we_i & !wb_ack_o & (wb_adr_i == 8'b00011100))) we_r <= 0;
       end
   end

endmodule
