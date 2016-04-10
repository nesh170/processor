module mult_latch_3(input_0,input_1,input_2,input_3,output_0,output_1,output_2,output_3,clock,reg_input,reg_output,ins_input,ins_output);
	input[31:0] input_0,input_1,input_2,input_3,reg_input,ins_input;
	input clock;
	output[31:0] output_0,output_1,output_2,output_3,reg_output,ins_output;


	register reg_0(.bitsIn(input_0), .bitsOut(output_0), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_1(.bitsIn(input_1), .bitsOut(output_1), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_2(.bitsIn(input_2), .bitsOut(output_2), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_3(.bitsIn(input_3), .bitsOut(output_3), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	register reg_extra(.bitsIn(reg_input), .bitsOut(reg_output), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
	
	register reg_instruction(.bitsIn(ins_input), .bitsOut(ins_output), .writeEnable(1'b1), .reset(1'b0), .clk(clock));
endmodule