/*--------------------------------------------------------------------
 * TITLE: Plasma DDR Initialization
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 12/17/05
 * FILENAME: ddr_init.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Plasma DDR Initialization
 *    Supports 64MB (512Mb) MT46V32M16 by default.
 *    For 32 MB and 128 MB DDR parts change AddressLines and Bank shift:
 *    For 32 MB change 13->12 and 11->10.  MT46V16M16
 *    For 128 MB change 13->14 and 11->12. MT46V64M16
 *--------------------------------------------------------------------*/
#include "../plasma.h"

#define DDR_BASE 0x10000000

extern  int  putchar  (int value);
extern  int  puts     (const char *string);
extern  void print_hex(unsigned long num);
typedef void (*FuncPtr)(void);
extern unsigned char wait_data();

void ProgramExec()
{
   FuncPtr funcPtr;
	puts("################# BOOTING THE BINARY CODE... #################\r\n");
	funcPtr = (FuncPtr)0x10000000;
	funcPtr();
	puts("################# COMING BACK FROM PROGRAM.. #################\r\n");
	wait_data();
}

