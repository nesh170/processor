transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/nesh1/OneDrive/Current\ Classes/ECE\ 350/Processor/ALU {C:/Users/nesh1/OneDrive/Current Classes/ECE 350/Processor/ALU/shift_right_arithmetic.v}

vlog -vlog01compat -work work +incdir+C:/Users/nesh1/OneDrive/Current\ Classes/ECE\ 350/Processor/ALU {C:/Users/nesh1/OneDrive/Current Classes/ECE 350/Processor/ALU/testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  Dwyer_testBench

add wave *
view structure
view signals
run -all
