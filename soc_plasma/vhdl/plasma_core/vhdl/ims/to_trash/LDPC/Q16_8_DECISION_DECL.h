////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q16_8_DECISION_ 1

#if ENABLE_INSTR_Q16_8_DECISION_ == 1

	inline short instr_q168decision(short a){
		int res;
		__asm ( "q168decision %1, %0 \n\t" : "=r" (res) : "r" (a) );
		return (short)res;
	}

	inline short prog_q168decision(short A){
		short S;
		if (A < 0) S = 0;
		else S = 1;
		return S;
	}

	#define q168decision(a) instr_q168decision(a)

#endif
