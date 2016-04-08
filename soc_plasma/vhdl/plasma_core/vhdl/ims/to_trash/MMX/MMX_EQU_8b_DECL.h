////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_MMX_EQU_8b 1

#if ENABLE_INSTR_MMX_EQU_8b == 1
inline int instr_v8equ(int a, int b){
	int res;
	__asm volatile ( "v8equ %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
	return res;
}
#endif

inline int prog_v8equ(int A, int B){
	int res = 0;
	unsigned char *a = (unsigned char*)&A;
	unsigned char *b = (unsigned char*)&B;
	unsigned char *c = (unsigned char*)&res;
	c[0] = ((a[0] == b[0])?0xFF:0x00);
	c[1] = ((a[1] == b[1])?0xFF:0x00);
	c[2] = ((a[2] == b[2])?0xFF:0x00);
	c[3] = ((a[3] == b[3])?0xFF:0x00);
	return res;
}

#if ENABLE_INSTR_MMX_EQU_8b == 1
	#define v8equ(a,b) instr_v8equ(a,b)
#else
	#define v8equ(a,b) prog_v8equ(a,b)
#endif


