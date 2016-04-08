////////////////////////////////////////////////////////////////
#define MAX_TEST_LENGTH	10

int MAXIMUM_32b_AUTOTEST(){
	int i, j;
	printf("LAUNCHING THE (MAXIMUM) RESOURCE TEST...\n");
	for(j=0; j<MAX_TEST_LENGTH; j++){
		int op1 = rand() % 65536;
		int op2 = rand() % 65536;
		int res1 = instr_max(op1, op2);
		int res2 = instr_max(op2, op1);
		int res3 = prog_max (op1, op2);
		if( (res1!=res2) || (res1!=res3) ){
			printf("- TEST OF THE (MAXIMUM) RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION BEFORE ERROR... !\n", j);
			printf("  + INSTRUCTION RESULT (%d l %d) => %d\n", op1, op2, res1);
			printf("  + INSTRUCTION RESULT (%d l %d) => %d\n", op2, op1, res2);
			printf("  + C CODE RESULT      (%d l %d) => %d\n", op2, op1, res3);
			return 0;
		}
	}
	printf("- TEST OF THE (MAXIMUM) RESOURCE => OK\n");
	return 1;
}

