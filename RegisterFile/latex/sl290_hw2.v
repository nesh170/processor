module sl290_hw2(clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB);
	input clock, ctrl_writeEnable, ctrl_reset;
   input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
   input [31:0] data_writeReg;
   output [31:0] data_readRegA, data_readRegB;
	
	regfile register(clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB);
	
endmodule

module regfile(clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB);
   input clock, ctrl_writeEnable, ctrl_reset;
   input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
   input [31:0] data_writeReg;
   output [31:0] data_readRegA, data_readRegB;

	wire [31:0]ctrl_writeWhichRegister;
	wire [31:0] selectDecoderA;
	wire [31:0] selectDecoderB;
	
	/*
	Decode 5 bits to 32 bits to access each register; 0001 -> 1 register, 1111 -> 32 register
	*/
	decoder5to32 decoderForWrite(ctrl_writeReg,ctrl_writeWhichRegister);
	decoder5to32 decoderForReadA(ctrl_readRegA,selectDecoderA);
	decoder5to32 decoderForReadB(ctrl_readRegB,selectDecoderB);
	
	genvar i;
	generate 
		for(i=0;i<=31;i=i+1) begin: registerGenerator
			wire [31:0] data_Out;
			register regis(data_writeReg,data_Out,ctrl_writeEnable & ctrl_writeWhichRegister[i],ctrl_reset,clock); //initializing the register 
			assign data_readRegA = selectDecoderA[i] ? data_Out : 32'bZ; //tri state buffer to decide which output to display
			assign data_readRegB = selectDecoderB[i] ? data_Out : 32'bZ; //tri state buffer to decide which output to display
		end
	endgenerate

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


