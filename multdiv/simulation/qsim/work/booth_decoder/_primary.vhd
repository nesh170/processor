library verilog;
use verilog.vl_types.all;
entity booth_decoder is
    port(
        booth_operation : in     vl_logic_vector(2 downto 0);
        multiplicand    : in     vl_logic_vector(31 downto 0);
        adder_output    : out    vl_logic_vector(31 downto 0);
        carry_in        : out    vl_logic
    );
end booth_decoder;
