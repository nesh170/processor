module mult_latch_1_4(input_A,input_B,output_A,output_B,clock);
	input[31:0] input_A,input_B;
	input clock;
	output[31:0] output_A,output_B;
	

	register reg_A(.bitsIn(input_A), .bitsOut(output_A), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_B(.bitsIn(input_B), .bitsOut(output_B), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	
	
endmodule