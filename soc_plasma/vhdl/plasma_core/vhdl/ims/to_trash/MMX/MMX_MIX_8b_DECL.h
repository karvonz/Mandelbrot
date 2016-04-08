////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define ENABLE_INSTR_MMX_MIX_8b 1

#if ENABLE_INSTR_MMX_MIX_8b == 1

	inline int instr_v8mix(int a, int b){
		int res;
		__asm ( "v8mix %1, %2, %0 \n\t" : "=r" (res) : "r" (a), "r" (b) );
		return res;
	}

	inline int prog_v8mix(int A, int B){
		int res = 0;
		unsigned char *a = (unsigned char*)&A;
		unsigned char *b = (unsigned char*)&B;
		unsigned char *c = (unsigned char*)&res;
		c[0] = a[b[0]-1]; //((b[0]==1)?a[0]:0) + ((b[0]==2)?a[1]:0) + ((b[0]==3)?a[2]:0) + ((b[0]==4)?a[3]:0);
		c[1] = a[b[1]-1]; //((b[0]==1)?a[0]:0) + ((b[0]==2)?a[1]:0) + ((b[0]==3)?a[2]:0) + ((b[0]==4)?a[3]:0);
		c[2] = a[b[2]-1]; //((b[0]==1)?a[0]:0) + ((b[0]==2)?a[1]:0) + ((b[0]==3)?a[2]:0) + ((b[0]==4)?a[3]:0);
		c[3] = a[b[3]-1]; //((b[0]==1)?a[0]:0) + ((b[0]==2)?a[1]:0) + ((b[0]==3)?a[2]:0) + ((b[0]==4)?a[3]:0);
		return res;
	}

	#define v8mix(a,b) instr_v8mix(a,b)

#endif


