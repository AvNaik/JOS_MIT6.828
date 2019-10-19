
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 87 04 00 00       	call   800511 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 ea 1d 80 00       	push   $0x801dea
  800103:	6a 23                	push   $0x23
  800105:	68 07 1e 80 00       	push   $0x801e07
  80010a:	e8 6a 0f 00 00       	call   801079 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 ea 1d 80 00       	push   $0x801dea
  800184:	6a 23                	push   $0x23
  800186:	68 07 1e 80 00       	push   $0x801e07
  80018b:	e8 e9 0e 00 00       	call   801079 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 ea 1d 80 00       	push   $0x801dea
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 07 1e 80 00       	push   $0x801e07
  8001cd:	e8 a7 0e 00 00       	call   801079 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 ea 1d 80 00       	push   $0x801dea
  800208:	6a 23                	push   $0x23
  80020a:	68 07 1e 80 00       	push   $0x801e07
  80020f:	e8 65 0e 00 00       	call   801079 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 ea 1d 80 00       	push   $0x801dea
  80024a:	6a 23                	push   $0x23
  80024c:	68 07 1e 80 00       	push   $0x801e07
  800251:	e8 23 0e 00 00       	call   801079 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 ea 1d 80 00       	push   $0x801dea
  80028c:	6a 23                	push   $0x23
  80028e:	68 07 1e 80 00       	push   $0x801e07
  800293:	e8 e1 0d 00 00       	call   801079 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 ea 1d 80 00       	push   $0x801dea
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 07 1e 80 00       	push   $0x801e07
  8002d5:	e8 9f 0d 00 00       	call   801079 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 ea 1d 80 00       	push   $0x801dea
  800332:	6a 23                	push   $0x23
  800334:	68 07 1e 80 00       	push   $0x801e07
  800339:	e8 3b 0d 00 00       	call   801079 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	05 00 00 00 30       	add    $0x30000000,%eax
  800351:	c1 e8 0c             	shr    $0xc,%eax
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	05 00 00 00 30       	add    $0x30000000,%eax
  800361:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800366:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 11                	je     80039a <fd_alloc+0x2d>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	75 09                	jne    8003a3 <fd_alloc+0x36>
			*fd_store = fd;
  80039a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039c:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a1:	eb 17                	jmp    8003ba <fd_alloc+0x4d>
  8003a3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ad:	75 c9                	jne    800378 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c2:	83 f8 1f             	cmp    $0x1f,%eax
  8003c5:	77 36                	ja     8003fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
  8003ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 16             	shr    $0x16,%edx
  8003d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x48>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	eb 13                	jmp    800410 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb 0c                	jmp    800410 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb 05                	jmp    800410 <fd_lookup+0x54>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800420:	eb 13                	jmp    800435 <dev_lookup+0x23>
  800422:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 08                	cmp    %ecx,(%eax)
  800427:	75 0c                	jne    800435 <dev_lookup+0x23>
			*dev = devtab[i];
  800429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	eb 2e                	jmp    800463 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	85 c0                	test   %eax,%eax
  800439:	75 e7                	jne    800422 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043b:	a1 04 40 80 00       	mov    0x804004,%eax
  800440:	8b 40 48             	mov    0x48(%eax),%eax
  800443:	83 ec 04             	sub    $0x4,%esp
  800446:	51                   	push   %ecx
  800447:	50                   	push   %eax
  800448:	68 18 1e 80 00       	push   $0x801e18
  80044d:	e8 00 0d 00 00       	call   801152 <cprintf>
	*dev = 0;
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
  800455:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 10             	sub    $0x10,%esp
  80046d:	8b 75 08             	mov    0x8(%ebp),%esi
  800470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800476:	50                   	push   %eax
  800477:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047d:	c1 e8 0c             	shr    $0xc,%eax
  800480:	50                   	push   %eax
  800481:	e8 36 ff ff ff       	call   8003bc <fd_lookup>
  800486:	83 c4 08             	add    $0x8,%esp
  800489:	85 c0                	test   %eax,%eax
  80048b:	78 05                	js     800492 <fd_close+0x2d>
	    || fd != fd2)
  80048d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800490:	74 0c                	je     80049e <fd_close+0x39>
		return (must_exist ? r : 0);
  800492:	84 db                	test   %bl,%bl
  800494:	ba 00 00 00 00       	mov    $0x0,%edx
  800499:	0f 44 c2             	cmove  %edx,%eax
  80049c:	eb 41                	jmp    8004df <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a4:	50                   	push   %eax
  8004a5:	ff 36                	pushl  (%esi)
  8004a7:	e8 66 ff ff ff       	call   800412 <dev_lookup>
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 1a                	js     8004cf <fd_close+0x6a>
		if (dev->dev_close)
  8004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	74 0b                	je     8004cf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c4:	83 ec 0c             	sub    $0xc,%esp
  8004c7:	56                   	push   %esi
  8004c8:	ff d0                	call   *%eax
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	56                   	push   %esi
  8004d3:	6a 00                	push   $0x0
  8004d5:	e8 00 fd ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	89 d8                	mov    %ebx,%eax
}
  8004df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e2:	5b                   	pop    %ebx
  8004e3:	5e                   	pop    %esi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 c4 fe ff ff       	call   8003bc <fd_lookup>
  8004f8:	83 c4 08             	add    $0x8,%esp
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	78 10                	js     80050f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	6a 01                	push   $0x1
  800504:	ff 75 f4             	pushl  -0xc(%ebp)
  800507:	e8 59 ff ff ff       	call   800465 <fd_close>
  80050c:	83 c4 10             	add    $0x10,%esp
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <close_all>:

void
close_all(void)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	53                   	push   %ebx
  800515:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800518:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	53                   	push   %ebx
  800521:	e8 c0 ff ff ff       	call   8004e6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	83 c3 01             	add    $0x1,%ebx
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	83 fb 20             	cmp    $0x20,%ebx
  80052f:	75 ec                	jne    80051d <close_all+0xc>
		close(i);
}
  800531:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800534:	c9                   	leave  
  800535:	c3                   	ret    

00800536 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	57                   	push   %edi
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
  80053c:	83 ec 2c             	sub    $0x2c,%esp
  80053f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800542:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800545:	50                   	push   %eax
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 6e fe ff ff       	call   8003bc <fd_lookup>
  80054e:	83 c4 08             	add    $0x8,%esp
  800551:	85 c0                	test   %eax,%eax
  800553:	0f 88 c1 00 00 00    	js     80061a <dup+0xe4>
		return r;
	close(newfdnum);
  800559:	83 ec 0c             	sub    $0xc,%esp
  80055c:	56                   	push   %esi
  80055d:	e8 84 ff ff ff       	call   8004e6 <close>

	newfd = INDEX2FD(newfdnum);
  800562:	89 f3                	mov    %esi,%ebx
  800564:	c1 e3 0c             	shl    $0xc,%ebx
  800567:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056d:	83 c4 04             	add    $0x4,%esp
  800570:	ff 75 e4             	pushl  -0x1c(%ebp)
  800573:	e8 de fd ff ff       	call   800356 <fd2data>
  800578:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057a:	89 1c 24             	mov    %ebx,(%esp)
  80057d:	e8 d4 fd ff ff       	call   800356 <fd2data>
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800588:	89 f8                	mov    %edi,%eax
  80058a:	c1 e8 16             	shr    $0x16,%eax
  80058d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800594:	a8 01                	test   $0x1,%al
  800596:	74 37                	je     8005cf <dup+0x99>
  800598:	89 f8                	mov    %edi,%eax
  80059a:	c1 e8 0c             	shr    $0xc,%eax
  80059d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a4:	f6 c2 01             	test   $0x1,%dl
  8005a7:	74 26                	je     8005cf <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b0:	83 ec 0c             	sub    $0xc,%esp
  8005b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b8:	50                   	push   %eax
  8005b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bc:	6a 00                	push   $0x0
  8005be:	57                   	push   %edi
  8005bf:	6a 00                	push   $0x0
  8005c1:	e8 d2 fb ff ff       	call   800198 <sys_page_map>
  8005c6:	89 c7                	mov    %eax,%edi
  8005c8:	83 c4 20             	add    $0x20,%esp
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	78 2e                	js     8005fd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d2:	89 d0                	mov    %edx,%eax
  8005d4:	c1 e8 0c             	shr    $0xc,%eax
  8005d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e6:	50                   	push   %eax
  8005e7:	53                   	push   %ebx
  8005e8:	6a 00                	push   $0x0
  8005ea:	52                   	push   %edx
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 a6 fb ff ff       	call   800198 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f9:	85 ff                	test   %edi,%edi
  8005fb:	79 1d                	jns    80061a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 00                	push   $0x0
  800603:	e8 d2 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800608:	83 c4 08             	add    $0x8,%esp
  80060b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060e:	6a 00                	push   $0x0
  800610:	e8 c5 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	89 f8                	mov    %edi,%eax
}
  80061a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061d:	5b                   	pop    %ebx
  80061e:	5e                   	pop    %esi
  80061f:	5f                   	pop    %edi
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	53                   	push   %ebx
  800626:	83 ec 14             	sub    $0x14,%esp
  800629:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062f:	50                   	push   %eax
  800630:	53                   	push   %ebx
  800631:	e8 86 fd ff ff       	call   8003bc <fd_lookup>
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	89 c2                	mov    %eax,%edx
  80063b:	85 c0                	test   %eax,%eax
  80063d:	78 6d                	js     8006ac <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800645:	50                   	push   %eax
  800646:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800649:	ff 30                	pushl  (%eax)
  80064b:	e8 c2 fd ff ff       	call   800412 <dev_lookup>
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	85 c0                	test   %eax,%eax
  800655:	78 4c                	js     8006a3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800657:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065a:	8b 42 08             	mov    0x8(%edx),%eax
  80065d:	83 e0 03             	and    $0x3,%eax
  800660:	83 f8 01             	cmp    $0x1,%eax
  800663:	75 21                	jne    800686 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800665:	a1 04 40 80 00       	mov    0x804004,%eax
  80066a:	8b 40 48             	mov    0x48(%eax),%eax
  80066d:	83 ec 04             	sub    $0x4,%esp
  800670:	53                   	push   %ebx
  800671:	50                   	push   %eax
  800672:	68 59 1e 80 00       	push   $0x801e59
  800677:	e8 d6 0a 00 00       	call   801152 <cprintf>
		return -E_INVAL;
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800684:	eb 26                	jmp    8006ac <read+0x8a>
	}
	if (!dev->dev_read)
  800686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800689:	8b 40 08             	mov    0x8(%eax),%eax
  80068c:	85 c0                	test   %eax,%eax
  80068e:	74 17                	je     8006a7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800690:	83 ec 04             	sub    $0x4,%esp
  800693:	ff 75 10             	pushl  0x10(%ebp)
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	52                   	push   %edx
  80069a:	ff d0                	call   *%eax
  80069c:	89 c2                	mov    %eax,%edx
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb 09                	jmp    8006ac <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a3:	89 c2                	mov    %eax,%edx
  8006a5:	eb 05                	jmp    8006ac <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ac:	89 d0                	mov    %edx,%eax
  8006ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b1:	c9                   	leave  
  8006b2:	c3                   	ret    

008006b3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	57                   	push   %edi
  8006b7:	56                   	push   %esi
  8006b8:	53                   	push   %ebx
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c7:	eb 21                	jmp    8006ea <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c9:	83 ec 04             	sub    $0x4,%esp
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	29 d8                	sub    %ebx,%eax
  8006d0:	50                   	push   %eax
  8006d1:	89 d8                	mov    %ebx,%eax
  8006d3:	03 45 0c             	add    0xc(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	57                   	push   %edi
  8006d8:	e8 45 ff ff ff       	call   800622 <read>
		if (m < 0)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 10                	js     8006f4 <readn+0x41>
			return m;
		if (m == 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 0a                	je     8006f2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e8:	01 c3                	add    %eax,%ebx
  8006ea:	39 f3                	cmp    %esi,%ebx
  8006ec:	72 db                	jb     8006c9 <readn+0x16>
  8006ee:	89 d8                	mov    %ebx,%eax
  8006f0:	eb 02                	jmp    8006f4 <readn+0x41>
  8006f2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 14             	sub    $0x14,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	53                   	push   %ebx
  80070b:	e8 ac fc ff ff       	call   8003bc <fd_lookup>
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	89 c2                	mov    %eax,%edx
  800715:	85 c0                	test   %eax,%eax
  800717:	78 68                	js     800781 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800723:	ff 30                	pushl  (%eax)
  800725:	e8 e8 fc ff ff       	call   800412 <dev_lookup>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 47                	js     800778 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800738:	75 21                	jne    80075b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073a:	a1 04 40 80 00       	mov    0x804004,%eax
  80073f:	8b 40 48             	mov    0x48(%eax),%eax
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	53                   	push   %ebx
  800746:	50                   	push   %eax
  800747:	68 75 1e 80 00       	push   $0x801e75
  80074c:	e8 01 0a 00 00       	call   801152 <cprintf>
		return -E_INVAL;
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800759:	eb 26                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075e:	8b 52 0c             	mov    0xc(%edx),%edx
  800761:	85 d2                	test   %edx,%edx
  800763:	74 17                	je     80077c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800765:	83 ec 04             	sub    $0x4,%esp
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	50                   	push   %eax
  80076f:	ff d2                	call   *%edx
  800771:	89 c2                	mov    %eax,%edx
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 09                	jmp    800781 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800778:	89 c2                	mov    %eax,%edx
  80077a:	eb 05                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800781:	89 d0                	mov    %edx,%eax
  800783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <seek>:

int
seek(int fdnum, off_t offset)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	ff 75 08             	pushl  0x8(%ebp)
  800795:	e8 22 fc ff ff       	call   8003bc <fd_lookup>
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 0e                	js     8007af <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 14             	sub    $0x14,%esp
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	53                   	push   %ebx
  8007c0:	e8 f7 fb ff ff       	call   8003bc <fd_lookup>
  8007c5:	83 c4 08             	add    $0x8,%esp
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 65                	js     800833 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	ff 30                	pushl  (%eax)
  8007da:	e8 33 fc ff ff       	call   800412 <dev_lookup>
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	78 44                	js     80082a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ed:	75 21                	jne    800810 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007ef:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f4:	8b 40 48             	mov    0x48(%eax),%eax
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	50                   	push   %eax
  8007fc:	68 38 1e 80 00       	push   $0x801e38
  800801:	e8 4c 09 00 00       	call   801152 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080e:	eb 23                	jmp    800833 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800810:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800813:	8b 52 18             	mov    0x18(%edx),%edx
  800816:	85 d2                	test   %edx,%edx
  800818:	74 14                	je     80082e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	50                   	push   %eax
  800821:	ff d2                	call   *%edx
  800823:	89 c2                	mov    %eax,%edx
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	eb 09                	jmp    800833 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	eb 05                	jmp    800833 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800833:	89 d0                	mov    %edx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 6c fb ff ff       	call   8003bc <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	89 c2                	mov    %eax,%edx
  800855:	85 c0                	test   %eax,%eax
  800857:	78 58                	js     8008b1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085f:	50                   	push   %eax
  800860:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800863:	ff 30                	pushl  (%eax)
  800865:	e8 a8 fb ff ff       	call   800412 <dev_lookup>
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	85 c0                	test   %eax,%eax
  80086f:	78 37                	js     8008a8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800874:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800878:	74 32                	je     8008ac <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800884:	00 00 00 
	stat->st_isdir = 0;
  800887:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088e:	00 00 00 
	stat->st_dev = dev;
  800891:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	ff 75 f0             	pushl  -0x10(%ebp)
  80089e:	ff 50 14             	call   *0x14(%eax)
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 09                	jmp    8008b1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	eb 05                	jmp    8008b1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	6a 00                	push   $0x0
  8008c2:	ff 75 08             	pushl  0x8(%ebp)
  8008c5:	e8 2c 02 00 00       	call   800af6 <open>
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	78 1b                	js     8008ee <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	ff 75 0c             	pushl  0xc(%ebp)
  8008d9:	50                   	push   %eax
  8008da:	e8 5b ff ff ff       	call   80083a <fstat>
  8008df:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 fd fb ff ff       	call   8004e6 <close>
	return r;
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	89 f0                	mov    %esi,%eax
}
  8008ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	89 c6                	mov    %eax,%esi
  8008fc:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  8008fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800905:	75 12                	jne    800919 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 01                	push   $0x1
  80090c:	e8 c0 11 00 00       	call   801ad1 <ipc_find_env>
  800911:	a3 00 40 80 00       	mov    %eax,0x804000
  800916:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800919:	6a 07                	push   $0x7
  80091b:	68 00 50 80 00       	push   $0x805000
  800920:	56                   	push   %esi
  800921:	ff 35 00 40 80 00    	pushl  0x804000
  800927:	e8 51 11 00 00       	call   801a7d <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  80092c:	83 c4 0c             	add    $0xc,%esp
  80092f:	6a 00                	push   $0x0
  800931:	53                   	push   %ebx
  800932:	6a 00                	push   $0x0
  800934:	e8 e5 10 00 00       	call   801a1e <ipc_recv>
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 40 0c             	mov    0xc(%eax),%eax
  80094c:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	b8 02 00 00 00       	mov    $0x2,%eax
  800963:	e8 8d ff ff ff       	call   8008f5 <fsipc>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 40 0c             	mov    0xc(%eax),%eax
  800976:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  80097b:	ba 00 00 00 00       	mov    $0x0,%edx
  800980:	b8 06 00 00 00       	mov    $0x6,%eax
  800985:	e8 6b ff ff ff       	call   8008f5 <fsipc>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	53                   	push   %ebx
  800990:	83 ec 04             	sub    $0x4,%esp
  800993:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ab:	e8 45 ff ff ff       	call   8008f5 <fsipc>
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	78 2c                	js     8009e0 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b4:	83 ec 08             	sub    $0x8,%esp
  8009b7:	68 00 50 80 00       	push   $0x805000
  8009bc:	53                   	push   %ebx
  8009bd:	e8 15 0d 00 00       	call   8016d7 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8009c2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009cd:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	53                   	push   %ebx
  8009e9:	83 ec 08             	sub    $0x8,%esp
  8009ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f5:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  8009fa:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  800a00:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a06:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800a0b:	0f 46 c3             	cmovbe %ebx,%eax
  800a0e:	50                   	push   %eax
  800a0f:	ff 75 0c             	pushl  0xc(%ebp)
  800a12:	68 08 50 80 00       	push   $0x805008
  800a17:	e8 4d 0e 00 00       	call   801869 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  800a1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a21:	b8 04 00 00 00       	mov    $0x4,%eax
  800a26:	e8 ca fe ff ff       	call   8008f5 <fsipc>
  800a2b:	83 c4 10             	add    $0x10,%esp
  800a2e:	85 c0                	test   %eax,%eax
  800a30:	78 3d                	js     800a6f <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  800a32:	39 c3                	cmp    %eax,%ebx
  800a34:	73 19                	jae    800a4f <devfile_write+0x6a>
  800a36:	68 a4 1e 80 00       	push   $0x801ea4
  800a3b:	68 ab 1e 80 00       	push   $0x801eab
  800a40:	68 9a 00 00 00       	push   $0x9a
  800a45:	68 c0 1e 80 00       	push   $0x801ec0
  800a4a:	e8 2a 06 00 00       	call   801079 <_panic>
	   assert (r <= bytes_written);
  800a4f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a54:	7e 19                	jle    800a6f <devfile_write+0x8a>
  800a56:	68 cb 1e 80 00       	push   $0x801ecb
  800a5b:	68 ab 1e 80 00       	push   $0x801eab
  800a60:	68 9b 00 00 00       	push   $0x9b
  800a65:	68 c0 1e 80 00       	push   $0x801ec0
  800a6a:	e8 0a 06 00 00       	call   801079 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  800a6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a82:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  800a87:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	b8 03 00 00 00       	mov    $0x3,%eax
  800a97:	e8 59 fe ff ff       	call   8008f5 <fsipc>
  800a9c:	89 c3                	mov    %eax,%ebx
  800a9e:	85 c0                	test   %eax,%eax
  800aa0:	78 4b                	js     800aed <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  800aa2:	39 c6                	cmp    %eax,%esi
  800aa4:	73 16                	jae    800abc <devfile_read+0x48>
  800aa6:	68 a4 1e 80 00       	push   $0x801ea4
  800aab:	68 ab 1e 80 00       	push   $0x801eab
  800ab0:	6a 7c                	push   $0x7c
  800ab2:	68 c0 1e 80 00       	push   $0x801ec0
  800ab7:	e8 bd 05 00 00       	call   801079 <_panic>
	   assert(r <= PGSIZE);
  800abc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac1:	7e 16                	jle    800ad9 <devfile_read+0x65>
  800ac3:	68 de 1e 80 00       	push   $0x801ede
  800ac8:	68 ab 1e 80 00       	push   $0x801eab
  800acd:	6a 7d                	push   $0x7d
  800acf:	68 c0 1e 80 00       	push   $0x801ec0
  800ad4:	e8 a0 05 00 00       	call   801079 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad9:	83 ec 04             	sub    $0x4,%esp
  800adc:	50                   	push   %eax
  800add:	68 00 50 80 00       	push   $0x805000
  800ae2:	ff 75 0c             	pushl  0xc(%ebp)
  800ae5:	e8 7f 0d 00 00       	call   801869 <memmove>
	   return r;
  800aea:	83 c4 10             	add    $0x10,%esp
}
  800aed:	89 d8                	mov    %ebx,%eax
  800aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	53                   	push   %ebx
  800afa:	83 ec 20             	sub    $0x20,%esp
  800afd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  800b00:	53                   	push   %ebx
  800b01:	e8 98 0b 00 00       	call   80169e <strlen>
  800b06:	83 c4 10             	add    $0x10,%esp
  800b09:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b0e:	7f 67                	jg     800b77 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b10:	83 ec 0c             	sub    $0xc,%esp
  800b13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b16:	50                   	push   %eax
  800b17:	e8 51 f8 ff ff       	call   80036d <fd_alloc>
  800b1c:	83 c4 10             	add    $0x10,%esp
			 return r;
  800b1f:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b21:	85 c0                	test   %eax,%eax
  800b23:	78 57                	js     800b7c <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  800b25:	83 ec 08             	sub    $0x8,%esp
  800b28:	53                   	push   %ebx
  800b29:	68 00 50 80 00       	push   $0x805000
  800b2e:	e8 a4 0b 00 00       	call   8016d7 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b43:	e8 ad fd ff ff       	call   8008f5 <fsipc>
  800b48:	89 c3                	mov    %eax,%ebx
  800b4a:	83 c4 10             	add    $0x10,%esp
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	79 14                	jns    800b65 <open+0x6f>
			 fd_close(fd, 0);
  800b51:	83 ec 08             	sub    $0x8,%esp
  800b54:	6a 00                	push   $0x0
  800b56:	ff 75 f4             	pushl  -0xc(%ebp)
  800b59:	e8 07 f9 ff ff       	call   800465 <fd_close>
			 return r;
  800b5e:	83 c4 10             	add    $0x10,%esp
  800b61:	89 da                	mov    %ebx,%edx
  800b63:	eb 17                	jmp    800b7c <open+0x86>
	   }

	   return fd2num(fd);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6b:	e8 d6 f7 ff ff       	call   800346 <fd2num>
  800b70:	89 c2                	mov    %eax,%edx
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb 05                	jmp    800b7c <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  800b77:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  800b7c:	89 d0                	mov    %edx,%eax
  800b7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b93:	e8 5d fd ff ff       	call   8008f5 <fsipc>
}
  800b98:	c9                   	leave  
  800b99:	c3                   	ret    

00800b9a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	ff 75 08             	pushl  0x8(%ebp)
  800ba8:	e8 a9 f7 ff ff       	call   800356 <fd2data>
  800bad:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800baf:	83 c4 08             	add    $0x8,%esp
  800bb2:	68 ea 1e 80 00       	push   $0x801eea
  800bb7:	53                   	push   %ebx
  800bb8:	e8 1a 0b 00 00       	call   8016d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bbd:	8b 46 04             	mov    0x4(%esi),%eax
  800bc0:	2b 06                	sub    (%esi),%eax
  800bc2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bc8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bcf:	00 00 00 
	stat->st_dev = &devpipe;
  800bd2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bd9:	30 80 00 
	return 0;
}
  800bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800be1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	53                   	push   %ebx
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf2:	53                   	push   %ebx
  800bf3:	6a 00                	push   $0x0
  800bf5:	e8 e0 f5 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bfa:	89 1c 24             	mov    %ebx,(%esp)
  800bfd:	e8 54 f7 ff ff       	call   800356 <fd2data>
  800c02:	83 c4 08             	add    $0x8,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 00                	push   $0x0
  800c08:	e8 cd f5 ff ff       	call   8001da <sys_page_unmap>
}
  800c0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 1c             	sub    $0x1c,%esp
  800c1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c1e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c20:	a1 04 40 80 00       	mov    0x804004,%eax
  800c25:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	ff 75 e0             	pushl  -0x20(%ebp)
  800c2e:	e8 d7 0e 00 00       	call   801b0a <pageref>
  800c33:	89 c3                	mov    %eax,%ebx
  800c35:	89 3c 24             	mov    %edi,(%esp)
  800c38:	e8 cd 0e 00 00       	call   801b0a <pageref>
  800c3d:	83 c4 10             	add    $0x10,%esp
  800c40:	39 c3                	cmp    %eax,%ebx
  800c42:	0f 94 c1             	sete   %cl
  800c45:	0f b6 c9             	movzbl %cl,%ecx
  800c48:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c4b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c51:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c54:	39 ce                	cmp    %ecx,%esi
  800c56:	74 1b                	je     800c73 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c58:	39 c3                	cmp    %eax,%ebx
  800c5a:	75 c4                	jne    800c20 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c5c:	8b 42 58             	mov    0x58(%edx),%eax
  800c5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c62:	50                   	push   %eax
  800c63:	56                   	push   %esi
  800c64:	68 f1 1e 80 00       	push   $0x801ef1
  800c69:	e8 e4 04 00 00       	call   801152 <cprintf>
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	eb ad                	jmp    800c20 <_pipeisclosed+0xe>
	}
}
  800c73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 28             	sub    $0x28,%esp
  800c87:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c8a:	56                   	push   %esi
  800c8b:	e8 c6 f6 ff ff       	call   800356 <fd2data>
  800c90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9a:	eb 4b                	jmp    800ce7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c9c:	89 da                	mov    %ebx,%edx
  800c9e:	89 f0                	mov    %esi,%eax
  800ca0:	e8 6d ff ff ff       	call   800c12 <_pipeisclosed>
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	75 48                	jne    800cf1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ca9:	e8 88 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cae:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb1:	8b 0b                	mov    (%ebx),%ecx
  800cb3:	8d 51 20             	lea    0x20(%ecx),%edx
  800cb6:	39 d0                	cmp    %edx,%eax
  800cb8:	73 e2                	jae    800c9c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cc1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cc4:	89 c2                	mov    %eax,%edx
  800cc6:	c1 fa 1f             	sar    $0x1f,%edx
  800cc9:	89 d1                	mov    %edx,%ecx
  800ccb:	c1 e9 1b             	shr    $0x1b,%ecx
  800cce:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cd1:	83 e2 1f             	and    $0x1f,%edx
  800cd4:	29 ca                	sub    %ecx,%edx
  800cd6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cda:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cde:	83 c0 01             	add    $0x1,%eax
  800ce1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce4:	83 c7 01             	add    $0x1,%edi
  800ce7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cea:	75 c2                	jne    800cae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cec:	8b 45 10             	mov    0x10(%ebp),%eax
  800cef:	eb 05                	jmp    800cf6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 18             	sub    $0x18,%esp
  800d07:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d0a:	57                   	push   %edi
  800d0b:	e8 46 f6 ff ff       	call   800356 <fd2data>
  800d10:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d12:	83 c4 10             	add    $0x10,%esp
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	eb 3d                	jmp    800d59 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d1c:	85 db                	test   %ebx,%ebx
  800d1e:	74 04                	je     800d24 <devpipe_read+0x26>
				return i;
  800d20:	89 d8                	mov    %ebx,%eax
  800d22:	eb 44                	jmp    800d68 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d24:	89 f2                	mov    %esi,%edx
  800d26:	89 f8                	mov    %edi,%eax
  800d28:	e8 e5 fe ff ff       	call   800c12 <_pipeisclosed>
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	75 32                	jne    800d63 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d31:	e8 00 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d36:	8b 06                	mov    (%esi),%eax
  800d38:	3b 46 04             	cmp    0x4(%esi),%eax
  800d3b:	74 df                	je     800d1c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d3d:	99                   	cltd   
  800d3e:	c1 ea 1b             	shr    $0x1b,%edx
  800d41:	01 d0                	add    %edx,%eax
  800d43:	83 e0 1f             	and    $0x1f,%eax
  800d46:	29 d0                	sub    %edx,%eax
  800d48:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d53:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d56:	83 c3 01             	add    $0x1,%ebx
  800d59:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d5c:	75 d8                	jne    800d36 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d61:	eb 05                	jmp    800d68 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d63:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d7b:	50                   	push   %eax
  800d7c:	e8 ec f5 ff ff       	call   80036d <fd_alloc>
  800d81:	83 c4 10             	add    $0x10,%esp
  800d84:	89 c2                	mov    %eax,%edx
  800d86:	85 c0                	test   %eax,%eax
  800d88:	0f 88 2c 01 00 00    	js     800eba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8e:	83 ec 04             	sub    $0x4,%esp
  800d91:	68 07 04 00 00       	push   $0x407
  800d96:	ff 75 f4             	pushl  -0xc(%ebp)
  800d99:	6a 00                	push   $0x0
  800d9b:	e8 b5 f3 ff ff       	call   800155 <sys_page_alloc>
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	89 c2                	mov    %eax,%edx
  800da5:	85 c0                	test   %eax,%eax
  800da7:	0f 88 0d 01 00 00    	js     800eba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db3:	50                   	push   %eax
  800db4:	e8 b4 f5 ff ff       	call   80036d <fd_alloc>
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	0f 88 e2 00 00 00    	js     800ea8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc6:	83 ec 04             	sub    $0x4,%esp
  800dc9:	68 07 04 00 00       	push   $0x407
  800dce:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd1:	6a 00                	push   $0x0
  800dd3:	e8 7d f3 ff ff       	call   800155 <sys_page_alloc>
  800dd8:	89 c3                	mov    %eax,%ebx
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	0f 88 c3 00 00 00    	js     800ea8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800de5:	83 ec 0c             	sub    $0xc,%esp
  800de8:	ff 75 f4             	pushl  -0xc(%ebp)
  800deb:	e8 66 f5 ff ff       	call   800356 <fd2data>
  800df0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 c4 0c             	add    $0xc,%esp
  800df5:	68 07 04 00 00       	push   $0x407
  800dfa:	50                   	push   %eax
  800dfb:	6a 00                	push   $0x0
  800dfd:	e8 53 f3 ff ff       	call   800155 <sys_page_alloc>
  800e02:	89 c3                	mov    %eax,%ebx
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	85 c0                	test   %eax,%eax
  800e09:	0f 88 89 00 00 00    	js     800e98 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e0f:	83 ec 0c             	sub    $0xc,%esp
  800e12:	ff 75 f0             	pushl  -0x10(%ebp)
  800e15:	e8 3c f5 ff ff       	call   800356 <fd2data>
  800e1a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e21:	50                   	push   %eax
  800e22:	6a 00                	push   $0x0
  800e24:	56                   	push   %esi
  800e25:	6a 00                	push   $0x0
  800e27:	e8 6c f3 ff ff       	call   800198 <sys_page_map>
  800e2c:	89 c3                	mov    %eax,%ebx
  800e2e:	83 c4 20             	add    $0x20,%esp
  800e31:	85 c0                	test   %eax,%eax
  800e33:	78 55                	js     800e8a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e35:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e43:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e4a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e53:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e58:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	ff 75 f4             	pushl  -0xc(%ebp)
  800e65:	e8 dc f4 ff ff       	call   800346 <fd2num>
  800e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e6f:	83 c4 04             	add    $0x4,%esp
  800e72:	ff 75 f0             	pushl  -0x10(%ebp)
  800e75:	e8 cc f4 ff ff       	call   800346 <fd2num>
  800e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	ba 00 00 00 00       	mov    $0x0,%edx
  800e88:	eb 30                	jmp    800eba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e8a:	83 ec 08             	sub    $0x8,%esp
  800e8d:	56                   	push   %esi
  800e8e:	6a 00                	push   $0x0
  800e90:	e8 45 f3 ff ff       	call   8001da <sys_page_unmap>
  800e95:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e9e:	6a 00                	push   $0x0
  800ea0:	e8 35 f3 ff ff       	call   8001da <sys_page_unmap>
  800ea5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	ff 75 f4             	pushl  -0xc(%ebp)
  800eae:	6a 00                	push   $0x0
  800eb0:	e8 25 f3 ff ff       	call   8001da <sys_page_unmap>
  800eb5:	83 c4 10             	add    $0x10,%esp
  800eb8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eba:	89 d0                	mov    %edx,%eax
  800ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ecc:	50                   	push   %eax
  800ecd:	ff 75 08             	pushl  0x8(%ebp)
  800ed0:	e8 e7 f4 ff ff       	call   8003bc <fd_lookup>
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	78 18                	js     800ef4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee2:	e8 6f f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800ee7:	89 c2                	mov    %eax,%edx
  800ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eec:	e8 21 fd ff ff       	call   800c12 <_pipeisclosed>
  800ef1:	83 c4 10             	add    $0x10,%esp
}
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f06:	68 09 1f 80 00       	push   $0x801f09
  800f0b:	ff 75 0c             	pushl  0xc(%ebp)
  800f0e:	e8 c4 07 00 00       	call   8016d7 <strcpy>
	return 0;
}
  800f13:	b8 00 00 00 00       	mov    $0x0,%eax
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f26:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f31:	eb 2d                	jmp    800f60 <devcons_write+0x46>
		m = n - tot;
  800f33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f36:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f38:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f3b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f40:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	53                   	push   %ebx
  800f47:	03 45 0c             	add    0xc(%ebp),%eax
  800f4a:	50                   	push   %eax
  800f4b:	57                   	push   %edi
  800f4c:	e8 18 09 00 00       	call   801869 <memmove>
		sys_cputs(buf, m);
  800f51:	83 c4 08             	add    $0x8,%esp
  800f54:	53                   	push   %ebx
  800f55:	57                   	push   %edi
  800f56:	e8 3e f1 ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f5b:	01 de                	add    %ebx,%esi
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	89 f0                	mov    %esi,%eax
  800f62:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f65:	72 cc                	jb     800f33 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6a:	5b                   	pop    %ebx
  800f6b:	5e                   	pop    %esi
  800f6c:	5f                   	pop    %edi
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f7e:	74 2a                	je     800faa <devcons_read+0x3b>
  800f80:	eb 05                	jmp    800f87 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f82:	e8 af f1 ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f87:	e8 2b f1 ff ff       	call   8000b7 <sys_cgetc>
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	74 f2                	je     800f82 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 16                	js     800faa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f94:	83 f8 04             	cmp    $0x4,%eax
  800f97:	74 0c                	je     800fa5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9c:	88 02                	mov    %al,(%edx)
	return 1;
  800f9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa3:	eb 05                	jmp    800faa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fa5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fb8:	6a 01                	push   $0x1
  800fba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbd:	50                   	push   %eax
  800fbe:	e8 d6 f0 ff ff       	call   800099 <sys_cputs>
}
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	c9                   	leave  
  800fc7:	c3                   	ret    

00800fc8 <getchar>:

int
getchar(void)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fce:	6a 01                	push   $0x1
  800fd0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd3:	50                   	push   %eax
  800fd4:	6a 00                	push   $0x0
  800fd6:	e8 47 f6 ff ff       	call   800622 <read>
	if (r < 0)
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 0f                	js     800ff1 <getchar+0x29>
		return r;
	if (r < 1)
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	7e 06                	jle    800fec <getchar+0x24>
		return -E_EOF;
	return c;
  800fe6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fea:	eb 05                	jmp    800ff1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffc:	50                   	push   %eax
  800ffd:	ff 75 08             	pushl  0x8(%ebp)
  801000:	e8 b7 f3 ff ff       	call   8003bc <fd_lookup>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 11                	js     80101d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80100c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801015:	39 10                	cmp    %edx,(%eax)
  801017:	0f 94 c0             	sete   %al
  80101a:	0f b6 c0             	movzbl %al,%eax
}
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <opencons>:

int
opencons(void)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801025:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801028:	50                   	push   %eax
  801029:	e8 3f f3 ff ff       	call   80036d <fd_alloc>
  80102e:	83 c4 10             	add    $0x10,%esp
		return r;
  801031:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801033:	85 c0                	test   %eax,%eax
  801035:	78 3e                	js     801075 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801037:	83 ec 04             	sub    $0x4,%esp
  80103a:	68 07 04 00 00       	push   $0x407
  80103f:	ff 75 f4             	pushl  -0xc(%ebp)
  801042:	6a 00                	push   $0x0
  801044:	e8 0c f1 ff ff       	call   800155 <sys_page_alloc>
  801049:	83 c4 10             	add    $0x10,%esp
		return r;
  80104c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104e:	85 c0                	test   %eax,%eax
  801050:	78 23                	js     801075 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801052:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801058:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80105d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801060:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	50                   	push   %eax
  80106b:	e8 d6 f2 ff ff       	call   800346 <fd2num>
  801070:	89 c2                	mov    %eax,%edx
  801072:	83 c4 10             	add    $0x10,%esp
}
  801075:	89 d0                	mov    %edx,%eax
  801077:	c9                   	leave  
  801078:	c3                   	ret    

00801079 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80107e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801081:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801087:	e8 8b f0 ff ff       	call   800117 <sys_getenvid>
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	ff 75 0c             	pushl  0xc(%ebp)
  801092:	ff 75 08             	pushl  0x8(%ebp)
  801095:	56                   	push   %esi
  801096:	50                   	push   %eax
  801097:	68 18 1f 80 00       	push   $0x801f18
  80109c:	e8 b1 00 00 00       	call   801152 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a1:	83 c4 18             	add    $0x18,%esp
  8010a4:	53                   	push   %ebx
  8010a5:	ff 75 10             	pushl  0x10(%ebp)
  8010a8:	e8 54 00 00 00       	call   801101 <vcprintf>
	cprintf("\n");
  8010ad:	c7 04 24 02 1f 80 00 	movl   $0x801f02,(%esp)
  8010b4:	e8 99 00 00 00       	call   801152 <cprintf>
  8010b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010bc:	cc                   	int3   
  8010bd:	eb fd                	jmp    8010bc <_panic+0x43>

008010bf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	53                   	push   %ebx
  8010c3:	83 ec 04             	sub    $0x4,%esp
  8010c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010c9:	8b 13                	mov    (%ebx),%edx
  8010cb:	8d 42 01             	lea    0x1(%edx),%eax
  8010ce:	89 03                	mov    %eax,(%ebx)
  8010d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010dc:	75 1a                	jne    8010f8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010de:	83 ec 08             	sub    $0x8,%esp
  8010e1:	68 ff 00 00 00       	push   $0xff
  8010e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8010e9:	50                   	push   %eax
  8010ea:	e8 aa ef ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8010ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80110a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801111:	00 00 00 
	b.cnt = 0;
  801114:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80111b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80111e:	ff 75 0c             	pushl  0xc(%ebp)
  801121:	ff 75 08             	pushl  0x8(%ebp)
  801124:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	68 bf 10 80 00       	push   $0x8010bf
  801130:	e8 54 01 00 00       	call   801289 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801135:	83 c4 08             	add    $0x8,%esp
  801138:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80113e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801144:	50                   	push   %eax
  801145:	e8 4f ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  80114a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801150:	c9                   	leave  
  801151:	c3                   	ret    

00801152 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801158:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80115b:	50                   	push   %eax
  80115c:	ff 75 08             	pushl  0x8(%ebp)
  80115f:	e8 9d ff ff ff       	call   801101 <vcprintf>
	va_end(ap);

	return cnt;
}
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	57                   	push   %edi
  80116a:	56                   	push   %esi
  80116b:	53                   	push   %ebx
  80116c:	83 ec 1c             	sub    $0x1c,%esp
  80116f:	89 c7                	mov    %eax,%edi
  801171:	89 d6                	mov    %edx,%esi
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	8b 55 0c             	mov    0xc(%ebp),%edx
  801179:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80117c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80117f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801182:	bb 00 00 00 00       	mov    $0x0,%ebx
  801187:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80118a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80118d:	39 d3                	cmp    %edx,%ebx
  80118f:	72 05                	jb     801196 <printnum+0x30>
  801191:	39 45 10             	cmp    %eax,0x10(%ebp)
  801194:	77 45                	ja     8011db <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	ff 75 18             	pushl  0x18(%ebp)
  80119c:	8b 45 14             	mov    0x14(%ebp),%eax
  80119f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011a2:	53                   	push   %ebx
  8011a3:	ff 75 10             	pushl  0x10(%ebp)
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8011af:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b5:	e8 96 09 00 00       	call   801b50 <__udivdi3>
  8011ba:	83 c4 18             	add    $0x18,%esp
  8011bd:	52                   	push   %edx
  8011be:	50                   	push   %eax
  8011bf:	89 f2                	mov    %esi,%edx
  8011c1:	89 f8                	mov    %edi,%eax
  8011c3:	e8 9e ff ff ff       	call   801166 <printnum>
  8011c8:	83 c4 20             	add    $0x20,%esp
  8011cb:	eb 18                	jmp    8011e5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011cd:	83 ec 08             	sub    $0x8,%esp
  8011d0:	56                   	push   %esi
  8011d1:	ff 75 18             	pushl  0x18(%ebp)
  8011d4:	ff d7                	call   *%edi
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	eb 03                	jmp    8011de <printnum+0x78>
  8011db:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011de:	83 eb 01             	sub    $0x1,%ebx
  8011e1:	85 db                	test   %ebx,%ebx
  8011e3:	7f e8                	jg     8011cd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	56                   	push   %esi
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f8:	e8 83 0a 00 00       	call   801c80 <__umoddi3>
  8011fd:	83 c4 14             	add    $0x14,%esp
  801200:	0f be 80 3b 1f 80 00 	movsbl 0x801f3b(%eax),%eax
  801207:	50                   	push   %eax
  801208:	ff d7                	call   *%edi
}
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801218:	83 fa 01             	cmp    $0x1,%edx
  80121b:	7e 0e                	jle    80122b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80121d:	8b 10                	mov    (%eax),%edx
  80121f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801222:	89 08                	mov    %ecx,(%eax)
  801224:	8b 02                	mov    (%edx),%eax
  801226:	8b 52 04             	mov    0x4(%edx),%edx
  801229:	eb 22                	jmp    80124d <getuint+0x38>
	else if (lflag)
  80122b:	85 d2                	test   %edx,%edx
  80122d:	74 10                	je     80123f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80122f:	8b 10                	mov    (%eax),%edx
  801231:	8d 4a 04             	lea    0x4(%edx),%ecx
  801234:	89 08                	mov    %ecx,(%eax)
  801236:	8b 02                	mov    (%edx),%eax
  801238:	ba 00 00 00 00       	mov    $0x0,%edx
  80123d:	eb 0e                	jmp    80124d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80123f:	8b 10                	mov    (%eax),%edx
  801241:	8d 4a 04             	lea    0x4(%edx),%ecx
  801244:	89 08                	mov    %ecx,(%eax)
  801246:	8b 02                	mov    (%edx),%eax
  801248:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801255:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801259:	8b 10                	mov    (%eax),%edx
  80125b:	3b 50 04             	cmp    0x4(%eax),%edx
  80125e:	73 0a                	jae    80126a <sprintputch+0x1b>
		*b->buf++ = ch;
  801260:	8d 4a 01             	lea    0x1(%edx),%ecx
  801263:	89 08                	mov    %ecx,(%eax)
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	88 02                	mov    %al,(%edx)
}
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801272:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801275:	50                   	push   %eax
  801276:	ff 75 10             	pushl  0x10(%ebp)
  801279:	ff 75 0c             	pushl  0xc(%ebp)
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 05 00 00 00       	call   801289 <vprintfmt>
	va_end(ap);
}
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	57                   	push   %edi
  80128d:	56                   	push   %esi
  80128e:	53                   	push   %ebx
  80128f:	83 ec 2c             	sub    $0x2c,%esp
  801292:	8b 75 08             	mov    0x8(%ebp),%esi
  801295:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801298:	8b 7d 10             	mov    0x10(%ebp),%edi
  80129b:	eb 12                	jmp    8012af <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80129d:	85 c0                	test   %eax,%eax
  80129f:	0f 84 89 03 00 00    	je     80162e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012a5:	83 ec 08             	sub    $0x8,%esp
  8012a8:	53                   	push   %ebx
  8012a9:	50                   	push   %eax
  8012aa:	ff d6                	call   *%esi
  8012ac:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012af:	83 c7 01             	add    $0x1,%edi
  8012b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012b6:	83 f8 25             	cmp    $0x25,%eax
  8012b9:	75 e2                	jne    80129d <vprintfmt+0x14>
  8012bb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012bf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d9:	eb 07                	jmp    8012e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012db:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012de:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e2:	8d 47 01             	lea    0x1(%edi),%eax
  8012e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e8:	0f b6 07             	movzbl (%edi),%eax
  8012eb:	0f b6 c8             	movzbl %al,%ecx
  8012ee:	83 e8 23             	sub    $0x23,%eax
  8012f1:	3c 55                	cmp    $0x55,%al
  8012f3:	0f 87 1a 03 00 00    	ja     801613 <vprintfmt+0x38a>
  8012f9:	0f b6 c0             	movzbl %al,%eax
  8012fc:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  801303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801306:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80130a:	eb d6                	jmp    8012e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80130f:	b8 00 00 00 00       	mov    $0x0,%eax
  801314:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801317:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80131a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80131e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801321:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801324:	83 fa 09             	cmp    $0x9,%edx
  801327:	77 39                	ja     801362 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801329:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80132c:	eb e9                	jmp    801317 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80132e:	8b 45 14             	mov    0x14(%ebp),%eax
  801331:	8d 48 04             	lea    0x4(%eax),%ecx
  801334:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801337:	8b 00                	mov    (%eax),%eax
  801339:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80133f:	eb 27                	jmp    801368 <vprintfmt+0xdf>
  801341:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801344:	85 c0                	test   %eax,%eax
  801346:	b9 00 00 00 00       	mov    $0x0,%ecx
  80134b:	0f 49 c8             	cmovns %eax,%ecx
  80134e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801354:	eb 8c                	jmp    8012e2 <vprintfmt+0x59>
  801356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801359:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801360:	eb 80                	jmp    8012e2 <vprintfmt+0x59>
  801362:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801365:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801368:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80136c:	0f 89 70 ff ff ff    	jns    8012e2 <vprintfmt+0x59>
				width = precision, precision = -1;
  801372:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801375:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801378:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80137f:	e9 5e ff ff ff       	jmp    8012e2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801384:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80138a:	e9 53 ff ff ff       	jmp    8012e2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80138f:	8b 45 14             	mov    0x14(%ebp),%eax
  801392:	8d 50 04             	lea    0x4(%eax),%edx
  801395:	89 55 14             	mov    %edx,0x14(%ebp)
  801398:	83 ec 08             	sub    $0x8,%esp
  80139b:	53                   	push   %ebx
  80139c:	ff 30                	pushl  (%eax)
  80139e:	ff d6                	call   *%esi
			break;
  8013a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013a6:	e9 04 ff ff ff       	jmp    8012af <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ae:	8d 50 04             	lea    0x4(%eax),%edx
  8013b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b4:	8b 00                	mov    (%eax),%eax
  8013b6:	99                   	cltd   
  8013b7:	31 d0                	xor    %edx,%eax
  8013b9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013bb:	83 f8 0f             	cmp    $0xf,%eax
  8013be:	7f 0b                	jg     8013cb <vprintfmt+0x142>
  8013c0:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013c7:	85 d2                	test   %edx,%edx
  8013c9:	75 18                	jne    8013e3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013cb:	50                   	push   %eax
  8013cc:	68 53 1f 80 00       	push   $0x801f53
  8013d1:	53                   	push   %ebx
  8013d2:	56                   	push   %esi
  8013d3:	e8 94 fe ff ff       	call   80126c <printfmt>
  8013d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013de:	e9 cc fe ff ff       	jmp    8012af <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013e3:	52                   	push   %edx
  8013e4:	68 bd 1e 80 00       	push   $0x801ebd
  8013e9:	53                   	push   %ebx
  8013ea:	56                   	push   %esi
  8013eb:	e8 7c fe ff ff       	call   80126c <printfmt>
  8013f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013f6:	e9 b4 fe ff ff       	jmp    8012af <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013fe:	8d 50 04             	lea    0x4(%eax),%edx
  801401:	89 55 14             	mov    %edx,0x14(%ebp)
  801404:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801406:	85 ff                	test   %edi,%edi
  801408:	b8 4c 1f 80 00       	mov    $0x801f4c,%eax
  80140d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801410:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801414:	0f 8e 94 00 00 00    	jle    8014ae <vprintfmt+0x225>
  80141a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80141e:	0f 84 98 00 00 00    	je     8014bc <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	ff 75 d0             	pushl  -0x30(%ebp)
  80142a:	57                   	push   %edi
  80142b:	e8 86 02 00 00       	call   8016b6 <strnlen>
  801430:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801433:	29 c1                	sub    %eax,%ecx
  801435:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801438:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80143b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80143f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801442:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801445:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801447:	eb 0f                	jmp    801458 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	53                   	push   %ebx
  80144d:	ff 75 e0             	pushl  -0x20(%ebp)
  801450:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801452:	83 ef 01             	sub    $0x1,%edi
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	85 ff                	test   %edi,%edi
  80145a:	7f ed                	jg     801449 <vprintfmt+0x1c0>
  80145c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80145f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801462:	85 c9                	test   %ecx,%ecx
  801464:	b8 00 00 00 00       	mov    $0x0,%eax
  801469:	0f 49 c1             	cmovns %ecx,%eax
  80146c:	29 c1                	sub    %eax,%ecx
  80146e:	89 75 08             	mov    %esi,0x8(%ebp)
  801471:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801474:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801477:	89 cb                	mov    %ecx,%ebx
  801479:	eb 4d                	jmp    8014c8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80147b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80147f:	74 1b                	je     80149c <vprintfmt+0x213>
  801481:	0f be c0             	movsbl %al,%eax
  801484:	83 e8 20             	sub    $0x20,%eax
  801487:	83 f8 5e             	cmp    $0x5e,%eax
  80148a:	76 10                	jbe    80149c <vprintfmt+0x213>
					putch('?', putdat);
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	ff 75 0c             	pushl  0xc(%ebp)
  801492:	6a 3f                	push   $0x3f
  801494:	ff 55 08             	call   *0x8(%ebp)
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	eb 0d                	jmp    8014a9 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	ff 75 0c             	pushl  0xc(%ebp)
  8014a2:	52                   	push   %edx
  8014a3:	ff 55 08             	call   *0x8(%ebp)
  8014a6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014a9:	83 eb 01             	sub    $0x1,%ebx
  8014ac:	eb 1a                	jmp    8014c8 <vprintfmt+0x23f>
  8014ae:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014ba:	eb 0c                	jmp    8014c8 <vprintfmt+0x23f>
  8014bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8014bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014c8:	83 c7 01             	add    $0x1,%edi
  8014cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014cf:	0f be d0             	movsbl %al,%edx
  8014d2:	85 d2                	test   %edx,%edx
  8014d4:	74 23                	je     8014f9 <vprintfmt+0x270>
  8014d6:	85 f6                	test   %esi,%esi
  8014d8:	78 a1                	js     80147b <vprintfmt+0x1f2>
  8014da:	83 ee 01             	sub    $0x1,%esi
  8014dd:	79 9c                	jns    80147b <vprintfmt+0x1f2>
  8014df:	89 df                	mov    %ebx,%edi
  8014e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e7:	eb 18                	jmp    801501 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	53                   	push   %ebx
  8014ed:	6a 20                	push   $0x20
  8014ef:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014f1:	83 ef 01             	sub    $0x1,%edi
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	eb 08                	jmp    801501 <vprintfmt+0x278>
  8014f9:	89 df                	mov    %ebx,%edi
  8014fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8014fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801501:	85 ff                	test   %edi,%edi
  801503:	7f e4                	jg     8014e9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801508:	e9 a2 fd ff ff       	jmp    8012af <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80150d:	83 fa 01             	cmp    $0x1,%edx
  801510:	7e 16                	jle    801528 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801512:	8b 45 14             	mov    0x14(%ebp),%eax
  801515:	8d 50 08             	lea    0x8(%eax),%edx
  801518:	89 55 14             	mov    %edx,0x14(%ebp)
  80151b:	8b 50 04             	mov    0x4(%eax),%edx
  80151e:	8b 00                	mov    (%eax),%eax
  801520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801523:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801526:	eb 32                	jmp    80155a <vprintfmt+0x2d1>
	else if (lflag)
  801528:	85 d2                	test   %edx,%edx
  80152a:	74 18                	je     801544 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80152c:	8b 45 14             	mov    0x14(%ebp),%eax
  80152f:	8d 50 04             	lea    0x4(%eax),%edx
  801532:	89 55 14             	mov    %edx,0x14(%ebp)
  801535:	8b 00                	mov    (%eax),%eax
  801537:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153a:	89 c1                	mov    %eax,%ecx
  80153c:	c1 f9 1f             	sar    $0x1f,%ecx
  80153f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801542:	eb 16                	jmp    80155a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801544:	8b 45 14             	mov    0x14(%ebp),%eax
  801547:	8d 50 04             	lea    0x4(%eax),%edx
  80154a:	89 55 14             	mov    %edx,0x14(%ebp)
  80154d:	8b 00                	mov    (%eax),%eax
  80154f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801552:	89 c1                	mov    %eax,%ecx
  801554:	c1 f9 1f             	sar    $0x1f,%ecx
  801557:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80155a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80155d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801560:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801565:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801569:	79 74                	jns    8015df <vprintfmt+0x356>
				putch('-', putdat);
  80156b:	83 ec 08             	sub    $0x8,%esp
  80156e:	53                   	push   %ebx
  80156f:	6a 2d                	push   $0x2d
  801571:	ff d6                	call   *%esi
				num = -(long long) num;
  801573:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801576:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801579:	f7 d8                	neg    %eax
  80157b:	83 d2 00             	adc    $0x0,%edx
  80157e:	f7 da                	neg    %edx
  801580:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801583:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801588:	eb 55                	jmp    8015df <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80158a:	8d 45 14             	lea    0x14(%ebp),%eax
  80158d:	e8 83 fc ff ff       	call   801215 <getuint>
			base = 10;
  801592:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801597:	eb 46                	jmp    8015df <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801599:	8d 45 14             	lea    0x14(%ebp),%eax
  80159c:	e8 74 fc ff ff       	call   801215 <getuint>
			base = 8;
  8015a1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015a6:	eb 37                	jmp    8015df <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	53                   	push   %ebx
  8015ac:	6a 30                	push   $0x30
  8015ae:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	53                   	push   %ebx
  8015b4:	6a 78                	push   $0x78
  8015b6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bb:	8d 50 04             	lea    0x4(%eax),%edx
  8015be:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015c1:	8b 00                	mov    (%eax),%eax
  8015c3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015cb:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015d0:	eb 0d                	jmp    8015df <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8015d5:	e8 3b fc ff ff       	call   801215 <getuint>
			base = 16;
  8015da:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015df:	83 ec 0c             	sub    $0xc,%esp
  8015e2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015e6:	57                   	push   %edi
  8015e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ea:	51                   	push   %ecx
  8015eb:	52                   	push   %edx
  8015ec:	50                   	push   %eax
  8015ed:	89 da                	mov    %ebx,%edx
  8015ef:	89 f0                	mov    %esi,%eax
  8015f1:	e8 70 fb ff ff       	call   801166 <printnum>
			break;
  8015f6:	83 c4 20             	add    $0x20,%esp
  8015f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015fc:	e9 ae fc ff ff       	jmp    8012af <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	53                   	push   %ebx
  801605:	51                   	push   %ecx
  801606:	ff d6                	call   *%esi
			break;
  801608:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80160e:	e9 9c fc ff ff       	jmp    8012af <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801613:	83 ec 08             	sub    $0x8,%esp
  801616:	53                   	push   %ebx
  801617:	6a 25                	push   $0x25
  801619:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	eb 03                	jmp    801623 <vprintfmt+0x39a>
  801620:	83 ef 01             	sub    $0x1,%edi
  801623:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801627:	75 f7                	jne    801620 <vprintfmt+0x397>
  801629:	e9 81 fc ff ff       	jmp    8012af <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80162e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801631:	5b                   	pop    %ebx
  801632:	5e                   	pop    %esi
  801633:	5f                   	pop    %edi
  801634:	5d                   	pop    %ebp
  801635:	c3                   	ret    

00801636 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	83 ec 18             	sub    $0x18,%esp
  80163c:	8b 45 08             	mov    0x8(%ebp),%eax
  80163f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801642:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801645:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801649:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80164c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801653:	85 c0                	test   %eax,%eax
  801655:	74 26                	je     80167d <vsnprintf+0x47>
  801657:	85 d2                	test   %edx,%edx
  801659:	7e 22                	jle    80167d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80165b:	ff 75 14             	pushl  0x14(%ebp)
  80165e:	ff 75 10             	pushl  0x10(%ebp)
  801661:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	68 4f 12 80 00       	push   $0x80124f
  80166a:	e8 1a fc ff ff       	call   801289 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80166f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801672:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801675:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	eb 05                	jmp    801682 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80167d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80168a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80168d:	50                   	push   %eax
  80168e:	ff 75 10             	pushl  0x10(%ebp)
  801691:	ff 75 0c             	pushl  0xc(%ebp)
  801694:	ff 75 08             	pushl  0x8(%ebp)
  801697:	e8 9a ff ff ff       	call   801636 <vsnprintf>
	va_end(ap);

	return rc;
}
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a9:	eb 03                	jmp    8016ae <strlen+0x10>
		n++;
  8016ab:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016b2:	75 f7                	jne    8016ab <strlen+0xd>
		n++;
	return n;
}
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c4:	eb 03                	jmp    8016c9 <strnlen+0x13>
		n++;
  8016c6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c9:	39 c2                	cmp    %eax,%edx
  8016cb:	74 08                	je     8016d5 <strnlen+0x1f>
  8016cd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016d1:	75 f3                	jne    8016c6 <strnlen+0x10>
  8016d3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	53                   	push   %ebx
  8016db:	8b 45 08             	mov    0x8(%ebp),%eax
  8016de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	83 c2 01             	add    $0x1,%edx
  8016e6:	83 c1 01             	add    $0x1,%ecx
  8016e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016f0:	84 db                	test   %bl,%bl
  8016f2:	75 ef                	jne    8016e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016f4:	5b                   	pop    %ebx
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	53                   	push   %ebx
  8016fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016fe:	53                   	push   %ebx
  8016ff:	e8 9a ff ff ff       	call   80169e <strlen>
  801704:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801707:	ff 75 0c             	pushl  0xc(%ebp)
  80170a:	01 d8                	add    %ebx,%eax
  80170c:	50                   	push   %eax
  80170d:	e8 c5 ff ff ff       	call   8016d7 <strcpy>
	return dst;
}
  801712:	89 d8                	mov    %ebx,%eax
  801714:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801717:	c9                   	leave  
  801718:	c3                   	ret    

00801719 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	56                   	push   %esi
  80171d:	53                   	push   %ebx
  80171e:	8b 75 08             	mov    0x8(%ebp),%esi
  801721:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801724:	89 f3                	mov    %esi,%ebx
  801726:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801729:	89 f2                	mov    %esi,%edx
  80172b:	eb 0f                	jmp    80173c <strncpy+0x23>
		*dst++ = *src;
  80172d:	83 c2 01             	add    $0x1,%edx
  801730:	0f b6 01             	movzbl (%ecx),%eax
  801733:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801736:	80 39 01             	cmpb   $0x1,(%ecx)
  801739:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173c:	39 da                	cmp    %ebx,%edx
  80173e:	75 ed                	jne    80172d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801740:	89 f0                	mov    %esi,%eax
  801742:	5b                   	pop    %ebx
  801743:	5e                   	pop    %esi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    

00801746 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	56                   	push   %esi
  80174a:	53                   	push   %ebx
  80174b:	8b 75 08             	mov    0x8(%ebp),%esi
  80174e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801751:	8b 55 10             	mov    0x10(%ebp),%edx
  801754:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801756:	85 d2                	test   %edx,%edx
  801758:	74 21                	je     80177b <strlcpy+0x35>
  80175a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80175e:	89 f2                	mov    %esi,%edx
  801760:	eb 09                	jmp    80176b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801762:	83 c2 01             	add    $0x1,%edx
  801765:	83 c1 01             	add    $0x1,%ecx
  801768:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80176b:	39 c2                	cmp    %eax,%edx
  80176d:	74 09                	je     801778 <strlcpy+0x32>
  80176f:	0f b6 19             	movzbl (%ecx),%ebx
  801772:	84 db                	test   %bl,%bl
  801774:	75 ec                	jne    801762 <strlcpy+0x1c>
  801776:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801778:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80177b:	29 f0                	sub    %esi,%eax
}
  80177d:	5b                   	pop    %ebx
  80177e:	5e                   	pop    %esi
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801787:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80178a:	eb 06                	jmp    801792 <strcmp+0x11>
		p++, q++;
  80178c:	83 c1 01             	add    $0x1,%ecx
  80178f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801792:	0f b6 01             	movzbl (%ecx),%eax
  801795:	84 c0                	test   %al,%al
  801797:	74 04                	je     80179d <strcmp+0x1c>
  801799:	3a 02                	cmp    (%edx),%al
  80179b:	74 ef                	je     80178c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80179d:	0f b6 c0             	movzbl %al,%eax
  8017a0:	0f b6 12             	movzbl (%edx),%edx
  8017a3:	29 d0                	sub    %edx,%eax
}
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	53                   	push   %ebx
  8017ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b1:	89 c3                	mov    %eax,%ebx
  8017b3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017b6:	eb 06                	jmp    8017be <strncmp+0x17>
		n--, p++, q++;
  8017b8:	83 c0 01             	add    $0x1,%eax
  8017bb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017be:	39 d8                	cmp    %ebx,%eax
  8017c0:	74 15                	je     8017d7 <strncmp+0x30>
  8017c2:	0f b6 08             	movzbl (%eax),%ecx
  8017c5:	84 c9                	test   %cl,%cl
  8017c7:	74 04                	je     8017cd <strncmp+0x26>
  8017c9:	3a 0a                	cmp    (%edx),%cl
  8017cb:	74 eb                	je     8017b8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017cd:	0f b6 00             	movzbl (%eax),%eax
  8017d0:	0f b6 12             	movzbl (%edx),%edx
  8017d3:	29 d0                	sub    %edx,%eax
  8017d5:	eb 05                	jmp    8017dc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017dc:	5b                   	pop    %ebx
  8017dd:	5d                   	pop    %ebp
  8017de:	c3                   	ret    

008017df <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e9:	eb 07                	jmp    8017f2 <strchr+0x13>
		if (*s == c)
  8017eb:	38 ca                	cmp    %cl,%dl
  8017ed:	74 0f                	je     8017fe <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017ef:	83 c0 01             	add    $0x1,%eax
  8017f2:	0f b6 10             	movzbl (%eax),%edx
  8017f5:	84 d2                	test   %dl,%dl
  8017f7:	75 f2                	jne    8017eb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180a:	eb 03                	jmp    80180f <strfind+0xf>
  80180c:	83 c0 01             	add    $0x1,%eax
  80180f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801812:	38 ca                	cmp    %cl,%dl
  801814:	74 04                	je     80181a <strfind+0x1a>
  801816:	84 d2                	test   %dl,%dl
  801818:	75 f2                	jne    80180c <strfind+0xc>
			break;
	return (char *) s;
}
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	57                   	push   %edi
  801820:	56                   	push   %esi
  801821:	53                   	push   %ebx
  801822:	8b 7d 08             	mov    0x8(%ebp),%edi
  801825:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801828:	85 c9                	test   %ecx,%ecx
  80182a:	74 36                	je     801862 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80182c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801832:	75 28                	jne    80185c <memset+0x40>
  801834:	f6 c1 03             	test   $0x3,%cl
  801837:	75 23                	jne    80185c <memset+0x40>
		c &= 0xFF;
  801839:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80183d:	89 d3                	mov    %edx,%ebx
  80183f:	c1 e3 08             	shl    $0x8,%ebx
  801842:	89 d6                	mov    %edx,%esi
  801844:	c1 e6 18             	shl    $0x18,%esi
  801847:	89 d0                	mov    %edx,%eax
  801849:	c1 e0 10             	shl    $0x10,%eax
  80184c:	09 f0                	or     %esi,%eax
  80184e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801850:	89 d8                	mov    %ebx,%eax
  801852:	09 d0                	or     %edx,%eax
  801854:	c1 e9 02             	shr    $0x2,%ecx
  801857:	fc                   	cld    
  801858:	f3 ab                	rep stos %eax,%es:(%edi)
  80185a:	eb 06                	jmp    801862 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185f:	fc                   	cld    
  801860:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801862:	89 f8                	mov    %edi,%eax
  801864:	5b                   	pop    %ebx
  801865:	5e                   	pop    %esi
  801866:	5f                   	pop    %edi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	57                   	push   %edi
  80186d:	56                   	push   %esi
  80186e:	8b 45 08             	mov    0x8(%ebp),%eax
  801871:	8b 75 0c             	mov    0xc(%ebp),%esi
  801874:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801877:	39 c6                	cmp    %eax,%esi
  801879:	73 35                	jae    8018b0 <memmove+0x47>
  80187b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80187e:	39 d0                	cmp    %edx,%eax
  801880:	73 2e                	jae    8018b0 <memmove+0x47>
		s += n;
		d += n;
  801882:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801885:	89 d6                	mov    %edx,%esi
  801887:	09 fe                	or     %edi,%esi
  801889:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80188f:	75 13                	jne    8018a4 <memmove+0x3b>
  801891:	f6 c1 03             	test   $0x3,%cl
  801894:	75 0e                	jne    8018a4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801896:	83 ef 04             	sub    $0x4,%edi
  801899:	8d 72 fc             	lea    -0x4(%edx),%esi
  80189c:	c1 e9 02             	shr    $0x2,%ecx
  80189f:	fd                   	std    
  8018a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a2:	eb 09                	jmp    8018ad <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018a4:	83 ef 01             	sub    $0x1,%edi
  8018a7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018aa:	fd                   	std    
  8018ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ad:	fc                   	cld    
  8018ae:	eb 1d                	jmp    8018cd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b0:	89 f2                	mov    %esi,%edx
  8018b2:	09 c2                	or     %eax,%edx
  8018b4:	f6 c2 03             	test   $0x3,%dl
  8018b7:	75 0f                	jne    8018c8 <memmove+0x5f>
  8018b9:	f6 c1 03             	test   $0x3,%cl
  8018bc:	75 0a                	jne    8018c8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018be:	c1 e9 02             	shr    $0x2,%ecx
  8018c1:	89 c7                	mov    %eax,%edi
  8018c3:	fc                   	cld    
  8018c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c6:	eb 05                	jmp    8018cd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018c8:	89 c7                	mov    %eax,%edi
  8018ca:	fc                   	cld    
  8018cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018cd:	5e                   	pop    %esi
  8018ce:	5f                   	pop    %edi
  8018cf:	5d                   	pop    %ebp
  8018d0:	c3                   	ret    

008018d1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d4:	ff 75 10             	pushl  0x10(%ebp)
  8018d7:	ff 75 0c             	pushl  0xc(%ebp)
  8018da:	ff 75 08             	pushl  0x8(%ebp)
  8018dd:	e8 87 ff ff ff       	call   801869 <memmove>
}
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	56                   	push   %esi
  8018e8:	53                   	push   %ebx
  8018e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ef:	89 c6                	mov    %eax,%esi
  8018f1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f4:	eb 1a                	jmp    801910 <memcmp+0x2c>
		if (*s1 != *s2)
  8018f6:	0f b6 08             	movzbl (%eax),%ecx
  8018f9:	0f b6 1a             	movzbl (%edx),%ebx
  8018fc:	38 d9                	cmp    %bl,%cl
  8018fe:	74 0a                	je     80190a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801900:	0f b6 c1             	movzbl %cl,%eax
  801903:	0f b6 db             	movzbl %bl,%ebx
  801906:	29 d8                	sub    %ebx,%eax
  801908:	eb 0f                	jmp    801919 <memcmp+0x35>
		s1++, s2++;
  80190a:	83 c0 01             	add    $0x1,%eax
  80190d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801910:	39 f0                	cmp    %esi,%eax
  801912:	75 e2                	jne    8018f6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	53                   	push   %ebx
  801921:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801924:	89 c1                	mov    %eax,%ecx
  801926:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801929:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80192d:	eb 0a                	jmp    801939 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80192f:	0f b6 10             	movzbl (%eax),%edx
  801932:	39 da                	cmp    %ebx,%edx
  801934:	74 07                	je     80193d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801936:	83 c0 01             	add    $0x1,%eax
  801939:	39 c8                	cmp    %ecx,%eax
  80193b:	72 f2                	jb     80192f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80193d:	5b                   	pop    %ebx
  80193e:	5d                   	pop    %ebp
  80193f:	c3                   	ret    

00801940 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	57                   	push   %edi
  801944:	56                   	push   %esi
  801945:	53                   	push   %ebx
  801946:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801949:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80194c:	eb 03                	jmp    801951 <strtol+0x11>
		s++;
  80194e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801951:	0f b6 01             	movzbl (%ecx),%eax
  801954:	3c 20                	cmp    $0x20,%al
  801956:	74 f6                	je     80194e <strtol+0xe>
  801958:	3c 09                	cmp    $0x9,%al
  80195a:	74 f2                	je     80194e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80195c:	3c 2b                	cmp    $0x2b,%al
  80195e:	75 0a                	jne    80196a <strtol+0x2a>
		s++;
  801960:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801963:	bf 00 00 00 00       	mov    $0x0,%edi
  801968:	eb 11                	jmp    80197b <strtol+0x3b>
  80196a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80196f:	3c 2d                	cmp    $0x2d,%al
  801971:	75 08                	jne    80197b <strtol+0x3b>
		s++, neg = 1;
  801973:	83 c1 01             	add    $0x1,%ecx
  801976:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801981:	75 15                	jne    801998 <strtol+0x58>
  801983:	80 39 30             	cmpb   $0x30,(%ecx)
  801986:	75 10                	jne    801998 <strtol+0x58>
  801988:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80198c:	75 7c                	jne    801a0a <strtol+0xca>
		s += 2, base = 16;
  80198e:	83 c1 02             	add    $0x2,%ecx
  801991:	bb 10 00 00 00       	mov    $0x10,%ebx
  801996:	eb 16                	jmp    8019ae <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801998:	85 db                	test   %ebx,%ebx
  80199a:	75 12                	jne    8019ae <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80199c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a1:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a4:	75 08                	jne    8019ae <strtol+0x6e>
		s++, base = 8;
  8019a6:	83 c1 01             	add    $0x1,%ecx
  8019a9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019b6:	0f b6 11             	movzbl (%ecx),%edx
  8019b9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019bc:	89 f3                	mov    %esi,%ebx
  8019be:	80 fb 09             	cmp    $0x9,%bl
  8019c1:	77 08                	ja     8019cb <strtol+0x8b>
			dig = *s - '0';
  8019c3:	0f be d2             	movsbl %dl,%edx
  8019c6:	83 ea 30             	sub    $0x30,%edx
  8019c9:	eb 22                	jmp    8019ed <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019cb:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019ce:	89 f3                	mov    %esi,%ebx
  8019d0:	80 fb 19             	cmp    $0x19,%bl
  8019d3:	77 08                	ja     8019dd <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019d5:	0f be d2             	movsbl %dl,%edx
  8019d8:	83 ea 57             	sub    $0x57,%edx
  8019db:	eb 10                	jmp    8019ed <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019dd:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019e0:	89 f3                	mov    %esi,%ebx
  8019e2:	80 fb 19             	cmp    $0x19,%bl
  8019e5:	77 16                	ja     8019fd <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019e7:	0f be d2             	movsbl %dl,%edx
  8019ea:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019ed:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f0:	7d 0b                	jge    8019fd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019f2:	83 c1 01             	add    $0x1,%ecx
  8019f5:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019f9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019fb:	eb b9                	jmp    8019b6 <strtol+0x76>

	if (endptr)
  8019fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a01:	74 0d                	je     801a10 <strtol+0xd0>
		*endptr = (char *) s;
  801a03:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a06:	89 0e                	mov    %ecx,(%esi)
  801a08:	eb 06                	jmp    801a10 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a0a:	85 db                	test   %ebx,%ebx
  801a0c:	74 98                	je     8019a6 <strtol+0x66>
  801a0e:	eb 9e                	jmp    8019ae <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a10:	89 c2                	mov    %eax,%edx
  801a12:	f7 da                	neg    %edx
  801a14:	85 ff                	test   %edi,%edi
  801a16:	0f 45 c2             	cmovne %edx,%eax
}
  801a19:	5b                   	pop    %ebx
  801a1a:	5e                   	pop    %esi
  801a1b:	5f                   	pop    %edi
  801a1c:	5d                   	pop    %ebp
  801a1d:	c3                   	ret    

00801a1e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	56                   	push   %esi
  801a22:	53                   	push   %ebx
  801a23:	8b 75 08             	mov    0x8(%ebp),%esi
  801a26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801a2c:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801a2e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a33:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801a36:	83 ec 0c             	sub    $0xc,%esp
  801a39:	50                   	push   %eax
  801a3a:	e8 c6 e8 ff ff       	call   800305 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	85 c0                	test   %eax,%eax
  801a44:	78 0e                	js     801a54 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801a46:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a4c:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801a4f:	8b 52 78             	mov    0x78(%edx),%edx
  801a52:	eb 0a                	jmp    801a5e <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801a54:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801a59:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801a5e:	85 f6                	test   %esi,%esi
  801a60:	74 02                	je     801a64 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801a62:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801a64:	85 db                	test   %ebx,%ebx
  801a66:	74 02                	je     801a6a <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801a68:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	78 08                	js     801a76 <ipc_recv+0x58>
  801a6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a73:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801a76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a79:	5b                   	pop    %ebx
  801a7a:	5e                   	pop    %esi
  801a7b:	5d                   	pop    %ebp
  801a7c:	c3                   	ret    

00801a7d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	57                   	push   %edi
  801a81:	56                   	push   %esi
  801a82:	53                   	push   %ebx
  801a83:	83 ec 0c             	sub    $0xc,%esp
  801a86:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a89:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801a8f:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801a91:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801a96:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801a99:	ff 75 14             	pushl  0x14(%ebp)
  801a9c:	53                   	push   %ebx
  801a9d:	56                   	push   %esi
  801a9e:	57                   	push   %edi
  801a9f:	e8 3e e8 ff ff       	call   8002e2 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aaa:	75 07                	jne    801ab3 <ipc_send+0x36>
				    sys_yield();
  801aac:	e8 85 e6 ff ff       	call   800136 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801ab1:	eb e6                	jmp    801a99 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	74 12                	je     801ac9 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801ab7:	50                   	push   %eax
  801ab8:	68 40 22 80 00       	push   $0x802240
  801abd:	6a 4b                	push   $0x4b
  801abf:	68 54 22 80 00       	push   $0x802254
  801ac4:	e8 b0 f5 ff ff       	call   801079 <_panic>
			 }
	   }
}
  801ac9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acc:	5b                   	pop    %ebx
  801acd:	5e                   	pop    %esi
  801ace:	5f                   	pop    %edi
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801adc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801adf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ae5:	8b 52 50             	mov    0x50(%edx),%edx
  801ae8:	39 ca                	cmp    %ecx,%edx
  801aea:	75 0d                	jne    801af9 <ipc_find_env+0x28>
				    return envs[i].env_id;
  801aec:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af4:	8b 40 48             	mov    0x48(%eax),%eax
  801af7:	eb 0f                	jmp    801b08 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801af9:	83 c0 01             	add    $0x1,%eax
  801afc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b01:	75 d9                	jne    801adc <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801b03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b10:	89 d0                	mov    %edx,%eax
  801b12:	c1 e8 16             	shr    $0x16,%eax
  801b15:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b21:	f6 c1 01             	test   $0x1,%cl
  801b24:	74 1d                	je     801b43 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b26:	c1 ea 0c             	shr    $0xc,%edx
  801b29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b30:	f6 c2 01             	test   $0x1,%dl
  801b33:	74 0e                	je     801b43 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b35:	c1 ea 0c             	shr    $0xc,%edx
  801b38:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b3f:	ef 
  801b40:	0f b7 c0             	movzwl %ax,%eax
}
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    
  801b45:	66 90                	xchg   %ax,%ax
  801b47:	66 90                	xchg   %ax,%ax
  801b49:	66 90                	xchg   %ax,%ax
  801b4b:	66 90                	xchg   %ax,%ax
  801b4d:	66 90                	xchg   %ax,%ax
  801b4f:	90                   	nop

00801b50 <__udivdi3>:
  801b50:	55                   	push   %ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	53                   	push   %ebx
  801b54:	83 ec 1c             	sub    $0x1c,%esp
  801b57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b67:	85 f6                	test   %esi,%esi
  801b69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b6d:	89 ca                	mov    %ecx,%edx
  801b6f:	89 f8                	mov    %edi,%eax
  801b71:	75 3d                	jne    801bb0 <__udivdi3+0x60>
  801b73:	39 cf                	cmp    %ecx,%edi
  801b75:	0f 87 c5 00 00 00    	ja     801c40 <__udivdi3+0xf0>
  801b7b:	85 ff                	test   %edi,%edi
  801b7d:	89 fd                	mov    %edi,%ebp
  801b7f:	75 0b                	jne    801b8c <__udivdi3+0x3c>
  801b81:	b8 01 00 00 00       	mov    $0x1,%eax
  801b86:	31 d2                	xor    %edx,%edx
  801b88:	f7 f7                	div    %edi
  801b8a:	89 c5                	mov    %eax,%ebp
  801b8c:	89 c8                	mov    %ecx,%eax
  801b8e:	31 d2                	xor    %edx,%edx
  801b90:	f7 f5                	div    %ebp
  801b92:	89 c1                	mov    %eax,%ecx
  801b94:	89 d8                	mov    %ebx,%eax
  801b96:	89 cf                	mov    %ecx,%edi
  801b98:	f7 f5                	div    %ebp
  801b9a:	89 c3                	mov    %eax,%ebx
  801b9c:	89 d8                	mov    %ebx,%eax
  801b9e:	89 fa                	mov    %edi,%edx
  801ba0:	83 c4 1c             	add    $0x1c,%esp
  801ba3:	5b                   	pop    %ebx
  801ba4:	5e                   	pop    %esi
  801ba5:	5f                   	pop    %edi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    
  801ba8:	90                   	nop
  801ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bb0:	39 ce                	cmp    %ecx,%esi
  801bb2:	77 74                	ja     801c28 <__udivdi3+0xd8>
  801bb4:	0f bd fe             	bsr    %esi,%edi
  801bb7:	83 f7 1f             	xor    $0x1f,%edi
  801bba:	0f 84 98 00 00 00    	je     801c58 <__udivdi3+0x108>
  801bc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	89 c5                	mov    %eax,%ebp
  801bc9:	29 fb                	sub    %edi,%ebx
  801bcb:	d3 e6                	shl    %cl,%esi
  801bcd:	89 d9                	mov    %ebx,%ecx
  801bcf:	d3 ed                	shr    %cl,%ebp
  801bd1:	89 f9                	mov    %edi,%ecx
  801bd3:	d3 e0                	shl    %cl,%eax
  801bd5:	09 ee                	or     %ebp,%esi
  801bd7:	89 d9                	mov    %ebx,%ecx
  801bd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdd:	89 d5                	mov    %edx,%ebp
  801bdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801be3:	d3 ed                	shr    %cl,%ebp
  801be5:	89 f9                	mov    %edi,%ecx
  801be7:	d3 e2                	shl    %cl,%edx
  801be9:	89 d9                	mov    %ebx,%ecx
  801beb:	d3 e8                	shr    %cl,%eax
  801bed:	09 c2                	or     %eax,%edx
  801bef:	89 d0                	mov    %edx,%eax
  801bf1:	89 ea                	mov    %ebp,%edx
  801bf3:	f7 f6                	div    %esi
  801bf5:	89 d5                	mov    %edx,%ebp
  801bf7:	89 c3                	mov    %eax,%ebx
  801bf9:	f7 64 24 0c          	mull   0xc(%esp)
  801bfd:	39 d5                	cmp    %edx,%ebp
  801bff:	72 10                	jb     801c11 <__udivdi3+0xc1>
  801c01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	d3 e6                	shl    %cl,%esi
  801c09:	39 c6                	cmp    %eax,%esi
  801c0b:	73 07                	jae    801c14 <__udivdi3+0xc4>
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	75 03                	jne    801c14 <__udivdi3+0xc4>
  801c11:	83 eb 01             	sub    $0x1,%ebx
  801c14:	31 ff                	xor    %edi,%edi
  801c16:	89 d8                	mov    %ebx,%eax
  801c18:	89 fa                	mov    %edi,%edx
  801c1a:	83 c4 1c             	add    $0x1c,%esp
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5f                   	pop    %edi
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    
  801c22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c28:	31 ff                	xor    %edi,%edi
  801c2a:	31 db                	xor    %ebx,%ebx
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	89 fa                	mov    %edi,%edx
  801c30:	83 c4 1c             	add    $0x1c,%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    
  801c38:	90                   	nop
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	89 d8                	mov    %ebx,%eax
  801c42:	f7 f7                	div    %edi
  801c44:	31 ff                	xor    %edi,%edi
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	89 d8                	mov    %ebx,%eax
  801c4a:	89 fa                	mov    %edi,%edx
  801c4c:	83 c4 1c             	add    $0x1c,%esp
  801c4f:	5b                   	pop    %ebx
  801c50:	5e                   	pop    %esi
  801c51:	5f                   	pop    %edi
  801c52:	5d                   	pop    %ebp
  801c53:	c3                   	ret    
  801c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c58:	39 ce                	cmp    %ecx,%esi
  801c5a:	72 0c                	jb     801c68 <__udivdi3+0x118>
  801c5c:	31 db                	xor    %ebx,%ebx
  801c5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c62:	0f 87 34 ff ff ff    	ja     801b9c <__udivdi3+0x4c>
  801c68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c6d:	e9 2a ff ff ff       	jmp    801b9c <__udivdi3+0x4c>
  801c72:	66 90                	xchg   %ax,%ax
  801c74:	66 90                	xchg   %ax,%ax
  801c76:	66 90                	xchg   %ax,%ax
  801c78:	66 90                	xchg   %ax,%ax
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__umoddi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c97:	85 d2                	test   %edx,%edx
  801c99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ca1:	89 f3                	mov    %esi,%ebx
  801ca3:	89 3c 24             	mov    %edi,(%esp)
  801ca6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801caa:	75 1c                	jne    801cc8 <__umoddi3+0x48>
  801cac:	39 f7                	cmp    %esi,%edi
  801cae:	76 50                	jbe    801d00 <__umoddi3+0x80>
  801cb0:	89 c8                	mov    %ecx,%eax
  801cb2:	89 f2                	mov    %esi,%edx
  801cb4:	f7 f7                	div    %edi
  801cb6:	89 d0                	mov    %edx,%eax
  801cb8:	31 d2                	xor    %edx,%edx
  801cba:	83 c4 1c             	add    $0x1c,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    
  801cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	89 d0                	mov    %edx,%eax
  801ccc:	77 52                	ja     801d20 <__umoddi3+0xa0>
  801cce:	0f bd ea             	bsr    %edx,%ebp
  801cd1:	83 f5 1f             	xor    $0x1f,%ebp
  801cd4:	75 5a                	jne    801d30 <__umoddi3+0xb0>
  801cd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cda:	0f 82 e0 00 00 00    	jb     801dc0 <__umoddi3+0x140>
  801ce0:	39 0c 24             	cmp    %ecx,(%esp)
  801ce3:	0f 86 d7 00 00 00    	jbe    801dc0 <__umoddi3+0x140>
  801ce9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ced:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cf1:	83 c4 1c             	add    $0x1c,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	85 ff                	test   %edi,%edi
  801d02:	89 fd                	mov    %edi,%ebp
  801d04:	75 0b                	jne    801d11 <__umoddi3+0x91>
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	f7 f7                	div    %edi
  801d0f:	89 c5                	mov    %eax,%ebp
  801d11:	89 f0                	mov    %esi,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f5                	div    %ebp
  801d17:	89 c8                	mov    %ecx,%eax
  801d19:	f7 f5                	div    %ebp
  801d1b:	89 d0                	mov    %edx,%eax
  801d1d:	eb 99                	jmp    801cb8 <__umoddi3+0x38>
  801d1f:	90                   	nop
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	83 c4 1c             	add    $0x1c,%esp
  801d27:	5b                   	pop    %ebx
  801d28:	5e                   	pop    %esi
  801d29:	5f                   	pop    %edi
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    
  801d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d30:	8b 34 24             	mov    (%esp),%esi
  801d33:	bf 20 00 00 00       	mov    $0x20,%edi
  801d38:	89 e9                	mov    %ebp,%ecx
  801d3a:	29 ef                	sub    %ebp,%edi
  801d3c:	d3 e0                	shl    %cl,%eax
  801d3e:	89 f9                	mov    %edi,%ecx
  801d40:	89 f2                	mov    %esi,%edx
  801d42:	d3 ea                	shr    %cl,%edx
  801d44:	89 e9                	mov    %ebp,%ecx
  801d46:	09 c2                	or     %eax,%edx
  801d48:	89 d8                	mov    %ebx,%eax
  801d4a:	89 14 24             	mov    %edx,(%esp)
  801d4d:	89 f2                	mov    %esi,%edx
  801d4f:	d3 e2                	shl    %cl,%edx
  801d51:	89 f9                	mov    %edi,%ecx
  801d53:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d5b:	d3 e8                	shr    %cl,%eax
  801d5d:	89 e9                	mov    %ebp,%ecx
  801d5f:	89 c6                	mov    %eax,%esi
  801d61:	d3 e3                	shl    %cl,%ebx
  801d63:	89 f9                	mov    %edi,%ecx
  801d65:	89 d0                	mov    %edx,%eax
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	09 d8                	or     %ebx,%eax
  801d6d:	89 d3                	mov    %edx,%ebx
  801d6f:	89 f2                	mov    %esi,%edx
  801d71:	f7 34 24             	divl   (%esp)
  801d74:	89 d6                	mov    %edx,%esi
  801d76:	d3 e3                	shl    %cl,%ebx
  801d78:	f7 64 24 04          	mull   0x4(%esp)
  801d7c:	39 d6                	cmp    %edx,%esi
  801d7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d82:	89 d1                	mov    %edx,%ecx
  801d84:	89 c3                	mov    %eax,%ebx
  801d86:	72 08                	jb     801d90 <__umoddi3+0x110>
  801d88:	75 11                	jne    801d9b <__umoddi3+0x11b>
  801d8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d8e:	73 0b                	jae    801d9b <__umoddi3+0x11b>
  801d90:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d94:	1b 14 24             	sbb    (%esp),%edx
  801d97:	89 d1                	mov    %edx,%ecx
  801d99:	89 c3                	mov    %eax,%ebx
  801d9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d9f:	29 da                	sub    %ebx,%edx
  801da1:	19 ce                	sbb    %ecx,%esi
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 f0                	mov    %esi,%eax
  801da7:	d3 e0                	shl    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	d3 ea                	shr    %cl,%edx
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	d3 ee                	shr    %cl,%esi
  801db1:	09 d0                	or     %edx,%eax
  801db3:	89 f2                	mov    %esi,%edx
  801db5:	83 c4 1c             	add    $0x1c,%esp
  801db8:	5b                   	pop    %ebx
  801db9:	5e                   	pop    %esi
  801dba:	5f                   	pop    %edi
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
  801dc0:	29 f9                	sub    %edi,%ecx
  801dc2:	19 d6                	sbb    %edx,%esi
  801dc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dcc:	e9 18 ff ff ff       	jmp    801ce9 <__umoddi3+0x69>
