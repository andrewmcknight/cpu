module shift_left_1(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {in[30:0], 1'b0};
endmodule
