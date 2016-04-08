#########################################
# DIVIDER (32b) RESOURCE DECLARATION
#########################################
BEGIN INSTRUCTION
ENABLE = {NO}
NAME   = {fudiv}
VHDL   = {DIVIDER_32b.vhd}
TYPE   = {SEQU}
INPUT  = {2}
OUTPUT = {1}
IMME   = {NO}
POWER  = {YES}
CYCLES = {32}
SLICES = {ML402:(155LUTs,156FFs,119Slices)}
CPATH  = {ML402:(4.444ns)}
END INSTRUCTION
