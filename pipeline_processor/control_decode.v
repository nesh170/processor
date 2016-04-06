module control_decode(instruction,read_reg_s1,read_reg_s2,bne_signal,blt_signal,branch_N);
	input[31:0] instruction;
	output[4:0] read_reg_s1,read_reg_s2;
	output bne_signal,blt_signal;
	output[31:0] branch_N;
	//optaining the opcode and putting them in individual wires;
	wire A,B,C,D,E;
	assign A = instruction[31];
	assign B = instruction[30];
	assign C = instruction[29];
	assign D = instruction[28];
	assign E = instruction[27];
	
	//Signal to decide whether s2 should be read from rd(if true) or rt
	wire rd_rt_signal;
	assign rd_rt_signal = (~A&~B&~C&D&~E) | (~A&~B&C&~D&~E) | (~A&~B&C&D&~E) | (~A&~B&C&D&E);
	
	
	assign read_reg_s1 = instruction[21:17];
	assign read_reg_s2 = (rd_rt_signal) ? instruction[26:22] : instruction[16:12];
	
	assign bne_signal = (~A&~B&~C&D&~E);
	assign blt_signal = (~A&~B&C&D&~E);
	
	assign branch_N[16:0] = instruction[16:0];
	assign branch_N[31:17] = 15'b0;
	
endmodule