module shift_right_8(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {{8{in[31]}}, in[31:8]};
endmodule
