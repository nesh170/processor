module ALU_decoder(in_signal,out_signal);
	input[4:0] in_signal;
	output[31:0] out_signal;

	assign out_signal = (1 << in_signal);
endmodule