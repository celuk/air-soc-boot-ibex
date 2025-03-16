`timescale 1ns / 1ps

`include "header.vh"

module ram32 #(
   parameter SIZE = 16384,  // 64 K
   parameter INIT_FILE = ""
) (
   input clk_i,
   input rst_ni,

   input               req_i,
   input               we_i,
   input        [ 3:0] be_i,
   input        [31:0] addr_i,
   input        [31:0] wdata_i,
   output logic        rvalid_o,
   output logic [31:0] rdata_o

   ,output logic system_reset_o
);

   localparam int ADDR_W = $clog2(SIZE*4); // SIZE??

   logic [ADDR_W-1:0] mem_addr;
   assign mem_addr = addr_i[ADDR_W-1+2:2];

   function integer clogb2;
   input integer depth;
     for (clogb2=0; depth>0; clogb2=clogb2+1)
       depth = depth >> 1;
   endfunction
   
   localparam NB_COL = 4;
   localparam COL_WIDTH = 8;
   localparam RAM_DEPTH = SIZE*4;
   localparam ADDR_MSB = clogb2(RAM_DEPTH) + 1;
   localparam CPU_CLK   = `CPU_CLK;
   localparam BAUD_RATE = `BAUD_RATE;
   
   reg [(NB_COL*COL_WIDTH)-1:0] ram [RAM_DEPTH-1:0];

   reg [31:0] boot_rom_addr;
   wire [31:0] boot_rom_rdata;
   bootrom boot_mem (
      .addr_i(boot_rom_addr),
      .rdata_o(boot_rom_rdata)
   );

   /*
   always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
          if (`USE_BOOTROM) begin
             for (int i = 0; i < RAM_DEPTH; i++) begin
                boot_rom_addr = i;
                ram[i] = boot_rom_rdata;
             end
          end
          else begin
              for (int ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
                 ram[ram_index] = {(NB_COL*COL_WIDTH){1'b0}};
          end
          rdata_o <= 0;
      end
      else begin
          if (req_i && we_i) begin
              for (int i = 0; i < 4; i++) if (be_i[i] == 1'b1) ram[mem_addr][i*8+:8] <= wdata_i[i*8+:8];
          end
          rdata_o <= ram[mem_addr];
      end
   end
   */

   //int boot_index;

   always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
          if (`USE_BOOTROM) begin
              //boot_index <= 0;
              boot_rom_addr <= 0;
          end
          else begin
              for (int ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
                 ram[ram_index] <= {(NB_COL*COL_WIDTH){1'b0}};
          end
          rdata_o <= 0;
          rvalid_o <= '0;
          system_reset_o <= 0;
      end
      else begin
          if (`USE_BOOTROM && boot_rom_addr < RAM_DEPTH) begin
              //boot_rom_addr <= boot_index;
              ram[boot_rom_addr] <= boot_rom_rdata;
              boot_rom_addr <= boot_rom_addr + 1;
          end
          else if (req_i && we_i) begin
              for (int i = 0; i < 4; i++) 
                  if (be_i[i] == 1'b1) 
                      ram[mem_addr][i*8+:8] <= wdata_i[i*8+:8];
          end
          rdata_o <= ram[mem_addr];
          if (!(`USE_BOOTROM && boot_rom_addr < RAM_DEPTH)) begin
              rvalid_o <= req_i;
              system_reset_o <= 1;
          end
      end
   end

endmodule
