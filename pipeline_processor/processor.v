module processor(clock, reset, ps2_key_pressed, ps2_out, lcd_write, lcd_data, debug_data, debug_addr);

	input 			clock, reset, ps2_key_pressed;
	input 	[7:0]	ps2_out;
	
	output 			lcd_write;
	output 	[31:0] 	lcd_data;
	
	// GRADER OUTPUTS - YOU MUST CONNECT TO YOUR DMEM
	output 	[31:0] 	debug_data;
	output	[11:0]	debug_addr;
	
	
	// your processor here
	//
	
	//////////////////////////////////////
	////// THIS IS REQUIRED FOR GRADING
	// CHANGE THIS TO ASSIGN YOUR DMEM WRITE ADDRESS ALSO TO debug_addr
	assign debug_addr = (12'b000000000001);
	// CHANGE THIS TO ASSIGN YOUR DMEM DATA INPUT (TO BE WRITTEN) ALSO TO debug_data
	assign debug_data = (12'b000000000001);
	////////////////////////////////////////////////////////////
	
	/**
	FETCH stage
	**/
	//Instruction Wires
	wire[31:0] instruction_wire;
	
	//Program Counter
	wire[31:0] program_counter_input,program_counter_output;
	register program_counter(program_counter_input,program_counter_output,1'b1,1'b0,clock);
	wire[31:0] next_program_counter;
	carry_select_adder add_program_counter(program_counter_output, 32'b0, next_program_counter, 1'b1); //CHECK IF THIS IS +1 or +4
	//IMEM
	imem myimem(.address(program_counter_output[11:0]),.clken(1'b1),.clock(clock),.q(instruction_wire)); 
	
	
	//fetch_decode_latch
	wire[31:0] fd_ir_output,fd_pc_output;
	latch_350 fetch_decode_latch(.input_A(32'b0),.input_B(32'b0),.program_counter(next_program_counter),.instruction(instruction_wire),.clock(clock),.output_PC(fd_pc_output),.output_ins(fd_ir_output));
	
	
	
	//Register File 
	wire write_enable;
	wire[4:0] write_reg,read_reg_A,read_reg_B;
	wire[31:0] write_data,read_A_data, read_B_data;
	regfile register_file(clock, write_enable, reset, write_reg, read_reg_A, read_reg_B, write_data, read_A_data, read_B_data);
	
	control_decode con_decode(fd_ir_output,read_reg_A,read_reg_B);

	//decode_execute_latch
	wire[31:0] de_ir_output,de_pc_output,de_A_output,de_B_output;
	latch_350 decode_execute_latch(.input_A(read_A_data),.input_B(read_B_data),.program_counter(fd_pc_output),.instruction(fd_ir_output),.clock(clock),.output_A(de_A_output),.output_B(de_B_output),.output_PC(de_pc_output),.output_ins(de_ir_output));
	
	
	//ALU
	wire[31:0] ALU_inputA,ALU_inputB,ALU_output;
	wire isNotEqual, isLessThan;
	
	wire[4:0] ALU_opcode, shamt;
	wire[16:0] immediate_data;
	wire[26:0] jump_target;
	wire i_sig,j_sig;
	ALU alu_opertaion(ALU_inputA, ALU_inputB, ALU_opcode, shamt, ALU_output, isNotEqual, isLessThan);
	control_execute alu_controller(de_ir_output,immediate_data,jump_target,ALU_opcode,shamt,i_sig,j_sig); //ALU Controls
	
	wire[31:0] immediate_data_32,jump_target_32;
	sign_extender_17 extend_immediate(immediate_data,immediate_data_32);
	sign_extender_27 extend_jump(jump_target,jump_target_32);
	
	assign ALU_inputB = (i_sig) ? immediate_data_32 : de_B_output;
	assign ALU_inputA = de_A_output;
	
	//execute_memory_latch
	wire[31:0] em_O_output,em_D_output,em_ir_output,em_pc_output;
	latch_350 execute_memory_latch(.input_A(ALU_output),.input_B(de_B_output),.program_counter(de_pc_output),.instruction(de_ir_output),.clock(clock),.output_A(em_O_output),.output_B(em_D_output),.output_PC(em_pc_output),.output_ins(em_ir_output));
	
	//MEMORY stage
	wire data_write_sig; //asserted for saveword 00111
	control_memory memory_controller(em_ir_output,data_write_sig);
	wire[31:0] dmem_data_output;
	//DMEM
	dmem mydmem(.address	(em_O_output[11:0]),.clock(clock),.data(em_O_output),.wren(data_write_sig),.q(dmem_data_output));
	
	
	//memory_writeback_latch
	wire[31:0] mw_O_output,mw_D_output,mw_ir_output,mw_pc_output;
	latch_350 memory_writeback_latch(.input_A(em_O_output),.input_B(dmem_data_output),.program_counter(em_pc_output),.instruction(em_ir_output),.clock(clock),.output_A(mw_O_output),.output_B(mw_D_output),.output_PC(mw_pc_output),.output_ins(mw_ir_output));
	
	//WRITEBACK stage
	wire data_or_output_sig,jal_ins_signal;
	wire[4:0] rd;
	wire[31:0] data_to_register;
	assign data_to_register = (data_or_output_sig) ? mw_D_output : mw_O_output;
	
	assign write_data = (jal_ins_signal) ? mw_pc_output : data_to_register;
	assign write_reg = (jal_ins_signal) ? 5'b11111 : rd;
	
	control_writeback writeback_controller(mw_ir_output,rd,data_or_output_sig,jal_ins_signal,write_enable);

endmodule
