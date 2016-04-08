////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q16_8_CondInv 1

#if ENABLE_INSTR_Q16_8_CondInv == 1

	inline short instr_q168cinv(short signe, short value){
		int res;
		__asm ( "q168cinv %1, %2, %0 \n\t" : "=r" (res) : "r" (signe), "r" (value) );
		return (short)res;
	}

	inline short prog_q168cinv(short signe, short value){
		if (signe == 0){
			return -value;
		}
		return value;
	}

	#define q168cinv(a,b) instr_q168cinv(a,b)

#endif


