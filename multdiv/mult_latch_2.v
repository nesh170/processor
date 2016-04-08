module mult_latch_2(input_0,input_1,input_2,input_3,input_4,input_5,input_6,input_7,output_0,output_1,output_2,output_3,output_4,output_5,output_6,output_7,clock,reg_input,reg_output);
	input[31:0] input_0,input_1,input_2,input_3,input_4,input_5,input_6,input_7,reg_input;
	input clock;
	output[31:0] output_0,output_1,output_2,output_3,output_4,output_5,output_6,output_7,reg_output;
	

	register reg_0(.bitsIn(input_0), .bitsOut(output_0), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_1(.bitsIn(input_1), .bitsOut(output_1), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_2(.bitsIn(input_2), .bitsOut(output_2), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_3(.bitsIn(input_3), .bitsOut(output_3), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_4(.bitsIn(input_4), .bitsOut(output_4), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_5(.bitsIn(input_5), .bitsOut(output_5), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_6(.bitsIn(input_6), .bitsOut(output_6), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_7(.bitsIn(input_7), .bitsOut(output_7), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	
	register reg_extra(.bitsIn(reg_input), .bitsOut(reg_output), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	
endmodule