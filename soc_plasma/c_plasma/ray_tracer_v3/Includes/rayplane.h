/**
 * \file rayplane.h
 * \brief Raytracer plane object
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */

#ifndef __RAY_PLANE_H__
#define __RAY_PLANE_H__

#include "raymath.h"

/**
 * \def MAX_PLANES
 * \brief Maximum number of planes in the current scene
 */
#define MAX_PLANES	16

/**
 * \typedef plane_t
 * \brief A Structure to represent a plane
 */
typedef struct plane {
	number axis;		/*!< Plane axis (0 : x, 1 : y, 2 : z) */
	number dist;		/*!< Plane distance to camera */
	vec3_t color;		/*!< Plane color (rgb) */
} plane_t;

/**
 * \fn u32_t PlaneAdd()
 * \brief Add a plane to the current scene
 *
 * \return a unique plane identifier
 */
u32_t	PlaneAdd		();

/**
 * \fn u32_t PlaneGetCount()
 * \brief Return the total number of planes in the current scene
 *
 * \return Number of planes
 */
u32_t	PlaneGetCount	();

/**
 * \fn void PlaneSet( int idx, number axis, number dist, vec3_t color )
 * \brief Set a plane axis, its distance to camera and its color
 *
 * \param idx	Plane identifier
 * \param axis	Plane axis
 * \param dist	Plane distance to camera
 * \param color Plane color
 */
void	PlaneSet		( int idx, number axis, number dist, vec3_t color );

/**
 * \fn number PlaneGetAxis( int idx )
 * \brief Get a plane axis
 *
 * \param idx Plane identifier
 * \return Plane axis
 */
int		PlaneGetAxis	( int idx );

/**
 * \fn number PlaneGetDistance( int idx )
 * \brief Get a plane distance from camera
 *
 * \param idx Plane identifier
 */
number	PlaneGetDistance( int idx );

/**
 * \fn vec3_t PlaneGetColor( int idx )
 * \brief Get a plane color
 *
 * \param idx Plane identifier
 * \return Plane color
 */
vec3_t	PlaneGetColor	( int idx );

/**
 * \fn vec3_t PlaneGetNormal( int idx, vec3_t o )
 * \brief Get a plane normal
 *
 * \param idx	Plane identifier
 * \param o		origin
 * \return Plane normal
 */
vec3_t	PlaneGetNormal	( int idx, vec3_t o );

#endif
