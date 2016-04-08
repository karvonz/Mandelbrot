////////////////////////////////////////////////////////////////
//
//
//
//
//////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_REVERSE_BIT	1

#if ENABLE_INSTR_REVERSE_BIT == 1

	inline int instr_rbit(int a){
		int res;
		__asm( "rbit %1, %0 \n\t" : "=r" (res) : "r" (a) );
		return res;
	}

	inline int prog_rbit(int a) {
		int h = 0;
		for(int i = 0; i < 32; i++) {
			h = (h << 1) + (a & 1); 
			a >>= 1; 
		}
		return h;
	}
	
	#define rbit(a) instr_rbit(a)

#endif



