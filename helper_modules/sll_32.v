// sll_32: Barrel shifter implementing logical left shifts by variable amounts. Inputs: in, shift_amt. Outputs: out.

module sll_32(out, in, shift_amt);

    input [31:0] in;
    input [4:0] shift_amt;
    output [31:0] out;

    wire [31:0] stage1, stage2, stage3, stage4;
    wire [31:0] shifted_16, shifted_8, shifted_4, shifted_2, shifted_1;

    shift_left_16 sl16(shifted_16, in);
    mux_2 mux1(stage1, shift_amt[4], in, shifted_16);

    shift_left_8 sl8(shifted_8, stage1);
    mux_2 mux2(stage2, shift_amt[3], stage1, shifted_8);

    shift_left_4 sl4(shifted_4, stage2);
    mux_2 mux3(stage3, shift_amt[2], stage2, shifted_4);

    shift_left_2 sl2(shifted_2, stage3);
    mux_2 mux4(stage4, shift_amt[1], stage3, shifted_2);

    shift_left_1 sl1(shifted_1, stage4);
    mux_2 mux5(out, shift_amt[0], stage4, shifted_1);

endmodule
