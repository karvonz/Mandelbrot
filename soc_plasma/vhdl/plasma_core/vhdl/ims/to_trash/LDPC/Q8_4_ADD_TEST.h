////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define Q8_4_ADD_TEST_LENGTH	10

int Q8_4_ADD_AUTOTEST(){
	printf("LAUNCHING THE (Q8_4_SUB) RESOURCE AUTOTEST...\n");
	int i, j;
	for(j=0; j<Q8_4_ADD_TEST_LENGTH; j++){
		int op1 = (rand() % 256) - 128;
		int op2 = (rand() % 256) - 128;
		int op3 = instr_q84add(op1, op2);
		int op4 = prog_q84add (op1, op2);
		if( op3 != op4 ){
			printf("- TEST OF THE (Q8_4_ADD) RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION(s) BEFORE ERROR...\n", j);
			printf("  + OPERANDE 1 [%d]\n", op1);
			printf("  + OPERANDE 2 [%d]\n", op2);
			printf("  + ASM INSTR. [%d]\n", op3);
			printf("  + REF C CODE [%d]\n", op4);
			return 0;
		}
	}
	printf("- TEST OF THE (Q8_4_ADD) RESOURCE => OK\n");
	return 1;
}


