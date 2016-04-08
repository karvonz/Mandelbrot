////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q8_4_DECISION_ 1

#if ENABLE_INSTR_Q8_4_DECISION_ == 1

	inline int instr_q84decision(int a){
		int res;
		__asm ( "q84decision %1, %0 \n\t" : "=r" (res) : "r" (a) );
		return res;
	}

	inline int prog_q84decision(int A){
		int S;
		if (A < 0) S = 0;
		else S = 1;
		return S;
	}

	#define q84decision(a) instr_q84decision(a)

#endif
