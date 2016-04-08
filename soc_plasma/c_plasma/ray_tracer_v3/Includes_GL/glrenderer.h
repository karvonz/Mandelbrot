/**
 * \file glrenderer.h
 * \brief OpenGL renderer
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */

#ifndef __GL_RENDERER_H__
#define __GL_RENDERER_H__

#include "GL/glew.h"
#include "SDL2/SDL_opengl.h"

#include "raytypes.h"

/**
 * \fn void	GLRendererInit( int w, int h )
 * \brief Init OpenGL renderer
 *
 * \param w			renderer width
 * \param h			renderer height
 */
void	GLRendererInit				( int w, int h );

/**
 * \fn void	GLRendererInit2d()
 * \brief Init OpenGL renderer for 2d drawing
 */
void	GLRendererInit2d			();

/**
 * \fn void	GLRendererSetupTexture()
 * \brief Setup OpenGL texture output
 */
void	GLRendererSetupTexture		();

/**
 * \fn void	GLRendererSetTextureImage()
 * \brief Set the texture as OpenGL output
 */
void	GLRendererSetTextureImage	();

/**
 * \fn u32_t GLRendererGetTextureSize()
 * \brief Get the texture size
 *
 * \return Texture size
 */
u32_t	GLRendererGetTextureSize	();

/**
 * \fn void	GLRendererDrawPixel( int x, int y, u8_t r, u8_t g, u8_t  b )
 * \brief Draw a pixel
 *
 * \param x			x position
 * \param y			y position
 * \param r			red
 * \param g			green
 * \param b			blue
 */
void	GLRendererDrawPixel			( int x, int y, u8_t r, u8_t g, u8_t  b );

/**
 * \fn void	GLRendererDrawRect( int x, int y, int w, int h, u8_t r, u8_t g, u8_t b )
 * \brief Draw a pixel
 *
 * \param x			x position
 * \param y			y position
 * \param w			w width
 * \param h			h width
 * \param r			red
 * \param g			green
 * \param b			blue
 */
void	GLRendererDrawRect			( int x, int y, int w, int h, u8_t r, u8_t g, u8_t b );

/**
 * \fn void	GLRendererDrawImage()
 * \brief Draw rendered image
 */
void	GLRendererDrawImage			();

#endif
