// tsb_32: 32-bit tri-state buffer wrapper. Inputs: in, oe. Outputs: out.

module tsb_32(out, in, oe);
    input [31:0] in;
    input oe;
    output [31:0] out;

    assign out = oe? in:32'bz;

endmodule
