
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 87 04 00 00       	call   800512 <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 ea 1d 80 00       	push   $0x801dea
  800104:	6a 23                	push   $0x23
  800106:	68 07 1e 80 00       	push   $0x801e07
  80010b:	e8 6a 0f 00 00       	call   80107a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 ea 1d 80 00       	push   $0x801dea
  800185:	6a 23                	push   $0x23
  800187:	68 07 1e 80 00       	push   $0x801e07
  80018c:	e8 e9 0e 00 00       	call   80107a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 ea 1d 80 00       	push   $0x801dea
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 07 1e 80 00       	push   $0x801e07
  8001ce:	e8 a7 0e 00 00       	call   80107a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 ea 1d 80 00       	push   $0x801dea
  800209:	6a 23                	push   $0x23
  80020b:	68 07 1e 80 00       	push   $0x801e07
  800210:	e8 65 0e 00 00       	call   80107a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 ea 1d 80 00       	push   $0x801dea
  80024b:	6a 23                	push   $0x23
  80024d:	68 07 1e 80 00       	push   $0x801e07
  800252:	e8 23 0e 00 00       	call   80107a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 ea 1d 80 00       	push   $0x801dea
  80028d:	6a 23                	push   $0x23
  80028f:	68 07 1e 80 00       	push   $0x801e07
  800294:	e8 e1 0d 00 00       	call   80107a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 0a                	push   $0xa
  8002ca:	68 ea 1d 80 00       	push   $0x801dea
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 07 1e 80 00       	push   $0x801e07
  8002d6:	e8 9f 0d 00 00       	call   80107a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 ea 1d 80 00       	push   $0x801dea
  800333:	6a 23                	push   $0x23
  800335:	68 07 1e 80 00       	push   $0x801e07
  80033a:	e8 3b 0d 00 00       	call   80107a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 16             	shr    $0x16,%edx
  80037e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	74 11                	je     80039b <fd_alloc+0x2d>
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 0c             	shr    $0xc,%edx
  80038f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	75 09                	jne    8003a4 <fd_alloc+0x36>
			*fd_store = fd;
  80039b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039d:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a2:	eb 17                	jmp    8003bb <fd_alloc+0x4d>
  8003a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ae:	75 c9                	jne    800379 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c3:	83 f8 1f             	cmp    $0x1f,%eax
  8003c6:	77 36                	ja     8003fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
  8003cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 24                	je     800405 <fd_lookup+0x48>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1a                	je     80040c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	eb 13                	jmp    800411 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800403:	eb 0c                	jmp    800411 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb 05                	jmp    800411 <fd_lookup+0x54>
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041c:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	eb 13                	jmp    800436 <dev_lookup+0x23>
  800423:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 08                	cmp    %ecx,(%eax)
  800428:	75 0c                	jne    800436 <dev_lookup+0x23>
			*dev = devtab[i];
  80042a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	eb 2e                	jmp    800464 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	75 e7                	jne    800423 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043c:	a1 04 40 80 00       	mov    0x804004,%eax
  800441:	8b 40 48             	mov    0x48(%eax),%eax
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	51                   	push   %ecx
  800448:	50                   	push   %eax
  800449:	68 18 1e 80 00       	push   $0x801e18
  80044e:	e8 00 0d 00 00       	call   801153 <cprintf>
	*dev = 0;
  800453:	8b 45 0c             	mov    0xc(%ebp),%eax
  800456:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	56                   	push   %esi
  80046a:	53                   	push   %ebx
  80046b:	83 ec 10             	sub    $0x10,%esp
  80046e:	8b 75 08             	mov    0x8(%ebp),%esi
  800471:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800477:	50                   	push   %eax
  800478:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047e:	c1 e8 0c             	shr    $0xc,%eax
  800481:	50                   	push   %eax
  800482:	e8 36 ff ff ff       	call   8003bd <fd_lookup>
  800487:	83 c4 08             	add    $0x8,%esp
  80048a:	85 c0                	test   %eax,%eax
  80048c:	78 05                	js     800493 <fd_close+0x2d>
	    || fd != fd2)
  80048e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800491:	74 0c                	je     80049f <fd_close+0x39>
		return (must_exist ? r : 0);
  800493:	84 db                	test   %bl,%bl
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
  80049a:	0f 44 c2             	cmove  %edx,%eax
  80049d:	eb 41                	jmp    8004e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a5:	50                   	push   %eax
  8004a6:	ff 36                	pushl  (%esi)
  8004a8:	e8 66 ff ff ff       	call   800413 <dev_lookup>
  8004ad:	89 c3                	mov    %eax,%ebx
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	78 1a                	js     8004d0 <fd_close+0x6a>
		if (dev->dev_close)
  8004b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	74 0b                	je     8004d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c5:	83 ec 0c             	sub    $0xc,%esp
  8004c8:	56                   	push   %esi
  8004c9:	ff d0                	call   *%eax
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	56                   	push   %esi
  8004d4:	6a 00                	push   $0x0
  8004d6:	e8 00 fd ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	89 d8                	mov    %ebx,%eax
}
  8004e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5e                   	pop    %esi
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	ff 75 08             	pushl  0x8(%ebp)
  8004f4:	e8 c4 fe ff ff       	call   8003bd <fd_lookup>
  8004f9:	83 c4 08             	add    $0x8,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 10                	js     800510 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	6a 01                	push   $0x1
  800505:	ff 75 f4             	pushl  -0xc(%ebp)
  800508:	e8 59 ff ff ff       	call   800466 <fd_close>
  80050d:	83 c4 10             	add    $0x10,%esp
}
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <close_all>:

void
close_all(void)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	53                   	push   %ebx
  800516:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800519:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	53                   	push   %ebx
  800522:	e8 c0 ff ff ff       	call   8004e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800527:	83 c3 01             	add    $0x1,%ebx
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	83 fb 20             	cmp    $0x20,%ebx
  800530:	75 ec                	jne    80051e <close_all+0xc>
		close(i);
}
  800532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	57                   	push   %edi
  80053b:	56                   	push   %esi
  80053c:	53                   	push   %ebx
  80053d:	83 ec 2c             	sub    $0x2c,%esp
  800540:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800543:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800546:	50                   	push   %eax
  800547:	ff 75 08             	pushl  0x8(%ebp)
  80054a:	e8 6e fe ff ff       	call   8003bd <fd_lookup>
  80054f:	83 c4 08             	add    $0x8,%esp
  800552:	85 c0                	test   %eax,%eax
  800554:	0f 88 c1 00 00 00    	js     80061b <dup+0xe4>
		return r;
	close(newfdnum);
  80055a:	83 ec 0c             	sub    $0xc,%esp
  80055d:	56                   	push   %esi
  80055e:	e8 84 ff ff ff       	call   8004e7 <close>

	newfd = INDEX2FD(newfdnum);
  800563:	89 f3                	mov    %esi,%ebx
  800565:	c1 e3 0c             	shl    $0xc,%ebx
  800568:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056e:	83 c4 04             	add    $0x4,%esp
  800571:	ff 75 e4             	pushl  -0x1c(%ebp)
  800574:	e8 de fd ff ff       	call   800357 <fd2data>
  800579:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057b:	89 1c 24             	mov    %ebx,(%esp)
  80057e:	e8 d4 fd ff ff       	call   800357 <fd2data>
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800589:	89 f8                	mov    %edi,%eax
  80058b:	c1 e8 16             	shr    $0x16,%eax
  80058e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800595:	a8 01                	test   $0x1,%al
  800597:	74 37                	je     8005d0 <dup+0x99>
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 0c             	shr    $0xc,%eax
  80059e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a5:	f6 c2 01             	test   $0x1,%dl
  8005a8:	74 26                	je     8005d0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b9:	50                   	push   %eax
  8005ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bd:	6a 00                	push   $0x0
  8005bf:	57                   	push   %edi
  8005c0:	6a 00                	push   $0x0
  8005c2:	e8 d2 fb ff ff       	call   800199 <sys_page_map>
  8005c7:	89 c7                	mov    %eax,%edi
  8005c9:	83 c4 20             	add    $0x20,%esp
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	78 2e                	js     8005fe <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d3:	89 d0                	mov    %edx,%eax
  8005d5:	c1 e8 0c             	shr    $0xc,%eax
  8005d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e7:	50                   	push   %eax
  8005e8:	53                   	push   %ebx
  8005e9:	6a 00                	push   $0x0
  8005eb:	52                   	push   %edx
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 a6 fb ff ff       	call   800199 <sys_page_map>
  8005f3:	89 c7                	mov    %eax,%edi
  8005f5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	79 1d                	jns    80061b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 00                	push   $0x0
  800604:	e8 d2 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060f:	6a 00                	push   $0x0
  800611:	e8 c5 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	89 f8                	mov    %edi,%eax
}
  80061b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061e:	5b                   	pop    %ebx
  80061f:	5e                   	pop    %esi
  800620:	5f                   	pop    %edi
  800621:	5d                   	pop    %ebp
  800622:	c3                   	ret    

00800623 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800623:	55                   	push   %ebp
  800624:	89 e5                	mov    %esp,%ebp
  800626:	53                   	push   %ebx
  800627:	83 ec 14             	sub    $0x14,%esp
  80062a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800630:	50                   	push   %eax
  800631:	53                   	push   %ebx
  800632:	e8 86 fd ff ff       	call   8003bd <fd_lookup>
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	89 c2                	mov    %eax,%edx
  80063c:	85 c0                	test   %eax,%eax
  80063e:	78 6d                	js     8006ad <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800646:	50                   	push   %eax
  800647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064a:	ff 30                	pushl  (%eax)
  80064c:	e8 c2 fd ff ff       	call   800413 <dev_lookup>
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	85 c0                	test   %eax,%eax
  800656:	78 4c                	js     8006a4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800658:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065b:	8b 42 08             	mov    0x8(%edx),%eax
  80065e:	83 e0 03             	and    $0x3,%eax
  800661:	83 f8 01             	cmp    $0x1,%eax
  800664:	75 21                	jne    800687 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800666:	a1 04 40 80 00       	mov    0x804004,%eax
  80066b:	8b 40 48             	mov    0x48(%eax),%eax
  80066e:	83 ec 04             	sub    $0x4,%esp
  800671:	53                   	push   %ebx
  800672:	50                   	push   %eax
  800673:	68 59 1e 80 00       	push   $0x801e59
  800678:	e8 d6 0a 00 00       	call   801153 <cprintf>
		return -E_INVAL;
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800685:	eb 26                	jmp    8006ad <read+0x8a>
	}
	if (!dev->dev_read)
  800687:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068a:	8b 40 08             	mov    0x8(%eax),%eax
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 17                	je     8006a8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800691:	83 ec 04             	sub    $0x4,%esp
  800694:	ff 75 10             	pushl  0x10(%ebp)
  800697:	ff 75 0c             	pushl  0xc(%ebp)
  80069a:	52                   	push   %edx
  80069b:	ff d0                	call   *%eax
  80069d:	89 c2                	mov    %eax,%edx
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 09                	jmp    8006ad <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a4:	89 c2                	mov    %eax,%edx
  8006a6:	eb 05                	jmp    8006ad <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ad:	89 d0                	mov    %edx,%eax
  8006af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	57                   	push   %edi
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c8:	eb 21                	jmp    8006eb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ca:	83 ec 04             	sub    $0x4,%esp
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	29 d8                	sub    %ebx,%eax
  8006d1:	50                   	push   %eax
  8006d2:	89 d8                	mov    %ebx,%eax
  8006d4:	03 45 0c             	add    0xc(%ebp),%eax
  8006d7:	50                   	push   %eax
  8006d8:	57                   	push   %edi
  8006d9:	e8 45 ff ff ff       	call   800623 <read>
		if (m < 0)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	78 10                	js     8006f5 <readn+0x41>
			return m;
		if (m == 0)
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	74 0a                	je     8006f3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e9:	01 c3                	add    %eax,%ebx
  8006eb:	39 f3                	cmp    %esi,%ebx
  8006ed:	72 db                	jb     8006ca <readn+0x16>
  8006ef:	89 d8                	mov    %ebx,%eax
  8006f1:	eb 02                	jmp    8006f5 <readn+0x41>
  8006f3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	53                   	push   %ebx
  800701:	83 ec 14             	sub    $0x14,%esp
  800704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800707:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	53                   	push   %ebx
  80070c:	e8 ac fc ff ff       	call   8003bd <fd_lookup>
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	89 c2                	mov    %eax,%edx
  800716:	85 c0                	test   %eax,%eax
  800718:	78 68                	js     800782 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800720:	50                   	push   %eax
  800721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800724:	ff 30                	pushl  (%eax)
  800726:	e8 e8 fc ff ff       	call   800413 <dev_lookup>
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	85 c0                	test   %eax,%eax
  800730:	78 47                	js     800779 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800739:	75 21                	jne    80075c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073b:	a1 04 40 80 00       	mov    0x804004,%eax
  800740:	8b 40 48             	mov    0x48(%eax),%eax
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	53                   	push   %ebx
  800747:	50                   	push   %eax
  800748:	68 75 1e 80 00       	push   $0x801e75
  80074d:	e8 01 0a 00 00       	call   801153 <cprintf>
		return -E_INVAL;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075a:	eb 26                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075f:	8b 52 0c             	mov    0xc(%edx),%edx
  800762:	85 d2                	test   %edx,%edx
  800764:	74 17                	je     80077d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	50                   	push   %eax
  800770:	ff d2                	call   *%edx
  800772:	89 c2                	mov    %eax,%edx
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 09                	jmp    800782 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800779:	89 c2                	mov    %eax,%edx
  80077b:	eb 05                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800782:	89 d0                	mov    %edx,%eax
  800784:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <seek>:

int
seek(int fdnum, off_t offset)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 22 fc ff ff       	call   8003bd <fd_lookup>
  80079b:	83 c4 08             	add    $0x8,%esp
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	78 0e                	js     8007b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	83 ec 14             	sub    $0x14,%esp
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	53                   	push   %ebx
  8007c1:	e8 f7 fb ff ff       	call   8003bd <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 65                	js     800834 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	ff 30                	pushl  (%eax)
  8007db:	e8 33 fc ff ff       	call   800413 <dev_lookup>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 44                	js     80082b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ee:	75 21                	jne    800811 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f5:	8b 40 48             	mov    0x48(%eax),%eax
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	53                   	push   %ebx
  8007fc:	50                   	push   %eax
  8007fd:	68 38 1e 80 00       	push   $0x801e38
  800802:	e8 4c 09 00 00       	call   801153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080f:	eb 23                	jmp    800834 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800811:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800814:	8b 52 18             	mov    0x18(%edx),%edx
  800817:	85 d2                	test   %edx,%edx
  800819:	74 14                	je     80082f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	ff 75 0c             	pushl  0xc(%ebp)
  800821:	50                   	push   %eax
  800822:	ff d2                	call   *%edx
  800824:	89 c2                	mov    %eax,%edx
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	eb 09                	jmp    800834 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082b:	89 c2                	mov    %eax,%edx
  80082d:	eb 05                	jmp    800834 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800834:	89 d0                	mov    %edx,%eax
  800836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 14             	sub    $0x14,%esp
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800845:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	ff 75 08             	pushl  0x8(%ebp)
  80084c:	e8 6c fb ff ff       	call   8003bd <fd_lookup>
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	89 c2                	mov    %eax,%edx
  800856:	85 c0                	test   %eax,%eax
  800858:	78 58                	js     8008b2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800860:	50                   	push   %eax
  800861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800864:	ff 30                	pushl  (%eax)
  800866:	e8 a8 fb ff ff       	call   800413 <dev_lookup>
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 37                	js     8008a9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800875:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800879:	74 32                	je     8008ad <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800885:	00 00 00 
	stat->st_isdir = 0;
  800888:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088f:	00 00 00 
	stat->st_dev = dev;
  800892:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	ff 75 f0             	pushl  -0x10(%ebp)
  80089f:	ff 50 14             	call   *0x14(%eax)
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	eb 09                	jmp    8008b2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a9:	89 c2                	mov    %eax,%edx
  8008ab:	eb 05                	jmp    8008b2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b2:	89 d0                	mov    %edx,%eax
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	6a 00                	push   $0x0
  8008c3:	ff 75 08             	pushl  0x8(%ebp)
  8008c6:	e8 2c 02 00 00       	call   800af7 <open>
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	78 1b                	js     8008ef <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	50                   	push   %eax
  8008db:	e8 5b ff ff ff       	call   80083b <fstat>
  8008e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	e8 fd fb ff ff       	call   8004e7 <close>
	return r;
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	89 f0                	mov    %esi,%eax
}
  8008ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	89 c6                	mov    %eax,%esi
  8008fd:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  8008ff:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800906:	75 12                	jne    80091a <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  800908:	83 ec 0c             	sub    $0xc,%esp
  80090b:	6a 01                	push   $0x1
  80090d:	e8 c0 11 00 00       	call   801ad2 <ipc_find_env>
  800912:	a3 00 40 80 00       	mov    %eax,0x804000
  800917:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091a:	6a 07                	push   $0x7
  80091c:	68 00 50 80 00       	push   $0x805000
  800921:	56                   	push   %esi
  800922:	ff 35 00 40 80 00    	pushl  0x804000
  800928:	e8 51 11 00 00       	call   801a7e <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  80092d:	83 c4 0c             	add    $0xc,%esp
  800930:	6a 00                	push   $0x0
  800932:	53                   	push   %ebx
  800933:	6a 00                	push   $0x0
  800935:	e8 e5 10 00 00       	call   801a1f <ipc_recv>
}
  80093a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 40 0c             	mov    0xc(%eax),%eax
  80094d:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	b8 02 00 00 00       	mov    $0x2,%eax
  800964:	e8 8d ff ff ff       	call   8008f6 <fsipc>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 40 0c             	mov    0xc(%eax),%eax
  800977:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	b8 06 00 00 00       	mov    $0x6,%eax
  800986:	e8 6b ff ff ff       	call   8008f6 <fsipc>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	83 ec 04             	sub    $0x4,%esp
  800994:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ac:	e8 45 ff ff ff       	call   8008f6 <fsipc>
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	78 2c                	js     8009e1 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b5:	83 ec 08             	sub    $0x8,%esp
  8009b8:	68 00 50 80 00       	push   $0x805000
  8009bd:	53                   	push   %ebx
  8009be:	e8 15 0d 00 00       	call   8016d8 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8009c3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ce:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8009d9:	83 c4 10             	add    $0x10,%esp
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	53                   	push   %ebx
  8009ea:	83 ec 08             	sub    $0x8,%esp
  8009ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f6:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  8009fb:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  800a01:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a07:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800a0c:	0f 46 c3             	cmovbe %ebx,%eax
  800a0f:	50                   	push   %eax
  800a10:	ff 75 0c             	pushl  0xc(%ebp)
  800a13:	68 08 50 80 00       	push   $0x805008
  800a18:	e8 4d 0e 00 00       	call   80186a <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  800a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a22:	b8 04 00 00 00       	mov    $0x4,%eax
  800a27:	e8 ca fe ff ff       	call   8008f6 <fsipc>
  800a2c:	83 c4 10             	add    $0x10,%esp
  800a2f:	85 c0                	test   %eax,%eax
  800a31:	78 3d                	js     800a70 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  800a33:	39 c3                	cmp    %eax,%ebx
  800a35:	73 19                	jae    800a50 <devfile_write+0x6a>
  800a37:	68 a4 1e 80 00       	push   $0x801ea4
  800a3c:	68 ab 1e 80 00       	push   $0x801eab
  800a41:	68 9a 00 00 00       	push   $0x9a
  800a46:	68 c0 1e 80 00       	push   $0x801ec0
  800a4b:	e8 2a 06 00 00       	call   80107a <_panic>
	   assert (r <= bytes_written);
  800a50:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a55:	7e 19                	jle    800a70 <devfile_write+0x8a>
  800a57:	68 cb 1e 80 00       	push   $0x801ecb
  800a5c:	68 ab 1e 80 00       	push   $0x801eab
  800a61:	68 9b 00 00 00       	push   $0x9b
  800a66:	68 c0 1e 80 00       	push   $0x801ec0
  800a6b:	e8 0a 06 00 00       	call   80107a <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  800a70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a73:	c9                   	leave  
  800a74:	c3                   	ret    

00800a75 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8b 40 0c             	mov    0xc(%eax),%eax
  800a83:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  800a88:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a93:	b8 03 00 00 00       	mov    $0x3,%eax
  800a98:	e8 59 fe ff ff       	call   8008f6 <fsipc>
  800a9d:	89 c3                	mov    %eax,%ebx
  800a9f:	85 c0                	test   %eax,%eax
  800aa1:	78 4b                	js     800aee <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  800aa3:	39 c6                	cmp    %eax,%esi
  800aa5:	73 16                	jae    800abd <devfile_read+0x48>
  800aa7:	68 a4 1e 80 00       	push   $0x801ea4
  800aac:	68 ab 1e 80 00       	push   $0x801eab
  800ab1:	6a 7c                	push   $0x7c
  800ab3:	68 c0 1e 80 00       	push   $0x801ec0
  800ab8:	e8 bd 05 00 00       	call   80107a <_panic>
	   assert(r <= PGSIZE);
  800abd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac2:	7e 16                	jle    800ada <devfile_read+0x65>
  800ac4:	68 de 1e 80 00       	push   $0x801ede
  800ac9:	68 ab 1e 80 00       	push   $0x801eab
  800ace:	6a 7d                	push   $0x7d
  800ad0:	68 c0 1e 80 00       	push   $0x801ec0
  800ad5:	e8 a0 05 00 00       	call   80107a <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ada:	83 ec 04             	sub    $0x4,%esp
  800add:	50                   	push   %eax
  800ade:	68 00 50 80 00       	push   $0x805000
  800ae3:	ff 75 0c             	pushl  0xc(%ebp)
  800ae6:	e8 7f 0d 00 00       	call   80186a <memmove>
	   return r;
  800aeb:	83 c4 10             	add    $0x10,%esp
}
  800aee:	89 d8                	mov    %ebx,%eax
  800af0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af3:	5b                   	pop    %ebx
  800af4:	5e                   	pop    %esi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	53                   	push   %ebx
  800afb:	83 ec 20             	sub    $0x20,%esp
  800afe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  800b01:	53                   	push   %ebx
  800b02:	e8 98 0b 00 00       	call   80169f <strlen>
  800b07:	83 c4 10             	add    $0x10,%esp
  800b0a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b0f:	7f 67                	jg     800b78 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b11:	83 ec 0c             	sub    $0xc,%esp
  800b14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b17:	50                   	push   %eax
  800b18:	e8 51 f8 ff ff       	call   80036e <fd_alloc>
  800b1d:	83 c4 10             	add    $0x10,%esp
			 return r;
  800b20:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b22:	85 c0                	test   %eax,%eax
  800b24:	78 57                	js     800b7d <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  800b26:	83 ec 08             	sub    $0x8,%esp
  800b29:	53                   	push   %ebx
  800b2a:	68 00 50 80 00       	push   $0x805000
  800b2f:	e8 a4 0b 00 00       	call   8016d8 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  800b34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b37:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b44:	e8 ad fd ff ff       	call   8008f6 <fsipc>
  800b49:	89 c3                	mov    %eax,%ebx
  800b4b:	83 c4 10             	add    $0x10,%esp
  800b4e:	85 c0                	test   %eax,%eax
  800b50:	79 14                	jns    800b66 <open+0x6f>
			 fd_close(fd, 0);
  800b52:	83 ec 08             	sub    $0x8,%esp
  800b55:	6a 00                	push   $0x0
  800b57:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5a:	e8 07 f9 ff ff       	call   800466 <fd_close>
			 return r;
  800b5f:	83 c4 10             	add    $0x10,%esp
  800b62:	89 da                	mov    %ebx,%edx
  800b64:	eb 17                	jmp    800b7d <open+0x86>
	   }

	   return fd2num(fd);
  800b66:	83 ec 0c             	sub    $0xc,%esp
  800b69:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6c:	e8 d6 f7 ff ff       	call   800347 <fd2num>
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	83 c4 10             	add    $0x10,%esp
  800b76:	eb 05                	jmp    800b7d <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  800b78:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  800b7d:	89 d0                	mov    %edx,%eax
  800b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 08 00 00 00       	mov    $0x8,%eax
  800b94:	e8 5d fd ff ff       	call   8008f6 <fsipc>
}
  800b99:	c9                   	leave  
  800b9a:	c3                   	ret    

00800b9b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	ff 75 08             	pushl  0x8(%ebp)
  800ba9:	e8 a9 f7 ff ff       	call   800357 <fd2data>
  800bae:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bb0:	83 c4 08             	add    $0x8,%esp
  800bb3:	68 ea 1e 80 00       	push   $0x801eea
  800bb8:	53                   	push   %ebx
  800bb9:	e8 1a 0b 00 00       	call   8016d8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bbe:	8b 46 04             	mov    0x4(%esi),%eax
  800bc1:	2b 06                	sub    (%esi),%eax
  800bc3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bc9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bd0:	00 00 00 
	stat->st_dev = &devpipe;
  800bd3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bda:	30 80 00 
	return 0;
}
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800be2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf3:	53                   	push   %ebx
  800bf4:	6a 00                	push   $0x0
  800bf6:	e8 e0 f5 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bfb:	89 1c 24             	mov    %ebx,(%esp)
  800bfe:	e8 54 f7 ff ff       	call   800357 <fd2data>
  800c03:	83 c4 08             	add    $0x8,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 00                	push   $0x0
  800c09:	e8 cd f5 ff ff       	call   8001db <sys_page_unmap>
}
  800c0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 1c             	sub    $0x1c,%esp
  800c1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c1f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c21:	a1 04 40 80 00       	mov    0x804004,%eax
  800c26:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	ff 75 e0             	pushl  -0x20(%ebp)
  800c2f:	e8 d7 0e 00 00       	call   801b0b <pageref>
  800c34:	89 c3                	mov    %eax,%ebx
  800c36:	89 3c 24             	mov    %edi,(%esp)
  800c39:	e8 cd 0e 00 00       	call   801b0b <pageref>
  800c3e:	83 c4 10             	add    $0x10,%esp
  800c41:	39 c3                	cmp    %eax,%ebx
  800c43:	0f 94 c1             	sete   %cl
  800c46:	0f b6 c9             	movzbl %cl,%ecx
  800c49:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c4c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c52:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c55:	39 ce                	cmp    %ecx,%esi
  800c57:	74 1b                	je     800c74 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c59:	39 c3                	cmp    %eax,%ebx
  800c5b:	75 c4                	jne    800c21 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c5d:	8b 42 58             	mov    0x58(%edx),%eax
  800c60:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c63:	50                   	push   %eax
  800c64:	56                   	push   %esi
  800c65:	68 f1 1e 80 00       	push   $0x801ef1
  800c6a:	e8 e4 04 00 00       	call   801153 <cprintf>
  800c6f:	83 c4 10             	add    $0x10,%esp
  800c72:	eb ad                	jmp    800c21 <_pipeisclosed+0xe>
	}
}
  800c74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 28             	sub    $0x28,%esp
  800c88:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c8b:	56                   	push   %esi
  800c8c:	e8 c6 f6 ff ff       	call   800357 <fd2data>
  800c91:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c93:	83 c4 10             	add    $0x10,%esp
  800c96:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9b:	eb 4b                	jmp    800ce8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c9d:	89 da                	mov    %ebx,%edx
  800c9f:	89 f0                	mov    %esi,%eax
  800ca1:	e8 6d ff ff ff       	call   800c13 <_pipeisclosed>
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	75 48                	jne    800cf2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800caa:	e8 88 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800caf:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb2:	8b 0b                	mov    (%ebx),%ecx
  800cb4:	8d 51 20             	lea    0x20(%ecx),%edx
  800cb7:	39 d0                	cmp    %edx,%eax
  800cb9:	73 e2                	jae    800c9d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cc2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cc5:	89 c2                	mov    %eax,%edx
  800cc7:	c1 fa 1f             	sar    $0x1f,%edx
  800cca:	89 d1                	mov    %edx,%ecx
  800ccc:	c1 e9 1b             	shr    $0x1b,%ecx
  800ccf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cd2:	83 e2 1f             	and    $0x1f,%edx
  800cd5:	29 ca                	sub    %ecx,%edx
  800cd7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cdb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cdf:	83 c0 01             	add    $0x1,%eax
  800ce2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce5:	83 c7 01             	add    $0x1,%edi
  800ce8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ceb:	75 c2                	jne    800caf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ced:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf0:	eb 05                	jmp    800cf7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 18             	sub    $0x18,%esp
  800d08:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d0b:	57                   	push   %edi
  800d0c:	e8 46 f6 ff ff       	call   800357 <fd2data>
  800d11:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d13:	83 c4 10             	add    $0x10,%esp
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	eb 3d                	jmp    800d5a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d1d:	85 db                	test   %ebx,%ebx
  800d1f:	74 04                	je     800d25 <devpipe_read+0x26>
				return i;
  800d21:	89 d8                	mov    %ebx,%eax
  800d23:	eb 44                	jmp    800d69 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d25:	89 f2                	mov    %esi,%edx
  800d27:	89 f8                	mov    %edi,%eax
  800d29:	e8 e5 fe ff ff       	call   800c13 <_pipeisclosed>
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	75 32                	jne    800d64 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d32:	e8 00 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d37:	8b 06                	mov    (%esi),%eax
  800d39:	3b 46 04             	cmp    0x4(%esi),%eax
  800d3c:	74 df                	je     800d1d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d3e:	99                   	cltd   
  800d3f:	c1 ea 1b             	shr    $0x1b,%edx
  800d42:	01 d0                	add    %edx,%eax
  800d44:	83 e0 1f             	and    $0x1f,%eax
  800d47:	29 d0                	sub    %edx,%eax
  800d49:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d54:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d57:	83 c3 01             	add    $0x1,%ebx
  800d5a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d5d:	75 d8                	jne    800d37 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d5f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d62:	eb 05                	jmp    800d69 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d64:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d7c:	50                   	push   %eax
  800d7d:	e8 ec f5 ff ff       	call   80036e <fd_alloc>
  800d82:	83 c4 10             	add    $0x10,%esp
  800d85:	89 c2                	mov    %eax,%edx
  800d87:	85 c0                	test   %eax,%eax
  800d89:	0f 88 2c 01 00 00    	js     800ebb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8f:	83 ec 04             	sub    $0x4,%esp
  800d92:	68 07 04 00 00       	push   $0x407
  800d97:	ff 75 f4             	pushl  -0xc(%ebp)
  800d9a:	6a 00                	push   $0x0
  800d9c:	e8 b5 f3 ff ff       	call   800156 <sys_page_alloc>
  800da1:	83 c4 10             	add    $0x10,%esp
  800da4:	89 c2                	mov    %eax,%edx
  800da6:	85 c0                	test   %eax,%eax
  800da8:	0f 88 0d 01 00 00    	js     800ebb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dae:	83 ec 0c             	sub    $0xc,%esp
  800db1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db4:	50                   	push   %eax
  800db5:	e8 b4 f5 ff ff       	call   80036e <fd_alloc>
  800dba:	89 c3                	mov    %eax,%ebx
  800dbc:	83 c4 10             	add    $0x10,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	0f 88 e2 00 00 00    	js     800ea9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc7:	83 ec 04             	sub    $0x4,%esp
  800dca:	68 07 04 00 00       	push   $0x407
  800dcf:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd2:	6a 00                	push   $0x0
  800dd4:	e8 7d f3 ff ff       	call   800156 <sys_page_alloc>
  800dd9:	89 c3                	mov    %eax,%ebx
  800ddb:	83 c4 10             	add    $0x10,%esp
  800dde:	85 c0                	test   %eax,%eax
  800de0:	0f 88 c3 00 00 00    	js     800ea9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	ff 75 f4             	pushl  -0xc(%ebp)
  800dec:	e8 66 f5 ff ff       	call   800357 <fd2data>
  800df1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df3:	83 c4 0c             	add    $0xc,%esp
  800df6:	68 07 04 00 00       	push   $0x407
  800dfb:	50                   	push   %eax
  800dfc:	6a 00                	push   $0x0
  800dfe:	e8 53 f3 ff ff       	call   800156 <sys_page_alloc>
  800e03:	89 c3                	mov    %eax,%ebx
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	0f 88 89 00 00 00    	js     800e99 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e10:	83 ec 0c             	sub    $0xc,%esp
  800e13:	ff 75 f0             	pushl  -0x10(%ebp)
  800e16:	e8 3c f5 ff ff       	call   800357 <fd2data>
  800e1b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e22:	50                   	push   %eax
  800e23:	6a 00                	push   $0x0
  800e25:	56                   	push   %esi
  800e26:	6a 00                	push   $0x0
  800e28:	e8 6c f3 ff ff       	call   800199 <sys_page_map>
  800e2d:	89 c3                	mov    %eax,%ebx
  800e2f:	83 c4 20             	add    $0x20,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	78 55                	js     800e8b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e36:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e44:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e4b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e54:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e59:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e60:	83 ec 0c             	sub    $0xc,%esp
  800e63:	ff 75 f4             	pushl  -0xc(%ebp)
  800e66:	e8 dc f4 ff ff       	call   800347 <fd2num>
  800e6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e70:	83 c4 04             	add    $0x4,%esp
  800e73:	ff 75 f0             	pushl  -0x10(%ebp)
  800e76:	e8 cc f4 ff ff       	call   800347 <fd2num>
  800e7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	ba 00 00 00 00       	mov    $0x0,%edx
  800e89:	eb 30                	jmp    800ebb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e8b:	83 ec 08             	sub    $0x8,%esp
  800e8e:	56                   	push   %esi
  800e8f:	6a 00                	push   $0x0
  800e91:	e8 45 f3 ff ff       	call   8001db <sys_page_unmap>
  800e96:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e99:	83 ec 08             	sub    $0x8,%esp
  800e9c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e9f:	6a 00                	push   $0x0
  800ea1:	e8 35 f3 ff ff       	call   8001db <sys_page_unmap>
  800ea6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ea9:	83 ec 08             	sub    $0x8,%esp
  800eac:	ff 75 f4             	pushl  -0xc(%ebp)
  800eaf:	6a 00                	push   $0x0
  800eb1:	e8 25 f3 ff ff       	call   8001db <sys_page_unmap>
  800eb6:	83 c4 10             	add    $0x10,%esp
  800eb9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ebb:	89 d0                	mov    %edx,%eax
  800ebd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ecd:	50                   	push   %eax
  800ece:	ff 75 08             	pushl  0x8(%ebp)
  800ed1:	e8 e7 f4 ff ff       	call   8003bd <fd_lookup>
  800ed6:	83 c4 10             	add    $0x10,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	78 18                	js     800ef5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800edd:	83 ec 0c             	sub    $0xc,%esp
  800ee0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee3:	e8 6f f4 ff ff       	call   800357 <fd2data>
	return _pipeisclosed(fd, p);
  800ee8:	89 c2                	mov    %eax,%edx
  800eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eed:	e8 21 fd ff ff       	call   800c13 <_pipeisclosed>
  800ef2:	83 c4 10             	add    $0x10,%esp
}
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800efa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f07:	68 09 1f 80 00       	push   $0x801f09
  800f0c:	ff 75 0c             	pushl  0xc(%ebp)
  800f0f:	e8 c4 07 00 00       	call   8016d8 <strcpy>
	return 0;
}
  800f14:	b8 00 00 00 00       	mov    $0x0,%eax
  800f19:	c9                   	leave  
  800f1a:	c3                   	ret    

00800f1b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	57                   	push   %edi
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
  800f21:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f27:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f2c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f32:	eb 2d                	jmp    800f61 <devcons_write+0x46>
		m = n - tot;
  800f34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f37:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f39:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f3c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f41:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f44:	83 ec 04             	sub    $0x4,%esp
  800f47:	53                   	push   %ebx
  800f48:	03 45 0c             	add    0xc(%ebp),%eax
  800f4b:	50                   	push   %eax
  800f4c:	57                   	push   %edi
  800f4d:	e8 18 09 00 00       	call   80186a <memmove>
		sys_cputs(buf, m);
  800f52:	83 c4 08             	add    $0x8,%esp
  800f55:	53                   	push   %ebx
  800f56:	57                   	push   %edi
  800f57:	e8 3e f1 ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f5c:	01 de                	add    %ebx,%esi
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	89 f0                	mov    %esi,%eax
  800f63:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f66:	72 cc                	jb     800f34 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6b:	5b                   	pop    %ebx
  800f6c:	5e                   	pop    %esi
  800f6d:	5f                   	pop    %edi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	83 ec 08             	sub    $0x8,%esp
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f7f:	74 2a                	je     800fab <devcons_read+0x3b>
  800f81:	eb 05                	jmp    800f88 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f83:	e8 af f1 ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f88:	e8 2b f1 ff ff       	call   8000b8 <sys_cgetc>
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	74 f2                	je     800f83 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f91:	85 c0                	test   %eax,%eax
  800f93:	78 16                	js     800fab <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f95:	83 f8 04             	cmp    $0x4,%eax
  800f98:	74 0c                	je     800fa6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9d:	88 02                	mov    %al,(%edx)
	return 1;
  800f9f:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa4:	eb 05                	jmp    800fab <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fa6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    

00800fad <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fb9:	6a 01                	push   $0x1
  800fbb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbe:	50                   	push   %eax
  800fbf:	e8 d6 f0 ff ff       	call   80009a <sys_cputs>
}
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    

00800fc9 <getchar>:

int
getchar(void)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fcf:	6a 01                	push   $0x1
  800fd1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd4:	50                   	push   %eax
  800fd5:	6a 00                	push   $0x0
  800fd7:	e8 47 f6 ff ff       	call   800623 <read>
	if (r < 0)
  800fdc:	83 c4 10             	add    $0x10,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	78 0f                	js     800ff2 <getchar+0x29>
		return r;
	if (r < 1)
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	7e 06                	jle    800fed <getchar+0x24>
		return -E_EOF;
	return c;
  800fe7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800feb:	eb 05                	jmp    800ff2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fed:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ffa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffd:	50                   	push   %eax
  800ffe:	ff 75 08             	pushl  0x8(%ebp)
  801001:	e8 b7 f3 ff ff       	call   8003bd <fd_lookup>
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 11                	js     80101e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80100d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801010:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801016:	39 10                	cmp    %edx,(%eax)
  801018:	0f 94 c0             	sete   %al
  80101b:	0f b6 c0             	movzbl %al,%eax
}
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <opencons>:

int
opencons(void)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801026:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801029:	50                   	push   %eax
  80102a:	e8 3f f3 ff ff       	call   80036e <fd_alloc>
  80102f:	83 c4 10             	add    $0x10,%esp
		return r;
  801032:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801034:	85 c0                	test   %eax,%eax
  801036:	78 3e                	js     801076 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801038:	83 ec 04             	sub    $0x4,%esp
  80103b:	68 07 04 00 00       	push   $0x407
  801040:	ff 75 f4             	pushl  -0xc(%ebp)
  801043:	6a 00                	push   $0x0
  801045:	e8 0c f1 ff ff       	call   800156 <sys_page_alloc>
  80104a:	83 c4 10             	add    $0x10,%esp
		return r;
  80104d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 23                	js     801076 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801053:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801059:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80105e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801061:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	50                   	push   %eax
  80106c:	e8 d6 f2 ff ff       	call   800347 <fd2num>
  801071:	89 c2                	mov    %eax,%edx
  801073:	83 c4 10             	add    $0x10,%esp
}
  801076:	89 d0                	mov    %edx,%eax
  801078:	c9                   	leave  
  801079:	c3                   	ret    

0080107a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80107f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801082:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801088:	e8 8b f0 ff ff       	call   800118 <sys_getenvid>
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	ff 75 0c             	pushl  0xc(%ebp)
  801093:	ff 75 08             	pushl  0x8(%ebp)
  801096:	56                   	push   %esi
  801097:	50                   	push   %eax
  801098:	68 18 1f 80 00       	push   $0x801f18
  80109d:	e8 b1 00 00 00       	call   801153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a2:	83 c4 18             	add    $0x18,%esp
  8010a5:	53                   	push   %ebx
  8010a6:	ff 75 10             	pushl  0x10(%ebp)
  8010a9:	e8 54 00 00 00       	call   801102 <vcprintf>
	cprintf("\n");
  8010ae:	c7 04 24 02 1f 80 00 	movl   $0x801f02,(%esp)
  8010b5:	e8 99 00 00 00       	call   801153 <cprintf>
  8010ba:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010bd:	cc                   	int3   
  8010be:	eb fd                	jmp    8010bd <_panic+0x43>

008010c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	53                   	push   %ebx
  8010c4:	83 ec 04             	sub    $0x4,%esp
  8010c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010ca:	8b 13                	mov    (%ebx),%edx
  8010cc:	8d 42 01             	lea    0x1(%edx),%eax
  8010cf:	89 03                	mov    %eax,(%ebx)
  8010d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010dd:	75 1a                	jne    8010f9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010df:	83 ec 08             	sub    $0x8,%esp
  8010e2:	68 ff 00 00 00       	push   $0xff
  8010e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ea:	50                   	push   %eax
  8010eb:	e8 aa ef ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8010f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801100:	c9                   	leave  
  801101:	c3                   	ret    

00801102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80110b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801112:	00 00 00 
	b.cnt = 0;
  801115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80111c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80111f:	ff 75 0c             	pushl  0xc(%ebp)
  801122:	ff 75 08             	pushl  0x8(%ebp)
  801125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80112b:	50                   	push   %eax
  80112c:	68 c0 10 80 00       	push   $0x8010c0
  801131:	e8 54 01 00 00       	call   80128a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801136:	83 c4 08             	add    $0x8,%esp
  801139:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80113f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801145:	50                   	push   %eax
  801146:	e8 4f ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  80114b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80115c:	50                   	push   %eax
  80115d:	ff 75 08             	pushl  0x8(%ebp)
  801160:	e8 9d ff ff ff       	call   801102 <vcprintf>
	va_end(ap);

	return cnt;
}
  801165:	c9                   	leave  
  801166:	c3                   	ret    

00801167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 1c             	sub    $0x1c,%esp
  801170:	89 c7                	mov    %eax,%edi
  801172:	89 d6                	mov    %edx,%esi
  801174:	8b 45 08             	mov    0x8(%ebp),%eax
  801177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80117d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801180:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801183:	bb 00 00 00 00       	mov    $0x0,%ebx
  801188:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80118b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80118e:	39 d3                	cmp    %edx,%ebx
  801190:	72 05                	jb     801197 <printnum+0x30>
  801192:	39 45 10             	cmp    %eax,0x10(%ebp)
  801195:	77 45                	ja     8011dc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	ff 75 18             	pushl  0x18(%ebp)
  80119d:	8b 45 14             	mov    0x14(%ebp),%eax
  8011a0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011a3:	53                   	push   %ebx
  8011a4:	ff 75 10             	pushl  0x10(%ebp)
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b6:	e8 95 09 00 00       	call   801b50 <__udivdi3>
  8011bb:	83 c4 18             	add    $0x18,%esp
  8011be:	52                   	push   %edx
  8011bf:	50                   	push   %eax
  8011c0:	89 f2                	mov    %esi,%edx
  8011c2:	89 f8                	mov    %edi,%eax
  8011c4:	e8 9e ff ff ff       	call   801167 <printnum>
  8011c9:	83 c4 20             	add    $0x20,%esp
  8011cc:	eb 18                	jmp    8011e6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	56                   	push   %esi
  8011d2:	ff 75 18             	pushl  0x18(%ebp)
  8011d5:	ff d7                	call   *%edi
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	eb 03                	jmp    8011df <printnum+0x78>
  8011dc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011df:	83 eb 01             	sub    $0x1,%ebx
  8011e2:	85 db                	test   %ebx,%ebx
  8011e4:	7f e8                	jg     8011ce <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e6:	83 ec 08             	sub    $0x8,%esp
  8011e9:	56                   	push   %esi
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f9:	e8 82 0a 00 00       	call   801c80 <__umoddi3>
  8011fe:	83 c4 14             	add    $0x14,%esp
  801201:	0f be 80 3b 1f 80 00 	movsbl 0x801f3b(%eax),%eax
  801208:	50                   	push   %eax
  801209:	ff d7                	call   *%edi
}
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801211:	5b                   	pop    %ebx
  801212:	5e                   	pop    %esi
  801213:	5f                   	pop    %edi
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801219:	83 fa 01             	cmp    $0x1,%edx
  80121c:	7e 0e                	jle    80122c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80121e:	8b 10                	mov    (%eax),%edx
  801220:	8d 4a 08             	lea    0x8(%edx),%ecx
  801223:	89 08                	mov    %ecx,(%eax)
  801225:	8b 02                	mov    (%edx),%eax
  801227:	8b 52 04             	mov    0x4(%edx),%edx
  80122a:	eb 22                	jmp    80124e <getuint+0x38>
	else if (lflag)
  80122c:	85 d2                	test   %edx,%edx
  80122e:	74 10                	je     801240 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801230:	8b 10                	mov    (%eax),%edx
  801232:	8d 4a 04             	lea    0x4(%edx),%ecx
  801235:	89 08                	mov    %ecx,(%eax)
  801237:	8b 02                	mov    (%edx),%eax
  801239:	ba 00 00 00 00       	mov    $0x0,%edx
  80123e:	eb 0e                	jmp    80124e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801240:	8b 10                	mov    (%eax),%edx
  801242:	8d 4a 04             	lea    0x4(%edx),%ecx
  801245:	89 08                	mov    %ecx,(%eax)
  801247:	8b 02                	mov    (%edx),%eax
  801249:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801256:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80125a:	8b 10                	mov    (%eax),%edx
  80125c:	3b 50 04             	cmp    0x4(%eax),%edx
  80125f:	73 0a                	jae    80126b <sprintputch+0x1b>
		*b->buf++ = ch;
  801261:	8d 4a 01             	lea    0x1(%edx),%ecx
  801264:	89 08                	mov    %ecx,(%eax)
  801266:	8b 45 08             	mov    0x8(%ebp),%eax
  801269:	88 02                	mov    %al,(%edx)
}
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801273:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801276:	50                   	push   %eax
  801277:	ff 75 10             	pushl  0x10(%ebp)
  80127a:	ff 75 0c             	pushl  0xc(%ebp)
  80127d:	ff 75 08             	pushl  0x8(%ebp)
  801280:	e8 05 00 00 00       	call   80128a <vprintfmt>
	va_end(ap);
}
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	57                   	push   %edi
  80128e:	56                   	push   %esi
  80128f:	53                   	push   %ebx
  801290:	83 ec 2c             	sub    $0x2c,%esp
  801293:	8b 75 08             	mov    0x8(%ebp),%esi
  801296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801299:	8b 7d 10             	mov    0x10(%ebp),%edi
  80129c:	eb 12                	jmp    8012b0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	0f 84 89 03 00 00    	je     80162f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012a6:	83 ec 08             	sub    $0x8,%esp
  8012a9:	53                   	push   %ebx
  8012aa:	50                   	push   %eax
  8012ab:	ff d6                	call   *%esi
  8012ad:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012b0:	83 c7 01             	add    $0x1,%edi
  8012b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012b7:	83 f8 25             	cmp    $0x25,%eax
  8012ba:	75 e2                	jne    80129e <vprintfmt+0x14>
  8012bc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012c7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012da:	eb 07                	jmp    8012e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e3:	8d 47 01             	lea    0x1(%edi),%eax
  8012e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e9:	0f b6 07             	movzbl (%edi),%eax
  8012ec:	0f b6 c8             	movzbl %al,%ecx
  8012ef:	83 e8 23             	sub    $0x23,%eax
  8012f2:	3c 55                	cmp    $0x55,%al
  8012f4:	0f 87 1a 03 00 00    	ja     801614 <vprintfmt+0x38a>
  8012fa:	0f b6 c0             	movzbl %al,%eax
  8012fd:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  801304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801307:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80130b:	eb d6                	jmp    8012e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801310:	b8 00 00 00 00       	mov    $0x0,%eax
  801315:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801318:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80131b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80131f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801322:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801325:	83 fa 09             	cmp    $0x9,%edx
  801328:	77 39                	ja     801363 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80132a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80132d:	eb e9                	jmp    801318 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80132f:	8b 45 14             	mov    0x14(%ebp),%eax
  801332:	8d 48 04             	lea    0x4(%eax),%ecx
  801335:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801338:	8b 00                	mov    (%eax),%eax
  80133a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801340:	eb 27                	jmp    801369 <vprintfmt+0xdf>
  801342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801345:	85 c0                	test   %eax,%eax
  801347:	b9 00 00 00 00       	mov    $0x0,%ecx
  80134c:	0f 49 c8             	cmovns %eax,%ecx
  80134f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801355:	eb 8c                	jmp    8012e3 <vprintfmt+0x59>
  801357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80135a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801361:	eb 80                	jmp    8012e3 <vprintfmt+0x59>
  801363:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801366:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801369:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80136d:	0f 89 70 ff ff ff    	jns    8012e3 <vprintfmt+0x59>
				width = precision, precision = -1;
  801373:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801376:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801379:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801380:	e9 5e ff ff ff       	jmp    8012e3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801385:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80138b:	e9 53 ff ff ff       	jmp    8012e3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801390:	8b 45 14             	mov    0x14(%ebp),%eax
  801393:	8d 50 04             	lea    0x4(%eax),%edx
  801396:	89 55 14             	mov    %edx,0x14(%ebp)
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	53                   	push   %ebx
  80139d:	ff 30                	pushl  (%eax)
  80139f:	ff d6                	call   *%esi
			break;
  8013a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013a7:	e9 04 ff ff ff       	jmp    8012b0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8013af:	8d 50 04             	lea    0x4(%eax),%edx
  8013b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b5:	8b 00                	mov    (%eax),%eax
  8013b7:	99                   	cltd   
  8013b8:	31 d0                	xor    %edx,%eax
  8013ba:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013bc:	83 f8 0f             	cmp    $0xf,%eax
  8013bf:	7f 0b                	jg     8013cc <vprintfmt+0x142>
  8013c1:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013c8:	85 d2                	test   %edx,%edx
  8013ca:	75 18                	jne    8013e4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013cc:	50                   	push   %eax
  8013cd:	68 53 1f 80 00       	push   $0x801f53
  8013d2:	53                   	push   %ebx
  8013d3:	56                   	push   %esi
  8013d4:	e8 94 fe ff ff       	call   80126d <printfmt>
  8013d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013df:	e9 cc fe ff ff       	jmp    8012b0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013e4:	52                   	push   %edx
  8013e5:	68 bd 1e 80 00       	push   $0x801ebd
  8013ea:	53                   	push   %ebx
  8013eb:	56                   	push   %esi
  8013ec:	e8 7c fe ff ff       	call   80126d <printfmt>
  8013f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013f7:	e9 b4 fe ff ff       	jmp    8012b0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ff:	8d 50 04             	lea    0x4(%eax),%edx
  801402:	89 55 14             	mov    %edx,0x14(%ebp)
  801405:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801407:	85 ff                	test   %edi,%edi
  801409:	b8 4c 1f 80 00       	mov    $0x801f4c,%eax
  80140e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801411:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801415:	0f 8e 94 00 00 00    	jle    8014af <vprintfmt+0x225>
  80141b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80141f:	0f 84 98 00 00 00    	je     8014bd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	ff 75 d0             	pushl  -0x30(%ebp)
  80142b:	57                   	push   %edi
  80142c:	e8 86 02 00 00       	call   8016b7 <strnlen>
  801431:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801434:	29 c1                	sub    %eax,%ecx
  801436:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801439:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80143c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801440:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801443:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801446:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801448:	eb 0f                	jmp    801459 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	53                   	push   %ebx
  80144e:	ff 75 e0             	pushl  -0x20(%ebp)
  801451:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801453:	83 ef 01             	sub    $0x1,%edi
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	85 ff                	test   %edi,%edi
  80145b:	7f ed                	jg     80144a <vprintfmt+0x1c0>
  80145d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801460:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801463:	85 c9                	test   %ecx,%ecx
  801465:	b8 00 00 00 00       	mov    $0x0,%eax
  80146a:	0f 49 c1             	cmovns %ecx,%eax
  80146d:	29 c1                	sub    %eax,%ecx
  80146f:	89 75 08             	mov    %esi,0x8(%ebp)
  801472:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801475:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801478:	89 cb                	mov    %ecx,%ebx
  80147a:	eb 4d                	jmp    8014c9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80147c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801480:	74 1b                	je     80149d <vprintfmt+0x213>
  801482:	0f be c0             	movsbl %al,%eax
  801485:	83 e8 20             	sub    $0x20,%eax
  801488:	83 f8 5e             	cmp    $0x5e,%eax
  80148b:	76 10                	jbe    80149d <vprintfmt+0x213>
					putch('?', putdat);
  80148d:	83 ec 08             	sub    $0x8,%esp
  801490:	ff 75 0c             	pushl  0xc(%ebp)
  801493:	6a 3f                	push   $0x3f
  801495:	ff 55 08             	call   *0x8(%ebp)
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	eb 0d                	jmp    8014aa <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	ff 75 0c             	pushl  0xc(%ebp)
  8014a3:	52                   	push   %edx
  8014a4:	ff 55 08             	call   *0x8(%ebp)
  8014a7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014aa:	83 eb 01             	sub    $0x1,%ebx
  8014ad:	eb 1a                	jmp    8014c9 <vprintfmt+0x23f>
  8014af:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014bb:	eb 0c                	jmp    8014c9 <vprintfmt+0x23f>
  8014bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8014c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014c9:	83 c7 01             	add    $0x1,%edi
  8014cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014d0:	0f be d0             	movsbl %al,%edx
  8014d3:	85 d2                	test   %edx,%edx
  8014d5:	74 23                	je     8014fa <vprintfmt+0x270>
  8014d7:	85 f6                	test   %esi,%esi
  8014d9:	78 a1                	js     80147c <vprintfmt+0x1f2>
  8014db:	83 ee 01             	sub    $0x1,%esi
  8014de:	79 9c                	jns    80147c <vprintfmt+0x1f2>
  8014e0:	89 df                	mov    %ebx,%edi
  8014e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e8:	eb 18                	jmp    801502 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014ea:	83 ec 08             	sub    $0x8,%esp
  8014ed:	53                   	push   %ebx
  8014ee:	6a 20                	push   $0x20
  8014f0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014f2:	83 ef 01             	sub    $0x1,%edi
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	eb 08                	jmp    801502 <vprintfmt+0x278>
  8014fa:	89 df                	mov    %ebx,%edi
  8014fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801502:	85 ff                	test   %edi,%edi
  801504:	7f e4                	jg     8014ea <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801509:	e9 a2 fd ff ff       	jmp    8012b0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80150e:	83 fa 01             	cmp    $0x1,%edx
  801511:	7e 16                	jle    801529 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801513:	8b 45 14             	mov    0x14(%ebp),%eax
  801516:	8d 50 08             	lea    0x8(%eax),%edx
  801519:	89 55 14             	mov    %edx,0x14(%ebp)
  80151c:	8b 50 04             	mov    0x4(%eax),%edx
  80151f:	8b 00                	mov    (%eax),%eax
  801521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801524:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801527:	eb 32                	jmp    80155b <vprintfmt+0x2d1>
	else if (lflag)
  801529:	85 d2                	test   %edx,%edx
  80152b:	74 18                	je     801545 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80152d:	8b 45 14             	mov    0x14(%ebp),%eax
  801530:	8d 50 04             	lea    0x4(%eax),%edx
  801533:	89 55 14             	mov    %edx,0x14(%ebp)
  801536:	8b 00                	mov    (%eax),%eax
  801538:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153b:	89 c1                	mov    %eax,%ecx
  80153d:	c1 f9 1f             	sar    $0x1f,%ecx
  801540:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801543:	eb 16                	jmp    80155b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801545:	8b 45 14             	mov    0x14(%ebp),%eax
  801548:	8d 50 04             	lea    0x4(%eax),%edx
  80154b:	89 55 14             	mov    %edx,0x14(%ebp)
  80154e:	8b 00                	mov    (%eax),%eax
  801550:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801553:	89 c1                	mov    %eax,%ecx
  801555:	c1 f9 1f             	sar    $0x1f,%ecx
  801558:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80155b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80155e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801561:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801566:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80156a:	79 74                	jns    8015e0 <vprintfmt+0x356>
				putch('-', putdat);
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	53                   	push   %ebx
  801570:	6a 2d                	push   $0x2d
  801572:	ff d6                	call   *%esi
				num = -(long long) num;
  801574:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801577:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80157a:	f7 d8                	neg    %eax
  80157c:	83 d2 00             	adc    $0x0,%edx
  80157f:	f7 da                	neg    %edx
  801581:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801584:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801589:	eb 55                	jmp    8015e0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80158b:	8d 45 14             	lea    0x14(%ebp),%eax
  80158e:	e8 83 fc ff ff       	call   801216 <getuint>
			base = 10;
  801593:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801598:	eb 46                	jmp    8015e0 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80159a:	8d 45 14             	lea    0x14(%ebp),%eax
  80159d:	e8 74 fc ff ff       	call   801216 <getuint>
			base = 8;
  8015a2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015a7:	eb 37                	jmp    8015e0 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	6a 30                	push   $0x30
  8015af:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b1:	83 c4 08             	add    $0x8,%esp
  8015b4:	53                   	push   %ebx
  8015b5:	6a 78                	push   $0x78
  8015b7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bc:	8d 50 04             	lea    0x4(%eax),%edx
  8015bf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015c2:	8b 00                	mov    (%eax),%eax
  8015c4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015cc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015d1:	eb 0d                	jmp    8015e0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8015d6:	e8 3b fc ff ff       	call   801216 <getuint>
			base = 16;
  8015db:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015e7:	57                   	push   %edi
  8015e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015eb:	51                   	push   %ecx
  8015ec:	52                   	push   %edx
  8015ed:	50                   	push   %eax
  8015ee:	89 da                	mov    %ebx,%edx
  8015f0:	89 f0                	mov    %esi,%eax
  8015f2:	e8 70 fb ff ff       	call   801167 <printnum>
			break;
  8015f7:	83 c4 20             	add    $0x20,%esp
  8015fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015fd:	e9 ae fc ff ff       	jmp    8012b0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	53                   	push   %ebx
  801606:	51                   	push   %ecx
  801607:	ff d6                	call   *%esi
			break;
  801609:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80160f:	e9 9c fc ff ff       	jmp    8012b0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	53                   	push   %ebx
  801618:	6a 25                	push   $0x25
  80161a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	eb 03                	jmp    801624 <vprintfmt+0x39a>
  801621:	83 ef 01             	sub    $0x1,%edi
  801624:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801628:	75 f7                	jne    801621 <vprintfmt+0x397>
  80162a:	e9 81 fc ff ff       	jmp    8012b0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80162f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801632:	5b                   	pop    %ebx
  801633:	5e                   	pop    %esi
  801634:	5f                   	pop    %edi
  801635:	5d                   	pop    %ebp
  801636:	c3                   	ret    

00801637 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	83 ec 18             	sub    $0x18,%esp
  80163d:	8b 45 08             	mov    0x8(%ebp),%eax
  801640:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801643:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801646:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80164a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80164d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801654:	85 c0                	test   %eax,%eax
  801656:	74 26                	je     80167e <vsnprintf+0x47>
  801658:	85 d2                	test   %edx,%edx
  80165a:	7e 22                	jle    80167e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80165c:	ff 75 14             	pushl  0x14(%ebp)
  80165f:	ff 75 10             	pushl  0x10(%ebp)
  801662:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	68 50 12 80 00       	push   $0x801250
  80166b:	e8 1a fc ff ff       	call   80128a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801670:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801673:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801676:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	eb 05                	jmp    801683 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80167e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80168b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80168e:	50                   	push   %eax
  80168f:	ff 75 10             	pushl  0x10(%ebp)
  801692:	ff 75 0c             	pushl  0xc(%ebp)
  801695:	ff 75 08             	pushl  0x8(%ebp)
  801698:	e8 9a ff ff ff       	call   801637 <vsnprintf>
	va_end(ap);

	return rc;
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016aa:	eb 03                	jmp    8016af <strlen+0x10>
		n++;
  8016ac:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016af:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016b3:	75 f7                	jne    8016ac <strlen+0xd>
		n++;
	return n;
}
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    

008016b7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c5:	eb 03                	jmp    8016ca <strnlen+0x13>
		n++;
  8016c7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ca:	39 c2                	cmp    %eax,%edx
  8016cc:	74 08                	je     8016d6 <strnlen+0x1f>
  8016ce:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016d2:	75 f3                	jne    8016c7 <strnlen+0x10>
  8016d4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	53                   	push   %ebx
  8016dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e2:	89 c2                	mov    %eax,%edx
  8016e4:	83 c2 01             	add    $0x1,%edx
  8016e7:	83 c1 01             	add    $0x1,%ecx
  8016ea:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016ee:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016f1:	84 db                	test   %bl,%bl
  8016f3:	75 ef                	jne    8016e4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016f5:	5b                   	pop    %ebx
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    

008016f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	53                   	push   %ebx
  8016fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016ff:	53                   	push   %ebx
  801700:	e8 9a ff ff ff       	call   80169f <strlen>
  801705:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801708:	ff 75 0c             	pushl  0xc(%ebp)
  80170b:	01 d8                	add    %ebx,%eax
  80170d:	50                   	push   %eax
  80170e:	e8 c5 ff ff ff       	call   8016d8 <strcpy>
	return dst;
}
  801713:	89 d8                	mov    %ebx,%eax
  801715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
  80171f:	8b 75 08             	mov    0x8(%ebp),%esi
  801722:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801725:	89 f3                	mov    %esi,%ebx
  801727:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80172a:	89 f2                	mov    %esi,%edx
  80172c:	eb 0f                	jmp    80173d <strncpy+0x23>
		*dst++ = *src;
  80172e:	83 c2 01             	add    $0x1,%edx
  801731:	0f b6 01             	movzbl (%ecx),%eax
  801734:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801737:	80 39 01             	cmpb   $0x1,(%ecx)
  80173a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173d:	39 da                	cmp    %ebx,%edx
  80173f:	75 ed                	jne    80172e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801741:	89 f0                	mov    %esi,%eax
  801743:	5b                   	pop    %ebx
  801744:	5e                   	pop    %esi
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	56                   	push   %esi
  80174b:	53                   	push   %ebx
  80174c:	8b 75 08             	mov    0x8(%ebp),%esi
  80174f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801752:	8b 55 10             	mov    0x10(%ebp),%edx
  801755:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801757:	85 d2                	test   %edx,%edx
  801759:	74 21                	je     80177c <strlcpy+0x35>
  80175b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80175f:	89 f2                	mov    %esi,%edx
  801761:	eb 09                	jmp    80176c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801763:	83 c2 01             	add    $0x1,%edx
  801766:	83 c1 01             	add    $0x1,%ecx
  801769:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80176c:	39 c2                	cmp    %eax,%edx
  80176e:	74 09                	je     801779 <strlcpy+0x32>
  801770:	0f b6 19             	movzbl (%ecx),%ebx
  801773:	84 db                	test   %bl,%bl
  801775:	75 ec                	jne    801763 <strlcpy+0x1c>
  801777:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801779:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80177c:	29 f0                	sub    %esi,%eax
}
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801788:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80178b:	eb 06                	jmp    801793 <strcmp+0x11>
		p++, q++;
  80178d:	83 c1 01             	add    $0x1,%ecx
  801790:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801793:	0f b6 01             	movzbl (%ecx),%eax
  801796:	84 c0                	test   %al,%al
  801798:	74 04                	je     80179e <strcmp+0x1c>
  80179a:	3a 02                	cmp    (%edx),%al
  80179c:	74 ef                	je     80178d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80179e:	0f b6 c0             	movzbl %al,%eax
  8017a1:	0f b6 12             	movzbl (%edx),%edx
  8017a4:	29 d0                	sub    %edx,%eax
}
  8017a6:	5d                   	pop    %ebp
  8017a7:	c3                   	ret    

008017a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	53                   	push   %ebx
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b2:	89 c3                	mov    %eax,%ebx
  8017b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017b7:	eb 06                	jmp    8017bf <strncmp+0x17>
		n--, p++, q++;
  8017b9:	83 c0 01             	add    $0x1,%eax
  8017bc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017bf:	39 d8                	cmp    %ebx,%eax
  8017c1:	74 15                	je     8017d8 <strncmp+0x30>
  8017c3:	0f b6 08             	movzbl (%eax),%ecx
  8017c6:	84 c9                	test   %cl,%cl
  8017c8:	74 04                	je     8017ce <strncmp+0x26>
  8017ca:	3a 0a                	cmp    (%edx),%cl
  8017cc:	74 eb                	je     8017b9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ce:	0f b6 00             	movzbl (%eax),%eax
  8017d1:	0f b6 12             	movzbl (%edx),%edx
  8017d4:	29 d0                	sub    %edx,%eax
  8017d6:	eb 05                	jmp    8017dd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017d8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017dd:	5b                   	pop    %ebx
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    

008017e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ea:	eb 07                	jmp    8017f3 <strchr+0x13>
		if (*s == c)
  8017ec:	38 ca                	cmp    %cl,%dl
  8017ee:	74 0f                	je     8017ff <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017f0:	83 c0 01             	add    $0x1,%eax
  8017f3:	0f b6 10             	movzbl (%eax),%edx
  8017f6:	84 d2                	test   %dl,%dl
  8017f8:	75 f2                	jne    8017ec <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	8b 45 08             	mov    0x8(%ebp),%eax
  801807:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180b:	eb 03                	jmp    801810 <strfind+0xf>
  80180d:	83 c0 01             	add    $0x1,%eax
  801810:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801813:	38 ca                	cmp    %cl,%dl
  801815:	74 04                	je     80181b <strfind+0x1a>
  801817:	84 d2                	test   %dl,%dl
  801819:	75 f2                	jne    80180d <strfind+0xc>
			break;
	return (char *) s;
}
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	57                   	push   %edi
  801821:	56                   	push   %esi
  801822:	53                   	push   %ebx
  801823:	8b 7d 08             	mov    0x8(%ebp),%edi
  801826:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801829:	85 c9                	test   %ecx,%ecx
  80182b:	74 36                	je     801863 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80182d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801833:	75 28                	jne    80185d <memset+0x40>
  801835:	f6 c1 03             	test   $0x3,%cl
  801838:	75 23                	jne    80185d <memset+0x40>
		c &= 0xFF;
  80183a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80183e:	89 d3                	mov    %edx,%ebx
  801840:	c1 e3 08             	shl    $0x8,%ebx
  801843:	89 d6                	mov    %edx,%esi
  801845:	c1 e6 18             	shl    $0x18,%esi
  801848:	89 d0                	mov    %edx,%eax
  80184a:	c1 e0 10             	shl    $0x10,%eax
  80184d:	09 f0                	or     %esi,%eax
  80184f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801851:	89 d8                	mov    %ebx,%eax
  801853:	09 d0                	or     %edx,%eax
  801855:	c1 e9 02             	shr    $0x2,%ecx
  801858:	fc                   	cld    
  801859:	f3 ab                	rep stos %eax,%es:(%edi)
  80185b:	eb 06                	jmp    801863 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801860:	fc                   	cld    
  801861:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801863:	89 f8                	mov    %edi,%eax
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5f                   	pop    %edi
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    

0080186a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	57                   	push   %edi
  80186e:	56                   	push   %esi
  80186f:	8b 45 08             	mov    0x8(%ebp),%eax
  801872:	8b 75 0c             	mov    0xc(%ebp),%esi
  801875:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801878:	39 c6                	cmp    %eax,%esi
  80187a:	73 35                	jae    8018b1 <memmove+0x47>
  80187c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80187f:	39 d0                	cmp    %edx,%eax
  801881:	73 2e                	jae    8018b1 <memmove+0x47>
		s += n;
		d += n;
  801883:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801886:	89 d6                	mov    %edx,%esi
  801888:	09 fe                	or     %edi,%esi
  80188a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801890:	75 13                	jne    8018a5 <memmove+0x3b>
  801892:	f6 c1 03             	test   $0x3,%cl
  801895:	75 0e                	jne    8018a5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801897:	83 ef 04             	sub    $0x4,%edi
  80189a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80189d:	c1 e9 02             	shr    $0x2,%ecx
  8018a0:	fd                   	std    
  8018a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a3:	eb 09                	jmp    8018ae <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018a5:	83 ef 01             	sub    $0x1,%edi
  8018a8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018ab:	fd                   	std    
  8018ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ae:	fc                   	cld    
  8018af:	eb 1d                	jmp    8018ce <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b1:	89 f2                	mov    %esi,%edx
  8018b3:	09 c2                	or     %eax,%edx
  8018b5:	f6 c2 03             	test   $0x3,%dl
  8018b8:	75 0f                	jne    8018c9 <memmove+0x5f>
  8018ba:	f6 c1 03             	test   $0x3,%cl
  8018bd:	75 0a                	jne    8018c9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018bf:	c1 e9 02             	shr    $0x2,%ecx
  8018c2:	89 c7                	mov    %eax,%edi
  8018c4:	fc                   	cld    
  8018c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c7:	eb 05                	jmp    8018ce <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018c9:	89 c7                	mov    %eax,%edi
  8018cb:	fc                   	cld    
  8018cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ce:	5e                   	pop    %esi
  8018cf:	5f                   	pop    %edi
  8018d0:	5d                   	pop    %ebp
  8018d1:	c3                   	ret    

008018d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d5:	ff 75 10             	pushl  0x10(%ebp)
  8018d8:	ff 75 0c             	pushl  0xc(%ebp)
  8018db:	ff 75 08             	pushl  0x8(%ebp)
  8018de:	e8 87 ff ff ff       	call   80186a <memmove>
}
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	56                   	push   %esi
  8018e9:	53                   	push   %ebx
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f0:	89 c6                	mov    %eax,%esi
  8018f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f5:	eb 1a                	jmp    801911 <memcmp+0x2c>
		if (*s1 != *s2)
  8018f7:	0f b6 08             	movzbl (%eax),%ecx
  8018fa:	0f b6 1a             	movzbl (%edx),%ebx
  8018fd:	38 d9                	cmp    %bl,%cl
  8018ff:	74 0a                	je     80190b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801901:	0f b6 c1             	movzbl %cl,%eax
  801904:	0f b6 db             	movzbl %bl,%ebx
  801907:	29 d8                	sub    %ebx,%eax
  801909:	eb 0f                	jmp    80191a <memcmp+0x35>
		s1++, s2++;
  80190b:	83 c0 01             	add    $0x1,%eax
  80190e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801911:	39 f0                	cmp    %esi,%eax
  801913:	75 e2                	jne    8018f7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191a:	5b                   	pop    %ebx
  80191b:	5e                   	pop    %esi
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	53                   	push   %ebx
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801925:	89 c1                	mov    %eax,%ecx
  801927:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80192a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80192e:	eb 0a                	jmp    80193a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801930:	0f b6 10             	movzbl (%eax),%edx
  801933:	39 da                	cmp    %ebx,%edx
  801935:	74 07                	je     80193e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801937:	83 c0 01             	add    $0x1,%eax
  80193a:	39 c8                	cmp    %ecx,%eax
  80193c:	72 f2                	jb     801930 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80193e:	5b                   	pop    %ebx
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	57                   	push   %edi
  801945:	56                   	push   %esi
  801946:	53                   	push   %ebx
  801947:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80194d:	eb 03                	jmp    801952 <strtol+0x11>
		s++;
  80194f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801952:	0f b6 01             	movzbl (%ecx),%eax
  801955:	3c 20                	cmp    $0x20,%al
  801957:	74 f6                	je     80194f <strtol+0xe>
  801959:	3c 09                	cmp    $0x9,%al
  80195b:	74 f2                	je     80194f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80195d:	3c 2b                	cmp    $0x2b,%al
  80195f:	75 0a                	jne    80196b <strtol+0x2a>
		s++;
  801961:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801964:	bf 00 00 00 00       	mov    $0x0,%edi
  801969:	eb 11                	jmp    80197c <strtol+0x3b>
  80196b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801970:	3c 2d                	cmp    $0x2d,%al
  801972:	75 08                	jne    80197c <strtol+0x3b>
		s++, neg = 1;
  801974:	83 c1 01             	add    $0x1,%ecx
  801977:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801982:	75 15                	jne    801999 <strtol+0x58>
  801984:	80 39 30             	cmpb   $0x30,(%ecx)
  801987:	75 10                	jne    801999 <strtol+0x58>
  801989:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80198d:	75 7c                	jne    801a0b <strtol+0xca>
		s += 2, base = 16;
  80198f:	83 c1 02             	add    $0x2,%ecx
  801992:	bb 10 00 00 00       	mov    $0x10,%ebx
  801997:	eb 16                	jmp    8019af <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801999:	85 db                	test   %ebx,%ebx
  80199b:	75 12                	jne    8019af <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80199d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a2:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a5:	75 08                	jne    8019af <strtol+0x6e>
		s++, base = 8;
  8019a7:	83 c1 01             	add    $0x1,%ecx
  8019aa:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019af:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019b7:	0f b6 11             	movzbl (%ecx),%edx
  8019ba:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019bd:	89 f3                	mov    %esi,%ebx
  8019bf:	80 fb 09             	cmp    $0x9,%bl
  8019c2:	77 08                	ja     8019cc <strtol+0x8b>
			dig = *s - '0';
  8019c4:	0f be d2             	movsbl %dl,%edx
  8019c7:	83 ea 30             	sub    $0x30,%edx
  8019ca:	eb 22                	jmp    8019ee <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019cc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019cf:	89 f3                	mov    %esi,%ebx
  8019d1:	80 fb 19             	cmp    $0x19,%bl
  8019d4:	77 08                	ja     8019de <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019d6:	0f be d2             	movsbl %dl,%edx
  8019d9:	83 ea 57             	sub    $0x57,%edx
  8019dc:	eb 10                	jmp    8019ee <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019de:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019e1:	89 f3                	mov    %esi,%ebx
  8019e3:	80 fb 19             	cmp    $0x19,%bl
  8019e6:	77 16                	ja     8019fe <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019e8:	0f be d2             	movsbl %dl,%edx
  8019eb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019ee:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f1:	7d 0b                	jge    8019fe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019f3:	83 c1 01             	add    $0x1,%ecx
  8019f6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019fa:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019fc:	eb b9                	jmp    8019b7 <strtol+0x76>

	if (endptr)
  8019fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a02:	74 0d                	je     801a11 <strtol+0xd0>
		*endptr = (char *) s;
  801a04:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a07:	89 0e                	mov    %ecx,(%esi)
  801a09:	eb 06                	jmp    801a11 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a0b:	85 db                	test   %ebx,%ebx
  801a0d:	74 98                	je     8019a7 <strtol+0x66>
  801a0f:	eb 9e                	jmp    8019af <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a11:	89 c2                	mov    %eax,%edx
  801a13:	f7 da                	neg    %edx
  801a15:	85 ff                	test   %edi,%edi
  801a17:	0f 45 c2             	cmovne %edx,%eax
}
  801a1a:	5b                   	pop    %ebx
  801a1b:	5e                   	pop    %esi
  801a1c:	5f                   	pop    %edi
  801a1d:	5d                   	pop    %ebp
  801a1e:	c3                   	ret    

00801a1f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	56                   	push   %esi
  801a23:	53                   	push   %ebx
  801a24:	8b 75 08             	mov    0x8(%ebp),%esi
  801a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801a2d:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801a2f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a34:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	50                   	push   %eax
  801a3b:	e8 c6 e8 ff ff       	call   800306 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	85 c0                	test   %eax,%eax
  801a45:	78 0e                	js     801a55 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801a47:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a4d:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801a50:	8b 52 78             	mov    0x78(%edx),%edx
  801a53:	eb 0a                	jmp    801a5f <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801a55:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801a5a:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801a5f:	85 f6                	test   %esi,%esi
  801a61:	74 02                	je     801a65 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801a63:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801a65:	85 db                	test   %ebx,%ebx
  801a67:	74 02                	je     801a6b <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801a69:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	78 08                	js     801a77 <ipc_recv+0x58>
  801a6f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a74:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801a77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5e                   	pop    %esi
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	57                   	push   %edi
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	83 ec 0c             	sub    $0xc,%esp
  801a87:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801a90:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801a92:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801a97:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801a9a:	ff 75 14             	pushl  0x14(%ebp)
  801a9d:	53                   	push   %ebx
  801a9e:	56                   	push   %esi
  801a9f:	57                   	push   %edi
  801aa0:	e8 3e e8 ff ff       	call   8002e3 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aab:	75 07                	jne    801ab4 <ipc_send+0x36>
				    sys_yield();
  801aad:	e8 85 e6 ff ff       	call   800137 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801ab2:	eb e6                	jmp    801a9a <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	74 12                	je     801aca <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801ab8:	50                   	push   %eax
  801ab9:	68 40 22 80 00       	push   $0x802240
  801abe:	6a 4b                	push   $0x4b
  801ac0:	68 54 22 80 00       	push   $0x802254
  801ac5:	e8 b0 f5 ff ff       	call   80107a <_panic>
			 }
	   }
}
  801aca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acd:	5b                   	pop    %ebx
  801ace:	5e                   	pop    %esi
  801acf:	5f                   	pop    %edi
  801ad0:	5d                   	pop    %ebp
  801ad1:	c3                   	ret    

00801ad2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801ad8:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801add:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ae0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ae6:	8b 52 50             	mov    0x50(%edx),%edx
  801ae9:	39 ca                	cmp    %ecx,%edx
  801aeb:	75 0d                	jne    801afa <ipc_find_env+0x28>
				    return envs[i].env_id;
  801aed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801af0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af5:	8b 40 48             	mov    0x48(%eax),%eax
  801af8:	eb 0f                	jmp    801b09 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801afa:	83 c0 01             	add    $0x1,%eax
  801afd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b02:	75 d9                	jne    801add <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801b04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b11:	89 d0                	mov    %edx,%eax
  801b13:	c1 e8 16             	shr    $0x16,%eax
  801b16:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b1d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b22:	f6 c1 01             	test   $0x1,%cl
  801b25:	74 1d                	je     801b44 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b27:	c1 ea 0c             	shr    $0xc,%edx
  801b2a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b31:	f6 c2 01             	test   $0x1,%dl
  801b34:	74 0e                	je     801b44 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b36:	c1 ea 0c             	shr    $0xc,%edx
  801b39:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b40:	ef 
  801b41:	0f b7 c0             	movzwl %ax,%eax
}
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    
  801b46:	66 90                	xchg   %ax,%ax
  801b48:	66 90                	xchg   %ax,%ax
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
