// mux_2_1bit: Single-bit 2-to-1 multiplexer. Inputs: select, in0, in1. Outputs: out.

module mux_2_1bit(out, select, in0, in1);

    input select;
    input in0, in1;
    output out;

    assign out = select? in1:in0;

endmodule
