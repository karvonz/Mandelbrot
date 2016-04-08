###################################
# RIGHT SHIFTER (32b) RESOURCE DECLARATION
###################################
BEGIN INSTRUCTION
ENABLE = {YES}
NAME   = {rshift}
VHDL   = {RIGHT_SHIFTER_32b.vhd}
TYPE   = {COMB} 
INPUT  = {2}
OUTPUT = {1}
IMME   = {NO}
POWER  = {YES}
CYCLES = {0}
SLICES = {ML402:(156LUTs,0FFs,86Slices)}
CPATH  = {ML402:(4.125ns)}
END INSTRUCTION
