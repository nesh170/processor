`timescale 1 ns / 100 ps
module regfile_tb();
    // inputs to the DUT are reg type
    reg     clock, ctrl_writeEn, ctrl_reset;
    reg [4:0]     ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    reg [31:0]     data_writeReg;

    // outputs from the DUT are wire type
    wire [31:0] data_readRegA, data_readRegB;

    integer index, i;

    // instantiate the DUT
    regfile     U1 (clock, ctrl_writeEn, ctrl_reset, ctrl_writeReg,
                ctrl_readRegA, ctrl_readRegB, data_writeReg,
                 data_readRegA, data_readRegB);

    // setting the initial values of all the reg
    initial
    begin

        $display($time, " << Starting the Simulation >>");
        clock = 1'b0;    // at time 0

        ctrl_reset = 1'b1;    // assert reset
        ctrl_writeEn = 1'b0;
        @(negedge clock);    // wait until next negative edge of clock
        @(negedge clock);    // wait until next negative edge of clock
        ctrl_reset = 1'b0;    // de-assert reset
        @(negedge clock);    // wait until next negative edge of clock
        printRegisters();

        $display($time, "Initial:");
        $display("\nWriting registers now:");
        for (index = 0; index <= 31; index = index+1)
        begin
            writeRegister(index, index + (index << 8) + (index << 16) + (index << 24));
        end
        $display("\nReading registers now:");
        printRegisters();
        $display("\nWriting registers now:");
        for (index = 0; index <= 31; index = index+1)
        begin
            writeRegister(index, 4294967295 - (index + (index << 8) + (index << 16) + (index << 24)));
        end
        $display("\nReading registers now:");
        printRegisters();
        $display("\nWriting registers now:");
        for (index = 0; index <= 31; index = index+2)
        begin
            writeRegister(index, index * 3 + (index << 19));
        end
        $display("\nReading registers now:");
        printRegisters();
        $display("\nWriting registers now:");
        for (index = 1; index <= 31; index = index+2)
        begin
            writeRegister(index, (index << 4) + (index << 12) + (index << 17));
        end
        $display("\nReading registers now:");
        printRegisters();
        $display("\nWriting registers now:");
        for (index = 1; index <= 31; index = index*2)
        begin
            writeRegister(index, (index << 2) + (index << 3) + (index << 9) - (index << 12));
        end
        $display("\nReading registers now:");
        printRegisters();
    $stop;
    end
    always
         #25     clock = ~clock;    // toggle
    task writeRegister;
        input [4:0] regi;
        input [31:0] value;

        begin
            @(negedge clock);    // wait for next negedge of clock
            $display("Writing register: \t%10d, Value: %h", regi, value);
            ctrl_writeEn = 1'b1;
            ctrl_writeReg = regi;
            data_writeReg = value;

            @(negedge clock); // wait for next negedge, write should be done
            ctrl_writeEn = 1'b0;
        end
    endtask
    task printRegisters;
        begin
            for(i = 0;i <= 31;i = i + 1)
            begin
                @(negedge clock);    // wait for next negedge of clock
                ctrl_writeEn = 1'b0;
                ctrl_readRegA = i;    // test port A
                ctrl_readRegB = i;    // test port B

                @(negedge clock); // wait for next negedge, read should be done
                if (data_readRegA != data_readRegB) begin
                    $display("Error:  read port mismatch");
                end
                $display("Reading register: \t%10d, Value: %h", i, data_readRegA);
            end
            @(negedge clock); // wait for next negedge, write should be done
        end
    endtask

 endmodule
