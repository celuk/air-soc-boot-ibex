`timescale 1ns / 1ps

module tb_i2c_master;

    // Testbench sinyalleri
    reg clk_i;
    reg rst_i;
    reg scl_i;
    wire scl_o;
    reg sda_i;
    wire sda_o;
    reg [6:0] address_i;
    reg rd_wr_i;
    reg [31:0] write_data_i;
    reg [2:0] num_bytes_i;
    wire [31:0] read_data_o;
    reg start_i;
    wire start_aldim_o;
    wire ready_o;
    wire read_finished_o;
    wire write_finished_o;
    wire error_o;
    
    // I2C Master modülünün instance'ı
    i2c_master uut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .scl_i(scl_i),
        .scl_o(scl_o),
        .sda_i(sda_i),
        .sda_o(sda_o),
        .address_i(address_i),
        .rd_wr_i(rd_wr_i),
        .write_data_i(write_data_i),
        .num_bytes_i(num_bytes_i),
        .read_data_o(read_data_o),
        .start_i(start_i),
        .start_aldim_o(start_aldim_o),
        .ready_o(ready_o),
        .read_finished_o(read_finished_o),
        .write_finished_o(write_finished_o),
        .error_o(error_o)
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
//    sda_i;
    address_i = 7'b1100110;
    rd_wr_i = 1'b0; //yazma
    sda_i = 1'b0;
    write_data_i = 32'b110011001100110011001100_00001100;
    num_bytes_i = 3'b100;
    start_i = 1'b1;    

    end
    
    
endmodule
