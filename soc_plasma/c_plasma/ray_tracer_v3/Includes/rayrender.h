/**
 * \file rayrender.h
 * \brief Raytracer scene rendering
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */

#ifndef __RAY_RENDER_H__
#define __RAY_RENDER_H__

#include <stdio.h>
#include <stdbool.h>
#include <float.h>

#include "raymath.h"
#include "rayintersect.h"
#include "raylight.h"
//#include "glrenderer.h"

/**
 * \def SIZE_IMG
 * \brief Size of image output
 */
#define SIZE_IMG	4

/**
 * \fn void RenderSetup( vec3_t l, number ambient, u32_t maxr );
 * \brief Setup the render context
 *
 * \param l			Point light position
 * \param ambient	Ambient light multiplier factor
 * \param maxr		Maximum render resolution
 */
void	RenderSetup				( vec3_t l, number ambient, u32_t maxr );

/**
 * \fn void RenderReset( );
 * \brief Reset the render context
 */
void	RenderReset				();

/**
 * \fn void Render( );
 * \brief Render the current scene
 */
void	Render					();

/**
 * \fn vec3_t RenderComputePixelColor( u32_t size, number x, number y )
 * \brief Render the current scene
 *
 * \param size	Size of output "pixel"
 * \param x		Pixel x position
 * \param y		Pixel y position
 * \return A 3D vector representing the computed pixel color
 */
vec3_t	RenderComputePixelColor	( u32_t size, number x, number y );

#endif
