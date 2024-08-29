// air_soc.sv
`timescale 1ns / 1ps

`include "header.vh"

`default_nettype none

`define QSPI_SIM

module air_soc (
   input wire clk_i,
   input wire rst_ni,

   input  wire uart_rx_i,
   output wire uart_tx_o,

   output wire dp_pu_o,
   output wire tx_en_o,
   output wire dp_tx_o,
   output wire dn_tx_o,
   input  wire dp_rx_i,
   input  wire dn_rx_i
);

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
   logic                data_req;
   logic [       31:0]  data_addr;
   logic                data_we;
   logic [`MEM_W/8-1:0] data_be;
   logic [`MEM_W  -1:0] data_wdata;
   logic                data_gnt;
   logic                data_rvalid;
   logic [`MEM_W  -1:0] data_rdata;

   logic                cache_req;
   logic [       31:0]  cache_addr;
   logic                cache_we;
   logic [`MEM_W/8-1:0] cache_be;
   logic [`MEM_W  -1:0] cache_wdata;
   logic                cache_gnt;
   logic                cache_rvalid;
   logic [`MEM_W  -1:0] cache_rdata;

   logic                uart_req;
   logic [       31:0]  uart_addr;
   logic                uart_we;
   logic [`MEM_W/8-1:0] uart_be;
   logic [`MEM_W  -1:0] uart_wdata;
   logic                uart_gnt;
   logic                uart_rvalid;
   logic [`MEM_W  -1:0] uart_rdata;

   logic                timer_req;
   logic [       31:0]  timer_addr;
   logic                timer_we;
   logic [`MEM_W/8-1:0] timer_be;
   logic [`MEM_W  -1:0] timer_wdata;
   logic                timer_gnt;
   logic                timer_rvalid;
   logic [`MEM_W  -1:0] timer_rdata;

   logic                gpio_req;
   logic [       31:0]  gpio_addr;
   logic                gpio_we;
   logic [`MEM_W/8-1:0] gpio_be;
   logic [`MEM_W  -1:0] gpio_wdata;
   logic                gpio_gnt;
   logic                gpio_rvalid;
   logic [`MEM_W  -1:0] gpio_rdata;

   logic                qspi_req;
   logic [       31:0]  qspi_addr;
   logic                qspi_we;
   logic [`MEM_W/8-1:0] qspi_be;
   logic [`MEM_W  -1:0] qspi_wdata;
   logic                qspi_gnt;
   logic                qspi_rvalid;
   logic [`MEM_W  -1:0] qspi_rdata;

   logic                i2c_req;
   logic [       31:0]  i2c_addr;
   logic                i2c_we;
   logic [`MEM_W/8-1:0] i2c_be;
   logic [`MEM_W  -1:0] i2c_wdata;
   logic                i2c_gnt;
   logic                i2c_rvalid;
   logic [`MEM_W  -1:0] i2c_rdata;

   logic                usb_req;
   logic [       31:0]  usb_addr;
   logic                usb_we;
   logic [`MEM_W/8-1:0] usb_be;
   logic [`MEM_W  -1:0] usb_wdata;
   logic                usb_gnt;
   logic                usb_rvalid;
   logic [`MEM_W  -1:0] usb_rdata;


   // instruction cache
   logic               imem_req;
   logic               imem_gnt;
   logic [       31:0] imem_addr;
   logic               imem_rvalid;
   logic [ `MEM_W-1:0] imem_rdata;

   // data cache
   logic                dmem_req;
   logic                dmem_gnt;
   logic [       31:0]  dmem_addr;
   logic                dmem_we;
   logic [         3:0] dmem_be;
   logic [`MEM_W  -1:0] dmem_wdata;
   logic                dmem_rvalid;
   logic                dmem_wvalid;
   logic [`MEM_W  -1:0] dmem_rdata;

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

   generate
      if(`ICACHE_SZ > 0) begin
         cache #(
            .ADDR_BIT_W (32),
            .CPU_BYTE_W (4),
            .MEM_BYTE_W (`MEM_W / 8),
            .LINE_BYTE_W(`ICACHE_LINE_W / 8),
            .WAY_LEN    (`ICACHE_WAY_LEN)
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
      end
      else begin
         assign instr_gnt    = imem_gnt;
         assign instr_rvalid = imem_rvalid;
         assign instr_rdata  = imem_rdata[31:0];
         assign imem_req     = instr_req;
         assign imem_addr    = instr_addr;
      end
   endgenerate

   generate
      if(`DCACHE_SZ > 0) begin
         cache #(
            .ADDR_BIT_W (32),
            .CPU_BYTE_W (`MEM_W / 8),
            .MEM_BYTE_W (`MEM_W / 8),
            .LINE_BYTE_W(`DCACHE_LINE_W / 8),
            .WAY_LEN    (`DCACHE_WAY_LEN)
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
         assign dmem_be = 4'b1111;
      end
      else begin
         assign dmem_req     = cache_req;
         assign dmem_we      = cache_we;
         assign dmem_be      = cache_be;
         assign dmem_addr    = cache_addr;
         assign dmem_wdata   = cache_wdata;
         assign cache_gnt    = dmem_gnt;
         assign cache_rvalid = dmem_rvalid | dmem_wvalid;
         assign cache_rdata  = dmem_rdata;
      end
   endgenerate

   ///////////////////////////////////////////////////////////////////////////
   // MEMORY ARBITER

   always_comb begin
      mem_req   = imem_req | dmem_req;
      mem_addr  = imem_addr;
      mem_we    = 1'b0;
      mem_be    = dmem_be;
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
   assign imem_rdata  = (`ICACHE_SZ > 0) ? mem_rdata : mem_rdata[(imem_req_addr[0][$clog2(`MEM_W)-1:0] & {3'b000, {($clog2(`MEM_W/8)-2){1'b1}}, 2'b00})*8 +: 32];
   assign dmem_rdata  = mem_rdata;

   ram32 #(
      .SIZE     (`RAM_SIZE / 4),
      .INIT_FILE(`RAM_FPATH)
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

      .qspi_req_o   (qspi_req),
      .qspi_addr_o  (qspi_addr),
      .qspi_we_o    (qspi_we),
      .qspi_be_o    (qspi_be),
      .qspi_wdata_o (qspi_wdata),
      .qspi_gnt_i   (qspi_gnt),
      .qspi_rvalid_i(qspi_rvalid),
      .qspi_rdata_i (qspi_rdata),

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

   wire qspi_cs_n_o;
   wire qspi_sck_o;
   wire [3:0] qspi_data_io;
   wire [3:0] qspi_data_i;
   wire [3:0] qspi_data_o;
   wire [1:0] qspi_out_mod_o;

   assign qspi_data_io[0] = |qspi_out_mod_o   ? qspi_data_o[0] : 1'bZ;
   assign qspi_data_io[1] = qspi_out_mod_o[1] ? qspi_data_o[1] : 1'bZ;
   assign qspi_data_io[2] = &qspi_out_mod_o   ? qspi_data_o[2] : 1'bZ;
   assign qspi_data_io[3] = &qspi_out_mod_o   ? qspi_data_o[3] : 1'bZ;

   assign qspi_data_i = qspi_data_io;

   qspi_controller_obi qspi (
      .clk_i         (clk_i),
      .rst_ni        (rst_ni),
      .req_i         (qspi_req),
      .we_i          (qspi_we),
      .be_i          (qspi_be),
      .addr_i        (qspi_addr),
      .wdata_i       (qspi_wdata),
      .gnt_o         (qspi_gnt),
      .rvalid_o      (qspi_rvalid),
      .rdata_o       (qspi_rdata),
      .qspi_data_i   (qspi_data_i),
      .qspi_data_o   (qspi_data_o),
      .qspi_out_mod_o(qspi_out_mod_o),
      .qspi_cs_n_o   (qspi_cs_n_o),
      .qspi_sck_o    (qspi_sck_o)
   );

`ifdef QSPI_SIM
   s25fl128s #(
      .mem_file_name("../../../tests/demo/demo.vmem"),
      //.mem_file_name("../../../rtl/sim/s25fl128s.mem"),
      //.mem_file_name("none"),
      .otp_file_name("none"),
      .AddrRANGE(24'h00FFFF)
   ) flash (
      // Data Inputs/Outputs
      .SI(qspi_data_io[0]),
      .SO(qspi_data_io[1]),
      // Controls
      .SCK(qspi_sck_o),
      .CSNeg(qspi_cs_n_o),
      //.RSTNeg(1),
      .WPNeg(qspi_data_io[2]),
      .HOLDNeg(qspi_data_io[3])
   );
`endif

   logic sda_i, sda_o, scl_i, scl_o;

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
      .rdata_o (i2c_rdata),
      .sda_i   (sda_i),
      .sda_o   (sda_o),
      .scl_i   (scl_i),
      .scl_o   (scl_o)
   );

   logic [15:0] gpio_i = 16'h0000;
   logic [15:0] gpio_o;

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
      .rdata_o (gpio_rdata),
      .gpio_i  (gpio_i),
      .gpio_o  (gpio_o)
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
      .rdata_o (usb_rdata),

      .dp_pu_o(dp_pu_o),
      .tx_en_o(tx_en_o),
      .dp_tx_o(dp_tx_o),
      .dn_tx_o(dn_tx_o),
      .dp_rx_i(dp_rx_i),
      .dn_rx_i(dn_rx_i)
   );

endmodule
