// air_soc.sv
`timescale 1ns / 1ps
//
`default_nettype none

`include "header.vh"


module air_soc #(
   parameter int unsigned ICACHE_SZ     = 8192,  // instruction cache size in bytes
   parameter int unsigned ICACHE_LINE_W = 128,   // instruction cache line width in bits
   parameter int unsigned DCACHE_SZ     = 8192,  // data cache size in bytes
   parameter int unsigned DCACHE_LINE_W = 512    // data cache line width in bits
) (
   input wire clk_i,
   input wire rst_ni,

   output wire        mem_req_o,
   output wire [31:0] mem_addr_o,
   output wire        mem_we_o,
   output wire [ 3:0] mem_be_o,
   output wire [31:0] mem_wdata_o,
   input  wire        mem_rvalid_i,
   input  wire [31:0] mem_rdata_i,

   output wire        periph_req_o,
   output wire [31:0] periph_addr_o,
   output wire        periph_we_o,
   output wire [ 3:0] periph_be_o,
   output wire [31:0] periph_wdata_o,
   input  wire        periph_rvalid_i,
   input  wire [31:0] periph_rdata_i
);

   localparam int unsigned DCACHE_WAY_LEN = DCACHE_SZ / (DCACHE_LINE_W / 8) / 2;
   localparam int unsigned ICACHE_WAY_LEN = ICACHE_SZ / (ICACHE_LINE_W / 8) / 2;
   localparam PERIPH_BASE_ADR = 32'hFF00_0000;

   logic        core_data_req;
   logic [31:0] core_data_addr;
   logic        core_data_we;
   logic [ 3:0] core_data_be;
   logic [31:0] core_data_wdata;
   logic        core_data_gnt;
   logic        core_data_rvalid;
   logic [31:0] core_data_rdata;

   logic        core_instr_req;
   logic [31:0] core_instr_addr;
   logic        core_instr_gnt;
   logic        core_instr_rvalid;
   logic [31:0] core_instr_rdata;

   logic        core2dcache_data_req;
   logic [31:0] core2dcache_data_addr;
   logic        core2dcache_data_we;
   logic [ 3:0] core2dcache_data_be;
   logic [31:0] core2dcache_data_wdata;
   logic        core2dcache_data_gnt;
   logic        core2dcache_data_rvalid;
   logic [31:0] core2dcache_data_rdata;

   logic        dcache2mem_data_req;
   logic [31:0] dcache2mem_data_addr;
   logic        dcache2mem_data_we;
   // logic [ 3:0] dcache2mem_data_be;
   logic [31:0] dcache2mem_data_wdata;
   logic        dcache2mem_data_gnt;
   logic        dcache2mem_data_rvalid;
   logic [31:0] dcache2mem_data_rdata;

   logic        icache2mem_instr_req;
   logic [31:0] icache2mem_instr_addr;
   logic        icache2mem_instr_gnt;
   logic        icache2mem_instr_rvalid;
   logic [31:0] icache2mem_instr_rdata;

   typedef enum {
      IDLE,
      DCACHE,
      ICACHE
   } bus_state;

   bus_state switch;

   cv32e40p_top #(
      .FPU             (0),
      .FPU_ADDMUL_LAT  (0),
      .FPU_OTHERS_LAT  (0),
      .ZFINX           (0),
      .COREV_PULP      (0),
      .COREV_CLUSTER   (0),
      .NUM_MHPMCOUNTERS(1)
   ) u_core (
      // Clock and reset
      .rst_ni      (rst_ni),
      .clk_i       (clk_i),
      .scan_cg_en_i(1'b0),

      // Special control signals
      .fetch_enable_i (1'b1),
      .pulp_clock_en_i(1'b0),
      .core_sleep_o   (),

      // Configuration
      .boot_addr_i        (32'h0000_0080),
      .mtvec_addr_i       (32'h0000_0000),
      .dm_halt_addr_i     (32'h00000000),
      .dm_exception_addr_i(32'h00000000),
      .hart_id_i          (32'b0),

      // Instruction memory interface
      .instr_addr_o  (core_instr_addr),
      .instr_req_o   (core_instr_req),
      .instr_gnt_i   (core_instr_gnt & core_instr_req),
      .instr_rvalid_i(core_instr_rvalid & core_instr_req),
      .instr_rdata_i (core_instr_rdata),

      // Data memory interface
      .data_addr_o  (core_data_addr),
      .data_req_o   (core_data_req),
      .data_gnt_i   (core_data_gnt & core_data_req),
      .data_we_o    (core_data_we),
      .data_be_o    (core_data_be),
      .data_wdata_o (core_data_wdata),
      .data_rvalid_i(core_data_rvalid & core_data_req),
      .data_rdata_i (core_data_rdata),

      // Interrupt interface
      .irq_i                    (0), //({14'b0, timer_bus.irq, gpio_bus.irq, 16'b0}), //4'b0, 0, 3'b0, 0, 3'b0, 0, 3'b0}),
      .irq_ack_o(),
      .irq_id_o(),

      // Debug interface
      .debug_req_i      (1'b0),
      .debug_havereset_o(),
      .debug_running_o  (),
      .debug_halted_o   ()
   );

   cache #(
      .ADDR_BIT_W (32),
      .CPU_BYTE_W (4),
      .MEM_BYTE_W (4),
      .LINE_BYTE_W(ICACHE_LINE_W / 8),
      .WAY_LEN    (ICACHE_WAY_LEN)
   ) icache (
      .clk_i       (clk_i),
      .rst_ni      (rst_ni),
      .hold_mem_i  (1'b0),
      //
      .cpu_req_i   (core_instr_req),
      .cpu_addr_i  (core_instr_addr),
      .cpu_we_i    ('0),
      .cpu_be_i    ('0),
      .cpu_wdata_i ('0),
      .cpu_gnt_o   (core_instr_gnt),
      .cpu_rvalid_o(core_instr_rvalid),
      .cpu_rdata_o (core_instr_rdata),
      //
      .mem_req_o   (icache2mem_instr_req),
      .mem_addr_o  (icache2mem_instr_addr),
      .mem_we_o    (  /*unused*/),
      .mem_wdata_o (  /*unused*/),
      .mem_gnt_i   (icache2mem_instr_gnt & icache2mem_instr_req),
      .mem_rvalid_i(icache2mem_instr_rvalid),
      .mem_rdata_i (icache2mem_instr_rdata)
   );

   cache #(
      .ADDR_BIT_W (32),
      .CPU_BYTE_W (4),
      .MEM_BYTE_W (4),
      .LINE_BYTE_W(DCACHE_LINE_W / 8),
      .WAY_LEN    (DCACHE_WAY_LEN)
   ) dcache (
      .clk_i       (clk_i),
      .rst_ni      (rst_ni),
      .hold_mem_i  (1'b0),
      //
      .cpu_req_i   (core2dcache_data_req),
      .cpu_addr_i  (core2dcache_data_addr),
      .cpu_we_i    (core2dcache_data_we),
      .cpu_be_i    (core2dcache_data_be),
      .cpu_wdata_i (core2dcache_data_wdata),
      .cpu_gnt_o   (core2dcache_data_gnt),
      .cpu_rvalid_o(core2dcache_data_rvalid),
      .cpu_rdata_o (core2dcache_data_rdata),
      //
      .mem_req_o   (dcache2mem_data_req),
      .mem_we_o    (dcache2mem_data_we),
      .mem_addr_o  (dcache2mem_data_addr),
      .mem_wdata_o (dcache2mem_data_wdata),
      .mem_gnt_i   (dcache2mem_data_gnt & dcache2mem_data_req),
      .mem_rvalid_i(dcache2mem_data_rvalid),
      .mem_rdata_i (dcache2mem_data_rdata)
   );

   wire periph_req = (core_data_addr >= PERIPH_BASE_ADR);

   // verilog_format: off
   assign core2dcache_data_req    = (!periph_req) ? core_data_req : 1'b0;
   assign core2dcache_data_we     = (!periph_req) ? core_data_we  : 1'b0;
   assign core2dcache_data_be     = (!periph_req) ? core_data_be  : 4'b0;
   assign core2dcache_data_addr   = core_data_addr;
   assign core2dcache_data_wdata  = core_data_wdata;

   assign periph_req_o    = (periph_req) ? core_data_req  : 1'b0;
   assign periph_we_o     = (periph_req) ? core_data_we  : 1'b0;
   assign periph_be_o     = (periph_req) ? core_data_be  : 4'b0;
   assign periph_addr_o   = core_data_addr;
   assign periph_wdata_o  = core_data_wdata;

   assign core_data_gnt    = (periph_req) ? 1'b1            : core2dcache_data_gnt;
   assign core_data_rvalid = (periph_req) ? periph_rvalid_i : core2dcache_data_rvalid;
   assign core_data_rdata  = (periph_req) ? periph_rdata_i  : core2dcache_data_rdata;
   // verilog_format: on


   assign mem_addr_o              = (switch == ICACHE) ? icache2mem_instr_addr:
                                    (switch == DCACHE) ? dcache2mem_data_addr :
                                                         icache2mem_instr_addr;

   assign mem_req_o               = (switch == ICACHE) ? icache2mem_instr_req:
                                    (switch == DCACHE) ? dcache2mem_data_req :
                                                         icache2mem_instr_req;

   assign mem_we_o                = (switch == ICACHE) ? 1'b0:
                                    (switch == DCACHE) ? dcache2mem_data_we :
                                                         1'b0;

   assign mem_be_o                = 4'b1111;

   assign mem_wdata_o             = (switch == ICACHE) ? 32'b0:
                                    (switch == DCACHE) ? dcache2mem_data_wdata :
                                                         32'b0;

   assign dcache2mem_data_gnt     =  (switch == DCACHE);

   assign dcache2mem_data_rvalid  = (switch == ICACHE) ? 1'b0:
                                    (switch == DCACHE) ? mem_rvalid_i:
                                                         1'b0;

   assign icache2mem_instr_gnt    =  (switch == ICACHE);

   assign icache2mem_instr_rvalid = (switch == ICACHE) ? mem_rvalid_i:
                                    (switch == DCACHE) ? 1'b0:
                                                         1'b0;

   // verilog_format: off
   assign dcache2mem_data_rdata  = mem_rdata_i;
   assign icache2mem_instr_rdata = mem_rdata_i;
   // verilog_format: on

   wire [1:0] id = {icache2mem_instr_req, dcache2mem_data_req};
   logic req_sources[32];
   logic req_write[32];  // keeping track of whether the request was a write
   logic [31:0] imem_req_addr[32];  // keeping track of address for instruction memory requests
   logic [4:0] req_count;

   always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
         switch <= IDLE;
      end else begin
         case (id)
            {2'b00} : switch <= ICACHE;
            {2'b01} : switch <= DCACHE;
            {2'b10} : switch <= ICACHE;
            {2'b11} : switch <= switch;
         endcase
      end
   end
endmodule
