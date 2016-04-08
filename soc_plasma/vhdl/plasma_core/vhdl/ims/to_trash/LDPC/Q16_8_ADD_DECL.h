////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q16_8_ADD 1

#if ENABLE_INSTR_Q16_8_ADD == 1

	inline short instr_q168add(int a, short b){
		int res;
		__asm ( "q168add %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return (short)res;
	}

	inline short prog_q168add(int A, short B){
		int C = A + (int)B;
		if( C > 32767 ){
			C = 32767;
		}else if( C < -32768 ){
			C = -32768;
		}
		return (short)C;
	}

	#define q168add(a,b) instr_q168add(a,b)

#endif


