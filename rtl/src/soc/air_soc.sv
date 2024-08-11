// air_soc.sv
`timescale 1ns / 1ps

`include "header.vh"

`default_nettype none

module air_soc #(
   parameter int unsigned MEM_W         = 32,    // memory bus width in bits
   parameter int unsigned ICACHE_SZ     = 8192,  // instruction cache size in bytes
   parameter int unsigned ICACHE_LINE_W = 64,    // instruction cache line width in bits
   parameter int unsigned DCACHE_SZ     = 8192,  // data cache size in bytes
   parameter int unsigned DCACHE_LINE_W = 64     // data cache line width in bits
) (
   input wire clk_i,
   input wire rst_ni,

   input  wire uart_rx_i,
   output wire uart_tx_o
);

   localparam RAM_FPATH = "";
   localparam RAM_SIZE = 256 * 1024;

   logic               mem_req;
   logic [       31:0] mem_addr;
   logic               mem_we;
   logic [        3:0] mem_be;
   logic [       31:0] mem_wdata;
   logic               mem_rvalid;
   logic [       31:0] mem_rdata;

   // Instruction fetch interface
   logic               instr_req;
   logic [       31:0] instr_addr;
   logic               instr_gnt;
   logic               instr_rvalid;
   logic [       31:0] instr_rdata;

   // Data arbiter for main core
   logic               data_req;
   logic [       31:0] data_addr;
   logic               data_we;
   logic [MEM_W/8-1:0] data_be;
   logic [MEM_W  -1:0] data_wdata;
   logic               data_gnt;
   logic               data_rvalid;
   logic [MEM_W  -1:0] data_rdata;

   logic               cache_req;
   logic [       31:0] cache_addr;
   logic               cache_we;
   logic [MEM_W/8-1:0] cache_be;
   logic [MEM_W  -1:0] cache_wdata;
   logic               cache_gnt;
   logic               cache_rvalid;
   logic [MEM_W  -1:0] cache_rdata;

   logic               periph_req;
   logic [       31:0] periph_addr;
   logic               periph_we;
   logic [MEM_W/8-1:0] periph_be;
   logic [MEM_W  -1:0] periph_wdata;
   logic               periph_gnt;
   logic               periph_rvalid;
   logic [MEM_W  -1:0] periph_rdata;

   // instruction cache
   logic               imem_req;
   logic               imem_gnt;
   logic [       31:0] imem_addr;
   logic               imem_rvalid;
   logic [  MEM_W-1:0] imem_rdata;

   // data cache
   logic               dmem_req;
   logic               dmem_gnt;
   logic [       31:0] dmem_addr;
   logic               dmem_we;
   logic [MEM_W  -1:0] dmem_wdata;
   logic               dmem_rvalid;
   logic               dmem_wvalid;
   logic [MEM_W  -1:0] dmem_rdata;

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

       // Instruction memory interface
       .instr_req_o              (instr_req),
       .instr_gnt_i              (instr_gnt),
       .instr_rvalid_i           (instr_rvalid),
       .instr_addr_o             (instr_addr),
       .instr_rdata_i            (instr_rdata),

       // Data memory interface
       .data_req_o               (data_req),
       .data_gnt_i               (data_gnt),
       .data_rvalid_i            (data_rvalid),
       .data_we_o                (data_we),
       .data_be_o                (data_be),
       .data_addr_o              (data_addr),
       .data_wdata_o             (data_wdata),
       .data_rdata_i             (data_rdata),

       // TODO: Interrupt instead of polling peripherals
       // Interrupt interface
       .irq_i                    (32'h0), //({14'b0, timer_bus.irq, gpio_bus.irq, 16'b0}), //4'b0, 0, 3'b0, 0, 3'b0, 0, 3'b0}),
       .irq_ack_o                (),
       .irq_id_o                 (),

       // TODO: JTAG Integration
       // Debug interface
       .debug_req_i              (1'b0),
       .debug_havereset_o        (),
       .debug_running_o          (),
       .debug_halted_o           (),

       // CPU Control Signals
       .fetch_enable_i           (1'b1),
       .core_sleep_o             ()
   );

   // instruction cache
   localparam int unsigned ICACHE_WAY_LEN = ICACHE_SZ / (ICACHE_LINE_W / 8) / 2;
   cache #(
      .ADDR_BIT_W (32),
      .CPU_BYTE_W (4),
      .MEM_BYTE_W (MEM_W / 8),
      .LINE_BYTE_W(ICACHE_LINE_W / 8),
      .WAY_LEN    (ICACHE_WAY_LEN)
   ) icache (
      .clk_i       (clk_i),
      .rst_ni      (rst_ni),
      .hold_mem_i  (1'b0),
      .cpu_req_i   (instr_req),
      .cpu_addr_i  (instr_addr),
      .cpu_we_i    ('0),
      .cpu_be_i    ('0),
      .cpu_wdata_i ('0),
      .cpu_gnt_o   (instr_gnt),
      .cpu_rvalid_o(instr_rvalid),
      .cpu_rdata_o (instr_rdata),
      .mem_req_o   (imem_req),
      .mem_addr_o  (imem_addr),
      .mem_we_o    (),
      .mem_wdata_o (),
      .mem_gnt_i   (imem_gnt),
      .mem_rvalid_i(imem_rvalid),
      .mem_rdata_i (imem_rdata)
   );

   // data cache
   localparam int unsigned DCACHE_WAY_LEN = DCACHE_SZ / (DCACHE_LINE_W / 8) / 2;
   cache #(
      .ADDR_BIT_W (32),
      .CPU_BYTE_W (MEM_W / 8),
      .MEM_BYTE_W (MEM_W / 8),
      .LINE_BYTE_W(DCACHE_LINE_W / 8),
      .WAY_LEN    (DCACHE_WAY_LEN)
   ) dcache (
      .clk_i     (clk_i),
      .rst_ni    (rst_ni),
      .hold_mem_i(1'b0),

      .cpu_req_i   (cache_req),
      .cpu_addr_i  (cache_addr),
      .cpu_we_i    (cache_we),
      .cpu_be_i    (cache_be),
      .cpu_wdata_i (cache_wdata),
      .cpu_gnt_o   (cache_gnt),
      .cpu_rvalid_o(cache_rvalid),
      .cpu_rdata_o (cache_rdata),

      .mem_req_o   (dmem_req),
      .mem_we_o    (dmem_we),
      .mem_addr_o  (dmem_addr),
      .mem_wdata_o (dmem_wdata),
      .mem_gnt_i   (dmem_gnt),
      .mem_rvalid_i(dmem_rvalid),
      .mem_rdata_i (dmem_rdata)
   );

   ///////////////////////////////////////////////////////////////////////////
   // MEMORY ARBITER
   always_comb begin
      mem_req   = imem_req | dmem_req;
      mem_addr  = imem_addr;
      mem_we    = 1'b0;
      mem_be    =  '1;
      mem_wdata = dmem_wdata;
      if (dmem_req) begin
         mem_we   = dmem_we;
         mem_addr = dmem_addr;
      end
   end
   assign imem_gnt = imem_req & ~dmem_req;
   assign dmem_gnt = dmem_req;

   // shift register keeping track of the source of mem requests for up to 32 cycles
   logic        req_sources  [32];
   logic        req_write    [32];  // keeping track of whether the request was a write
   logic [31:0] imem_req_addr[32];  // keeping track of address for instruction memory requests
   logic [ 4:0] req_count;
   always_ff @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
         req_count <= '0;
      end else begin
         if (mem_rvalid) begin
            for (int i = 0; i < 31; i++) begin
               req_sources[i]   <= req_sources[i+1];
               req_write[i]     <= req_write[i+1];
               imem_req_addr[i] <= imem_req_addr[i+1];
            end
            if (~imem_gnt & ~dmem_gnt) begin
               req_count <= req_count - 1;
            end else begin
               req_sources[req_count-1]   <= dmem_gnt;
               req_write[req_count-1]     <= dmem_we;
               imem_req_addr[req_count-1] <= imem_addr;
            end
         end else if (imem_gnt | dmem_gnt) begin
            req_sources[req_count]   <= dmem_gnt;
            req_write[req_count]     <= dmem_we;
            imem_req_addr[req_count] <= imem_addr;
            req_count                <= req_count + 1;
         end
      end
   end
   assign imem_rvalid = mem_rvalid & ~req_sources[0];
   assign dmem_rvalid = mem_rvalid & req_sources[0] & ~req_write[0];
   assign dmem_wvalid = mem_rvalid & req_sources[0] & req_write[0];
   assign imem_rdata  = mem_rdata;
   assign dmem_rdata  = mem_rdata;

   ram32 #(
      .SIZE     (RAM_SIZE / 4),
      .INIT_FILE(RAM_FPATH)
   ) main_memory (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .req_i   (mem_req),
      .we_i    (mem_req & mem_we),
      .be_i    (mem_be),
      .addr_i  (mem_addr),
      .wdata_i (mem_wdata),
      .rvalid_o(mem_rvalid),
      .rdata_o (mem_rdata)

      //,.program_rx_i(program_rx_i),
      //.system_reset_o(system_reset_o),
      //.prog_mode_led_o(prog_mode_led_o)
   );

   periph_bus pb(
      .clk_i(clk_i),
      .rst_i(~rst_ni),

      .req_i   (periph_req),
      .we_i    (periph_we),
      .be_i    (periph_be),
      .addr_i  (periph_addr),
      .wdata_i (periph_wdata),
      .gnt_o   (periph_gnt),
      .rvalid_o(periph_rvalid),
      .rdata_o (periph_rdata),

      .uart_rx_i      (uart_rx_i),
      .uart_tx_o      (uart_tx_o)
   );
   

   obi_demux obi_demux_dut (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .data_req_i   (data_req),
      .data_gnt_o   (data_gnt),
      .data_rvalid_o(data_rvalid),
      .data_we_i    (data_we),
      .data_be_i    (data_be),
      .data_addr_i  (data_addr),
      .data_wdata_i (data_wdata),
      .data_rdata_o (data_rdata),

      .cache_req_o   (cache_req),
      .cache_addr_o  (cache_addr),
      .cache_we_o    (cache_we),
      .cache_be_o    (cache_be),
      .cache_wdata_o (cache_wdata),
      .cache_gnt_i   (cache_gnt),
      .cache_rvalid_i(cache_rvalid),
      .cache_rdata_i (cache_rdata),

      .periph_req_o   (periph_req),
      .periph_addr_o  (periph_addr),
      .periph_we_o    (periph_we),
      .periph_be_o    (periph_be),
      .periph_wdata_o (periph_wdata),
      .periph_gnt_i   (periph_gnt),
      .periph_rvalid_i(periph_rvalid),
      .periph_rdata_i (periph_rdata)
   );

endmodule
