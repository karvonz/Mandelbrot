////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_MMX_ADD_8b 1

#if ENABLE_INSTR_MMX_ADD_8b == 1
inline int instr_v8add(int a, int b){
	int res;
	__asm volatile ( "v8add %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
	return res;
}
#endif

inline int prog_v8add(int A, int B){
	int res = 0;
	short tmp[4];
	unsigned char *a = (unsigned char*)&A;
	unsigned char *b = (unsigned char*)&B;
	unsigned char *c = (unsigned char*)&res;
	tmp[0] = (short)a[0] + (short)b[0];
	tmp[1] = (short)a[1] + (short)b[1];
	tmp[2] = (short)a[2] + (short)b[2];
	tmp[3] = (short)a[3] + (short)b[3];
	c[0]   = (tmp[0]>0xFF)?0xFF:((unsigned char)tmp[0]);
	c[1]   = (tmp[1]>0xFF)?0xFF:((unsigned char)tmp[1]);
	c[2]   = (tmp[2]>0xFF)?0xFF:((unsigned char)tmp[2]);
	c[3]   = (tmp[3]>0xFF)?0xFF:((unsigned char)tmp[3]);
	return res;
}

#if ENABLE_INSTR_MMX_ADD_8b == 1
	#define v8add(a,b) instr_v8add(a,b)
#else
	#define v8add(a,b) prog_v8add(a,b)
#endif

