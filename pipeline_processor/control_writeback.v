module control_writeback(instruction,write_reg_number,jal_signal,lw_signal,wren_signal);
	input[31:0] instruction;
	output[4:0] write_reg_number;
	output jal_signal,lw_signal,wren_signal;
	
	//optaining the opcode and putting them in individual wires;
	wire A,B,C,D,E;
	assign A = instruction[31];
	assign B = instruction[30];
	assign C = instruction[29];
	assign D = instruction[28];
	assign E = instruction[27];
	
	wire jal_signal_wire;
	assign jal_signal_wire = ~A&~B&~C&D&E;
	
	assign write_reg_number = (jal_signal_wire) ? 5'b11111 : instruction[26:22];
	
	assign jal_signal = jal_signal_wire;
	assign lw_signal = ~A&B&~C&~D&~E;
	assign wren_signal = (~A&~B&~C&~D&~E) | (~A&~B&~C&D&E) | (~A&~B&C&~D&E) | (~A&B&~C&~D&~E) | (A&B&C&D&~E);
	
	
endmodule