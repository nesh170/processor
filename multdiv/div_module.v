module div_module(data_operandA, data_operandB, clock, data_result, data_exception, data_inputRDY, data_resultRDY);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input clock;      
   output [31:0] data_result; 
   output data_exception, data_inputRDY, data_resultRDY;
	
	/*
	Flips the signs if they are negative and predict the output sign
	*/
	wire predicted_sign;
	wire[31:0] dividend,divisor;
	assign divisor[31:16] = 0;
	sign_checker(data_operandA,data_operandB,dividend,divisor[15:0],predicted_sign);
	
	assign data_exception = (~|divisor); //DIV by 0 Check
	
	
	wire[31:0] aligned_divisor;
	align_divider aligner(dividend,divisor,aligned_divisor);
	
	//ALU(data_operandA, data_operandB, 00001, ctrl_shiftamt, data_result, isNotEqual, isLessThan);
	
	genvar index;
	generate
	for(index = 0; index<31; index=index+1) begin: divisor_loop
		
	end
	endgenerate

endmodule