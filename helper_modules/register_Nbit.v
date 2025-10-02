// register_Nbit: Parameterizable register array with enable and async clear. Inputs: dataIn, clk, en, clr. Outputs: dataOut.

module register_Nbit #(parameter N = 32) (
    output [N-1:0] dataOut,
    input [N-1:0] dataIn,
    input clk, en, clr
);
    genvar g;
    generate
        for (g = 0; g < N; g = g + 1) begin : dff_gen
            dffe_ref dff(.q(dataOut[g]), .d(dataIn[g]), .clk(clk), .en(en), .clr(clr));
        end
    endgenerate
endmodule
