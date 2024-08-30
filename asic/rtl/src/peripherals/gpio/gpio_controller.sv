// gpio_controller.sv
`timescale 1ns / 1ps

`include "header.vh"

module gpio_controller (
    input wire clk_i,
    input wire rst_i,
    
    input  wire [ 7:0] wb_adr_i,
    input  wire [31:0] wb_dat_i,
    input  wire        wb_we_i ,
    input  wire        wb_stb_i,
    input  wire [ 3:0] wb_sel_i,
    input  wire        wb_cyc_i,
    output reg         wb_ack_o,
    output reg  [31:0] wb_dat_o,

    input  [15:0] gpio_i,
    output [15:0] gpio_o
);

   reg [31:0] wb_read_data_r;
   reg [31:0] wb_read_data_next_r;
   assign wb_dat_o = wb_read_data_r;

   reg wb_ack_r;
   reg wb_ack_next_r;
   assign wb_ack_o = wb_ack_r;

   reg [31:0] GPIO_ODR;
   reg [31:0] GPIO_ODR_NEXT;

   reg [31:0] GPIO_IDR;
   reg [31:0] GPIO_IDR_NEXT;

   assign gpio_o = GPIO_ODR[15:0];

   always @* begin
      wb_ack_next_r = 0;
      wb_read_data_next_r = 0;

      GPIO_IDR_NEXT = 0;
      GPIO_ODR_NEXT = GPIO_ODR;

      GPIO_IDR_NEXT[15:0] = gpio_i;

      if(wb_cyc_i) begin
         wb_ack_next_r = wb_stb_i & !wb_ack_r;
         if(wb_stb_i & wb_we_i & !wb_ack_o) begin // write
            case(wb_adr_i)
               8'h04: begin
                  GPIO_ODR_NEXT[7:0  ] = wb_sel_i[0] ? wb_dat_i[7:0  ] : GPIO_ODR[7:0  ];
                  GPIO_ODR_NEXT[15:8 ] = wb_sel_i[1] ? wb_dat_i[15:8 ] : GPIO_ODR[15:8 ];
                  GPIO_ODR_NEXT[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : GPIO_ODR[23:16];
                  GPIO_ODR_NEXT[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : GPIO_ODR[31:24];
               end
            endcase
         end 
         else if(~wb_we_i) begin // read
            case(wb_adr_i)
               8'h00: begin
                  wb_read_data_next_r = GPIO_IDR;
               end
               8'h04: begin
                  wb_read_data_next_r = GPIO_ODR;
               end
            endcase
         end
      end
   end

   always @(posedge clk_i) begin
      if (rst_i) begin
         wb_ack_r <= 0;
         wb_read_data_r <= 0;

         GPIO_IDR <= 0;
         GPIO_ODR <= 0;
      end else begin
         wb_ack_r <= wb_ack_next_r;
         wb_read_data_r <= wb_read_data_next_r;

         GPIO_IDR <= GPIO_IDR_NEXT;
         GPIO_ODR <= GPIO_ODR_NEXT;
      end
   end

endmodule
