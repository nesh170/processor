module control_decode(instruction,rs,rt);
	input[31:0] instruction;
	output[4:0] rs,rt;
	
	
	assign rs = instruction[21:17];
	assign rt = instruction[16:12];
	
	




endmodule