library verilog;
use verilog.vl_types.all;
entity testbench is
    generic(
        minfreq         : integer := 30;
        maxfreq         : integer := 150;
        freqstep        : integer := 5
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of minfreq : constant is 1;
    attribute mti_svvh_generic_type of maxfreq : constant is 1;
    attribute mti_svvh_generic_type of freqstep : constant is 1;
end testbench;
