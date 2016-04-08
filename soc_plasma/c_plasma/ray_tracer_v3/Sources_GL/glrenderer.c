/**
 * \file glrenderer.c
 * \brief OpenGL renderer
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */
 
#include "glrenderer.h"
#include "rayrender.h"

static u32_t g_width  = 0;
static u32_t g_height = 0;

static u8_t  g_imgData[ SIZE_IMG ][ SIZE_IMG ][ 3 ];
static u32_t g_texture;

void GLRendererInit( int w, int h ) {
	g_width  = w;
	g_height = h;
}

u32_t GLRendererGetTextureSize() {
	return SIZE_IMG;
}

void GLRendererDrawPixel( int x, int y, u8_t r, u8_t g, u8_t b ) {
	g_imgData[ y ][ x ][ 0 ] = r;
	g_imgData[ y ][ x ][ 1 ] = g;
	g_imgData[ y ][ x ][ 2 ] = b;
}

void GLRendererDrawRect( int x, int y, int w, int h, u8_t r, u8_t g, u8_t b ) {
	for ( int i = y; i <= y + h; i++ ) {
		for ( int j = x; j <= x + w ; j++ ) {
			if ( j > 0 && j < SIZE_IMG - 1 ) {
				if ( i > 0 && i < SIZE_IMG - 1 ) {
					GLRendererDrawPixel( j, i, r, g, b );
				}
			}
		}
	}
}

void GLRendererInit2d() {
	glViewport( 0, 0, g_width, g_height );
	glClearColor( 0.2f, 0.2f, 0.2f, 1.0f );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	glEnable( GL_BLEND );
	glBlendEquation( GL_FUNC_ADD );
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	glDisable( GL_TEXTURE_2D );
	glEnable( GL_DEPTH_TEST );
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	gluOrtho2D( 0, g_width, 0, g_height );
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
}

void GLRendererSetupTexture() {
	GLRendererDrawRect( 0, 0, SIZE_IMG, SIZE_IMG, 0, 0, 0 );
	glGenTextures( 1, &g_texture );
	glBindTexture( GL_TEXTURE_2D, g_texture );
	glTexImage2D( GL_TEXTURE_2D, 0, 3, SIZE_IMG, SIZE_IMG, 0, GL_RGB, GL_UNSIGNED_BYTE, ( void * )g_imgData );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glBindTexture( GL_TEXTURE_2D, 0 );
	glDisable( GL_TEXTURE_2D );
}

void GLRendererDrawImage() {
	glEnable( GL_TEXTURE_2D );
	glBindTexture( GL_TEXTURE_2D, g_texture );
	glTexImage2D( GL_TEXTURE_2D, 0, 3, SIZE_IMG, SIZE_IMG, 0, GL_RGB, GL_UNSIGNED_BYTE, ( void * )g_imgData );
	glColor4ub( 255, 255, 255, 255 );
	glBegin( GL_QUADS );
	glTexCoord2f( 0.0f, 0.0f ); glVertex3f( 0.0f		   , (float)g_height , -0.01f );
	glTexCoord2f( 1.0f, 0.0f ); glVertex3f( (float)g_width , (float)g_height , -0.01f );
	glTexCoord2f( 1.0f, 1.0f ); glVertex3f( (float)g_width , 0.0f			 , -0.01f );
	glTexCoord2f( 0.0f, 1.0f ); glVertex3f( 0.0f		   , 0.0f			 , -0.01f );
	glEnd();
	glBindTexture( GL_TEXTURE_2D, 0 );
	glDisable( GL_TEXTURE_2D );
}

void GLRendererSetTextureImage( ) {
	glBindTexture( GL_TEXTURE_2D, g_texture );
	glTexSubImage2D( GL_TEXTURE_2D, 0, 0, 0, SIZE_IMG, SIZE_IMG, GL_RGB, GL_UNSIGNED_BYTE, ( void * )g_imgData );
}
