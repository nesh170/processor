module regfile(clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB, output_register);
   input clock, ctrl_writeEnable, ctrl_reset;
   input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
   input [31:0] data_writeReg;
   output [31:0] data_readRegA, data_readRegB,output_register;

	wire [31:0]ctrl_writeWhichRegister;
	wire [31:0] selectDecoderA;
	wire [31:0] selectDecoderB;
	
	/*
	Decode 5 bits to 32 bits to access each register; 0001 -> 1 register, 1111 -> 32 register
	*/
	decoder5to32 decoderForWrite(ctrl_writeReg,ctrl_writeWhichRegister);
	decoder5to32 decoderForReadA(ctrl_readRegA,selectDecoderA);
	decoder5to32 decoderForReadB(ctrl_readRegB,selectDecoderB);
	
	//ZERO case, register zero has to be zero
	wire[31:0] data_Out_zero;
	wire [31:0] data_zero;
	register register_zero(data_writeReg,data_Out_zero,ctrl_writeEnable & ctrl_writeWhichRegister[0],ctrl_reset,clock);  
	assign data_readRegA = selectDecoderA[0] ? 32'b0 : 32'bZ; //tri state buffer to decide which output to display
	assign data_readRegB = selectDecoderB[0] ? 32'b0 : 32'bZ; //tri state buffer to decide which output to display
	
	wire[31:0] out_array [31:0];
	assign out_array[0] = data_Out_zero;
	genvar i;
	generate 
		for(i=1;i<=31;i=i+1) begin: registerGenerator
			wire [31:0] data_Out;
			assign out_array[i] = data_Out;
			register regis(data_writeReg,data_Out,ctrl_writeEnable & ctrl_writeWhichRegister[i],ctrl_reset,clock); //initializing the register 
			assign data_readRegA = selectDecoderA[i] ? data_Out : 32'bZ; //tri state buffer to decide which output to display
			assign data_readRegB = selectDecoderB[i] ? data_Out : 32'bZ; //tri state buffer to decide which output to display
		end
	endgenerate
	
	assign output_register = out_array[27]; //CHANGE THE VALUE HERE TO DETERMINE WHICH REGISTER YOU WANT THE DATA FROM

endmodule


module decoder5to32(in,out);
	input[4:0] in;
	output[31:0] out;
	
	assign out = (1 << in);
endmodule

module register(bitsIn, bitsOut, writeEnable, reset, clk);
	input [31:0] bitsIn;
	input writeEnable, reset, clk;
	output [31:0] bitsOut;
	
	genvar index;
	generate
		for(index=0; index<=31; index=index+1) begin: loop1
			DFFE dflipflop(.d(bitsIn[index]),.clk(clk),.clrn(~reset),.prn(1'b1),.ena(writeEnable),.q(bitsOut[index]));
		end
	endgenerate
	
endmodule


