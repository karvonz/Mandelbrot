////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define Q8_4_DECISION_TEST_LENGTH	10

int Q8_4_DECISION_AUTOTEST(){
	printf("LAUNCHING THE (Q8_4_DECISION) RESOURCE AUTOTEST...\n");
	int i, j;
	for(j=0; j<Q8_4_DECISION_TEST_LENGTH; j++){
		int op1 = (rand() % 256) - 128;
		int op3 = instr_q84decision(op1);
		int op4 = prog_q84decision (op1);
		if( op3 != op4 ){
			printf("- TEST OF THE (Q8_4_DECISION) RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION(s) BEFORE ERROR...\n", j);
			printf("  + OPERANDE 1 [%d]\n", op1);
			printf("  + ASM INSTR. [%d]\n", op3);
			printf("  + REF C CODE [%d]\n", op4);
			return 0;
		}
	}
	printf("- TEST OF THE (Q8_4_DECISION) RESOURCE => OK\n");
	return 1;
}
