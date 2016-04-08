////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_XOR_MIN_8b 1

#if ENABLE_INSTR_XOR_MIN_8b == 1

	inline int instr_xormin(int a, int b){
		int res;
		__asm volatile ( "xormin %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	#define fxXOR(c,d) (((c)&0x80)^((d)&0x80))
	#define fxMIN(c,d) ((((c)&0x7F)<((d)&0x7F))?((c)&0x7F):((d)&0x7F))
	inline int prog_xormin(int A, int B){
		int res = 0;
		unsigned char *a = (unsigned char*)&A;
		unsigned char *b = (unsigned char*)&B;
		unsigned char *c = (unsigned char*)&res;
		c[0] = fxXOR(a[0],b[0]) | fxMIN(a[0],b[0]);
		c[1] = fxXOR(a[1],b[1]) | fxMIN(a[1],b[1]);
		c[2] = fxXOR(a[2],b[2]) | fxMIN(a[2],b[2]);
		c[3] = fxXOR(a[3],b[3]) | fxMIN(a[3],b[3]);
		return res;
	}

	#define xormin(a,b) instr_xormin(a,b)

#endif


