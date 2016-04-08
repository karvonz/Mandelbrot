/**
 * \file text.h
 * \brief OpenGL text drawing
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */

#ifndef __TEXT_H__
#define __TEXT_H__

/**
 * \def RGBA
 * \brief Pack unpacked rgba values into an integer
 */
#define RGBA( r, g, b, a ) (r) | (g << 8) | (b << 16) | (a << 24)

/**
 * \def TEXT_ALIGN_LEFT
 * \brief Text alignment macro (left)
 */
#define TEXT_ALIGN_LEFT		0

/**
 * \def TEXT_ALIGN_RIGHT
 * \brief Text alignment macro (right)
 */
#define TEXT_ALIGN_RIGHT	1

/**
 * \def TEXT_ALIGN_CENTER
 * \brief Text alignment macro (center)
 */
#define TEXT_ALIGN_CENTER	2

/**
 * \fn bool TextInit( char * font )
 * \brief Init text resources
 *
 * \param font Path to a truetype font file (.ttf)
 * \return A boolean set to true if initialization was succesful, false otherwise
 */
bool TextInit		( char * font );

/**
 * \fn void TextDestroy()
 * \brief Free text resources
 */
void TextDestroy	();

/**
 * \fn void TextDraw( float x, float y, const char * text, int align, unsigned int col )
 * \brief Draw a text on screen
 *
 * \param x x position
 * \param y y position
 * \param text text to draw
 * \param align text alignment
 * \param col text color (packed rgba value)
 * \return A boolean set to true if initialization was succesful, false otherwise
 */
void TextDraw		( float x, float y, const char * text, int align, unsigned int col );

#endif
