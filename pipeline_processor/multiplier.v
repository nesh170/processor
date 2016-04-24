module multiplier(multiplicand, multiplier, data_inputRDY, result, data_resultRDY, data_exception);
	input[31:0] multiplicand;
	input[15:0] multiplier;
	output data_inputRDY, data_resultRDY, data_exception;
	wire[16:0] modifiedMultiplier;
	wire[31:0] initialSum, w1, w2, w3, w4, w5, w6, w7;
	wire[31:0] w8, w10, w12, w14, w16, w18, w20;
	wire[16:0] w9, w11, w13, w15, w17, w19, w21;
	output[31:0] result;
	assign data_inputRDY = 1'b1;
	
	assign data_resultRDY = 1'b1;
	assign initialSum = 32'b0;
	wire outputMSB;
	assign outputMSB = multiplicand[31] ^ multiplier[15];
	//multiply least significant 16 bits of data_operandA, by data_operandB
	assign modifiedMultiplier[0] = 1'b0;
	assign modifiedMultiplier[16:1] = multiplier;
	//wire[2:0] iterOne, iterTwo, iterThree, iterFour, iterFive, iterSix, iterSeven, iterEight;
	//assign iterOne = modifiedMultiplier[2:0];
	//assign iterTwo = modifiedMultiplier[4:2];
	//assign iterThree = modifiedMultiplier[6:4];
	//assign iterFour = modifiedMultiplier[8:6];
	//assign iterFive = modifiedMultiplier[10:8];
	//assign iterSix = modifiedMultiplier[12:10];
	//assign iterSeven = modifiedMultiplier[14:12];
	//assign iterEight = modifiedMultiplier[16:14];
	//assign firstIterationMultiplier = multiplier << 1;
	//repeat algorithm 8 times, pass multiplicand, multiplier to module that then outputs the result
	boothAlgorithm one(multiplicand, modifiedMultiplier, w1, initialSum); //w1 holds new sum
	assign w8 = multiplicand << 2;
	assign w9 = modifiedMultiplier >> 2;
	boothAlgorithm two(w8, w9, w2, w1); //new sum in w2
	assign w10 = w8 << 2;
	assign w11 = w9 >> 2;
	boothAlgorithm three(w10, w11, w3, w2);
	assign w12 = w10 << 2;
	assign w13 = w11 >> 2;
	boothAlgorithm four(w12, w13, w4, w3);
	assign w14 = w12 << 2;
	assign w15 = w13 >> 2;
	boothAlgorithm five(w14, w15, w5, w4);
	assign w16 = w14 << 2;
	assign w17 = w15 >> 2;
	boothAlgorithm six(w16, w17, w6, w5);
	assign w18 = w16 << 2;
	assign w19 = w17 >> 2;
	boothAlgorithm seven(w18, w19, w7, w6);
	assign w20 = w18 << 2;
	assign w21 = w19 >> 2;
	boothAlgorithm eight(w20, w21, result, w7);
	wire notEqual;
	//if MSB of result not equal to theoretical MSB (which is outputMSB, then exception thrown)
	assign data_exception = outputMSB ^ result[31];
	//assign data_inputRDY = 1'b1;
endmodule	




module boothAlgorithm(multiplicand, multiplier, operationResult, prevSum);
	input[31:0] multiplicand;
	input[16:0]multiplier;
	output[31:0] operationResult;
	input[31:0] prevSum;
	wire[2:0] multiplierBits;
	assign multiplierBits = multiplier[2:0];
	wire[7:0] decodedOutput;
	threeToEightDecoder decode(multiplierBits, decodedOutput);
	//wire[31:0] operationResu
	wire[31:0] w0, w1, w2, w3, w4, w5, w6, w7, shiftedMultiplicand, w16, result;
	wire w8, w9, w10, w11, w12, w13, w14, w15; //cout for addition/subtraction
	assign shiftedMultiplicand = multiplicand << 1;
	//000 do nothing - output 0
	assign w16 = 32'b0;
	thirtyTwoBitCarrySelectAdder addZero(.a(prevSum), .b(w16), .cin(1'b0), .cout(w8), .sum(w0));
	triStateBuffer32Bit triZero(w0, decodedOutput[0], operationResult);
	//001 add multiplicand
	thirtyTwoBitCarrySelectAdder add(prevSum, multiplicand, 1'b0, w9, w1);
	triStateBuffer32Bit triOne(w1, decodedOutput[1], operationResult);
	//010 add multiplicand 
	thirtyTwoBitCarrySelectAdder addAgain(prevSum, multiplicand, 1'b0, w10, w2);
	triStateBuffer32Bit triTwo(w2, decodedOutput[2], operationResult);
	//011 add multiplicand<<1
	thirtyTwoBitCarrySelectAdder addShifted(prevSum, shiftedMultiplicand, 1'b0, w11, w3);
	triStateBuffer32Bit triThree(w3, decodedOutput[3], operationResult);
	//100 subtract multiplicand<<1
	subtract subtractShifted(prevSum, shiftedMultiplicand, 1'b1, w12, w4);
	triStateBuffer32Bit triFour(w4, decodedOutput[4], operationResult);
	//101 subtract multiplicand
	subtract subtractMultiplicand(prevSum, multiplicand, 1'b1, w13, w5);
	triStateBuffer32Bit triFive(w5, decodedOutput[5], operationResult);
	//110 subtract multiplicand
	subtract subtractAgain(prevSum, multiplicand, 1'b1, w14, w6);
	triStateBuffer32Bit triSix(w6, decodedOutput[6], operationResult);
	//111 do nothing
	thirtyTwoBitCarrySelectAdder addZeroAgain(prevSum, 32'b0, 1'b0, w15, w7);
	triStateBuffer32Bit triSeven(w7, decodedOutput[7], operationResult);
	//assign operationResult = result;
	
	//now operation result has the new value to return, the updated sum
endmodule


module triStateBuffer32Bit(in, oe, out);
	input[31:0] in;
	output[31:0] out;
	input oe;
	assign out = oe ? in : 32'bz;

endmodule


/*

this module is used to decode the three bits read in, which will later be used to choose from a series of tri state buffers for each possible output
*/

module threeToEightDecoder(in, out);
	input[2:0] in;
	output[7:0] out;	
	assign out = 1'b1 << in;
endmodule

module thirtyTwoBitCarrySelectAdder(a, b, cin, cout, sum);
	input[31:0] a, b;
	input cin;
	output[31:0] sum;
	output cout;
	
	wire[15:0] alsb, amsb, blsb, bmsb, sumOne, sumTwo;
	wire coutSelector, carryOutOne, carryOutTwo;
	assign alsb = a[15:0];
	assign amsb = a[31:16];
	assign blsb = b[15:0];
	assign bmsb = b[31:16];
	
	sixteenBitCarrySelectAdder adderOne(alsb, blsb, cin, coutSelector, sum[15:0]);
	sixteenBitCarrySelectAdder adderTwo(amsb, bmsb, 1'b0, carryOutOne, sumOne);
	sixteenBitCarrySelectAdder adderThree(amsb, bmsb, 1'b1, carryOutTwo, sumTwo);

	wire[1:0] decodedOutput; //choosing between two things, one sum or other sum; one carry out or other carry out
	decoderOneTwo decoder(coutSelector, decodedOutput);
	twoToOneMux16Bit muxOne(sumOne, sumTwo, coutSelector, sum[31:16]);
	twoToOneMux1Bit muxTwo(carryOutOne, carryOutTwo, coutSelector, cout);
	//select between the two sums
	//triStateBuffer16Bit triOne(sumOne, decodedOutput[0], sum[31:16]);
	//triStateBuffer16Bit triTwo(sumTwo, decodedOutput[1], sum[31:16]);
	//select between two carry out, should correspond to same index as sum
	//triStateBuffer1Bit triThree(carryOutOne, decodedOutput[0], cout);
	//triStateBuffer1Bit triFour(carryOutTwo, decodedOutput[1], cout);
endmodule


module sixteenBitCarrySelectAdder(a, b, cin, cout, sum);
	input[15:0] a, b;
	input cin;
	output[15:0] sum;
	output cout;
	
	wire[7:0] alsb, amsb, blsb, bmsb, sumOne, sumTwo;
	wire coutSelector, carryOutOne, carryOutTwo;
	assign alsb = a[7:0];
	assign amsb = a[15:8];
	assign blsb = b[7:0];
	assign bmsb = b[15:8];
	
	eightBitCarrySelectAdder adderOne(alsb, blsb, cin, coutSelector, sum[7:0]);
	eightBitCarrySelectAdder adderTwo(amsb, bmsb, 1'b0, carryOutOne, sumOne);
	eightBitCarrySelectAdder adderThree(amsb, bmsb, 1'b1, carryOutTwo, sumTwo);

	wire[1:0] decodedOutput; //choosing between two things, one sum or other sum; one carry out or other carry out
	decoderOneTwo decoder(coutSelector, decodedOutput);
	twoToOneMux8Bit muxOne(sumOne, sumTwo, coutSelector, sum[15:8]);
	twoToOneMux1Bit muxTwo(carryOutOne, carryOutTwo, coutSelector, cout);
	//select between the two sums
	//triStateBuffer8Bit triOne(sumOne, decodedOutput[0], sum[15:8]);
	//triStateBuffer8Bit triTwo(sumTwo, decodedOutput[1], sum[15:8]);
	//select between two carry out, should correspond to same index as sum
	//triStateBuffer1Bit triThree(carryOutOne, decodedOutput[0], cout);
	//triStateBuffer1Bit triFour(carryOutTwo, decodedOutput[1], cout);
endmodule


module eightBitCarrySelectAdder(a, b, cin, cout, sum);
	input[7:0] a, b;
	input cin;
	output[7:0] sum;
	output cout;
	
	wire[3:0] alsb, amsb, blsb, bmsb, sumOne, sumTwo;
	wire coutSelector, carryOutOne, carryOutTwo;
	assign alsb = a[3:0];
	assign amsb = a[7:4];
	assign blsb = b[3:0];
	assign bmsb = b[7:4];
	
	fourBitCarrySelectAdder adderOne8(alsb, blsb, cin, coutSelector, sum[3:0]);
	fourBitCarrySelectAdder adderTwo8(amsb, bmsb, 1'b0, carryOutOne, sumOne);
	fourBitCarrySelectAdder adderThree8(amsb, bmsb, 1'b1, carryOutTwo, sumTwo);

	wire[1:0] decodedOutput; //choosing between two things, one sum or other sum; one carry out or other carry out
	decoderOneTwo decoder(coutSelector, decodedOutput);
	twoToOneMux4Bit muxOne(sumOne, sumTwo, coutSelector, sum[7:4]);
	twoToOneMux1Bit muxTwo(carryOutOne, carryOutTwo, coutSelector, cout);
	//select between the two sums
	//triStateBuffer4Bit triOne(sumOne, decodedOutput[0], sum[7:4]);
	//triStateBuffer4Bit triTwo(sumTwo, decodedOutput[1], sum[7:4]);
	//select between two carry out, should correspond to same index as sum
	//triStateBuffer1Bit triThree(carryOutOne, decodedOutput[0], cout);
	//triStateBuffer1Bit triFour(carryOutTwo, decodedOutput[1], cout);
endmodule





module fourBitCarrySelectAdder(a, b, cin, cout, sum);
	input[3:0] a, b;
	input cin;
	output[3:0] sum;
	output cout;
	
	wire[1:0] alsb, amsb, blsb, bmsb, sumOne, sumTwo;
	wire coutSelector, carryOutOne, carryOutTwo;
	assign alsb = a[1:0];
	assign amsb = a[3:2];
	assign blsb = b[1:0];
	assign bmsb = b[3:2];
	
	twoBitCarrySelectAdder adderOne4(alsb, blsb, cin, coutSelector, sum[1:0]);
	twoBitCarrySelectAdder adderTwo4(amsb, bmsb, 1'b0, carryOutOne, sumOne);
	twoBitCarrySelectAdder adderThree4(amsb, bmsb, 1'b1, carryOutTwo, sumTwo);

	wire[1:0] decodedOutput; //choosing between two things, one sum or other sum; one carry out or other carry out
	decoderOneTwo decoder(coutSelector, decodedOutput);
	twoToOneMux2Bit muxOne(sumOne, sumTwo, coutSelector, sum[3:2]);
	twoToOneMux1Bit muxTwo(carryOutOne, carryOutTwo, coutSelector, cout);
	//select between the two sums
	//triStateBuffer2Bit triOne(sumOne, decodedOutput[0], sum[3:2]);
	//triStateBuffer2Bit triTwo(sumTwo, decodedOutput[1], sum[3:2]);
	//select between two carry out, should correspond to same index as sum
	//triStateBuffer1Bit triThree(carryOutOne, decodedOutput[0], cout);
	//triStateBuffer1Bit triFour(carryOutTwo, decodedOutput[1], cout);
endmodule





module twoBitCarrySelectAdder(a, b, cin, cout, sum);
	input[1:0] a, b;
	input cin;
	output[1:0] sum;
	output cout;
	
	wire coutSelector;
	wire sumSelectOne, sumSelectTwo;
	wire carryOutOne, carryOutTwo;
	oneBitAdder adderOne2(a[0], b[0], cin, coutSelector, sum[0]);
	oneBitAdder adderTwo2(a[1], b[1], 1'b0, carryOutOne, sumSelectOne);
	oneBitAdder adderThree2(a[1], b[1], 1'b1, carryOutTwo, sumSelectTwo);
	
	
	//decode carry out bit of first adder to 2 bits to select between the two tri state buffers
	wire[1:0] decodedOutput;
	decoderOneTwo decodeCarryOut(coutSelector, decodedOutput);
	
	
	
	twoToOneMux1Bit firstMux(sumSelectOne, sumSelectTwo, coutSelector, sum[1]);
	twoToOneMux1Bit secondMux(carryOutOne, carryOutTwo, coutSelector, cout);
	
	
	
	
	//tri state buffers to select between the two sums to see which one is correct
	//triStateBuffer1Bit triOne(sumSelectOne, decodedOutput[0], sum[1]);
	//triStateBuffer1Bit triTwo(sumSelectTwo, decodedOutput[1], sum[1]);

	//tri state buffers to select betwen the two carry out bits corresponding to the one chosen above
	//triStateBuffer1Bit triThree(carryOutOne, decodedOutput[0], cout); 
	//triStateBuffer1Bit triFour(carryOutTwo, decodedOutput[1], cout); //, decodedOutput[1]);
	
endmodule

module oneBitAdder(a, b, cin, cout, sum);
	input a, b, cin;
	output cout, sum;
	
	wire w1, w2, w3;
	wire w4, w5, w6, w7;
	wire w8, w9, w10, w11;
	
	not notA(w1, a); 
	not notB(w2, b);
	not notcin(w3, cin);
	
	//get expression for sum
	and andOne(w4, w1, w2, cin);
	and andTwo(w5, w1, b, w3);
	and andThree(w6, a, w2, w3); 
	and andFour(w7, a, b, cin);
	
	or orSum(sum, w4, w5, w6, w7);
	
	
	//get expression for cout
	and andFive(w8, w1, b, cin);
	and andSix(w9, a, w2, cin);
	and andSeven(w10, a, b, w3);
	and andEight(w11, a, b, cin);
	
	
	or orcout(cout, w8, w9, w10, w11);
endmodule




module twoToOneMux16Bit(in0, in1, select, out);
	input[15:0] in1, in0;
	input select;
	output[15:0] out;
	wire[15:0] w0, w1, w2, w3;
	genvar i;
	generate
	for (i = 0; i < 16; i = i+1) begin: loop1
		assign w0[i] = select;
		assign w1[i] = ~w0[i];
		assign w2[i] = in1[i] & w0[i];
		assign w3[i] = in0[i] & w1[i];
		assign out[i] = w2[i] | w3[i];
	end
	endgenerate
endmodule


module twoToOneMux8Bit(in0, in1, select, out);
	input[7:0] in1, in0;
	input select;
	output[7:0] out;
	wire[7:0] w0, w1, w2, w3;
	genvar i;
	generate
	for (i = 0; i < 8; i = i+1) begin: loop1
		assign w0[i] = select;
		assign w1[i] = ~w0[i];
		assign w2[i] = in1[i] & w0[i];
		assign w3[i] = in0[i] & w1[i];
		assign out[i] = w2[i] | w3[i];
	end
	endgenerate
endmodule



module twoToOneMux4Bit(in0, in1, select, out);
	input[3:0] in1, in0;
	input select;
	output[3:0] out;
	wire[3:0] w0, w1, w2, w3;
	genvar i;
	generate
	for (i = 0; i < 4; i = i+1) begin: loop1
		assign w0[i] = select;
		assign w1[i] = ~w0[i];
		assign w2[i] = in1[i] & w0[i];
		assign w3[i] = in0[i] & w1[i];
		assign out[i] = w2[i] | w3[i];
	end
	endgenerate
endmodule

module twoToOneMux2Bit(in0, in1, select, out);
	input[1:0] in1, in0;
	input select;
	output[1:0] out;
	//wire w0;
	wire[1:0] w0, w1, w2, w3;
	assign w0[0] = select;
	assign w0[1] = select;
	assign w1[0] = ~w0[0];
	assign w1[1]= ~w0[1];
	//not notIn1(w1, w0);
	//not notIn0(w1, in0);
	//not notSelect(w2, select);
	
	assign w2[0] = in1[0] & w0[0];
	assign w2[1] = in1[1] & w0[1];
	
	assign w3[0] = in0[0] & w1[0];
	assign w3[1] = in0[1] & w1[1];
	//and and1(w2, in1, w0);
	//and and2(w3, in0, w1);
	//and and3(w5, in1, in0, w2);
	//and and4(w6, in1, in0, select);
	assign out[0] = w2[0] | w3[0];
	assign out[1] = w2[1] | w3[1];
	//or orOne(out, w2, w3);
endmodule


module twoToOneMux1Bit(in0, in1, select, out);
	input in1, in0, select;
	output out;
	wire w0, w1, w2, w3, w4, w5, w6;
	
	not notIn1(w0, select);
	//not notIn0(w1, in0);
	//not notSelect(w2, select);
	
	
	and and1(w1, in1, select);
	and and2(w2, in0, w0);
	//and and3(w5, in1, in0, w2);
	//and and4(w6, in1, in0, select);
	
	or orOne(out, w1, w2);
	
	

endmodule

module decoderOneTwo(in, out);
	input in;
	output[1:0] out;
	
	assign out = 1'b1 << in;

endmodule

module subtract(a, b, cin, cout, result); // add positive and negative number, can use carry in of 1 to take care of negation (to negate, add 1 to complemented bits)
	input[31:0] a, b;
	input cin;
	output[31:0] result;
	output cout;
	wire[31:0] negatedResult;
	// b will be negated input when called
	//input now negated, but 1 hasn't been added. to negate, flip all bits and add 1, the add 1 can be done through adder cin
	negate negateInput(b, negatedResult);
	thirtyTwoBitCarrySelectAdder subtractInputs(a, negatedResult, cin, cout, result);
endmodule

//to negate a number, flip all the bits and add 1 - will add 1 when putting through the adder
module negate(in, out);
	input[31:0] in;
	output[31:0] out;

	genvar i;
	generate
	for (i = 0; i < 32; i = i + 1) begin: loop
		assign out[i] = ~in[i];
	end
	endgenerate
	
endmodule



