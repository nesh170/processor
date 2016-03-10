module multdiv(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, data_result, data_exception, data_inputRDY, data_resultRDY);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input ctrl_MULT, ctrl_DIV, clock;             
   output [31:0] data_result; 
   output data_exception, data_inputRDY, data_resultRDY;
	
	wire[31:0] temp_mult_result;
	wire mult_exception,mult_inputRDY,mult_resultRDY;
	
	mult_module multiplier(data_operandA, data_operandB, clock, temp_mult_result, mult_exception, mult_inputRDY, mult_resultRDY);
	assign data_result = (ctrl_MULT) ? temp_mult_result : 32'bZ;
	assign data_exception = (ctrl_MULT) ? mult_exception : 1'bZ;
	assign data_inputRDY = (ctrl_MULT) ? mult_inputRDY : 1'bZ;
	assign data_resultRDY = (ctrl_MULT) ? mult_resultRDY : 1'bZ;
	
	wire[31:0] temp_div_result;
	wire div_exception,div_inputRDY,div_resultRDY;
	
	div_module diviplier(data_operandA, data_operandB, clock, temp_div_result, div_exception, div_inputRDY, div_resultRDY);
	assign data_result = (ctrl_DIV) ? temp_div_result : 32'bZ;
	assign data_exception = (ctrl_DIV) ? div_exception : 1'bZ;
	assign data_inputRDY = (ctrl_DIV) ? div_inputRDY : 1'bZ;
	assign data_resultRDY = (ctrl_DIV) ? div_resultRDY : 1'bZ;
	
endmodule

