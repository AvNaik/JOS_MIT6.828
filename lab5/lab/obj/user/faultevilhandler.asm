
obj/user/faultevilhandler.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 87 04 00 00       	call   80053d <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 2a 1e 80 00       	push   $0x801e2a
  80012f:	6a 23                	push   $0x23
  800131:	68 47 1e 80 00       	push   $0x801e47
  800136:	e8 6a 0f 00 00       	call   8010a5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 2a 1e 80 00       	push   $0x801e2a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 47 1e 80 00       	push   $0x801e47
  8001b7:	e8 e9 0e 00 00       	call   8010a5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 2a 1e 80 00       	push   $0x801e2a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 47 1e 80 00       	push   $0x801e47
  8001f9:	e8 a7 0e 00 00       	call   8010a5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 2a 1e 80 00       	push   $0x801e2a
  800234:	6a 23                	push   $0x23
  800236:	68 47 1e 80 00       	push   $0x801e47
  80023b:	e8 65 0e 00 00       	call   8010a5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 2a 1e 80 00       	push   $0x801e2a
  800276:	6a 23                	push   $0x23
  800278:	68 47 1e 80 00       	push   $0x801e47
  80027d:	e8 23 0e 00 00       	call   8010a5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 2a 1e 80 00       	push   $0x801e2a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 47 1e 80 00       	push   $0x801e47
  8002bf:	e8 e1 0d 00 00       	call   8010a5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 2a 1e 80 00       	push   $0x801e2a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 47 1e 80 00       	push   $0x801e47
  800301:	e8 9f 0d 00 00       	call   8010a5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 2a 1e 80 00       	push   $0x801e2a
  80035e:	6a 23                	push   $0x23
  800360:	68 47 1e 80 00       	push   $0x801e47
  800365:	e8 3b 0d 00 00       	call   8010a5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 11                	je     8003c6 <fd_alloc+0x2d>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	75 09                	jne    8003cf <fd_alloc+0x36>
			*fd_store = fd;
  8003c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	eb 17                	jmp    8003e6 <fd_alloc+0x4d>
  8003cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d9:	75 c9                	jne    8003a4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	eb 13                	jmp    80043c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb 0c                	jmp    80043c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb 05                	jmp    80043c <fd_lookup+0x54>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba d4 1e 80 00       	mov    $0x801ed4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	eb 13                	jmp    800461 <dev_lookup+0x23>
  80044e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	75 0c                	jne    800461 <dev_lookup+0x23>
			*dev = devtab[i];
  800455:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800458:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	eb 2e                	jmp    80048f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	75 e7                	jne    80044e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800467:	a1 04 40 80 00       	mov    0x804004,%eax
  80046c:	8b 40 48             	mov    0x48(%eax),%eax
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	51                   	push   %ecx
  800473:	50                   	push   %eax
  800474:	68 58 1e 80 00       	push   $0x801e58
  800479:	e8 00 0d 00 00       	call   80117e <cprintf>
	*dev = 0;
  80047e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800481:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 10             	sub    $0x10,%esp
  800499:	8b 75 08             	mov    0x8(%ebp),%esi
  80049c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a2:	50                   	push   %eax
  8004a3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a9:	c1 e8 0c             	shr    $0xc,%eax
  8004ac:	50                   	push   %eax
  8004ad:	e8 36 ff ff ff       	call   8003e8 <fd_lookup>
  8004b2:	83 c4 08             	add    $0x8,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	78 05                	js     8004be <fd_close+0x2d>
	    || fd != fd2)
  8004b9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bc:	74 0c                	je     8004ca <fd_close+0x39>
		return (must_exist ? r : 0);
  8004be:	84 db                	test   %bl,%bl
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	0f 44 c2             	cmove  %edx,%eax
  8004c8:	eb 41                	jmp    80050b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 36                	pushl  (%esi)
  8004d3:	e8 66 ff ff ff       	call   80043e <dev_lookup>
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	78 1a                	js     8004fb <fd_close+0x6a>
		if (dev->dev_close)
  8004e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	74 0b                	je     8004fb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	56                   	push   %esi
  8004f4:	ff d0                	call   *%eax
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	6a 00                	push   $0x0
  800501:	e8 00 fd ff ff       	call   800206 <sys_page_unmap>
	return r;
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	89 d8                	mov    %ebx,%eax
}
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051b:	50                   	push   %eax
  80051c:	ff 75 08             	pushl  0x8(%ebp)
  80051f:	e8 c4 fe ff ff       	call   8003e8 <fd_lookup>
  800524:	83 c4 08             	add    $0x8,%esp
  800527:	85 c0                	test   %eax,%eax
  800529:	78 10                	js     80053b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	6a 01                	push   $0x1
  800530:	ff 75 f4             	pushl  -0xc(%ebp)
  800533:	e8 59 ff ff ff       	call   800491 <fd_close>
  800538:	83 c4 10             	add    $0x10,%esp
}
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <close_all>:

void
close_all(void)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	53                   	push   %ebx
  800541:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800544:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800549:	83 ec 0c             	sub    $0xc,%esp
  80054c:	53                   	push   %ebx
  80054d:	e8 c0 ff ff ff       	call   800512 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800552:	83 c3 01             	add    $0x1,%ebx
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	83 fb 20             	cmp    $0x20,%ebx
  80055b:	75 ec                	jne    800549 <close_all+0xc>
		close(i);
}
  80055d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	53                   	push   %ebx
  800568:	83 ec 2c             	sub    $0x2c,%esp
  80056b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800571:	50                   	push   %eax
  800572:	ff 75 08             	pushl  0x8(%ebp)
  800575:	e8 6e fe ff ff       	call   8003e8 <fd_lookup>
  80057a:	83 c4 08             	add    $0x8,%esp
  80057d:	85 c0                	test   %eax,%eax
  80057f:	0f 88 c1 00 00 00    	js     800646 <dup+0xe4>
		return r;
	close(newfdnum);
  800585:	83 ec 0c             	sub    $0xc,%esp
  800588:	56                   	push   %esi
  800589:	e8 84 ff ff ff       	call   800512 <close>

	newfd = INDEX2FD(newfdnum);
  80058e:	89 f3                	mov    %esi,%ebx
  800590:	c1 e3 0c             	shl    $0xc,%ebx
  800593:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800599:	83 c4 04             	add    $0x4,%esp
  80059c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059f:	e8 de fd ff ff       	call   800382 <fd2data>
  8005a4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a6:	89 1c 24             	mov    %ebx,(%esp)
  8005a9:	e8 d4 fd ff ff       	call   800382 <fd2data>
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b4:	89 f8                	mov    %edi,%eax
  8005b6:	c1 e8 16             	shr    $0x16,%eax
  8005b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c0:	a8 01                	test   $0x1,%al
  8005c2:	74 37                	je     8005fb <dup+0x99>
  8005c4:	89 f8                	mov    %edi,%eax
  8005c6:	c1 e8 0c             	shr    $0xc,%eax
  8005c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d0:	f6 c2 01             	test   $0x1,%dl
  8005d3:	74 26                	je     8005fb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e8:	6a 00                	push   $0x0
  8005ea:	57                   	push   %edi
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 d2 fb ff ff       	call   8001c4 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	78 2e                	js     800629 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 d0                	mov    %edx,%eax
  800600:	c1 e8 0c             	shr    $0xc,%eax
  800603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	25 07 0e 00 00       	and    $0xe07,%eax
  800612:	50                   	push   %eax
  800613:	53                   	push   %ebx
  800614:	6a 00                	push   $0x0
  800616:	52                   	push   %edx
  800617:	6a 00                	push   $0x0
  800619:	e8 a6 fb ff ff       	call   8001c4 <sys_page_map>
  80061e:	89 c7                	mov    %eax,%edi
  800620:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800623:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800625:	85 ff                	test   %edi,%edi
  800627:	79 1d                	jns    800646 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 00                	push   $0x0
  80062f:	e8 d2 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063a:	6a 00                	push   $0x0
  80063c:	e8 c5 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	89 f8                	mov    %edi,%eax
}
  800646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	53                   	push   %ebx
  800652:	83 ec 14             	sub    $0x14,%esp
  800655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	53                   	push   %ebx
  80065d:	e8 86 fd ff ff       	call   8003e8 <fd_lookup>
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	89 c2                	mov    %eax,%edx
  800667:	85 c0                	test   %eax,%eax
  800669:	78 6d                	js     8006d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800671:	50                   	push   %eax
  800672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800675:	ff 30                	pushl  (%eax)
  800677:	e8 c2 fd ff ff       	call   80043e <dev_lookup>
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	85 c0                	test   %eax,%eax
  800681:	78 4c                	js     8006cf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800683:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800686:	8b 42 08             	mov    0x8(%edx),%eax
  800689:	83 e0 03             	and    $0x3,%eax
  80068c:	83 f8 01             	cmp    $0x1,%eax
  80068f:	75 21                	jne    8006b2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800691:	a1 04 40 80 00       	mov    0x804004,%eax
  800696:	8b 40 48             	mov    0x48(%eax),%eax
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	53                   	push   %ebx
  80069d:	50                   	push   %eax
  80069e:	68 99 1e 80 00       	push   $0x801e99
  8006a3:	e8 d6 0a 00 00       	call   80117e <cprintf>
		return -E_INVAL;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b0:	eb 26                	jmp    8006d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b5:	8b 40 08             	mov    0x8(%eax),%eax
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 17                	je     8006d3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bc:	83 ec 04             	sub    $0x4,%esp
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	52                   	push   %edx
  8006c6:	ff d0                	call   *%eax
  8006c8:	89 c2                	mov    %eax,%edx
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 09                	jmp    8006d8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	eb 05                	jmp    8006d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d8:	89 d0                	mov    %edx,%eax
  8006da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	57                   	push   %edi
  8006e3:	56                   	push   %esi
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 0c             	sub    $0xc,%esp
  8006e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f3:	eb 21                	jmp    800716 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	29 d8                	sub    %ebx,%eax
  8006fc:	50                   	push   %eax
  8006fd:	89 d8                	mov    %ebx,%eax
  8006ff:	03 45 0c             	add    0xc(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	57                   	push   %edi
  800704:	e8 45 ff ff ff       	call   80064e <read>
		if (m < 0)
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 10                	js     800720 <readn+0x41>
			return m;
		if (m == 0)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 0a                	je     80071e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800714:	01 c3                	add    %eax,%ebx
  800716:	39 f3                	cmp    %esi,%ebx
  800718:	72 db                	jb     8006f5 <readn+0x16>
  80071a:	89 d8                	mov    %ebx,%eax
  80071c:	eb 02                	jmp    800720 <readn+0x41>
  80071e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 14             	sub    $0x14,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	53                   	push   %ebx
  800737:	e8 ac fc ff ff       	call   8003e8 <fd_lookup>
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	89 c2                	mov    %eax,%edx
  800741:	85 c0                	test   %eax,%eax
  800743:	78 68                	js     8007ad <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	ff 30                	pushl  (%eax)
  800751:	e8 e8 fc ff ff       	call   80043e <dev_lookup>
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 47                	js     8007a4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800764:	75 21                	jne    800787 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 b5 1e 80 00       	push   $0x801eb5
  800778:	e8 01 0a 00 00       	call   80117e <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800785:	eb 26                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078a:	8b 52 0c             	mov    0xc(%edx),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 17                	je     8007a8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800791:	83 ec 04             	sub    $0x4,%esp
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	50                   	push   %eax
  80079b:	ff d2                	call   *%edx
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 09                	jmp    8007ad <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	eb 05                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ad:	89 d0                	mov    %edx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 22 fc ff ff       	call   8003e8 <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 0e                	js     8007db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 14             	sub    $0x14,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	53                   	push   %ebx
  8007ec:	e8 f7 fb ff ff       	call   8003e8 <fd_lookup>
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 65                	js     80085f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800804:	ff 30                	pushl  (%eax)
  800806:	e8 33 fc ff ff       	call   80043e <dev_lookup>
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 44                	js     800856 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800819:	75 21                	jne    80083c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	68 78 1e 80 00       	push   $0x801e78
  80082d:	e8 4c 09 00 00       	call   80117e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083a:	eb 23                	jmp    80085f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083f:	8b 52 18             	mov    0x18(%edx),%edx
  800842:	85 d2                	test   %edx,%edx
  800844:	74 14                	je     80085a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	50                   	push   %eax
  80084d:	ff d2                	call   *%edx
  80084f:	89 c2                	mov    %eax,%edx
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb 09                	jmp    80085f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800856:	89 c2                	mov    %eax,%edx
  800858:	eb 05                	jmp    80085f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085f:	89 d0                	mov    %edx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 14             	sub    $0x14,%esp
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 6c fb ff ff       	call   8003e8 <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	89 c2                	mov    %eax,%edx
  800881:	85 c0                	test   %eax,%eax
  800883:	78 58                	js     8008dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	ff 30                	pushl  (%eax)
  800891:	e8 a8 fb ff ff       	call   80043e <dev_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 37                	js     8008d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a4:	74 32                	je     8008d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b0:	00 00 00 
	stat->st_isdir = 0;
  8008b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ba:	00 00 00 
	stat->st_dev = dev;
  8008bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ca:	ff 50 14             	call   *0x14(%eax)
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	eb 09                	jmp    8008dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	eb 05                	jmp    8008dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	6a 00                	push   $0x0
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 2c 02 00 00       	call   800b22 <open>
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	78 1b                	js     80091a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	50                   	push   %eax
  800906:	e8 5b ff ff ff       	call   800866 <fstat>
  80090b:	89 c6                	mov    %eax,%esi
	close(fd);
  80090d:	89 1c 24             	mov    %ebx,(%esp)
  800910:	e8 fd fb ff ff       	call   800512 <close>
	return r;
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	89 f0                	mov    %esi,%eax
}
  80091a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	89 c6                	mov    %eax,%esi
  800928:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  80092a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800931:	75 12                	jne    800945 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	6a 01                	push   $0x1
  800938:	e8 c0 11 00 00       	call   801afd <ipc_find_env>
  80093d:	a3 00 40 80 00       	mov    %eax,0x804000
  800942:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800945:	6a 07                	push   $0x7
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	56                   	push   %esi
  80094d:	ff 35 00 40 80 00    	pushl  0x804000
  800953:	e8 51 11 00 00       	call   801aa9 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 e5 10 00 00       	call   801a4a <ipc_recv>
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 40 0c             	mov    0xc(%eax),%eax
  800978:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 02 00 00 00       	mov    $0x2,%eax
  80098f:	e8 8d ff ff ff       	call   800921 <fsipc>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b1:	e8 6b ff ff ff       	call   800921 <fsipc>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	83 ec 04             	sub    $0x4,%esp
  8009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d7:	e8 45 ff ff ff       	call   800921 <fsipc>
  8009dc:	85 c0                	test   %eax,%eax
  8009de:	78 2c                	js     800a0c <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	68 00 50 80 00       	push   $0x805000
  8009e8:	53                   	push   %ebx
  8009e9:	e8 15 0d 00 00       	call   801703 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8009ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  800a04:	83 c4 10             	add    $0x10,%esp
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	53                   	push   %ebx
  800a15:	83 ec 08             	sub    $0x8,%esp
  800a18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a21:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  800a26:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  800a2c:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a32:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800a37:	0f 46 c3             	cmovbe %ebx,%eax
  800a3a:	50                   	push   %eax
  800a3b:	ff 75 0c             	pushl  0xc(%ebp)
  800a3e:	68 08 50 80 00       	push   $0x805008
  800a43:	e8 4d 0e 00 00       	call   801895 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  800a48:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4d:	b8 04 00 00 00       	mov    $0x4,%eax
  800a52:	e8 ca fe ff ff       	call   800921 <fsipc>
  800a57:	83 c4 10             	add    $0x10,%esp
  800a5a:	85 c0                	test   %eax,%eax
  800a5c:	78 3d                	js     800a9b <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  800a5e:	39 c3                	cmp    %eax,%ebx
  800a60:	73 19                	jae    800a7b <devfile_write+0x6a>
  800a62:	68 e4 1e 80 00       	push   $0x801ee4
  800a67:	68 eb 1e 80 00       	push   $0x801eeb
  800a6c:	68 9a 00 00 00       	push   $0x9a
  800a71:	68 00 1f 80 00       	push   $0x801f00
  800a76:	e8 2a 06 00 00       	call   8010a5 <_panic>
	   assert (r <= bytes_written);
  800a7b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a80:	7e 19                	jle    800a9b <devfile_write+0x8a>
  800a82:	68 0b 1f 80 00       	push   $0x801f0b
  800a87:	68 eb 1e 80 00       	push   $0x801eeb
  800a8c:	68 9b 00 00 00       	push   $0x9b
  800a91:	68 00 1f 80 00       	push   $0x801f00
  800a96:	e8 0a 06 00 00       	call   8010a5 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  800a9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 40 0c             	mov    0xc(%eax),%eax
  800aae:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  800ab3:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ab9:	ba 00 00 00 00       	mov    $0x0,%edx
  800abe:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac3:	e8 59 fe ff ff       	call   800921 <fsipc>
  800ac8:	89 c3                	mov    %eax,%ebx
  800aca:	85 c0                	test   %eax,%eax
  800acc:	78 4b                	js     800b19 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  800ace:	39 c6                	cmp    %eax,%esi
  800ad0:	73 16                	jae    800ae8 <devfile_read+0x48>
  800ad2:	68 e4 1e 80 00       	push   $0x801ee4
  800ad7:	68 eb 1e 80 00       	push   $0x801eeb
  800adc:	6a 7c                	push   $0x7c
  800ade:	68 00 1f 80 00       	push   $0x801f00
  800ae3:	e8 bd 05 00 00       	call   8010a5 <_panic>
	   assert(r <= PGSIZE);
  800ae8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aed:	7e 16                	jle    800b05 <devfile_read+0x65>
  800aef:	68 1e 1f 80 00       	push   $0x801f1e
  800af4:	68 eb 1e 80 00       	push   $0x801eeb
  800af9:	6a 7d                	push   $0x7d
  800afb:	68 00 1f 80 00       	push   $0x801f00
  800b00:	e8 a0 05 00 00       	call   8010a5 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b05:	83 ec 04             	sub    $0x4,%esp
  800b08:	50                   	push   %eax
  800b09:	68 00 50 80 00       	push   $0x805000
  800b0e:	ff 75 0c             	pushl  0xc(%ebp)
  800b11:	e8 7f 0d 00 00       	call   801895 <memmove>
	   return r;
  800b16:	83 c4 10             	add    $0x10,%esp
}
  800b19:	89 d8                	mov    %ebx,%eax
  800b1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	53                   	push   %ebx
  800b26:	83 ec 20             	sub    $0x20,%esp
  800b29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  800b2c:	53                   	push   %ebx
  800b2d:	e8 98 0b 00 00       	call   8016ca <strlen>
  800b32:	83 c4 10             	add    $0x10,%esp
  800b35:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b3a:	7f 67                	jg     800ba3 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b3c:	83 ec 0c             	sub    $0xc,%esp
  800b3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b42:	50                   	push   %eax
  800b43:	e8 51 f8 ff ff       	call   800399 <fd_alloc>
  800b48:	83 c4 10             	add    $0x10,%esp
			 return r;
  800b4b:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	78 57                	js     800ba8 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  800b51:	83 ec 08             	sub    $0x8,%esp
  800b54:	53                   	push   %ebx
  800b55:	68 00 50 80 00       	push   $0x805000
  800b5a:	e8 a4 0b 00 00       	call   801703 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  800b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b62:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6f:	e8 ad fd ff ff       	call   800921 <fsipc>
  800b74:	89 c3                	mov    %eax,%ebx
  800b76:	83 c4 10             	add    $0x10,%esp
  800b79:	85 c0                	test   %eax,%eax
  800b7b:	79 14                	jns    800b91 <open+0x6f>
			 fd_close(fd, 0);
  800b7d:	83 ec 08             	sub    $0x8,%esp
  800b80:	6a 00                	push   $0x0
  800b82:	ff 75 f4             	pushl  -0xc(%ebp)
  800b85:	e8 07 f9 ff ff       	call   800491 <fd_close>
			 return r;
  800b8a:	83 c4 10             	add    $0x10,%esp
  800b8d:	89 da                	mov    %ebx,%edx
  800b8f:	eb 17                	jmp    800ba8 <open+0x86>
	   }

	   return fd2num(fd);
  800b91:	83 ec 0c             	sub    $0xc,%esp
  800b94:	ff 75 f4             	pushl  -0xc(%ebp)
  800b97:	e8 d6 f7 ff ff       	call   800372 <fd2num>
  800b9c:	89 c2                	mov    %eax,%edx
  800b9e:	83 c4 10             	add    $0x10,%esp
  800ba1:	eb 05                	jmp    800ba8 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  800ba3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  800ba8:	89 d0                	mov    %edx,%eax
  800baa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbf:	e8 5d fd ff ff       	call   800921 <fsipc>
}
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    

00800bc6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bce:	83 ec 0c             	sub    $0xc,%esp
  800bd1:	ff 75 08             	pushl  0x8(%ebp)
  800bd4:	e8 a9 f7 ff ff       	call   800382 <fd2data>
  800bd9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bdb:	83 c4 08             	add    $0x8,%esp
  800bde:	68 2a 1f 80 00       	push   $0x801f2a
  800be3:	53                   	push   %ebx
  800be4:	e8 1a 0b 00 00       	call   801703 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800be9:	8b 46 04             	mov    0x4(%esi),%eax
  800bec:	2b 06                	sub    (%esi),%eax
  800bee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bf4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bfb:	00 00 00 
	stat->st_dev = &devpipe;
  800bfe:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c05:	30 80 00 
	return 0;
}
  800c08:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	53                   	push   %ebx
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c1e:	53                   	push   %ebx
  800c1f:	6a 00                	push   $0x0
  800c21:	e8 e0 f5 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c26:	89 1c 24             	mov    %ebx,(%esp)
  800c29:	e8 54 f7 ff ff       	call   800382 <fd2data>
  800c2e:	83 c4 08             	add    $0x8,%esp
  800c31:	50                   	push   %eax
  800c32:	6a 00                	push   $0x0
  800c34:	e8 cd f5 ff ff       	call   800206 <sys_page_unmap>
}
  800c39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 1c             	sub    $0x1c,%esp
  800c47:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c4a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c4c:	a1 04 40 80 00       	mov    0x804004,%eax
  800c51:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	ff 75 e0             	pushl  -0x20(%ebp)
  800c5a:	e8 d7 0e 00 00       	call   801b36 <pageref>
  800c5f:	89 c3                	mov    %eax,%ebx
  800c61:	89 3c 24             	mov    %edi,(%esp)
  800c64:	e8 cd 0e 00 00       	call   801b36 <pageref>
  800c69:	83 c4 10             	add    $0x10,%esp
  800c6c:	39 c3                	cmp    %eax,%ebx
  800c6e:	0f 94 c1             	sete   %cl
  800c71:	0f b6 c9             	movzbl %cl,%ecx
  800c74:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c77:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c7d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c80:	39 ce                	cmp    %ecx,%esi
  800c82:	74 1b                	je     800c9f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c84:	39 c3                	cmp    %eax,%ebx
  800c86:	75 c4                	jne    800c4c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c88:	8b 42 58             	mov    0x58(%edx),%eax
  800c8b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c8e:	50                   	push   %eax
  800c8f:	56                   	push   %esi
  800c90:	68 31 1f 80 00       	push   $0x801f31
  800c95:	e8 e4 04 00 00       	call   80117e <cprintf>
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	eb ad                	jmp    800c4c <_pipeisclosed+0xe>
	}
}
  800c9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 28             	sub    $0x28,%esp
  800cb3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800cb6:	56                   	push   %esi
  800cb7:	e8 c6 f6 ff ff       	call   800382 <fd2data>
  800cbc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cbe:	83 c4 10             	add    $0x10,%esp
  800cc1:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc6:	eb 4b                	jmp    800d13 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cc8:	89 da                	mov    %ebx,%edx
  800cca:	89 f0                	mov    %esi,%eax
  800ccc:	e8 6d ff ff ff       	call   800c3e <_pipeisclosed>
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	75 48                	jne    800d1d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cd5:	e8 88 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cda:	8b 43 04             	mov    0x4(%ebx),%eax
  800cdd:	8b 0b                	mov    (%ebx),%ecx
  800cdf:	8d 51 20             	lea    0x20(%ecx),%edx
  800ce2:	39 d0                	cmp    %edx,%eax
  800ce4:	73 e2                	jae    800cc8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ced:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cf0:	89 c2                	mov    %eax,%edx
  800cf2:	c1 fa 1f             	sar    $0x1f,%edx
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	c1 e9 1b             	shr    $0x1b,%ecx
  800cfa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cfd:	83 e2 1f             	and    $0x1f,%edx
  800d00:	29 ca                	sub    %ecx,%edx
  800d02:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d06:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d0a:	83 c0 01             	add    $0x1,%eax
  800d0d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d10:	83 c7 01             	add    $0x1,%edi
  800d13:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d16:	75 c2                	jne    800cda <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d18:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1b:	eb 05                	jmp    800d22 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 18             	sub    $0x18,%esp
  800d33:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d36:	57                   	push   %edi
  800d37:	e8 46 f6 ff ff       	call   800382 <fd2data>
  800d3c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d3e:	83 c4 10             	add    $0x10,%esp
  800d41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d46:	eb 3d                	jmp    800d85 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d48:	85 db                	test   %ebx,%ebx
  800d4a:	74 04                	je     800d50 <devpipe_read+0x26>
				return i;
  800d4c:	89 d8                	mov    %ebx,%eax
  800d4e:	eb 44                	jmp    800d94 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d50:	89 f2                	mov    %esi,%edx
  800d52:	89 f8                	mov    %edi,%eax
  800d54:	e8 e5 fe ff ff       	call   800c3e <_pipeisclosed>
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	75 32                	jne    800d8f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d5d:	e8 00 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d62:	8b 06                	mov    (%esi),%eax
  800d64:	3b 46 04             	cmp    0x4(%esi),%eax
  800d67:	74 df                	je     800d48 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d69:	99                   	cltd   
  800d6a:	c1 ea 1b             	shr    $0x1b,%edx
  800d6d:	01 d0                	add    %edx,%eax
  800d6f:	83 e0 1f             	and    $0x1f,%eax
  800d72:	29 d0                	sub    %edx,%eax
  800d74:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d7f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d82:	83 c3 01             	add    $0x1,%ebx
  800d85:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d88:	75 d8                	jne    800d62 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d8a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d8d:	eb 05                	jmp    800d94 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d8f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800da4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800da7:	50                   	push   %eax
  800da8:	e8 ec f5 ff ff       	call   800399 <fd_alloc>
  800dad:	83 c4 10             	add    $0x10,%esp
  800db0:	89 c2                	mov    %eax,%edx
  800db2:	85 c0                	test   %eax,%eax
  800db4:	0f 88 2c 01 00 00    	js     800ee6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dba:	83 ec 04             	sub    $0x4,%esp
  800dbd:	68 07 04 00 00       	push   $0x407
  800dc2:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc5:	6a 00                	push   $0x0
  800dc7:	e8 b5 f3 ff ff       	call   800181 <sys_page_alloc>
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	89 c2                	mov    %eax,%edx
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	0f 88 0d 01 00 00    	js     800ee6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ddf:	50                   	push   %eax
  800de0:	e8 b4 f5 ff ff       	call   800399 <fd_alloc>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	0f 88 e2 00 00 00    	js     800ed4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 ec 04             	sub    $0x4,%esp
  800df5:	68 07 04 00 00       	push   $0x407
  800dfa:	ff 75 f0             	pushl  -0x10(%ebp)
  800dfd:	6a 00                	push   $0x0
  800dff:	e8 7d f3 ff ff       	call   800181 <sys_page_alloc>
  800e04:	89 c3                	mov    %eax,%ebx
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	0f 88 c3 00 00 00    	js     800ed4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	ff 75 f4             	pushl  -0xc(%ebp)
  800e17:	e8 66 f5 ff ff       	call   800382 <fd2data>
  800e1c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1e:	83 c4 0c             	add    $0xc,%esp
  800e21:	68 07 04 00 00       	push   $0x407
  800e26:	50                   	push   %eax
  800e27:	6a 00                	push   $0x0
  800e29:	e8 53 f3 ff ff       	call   800181 <sys_page_alloc>
  800e2e:	89 c3                	mov    %eax,%ebx
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	85 c0                	test   %eax,%eax
  800e35:	0f 88 89 00 00 00    	js     800ec4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e41:	e8 3c f5 ff ff       	call   800382 <fd2data>
  800e46:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e4d:	50                   	push   %eax
  800e4e:	6a 00                	push   $0x0
  800e50:	56                   	push   %esi
  800e51:	6a 00                	push   $0x0
  800e53:	e8 6c f3 ff ff       	call   8001c4 <sys_page_map>
  800e58:	89 c3                	mov    %eax,%ebx
  800e5a:	83 c4 20             	add    $0x20,%esp
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	78 55                	js     800eb6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e61:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e76:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e84:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e8b:	83 ec 0c             	sub    $0xc,%esp
  800e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e91:	e8 dc f4 ff ff       	call   800372 <fd2num>
  800e96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e99:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e9b:	83 c4 04             	add    $0x4,%esp
  800e9e:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea1:	e8 cc f4 ff ff       	call   800372 <fd2num>
  800ea6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800eac:	83 c4 10             	add    $0x10,%esp
  800eaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb4:	eb 30                	jmp    800ee6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800eb6:	83 ec 08             	sub    $0x8,%esp
  800eb9:	56                   	push   %esi
  800eba:	6a 00                	push   $0x0
  800ebc:	e8 45 f3 ff ff       	call   800206 <sys_page_unmap>
  800ec1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	ff 75 f0             	pushl  -0x10(%ebp)
  800eca:	6a 00                	push   $0x0
  800ecc:	e8 35 f3 ff ff       	call   800206 <sys_page_unmap>
  800ed1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eda:	6a 00                	push   $0x0
  800edc:	e8 25 f3 ff ff       	call   800206 <sys_page_unmap>
  800ee1:	83 c4 10             	add    $0x10,%esp
  800ee4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ee6:	89 d0                	mov    %edx,%eax
  800ee8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef8:	50                   	push   %eax
  800ef9:	ff 75 08             	pushl  0x8(%ebp)
  800efc:	e8 e7 f4 ff ff       	call   8003e8 <fd_lookup>
  800f01:	83 c4 10             	add    $0x10,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	78 18                	js     800f20 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0e:	e8 6f f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800f13:	89 c2                	mov    %eax,%edx
  800f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f18:	e8 21 fd ff ff       	call   800c3e <_pipeisclosed>
  800f1d:	83 c4 10             	add    $0x10,%esp
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f32:	68 49 1f 80 00       	push   $0x801f49
  800f37:	ff 75 0c             	pushl  0xc(%ebp)
  800f3a:	e8 c4 07 00 00       	call   801703 <strcpy>
	return 0;
}
  800f3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f44:	c9                   	leave  
  800f45:	c3                   	ret    

00800f46 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
  800f4c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f52:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f57:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f5d:	eb 2d                	jmp    800f8c <devcons_write+0x46>
		m = n - tot;
  800f5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f62:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f64:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f67:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f6c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f6f:	83 ec 04             	sub    $0x4,%esp
  800f72:	53                   	push   %ebx
  800f73:	03 45 0c             	add    0xc(%ebp),%eax
  800f76:	50                   	push   %eax
  800f77:	57                   	push   %edi
  800f78:	e8 18 09 00 00       	call   801895 <memmove>
		sys_cputs(buf, m);
  800f7d:	83 c4 08             	add    $0x8,%esp
  800f80:	53                   	push   %ebx
  800f81:	57                   	push   %edi
  800f82:	e8 3e f1 ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f87:	01 de                	add    %ebx,%esi
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	89 f0                	mov    %esi,%eax
  800f8e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f91:	72 cc                	jb     800f5f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f96:	5b                   	pop    %ebx
  800f97:	5e                   	pop    %esi
  800f98:	5f                   	pop    %edi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	83 ec 08             	sub    $0x8,%esp
  800fa1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800fa6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800faa:	74 2a                	je     800fd6 <devcons_read+0x3b>
  800fac:	eb 05                	jmp    800fb3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800fae:	e8 af f1 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800fb3:	e8 2b f1 ff ff       	call   8000e3 <sys_cgetc>
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	74 f2                	je     800fae <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 16                	js     800fd6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fc0:	83 f8 04             	cmp    $0x4,%eax
  800fc3:	74 0c                	je     800fd1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc8:	88 02                	mov    %al,(%edx)
	return 1;
  800fca:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcf:	eb 05                	jmp    800fd6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fd1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fe4:	6a 01                	push   $0x1
  800fe6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe9:	50                   	push   %eax
  800fea:	e8 d6 f0 ff ff       	call   8000c5 <sys_cputs>
}
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <getchar>:

int
getchar(void)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800ffa:	6a 01                	push   $0x1
  800ffc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fff:	50                   	push   %eax
  801000:	6a 00                	push   $0x0
  801002:	e8 47 f6 ff ff       	call   80064e <read>
	if (r < 0)
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	78 0f                	js     80101d <getchar+0x29>
		return r;
	if (r < 1)
  80100e:	85 c0                	test   %eax,%eax
  801010:	7e 06                	jle    801018 <getchar+0x24>
		return -E_EOF;
	return c;
  801012:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801016:	eb 05                	jmp    80101d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801018:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801025:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801028:	50                   	push   %eax
  801029:	ff 75 08             	pushl  0x8(%ebp)
  80102c:	e8 b7 f3 ff ff       	call   8003e8 <fd_lookup>
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	85 c0                	test   %eax,%eax
  801036:	78 11                	js     801049 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801041:	39 10                	cmp    %edx,(%eax)
  801043:	0f 94 c0             	sete   %al
  801046:	0f b6 c0             	movzbl %al,%eax
}
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <opencons>:

int
opencons(void)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801051:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801054:	50                   	push   %eax
  801055:	e8 3f f3 ff ff       	call   800399 <fd_alloc>
  80105a:	83 c4 10             	add    $0x10,%esp
		return r;
  80105d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 3e                	js     8010a1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	68 07 04 00 00       	push   $0x407
  80106b:	ff 75 f4             	pushl  -0xc(%ebp)
  80106e:	6a 00                	push   $0x0
  801070:	e8 0c f1 ff ff       	call   800181 <sys_page_alloc>
  801075:	83 c4 10             	add    $0x10,%esp
		return r;
  801078:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80107a:	85 c0                	test   %eax,%eax
  80107c:	78 23                	js     8010a1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80107e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801084:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801087:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801089:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	50                   	push   %eax
  801097:	e8 d6 f2 ff ff       	call   800372 <fd2num>
  80109c:	89 c2                	mov    %eax,%edx
  80109e:	83 c4 10             	add    $0x10,%esp
}
  8010a1:	89 d0                	mov    %edx,%eax
  8010a3:	c9                   	leave  
  8010a4:	c3                   	ret    

008010a5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	56                   	push   %esi
  8010a9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010aa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010ad:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010b3:	e8 8b f0 ff ff       	call   800143 <sys_getenvid>
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	ff 75 0c             	pushl  0xc(%ebp)
  8010be:	ff 75 08             	pushl  0x8(%ebp)
  8010c1:	56                   	push   %esi
  8010c2:	50                   	push   %eax
  8010c3:	68 58 1f 80 00       	push   $0x801f58
  8010c8:	e8 b1 00 00 00       	call   80117e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010cd:	83 c4 18             	add    $0x18,%esp
  8010d0:	53                   	push   %ebx
  8010d1:	ff 75 10             	pushl  0x10(%ebp)
  8010d4:	e8 54 00 00 00       	call   80112d <vcprintf>
	cprintf("\n");
  8010d9:	c7 04 24 42 1f 80 00 	movl   $0x801f42,(%esp)
  8010e0:	e8 99 00 00 00       	call   80117e <cprintf>
  8010e5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010e8:	cc                   	int3   
  8010e9:	eb fd                	jmp    8010e8 <_panic+0x43>

008010eb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 04             	sub    $0x4,%esp
  8010f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010f5:	8b 13                	mov    (%ebx),%edx
  8010f7:	8d 42 01             	lea    0x1(%edx),%eax
  8010fa:	89 03                	mov    %eax,(%ebx)
  8010fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ff:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801103:	3d ff 00 00 00       	cmp    $0xff,%eax
  801108:	75 1a                	jne    801124 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	68 ff 00 00 00       	push   $0xff
  801112:	8d 43 08             	lea    0x8(%ebx),%eax
  801115:	50                   	push   %eax
  801116:	e8 aa ef ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  80111b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801121:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801124:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801128:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112b:	c9                   	leave  
  80112c:	c3                   	ret    

0080112d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801136:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80113d:	00 00 00 
	b.cnt = 0;
  801140:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801147:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80114a:	ff 75 0c             	pushl  0xc(%ebp)
  80114d:	ff 75 08             	pushl  0x8(%ebp)
  801150:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801156:	50                   	push   %eax
  801157:	68 eb 10 80 00       	push   $0x8010eb
  80115c:	e8 54 01 00 00       	call   8012b5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801161:	83 c4 08             	add    $0x8,%esp
  801164:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80116a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801170:	50                   	push   %eax
  801171:	e8 4f ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  801176:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    

0080117e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801184:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801187:	50                   	push   %eax
  801188:	ff 75 08             	pushl  0x8(%ebp)
  80118b:	e8 9d ff ff ff       	call   80112d <vcprintf>
	va_end(ap);

	return cnt;
}
  801190:	c9                   	leave  
  801191:	c3                   	ret    

00801192 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	57                   	push   %edi
  801196:	56                   	push   %esi
  801197:	53                   	push   %ebx
  801198:	83 ec 1c             	sub    $0x1c,%esp
  80119b:	89 c7                	mov    %eax,%edi
  80119d:	89 d6                	mov    %edx,%esi
  80119f:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8011b6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8011b9:	39 d3                	cmp    %edx,%ebx
  8011bb:	72 05                	jb     8011c2 <printnum+0x30>
  8011bd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011c0:	77 45                	ja     801207 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011c2:	83 ec 0c             	sub    $0xc,%esp
  8011c5:	ff 75 18             	pushl  0x18(%ebp)
  8011c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8011cb:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011ce:	53                   	push   %ebx
  8011cf:	ff 75 10             	pushl  0x10(%ebp)
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011db:	ff 75 dc             	pushl  -0x24(%ebp)
  8011de:	ff 75 d8             	pushl  -0x28(%ebp)
  8011e1:	e8 9a 09 00 00       	call   801b80 <__udivdi3>
  8011e6:	83 c4 18             	add    $0x18,%esp
  8011e9:	52                   	push   %edx
  8011ea:	50                   	push   %eax
  8011eb:	89 f2                	mov    %esi,%edx
  8011ed:	89 f8                	mov    %edi,%eax
  8011ef:	e8 9e ff ff ff       	call   801192 <printnum>
  8011f4:	83 c4 20             	add    $0x20,%esp
  8011f7:	eb 18                	jmp    801211 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	56                   	push   %esi
  8011fd:	ff 75 18             	pushl  0x18(%ebp)
  801200:	ff d7                	call   *%edi
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	eb 03                	jmp    80120a <printnum+0x78>
  801207:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80120a:	83 eb 01             	sub    $0x1,%ebx
  80120d:	85 db                	test   %ebx,%ebx
  80120f:	7f e8                	jg     8011f9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801211:	83 ec 08             	sub    $0x8,%esp
  801214:	56                   	push   %esi
  801215:	83 ec 04             	sub    $0x4,%esp
  801218:	ff 75 e4             	pushl  -0x1c(%ebp)
  80121b:	ff 75 e0             	pushl  -0x20(%ebp)
  80121e:	ff 75 dc             	pushl  -0x24(%ebp)
  801221:	ff 75 d8             	pushl  -0x28(%ebp)
  801224:	e8 87 0a 00 00       	call   801cb0 <__umoddi3>
  801229:	83 c4 14             	add    $0x14,%esp
  80122c:	0f be 80 7b 1f 80 00 	movsbl 0x801f7b(%eax),%eax
  801233:	50                   	push   %eax
  801234:	ff d7                	call   *%edi
}
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123c:	5b                   	pop    %ebx
  80123d:	5e                   	pop    %esi
  80123e:	5f                   	pop    %edi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801244:	83 fa 01             	cmp    $0x1,%edx
  801247:	7e 0e                	jle    801257 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801249:	8b 10                	mov    (%eax),%edx
  80124b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80124e:	89 08                	mov    %ecx,(%eax)
  801250:	8b 02                	mov    (%edx),%eax
  801252:	8b 52 04             	mov    0x4(%edx),%edx
  801255:	eb 22                	jmp    801279 <getuint+0x38>
	else if (lflag)
  801257:	85 d2                	test   %edx,%edx
  801259:	74 10                	je     80126b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80125b:	8b 10                	mov    (%eax),%edx
  80125d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801260:	89 08                	mov    %ecx,(%eax)
  801262:	8b 02                	mov    (%edx),%eax
  801264:	ba 00 00 00 00       	mov    $0x0,%edx
  801269:	eb 0e                	jmp    801279 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80126b:	8b 10                	mov    (%eax),%edx
  80126d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801270:	89 08                	mov    %ecx,(%eax)
  801272:	8b 02                	mov    (%edx),%eax
  801274:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801281:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801285:	8b 10                	mov    (%eax),%edx
  801287:	3b 50 04             	cmp    0x4(%eax),%edx
  80128a:	73 0a                	jae    801296 <sprintputch+0x1b>
		*b->buf++ = ch;
  80128c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80128f:	89 08                	mov    %ecx,(%eax)
  801291:	8b 45 08             	mov    0x8(%ebp),%eax
  801294:	88 02                	mov    %al,(%edx)
}
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80129e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012a1:	50                   	push   %eax
  8012a2:	ff 75 10             	pushl  0x10(%ebp)
  8012a5:	ff 75 0c             	pushl  0xc(%ebp)
  8012a8:	ff 75 08             	pushl  0x8(%ebp)
  8012ab:	e8 05 00 00 00       	call   8012b5 <vprintfmt>
	va_end(ap);
}
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	c9                   	leave  
  8012b4:	c3                   	ret    

008012b5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	57                   	push   %edi
  8012b9:	56                   	push   %esi
  8012ba:	53                   	push   %ebx
  8012bb:	83 ec 2c             	sub    $0x2c,%esp
  8012be:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012c4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012c7:	eb 12                	jmp    8012db <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	0f 84 89 03 00 00    	je     80165a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012d1:	83 ec 08             	sub    $0x8,%esp
  8012d4:	53                   	push   %ebx
  8012d5:	50                   	push   %eax
  8012d6:	ff d6                	call   *%esi
  8012d8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012db:	83 c7 01             	add    $0x1,%edi
  8012de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012e2:	83 f8 25             	cmp    $0x25,%eax
  8012e5:	75 e2                	jne    8012c9 <vprintfmt+0x14>
  8012e7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012eb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012f9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801300:	ba 00 00 00 00       	mov    $0x0,%edx
  801305:	eb 07                	jmp    80130e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801307:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80130a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130e:	8d 47 01             	lea    0x1(%edi),%eax
  801311:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801314:	0f b6 07             	movzbl (%edi),%eax
  801317:	0f b6 c8             	movzbl %al,%ecx
  80131a:	83 e8 23             	sub    $0x23,%eax
  80131d:	3c 55                	cmp    $0x55,%al
  80131f:	0f 87 1a 03 00 00    	ja     80163f <vprintfmt+0x38a>
  801325:	0f b6 c0             	movzbl %al,%eax
  801328:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  80132f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801332:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801336:	eb d6                	jmp    80130e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
  801340:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801343:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801346:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80134a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80134d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801350:	83 fa 09             	cmp    $0x9,%edx
  801353:	77 39                	ja     80138e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801355:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801358:	eb e9                	jmp    801343 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80135a:	8b 45 14             	mov    0x14(%ebp),%eax
  80135d:	8d 48 04             	lea    0x4(%eax),%ecx
  801360:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801363:	8b 00                	mov    (%eax),%eax
  801365:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80136b:	eb 27                	jmp    801394 <vprintfmt+0xdf>
  80136d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801370:	85 c0                	test   %eax,%eax
  801372:	b9 00 00 00 00       	mov    $0x0,%ecx
  801377:	0f 49 c8             	cmovns %eax,%ecx
  80137a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801380:	eb 8c                	jmp    80130e <vprintfmt+0x59>
  801382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801385:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80138c:	eb 80                	jmp    80130e <vprintfmt+0x59>
  80138e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801391:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801394:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801398:	0f 89 70 ff ff ff    	jns    80130e <vprintfmt+0x59>
				width = precision, precision = -1;
  80139e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8013a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013a4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8013ab:	e9 5e ff ff ff       	jmp    80130e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8013b0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8013b6:	e9 53 ff ff ff       	jmp    80130e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8013bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013be:	8d 50 04             	lea    0x4(%eax),%edx
  8013c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c4:	83 ec 08             	sub    $0x8,%esp
  8013c7:	53                   	push   %ebx
  8013c8:	ff 30                	pushl  (%eax)
  8013ca:	ff d6                	call   *%esi
			break;
  8013cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013d2:	e9 04 ff ff ff       	jmp    8012db <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8013da:	8d 50 04             	lea    0x4(%eax),%edx
  8013dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e0:	8b 00                	mov    (%eax),%eax
  8013e2:	99                   	cltd   
  8013e3:	31 d0                	xor    %edx,%eax
  8013e5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013e7:	83 f8 0f             	cmp    $0xf,%eax
  8013ea:	7f 0b                	jg     8013f7 <vprintfmt+0x142>
  8013ec:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  8013f3:	85 d2                	test   %edx,%edx
  8013f5:	75 18                	jne    80140f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013f7:	50                   	push   %eax
  8013f8:	68 93 1f 80 00       	push   $0x801f93
  8013fd:	53                   	push   %ebx
  8013fe:	56                   	push   %esi
  8013ff:	e8 94 fe ff ff       	call   801298 <printfmt>
  801404:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80140a:	e9 cc fe ff ff       	jmp    8012db <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80140f:	52                   	push   %edx
  801410:	68 fd 1e 80 00       	push   $0x801efd
  801415:	53                   	push   %ebx
  801416:	56                   	push   %esi
  801417:	e8 7c fe ff ff       	call   801298 <printfmt>
  80141c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80141f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801422:	e9 b4 fe ff ff       	jmp    8012db <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801427:	8b 45 14             	mov    0x14(%ebp),%eax
  80142a:	8d 50 04             	lea    0x4(%eax),%edx
  80142d:	89 55 14             	mov    %edx,0x14(%ebp)
  801430:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801432:	85 ff                	test   %edi,%edi
  801434:	b8 8c 1f 80 00       	mov    $0x801f8c,%eax
  801439:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80143c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801440:	0f 8e 94 00 00 00    	jle    8014da <vprintfmt+0x225>
  801446:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80144a:	0f 84 98 00 00 00    	je     8014e8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801450:	83 ec 08             	sub    $0x8,%esp
  801453:	ff 75 d0             	pushl  -0x30(%ebp)
  801456:	57                   	push   %edi
  801457:	e8 86 02 00 00       	call   8016e2 <strnlen>
  80145c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80145f:	29 c1                	sub    %eax,%ecx
  801461:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801464:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801467:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80146b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80146e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801471:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801473:	eb 0f                	jmp    801484 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	53                   	push   %ebx
  801479:	ff 75 e0             	pushl  -0x20(%ebp)
  80147c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80147e:	83 ef 01             	sub    $0x1,%edi
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	85 ff                	test   %edi,%edi
  801486:	7f ed                	jg     801475 <vprintfmt+0x1c0>
  801488:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80148b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80148e:	85 c9                	test   %ecx,%ecx
  801490:	b8 00 00 00 00       	mov    $0x0,%eax
  801495:	0f 49 c1             	cmovns %ecx,%eax
  801498:	29 c1                	sub    %eax,%ecx
  80149a:	89 75 08             	mov    %esi,0x8(%ebp)
  80149d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a3:	89 cb                	mov    %ecx,%ebx
  8014a5:	eb 4d                	jmp    8014f4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8014a7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014ab:	74 1b                	je     8014c8 <vprintfmt+0x213>
  8014ad:	0f be c0             	movsbl %al,%eax
  8014b0:	83 e8 20             	sub    $0x20,%eax
  8014b3:	83 f8 5e             	cmp    $0x5e,%eax
  8014b6:	76 10                	jbe    8014c8 <vprintfmt+0x213>
					putch('?', putdat);
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	ff 75 0c             	pushl  0xc(%ebp)
  8014be:	6a 3f                	push   $0x3f
  8014c0:	ff 55 08             	call   *0x8(%ebp)
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	eb 0d                	jmp    8014d5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ce:	52                   	push   %edx
  8014cf:	ff 55 08             	call   *0x8(%ebp)
  8014d2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014d5:	83 eb 01             	sub    $0x1,%ebx
  8014d8:	eb 1a                	jmp    8014f4 <vprintfmt+0x23f>
  8014da:	89 75 08             	mov    %esi,0x8(%ebp)
  8014dd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014e3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014e6:	eb 0c                	jmp    8014f4 <vprintfmt+0x23f>
  8014e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8014eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014f4:	83 c7 01             	add    $0x1,%edi
  8014f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014fb:	0f be d0             	movsbl %al,%edx
  8014fe:	85 d2                	test   %edx,%edx
  801500:	74 23                	je     801525 <vprintfmt+0x270>
  801502:	85 f6                	test   %esi,%esi
  801504:	78 a1                	js     8014a7 <vprintfmt+0x1f2>
  801506:	83 ee 01             	sub    $0x1,%esi
  801509:	79 9c                	jns    8014a7 <vprintfmt+0x1f2>
  80150b:	89 df                	mov    %ebx,%edi
  80150d:	8b 75 08             	mov    0x8(%ebp),%esi
  801510:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801513:	eb 18                	jmp    80152d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	53                   	push   %ebx
  801519:	6a 20                	push   $0x20
  80151b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80151d:	83 ef 01             	sub    $0x1,%edi
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	eb 08                	jmp    80152d <vprintfmt+0x278>
  801525:	89 df                	mov    %ebx,%edi
  801527:	8b 75 08             	mov    0x8(%ebp),%esi
  80152a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80152d:	85 ff                	test   %edi,%edi
  80152f:	7f e4                	jg     801515 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801534:	e9 a2 fd ff ff       	jmp    8012db <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801539:	83 fa 01             	cmp    $0x1,%edx
  80153c:	7e 16                	jle    801554 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80153e:	8b 45 14             	mov    0x14(%ebp),%eax
  801541:	8d 50 08             	lea    0x8(%eax),%edx
  801544:	89 55 14             	mov    %edx,0x14(%ebp)
  801547:	8b 50 04             	mov    0x4(%eax),%edx
  80154a:	8b 00                	mov    (%eax),%eax
  80154c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801552:	eb 32                	jmp    801586 <vprintfmt+0x2d1>
	else if (lflag)
  801554:	85 d2                	test   %edx,%edx
  801556:	74 18                	je     801570 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801558:	8b 45 14             	mov    0x14(%ebp),%eax
  80155b:	8d 50 04             	lea    0x4(%eax),%edx
  80155e:	89 55 14             	mov    %edx,0x14(%ebp)
  801561:	8b 00                	mov    (%eax),%eax
  801563:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801566:	89 c1                	mov    %eax,%ecx
  801568:	c1 f9 1f             	sar    $0x1f,%ecx
  80156b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80156e:	eb 16                	jmp    801586 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801570:	8b 45 14             	mov    0x14(%ebp),%eax
  801573:	8d 50 04             	lea    0x4(%eax),%edx
  801576:	89 55 14             	mov    %edx,0x14(%ebp)
  801579:	8b 00                	mov    (%eax),%eax
  80157b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80157e:	89 c1                	mov    %eax,%ecx
  801580:	c1 f9 1f             	sar    $0x1f,%ecx
  801583:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801586:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801589:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80158c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801591:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801595:	79 74                	jns    80160b <vprintfmt+0x356>
				putch('-', putdat);
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	53                   	push   %ebx
  80159b:	6a 2d                	push   $0x2d
  80159d:	ff d6                	call   *%esi
				num = -(long long) num;
  80159f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8015a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8015a5:	f7 d8                	neg    %eax
  8015a7:	83 d2 00             	adc    $0x0,%edx
  8015aa:	f7 da                	neg    %edx
  8015ac:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8015af:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8015b4:	eb 55                	jmp    80160b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8015b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b9:	e8 83 fc ff ff       	call   801241 <getuint>
			base = 10;
  8015be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015c3:	eb 46                	jmp    80160b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8015c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8015c8:	e8 74 fc ff ff       	call   801241 <getuint>
			base = 8;
  8015cd:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015d2:	eb 37                	jmp    80160b <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	53                   	push   %ebx
  8015d8:	6a 30                	push   $0x30
  8015da:	ff d6                	call   *%esi
			putch('x', putdat);
  8015dc:	83 c4 08             	add    $0x8,%esp
  8015df:	53                   	push   %ebx
  8015e0:	6a 78                	push   $0x78
  8015e2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e7:	8d 50 04             	lea    0x4(%eax),%edx
  8015ea:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015ed:	8b 00                	mov    (%eax),%eax
  8015ef:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015f4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015f7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015fc:	eb 0d                	jmp    80160b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015fe:	8d 45 14             	lea    0x14(%ebp),%eax
  801601:	e8 3b fc ff ff       	call   801241 <getuint>
			base = 16;
  801606:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80160b:	83 ec 0c             	sub    $0xc,%esp
  80160e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801612:	57                   	push   %edi
  801613:	ff 75 e0             	pushl  -0x20(%ebp)
  801616:	51                   	push   %ecx
  801617:	52                   	push   %edx
  801618:	50                   	push   %eax
  801619:	89 da                	mov    %ebx,%edx
  80161b:	89 f0                	mov    %esi,%eax
  80161d:	e8 70 fb ff ff       	call   801192 <printnum>
			break;
  801622:	83 c4 20             	add    $0x20,%esp
  801625:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801628:	e9 ae fc ff ff       	jmp    8012db <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80162d:	83 ec 08             	sub    $0x8,%esp
  801630:	53                   	push   %ebx
  801631:	51                   	push   %ecx
  801632:	ff d6                	call   *%esi
			break;
  801634:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80163a:	e9 9c fc ff ff       	jmp    8012db <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	53                   	push   %ebx
  801643:	6a 25                	push   $0x25
  801645:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	eb 03                	jmp    80164f <vprintfmt+0x39a>
  80164c:	83 ef 01             	sub    $0x1,%edi
  80164f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801653:	75 f7                	jne    80164c <vprintfmt+0x397>
  801655:	e9 81 fc ff ff       	jmp    8012db <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80165a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5f                   	pop    %edi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	83 ec 18             	sub    $0x18,%esp
  801668:	8b 45 08             	mov    0x8(%ebp),%eax
  80166b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80166e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801671:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801675:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801678:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80167f:	85 c0                	test   %eax,%eax
  801681:	74 26                	je     8016a9 <vsnprintf+0x47>
  801683:	85 d2                	test   %edx,%edx
  801685:	7e 22                	jle    8016a9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801687:	ff 75 14             	pushl  0x14(%ebp)
  80168a:	ff 75 10             	pushl  0x10(%ebp)
  80168d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	68 7b 12 80 00       	push   $0x80127b
  801696:	e8 1a fc ff ff       	call   8012b5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80169b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80169e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	eb 05                	jmp    8016ae <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016b6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016b9:	50                   	push   %eax
  8016ba:	ff 75 10             	pushl  0x10(%ebp)
  8016bd:	ff 75 0c             	pushl  0xc(%ebp)
  8016c0:	ff 75 08             	pushl  0x8(%ebp)
  8016c3:	e8 9a ff ff ff       	call   801662 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d5:	eb 03                	jmp    8016da <strlen+0x10>
		n++;
  8016d7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016de:	75 f7                	jne    8016d7 <strlen+0xd>
		n++;
	return n;
}
  8016e0:	5d                   	pop    %ebp
  8016e1:	c3                   	ret    

008016e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f0:	eb 03                	jmp    8016f5 <strnlen+0x13>
		n++;
  8016f2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f5:	39 c2                	cmp    %eax,%edx
  8016f7:	74 08                	je     801701 <strnlen+0x1f>
  8016f9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016fd:	75 f3                	jne    8016f2 <strnlen+0x10>
  8016ff:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	53                   	push   %ebx
  801707:	8b 45 08             	mov    0x8(%ebp),%eax
  80170a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	83 c2 01             	add    $0x1,%edx
  801712:	83 c1 01             	add    $0x1,%ecx
  801715:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801719:	88 5a ff             	mov    %bl,-0x1(%edx)
  80171c:	84 db                	test   %bl,%bl
  80171e:	75 ef                	jne    80170f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801720:	5b                   	pop    %ebx
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	53                   	push   %ebx
  801727:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80172a:	53                   	push   %ebx
  80172b:	e8 9a ff ff ff       	call   8016ca <strlen>
  801730:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801733:	ff 75 0c             	pushl  0xc(%ebp)
  801736:	01 d8                	add    %ebx,%eax
  801738:	50                   	push   %eax
  801739:	e8 c5 ff ff ff       	call   801703 <strcpy>
	return dst;
}
  80173e:	89 d8                	mov    %ebx,%eax
  801740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
  80174a:	8b 75 08             	mov    0x8(%ebp),%esi
  80174d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801750:	89 f3                	mov    %esi,%ebx
  801752:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801755:	89 f2                	mov    %esi,%edx
  801757:	eb 0f                	jmp    801768 <strncpy+0x23>
		*dst++ = *src;
  801759:	83 c2 01             	add    $0x1,%edx
  80175c:	0f b6 01             	movzbl (%ecx),%eax
  80175f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801762:	80 39 01             	cmpb   $0x1,(%ecx)
  801765:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801768:	39 da                	cmp    %ebx,%edx
  80176a:	75 ed                	jne    801759 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80176c:	89 f0                	mov    %esi,%eax
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	56                   	push   %esi
  801776:	53                   	push   %ebx
  801777:	8b 75 08             	mov    0x8(%ebp),%esi
  80177a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177d:	8b 55 10             	mov    0x10(%ebp),%edx
  801780:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801782:	85 d2                	test   %edx,%edx
  801784:	74 21                	je     8017a7 <strlcpy+0x35>
  801786:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80178a:	89 f2                	mov    %esi,%edx
  80178c:	eb 09                	jmp    801797 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80178e:	83 c2 01             	add    $0x1,%edx
  801791:	83 c1 01             	add    $0x1,%ecx
  801794:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801797:	39 c2                	cmp    %eax,%edx
  801799:	74 09                	je     8017a4 <strlcpy+0x32>
  80179b:	0f b6 19             	movzbl (%ecx),%ebx
  80179e:	84 db                	test   %bl,%bl
  8017a0:	75 ec                	jne    80178e <strlcpy+0x1c>
  8017a2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017a4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017a7:	29 f0                	sub    %esi,%eax
}
  8017a9:	5b                   	pop    %ebx
  8017aa:	5e                   	pop    %esi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    

008017ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017b6:	eb 06                	jmp    8017be <strcmp+0x11>
		p++, q++;
  8017b8:	83 c1 01             	add    $0x1,%ecx
  8017bb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017be:	0f b6 01             	movzbl (%ecx),%eax
  8017c1:	84 c0                	test   %al,%al
  8017c3:	74 04                	je     8017c9 <strcmp+0x1c>
  8017c5:	3a 02                	cmp    (%edx),%al
  8017c7:	74 ef                	je     8017b8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c9:	0f b6 c0             	movzbl %al,%eax
  8017cc:	0f b6 12             	movzbl (%edx),%edx
  8017cf:	29 d0                	sub    %edx,%eax
}
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	53                   	push   %ebx
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017dd:	89 c3                	mov    %eax,%ebx
  8017df:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017e2:	eb 06                	jmp    8017ea <strncmp+0x17>
		n--, p++, q++;
  8017e4:	83 c0 01             	add    $0x1,%eax
  8017e7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017ea:	39 d8                	cmp    %ebx,%eax
  8017ec:	74 15                	je     801803 <strncmp+0x30>
  8017ee:	0f b6 08             	movzbl (%eax),%ecx
  8017f1:	84 c9                	test   %cl,%cl
  8017f3:	74 04                	je     8017f9 <strncmp+0x26>
  8017f5:	3a 0a                	cmp    (%edx),%cl
  8017f7:	74 eb                	je     8017e4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017f9:	0f b6 00             	movzbl (%eax),%eax
  8017fc:	0f b6 12             	movzbl (%edx),%edx
  8017ff:	29 d0                	sub    %edx,%eax
  801801:	eb 05                	jmp    801808 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801803:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801808:	5b                   	pop    %ebx
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    

0080180b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801815:	eb 07                	jmp    80181e <strchr+0x13>
		if (*s == c)
  801817:	38 ca                	cmp    %cl,%dl
  801819:	74 0f                	je     80182a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80181b:	83 c0 01             	add    $0x1,%eax
  80181e:	0f b6 10             	movzbl (%eax),%edx
  801821:	84 d2                	test   %dl,%dl
  801823:	75 f2                	jne    801817 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801825:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182a:	5d                   	pop    %ebp
  80182b:	c3                   	ret    

0080182c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	8b 45 08             	mov    0x8(%ebp),%eax
  801832:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801836:	eb 03                	jmp    80183b <strfind+0xf>
  801838:	83 c0 01             	add    $0x1,%eax
  80183b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80183e:	38 ca                	cmp    %cl,%dl
  801840:	74 04                	je     801846 <strfind+0x1a>
  801842:	84 d2                	test   %dl,%dl
  801844:	75 f2                	jne    801838 <strfind+0xc>
			break;
	return (char *) s;
}
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	57                   	push   %edi
  80184c:	56                   	push   %esi
  80184d:	53                   	push   %ebx
  80184e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801851:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801854:	85 c9                	test   %ecx,%ecx
  801856:	74 36                	je     80188e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801858:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80185e:	75 28                	jne    801888 <memset+0x40>
  801860:	f6 c1 03             	test   $0x3,%cl
  801863:	75 23                	jne    801888 <memset+0x40>
		c &= 0xFF;
  801865:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801869:	89 d3                	mov    %edx,%ebx
  80186b:	c1 e3 08             	shl    $0x8,%ebx
  80186e:	89 d6                	mov    %edx,%esi
  801870:	c1 e6 18             	shl    $0x18,%esi
  801873:	89 d0                	mov    %edx,%eax
  801875:	c1 e0 10             	shl    $0x10,%eax
  801878:	09 f0                	or     %esi,%eax
  80187a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80187c:	89 d8                	mov    %ebx,%eax
  80187e:	09 d0                	or     %edx,%eax
  801880:	c1 e9 02             	shr    $0x2,%ecx
  801883:	fc                   	cld    
  801884:	f3 ab                	rep stos %eax,%es:(%edi)
  801886:	eb 06                	jmp    80188e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188b:	fc                   	cld    
  80188c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80188e:	89 f8                	mov    %edi,%eax
  801890:	5b                   	pop    %ebx
  801891:	5e                   	pop    %esi
  801892:	5f                   	pop    %edi
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    

00801895 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	57                   	push   %edi
  801899:	56                   	push   %esi
  80189a:	8b 45 08             	mov    0x8(%ebp),%eax
  80189d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018a3:	39 c6                	cmp    %eax,%esi
  8018a5:	73 35                	jae    8018dc <memmove+0x47>
  8018a7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018aa:	39 d0                	cmp    %edx,%eax
  8018ac:	73 2e                	jae    8018dc <memmove+0x47>
		s += n;
		d += n;
  8018ae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b1:	89 d6                	mov    %edx,%esi
  8018b3:	09 fe                	or     %edi,%esi
  8018b5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018bb:	75 13                	jne    8018d0 <memmove+0x3b>
  8018bd:	f6 c1 03             	test   $0x3,%cl
  8018c0:	75 0e                	jne    8018d0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018c2:	83 ef 04             	sub    $0x4,%edi
  8018c5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018c8:	c1 e9 02             	shr    $0x2,%ecx
  8018cb:	fd                   	std    
  8018cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ce:	eb 09                	jmp    8018d9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018d0:	83 ef 01             	sub    $0x1,%edi
  8018d3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018d6:	fd                   	std    
  8018d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018d9:	fc                   	cld    
  8018da:	eb 1d                	jmp    8018f9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018dc:	89 f2                	mov    %esi,%edx
  8018de:	09 c2                	or     %eax,%edx
  8018e0:	f6 c2 03             	test   $0x3,%dl
  8018e3:	75 0f                	jne    8018f4 <memmove+0x5f>
  8018e5:	f6 c1 03             	test   $0x3,%cl
  8018e8:	75 0a                	jne    8018f4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018ea:	c1 e9 02             	shr    $0x2,%ecx
  8018ed:	89 c7                	mov    %eax,%edi
  8018ef:	fc                   	cld    
  8018f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018f2:	eb 05                	jmp    8018f9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018f4:	89 c7                	mov    %eax,%edi
  8018f6:	fc                   	cld    
  8018f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018f9:	5e                   	pop    %esi
  8018fa:	5f                   	pop    %edi
  8018fb:	5d                   	pop    %ebp
  8018fc:	c3                   	ret    

008018fd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801900:	ff 75 10             	pushl  0x10(%ebp)
  801903:	ff 75 0c             	pushl  0xc(%ebp)
  801906:	ff 75 08             	pushl  0x8(%ebp)
  801909:	e8 87 ff ff ff       	call   801895 <memmove>
}
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	56                   	push   %esi
  801914:	53                   	push   %ebx
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191b:	89 c6                	mov    %eax,%esi
  80191d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801920:	eb 1a                	jmp    80193c <memcmp+0x2c>
		if (*s1 != *s2)
  801922:	0f b6 08             	movzbl (%eax),%ecx
  801925:	0f b6 1a             	movzbl (%edx),%ebx
  801928:	38 d9                	cmp    %bl,%cl
  80192a:	74 0a                	je     801936 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80192c:	0f b6 c1             	movzbl %cl,%eax
  80192f:	0f b6 db             	movzbl %bl,%ebx
  801932:	29 d8                	sub    %ebx,%eax
  801934:	eb 0f                	jmp    801945 <memcmp+0x35>
		s1++, s2++;
  801936:	83 c0 01             	add    $0x1,%eax
  801939:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80193c:	39 f0                	cmp    %esi,%eax
  80193e:	75 e2                	jne    801922 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801940:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801945:	5b                   	pop    %ebx
  801946:	5e                   	pop    %esi
  801947:	5d                   	pop    %ebp
  801948:	c3                   	ret    

00801949 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	53                   	push   %ebx
  80194d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801950:	89 c1                	mov    %eax,%ecx
  801952:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801955:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801959:	eb 0a                	jmp    801965 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80195b:	0f b6 10             	movzbl (%eax),%edx
  80195e:	39 da                	cmp    %ebx,%edx
  801960:	74 07                	je     801969 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801962:	83 c0 01             	add    $0x1,%eax
  801965:	39 c8                	cmp    %ecx,%eax
  801967:	72 f2                	jb     80195b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801969:	5b                   	pop    %ebx
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	57                   	push   %edi
  801970:	56                   	push   %esi
  801971:	53                   	push   %ebx
  801972:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801975:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801978:	eb 03                	jmp    80197d <strtol+0x11>
		s++;
  80197a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80197d:	0f b6 01             	movzbl (%ecx),%eax
  801980:	3c 20                	cmp    $0x20,%al
  801982:	74 f6                	je     80197a <strtol+0xe>
  801984:	3c 09                	cmp    $0x9,%al
  801986:	74 f2                	je     80197a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801988:	3c 2b                	cmp    $0x2b,%al
  80198a:	75 0a                	jne    801996 <strtol+0x2a>
		s++;
  80198c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80198f:	bf 00 00 00 00       	mov    $0x0,%edi
  801994:	eb 11                	jmp    8019a7 <strtol+0x3b>
  801996:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80199b:	3c 2d                	cmp    $0x2d,%al
  80199d:	75 08                	jne    8019a7 <strtol+0x3b>
		s++, neg = 1;
  80199f:	83 c1 01             	add    $0x1,%ecx
  8019a2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019a7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019ad:	75 15                	jne    8019c4 <strtol+0x58>
  8019af:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b2:	75 10                	jne    8019c4 <strtol+0x58>
  8019b4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019b8:	75 7c                	jne    801a36 <strtol+0xca>
		s += 2, base = 16;
  8019ba:	83 c1 02             	add    $0x2,%ecx
  8019bd:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019c2:	eb 16                	jmp    8019da <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019c4:	85 db                	test   %ebx,%ebx
  8019c6:	75 12                	jne    8019da <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019c8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019cd:	80 39 30             	cmpb   $0x30,(%ecx)
  8019d0:	75 08                	jne    8019da <strtol+0x6e>
		s++, base = 8;
  8019d2:	83 c1 01             	add    $0x1,%ecx
  8019d5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019da:	b8 00 00 00 00       	mov    $0x0,%eax
  8019df:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019e2:	0f b6 11             	movzbl (%ecx),%edx
  8019e5:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019e8:	89 f3                	mov    %esi,%ebx
  8019ea:	80 fb 09             	cmp    $0x9,%bl
  8019ed:	77 08                	ja     8019f7 <strtol+0x8b>
			dig = *s - '0';
  8019ef:	0f be d2             	movsbl %dl,%edx
  8019f2:	83 ea 30             	sub    $0x30,%edx
  8019f5:	eb 22                	jmp    801a19 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019f7:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019fa:	89 f3                	mov    %esi,%ebx
  8019fc:	80 fb 19             	cmp    $0x19,%bl
  8019ff:	77 08                	ja     801a09 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a01:	0f be d2             	movsbl %dl,%edx
  801a04:	83 ea 57             	sub    $0x57,%edx
  801a07:	eb 10                	jmp    801a19 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a09:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a0c:	89 f3                	mov    %esi,%ebx
  801a0e:	80 fb 19             	cmp    $0x19,%bl
  801a11:	77 16                	ja     801a29 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a13:	0f be d2             	movsbl %dl,%edx
  801a16:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a19:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a1c:	7d 0b                	jge    801a29 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a1e:	83 c1 01             	add    $0x1,%ecx
  801a21:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a25:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a27:	eb b9                	jmp    8019e2 <strtol+0x76>

	if (endptr)
  801a29:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a2d:	74 0d                	je     801a3c <strtol+0xd0>
		*endptr = (char *) s;
  801a2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a32:	89 0e                	mov    %ecx,(%esi)
  801a34:	eb 06                	jmp    801a3c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a36:	85 db                	test   %ebx,%ebx
  801a38:	74 98                	je     8019d2 <strtol+0x66>
  801a3a:	eb 9e                	jmp    8019da <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a3c:	89 c2                	mov    %eax,%edx
  801a3e:	f7 da                	neg    %edx
  801a40:	85 ff                	test   %edi,%edi
  801a42:	0f 45 c2             	cmovne %edx,%eax
}
  801a45:	5b                   	pop    %ebx
  801a46:	5e                   	pop    %esi
  801a47:	5f                   	pop    %edi
  801a48:	5d                   	pop    %ebp
  801a49:	c3                   	ret    

00801a4a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	56                   	push   %esi
  801a4e:	53                   	push   %ebx
  801a4f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801a58:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801a5a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a5f:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	50                   	push   %eax
  801a66:	e8 c6 e8 ff ff       	call   800331 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	78 0e                	js     801a80 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801a72:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a78:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801a7b:	8b 52 78             	mov    0x78(%edx),%edx
  801a7e:	eb 0a                	jmp    801a8a <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801a80:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801a85:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801a8a:	85 f6                	test   %esi,%esi
  801a8c:	74 02                	je     801a90 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801a8e:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801a90:	85 db                	test   %ebx,%ebx
  801a92:	74 02                	je     801a96 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801a94:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 08                	js     801aa2 <ipc_recv+0x58>
  801a9a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9f:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801aa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	57                   	push   %edi
  801aad:	56                   	push   %esi
  801aae:	53                   	push   %ebx
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801abb:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801abd:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801ac2:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801ac5:	ff 75 14             	pushl  0x14(%ebp)
  801ac8:	53                   	push   %ebx
  801ac9:	56                   	push   %esi
  801aca:	57                   	push   %edi
  801acb:	e8 3e e8 ff ff       	call   80030e <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad6:	75 07                	jne    801adf <ipc_send+0x36>
				    sys_yield();
  801ad8:	e8 85 e6 ff ff       	call   800162 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801add:	eb e6                	jmp    801ac5 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	74 12                	je     801af5 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801ae3:	50                   	push   %eax
  801ae4:	68 80 22 80 00       	push   $0x802280
  801ae9:	6a 4b                	push   $0x4b
  801aeb:	68 94 22 80 00       	push   $0x802294
  801af0:	e8 b0 f5 ff ff       	call   8010a5 <_panic>
			 }
	   }
}
  801af5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af8:	5b                   	pop    %ebx
  801af9:	5e                   	pop    %esi
  801afa:	5f                   	pop    %edi
  801afb:	5d                   	pop    %ebp
  801afc:	c3                   	ret    

00801afd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801b03:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801b08:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b0b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b11:	8b 52 50             	mov    0x50(%edx),%edx
  801b14:	39 ca                	cmp    %ecx,%edx
  801b16:	75 0d                	jne    801b25 <ipc_find_env+0x28>
				    return envs[i].env_id;
  801b18:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b1b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b20:	8b 40 48             	mov    0x48(%eax),%eax
  801b23:	eb 0f                	jmp    801b34 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801b25:	83 c0 01             	add    $0x1,%eax
  801b28:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b2d:	75 d9                	jne    801b08 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801b2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3c:	89 d0                	mov    %edx,%eax
  801b3e:	c1 e8 16             	shr    $0x16,%eax
  801b41:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b48:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b4d:	f6 c1 01             	test   $0x1,%cl
  801b50:	74 1d                	je     801b6f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b52:	c1 ea 0c             	shr    $0xc,%edx
  801b55:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b5c:	f6 c2 01             	test   $0x1,%dl
  801b5f:	74 0e                	je     801b6f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b61:	c1 ea 0c             	shr    $0xc,%edx
  801b64:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b6b:	ef 
  801b6c:	0f b7 c0             	movzwl %ax,%eax
}
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    
  801b71:	66 90                	xchg   %ax,%ax
  801b73:	66 90                	xchg   %ax,%ax
  801b75:	66 90                	xchg   %ax,%ax
  801b77:	66 90                	xchg   %ax,%ax
  801b79:	66 90                	xchg   %ax,%ax
  801b7b:	66 90                	xchg   %ax,%ax
  801b7d:	66 90                	xchg   %ax,%ax
  801b7f:	90                   	nop

00801b80 <__udivdi3>:
  801b80:	55                   	push   %ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 1c             	sub    $0x1c,%esp
  801b87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b97:	85 f6                	test   %esi,%esi
  801b99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b9d:	89 ca                	mov    %ecx,%edx
  801b9f:	89 f8                	mov    %edi,%eax
  801ba1:	75 3d                	jne    801be0 <__udivdi3+0x60>
  801ba3:	39 cf                	cmp    %ecx,%edi
  801ba5:	0f 87 c5 00 00 00    	ja     801c70 <__udivdi3+0xf0>
  801bab:	85 ff                	test   %edi,%edi
  801bad:	89 fd                	mov    %edi,%ebp
  801baf:	75 0b                	jne    801bbc <__udivdi3+0x3c>
  801bb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb6:	31 d2                	xor    %edx,%edx
  801bb8:	f7 f7                	div    %edi
  801bba:	89 c5                	mov    %eax,%ebp
  801bbc:	89 c8                	mov    %ecx,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f5                	div    %ebp
  801bc2:	89 c1                	mov    %eax,%ecx
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	89 cf                	mov    %ecx,%edi
  801bc8:	f7 f5                	div    %ebp
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	89 d8                	mov    %ebx,%eax
  801bce:	89 fa                	mov    %edi,%edx
  801bd0:	83 c4 1c             	add    $0x1c,%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
  801bd8:	90                   	nop
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	39 ce                	cmp    %ecx,%esi
  801be2:	77 74                	ja     801c58 <__udivdi3+0xd8>
  801be4:	0f bd fe             	bsr    %esi,%edi
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	0f 84 98 00 00 00    	je     801c88 <__udivdi3+0x108>
  801bf0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	89 c5                	mov    %eax,%ebp
  801bf9:	29 fb                	sub    %edi,%ebx
  801bfb:	d3 e6                	shl    %cl,%esi
  801bfd:	89 d9                	mov    %ebx,%ecx
  801bff:	d3 ed                	shr    %cl,%ebp
  801c01:	89 f9                	mov    %edi,%ecx
  801c03:	d3 e0                	shl    %cl,%eax
  801c05:	09 ee                	or     %ebp,%esi
  801c07:	89 d9                	mov    %ebx,%ecx
  801c09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0d:	89 d5                	mov    %edx,%ebp
  801c0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c13:	d3 ed                	shr    %cl,%ebp
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e2                	shl    %cl,%edx
  801c19:	89 d9                	mov    %ebx,%ecx
  801c1b:	d3 e8                	shr    %cl,%eax
  801c1d:	09 c2                	or     %eax,%edx
  801c1f:	89 d0                	mov    %edx,%eax
  801c21:	89 ea                	mov    %ebp,%edx
  801c23:	f7 f6                	div    %esi
  801c25:	89 d5                	mov    %edx,%ebp
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	f7 64 24 0c          	mull   0xc(%esp)
  801c2d:	39 d5                	cmp    %edx,%ebp
  801c2f:	72 10                	jb     801c41 <__udivdi3+0xc1>
  801c31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e6                	shl    %cl,%esi
  801c39:	39 c6                	cmp    %eax,%esi
  801c3b:	73 07                	jae    801c44 <__udivdi3+0xc4>
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	75 03                	jne    801c44 <__udivdi3+0xc4>
  801c41:	83 eb 01             	sub    $0x1,%ebx
  801c44:	31 ff                	xor    %edi,%edi
  801c46:	89 d8                	mov    %ebx,%eax
  801c48:	89 fa                	mov    %edi,%edx
  801c4a:	83 c4 1c             	add    $0x1c,%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    
  801c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c58:	31 ff                	xor    %edi,%edi
  801c5a:	31 db                	xor    %ebx,%ebx
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
  801c68:	90                   	nop
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	f7 f7                	div    %edi
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	89 d8                	mov    %ebx,%eax
  801c7a:	89 fa                	mov    %edi,%edx
  801c7c:	83 c4 1c             	add    $0x1c,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    
  801c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c88:	39 ce                	cmp    %ecx,%esi
  801c8a:	72 0c                	jb     801c98 <__udivdi3+0x118>
  801c8c:	31 db                	xor    %ebx,%ebx
  801c8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c92:	0f 87 34 ff ff ff    	ja     801bcc <__udivdi3+0x4c>
  801c98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c9d:	e9 2a ff ff ff       	jmp    801bcc <__udivdi3+0x4c>
  801ca2:	66 90                	xchg   %ax,%ax
  801ca4:	66 90                	xchg   %ax,%ax
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 d2                	test   %edx,%edx
  801cc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cd1:	89 f3                	mov    %esi,%ebx
  801cd3:	89 3c 24             	mov    %edi,(%esp)
  801cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cda:	75 1c                	jne    801cf8 <__umoddi3+0x48>
  801cdc:	39 f7                	cmp    %esi,%edi
  801cde:	76 50                	jbe    801d30 <__umoddi3+0x80>
  801ce0:	89 c8                	mov    %ecx,%eax
  801ce2:	89 f2                	mov    %esi,%edx
  801ce4:	f7 f7                	div    %edi
  801ce6:	89 d0                	mov    %edx,%eax
  801ce8:	31 d2                	xor    %edx,%edx
  801cea:	83 c4 1c             	add    $0x1c,%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    
  801cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf8:	39 f2                	cmp    %esi,%edx
  801cfa:	89 d0                	mov    %edx,%eax
  801cfc:	77 52                	ja     801d50 <__umoddi3+0xa0>
  801cfe:	0f bd ea             	bsr    %edx,%ebp
  801d01:	83 f5 1f             	xor    $0x1f,%ebp
  801d04:	75 5a                	jne    801d60 <__umoddi3+0xb0>
  801d06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d0a:	0f 82 e0 00 00 00    	jb     801df0 <__umoddi3+0x140>
  801d10:	39 0c 24             	cmp    %ecx,(%esp)
  801d13:	0f 86 d7 00 00 00    	jbe    801df0 <__umoddi3+0x140>
  801d19:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d21:	83 c4 1c             	add    $0x1c,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	85 ff                	test   %edi,%edi
  801d32:	89 fd                	mov    %edi,%ebp
  801d34:	75 0b                	jne    801d41 <__umoddi3+0x91>
  801d36:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	f7 f7                	div    %edi
  801d3f:	89 c5                	mov    %eax,%ebp
  801d41:	89 f0                	mov    %esi,%eax
  801d43:	31 d2                	xor    %edx,%edx
  801d45:	f7 f5                	div    %ebp
  801d47:	89 c8                	mov    %ecx,%eax
  801d49:	f7 f5                	div    %ebp
  801d4b:	89 d0                	mov    %edx,%eax
  801d4d:	eb 99                	jmp    801ce8 <__umoddi3+0x38>
  801d4f:	90                   	nop
  801d50:	89 c8                	mov    %ecx,%eax
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	83 c4 1c             	add    $0x1c,%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    
  801d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d60:	8b 34 24             	mov    (%esp),%esi
  801d63:	bf 20 00 00 00       	mov    $0x20,%edi
  801d68:	89 e9                	mov    %ebp,%ecx
  801d6a:	29 ef                	sub    %ebp,%edi
  801d6c:	d3 e0                	shl    %cl,%eax
  801d6e:	89 f9                	mov    %edi,%ecx
  801d70:	89 f2                	mov    %esi,%edx
  801d72:	d3 ea                	shr    %cl,%edx
  801d74:	89 e9                	mov    %ebp,%ecx
  801d76:	09 c2                	or     %eax,%edx
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	89 14 24             	mov    %edx,(%esp)
  801d7d:	89 f2                	mov    %esi,%edx
  801d7f:	d3 e2                	shl    %cl,%edx
  801d81:	89 f9                	mov    %edi,%ecx
  801d83:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d8b:	d3 e8                	shr    %cl,%eax
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	89 c6                	mov    %eax,%esi
  801d91:	d3 e3                	shl    %cl,%ebx
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 d0                	mov    %edx,%eax
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	09 d8                	or     %ebx,%eax
  801d9d:	89 d3                	mov    %edx,%ebx
  801d9f:	89 f2                	mov    %esi,%edx
  801da1:	f7 34 24             	divl   (%esp)
  801da4:	89 d6                	mov    %edx,%esi
  801da6:	d3 e3                	shl    %cl,%ebx
  801da8:	f7 64 24 04          	mull   0x4(%esp)
  801dac:	39 d6                	cmp    %edx,%esi
  801dae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801db2:	89 d1                	mov    %edx,%ecx
  801db4:	89 c3                	mov    %eax,%ebx
  801db6:	72 08                	jb     801dc0 <__umoddi3+0x110>
  801db8:	75 11                	jne    801dcb <__umoddi3+0x11b>
  801dba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dbe:	73 0b                	jae    801dcb <__umoddi3+0x11b>
  801dc0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dc4:	1b 14 24             	sbb    (%esp),%edx
  801dc7:	89 d1                	mov    %edx,%ecx
  801dc9:	89 c3                	mov    %eax,%ebx
  801dcb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dcf:	29 da                	sub    %ebx,%edx
  801dd1:	19 ce                	sbb    %ecx,%esi
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 f0                	mov    %esi,%eax
  801dd7:	d3 e0                	shl    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	d3 ea                	shr    %cl,%edx
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	d3 ee                	shr    %cl,%esi
  801de1:	09 d0                	or     %edx,%eax
  801de3:	89 f2                	mov    %esi,%edx
  801de5:	83 c4 1c             	add    $0x1c,%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    
  801ded:	8d 76 00             	lea    0x0(%esi),%esi
  801df0:	29 f9                	sub    %edi,%ecx
  801df2:	19 d6                	sbb    %edx,%esi
  801df4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dfc:	e9 18 ff ff ff       	jmp    801d19 <__umoddi3+0x69>
