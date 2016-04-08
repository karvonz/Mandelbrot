
#Map the required libraries here.#

vmap -c
vmap unisim /opt/Xilinx/13.1/ISE_DS/ISE/vhdl/mti_se/6.6b/lin64/unisim/

#Add libraries here #

vlib tmcalotrigger_lib

#Compile all module#

vcom -vmake -work tmcalotrigger_lib ../../hdl/constants_pkg.vhd
vcom -vmake -work tmcalotrigger_lib ../../hdl/types_pkg.vhd
vcom -vmake -work tmcalotrigger_lib ../../hdl/linkinterface_linkinterface.vhd
vcom -vmake -work tmcalotrigger_lib ../../hdl/components_pkg.vhd
vcom -vmake -work tmcalotrigger_lib ../../hdl/TowerLinearizer_TowerLinearizer.vhd
vcom -vmake -work tmcalotrigger_lib ../../hdl/ClusterWeight_ClusterWeight.vhd
vcom -vmake -work tmcalotrigger_lib ../../hdl/Comparitor_Comparitor.vhd
vcom -vmake -work tmcalotrigger_lib ../../hdl/EHAdder_EHAdder.vhd
vcom -vmake -work tmcalotrigger_lib ../../hdl/EPIM_EPIM.vhd
vcom -vmake -work tmcalotrigger_lib ../../hdl/TowerPruning_TowerPruning.vhd
vcom -vmake -work tmcalotrigger_lib ../../hdl/ClusterOverlapFilter_ClusterOverlapFilter.vhd
vcom -vmake -work tmcalotrigger_lib ../../hdl/AlgorithmTop_AlgorithmTop.vhd

#vcom -vmake -work tmcalotrigger_lib ../../hdl/*#

#Load the design. Use required libraries.#
#vsim -t ps -novopt +notimingchecks tmcalotrigger_lib.AlgorithmTop#

#View sim_tb_top signals in waveform#
#add wave sim:/AlgorithmTop/*#

#Change radix to Hexadecimal#
#radix hex#

#Supress Numeric Std package and Arith package warnings.#
#For VHDL designs we get some warnings due to unknown values on some signals at startup#
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0#
#We may also get some Arithmetic packeage warnings because of unknown values on#
#some of the signals that are used in an Arithmetic operation.#
#In order to suppress these warnings, we use following two commands#
#set NumericStdNoWarnings 1#
#set StdArithNoWarnings 1#

#Choose simulation run time by inserting a breakpoint and then run for specified #
#period. For more details, refer to Simulation Guide section of MIG user guide (UG086).#

#run 100 us#

#stop#
