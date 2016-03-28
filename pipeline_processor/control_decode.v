module control_decode(instruction,rs,rt,sw_signal);
	input[31:0] instruction;
	output[4:0] rs,rt;
	wire sw_signal;
	
	assign sw_signal = ~instruction[31] & ~instruction[30] & instruction[29] & instruction[28] & instruction[27];
	assign rs = instruction[21:17];
	assign rt = (sw_signal) instruction[26:22] : instruction[16:12];

endmodule