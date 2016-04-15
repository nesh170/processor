module processor(clock, reset, ps2_key_pressed, ps2_out, lcd_write, lcd_data, debug_data, debug_addr,debug_out,output_reg,vga_wren_enable,vga_data_addr,vga_data_write,ir_out,pc_out,debug_e,pc_e,ir_e,bypass_e,dmem_input,bypass_m,pc_m,pc_d,ir_d,bypass_d);

	input 			clock, reset, ps2_key_pressed;
	input 	[7:0]	ps2_out;
	
	output 			lcd_write;
	output 	[31:0] 	lcd_data,output_reg;
	
	output[31:0] debug_out,ir_out,pc_out,debug_e,pc_e,ir_e,dmem_input,pc_m,pc_d,ir_d; //debug tools
	output [3:0] bypass_e;
	output bypass_m;
	output [5:0] bypass_d;
	// GRADER OUTPUTS - YOU MUST CONNECT TO YOUR DMEM
	output 	[31:0] 	debug_data;
	output	[11:0]	debug_addr;
	
	
	//VGA IO
	output vga_wren_enable;
	output[18:0] vga_data_addr;
	output[7:0] vga_data_write;
	
	

	
	//FETCH STAGE
	//PROGRAM COUNTER
	wire[31:0] pc_input,pc_output;
	wire stall_sig;
	register program_counter(.bitsIn(pc_input), .bitsOut(pc_output), .writeEnable(~stall_sig), .reset(reset), .clk(clock));
	
	//IMEM
	wire[31:0] imem_output;	
	imem myimem(.address(pc_output[11:0]),.clken(1'b1),.clock(~clock),.q(imem_output)); //read on negative edge
	
	//NEXT PROGRAM COUNTER calculations
	wire[31:0] next_pc_output;
	carry_select_adder pc_adder(.in_A(pc_output), .in_B(32'b0), .out(next_pc_output), .carry_in(1'b1));
	
	//pc_input is assigned in the execute stage
	
	//FETCH_DECODE LATCH
	wire[31:0] fd_pc_output,fd_ir_output,fd_ir_input;
	assign fd_ir_input = (j_sig | branch_sig) ? 32'b0 : imem_output; //noop stall if jump or branch
	latch_350 fetch_decode_latch(.wren_signal(~stall_sig),.program_counter(next_pc_output),.instruction(fd_ir_input),.clock(clock),.output_PC(fd_pc_output),.output_ins(fd_ir_output));
	
	
	//DECODE STAGE
	//DECODE controller
	wire[4:0] read_reg_A,read_reg_B;
	wire[31:0] branch_to_add;
	wire blt_sig,bne_sig,beq_sig;
	control_decode decode_controller(.instruction(fd_ir_output),.read_reg_s1(read_reg_A),.read_reg_s2(read_reg_B),.beq_signal(beq_sig),.bne_signal(bne_sig),.blt_signal(blt_sig),.branch_N(branch_to_add));
	
	//REGISTER FILE
	wire wren_sig;//WRITEBACK
	wire[4:0] write_register;//WRITEBACK
	wire[31:0] write_data,read_data_A,read_data_B;
	regfile register_file(.clock(~clock), .ctrl_writeEnable(wren_sig), .ctrl_reset(reset), .ctrl_writeReg(write_register),.output_register(output_reg), .ctrl_readRegA(read_reg_A), .ctrl_readRegB(read_reg_B), .data_writeReg(write_data), .data_readRegA(read_data_A), .data_readRegB(read_data_B));

	//BRANCH STUFF, mux is shown in execute but actually done in decoding 
	wire branch_sig;
	wire isNotEqual,isLessThan;
	wire[31:0] temp_read_data_A,temp_read_data_B;
	branch_detector detect(.in_A(temp_read_data_A),.in_B(temp_read_data_B),.blt(isLessThan),.bne(isNotEqual)); //bascially a subtract module :/
	assign branch_sig =(beq_sig & ~isNotEqual) | (bne_sig & isNotEqual) | (blt_sig & ~isLessThan & isNotEqual);
	wire[31:0] new_branch_pc;
	carry_select_adder add_branch_pc(.in_A(fd_pc_output), .in_B(branch_to_add), .out(new_branch_pc), .carry_in(1'b0));
	
	
	//DECODE_EXECUTE LATCH
	wire[31:0] de_pc_output,de_ir_output,de_A_output,de_B_output,de_ir_input;
	assign de_ir_input = (j_sig | stall_sig) ? 32'b0 : fd_ir_output;
	latch_350 decode_execute_latch(.wren_signal(1'b1),.input_A(read_data_A),.input_B(read_data_B),.program_counter(fd_pc_output),.instruction(de_ir_input),.clock(clock),.output_A(de_A_output),.output_B(de_B_output),.output_PC(de_pc_output),.output_ins(de_ir_output));
	
	
	//EXECUTE controller
	wire[4:0] opcode_ALU, shamt;
	wire[31:0] immediate_data;
	wire[31:0] jump_immediate_data;
	wire i_sig,j_sig,jr_sig;
	control_execute execute_controller(.instruction(de_ir_output),.ALU_opcode(opcode_ALU),.ctrl_shamt(shamt),.immediate_value(immediate_data),.i_signal(i_sig),.j_signal(j_sig),.jr_signal(jr_sig),.jump_immediate_value(jump_immediate_data),.pc(de_pc_output));
	
	//JUMP Stuff
	wire[31:0] jump_branch_next_pc,temp_jump_next_pc;
	assign temp_jump_next_pc = (jr_sig) ? de_B_output : jump_immediate_data;
	assign jump_branch_next_pc = (branch_sig) ? new_branch_pc : temp_jump_next_pc; //branch_sig calculations are done in the decode stage
	assign pc_input = (j_sig | branch_sig) ? jump_branch_next_pc : next_pc_output;
	
	//ALU
	wire[31:0] ALU_input_B,ALU_output,ALU_input_A,temp_ALU_input_B;
	assign ALU_input_B = (i_sig) ? immediate_data : temp_ALU_input_B;
	ALU alu(.data_operandA(ALU_input_A), .data_operandB(ALU_input_B), .ctrl_ALUopcode(opcode_ALU), .ctrl_shiftamt(shamt), .data_result(ALU_output));
	
	//EXECUTE_MEMORY_LATCH
	wire[31:0] em_pc_output,em_ir_output, em_A_output,em_B_output;
	latch_350 execute_memory_latch(.wren_signal(1'b1),.input_A(ALU_output),.input_B(temp_ALU_input_B),.program_counter(de_pc_output),.instruction(de_ir_output),.clock(clock),.output_A(em_A_output),.output_B(em_B_output),.output_PC(em_pc_output),.output_ins(em_ir_output));
	

	//MEMORY stage
	//MEMORY controller
	wire sw_sig,swd_sig;
	control_memory memory_controller(.instruction(em_ir_output),.sw_signal(sw_sig),.swd_signal(swd_sig));
	wire[31:0] dmem_output;	
	wire[31:0] dmem_data_input;
	//DMEM
	dmem mydmem(.address(em_A_output[11:0]),.clock(~clock),.data(dmem_data_input),.wren(sw_sig),.q(dmem_output));
	assign vga_wren_enable = swd_sig;
	assign vga_data_addr = em_A_output[18:0];
	assign vga_data_write = dmem_data_input[7:0];

	//MEMORY_WRITEBACK latch
	wire[31:0] mw_pc_output,mw_ir_output,mw_A_output,mw_B_output;
	latch_350 memory_writeback_latch(.wren_signal(1'b1),.input_A(em_A_output),.input_B(dmem_output),.program_counter(em_pc_output),.instruction(em_ir_output),.clock(clock),.output_A(mw_A_output),.output_B(mw_B_output),.output_PC(mw_pc_output),.output_ins(mw_ir_output));
	
	
	//WRITEBACK control
	wire lw_sig,jal_sig;
	control_writeback writeback_controller(.instruction(mw_ir_output),.write_reg_number(write_register),.jal_signal(jal_sig),.lw_signal(lw_sig),.wren_signal(wren_sig));

	wire[31:0] intermediate_value;
	assign intermediate_value = (lw_sig) ? mw_B_output : mw_A_output;
	assign write_data = (jal_sig) ? mw_pc_output : intermediate_value;
	assign lcd_data = write_data;
	assign lcd_write = lw_sig;
	
	
	//BYPASSING LOGIKZ
	//Memory_Stage
	wire bypass_m_sig;
	bypass_m memory_bypass_controller(.mw_instruction(mw_ir_output),.em_instruction(em_ir_output),.bypass_sig(bypass_m_sig));
	assign dmem_data_input = (bypass_m_sig) ? write_data : em_B_output;
	
	//Execute_Stage
	wire[1:0] bypass_e_A_sig,bypass_e_B_sig;
	bypass_e execute_bypass_controller(.mw_instruction(mw_ir_output),.em_instruction(em_ir_output),.de_instruction(de_ir_output),.bypass_A_sig(bypass_e_A_sig),.bypass_B_sig(bypass_e_B_sig));
	
	//ALU_input_A bypass
	assign ALU_input_A = (bypass_e_A_sig[1]) ? em_A_output : 32'bZ;
	assign ALU_input_A = (bypass_e_A_sig[0] & ~bypass_e_A_sig[1]) ? write_data : 32'bZ;
	assign ALU_input_A = (~bypass_e_A_sig[0] & ~bypass_e_A_sig[1]) ? de_A_output :32'bZ;
	
	//ALU_input_B bypass
	assign temp_ALU_input_B = (bypass_e_B_sig[1]) ? em_A_output : 32'bZ;
	assign temp_ALU_input_B = (bypass_e_B_sig[0] & ~bypass_e_B_sig[1]) ? write_data : 32'bZ;
	assign temp_ALU_input_B = (~bypass_e_B_sig[0] & ~bypass_e_B_sig[1]) ? de_B_output :32'bZ;
	
	//Decode_Stage
	wire[2:0] bypass_d_A_sig,bypass_d_B_sig;
	bypass_d decode_bypass_controller(.mw_instruction(mw_ir_output),.em_instruction(em_ir_output),.de_instruction(de_ir_output),.fd_instruction(fd_ir_output),.bypass_A_sig(bypass_d_A_sig),.bypass_B_sig(bypass_d_B_sig));

	//branch_predict_A_bypass
	assign temp_read_data_A = (bypass_d_A_sig[2]) ? ALU_output : 32'bZ;
	assign temp_read_data_A = (~bypass_d_A_sig[2] & bypass_d_A_sig[1]) ? em_A_output : 32'bZ;
	assign temp_read_data_A = (~bypass_d_A_sig[2] & ~bypass_d_A_sig[1] & bypass_d_A_sig[0]) ?  write_data : 32'bZ;
	assign temp_read_data_A = (~bypass_d_A_sig[2] & ~bypass_d_A_sig[1] & ~bypass_d_A_sig[0]) ? read_data_A :32'bZ;
	
	//branch_predict_B_bypass
	assign temp_read_data_B = (bypass_d_B_sig[2]) ? ALU_output : 32'bZ;
	assign temp_read_data_B = (~bypass_d_B_sig[2] & bypass_d_B_sig[1]) ? em_A_output : 32'bZ;
	assign temp_read_data_B = (~bypass_d_B_sig[2] & ~bypass_d_B_sig[1] & bypass_d_B_sig[0]) ?  write_data : 32'bZ;
	assign temp_read_data_B = (~bypass_d_B_sig[2] & ~bypass_d_B_sig[1] & ~bypass_d_B_sig[0]) ? read_data_B :32'bZ;
	
	//STALL_Logic
	stall_logic stall_log(.fd_instruction(fd_ir_output),.de_instruction(de_ir_output),.stall_signal(stall_sig));
	
	/*
	DEBUGGING TOOLS
	*/
	assign ir_out = mw_ir_output;
	assign pc_out = mw_pc_output;
	assign debug_out = write_data;
	
	assign debug_e = ALU_output;
	assign pc_e = de_pc_output;
	assign bypass_e[1:0] = bypass_e_A_sig;
	assign bypass_e[3:2] = bypass_e_B_sig;
	assign ir_e = de_ir_output;
	assign dmem_input = dmem_data_input;
	assign pc_m = em_pc_output;
	assign bypass_m = bypass_m_sig;
	assign pc_d = fd_pc_output;
	assign ir_d = fd_ir_output;
	assign bypass_d[2:0] = bypass_d_A_sig;
	assign bypass_d[5:3] = bypass_d_B_sig;
	
	
	//////////////////////////////////////
	////// THIS IS REQUIRED FOR GRADING
	// CHANGE THIS TO ASSIGN YOUR DMEM WRITE ADDRESS ALSO TO debug_addr
	assign debug_addr = (em_A_output[11:0]);
	// CHANGE THIS TO ASSIGN YOUR DMEM DATA INPUT (TO BE WRITTEN) ALSO TO debug_data
	assign debug_data = (dmem_data_input);
	////////////////////////////////////////////////////////////
	
endmodule
