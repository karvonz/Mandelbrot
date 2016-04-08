#include "instructions.h"

#define FIFO_IN_EMPTY			0x30000000
#define FIFO_OUT_EMPTY			0x30000010
#define FIFO_IN_FULL			0x30000020
#define FIFO_OUT_FULL			0x30000030
#define FIFO_IN_VALID			0x30000040
#define FIFO_OUT_VALID			0x30000050
#define FIFO_IN_COUNTER			0x30000060
#define FIFO_OUT_COUNTER		0x30000070
#define FIFO_IN_DATA_READ		0x30000080
#define FIFO_OUT_DATA_WRITE		0x30000090

#define MemoryRead(A)   (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)

#define i_empty() 		MemoryRead( FIFO_IN_EMPTY     )
#define o_empty() 		MemoryRead( FIFO_OUT_EMPTY    )
#define i_full() 		MemoryRead( FIFO_IN_FULL      )
#define o_full() 		MemoryRead( FIFO_OUT_FULL     )
#define i_valid() 		MemoryRead( FIFO_IN_VALID     )
#define o_valid() 		MemoryRead( FIFO_OUT_VALID    )
#define i_counter() 	MemoryRead( FIFO_IN_COUNTER   )
#define o_counter() 	MemoryRead( FIFO_OUT_COUNTER  )
#define i_read()  		MemoryRead( FIFO_IN_DATA_READ )
#define o_write(value) 	MemoryWrite(FIFO_OUT_DATA_WRITE, value)

#define NB_FU			 24
#define NB_VAR_TO_LOAD   576
#define NB_VAR_PER_SU    NB_VAR_TO_LOAD/NB_FU
#define NB_MSG_PER_FU    10
#define NB_PNODE_TO_LOAD 10*24


int main( void ){
	int i, zero = 0;
	puts("LDPC CO-PROCESSOR (load and store) TESTING\r\n");

	// ON PASSE LE CO-PROCESSEUR EN MODE CHARGEMENT
	puts("- CONFIGURATION DES PARAMETRES\r\n");
	cop_switch_ldst_mode();
	cop_exec_nop();

	//
	// ON CONFIGURE LES COMPTEURS DE L'ARCHITECTURE
	//
	cop_store_node_count(NB_VAR_PER_SU);
	cop_store_mesg_count(NB_MSG_PER_FU);

	//
	// fill the pnode rams
	//
	puts("- REMPLISSAGE DES pNODE RAMs\r\n");
	for(i=0 ; i<NB_PNODE_TO_LOAD ; i++)
	{
	    cop_write_node_index( zero );
	}
	cop_exec_nop();

	//
	// fill the interleavers
	//
	puts("- REMPLISSAGE DES INTERLEAVERS (BENES)\r\n");
	for(i=0 ; i<NB_PNODE_TO_LOAD ; i++)
	{
	    cop_write_interlv( zero );
	}
	cop_exec_nop();

	//	
	puts("- REMPLISSAGE DES VARIABLES\r\n");
    for(i=0 ; i<NB_VAR_TO_LOAD ; i++)
    {
        cop_write_variable( i%256 );
    }
	cop_exec_nop();

	puts("- SWITCHING TO EXEC MODE\r\n");
	cop_switch_exec_mode();
	cop_exec_nop();
	cop_exec_nop();
	cop_exec_nop();
	cop_exec_nop();

	puts("- SWITCHING TO LOAD/STORE MODE\r\n");
	cop_switch_ldst_mode();
	cop_exec_nop();
	cop_exec_nop();
	cop_exec_nop();
	cop_exec_nop();

	int error = 0;
	puts("- LECTURE DES VARIABLES\r\n");
	for(i=0 ; i<NB_VAR_TO_LOAD ; i++)
	{
        int buf = cop_read_variable() & 0x00FF;
        if(buf != i%256)
        {
        	puts("WAITING : "); print_hex(i%256); puts("  => GET : "); print_hex(buf); puts("\r\n");
        	error += 1;
			asm("break 1" : : );	
        }
	}

	if( error != 0 ){
		puts(" ERROR(S) DETECTED !\r\n");
	}else{
		puts(" NO ERROR DETECTED...\r\n");
	}

	puts("PCIe interface test finished\r\n");
	asm("break 1" : : );	
	return 0;
}
