////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_MMX_MIN_8b 1

#if ENABLE_INSTR_MMX_MIN_8b == 1
inline int instr_v8min(int a, int b){
	int res;
	__asm ( "v8min %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
	return res;
}
#endif

#define DEC_MIN(a,b) ((a>b)?a:b)
inline int prog_v8min(int A, int B){
	int res = 0;
	unsigned char *a = (unsigned char*)&A;
	unsigned char *b = (unsigned char*)&B;
	unsigned char *c = (unsigned char*)&res;
	c[0] = DEC_MIN(a[0],b[0]);
	c[1] = DEC_MIN(a[1],b[1]);
	c[2] = DEC_MIN(a[2],b[2]);
	c[3] = DEC_MIN(a[3],b[3]);
	return res;
}

#if ENABLE_INSTR_MMX_MIN_8b == 1
	#define v8min(a,b) instr_v8min(a,b)
#else
	#define v8min(a,b) prog_v8min(a,b)
#endif


