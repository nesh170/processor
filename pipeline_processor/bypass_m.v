module bypass_m(mw_instruction,em_instruction,bypass_sig);
	input[31:0] mw_instruction,em_instruction;
	output bypass_sig;
	
	wire[4:0] rd_mw,rd_em //if they are the same then bypass :D
	//Get the reg_D to compare them
	read_register_decoder mw_decoder(.instruction(mw_instruction),.reg_D(rd_mw));
	read_register_decoder em_decoder(.instruction(em_instruction),.reg_D(rd_em));
	
	equal_comparator(.in_A(rd_mw),.in_B(rd_em),.isEqual(bypass_sig));
	
endmodule