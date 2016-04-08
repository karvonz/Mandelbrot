/**
 * \file rayintersect.c
 * \brief Raytracer ray intersection
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */
 
#include "../Includes/rayintersect.h"
#include "../../shared/plasmaSoPCDesign.h"
#include "../../shared/plasmaCoprocessors.h"


static bool IntersectionTest( number dist, int p, int i, rayintersect_t * info ) {
	if ( dist < info->dist && dist > T( 0.0f ) ) { 										// closest intersection so far in forward direction of ray ?
		// save intersection state
		info->type  = p;
		info->index = i;
		info->dist  = dist;
		return true;
	}
	return false;
}

static bool IntersectionRaySphere( int idx, vec3_t r, vec3_t o, rayintersect_t * info ) {
	//puts("sphere intersect \n"); // profiling
	//int t0, t1, t2, t3, t4, t5, t6; // profiling
	//t0 = r_timer(); // profiling
	vec3_t s = MathVec3Sub( SphereGetPosition( idx ), o ); 								// sphere center translated into coordinate frame of ray origin
	number radius = SphereGetRadius( idx );												// sphere radius
	//t1 = r_timer(); // profiling
	//number a = MathVec3Dot( r, r ); 													// intersection of sphere and line = quadratic function of distance
	//t2 = r_timer();  // profiling
	
	coproc_reset(COPROC_1_RST);
   coproc_write(COPROC_1_RW, r.x);
	coproc_write(COPROC_1_RW, r.x);
	coproc_write(COPROC_1_RW, r.y);
	coproc_write(COPROC_1_RW, r.y);
	coproc_write(COPROC_1_RW, r.z);
	coproc_write(COPROC_1_RW, r.z);
	number a = coproc_read(COPROC_1_RW);
	/*my_printf("a=",a);
	my_printf("a_hw=",a_hw);*/
	number b = mul( T( -2.0f ), MathVec3Dot( s, r ) ); 									//   a  x^2 +    b  x +        c         = 0
	//t3 = r_timer(); // profiling
	number c = sub( MathVec3Dot( s, s ), ( mul( radius, radius ) ) ); 					// (r'r)x^2 - (2s'r)x + (s's - radius^2) = 0
	//t4 = r_timer(); // profiling
	number d = sub( mul( b, b ), mul( T( 4.0f ), mul( a, c ) ) ); 						// precompute discriminant
	//t5 = r_timer(); // profiling
	/*my_printf("r.x ", r.x);
	my_printf("r.y ", r.y);
	my_printf("r.z ", r.z);
	my_printf("a ", a);
	my_printf("hw_a ", hw_a);*/
	/*if(hw_a != a){
	  my_printf("a ", a);
	my_printf("hw_a ", hw_a);	
	}*/
	//t_2 = r_timer();
	
	if ( d > T( 0.0f ) ) { 																// solution exists only if sqrt( d ) is real (not imaginary)
		number sign = ( c < -EPS_VALUE ) ? (number)1 : (number)-1; 						// ray originates inside sphere if c < 0
		number dist = div( ( add( -b, sign * sqr( d ) ) ), ( mul( T( 2.0f ), a ) ) ); 	// solve quadratic equation for distance to intersection
		if ( IntersectionTest( dist, OBJECT_TYPE_SPHERE, idx, info ) ) { 				// is this closest intersection so far ?
			return true;
		}
	}
	/*t6 = r_timer(); // profiling
	my_printf( "time sphere intersect :", t6-t1); // profiling
	my_printf( "TSI t1-t0:", t1-t0); // profiling
	my_printf( "TSI t2-t1:", t2-t1); // profiling
	my_printf( "TSI t3-t2:", t3-t2); // profiling
	my_printf( "TSI t4-t3:", t4-t3); // profiling
	my_printf( "TSI t5-t4:", t5-t4); // profiling
	my_printf( "TSI t6-t5:", t6-t5); // profiling*/
	return false;
}

static bool IntersectionRayPlane( int idx, vec3_t r, vec3_t o, rayintersect_t * info ) {
	 //puts("plane intersect\n"); // profiling
	 //int t0, t1; // profiling
	 //t0 = r_timer(); // profiling
	int axis  = PlaneGetAxis( idx ); 													// determine orientation of axis-aligned plane
	number ray = T( 0.0f );
	number org = T( 0.0f );
	if ( axis == 0 ) {
		ray = r.x; org = o.x;
	}else if ( axis == 1 ) {
		ray = r.y; org = o.y;
	}else if ( axis == 2 ) {
		ray = r.z; org = o.z;
	}
	if ( ray != T( 0.0f ) ) { 															// parallel ray = no intersection
		number dist = div( ( sub( PlaneGetDistance( idx ), org ) ), ray ); 				// solve linear equation (rx = p - o)
		if ( IntersectionTest( dist, OBJECT_TYPE_PLANE, idx, info ) ) {
		  //t_b = r_timer();
		  //my_printf("plane time: ",t_b-t_a);
			return true;
		}
	}
	//t1 = r_timer(); // profiling
   //my_printf("plane time: ",t1-t0);  // profiling
	return false;
}

bool IntersectionRayObject( int type, int idx, vec3_t r, vec3_t o, rayintersect_t * info ) {
	if ( type == OBJECT_TYPE_SPHERE ) { 												// object is a sphere ?
		if ( IntersectionRaySphere( idx, r, o, info ) ) { 								// ray-sphere intersection test
			return true;
		}
	} else if ( type == OBJECT_TYPE_PLANE ) { 											// object is a plane ?
		if ( IntersectionRayPlane( idx, r, o, info ) ) { 								// ray-plane intersection test
			return true;
		}
	}
	return false;
}
