/**
 * \file rayobject.h
 * \brief Raytracer objects
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */

#ifndef __RAY_OBJECT_H__
#define __RAY_OBJECT_H__

#include "raymath.h"
#include "rayplane.h"
#include "raysphere.h"

/**
 * \def OBJECT_NUM_TYPES
 * \brief Number of object types
 */
#define OBJECT_NUM_TYPES	2

/**
 * \def OBJECT_TYPE_SPHERE
 * \brief Sphere object type constant
 */
#define OBJECT_TYPE_SPHERE	0

/**
 * \def OBJECT_TYPE_SPHERE
 * \brief Plane object type constant
 */
#define OBJECT_TYPE_PLANE	1

/**
 * \fn u32_t ObjectGetNumberByType( int type )
 * \brief Get the number of objects given a type
 *
 * \param type Object type (OBJECT_TYPE_SPHERE or OBJECT_TYPE_PLANE)
 * \return Number of objects (by type)
 */
u32_t	ObjectGetNumberByType	( int type );

/**
 * \fn vec3_t ObjectGetNormal( int type, int idx, vec3_t p, vec3_t inside )
 * \brief Get an object normal
 *
 * \param type		Object type (OBJECT_TYPE_SPHERE or OBJECT_TYPE_PLANE)
 * \param idx		Object identifier
 * \param p 		Intersection point position
 * \param inside 	origin (applies for planes only)
 * \return Object normal
 */
vec3_t	ObjectGetNormal			( int type, int idx, vec3_t p, vec3_t inside );

/**
 * \fn vec3_t ObjectGetColor( int type, int idx )
 * \brief Get an object color
 *
 * \param type	Object type (OBJECT_TYPE_SPHERE or OBJECT_TYPE_PLANE)
 * \param idx	Object identifier
 * \return Object color
 */
vec3_t	ObjectGetColor			( int type, int idx );

#endif
