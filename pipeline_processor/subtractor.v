module subtractor(data_operandA, data_operandB, data_result, isLessThan, isNotEqual);
   input [31:0] data_operandA, data_operandB;
   output [31:0] data_result;
   output isLessThan, isNotEqual;
	
	wire[31:0] subtract_output;
	subtractor_32bit sub(data_operandA,data_operandB,subtract_output);
	

	wire[3:0] less_then_case_selector;
	assign less_then_case_selector[0] = ~data_operandA[31] & data_operandB[31]; //+-
	assign less_then_case_selector[1] = data_operandA[31] & ~data_operandB[31]; //-+
	assign less_then_case_selector[2] = data_operandA[31] & data_operandB[31]; //--
	assign less_then_case_selector[3] = ~data_operandA[31] & ~data_operandB[31]; //++
	
	assign isLessThan = (less_then_case_selector[0]) ? 1'b0 : 1'bZ;
	assign isLessThan = (less_then_case_selector[1]) ? 1'b1 : 1'bZ;
	assign isLessThan = (less_then_case_selector[2]) ? subtract_output[31] : 1'bZ;
	assign isLessThan = (less_then_case_selector[3]) ? subtract_output[31] : 1'bZ;
	
	assign data_result = subtract_output;
	assign isNotEqual = ~(~subtract_output & (subtract_output + ~0)) >> 31;
	
endmodule