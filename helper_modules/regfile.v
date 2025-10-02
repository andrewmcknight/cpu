// regfile: 32x32 register file with dual read ports and single write port. Inputs: clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, data_writeReg. Outputs: data_readRegA, data_readRegB.

module regfile (
    input clock,
    input ctrl_writeEnable, ctrl_reset,
    input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB,
    input [31:0] data_writeReg,
    output [31:0] data_readRegA, data_readRegB
);

    wire [31:0] reg_dataOut [31:0];
    wire [31:0] write_enable;        // One-hot write enable signals
    wire [31:0] read_enableA, read_enableB; // Read enable signals for A & B

    // Register 0 is hardwired to 0
    assign reg_dataOut[0] = 32'b0;

    // Write Enable Decoder
    decoder write_decoder(.out(write_enable), .select(ctrl_writeReg), .enable(ctrl_writeEnable));

    // Generate 31 registers (excluding reg0)
    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin : reg_gen
            single_reg reg_inst (
                .dataOut(reg_dataOut[i]),
                .dataIn(data_writeReg),
                .clk(clock),
                .en(write_enable[i]),  // Only enabled when write signal is active
                .clr(ctrl_reset)
            );
        end
    endgenerate

    // Read Enable Decoders
    decoder read_decoderA(.out(read_enableA), .select(ctrl_readRegA), .enable(1'b1));
    decoder read_decoderB(.out(read_enableB), .select(ctrl_readRegB), .enable(1'b1));

    // Tri-State Buffers for Register Read
    genvar j;
    generate
        for (j = 0; j < 32; j = j + 1) begin : tsb_gen
            tsb_32 tsbA(.out(data_readRegA), .in(reg_dataOut[j]), .oe(read_enableA[j]));
            tsb_32 tsbB(.out(data_readRegB), .in(reg_dataOut[j]), .oe(read_enableB[j]));
        end
    endgenerate

endmodule
