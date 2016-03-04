module register(bitsIn, bitsOut, reset, clk);
	input [31:0] bitsIn;
	input reset, clk;
	output [31:0] bitsOut;
	
	genvar index;
	generate
		for(index=0; index<=31; index=index+1) begin: loop1
			DFFE dflipflop(.d(bitsIn[index]),.clk(clk),.clrn(~reset),.prn(1'b1),.ena(1'b1),.q(bitsOut[index]));
		end
	endgenerate
endmodule