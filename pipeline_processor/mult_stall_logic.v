module mult_stall_logic(mult_ins_signal,fd_instruction,instruction_1,instruction_2,instruction_3,instruction_4,mult_stall_logic_signal);
	input mult_ins_signal;
	input[31:0] fd_instruction,instruction_1,instruction_2,instruction_3,instruction_4;
	output mult_stall_logic_signal;
	
	//Obtaining the right registers to use for comparison
	wire[4:0] fd_regD,mult_1_rs1,mult_1_rs2,mult_2_rs1,mult_2_rs2,mult_3_rs1,mult_3_rs2;
	read_register_decoder read_fd_for_rd(.instruction(fd_instruction),.reg_D(fd_regD));
	read_register_decoder read_reg_mult_1(.instruction(instruction_1),.reg_S1(mult_1_rs1),.reg_S2(mult_1_rs2));
	read_register_decoder read_reg_mult_2(.instruction(instruction_2),.reg_S1(mult_2_rs1),.reg_S2(mult_2_rs2));
	read_register_decoder read_reg_mult_3(.instruction(instruction_3),.reg_S1(mult_3_rs1),.reg_S2(mult_3_rs2));
	
	wire[5:0] equal_signal;
	equal_comparator equal_0(.in_A(fd_regD),.in_B(mult_1_rs1),.isEqual(equal_signal[0]));
	equal_comparator equal_1(.in_A(fd_regD),.in_B(mult_1_rs2),.isEqual(equal_signal[1]));
	equal_comparator equal_2(.in_A(fd_regD),.in_B(mult_2_rs1),.isEqual(equal_signal[2]));
	equal_comparator equal_3(.in_A(fd_regD),.in_B(mult_2_rs2),.isEqual(equal_signal[3]));
	equal_comparator equal_4(.in_A(fd_regD),.in_B(mult_3_rs1),.isEqual(equal_signal[4]));
	equal_comparator equal_5(.in_A(fd_regD),.in_B(mult_3_rs2),.isEqual(equal_signal[5]));

	
	

	assign mult_stall_logic_signal = (|equal_signal);
	
	
endmodule