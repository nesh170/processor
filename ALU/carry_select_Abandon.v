

module carry_select_Adder(in_A, in_B, out, carry_in, carry_out);
	input[31:0] in_A,in_B;
	input carry_in;
	output carry_out;
	output[31:0] out;
	
	wire carry_outWireToMux;
	wire carry_outWire[1:0];
	wire[15:0] sum1,sum2;
	
	
	carry_select_Adder_16bit firstAdderOutput(in_A[15:0],in_B[15:0],carry_in,out[15:0],carry_outWireToMux);

	carry_select_Adder_16bit secondAdderOutput(in_A[31:16],in_B[31:16], 1'b0, sum1,carry_outWire[0]); 
	carry_select_Adder_16bit thirdAdderOutput(in_A[31:16],in_B[31:16], 1'b1, sum2, carry_outWire[1]); 
	
	assign carry_out = carry_outWireToMux ? carry_outWire[1] : carry_outWire[0];
	assign out[31:16] = carry_outWireToMux ? sum2 : sum1;
endmodule

module carry_select_Adder_16bit(in_A, in_B, carry_in, out, carry_out);
	input[15:0] in_A,in_B;
	input carry_in; 
	output carry_out;
	output[15:0] out;
	
	wire carry_outWireToMux;
	wire carry_outWire[1:0];
	wire[7:0] sum1,sum2;
	
	
	carry_select_Adder_8bit firstAdderOutput(in_A[7:0],in_B[7:0],carry_in,out[7:0],carry_outWireToMux);
	
	carry_select_Adder_8bit secondAdderOutput(in_A[15:8],in_B[15:8], 1'b0, sum1,carry_outWire[0]); 
	carry_select_Adder_8bit thirdAdderOutput(in_A[15:8],in_B[15:8], 1'b1, sum2, carry_outWire[1]); 
	
	assign carry_out = carry_outWireToMux ? carry_outWire[1] : carry_outWire[0];
	assign out[15:8] = carry_outWireToMux ? sum2 : sum1;
endmodule


module carry_select_Adder_8bit(in_A, in_B, carry_in, out, carry_out);
	input[7:0] in_A,in_B;
	input carry_in; 
	output carry_out;
	output[7:0] out;
	
	wire carry_outWireToMux;
	wire carry_outWire[1:0];
	wire[3:0] sum1,sum2;
	
	
	carry_select_Adder_4bit firstAdderOutput(in_A[3:0],in_B[3:0],carry_in,out[3:0],carry_outWireToMux);
	
	carry_select_Adder_4bit secondAdderOutput(in_A[7:4],in_B[7:4], 1'b0, sum1,carry_outWire[0]); 
	carry_select_Adder_4bit thirdAdderOutput(in_A[7:4],in_B[7:4], 1'b1, sum2, carry_outWire[1]); 
	
	assign carry_out = carry_outWireToMux ? carry_outWire[1] : carry_outWire[0];
	assign out[7:4] = carry_outWireToMux ? sum2 : sum1;
endmodule


module carry_select_Adder_4bit(in_A, in_B, carry_in, out, carry_out);
	input[3:0] in_A,in_B;
	input carry_in; 
	output carry_out;
	output[3:0] out;
	
	wire carry_outWireToMux;
	wire carry_outWire[1:0];
	wire[1:0] sum1,sum2;
	
	
	carry_select_Adder_2bit firstAdderOutput(in_A[1:0],in_B[1:0],carry_in,out[1:0],carry_outWireToMux);
	
	carry_select_Adder_2bit secondAdderOutput(in_A[3:2],in_B[3:2], 1'b0, sum1,carry_outWire[0]); 
	carry_select_Adder_2bit thirdAdderOutput(in_A[3:2],in_B[3:2], 1'b1, sum2, carry_outWire[1]); 
	
	assign carry_out = carry_outWireToMux ? carry_outWire[1] : carry_outWire[0];
	assign out[3:2] = carry_outWireToMux ? sum2 : sum1;
endmodule

module carry_select_Adder_2bit(in_A, in_B, carry_in, out, carry_out);
	input[1:0] in_A,in_B;
	input carry_in; 
	output carry_out;
	output[1:0] out;
	
	wire carry_outWireToMux;
	wire carry_outWire[1:0];
	wire sum1,sum2;
	
	
	adder_1bit firstAdderOutput(in_A[0],in_B[0],carry_in,out[0],carry_outWireToMux);
	
	adder_1bit secondAdderOutput(in_A[1],in_B[1],1'b0,sum1,carry_outWire[0]); 
	adder_1bit thirdAdderOutput(in_A[1],in_B[1],1'b1,sum2,carry_outWire[1]); 
	
	assign carry_out = carry_outWireToMux ? carry_outWire[1] : carry_outWire[0];
	assign out[1] = carry_outWireToMux ? sum2 : sum1;
	
endmodule

module adder_1bit(in_A, in_B , carry_in, out, carry_out);
	input in_A, in_B, carry_in;
	output out,carry_out;
	
	wire xorGateOutput1,cOutProcess1,cOutProcess2;
	
	xor xorGate1(xorGateOutput1, in_A, in_B);
	xor xorGate2(out,carry_in,xorGateOutput1);
	and ANDGate1(cOutProcess1,in_A,in_B);
	and ANDGate2(cOutProcess2,carry_in,xorGateOutput1);
	or ORGate(carry_out,cOutProcess1,cOutProcess2);
	
endmodule



