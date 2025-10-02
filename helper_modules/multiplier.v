module multiplier(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY
);

    input [31:0] data_operandA, data_operandB;   // A is multiplicand, B is multiplier
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    /* ------ REGISTER ------ */
    wire [64:0] bigRegIn, bigRegOut;
    register_Nbit #(65) bigReg(.dataOut(bigRegOut), .dataIn(bigRegIn), .clk(clock), .en(1'b1), .clr(1'b0));
    wire [2:0] LSBS;
    assign LSBS = bigRegOut[2:0];
    assign data_result = bigRegIn[32:1];

    /* ------ CTRL ------ */
    wire shiftM; // true for 100, 011
    assign shiftM = (LSBS[2] & ~LSBS[1] & ~LSBS[0]) | (~LSBS[2] & LSBS[1] & LSBS[0]);

    wire noAddSub; // true for 000, 111
    assign noAddSub = ~(|LSBS) | &LSBS;

    wire subtract; // true for 100, 101, 110
    assign subtract = LSBS[2] & ~(&LSBS[1:0]);

    wire reset;
    assign reset = ctrl_MULT;

    /* ------ ADDER ------ */
    wire overflow;
    wire [31:0] adderResult, adderInB;
    adder_32 adder(.s(adderResult), .overflow(overflow), .a(bigRegOut[64:33]), .b(adderInB), .Cin(subtract));

    /* ------ COUNTER ------ */
    wire [3:0] counterNum;
    counter_16cycle counter(.q(counterNum), .clk(clock), .en(1'b1), .clr(reset));
    assign data_resultRDY = &counterNum;

    /* ------ choose adderInB ------ */
    wire [31:0] mFlipped;
    wire [31:0] mFlippedShifted;
    assign mFlipped = ~data_operandA;
    assign mFlippedShifted = {mFlipped[30:0], 1'b1};
    mux_4 chooseAdderInB(.out(adderInB), .select({subtract, shiftM}), .in0(data_operandA), .in1(data_operandA << 1), .in2(mFlipped), .in3(mFlippedShifted));

    /* ------ combine add/sub/no-op with lower bits ------ */
    wire [64:0] combo;
    mux_2 chooseUpperBits(.out(combo[64:33]), .select(noAddSub), .in0(adderResult), .in1(bigRegOut[64:33]));
    assign combo[32:0] = bigRegOut[32:0];

    /* ------ deal with ICs for bigRegIn ------ */
    wire [64:0] muxIn;
    assign muxIn = {{2{combo[64]}}, combo[64:2]};
    mux_2to1_Nbit #(65) chooseBigRegIn(.out(bigRegIn), .select(reset), .in0(muxIn), .in1({32'd0, data_operandB, 1'b0}));

    /* ------ OVERFLOW ------ */
    // bits 64:32 have to be the same. otherwise, overflow.

    wire [6:0] nor1, nor2, nor3;
    wire [5:0] nor4, nor5;
    wire bigNor;
    assign nor1 = ~(|bigRegIn[64:58]);
    assign nor2 = ~(|bigRegIn[57:51]);
    assign nor3 = ~(|bigRegIn[50:44]);
    assign nor4 = ~(|bigRegIn[43:38]);
    assign nor5 = ~(|bigRegIn[37:32]);
    assign bigNor = nor1 & nor2 & nor3 & nor4 & nor5;

    wire [6:0] and1, and2;
    wire [5:0] and3, and4, and5;
    wire bigAnd;
    assign and1 = &bigRegIn[64:58];
    assign and2 = &bigRegIn[57:51]; 
    assign and3 = &bigRegIn[50:44];  
    assign and4 = &bigRegIn[43:38];   
    assign and5 = &bigRegIn[37:32];    
    assign bigAnd = and1 & and2 & and3 & and4 & and5;

    wire sign_mistake;
    wire Aeqz, Beqz;
    eqz_32 eqz1(.out(Aeqz), .in(data_operandA));
    eqz_32 eqz2(.out(Beqz), .in(data_operandB));

    assign sign_mistake = ~Aeqz & ~Beqz & 
                            (((data_operandA[31] ^ data_operandB[31]) & ~data_result[31]) 
                            | ((data_operandA[31] & data_operandB[31]) & data_result[31])
                            | ((~data_operandA[31] & ~data_operandB[31]) & data_result[31]));

    assign data_exception = ~(bigNor | bigAnd) | sign_mistake;

endmodule
