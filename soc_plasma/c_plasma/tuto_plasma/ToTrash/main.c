#include "SoPC_Design.h"
#include "Isa_Custom.h"
#include "Coprocessors.h"

#define MemoryRead(A)     (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)

/************************************************/
/************************************************/
/* POUR CHOISIR L'ALGO A EXECUTER,              */
/* DECOMMENTER LA LIGNE CORRESPONDANTE          */
/************************************************/
/************************************************/


/************************************************/
// implementation en virgule fixe de l'algo, pas d'optimisation particuliere:

//#define NO_OPT 
/************************************************/



/************************************************/
// Idem NO_OPT + 3 instructions custom : min, max et mise à l'echelle

//#define OPT1
/************************************************/



/************************************************/
// Idem NO_OPT + data packing de 4 donnees char dans un seul int + 1 instruction custom qui calcule le min et le max en même temps.
// lamise à l'echelle est egalement faite sur 4 donnees à la fois

//#define OPT2
/************************************************/



/************************************************/
// 2 coprocesseurs : calcul du min/max et mise à l'echelle

#define OPT3
/************************************************/




/************************************************/
// lecture des donnees d'entree dans un fichier texte via la FIFO du SoC Plasma
// Si ligne commentee => les donnees sont definies dans le programme lui même : unsigned char data[16]= {12, ...

//#define FIFO_IN_READ
//#define FIFO_OUT_WRITE
/************************************************/

/************************************************/
// Pour activer le DEBUG :

#define DEBUG
/************************************************/

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
    
#ifdef FIFO_IN_READ
  unsigned char data[32768];
#else
  unsigned char data[16] = {12, 15, 20, 210, 124, 16, 54, 156, 134, 21, 7, 15, 46, 97, 84, 161}; 
#endif

int main( void )
{
  
    unsigned short tmp;

	 unsigned char max, min;
	 unsigned short beta;
	 unsigned int data_pack, min_max_pack;
	 unsigned int beta_mini;
	 unsigned char mini, maxi;
	 int i;
	 unsigned int start_c, stop_c;
	 
	 unsigned int col_nb, row_nb, pixel_nb;
	 	 
  
#ifdef FIFO_IN_READ

	 // on recupere le nombre de colonnes dans l'image
	 col_nb = i_read();
	 my_printf("nbre de colonnes dans l'image: ", col_nb);
	 
	 // on recupere le nombre de lignes dans l'image
	 row_nb = i_read();
	 my_printf("nbre de lignes dans l'image: ", row_nb);
	 
	 pixel_nb=col_nb*row_nb;
	 my_printf("nbre de pixel dans l'image: ", pixel_nb);

	 if(pixel_nb > 32768){
		  puts("WARNING :image trop volumineuse, taille max = 32768 octets");		  
	 }
	 
 i=0;
 while( i_empty() == 0 )//tant que la FIFO d'entree n'est pas vide
  {	 
	 data[i] = i_read(); // je lis une valeur dans la FIFO d'entree et je la stock dans data[i]
	 i++;
  }  
puts("Lecture de la FIFO d'entree terminee\n");
#else
  pixel_nb = 16;
#endif


  
#ifdef DEBUG
// Affichage des valeurs d'entrees sur la sortie standard
	for(i=0;i<pixel_nb;i++){
		my_printf(" val=> ", data[i]);
	}	
puts("Affichage des valeurs initiales termine\n");
#endif

#ifdef NO_OPT
	// Start timer
	start_c = r_timer();
	
	max = 0;
	min = 255;
	// Calcul MIN/MAX
	for(i=0;i<pixel_nb;i++){
		if(data[i] > max) max = data[i];
		if(data[i] < min) min = data[i];	
	}

	// Calcul du Beta
	beta = 255 << 8; // 255 au format U(8,8)
	beta = beta / (max-min); // U(8,8)/U(8,0) => U(8,8) 
	
	 // Mise à l'echelle
	 for(i=0;i<pixel_nb;i++){
		data[i] = (beta * (data[i] - min)) >> 8;
	 }
	
  // stop timer
	stop_c = r_timer();
	
	my_printf("nbre de cycles : ", stop_c-start_c);

  puts("### section NO_OPT terminee ###\n");
#endif

#ifdef OPT1
  
  // Start timer
	start_c = r_timer();
  
	max = 0;
	min = 255;
	// Calcul MIN/MAX avec instructions custom pour le calcul du min et max
	for(i=0;i<pixel_nb;i++){
		max = isa_custom_1(data[i],max);
		min = isa_custom_2(data[i],min);
	}

	// Calcul du Beta
	beta = 255 << 8; // 255 au format (8,8)
	beta = beta / (max-min); // (8,8)/(8,0) => (8,8) 
	
	// concatenation de beta et min dans un unsigned int
	beta_mini = beta << 16 | min;
	
	 // Mise à l'echelle
	 for(i=0;i<pixel_nb;i++){
		data[i] = isa_custom_3(data[i], beta_mini);
	 }
	
	// stop timer
	stop_c = r_timer();
	
	my_printf("nbre de cycles : ", stop_c-start_c);

  puts("### section OPT1 terminee ###\n");
#endif
	
#ifdef OPT2
	// Start timer
	start_c = r_timer();
   
	// Calcul MIN/MAX
	
	// packing min and max into a single int
	max = 0;
	min = 255;
	unsigned int min_max;
	min_max = min << 8 | max;
	
	// pointer casting: p points to blocks of 4 bytes (= int)
	int* p = (int*)data;
	
	for(i=0;i<pixel_nb;i+=4){
		// packing 4 bytes into a single int
		// update the min and max value using a single instruction
		// SIMD with P=4 bytes processed in parallel
		min_max = isa_custom_4(*p, min_max);	
		p += 1;
   }
   
   // retrieves min and max from the output of the instruction
	min = min_max >> 8;
	max = min_max & 0x000000FF;
	
	// Calcul du Beta
	beta = 255 << 8; // 255 au format (8,8)
	beta = beta / (max-min); // (8,8)/(8,0) => (8,8) 
	
	// Mise à l'echelle
	// packing beta et mini dans une seule variable
	beta_mini = beta << 16 | min;
	
	p = (int*)data;
	
	for(i=0;i<pixel_nb/4;i++){
		*p = isa_custom_5(*p, beta_mini);
		p +=1;
   }
   
	// stop timer
	stop_c = r_timer();
	
	my_printf("nbre de cycles : ", stop_c-start_c);
	
  puts("### section OPT2 terminee ###\n");
#endif
  
#ifdef OPT3

	// Start timer
	start_c = r_timer();
   
	// Calcul MIN/MAX
	
	unsigned int min_max;
	
	// pointer casting: p points to blocks of 4 bytes (= int)
	int* p;
	p = (int*)data;
	
	coproc_reset(COPROC_1_RST);
	for(i=0;i<pixel_nb;i+=4){
		// push 4 bytes in the COPROC_1
		coproc_write(COPROC_1_RW, *p);
		p += 1;
   }  

   // On recupere le min et le max
   min_max = coproc_read(COPROC_1_RW);
	
	// on repositionne le pointeur au debut du tableau de donnees
	p = (int*)data;
	
	coproc_reset(COPROC_2_RST);
	// on envoie le minmax au coproc pour qu'il calcule le beta et le stocke ainsi que le min
	coproc_write(COPROC_2_RW, min_max);
	
	for(i=0;i<pixel_nb;i+=4){
		// push 4 bytes in the COPROC_2
		coproc_write(COPROC_2_RW, *p);
		// pull and store the result
		*p = coproc_read(COPROC_2_RW);
		// move to the next data in the array
		p += 1;
   }

	// stop timer
	stop_c = r_timer();
	
	my_printf("nbre de cycles : ", stop_c-start_c);
	
  puts("### section OPT3 terminee ###\n");
	
	
#endif
  
#ifdef FIFO_OUT_WRITE

  
  o_write( col_nb);
  o_write( row_nb);
  o_write( 255 );
  for(i=0;i<pixel_nb;i++){ // pour chaque echantillon 
	 o_write( data[i] ); // j'ecrie la valeur dans la FIFO de sortie
	 //my_printf("dataout", data[i]);
  } 
puts("Ecriture des resultats dans la FIFO de sortie\n");

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


