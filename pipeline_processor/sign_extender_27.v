module sign_extender_27(in_bits,out_bits);
	input[26:0] in_bits;
	output[31:0] out_bits;
	/**
	Takes in a 17 bit and sign extend it to 31 bits
	**/
	assign out_bits[26:0] = in_bits;
	
	genvar index;
	generate
	for(index=27; index<32;index=index+1)begin:loop
		assign out_bits[index]=in_bits[26];
	end
	endgenerate
endmodule