// air_soc.sv
`timescale 1ns / 1ps
//
`default_nettype none


module obi_demux (
   input wire clk_i,
   input wire rst_ni,

   // CPU interface
   input  wire        data_req_i,
   output wire        data_gnt_o,
   output wire        data_rvalid_o,
   input  wire        data_we_i,
   input  wire [ 3:0] data_be_i,
   input  wire [31:0] data_addr_i,
   input  wire [31:0] data_wdata_i,
   output wire [31:0] data_rdata_o,

   // DCache interface
   output wire        cache_req_o,
   output wire [31:0] cache_addr_o,
   output wire        cache_we_o,
   output wire [ 3:0] cache_be_o,
   output wire [31:0] cache_wdata_o,
   input  wire        cache_gnt_i,
   input  wire        cache_rvalid_i,
   input  wire [31:0] cache_rdata_i,

   // UART interface
   output wire        uart_req_o,
   output wire [31:0] uart_addr_o,
   output wire        uart_we_o,
   output wire [ 3:0] uart_be_o,
   output wire [31:0] uart_wdata_o,
   input  wire        uart_gnt_i,
   input  wire        uart_rvalid_i,
   input  wire [31:0] uart_rdata_i
);

   // verilog_format: off
   localparam [31:0] MEM_BASE_ADDR  = 32'h0000_0000;
   localparam [31:0] UART_BASE_ADDR = 32'h2000_0000;
   localparam [31:0] MEM_RANGE  = 32'h0008_0000;
   localparam [31:0] UART_RANGE = 32'h0001_0000;
   // verilog_format: on

   reg         data_req;
   reg         data_we;
   reg  [ 3:0] data_be;
   reg  [31:0] data_addr;
   reg  [31:0] data_wdata;

   wire        periph_gnt;

   typedef enum {
      ZZZZZ,
      ERROR,
      CACHE,
      UART
   } selected_periph_t;

   typedef enum {
      IDLE,
      WAITING
   } state_t;

   state_t state;
   selected_periph_t periph;

   assign cache_addr_o = data_addr;
   assign uart_addr_o = data_addr;

   assign cache_wdata_o = data_wdata;
   assign uart_wdata_o = data_wdata;

   assign cache_req_o = (MEM_BASE_ADDR + MEM_RANGE > data_addr) && (data_addr >= MEM_BASE_ADDR) ? data_req : 'h0;
   assign cache_we_o =  (MEM_BASE_ADDR + MEM_RANGE > data_addr) && (data_addr >= MEM_BASE_ADDR) ? data_we : 'h0;
   assign cache_be_o =  (MEM_BASE_ADDR + MEM_RANGE > data_addr) && (data_addr >= MEM_BASE_ADDR) ? data_be : 'h0;

   assign uart_req_o = (UART_BASE_ADDR + UART_RANGE > data_addr) && (data_addr >= UART_BASE_ADDR) ? data_req : 'h0;
   assign uart_we_o = (UART_BASE_ADDR + UART_RANGE > data_addr ) && (data_addr >= UART_BASE_ADDR) ? data_we : 'h0;
   assign uart_be_o = (UART_BASE_ADDR + UART_RANGE > data_addr ) && (data_addr >= UART_BASE_ADDR) ? data_be : 'h0;



   assign data_rdata_o = (MEM_BASE_ADDR+MEM_RANGE   > data_addr) && (data_addr >= MEM_BASE_ADDR ) ? cache_rdata_i :
                         (UART_BASE_ADDR+UART_RANGE > data_addr) && (data_addr >= UART_BASE_ADDR) ? uart_rdata_i  :
                                                                                                    32'h0         ;

   assign data_rvalid_o= (MEM_BASE_ADDR+MEM_RANGE   >= data_addr) && (data_addr >= MEM_BASE_ADDR ) ? cache_rvalid_i :
                         (UART_BASE_ADDR+UART_RANGE >= data_addr) && (data_addr >= UART_BASE_ADDR) ? uart_rvalid_i  :
                                                                                                      32'h0         ;

   assign periph_gnt   = (MEM_BASE_ADDR+MEM_RANGE   > data_addr) && (data_addr >= MEM_BASE_ADDR ) ? cache_gnt_i :
                         (UART_BASE_ADDR+UART_RANGE > data_addr) && (data_addr >= UART_BASE_ADDR) ? uart_gnt_i  :
                                                                                                      'h0       ;

   assign data_gnt_o = (state == IDLE) & periph_gnt;


   always @(posedge clk_i) begin
      if (!rst_ni) begin
         state <= IDLE;
         periph <= ZZZZZ;

         data_req <= 0;
         data_we <= 0;
         data_be <= 0;
         data_addr <= 0;
         data_wdata <= 0;

      end else begin
         case (state)
            IDLE: begin
               if (data_req_i & data_gnt_o) begin
                  state <= WAITING;
               end
            end
            WAITING: begin
               if (data_rvalid_o) state <= IDLE;
               if (data_req & periph_gnt) data_req <= 0;
            end
         endcase

         case (state)
            IDLE: begin
               data_req <= data_req_i;
               data_we <= data_we_i;
               data_be <= data_be_i;
               data_addr <= data_addr_i;
               data_wdata <= data_wdata_i;
            end
            default: begin
            end
         endcase

         periph  <= (MEM_BASE_ADDR+MEM_RANGE   > data_addr) && (data_addr >= MEM_BASE_ADDR ) ? CACHE :
                    (UART_BASE_ADDR+UART_RANGE > data_addr) && (data_addr >= UART_BASE_ADDR) ? UART  :
                                                                                               ERROR ;
      end
   end
endmodule
