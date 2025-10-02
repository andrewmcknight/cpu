module shift_right_16(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {{16{in[31]}}, in[31:16]};
endmodule
