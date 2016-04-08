////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q16_8_FullXorMin 1

#if ENABLE_INSTR_Q16_8_FullXorMin == 1

	inline int instr_q168fxormin(int a, int b){
		int res;
		__asm volatile ( "q168fxormin %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline int prog_q168fxormin(int input, int miniS){
		short mini1 = (miniS >> 16) & 0x007FFF;
		short mini2 = miniS & 0x007FFF;
		short sign  = (miniS >> 31) & 0x01;

		short isign = (input >> 15) & 0x0001;
		//short isign = Signe_de ( input );
		//input = f_abs_fix      ( input );
		input = (input<0)?-input:input;
		
		if(input < mini1){
			mini2 = mini1;
			mini1  = input;
		}else if(input < mini2){
			mini2 = input;
			mini1 = mini1;
		}
		
		sign = sign ^ isign;
		
		return (((int)sign) << 31) | (((int)mini1) << 16) | ((int)mini2);
	}

	#define q168fxormin(a,b) instr_q168fxormin(a,b)

#endif


