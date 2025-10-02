// eqz_32: Zero detector implemented with a NOR tree. Inputs: in. Outputs: out.

module eqz_32(out, in);
    input [31:0] in;
    output out;

    wire nor1, nor2, nor3, nor4; 

    nor nor_gate1(nor1, in[7], in[6], in[5], in[4], in[3], in[2], in[1], in[0]);
    nor nor_gate2(nor2, in[15], in[14], in[13], in[12], in[11], in[10], in[9], in[8]);
    nor nor_gate3(nor3, in[23], in[22], in[21], in[20], in[19], in[18], in[17], in[16]);
    nor nor_gate4(nor4, in[31], in[30], in[29], in[28], in[27], in[26], in[25], in[24]);

    and and1(out, nor1, nor2, nor3, nor4);

endmodule
