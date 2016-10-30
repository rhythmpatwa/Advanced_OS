/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 Description                       Interrupt     Error Code
Number

Divide error                       0            No
Debug exceptions                   1            No
Breakpoint                         3            No
Overflow                           4            No
Bounds check                       5            No
Invalid opcode                     6            No
Coprocessor not available          7            No
System error                       8            Yes (always 0)
Coprocessor Segment Overrun        9            No
Invalid TSS                       10            Yes
Segment not present               11            Yes
Stack exception                   12            Yes
General protection fault          13            Yes
Page fault                        14            Yes
Coprocessor error                 16            No
 */
	TRAPHANDLER_NOEC(divide_error, T_DIVIDE)
	TRAPHANDLER_NOEC(debug_exceptions, T_DEBUG)
	TRAPHANDLER_NOEC(break_point, T_BRKPT)
	TRAPHANDLER_NOEC(overflow, T_OFLOW)
	TRAPHANDLER_NOEC(bounds_check, T_BOUND)
	TRAPHANDLER_NOEC(invalid_opcode, T_ILLOP)
	TRAPHANDLER_NOEC(coprocessor_not_available, T_DEVICE)
	TRAPHANDLER(system_error, T_DBLFLT)
	TRAPHANDLER(invalid_tss, T_TSS)
	TRAPHANDLER(segment_not_present, T_SEGNP)
	TRAPHANDLER(stack_exception, T_STACK)
	TRAPHANDLER(general_protection_fault, T_GPFLT)
	TRAPHANDLER(page_fault, T_PGFLT)
	TRAPHANDLER_NOEC(coprocessor_error, T_FPERR)
	TRAPHANDLER_NOEC(system_call, T_SYSCALL)
	/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:	
 		pushl %es
 		pushl %ds
 		pushal
 		movl $GD_KD, %eax
 		movw %ax, %es
 		movw %ax, %ds
 		pushl %esp	
		call trap
