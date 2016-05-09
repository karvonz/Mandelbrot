#include <stdio.h>
#include <stdbool.h>

#include "../../shared/plasmaCoprocessors.h"
#include "../../shared/plasmaIsaCustom.h"
#include "../../shared/plasmaMisc.h"
#include "../../shared/plasmaSoPCDesign.h"
#include "../../shared/plasmaMyPrint.h"
#include "../../shared/plasmaFifoInOut.h"

#define precision 28
#define XPOINT 0xE994DE80 
#define YPOINT 0x00000000
#define ZOOM 2
#define ITER 50


int Convergence_Fixed(int X, int Y, int maxi)
{
  int   deux = 2 << precision;
  int      i = 0;
  long long x1 = 0;
  long long y1 = 0;
int temp, tempy1;

  //int x2, y2;
  do{

    temp = isa_custom_3(x1,y1); //x1²+y1²
    tempy1=y1;
    y1 = isa_custom_1(x1 , y1) + Y; //x1*y1*2+Y
    x1 = isa_custom_2(x1,tempy1) + X; //x2² - y2² + X;
    i++;
  }while( (temp <= deux) && ( i < maxi )  );


  return i;
}


 int main( int argc, char ** argv ) {

  /*const int _xstart   = 0xE0000000;
  const int _ystart   = 0xF0000000;
  const int _xinc     = 0x00133AE4;
  const int _yinc     = 0x00111A30;
*/
	
	int _xstart = XPOINT-0x18000000;  // - 1,5 
	int _ystart = YPOINT-0x10000000;
	int step    = 0x00111111;
	int _delta = 0x00000000;


	//step <= 0x00111111"; //Mandelbrot -2 1 x -1 1 sur 640x480

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

      int i = Convergence_Fixed(posX, posY, ITER);
		int value = (256 * i) / maxi;
		coproc_write(COPROC_4_RW, value);
      
      posX += step;
    }
      posY += step;
  }
	_xstart = isa_custom_4(_xstart,_delta);  
	_ystart = isa_custom_5(_ystart,_delta);  
	step = step>>1;
wait(5);
	
}

}

