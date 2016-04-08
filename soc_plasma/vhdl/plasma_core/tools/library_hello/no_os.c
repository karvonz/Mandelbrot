#include "../plasma.h"

#define MemoryRead(A)     (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)

int putchar(int value)
{
   while((MemoryRead(IRQ_STATUS) & IRQ_UART_WRITE_AVAILABLE) == 0);
   MemoryWrite(UART_WRITE, value);
	//int i;
	//for(i=0; i<65536; i++){ 	asm volatile("nop" : : ); }
   return 0;
}

int puts(const char *string)
{
   while(*string)
   {
      //if(*string == '\n')
      //   putchar('\r');
      putchar(*string++);
   }
   return 0;
}

/*
void print_hex(unsigned long num)
{
   long i;
   unsigned long j;
   for(i = 28; i >= 0; i -= 4) 
   {
      j = (num >> i) & 0xf;
      if(j < 10) 
         putchar('0' + j);
      else 
         putchar('a' - 10 + j);
   }
}

void OS_InterruptServiceRoutine(unsigned int status)
{
   (void)status;
   putchar('I');
}

int kbhit(void)
{
   return MemoryRead(IRQ_STATUS) & IRQ_UART_READ_AVAILABLE;
}

int getch(void)
{
   while(!kbhit()) ;
   return MemoryRead(UART_READ);
}

int memcmp( const void *buffer1, const void *buffer2, unsigned int count )
{
  register const unsigned char *s1 = (const unsigned char*)buffer1;
  register const unsigned char *s2 = (const unsigned char*)buffer2;
  while (count-- > 0)
    {
      if (*s1++ != *s2++)
	  return s1[-1] < s2[-1] ? -1 : 1;
    }
  return 0;
}
*/


