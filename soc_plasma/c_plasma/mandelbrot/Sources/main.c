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
#define ITER_MAX 255
#define ITER_BEGIN 50

#define MASK_SWITCH_ITER 0x00000020
#define MASK_SWITCH_ZOOM 0x00000040
#define MASK_UP  0x00000010
#define MASK_DOWN  0x00000002
#define MASK_LEFT 0x00000008
#define MASK_RIGHT  0x00000004
#define MASK_CENTER  0x00000001

volatile bool buttonLeft (volatile unsigned int *p ){
    static bool b=false;
    if(((*p) & MASK_LEFT) == MASK_LEFT){
        if (b==false)
        {
            b=true;
            return true;
        }
        else
            return false;
    }
    b=false;
    return false;
}

volatile bool buttonCenter (volatile unsigned int *p ){
    static bool b=false;
    if(((*p) & MASK_CENTER) == MASK_CENTER){
        if (b==false)
        {
            b=true;
            return true;
        }
        else
            return false;
    }
    b=false;
    return false;
}
volatile bool buttonDown (volatile unsigned int *p ){
    static bool b=false;
    if(((*p) & MASK_DOWN) == MASK_DOWN){
        if (b==false)
        {
            b=true;
            return true;
        }
        else
            return false;
    }
    b=false;
    return false;
}

volatile bool buttonUp (volatile unsigned int *p ){
    static bool b=false;
    if(((*p) & MASK_UP) == MASK_UP){
        if (b==false)
        {
            b=true;
            return true;
        }
        else
            return false;
    }
    b=false;
    return false;
}

volatile bool buttonRight (volatile unsigned int *p ){
    static bool b=false;
    if(((*p) & MASK_RIGHT) == MASK_RIGHT){
        if (b==false)
        {
            b=true;
            return true;
        }
        else
            return false;
    }
    b=false;
    return false;
}

volatile bool switchZoom (volatile unsigned int *p ){
    return (((*p) & MASK_SWITCH_ZOOM) == MASK_SWITCH_ZOOM);
}

volatile bool switchIter (volatile unsigned int *p){
    return (((*p) & MASK_SWITCH_ITER) == MASK_SWITCH_ITER);
}


inline int Convergence_Fixed(int X, int Y, int maxi)
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
    volatile unsigned int* p;
    //volatile unsigned int* p;
    p= 0x20000050;
    /*const int _xstart   = 0xE0000000;
  const int _ystart   = 0xF0000000;
  const int _xinc     = 0x00133AE4;
  const int _yinc     = 0x00111A30;
*/

    int _xstart = XPOINT-0x18000000;  // - 1,5
    int _ystart = YPOINT-0x10000000;
    int step    = 0x00111111;
    int _delta = 0x00000000;
    int maxi = ITER_BEGIN;

    coproc_reset(COPROC_4_RST);
    int height = 480;
    int width = 640;

    while(true){


        if (!switchIter(p))
        {
            while(maxi<ITER_MAX)
            {
                // for(int maxi=1; maxi<256; maxi++)
                //{
                int posY = _ystart;
                for(int py = 0; py < height; py += 1)
                {
                    int posX = _xstart;

                    for(int px = 0; px < width; px += 1){

                        int i = Convergence_Fixed(posX, posY, maxi); //maxi
                       // int value = (256 * i) / maxi; //maxi
                        coproc_write(COPROC_4_RW, i);

                        posX += step;

                        if(buttonRight(p)){
                            _xstart += (step<<7);
                            maxi = ITER_BEGIN;
                        }

                        if(buttonLeft(p)){
                            _xstart -= (step<<7);
                            maxi = ITER_BEGIN;
                        }

                        if(buttonUp(p)){
                            _ystart += (step<<7);
                            maxi = ITER_BEGIN;
                        }

                        if(buttonDown(p)){
                            _ystart -= (step<<7);
                            maxi = ITER_BEGIN;
                        }
                        if(buttonCenter(p)){
                            _xstart += isa_custom_4(step,0x28000000);
                            _ystart += isa_custom_4(step,0x1E000000);
                            //s_xstart <= s_xstart + (mult(s_step srl 2,x"28000000",FIXED) sll 8);
                            //s_ystart <= s_ystart + (mult(s_step srl 2,x"1E000000",FIXED) sll 8);
                            step = step >> 1; //--Zoom x2> réduction du step
                            maxi = ITER_BEGIN;
                        }

                    }
                    posY += step;

                }
                maxi++;
            }
        }
        else
            maxi = 5;


        //    while(switchIter(p))
        //    {}

        // }

    }


    //
    //ZOOM
    //
    //_xstart = isa_custom_4(_xstart,_delta);
    //_ystart = isa_custom_5(_ystart,_delta);
    //step = step>>1;

}



