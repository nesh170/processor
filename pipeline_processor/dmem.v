// ECE350 memory
module dmem (
	address,
	clock,
	data,
	wren,
	q);

	input	[11:0]  address;
	input	  clock;
	input	[31:0]  data;
	input	  wren;
	output	[31:0]  q;
	
	reg [31:0] contents [4095:0];

	// initialize the hexadecimal reads from the vectors.txt file
	initial 
	begin	
		$readmemh("dmem.hex", contents);
		
	end
	assign q = contents[address];
	always @(posedge clock) if(wren) contents[address] = data;
	
//	wire [31:0] sub_wire0;
//	wire [31:0] q = sub_wire0[31:0];
//
//	altsyncram	altsyncram_component (
//				.clocken0 (1'b1),
//				.clock0 (clock),
//				.address_a (address),
//				.q_a (sub_wire0),
//				.aclr0 (1'b0),
//				.aclr1 (1'b0),
//				.address_b (1'b1),
//				.addressstall_a (1'b0),
//				.addressstall_b (1'b0),
//				.byteena_a (1'b1),
//				.byteena_b (1'b1),
//				.clock1 (1'b1),
//				.clocken1 (1'b1),
//				.clocken2 (1'b1),
//				.clocken3 (1'b1),
//				.data_a (data),
//				.data_b (1'b1),
//				.eccstatus (),
//				.q_b (),
//				.rden_a (1'b1),
//				.rden_b (1'b1),
//				.wren_a (wren),
//				.wren_b (1'b0));
//	defparam
//		altsyncram_component.clock_enable_input_a = "BYPASS",
//		altsyncram_component.clock_enable_output_a = "BYPASS",
//		altsyncram_component.init_file = "dmem.mif",
//		altsyncram_component.intended_device_family = "Cyclone IV E",
//		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
//		altsyncram_component.lpm_type = "altsyncram",
//		altsyncram_component.numwords_a = 4096,
//		altsyncram_component.operation_mode = "SINGLE_PORT",
//		altsyncram_component.outdata_aclr_a = "NONE",
//		altsyncram_component.outdata_reg_a = "UNREGISTERED",
//		altsyncram_component.widthad_a = 12,
//		altsyncram_component.width_a = 32,
//		altsyncram_component.width_byteena_a = 1;
	
endmodule