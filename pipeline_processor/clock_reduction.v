module clock_reduction(clock_in,clock_out,counter_5);
	input clock_in;
	output clock_out;
	output[5:0] counter_5;

	reg[5:0] counter;
	reg clocker;

	assign counter_5 = counter;
	assign clock_out = clocker;

	always@(negedge clock_in)
	begin
		if(counter==5'd1)
			begin
				if(clocker == 1'b1)
					begin
						clocker <= 1'b0;
						counter <= 5'd0;
					end
				else
					begin
						clocker <= 1'b1;
						counter <= 5'd0;
					end
			end
		else
			counter <= counter + 5'd1;
	end





endmodule