module control_execute(instruction,ALU_opcode,ctrl_shamt,immediate_value,i_signal);
	input[31:0] instruction;
	output[4:0] ALU_opcode,ctrl_shamt;
	output[31:0] immediate_value;
	output i_signal;
	
	//optaining the opcode and putting them in individual wires;
	wire A,B,C,D,E;
	assign A = instruction[31];
	assign B = instruction[30];
	assign C = instruction[29];
	assign D = instruction[28];
	assign E = instruction[27];
	
	wire addi_operation,subi_operation;
	assign addi_operation = (~A&~B&C&~D&E) | (~A&~B&C&D&E) | (~A&B&~C&~D&~E);
	assign subi_operation = (~A&~B&~C&D&~E) | (~A&~B&C&D&~E);
	
	assign i_signal = addi_operation; //signal to pick up choose immediate bits over register output
	
	assign ALU_opcode = (addi_operation&~subi_operation) ? 5'b00000 : 5'bZ; //addi,sw,lw
	assign ALU_opcode = (subi_operation&~addi_operation) ? 5'b00001 : 5'bZ; //for branching
	assign ALU_opcode = (~addi_operation&~subi_operation) ? instruction[6:2] : 5'bZ; //regular operations
	assign ALU_opcode = (addi_operation&subi_operation) ? 5'b0 : 5'bZ; //handle this case just for quartus to not get angry. Don't care case!!
	
	
	assign ctrl_shamt = instruction[11:7];
	assign immediate_value[16:0] = instruction[16:0];
	assign immediate_value[31:17] = 15'b0;
	
endmodule