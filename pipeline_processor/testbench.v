`timescale 1 ns / 100 ps
module testbench();
	///////////////////////////////////////////////////////////////////////////
	parameter clock_halfperiod = 25;	// clock half period in ns

	///////////////////////////////////////////////////////////////////////////
	// Tracking the number of errors
	reg clock, ctrl_reset;	// standard signals- required even if DUT doesn't use them
	integer ticks; // ticks are HALF clock ticks... two ticks equal a clock period
	
	reg 			inclock, resetn;	
	
	wire 			lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon;
	wire 	[7:0] 	leds, lcd_data;
	wire 	[6:0] 	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	wire 	[31:0] 	debug_word;
	wire  [11:0]  debug_addr;
	
	// instantiate the skeleton
	skeleton		U1 (clock, resetn, /*ps2_clock, ps2_data,*/ debug_word, debug_addr, leds, 
					lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon, 	
					seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8);
	
		
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// setting the initial values of all the reg
	initial
	begin		
		clock = 1'b0;	// at time 0
		ticks = 0;		
		
		$display(ticks, "\n\n\n << Starting simulation (manually stop)>>\n\n");
		
		$monitor("%t: addr=%h value=%h", $realtime, debug_addr, debug_word);
		
		#20;
	end
	
	// Clock generator
	always
	begin
 		#clock_halfperiod     clock = ~clock;    // toggle
		ticks = ticks + 1;
	end
	 

endmodule







