
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 87 04 00 00       	call   800526 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 18 1e 80 00       	push   $0x801e18
  800118:	6a 23                	push   $0x23
  80011a:	68 35 1e 80 00       	push   $0x801e35
  80011f:	e8 6a 0f 00 00       	call   80108e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 18 1e 80 00       	push   $0x801e18
  800199:	6a 23                	push   $0x23
  80019b:	68 35 1e 80 00       	push   $0x801e35
  8001a0:	e8 e9 0e 00 00       	call   80108e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 18 1e 80 00       	push   $0x801e18
  8001db:	6a 23                	push   $0x23
  8001dd:	68 35 1e 80 00       	push   $0x801e35
  8001e2:	e8 a7 0e 00 00       	call   80108e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 18 1e 80 00       	push   $0x801e18
  80021d:	6a 23                	push   $0x23
  80021f:	68 35 1e 80 00       	push   $0x801e35
  800224:	e8 65 0e 00 00       	call   80108e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 18 1e 80 00       	push   $0x801e18
  80025f:	6a 23                	push   $0x23
  800261:	68 35 1e 80 00       	push   $0x801e35
  800266:	e8 23 0e 00 00       	call   80108e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 18 1e 80 00       	push   $0x801e18
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 35 1e 80 00       	push   $0x801e35
  8002a8:	e8 e1 0d 00 00       	call   80108e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 18 1e 80 00       	push   $0x801e18
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 35 1e 80 00       	push   $0x801e35
  8002ea:	e8 9f 0d 00 00       	call   80108e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 18 1e 80 00       	push   $0x801e18
  800347:	6a 23                	push   $0x23
  800349:	68 35 1e 80 00       	push   $0x801e35
  80034e:	e8 3b 0d 00 00       	call   80108e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 11                	je     8003af <fd_alloc+0x2d>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	75 09                	jne    8003b8 <fd_alloc+0x36>
			*fd_store = fd;
  8003af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b6:	eb 17                	jmp    8003cf <fd_alloc+0x4d>
  8003b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003c2:	75 c9                	jne    80038d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	eb 13                	jmp    800425 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 0c                	jmp    800425 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb 05                	jmp    800425 <fd_lookup+0x54>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba c0 1e 80 00       	mov    $0x801ec0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	eb 13                	jmp    80044a <dev_lookup+0x23>
  800437:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	75 0c                	jne    80044a <dev_lookup+0x23>
			*dev = devtab[i];
  80043e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800441:	89 01                	mov    %eax,(%ecx)
			return 0;
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	eb 2e                	jmp    800478 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	85 c0                	test   %eax,%eax
  80044e:	75 e7                	jne    800437 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800450:	a1 04 40 80 00       	mov    0x804004,%eax
  800455:	8b 40 48             	mov    0x48(%eax),%eax
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	51                   	push   %ecx
  80045c:	50                   	push   %eax
  80045d:	68 44 1e 80 00       	push   $0x801e44
  800462:	e8 00 0d 00 00       	call   801167 <cprintf>
	*dev = 0;
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 10             	sub    $0x10,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80048b:	50                   	push   %eax
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
  800495:	50                   	push   %eax
  800496:	e8 36 ff ff ff       	call   8003d1 <fd_lookup>
  80049b:	83 c4 08             	add    $0x8,%esp
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	78 05                	js     8004a7 <fd_close+0x2d>
	    || fd != fd2)
  8004a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a5:	74 0c                	je     8004b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a7:	84 db                	test   %bl,%bl
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	0f 44 c2             	cmove  %edx,%eax
  8004b1:	eb 41                	jmp    8004f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 36                	pushl  (%esi)
  8004bc:	e8 66 ff ff ff       	call   800427 <dev_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 1a                	js     8004e4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 0b                	je     8004e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d9:	83 ec 0c             	sub    $0xc,%esp
  8004dc:	56                   	push   %esi
  8004dd:	ff d0                	call   *%eax
  8004df:	89 c3                	mov    %eax,%ebx
  8004e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	56                   	push   %esi
  8004e8:	6a 00                	push   $0x0
  8004ea:	e8 00 fd ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	89 d8                	mov    %ebx,%eax
}
  8004f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 c4 fe ff ff       	call   8003d1 <fd_lookup>
  80050d:	83 c4 08             	add    $0x8,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 10                	js     800524 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	6a 01                	push   $0x1
  800519:	ff 75 f4             	pushl  -0xc(%ebp)
  80051c:	e8 59 ff ff ff       	call   80047a <fd_close>
  800521:	83 c4 10             	add    $0x10,%esp
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <close_all>:

void
close_all(void)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	53                   	push   %ebx
  80052a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800532:	83 ec 0c             	sub    $0xc,%esp
  800535:	53                   	push   %ebx
  800536:	e8 c0 ff ff ff       	call   8004fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80053b:	83 c3 01             	add    $0x1,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	83 fb 20             	cmp    $0x20,%ebx
  800544:	75 ec                	jne    800532 <close_all+0xc>
		close(i);
}
  800546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	83 ec 2c             	sub    $0x2c,%esp
  800554:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800557:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055a:	50                   	push   %eax
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 6e fe ff ff       	call   8003d1 <fd_lookup>
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	0f 88 c1 00 00 00    	js     80062f <dup+0xe4>
		return r;
	close(newfdnum);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	56                   	push   %esi
  800572:	e8 84 ff ff ff       	call   8004fb <close>

	newfd = INDEX2FD(newfdnum);
  800577:	89 f3                	mov    %esi,%ebx
  800579:	c1 e3 0c             	shl    $0xc,%ebx
  80057c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800582:	83 c4 04             	add    $0x4,%esp
  800585:	ff 75 e4             	pushl  -0x1c(%ebp)
  800588:	e8 de fd ff ff       	call   80036b <fd2data>
  80058d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058f:	89 1c 24             	mov    %ebx,(%esp)
  800592:	e8 d4 fd ff ff       	call   80036b <fd2data>
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 16             	shr    $0x16,%eax
  8005a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a9:	a8 01                	test   $0x1,%al
  8005ab:	74 37                	je     8005e4 <dup+0x99>
  8005ad:	89 f8                	mov    %edi,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 01             	test   $0x1,%dl
  8005bc:	74 26                	je     8005e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d1:	6a 00                	push   $0x0
  8005d3:	57                   	push   %edi
  8005d4:	6a 00                	push   $0x0
  8005d6:	e8 d2 fb ff ff       	call   8001ad <sys_page_map>
  8005db:	89 c7                	mov    %eax,%edi
  8005dd:	83 c4 20             	add    $0x20,%esp
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	78 2e                	js     800612 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e7:	89 d0                	mov    %edx,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fb:	50                   	push   %eax
  8005fc:	53                   	push   %ebx
  8005fd:	6a 00                	push   $0x0
  8005ff:	52                   	push   %edx
  800600:	6a 00                	push   $0x0
  800602:	e8 a6 fb ff ff       	call   8001ad <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80060c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	85 ff                	test   %edi,%edi
  800610:	79 1d                	jns    80062f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 00                	push   $0x0
  800618:	e8 d2 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	ff 75 d4             	pushl  -0x2c(%ebp)
  800623:	6a 00                	push   $0x0
  800625:	e8 c5 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	89 f8                	mov    %edi,%eax
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 14             	sub    $0x14,%esp
  80063e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	53                   	push   %ebx
  800646:	e8 86 fd ff ff       	call   8003d1 <fd_lookup>
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	89 c2                	mov    %eax,%edx
  800650:	85 c0                	test   %eax,%eax
  800652:	78 6d                	js     8006c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065a:	50                   	push   %eax
  80065b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065e:	ff 30                	pushl  (%eax)
  800660:	e8 c2 fd ff ff       	call   800427 <dev_lookup>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 4c                	js     8006b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066f:	8b 42 08             	mov    0x8(%edx),%eax
  800672:	83 e0 03             	and    $0x3,%eax
  800675:	83 f8 01             	cmp    $0x1,%eax
  800678:	75 21                	jne    80069b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067a:	a1 04 40 80 00       	mov    0x804004,%eax
  80067f:	8b 40 48             	mov    0x48(%eax),%eax
  800682:	83 ec 04             	sub    $0x4,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	68 85 1e 80 00       	push   $0x801e85
  80068c:	e8 d6 0a 00 00       	call   801167 <cprintf>
		return -E_INVAL;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800699:	eb 26                	jmp    8006c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069e:	8b 40 08             	mov    0x8(%eax),%eax
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 17                	je     8006bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	52                   	push   %edx
  8006af:	ff d0                	call   *%eax
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 09                	jmp    8006c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b8:	89 c2                	mov    %eax,%edx
  8006ba:	eb 05                	jmp    8006c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006c1:	89 d0                	mov    %edx,%eax
  8006c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dc:	eb 21                	jmp    8006ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006de:	83 ec 04             	sub    $0x4,%esp
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	29 d8                	sub    %ebx,%eax
  8006e5:	50                   	push   %eax
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	03 45 0c             	add    0xc(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	57                   	push   %edi
  8006ed:	e8 45 ff ff ff       	call   800637 <read>
		if (m < 0)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	78 10                	js     800709 <readn+0x41>
			return m;
		if (m == 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 0a                	je     800707 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006fd:	01 c3                	add    %eax,%ebx
  8006ff:	39 f3                	cmp    %esi,%ebx
  800701:	72 db                	jb     8006de <readn+0x16>
  800703:	89 d8                	mov    %ebx,%eax
  800705:	eb 02                	jmp    800709 <readn+0x41>
  800707:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	83 ec 14             	sub    $0x14,%esp
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	53                   	push   %ebx
  800720:	e8 ac fc ff ff       	call   8003d1 <fd_lookup>
  800725:	83 c4 08             	add    $0x8,%esp
  800728:	89 c2                	mov    %eax,%edx
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 68                	js     800796 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800738:	ff 30                	pushl  (%eax)
  80073a:	e8 e8 fc ff ff       	call   800427 <dev_lookup>
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 47                	js     80078d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074d:	75 21                	jne    800770 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 04 40 80 00       	mov    0x804004,%eax
  800754:	8b 40 48             	mov    0x48(%eax),%eax
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	68 a1 1e 80 00       	push   $0x801ea1
  800761:	e8 01 0a 00 00       	call   801167 <cprintf>
		return -E_INVAL;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076e:	eb 26                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800773:	8b 52 0c             	mov    0xc(%edx),%edx
  800776:	85 d2                	test   %edx,%edx
  800778:	74 17                	je     800791 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80077a:	83 ec 04             	sub    $0x4,%esp
  80077d:	ff 75 10             	pushl  0x10(%ebp)
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	50                   	push   %eax
  800784:	ff d2                	call   *%edx
  800786:	89 c2                	mov    %eax,%edx
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb 09                	jmp    800796 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	eb 05                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800791:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800796:	89 d0                	mov    %edx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <seek>:

int
seek(int fdnum, off_t offset)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 22 fc ff ff       	call   8003d1 <fd_lookup>
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 0e                	js     8007c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	83 ec 14             	sub    $0x14,%esp
  8007cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	53                   	push   %ebx
  8007d5:	e8 f7 fb ff ff       	call   8003d1 <fd_lookup>
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 65                	js     800848 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	ff 30                	pushl  (%eax)
  8007ef:	e8 33 fc ff ff       	call   800427 <dev_lookup>
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 44                	js     80083f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800802:	75 21                	jne    800825 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800804:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800809:	8b 40 48             	mov    0x48(%eax),%eax
  80080c:	83 ec 04             	sub    $0x4,%esp
  80080f:	53                   	push   %ebx
  800810:	50                   	push   %eax
  800811:	68 64 1e 80 00       	push   $0x801e64
  800816:	e8 4c 09 00 00       	call   801167 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800823:	eb 23                	jmp    800848 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800828:	8b 52 18             	mov    0x18(%edx),%edx
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 14                	je     800843 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	50                   	push   %eax
  800836:	ff d2                	call   *%edx
  800838:	89 c2                	mov    %eax,%edx
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 09                	jmp    800848 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 05                	jmp    800848 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800843:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800848:	89 d0                	mov    %edx,%eax
  80084a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 14             	sub    $0x14,%esp
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085c:	50                   	push   %eax
  80085d:	ff 75 08             	pushl  0x8(%ebp)
  800860:	e8 6c fb ff ff       	call   8003d1 <fd_lookup>
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	89 c2                	mov    %eax,%edx
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 58                	js     8008c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 a8 fb ff ff       	call   800427 <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 37                	js     8008bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 32                	je     8008c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	eb 09                	jmp    8008c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	eb 05                	jmp    8008c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c6:	89 d0                	mov    %edx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	6a 00                	push   $0x0
  8008d7:	ff 75 08             	pushl  0x8(%ebp)
  8008da:	e8 2c 02 00 00       	call   800b0b <open>
  8008df:	89 c3                	mov    %eax,%ebx
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	78 1b                	js     800903 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ee:	50                   	push   %eax
  8008ef:	e8 5b ff ff ff       	call   80084f <fstat>
  8008f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	e8 fd fb ff ff       	call   8004fb <close>
	return r;
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f0                	mov    %esi,%eax
}
  800903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	89 c6                	mov    %eax,%esi
  800911:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  800913:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80091a:	75 12                	jne    80092e <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  80091c:	83 ec 0c             	sub    $0xc,%esp
  80091f:	6a 01                	push   $0x1
  800921:	e8 c0 11 00 00       	call   801ae6 <ipc_find_env>
  800926:	a3 00 40 80 00       	mov    %eax,0x804000
  80092b:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092e:	6a 07                	push   $0x7
  800930:	68 00 50 80 00       	push   $0x805000
  800935:	56                   	push   %esi
  800936:	ff 35 00 40 80 00    	pushl  0x804000
  80093c:	e8 51 11 00 00       	call   801a92 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  800941:	83 c4 0c             	add    $0xc,%esp
  800944:	6a 00                	push   $0x0
  800946:	53                   	push   %ebx
  800947:	6a 00                	push   $0x0
  800949:	e8 e5 10 00 00       	call   801a33 <ipc_recv>
}
  80094e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 40 0c             	mov    0xc(%eax),%eax
  800961:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 02 00 00 00       	mov    $0x2,%eax
  800978:	e8 8d ff ff ff       	call   80090a <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	b8 06 00 00 00       	mov    $0x6,%eax
  80099a:	e8 6b ff ff ff       	call   80090a <fsipc>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 04             	sub    $0x4,%esp
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b1:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c0:	e8 45 ff ff ff       	call   80090a <fsipc>
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	78 2c                	js     8009f5 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	68 00 50 80 00       	push   $0x805000
  8009d1:	53                   	push   %ebx
  8009d2:	e8 15 0d 00 00       	call   8016ec <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8009d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	53                   	push   %ebx
  8009fe:	83 ec 08             	sub    $0x8,%esp
  800a01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0a:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  800a0f:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  800a15:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a1b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800a20:	0f 46 c3             	cmovbe %ebx,%eax
  800a23:	50                   	push   %eax
  800a24:	ff 75 0c             	pushl  0xc(%ebp)
  800a27:	68 08 50 80 00       	push   $0x805008
  800a2c:	e8 4d 0e 00 00       	call   80187e <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  800a31:	ba 00 00 00 00       	mov    $0x0,%edx
  800a36:	b8 04 00 00 00       	mov    $0x4,%eax
  800a3b:	e8 ca fe ff ff       	call   80090a <fsipc>
  800a40:	83 c4 10             	add    $0x10,%esp
  800a43:	85 c0                	test   %eax,%eax
  800a45:	78 3d                	js     800a84 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  800a47:	39 c3                	cmp    %eax,%ebx
  800a49:	73 19                	jae    800a64 <devfile_write+0x6a>
  800a4b:	68 d0 1e 80 00       	push   $0x801ed0
  800a50:	68 d7 1e 80 00       	push   $0x801ed7
  800a55:	68 9a 00 00 00       	push   $0x9a
  800a5a:	68 ec 1e 80 00       	push   $0x801eec
  800a5f:	e8 2a 06 00 00       	call   80108e <_panic>
	   assert (r <= bytes_written);
  800a64:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a69:	7e 19                	jle    800a84 <devfile_write+0x8a>
  800a6b:	68 f7 1e 80 00       	push   $0x801ef7
  800a70:	68 d7 1e 80 00       	push   $0x801ed7
  800a75:	68 9b 00 00 00       	push   $0x9b
  800a7a:	68 ec 1e 80 00       	push   $0x801eec
  800a7f:	e8 0a 06 00 00       	call   80108e <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  800a84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a87:	c9                   	leave  
  800a88:	c3                   	ret    

00800a89 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
  800a8e:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	8b 40 0c             	mov    0xc(%eax),%eax
  800a97:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  800a9c:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa7:	b8 03 00 00 00       	mov    $0x3,%eax
  800aac:	e8 59 fe ff ff       	call   80090a <fsipc>
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	85 c0                	test   %eax,%eax
  800ab5:	78 4b                	js     800b02 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  800ab7:	39 c6                	cmp    %eax,%esi
  800ab9:	73 16                	jae    800ad1 <devfile_read+0x48>
  800abb:	68 d0 1e 80 00       	push   $0x801ed0
  800ac0:	68 d7 1e 80 00       	push   $0x801ed7
  800ac5:	6a 7c                	push   $0x7c
  800ac7:	68 ec 1e 80 00       	push   $0x801eec
  800acc:	e8 bd 05 00 00       	call   80108e <_panic>
	   assert(r <= PGSIZE);
  800ad1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ad6:	7e 16                	jle    800aee <devfile_read+0x65>
  800ad8:	68 0a 1f 80 00       	push   $0x801f0a
  800add:	68 d7 1e 80 00       	push   $0x801ed7
  800ae2:	6a 7d                	push   $0x7d
  800ae4:	68 ec 1e 80 00       	push   $0x801eec
  800ae9:	e8 a0 05 00 00       	call   80108e <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aee:	83 ec 04             	sub    $0x4,%esp
  800af1:	50                   	push   %eax
  800af2:	68 00 50 80 00       	push   $0x805000
  800af7:	ff 75 0c             	pushl  0xc(%ebp)
  800afa:	e8 7f 0d 00 00       	call   80187e <memmove>
	   return r;
  800aff:	83 c4 10             	add    $0x10,%esp
}
  800b02:	89 d8                	mov    %ebx,%eax
  800b04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	53                   	push   %ebx
  800b0f:	83 ec 20             	sub    $0x20,%esp
  800b12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  800b15:	53                   	push   %ebx
  800b16:	e8 98 0b 00 00       	call   8016b3 <strlen>
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b23:	7f 67                	jg     800b8c <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b25:	83 ec 0c             	sub    $0xc,%esp
  800b28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2b:	50                   	push   %eax
  800b2c:	e8 51 f8 ff ff       	call   800382 <fd_alloc>
  800b31:	83 c4 10             	add    $0x10,%esp
			 return r;
  800b34:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b36:	85 c0                	test   %eax,%eax
  800b38:	78 57                	js     800b91 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  800b3a:	83 ec 08             	sub    $0x8,%esp
  800b3d:	53                   	push   %ebx
  800b3e:	68 00 50 80 00       	push   $0x805000
  800b43:	e8 a4 0b 00 00       	call   8016ec <strcpy>
	   fsipcbuf.open.req_omode = mode;
  800b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4b:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b50:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b53:	b8 01 00 00 00       	mov    $0x1,%eax
  800b58:	e8 ad fd ff ff       	call   80090a <fsipc>
  800b5d:	89 c3                	mov    %eax,%ebx
  800b5f:	83 c4 10             	add    $0x10,%esp
  800b62:	85 c0                	test   %eax,%eax
  800b64:	79 14                	jns    800b7a <open+0x6f>
			 fd_close(fd, 0);
  800b66:	83 ec 08             	sub    $0x8,%esp
  800b69:	6a 00                	push   $0x0
  800b6b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6e:	e8 07 f9 ff ff       	call   80047a <fd_close>
			 return r;
  800b73:	83 c4 10             	add    $0x10,%esp
  800b76:	89 da                	mov    %ebx,%edx
  800b78:	eb 17                	jmp    800b91 <open+0x86>
	   }

	   return fd2num(fd);
  800b7a:	83 ec 0c             	sub    $0xc,%esp
  800b7d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b80:	e8 d6 f7 ff ff       	call   80035b <fd2num>
  800b85:	89 c2                	mov    %eax,%edx
  800b87:	83 c4 10             	add    $0x10,%esp
  800b8a:	eb 05                	jmp    800b91 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  800b8c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  800b91:	89 d0                	mov    %edx,%eax
  800b93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  800b9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba8:	e8 5d fd ff ff       	call   80090a <fsipc>
}
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	ff 75 08             	pushl  0x8(%ebp)
  800bbd:	e8 a9 f7 ff ff       	call   80036b <fd2data>
  800bc2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bc4:	83 c4 08             	add    $0x8,%esp
  800bc7:	68 16 1f 80 00       	push   $0x801f16
  800bcc:	53                   	push   %ebx
  800bcd:	e8 1a 0b 00 00       	call   8016ec <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bd2:	8b 46 04             	mov    0x4(%esi),%eax
  800bd5:	2b 06                	sub    (%esi),%eax
  800bd7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bdd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800be4:	00 00 00 
	stat->st_dev = &devpipe;
  800be7:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800bee:	30 80 00 
	return 0;
}
  800bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c07:	53                   	push   %ebx
  800c08:	6a 00                	push   $0x0
  800c0a:	e8 e0 f5 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c0f:	89 1c 24             	mov    %ebx,(%esp)
  800c12:	e8 54 f7 ff ff       	call   80036b <fd2data>
  800c17:	83 c4 08             	add    $0x8,%esp
  800c1a:	50                   	push   %eax
  800c1b:	6a 00                	push   $0x0
  800c1d:	e8 cd f5 ff ff       	call   8001ef <sys_page_unmap>
}
  800c22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 1c             	sub    $0x1c,%esp
  800c30:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c33:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c35:	a1 04 40 80 00       	mov    0x804004,%eax
  800c3a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	ff 75 e0             	pushl  -0x20(%ebp)
  800c43:	e8 d7 0e 00 00       	call   801b1f <pageref>
  800c48:	89 c3                	mov    %eax,%ebx
  800c4a:	89 3c 24             	mov    %edi,(%esp)
  800c4d:	e8 cd 0e 00 00       	call   801b1f <pageref>
  800c52:	83 c4 10             	add    $0x10,%esp
  800c55:	39 c3                	cmp    %eax,%ebx
  800c57:	0f 94 c1             	sete   %cl
  800c5a:	0f b6 c9             	movzbl %cl,%ecx
  800c5d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c60:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c66:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c69:	39 ce                	cmp    %ecx,%esi
  800c6b:	74 1b                	je     800c88 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c6d:	39 c3                	cmp    %eax,%ebx
  800c6f:	75 c4                	jne    800c35 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c71:	8b 42 58             	mov    0x58(%edx),%eax
  800c74:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c77:	50                   	push   %eax
  800c78:	56                   	push   %esi
  800c79:	68 1d 1f 80 00       	push   $0x801f1d
  800c7e:	e8 e4 04 00 00       	call   801167 <cprintf>
  800c83:	83 c4 10             	add    $0x10,%esp
  800c86:	eb ad                	jmp    800c35 <_pipeisclosed+0xe>
	}
}
  800c88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 28             	sub    $0x28,%esp
  800c9c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c9f:	56                   	push   %esi
  800ca0:	e8 c6 f6 ff ff       	call   80036b <fd2data>
  800ca5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca7:	83 c4 10             	add    $0x10,%esp
  800caa:	bf 00 00 00 00       	mov    $0x0,%edi
  800caf:	eb 4b                	jmp    800cfc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cb1:	89 da                	mov    %ebx,%edx
  800cb3:	89 f0                	mov    %esi,%eax
  800cb5:	e8 6d ff ff ff       	call   800c27 <_pipeisclosed>
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	75 48                	jne    800d06 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cbe:	e8 88 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cc3:	8b 43 04             	mov    0x4(%ebx),%eax
  800cc6:	8b 0b                	mov    (%ebx),%ecx
  800cc8:	8d 51 20             	lea    0x20(%ecx),%edx
  800ccb:	39 d0                	cmp    %edx,%eax
  800ccd:	73 e2                	jae    800cb1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cd6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cd9:	89 c2                	mov    %eax,%edx
  800cdb:	c1 fa 1f             	sar    $0x1f,%edx
  800cde:	89 d1                	mov    %edx,%ecx
  800ce0:	c1 e9 1b             	shr    $0x1b,%ecx
  800ce3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ce6:	83 e2 1f             	and    $0x1f,%edx
  800ce9:	29 ca                	sub    %ecx,%edx
  800ceb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cf3:	83 c0 01             	add    $0x1,%eax
  800cf6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf9:	83 c7 01             	add    $0x1,%edi
  800cfc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cff:	75 c2                	jne    800cc3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d01:	8b 45 10             	mov    0x10(%ebp),%eax
  800d04:	eb 05                	jmp    800d0b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d06:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 18             	sub    $0x18,%esp
  800d1c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d1f:	57                   	push   %edi
  800d20:	e8 46 f6 ff ff       	call   80036b <fd2data>
  800d25:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d27:	83 c4 10             	add    $0x10,%esp
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	eb 3d                	jmp    800d6e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d31:	85 db                	test   %ebx,%ebx
  800d33:	74 04                	je     800d39 <devpipe_read+0x26>
				return i;
  800d35:	89 d8                	mov    %ebx,%eax
  800d37:	eb 44                	jmp    800d7d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d39:	89 f2                	mov    %esi,%edx
  800d3b:	89 f8                	mov    %edi,%eax
  800d3d:	e8 e5 fe ff ff       	call   800c27 <_pipeisclosed>
  800d42:	85 c0                	test   %eax,%eax
  800d44:	75 32                	jne    800d78 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d46:	e8 00 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d4b:	8b 06                	mov    (%esi),%eax
  800d4d:	3b 46 04             	cmp    0x4(%esi),%eax
  800d50:	74 df                	je     800d31 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d52:	99                   	cltd   
  800d53:	c1 ea 1b             	shr    $0x1b,%edx
  800d56:	01 d0                	add    %edx,%eax
  800d58:	83 e0 1f             	and    $0x1f,%eax
  800d5b:	29 d0                	sub    %edx,%eax
  800d5d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d65:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d68:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d6b:	83 c3 01             	add    $0x1,%ebx
  800d6e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d71:	75 d8                	jne    800d4b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d73:	8b 45 10             	mov    0x10(%ebp),%eax
  800d76:	eb 05                	jmp    800d7d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d78:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
  800d8a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d90:	50                   	push   %eax
  800d91:	e8 ec f5 ff ff       	call   800382 <fd_alloc>
  800d96:	83 c4 10             	add    $0x10,%esp
  800d99:	89 c2                	mov    %eax,%edx
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	0f 88 2c 01 00 00    	js     800ecf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	68 07 04 00 00       	push   $0x407
  800dab:	ff 75 f4             	pushl  -0xc(%ebp)
  800dae:	6a 00                	push   $0x0
  800db0:	e8 b5 f3 ff ff       	call   80016a <sys_page_alloc>
  800db5:	83 c4 10             	add    $0x10,%esp
  800db8:	89 c2                	mov    %eax,%edx
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	0f 88 0d 01 00 00    	js     800ecf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc8:	50                   	push   %eax
  800dc9:	e8 b4 f5 ff ff       	call   800382 <fd_alloc>
  800dce:	89 c3                	mov    %eax,%ebx
  800dd0:	83 c4 10             	add    $0x10,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	0f 88 e2 00 00 00    	js     800ebd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddb:	83 ec 04             	sub    $0x4,%esp
  800dde:	68 07 04 00 00       	push   $0x407
  800de3:	ff 75 f0             	pushl  -0x10(%ebp)
  800de6:	6a 00                	push   $0x0
  800de8:	e8 7d f3 ff ff       	call   80016a <sys_page_alloc>
  800ded:	89 c3                	mov    %eax,%ebx
  800def:	83 c4 10             	add    $0x10,%esp
  800df2:	85 c0                	test   %eax,%eax
  800df4:	0f 88 c3 00 00 00    	js     800ebd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dfa:	83 ec 0c             	sub    $0xc,%esp
  800dfd:	ff 75 f4             	pushl  -0xc(%ebp)
  800e00:	e8 66 f5 ff ff       	call   80036b <fd2data>
  800e05:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e07:	83 c4 0c             	add    $0xc,%esp
  800e0a:	68 07 04 00 00       	push   $0x407
  800e0f:	50                   	push   %eax
  800e10:	6a 00                	push   $0x0
  800e12:	e8 53 f3 ff ff       	call   80016a <sys_page_alloc>
  800e17:	89 c3                	mov    %eax,%ebx
  800e19:	83 c4 10             	add    $0x10,%esp
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	0f 88 89 00 00 00    	js     800ead <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2a:	e8 3c f5 ff ff       	call   80036b <fd2data>
  800e2f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e36:	50                   	push   %eax
  800e37:	6a 00                	push   $0x0
  800e39:	56                   	push   %esi
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 6c f3 ff ff       	call   8001ad <sys_page_map>
  800e41:	89 c3                	mov    %eax,%ebx
  800e43:	83 c4 20             	add    $0x20,%esp
  800e46:	85 c0                	test   %eax,%eax
  800e48:	78 55                	js     800e9f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e4a:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e53:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e58:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e5f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e68:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e6d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e74:	83 ec 0c             	sub    $0xc,%esp
  800e77:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7a:	e8 dc f4 ff ff       	call   80035b <fd2num>
  800e7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e82:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e84:	83 c4 04             	add    $0x4,%esp
  800e87:	ff 75 f0             	pushl  -0x10(%ebp)
  800e8a:	e8 cc f4 ff ff       	call   80035b <fd2num>
  800e8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e92:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9d:	eb 30                	jmp    800ecf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	56                   	push   %esi
  800ea3:	6a 00                	push   $0x0
  800ea5:	e8 45 f3 ff ff       	call   8001ef <sys_page_unmap>
  800eaa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ead:	83 ec 08             	sub    $0x8,%esp
  800eb0:	ff 75 f0             	pushl  -0x10(%ebp)
  800eb3:	6a 00                	push   $0x0
  800eb5:	e8 35 f3 ff ff       	call   8001ef <sys_page_unmap>
  800eba:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ebd:	83 ec 08             	sub    $0x8,%esp
  800ec0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec3:	6a 00                	push   $0x0
  800ec5:	e8 25 f3 ff ff       	call   8001ef <sys_page_unmap>
  800eca:	83 c4 10             	add    $0x10,%esp
  800ecd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ecf:	89 d0                	mov    %edx,%eax
  800ed1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ede:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee1:	50                   	push   %eax
  800ee2:	ff 75 08             	pushl  0x8(%ebp)
  800ee5:	e8 e7 f4 ff ff       	call   8003d1 <fd_lookup>
  800eea:	83 c4 10             	add    $0x10,%esp
  800eed:	85 c0                	test   %eax,%eax
  800eef:	78 18                	js     800f09 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ef1:	83 ec 0c             	sub    $0xc,%esp
  800ef4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef7:	e8 6f f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800efc:	89 c2                	mov    %eax,%edx
  800efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f01:	e8 21 fd ff ff       	call   800c27 <_pipeisclosed>
  800f06:	83 c4 10             	add    $0x10,%esp
}
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f1b:	68 35 1f 80 00       	push   $0x801f35
  800f20:	ff 75 0c             	pushl  0xc(%ebp)
  800f23:	e8 c4 07 00 00       	call   8016ec <strcpy>
	return 0;
}
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f40:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f46:	eb 2d                	jmp    800f75 <devcons_write+0x46>
		m = n - tot;
  800f48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f4d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f50:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f55:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f58:	83 ec 04             	sub    $0x4,%esp
  800f5b:	53                   	push   %ebx
  800f5c:	03 45 0c             	add    0xc(%ebp),%eax
  800f5f:	50                   	push   %eax
  800f60:	57                   	push   %edi
  800f61:	e8 18 09 00 00       	call   80187e <memmove>
		sys_cputs(buf, m);
  800f66:	83 c4 08             	add    $0x8,%esp
  800f69:	53                   	push   %ebx
  800f6a:	57                   	push   %edi
  800f6b:	e8 3e f1 ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f70:	01 de                	add    %ebx,%esi
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	89 f0                	mov    %esi,%eax
  800f77:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f7a:	72 cc                	jb     800f48 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5f                   	pop    %edi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 08             	sub    $0x8,%esp
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f8f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f93:	74 2a                	je     800fbf <devcons_read+0x3b>
  800f95:	eb 05                	jmp    800f9c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f97:	e8 af f1 ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f9c:	e8 2b f1 ff ff       	call   8000cc <sys_cgetc>
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	74 f2                	je     800f97 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	78 16                	js     800fbf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fa9:	83 f8 04             	cmp    $0x4,%eax
  800fac:	74 0c                	je     800fba <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb1:	88 02                	mov    %al,(%edx)
	return 1;
  800fb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb8:	eb 05                	jmp    800fbf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fba:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fbf:	c9                   	leave  
  800fc0:	c3                   	ret    

00800fc1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fca:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fcd:	6a 01                	push   $0x1
  800fcf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd2:	50                   	push   %eax
  800fd3:	e8 d6 f0 ff ff       	call   8000ae <sys_cputs>
}
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    

00800fdd <getchar>:

int
getchar(void)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fe3:	6a 01                	push   $0x1
  800fe5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe8:	50                   	push   %eax
  800fe9:	6a 00                	push   $0x0
  800feb:	e8 47 f6 ff ff       	call   800637 <read>
	if (r < 0)
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 0f                	js     801006 <getchar+0x29>
		return r;
	if (r < 1)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	7e 06                	jle    801001 <getchar+0x24>
		return -E_EOF;
	return c;
  800ffb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fff:	eb 05                	jmp    801006 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801001:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801006:	c9                   	leave  
  801007:	c3                   	ret    

00801008 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801011:	50                   	push   %eax
  801012:	ff 75 08             	pushl  0x8(%ebp)
  801015:	e8 b7 f3 ff ff       	call   8003d1 <fd_lookup>
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	78 11                	js     801032 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801021:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801024:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80102a:	39 10                	cmp    %edx,(%eax)
  80102c:	0f 94 c0             	sete   %al
  80102f:	0f b6 c0             	movzbl %al,%eax
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <opencons>:

int
opencons(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80103a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103d:	50                   	push   %eax
  80103e:	e8 3f f3 ff ff       	call   800382 <fd_alloc>
  801043:	83 c4 10             	add    $0x10,%esp
		return r;
  801046:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801048:	85 c0                	test   %eax,%eax
  80104a:	78 3e                	js     80108a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104c:	83 ec 04             	sub    $0x4,%esp
  80104f:	68 07 04 00 00       	push   $0x407
  801054:	ff 75 f4             	pushl  -0xc(%ebp)
  801057:	6a 00                	push   $0x0
  801059:	e8 0c f1 ff ff       	call   80016a <sys_page_alloc>
  80105e:	83 c4 10             	add    $0x10,%esp
		return r;
  801061:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801063:	85 c0                	test   %eax,%eax
  801065:	78 23                	js     80108a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801067:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80106d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801070:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801072:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801075:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	50                   	push   %eax
  801080:	e8 d6 f2 ff ff       	call   80035b <fd2num>
  801085:	89 c2                	mov    %eax,%edx
  801087:	83 c4 10             	add    $0x10,%esp
}
  80108a:	89 d0                	mov    %edx,%eax
  80108c:	c9                   	leave  
  80108d:	c3                   	ret    

0080108e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801093:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801096:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80109c:	e8 8b f0 ff ff       	call   80012c <sys_getenvid>
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	ff 75 0c             	pushl  0xc(%ebp)
  8010a7:	ff 75 08             	pushl  0x8(%ebp)
  8010aa:	56                   	push   %esi
  8010ab:	50                   	push   %eax
  8010ac:	68 44 1f 80 00       	push   $0x801f44
  8010b1:	e8 b1 00 00 00       	call   801167 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010b6:	83 c4 18             	add    $0x18,%esp
  8010b9:	53                   	push   %ebx
  8010ba:	ff 75 10             	pushl  0x10(%ebp)
  8010bd:	e8 54 00 00 00       	call   801116 <vcprintf>
	cprintf("\n");
  8010c2:	c7 04 24 2e 1f 80 00 	movl   $0x801f2e,(%esp)
  8010c9:	e8 99 00 00 00       	call   801167 <cprintf>
  8010ce:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010d1:	cc                   	int3   
  8010d2:	eb fd                	jmp    8010d1 <_panic+0x43>

008010d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	53                   	push   %ebx
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010de:	8b 13                	mov    (%ebx),%edx
  8010e0:	8d 42 01             	lea    0x1(%edx),%eax
  8010e3:	89 03                	mov    %eax,(%ebx)
  8010e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010f1:	75 1a                	jne    80110d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010f3:	83 ec 08             	sub    $0x8,%esp
  8010f6:	68 ff 00 00 00       	push   $0xff
  8010fb:	8d 43 08             	lea    0x8(%ebx),%eax
  8010fe:	50                   	push   %eax
  8010ff:	e8 aa ef ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  801104:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80110a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80110d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801111:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801114:	c9                   	leave  
  801115:	c3                   	ret    

00801116 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80111f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801126:	00 00 00 
	b.cnt = 0;
  801129:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801130:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801133:	ff 75 0c             	pushl  0xc(%ebp)
  801136:	ff 75 08             	pushl  0x8(%ebp)
  801139:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80113f:	50                   	push   %eax
  801140:	68 d4 10 80 00       	push   $0x8010d4
  801145:	e8 54 01 00 00       	call   80129e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80114a:	83 c4 08             	add    $0x8,%esp
  80114d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801153:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801159:	50                   	push   %eax
  80115a:	e8 4f ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  80115f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801165:	c9                   	leave  
  801166:	c3                   	ret    

00801167 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80116d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801170:	50                   	push   %eax
  801171:	ff 75 08             	pushl  0x8(%ebp)
  801174:	e8 9d ff ff ff       	call   801116 <vcprintf>
	va_end(ap);

	return cnt;
}
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	57                   	push   %edi
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	83 ec 1c             	sub    $0x1c,%esp
  801184:	89 c7                	mov    %eax,%edi
  801186:	89 d6                	mov    %edx,%esi
  801188:	8b 45 08             	mov    0x8(%ebp),%eax
  80118b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801191:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801194:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801197:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80119f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8011a2:	39 d3                	cmp    %edx,%ebx
  8011a4:	72 05                	jb     8011ab <printnum+0x30>
  8011a6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011a9:	77 45                	ja     8011f0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011ab:	83 ec 0c             	sub    $0xc,%esp
  8011ae:	ff 75 18             	pushl  0x18(%ebp)
  8011b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8011b4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011b7:	53                   	push   %ebx
  8011b8:	ff 75 10             	pushl  0x10(%ebp)
  8011bb:	83 ec 08             	sub    $0x8,%esp
  8011be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ca:	e8 91 09 00 00       	call   801b60 <__udivdi3>
  8011cf:	83 c4 18             	add    $0x18,%esp
  8011d2:	52                   	push   %edx
  8011d3:	50                   	push   %eax
  8011d4:	89 f2                	mov    %esi,%edx
  8011d6:	89 f8                	mov    %edi,%eax
  8011d8:	e8 9e ff ff ff       	call   80117b <printnum>
  8011dd:	83 c4 20             	add    $0x20,%esp
  8011e0:	eb 18                	jmp    8011fa <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011e2:	83 ec 08             	sub    $0x8,%esp
  8011e5:	56                   	push   %esi
  8011e6:	ff 75 18             	pushl  0x18(%ebp)
  8011e9:	ff d7                	call   *%edi
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	eb 03                	jmp    8011f3 <printnum+0x78>
  8011f0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011f3:	83 eb 01             	sub    $0x1,%ebx
  8011f6:	85 db                	test   %ebx,%ebx
  8011f8:	7f e8                	jg     8011e2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011fa:	83 ec 08             	sub    $0x8,%esp
  8011fd:	56                   	push   %esi
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	ff 75 e4             	pushl  -0x1c(%ebp)
  801204:	ff 75 e0             	pushl  -0x20(%ebp)
  801207:	ff 75 dc             	pushl  -0x24(%ebp)
  80120a:	ff 75 d8             	pushl  -0x28(%ebp)
  80120d:	e8 7e 0a 00 00       	call   801c90 <__umoddi3>
  801212:	83 c4 14             	add    $0x14,%esp
  801215:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  80121c:	50                   	push   %eax
  80121d:	ff d7                	call   *%edi
}
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801225:	5b                   	pop    %ebx
  801226:	5e                   	pop    %esi
  801227:	5f                   	pop    %edi
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80122d:	83 fa 01             	cmp    $0x1,%edx
  801230:	7e 0e                	jle    801240 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801232:	8b 10                	mov    (%eax),%edx
  801234:	8d 4a 08             	lea    0x8(%edx),%ecx
  801237:	89 08                	mov    %ecx,(%eax)
  801239:	8b 02                	mov    (%edx),%eax
  80123b:	8b 52 04             	mov    0x4(%edx),%edx
  80123e:	eb 22                	jmp    801262 <getuint+0x38>
	else if (lflag)
  801240:	85 d2                	test   %edx,%edx
  801242:	74 10                	je     801254 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801244:	8b 10                	mov    (%eax),%edx
  801246:	8d 4a 04             	lea    0x4(%edx),%ecx
  801249:	89 08                	mov    %ecx,(%eax)
  80124b:	8b 02                	mov    (%edx),%eax
  80124d:	ba 00 00 00 00       	mov    $0x0,%edx
  801252:	eb 0e                	jmp    801262 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801254:	8b 10                	mov    (%eax),%edx
  801256:	8d 4a 04             	lea    0x4(%edx),%ecx
  801259:	89 08                	mov    %ecx,(%eax)
  80125b:	8b 02                	mov    (%edx),%eax
  80125d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80126a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80126e:	8b 10                	mov    (%eax),%edx
  801270:	3b 50 04             	cmp    0x4(%eax),%edx
  801273:	73 0a                	jae    80127f <sprintputch+0x1b>
		*b->buf++ = ch;
  801275:	8d 4a 01             	lea    0x1(%edx),%ecx
  801278:	89 08                	mov    %ecx,(%eax)
  80127a:	8b 45 08             	mov    0x8(%ebp),%eax
  80127d:	88 02                	mov    %al,(%edx)
}
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    

00801281 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801287:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80128a:	50                   	push   %eax
  80128b:	ff 75 10             	pushl  0x10(%ebp)
  80128e:	ff 75 0c             	pushl  0xc(%ebp)
  801291:	ff 75 08             	pushl  0x8(%ebp)
  801294:	e8 05 00 00 00       	call   80129e <vprintfmt>
	va_end(ap);
}
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	c9                   	leave  
  80129d:	c3                   	ret    

0080129e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 2c             	sub    $0x2c,%esp
  8012a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012ad:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012b0:	eb 12                	jmp    8012c4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	0f 84 89 03 00 00    	je     801643 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	53                   	push   %ebx
  8012be:	50                   	push   %eax
  8012bf:	ff d6                	call   *%esi
  8012c1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012c4:	83 c7 01             	add    $0x1,%edi
  8012c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012cb:	83 f8 25             	cmp    $0x25,%eax
  8012ce:	75 e2                	jne    8012b2 <vprintfmt+0x14>
  8012d0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012d4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012db:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012e2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ee:	eb 07                	jmp    8012f7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012f3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f7:	8d 47 01             	lea    0x1(%edi),%eax
  8012fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012fd:	0f b6 07             	movzbl (%edi),%eax
  801300:	0f b6 c8             	movzbl %al,%ecx
  801303:	83 e8 23             	sub    $0x23,%eax
  801306:	3c 55                	cmp    $0x55,%al
  801308:	0f 87 1a 03 00 00    	ja     801628 <vprintfmt+0x38a>
  80130e:	0f b6 c0             	movzbl %al,%eax
  801311:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  801318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80131b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80131f:	eb d6                	jmp    8012f7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801324:	b8 00 00 00 00       	mov    $0x0,%eax
  801329:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80132c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80132f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801333:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801336:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801339:	83 fa 09             	cmp    $0x9,%edx
  80133c:	77 39                	ja     801377 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80133e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801341:	eb e9                	jmp    80132c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801343:	8b 45 14             	mov    0x14(%ebp),%eax
  801346:	8d 48 04             	lea    0x4(%eax),%ecx
  801349:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80134c:	8b 00                	mov    (%eax),%eax
  80134e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801354:	eb 27                	jmp    80137d <vprintfmt+0xdf>
  801356:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801359:	85 c0                	test   %eax,%eax
  80135b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801360:	0f 49 c8             	cmovns %eax,%ecx
  801363:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801369:	eb 8c                	jmp    8012f7 <vprintfmt+0x59>
  80136b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80136e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801375:	eb 80                	jmp    8012f7 <vprintfmt+0x59>
  801377:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80137a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80137d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801381:	0f 89 70 ff ff ff    	jns    8012f7 <vprintfmt+0x59>
				width = precision, precision = -1;
  801387:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80138a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80138d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801394:	e9 5e ff ff ff       	jmp    8012f7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801399:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80139f:	e9 53 ff ff ff       	jmp    8012f7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8013a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a7:	8d 50 04             	lea    0x4(%eax),%edx
  8013aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	53                   	push   %ebx
  8013b1:	ff 30                	pushl  (%eax)
  8013b3:	ff d6                	call   *%esi
			break;
  8013b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013bb:	e9 04 ff ff ff       	jmp    8012c4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c3:	8d 50 04             	lea    0x4(%eax),%edx
  8013c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c9:	8b 00                	mov    (%eax),%eax
  8013cb:	99                   	cltd   
  8013cc:	31 d0                	xor    %edx,%eax
  8013ce:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013d0:	83 f8 0f             	cmp    $0xf,%eax
  8013d3:	7f 0b                	jg     8013e0 <vprintfmt+0x142>
  8013d5:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8013dc:	85 d2                	test   %edx,%edx
  8013de:	75 18                	jne    8013f8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013e0:	50                   	push   %eax
  8013e1:	68 7f 1f 80 00       	push   $0x801f7f
  8013e6:	53                   	push   %ebx
  8013e7:	56                   	push   %esi
  8013e8:	e8 94 fe ff ff       	call   801281 <printfmt>
  8013ed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013f3:	e9 cc fe ff ff       	jmp    8012c4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013f8:	52                   	push   %edx
  8013f9:	68 e9 1e 80 00       	push   $0x801ee9
  8013fe:	53                   	push   %ebx
  8013ff:	56                   	push   %esi
  801400:	e8 7c fe ff ff       	call   801281 <printfmt>
  801405:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80140b:	e9 b4 fe ff ff       	jmp    8012c4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801410:	8b 45 14             	mov    0x14(%ebp),%eax
  801413:	8d 50 04             	lea    0x4(%eax),%edx
  801416:	89 55 14             	mov    %edx,0x14(%ebp)
  801419:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80141b:	85 ff                	test   %edi,%edi
  80141d:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  801422:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801425:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801429:	0f 8e 94 00 00 00    	jle    8014c3 <vprintfmt+0x225>
  80142f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801433:	0f 84 98 00 00 00    	je     8014d1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801439:	83 ec 08             	sub    $0x8,%esp
  80143c:	ff 75 d0             	pushl  -0x30(%ebp)
  80143f:	57                   	push   %edi
  801440:	e8 86 02 00 00       	call   8016cb <strnlen>
  801445:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801448:	29 c1                	sub    %eax,%ecx
  80144a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80144d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801450:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801457:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80145a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80145c:	eb 0f                	jmp    80146d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	53                   	push   %ebx
  801462:	ff 75 e0             	pushl  -0x20(%ebp)
  801465:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801467:	83 ef 01             	sub    $0x1,%edi
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 ff                	test   %edi,%edi
  80146f:	7f ed                	jg     80145e <vprintfmt+0x1c0>
  801471:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801474:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801477:	85 c9                	test   %ecx,%ecx
  801479:	b8 00 00 00 00       	mov    $0x0,%eax
  80147e:	0f 49 c1             	cmovns %ecx,%eax
  801481:	29 c1                	sub    %eax,%ecx
  801483:	89 75 08             	mov    %esi,0x8(%ebp)
  801486:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801489:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80148c:	89 cb                	mov    %ecx,%ebx
  80148e:	eb 4d                	jmp    8014dd <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801490:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801494:	74 1b                	je     8014b1 <vprintfmt+0x213>
  801496:	0f be c0             	movsbl %al,%eax
  801499:	83 e8 20             	sub    $0x20,%eax
  80149c:	83 f8 5e             	cmp    $0x5e,%eax
  80149f:	76 10                	jbe    8014b1 <vprintfmt+0x213>
					putch('?', putdat);
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	ff 75 0c             	pushl  0xc(%ebp)
  8014a7:	6a 3f                	push   $0x3f
  8014a9:	ff 55 08             	call   *0x8(%ebp)
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	eb 0d                	jmp    8014be <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014b1:	83 ec 08             	sub    $0x8,%esp
  8014b4:	ff 75 0c             	pushl  0xc(%ebp)
  8014b7:	52                   	push   %edx
  8014b8:	ff 55 08             	call   *0x8(%ebp)
  8014bb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014be:	83 eb 01             	sub    $0x1,%ebx
  8014c1:	eb 1a                	jmp    8014dd <vprintfmt+0x23f>
  8014c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8014c6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014cc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014cf:	eb 0c                	jmp    8014dd <vprintfmt+0x23f>
  8014d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8014d4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014d7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014da:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014dd:	83 c7 01             	add    $0x1,%edi
  8014e0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014e4:	0f be d0             	movsbl %al,%edx
  8014e7:	85 d2                	test   %edx,%edx
  8014e9:	74 23                	je     80150e <vprintfmt+0x270>
  8014eb:	85 f6                	test   %esi,%esi
  8014ed:	78 a1                	js     801490 <vprintfmt+0x1f2>
  8014ef:	83 ee 01             	sub    $0x1,%esi
  8014f2:	79 9c                	jns    801490 <vprintfmt+0x1f2>
  8014f4:	89 df                	mov    %ebx,%edi
  8014f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014fc:	eb 18                	jmp    801516 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014fe:	83 ec 08             	sub    $0x8,%esp
  801501:	53                   	push   %ebx
  801502:	6a 20                	push   $0x20
  801504:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801506:	83 ef 01             	sub    $0x1,%edi
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	eb 08                	jmp    801516 <vprintfmt+0x278>
  80150e:	89 df                	mov    %ebx,%edi
  801510:	8b 75 08             	mov    0x8(%ebp),%esi
  801513:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801516:	85 ff                	test   %edi,%edi
  801518:	7f e4                	jg     8014fe <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80151a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80151d:	e9 a2 fd ff ff       	jmp    8012c4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801522:	83 fa 01             	cmp    $0x1,%edx
  801525:	7e 16                	jle    80153d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801527:	8b 45 14             	mov    0x14(%ebp),%eax
  80152a:	8d 50 08             	lea    0x8(%eax),%edx
  80152d:	89 55 14             	mov    %edx,0x14(%ebp)
  801530:	8b 50 04             	mov    0x4(%eax),%edx
  801533:	8b 00                	mov    (%eax),%eax
  801535:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801538:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80153b:	eb 32                	jmp    80156f <vprintfmt+0x2d1>
	else if (lflag)
  80153d:	85 d2                	test   %edx,%edx
  80153f:	74 18                	je     801559 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801541:	8b 45 14             	mov    0x14(%ebp),%eax
  801544:	8d 50 04             	lea    0x4(%eax),%edx
  801547:	89 55 14             	mov    %edx,0x14(%ebp)
  80154a:	8b 00                	mov    (%eax),%eax
  80154c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154f:	89 c1                	mov    %eax,%ecx
  801551:	c1 f9 1f             	sar    $0x1f,%ecx
  801554:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801557:	eb 16                	jmp    80156f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801559:	8b 45 14             	mov    0x14(%ebp),%eax
  80155c:	8d 50 04             	lea    0x4(%eax),%edx
  80155f:	89 55 14             	mov    %edx,0x14(%ebp)
  801562:	8b 00                	mov    (%eax),%eax
  801564:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801567:	89 c1                	mov    %eax,%ecx
  801569:	c1 f9 1f             	sar    $0x1f,%ecx
  80156c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80156f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801572:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801575:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80157a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80157e:	79 74                	jns    8015f4 <vprintfmt+0x356>
				putch('-', putdat);
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	53                   	push   %ebx
  801584:	6a 2d                	push   $0x2d
  801586:	ff d6                	call   *%esi
				num = -(long long) num;
  801588:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80158b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80158e:	f7 d8                	neg    %eax
  801590:	83 d2 00             	adc    $0x0,%edx
  801593:	f7 da                	neg    %edx
  801595:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801598:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80159d:	eb 55                	jmp    8015f4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80159f:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a2:	e8 83 fc ff ff       	call   80122a <getuint>
			base = 10;
  8015a7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015ac:	eb 46                	jmp    8015f4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8015ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b1:	e8 74 fc ff ff       	call   80122a <getuint>
			base = 8;
  8015b6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015bb:	eb 37                	jmp    8015f4 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	53                   	push   %ebx
  8015c1:	6a 30                	push   $0x30
  8015c3:	ff d6                	call   *%esi
			putch('x', putdat);
  8015c5:	83 c4 08             	add    $0x8,%esp
  8015c8:	53                   	push   %ebx
  8015c9:	6a 78                	push   $0x78
  8015cb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d0:	8d 50 04             	lea    0x4(%eax),%edx
  8015d3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015d6:	8b 00                	mov    (%eax),%eax
  8015d8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015dd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015e0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015e5:	eb 0d                	jmp    8015f4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ea:	e8 3b fc ff ff       	call   80122a <getuint>
			base = 16;
  8015ef:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015f4:	83 ec 0c             	sub    $0xc,%esp
  8015f7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015fb:	57                   	push   %edi
  8015fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ff:	51                   	push   %ecx
  801600:	52                   	push   %edx
  801601:	50                   	push   %eax
  801602:	89 da                	mov    %ebx,%edx
  801604:	89 f0                	mov    %esi,%eax
  801606:	e8 70 fb ff ff       	call   80117b <printnum>
			break;
  80160b:	83 c4 20             	add    $0x20,%esp
  80160e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801611:	e9 ae fc ff ff       	jmp    8012c4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	53                   	push   %ebx
  80161a:	51                   	push   %ecx
  80161b:	ff d6                	call   *%esi
			break;
  80161d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801623:	e9 9c fc ff ff       	jmp    8012c4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	53                   	push   %ebx
  80162c:	6a 25                	push   $0x25
  80162e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	eb 03                	jmp    801638 <vprintfmt+0x39a>
  801635:	83 ef 01             	sub    $0x1,%edi
  801638:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80163c:	75 f7                	jne    801635 <vprintfmt+0x397>
  80163e:	e9 81 fc ff ff       	jmp    8012c4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801643:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801646:	5b                   	pop    %ebx
  801647:	5e                   	pop    %esi
  801648:	5f                   	pop    %edi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	83 ec 18             	sub    $0x18,%esp
  801651:	8b 45 08             	mov    0x8(%ebp),%eax
  801654:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801657:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80165a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80165e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801661:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801668:	85 c0                	test   %eax,%eax
  80166a:	74 26                	je     801692 <vsnprintf+0x47>
  80166c:	85 d2                	test   %edx,%edx
  80166e:	7e 22                	jle    801692 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801670:	ff 75 14             	pushl  0x14(%ebp)
  801673:	ff 75 10             	pushl  0x10(%ebp)
  801676:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	68 64 12 80 00       	push   $0x801264
  80167f:	e8 1a fc ff ff       	call   80129e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801684:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801687:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80168a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	eb 05                	jmp    801697 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801692:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801697:	c9                   	leave  
  801698:	c3                   	ret    

00801699 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80169f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016a2:	50                   	push   %eax
  8016a3:	ff 75 10             	pushl  0x10(%ebp)
  8016a6:	ff 75 0c             	pushl  0xc(%ebp)
  8016a9:	ff 75 08             	pushl  0x8(%ebp)
  8016ac:	e8 9a ff ff ff       	call   80164b <vsnprintf>
	va_end(ap);

	return rc;
}
  8016b1:	c9                   	leave  
  8016b2:	c3                   	ret    

008016b3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016be:	eb 03                	jmp    8016c3 <strlen+0x10>
		n++;
  8016c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016c7:	75 f7                	jne    8016c0 <strlen+0xd>
		n++;
	return n;
}
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    

008016cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d9:	eb 03                	jmp    8016de <strnlen+0x13>
		n++;
  8016db:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016de:	39 c2                	cmp    %eax,%edx
  8016e0:	74 08                	je     8016ea <strnlen+0x1f>
  8016e2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016e6:	75 f3                	jne    8016db <strnlen+0x10>
  8016e8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    

008016ec <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	53                   	push   %ebx
  8016f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016f6:	89 c2                	mov    %eax,%edx
  8016f8:	83 c2 01             	add    $0x1,%edx
  8016fb:	83 c1 01             	add    $0x1,%ecx
  8016fe:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801702:	88 5a ff             	mov    %bl,-0x1(%edx)
  801705:	84 db                	test   %bl,%bl
  801707:	75 ef                	jne    8016f8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801709:	5b                   	pop    %ebx
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	53                   	push   %ebx
  801710:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801713:	53                   	push   %ebx
  801714:	e8 9a ff ff ff       	call   8016b3 <strlen>
  801719:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80171c:	ff 75 0c             	pushl  0xc(%ebp)
  80171f:	01 d8                	add    %ebx,%eax
  801721:	50                   	push   %eax
  801722:	e8 c5 ff ff ff       	call   8016ec <strcpy>
	return dst;
}
  801727:	89 d8                	mov    %ebx,%eax
  801729:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	56                   	push   %esi
  801732:	53                   	push   %ebx
  801733:	8b 75 08             	mov    0x8(%ebp),%esi
  801736:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801739:	89 f3                	mov    %esi,%ebx
  80173b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173e:	89 f2                	mov    %esi,%edx
  801740:	eb 0f                	jmp    801751 <strncpy+0x23>
		*dst++ = *src;
  801742:	83 c2 01             	add    $0x1,%edx
  801745:	0f b6 01             	movzbl (%ecx),%eax
  801748:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80174b:	80 39 01             	cmpb   $0x1,(%ecx)
  80174e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801751:	39 da                	cmp    %ebx,%edx
  801753:	75 ed                	jne    801742 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801755:	89 f0                	mov    %esi,%eax
  801757:	5b                   	pop    %ebx
  801758:	5e                   	pop    %esi
  801759:	5d                   	pop    %ebp
  80175a:	c3                   	ret    

0080175b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
  801760:	8b 75 08             	mov    0x8(%ebp),%esi
  801763:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801766:	8b 55 10             	mov    0x10(%ebp),%edx
  801769:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80176b:	85 d2                	test   %edx,%edx
  80176d:	74 21                	je     801790 <strlcpy+0x35>
  80176f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801773:	89 f2                	mov    %esi,%edx
  801775:	eb 09                	jmp    801780 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801777:	83 c2 01             	add    $0x1,%edx
  80177a:	83 c1 01             	add    $0x1,%ecx
  80177d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801780:	39 c2                	cmp    %eax,%edx
  801782:	74 09                	je     80178d <strlcpy+0x32>
  801784:	0f b6 19             	movzbl (%ecx),%ebx
  801787:	84 db                	test   %bl,%bl
  801789:	75 ec                	jne    801777 <strlcpy+0x1c>
  80178b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80178d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801790:	29 f0                	sub    %esi,%eax
}
  801792:	5b                   	pop    %ebx
  801793:	5e                   	pop    %esi
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80179f:	eb 06                	jmp    8017a7 <strcmp+0x11>
		p++, q++;
  8017a1:	83 c1 01             	add    $0x1,%ecx
  8017a4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017a7:	0f b6 01             	movzbl (%ecx),%eax
  8017aa:	84 c0                	test   %al,%al
  8017ac:	74 04                	je     8017b2 <strcmp+0x1c>
  8017ae:	3a 02                	cmp    (%edx),%al
  8017b0:	74 ef                	je     8017a1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b2:	0f b6 c0             	movzbl %al,%eax
  8017b5:	0f b6 12             	movzbl (%edx),%edx
  8017b8:	29 d0                	sub    %edx,%eax
}
  8017ba:	5d                   	pop    %ebp
  8017bb:	c3                   	ret    

008017bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	53                   	push   %ebx
  8017c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c6:	89 c3                	mov    %eax,%ebx
  8017c8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017cb:	eb 06                	jmp    8017d3 <strncmp+0x17>
		n--, p++, q++;
  8017cd:	83 c0 01             	add    $0x1,%eax
  8017d0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017d3:	39 d8                	cmp    %ebx,%eax
  8017d5:	74 15                	je     8017ec <strncmp+0x30>
  8017d7:	0f b6 08             	movzbl (%eax),%ecx
  8017da:	84 c9                	test   %cl,%cl
  8017dc:	74 04                	je     8017e2 <strncmp+0x26>
  8017de:	3a 0a                	cmp    (%edx),%cl
  8017e0:	74 eb                	je     8017cd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e2:	0f b6 00             	movzbl (%eax),%eax
  8017e5:	0f b6 12             	movzbl (%edx),%edx
  8017e8:	29 d0                	sub    %edx,%eax
  8017ea:	eb 05                	jmp    8017f1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017ec:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017f1:	5b                   	pop    %ebx
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    

008017f4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fe:	eb 07                	jmp    801807 <strchr+0x13>
		if (*s == c)
  801800:	38 ca                	cmp    %cl,%dl
  801802:	74 0f                	je     801813 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801804:	83 c0 01             	add    $0x1,%eax
  801807:	0f b6 10             	movzbl (%eax),%edx
  80180a:	84 d2                	test   %dl,%dl
  80180c:	75 f2                	jne    801800 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80180e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801813:	5d                   	pop    %ebp
  801814:	c3                   	ret    

00801815 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181f:	eb 03                	jmp    801824 <strfind+0xf>
  801821:	83 c0 01             	add    $0x1,%eax
  801824:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801827:	38 ca                	cmp    %cl,%dl
  801829:	74 04                	je     80182f <strfind+0x1a>
  80182b:	84 d2                	test   %dl,%dl
  80182d:	75 f2                	jne    801821 <strfind+0xc>
			break;
	return (char *) s;
}
  80182f:	5d                   	pop    %ebp
  801830:	c3                   	ret    

00801831 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	57                   	push   %edi
  801835:	56                   	push   %esi
  801836:	53                   	push   %ebx
  801837:	8b 7d 08             	mov    0x8(%ebp),%edi
  80183a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80183d:	85 c9                	test   %ecx,%ecx
  80183f:	74 36                	je     801877 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801841:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801847:	75 28                	jne    801871 <memset+0x40>
  801849:	f6 c1 03             	test   $0x3,%cl
  80184c:	75 23                	jne    801871 <memset+0x40>
		c &= 0xFF;
  80184e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801852:	89 d3                	mov    %edx,%ebx
  801854:	c1 e3 08             	shl    $0x8,%ebx
  801857:	89 d6                	mov    %edx,%esi
  801859:	c1 e6 18             	shl    $0x18,%esi
  80185c:	89 d0                	mov    %edx,%eax
  80185e:	c1 e0 10             	shl    $0x10,%eax
  801861:	09 f0                	or     %esi,%eax
  801863:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801865:	89 d8                	mov    %ebx,%eax
  801867:	09 d0                	or     %edx,%eax
  801869:	c1 e9 02             	shr    $0x2,%ecx
  80186c:	fc                   	cld    
  80186d:	f3 ab                	rep stos %eax,%es:(%edi)
  80186f:	eb 06                	jmp    801877 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801871:	8b 45 0c             	mov    0xc(%ebp),%eax
  801874:	fc                   	cld    
  801875:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801877:	89 f8                	mov    %edi,%eax
  801879:	5b                   	pop    %ebx
  80187a:	5e                   	pop    %esi
  80187b:	5f                   	pop    %edi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	57                   	push   %edi
  801882:	56                   	push   %esi
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	8b 75 0c             	mov    0xc(%ebp),%esi
  801889:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80188c:	39 c6                	cmp    %eax,%esi
  80188e:	73 35                	jae    8018c5 <memmove+0x47>
  801890:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801893:	39 d0                	cmp    %edx,%eax
  801895:	73 2e                	jae    8018c5 <memmove+0x47>
		s += n;
		d += n;
  801897:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80189a:	89 d6                	mov    %edx,%esi
  80189c:	09 fe                	or     %edi,%esi
  80189e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a4:	75 13                	jne    8018b9 <memmove+0x3b>
  8018a6:	f6 c1 03             	test   $0x3,%cl
  8018a9:	75 0e                	jne    8018b9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018ab:	83 ef 04             	sub    $0x4,%edi
  8018ae:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018b1:	c1 e9 02             	shr    $0x2,%ecx
  8018b4:	fd                   	std    
  8018b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b7:	eb 09                	jmp    8018c2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018b9:	83 ef 01             	sub    $0x1,%edi
  8018bc:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018bf:	fd                   	std    
  8018c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c2:	fc                   	cld    
  8018c3:	eb 1d                	jmp    8018e2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c5:	89 f2                	mov    %esi,%edx
  8018c7:	09 c2                	or     %eax,%edx
  8018c9:	f6 c2 03             	test   $0x3,%dl
  8018cc:	75 0f                	jne    8018dd <memmove+0x5f>
  8018ce:	f6 c1 03             	test   $0x3,%cl
  8018d1:	75 0a                	jne    8018dd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018d3:	c1 e9 02             	shr    $0x2,%ecx
  8018d6:	89 c7                	mov    %eax,%edi
  8018d8:	fc                   	cld    
  8018d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018db:	eb 05                	jmp    8018e2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018dd:	89 c7                	mov    %eax,%edi
  8018df:	fc                   	cld    
  8018e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e2:	5e                   	pop    %esi
  8018e3:	5f                   	pop    %edi
  8018e4:	5d                   	pop    %ebp
  8018e5:	c3                   	ret    

008018e6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e9:	ff 75 10             	pushl  0x10(%ebp)
  8018ec:	ff 75 0c             	pushl  0xc(%ebp)
  8018ef:	ff 75 08             	pushl  0x8(%ebp)
  8018f2:	e8 87 ff ff ff       	call   80187e <memmove>
}
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    

008018f9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	56                   	push   %esi
  8018fd:	53                   	push   %ebx
  8018fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801901:	8b 55 0c             	mov    0xc(%ebp),%edx
  801904:	89 c6                	mov    %eax,%esi
  801906:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801909:	eb 1a                	jmp    801925 <memcmp+0x2c>
		if (*s1 != *s2)
  80190b:	0f b6 08             	movzbl (%eax),%ecx
  80190e:	0f b6 1a             	movzbl (%edx),%ebx
  801911:	38 d9                	cmp    %bl,%cl
  801913:	74 0a                	je     80191f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801915:	0f b6 c1             	movzbl %cl,%eax
  801918:	0f b6 db             	movzbl %bl,%ebx
  80191b:	29 d8                	sub    %ebx,%eax
  80191d:	eb 0f                	jmp    80192e <memcmp+0x35>
		s1++, s2++;
  80191f:	83 c0 01             	add    $0x1,%eax
  801922:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801925:	39 f0                	cmp    %esi,%eax
  801927:	75 e2                	jne    80190b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801929:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192e:	5b                   	pop    %ebx
  80192f:	5e                   	pop    %esi
  801930:	5d                   	pop    %ebp
  801931:	c3                   	ret    

00801932 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	53                   	push   %ebx
  801936:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801939:	89 c1                	mov    %eax,%ecx
  80193b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80193e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801942:	eb 0a                	jmp    80194e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801944:	0f b6 10             	movzbl (%eax),%edx
  801947:	39 da                	cmp    %ebx,%edx
  801949:	74 07                	je     801952 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80194b:	83 c0 01             	add    $0x1,%eax
  80194e:	39 c8                	cmp    %ecx,%eax
  801950:	72 f2                	jb     801944 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801952:	5b                   	pop    %ebx
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	57                   	push   %edi
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801961:	eb 03                	jmp    801966 <strtol+0x11>
		s++;
  801963:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801966:	0f b6 01             	movzbl (%ecx),%eax
  801969:	3c 20                	cmp    $0x20,%al
  80196b:	74 f6                	je     801963 <strtol+0xe>
  80196d:	3c 09                	cmp    $0x9,%al
  80196f:	74 f2                	je     801963 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801971:	3c 2b                	cmp    $0x2b,%al
  801973:	75 0a                	jne    80197f <strtol+0x2a>
		s++;
  801975:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801978:	bf 00 00 00 00       	mov    $0x0,%edi
  80197d:	eb 11                	jmp    801990 <strtol+0x3b>
  80197f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801984:	3c 2d                	cmp    $0x2d,%al
  801986:	75 08                	jne    801990 <strtol+0x3b>
		s++, neg = 1;
  801988:	83 c1 01             	add    $0x1,%ecx
  80198b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801990:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801996:	75 15                	jne    8019ad <strtol+0x58>
  801998:	80 39 30             	cmpb   $0x30,(%ecx)
  80199b:	75 10                	jne    8019ad <strtol+0x58>
  80199d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019a1:	75 7c                	jne    801a1f <strtol+0xca>
		s += 2, base = 16;
  8019a3:	83 c1 02             	add    $0x2,%ecx
  8019a6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019ab:	eb 16                	jmp    8019c3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019ad:	85 db                	test   %ebx,%ebx
  8019af:	75 12                	jne    8019c3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019b1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019b6:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b9:	75 08                	jne    8019c3 <strtol+0x6e>
		s++, base = 8;
  8019bb:	83 c1 01             	add    $0x1,%ecx
  8019be:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019cb:	0f b6 11             	movzbl (%ecx),%edx
  8019ce:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019d1:	89 f3                	mov    %esi,%ebx
  8019d3:	80 fb 09             	cmp    $0x9,%bl
  8019d6:	77 08                	ja     8019e0 <strtol+0x8b>
			dig = *s - '0';
  8019d8:	0f be d2             	movsbl %dl,%edx
  8019db:	83 ea 30             	sub    $0x30,%edx
  8019de:	eb 22                	jmp    801a02 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019e0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019e3:	89 f3                	mov    %esi,%ebx
  8019e5:	80 fb 19             	cmp    $0x19,%bl
  8019e8:	77 08                	ja     8019f2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019ea:	0f be d2             	movsbl %dl,%edx
  8019ed:	83 ea 57             	sub    $0x57,%edx
  8019f0:	eb 10                	jmp    801a02 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019f2:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019f5:	89 f3                	mov    %esi,%ebx
  8019f7:	80 fb 19             	cmp    $0x19,%bl
  8019fa:	77 16                	ja     801a12 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019fc:	0f be d2             	movsbl %dl,%edx
  8019ff:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a02:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a05:	7d 0b                	jge    801a12 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a07:	83 c1 01             	add    $0x1,%ecx
  801a0a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a0e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a10:	eb b9                	jmp    8019cb <strtol+0x76>

	if (endptr)
  801a12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a16:	74 0d                	je     801a25 <strtol+0xd0>
		*endptr = (char *) s;
  801a18:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a1b:	89 0e                	mov    %ecx,(%esi)
  801a1d:	eb 06                	jmp    801a25 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a1f:	85 db                	test   %ebx,%ebx
  801a21:	74 98                	je     8019bb <strtol+0x66>
  801a23:	eb 9e                	jmp    8019c3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a25:	89 c2                	mov    %eax,%edx
  801a27:	f7 da                	neg    %edx
  801a29:	85 ff                	test   %edi,%edi
  801a2b:	0f 45 c2             	cmovne %edx,%eax
}
  801a2e:	5b                   	pop    %ebx
  801a2f:	5e                   	pop    %esi
  801a30:	5f                   	pop    %edi
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    

00801a33 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	56                   	push   %esi
  801a37:	53                   	push   %ebx
  801a38:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801a41:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801a43:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a48:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801a4b:	83 ec 0c             	sub    $0xc,%esp
  801a4e:	50                   	push   %eax
  801a4f:	e8 c6 e8 ff ff       	call   80031a <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	85 c0                	test   %eax,%eax
  801a59:	78 0e                	js     801a69 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801a5b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a61:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801a64:	8b 52 78             	mov    0x78(%edx),%edx
  801a67:	eb 0a                	jmp    801a73 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801a69:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801a6e:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801a73:	85 f6                	test   %esi,%esi
  801a75:	74 02                	je     801a79 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801a77:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801a79:	85 db                	test   %ebx,%ebx
  801a7b:	74 02                	je     801a7f <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801a7d:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	78 08                	js     801a8b <ipc_recv+0x58>
  801a83:	a1 04 40 80 00       	mov    0x804004,%eax
  801a88:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801a8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8e:	5b                   	pop    %ebx
  801a8f:	5e                   	pop    %esi
  801a90:	5d                   	pop    %ebp
  801a91:	c3                   	ret    

00801a92 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	57                   	push   %edi
  801a96:	56                   	push   %esi
  801a97:	53                   	push   %ebx
  801a98:	83 ec 0c             	sub    $0xc,%esp
  801a9b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aa1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801aa4:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801aa6:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801aab:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801aae:	ff 75 14             	pushl  0x14(%ebp)
  801ab1:	53                   	push   %ebx
  801ab2:	56                   	push   %esi
  801ab3:	57                   	push   %edi
  801ab4:	e8 3e e8 ff ff       	call   8002f7 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801abf:	75 07                	jne    801ac8 <ipc_send+0x36>
				    sys_yield();
  801ac1:	e8 85 e6 ff ff       	call   80014b <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801ac6:	eb e6                	jmp    801aae <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	74 12                	je     801ade <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801acc:	50                   	push   %eax
  801acd:	68 60 22 80 00       	push   $0x802260
  801ad2:	6a 4b                	push   $0x4b
  801ad4:	68 74 22 80 00       	push   $0x802274
  801ad9:	e8 b0 f5 ff ff       	call   80108e <_panic>
			 }
	   }
}
  801ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5f                   	pop    %edi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801aec:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801af1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801af4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801afa:	8b 52 50             	mov    0x50(%edx),%edx
  801afd:	39 ca                	cmp    %ecx,%edx
  801aff:	75 0d                	jne    801b0e <ipc_find_env+0x28>
				    return envs[i].env_id;
  801b01:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b04:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b09:	8b 40 48             	mov    0x48(%eax),%eax
  801b0c:	eb 0f                	jmp    801b1d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801b0e:	83 c0 01             	add    $0x1,%eax
  801b11:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b16:	75 d9                	jne    801af1 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801b18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    

00801b1f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b25:	89 d0                	mov    %edx,%eax
  801b27:	c1 e8 16             	shr    $0x16,%eax
  801b2a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b36:	f6 c1 01             	test   $0x1,%cl
  801b39:	74 1d                	je     801b58 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b3b:	c1 ea 0c             	shr    $0xc,%edx
  801b3e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b45:	f6 c2 01             	test   $0x1,%dl
  801b48:	74 0e                	je     801b58 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b4a:	c1 ea 0c             	shr    $0xc,%edx
  801b4d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b54:	ef 
  801b55:	0f b7 c0             	movzwl %ax,%eax
}
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    
  801b5a:	66 90                	xchg   %ax,%ax
  801b5c:	66 90                	xchg   %ax,%ax
  801b5e:	66 90                	xchg   %ax,%ax

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 1c             	sub    $0x1c,%esp
  801b67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b77:	85 f6                	test   %esi,%esi
  801b79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b7d:	89 ca                	mov    %ecx,%edx
  801b7f:	89 f8                	mov    %edi,%eax
  801b81:	75 3d                	jne    801bc0 <__udivdi3+0x60>
  801b83:	39 cf                	cmp    %ecx,%edi
  801b85:	0f 87 c5 00 00 00    	ja     801c50 <__udivdi3+0xf0>
  801b8b:	85 ff                	test   %edi,%edi
  801b8d:	89 fd                	mov    %edi,%ebp
  801b8f:	75 0b                	jne    801b9c <__udivdi3+0x3c>
  801b91:	b8 01 00 00 00       	mov    $0x1,%eax
  801b96:	31 d2                	xor    %edx,%edx
  801b98:	f7 f7                	div    %edi
  801b9a:	89 c5                	mov    %eax,%ebp
  801b9c:	89 c8                	mov    %ecx,%eax
  801b9e:	31 d2                	xor    %edx,%edx
  801ba0:	f7 f5                	div    %ebp
  801ba2:	89 c1                	mov    %eax,%ecx
  801ba4:	89 d8                	mov    %ebx,%eax
  801ba6:	89 cf                	mov    %ecx,%edi
  801ba8:	f7 f5                	div    %ebp
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	89 d8                	mov    %ebx,%eax
  801bae:	89 fa                	mov    %edi,%edx
  801bb0:	83 c4 1c             	add    $0x1c,%esp
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    
  801bb8:	90                   	nop
  801bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bc0:	39 ce                	cmp    %ecx,%esi
  801bc2:	77 74                	ja     801c38 <__udivdi3+0xd8>
  801bc4:	0f bd fe             	bsr    %esi,%edi
  801bc7:	83 f7 1f             	xor    $0x1f,%edi
  801bca:	0f 84 98 00 00 00    	je     801c68 <__udivdi3+0x108>
  801bd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	89 c5                	mov    %eax,%ebp
  801bd9:	29 fb                	sub    %edi,%ebx
  801bdb:	d3 e6                	shl    %cl,%esi
  801bdd:	89 d9                	mov    %ebx,%ecx
  801bdf:	d3 ed                	shr    %cl,%ebp
  801be1:	89 f9                	mov    %edi,%ecx
  801be3:	d3 e0                	shl    %cl,%eax
  801be5:	09 ee                	or     %ebp,%esi
  801be7:	89 d9                	mov    %ebx,%ecx
  801be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bed:	89 d5                	mov    %edx,%ebp
  801bef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bf3:	d3 ed                	shr    %cl,%ebp
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e2                	shl    %cl,%edx
  801bf9:	89 d9                	mov    %ebx,%ecx
  801bfb:	d3 e8                	shr    %cl,%eax
  801bfd:	09 c2                	or     %eax,%edx
  801bff:	89 d0                	mov    %edx,%eax
  801c01:	89 ea                	mov    %ebp,%edx
  801c03:	f7 f6                	div    %esi
  801c05:	89 d5                	mov    %edx,%ebp
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	f7 64 24 0c          	mull   0xc(%esp)
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	72 10                	jb     801c21 <__udivdi3+0xc1>
  801c11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e6                	shl    %cl,%esi
  801c19:	39 c6                	cmp    %eax,%esi
  801c1b:	73 07                	jae    801c24 <__udivdi3+0xc4>
  801c1d:	39 d5                	cmp    %edx,%ebp
  801c1f:	75 03                	jne    801c24 <__udivdi3+0xc4>
  801c21:	83 eb 01             	sub    $0x1,%ebx
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 d8                	mov    %ebx,%eax
  801c28:	89 fa                	mov    %edi,%edx
  801c2a:	83 c4 1c             	add    $0x1c,%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    
  801c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c38:	31 ff                	xor    %edi,%edi
  801c3a:	31 db                	xor    %ebx,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	89 d8                	mov    %ebx,%eax
  801c52:	f7 f7                	div    %edi
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	89 d8                	mov    %ebx,%eax
  801c5a:	89 fa                	mov    %edi,%edx
  801c5c:	83 c4 1c             	add    $0x1c,%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5e                   	pop    %esi
  801c61:	5f                   	pop    %edi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	39 ce                	cmp    %ecx,%esi
  801c6a:	72 0c                	jb     801c78 <__udivdi3+0x118>
  801c6c:	31 db                	xor    %ebx,%ebx
  801c6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c72:	0f 87 34 ff ff ff    	ja     801bac <__udivdi3+0x4c>
  801c78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c7d:	e9 2a ff ff ff       	jmp    801bac <__udivdi3+0x4c>
  801c82:	66 90                	xchg   %ax,%ax
  801c84:	66 90                	xchg   %ax,%ax
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 d2                	test   %edx,%edx
  801ca9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cb1:	89 f3                	mov    %esi,%ebx
  801cb3:	89 3c 24             	mov    %edi,(%esp)
  801cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cba:	75 1c                	jne    801cd8 <__umoddi3+0x48>
  801cbc:	39 f7                	cmp    %esi,%edi
  801cbe:	76 50                	jbe    801d10 <__umoddi3+0x80>
  801cc0:	89 c8                	mov    %ecx,%eax
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	f7 f7                	div    %edi
  801cc6:	89 d0                	mov    %edx,%eax
  801cc8:	31 d2                	xor    %edx,%edx
  801cca:	83 c4 1c             	add    $0x1c,%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
  801cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	89 d0                	mov    %edx,%eax
  801cdc:	77 52                	ja     801d30 <__umoddi3+0xa0>
  801cde:	0f bd ea             	bsr    %edx,%ebp
  801ce1:	83 f5 1f             	xor    $0x1f,%ebp
  801ce4:	75 5a                	jne    801d40 <__umoddi3+0xb0>
  801ce6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cea:	0f 82 e0 00 00 00    	jb     801dd0 <__umoddi3+0x140>
  801cf0:	39 0c 24             	cmp    %ecx,(%esp)
  801cf3:	0f 86 d7 00 00 00    	jbe    801dd0 <__umoddi3+0x140>
  801cf9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d01:	83 c4 1c             	add    $0x1c,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	85 ff                	test   %edi,%edi
  801d12:	89 fd                	mov    %edi,%ebp
  801d14:	75 0b                	jne    801d21 <__umoddi3+0x91>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f7                	div    %edi
  801d1f:	89 c5                	mov    %eax,%ebp
  801d21:	89 f0                	mov    %esi,%eax
  801d23:	31 d2                	xor    %edx,%edx
  801d25:	f7 f5                	div    %ebp
  801d27:	89 c8                	mov    %ecx,%eax
  801d29:	f7 f5                	div    %ebp
  801d2b:	89 d0                	mov    %edx,%eax
  801d2d:	eb 99                	jmp    801cc8 <__umoddi3+0x38>
  801d2f:	90                   	nop
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	83 c4 1c             	add    $0x1c,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    
  801d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d40:	8b 34 24             	mov    (%esp),%esi
  801d43:	bf 20 00 00 00       	mov    $0x20,%edi
  801d48:	89 e9                	mov    %ebp,%ecx
  801d4a:	29 ef                	sub    %ebp,%edi
  801d4c:	d3 e0                	shl    %cl,%eax
  801d4e:	89 f9                	mov    %edi,%ecx
  801d50:	89 f2                	mov    %esi,%edx
  801d52:	d3 ea                	shr    %cl,%edx
  801d54:	89 e9                	mov    %ebp,%ecx
  801d56:	09 c2                	or     %eax,%edx
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	89 14 24             	mov    %edx,(%esp)
  801d5d:	89 f2                	mov    %esi,%edx
  801d5f:	d3 e2                	shl    %cl,%edx
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d6b:	d3 e8                	shr    %cl,%eax
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	89 c6                	mov    %eax,%esi
  801d71:	d3 e3                	shl    %cl,%ebx
  801d73:	89 f9                	mov    %edi,%ecx
  801d75:	89 d0                	mov    %edx,%eax
  801d77:	d3 e8                	shr    %cl,%eax
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	09 d8                	or     %ebx,%eax
  801d7d:	89 d3                	mov    %edx,%ebx
  801d7f:	89 f2                	mov    %esi,%edx
  801d81:	f7 34 24             	divl   (%esp)
  801d84:	89 d6                	mov    %edx,%esi
  801d86:	d3 e3                	shl    %cl,%ebx
  801d88:	f7 64 24 04          	mull   0x4(%esp)
  801d8c:	39 d6                	cmp    %edx,%esi
  801d8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d92:	89 d1                	mov    %edx,%ecx
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	72 08                	jb     801da0 <__umoddi3+0x110>
  801d98:	75 11                	jne    801dab <__umoddi3+0x11b>
  801d9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d9e:	73 0b                	jae    801dab <__umoddi3+0x11b>
  801da0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801da4:	1b 14 24             	sbb    (%esp),%edx
  801da7:	89 d1                	mov    %edx,%ecx
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	8b 54 24 08          	mov    0x8(%esp),%edx
  801daf:	29 da                	sub    %ebx,%edx
  801db1:	19 ce                	sbb    %ecx,%esi
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 f0                	mov    %esi,%eax
  801db7:	d3 e0                	shl    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	d3 ea                	shr    %cl,%edx
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	d3 ee                	shr    %cl,%esi
  801dc1:	09 d0                	or     %edx,%eax
  801dc3:	89 f2                	mov    %esi,%edx
  801dc5:	83 c4 1c             	add    $0x1c,%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    
  801dcd:	8d 76 00             	lea    0x0(%esi),%esi
  801dd0:	29 f9                	sub    %edi,%ecx
  801dd2:	19 d6                	sbb    %edx,%esi
  801dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ddc:	e9 18 ff ff ff       	jmp    801cf9 <__umoddi3+0x69>
