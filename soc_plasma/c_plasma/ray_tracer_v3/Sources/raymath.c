/**
 * \file raymath.c
 * \brief Raytracer math
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */
 
#include "../Includes/raymath.h"

//I should macroized or inline that !
number MathClamp( number d, number min, number max ) {
  number t = d < min ? min : d;
  return t > max ? max : t;
}

bool MathIsOdd( int x ) {
	return x % 2 != 0;
}

vec3_t MathVec3Set( number x, number y, number z ) {
	vec3_t v;
	v.x = x;
	v.y = y;
	v.z = z;
	return v;
}

vec3_t MathVec3Add( vec3_t a, vec3_t b ) {
	vec3_t r = MathVec3Set( add( a.x, b.x ), add( a.y, b.y ), add( a.z, b.z ) );
	return r;
}

vec3_t MathVec3Sub( vec3_t a, vec3_t b ) {
	vec3_t r = MathVec3Set( sub( a.x, b.x ), sub( a.y, b.y ), sub( a.z, b.z ) );
	return r;
}

vec3_t MathVec3Scale( vec3_t a, number c ) {
	vec3_t r = MathVec3Set( mul( c, a.x ), mul( c, a.y ), mul( c, a.z ) );
	return r;
}

number MathVec3Dot( vec3_t a, vec3_t b ) {
    number dot = T( 0.0f );
	dot = add( dot, mul( a.x, b.x ) );
	dot = add( dot, mul( a.y, b.y ) );
	dot = add( dot, mul( a.z, b.z ) );
    return dot;
}

vec3_t MathVec3Normalize( vec3_t v ) {
	number l = (number)sqr( MathVec3Dot( v, v ) );
	return MathVec3Scale( v, div( T( 1.0f ), l ) );
}
