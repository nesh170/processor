library verilog;
use verilog.vl_types.all;
entity multdiv is
    port(
        data_operandA   : in     vl_logic_vector(31 downto 0);
        data_operandB   : in     vl_logic_vector(15 downto 0);
        ctrl_MULT       : in     vl_logic;
        ctrl_DIV        : in     vl_logic;
        clock           : in     vl_logic;
        data_result     : out    vl_logic_vector(31 downto 0);
        data_exception  : out    vl_logic;
        data_inputRDY   : out    vl_logic;
        data_resultRDY  : out    vl_logic
    );
end multdiv;
