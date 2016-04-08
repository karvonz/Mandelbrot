////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_Q16_8_DoubleMini 1

#if ENABLE_INSTR_Q16_8_DoubleMini == 1

	inline int instr_q168dmini(int a, int b){
		int res;
		__asm ( "q168dmini %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline int prog_q168dmini(short input, int miniS){
		short mini1 = miniS >> 16;
		short mini2 = miniS & 0x00FFFF;
		if (input < 0){
			input = -input;
		}
    	if(input < mini1){
			mini2 = mini1;
			mini1  = input;
    	}else if(input < mini2){
			mini2 = input;
			mini1 = mini1;
    	}
		return (((int)mini1) << 16) | ((int)mini2);
	}

	#define q168dmini(a,b) instr_q168dmini(a,b)

#endif


