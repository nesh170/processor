module control_execute(instruction,ALU_opcode,ctrl_shamt,immediate_value,i_signal,j_signal,jr_signal,jump_immediate_value,pc,tty_signal,status,setx_signal,mult_signal,div_signal);
	input[31:0] instruction,pc,status;
	output[4:0] ALU_opcode,ctrl_shamt;
	output[31:0] immediate_value,jump_immediate_value;
	output i_signal,j_signal,jr_signal,tty_signal,setx_signal;
	output mult_signal,div_signal;
	
	//optaining the opcode and putting them in individual wires;
	wire A,B,C,D,E;
	
	
	assign A = instruction[31];
	assign B = instruction[30];
	assign C = instruction[29];
	assign D = instruction[28];
	assign E = instruction[27];
	
	wire addi_operation,subi_operation;
	assign addi_operation = (~A&~B&C&~D&E) | (~A&~B&C&D&E) | (~A&B&~C&~D&~E) | (A&~B&~C&~D&E) | (A&B&C&D&~E);
	assign subi_operation = (~A&~B&~C&D&~E) | (~A&~B&C&D&~E);
	
	//HANDLING BEX
	wire bex_signal;
	assign bex_signal = (A&~B&C&D&~E) & (|status) & (~status[31]);


	assign i_signal = addi_operation; //signal to pick up choose immediate bits over register output
	assign j_signal = (~A&~B&~C&~D&E) | (~A&~B&~C&D&E) | (~A&~B&C&~D&~E) | bex_signal; //this is 3 jumps
	assign jr_signal = (~A&~B&C&~D&~E);
	assign tty_signal = (A&B&C&D&~E); //This is for the keyboard input
	assign ALU_opcode = (addi_operation&~subi_operation) ? 5'b00000 : 5'bZ; //addi,sw,lw
	assign ALU_opcode = (subi_operation&~addi_operation) ? 5'b00001 : 5'bZ; //for branching
	assign ALU_opcode = (~addi_operation&~subi_operation) ? instruction[6:2] : 5'bZ; //regular operations
	assign ALU_opcode = (addi_operation&subi_operation) ? 5'b0 : 5'bZ; //handle this case just for quartus to not get angry. Don't care case!!
	assign setx_signal = (A&~B&C&~D&E);
	
	assign ctrl_shamt = instruction[11:7];
	assign immediate_value[16:0] = instruction[16:0];
	
	//assign div signal and mult signal
	wire runALU;
	assign runALU=(~A&~B&~C&~D&~E);
	assign mult_signal = ~instruction[6]&~instruction[5]&instruction[4]&instruction[3]&~instruction[2]&runALU;
	assign div_signal =  ~instruction[6]&~instruction[5]&instruction[4]&instruction[3]&instruction[2]&runALU;


	//Sign Extending
	genvar i;
	generate
	for(i=17;i<=31;i=i+1) begin:loop
		assign immediate_value[i] = instruction[16];
	end
	endgenerate
	
	assign jump_immediate_value[26:0] = instruction[26:0];
	assign jump_immediate_value[31:27] = pc[31:27];
	
	
	
endmodule