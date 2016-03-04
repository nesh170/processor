module mult_module(data_operandA, data_operandB, clock, ctrl_MULT, data_result, data_exception, data_inputRDY, data_resultRDY);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input clock, ctrl_MULT;      
   output [31:0] data_result; 
   output data_exception, data_inputRDY, data_resultRDY; 

	/*
	Handling Reset Cases
	*/
	wire reset_wire; 
	assign reset_wire	= data_exception | ~ctrl_MULT;

	
	//xor xor_gate(data_exception,data_operandA[31:16]);
	
	counter counter_3bit(clock, reset_wire, counter_output); //handles the fsm counter
	wire carry_in;
	wire[31:0] booth_output;
	booth_module booth_operations(data_operandA,data_operandB, counter_output, booth_output, carry_in); //this does the shifting and booth operation
	carry_select_adder adder(adder_input, booth_output, input_DFF, carry_in, data_exception); //adds it and throws it back to the DFFE

endmodule