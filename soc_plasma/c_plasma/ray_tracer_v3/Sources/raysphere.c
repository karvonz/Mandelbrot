/**
 * \file raysphere.c
 * \brief Raytracer sphere object
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */
 
#include "../Includes/raysphere.h"

static sphere_t	g_spheres[ MAX_SPHERES ];
static u32_t	g_totSpheres = 0;

u32_t SphereAdd() {
	return g_totSpheres++;
}

u32_t SphereGetCount() {
	return g_totSpheres;
}

void SphereSet( int idx, number x, number y, number z, number radius, vec3_t color, bool reflect ) {
	g_spheres[ idx ].pos.x   = x; 											// sphere position
	g_spheres[ idx ].pos.y   = y;
	g_spheres[ idx ].pos.z   = z;
	g_spheres[ idx ].r		 = radius; 										// ... radius
	g_spheres[ idx ].color   = color; 										// ... color
	g_spheres[ idx ].reflect = reflect; 									// ... reflect material ?
}

bool SphereHasReflection( int idx ) {
	return g_spheres[ idx ].reflect;
}

vec3_t SphereGetPosition( int idx ) {
	return g_spheres[ idx ].pos;
}

number SphereGetRadius( int idx ) {
	return g_spheres[ idx ].r;
}

vec3_t SphereGetColor( int idx ) {
	return g_spheres[ idx ].color;
}

vec3_t SphereGetNormal( int idx, vec3_t p ) {
	return MathVec3Normalize( MathVec3Sub( p, g_spheres[ idx ].pos ) ); 	// surface normal (center to point)
}
