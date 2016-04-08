////////////////////////////////////////////////////////////////
#define REVERSE_BYTE_TEST_LENGTH	10

int REVERSE_BYTE_32b_AUTOTEST(){
	printf("LAUNCHING THE (REVERSE_BYTE) RESOURCE TEST...\n");
	int i, j;
	for(j=0; j<REVERSE_BYTE_TEST_LENGTH; j++){
		int op1  = (rand() % 255) << 24 | (rand() % 255) << 16 | (rand() % 255) << 8 | (rand() % 255);
		int res1 = instr_rbyte(op1);
		int res2 = prog_rbyte (op1);

		if( res1 != res2 ){
			printf("- TEST OF THE REVERSE_BYTE RESOURCE => FAILED !\n");
			printf("  + OPERANDE 1         [%8x]\n",  op1);
			printf("  + INSTRUCTION RESULT (%8x)\n", res1);
			printf("  + C CODE RESULT      (%8x)\n", res2);
			return 0;
		}
	}
	printf("- TEST OF THE REVERSE_BYTE RESOURCE => OK\n");
	return 1;
}

//05.56.21.30.22