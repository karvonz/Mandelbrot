////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q16_8_CondSelect 1

#if ENABLE_INSTR_Q16_8_CondSelect == 1

	inline short instr_q168csel(short signe, int value){
		int res;
		__asm ( "q168csel %1, %2, %0 \n\t" : "=r" (res) : "r" (signe), "r" (value) );
		return (short)res;
	}

	inline short prog_q168csel(short value, int dMin){
		short beta_fix = 38;
		short min  = dMin >> 16;
		short min2 = dMin & 0x00FFFF;
		if (value < 0) value = -value; // VALEUR ABSOLUE
		if( value == min){
			short cste_1 = (min2 - beta_fix);
			cste_1 = (cste_1 < 0)?0:cste_1;
			return cste_1;
		}
		short cste_2 = (min  - beta_fix);
		cste_2 = (cste_2 < 0)?0:cste_2;
		return cste_2;
	}

	#define q168csel(a,b) instr_q168csel(a,b)

#endif


