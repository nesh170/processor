module processor(clock, reset, ps2_key_pressed, ps2_out, lcd_write, lcd_data, debug_data, debug_addr,debug_out,ir_out);

	input 			clock, reset, ps2_key_pressed;
	input 	[7:0]	ps2_out;
	
	output 			lcd_write;
	output 	[31:0] 	lcd_data;
	
	output[31:0] debug_out,ir_out;
	
	// GRADER OUTPUTS - YOU MUST CONNECT TO YOUR DMEM
	output 	[31:0] 	debug_data;
	output	[11:0]	debug_addr;
	
	
	//////////////////////////////////////
	////// THIS IS REQUIRED FOR GRADING
	// CHANGE THIS TO ASSIGN YOUR DMEM WRITE ADDRESS ALSO TO debug_addr
	assign debug_addr = (12'b000000000001);
	// CHANGE THIS TO ASSIGN YOUR DMEM DATA INPUT (TO BE WRITTEN) ALSO TO debug_data
	assign debug_data = (12'b000000000001);
	////////////////////////////////////////////////////////////
	
	//FETCH STAGE
	//PROGRAM COUNTER
	wire[31:0] pc_input,pc_output;
	register program_counter(.bitsIn(pc_input), .bitsOut(pc_output), .writeEnable(1'b1), .reset(reset), .clk(clock));
	
	//IMEM
	wire[31:0] imem_output;	
	imem myimem(.address(pc_output[11:0]),.clken(1'b1),.clock(~clock),.q(imem_output)); //read on negative edge
	
	//NEXT PROGRAM COUNTER calculations
	wire[31:0] next_pc_output;
	carry_select_adder pc_adder(.in_A(pc_output), .in_B(32'b0), .out(next_pc_output), .carry_in(1'b1));
	
	assign pc_input = next_pc_output; //remove THIS IT IS WRONG BROSKI
	
	//FETCH_DECODE LATCH
	wire[31:0] fd_pc_output,fd_ir_output;
	latch_350 fetch_decode_latch(.program_counter(next_pc_output),.instruction(imem_output),.clock(clock),.output_PC(fd_pc_output),.output_ins(fd_ir_output));
	assign ir_out = fd_ir_output;
	//DECODE STAGE
	//DECODE controller
	wire[4:0] read_reg_A,read_reg_B;
	control_decode decode_controller(.instruction(fd_ir_output),.read_reg_s1(read_reg_A),.read_reg_s2(read_reg_B));
	assign debug_out[4:0] = read_reg_A;
	assign debug_out[31:27] = read_reg_B;
	assign debug_out[26:5] = 0;
	
	
	
	
	
	
	
		
	// You'll need to change where the dmem and imem read and write...
	dmem mydmem(	.address	(debug_addr),
					.clock		(clock),
					.data		(debug_data),
					.wren		(1'b1) //,	//need to fix this!
					//.q			(wherever_you_want) // change where output q goes...
	);
	
endmodule
