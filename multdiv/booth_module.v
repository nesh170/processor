module booth_module(multiplicand,multiplier, counter_val, booth_output, carry_out);
	input[31:0] multiplicand;
	input[15:0] multiplier;
	input[2:0] counter_val;
	output carry_out;
	output[31:0] booth_output;
	
	/*
	Gets the operation counter in one hot decoding
	*/
	wire[7:0] one_hot_counter_amt;
	assign one_hot_counter_amt = 8'b00000001 << counter_val;
	
	
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
	
	/*
		The code below generates the shifters and booth_decoders to resturn the right output which is then added but the adder
	*/
	genvar index;
	generate
	for(index=0; index<8; index = index + 1) begin: loop_structure
		wire[31:0] shift_wire;
		wire[31:0] temp_output;
		wire temp_carry_out;
		assign shift_wire = multiplicand << (2*index);
		booth_decoder decode(booth_input[index],shift_wire,temp_output,temp_carry_out);
		assign booth_output = (one_hot_counter_amt[index]) ? temp_output : 32'bZ;
		assign carry_out = (one_hot_counter_amt[index]) ? temp_carry_out : 1'bZ;
	end
	endgenerate
	

endmodule