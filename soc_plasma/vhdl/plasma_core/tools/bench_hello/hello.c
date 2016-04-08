

int main( void ){
	puts("Hello world !\r\n");
	puts("UART works well...\r\n");
	//puts("Hello world !\n\r");
	//puts("UART works well 2...\n\r");
	asm("break 1" : : );
	return 0;
}


