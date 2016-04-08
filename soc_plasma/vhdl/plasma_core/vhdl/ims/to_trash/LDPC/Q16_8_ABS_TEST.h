////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define Q16_8_ABS_TEST_LENGTH	10

int Q16_8_ABS_AUTOTEST(){
	printf("LAUNCHING THE (Q16_8_ABS) RESOURCE AUTOTEST...\n");
	int i, j;
	for(j=0; j<Q16_8_ABS_TEST_LENGTH; j++){
		int op1 = (rand() % 65536) - 32768;
		int op3 = instr_q168abs(op1);
		int op4 = prog_q168abs (op1);
		if( op3 != op4 ){
			printf("- TEST OF THE (Q16_8_ABS) RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION(s) BEFORE ERROR...\n", j);
			printf("  + OPERANDE 1 [%d]\n", op1);
			printf("  + ASM INSTR. [%d]\n", op3);
			printf("  + REF C CODE [%d]\n", op4);
			return 0;
		}
	}
	printf("- TEST OF THE (Q16_8_ABS) RESOURCE => OK\n");
	return 1;
}
