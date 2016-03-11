module align_divider(dividend,divisor,shifted_divisor);
	input[31:0] dividend,divisor;
	output[31:0] shifted_divisor;
	
	
	/*
	This shifts the divisor until the 1 is the first index
	*/
	wire[31:0] divisor_shift_1;
	wire[31:0] temp_shift_divisor[31:0];
	assign temp_shift_divisor[0] = divisor;
	genvar shift_index;
	generate
	for(shift_index=0;shift_index<31;shift_index=shift_index+1) begin:shift_dividend_loop
		assign temp_shift_divisor[shift_index+1] = (temp_shift_divisor[shift_index][31]) ? temp_shift_divisor[shift_index] : (temp_shift_divisor[shift_index]<< 1);
	end
	endgenerate
	assign divisor_shift_1 = temp_shift_divisor[31];
	
	
	
	/*
	Shifts the divisor until it aligns with the dividend
	*/
	wire[31:0] prev;
	wire[31:0] temp_shifts[31:0];
	assign prev[31] = 0;
	assign temp_shifts[31] = divisor_shift_1;
	genvar index;
	generate
	for(index=31; index>=1; index=index-1) begin:loop_1
		wire next_shift;
		assign next_shift = temp_shifts[index][index] & dividend[index];
		assign prev[index-1] = next_shift | prev[index];
		assign temp_shifts[index-1] = (~next_shift & ~prev[index]) ? (temp_shifts[index] >> 1) : temp_shifts[index];
	end
	endgenerate
	
	assign shifted_divisor =  temp_shifts[0];
	
endmodule