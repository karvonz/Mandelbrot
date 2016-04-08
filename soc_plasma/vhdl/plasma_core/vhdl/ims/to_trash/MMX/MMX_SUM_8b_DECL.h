////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_MMX_SUM_8b 1

#if ENABLE_INSTR_MMX_SUM_8b == 1
inline int instr_v8sum(int a, int b){
	int res;
	__asm volatile ( "v8sum %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
	return res;
}
#endif

inline int prog_v8sum(int A, int B){
	unsigned char *a = (unsigned char*)&A;
	unsigned char *b = (unsigned char*)&B;
	int res = ((int)a[0]) + ((int)b[0]);
	res    += ((int)a[1]) + ((int)b[1]);
	res    += ((int)a[2]) + ((int)b[2]);
	res    += ((int)a[3]) + ((int)b[3]);
	return res;
}

#if ENABLE_INSTR_MMX_SUM_8b == 1
	#define v8sum(a,b) instr_v8sum(a,b)
#else
	#define v8sum(a,b) prog_v8sum(a,b)
#endif


