module branch_detector(in_A,in_B,blt,bne);
	input[31:0] in_A,in_B;
	output blt,bne;
	
	wire[31:0] subtract_output;
	subtractor_32bit sub(.in_A(in_A), .in_B(in_B), .out(subtract_output));
	
	//Doing isNotEqual
	assign bne = ~(~subtract_output & (subtract_output + ~0)) >> 31;
	
	//Doing isLessThen
	wire[3:0] less_then_case_selector;
	assign less_then_case_selector[0] = ~in_A[31] & in_B[31]; //+-
	assign less_then_case_selector[1] = in_A[31] & ~in_B[31]; //-+
	assign less_then_case_selector[2] = in_A[31] & in_B[31]; //--
	assign less_then_case_selector[3] = ~in_A[31] & ~in_B[31]; //++
	
	assign blt = (less_then_case_selector[0]) ? 1'b0 : 1'bZ;
	assign blt	= (less_then_case_selector[1]) ? 1'b1 : 1'bZ;
	assign blt = (less_then_case_selector[2]) ? subtract_output[31] : 1'bZ;
	assign blt = (less_then_case_selector[3]) ? subtract_output[31] : 1'bZ;
endmodule