module shift_left_4(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {in[27:0], 4'b0000};
endmodule
