
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 65 00 00 00       	call   8000aa <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 87 04 00 00       	call   800522 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 0a 1e 80 00       	push   $0x801e0a
  800114:	6a 23                	push   $0x23
  800116:	68 27 1e 80 00       	push   $0x801e27
  80011b:	e8 6a 0f 00 00       	call   80108a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 0a 1e 80 00       	push   $0x801e0a
  800195:	6a 23                	push   $0x23
  800197:	68 27 1e 80 00       	push   $0x801e27
  80019c:	e8 e9 0e 00 00       	call   80108a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 0a 1e 80 00       	push   $0x801e0a
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 27 1e 80 00       	push   $0x801e27
  8001de:	e8 a7 0e 00 00       	call   80108a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 0a 1e 80 00       	push   $0x801e0a
  800219:	6a 23                	push   $0x23
  80021b:	68 27 1e 80 00       	push   $0x801e27
  800220:	e8 65 0e 00 00       	call   80108a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 0a 1e 80 00       	push   $0x801e0a
  80025b:	6a 23                	push   $0x23
  80025d:	68 27 1e 80 00       	push   $0x801e27
  800262:	e8 23 0e 00 00       	call   80108a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 0a 1e 80 00       	push   $0x801e0a
  80029d:	6a 23                	push   $0x23
  80029f:	68 27 1e 80 00       	push   $0x801e27
  8002a4:	e8 e1 0d 00 00       	call   80108a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 0a 1e 80 00       	push   $0x801e0a
  8002df:	6a 23                	push   $0x23
  8002e1:	68 27 1e 80 00       	push   $0x801e27
  8002e6:	e8 9f 0d 00 00       	call   80108a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 0a 1e 80 00       	push   $0x801e0a
  800343:	6a 23                	push   $0x23
  800345:	68 27 1e 80 00       	push   $0x801e27
  80034a:	e8 3b 0d 00 00       	call   80108a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 11                	je     8003ab <fd_alloc+0x2d>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	75 09                	jne    8003b4 <fd_alloc+0x36>
			*fd_store = fd;
  8003ab:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	eb 17                	jmp    8003cb <fd_alloc+0x4d>
  8003b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003be:	75 c9                	jne    800389 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 13                	jmp    800421 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb 0c                	jmp    800421 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb 05                	jmp    800421 <fd_lookup+0x54>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	eb 13                	jmp    800446 <dev_lookup+0x23>
  800433:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	75 0c                	jne    800446 <dev_lookup+0x23>
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 2e                	jmp    800474 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	75 e7                	jne    800433 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80044c:	a1 04 40 80 00       	mov    0x804004,%eax
  800451:	8b 40 48             	mov    0x48(%eax),%eax
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	51                   	push   %ecx
  800458:	50                   	push   %eax
  800459:	68 38 1e 80 00       	push   $0x801e38
  80045e:	e8 00 0d 00 00       	call   801163 <cprintf>
	*dev = 0;
  800463:	8b 45 0c             	mov    0xc(%ebp),%eax
  800466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 10             	sub    $0x10,%esp
  80047e:	8b 75 08             	mov    0x8(%ebp),%esi
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800487:	50                   	push   %eax
  800488:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	50                   	push   %eax
  800492:	e8 36 ff ff ff       	call   8003cd <fd_lookup>
  800497:	83 c4 08             	add    $0x8,%esp
  80049a:	85 c0                	test   %eax,%eax
  80049c:	78 05                	js     8004a3 <fd_close+0x2d>
	    || fd != fd2)
  80049e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a1:	74 0c                	je     8004af <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a3:	84 db                	test   %bl,%bl
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 44 c2             	cmove  %edx,%eax
  8004ad:	eb 41                	jmp    8004f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 66 ff ff ff       	call   800423 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 1a                	js     8004e0 <fd_close+0x6a>
		if (dev->dev_close)
  8004c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	74 0b                	je     8004e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	56                   	push   %esi
  8004d9:	ff d0                	call   *%eax
  8004db:	89 c3                	mov    %eax,%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 00 fd ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	89 d8                	mov    %ebx,%eax
}
  8004f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 c4 fe ff ff       	call   8003cd <fd_lookup>
  800509:	83 c4 08             	add    $0x8,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 10                	js     800520 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	6a 01                	push   $0x1
  800515:	ff 75 f4             	pushl  -0xc(%ebp)
  800518:	e8 59 ff ff ff       	call   800476 <fd_close>
  80051d:	83 c4 10             	add    $0x10,%esp
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <close_all>:

void
close_all(void)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	53                   	push   %ebx
  800532:	e8 c0 ff ff ff       	call   8004f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	83 fb 20             	cmp    $0x20,%ebx
  800540:	75 ec                	jne    80052e <close_all+0xc>
		close(i);
}
  800542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	57                   	push   %edi
  80054b:	56                   	push   %esi
  80054c:	53                   	push   %ebx
  80054d:	83 ec 2c             	sub    $0x2c,%esp
  800550:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 6e fe ff ff       	call   8003cd <fd_lookup>
  80055f:	83 c4 08             	add    $0x8,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 88 c1 00 00 00    	js     80062b <dup+0xe4>
		return r;
	close(newfdnum);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	56                   	push   %esi
  80056e:	e8 84 ff ff ff       	call   8004f7 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	89 f3                	mov    %esi,%ebx
  800575:	c1 e3 0c             	shl    $0xc,%ebx
  800578:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057e:	83 c4 04             	add    $0x4,%esp
  800581:	ff 75 e4             	pushl  -0x1c(%ebp)
  800584:	e8 de fd ff ff       	call   800367 <fd2data>
  800589:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058b:	89 1c 24             	mov    %ebx,(%esp)
  80058e:	e8 d4 fd ff ff       	call   800367 <fd2data>
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 37                	je     8005e0 <dup+0x99>
  8005a9:	89 f8                	mov    %edi,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	74 26                	je     8005e0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005cd:	6a 00                	push   $0x0
  8005cf:	57                   	push   %edi
  8005d0:	6a 00                	push   $0x0
  8005d2:	e8 d2 fb ff ff       	call   8001a9 <sys_page_map>
  8005d7:	89 c7                	mov    %eax,%edi
  8005d9:	83 c4 20             	add    $0x20,%esp
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	78 2e                	js     80060e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e3:	89 d0                	mov    %edx,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	53                   	push   %ebx
  8005f9:	6a 00                	push   $0x0
  8005fb:	52                   	push   %edx
  8005fc:	6a 00                	push   $0x0
  8005fe:	e8 a6 fb ff ff       	call   8001a9 <sys_page_map>
  800603:	89 c7                	mov    %eax,%edi
  800605:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800608:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060a:	85 ff                	test   %edi,%edi
  80060c:	79 1d                	jns    80062b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 00                	push   $0x0
  800614:	e8 d2 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061f:	6a 00                	push   $0x0
  800621:	e8 c5 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	89 f8                	mov    %edi,%eax
}
  80062b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	53                   	push   %ebx
  800637:	83 ec 14             	sub    $0x14,%esp
  80063a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	53                   	push   %ebx
  800642:	e8 86 fd ff ff       	call   8003cd <fd_lookup>
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	89 c2                	mov    %eax,%edx
  80064c:	85 c0                	test   %eax,%eax
  80064e:	78 6d                	js     8006bd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800656:	50                   	push   %eax
  800657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065a:	ff 30                	pushl  (%eax)
  80065c:	e8 c2 fd ff ff       	call   800423 <dev_lookup>
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	85 c0                	test   %eax,%eax
  800666:	78 4c                	js     8006b4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066b:	8b 42 08             	mov    0x8(%edx),%eax
  80066e:	83 e0 03             	and    $0x3,%eax
  800671:	83 f8 01             	cmp    $0x1,%eax
  800674:	75 21                	jne    800697 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800676:	a1 04 40 80 00       	mov    0x804004,%eax
  80067b:	8b 40 48             	mov    0x48(%eax),%eax
  80067e:	83 ec 04             	sub    $0x4,%esp
  800681:	53                   	push   %ebx
  800682:	50                   	push   %eax
  800683:	68 79 1e 80 00       	push   $0x801e79
  800688:	e8 d6 0a 00 00       	call   801163 <cprintf>
		return -E_INVAL;
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800695:	eb 26                	jmp    8006bd <read+0x8a>
	}
	if (!dev->dev_read)
  800697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069a:	8b 40 08             	mov    0x8(%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 17                	je     8006b8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	52                   	push   %edx
  8006ab:	ff d0                	call   *%eax
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 09                	jmp    8006bd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b4:	89 c2                	mov    %eax,%edx
  8006b6:	eb 05                	jmp    8006bd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006bd:	89 d0                	mov    %edx,%eax
  8006bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 0c             	sub    $0xc,%esp
  8006cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d8:	eb 21                	jmp    8006fb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 45 ff ff ff       	call   800633 <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 10                	js     800705 <readn+0x41>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 0a                	je     800703 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	39 f3                	cmp    %esi,%ebx
  8006fd:	72 db                	jb     8006da <readn+0x16>
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	eb 02                	jmp    800705 <readn+0x41>
  800703:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	83 ec 14             	sub    $0x14,%esp
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	53                   	push   %ebx
  80071c:	e8 ac fc ff ff       	call   8003cd <fd_lookup>
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	89 c2                	mov    %eax,%edx
  800726:	85 c0                	test   %eax,%eax
  800728:	78 68                	js     800792 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	ff 30                	pushl  (%eax)
  800736:	e8 e8 fc ff ff       	call   800423 <dev_lookup>
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 47                	js     800789 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800749:	75 21                	jne    80076c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 95 1e 80 00       	push   $0x801e95
  80075d:	e8 01 0a 00 00       	call   801163 <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076a:	eb 26                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 0c             	mov    0xc(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 17                	je     80078d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	50                   	push   %eax
  800780:	ff d2                	call   *%edx
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 09                	jmp    800792 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	89 c2                	mov    %eax,%edx
  80078b:	eb 05                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800792:	89 d0                	mov    %edx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <seek>:

int
seek(int fdnum, off_t offset)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 22 fc ff ff       	call   8003cd <fd_lookup>
  8007ab:	83 c4 08             	add    $0x8,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 0e                	js     8007c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 14             	sub    $0x14,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	53                   	push   %ebx
  8007d1:	e8 f7 fb ff ff       	call   8003cd <fd_lookup>
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 65                	js     800844 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	ff 30                	pushl  (%eax)
  8007eb:	e8 33 fc ff ff       	call   800423 <dev_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 44                	js     80083b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fe:	75 21                	jne    800821 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800800:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800805:	8b 40 48             	mov    0x48(%eax),%eax
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	53                   	push   %ebx
  80080c:	50                   	push   %eax
  80080d:	68 58 1e 80 00       	push   $0x801e58
  800812:	e8 4c 09 00 00       	call   801163 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081f:	eb 23                	jmp    800844 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800824:	8b 52 18             	mov    0x18(%edx),%edx
  800827:	85 d2                	test   %edx,%edx
  800829:	74 14                	je     80083f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	50                   	push   %eax
  800832:	ff d2                	call   *%edx
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	eb 09                	jmp    800844 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	eb 05                	jmp    800844 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800844:	89 d0                	mov    %edx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 14             	sub    $0x14,%esp
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	ff 75 08             	pushl  0x8(%ebp)
  80085c:	e8 6c fb ff ff       	call   8003cd <fd_lookup>
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	89 c2                	mov    %eax,%edx
  800866:	85 c0                	test   %eax,%eax
  800868:	78 58                	js     8008c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	ff 30                	pushl  (%eax)
  800876:	e8 a8 fb ff ff       	call   800423 <dev_lookup>
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 37                	js     8008b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800889:	74 32                	je     8008bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800895:	00 00 00 
	stat->st_isdir = 0;
  800898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089f:	00 00 00 
	stat->st_dev = dev;
  8008a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8008af:	ff 50 14             	call   *0x14(%eax)
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 09                	jmp    8008c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	eb 05                	jmp    8008c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c2:	89 d0                	mov    %edx,%eax
  8008c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	6a 00                	push   $0x0
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 2c 02 00 00       	call   800b07 <open>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 1b                	js     8008ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	50                   	push   %eax
  8008eb:	e8 5b ff ff ff       	call   80084b <fstat>
  8008f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	e8 fd fb ff ff       	call   8004f7 <close>
	return r;
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	89 f0                	mov    %esi,%eax
}
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  80090f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800916:	75 12                	jne    80092a <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	6a 01                	push   $0x1
  80091d:	e8 c0 11 00 00       	call   801ae2 <ipc_find_env>
  800922:	a3 00 40 80 00       	mov    %eax,0x804000
  800927:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092a:	6a 07                	push   $0x7
  80092c:	68 00 50 80 00       	push   $0x805000
  800931:	56                   	push   %esi
  800932:	ff 35 00 40 80 00    	pushl  0x804000
  800938:	e8 51 11 00 00       	call   801a8e <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  80093d:	83 c4 0c             	add    $0xc,%esp
  800940:	6a 00                	push   $0x0
  800942:	53                   	push   %ebx
  800943:	6a 00                	push   $0x0
  800945:	e8 e5 10 00 00       	call   801a2f <ipc_recv>
}
  80094a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8d ff ff ff       	call   800906 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 6b ff ff ff       	call   800906 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 45 ff ff ff       	call   800906 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 15 0d 00 00       	call   8016e8 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	53                   	push   %ebx
  8009fa:	83 ec 08             	sub    $0x8,%esp
  8009fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	8b 40 0c             	mov    0xc(%eax),%eax
  800a06:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  800a0b:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  800a11:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a17:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800a1c:	0f 46 c3             	cmovbe %ebx,%eax
  800a1f:	50                   	push   %eax
  800a20:	ff 75 0c             	pushl  0xc(%ebp)
  800a23:	68 08 50 80 00       	push   $0x805008
  800a28:	e8 4d 0e 00 00       	call   80187a <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	b8 04 00 00 00       	mov    $0x4,%eax
  800a37:	e8 ca fe ff ff       	call   800906 <fsipc>
  800a3c:	83 c4 10             	add    $0x10,%esp
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	78 3d                	js     800a80 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  800a43:	39 c3                	cmp    %eax,%ebx
  800a45:	73 19                	jae    800a60 <devfile_write+0x6a>
  800a47:	68 c4 1e 80 00       	push   $0x801ec4
  800a4c:	68 cb 1e 80 00       	push   $0x801ecb
  800a51:	68 9a 00 00 00       	push   $0x9a
  800a56:	68 e0 1e 80 00       	push   $0x801ee0
  800a5b:	e8 2a 06 00 00       	call   80108a <_panic>
	   assert (r <= bytes_written);
  800a60:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a65:	7e 19                	jle    800a80 <devfile_write+0x8a>
  800a67:	68 eb 1e 80 00       	push   $0x801eeb
  800a6c:	68 cb 1e 80 00       	push   $0x801ecb
  800a71:	68 9b 00 00 00       	push   $0x9b
  800a76:	68 e0 1e 80 00       	push   $0x801ee0
  800a7b:	e8 0a 06 00 00       	call   80108a <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  800a80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 40 0c             	mov    0xc(%eax),%eax
  800a93:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  800a98:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa3:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa8:	e8 59 fe ff ff       	call   800906 <fsipc>
  800aad:	89 c3                	mov    %eax,%ebx
  800aaf:	85 c0                	test   %eax,%eax
  800ab1:	78 4b                	js     800afe <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  800ab3:	39 c6                	cmp    %eax,%esi
  800ab5:	73 16                	jae    800acd <devfile_read+0x48>
  800ab7:	68 c4 1e 80 00       	push   $0x801ec4
  800abc:	68 cb 1e 80 00       	push   $0x801ecb
  800ac1:	6a 7c                	push   $0x7c
  800ac3:	68 e0 1e 80 00       	push   $0x801ee0
  800ac8:	e8 bd 05 00 00       	call   80108a <_panic>
	   assert(r <= PGSIZE);
  800acd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ad2:	7e 16                	jle    800aea <devfile_read+0x65>
  800ad4:	68 fe 1e 80 00       	push   $0x801efe
  800ad9:	68 cb 1e 80 00       	push   $0x801ecb
  800ade:	6a 7d                	push   $0x7d
  800ae0:	68 e0 1e 80 00       	push   $0x801ee0
  800ae5:	e8 a0 05 00 00       	call   80108a <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aea:	83 ec 04             	sub    $0x4,%esp
  800aed:	50                   	push   %eax
  800aee:	68 00 50 80 00       	push   $0x805000
  800af3:	ff 75 0c             	pushl  0xc(%ebp)
  800af6:	e8 7f 0d 00 00       	call   80187a <memmove>
	   return r;
  800afb:	83 c4 10             	add    $0x10,%esp
}
  800afe:	89 d8                	mov    %ebx,%eax
  800b00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 20             	sub    $0x20,%esp
  800b0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  800b11:	53                   	push   %ebx
  800b12:	e8 98 0b 00 00       	call   8016af <strlen>
  800b17:	83 c4 10             	add    $0x10,%esp
  800b1a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1f:	7f 67                	jg     800b88 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b21:	83 ec 0c             	sub    $0xc,%esp
  800b24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b27:	50                   	push   %eax
  800b28:	e8 51 f8 ff ff       	call   80037e <fd_alloc>
  800b2d:	83 c4 10             	add    $0x10,%esp
			 return r;
  800b30:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b32:	85 c0                	test   %eax,%eax
  800b34:	78 57                	js     800b8d <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  800b36:	83 ec 08             	sub    $0x8,%esp
  800b39:	53                   	push   %ebx
  800b3a:	68 00 50 80 00       	push   $0x805000
  800b3f:	e8 a4 0b 00 00       	call   8016e8 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  800b44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b47:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b54:	e8 ad fd ff ff       	call   800906 <fsipc>
  800b59:	89 c3                	mov    %eax,%ebx
  800b5b:	83 c4 10             	add    $0x10,%esp
  800b5e:	85 c0                	test   %eax,%eax
  800b60:	79 14                	jns    800b76 <open+0x6f>
			 fd_close(fd, 0);
  800b62:	83 ec 08             	sub    $0x8,%esp
  800b65:	6a 00                	push   $0x0
  800b67:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6a:	e8 07 f9 ff ff       	call   800476 <fd_close>
			 return r;
  800b6f:	83 c4 10             	add    $0x10,%esp
  800b72:	89 da                	mov    %ebx,%edx
  800b74:	eb 17                	jmp    800b8d <open+0x86>
	   }

	   return fd2num(fd);
  800b76:	83 ec 0c             	sub    $0xc,%esp
  800b79:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7c:	e8 d6 f7 ff ff       	call   800357 <fd2num>
  800b81:	89 c2                	mov    %eax,%edx
  800b83:	83 c4 10             	add    $0x10,%esp
  800b86:	eb 05                	jmp    800b8d <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  800b88:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  800b8d:	89 d0                	mov    %edx,%eax
  800b8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b92:	c9                   	leave  
  800b93:	c3                   	ret    

00800b94 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba4:	e8 5d fd ff ff       	call   800906 <fsipc>
}
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	ff 75 08             	pushl  0x8(%ebp)
  800bb9:	e8 a9 f7 ff ff       	call   800367 <fd2data>
  800bbe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bc0:	83 c4 08             	add    $0x8,%esp
  800bc3:	68 0a 1f 80 00       	push   $0x801f0a
  800bc8:	53                   	push   %ebx
  800bc9:	e8 1a 0b 00 00       	call   8016e8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bce:	8b 46 04             	mov    0x4(%esi),%eax
  800bd1:	2b 06                	sub    (%esi),%eax
  800bd3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bd9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800be0:	00 00 00 
	stat->st_dev = &devpipe;
  800be3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bea:	30 80 00 
	return 0;
}
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c03:	53                   	push   %ebx
  800c04:	6a 00                	push   $0x0
  800c06:	e8 e0 f5 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c0b:	89 1c 24             	mov    %ebx,(%esp)
  800c0e:	e8 54 f7 ff ff       	call   800367 <fd2data>
  800c13:	83 c4 08             	add    $0x8,%esp
  800c16:	50                   	push   %eax
  800c17:	6a 00                	push   $0x0
  800c19:	e8 cd f5 ff ff       	call   8001eb <sys_page_unmap>
}
  800c1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 1c             	sub    $0x1c,%esp
  800c2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c2f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c31:	a1 04 40 80 00       	mov    0x804004,%eax
  800c36:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c39:	83 ec 0c             	sub    $0xc,%esp
  800c3c:	ff 75 e0             	pushl  -0x20(%ebp)
  800c3f:	e8 d7 0e 00 00       	call   801b1b <pageref>
  800c44:	89 c3                	mov    %eax,%ebx
  800c46:	89 3c 24             	mov    %edi,(%esp)
  800c49:	e8 cd 0e 00 00       	call   801b1b <pageref>
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	39 c3                	cmp    %eax,%ebx
  800c53:	0f 94 c1             	sete   %cl
  800c56:	0f b6 c9             	movzbl %cl,%ecx
  800c59:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c5c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c62:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c65:	39 ce                	cmp    %ecx,%esi
  800c67:	74 1b                	je     800c84 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c69:	39 c3                	cmp    %eax,%ebx
  800c6b:	75 c4                	jne    800c31 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c6d:	8b 42 58             	mov    0x58(%edx),%eax
  800c70:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c73:	50                   	push   %eax
  800c74:	56                   	push   %esi
  800c75:	68 11 1f 80 00       	push   $0x801f11
  800c7a:	e8 e4 04 00 00       	call   801163 <cprintf>
  800c7f:	83 c4 10             	add    $0x10,%esp
  800c82:	eb ad                	jmp    800c31 <_pipeisclosed+0xe>
	}
}
  800c84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 28             	sub    $0x28,%esp
  800c98:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c9b:	56                   	push   %esi
  800c9c:	e8 c6 f6 ff ff       	call   800367 <fd2data>
  800ca1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca3:	83 c4 10             	add    $0x10,%esp
  800ca6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cab:	eb 4b                	jmp    800cf8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cad:	89 da                	mov    %ebx,%edx
  800caf:	89 f0                	mov    %esi,%eax
  800cb1:	e8 6d ff ff ff       	call   800c23 <_pipeisclosed>
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	75 48                	jne    800d02 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cba:	e8 88 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cbf:	8b 43 04             	mov    0x4(%ebx),%eax
  800cc2:	8b 0b                	mov    (%ebx),%ecx
  800cc4:	8d 51 20             	lea    0x20(%ecx),%edx
  800cc7:	39 d0                	cmp    %edx,%eax
  800cc9:	73 e2                	jae    800cad <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cd2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cd5:	89 c2                	mov    %eax,%edx
  800cd7:	c1 fa 1f             	sar    $0x1f,%edx
  800cda:	89 d1                	mov    %edx,%ecx
  800cdc:	c1 e9 1b             	shr    $0x1b,%ecx
  800cdf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ce2:	83 e2 1f             	and    $0x1f,%edx
  800ce5:	29 ca                	sub    %ecx,%edx
  800ce7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ceb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cef:	83 c0 01             	add    $0x1,%eax
  800cf2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf5:	83 c7 01             	add    $0x1,%edi
  800cf8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cfb:	75 c2                	jne    800cbf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cfd:	8b 45 10             	mov    0x10(%ebp),%eax
  800d00:	eb 05                	jmp    800d07 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d02:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 18             	sub    $0x18,%esp
  800d18:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d1b:	57                   	push   %edi
  800d1c:	e8 46 f6 ff ff       	call   800367 <fd2data>
  800d21:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d23:	83 c4 10             	add    $0x10,%esp
  800d26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2b:	eb 3d                	jmp    800d6a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d2d:	85 db                	test   %ebx,%ebx
  800d2f:	74 04                	je     800d35 <devpipe_read+0x26>
				return i;
  800d31:	89 d8                	mov    %ebx,%eax
  800d33:	eb 44                	jmp    800d79 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d35:	89 f2                	mov    %esi,%edx
  800d37:	89 f8                	mov    %edi,%eax
  800d39:	e8 e5 fe ff ff       	call   800c23 <_pipeisclosed>
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	75 32                	jne    800d74 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d42:	e8 00 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d47:	8b 06                	mov    (%esi),%eax
  800d49:	3b 46 04             	cmp    0x4(%esi),%eax
  800d4c:	74 df                	je     800d2d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d4e:	99                   	cltd   
  800d4f:	c1 ea 1b             	shr    $0x1b,%edx
  800d52:	01 d0                	add    %edx,%eax
  800d54:	83 e0 1f             	and    $0x1f,%eax
  800d57:	29 d0                	sub    %edx,%eax
  800d59:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d64:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d67:	83 c3 01             	add    $0x1,%ebx
  800d6a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d6d:	75 d8                	jne    800d47 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d72:	eb 05                	jmp    800d79 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d74:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d8c:	50                   	push   %eax
  800d8d:	e8 ec f5 ff ff       	call   80037e <fd_alloc>
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	89 c2                	mov    %eax,%edx
  800d97:	85 c0                	test   %eax,%eax
  800d99:	0f 88 2c 01 00 00    	js     800ecb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	68 07 04 00 00       	push   $0x407
  800da7:	ff 75 f4             	pushl  -0xc(%ebp)
  800daa:	6a 00                	push   $0x0
  800dac:	e8 b5 f3 ff ff       	call   800166 <sys_page_alloc>
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	89 c2                	mov    %eax,%edx
  800db6:	85 c0                	test   %eax,%eax
  800db8:	0f 88 0d 01 00 00    	js     800ecb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc4:	50                   	push   %eax
  800dc5:	e8 b4 f5 ff ff       	call   80037e <fd_alloc>
  800dca:	89 c3                	mov    %eax,%ebx
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	0f 88 e2 00 00 00    	js     800eb9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd7:	83 ec 04             	sub    $0x4,%esp
  800dda:	68 07 04 00 00       	push   $0x407
  800ddf:	ff 75 f0             	pushl  -0x10(%ebp)
  800de2:	6a 00                	push   $0x0
  800de4:	e8 7d f3 ff ff       	call   800166 <sys_page_alloc>
  800de9:	89 c3                	mov    %eax,%ebx
  800deb:	83 c4 10             	add    $0x10,%esp
  800dee:	85 c0                	test   %eax,%eax
  800df0:	0f 88 c3 00 00 00    	js     800eb9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800df6:	83 ec 0c             	sub    $0xc,%esp
  800df9:	ff 75 f4             	pushl  -0xc(%ebp)
  800dfc:	e8 66 f5 ff ff       	call   800367 <fd2data>
  800e01:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e03:	83 c4 0c             	add    $0xc,%esp
  800e06:	68 07 04 00 00       	push   $0x407
  800e0b:	50                   	push   %eax
  800e0c:	6a 00                	push   $0x0
  800e0e:	e8 53 f3 ff ff       	call   800166 <sys_page_alloc>
  800e13:	89 c3                	mov    %eax,%ebx
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	0f 88 89 00 00 00    	js     800ea9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e20:	83 ec 0c             	sub    $0xc,%esp
  800e23:	ff 75 f0             	pushl  -0x10(%ebp)
  800e26:	e8 3c f5 ff ff       	call   800367 <fd2data>
  800e2b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e32:	50                   	push   %eax
  800e33:	6a 00                	push   $0x0
  800e35:	56                   	push   %esi
  800e36:	6a 00                	push   $0x0
  800e38:	e8 6c f3 ff ff       	call   8001a9 <sys_page_map>
  800e3d:	89 c3                	mov    %eax,%ebx
  800e3f:	83 c4 20             	add    $0x20,%esp
  800e42:	85 c0                	test   %eax,%eax
  800e44:	78 55                	js     800e9b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e46:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e54:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e5b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e64:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e69:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e70:	83 ec 0c             	sub    $0xc,%esp
  800e73:	ff 75 f4             	pushl  -0xc(%ebp)
  800e76:	e8 dc f4 ff ff       	call   800357 <fd2num>
  800e7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e80:	83 c4 04             	add    $0x4,%esp
  800e83:	ff 75 f0             	pushl  -0x10(%ebp)
  800e86:	e8 cc f4 ff ff       	call   800357 <fd2num>
  800e8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	ba 00 00 00 00       	mov    $0x0,%edx
  800e99:	eb 30                	jmp    800ecb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e9b:	83 ec 08             	sub    $0x8,%esp
  800e9e:	56                   	push   %esi
  800e9f:	6a 00                	push   $0x0
  800ea1:	e8 45 f3 ff ff       	call   8001eb <sys_page_unmap>
  800ea6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ea9:	83 ec 08             	sub    $0x8,%esp
  800eac:	ff 75 f0             	pushl  -0x10(%ebp)
  800eaf:	6a 00                	push   $0x0
  800eb1:	e8 35 f3 ff ff       	call   8001eb <sys_page_unmap>
  800eb6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eb9:	83 ec 08             	sub    $0x8,%esp
  800ebc:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebf:	6a 00                	push   $0x0
  800ec1:	e8 25 f3 ff ff       	call   8001eb <sys_page_unmap>
  800ec6:	83 c4 10             	add    $0x10,%esp
  800ec9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ecb:	89 d0                	mov    %edx,%eax
  800ecd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800edd:	50                   	push   %eax
  800ede:	ff 75 08             	pushl  0x8(%ebp)
  800ee1:	e8 e7 f4 ff ff       	call   8003cd <fd_lookup>
  800ee6:	83 c4 10             	add    $0x10,%esp
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	78 18                	js     800f05 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef3:	e8 6f f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800ef8:	89 c2                	mov    %eax,%edx
  800efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800efd:	e8 21 fd ff ff       	call   800c23 <_pipeisclosed>
  800f02:	83 c4 10             	add    $0x10,%esp
}
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f17:	68 29 1f 80 00       	push   $0x801f29
  800f1c:	ff 75 0c             	pushl  0xc(%ebp)
  800f1f:	e8 c4 07 00 00       	call   8016e8 <strcpy>
	return 0;
}
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
  800f29:	c9                   	leave  
  800f2a:	c3                   	ret    

00800f2b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	57                   	push   %edi
  800f2f:	56                   	push   %esi
  800f30:	53                   	push   %ebx
  800f31:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f37:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f3c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f42:	eb 2d                	jmp    800f71 <devcons_write+0x46>
		m = n - tot;
  800f44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f47:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f49:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f4c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f51:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	53                   	push   %ebx
  800f58:	03 45 0c             	add    0xc(%ebp),%eax
  800f5b:	50                   	push   %eax
  800f5c:	57                   	push   %edi
  800f5d:	e8 18 09 00 00       	call   80187a <memmove>
		sys_cputs(buf, m);
  800f62:	83 c4 08             	add    $0x8,%esp
  800f65:	53                   	push   %ebx
  800f66:	57                   	push   %edi
  800f67:	e8 3e f1 ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f6c:	01 de                	add    %ebx,%esi
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	89 f0                	mov    %esi,%eax
  800f73:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f76:	72 cc                	jb     800f44 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7b:	5b                   	pop    %ebx
  800f7c:	5e                   	pop    %esi
  800f7d:	5f                   	pop    %edi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 08             	sub    $0x8,%esp
  800f86:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f8b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f8f:	74 2a                	je     800fbb <devcons_read+0x3b>
  800f91:	eb 05                	jmp    800f98 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f93:	e8 af f1 ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f98:	e8 2b f1 ff ff       	call   8000c8 <sys_cgetc>
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	74 f2                	je     800f93 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	78 16                	js     800fbb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fa5:	83 f8 04             	cmp    $0x4,%eax
  800fa8:	74 0c                	je     800fb6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800faa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fad:	88 02                	mov    %al,(%edx)
	return 1;
  800faf:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb4:	eb 05                	jmp    800fbb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fb6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fc9:	6a 01                	push   $0x1
  800fcb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fce:	50                   	push   %eax
  800fcf:	e8 d6 f0 ff ff       	call   8000aa <sys_cputs>
}
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	c9                   	leave  
  800fd8:	c3                   	ret    

00800fd9 <getchar>:

int
getchar(void)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fdf:	6a 01                	push   $0x1
  800fe1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe4:	50                   	push   %eax
  800fe5:	6a 00                	push   $0x0
  800fe7:	e8 47 f6 ff ff       	call   800633 <read>
	if (r < 0)
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 0f                	js     801002 <getchar+0x29>
		return r;
	if (r < 1)
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	7e 06                	jle    800ffd <getchar+0x24>
		return -E_EOF;
	return c;
  800ff7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ffb:	eb 05                	jmp    801002 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ffd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801002:	c9                   	leave  
  801003:	c3                   	ret    

00801004 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100d:	50                   	push   %eax
  80100e:	ff 75 08             	pushl  0x8(%ebp)
  801011:	e8 b7 f3 ff ff       	call   8003cd <fd_lookup>
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	78 11                	js     80102e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801026:	39 10                	cmp    %edx,(%eax)
  801028:	0f 94 c0             	sete   %al
  80102b:	0f b6 c0             	movzbl %al,%eax
}
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <opencons>:

int
opencons(void)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801036:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801039:	50                   	push   %eax
  80103a:	e8 3f f3 ff ff       	call   80037e <fd_alloc>
  80103f:	83 c4 10             	add    $0x10,%esp
		return r;
  801042:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801044:	85 c0                	test   %eax,%eax
  801046:	78 3e                	js     801086 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801048:	83 ec 04             	sub    $0x4,%esp
  80104b:	68 07 04 00 00       	push   $0x407
  801050:	ff 75 f4             	pushl  -0xc(%ebp)
  801053:	6a 00                	push   $0x0
  801055:	e8 0c f1 ff ff       	call   800166 <sys_page_alloc>
  80105a:	83 c4 10             	add    $0x10,%esp
		return r;
  80105d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 23                	js     801086 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801063:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801069:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80106e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801071:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	50                   	push   %eax
  80107c:	e8 d6 f2 ff ff       	call   800357 <fd2num>
  801081:	89 c2                	mov    %eax,%edx
  801083:	83 c4 10             	add    $0x10,%esp
}
  801086:	89 d0                	mov    %edx,%eax
  801088:	c9                   	leave  
  801089:	c3                   	ret    

0080108a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	56                   	push   %esi
  80108e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80108f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801092:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801098:	e8 8b f0 ff ff       	call   800128 <sys_getenvid>
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	ff 75 0c             	pushl  0xc(%ebp)
  8010a3:	ff 75 08             	pushl  0x8(%ebp)
  8010a6:	56                   	push   %esi
  8010a7:	50                   	push   %eax
  8010a8:	68 38 1f 80 00       	push   $0x801f38
  8010ad:	e8 b1 00 00 00       	call   801163 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010b2:	83 c4 18             	add    $0x18,%esp
  8010b5:	53                   	push   %ebx
  8010b6:	ff 75 10             	pushl  0x10(%ebp)
  8010b9:	e8 54 00 00 00       	call   801112 <vcprintf>
	cprintf("\n");
  8010be:	c7 04 24 22 1f 80 00 	movl   $0x801f22,(%esp)
  8010c5:	e8 99 00 00 00       	call   801163 <cprintf>
  8010ca:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010cd:	cc                   	int3   
  8010ce:	eb fd                	jmp    8010cd <_panic+0x43>

008010d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	53                   	push   %ebx
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010da:	8b 13                	mov    (%ebx),%edx
  8010dc:	8d 42 01             	lea    0x1(%edx),%eax
  8010df:	89 03                	mov    %eax,(%ebx)
  8010e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010ed:	75 1a                	jne    801109 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010ef:	83 ec 08             	sub    $0x8,%esp
  8010f2:	68 ff 00 00 00       	push   $0xff
  8010f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8010fa:	50                   	push   %eax
  8010fb:	e8 aa ef ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  801100:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801106:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801109:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80110d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801110:	c9                   	leave  
  801111:	c3                   	ret    

00801112 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80111b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801122:	00 00 00 
	b.cnt = 0;
  801125:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80112c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80112f:	ff 75 0c             	pushl  0xc(%ebp)
  801132:	ff 75 08             	pushl  0x8(%ebp)
  801135:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80113b:	50                   	push   %eax
  80113c:	68 d0 10 80 00       	push   $0x8010d0
  801141:	e8 54 01 00 00       	call   80129a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801146:	83 c4 08             	add    $0x8,%esp
  801149:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80114f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801155:	50                   	push   %eax
  801156:	e8 4f ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  80115b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801161:	c9                   	leave  
  801162:	c3                   	ret    

00801163 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801169:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80116c:	50                   	push   %eax
  80116d:	ff 75 08             	pushl  0x8(%ebp)
  801170:	e8 9d ff ff ff       	call   801112 <vcprintf>
	va_end(ap);

	return cnt;
}
  801175:	c9                   	leave  
  801176:	c3                   	ret    

00801177 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	57                   	push   %edi
  80117b:	56                   	push   %esi
  80117c:	53                   	push   %ebx
  80117d:	83 ec 1c             	sub    $0x1c,%esp
  801180:	89 c7                	mov    %eax,%edi
  801182:	89 d6                	mov    %edx,%esi
  801184:	8b 45 08             	mov    0x8(%ebp),%eax
  801187:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80118d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801190:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801193:	bb 00 00 00 00       	mov    $0x0,%ebx
  801198:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80119b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80119e:	39 d3                	cmp    %edx,%ebx
  8011a0:	72 05                	jb     8011a7 <printnum+0x30>
  8011a2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011a5:	77 45                	ja     8011ec <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011a7:	83 ec 0c             	sub    $0xc,%esp
  8011aa:	ff 75 18             	pushl  0x18(%ebp)
  8011ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8011b0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011b3:	53                   	push   %ebx
  8011b4:	ff 75 10             	pushl  0x10(%ebp)
  8011b7:	83 ec 08             	sub    $0x8,%esp
  8011ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c6:	e8 95 09 00 00       	call   801b60 <__udivdi3>
  8011cb:	83 c4 18             	add    $0x18,%esp
  8011ce:	52                   	push   %edx
  8011cf:	50                   	push   %eax
  8011d0:	89 f2                	mov    %esi,%edx
  8011d2:	89 f8                	mov    %edi,%eax
  8011d4:	e8 9e ff ff ff       	call   801177 <printnum>
  8011d9:	83 c4 20             	add    $0x20,%esp
  8011dc:	eb 18                	jmp    8011f6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011de:	83 ec 08             	sub    $0x8,%esp
  8011e1:	56                   	push   %esi
  8011e2:	ff 75 18             	pushl  0x18(%ebp)
  8011e5:	ff d7                	call   *%edi
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	eb 03                	jmp    8011ef <printnum+0x78>
  8011ec:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011ef:	83 eb 01             	sub    $0x1,%ebx
  8011f2:	85 db                	test   %ebx,%ebx
  8011f4:	7f e8                	jg     8011de <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f6:	83 ec 08             	sub    $0x8,%esp
  8011f9:	56                   	push   %esi
  8011fa:	83 ec 04             	sub    $0x4,%esp
  8011fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801200:	ff 75 e0             	pushl  -0x20(%ebp)
  801203:	ff 75 dc             	pushl  -0x24(%ebp)
  801206:	ff 75 d8             	pushl  -0x28(%ebp)
  801209:	e8 82 0a 00 00       	call   801c90 <__umoddi3>
  80120e:	83 c4 14             	add    $0x14,%esp
  801211:	0f be 80 5b 1f 80 00 	movsbl 0x801f5b(%eax),%eax
  801218:	50                   	push   %eax
  801219:	ff d7                	call   *%edi
}
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801221:	5b                   	pop    %ebx
  801222:	5e                   	pop    %esi
  801223:	5f                   	pop    %edi
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    

00801226 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801229:	83 fa 01             	cmp    $0x1,%edx
  80122c:	7e 0e                	jle    80123c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80122e:	8b 10                	mov    (%eax),%edx
  801230:	8d 4a 08             	lea    0x8(%edx),%ecx
  801233:	89 08                	mov    %ecx,(%eax)
  801235:	8b 02                	mov    (%edx),%eax
  801237:	8b 52 04             	mov    0x4(%edx),%edx
  80123a:	eb 22                	jmp    80125e <getuint+0x38>
	else if (lflag)
  80123c:	85 d2                	test   %edx,%edx
  80123e:	74 10                	je     801250 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801240:	8b 10                	mov    (%eax),%edx
  801242:	8d 4a 04             	lea    0x4(%edx),%ecx
  801245:	89 08                	mov    %ecx,(%eax)
  801247:	8b 02                	mov    (%edx),%eax
  801249:	ba 00 00 00 00       	mov    $0x0,%edx
  80124e:	eb 0e                	jmp    80125e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801250:	8b 10                	mov    (%eax),%edx
  801252:	8d 4a 04             	lea    0x4(%edx),%ecx
  801255:	89 08                	mov    %ecx,(%eax)
  801257:	8b 02                	mov    (%edx),%eax
  801259:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801266:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80126a:	8b 10                	mov    (%eax),%edx
  80126c:	3b 50 04             	cmp    0x4(%eax),%edx
  80126f:	73 0a                	jae    80127b <sprintputch+0x1b>
		*b->buf++ = ch;
  801271:	8d 4a 01             	lea    0x1(%edx),%ecx
  801274:	89 08                	mov    %ecx,(%eax)
  801276:	8b 45 08             	mov    0x8(%ebp),%eax
  801279:	88 02                	mov    %al,(%edx)
}
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801283:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801286:	50                   	push   %eax
  801287:	ff 75 10             	pushl  0x10(%ebp)
  80128a:	ff 75 0c             	pushl  0xc(%ebp)
  80128d:	ff 75 08             	pushl  0x8(%ebp)
  801290:	e8 05 00 00 00       	call   80129a <vprintfmt>
	va_end(ap);
}
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	c9                   	leave  
  801299:	c3                   	ret    

0080129a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	57                   	push   %edi
  80129e:	56                   	push   %esi
  80129f:	53                   	push   %ebx
  8012a0:	83 ec 2c             	sub    $0x2c,%esp
  8012a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012ac:	eb 12                	jmp    8012c0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	0f 84 89 03 00 00    	je     80163f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012b6:	83 ec 08             	sub    $0x8,%esp
  8012b9:	53                   	push   %ebx
  8012ba:	50                   	push   %eax
  8012bb:	ff d6                	call   *%esi
  8012bd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012c0:	83 c7 01             	add    $0x1,%edi
  8012c3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012c7:	83 f8 25             	cmp    $0x25,%eax
  8012ca:	75 e2                	jne    8012ae <vprintfmt+0x14>
  8012cc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012d0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012de:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ea:	eb 07                	jmp    8012f3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012ef:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f3:	8d 47 01             	lea    0x1(%edi),%eax
  8012f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f9:	0f b6 07             	movzbl (%edi),%eax
  8012fc:	0f b6 c8             	movzbl %al,%ecx
  8012ff:	83 e8 23             	sub    $0x23,%eax
  801302:	3c 55                	cmp    $0x55,%al
  801304:	0f 87 1a 03 00 00    	ja     801624 <vprintfmt+0x38a>
  80130a:	0f b6 c0             	movzbl %al,%eax
  80130d:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  801314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801317:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80131b:	eb d6                	jmp    8012f3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801320:	b8 00 00 00 00       	mov    $0x0,%eax
  801325:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801328:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80132b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80132f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801332:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801335:	83 fa 09             	cmp    $0x9,%edx
  801338:	77 39                	ja     801373 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80133a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80133d:	eb e9                	jmp    801328 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80133f:	8b 45 14             	mov    0x14(%ebp),%eax
  801342:	8d 48 04             	lea    0x4(%eax),%ecx
  801345:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801348:	8b 00                	mov    (%eax),%eax
  80134a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801350:	eb 27                	jmp    801379 <vprintfmt+0xdf>
  801352:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801355:	85 c0                	test   %eax,%eax
  801357:	b9 00 00 00 00       	mov    $0x0,%ecx
  80135c:	0f 49 c8             	cmovns %eax,%ecx
  80135f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801365:	eb 8c                	jmp    8012f3 <vprintfmt+0x59>
  801367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80136a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801371:	eb 80                	jmp    8012f3 <vprintfmt+0x59>
  801373:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801376:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801379:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80137d:	0f 89 70 ff ff ff    	jns    8012f3 <vprintfmt+0x59>
				width = precision, precision = -1;
  801383:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801386:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801389:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801390:	e9 5e ff ff ff       	jmp    8012f3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801395:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80139b:	e9 53 ff ff ff       	jmp    8012f3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8013a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a3:	8d 50 04             	lea    0x4(%eax),%edx
  8013a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	53                   	push   %ebx
  8013ad:	ff 30                	pushl  (%eax)
  8013af:	ff d6                	call   *%esi
			break;
  8013b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013b7:	e9 04 ff ff ff       	jmp    8012c0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8013bf:	8d 50 04             	lea    0x4(%eax),%edx
  8013c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c5:	8b 00                	mov    (%eax),%eax
  8013c7:	99                   	cltd   
  8013c8:	31 d0                	xor    %edx,%eax
  8013ca:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013cc:	83 f8 0f             	cmp    $0xf,%eax
  8013cf:	7f 0b                	jg     8013dc <vprintfmt+0x142>
  8013d1:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8013d8:	85 d2                	test   %edx,%edx
  8013da:	75 18                	jne    8013f4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013dc:	50                   	push   %eax
  8013dd:	68 73 1f 80 00       	push   $0x801f73
  8013e2:	53                   	push   %ebx
  8013e3:	56                   	push   %esi
  8013e4:	e8 94 fe ff ff       	call   80127d <printfmt>
  8013e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013ef:	e9 cc fe ff ff       	jmp    8012c0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013f4:	52                   	push   %edx
  8013f5:	68 dd 1e 80 00       	push   $0x801edd
  8013fa:	53                   	push   %ebx
  8013fb:	56                   	push   %esi
  8013fc:	e8 7c fe ff ff       	call   80127d <printfmt>
  801401:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801407:	e9 b4 fe ff ff       	jmp    8012c0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80140c:	8b 45 14             	mov    0x14(%ebp),%eax
  80140f:	8d 50 04             	lea    0x4(%eax),%edx
  801412:	89 55 14             	mov    %edx,0x14(%ebp)
  801415:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801417:	85 ff                	test   %edi,%edi
  801419:	b8 6c 1f 80 00       	mov    $0x801f6c,%eax
  80141e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801421:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801425:	0f 8e 94 00 00 00    	jle    8014bf <vprintfmt+0x225>
  80142b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80142f:	0f 84 98 00 00 00    	je     8014cd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	ff 75 d0             	pushl  -0x30(%ebp)
  80143b:	57                   	push   %edi
  80143c:	e8 86 02 00 00       	call   8016c7 <strnlen>
  801441:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801444:	29 c1                	sub    %eax,%ecx
  801446:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801449:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80144c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801450:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801453:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801456:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801458:	eb 0f                	jmp    801469 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	53                   	push   %ebx
  80145e:	ff 75 e0             	pushl  -0x20(%ebp)
  801461:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801463:	83 ef 01             	sub    $0x1,%edi
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	85 ff                	test   %edi,%edi
  80146b:	7f ed                	jg     80145a <vprintfmt+0x1c0>
  80146d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801470:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801473:	85 c9                	test   %ecx,%ecx
  801475:	b8 00 00 00 00       	mov    $0x0,%eax
  80147a:	0f 49 c1             	cmovns %ecx,%eax
  80147d:	29 c1                	sub    %eax,%ecx
  80147f:	89 75 08             	mov    %esi,0x8(%ebp)
  801482:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801485:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801488:	89 cb                	mov    %ecx,%ebx
  80148a:	eb 4d                	jmp    8014d9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80148c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801490:	74 1b                	je     8014ad <vprintfmt+0x213>
  801492:	0f be c0             	movsbl %al,%eax
  801495:	83 e8 20             	sub    $0x20,%eax
  801498:	83 f8 5e             	cmp    $0x5e,%eax
  80149b:	76 10                	jbe    8014ad <vprintfmt+0x213>
					putch('?', putdat);
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	ff 75 0c             	pushl  0xc(%ebp)
  8014a3:	6a 3f                	push   $0x3f
  8014a5:	ff 55 08             	call   *0x8(%ebp)
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	eb 0d                	jmp    8014ba <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	ff 75 0c             	pushl  0xc(%ebp)
  8014b3:	52                   	push   %edx
  8014b4:	ff 55 08             	call   *0x8(%ebp)
  8014b7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014ba:	83 eb 01             	sub    $0x1,%ebx
  8014bd:	eb 1a                	jmp    8014d9 <vprintfmt+0x23f>
  8014bf:	89 75 08             	mov    %esi,0x8(%ebp)
  8014c2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014cb:	eb 0c                	jmp    8014d9 <vprintfmt+0x23f>
  8014cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8014d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014d9:	83 c7 01             	add    $0x1,%edi
  8014dc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014e0:	0f be d0             	movsbl %al,%edx
  8014e3:	85 d2                	test   %edx,%edx
  8014e5:	74 23                	je     80150a <vprintfmt+0x270>
  8014e7:	85 f6                	test   %esi,%esi
  8014e9:	78 a1                	js     80148c <vprintfmt+0x1f2>
  8014eb:	83 ee 01             	sub    $0x1,%esi
  8014ee:	79 9c                	jns    80148c <vprintfmt+0x1f2>
  8014f0:	89 df                	mov    %ebx,%edi
  8014f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014f8:	eb 18                	jmp    801512 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014fa:	83 ec 08             	sub    $0x8,%esp
  8014fd:	53                   	push   %ebx
  8014fe:	6a 20                	push   $0x20
  801500:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801502:	83 ef 01             	sub    $0x1,%edi
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	eb 08                	jmp    801512 <vprintfmt+0x278>
  80150a:	89 df                	mov    %ebx,%edi
  80150c:	8b 75 08             	mov    0x8(%ebp),%esi
  80150f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801512:	85 ff                	test   %edi,%edi
  801514:	7f e4                	jg     8014fa <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801516:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801519:	e9 a2 fd ff ff       	jmp    8012c0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80151e:	83 fa 01             	cmp    $0x1,%edx
  801521:	7e 16                	jle    801539 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801523:	8b 45 14             	mov    0x14(%ebp),%eax
  801526:	8d 50 08             	lea    0x8(%eax),%edx
  801529:	89 55 14             	mov    %edx,0x14(%ebp)
  80152c:	8b 50 04             	mov    0x4(%eax),%edx
  80152f:	8b 00                	mov    (%eax),%eax
  801531:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801534:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801537:	eb 32                	jmp    80156b <vprintfmt+0x2d1>
	else if (lflag)
  801539:	85 d2                	test   %edx,%edx
  80153b:	74 18                	je     801555 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80153d:	8b 45 14             	mov    0x14(%ebp),%eax
  801540:	8d 50 04             	lea    0x4(%eax),%edx
  801543:	89 55 14             	mov    %edx,0x14(%ebp)
  801546:	8b 00                	mov    (%eax),%eax
  801548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154b:	89 c1                	mov    %eax,%ecx
  80154d:	c1 f9 1f             	sar    $0x1f,%ecx
  801550:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801553:	eb 16                	jmp    80156b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801555:	8b 45 14             	mov    0x14(%ebp),%eax
  801558:	8d 50 04             	lea    0x4(%eax),%edx
  80155b:	89 55 14             	mov    %edx,0x14(%ebp)
  80155e:	8b 00                	mov    (%eax),%eax
  801560:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801563:	89 c1                	mov    %eax,%ecx
  801565:	c1 f9 1f             	sar    $0x1f,%ecx
  801568:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80156b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80156e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801571:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801576:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80157a:	79 74                	jns    8015f0 <vprintfmt+0x356>
				putch('-', putdat);
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	53                   	push   %ebx
  801580:	6a 2d                	push   $0x2d
  801582:	ff d6                	call   *%esi
				num = -(long long) num;
  801584:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801587:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80158a:	f7 d8                	neg    %eax
  80158c:	83 d2 00             	adc    $0x0,%edx
  80158f:	f7 da                	neg    %edx
  801591:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801594:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801599:	eb 55                	jmp    8015f0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80159b:	8d 45 14             	lea    0x14(%ebp),%eax
  80159e:	e8 83 fc ff ff       	call   801226 <getuint>
			base = 10;
  8015a3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015a8:	eb 46                	jmp    8015f0 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8015aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ad:	e8 74 fc ff ff       	call   801226 <getuint>
			base = 8;
  8015b2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015b7:	eb 37                	jmp    8015f0 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	6a 30                	push   $0x30
  8015bf:	ff d6                	call   *%esi
			putch('x', putdat);
  8015c1:	83 c4 08             	add    $0x8,%esp
  8015c4:	53                   	push   %ebx
  8015c5:	6a 78                	push   $0x78
  8015c7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015cc:	8d 50 04             	lea    0x4(%eax),%edx
  8015cf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015d2:	8b 00                	mov    (%eax),%eax
  8015d4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015d9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015dc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015e1:	eb 0d                	jmp    8015f0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8015e6:	e8 3b fc ff ff       	call   801226 <getuint>
			base = 16;
  8015eb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015f0:	83 ec 0c             	sub    $0xc,%esp
  8015f3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015f7:	57                   	push   %edi
  8015f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015fb:	51                   	push   %ecx
  8015fc:	52                   	push   %edx
  8015fd:	50                   	push   %eax
  8015fe:	89 da                	mov    %ebx,%edx
  801600:	89 f0                	mov    %esi,%eax
  801602:	e8 70 fb ff ff       	call   801177 <printnum>
			break;
  801607:	83 c4 20             	add    $0x20,%esp
  80160a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80160d:	e9 ae fc ff ff       	jmp    8012c0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	53                   	push   %ebx
  801616:	51                   	push   %ecx
  801617:	ff d6                	call   *%esi
			break;
  801619:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80161f:	e9 9c fc ff ff       	jmp    8012c0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	53                   	push   %ebx
  801628:	6a 25                	push   $0x25
  80162a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	eb 03                	jmp    801634 <vprintfmt+0x39a>
  801631:	83 ef 01             	sub    $0x1,%edi
  801634:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801638:	75 f7                	jne    801631 <vprintfmt+0x397>
  80163a:	e9 81 fc ff ff       	jmp    8012c0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80163f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801642:	5b                   	pop    %ebx
  801643:	5e                   	pop    %esi
  801644:	5f                   	pop    %edi
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	83 ec 18             	sub    $0x18,%esp
  80164d:	8b 45 08             	mov    0x8(%ebp),%eax
  801650:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801653:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801656:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80165a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80165d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801664:	85 c0                	test   %eax,%eax
  801666:	74 26                	je     80168e <vsnprintf+0x47>
  801668:	85 d2                	test   %edx,%edx
  80166a:	7e 22                	jle    80168e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80166c:	ff 75 14             	pushl  0x14(%ebp)
  80166f:	ff 75 10             	pushl  0x10(%ebp)
  801672:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801675:	50                   	push   %eax
  801676:	68 60 12 80 00       	push   $0x801260
  80167b:	e8 1a fc ff ff       	call   80129a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801680:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801683:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	eb 05                	jmp    801693 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80168e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801693:	c9                   	leave  
  801694:	c3                   	ret    

00801695 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80169b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80169e:	50                   	push   %eax
  80169f:	ff 75 10             	pushl  0x10(%ebp)
  8016a2:	ff 75 0c             	pushl  0xc(%ebp)
  8016a5:	ff 75 08             	pushl  0x8(%ebp)
  8016a8:	e8 9a ff ff ff       	call   801647 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ba:	eb 03                	jmp    8016bf <strlen+0x10>
		n++;
  8016bc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016bf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016c3:	75 f7                	jne    8016bc <strlen+0xd>
		n++;
	return n;
}
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d5:	eb 03                	jmp    8016da <strnlen+0x13>
		n++;
  8016d7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016da:	39 c2                	cmp    %eax,%edx
  8016dc:	74 08                	je     8016e6 <strnlen+0x1f>
  8016de:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016e2:	75 f3                	jne    8016d7 <strnlen+0x10>
  8016e4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    

008016e8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	53                   	push   %ebx
  8016ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016f2:	89 c2                	mov    %eax,%edx
  8016f4:	83 c2 01             	add    $0x1,%edx
  8016f7:	83 c1 01             	add    $0x1,%ecx
  8016fa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016fe:	88 5a ff             	mov    %bl,-0x1(%edx)
  801701:	84 db                	test   %bl,%bl
  801703:	75 ef                	jne    8016f4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801705:	5b                   	pop    %ebx
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	53                   	push   %ebx
  80170c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80170f:	53                   	push   %ebx
  801710:	e8 9a ff ff ff       	call   8016af <strlen>
  801715:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801718:	ff 75 0c             	pushl  0xc(%ebp)
  80171b:	01 d8                	add    %ebx,%eax
  80171d:	50                   	push   %eax
  80171e:	e8 c5 ff ff ff       	call   8016e8 <strcpy>
	return dst;
}
  801723:	89 d8                	mov    %ebx,%eax
  801725:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801728:	c9                   	leave  
  801729:	c3                   	ret    

0080172a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	56                   	push   %esi
  80172e:	53                   	push   %ebx
  80172f:	8b 75 08             	mov    0x8(%ebp),%esi
  801732:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801735:	89 f3                	mov    %esi,%ebx
  801737:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173a:	89 f2                	mov    %esi,%edx
  80173c:	eb 0f                	jmp    80174d <strncpy+0x23>
		*dst++ = *src;
  80173e:	83 c2 01             	add    $0x1,%edx
  801741:	0f b6 01             	movzbl (%ecx),%eax
  801744:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801747:	80 39 01             	cmpb   $0x1,(%ecx)
  80174a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80174d:	39 da                	cmp    %ebx,%edx
  80174f:	75 ed                	jne    80173e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801751:	89 f0                	mov    %esi,%eax
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5d                   	pop    %ebp
  801756:	c3                   	ret    

00801757 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	56                   	push   %esi
  80175b:	53                   	push   %ebx
  80175c:	8b 75 08             	mov    0x8(%ebp),%esi
  80175f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801762:	8b 55 10             	mov    0x10(%ebp),%edx
  801765:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801767:	85 d2                	test   %edx,%edx
  801769:	74 21                	je     80178c <strlcpy+0x35>
  80176b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80176f:	89 f2                	mov    %esi,%edx
  801771:	eb 09                	jmp    80177c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801773:	83 c2 01             	add    $0x1,%edx
  801776:	83 c1 01             	add    $0x1,%ecx
  801779:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80177c:	39 c2                	cmp    %eax,%edx
  80177e:	74 09                	je     801789 <strlcpy+0x32>
  801780:	0f b6 19             	movzbl (%ecx),%ebx
  801783:	84 db                	test   %bl,%bl
  801785:	75 ec                	jne    801773 <strlcpy+0x1c>
  801787:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801789:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80178c:	29 f0                	sub    %esi,%eax
}
  80178e:	5b                   	pop    %ebx
  80178f:	5e                   	pop    %esi
  801790:	5d                   	pop    %ebp
  801791:	c3                   	ret    

00801792 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801798:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80179b:	eb 06                	jmp    8017a3 <strcmp+0x11>
		p++, q++;
  80179d:	83 c1 01             	add    $0x1,%ecx
  8017a0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017a3:	0f b6 01             	movzbl (%ecx),%eax
  8017a6:	84 c0                	test   %al,%al
  8017a8:	74 04                	je     8017ae <strcmp+0x1c>
  8017aa:	3a 02                	cmp    (%edx),%al
  8017ac:	74 ef                	je     80179d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ae:	0f b6 c0             	movzbl %al,%eax
  8017b1:	0f b6 12             	movzbl (%edx),%edx
  8017b4:	29 d0                	sub    %edx,%eax
}
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	53                   	push   %ebx
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c2:	89 c3                	mov    %eax,%ebx
  8017c4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017c7:	eb 06                	jmp    8017cf <strncmp+0x17>
		n--, p++, q++;
  8017c9:	83 c0 01             	add    $0x1,%eax
  8017cc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017cf:	39 d8                	cmp    %ebx,%eax
  8017d1:	74 15                	je     8017e8 <strncmp+0x30>
  8017d3:	0f b6 08             	movzbl (%eax),%ecx
  8017d6:	84 c9                	test   %cl,%cl
  8017d8:	74 04                	je     8017de <strncmp+0x26>
  8017da:	3a 0a                	cmp    (%edx),%cl
  8017dc:	74 eb                	je     8017c9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017de:	0f b6 00             	movzbl (%eax),%eax
  8017e1:	0f b6 12             	movzbl (%edx),%edx
  8017e4:	29 d0                	sub    %edx,%eax
  8017e6:	eb 05                	jmp    8017ed <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017e8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017ed:	5b                   	pop    %ebx
  8017ee:	5d                   	pop    %ebp
  8017ef:	c3                   	ret    

008017f0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fa:	eb 07                	jmp    801803 <strchr+0x13>
		if (*s == c)
  8017fc:	38 ca                	cmp    %cl,%dl
  8017fe:	74 0f                	je     80180f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801800:	83 c0 01             	add    $0x1,%eax
  801803:	0f b6 10             	movzbl (%eax),%edx
  801806:	84 d2                	test   %dl,%dl
  801808:	75 f2                	jne    8017fc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80180a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181b:	eb 03                	jmp    801820 <strfind+0xf>
  80181d:	83 c0 01             	add    $0x1,%eax
  801820:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801823:	38 ca                	cmp    %cl,%dl
  801825:	74 04                	je     80182b <strfind+0x1a>
  801827:	84 d2                	test   %dl,%dl
  801829:	75 f2                	jne    80181d <strfind+0xc>
			break;
	return (char *) s;
}
  80182b:	5d                   	pop    %ebp
  80182c:	c3                   	ret    

0080182d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	57                   	push   %edi
  801831:	56                   	push   %esi
  801832:	53                   	push   %ebx
  801833:	8b 7d 08             	mov    0x8(%ebp),%edi
  801836:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801839:	85 c9                	test   %ecx,%ecx
  80183b:	74 36                	je     801873 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80183d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801843:	75 28                	jne    80186d <memset+0x40>
  801845:	f6 c1 03             	test   $0x3,%cl
  801848:	75 23                	jne    80186d <memset+0x40>
		c &= 0xFF;
  80184a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80184e:	89 d3                	mov    %edx,%ebx
  801850:	c1 e3 08             	shl    $0x8,%ebx
  801853:	89 d6                	mov    %edx,%esi
  801855:	c1 e6 18             	shl    $0x18,%esi
  801858:	89 d0                	mov    %edx,%eax
  80185a:	c1 e0 10             	shl    $0x10,%eax
  80185d:	09 f0                	or     %esi,%eax
  80185f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801861:	89 d8                	mov    %ebx,%eax
  801863:	09 d0                	or     %edx,%eax
  801865:	c1 e9 02             	shr    $0x2,%ecx
  801868:	fc                   	cld    
  801869:	f3 ab                	rep stos %eax,%es:(%edi)
  80186b:	eb 06                	jmp    801873 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80186d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801870:	fc                   	cld    
  801871:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801873:	89 f8                	mov    %edi,%eax
  801875:	5b                   	pop    %ebx
  801876:	5e                   	pop    %esi
  801877:	5f                   	pop    %edi
  801878:	5d                   	pop    %ebp
  801879:	c3                   	ret    

0080187a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	57                   	push   %edi
  80187e:	56                   	push   %esi
  80187f:	8b 45 08             	mov    0x8(%ebp),%eax
  801882:	8b 75 0c             	mov    0xc(%ebp),%esi
  801885:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801888:	39 c6                	cmp    %eax,%esi
  80188a:	73 35                	jae    8018c1 <memmove+0x47>
  80188c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80188f:	39 d0                	cmp    %edx,%eax
  801891:	73 2e                	jae    8018c1 <memmove+0x47>
		s += n;
		d += n;
  801893:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801896:	89 d6                	mov    %edx,%esi
  801898:	09 fe                	or     %edi,%esi
  80189a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a0:	75 13                	jne    8018b5 <memmove+0x3b>
  8018a2:	f6 c1 03             	test   $0x3,%cl
  8018a5:	75 0e                	jne    8018b5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018a7:	83 ef 04             	sub    $0x4,%edi
  8018aa:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018ad:	c1 e9 02             	shr    $0x2,%ecx
  8018b0:	fd                   	std    
  8018b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b3:	eb 09                	jmp    8018be <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018b5:	83 ef 01             	sub    $0x1,%edi
  8018b8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018bb:	fd                   	std    
  8018bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018be:	fc                   	cld    
  8018bf:	eb 1d                	jmp    8018de <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c1:	89 f2                	mov    %esi,%edx
  8018c3:	09 c2                	or     %eax,%edx
  8018c5:	f6 c2 03             	test   $0x3,%dl
  8018c8:	75 0f                	jne    8018d9 <memmove+0x5f>
  8018ca:	f6 c1 03             	test   $0x3,%cl
  8018cd:	75 0a                	jne    8018d9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018cf:	c1 e9 02             	shr    $0x2,%ecx
  8018d2:	89 c7                	mov    %eax,%edi
  8018d4:	fc                   	cld    
  8018d5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d7:	eb 05                	jmp    8018de <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d9:	89 c7                	mov    %eax,%edi
  8018db:	fc                   	cld    
  8018dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018de:	5e                   	pop    %esi
  8018df:	5f                   	pop    %edi
  8018e0:	5d                   	pop    %ebp
  8018e1:	c3                   	ret    

008018e2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e5:	ff 75 10             	pushl  0x10(%ebp)
  8018e8:	ff 75 0c             	pushl  0xc(%ebp)
  8018eb:	ff 75 08             	pushl  0x8(%ebp)
  8018ee:	e8 87 ff ff ff       	call   80187a <memmove>
}
  8018f3:	c9                   	leave  
  8018f4:	c3                   	ret    

008018f5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	56                   	push   %esi
  8018f9:	53                   	push   %ebx
  8018fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801900:	89 c6                	mov    %eax,%esi
  801902:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801905:	eb 1a                	jmp    801921 <memcmp+0x2c>
		if (*s1 != *s2)
  801907:	0f b6 08             	movzbl (%eax),%ecx
  80190a:	0f b6 1a             	movzbl (%edx),%ebx
  80190d:	38 d9                	cmp    %bl,%cl
  80190f:	74 0a                	je     80191b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801911:	0f b6 c1             	movzbl %cl,%eax
  801914:	0f b6 db             	movzbl %bl,%ebx
  801917:	29 d8                	sub    %ebx,%eax
  801919:	eb 0f                	jmp    80192a <memcmp+0x35>
		s1++, s2++;
  80191b:	83 c0 01             	add    $0x1,%eax
  80191e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801921:	39 f0                	cmp    %esi,%eax
  801923:	75 e2                	jne    801907 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801925:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192a:	5b                   	pop    %ebx
  80192b:	5e                   	pop    %esi
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    

0080192e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	53                   	push   %ebx
  801932:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801935:	89 c1                	mov    %eax,%ecx
  801937:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80193a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80193e:	eb 0a                	jmp    80194a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801940:	0f b6 10             	movzbl (%eax),%edx
  801943:	39 da                	cmp    %ebx,%edx
  801945:	74 07                	je     80194e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801947:	83 c0 01             	add    $0x1,%eax
  80194a:	39 c8                	cmp    %ecx,%eax
  80194c:	72 f2                	jb     801940 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80194e:	5b                   	pop    %ebx
  80194f:	5d                   	pop    %ebp
  801950:	c3                   	ret    

00801951 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	57                   	push   %edi
  801955:	56                   	push   %esi
  801956:	53                   	push   %ebx
  801957:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195d:	eb 03                	jmp    801962 <strtol+0x11>
		s++;
  80195f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801962:	0f b6 01             	movzbl (%ecx),%eax
  801965:	3c 20                	cmp    $0x20,%al
  801967:	74 f6                	je     80195f <strtol+0xe>
  801969:	3c 09                	cmp    $0x9,%al
  80196b:	74 f2                	je     80195f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80196d:	3c 2b                	cmp    $0x2b,%al
  80196f:	75 0a                	jne    80197b <strtol+0x2a>
		s++;
  801971:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801974:	bf 00 00 00 00       	mov    $0x0,%edi
  801979:	eb 11                	jmp    80198c <strtol+0x3b>
  80197b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801980:	3c 2d                	cmp    $0x2d,%al
  801982:	75 08                	jne    80198c <strtol+0x3b>
		s++, neg = 1;
  801984:	83 c1 01             	add    $0x1,%ecx
  801987:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801992:	75 15                	jne    8019a9 <strtol+0x58>
  801994:	80 39 30             	cmpb   $0x30,(%ecx)
  801997:	75 10                	jne    8019a9 <strtol+0x58>
  801999:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80199d:	75 7c                	jne    801a1b <strtol+0xca>
		s += 2, base = 16;
  80199f:	83 c1 02             	add    $0x2,%ecx
  8019a2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a7:	eb 16                	jmp    8019bf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019a9:	85 db                	test   %ebx,%ebx
  8019ab:	75 12                	jne    8019bf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019ad:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019b2:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b5:	75 08                	jne    8019bf <strtol+0x6e>
		s++, base = 8;
  8019b7:	83 c1 01             	add    $0x1,%ecx
  8019ba:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019c7:	0f b6 11             	movzbl (%ecx),%edx
  8019ca:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019cd:	89 f3                	mov    %esi,%ebx
  8019cf:	80 fb 09             	cmp    $0x9,%bl
  8019d2:	77 08                	ja     8019dc <strtol+0x8b>
			dig = *s - '0';
  8019d4:	0f be d2             	movsbl %dl,%edx
  8019d7:	83 ea 30             	sub    $0x30,%edx
  8019da:	eb 22                	jmp    8019fe <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019dc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019df:	89 f3                	mov    %esi,%ebx
  8019e1:	80 fb 19             	cmp    $0x19,%bl
  8019e4:	77 08                	ja     8019ee <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019e6:	0f be d2             	movsbl %dl,%edx
  8019e9:	83 ea 57             	sub    $0x57,%edx
  8019ec:	eb 10                	jmp    8019fe <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019ee:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019f1:	89 f3                	mov    %esi,%ebx
  8019f3:	80 fb 19             	cmp    $0x19,%bl
  8019f6:	77 16                	ja     801a0e <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019f8:	0f be d2             	movsbl %dl,%edx
  8019fb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019fe:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a01:	7d 0b                	jge    801a0e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a03:	83 c1 01             	add    $0x1,%ecx
  801a06:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a0a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a0c:	eb b9                	jmp    8019c7 <strtol+0x76>

	if (endptr)
  801a0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a12:	74 0d                	je     801a21 <strtol+0xd0>
		*endptr = (char *) s;
  801a14:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a17:	89 0e                	mov    %ecx,(%esi)
  801a19:	eb 06                	jmp    801a21 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a1b:	85 db                	test   %ebx,%ebx
  801a1d:	74 98                	je     8019b7 <strtol+0x66>
  801a1f:	eb 9e                	jmp    8019bf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a21:	89 c2                	mov    %eax,%edx
  801a23:	f7 da                	neg    %edx
  801a25:	85 ff                	test   %edi,%edi
  801a27:	0f 45 c2             	cmovne %edx,%eax
}
  801a2a:	5b                   	pop    %ebx
  801a2b:	5e                   	pop    %esi
  801a2c:	5f                   	pop    %edi
  801a2d:	5d                   	pop    %ebp
  801a2e:	c3                   	ret    

00801a2f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
  801a34:	8b 75 08             	mov    0x8(%ebp),%esi
  801a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801a3d:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801a3f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a44:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801a47:	83 ec 0c             	sub    $0xc,%esp
  801a4a:	50                   	push   %eax
  801a4b:	e8 c6 e8 ff ff       	call   800316 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 0e                	js     801a65 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801a57:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a5d:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801a60:	8b 52 78             	mov    0x78(%edx),%edx
  801a63:	eb 0a                	jmp    801a6f <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801a65:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801a6a:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801a6f:	85 f6                	test   %esi,%esi
  801a71:	74 02                	je     801a75 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801a73:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801a75:	85 db                	test   %ebx,%ebx
  801a77:	74 02                	je     801a7b <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801a79:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 08                	js     801a87 <ipc_recv+0x58>
  801a7f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a84:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801a87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8a:	5b                   	pop    %ebx
  801a8b:	5e                   	pop    %esi
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	57                   	push   %edi
  801a92:	56                   	push   %esi
  801a93:	53                   	push   %ebx
  801a94:	83 ec 0c             	sub    $0xc,%esp
  801a97:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801aa0:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801aa2:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801aa7:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801aaa:	ff 75 14             	pushl  0x14(%ebp)
  801aad:	53                   	push   %ebx
  801aae:	56                   	push   %esi
  801aaf:	57                   	push   %edi
  801ab0:	e8 3e e8 ff ff       	call   8002f3 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801abb:	75 07                	jne    801ac4 <ipc_send+0x36>
				    sys_yield();
  801abd:	e8 85 e6 ff ff       	call   800147 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801ac2:	eb e6                	jmp    801aaa <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	74 12                	je     801ada <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801ac8:	50                   	push   %eax
  801ac9:	68 60 22 80 00       	push   $0x802260
  801ace:	6a 4b                	push   $0x4b
  801ad0:	68 74 22 80 00       	push   $0x802274
  801ad5:	e8 b0 f5 ff ff       	call   80108a <_panic>
			 }
	   }
}
  801ada:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5f                   	pop    %edi
  801ae0:	5d                   	pop    %ebp
  801ae1:	c3                   	ret    

00801ae2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801ae8:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801aed:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801af0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af6:	8b 52 50             	mov    0x50(%edx),%edx
  801af9:	39 ca                	cmp    %ecx,%edx
  801afb:	75 0d                	jne    801b0a <ipc_find_env+0x28>
				    return envs[i].env_id;
  801afd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b00:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b05:	8b 40 48             	mov    0x48(%eax),%eax
  801b08:	eb 0f                	jmp    801b19 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801b0a:	83 c0 01             	add    $0x1,%eax
  801b0d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b12:	75 d9                	jne    801aed <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801b14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b19:	5d                   	pop    %ebp
  801b1a:	c3                   	ret    

00801b1b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b21:	89 d0                	mov    %edx,%eax
  801b23:	c1 e8 16             	shr    $0x16,%eax
  801b26:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b2d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b32:	f6 c1 01             	test   $0x1,%cl
  801b35:	74 1d                	je     801b54 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b37:	c1 ea 0c             	shr    $0xc,%edx
  801b3a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b41:	f6 c2 01             	test   $0x1,%dl
  801b44:	74 0e                	je     801b54 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b46:	c1 ea 0c             	shr    $0xc,%edx
  801b49:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b50:	ef 
  801b51:	0f b7 c0             	movzwl %ax,%eax
}
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    
  801b56:	66 90                	xchg   %ax,%ax
  801b58:	66 90                	xchg   %ax,%ax
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
