`timescale 1 ns / 100 ps
module alu_tb();
    // inputs to the DUT are reg type
    reg [4:0]     ctrl_ALUopcode, ctrl_shiftamt;
    reg [31:0]     data_operandA, data_operandB;

    reg clock;

    // outputs from the DUT are wire type
    wire [31:0] data_result;
    wire isNotEqual, isLessThan;

    integer index, i;
    integer errors;
    integer addE, subE, andE, orE, sllE, sraE;
    integer specialE;
    integer testNumber;

    // instantiate the DUT
    sl290_alu     U1 (data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan);

    // setting the initial values of all the reg
    initial
    begin

        $display($time, " << Starting the Simulation >>");
        clock = 1'b0;    // at time 0
        errors = 0;
        addE = 0;
        subE = 0;
        andE = 0;
        orE = 0;
        sllE = 0;
        sraE = 0;
        specialE = 0;
        testNumber = 0;

        @(negedge clock);    // wait until next negative edge of clock
        @(negedge clock);    // wait until next negative edge of clock

        $display("\nTesting ADD now:\n");
        test(5'd0, 5'd0, 32'd0, 32'd1);
        check(32'd1);
        test(5'd0, 5'd0, 32'd1000, 32'd1028748);
        check(32'd1029748);
        test(5'd0, 5'd0, 32'd15, -32'd15);
        check(32'd0);

        test(5'd0, 5'd0, 1 << 15, 2 << 25);
        check((1 << 15) + (2 << 25));
        
        $display("Starting for loop for add");
        for (index=0; index<32; index=index+1) 
        begin
            test(5'd0, 5'd0, 1 << index, 1 << index);
            check((1<<index) + (1<<index));
        end

        for (index=0; index<32; index=index+1) 
        begin
            test(5'd0, 5'd0, 1 << index, 4294967295 - (1 << index));
            check((1<<index) + 4294967295 - (1<<index));
        end

        for (index=0; index<32; index=index+1) 
        begin
            test(5'd0, 5'd0, 1 << index, 4294967295);
            check((1<<index) + 4294967295);
        end

        for (index = 0; index <= 31; index = index+1)
        begin
            test(5'd0, 5'd0, (1 << index) + 24 * i, 24 << (index/2)+17*i);
            check((1<<index) + 24 * i +(index/2)+17*i);
        end

        test(5'd0, 5'd0, 32'd73707701, 32'd73707701);
        check(32'd147415402);
        test(5'd0, 5'd0, 32'd73707701, -32'd141598138);
        check(32'd73707701 + -32'd141598138);
        test(5'd0, 5'd0, 32'd5190043, 32'd141598138);
        check(32'd5190043 + 32'd141598138);
        test(5'd0, 5'd0, 32'd47237836, -32'd5190043);
        check(32'd47237836 + -32'd5190043);
        test(5'd0, 5'd0, 32'd5190043, -32'd47237836);
        check(32'd5190043 + -32'd47237836);
        test(5'd0, 5'd0, 32'd47237836, -32'd141598138);
        check(32'd47237836 + -32'd141598138);
        test(5'd0, 5'd0, -32'd47237836, 32'd47237836);
        check(-32'd47237836 + 32'd47237836);
        test(5'd0, 5'd0, -32'd84052716, -32'd84052716);
        check(-32'd84052716 + -32'd84052716);
        test(5'd0, 5'd0, -32'd47237836, 32'd141598138);
        check(-32'd47237836 + 32'd141598138);


        $display("\nTesting subtract now:\n");
        test(5'd1, 5'd0, 32'd0, 32'd1);
        check(-32'd1);
        test(5'd1, 5'd0, 32'd1000, 32'd1028748);
        check(-32'd1027748);
        test(5'd1, 5'd0, 32'd15, 32'd15);
        check(32'd0);
        test(5'd1, 5'd0, 32'd0, 32'd1);
        check(-32'd1);
        test(5'd1, 5'd0, 32'd1000, 32'd1028748);
        check(-32'd1027748);
        test(5'd1, 5'd0, 32'd15, -32'd15);
        check(32'd30);

        test(5'd1, 5'd0, 1 << 15, 2 << 25);
        check((1 << 15) - (2 << 25));
        
        $display("Starting for loop for sub");
        for (index=0; index<32; index=index+1) 
        begin
            test(5'd1, 5'd0, 1 << index, 1 << index);
            check((1<<index) - (1<<index));
        end

        for (index = 0; index <= 31; index = index+1)
        begin
            test(5'd1, 5'd0, (1 << index) - 24 * i + (3 >> index)*17, 5 << (index) *7 + 23*i);
            check(((1 << index) - 24 * i + (3 >> index)*17)-
            (5 << (index) *7 + 23*i));
        end

        test(5'd1, 5'd0, 32'd73707701, 32'd73707701);
        check(32'd0);
        test(5'd1, 5'd0, 32'd73707701, -32'd141598138);
        check(32'd73707701 + 32'd141598138);
        test(5'd1, 5'd0, 32'd5190043, 32'd141598138);
        check(32'd5190043 - 32'd141598138);
        test(5'd1, 5'd0, 32'd47237836, -32'd5190043);
        check(32'd47237836 - -32'd5190043);
        test(5'd1, 5'd0, 32'd5190043, -32'd47237836);
        check(32'd5190043 - -32'd47237836);
        test(5'd1, 5'd0, 32'd47237836, -32'd141598138);
        check(32'd47237836 - -32'd141598138);
        test(5'd1, 5'd0, -32'd47237836, 32'd47237836);
        check(-32'd47237836 - 32'd47237836);
        test(5'd1, 5'd0, -32'd84052716, -32'd84052716);
        check(-32'd84052716 - -32'd84052716);
        test(5'd1, 5'd0, -32'd47237836, 32'd141598138);
        check(-32'd47237836 - 32'd141598138);

        $display("\nTesting AND now:\n");
        test(5'd2, 5'd0, 
            32'b00000000000000000000000000000000, 
            32'b00000000000000000000000000000000);
        check(32'b00000000000000000000000000000000);

        test(5'd2, 5'd0, 
            32'b11111111111111111111111111111111, 
            32'b00000000000000000000000000000000);
        check(32'b00000000000000000000000000000000);

        test(5'd2, 5'd0, 
            32'b00000000000000000000000000000000, 
            32'b11111111111111111111111111111111);
        check(32'b00000000000000000000000000000000);
        
        test(5'd2, 5'd0, 
            32'b11111111111111111111111111111111, 
            32'b11111111111111111111111111111111);
        check(32'b11111111111111111111111111111111);
        
        test(5'd2, 5'd0, 
            32'b11111011111011011101111101110111, 
            32'b00001000100100010010001000100010);
        check(32'b11111011111011011101111101110111 & 
            32'b00001000100100010010001000100010);

        $display("\nTesting OR now:\n");
        test(5'd3, 5'd0, 
            32'b00000000000000000000000000000000, 
            32'b00000000000000000000000000000000);
        check(32'b00000000000000000000000000000000);

        test(5'd3, 5'd0, 
            32'b11111111111111111111111111111111, 
            32'b00000000000000000000000000000000);
        check(32'b11111111111111111111111111111111);

        test(5'd3, 5'd0, 
            32'b00000000000000000000000000000000, 
            32'b11111111111111111111111111111111);
        check(32'b11111111111111111111111111111111);
        
        test(5'd3, 5'd0, 
            32'b11111111111111111111111111111111, 
            32'b11111111111111111111111111111111);
        check(32'b11111111111111111111111111111111);
        
        test(5'd3, 5'd0, 
            32'b11111011111011011101111101110111, 
            32'b00001000100100010010001000100010);
        check(32'b11111011111011011101111101110111 | 
            32'b00001000100100010010001000100010);
        

        $display("\nTesting SLL now:\n");
        test(5'd4, 5'd0, 
            32'b00000000000000000000000000000000, 
            32'd0);
        check(32'b00000000000000000000000000000000);

        test(5'd4, 5'd16, 
            32'b11111111111111111111111111111111, 
            32'd0);
        check(32'b11111111111111110000000000000000);

        test(5'd4, 5'd31, 
            32'b10000000000000000000000000000001, 
            32'd0);
        check(32'b10000000000000000000000000000000);
        
        test(5'd4, 5'd13, 
            32'b10101010101010101010101010101010, 
            32'd0);
        check(32'b10101010101010101010101010101010 << 5'd13);
        
        test(5'd4, 5'd27, 
            32'b11111011111011011101111101110111, 
            32'd0);
        check(32'b11111011111011011101111101110111 << 5'd27); 

        $display("\nTesting SRA now:\n");
        test(5'd5, 5'd0, 
            32'b00000000000000000000000000000000, 
            32'd0);
        check(32'b00000000000000000000000000000000);

        test(5'd5, 5'd16, 
            32'b11111111111111111111111111111111, 
            32'd0);
        check(32'b11111111111111111111111111111111);

        test(5'd5, 5'd31, 
            32'b10000000000000000000000000000001, 
            32'd0);
        check(32'b11111111111111111111111111111111);
        
        test(5'd5, 5'd13, 
            32'b10101010101010101010101010101010, 
            32'd0);
        check($signed(32'b10101010101010101010101010101010) >>> 5'd13);
        
        test(5'd5, 5'd27, 
            32'b11011011111011011101111101110111, 
            32'd0);
        check($signed(32'b11011011111011011101111101110111) >>> 5'd27);

        test(5'd5, 5'd13, 
            32'b00101010101010101010101010101010, 
            32'd0);
        check(32'b00101010101010101010101010101010 >>> 5'd13);


        $display("\nTesting subtract special now:\n");
        test(5'd1, 5'd0, 32'd0, 32'd0);
        subCheck(0, 0);
        test(5'd1, 5'd0, 32'd1000, 32'd1028748);
        subCheck(1, 1);
        test(5'd1, 5'd0, 32'd15, 32'd15);
        subCheck(0, 0);
        test(5'd1, 5'd0, 32'd100000, 32'd1343);
        subCheck(1, 0);
        test(5'd1, 5'd0, -32'd1000, 32'd1028748);
        subCheck(1, 1);
        test(5'd1, 5'd0, 32'd15, -32'd15);
        subCheck(1, 0);
        test(5'd1, 5'd0, 32'd15, -32'd15);
        subCheck(1'bz, 1'bz);
        test(5'd0, 5'd0, 32'd15, -32'd15);
        subCheck(1'bz, 1'bz);
        test(5'd2, 5'd0, 32'd15, -32'd15);
        subCheck(1'bz, 1'bz);
        test(5'd3, 5'd0, 32'd15, -32'd15);
        subCheck(1'bz, 1'bz);
        test(5'd4, 5'd0, 32'd15, -32'd15);
        subCheck(1'bz, 1'bz);
        test(5'd5, 5'd0, 32'd15, -32'd15);
        subCheck(1'bz, 1'bz);

        if (errors == 0) begin
        $display("\nThe simulation completed without errors");
        end
        else begin
            $display("\nThe simulation failed with %d errors", errors);
        end
        $display("Simulated %d tests", testNumber);
        $display("Total errors: %d", errors);
        $display("ADD   errors: %d", addE);
        $display("SUB   errors: %d", subE);
        $display("AND   errors: %d", andE);
        $display("OR    errors: %d", orE);
        $display("SLL   errors: %d", sllE);
        $display("SRA   errors: %d", sraE);
        $display("Special Sub");
        $display("      errors: %d", sraE);
    $stop;
    end
    always
         #50     clock = ~clock;    // toggle
    task test;
        input [4:0] op;
        input [4:0] shift;
        input [31:0] a;
        input [31:0] b;

        begin
            @(negedge clock);    // wait for next negedge of clock
            //$display("Writing register: \t%10d, Value: %h", regi, value);

            //$display("Testing");

    		ctrl_ALUopcode = op;
    		ctrl_shiftamt = shift;
    		data_operandA = a;
    		data_operandB = b;

            @(negedge clock); // wait for next negedge, write should be done
        end
    endtask

    task check;
    	input [31:0] value;
        begin
            @(negedge clock);    // wait for next negedge of clock
           
            @(negedge clock); // wait for next negedge, read should be done
            testNumber = testNumber + 1;
            $display("Checking test number %d", testNumber);

            if (data_result != value) begin
                $display("Error: Values don't match");
                $display("Expected: %d", value);
                $display("Expected: %b", value);
                $display("Actual  : %d", data_result);
                $display("Actual  : %b", data_result);
                errors = errors + 1;
                if (ctrl_ALUopcode == 5'd0) begin
                    addE = addE + 1;
                end
                else if (ctrl_ALUopcode == 5'd1) begin
                    subE = subE + 1;
                end
                else if (ctrl_ALUopcode == 5'd2) begin
                    andE = andE + 1;
                end
                else if (ctrl_ALUopcode == 5'd3) begin
                    orE = orE + 1;
                end
                else if (ctrl_ALUopcode == 5'd4) begin
                    sllE = sllE + 1;
                end
                else if (ctrl_ALUopcode == 5'd5) begin
                    sraE = sraE + 1;
                end
            end
            @(negedge clock); // wait for next negedge, write should be done
        end
    endtask

    task subCheck;
        input notEqual;
        input lessThan;
        begin
            @(negedge clock);    // wait for next negedge of clock
           
            @(negedge clock); // wait for next negedge, read should be done
            testNumber = testNumber + 1;
            $display("Checking test number %d", testNumber);

            if (isNotEqual != notEqual) begin
                $display("Error: Values don't match");
                $display("Expected: %b", notEqual);
                $display("Actual  : %b", isNotEqual);
                errors = errors + 1;
                specialE = specialE + 1;
            end

            if (lessThan != isLessThan) begin
                $display("Error: Values don't match");
                $display("Expected: %b", lessThan);
                $display("Actual  : %b", isLessThan);
                errors = errors + 1;
                specialE = specialE + 1;
            end
            @(negedge clock); // wait for next negedge, write should be done
        end
    endtask
 endmodule