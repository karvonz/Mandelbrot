# The CC_X86 is for compiling tools on your PC.
# The GCC_MIPS is for compiling code on the target.
# Convert_bin changes test.axf into code.txt which is used by the VHDL.
# Convert_bin == "objcopy -I elf32-big -O binary test.axf test.bin"

# Customized for Linux
# See http://www.opencores.com/projects.cgi/web/mips/linux_tools.htm
CC_X86 = gcc -Wall -O -g
CP = cp
RM = rm -rf 
DWIN32 =
BIN_MIPS = 
VHDL_DIR    = ../../vhdl
LINUX_PWD   = ../
GCC_MIPS    = $(BIN_MIPS)mips-elf-gcc $(CFLAGS)
AS_MIPS     = $(BIN_MIPS)mips-elf-as
LD_MIPS     = $(BIN_MIPS)mips-elf-ld
DUMP_MIPS   = $(BIN_MIPS)mips-elf-objdump
CONVERT_BIN = $(LINUX_PWD)convert_bin.exe
#CONVERT_BIN = $(BIN_MIPS)mips-elf-objcopy -I elf32-big -O binary test.axf test.bin


CFLAGS = -O3 -Wall -c -s -funroll-loops -mips1 -mtune=mips1 -msoft-float -finline-functions

all: convert_bin.exe tracehex.exe bintohex.exe ram_image.exe
	@echo make targets = count, opcodes, pi, test, run, tohex,\
	bootldr, toimage, eterm
	
clean:
	-$(RM) *.o *.obj *.map *.lst *.hex *.txt *.exe *.axf *.bin *.exec

main: 
	$(GCC_MIPS) pcie_loop.c
	$(GCC_MIPS) no_os.c 
	$(LD_MIPS) -Ttext 0x10000000 -eentry -Map test.map -s -N -o test.axf pcie_loop.o no_os.o
	-@$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	../exec_generator
	rm test.bin
	mv test.exec app_pcie_loop.bin

