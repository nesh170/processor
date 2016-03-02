library verilog;
use verilog.vl_types.all;
entity subtractor_32bit is
    port(
        in_A            : in     vl_logic_vector(31 downto 0);
        in_B            : in     vl_logic_vector(31 downto 0);
        \out\           : out    vl_logic_vector(31 downto 0)
    );
end subtractor_32bit;
