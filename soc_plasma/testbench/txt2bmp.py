#/usr/bin/python3

import os
import numpy as np
import sys

print "##################################################################"
print "Script de conversion bin => pgm/ppm" 
print "USAGE: python txt2bmp.py my_file.bmp option" 
print "option = gray OR color"
print "##################################################################"

#retrieve output bmp file name from command line
bmp_filename = sys.argv[1]
option = sys.argv[2]

if(option == "gray" or option == "color"):
  print "option checked"
else :
  print "option should either be gray OR color"
  print "Exiting python script ..."
  exit(0)

base_filename = os.path.splitext(bmp_filename)[0]

# if gray level:
if(option=="gray"):
  netpbm_filename = base_filename+".pgm"
else : #color
  netpbm_filename = base_filename+".ppm"

netpbm_file = open(netpbm_filename, 'w')

# open the input file
txt_file = open("./tb_soc_plasma/pcie_out.txt","r")

col = int(txt_file.readline(),2)
row = int(txt_file.readline(),2)
max_val=int(txt_file.readline(),2)

# if gray level:
if(option=="gray"):
  netpbm_file.write("P2\n")
else : #color
  netpbm_file.write("P3\n")

netpbm_file.write("%d %d\n" % (col, row))
netpbm_file.write("%d\n" % (max_val))
#parsing values in the file

count=0
for line in txt_file:
	if count == 30:
		netpbm_file.write(str(int(line,2))+"\n")
		count = 0
	else:
		netpbm_file.write(str(int(line,2))+" "),
		count+=1
		
command = "convert "+netpbm_filename+" "+bmp_filename
print command
os.system(command)

