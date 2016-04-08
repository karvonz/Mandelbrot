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
#define MemoryRead(A) (*(volatile int*)(A))
#define MemoryWrite(A,V) *(volatile int*)(A)=(V)

extern  int  putchar  (int value);
extern  int  puts     (const char *string);
extern  void print_hex(unsigned long num);
extern  char *xtoa(unsigned long num);
extern  unsigned long getnum(void);
extern  int kbhit(void);
extern  int getch(void);


typedef void (*FuncPtr)(void);

extern void ProgramExec();
extern int ReceiveProgram();
extern int LocalRamTester();

unsigned char wait_data()
{
	while( !kbhit() );
   unsigned char ch = getch();
	return ch;
}

#define TIMEOUT (50000000/8)
unsigned char wait_data_with_timeout()
{
	int i;
	for(i=0; i<TIMEOUT; i++)
	{
		if( kbhit() ) return 1;
	}
	return 0;
}

#define TIMEOUT_2 (50000000)
int isStillAlive()
{
	int i;
	unsigned int cpt = 1;
	while( 1 )
	{
		for(i=0; i<TIMEOUT_2; i++){
			cpt *= 2 - 1;
			asm volatile ("nop");
		}
	   puts("  + Processor is running ");
		print_hex( (unsigned int)cpt );
		puts("\r\n");
		cpt += 1;
		if( kbhit() ) return getch();
	}
	return (i-cpt);
}

unsigned int wait_button_action()
{
	while( (MemoryRead(GPIOA_IN) & 0x000F) == 0x00 );
	unsigned int lState = MemoryRead(GPIOA_IN) & 0x0F;
	while( (MemoryRead(GPIOA_IN) & 0x000F) != 0x00 );
	return lState;
}

void show_help()
{
      puts("\nWaiting for binary image linked at 0x10000000\n");
      puts("Other Menu Options:\n");
      puts("1. Memory read word\n");
      puts("2. Memory write word\n");
      puts("3. Memory read byte\n");
      puts("4. Memory write byte\n");
      //puts("6. Receive binary program (X-Modem)\n");
      puts("7. Launch program execution\n");
      puts("8. Still alive procedure\n");
}

void version()
{
   puts("BUILT-IN SELF TEST PROGRAM  v1.03 - ");
	puts(__DATE__); puts(" "); puts(__TIME__); puts("\n");
}

int main()
{
   int ch;
   unsigned long address, value;

   puts("\r\n\r\n\r\n\r\n");
	version();

	//
	// ON TESTE LA MEMOIRE RAM INTERNE (64ko)
	//
	LocalRamTester();

	//////////////////////////////////////////////////////////////////////////////
	//
	//
	//
	//////////////////////////////////////////////////////////////////////////////
	show_help();
   for(;;)
   {
      puts("> ");
      ch = getch();
      address = 0;
      if('0' <= ch && ch <= '5')
      {
         putchar(ch);
         puts("\nAddress in hex> ");
         address = getnum();
         puts("Address = ");
         puts(xtoa(address));
         puts("\n");
      }
      switch(ch)
      {
      case 'h':
      case 'H':
			show_help();
         break;

      case 'V':
      case 'v':
			version();
         break;

      case '1':
         value = MemoryRead(address);
         puts(xtoa(value));
         puts("\n");
         break;

      case '2':
         puts("\nValue in hex> ");
         value = getnum();
         puts(xtoa(value));
         MemoryWrite(address, value);
         break;

      case '3':
         value = *(unsigned char*)address;
         puts(xtoa(value));
         puts("\n");
         break;

      case '4':
         puts("\nValue in hex> ");
         value = getnum();
         puts(xtoa(value));
         *(unsigned char*)address = value;
         break;

      case '7':
		   ProgramExec();
         break;

      case '8':
			isStillAlive();
         break;

      case 0xFF:
			ReceiveProgram();
         break;

		default:
		   puts("=> ERROR (value = "); print_hex( (unsigned int)ch ); puts(")\r\n");
         break;

      }
   }
   return 0;
}

