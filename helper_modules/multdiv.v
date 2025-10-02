module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY
);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    /* ------ MULTIPLIER ------ */
    wire [31:0] mult_result;
    wire mult_exception, mult_resultRDY;
    multiplier mo (
        .data_operandA(data_operandA),
        .data_operandB(data_operandB),
        .ctrl_MULT(ctrl_MULT),
        .ctrl_DIV(1'b0),
        .clock(clock),
        .data_result(mult_result),
        .data_exception(mult_exception),
        .data_resultRDY(mult_resultRDY)
    );

    /* ------ DIVIDER ------ */
    wire [31:0] div_result;
    wire div_exception, div_resultRDY;
    divider dorian (
        .data_operandA(data_operandA),
        .data_operandB(data_operandB),
        .ctrl_MULT(1'b0),
        .ctrl_DIV(ctrl_DIV),
        .clock(clock),
        .data_result(div_result),
        .data_exception(div_exception),
        .data_resultRDY(div_resultRDY)
    );

    /* ------ Choose outputs ------ */
    wire op; // 1 = divide, 0 = multiply
    dffe_ref thingy (.q(op), .d(ctrl_DIV), .clk(clock), .en(ctrl_DIV), .clr(ctrl_MULT));
    assign data_resultRDY = (op & div_resultRDY) || (~op & mult_resultRDY);
    assign data_exception = (op & div_exception) || (~op & mult_exception);
    mux_2to1_Nbit #(32) muxiplex (.out(data_result), .select(op), .in0(mult_result), .in1(div_result)); 

endmodule
