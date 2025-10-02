// mux_2to1_Nbit: Parameterized 2-to-1 multiplexer. Inputs: select, in0, in1. Outputs: out.

module mux_2to1_Nbit #(parameter N = 32) (out, select, in0, in1);

    input select;
    input [N-1 :0] in0, in1;
    output [N-1 :0] out;

    assign out = select? in1:in0;

endmodule
