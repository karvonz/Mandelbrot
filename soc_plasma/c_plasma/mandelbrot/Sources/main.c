#include <stdio.h>
#include <stdbool.h>

#include "../../shared/plasmaCoprocessors.h"
#include "../../shared/plasmaIsaCustom.h"
#include "../../shared/plasmaMisc.h"
#include "../../shared/plasmaSoPCDesign.h"
#include "../../shared/plasmaMyPrint.h"
#include "../../shared/plasmaFifoInOut.h"

#define precision 28

int Convergence_Fixed(int X, int Y, int maxi)
{
  int   deux = 2 << precision;
  int      i = 0;
  long long x1 = 0;
  long long y1 = 0;
int temp;

  //int x2, y2;
  do{
    //x2 = isa_custom_1(x1 , x1);
    //y2 = isa_custom_1(y1 , y1);
    temp = isa_custom_3(x1,y1); //x2 - y2 + X;
    y1 = isa_custom_1(x1 , y1) + Y; //x1*y1*2+Y
    x1 = isa_custom_2(x1,y1) + X;
    i++;
  }while( (temp <= deux) && ( i < maxi )  );


  return i;
}


 int main( int argc, char ** argv ) {

  const int _xstart   = 0xE0000000;
  const int _ystart   = 0xF0000000;
  const int _xinc     = 0x004D4874;
  const int _yinc     = 0x0052BF5B;

coproc_reset(COPROC_4_RST);
int height = 480;
int width = 640;

for(int maxi=1; maxi<256; maxi++)
{

  int posY = _ystart;
  for(int py = 0; py < height; py += 1)
  {
    int posX = _xstart;

    for(int px = 0; px < width; px += 1){

      int i = Convergence_Fixed(posX, posY, maxi);
		int value = (256 * i) / maxi;
		coproc_write(COPROC_4_RW, value);
      
      posX += _xinc;
    }
      posY += _yinc;
  }
  
}

}
