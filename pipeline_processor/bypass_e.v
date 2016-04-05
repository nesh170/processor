module bypass_e(mw_instruction,em_instruction,de_instruction,bypass_A_sig,bypass_B_sig);
	input[31:0] mw_instruction,em_instruction,de_instruction;
	output[1:0] bypass_A_sig,bypass_B_sig;
	
	//1=comparison with mw, 0=comparison with em
	wire[4:0] de_reg_S1,de_reg_S2,em_reg_D,mw_reg_D;
	read_register_decoder de_decoder(.instruction(de_instruction),.reg_S1(de_reg_S1),.reg_S2(de_reg_S2));
	read_register_decoder em_decoder(.instruction(em_instruction),.reg_D(em_reg_D));
	read_register_decoder mw_decoder(.instruction(mw_instruction),.reg_D(mw_reg_D));
	
	equal_comparator(.in_A(mw_reg_D),.in_B(de_reg_S1),.isEqual(bypass_A_sig[1]));
	equal_comparator(.in_A(em_reg_D),.in_B(de_reg_S1),.isEqual(bypass_A_sig[0]));
	equal_comparator(.in_A(mw_reg_D),.in_B(de_reg_S2),.isEqual(bypass_B_sig[1]));
	equal_comparator(.in_A(em_reg_D),.in_B(de_reg_S2),.isEqual(bypass_B_sig[0]));
endmodule