module skeleton(	inclock, resetn, ps2_clock, ps2_data, debug_word, debug_addr, leds, 
					lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon, 	
					seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8,
					VGA_B,
					VGA_BLANK_N,
					VGA_CLK,
					VGA_G,
					VGA_HS,
					VGA_R,
					VGA_SYNC_N,
					VGA_VS);

	input 			inclock, resetn;
	inout 			ps2_data, ps2_clock;
	
	output 			lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon;
	output 	[7:0] 	leds, lcd_data;
	output 	[6:0] 	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	output 	[31:0] 	debug_word;
	output  [11:0]  debug_addr;
	
	/////// VGA /////////
	output		   [7:0]		VGA_B;
	output		        		VGA_BLANK_N;
	output		        		VGA_CLK;
	output		   [7:0]		VGA_G;
	output	          		VGA_HS;
	output	      [7:0]		VGA_R;
	output	         		VGA_SYNC_N;
	output	          		VGA_VS;
	
	wire			clock;
	wire			lcd_write_en;
	wire 	[31:0]	lcd_write_data;
	wire	[7:0]	ps2_key_data;
	wire			ps2_key_pressed;
	wire	[7:0]	ps2_out;	

	
	// clock divider (by 5, i.e., 10 MHz)
	//pll div(inclock,clock);
	
	// UNCOMMENT FOLLOWING LINE AND COMMENT ABOVE LINE TO RUN AT 50 MHz
	assign clock = inclock;
	
	// your processor
	wire vga_wren_enable;
	wire[31:0] output_from_register;
	wire[18:0] vga_data_addr;
	wire[7:0] vga_data_write;
	processor myprocessor(.clock(clock), .reset(~resetn), .ps2_key_pressed(ps2_key_pressed), .ps2_out(ps2_out),
	.output_reg(output_from_register),
	.lcd_write(lcd_write_en), .lcd_data(lcd_write_data), .debug_data(debug_word), .debug_addr(debug_addr),
	.vga_wren_enable(vga_wren_enable),.vga_data_addr(vga_data_addr),.vga_data_write(vga_data_write));
	
	
	//VGA Controller
	vga_abstract vga_controller(.write_clock(~clock),.CLOCK_50(clock),
	.vga_data_write(vga_data_write),.vga_data_addr(vga_data_addr),.vga_wren_enable(vga_wren_enable),
	.VGA_B(VGA_B),
	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_CLK(VGA_CLK),
	.VGA_G(VGA_G),
	.VGA_HS(VGA_HS),
	.VGA_R(VGA_R),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_VS(VGA_VS));

	
	// keyboard controller
	PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);
	
	// lcd controller
	lcd mylcd(clock, ~resetn, lcd_write_en, lcd_write_data[7:0], lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon);
	
	// HEXADECIMAL DISPLAY FOR TIME
	Hexadecimal_To_Seven_Segment hex1(output_from_register[3:0], seg1);
	Hexadecimal_To_Seven_Segment hex2(output_from_register[7:4], seg2);
	Hexadecimal_To_Seven_Segment hex3(output_from_register[11:8], seg3);
	Hexadecimal_To_Seven_Segment hex4(output_from_register[15:12], seg4);
	Hexadecimal_To_Seven_Segment hex5(output_from_register[19:16], seg5);
	Hexadecimal_To_Seven_Segment hex6(output_from_register[23:20], seg6);
	Hexadecimal_To_Seven_Segment hex7(output_from_register[27:24], seg7);
	Hexadecimal_To_Seven_Segment hex8(output_from_register[31:28], seg8);
	
	// some LEDs that you could use for debugging if you wanted
	assign leds = output_from_register[7:0];
	
endmodule
