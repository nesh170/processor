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