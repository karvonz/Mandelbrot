#ifndef LDPC_H
#define LDPC_H

extern __attribute__((always_inline)) inline void cop_write_variable(int data) 
{
	asm volatile("cop.write.variable %0 " : : "r" (data) );
}

extern inline int cop_read_variable()//2
{
	int data;
	asm volatile("cop.read.variable %0 " : "=r" (data) : );
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
