////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q16_8_ABS_ 1

#if ENABLE_INSTR_Q16_8_ABS_ == 1

	inline short instr_q168abs(short a){
		int res;
		__asm ( "q168abs %1, %0 \n\t" : "=r" (res) : "r" (a) );
		return (short)res;
	}

	inline short prog_q168abs(short A){
		short S;
		if (A < 0) S = -A;
		else S = A;
		return S;
	}

	#define q168abs(a) instr_q168abs(a)

#endif
