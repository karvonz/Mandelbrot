////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_MMX_MUL_8b 1

#if ENABLE_INSTR_MMX_MUL_8b == 1
inline int instr_v8mul(int a, int b){
	int res;
	__asm volatile ( "v8mul %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
	return res;
}
#endif

inline int prog_v8mul(int A, int B){
	int res = 0;
	short tmp[4];
	char *a = (char*)&A;
	char *b = (char*)&B;
	char *c = (char*)&res;
	c[0] = (unsigned char)((short)a[0] * (short)b[0]);
	c[1] = (unsigned char)((short)a[1] * (short)b[1]);
	c[2] = (unsigned char)((short)a[2] * (short)b[2]);
	c[3] = (unsigned char)((short)a[3] * (short)b[3]);
	return res;
}

#if ENABLE_INSTR_MMX_MUL_8b == 1
	#define v8mul(a,b) instr_v8mul(a,b)
#else
	#define v8mul(a,b) prog_v8mul(a,b)
#endif


