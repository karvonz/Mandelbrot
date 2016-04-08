////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////
#define SEQ_SUM_8d_8b_6c_TEST_LENGTH	10

#define OP1(a) ((a & 0x000000FF))
#define OP2(a) ((a & 0x0000FF00)>> 8)
#define OP3(a) ((a & 0x00FF0000)>>16)
#define OP4(a) ((a & 0xFF000000)>>24)

int SEQ_SUM_8d_8b_6c_AUTOTEST(){
	printf("LAUNCHING THE (SEQ_SUM_8d_8b_6c) RESOURCE TEST...\n");
	int i, j;
	for(j=0; j<SEQ_SUM_8d_8b_6c_TEST_LENGTH; j++){
		int op1 = ((rand() % 65536) << 16) & (rand() % 65536);
		int op2 = ((rand() % 65536) << 16) & (rand() % 65536);
		int op3 = instr_seqsum(op1, op2);
		int op4 = prog_seqsum (op1, op2);
		if( op3 != op4 ){
			printf("TEST OF THE GRAPHLAB (SEQ_SUM_8d_8b_6c) RESOURCE => FAILED !\n");
			printf("- %d COMPUTATION(s) BEFORE ERROR...\n", j);
			printf("- OPERANDE 1 [%.3d %.3d %.3d %.3d]\n", OP4(op1), OP3(op1), OP2(op1), OP1(op1));
			printf("- OPERANDE 2 [%.3d %.3d %.3d %.3d]\n", OP4(op2), OP3(op2), OP2(op2), OP1(op2));
			printf("- ASM INSTR. [%d]\n", op3);
			printf("- REF C CODE [%d]\n", op4);
			return 0;
		}
	}
	printf("- TEST OF THE (SEQ_SUM_8d_8b_6c) RESOURCE => OK\n");
	return 1;
}

