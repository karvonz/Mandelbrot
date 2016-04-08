////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define MMX_MIN_8b_TEST_LENGTH	10

#define OP1(a) ((a & 0x000000FF))
#define OP2(a) ((a & 0x0000FF00)>> 8)
#define OP3(a) ((a & 0x00FF0000)>>16)
#define OP4(a) ((a & 0xFF000000)>>24)
int MMX_MIN_8b_AUTOTEST(){
	int i, j;
	printf("LAUNCHING THE (MMX_MIN) RESOURCE AUTOTEST...\n");
	for(j=0; j<MMX_MIN_8b_TEST_LENGTH; j++){
		int op1 = ((rand() % 65536) << 16) & (rand() % 65536);
		int op2 = ((rand() % 65536) << 16) & (rand() % 65536);
		int op3 = instr_v8min(op1, op2);
		int op4 = prog_v8min (op1, op2);
		if( op3 != op4 ){
			printf("- TEST OF THE MMX_MIN_8b RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION(s) BEFORE ERROR...\n", j);
			printf("  + OPERANDE 1 [%.3d %.3d %.3d %.3d]\n", OP4(op1), OP3(op1), OP2(op1), OP1(op1));
			printf("  + OPERANDE 2 [%.3d %.3d %.3d %.3d]\n", OP4(op2), OP3(op2), OP2(op2), OP1(op2));
			printf("  + ASM INSTR. [%.3d %.3d %.3d %.3d]\n", OP4(op3), OP3(op3), OP2(op3), OP1(op3));
			printf("  + REF C CODE [%.3d %.3d %.3d %.3d]\n", OP4(op4), OP3(op4), OP2(op4), OP1(op4));
			return 0;
		}
	}
	printf("- TEST OF THE MMX_MIN_8b RESOURCE => OK\n");
	return 1;
}

