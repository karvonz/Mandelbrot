////////////////////////////////////////////////////////////////
#define STOP_TEST_LENGTH	10

int STOP_32b_AUTOTEST(){
	int i, j;
	printf("LAUNCHING THE (STOP) RESOURCE TEST...\n");
	for(j=0; j<STOP_TEST_LENGTH; j++){
		int op1 = rand() % 65536;
		int res1 = instr_stop(op1);
		int res2 = prog_stop (op1);
		if( res1 != res2 ){
			printf("- TEST OF THE (STOP) RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION BEFORE ERROR... !\n", j);
			printf("  + INSTRUCTION RESULT (%d) => %d\n", op1, res1);
			printf("  + C CODE RESULT      (%d) => %d\n", op1, res2);
			return 0;
		}
	}
	printf("- TEST OF THE (STOP) RESOURCE => OK\n");
	return 1;
}

