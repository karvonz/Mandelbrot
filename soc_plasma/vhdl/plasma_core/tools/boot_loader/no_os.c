#include "../plasma.h"

#define MemoryRead(A) (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)


int putchar(int value)
{
   while((MemoryRead(IRQ_STATUS) & IRQ_UART_WRITE_AVAILABLE) == 0)
      ;
   MemoryWrite(UART_WRITE, value);
   return 0;
}

int puts(const char *string)
{
   while(*string)
   {
      if(*string == '\n')
         putchar('\r');
      putchar(*string++);
   }
   return 0;
}

void print_hex(unsigned int num)
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

#ifdef MEMCMP
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
#endif

static char buf[12];
char *xtoa(unsigned long num)
{
   int i, digit;
   buf[8] = 0;
   for (i = 7; i >= 0; --i)
   {
      digit = num & 0xf;
      buf[i] = digit + (digit < 10 ? '0' : 'A' - 10);
      num >>= 4;
   }
   return buf;
}


unsigned long getnum(void)
{
   int i;
   unsigned long ch, ch2, value=0;
   for(i = 0; i < 16; )
   {
      ch = ch2 = getch();
      if(ch == '\n' || ch == '\r')
         break;
      if('0' <= ch && ch <= '9')
         ch -= '0';
      else if('A' <= ch && ch <= 'Z')
         ch = ch - 'A' + 10;
      else if('a' <= ch && ch <= 'z')
         ch = ch - 'a' + 10;
      else if(ch == 8)
      {
         if(i > 0)
         {
            --i;
            putchar(ch);
            putchar(' ');
            putchar(ch);
         }
         value >>= 4;
         continue;
      }
      putchar(ch2);
      value = (value << 4) + ch;
      ++i;
   }
   putchar('\r');
   putchar('\n');
   return value;
}

