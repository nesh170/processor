module multdiv(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, data_result, data_exception, data_inputRDY, data_resultRDY);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input ctrl_MULT, ctrl_DIV, clock;             
   output [31:0] data_result; 
   output data_exception, data_inputRDY, data_resultRDY;
	
	wire[31:0] temp_mult_result;
	
	mult_module multiplier(data_operandA, data_operandB, clock, ctrl_MULT, temp_mult_result, data_exception, data_inputRDY, data_resultRDY);
	assign data_result = temp_mult_result;
	
endmodule

