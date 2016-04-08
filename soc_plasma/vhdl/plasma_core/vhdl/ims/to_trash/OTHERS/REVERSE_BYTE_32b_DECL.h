////////////////////////////////////////////////////////////////
//
//
//
//
//////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_REVERSE_BYTE	1

#if ENABLE_INSTR_REVERSE_BYTE == 1

	inline int instr_rbyte(int a){
		int res;
		__asm( "rbyte %1, %0 \n\t" : "=r" (res) : "r" (a) );
		return res;
	}

	inline int prog_rbyte(int a){
		int p0 = (a >> 24) & 0x000000FF;
		int p1 = ((a & 0x00FF0000) >>  8);
		int p2 = ((a & 0x0000FF00) <<  8);
		int p3 = ((a & 0x000000FF) << 24);
		return (p3) | (p2) | (p1) | (p0);
	}

	#define rbyte(a) instr_rbyte(a)

#endif

