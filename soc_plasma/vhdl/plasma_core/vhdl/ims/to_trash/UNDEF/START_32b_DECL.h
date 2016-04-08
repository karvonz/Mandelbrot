////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_START_32b	1

#if ENABLE_INSTR_START_32b == 1

	inline int instr_start(int a){
		int res;
		__asm volatile( "start %1, %0 \n\t" : "=r" (res) : "r" (a) );
		return res;
	}

	inline int prog_start(int a){
		return a + 0;
	}


	#define start(a) instr_start(a)

#endif
