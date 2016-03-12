module sign_checker(data_operandA,data_operandB,output_A,output_B,output_sign);
	input[31:0] data_operandA;
	input[15:0] data_operandB;
	output output_sign;
	output[31:0] output_A;
	output[15:0] output_B;
	
	
	
	/*
	This modules checks for the sign if they are negative and predicts the output sign
	*/
	assign output_sign = data_operandA[31]^data_operandB[15]; //figures out what the value is at the end
	
	wire[31:0] temp_A_flip;
	wire[15:0] temp_B_flip;
	
	carry_select_adder flip_A(~data_operandA, 0, temp_A_flip, 1); //flip the sign
	carry_select_adder flip_B(~data_operandB, 0, temp_B_flip, 1); //flip the sign
	
	
	assign output_A = (~data_operandA[31]) ? data_operandA :32'bZ;
	assign output_A = (data_operandA[31]) ? temp_A_flip :32'bZ; //the original is negative, make it +ve
	
	assign output_B = (~data_operandB[15]) ? data_operandB : 16'bZ;
	assign output_B = (data_operandB[15]) ? temp_B_flip : 16'bZ; //the original is negative, make it +ve
	
endmodule