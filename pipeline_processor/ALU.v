module ALU(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, mult_exception, div_exception);
   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
   output [31:0] data_result;
   output isNotEqual, isLessThan;
   output div_exception,mult_exception;
	
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
	shift_left_logical SLL_gate(data_operandA, ctrl_shiftamt, SLL_output);
	tri_state tri_state_SLL(SLL_output,data_result,decoder_output[4]);
	
	//SRA Block Opcode:00101
	wire[31:0] SRA_output;
	shift_right_arithmetic SRA_gate(data_operandA, ctrl_shiftamt, SRA_output);
	tri_state tri_state_SRA(SRA_output,data_result,decoder_output[5]);
	
	//Mult Opcode: 00110
	wire[31:0] mult_output;
	wire temp_mult_exception;
	multiplier muliply_operation(.multiplicand(data_operandA), .multiplier(data_operandB[15:0]), .result(mult_output), .data_exception(temp_mult_exception));
	tri_state tri_state_MULT(mult_output,data_result,decoder_output[6]);
	assign mult_exception = (decoder_output[6]) ? temp_mult_exception : 1'b0;

	//DIV module Opcode: 00111
	wire[31:0] div_output;
	wire temp_div_exception;
	div_module divider(.data_operandA(data_operandA), .data_operandB(data_operandB[15:0]), .ctrl_DIV(1'b1), .data_result(div_output), .data_exception(temp_div_exception));
	tri_state tri_state_DIV(div_output,data_result,decoder_output[7]);
	assign div_exception = (decoder_output[7]) ? temp_div_exception : 1'b0;
endmodule

module tri_state(in, out, enable);
	input[31:0] in;
	input enable;
	output [31:0] out;
	
	assign out = (enable) ? in : 32'bZ;

endmodule

module shift_right_arithmetic(in ,ctrl_ShiftAmt,out);
	input[31:0] in;
	input[4:0] ctrl_ShiftAmt;
	output[31:0] out;
	
	assign out = $signed(in) >>> ctrl_ShiftAmt;
endmodule

module shift_left_logical(in, ctrl_ShiftAmt, out);
	input[31:0] in;
	input[4:0] ctrl_ShiftAmt;
	output[31:0] out;
	
	assign out = in << ctrl_ShiftAmt;
endmodule

/*
*Creating A-B=out
*/

module subtractor_32bit(in_A, in_B, out, carry_out);
	input[31:0] in_A,in_B;
	output[31:0] out;
	output carry_out;
	
	//inverting B and setting carry _n to +1 to convert B into -B
	carry_select_adder subtractor(in_A, ~in_B, out, 1'b1,carry_out);
endmodule

module carry_select_adder(in_A, in_B, out, carry_in, carry_out);
	input[31:0] in_A,in_B;
	input carry_in;
	output carry_out;
	output[31:0] out;
	
	wire carry_outWireToMux;
	wire carry_outWire[1:0];
	wire[31:0] sum1,sum2;
	wire[7:0] carry_out_of_Gate;
	
	adder_4bit adder_1v4(in_A[3:0],in_B[3:0],carry_in,out[3:0],carry_out_of_Gate[0]);
	
	genvar index,index_1;
	generate
	for(index=1;index <=7; index = index+1) begin:loop_adder
		wire[1:0] c_out;
		wire[3:0] out_0;
		wire[3:0] out_1;
		adder_4bit adder_0(in_A[((index*4)+3):index*4],in_B[((index*4)+3):index*4],1'b0,out_0,c_out[0]);
		adder_4bit adder_1(in_A[((index*4)+3):index*4],in_B[((index*4)+3):index*4],1'b1,out_1,c_out[1]);
		for(index_1=0; index_1<4; index_1 = index_1 + 1) begin:loop_mux
			assign out[index*4 + index_1] = (carry_out_of_Gate[index-1]) ? out_1[index_1] : out_0[index_1];
		end
		assign carry_out_of_Gate[index] = (carry_out_of_Gate[index-1]) ? c_out[1] : c_out[0];
	end
	endgenerate
	
	assign carry_out = carry_out_of_Gate[7];

endmodule

module adder_4bit(in_A,in_B,carry_in,out, carry_out);
	input[3:0] in_A, in_B; 
	input carry_in;
	output[3:0] out;
	output carry_out;
	wire [2:0] carry_out_wire;
	
	adder_1bit adder1(in_A[0],in_B[0],carry_in,out[0],carry_out_wire[0]);
	adder_1bit adder2(in_A[1],in_B[1],carry_out_wire[0],out[1],carry_out_wire[1]);
	adder_1bit adder3(in_A[2],in_B[2],carry_out_wire[1],out[2],carry_out_wire[2]);
	adder_1bit adder4(in_A[3],in_B[3],carry_out_wire[2],out[3],carry_out);
	
endmodule

module adder_1bit(in_A, in_B , carry_in, out, carry_out);
	input in_A, in_B, carry_in;
	output out,carry_out;
	
	wire xorGateOutput1,cOutProcess1,cOutProcess2;
	
	xor xorGate1(xorGateOutput1, in_A, in_B);
	xor xorGate2(out,carry_in,xorGateOutput1);
	and ANDGate1(cOutProcess1,in_A,in_B);
	and ANDGate2(cOutProcess2,carry_in,xorGateOutput1);
	or ORGate(carry_out,cOutProcess1,cOutProcess2);
	
endmodule

module ALU_decoder(in_signal,out_signal);
	input[4:0] in_signal;
	output[31:0] out_signal;

	assign out_signal = (1 << in_signal);
endmodule