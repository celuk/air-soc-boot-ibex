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

   logic               uart_req;
   logic [       31:0] uart_addr;
   logic               uart_we;
   logic [MEM_W/8-1:0] uart_be;
   logic [MEM_W  -1:0] uart_wdata;
   logic               uart_gnt;
   logic               uart_rvalid;
   logic [MEM_W  -1:0] uart_rdata;

   logic               timer_req;
   logic [       31:0] timer_addr;
   logic               timer_we;
   logic [MEM_W/8-1:0] timer_be;
   logic [MEM_W  -1:0] timer_wdata;
   logic               timer_gnt;
   logic               timer_rvalid;
   logic [MEM_W  -1:0] timer_rdata;

   logic               gpio_req;
   logic [       31:0] gpio_addr;
   logic               gpio_we;
   logic [MEM_W/8-1:0] gpio_be;
   logic [MEM_W  -1:0] gpio_wdata;
   logic               gpio_gnt;
   logic               gpio_rvalid;
   logic [MEM_W  -1:0] gpio_rdata;

   logic               spi_req;
   logic [       31:0] spi_addr;
   logic               spi_we;
   logic [MEM_W/8-1:0] spi_be;
   logic [MEM_W  -1:0] spi_wdata;
   logic               spi_gnt;
   logic               spi_rvalid;
   logic [MEM_W  -1:0] spi_rdata;

   logic               i2c_req;
   logic [       31:0] i2c_addr;
   logic               i2c_we;
   logic [MEM_W/8-1:0] i2c_be;
   logic [MEM_W  -1:0] i2c_wdata;
   logic               i2c_gnt;
   logic               i2c_rvalid;
   logic [MEM_W  -1:0] i2c_rdata;

   logic               usb_req;
   logic [       31:0] usb_addr;
   logic               usb_we;
   logic [MEM_W/8-1:0] usb_be;
   logic [MEM_W  -1:0] usb_wdata;
   logic               usb_gnt;
   logic               usb_rvalid;
   logic [MEM_W  -1:0] usb_rdata;


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
      .uart_rdata_i (uart_rdata),

      .spi_req_o   (spi_req),
      .spi_addr_o  (spi_addr),
      .spi_we_o    (spi_we),
      .spi_be_o    (spi_be),
      .spi_wdata_o (spi_wdata),
      .spi_gnt_i   (spi_gnt),
      .spi_rvalid_i(spi_rvalid),
      .spi_rdata_i (spi_rdata),

      .timer_req_o   (timer_req),
      .timer_addr_o  (timer_addr),
      .timer_we_o    (timer_we),
      .timer_be_o    (timer_be),
      .timer_wdata_o (timer_wdata),
      .timer_gnt_i   (timer_gnt),
      .timer_rvalid_i(timer_rvalid),
      .timer_rdata_i (timer_rdata),

      .i2c_req_o   (i2c_req),
      .i2c_addr_o  (i2c_addr),
      .i2c_we_o    (i2c_we),
      .i2c_be_o    (i2c_be),
      .i2c_wdata_o (i2c_wdata),
      .i2c_gnt_i   (i2c_gnt),
      .i2c_rvalid_i(i2c_rvalid),
      .i2c_rdata_i (i2c_rdata),

      .gpio_req_o   (gpio_req),
      .gpio_addr_o  (gpio_addr),
      .gpio_we_o    (gpio_we),
      .gpio_be_o    (gpio_be),
      .gpio_wdata_o (gpio_wdata),
      .gpio_gnt_i   (gpio_gnt),
      .gpio_rvalid_i(gpio_rvalid),
      .gpio_rdata_i (gpio_rdata),

      .usb_req_o   (usb_req),
      .usb_addr_o  (usb_addr),
      .usb_we_o    (usb_we),
      .usb_be_o    (usb_be),
      .usb_wdata_o (usb_wdata),
      .usb_gnt_i   (usb_gnt),
      .usb_rvalid_i(usb_rvalid),
      .usb_rdata_i (usb_rdata)

   );


   uart_controller_obi uart (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .req_i   (uart_req),
      .we_i    (uart_we),
      .be_i    (uart_be),
      .addr_i  (uart_addr),
      .wdata_i (uart_wdata),
      .gnt_o   (uart_gnt),
      .rvalid_o(uart_rvalid),
      .rdata_o (uart_rdata),
      .rx_i    (uart_rx_i),
      .tx_o    (uart_tx_o)
   );

   timer_controller_obi timer (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .req_i   (timer_req),
      .we_i    (timer_we),
      .be_i    (timer_be),
      .addr_i  (timer_addr),
      .wdata_i (timer_wdata),
      .gnt_o   (timer_gnt),
      .rvalid_o(timer_rvalid),
      .rdata_o (timer_rdata)
   );

   spi_controller_obi spi (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .req_i   (spi_req),
      .we_i    (spi_we),
      .be_i    (spi_be),
      .addr_i  (spi_addr),
      .wdata_i (spi_wdata),
      .gnt_o   (spi_gnt),
      .rvalid_o(spi_rvalid),
      .rdata_o (spi_rdata)
   );

   i2c_controller_obi i2c (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .req_i   (i2c_req),
      .we_i    (i2c_we),
      .be_i    (i2c_be),
      .addr_i  (i2c_addr),
      .wdata_i (i2c_wdata),
      .gnt_o   (i2c_gnt),
      .rvalid_o(i2c_rvalid),
      .rdata_o (i2c_rdata)
   );

   gpio_controller_obi gpio (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .req_i   (gpio_req),
      .we_i    (gpio_we),
      .be_i    (gpio_be),
      .addr_i  (gpio_addr),
      .wdata_i (gpio_wdata),
      .gnt_o   (gpio_gnt),
      .rvalid_o(gpio_rvalid),
      .rdata_o (gpio_rdata)
   );

   usb_controller_obi usb (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .req_i   (usb_req),
      .we_i    (usb_we),
      .be_i    (usb_be),
      .addr_i  (usb_addr),
      .wdata_i (usb_wdata),
      .gnt_o   (usb_gnt),
      .rvalid_o(usb_rvalid),
      .rdata_o (usb_rdata)
   );

endmodule
