// adder_block: 8-bit carry-lookahead slice producing sum and carry signals. Inputs: a, b, Cin. Outputs: s, G, P, c7.

module adder_block(s, G, P, c7, a, b, Cin);

    input Cin;
    input [7:0] a, b;
    output G, P, c7;
    output [7:0] s;

    wire g0, g1, g2, g3, g4, g5, g6, g7;
    wire p0, p1, p2, p3, p4, p5, p6, p7;
    wire c0, c1, c2, c3, c4, c5, c6;
    wire c0p0, c0p0p1, c0p0p1p2, c0p0p1p2p3, c0p0p1p2p3p4, c0p0p1p2p3p4p5, c0p0p1p2p3p4p5p6, c0p0p1p2p3p4p5p6p7;
    wire g0p1, g0p1p2, g0p1p2p3, g0p1p2p3p4, g0p1p2p3p4p5, g0p1p2p3p4p5p6, g0p1p2p3p4p5p6p7;
    wire g1p2, g1p2p3, g1p2p3p4, g1p2p3p4p5, g1p2p3p4p5p6, g1p2p3p4p5p6p7;
    wire g2p3, g2p3p4, g2p3p4p5, g2p3p4p5p6, g2p3p4p5p6p7;
    wire g3p4, g3p4p5, g3p4p5p6, g3p4p5p6p7;
    wire g4p5, g4p5p6, g4p5p6p7;
    wire g5p6, g5p6p7;
    wire g6p7;

    and g0and(g0, a[0], b[0]);
    and g1and(g1, a[1], b[1]);
    and g2and(g2, a[2], b[2]);
    and g3and(g3, a[3], b[3]);
    and g4and(g4, a[4], b[4]);
    and g5and(g5, a[5], b[5]);
    and g6and(g6, a[6], b[6]);
    and g7and(g7, a[7], b[7]);

    or p0or(p0, a[0], b[0]);
    or p1or(p1, a[1], b[1]);
    or p2or(p2, a[2], b[2]);
    or p3or(p3, a[3], b[3]);
    or p4or(p4, a[4], b[4]);
    or p5or(p5, a[5], b[5]);
    or p6or(p6, a[6], b[6]);
    or p7or(p7, a[7], b[7]);

    assign c0 = Cin;

    and c0andp0(c0p0, c0, p0);
    and c0andp0p1(c0p0p1, c0, p0, p1);
    and c0andp0p1p2(c0p0p1p2, c0, p0, p1, p2);
    and c0andp0p1p2p3(c0p0p1p2p3, c0, p0, p1, p2, p3);
    and c0andp0p1p2p3p4(c0p0p1p2p3p4, c0, p0, p1, p2, p3, p4);
    and c0andp0p1p2p3p4p5(c0p0p1p2p3p4p5, c0, p0, p1, p2, p3, p4, p5);
    and c0andp0p1p2p3p4p5p6(c0p0p1p2p3p4p5p6, c0, p0, p1, p2, p3, p4, p5, p6);
    and c0andp0p1p2p3p4p5p6p7(c0p0p1p2p3p4p5p6p7, c0, p0, p1, p2, p3, p4, p5, p6, p7);

    and g0andp1(g0p1, g0, p1);
    and g0andp1p2(g0p1p2, g0, p1, p2);
    and g0andp1p2p3(g0p1p2p3, g0, p1, p2, p3);
    and g0andp1p2p3p4(g0p1p2p3p4, g0, p1, p2, p3, p4);
    and g0andp1p2p3p4p5(g0p1p2p3p4p5, g0, p1, p2, p3, p4, p5);
    and g0andp1p2p3p4p5p6(g0p1p2p3p4p5p6, g0, p1, p2, p3, p4, p5, p6);
    and g0andp1p2p3p4p5p6p7(g0p1p2p3p4p5p6p7, g0, p1, p2, p3, p4, p5, p6, p7);

    and g1andp2(g1p2, g1, p2);
    and g1andp2p3(g1p2p3, g1, p2, p3);
    and g1andp2p3p4(g1p2p3p4, g1, p2, p3, p4);
    and g1andp2p3p4p5(g1p2p3p4p5, g1, p2, p3, p4, p5);
    and g1andp2p3p4p5p6(g1p2p3p4p5p6, g1, p2, p3, p4, p5, p6);
    and g1andp2p3p4p5p6p7(g1p2p3p4p5p6p7, g1, p2, p3, p4, p5, p6, p7);

    and g2andp3(g2p3, g2, p3);
    and g2andp3p4(g2p3p4, g2, p3, p4);
    and g2andp3p4p5(g2p3p4p5, g2, p3, p4, p5);
    and g2andp3p4p5p6(g2p3p4p5p6, g2, p3, p4, p5, p6);
    and g2andp3p4p5p6p7(g2p3p4p5p6p7, g2, p3, p4, p5, p6, p7);

    and g3andp4(g3p4, g3, p4);
    and g3andp4p5(g3p4p5, g3, p4, p5);
    and g3andp4p5p6(g3p4p5p6, g3, p4, p5, p6);
    and g3andp4p5p6p7(g3p4p5p6p7, g3, p4, p5, p6, p7);

    and g4andp5(g4p5, g4, p5);
    and g4andp5p6(g4p5p6, g4, p5, p6);
    and g4andp5p6p7(g4p5p6p7, g4, p5, p6, p7);

    and g5andp6(g5p6, g5, p6);
    and g5andp6p7(g5p6p7, g5, p6, p7);
    
    and g6andp7(g6p7, g6, p7);

    or c1or(c1, g0, c0p0);
    or c2or(c2, g1, g0p1, c0p0p1);
    or c3or(c3, g2, g1p2, g0p1p2, c0p0p1p2);
    or c4or(c4, g3, g2p3, g1p2p3, g0p1p2p3, c0p0p1p2p3);
    or c5or(c5, g4, g3p4, g2p3p4, g1p2p3p4, g0p1p2p3p4, c0p0p1p2p3p4);
    or c6or(c6, g5, g4p5, g3p4p5, g2p3p4p5, g1p2p3p4p5, g0p1p2p3p4p5, c0p0p1p2p3p4p5);
    or c7or(c7, g6, g5p6, g4p5p6, g3p4p5p6, g2p3p4p5p6, g1p2p3p4p5p6, g0p1p2p3p4p5p6, c0p0p1p2p3p4p5p6);


    and bigPand(P, p0, p1, p2, p3, p4, p5, p6, p7);
    or bigGor(G, g7, g6p7, g5p6p7, g4p5p6p7, g3p4p5p6p7, g2p3p4p5p6p7, g1p2p3p4p5p6p7, g0p1p2p3p4p5p6p7);

    xor s0xor(s[0], a[0], b[0], c0);
    xor s1xor(s[1], a[1], b[1], c1);
    xor s2xor(s[2], a[2], b[2], c2);
    xor s3xor(s[3], a[3], b[3], c3);
    xor s4xor(s[4], a[4], b[4], c4);
    xor s5xor(s[5], a[5], b[5], c5);
    xor s6xor(s[6], a[6], b[6], c6);
    xor s7xor(s[7], a[7], b[7], c7);

endmodule
