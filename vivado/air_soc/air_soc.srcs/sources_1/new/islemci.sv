`timescale 1ns / 1ps

`include "sabitler.vh"

`include "header.vh"

//`define SAED32_SRAM

module islemci (
   input clk,
   input resetn,

`ifdef USE_POWER_PINS
   input vccd1,
   input vssd1,
`endif

   output        iomem_valid,
   input         iomem_ready,
   output [ 3:0] iomem_wstrb,
   output [31:0] iomem_addr,
   output [31:0] iomem_wdata,
   input  [31:0] iomem_rdata,

   output uart_tx_o,
   input  uart_rx_i

   
);

wire pwm0_o;
wire pwm1_o;

wire spi_cs_o;
wire spi_sck_o;
wire spi_mosi_o;
wire spi_miso_i;

wire                            io_cek_buyruk_istek_gecerli_w;
wire                            io_cek_l1vd_istek_gecerli_w;
wire                            io_cek_buyruk_istek_hazir_w;
wire                            io_cek_l1vd_istek_hazir_w;
// ---- Cekirdek ----
wire                            io_cek_clk_w;
wire                            io_cek_rstn_w;
wire    [`L1_BLOK_BIT-1:0]      io_cek_buyruk_yanit_veri_w;
wire                            io_cek_buyruk_yanit_gecerli_w;
//wire                            io_cek_buyruk_yanit_hazir_w;
wire                            io_cek_buyruk_yanit_hazir_w = io_cek_buyruk_istek_gecerli_w && !io_cek_buyruk_istek_hazir_w;
wire    [`ADRES_BIT-1:0]        io_cek_buyruk_istek_adres_w;


wire    [`VERI_BIT-1:0]         io_cek_l1vd_yanit_veri_w;
wire                            io_cek_l1vd_yanit_gecerli_w;
//wire                            io_cek_l1vd_yanit_hazir_w;
wire                            io_cek_l1vd_yanit_hazir_w = io_cek_l1vd_istek_gecerli_w && !io_cek_l1vd_istek_hazir_w;
wire    [`VERI_BIT-1:0]         io_cek_l1vd_istek_veri_w;
wire    [`VERI_BYTE-1:0]        io_cek_l1vd_istek_maske_w;
wire    [`ADRES_BIT-1:0]        io_cek_l1vd_istek_adres_w;
wire                            io_cek_l1vd_istek_yaz_w;

wire                            io_cek_l1vd_istek_onbellekleme_w;
//reg                            io_cek_l1vd_istek_onbellekleme_w = 1;


assign io_cek_l1vd_istek_onbellekleme_w = ({32{io_cek_buyruk_istek_hazir_w}} & (io_cek_l1vd_istek_adres_w & ~`RAM_MASK_ADDR)) != `RAM_BASE_ADDR; //io_cek_l1vd_istek_adres_w[30] ? 1'b0 : 1'b1;

/*
cekirdek cekirdek (
   .clk_i                      ( io_cek_clk_w ),
   .rstn_i                     ( io_cek_rstn_w ),
   .buyruk_yanit_veri_i        ( io_cek_buyruk_yanit_veri_w ),
   .buyruk_yanit_gecerli_i     ( io_cek_buyruk_yanit_gecerli_w ),
   .buyruk_yanit_hazir_o       ( io_cek_buyruk_yanit_hazir_w ),
   .buyruk_istek_adres_o       ( io_cek_buyruk_istek_adres_w ),
   .buyruk_istek_gecerli_o     ( io_cek_buyruk_istek_gecerli_w ),
   .buyruk_istek_hazir_i       ( io_cek_buyruk_istek_hazir_w ),
   .l1v_yanit_veri_i           ( io_cek_l1vd_yanit_veri_w ),
   .l1v_yanit_gecerli_i        ( io_cek_l1vd_yanit_gecerli_w ),
   .l1v_yanit_hazir_o          ( io_cek_l1vd_yanit_hazir_w ),
   .l1v_istek_veri_o           ( io_cek_l1vd_istek_veri_w ),
   .l1v_istek_maske_o          ( io_cek_l1vd_istek_maske_w ),
   .l1v_istek_adres_o          ( io_cek_l1vd_istek_adres_w ),
   .l1v_istek_yaz_o            ( io_cek_l1vd_istek_yaz_w ),
   .l1v_istek_gecerli_o        ( io_cek_l1vd_istek_gecerli_w ),
   .l1v_istek_onbellekleme_o   ( io_cek_l1vd_istek_onbellekleme_w ),
   .l1v_istek_hazir_i          ( io_cek_l1vd_istek_hazir_w )
);
*/

/*
// State definitions
`define STATE_IDLE 2'b00
`define STATE_REQUESTED 2'b01
`define STATE_GRANTED 2'b10

// Signal declarations (assuming these are part of your module)
reg [1:0] instr_state = `STATE_IDLE;

// Instruction interface signals
wire instr_req_o;
wire instr_gnt_i;

// Output signal indicating readiness to accept instruction response
reg io_cek_buyruk_yanit_hazir_r;
assign io_cek_buyruk_yanit_hazir_w = io_cek_buyruk_yanit_hazir_r;

// FSM for instruction interface
always @(posedge clk) begin
    if (resetn == 1'b0) begin
        instr_state <= `STATE_IDLE;
        io_cek_buyruk_yanit_hazir_r <= 1'b0;
    end else begin
        case (instr_state)
            `STATE_IDLE: begin
                if (io_cek_buyruk_istek_gecerli_w) begin
                    instr_state <= `STATE_REQUESTED;
                    //instr_state <= io_cek_buyruk_istek_hazir_w ? `STATE_GRANTED : `STATE_REQUESTED;
                end
                io_cek_buyruk_yanit_hazir_r <= 1'b1; // Ready for new instructions
            end
            `STATE_REQUESTED: begin
                if (io_cek_buyruk_istek_hazir_w) begin
                    instr_state <= `STATE_GRANTED;
                end
                io_cek_buyruk_yanit_hazir_r <= 1'b0; // Not ready until granted
            end
            `STATE_GRANTED: begin
                // Transition logic to return to IDLE or handle additional logic
                //if(io_cek_buyruk_yanit_gecerli_w)
                    instr_state <= `STATE_IDLE; // Simplified transition
            end
            default: instr_state <= `STATE_IDLE;
        endcase
    end
end

reg [1:0] data_state = `STATE_IDLE;

// Instruction interface signals
wire data_req_o;
wire data_gnt_i;

// Output signal indicating readiness to accept datauction response
reg io_cek_veri_yanit_hazir_r;
assign io_cek_l1vd_yanit_hazir_w = io_cek_veri_yanit_hazir_r;

// FSM for datauction interface
always @(posedge clk) begin
    if (resetn == 1'b0) begin
        data_state <= `STATE_IDLE;
        io_cek_veri_yanit_hazir_r <= 1'b0;
    end else begin
        case (data_state)
            `STATE_IDLE: begin
                if (io_cek_l1vd_istek_gecerli_w) begin
                    data_state <= `STATE_REQUESTED;
                    //data_state <= io_cek_l1vd_istek_hazir_w ? `STATE_GRANTED : `STATE_REQUESTED;
                end
                io_cek_veri_yanit_hazir_r <= 1'b1; // Ready for new datauctions
            end
            `STATE_REQUESTED: begin
                if (io_cek_l1vd_istek_hazir_w) begin
                    data_state <= `STATE_GRANTED;
                end
                io_cek_veri_yanit_hazir_r <= 1'b0; // Not ready until granted
            end
            `STATE_GRANTED: begin
                // Transition logic to return to IDLE or handle additional logic
                //if(io_cek_l1vd_yanit_gecerli_w)
                    data_state <= `STATE_IDLE; // Simplified transition
            end
            default: data_state <= `STATE_IDLE;
        endcase
    end
end
*/

/*
reg io_cek_buyruk_istek_gecerli_r = 0;
reg io_cek_l1vd_istek_gecerli_r = 0;

reg io_cek_buyruk_istek_hazir_r = 0;
reg io_cek_l1vd_istek_hazir_r = 0;

reg io_cek_buyruk_yanit_gecerli_r = 0;
reg io_cek_l1vd_yanit_gecerli_r = 0;

always @ (posedge clk) begin
    if(resetn == 0) begin
        io_cek_buyruk_istek_gecerli_r <= 0;
        io_cek_l1vd_istek_gecerli_r <= 0;
        
        io_cek_buyruk_istek_hazir_r <= 0;
        io_cek_l1vd_istek_hazir_r <= 0;
        
        io_cek_buyruk_yanit_gecerli_r <= 0;
        io_cek_l1vd_yanit_gecerli_r <= 0;
    end
    else begin
        io_cek_buyruk_istek_gecerli_r <= io_cek_buyruk_istek_gecerli_w;
        io_cek_l1vd_istek_gecerli_r <= io_cek_l1vd_istek_gecerli_w;
        
        io_cek_buyruk_istek_hazir_r <= io_cek_buyruk_istek_hazir_w;
        io_cek_l1vd_istek_hazir_r <= io_cek_l1vd_istek_hazir_w;
        
        io_cek_buyruk_yanit_gecerli_r <= io_cek_buyruk_yanit_gecerli_w;
        io_cek_l1vd_yanit_gecerli_r <= io_cek_l1vd_yanit_gecerli_w;
    end
end
*/

cv32e40p_top #(
    .COREV_PULP               ( `COREV_PULP ),
    .COREV_CLUSTER            ( `COREV_CLUSTER ),
    .FPU                      ( `FPU ),
    .FPU_ADDMUL_LAT           ( `FPU_ADDMUL_LAT ),
    .FPU_OTHERS_LAT           ( `FPU_OTHERS_LAT ),
    .ZFINX                    ( `ZFINX ),
    .NUM_MHPMCOUNTERS         ( `NUM_MHPMCOUNTERS )
)
cv32e40p_core_ip (
    .clk_i                    (io_cek_clk_w),
    .rst_ni                   (io_cek_rstn_w),

    .pulp_clock_en_i          (`PULP_CLOCK_EN), // PULP clock enable (only used if COREV_CLUSTER = 1)
    .scan_cg_en_i             (`SCAN_CG_EN), // Enable all clock gates for testing

    // Configuration
    .boot_addr_i              (`BOOT_ADDR),
    .mtvec_addr_i             (`MTVEC_ADDR),
    .dm_halt_addr_i           (`DM_HALT_ADDR),
    .hart_id_i                (`HART_ID),
    .dm_exception_addr_i      (`DM_EXCEPTION_ADDR),
    
    // TODO: Always valid?
    // Instruction memory interface
    .instr_req_o              (io_cek_buyruk_istek_gecerli_w),
    .instr_gnt_i              (io_cek_buyruk_istek_hazir_w),
    .instr_rvalid_i           (io_cek_buyruk_yanit_gecerli_w),
    .instr_addr_o             (io_cek_buyruk_istek_adres_w),
    .instr_rdata_i            (io_cek_buyruk_yanit_veri_w),

    // TODO: Always valid?
    // Data memory interface
    .data_req_o               (io_cek_l1vd_istek_gecerli_w),
    .data_gnt_i               (io_cek_l1vd_istek_hazir_w),
    .data_rvalid_i            (io_cek_l1vd_yanit_gecerli_w),
    .data_we_o                (io_cek_l1vd_istek_yaz_w),
    .data_be_o                (io_cek_l1vd_istek_maske_w),
    .data_addr_o              (io_cek_l1vd_istek_adres_w),
    .data_wdata_o             (io_cek_l1vd_istek_veri_w),
    .data_rdata_i             (io_cek_l1vd_yanit_veri_w),

    // Interrupt interface
    .irq_i                    (32'h0),
    .irq_ack_o                (),
    .irq_id_o                 (),

    // TODO: JTAG Integration
    // Debug interface
    .debug_req_i              (1'b0),
    .debug_havereset_o        (),
    .debug_running_o          (),
    .debug_halted_o           (),

    // TODO
    // CPU Control Signals
    .fetch_enable_i           (io_cek_rstn_w),
    .core_sleep_o             ()
);

   // ---- L1 Buyruk Denetleyicisi ----
   wire                                      io_l1bd_clk_w;
   wire                                      io_l1bd_rstn_w;
   wire [                    `ADRES_BIT-1:0] io_l1bd_port_istek_adres_w;
   wire                                      io_l1bd_port_istek_gecerli_w;
   wire                                      io_l1bd_port_istek_yaz_w;
   wire [                     `VERI_BIT-1:0] io_l1bd_port_istek_veri_w;
   wire                                      io_l1bd_port_istek_hazir_w;
   wire [                     `VERI_BIT-1:0] io_l1bd_port_veri_w;
   wire                                      io_l1bd_port_veri_gecerli_w;
   wire                                      io_l1bd_port_veri_hazir_w;
   wire                                      io_l1bd_l1_istek_gecersiz_w;
   wire [              `ADRES_SATIR_BIT-1:0] io_l1bd_l1_istek_satir_w;
   wire [                      `L1B_YOL-1:0] io_l1bd_l1_istek_yaz_w;
   wire [(`ADRES_ETIKET_BIT * `L1B_YOL)-1:0] io_l1bd_l1_istek_etiket_w;
   wire [     (`L1_BLOK_BIT * `L1B_YOL)-1:0] io_l1bd_l1_istek_blok_w;
   wire [(`ADRES_ETIKET_BIT * `L1B_YOL)-1:0] io_l1bd_l1_veri_etiket_w;
   wire [     (`L1_BLOK_BIT * `L1B_YOL)-1:0] io_l1bd_l1_veri_blok_w;
   wire                                      io_l1bd_l1_veri_gecerli_w;
   wire [                    `ADRES_BIT-1:0] io_l1bd_vy_istek_adres_w;
   wire                                      io_l1bd_vy_istek_gecerli_w;
   wire                                      io_l1bd_vy_istek_hazir_w;
   wire                                      io_l1bd_vy_istek_yaz_w;
   wire [                  `L1_BLOK_BIT-1:0] io_l1bd_vy_istek_veri_w;
   wire [                  `L1_BLOK_BIT-1:0] io_l1bd_vy_veri_w;
   wire                                      io_l1bd_vy_veri_gecerli_w;
   wire                                      io_l1bd_vy_veri_hazir_w;

   l1b_denetleyici l1bd (
      .clk_i               (io_l1bd_clk_w),
      .rstn_i              (io_l1bd_rstn_w),
      .port_istek_adres_i  (io_l1bd_port_istek_adres_w),
      .port_istek_gecerli_i(io_l1bd_port_istek_gecerli_w),
      .port_istek_yaz_i    (io_l1bd_port_istek_yaz_w),
      .port_istek_veri_i   (io_l1bd_port_istek_veri_w),
      .port_istek_hazir_o  (io_l1bd_port_istek_hazir_w),
      .port_veri_o         (io_l1bd_port_veri_w),
      .port_veri_gecerli_o (io_l1bd_port_veri_gecerli_w),
      .port_veri_hazir_i   (io_l1bd_port_veri_hazir_w),
      .l1_istek_gecersiz_o (io_l1bd_l1_istek_gecersiz_w),
      .l1_istek_satir_o    (io_l1bd_l1_istek_satir_w),
      .l1_istek_yaz_o      (io_l1bd_l1_istek_yaz_w),
      .l1_istek_etiket_o   (io_l1bd_l1_istek_etiket_w),
      .l1_istek_blok_o     (io_l1bd_l1_istek_blok_w),
      .l1_veri_etiket_i    (io_l1bd_l1_veri_etiket_w),
      .l1_veri_blok_i      (io_l1bd_l1_veri_blok_w),
      .l1_veri_gecerli_i   (io_l1bd_l1_veri_gecerli_w),
      .vy_istek_adres_o    (io_l1bd_vy_istek_adres_w),
      .vy_istek_gecerli_o  (io_l1bd_vy_istek_gecerli_w),
      .vy_istek_hazir_i    (io_l1bd_vy_istek_hazir_w),
      .vy_istek_yaz_o      (io_l1bd_vy_istek_yaz_w),
      .vy_istek_veri_o     (io_l1bd_vy_istek_veri_w),
      .vy_veri_i           (io_l1bd_vy_veri_w),
      .vy_veri_gecerli_i   (io_l1bd_vy_veri_gecerli_w),
      .vy_veri_hazir_o     (io_l1bd_vy_veri_hazir_w)
   );

   // ---- L1 Buyruk Onbellegi ----
   wire                         io_l1bv_clk_w;
   wire                         io_l1bv_komut_gecerli_w;
   wire [         `L1B_YOL-1:0] io_l1bv_komut_yaz_w;
   wire [ `ADRES_SATIR_BIT-1:0] io_l1bv_komut_adres_w;

   wire [`ADRES_ETIKET_BIT-1:0] io_l1bv_yaz_etiket_bw   [0:`L1B_YOL-1];
   wire [     `L1_BLOK_BIT-1:0] io_l1bv_yaz_blok_bw     [0:`L1B_YOL-1];

   wire [`ADRES_ETIKET_BIT-1:0] io_l1bv_oku_etiket_bw   [0:`L1B_YOL-1];
   wire [     `L1_BLOK_BIT-1:0] io_l1bv_oku_blok_bw     [0:`L1B_YOL-1];

   genvar i;
`ifdef OPENLANE
   wire [335:0] l1b_wr_connect;
   wire [335:0] l1b_rd_connect;
   wire [ 41:0] l1b_wr_mask;
   localparam L1B_DATA_OFF = 56;
   generate
      for (i = 0; i < `L1B_YOL; i = i + 1) begin
         assign l1b_wr_connect[i*L1B_DATA_OFF+:32] = io_l1bv_yaz_blok_bw[i];
         assign l1b_wr_connect[i*L1B_DATA_OFF+32+:24] = {1'b0, io_l1bv_yaz_etiket_bw[i]};
         assign io_l1bv_oku_blok_bw[i] = l1b_rd_connect[i*L1B_DATA_OFF+:32];
         assign io_l1bv_oku_etiket_bw[i] = l1b_rd_connect[i*L1B_DATA_OFF+32+:23];
         assign l1b_wr_mask[i*7+:7] = io_l1bv_komut_yaz_w[i] ? 7'h00 : 7'h7F;
      end
   endgenerate
   sram_336x128 l1b_sram (
      .clk0  (io_l1bv_clk_w),
      .csb0  (!io_l1bv_komut_gecerli_w),
      .web0  (l1b_wr_mask),
      .addr0 ({0, io_l1bv_komut_adres_w}),
      .wmask0('hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF),
      .din0  (l1b_wr_connect),
      .dout0 (l1b_rd_connect)
   );
`elsif SAED32_SRAM
   genvar j;
   wire [7:0] io_l1bv_oku_etiket_bw2;
   generate
      for (i = 0; i < `L1B_YOL; i = i + 1) begin
         /*
         for (j = 0; j < 3; j = j + 1) begin // Burasi 3 (8x3 = 24 bit) cunku etiket 22 bit
            SRAM1RW1024x8 l1b_etiket_sram (
               .A({io_l1bv_komut_adres_w, 2'b00}),
               .CE(io_l1bd_clk_w),
               .WEB(!io_l1bv_komut_yaz_w[i]),
               .OEB(1'b0), //.OEB(!io_l1bv_komut_gecerli_w),
               .CSB(!io_l1bv_komut_gecerli_w),
               .I(io_l1bv_yaz_etiket_bw[i][j*8+:8]),
               .O(io_l1bv_oku_etiket_bw[i][j*8+:8])
            );
         end
         */
         
         SRAM1RW1024x8 l1b_etiket_sram0 (
               .A({io_l1bv_komut_adres_w, 2'b00}),
               .CE(io_l1bd_clk_w),
               .WEB(!io_l1bv_komut_yaz_w[i]),
               .OEB(1'b0), //.OEB(!io_l1bv_komut_gecerli_w),
               .CSB(!io_l1bv_komut_gecerli_w),
               .I(io_l1bv_yaz_etiket_bw[i][7:0]),
               .O(io_l1bv_oku_etiket_bw[i][7:0])
         );
         SRAM1RW1024x8 l1b_etiket_sram1 (
               .A({io_l1bv_komut_adres_w, 2'b00}),
               .CE(io_l1bd_clk_w),
               .WEB(!io_l1bv_komut_yaz_w[i]),
               .OEB(1'b0), //.OEB(!io_l1bv_komut_gecerli_w),
               .CSB(!io_l1bv_komut_gecerli_w),
               .I(io_l1bv_yaz_etiket_bw[i][15:8]),
               .O(io_l1bv_oku_etiket_bw[i][15:8])
         );
         
         SRAM1RW1024x8 l1b_etiket_sram2 (
               .A({io_l1bv_komut_adres_w, 2'b00}),
               .CE(io_l1bd_clk_w),
               .WEB(!io_l1bv_komut_yaz_w[i]),
               .OEB(1'b0), //.OEB(!io_l1bv_komut_gecerli_w),
               .CSB(!io_l1bv_komut_gecerli_w),
               .I({2'b00, io_l1bv_yaz_etiket_bw[i][21:16]}),
               .O(io_l1bv_oku_etiket_bw2)
         );
         assign io_l1bv_oku_etiket_bw[i][21:16] = io_l1bv_oku_etiket_bw2[5:0];
         
         for (j = 0; j < 4; j = j + 1) begin
            SRAM1RW1024x8 l1b_veri_sram (
               .A({io_l1bv_komut_adres_w, 2'b00}),
               .CE(io_l1bd_clk_w),
               .WEB(!io_l1bv_komut_yaz_w[i]),
               .OEB(1'b0), //.OEB(!io_l1bv_komut_gecerli_w),
               .CSB(!io_l1bv_komut_gecerli_w),
               .I(io_l1bv_yaz_blok_bw[i][j*8+:8]),
               .O(io_l1bv_oku_blok_bw[i][j*8+:8])
            );
         end
      end
   endgenerate
`else
   generate
      for (i = 0; i < `L1B_YOL; i = i + 1) begin
         bram_model #(
            .DATA_WIDTH(`ADRES_ETIKET_BIT),
            .BRAM_DEPTH(`L1B_SATIR)
         ) l1b_etiket (
            .clk_i   (io_l1bv_clk_w),
            .cmd_en_i(io_l1bv_komut_gecerli_w),
            .wr_en_i (io_l1bv_komut_yaz_w[i]),
            .addr_i  (io_l1bv_komut_adres_w),
            .data_i  ({0, io_l1bv_yaz_etiket_bw[i]}),
            .data_o  (io_l1bv_oku_etiket_bw[i])
         );

         bram_model #(
            .DATA_WIDTH(`L1_BLOK_BIT),
            .BRAM_DEPTH(`L1B_SATIR)
         ) l1b_veri (
            .clk_i   (io_l1bv_clk_w),
            .cmd_en_i(io_l1bv_komut_gecerli_w),
            .wr_en_i (io_l1bv_komut_yaz_w[i]),
            .addr_i  (io_l1bv_komut_adres_w),
            .data_i  ({0, io_l1bv_yaz_blok_bw[i]}),
            .data_o  (io_l1bv_oku_blok_bw[i])
         );
      end
   endgenerate
`endif

   // ---- L1 Veri Denetleyicisi ----
   wire                                      io_l1vd_clk_w;
   wire                                      io_l1vd_rstn_w;
   wire [                    `ADRES_BIT-1:0] io_l1vd_port_istek_adres_w;
   wire                                      io_l1vd_port_istek_gecerli_w;
   wire                                      io_l1vd_port_istek_onbellekleme_w;
   wire                                      io_l1vd_port_istek_yaz_w;
   wire [                     `VERI_BIT-1:0] io_l1vd_port_istek_veri_w;
   wire [                    `VERI_BYTE-1:0] io_l1vd_port_istek_maske_w;
   wire                                      io_l1vd_port_istek_hazir_w;
   wire [                     `VERI_BIT-1:0] io_l1vd_port_veri_w;
   wire                                      io_l1vd_port_veri_gecerli_w;
   wire                                      io_l1vd_port_veri_hazir_w;
   wire                                      io_l1vd_l1_istek_gecersiz_w;
   wire [              `ADRES_SATIR_BIT-1:0] io_l1vd_l1_istek_satir_w;
   wire [                      `L1V_YOL-1:0] io_l1vd_l1_istek_yaz_w;
   wire [(`ADRES_ETIKET_BIT * `L1V_YOL)-1:0] io_l1vd_l1_istek_etiket_w;
   wire [     (`L1_BLOK_BIT * `L1V_YOL)-1:0] io_l1vd_l1_istek_blok_w;
   wire [(`ADRES_ETIKET_BIT * `L1V_YOL)-1:0] io_l1vd_l1_veri_etiket_w;
   wire [     (`L1_BLOK_BIT * `L1V_YOL)-1:0] io_l1vd_l1_veri_blok_w;
   wire                                      io_l1vd_l1_veri_gecerli_w;
   wire [                    `ADRES_BIT-1:0] io_l1vd_vy_istek_adres_w;
   wire                                      io_l1vd_vy_istek_gecerli_w;
   wire                                      io_l1vd_vy_istek_onbellekleme_w;
   wire                                      io_l1vd_vy_istek_hazir_w;
   wire                                      io_l1vd_vy_istek_yaz_w;
   wire [                  `L1_BLOK_BIT-1:0] io_l1vd_vy_istek_veri_w;
   wire [                  `L1_BLOK_BIT-1:0] io_l1vd_vy_veri_w;
   wire                                      io_l1vd_vy_veri_gecerli_w;
   wire                                      io_l1vd_vy_veri_hazir_w;

   l1v_denetleyici l1vd (
      .clk_i                    (io_l1vd_clk_w),
      .rstn_i                   (io_l1vd_rstn_w),
      .port_istek_adres_i       (io_l1vd_port_istek_adres_w),
      .port_istek_gecerli_i     (io_l1vd_port_istek_gecerli_w),
      .port_istek_onbellekleme_i(io_l1vd_port_istek_onbellekleme_w),
      .port_istek_yaz_i         (io_l1vd_port_istek_yaz_w),
      .port_istek_veri_i        (io_l1vd_port_istek_veri_w),
      .port_istek_maske_i       (io_l1vd_port_istek_maske_w),
      .port_istek_hazir_o       (io_l1vd_port_istek_hazir_w),
      .port_veri_o              (io_l1vd_port_veri_w),
      .port_veri_gecerli_o      (io_l1vd_port_veri_gecerli_w),
      .port_veri_hazir_i        (io_l1vd_port_veri_hazir_w),
      .l1_istek_gecersiz_o      (io_l1vd_l1_istek_gecersiz_w),
      .l1_istek_satir_o         (io_l1vd_l1_istek_satir_w),
      .l1_istek_yaz_o           (io_l1vd_l1_istek_yaz_w),
      .l1_istek_etiket_o        (io_l1vd_l1_istek_etiket_w),
      .l1_istek_blok_o          (io_l1vd_l1_istek_blok_w),
      .l1_veri_etiket_i         (io_l1vd_l1_veri_etiket_w),
      .l1_veri_blok_i           (io_l1vd_l1_veri_blok_w),
      .l1_veri_gecerli_i        (io_l1vd_l1_veri_gecerli_w),
      .vy_istek_adres_o         (io_l1vd_vy_istek_adres_w),
      .vy_istek_gecerli_o       (io_l1vd_vy_istek_gecerli_w),
      .vy_istek_onbellekleme_o  (io_l1vd_vy_istek_onbellekleme_w),
      .vy_istek_hazir_i         (io_l1vd_vy_istek_hazir_w),
      .vy_istek_yaz_o           (io_l1vd_vy_istek_yaz_w),
      .vy_istek_veri_o          (io_l1vd_vy_istek_veri_w),
      .vy_veri_i                (io_l1vd_vy_veri_w),
      .vy_veri_gecerli_i        (io_l1vd_vy_veri_gecerli_w),
      .vy_veri_hazir_o          (io_l1vd_vy_veri_hazir_w)
   );

   // ---- L1 Buyruk Onbellegi ----
   wire                         io_l1vv_clk_w;
   wire                         io_l1vv_komut_gecerli_w;
   wire [         `L1V_YOL-1:0] io_l1vv_komut_yaz_w;
   wire [ `ADRES_SATIR_BIT-1:0] io_l1vv_komut_adres_w;

   wire [`ADRES_ETIKET_BIT-1:0] io_l1vv_yaz_etiket_bw   [0:`L1V_YOL-1];
   wire [     `L1_BLOK_BIT-1:0] io_l1vv_yaz_blok_bw     [0:`L1V_YOL-1];

   wire [`ADRES_ETIKET_BIT-1:0] io_l1vv_oku_etiket_bw   [0:`L1V_YOL-1];
   wire [     `L1_BLOK_BIT-1:0] io_l1vv_oku_blok_bw     [0:`L1V_YOL-1];

`ifdef OPENLANE
   wire [335:0] l1v_wr_connect;
   wire [335:0] l1v_rd_connect;
   wire [ 41:0] l1v_wr_mask;
   localparam L1V_DATA_OFF = 56;
   generate
      for (i = 0; i < `L1V_YOL; i = i + 1) begin
         assign l1v_wr_connect[i*L1V_DATA_OFF+:32] = io_l1vv_yaz_blok_bw[i];
         assign l1v_wr_connect[i*L1V_DATA_OFF+32+:24] = {1'b0, io_l1vv_yaz_etiket_bw[i]};
         assign io_l1vv_oku_blok_bw[i] = l1v_rd_connect[i*L1V_DATA_OFF+:32];
         assign io_l1vv_oku_etiket_bw[i] = l1v_rd_connect[i*L1V_DATA_OFF+32+:23];
         assign l1v_wr_mask[i*7+:7] = io_l1vv_komut_yaz_w[i] ? 7'h00 : 7'h7F;
      end
   endgenerate
   sram_112x128 l1v_sram (
      .clk0  (io_l1vv_clk_w),
      .csb0  (!io_l1vv_komut_gecerli_w),
      .web0  (l1v_wr_mask),
      .addr0 ({0, io_l1vv_komut_adres_w}),
      .wmask0('hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF),
      .din0  (l1v_wr_connect),
      .dout0 (l1v_rd_connect)
   );
`elsif SAED32_SRAM
   //genvar j;
   wire [7:0] io_l1vv_oku_etiket_bw2;
   generate
      for (i = 0; i < `L1V_YOL; i = i + 1) begin
         SRAM1RW1024x8 l1v_etiket_sram0 (
               .A({io_l1vv_komut_adres_w, 2'b00}),
               .CE(io_l1vd_clk_w),
               .WEB(!io_l1vv_komut_yaz_w[i]),
               .OEB(1'b0), //.OEB(!io_l1vv_komut_gecerli_w),
               .CSB(!io_l1vv_komut_gecerli_w),
               .I(io_l1vv_yaz_etiket_bw[i][7:0]),
               .O(io_l1vv_oku_etiket_bw[i][7:0])
         );
         SRAM1RW1024x8 l1v_etiket_sram1 (
               .A({io_l1vv_komut_adres_w, 2'b00}),
               .CE(io_l1vd_clk_w),
               .WEB(!io_l1vv_komut_yaz_w[i]),
               .OEB(1'b0), //.OEB(!io_l1vv_komut_gecerli_w),
               .CSB(!io_l1vv_komut_gecerli_w),
               .I(io_l1vv_yaz_etiket_bw[i][15:8]),
               .O(io_l1vv_oku_etiket_bw[i][15:8])
         );
         
         SRAM1RW1024x8 l1v_etiket_sram2 (
               .A({io_l1vv_komut_adres_w, 2'b00}),
               .CE(io_l1vd_clk_w),
               .WEB(!io_l1vv_komut_yaz_w[i]),
               .OEB(1'b0), //.OEB(!io_l1vv_komut_gecerli_w),
               .CSB(!io_l1vv_komut_gecerli_w),
               .I({2'b00, io_l1vv_yaz_etiket_bw[i][21:16]}),
               .O(io_l1vv_oku_etiket_bw2)
         );
         assign io_l1vv_oku_etiket_bw[i][21:16] = io_l1vv_oku_etiket_bw2[5:0];
         
         for (j = 0; j < 4; j = j + 1) begin
            SRAM1RW1024x8 l1v_veri_sram (
               .A({io_l1vv_komut_adres_w, 2'b00}),
               .CE(io_l1vd_clk_w),
               .WEB(!io_l1vv_komut_yaz_w[i]),
               .OEB(1'b0), //.OEB(!io_l1vv_komut_gecerli_w),
               .CSB(!io_l1vv_komut_gecerli_w),
               .I(io_l1vv_yaz_blok_bw[i][j*8+:8]),
               .O(io_l1vv_oku_blok_bw[i][j*8+:8])
            );
         end
      end
   endgenerate 
`else
   generate
      for (i = 0; i < `L1V_YOL; i = i + 1) begin
         bram_model #(
            .DATA_WIDTH(`ADRES_ETIKET_BIT),
            .BRAM_DEPTH(`L1V_SATIR)
         ) l1v_etiket (
            .clk_i   (io_l1vv_clk_w),
            .cmd_en_i(io_l1vv_komut_gecerli_w),
            .wr_en_i (io_l1vv_komut_yaz_w[i]),
            .addr_i  ({0, io_l1vv_komut_adres_w}),
            .data_i  (io_l1vv_yaz_etiket_bw[i]),
            .data_o  (io_l1vv_oku_etiket_bw[i])
         );

         bram_model #(
            .DATA_WIDTH(`L1_BLOK_BIT),
            .BRAM_DEPTH(`L1V_SATIR)
         ) l1v_veri (
            .clk_i   (io_l1vv_clk_w),
            .cmd_en_i(io_l1vv_komut_gecerli_w),
            .wr_en_i (io_l1vv_komut_yaz_w[i]),
            .addr_i  ({0, io_l1vv_komut_adres_w}),
            .data_i  (io_l1vv_yaz_blok_bw[i]),
            .data_o  (io_l1vv_oku_blok_bw[i])
         );
      end
   endgenerate
`endif

   // ---- Veri Yolu Denetleyicisi ----
   wire                    io_vyd_clk_w;
   wire                    io_vyd_rstn_w;
   wire [  `ADRES_BIT-1:0] io_vyd_mem_istek_adres_w;
   wire [   `VERI_BIT-1:0] io_vyd_mem_istek_veri_w;
   wire                    io_vyd_mem_istek_yaz_w;
   wire                    io_vyd_mem_istek_gecerli_w;
   wire                    io_vyd_mem_istek_hazir_w;
   wire [   `VERI_BIT-1:0] io_vyd_mem_veri_w;
   wire                    io_vyd_mem_veri_gecerli_w;
   wire                    io_vyd_mem_veri_hazir_w;
   wire [  `ADRES_BIT-1:0] io_vyd_l1b_istek_adres_w;
   wire                    io_vyd_l1b_istek_gecerli_w;
   wire [`L1_BLOK_BIT-1:0] io_vyd_l1b_istek_veri_w;
   wire                    io_vyd_l1b_istek_yaz_w;
   wire                    io_vyd_l1b_istek_hazir_w;
   wire [`L1_BLOK_BIT-1:0] io_vyd_l1b_veri_w;
   wire                    io_vyd_l1b_veri_gecerli_w;
   wire                    io_vyd_l1b_veri_hazir_w;
   wire [  `ADRES_BIT-1:0] io_vyd_l1v_istek_adres_w;
   wire                    io_vyd_l1v_istek_gecerli_w;
   wire [`L1_BLOK_BIT-1:0] io_vyd_l1v_istek_veri_w;
   wire                    io_vyd_l1v_istek_yaz_w;
   wire                    io_vyd_l1v_istek_hazir_w;
   wire [`L1_BLOK_BIT-1:0] io_vyd_l1v_veri_w;
   wire                    io_vyd_l1v_veri_gecerli_w;
   wire                    io_vyd_l1v_veri_hazir_w;

   veri_yolu_denetleyici vyd (
      .clk_i                   (io_vyd_clk_w),
      .rstn_i                  (io_vyd_rstn_w),
      .mem_istek_adres_o       (io_vyd_mem_istek_adres_w),
      .mem_istek_veri_o        (io_vyd_mem_istek_veri_w),
      .mem_istek_yaz_o         (io_vyd_mem_istek_yaz_w),
      .mem_istek_gecerli_o     (io_vyd_mem_istek_gecerli_w),
      .mem_istek_hazir_i       (io_vyd_mem_istek_hazir_w),
      .mem_veri_i              (io_vyd_mem_veri_w),
      .mem_veri_gecerli_i      (io_vyd_mem_veri_gecerli_w),
      .mem_veri_hazir_o        (io_vyd_mem_veri_hazir_w),
      .l1b_istek_adres_i       (io_vyd_l1b_istek_adres_w),
      .l1b_istek_gecerli_i     (io_vyd_l1b_istek_gecerli_w),
      .l1b_istek_veri_i        (io_vyd_l1b_istek_veri_w),
      .l1b_istek_yaz_i         (io_vyd_l1b_istek_yaz_w),
      .l1b_istek_hazir_o       (io_vyd_l1b_istek_hazir_w),
      .l1b_veri_o              (io_vyd_l1b_veri_w),
      .l1b_veri_gecerli_o      (io_vyd_l1b_veri_gecerli_w),
      .l1b_veri_hazir_i        (io_vyd_l1b_veri_hazir_w),
      .l1v_istek_adres_i       (io_vyd_l1v_istek_adres_w),
      .l1v_istek_gecerli_i     (io_vyd_l1v_istek_gecerli_w),
      .l1v_istek_onbellekleme_i(io_vyd_l1v_istek_onbellekleme_w),
      .l1v_istek_veri_i        (io_vyd_l1v_istek_veri_w),
      .l1v_istek_yaz_i         (io_vyd_l1v_istek_yaz_w),
      .l1v_istek_hazir_o       (io_vyd_l1v_istek_hazir_w),
      .l1v_veri_o              (io_vyd_l1v_veri_w),
      .l1v_veri_gecerli_o      (io_vyd_l1v_veri_gecerli_w),
      .l1v_veri_hazir_i        (io_vyd_l1v_veri_hazir_w)
   );

   // ---- SPI Denetleyicisi ----
   wire                  io_spid_clk_w;
   wire                  io_spid_rstn_w;
   wire [`ADRES_BIT-1:0] io_spid_cek_adres_w;
   wire [ `VERI_BIT-1:0] io_spid_cek_veri_w;
   wire [`TL_A_BITS-1:0] io_spid_cek_tilefields_w;
   wire                  io_spid_cek_gecerli_w;
   wire                  io_spid_cek_hazir_w;
   wire [ `VERI_BIT-1:0] io_spid_spi_veri_w;
   wire                  io_spid_spi_gecerli_w;
   wire [`TL_D_BITS-1:0] io_spid_spi_tilefields_w;
   wire                  io_spid_spi_hazir_w;
   wire                  io_spid_miso_w;
   wire                  io_spid_mosi_w;
   wire                  io_spid_csn_w;
   wire                  io_spid_sck_w;

/*
   spi_denetleyici spid (
      .clk_i           (io_spid_clk_w),
      .rstn_i          (io_spid_rstn_w),
      .cek_adres_i     (io_spid_cek_adres_w),
      .cek_veri_i      (io_spid_cek_veri_w),
      .cek_tilefields_i(io_spid_cek_tilefields_w),
      .cek_gecerli_i   (io_spid_cek_gecerli_w),
      .cek_hazir_o     (io_spid_cek_hazir_w),
      .spi_veri_o      (io_spid_spi_veri_w),
      .spi_tilefields_o(io_spid_spi_tilefields_w),
      .spi_gecerli_o   (io_spid_spi_gecerli_w),
      .spi_hazir_i     (io_spid_spi_hazir_w),
      .miso_i          (io_spid_miso_w),
      .mosi_o          (io_spid_mosi_w),
      .csn_o           (io_spid_csn_w),
      .sck_o           (io_spid_sck_w)
   );
   */

   // ---- UART Denetleyicisi ----
   wire                  io_uartd_clk_w;
   wire                  io_uartd_rstn_w;
   wire [`ADRES_BIT-1:0] io_uartd_cek_adres_w;
   wire [ `VERI_BIT-1:0] io_uartd_cek_veri_w;
   wire [`TL_A_BITS-1:0] io_uartd_cek_tilefields_w;
   wire                  io_uartd_cek_gecerli_w;
   wire                  io_uartd_cek_hazir_w;
   wire [ `VERI_BIT-1:0] io_uartd_uart_veri_w;
   wire                  io_uartd_uart_gecerli_w;
   wire [`TL_D_BITS-1:0] io_uartd_uart_tilefields_w;
   wire                  io_uartd_uart_hazir_w;
   wire                  io_uartd_rx_w;
   wire                  io_uartd_tx_w;

   uart_denetleyicisi uartd (
      .clk_i            (io_uartd_clk_w),
      .rstn_i           (io_uartd_rstn_w),
      .cek_adres_i      (io_uartd_cek_adres_w),
      .cek_veri_i       (io_uartd_cek_veri_w),
      .cek_tilefields_i (io_uartd_cek_tilefields_w),
      .cek_gecerli_i    (io_uartd_cek_gecerli_w),
      .cek_hazir_o      (io_uartd_cek_hazir_w),
      .uart_veri_o      (io_uartd_uart_veri_w),
      .uart_gecerli_o   (io_uartd_uart_gecerli_w),
      .uart_tilefields_o(io_uartd_uart_tilefields_w),
      .uart_hazir_i     (io_uartd_uart_hazir_w),
      .rx_i             (io_uartd_rx_w),
      .tx_o             (io_uartd_tx_w)
   );

   // ---- PWM Denetleyicisi ----
   wire                  io_pwmd_clk_w;
   wire                  io_pwmd_rstn_w;
   wire [`ADRES_BIT-1:0] io_pwmd_cek_adres_w;
   wire [ `VERI_BIT-1:0] io_pwmd_cek_veri_w;
   wire [`TL_A_BITS-1:0] io_pwmd_cek_tilefields_w;
   wire                  io_pwmd_cek_gecerli_w;
   wire                  io_pwmd_cek_hazir_w;
   wire [ `VERI_BIT-1:0] io_pwmd_pwm_veri_w;
   wire                  io_pwmd_pwm_gecerli_w;
   wire [`TL_D_BITS-1:0] io_pwmd_pwm_tilefields_w;
   wire                  io_pwmd_pwm_hazir_w;
   wire                  io_pwmd_o1_w;
   wire                  io_pwmd_o2_w;

/*
   pwm_denetleyici pwmd (
      .clk_i           (io_pwmd_clk_w),
      .rstn_i          (io_pwmd_rstn_w),
      .cek_adres_i     (io_pwmd_cek_adres_w),
      .cek_veri_i      (io_pwmd_cek_veri_w),
      .cek_tilefields_i(io_pwmd_cek_tilefields_w),
      .cek_gecerli_i   (io_pwmd_cek_gecerli_w),
      .cek_hazir_o     (io_pwmd_cek_hazir_w),
      .pwm_veri_o      (io_pwmd_pwm_veri_w),
      .pwm_gecerli_o   (io_pwmd_pwm_gecerli_w),
      .pwm_tilefields_o(io_pwmd_pwm_tilefields_w),
      .pwm_hazir_i     (io_pwmd_pwm_hazir_w),
      .o1              (io_pwmd_o1_w),
      .o2              (io_pwmd_o2_w)
   );
   */

   // Cekirdek < Sistem
   assign io_cek_clk_w = clk;
   assign io_cek_rstn_w = resetn;

   // L1BD < Sistem
   assign io_l1bd_clk_w = clk;
   assign io_l1bd_rstn_w = resetn;

   // L1BV < Sistem
   assign io_l1bv_clk_w = clk;

   // L1VD < Sistem
   assign io_l1vd_clk_w = clk;
   assign io_l1vd_rstn_w = resetn;

   // L1VV < Sistem
   assign io_l1vv_clk_w = clk;

   // Veri yolu denetleyicisi < Sistem
   assign io_vyd_clk_w = clk;
   assign io_vyd_rstn_w = resetn;

   // SPI Denetleyicisi < Sistem
   assign io_spid_clk_w = clk;
   assign io_spid_rstn_w = resetn;

   // UART Denetleyicisi < Sistem
   assign io_uartd_clk_w = clk;
   assign io_uartd_rstn_w = resetn;

   // PWM Denetleyicisi < Sistem
   assign io_pwmd_clk_w = clk;
   assign io_pwmd_rstn_w = resetn;

   // Cekirdek < L1BD
   assign io_cek_buyruk_yanit_veri_w = io_l1bd_port_veri_w;
   assign io_cek_buyruk_yanit_gecerli_w = io_l1bd_port_veri_gecerli_w;
   assign io_cek_buyruk_istek_hazir_w = io_l1bd_port_istek_hazir_w;

   // L1BD < Cekirdek
   assign io_l1bd_port_istek_adres_w = io_cek_buyruk_istek_adres_w;
   assign io_l1bd_port_istek_gecerli_w = io_cek_buyruk_istek_gecerli_w;
   assign io_l1bd_port_istek_yaz_w = `LOW;  // Getir asla yazmaz
   assign io_l1bd_port_istek_veri_w = {`L1_BLOK_BIT{1'b0}};  // Getir asla yazmaz
   assign io_l1bd_port_veri_hazir_w = io_cek_buyruk_yanit_hazir_w;

   // Cekirdek < L1VD
   assign io_cek_l1vd_yanit_veri_w = io_l1vd_port_veri_w;
   assign io_cek_l1vd_yanit_gecerli_w = io_l1vd_port_veri_gecerli_w;
   assign io_cek_l1vd_istek_hazir_w = io_l1vd_port_istek_hazir_w;

   // L1BD < L1BV Okuma / Yazma Gecikmesi
   reg  [`L1_ONBELLEK_GECIKME-1:0] io_sistem_l1bv_istek_r;
   wire                            io_sistem_l1bv_gecerli_w;

   always @(posedge io_l1bd_clk_w) begin
      if (!resetn) begin
         io_sistem_l1bv_istek_r <= {`L1_ONBELLEK_GECIKME{1'b0}};
      end else begin
         if (`L1_ONBELLEK_GECIKME > 1) begin
            io_sistem_l1bv_istek_r <= {
               io_sistem_l1bv_istek_r[`L1_ONBELLEK_GECIKME-2:0],
               (!io_l1bd_l1_istek_gecersiz_w && !(|io_l1bd_l1_istek_yaz_w))
            };
         end else begin
            io_sistem_l1bv_istek_r <= (!io_l1bd_l1_istek_gecersiz_w && !(|io_l1bd_l1_istek_yaz_w));
         end
      end
   end
   assign io_sistem_l1bv_gecerli_w  = io_sistem_l1bv_istek_r[`L1_ONBELLEK_GECIKME-1];

   // L1BD < L1BV
   assign io_l1bd_l1_veri_gecerli_w = io_sistem_l1bv_gecerli_w;

   generate
      for (i = 0; i < `L1B_YOL; i = i + 1) begin
         assign io_l1bd_l1_veri_etiket_w[i * `ADRES_ETIKET_BIT +: `ADRES_ETIKET_BIT] = io_l1bv_oku_etiket_bw[i];
         assign io_l1bd_l1_veri_blok_w[i*`L1_BLOK_BIT+:`L1_BLOK_BIT] = io_l1bv_oku_blok_bw[i];
      end
   endgenerate

   // L1BV < L1BD
   assign io_l1bv_komut_gecerli_w = !io_l1bd_l1_istek_gecersiz_w;
   assign io_l1bv_komut_adres_w = io_l1bd_l1_istek_satir_w;
   assign io_l1bv_komut_yaz_w = io_l1bd_l1_istek_yaz_w;

   generate
      for (i = 0; i < `L1B_YOL; i = i + 1) begin
         assign io_l1bv_yaz_etiket_bw[i] = io_l1bd_l1_istek_etiket_w[i * `ADRES_ETIKET_BIT +: `ADRES_ETIKET_BIT];
         assign io_l1bv_yaz_blok_bw[i] = io_l1bd_l1_istek_blok_w[i*`L1_BLOK_BIT+:`L1_BLOK_BIT];
      end
   endgenerate

   // L1VD < Cekirdek
   assign io_l1vd_port_istek_adres_w = io_cek_l1vd_istek_adres_w;
   assign io_l1vd_port_istek_gecerli_w = io_cek_l1vd_istek_gecerli_w;
   assign io_l1vd_port_istek_onbellekleme_w = io_cek_l1vd_istek_onbellekleme_w;
   assign io_l1vd_port_istek_yaz_w = io_cek_l1vd_istek_yaz_w;
   assign io_l1vd_port_istek_veri_w = io_cek_l1vd_istek_veri_w;
   assign io_l1vd_port_istek_maske_w = io_cek_l1vd_istek_maske_w;
   assign io_l1vd_port_veri_hazir_w = io_cek_l1vd_yanit_hazir_w;

   // L1VD < L1VV Okuma / Yazma Gecikmesi
   reg  [`L1_ONBELLEK_GECIKME-1:0] io_sistem_l1vv_istek_r;
   wire                            io_sistem_l1vv_gecerli_w;

   always @(posedge io_l1vd_clk_w) begin
      if (!resetn) begin
         io_sistem_l1vv_istek_r <= {`L1_ONBELLEK_GECIKME{1'b0}};
      end else begin
         if (`L1_ONBELLEK_GECIKME > 1) begin
            io_sistem_l1vv_istek_r <= {
               io_sistem_l1vv_istek_r[`L1_ONBELLEK_GECIKME-2:0],
               (!io_l1vd_l1_istek_gecersiz_w && !(|io_l1vd_l1_istek_yaz_w))
            };
         end else begin
            io_sistem_l1vv_istek_r <= (!io_l1vd_l1_istek_gecersiz_w && !(|io_l1vd_l1_istek_yaz_w));
         end
      end
   end
   assign io_sistem_l1vv_gecerli_w  = io_sistem_l1vv_istek_r[`L1_ONBELLEK_GECIKME-1];

   // L1VD < L1VV
   assign io_l1vd_l1_veri_gecerli_w = io_sistem_l1vv_gecerli_w;

   generate
      for (i = 0; i < `L1V_YOL; i = i + 1) begin
         assign io_l1vd_l1_veri_etiket_w[i * `ADRES_ETIKET_BIT +: `ADRES_ETIKET_BIT] = io_l1vv_oku_etiket_bw[i];
         assign io_l1vd_l1_veri_blok_w[i*`L1_BLOK_BIT+:`L1_BLOK_BIT] = io_l1vv_oku_blok_bw[i];
      end
   endgenerate

   // L1VV < L1VD
   assign io_l1vv_komut_gecerli_w = !io_l1vd_l1_istek_gecersiz_w;
   assign io_l1vv_komut_adres_w = io_l1vd_l1_istek_satir_w;
   assign io_l1vv_komut_yaz_w = io_l1vd_l1_istek_yaz_w;

   generate
      for (i = 0; i < `L1V_YOL; i = i + 1) begin
         assign io_l1vv_yaz_etiket_bw[i] = io_l1vd_l1_istek_etiket_w[i * `ADRES_ETIKET_BIT +: `ADRES_ETIKET_BIT];
         assign io_l1vv_yaz_blok_bw[i] = io_l1vd_l1_istek_blok_w[i*`L1_BLOK_BIT+:`L1_BLOK_BIT];
      end
   endgenerate

   // L1BD < Veri Yolu Denetleyicisi
   assign io_l1bd_vy_istek_hazir_w = io_vyd_l1b_istek_hazir_w;
   assign io_l1bd_vy_veri_w = io_vyd_l1b_veri_w;
   assign io_l1bd_vy_veri_gecerli_w = io_vyd_l1b_veri_gecerli_w;

   // Veri Yolu Denetleyicisi < L1BD
   assign io_vyd_l1b_istek_adres_w = io_l1bd_vy_istek_adres_w;
   assign io_vyd_l1b_istek_gecerli_w = io_l1bd_vy_istek_gecerli_w;
   assign io_vyd_l1b_istek_veri_w = io_l1bd_vy_istek_veri_w;
   assign io_vyd_l1b_istek_yaz_w = io_l1bd_vy_istek_yaz_w;
   assign io_vyd_l1b_veri_hazir_w = io_l1bd_vy_veri_hazir_w;

   // L1VD < Veri Yolu Denetleyicisi
   assign io_l1vd_vy_istek_hazir_w = io_vyd_l1v_istek_hazir_w;
   assign io_l1vd_vy_veri_w = io_vyd_l1v_veri_w;
   assign io_l1vd_vy_veri_gecerli_w = io_vyd_l1v_veri_gecerli_w;

   // Veri Yolu Denetleyicisi < L1VD
   assign io_vyd_l1v_istek_adres_w = io_l1vd_vy_istek_adres_w;
   assign io_vyd_l1v_istek_gecerli_w = io_l1vd_vy_istek_gecerli_w;
   assign io_vyd_l1v_istek_onbellekleme_w = io_l1vd_vy_istek_onbellekleme_w;
   assign io_vyd_l1v_istek_veri_w = io_l1vd_vy_istek_veri_w;
   assign io_vyd_l1v_istek_yaz_w = io_l1vd_vy_istek_yaz_w;
   assign io_vyd_l1v_veri_hazir_w = io_l1vd_vy_veri_hazir_w;

   // Sistem Veri Yolu < Veri Yolu Denetleyicisi
   assign iomem_wdata = io_vyd_mem_istek_veri_w;
   assign iomem_valid = io_vyd_mem_istek_gecerli_w;
   assign iomem_addr = io_vyd_mem_istek_adres_w;
   generate
      for (i = 0; i < `VERI_BYTE; i = i + 1) begin
         assign iomem_wstrb[i] = io_vyd_mem_istek_yaz_w;
      end
   endgenerate

   // Veri Yolu Denetleyicisi < Sistem Veri Yolu Istek Hazir / Veri Gecerli
   reg bellek_istek_bosta;
   reg bellek_oku_istek;
   reg bellek_veri_gecerli;
   reg [31:0] bellek_veri;

   always @(posedge clk) begin
      if (!resetn) begin
         bellek_istek_bosta <= 1'b1;
         bellek_oku_istek   <= 1'b0;
      end else begin
         if (bellek_istek_bosta && io_vyd_mem_istek_gecerli_w) begin
            bellek_istek_bosta <= 1'b0;
            bellek_oku_istek   <= !io_vyd_mem_istek_yaz_w;
         end
         if (io_vyd_mem_istek_hazir_w) begin
            bellek_istek_bosta <= 1'b1;
         end
      end
   end

   always @* begin
      bellek_veri = 0;
      bellek_veri_gecerli = `LOW;
      if (bellek_oku_istek && iomem_ready) begin
         bellek_veri = iomem_rdata;
         bellek_veri_gecerli = `HIGH;
      end else if (io_spid_spi_gecerli_w && io_spid_spi_tilefields_w[`TL_D_OP] != `TL_OP_ACK) begin
         bellek_veri = io_spid_spi_veri_w;
         bellek_veri_gecerli = `HIGH;
      end
   else if (io_uartd_uart_gecerli_w && io_uartd_uart_tilefields_w[`TL_D_OP] != `TL_OP_ACK) begin
         bellek_veri = io_uartd_uart_veri_w;
         bellek_veri_gecerli = `HIGH;
      end else if (io_pwmd_pwm_gecerli_w && io_pwmd_pwm_tilefields_w[`TL_D_OP] != `TL_OP_ACK) begin
         bellek_veri = io_pwmd_pwm_veri_w;
         bellek_veri_gecerli = `HIGH;
      end
   end

   // Veri Yolu Denetleyicisi < Sistem Veri Yolu
   assign io_vyd_mem_istek_hazir_w = (io_vyd_mem_istek_adres_w & ~`RAM_MASK_ADDR) == `RAM_BASE_ADDR ? iomem_ready :
                          (io_vyd_mem_istek_adres_w & ~`TIMER_MASK_ADDR) == `TIMER_BASE_ADDR ? iomem_ready :
                          (io_vyd_mem_istek_adres_w & ~`SPI_MASK_ADDR) == `SPI_BASE_ADDR ? io_spid_cek_hazir_w :
                          (io_vyd_mem_istek_adres_w & ~`UART_MASK_ADDR) == `UART_BASE_ADDR ? io_uartd_cek_hazir_w :
                          (io_vyd_mem_istek_adres_w & ~`PWM_MASK_ADDR) == `PWM_BASE_ADDR ? io_pwmd_cek_hazir_w : `LOW;

   assign io_vyd_mem_veri_w = bellek_veri;
   assign io_vyd_mem_veri_gecerli_w = bellek_veri_gecerli;

   // SPI Denetleyici < Veri Yolu Denetleyicisi
   assign io_spid_cek_adres_w = io_vyd_mem_istek_adres_w;
   assign io_spid_cek_veri_w = io_vyd_mem_istek_veri_w;
   assign io_spid_cek_tilefields_w = io_vyd_mem_istek_yaz_w ? `TL_REQ_A_PUTF : `TL_REQ_A_GET;
   assign io_spid_cek_gecerli_w = io_vyd_mem_istek_gecerli_w;
   assign io_spid_spi_hazir_w = io_vyd_mem_veri_hazir_w;

   // UART Denetleyici < Veri Yolu Denetleyicisi
   assign io_uartd_cek_adres_w = io_vyd_mem_istek_adres_w;
   assign io_uartd_cek_veri_w = io_vyd_mem_istek_veri_w;
   assign io_uartd_cek_tilefields_w = io_vyd_mem_istek_yaz_w ? `TL_REQ_A_PUTF : `TL_REQ_A_GET;
   assign io_uartd_cek_gecerli_w = io_vyd_mem_istek_gecerli_w;
   assign io_uartd_uart_hazir_w = io_vyd_mem_veri_hazir_w;

   // PWM Denetleyici < Veri Yolu Denetleyicisi
   assign io_pwmd_cek_adres_w = io_vyd_mem_istek_adres_w;
   assign io_pwmd_cek_veri_w = io_vyd_mem_istek_veri_w;
   assign io_pwmd_cek_tilefields_w = io_vyd_mem_istek_yaz_w ? `TL_REQ_A_PUTF : `TL_REQ_A_GET;
   assign io_pwmd_cek_gecerli_w = io_vyd_mem_istek_gecerli_w;
   assign io_pwmd_pwm_hazir_w = io_vyd_mem_veri_hazir_w;


   // ---- Cekirdek <> Cevre Birimleri ----
   /*
   assign spi_cs_o = io_spid_csn_w;
   assign spi_sck_o = io_spid_sck_w;
   assign spi_mosi_o = io_spid_mosi_w;
   assign io_spid_miso_w = spi_miso_i;
   */
   
   assign io_uartd_rx_w = uart_rx_i;

   assign uart_tx_o = io_uartd_tx_w;
   /*
   assign pwm0_o = io_pwmd_o1_w;
   assign pwm1_o = io_pwmd_o2_w;
   */

endmodule
