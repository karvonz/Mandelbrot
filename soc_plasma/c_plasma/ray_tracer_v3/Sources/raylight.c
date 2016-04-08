/**
 * \file raylight.c
 * \brief Raytracer light
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */
 
#include "../Includes/raylight.h"

static number LightGetDiffuse( vec3_t n, vec3_t l, vec3_t p ) {
	vec3_t lv = MathVec3Normalize( MathVec3Sub( l, p ) ); 					// light vector (point to light)
	return MathVec3Dot( n, lv ); 											// dot product = cos( light-to-surface-normal Angle )
}

number LightObject( int type, int idx, vec3_t l, vec3_t p, number lightAmbient ) {
	number i = LightGetDiffuse( ObjectGetNormal( type, idx, p, l ), l, p );
	return MathMin( T( 1.0f ), MathMax( i, lightAmbient ) ); 				// add in ambient light by constraining min value
}
