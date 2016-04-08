////////////////////////////////////////////////////////////////
#define RGB_2_YUV_TEST_LENGTH	10

int RGB_2_YUV_AUTOTEST(){
	int i, j;
	printf("LAUNCHING THE (RGB_2_YUV) RESOURCE TEST...\n");
	for(j=0; j<RGB_2_YUV_TEST_LENGTH; j++){
		int op1 = ((rand()%256) << 16) | ((rand()%256) << 8) | (rand()%256);
		int res1 = instr_rgb2yuv(op1);
		int res2 = prog_rgb2yuv (op1);
		if( res1 != res2 ){
			printf("- TEST OF THE (RGB_2_YUV) RESOURCE => FAILED !\n");
			printf("  + %d COMPUTATION BEFORE ERROR... !\n", j);
			printf("  + INPUT DATA         = (%d, %d, %d)\n", (op1   >> 16), ((op1   >> 8) & 0xFF), (op1   & 0xFF));
			printf("  + INSTRUCTION RESULT = (%d, %d, %d)\n", (res1  >> 16), ((res1  >> 8) & 0xFF), (res1  & 0xFF));
			printf("  + C CODE RESULT      = (%d, %d, %d)\n", (res2  >> 16), ((res2  >> 8) & 0xFF), (res2  & 0xFF));
			return 0;
		}
	}
	printf("- TEST OF THE (RGB_2_YUV) RESOURCE => OK\n");
	return 1;
}

