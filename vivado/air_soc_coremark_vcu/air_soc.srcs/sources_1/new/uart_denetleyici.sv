`timescale 1ns/1ps

`include "sabitler.vh"

module fifo2 #(
   parameter DATA_WIDTH = 32,
   parameter DATA_DEPTH = 8
)(
   input                       clk_i,
   input                       rstn_i,

   input   [DATA_WIDTH-1:0]    data_i,
   input                       wr_en_i,

   output  [DATA_WIDTH-1:0]    data_o,
   input                       rd_en_i,
   
   output                      full_o,
   output                      empty_o
);

reg [DATA_WIDTH-1:0] buf_r [0:DATA_DEPTH-1];
reg [DATA_WIDTH-1:0] buf_ns [0:DATA_DEPTH-1];

reg full_r;
reg full_ns;

reg [$clog2(DATA_DEPTH)-1:0] ptr_rd_r;
reg [$clog2(DATA_DEPTH)-1:0] ptr_rd_ns;
reg [$clog2(DATA_DEPTH)-1:0] ptr_wr_r;
reg [$clog2(DATA_DEPTH)-1:0] ptr_wr_ns;

integer i;
always @* begin
   for (i = 0; i < DATA_DEPTH; i = i + 1) begin
      buf_ns[i] = buf_r[i];
   end
   ptr_rd_ns = ptr_rd_r;
   ptr_wr_ns = ptr_wr_r;
   full_ns = full_r;

   if (rd_en_i && !empty_o) begin
      ptr_rd_ns = (ptr_rd_r + 1) % DATA_DEPTH;
      full_ns = `LOW;
   end

   if (wr_en_i && !full_o) begin
      buf_ns[ptr_wr_r] = data_i;
      ptr_wr_ns = (ptr_wr_r + 1) % DATA_DEPTH;
      full_ns = !rd_en_i && ((ptr_wr_r + 1) % DATA_DEPTH) == ptr_rd_r;
   end
end

always @(posedge clk_i) begin
   if (!rstn_i) begin
      ptr_rd_r <= 0;
      ptr_wr_r <= 0;
      full_r <= 0;
   end
   else begin
      for (i = 0; i < DATA_DEPTH; i = i + 1) begin
         buf_r[i] <= buf_ns[i];
      end
      ptr_rd_r <= ptr_rd_ns;
      ptr_wr_r <= ptr_wr_ns;
      full_r <= full_ns;
   end
end

assign data_o = buf_r[ptr_rd_r];
assign full_o = full_r;
assign empty_o = (ptr_rd_r == ptr_wr_r) && !full_r;

endmodule

module uart_denetleyicisi (
   input                       clk_i,
   input                       rstn_i,

   input   [`ADRES_BIT-1:0]    cek_adres_i,
   input   [`VERI_BIT-1:0]     cek_veri_i,
   input   [`TL_A_BITS-1:0]    cek_tilefields_i,

   input                       cek_gecerli_i,
   output                      cek_hazir_o,

   output  [`VERI_BIT-1:0]     uart_veri_o,
   output                      uart_gecerli_o,
   output  [`TL_D_BITS-1:0]    uart_tilefields_o,
   input                       uart_hazir_i,

   input                       rx_i,
   output                      tx_o
);

wire        cek_uart_istek_w;
wire [3:0]  cek_uart_addr_w;
wire        cek_uart_yaz_w;
wire        cek_uart_oku_w;

assign cek_uart_istek_w = ((cek_adres_i & ~`UART_MASK_ADDR) == `UART_BASE_ADDR) && cek_gecerli_i;
assign cek_uart_addr_w = cek_adres_i & `UART_MASK_ADDR;
assign cek_uart_yaz_w = cek_tilefields_i[`TL_A_OP] == `TL_OP_PUT_FULL || cek_tilefields_i[`TL_A_OP] == `TL_OP_PUT_PART;
assign cek_uart_oku_w = cek_tilefields_i[`TL_A_OP] == `TL_OP_GET;

reg [31:0] uart_ctrl_r;
reg [31:0] uart_ctrl_ns;
wire tx_en_w;
wire rx_en_w;
wire [15:0] baud_div;

wire [3:0] uart_status_w;
reg [7:0] uart_rdata;
reg [7:0] uart_wdata;

reg [1:0] durum_r;
reg [1:0] durum_ns;

reg [`TL_D_BITS-1:0] uart_tilefields_r;
reg [`TL_D_BITS-1:0] uart_tilefields_ns;
reg [`VERI_BIT-1:0] uart_veri_r;
reg [`VERI_BIT-1:0] uart_veri_ns;
reg uart_gecerli_r;
reg uart_gecerli_ns;
reg [`VERI_BIT-1:0] fifo_buf_veri_r;
reg [`VERI_BIT-1:0] fifo_buf_veri_ns;

localparam BOSTA = 0;
localparam VERI_BEKLE = 1;
localparam YER_BEKLE = 2;

// ------------ FIFO TX BUFFER I/O-----------------//
reg  [7:0] tx_fifo_wr_data_cmb;
reg        tx_fifo_wr_en_cmb;
wire [7:0] tx_fifo_rd_data_w;
reg        tx_fifo_rd_en_cmb;
wire       tx_fifo_full_w;
wire       tx_fifo_empty;
wire       consume_w;
// ------------ FIFO RX BUFFER I/O-----------------//
reg  [7:0] rx_fifo_wr_data_cmb;
reg        rx_fifo_wr_en_cmb;
wire [7:0] rx_fifo_rd_data_w;
reg        rx_fifo_rd_en_cmb;
wire       rx_fifo_full_w;
wire       rx_fifo_empty;
// ------------ UART ALICI I/O --------------------//
wire [7:0]            alici_alinan_veri_w;
reg                   alici_rx_cmb;
wire                  alici_hazir_w;
wire                  alici_alinan_gecerli_w;
// ------------ UART VERICI I/O -------------------//
reg                   verici_basla_cmb;
reg                   verici_gelen_veri_gecerli_cmb;  
reg [7:0]             verici_gelen_veri_cmb;
wire                  verici_tx_w;
wire                  verici_hazir_w;

always @* begin
   uart_tilefields_ns = uart_tilefields_r;
   uart_tilefields_ns[`TL_D_SIZE] = 5;
   durum_ns = durum_r;
   uart_ctrl_ns = uart_ctrl_r;
   uart_veri_ns = uart_veri_r;
   uart_gecerli_ns = uart_gecerli_r;
   fifo_buf_veri_ns = fifo_buf_veri_r;
   tx_fifo_wr_data_cmb = 8'd0;
   tx_fifo_wr_en_cmb = `LOW;
   tx_fifo_rd_en_cmb = `LOW;
   rx_fifo_wr_data_cmb = 8'd0;
   rx_fifo_wr_en_cmb = `LOW;
   rx_fifo_rd_en_cmb = `LOW;
   uart_rdata = 0;
   uart_wdata = 0;

   alici_rx_cmb = `HIGH; // baslarken low'a çek
   verici_basla_cmb = `LOW;
   verici_gelen_veri_gecerli_cmb = `LOW;
   verici_gelen_veri_cmb = 8'd0;

   if ((uart_gecerli_o && uart_hazir_i) || uart_tilefields_o[`TL_D_OP] == `TL_OP_ACK) begin
      uart_gecerli_ns = `LOW;
   end

   case (durum_r)
      BOSTA: begin
         if (cek_uart_istek_w) begin
            case (cek_uart_addr_w) 
               `UART_CTRL_REG: begin
                  if (cek_uart_oku_w) begin
                     uart_veri_ns = uart_ctrl_r;
                     uart_gecerli_ns = `HIGH;
                     uart_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                  end
                  else if (cek_uart_yaz_w) begin
                     uart_ctrl_ns = cek_veri_i;
                     uart_gecerli_ns = `HIGH;
                     uart_tilefields_ns[`TL_D_OP] = `TL_OP_ACK;
                  end
               end
               `UART_STATUS_REG: begin
                  if (cek_uart_oku_w) begin
                  `ifndef SPIKE_DIFF
                     uart_veri_ns = uart_status_w;
                  `else
                     uart_veri_ns = 32'd0;
                  `endif
                     uart_gecerli_ns = `HIGH;
                     uart_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                  end
               end
               `UART_RDATA_REG: begin
                  if (cek_uart_oku_w) begin
                     if (rx_fifo_empty) begin
                        durum_ns = VERI_BEKLE;
                     end
                     else begin
                        uart_veri_ns = rx_fifo_rd_data_w;
                        rx_fifo_rd_en_cmb = `HIGH;
                        uart_gecerli_ns = `HIGH;
                        uart_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                     end
                  end
               end
               `UART_WDATA_REG: begin
                   if (cek_uart_yaz_w) begin
                     uart_tilefields_ns[`TL_D_OP] = `TL_OP_ACK;
                     uart_gecerli_ns = `HIGH;
                     if (tx_fifo_full_w) begin
                        fifo_buf_veri_ns = cek_veri_i;
                        durum_ns = YER_BEKLE;
                     end
                     else begin
                        tx_fifo_wr_data_cmb = cek_veri_i;
                        tx_fifo_wr_en_cmb = `HIGH;
                     end
                  end
               end
            endcase
         end    
      end
      VERI_BEKLE: begin
          if (!rx_fifo_empty) begin
            uart_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
            uart_veri_ns = rx_fifo_rd_data_w;
            rx_fifo_rd_en_cmb = `HIGH;
            uart_gecerli_ns = `HIGH;
            durum_ns = BOSTA;
         end
      end
      YER_BEKLE: begin
         if (!tx_fifo_full_w) begin
            tx_fifo_wr_data_cmb = fifo_buf_veri_r;
            tx_fifo_wr_en_cmb = `HIGH;
            durum_ns = BOSTA;
         end
      end
   endcase

   if (alici_alinan_gecerli_w && rx_en_w) begin
      rx_fifo_wr_data_cmb = alici_alinan_veri_w;
      rx_fifo_wr_en_cmb = `HIGH;
   end
end

always @ (posedge clk_i) begin
   if (!rstn_i) begin
      durum_r <= BOSTA;
      uart_ctrl_r <= 0;
      uart_veri_r <= 0;
      uart_gecerli_r <= `LOW;
      fifo_buf_veri_r <= 0;
      uart_tilefields_r <= 0;
   end
   else begin
      uart_tilefields_r <= uart_tilefields_ns;
      durum_r <= durum_ns; 
      uart_ctrl_r <= uart_ctrl_ns;
      uart_veri_r <= uart_veri_ns;
      uart_gecerli_r <= uart_gecerli_ns;
      fifo_buf_veri_r <= fifo_buf_veri_ns;
   end
end

fifo2 #(
   .DATA_WIDTH(8),
   .DATA_DEPTH(32)
) rx_buffer (
   .clk_i    ( clk_i ),         
   .rstn_i   ( rstn_i ),         
   .data_i   ( rx_fifo_wr_data_cmb ),         
   .wr_en_i  ( rx_fifo_wr_en_cmb ),         
   .data_o   ( rx_fifo_rd_data_w ),         
   .rd_en_i  ( rx_fifo_rd_en_cmb ),         
   .full_o   ( rx_fifo_full_w ),         
   .empty_o  ( rx_fifo_empty )         
);

fifo2 #(
   .DATA_WIDTH(8),
   .DATA_DEPTH(32)
) tx_buffer (
   .clk_i    ( clk_i ),         
   .rstn_i   ( rstn_i ),         
   .data_i   ( tx_fifo_wr_data_cmb ),         
   .wr_en_i  ( tx_fifo_wr_en_cmb),         
   .data_o   ( tx_fifo_rd_data_w ),         
   .rd_en_i  ( consume_w ),         
   .full_o   ( tx_fifo_full_w ),         
   .empty_o  ( tx_fifo_empty )         
);

uart_alici alici (
   .clk_i                     ( clk_i ),
   .rstn_i                    ( rstn_i ),
   .rx_en_i                   ( rx_en_w ),
   .alinan_veri_o             ( alici_alinan_veri_w ),
   .alinan_gecerli_o          ( alici_alinan_gecerli_w ),
   .baud_div_i                ( baud_div ),   
   .rx_i                      ( rx_i )
);

uart_verici verici (
   .clk_i                     ( clk_i),
   .rstn_i                    ( rstn_i),
   .tx_en_i                   ( tx_en_w ),
   .veri_gecerli_i            ( !tx_fifo_empty ),
   .consume_o                 ( consume_w ),
   .gelen_veri_i              ( tx_fifo_rd_data_w ),
   .baud_div_i                ( baud_div ),
   .tx_o                      ( tx_o ),
   .hazir_o                   ( verici_hazir_w ) 
);

reg [31:0] tx_ctr_r;

always @(posedge clk_i) begin
   if (!rstn_i) begin
      tx_ctr_r <= 0;
   end
   else if (consume_w) begin
      tx_ctr_r <= tx_ctr_r + 1;
   end
end

assign tx_en_w = uart_ctrl_r [0];
assign rx_en_w = uart_ctrl_r [1];

`ifndef SPIKE_DIFF
assign baud_div = uart_ctrl_r [31:16];
`else
assign baud_div = 16'd2;
`endif

assign uart_veri_o = uart_veri_r;
assign uart_gecerli_o = uart_gecerli_r;
assign uart_tilefields_o = uart_tilefields_r;
assign uart_status_w [0] = tx_fifo_full_w;
assign uart_status_w [1] = tx_fifo_empty;
assign uart_status_w [2] = rx_fifo_full_w;
assign uart_status_w [3] = rx_fifo_empty;

assign cek_hazir_o = `HIGH;

//ila_uartd debug_uartd (
//    .clk    (clk_i),
//    .probe0 (durum_r),
//    .probe1 (tx_fifo_full_w),
//    .probe2 (tx_fifo_empty),
//    .probe3 (tx_fifo_wr_en_cmb),
//    .probe4 (tx_fifo_rd_en_cmb),
//    .probe5 (rx_fifo_full_w),
//    .probe6 (rx_fifo_empty),
//    .probe7 (rx_fifo_wr_en_cmb),
//    .probe8 (rx_fifo_rd_en_cmb),
//    .probe9 (baud_div),
//    .probe10(cek_adres_i),
//    .probe11(cek_uart_istek_w),
//    .probe12(cek_hazir_o),
//    .probe13(uart_veri_o),
//    .probe14(uart_gecerli_o),
//    .probe15(uart_hazir_i)
//);

endmodule

module uart_alici (
    input                   clk_i,
    input                   rstn_i,

    input                   rx_en_i,
    output [7:0]            alinan_veri_o,
    output                  alinan_gecerli_o,
    input [15:0]            baud_div_i,
    
    input                   rx_i
    
);

localparam BOSTA = 0;
localparam START_AL = 1;
localparam VERI_AL = 2;
localparam BITTI = 3;

reg [7:0] alinan_veri_ns;
reg [7:0] alinan_veri_r;

reg [1:0] durum_r;
reg [1:0] durum_ns;

reg [15:0] sayac_r;
reg [15:0] sayac_ns;

reg [3:0] alinan_veri_biti_r;
reg [3:0] alinan_veri_biti_ns;

reg sample0_aktif_cmb;
reg sample1_aktif_cmb;
reg sample2_aktif_cmb;

reg sample0_r;
reg sample0_ns;

reg sample1_r;
reg sample1_ns;

reg sample2_r;
reg sample2_ns;

reg rx_past0_r;
reg rx_past0_ns;

reg rx_past1_r;
reg rx_past1_ns;

reg hazir_cmb;
reg saat_aktif_cmb;
reg alinan_veri_gecerli_cmb;
reg sample_maj_cmb;

always @* begin
   rx_past0_ns = rx_i;
   rx_past1_ns = rx_past0_r;
   sample0_ns = sample0_r;
   sample1_ns = sample1_r;
   sample2_ns = sample2_r;

   hazir_cmb = `LOW;
   saat_aktif_cmb = `LOW;
   alinan_veri_gecerli_cmb = `LOW;
   durum_ns = durum_r;
   sayac_ns = sayac_r;
   alinan_veri_biti_ns = alinan_veri_biti_r;
   alinan_veri_ns = alinan_veri_r;

   sayac_ns = sayac_r + 1;

   saat_aktif_cmb = sayac_r == baud_div_i;
   sample0_aktif_cmb = sayac_r == (baud_div_i / 20 * 9);
   sample1_aktif_cmb = sayac_r == (baud_div_i / 20 * 10);
   sample2_aktif_cmb = sayac_r == (baud_div_i / 20 * 11);

   if (saat_aktif_cmb) begin
      sayac_ns = 0;
   end

   if (sample0_aktif_cmb) begin
      sample0_ns = rx_past1_r;
   end

   if (sample1_aktif_cmb) begin
      sample1_ns = rx_past1_r;
   end

   if (sample2_aktif_cmb) begin
      sample2_ns = rx_past1_r;
   end

   sample_maj_cmb = (sample0_r && sample1_r) || (sample1_r && sample2_r) || (sample0_r && sample2_r);

   case (durum_r) 
      BOSTA: begin
         if (rx_i == `LOW && rx_en_i) begin 
            durum_ns = START_AL;
            sayac_ns = 16'd0;
            alinan_veri_biti_ns = 0;
         end    
      end
      START_AL: begin
         if (saat_aktif_cmb) begin
            durum_ns = sample_maj_cmb ? BOSTA : VERI_AL;
         end
      end
      VERI_AL: begin
         if (saat_aktif_cmb) begin
            alinan_veri_ns[alinan_veri_biti_r] = sample_maj_cmb;
            alinan_veri_biti_ns = alinan_veri_biti_r + 1;
            if (alinan_veri_biti_r == 4'd7) begin
               durum_ns = BITTI;
            end
         end
      end
      BITTI: begin
         if (sample2_aktif_cmb) begin
            alinan_veri_gecerli_cmb = `HIGH;
            durum_ns = BOSTA;
            hazir_cmb = `HIGH;
         end
      end
   endcase
end

always @ (posedge clk_i) begin
   if (!rstn_i) begin
      durum_r <= BOSTA;
      sayac_r <= 16'd0;
      alinan_veri_biti_r <= 0; 
      rx_past0_r <= 0;
      rx_past1_r <= 0;
      sample0_r <= 0;
      sample1_r <= 0;
      sample2_r <= 0;
   end
   else begin
      durum_r <= durum_ns; 
      sayac_r <= sayac_ns;
      alinan_veri_biti_r <= alinan_veri_biti_ns;
      alinan_veri_r <= alinan_veri_ns;
      rx_past0_r <= rx_past0_ns;
      rx_past1_r <= rx_past1_ns;
      sample0_r <= sample0_ns;
      sample1_r <= sample1_ns;
      sample2_r <= sample2_ns;
   end
end

assign alinan_veri_o = alinan_veri_r;
assign alinan_gecerli_o = alinan_veri_gecerli_cmb;

endmodule

module uart_verici (
   input                   clk_i,
   input                   rstn_i,
   
   input                   tx_en_i,              // tx_en
   input                   veri_gecerli_i, // !fifo_empty
   output                  consume_o,

   input [7:0]             gelen_veri_i,
   input [15:0]            baud_div_i,
   
   output                  tx_o,
   output                  hazir_o
);

localparam BOSTA = 0;
localparam BASLA = 1;
localparam VERI_GONDER = 2;
localparam BITTI = 3;

reg [1:0] durum_r;
reg [1:0] durum_ns;

reg [15:0] sayac_r;
reg [15:0] sayac_ns;

reg [2:0] gonderilecek_veri_biti_r;
reg [2:0] gonderilecek_veri_biti_ns;

reg [7:0] veri_r;
reg [7:0] veri_ns;

reg tx_cmb;
reg hazir_cmb;
reg saat_aktif_cmb;

reg consume_cmb;

always @* begin
   tx_cmb = `HIGH;
   hazir_cmb = `LOW;
   saat_aktif_cmb = `LOW;
   durum_ns = durum_r;
   sayac_ns = sayac_r;
   veri_ns = veri_r;
   gonderilecek_veri_biti_ns = gonderilecek_veri_biti_r;
   consume_cmb = `LOW;

   sayac_ns = sayac_r + 1;

   saat_aktif_cmb = sayac_r == baud_div_i;

   if (sayac_r == baud_div_i) begin
      sayac_ns = 0;
   end

   case (durum_r) 
      BOSTA: begin
         if (tx_en_i && veri_gecerli_i) begin
            consume_cmb = `HIGH;
            tx_cmb = `LOW;
            durum_ns = BASLA;
            sayac_ns = 16'd0;
            veri_ns = gelen_veri_i;
            gonderilecek_veri_biti_ns = 0;
         end    
      end
      BASLA: begin
         tx_cmb = `LOW;
         if (saat_aktif_cmb) begin
            durum_ns = VERI_GONDER;
         end
      end
      VERI_GONDER: begin
         tx_cmb = veri_r[gonderilecek_veri_biti_r];
         if (saat_aktif_cmb) begin
            gonderilecek_veri_biti_ns = gonderilecek_veri_biti_r + 1;
            if (gonderilecek_veri_biti_r == 3'd7) begin
               durum_ns = BITTI;
            end
         end            
      end
      BITTI: begin
         tx_cmb = `HIGH;
         if (saat_aktif_cmb) begin
            durum_ns = BOSTA;
            hazir_cmb = `HIGH;
         end     
      end
   endcase
end

always @ (posedge clk_i) begin
   if (!rstn_i) begin
      durum_r <= BOSTA;
      sayac_r <= 0;
      gonderilecek_veri_biti_r <= 0; // En anlamsız bitten yollamaya başlanır.
      veri_r <= 0;
   end
   else begin
      durum_r <= durum_ns; 
      sayac_r <= sayac_ns;
      gonderilecek_veri_biti_r <= gonderilecek_veri_biti_ns;
      veri_r <= veri_ns;
   end
end

assign tx_o = tx_cmb;
assign hazir_o = hazir_cmb;
assign consume_o = consume_cmb;

endmodule
