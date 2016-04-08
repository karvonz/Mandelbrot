#########################################
# PGDC (32b) RESOURCE DECLARATION
#########################################
BEGIN INSTRUCTION
ENABLE = {YES}
NAME   = {rgb2yuv}
VHDL   = {RGB_2_YUV.vhd}
TYPE   = {SEQU}
INPUT  = {1}
OUTPUT = {1}
IMME   = {NO}
POWER  = {YES}
CYCLES = {4}
SLICES = {ML402:(1109LUTs,289FFs,583Slices)}
CPATH  = {ML402:(8.347ns)}
END INSTRUCTION
