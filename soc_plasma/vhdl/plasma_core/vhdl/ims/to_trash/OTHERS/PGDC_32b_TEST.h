////////////////////////////////////////////////////////////////
#define PGDC_TEST_LENGTH	10

int PGDC_32b_AUTOTEST(){
	printf("LAUNCHING THE (PGCD) RESOURCE TEST...\n");
	int i, j;
	for(j=0; j<PGDC_TEST_LENGTH; j++){
		int op1 = rand() % 255;
		int op2 = rand() % 255;
		int res1 = instr_pgdc(op1, op2);
		int res2 = instr_pgdc(op2, op1);
		int res3 = prog_pgdc (op1, op2);
		if( (res1!=res3) || (res2!=res3) ){
			printf("- TEST OF THE PGDC RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION BEFORE ERROR... !\n", j);
			printf("  + INSTRUCTION RESULT (%d l %d) => %d\n", op1, op2, res1);
			printf("  + INSTRUCTION RESULT (%d l %d) => %d\n", op2, op1, res2);
			printf("  + C CODE RESULT      (%d l %d) => %d\n", op2, op1, res3);
			return 0;
		}
	}
	printf("- TEST OF THE PGDC RESOURCE => OK\n");
	return 1;
}

