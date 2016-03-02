library verilog;
use verilog.vl_types.all;
entity shift_right_arithmetic is
    port(
        \in\            : in     vl_logic_vector(31 downto 0);
        ctrl_ShiftAmt   : in     vl_logic_vector(4 downto 0);
        \out\           : out    vl_logic_vector(31 downto 0)
    );
end shift_right_arithmetic;
