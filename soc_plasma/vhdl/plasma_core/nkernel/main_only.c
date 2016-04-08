/*--------------------------------------------------------------------
 * TITLE: Plasma Real Time Operating System
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 12/17/05
 * FILENAME: rtos.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Plasma Real Time Operating System
 *    Fully pre-emptive RTOS with support for:
 *       Heaps, Threads, Semaphores, Mutexes, Message Queues, and Timers.
 *    This file tries to be hardware independent except for calls to:
 *       MemoryRead() and MemoryWrite() for interrupts.
 *    Partial support for multiple CPUs using symmetric multiprocessing.
 *--------------------------------------------------------------------*/
#include "../tools/plasma.h"

#define MemoryRead(A)     (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)

void putchar(int value)
{
   while((MemoryRead(IRQ_STATUS) & IRQ_UART_WRITE_AVAILABLE) == 0);
   MemoryWrite(UART_WRITE, value);
	//int i;
	//for(i=0; i<65536; i++){ 	asm volatile("nop" : : ); }
   //return 0;
}

void puts(const char *string)
{
   while((*string) != 0)
   {
      //if(*string == '\n')
      //   putchar('\r');
      putchar(*string++);
   }
   //return 0;
}

int main( void ){
	puts("Hello world !\r\n");
	puts("UART works well...\r\n");
	asm("break 1" : : );
   //UartPrintfCritical("Starting RTOS\n");
   //UartPrintfCritical("Starting UartInit\n");
   //UartPrintfCritical("Starting OS_ThreadCreate\n");
   //UartPrintfCritical("Starting OS_Start\n");
   //UartPrintfCritical("Finishing Main\n");
   return 0;
}

