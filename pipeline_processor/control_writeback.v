module control_writeback(instruction,data_output_signal,jal_instruction,write_enable_signal);
	input[31:0] instruction
	output data_output_signal,jal_instruction,write_enable_signal;

	wire[4:0] opcode
	assign opcode = instruction[31:27];
	assign write_enable_signal = (~opcode[4]&~opcode[2]&~opcode[1]&~opcode[0]) | (~opcode[4]&~opcode[3]&~opcode[2]&opcode[1]&opcode[0]) | (~opcode[4]&~opcode[3]&opcode[2]&~opcode[1]&opcode[0]);
	assign jal_instruction = (~opcode[4]&~opcode[3]&~opcode[2]&opcode[1]&opcode[0]);
	assign data_output_signal = (~opcode[4]&opcode[3]&~opcode[2]&~opcode[1]&~opcode[0]);
endmodule