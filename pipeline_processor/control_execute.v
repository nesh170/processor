module control_execute(instruction,output_immediate_value,output_jump_value,output_opcode,output_shamt,output_i,output_j);
	input[31:0] instruction;
	output[16:0] output_immediate_value;
	output[26:0] output_jump_value;
	output[4:0] output_opcode,output_shamt;
	output output_i,output_j;
	
	wire i_type,j_type;
	assign j_type = 1'b0;//TODO
	assign i_type = ~instruction[31] & ~instruction[30] & instruction[29] & ~instruction[28] & instruction[27];
	assign output_i = i_type;
	assign output_j = j_type; 
	assign output_jump_value = instruction[26:0];
	assign output_immediate_value = instruction[16:0];
	assign output_opcode = (i_type) ? 5'b00101 : instruction[6:2];
	assign output_shamt = instruction[11:7];
	
	
	
endmodule
	