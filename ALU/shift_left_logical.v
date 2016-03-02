module shift_left_logical(in, ctrl_ShiftAmt, out);
	input[31:0] in;
	input[4:0] ctrl_ShiftAmt;
	output[31:0] out;
	
	
	
	//shifts by 2^0=1
	wire[31:0] output_connector_0;
	genvar index_0;
	generate
	for(index_0=31; index_0>0; index_0=index_0-1) begin:loopPower0_0
		assign output_connector_0[index_0] = ctrl_ShiftAmt[0] ? in[index_0-1] : in[index_0];
	end
		assign output_connector_0[0] = ctrl_ShiftAmt[0] ? 1'b0 : in[0];
	endgenerate
	
	//shifts by 2^1=2
	wire[31:0] output_connector_1;
	genvar index_1;
	generate
	for(index_1=31; index_1>1; index_1=index_1-1) begin:loopPower1_0
		assign output_connector_1[index_1] = ctrl_ShiftAmt[1] ? output_connector_0[index_1-2] : output_connector_0[index_1];
	end
	for(index_1=1; index_1>=0; index_1=index_1-1) begin:loopPower1_1
		assign output_connector_1[index_1] = ctrl_ShiftAmt[1] ? 1'b0 : output_connector_0[index_1];
	end
	endgenerate

//	//shifts by 2^2=4
	wire[31:0] output_connector_2;
	genvar index_2;
	generate
	for(index_2=31; index_2>3; index_2=index_2-1) begin:loopPower2_0
		assign output_connector_2[index_2] = ctrl_ShiftAmt[2] ? output_connector_1[index_2-4] : output_connector_1[index_2];
	end
	for(index_2=3; index_2>=0; index_2=index_2-1) begin:loopPower2_1
		assign output_connector_2[index_2] = ctrl_ShiftAmt[2] ? 1'b0 : output_connector_1[index_2];
	end
	endgenerate

//	//shifts by 2^3=8
	wire[31:0] output_connector_3;
	genvar index_3;
	generate
	for(index_3=31; index_3>7; index_3=index_3-1) begin:loopPower3_0
		assign output_connector_3[index_3] = ctrl_ShiftAmt[3] ? output_connector_2[index_3-8] : output_connector_2[index_3];
	end
	for(index_3=7; index_3>=0; index_3=index_3-1) begin:loopPower3_1
		assign output_connector_3[index_3] = ctrl_ShiftAmt[3] ? 1'b0 : output_connector_2[index_3];
	end
	endgenerate
	
	//shifts by 2^4=16
	wire[31:0] output_connector_4;
	genvar index_4;
	generate
	for(index_4=31; index_4>15; index_4=index_4-1) begin:loopPower4_0
		assign output_connector_4[index_4] = ctrl_ShiftAmt[4] ? output_connector_3[index_4-16] : output_connector_3[index_4];
	end
	for(index_4=15; index_4>=0; index_4=index_4-1) begin:loopPower4_1
		assign output_connector_4[index_4] = ctrl_ShiftAmt[4] ? 1'b0 : output_connector_3[index_4];
	end
	endgenerate

	
	assign out = output_connector_4;
endmodule

