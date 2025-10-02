// tsb: 32-bit tri-state buffer to gate a bus. Inputs: in, oe. Outputs: out.

module tsb(out, in, oe);
    input [31:0] in;
    input oe;
    output [31:0] out;

    assign out = oe? in:32'bz;

endmodule
