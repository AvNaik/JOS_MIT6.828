// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
/*	   static void
	   pgfault(struct UTrapframe *utf)
	   {
	   void *addr = (void *) utf->utf_fault_va;
	   uint32_t err = utf->utf_err;
	   int r;

// Check that the faulting access was (1) a write, and (2) to a
// copy-on-write page.  If not, panic.
// Hint:
//   Use the read-only page table mappings at uvpt
//   (see <inc/memlayout.h>).

// LAB 4: Your code here.

pte_t pte = uvpt [(uintptr_t)addr >> PTXSHIFT];

if (!(err & FEC_WR))
{
panic ("Page fault Not caused by a write. %x \n", err);
} else if (!(pte & PTE_COW))
panic ("Page fault Not caused by copy on write %x \n", err);

// Allocate a new page, map it at a temporary location (PFTEMP),
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.

// LAB 4: Your code here.

int perm = PTE_P | PTE_W | PTE_U;
r = sys_page_alloc (0, (void *) PFTEMP, perm);
if (r < 0)
panic ("Sys_page_alloc failed %e", r);

memmove (PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);

if ((r = sys_page_map (0, (void *)PFTEMP, 0, ROUNDDOWN (addr, PGSIZE), perm)) < 0)
panic ("sys_page_map Failed. %e", r);


if ((r = sys_page_unmap (0, (void*) PFTEMP)) < 0)
panic ("sys_page_unmap Failed \n. %e", r);

//panic("pgfault not implemented");

}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
int r;

// LAB 4: Your code here.
void* address = (void*) (pn*PGSIZE);

if ((uvpt [pn] & PTE_W) || (uvpt[pn] & PTE_COW))
{
if ((r = sys_page_map (0, address, envid, address, PTE_COW | PTE_P | PTE_U)) < 0)
return r;

if ((r = sys_page_map (0, address, 0, address, PTE_COW | PTE_P | PTE_U)) < 0)
	   return r;
	   } else
{
	   if ((r = sys_page_map (0, address, envid, address, PTE_U | PTE_P)) < 0)
			 return r;
}

//	   panic("duppage not implemented");
return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
	   // LAB 4: Your code here.

	   set_pgfault_handler(pgfault);

	   envid_t child_envid ;
	   child_envid = sys_exofork();
	   if (child_envid < 0)
	   {
			 panic ("sys_exofork failed \n. %e", child_envid);
	   } else if (child_envid == 0)
	   {
			 set_pgfault_handler(pgfault);
			 thisenv = &envs [ENVX(sys_getenvid())];
			 return child_envid;
	   }

	   bool is_below_UTOP = true;

	   for (int  i = 0; is_below_UTOP && i < NPDENTRIES; i ++)
	   {
			 if (!(uvpd [i] & PTE_P))	//execute the statement only if the conndition is false.
				    continue;

			 for (int j = 0; is_below_UTOP && j < NPTENTRIES; j ++)
			 {
				    uint32_t page_number = i * NPTENTRIES + j;

				    if (page_number == (UXSTACKTOP - PGSIZE) >> PGSHIFT)
				    {
						  continue;
				    } else if (page_number >= (UTOP >> PGSHIFT))
				    {
						  is_below_UTOP = false;
				    } else if (uvpt [page_number] & PTE_P)
				    {
						  duppage (child_envid, page_number);
				    }
			 }
	   }

	   extern void _pgfault_upcall ();

	   sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
	   sys_page_alloc (child_envid, (void*) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);

	   sys_env_set_status (child_envid, ENV_RUNNABLE);

	   return child_envid; 
}
*/

	   static void
pgfault(struct UTrapframe *utf)
{
	   void *addr = (void *) utf->utf_fault_va;
	   uint32_t err = utf->utf_err;
	   int r;

	   //	cprintf("[%x] pgfault handler: %x\n", sys_getenvid(),  (uintptr_t)addr);

	   // Check that the faulting access was (1) a write, and (2) to a
	   // copy-on-write page.  If not, panic.
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];

	   if (!(err & 2)) {
			 panic("pgfault was not a write. err: %x", err);
	   } else if (!(pte & PTE_COW)) {
			 panic("pgfault is not copy on write");
	   }

	   // Allocate a new page, map it at a temporary location (PFTEMP),
	   // copy the data from the old page to the new page, then move the new
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
			 panic("sys_page_alloc: %e", r);
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
	   if ((r = sys_page_map(0,
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
			 panic("unmap %e", r);
	   }
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];

	   if (!(pte & PTE_W) && !(pte & PTE_COW)) {
			 if ((r = sys_page_map(thisenv->env_id,
									   (void *)(pn * PGSIZE),
									   envid,
									   (void *)(pn * PGSIZE),
									   pte & PTE_SYSCALL)) < 0) {
				    panic("sys_page_map: %e", r);
			 }
			 return 0;
	   }

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id,
								(void *)(pn * PGSIZE),
								envid,
								(void *)(pn * PGSIZE),
								pte & PTE_SYSCALL)) < 0) {
			 panic("sys_page_map: %e", r);
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id,
								(void *)(pn * PGSIZE),
								thisenv->env_id,
								(void *)(pn * PGSIZE),
								pte & PTE_SYSCALL)) < 0) {
			 panic("sys_page_map: %e", r);
	   }

	   return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
			 panic("sys_exofork: %e", envid);
	   } else if (envid == 0) {  // child
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   // parent

	   //	cprintf("parent %x dupping pages for child: %x -> ",
	   //		thisenv->env_id,
	   //		envid);

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
						  //				cprintf("%x ", pn);
						  duppage(envid, pn);
				    }
			 }
	   }
	   //	cprintf("\n");

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);

	   return envid;
}
// Challenge!
	   int
sfork(void)
{
	   panic("sfork not implemented");
	   return -E_INVAL;
}
