////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define Q16_8_CondSelect_TEST_LENGTH	10

int Q16_8_CondSelect_AUTOTEST(){
	printf("LAUNCHING THE (Q16_8_CondSelect) RESOURCE AUTOTEST...\n");
	int i, j;
	for(j=0; j<Q16_8_CondInv_TEST_LENGTH; j++){
		short op1 = (rand() % 65536) - 32768;
		int   op2 = (((rand() % 65536) - 32768) << 16) | ((rand() % 65536) - 32768);		
		short op3 = instr_q168csel(op1, op2);
		short op4 = prog_q168csel (op1, op2);
		if( op3 != op4 ){
			printf("- TEST OF THE (Q16_8_CondSelect) RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION(s) BEFORE ERROR...\n", j);
			printf("  + OPERANDE 1 [%d]\n",     op1);
			printf("  + OPERANDE 2 [%d, %d]\n", ((short)(op2 >> 16)), ((short)op2));
			printf("  + ASM INSTR. [%d]\n",     op3);
			printf("  + REF C CODE [%d]\n",     op4);
			return 0;
		}
	}
	printf("- TEST OF THE (Q16_8_CondSelect) RESOURCE => OK\n");
	return 1;
}
