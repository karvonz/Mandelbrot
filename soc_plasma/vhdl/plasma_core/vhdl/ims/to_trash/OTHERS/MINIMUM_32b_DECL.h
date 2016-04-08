////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_MINIMUM_32b	1

#if ENABLE_INSTR_MINIMUM_32b == 1
	inline int instr_min(int a, int b){
		int res;
		__asm( "min %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline int prog_min(int a, int b){
		return (a<b)?a:b;
	}

	#define min(a,b) instr_min(a,b)
#endif
