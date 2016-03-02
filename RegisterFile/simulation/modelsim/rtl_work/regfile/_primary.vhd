library verilog;
use verilog.vl_types.all;
entity regfile is
    port(
        clock           : in     vl_logic;
        ctrl_writeEnable: in     vl_logic;
        ctrl_reset      : in     vl_logic;
        ctrl_writeReg   : in     vl_logic_vector(4 downto 0);
        ctrl_readRegA   : in     vl_logic_vector(4 downto 0);
        ctrl_readRegB   : in     vl_logic_vector(4 downto 0);
        data_writeReg   : in     vl_logic_vector(31 downto 0);
        data_readRegA   : out    vl_logic_vector(31 downto 0);
        data_readRegB   : out    vl_logic_vector(31 downto 0)
    );
end regfile;
