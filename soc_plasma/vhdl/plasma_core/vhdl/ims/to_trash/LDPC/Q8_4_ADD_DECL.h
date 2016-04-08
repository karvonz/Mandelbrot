////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q8_4_ADD 1

#if ENABLE_INSTR_Q8_4_ADD == 1

	inline int instr_q84add(int a, int b){
		int res;
		__asm ( "q84add %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return (short)res;
	}

	inline int prog_q84add(int A, int B){
		int C = A + (int)B;
		if( C > 127 ){
			C = 127;
		}else if( C < -128 ){
			C = -128;
		}
		return C;
	}

	#define q84add(a,b) instr_q84add(a,b)

#endif


