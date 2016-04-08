////////////////////////////////////////////////////////////////
#define MODULUS_2x_TEST_LENGTH	10

int MODULUS_2x_32b_AUTOTEST(){
	int i, j;
	printf("LAUNCHING THE (MODULUS_2x_32b) RESOURCE AUTOTEST...\n");
	for(j=0; j<MODULUS_2x_TEST_LENGTH; j++){
		int op1 = rand() % 65536;
		int op2 = rand() % 65536;
		int res1 = instr_mod(op1, op2);
		int res3 = instr_mod(op1, op2);
		if( res1 != res3 ){
			printf("TEST OF THE (MODULUS_2x_32b) RESOURCE => FAILED !\n");
			printf("- %d COMPUTATION BEFORE ERROR... !\n", j);
			printf("- INSTRUCTION RESULT (%d l %d) => %d\n", op1, op2, res1);
			printf("- C CODE RESULT      (%d l %d) => %d\n", op2, op1, res3);
			return 0;
		}
	}
	printf("- TEST OF THE (MODULUS_2x_32b) RESOURCE => OK\n");
	return 1;
}

