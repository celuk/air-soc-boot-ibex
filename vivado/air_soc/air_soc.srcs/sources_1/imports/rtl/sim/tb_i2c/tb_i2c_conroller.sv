`timescale 1ns / 1ps

module tb_i2c_controller();

    reg           clk_i;
    reg           rst_i;
    reg   [7:0]   wb_adr_i;
    reg   [31:0]  wb_dat_i;
    reg           wb_we_i;
    reg           wb_stb_i;
    reg   [3:0]   wb_sel_i;
    reg           wb_cyc_i;
    wire          wb_ack_o;
    wire  [31:0]  wb_dat_o;
    reg           sda_i;
    wire          sda_o;
    reg           scl_i; 
    wire          scl_o;


    i2c_controller controller_uut(
    .clk_i       (clk_i),
    .rst_i       (rst_i),
    .wb_adr_i    (wb_adr_i),
    .wb_dat_i    (wb_dat_i),
    .wb_we_i     (wb_we_i),
    .wb_stb_i    (wb_stb_i),
    .wb_sel_i    (wb_sel_i),
    .wb_cyc_i    (wb_cyc_i),
    .wb_ack_o    (wb_ack_o),
    .wb_dat_o    (wb_dat_o),
    .sda_i       (sda_i),
    .sda_o       (sda_o),
    .scl_i       (scl_i), 
    .scl_o       (scl_o)
    );

    always begin
        clk_i = 1'b1;
        #5;
        clk_i = 1'b0;
        #5;
    end

    initial begin
        
        rst_i = 1'b1;
        #50;
        rst_i = 1'b0;
        #50;
        wb_adr_i = 32'd35;
        wb_dat_i = 32'd35;
        wb_we_i = 1'b1;
       
        wb_stb_i = 1'b1;
        wb_sel_i = 4'b1111;
        wb_cyc_i = 1'b1;
    end



endmodule