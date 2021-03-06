module booth_decoder(shifted_multiplicand,booth_operation,output_multiplicand);
	input[31:0] shifted_multiplicand;
	input[2:0] booth_operation;
	
	output[31:0] output_multiplicand;
		
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
	carry_select_adder adder(temp_output, 32'b0, output_multiplicand, make_negative); //generate a negative shifted multiplicand
	
endmodule