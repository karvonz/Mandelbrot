#define FIFO_IN_EMPTY			0x30000000
#define FIFO_OUT_EMPTY			0x30000010
#define FIFO_IN_FULL				0x30000020
#define FIFO_OUT_FULL			0x30000030
#define FIFO_IN_VALID			0x30000040
#define FIFO_OUT_VALID			0x30000050
#define FIFO_IN_COUNTER			0x30000060
#define FIFO_OUT_COUNTER		0x30000070
#define FIFO_IN_DATA_READ		0x30000080
#define FIFO_OUT_DATA_WRITE	0x30000090

#define MemoryRead(A)   (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)

#define i_empty() 		MemoryRead( FIFO_IN_EMPTY     )
#define o_empty() 		MemoryRead( FIFO_OUT_EMPTY    )
#define i_full() 			MemoryRead( FIFO_IN_FULL      )
#define o_full() 			MemoryRead( FIFO_OUT_FULL     )
#define i_valid() 		MemoryRead( FIFO_IN_VALID     )
#define o_valid() 		MemoryRead( FIFO_OUT_VALID    )
#define i_counter() 		MemoryRead( FIFO_IN_COUNTER   )
#define o_counter() 		MemoryRead( FIFO_OUT_COUNTER  )
#define i_read()  		MemoryRead( FIFO_IN_DATA_READ )
#define o_write(value) 	MemoryWrite(FIFO_OUT_DATA_WRITE, value)

int main( void ){
	puts("PCIe interface testing"); puts("\r\n");

	puts("- i_empty()   (");	print_hex(FIFO_IN_EMPTY);		puts(") = ");	print_hex( i_empty() ); 		puts("\r\n");
	puts("- o_empty()   (");	print_hex(FIFO_OUT_EMPTY);   	puts(") = ");	print_hex( o_empty() );			puts("\r\n");
	puts("- i_full()    (");	print_hex(FIFO_IN_FULL);    	puts(") = ");	print_hex( i_full() ); 			puts("\r\n");
	puts("- o_full()    (");	print_hex(FIFO_OUT_FULL);   	puts(") = ");	print_hex( o_full() ); 			puts("\r\n");
	puts("- i_valid()   (");	print_hex(FIFO_IN_VALID);    	puts(") = ");	print_hex( i_valid() ); 		puts("\r\n");
	puts("- o_valid()   (");	print_hex(FIFO_OUT_VALID);   	puts(") = ");	print_hex( o_valid() ); 		puts("\r\n");
	puts("- i_counter() (");	print_hex(FIFO_IN_COUNTER);   puts(") = ");	print_hex( i_counter() ); 		puts("\r\n");
	puts("- o_counter() (");	print_hex(FIFO_OUT_COUNTER);  puts(") = ");	print_hex( o_counter() ); 		puts("\r\n");

	while( 1 )
	{
		if( (i_valid() == 1) && (i_empty() == 0) ){
			int v = i_read();
			puts("- reading an input  data   (");  print_hex(FIFO_IN_DATA_READ);   puts(") = ");	print_hex( v );       puts("\r\n");
			//v -= 0x01; // ON MODIFIE LES CARACTERES ASCCI RECUS
			puts("- writing an output data   (");	print_hex(FIFO_OUT_DATA_WRITE); puts(") = ");	print_hex( v );       puts("\r\n");
			o_write( v );
		}
	}

	//v = 'A';
	//puts("- writing an output data   (");	print_hex(FIFO_OUT_DATA_WRITE); puts(") = ");	print_hex( v );       puts("\r\n");
	//write( v++ );
	//write( v++ );
	//write( v++ );
	//write( v++ );
	//write( v++ );
	puts("PCIe interface test finished"); 									        puts("\r\n");
	return 0;
}

