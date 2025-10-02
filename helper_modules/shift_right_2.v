module shift_right_2(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {{2{in[31]}}, in[31:2]};
endmodule
