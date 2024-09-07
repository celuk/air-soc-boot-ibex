// uart_verici.v
`timescale 1ns / 1ps


// 1 bit start bit 8 veri bit no parity ve 1 stop bit
// gonderme circular queue araciligi ile yapilir.
module uart_tx (
   input  wire        clk_i,
   input  wire        rst_i,
   input  wire [31:0] baud_div_i,
   input  wire [1:0]  stop_bit_i,
   input  wire        stall_i,
   input  wire        we_i,
   input  wire [ 7:0] data_i,
   output reg         complete_o,
   output reg         tx_o
);

   reg [4:0] state;
   reg [4:0] next;

   wire [32:0] baud_div = baud_div_i;

   localparam IDLE       = 5'd0,
              START_BIT  = 5'd1,
              DATA_0     = 5'd2,
              DATA_1     = 5'd3,
              DATA_2     = 5'd4,
              DATA_3     = 5'd5,
              DATA_4     = 5'd6,
              DATA_5     = 5'd7,
              DATA_6     = 5'd8,
              DATA_7     = 5'd9,
              STOP_BIT0  = 5'd10;

   reg  [ 7:0] write_buffer;

   reg  [32:0] counter;
   reg         uart_clk_pulse;

   always @(posedge clk_i) begin
      if (rst_i) state <= IDLE;
      else if (uart_clk_pulse) state <= next;

      if (rst_i) begin
         counter        <= 0;
         uart_clk_pulse <= 0;
         complete_o     <= 0;
         write_buffer   <= 0;
      end else begin
         if (we_i) begin
            write_buffer <= data_i;
         end
         if (uart_clk_pulse) begin
            if ((state == STOP_BIT0) && (next == IDLE)) complete_o <= 1;
         end
         if (state == STOP_BIT0) begin
            casex (stop_bit_i)
               2'b00: begin
                  if (counter >= baud_div) begin
                     counter        <= 0;
                     uart_clk_pulse <= 1'b1;
                  end else begin
                     counter <= counter + 1;
                     uart_clk_pulse <= 1'b0;
                  end
               end
               2'b01: begin
                  if (counter >= baud_div / 2 * 3) begin
                     counter        <= 0;
                     uart_clk_pulse <= 1'b1;
                  end else begin
                     counter <= counter + 1;
                     uart_clk_pulse <= 1'b0;
                  end
               end
               2'b1x: begin
                  if (counter >= baud_div * 2) begin
                     counter        <= 0;
                     uart_clk_pulse <= 1'b1;
                  end else begin
                     counter <= counter + 1;
                     uart_clk_pulse <= 1'b0;
                  end
               end
            endcase
         end else begin
            if (counter == baud_div) begin
               counter        <= 0;
               uart_clk_pulse <= 1'b1;
            end else begin
               counter <= counter + 1;
               uart_clk_pulse <= 1'b0;
            end
         end
      end
   end

   always @(*) begin
      case (state)
         IDLE:       if (~stall_i) next = START_BIT;
                     else next = IDLE;
         START_BIT: next = DATA_0;
         DATA_0:    next = DATA_1;
         DATA_1:    next = DATA_2;
         DATA_2:    next = DATA_3;
         DATA_3:    next = DATA_4;
         DATA_4:    next = DATA_5;
         DATA_5:    next = DATA_6;
         DATA_6:    next = DATA_7;
         DATA_7:    next = STOP_BIT0;
         STOP_BIT0: next = IDLE;
         default:   next = IDLE;
      endcase
   end
   always @(*) begin
      case (state)
         IDLE:      tx_o = 1'b1;
         START_BIT: tx_o = 1'b0;
         DATA_0:    tx_o = write_buffer[0];
         DATA_1:    tx_o = write_buffer[1];
         DATA_2:    tx_o = write_buffer[2];
         DATA_3:    tx_o = write_buffer[3];
         DATA_4:    tx_o = write_buffer[4];
         DATA_5:    tx_o = write_buffer[5];
         DATA_6:    tx_o = write_buffer[6];
         DATA_7:    tx_o = write_buffer[7];
         STOP_BIT0: tx_o = 1'b1;
         default:   tx_o = 1'b1;
      endcase
   end
endmodule
