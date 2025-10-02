// decoder: 5-to-32 one-hot decoder gated by enable. Inputs: select, enable. Outputs: out.

module decoder(
    output[31:0] out,
    input[4:0] select,
    input enable
);
    assign out = enable << select;
endmodule
