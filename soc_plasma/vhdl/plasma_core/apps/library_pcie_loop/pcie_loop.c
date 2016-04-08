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
	puts("PCIe benchmark (data copy only)");  puts("\r\n");
	while( 1 )
	{
		if( i_empty() == 0 )
		{
			int value = i_read();
			o_write( value );
			//puts("- input data = "); print_hex( value ); puts("\r\n");
		}
	}
	puts("PCIe interface test finished");  puts("\r\n");
	return 0;
}

