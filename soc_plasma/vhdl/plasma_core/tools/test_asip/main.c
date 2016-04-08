// system include files
//
#include <stdio.h>
#include <stdlib.h>

	inline int instr_mini(int a, int b){
		int res;
		//__asm volatile( "mini %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		__asm volatile( "mini %0, %1, %2 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline int instr_maxi(int a, int b){
		int res;
		//asm volatile ("maxi %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		asm volatile ("maxi %0, %1, %2 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline int instr_pgdc(int a, int b){
		int res;
		//asm volatile ("maxi %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		asm volatile ("pgdc %0, %1, %2 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

int main( int argc, char * argv[] )
{
	int a = 5;
	int b = 13;
	//asm  volatile("nop" : : );
	int e = instr_mini(a,b);
	int d = instr_maxi(a,b);
//	asm  volatile("nop" : : );
//	asm  volatile("nop" : : );
//	asm  volatile("nop" : : );
	int z = e * d;
//	asm  volatile("nop" : : );
//	asm  volatile("nop" : : );
//	int f = instr_pgdc(z,b);
//	int g = instr_pgdc(b,z);
//	asm  volatile("nop" : : );
//	asm  volatile("nop" : : );
//	asm  volatile("nop" : : );
	//int f = a * b;
	//asm  volatile("nop" : : );
	puts("Hello world\n");
	puts("A    = "); print_hex( a ); puts("\n");
	puts("B    = "); print_hex( b ); puts("\n");
	puts("Mini = "); print_hex( e ); puts("\n");
	puts("Maxi = "); print_hex( d ); puts("\n");
//	puts("PGDC = "); print_hex( f ); puts("\n");
//	puts("PGDC = "); print_hex( g ); puts("\n");
//	puts("MULT = "); print_hex( z ); puts("\n");
	//puts("Sum  = "); print_hex( f ); puts("\n");

	asm  volatile("break 1" : : );
   return 1;
}


