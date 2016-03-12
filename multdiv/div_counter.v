module div_counter(clock, in_signal, out, present, next);
	input clock, in_signal;
	output[6:0] out;
	output [6:0] present,next;
	
	
	wire [6:0] present;
	
	reg[2:0] out;
	reg[6:0] next;
	
	always @(*) begin
		case(present)
			`state0: next = in_signal ? `state0 : `state1;
			`state1: next = in_signal ? `state0 : `state2;
			`state2: next = in_signal ? `state0 : `state3;
			`state3: next = in_signal ? `state0 : `state4;
			`state4: next = in_signal ? `state0 : `state5;
			`state5: next = in_signal ? `state0 : `state6;
			`state6: next = in_signal ? `state0 : `state7;
			`state7: next = in_signal ? `state0 : `state0;
			default: next = `state0;
		endcase
	end
	
	always @(present) begin
		case(present)
			`state0: out = `state0;
			`state1: out = `state1;
			`state2: out = `state2;
			`state3: out = `state3;
			`state4: out = `state4;
			`state5: out = `state5;
			`state6: out = `state6;
			`state7: out = `state7;
			default: out = `state0;
		endcase
	end

	DFF state_reg_0(.clk(clock), .d(next[0]), .q(present[0]));
	DFF state_reg_1(.clk(clock), .d(next[1]), .q(present[1]));
	DFF state_reg_2(.clk(clock), .d(next[2]), .q(present[2]));
	
endmodule