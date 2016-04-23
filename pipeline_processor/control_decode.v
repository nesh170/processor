module control_decode(instruction,read_reg_s1,read_reg_s2,bne_signal,blt_signal,beq_signal,branch_N,bex_signal,setx_signal);
	input[31:0] instruction;
	output[4:0] read_reg_s1,read_reg_s2;
	output bne_signal,blt_signal,beq_signal,bex_signal,setx_signal;
	output[31:0] branch_N;
	//optaining the opcode and putting them in individual wires;
	wire A,B,C,D,E;
	assign A = instruction[31];
	assign B = instruction[30];
	assign C = instruction[29];
	assign D = instruction[28];
	assign E = instruction[27];
	
	//Signal to decide whether s2 should be read from rd(if true) or rt
	wire rd_rt_signal;
	assign rd_rt_signal = (~A&~B&~C&D&~E) | (~A&~B&C&~D&~E) | (~A&~B&C&D&~E) | (~A&~B&C&D&E) | (A&~B&~C&~D&~E) | (A&~B&~C&~D&E);
	
	
	assign read_reg_s1 = instruction[21:17];
	assign read_reg_s2 = (rd_rt_signal) ? instruction[26:22] : instruction[16:12];
	
	//BRANCHing Signal
	assign bne_signal = (~A&~B&~C&D&~E);
	assign blt_signal = (~A&~B&C&D&~E);
	assign beq_signal = (A&~B&~C&~D&~E);
	assign bex_signal = (A&~B&C&D&~E);

	//SET STATUS signal
	assign setx_signal = (A&~B&C&~D&E);
	
	wire[31:0] temp_branch_add,temp_status_branch;
	assign temp_branch_add[16:0] = instruction[16:0];
	genvar i;
	generate
	for(i=17;i<=31;i=i+1) begin:loop
		assign temp_branch_add[i] = instruction[16];
	end
	endgenerate

	assign temp_status_branch[26:0] = instruction[26:0];
	genvar k;
	generate
	for(k=27;k<=31;k=k+1) begin:loop_status
		assign temp_status_branch[k] = instruction[26];
	end
	endgenerate

	assign branch_N = ((bne_signal|blt_signal|beq_signal)&~bex_signal) ? temp_branch_add : 32'bZ;
	assign branch_N = (~(bne_signal|blt_signal|beq_signal)&bex_signal) ? temp_status_branch : 32'bZ;
endmodule