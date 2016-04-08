/**
 * \file raymathfix.h
 * \brief Raytracer fix math
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */

#ifndef __RAY_MATH_FIX_H__
#define __RAY_MATH_FIX_H__

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>  
#include <math.h>
#include "../../shared/plasmaIsaCustom.h"


#include "raymath.h"

/**
 * \def FIX_SHIFT
 * \brief Fixed point number of fractional bits
 */
#define FIX_SHIFT				11

#define FIX_SCALE				( 1 << FIX_SHIFT )
#define FIX_MASK				( FIX_SCALE - 1 )
#define FIX_SCALEF				( (float)FIX_SCALE )
#define FIX_SCALEF_INV			( 1.0f / FIX_SCALEF	)
#define FIX_ONE					FIX_SCALE

/**
 * \def MathFloat2Fix( f )
 * \brief Convert a floating point number to a fixed point number
 */
#define MathFloat2Fix( f )		(number)( f * FIX_SCALEF )

/**
 * \def MathFixAdd( fa, fb )
 * \brief Add two fixed point number
 */
#define MathFixAdd( fa, fb )	(number)( fa + fb )

/**
 * \def MathFixSub( fa, fb )
 * \brief Subtract two fixed point number
 */
#define MathFixSub( fa, fb )	(number)( fa - fb )

/**
 * \def MathFixMul( fa, fb )
 * \brief Multiply two fixed point number
 */
#define MathFixMul( fa, fb )	(number)( ( fa * fb ) >> FIX_SHIFT )
//#define MathFixMul( fa, fb ) isa_custom_1(fa, fb)

/**
 * \def MathFixDiv( fa, fb )
 * \brief Divide two fixed point number
 */
#define MathFixDiv( fa, fb )	( ( (number)fa ) << FIX_SHIFT ) / ( ( fb == 0 ) ? 1 : fb )

/**
 * \def MathInt2Fix( d )
 * \brief Convert a integer to a fixed point number
 */
#define MathInt2Fix( d )		(fixed)( d << FIX_SHIFT )

/**
 * \def MathFix2Uint( fix )
 * \brief Convert a fixed point number to an unsigned integer
 */
#define MathFix2Uint( fix )		(u32_t)( fix >> FIX_SHIFT )

/**
 * \def MathFix2UFrac( fix )
 * \brief Convert a fixed point fractional part to an unsigned integer
 */
#define MathFix2UFrac( fix )	(u32_t)( fix & FIX_MASK )

/**
 * \def MathFix2Int( fix )
 * \brief Convert a fixed point number part to a signed integer
 */
#define MathFix2Int( fix )		(int)( fix / FIX_SCALE )

/**
 * \def MathFix2Float( fix )
 * \brief Convert a fixed point number to a floating point number
 */
#define MathFix2Float( fix )	(float)( fix / FIX_SCALEF )

#endif
