////////////////////////////////////////////////////////////////
//
//
//
//
//////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_rSHIFT	1

#if ENABLE_INSTR_rSHIFT == 1
	inline int instr_rshift(int a, int b){
		int res;
		__asm( "rshift %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline int prog_rshift(int a, int b){
		return (a >> b);
	}

	#define rshift(a,b) instr_rshift(a,b)

#endif



