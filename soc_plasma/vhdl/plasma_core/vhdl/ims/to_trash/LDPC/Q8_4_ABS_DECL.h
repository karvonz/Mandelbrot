////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q8_4_ABS_ 1

#if ENABLE_INSTR_Q8_4_ABS_ == 1

	inline int instr_q84abs(int a){
		int res;
		__asm ( "q84abs %1, %0 \n\t" : "=r" (res) : "r" (a) );
		return res;
	}

	inline int prog_q84abs(int A){
		short S;
		if (A < 0) S = -A;
		else S = A;
		return S;
	}

	#define q84abs(a) instr_q84abs(a)

#endif
