
module ctr_keystream_generator (
    input  wire [31:0] key,
    input  wire [31:0] row_number,
    output wire [31:0] keystream
);

    wire [31:0] temp_0;
    wire [31:0] temp_1;
    wire [31:0] temp_2;
    
    assign temp_0 = key ^ row_number;
    assign temp_1 = temp_0 ^ (temp_0 << 13) ^ (temp_0 >> 17);
    assign temp_2 = temp_1 + 32'h9E3779B9; // magic value
    assign keystream = temp_2 ^ (temp_2 << 7) ^ (temp_2 >> 12);
endmodule
