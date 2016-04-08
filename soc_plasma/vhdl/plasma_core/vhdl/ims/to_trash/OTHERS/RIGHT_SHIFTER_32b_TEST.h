////////////////////////////////////////////////////////////////
#define RIGHT_SHIFTER_LENGTH	10

int RIGHT_SHIFTER_32b_AUTOTEST(){
	int i, j;
	printf("LAUNCHING THE (RIGHT_SHIFTER) RESOURCE AUTOTEST...\n");
	for(j=0; j<RIGHT_SHIFTER_LENGTH; j++){
		int op1 = rand() % 65536;
		int op2 = rand() % 32;
		int res1 = instr_rshift(op1, op2);
		int res3 = prog_rshift (op1, op2);
		if( res1 != res3 ){
			printf("- TEST OF THE (RIGHT_SHIFTER) RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION BEFORE ERROR... !\n", j);
			printf("  + INSTRUCTION RESULT (%d l %d) => %d\n", op1, op2, res1);
			printf("  + C CODE RESULT      (%d l %d) => %d\n", op2, op1, res3);
			return 0;
		}
	}
	printf("- TEST OF THE (RIGHT_SHIFTER) RESOURCE => OK\n");
	return 1;
}

