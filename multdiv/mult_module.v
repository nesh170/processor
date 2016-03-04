module mult_module(data_operandA, data_operandB, clock, ctrl_MULT, data_result, data_exception, data_inputRDY, data_resultRDY);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input clock, ctrl_MULT;      
   output [31:0] data_result; 
   output data_exception, data_inputRDY, data_resultRDY; 
	
	wire exception_wire[1:0];
	assign data_exception = exception_wire[1] | exception_wire[0];
	assign exception_wire[0] = 0;
	
	//xor xor_gate(exception_wire[0],data_operandA[31:16]);

	/*
	Handling Reset Cases
	*/
	wire reset_wire; 
	assign reset_wire	= exception_wire[1] | exception_wire[0] | ~ctrl_MULT;
	
	
	
	/*
		Handling the D-Flip-Flop Operation
	*/
	wire[31:0] input_DFF;
	wire[31:0] output_DFF;
	genvar memory_index;
	generate
	for(memory_index=0; memory_index<32; memory_index=memory_index+1) begin: memory_loop
		DFFE memory_storage (.d(input_DFF[memory_index]), .clk(clock),.clrn(~reset_wire), .prn(1'b1), .ena(~data_resultRDY),.q(output_DFF[memory_index]));
	end
	endgenerate
	
	wire[2:0] counter_output; //output from the couter to the BOOTH and SHIFTER
	assign data_resultRDY = counter_output[0] & counter_output[1] & counter_output[2]; //set to high if counter is at 7, meaning the output is ready
	assign data_inputRDY = ~counter_output[0] & ~counter_output[1] & ~counter_output[2]; //set high when counter is at 0, ready to take in new value
	wire[31:0] adder_input; //goes from DFFE to adder
		/*
	Handles the output of the DFFE  on whether to display to the user or exit the program
	*/
	assign data_result = (data_resultRDY) ? output_DFF : 32'bz;
	assign adder_input = (~data_resultRDY) ? output_DFF : 32'bz;
	
	
	counter counter_3bit(clock, reset_wire, counter_output); //handles the fsm counter
	wire carry_in;
	wire[31:0] booth_output;
	booth_module booth_operations(data_operandA,data_operandB, counter_output, booth_output, carry_in); //this does the shifting and booth operation
	carry_select_adder adder(adder_input, booth_output, input_DFF, carry_in, exception_wire[1]); //adds it and throws it back to the DFFE

endmodule