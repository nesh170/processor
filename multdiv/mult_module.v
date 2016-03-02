module mult_module(data_operandA, data_operandB, clock, data_result, data_exception, data_inputRDY, data_resultRDY);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input clock;      
   output [31:0] data_result; 
   output data_exception, data_inputRDY, data_resultRDY; 
	
	/*
		This is to handle the first input edge case so 0 will be added to the adder
	*/
	wire[31:0] temp_adder_wire[8:0];
	assign temp_adder_wire[0] = 32'b0;
	

	genvar index;
	generate
		for(index=1; index<9; index=index+1) begin:mult_loop
			wire carry_in;
			wire[31:0] booth_output;
			booth_module booth(data_operandA,data_operandB,index-1,booth_output,carry_in);
			carry_select_adder adder(temp_adder_wire[index-1],booth_output,temp_adder_wire[index],carry_in);
		end
	endgenerate

	assign data_result = temp_adder_wire[8];
	assign data_inputRDY = 1;
	assign data_resultRDY = 1;
endmodule