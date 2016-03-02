module mult_module(data_operandA, data_operandB, clock, reset, data_result, data_exception, data_inputRDY, data_resultRDY);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input clock, reset;      
   output [31:0] data_result; 
   output data_exception, data_inputRDY, data_resultRDY; 

	/*
	Handling Reset Cases
	*/
	wire reset_wire; 
	assign reset_wire	= data_exception | reset;
	
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
	
	
	counter_8bit counter(clock, reset_wire, counter_output); //handles the fsm counter
	wire carry_in;
	wire[31:0] booth_output;
	booth_module booth_operations(data_operandA,data_operandB, counter_output, booth_output, carry_in); //this does the shifting and booth operation
	carry_select_adder adder(adder_input, booth_output, input_DFF, carry_in, data_exception); //adds it and throws it back to the DFFE

endmodule