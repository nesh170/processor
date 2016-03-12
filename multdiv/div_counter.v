module div_counter(clock, in_signal, out, present, next);
	input clock, in_signal;
	output[2:0] out;
	output [5:0] present,next;
	
	
	wire [5:0] present;
	
	reg[2:0] out;
	reg[5:0] next;
	
	always @(*) begin
		if(in_signal)
			next = 6'b0;
		else if(present~=6'b100001)
			next = present + 1;
		else if(present == 6'b100001)
			next = 6'b0;
		else 
			next = 6'b0;
		end
	end
	
	always @(present) begin
		if(present==6'b0)
			out = 2'b01;
		else if(present == 6'b100001)
			out = 2'b10;
		else 
			out = 2'b00;
		end
	end

	DFF state_reg_0(.clk(clock), .d(next[0]), .q(present[0]));
	DFF state_reg_1(.clk(clock), .d(next[1]), .q(present[1]));
	DFF state_reg_2(.clk(clock), .d(next[2]), .q(present[2]));
	DFF state_reg_3(.clk(clock), .d(next[3]), .q(present[3]));
	DFF state_reg_4(.clk(clock), .d(next[4]), .q(present[4]));
	DFF state_reg_5(.clk(clock), .d(next[5]), .q(present[5]));
endmodule