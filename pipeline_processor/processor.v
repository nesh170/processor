module processor(clock, reset, ps2_key_pressed, ps2_out, lcd_write, lcd_data, debug_data, debug_addr,debug_out,ir_out);

	input 			clock, reset, ps2_key_pressed;
	input 	[7:0]	ps2_out;
	
	output 			lcd_write;
	output 	[31:0] 	lcd_data;
	
	output[31:0] debug_out,ir_out;
	
	// GRADER OUTPUTS - YOU MUST CONNECT TO YOUR DMEM
	output 	[31:0] 	debug_data;
	output	[11:0]	debug_addr;
	
	
	//////////////////////////////////////
	////// THIS IS REQUIRED FOR GRADING
	// CHANGE THIS TO ASSIGN YOUR DMEM WRITE ADDRESS ALSO TO debug_addr
	assign debug_addr = (12'b000000000001);
	// CHANGE THIS TO ASSIGN YOUR DMEM DATA INPUT (TO BE WRITTEN) ALSO TO debug_data
	assign debug_data = (12'b000000000001);
	////////////////////////////////////////////////////////////
	
	//FETCH STAGE
	//PROGRAM COUNTER
	wire[31:0] pc_input,pc_output;
	register program_counter(.bitsIn(pc_input), .bitsOut(pc_output), .writeEnable(1'b1), .reset(reset), .clk(clock));
	
	//IMEM
	wire[31:0] imem_output;	
	imem myimem(.address(pc_output[11:0]),.clken(1'b1),.clock(~clock),.q(imem_output)); //read on negative edge
	
	//NEXT PROGRAM COUNTER calculations
	wire[31:0] next_pc_output;
	carry_select_adder pc_adder(.in_A(pc_output), .in_B(32'b0), .out(next_pc_output), .carry_in(1'b1));
	
	//pc_input is assigned in the execute stage
	
	//FETCH_DECODE LATCH
	wire[31:0] fd_pc_output,fd_ir_output;
	latch_350 fetch_decode_latch(.program_counter(next_pc_output),.instruction(imem_output),.clock(clock),.output_PC(fd_pc_output),.output_ins(fd_ir_output));
	
	
	//DECODE STAGE
	//DECODE controller
	wire[4:0] read_reg_A,read_reg_B;
	control_decode decode_controller(.instruction(fd_ir_output),.read_reg_s1(read_reg_A),.read_reg_s2(read_reg_B));
	
	//REGISTER FILE
	wire wren_sig;//WRITEBACK
	wire[4:0] write_register;//WRITEBACK
	wire[31:0] write_data,read_data_A,read_data_B;
	regfile register_file(.clock(~clock), .ctrl_writeEnable(wren_sig), .ctrl_reset(reset), .ctrl_writeReg(write_register), .ctrl_readRegA(read_reg_A), .ctrl_readRegB(read_reg_B), .data_writeReg(write_data), .data_readRegA(read_data_A), .data_readRegB(read_data_B));

	
	//DECODE_EXECUTE LATCH
	wire[31:0] de_pc_output,de_ir_output,de_A_output,de_B_output;
	latch_350 decode_execute_latch(.input_A(read_data_A),.input_B(read_data_B),.program_counter(fd_pc_output),.instruction(fd_ir_output),.clock(clock),.output_A(de_A_output),.output_B(de_B_output),.output_PC(de_pc_output),.output_ins(de_ir_output));
	
	
	//EXECUTE controller
	wire[4:0] opcode_ALU, shamt;
	wire[31:0] immediate_data;
	wire[31:0] jump_immediate_data;
	wire i_sig,j_sig,jr_sig;
	control_execute execute_controller(.instruction(de_ir_output),.ALU_opcode(opcode_ALU),.ctrl_shamt(shamt),.immediate_value(immediate_data),.i_signal(i_sig),.j_signal(j_sig),.jr_signal(jr_sig),.jump_immediate_value(jump_immediate_data),.pc(de_pc_output));
	
	//JUMP Stuff
	wire[31:0] jump_next_pc;
	assign jump_next_pc = (jr_sig) ? de_B_output : jump_immediate_data;
	assign pc_input = (j_sig) ? jump_next_pc : next_pc_output;
	
	
	//ALU
	wire[31:0] ALU_input_B,ALU_output;
	wire ALU_isNotEqual,ALU_isLessThan;
	assign ALU_input_B = (i_sig) ? immediate_data : de_B_output;
	ALU alu(.data_operandA(de_A_output), .data_operandB(ALU_input_B), .ctrl_ALUopcode(opcode_ALU), .ctrl_shiftamt(shamt), .data_result(ALU_output), .isNotEqual(ALU_isNotEqual), .isLessThan(ALU_isLessThan));
	
	//EXECUTE_MEMORY_LATCH
	wire[31:0] em_pc_output,em_ir_output, em_A_output,em_B_output;
	latch_350 execute_memory_latch(.input_A(ALU_output),.input_B(de_B_output),.program_counter(de_pc_output),.instruction(de_ir_output),.clock(clock),.output_A(em_A_output),.output_B(em_B_output),.output_PC(em_pc_output),.output_ins(em_ir_output));
	

	//MEMORY stage
	//MEMORY controller
	wire sw_sig;
	control_memory memory_controller(.instruction(em_ir_output),.sw_signal(sw_sig));
	wire[31:0] dmem_output;	
	//DMEM
	dmem mydmem(.address(em_A_output[11:0]),.clock(~clock),.data(em_B_output),.wren(sw_sig),.q(dmem_output));

	//MEMORY_WRITEBACK latch
	wire[31:0] mw_pc_output,mw_ir_output,mw_A_output,mw_B_output;
	latch_350 memory_writeback_latch(.input_A(em_A_output),.input_B(dmem_output),.program_counter(em_pc_output),.instruction(em_ir_output),.clock(clock),.output_A(mw_A_output),.output_B(mw_B_output),.output_PC(mw_pc_output),.output_ins(mw_ir_output));
	
	
	//WRITEBACK control
	wire lw_sig,jal_sig;
	control_writeback writeback_controller(.instruction(mw_ir_output),.write_reg_number(write_register),.jal_signal(jal_sig),.lw_signal(lw_sig),.wren_signal(wren_sig));

	wire[31:0] intermediate_value;
	assign intermediate_value = (lw_sig) ? mw_B_output : mw_A_output;
	assign write_data = (jal_sig) ? mw_pc_output : intermediate_value;
	
	assign ir_out = mw_ir_output;
	assign debug_out = write_data;
	
	
endmodule
