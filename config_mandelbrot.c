#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define FILENAME "config_mandelbrot.vhd"
#define ENTETE "library IEEE;\nuse IEEE.STD_LOGIC_1164.ALL;\nuse IEEE.NUMERIC_STD.ALL;\n\n\npackage CONFIG_MANDELBROT is \n"
#define QF 28


void to_bin( int nbr, char *str)
{
int  c, k;
    int i=0;
        for (c = 31; c >= 0; c--)
	  {
	        k = nbr >> c;
		 
		    if (k & 1)
		            str[i++]='1';
		        else
			    str[i++]='0';
			  }
 
  str[i]='\0';
   
    }

int main(int argc, char ** argv){
  if (argc < 7)
  {
    fprintf(stderr, "usage %s <xstart><xstop><ystart><ystop><xres><yres>\n",argv[0]);
    exit(2);
  }
  float xstart=atof(argv[1]),xstop=atof(argv[2]),ystart=atof(argv[3]),ystop=atof(argv[4]),xres=atof(argv[5]), yres=atof(argv[6]);

 float xinc=(xstop-xstart)/(xres-1); 
 float yinc=(ystop-ystart)/(yres-1);
 char buf[256]={};

  FILE* fichier=NULL;
  fichier=fopen(FILENAME, "w+");
  if(fichier!=NULL){
    fprintf(fichier, "%s", ENTETE); 
    fprintf(fichier, "constant XSTART : SIGNED(31 downto 0) :=x\"%X\";\n", (int32_t)round(xstart*(1<<QF))); 
    fprintf(fichier, "constant XSTOP : SIGNED(31 downto 0) :=x\"%X\";\n",(int32_t)round(xstop*(1<<QF))); 
    fprintf(fichier, "constant YSTART : SIGNED(31 downto 0) :=x\"%X\";\n", (int32_t)round(ystart*(1<<QF))); 
    fprintf(fichier, "constant YSTOP : SIGNED(31 downto 0) :=x\"%X\";\n", (int32_t)round(ystop*(1<<QF))); 
    fprintf(fichier, "constant XINC : SIGNED(31 downto 0) :=x\"%X\";\n", (int32_t)round(xinc*(1<<QF))); 
    fprintf(fichier, "constant YINC : SIGNED(31 downto 0) :=x\"%X\";\n", (int32_t)round(yinc*(1<<QF))); 
    fprintf(fichier, "constant XRES : integer :=\"%d\";\n", (int)xres); 
    fprintf(fichier, "constant YRES : integer :=\"%d\";\n", (int)yres); 
    fprintf(fichier, "\n\n end CONFIG_MANDELBROT;\n"); 
  }
  else
  {
    printf("erreur d'ouverture du fichier\n");
  }
  fclose(fichier);
  return 0;
}
