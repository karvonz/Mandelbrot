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
	puts("PCIe interface test starting");  puts("\r\n");
	int lR = 0;
	int lG = 0;
	int lB = 0;
	int lA = 0;
	while( 1 )
	{
		if( i_empty() == 0 )
		//if( (i_valid() == 1) && (i_empty() == 0) )
		{
			/*int nv = i_read();
			puts("- i_read () = ");	print_hex( nv ); puts("\r\n");
			int r = (nv & 0x000000FF);
			int g = (nv & 0x0000FF00) >>  8;
			int b = (nv & 0x00FF0000) >> 16;
			int a = (nv & 0xFF000000) >> 24;

			int v = (abs(a-lA) << 24) | (abs(b-lB) << 16) | (abs(g-lG) << 8) | (abs(r-lR));
			o_write( v );
			puts("- o_write() = ");	print_hex( nv ); puts("\r\n");

			lR = r;
			lG = g;
			lB = b;
			lA = a;*/
			o_write( i_read() );
		}
	}
	puts("PCIe interface test finished");  puts("\r\n");
	return 0;
}

