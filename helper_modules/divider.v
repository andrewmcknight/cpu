module divider(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY
);

    input [31:0] data_operandA, data_operandB;   // A is dividend, B is divisor
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;
    
    //

    /* ------ REGISTER ------ */
    wire [64:0] bigRegIn, bigRegOut;
    register_Nbit #(65) bigReg(.dataOut(bigRegOut), .dataIn(bigRegIn), .clk(clock), .en(1'b1), .clr(1'b0));

    /* ------ CTRL ------ */
    wire subtract;
    assign subtract = ~bigRegOut[64];    // MSB of R

    wire reset;
    assign reset = ctrl_DIV;

    /* ------ COUNTER ------ */
    wire [4:0] counterNum;
    counter_32cycle counter(.q(counterNum), .clk(clock), .en(1'b1), .clr(reset));
    assign data_resultRDY = &counterNum;

    /* ------ ADDER ------ */
    wire overflow;
    wire [31:0] adderResult, adderInA, adderInB;
    adder_32 addur(.s(adderResult), .overflow(overflow), .a(adderInA), .b(adderInB), .Cin(1'b0));

    /* ------ Get complement, Abs val and negative inputs ------ */
    wire [31:0] compA, compB;
    adder_32 complementA(.s(compA), .a(32'b1), .b(~data_operandA), .Cin(1'b0));
    adder_32 complementB(.s(compB), .a(32'b1), .b(~data_operandB), .Cin(1'b0));
    wire [31:0] absA, absB;
    mux_2to1_Nbit #(32) plux(.out(absA), .select(data_operandA[31]), .in0(data_operandA), .in1(compA));
    mux_2to1_Nbit #(32) pluxx(.out(absB), .select(data_operandB[31]), .in0(data_operandB), .in1(compB));
    wire [31:0] negB;
    mux_2to1_Nbit #(32) pluxxx(.out(negB), .select(data_operandB[31]), .in0(compB), .in1(data_operandB));
    
    /* ------ choose adderInA ------ */
    assign adderInA = bigRegOut[63:32];     //left-shifted R

    /* ------ choose adderInB ------ */
    mux_2to1_Nbit #(32) muxy(.out(adderInB), .select(subtract), .in0(absB), .in1(negB));

    /* ------ assign bigRegIn, considering ICs ------ */
    wire [64:0] ongoingResult;
    assign ongoingResult[64:33] = adderResult;
    assign ongoingResult[32:2] = bigRegOut[31:1];
    assign ongoingResult[1] = ~adderResult[31];
    assign ongoingResult[0] = 1'b0;
    mux_2to1_Nbit #(65) chooseBigRegIn(.out(bigRegIn), .select(reset), .in0(ongoingResult), .in1({32'd0, absA, 1'b0}));

    /* ------ correct sign result ------ */
    wire [31:0] uncorrected_result;
    assign uncorrected_result = {bigRegOut[31:1], ~adderResult[31]};
    wire [31:0] result_comp;
    adder_32 adore(.s(result_comp), .a(32'b1), .b(~uncorrected_result), .Cin(1'b0));
    mux_4 mucks(.out(data_result), .select({data_operandA[31], data_operandB[31]}), .in0(uncorrected_result), .in1(result_comp), .in2(result_comp), .in3(uncorrected_result));

    /* ------ data exception ------ */
    eqz_32 Beqz(.out(data_exception), .in(data_operandB));

endmodule