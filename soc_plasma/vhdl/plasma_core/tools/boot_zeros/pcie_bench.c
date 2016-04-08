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
#define NB_VAR_TO_STORE  576
#define NB_VAR_TO_LOAD   576
#define NB_VAR_PER_SU    24
#define NB_MSG_PER_FU    130
#define NB_PNODE_TO_LOAD 3120
#define NB_CMDE_TO_PNODE 3120
#define NB_CMDE_TO_BENES 650

#define DEBUG_MSG 0

#define EXEC_6_NODES            {cop_exec_first_node();  cop_exec_node(); cop_exec_node(); cop_exec_node(); cop_exec_node(); cop_exec_node();}
#define EXEC_6_MESSAGES         {cop_exec_first_mesg();  cop_exec_mesg(); cop_exec_mesg(); cop_exec_mesg(); cop_exec_mesg(); cop_exec_mesg();}
#define EXEC_6_NODES_6_MESSAGES {cop_exec_f_node_mesg(); cop_exec_node_mesg(); cop_exec_node_mesg(); cop_exec_node_mesg(); cop_exec_node_mesg(); cop_exec_node_mesg();}
#define EXEC_7_NODES_7_MESSAGES {cop_exec_f_node_mesg(); cop_exec_node_mesg(); cop_exec_node_mesg(); cop_exec_node_mesg(); cop_exec_node_mesg(); cop_exec_node_mesg(); cop_exec_node_mesg();}
//#define EXEC_7_NODES_6_MESSAGES
//#define EXEC_6_NODES_7_MESSAGES
#define NOP_4_CYCLES {cop_exec_nop();cop_exec_nop();cop_exec_nop();cop_exec_nop();}

int main( void ){
	int i, value, zero = 0;
	int errors = 0;
	
	puts("LDPC CO-PROCESSOR (load and store) TESTING\r\n");

	//
	// ON PASSE LE CO-PROCESSEUR EN MODE CHARGEMENT
	//
	puts("- CONFIGURATION DES PARAMETRES\r\n");
	cop_switch_ldst_mode();
	cop_exec_nop();
	cop_store_node_count(NB_VAR_PER_SU);
	cop_store_mesg_count(NB_MSG_PER_FU);

	//
	// ON CONFIGURE LES COMPTEURS DE L'ARCHITECTURE
	//
	puts("- CHECKING THE NB_CMDE_TO_PNODE VALUE\r\n");
	while( i_empty() ); // ON ATTEND UNE DONNEE SUR LE PORT PCIe
	value = i_read();
	if( value != NB_CMDE_TO_PNODE ){
		puts(" => ERROR FOR PNODE COUNT ! <=\r\n");
		puts("    - WAITING    :"); print_int(NB_CMDE_TO_PNODE); puts("\r\n");
		puts("    - PCIe VALUE :"); print_int(value);            puts("\r\n");
	}

	//
	// fill the pNODE rams
	//
	puts("- REMPLISSAGE DES pNODE RAMs\r\n");
	for(i=0 ; i<NB_CMDE_TO_PNODE ; i++)
	{
		while( i_empty() ); // ON ATTEND UNE DONNEE SUR LE PORT PCIe
		value = i_read();
	    cop_write_node_index( value );
	}
	cop_exec_nop();

	//
	//
	//
	puts("- CHECKING THE NB_CMDE_TO_BENES VALUE\r\n");
	while( i_empty() ); // ON ATTEND UNE DONNEE SUR LE PORT PCIe
	value = i_read();
	if( value != NB_CMDE_TO_BENES ){
		puts(" => ERROR FOR BENES COUNT ! <=\r\n");
		puts("    - WAITING    :"); print_int(NB_CMDE_TO_BENES); puts("\r\n");
		puts("    - PCIe VALUE :"); print_int(value);            puts("\r\n");
	}

	//
	// fill the interleavers
	//
	puts("- REMPLISSAGE DES INTERLEAVERS (BENES)\r\n");
	for(i=0 ; i<NB_CMDE_TO_BENES ; i++)
	{
		while( i_empty() ); // ON ATTEND UNE DONNEE SUR LE PORT PCIe
		value = i_read();
	    cop_write_interlv( value );
	}
	cop_exec_nop();

int processing = 1;
while( ! i_empty() ){

	puts("- LAUNCHING LDPC DECODING N = "); print_hex(processing++); puts("\r\n");
	while( i_empty() ); // ON ATTEND UNE DONNEE SUR LE PORT PCIe
	int loop = i_read();
#if DEBUG_MSG == 1
	puts("  + NUMBER OF ITERATIONS = "); print_int(loop); puts("\r\n");
#endif

	//
	//
	//
#if DEBUG_MSG == 1
	puts("  + REMPLISSAGE DES VARIABLES\r\n");
#endif
    for(i=0 ; i<NB_VAR_TO_STORE ; i++)
    {
	    while( i_empty() );
	    int value = i_read();
        cop_write_variable( value );
    }
	cop_exec_nop();

	//
	//
	//
#if DEBUG_MSG == 1
	puts(" + SWITCHING TO EXEC MODE\r\n");
#endif
	cop_switch_exec_mode();
	NOP_4_CYCLES;

#if DEBUG_MSG == 1
	puts(" + LANCEMENT DES CALCULS\r\n");
#endif
	while( loop-- ){
		//start iteration 0
		//start CycleExec 0 (6) 
		cop_exec_first_node();
		cop_exec_node();
		cop_exec_node();
		cop_exec_node();
		cop_exec_node();
		cop_exec_node();

		//start CycleExec 1 (7), end of 0 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node();

		//start CycleExec 2 (6), end of 1 (7)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_mesg();
		cop_exec_node_mesg();

		//start CycleExec 3 (6), end of 2 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();

		//start CycleExec 4 (7), end of 3 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node();

		//start CycleExec 5 (6), end of 4 (7)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_mesg();
		cop_exec_node_mesg();

		//start CycleExec 6 (6), end of 5 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();

		//start CycleExec 7 (7), end of 6 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node();

		//start CycleExec 8 (6), end of 7 (7)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_mesg();
		cop_exec_node_mesg();

		//start CycleExec 9 (6), end of 8 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();

		//start CycleExec 10 (7), end of 9 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node();

		//start CycleExec 11 (6), end of 10 (7)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_mesg();
		cop_exec_node_mesg();

		//start CycleExec 12 (6), end of 11 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();

		//start CycleExec 13 (6), end of 12 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();

		//start CycleExec 14 (6), end of 13 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();

		//start CycleExec 15 (6), end of 14 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();

		//start CycleExec 16 (6), end of 15 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();

		//start CycleExec 17 (6), end of 16 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();

		//start CycleExec 18 (6), end of 17 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();

		//start CycleExec 19 (6), end of 18 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();

		//start CycleExec 20 (6), end of 19 (6)
		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();

		//start CycleExec 0 (6), end of 20 (6)
/*		cop_exec_f_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
		cop_exec_node_mesg();
*/
		//start CycleExec 0 (6), end of 20 (6)
		cop_exec_first_mesg();
		cop_exec_mesg();
		cop_exec_mesg();
		cop_exec_mesg();
		cop_exec_mesg();
		cop_exec_mesg();
	}

	//
	//
	//
#if DEBUG_MSG == 1
	puts(" + SWITCHING TO LOAD/STORE MODE\r\n");
#endif
	cop_switch_ldst_mode();
	NOP_4_CYCLES;

    int ok = 0;
	int error = 0;

	//
	//
	//
#if DEBUG_MSG == 1
	puts(" + LECTURE DES VARIABLES\r\n");
#endif
	for(i=0 ; i<NB_VAR_TO_LOAD ; i++)
	{
        int pratique = cop_read_variable();
		while( i_empty() ); // ON ATTEND UNE DONNEE SUR LE PORT PCIe
		int theorique = i_read();

        if( theorique != pratique ){
        	error += 1;
        }else{
        	ok += 1;
        }
	}
#if DEBUG_MSG == 1
    puts("#error : ");	
    print_hex(error);
    puts("  #ok : ");
    print_hex(ok);
	puts("\r\n");
#endif
	errors += error;
}

	if( errors != 0 ){
		puts(" ERROR(S) DETECTED !\r\n");
//		cop_switch_exec_mode(); cop_exec_nop(); cop_exec_nop(); cop_exec_nop(); cop_exec_nop();
//		cop_switch_ldst_mode(); cop_exec_nop(); cop_exec_nop(); cop_exec_nop(); cop_exec_nop();
//		for(i=0 ; i<NB_VAR_TO_LOAD ; i++)
//		{
//	        int buf = cop_read_variable();
//    		puts("WAITING : "); print_int( i ); puts("  => GET : "); print_int( buf ); puts("\r\n");
//		}
	}else{
		puts(" NO ERROR DETECTED...\r\n");
	}

	puts("PCIe interface test finished\r\n");
	asm("break 1" : : );	
	return 0;
}
