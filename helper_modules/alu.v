module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    /* --------- 1. ADD and 2. SUBTRACT---------- */
    wire [31:0] add_sub_result;
    wire [31:0] b_flipped;
    wire [31:0] adder_second_input;
    wire adder_Cin;
    not_32 notb(b_flipped, data_operandB);

    mux_2 chooseAdder2ndInput(adder_second_input, ctrl_ALUopcode[0], data_operandB, b_flipped);
    mux_2_1bit chooseAdderCin(adder_Cin, ctrl_ALUopcode[0], 1'b0, 1'b1);
    adder_32 adder(add_sub_result, overflow, data_operandA, adder_second_input, adder_Cin);


    /* --------- 3. AND ---------- */
    wire [31:0] and_result;
    and_32 ander(and_result, data_operandA, data_operandB);


    /* --------- 4. OR ---------- */
    wire [31:0] or_result;
    or_32 orer(or_result, data_operandA, data_operandB);


    /* --------- 5. SLL ---------- */
    wire [31:0] sll_result;
    sll_32 sler(sll_result, data_operandA, ctrl_shiftamt);


    /* --------- 6. SRA ---------- */
    wire [31:0] sra_result;
    sra_32 srer(sra_result, data_operandA, ctrl_shiftamt);


    /* --------- isNotEqual ---------- */
    wire add_sub_result_eqz;
    wire add_sub_result_neqz;
    eqz_32 eqz(add_sub_result_eqz, add_sub_result);
    not neqz(add_sub_result_neqz, add_sub_result_eqz);
    mux_2_1bit chooseIsNotEqual(.out(isNotEqual), .select(overflow), .in0(add_sub_result_neqz), .in1(1'b1));


    /* --------- isLessThan ---------- */
    wire signXORresult;
    xor signXOR(signXORresult, data_operandA[31], data_operandB[31]);
    assign isLessThan = signXORresult ? data_operandA[31] : add_sub_result[31];


    /* --------- overflow ---------- */
    //      (built into adder)
    

    /* ------------------------- */
    mux_8 choose_op(data_result, ctrl_ALUopcode[2:0], add_sub_result, add_sub_result, and_result, or_result, sll_result, sra_result, 0, 0);

endmodule