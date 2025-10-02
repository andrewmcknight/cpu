module shift_right_1(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {in[31], in[31:1]};  // Keep sign bit, shift right by 1
endmodule
