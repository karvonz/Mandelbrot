#include <stdio.h>
#include <stdbool.h>

#include "../../shared/plasmaCoprocessors.h"
#include "../../shared/plasmaIsaCustom.h"
#include "../../shared/plasmaMisc.h"
#include "../../shared/plasmaSoPCDesign.h"
#include "../../shared/plasmaMyPrint.h"
#include "../../shared/plasmaFifoInOut.h"

#include "../Includes/filtrage.h"

#define MemoryRead(A)     (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)

#define ENABLE_2D
/************************************************/
// lecture des donnees d'entree dans un fichier texte via la FIFO du SoC Plasma
// Si ligne commentee => les donnees sont definies dans le programme lui même : unsigned char data[16]= {12, ...
#define FIFO_IN_READ
/************************************************/

#ifdef FIFO_IN_READ
  unsigned char data[32768];
  unsigned char data_sortie[32768];
#else
  unsigned char data[25] = {12, 15, 20, 210, 129, 124, 16, 54, 156, 17, 134, 21, 7, 15, 22, 46, 97, 84, 161, 65, 99, 128, 134, 201, 164};
  unsigned char data_sortie[32768];
#endif
  
  
int main(int argc, char ** argv) {

  	 /**************** VARIABLES ********************/
	 int i, j;
	 unsigned int start_c, stop_c;
	 unsigned int col_nb, row_nb, pixel_nb;

	 /*************************************************************/

#ifdef FIFO_IN_READ

	 LoadImage(&col_nb, &row_nb, &pixel_nb, data);
	 
#else
 
	 pixel_nb = 25;
	 col_nb = 5;
	 row_nb = 5;
	 
#endif

#ifdef DEBUG
	 // Affichage des valeurs d'entrees sur la sortie standard
	 for(i=0;i<pixel_nb;i++){
		my_printf(" val=> ", data[i]);
	 }
	 puts("Affichage des valeurs initiales termine\n");
#endif
	 
	 // Start timer
	 start_c = r_timer(); //read_Timer

	 // filtrage
	 //filtre_1(data, col_nb, row_nb, data_sortie);
	 //filtre_1_opt(data, col_nb, row_nb, data_sortie);
	 filtre_3_opt(data, col_nb, row_nb, data_sortie);
	 // stop timer
	 stop_c = r_timer();

	 my_printf("nbre de cycles : ", stop_c-start_c);
	 
	 StoreImage(col_nb-2, row_nb-2, data_sortie);
	 
#ifdef DEBUG
	 // Affichage des valeurs d'entrees sur la sortie standard
	 for(i=0;i<pixel_nb;i++){
		  my_printf(" dataout=> ", data_sortie[i]);
	 }
	 puts("Affichage des valeurs de sortie termine\n");
#endif

	 // arrêt du programme
	 puts("Fin du programme\n");
	 stop();
	 return 1;
}