module latch_350(wren_signal,input_A,input_B,program_counter,instruction,clock,output_A,output_B,output_PC,output_ins);
	input[31:0] input_A,input_B,program_counter,instruction;
	input clock,wren_signal;
	output[31:0] output_A,output_B,output_PC,output_ins;
	
	/**
	This is the latch, it takes in 2 inputs and a program counter and the instruction and puts it in a register.
	The register always has to have write_enable to be high and reset to be low since the latch just passe the value.
	
	This latch can be used for all the stages, assert 0 for when it is not in use.
	**/
	
	
	register register_A(input_A,output_A,wren_signal,1'b0,clock);
	register register_B(input_B,output_B,wren_signal,1'b0,clock);
	register register_PC(program_counter,output_PC,wren_signal,1'b0,clock); //always return the lower 12 bits for this project
	register register_instruction(instruction,output_ins,wren_signal,1'b0,clock);
endmodule