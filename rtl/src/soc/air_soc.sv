// air_soc.sv
`timescale 1ns / 1ps

`include "header.vh"

module air_soc #(
        parameter int unsigned     MEM_W         = 32,  // memory bus width in bits
        parameter int unsigned     ICACHE_SZ     = 0,   // instruction cache size in bytes
        parameter int unsigned     ICACHE_LINE_W = 128, // instruction cache line width in bits
        parameter int unsigned     DCACHE_SZ     = 0,   // data cache size in bytes
        parameter int unsigned     DCACHE_LINE_W = 512  // data cache line width in bits
    )(
        input  logic               clk_i,
        input  logic               rst_ni,

        output logic               mem_req_o,
        output logic [31:0]        mem_addr_o,
        output logic               mem_we_o,
        output logic [3:0] mem_be_o,
        output logic [31:0] mem_wdata_o,
        input  logic               mem_rvalid_i,
        input  logic [31:0] mem_rdata_i
    );

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
    logic  [3:0] sdata_be;
    logic [31:0] sdata_wdata;
    logic        sdata_gnt;
    logic        sdata_rvalid;
    logic [31:0] sdata_rdata;

cv32e40p_top #(
    .FPU                      ( 0 ),
    .FPU_ADDMUL_LAT           ( 0 ),
    .FPU_OTHERS_LAT           ( 0 ),
    .ZFINX                    ( 0 ),
    .COREV_PULP               ( 0 ),
    .COREV_CLUSTER            ( 0 ),
    .NUM_MHPMCOUNTERS         ( 1 )
) u_core (
    // Clock and reset
    .rst_ni                   (rst_ni),
    .clk_i                    (clk_i),
    .scan_cg_en_i             (1'b0),

    // Special control signals
    .fetch_enable_i           (1),
    .pulp_clock_en_i          (1'b0),
    .core_sleep_o             (),

    // Configuration
    .boot_addr_i              (32'h0000_0080),
    .mtvec_addr_i             (32'h0000_0000),
    .dm_halt_addr_i           (32'h00000000),
    .dm_exception_addr_i      (32'h00000000),
    .hart_id_i                (32'b0),

    // Instruction memory interface
    .instr_addr_o             (instr_addr),
    .instr_req_o              (instr_req),
    .instr_gnt_i              (instr_gnt),
    .instr_rvalid_i           (instr_rvalid),
    .instr_rdata_i            (instr_rdata),

    // Data memory interface
    .data_addr_o              (sdata_addr),
    .data_req_o               (sdata_req),
    .data_gnt_i               (sdata_gnt),
    .data_we_o                (sdata_we),
    .data_be_o                (sdata_be),
    .data_wdata_o             (sdata_wdata),
    .data_rvalid_i            (sdata_rvalid),
    .data_rdata_i             (sdata_rdata),

    // Interrupt interface
    .irq_i                    (0), //({14'b0, timer_bus.irq, gpio_bus.irq, 16'b0}), //4'b0, 0, 3'b0, 0, 3'b0, 0, 3'b0}),
    .irq_ack_o                (),
    .irq_id_o                 (),

    // Debug interface
    .debug_req_i              (1'b0),
    .debug_havereset_o        (),
    .debug_running_o          (),
    .debug_halted_o           ()
);


    // Data arbiter for main core
    logic                sdata_hold;
    logic                data_req;
    logic [31:0]         data_addr;
    logic                data_we;
    logic [MEM_W/8-1:0] data_be;
    logic [MEM_W  -1:0] data_wdata;
    logic                data_gnt;
    logic                data_rvalid;
    logic [MEM_W  -1:0] data_rdata;
    logic                sdata_waiting;
    logic [31:0]         sdata_wait_addr;
    assign sdata_hold = 0;
    always_comb begin
        data_req   = (sdata_req & ~sdata_hold);
        data_addr  = sdata_addr;
        data_we    = sdata_we;
        data_be    = {{(MEM_W-32){1'b0}}, sdata_be} << (sdata_addr[$clog2(MEM_W/8)-1:0] & {{$clog2(MEM_W/32){1'b1}}, 2'b00});
        data_wdata = '0;
        for (int i = 0; i < MEM_W / 32; i++) begin
            data_wdata[32*i +: 32] = sdata_wdata;
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
            end
            else if (sdata_rvalid) begin
                sdata_waiting <= 1'b0;
            end
        end
    end
    assign sdata_rvalid = sdata_waiting & data_rvalid;
    assign sdata_rdata  = data_rdata[(sdata_wait_addr[$clog2(MEM_W)-1:0] & {3'b000, {($clog2(MEM_W/8)-2){1'b1}}, 2'b00})*8 +: 32];

    // instruction cache
    logic             imem_req;
    logic             imem_gnt;
    logic [31:0]      imem_addr;
    logic             imem_rvalid;
    logic [MEM_W-1:0] imem_rdata;
    generate
        if (ICACHE_SZ != 0) begin
            localparam int unsigned ICACHE_WAY_LEN = ICACHE_SZ / (ICACHE_LINE_W / 8) / 2;
            cache #(
                .ADDR_BIT_W   ( 32                ),
                .CPU_BYTE_W   ( 4                 ),
                .MEM_BYTE_W   ( MEM_W / 8         ),
                .LINE_BYTE_W  ( ICACHE_LINE_W / 8 ),
                .WAY_LEN      ( ICACHE_WAY_LEN    )
            ) icache (
                .clk_i        ( clk_i             ),
                .rst_ni       ( rst_ni            ),
                .hold_mem_i   ( 1'b0              ),
                .cpu_req_i    ( instr_req         ),
                .cpu_addr_i   ( instr_addr        ),
                .cpu_we_i     ( '0                ),
                .cpu_be_i     ( '0                ),
                .cpu_wdata_i  ( '0                ),
                .cpu_gnt_o    ( instr_gnt         ),
                .cpu_rvalid_o ( instr_rvalid      ),
                .cpu_rdata_o  ( instr_rdata       ),
                .mem_req_o    ( imem_req          ),
                .mem_addr_o   ( imem_addr         ),
                .mem_we_o     (                   ),
                .mem_wdata_o  (                   ),
                .mem_gnt_i    ( imem_gnt          ),
                .mem_rvalid_i ( imem_rvalid       ),
                .mem_rdata_i  ( imem_rdata        )
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
    logic [31:0]        dmem_addr;
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
                .ADDR_BIT_W   ( 32                ),
                .CPU_BYTE_W   ( MEM_W / 8        ),
                .MEM_BYTE_W   ( MEM_W / 8         ),
                .LINE_BYTE_W  ( DCACHE_LINE_W / 8 ),
                .WAY_LEN      ( DCACHE_WAY_LEN    )
            ) vcache (
                .clk_i        ( clk_i             ),
                .rst_ni       ( rst_ni            ),
                .hold_mem_i   ( hold_mem          ),
                .cpu_req_i    ( data_req          ),
                .cpu_addr_i   ( data_addr         ),
                .cpu_we_i     ( data_we           ),
                .cpu_be_i     ( data_be           ),
                .cpu_wdata_i  ( data_wdata        ),
                .cpu_gnt_o    ( data_gnt          ),
                .cpu_rvalid_o ( data_rvalid       ),
                .cpu_rdata_o  ( data_rdata        ),
                .mem_req_o    ( dmem_req          ),
                .mem_we_o     ( dmem_we           ),
                .mem_addr_o   ( dmem_addr         ),
                .mem_wdata_o  ( dmem_wdata        ),
                .mem_gnt_i    ( dmem_gnt          ),
                .mem_rvalid_i ( dmem_rvalid       ),
                .mem_rdata_i  ( dmem_rdata        )
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
        mem_req_o   = imem_req | dmem_req;
        mem_addr_o  = imem_addr;
        mem_we_o    = 1'b0;
        mem_be_o    = dmem_be;
        mem_wdata_o = dmem_wdata;
        if (dmem_req) begin
            mem_we_o   = dmem_we;
            mem_addr_o = dmem_addr;
        end
    end
    assign imem_gnt = imem_req & ~dmem_req;
    assign dmem_gnt =             dmem_req;

    // shift register keeping track of the source of mem requests for up to 32 cycles
    logic        req_sources  [32];
    logic        req_write    [32]; // keeping track of whether the request was a write
    logic [31:0] imem_req_addr[32]; // keeping track of address for instruction memory requests
    logic [4:0]  req_count;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            req_count <= '0;
        end else begin
            if (mem_rvalid_i) begin
                for (int i = 0; i < 31; i++) begin
                    req_sources  [i] <= req_sources  [i+1];
                    req_write    [i] <= req_write    [i+1];
                    imem_req_addr[i] <= imem_req_addr[i+1];
                end
                if (~imem_gnt & ~dmem_gnt) begin
                    req_count <= req_count - 1;
                end else begin
                    req_sources  [req_count-1] <= dmem_gnt;
                    req_write    [req_count-1] <= dmem_we;
                    imem_req_addr[req_count-1] <= imem_addr;
                end
            end
            else if (imem_gnt | dmem_gnt) begin
                req_sources  [req_count] <= dmem_gnt;
                req_write    [req_count] <= dmem_we;
                imem_req_addr[req_count] <= imem_addr;
                req_count                <= req_count + 1;
            end
        end
    end
    assign imem_rvalid = mem_rvalid_i & ~req_sources[0];
    assign dmem_rvalid = mem_rvalid_i &  req_sources[0] & ~req_write[0];
    assign dmem_wvalid = mem_rvalid_i &  req_sources[0] &  req_write[0];
    assign imem_rdata  = (ICACHE_SZ != 0) ? mem_rdata_i : mem_rdata_i[
        (imem_req_addr[0][$clog2(MEM_W)-1:0] & {3'b000, {($clog2(MEM_W/8)-2){1'b1}}, 2'b00})*8 +: 32];
    assign dmem_rdata  = mem_rdata_i;

endmodule

