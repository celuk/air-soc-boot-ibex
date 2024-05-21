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
    input  wire uart_rx_i,
    
    output wire spi_cs_o,
    output wire spi_sck_o,
    output wire spi_mosi_o,
    input  wire spi_miso_i,
    
    output wire pwm0_o,
    output wire pwm1_o

);

wire       data_we_o;
wire [3:0] data_be_o;

assign iomem_wstrb = data_we_o ? data_be_o : 4'h0;

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
    .instr_req_o              (iomem_valid),
    .instr_gnt_i              (iomem_ready),
    .instr_rvalid_i           (1'b1),
    .instr_addr_o             (iomem_addr),
    .instr_rdata_i            (iomem_rdata),

    // TODO: Always valid?
    // Data memory interface
    .data_req_o               (iomem_valid),
    .data_gnt_i               (iomem_ready),
    .data_rvalid_i            (1'b1),
    .data_we_o                (data_we_o),
    .data_be_o                (data_be_o),
    .data_addr_o              (iomem_addr),
    .data_wdata_o             (iomem_wdata),
    .data_rdata_i             (iomem_rdata),

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



endmodule
