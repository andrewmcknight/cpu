module decoder(
    output[31:0] out,
    input[4:0] select,
    input enable
);
    assign out = enable << select;
endmodule