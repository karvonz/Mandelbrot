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
*/
/*
int kbhit(void)
{
   return MemoryRead(IRQ_STATUS) & IRQ_UART_READ_AVAILABLE;
}
*/
/*
int getch(void)
{
   while(!kbhit()) ;
   return MemoryRead(UART_READ);
}
*/
/*
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
/*
char *strcpy2(char *s, const char *t)
{
   char *tmp=s;
   while((int)(*s++=*t++)) ;
   return(tmp);
}

static void itoa2(long n, char *s, int base, long *digits)
{
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
*/
/*
void print(long num, long base, long digits)
{
   char *ptr,buffer[128];
   itoa2(num,buffer,base,&digits);
   ptr=buffer;
   while(*ptr) {
      putchar(*ptr++);
      if(ptr[-1]=='\n') *--ptr='\r';
   }
}              
*/
/*
void print_int(int _num)
{
	int sign = 0;//(_num < 0);	
	//if(num < 0) puts( "-" );
	int num  = (sign) ? -_num : _num;
	if( (num >=   0) && (num <   10) ){
		print(_num, 10, sign + 1);
   }else if( (num >     9) && (num <   100) ){
		print(_num, 10, sign + 2);
   }else if( (num >    99) && (num <  1000) ){
		print(_num, 10, sign + 3);
   }else if( (num >   999) && (num <  10000) ){
		print(_num, 10, sign + 4);
   }else if( (num >  9999) && (num < 100000) ){
		print(_num, 10, sign + 5);
	}else{
		print(_num, 10, 12);
	}
}              
void print_fft_data(char *txt, int v1, int v2)
{
	puts(txt);
	puts(" ");
	print_int( v1 );
	puts(" - ");
	print_int( v2 );
	puts("\n");
}

void print_with_int(char *txt, int v1)
{
	puts(txt);
	print_int( v1 );
	puts("\n");
}


void testing(int v1, int v2, int v3, int v4)
{
	puts("(");
	print_int( v1 );
	puts(", ");
	print_int( v2 );
	puts(") <=> (");
	print_int( v3 );
	puts(", ");
	print_int( v4 );
	puts(")\n");
}
*/

