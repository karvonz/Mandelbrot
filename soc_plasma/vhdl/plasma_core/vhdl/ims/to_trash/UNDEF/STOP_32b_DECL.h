////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_STOP_32b	1

#if ENABLE_INSTR_STOP_32b == 1

	inline int instr_stop(int a){
		int res;
		__asm volatile( "stop %1, %0 \n\t" : "=r" (res) : "r" (a) );
		return res;
	}

	inline int prog_stop(int a){
		return a + 0;
	}


	#define stop(a) instr_stop(a)

#endif
