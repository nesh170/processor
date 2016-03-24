`timescale 1 ns / 100 ps
module testbench();
    ///////////////////////////////////////////////////////////////////////////
    parameter minfreq = 50;    // Min. clock freq. for testing (in MHz)
    parameter maxfreq = 300;    // Max. clock freq. for testing (in MHz)
    parameter freqstep = 50;    // Increment in clock freq. between tests (in MHz)
    ///////////////////////////////////////////////////////////////////////////
    // Tracking the number of errors
    reg clock, ctrl_reset;    // standard signals- required even if DUT doesn't use them
    integer errors, ticks, adderErrors; // ticks are HALF clock ticks... two ticks equal a clock period
    integer clktest;    // for testing...
   integer clock_halfperiod;
    integer testresults[maxfreq:0]; // for reporting


    // inputs to the DUT are reg type
    reg signed [31:0] data_operandA, data_operandB;
    reg [4:0] ctrl_ALUopcode, ctrl_shiftamt;    
    
    // outputs from the DUT are wire type
    wire [31:0] data_result;
    wire isNotEqual, isLessThan;

 

    // instantiate the DUT
    // data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan
    ALU U1 (.data_operandA(data_operandA), .data_operandB(data_operandB), .ctrl_ALUopcode(ctrl_ALUopcode),
                        .ctrl_shiftamt(ctrl_shiftamt), .data_result(data_result), .isNotEqual(isNotEqual),
                        .isLessThan(isLessThan));

 

 


 
   
   
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // setting the initial values of all the reg
    initial
    begin        
        clock = 1'b0;    // at time 0
        errors = 0; ticks = 0; adderErrors=0;       
        
        for(clktest = maxfreq; clktest >= minfreq; clktest = clktest - freqstep) begin    
            $display(ticks, " << Starting %d MHz simulation >>", clktest);
            errors = 0;
            test(2000.0 / clktest);            
            testresults[clktest] = errors;
      end

        $display(ticks, " << Starting the 'functional' Simulation >>");
        errors = 0;
        test(1000);    // a very slow clock test        
        $write(" \n\n--------------------------SUMMARY--------------------------\n                                 ERRORS\nTest @\t    functional: %d\n", errors);
        
        for(clktest = maxfreq; clktest >= minfreq; clktest = clktest - freqstep) begin
            $write("Test @       %d MHz: %d\n", clktest, testresults[clktest]);
        end
        
      $stop; // break point (permits analysis)
    end
    
    // Clock generator
    always
    begin
         #clock_halfperiod     clock = ~clock;    // toggle
        ticks = ticks + 1;
    end
        
 ///////////////////////////////////////////////////////////////////////////////
 task test;    // Perform a test of the DUT at a particular clock (half) period
  input integer clk_half;
  integer index_op, index_rep;
  integer opA, opB;
  begin
    clock_halfperiod = clk_half; // change the current clock half period...
        
    ctrl_reset = 1'b1;    // assert reset
    @(negedge clock);    // wait until next negative edge of clock
    @(negedge clock);    // wait until next negative edge of clock
    ctrl_reset = 1'b0;    // de-assert reset        
    @(negedge clock);    // wait until next negative edge of clock

    // Begin testing...
    for(index_op = 0;index_op <= 5;index_op = index_op + 1)    // iterate through ALUopcodes
        begin
        for(index_rep = 0;index_rep <= 15;index_rep = index_rep + 1)    // replicated random tests
            begin
                opA = $random;
                opB = $random;
                
                case(index_op)
                    0: verify(opA, opB, index_op, index_rep, opA + opB);
                    1: verify(opA, opB, index_op, index_rep, opA - opB);
                    2: verify(opA, opB, index_op, index_rep, opA & opB);
                    3: verify(opA, opB, index_op, index_rep, opA | opB);
                    4: verify(opA, opB, index_op, index_rep, opA << index_rep);
                    5: verify(opA, opB, index_op, index_rep, opA >>> index_rep);
                    default: $write("PANIC: illegal ALUop in test bench!?!?\n");
                endcase                
            end
    end
    
    // Test < and == operators
    for(index_rep = 0;index_rep <= 15;index_rep = index_rep + 1)    // replicated random tests
    begin
        opA = $random;
        opB = $random;
        
        verifyLTNEQ(opA, opB, opA < opB, opA != opB);
        verifyLTNEQ(opB, opA, opB < opA, opB != opA);
        verifyLTNEQ(opA, opA, 0, 0);
    end    
    
    if(errors == 0) begin
               $display("The simulation completed without errors");
   end else begin
              $display("The simulation failed with %d errors", errors);
	      $display("The simulation failed with %d adder_errors", adderErrors);
   end
  end
 endtask
 
 task verify;
 input [31:0] inopA;
 input [31:0] inopB;
 input [4:0] inALUop;
 input [4:0] inSH;
 input [31:0] inExp;
 
    begin
        $display(ticks, " << Executing opcode %d with (0x%h, 0x%h, %d) >>", inALUop, inopA, inopB, inSH);
        
        data_operandA = inopA;
        data_operandB = inopB;
        ctrl_ALUopcode = inALUop;
        ctrl_shiftamt = inSH;
        
        @(posedge clock); // wait for next posedge, calculation should be done
        if(data_result != inExp) begin
            $display("**Error in calculation: 0x%h but expected 0x%h.", data_result, inExp);
		if(ctrl_ALUopcode==5) begin
		adderErrors= adderErrors +1;       

		end	
            errors = errors + 1;            
        end else begin
          $display("\t\t Operation correct.");
        end
    
    end
 endtask
 
 
task verifyLTNEQ;
 input [31:0] inopA2;
 input [31:0] inopB2;
 input LT;
 input NEQ;
 
    begin
        $display(ticks, " << Executing LTNEQ with (0x%h, 0x%h) >>", inopA2, inopB2);
        
        data_operandA = inopA2;
        data_operandB = inopB2;
        ctrl_ALUopcode = 1;    // subtract        
        
        @(posedge clock); // wait for next posedge, calculation should be done
        if(isLessThan != LT) begin
            $display("**Error in LT calculation: expected %d", inopA2 < inopB2);
            errors = errors + 1;            
        end else begin
          $display("\t\t LT operation correct.");
        end

        if(isNotEqual != NEQ) begin
            $display("**Error in NEQ calculation: expected %d", inopA2 != inopB2);
            errors = errors + 1;            
        end else begin
          $display("\t\t NEQ operation correct.");
        end
    
    end
 endtask


endmodule

