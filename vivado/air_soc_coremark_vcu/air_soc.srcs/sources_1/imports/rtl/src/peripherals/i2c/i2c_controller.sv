// i2c_controller.sv
`timescale 1ns / 1ps

`include "header.vh"
`define HIGH 1'b1
`define LOW 1'b0

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
    output scl_o,

    output sda_out_en_o,
    output scl_out_en_o
);

reg [31:0] wb_read_data_r = 0;
reg [31:0] wb_read_data_next_r = 0;
assign wb_dat_o = wb_read_data_r;

reg wb_ack_r = 0;
reg wb_ack_next_r = 0;
assign wb_ack_o = wb_ack_r;

    reg [31:0] I2C_NBY;
    reg [31:0] I2C_NBY_NEXT;
    /*
    Masterdan slave'e yazılacak ya da okunacak bayt sayısını belirler.
    1-4 arasında. 0'a 1, >4 ise 4 değerini alır. 
    */

    reg [31:0] I2C_ADR;
    reg [31:0] I2C_ADR_NEXT;
    /*
    Slave adresini belirler. ADR[6:0] olarak kullanılır. Diğer bitler önemsiz.
    */
    reg [31:0] I2C_RDR;
    reg [31:0] I2C_RDR_NEXT;
    /*
    READ ONLY REG
    CDG[2] 1 olduğu anda NBY'ye göre veri yazılır.
    İlk gelen veriler en anlamsız bitlere yazılır. [7:0], [15:8] ...
    Receive tamamlandığında CFG[3] bitini 1'e çeker.
    */
    reg [31:0] I2C_TDR;
    reg [31:0] I2C_TDR_NEXT;
    /*
    NBY'ye bakarak iletilecek bayt sayısını belirler.
    CFG[0] 1 olduğunda transmit başlar.
    Bittiğinde CFG[1]'i 1 yapar.
    Düşük anlamlı bayttan göndermeye başlar. [7:0], [15:8] ...
    */

    reg [31:0] I2C_CFG;
    reg [31:0] I2C_CFG_NEXT;
    /*
    I2C_CFG[0] --> Transmit enable | TDR'de bulunan veriyi NBY bayt kadar gönderir
    I2C_CFG[1] --> Transmit tamamlandı | Veri gönderimi tamamlandığında HW tarafından 1 yapılır, SW tarafından 0 yapılır
    I2C_CFG[2] --> Receive enable | 1 olduğu sürece slaveden NBY'deki sayı kadar bayt okunur.
    I2C_CFG[3] --> Receive tamamlandı | Veri alımı tamamlandığında HW tarafından 1 yapılır, SW tarafından 0 yapılır
    */

   reg  [6:0]       address_r;
   reg              rd_wr_r;  // write -->0, read -->1
   reg  [31:0]      write_data_r;
   reg  [2:0]       num_bytes_r;
   wire [31:0]      read_data_w; //i2c'den okunan veri
   reg              start_r;
   wire             start_aldim_w;
   wire             ready_w;
   wire             read_finished_w;
   wire             write_finished_w;
   wire             error_w;
   wire             sda_drive_w;

   wire [2:0] bayt_sayisi;
   assign bayt_sayisi = I2C_NBY[2:0] < 1 ? 0 : (I2C_NBY[2:0] > 4 ? 4 : I2C_NBY[2:0]); // bayt sayısını 1-4 arasına sıkıştırır

   wire CFG_YAZ_EN = I2C_CFG[0] ? 1 : 0;
   wire CFG_YAZ_TAMAMLANDI = I2C_CFG[1] ? 1 : 0; 
   wire CFG_OKU_EN = I2C_CFG[2] ? 1 : 0;
   wire CFG_OKU_TAMAMLANDI = I2C_CFG[3] ? 1 : 0;

   reg [1:0] durum_r;
   reg [1:0] durum_ns;;
   localparam BOSTA = 2'd0;
   localparam YAZ = 2'd1;
   localparam OKU = 2'd2;
   localparam BITTI = 2'd3;



   reg [7:0] write_data;
   reg [7:0] read_data;
   reg [2:0] num_read;
   reg start;
   reg rd_wr;

   always @* begin
      wb_ack_next_r = 0;
      wb_read_data_next_r = 0;
      durum_ns = durum_r;

      address_r = 0;
      rd_wr_r = 0;
      write_data_r = 0;
      num_bytes_r = 0;
      start_r = 0;

   
         if (CFG_YAZ_EN) begin //: Transmit enable bit. ‘1’ olduğu sürece I2C_TDR registerında bulunan veriyi I2C_NBY bayt kadar gönderir
            address_r = I2C_ADR[6:0];
            rd_wr_r = `LOW; //yaz -->0, Oku -->1
            write_data_r = I2C_TDR;
            num_bytes_r = I2C_NBY;
            start_r = `HIGH;
            if(write_finished_w) begin
               I2C_CFG[1] = `HIGH;
            end  
         end

         else if (CFG_OKU_EN) begin
            address_r = I2C_ADR[6:0];
            rd_wr_r = `HIGH; //yaz -->0, Oku -->1
            num_bytes_r = bayt_sayisi;
            start_r = 1;
            if(read_finished_w) begin
               I2C_RDR_NEXT = read_data_w;
               I2C_CFG[1] = `HIGH;
            end
         end



      if (wb_cyc_i) begin
         wb_ack_next_r <= wb_stb_i & !wb_ack_r;
         if (wb_stb_i & wb_we_i & !wb_ack_o) begin // write
            case (wb_adr_i)
               8'h00: begin
                  //eb arayüzünden son 3 bitine atama yapılmış halinde veri gelmelidir
                  I2C_NBY_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : I2C_NBY[7:0  ];
                  I2C_NBY_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : I2C_NBY[15:8 ];
                  I2C_NBY_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : I2C_NBY[23:16];
                  I2C_NBY_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : I2C_NBY[31:24];
               end
               8'h04: begin
                  I2C_ADR_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : I2C_ADR[7:0  ];
                  I2C_ADR_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : I2C_ADR[15:8 ];
                  I2C_ADR_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : I2C_ADR[23:16];
                  I2C_ADR_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : I2C_ADR[31:24];
               end
               8'h08: begin
                  I2C_TDR_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : I2C_TDR[7:0  ];
                  I2C_TDR_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : I2C_TDR[15:8 ];
                  I2C_TDR_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : I2C_TDR[23:16];
                  I2C_TDR_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : I2C_TDR[31:24];
               end
               8'h0C: begin
                  I2C_CFG_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : I2C_CFG[7:0  ];
                  I2C_CFG_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : I2C_CFG[15:8 ];
                  I2C_CFG_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : I2C_CFG[23:16];
                  I2C_CFG_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : I2C_CFG[31:24];
               end
            endcase
         end 
         else if (~wb_we_i) begin // read
            case (wb_adr_i)
               8'h00: begin
                  wb_read_data_next_r = I2C_NBY;
               end
               8'h04: begin
                  wb_read_data_next_r = I2C_ADR;
               end
               8'h08: begin
                  wb_read_data_next_r = I2C_RDR;
               end
               8'h0C: begin
                  wb_read_data_next_r = I2C_TDR;
               end
               8'h10: begin
                  wb_read_data_next_r = I2C_CFG;
               end
            endcase
         end
      end
   end

   i2c_master master(
      .clk_i                (clk_i),
      .rst_i                (rst_i),
      .scl_i                (scl_i),           // TODO: scl input, mutli master için kullanılabilir 
      .scl_o                (scl_o),
      .sda_i                (sda_i),           // sda input
      .sda_o                (sda_o),           // sda output
      .address_i            (address_r),
      .rd_wr_i              (rd_wr_r),
      .write_data_i         (write_data_r),
      .num_bytes_i          (num_bytes_r),
      .read_data_o          (read_data_w),
      .start_i              (start_r),
      .start_aldim_o        (start_aldim_w),
      .ready_o              (ready_w),
      .read_finished_o      (read_finished_w),
      .write_finished_o     (write_finished_w),
      .error_o              (error_w),
      .sda_drive_o          (sda_drive_w)
   );
   

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
         durum_r <= BOSTA;
      end else begin
         wb_ack_r <= wb_ack_next_r;
         wb_read_data_r <= wb_read_data_next_r;
         I2C_NBY <= I2C_NBY_NEXT;
         I2C_ADR <= I2C_ADR_NEXT;
         I2C_TDR <= I2C_TDR_NEXT;
         I2C_CFG <= I2C_CFG_NEXT;
         durum_r <= durum_ns;
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




endmodule

