/**
 * \file raysphere.h
 * \brief Raytracer sphere object
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */

#ifndef __RAY_SPHERE_H__
#define __RAY_SPHERE_H__

#include "raymath.h"

/**
 * \def MAX_SPHERES
 * \brief Maximum number of spheres in the current scene
 */
#define MAX_SPHERES 16

/**
 * \typedef sphere_t
 * \brief A Structure to represent a sphere
 */
typedef struct sphere {
	vec3_t	pos;		/*!< Sphere position (xyz) */
	number	r;			/*!< Sphere radius */
	vec3_t	color;		/*!< Sphere color (rgb) */
	bool	reflect;	/*!< Sphere reflection (false: disable reflection, true: enable reflection) */
} sphere_t;

/**
 * \fn u32_t SphereAdd()
 * \brief Add a sphere to the current scene
 *
 * \return a unique sphere identifier
 */
u32_t	SphereAdd			();

/**
 * \fn u32_t SphereGetCount()
 * \brief Return the total number of spheres in the current scene
 *
 * \return Number of spheres
 */
u32_t	SphereGetCount		();

/**
 * \fn void SphereSet( int idx, number x, number y, number z, number radius, vec3_t color, bool reflect );
 * \brief Set a sphere position, its radius, its color and its reflection property
 *
 * \param idx		Sphere identifier
 * \param x			Sphere x position
 * \param y			Sphere y position
 * \param z			Sphere z position
 * \param radius	Sphere radius
 * \param color		Sphere color
 * \param reflect	Sphere reflection property
 */
void	SphereSet			( int idx, number x, number y, number z, number radius, vec3_t color, bool reflect );

/**
 * \fn bool SphereHasReflection( int idx );
 * \brief Get the reflection property of a sphere
 *
 * \param idx Sphere identifier
 * \return A boolean set to true if the sphere has a material reflection property, false otherwise
 */
bool	SphereHasReflection	( int idx );

/**
 * \fn vec3_t SphereGetPosition( int idx );
 * \brief Get the position of a sphere in the current scene
 *
 * \param idx Sphere identifier
 * \return A 3D vector representing the position of the sphere
 */
vec3_t	SphereGetPosition	( int idx );

/**
 * \fn number SphereGetRadius( int idx );
 * \brief Get the radius of a sphere in the current scene
 *
 * \param idx Sphere identifier
 * \return The radius of the sphere
 */
number	SphereGetRadius		( int idx );

/**
 * \fn vec3_t SphereGetColor( int idx );
 * \brief Get the color of a sphere in the current scene
 *
 * \param idx Sphere identifier
 * \return A 3D vector representing the rgb components of the sphere
 */
vec3_t	SphereGetColor		( int idx );

/**
 * \fn vec3_t SphereGetNormal( int idx, vec3_t p )
 * \brief Get a sphere normal
 *
 * \param idx	Sphere identifier
 * \param p		Intersection point
 * \return Sphere normal
 */
vec3_t	SphereGetNormal		( int idx, vec3_t p );

#endif
