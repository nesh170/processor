module mult_module(data_operandA, data_operandB,ctrl_MULT, clock, data_result, data_exception, data_inputRDY, data_resultRDY);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input clock,ctrl_MULT;      
   output [31:0] data_result; 
   output data_exception, data_inputRDY, data_resultRDY; 
	
	/*
		This is to handle the first input edge case so 0 will be added to the adder
	*/
	wire[31:0] temp_adder_wire[8:0];
	assign temp_adder_wire[0] = 32'b0;
	
	wire[1:0] wire_reset;
	assign wire_reset[0] = ^data_operandA[31:15];
	assign wire_reset[1] = ~ctrl_MULT;
	assign data_exception = wire_reset[0];
	
	wire[2:0] counter_output;
	
	counter counter_3_bit(clock,|wire_reset,counter_output);
	assign data_inputRDY = ~counter_output[0] & ~counter_output[1] & ~counter_output[2];
	assign data_resultRDY = counter_output[0] & counter_output[1] & counter_output[2];
	
	
	wire[31:0] booth_output[7:0];
	genvar index;
	generate
		for(index=1; index<9; index=index+1) begin:mult_loop
			wire carry_in;
			booth_module booth(data_operandA,data_operandB,index-1,booth_output[index-1],carry_in);
			carry_select_adder adder(temp_adder_wire[index-1],booth_output[index-1],temp_adder_wire[index],carry_in);
		end
	endgenerate

	assign data_result = temp_adder_wire[8];

endmodule