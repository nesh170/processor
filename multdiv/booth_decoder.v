module booth_decoder(booth_operation,multiplicand,adder_output,carry_out); //takes in the shifted multiplicand
	input[2:0] booth_operation;
	input[31:0] multiplicand;
	output[31:0] adder_output;
	output carry_out;
	
	wire[7:0] booth_operation_wire;
	assign booth_operation_wire = 8'b00000001 << booth_operation; //this generates which operation should be performed
	
	wire[31:0] output_operation_wire[7:0];
	
	
	assign output_operation_wire[0] = 0;
	assign output_operation_wire[1] = multiplicand;
	assign output_operation_wire[2] = multiplicand;
	assign output_operation_wire[3] = (multiplicand << 1);
	assign output_operation_wire[4] = ~(multiplicand << 1);
	assign output_operation_wire[5] = ~multiplicand;
	assign output_operation_wire[6] = ~multiplicand;
	assign output_operation_wire[7] = 0;
	
	genvar output_index;
	generate
	for(output_index=0;output_index<8;output_index=output_index+1) begin: output_loop
		assign adder_output = (booth_operation_wire[output_index]) ? output_operation_wire[output_index] : 32'bZ;
	end
	endgenerate
	assign carry_out = booth_operation_wire[4] | booth_operation_wire[6] | booth_operation_wire[5];
	
endmodule



