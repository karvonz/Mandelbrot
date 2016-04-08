
#Map the required libraries here.#

vmap -c
vmap tmcalotrigger_lib ../../../calotrig/sim/tmcalotrigger_lib/tmcalotrigger_lib
#vmap unisim /opt/Xilinx/13.1/ISE_DS/ISE/vhdl/mti_se/6.6b/lin64/unisim/#


#Add libraries here #

vlib work

#Compile all module#

vcom -vmake -work work ../../hdl/detector_sim.vhd
vcom -vmake -work work ../../hdl/timemux_top.vhd
vcom -vmake -work work ../../hdl/timemux_tb.vhd

#vcom -vmake -work work ../../hdl/*#

#Load the design. Use required libraries.#
vsim -t ps -novopt +notimingchecks work.timemux_tb

#View sim_tb_top signals in waveform#
add wave sim:/timemux_tb/*
add wave -noupdate -divider -height 32 detector_sim_inst
add wave -noupdate sim:/timemux_tb/detector_sim_inst/*
add wave -noupdate -divider -height 32 timemux_top_inst
add wave -noupdate sim:/timemux_tb/timemux_top_inst/*

#Change radix to Hexadecimal#
radix hex

#Supress Numeric Std package and Arith package warnings.#
#For VHDL designs we get some warnings due to unknown values on some signals at startup#
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0#
#We may also get some Arithmetic packeage warnings because of unknown values on#
#some of the signals that are used in an Arithmetic operation.#
#In order to suppress these warnings, we use following two commands#
set NumericStdNoWarnings 1
set StdArithNoWarnings 1

#Choose simulation run time by inserting a breakpoint and then run for specified #
#period. For more details, refer to Simulation Guide section of MIG user guide (UG086).#

run 2 us

stop
