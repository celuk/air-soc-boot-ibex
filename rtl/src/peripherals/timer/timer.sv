`timescale 1ns / 1ps

module timer(
    input clk_i,
    input rst_i,
    input [31:0] TIM_PRE,
    input [31:0] TIM_ARE,
    input [31:0] TIM_CLR,
    input [31:0] TIM_ENA,
    input [31:0] TIM_MOD,
    input [31:0] TIM_EVC,
    output [31:0] TIM_CNT,
    output [31:0] TIM_EVN
);

reg [31:0] TIM_CNT_R;
reg [31:0] TIM_CNT_NEXT_R;
reg [31:0] TIM_EVN_R;
reg [31:0] TIM_EVN_NEXT_R;

assign TIM_CNT = TIM_CNT_R;
assign TIM_EVN = TIM_EVN_R;

reg [63:0] sayac;
reg [63:0] sayac_next;

wire basa_don = TIM_CNT_R == TIM_ARE;
wire miktar = (sayac == TIM_PRE +1);

always @* begin
    TIM_CNT_NEXT_R = TIM_CNT_R;
    TIM_EVN_NEXT_R = TIM_EVN_R;

    if(TIM_ENA[0]) begin
        case({TIM_CLR[0], TIM_EVC[0], basa_don})
            3'b000: begin
                TIM_CNT_NEXT_R = TIM_MOD ? (TIM_CNT_R + miktar) : (TIM_CNT_R - miktar);
                TIM_EVN_NEXT_R = TIM_EVN_R;
                if(sayac == TIM_PRE+1) begin
                    sayac_next = 0;
                end else begin
                    sayac_next = sayac + 1;
                end
            end
            3'b001: begin
                TIM_CNT_NEXT_R = 0;
                TIM_EVN_NEXT_R = TIM_EVN_R + 1;
                if(sayac == TIM_PRE+1) begin
                    sayac_next = 0;
                end else begin
                    sayac_next = sayac + 1;
                end
            end
            3'b010: begin
                TIM_CNT_NEXT_R = TIM_MOD ? (TIM_CNT_R + miktar) : (TIM_CNT_R - miktar);
                TIM_EVN_NEXT_R = 0;
                if(sayac == TIM_PRE+1) begin
                    sayac_next = 0;
                end else begin
                    sayac_next = sayac + 1;
                end
            end
            3'b011: begin
                TIM_CNT_NEXT_R = 0;
                TIM_EVN_NEXT_R = 0;
                if(sayac == TIM_PRE+1) begin
                    sayac_next = 0;
                end else begin
                    sayac_next = sayac + 1;
                end
            end
            3'b100: begin
                TIM_CNT_NEXT_R = 0;
                TIM_EVN_NEXT_R = TIM_EVN_R;
                sayac_next = 0;
                
            end
            3'b101: begin
                TIM_CNT_NEXT_R = 0;
                TIM_EVN_NEXT_R = TIM_EVN_R + 1;
                sayac_next = 0;
            end
            3'b110: begin
                TIM_CNT_NEXT_R = 0;
                TIM_EVN_NEXT_R = 0;
                sayac_next = 0;
            end
            3'b111: begin
                TIM_CNT_NEXT_R = 0;
                TIM_EVN_NEXT_R = 0;
                sayac_next = 0;
            end
        endcase  
    end else begin
        if(TIM_EVC[0]) begin
            TIM_EVN_NEXT_R = 0;
        end
    
        if(TIM_CLR[0]) begin
            TIM_CNT_NEXT_R = 0;
            sayac_next = 0;     
        end
    end
end

//always@* begin
//    sayac_next = sayac + 1;
//    if(sayac == TIM_PRE+1) begin
//        sayac_next = 0;
//    end
//end

always @(posedge clk_i) begin
    if(rst_i) begin
        TIM_CNT_R <= 0;
        TIM_EVN_R <= 0;
        sayac <= 0;
    end
    else begin
        TIM_CNT_R <= TIM_CNT_NEXT_R;
        TIM_EVN_R <= TIM_EVN_NEXT_R;
        sayac <= sayac_next;
    end
end

endmodule