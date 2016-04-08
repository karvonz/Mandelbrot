////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_MMX_MAX_8b 1

#if ENABLE_INSTR_MMX_MAX_8b == 1
inline int instr_v8max(int a, int b){
	int res;
	__asm ( "v8max %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
	return res;
}
#endif

#define DEC_MAX(a,b) ((a>b)?a:b)
inline int prog_v8max(int A, int B){
	int res = 0;
	unsigned char *a = (unsigned char*)&A;
	unsigned char *b = (unsigned char*)&B;
	unsigned char *c = (unsigned char*)&res;
	c[0] = DEC_MAX(a[0],b[0]);
	c[1] = DEC_MAX(a[1],b[1]);
	c[2] = DEC_MAX(a[2],b[2]);
	c[3] = DEC_MAX(a[3],b[3]);
	return res;
}

#if ENABLE_INSTR_MMX_MAX_8b == 1
	#define v8max(a,b) instr_v8max(a,b)
#else
	#define v8max(a,b) prog_v8max(a,b)
#endif


