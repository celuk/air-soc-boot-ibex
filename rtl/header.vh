`define COREV_PULP       1'b0
`define COREV_CLUSTER    1'b0
`define FPU              1'b0
`define FPU_ADDMUL_LAT   1'b0
`define FPU_OTHERS_LAT   1'b0
`define ZFINX            1'b0
`define NUM_MHPMCOUNTERS 1'b1  

`define BOOT_ADDR 32'h00000180
`define MTVEC_ADDR 32'h0
`define DM_HALT_ADDR 32'h1A110800

`define PULP_CLOCK_EN 1'b0
`define SCAN_CG_EN 1'b0

`define HART_ID 32'h0
`define DM_EXCEPTION_ADDR 32'h0
