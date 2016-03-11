`timescale 1 ns / 100 ps
module testbench_jw();  
    // inputs to the DUT are reg type
    reg signed [31:0] data_operandA;
    reg signed [15:0] data_operandB;
    reg ctrl_MULT, ctrl_DIV;               
    
    // outputs from the DUT are wire type
    wire [31:0] data_result; 
    wire data_exception, data_inputRDY, data_resultRDY;

    // Tracking the number of errors
    reg clock, ctrl_reset;    
    // standard signals- required even if DUT doesn't use them

    integer totalErrors;
    integer errors, ticks; // ticks are HALF clock ticks... two ticks equal a clock period

    integer clktest;    // for testing...
    integer clock_halfperiod;
 
    // instantiate the DUT
    multdiv my_multdiv(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, data_result, data_exception, data_inputRDY, data_resultRDY);

    // setting the initial values of all the reg
    initial
    begin        
        totalErrors = 0;
        clock = 1'b0;    // at time 0
        errors = 0; ticks = 0;        

        $display("\nStarting the 'functional' Simulation");
        errors = 0;
        test(1000);    // a very slow clock test        
        $write(" \n\n--SUMMARY--\n                                 ERRORS\nTest @\t    functional: %d\n", errors);
        
        $display("Total Number of Errors: %d\n\n", totalErrors);
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
  integer opA, opB, index_rep;
  begin
    clock_halfperiod = clk_half; // change the current clock half period...
        
    ctrl_reset = 1'b1;    // assert reset
    @(negedge clock);    // wait until next negative edge of clock
    @(negedge clock);    // wait until next negative edge of clock
    ctrl_reset = 1'b0;    // de-assert reset        
    @(negedge clock);    // wait until next negative edge of clock

    // Begin testing...
    
    
    for(index_rep = 0;index_rep <= 15;index_rep = index_rep + 1)    // replicated random tests
        begin
            opA = $urandom_range(0,65535) - 32767;
            opB = $urandom_range(0,65535) - 32767;
            
            verifyMult(opA, opB, opA * opB);           
        end    
    
        
    for(index_rep = 0;index_rep <= 15;index_rep = index_rep + 1)    // replicated random tests
        begin
            opA = $random; //$urandom_range(-2147483648, 2147483647);
            opB = $urandom_range(0,65535) - 32767;
            
            verifyDiv(opA, opB, opA / opB);
        end  

    $display("\n\n");
    if(errors == 0) begin
               $display("The simulation completed without errors");
    end else begin
              $display("The simulation failed with %d errors", errors);
    end
  end
 endtask
 
 task verifyMult;
 input [31:0] inopA;
 input [15:0] inopB;
 input [31:0] inExp;
 
    begin
        $display("\n\nExecuting mult");
        $display("inopA : %b", inopA);
        $display("inopB : %b", inopB);
        
        data_operandA = inopA;
        data_operandB = inopB;
        ctrl_MULT = 1;
        ctrl_DIV = 0;
        
        @(posedge clock); // wait for next posedge, calculation should be done
        if(data_result != inExp) begin
            $display("actual: %b, expected: %b", data_result, inExp);
            $display("Operation incorrect.");
            errors = errors + 1;  
            totalErrors = totalErrors + 1;          
        end else begin
            $display("actual: %b, expected: %b", data_result, inExp);
            $display("Operation correct.");
        end
    end
 endtask

 task verifyDiv;
 input [31:0] inopA;
 input [15:0] inopB;
 input [31:0] inExp;
 
    begin
        $display("\n\nExecuting div");
        $display("inopA : %b", inopA);
        $display("inopB : %b", inopB);
        
        data_operandA = inopA;
        data_operandB = inopB;
        ctrl_MULT = 0;
        ctrl_DIV = 1;
        
        @(posedge clock); // wait for next posedge, calculation should be done
        if(data_result != inExp) begin
            $display("actual: %b, expected: %b", data_result, inExp);
            $display("Operation incorrect.");
            errors = errors + 1;  
            totalErrors = totalErrors + 1;          
        end else begin
            $display("actual: %b, expected: %b", data_result, inExp);
            $display("Operation correct.");
        end
    end
 endtask
endmodule