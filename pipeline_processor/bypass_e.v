module bypass_e(mw_instruction,em_instruction,de_instruction,bypass_A_sig,bypass_B_sig);
	input[31:0] mw_instruction,em_instruction,de_instruction;
	output[1:0] bypass_A_sig,bypass_B_sig;
	
	
	//Signal to decide whether s2 should be read from rd(if true) or rt
	wire em_rd_rt_signal,mw_rd_rt_signal;
	
	//1=comparison with mw, 0=comparison with em
	wire[4:0] de_reg_S1,de_reg_S2,em_reg_D,mw_reg_D;
	read_register_decoder de_decoder(.instruction(de_instruction),.reg_S1(de_reg_S1),.reg_S2(de_reg_S2));
	read_register_decoder em_decoder(.instruction(em_instruction),.reg_D(em_reg_D),.rd_rt(em_rd_rt_signal));
	read_register_decoder mw_decoder(.instruction(mw_instruction),.reg_D(mw_reg_D),.rd_rt(mw_rd_rt_signal));
	
	wire[1:0] temp_A,temp_B;
	equal_comparator equal_A(.in_A(mw_reg_D),.in_B(de_reg_S1),.isEqual(temp_A[0]));
	equal_comparator equal_B(.in_A(em_reg_D),.in_B(de_reg_S1),.isEqual(temp_A[1]));
	equal_comparator equal_C(.in_A(mw_reg_D),.in_B(de_reg_S2),.isEqual(temp_B[0]));
	equal_comparator equal_D(.in_A(em_reg_D),.in_B(de_reg_S2),.isEqual(temp_B[1]));
	
	assign bypass_A_sig[0] = temp_A[0]&~mw_rd_rt_signal;
	assign bypass_A_sig[1] = temp_A[1]&~em_rd_rt_signal;
	assign bypass_B_sig[0] = temp_B[0]&~mw_rd_rt_signal;
	assign bypass_B_sig[1] = temp_B[1]&~em_rd_rt_signal;
	
endmodule