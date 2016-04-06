module read_register_decoder(instruction,reg_S1,reg_S2,reg_D);
	input[31:0] instruction;
	output[4:0] reg_S1,reg_S2,reg_D;
	
	//optaining the opcode and putting them in individual wires;
	wire A,B,C,D,E;
	assign A = instruction[31];
	assign B = instruction[30];
	assign C = instruction[29];
	assign D = instruction[28];
	assign E = instruction[27];
	
	//Signal to decide whether s2 should be read from rd(if true) or rt
	wire rd_rt_signal;
	assign rd_rt_signal = (~A&~B&~C&D&~E) | (~A&~B&C&~D&~E) | (~A&~B&C&D&~E) | (~A&~B&C&D&E); //00010 00100 00110 00111
	
	assign reg_S1 = instruction[21:17];
	assign reg_S2 = (rd_rt_signal) ? instruction[26:22] : instruction[16:12];
	assign reg_D = instruction[26:22];

endmodule