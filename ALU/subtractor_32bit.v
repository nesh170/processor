/*
*Creating A-B=out
*/

module subtractor_32bit(in_A, in_B, out, carry_out);
	input[31:0] in_A,in_B;
	output[31:0] out;
	output carry_out;
	
	//inverting B and setting carry _n to +1 to convert B into -B
	carry_select_Adder subtractor(in_A, ~in_B, out, 1'b1,carry_out);
endmodule