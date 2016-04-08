/**
 * \file rayobject.c
 * \brief Raytracer object
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */
 
#include "../Includes/rayobject.h"

u32_t ObjectGetNumberByType( int type ) {
	if ( type == OBJECT_TYPE_SPHERE ) {
		return SphereGetCount();
	} else if ( type == OBJECT_TYPE_PLANE ) {
		return PlaneGetCount();
	}
	return 0;
}

vec3_t ObjectGetNormal( int type, int idx, vec3_t p, vec3_t inside ) {
	if ( type == OBJECT_TYPE_SPHERE ) {
		return SphereGetNormal( idx, p );
	} else if ( type == OBJECT_TYPE_PLANE ) {
		return PlaneGetNormal( idx, inside );
	}
	return MathVec3Set( T( 0.0f ), T( 0.0f ), T( 0.0f ) );
}

vec3_t ObjectGetColor( int type, int idx ) {
	if ( type == OBJECT_TYPE_SPHERE ) {
		return SphereGetColor( idx );
	} else if ( type == OBJECT_TYPE_PLANE ) {
		return PlaneGetColor( idx );
	}
	return MathVec3Set( T( 0.0f ), T( 0.0f ), T( 0.0f ) );
}
