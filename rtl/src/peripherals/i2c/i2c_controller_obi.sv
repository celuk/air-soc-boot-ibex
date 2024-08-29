
module i2c_controller_obi (
   input  wire        clk_i,
   input  wire        rst_ni,
   input  wire        req_i,
   input  wire        we_i,
   input  wire [ 3:0] be_i,
   output wire        gnt_o,
   input  wire [31:0] addr_i,
   input  wire [31:0] wdata_i,
   output reg         rvalid_o,
   output reg  [31:0] rdata_o,
   input  wire sda_i,
   output wire sda_o,
   input  wire scl_i,
   output wire scl_o,
   output wire sda_out_en_o,
   output wire scl_out_en_o
);

   reg         wb_cyc_r = 0;
   reg         wb_stb_r = 0;
   wire        wb_ack_w = 0;
   wire [31:0] wb_dat_o_w = 0;

   i2c_controller i2c_iface_dut (
      .clk_i   (clk_i),
      .rst_i   (~rst_ni),
      .wb_adr_i(addr_i),
      .wb_dat_i(wdata_i),
      .wb_we_i (we_i),
      .wb_stb_i(wb_stb_r),
      .wb_sel_i(be_i),
      .wb_cyc_i(wb_cyc_r),
      .wb_ack_o(wb_ack_w),
      .wb_dat_o(wb_dat_o_w),
      .sda_i   (sda_i),
      .sda_o   (sda_o),
      .scl_i   (scl_i),
      .scl_o   (scl_o),
      .sda_out_en_o(sda_out_en_o),
      .scl_out_en_o(scl_out_en_o)
   );

   always @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
         wb_cyc_r <= 1'b0;
         wb_stb_r <= 1'b0;
         rvalid_o <= 1'b0;
         rdata_o  <= 32'b0;
      end else begin
         if (req_i && gnt_o) begin
            wb_cyc_r <= 1'b1;
            wb_stb_r <= 1'b1;
         end else if (wb_ack_w) begin
            wb_cyc_r <= 1'b0;
            wb_stb_r <= 1'b0;
         end

         rvalid_o <= wb_ack_w;
         if (wb_ack_w) begin
            rdata_o <= wb_dat_o_w;
         end
      end
   end

   assign gnt_o = ~wb_cyc_r;

endmodule
