# The CC_X86 is for compiling tools on your PC.
# The GCC_MIPS is for compiling code on the target.
# Convert_bin changes test.axf into code.txt which is used by the VHDL.
# Convert_bin == "objcopy -I elf32-big -O binary test.axf test.bin"


ifeq ($(LANG),)

# Customize for Windows
# The MIPS gcc compiler must use the cygwin1.dll that came with the compiler.
CC_X86 = cl /O1 /nologo
CP = copy
RM = del
DWIN32 = -DWIN32
BIN_MIPS = ..\gccmips_elf
VHDL_DIR = ..\vhdl
LINUX_PWD   = ../
GCC_MIPS    = $(BIN_MIPS)\gcc $(CFLAGS)
AS_MIPS     = $(BIN_MIPS)\as
LD_MIPS     = $(BIN_MIPS)\ld
DUMP_MIPS   = $(BIN_MIPS)\objdump
CONVERT_BIN = $(LINUX_PWD)convert_bin.exe

else

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

endif

CFLAGS = -O3 -Wall -c -s -funroll-loops -mips1 -mtune=mips1 -msoft-float

all: convert_bin.exe tracehex.exe bintohex.exe ram_image.exe
	@echo make targets = count, opcodes, pi, test, run, tohex,\
	bootldr, toimage, eterm
	
clean:
	-$(RM) *.o *.obj *.map *.lst *.hex *.txt *.exe *.axf

#Same as "objcopy -I elf32-big -O binary test.axf test.bin"
convert_bin.exe: convert.c
	@$(CC_X86) -o convert_bin.exe convert.c

convert_le.exe: convert.c
	@$(CC_X86) -DLITTLE_ENDIAN -o convert_le.exe convert.c

mlite.exe: mlite.c
	@$(CC_X86) -o mlite.exe mlite.c $(DWIN32)

tracehex.exe: tracehex.c
	@$(CC_X86) -o tracehex.exe tracehex.c

bintohex.exe: bintohex.c
	@$(CC_X86) -o bintohex.exe bintohex.c

ram_image.exe: ram_image.c
	@$(CC_X86) -o ram_image.exe ram_image.c

# Terminal program that will download a new image.
# For Linux, use any serial port program at 57600 baud 8-bits;1-stop bit
# This mode does not support Ethernet packet transfers.
eterm: etermip.c
	-@$(CC_X86) -o etermip.exe etermip.c

# Terminal program that will download a new image and supports Ethernet
# traffic over UART.  Get wpcap.lib from http://www.winpcap.org/.
# Requires Windows OS
# Uses wpcap.lib for receiving and transmitting raw Ethernet packets
# Get wpcap.lib from http://www.winpcap.org/.
etermip: etermip.c
	@echo Get wpcap.lib from http://www.winpcap.org/
	-@$(CC_X86) -DUSE_WPCAP -o etermip.exe etermip.c wpcap.lib

nomult.exe: nomult.c
	-@$(CC_X86) -o nomult.exe nomult.c

download: etermip
	@echo Reset board before downloading code
	etermip

main: 
	$(AS_MIPS) -o boot.o ../boot.asm
	$(GCC_MIPS) hello.c
	$(GCC_MIPS) no_os.c 
	$(LD_MIPS) -Ttext 0 -eentry -Map test.map -s -N -o test.axf boot.o hello.o no_os.o 
	-$(DUMP_MIPS) --disassemble test.axf > test.lst
	$(CONVERT_BIN)
	$(CP) code.txt $(VHDL_DIR)


# Run a MIPS opcode simulator
run: mlite.exe
	@$(LINUX_PWD)mlite.exe test.bin 

run_little_endian: mlite.exe
	@$(LINUX_PWD)mlite.exe test.bin L

disassemble: mlite.exe
	$(LINUX_PWD)mlite.exe test.bin BD > test.txt

# Used by Xilinx FPGAs for ram image
toimage:
	$(LINUX_PWD)ram_image.exe ../vhdl/ram_xilinx.vhd ../vhdl/code.txt ../vhdl/ram_image.vhd


