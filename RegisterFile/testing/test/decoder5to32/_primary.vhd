library verilog;
use verilog.vl_types.all;
entity decoder5to32 is
    port(
        \in\            : in     vl_logic_vector(4 downto 0);
        \out\           : out    vl_logic_vector(31 downto 0)
    );
end decoder5to32;
