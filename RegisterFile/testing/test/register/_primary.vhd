library verilog;
use verilog.vl_types.all;
entity \register\ is
    port(
        bitsIn          : in     vl_logic_vector(31 downto 0);
        bitsOut         : out    vl_logic_vector(31 downto 0);
        writeEnable     : in     vl_logic;
        reset           : in     vl_logic;
        clk             : in     vl_logic
    );
end \register\;
