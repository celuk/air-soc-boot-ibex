// air_soc.sv
`timescale 1ns / 1ps
//
`default_nettype none

`include "header.vh"
`include "typedef.svh"

module air_soc #(
   parameter int unsigned MEM_W         = 32,    // memory bus width in bits
   parameter int unsigned ICACHE_SZ     = 8192,  // instruction cache size in bytes
   parameter int unsigned ICACHE_LINE_W = 64,    // instruction cache line width in bits
   parameter int unsigned DCACHE_SZ     = 8192,  // data cache size in bytes
   parameter int unsigned DCACHE_LINE_W = 64     // data cache line width in bits
) (
   input wire clk_i,
   input wire rst_ni
);


   localparam RAM_FPATH = "";
   localparam RAM_SIZE = 262144;
   localparam UART_BAUD_RATE = 9600;

   localparam logic [31:0] MEM_START = 32'h00000000;
   localparam logic [31:0] MEM_MASK = RAM_SIZE - 1;

   logic        mem_req;
   logic [31:0] mem_addr;
   logic        mem_we;
   logic [ 3:0] mem_be;
   logic [31:0] mem_wdata;
   logic        mem_rvalid;
   logic [31:0] mem_rdata;

   // Instruction fetch interface
   logic        instr_req;
   logic [31:0] instr_addr;
   logic        instr_gnt;
   logic        instr_rvalid;
   logic [31:0] instr_rdata;

   // Data load & store interface
   logic        sdata_req;
   logic [31:0] sdata_addr;
   logic        sdata_we;
   logic [ 3:0] sdata_be;
   logic [31:0] sdata_wdata;
   logic        sdata_gnt;
   logic        sdata_rvalid;
   logic [31:0] sdata_rdata;

   //////////////////////////////////
   // Copyright 2024 ETH Zurich and University of Bologna.
   // Solderpad Hardware License, Version 0.51, see LICENSE for details.
   // SPDX-License-Identifier: SHL-0.51
   //
   // Authors:
   // - Philippe Sauter <phsauter@iis.ee.ethz.ch>

   // `include "register_interface/typedef.svh"


   localparam int unsigned HartId = 32'd0;
   localparam int unsigned PulpJtagIdCode = 32'h1_0000_db3;

   typedef enum logic {Jtag = 1'b0} bootmode_e;

   localparam int unsigned NumExternalIrqs = 4;

   // -----------------
   // Address Map
   // -----------------
   // ideally compatible with: https://pulp-platform.github.io/cheshire/um/arch/#memory-map

   // Address map data type
   typedef struct packed {
      logic [31:0] idx;
      logic [31:0] start_addr;
      logic [31:0] end_addr;
   } addr_map_rule_t;

   // Main interconnect addressing
   localparam bit [31:0] PeriphBaseAddr = 32'h0000_0000;
   localparam bit [31:0] PeriphAddrRange = 32'h1000_0000;

   localparam bit [31:0] MemBaseAddr = 32'h1000_0000;
   localparam int unsigned BankNumWords = 512;
   localparam int unsigned NumBanks = 32'd2;

   // Enum for bus indices
   typedef enum int {
      XbarUser,
      XbarPeriph,
      XbarBank0
   } xbar_outputs_e;
   // User space is implicit as everything outside Periph and Memory ranges
   localparam int unsigned NumRules = 1 + NumBanks;

   function automatic addr_map_rule_t [NumRules-1:0] gen_xbar_addr_rules();
      addr_map_rule_t [NumRules-1:0] ret;
      ret[0] = '{
         idx: XbarPeriph,
         start_addr: PeriphBaseAddr,
         end_addr: PeriphBaseAddr + PeriphAddrRange
      };

      for (int i = 0; i < NumBanks; i++) begin
         ret[i+1] = '{
            idx: XbarBank0 + i,
            start_addr: MemBaseAddr + (i * BankNumWords * 4),
            end_addr: MemBaseAddr + ((i + 1) * BankNumWords * 4)
         };
      end
      return ret;
   endfunction

   localparam addr_map_rule_t [NumRules-1:0] main_addr_map = gen_xbar_addr_rules();


   // Peripheral address map
   localparam bit [31:0] DebugAddrOffset = 32'h0000_0000;
   localparam bit [31:0] DebugAddrRange = 32'h0004_0000;

   localparam bit [31:0] SocCtrlAddrOffset = 32'h0300_0000;
   localparam bit [31:0] SocCtrlAddrRange = 32'h0000_1000;

   localparam bit [31:0] UartAddrOffset = 32'h0300_2000;
   localparam bit [31:0] UartAddrRange = 32'h0000_1000;

   localparam bit [31:0] TimerAddrOffset = 32'h0300_A000;
   localparam bit [31:0] TimerAddrRange = 32'h0000_1000;

   localparam int unsigned NumPeriphRules = 4;
   localparam int unsigned NumPeriphs = NumPeriphRules + 1;  // additional OBI error

   // Enum for bus indices
   typedef enum int {
      PeriphErrorSlv = 0,
      PeriphDebug    = 1,
      PeriphSocCtrl  = 2,
      PeriphUart     = 3,
      PeriphTimer    = 4
   } periph_outputs_e;

   localparam addr_map_rule_t [NumPeriphRules-1:0] periph_addr_map = '{  // 0: OBI Error (default)
      '{
         idx: PeriphDebug,
         start_addr: DebugAddrOffset,
         end_addr: DebugAddrOffset + DebugAddrRange
      },  // 1: Debug
      '{
         idx: PeriphSocCtrl,
         start_addr: SocCtrlAddrOffset,
         end_addr: SocCtrlAddrOffset + SocCtrlAddrRange
      },  // 2: SoC control
      '{
         idx: PeriphUart,
         start_addr: UartAddrOffset,
         end_addr: UartAddrOffset + UartAddrRange
      },  // 3: UART
      '{
         idx: PeriphTimer,
         start_addr: TimerAddrOffset,
         end_addr: TimerAddrOffset + TimerAddrRange
      }  // 4: Timer
   };


   // OBI is configured as 32 bit data, 32 bit address width
   localparam int unsigned NumManagers = 3;  // DBG, Core Instr, Core Data
   localparam int unsigned NumSubordinates = 2 + NumBanks;  // User + Periph + Memory

   // no optional bits in the OBI interconnect
   `OBI_TYPEDEF_MINIMAL_A_OPTIONAL(a_optional_t)
   `OBI_TYPEDEF_MINIMAL_R_OPTIONAL(r_optional_t)

   // Create types for OBI managers/masters (from a manager into the interconnect)
   localparam obi_pkg::obi_cfg_t MgrObiCfg = obi_pkg::obi_default_cfg(
      32, 32, 1, obi_pkg::ObiMinimalOptionalConfig
   );
   `OBI_TYPEDEF_A_CHAN_T(mgr_obi_a_chan_t, MgrObiCfg.AddrWidth, MgrObiCfg.DataWidth,
                         MgrObiCfg.IdWidth, a_optional_t)
   `OBI_TYPEDEF_DEFAULT_REQ_T(mgr_obi_req_t, mgr_obi_a_chan_t)
   `OBI_TYPEDEF_R_CHAN_T(mgr_obi_r_chan_t, MgrObiCfg.DataWidth, MgrObiCfg.IdWidth, r_optional_t)
   `OBI_TYPEDEF_RSP_T(mgr_obi_rsp_t, mgr_obi_r_chan_t)

   // Create types for OBI subordinates/slaves (out of the interconnect, into the device)
   localparam obi_pkg::obi_cfg_t SbrObiCfg = obi_pkg::mux_grow_cfg(MgrObiCfg, NumManagers);
   `OBI_TYPEDEF_A_CHAN_T(sbr_obi_a_chan_t, SbrObiCfg.AddrWidth, SbrObiCfg.DataWidth,
                         SbrObiCfg.IdWidth, a_optional_t)
   `OBI_TYPEDEF_DEFAULT_REQ_T(sbr_obi_req_t, sbr_obi_a_chan_t)
   `OBI_TYPEDEF_R_CHAN_T(sbr_obi_r_chan_t, SbrObiCfg.DataWidth, SbrObiCfg.IdWidth, r_optional_t)
   `OBI_TYPEDEF_RSP_T(sbr_obi_rsp_t, sbr_obi_r_chan_t)

   // Register Interface configured as 32 bit data, 32 bit address width (4 byte enable bits)
   // `REG_BUS_TYPEDEF_ALL(reg, logic[31:0], logic[31:0], logic[3:0]);


   /////////////////////////////////

   // Core data bus
   mgr_obi_req_t core_data_obi_req;
   mgr_obi_rsp_t core_data_obi_rsp;
   assign core_data_obi_req.a.aid = '0;
   assign core_data_obi_req.a.a_optional = '0;

   /////////////////////////////////

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
      .instr_addr_o  (instr_addr),
      .instr_req_o   (instr_req),
      .instr_gnt_i   (instr_gnt),
      .instr_rvalid_i(instr_rvalid),
      .instr_rdata_i (instr_rdata),

      // Data memory interface
      .data_req_o(core_data_obi_req.req),
      .data_gnt_i(core_data_obi_rsp.gnt),
      .data_rvalid_i(core_data_obi_rsp.rvalid),
      .data_we_o(core_data_obi_req.a.we),
      .data_be_o(core_data_obi_req.a.be),
      .data_addr_o(core_data_obi_req.a.addr),
      .data_wdata_o(core_data_obi_req.a.wdata),
      .data_rdata_i(core_data_obi_rsp.r.rdata),

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


   // Data arbiter for main core
   logic               sdata_hold;
   logic               data_req;
   logic [       31:0] data_addr;
   logic               data_we;
   logic [MEM_W/8-1:0] data_be;
   logic [MEM_W  -1:0] data_wdata;
   logic               data_gnt;
   logic               data_rvalid;
   logic [MEM_W  -1:0] data_rdata;
   logic               sdata_waiting;
   logic [       31:0] sdata_wait_addr;
   assign sdata_hold = 0;
   always_comb begin
      data_req = (sdata_req & ~sdata_hold);
      data_addr = sdata_addr;
      data_we = sdata_we;
      data_be = {{(MEM_W - 32) {1'b0}}, sdata_be} <<
         (sdata_addr[$clog2(MEM_W/8)-1:0] & {{$clog2(MEM_W / 32) {1'b1}}, 2'b00});
      data_wdata = '0;
      for (int i = 0; i < MEM_W / 32; i++) begin
         data_wdata[32*i+:32] = sdata_wdata;
      end
   end
   assign sdata_gnt = data_gnt & sdata_req & ~sdata_hold;
   always_ff @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
         sdata_waiting   <= 1'b0;
         sdata_wait_addr <= '0;
      end else begin
         if (sdata_gnt) begin
            sdata_waiting   <= 1'b1;
            sdata_wait_addr <= sdata_addr;
         end else if (sdata_rvalid) begin
            sdata_waiting <= 1'b0;
         end
      end
   end
   assign sdata_rvalid = sdata_waiting & data_rvalid;
   assign sdata_rdata = data_rdata[(sdata_wait_addr[$clog2(
      MEM_W
   )-1:0]&{3'b000, {($clog2(
      MEM_W/8
   )-2) {1'b1}}, 2'b00})*8+:32];

   // instruction cache
   logic             imem_req;
   logic             imem_gnt;
   logic [     31:0] imem_addr;
   logic             imem_rvalid;
   logic [MEM_W-1:0] imem_rdata;
   generate
      if (ICACHE_SZ != 0) begin
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
      end else begin
         assign imem_req     = instr_req;
         assign imem_addr    = instr_addr;
         assign instr_gnt    = imem_gnt;
         assign instr_rvalid = imem_rvalid;
         assign instr_rdata  = imem_rdata[31:0];
      end
   endgenerate

   // data cache
   logic               dmem_req;
   logic               dmem_gnt;
   logic [       31:0] dmem_addr;
   logic               dmem_we;
   logic [MEM_W/8-1:0] dmem_be;
   logic [MEM_W  -1:0] dmem_wdata;
   logic               dmem_rvalid;
   logic               dmem_wvalid;
   logic [MEM_W  -1:0] dmem_rdata;
   generate
      if (DCACHE_SZ != 0) begin
         localparam int unsigned DCACHE_WAY_LEN = DCACHE_SZ / (DCACHE_LINE_W / 8) / 2;
         logic hold_mem = 0;
         cache #(
            .ADDR_BIT_W (32),
            .CPU_BYTE_W (MEM_W / 8),
            .MEM_BYTE_W (MEM_W / 8),
            .LINE_BYTE_W(DCACHE_LINE_W / 8),
            .WAY_LEN    (DCACHE_WAY_LEN)
         ) vcache (
            .clk_i       (clk_i),
            .rst_ni      (rst_ni),
            .hold_mem_i  (hold_mem),
            .cpu_req_i   (data_req),
            .cpu_addr_i  (data_addr),
            .cpu_we_i    (data_we),
            .cpu_be_i    (data_be),
            .cpu_wdata_i (data_wdata),
            .cpu_gnt_o   (data_gnt),
            .cpu_rvalid_o(data_rvalid),
            .cpu_rdata_o (data_rdata),
            .mem_req_o   (dmem_req),
            .mem_we_o    (dmem_we),
            .mem_addr_o  (dmem_addr),
            .mem_wdata_o (dmem_wdata),
            .mem_gnt_i   (dmem_gnt),
            .mem_rvalid_i(dmem_rvalid),
            .mem_rdata_i (dmem_rdata)
         );
         assign dmem_be = '1;
      end else begin

         assign dmem_req    = data_req;
         assign dmem_addr   = data_addr;
         assign dmem_we     = data_we;
         assign dmem_be     = data_be;
         assign dmem_wdata  = data_wdata;
         assign data_gnt    = dmem_gnt;
         assign data_rvalid = dmem_rvalid | dmem_wvalid;
         assign data_rdata  = dmem_rdata;
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
   assign imem_rdata = (ICACHE_SZ != 0) ? mem_rdata : mem_rdata[(imem_req_addr[0][$clog2(
      MEM_W
   )-1:0]&{3'b000, {($clog2(
      MEM_W/8
   )-2) {1'b1}}, 2'b00})*8+:32];
   assign dmem_rdata = mem_rdata;


   logic        sram_rvalid;
   logic [31:0] sram_rdata;
   logic        hwreg_rvalid;
   logic [31:0] hwreg_rdata;


   ram32 #(
      .SIZE     (RAM_SIZE / 4),
      .INIT_FILE(RAM_FPATH)
   ) u_ram (
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




   // -----------------
   // Peripheral buses
   // -----------------
   sbr_obi_req_t [NumPeriphs-1:0] all_periph_obi_req;
   sbr_obi_rsp_t [NumPeriphs-1:0] all_periph_obi_rsp;
   // ----------------------------------
   // Subordinate buses out of crossbar
   // ----------------------------------
   // Main xbar subordinate buses, must align with addr map indices!
   sbr_obi_req_t [NumSubordinates-1:0] all_sbr_obi_req;
   sbr_obi_rsp_t [NumSubordinates-1:0] all_sbr_obi_rsp;

   // user bus defined in module port

   // mem bank buses
   sbr_obi_req_t [NumBanks-1:0] xbar_mem_bank_obi_req;
   sbr_obi_rsp_t [NumBanks-1:0] xbar_mem_bank_obi_rsp;
   // periph bus
   sbr_obi_req_t xbar_periph_obi_req;
   sbr_obi_rsp_t xbar_periph_obi_rsp;

   assign xbar_periph_obi_req         = all_sbr_obi_req[XbarPeriph];
   assign all_sbr_obi_rsp[XbarPeriph] = xbar_periph_obi_rsp;




   // -----------------
   // Peripherals
   // -----------------

   // demultiplex to peripherals according to address map
   logic [cf_math_pkg::idx_width(NumPeriphs)-1:0] periph_idx;

   addr_decode #(
      .NoIndices(NumPeriphs),
      .NoRules  (NumPeriphRules),
      .addr_t   (logic [SbrObiCfg.DataWidth-1:0]),
      .rule_t   (addr_map_rule_t)
      // .Napot    (1'b0)
   ) i_addr_decode_periphs (
      .addr_i          (xbar_periph_obi_req.a.addr),
      .addr_map_i      (periph_addr_map),
      .idx_o           (periph_idx),
      .dec_valid_o     (),
      .dec_error_o     (),
      .en_default_idx_i(1'b1),
      .default_idx_i   ('0)
   );

   obi_demux #(
      .ObiCfg     (SbrObiCfg),
      .obi_req_t  (sbr_obi_req_t),
      .obi_rsp_t  (sbr_obi_rsp_t),
      .NumMgrPorts(NumPeriphs),
      .NumMaxTrans(2)
   ) i_obi_demux (
      .clk_i,
      .rst_ni,

      .sbr_port_select_i(periph_idx),
      .sbr_port_req_i   (xbar_periph_obi_req),
      .sbr_port_rsp_o   (xbar_periph_obi_rsp),

      .mgr_ports_req_o(all_periph_obi_req),
      .mgr_ports_rsp_i(all_periph_obi_rsp)
   );

endmodule
