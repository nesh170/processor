module mult_latch_1_4(input_A,input_B,reg_input,output_A,output_B,clock,reg_output,ins_input,ins_output);
	input[31:0] input_A,input_B,reg_input,ins_input;
	input clock;
	output[31:0] output_A,output_B,reg_output,ins_output;
	

	register reg_A(.bitsIn(input_A), .bitsOut(output_A), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_B(.bitsIn(input_B), .bitsOut(output_B), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_extra(.bitsIn(reg_input), .bitsOut(reg_output), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_instruction(.bitsIn(ins_input), .bitsOut(ins_output), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	
	
endmodule