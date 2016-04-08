#include "../plasma.h"

#define DDR_BASE 0x10000000
#define MemoryRead(A) (*(volatile int*)(A))
#define MemoryWrite(A,V) *(volatile int*)(A)=(V)

extern  int  putchar  (int value);
extern  int  puts     (const char *string);
extern  void print_hex(unsigned long num);


int test_ram(unsigned char* ptr, unsigned char pattern, unsigned int size)
{
	int i;
  	for(i = 0; i < size; ++i)
   {
      ptr[i] = (unsigned char)pattern;
   }
   for(i = 0; i < size; ++i)
   {
   	if(ptr[i] != pattern){
			return 1;
		}
   }
	return 0;
}


void ShowAddressTesting(unsigned char* ptr, unsigned int size, int state)
{
	unsigned char* adr_start = &ptr[0];
	unsigned char* adr_stop  = &ptr[size-1];
   puts("  + @dr testing (n ko) from 0x");
	print_hex( (unsigned int)adr_start );
	puts(" to 0x");
	print_hex( (unsigned int)adr_stop );
	if( state == 0 )
		puts(" : OK\r\n");
	else
		puts(" : FAILED\r\n");
}


int test_ram_alea(unsigned char* ptr, unsigned int size)
{
	int i;
  	for(i = 0; i < size; ++i)
   {
      ptr[i] = (unsigned char)(i & 0x00FF);
   }
   for(i = 0; i < size; ++i)
   {
		unsigned char ref = (unsigned char)(i & 0x00FF);
   	if(ptr[i] != ref){
			return 1;
		}
   }
	return 0;
}


int LocalRamTester()
{
   int y;
   unsigned char *ptr = (unsigned char*)DDR_BASE;
	unsigned char pattern[]   = {0x00, 0xFF, 0xF0, 0x0F};
	unsigned int  RAM_SPACE   = 64*1024;
	unsigned int  TEST_LENGTH = 4*1024;

	//////////////////////////////////////////////////////////////////////////////
	//
	//
	//
	//////////////////////////////////////////////////////////////////////////////
   puts("- TESTING INTERNAL RAM BEHAVIOR\n");
	int error = 0;
   for(y=0; y<(RAM_SPACE/TEST_LENGTH); y++){ 
		error += test_ram( ptr, pattern[0], TEST_LENGTH);
		error += test_ram( ptr, pattern[1], TEST_LENGTH);
		error += test_ram( ptr, pattern[2], TEST_LENGTH);
		error += test_ram( ptr, pattern[3], TEST_LENGTH);
		error += test_ram_alea( ptr, TEST_LENGTH);
		ptr += TEST_LENGTH;
   }
	if( error == 0 )
	{
   	puts("  + 64kbyte memory is OK\n");
   }
	else
	{
   	puts("  + ERROR with the 64kbyte memory\n");
   }
   return 0;
}

