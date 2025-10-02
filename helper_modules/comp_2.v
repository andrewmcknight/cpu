module comp_2(EQ1, GT1, A, B, EQ0, GT0);
    input EQ1, GT1;
    input [1:0] A, B;
    output EQ0, GT0;

    wire [2:0] select;
    assign select = {A, B[1]};
    wire notB0, notEQ1, notGT1;
    not not1(notB0, B[0]);
    not not2(notEQ1, EQ1);
    not not3(notGT1, GT1);
    wire EQmux_result, GTmux_result;
    wire GTand1_result, GTand2_result;

    mux_8 EQmux(.out(EQmux_result), .select(select), .in0(notB0), .in1(0), .in2(B[0]), .in3(0), .in4(0), .in5(notB0), .in6(0), .in7(B[0]));
    mux_8 GTmux(.out(GTmux_result), .select(select), .in0(0), .in1(0), .in2(notB0), .in3(0), .in4(1), .in5(0), .in6(1), .in7(notB0));

    and EQand(EQ0, EQ1, notGT1, EQmux_result);
    and GTand1(GTand1_result, notEQ1, GT1);
    and GTand2(GTand2_result, EQ1, notGT1, GTmux_result);
    or GTor(GT0, GTand1_result, GTand2_result);

endmodule