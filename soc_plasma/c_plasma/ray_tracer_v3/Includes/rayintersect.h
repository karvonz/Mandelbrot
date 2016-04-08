/**
 * \file rayintersect.h
 * \brief Raytracer ray intersection
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */

#ifndef __RAY_INTERSECT_H__
#define __RAY_INTERSECT_H__

#include <stdbool.h>

#include "raymath.h"
#include "raymathfix.h"
#include "rayplane.h"
#include "raysphere.h"
#include "rayobject.h"

/**
 * \typedef plane_t
 * \brief A Structure to represent an intersection data
 */
typedef struct rayintersect {
	int type;		/*!< Type of the object which has intersected with the ray */
	int index;		/*!< Index of the object which has intersected with the ray */
	number dist;	/*!< Distance from ray origin to intersection point */
} rayintersect_t;

/**
 * \fn bool IntersectionRayObject( int type, int idx, vec3_t r, vec3_t o, rayintersect_t * info )
 * \brief Test if an intersection between a ray and a object occurs
 *
 * \param type			Object type ( OBJECT_TYPE_SPHERE or OBJECT_TYPE_PLANE )
 * \param idx			Object identifier
 * \param r 			Ray direction
 * \param o 			Ray origin
 * \param info			A pointer holding a structure of intersection data
 * \return True if an intersection occurs, false otherwise
 */
bool IntersectionRayObject( int type, int idx, vec3_t r, vec3_t o, rayintersect_t * info );

#endif
