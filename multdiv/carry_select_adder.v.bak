module carry_select_Adder(in_A, in_B, out, carry_in, carry_out);
	input[31:0] in_A,in_B;
	input carry_in;
	output carry_out;
	output[31:0] out;
	
	wire carry_outWireToMux;
	wire carry_outWire[1:0];
	wire[31:0] sum1,sum2;
	wire[7:0] carry_out_of_Gate;
	
	adder_4bit adder_1v4(in_A[3:0],in_B[3:0],carry_in,out[3:0],carry_out_of_Gate[0]);
	
	genvar index,index_1;
	generate
	for(index=1;index <=7; index = index+1) begin:loop_adder
		wire[1:0] c_out;
		wire[3:0] out_0;
		wire[3:0] out_1;
		adder_4bit adder_0(in_A[((index*4)+3):index*4],in_B[((index*4)+3):index*4],1'b0,out_0,c_out[0]);
		adder_4bit adder_1(in_A[((index*4)+3):index*4],in_B[((index*4)+3):index*4],1'b1,out_1,c_out[1]);
		for(index_1=0; index_1<4; index_1 = index_1 + 1) begin:loop_mux
			assign out[index*4 + index_1] = (~carry_out_of_Gate[index-1]) ? out_0[index_1] : 1'bZ;
			assign out[index*4 + index_1] = (carry_out_of_Gate[index-1]) ? out_1[index_1] : 1'bZ;
		end
		assign carry_out_of_Gate[index] = (carry_out_of_Gate[index-1]) ? c_out[1] : 1'bZ;
		assign carry_out_of_Gate[index] = (~carry_out_of_Gate[index-1]) ? c_out[0] : 1'bZ;
	end
	endgenerate
	
	assign carry_out = carry_out_of_Gate[7];

endmodule

module adder_4bit(in_A,in_B,carry_in,out, carry_out);
	input[3:0] in_A, in_B; 
	input carry_in;
	output[3:0] out;
	output carry_out;
	wire [2:0] carry_out_wire;
	
	adder_1bit adder1(in_A[0],in_B[0],carry_in,out[0],carry_out_wire[0]);
	adder_1bit adder2(in_A[1],in_B[1],carry_out_wire[0],out[1],carry_out_wire[1]);
	adder_1bit adder3(in_A[2],in_B[2],carry_out_wire[1],out[2],carry_out_wire[2]);
	adder_1bit adder4(in_A[3],in_B[3],carry_out_wire[2],out[3],carry_out);
	
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

