////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_RGB2YUV	1

#if ENABLE_INSTR_RGB2YUV == 1

	inline int instr_rgb2yuv(int a){
		int res;
		__asm ( "rgb2yuv %1, %0 \n\t" : "=r" (res) : "r" (a) );
		return res;
	}

	#define Nc  12
	#define C1 (int)( 0.299   * (1 << Nc))
	#define C2 (int)(0.16874  * (1 << Nc))
	#define C3 (int)( 0.5     * (1 << Nc))
	#define C4 (int)( 0.587   * (1 << Nc))
	#define C5 (int)( 0.33126 * (1 << Nc))
	#define C6 (int)( 0.41869 * (1 << Nc))
	#define C7 (int)( 0.114   * (1 << Nc))
	#define C8 (int)( 0.5     * (1 << Nc))
	#define C9 (int)( 0.08131 * (1 << Nc))
	#define OF (int)( 128     * (1 << Nc))

	inline int prog_rgb2yuv(int a){
		int R = (a & 0x0000FF);
		int G = (a & 0x00FF00);
		int B = (a & 0xFF0000);
		int Y = ((     C1 * R + C4 * G + C7 * B) >> Nc);
		int U = ((OF - C2 * R - C5 * G + C8 * B) >> Nc);
		int V = ((OF + C3 * R - C6 * G - C9 * B) >> Nc);
		Y = (Y>255)?255:Y; Y = (Y<0)?0:Y;
		U = (U>255)?255:U; U = (U<0)?0:U;
		V = (V>255)?255:V; V = (V<0)?0:V;
		return (V << 16) | (U << 8) | Y;
	}
	#undef Nc

	#define rgb2yuv(a) instr_rgb2yuv(a)

#endif

