////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q16_8_SIGN 1

#if ENABLE_INSTR_Q16_8_SIGN == 1

	inline short instr_q168sign(short a){
		short res;
		__asm ( "q168sign %1, %0 \n\t" : "=r" (res) : "r" (a) );
		return res;
	}

	inline short prog_q168sign(short A){
		return (A >> 15) & 0x0001;
	}

	#define q168sign(a) instr_q168sign(a)

#endif


