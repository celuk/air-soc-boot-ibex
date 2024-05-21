// air_soc.sv
`timescale 1ns / 1ps

`include "header.vh"

module air_soc (
    input wire clk_i,
    input wire rst_ni,
    
    output wire        iomem_valid,
    input  wire        iomem_ready,
    output wire [ 3:0] iomem_wstrb,
    output wire [31:0] iomem_addr,
    output wire [31:0] iomem_wdata,
    input  wire [31:0] iomem_rdata,
    
    output wire uart_tx_o,
    input  wire uart_rx_i
    
    /*
    output wire       qspi_cs_o,
    output wire       qspi_sck_o,
    output wire [3:0] qspi_mosi_o,
    input  wire [3:0] qspi_miso_i,

    input  wire sda_i,
    output wire sda_o,
    input  wire scl_i,
    output wire scl_o,

    input  wire [15:0] gpio_i,
    output wire [15:0] gpio_o
    */
);

wire       qspi_cs_o;
wire       qspi_sck_o;
wire [3:0] qspi_mosi_o;
reg [3:0] qspi_miso_i = 4'h0;
reg sda_i = 1'b0;
wire sda_o;
reg scl_i = 1'b0;
wire scl_o;
reg [15:0] gpio_i = 16'h0;
wire [15:0] gpio_o;

wire        yol0_EN0;
wire        yol1_EN0;
wire [ 7:0] yol_A0 ;
wire [40:0] yol_Di0;
wire [40:0] yol0_Do0;
wire [40:0] yol1_Do0;
wire [ 3:0] yol_WE0;

wire lru_din;
wire lru_ddo;
wire yol0_valid_din;
wire yol0_valid_ddo;
wire yol0_dirty_din;
wire yol0_dirty_ddo;
wire yol1_valid_din;
wire yol1_valid_ddo;
wire yol1_dirty_din;
wire yol1_dirty_ddo;

wire  we0;
wire [7:0] adr0;
wire [7:0] datai0;
wire [7:0] datao0;

wire  we1;
wire [7:0] adr1;
wire [7:0] datai1;
wire [7:0] datao1;

wire        ram512d0_we0;
wire [ 8:0] ram512d0_adr0;
wire [15:0] ram512d0_datai0;
wire [15:0] ram512d0_datao0;

wire        ram512d1_we0;
wire [ 8:0] ram512d1_adr0;
wire [15:0] ram512d1_datai0;
wire [15:0] ram512d1_datao0;

wire [7:0] l1b_tag_adr;,

wire rst_i = ~rst_ni;

wire [31:0] mpu_wr_data;
wire [31:0] mpu_rd_data;
wire [31:0] mpu_addr;
wire [ 3:0] mpu_mask;
wire        mpu_stall;
wire        mpu_req;

wire        l1i_wait;
wire [31:0] l1i_val;
wire [18:1] l1i_addr;

assign l1b_tag_adr = l1i_addr[18:11];

wire [31:0] l1d_rd_data;
wire        l1d_sel;
wire        l1d_stall;

wire [31:0] dp_rd_data;
wire        dp_sel;
wire        dp_stall;

wire [31:0] tmr_rd_data;
wire        tmr_sel;

wire        l1d_iomem_valid;
wire        l1d_iomem_ready;
wire [ 3:0] l1d_iomem_wstrb;
wire [18:2] l1d_iomem_addr;
wire [31:0] l1d_iomem_wdata;
wire [31:0] l1d_iomem_rdata;

wire        l1i_iomem_valid;
wire        l1i_iomem_ready;
wire [18:2] l1i_iomem_addr;
wire [31:0] l1i_iomem_rdata;

/*
cekirdek cek (
   .clk_i (clk_i),
   .rst_i (rst_i),
   //
   .l1b_bekle_i        (l1b_bekle          ),
   .l1b_deger_i        (l1b_deger          ),
   .l1b_adres_o        (l1b_adres          ),
   //
   .bib_veri_i       (bib_oku_veri     ),
   .bib_durdur_i     (bib_durdur       ),
   .bib_veri_o       (bib_yaz_veri     ),
   .bib_adr_o        (bib_adr          ),
   .bib_veri_maske_o (bib_mask         ),
   .bib_sec_o        (bib_sec          )
);
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
    .clk_i                    (clk_i),
    .rst_ni                   (rst_ni),

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
    .instr_req_o              (),
    .instr_gnt_i              (~l1i_wait),
    .instr_rvalid_i           (1'b1),
    .instr_addr_o             (l1i_addr),
    .instr_rdata_i            (l1i_val),

    // TODO: Always valid?
    // Data memory interface
    .data_req_o               (mpu_req),
    .data_gnt_i               (~mpu_stall),
    .data_rvalid_i            (1'b1),
    .data_we_o                (data_we_o),
    .data_be_o                (mpu_mask),
    .data_addr_o              (mpu_addr),
    .data_wdata_o             (mpu_wr_data),
    .data_rdata_i             (mpu_rd_data),

    // Interrupt interface
    .irq_i                    (32'h0),
    .irq_ack_o                (),
    .irq_id_o                 (),

    // TODO: JTAG Integration
    // Debug interface
    .debug_req_i              (1'b0),
    .debug_havereset_o        (),
    .debug_running_o          (),
    .debug_halted_o           ()

    // TODO
    // CPU Control Signals
    .fetch_enable_i           (1'b1),
    .core_sleep_o             ()
);

icache_controller icache_controller_dut (
   .clk_i (clk_i ),
   .rst_i (rst_i ),
   
   .iomem_valid   (l1i_iomem_valid),
   .iomem_ready   (l1i_iomem_ready),
   .iomem_addr    (l1i_iomem_addr ),
   .iomem_rdata   (l1i_iomem_rdata),

   .l1i_wait_o   (l1i_wait),
   .l1i_val_o   (l1i_val),
   .l1i_addr_i   (l1i_addr),
   
   .we0_o    (we0    ),
   .adr0_o   (adr0   ),
   .datao0_i (datao0 ),
   
   .we1_o    (we1    ),
   .adr1_o   (adr1   ),
   .datao1_i (datao1 ),
   
   .ram512d0_we0_o    (ram512d0_we0    ),
   .ram512d0_adr0_o   (ram512d0_adr0   ),
   .ram512d0_datao0_i (ram512d0_datao0 ),
   
   .ram512d1_we0_o    (ram512d1_we0    ),
   .ram512d1_adr0_o   (ram512d1_adr0   ),
   .ram512d1_datao0_i (ram512d1_datao0 )
);

assign l1d_sel = mpu_addr[30]                ? mpu_req : 1'b0;
assign dp_sel  = mpu_addr[29]&&~mpu_addr[28] ? mpu_req : 1'b0;
assign tmr_sel = mpu_addr[28]                ? mpu_req : 1'b0;

assign mpu_stall = mpu_addr[30] ? l1d_stall :
                   mpu_addr[28] ? 1'b0      :
                                  dp_stall  ;

assign mpu_rd_data  = mpu_addr[30] ? l1d_rd_data :
                      mpu_addr[28] ? tmr_rd_data :
                                     dp_rd_data  ;

dcache_controller dcache_controller_dut (
   .clk_i (clk_i ),
   .rst_i (rst_i ),
   
   .l1d_data_o      (l1d_rd_data   ),
   .l1d_stall_o     (l1d_stall     ),
   .l1d_data_i      (mpu_wr_data   ),
   .l1d_addr_i      (mpu_addr[18:2]),
   .l1d_data_mask_i (mpu_mask      ),
   .l1d_sel_i       (l1d_sel       ),

   .iomem_ready_i (l1d_iomem_ready ),
   .iomem_valid_o (l1d_iomem_valid ),
   .iomem_wstrb_o (l1d_iomem_wstrb ),
   .iomem_addr_o  (l1d_iomem_addr  ),
   .iomem_wdata_o (l1d_iomem_wdata ),
   .iomem_rdata_i (l1d_iomem_rdata ),
   
   .yol0_EN0 (yol0_EN0 ),
   .yol1_EN0 (yol1_EN0 ),
   .yol_A0   (yol_A0   ),
   .yol_Di0  (yol_Di0  ),
   .yol0_Do0 (yol0_Do0 ),
   .yol1_Do0 (yol1_Do0 ),
   .yol_WE0  (yol_WE0  ),
   
   .lru_i (lru_din ),
   .lru_o (lru_ddo ),
   .yol0_valid_i (yol0_valid_din ),
   .yol0_valid_o (yol0_valid_ddo ),
   .yol0_dirty_i (yol0_dirty_din ),
   .yol0_dirty_o (yol0_dirty_ddo ),
   .yol1_valid_i (yol1_valid_din ),
   .yol1_valid_o (yol1_valid_ddo ),
   .yol1_dirty_i (yol1_dirty_din ),
   .yol1_dirty_o  ( yol1_dirty_ddo)
);

main_memory_controller main_memory_controller_dut (
   .clk_i (clk_i ),
   .rst_i (rst_i ),
   
   .iomem_valid (iomem_valid ),
   .iomem_ready (iomem_ready ),
   .iomem_wstrb (iomem_wstrb ),
   .iomem_addr  (iomem_addr  ),
   .iomem_wdata (iomem_wdata ),
   .iomem_rdata (iomem_rdata ),

   .timer_iomem_valid (tmr_sel    ),
   .timer_iomem_addr  (mpu_addr   ),
   .timer_iomem_rdata (tmr_rd_data),

   .l1i_iomem_valid (l1i_iomem_valid ),
   .l1i_iomem_ready (l1i_iomem_ready ),
   .l1i_iomem_addr  (l1i_iomem_addr  ),
   .l1i_iomem_rdata (l1i_iomem_rdata ),

   .l1d_iomem_valid (l1d_iomem_valid ),
   .l1d_iomem_ready (l1d_iomem_ready ),
   .l1d_iomem_wstrb (l1d_iomem_wstrb ),
   .l1d_iomem_addr  (l1d_iomem_addr  ),
   .l1d_iomem_wdata (l1d_iomem_wdata ),
   .l1d_iomem_rdata (l1d_iomem_rdata )
);

datapath  datapath_dut (
    .clk_i (clk_i ),
    .rst_i (rst_i ),
    .dp_data_o        (dp_rd_data     ),
    .dp_stall_o       (dp_stall       ),
    .dp_data_i        (mpu_wr_data    ),
    .dp_addr_i        (mpu_addr       ),
    .dp_data_mask_i   (mpu_mask       ),
    .dp_sel_i         (dp_sel         ),

    .uart_tx_o  (uart_tx_o ),
    .uart_rx_i  (uart_rx_i ),

    .qspi_cs_o   (qspi_cs_o   ),
    .qspi_sck_o  (qspi_sck_o  ),
    .qspi_mosi_o (qspi_mosi_o ),
    .qspi_miso_i (qspi_miso_i ),

    .sda_i (sda_i),
    .sda_o (sda_o),
    .scl_i (scl_i),
    .scl_o (scl_o),

    .gpio_i (gpio_i),
    .gpio_o (gpio_o)
);

RAM512x16_ASYNC`GATE RAM512_d0 (
   .CLK(clk),
   .A0(ram512d0_adr0),
   .Di0(iomem_rdata[15:0]),
   .Do0(ram512d0_datao0),
   .WE0({ram512d0_we0,ram512d0_we0})
);

RAM512x16_ASYNC`GATE RAM512_d1 (
   .CLK(clk),
   .A0(ram512d1_adr0),
   .Di0(iomem_rdata[31:16]),
   .Do0(ram512d1_datao0),
   .WE0({ram512d1_we0,ram512d1_we0})
);

RAM256x8_ASYNC`GATE bffram_t0( // even
   .CLK(clk),
   .A0(adr0),
   .Di0(l1b_tag_adr),
   .Do0(datao0),
   .WE0(we0)
);

RAM256x8_ASYNC`GATE bffram_t1( // odd
   .CLK(clk),
   .A0(adr1),
   .Di0(l1b_tag_adr),
   .Do0(datao1),
   .WE0(we1)
);

RAM256x8_ASYNC`GATE vffram_t0_0(
   .CLK(clk),
   .A0 (yol_A0  ),
   .Di0(yol_Di0 [39:32]),
   .Do0(yol0_Do0[39:32]),
   .WE0(yol0_EN0)
);

RAM256x8_ASYNC`GATE vffram_t1_0(
   .CLK(clk),
   .A0 (yol_A0  ),
   .Di0(yol_Di0 [39:32]),
   .Do0(yol1_Do0[39:32]),
   .WE0(yol1_EN0)
);


RAM256x16_ASYNC`GATE vffram_d0_0(
   .CLK(clk),
   .A0 (yol_A0  ),
   .Di0(yol_Di0 [15:0]),
   .Do0(yol0_Do0[15:0]),
   .WE0(yol_WE0[1:0] & {yol0_EN0,yol0_EN0})
);

RAM256x16_ASYNC`GATE vffram_d0_1(
   .CLK(clk),
   .A0 (yol_A0  ),
   .Di0(yol_Di0 [31:16]),
   .Do0(yol0_Do0[31:16]),
   .WE0(yol_WE0[3:2] & {yol0_EN0,yol0_EN0})
);

RAM256x16_ASYNC`GATE vffram_d1_0(
   .CLK(clk),
   .A0 (yol_A0  ),
   .Di0(yol_Di0 [15:0]),
   .Do0(yol1_Do0[15:0]),
   .WE0(yol_WE0[1:0] & {yol1_EN0,yol1_EN0})
);

RAM256x16_ASYNC`GATE vffram_d1_1(
   .CLK(clk),
   .A0 (yol_A0  ),
   .Di0(yol_Di0 [31:16]),
   .Do0(yol1_Do0[31:16]),
   .WE0(yol_WE0[3:2] & {yol1_EN0,yol1_EN0})
);

// t1_d1_v1_x_lru_t0_d0_v0
wire [7:0] combined_data_yeni;
wire [7:0] combined_data_okunan;

assign combined_data_yeni[0] =  yol0_EN0             ? yol0_valid_ddo : combined_data_okunan[0];
assign combined_data_yeni[1] =  yol0_EN0             ? yol0_dirty_ddo : combined_data_okunan[1];
assign combined_data_yeni[2] =  yol0_EN0             ? yol_Di0 [40]   : combined_data_okunan[2];
assign combined_data_yeni[3] = (yol0_EN0 | yol1_EN0) ? lru_ddo        : combined_data_okunan[3];
assign combined_data_yeni[4] = 1'bx;
assign combined_data_yeni[5] =  yol1_EN0             ? yol1_valid_ddo : combined_data_okunan[5];
assign combined_data_yeni[6] =  yol1_EN0             ? yol1_dirty_ddo : combined_data_okunan[6];
assign combined_data_yeni[7] =  yol1_EN0             ? yol_Di0 [40]   : combined_data_okunan[7];

assign yol0_valid_din = combined_data_okunan[0];
assign yol0_dirty_din = combined_data_okunan[1];
assign yol0_Do0[40]   = combined_data_okunan[2];
assign lru_din        = combined_data_okunan[3];

assign yol1_valid_din = combined_data_okunan[5];
assign yol1_dirty_din = combined_data_okunan[6];
assign yol1_Do0[40]   = combined_data_okunan[7];


RAM256x8_ASYNC`GATE vffram_combined(
   .CLK(clk),
   .A0 (yol_A0  ),
   .Di0(combined_data_yeni),
   .Do0(combined_data_okunan),
   .WE0(yol0_EN0 | yol1_EN0)
);

endmodule
