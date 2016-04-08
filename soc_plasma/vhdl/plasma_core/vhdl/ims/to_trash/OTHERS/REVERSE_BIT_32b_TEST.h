////////////////////////////////////////////////////////////////
#define REVERSE_BIT_TEST_LENGTH	10

int REVERSE_BIT_32b_AUTOTEST(){
	printf("LAUNCHING THE (REVERSE_BIT) RESOURCE TEST...\n");
	int i, j;
	for(j=0; j<REVERSE_BIT_TEST_LENGTH; j++){
		int op1  = rand();
		int res1 = instr_rbit(op1);
		int res2 = prog_rbit (op1);
		if( res1 != res2 ){
			printf("- TEST OF THE (REVERSE_BIT) RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION BEFORE ERROR... !\n", j);
			printf("  + OPERANDE 1         [%x]\n",  op1);
			printf("  + INSTRUCTION RESULT [%x]\n", res1);
			printf("  + C CODE RESULT      [%x]\n", res2);
			return 0;
		}
	}
	printf("- TEST OF THE (REVERSE_BIT) RESOURCE => OK\n");
	return 1;
}

