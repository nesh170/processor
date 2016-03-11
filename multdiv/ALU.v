module ALU(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan);
   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
   output [31:0] data_result;
   output isNotEqual, isLessThan;
	
	wire[31:0] decoder_output;
	
	//Decoder
	ALU_decoder decode(ctrl_ALUopcode,decoder_output);
	
	//Adder Block Opcode: 00000
	wire[31:0] adder_output;
	carry_select_adder add(data_operandA, data_operandB, adder_output, 1'b0);
	tri_state tri_state_adder(adder_output,data_result,decoder_output[0]);
	
	//Subtract Block Opcode:00001
	wire[31:0] subtract_output;
	wire carry_out_subtractor;
	subtractor_32bit subtract(data_operandA,data_operandB,subtract_output,carry_out_subtractor);
	tri_state tri_state_subtract(subtract_output,data_result,decoder_output[1]);
	
	//Doing isNotEqual
	assign isNotEqual = ~(~subtract_output & (subtract_output + ~0)) >> 31;
	
	//Doing isLessThen
	wire[3:0] less_then_case_selector;
	assign less_then_case_selector[0] = ~data_operandA[31] & data_operandB[31]; //+-
	assign less_then_case_selector[1] = data_operandA[31] & ~data_operandB[31]; //-+
	assign less_then_case_selector[2] = data_operandA[31] & data_operandB[31]; //--
	assign less_then_case_selector[3] = ~data_operandA[31] & ~data_operandB[31]; //++
	
	assign isLessThan = (less_then_case_selector[0]) ? 1'b0 : 1'bZ;
	assign isLessThan = (less_then_case_selector[1]) ? 1'b1 : 1'bZ;
	assign isLessThan = (less_then_case_selector[2]) ? subtract_output[31] : 1'bZ;
	assign isLessThan = (less_then_case_selector[3]) ? subtract_output[31] : 1'bZ;
	
	//AND Block Opcode: 00010
	tri_state tri_state_AND(data_operandA & data_operandB, data_result, decoder_output[2]);
	
	//Or Block Opcode: 00011
	tri_state tri_state_OR(data_operandA | data_operandB, data_result, decoder_output[3]);
	
	//SLL Opcode:00100
	wire[31:0] SLL_output;
	assign SLL_output = $signed(data_operandA) << ctrl_shiftamt;	
	tri_state tri_state_SLL(SLL_output,data_result,decoder_output[4]);
	
	//SRA Block Opcode:00101
	wire[31:0] SRA_output;
	assign SRA_output = $signed(data_operandA) >>> ctrl_shiftamt;
	tri_state tri_state_SRA(SRA_output,data_result,decoder_output[5]);
	
endmodule

module tri_state(in, out, enable);
	input[31:0] in;
	input enable;
	output [31:0] out;
	
	assign out = (enable) ? in : 32'bZ;

endmodule

module subtractor_32bit(in_A, in_B, out, carry_out);
	input[31:0] in_A,in_B;
	output[31:0] out;
	output carry_out;

	carry_select_adder subtractor(in_A, ~in_B, out, 1'b1,carry_out);
endmodule


module ALU_decoder(in_signal,out_signal);
	input[4:0] in_signal;
	output[31:0] out_signal;

	assign out_signal = (1 << in_signal);
endmodule