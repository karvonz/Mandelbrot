////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_uDIVIDER_32b	1

#if ENABLE_INSTR_uDIVIDER_32b == 1
	inline int instr_fudiv(int a, int b){
		int res;
		__asm ( "fudiv %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline int prog_fudiv(int a, int b){
		return (a/b);
	}

	#define fudiv(a,b) instr_fudiv(a,b)

#endif
