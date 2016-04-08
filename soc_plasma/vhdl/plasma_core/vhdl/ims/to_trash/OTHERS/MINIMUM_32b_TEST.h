////////////////////////////////////////////////////////////////
#define MIN_TEST_LENGTH	10

int MINIMUM_32b_AUTOTEST(){
	int i, j;
	printf("LAUNCHING THE (MINIMUM) RESOURCE TEST...\n");
	for(j=0; j<MIN_TEST_LENGTH; j++){
		int op1 = rand() % 256;
		int op2 = rand() % 256;
		int res1 = instr_min(op1, op2);
		int res2 = instr_min(op2, op1);
		int res3 = prog_min (op1, op2);
		if( (res1!=res2) || (res1!=res3) ){
			printf("- TEST OF THE MINIMUM_32b RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION BEFORE ERROR... !\n", j);
			printf("  + INSTRUCTION RESULT (%d l %d) => %d\n", op1, op2, res1);
			printf("  + INSTRUCTION RESULT (%d l %d) => %d\n", op2, op1, res2);
			printf("  + C CODE RESULT      (%d l %d) => %d\n", op2, op1, res3);
			return 0;
		}
	}
	printf("- TEST OF THE (MINIMUM) RESOURCE => OK\n");
	return 1;
}

