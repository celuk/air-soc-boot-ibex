// Copyright 2017 Embecosm Limited <www.embecosm.com>
// Copyright 2018 Robert Balas <balasr@student.ethz.ch>
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Top level wrapper for a RI5CY testbench
// Contributor: Robert Balas <balasr@student.ethz.ch>
//              Jeremy Bennett <jeremy.bennett@embecosm.com>

module soc_top #(
    parameter INSTR_RDATA_WIDTH = 32,
    parameter RAM_ADDR_WIDTH = 22,
    parameter BOOT_ADDR = `BOOT_ADDR,
    parameter PULP_XPULP = 0,
    parameter PULP_CLUSTER = 0,
    parameter FPU = `FPU,
    parameter ZFINX = `ZFINX,
    parameter NUM_MHPMCOUNTERS = `NUM_MHPMCOUNTERS,
    parameter DM_HALTADDRESS = `DM_HALT_ADDR
)(
  input  clk_p,
  input  clk_n,
  input  rst_ni,
  input  program_rx_i,
  output prog_mode_led_o,

  output uart_tx_o

);

wire uart_rx_i;

wire clk_i;
wire dummy;
clk_wiz_0 dutclk (
  .clk_out1(clk_i),
  .clk_in1_p(clk_p),
  .clk_in1_n(clk_n),
  .reset(~rst_ni),
  .locked(dummy)
);

/*
  initial begin
    $readmemh("/home/shc/projects/tekno-kizil/testler/uart-demo/main_static.hex", wrapper_i.ram_i.dp_ram_i.mem);
  end
*/
reg [7:0] mem [0:4095];
reg [31:0] temp_mem [0:1023];
integer i;

initial begin
  $readmemh("/home/shc/projects/tekno-kizil/testler/uart-demo/main_static.hex", temp_mem);
  
  for (i = 0; i < 1024; i = i + 1) begin
    mem[i*4]     = temp_mem[i][7:0];
    mem[i*4 + 1] = temp_mem[i][15:8];
    mem[i*4 + 2] = temp_mem[i][23:16];
    mem[i*4 + 3] = temp_mem[i][31:24];
  end
end
  
  cv32e40p_tb_subsystem #(
      .INSTR_RDATA_WIDTH(INSTR_RDATA_WIDTH),
      .RAM_ADDR_WIDTH   (RAM_ADDR_WIDTH),
      .BOOT_ADDR        (BOOT_ADDR),
      .PULP_XPULP       (PULP_XPULP),
      .PULP_CLUSTER     (PULP_CLUSTER),
      .FPU              (FPU),
      .ZFINX            (ZFINX),
      .NUM_MHPMCOUNTERS (NUM_MHPMCOUNTERS),
      .DM_HALTADDRESS   (DM_HALTADDRESS)
  ) wrapper_i (
      .clk_i         (clk_i),
      .rst_ni        (rst_ni),
      .fetch_enable_i(1'b1),
      .uart_rx_i(uart_rx_i),
      .uart_tx_o(uart_tx_o),
      .tests_passed_o(),
      .tests_failed_o(),
      .exit_valid_o  (),
      .exit_value_o  ()
  );

endmodule  // tb_top
