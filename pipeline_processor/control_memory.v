module control_memory(instruction,data_write);
	input[31:0] instruction;
	input data_write;
	
	wire[4:0] opcode
	assign opcode = instruction[31:27];
	assign data_write =~opcode[4] & ~opcode[3] & opcode[2] & opcode[1] & opcode[0];  //only asserted for saveword  which is 00111
	
	
endmodule
	