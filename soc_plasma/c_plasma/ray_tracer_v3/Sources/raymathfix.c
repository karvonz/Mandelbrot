/**
 * \file raymathfix.c
 * \brief Raytracer fix math
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */
 
#include "../Includes/raymathfix.h"

//!Float implementation of square root of n
#ifndef FIX_IMP
float MathSqrtf(float n) {
    long i;
    float x, y;
    const float f = 1.5F;
    x = n * 0.5F;
    y  = n;
    i  = * ( long * ) &y;
    i  = 0x5f3759df - ( i >> 1 );
    y  = * ( float * ) &i;
    y  = y * ( f - ( x * y * y ) );
    y  = y * ( f - ( x * y * y ) );
	//at this point we are with 1 / sqrt
    return n * y;
}
#else
//!Fixed implementation of square root of n
number MathFixSqrt( number n ) {
    number x, y;
	 int j;
    number f = T( 1.5f );
    x = MathFixMul( n, T( 0.5f ) );
    y = n;
	y = ( 1 << ( FIX_SHIFT - 1 ) );
	for ( j = 0; j < 6; j++ ) {
		y = MathFixMul( y, ( f - MathFixMul( x, MathFixMul( y, y ) ) ) );
	}
	number s = (number)MathFixMul( n, y );
    return s;
}
#endif

/*number MathFixMul(number a, number b){
  return ((a*b) >> FIX_SHIFT);
}*/
