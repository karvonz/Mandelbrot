#include "../plasma.h"

#define MemoryRead(A)     (*(volatile unsigned int*)(A))
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

/*
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


char *strcpy2(char *s, const char *t)
{
   char *tmp=s;
   while((int)(*s++=*t++)) ;
   return(tmp);
}

void itoa2(long n, char *s, int base, long *digits)
{
	print_hex( *digits );
   long i,j,sign;
   unsigned long n2;
   char number[20];
   for(i=0;i<15;++i) {
      number[i]=' ';
   }
   number[15]=0;
   if(n>=0 || base!=10) {
      sign = 1;
   } else {
      sign = -1;
   }
   n2 = n*sign;
   for(j=14;j>=0;--j) {
      i=n2%base;
      n2/=base;
      number[j]=i<10?'0'+i:'a'+i-10;
      if(n2==0&&15-j>=*digits) break;
   } 
   if(sign == -1) {
      number[--j]='-';
   }
   if(*digits==0 || *digits<15-j) {
      strcpy2(s,&number[j]);
      *digits=15-j;
   } else {
      strcpy2(s,&number[15-*digits]);
   }
}

int buffer[16];

void itoa3(int n, int digits)
{
	int i;
	for(i=0; i<digits; i++){
		buffer[i] = '0' + (n%10);
		n   /= 10;
	}
	buffer[digits] = 0;
}

#define abs(a) ((a<0)?-a:a)

void print(long num, long digits)
{
    int i;
    if( num < 0 ) puts("-");
    itoa3(abs(num), digits);
	for(i=0; i<digits; i++){
		putchar(buffer[digits-i-1]);
	}
}              


void print_int(int _num)
{
	int copy = abs(_num);
	int size = 0;
	while( copy != 0 ){
		size += 1;
		copy /= 10;
	}
	size = (size != 0)?size:1;
	
	int sign = 0;
	//print_hex( size ); puts(" "); print_hex( _num ); puts(" ");
	print(_num, sign + size);
}
