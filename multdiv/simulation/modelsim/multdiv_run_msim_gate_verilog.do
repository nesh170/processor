transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {multdiv_6_1200mv_85c_slow.vo}

vlog -vlog01compat -work work +incdir+C:/Users/nesh1/OneDrive/Current\ Classes/ECE\ 350/Processor/multdiv {C:/Users/nesh1/OneDrive/Current Classes/ECE 350/Processor/multdiv/testbench_jw.v}

vsim -t 1ps +transport_int_delays +transport_path_delays -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  testbench_jw

add wave *
view structure
view signals
run -all
