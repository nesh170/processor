`timescale 1 ns / 100 ps
module testbench();
    ///////////////////////////////////////////////////////////////////////////
    parameter minfreq = 30;    // Min. clock freq. for testing (in MHz)
    parameter maxfreq = 70;    // Max. clock freq. for testing (in MHz)
    parameter freqstep = 5;    // Increment in clock freq. between tests (in MHz)
    parameter cycles_per_mult = 8;    // for multi-cycle multiplcation
    parameter cycles_per_div = 66;        // for mult-cycle division
    ///////////////////////////////////////////////////////////////////////////
    // Tracking the number of errors
    reg clock, ctrl_reset;    // standard signals- required even if DUT doesn't use them
    integer errors, ticks; // ticks are HALF clock ticks... two ticks equal a clock period
    integer clktest;    // for testing...
   integer clock_halfperiod;
    integer testresults[maxfreq:0]; // for reporting    
   
    
    
    // inputs to the DUT are reg type
    reg signed [31:0] data_operandA;
   reg signed [15:0] data_operandB;
   reg ctrl_MULT, ctrl_DIV;
   
    // outputs from the DUT are wire type
    wire signed [31:0] data_result;
   wire data_exception, data_inputRDY, data_resultRDY;
    
    
    // instantiate the DUT
    //data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, data_result, data_exception, data_inputRDY, data_resultRDY
    multdiv        U1 (.data_operandA(data_operandA), .data_operandB(data_operandB), .ctrl_MULT(ctrl_MULT), .ctrl_DIV(ctrl_DIV),
                    .clock(clock), .data_result(data_result), .data_exception(data_exception), .data_inputRDY(data_inputRDY),
                    .data_resultRDY(data_resultRDY));
    
    
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // setting the initial values of all the reg
    initial
    begin        
        clock = 1'b0;    // at time 0
        errors = 0; ticks = 0;        
        
        for(clktest = maxfreq; clktest >= minfreq; clktest = clktest - freqstep) begin    
            $display(ticks, "\n\n\n << Starting %d MHz simulation >>", clktest);
            errors = 0;
            test(2000.0 / clktest);            
            testresults[clktest] = errors;
      end

        $display(ticks, " << Starting the 'functional' Simulation >>");
        errors = 0;
        test(1000000);    // a very slow clock test        
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
  integer index_rep, next_tick;
  reg signed [31:0] opA;
  reg signed [15:0] opB;
 
  begin
    clock_halfperiod = clk_half; // change the current clock half period...

    ctrl_MULT = 1'b0;
    ctrl_DIV = 1'b0;            
    ctrl_reset = 1'b1;    // assert reset
    @(negedge clock);    // wait until next negative edge of clock
    @(negedge clock);    // wait until next negative edge of clock
    ctrl_reset = 1'b0;    // de-assert reset        
    @(negedge clock);    // wait until next negative edge of clock

    // Begin testing MULT/DIV...
    for(index_rep = 0;index_rep <= 15;index_rep = index_rep + 1)    // replicated random tests
    begin
            opA = $random;
            opB = $random;
            
            next_tick = ticks + cycles_per_mult;
            verifyMULT(opA, opB, opA * opB);
            wait(ticks == next_tick);
            ctrl_MULT = 1'b0;
            ctrl_DIV = 1'b0;
            wait(ticks == next_tick+1);
            
            next_tick = ticks + cycles_per_div;            
            verifyDIV(opA, opB, opA / opB);
            wait(ticks == next_tick);
            ctrl_MULT = 1'b0;
            ctrl_DIV = 1'b0;
            wait(ticks == next_tick+1);
    end
    
    // Verify DIV0 exception
    next_tick = ticks + cycles_per_div;            
    verifyDIV0(opA);    // DIV0
    wait(ticks == next_tick);
    ctrl_MULT = 1'b0;
    ctrl_DIV = 1'b0;
    wait(ticks == next_tick+1);
            
    if(errors == 0) begin
               $display("The simulation completed without errors");
   end else begin
              $display("The simulation failed with %d errors", errors);
   end
    
  end
 endtask
 
 
 
// reg signed [31:0] data_operandA;
//   reg signed [15:0] data_operandB;
//   reg ctrl_MULT, ctrl_DIV, clock;
//   
//    // outputs from the DUT are wire type
//    wire [31:0] data_result;
//   wire data_exception, data_inputRDY, data_resultRDY;
    
 task verifyMULT;
 input signed [31:0] inopA;
 input signed [15:0] inopB;
 input signed [31:0] inExp;
 
    begin
        $display(ticks, " << Executing MULT with (%d, %d) >>", inopA, inopB);
        
        ctrl_MULT = 1'b1;
        ctrl_DIV = 1'b0;        
        wait(data_inputRDY);    // wait for the unit to become available...
        $display(ticks, " ***Unit available");
        
        data_operandA = inopA;
        data_operandB = inopB;

        wait(data_resultRDY);    // wait for the unit to finish...
        #15; // wait 15ns
        
        if(data_result[31] != (data_operandA[31] ^ data_operandB[15])) begin
            if(!data_exception) begin
                $display("**Error in exception handling.");
                errors = errors + 1;                
            end else begin
                $display(ticks, "\t\t Correct exception handling.");
            end
        end
    
        if(data_result != inExp) begin
            $display("**Error in calculation: %d but expected %d.", data_result, inExp);
            errors = errors + 1;            
        end else begin
          $display(ticks, "\t\t Operation correct.");
        end
    end
 endtask
 
 task verifyDIV;
 input signed [31:0] inopA;
 input signed [15:0] inopB;
 input signed [31:0] inExp;
 
    begin
        $display(ticks, " << Executing DIV with (%d, %d) >>", inopA, inopB);
        
        ctrl_MULT = 1'b0;
        ctrl_DIV = 1'b1;
        wait(data_inputRDY);    // wait for the unit to become available...
        $display(ticks, " ***Unit available");
        
        data_operandA = inopA;
        data_operandB = inopB;
        
        wait(data_resultRDY);    // wait for the unit to finish...
        #15; // wait 2ns
        
        if(data_result[31] != (data_operandA[31] ^ data_operandB[15])) begin
            if(!data_exception) begin
                $display("**Error in exception handling.");
                errors = errors + 1;                
            end else begin
                $display(ticks, "\t\t Correct exception handling.");
            end
        end
        
        if(data_result != inExp) begin
            $display("**Error in calculation: %d but expected %d.", data_result, inExp);
            errors = errors + 1;            
        end else begin
          $display(ticks, "\t\t Operation correct.");
        end
    end
 endtask

 task verifyDIV0;
 input signed [31:0] inopA;
 
    begin
        $display(ticks, " << Executing DIV0 with %d >>", inopA);
        
        ctrl_MULT = 1'b0;
        ctrl_DIV = 1'b1;
        wait(data_inputRDY);    // wait for the unit to become available...
        $display(ticks, " ***Unit available");
        
        data_operandA = inopA;
        data_operandB = 32'd0;
        
        wait(data_resultRDY);    // wait for the unit to finish...
        #2; // wait 2ns
        
        if(data_exception != 1'b1) begin
            $display("***Error catching DIV0 exception");
            errors = errors + 1;            
        end else begin
          $display(ticks, "\t\t Exception detected correctly.");
        end
    end
 endtask

 
 

endmodule