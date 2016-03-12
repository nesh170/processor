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
	sign_checker check_sign(data_operandA,data_operandB,dividend,divisor[15:0],predicted_sign); //tested and works
	
	assign data_exception = (~|divisor); //DIV by 0 Check
	
	
	wire[31:0] aligned_divisor;
	align_divider aligner(dividend,divisor,aligned_divisor);
		
	wire[31:0] temp_divisor[31:0];
	wire[31:0] remainder[31:0];
	wire[31:0] temp_quotient[31:0];
	assign remainder[0] = dividend;
	assign temp_divisor[0] = aligned_divisor;
	assign temp_quotient[0] = 32'b0;
	
	/*
	try to figure whether 1 or 0: if A<B, then choose 0
	*/
	// //A<B
	//subtractor(data_operandA, data_operandB, data_result, isLessThan, isHighImp)
	genvar index;
	generate
	for(index = 0; index<31; index=index+1) begin: divisor_loop
		wire isNotEqual,isLessThan,isHighImp_1,isHighImp_2,divisor_isNotEqual,divisor_isLessThan;
		wire[31:0] temp_wire;
		wire[31:0] temp_remainder; //because we need to pick between - 0 or not
		subtractor sub1(remainder[index],temp_divisor[index],isLessThan,isHighImp_1);
		subtractor sub2(remainder[index],divisor,temp_wire,divisor_isLessThan,isHighImp_2); //figure out if shift or not
		assign remainder[index+1] = (~isHighImp_1) ? remainder[index] : temp_remainder; //is a<B then subtract 0 else subtract temp_divisor
		wire[31:0] w1;
		wire[31:0] temp_shift_wire;
		assign temp_shift_wire = (temp_quotient[index] << 1);
		assign w1[31:1] = temp_shift_wire[31:1];
		assign w1[0] = (~isHighImp_2) ? temp_shift_wire[0] : isHighImp_1;
		assign temp_quotient[index+1] = (~isHighImp_2) ? temp_quotient[index] : w1[31:0];
	end
	endgenerate
	
	wire[31:0] positive_temp_quotient,negative_temp_quotient;
	assign positive_temp_quotient = temp_quotient[31];
	carry_select_adder adder(~positive_temp_quotient, 0, negative_temp_quotient, 1);
	//assign data_result = (predicted_sign) ? negative_temp_quotient : positive_temp_quotient;
	assign data_result = temp_quotient[31];

endmodule