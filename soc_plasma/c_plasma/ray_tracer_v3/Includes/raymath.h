/**
 * \file raymath.h
 * \brief Raytracer math
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */

#ifndef __RAY_MATH_H__
#define __RAY_MATH_H__

#include <stdbool.h>
#include <stdlib.h>  
#include <math.h>
#include <limits.h>

#include "raytypes.h"
#include "raymathfix.h"

/**
 * \def FIX_IMP
 * \brief Enable 32-bit fixed point raytracer implementation
 */
#define FIX_IMP

/**
 * \def FIX_64
 * \brief Enable 64-bit fixed point raytracer implementation (only if FIX_IMP is previously defined)
 */
//#define FIX_64

/**
 * \def MathMax( a, b )
 * \brief Get the maximum of two numbers
 */
#define MathMax( a, b )    (((a) > (b)) ? (a) : (b))

/**
 * \def MathMin( a, b )
 * \brief Get the minimum of two numbers
 */
#define MathMin( a, b )    (((a) < (b)) ? (a) : (b))

#ifndef FIX_IMP
	#define number		float
	#define EPS_VALUE	0.00001f
	#define MAX_VALUE	FLT_MAX
	#define ZERO		0.0f
	#define T( f )		f

	#define add( a, b )	a + b
	#define sub( a, b )	a - b
	#define mul( a, b )	a * b
	#define div( a, b )	a / b
	#define sqr( a )	MathSqrtf( a )

	float	MathSqrtf		( float n );
#else
#ifdef FIX_64
	#define number		fixed64
#else
	#define number		fixed
#endif
	#define T( f )		MathFloat2Fix( f )
	#define add( a, b ) MathFixAdd( a, b )
	#define sub( a, b )	MathFixSub( a, b )
	#define mul( a, b )	MathFixMul( a, b )
	#define div( a, b )	MathFixDiv( a, b )
	#define sqr( a )	MathFixSqrt( a )

	#define EPS_VALUE	1 << FIX_SHIFT
	#define MAX_VALUE	INT_MAX
	#define ZERO		0

	number	MathFixSqrt		( number n );
#endif

/**
 * \typedef vec3_t
 * \brief A Structure to represent a 3D vector
 */
typedef struct vec3 {
	number x; 	/*!< x component */
	number y; 	/*!< y component */
	number z; 	/*!< z component */
} vec3_t;

/**
 * \fn number MathClamp( number d, number min, number max )
 * \brief Clamp a number between a range
 *
 * \param d number to clamp
 * \param min minimum number range
 * \param max maximum number range
 * \return clamped number
 */
number	MathClamp			( number d, number min, number max );

/**
 * \fn bool	MathIsOdd( int x )
 * \brief Get the parity of a integer
 *
 * \param x integer to test 
 * \return true if the integer is odd, false if even
 */
bool	MathIsOdd			( int x );

/**
 * \fn vec3_t MathVec3Set( number x, number y, number z )
 * \brief Set a 3D vector
 *
 * \param x x component
 * \param y y component
 * \param z z component
 * \return 3D vector
 */
vec3_t	MathVec3Set			( number x, number y, number z );

/**
 * \fn vec3_t MathVec3Add( vec3_t a, vec3_t b )
 * \brief Add two 3D vectors
 *
 * \param a 3D vector
 * \param b 3D vector
 * \return resulting 3D vector (a + b)
 */
vec3_t	MathVec3Add			( vec3_t a, vec3_t b );

/**
 * \fn vec3_t MathVec3Sub( vec3_t a, vec3_t b )
 * \brief Subtract two 3D vectors
 *
 * \param a 3D vector
 * \param b 3D vector
 * \return resulting 3D vector (a - b)
 */
vec3_t	MathVec3Sub			( vec3_t a, vec3_t b );

/**
 * \fn number MathVec3Dot( vec3_t a, vec3_t b )
 * \brief Compute the dot product between two vectors
 *
 * \param a 3D vector
 * \param b 3D vector
 * \return resulting dot product (a . b)
 */
number	MathVec3Dot			( vec3_t a, vec3_t b );

/**
 * \fn vec3_t MathVec3Scale( vec3_t a, number c )
 * \brief Scale a 3D vector (multiply by a scalar)
 *
 * \param a 3D vector
 * \param c scalar
 * \return resulting 3D vector (a x c)
 */
vec3_t	MathVec3Scale		( vec3_t a, number c );

/**
 * \fn vec3_t MathVec3Normalize( vec3_t v )
 * \brief Normalize a 3D vector
 *
 * \param v 3D vector
 * \return normalized 3D vector
 */
vec3_t	MathVec3Normalize	( vec3_t v );

#endif
