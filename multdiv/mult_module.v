module mult_module(data_A, data_B,mult_signal, clock, data_result, exception, input_RDY, result_RDY);
	input[31:0] data_A;
	input[15:0] data_B;
	input mult_signal,clock;

	output[31:0] data_result;
	output exception,input_RDY,result_RDY;
	
	
	
	//Latch 1
	wire[31:0] multiplier,multiplicand,temp_data_B,important_bits,latch_1_important; //important bits hold predicted output and result_rdy
	assign temp_data_B[31:16] = 16'b0;
	assign temp_data_B[15:0] = data_B; //Registers are 32 bits wide
	assign important_bits[0] = data_A[31]^data_B[15]; //0 bit is predicted sign
	assign important_bits[1] = mult_signal; //bit 1 is the mult signal
	mult_latch_1_4 latch_1(.input_A(data_A),.input_B(temp_data_B),.output_A(multiplicand),.output_B(multiplier),.clock(clock),.reg_input(important_bits),.reg_output(latch_1_important));
	
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
			booth_decoder decoder(.shifted_multiplicand((data_A << (2*index))),.booth_operation(booth_input[index]),.output_multiplicand(booth_output[index]));
		end
	endgenerate
	
	
	//LATCH 2
	wire[31:0] latch_2_important;
	wire[31:0] latch_2_output[7:0];
	mult_latch_2 latch_2(.input_0(booth_output[0]),.input_1(booth_output[1]),.input_2(booth_output[2]),.input_3(booth_output[3]),.input_4(booth_output[4]),.input_5(booth_output[5]),.input_6(booth_output[6]),.input_7(booth_output[7]),.output_0(latch_2_output[0]),.output_1(latch_2_output[1]),.output_2(latch_2_output[2]),.output_3(latch_2_output[3]),.output_4(latch_2_output[4]),.output_5(latch_2_output[5]),.output_6(latch_2_output[6]),.output_7(latch_2_output[7]),.clock(clock),.reg_input(latch_1_important),.reg_output(latch_2_important));
	
	//Stage 2 operations, adding the a tree structure 0+1,2+3,4+5,6+7;
	wire[31:0] adder_2_output[3:0];
	carry_select_adder add_stage_2_1(.in_A(latch_2_output[0]), .in_B(latch_2_output[1]), .out(adder_2_output[0]), .carry_in(1'b0));
	carry_select_adder add_stage_2_2(.in_A(latch_2_output[2]), .in_B(latch_2_output[3]), .out(adder_2_output[1]), .carry_in(1'b0));
	carry_select_adder add_stage_2_3(.in_A(latch_2_output[4]), .in_B(latch_2_output[5]), .out(adder_2_output[2]), .carry_in(1'b0));
	carry_select_adder add_stage_2_4(.in_A(latch_2_output[6]), .in_B(latch_2_output[7]), .out(adder_2_output[3]), .carry_in(1'b0));
	
	//LATCH 3
	wire[31:0] latch_3_important;
	wire[31:0] latch_3_output[3:0];
	mult_latch_3 latch_3(.input_0(adder_2_output[0]),.input_1(adder_2_output[1]),.input_2(adder_2_output[2]),.input_3(adder_2_output[3]),.output_0(latch_3_output[0]),.output_1(latch_3_output[1]),.output_2(latch_3_output[2]),.output_3(latch_3_output[3]),.clock(clock),.reg_input(latch_2_important),.reg_output(latch_3_important));
	
	//Stage 3 operations, adding in a tree structure (0+1) + (2+3), (4+5) + (6+7)
	wire[31:0] adder_3_output[1:0];
	carry_select_adder add_stage_3_1(.in_A(latch_3_output[0]), .in_B(latch_3_output[1]), .out(adder_3_output[0]), .carry_in(1'b0));
	carry_select_adder add_stage_3_2(.in_A(latch_3_output[2]), .in_B(latch_3_output[3]), .out(adder_3_output[1]), .carry_in(1'b0));
	
	//LATCH 4
	wire[31:0] latch_4_important;
	wire[31:0] latch_4_output[1:0];
	mult_latch_1_4 latch_4(.input_A(adder_3_output[0]),.input_B(adder_3_output[1]),.output_A(latch_4_output[0]),.output_B(latch_4_output[1]),.clock(clock),.reg_input(latch_3_important),.reg_output(latch_4_important));

	//Stage 4 operations, adding in a tree structure ((0+1) + (2+3)) + ((4+5) + (6+7))
	carry_select_adder add_stage_4_1(.in_A(latch_4_output[0]), .in_B(latch_4_output[1]), .out(data_result), .carry_in(1'b0));
	assign exception = (data_result[31]^latch_4_important[0]);
	assign result_RDY = latch_4_important[1];
	assign input_RDY =1'b1; //always ready to acccept input since it opens a new space every clock cycle
	
endmodule