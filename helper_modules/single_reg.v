// single_reg: 32-bit register constructed from bit-level dffe_ref cells. Inputs: dataIn, clk, en, clr. Outputs: dataOut.

module single_reg (
    output [31:0] dataOut,
    input [31:0] dataIn,
    input clk, en, clr
);
    genvar g;
    generate
        for (g = 0; g < 32; g = g + 1) begin : dff_gen
            dffe_ref dff(.q(dataOut[g]), .d(dataIn[g]), .clk(clk), .en(en), .clr(clr));
        end
    endgenerate
endmodule
