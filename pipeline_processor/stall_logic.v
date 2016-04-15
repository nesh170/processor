module stall_logic(fd_instruction,de_instruction,stall_signal);
	input[31:0] fd_instruction,de_instruction;
	output stall_signal;
	
	wire de_load,fd_save;
	wire[4:0] fd_rs1,fd_rs2,de_rd;
	read_register_decoder fd_decoder(.instruction(fd_instruction),.reg_S1(fd_rs1),.reg_S2(fd_rs2));
	read_register_decoder de_decoder(.instruction(de_instruction),.reg_D(de_rd));
	
	assign de_load = ~de_instruction[31]&de_instruction[30]&~de_instruction[29]&~de_instruction[28]&~de_instruction[27];
	assign fd_save = (~fd_instruction[31]&~fd_instruction[30]&fd_instruction[29]&fd_instruction[28]&fd_instruction[27]) | (fd_instruction[31]&~fd_instruction[30]&~fd_instruction[29]&~fd_instruction[28]&fd_instruction[27]) ;
	
	wire equal_rs1_rd,equal_rs2_rd;
	equal_comparator equalator_a(.in_A(fd_rs1),.in_B(de_rd),.isEqual(equal_rs1_rd));
	equal_comparator equalator_b(.in_A(fd_rs2),.in_B(de_rd),.isEqual(equal_rs2_rd));
	
	assign stall_signal = (de_load) & ((equal_rs1_rd) | (equal_rs2_rd&~fd_save));

endmodule