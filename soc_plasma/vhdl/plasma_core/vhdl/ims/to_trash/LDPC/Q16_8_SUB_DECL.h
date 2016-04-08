////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q16_8_SUB 1

#if ENABLE_INSTR_Q16_8_SUB == 1

	inline short instr_q168sub(short a, short b){
		short res;
		__asm ( "q168sub %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline short prog_q168sub(short A, short B){
		int C = ((int)A) - ((int)B);
		if( C > 32767 ){
			C = 32767;
		}else if( C < -32768 ){
			C = -32768;
		}
		return (short)C;
	}

	#define q168sub(a) instr_q168sub(a)

#endif


