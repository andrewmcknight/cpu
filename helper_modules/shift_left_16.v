module shift_left_16(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {in[15:0], 16'b0000000000000000};
endmodule
