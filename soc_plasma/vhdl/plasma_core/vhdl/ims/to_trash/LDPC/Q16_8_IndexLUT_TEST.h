////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define Q16_8_iLUT_TEST_LENGTH	10

int Q16_8_IndexLUT_AUTOTEST(){
	printf("LAUNCHING THE (Q16_8_IndexLUT) RESOURCE AUTOTEST...\n");
	int i, j;
	for(j=0; j<Q16_8_iLUT_TEST_LENGTH; j++){
		short op1 = (short)(((int)rand()) % 1824);
		short op3 = prog_q168ilut (op1);
		short op2 = instr_q168ilut(op1);
		if( op2 != op3 ){
			printf("- TEST OF THE (Q16_8_IndexLUT) RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION(s) BEFORE ERROR...\n", j);
			printf("  + OPERANDE 1 [%d]\n", op1);
			printf("  + ASM INSTR. [%d]\n", op2);
			printf("  + REF C CODE [%d]\n", op3);
			return 0;
		}
	}
	printf("- TEST OF THE (Q16_8_IndexLUT) RESOURCE => OK\n");
	return 1;
}
