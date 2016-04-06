module bypass_d(mw_instruction,em_instruction,de_instruction,fd_instruction,bypass_A_sig,bypass_B_sig);
	input[31:0] mw_instruction,em_instruction,de_instruction,fd_instruction;
	output[2:0] bypass_A_sig,bypass_B_sig;
	
	wire[4:0] fd_reg_S1,fd_reg_S2,de_reg_D,em_reg_D,mw_reg_D;
	read_register_decoder fd_decoder(.instruction(fd_instruction),.reg_S1(fd_reg_S1),.reg_S2(fd_reg_S2));
	read_register_decoder de_decoder(.instruction(de_instruction),.reg_D(de_reg_D));
	read_register_decoder em_decoder(.instruction(em_instruction),.reg_D(em_reg_D));
	read_register_decoder mw_decoder(.instruction(mw_instruction),.reg_D(mw_reg_D));
	
	equal_comparator equal_A(.in_A(fd_reg_S1),.in_B(mw_reg_D),.isEqual(bypass_A_sig[0]));
	equal_comparator equal_B(.in_A(fd_reg_S1),.in_B(em_reg_D),.isEqual(bypass_A_sig[1]));
	equal_comparator equal_C(.in_A(fd_reg_S1),.in_B(de_reg_D),.isEqual(bypass_A_sig[2]));
	
	equal_comparator equal_D(.in_A(fd_reg_S2),.in_B(mw_reg_D),.isEqual(bypass_B_sig[0]));
	equal_comparator equal_E(.in_A(fd_reg_S2),.in_B(em_reg_D),.isEqual(bypass_B_sig[1]));
	equal_comparator equal_F(.in_A(fd_reg_S2),.in_B(de_reg_D),.isEqual(bypass_B_sig[2]));
endmodule