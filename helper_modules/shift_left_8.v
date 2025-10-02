module shift_left_8(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {in[23:0], 8'b00000000};
endmodule
