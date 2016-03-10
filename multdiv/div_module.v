module div_module(data_operandA, data_operandB, clock, temp_div_result, div_exception, div_inputRDY, div_resultRDY);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input clock;      
   output [31:0] data_result; 
   output data_exception, data_inputRDY, data_resultRDY; 

endmodule