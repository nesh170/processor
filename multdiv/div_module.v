module div_module(data_operandA, data_operandB, ctrl_DIV, clock, data_result, data_exception, data_inputRDY, data_resultRDY,less,notEq);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input clock,ctrl_DIV;      
   output [31:0] data_result; 
	output [31:0] less,notEq;
   output data_exception, data_inputRDY, data_resultRDY;
	/*
	Flips the signs if they are negative and predict the output sign
	*/
	wire predicted_sign;
	wire[31:0] dividend,divisor;
	assign divisor[31:16] = 0;
	sign_checker check_sign(data_operandA,data_operandB,dividend,divisor[15:0],predicted_sign); //tested and works
	
	assign data_exception = (~|divisor); //DIV by 0 Check
	
	
	wire[31:0] remainder[32:0];
	wire[31:0] temp_quotient;
	
	assign remainder[0] = 32'b0;
	
	
	genvar index;
	generate
	for(index=0;index < 32;index = index + 1) begin: divider_loop
		wire[31:0] temp_shifted_remainder;
		assign temp_shifted_remainder = (remainder[index] << 1);
		wire[31:0] modified_shifted_remainder;
		assign modified_shifted_remainder[31:1] = temp_shifted_remainder[31:1];
		assign modified_shifted_remainder[0] = dividend[(index-31)*-1];
		
		wire[31:0] temp_sub_value;
		wire isLessThan,isNotEqual;
		
		subtractor sub_1(modified_shifted_remainder,divisor, temp_sub_value,isLessThan,isNotEqual); 
		assign less[index] = isLessThan;
		assign notEq[index] = isNotEqual;
		assign temp_quotient[(index-31)*-1] = (~isLessThan&isNotEqual | ~isNotEqual) ? 1'b1:1'b0;
		assign remainder[index+1] = (~isLessThan&isNotEqual | ~isNotEqual) ? temp_sub_value : modified_shifted_remainder;
	end
	endgenerate
	
	wire[31:0] positive_temp_quotient,negative_temp_quotient;
	assign positive_temp_quotient = temp_quotient;
	carry_select_adder adder(~positive_temp_quotient, 0, negative_temp_quotient, 1);
	assign data_result = (predicted_sign) ? negative_temp_quotient : positive_temp_quotient;

endmodule