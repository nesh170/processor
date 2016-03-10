module mult_module(data_operandA, data_operandB,ctrl_MULT, clock, data_result, data_exception, data_inputRDY, data_resultRDY);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input clock,ctrl_MULT;      
   output [31:0] data_result; 
   output data_exception, data_inputRDY, data_resultRDY; 
	
	wire[31:0] output_booth[7:0];
	booth_module booth(data_operandA,data_operandB, output_booth[0],output_booth[1],output_booth[2],output_booth[3],output_booth[4],output_booth[5],output_booth[6],output_booth[7]);
	
	wire[31:0] adder_stage_1_output[3:0];
	wire[31:0] adder_stage_2_output[1:0];
	wire[31:0] adder_stage_3_output;
	/*
	Adding all the output_booth below
	*/
	/*
	Stage 1 addition = 1 cycle
	*/
	carry_select_adder stage_1_1(output_booth[0], output_booth[1], adder_stage_1_output[0], 0);
	carry_select_adder stage_1_2(output_booth[2], output_booth[3], adder_stage_1_output[1], 0);
	carry_select_adder stage_1_3(output_booth[4], output_booth[5], adder_stage_1_output[2], 0);
	carry_select_adder stage_1_4(output_booth[6], output_booth[7], adder_stage_1_output[3], 0);
	
	/*
	Stage 2 addition = 1 cycle
	*/
	carry_select_adder stage_2_1(adder_stage_1_output[0], adder_stage_1_output[1], adder_stage_2_output[0], 0);
	carry_select_adder stage_2_2(adder_stage_1_output[2], adder_stage_1_output[3], adder_stage_2_output[1], 0);
	
	/*
	Stage 3 addition = 1 cycle, final stage
	*/
	carry_select_adder stage_3(adder_stage_2_output[0], adder_stage_2_output[1], adder_stage_3_output, 0);
	assign data_result = adder_stage_3_output;
	
	
	/*
	Handle counter to assert the data_inputRDY and data_resultRDY
	*/
	wire[2:0] counter_output;
	wire in_signal; //the in_signal is used to reset the wire, effectively turning the counter to be a mod k counter where k <= 8
	counter count_8(clock, in_signal, counter_output);
	assign in_signal = ~ctrl_MULT; 
	assign data_resultRDY = (counter_output[0] & counter_output[1] & counter_output[2]); //currently mod 8 counter; change here to change it
	assign data_inputRDY = ~counter_output[0] & ~counter_output[1] & ~counter_output[2];
	
	/*
	Data exception is triggered when the sign bit of the output does not match the predicted output sign.
	*/
	assign data_exception= (data_operandA[31]^data_operandB[15])^adder_stage_3_output[31];
endmodule