#include "SoPC_Design.h"
#include "Isa_Custom.h"
#include "Coprocessors.h"

void my_printf(char* str, int value)
{
  puts(str); print_int( value ); puts("\n");
}

void my_printfh(char* str, int* ptr, int value)
{
  puts(str); print_hex( ptr ); puts(" = "); print_int( value ); puts("\n");
}

void my_printh(int* ptr)
{
  print_hex( ptr ); puts(" = "); print_hex( *ptr ); puts("\n");
}


inline void stop(){
	__asm volatile ( "break 1\n\t" : : );
}

inline void nop(){
	__asm volatile ( "nop\n\t" : : );
}

int main( void )
{

  unsigned short int data[16] = {12, 15, 20, 210, 124, 16, 54, 156, 134, 21, 7, 15, 46, 97, 84, 161}; 
  unsigned int i;
  print_timer();
  print_timer();
  print_timer();
	unsigned int max = 0;
	unsigned int min = 255;
	unsigned int beta;


	 while( ! i_empty() ){
		int value = i_read();
		o_write( value );
	 }

// Affichage des valeurs d'entrées sur la sortie standard
	for(i=0;i<16;i++){
		my_printf(" val=> ", data[i]);
	}
	
// Affichage de la valeur du timer
	print_timer();
	  
// Calcul MIN/MAX
	for(i=0;i<16;i++){
		if(data[i] > max) max = data[i];
		if(data[i] < min) min = data[i];
	}

// Calcul du Beta
	beta = 255 << 8; // 255 au format (8,8)
	beta = beta / (max-min); // (8,8)/(8,0) => (8,8) 

// Mise à l'échelle
	for(i=0;i<16;i++){
		data[i] = (beta * (data[i] - min)) >> 8;		
	}

// Affichage de la valeur du timer
  print_timer();

// Affichage des valeurs de sortie sur la sortie standard
	for(i=0;i<16;i++){
		my_printf(" val=> ", data[i]);
	}

  print_timer();
  
  //while( 1 );
  puts("MAIN FINISHED\n");stop();
}


