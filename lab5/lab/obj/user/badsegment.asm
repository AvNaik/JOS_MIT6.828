
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 87 04 00 00       	call   800516 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 ea 1d 80 00       	push   $0x801dea
  800108:	6a 23                	push   $0x23
  80010a:	68 07 1e 80 00       	push   $0x801e07
  80010f:	e8 6a 0f 00 00       	call   80107e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 ea 1d 80 00       	push   $0x801dea
  800189:	6a 23                	push   $0x23
  80018b:	68 07 1e 80 00       	push   $0x801e07
  800190:	e8 e9 0e 00 00       	call   80107e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 ea 1d 80 00       	push   $0x801dea
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 07 1e 80 00       	push   $0x801e07
  8001d2:	e8 a7 0e 00 00       	call   80107e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 ea 1d 80 00       	push   $0x801dea
  80020d:	6a 23                	push   $0x23
  80020f:	68 07 1e 80 00       	push   $0x801e07
  800214:	e8 65 0e 00 00       	call   80107e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 ea 1d 80 00       	push   $0x801dea
  80024f:	6a 23                	push   $0x23
  800251:	68 07 1e 80 00       	push   $0x801e07
  800256:	e8 23 0e 00 00       	call   80107e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 ea 1d 80 00       	push   $0x801dea
  800291:	6a 23                	push   $0x23
  800293:	68 07 1e 80 00       	push   $0x801e07
  800298:	e8 e1 0d 00 00       	call   80107e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 ea 1d 80 00       	push   $0x801dea
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 07 1e 80 00       	push   $0x801e07
  8002da:	e8 9f 0d 00 00       	call   80107e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 ea 1d 80 00       	push   $0x801dea
  800337:	6a 23                	push   $0x23
  800339:	68 07 1e 80 00       	push   $0x801e07
  80033e:	e8 3b 0d 00 00       	call   80107e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	05 00 00 00 30       	add    $0x30000000,%eax
  800356:	c1 e8 0c             	shr    $0xc,%eax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037d:	89 c2                	mov    %eax,%edx
  80037f:	c1 ea 16             	shr    $0x16,%edx
  800382:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	74 11                	je     80039f <fd_alloc+0x2d>
  80038e:	89 c2                	mov    %eax,%edx
  800390:	c1 ea 0c             	shr    $0xc,%edx
  800393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039a:	f6 c2 01             	test   $0x1,%dl
  80039d:	75 09                	jne    8003a8 <fd_alloc+0x36>
			*fd_store = fd;
  80039f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	eb 17                	jmp    8003bf <fd_alloc+0x4d>
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 c9                	jne    80037d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c7:	83 f8 1f             	cmp    $0x1f,%eax
  8003ca:	77 36                	ja     800402 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003cc:	c1 e0 0c             	shl    $0xc,%eax
  8003cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 16             	shr    $0x16,%edx
  8003d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	74 24                	je     800409 <fd_lookup+0x48>
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 ea 0c             	shr    $0xc,%edx
  8003ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f1:	f6 c2 01             	test   $0x1,%dl
  8003f4:	74 1a                	je     800410 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800400:	eb 13                	jmp    800415 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800407:	eb 0c                	jmp    800415 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040e:	eb 05                	jmp    800415 <fd_lookup+0x54>
  800410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800420:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800425:	eb 13                	jmp    80043a <dev_lookup+0x23>
  800427:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042a:	39 08                	cmp    %ecx,(%eax)
  80042c:	75 0c                	jne    80043a <dev_lookup+0x23>
			*dev = devtab[i];
  80042e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800431:	89 01                	mov    %eax,(%ecx)
			return 0;
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	eb 2e                	jmp    800468 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 e7                	jne    800427 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800440:	a1 04 40 80 00       	mov    0x804004,%eax
  800445:	8b 40 48             	mov    0x48(%eax),%eax
  800448:	83 ec 04             	sub    $0x4,%esp
  80044b:	51                   	push   %ecx
  80044c:	50                   	push   %eax
  80044d:	68 18 1e 80 00       	push   $0x801e18
  800452:	e8 00 0d 00 00       	call   801157 <cprintf>
	*dev = 0;
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    

0080046a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 10             	sub    $0x10,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047b:	50                   	push   %eax
  80047c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800482:	c1 e8 0c             	shr    $0xc,%eax
  800485:	50                   	push   %eax
  800486:	e8 36 ff ff ff       	call   8003c1 <fd_lookup>
  80048b:	83 c4 08             	add    $0x8,%esp
  80048e:	85 c0                	test   %eax,%eax
  800490:	78 05                	js     800497 <fd_close+0x2d>
	    || fd != fd2)
  800492:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800495:	74 0c                	je     8004a3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800497:	84 db                	test   %bl,%bl
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	0f 44 c2             	cmove  %edx,%eax
  8004a1:	eb 41                	jmp    8004e4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a9:	50                   	push   %eax
  8004aa:	ff 36                	pushl  (%esi)
  8004ac:	e8 66 ff ff ff       	call   800417 <dev_lookup>
  8004b1:	89 c3                	mov    %eax,%ebx
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 1a                	js     8004d4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004bd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	74 0b                	je     8004d4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c9:	83 ec 0c             	sub    $0xc,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff d0                	call   *%eax
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	56                   	push   %esi
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 00 fd ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	89 d8                	mov    %ebx,%eax
}
  8004e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	50                   	push   %eax
  8004f5:	ff 75 08             	pushl  0x8(%ebp)
  8004f8:	e8 c4 fe ff ff       	call   8003c1 <fd_lookup>
  8004fd:	83 c4 08             	add    $0x8,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 10                	js     800514 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	6a 01                	push   $0x1
  800509:	ff 75 f4             	pushl  -0xc(%ebp)
  80050c:	e8 59 ff ff ff       	call   80046a <fd_close>
  800511:	83 c4 10             	add    $0x10,%esp
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <close_all>:

void
close_all(void)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	53                   	push   %ebx
  80051a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800522:	83 ec 0c             	sub    $0xc,%esp
  800525:	53                   	push   %ebx
  800526:	e8 c0 ff ff ff       	call   8004eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052b:	83 c3 01             	add    $0x1,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	83 fb 20             	cmp    $0x20,%ebx
  800534:	75 ec                	jne    800522 <close_all+0xc>
		close(i);
}
  800536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800539:	c9                   	leave  
  80053a:	c3                   	ret    

0080053b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	57                   	push   %edi
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
  800541:	83 ec 2c             	sub    $0x2c,%esp
  800544:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800547:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054a:	50                   	push   %eax
  80054b:	ff 75 08             	pushl  0x8(%ebp)
  80054e:	e8 6e fe ff ff       	call   8003c1 <fd_lookup>
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	85 c0                	test   %eax,%eax
  800558:	0f 88 c1 00 00 00    	js     80061f <dup+0xe4>
		return r;
	close(newfdnum);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	56                   	push   %esi
  800562:	e8 84 ff ff ff       	call   8004eb <close>

	newfd = INDEX2FD(newfdnum);
  800567:	89 f3                	mov    %esi,%ebx
  800569:	c1 e3 0c             	shl    $0xc,%ebx
  80056c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800572:	83 c4 04             	add    $0x4,%esp
  800575:	ff 75 e4             	pushl  -0x1c(%ebp)
  800578:	e8 de fd ff ff       	call   80035b <fd2data>
  80057d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057f:	89 1c 24             	mov    %ebx,(%esp)
  800582:	e8 d4 fd ff ff       	call   80035b <fd2data>
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80058d:	89 f8                	mov    %edi,%eax
  80058f:	c1 e8 16             	shr    $0x16,%eax
  800592:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800599:	a8 01                	test   $0x1,%al
  80059b:	74 37                	je     8005d4 <dup+0x99>
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 0c             	shr    $0xc,%eax
  8005a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a9:	f6 c2 01             	test   $0x1,%dl
  8005ac:	74 26                	je     8005d4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b5:	83 ec 0c             	sub    $0xc,%esp
  8005b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005bd:	50                   	push   %eax
  8005be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c1:	6a 00                	push   $0x0
  8005c3:	57                   	push   %edi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 d2 fb ff ff       	call   80019d <sys_page_map>
  8005cb:	89 c7                	mov    %eax,%edi
  8005cd:	83 c4 20             	add    $0x20,%esp
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	78 2e                	js     800602 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d7:	89 d0                	mov    %edx,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005eb:	50                   	push   %eax
  8005ec:	53                   	push   %ebx
  8005ed:	6a 00                	push   $0x0
  8005ef:	52                   	push   %edx
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 a6 fb ff ff       	call   80019d <sys_page_map>
  8005f7:	89 c7                	mov    %eax,%edi
  8005f9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005fc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fe:	85 ff                	test   %edi,%edi
  800600:	79 1d                	jns    80061f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 00                	push   $0x0
  800608:	e8 d2 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	ff 75 d4             	pushl  -0x2c(%ebp)
  800613:	6a 00                	push   $0x0
  800615:	e8 c5 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	89 f8                	mov    %edi,%eax
}
  80061f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800622:	5b                   	pop    %ebx
  800623:	5e                   	pop    %esi
  800624:	5f                   	pop    %edi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	53                   	push   %ebx
  80062b:	83 ec 14             	sub    $0x14,%esp
  80062e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	53                   	push   %ebx
  800636:	e8 86 fd ff ff       	call   8003c1 <fd_lookup>
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	89 c2                	mov    %eax,%edx
  800640:	85 c0                	test   %eax,%eax
  800642:	78 6d                	js     8006b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064a:	50                   	push   %eax
  80064b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064e:	ff 30                	pushl  (%eax)
  800650:	e8 c2 fd ff ff       	call   800417 <dev_lookup>
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 c0                	test   %eax,%eax
  80065a:	78 4c                	js     8006a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80065c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065f:	8b 42 08             	mov    0x8(%edx),%eax
  800662:	83 e0 03             	and    $0x3,%eax
  800665:	83 f8 01             	cmp    $0x1,%eax
  800668:	75 21                	jne    80068b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066a:	a1 04 40 80 00       	mov    0x804004,%eax
  80066f:	8b 40 48             	mov    0x48(%eax),%eax
  800672:	83 ec 04             	sub    $0x4,%esp
  800675:	53                   	push   %ebx
  800676:	50                   	push   %eax
  800677:	68 59 1e 80 00       	push   $0x801e59
  80067c:	e8 d6 0a 00 00       	call   801157 <cprintf>
		return -E_INVAL;
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800689:	eb 26                	jmp    8006b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	8b 40 08             	mov    0x8(%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	74 17                	je     8006ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	ff 75 0c             	pushl  0xc(%ebp)
  80069e:	52                   	push   %edx
  80069f:	ff d0                	call   *%eax
  8006a1:	89 c2                	mov    %eax,%edx
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 09                	jmp    8006b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a8:	89 c2                	mov    %eax,%edx
  8006aa:	eb 05                	jmp    8006b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b1:	89 d0                	mov    %edx,%eax
  8006b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cc:	eb 21                	jmp    8006ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ce:	83 ec 04             	sub    $0x4,%esp
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	29 d8                	sub    %ebx,%eax
  8006d5:	50                   	push   %eax
  8006d6:	89 d8                	mov    %ebx,%eax
  8006d8:	03 45 0c             	add    0xc(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	57                   	push   %edi
  8006dd:	e8 45 ff ff ff       	call   800627 <read>
		if (m < 0)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	78 10                	js     8006f9 <readn+0x41>
			return m;
		if (m == 0)
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 0a                	je     8006f7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ed:	01 c3                	add    %eax,%ebx
  8006ef:	39 f3                	cmp    %esi,%ebx
  8006f1:	72 db                	jb     8006ce <readn+0x16>
  8006f3:	89 d8                	mov    %ebx,%eax
  8006f5:	eb 02                	jmp    8006f9 <readn+0x41>
  8006f7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	53                   	push   %ebx
  800705:	83 ec 14             	sub    $0x14,%esp
  800708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	53                   	push   %ebx
  800710:	e8 ac fc ff ff       	call   8003c1 <fd_lookup>
  800715:	83 c4 08             	add    $0x8,%esp
  800718:	89 c2                	mov    %eax,%edx
  80071a:	85 c0                	test   %eax,%eax
  80071c:	78 68                	js     800786 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800728:	ff 30                	pushl  (%eax)
  80072a:	e8 e8 fc ff ff       	call   800417 <dev_lookup>
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	85 c0                	test   %eax,%eax
  800734:	78 47                	js     80077d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073d:	75 21                	jne    800760 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073f:	a1 04 40 80 00       	mov    0x804004,%eax
  800744:	8b 40 48             	mov    0x48(%eax),%eax
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	53                   	push   %ebx
  80074b:	50                   	push   %eax
  80074c:	68 75 1e 80 00       	push   $0x801e75
  800751:	e8 01 0a 00 00       	call   801157 <cprintf>
		return -E_INVAL;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075e:	eb 26                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800760:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800763:	8b 52 0c             	mov    0xc(%edx),%edx
  800766:	85 d2                	test   %edx,%edx
  800768:	74 17                	je     800781 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076a:	83 ec 04             	sub    $0x4,%esp
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	50                   	push   %eax
  800774:	ff d2                	call   *%edx
  800776:	89 c2                	mov    %eax,%edx
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 09                	jmp    800786 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	eb 05                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800781:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800786:	89 d0                	mov    %edx,%eax
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <seek>:

int
seek(int fdnum, off_t offset)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800793:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	ff 75 08             	pushl  0x8(%ebp)
  80079a:	e8 22 fc ff ff       	call   8003c1 <fd_lookup>
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	78 0e                	js     8007b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	83 ec 14             	sub    $0x14,%esp
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	53                   	push   %ebx
  8007c5:	e8 f7 fb ff ff       	call   8003c1 <fd_lookup>
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	78 65                	js     800838 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dd:	ff 30                	pushl  (%eax)
  8007df:	e8 33 fc ff ff       	call   800417 <dev_lookup>
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 44                	js     80082f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f2:	75 21                	jne    800815 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f9:	8b 40 48             	mov    0x48(%eax),%eax
  8007fc:	83 ec 04             	sub    $0x4,%esp
  8007ff:	53                   	push   %ebx
  800800:	50                   	push   %eax
  800801:	68 38 1e 80 00       	push   $0x801e38
  800806:	e8 4c 09 00 00       	call   801157 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800813:	eb 23                	jmp    800838 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800815:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800818:	8b 52 18             	mov    0x18(%edx),%edx
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 14                	je     800833 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	50                   	push   %eax
  800826:	ff d2                	call   *%edx
  800828:	89 c2                	mov    %eax,%edx
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	eb 09                	jmp    800838 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	89 c2                	mov    %eax,%edx
  800831:	eb 05                	jmp    800838 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800833:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800838:	89 d0                	mov    %edx,%eax
  80083a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	83 ec 14             	sub    $0x14,%esp
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800849:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084c:	50                   	push   %eax
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 6c fb ff ff       	call   8003c1 <fd_lookup>
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	89 c2                	mov    %eax,%edx
  80085a:	85 c0                	test   %eax,%eax
  80085c:	78 58                	js     8008b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800864:	50                   	push   %eax
  800865:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800868:	ff 30                	pushl  (%eax)
  80086a:	e8 a8 fb ff ff       	call   800417 <dev_lookup>
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	85 c0                	test   %eax,%eax
  800874:	78 37                	js     8008ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800879:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087d:	74 32                	je     8008b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800882:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800889:	00 00 00 
	stat->st_isdir = 0;
  80088c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800893:	00 00 00 
	stat->st_dev = dev;
  800896:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a3:	ff 50 14             	call   *0x14(%eax)
  8008a6:	89 c2                	mov    %eax,%edx
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	eb 09                	jmp    8008b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	eb 05                	jmp    8008b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b6:	89 d0                	mov    %edx,%eax
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	6a 00                	push   $0x0
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 2c 02 00 00       	call   800afb <open>
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	85 c0                	test   %eax,%eax
  8008d6:	78 1b                	js     8008f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	50                   	push   %eax
  8008df:	e8 5b ff ff ff       	call   80083f <fstat>
  8008e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e6:	89 1c 24             	mov    %ebx,(%esp)
  8008e9:	e8 fd fb ff ff       	call   8004eb <close>
	return r;
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	89 f0                	mov    %esi,%eax
}
  8008f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  800903:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090a:	75 12                	jne    80091e <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  80090c:	83 ec 0c             	sub    $0xc,%esp
  80090f:	6a 01                	push   $0x1
  800911:	e8 c0 11 00 00       	call   801ad6 <ipc_find_env>
  800916:	a3 00 40 80 00       	mov    %eax,0x804000
  80091b:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091e:	6a 07                	push   $0x7
  800920:	68 00 50 80 00       	push   $0x805000
  800925:	56                   	push   %esi
  800926:	ff 35 00 40 80 00    	pushl  0x804000
  80092c:	e8 51 11 00 00       	call   801a82 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  800931:	83 c4 0c             	add    $0xc,%esp
  800934:	6a 00                	push   $0x0
  800936:	53                   	push   %ebx
  800937:	6a 00                	push   $0x0
  800939:	e8 e5 10 00 00       	call   801a23 <ipc_recv>
}
  80093e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 40 0c             	mov    0xc(%eax),%eax
  800951:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80095e:	ba 00 00 00 00       	mov    $0x0,%edx
  800963:	b8 02 00 00 00       	mov    $0x2,%eax
  800968:	e8 8d ff ff ff       	call   8008fa <fsipc>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 40 0c             	mov    0xc(%eax),%eax
  80097b:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	b8 06 00 00 00       	mov    $0x6,%eax
  80098a:	e8 6b ff ff ff       	call   8008fa <fsipc>
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	83 ec 04             	sub    $0x4,%esp
  800998:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a1:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b0:	e8 45 ff ff ff       	call   8008fa <fsipc>
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	78 2c                	js     8009e5 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b9:	83 ec 08             	sub    $0x8,%esp
  8009bc:	68 00 50 80 00       	push   $0x805000
  8009c1:	53                   	push   %ebx
  8009c2:	e8 15 0d 00 00       	call   8016dc <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8009c7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8009dd:	83 c4 10             	add    $0x10,%esp
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	83 ec 08             	sub    $0x8,%esp
  8009f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fa:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  8009ff:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  800a05:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a0b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800a10:	0f 46 c3             	cmovbe %ebx,%eax
  800a13:	50                   	push   %eax
  800a14:	ff 75 0c             	pushl  0xc(%ebp)
  800a17:	68 08 50 80 00       	push   $0x805008
  800a1c:	e8 4d 0e 00 00       	call   80186e <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  800a21:	ba 00 00 00 00       	mov    $0x0,%edx
  800a26:	b8 04 00 00 00       	mov    $0x4,%eax
  800a2b:	e8 ca fe ff ff       	call   8008fa <fsipc>
  800a30:	83 c4 10             	add    $0x10,%esp
  800a33:	85 c0                	test   %eax,%eax
  800a35:	78 3d                	js     800a74 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  800a37:	39 c3                	cmp    %eax,%ebx
  800a39:	73 19                	jae    800a54 <devfile_write+0x6a>
  800a3b:	68 a4 1e 80 00       	push   $0x801ea4
  800a40:	68 ab 1e 80 00       	push   $0x801eab
  800a45:	68 9a 00 00 00       	push   $0x9a
  800a4a:	68 c0 1e 80 00       	push   $0x801ec0
  800a4f:	e8 2a 06 00 00       	call   80107e <_panic>
	   assert (r <= bytes_written);
  800a54:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a59:	7e 19                	jle    800a74 <devfile_write+0x8a>
  800a5b:	68 cb 1e 80 00       	push   $0x801ecb
  800a60:	68 ab 1e 80 00       	push   $0x801eab
  800a65:	68 9b 00 00 00       	push   $0x9b
  800a6a:	68 c0 1e 80 00       	push   $0x801ec0
  800a6f:	e8 0a 06 00 00       	call   80107e <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  800a74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    

00800a79 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 40 0c             	mov    0xc(%eax),%eax
  800a87:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  800a8c:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a92:	ba 00 00 00 00       	mov    $0x0,%edx
  800a97:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9c:	e8 59 fe ff ff       	call   8008fa <fsipc>
  800aa1:	89 c3                	mov    %eax,%ebx
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	78 4b                	js     800af2 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  800aa7:	39 c6                	cmp    %eax,%esi
  800aa9:	73 16                	jae    800ac1 <devfile_read+0x48>
  800aab:	68 a4 1e 80 00       	push   $0x801ea4
  800ab0:	68 ab 1e 80 00       	push   $0x801eab
  800ab5:	6a 7c                	push   $0x7c
  800ab7:	68 c0 1e 80 00       	push   $0x801ec0
  800abc:	e8 bd 05 00 00       	call   80107e <_panic>
	   assert(r <= PGSIZE);
  800ac1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac6:	7e 16                	jle    800ade <devfile_read+0x65>
  800ac8:	68 de 1e 80 00       	push   $0x801ede
  800acd:	68 ab 1e 80 00       	push   $0x801eab
  800ad2:	6a 7d                	push   $0x7d
  800ad4:	68 c0 1e 80 00       	push   $0x801ec0
  800ad9:	e8 a0 05 00 00       	call   80107e <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ade:	83 ec 04             	sub    $0x4,%esp
  800ae1:	50                   	push   %eax
  800ae2:	68 00 50 80 00       	push   $0x805000
  800ae7:	ff 75 0c             	pushl  0xc(%ebp)
  800aea:	e8 7f 0d 00 00       	call   80186e <memmove>
	   return r;
  800aef:	83 c4 10             	add    $0x10,%esp
}
  800af2:	89 d8                	mov    %ebx,%eax
  800af4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	83 ec 20             	sub    $0x20,%esp
  800b02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  800b05:	53                   	push   %ebx
  800b06:	e8 98 0b 00 00       	call   8016a3 <strlen>
  800b0b:	83 c4 10             	add    $0x10,%esp
  800b0e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b13:	7f 67                	jg     800b7c <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b15:	83 ec 0c             	sub    $0xc,%esp
  800b18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1b:	50                   	push   %eax
  800b1c:	e8 51 f8 ff ff       	call   800372 <fd_alloc>
  800b21:	83 c4 10             	add    $0x10,%esp
			 return r;
  800b24:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b26:	85 c0                	test   %eax,%eax
  800b28:	78 57                	js     800b81 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  800b2a:	83 ec 08             	sub    $0x8,%esp
  800b2d:	53                   	push   %ebx
  800b2e:	68 00 50 80 00       	push   $0x805000
  800b33:	e8 a4 0b 00 00       	call   8016dc <strcpy>
	   fsipcbuf.open.req_omode = mode;
  800b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3b:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b43:	b8 01 00 00 00       	mov    $0x1,%eax
  800b48:	e8 ad fd ff ff       	call   8008fa <fsipc>
  800b4d:	89 c3                	mov    %eax,%ebx
  800b4f:	83 c4 10             	add    $0x10,%esp
  800b52:	85 c0                	test   %eax,%eax
  800b54:	79 14                	jns    800b6a <open+0x6f>
			 fd_close(fd, 0);
  800b56:	83 ec 08             	sub    $0x8,%esp
  800b59:	6a 00                	push   $0x0
  800b5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5e:	e8 07 f9 ff ff       	call   80046a <fd_close>
			 return r;
  800b63:	83 c4 10             	add    $0x10,%esp
  800b66:	89 da                	mov    %ebx,%edx
  800b68:	eb 17                	jmp    800b81 <open+0x86>
	   }

	   return fd2num(fd);
  800b6a:	83 ec 0c             	sub    $0xc,%esp
  800b6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b70:	e8 d6 f7 ff ff       	call   80034b <fd2num>
  800b75:	89 c2                	mov    %eax,%edx
  800b77:	83 c4 10             	add    $0x10,%esp
  800b7a:	eb 05                	jmp    800b81 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  800b7c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  800b81:	89 d0                	mov    %edx,%eax
  800b83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    

00800b88 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	b8 08 00 00 00       	mov    $0x8,%eax
  800b98:	e8 5d fd ff ff       	call   8008fa <fsipc>
}
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	ff 75 08             	pushl  0x8(%ebp)
  800bad:	e8 a9 f7 ff ff       	call   80035b <fd2data>
  800bb2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bb4:	83 c4 08             	add    $0x8,%esp
  800bb7:	68 ea 1e 80 00       	push   $0x801eea
  800bbc:	53                   	push   %ebx
  800bbd:	e8 1a 0b 00 00       	call   8016dc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bc2:	8b 46 04             	mov    0x4(%esi),%eax
  800bc5:	2b 06                	sub    (%esi),%eax
  800bc7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bcd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bd4:	00 00 00 
	stat->st_dev = &devpipe;
  800bd7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bde:	30 80 00 
	return 0;
}
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf7:	53                   	push   %ebx
  800bf8:	6a 00                	push   $0x0
  800bfa:	e8 e0 f5 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bff:	89 1c 24             	mov    %ebx,(%esp)
  800c02:	e8 54 f7 ff ff       	call   80035b <fd2data>
  800c07:	83 c4 08             	add    $0x8,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 00                	push   $0x0
  800c0d:	e8 cd f5 ff ff       	call   8001df <sys_page_unmap>
}
  800c12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 1c             	sub    $0x1c,%esp
  800c20:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c23:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c25:	a1 04 40 80 00       	mov    0x804004,%eax
  800c2a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c2d:	83 ec 0c             	sub    $0xc,%esp
  800c30:	ff 75 e0             	pushl  -0x20(%ebp)
  800c33:	e8 d7 0e 00 00       	call   801b0f <pageref>
  800c38:	89 c3                	mov    %eax,%ebx
  800c3a:	89 3c 24             	mov    %edi,(%esp)
  800c3d:	e8 cd 0e 00 00       	call   801b0f <pageref>
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	39 c3                	cmp    %eax,%ebx
  800c47:	0f 94 c1             	sete   %cl
  800c4a:	0f b6 c9             	movzbl %cl,%ecx
  800c4d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c50:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c56:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c59:	39 ce                	cmp    %ecx,%esi
  800c5b:	74 1b                	je     800c78 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c5d:	39 c3                	cmp    %eax,%ebx
  800c5f:	75 c4                	jne    800c25 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c61:	8b 42 58             	mov    0x58(%edx),%eax
  800c64:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c67:	50                   	push   %eax
  800c68:	56                   	push   %esi
  800c69:	68 f1 1e 80 00       	push   $0x801ef1
  800c6e:	e8 e4 04 00 00       	call   801157 <cprintf>
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	eb ad                	jmp    800c25 <_pipeisclosed+0xe>
	}
}
  800c78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 28             	sub    $0x28,%esp
  800c8c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c8f:	56                   	push   %esi
  800c90:	e8 c6 f6 ff ff       	call   80035b <fd2data>
  800c95:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c97:	83 c4 10             	add    $0x10,%esp
  800c9a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9f:	eb 4b                	jmp    800cec <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ca1:	89 da                	mov    %ebx,%edx
  800ca3:	89 f0                	mov    %esi,%eax
  800ca5:	e8 6d ff ff ff       	call   800c17 <_pipeisclosed>
  800caa:	85 c0                	test   %eax,%eax
  800cac:	75 48                	jne    800cf6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cae:	e8 88 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cb3:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb6:	8b 0b                	mov    (%ebx),%ecx
  800cb8:	8d 51 20             	lea    0x20(%ecx),%edx
  800cbb:	39 d0                	cmp    %edx,%eax
  800cbd:	73 e2                	jae    800ca1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cc6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cc9:	89 c2                	mov    %eax,%edx
  800ccb:	c1 fa 1f             	sar    $0x1f,%edx
  800cce:	89 d1                	mov    %edx,%ecx
  800cd0:	c1 e9 1b             	shr    $0x1b,%ecx
  800cd3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cd6:	83 e2 1f             	and    $0x1f,%edx
  800cd9:	29 ca                	sub    %ecx,%edx
  800cdb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cdf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ce3:	83 c0 01             	add    $0x1,%eax
  800ce6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce9:	83 c7 01             	add    $0x1,%edi
  800cec:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cef:	75 c2                	jne    800cb3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cf1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf4:	eb 05                	jmp    800cfb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 18             	sub    $0x18,%esp
  800d0c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d0f:	57                   	push   %edi
  800d10:	e8 46 f6 ff ff       	call   80035b <fd2data>
  800d15:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d17:	83 c4 10             	add    $0x10,%esp
  800d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1f:	eb 3d                	jmp    800d5e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d21:	85 db                	test   %ebx,%ebx
  800d23:	74 04                	je     800d29 <devpipe_read+0x26>
				return i;
  800d25:	89 d8                	mov    %ebx,%eax
  800d27:	eb 44                	jmp    800d6d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d29:	89 f2                	mov    %esi,%edx
  800d2b:	89 f8                	mov    %edi,%eax
  800d2d:	e8 e5 fe ff ff       	call   800c17 <_pipeisclosed>
  800d32:	85 c0                	test   %eax,%eax
  800d34:	75 32                	jne    800d68 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d36:	e8 00 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d3b:	8b 06                	mov    (%esi),%eax
  800d3d:	3b 46 04             	cmp    0x4(%esi),%eax
  800d40:	74 df                	je     800d21 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d42:	99                   	cltd   
  800d43:	c1 ea 1b             	shr    $0x1b,%edx
  800d46:	01 d0                	add    %edx,%eax
  800d48:	83 e0 1f             	and    $0x1f,%eax
  800d4b:	29 d0                	sub    %edx,%eax
  800d4d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d55:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d58:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d5b:	83 c3 01             	add    $0x1,%ebx
  800d5e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d61:	75 d8                	jne    800d3b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d63:	8b 45 10             	mov    0x10(%ebp),%eax
  800d66:	eb 05                	jmp    800d6d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d68:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d80:	50                   	push   %eax
  800d81:	e8 ec f5 ff ff       	call   800372 <fd_alloc>
  800d86:	83 c4 10             	add    $0x10,%esp
  800d89:	89 c2                	mov    %eax,%edx
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	0f 88 2c 01 00 00    	js     800ebf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d93:	83 ec 04             	sub    $0x4,%esp
  800d96:	68 07 04 00 00       	push   $0x407
  800d9b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d9e:	6a 00                	push   $0x0
  800da0:	e8 b5 f3 ff ff       	call   80015a <sys_page_alloc>
  800da5:	83 c4 10             	add    $0x10,%esp
  800da8:	89 c2                	mov    %eax,%edx
  800daa:	85 c0                	test   %eax,%eax
  800dac:	0f 88 0d 01 00 00    	js     800ebf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db8:	50                   	push   %eax
  800db9:	e8 b4 f5 ff ff       	call   800372 <fd_alloc>
  800dbe:	89 c3                	mov    %eax,%ebx
  800dc0:	83 c4 10             	add    $0x10,%esp
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	0f 88 e2 00 00 00    	js     800ead <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcb:	83 ec 04             	sub    $0x4,%esp
  800dce:	68 07 04 00 00       	push   $0x407
  800dd3:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd6:	6a 00                	push   $0x0
  800dd8:	e8 7d f3 ff ff       	call   80015a <sys_page_alloc>
  800ddd:	89 c3                	mov    %eax,%ebx
  800ddf:	83 c4 10             	add    $0x10,%esp
  800de2:	85 c0                	test   %eax,%eax
  800de4:	0f 88 c3 00 00 00    	js     800ead <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	ff 75 f4             	pushl  -0xc(%ebp)
  800df0:	e8 66 f5 ff ff       	call   80035b <fd2data>
  800df5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df7:	83 c4 0c             	add    $0xc,%esp
  800dfa:	68 07 04 00 00       	push   $0x407
  800dff:	50                   	push   %eax
  800e00:	6a 00                	push   $0x0
  800e02:	e8 53 f3 ff ff       	call   80015a <sys_page_alloc>
  800e07:	89 c3                	mov    %eax,%ebx
  800e09:	83 c4 10             	add    $0x10,%esp
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	0f 88 89 00 00 00    	js     800e9d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	ff 75 f0             	pushl  -0x10(%ebp)
  800e1a:	e8 3c f5 ff ff       	call   80035b <fd2data>
  800e1f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e26:	50                   	push   %eax
  800e27:	6a 00                	push   $0x0
  800e29:	56                   	push   %esi
  800e2a:	6a 00                	push   $0x0
  800e2c:	e8 6c f3 ff ff       	call   80019d <sys_page_map>
  800e31:	89 c3                	mov    %eax,%ebx
  800e33:	83 c4 20             	add    $0x20,%esp
  800e36:	85 c0                	test   %eax,%eax
  800e38:	78 55                	js     800e8f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e3a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e43:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e48:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e4f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e58:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e64:	83 ec 0c             	sub    $0xc,%esp
  800e67:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6a:	e8 dc f4 ff ff       	call   80034b <fd2num>
  800e6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e72:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e74:	83 c4 04             	add    $0x4,%esp
  800e77:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7a:	e8 cc f4 ff ff       	call   80034b <fd2num>
  800e7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e82:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8d:	eb 30                	jmp    800ebf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	56                   	push   %esi
  800e93:	6a 00                	push   $0x0
  800e95:	e8 45 f3 ff ff       	call   8001df <sys_page_unmap>
  800e9a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e9d:	83 ec 08             	sub    $0x8,%esp
  800ea0:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea3:	6a 00                	push   $0x0
  800ea5:	e8 35 f3 ff ff       	call   8001df <sys_page_unmap>
  800eaa:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ead:	83 ec 08             	sub    $0x8,%esp
  800eb0:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb3:	6a 00                	push   $0x0
  800eb5:	e8 25 f3 ff ff       	call   8001df <sys_page_unmap>
  800eba:	83 c4 10             	add    $0x10,%esp
  800ebd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ebf:	89 d0                	mov    %edx,%eax
  800ec1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ece:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed1:	50                   	push   %eax
  800ed2:	ff 75 08             	pushl  0x8(%ebp)
  800ed5:	e8 e7 f4 ff ff       	call   8003c1 <fd_lookup>
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	78 18                	js     800ef9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ee1:	83 ec 0c             	sub    $0xc,%esp
  800ee4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee7:	e8 6f f4 ff ff       	call   80035b <fd2data>
	return _pipeisclosed(fd, p);
  800eec:	89 c2                	mov    %eax,%edx
  800eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef1:	e8 21 fd ff ff       	call   800c17 <_pipeisclosed>
  800ef6:	83 c4 10             	add    $0x10,%esp
}
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800efe:	b8 00 00 00 00       	mov    $0x0,%eax
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f0b:	68 09 1f 80 00       	push   $0x801f09
  800f10:	ff 75 0c             	pushl  0xc(%ebp)
  800f13:	e8 c4 07 00 00       	call   8016dc <strcpy>
	return 0;
}
  800f18:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	57                   	push   %edi
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
  800f25:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f30:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f36:	eb 2d                	jmp    800f65 <devcons_write+0x46>
		m = n - tot;
  800f38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f3d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f40:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f45:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f48:	83 ec 04             	sub    $0x4,%esp
  800f4b:	53                   	push   %ebx
  800f4c:	03 45 0c             	add    0xc(%ebp),%eax
  800f4f:	50                   	push   %eax
  800f50:	57                   	push   %edi
  800f51:	e8 18 09 00 00       	call   80186e <memmove>
		sys_cputs(buf, m);
  800f56:	83 c4 08             	add    $0x8,%esp
  800f59:	53                   	push   %ebx
  800f5a:	57                   	push   %edi
  800f5b:	e8 3e f1 ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f60:	01 de                	add    %ebx,%esi
  800f62:	83 c4 10             	add    $0x10,%esp
  800f65:	89 f0                	mov    %esi,%eax
  800f67:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f6a:	72 cc                	jb     800f38 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6f:	5b                   	pop    %ebx
  800f70:	5e                   	pop    %esi
  800f71:	5f                   	pop    %edi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	83 ec 08             	sub    $0x8,%esp
  800f7a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f7f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f83:	74 2a                	je     800faf <devcons_read+0x3b>
  800f85:	eb 05                	jmp    800f8c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f87:	e8 af f1 ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f8c:	e8 2b f1 ff ff       	call   8000bc <sys_cgetc>
  800f91:	85 c0                	test   %eax,%eax
  800f93:	74 f2                	je     800f87 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f95:	85 c0                	test   %eax,%eax
  800f97:	78 16                	js     800faf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f99:	83 f8 04             	cmp    $0x4,%eax
  800f9c:	74 0c                	je     800faa <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa1:	88 02                	mov    %al,(%edx)
	return 1;
  800fa3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa8:	eb 05                	jmp    800faf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800faa:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fba:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fbd:	6a 01                	push   $0x1
  800fbf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc2:	50                   	push   %eax
  800fc3:	e8 d6 f0 ff ff       	call   80009e <sys_cputs>
}
  800fc8:	83 c4 10             	add    $0x10,%esp
  800fcb:	c9                   	leave  
  800fcc:	c3                   	ret    

00800fcd <getchar>:

int
getchar(void)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fd3:	6a 01                	push   $0x1
  800fd5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd8:	50                   	push   %eax
  800fd9:	6a 00                	push   $0x0
  800fdb:	e8 47 f6 ff ff       	call   800627 <read>
	if (r < 0)
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	78 0f                	js     800ff6 <getchar+0x29>
		return r;
	if (r < 1)
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	7e 06                	jle    800ff1 <getchar+0x24>
		return -E_EOF;
	return c;
  800feb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fef:	eb 05                	jmp    800ff6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ff1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ffe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801001:	50                   	push   %eax
  801002:	ff 75 08             	pushl  0x8(%ebp)
  801005:	e8 b7 f3 ff ff       	call   8003c1 <fd_lookup>
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 11                	js     801022 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801014:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101a:	39 10                	cmp    %edx,(%eax)
  80101c:	0f 94 c0             	sete   %al
  80101f:	0f b6 c0             	movzbl %al,%eax
}
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <opencons>:

int
opencons(void)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80102a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102d:	50                   	push   %eax
  80102e:	e8 3f f3 ff ff       	call   800372 <fd_alloc>
  801033:	83 c4 10             	add    $0x10,%esp
		return r;
  801036:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801038:	85 c0                	test   %eax,%eax
  80103a:	78 3e                	js     80107a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80103c:	83 ec 04             	sub    $0x4,%esp
  80103f:	68 07 04 00 00       	push   $0x407
  801044:	ff 75 f4             	pushl  -0xc(%ebp)
  801047:	6a 00                	push   $0x0
  801049:	e8 0c f1 ff ff       	call   80015a <sys_page_alloc>
  80104e:	83 c4 10             	add    $0x10,%esp
		return r;
  801051:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801053:	85 c0                	test   %eax,%eax
  801055:	78 23                	js     80107a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801057:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80105d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801060:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801062:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801065:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	50                   	push   %eax
  801070:	e8 d6 f2 ff ff       	call   80034b <fd2num>
  801075:	89 c2                	mov    %eax,%edx
  801077:	83 c4 10             	add    $0x10,%esp
}
  80107a:	89 d0                	mov    %edx,%eax
  80107c:	c9                   	leave  
  80107d:	c3                   	ret    

0080107e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801083:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801086:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80108c:	e8 8b f0 ff ff       	call   80011c <sys_getenvid>
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	ff 75 0c             	pushl  0xc(%ebp)
  801097:	ff 75 08             	pushl  0x8(%ebp)
  80109a:	56                   	push   %esi
  80109b:	50                   	push   %eax
  80109c:	68 18 1f 80 00       	push   $0x801f18
  8010a1:	e8 b1 00 00 00       	call   801157 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a6:	83 c4 18             	add    $0x18,%esp
  8010a9:	53                   	push   %ebx
  8010aa:	ff 75 10             	pushl  0x10(%ebp)
  8010ad:	e8 54 00 00 00       	call   801106 <vcprintf>
	cprintf("\n");
  8010b2:	c7 04 24 02 1f 80 00 	movl   $0x801f02,(%esp)
  8010b9:	e8 99 00 00 00       	call   801157 <cprintf>
  8010be:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c1:	cc                   	int3   
  8010c2:	eb fd                	jmp    8010c1 <_panic+0x43>

008010c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	53                   	push   %ebx
  8010c8:	83 ec 04             	sub    $0x4,%esp
  8010cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010ce:	8b 13                	mov    (%ebx),%edx
  8010d0:	8d 42 01             	lea    0x1(%edx),%eax
  8010d3:	89 03                	mov    %eax,(%ebx)
  8010d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e1:	75 1a                	jne    8010fd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010e3:	83 ec 08             	sub    $0x8,%esp
  8010e6:	68 ff 00 00 00       	push   $0xff
  8010eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ee:	50                   	push   %eax
  8010ef:	e8 aa ef ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8010f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010fa:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010fd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801101:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801104:	c9                   	leave  
  801105:	c3                   	ret    

00801106 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80110f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801116:	00 00 00 
	b.cnt = 0;
  801119:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801120:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801123:	ff 75 0c             	pushl  0xc(%ebp)
  801126:	ff 75 08             	pushl  0x8(%ebp)
  801129:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80112f:	50                   	push   %eax
  801130:	68 c4 10 80 00       	push   $0x8010c4
  801135:	e8 54 01 00 00       	call   80128e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80113a:	83 c4 08             	add    $0x8,%esp
  80113d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801143:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801149:	50                   	push   %eax
  80114a:	e8 4f ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  80114f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80115d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801160:	50                   	push   %eax
  801161:	ff 75 08             	pushl  0x8(%ebp)
  801164:	e8 9d ff ff ff       	call   801106 <vcprintf>
	va_end(ap);

	return cnt;
}
  801169:	c9                   	leave  
  80116a:	c3                   	ret    

0080116b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	57                   	push   %edi
  80116f:	56                   	push   %esi
  801170:	53                   	push   %ebx
  801171:	83 ec 1c             	sub    $0x1c,%esp
  801174:	89 c7                	mov    %eax,%edi
  801176:	89 d6                	mov    %edx,%esi
  801178:	8b 45 08             	mov    0x8(%ebp),%eax
  80117b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801181:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801184:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801187:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80118f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801192:	39 d3                	cmp    %edx,%ebx
  801194:	72 05                	jb     80119b <printnum+0x30>
  801196:	39 45 10             	cmp    %eax,0x10(%ebp)
  801199:	77 45                	ja     8011e0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80119b:	83 ec 0c             	sub    $0xc,%esp
  80119e:	ff 75 18             	pushl  0x18(%ebp)
  8011a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8011a4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011a7:	53                   	push   %ebx
  8011a8:	ff 75 10             	pushl  0x10(%ebp)
  8011ab:	83 ec 08             	sub    $0x8,%esp
  8011ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ba:	e8 91 09 00 00       	call   801b50 <__udivdi3>
  8011bf:	83 c4 18             	add    $0x18,%esp
  8011c2:	52                   	push   %edx
  8011c3:	50                   	push   %eax
  8011c4:	89 f2                	mov    %esi,%edx
  8011c6:	89 f8                	mov    %edi,%eax
  8011c8:	e8 9e ff ff ff       	call   80116b <printnum>
  8011cd:	83 c4 20             	add    $0x20,%esp
  8011d0:	eb 18                	jmp    8011ea <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	56                   	push   %esi
  8011d6:	ff 75 18             	pushl  0x18(%ebp)
  8011d9:	ff d7                	call   *%edi
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	eb 03                	jmp    8011e3 <printnum+0x78>
  8011e0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011e3:	83 eb 01             	sub    $0x1,%ebx
  8011e6:	85 db                	test   %ebx,%ebx
  8011e8:	7f e8                	jg     8011d2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	56                   	push   %esi
  8011ee:	83 ec 04             	sub    $0x4,%esp
  8011f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f7:	ff 75 dc             	pushl  -0x24(%ebp)
  8011fa:	ff 75 d8             	pushl  -0x28(%ebp)
  8011fd:	e8 7e 0a 00 00       	call   801c80 <__umoddi3>
  801202:	83 c4 14             	add    $0x14,%esp
  801205:	0f be 80 3b 1f 80 00 	movsbl 0x801f3b(%eax),%eax
  80120c:	50                   	push   %eax
  80120d:	ff d7                	call   *%edi
}
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801215:	5b                   	pop    %ebx
  801216:	5e                   	pop    %esi
  801217:	5f                   	pop    %edi
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80121d:	83 fa 01             	cmp    $0x1,%edx
  801220:	7e 0e                	jle    801230 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801222:	8b 10                	mov    (%eax),%edx
  801224:	8d 4a 08             	lea    0x8(%edx),%ecx
  801227:	89 08                	mov    %ecx,(%eax)
  801229:	8b 02                	mov    (%edx),%eax
  80122b:	8b 52 04             	mov    0x4(%edx),%edx
  80122e:	eb 22                	jmp    801252 <getuint+0x38>
	else if (lflag)
  801230:	85 d2                	test   %edx,%edx
  801232:	74 10                	je     801244 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801234:	8b 10                	mov    (%eax),%edx
  801236:	8d 4a 04             	lea    0x4(%edx),%ecx
  801239:	89 08                	mov    %ecx,(%eax)
  80123b:	8b 02                	mov    (%edx),%eax
  80123d:	ba 00 00 00 00       	mov    $0x0,%edx
  801242:	eb 0e                	jmp    801252 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801244:	8b 10                	mov    (%eax),%edx
  801246:	8d 4a 04             	lea    0x4(%edx),%ecx
  801249:	89 08                	mov    %ecx,(%eax)
  80124b:	8b 02                	mov    (%edx),%eax
  80124d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80125a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80125e:	8b 10                	mov    (%eax),%edx
  801260:	3b 50 04             	cmp    0x4(%eax),%edx
  801263:	73 0a                	jae    80126f <sprintputch+0x1b>
		*b->buf++ = ch;
  801265:	8d 4a 01             	lea    0x1(%edx),%ecx
  801268:	89 08                	mov    %ecx,(%eax)
  80126a:	8b 45 08             	mov    0x8(%ebp),%eax
  80126d:	88 02                	mov    %al,(%edx)
}
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801277:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80127a:	50                   	push   %eax
  80127b:	ff 75 10             	pushl  0x10(%ebp)
  80127e:	ff 75 0c             	pushl  0xc(%ebp)
  801281:	ff 75 08             	pushl  0x8(%ebp)
  801284:	e8 05 00 00 00       	call   80128e <vprintfmt>
	va_end(ap);
}
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	c9                   	leave  
  80128d:	c3                   	ret    

0080128e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	57                   	push   %edi
  801292:	56                   	push   %esi
  801293:	53                   	push   %ebx
  801294:	83 ec 2c             	sub    $0x2c,%esp
  801297:	8b 75 08             	mov    0x8(%ebp),%esi
  80129a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80129d:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a0:	eb 12                	jmp    8012b4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	0f 84 89 03 00 00    	je     801633 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	53                   	push   %ebx
  8012ae:	50                   	push   %eax
  8012af:	ff d6                	call   *%esi
  8012b1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012b4:	83 c7 01             	add    $0x1,%edi
  8012b7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012bb:	83 f8 25             	cmp    $0x25,%eax
  8012be:	75 e2                	jne    8012a2 <vprintfmt+0x14>
  8012c0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012c4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012d2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012de:	eb 07                	jmp    8012e7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012e3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e7:	8d 47 01             	lea    0x1(%edi),%eax
  8012ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ed:	0f b6 07             	movzbl (%edi),%eax
  8012f0:	0f b6 c8             	movzbl %al,%ecx
  8012f3:	83 e8 23             	sub    $0x23,%eax
  8012f6:	3c 55                	cmp    $0x55,%al
  8012f8:	0f 87 1a 03 00 00    	ja     801618 <vprintfmt+0x38a>
  8012fe:	0f b6 c0             	movzbl %al,%eax
  801301:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  801308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80130b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80130f:	eb d6                	jmp    8012e7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801314:	b8 00 00 00 00       	mov    $0x0,%eax
  801319:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80131c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80131f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801323:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801326:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801329:	83 fa 09             	cmp    $0x9,%edx
  80132c:	77 39                	ja     801367 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80132e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801331:	eb e9                	jmp    80131c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801333:	8b 45 14             	mov    0x14(%ebp),%eax
  801336:	8d 48 04             	lea    0x4(%eax),%ecx
  801339:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80133c:	8b 00                	mov    (%eax),%eax
  80133e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801344:	eb 27                	jmp    80136d <vprintfmt+0xdf>
  801346:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801349:	85 c0                	test   %eax,%eax
  80134b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801350:	0f 49 c8             	cmovns %eax,%ecx
  801353:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801359:	eb 8c                	jmp    8012e7 <vprintfmt+0x59>
  80135b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80135e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801365:	eb 80                	jmp    8012e7 <vprintfmt+0x59>
  801367:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80136a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80136d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801371:	0f 89 70 ff ff ff    	jns    8012e7 <vprintfmt+0x59>
				width = precision, precision = -1;
  801377:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80137a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80137d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801384:	e9 5e ff ff ff       	jmp    8012e7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801389:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80138f:	e9 53 ff ff ff       	jmp    8012e7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801394:	8b 45 14             	mov    0x14(%ebp),%eax
  801397:	8d 50 04             	lea    0x4(%eax),%edx
  80139a:	89 55 14             	mov    %edx,0x14(%ebp)
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	53                   	push   %ebx
  8013a1:	ff 30                	pushl  (%eax)
  8013a3:	ff d6                	call   *%esi
			break;
  8013a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013ab:	e9 04 ff ff ff       	jmp    8012b4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b3:	8d 50 04             	lea    0x4(%eax),%edx
  8013b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b9:	8b 00                	mov    (%eax),%eax
  8013bb:	99                   	cltd   
  8013bc:	31 d0                	xor    %edx,%eax
  8013be:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013c0:	83 f8 0f             	cmp    $0xf,%eax
  8013c3:	7f 0b                	jg     8013d0 <vprintfmt+0x142>
  8013c5:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013cc:	85 d2                	test   %edx,%edx
  8013ce:	75 18                	jne    8013e8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013d0:	50                   	push   %eax
  8013d1:	68 53 1f 80 00       	push   $0x801f53
  8013d6:	53                   	push   %ebx
  8013d7:	56                   	push   %esi
  8013d8:	e8 94 fe ff ff       	call   801271 <printfmt>
  8013dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013e3:	e9 cc fe ff ff       	jmp    8012b4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013e8:	52                   	push   %edx
  8013e9:	68 bd 1e 80 00       	push   $0x801ebd
  8013ee:	53                   	push   %ebx
  8013ef:	56                   	push   %esi
  8013f0:	e8 7c fe ff ff       	call   801271 <printfmt>
  8013f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013fb:	e9 b4 fe ff ff       	jmp    8012b4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801400:	8b 45 14             	mov    0x14(%ebp),%eax
  801403:	8d 50 04             	lea    0x4(%eax),%edx
  801406:	89 55 14             	mov    %edx,0x14(%ebp)
  801409:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80140b:	85 ff                	test   %edi,%edi
  80140d:	b8 4c 1f 80 00       	mov    $0x801f4c,%eax
  801412:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801415:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801419:	0f 8e 94 00 00 00    	jle    8014b3 <vprintfmt+0x225>
  80141f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801423:	0f 84 98 00 00 00    	je     8014c1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801429:	83 ec 08             	sub    $0x8,%esp
  80142c:	ff 75 d0             	pushl  -0x30(%ebp)
  80142f:	57                   	push   %edi
  801430:	e8 86 02 00 00       	call   8016bb <strnlen>
  801435:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801438:	29 c1                	sub    %eax,%ecx
  80143a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80143d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801440:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801444:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801447:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80144a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80144c:	eb 0f                	jmp    80145d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80144e:	83 ec 08             	sub    $0x8,%esp
  801451:	53                   	push   %ebx
  801452:	ff 75 e0             	pushl  -0x20(%ebp)
  801455:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801457:	83 ef 01             	sub    $0x1,%edi
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	85 ff                	test   %edi,%edi
  80145f:	7f ed                	jg     80144e <vprintfmt+0x1c0>
  801461:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801464:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801467:	85 c9                	test   %ecx,%ecx
  801469:	b8 00 00 00 00       	mov    $0x0,%eax
  80146e:	0f 49 c1             	cmovns %ecx,%eax
  801471:	29 c1                	sub    %eax,%ecx
  801473:	89 75 08             	mov    %esi,0x8(%ebp)
  801476:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801479:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147c:	89 cb                	mov    %ecx,%ebx
  80147e:	eb 4d                	jmp    8014cd <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801480:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801484:	74 1b                	je     8014a1 <vprintfmt+0x213>
  801486:	0f be c0             	movsbl %al,%eax
  801489:	83 e8 20             	sub    $0x20,%eax
  80148c:	83 f8 5e             	cmp    $0x5e,%eax
  80148f:	76 10                	jbe    8014a1 <vprintfmt+0x213>
					putch('?', putdat);
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	ff 75 0c             	pushl  0xc(%ebp)
  801497:	6a 3f                	push   $0x3f
  801499:	ff 55 08             	call   *0x8(%ebp)
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	eb 0d                	jmp    8014ae <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	ff 75 0c             	pushl  0xc(%ebp)
  8014a7:	52                   	push   %edx
  8014a8:	ff 55 08             	call   *0x8(%ebp)
  8014ab:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014ae:	83 eb 01             	sub    $0x1,%ebx
  8014b1:	eb 1a                	jmp    8014cd <vprintfmt+0x23f>
  8014b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014bf:	eb 0c                	jmp    8014cd <vprintfmt+0x23f>
  8014c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8014c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014cd:	83 c7 01             	add    $0x1,%edi
  8014d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014d4:	0f be d0             	movsbl %al,%edx
  8014d7:	85 d2                	test   %edx,%edx
  8014d9:	74 23                	je     8014fe <vprintfmt+0x270>
  8014db:	85 f6                	test   %esi,%esi
  8014dd:	78 a1                	js     801480 <vprintfmt+0x1f2>
  8014df:	83 ee 01             	sub    $0x1,%esi
  8014e2:	79 9c                	jns    801480 <vprintfmt+0x1f2>
  8014e4:	89 df                	mov    %ebx,%edi
  8014e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014ec:	eb 18                	jmp    801506 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	53                   	push   %ebx
  8014f2:	6a 20                	push   $0x20
  8014f4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014f6:	83 ef 01             	sub    $0x1,%edi
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	eb 08                	jmp    801506 <vprintfmt+0x278>
  8014fe:	89 df                	mov    %ebx,%edi
  801500:	8b 75 08             	mov    0x8(%ebp),%esi
  801503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801506:	85 ff                	test   %edi,%edi
  801508:	7f e4                	jg     8014ee <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80150a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80150d:	e9 a2 fd ff ff       	jmp    8012b4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801512:	83 fa 01             	cmp    $0x1,%edx
  801515:	7e 16                	jle    80152d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801517:	8b 45 14             	mov    0x14(%ebp),%eax
  80151a:	8d 50 08             	lea    0x8(%eax),%edx
  80151d:	89 55 14             	mov    %edx,0x14(%ebp)
  801520:	8b 50 04             	mov    0x4(%eax),%edx
  801523:	8b 00                	mov    (%eax),%eax
  801525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801528:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80152b:	eb 32                	jmp    80155f <vprintfmt+0x2d1>
	else if (lflag)
  80152d:	85 d2                	test   %edx,%edx
  80152f:	74 18                	je     801549 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801531:	8b 45 14             	mov    0x14(%ebp),%eax
  801534:	8d 50 04             	lea    0x4(%eax),%edx
  801537:	89 55 14             	mov    %edx,0x14(%ebp)
  80153a:	8b 00                	mov    (%eax),%eax
  80153c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153f:	89 c1                	mov    %eax,%ecx
  801541:	c1 f9 1f             	sar    $0x1f,%ecx
  801544:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801547:	eb 16                	jmp    80155f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801549:	8b 45 14             	mov    0x14(%ebp),%eax
  80154c:	8d 50 04             	lea    0x4(%eax),%edx
  80154f:	89 55 14             	mov    %edx,0x14(%ebp)
  801552:	8b 00                	mov    (%eax),%eax
  801554:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801557:	89 c1                	mov    %eax,%ecx
  801559:	c1 f9 1f             	sar    $0x1f,%ecx
  80155c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80155f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801562:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801565:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80156a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80156e:	79 74                	jns    8015e4 <vprintfmt+0x356>
				putch('-', putdat);
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	53                   	push   %ebx
  801574:	6a 2d                	push   $0x2d
  801576:	ff d6                	call   *%esi
				num = -(long long) num;
  801578:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80157b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80157e:	f7 d8                	neg    %eax
  801580:	83 d2 00             	adc    $0x0,%edx
  801583:	f7 da                	neg    %edx
  801585:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801588:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80158d:	eb 55                	jmp    8015e4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80158f:	8d 45 14             	lea    0x14(%ebp),%eax
  801592:	e8 83 fc ff ff       	call   80121a <getuint>
			base = 10;
  801597:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80159c:	eb 46                	jmp    8015e4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80159e:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a1:	e8 74 fc ff ff       	call   80121a <getuint>
			base = 8;
  8015a6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015ab:	eb 37                	jmp    8015e4 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	53                   	push   %ebx
  8015b1:	6a 30                	push   $0x30
  8015b3:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b5:	83 c4 08             	add    $0x8,%esp
  8015b8:	53                   	push   %ebx
  8015b9:	6a 78                	push   $0x78
  8015bb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c0:	8d 50 04             	lea    0x4(%eax),%edx
  8015c3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015c6:	8b 00                	mov    (%eax),%eax
  8015c8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015cd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015d0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015d5:	eb 0d                	jmp    8015e4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015da:	e8 3b fc ff ff       	call   80121a <getuint>
			base = 16;
  8015df:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015e4:	83 ec 0c             	sub    $0xc,%esp
  8015e7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015eb:	57                   	push   %edi
  8015ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ef:	51                   	push   %ecx
  8015f0:	52                   	push   %edx
  8015f1:	50                   	push   %eax
  8015f2:	89 da                	mov    %ebx,%edx
  8015f4:	89 f0                	mov    %esi,%eax
  8015f6:	e8 70 fb ff ff       	call   80116b <printnum>
			break;
  8015fb:	83 c4 20             	add    $0x20,%esp
  8015fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801601:	e9 ae fc ff ff       	jmp    8012b4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	53                   	push   %ebx
  80160a:	51                   	push   %ecx
  80160b:	ff d6                	call   *%esi
			break;
  80160d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801610:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801613:	e9 9c fc ff ff       	jmp    8012b4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	53                   	push   %ebx
  80161c:	6a 25                	push   $0x25
  80161e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	eb 03                	jmp    801628 <vprintfmt+0x39a>
  801625:	83 ef 01             	sub    $0x1,%edi
  801628:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80162c:	75 f7                	jne    801625 <vprintfmt+0x397>
  80162e:	e9 81 fc ff ff       	jmp    8012b4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801633:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801636:	5b                   	pop    %ebx
  801637:	5e                   	pop    %esi
  801638:	5f                   	pop    %edi
  801639:	5d                   	pop    %ebp
  80163a:	c3                   	ret    

0080163b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	83 ec 18             	sub    $0x18,%esp
  801641:	8b 45 08             	mov    0x8(%ebp),%eax
  801644:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801647:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80164a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80164e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801651:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801658:	85 c0                	test   %eax,%eax
  80165a:	74 26                	je     801682 <vsnprintf+0x47>
  80165c:	85 d2                	test   %edx,%edx
  80165e:	7e 22                	jle    801682 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801660:	ff 75 14             	pushl  0x14(%ebp)
  801663:	ff 75 10             	pushl  0x10(%ebp)
  801666:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	68 54 12 80 00       	push   $0x801254
  80166f:	e8 1a fc ff ff       	call   80128e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801674:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801677:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80167a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	eb 05                	jmp    801687 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801682:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801687:	c9                   	leave  
  801688:	c3                   	ret    

00801689 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80168f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801692:	50                   	push   %eax
  801693:	ff 75 10             	pushl  0x10(%ebp)
  801696:	ff 75 0c             	pushl  0xc(%ebp)
  801699:	ff 75 08             	pushl  0x8(%ebp)
  80169c:	e8 9a ff ff ff       	call   80163b <vsnprintf>
	va_end(ap);

	return rc;
}
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ae:	eb 03                	jmp    8016b3 <strlen+0x10>
		n++;
  8016b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016b7:	75 f7                	jne    8016b0 <strlen+0xd>
		n++;
	return n;
}
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c9:	eb 03                	jmp    8016ce <strnlen+0x13>
		n++;
  8016cb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ce:	39 c2                	cmp    %eax,%edx
  8016d0:	74 08                	je     8016da <strnlen+0x1f>
  8016d2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016d6:	75 f3                	jne    8016cb <strnlen+0x10>
  8016d8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	53                   	push   %ebx
  8016e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e6:	89 c2                	mov    %eax,%edx
  8016e8:	83 c2 01             	add    $0x1,%edx
  8016eb:	83 c1 01             	add    $0x1,%ecx
  8016ee:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016f2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016f5:	84 db                	test   %bl,%bl
  8016f7:	75 ef                	jne    8016e8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016f9:	5b                   	pop    %ebx
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	53                   	push   %ebx
  801700:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801703:	53                   	push   %ebx
  801704:	e8 9a ff ff ff       	call   8016a3 <strlen>
  801709:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80170c:	ff 75 0c             	pushl  0xc(%ebp)
  80170f:	01 d8                	add    %ebx,%eax
  801711:	50                   	push   %eax
  801712:	e8 c5 ff ff ff       	call   8016dc <strcpy>
	return dst;
}
  801717:	89 d8                	mov    %ebx,%eax
  801719:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171c:	c9                   	leave  
  80171d:	c3                   	ret    

0080171e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	8b 75 08             	mov    0x8(%ebp),%esi
  801726:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801729:	89 f3                	mov    %esi,%ebx
  80172b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80172e:	89 f2                	mov    %esi,%edx
  801730:	eb 0f                	jmp    801741 <strncpy+0x23>
		*dst++ = *src;
  801732:	83 c2 01             	add    $0x1,%edx
  801735:	0f b6 01             	movzbl (%ecx),%eax
  801738:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80173b:	80 39 01             	cmpb   $0x1,(%ecx)
  80173e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801741:	39 da                	cmp    %ebx,%edx
  801743:	75 ed                	jne    801732 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801745:	89 f0                	mov    %esi,%eax
  801747:	5b                   	pop    %ebx
  801748:	5e                   	pop    %esi
  801749:	5d                   	pop    %ebp
  80174a:	c3                   	ret    

0080174b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
  801750:	8b 75 08             	mov    0x8(%ebp),%esi
  801753:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801756:	8b 55 10             	mov    0x10(%ebp),%edx
  801759:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80175b:	85 d2                	test   %edx,%edx
  80175d:	74 21                	je     801780 <strlcpy+0x35>
  80175f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801763:	89 f2                	mov    %esi,%edx
  801765:	eb 09                	jmp    801770 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801767:	83 c2 01             	add    $0x1,%edx
  80176a:	83 c1 01             	add    $0x1,%ecx
  80176d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801770:	39 c2                	cmp    %eax,%edx
  801772:	74 09                	je     80177d <strlcpy+0x32>
  801774:	0f b6 19             	movzbl (%ecx),%ebx
  801777:	84 db                	test   %bl,%bl
  801779:	75 ec                	jne    801767 <strlcpy+0x1c>
  80177b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80177d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801780:	29 f0                	sub    %esi,%eax
}
  801782:	5b                   	pop    %ebx
  801783:	5e                   	pop    %esi
  801784:	5d                   	pop    %ebp
  801785:	c3                   	ret    

00801786 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80178f:	eb 06                	jmp    801797 <strcmp+0x11>
		p++, q++;
  801791:	83 c1 01             	add    $0x1,%ecx
  801794:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801797:	0f b6 01             	movzbl (%ecx),%eax
  80179a:	84 c0                	test   %al,%al
  80179c:	74 04                	je     8017a2 <strcmp+0x1c>
  80179e:	3a 02                	cmp    (%edx),%al
  8017a0:	74 ef                	je     801791 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a2:	0f b6 c0             	movzbl %al,%eax
  8017a5:	0f b6 12             	movzbl (%edx),%edx
  8017a8:	29 d0                	sub    %edx,%eax
}
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	53                   	push   %ebx
  8017b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b6:	89 c3                	mov    %eax,%ebx
  8017b8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017bb:	eb 06                	jmp    8017c3 <strncmp+0x17>
		n--, p++, q++;
  8017bd:	83 c0 01             	add    $0x1,%eax
  8017c0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017c3:	39 d8                	cmp    %ebx,%eax
  8017c5:	74 15                	je     8017dc <strncmp+0x30>
  8017c7:	0f b6 08             	movzbl (%eax),%ecx
  8017ca:	84 c9                	test   %cl,%cl
  8017cc:	74 04                	je     8017d2 <strncmp+0x26>
  8017ce:	3a 0a                	cmp    (%edx),%cl
  8017d0:	74 eb                	je     8017bd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d2:	0f b6 00             	movzbl (%eax),%eax
  8017d5:	0f b6 12             	movzbl (%edx),%edx
  8017d8:	29 d0                	sub    %edx,%eax
  8017da:	eb 05                	jmp    8017e1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017dc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017e1:	5b                   	pop    %ebx
  8017e2:	5d                   	pop    %ebp
  8017e3:	c3                   	ret    

008017e4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ee:	eb 07                	jmp    8017f7 <strchr+0x13>
		if (*s == c)
  8017f0:	38 ca                	cmp    %cl,%dl
  8017f2:	74 0f                	je     801803 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017f4:	83 c0 01             	add    $0x1,%eax
  8017f7:	0f b6 10             	movzbl (%eax),%edx
  8017fa:	84 d2                	test   %dl,%dl
  8017fc:	75 f2                	jne    8017f0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	8b 45 08             	mov    0x8(%ebp),%eax
  80180b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180f:	eb 03                	jmp    801814 <strfind+0xf>
  801811:	83 c0 01             	add    $0x1,%eax
  801814:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801817:	38 ca                	cmp    %cl,%dl
  801819:	74 04                	je     80181f <strfind+0x1a>
  80181b:	84 d2                	test   %dl,%dl
  80181d:	75 f2                	jne    801811 <strfind+0xc>
			break;
	return (char *) s;
}
  80181f:	5d                   	pop    %ebp
  801820:	c3                   	ret    

00801821 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	57                   	push   %edi
  801825:	56                   	push   %esi
  801826:	53                   	push   %ebx
  801827:	8b 7d 08             	mov    0x8(%ebp),%edi
  80182a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80182d:	85 c9                	test   %ecx,%ecx
  80182f:	74 36                	je     801867 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801831:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801837:	75 28                	jne    801861 <memset+0x40>
  801839:	f6 c1 03             	test   $0x3,%cl
  80183c:	75 23                	jne    801861 <memset+0x40>
		c &= 0xFF;
  80183e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801842:	89 d3                	mov    %edx,%ebx
  801844:	c1 e3 08             	shl    $0x8,%ebx
  801847:	89 d6                	mov    %edx,%esi
  801849:	c1 e6 18             	shl    $0x18,%esi
  80184c:	89 d0                	mov    %edx,%eax
  80184e:	c1 e0 10             	shl    $0x10,%eax
  801851:	09 f0                	or     %esi,%eax
  801853:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801855:	89 d8                	mov    %ebx,%eax
  801857:	09 d0                	or     %edx,%eax
  801859:	c1 e9 02             	shr    $0x2,%ecx
  80185c:	fc                   	cld    
  80185d:	f3 ab                	rep stos %eax,%es:(%edi)
  80185f:	eb 06                	jmp    801867 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801861:	8b 45 0c             	mov    0xc(%ebp),%eax
  801864:	fc                   	cld    
  801865:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801867:	89 f8                	mov    %edi,%eax
  801869:	5b                   	pop    %ebx
  80186a:	5e                   	pop    %esi
  80186b:	5f                   	pop    %edi
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    

0080186e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	57                   	push   %edi
  801872:	56                   	push   %esi
  801873:	8b 45 08             	mov    0x8(%ebp),%eax
  801876:	8b 75 0c             	mov    0xc(%ebp),%esi
  801879:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80187c:	39 c6                	cmp    %eax,%esi
  80187e:	73 35                	jae    8018b5 <memmove+0x47>
  801880:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801883:	39 d0                	cmp    %edx,%eax
  801885:	73 2e                	jae    8018b5 <memmove+0x47>
		s += n;
		d += n;
  801887:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188a:	89 d6                	mov    %edx,%esi
  80188c:	09 fe                	or     %edi,%esi
  80188e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801894:	75 13                	jne    8018a9 <memmove+0x3b>
  801896:	f6 c1 03             	test   $0x3,%cl
  801899:	75 0e                	jne    8018a9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80189b:	83 ef 04             	sub    $0x4,%edi
  80189e:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a1:	c1 e9 02             	shr    $0x2,%ecx
  8018a4:	fd                   	std    
  8018a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a7:	eb 09                	jmp    8018b2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018a9:	83 ef 01             	sub    $0x1,%edi
  8018ac:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018af:	fd                   	std    
  8018b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b2:	fc                   	cld    
  8018b3:	eb 1d                	jmp    8018d2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b5:	89 f2                	mov    %esi,%edx
  8018b7:	09 c2                	or     %eax,%edx
  8018b9:	f6 c2 03             	test   $0x3,%dl
  8018bc:	75 0f                	jne    8018cd <memmove+0x5f>
  8018be:	f6 c1 03             	test   $0x3,%cl
  8018c1:	75 0a                	jne    8018cd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018c3:	c1 e9 02             	shr    $0x2,%ecx
  8018c6:	89 c7                	mov    %eax,%edi
  8018c8:	fc                   	cld    
  8018c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018cb:	eb 05                	jmp    8018d2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018cd:	89 c7                	mov    %eax,%edi
  8018cf:	fc                   	cld    
  8018d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d2:	5e                   	pop    %esi
  8018d3:	5f                   	pop    %edi
  8018d4:	5d                   	pop    %ebp
  8018d5:	c3                   	ret    

008018d6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d9:	ff 75 10             	pushl  0x10(%ebp)
  8018dc:	ff 75 0c             	pushl  0xc(%ebp)
  8018df:	ff 75 08             	pushl  0x8(%ebp)
  8018e2:	e8 87 ff ff ff       	call   80186e <memmove>
}
  8018e7:	c9                   	leave  
  8018e8:	c3                   	ret    

008018e9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	56                   	push   %esi
  8018ed:	53                   	push   %ebx
  8018ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f4:	89 c6                	mov    %eax,%esi
  8018f6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f9:	eb 1a                	jmp    801915 <memcmp+0x2c>
		if (*s1 != *s2)
  8018fb:	0f b6 08             	movzbl (%eax),%ecx
  8018fe:	0f b6 1a             	movzbl (%edx),%ebx
  801901:	38 d9                	cmp    %bl,%cl
  801903:	74 0a                	je     80190f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801905:	0f b6 c1             	movzbl %cl,%eax
  801908:	0f b6 db             	movzbl %bl,%ebx
  80190b:	29 d8                	sub    %ebx,%eax
  80190d:	eb 0f                	jmp    80191e <memcmp+0x35>
		s1++, s2++;
  80190f:	83 c0 01             	add    $0x1,%eax
  801912:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801915:	39 f0                	cmp    %esi,%eax
  801917:	75 e2                	jne    8018fb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191e:	5b                   	pop    %ebx
  80191f:	5e                   	pop    %esi
  801920:	5d                   	pop    %ebp
  801921:	c3                   	ret    

00801922 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	53                   	push   %ebx
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801929:	89 c1                	mov    %eax,%ecx
  80192b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80192e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801932:	eb 0a                	jmp    80193e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801934:	0f b6 10             	movzbl (%eax),%edx
  801937:	39 da                	cmp    %ebx,%edx
  801939:	74 07                	je     801942 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80193b:	83 c0 01             	add    $0x1,%eax
  80193e:	39 c8                	cmp    %ecx,%eax
  801940:	72 f2                	jb     801934 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801942:	5b                   	pop    %ebx
  801943:	5d                   	pop    %ebp
  801944:	c3                   	ret    

00801945 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	57                   	push   %edi
  801949:	56                   	push   %esi
  80194a:	53                   	push   %ebx
  80194b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801951:	eb 03                	jmp    801956 <strtol+0x11>
		s++;
  801953:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801956:	0f b6 01             	movzbl (%ecx),%eax
  801959:	3c 20                	cmp    $0x20,%al
  80195b:	74 f6                	je     801953 <strtol+0xe>
  80195d:	3c 09                	cmp    $0x9,%al
  80195f:	74 f2                	je     801953 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801961:	3c 2b                	cmp    $0x2b,%al
  801963:	75 0a                	jne    80196f <strtol+0x2a>
		s++;
  801965:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801968:	bf 00 00 00 00       	mov    $0x0,%edi
  80196d:	eb 11                	jmp    801980 <strtol+0x3b>
  80196f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801974:	3c 2d                	cmp    $0x2d,%al
  801976:	75 08                	jne    801980 <strtol+0x3b>
		s++, neg = 1;
  801978:	83 c1 01             	add    $0x1,%ecx
  80197b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801980:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801986:	75 15                	jne    80199d <strtol+0x58>
  801988:	80 39 30             	cmpb   $0x30,(%ecx)
  80198b:	75 10                	jne    80199d <strtol+0x58>
  80198d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801991:	75 7c                	jne    801a0f <strtol+0xca>
		s += 2, base = 16;
  801993:	83 c1 02             	add    $0x2,%ecx
  801996:	bb 10 00 00 00       	mov    $0x10,%ebx
  80199b:	eb 16                	jmp    8019b3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80199d:	85 db                	test   %ebx,%ebx
  80199f:	75 12                	jne    8019b3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a6:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a9:	75 08                	jne    8019b3 <strtol+0x6e>
		s++, base = 8;
  8019ab:	83 c1 01             	add    $0x1,%ecx
  8019ae:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019bb:	0f b6 11             	movzbl (%ecx),%edx
  8019be:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c1:	89 f3                	mov    %esi,%ebx
  8019c3:	80 fb 09             	cmp    $0x9,%bl
  8019c6:	77 08                	ja     8019d0 <strtol+0x8b>
			dig = *s - '0';
  8019c8:	0f be d2             	movsbl %dl,%edx
  8019cb:	83 ea 30             	sub    $0x30,%edx
  8019ce:	eb 22                	jmp    8019f2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019d0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d3:	89 f3                	mov    %esi,%ebx
  8019d5:	80 fb 19             	cmp    $0x19,%bl
  8019d8:	77 08                	ja     8019e2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019da:	0f be d2             	movsbl %dl,%edx
  8019dd:	83 ea 57             	sub    $0x57,%edx
  8019e0:	eb 10                	jmp    8019f2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019e2:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019e5:	89 f3                	mov    %esi,%ebx
  8019e7:	80 fb 19             	cmp    $0x19,%bl
  8019ea:	77 16                	ja     801a02 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019ec:	0f be d2             	movsbl %dl,%edx
  8019ef:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019f2:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f5:	7d 0b                	jge    801a02 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019f7:	83 c1 01             	add    $0x1,%ecx
  8019fa:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019fe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a00:	eb b9                	jmp    8019bb <strtol+0x76>

	if (endptr)
  801a02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a06:	74 0d                	je     801a15 <strtol+0xd0>
		*endptr = (char *) s;
  801a08:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a0b:	89 0e                	mov    %ecx,(%esi)
  801a0d:	eb 06                	jmp    801a15 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a0f:	85 db                	test   %ebx,%ebx
  801a11:	74 98                	je     8019ab <strtol+0x66>
  801a13:	eb 9e                	jmp    8019b3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a15:	89 c2                	mov    %eax,%edx
  801a17:	f7 da                	neg    %edx
  801a19:	85 ff                	test   %edi,%edi
  801a1b:	0f 45 c2             	cmovne %edx,%eax
}
  801a1e:	5b                   	pop    %ebx
  801a1f:	5e                   	pop    %esi
  801a20:	5f                   	pop    %edi
  801a21:	5d                   	pop    %ebp
  801a22:	c3                   	ret    

00801a23 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	56                   	push   %esi
  801a27:	53                   	push   %ebx
  801a28:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801a31:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801a33:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a38:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	50                   	push   %eax
  801a3f:	e8 c6 e8 ff ff       	call   80030a <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	85 c0                	test   %eax,%eax
  801a49:	78 0e                	js     801a59 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801a4b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a51:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801a54:	8b 52 78             	mov    0x78(%edx),%edx
  801a57:	eb 0a                	jmp    801a63 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801a59:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801a5e:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801a63:	85 f6                	test   %esi,%esi
  801a65:	74 02                	je     801a69 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801a67:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801a69:	85 db                	test   %ebx,%ebx
  801a6b:	74 02                	je     801a6f <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801a6d:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	78 08                	js     801a7b <ipc_recv+0x58>
  801a73:	a1 04 40 80 00       	mov    0x804004,%eax
  801a78:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801a7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7e:	5b                   	pop    %ebx
  801a7f:	5e                   	pop    %esi
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	57                   	push   %edi
  801a86:	56                   	push   %esi
  801a87:	53                   	push   %ebx
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801a94:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801a96:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801a9b:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801a9e:	ff 75 14             	pushl  0x14(%ebp)
  801aa1:	53                   	push   %ebx
  801aa2:	56                   	push   %esi
  801aa3:	57                   	push   %edi
  801aa4:	e8 3e e8 ff ff       	call   8002e7 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aaf:	75 07                	jne    801ab8 <ipc_send+0x36>
				    sys_yield();
  801ab1:	e8 85 e6 ff ff       	call   80013b <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801ab6:	eb e6                	jmp    801a9e <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	74 12                	je     801ace <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801abc:	50                   	push   %eax
  801abd:	68 40 22 80 00       	push   $0x802240
  801ac2:	6a 4b                	push   $0x4b
  801ac4:	68 54 22 80 00       	push   $0x802254
  801ac9:	e8 b0 f5 ff ff       	call   80107e <_panic>
			 }
	   }
}
  801ace:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad1:	5b                   	pop    %ebx
  801ad2:	5e                   	pop    %esi
  801ad3:	5f                   	pop    %edi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801adc:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801ae1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ae4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aea:	8b 52 50             	mov    0x50(%edx),%edx
  801aed:	39 ca                	cmp    %ecx,%edx
  801aef:	75 0d                	jne    801afe <ipc_find_env+0x28>
				    return envs[i].env_id;
  801af1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801af4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af9:	8b 40 48             	mov    0x48(%eax),%eax
  801afc:	eb 0f                	jmp    801b0d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801afe:	83 c0 01             	add    $0x1,%eax
  801b01:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b06:	75 d9                	jne    801ae1 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801b08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b0d:	5d                   	pop    %ebp
  801b0e:	c3                   	ret    

00801b0f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b15:	89 d0                	mov    %edx,%eax
  801b17:	c1 e8 16             	shr    $0x16,%eax
  801b1a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b21:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b26:	f6 c1 01             	test   $0x1,%cl
  801b29:	74 1d                	je     801b48 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b2b:	c1 ea 0c             	shr    $0xc,%edx
  801b2e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b35:	f6 c2 01             	test   $0x1,%dl
  801b38:	74 0e                	je     801b48 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b3a:	c1 ea 0c             	shr    $0xc,%edx
  801b3d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b44:	ef 
  801b45:	0f b7 c0             	movzwl %ax,%eax
}
  801b48:	5d                   	pop    %ebp
  801b49:	c3                   	ret    
  801b4a:	66 90                	xchg   %ax,%ax
  801b4c:	66 90                	xchg   %ax,%ax
  801b4e:	66 90                	xchg   %ax,%ax

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
