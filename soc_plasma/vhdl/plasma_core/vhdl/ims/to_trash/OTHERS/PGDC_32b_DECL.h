////////////////////////////////////////////////////////////////
//
//
//
//
//////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_PDDC	1

#if ENABLE_INSTR_PDDC == 1

	inline int instr_pgdc(int a, int b){
		int res;
		__asm( "pgdc %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline int prog_pgdc(int a, int b){
		if((a==0) || (b == 0)) return 0;
		while( a != b ){
			if( a > b ) a = a - b;
			else if( b > a ) b = b - a;
		}
		return a;
	}

	#define pgdc(a,b) instr_pgdc(a,b)

#endif



