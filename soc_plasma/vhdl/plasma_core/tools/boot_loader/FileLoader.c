#include "../plasma.h"

#define DDR_BASE 0x10000000
#define MemoryRead(A) (*(volatile int*)(A))
#define MemoryWrite(A,V) *(volatile int*)(A)=(V)

extern  int  putchar  (int value);
extern  int  puts     (const char *string);
extern  void print_hex(unsigned long num);

extern unsigned char wait_data();

int ReceiveProgram()
{
   //puts("  + STARTING DATA RECEPTION\r\n");
   unsigned char *ptr = (unsigned char*)DDR_BASE;
   int y;

	unsigned char data;
	data = wait_data(); // ON LIT LA DONNEE 0xFF
	if( data != 0xFF )
	{
	   puts("  + ERROR ON DATA (1)\r\n");
	   puts("    - DATA = "); print_hex( (unsigned int)data ); puts("\r\n");
	}
	data = wait_data(); // ON LIT LA DONNEE 0xFF
	if( data != 0xFF ) 
	{
	   puts("  + ERROR ON DATA (2)\r\n");
	   puts("    - DATA = "); print_hex( (unsigned int)data ); puts("\r\n");
	}

	data = wait_data(); // ON LIT LA DONNEE 0xFF
	if( data != 0xFF ) 
	{
	   puts("  + ERROR ON DATA (3)\r\n");
	   puts("    - DATA = "); print_hex( (unsigned int)data ); puts("\r\n");
	}

	unsigned char data1 = wait_data(); // ON LIT LA DONNEE 0xFF
	unsigned char data2 = wait_data(); // ON LIT LA DONNEE 0xFF
	unsigned char data3 = wait_data(); // ON LIT LA DONNEE 0xFF
	unsigned char data4 = wait_data(); // ON LIT LA DONNEE 0xFF

	unsigned int sSize = (data4 << 24) | (data3 << 16) | (data2 << 8) | data1;

   for(y=0; y<sSize; y++){
		unsigned char dataS = wait_data();
		ptr[y] = dataS;
   }
   puts("  + DATA RECEPTION COMPLETE\r\n");
   puts("  + # OF OCTETS : "); print_hex( (unsigned int)sSize ); puts("\r\n");

	return 1;
}

