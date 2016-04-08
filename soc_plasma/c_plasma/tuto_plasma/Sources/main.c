#include <stdio.h>
#include <stdbool.h>

#include "../../shared/plasmaCoprocessors.h"
#include "../../shared/plasmaIsaCustom.h"
#include "../../shared/plasmaMisc.h"
#include "../../shared/plasmaSoPCDesign.h"
#include "../../shared/plasmaMyPrint.h"
#include "../../shared/plasmaFifoInOut.h"

#include "../Includes/scale.h"

#define MemoryRead(A)     (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)
#define DEBUG
#define ENABLE_2D
#define VGA

/************************************************/
// lecture des donnees d'entree dans un fichier texte via la FIFO du SoC Plasma
// Si ligne commentee => les donnees sont definies dans le programme lui même : unsigned char data[16]= {12, ...
//#define FIFO_IN_READ
/************************************************/

#ifdef FIFO_IN_READ
  unsigned char data[32768];
#else
  unsigned char data[16] = {12, 15, 20, 210, 124, 16, 54, 156, 134, 21, 7, 15, 46, 97, 84, 161};
#endif
  
  
int main(int argc, char ** argv) {

  	 /**************** VARIABLES ********************/
	 int i, j;
	 unsigned int start_c, stop_c;
	 unsigned int col_nb, row_nb, pixel_nb;
	 unsigned short tmp;	 
	 /*************************************************************/

#ifdef FIFO_IN_READ

	 LoadImage(&col_nb, &row_nb, &pixel_nb, data);
	 
#else
 
	 pixel_nb = 16;
	 col_nb = 4;
	 row_nb = 4;
	 
#endif
  
#ifdef DEBUG
// Affichage des valeurs d'entrees sur la sortie standard
	for(i=0;i<pixel_nb;i++){
		my_printf(" val=> ", data[i]);
	}	
puts("Affichage des valeurs initiales termine\n");
#endif

	// Start timer
	start_c = r_timer();
	
	scale_no_opt(data, pixel_nb);
	//scale_opt1(data, pixel_nb);
	//scale_opt2(data, pixel_nb);
	//scale_opt3(data, pixel_nb);
	
  // stop timer
	stop_c = r_timer();
	
	my_printf("nbre de cycles : ", stop_c-start_c);

   puts("### section NO_OPT terminee ###\n");

   StoreImage(col_nb, row_nb, data);
  
   puts("Ecriture des resultats dans la FIFO de sortie\n");


#ifdef DEBUG
  // Affichage des valeurs de sortie sur la sortie standard
	for(i=0;i<pixel_nb;i++){
		my_printf(" scaled val=> ", data[i]);
	}
#endif

#ifdef VGA
  coproc_reset(COPROC_4_RST);
  int data_concat;
  for(i=0;i<307200;i++){
		data_concat = 130;
		coproc_write(COPROC_4_RW, data_concat);
		my_printf(" toVGA => ", data_concat);
		my_printf(" from copro => ",coproc_read(COPROC_4_RW));
	}
#endif

  // arrêt du programme
  puts("Fin du programme 6\n");
  stop();
}


