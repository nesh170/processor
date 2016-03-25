module multdiv(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, data_result, data_exception, data_inputRDY, data_resultRDY);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input ctrl_MULT, ctrl_DIV, clock;             
   output [31:0] data_result; 
   output data_exception, data_inputRDY, data_resultRDY;
	
	wire[31:0] temp_mult_result;
	wire mult_exception,mult_inputRDY,mult_resultRDY;
	mult_module multiplier(data_operandA, data_operandB,ctrl_MULT, clock, temp_mult_result, mult_exception, mult_inputRDY, mult_resultRDY);
	assign data_result = (ctrl_MULT) ? temp_mult_result : 32'bZ;
	assign data_exception = (ctrl_MULT) ? mult_exception : 1'bZ;
	assign data_inputRDY = (ctrl_MULT) ? mult_inputRDY : 1'bZ;
	assign data_resultRDY = (ctrl_MULT)  ? mult_resultRDY : 1'bZ;
	
	wire[31:0] temp_div_result;
	wire div_exception,div_inputRDY,div_resultRDY;
	div_module diviplier(data_operandA, data_operandB, ctrl_DIV, clock, temp_div_result, div_exception, div_inputRDY, div_resultRDY);
	assign data_result = (ctrl_DIV) ? temp_div_result : 32'bZ;
	assign data_exception = (ctrl_DIV) ? div_exception : 1'bZ;
	assign data_inputRDY = (ctrl_DIV) ? div_inputRDY : 1'bZ;
	assign data_resultRDY = (ctrl_DIV) ? div_resultRDY : 1'bZ;
endmodule

module booth_decoder(booth_operation,shifted_multiplicand,adder_output); //takes in the shifted multiplicand
	input[2:0] booth_operation;
	input[31:0] shifted_multiplicand;
	output[31:0] adder_output;
	
	wire[7:0] booth_operation_wire;
	assign booth_operation_wire = 8'b00000001 << booth_operation; //this generates which operation should be performed
	
	wire[31:0] output_operation_wire[7:0];
	
	assign output_operation_wire[0] = 0;
	assign output_operation_wire[1] = shifted_multiplicand;
	assign output_operation_wire[2] = shifted_multiplicand;
	assign output_operation_wire[3] = (shifted_multiplicand << 1);
	assign output_operation_wire[4] = ~(shifted_multiplicand << 1);
	assign output_operation_wire[5] = ~shifted_multiplicand;
	assign output_operation_wire[6] = ~shifted_multiplicand;
	assign output_operation_wire[7] = 0;
	
	wire[31:0] temp_output;
	genvar output_index;
	generate
	for(output_index=0;output_index<8;output_index=output_index+1) begin: output_loop
		assign temp_output = (booth_operation_wire[output_index]) ? output_operation_wire[output_index] : 32'bZ;
	end
	endgenerate
	wire make_negative;
	assign make_negative = booth_operation_wire[4] | booth_operation_wire[5] | booth_operation_wire[6];
	carry_select_adder adder(temp_output, 32'b0, adder_output, make_negative); //generate a negative shifted multiplicand
	
endmodule

module booth_module(multiplicand,multiplier, booth_output_0,booth_output_1,booth_output_2,booth_output_3,booth_output_4,booth_output_5,booth_output_6,booth_output_7);
	input[31:0] multiplicand;
	input[15:0] multiplier;
	output[31:0] booth_output_0;
	output[31:0] booth_output_1;
	output[31:0] booth_output_2;
	output[31:0] booth_output_3;
	output[31:0] booth_output_4;
	output[31:0] booth_output_5;
	output[31:0] booth_output_6;
	output[31:0] booth_output_7;
	
	
	/*
	The code below handles the implicit 0 case
	*/
	wire[2:0] temp_booth_0;
	assign temp_booth_0[0] = 0;
	assign temp_booth_0[2:1] = multiplier[1:0];
	/*
	Adds all the booth value from the multiplier to a wire array so it could be used for calculation
	*/
	wire[2:0] booth_input[7:0];
	assign booth_input[0] = temp_booth_0;
	assign booth_input[1] = multiplier[3:1];
	assign booth_input[2] = multiplier[5:3];
	assign booth_input[3] = multiplier[7:5];
	assign booth_input[4] = multiplier[9:7];
	assign booth_input[5] = multiplier[11:9];
	assign booth_input[6] = multiplier[13:11];
	assign booth_input[7] = multiplier[15:13];
	
	wire[31:0] booth_output[7:0];
	genvar index;
	generate
	for(index=0; index<8; index = index + 1) begin: loop_structure
		booth_decoder booth(booth_input[index],(multiplicand << (2*index)),booth_output[index]);
	end
	endgenerate
	
	assign booth_output_0=booth_output[0];
	assign booth_output_1=booth_output[1];
	assign booth_output_2=booth_output[2];
	assign booth_output_3=booth_output[3];
	assign booth_output_4=booth_output[4];
	assign booth_output_5=booth_output[5];
	assign booth_output_6=booth_output[6];
	assign booth_output_7=booth_output[7];
	

endmodule

`define state0  3'b000
`define state1  3'b001
`define state2  3'b010
`define state3  3'b011
`define state4  3'b100
`define state5  3'b101
`define state6  3'b110
`define state7  3'b111

module counter(clock, in_signal, out, present, next);
	input clock, in_signal;
	output[2:0] out;
	output [2:0] present,next;
	
	
	wire [2:0] present;
	
	reg[2:0] out;
	reg[2:0] next;
	
	always @(*) begin
		case(present)
			`state0: next = in_signal ? `state0 : `state1;
			`state1: next = in_signal ? `state0 : `state2;
			`state2: next = in_signal ? `state0 : `state3;
			`state3: next = in_signal ? `state0 : `state4;
			`state4: next = in_signal ? `state0 : `state5;
			`state5: next = in_signal ? `state0 : `state6;
			`state6: next = in_signal ? `state0 : `state7;
			`state7: next = in_signal ? `state0 : `state0;
			default: next = `state0;
		endcase
	end
	
	always @(present) begin
		case(present)
			`state0: out = `state0;
			`state1: out = `state1;
			`state2: out = `state2;
			`state3: out = `state3;
			`state4: out = `state4;
			`state5: out = `state5;
			`state6: out = `state6;
			`state7: out = `state7;
			default: out = `state0;
		endcase
	end

	dff state_reg_0(.clk(clock), .d(next[0]), .q(present[0]));
	dff state_reg_1(.clk(clock), .d(next[1]), .q(present[1]));
	dff state_reg_2(.clk(clock), .d(next[2]), .q(present[2]));
	
endmodule

module div_counter(clock, in_signal, out, present, next);
	input clock, in_signal;
	output[2:0] out;
	output [5:0] present,next;
	
	
	wire [5:0] present;
	
	reg[1:0] out;
	reg[5:0] next;
	
	always @(*) begin
		if(in_signal)
			next = 6'b0;
		else if(present!=6'b100001)
			next = present + 1;
		else if(present == 6'b100001)
			next = 6'b0;
		else 
			next = 6'b0;
	end
	
	always @(present) begin
		if(present==6'b0)
			out = 2'b01;
		else if(present == 6'b100001)
			out = 2'b10;
		else 
			out = 2'b00;
	end

	dff state_reg_0(.clk(clock), .d(next[0]), .q(present[0]));
	dff state_reg_1(.clk(clock), .d(next[1]), .q(present[1]));
	dff state_reg_2(.clk(clock), .d(next[2]), .q(present[2]));
	dff state_reg_3(.clk(clock), .d(next[3]), .q(present[3]));
	dff state_reg_4(.clk(clock), .d(next[4]), .q(present[4]));
	dff state_reg_5(.clk(clock), .d(next[5]), .q(present[5]));
endmodule

module div_module(data_operandA, data_operandB, ctrl_DIV, clock, data_result, data_exception, data_inputRDY, data_resultRDY);
   input [31:0] data_operandA;
   input [15:0] data_operandB;
   input clock,ctrl_DIV;      
   output [31:0] data_result; 
   output data_exception, data_inputRDY, data_resultRDY;
	/*
	Flips the signs if they are negative and predict the output sign
	*/
	wire predicted_sign;
	wire[31:0] dividend,divisor;
	assign divisor[31:16] = 0;
	sign_checker check_sign(data_operandA,data_operandB,dividend,divisor[15:0],predicted_sign); //tested and works
	
	assign data_exception = ~|data_operandB;
	
	wire[1:0] counter_output;
	div_counter counter_33(clock, ~ctrl_DIV, counter_output);
	assign data_inputRDY = (counter_output[1] & ~counter_output[0]) | (~counter_output[1] & counter_output[0]);
	assign data_resultRDY = counter_output[1] & ~counter_output[0];
//	assign data_inputRDY = 1; assign data_resultRDY = 1;
	
	wire[31:0] remainder[32:0];
	wire[31:0] temp_quotient;
	
	assign remainder[0] = 32'b0;
	
	
	genvar index;
	generate
	for(index=0;index < 32;index = index + 1) begin: divider_loop
		wire[31:0] temp_shifted_remainder;
		assign temp_shifted_remainder = (remainder[index] << 1);
		wire[31:0] modified_shifted_remainder;
		assign modified_shifted_remainder[31:1] = temp_shifted_remainder[31:1];
		assign modified_shifted_remainder[0] = dividend[(index-31)*-1];
		
		wire[31:0] temp_sub_value;
		wire isLessThan,isNotEqual;
		subtractor sub_1(modified_shifted_remainder,divisor, temp_sub_value,isLessThan,isNotEqual); 
		assign temp_quotient[(index-31)*-1] = (~isLessThan&isNotEqual | ~isNotEqual) ? 1'b1:1'b0;
		assign remainder[index+1] = (~isLessThan&isNotEqual | ~isNotEqual) ? temp_sub_value : modified_shifted_remainder;
	end
	endgenerate
	
	wire[31:0] positive_temp_quotient,negative_temp_quotient;
	assign positive_temp_quotient = temp_quotient;
	carry_select_adder adder(~positive_temp_quotient, 0, negative_temp_quotient, 1);
	assign data_result = (predicted_sign) ? negative_temp_quotient : positive_temp_quotient;

endmodule

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
	assign data_inputRDY = (~counter_output[0] & ~counter_output[1] & ~counter_output[2]) | (counter_output[0] & counter_output[1] & counter_output[2]);
	//assign data_inputRDY=1; assign data_resultRDY=1;
	
	/*
	Data exception is triggered when the sign bit of the output does not match the predicted output sign.
	*/
	assign data_exception= (data_operandA[31]^data_operandB[15])^adder_stage_3_output[31];
endmodule

module sign_checker(data_operandA,data_operandB,output_A,output_B,output_sign);
	input[31:0] data_operandA;
	input[15:0] data_operandB;
	output output_sign;
	output[31:0] output_A;
	output[15:0] output_B;
	
	
	
	/*
	This modules checks for the sign if they are negative and predicts the output sign
	*/
	assign output_sign = data_operandA[31]^data_operandB[15]; //figures out what the value is at the end
	
	wire[31:0] temp_A_flip;
	wire[15:0] temp_B_flip;
	
	carry_select_adder flip_A(~data_operandA, 0, temp_A_flip, 1); //flip the sign
	carry_select_adder flip_B(~data_operandB, 0, temp_B_flip, 1); //flip the sign
	
	
	assign output_A = (~data_operandA[31]) ? data_operandA :32'bZ;
	assign output_A = (data_operandA[31]) ? temp_A_flip :32'bZ; //the original is negative, make it +ve
	
	assign output_B = (~data_operandB[15]) ? data_operandB : 16'bZ;
	assign output_B = (data_operandB[15]) ? temp_B_flip : 16'bZ; //the original is negative, make it +ve
	
endmodule

module subtractor(data_operandA, data_operandB, data_result, isLessThan, isNotEqual);
   input [31:0] data_operandA, data_operandB;
   output [31:0] data_result;
   output isLessThan, isNotEqual;
	
	wire[31:0] subtract_output;
	subtractor_32bi sub(data_operandA,data_operandB,subtract_output);
	
	wire[3:0] less_then_case_selector;
	assign less_then_case_selector[0] = ~data_operandA[31] & data_operandB[31]; //+-
	assign less_then_case_selector[1] = data_operandA[31] & ~data_operandB[31]; //-+
	assign less_then_case_selector[2] = data_operandA[31] & data_operandB[31]; //--
	assign less_then_case_selector[3] = ~data_operandA[31] & ~data_operandB[31]; //++
	
	assign isLessThan = (less_then_case_selector[0]) ? 1'b0 : 1'bZ;
	assign isLessThan = (less_then_case_selector[1]) ? 1'b1 : 1'bZ;
	assign isLessThan = (less_then_case_selector[2]) ? subtract_output[31] : 1'bZ;
	assign isLessThan = (less_then_case_selector[3]) ? subtract_output[31] : 1'bZ;
	
	assign data_result = subtract_output;
	assign isNotEqual = ~(~subtract_output & (subtract_output + ~0)) >> 31;
	
endmodule

module subtractor_32bi(in_A, in_B, out, carry_out);
	input[31:0] in_A,in_B;
	output[31:0] out;
	output carry_out;

	carry_select_adder subtractor(in_A, ~in_B, out, 1'b1,carry_out);
endmodule










