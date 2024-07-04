// Copyright 2018 Robert Balas <balasr@student.ethz.ch>
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Wrapper for a RI5CY testbench, containing RI5CY, Memory and stdout peripheral
// Contributor: Robert Balas <balasr@student.ethz.ch>

`include "header.vh"

module cv32e40p_tb_subsystem #(
   parameter INSTR_RDATA_WIDTH = 32,
   parameter RAM_ADDR_WIDTH = 20,
   parameter BOOT_ADDR = 'h0,
   parameter PULP_XPULP = 0,
   parameter PULP_CLUSTER = 0,
   parameter FPU = 0,
   parameter FPU_ADDMUL_LAT = 0,
   parameter FPU_OTHERS_LAT = 0,
   parameter ZFINX = 0,
   parameter NUM_MHPMCOUNTERS = 1,
   parameter DM_HALTADDRESS = 32'h1A110800
) (
   input logic clk_i,
   input logic rst_ni,

   input  logic        fetch_enable_i,
   output logic        tests_passed_o,
   output logic        tests_failed_o,
   output logic [31:0] exit_value_o,
   output logic        exit_valid_o,
   
   input  uart_rx_i,
   output uart_tx_o
);

   // signals connecting core to memory
   logic                         instr_req;
   logic                         instr_gnt;
   logic                         instr_rvalid;
   logic [                 31:0] instr_addr;
   logic [INSTR_RDATA_WIDTH-1:0] instr_rdata;

   logic                         data_req;
   logic                         data_gnt;
   logic                         data_rvalid;
   logic [                 31:0] data_addr;
   logic                         data_we;
   logic [                  3:0] data_be;
   logic [                 31:0] data_rdata;
   logic [                 31:0] data_wdata;
   logic [                  5:0] data_atop = 6'b0;

   // signals to debug unit
   logic                         debug_req_i;

   // irq signals
   logic                         irq_ack;
   logic [                  4:0] irq_id_out;
   logic                         irq_software;
   logic                         irq_timer;
   logic                         irq_external;
   logic [                 15:0] irq_fast;

   logic                         core_sleep_o;


   logic [                 31:0] mpu_rd_data;
   wire mpu_gnt;

   assign debug_req_i = 1'b0;

   // instantiate the core
cv32e40p_top #(
    .COREV_PULP               ( `COREV_PULP ),
    .COREV_CLUSTER            ( `COREV_CLUSTER ),
    .FPU                      ( `FPU ),
    .FPU_ADDMUL_LAT           ( `FPU_ADDMUL_LAT ),
    .FPU_OTHERS_LAT           ( `FPU_OTHERS_LAT ),
    .ZFINX                    ( `ZFINX ),
    .NUM_MHPMCOUNTERS         ( `NUM_MHPMCOUNTERS )
)
top_i (
    .clk_i                    (clk_i),
    .rst_ni                   (rst_ni),

    .pulp_clock_en_i          (`PULP_CLOCK_EN), // PULP clock enable (only used if COREV_CLUSTER = 1)
    .scan_cg_en_i             (`SCAN_CG_EN), // Enable all clock gates for testing

    // Configuration
    .boot_addr_i              (BOOT_ADDR),
    .mtvec_addr_i             (`MTVEC_ADDR),
    .dm_halt_addr_i           (`DM_HALT_ADDR),
    .hart_id_i                (`HART_ID),
    .dm_exception_addr_i      (`DM_EXCEPTION_ADDR),

      .instr_addr_o  (instr_addr),
      .instr_req_o   (instr_req),
      .instr_rdata_i (instr_rdata),
      .instr_gnt_i   (instr_gnt),
      .instr_rvalid_i(instr_rvalid),

      .data_addr_o  (data_addr),
      .data_wdata_o (data_wdata),
      .data_we_o    (data_we),
      .data_req_o   (data_req),
      .data_be_o    (data_be),
      .data_rdata_i (mpu_rd_data),
      .data_gnt_i   (mpu_gnt),
      .data_rvalid_i(data_rvalid),

      .irq_i    ({irq_fast, 4'b0, irq_external, 3'b0, irq_timer, 3'b0, irq_software, 3'b0}),
      .irq_ack_o(irq_ack),
      .irq_id_o (irq_id_out),

      .debug_req_i      (debug_req_i),
      .debug_havereset_o(),
      .debug_running_o  (),
      .debug_halted_o   (),

      .fetch_enable_i(fetch_enable_i),
      .core_sleep_o  (core_sleep_o)
   );



   // this handles read to RAM and memory mapped pseudo peripherals
   mm_ram #(
      .RAM_ADDR_WIDTH(RAM_ADDR_WIDTH),
      .INSTR_RDATA_WIDTH(INSTR_RDATA_WIDTH)
   ) ram_i (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .instr_req_i   (instr_req),
      .instr_addr_i  (instr_addr[RAM_ADDR_WIDTH-1:0]),
      .instr_rdata_o (instr_rdata),
      .instr_rvalid_o(instr_rvalid),
      .instr_gnt_o   (instr_gnt),

      .data_req_i   (data_req),
      .data_addr_i  (data_addr),
      .data_we_i    (data_we),
      .data_be_i    (data_be),
      .data_wdata_i (data_wdata),
      .data_rdata_o (data_rdata),
      .data_rvalid_o(data_rvalid),
      .data_gnt_o   (data_gnt),
      .data_atop_i  (data_atop),

      .irq_id_i (irq_id_out),
      .irq_ack_i(irq_ack),

      // output irq lines to Core
      .irq_software_o(irq_software),
      .irq_timer_o   (irq_timer),
      .irq_external_o(irq_external),
      .irq_fast_o    (irq_fast),

      .pc_core_id_i(top_i.core_i.pc_id),

      .tests_passed_o(tests_passed_o),
      .tests_failed_o(tests_failed_o),
      .exit_valid_o  (exit_valid_o),
      .exit_value_o  (exit_value_o)
   );

assign dp_sel = data_addr[31:20] == 12'h200 ? 1 : 1'b0; // data_req = 1?

wire dp_stall;
assign mpu_gnt = data_gnt || ~dp_sel;

wire [31:0] dp_rd_data;
assign mpu_rd_data  = data_addr[31:20] == 12'h200 ? dp_rd_data : data_rdata;

wire dp_wdata;
assign dp_wdata = data_wdata; /*(data_be == 4'b0001 || data_be == 4'b0010 || data_be == 4'b0100 || data_be == 4'b1000 ) ? (data_wdata << (mylog2(data_be)*8)) :
                     (data_be == 4'b0011 || data_be == 4'b1100) ? ((data_be[3]) ? (data_wdata << 16) : data_be ) :
                      data_be == 4'b1111  ?  data_wdata :
                                              data_wdata ;*/
function automatic [1:0] mylog2;
      input [3:0] data;
      begin
          mylog2 = data[0] ? 2'd0 :
                   data[1] ? 2'd1 :
                   data[2] ? 2'd2 :
                             2'd3 ;
      end
endfunction

datapath  datapath_dut (
    .clk_i (clk_i ),
    .rst_i (~rst_ni ),
    .dp_data_o        (dp_rd_data     ),
    .dp_stall_o       (dp_stall       ),
    .dp_data_i        (dp_wdata    ),
    .dp_addr_i        (data_addr       ),
    .dp_data_mask_i   (data_be       ),
    .dp_sel_i         (dp_sel         ),

    .uart_tx_o  (uart_tx_o ),
    .uart_rx_i  (uart_rx_i )
/*
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
*/
);

endmodule  // cv32e40p_tb_subsystem
