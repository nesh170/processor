library verilog;
use verilog.vl_types.all;
entity carry_select_Adder is
    port(
        in_A            : in     vl_logic_vector(31 downto 0);
        in_B            : in     vl_logic_vector(31 downto 0);
        \out\           : out    vl_logic_vector(31 downto 0);
        carry_in        : in     vl_logic;
        carry_out       : out    vl_logic
    );
end carry_select_Adder;
