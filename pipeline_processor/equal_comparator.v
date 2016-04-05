module equal_comparator(in_A,in_B,isEqual);
	input[4:0] in_A,in_B;
	output isEqual;
	
	//Testing equality by xor both the inputs, then nor each bit in the output
	wire[4:0] temp_state;
	assign temp_state = in_A^in_B;
	
	assign isEqual = ~|temp_state;
	
endmodule