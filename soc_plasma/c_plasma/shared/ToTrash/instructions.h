#ifndef LDPC_H
#define LDPC_H

//
//
//
extern inline int cop_read_configuration(int arg)//2
{
	int data;
	asm volatile("cop.read.id %0, %1" : "=r" (data) : "r" (arg) );
	return data;
}

//
//
//
extern inline int cop_read_configuratio2()//2
{
    int data;
    asm volatile("cop.read.reg %0\n\t" : "=r" (data) : );
    return data;
}


extern __attribute__((always_inline)) inline void cop_write_variable(int data) 
{
	asm volatile("cop.write.variable %0 " : : "r" (data) );
}


extern __attribute__((always_inline)) inline void cop_write_variabl1(int data)
{
    asm volatile("cop.write.variable2 %0, %0, 3" : : "r" (data));
}


extern __attribute__((always_inline)) inline void cop_write_variabl2(int data)
{
    asm volatile("cop.write.variable2 %0, %0, 2" : : "r" (data));
}


extern __attribute__((always_inline)) inline void cop_write_variabl3(int data)
{
    asm volatile("cop.write.variable2 %0, %0, 1" : : "r" (data));
}


extern __attribute__((always_inline)) inline void cop_write_variabl4(int data)
{
    asm volatile("cop.write.variable2 %0, %0, 0" : : "r" (data));
}


extern __attribute__((always_inline)) inline void cop_write_variables(int data)
{
    asm volatile("cop.write.var.d1 %0" : : "r" (data));
    asm volatile("cop.write.var.d2 %0" : : "r" (data));
    asm volatile("cop.write.var.d3 %0" : : "r" (data));
    asm volatile("cop.write.var.d4 %0" : : "r" (data));
}


extern inline int cop_read_variable()//2
{
	int data;
	asm volatile("cop.read.variable %0 " : "=r" (data) : );
	return data;
}


//
// METHODE PERMETTANT DE LIRE LA SORTIE DE L'ACCELERATEUR MATERIEL. LA SORTIE
// EST OBTENUE SOUS LA FORME D'UNE DECISION BINAIRE QUI EST CONCATENE A LA VALEUR
// FOURNIE EN ARGUMENT (OPTIMISATION DU TEMPS DE CALCUL).
//
extern inline int cop_read_variabl2(int arg)//2
{   
    int data;
    asm volatile ("cop.read.variable %0, %1" : "=r" (data) : "0" (arg) );
	return data;
}


extern inline void cop_exec_first_node(void)//3
{
	asm volatile("cop.exec.first.node" : : );
}

extern inline void cop_exec_node(void)//4
{
	asm volatile("cop.exec.node" : : );
}

extern inline void cop_exec_first_mesg(void)//5
{
	asm volatile("cop.exec.first.mesg" : : );
}

extern inline void cop_exec_mesg(void)//6
{
	asm volatile("cop.exec.mesg" : : );
}

extern inline void cop_exec_f_node_mesg(void)//7
{
	asm volatile("cop.exec.f.node.mesg" : : );
}

extern inline void cop_exec_node_mesg(void)//8
{
	asm volatile("cop.exec.node.mesg");
}

extern inline void cop_switch_ldst_mode(void)//9
{
	asm volatile("cop.switch.ldst.mode" : : );
}

extern inline void cop_switch_exec_mode(void)//10
{
	asm volatile("cop.switch.exec.mode" : : );
}

extern inline void cop_soft_reset(void)//11
{
	asm volatile("cop.soft.reset" : : );
}

extern inline void cop_store_node_count(int data)//12
{
	asm volatile("cop.store.node.count %0 " : : "r" (data) );
}

extern inline void cop_store_mesg_count(int data)//13
{
	asm volatile("cop.store.mesg.count %0 " : : "r" (data) );
}

extern inline void cop_write_node_index(int data)//14
{
	asm volatile("cop.write.node.index %0 " : : "r" (data) );
}

extern inline void cop_write_interlv(int data)//15
{
	asm volatile("cop.write.interlv %0 " : : "r" (data) );
}

extern inline void cop_exec_nop(void)//16
{
	asm volatile("cop.exec.nop" : : );
}

#endif /* LDPC_H */
