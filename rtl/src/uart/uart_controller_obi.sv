
module uart_controller_obi #(
   parameter int unsigned CLK_FREQ       = 50_000_000,
   parameter int unsigned UART_BAUD_RATE = 115200
) (
   input  logic        clk_i,
   input  logic        rst_ni,
   input  logic        req_i,
   input  logic        we_i,
   output logic        gnt_o,
   input  logic [15:0] addr_i,
   input  logic [31:0] wdata_i,
   output logic        rvalid_o,
   output logic [31:0] rdata_o,

   input  logic rx_i,
   output logic tx_o
);

   wire busy;
   uart_iface #(
      .CLK_FREQ (CLK_FREQ),
      .BAUD_RATE(UART_BAUD_RATE)
   ) uart (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .we_i    (req_i && we_i),
      .wdata_i (wdata_i[7:0]),
      .wbusy_o (busy),
      .read_i  (req_i && !we_i),
      .rvalid_o(rvalid_o),
      .rdata_o (rdata_o),

      .rx_i(rx_i),
      .tx_o(tx_o)
   );

   assign gnt_o = !busy;
   assign uart_req = req_i;

endmodule


module uart_iface #(
   parameter int unsigned CLK_FREQ  = 50_000_000,
   parameter int unsigned BAUD_RATE = 115200
) (
   input logic clk_i,
   input logic rst_ni,

   input  logic       we_i,
   input  logic [7:0] wdata_i,
   output logic       wbusy_o,
   input  logic       read_i,
   output logic       rvalid_o,
   output logic [7:0] rdata_o,

   input  logic rx_i,
   output logic tx_o
);

   localparam UART_RX_QUEUE_LEN = 8;

   logic tx_ready;
   uart_tx #(
      .DATA_WIDTH(8),
      .BAUD_RATE (BAUD_RATE),
      .CLK_FREQ  (CLK_FREQ)
   ) tx_inst (
      .clk_i  (clk_i),
      .rst_ni (rst_ni),
      .valid_i(we_i),
      .data_i (wdata_i),
      .ready_o(tx_ready),
      .tx_o   (tx_o)
   );
   assign wbusy_o = ~tx_ready;

   logic       rx_valid;
   logic [7:0] rx_data;
   uart_rx #(
      .DATA_WIDTH(8),
      .BAUD_RATE (BAUD_RATE),
      .CLK_FREQ  (CLK_FREQ)
   ) rx_inst (
      .clk_i  (clk_i),
      .rst_ni (rst_ni),
      .rx_i   (rx_i),
      .ready_i(1'b1),
      .valid_o(rx_valid),
      .data_o (rx_data)
   );

   logic       rvalid[UART_RX_QUEUE_LEN-1:0] = '{default: 0};
   logic [7:0] rdata [UART_RX_QUEUE_LEN-1:0] = '{default: 0};

   always_ff @(posedge clk_i) begin
      if (rvalid[0] == 0) begin
         for (int i = 0; i < UART_RX_QUEUE_LEN - 1; i++) begin
            rvalid[i] <= rvalid[i+1];
            rdata[i]  <= rdata[i+1];
         end
         rvalid[UART_RX_QUEUE_LEN-1] <= 0;
      end

      if (rx_valid) begin
         rvalid[UART_RX_QUEUE_LEN-1] <= 1;
         rdata[UART_RX_QUEUE_LEN-1]  <= rx_data;
      end
      if (rvalid[0] && read_i) rvalid[0] <= 0;
   end

   assign rvalid_o = rvalid[0];
   assign rdata_o  = rdata[0];
endmodule
