////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_SEQ_SUM_8d_8b_6c 1

#if ENABLE_INSTR_SEQ_SUM_8d_8b_6c == 1

	inline int instr_seqsum(int a, int b){
		int res;
		__asm volatile ( "seqsum %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline int prog_seqsum(int A, int B){
		unsigned char *a = (unsigned char*)&A;
		unsigned char *b = (unsigned char*)&B;
		int res = ((int)a[0]) + ((int)b[0]);
		res    += ((int)a[1]) + ((int)b[1]);
		res    += ((int)a[2]) + ((int)b[2]);
		res    += ((int)a[3]) + ((int)b[3]);
		return res;
	}

	#define seqsum(a,b) instr_seqsum(a,b)

#endif

