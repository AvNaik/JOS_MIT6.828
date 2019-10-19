
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 ad 04 00 00       	call   800552 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 8a 1e 80 00       	push   $0x801e8a
  80011e:	6a 23                	push   $0x23
  800120:	68 a7 1e 80 00       	push   $0x801ea7
  800125:	e8 90 0f 00 00       	call   8010ba <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 8a 1e 80 00       	push   $0x801e8a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 a7 1e 80 00       	push   $0x801ea7
  8001a6:	e8 0f 0f 00 00       	call   8010ba <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 8a 1e 80 00       	push   $0x801e8a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 a7 1e 80 00       	push   $0x801ea7
  8001e8:	e8 cd 0e 00 00       	call   8010ba <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 8a 1e 80 00       	push   $0x801e8a
  800223:	6a 23                	push   $0x23
  800225:	68 a7 1e 80 00       	push   $0x801ea7
  80022a:	e8 8b 0e 00 00       	call   8010ba <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 8a 1e 80 00       	push   $0x801e8a
  800265:	6a 23                	push   $0x23
  800267:	68 a7 1e 80 00       	push   $0x801ea7
  80026c:	e8 49 0e 00 00       	call   8010ba <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 8a 1e 80 00       	push   $0x801e8a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 a7 1e 80 00       	push   $0x801ea7
  8002ae:	e8 07 0e 00 00       	call   8010ba <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 8a 1e 80 00       	push   $0x801e8a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 a7 1e 80 00       	push   $0x801ea7
  8002f0:	e8 c5 0d 00 00       	call   8010ba <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 8a 1e 80 00       	push   $0x801e8a
  80034d:	6a 23                	push   $0x23
  80034f:	68 a7 1e 80 00       	push   $0x801ea7
  800354:	e8 61 0d 00 00       	call   8010ba <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
movl _pgfault_handler, %eax
  800362:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  800367:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  80036c:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  800370:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  800374:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  800377:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  80037b:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  80037d:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  800380:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  800381:	83 c4 04             	add    $0x4,%esp
popfl
  800384:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  800385:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  800386:	c3                   	ret    

00800387 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	05 00 00 00 30       	add    $0x30000000,%eax
  800392:	c1 e8 0c             	shr    $0xc,%eax
}
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b9:	89 c2                	mov    %eax,%edx
  8003bb:	c1 ea 16             	shr    $0x16,%edx
  8003be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c5:	f6 c2 01             	test   $0x1,%dl
  8003c8:	74 11                	je     8003db <fd_alloc+0x2d>
  8003ca:	89 c2                	mov    %eax,%edx
  8003cc:	c1 ea 0c             	shr    $0xc,%edx
  8003cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d6:	f6 c2 01             	test   $0x1,%dl
  8003d9:	75 09                	jne    8003e4 <fd_alloc+0x36>
			*fd_store = fd;
  8003db:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e2:	eb 17                	jmp    8003fb <fd_alloc+0x4d>
  8003e4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ee:	75 c9                	jne    8003b9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003f6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800403:	83 f8 1f             	cmp    $0x1f,%eax
  800406:	77 36                	ja     80043e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800408:	c1 e0 0c             	shl    $0xc,%eax
  80040b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800410:	89 c2                	mov    %eax,%edx
  800412:	c1 ea 16             	shr    $0x16,%edx
  800415:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041c:	f6 c2 01             	test   $0x1,%dl
  80041f:	74 24                	je     800445 <fd_lookup+0x48>
  800421:	89 c2                	mov    %eax,%edx
  800423:	c1 ea 0c             	shr    $0xc,%edx
  800426:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042d:	f6 c2 01             	test   $0x1,%dl
  800430:	74 1a                	je     80044c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800432:	8b 55 0c             	mov    0xc(%ebp),%edx
  800435:	89 02                	mov    %eax,(%edx)
	return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	eb 13                	jmp    800451 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800443:	eb 0c                	jmp    800451 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044a:	eb 05                	jmp    800451 <fd_lookup+0x54>
  80044c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800451:	5d                   	pop    %ebp
  800452:	c3                   	ret    

00800453 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045c:	ba 34 1f 80 00       	mov    $0x801f34,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	eb 13                	jmp    800476 <dev_lookup+0x23>
  800463:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800466:	39 08                	cmp    %ecx,(%eax)
  800468:	75 0c                	jne    800476 <dev_lookup+0x23>
			*dev = devtab[i];
  80046a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046f:	b8 00 00 00 00       	mov    $0x0,%eax
  800474:	eb 2e                	jmp    8004a4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800476:	8b 02                	mov    (%edx),%eax
  800478:	85 c0                	test   %eax,%eax
  80047a:	75 e7                	jne    800463 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80047c:	a1 04 40 80 00       	mov    0x804004,%eax
  800481:	8b 40 48             	mov    0x48(%eax),%eax
  800484:	83 ec 04             	sub    $0x4,%esp
  800487:	51                   	push   %ecx
  800488:	50                   	push   %eax
  800489:	68 b8 1e 80 00       	push   $0x801eb8
  80048e:	e8 00 0d 00 00       	call   801193 <cprintf>
	*dev = 0;
  800493:	8b 45 0c             	mov    0xc(%ebp),%eax
  800496:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    

008004a6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	56                   	push   %esi
  8004aa:	53                   	push   %ebx
  8004ab:	83 ec 10             	sub    $0x10,%esp
  8004ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b7:	50                   	push   %eax
  8004b8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004be:	c1 e8 0c             	shr    $0xc,%eax
  8004c1:	50                   	push   %eax
  8004c2:	e8 36 ff ff ff       	call   8003fd <fd_lookup>
  8004c7:	83 c4 08             	add    $0x8,%esp
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	78 05                	js     8004d3 <fd_close+0x2d>
	    || fd != fd2)
  8004ce:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004d1:	74 0c                	je     8004df <fd_close+0x39>
		return (must_exist ? r : 0);
  8004d3:	84 db                	test   %bl,%bl
  8004d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004da:	0f 44 c2             	cmove  %edx,%eax
  8004dd:	eb 41                	jmp    800520 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e5:	50                   	push   %eax
  8004e6:	ff 36                	pushl  (%esi)
  8004e8:	e8 66 ff ff ff       	call   800453 <dev_lookup>
  8004ed:	89 c3                	mov    %eax,%ebx
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	85 c0                	test   %eax,%eax
  8004f4:	78 1a                	js     800510 <fd_close+0x6a>
		if (dev->dev_close)
  8004f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004f9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004fc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800501:	85 c0                	test   %eax,%eax
  800503:	74 0b                	je     800510 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800505:	83 ec 0c             	sub    $0xc,%esp
  800508:	56                   	push   %esi
  800509:	ff d0                	call   *%eax
  80050b:	89 c3                	mov    %eax,%ebx
  80050d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	56                   	push   %esi
  800514:	6a 00                	push   $0x0
  800516:	e8 da fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	89 d8                	mov    %ebx,%eax
}
  800520:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800523:	5b                   	pop    %ebx
  800524:	5e                   	pop    %esi
  800525:	5d                   	pop    %ebp
  800526:	c3                   	ret    

00800527 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800530:	50                   	push   %eax
  800531:	ff 75 08             	pushl  0x8(%ebp)
  800534:	e8 c4 fe ff ff       	call   8003fd <fd_lookup>
  800539:	83 c4 08             	add    $0x8,%esp
  80053c:	85 c0                	test   %eax,%eax
  80053e:	78 10                	js     800550 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	6a 01                	push   $0x1
  800545:	ff 75 f4             	pushl  -0xc(%ebp)
  800548:	e8 59 ff ff ff       	call   8004a6 <fd_close>
  80054d:	83 c4 10             	add    $0x10,%esp
}
  800550:	c9                   	leave  
  800551:	c3                   	ret    

00800552 <close_all>:

void
close_all(void)
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	53                   	push   %ebx
  800556:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800559:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	53                   	push   %ebx
  800562:	e8 c0 ff ff ff       	call   800527 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800567:	83 c3 01             	add    $0x1,%ebx
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	83 fb 20             	cmp    $0x20,%ebx
  800570:	75 ec                	jne    80055e <close_all+0xc>
		close(i);
}
  800572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800575:	c9                   	leave  
  800576:	c3                   	ret    

00800577 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	57                   	push   %edi
  80057b:	56                   	push   %esi
  80057c:	53                   	push   %ebx
  80057d:	83 ec 2c             	sub    $0x2c,%esp
  800580:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800583:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800586:	50                   	push   %eax
  800587:	ff 75 08             	pushl  0x8(%ebp)
  80058a:	e8 6e fe ff ff       	call   8003fd <fd_lookup>
  80058f:	83 c4 08             	add    $0x8,%esp
  800592:	85 c0                	test   %eax,%eax
  800594:	0f 88 c1 00 00 00    	js     80065b <dup+0xe4>
		return r;
	close(newfdnum);
  80059a:	83 ec 0c             	sub    $0xc,%esp
  80059d:	56                   	push   %esi
  80059e:	e8 84 ff ff ff       	call   800527 <close>

	newfd = INDEX2FD(newfdnum);
  8005a3:	89 f3                	mov    %esi,%ebx
  8005a5:	c1 e3 0c             	shl    $0xc,%ebx
  8005a8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ae:	83 c4 04             	add    $0x4,%esp
  8005b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b4:	e8 de fd ff ff       	call   800397 <fd2data>
  8005b9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005bb:	89 1c 24             	mov    %ebx,(%esp)
  8005be:	e8 d4 fd ff ff       	call   800397 <fd2data>
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c9:	89 f8                	mov    %edi,%eax
  8005cb:	c1 e8 16             	shr    $0x16,%eax
  8005ce:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d5:	a8 01                	test   $0x1,%al
  8005d7:	74 37                	je     800610 <dup+0x99>
  8005d9:	89 f8                	mov    %edi,%eax
  8005db:	c1 e8 0c             	shr    $0xc,%eax
  8005de:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e5:	f6 c2 01             	test   $0x1,%dl
  8005e8:	74 26                	je     800610 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f1:	83 ec 0c             	sub    $0xc,%esp
  8005f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f9:	50                   	push   %eax
  8005fa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005fd:	6a 00                	push   $0x0
  8005ff:	57                   	push   %edi
  800600:	6a 00                	push   $0x0
  800602:	e8 ac fb ff ff       	call   8001b3 <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
  80060c:	85 c0                	test   %eax,%eax
  80060e:	78 2e                	js     80063e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800610:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800613:	89 d0                	mov    %edx,%eax
  800615:	c1 e8 0c             	shr    $0xc,%eax
  800618:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061f:	83 ec 0c             	sub    $0xc,%esp
  800622:	25 07 0e 00 00       	and    $0xe07,%eax
  800627:	50                   	push   %eax
  800628:	53                   	push   %ebx
  800629:	6a 00                	push   $0x0
  80062b:	52                   	push   %edx
  80062c:	6a 00                	push   $0x0
  80062e:	e8 80 fb ff ff       	call   8001b3 <sys_page_map>
  800633:	89 c7                	mov    %eax,%edi
  800635:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800638:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80063a:	85 ff                	test   %edi,%edi
  80063c:	79 1d                	jns    80065b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	53                   	push   %ebx
  800642:	6a 00                	push   $0x0
  800644:	e8 ac fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064f:	6a 00                	push   $0x0
  800651:	e8 9f fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	89 f8                	mov    %edi,%eax
}
  80065b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065e:	5b                   	pop    %ebx
  80065f:	5e                   	pop    %esi
  800660:	5f                   	pop    %edi
  800661:	5d                   	pop    %ebp
  800662:	c3                   	ret    

00800663 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
  800666:	53                   	push   %ebx
  800667:	83 ec 14             	sub    $0x14,%esp
  80066a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80066d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800670:	50                   	push   %eax
  800671:	53                   	push   %ebx
  800672:	e8 86 fd ff ff       	call   8003fd <fd_lookup>
  800677:	83 c4 08             	add    $0x8,%esp
  80067a:	89 c2                	mov    %eax,%edx
  80067c:	85 c0                	test   %eax,%eax
  80067e:	78 6d                	js     8006ed <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800686:	50                   	push   %eax
  800687:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80068a:	ff 30                	pushl  (%eax)
  80068c:	e8 c2 fd ff ff       	call   800453 <dev_lookup>
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	85 c0                	test   %eax,%eax
  800696:	78 4c                	js     8006e4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800698:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80069b:	8b 42 08             	mov    0x8(%edx),%eax
  80069e:	83 e0 03             	and    $0x3,%eax
  8006a1:	83 f8 01             	cmp    $0x1,%eax
  8006a4:	75 21                	jne    8006c7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8006ab:	8b 40 48             	mov    0x48(%eax),%eax
  8006ae:	83 ec 04             	sub    $0x4,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	50                   	push   %eax
  8006b3:	68 f9 1e 80 00       	push   $0x801ef9
  8006b8:	e8 d6 0a 00 00       	call   801193 <cprintf>
		return -E_INVAL;
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006c5:	eb 26                	jmp    8006ed <read+0x8a>
	}
	if (!dev->dev_read)
  8006c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ca:	8b 40 08             	mov    0x8(%eax),%eax
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	74 17                	je     8006e8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d1:	83 ec 04             	sub    $0x4,%esp
  8006d4:	ff 75 10             	pushl  0x10(%ebp)
  8006d7:	ff 75 0c             	pushl  0xc(%ebp)
  8006da:	52                   	push   %edx
  8006db:	ff d0                	call   *%eax
  8006dd:	89 c2                	mov    %eax,%edx
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	eb 09                	jmp    8006ed <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e4:	89 c2                	mov    %eax,%edx
  8006e6:	eb 05                	jmp    8006ed <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ed:	89 d0                	mov    %edx,%eax
  8006ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 0c             	sub    $0xc,%esp
  8006fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800700:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800703:	bb 00 00 00 00       	mov    $0x0,%ebx
  800708:	eb 21                	jmp    80072b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80070a:	83 ec 04             	sub    $0x4,%esp
  80070d:	89 f0                	mov    %esi,%eax
  80070f:	29 d8                	sub    %ebx,%eax
  800711:	50                   	push   %eax
  800712:	89 d8                	mov    %ebx,%eax
  800714:	03 45 0c             	add    0xc(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	57                   	push   %edi
  800719:	e8 45 ff ff ff       	call   800663 <read>
		if (m < 0)
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	85 c0                	test   %eax,%eax
  800723:	78 10                	js     800735 <readn+0x41>
			return m;
		if (m == 0)
  800725:	85 c0                	test   %eax,%eax
  800727:	74 0a                	je     800733 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800729:	01 c3                	add    %eax,%ebx
  80072b:	39 f3                	cmp    %esi,%ebx
  80072d:	72 db                	jb     80070a <readn+0x16>
  80072f:	89 d8                	mov    %ebx,%eax
  800731:	eb 02                	jmp    800735 <readn+0x41>
  800733:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800735:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800738:	5b                   	pop    %ebx
  800739:	5e                   	pop    %esi
  80073a:	5f                   	pop    %edi
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	53                   	push   %ebx
  800741:	83 ec 14             	sub    $0x14,%esp
  800744:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800747:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80074a:	50                   	push   %eax
  80074b:	53                   	push   %ebx
  80074c:	e8 ac fc ff ff       	call   8003fd <fd_lookup>
  800751:	83 c4 08             	add    $0x8,%esp
  800754:	89 c2                	mov    %eax,%edx
  800756:	85 c0                	test   %eax,%eax
  800758:	78 68                	js     8007c2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800760:	50                   	push   %eax
  800761:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800764:	ff 30                	pushl  (%eax)
  800766:	e8 e8 fc ff ff       	call   800453 <dev_lookup>
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	85 c0                	test   %eax,%eax
  800770:	78 47                	js     8007b9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800775:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800779:	75 21                	jne    80079c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80077b:	a1 04 40 80 00       	mov    0x804004,%eax
  800780:	8b 40 48             	mov    0x48(%eax),%eax
  800783:	83 ec 04             	sub    $0x4,%esp
  800786:	53                   	push   %ebx
  800787:	50                   	push   %eax
  800788:	68 15 1f 80 00       	push   $0x801f15
  80078d:	e8 01 0a 00 00       	call   801193 <cprintf>
		return -E_INVAL;
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80079a:	eb 26                	jmp    8007c2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80079f:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a2:	85 d2                	test   %edx,%edx
  8007a4:	74 17                	je     8007bd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a6:	83 ec 04             	sub    $0x4,%esp
  8007a9:	ff 75 10             	pushl  0x10(%ebp)
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	50                   	push   %eax
  8007b0:	ff d2                	call   *%edx
  8007b2:	89 c2                	mov    %eax,%edx
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	eb 09                	jmp    8007c2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b9:	89 c2                	mov    %eax,%edx
  8007bb:	eb 05                	jmp    8007c2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c2:	89 d0                	mov    %edx,%eax
  8007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007cf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d2:	50                   	push   %eax
  8007d3:	ff 75 08             	pushl  0x8(%ebp)
  8007d6:	e8 22 fc ff ff       	call   8003fd <fd_lookup>
  8007db:	83 c4 08             	add    $0x8,%esp
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	78 0e                	js     8007f0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	83 ec 14             	sub    $0x14,%esp
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ff:	50                   	push   %eax
  800800:	53                   	push   %ebx
  800801:	e8 f7 fb ff ff       	call   8003fd <fd_lookup>
  800806:	83 c4 08             	add    $0x8,%esp
  800809:	89 c2                	mov    %eax,%edx
  80080b:	85 c0                	test   %eax,%eax
  80080d:	78 65                	js     800874 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080f:	83 ec 08             	sub    $0x8,%esp
  800812:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800815:	50                   	push   %eax
  800816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800819:	ff 30                	pushl  (%eax)
  80081b:	e8 33 fc ff ff       	call   800453 <dev_lookup>
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	85 c0                	test   %eax,%eax
  800825:	78 44                	js     80086b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800827:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082e:	75 21                	jne    800851 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800830:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800835:	8b 40 48             	mov    0x48(%eax),%eax
  800838:	83 ec 04             	sub    $0x4,%esp
  80083b:	53                   	push   %ebx
  80083c:	50                   	push   %eax
  80083d:	68 d8 1e 80 00       	push   $0x801ed8
  800842:	e8 4c 09 00 00       	call   801193 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800847:	83 c4 10             	add    $0x10,%esp
  80084a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80084f:	eb 23                	jmp    800874 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800851:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800854:	8b 52 18             	mov    0x18(%edx),%edx
  800857:	85 d2                	test   %edx,%edx
  800859:	74 14                	je     80086f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	ff 75 0c             	pushl  0xc(%ebp)
  800861:	50                   	push   %eax
  800862:	ff d2                	call   *%edx
  800864:	89 c2                	mov    %eax,%edx
  800866:	83 c4 10             	add    $0x10,%esp
  800869:	eb 09                	jmp    800874 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086b:	89 c2                	mov    %eax,%edx
  80086d:	eb 05                	jmp    800874 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800874:	89 d0                	mov    %edx,%eax
  800876:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	83 ec 14             	sub    $0x14,%esp
  800882:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800885:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800888:	50                   	push   %eax
  800889:	ff 75 08             	pushl  0x8(%ebp)
  80088c:	e8 6c fb ff ff       	call   8003fd <fd_lookup>
  800891:	83 c4 08             	add    $0x8,%esp
  800894:	89 c2                	mov    %eax,%edx
  800896:	85 c0                	test   %eax,%eax
  800898:	78 58                	js     8008f2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a0:	50                   	push   %eax
  8008a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a4:	ff 30                	pushl  (%eax)
  8008a6:	e8 a8 fb ff ff       	call   800453 <dev_lookup>
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 37                	js     8008e9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b9:	74 32                	je     8008ed <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008bb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008be:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c5:	00 00 00 
	stat->st_isdir = 0;
  8008c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cf:	00 00 00 
	stat->st_dev = dev;
  8008d2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	53                   	push   %ebx
  8008dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8008df:	ff 50 14             	call   *0x14(%eax)
  8008e2:	89 c2                	mov    %eax,%edx
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	eb 09                	jmp    8008f2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e9:	89 c2                	mov    %eax,%edx
  8008eb:	eb 05                	jmp    8008f2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    

008008f9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fe:	83 ec 08             	sub    $0x8,%esp
  800901:	6a 00                	push   $0x0
  800903:	ff 75 08             	pushl  0x8(%ebp)
  800906:	e8 2c 02 00 00       	call   800b37 <open>
  80090b:	89 c3                	mov    %eax,%ebx
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	85 c0                	test   %eax,%eax
  800912:	78 1b                	js     80092f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	ff 75 0c             	pushl  0xc(%ebp)
  80091a:	50                   	push   %eax
  80091b:	e8 5b ff ff ff       	call   80087b <fstat>
  800920:	89 c6                	mov    %eax,%esi
	close(fd);
  800922:	89 1c 24             	mov    %ebx,(%esp)
  800925:	e8 fd fb ff ff       	call   800527 <close>
	return r;
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	89 f0                	mov    %esi,%eax
}
  80092f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	89 c6                	mov    %eax,%esi
  80093d:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  80093f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800946:	75 12                	jne    80095a <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  800948:	83 ec 0c             	sub    $0xc,%esp
  80094b:	6a 01                	push   $0x1
  80094d:	e8 19 12 00 00       	call   801b6b <ipc_find_env>
  800952:	a3 00 40 80 00       	mov    %eax,0x804000
  800957:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80095a:	6a 07                	push   $0x7
  80095c:	68 00 50 80 00       	push   $0x805000
  800961:	56                   	push   %esi
  800962:	ff 35 00 40 80 00    	pushl  0x804000
  800968:	e8 aa 11 00 00       	call   801b17 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  80096d:	83 c4 0c             	add    $0xc,%esp
  800970:	6a 00                	push   $0x0
  800972:	53                   	push   %ebx
  800973:	6a 00                	push   $0x0
  800975:	e8 3e 11 00 00       	call   801ab8 <ipc_recv>
}
  80097a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 40 0c             	mov    0xc(%eax),%eax
  80098d:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  800992:	8b 45 0c             	mov    0xc(%ebp),%eax
  800995:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80099a:	ba 00 00 00 00       	mov    $0x0,%edx
  80099f:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a4:	e8 8d ff ff ff       	call   800936 <fsipc>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b7:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  8009bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c1:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c6:	e8 6b ff ff ff       	call   800936 <fsipc>
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	53                   	push   %ebx
  8009d1:	83 ec 04             	sub    $0x4,%esp
  8009d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 40 0c             	mov    0xc(%eax),%eax
  8009dd:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ec:	e8 45 ff ff ff       	call   800936 <fsipc>
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	78 2c                	js     800a21 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f5:	83 ec 08             	sub    $0x8,%esp
  8009f8:	68 00 50 80 00       	push   $0x805000
  8009fd:	53                   	push   %ebx
  8009fe:	e8 15 0d 00 00       	call   801718 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  800a03:	a1 80 50 80 00       	mov    0x805080,%eax
  800a08:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a13:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  800a19:	83 c4 10             	add    $0x10,%esp
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	53                   	push   %ebx
  800a2a:	83 ec 08             	sub    $0x8,%esp
  800a2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 40 0c             	mov    0xc(%eax),%eax
  800a36:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  800a3b:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  800a41:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a47:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800a4c:	0f 46 c3             	cmovbe %ebx,%eax
  800a4f:	50                   	push   %eax
  800a50:	ff 75 0c             	pushl  0xc(%ebp)
  800a53:	68 08 50 80 00       	push   $0x805008
  800a58:	e8 4d 0e 00 00       	call   8018aa <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  800a5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a62:	b8 04 00 00 00       	mov    $0x4,%eax
  800a67:	e8 ca fe ff ff       	call   800936 <fsipc>
  800a6c:	83 c4 10             	add    $0x10,%esp
  800a6f:	85 c0                	test   %eax,%eax
  800a71:	78 3d                	js     800ab0 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  800a73:	39 c3                	cmp    %eax,%ebx
  800a75:	73 19                	jae    800a90 <devfile_write+0x6a>
  800a77:	68 44 1f 80 00       	push   $0x801f44
  800a7c:	68 4b 1f 80 00       	push   $0x801f4b
  800a81:	68 9a 00 00 00       	push   $0x9a
  800a86:	68 60 1f 80 00       	push   $0x801f60
  800a8b:	e8 2a 06 00 00       	call   8010ba <_panic>
	   assert (r <= bytes_written);
  800a90:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a95:	7e 19                	jle    800ab0 <devfile_write+0x8a>
  800a97:	68 6b 1f 80 00       	push   $0x801f6b
  800a9c:	68 4b 1f 80 00       	push   $0x801f4b
  800aa1:	68 9b 00 00 00       	push   $0x9b
  800aa6:	68 60 1f 80 00       	push   $0x801f60
  800aab:	e8 0a 06 00 00       	call   8010ba <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  800ab0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab3:	c9                   	leave  
  800ab4:	c3                   	ret    

00800ab5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	8b 40 0c             	mov    0xc(%eax),%eax
  800ac3:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  800ac8:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ace:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad8:	e8 59 fe ff ff       	call   800936 <fsipc>
  800add:	89 c3                	mov    %eax,%ebx
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	78 4b                	js     800b2e <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  800ae3:	39 c6                	cmp    %eax,%esi
  800ae5:	73 16                	jae    800afd <devfile_read+0x48>
  800ae7:	68 44 1f 80 00       	push   $0x801f44
  800aec:	68 4b 1f 80 00       	push   $0x801f4b
  800af1:	6a 7c                	push   $0x7c
  800af3:	68 60 1f 80 00       	push   $0x801f60
  800af8:	e8 bd 05 00 00       	call   8010ba <_panic>
	   assert(r <= PGSIZE);
  800afd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b02:	7e 16                	jle    800b1a <devfile_read+0x65>
  800b04:	68 7e 1f 80 00       	push   $0x801f7e
  800b09:	68 4b 1f 80 00       	push   $0x801f4b
  800b0e:	6a 7d                	push   $0x7d
  800b10:	68 60 1f 80 00       	push   $0x801f60
  800b15:	e8 a0 05 00 00       	call   8010ba <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b1a:	83 ec 04             	sub    $0x4,%esp
  800b1d:	50                   	push   %eax
  800b1e:	68 00 50 80 00       	push   $0x805000
  800b23:	ff 75 0c             	pushl  0xc(%ebp)
  800b26:	e8 7f 0d 00 00       	call   8018aa <memmove>
	   return r;
  800b2b:	83 c4 10             	add    $0x10,%esp
}
  800b2e:	89 d8                	mov    %ebx,%eax
  800b30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	53                   	push   %ebx
  800b3b:	83 ec 20             	sub    $0x20,%esp
  800b3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  800b41:	53                   	push   %ebx
  800b42:	e8 98 0b 00 00       	call   8016df <strlen>
  800b47:	83 c4 10             	add    $0x10,%esp
  800b4a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b4f:	7f 67                	jg     800bb8 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b57:	50                   	push   %eax
  800b58:	e8 51 f8 ff ff       	call   8003ae <fd_alloc>
  800b5d:	83 c4 10             	add    $0x10,%esp
			 return r;
  800b60:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b62:	85 c0                	test   %eax,%eax
  800b64:	78 57                	js     800bbd <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  800b66:	83 ec 08             	sub    $0x8,%esp
  800b69:	53                   	push   %ebx
  800b6a:	68 00 50 80 00       	push   $0x805000
  800b6f:	e8 a4 0b 00 00       	call   801718 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  800b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b77:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b84:	e8 ad fd ff ff       	call   800936 <fsipc>
  800b89:	89 c3                	mov    %eax,%ebx
  800b8b:	83 c4 10             	add    $0x10,%esp
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	79 14                	jns    800ba6 <open+0x6f>
			 fd_close(fd, 0);
  800b92:	83 ec 08             	sub    $0x8,%esp
  800b95:	6a 00                	push   $0x0
  800b97:	ff 75 f4             	pushl  -0xc(%ebp)
  800b9a:	e8 07 f9 ff ff       	call   8004a6 <fd_close>
			 return r;
  800b9f:	83 c4 10             	add    $0x10,%esp
  800ba2:	89 da                	mov    %ebx,%edx
  800ba4:	eb 17                	jmp    800bbd <open+0x86>
	   }

	   return fd2num(fd);
  800ba6:	83 ec 0c             	sub    $0xc,%esp
  800ba9:	ff 75 f4             	pushl  -0xc(%ebp)
  800bac:	e8 d6 f7 ff ff       	call   800387 <fd2num>
  800bb1:	89 c2                	mov    %eax,%edx
  800bb3:	83 c4 10             	add    $0x10,%esp
  800bb6:	eb 05                	jmp    800bbd <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  800bb8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  800bbd:	89 d0                	mov    %edx,%eax
  800bbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  800bca:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcf:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd4:	e8 5d fd ff ff       	call   800936 <fsipc>
}
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	ff 75 08             	pushl  0x8(%ebp)
  800be9:	e8 a9 f7 ff ff       	call   800397 <fd2data>
  800bee:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bf0:	83 c4 08             	add    $0x8,%esp
  800bf3:	68 8a 1f 80 00       	push   $0x801f8a
  800bf8:	53                   	push   %ebx
  800bf9:	e8 1a 0b 00 00       	call   801718 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bfe:	8b 46 04             	mov    0x4(%esi),%eax
  800c01:	2b 06                	sub    (%esi),%eax
  800c03:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c09:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c10:	00 00 00 
	stat->st_dev = &devpipe;
  800c13:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c1a:	30 80 00 
	return 0;
}
  800c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 0c             	sub    $0xc,%esp
  800c30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c33:	53                   	push   %ebx
  800c34:	6a 00                	push   $0x0
  800c36:	e8 ba f5 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c3b:	89 1c 24             	mov    %ebx,(%esp)
  800c3e:	e8 54 f7 ff ff       	call   800397 <fd2data>
  800c43:	83 c4 08             	add    $0x8,%esp
  800c46:	50                   	push   %eax
  800c47:	6a 00                	push   $0x0
  800c49:	e8 a7 f5 ff ff       	call   8001f5 <sys_page_unmap>
}
  800c4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c51:	c9                   	leave  
  800c52:	c3                   	ret    

00800c53 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 1c             	sub    $0x1c,%esp
  800c5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c5f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c61:	a1 04 40 80 00       	mov    0x804004,%eax
  800c66:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	ff 75 e0             	pushl  -0x20(%ebp)
  800c6f:	e8 30 0f 00 00       	call   801ba4 <pageref>
  800c74:	89 c3                	mov    %eax,%ebx
  800c76:	89 3c 24             	mov    %edi,(%esp)
  800c79:	e8 26 0f 00 00       	call   801ba4 <pageref>
  800c7e:	83 c4 10             	add    $0x10,%esp
  800c81:	39 c3                	cmp    %eax,%ebx
  800c83:	0f 94 c1             	sete   %cl
  800c86:	0f b6 c9             	movzbl %cl,%ecx
  800c89:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c8c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c92:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c95:	39 ce                	cmp    %ecx,%esi
  800c97:	74 1b                	je     800cb4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c99:	39 c3                	cmp    %eax,%ebx
  800c9b:	75 c4                	jne    800c61 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c9d:	8b 42 58             	mov    0x58(%edx),%eax
  800ca0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ca3:	50                   	push   %eax
  800ca4:	56                   	push   %esi
  800ca5:	68 91 1f 80 00       	push   $0x801f91
  800caa:	e8 e4 04 00 00       	call   801193 <cprintf>
  800caf:	83 c4 10             	add    $0x10,%esp
  800cb2:	eb ad                	jmp    800c61 <_pipeisclosed+0xe>
	}
}
  800cb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	83 ec 28             	sub    $0x28,%esp
  800cc8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800ccb:	56                   	push   %esi
  800ccc:	e8 c6 f6 ff ff       	call   800397 <fd2data>
  800cd1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd3:	83 c4 10             	add    $0x10,%esp
  800cd6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cdb:	eb 4b                	jmp    800d28 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cdd:	89 da                	mov    %ebx,%edx
  800cdf:	89 f0                	mov    %esi,%eax
  800ce1:	e8 6d ff ff ff       	call   800c53 <_pipeisclosed>
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	75 48                	jne    800d32 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cea:	e8 62 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cef:	8b 43 04             	mov    0x4(%ebx),%eax
  800cf2:	8b 0b                	mov    (%ebx),%ecx
  800cf4:	8d 51 20             	lea    0x20(%ecx),%edx
  800cf7:	39 d0                	cmp    %edx,%eax
  800cf9:	73 e2                	jae    800cdd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d02:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d05:	89 c2                	mov    %eax,%edx
  800d07:	c1 fa 1f             	sar    $0x1f,%edx
  800d0a:	89 d1                	mov    %edx,%ecx
  800d0c:	c1 e9 1b             	shr    $0x1b,%ecx
  800d0f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d12:	83 e2 1f             	and    $0x1f,%edx
  800d15:	29 ca                	sub    %ecx,%edx
  800d17:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d1b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d1f:	83 c0 01             	add    $0x1,%eax
  800d22:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d25:	83 c7 01             	add    $0x1,%edi
  800d28:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d2b:	75 c2                	jne    800cef <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d30:	eb 05                	jmp    800d37 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d32:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 18             	sub    $0x18,%esp
  800d48:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d4b:	57                   	push   %edi
  800d4c:	e8 46 f6 ff ff       	call   800397 <fd2data>
  800d51:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d53:	83 c4 10             	add    $0x10,%esp
  800d56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5b:	eb 3d                	jmp    800d9a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d5d:	85 db                	test   %ebx,%ebx
  800d5f:	74 04                	je     800d65 <devpipe_read+0x26>
				return i;
  800d61:	89 d8                	mov    %ebx,%eax
  800d63:	eb 44                	jmp    800da9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d65:	89 f2                	mov    %esi,%edx
  800d67:	89 f8                	mov    %edi,%eax
  800d69:	e8 e5 fe ff ff       	call   800c53 <_pipeisclosed>
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	75 32                	jne    800da4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d72:	e8 da f3 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d77:	8b 06                	mov    (%esi),%eax
  800d79:	3b 46 04             	cmp    0x4(%esi),%eax
  800d7c:	74 df                	je     800d5d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d7e:	99                   	cltd   
  800d7f:	c1 ea 1b             	shr    $0x1b,%edx
  800d82:	01 d0                	add    %edx,%eax
  800d84:	83 e0 1f             	and    $0x1f,%eax
  800d87:	29 d0                	sub    %edx,%eax
  800d89:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d94:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d97:	83 c3 01             	add    $0x1,%ebx
  800d9a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d9d:	75 d8                	jne    800d77 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800da2:	eb 05                	jmp    800da9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800da4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
  800db6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800db9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dbc:	50                   	push   %eax
  800dbd:	e8 ec f5 ff ff       	call   8003ae <fd_alloc>
  800dc2:	83 c4 10             	add    $0x10,%esp
  800dc5:	89 c2                	mov    %eax,%edx
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	0f 88 2c 01 00 00    	js     800efb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcf:	83 ec 04             	sub    $0x4,%esp
  800dd2:	68 07 04 00 00       	push   $0x407
  800dd7:	ff 75 f4             	pushl  -0xc(%ebp)
  800dda:	6a 00                	push   $0x0
  800ddc:	e8 8f f3 ff ff       	call   800170 <sys_page_alloc>
  800de1:	83 c4 10             	add    $0x10,%esp
  800de4:	89 c2                	mov    %eax,%edx
  800de6:	85 c0                	test   %eax,%eax
  800de8:	0f 88 0d 01 00 00    	js     800efb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dee:	83 ec 0c             	sub    $0xc,%esp
  800df1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800df4:	50                   	push   %eax
  800df5:	e8 b4 f5 ff ff       	call   8003ae <fd_alloc>
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	0f 88 e2 00 00 00    	js     800ee9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e07:	83 ec 04             	sub    $0x4,%esp
  800e0a:	68 07 04 00 00       	push   $0x407
  800e0f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e12:	6a 00                	push   $0x0
  800e14:	e8 57 f3 ff ff       	call   800170 <sys_page_alloc>
  800e19:	89 c3                	mov    %eax,%ebx
  800e1b:	83 c4 10             	add    $0x10,%esp
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	0f 88 c3 00 00 00    	js     800ee9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	ff 75 f4             	pushl  -0xc(%ebp)
  800e2c:	e8 66 f5 ff ff       	call   800397 <fd2data>
  800e31:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e33:	83 c4 0c             	add    $0xc,%esp
  800e36:	68 07 04 00 00       	push   $0x407
  800e3b:	50                   	push   %eax
  800e3c:	6a 00                	push   $0x0
  800e3e:	e8 2d f3 ff ff       	call   800170 <sys_page_alloc>
  800e43:	89 c3                	mov    %eax,%ebx
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	0f 88 89 00 00 00    	js     800ed9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	ff 75 f0             	pushl  -0x10(%ebp)
  800e56:	e8 3c f5 ff ff       	call   800397 <fd2data>
  800e5b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e62:	50                   	push   %eax
  800e63:	6a 00                	push   $0x0
  800e65:	56                   	push   %esi
  800e66:	6a 00                	push   $0x0
  800e68:	e8 46 f3 ff ff       	call   8001b3 <sys_page_map>
  800e6d:	89 c3                	mov    %eax,%ebx
  800e6f:	83 c4 20             	add    $0x20,%esp
  800e72:	85 c0                	test   %eax,%eax
  800e74:	78 55                	js     800ecb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e76:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e84:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e8b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e94:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e99:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800ea0:	83 ec 0c             	sub    $0xc,%esp
  800ea3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea6:	e8 dc f4 ff ff       	call   800387 <fd2num>
  800eab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eae:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800eb0:	83 c4 04             	add    $0x4,%esp
  800eb3:	ff 75 f0             	pushl  -0x10(%ebp)
  800eb6:	e8 cc f4 ff ff       	call   800387 <fd2num>
  800ebb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebe:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec9:	eb 30                	jmp    800efb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800ecb:	83 ec 08             	sub    $0x8,%esp
  800ece:	56                   	push   %esi
  800ecf:	6a 00                	push   $0x0
  800ed1:	e8 1f f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ed6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	ff 75 f0             	pushl  -0x10(%ebp)
  800edf:	6a 00                	push   $0x0
  800ee1:	e8 0f f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ee6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ee9:	83 ec 08             	sub    $0x8,%esp
  800eec:	ff 75 f4             	pushl  -0xc(%ebp)
  800eef:	6a 00                	push   $0x0
  800ef1:	e8 ff f2 ff ff       	call   8001f5 <sys_page_unmap>
  800ef6:	83 c4 10             	add    $0x10,%esp
  800ef9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800efb:	89 d0                	mov    %edx,%eax
  800efd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f0d:	50                   	push   %eax
  800f0e:	ff 75 08             	pushl  0x8(%ebp)
  800f11:	e8 e7 f4 ff ff       	call   8003fd <fd_lookup>
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	78 18                	js     800f35 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800f1d:	83 ec 0c             	sub    $0xc,%esp
  800f20:	ff 75 f4             	pushl  -0xc(%ebp)
  800f23:	e8 6f f4 ff ff       	call   800397 <fd2data>
	return _pipeisclosed(fd, p);
  800f28:	89 c2                	mov    %eax,%edx
  800f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f2d:	e8 21 fd ff ff       	call   800c53 <_pipeisclosed>
  800f32:	83 c4 10             	add    $0x10,%esp
}
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    

00800f37 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f47:	68 a9 1f 80 00       	push   $0x801fa9
  800f4c:	ff 75 0c             	pushl  0xc(%ebp)
  800f4f:	e8 c4 07 00 00       	call   801718 <strcpy>
	return 0;
}
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
  800f59:	c9                   	leave  
  800f5a:	c3                   	ret    

00800f5b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	57                   	push   %edi
  800f5f:	56                   	push   %esi
  800f60:	53                   	push   %ebx
  800f61:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f67:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f6c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f72:	eb 2d                	jmp    800fa1 <devcons_write+0x46>
		m = n - tot;
  800f74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f77:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f79:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f7c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f81:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	53                   	push   %ebx
  800f88:	03 45 0c             	add    0xc(%ebp),%eax
  800f8b:	50                   	push   %eax
  800f8c:	57                   	push   %edi
  800f8d:	e8 18 09 00 00       	call   8018aa <memmove>
		sys_cputs(buf, m);
  800f92:	83 c4 08             	add    $0x8,%esp
  800f95:	53                   	push   %ebx
  800f96:	57                   	push   %edi
  800f97:	e8 18 f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f9c:	01 de                	add    %ebx,%esi
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	89 f0                	mov    %esi,%eax
  800fa3:	3b 75 10             	cmp    0x10(%ebp),%esi
  800fa6:	72 cc                	jb     800f74 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800fa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fab:	5b                   	pop    %ebx
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 08             	sub    $0x8,%esp
  800fb6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800fbb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fbf:	74 2a                	je     800feb <devcons_read+0x3b>
  800fc1:	eb 05                	jmp    800fc8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800fc3:	e8 89 f1 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800fc8:	e8 05 f1 ff ff       	call   8000d2 <sys_cgetc>
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	74 f2                	je     800fc3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	78 16                	js     800feb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fd5:	83 f8 04             	cmp    $0x4,%eax
  800fd8:	74 0c                	je     800fe6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fda:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fdd:	88 02                	mov    %al,(%edx)
	return 1;
  800fdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe4:	eb 05                	jmp    800feb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fe6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800feb:	c9                   	leave  
  800fec:	c3                   	ret    

00800fed <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800ff9:	6a 01                	push   $0x1
  800ffb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800ffe:	50                   	push   %eax
  800fff:	e8 b0 f0 ff ff       	call   8000b4 <sys_cputs>
}
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <getchar>:

int
getchar(void)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80100f:	6a 01                	push   $0x1
  801011:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801014:	50                   	push   %eax
  801015:	6a 00                	push   $0x0
  801017:	e8 47 f6 ff ff       	call   800663 <read>
	if (r < 0)
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	78 0f                	js     801032 <getchar+0x29>
		return r;
	if (r < 1)
  801023:	85 c0                	test   %eax,%eax
  801025:	7e 06                	jle    80102d <getchar+0x24>
		return -E_EOF;
	return c;
  801027:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80102b:	eb 05                	jmp    801032 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80102d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80103a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103d:	50                   	push   %eax
  80103e:	ff 75 08             	pushl  0x8(%ebp)
  801041:	e8 b7 f3 ff ff       	call   8003fd <fd_lookup>
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	78 11                	js     80105e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80104d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801050:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801056:	39 10                	cmp    %edx,(%eax)
  801058:	0f 94 c0             	sete   %al
  80105b:	0f b6 c0             	movzbl %al,%eax
}
  80105e:	c9                   	leave  
  80105f:	c3                   	ret    

00801060 <opencons>:

int
opencons(void)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801066:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801069:	50                   	push   %eax
  80106a:	e8 3f f3 ff ff       	call   8003ae <fd_alloc>
  80106f:	83 c4 10             	add    $0x10,%esp
		return r;
  801072:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801074:	85 c0                	test   %eax,%eax
  801076:	78 3e                	js     8010b6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801078:	83 ec 04             	sub    $0x4,%esp
  80107b:	68 07 04 00 00       	push   $0x407
  801080:	ff 75 f4             	pushl  -0xc(%ebp)
  801083:	6a 00                	push   $0x0
  801085:	e8 e6 f0 ff ff       	call   800170 <sys_page_alloc>
  80108a:	83 c4 10             	add    $0x10,%esp
		return r;
  80108d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80108f:	85 c0                	test   %eax,%eax
  801091:	78 23                	js     8010b6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801093:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801099:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80109e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010a8:	83 ec 0c             	sub    $0xc,%esp
  8010ab:	50                   	push   %eax
  8010ac:	e8 d6 f2 ff ff       	call   800387 <fd2num>
  8010b1:	89 c2                	mov    %eax,%edx
  8010b3:	83 c4 10             	add    $0x10,%esp
}
  8010b6:	89 d0                	mov    %edx,%eax
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    

008010ba <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010bf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010c2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010c8:	e8 65 f0 ff ff       	call   800132 <sys_getenvid>
  8010cd:	83 ec 0c             	sub    $0xc,%esp
  8010d0:	ff 75 0c             	pushl  0xc(%ebp)
  8010d3:	ff 75 08             	pushl  0x8(%ebp)
  8010d6:	56                   	push   %esi
  8010d7:	50                   	push   %eax
  8010d8:	68 b8 1f 80 00       	push   $0x801fb8
  8010dd:	e8 b1 00 00 00       	call   801193 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010e2:	83 c4 18             	add    $0x18,%esp
  8010e5:	53                   	push   %ebx
  8010e6:	ff 75 10             	pushl  0x10(%ebp)
  8010e9:	e8 54 00 00 00       	call   801142 <vcprintf>
	cprintf("\n");
  8010ee:	c7 04 24 a2 1f 80 00 	movl   $0x801fa2,(%esp)
  8010f5:	e8 99 00 00 00       	call   801193 <cprintf>
  8010fa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010fd:	cc                   	int3   
  8010fe:	eb fd                	jmp    8010fd <_panic+0x43>

00801100 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	53                   	push   %ebx
  801104:	83 ec 04             	sub    $0x4,%esp
  801107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80110a:	8b 13                	mov    (%ebx),%edx
  80110c:	8d 42 01             	lea    0x1(%edx),%eax
  80110f:	89 03                	mov    %eax,(%ebx)
  801111:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801114:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801118:	3d ff 00 00 00       	cmp    $0xff,%eax
  80111d:	75 1a                	jne    801139 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80111f:	83 ec 08             	sub    $0x8,%esp
  801122:	68 ff 00 00 00       	push   $0xff
  801127:	8d 43 08             	lea    0x8(%ebx),%eax
  80112a:	50                   	push   %eax
  80112b:	e8 84 ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  801130:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801136:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801139:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80113d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801140:	c9                   	leave  
  801141:	c3                   	ret    

00801142 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80114b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801152:	00 00 00 
	b.cnt = 0;
  801155:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80115c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80115f:	ff 75 0c             	pushl  0xc(%ebp)
  801162:	ff 75 08             	pushl  0x8(%ebp)
  801165:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80116b:	50                   	push   %eax
  80116c:	68 00 11 80 00       	push   $0x801100
  801171:	e8 54 01 00 00       	call   8012ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801176:	83 c4 08             	add    $0x8,%esp
  801179:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80117f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801185:	50                   	push   %eax
  801186:	e8 29 ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  80118b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801191:	c9                   	leave  
  801192:	c3                   	ret    

00801193 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801199:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80119c:	50                   	push   %eax
  80119d:	ff 75 08             	pushl  0x8(%ebp)
  8011a0:	e8 9d ff ff ff       	call   801142 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011a5:	c9                   	leave  
  8011a6:	c3                   	ret    

008011a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	57                   	push   %edi
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 1c             	sub    $0x1c,%esp
  8011b0:	89 c7                	mov    %eax,%edi
  8011b2:	89 d6                	mov    %edx,%esi
  8011b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8011cb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8011ce:	39 d3                	cmp    %edx,%ebx
  8011d0:	72 05                	jb     8011d7 <printnum+0x30>
  8011d2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011d5:	77 45                	ja     80121c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011d7:	83 ec 0c             	sub    $0xc,%esp
  8011da:	ff 75 18             	pushl  0x18(%ebp)
  8011dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8011e0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011e3:	53                   	push   %ebx
  8011e4:	ff 75 10             	pushl  0x10(%ebp)
  8011e7:	83 ec 08             	sub    $0x8,%esp
  8011ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f6:	e8 e5 09 00 00       	call   801be0 <__udivdi3>
  8011fb:	83 c4 18             	add    $0x18,%esp
  8011fe:	52                   	push   %edx
  8011ff:	50                   	push   %eax
  801200:	89 f2                	mov    %esi,%edx
  801202:	89 f8                	mov    %edi,%eax
  801204:	e8 9e ff ff ff       	call   8011a7 <printnum>
  801209:	83 c4 20             	add    $0x20,%esp
  80120c:	eb 18                	jmp    801226 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80120e:	83 ec 08             	sub    $0x8,%esp
  801211:	56                   	push   %esi
  801212:	ff 75 18             	pushl  0x18(%ebp)
  801215:	ff d7                	call   *%edi
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	eb 03                	jmp    80121f <printnum+0x78>
  80121c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80121f:	83 eb 01             	sub    $0x1,%ebx
  801222:	85 db                	test   %ebx,%ebx
  801224:	7f e8                	jg     80120e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801226:	83 ec 08             	sub    $0x8,%esp
  801229:	56                   	push   %esi
  80122a:	83 ec 04             	sub    $0x4,%esp
  80122d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801230:	ff 75 e0             	pushl  -0x20(%ebp)
  801233:	ff 75 dc             	pushl  -0x24(%ebp)
  801236:	ff 75 d8             	pushl  -0x28(%ebp)
  801239:	e8 d2 0a 00 00       	call   801d10 <__umoddi3>
  80123e:	83 c4 14             	add    $0x14,%esp
  801241:	0f be 80 db 1f 80 00 	movsbl 0x801fdb(%eax),%eax
  801248:	50                   	push   %eax
  801249:	ff d7                	call   *%edi
}
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801251:	5b                   	pop    %ebx
  801252:	5e                   	pop    %esi
  801253:	5f                   	pop    %edi
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801259:	83 fa 01             	cmp    $0x1,%edx
  80125c:	7e 0e                	jle    80126c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80125e:	8b 10                	mov    (%eax),%edx
  801260:	8d 4a 08             	lea    0x8(%edx),%ecx
  801263:	89 08                	mov    %ecx,(%eax)
  801265:	8b 02                	mov    (%edx),%eax
  801267:	8b 52 04             	mov    0x4(%edx),%edx
  80126a:	eb 22                	jmp    80128e <getuint+0x38>
	else if (lflag)
  80126c:	85 d2                	test   %edx,%edx
  80126e:	74 10                	je     801280 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801270:	8b 10                	mov    (%eax),%edx
  801272:	8d 4a 04             	lea    0x4(%edx),%ecx
  801275:	89 08                	mov    %ecx,(%eax)
  801277:	8b 02                	mov    (%edx),%eax
  801279:	ba 00 00 00 00       	mov    $0x0,%edx
  80127e:	eb 0e                	jmp    80128e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801280:	8b 10                	mov    (%eax),%edx
  801282:	8d 4a 04             	lea    0x4(%edx),%ecx
  801285:	89 08                	mov    %ecx,(%eax)
  801287:	8b 02                	mov    (%edx),%eax
  801289:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801296:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80129a:	8b 10                	mov    (%eax),%edx
  80129c:	3b 50 04             	cmp    0x4(%eax),%edx
  80129f:	73 0a                	jae    8012ab <sprintputch+0x1b>
		*b->buf++ = ch;
  8012a1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8012a4:	89 08                	mov    %ecx,(%eax)
  8012a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a9:	88 02                	mov    %al,(%edx)
}
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8012b3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012b6:	50                   	push   %eax
  8012b7:	ff 75 10             	pushl  0x10(%ebp)
  8012ba:	ff 75 0c             	pushl  0xc(%ebp)
  8012bd:	ff 75 08             	pushl  0x8(%ebp)
  8012c0:	e8 05 00 00 00       	call   8012ca <vprintfmt>
	va_end(ap);
}
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	c9                   	leave  
  8012c9:	c3                   	ret    

008012ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	57                   	push   %edi
  8012ce:	56                   	push   %esi
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 2c             	sub    $0x2c,%esp
  8012d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012d9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012dc:	eb 12                	jmp    8012f0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	0f 84 89 03 00 00    	je     80166f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	53                   	push   %ebx
  8012ea:	50                   	push   %eax
  8012eb:	ff d6                	call   *%esi
  8012ed:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012f0:	83 c7 01             	add    $0x1,%edi
  8012f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012f7:	83 f8 25             	cmp    $0x25,%eax
  8012fa:	75 e2                	jne    8012de <vprintfmt+0x14>
  8012fc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801300:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801307:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80130e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801315:	ba 00 00 00 00       	mov    $0x0,%edx
  80131a:	eb 07                	jmp    801323 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80131f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801323:	8d 47 01             	lea    0x1(%edi),%eax
  801326:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801329:	0f b6 07             	movzbl (%edi),%eax
  80132c:	0f b6 c8             	movzbl %al,%ecx
  80132f:	83 e8 23             	sub    $0x23,%eax
  801332:	3c 55                	cmp    $0x55,%al
  801334:	0f 87 1a 03 00 00    	ja     801654 <vprintfmt+0x38a>
  80133a:	0f b6 c0             	movzbl %al,%eax
  80133d:	ff 24 85 20 21 80 00 	jmp    *0x802120(,%eax,4)
  801344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801347:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80134b:	eb d6                	jmp    801323 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801350:	b8 00 00 00 00       	mov    $0x0,%eax
  801355:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801358:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80135b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80135f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801362:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801365:	83 fa 09             	cmp    $0x9,%edx
  801368:	77 39                	ja     8013a3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80136a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80136d:	eb e9                	jmp    801358 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80136f:	8b 45 14             	mov    0x14(%ebp),%eax
  801372:	8d 48 04             	lea    0x4(%eax),%ecx
  801375:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801378:	8b 00                	mov    (%eax),%eax
  80137a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801380:	eb 27                	jmp    8013a9 <vprintfmt+0xdf>
  801382:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801385:	85 c0                	test   %eax,%eax
  801387:	b9 00 00 00 00       	mov    $0x0,%ecx
  80138c:	0f 49 c8             	cmovns %eax,%ecx
  80138f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801395:	eb 8c                	jmp    801323 <vprintfmt+0x59>
  801397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80139a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8013a1:	eb 80                	jmp    801323 <vprintfmt+0x59>
  8013a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013a6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8013a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013ad:	0f 89 70 ff ff ff    	jns    801323 <vprintfmt+0x59>
				width = precision, precision = -1;
  8013b3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8013b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013b9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8013c0:	e9 5e ff ff ff       	jmp    801323 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8013c5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8013cb:	e9 53 ff ff ff       	jmp    801323 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8013d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d3:	8d 50 04             	lea    0x4(%eax),%edx
  8013d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	53                   	push   %ebx
  8013dd:	ff 30                	pushl  (%eax)
  8013df:	ff d6                	call   *%esi
			break;
  8013e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013e7:	e9 04 ff ff ff       	jmp    8012f0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ef:	8d 50 04             	lea    0x4(%eax),%edx
  8013f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8013f5:	8b 00                	mov    (%eax),%eax
  8013f7:	99                   	cltd   
  8013f8:	31 d0                	xor    %edx,%eax
  8013fa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013fc:	83 f8 0f             	cmp    $0xf,%eax
  8013ff:	7f 0b                	jg     80140c <vprintfmt+0x142>
  801401:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  801408:	85 d2                	test   %edx,%edx
  80140a:	75 18                	jne    801424 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80140c:	50                   	push   %eax
  80140d:	68 f3 1f 80 00       	push   $0x801ff3
  801412:	53                   	push   %ebx
  801413:	56                   	push   %esi
  801414:	e8 94 fe ff ff       	call   8012ad <printfmt>
  801419:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80141c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80141f:	e9 cc fe ff ff       	jmp    8012f0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801424:	52                   	push   %edx
  801425:	68 5d 1f 80 00       	push   $0x801f5d
  80142a:	53                   	push   %ebx
  80142b:	56                   	push   %esi
  80142c:	e8 7c fe ff ff       	call   8012ad <printfmt>
  801431:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801434:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801437:	e9 b4 fe ff ff       	jmp    8012f0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80143c:	8b 45 14             	mov    0x14(%ebp),%eax
  80143f:	8d 50 04             	lea    0x4(%eax),%edx
  801442:	89 55 14             	mov    %edx,0x14(%ebp)
  801445:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801447:	85 ff                	test   %edi,%edi
  801449:	b8 ec 1f 80 00       	mov    $0x801fec,%eax
  80144e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801451:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801455:	0f 8e 94 00 00 00    	jle    8014ef <vprintfmt+0x225>
  80145b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80145f:	0f 84 98 00 00 00    	je     8014fd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801465:	83 ec 08             	sub    $0x8,%esp
  801468:	ff 75 d0             	pushl  -0x30(%ebp)
  80146b:	57                   	push   %edi
  80146c:	e8 86 02 00 00       	call   8016f7 <strnlen>
  801471:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801474:	29 c1                	sub    %eax,%ecx
  801476:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801479:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80147c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801480:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801483:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801486:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801488:	eb 0f                	jmp    801499 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	53                   	push   %ebx
  80148e:	ff 75 e0             	pushl  -0x20(%ebp)
  801491:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801493:	83 ef 01             	sub    $0x1,%edi
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	85 ff                	test   %edi,%edi
  80149b:	7f ed                	jg     80148a <vprintfmt+0x1c0>
  80149d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8014a0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8014a3:	85 c9                	test   %ecx,%ecx
  8014a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014aa:	0f 49 c1             	cmovns %ecx,%eax
  8014ad:	29 c1                	sub    %eax,%ecx
  8014af:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b8:	89 cb                	mov    %ecx,%ebx
  8014ba:	eb 4d                	jmp    801509 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8014bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014c0:	74 1b                	je     8014dd <vprintfmt+0x213>
  8014c2:	0f be c0             	movsbl %al,%eax
  8014c5:	83 e8 20             	sub    $0x20,%eax
  8014c8:	83 f8 5e             	cmp    $0x5e,%eax
  8014cb:	76 10                	jbe    8014dd <vprintfmt+0x213>
					putch('?', putdat);
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	ff 75 0c             	pushl  0xc(%ebp)
  8014d3:	6a 3f                	push   $0x3f
  8014d5:	ff 55 08             	call   *0x8(%ebp)
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	eb 0d                	jmp    8014ea <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	ff 75 0c             	pushl  0xc(%ebp)
  8014e3:	52                   	push   %edx
  8014e4:	ff 55 08             	call   *0x8(%ebp)
  8014e7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014ea:	83 eb 01             	sub    $0x1,%ebx
  8014ed:	eb 1a                	jmp    801509 <vprintfmt+0x23f>
  8014ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8014f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014fb:	eb 0c                	jmp    801509 <vprintfmt+0x23f>
  8014fd:	89 75 08             	mov    %esi,0x8(%ebp)
  801500:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801503:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801506:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801509:	83 c7 01             	add    $0x1,%edi
  80150c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801510:	0f be d0             	movsbl %al,%edx
  801513:	85 d2                	test   %edx,%edx
  801515:	74 23                	je     80153a <vprintfmt+0x270>
  801517:	85 f6                	test   %esi,%esi
  801519:	78 a1                	js     8014bc <vprintfmt+0x1f2>
  80151b:	83 ee 01             	sub    $0x1,%esi
  80151e:	79 9c                	jns    8014bc <vprintfmt+0x1f2>
  801520:	89 df                	mov    %ebx,%edi
  801522:	8b 75 08             	mov    0x8(%ebp),%esi
  801525:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801528:	eb 18                	jmp    801542 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80152a:	83 ec 08             	sub    $0x8,%esp
  80152d:	53                   	push   %ebx
  80152e:	6a 20                	push   $0x20
  801530:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801532:	83 ef 01             	sub    $0x1,%edi
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	eb 08                	jmp    801542 <vprintfmt+0x278>
  80153a:	89 df                	mov    %ebx,%edi
  80153c:	8b 75 08             	mov    0x8(%ebp),%esi
  80153f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801542:	85 ff                	test   %edi,%edi
  801544:	7f e4                	jg     80152a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801549:	e9 a2 fd ff ff       	jmp    8012f0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80154e:	83 fa 01             	cmp    $0x1,%edx
  801551:	7e 16                	jle    801569 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801553:	8b 45 14             	mov    0x14(%ebp),%eax
  801556:	8d 50 08             	lea    0x8(%eax),%edx
  801559:	89 55 14             	mov    %edx,0x14(%ebp)
  80155c:	8b 50 04             	mov    0x4(%eax),%edx
  80155f:	8b 00                	mov    (%eax),%eax
  801561:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801564:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801567:	eb 32                	jmp    80159b <vprintfmt+0x2d1>
	else if (lflag)
  801569:	85 d2                	test   %edx,%edx
  80156b:	74 18                	je     801585 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80156d:	8b 45 14             	mov    0x14(%ebp),%eax
  801570:	8d 50 04             	lea    0x4(%eax),%edx
  801573:	89 55 14             	mov    %edx,0x14(%ebp)
  801576:	8b 00                	mov    (%eax),%eax
  801578:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80157b:	89 c1                	mov    %eax,%ecx
  80157d:	c1 f9 1f             	sar    $0x1f,%ecx
  801580:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801583:	eb 16                	jmp    80159b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801585:	8b 45 14             	mov    0x14(%ebp),%eax
  801588:	8d 50 04             	lea    0x4(%eax),%edx
  80158b:	89 55 14             	mov    %edx,0x14(%ebp)
  80158e:	8b 00                	mov    (%eax),%eax
  801590:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801593:	89 c1                	mov    %eax,%ecx
  801595:	c1 f9 1f             	sar    $0x1f,%ecx
  801598:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80159b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80159e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8015a1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8015a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8015aa:	79 74                	jns    801620 <vprintfmt+0x356>
				putch('-', putdat);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	53                   	push   %ebx
  8015b0:	6a 2d                	push   $0x2d
  8015b2:	ff d6                	call   *%esi
				num = -(long long) num;
  8015b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8015b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8015ba:	f7 d8                	neg    %eax
  8015bc:	83 d2 00             	adc    $0x0,%edx
  8015bf:	f7 da                	neg    %edx
  8015c1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8015c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8015c9:	eb 55                	jmp    801620 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8015cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ce:	e8 83 fc ff ff       	call   801256 <getuint>
			base = 10;
  8015d3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015d8:	eb 46                	jmp    801620 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8015da:	8d 45 14             	lea    0x14(%ebp),%eax
  8015dd:	e8 74 fc ff ff       	call   801256 <getuint>
			base = 8;
  8015e2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015e7:	eb 37                	jmp    801620 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	53                   	push   %ebx
  8015ed:	6a 30                	push   $0x30
  8015ef:	ff d6                	call   *%esi
			putch('x', putdat);
  8015f1:	83 c4 08             	add    $0x8,%esp
  8015f4:	53                   	push   %ebx
  8015f5:	6a 78                	push   $0x78
  8015f7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fc:	8d 50 04             	lea    0x4(%eax),%edx
  8015ff:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801602:	8b 00                	mov    (%eax),%eax
  801604:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801609:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80160c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801611:	eb 0d                	jmp    801620 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801613:	8d 45 14             	lea    0x14(%ebp),%eax
  801616:	e8 3b fc ff ff       	call   801256 <getuint>
			base = 16;
  80161b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801620:	83 ec 0c             	sub    $0xc,%esp
  801623:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801627:	57                   	push   %edi
  801628:	ff 75 e0             	pushl  -0x20(%ebp)
  80162b:	51                   	push   %ecx
  80162c:	52                   	push   %edx
  80162d:	50                   	push   %eax
  80162e:	89 da                	mov    %ebx,%edx
  801630:	89 f0                	mov    %esi,%eax
  801632:	e8 70 fb ff ff       	call   8011a7 <printnum>
			break;
  801637:	83 c4 20             	add    $0x20,%esp
  80163a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80163d:	e9 ae fc ff ff       	jmp    8012f0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	53                   	push   %ebx
  801646:	51                   	push   %ecx
  801647:	ff d6                	call   *%esi
			break;
  801649:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80164f:	e9 9c fc ff ff       	jmp    8012f0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801654:	83 ec 08             	sub    $0x8,%esp
  801657:	53                   	push   %ebx
  801658:	6a 25                	push   $0x25
  80165a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	eb 03                	jmp    801664 <vprintfmt+0x39a>
  801661:	83 ef 01             	sub    $0x1,%edi
  801664:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801668:	75 f7                	jne    801661 <vprintfmt+0x397>
  80166a:	e9 81 fc ff ff       	jmp    8012f0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80166f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	5f                   	pop    %edi
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	83 ec 18             	sub    $0x18,%esp
  80167d:	8b 45 08             	mov    0x8(%ebp),%eax
  801680:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801683:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801686:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80168a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80168d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801694:	85 c0                	test   %eax,%eax
  801696:	74 26                	je     8016be <vsnprintf+0x47>
  801698:	85 d2                	test   %edx,%edx
  80169a:	7e 22                	jle    8016be <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80169c:	ff 75 14             	pushl  0x14(%ebp)
  80169f:	ff 75 10             	pushl  0x10(%ebp)
  8016a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016a5:	50                   	push   %eax
  8016a6:	68 90 12 80 00       	push   $0x801290
  8016ab:	e8 1a fc ff ff       	call   8012ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	eb 05                	jmp    8016c3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016ce:	50                   	push   %eax
  8016cf:	ff 75 10             	pushl  0x10(%ebp)
  8016d2:	ff 75 0c             	pushl  0xc(%ebp)
  8016d5:	ff 75 08             	pushl  0x8(%ebp)
  8016d8:	e8 9a ff ff ff       	call   801677 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ea:	eb 03                	jmp    8016ef <strlen+0x10>
		n++;
  8016ec:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ef:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016f3:	75 f7                	jne    8016ec <strlen+0xd>
		n++;
	return n;
}
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801700:	ba 00 00 00 00       	mov    $0x0,%edx
  801705:	eb 03                	jmp    80170a <strnlen+0x13>
		n++;
  801707:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80170a:	39 c2                	cmp    %eax,%edx
  80170c:	74 08                	je     801716 <strnlen+0x1f>
  80170e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801712:	75 f3                	jne    801707 <strnlen+0x10>
  801714:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	53                   	push   %ebx
  80171c:	8b 45 08             	mov    0x8(%ebp),%eax
  80171f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801722:	89 c2                	mov    %eax,%edx
  801724:	83 c2 01             	add    $0x1,%edx
  801727:	83 c1 01             	add    $0x1,%ecx
  80172a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80172e:	88 5a ff             	mov    %bl,-0x1(%edx)
  801731:	84 db                	test   %bl,%bl
  801733:	75 ef                	jne    801724 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801735:	5b                   	pop    %ebx
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    

00801738 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	53                   	push   %ebx
  80173c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80173f:	53                   	push   %ebx
  801740:	e8 9a ff ff ff       	call   8016df <strlen>
  801745:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801748:	ff 75 0c             	pushl  0xc(%ebp)
  80174b:	01 d8                	add    %ebx,%eax
  80174d:	50                   	push   %eax
  80174e:	e8 c5 ff ff ff       	call   801718 <strcpy>
	return dst;
}
  801753:	89 d8                	mov    %ebx,%eax
  801755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	56                   	push   %esi
  80175e:	53                   	push   %ebx
  80175f:	8b 75 08             	mov    0x8(%ebp),%esi
  801762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801765:	89 f3                	mov    %esi,%ebx
  801767:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80176a:	89 f2                	mov    %esi,%edx
  80176c:	eb 0f                	jmp    80177d <strncpy+0x23>
		*dst++ = *src;
  80176e:	83 c2 01             	add    $0x1,%edx
  801771:	0f b6 01             	movzbl (%ecx),%eax
  801774:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801777:	80 39 01             	cmpb   $0x1,(%ecx)
  80177a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80177d:	39 da                	cmp    %ebx,%edx
  80177f:	75 ed                	jne    80176e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801781:	89 f0                	mov    %esi,%eax
  801783:	5b                   	pop    %ebx
  801784:	5e                   	pop    %esi
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	56                   	push   %esi
  80178b:	53                   	push   %ebx
  80178c:	8b 75 08             	mov    0x8(%ebp),%esi
  80178f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801792:	8b 55 10             	mov    0x10(%ebp),%edx
  801795:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801797:	85 d2                	test   %edx,%edx
  801799:	74 21                	je     8017bc <strlcpy+0x35>
  80179b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80179f:	89 f2                	mov    %esi,%edx
  8017a1:	eb 09                	jmp    8017ac <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017a3:	83 c2 01             	add    $0x1,%edx
  8017a6:	83 c1 01             	add    $0x1,%ecx
  8017a9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017ac:	39 c2                	cmp    %eax,%edx
  8017ae:	74 09                	je     8017b9 <strlcpy+0x32>
  8017b0:	0f b6 19             	movzbl (%ecx),%ebx
  8017b3:	84 db                	test   %bl,%bl
  8017b5:	75 ec                	jne    8017a3 <strlcpy+0x1c>
  8017b7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017b9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017bc:	29 f0                	sub    %esi,%eax
}
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017cb:	eb 06                	jmp    8017d3 <strcmp+0x11>
		p++, q++;
  8017cd:	83 c1 01             	add    $0x1,%ecx
  8017d0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017d3:	0f b6 01             	movzbl (%ecx),%eax
  8017d6:	84 c0                	test   %al,%al
  8017d8:	74 04                	je     8017de <strcmp+0x1c>
  8017da:	3a 02                	cmp    (%edx),%al
  8017dc:	74 ef                	je     8017cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017de:	0f b6 c0             	movzbl %al,%eax
  8017e1:	0f b6 12             	movzbl (%edx),%edx
  8017e4:	29 d0                	sub    %edx,%eax
}
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    

008017e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	53                   	push   %ebx
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f2:	89 c3                	mov    %eax,%ebx
  8017f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017f7:	eb 06                	jmp    8017ff <strncmp+0x17>
		n--, p++, q++;
  8017f9:	83 c0 01             	add    $0x1,%eax
  8017fc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017ff:	39 d8                	cmp    %ebx,%eax
  801801:	74 15                	je     801818 <strncmp+0x30>
  801803:	0f b6 08             	movzbl (%eax),%ecx
  801806:	84 c9                	test   %cl,%cl
  801808:	74 04                	je     80180e <strncmp+0x26>
  80180a:	3a 0a                	cmp    (%edx),%cl
  80180c:	74 eb                	je     8017f9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80180e:	0f b6 00             	movzbl (%eax),%eax
  801811:	0f b6 12             	movzbl (%edx),%edx
  801814:	29 d0                	sub    %edx,%eax
  801816:	eb 05                	jmp    80181d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801818:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80181d:	5b                   	pop    %ebx
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80182a:	eb 07                	jmp    801833 <strchr+0x13>
		if (*s == c)
  80182c:	38 ca                	cmp    %cl,%dl
  80182e:	74 0f                	je     80183f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801830:	83 c0 01             	add    $0x1,%eax
  801833:	0f b6 10             	movzbl (%eax),%edx
  801836:	84 d2                	test   %dl,%dl
  801838:	75 f2                	jne    80182c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80183a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183f:	5d                   	pop    %ebp
  801840:	c3                   	ret    

00801841 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80184b:	eb 03                	jmp    801850 <strfind+0xf>
  80184d:	83 c0 01             	add    $0x1,%eax
  801850:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801853:	38 ca                	cmp    %cl,%dl
  801855:	74 04                	je     80185b <strfind+0x1a>
  801857:	84 d2                	test   %dl,%dl
  801859:	75 f2                	jne    80184d <strfind+0xc>
			break;
	return (char *) s;
}
  80185b:	5d                   	pop    %ebp
  80185c:	c3                   	ret    

0080185d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	57                   	push   %edi
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
  801863:	8b 7d 08             	mov    0x8(%ebp),%edi
  801866:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801869:	85 c9                	test   %ecx,%ecx
  80186b:	74 36                	je     8018a3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80186d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801873:	75 28                	jne    80189d <memset+0x40>
  801875:	f6 c1 03             	test   $0x3,%cl
  801878:	75 23                	jne    80189d <memset+0x40>
		c &= 0xFF;
  80187a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80187e:	89 d3                	mov    %edx,%ebx
  801880:	c1 e3 08             	shl    $0x8,%ebx
  801883:	89 d6                	mov    %edx,%esi
  801885:	c1 e6 18             	shl    $0x18,%esi
  801888:	89 d0                	mov    %edx,%eax
  80188a:	c1 e0 10             	shl    $0x10,%eax
  80188d:	09 f0                	or     %esi,%eax
  80188f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801891:	89 d8                	mov    %ebx,%eax
  801893:	09 d0                	or     %edx,%eax
  801895:	c1 e9 02             	shr    $0x2,%ecx
  801898:	fc                   	cld    
  801899:	f3 ab                	rep stos %eax,%es:(%edi)
  80189b:	eb 06                	jmp    8018a3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80189d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a0:	fc                   	cld    
  8018a1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018a3:	89 f8                	mov    %edi,%eax
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5f                   	pop    %edi
  8018a8:	5d                   	pop    %ebp
  8018a9:	c3                   	ret    

008018aa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	57                   	push   %edi
  8018ae:	56                   	push   %esi
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018b8:	39 c6                	cmp    %eax,%esi
  8018ba:	73 35                	jae    8018f1 <memmove+0x47>
  8018bc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018bf:	39 d0                	cmp    %edx,%eax
  8018c1:	73 2e                	jae    8018f1 <memmove+0x47>
		s += n;
		d += n;
  8018c3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c6:	89 d6                	mov    %edx,%esi
  8018c8:	09 fe                	or     %edi,%esi
  8018ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018d0:	75 13                	jne    8018e5 <memmove+0x3b>
  8018d2:	f6 c1 03             	test   $0x3,%cl
  8018d5:	75 0e                	jne    8018e5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018d7:	83 ef 04             	sub    $0x4,%edi
  8018da:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018dd:	c1 e9 02             	shr    $0x2,%ecx
  8018e0:	fd                   	std    
  8018e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e3:	eb 09                	jmp    8018ee <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018e5:	83 ef 01             	sub    $0x1,%edi
  8018e8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018eb:	fd                   	std    
  8018ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ee:	fc                   	cld    
  8018ef:	eb 1d                	jmp    80190e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f1:	89 f2                	mov    %esi,%edx
  8018f3:	09 c2                	or     %eax,%edx
  8018f5:	f6 c2 03             	test   $0x3,%dl
  8018f8:	75 0f                	jne    801909 <memmove+0x5f>
  8018fa:	f6 c1 03             	test   $0x3,%cl
  8018fd:	75 0a                	jne    801909 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018ff:	c1 e9 02             	shr    $0x2,%ecx
  801902:	89 c7                	mov    %eax,%edi
  801904:	fc                   	cld    
  801905:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801907:	eb 05                	jmp    80190e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801909:	89 c7                	mov    %eax,%edi
  80190b:	fc                   	cld    
  80190c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80190e:	5e                   	pop    %esi
  80190f:	5f                   	pop    %edi
  801910:	5d                   	pop    %ebp
  801911:	c3                   	ret    

00801912 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801915:	ff 75 10             	pushl  0x10(%ebp)
  801918:	ff 75 0c             	pushl  0xc(%ebp)
  80191b:	ff 75 08             	pushl  0x8(%ebp)
  80191e:	e8 87 ff ff ff       	call   8018aa <memmove>
}
  801923:	c9                   	leave  
  801924:	c3                   	ret    

00801925 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	56                   	push   %esi
  801929:	53                   	push   %ebx
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801930:	89 c6                	mov    %eax,%esi
  801932:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801935:	eb 1a                	jmp    801951 <memcmp+0x2c>
		if (*s1 != *s2)
  801937:	0f b6 08             	movzbl (%eax),%ecx
  80193a:	0f b6 1a             	movzbl (%edx),%ebx
  80193d:	38 d9                	cmp    %bl,%cl
  80193f:	74 0a                	je     80194b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801941:	0f b6 c1             	movzbl %cl,%eax
  801944:	0f b6 db             	movzbl %bl,%ebx
  801947:	29 d8                	sub    %ebx,%eax
  801949:	eb 0f                	jmp    80195a <memcmp+0x35>
		s1++, s2++;
  80194b:	83 c0 01             	add    $0x1,%eax
  80194e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801951:	39 f0                	cmp    %esi,%eax
  801953:	75 e2                	jne    801937 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801955:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195a:	5b                   	pop    %ebx
  80195b:	5e                   	pop    %esi
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	53                   	push   %ebx
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801965:	89 c1                	mov    %eax,%ecx
  801967:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80196a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196e:	eb 0a                	jmp    80197a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801970:	0f b6 10             	movzbl (%eax),%edx
  801973:	39 da                	cmp    %ebx,%edx
  801975:	74 07                	je     80197e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801977:	83 c0 01             	add    $0x1,%eax
  80197a:	39 c8                	cmp    %ecx,%eax
  80197c:	72 f2                	jb     801970 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80197e:	5b                   	pop    %ebx
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	57                   	push   %edi
  801985:	56                   	push   %esi
  801986:	53                   	push   %ebx
  801987:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80198a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198d:	eb 03                	jmp    801992 <strtol+0x11>
		s++;
  80198f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801992:	0f b6 01             	movzbl (%ecx),%eax
  801995:	3c 20                	cmp    $0x20,%al
  801997:	74 f6                	je     80198f <strtol+0xe>
  801999:	3c 09                	cmp    $0x9,%al
  80199b:	74 f2                	je     80198f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80199d:	3c 2b                	cmp    $0x2b,%al
  80199f:	75 0a                	jne    8019ab <strtol+0x2a>
		s++;
  8019a1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a9:	eb 11                	jmp    8019bc <strtol+0x3b>
  8019ab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019b0:	3c 2d                	cmp    $0x2d,%al
  8019b2:	75 08                	jne    8019bc <strtol+0x3b>
		s++, neg = 1;
  8019b4:	83 c1 01             	add    $0x1,%ecx
  8019b7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019bc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c2:	75 15                	jne    8019d9 <strtol+0x58>
  8019c4:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c7:	75 10                	jne    8019d9 <strtol+0x58>
  8019c9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019cd:	75 7c                	jne    801a4b <strtol+0xca>
		s += 2, base = 16;
  8019cf:	83 c1 02             	add    $0x2,%ecx
  8019d2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d7:	eb 16                	jmp    8019ef <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019d9:	85 db                	test   %ebx,%ebx
  8019db:	75 12                	jne    8019ef <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019dd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019e2:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e5:	75 08                	jne    8019ef <strtol+0x6e>
		s++, base = 8;
  8019e7:	83 c1 01             	add    $0x1,%ecx
  8019ea:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019f7:	0f b6 11             	movzbl (%ecx),%edx
  8019fa:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019fd:	89 f3                	mov    %esi,%ebx
  8019ff:	80 fb 09             	cmp    $0x9,%bl
  801a02:	77 08                	ja     801a0c <strtol+0x8b>
			dig = *s - '0';
  801a04:	0f be d2             	movsbl %dl,%edx
  801a07:	83 ea 30             	sub    $0x30,%edx
  801a0a:	eb 22                	jmp    801a2e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a0c:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a0f:	89 f3                	mov    %esi,%ebx
  801a11:	80 fb 19             	cmp    $0x19,%bl
  801a14:	77 08                	ja     801a1e <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a16:	0f be d2             	movsbl %dl,%edx
  801a19:	83 ea 57             	sub    $0x57,%edx
  801a1c:	eb 10                	jmp    801a2e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a1e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a21:	89 f3                	mov    %esi,%ebx
  801a23:	80 fb 19             	cmp    $0x19,%bl
  801a26:	77 16                	ja     801a3e <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a28:	0f be d2             	movsbl %dl,%edx
  801a2b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a2e:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a31:	7d 0b                	jge    801a3e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a33:	83 c1 01             	add    $0x1,%ecx
  801a36:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a3a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a3c:	eb b9                	jmp    8019f7 <strtol+0x76>

	if (endptr)
  801a3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a42:	74 0d                	je     801a51 <strtol+0xd0>
		*endptr = (char *) s;
  801a44:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a47:	89 0e                	mov    %ecx,(%esi)
  801a49:	eb 06                	jmp    801a51 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a4b:	85 db                	test   %ebx,%ebx
  801a4d:	74 98                	je     8019e7 <strtol+0x66>
  801a4f:	eb 9e                	jmp    8019ef <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a51:	89 c2                	mov    %eax,%edx
  801a53:	f7 da                	neg    %edx
  801a55:	85 ff                	test   %edi,%edi
  801a57:	0f 45 c2             	cmovne %edx,%eax
}
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5f                   	pop    %edi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  801a65:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a6c:	75 2a                	jne    801a98 <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801a6e:	83 ec 04             	sub    $0x4,%esp
  801a71:	6a 06                	push   $0x6
  801a73:	68 00 f0 bf ee       	push   $0xeebff000
  801a78:	6a 00                	push   $0x0
  801a7a:	e8 f1 e6 ff ff       	call   800170 <sys_page_alloc>
			 if (a < 0)
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	85 c0                	test   %eax,%eax
  801a84:	79 12                	jns    801a98 <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801a86:	50                   	push   %eax
  801a87:	68 e0 22 80 00       	push   $0x8022e0
  801a8c:	6a 21                	push   $0x21
  801a8e:	68 fa 22 80 00       	push   $0x8022fa
  801a93:	e8 22 f6 ff ff       	call   8010ba <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  801a98:	e8 95 e6 ff ff       	call   800132 <sys_getenvid>
  801a9d:	83 ec 08             	sub    $0x8,%esp
  801aa0:	68 61 03 80 00       	push   $0x800361
  801aa5:	50                   	push   %eax
  801aa6:	e8 10 e8 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	c9                   	leave  
  801ab7:	c3                   	ret    

00801ab8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801ac6:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801ac8:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801acd:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	50                   	push   %eax
  801ad4:	e8 47 e8 ff ff       	call   800320 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801ad9:	83 c4 10             	add    $0x10,%esp
  801adc:	85 c0                	test   %eax,%eax
  801ade:	78 0e                	js     801aee <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801ae0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ae6:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801ae9:	8b 52 78             	mov    0x78(%edx),%edx
  801aec:	eb 0a                	jmp    801af8 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801aee:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801af3:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801af8:	85 f6                	test   %esi,%esi
  801afa:	74 02                	je     801afe <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801afc:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801afe:	85 db                	test   %ebx,%ebx
  801b00:	74 02                	je     801b04 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801b02:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 08                	js     801b10 <ipc_recv+0x58>
  801b08:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0d:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801b10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    

00801b17 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	57                   	push   %edi
  801b1b:	56                   	push   %esi
  801b1c:	53                   	push   %ebx
  801b1d:	83 ec 0c             	sub    $0xc,%esp
  801b20:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b23:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801b29:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801b2b:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801b30:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801b33:	ff 75 14             	pushl  0x14(%ebp)
  801b36:	53                   	push   %ebx
  801b37:	56                   	push   %esi
  801b38:	57                   	push   %edi
  801b39:	e8 bf e7 ff ff       	call   8002fd <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b44:	75 07                	jne    801b4d <ipc_send+0x36>
				    sys_yield();
  801b46:	e8 06 e6 ff ff       	call   800151 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801b4b:	eb e6                	jmp    801b33 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801b4d:	85 c0                	test   %eax,%eax
  801b4f:	74 12                	je     801b63 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801b51:	50                   	push   %eax
  801b52:	68 08 23 80 00       	push   $0x802308
  801b57:	6a 4b                	push   $0x4b
  801b59:	68 1c 23 80 00       	push   $0x80231c
  801b5e:	e8 57 f5 ff ff       	call   8010ba <_panic>
			 }
	   }
}
  801b63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b66:	5b                   	pop    %ebx
  801b67:	5e                   	pop    %esi
  801b68:	5f                   	pop    %edi
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    

00801b6b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801b71:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801b76:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b79:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b7f:	8b 52 50             	mov    0x50(%edx),%edx
  801b82:	39 ca                	cmp    %ecx,%edx
  801b84:	75 0d                	jne    801b93 <ipc_find_env+0x28>
				    return envs[i].env_id;
  801b86:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b89:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b8e:	8b 40 48             	mov    0x48(%eax),%eax
  801b91:	eb 0f                	jmp    801ba2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801b93:	83 c0 01             	add    $0x1,%eax
  801b96:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b9b:	75 d9                	jne    801b76 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801b9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba2:	5d                   	pop    %ebp
  801ba3:	c3                   	ret    

00801ba4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801baa:	89 d0                	mov    %edx,%eax
  801bac:	c1 e8 16             	shr    $0x16,%eax
  801baf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bb6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bbb:	f6 c1 01             	test   $0x1,%cl
  801bbe:	74 1d                	je     801bdd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bc0:	c1 ea 0c             	shr    $0xc,%edx
  801bc3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bca:	f6 c2 01             	test   $0x1,%dl
  801bcd:	74 0e                	je     801bdd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bcf:	c1 ea 0c             	shr    $0xc,%edx
  801bd2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bd9:	ef 
  801bda:	0f b7 c0             	movzwl %ax,%eax
}
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    
  801bdf:	90                   	nop

00801be0 <__udivdi3>:
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	83 ec 1c             	sub    $0x1c,%esp
  801be7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801beb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bf7:	85 f6                	test   %esi,%esi
  801bf9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bfd:	89 ca                	mov    %ecx,%edx
  801bff:	89 f8                	mov    %edi,%eax
  801c01:	75 3d                	jne    801c40 <__udivdi3+0x60>
  801c03:	39 cf                	cmp    %ecx,%edi
  801c05:	0f 87 c5 00 00 00    	ja     801cd0 <__udivdi3+0xf0>
  801c0b:	85 ff                	test   %edi,%edi
  801c0d:	89 fd                	mov    %edi,%ebp
  801c0f:	75 0b                	jne    801c1c <__udivdi3+0x3c>
  801c11:	b8 01 00 00 00       	mov    $0x1,%eax
  801c16:	31 d2                	xor    %edx,%edx
  801c18:	f7 f7                	div    %edi
  801c1a:	89 c5                	mov    %eax,%ebp
  801c1c:	89 c8                	mov    %ecx,%eax
  801c1e:	31 d2                	xor    %edx,%edx
  801c20:	f7 f5                	div    %ebp
  801c22:	89 c1                	mov    %eax,%ecx
  801c24:	89 d8                	mov    %ebx,%eax
  801c26:	89 cf                	mov    %ecx,%edi
  801c28:	f7 f5                	div    %ebp
  801c2a:	89 c3                	mov    %eax,%ebx
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
  801c40:	39 ce                	cmp    %ecx,%esi
  801c42:	77 74                	ja     801cb8 <__udivdi3+0xd8>
  801c44:	0f bd fe             	bsr    %esi,%edi
  801c47:	83 f7 1f             	xor    $0x1f,%edi
  801c4a:	0f 84 98 00 00 00    	je     801ce8 <__udivdi3+0x108>
  801c50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	89 c5                	mov    %eax,%ebp
  801c59:	29 fb                	sub    %edi,%ebx
  801c5b:	d3 e6                	shl    %cl,%esi
  801c5d:	89 d9                	mov    %ebx,%ecx
  801c5f:	d3 ed                	shr    %cl,%ebp
  801c61:	89 f9                	mov    %edi,%ecx
  801c63:	d3 e0                	shl    %cl,%eax
  801c65:	09 ee                	or     %ebp,%esi
  801c67:	89 d9                	mov    %ebx,%ecx
  801c69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6d:	89 d5                	mov    %edx,%ebp
  801c6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c73:	d3 ed                	shr    %cl,%ebp
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e2                	shl    %cl,%edx
  801c79:	89 d9                	mov    %ebx,%ecx
  801c7b:	d3 e8                	shr    %cl,%eax
  801c7d:	09 c2                	or     %eax,%edx
  801c7f:	89 d0                	mov    %edx,%eax
  801c81:	89 ea                	mov    %ebp,%edx
  801c83:	f7 f6                	div    %esi
  801c85:	89 d5                	mov    %edx,%ebp
  801c87:	89 c3                	mov    %eax,%ebx
  801c89:	f7 64 24 0c          	mull   0xc(%esp)
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	72 10                	jb     801ca1 <__udivdi3+0xc1>
  801c91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	d3 e6                	shl    %cl,%esi
  801c99:	39 c6                	cmp    %eax,%esi
  801c9b:	73 07                	jae    801ca4 <__udivdi3+0xc4>
  801c9d:	39 d5                	cmp    %edx,%ebp
  801c9f:	75 03                	jne    801ca4 <__udivdi3+0xc4>
  801ca1:	83 eb 01             	sub    $0x1,%ebx
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 d8                	mov    %ebx,%eax
  801ca8:	89 fa                	mov    %edi,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	31 ff                	xor    %edi,%edi
  801cba:	31 db                	xor    %ebx,%ebx
  801cbc:	89 d8                	mov    %ebx,%eax
  801cbe:	89 fa                	mov    %edi,%edx
  801cc0:	83 c4 1c             	add    $0x1c,%esp
  801cc3:	5b                   	pop    %ebx
  801cc4:	5e                   	pop    %esi
  801cc5:	5f                   	pop    %edi
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    
  801cc8:	90                   	nop
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	89 d8                	mov    %ebx,%eax
  801cd2:	f7 f7                	div    %edi
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 c3                	mov    %eax,%ebx
  801cd8:	89 d8                	mov    %ebx,%eax
  801cda:	89 fa                	mov    %edi,%edx
  801cdc:	83 c4 1c             	add    $0x1c,%esp
  801cdf:	5b                   	pop    %ebx
  801ce0:	5e                   	pop    %esi
  801ce1:	5f                   	pop    %edi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    
  801ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	39 ce                	cmp    %ecx,%esi
  801cea:	72 0c                	jb     801cf8 <__udivdi3+0x118>
  801cec:	31 db                	xor    %ebx,%ebx
  801cee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cf2:	0f 87 34 ff ff ff    	ja     801c2c <__udivdi3+0x4c>
  801cf8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cfd:	e9 2a ff ff ff       	jmp    801c2c <__udivdi3+0x4c>
  801d02:	66 90                	xchg   %ax,%ax
  801d04:	66 90                	xchg   %ax,%ax
  801d06:	66 90                	xchg   %ax,%ax
  801d08:	66 90                	xchg   %ax,%ax
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

00801d10 <__umoddi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	83 ec 1c             	sub    $0x1c,%esp
  801d17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d27:	85 d2                	test   %edx,%edx
  801d29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d31:	89 f3                	mov    %esi,%ebx
  801d33:	89 3c 24             	mov    %edi,(%esp)
  801d36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3a:	75 1c                	jne    801d58 <__umoddi3+0x48>
  801d3c:	39 f7                	cmp    %esi,%edi
  801d3e:	76 50                	jbe    801d90 <__umoddi3+0x80>
  801d40:	89 c8                	mov    %ecx,%eax
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	f7 f7                	div    %edi
  801d46:	89 d0                	mov    %edx,%eax
  801d48:	31 d2                	xor    %edx,%edx
  801d4a:	83 c4 1c             	add    $0x1c,%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
  801d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d58:	39 f2                	cmp    %esi,%edx
  801d5a:	89 d0                	mov    %edx,%eax
  801d5c:	77 52                	ja     801db0 <__umoddi3+0xa0>
  801d5e:	0f bd ea             	bsr    %edx,%ebp
  801d61:	83 f5 1f             	xor    $0x1f,%ebp
  801d64:	75 5a                	jne    801dc0 <__umoddi3+0xb0>
  801d66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d6a:	0f 82 e0 00 00 00    	jb     801e50 <__umoddi3+0x140>
  801d70:	39 0c 24             	cmp    %ecx,(%esp)
  801d73:	0f 86 d7 00 00 00    	jbe    801e50 <__umoddi3+0x140>
  801d79:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d81:	83 c4 1c             	add    $0x1c,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5f                   	pop    %edi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	85 ff                	test   %edi,%edi
  801d92:	89 fd                	mov    %edi,%ebp
  801d94:	75 0b                	jne    801da1 <__umoddi3+0x91>
  801d96:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f7                	div    %edi
  801d9f:	89 c5                	mov    %eax,%ebp
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f5                	div    %ebp
  801da7:	89 c8                	mov    %ecx,%eax
  801da9:	f7 f5                	div    %ebp
  801dab:	89 d0                	mov    %edx,%eax
  801dad:	eb 99                	jmp    801d48 <__umoddi3+0x38>
  801daf:	90                   	nop
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 f2                	mov    %esi,%edx
  801db4:	83 c4 1c             	add    $0x1c,%esp
  801db7:	5b                   	pop    %ebx
  801db8:	5e                   	pop    %esi
  801db9:	5f                   	pop    %edi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    
  801dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	8b 34 24             	mov    (%esp),%esi
  801dc3:	bf 20 00 00 00       	mov    $0x20,%edi
  801dc8:	89 e9                	mov    %ebp,%ecx
  801dca:	29 ef                	sub    %ebp,%edi
  801dcc:	d3 e0                	shl    %cl,%eax
  801dce:	89 f9                	mov    %edi,%ecx
  801dd0:	89 f2                	mov    %esi,%edx
  801dd2:	d3 ea                	shr    %cl,%edx
  801dd4:	89 e9                	mov    %ebp,%ecx
  801dd6:	09 c2                	or     %eax,%edx
  801dd8:	89 d8                	mov    %ebx,%eax
  801dda:	89 14 24             	mov    %edx,(%esp)
  801ddd:	89 f2                	mov    %esi,%edx
  801ddf:	d3 e2                	shl    %cl,%edx
  801de1:	89 f9                	mov    %edi,%ecx
  801de3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801de7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801deb:	d3 e8                	shr    %cl,%eax
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	89 c6                	mov    %eax,%esi
  801df1:	d3 e3                	shl    %cl,%ebx
  801df3:	89 f9                	mov    %edi,%ecx
  801df5:	89 d0                	mov    %edx,%eax
  801df7:	d3 e8                	shr    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	09 d8                	or     %ebx,%eax
  801dfd:	89 d3                	mov    %edx,%ebx
  801dff:	89 f2                	mov    %esi,%edx
  801e01:	f7 34 24             	divl   (%esp)
  801e04:	89 d6                	mov    %edx,%esi
  801e06:	d3 e3                	shl    %cl,%ebx
  801e08:	f7 64 24 04          	mull   0x4(%esp)
  801e0c:	39 d6                	cmp    %edx,%esi
  801e0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e12:	89 d1                	mov    %edx,%ecx
  801e14:	89 c3                	mov    %eax,%ebx
  801e16:	72 08                	jb     801e20 <__umoddi3+0x110>
  801e18:	75 11                	jne    801e2b <__umoddi3+0x11b>
  801e1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e1e:	73 0b                	jae    801e2b <__umoddi3+0x11b>
  801e20:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e24:	1b 14 24             	sbb    (%esp),%edx
  801e27:	89 d1                	mov    %edx,%ecx
  801e29:	89 c3                	mov    %eax,%ebx
  801e2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e2f:	29 da                	sub    %ebx,%edx
  801e31:	19 ce                	sbb    %ecx,%esi
  801e33:	89 f9                	mov    %edi,%ecx
  801e35:	89 f0                	mov    %esi,%eax
  801e37:	d3 e0                	shl    %cl,%eax
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	d3 ea                	shr    %cl,%edx
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	d3 ee                	shr    %cl,%esi
  801e41:	09 d0                	or     %edx,%eax
  801e43:	89 f2                	mov    %esi,%edx
  801e45:	83 c4 1c             	add    $0x1c,%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5f                   	pop    %edi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    
  801e4d:	8d 76 00             	lea    0x0(%esi),%esi
  801e50:	29 f9                	sub    %edi,%ecx
  801e52:	19 d6                	sbb    %edx,%esi
  801e54:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e5c:	e9 18 ff ff ff       	jmp    801d79 <__umoddi3+0x69>
