////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q16_8_FullCondSelect 1

#if ENABLE_INSTR_Q16_8_FullCondSelect == 1

	inline int instr_q168fcsel(int a, int b){
		int res;
		__asm volatile ( "q168fcsel %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline int prog_q168fcsel(int value, int dMin){
		short beta_fix = 38;
		short min   = (dMin >> 16) & 0x007FFF;
		short min2  = (dMin & 0x007FFF);
		short res;

		// ON REALISE COND SELECT
		int aValue = (value<0)?-value:value;
		if( aValue /*f_abs_fix( value )*/ == min){
			short cste_1 = (min2 - beta_fix);
			res = (cste_1 < 0)?0:cste_1;
		}else{
			short cste_2 = (min  - beta_fix);
			res = (cste_2 < 0)?0:cste_2;
		}

		// ON XOR LES SIGNES
		short sign  = (dMin >> 31) & 0x01;
		short isign = (value >> 15) & 0x0001; //Signe_de ( value );
//		short isign = Signe_de ( value );
		sign = sign ^ isign;
		
		// ON FAIT COND. INV. CondInvSign
		if (sign == 0){
			return -res;
		}else{
			return res;
		}
	}

	#define q168fcsel(a,b) instr_q168fcsel(a,b)

#endif


