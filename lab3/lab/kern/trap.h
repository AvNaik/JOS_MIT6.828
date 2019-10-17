/* See COPYRIGHT for copyright information. */

#ifndef JOS_KERN_TRAP_H
#define JOS_KERN_TRAP_H
#ifndef JOS_KERNEL
# error "This is a JOS kernel header; user programs should not #include it"
#endif

#include <inc/trap.h>
#include <inc/mmu.h>

/* The kernel's interrupt descriptor table */
extern struct Gatedesc idt[];
extern struct Pseudodesc idt_pd;

void trap_init(void);
void trap_init_percpu(void);
void print_regs(struct PushRegs *regs);
void print_trapframe(struct Trapframe *tf);
void page_fault_handler(struct Trapframe *);
void backtrace(struct Trapframe *);


/*
Exception and Interupt handler function decalrations for the respective functions to be invoked.
*/

void divide_exception ();
void debug_exception ();
void nmi_interupt ();
void breakpoint_exception ();
void overflow_exception ();
void bounds_check_exception ();
void illegal_opcode_exception ();
void coprocessor_exception ();
void double_fault_exception () ;
void tss_exception (); 
void segment_np_exception ();
void stack_np_excecption ();
void general_protection_fault ();
void page_fault_exception ();
void fp_err_exception ();
void alignment_exception ();
void machine_exception ();
void SIMDerr_exception ();

void syscall_interrupt ();

#endif /* JOS_KERN_TRAP_H */
