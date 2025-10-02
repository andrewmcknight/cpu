// mux_2: 32-bit 2-to-1 multiplexer. Inputs: select, in0, in1. Outputs: out.

module mux_2(out, select, in0, in1);

    input select;
    input [31:0] in0, in1;
    output [31:0] out;

    assign out = select? in1:in0;

endmodule
