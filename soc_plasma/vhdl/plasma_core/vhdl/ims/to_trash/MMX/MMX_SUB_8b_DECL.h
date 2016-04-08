////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_MMX_SUB_8b 1

#if ENABLE_INSTR_MMX_SUB_8b == 1
inline int instr_v8sub(int a, int b){
	int res;
	__asm ( "v8sub %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
	return res;
}
#endif

inline int prog_v8sub(int A, int B){
	int res = 0;
	short tmp[4];
	char *a = (char*)&A;
	char *b = (char*)&B;
	char *c = (char*)&res;
	tmp[0] = (short)a[0] + (short)b[0];
	tmp[1] = (short)a[1] + (short)b[1];
	tmp[2] = (short)a[2] + (short)b[2];
	tmp[3] = (short)a[3] + (short)b[3];
	c[0]   = (tmp[0]<0x00)?0x00:((unsigned char)tmp[0]);
	c[1]   = (tmp[1]<0x00)?0x00:((unsigned char)tmp[1]);
	c[2]   = (tmp[2]<0x00)?0x00:((unsigned char)tmp[2]);
	c[3]   = (tmp[3]<0x00)?0x00:((unsigned char)tmp[3]);
	return res;
}

#if ENABLE_INSTR_MMX_SUB_8b == 1
	#define v8sub(a,b) instr_v8sub(a,b)
#else
	#define v8sub(a,b) prog_v8sub(a,b)
#endif


