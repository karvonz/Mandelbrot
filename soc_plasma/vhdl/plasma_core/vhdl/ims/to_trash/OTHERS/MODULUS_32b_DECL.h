////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_MODULUS_32b	1

#if ENABLE_INSTR_MODULUS_32b == 1
	inline int instr_mod(int a, int b){
		int res;
		__asm ( "umod %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline int prog_mod(int a, int b){
		return (a%b);
	}

	#define mod(a,b) instr_mod(a,b)

#endif
