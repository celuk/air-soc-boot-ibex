// air_soc.sv
`timescale 1ns / 1ps
//
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

   localparam int unsigned CLK_FREQ = 50_000_000;

   localparam RAM_FPATH = "";
   localparam RAM_SIZE = 256 * 1024;
   localparam UART_BAUD_RATE = 9600;

   localparam logic [31:0] MEM_START = 32'h00000000;
   localparam logic [31:0] MEM_MASK = RAM_SIZE - 1;

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

   logic               uart_req;
   logic [       31:0] uart_addr;
   logic               uart_we;
   logic [MEM_W/8-1:0] uart_be;
   logic [MEM_W  -1:0] uart_wdata;
   logic               uart_gnt;
   logic               uart_rvalid;
   logic [MEM_W  -1:0] uart_rdata;

   // instruction cache
   logic               imem_req;
   logic               imem_gnt;
   logic [       31:0] imem_addr;
   logic               imem_rvalid;
   logic [  MEM_W-1:0] imem_rdata;


   cv32e40p_top #(
      .FPU             (0),
      .FPU_ADDMUL_LAT  (0),
      .FPU_OTHERS_LAT  (0),
      .ZFINX           (0),
      .COREV_PULP      (0),
      .COREV_CLUSTER   (0),
      .NUM_MHPMCOUNTERS(1)
   ) core (
      // Clock and reset
      .rst_ni      (rst_ni),
      .clk_i       (clk_i),
      .scan_cg_en_i(1'b0),

      // Special control signals
      .fetch_enable_i (1),
      .pulp_clock_en_i(1'b0),
      .core_sleep_o   (),

      // Configuration
      .boot_addr_i        (32'h0000_0080),
      .mtvec_addr_i       (32'h0000_0000),
      .dm_halt_addr_i     (32'h00000000),
      .dm_exception_addr_i(32'h00000000),
      .hart_id_i          (32'b0),

      // Instruction memory interface
      .instr_addr_o  (instr_addr),
      .instr_req_o   (instr_req),
      .instr_gnt_i   (instr_gnt),
      .instr_rvalid_i(instr_rvalid),
      .instr_rdata_i (instr_rdata),

      // Data memory interface
      .data_addr_o  (data_addr),
      .data_req_o   (data_req),
      .data_gnt_i   (data_gnt),
      .data_we_o    (data_we),
      .data_be_o    (data_be),
      .data_wdata_o (data_wdata),
      .data_rvalid_i(data_rvalid),
      .data_rdata_i (data_rdata),

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
   logic               dmem_req;
   logic               dmem_gnt;
   logic [       31:0] dmem_addr;
   logic               dmem_we;
   logic [MEM_W  -1:0] dmem_wdata;
   logic               dmem_rvalid;
   logic               dmem_wvalid;
   logic [MEM_W  -1:0] dmem_rdata;

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

   uart_controller_obi #(
      .CLK_FREQ      (CLK_FREQ),
      .UART_BAUD_RATE(UART_BAUD_RATE)
   ) uart (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .req_i   (uart_req),
      .we_i    (uart_we),
      .addr_i  (uart_addr),
      .wdata_i (uart_wdata),
      .gnt_o   (uart_gnt),
      .rvalid_o(uart_rvalid),
      .rdata_o (uart_rdata),
      .rx_i    (uart_rx_i),
      .tx_o    (uart_tx_o)
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

      .uart_req_o   (uart_req),
      .uart_addr_o  (uart_addr),
      .uart_we_o    (uart_we),
      .uart_be_o    (uart_be),
      .uart_wdata_o (uart_wdata),
      .uart_gnt_i   (uart_gnt),
      .uart_rvalid_i(uart_rvalid),
      .uart_rdata_i (uart_rdata)
   );

endmodule
