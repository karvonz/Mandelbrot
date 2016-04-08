#/usr/bin/python3

import os
import numpy as np
import sys

print "############################################"
print "Script de conversion bmp => bin" 
print "USAGE: python bmp2txt.py my_file.bmp option" 
print "option = gray OR color"
print "############################################"

#retrieve bmp file name from command line
bmp_filename = sys.argv[1]
option = sys.argv[2]

if(option == "gray" or option == "color"):
  print "option checked"
else :
  print "option should either be gray OR color"
  print "Exiting python script ..."
  exit(0)

base_filename = os.path.splitext(bmp_filename)[0]

#create output file
txt_file = open("pcie_in.txt", 'w')

# if gray level:
if(option=="gray"):
  netpbm_filename = base_filename+".pgm"
  command = "convert "+bmp_filename+ " -set colorspace RGB -colorspace gray -compress none "+netpbm_filename

else : #color
  netpbm_filename = base_filename+".ppm"
  command = "convert "+bmp_filename+ " -compress none "+netpbm_filename

#print command
os.system(command)

# open the intermediate netpbm file (pgm or ppm format depending on the option)
netpbm_file = open(netpbm_filename,"r")

#read the first line
mode = netpbm_file.readline()

(col,row) = netpbm_file.readline().split(' ')

txt_file.write('{0:032b}'.format(int(col)))
txt_file.write("\n")
txt_file.write('{0:032b}'.format(int(row)))
txt_file.write("\n")

netpbm_file.readline()

#parsing values in the file
adata=[]
for line in netpbm_file:
	#adata=line.split()
	for val in line.split():
		adata.append(val)
		#print (int(line,2))
#print adata


#converting the array into a numpy array
data = np.array(adata,dtype=int)

#data = np.array([12, 15, 20, 210, 124, 16, 54, 156, 134, 21, 7, 15, 46, 97, 84, 161])

for x in np.nditer(data):
	txt_file.write(np.binary_repr(x, width=32))
	txt_file.write("\n")

os.system("mv pcie_in.txt ./tb_soc_plasma")

print "le fichier pcie_in.txt a ete genere dans tb_soc_plasma/"
