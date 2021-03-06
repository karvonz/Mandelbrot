# Makefile permettant de :
# - compiler le code source à exécuter sur le Plasma
# - compiler les fichiers VHDL du SoC Plasma
# - lancer la simulation VHDL du SoC Plasma
# Usage: 
# - make soft : compile l'exécutable avec le compilateur MIPS et génère le fichier .txt correspondant
# - make vhdl : compile les fichiers VHDL du SoC Plasma
# - make simu : lance la simulation VHDL du SoC Plasma
# - make all : fait toutes les étapes précédentes une par une
# - make fpga : make soft + make vhdl + copie le fichier binaire dans le repertoire de synthese
# - make simu_debug : make soft + make vhdl + lancement de la simu modelsim en mode graphique
# - make ppm : permet d'executer le programme sur votre machine linux (attention tous les appels à du materiel isa_custom etc... ne fonctionneront pas)

#MY_PROJECT=ray_tracer_v3
MY_PROJECT=mandelbrot
#MY_PROJECT=filtre
#MY_PROJECT=tuto_plasma
SRC_DIR=Sources
INC_DIR=Includes
SHARED_DIR=shared
C_DIR=../../c_plasma

SHARED_FILES = \
	$(C_DIR)/$(SHARED_DIR)/plasmaSoPCDesign.h\
	$(C_DIR)/$(SHARED_DIR)/plasmaCoprocessors.h\
	$(C_DIR)/$(SHARED_DIR)/plasmaIsaCustom.h\
	$(C_DIR)/$(SHARED_DIR)/plasmaMisc.h\
	$(C_DIR)/$(SHARED_DIR)/plasmaMyPrint.h\
	$(C_DIR)/$(SHARED_DIR)/plasmaFifoInOut.h

SIM_TOP = tbench
OBJDIR = obj

all: vhdl soft simu

debug: vhdl soft simu_debug

fpga:
	# software compilation
	make soft
	# build hardware 
	#make vhdl
	# move the program in the synthesis directory
	cp ../code_bin.txt ../../synthese/

####################################################################################################
#
# ON GENERE LE CODE EXECUTABLE QUE L'ON VA FAIRE TOURNER SUR LE PROCESSEUR PLASMA
#
####################################################################################################

CFLAGS      = -O3 -Wall -c -s -funroll-loops -mips1 -mtune=mips1 -msoft-float -std=c99
GCC_MIPS    = mips-elf-gcc $(CFLAGS)
AS_MIPS     = mips-elf-as
LD_MIPS     = mips-elf-ld
CONVERT_BIN = ../../c_plasma/tools/convert_bin.exe

soft:
	$(AS_MIPS) -o boot.o  ../../c_plasma/shared/boot.asm
	$(AS_MIPS) -o uboot.o ../../c_plasma/shared/uboot.asm
	$(GCC_MIPS) $(C_DIR)/$(SHARED_DIR)/no_os.c -o no_os.o
	$(GCC_MIPS) $(SHARED_FILES)
	$(GCC_MIPS) -DVHDL_SIMULATION $(C_DIR)/$(MY_PROJECT)/$(INC_DIR)/*.h
	$(GCC_MIPS) -DVHDL_SIMULATION $(C_DIR)/$(MY_PROJECT)/$(SRC_DIR)/*.c
	$(GCC_MIPS) -DVHDL_SIMULATION ../../c_plasma/$(MY_PROJECT)/$(SRC_DIR)/main.c
	#$(LD_MIPS) -Ttext 0 -eentry -Map test.map -s -N -o test.axf uboot.o main.o no_os.o *.o
	$(LD_MIPS) -Ttext 0 -eentry -Map test.map -s -N -o test.axf boot.o main.o no_os.o #raymath.o raymathfix.o raylight.o rayplane.o raysphere.o rayintersect.o rayobject.o rayrender.o
	#$(LD_MIPS) -Ttext 0 -eentry -Map test.map -s -N -o test.axf boot.o main.o no_os.o
	# raymath.o raymathfix.o raylight.o rayplane.o raysphere.o rayintersect.o rayobject.o rayrender.o

	$(CONVERT_BIN)
	rm $(C_DIR)/$(SHARED_DIR)/*.gch
	rm $(C_DIR)/$(MY_PROJECT)/$(INC_DIR)/*.gch
	cp code_bin.txt ..

ppm:
	g++ -c $(C_DIR)/$(MY_PROJECT)/$(INC_DIR)/*.h
	g++ -c $(C_DIR)/$(MY_PROJECT)/$(SRC_DIR)/*.c
	g++ -c ../../c_plasma/$(MY_PROJECT)/$(SRC_DIR)/main.c
	#g++ -o ray_trace main.o raymath.o raymathfix.o raylight.o rayplane.o raysphere.o rayintersect.o rayobject.o rayrender.o

####################################################################################################
#
# ON GENERE LE MODELE SIMULABLE DU PROCESSEUR AVEC MODELSIM
#
####################################################################################################

NAME=main

workdir:
	mkdir -p $(OBJDIR)

GENE_DIR = ../../vhdl/dedicated
VHDL_DIR = ../../vhdl/plasma_core/vhdl
VHDL_CUSTOM_DIR = ../../vhdl/custom/$(MY_PROJECT)
PROJ_VHDL = \
	$(VHDL_DIR)/cam/cam_pkg.vhd\
	$(VHDL_CUSTOM_DIR)/Shared.vhd \
	$(VHDL_DIR)/ims/conversion.vhd \
	$(VHDL_DIR)/ims/txt_util.vhd  \
	$(VHDL_DIR)/mlite_pack.vhd \
	$(VHDL_DIR)/plasma_3e.vhd \
	$(VHDL_DIR)/ddr_ctrl.vhd \
	$(VHDL_DIR)/memory_64k.vhd \
	$(VHDL_DIR)/simulation/txt_util.vhd \
	$(VHDL_DIR)/ram_boot_for_simu.vhd \
	$(VHDL_DIR)/simulation/pcie_in.vhd \
	$(VHDL_DIR)/simulation/pcie_out.vhd \
	$(VHDL_DIR)/simulation/pcie_cmp.vhd \
	$(VHDL_DIR)/uart.vhd \
	$(VHDL_DIR)/eth_dma.vhd \
	$(VHDL_DIR)/mlite_cpu.vhd \
	$(VHDL_DIR)/alu.vhd \
	$(VHDL_DIR)/bus_mux.vhd \
	$(VHDL_DIR)/control.vhd \
	$(VHDL_DIR)/disassembler.vhd \
	$(VHDL_DIR)/mem_ctrl.vhd \
	$(VHDL_DIR)/mult.vhd \
	$(VHDL_DIR)/pipeline.vhd \
	$(VHDL_DIR)/pc_next.vhd \
	$(VHDL_DIR)/reg_bank.vhd \
	$(VHDL_DIR)/shifter.vhd \
	$(VHDL_DIR)/dma_engine.vhd \
	$(VHDL_DIR)/ims/conversion.vhd \
	$(VHDL_CUSTOM_DIR)/function_1.vhd \
	$(VHDL_CUSTOM_DIR)/function_2.vhd \
	$(VHDL_CUSTOM_DIR)/function_3.vhd \
	$(VHDL_CUSTOM_DIR)/function_4.vhd \
	$(VHDL_CUSTOM_DIR)/function_5.vhd \
	$(VHDL_CUSTOM_DIR)/function_6.vhd \
	$(VHDL_CUSTOM_DIR)/function_7.vhd \
	$(VHDL_CUSTOM_DIR)/function_8.vhd \
	$(VHDL_CUSTOM_DIR)/function_9.vhd \
	$(VHDL_CUSTOM_DIR)/function_10.vhd \
	$(VHDL_CUSTOM_DIR)/function_11.vhd \
	$(VHDL_CUSTOM_DIR)/function_12.vhd \
	$(VHDL_CUSTOM_DIR)/function_13.vhd \
	$(VHDL_CUSTOM_DIR)/function_14.vhd \
	$(VHDL_CUSTOM_DIR)/function_15.vhd \
	$(VHDL_CUSTOM_DIR)/function_16.vhd \
	$(VHDL_CUSTOM_DIR)/function_17.vhd \
	$(VHDL_CUSTOM_DIR)/function_18.vhd \
	$(VHDL_CUSTOM_DIR)/function_19.vhd \
	$(VHDL_CUSTOM_DIR)/coproc_1.vhd \
	$(VHDL_CUSTOM_DIR)/coproc_2.vhd \
	$(VHDL_CUSTOM_DIR)/coproc_3.vhd \
	$(VHDL_CUSTOM_DIR)/coproc_4.vhd \
	$(VHDL_DIR)/ims/sequ_alu_1.vhd \
	$(VHDL_DIR)/vgd_bitmap_640x480.vhd \
	$(VHDL_DIR)/cache.vhd \
	$(VHDL_DIR)/ims/comb_alu_1.vhd \
	$(VHDL_DIR)/plasma.vhd

clean:
	rm -rf *.o *.cf $(OBJDIR) tb *.vcd main $(SIM_TOP) *.ghw
	rm -f *.bit *.bgn *_pad.txt *_pad.csv *.xpi *.srp *.ngc *.par
	rm -f *.lst *.ngd *.ngm *.pcf *.mrp *.unroutes *.pad
	rm -f *.bld *.ncd *.twr *.drcvlib
	rm -rf xst $(NAME).prj
	rm -rf generated

vhdl: workdir
	vlib work
	vmap work work
	vcom -quiet  -93  -work work $(PROJ_VHDL)
	vcom -quiet  -93  -work work tbench.vhd

####################################################################################################
#
# ON LANCE LA SIMULATION DU MODELE VHDL DU PROCESSEUR
#
####################################################################################################

simu:
	cp code_bin.txt ..
	vsim tbench -c -quiet -do "set NumericStdNoWarnings 1; set StdArithNoWarnings 1; run -all; exit"
	rm ../code_bin.txt
	cmp pcie_out.txt $(MY_PROJECT)_ref.txt

simu_debug:
	cp code_bin.txt ..
	vsim tbench -quiet -do "set NumericStdNoWarnings 1; set StdArithNoWarnings 1;"

dasm:
	mips-elf-gcc -O3 -Wall -c -s -funroll-loops -mips1 -mtune=mips1 -msoft-float -std=c99 -DVHDL_SIMULATION ../../c_plasma/ray_tracer_v3/Sources/main.c -S
	vi main.s
