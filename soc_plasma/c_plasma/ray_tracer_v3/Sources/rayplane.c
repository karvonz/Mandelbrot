/**
 * \file rayplane.c
 * \brief Raytracer plane object
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */
 
#include "../Includes/rayplane.h"

static plane_t g_planes[ MAX_PLANES ];
static u32_t g_totPlanes = 0;

u32_t PlaneAdd() {
	return g_totPlanes++;
}

u32_t PlaneGetCount() {
	return g_totPlanes;
}

void PlaneSet( int idx, number axis, number dist, vec3_t color ) {
	g_planes[ idx ].axis  = axis;
	g_planes[ idx ].dist  = dist;
	g_planes[ idx ].color = color;
}

number PlaneGetDistance( int idx ) {
	return g_planes[ idx ].dist;
}

int	PlaneGetAxis( int idx ) {
	return ( int )g_planes[ idx ].axis;
}

vec3_t PlaneGetColor( int idx ) {
	return g_planes[ idx ].color;
}

vec3_t PlaneGetNormal( int idx, vec3_t o ) {
	int axis = PlaneGetAxis( idx );
	vec3_t n = MathVec3Set( T( 0.0f ), T( 0.0f ), T( 0.0f ) );
	// compute vector from surface to light
	if ( axis == 0 ) {
		n.x = o.x - g_planes[ idx ].dist;
	}else if ( axis == 1 ) {
		n.y = o.y - g_planes[ idx ].dist;
	}else if ( axis == 2 ) {
		n.z = o.z - g_planes[ idx ].dist;
	}
	return MathVec3Normalize( n );
}
