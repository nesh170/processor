module control_memory(instruction,sw_signal,swd_signal);
	input[31:0] instruction;
	output sw_signal,swd_signal;
	
	//optaining the opcode and putting them in individual wires;
	wire A,B,C,D,E;
	assign A = instruction[31];
	assign B = instruction[30];
	assign C = instruction[29];
	assign D = instruction[28];
	assign E = instruction[27];
	
	assign sw_signal = ~A&~B&C&D&E;
	assign swd_signal = A&~B&~C&~D&E;

endmodule