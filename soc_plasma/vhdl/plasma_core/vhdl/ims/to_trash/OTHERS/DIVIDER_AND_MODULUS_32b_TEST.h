////////////////////////////////////////////////////////////////
#define DIV_AND_MOD_32b_TEST_LENGTH	10

int DIVIDER_32b_AUTOTEST(){
	printf("LAUNCHING THE (uDIV/MOD) RESOURCE TEST...\n");
	int isOk1 = 1;
	int i, j;
	
	// ON LANCE LA PROCEDURE DE TEST APPLIQUE AU DIVISEUR UNIQUEMENT
	for(j=0; j<DIV_AND_MOD_32b_TEST_LENGTH; j++){
		int op1 = rand() % 65536;
		int op2 = rand() % 65536;
		int res1 = instr_fudiv(op1, op2);
		int res2 = instr_fudiv(op1, op2);
		int res3 = instr_mod(op1, op2);
		int res4 = instr_mod(op1, op2);
		if( (res1 != res2) || (res3 != res4) ){
			printf("- TEST OF THE DIVIDER_32b RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION BEFORE ERROR... !\n", j);
			printf("  + INSTRUCTION RESULT (%d udiv %d) => %d\n", op1, op2, res1);
			printf("  + C CODE RESULT      (%d udiv %d) => %d\n", op1, op2, res2);
			printf("  + INSTRUCTION RESULT (%d umod %d) => %d\n", op1, op2, res3);
			printf("  + C CODE RESULT      (%d umod %d) => %d\n", op1, op2, res4);
			return 0;
		}
	}
	printf("- TEST OF THE DIVIDER_32b RESOURCE => OK\n");
	return 1;
}

