////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define Q16_8_DMINI_TEST_LENGTH	10

int Q16_8_DoubleMini_AUTOTEST(){
	printf("LAUNCHING THE (Q16_8_DoubleMini) RESOURCE AUTOTEST...\n");
	int i, j;
	for(j=0; j<Q16_8_DMINI_TEST_LENGTH; j++){
		int op1 = (rand() % 65536) - 32768;
		int op2 = (((rand() % 65536) - 32768) << 16) | ((rand() % 65536) - 32768);		
		int op3 = instr_q168dmini(op1, op2);
		int op4 = prog_q168dmini (op1, op2);
		if( op3 != op4 ){
			printf("- TEST OF THE (Q16_8_DoubleMini) RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION(s) BEFORE ERROR...\n", j);
			printf("  + OPERANDE 1 [%d]\n", op1);
			printf("  + OPERANDE 2 [%d, %d]\n", ((short)(op2 >> 16)), ((short)op2));
			printf("  + ASM INSTR. [%d, %d]\n", ((short)(op3 >> 16)), ((short)op3));
			printf("  + REF C CODE [%d, %d]\n", ((short)(op4 >> 16)), ((short)op4));
			return 0;
		}
	}
	printf("- TEST OF THE (Q16_8_DoubleMini) RESOURCE => OK\n");
	return 1;
}

