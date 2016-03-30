module control_writeback(instruction,destination_register,data_output_signal,jal_instruction,write_enable_signal);
	input[31:0] instruction;
	output data_output_signal,jal_instruction,write_enable_signal;
	output[4:0] destination_register;

	wire[4:0] opcode;
	assign opcode = instruction[31:27];
	assign write_enable_signal = (~opcode[4]&~opcode[2]&~opcode[1]&~opcode[0]) | (~opcode[4]&~opcode[3]&~opcode[2]&opcode[1]&opcode[0]) | (~opcode[4]&~opcode[3]&opcode[2]&~opcode[1]&opcode[0]);
	assign jal_instruction = (~opcode[4]&~opcode[3]&~opcode[2]&opcode[1]&opcode[0]);
	assign data_output_signal = (~opcode[4]&opcode[3]&~opcode[2]&~opcode[1]&~opcode[0]);
	
	
	assign destination_register = instruction[26:22];
endmodule