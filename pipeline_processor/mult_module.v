module mult_module(data_A, data_B,mult_signal, clock, data_result, exception, input_RDY, result_RDY,input_ins,instruction_1,instruction_2,instruction_3,instruction_4);
	input[31:0] data_A,input_ins;
	input[15:0] data_B;
	input mult_signal,clock;

	output[31:0] data_result,instruction_1,instruction_2,instruction_3,instruction_4;
	output exception,input_RDY,result_RDY;
	
	//Operations before LATCH 1
	wire[31:0] multiplier,multiplicand,important_bits; //important bits hold predicted output and result_rdy
	assign multiplicand = data_A;
	assign multiplier[31:16] = 16'b0;
	assign multiplier[15:0] = data_B; //Registers are 32 bits wide
	assign important_bits[0] = data_A[31]^data_B[15]; //0 bit is predicted sign
	assign important_bits[1] = mult_signal; //bit 1 is the mult signal
	
	//Stage 1 operations - Handing the shifting operation and generating the shifted multiplicand to be added to the next stages
	/*
	The code below handles the implicit 0 case
	*/
	wire[2:0] temp_booth_0;
	assign temp_booth_0[0] = 0;
	assign temp_booth_0[2:1] = multiplier[1:0];
	wire[2:0] booth_input[7:0];
	assign booth_input[0] = temp_booth_0;
	assign booth_input[1] = multiplier[3:1];
	assign booth_input[2] = multiplier[5:3];
	assign booth_input[3] = multiplier[7:5];
	assign booth_input[4] = multiplier[9:7];
	assign booth_input[5] = multiplier[11:9];
	assign booth_input[6] = multiplier[13:11];
	assign booth_input[7] = multiplier[15:13];
	
	/*
	Adds all the booth value from the multiplier to a wire array so it could be used for calculation
	*/
	wire[31:0] booth_output[7:0];
	genvar index;
	generate
		for(index=0; index<8; index = index + 1) begin: loop_structure
			booth_decoder decoder(.shifted_multiplicand((multiplicand << (2*index))),.booth_operation(booth_input[index]),.output_multiplicand(booth_output[index]));
		end
	endgenerate
	
	
	//LATCH 1
	wire[31:0] latch_1_important,latch_1_output_instruction;
	wire[31:0] latch_1_output[7:0];
	mult_latch_2 latch_1(.input_0(booth_output[0]),.input_1(booth_output[1]),.input_2(booth_output[2]),.input_3(booth_output[3]),.input_4(booth_output[4]),.input_5(booth_output[5]),.input_6(booth_output[6]),.input_7(booth_output[7]),.output_0(latch_1_output[0]),.output_1(latch_1_output[1]),.output_2(latch_1_output[2]),.output_3(latch_1_output[3]),.output_4(latch_1_output[4]),.output_5(latch_1_output[5]),.output_6(latch_1_output[6]),.output_7(latch_1_output[7]),.clock(clock),.reg_input(important_bits),.reg_output(latch_1_important),.ins_input(input_ins),.ins_output(latch_1_output_instruction));
	
	//Stage 1 operations, adding the a tree structure 0+1,2+3,4+5,6+7;
	wire[31:0] adder_1_output[3:0];
	carry_select_adder add_stage_1_1(.in_A(latch_1_output[0]), .in_B(latch_1_output[1]), .out(adder_1_output[0]), .carry_in(1'b0));
	carry_select_adder add_stage_1_2(.in_A(latch_1_output[2]), .in_B(latch_1_output[3]), .out(adder_1_output[1]), .carry_in(1'b0));
	carry_select_adder add_stage_1_3(.in_A(latch_1_output[4]), .in_B(latch_1_output[5]), .out(adder_1_output[2]), .carry_in(1'b0));
	carry_select_adder add_stage_1_4(.in_A(latch_1_output[6]), .in_B(latch_1_output[7]), .out(adder_1_output[3]), .carry_in(1'b0));
	
	//LATCH 2
	wire[31:0] latch_2_important,latch_2_output_instruction;
	wire[31:0] latch_2_output[3:0];
	mult_latch_3 latch_2(.input_0(adder_1_output[0]),.input_1(adder_1_output[1]),.input_2(adder_1_output[2]),.input_3(adder_1_output[3]),.output_0(latch_2_output[0]),.output_1(latch_2_output[1]),.output_2(latch_2_output[2]),.output_3(latch_2_output[3]),.clock(clock),.reg_input(latch_1_important),.reg_output(latch_2_important),.ins_input(latch_1_output_instruction),.ins_output(latch_2_output_instruction));
	
	//Stage 2 operations, adding in a tree structure (0+1) + (2+3), (4+5) + (6+7)
	wire[31:0] adder_2_output[1:0];
	carry_select_adder add_stage_3_1(.in_A(latch_2_output[0]), .in_B(latch_2_output[1]), .out(adder_2_output[0]), .carry_in(1'b0));
	carry_select_adder add_stage_3_2(.in_A(latch_2_output[2]), .in_B(latch_2_output[3]), .out(adder_2_output[1]), .carry_in(1'b0));
	
	//LATCH 3
	wire[31:0] latch_3_important,latch_3_output_instruction;
	wire[31:0] latch_3_output[1:0];
	mult_latch_1_4 latch_3(.input_A(adder_2_output[0]),.input_B(adder_2_output[1]),.output_A(latch_3_output[0]),.output_B(latch_3_output[1]),.clock(clock),.reg_input(latch_2_important),.reg_output(latch_3_important),.ins_input(latch_2_output_instruction),.ins_output(latch_3_output_instruction));

	//Stage 3 operations, adding in a tree structure ((0+1) + (2+3)) + ((4+5) + (6+7))
	wire[31:0] adder_3_output;
	wire[31:0] important_bits_3;
	carry_select_adder add_stage_4_1(.in_A(latch_3_output[0]), .in_B(latch_3_output[1]), .out(adder_3_output), .carry_in(1'b0));
	assign important_bits_3[0] = (adder_3_output[31]^latch_3_important[0]);
	assign important_bits_3[1] = latch_3_important[1];

	//FINAL Latch
	wire[31:0] final_important_bits,latch_4_output_instruction;
	mult_latch_1_4 latch_4(.input_A(adder_3_output),.reg_input(important_bits_3),.output_A(data_result),.clock(clock),.reg_output(final_important_bits),.ins_input(latch_3_output_instruction),.ins_output(latch_4_output_instruction));
	assign exception = final_important_bits[0];
	assign result_RDY = final_important_bits[1];

	assign input_RDY =1'b1; //always ready to acccept input since it opens a new space every clock cycle

	//Assigning all the output port instructions
	assign instruction_1 = latch_1_output_instruction;
	assign instruction_2 = latch_2_output_instruction;
	assign instruction_3 = latch_3_output_instruction;
	assign instruction_4 = latch_4_output_instruction;
	
endmodule