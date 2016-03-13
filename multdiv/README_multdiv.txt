This contains all the files needed to assemble a multiplier and a divider in Quartus. It was tested using functional testing on the testbench provided in class and successfully passes all the cases. Hence it could run with 1 cycle per MULT and 1 cycle per DIV. This was ran using the RTL Simulation and Gate Level Simulation(FAST -M 1.2V 0 Model). The main file is multdiv.v

However, the counter was not implemented so data_inputRDY and data_outputRDY is always asserted hence only working with the functional test. 
Multiplication Implementation
  Modified Booth's Algorithm was used to calculate this but it could run in under 8 cycles since all the 8 possible outputs to add are generated in one cycle. Then, they are added in a 3 like structure in 3 stages. Thus taking a cycle each for each state thus being able to successfully output an answer in less than eight stages.
  
  
Division Implementation
  The division implementation was implemented based on this psudo code
      ```
      if D == 0 then error(DivisionByZeroException) end
      Q := 0                 -- initialize quotient and remainder to zero
      R := 0                     
      for i = n-1...0 do     -- where n is number of bits in N
        R := R << 1          -- left-shift R by 1 bit
        R(0) := N(i)         -- set the least-significant bit of R equal to bit i of the numerator
        if R >= D then
          R := R - D
          Q(i) := 1
        end
      end
      ```
  The div0 exception was checked by checking if all of data_operandB is all 0.
