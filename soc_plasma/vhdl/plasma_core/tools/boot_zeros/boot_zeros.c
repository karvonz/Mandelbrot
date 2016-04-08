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

short tabIn[] = {-36, -9,-15,0,-33,-26,0, -9,-13,-13,-18, -7,-30,-34,  8,-33,-17,-35,-22,-12, -7,-20,-22,-21, -7, 14,-40,-13,-19,-45,-11,-15, -3,  3,-26,-18,  0,-17, -8,-23,  6,-13,-12,-32,-16, -9,-12,  0,-13, -1,-21,-24, -9,-19,-20,-37, -6,-29,-16,-14,-21,-11,  0, -4,-16,-16,-22, -1,-26,-11,-22,-28,-24,  6, -9,-11, 10,-33,  0,  5,-13, -1,-26, -7,-28,-22,-25,-19, 16, -3, -6,-22,  6,  2,-10,-15,-25,-31,-12,  7,-26,-15,-11, -6,-21, -4,-13,-20,-28, -8,-19,-20,-17,-26, -3, -7,-17,-18,-20,-36,-25,-21,-24,-42,-26,-22,-22,-29,-11,-28,-16,-40,-14, -6,-20,-46,-11,  2, -2,  0,-21,-32,-24,-25,-20,-15,-14,-30,-27,-19,-14,-32,-30,-19, -1,-18, -3,-18,-18,-26,-11,-15,-25,-29,-20, -8,-26,-11, -1,-14,-30,  4,-33,-28,-32, 22,-31, -3,-21,  3, -5, -5,-32,-20, -5, -3,-10, -8, -2,-25,-35,-15,  0,-25,-29,-43, -1,-11,-20, 10,-15,-22,-32, -9,  4, -2,  8,  1, -5,-27,-13,-21,-29,-25, -8,  2,-20, -9,-19,-11, -7,-11,-13, -2,-17,-24, -9,-17,-19,-21,-32, -9,-21, -2,-24,-30,-22, -8,  1, -9,-25,-17,-13,-10,-23, -8, -6,  0, -3,-37,-40,-28,-28,-10,-22,-15,-23, -6,-15,-22,  2,-35,-32,-22, -3,  7,-12,-40, -5,-15,-18,  1,-27,-21,-11,-19,-22,-14, -8, -1,-14,-30,-15,-32,-20, -7,  0, -4, -3,  7,-14,-18,-20,  4, -8,-13,  8, -7,-24,-32,-24,-29, -3,-27,-26,-30, -2, -6,-16, -4, -9,-24,-22,-12, -9,-22,-11,-54,-25,-23,-27,-12, -2,-27,  0,-24, -7, -9,-33,-25, -9,-18,-30,-36,-35, 19,-17,-33,  2,-17,-33, -5,-35,-33, -7,-46, -1, -6,-24,-20,-52, -5, -2,-19,  0,-23,-30,-18, -8,-15, -4,-27, -2, 11,-25,-36,-12,-22, -8,-18,  2,-30,-18,-19,-11,-33,-20, -4,-10,  0,-25,-29,-23, -9,  0,  4,-25,-10,-27,-23,-15,-13,-11,-14,-16,-19,-35,-19,-27, -9,-22,-20,-23,-22,-20,-33, -5,-21,-13,-22,-10,-16,-13,-13,-30, -7,-12,-17,-19,-30,-19, -8, -4,-15,-18,-19,  9,-15,-10,-13,-36, -3,-24,-25,-22,-19,-28, -3, -8, -7,-67,-41,-12,-27,-13, -2,-30, -4,-31,-25,-11, -3, -6,-17, -1, -8,-32,  6,-16,-17,-46,-28,-22,-29,-13,-21, -5,-12,  0,-18,-11,-15,-15,-19,-22,  9, -9,-14,-55, -7,-23, 14,-21,-26,  2,  1,-16,-23,-16,-27, -6, -5,-21,-18, -2,-31,-31, -7, -1,  0,-24,-22,-34, -2,  5, 11,  1,-30,-24,-17,-21,-26,  0, -5,  1, -6,-35,-26,-27, -3, -4,-23,-31,-21,-23,-14, -8,-17,  2, -6, -9, -3,-16,-15,  6, -2,-32,-13, -6,-36,-30, 13, 10,-18,-30,-11,  4,-11, -2,-30,-25,  4,-22,-22, -5,-24,-10,-14,-41, -9,-14, -5, -9, -8,-20,-19, -3,-29,  3,-26,-34, 14,-10,-22,-24,-11};
short tabOu[] = {1,   0,   0,   0, 0,   1,   1,   0,   0,  0,   0,   0,   0,  0,   1,   0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

int main( void ){
	int i, value, zero = 0;
	print_int( 123 );puts("\r\n");
	print_int( 1234 );puts("\r\n");
	print_int( 1234567 );puts("\r\n");
	print_int( -1234567 );puts("\r\n");
	
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
		puts("    - WAITING    :"); print_hex(NB_CMDE_TO_PNODE); puts("\r\n");
		puts("    - PCIe VALUE :"); print_hex(value);            puts("\r\n");
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
		puts("    - WAITING    :"); print_hex(NB_CMDE_TO_BENES); puts("\r\n");
		puts("    - PCIe VALUE :"); print_hex(value);            puts("\r\n");
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

	//
	//
	//
	puts("- REMPLISSAGE DES VARIABLES\r\n");
    for(i=0 ; i<NB_VAR_TO_STORE ; i++)
    {
        cop_write_variable( /*zero*/ tabIn[i] );
    }
	cop_exec_nop();

	//
	//
	//
	puts("- SWITCHING TO EXEC MODE\r\n");
	cop_switch_exec_mode();
	cop_exec_nop();
	cop_exec_nop();
	cop_exec_nop();
	cop_exec_nop();

	int loop = 10;
	while( loop-- ){
		puts("- LANCEMENT DES CALCULS\r\n");
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
	puts("- SWITCHING TO LOAD/STORE MODE\r\n");
	cop_switch_ldst_mode();
	cop_exec_nop();
	cop_exec_nop();
	cop_exec_nop();
	cop_exec_nop();

    int k  = 0;
    int ok = 0;

	//
	//
	//
	int error = 0;
	puts("- LECTURE DES VARIABLES\r\n");
	for(i=0 ; i<NB_VAR_TO_LOAD ; i++)
	{
        int buf = cop_read_variable();
        if( (buf>=0) != tabOu[i] )
        {
        	error += 1;
        }else{
        	ok += 1;
        }
	}
    puts("#error : ");	
    print_hex(error);
    puts("  #ok : ");
    print_hex(ok);
	puts("\r\n");

	if( error != 0 ){
		puts(" ERROR(S) DETECTED !\r\n");
		cop_switch_exec_mode(); cop_exec_nop(); cop_exec_nop(); cop_exec_nop(); cop_exec_nop();
		cop_switch_ldst_mode(); cop_exec_nop(); cop_exec_nop(); cop_exec_nop(); cop_exec_nop();
		for(i=0 ; i<NB_VAR_TO_LOAD ; i++)
		{
	        int buf = cop_read_variable();
    		puts("WAITING : "); print_int( i ); puts("  => GET : "); print_int( buf ); puts("\r\n");
		}
	}else{
		puts(" NO ERROR DETECTED...\r\n");
	}

	puts("PCIe interface test finished\r\n");
	asm("break 1" : : );	
	return 0;
}
