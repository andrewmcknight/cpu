// adder_32: 32-bit carry-lookahead adder built from 8-bit blocks. Inputs: a, b, Cin. Outputs: s, overflow.

module adder_32(s, overflow, a, b, Cin);

    input [31:0] a, b;
    input Cin;
    output [31:0] s;
    output overflow;

    wire G0, G1, G2, G3;
    wire G0P1, G0P1P2, G0P1P2P3;
    wire G1P2, G1P2P3;
    wire G2P3;

    wire P0, P1, P2, P3;
    wire c0P0, c0P0P1, c0P0P1P2, c0P0P1P2P3;

    wire c0, c8, c16, c24, c32;
    wire c7, c15, c23, c31;
    assign c0 = Cin;
    
    and G0andP1(G0P1, G0, P1);
    and G0andP1P2(G0P1P2, G0, P1, P2);
    and G0andP1P2P3(G0P1P2P3, G0, P1, P2, P3);

    and G1andP2(G1P2, G1, P2);
    and G1andP2P3(G1P2P3, G1, P2, P3);

    and G2andP3(G2P3, G2, P3);

    and c0andP0(c0P0, c0, P0);
    and c0andP0P1(c0P0P1, c0, P0, P1);
    and c0andP0P1P2(c0P0P1P2, c0, P0, P1, P2);
    and c0andP0P1P2P3(c0P0P1P2P3, c0, P0, P1, P2, P3);

    or c8or(c8, G0, c0P0);
    or c16or(c16, G1, G0P1, c0P0P1);
    or c24or(c24, G2, G1P2, G0P1P2, c0P0P1P2);
    or c32or(c32, G3, G2P3, G1P2P3, G0P1P2P3, c0P0P1P2P3);

    adder_block adder_0to7(s[7:0], G0, P0, c7, a[7:0], b[7:0], Cin);
    adder_block adder_8to15(s[15:8], G1, P1, c15, a[15:8], b[15:8], c8);
    adder_block adder_16to23(s[23:16], G2, P2, c23, a[23:16], b[23:16], c16);
    adder_block adder_24to31(s[31:24], G3, P3, c31, a[31:24], b[31:24], c24);

    xor OVFxor(overflow, c31, c32);

endmodule
