
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 87 04 00 00       	call   80051a <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 ea 1d 80 00       	push   $0x801dea
  80010c:	6a 23                	push   $0x23
  80010e:	68 07 1e 80 00       	push   $0x801e07
  800113:	e8 6a 0f 00 00       	call   801082 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 ea 1d 80 00       	push   $0x801dea
  80018d:	6a 23                	push   $0x23
  80018f:	68 07 1e 80 00       	push   $0x801e07
  800194:	e8 e9 0e 00 00       	call   801082 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 ea 1d 80 00       	push   $0x801dea
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 07 1e 80 00       	push   $0x801e07
  8001d6:	e8 a7 0e 00 00       	call   801082 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 ea 1d 80 00       	push   $0x801dea
  800211:	6a 23                	push   $0x23
  800213:	68 07 1e 80 00       	push   $0x801e07
  800218:	e8 65 0e 00 00       	call   801082 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 ea 1d 80 00       	push   $0x801dea
  800253:	6a 23                	push   $0x23
  800255:	68 07 1e 80 00       	push   $0x801e07
  80025a:	e8 23 0e 00 00       	call   801082 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 ea 1d 80 00       	push   $0x801dea
  800295:	6a 23                	push   $0x23
  800297:	68 07 1e 80 00       	push   $0x801e07
  80029c:	e8 e1 0d 00 00       	call   801082 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 ea 1d 80 00       	push   $0x801dea
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 07 1e 80 00       	push   $0x801e07
  8002de:	e8 9f 0d 00 00       	call   801082 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 ea 1d 80 00       	push   $0x801dea
  80033b:	6a 23                	push   $0x23
  80033d:	68 07 1e 80 00       	push   $0x801e07
  800342:	e8 3b 0d 00 00       	call   801082 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	05 00 00 00 30       	add    $0x30000000,%eax
  80035a:	c1 e8 0c             	shr    $0xc,%eax
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	05 00 00 00 30       	add    $0x30000000,%eax
  80036a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800381:	89 c2                	mov    %eax,%edx
  800383:	c1 ea 16             	shr    $0x16,%edx
  800386:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80038d:	f6 c2 01             	test   $0x1,%dl
  800390:	74 11                	je     8003a3 <fd_alloc+0x2d>
  800392:	89 c2                	mov    %eax,%edx
  800394:	c1 ea 0c             	shr    $0xc,%edx
  800397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039e:	f6 c2 01             	test   $0x1,%dl
  8003a1:	75 09                	jne    8003ac <fd_alloc+0x36>
			*fd_store = fd;
  8003a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003aa:	eb 17                	jmp    8003c3 <fd_alloc+0x4d>
  8003ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b6:	75 c9                	jne    800381 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003cb:	83 f8 1f             	cmp    $0x1f,%eax
  8003ce:	77 36                	ja     800406 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d0:	c1 e0 0c             	shl    $0xc,%eax
  8003d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 16             	shr    $0x16,%edx
  8003dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 24                	je     80040d <fd_lookup+0x48>
  8003e9:	89 c2                	mov    %eax,%edx
  8003eb:	c1 ea 0c             	shr    $0xc,%edx
  8003ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f5:	f6 c2 01             	test   $0x1,%dl
  8003f8:	74 1a                	je     800414 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800404:	eb 13                	jmp    800419 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040b:	eb 0c                	jmp    800419 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800412:	eb 05                	jmp    800419 <fd_lookup+0x54>
  800414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800424:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800429:	eb 13                	jmp    80043e <dev_lookup+0x23>
  80042b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042e:	39 08                	cmp    %ecx,(%eax)
  800430:	75 0c                	jne    80043e <dev_lookup+0x23>
			*dev = devtab[i];
  800432:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800435:	89 01                	mov    %eax,(%ecx)
			return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	eb 2e                	jmp    80046c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	75 e7                	jne    80042b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800444:	a1 04 40 80 00       	mov    0x804004,%eax
  800449:	8b 40 48             	mov    0x48(%eax),%eax
  80044c:	83 ec 04             	sub    $0x4,%esp
  80044f:	51                   	push   %ecx
  800450:	50                   	push   %eax
  800451:	68 18 1e 80 00       	push   $0x801e18
  800456:	e8 00 0d 00 00       	call   80115b <cprintf>
	*dev = 0;
  80045b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 10             	sub    $0x10,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047f:	50                   	push   %eax
  800480:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800486:	c1 e8 0c             	shr    $0xc,%eax
  800489:	50                   	push   %eax
  80048a:	e8 36 ff ff ff       	call   8003c5 <fd_lookup>
  80048f:	83 c4 08             	add    $0x8,%esp
  800492:	85 c0                	test   %eax,%eax
  800494:	78 05                	js     80049b <fd_close+0x2d>
	    || fd != fd2)
  800496:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800499:	74 0c                	je     8004a7 <fd_close+0x39>
		return (must_exist ? r : 0);
  80049b:	84 db                	test   %bl,%bl
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	0f 44 c2             	cmove  %edx,%eax
  8004a5:	eb 41                	jmp    8004e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff 36                	pushl  (%esi)
  8004b0:	e8 66 ff ff ff       	call   80041b <dev_lookup>
  8004b5:	89 c3                	mov    %eax,%ebx
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	78 1a                	js     8004d8 <fd_close+0x6a>
		if (dev->dev_close)
  8004be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	74 0b                	je     8004d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004cd:	83 ec 0c             	sub    $0xc,%esp
  8004d0:	56                   	push   %esi
  8004d1:	ff d0                	call   *%eax
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	56                   	push   %esi
  8004dc:	6a 00                	push   $0x0
  8004de:	e8 00 fd ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	89 d8                	mov    %ebx,%eax
}
  8004e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004eb:	5b                   	pop    %ebx
  8004ec:	5e                   	pop    %esi
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f8:	50                   	push   %eax
  8004f9:	ff 75 08             	pushl  0x8(%ebp)
  8004fc:	e8 c4 fe ff ff       	call   8003c5 <fd_lookup>
  800501:	83 c4 08             	add    $0x8,%esp
  800504:	85 c0                	test   %eax,%eax
  800506:	78 10                	js     800518 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	6a 01                	push   $0x1
  80050d:	ff 75 f4             	pushl  -0xc(%ebp)
  800510:	e8 59 ff ff ff       	call   80046e <fd_close>
  800515:	83 c4 10             	add    $0x10,%esp
}
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <close_all>:

void
close_all(void)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	53                   	push   %ebx
  80051e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800521:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800526:	83 ec 0c             	sub    $0xc,%esp
  800529:	53                   	push   %ebx
  80052a:	e8 c0 ff ff ff       	call   8004ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052f:	83 c3 01             	add    $0x1,%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	83 fb 20             	cmp    $0x20,%ebx
  800538:	75 ec                	jne    800526 <close_all+0xc>
		close(i);
}
  80053a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	57                   	push   %edi
  800543:	56                   	push   %esi
  800544:	53                   	push   %ebx
  800545:	83 ec 2c             	sub    $0x2c,%esp
  800548:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 08             	pushl  0x8(%ebp)
  800552:	e8 6e fe ff ff       	call   8003c5 <fd_lookup>
  800557:	83 c4 08             	add    $0x8,%esp
  80055a:	85 c0                	test   %eax,%eax
  80055c:	0f 88 c1 00 00 00    	js     800623 <dup+0xe4>
		return r;
	close(newfdnum);
  800562:	83 ec 0c             	sub    $0xc,%esp
  800565:	56                   	push   %esi
  800566:	e8 84 ff ff ff       	call   8004ef <close>

	newfd = INDEX2FD(newfdnum);
  80056b:	89 f3                	mov    %esi,%ebx
  80056d:	c1 e3 0c             	shl    $0xc,%ebx
  800570:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800576:	83 c4 04             	add    $0x4,%esp
  800579:	ff 75 e4             	pushl  -0x1c(%ebp)
  80057c:	e8 de fd ff ff       	call   80035f <fd2data>
  800581:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800583:	89 1c 24             	mov    %ebx,(%esp)
  800586:	e8 d4 fd ff ff       	call   80035f <fd2data>
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800591:	89 f8                	mov    %edi,%eax
  800593:	c1 e8 16             	shr    $0x16,%eax
  800596:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80059d:	a8 01                	test   $0x1,%al
  80059f:	74 37                	je     8005d8 <dup+0x99>
  8005a1:	89 f8                	mov    %edi,%eax
  8005a3:	c1 e8 0c             	shr    $0xc,%eax
  8005a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ad:	f6 c2 01             	test   $0x1,%dl
  8005b0:	74 26                	je     8005d8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c5:	6a 00                	push   $0x0
  8005c7:	57                   	push   %edi
  8005c8:	6a 00                	push   $0x0
  8005ca:	e8 d2 fb ff ff       	call   8001a1 <sys_page_map>
  8005cf:	89 c7                	mov    %eax,%edi
  8005d1:	83 c4 20             	add    $0x20,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	78 2e                	js     800606 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005db:	89 d0                	mov    %edx,%eax
  8005dd:	c1 e8 0c             	shr    $0xc,%eax
  8005e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ef:	50                   	push   %eax
  8005f0:	53                   	push   %ebx
  8005f1:	6a 00                	push   $0x0
  8005f3:	52                   	push   %edx
  8005f4:	6a 00                	push   $0x0
  8005f6:	e8 a6 fb ff ff       	call   8001a1 <sys_page_map>
  8005fb:	89 c7                	mov    %eax,%edi
  8005fd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800600:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800602:	85 ff                	test   %edi,%edi
  800604:	79 1d                	jns    800623 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 00                	push   $0x0
  80060c:	e8 d2 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	ff 75 d4             	pushl  -0x2c(%ebp)
  800617:	6a 00                	push   $0x0
  800619:	e8 c5 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	89 f8                	mov    %edi,%eax
}
  800623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800626:	5b                   	pop    %ebx
  800627:	5e                   	pop    %esi
  800628:	5f                   	pop    %edi
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    

0080062b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	53                   	push   %ebx
  80062f:	83 ec 14             	sub    $0x14,%esp
  800632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800638:	50                   	push   %eax
  800639:	53                   	push   %ebx
  80063a:	e8 86 fd ff ff       	call   8003c5 <fd_lookup>
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	89 c2                	mov    %eax,%edx
  800644:	85 c0                	test   %eax,%eax
  800646:	78 6d                	js     8006b5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800652:	ff 30                	pushl  (%eax)
  800654:	e8 c2 fd ff ff       	call   80041b <dev_lookup>
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 c0                	test   %eax,%eax
  80065e:	78 4c                	js     8006ac <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800663:	8b 42 08             	mov    0x8(%edx),%eax
  800666:	83 e0 03             	and    $0x3,%eax
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	75 21                	jne    80068f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066e:	a1 04 40 80 00       	mov    0x804004,%eax
  800673:	8b 40 48             	mov    0x48(%eax),%eax
  800676:	83 ec 04             	sub    $0x4,%esp
  800679:	53                   	push   %ebx
  80067a:	50                   	push   %eax
  80067b:	68 59 1e 80 00       	push   $0x801e59
  800680:	e8 d6 0a 00 00       	call   80115b <cprintf>
		return -E_INVAL;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80068d:	eb 26                	jmp    8006b5 <read+0x8a>
	}
	if (!dev->dev_read)
  80068f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800692:	8b 40 08             	mov    0x8(%eax),%eax
  800695:	85 c0                	test   %eax,%eax
  800697:	74 17                	je     8006b0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	ff 75 10             	pushl  0x10(%ebp)
  80069f:	ff 75 0c             	pushl  0xc(%ebp)
  8006a2:	52                   	push   %edx
  8006a3:	ff d0                	call   *%eax
  8006a5:	89 c2                	mov    %eax,%edx
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 09                	jmp    8006b5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ac:	89 c2                	mov    %eax,%edx
  8006ae:	eb 05                	jmp    8006b5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b5:	89 d0                	mov    %edx,%eax
  8006b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	57                   	push   %edi
  8006c0:	56                   	push   %esi
  8006c1:	53                   	push   %ebx
  8006c2:	83 ec 0c             	sub    $0xc,%esp
  8006c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d0:	eb 21                	jmp    8006f3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	29 d8                	sub    %ebx,%eax
  8006d9:	50                   	push   %eax
  8006da:	89 d8                	mov    %ebx,%eax
  8006dc:	03 45 0c             	add    0xc(%ebp),%eax
  8006df:	50                   	push   %eax
  8006e0:	57                   	push   %edi
  8006e1:	e8 45 ff ff ff       	call   80062b <read>
		if (m < 0)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	78 10                	js     8006fd <readn+0x41>
			return m;
		if (m == 0)
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	74 0a                	je     8006fb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f1:	01 c3                	add    %eax,%ebx
  8006f3:	39 f3                	cmp    %esi,%ebx
  8006f5:	72 db                	jb     8006d2 <readn+0x16>
  8006f7:	89 d8                	mov    %ebx,%eax
  8006f9:	eb 02                	jmp    8006fd <readn+0x41>
  8006fb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800700:	5b                   	pop    %ebx
  800701:	5e                   	pop    %esi
  800702:	5f                   	pop    %edi
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	53                   	push   %ebx
  800709:	83 ec 14             	sub    $0x14,%esp
  80070c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	53                   	push   %ebx
  800714:	e8 ac fc ff ff       	call   8003c5 <fd_lookup>
  800719:	83 c4 08             	add    $0x8,%esp
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	85 c0                	test   %eax,%eax
  800720:	78 68                	js     80078a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072c:	ff 30                	pushl  (%eax)
  80072e:	e8 e8 fc ff ff       	call   80041b <dev_lookup>
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	85 c0                	test   %eax,%eax
  800738:	78 47                	js     800781 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800741:	75 21                	jne    800764 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800743:	a1 04 40 80 00       	mov    0x804004,%eax
  800748:	8b 40 48             	mov    0x48(%eax),%eax
  80074b:	83 ec 04             	sub    $0x4,%esp
  80074e:	53                   	push   %ebx
  80074f:	50                   	push   %eax
  800750:	68 75 1e 80 00       	push   $0x801e75
  800755:	e8 01 0a 00 00       	call   80115b <cprintf>
		return -E_INVAL;
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800762:	eb 26                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800764:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800767:	8b 52 0c             	mov    0xc(%edx),%edx
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 17                	je     800785 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	50                   	push   %eax
  800778:	ff d2                	call   *%edx
  80077a:	89 c2                	mov    %eax,%edx
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 09                	jmp    80078a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800781:	89 c2                	mov    %eax,%edx
  800783:	eb 05                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800785:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078a:	89 d0                	mov    %edx,%eax
  80078c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <seek>:

int
seek(int fdnum, off_t offset)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800797:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079a:	50                   	push   %eax
  80079b:	ff 75 08             	pushl  0x8(%ebp)
  80079e:	e8 22 fc ff ff       	call   8003c5 <fd_lookup>
  8007a3:	83 c4 08             	add    $0x8,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 0e                	js     8007b8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	83 ec 14             	sub    $0x14,%esp
  8007c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	53                   	push   %ebx
  8007c9:	e8 f7 fb ff ff       	call   8003c5 <fd_lookup>
  8007ce:	83 c4 08             	add    $0x8,%esp
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	78 65                	js     80083c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e1:	ff 30                	pushl  (%eax)
  8007e3:	e8 33 fc ff ff       	call   80041b <dev_lookup>
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	78 44                	js     800833 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f6:	75 21                	jne    800819 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fd:	8b 40 48             	mov    0x48(%eax),%eax
  800800:	83 ec 04             	sub    $0x4,%esp
  800803:	53                   	push   %ebx
  800804:	50                   	push   %eax
  800805:	68 38 1e 80 00       	push   $0x801e38
  80080a:	e8 4c 09 00 00       	call   80115b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800817:	eb 23                	jmp    80083c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800819:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80081c:	8b 52 18             	mov    0x18(%edx),%edx
  80081f:	85 d2                	test   %edx,%edx
  800821:	74 14                	je     800837 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	50                   	push   %eax
  80082a:	ff d2                	call   *%edx
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 09                	jmp    80083c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800833:	89 c2                	mov    %eax,%edx
  800835:	eb 05                	jmp    80083c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800837:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80083c:	89 d0                	mov    %edx,%eax
  80083e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	83 ec 14             	sub    $0x14,%esp
  80084a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800850:	50                   	push   %eax
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 6c fb ff ff       	call   8003c5 <fd_lookup>
  800859:	83 c4 08             	add    $0x8,%esp
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	85 c0                	test   %eax,%eax
  800860:	78 58                	js     8008ba <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086c:	ff 30                	pushl  (%eax)
  80086e:	e8 a8 fb ff ff       	call   80041b <dev_lookup>
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	85 c0                	test   %eax,%eax
  800878:	78 37                	js     8008b1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800881:	74 32                	je     8008b5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800883:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800886:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088d:	00 00 00 
	stat->st_isdir = 0;
  800890:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800897:	00 00 00 
	stat->st_dev = dev;
  80089a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a7:	ff 50 14             	call   *0x14(%eax)
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	eb 09                	jmp    8008ba <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	eb 05                	jmp    8008ba <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008ba:	89 d0                	mov    %edx,%eax
  8008bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	6a 00                	push   $0x0
  8008cb:	ff 75 08             	pushl  0x8(%ebp)
  8008ce:	e8 2c 02 00 00       	call   800aff <open>
  8008d3:	89 c3                	mov    %eax,%ebx
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	78 1b                	js     8008f7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	ff 75 0c             	pushl  0xc(%ebp)
  8008e2:	50                   	push   %eax
  8008e3:	e8 5b ff ff ff       	call   800843 <fstat>
  8008e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ea:	89 1c 24             	mov    %ebx,(%esp)
  8008ed:	e8 fd fb ff ff       	call   8004ef <close>
	return r;
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	89 f0                	mov    %esi,%eax
}
  8008f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  800907:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090e:	75 12                	jne    800922 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  800910:	83 ec 0c             	sub    $0xc,%esp
  800913:	6a 01                	push   $0x1
  800915:	e8 c0 11 00 00       	call   801ada <ipc_find_env>
  80091a:	a3 00 40 80 00       	mov    %eax,0x804000
  80091f:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800922:	6a 07                	push   $0x7
  800924:	68 00 50 80 00       	push   $0x805000
  800929:	56                   	push   %esi
  80092a:	ff 35 00 40 80 00    	pushl  0x804000
  800930:	e8 51 11 00 00       	call   801a86 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  800935:	83 c4 0c             	add    $0xc,%esp
  800938:	6a 00                	push   $0x0
  80093a:	53                   	push   %ebx
  80093b:	6a 00                	push   $0x0
  80093d:	e8 e5 10 00 00       	call   801a27 <ipc_recv>
}
  800942:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 40 0c             	mov    0xc(%eax),%eax
  800955:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095d:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	b8 02 00 00 00       	mov    $0x2,%eax
  80096c:	e8 8d ff ff ff       	call   8008fe <fsipc>
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 40 0c             	mov    0xc(%eax),%eax
  80097f:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
  800989:	b8 06 00 00 00       	mov    $0x6,%eax
  80098e:	e8 6b ff ff ff       	call   8008fe <fsipc>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	53                   	push   %ebx
  800999:	83 ec 04             	sub    $0x4,%esp
  80099c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a5:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b4:	e8 45 ff ff ff       	call   8008fe <fsipc>
  8009b9:	85 c0                	test   %eax,%eax
  8009bb:	78 2c                	js     8009e9 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009bd:	83 ec 08             	sub    $0x8,%esp
  8009c0:	68 00 50 80 00       	push   $0x805000
  8009c5:	53                   	push   %ebx
  8009c6:	e8 15 0d 00 00       	call   8016e0 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8009cb:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d6:	a1 84 50 80 00       	mov    0x805084,%eax
  8009db:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8009e1:	83 c4 10             	add    $0x10,%esp
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	53                   	push   %ebx
  8009f2:	83 ec 08             	sub    $0x8,%esp
  8009f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fe:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  800a03:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  800a09:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a0f:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800a14:	0f 46 c3             	cmovbe %ebx,%eax
  800a17:	50                   	push   %eax
  800a18:	ff 75 0c             	pushl  0xc(%ebp)
  800a1b:	68 08 50 80 00       	push   $0x805008
  800a20:	e8 4d 0e 00 00       	call   801872 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  800a25:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2a:	b8 04 00 00 00       	mov    $0x4,%eax
  800a2f:	e8 ca fe ff ff       	call   8008fe <fsipc>
  800a34:	83 c4 10             	add    $0x10,%esp
  800a37:	85 c0                	test   %eax,%eax
  800a39:	78 3d                	js     800a78 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  800a3b:	39 c3                	cmp    %eax,%ebx
  800a3d:	73 19                	jae    800a58 <devfile_write+0x6a>
  800a3f:	68 a4 1e 80 00       	push   $0x801ea4
  800a44:	68 ab 1e 80 00       	push   $0x801eab
  800a49:	68 9a 00 00 00       	push   $0x9a
  800a4e:	68 c0 1e 80 00       	push   $0x801ec0
  800a53:	e8 2a 06 00 00       	call   801082 <_panic>
	   assert (r <= bytes_written);
  800a58:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a5d:	7e 19                	jle    800a78 <devfile_write+0x8a>
  800a5f:	68 cb 1e 80 00       	push   $0x801ecb
  800a64:	68 ab 1e 80 00       	push   $0x801eab
  800a69:	68 9b 00 00 00       	push   $0x9b
  800a6e:	68 c0 1e 80 00       	push   $0x801ec0
  800a73:	e8 0a 06 00 00       	call   801082 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  800a78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7b:	c9                   	leave  
  800a7c:	c3                   	ret    

00800a7d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8b:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  800a90:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a96:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa0:	e8 59 fe ff ff       	call   8008fe <fsipc>
  800aa5:	89 c3                	mov    %eax,%ebx
  800aa7:	85 c0                	test   %eax,%eax
  800aa9:	78 4b                	js     800af6 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  800aab:	39 c6                	cmp    %eax,%esi
  800aad:	73 16                	jae    800ac5 <devfile_read+0x48>
  800aaf:	68 a4 1e 80 00       	push   $0x801ea4
  800ab4:	68 ab 1e 80 00       	push   $0x801eab
  800ab9:	6a 7c                	push   $0x7c
  800abb:	68 c0 1e 80 00       	push   $0x801ec0
  800ac0:	e8 bd 05 00 00       	call   801082 <_panic>
	   assert(r <= PGSIZE);
  800ac5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aca:	7e 16                	jle    800ae2 <devfile_read+0x65>
  800acc:	68 de 1e 80 00       	push   $0x801ede
  800ad1:	68 ab 1e 80 00       	push   $0x801eab
  800ad6:	6a 7d                	push   $0x7d
  800ad8:	68 c0 1e 80 00       	push   $0x801ec0
  800add:	e8 a0 05 00 00       	call   801082 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae2:	83 ec 04             	sub    $0x4,%esp
  800ae5:	50                   	push   %eax
  800ae6:	68 00 50 80 00       	push   $0x805000
  800aeb:	ff 75 0c             	pushl  0xc(%ebp)
  800aee:	e8 7f 0d 00 00       	call   801872 <memmove>
	   return r;
  800af3:	83 c4 10             	add    $0x10,%esp
}
  800af6:	89 d8                	mov    %ebx,%eax
  800af8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	53                   	push   %ebx
  800b03:	83 ec 20             	sub    $0x20,%esp
  800b06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  800b09:	53                   	push   %ebx
  800b0a:	e8 98 0b 00 00       	call   8016a7 <strlen>
  800b0f:	83 c4 10             	add    $0x10,%esp
  800b12:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b17:	7f 67                	jg     800b80 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1f:	50                   	push   %eax
  800b20:	e8 51 f8 ff ff       	call   800376 <fd_alloc>
  800b25:	83 c4 10             	add    $0x10,%esp
			 return r;
  800b28:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	78 57                	js     800b85 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  800b2e:	83 ec 08             	sub    $0x8,%esp
  800b31:	53                   	push   %ebx
  800b32:	68 00 50 80 00       	push   $0x805000
  800b37:	e8 a4 0b 00 00       	call   8016e0 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  800b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3f:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b47:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4c:	e8 ad fd ff ff       	call   8008fe <fsipc>
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	83 c4 10             	add    $0x10,%esp
  800b56:	85 c0                	test   %eax,%eax
  800b58:	79 14                	jns    800b6e <open+0x6f>
			 fd_close(fd, 0);
  800b5a:	83 ec 08             	sub    $0x8,%esp
  800b5d:	6a 00                	push   $0x0
  800b5f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b62:	e8 07 f9 ff ff       	call   80046e <fd_close>
			 return r;
  800b67:	83 c4 10             	add    $0x10,%esp
  800b6a:	89 da                	mov    %ebx,%edx
  800b6c:	eb 17                	jmp    800b85 <open+0x86>
	   }

	   return fd2num(fd);
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	ff 75 f4             	pushl  -0xc(%ebp)
  800b74:	e8 d6 f7 ff ff       	call   80034f <fd2num>
  800b79:	89 c2                	mov    %eax,%edx
  800b7b:	83 c4 10             	add    $0x10,%esp
  800b7e:	eb 05                	jmp    800b85 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  800b80:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  800b85:	89 d0                	mov    %edx,%eax
  800b87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8a:	c9                   	leave  
  800b8b:	c3                   	ret    

00800b8c <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  800b92:	ba 00 00 00 00       	mov    $0x0,%edx
  800b97:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9c:	e8 5d fd ff ff       	call   8008fe <fsipc>
}
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	ff 75 08             	pushl  0x8(%ebp)
  800bb1:	e8 a9 f7 ff ff       	call   80035f <fd2data>
  800bb6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bb8:	83 c4 08             	add    $0x8,%esp
  800bbb:	68 ea 1e 80 00       	push   $0x801eea
  800bc0:	53                   	push   %ebx
  800bc1:	e8 1a 0b 00 00       	call   8016e0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bc6:	8b 46 04             	mov    0x4(%esi),%eax
  800bc9:	2b 06                	sub    (%esi),%eax
  800bcb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bd1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bd8:	00 00 00 
	stat->st_dev = &devpipe;
  800bdb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800be2:	30 80 00 
	return 0;
}
  800be5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 0c             	sub    $0xc,%esp
  800bf8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bfb:	53                   	push   %ebx
  800bfc:	6a 00                	push   $0x0
  800bfe:	e8 e0 f5 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c03:	89 1c 24             	mov    %ebx,(%esp)
  800c06:	e8 54 f7 ff ff       	call   80035f <fd2data>
  800c0b:	83 c4 08             	add    $0x8,%esp
  800c0e:	50                   	push   %eax
  800c0f:	6a 00                	push   $0x0
  800c11:	e8 cd f5 ff ff       	call   8001e3 <sys_page_unmap>
}
  800c16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c19:	c9                   	leave  
  800c1a:	c3                   	ret    

00800c1b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 1c             	sub    $0x1c,%esp
  800c24:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c27:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c29:	a1 04 40 80 00       	mov    0x804004,%eax
  800c2e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c31:	83 ec 0c             	sub    $0xc,%esp
  800c34:	ff 75 e0             	pushl  -0x20(%ebp)
  800c37:	e8 d7 0e 00 00       	call   801b13 <pageref>
  800c3c:	89 c3                	mov    %eax,%ebx
  800c3e:	89 3c 24             	mov    %edi,(%esp)
  800c41:	e8 cd 0e 00 00       	call   801b13 <pageref>
  800c46:	83 c4 10             	add    $0x10,%esp
  800c49:	39 c3                	cmp    %eax,%ebx
  800c4b:	0f 94 c1             	sete   %cl
  800c4e:	0f b6 c9             	movzbl %cl,%ecx
  800c51:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c54:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c5a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c5d:	39 ce                	cmp    %ecx,%esi
  800c5f:	74 1b                	je     800c7c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c61:	39 c3                	cmp    %eax,%ebx
  800c63:	75 c4                	jne    800c29 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c65:	8b 42 58             	mov    0x58(%edx),%eax
  800c68:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c6b:	50                   	push   %eax
  800c6c:	56                   	push   %esi
  800c6d:	68 f1 1e 80 00       	push   $0x801ef1
  800c72:	e8 e4 04 00 00       	call   80115b <cprintf>
  800c77:	83 c4 10             	add    $0x10,%esp
  800c7a:	eb ad                	jmp    800c29 <_pipeisclosed+0xe>
	}
}
  800c7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 28             	sub    $0x28,%esp
  800c90:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c93:	56                   	push   %esi
  800c94:	e8 c6 f6 ff ff       	call   80035f <fd2data>
  800c99:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9b:	83 c4 10             	add    $0x10,%esp
  800c9e:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca3:	eb 4b                	jmp    800cf0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ca5:	89 da                	mov    %ebx,%edx
  800ca7:	89 f0                	mov    %esi,%eax
  800ca9:	e8 6d ff ff ff       	call   800c1b <_pipeisclosed>
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	75 48                	jne    800cfa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cb2:	e8 88 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cb7:	8b 43 04             	mov    0x4(%ebx),%eax
  800cba:	8b 0b                	mov    (%ebx),%ecx
  800cbc:	8d 51 20             	lea    0x20(%ecx),%edx
  800cbf:	39 d0                	cmp    %edx,%eax
  800cc1:	73 e2                	jae    800ca5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cca:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ccd:	89 c2                	mov    %eax,%edx
  800ccf:	c1 fa 1f             	sar    $0x1f,%edx
  800cd2:	89 d1                	mov    %edx,%ecx
  800cd4:	c1 e9 1b             	shr    $0x1b,%ecx
  800cd7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cda:	83 e2 1f             	and    $0x1f,%edx
  800cdd:	29 ca                	sub    %ecx,%edx
  800cdf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ce3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ce7:	83 c0 01             	add    $0x1,%eax
  800cea:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ced:	83 c7 01             	add    $0x1,%edi
  800cf0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cf3:	75 c2                	jne    800cb7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cf5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf8:	eb 05                	jmp    800cff <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cfa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 18             	sub    $0x18,%esp
  800d10:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d13:	57                   	push   %edi
  800d14:	e8 46 f6 ff ff       	call   80035f <fd2data>
  800d19:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1b:	83 c4 10             	add    $0x10,%esp
  800d1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d23:	eb 3d                	jmp    800d62 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d25:	85 db                	test   %ebx,%ebx
  800d27:	74 04                	je     800d2d <devpipe_read+0x26>
				return i;
  800d29:	89 d8                	mov    %ebx,%eax
  800d2b:	eb 44                	jmp    800d71 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d2d:	89 f2                	mov    %esi,%edx
  800d2f:	89 f8                	mov    %edi,%eax
  800d31:	e8 e5 fe ff ff       	call   800c1b <_pipeisclosed>
  800d36:	85 c0                	test   %eax,%eax
  800d38:	75 32                	jne    800d6c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d3a:	e8 00 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d3f:	8b 06                	mov    (%esi),%eax
  800d41:	3b 46 04             	cmp    0x4(%esi),%eax
  800d44:	74 df                	je     800d25 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d46:	99                   	cltd   
  800d47:	c1 ea 1b             	shr    $0x1b,%edx
  800d4a:	01 d0                	add    %edx,%eax
  800d4c:	83 e0 1f             	and    $0x1f,%eax
  800d4f:	29 d0                	sub    %edx,%eax
  800d51:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d5c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d5f:	83 c3 01             	add    $0x1,%ebx
  800d62:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d65:	75 d8                	jne    800d3f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d67:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6a:	eb 05                	jmp    800d71 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d6c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
  800d7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d84:	50                   	push   %eax
  800d85:	e8 ec f5 ff ff       	call   800376 <fd_alloc>
  800d8a:	83 c4 10             	add    $0x10,%esp
  800d8d:	89 c2                	mov    %eax,%edx
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	0f 88 2c 01 00 00    	js     800ec3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d97:	83 ec 04             	sub    $0x4,%esp
  800d9a:	68 07 04 00 00       	push   $0x407
  800d9f:	ff 75 f4             	pushl  -0xc(%ebp)
  800da2:	6a 00                	push   $0x0
  800da4:	e8 b5 f3 ff ff       	call   80015e <sys_page_alloc>
  800da9:	83 c4 10             	add    $0x10,%esp
  800dac:	89 c2                	mov    %eax,%edx
  800dae:	85 c0                	test   %eax,%eax
  800db0:	0f 88 0d 01 00 00    	js     800ec3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800db6:	83 ec 0c             	sub    $0xc,%esp
  800db9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dbc:	50                   	push   %eax
  800dbd:	e8 b4 f5 ff ff       	call   800376 <fd_alloc>
  800dc2:	89 c3                	mov    %eax,%ebx
  800dc4:	83 c4 10             	add    $0x10,%esp
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	0f 88 e2 00 00 00    	js     800eb1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcf:	83 ec 04             	sub    $0x4,%esp
  800dd2:	68 07 04 00 00       	push   $0x407
  800dd7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dda:	6a 00                	push   $0x0
  800ddc:	e8 7d f3 ff ff       	call   80015e <sys_page_alloc>
  800de1:	89 c3                	mov    %eax,%ebx
  800de3:	83 c4 10             	add    $0x10,%esp
  800de6:	85 c0                	test   %eax,%eax
  800de8:	0f 88 c3 00 00 00    	js     800eb1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dee:	83 ec 0c             	sub    $0xc,%esp
  800df1:	ff 75 f4             	pushl  -0xc(%ebp)
  800df4:	e8 66 f5 ff ff       	call   80035f <fd2data>
  800df9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dfb:	83 c4 0c             	add    $0xc,%esp
  800dfe:	68 07 04 00 00       	push   $0x407
  800e03:	50                   	push   %eax
  800e04:	6a 00                	push   $0x0
  800e06:	e8 53 f3 ff ff       	call   80015e <sys_page_alloc>
  800e0b:	89 c3                	mov    %eax,%ebx
  800e0d:	83 c4 10             	add    $0x10,%esp
  800e10:	85 c0                	test   %eax,%eax
  800e12:	0f 88 89 00 00 00    	js     800ea1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e1e:	e8 3c f5 ff ff       	call   80035f <fd2data>
  800e23:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e2a:	50                   	push   %eax
  800e2b:	6a 00                	push   $0x0
  800e2d:	56                   	push   %esi
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 6c f3 ff ff       	call   8001a1 <sys_page_map>
  800e35:	89 c3                	mov    %eax,%ebx
  800e37:	83 c4 20             	add    $0x20,%esp
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	78 55                	js     800e93 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e3e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e47:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e53:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e61:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e68:	83 ec 0c             	sub    $0xc,%esp
  800e6b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6e:	e8 dc f4 ff ff       	call   80034f <fd2num>
  800e73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e76:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e78:	83 c4 04             	add    $0x4,%esp
  800e7b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7e:	e8 cc f4 ff ff       	call   80034f <fd2num>
  800e83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e86:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e89:	83 c4 10             	add    $0x10,%esp
  800e8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e91:	eb 30                	jmp    800ec3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e93:	83 ec 08             	sub    $0x8,%esp
  800e96:	56                   	push   %esi
  800e97:	6a 00                	push   $0x0
  800e99:	e8 45 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e9e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ea1:	83 ec 08             	sub    $0x8,%esp
  800ea4:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea7:	6a 00                	push   $0x0
  800ea9:	e8 35 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800eae:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eb1:	83 ec 08             	sub    $0x8,%esp
  800eb4:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb7:	6a 00                	push   $0x0
  800eb9:	e8 25 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ec3:	89 d0                	mov    %edx,%eax
  800ec5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed5:	50                   	push   %eax
  800ed6:	ff 75 08             	pushl  0x8(%ebp)
  800ed9:	e8 e7 f4 ff ff       	call   8003c5 <fd_lookup>
  800ede:	83 c4 10             	add    $0x10,%esp
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	78 18                	js     800efd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ee5:	83 ec 0c             	sub    $0xc,%esp
  800ee8:	ff 75 f4             	pushl  -0xc(%ebp)
  800eeb:	e8 6f f4 ff ff       	call   80035f <fd2data>
	return _pipeisclosed(fd, p);
  800ef0:	89 c2                	mov    %eax,%edx
  800ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef5:	e8 21 fd ff ff       	call   800c1b <_pipeisclosed>
  800efa:	83 c4 10             	add    $0x10,%esp
}
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f0f:	68 09 1f 80 00       	push   $0x801f09
  800f14:	ff 75 0c             	pushl  0xc(%ebp)
  800f17:	e8 c4 07 00 00       	call   8016e0 <strcpy>
	return 0;
}
  800f1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f34:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3a:	eb 2d                	jmp    800f69 <devcons_write+0x46>
		m = n - tot;
  800f3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f41:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f44:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f49:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f4c:	83 ec 04             	sub    $0x4,%esp
  800f4f:	53                   	push   %ebx
  800f50:	03 45 0c             	add    0xc(%ebp),%eax
  800f53:	50                   	push   %eax
  800f54:	57                   	push   %edi
  800f55:	e8 18 09 00 00       	call   801872 <memmove>
		sys_cputs(buf, m);
  800f5a:	83 c4 08             	add    $0x8,%esp
  800f5d:	53                   	push   %ebx
  800f5e:	57                   	push   %edi
  800f5f:	e8 3e f1 ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f64:	01 de                	add    %ebx,%esi
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	89 f0                	mov    %esi,%eax
  800f6b:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f6e:	72 cc                	jb     800f3c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f73:	5b                   	pop    %ebx
  800f74:	5e                   	pop    %esi
  800f75:	5f                   	pop    %edi
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f87:	74 2a                	je     800fb3 <devcons_read+0x3b>
  800f89:	eb 05                	jmp    800f90 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f8b:	e8 af f1 ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f90:	e8 2b f1 ff ff       	call   8000c0 <sys_cgetc>
  800f95:	85 c0                	test   %eax,%eax
  800f97:	74 f2                	je     800f8b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 16                	js     800fb3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f9d:	83 f8 04             	cmp    $0x4,%eax
  800fa0:	74 0c                	je     800fae <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fa2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa5:	88 02                	mov    %al,(%edx)
	return 1;
  800fa7:	b8 01 00 00 00       	mov    $0x1,%eax
  800fac:	eb 05                	jmp    800fb3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fae:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fc1:	6a 01                	push   $0x1
  800fc3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc6:	50                   	push   %eax
  800fc7:	e8 d6 f0 ff ff       	call   8000a2 <sys_cputs>
}
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	c9                   	leave  
  800fd0:	c3                   	ret    

00800fd1 <getchar>:

int
getchar(void)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fd7:	6a 01                	push   $0x1
  800fd9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fdc:	50                   	push   %eax
  800fdd:	6a 00                	push   $0x0
  800fdf:	e8 47 f6 ff ff       	call   80062b <read>
	if (r < 0)
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 0f                	js     800ffa <getchar+0x29>
		return r;
	if (r < 1)
  800feb:	85 c0                	test   %eax,%eax
  800fed:	7e 06                	jle    800ff5 <getchar+0x24>
		return -E_EOF;
	return c;
  800fef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ff3:	eb 05                	jmp    800ffa <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ff5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801002:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801005:	50                   	push   %eax
  801006:	ff 75 08             	pushl  0x8(%ebp)
  801009:	e8 b7 f3 ff ff       	call   8003c5 <fd_lookup>
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	78 11                	js     801026 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801018:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101e:	39 10                	cmp    %edx,(%eax)
  801020:	0f 94 c0             	sete   %al
  801023:	0f b6 c0             	movzbl %al,%eax
}
  801026:	c9                   	leave  
  801027:	c3                   	ret    

00801028 <opencons>:

int
opencons(void)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80102e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801031:	50                   	push   %eax
  801032:	e8 3f f3 ff ff       	call   800376 <fd_alloc>
  801037:	83 c4 10             	add    $0x10,%esp
		return r;
  80103a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80103c:	85 c0                	test   %eax,%eax
  80103e:	78 3e                	js     80107e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801040:	83 ec 04             	sub    $0x4,%esp
  801043:	68 07 04 00 00       	push   $0x407
  801048:	ff 75 f4             	pushl  -0xc(%ebp)
  80104b:	6a 00                	push   $0x0
  80104d:	e8 0c f1 ff ff       	call   80015e <sys_page_alloc>
  801052:	83 c4 10             	add    $0x10,%esp
		return r;
  801055:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801057:	85 c0                	test   %eax,%eax
  801059:	78 23                	js     80107e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80105b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801061:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801064:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801066:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801069:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	50                   	push   %eax
  801074:	e8 d6 f2 ff ff       	call   80034f <fd2num>
  801079:	89 c2                	mov    %eax,%edx
  80107b:	83 c4 10             	add    $0x10,%esp
}
  80107e:	89 d0                	mov    %edx,%eax
  801080:	c9                   	leave  
  801081:	c3                   	ret    

00801082 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801087:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80108a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801090:	e8 8b f0 ff ff       	call   800120 <sys_getenvid>
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	ff 75 0c             	pushl  0xc(%ebp)
  80109b:	ff 75 08             	pushl  0x8(%ebp)
  80109e:	56                   	push   %esi
  80109f:	50                   	push   %eax
  8010a0:	68 18 1f 80 00       	push   $0x801f18
  8010a5:	e8 b1 00 00 00       	call   80115b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010aa:	83 c4 18             	add    $0x18,%esp
  8010ad:	53                   	push   %ebx
  8010ae:	ff 75 10             	pushl  0x10(%ebp)
  8010b1:	e8 54 00 00 00       	call   80110a <vcprintf>
	cprintf("\n");
  8010b6:	c7 04 24 02 1f 80 00 	movl   $0x801f02,(%esp)
  8010bd:	e8 99 00 00 00       	call   80115b <cprintf>
  8010c2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c5:	cc                   	int3   
  8010c6:	eb fd                	jmp    8010c5 <_panic+0x43>

008010c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	53                   	push   %ebx
  8010cc:	83 ec 04             	sub    $0x4,%esp
  8010cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010d2:	8b 13                	mov    (%ebx),%edx
  8010d4:	8d 42 01             	lea    0x1(%edx),%eax
  8010d7:	89 03                	mov    %eax,(%ebx)
  8010d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e5:	75 1a                	jne    801101 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	68 ff 00 00 00       	push   $0xff
  8010ef:	8d 43 08             	lea    0x8(%ebx),%eax
  8010f2:	50                   	push   %eax
  8010f3:	e8 aa ef ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8010f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010fe:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801101:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801105:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801108:	c9                   	leave  
  801109:	c3                   	ret    

0080110a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801113:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80111a:	00 00 00 
	b.cnt = 0;
  80111d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801124:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801127:	ff 75 0c             	pushl  0xc(%ebp)
  80112a:	ff 75 08             	pushl  0x8(%ebp)
  80112d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801133:	50                   	push   %eax
  801134:	68 c8 10 80 00       	push   $0x8010c8
  801139:	e8 54 01 00 00       	call   801292 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80113e:	83 c4 08             	add    $0x8,%esp
  801141:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801147:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80114d:	50                   	push   %eax
  80114e:	e8 4f ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  801153:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801159:	c9                   	leave  
  80115a:	c3                   	ret    

0080115b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801161:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801164:	50                   	push   %eax
  801165:	ff 75 08             	pushl  0x8(%ebp)
  801168:	e8 9d ff ff ff       	call   80110a <vcprintf>
	va_end(ap);

	return cnt;
}
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    

0080116f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	57                   	push   %edi
  801173:	56                   	push   %esi
  801174:	53                   	push   %ebx
  801175:	83 ec 1c             	sub    $0x1c,%esp
  801178:	89 c7                	mov    %eax,%edi
  80117a:	89 d6                	mov    %edx,%esi
  80117c:	8b 45 08             	mov    0x8(%ebp),%eax
  80117f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801182:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801185:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801188:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80118b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801190:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801193:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801196:	39 d3                	cmp    %edx,%ebx
  801198:	72 05                	jb     80119f <printnum+0x30>
  80119a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80119d:	77 45                	ja     8011e4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80119f:	83 ec 0c             	sub    $0xc,%esp
  8011a2:	ff 75 18             	pushl  0x18(%ebp)
  8011a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8011a8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011ab:	53                   	push   %ebx
  8011ac:	ff 75 10             	pushl  0x10(%ebp)
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b8:	ff 75 dc             	pushl  -0x24(%ebp)
  8011bb:	ff 75 d8             	pushl  -0x28(%ebp)
  8011be:	e8 8d 09 00 00       	call   801b50 <__udivdi3>
  8011c3:	83 c4 18             	add    $0x18,%esp
  8011c6:	52                   	push   %edx
  8011c7:	50                   	push   %eax
  8011c8:	89 f2                	mov    %esi,%edx
  8011ca:	89 f8                	mov    %edi,%eax
  8011cc:	e8 9e ff ff ff       	call   80116f <printnum>
  8011d1:	83 c4 20             	add    $0x20,%esp
  8011d4:	eb 18                	jmp    8011ee <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011d6:	83 ec 08             	sub    $0x8,%esp
  8011d9:	56                   	push   %esi
  8011da:	ff 75 18             	pushl  0x18(%ebp)
  8011dd:	ff d7                	call   *%edi
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	eb 03                	jmp    8011e7 <printnum+0x78>
  8011e4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011e7:	83 eb 01             	sub    $0x1,%ebx
  8011ea:	85 db                	test   %ebx,%ebx
  8011ec:	7f e8                	jg     8011d6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ee:	83 ec 08             	sub    $0x8,%esp
  8011f1:	56                   	push   %esi
  8011f2:	83 ec 04             	sub    $0x4,%esp
  8011f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011fb:	ff 75 dc             	pushl  -0x24(%ebp)
  8011fe:	ff 75 d8             	pushl  -0x28(%ebp)
  801201:	e8 7a 0a 00 00       	call   801c80 <__umoddi3>
  801206:	83 c4 14             	add    $0x14,%esp
  801209:	0f be 80 3b 1f 80 00 	movsbl 0x801f3b(%eax),%eax
  801210:	50                   	push   %eax
  801211:	ff d7                	call   *%edi
}
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801219:	5b                   	pop    %ebx
  80121a:	5e                   	pop    %esi
  80121b:	5f                   	pop    %edi
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801221:	83 fa 01             	cmp    $0x1,%edx
  801224:	7e 0e                	jle    801234 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801226:	8b 10                	mov    (%eax),%edx
  801228:	8d 4a 08             	lea    0x8(%edx),%ecx
  80122b:	89 08                	mov    %ecx,(%eax)
  80122d:	8b 02                	mov    (%edx),%eax
  80122f:	8b 52 04             	mov    0x4(%edx),%edx
  801232:	eb 22                	jmp    801256 <getuint+0x38>
	else if (lflag)
  801234:	85 d2                	test   %edx,%edx
  801236:	74 10                	je     801248 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801238:	8b 10                	mov    (%eax),%edx
  80123a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80123d:	89 08                	mov    %ecx,(%eax)
  80123f:	8b 02                	mov    (%edx),%eax
  801241:	ba 00 00 00 00       	mov    $0x0,%edx
  801246:	eb 0e                	jmp    801256 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801248:	8b 10                	mov    (%eax),%edx
  80124a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80124d:	89 08                	mov    %ecx,(%eax)
  80124f:	8b 02                	mov    (%edx),%eax
  801251:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80125e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801262:	8b 10                	mov    (%eax),%edx
  801264:	3b 50 04             	cmp    0x4(%eax),%edx
  801267:	73 0a                	jae    801273 <sprintputch+0x1b>
		*b->buf++ = ch;
  801269:	8d 4a 01             	lea    0x1(%edx),%ecx
  80126c:	89 08                	mov    %ecx,(%eax)
  80126e:	8b 45 08             	mov    0x8(%ebp),%eax
  801271:	88 02                	mov    %al,(%edx)
}
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80127b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80127e:	50                   	push   %eax
  80127f:	ff 75 10             	pushl  0x10(%ebp)
  801282:	ff 75 0c             	pushl  0xc(%ebp)
  801285:	ff 75 08             	pushl  0x8(%ebp)
  801288:	e8 05 00 00 00       	call   801292 <vprintfmt>
	va_end(ap);
}
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	c9                   	leave  
  801291:	c3                   	ret    

00801292 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	83 ec 2c             	sub    $0x2c,%esp
  80129b:	8b 75 08             	mov    0x8(%ebp),%esi
  80129e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a4:	eb 12                	jmp    8012b8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	0f 84 89 03 00 00    	je     801637 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012ae:	83 ec 08             	sub    $0x8,%esp
  8012b1:	53                   	push   %ebx
  8012b2:	50                   	push   %eax
  8012b3:	ff d6                	call   *%esi
  8012b5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012b8:	83 c7 01             	add    $0x1,%edi
  8012bb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012bf:	83 f8 25             	cmp    $0x25,%eax
  8012c2:	75 e2                	jne    8012a6 <vprintfmt+0x14>
  8012c4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012c8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012d6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e2:	eb 07                	jmp    8012eb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012e7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012eb:	8d 47 01             	lea    0x1(%edi),%eax
  8012ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f1:	0f b6 07             	movzbl (%edi),%eax
  8012f4:	0f b6 c8             	movzbl %al,%ecx
  8012f7:	83 e8 23             	sub    $0x23,%eax
  8012fa:	3c 55                	cmp    $0x55,%al
  8012fc:	0f 87 1a 03 00 00    	ja     80161c <vprintfmt+0x38a>
  801302:	0f b6 c0             	movzbl %al,%eax
  801305:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  80130c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80130f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801313:	eb d6                	jmp    8012eb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801318:	b8 00 00 00 00       	mov    $0x0,%eax
  80131d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801320:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801323:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801327:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80132a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80132d:	83 fa 09             	cmp    $0x9,%edx
  801330:	77 39                	ja     80136b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801332:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801335:	eb e9                	jmp    801320 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801337:	8b 45 14             	mov    0x14(%ebp),%eax
  80133a:	8d 48 04             	lea    0x4(%eax),%ecx
  80133d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801340:	8b 00                	mov    (%eax),%eax
  801342:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801348:	eb 27                	jmp    801371 <vprintfmt+0xdf>
  80134a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80134d:	85 c0                	test   %eax,%eax
  80134f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801354:	0f 49 c8             	cmovns %eax,%ecx
  801357:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80135d:	eb 8c                	jmp    8012eb <vprintfmt+0x59>
  80135f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801362:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801369:	eb 80                	jmp    8012eb <vprintfmt+0x59>
  80136b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80136e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801371:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801375:	0f 89 70 ff ff ff    	jns    8012eb <vprintfmt+0x59>
				width = precision, precision = -1;
  80137b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80137e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801381:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801388:	e9 5e ff ff ff       	jmp    8012eb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80138d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801393:	e9 53 ff ff ff       	jmp    8012eb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801398:	8b 45 14             	mov    0x14(%ebp),%eax
  80139b:	8d 50 04             	lea    0x4(%eax),%edx
  80139e:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	53                   	push   %ebx
  8013a5:	ff 30                	pushl  (%eax)
  8013a7:	ff d6                	call   *%esi
			break;
  8013a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013af:	e9 04 ff ff ff       	jmp    8012b8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b7:	8d 50 04             	lea    0x4(%eax),%edx
  8013ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8013bd:	8b 00                	mov    (%eax),%eax
  8013bf:	99                   	cltd   
  8013c0:	31 d0                	xor    %edx,%eax
  8013c2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013c4:	83 f8 0f             	cmp    $0xf,%eax
  8013c7:	7f 0b                	jg     8013d4 <vprintfmt+0x142>
  8013c9:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013d0:	85 d2                	test   %edx,%edx
  8013d2:	75 18                	jne    8013ec <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013d4:	50                   	push   %eax
  8013d5:	68 53 1f 80 00       	push   $0x801f53
  8013da:	53                   	push   %ebx
  8013db:	56                   	push   %esi
  8013dc:	e8 94 fe ff ff       	call   801275 <printfmt>
  8013e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013e7:	e9 cc fe ff ff       	jmp    8012b8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013ec:	52                   	push   %edx
  8013ed:	68 bd 1e 80 00       	push   $0x801ebd
  8013f2:	53                   	push   %ebx
  8013f3:	56                   	push   %esi
  8013f4:	e8 7c fe ff ff       	call   801275 <printfmt>
  8013f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013ff:	e9 b4 fe ff ff       	jmp    8012b8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801404:	8b 45 14             	mov    0x14(%ebp),%eax
  801407:	8d 50 04             	lea    0x4(%eax),%edx
  80140a:	89 55 14             	mov    %edx,0x14(%ebp)
  80140d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80140f:	85 ff                	test   %edi,%edi
  801411:	b8 4c 1f 80 00       	mov    $0x801f4c,%eax
  801416:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801419:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80141d:	0f 8e 94 00 00 00    	jle    8014b7 <vprintfmt+0x225>
  801423:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801427:	0f 84 98 00 00 00    	je     8014c5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80142d:	83 ec 08             	sub    $0x8,%esp
  801430:	ff 75 d0             	pushl  -0x30(%ebp)
  801433:	57                   	push   %edi
  801434:	e8 86 02 00 00       	call   8016bf <strnlen>
  801439:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80143c:	29 c1                	sub    %eax,%ecx
  80143e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801441:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801444:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801448:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80144b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80144e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801450:	eb 0f                	jmp    801461 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801452:	83 ec 08             	sub    $0x8,%esp
  801455:	53                   	push   %ebx
  801456:	ff 75 e0             	pushl  -0x20(%ebp)
  801459:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80145b:	83 ef 01             	sub    $0x1,%edi
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	85 ff                	test   %edi,%edi
  801463:	7f ed                	jg     801452 <vprintfmt+0x1c0>
  801465:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801468:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80146b:	85 c9                	test   %ecx,%ecx
  80146d:	b8 00 00 00 00       	mov    $0x0,%eax
  801472:	0f 49 c1             	cmovns %ecx,%eax
  801475:	29 c1                	sub    %eax,%ecx
  801477:	89 75 08             	mov    %esi,0x8(%ebp)
  80147a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80147d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801480:	89 cb                	mov    %ecx,%ebx
  801482:	eb 4d                	jmp    8014d1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801484:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801488:	74 1b                	je     8014a5 <vprintfmt+0x213>
  80148a:	0f be c0             	movsbl %al,%eax
  80148d:	83 e8 20             	sub    $0x20,%eax
  801490:	83 f8 5e             	cmp    $0x5e,%eax
  801493:	76 10                	jbe    8014a5 <vprintfmt+0x213>
					putch('?', putdat);
  801495:	83 ec 08             	sub    $0x8,%esp
  801498:	ff 75 0c             	pushl  0xc(%ebp)
  80149b:	6a 3f                	push   $0x3f
  80149d:	ff 55 08             	call   *0x8(%ebp)
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	eb 0d                	jmp    8014b2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	ff 75 0c             	pushl  0xc(%ebp)
  8014ab:	52                   	push   %edx
  8014ac:	ff 55 08             	call   *0x8(%ebp)
  8014af:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014b2:	83 eb 01             	sub    $0x1,%ebx
  8014b5:	eb 1a                	jmp    8014d1 <vprintfmt+0x23f>
  8014b7:	89 75 08             	mov    %esi,0x8(%ebp)
  8014ba:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014bd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014c0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014c3:	eb 0c                	jmp    8014d1 <vprintfmt+0x23f>
  8014c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8014c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014ce:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014d1:	83 c7 01             	add    $0x1,%edi
  8014d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014d8:	0f be d0             	movsbl %al,%edx
  8014db:	85 d2                	test   %edx,%edx
  8014dd:	74 23                	je     801502 <vprintfmt+0x270>
  8014df:	85 f6                	test   %esi,%esi
  8014e1:	78 a1                	js     801484 <vprintfmt+0x1f2>
  8014e3:	83 ee 01             	sub    $0x1,%esi
  8014e6:	79 9c                	jns    801484 <vprintfmt+0x1f2>
  8014e8:	89 df                	mov    %ebx,%edi
  8014ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014f0:	eb 18                	jmp    80150a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014f2:	83 ec 08             	sub    $0x8,%esp
  8014f5:	53                   	push   %ebx
  8014f6:	6a 20                	push   $0x20
  8014f8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014fa:	83 ef 01             	sub    $0x1,%edi
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	eb 08                	jmp    80150a <vprintfmt+0x278>
  801502:	89 df                	mov    %ebx,%edi
  801504:	8b 75 08             	mov    0x8(%ebp),%esi
  801507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80150a:	85 ff                	test   %edi,%edi
  80150c:	7f e4                	jg     8014f2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80150e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801511:	e9 a2 fd ff ff       	jmp    8012b8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801516:	83 fa 01             	cmp    $0x1,%edx
  801519:	7e 16                	jle    801531 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80151b:	8b 45 14             	mov    0x14(%ebp),%eax
  80151e:	8d 50 08             	lea    0x8(%eax),%edx
  801521:	89 55 14             	mov    %edx,0x14(%ebp)
  801524:	8b 50 04             	mov    0x4(%eax),%edx
  801527:	8b 00                	mov    (%eax),%eax
  801529:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80152f:	eb 32                	jmp    801563 <vprintfmt+0x2d1>
	else if (lflag)
  801531:	85 d2                	test   %edx,%edx
  801533:	74 18                	je     80154d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801535:	8b 45 14             	mov    0x14(%ebp),%eax
  801538:	8d 50 04             	lea    0x4(%eax),%edx
  80153b:	89 55 14             	mov    %edx,0x14(%ebp)
  80153e:	8b 00                	mov    (%eax),%eax
  801540:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801543:	89 c1                	mov    %eax,%ecx
  801545:	c1 f9 1f             	sar    $0x1f,%ecx
  801548:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80154b:	eb 16                	jmp    801563 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80154d:	8b 45 14             	mov    0x14(%ebp),%eax
  801550:	8d 50 04             	lea    0x4(%eax),%edx
  801553:	89 55 14             	mov    %edx,0x14(%ebp)
  801556:	8b 00                	mov    (%eax),%eax
  801558:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80155b:	89 c1                	mov    %eax,%ecx
  80155d:	c1 f9 1f             	sar    $0x1f,%ecx
  801560:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801563:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801566:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801569:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80156e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801572:	79 74                	jns    8015e8 <vprintfmt+0x356>
				putch('-', putdat);
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	53                   	push   %ebx
  801578:	6a 2d                	push   $0x2d
  80157a:	ff d6                	call   *%esi
				num = -(long long) num;
  80157c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80157f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801582:	f7 d8                	neg    %eax
  801584:	83 d2 00             	adc    $0x0,%edx
  801587:	f7 da                	neg    %edx
  801589:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80158c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801591:	eb 55                	jmp    8015e8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801593:	8d 45 14             	lea    0x14(%ebp),%eax
  801596:	e8 83 fc ff ff       	call   80121e <getuint>
			base = 10;
  80159b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015a0:	eb 46                	jmp    8015e8 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8015a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a5:	e8 74 fc ff ff       	call   80121e <getuint>
			base = 8;
  8015aa:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015af:	eb 37                	jmp    8015e8 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015b1:	83 ec 08             	sub    $0x8,%esp
  8015b4:	53                   	push   %ebx
  8015b5:	6a 30                	push   $0x30
  8015b7:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b9:	83 c4 08             	add    $0x8,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	6a 78                	push   $0x78
  8015bf:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c4:	8d 50 04             	lea    0x4(%eax),%edx
  8015c7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015ca:	8b 00                	mov    (%eax),%eax
  8015cc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015d1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015d4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015d9:	eb 0d                	jmp    8015e8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015db:	8d 45 14             	lea    0x14(%ebp),%eax
  8015de:	e8 3b fc ff ff       	call   80121e <getuint>
			base = 16;
  8015e3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015ef:	57                   	push   %edi
  8015f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f3:	51                   	push   %ecx
  8015f4:	52                   	push   %edx
  8015f5:	50                   	push   %eax
  8015f6:	89 da                	mov    %ebx,%edx
  8015f8:	89 f0                	mov    %esi,%eax
  8015fa:	e8 70 fb ff ff       	call   80116f <printnum>
			break;
  8015ff:	83 c4 20             	add    $0x20,%esp
  801602:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801605:	e9 ae fc ff ff       	jmp    8012b8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	53                   	push   %ebx
  80160e:	51                   	push   %ecx
  80160f:	ff d6                	call   *%esi
			break;
  801611:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801614:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801617:	e9 9c fc ff ff       	jmp    8012b8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	53                   	push   %ebx
  801620:	6a 25                	push   $0x25
  801622:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	eb 03                	jmp    80162c <vprintfmt+0x39a>
  801629:	83 ef 01             	sub    $0x1,%edi
  80162c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801630:	75 f7                	jne    801629 <vprintfmt+0x397>
  801632:	e9 81 fc ff ff       	jmp    8012b8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801637:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163a:	5b                   	pop    %ebx
  80163b:	5e                   	pop    %esi
  80163c:	5f                   	pop    %edi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	83 ec 18             	sub    $0x18,%esp
  801645:	8b 45 08             	mov    0x8(%ebp),%eax
  801648:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80164b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80164e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801652:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801655:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80165c:	85 c0                	test   %eax,%eax
  80165e:	74 26                	je     801686 <vsnprintf+0x47>
  801660:	85 d2                	test   %edx,%edx
  801662:	7e 22                	jle    801686 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801664:	ff 75 14             	pushl  0x14(%ebp)
  801667:	ff 75 10             	pushl  0x10(%ebp)
  80166a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80166d:	50                   	push   %eax
  80166e:	68 58 12 80 00       	push   $0x801258
  801673:	e8 1a fc ff ff       	call   801292 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801678:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80167b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80167e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	eb 05                	jmp    80168b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801686:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801693:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801696:	50                   	push   %eax
  801697:	ff 75 10             	pushl  0x10(%ebp)
  80169a:	ff 75 0c             	pushl  0xc(%ebp)
  80169d:	ff 75 08             	pushl  0x8(%ebp)
  8016a0:	e8 9a ff ff ff       	call   80163f <vsnprintf>
	va_end(ap);

	return rc;
}
  8016a5:	c9                   	leave  
  8016a6:	c3                   	ret    

008016a7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b2:	eb 03                	jmp    8016b7 <strlen+0x10>
		n++;
  8016b4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016bb:	75 f7                	jne    8016b4 <strlen+0xd>
		n++;
	return n;
}
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    

008016bf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cd:	eb 03                	jmp    8016d2 <strnlen+0x13>
		n++;
  8016cf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d2:	39 c2                	cmp    %eax,%edx
  8016d4:	74 08                	je     8016de <strnlen+0x1f>
  8016d6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016da:	75 f3                	jne    8016cf <strnlen+0x10>
  8016dc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016de:	5d                   	pop    %ebp
  8016df:	c3                   	ret    

008016e0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	83 c2 01             	add    $0x1,%edx
  8016ef:	83 c1 01             	add    $0x1,%ecx
  8016f2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016f6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016f9:	84 db                	test   %bl,%bl
  8016fb:	75 ef                	jne    8016ec <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016fd:	5b                   	pop    %ebx
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    

00801700 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	53                   	push   %ebx
  801704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801707:	53                   	push   %ebx
  801708:	e8 9a ff ff ff       	call   8016a7 <strlen>
  80170d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801710:	ff 75 0c             	pushl  0xc(%ebp)
  801713:	01 d8                	add    %ebx,%eax
  801715:	50                   	push   %eax
  801716:	e8 c5 ff ff ff       	call   8016e0 <strcpy>
	return dst;
}
  80171b:	89 d8                	mov    %ebx,%eax
  80171d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
  801727:	8b 75 08             	mov    0x8(%ebp),%esi
  80172a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172d:	89 f3                	mov    %esi,%ebx
  80172f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801732:	89 f2                	mov    %esi,%edx
  801734:	eb 0f                	jmp    801745 <strncpy+0x23>
		*dst++ = *src;
  801736:	83 c2 01             	add    $0x1,%edx
  801739:	0f b6 01             	movzbl (%ecx),%eax
  80173c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80173f:	80 39 01             	cmpb   $0x1,(%ecx)
  801742:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801745:	39 da                	cmp    %ebx,%edx
  801747:	75 ed                	jne    801736 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801749:	89 f0                	mov    %esi,%eax
  80174b:	5b                   	pop    %ebx
  80174c:	5e                   	pop    %esi
  80174d:	5d                   	pop    %ebp
  80174e:	c3                   	ret    

0080174f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	56                   	push   %esi
  801753:	53                   	push   %ebx
  801754:	8b 75 08             	mov    0x8(%ebp),%esi
  801757:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175a:	8b 55 10             	mov    0x10(%ebp),%edx
  80175d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80175f:	85 d2                	test   %edx,%edx
  801761:	74 21                	je     801784 <strlcpy+0x35>
  801763:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801767:	89 f2                	mov    %esi,%edx
  801769:	eb 09                	jmp    801774 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80176b:	83 c2 01             	add    $0x1,%edx
  80176e:	83 c1 01             	add    $0x1,%ecx
  801771:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801774:	39 c2                	cmp    %eax,%edx
  801776:	74 09                	je     801781 <strlcpy+0x32>
  801778:	0f b6 19             	movzbl (%ecx),%ebx
  80177b:	84 db                	test   %bl,%bl
  80177d:	75 ec                	jne    80176b <strlcpy+0x1c>
  80177f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801781:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801784:	29 f0                	sub    %esi,%eax
}
  801786:	5b                   	pop    %ebx
  801787:	5e                   	pop    %esi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801790:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801793:	eb 06                	jmp    80179b <strcmp+0x11>
		p++, q++;
  801795:	83 c1 01             	add    $0x1,%ecx
  801798:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80179b:	0f b6 01             	movzbl (%ecx),%eax
  80179e:	84 c0                	test   %al,%al
  8017a0:	74 04                	je     8017a6 <strcmp+0x1c>
  8017a2:	3a 02                	cmp    (%edx),%al
  8017a4:	74 ef                	je     801795 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a6:	0f b6 c0             	movzbl %al,%eax
  8017a9:	0f b6 12             	movzbl (%edx),%edx
  8017ac:	29 d0                	sub    %edx,%eax
}
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    

008017b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	53                   	push   %ebx
  8017b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ba:	89 c3                	mov    %eax,%ebx
  8017bc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017bf:	eb 06                	jmp    8017c7 <strncmp+0x17>
		n--, p++, q++;
  8017c1:	83 c0 01             	add    $0x1,%eax
  8017c4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017c7:	39 d8                	cmp    %ebx,%eax
  8017c9:	74 15                	je     8017e0 <strncmp+0x30>
  8017cb:	0f b6 08             	movzbl (%eax),%ecx
  8017ce:	84 c9                	test   %cl,%cl
  8017d0:	74 04                	je     8017d6 <strncmp+0x26>
  8017d2:	3a 0a                	cmp    (%edx),%cl
  8017d4:	74 eb                	je     8017c1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d6:	0f b6 00             	movzbl (%eax),%eax
  8017d9:	0f b6 12             	movzbl (%edx),%edx
  8017dc:	29 d0                	sub    %edx,%eax
  8017de:	eb 05                	jmp    8017e5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017e0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017e5:	5b                   	pop    %ebx
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    

008017e8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f2:	eb 07                	jmp    8017fb <strchr+0x13>
		if (*s == c)
  8017f4:	38 ca                	cmp    %cl,%dl
  8017f6:	74 0f                	je     801807 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017f8:	83 c0 01             	add    $0x1,%eax
  8017fb:	0f b6 10             	movzbl (%eax),%edx
  8017fe:	84 d2                	test   %dl,%dl
  801800:	75 f2                	jne    8017f4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801802:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    

00801809 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	8b 45 08             	mov    0x8(%ebp),%eax
  80180f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801813:	eb 03                	jmp    801818 <strfind+0xf>
  801815:	83 c0 01             	add    $0x1,%eax
  801818:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80181b:	38 ca                	cmp    %cl,%dl
  80181d:	74 04                	je     801823 <strfind+0x1a>
  80181f:	84 d2                	test   %dl,%dl
  801821:	75 f2                	jne    801815 <strfind+0xc>
			break;
	return (char *) s;
}
  801823:	5d                   	pop    %ebp
  801824:	c3                   	ret    

00801825 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	57                   	push   %edi
  801829:	56                   	push   %esi
  80182a:	53                   	push   %ebx
  80182b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80182e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801831:	85 c9                	test   %ecx,%ecx
  801833:	74 36                	je     80186b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801835:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183b:	75 28                	jne    801865 <memset+0x40>
  80183d:	f6 c1 03             	test   $0x3,%cl
  801840:	75 23                	jne    801865 <memset+0x40>
		c &= 0xFF;
  801842:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801846:	89 d3                	mov    %edx,%ebx
  801848:	c1 e3 08             	shl    $0x8,%ebx
  80184b:	89 d6                	mov    %edx,%esi
  80184d:	c1 e6 18             	shl    $0x18,%esi
  801850:	89 d0                	mov    %edx,%eax
  801852:	c1 e0 10             	shl    $0x10,%eax
  801855:	09 f0                	or     %esi,%eax
  801857:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801859:	89 d8                	mov    %ebx,%eax
  80185b:	09 d0                	or     %edx,%eax
  80185d:	c1 e9 02             	shr    $0x2,%ecx
  801860:	fc                   	cld    
  801861:	f3 ab                	rep stos %eax,%es:(%edi)
  801863:	eb 06                	jmp    80186b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801865:	8b 45 0c             	mov    0xc(%ebp),%eax
  801868:	fc                   	cld    
  801869:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80186b:	89 f8                	mov    %edi,%eax
  80186d:	5b                   	pop    %ebx
  80186e:	5e                   	pop    %esi
  80186f:	5f                   	pop    %edi
  801870:	5d                   	pop    %ebp
  801871:	c3                   	ret    

00801872 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	57                   	push   %edi
  801876:	56                   	push   %esi
  801877:	8b 45 08             	mov    0x8(%ebp),%eax
  80187a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80187d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801880:	39 c6                	cmp    %eax,%esi
  801882:	73 35                	jae    8018b9 <memmove+0x47>
  801884:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801887:	39 d0                	cmp    %edx,%eax
  801889:	73 2e                	jae    8018b9 <memmove+0x47>
		s += n;
		d += n;
  80188b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188e:	89 d6                	mov    %edx,%esi
  801890:	09 fe                	or     %edi,%esi
  801892:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801898:	75 13                	jne    8018ad <memmove+0x3b>
  80189a:	f6 c1 03             	test   $0x3,%cl
  80189d:	75 0e                	jne    8018ad <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80189f:	83 ef 04             	sub    $0x4,%edi
  8018a2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a5:	c1 e9 02             	shr    $0x2,%ecx
  8018a8:	fd                   	std    
  8018a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ab:	eb 09                	jmp    8018b6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018ad:	83 ef 01             	sub    $0x1,%edi
  8018b0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018b3:	fd                   	std    
  8018b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b6:	fc                   	cld    
  8018b7:	eb 1d                	jmp    8018d6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b9:	89 f2                	mov    %esi,%edx
  8018bb:	09 c2                	or     %eax,%edx
  8018bd:	f6 c2 03             	test   $0x3,%dl
  8018c0:	75 0f                	jne    8018d1 <memmove+0x5f>
  8018c2:	f6 c1 03             	test   $0x3,%cl
  8018c5:	75 0a                	jne    8018d1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018c7:	c1 e9 02             	shr    $0x2,%ecx
  8018ca:	89 c7                	mov    %eax,%edi
  8018cc:	fc                   	cld    
  8018cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018cf:	eb 05                	jmp    8018d6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d1:	89 c7                	mov    %eax,%edi
  8018d3:	fc                   	cld    
  8018d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d6:	5e                   	pop    %esi
  8018d7:	5f                   	pop    %edi
  8018d8:	5d                   	pop    %ebp
  8018d9:	c3                   	ret    

008018da <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018dd:	ff 75 10             	pushl  0x10(%ebp)
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	ff 75 08             	pushl  0x8(%ebp)
  8018e6:	e8 87 ff ff ff       	call   801872 <memmove>
}
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    

008018ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	56                   	push   %esi
  8018f1:	53                   	push   %ebx
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f8:	89 c6                	mov    %eax,%esi
  8018fa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018fd:	eb 1a                	jmp    801919 <memcmp+0x2c>
		if (*s1 != *s2)
  8018ff:	0f b6 08             	movzbl (%eax),%ecx
  801902:	0f b6 1a             	movzbl (%edx),%ebx
  801905:	38 d9                	cmp    %bl,%cl
  801907:	74 0a                	je     801913 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801909:	0f b6 c1             	movzbl %cl,%eax
  80190c:	0f b6 db             	movzbl %bl,%ebx
  80190f:	29 d8                	sub    %ebx,%eax
  801911:	eb 0f                	jmp    801922 <memcmp+0x35>
		s1++, s2++;
  801913:	83 c0 01             	add    $0x1,%eax
  801916:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801919:	39 f0                	cmp    %esi,%eax
  80191b:	75 e2                	jne    8018ff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80191d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	53                   	push   %ebx
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80192d:	89 c1                	mov    %eax,%ecx
  80192f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801932:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801936:	eb 0a                	jmp    801942 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801938:	0f b6 10             	movzbl (%eax),%edx
  80193b:	39 da                	cmp    %ebx,%edx
  80193d:	74 07                	je     801946 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80193f:	83 c0 01             	add    $0x1,%eax
  801942:	39 c8                	cmp    %ecx,%eax
  801944:	72 f2                	jb     801938 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801946:	5b                   	pop    %ebx
  801947:	5d                   	pop    %ebp
  801948:	c3                   	ret    

00801949 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	57                   	push   %edi
  80194d:	56                   	push   %esi
  80194e:	53                   	push   %ebx
  80194f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801952:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801955:	eb 03                	jmp    80195a <strtol+0x11>
		s++;
  801957:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195a:	0f b6 01             	movzbl (%ecx),%eax
  80195d:	3c 20                	cmp    $0x20,%al
  80195f:	74 f6                	je     801957 <strtol+0xe>
  801961:	3c 09                	cmp    $0x9,%al
  801963:	74 f2                	je     801957 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801965:	3c 2b                	cmp    $0x2b,%al
  801967:	75 0a                	jne    801973 <strtol+0x2a>
		s++;
  801969:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80196c:	bf 00 00 00 00       	mov    $0x0,%edi
  801971:	eb 11                	jmp    801984 <strtol+0x3b>
  801973:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801978:	3c 2d                	cmp    $0x2d,%al
  80197a:	75 08                	jne    801984 <strtol+0x3b>
		s++, neg = 1;
  80197c:	83 c1 01             	add    $0x1,%ecx
  80197f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801984:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80198a:	75 15                	jne    8019a1 <strtol+0x58>
  80198c:	80 39 30             	cmpb   $0x30,(%ecx)
  80198f:	75 10                	jne    8019a1 <strtol+0x58>
  801991:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801995:	75 7c                	jne    801a13 <strtol+0xca>
		s += 2, base = 16;
  801997:	83 c1 02             	add    $0x2,%ecx
  80199a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80199f:	eb 16                	jmp    8019b7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019a1:	85 db                	test   %ebx,%ebx
  8019a3:	75 12                	jne    8019b7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019aa:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ad:	75 08                	jne    8019b7 <strtol+0x6e>
		s++, base = 8;
  8019af:	83 c1 01             	add    $0x1,%ecx
  8019b2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019bf:	0f b6 11             	movzbl (%ecx),%edx
  8019c2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c5:	89 f3                	mov    %esi,%ebx
  8019c7:	80 fb 09             	cmp    $0x9,%bl
  8019ca:	77 08                	ja     8019d4 <strtol+0x8b>
			dig = *s - '0';
  8019cc:	0f be d2             	movsbl %dl,%edx
  8019cf:	83 ea 30             	sub    $0x30,%edx
  8019d2:	eb 22                	jmp    8019f6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019d4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d7:	89 f3                	mov    %esi,%ebx
  8019d9:	80 fb 19             	cmp    $0x19,%bl
  8019dc:	77 08                	ja     8019e6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019de:	0f be d2             	movsbl %dl,%edx
  8019e1:	83 ea 57             	sub    $0x57,%edx
  8019e4:	eb 10                	jmp    8019f6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019e6:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019e9:	89 f3                	mov    %esi,%ebx
  8019eb:	80 fb 19             	cmp    $0x19,%bl
  8019ee:	77 16                	ja     801a06 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019f0:	0f be d2             	movsbl %dl,%edx
  8019f3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019f6:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f9:	7d 0b                	jge    801a06 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019fb:	83 c1 01             	add    $0x1,%ecx
  8019fe:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a02:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a04:	eb b9                	jmp    8019bf <strtol+0x76>

	if (endptr)
  801a06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a0a:	74 0d                	je     801a19 <strtol+0xd0>
		*endptr = (char *) s;
  801a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a0f:	89 0e                	mov    %ecx,(%esi)
  801a11:	eb 06                	jmp    801a19 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a13:	85 db                	test   %ebx,%ebx
  801a15:	74 98                	je     8019af <strtol+0x66>
  801a17:	eb 9e                	jmp    8019b7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a19:	89 c2                	mov    %eax,%edx
  801a1b:	f7 da                	neg    %edx
  801a1d:	85 ff                	test   %edi,%edi
  801a1f:	0f 45 c2             	cmovne %edx,%eax
}
  801a22:	5b                   	pop    %ebx
  801a23:	5e                   	pop    %esi
  801a24:	5f                   	pop    %edi
  801a25:	5d                   	pop    %ebp
  801a26:	c3                   	ret    

00801a27 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	56                   	push   %esi
  801a2b:	53                   	push   %ebx
  801a2c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801a35:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801a37:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a3c:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801a3f:	83 ec 0c             	sub    $0xc,%esp
  801a42:	50                   	push   %eax
  801a43:	e8 c6 e8 ff ff       	call   80030e <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	78 0e                	js     801a5d <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801a4f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a55:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801a58:	8b 52 78             	mov    0x78(%edx),%edx
  801a5b:	eb 0a                	jmp    801a67 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801a5d:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801a62:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801a67:	85 f6                	test   %esi,%esi
  801a69:	74 02                	je     801a6d <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801a6b:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801a6d:	85 db                	test   %ebx,%ebx
  801a6f:	74 02                	je     801a73 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801a71:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 08                	js     801a7f <ipc_recv+0x58>
  801a77:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7c:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801a7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a82:	5b                   	pop    %ebx
  801a83:	5e                   	pop    %esi
  801a84:	5d                   	pop    %ebp
  801a85:	c3                   	ret    

00801a86 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	57                   	push   %edi
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a92:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801a98:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801a9a:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801a9f:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801aa2:	ff 75 14             	pushl  0x14(%ebp)
  801aa5:	53                   	push   %ebx
  801aa6:	56                   	push   %esi
  801aa7:	57                   	push   %edi
  801aa8:	e8 3e e8 ff ff       	call   8002eb <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ab3:	75 07                	jne    801abc <ipc_send+0x36>
				    sys_yield();
  801ab5:	e8 85 e6 ff ff       	call   80013f <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801aba:	eb e6                	jmp    801aa2 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801abc:	85 c0                	test   %eax,%eax
  801abe:	74 12                	je     801ad2 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801ac0:	50                   	push   %eax
  801ac1:	68 40 22 80 00       	push   $0x802240
  801ac6:	6a 4b                	push   $0x4b
  801ac8:	68 54 22 80 00       	push   $0x802254
  801acd:	e8 b0 f5 ff ff       	call   801082 <_panic>
			 }
	   }
}
  801ad2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad5:	5b                   	pop    %ebx
  801ad6:	5e                   	pop    %esi
  801ad7:	5f                   	pop    %edi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801ae0:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801ae5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ae8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aee:	8b 52 50             	mov    0x50(%edx),%edx
  801af1:	39 ca                	cmp    %ecx,%edx
  801af3:	75 0d                	jne    801b02 <ipc_find_env+0x28>
				    return envs[i].env_id;
  801af5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801af8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801afd:	8b 40 48             	mov    0x48(%eax),%eax
  801b00:	eb 0f                	jmp    801b11 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801b02:	83 c0 01             	add    $0x1,%eax
  801b05:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b0a:	75 d9                	jne    801ae5 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b19:	89 d0                	mov    %edx,%eax
  801b1b:	c1 e8 16             	shr    $0x16,%eax
  801b1e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2a:	f6 c1 01             	test   $0x1,%cl
  801b2d:	74 1d                	je     801b4c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b2f:	c1 ea 0c             	shr    $0xc,%edx
  801b32:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b39:	f6 c2 01             	test   $0x1,%dl
  801b3c:	74 0e                	je     801b4c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b3e:	c1 ea 0c             	shr    $0xc,%edx
  801b41:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b48:	ef 
  801b49:	0f b7 c0             	movzwl %ax,%eax
}
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    
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
