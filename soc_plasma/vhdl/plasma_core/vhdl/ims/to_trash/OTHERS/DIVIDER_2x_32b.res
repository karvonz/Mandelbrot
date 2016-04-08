#########################################
# DIVIDER 2x (32b) RESOURCE DECLARATION
#########################################
BEGIN INSTRUCTION
ENABLE = {YES}
NAME   = {fudiv}
VHDL   = {DIVIDER_2x_32b.vhd}
TYPE   = {SEQU}
INPUT  = {2}
OUTPUT = {1}
IMME   = {NO}
POWER  = {YES}
CYCLES = {16}
SLICES = {ML402:(242LUTs,155FFs,166Slices)}
CPATH  = {ML402:(8.296ns)}
END INSTRUCTION
