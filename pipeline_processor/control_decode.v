module control_decode(instruction,rs,rt);
	input[31:0] instruction;
	output[4:0] rs,rt;
	wire i_j_signal;
	wire[4:0] opcode;
	
	assign opcode = instruction[31:27];
	//A=4,B=3,C=2,D=1,E=0
	assign i_j_signal = (~opcode[4]&~opcode[3]&opcode[0]) | (~opcode[4]&~opcode[3]&opcode[1]) | (~opcode[4]&~opcode[3]&opcode[2]) | (~opcode[3]&opcode[2]&~opcode[1]&opcode[0]) | (~opcode[3]&opcode[2]&opcode[1]&~opcode[0]) | (~opcode[4]&opcode[3]&~opcode[2]&~opcode[1]&~opcode[0]);
	assign rs = instruction[21:17];
	assign rt = (i_j_signal) instruction[26:22] : instruction[16:12];

endmodule