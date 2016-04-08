/**
 * \file rayrender.c
 * \brief Raytracer scene rendering
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */

#include "../Includes/rayrender.h"
#include "../../shared/plasmaSoPCDesign.h"

static u32_t	g_row;
static u32_t	g_col;
static u32_t	g_it;
static u32_t	g_curr;
static u32_t	g_maxr;
static bool		g_empty; 

static vec3_t	g_origin;
static vec3_t	g_point;
static vec3_t	g_light;
static number	g_ambient;

void RenderReset() {
	g_row	= 0;
	g_col	= 0;
	g_it	= 1;
	g_curr	= 2;
	g_empty	= true;
}

void RenderSetup( vec3_t l, number ambient, u32_t maxr ) {
	g_origin  = MathVec3Set( T( 0.0f ), T( 0.0f ), T( 0.0f  ) ); 	// world origin
	g_point   = MathVec3Set( T( 0.0f ), T( 0.0f ), T( 0.0f  ) ); 	// point at which the ray intersected the object
	g_light   = l; 													// point light-source position
	g_ambient = ambient; 											// ambient lighting
	g_maxr	  = maxr; 												// max render resolution
}

vec3_t RenderFilterColor( vec3_t rgbIn, vec3_t color ) {
	vec3_t rgbOut = MathVec3Set( color.x, color.y, color.z );
	// absorb some wavelengths (r, g, b)
	rgbOut.x = MathMin( rgbOut.x, rgbIn.x );
	rgbOut.y = MathMin( rgbOut.y, rgbIn.y );
	rgbOut.z = MathMin( rgbOut.z, rgbIn.z );
	return rgbOut;
}

vec3_t RenderGetColor( vec3_t rgbIn, int type, int index ) {
	return RenderFilterColor( rgbIn, ObjectGetColor( type, index ) );
}

bool Raytrace( vec3_t ray, vec3_t origin, rayintersect_t * info ) {
	bool intersect = false; // no intersection along this ray yet
	info->dist = MAX_VALUE; // maximum distance to any object
	info->index = -1; 		// no ray-object index found yet
	info->type = -1; 		// no ray-object type found yet 
	u32_t i, j;
	// for every objects in scene, are there ray-object intersections ?
	for ( i = 0; i < OBJECT_NUM_TYPES; i++ ) {
		for ( j = 0; j < ObjectGetNumberByType( i ); j++ ) {
			if ( IntersectionRayObject( i, j, ray, origin, info ) ) {
				intersect = true;
			}
		}
	}
	return intersect;
}

vec3_t Reflect( u32_t type, u32_t index, vec3_t ray, vec3_t fromPoint ) {
	// surface normal
	vec3_t n = ObjectGetNormal( type, index, g_point, fromPoint );
	// approximation to reflection	
	return MathVec3Normalize( MathVec3Sub( ray, MathVec3Scale( n, ( mul( T( 2.0f ), MathVec3Dot( ray, n ) ) ) ) ) );
}

vec3_t RenderComputePixelColor( u32_t size, number x, number y ) {
   //int t0, t1, t2, t3, t4, t5, t6, t7, t8, t9; // profiling
   //t0 = r_timer(); // profiling
	vec3_t rgb = MathVec3Set( T( 0.0f ), T( 0.0f ), T( 0.0f ) );
	//t1 = r_timer(); // profiling
	// convert pixels to image plane coordinates (focal length = 1.0)
	vec3_t ray = MathVec3Set( sub( ( div( x, (number)size ) ), T( 0.5f ) ), - ( sub( ( div( y, (number)size ) ), T( 0.5f ) ) ), T( 1.0f ) );
	//t2 = r_timer(); // profiling
	rayintersect_t info;
	rayintersect_t * infoptr = &info;
	// raytrace - intersected objects are stored in a pointer
	//t3 = r_timer(); // profiling
	if ( Raytrace( ray, g_origin, infoptr ) ) {
		// intersection   
		// 3D point of intersection
	   //t4 = r_timer(); // profiling
		g_point = MathVec3Scale( ray, infoptr->dist );
		//int t_b = r_timer();
		// is there a sphere with a mirror surface ?
		if ( infoptr->type == OBJECT_TYPE_SPHERE && SphereHasReflection( infoptr->index ) ) {
			// reflect ray off the surface
			ray = Reflect( infoptr->type, infoptr->index, ray, g_origin );
			// follow the reflected ray
			if ( Raytrace( ray, g_point, infoptr ) ) {
				// 3D point of intersection
				g_point = MathVec3Add( MathVec3Scale( ray, infoptr->dist ), g_point );
			}
		}
		//t5 = r_timer(); // profiling
		// lighting via standard illumination model (diffuse + ambient)
		// store intersected object data
		int type = infoptr->type;
		int index = infoptr->index;
		// if in shadow, use ambient color of original object
		number i = g_ambient;
		// raytrace from light to object
		//t6 = r_timer(); // profiling
		Raytrace( MathVec3Sub( g_point, g_light ), g_light, infoptr );
		//t7 = r_timer(); // profiling
		// ray from light->object hits object first ?
		if ( type == infoptr->type && index == infoptr->index ) {
			// not in shadow - compute lighting
			i = LightObject( infoptr->type, infoptr->index, g_light, g_point, g_ambient );
		}
		//t8 = r_timer(); // profiling
		rgb = MathVec3Set( i, i, i );
		rgb = RenderGetColor( rgb, type, index );
		/*t9 = r_timer(); // profiling
		my_printf("t9 - t0 = ", t9-t0); // profiling
		my_printf("t9 - t8 = ", t9-t8); // profiling
		my_printf("t8 - t7 = ", t8-t7); // profiling
		my_printf("t7 - t6 = ", t7-t6); // profiling
		my_printf("t6 - t5 = ", t6-t5); // profiling
		my_printf("t5 - t4 = ", t5-t4); // profiling
		my_printf("t4 - t3 = ", t4-t3); // profiling
		my_printf("t3 - t2 = ", t3-t2); // profiling
		my_printf("t2 - t1 = ", t2-t1); // profiling
		my_printf("t1 - t0 = ", t1-t0); // profiling*/
	}
	return rgb;
}
/*
void Render() {
	if ( g_empty ) {
		u32_t imgSize = GLRendererGetTextureSize();
		u32_t iterations = 0;
		vec3_t rgb = MathVec3Set( T( 0.0f ), T( 0.0f ), T( 0.0f ) );
		while ( iterations < MathMax( g_curr, g_maxr ) ) {
			bool needsDrawing;
			if ( g_col >= g_curr ) {
				g_row++;
				g_col = 0;
				if ( g_row >= g_curr ) {
					g_it++;
					g_row = 0;
					g_curr = (int)( pow( 2.0, g_it ) );
				}
			}
			needsDrawing = ( g_it == 1 || MathIsOdd( g_row ) || ( ! MathIsOdd( g_row ) && MathIsOdd( g_col ) ) );
			int x = g_col * ( imgSize / g_curr );
			int y = g_row * ( imgSize / g_curr );
			number fx = (number)x;
			number fy = (number)y;
			g_col++;
			if ( needsDrawing ) {
				iterations++;
				rgb = RenderComputePixelColor( imgSize, fx, fy );
				#ifdef FIX_IMP
					GLRendererDrawRect( x, y, ( imgSize / g_curr ) - 1, ( imgSize / g_curr ) - 1, ( u8_t )(MathFix2Float(rgb.x) * 255), ( u8_t )(MathFix2Float(rgb.y) * 255), ( u8_t )(MathFix2Float(rgb.z) * 255 ) );
				#else
					rgb = MathVec3Scale( RenderComputePixelColor( imgSize, fx, fy ), T( 255.0f ) );
					GLRendererDrawRect( x, y, ( imgSize / g_curr ) - 1, ( imgSize / g_curr ) - 1, ( u8_t )rgb.x, ( u8_t )rgb.y, ( u8_t )rgb.z );
				#endif
			}
		}
		if ( g_row == imgSize - 1 ) { 
			g_empty = false; 
		}
	}
}*/
