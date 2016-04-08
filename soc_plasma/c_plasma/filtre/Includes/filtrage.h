 #include "../../shared/plasmaCoprocessors.h"


void filtre_1(char* data, int largeur, int hauteur, char* data_sortie)
{
	 int cpt_out, tmp_i;
	 int x,y;
	 unsigned char p0, p1, p2, p3, p4, p5, p6, p7, p8;
	 int coef[9];
	 int alpha, beta;
		
	 coef[0] = -1;	 coef[1] = -1;	 coef[2] =  0;
	 coef[3] = -1;	 coef[4] =  0;	 coef[5] = +1;
	 coef[6] =  0;	 coef[7] = +1;	 coef[8] = +1;

	 alpha = 1; // facteur de ponderation
	 beta = 128; // offset
		  
	 cpt_out = 0;

	 for(y=1; y<hauteur-1; y++){
		  for(x=1; x<largeur-1; x++){

				// on récupère les 9 pixels auxquels il fait appliquer le masque
				p0 = data[(y-1) * largeur + x - 1];
				p1 = data[(y-1) * largeur + x    ];
				p2 = data[(y-1) * largeur + x + 1];
				p3 = data[ y    * largeur + x - 1];
				p4 = data[ y    * largeur + x    ];
				p5 = data[ y    * largeur + x + 1];
				p6 = data[(y+1) * largeur + x - 1];
				p7 = data[(y+1) * largeur + x    ];
				p8 = data[(y+1) * largeur + x + 1];

				// on applique le masque
				tmp_i = coef[0]*p0 + coef[1]*p1 + coef[2]*p2 +
						  coef[3]*p3 + coef[4]*p4 + coef[5]*p5 +
						  coef[6]*p6 + coef[7]*p7 + coef[8]*p8;
						  
				// on applique une ponderation (alpha) et un offset (beta)
				tmp_i = alpha * (tmp_i+beta);
				
				// on tronque les valeurs obtenues pour garantir qu'elles se trouvent dans la plage 0-255
				if(tmp_i > 255){ // troncature à 255
					 data_sortie[cpt_out] = 255;
				}
				else if(tmp_i < 0){ // troncature à 0
					 data_sortie[cpt_out] = 0;
				}
				else{
					 data_sortie[cpt_out] = (unsigned char)tmp_i;
				}				
				cpt_out++;
		  }
	 }
}

void filtre_2(char* data, int largeur, int hauteur, char* data_sortie)
{
	 int cpt_out, tmp_i;
	 int x,y;
	 unsigned char *pt0, *pt1, *pt2, *pt3, *pt4, *pt5, *pt6, *pt7, *pt8;
	 int coef[9];
	 int alpha, beta;
 	 unsigned int op_a, op_b;
		
	 coef[0] = -1;	 coef[1] = -1;	 coef[2] =  0;
	 coef[3] = -1;	 coef[4] =  0;	 coef[5] = +1;
	 coef[6] =  0;	 coef[7] = +1;	 coef[8] = +1;

	 alpha = 1; // facteur de ponderation
	 beta = 128; // offset
		  
	 cpt_out = 0;

	 for(y=1; y<hauteur-1; y++){
		  pt0 = data  + 0 + largeur * (y-1);
		  pt1 = data  + 1 + largeur * (y-1);
		  pt2 = data  + 2 + largeur * (y-1);

		  pt3 = data  + 0 + largeur * (y);
		  pt4 = data  + 1 + largeur * (y);
		  pt5 = data  + 2 + largeur * (y);

		  pt6 = data  + 0 + largeur * (y+1);
		  pt7 = data  + 1 + largeur * (y+1);
		  pt8 = data  + 2 + largeur * (y+1);

		  for(x=1; x<largeur-1; x++){
			
				tmp_i = coef[0]*(*pt0) + coef[1]*(*pt1) + coef[2]*(*pt2) +
						  coef[3]*(*pt3) + coef[4]*(*pt4) + coef[5]*(*pt5) +
						  coef[6]*(*pt6) + coef[7]*(*pt7) + coef[8]*(*pt8);
				tmp_i = alpha * (tmp_i+beta);
				
				//tmp_i = -1*(*pt0) -1*(*pt1) -1* (*pt3) + (*pt5) + (*pt7) + (*pt8) + 128;

				pt0++; pt1++; pt2++; pt3++; pt4++; pt5++; pt6++; pt7++; pt8++;					

				if(tmp_i > 255)
				data_sortie[cpt_out] = 255;
				else if (tmp_i < 0)
				data_sortie[cpt_out] = 0;
				else
				data_sortie[cpt_out] = (unsigned char)tmp_i;
				
				cpt_out++;

		  }
	 }        
}



void filtre_2_opt(char* data, int largeur, int hauteur, char* data_sortie)
{
	 int cpt_out, tmp_i;
	 int x,y;
	 unsigned char *pt0, *pt1, *pt2, *pt3, *pt4, *pt5, *pt6, *pt7, *pt8;
	 int coef[9];
	 int alpha, beta;
 	 unsigned int op_a, op_b;
		
	 coef[0] = -1;	 coef[1] = -1;	 coef[2] =  0;
	 coef[3] = -1;	 coef[4] =  0;	 coef[5] = +1;
	 coef[6] =  0;	 coef[7] = +1;	 coef[8] = +1;

	 alpha = 1; // facteur de ponderation
	 beta = 128; // offset
		  
	 cpt_out = 0;

	 for(y=1; y<hauteur-1; y++){
		  pt0 = data  + 0 + largeur * (y-1);
		  pt1 = data  + 1 + largeur * (y-1);
		  pt2 = data  + 2 + largeur * (y-1);

		  pt3 = data  + 0 + largeur * (y);
		  pt4 = data  + 1 + largeur * (y);
		  pt5 = data  + 2 + largeur * (y);

		  pt6 = data  + 0 + largeur * (y+1);
		  pt7 = data  + 1 + largeur * (y+1);
		  pt8 = data  + 2 + largeur * (y+1);

		  for(x=1; x<largeur-1; x++){
			 /*op_a = (*pt0)<<24|(*pt1)<<16|(*pt3)<<8|(*pt5);
			 op_b = (*pt7)<<8|(*pt8);*/

			
				//tmp_i = coef[0]*p0 + coef[1]*p1 + coef[2]*p2 +
				//		  coef[3]*p3 + coef[4]*p4 + coef[5]*p5 +
				//		  coef[6]*p6 + coef[7]*p7 + coef[8]*p8;
				tmp_i = -1*(*pt0) -1*(*pt1) -1* (*pt3) + (*pt5) + (*pt7) + (*pt8) + 128;

				pt0++; pt1++; pt2++; pt3++; pt4++; pt5++; pt6++; pt7++; pt8++;


				if(tmp_i > 255)
				data_sortie[cpt_out] = 255;
				else if (tmp_i < 0)
				data_sortie[cpt_out] = 0;
				else
				data_sortie[cpt_out] = (unsigned char)tmp_i;
				
				/*data_sortie[cpt_out] = isa_custom_8(op_a,op_b);
				pt0++; pt1++; pt2++; pt3++; pt4++; pt5++; pt6++; pt7++; pt8++;*/
				cpt_out++;

		  }
	 }        
}

void filtre_1_opt(char* data, int largeur, int hauteur, char* data_sortie)
{
	 int cpt_out, tmp_i, tmp_ibis;
	 int x,y;
	 unsigned char p0, p1, p2, p3, p4, p5, p6, p7, p8;
	 unsigned int start_sat, stop_sat, start_load, stop_load, start_compute, stop_compute;
	 unsigned int op_a, op_b;
	 
	 cpt_out = 0;

	 for(y=1; y<hauteur-1; y++){
		  for(x=1; x<largeur-1; x++){

				// on récupère les 9 pixels auxquels il fait appliquer le masque
				//start_load = r_timer();
				p0 = data[(y-1) * largeur + x - 1];
				p1 = data[(y-1) * largeur + x    ];
				p3 = data[ y    * largeur + x - 1];
				p5 = data[ y    * largeur + x + 1];
				p7 = data[(y+1) * largeur + x    ];
				p8 = data[(y+1) * largeur + x + 1];
				//stop_load = r_timer();
				
				// on applique le masque
				//start_compute = r_timer();
				op_a = p0<<24|p1<<16|p3<<8|p5;
				op_b = p7<<8|p8;
				//my_printf("op_a: ", op_a);
				//my_printf("op_b: ", op_b);
				
				//tmp_i = -p0-p1-p3+p5+p7+p8+128;
				//tmp_ibis = isa_custom_7(op_a,op_b);
				/*if(tmp_i != tmp_ibis)
				{
					 my_printf("erreur ibis ", tmp_ibis);
					 my_printf("tmp_i = ", tmp_i);
				}*/
				//stop_compute = r_timer();
				
				//start_sat = r_timer();
				// on tronque les valeurs obtenues pour garantir qu'elles se trouvent dans la plage 0-255
				//data_sortie[cpt_out] = isa_custom_6(tmp_ibis,0);
				data_sortie[cpt_out] = isa_custom_8(op_a,op_b);
				/*if(tmp_i > 255){ // troncature à 255
					 data_sortie[cpt_out] = 255;
				}
				else if(tmp_i < 0){ // troncature à 0
					 data_sortie[cpt_out] = 0;
				}
				else{
					 data_sortie[cpt_out] = (unsigned char)tmp_i;
				}*/
				/*stop_sat = r_timer();
				my_printf("duree load: ", stop_load-start_load);
 				my_printf("duree compute: ", stop_compute-start_compute);
 				my_printf("duree saturation: ", stop_sat-start_sat);*/
 
				cpt_out++;
		  }
	 }
}



void filtre_3_opt(char* data, int largeur, int hauteur, char* data_sortie)
{
	 int cpt_out, tmp_i;
	 int x,y;
	 unsigned char *pt0, *pt1, *pt2, *pt3, *pt4, *pt5, *pt6, *pt7, *pt8;
	 int coef[9];
	 int alpha, beta;
 	 unsigned int op_a, op_b;
	 int pixel_concat;
		
	 coef[0] = -1;	 coef[1] = -1;	 coef[2] =  0;
	 coef[3] = -1;	 coef[4] =  0;	 coef[5] = +1;
	 coef[6] =  0;	 coef[7] = +1;	 coef[8] = +1;

	 alpha = 1; // facteur de ponderation
	 beta = 128; // offset
		  
	 cpt_out = 0;
	 coproc_reset(COPROC_1_RST);
	 
	 for(y=0; y<hauteur-2; y++){
		  pt0 = data  + largeur * y;
		  pt1 = data  + largeur * (y+1);
		  pt2 = data  + largeur * (y+2);

		  pixel_concat = (*pt0)<<16|(*pt1)<<8|(*pt2);
		  coproc_write(COPROC_1_RW, pixel_concat);
		  pt0++; pt1++; pt2++;
		  pixel_concat = (*pt0)<<16|(*pt1)<<8|(*pt2);
		  coproc_write(COPROC_1_RW, pixel_concat);
		  pt0++; pt1++; pt2++;
		  
		  for(x=2; x<largeur; x++){
			 //my_printf("d0:",(*pt0));
			 //my_printf("d1:",(*pt1));
			 //my_printf("d2:",(*pt2));
			 pixel_concat = (*pt0)<<16|(*pt1)<<8|(*pt2);
			 coproc_write(COPROC_1_RW, pixel_concat);
			 
		    //my_printf("val fil:", coproc_read(COPROC_1_RW));
			 tmp_i = coproc_read(COPROC_1_RW) + 128;
			 //my_printf("tmp_i:", coproc_read(COPROC_1_RW));
			 /*op_a = (*pt0)<<24|(*pt1)<<16|(*pt3)<<8|(*pt5);
			 op_b = (*pt7)<<8|(*pt8);*/

			
				//tmp_i = coef[0]*p0 + coef[1]*p1 + coef[2]*p2 +
				//		  coef[3]*p3 + coef[4]*p4 + coef[5]*p5 +
				//		  coef[6]*p6 + coef[7]*p7 + coef[8]*p8;
				//tmp_i = -1*(*pt0) -1*(*pt1) -1* (*pt3) + (*pt5) + (*pt7) + (*pt8) + 128;

				pt0++; pt1++; pt2++;// pt3++; pt4++; pt5++; pt6++; pt7++; pt8++;


				if(tmp_i > 255)
				data_sortie[cpt_out] = 255;
				else if (tmp_i < 0)
				data_sortie[cpt_out] = 0;
				else
				data_sortie[cpt_out] = (unsigned char)tmp_i;
				
				/*data_sortie[cpt_out] = isa_custom_8(op_a,op_b);
				pt0++; pt1++; pt2++; pt3++; pt4++; pt5++; pt6++; pt7++; pt8++;*/
				cpt_out++;

		  }
	 }        
}
