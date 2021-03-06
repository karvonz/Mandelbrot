////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_MAXIMUM_32b	1

#if ENABLE_INSTR_MAXIMUM_32b == 1
inline int instr_max(int a, int b){
	int res;
	__asm ( "max %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
	return res;
}
#endif

inline int prog_max(int a, int b){
	return (a>b)?a:b;
}

#if ENABLE_INSTR_MAXIMUM_32b == 1
	#define max(a,b) instr_max(a,b)
#else
	#define max(a,b) prog_max(a,b)
#endif
