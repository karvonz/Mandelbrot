/**
 * \file raylight.h
 * \brief Raytracer light
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */

#ifndef __RAY_LIGHT_H__
#define __RAY_LIGHT_H__

#include "raymath.h"
#include "rayobject.h"

/**
 * \fn number LightObject( int type, int idx, vec3_t l, vec3_t p, number lightAmbient )
 * \brief Get light contribution
 *
 * \param type			Object type ( OBJECT_TYPE_SPHERE or OBJECT_TYPE_PLANE )
 * \param idx			Object identifier
 * \param l 			Light position
 * \param p 			Intersection point position
 * \param lightAmbient	Ambient light multiplier
 * \return Light contribution to object
 */
number LightObject( int type, int idx, vec3_t l, vec3_t p, number lightAmbient );

#endif
