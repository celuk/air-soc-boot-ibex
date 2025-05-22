// dram_controller.sv
`timescale 1ns / 1ps

`include "header.vh"

module dram_controller (
   input wire clk_i,
   input wire rst_i,

   input  wire [ 7:0] wb_adr_i,
   input  wire [31:0] wb_dat_i,
   input  wire        wb_we_i ,
   input  wire        wb_stb_i,
   input  wire [ 3:0] wb_sel_i,
   input  wire        wb_cyc_i,
   output        wb_ack_o,
   output [31:0] wb_dat_o

   ,output ddr3_reset_n
   ,output ddr3_cke
   ,output ddr3_ck_p
   ,output ddr3_ck_n
   ,output ddr3_cs_n
   ,output ddr3_ras_n
   ,output ddr3_cas_n
   ,output ddr3_we_n
   ,output [2:0] ddr3_ba
   ,output [13:0] ddr3_addr
   ,output ddr3_odt
   ,output [1:0] ddr3_dm
   ,inout [1:0] ddr3_dqs_p
   ,inout [1:0] ddr3_dqs_n
   ,inout [15:0] ddr3_dq

   ,input clk100
   ,input clk_ddr
   ,input clk_ref
   ,input clk_ddr_dqs
);

    wire ddr3_reset_i;
 
    reg we_r;
    reg re_r;
    reg [31:0] adr_r;
    reg [31:0] data_write_r;
    wire [31:0] data_read_w;
 
    `ifdef ZC706
    wire [31:0]  ram_addr = adr_r;
    wire         ram_wr = we_r;
    wire [127:0] ram_wr_data = {96'h0, data_write_r};
    wire         ram_rd = re_r;
    wire [127:0] ram_rd_data;
    wire         ram_accept;
    wire         ram_ack;
 
    reg [15:0] ram_req_id = 0;
 
    assign data_read_w = ram_rd_data[31:0];
 
    ddr3_controller 
    #(
       .DDR_MHZ(`DDR_MHZ)
    )
    ddr3_controller_inst(
       // user ports
       .rst_i(reset_i),
       `ifdef DDR_100MHZ
       .clk(clk100),
       `else
       .clk(clk_i),
       `endif
       .clk_ddr(clk_ddr),
       .clk_ref(clk_ref),
       .clk_ddr_dqs(clk_ddr_dqs),
       .ram_addr(ram_addr),
       .wr_en(ram_wr),
       .wr_data(ram_wr_data),
       .rd_en(ram_rd),
       .rd_data(ram_rd_data),
       .accepted(ram_accept),
       .acked(ram_ack),
       // io ports
       .ddr3_reset_n(ddr3_reset_n),
       .ddr3_cke(ddr3_cke),
       .ddr3_ck_p(ddr3_ck_p),
       .ddr3_ck_n(ddr3_ck_n),
       .ddr3_ras_n(ddr3_ras_n),
       .ddr3_cas_n(ddr3_cas_n),
       .ddr3_we_n(ddr3_we_n),
       .ddr3_ba(ddr3_ba),
       .ddr3_addr(ddr3_addr),
       .ddr3_odt(ddr3_odt),
       .ddr3_dm(ddr3_dm),
       .ddr3_dqs_p(ddr3_dqs_p),
       .ddr3_dqs_n(ddr3_dqs_n),
       .ddr3_dq(ddr3_dq),
       .ddr3_cs_n(ddr3_cs_n)
 
       ,.ram_req_id(0)
    );
    `else
    wire [127:0]  ram_rd_data = 0;
    wire         ram_accept = 1;
    wire         ram_ack = 1;
 
    assign data_read_w = ram_rd_data[31:0];
    `endif
 
    `ifdef ZC706
    reg ram_accept_r = 0;
    reg ram_ack_r = 0;
    `else
    reg ram_accept_r = 1;
    reg ram_ack_r = 1;
    `endif

    reg [31:0] wb_read_data_r;
    reg [31:0] wb_read_data_next_r;
    assign wb_dat_o = wb_read_data_r;

    reg wb_ack_r;
    reg wb_ack_next_r;
    assign wb_ack_o = wb_ack_r;
 
    reg [31:0] DRAM_COMMAND;
    reg [31:0] DRAM_COMMAND_NEXT;
    reg [31:0] DRAM_ADDRESS;
    reg [31:0] DRAM_ADDRESS_NEXT;
    reg [31:0] DRAM_DATA_WRITE;
    reg [31:0] DRAM_DATA_WRITE_NEXT;
    reg [31:0] DRAM_DATA_READ;
    reg [31:0] DRAM_DATA_READ_NEXT;
    reg [31:0] DRAM_TIMER_RESET;
    reg [31:0] DRAM_TIMER_RESET_NEXT;
    reg [31:0] DRAM_TIMER;
    reg [31:0] DRAM_TIMER_NEXT;
    reg [31:0] DRAM_RE;
    reg [31:0] DRAM_RE_NEXT;
    reg [31:0] DRAM_WE;
    reg [31:0] DRAM_WE_NEXT;
    reg [31:0] DRAM_ACCEPT;
    reg [31:0] DRAM_ACCEPT_NEXT;
    reg [31:0] DRAM_ACK;
    reg [31:0] DRAM_ACK_NEXT;
    
    always @* begin
        wb_ack_next_r = 0;
        wb_read_data_next_r = 0;
    
        DRAM_COMMAND_NEXT = DRAM_COMMAND;
        DRAM_ADDRESS_NEXT = DRAM_ADDRESS;
        DRAM_DATA_WRITE_NEXT = DRAM_DATA_WRITE;
        DRAM_DATA_READ_NEXT = DRAM_DATA_READ;
        DRAM_TIMER_RESET_NEXT = DRAM_TIMER_RESET;
        DRAM_TIMER_NEXT = DRAM_TIMER;
        DRAM_RE_NEXT = DRAM_RE;
        DRAM_WE_NEXT = DRAM_WE;
        DRAM_ACCEPT_NEXT = DRAM_ACCEPT;
        DRAM_ACK_NEXT = DRAM_ACK;
    
        if(wb_cyc_i) begin
            wb_ack_next_r = wb_stb_i & !wb_ack_r;
            if(wb_stb_i & wb_we_i & !wb_ack_o) begin // write
                case(wb_adr_i)
                    8'h00: begin
                        DRAM_COMMAND_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : DRAM_COMMAND[7:0  ];
                        DRAM_COMMAND_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : DRAM_COMMAND[15:8 ];
                        DRAM_COMMAND_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : DRAM_COMMAND[23:16];
                        DRAM_COMMAND_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : DRAM_COMMAND[31:24];
                    end
                    8'h04: begin
                        DRAM_ADDRESS_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : DRAM_ADDRESS[7:0  ];
                        DRAM_ADDRESS_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : DRAM_ADDRESS[15:8 ];
                        DRAM_ADDRESS_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : DRAM_ADDRESS[23:16];
                        DRAM_ADDRESS_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : DRAM_ADDRESS[31:24];
                    end
                    8'h08: begin
                        DRAM_DATA_WRITE_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : DRAM_DATA_WRITE[7:0  ];
                        DRAM_DATA_WRITE_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : DRAM_DATA_WRITE[15:8 ];
                        DRAM_DATA_WRITE_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : DRAM_DATA_WRITE[23:16];
                        DRAM_DATA_WRITE_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : DRAM_DATA_WRITE[31:24];
                    end
                    8'h0C: begin
                        DRAM_DATA_READ_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : DRAM_DATA_READ[7:0  ];
                        DRAM_DATA_READ_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : DRAM_DATA_READ[15:8 ];
                        DRAM_DATA_READ_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : DRAM_DATA_READ[23:16];
                        DRAM_DATA_READ_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : DRAM_DATA_READ[31:24];
                    end
                    8'h10: begin
                        DRAM_TIMER_RESET_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : DRAM_TIMER_RESET[7:0  ];
                        DRAM_TIMER_RESET_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : DRAM_TIMER_RESET[15:8 ];
                        DRAM_TIMER_RESET_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : DRAM_TIMER_RESET[23:16];
                        DRAM_TIMER_RESET_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : DRAM_TIMER_RESET[31:24];
                    end
                    8'h14: begin
                        DRAM_TIMER_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : DRAM_TIMER[7:0  ];
                        DRAM_TIMER_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : DRAM_TIMER[15:8 ];
                        DRAM_TIMER_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : DRAM_TIMER[23:16];
                        DRAM_TIMER_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : DRAM_TIMER[31:24];
                    end
                    8'h18: begin
                        DRAM_RE_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : DRAM_RE[7:0  ];
                        DRAM_RE_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : DRAM_RE[15:8 ];
                        DRAM_RE_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : DRAM_RE[23:16];
                        DRAM_RE_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : DRAM_RE[31:24];
                    end
                    8'h1C: begin
                        DRAM_WE_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : DRAM_WE[7:0  ];
                        DRAM_WE_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : DRAM_WE[15:8 ];
                        DRAM_WE_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : DRAM_WE[23:16];
                        DRAM_WE_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : DRAM_WE[31:24];
                    end
                    8'h20: begin
                        DRAM_ACCEPT_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : DRAM_ACCEPT[7:0  ];
                        DRAM_ACCEPT_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : DRAM_ACCEPT[15:8 ];
                        DRAM_ACCEPT_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : DRAM_ACCEPT[23:16];
                        DRAM_ACCEPT_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : DRAM_ACCEPT[31:24];
                    end
                    8'h24: begin
                        DRAM_ACK_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : DRAM_ACK[7:0  ];
                        DRAM_ACK_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : DRAM_ACK[15:8 ];
                        DRAM_ACK_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : DRAM_ACK[23:16];
                        DRAM_ACK_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : DRAM_ACK[31:24];
                    end
                endcase
            end 
            else if(~wb_we_i) begin // read
                case(wb_adr_i)
                    8'h00: wb_read_data_next_r = DRAM_COMMAND;
                    8'h04: wb_read_data_next_r = DRAM_ADDRESS;
                    8'h08: wb_read_data_next_r = DRAM_DATA_WRITE;
                    8'h0C: wb_read_data_next_r = DRAM_DATA_READ;
                    8'h10: wb_read_data_next_r = DRAM_TIMER_RESET;
                    8'h14: wb_read_data_next_r = DRAM_TIMER;
                    8'h18: wb_read_data_next_r = DRAM_RE;
                    8'h1C: wb_read_data_next_r = DRAM_WE;
                    8'h20: wb_read_data_next_r = DRAM_ACCEPT;
                    8'h24: wb_read_data_next_r = DRAM_ACK;
                endcase
            end
        end
    end
    
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            wb_ack_r <= 0;
            wb_read_data_r <= 0;
    
            DRAM_COMMAND <= 0;
            DRAM_ADDRESS <= 0;
            DRAM_DATA_WRITE <= 0;
            DRAM_DATA_READ <= 0;
            DRAM_TIMER_RESET <= 0;
            DRAM_TIMER <= 0;
            DRAM_RE <= 0;
            DRAM_WE <= 0;
            DRAM_ACCEPT <= 0;
            DRAM_ACK <= 0;
        end else begin
            wb_ack_r <= wb_ack_next_r;
            wb_read_data_r <= wb_read_data_next_r;
    
            DRAM_COMMAND <= DRAM_COMMAND_NEXT;
            DRAM_ADDRESS <= DRAM_ADDRESS_NEXT;
            DRAM_DATA_WRITE <= DRAM_DATA_WRITE_NEXT;
            DRAM_DATA_READ <= DRAM_DATA_READ_NEXT;
            DRAM_TIMER_RESET <= DRAM_TIMER_RESET_NEXT;
            DRAM_TIMER <= DRAM_TIMER_NEXT;
            DRAM_RE <= DRAM_RE_NEXT;
            DRAM_WE <= DRAM_WE_NEXT;
            DRAM_ACCEPT <= DRAM_ACCEPT_NEXT;
            DRAM_ACK <= DRAM_ACK_NEXT;
        end
    end

endmodule
