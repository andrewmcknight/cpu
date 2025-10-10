module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */

    /* ------ Wires ------ */
    // Stall, nop, bypass
    wire stall_pc, stall_fd, stall_dx, stall_xm, stall_mw;
    wire nop_fd, nop_dx, nop_xm, nop_mw;
    wire [31:0] nop;
    wire xm_o_out_to_ALUinA, xm_exception_out_to_ALUinA, m_target_to_ALUinA, data_writeReg_to_ALUinA;
    wire xm_o_out_to_ALUinB, xm_exception_out_to_ALUinB, m_target_to_ALUinB, data_writeReg_to_ALUinB;
    wire data_writeReg_to_data, data_writeReg_to_xm_b_in;
    wire load_hazard;

    // Branching
    wire take_branch, take_jump;
    wire [31:0] branch_addr, jump_addr;

    // PC
    wire [31:0] pc_in, pc_out;

    // Fetch
    wire [31:0] pcPlusOne, pcPlusOnePlusTarget;

    // FD Latch
    wire [31:0] fd_pc_in, fd_pc_out, fd_insn_in, fd_insn_out;

    // Decode
    wire [4:0] d_opcode, d_rd, d_rs, d_rt;
    wire [31:0] d_target;
    wire d_sw, d_bne, d_blt, d_j, d_jal, d_jr, d_bex;

    // DX Latch
    wire [31:0] dx_pc_in, dx_pc_out, dx_insn_in, dx_insn_out;
    wire [31:0] dx_a_in, dx_a_out, dx_b_in, dx_b_out;

    // Execute
    wire [4:0] x_opcode, x_rs, x_rt, x_rd, x_shamt, x_aluop;
    wire [31:0] x_immediate, x_target;
    wire x_rtype, x_itype, x_add, x_addi, x_sub, x_mul, x_div, x_j, x_bne, x_jal, x_jr, x_blt, x_bex, x_sw, x_lw, x_setx;

    // ALU
    wire [31:0] ALUinA, ALUinB, ALUout;
    wire [4:0] ALUopcode, ALUshamt;
    wire ALUisNotEqual, ALUisLessThan, ALUoverflow;

    // MultDiv
    wire multdiv_exception, multdiv_ready, multdiv_busy, mult_pulse, div_pulse;
    wire [31:0] multdiv_out;

    // XM Latch
    wire [31:0] xm_insn_in, xm_insn_out;
    wire [31:0] xm_o_in, xm_o_out, xm_b_in, xm_b_out;
    wire [2:0] xm_exception_in, xm_exception_out;

    // Memory
    wire [4:0] m_opcode, m_rd;
    wire [31:0] m_target;
    wire m_rtype, m_addi, m_sw, m_setx;

    // MW Latch
    wire [31:0] mw_insn_in, mw_insn_out;
    wire [31:0] mw_o_in, mw_o_out, mw_d_in, mw_d_out;
    wire [2:0] mw_exception_in, mw_exception_out;

    // Writeback
    wire [4:0] w_opcode, w_rd, w_aluop;
    wire [31:0] w_target;
    wire w_rtype, w_add, w_addi, w_sub, w_mul, w_div, w_lw, w_setx, w_jal;
    wire writeRstatus;
    wire [31:0] writeRstatusData;

    /* ------ FETCH ------ */
    // PC Latch
    register_Nbit #(32) PC(.dataOut(pc_out), .dataIn(pc_in), .clk(~clock), .en(~stall_pc), .clr(reset));

    // FD Latch
    register_Nbit #(32) FD_latch_PC(.dataOut(fd_pc_out), .dataIn(fd_pc_in), .clk(~clock), .en(~stall_fd), .clr(reset));
    register_Nbit #(32) FD_latch_insn(.dataOut(fd_insn_out), .dataIn(fd_insn_in), .clk(~clock), .en(~stall_fd), .clr(reset));

    adder_32 addPCPlusOne(.s(pcPlusOne), .a(pc_out), .b(32'd1), .Cin(1'b0));
    adder_32 addPCPlusOnePlusN(.s(pcPlusOnePlusTarget), .a(dx_pc_out), .b(x_target), .Cin(1'b0));

    assign take_jump = x_j || x_jr || x_jal;
    assign jump_addr = x_jr? ALUinB : x_target;

    assign take_branch = x_blt && ALUisLessThan || (x_bne || x_bex) && ALUisNotEqual;
    assign branch_addr = (x_blt && ALUisLessThan || x_bne && ALUisNotEqual)? pcPlusOnePlusTarget : x_target;

    assign pc_in = take_branch? branch_addr : take_jump? jump_addr : pcPlusOne;
    assign address_imem = pc_out;
    assign fd_pc_in = pcPlusOne;
    assign fd_insn_in = nop_fd? nop : q_imem;

    /* ------ DECODE ------ */
    // Parse instruction
    assign d_opcode = fd_insn_out[31:27];
    assign d_rd = fd_insn_out[26:22];
    assign d_rs = fd_insn_out[21:17];
    assign d_rt = fd_insn_out[16:12];
    assign d_target = {5'b00000, fd_insn_out[26:0]};

    // Get operation
    assign d_sw = (d_opcode == 5'b00111);
    assign d_bne = (d_opcode == 5'b00010);
    assign d_blt = (d_opcode == 5'b00110);
    assign d_j = (d_opcode == 5'b00001);
    assign d_jal = (d_opcode == 5'b00011);
    assign d_jr = (d_opcode == 5'b00100);
    assign d_bex = (d_opcode == 5'b10110);

    // DX Latch
    register_Nbit #(32) DX_latch_PC(.dataOut(dx_pc_out), .dataIn(dx_pc_in), .clk(~clock), .en(~stall_dx), .clr(reset));
    register_Nbit #(32) DX_latch_insn(.dataOut(dx_insn_out), .dataIn(dx_insn_in), .clk(~clock), .en(~stall_dx), .clr(reset));
    register_Nbit #(32) DX_latch_A(.dataOut(dx_a_out), .dataIn(dx_a_in), .clk(~clock), .en(~stall_dx), .clr(reset));
    register_Nbit #(32) DX_latch_B(.dataOut(dx_b_out), .dataIn(dx_b_in), .clk(~clock), .en(~stall_dx), .clr(reset));

    assign ctrl_readRegA = d_bex? 5'd30 : d_rs;
    assign ctrl_readRegB = d_bex? 5'd0 : ((d_sw || d_bne || d_blt || d_jr)? d_rd : d_rt);

    assign dx_pc_in = fd_pc_out;
    assign dx_insn_in = nop_dx? nop : fd_insn_out;
    assign dx_a_in = data_readRegA;
    assign dx_b_in = data_readRegB;

    /* ------ EXECUTE ------ */
    // Parse instruction
    assign x_opcode = dx_insn_out[31:27];
    assign x_rd = dx_insn_out[26:22];
    assign x_rs = dx_insn_out[21:17];
    assign x_rt = dx_insn_out[16:12];
    assign x_shamt = dx_insn_out[11:7];
    assign x_aluop = dx_insn_out[6:2];
    assign x_immediate = {{15{dx_insn_out[16]}}, dx_insn_out[16:0]};
    assign x_target = {5'b00000, dx_insn_out[26:0]};

    // Get operation
    assign x_rtype = (x_opcode == 5'b00000);
    assign x_add = x_rtype && (x_aluop == 5'b00000);
    assign x_addi = (x_opcode == 5'b00101);
    assign x_sub = x_rtype && (x_aluop == 5'b00001);
    assign x_mul = x_rtype && (x_aluop == 5'b00110);
    assign x_div = x_rtype && (x_aluop == 5'b00111);
    assign x_j = (x_opcode == 5'b00001);
    assign x_bne = (x_opcode == 5'b00010);
    assign x_jal = (x_opcode == 5'b00011);
    assign x_jr = (x_opcode == 5'b00100);
    assign x_blt = (x_opcode == 5'b00110);
    assign x_bex = (x_opcode == 5'b10110);
    assign x_sw = (x_opcode == 5'b00111);
    assign x_lw = (x_opcode == 5'b01000);
    assign x_setx = (x_opcode == 5'b10101);
    assign x_itype = x_addi || x_sw || x_lw || x_bne || x_blt;

    // XM Latch
    register_Nbit #(32) XM_latch_insn(.dataOut(xm_insn_out), .dataIn(xm_insn_in), .clk(~clock), .en(~stall_xm), .clr(reset));
    register_Nbit #(32) XM_latch_O(.dataOut(xm_o_out), .dataIn(xm_o_in), .clk(~clock), .en(~stall_xm), .clr(reset));
    register_Nbit #(32) XM_latch_B(.dataOut(xm_b_out), .dataIn(xm_b_in), .clk(~clock), .en(~stall_xm), .clr(reset));
    register_Nbit #(3) XM_latch_exception(.dataOut(xm_exception_out), .dataIn(xm_exception_in), .clk(~clock), .en(1'b1), .clr(reset));

    // ALU
    assign ALUinA = xm_exception_out_to_ALUinA? {29'd0, xm_exception_out} : 
        (xm_o_out_to_ALUinA? xm_o_out :
        (m_target_to_ALUinA? m_target :
        (data_writeReg_to_ALUinA? data_writeReg :
        (x_blt? dx_b_out : dx_a_out))));
    assign ALUinB = xm_exception_out_to_ALUinB? {29'd0, xm_exception_out} :
        (xm_o_out_to_ALUinB? xm_o_out :
        (m_target_to_ALUinB? m_target :
        (data_writeReg_to_ALUinB? data_writeReg : 
        (x_blt? dx_a_out : 
        ((x_addi || x_sw || x_lw)? x_immediate : dx_b_out)))));
    assign ALUopcode = (x_addi || x_sw || x_lw)? 5'b00000 : ((x_bne || x_blt)? 5'b00001 : x_aluop);
    assign ALUshamt = x_shamt;
    alu aloo(.data_operandA(ALUinA), .data_operandB(ALUinB), .ctrl_ALUopcode(ALUopcode), .ctrl_shiftamt(ALUshamt), .data_result(ALUout), .isNotEqual(ALUisNotEqual), .isLessThan(ALUisLessThan), .overflow(ALUoverflow));

    // MultDiv
    pulse_generator mult_pulse_gen(.pulse(mult_pulse), .input_event(x_mul), .clock(clock), .reset(reset || multdiv_ready && ~clock));
    pulse_generator div_pulse_gen(.pulse(div_pulse), .input_event(x_div), .clock(clock), .reset(reset || multdiv_ready && ~clock));
    multdiv thing(.data_operandA(ALUinA), .data_operandB(ALUinB), .ctrl_MULT(mult_pulse), .ctrl_DIV(div_pulse), .clock(clock), .data_result(multdiv_out), .data_exception(multdiv_exception), .data_resultRDY(multdiv_ready));
    assign multdiv_busy = x_mul || x_div;

    // Check for exception
    tsb_Nbit #(3) tsb1(.out(xm_exception_in), .in(3'd1), .oe(x_add && ALUoverflow));
    tsb_Nbit #(3) tsb2(.out(xm_exception_in), .in(3'd2), .oe(x_addi && ALUoverflow));
    tsb_Nbit #(3) tsb3(.out(xm_exception_in), .in(3'd3), .oe(x_sub && ALUoverflow));
    tsb_Nbit #(3) tsb4(.out(xm_exception_in), .in(3'd4), .oe(x_mul && multdiv_ready && multdiv_exception));
    tsb_Nbit #(3) tsb5(.out(xm_exception_in), .in(3'd5), .oe(x_div && multdiv_ready && multdiv_exception));
    tsb_Nbit #(3) tsb6(.out(xm_exception_in), .in(3'd0), .oe(~((x_add || x_addi || x_sub) && ALUoverflow) && ~((x_mul || x_div) && multdiv_ready && multdiv_exception)));

    assign xm_insn_in = nop_xm? nop : dx_insn_out;
    assign xm_o_in = (x_mul || x_div)? multdiv_out : (x_jal? dx_pc_out : (x_setx? x_target : ALUout));
    assign xm_b_in = data_writeReg_to_xm_b_in? data_writeReg : dx_b_out;

    /* ------ MEMORY ------ */
    assign m_opcode = xm_insn_out[31:27];
    assign m_rd = xm_insn_out[26:22];
    assign m_target = {5'b00000, xm_insn_out[26:0]};
    assign m_rtype = (m_opcode == 5'b00000);
    assign m_addi = (m_opcode == 5'b00101);
    assign m_sw = (m_opcode == 5'b00111);
    assign m_setx = (m_opcode == 5'b10101);

    // MW Latch
    register_Nbit #(32) MW_latch_insn(.dataOut(mw_insn_out), .dataIn(mw_insn_in), .clk(~clock), .en(~stall_mw), .clr(reset));
    register_Nbit #(32) MW_latch_O(.dataOut(mw_o_out), .dataIn(mw_o_in), .clk(~clock), .en(~stall_mw), .clr(reset));
    register_Nbit #(32) MW_latch_D(.dataOut(mw_d_out), .dataIn(mw_d_in), .clk(~clock), .en(~stall_mw), .clr(reset));
    register_Nbit #(3) MW_latch_exception(.dataOut(mw_exception_out), .dataIn(mw_exception_in), .clk(~clock), .en(1'b1), .clr(reset));

    assign data = data_writeReg_to_data? data_writeReg : xm_b_out;
    assign wren = m_sw;
    assign address_dmem = xm_o_out;

    assign mw_exception_in = xm_exception_out;    
    assign mw_insn_in = nop_mw? nop : xm_insn_out;
    assign mw_o_in = xm_o_out;
    assign mw_d_in = q_dmem;

    /* ------ WRITEBACK ------ */
    // Parse instruction
    assign w_opcode = mw_insn_out[31:27];
    assign w_rd = mw_insn_out[26:22];
    assign w_aluop = mw_insn_out[6:2];
    assign w_target = {5'b00000, mw_insn_out[26:0]};

    // Get operation
    assign w_rtype = (w_opcode == 5'b00000);
    assign w_add = w_rtype && (w_aluop == 5'b00000);
    assign w_addi = (w_opcode == 5'b00101);
    assign w_sub = w_rtype && (w_aluop == 5'b00001);
    assign w_mul = w_rtype && (w_aluop == 5'b00110);
    assign w_div = w_rtype && (w_aluop == 5'b00111);
    assign w_lw = (w_opcode == 5'b01000);
    assign w_setx = (w_opcode == 5'b10101);
    assign w_jal = (w_opcode == 5'b00011);

    assign writeRstatus = w_setx || |mw_exception_out;
    assign writeRstatusData = w_setx? w_target : {29'd0, mw_exception_out};

    assign ctrl_writeReg = writeRstatus? 5'd30 : (w_jal? 5'd31 : w_rd);
    assign ctrl_writeEnable = writeRstatus || w_rtype || w_addi || w_lw || w_jal;
    assign data_writeReg = writeRstatus? writeRstatusData : (w_lw? mw_d_out : mw_o_out);
	
    /* ------ STALL, FLUSH, BYPASS ------ */
    assign nop = 32'd0;

    assign xm_o_out_to_ALUinA =
        |m_rd && (m_rtype || m_addi) && 
            ((x_rtype || x_itype && ~x_blt) && (x_rs == m_rd)
            || x_blt && (x_rd == m_rd)
            || x_bex && (m_rd == 5'd30));
    assign xm_exception_out_to_ALUinA = 
        |xm_exception_out && 
            (x_bex 
            || (x_rtype || x_itype && ~x_blt) && (x_rs == 5'd30)
            || x_blt && (x_rd == 5'd30));
    assign m_target_to_ALUinA = 
        m_setx && 
            ((x_rtype || x_itype && ~x_blt) && (x_rs == 5'd30)
            || x_bex
            || x_blt && (x_rd == 5'd30));
    assign data_writeReg_to_ALUinA = 
        ctrl_writeEnable && |ctrl_writeReg &&
            ((x_rtype || x_itype && ~x_blt) && (ctrl_writeReg == x_rs)
            || x_blt && (ctrl_writeReg == x_rd)
            || x_bex && (ctrl_writeReg == 5'd30));

    assign xm_o_out_to_ALUinB = 
        |m_rd && (m_rtype || m_addi) && 
            (x_rtype && (x_rt == m_rd)
            || x_blt && (x_rs == m_rd)
            || (x_jr || x_bne) && (x_rd == m_rd));
    assign xm_exception_out_to_ALUinB = 
        |xm_exception_out && 
            (x_rtype && (x_rt == 5'd30)
            || x_blt && (x_rs == 5'd30)
            || (x_bne || x_jr) && (x_rd == 5'd30));
    assign m_target_to_ALUinB = 
        m_setx && 
            (x_rtype && (x_rt == 5'd30)
            || x_blt && (x_rs == 5'd30)
            || (x_bne || x_jr) && (x_rd == 5'd30));
    assign data_writeReg_to_ALUinB = 
        ctrl_writeEnable && |ctrl_writeReg &&
            (x_rtype && (ctrl_writeReg == x_rt)
            || x_blt && (ctrl_writeReg == x_rs)
            || (x_bne || x_jr) && (ctrl_writeReg == x_rd));

    assign data_writeReg_to_data = 
        ctrl_writeEnable && m_sw && |ctrl_writeReg && (ctrl_writeReg == m_rd);

    assign data_writeReg_to_xm_b_in = 
        ctrl_writeEnable && x_sw && |ctrl_writeReg && (ctrl_writeReg == x_rd);

    assign load_hazard = 
        x_lw && 
            ((ctrl_readRegA == x_rd)
            || (ctrl_readRegB == x_rd) && ~d_sw);

    assign stall_pc = multdiv_ready? 1'b0 : multdiv_busy || load_hazard;
    assign stall_fd = multdiv_ready? 1'b0 : multdiv_busy || load_hazard;
    assign stall_dx = multdiv_ready? 1'b0 : multdiv_busy;
    assign stall_xm = multdiv_ready? 1'b0 : multdiv_busy;
    assign stall_mw = multdiv_ready? 1'b0 : multdiv_busy;

    assign nop_fd = take_branch || take_jump? 1'b1 : 1'b0;
    assign nop_dx = take_branch || take_jump || load_hazard? 1'b1 : 1'b0;
    assign nop_xm = 1'b0;
    assign nop_mw = 1'b0;

	/* END CODE */

endmodule
