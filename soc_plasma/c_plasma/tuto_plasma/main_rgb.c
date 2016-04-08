#include "SoPC_Design.h"
#include "Isa_Custom.h"
#include "Coprocessors.h"

#define MemoryRead(A)     (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)

#define RED
//#define CROP
#define FIFO_IN_READ
#define FIFO_OUT_WRITE

//#define DEBUG

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

union t_sliced {
  int   i;
  short s[2];
  char  c[4];
} t_sliced;
    
unsigned char R[16384];
unsigned char G[16384];
unsigned char B[16384];

int main( void )
{
	 puts("starting MAIN execution\n");
	 //unsigned char data[16] = {12, 15, 20, 210, 124, 16, 54, 156, 134, 21, 7, 15, 46, 97, 84, 161}; 

    unsigned short tmp;

	 unsigned char max, min;
	 unsigned short beta;
	 unsigned int data_pack, min_max_pack;
	 unsigned int beta_mini;
	 unsigned char mini, maxi;
	 int i;
	 unsigned int start_c, stop_c;
	 
	 unsigned int col_nb, row_nb, pixel_nb;
	 unsigned int A_row_ix, A_col_ix, B_row_ix, B_col_ix, row, col; 
	 volatile unsigned int dump;
	 A_row_ix = 25;
	 A_col_ix = 50;
	 B_row_ix = 75;
	 B_col_ix = 100;
	 
	 // on récupère le nombre de colonnes dans l'image
	 col_nb = i_read();
	 my_printf("nbre de colonnes dans l'image: ", col_nb);
	 
	 // on récupère le nombre de lignes dans l'image
	 row_nb = i_read();
	 my_printf("nbre de lignes dans l'image: ", row_nb);
	 
	 pixel_nb=col_nb*row_nb;
	 my_printf("nbre de pixel dans l'image: ", pixel_nb);

	 if(pixel_nb > 32768){
		  puts("WARNING :image trop volumineuse, taille max = 32768 octets");		  
	 }
	 
	 
#ifdef CROP
 row=col=i=0;
 
 while( i_empty() == 0 )//tant que la FIFO d'entrée n'est pas vide
  {	 
	 //if the pixel is in the zoom area, we store it
	 if(row < B_row_ix && row > A_row_ix && col < B_col_ix && col > A_col_ix){
		R[i] = i_read();
		G[i] = i_read();
		B[i] = i_read(); 
	   i++;
	 }
	 // otherwise, we dump 
	 else{
		dump = i_read();
		dump = i_read();
		dump = i_read();
	 }
	 col++;
	 if(col >= col_nb){
		col = 0;
		row++;
	 }
  }  
puts("Lecture de la FIFO d'entrée terminée\n");

  col_nb = B_col_ix-A_col_ix;
  my_printf("col_nb cropped: ", col_nb);
  row_nb = B_row_ix-A_row_ix;
  my_printf("row_nb cropped: ", row_nb);
  pixel_nb = row_nb*col_nb;
  my_printf("pixel_nb cropped: ", pixel_nb);
  
  o_write( col_nb);
  o_write( row_nb);
  o_write( 255 );
  for(i=0;i<pixel_nb;i++){ // pour chaque échantillon 
	 o_write( R[i] );
	 o_write( G[i] );
	 o_write( B[i] );
	 //my_printf("dataout", data[i]);
  } 
puts("Ecriture des resultats dans la FIFO de sortie\n");
#endif


  
#ifdef RED
  o_write( col_nb);
  o_write( row_nb);
  o_write( 255 );
  for(i=0;i<pixel_nb;i++){ // pour chaque échantillon 
	 o_write( i_read() );
	 o_write( 0 );
	 o_write( 0 );
	 dump = i_read();
	 dump = i_read();
	 //my_printf("dataout", data[i]);
  } 
  /*while( i_empty() == 0 )//tant que la FIFO d'entrée n'est pas vide
  {	 
	 o_write( i_read());
  }*/  
  
#endif

#ifdef DEBUG
  // Affichage des valeurs de sortie sur la sortie standard
	for(i=0;i<pixel_nb;i++){
		my_printf(" scaled val=> ", data[i]);
	}
#endif

  // arrêt du programme
  puts("Fin du programme\n");
  stop();
}


