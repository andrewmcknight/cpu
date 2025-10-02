// comp_8: Eight-bit comparator assembled from comp_2 stages. Inputs: EQ8, GT8, A, B. Outputs: EQ0, GT0.

module comp_8(EQ8, GT8, A, B, EQ0, GT0);

    input EQ8, GT8;
    input [7:0] A, B;
    output EQ0, GT0;

    wire EQ2, EQ4, EQ6;
    wire GT2, GT4, GT6;

    //right to left
    comp_2 comp_2a(.EQ0(EQ6), .GT0(GT6), .A(A[7:6]), .B(B[7:6]), .EQ1(EQ8), .GT1(GT8));
    comp_2 comp_2b(.EQ0(EQ4), .GT0(GT4), .A(A[5:4]), .B(B[5:4]), .EQ1(EQ6), .GT1(GT6));
    comp_2 comp_2c(.EQ0(EQ2), .GT0(GT2), .A(A[3:2]), .B(B[3:2]), .EQ1(EQ4), .GT1(GT4));
    comp_2 comp_2d(.EQ0(EQ0), .GT0(GT0), .A(A[1:0]), .B(B[1:0]), .EQ1(EQ2), .GT1(GT2));

endmodule
