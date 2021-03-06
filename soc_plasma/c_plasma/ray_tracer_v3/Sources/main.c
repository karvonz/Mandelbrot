/**
 * \file main.c
 * \brief Raytracer main file
 * \author J. Crenne & C. Leroux
 * \version 1.0
 * \date February 2016
 */
 
/**
 * \def RENDER_OPENGL
 * \brief OpenGL rendering
 */
//#define RENDER_OPENGL

/**
 * \def RENDER_IMAGE
 * \brief Render to image
 */
//#define RENDER_IMAGE

/**
 * \def PLASMA
 * \brief Plasma processor implementation
 */
//#define PLASMA
#define IMG_PPM

#include <stdio.h>
#include <stdbool.h>

#include "../Includes/raytypes.h"
#include "../Includes/raymath.h"
#include "../Includes/raymathfix.h"
#include "../Includes/rayrender.h"

#ifdef RENDER_OPENGL
#include "GL/glew.h"
#include "SDL2/SDL.h"
#include "text.h"
#include "glrenderer.h"
#endif

#ifdef PLASMA

#include <stdbool.h>

#include "../../shared/plasmaCoprocessors.h"
#include "../../shared/plasmaIsaCustom.h"
#include "../../shared/plasmaMisc.h"
#include "../../shared/plasmaSoPCDesign.h"
#include "../../shared/plasmaMyPrint.h"


#define MemoryRead(A)     (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)

#endif

int main( int argc, char ** argv ) {

#ifdef RENDER_OPENGL
	// SDL event, window and display mode
    SDL_Event event;
    SDL_Window * window;
    SDL_DisplayMode current;

	// window size
    int width = 1024;
    int height = 768;

    bool done = false;

    float fps = 0.0;
    char sfps[40] = "FPS: ";
	
	// init SDL library
    if ( SDL_Init( SDL_INIT_EVERYTHING ) < 0 ) {
        printf( "error: unable to init SDL\n" );
        return -1;
    }

	// get current desktop display mode
    if ( SDL_GetDesktopDisplayMode( 0, &current ) ) {
        printf( "error: unable to get current display mode\n" );
        return -1;
    }
	
	// set antialiasing on
    SDL_GL_SetAttribute( SDL_GL_MULTISAMPLEBUFFERS, 1 );
    SDL_GL_SetAttribute( SDL_GL_MULTISAMPLESAMPLES, 4 );

	// create and show the main window
    window = SDL_CreateWindow( 	"Raytracer - J.Crenne & C.Leroux",
								SDL_WINDOWPOS_CENTERED,
								SDL_WINDOWPOS_CENTERED,
								width, height,
								SDL_WINDOW_OPENGL );

	// create an OpenGL render context
    SDL_GLContext glWindow = SDL_GL_CreateContext( window );

	// init GLEW (for modern OpenGL API calls)
    GLenum status = glewInit();

	// check is everything is fine
    if ( status != GLEW_OK ) {
        printf( "error: unable to init GLEW\n" );
        return -1;
    }
	
	// init and check text resources availability
    if ( ! TextInit( "./DroidSans.ttf" ) ) {
        printf( "error: unable to init text resources\n" );
        return -1;
    }
	
	// double buffering swap interval
    SDL_GL_SetSwapInterval( 1 );

    GLRendererInit( width, height );
    GLRendererSetupTexture();
#endif //RENDER_OPENGL

    number a = T( 0.1f ); 										// ambient lighting
    vec3_t l = MathVec3Set( T( 0.0f ), T( 1.2f ), T( 3.75f ) ); // point light source position
    u32_t size = SIZE_IMG; 										// rendered image size

	// render setup and reset
    RenderSetup(l, a, size);
    RenderReset();

	// add 2 spheres to scene
    int sphere1 = SphereAdd();
    int sphere2 = SphereAdd();

	// set spheres radius and position spheres in scene
    SphereSet( sphere1, T( -0.6f ), T( 1.0f ), T( 4.0f ), T( 0.25f ), MathVec3Set( T( 0.0f), T( 1.0f ), T( 0.0f ) ), true);
    SphereSet( sphere2, T( -0.6f ), T( -1.0f ), T( 3.5f ), T( 0.5f ), MathVec3Set( T( 0.0f), T( 0.0f ), T( 1.0f ) ), false);

	// add 6 planes to scene
    int plane1 = PlaneAdd();
    int plane2 = PlaneAdd();
    int plane3 = PlaneAdd();
    int plane4 = PlaneAdd();
    int plane5 = PlaneAdd();
    int plane6 = PlaneAdd();

	// set planes axis and position in scene
    PlaneSet( plane1, 0, T(  1.5f ), MathVec3Set( T( 0.0 ), T( 1.0 ), T( 0.0 ) ) );
    PlaneSet( plane2, 1, T( -1.5f ), MathVec3Set( T( 1.0 ), T( 1.0 ), T( 1.0 ) ) );
    PlaneSet( plane3, 0, T( -1.5f ), MathVec3Set( T( 1.0 ), T( 0.0 ), T( 0.0 ) ) );
    PlaneSet( plane4, 1, T(  1.5f ), MathVec3Set( T( 1.0 ), T( 1.0 ), T( 1.0 ) ) );
    PlaneSet( plane5, 2, T(  5.0f ), MathVec3Set( T( 1.0 ), T( 1.0 ), T( 1.0 ) ) );
    PlaneSet( plane6, 2, T( -0.5f ), MathVec3Set( T( 1.0 ), T( 1.0 ), T( 1.0 ) ) );

#ifdef RENDER_IMAGE
    u32_t i;
    u32_t j;
	// open a file for writing rendered data
    FILE * file = fopen( "out.ppm", "w" );
	// format is ppm, set the header
    fprintf( file, "P3\n" );
    fprintf( file, "%d %d\n", size, size );
    fprintf( file, "255\n" );
	// render image
    for ( i = 0; i < size; i++ ) {
        for ( j = 0; j < size; j++ ) {
            vec3_t rgb = RenderComputePixelColor( size, (number)j, (number)i );
#ifdef FIX_IMP
            fprintf( file, "%d %d %d ", (int)( MathFix2Float( rgb.x ) * 255.0f ), (int)( MathFix2Float( rgb.y ) * 255.0f ), (int)( MathFix2Float( rgb.z ) * 255.0f ) );
#else
            rgb = Vec3Scale( rgb, T( 255.0f ) );
            fprintf( file, "%d %d %d ", (u8_t)rgb.x, (u8_t)rgb.y, (u8_t)rgb.z);
#endif //FIX_IMP
        }
        fprintf( file, "\n" );
    }
    fclose( file );
#else
#ifdef RENDER_OPENGL
    while ( ! done ) {
		// user input events handling 
        while ( SDL_PollEvent( &event )) {
            u32_t e = event.type;
            if ( e == SDL_KEYDOWN ) {
                if ( event.key.keysym.sym == SDLK_r ) {
                    RenderReset();
                } else if ( event.key.keysym.sym == SDLK_ESCAPE ) {
                    done = true;
                }
            } else if ( e == SDL_QUIT ) {
                done = true;
            }
        }
		// init renderer, render and draw the result to an image
        GLRendererInit2d();
        Render();
        GLRendererDrawImage();
		// draw a text label
        TextDraw( 10.0f, height - 20.0f, "'r' : reset rendering", TEXT_ALIGN_LEFT, RGBA( 255, 255, 255, 255) );
		// swap between front and back buffer
		SDL_GL_SwapWindow( window );
		// update window
        SDL_UpdateWindowSurface( window );
    }
	// release OpenGL context, text resources, window and quit
    SDL_GL_DeleteContext( glWindow );
    TextDestroy();
    SDL_DestroyWindow( window );
    SDL_Quit();
#endif
#endif

#ifdef PLASMA
    int i, j;
    unsigned int t_start, t_end;
    int tmp;
	 int width, height;

	 int red_pix, green_pix, blue_pix, vga_pix;
	 puts( "debut du programme:\n" );
	 size = 500;
	 
	 // RESET IP VGA
	 coproc_reset(COPROC_4_RST);
	 
	 width = 640;
	 height = 480;
	 
  	 int t0, t1, t2, t3;

	 t_start = r_timer();
    for ( i = 0; i < height; i++ ) {
        for ( j = 0; j < width; j++ ) {
				//t0 = r_timer(); // profiling
            vec3_t rgb = RenderComputePixelColor( size, j, i );
            //t1 = r_timer(); // profiling
				//my_printf("pix compute time = ",t1-t0); // profiling
            /*ta=rgb.x;
				tb=rgb.y;
				
				tc = (ta*tb)  >> FIX_SHIFT;
				t_end = r_timer();*/
				//my_printf("tc=",tc);
				/*my_printf("tps soft=",t_end-t_start);
				t_start = r_timer();
				td = isa_custom_1(ta,tb);
				t_end = r_timer();*/
				
				//my_printf("tps hard=",t_end-t_start);
            /*my_printf("r :", (rgb.x));
            my_printf("g :", (rgb.y));
            my_printf("b :", (rgb.z));*/
				
				red_pix = ( ( rgb.x >> ( FIX_SHIFT - 8 ) ) );
				green_pix = ( ( rgb.y >> ( FIX_SHIFT - 8 ) ) );
				blue_pix = ( ( rgb.z >> ( FIX_SHIFT - 8 ) ) );
				
				vga_pix = ((red_pix >> 4) << 8) | ((green_pix >> 4) << 4) | (blue_pix >> 4); // 12 bits
				//vga_pix = ((red_pix >> 4) << 7) | ((green_pix >> 4) << 3) | (blue_pix >> 5); // 11 bits
				//vga_pix = ((red_pix >> 5) << 7) | ((green_pix >> 4) << 3) | (blue_pix >> 5); // 10 bits
				/*my_printf("red:",red_pix);
				my_printf("green:",green_pix);
				my_printf("blue:",blue_pix);
				my_printf("vga:",vga_pix);*/
				coproc_write(COPROC_4_RW, vga_pix);
            //o_write( ( rgb.x >> ( FIX_SHIFT - 8 ) ) );
            //o_write( ( rgb.y >> ( FIX_SHIFT - 8 ) ) );
            //o_write( ( rgb.z >> ( FIX_SHIFT - 8 ) ) );
				
				}
				//my_printf( "l ", t_end);
    }
    t_end = r_timer();
    my_printf( "tps exec :", t_end - t_start );

    puts( "fin du programme:\n" );
    stop();
#endif//PLASMA
	 
#ifdef IMG_PPM
	 printf("img ppm\n");
	 FILE *ptr_file;
	 ptr_file = fopen("image.ppm","w");

    int i, j;
    int tmp;
	 int width, height;

	 int red_pix, green_pix, blue_pix, vga_pix;
	
	 size = 500;
	 
	 width = 640;
	 height = 480;
	 fprintf(ptr_file, "P3\n");
	 fprintf(ptr_file, "%d %d\n", width, height);
	 fprintf(ptr_file, "255\n");

	 int data_count = 0;
    for ( i = 0; i < height; i++ ) {
        for ( j = 0; j < width; j++ ) {

            vec3_t rgb = RenderComputePixelColor( size, j, i );
            red_pix = ( ( rgb.x >> ( FIX_SHIFT - 8 ) ) );
				green_pix = ( ( rgb.y >> ( FIX_SHIFT - 8 ) ) );
				blue_pix = ( ( rgb.z >> ( FIX_SHIFT - 8 ) ) );
				
            /*fprintf(ptr_file, "%d ", red_pix );
				fprintf(ptr_file, "%d ", green_pix );
				fprintf(ptr_file, "%d ", blue_pix );*/
				red_pix = (red_pix >> 4) << 4;
				green_pix = (green_pix >> 4) << 4;
				blue_pix = (blue_pix >> 4) << 4;
				fprintf(ptr_file, "%d ", red_pix );
				fprintf(ptr_file, "%d ", green_pix );
				fprintf(ptr_file, "%d ", blue_pix );
				if(data_count > 200) 
				{
				  fprintf(ptr_file, "\n");
				  data_count =0;
				}
				data_count++;
				//red_pix = ( ( rgb.x >> ( FIX_SHIFT - 8 ) ) );
				//green_pix = ( ( rgb.y >> ( FIX_SHIFT - 8 ) ) );
				//blue_pix = ( ( rgb.z >> ( FIX_SHIFT - 8 ) ) );
				
				//vga_pix = ((red_pix >> 4) << 8) | ((green_pix >> 4) << 4) | (blue_pix >> 4); // 12 bits
				            
        }
    }

#endif
    return 1;
}
