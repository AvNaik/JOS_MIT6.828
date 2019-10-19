
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 87 04 00 00       	call   80051f <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 0a 1e 80 00       	push   $0x801e0a
  800111:	6a 23                	push   $0x23
  800113:	68 27 1e 80 00       	push   $0x801e27
  800118:	e8 6a 0f 00 00       	call   801087 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 0a 1e 80 00       	push   $0x801e0a
  800192:	6a 23                	push   $0x23
  800194:	68 27 1e 80 00       	push   $0x801e27
  800199:	e8 e9 0e 00 00       	call   801087 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 0a 1e 80 00       	push   $0x801e0a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 27 1e 80 00       	push   $0x801e27
  8001db:	e8 a7 0e 00 00       	call   801087 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 0a 1e 80 00       	push   $0x801e0a
  800216:	6a 23                	push   $0x23
  800218:	68 27 1e 80 00       	push   $0x801e27
  80021d:	e8 65 0e 00 00       	call   801087 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 0a 1e 80 00       	push   $0x801e0a
  800258:	6a 23                	push   $0x23
  80025a:	68 27 1e 80 00       	push   $0x801e27
  80025f:	e8 23 0e 00 00       	call   801087 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 0a 1e 80 00       	push   $0x801e0a
  80029a:	6a 23                	push   $0x23
  80029c:	68 27 1e 80 00       	push   $0x801e27
  8002a1:	e8 e1 0d 00 00       	call   801087 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 0a 1e 80 00       	push   $0x801e0a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 27 1e 80 00       	push   $0x801e27
  8002e3:	e8 9f 0d 00 00       	call   801087 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 0a 1e 80 00       	push   $0x801e0a
  800340:	6a 23                	push   $0x23
  800342:	68 27 1e 80 00       	push   $0x801e27
  800347:	e8 3b 0d 00 00       	call   801087 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 11                	je     8003a8 <fd_alloc+0x2d>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	75 09                	jne    8003b1 <fd_alloc+0x36>
			*fd_store = fd;
  8003a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	eb 17                	jmp    8003c8 <fd_alloc+0x4d>
  8003b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003bb:	75 c9                	jne    800386 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	eb 13                	jmp    80041e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb 0c                	jmp    80041e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 05                	jmp    80041e <fd_lookup+0x54>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	eb 13                	jmp    800443 <dev_lookup+0x23>
  800430:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	75 0c                	jne    800443 <dev_lookup+0x23>
			*dev = devtab[i];
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	eb 2e                	jmp    800471 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	75 e7                	jne    800430 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800449:	a1 04 40 80 00       	mov    0x804004,%eax
  80044e:	8b 40 48             	mov    0x48(%eax),%eax
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	51                   	push   %ecx
  800455:	50                   	push   %eax
  800456:	68 38 1e 80 00       	push   $0x801e38
  80045b:	e8 00 0d 00 00       	call   801160 <cprintf>
	*dev = 0;
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 10             	sub    $0x10,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800484:	50                   	push   %eax
  800485:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
  80048e:	50                   	push   %eax
  80048f:	e8 36 ff ff ff       	call   8003ca <fd_lookup>
  800494:	83 c4 08             	add    $0x8,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	78 05                	js     8004a0 <fd_close+0x2d>
	    || fd != fd2)
  80049b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049e:	74 0c                	je     8004ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a0:	84 db                	test   %bl,%bl
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	0f 44 c2             	cmove  %edx,%eax
  8004aa:	eb 41                	jmp    8004ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff 36                	pushl  (%esi)
  8004b5:	e8 66 ff ff ff       	call   800420 <dev_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 1a                	js     8004dd <fd_close+0x6a>
		if (dev->dev_close)
  8004c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0b                	je     8004dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	6a 00                	push   $0x0
  8004e3:	e8 00 fd ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	89 d8                	mov    %ebx,%eax
}
  8004ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 c4 fe ff ff       	call   8003ca <fd_lookup>
  800506:	83 c4 08             	add    $0x8,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	78 10                	js     80051d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	6a 01                	push   $0x1
  800512:	ff 75 f4             	pushl  -0xc(%ebp)
  800515:	e8 59 ff ff ff       	call   800473 <fd_close>
  80051a:	83 c4 10             	add    $0x10,%esp
}
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <close_all>:

void
close_all(void)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	53                   	push   %ebx
  800523:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	53                   	push   %ebx
  80052f:	e8 c0 ff ff ff       	call   8004f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	83 c3 01             	add    $0x1,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	83 fb 20             	cmp    $0x20,%ebx
  80053d:	75 ec                	jne    80052b <close_all+0xc>
		close(i);
}
  80053f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	53                   	push   %ebx
  80054a:	83 ec 2c             	sub    $0x2c,%esp
  80054d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	ff 75 08             	pushl  0x8(%ebp)
  800557:	e8 6e fe ff ff       	call   8003ca <fd_lookup>
  80055c:	83 c4 08             	add    $0x8,%esp
  80055f:	85 c0                	test   %eax,%eax
  800561:	0f 88 c1 00 00 00    	js     800628 <dup+0xe4>
		return r;
	close(newfdnum);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	56                   	push   %esi
  80056b:	e8 84 ff ff ff       	call   8004f4 <close>

	newfd = INDEX2FD(newfdnum);
  800570:	89 f3                	mov    %esi,%ebx
  800572:	c1 e3 0c             	shl    $0xc,%ebx
  800575:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 de fd ff ff       	call   800364 <fd2data>
  800586:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800588:	89 1c 24             	mov    %ebx,(%esp)
  80058b:	e8 d4 fd ff ff       	call   800364 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800596:	89 f8                	mov    %edi,%eax
  800598:	c1 e8 16             	shr    $0x16,%eax
  80059b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a2:	a8 01                	test   $0x1,%al
  8005a4:	74 37                	je     8005dd <dup+0x99>
  8005a6:	89 f8                	mov    %edi,%eax
  8005a8:	c1 e8 0c             	shr    $0xc,%eax
  8005ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b2:	f6 c2 01             	test   $0x1,%dl
  8005b5:	74 26                	je     8005dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005be:	83 ec 0c             	sub    $0xc,%esp
  8005c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ca:	6a 00                	push   $0x0
  8005cc:	57                   	push   %edi
  8005cd:	6a 00                	push   $0x0
  8005cf:	e8 d2 fb ff ff       	call   8001a6 <sys_page_map>
  8005d4:	89 c7                	mov    %eax,%edi
  8005d6:	83 c4 20             	add    $0x20,%esp
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	78 2e                	js     80060b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e0:	89 d0                	mov    %edx,%eax
  8005e2:	c1 e8 0c             	shr    $0xc,%eax
  8005e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f4:	50                   	push   %eax
  8005f5:	53                   	push   %ebx
  8005f6:	6a 00                	push   $0x0
  8005f8:	52                   	push   %edx
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 a6 fb ff ff       	call   8001a6 <sys_page_map>
  800600:	89 c7                	mov    %eax,%edi
  800602:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800605:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800607:	85 ff                	test   %edi,%edi
  800609:	79 1d                	jns    800628 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 00                	push   $0x0
  800611:	e8 d2 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061c:	6a 00                	push   $0x0
  80061e:	e8 c5 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	89 f8                	mov    %edi,%eax
}
  800628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5f                   	pop    %edi
  80062e:	5d                   	pop    %ebp
  80062f:	c3                   	ret    

00800630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	53                   	push   %ebx
  80063f:	e8 86 fd ff ff       	call   8003ca <fd_lookup>
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	89 c2                	mov    %eax,%edx
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 6d                	js     8006ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800657:	ff 30                	pushl  (%eax)
  800659:	e8 c2 fd ff ff       	call   800420 <dev_lookup>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 c0                	test   %eax,%eax
  800663:	78 4c                	js     8006b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800665:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800668:	8b 42 08             	mov    0x8(%edx),%eax
  80066b:	83 e0 03             	and    $0x3,%eax
  80066e:	83 f8 01             	cmp    $0x1,%eax
  800671:	75 21                	jne    800694 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800673:	a1 04 40 80 00       	mov    0x804004,%eax
  800678:	8b 40 48             	mov    0x48(%eax),%eax
  80067b:	83 ec 04             	sub    $0x4,%esp
  80067e:	53                   	push   %ebx
  80067f:	50                   	push   %eax
  800680:	68 79 1e 80 00       	push   $0x801e79
  800685:	e8 d6 0a 00 00       	call   801160 <cprintf>
		return -E_INVAL;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800692:	eb 26                	jmp    8006ba <read+0x8a>
	}
	if (!dev->dev_read)
  800694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800697:	8b 40 08             	mov    0x8(%eax),%eax
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 17                	je     8006b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80069e:	83 ec 04             	sub    $0x4,%esp
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	52                   	push   %edx
  8006a8:	ff d0                	call   *%eax
  8006aa:	89 c2                	mov    %eax,%edx
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 09                	jmp    8006ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	eb 05                	jmp    8006ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ba:	89 d0                	mov    %edx,%eax
  8006bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	57                   	push   %edi
  8006c5:	56                   	push   %esi
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	eb 21                	jmp    8006f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d7:	83 ec 04             	sub    $0x4,%esp
  8006da:	89 f0                	mov    %esi,%eax
  8006dc:	29 d8                	sub    %ebx,%eax
  8006de:	50                   	push   %eax
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	03 45 0c             	add    0xc(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	57                   	push   %edi
  8006e6:	e8 45 ff ff ff       	call   800630 <read>
		if (m < 0)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	78 10                	js     800702 <readn+0x41>
			return m;
		if (m == 0)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 0a                	je     800700 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	01 c3                	add    %eax,%ebx
  8006f8:	39 f3                	cmp    %esi,%ebx
  8006fa:	72 db                	jb     8006d7 <readn+0x16>
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	eb 02                	jmp    800702 <readn+0x41>
  800700:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	83 ec 14             	sub    $0x14,%esp
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	53                   	push   %ebx
  800719:	e8 ac fc ff ff       	call   8003ca <fd_lookup>
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	89 c2                	mov    %eax,%edx
  800723:	85 c0                	test   %eax,%eax
  800725:	78 68                	js     80078f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 e8 fc ff ff       	call   800420 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 47                	js     800786 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	75 21                	jne    800769 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 95 1e 80 00       	push   $0x801e95
  80075a:	e8 01 0a 00 00       	call   801160 <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800767:	eb 26                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076c:	8b 52 0c             	mov    0xc(%edx),%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 17                	je     80078a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	ff d2                	call   *%edx
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 09                	jmp    80078f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800786:	89 c2                	mov    %eax,%edx
  800788:	eb 05                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078f:	89 d0                	mov    %edx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <seek>:

int
seek(int fdnum, off_t offset)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 22 fc ff ff       	call   8003ca <fd_lookup>
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 0e                	js     8007bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 14             	sub    $0x14,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 f7 fb ff ff       	call   8003ca <fd_lookup>
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 65                	js     800841 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e6:	ff 30                	pushl  (%eax)
  8007e8:	e8 33 fc ff ff       	call   800420 <dev_lookup>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 44                	js     800838 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fb:	75 21                	jne    80081e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 58 1e 80 00       	push   $0x801e58
  80080f:	e8 4c 09 00 00       	call   801160 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081c:	eb 23                	jmp    800841 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80081e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800821:	8b 52 18             	mov    0x18(%edx),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	74 14                	je     80083c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	50                   	push   %eax
  80082f:	ff d2                	call   *%edx
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	eb 09                	jmp    800841 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	89 c2                	mov    %eax,%edx
  80083a:	eb 05                	jmp    800841 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 6c fb ff ff       	call   8003ca <fd_lookup>
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	89 c2                	mov    %eax,%edx
  800863:	85 c0                	test   %eax,%eax
  800865:	78 58                	js     8008bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	ff 30                	pushl  (%eax)
  800873:	e8 a8 fb ff ff       	call   800420 <dev_lookup>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 37                	js     8008b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800886:	74 32                	je     8008ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800892:	00 00 00 
	stat->st_isdir = 0;
  800895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089c:	00 00 00 
	stat->st_dev = dev;
  80089f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ac:	ff 50 14             	call   *0x14(%eax)
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 09                	jmp    8008bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	eb 05                	jmp    8008bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 00                	push   $0x0
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 2c 02 00 00       	call   800b04 <open>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 1b                	js     8008fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	50                   	push   %eax
  8008e8:	e8 5b ff ff ff       	call   800848 <fstat>
  8008ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ef:	89 1c 24             	mov    %ebx,(%esp)
  8008f2:	e8 fd fb ff ff       	call   8004f4 <close>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 f0                	mov    %esi,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  80090c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800913:	75 12                	jne    800927 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	6a 01                	push   $0x1
  80091a:	e8 c0 11 00 00       	call   801adf <ipc_find_env>
  80091f:	a3 00 40 80 00       	mov    %eax,0x804000
  800924:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800927:	6a 07                	push   $0x7
  800929:	68 00 50 80 00       	push   $0x805000
  80092e:	56                   	push   %esi
  80092f:	ff 35 00 40 80 00    	pushl  0x804000
  800935:	e8 51 11 00 00       	call   801a8b <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  80093a:	83 c4 0c             	add    $0xc,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	53                   	push   %ebx
  800940:	6a 00                	push   $0x0
  800942:	e8 e5 10 00 00       	call   801a2c <ipc_recv>
}
  800947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 40 0c             	mov    0xc(%eax),%eax
  80095a:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	b8 02 00 00 00       	mov    $0x2,%eax
  800971:	e8 8d ff ff ff       	call   800903 <fsipc>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 6b ff ff ff       	call   800903 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	83 ec 04             	sub    $0x4,%esp
  8009a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b9:	e8 45 ff ff ff       	call   800903 <fsipc>
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 2c                	js     8009ee <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	68 00 50 80 00       	push   $0x805000
  8009ca:	53                   	push   %ebx
  8009cb:	e8 15 0d 00 00       	call   8016e5 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8009d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009db:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	53                   	push   %ebx
  8009f7:	83 ec 08             	sub    $0x8,%esp
  8009fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 40 0c             	mov    0xc(%eax),%eax
  800a03:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  800a08:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  800a0e:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a14:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800a19:	0f 46 c3             	cmovbe %ebx,%eax
  800a1c:	50                   	push   %eax
  800a1d:	ff 75 0c             	pushl  0xc(%ebp)
  800a20:	68 08 50 80 00       	push   $0x805008
  800a25:	e8 4d 0e 00 00       	call   801877 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a34:	e8 ca fe ff ff       	call   800903 <fsipc>
  800a39:	83 c4 10             	add    $0x10,%esp
  800a3c:	85 c0                	test   %eax,%eax
  800a3e:	78 3d                	js     800a7d <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  800a40:	39 c3                	cmp    %eax,%ebx
  800a42:	73 19                	jae    800a5d <devfile_write+0x6a>
  800a44:	68 c4 1e 80 00       	push   $0x801ec4
  800a49:	68 cb 1e 80 00       	push   $0x801ecb
  800a4e:	68 9a 00 00 00       	push   $0x9a
  800a53:	68 e0 1e 80 00       	push   $0x801ee0
  800a58:	e8 2a 06 00 00       	call   801087 <_panic>
	   assert (r <= bytes_written);
  800a5d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a62:	7e 19                	jle    800a7d <devfile_write+0x8a>
  800a64:	68 eb 1e 80 00       	push   $0x801eeb
  800a69:	68 cb 1e 80 00       	push   $0x801ecb
  800a6e:	68 9b 00 00 00       	push   $0x9b
  800a73:	68 e0 1e 80 00       	push   $0x801ee0
  800a78:	e8 0a 06 00 00       	call   801087 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  800a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
  800a87:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a90:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  800a95:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa5:	e8 59 fe ff ff       	call   800903 <fsipc>
  800aaa:	89 c3                	mov    %eax,%ebx
  800aac:	85 c0                	test   %eax,%eax
  800aae:	78 4b                	js     800afb <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  800ab0:	39 c6                	cmp    %eax,%esi
  800ab2:	73 16                	jae    800aca <devfile_read+0x48>
  800ab4:	68 c4 1e 80 00       	push   $0x801ec4
  800ab9:	68 cb 1e 80 00       	push   $0x801ecb
  800abe:	6a 7c                	push   $0x7c
  800ac0:	68 e0 1e 80 00       	push   $0x801ee0
  800ac5:	e8 bd 05 00 00       	call   801087 <_panic>
	   assert(r <= PGSIZE);
  800aca:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800acf:	7e 16                	jle    800ae7 <devfile_read+0x65>
  800ad1:	68 fe 1e 80 00       	push   $0x801efe
  800ad6:	68 cb 1e 80 00       	push   $0x801ecb
  800adb:	6a 7d                	push   $0x7d
  800add:	68 e0 1e 80 00       	push   $0x801ee0
  800ae2:	e8 a0 05 00 00       	call   801087 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae7:	83 ec 04             	sub    $0x4,%esp
  800aea:	50                   	push   %eax
  800aeb:	68 00 50 80 00       	push   $0x805000
  800af0:	ff 75 0c             	pushl  0xc(%ebp)
  800af3:	e8 7f 0d 00 00       	call   801877 <memmove>
	   return r;
  800af8:	83 c4 10             	add    $0x10,%esp
}
  800afb:	89 d8                	mov    %ebx,%eax
  800afd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	53                   	push   %ebx
  800b08:	83 ec 20             	sub    $0x20,%esp
  800b0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  800b0e:	53                   	push   %ebx
  800b0f:	e8 98 0b 00 00       	call   8016ac <strlen>
  800b14:	83 c4 10             	add    $0x10,%esp
  800b17:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1c:	7f 67                	jg     800b85 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b1e:	83 ec 0c             	sub    $0xc,%esp
  800b21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b24:	50                   	push   %eax
  800b25:	e8 51 f8 ff ff       	call   80037b <fd_alloc>
  800b2a:	83 c4 10             	add    $0x10,%esp
			 return r;
  800b2d:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	78 57                	js     800b8a <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  800b33:	83 ec 08             	sub    $0x8,%esp
  800b36:	53                   	push   %ebx
  800b37:	68 00 50 80 00       	push   $0x805000
  800b3c:	e8 a4 0b 00 00       	call   8016e5 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  800b41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b44:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b49:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b51:	e8 ad fd ff ff       	call   800903 <fsipc>
  800b56:	89 c3                	mov    %eax,%ebx
  800b58:	83 c4 10             	add    $0x10,%esp
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	79 14                	jns    800b73 <open+0x6f>
			 fd_close(fd, 0);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	6a 00                	push   $0x0
  800b64:	ff 75 f4             	pushl  -0xc(%ebp)
  800b67:	e8 07 f9 ff ff       	call   800473 <fd_close>
			 return r;
  800b6c:	83 c4 10             	add    $0x10,%esp
  800b6f:	89 da                	mov    %ebx,%edx
  800b71:	eb 17                	jmp    800b8a <open+0x86>
	   }

	   return fd2num(fd);
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	ff 75 f4             	pushl  -0xc(%ebp)
  800b79:	e8 d6 f7 ff ff       	call   800354 <fd2num>
  800b7e:	89 c2                	mov    %eax,%edx
  800b80:	83 c4 10             	add    $0x10,%esp
  800b83:	eb 05                	jmp    800b8a <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  800b85:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  800b8a:	89 d0                	mov    %edx,%eax
  800b8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba1:	e8 5d fd ff ff       	call   800903 <fsipc>
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bb0:	83 ec 0c             	sub    $0xc,%esp
  800bb3:	ff 75 08             	pushl  0x8(%ebp)
  800bb6:	e8 a9 f7 ff ff       	call   800364 <fd2data>
  800bbb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bbd:	83 c4 08             	add    $0x8,%esp
  800bc0:	68 0a 1f 80 00       	push   $0x801f0a
  800bc5:	53                   	push   %ebx
  800bc6:	e8 1a 0b 00 00       	call   8016e5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bcb:	8b 46 04             	mov    0x4(%esi),%eax
  800bce:	2b 06                	sub    (%esi),%eax
  800bd0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bd6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bdd:	00 00 00 
	stat->st_dev = &devpipe;
  800be0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800be7:	30 80 00 
	return 0;
}
  800bea:	b8 00 00 00 00       	mov    $0x0,%eax
  800bef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c00:	53                   	push   %ebx
  800c01:	6a 00                	push   $0x0
  800c03:	e8 e0 f5 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c08:	89 1c 24             	mov    %ebx,(%esp)
  800c0b:	e8 54 f7 ff ff       	call   800364 <fd2data>
  800c10:	83 c4 08             	add    $0x8,%esp
  800c13:	50                   	push   %eax
  800c14:	6a 00                	push   $0x0
  800c16:	e8 cd f5 ff ff       	call   8001e8 <sys_page_unmap>
}
  800c1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 1c             	sub    $0x1c,%esp
  800c29:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c2c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c2e:	a1 04 40 80 00       	mov    0x804004,%eax
  800c33:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	ff 75 e0             	pushl  -0x20(%ebp)
  800c3c:	e8 d7 0e 00 00       	call   801b18 <pageref>
  800c41:	89 c3                	mov    %eax,%ebx
  800c43:	89 3c 24             	mov    %edi,(%esp)
  800c46:	e8 cd 0e 00 00       	call   801b18 <pageref>
  800c4b:	83 c4 10             	add    $0x10,%esp
  800c4e:	39 c3                	cmp    %eax,%ebx
  800c50:	0f 94 c1             	sete   %cl
  800c53:	0f b6 c9             	movzbl %cl,%ecx
  800c56:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c59:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c5f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c62:	39 ce                	cmp    %ecx,%esi
  800c64:	74 1b                	je     800c81 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c66:	39 c3                	cmp    %eax,%ebx
  800c68:	75 c4                	jne    800c2e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c6a:	8b 42 58             	mov    0x58(%edx),%eax
  800c6d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c70:	50                   	push   %eax
  800c71:	56                   	push   %esi
  800c72:	68 11 1f 80 00       	push   $0x801f11
  800c77:	e8 e4 04 00 00       	call   801160 <cprintf>
  800c7c:	83 c4 10             	add    $0x10,%esp
  800c7f:	eb ad                	jmp    800c2e <_pipeisclosed+0xe>
	}
}
  800c81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 28             	sub    $0x28,%esp
  800c95:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c98:	56                   	push   %esi
  800c99:	e8 c6 f6 ff ff       	call   800364 <fd2data>
  800c9e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca0:	83 c4 10             	add    $0x10,%esp
  800ca3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca8:	eb 4b                	jmp    800cf5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800caa:	89 da                	mov    %ebx,%edx
  800cac:	89 f0                	mov    %esi,%eax
  800cae:	e8 6d ff ff ff       	call   800c20 <_pipeisclosed>
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	75 48                	jne    800cff <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cb7:	e8 88 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cbc:	8b 43 04             	mov    0x4(%ebx),%eax
  800cbf:	8b 0b                	mov    (%ebx),%ecx
  800cc1:	8d 51 20             	lea    0x20(%ecx),%edx
  800cc4:	39 d0                	cmp    %edx,%eax
  800cc6:	73 e2                	jae    800caa <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ccf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cd2:	89 c2                	mov    %eax,%edx
  800cd4:	c1 fa 1f             	sar    $0x1f,%edx
  800cd7:	89 d1                	mov    %edx,%ecx
  800cd9:	c1 e9 1b             	shr    $0x1b,%ecx
  800cdc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cdf:	83 e2 1f             	and    $0x1f,%edx
  800ce2:	29 ca                	sub    %ecx,%edx
  800ce4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ce8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cec:	83 c0 01             	add    $0x1,%eax
  800cef:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf2:	83 c7 01             	add    $0x1,%edi
  800cf5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cf8:	75 c2                	jne    800cbc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cfa:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfd:	eb 05                	jmp    800d04 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cff:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 18             	sub    $0x18,%esp
  800d15:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d18:	57                   	push   %edi
  800d19:	e8 46 f6 ff ff       	call   800364 <fd2data>
  800d1e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d20:	83 c4 10             	add    $0x10,%esp
  800d23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d28:	eb 3d                	jmp    800d67 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d2a:	85 db                	test   %ebx,%ebx
  800d2c:	74 04                	je     800d32 <devpipe_read+0x26>
				return i;
  800d2e:	89 d8                	mov    %ebx,%eax
  800d30:	eb 44                	jmp    800d76 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d32:	89 f2                	mov    %esi,%edx
  800d34:	89 f8                	mov    %edi,%eax
  800d36:	e8 e5 fe ff ff       	call   800c20 <_pipeisclosed>
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	75 32                	jne    800d71 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d3f:	e8 00 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d44:	8b 06                	mov    (%esi),%eax
  800d46:	3b 46 04             	cmp    0x4(%esi),%eax
  800d49:	74 df                	je     800d2a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d4b:	99                   	cltd   
  800d4c:	c1 ea 1b             	shr    $0x1b,%edx
  800d4f:	01 d0                	add    %edx,%eax
  800d51:	83 e0 1f             	and    $0x1f,%eax
  800d54:	29 d0                	sub    %edx,%eax
  800d56:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d61:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d64:	83 c3 01             	add    $0x1,%ebx
  800d67:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d6a:	75 d8                	jne    800d44 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6f:	eb 05                	jmp    800d76 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d89:	50                   	push   %eax
  800d8a:	e8 ec f5 ff ff       	call   80037b <fd_alloc>
  800d8f:	83 c4 10             	add    $0x10,%esp
  800d92:	89 c2                	mov    %eax,%edx
  800d94:	85 c0                	test   %eax,%eax
  800d96:	0f 88 2c 01 00 00    	js     800ec8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9c:	83 ec 04             	sub    $0x4,%esp
  800d9f:	68 07 04 00 00       	push   $0x407
  800da4:	ff 75 f4             	pushl  -0xc(%ebp)
  800da7:	6a 00                	push   $0x0
  800da9:	e8 b5 f3 ff ff       	call   800163 <sys_page_alloc>
  800dae:	83 c4 10             	add    $0x10,%esp
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	85 c0                	test   %eax,%eax
  800db5:	0f 88 0d 01 00 00    	js     800ec8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc1:	50                   	push   %eax
  800dc2:	e8 b4 f5 ff ff       	call   80037b <fd_alloc>
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	83 c4 10             	add    $0x10,%esp
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	0f 88 e2 00 00 00    	js     800eb6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd4:	83 ec 04             	sub    $0x4,%esp
  800dd7:	68 07 04 00 00       	push   $0x407
  800ddc:	ff 75 f0             	pushl  -0x10(%ebp)
  800ddf:	6a 00                	push   $0x0
  800de1:	e8 7d f3 ff ff       	call   800163 <sys_page_alloc>
  800de6:	89 c3                	mov    %eax,%ebx
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	0f 88 c3 00 00 00    	js     800eb6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	ff 75 f4             	pushl  -0xc(%ebp)
  800df9:	e8 66 f5 ff ff       	call   800364 <fd2data>
  800dfe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e00:	83 c4 0c             	add    $0xc,%esp
  800e03:	68 07 04 00 00       	push   $0x407
  800e08:	50                   	push   %eax
  800e09:	6a 00                	push   $0x0
  800e0b:	e8 53 f3 ff ff       	call   800163 <sys_page_alloc>
  800e10:	89 c3                	mov    %eax,%ebx
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	85 c0                	test   %eax,%eax
  800e17:	0f 88 89 00 00 00    	js     800ea6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	ff 75 f0             	pushl  -0x10(%ebp)
  800e23:	e8 3c f5 ff ff       	call   800364 <fd2data>
  800e28:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e2f:	50                   	push   %eax
  800e30:	6a 00                	push   $0x0
  800e32:	56                   	push   %esi
  800e33:	6a 00                	push   $0x0
  800e35:	e8 6c f3 ff ff       	call   8001a6 <sys_page_map>
  800e3a:	89 c3                	mov    %eax,%ebx
  800e3c:	83 c4 20             	add    $0x20,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	78 55                	js     800e98 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e43:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e51:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e58:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e61:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e66:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	ff 75 f4             	pushl  -0xc(%ebp)
  800e73:	e8 dc f4 ff ff       	call   800354 <fd2num>
  800e78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e7d:	83 c4 04             	add    $0x4,%esp
  800e80:	ff 75 f0             	pushl  -0x10(%ebp)
  800e83:	e8 cc f4 ff ff       	call   800354 <fd2num>
  800e88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e8e:	83 c4 10             	add    $0x10,%esp
  800e91:	ba 00 00 00 00       	mov    $0x0,%edx
  800e96:	eb 30                	jmp    800ec8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	56                   	push   %esi
  800e9c:	6a 00                	push   $0x0
  800e9e:	e8 45 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800ea3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ea6:	83 ec 08             	sub    $0x8,%esp
  800ea9:	ff 75 f0             	pushl  -0x10(%ebp)
  800eac:	6a 00                	push   $0x0
  800eae:	e8 35 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800eb3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eb6:	83 ec 08             	sub    $0x8,%esp
  800eb9:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 25 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ec8:	89 d0                	mov    %edx,%eax
  800eca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eda:	50                   	push   %eax
  800edb:	ff 75 08             	pushl  0x8(%ebp)
  800ede:	e8 e7 f4 ff ff       	call   8003ca <fd_lookup>
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	78 18                	js     800f02 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eea:	83 ec 0c             	sub    $0xc,%esp
  800eed:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef0:	e8 6f f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800ef5:	89 c2                	mov    %eax,%edx
  800ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800efa:	e8 21 fd ff ff       	call   800c20 <_pipeisclosed>
  800eff:	83 c4 10             	add    $0x10,%esp
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f07:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f14:	68 29 1f 80 00       	push   $0x801f29
  800f19:	ff 75 0c             	pushl  0xc(%ebp)
  800f1c:	e8 c4 07 00 00       	call   8016e5 <strcpy>
	return 0;
}
  800f21:	b8 00 00 00 00       	mov    $0x0,%eax
  800f26:	c9                   	leave  
  800f27:	c3                   	ret    

00800f28 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
  800f2e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f34:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f39:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3f:	eb 2d                	jmp    800f6e <devcons_write+0x46>
		m = n - tot;
  800f41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f44:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f46:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f49:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f4e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f51:	83 ec 04             	sub    $0x4,%esp
  800f54:	53                   	push   %ebx
  800f55:	03 45 0c             	add    0xc(%ebp),%eax
  800f58:	50                   	push   %eax
  800f59:	57                   	push   %edi
  800f5a:	e8 18 09 00 00       	call   801877 <memmove>
		sys_cputs(buf, m);
  800f5f:	83 c4 08             	add    $0x8,%esp
  800f62:	53                   	push   %ebx
  800f63:	57                   	push   %edi
  800f64:	e8 3e f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f69:	01 de                	add    %ebx,%esi
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	89 f0                	mov    %esi,%eax
  800f70:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f73:	72 cc                	jb     800f41 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 08             	sub    $0x8,%esp
  800f83:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f8c:	74 2a                	je     800fb8 <devcons_read+0x3b>
  800f8e:	eb 05                	jmp    800f95 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f90:	e8 af f1 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f95:	e8 2b f1 ff ff       	call   8000c5 <sys_cgetc>
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	74 f2                	je     800f90 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	78 16                	js     800fb8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fa2:	83 f8 04             	cmp    $0x4,%eax
  800fa5:	74 0c                	je     800fb3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fa7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800faa:	88 02                	mov    %al,(%edx)
	return 1;
  800fac:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb1:	eb 05                	jmp    800fb8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fb3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fc6:	6a 01                	push   $0x1
  800fc8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	e8 d6 f0 ff ff       	call   8000a7 <sys_cputs>
}
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <getchar>:

int
getchar(void)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fdc:	6a 01                	push   $0x1
  800fde:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe1:	50                   	push   %eax
  800fe2:	6a 00                	push   $0x0
  800fe4:	e8 47 f6 ff ff       	call   800630 <read>
	if (r < 0)
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 0f                	js     800fff <getchar+0x29>
		return r;
	if (r < 1)
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	7e 06                	jle    800ffa <getchar+0x24>
		return -E_EOF;
	return c;
  800ff4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ff8:	eb 05                	jmp    800fff <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ffa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801007:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100a:	50                   	push   %eax
  80100b:	ff 75 08             	pushl  0x8(%ebp)
  80100e:	e8 b7 f3 ff ff       	call   8003ca <fd_lookup>
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	78 11                	js     80102b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80101a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801023:	39 10                	cmp    %edx,(%eax)
  801025:	0f 94 c0             	sete   %al
  801028:	0f b6 c0             	movzbl %al,%eax
}
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    

0080102d <opencons>:

int
opencons(void)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801033:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801036:	50                   	push   %eax
  801037:	e8 3f f3 ff ff       	call   80037b <fd_alloc>
  80103c:	83 c4 10             	add    $0x10,%esp
		return r;
  80103f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801041:	85 c0                	test   %eax,%eax
  801043:	78 3e                	js     801083 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801045:	83 ec 04             	sub    $0x4,%esp
  801048:	68 07 04 00 00       	push   $0x407
  80104d:	ff 75 f4             	pushl  -0xc(%ebp)
  801050:	6a 00                	push   $0x0
  801052:	e8 0c f1 ff ff       	call   800163 <sys_page_alloc>
  801057:	83 c4 10             	add    $0x10,%esp
		return r;
  80105a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80105c:	85 c0                	test   %eax,%eax
  80105e:	78 23                	js     801083 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801060:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801066:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801069:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80106b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	50                   	push   %eax
  801079:	e8 d6 f2 ff ff       	call   800354 <fd2num>
  80107e:	89 c2                	mov    %eax,%edx
  801080:	83 c4 10             	add    $0x10,%esp
}
  801083:	89 d0                	mov    %edx,%eax
  801085:	c9                   	leave  
  801086:	c3                   	ret    

00801087 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	56                   	push   %esi
  80108b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80108c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80108f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801095:	e8 8b f0 ff ff       	call   800125 <sys_getenvid>
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	ff 75 0c             	pushl  0xc(%ebp)
  8010a0:	ff 75 08             	pushl  0x8(%ebp)
  8010a3:	56                   	push   %esi
  8010a4:	50                   	push   %eax
  8010a5:	68 38 1f 80 00       	push   $0x801f38
  8010aa:	e8 b1 00 00 00       	call   801160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010af:	83 c4 18             	add    $0x18,%esp
  8010b2:	53                   	push   %ebx
  8010b3:	ff 75 10             	pushl  0x10(%ebp)
  8010b6:	e8 54 00 00 00       	call   80110f <vcprintf>
	cprintf("\n");
  8010bb:	c7 04 24 22 1f 80 00 	movl   $0x801f22,(%esp)
  8010c2:	e8 99 00 00 00       	call   801160 <cprintf>
  8010c7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ca:	cc                   	int3   
  8010cb:	eb fd                	jmp    8010ca <_panic+0x43>

008010cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	53                   	push   %ebx
  8010d1:	83 ec 04             	sub    $0x4,%esp
  8010d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010d7:	8b 13                	mov    (%ebx),%edx
  8010d9:	8d 42 01             	lea    0x1(%edx),%eax
  8010dc:	89 03                	mov    %eax,(%ebx)
  8010de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010ea:	75 1a                	jne    801106 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010ec:	83 ec 08             	sub    $0x8,%esp
  8010ef:	68 ff 00 00 00       	push   $0xff
  8010f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8010f7:	50                   	push   %eax
  8010f8:	e8 aa ef ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8010fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801103:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801106:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80110a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80111f:	00 00 00 
	b.cnt = 0;
  801122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80112c:	ff 75 0c             	pushl  0xc(%ebp)
  80112f:	ff 75 08             	pushl  0x8(%ebp)
  801132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801138:	50                   	push   %eax
  801139:	68 cd 10 80 00       	push   $0x8010cd
  80113e:	e8 54 01 00 00       	call   801297 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801143:	83 c4 08             	add    $0x8,%esp
  801146:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80114c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801152:	50                   	push   %eax
  801153:	e8 4f ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  801158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    

00801160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801169:	50                   	push   %eax
  80116a:	ff 75 08             	pushl  0x8(%ebp)
  80116d:	e8 9d ff ff ff       	call   80110f <vcprintf>
	va_end(ap);

	return cnt;
}
  801172:	c9                   	leave  
  801173:	c3                   	ret    

00801174 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	57                   	push   %edi
  801178:	56                   	push   %esi
  801179:	53                   	push   %ebx
  80117a:	83 ec 1c             	sub    $0x1c,%esp
  80117d:	89 c7                	mov    %eax,%edi
  80117f:	89 d6                	mov    %edx,%esi
  801181:	8b 45 08             	mov    0x8(%ebp),%eax
  801184:	8b 55 0c             	mov    0xc(%ebp),%edx
  801187:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80118a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80118d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801190:	bb 00 00 00 00       	mov    $0x0,%ebx
  801195:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801198:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80119b:	39 d3                	cmp    %edx,%ebx
  80119d:	72 05                	jb     8011a4 <printnum+0x30>
  80119f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011a2:	77 45                	ja     8011e9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	ff 75 18             	pushl  0x18(%ebp)
  8011aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8011ad:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011b0:	53                   	push   %ebx
  8011b1:	ff 75 10             	pushl  0x10(%ebp)
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c3:	e8 98 09 00 00       	call   801b60 <__udivdi3>
  8011c8:	83 c4 18             	add    $0x18,%esp
  8011cb:	52                   	push   %edx
  8011cc:	50                   	push   %eax
  8011cd:	89 f2                	mov    %esi,%edx
  8011cf:	89 f8                	mov    %edi,%eax
  8011d1:	e8 9e ff ff ff       	call   801174 <printnum>
  8011d6:	83 c4 20             	add    $0x20,%esp
  8011d9:	eb 18                	jmp    8011f3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011db:	83 ec 08             	sub    $0x8,%esp
  8011de:	56                   	push   %esi
  8011df:	ff 75 18             	pushl  0x18(%ebp)
  8011e2:	ff d7                	call   *%edi
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	eb 03                	jmp    8011ec <printnum+0x78>
  8011e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011ec:	83 eb 01             	sub    $0x1,%ebx
  8011ef:	85 db                	test   %ebx,%ebx
  8011f1:	7f e8                	jg     8011db <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f3:	83 ec 08             	sub    $0x8,%esp
  8011f6:	56                   	push   %esi
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fd:	ff 75 e0             	pushl  -0x20(%ebp)
  801200:	ff 75 dc             	pushl  -0x24(%ebp)
  801203:	ff 75 d8             	pushl  -0x28(%ebp)
  801206:	e8 85 0a 00 00       	call   801c90 <__umoddi3>
  80120b:	83 c4 14             	add    $0x14,%esp
  80120e:	0f be 80 5b 1f 80 00 	movsbl 0x801f5b(%eax),%eax
  801215:	50                   	push   %eax
  801216:	ff d7                	call   *%edi
}
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121e:	5b                   	pop    %ebx
  80121f:	5e                   	pop    %esi
  801220:	5f                   	pop    %edi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    

00801223 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801226:	83 fa 01             	cmp    $0x1,%edx
  801229:	7e 0e                	jle    801239 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80122b:	8b 10                	mov    (%eax),%edx
  80122d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801230:	89 08                	mov    %ecx,(%eax)
  801232:	8b 02                	mov    (%edx),%eax
  801234:	8b 52 04             	mov    0x4(%edx),%edx
  801237:	eb 22                	jmp    80125b <getuint+0x38>
	else if (lflag)
  801239:	85 d2                	test   %edx,%edx
  80123b:	74 10                	je     80124d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80123d:	8b 10                	mov    (%eax),%edx
  80123f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801242:	89 08                	mov    %ecx,(%eax)
  801244:	8b 02                	mov    (%edx),%eax
  801246:	ba 00 00 00 00       	mov    $0x0,%edx
  80124b:	eb 0e                	jmp    80125b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80124d:	8b 10                	mov    (%eax),%edx
  80124f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801252:	89 08                	mov    %ecx,(%eax)
  801254:	8b 02                	mov    (%edx),%eax
  801256:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801263:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801267:	8b 10                	mov    (%eax),%edx
  801269:	3b 50 04             	cmp    0x4(%eax),%edx
  80126c:	73 0a                	jae    801278 <sprintputch+0x1b>
		*b->buf++ = ch;
  80126e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801271:	89 08                	mov    %ecx,(%eax)
  801273:	8b 45 08             	mov    0x8(%ebp),%eax
  801276:	88 02                	mov    %al,(%edx)
}
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801280:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801283:	50                   	push   %eax
  801284:	ff 75 10             	pushl  0x10(%ebp)
  801287:	ff 75 0c             	pushl  0xc(%ebp)
  80128a:	ff 75 08             	pushl  0x8(%ebp)
  80128d:	e8 05 00 00 00       	call   801297 <vprintfmt>
	va_end(ap);
}
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	c9                   	leave  
  801296:	c3                   	ret    

00801297 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	57                   	push   %edi
  80129b:	56                   	push   %esi
  80129c:	53                   	push   %ebx
  80129d:	83 ec 2c             	sub    $0x2c,%esp
  8012a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a9:	eb 12                	jmp    8012bd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	0f 84 89 03 00 00    	je     80163c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012b3:	83 ec 08             	sub    $0x8,%esp
  8012b6:	53                   	push   %ebx
  8012b7:	50                   	push   %eax
  8012b8:	ff d6                	call   *%esi
  8012ba:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012bd:	83 c7 01             	add    $0x1,%edi
  8012c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012c4:	83 f8 25             	cmp    $0x25,%eax
  8012c7:	75 e2                	jne    8012ab <vprintfmt+0x14>
  8012c9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012cd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012d4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012db:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e7:	eb 07                	jmp    8012f0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012ec:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f0:	8d 47 01             	lea    0x1(%edi),%eax
  8012f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f6:	0f b6 07             	movzbl (%edi),%eax
  8012f9:	0f b6 c8             	movzbl %al,%ecx
  8012fc:	83 e8 23             	sub    $0x23,%eax
  8012ff:	3c 55                	cmp    $0x55,%al
  801301:	0f 87 1a 03 00 00    	ja     801621 <vprintfmt+0x38a>
  801307:	0f b6 c0             	movzbl %al,%eax
  80130a:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  801311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801314:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801318:	eb d6                	jmp    8012f0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
  801322:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801325:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801328:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80132c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80132f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801332:	83 fa 09             	cmp    $0x9,%edx
  801335:	77 39                	ja     801370 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801337:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80133a:	eb e9                	jmp    801325 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80133c:	8b 45 14             	mov    0x14(%ebp),%eax
  80133f:	8d 48 04             	lea    0x4(%eax),%ecx
  801342:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801345:	8b 00                	mov    (%eax),%eax
  801347:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80134d:	eb 27                	jmp    801376 <vprintfmt+0xdf>
  80134f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801352:	85 c0                	test   %eax,%eax
  801354:	b9 00 00 00 00       	mov    $0x0,%ecx
  801359:	0f 49 c8             	cmovns %eax,%ecx
  80135c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801362:	eb 8c                	jmp    8012f0 <vprintfmt+0x59>
  801364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801367:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80136e:	eb 80                	jmp    8012f0 <vprintfmt+0x59>
  801370:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801373:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801376:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80137a:	0f 89 70 ff ff ff    	jns    8012f0 <vprintfmt+0x59>
				width = precision, precision = -1;
  801380:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801383:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801386:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80138d:	e9 5e ff ff ff       	jmp    8012f0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801392:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801398:	e9 53 ff ff ff       	jmp    8012f0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80139d:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a0:	8d 50 04             	lea    0x4(%eax),%edx
  8013a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	53                   	push   %ebx
  8013aa:	ff 30                	pushl  (%eax)
  8013ac:	ff d6                	call   *%esi
			break;
  8013ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013b4:	e9 04 ff ff ff       	jmp    8012bd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8013bc:	8d 50 04             	lea    0x4(%eax),%edx
  8013bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c2:	8b 00                	mov    (%eax),%eax
  8013c4:	99                   	cltd   
  8013c5:	31 d0                	xor    %edx,%eax
  8013c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013c9:	83 f8 0f             	cmp    $0xf,%eax
  8013cc:	7f 0b                	jg     8013d9 <vprintfmt+0x142>
  8013ce:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8013d5:	85 d2                	test   %edx,%edx
  8013d7:	75 18                	jne    8013f1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013d9:	50                   	push   %eax
  8013da:	68 73 1f 80 00       	push   $0x801f73
  8013df:	53                   	push   %ebx
  8013e0:	56                   	push   %esi
  8013e1:	e8 94 fe ff ff       	call   80127a <printfmt>
  8013e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013ec:	e9 cc fe ff ff       	jmp    8012bd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013f1:	52                   	push   %edx
  8013f2:	68 dd 1e 80 00       	push   $0x801edd
  8013f7:	53                   	push   %ebx
  8013f8:	56                   	push   %esi
  8013f9:	e8 7c fe ff ff       	call   80127a <printfmt>
  8013fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801404:	e9 b4 fe ff ff       	jmp    8012bd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801409:	8b 45 14             	mov    0x14(%ebp),%eax
  80140c:	8d 50 04             	lea    0x4(%eax),%edx
  80140f:	89 55 14             	mov    %edx,0x14(%ebp)
  801412:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801414:	85 ff                	test   %edi,%edi
  801416:	b8 6c 1f 80 00       	mov    $0x801f6c,%eax
  80141b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80141e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801422:	0f 8e 94 00 00 00    	jle    8014bc <vprintfmt+0x225>
  801428:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80142c:	0f 84 98 00 00 00    	je     8014ca <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801432:	83 ec 08             	sub    $0x8,%esp
  801435:	ff 75 d0             	pushl  -0x30(%ebp)
  801438:	57                   	push   %edi
  801439:	e8 86 02 00 00       	call   8016c4 <strnlen>
  80143e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801441:	29 c1                	sub    %eax,%ecx
  801443:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801446:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801449:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80144d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801450:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801453:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801455:	eb 0f                	jmp    801466 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	53                   	push   %ebx
  80145b:	ff 75 e0             	pushl  -0x20(%ebp)
  80145e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801460:	83 ef 01             	sub    $0x1,%edi
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	85 ff                	test   %edi,%edi
  801468:	7f ed                	jg     801457 <vprintfmt+0x1c0>
  80146a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80146d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801470:	85 c9                	test   %ecx,%ecx
  801472:	b8 00 00 00 00       	mov    $0x0,%eax
  801477:	0f 49 c1             	cmovns %ecx,%eax
  80147a:	29 c1                	sub    %eax,%ecx
  80147c:	89 75 08             	mov    %esi,0x8(%ebp)
  80147f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801482:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801485:	89 cb                	mov    %ecx,%ebx
  801487:	eb 4d                	jmp    8014d6 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801489:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80148d:	74 1b                	je     8014aa <vprintfmt+0x213>
  80148f:	0f be c0             	movsbl %al,%eax
  801492:	83 e8 20             	sub    $0x20,%eax
  801495:	83 f8 5e             	cmp    $0x5e,%eax
  801498:	76 10                	jbe    8014aa <vprintfmt+0x213>
					putch('?', putdat);
  80149a:	83 ec 08             	sub    $0x8,%esp
  80149d:	ff 75 0c             	pushl  0xc(%ebp)
  8014a0:	6a 3f                	push   $0x3f
  8014a2:	ff 55 08             	call   *0x8(%ebp)
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	eb 0d                	jmp    8014b7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	ff 75 0c             	pushl  0xc(%ebp)
  8014b0:	52                   	push   %edx
  8014b1:	ff 55 08             	call   *0x8(%ebp)
  8014b4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014b7:	83 eb 01             	sub    $0x1,%ebx
  8014ba:	eb 1a                	jmp    8014d6 <vprintfmt+0x23f>
  8014bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8014bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014c8:	eb 0c                	jmp    8014d6 <vprintfmt+0x23f>
  8014ca:	89 75 08             	mov    %esi,0x8(%ebp)
  8014cd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014d0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014d3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014d6:	83 c7 01             	add    $0x1,%edi
  8014d9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014dd:	0f be d0             	movsbl %al,%edx
  8014e0:	85 d2                	test   %edx,%edx
  8014e2:	74 23                	je     801507 <vprintfmt+0x270>
  8014e4:	85 f6                	test   %esi,%esi
  8014e6:	78 a1                	js     801489 <vprintfmt+0x1f2>
  8014e8:	83 ee 01             	sub    $0x1,%esi
  8014eb:	79 9c                	jns    801489 <vprintfmt+0x1f2>
  8014ed:	89 df                	mov    %ebx,%edi
  8014ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014f5:	eb 18                	jmp    80150f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	53                   	push   %ebx
  8014fb:	6a 20                	push   $0x20
  8014fd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014ff:	83 ef 01             	sub    $0x1,%edi
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	eb 08                	jmp    80150f <vprintfmt+0x278>
  801507:	89 df                	mov    %ebx,%edi
  801509:	8b 75 08             	mov    0x8(%ebp),%esi
  80150c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80150f:	85 ff                	test   %edi,%edi
  801511:	7f e4                	jg     8014f7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801516:	e9 a2 fd ff ff       	jmp    8012bd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80151b:	83 fa 01             	cmp    $0x1,%edx
  80151e:	7e 16                	jle    801536 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801520:	8b 45 14             	mov    0x14(%ebp),%eax
  801523:	8d 50 08             	lea    0x8(%eax),%edx
  801526:	89 55 14             	mov    %edx,0x14(%ebp)
  801529:	8b 50 04             	mov    0x4(%eax),%edx
  80152c:	8b 00                	mov    (%eax),%eax
  80152e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801531:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801534:	eb 32                	jmp    801568 <vprintfmt+0x2d1>
	else if (lflag)
  801536:	85 d2                	test   %edx,%edx
  801538:	74 18                	je     801552 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80153a:	8b 45 14             	mov    0x14(%ebp),%eax
  80153d:	8d 50 04             	lea    0x4(%eax),%edx
  801540:	89 55 14             	mov    %edx,0x14(%ebp)
  801543:	8b 00                	mov    (%eax),%eax
  801545:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801548:	89 c1                	mov    %eax,%ecx
  80154a:	c1 f9 1f             	sar    $0x1f,%ecx
  80154d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801550:	eb 16                	jmp    801568 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801552:	8b 45 14             	mov    0x14(%ebp),%eax
  801555:	8d 50 04             	lea    0x4(%eax),%edx
  801558:	89 55 14             	mov    %edx,0x14(%ebp)
  80155b:	8b 00                	mov    (%eax),%eax
  80155d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801560:	89 c1                	mov    %eax,%ecx
  801562:	c1 f9 1f             	sar    $0x1f,%ecx
  801565:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801568:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80156b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80156e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801573:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801577:	79 74                	jns    8015ed <vprintfmt+0x356>
				putch('-', putdat);
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	53                   	push   %ebx
  80157d:	6a 2d                	push   $0x2d
  80157f:	ff d6                	call   *%esi
				num = -(long long) num;
  801581:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801584:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801587:	f7 d8                	neg    %eax
  801589:	83 d2 00             	adc    $0x0,%edx
  80158c:	f7 da                	neg    %edx
  80158e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801591:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801596:	eb 55                	jmp    8015ed <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801598:	8d 45 14             	lea    0x14(%ebp),%eax
  80159b:	e8 83 fc ff ff       	call   801223 <getuint>
			base = 10;
  8015a0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015a5:	eb 46                	jmp    8015ed <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8015a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015aa:	e8 74 fc ff ff       	call   801223 <getuint>
			base = 8;
  8015af:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015b4:	eb 37                	jmp    8015ed <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	53                   	push   %ebx
  8015ba:	6a 30                	push   $0x30
  8015bc:	ff d6                	call   *%esi
			putch('x', putdat);
  8015be:	83 c4 08             	add    $0x8,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	6a 78                	push   $0x78
  8015c4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c9:	8d 50 04             	lea    0x4(%eax),%edx
  8015cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015cf:	8b 00                	mov    (%eax),%eax
  8015d1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015d6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015d9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015de:	eb 0d                	jmp    8015ed <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8015e3:	e8 3b fc ff ff       	call   801223 <getuint>
			base = 16;
  8015e8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015f4:	57                   	push   %edi
  8015f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f8:	51                   	push   %ecx
  8015f9:	52                   	push   %edx
  8015fa:	50                   	push   %eax
  8015fb:	89 da                	mov    %ebx,%edx
  8015fd:	89 f0                	mov    %esi,%eax
  8015ff:	e8 70 fb ff ff       	call   801174 <printnum>
			break;
  801604:	83 c4 20             	add    $0x20,%esp
  801607:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80160a:	e9 ae fc ff ff       	jmp    8012bd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	53                   	push   %ebx
  801613:	51                   	push   %ecx
  801614:	ff d6                	call   *%esi
			break;
  801616:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80161c:	e9 9c fc ff ff       	jmp    8012bd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	53                   	push   %ebx
  801625:	6a 25                	push   $0x25
  801627:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	eb 03                	jmp    801631 <vprintfmt+0x39a>
  80162e:	83 ef 01             	sub    $0x1,%edi
  801631:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801635:	75 f7                	jne    80162e <vprintfmt+0x397>
  801637:	e9 81 fc ff ff       	jmp    8012bd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80163c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163f:	5b                   	pop    %ebx
  801640:	5e                   	pop    %esi
  801641:	5f                   	pop    %edi
  801642:	5d                   	pop    %ebp
  801643:	c3                   	ret    

00801644 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	83 ec 18             	sub    $0x18,%esp
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801650:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801653:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801657:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80165a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801661:	85 c0                	test   %eax,%eax
  801663:	74 26                	je     80168b <vsnprintf+0x47>
  801665:	85 d2                	test   %edx,%edx
  801667:	7e 22                	jle    80168b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801669:	ff 75 14             	pushl  0x14(%ebp)
  80166c:	ff 75 10             	pushl  0x10(%ebp)
  80166f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801672:	50                   	push   %eax
  801673:	68 5d 12 80 00       	push   $0x80125d
  801678:	e8 1a fc ff ff       	call   801297 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80167d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801680:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801683:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	eb 05                	jmp    801690 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80168b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801698:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80169b:	50                   	push   %eax
  80169c:	ff 75 10             	pushl  0x10(%ebp)
  80169f:	ff 75 0c             	pushl  0xc(%ebp)
  8016a2:	ff 75 08             	pushl  0x8(%ebp)
  8016a5:	e8 9a ff ff ff       	call   801644 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b7:	eb 03                	jmp    8016bc <strlen+0x10>
		n++;
  8016b9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016bc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016c0:	75 f7                	jne    8016b9 <strlen+0xd>
		n++;
	return n;
}
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d2:	eb 03                	jmp    8016d7 <strnlen+0x13>
		n++;
  8016d4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d7:	39 c2                	cmp    %eax,%edx
  8016d9:	74 08                	je     8016e3 <strnlen+0x1f>
  8016db:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016df:	75 f3                	jne    8016d4 <strnlen+0x10>
  8016e1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    

008016e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	53                   	push   %ebx
  8016e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ef:	89 c2                	mov    %eax,%edx
  8016f1:	83 c2 01             	add    $0x1,%edx
  8016f4:	83 c1 01             	add    $0x1,%ecx
  8016f7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016fb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016fe:	84 db                	test   %bl,%bl
  801700:	75 ef                	jne    8016f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801702:	5b                   	pop    %ebx
  801703:	5d                   	pop    %ebp
  801704:	c3                   	ret    

00801705 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	53                   	push   %ebx
  801709:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80170c:	53                   	push   %ebx
  80170d:	e8 9a ff ff ff       	call   8016ac <strlen>
  801712:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801715:	ff 75 0c             	pushl  0xc(%ebp)
  801718:	01 d8                	add    %ebx,%eax
  80171a:	50                   	push   %eax
  80171b:	e8 c5 ff ff ff       	call   8016e5 <strcpy>
	return dst;
}
  801720:	89 d8                	mov    %ebx,%eax
  801722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	56                   	push   %esi
  80172b:	53                   	push   %ebx
  80172c:	8b 75 08             	mov    0x8(%ebp),%esi
  80172f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801732:	89 f3                	mov    %esi,%ebx
  801734:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801737:	89 f2                	mov    %esi,%edx
  801739:	eb 0f                	jmp    80174a <strncpy+0x23>
		*dst++ = *src;
  80173b:	83 c2 01             	add    $0x1,%edx
  80173e:	0f b6 01             	movzbl (%ecx),%eax
  801741:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801744:	80 39 01             	cmpb   $0x1,(%ecx)
  801747:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80174a:	39 da                	cmp    %ebx,%edx
  80174c:	75 ed                	jne    80173b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80174e:	89 f0                	mov    %esi,%eax
  801750:	5b                   	pop    %ebx
  801751:	5e                   	pop    %esi
  801752:	5d                   	pop    %ebp
  801753:	c3                   	ret    

00801754 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	56                   	push   %esi
  801758:	53                   	push   %ebx
  801759:	8b 75 08             	mov    0x8(%ebp),%esi
  80175c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175f:	8b 55 10             	mov    0x10(%ebp),%edx
  801762:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801764:	85 d2                	test   %edx,%edx
  801766:	74 21                	je     801789 <strlcpy+0x35>
  801768:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80176c:	89 f2                	mov    %esi,%edx
  80176e:	eb 09                	jmp    801779 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801770:	83 c2 01             	add    $0x1,%edx
  801773:	83 c1 01             	add    $0x1,%ecx
  801776:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801779:	39 c2                	cmp    %eax,%edx
  80177b:	74 09                	je     801786 <strlcpy+0x32>
  80177d:	0f b6 19             	movzbl (%ecx),%ebx
  801780:	84 db                	test   %bl,%bl
  801782:	75 ec                	jne    801770 <strlcpy+0x1c>
  801784:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801786:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801789:	29 f0                	sub    %esi,%eax
}
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801795:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801798:	eb 06                	jmp    8017a0 <strcmp+0x11>
		p++, q++;
  80179a:	83 c1 01             	add    $0x1,%ecx
  80179d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017a0:	0f b6 01             	movzbl (%ecx),%eax
  8017a3:	84 c0                	test   %al,%al
  8017a5:	74 04                	je     8017ab <strcmp+0x1c>
  8017a7:	3a 02                	cmp    (%edx),%al
  8017a9:	74 ef                	je     80179a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ab:	0f b6 c0             	movzbl %al,%eax
  8017ae:	0f b6 12             	movzbl (%edx),%edx
  8017b1:	29 d0                	sub    %edx,%eax
}
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	53                   	push   %ebx
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017bf:	89 c3                	mov    %eax,%ebx
  8017c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017c4:	eb 06                	jmp    8017cc <strncmp+0x17>
		n--, p++, q++;
  8017c6:	83 c0 01             	add    $0x1,%eax
  8017c9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017cc:	39 d8                	cmp    %ebx,%eax
  8017ce:	74 15                	je     8017e5 <strncmp+0x30>
  8017d0:	0f b6 08             	movzbl (%eax),%ecx
  8017d3:	84 c9                	test   %cl,%cl
  8017d5:	74 04                	je     8017db <strncmp+0x26>
  8017d7:	3a 0a                	cmp    (%edx),%cl
  8017d9:	74 eb                	je     8017c6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017db:	0f b6 00             	movzbl (%eax),%eax
  8017de:	0f b6 12             	movzbl (%edx),%edx
  8017e1:	29 d0                	sub    %edx,%eax
  8017e3:	eb 05                	jmp    8017ea <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017ea:	5b                   	pop    %ebx
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f7:	eb 07                	jmp    801800 <strchr+0x13>
		if (*s == c)
  8017f9:	38 ca                	cmp    %cl,%dl
  8017fb:	74 0f                	je     80180c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017fd:	83 c0 01             	add    $0x1,%eax
  801800:	0f b6 10             	movzbl (%eax),%edx
  801803:	84 d2                	test   %dl,%dl
  801805:	75 f2                	jne    8017f9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801807:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180c:	5d                   	pop    %ebp
  80180d:	c3                   	ret    

0080180e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801818:	eb 03                	jmp    80181d <strfind+0xf>
  80181a:	83 c0 01             	add    $0x1,%eax
  80181d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801820:	38 ca                	cmp    %cl,%dl
  801822:	74 04                	je     801828 <strfind+0x1a>
  801824:	84 d2                	test   %dl,%dl
  801826:	75 f2                	jne    80181a <strfind+0xc>
			break;
	return (char *) s;
}
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    

0080182a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	57                   	push   %edi
  80182e:	56                   	push   %esi
  80182f:	53                   	push   %ebx
  801830:	8b 7d 08             	mov    0x8(%ebp),%edi
  801833:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801836:	85 c9                	test   %ecx,%ecx
  801838:	74 36                	je     801870 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80183a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801840:	75 28                	jne    80186a <memset+0x40>
  801842:	f6 c1 03             	test   $0x3,%cl
  801845:	75 23                	jne    80186a <memset+0x40>
		c &= 0xFF;
  801847:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80184b:	89 d3                	mov    %edx,%ebx
  80184d:	c1 e3 08             	shl    $0x8,%ebx
  801850:	89 d6                	mov    %edx,%esi
  801852:	c1 e6 18             	shl    $0x18,%esi
  801855:	89 d0                	mov    %edx,%eax
  801857:	c1 e0 10             	shl    $0x10,%eax
  80185a:	09 f0                	or     %esi,%eax
  80185c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80185e:	89 d8                	mov    %ebx,%eax
  801860:	09 d0                	or     %edx,%eax
  801862:	c1 e9 02             	shr    $0x2,%ecx
  801865:	fc                   	cld    
  801866:	f3 ab                	rep stos %eax,%es:(%edi)
  801868:	eb 06                	jmp    801870 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80186a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186d:	fc                   	cld    
  80186e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801870:	89 f8                	mov    %edi,%eax
  801872:	5b                   	pop    %ebx
  801873:	5e                   	pop    %esi
  801874:	5f                   	pop    %edi
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    

00801877 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	57                   	push   %edi
  80187b:	56                   	push   %esi
  80187c:	8b 45 08             	mov    0x8(%ebp),%eax
  80187f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801882:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801885:	39 c6                	cmp    %eax,%esi
  801887:	73 35                	jae    8018be <memmove+0x47>
  801889:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80188c:	39 d0                	cmp    %edx,%eax
  80188e:	73 2e                	jae    8018be <memmove+0x47>
		s += n;
		d += n;
  801890:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801893:	89 d6                	mov    %edx,%esi
  801895:	09 fe                	or     %edi,%esi
  801897:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80189d:	75 13                	jne    8018b2 <memmove+0x3b>
  80189f:	f6 c1 03             	test   $0x3,%cl
  8018a2:	75 0e                	jne    8018b2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018a4:	83 ef 04             	sub    $0x4,%edi
  8018a7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018aa:	c1 e9 02             	shr    $0x2,%ecx
  8018ad:	fd                   	std    
  8018ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b0:	eb 09                	jmp    8018bb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018b2:	83 ef 01             	sub    $0x1,%edi
  8018b5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018b8:	fd                   	std    
  8018b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018bb:	fc                   	cld    
  8018bc:	eb 1d                	jmp    8018db <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018be:	89 f2                	mov    %esi,%edx
  8018c0:	09 c2                	or     %eax,%edx
  8018c2:	f6 c2 03             	test   $0x3,%dl
  8018c5:	75 0f                	jne    8018d6 <memmove+0x5f>
  8018c7:	f6 c1 03             	test   $0x3,%cl
  8018ca:	75 0a                	jne    8018d6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018cc:	c1 e9 02             	shr    $0x2,%ecx
  8018cf:	89 c7                	mov    %eax,%edi
  8018d1:	fc                   	cld    
  8018d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d4:	eb 05                	jmp    8018db <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d6:	89 c7                	mov    %eax,%edi
  8018d8:	fc                   	cld    
  8018d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018db:	5e                   	pop    %esi
  8018dc:	5f                   	pop    %edi
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    

008018df <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e2:	ff 75 10             	pushl  0x10(%ebp)
  8018e5:	ff 75 0c             	pushl  0xc(%ebp)
  8018e8:	ff 75 08             	pushl  0x8(%ebp)
  8018eb:	e8 87 ff ff ff       	call   801877 <memmove>
}
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	56                   	push   %esi
  8018f6:	53                   	push   %ebx
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018fd:	89 c6                	mov    %eax,%esi
  8018ff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801902:	eb 1a                	jmp    80191e <memcmp+0x2c>
		if (*s1 != *s2)
  801904:	0f b6 08             	movzbl (%eax),%ecx
  801907:	0f b6 1a             	movzbl (%edx),%ebx
  80190a:	38 d9                	cmp    %bl,%cl
  80190c:	74 0a                	je     801918 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80190e:	0f b6 c1             	movzbl %cl,%eax
  801911:	0f b6 db             	movzbl %bl,%ebx
  801914:	29 d8                	sub    %ebx,%eax
  801916:	eb 0f                	jmp    801927 <memcmp+0x35>
		s1++, s2++;
  801918:	83 c0 01             	add    $0x1,%eax
  80191b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80191e:	39 f0                	cmp    %esi,%eax
  801920:	75 e2                	jne    801904 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801922:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801927:	5b                   	pop    %ebx
  801928:	5e                   	pop    %esi
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	53                   	push   %ebx
  80192f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801932:	89 c1                	mov    %eax,%ecx
  801934:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801937:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80193b:	eb 0a                	jmp    801947 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80193d:	0f b6 10             	movzbl (%eax),%edx
  801940:	39 da                	cmp    %ebx,%edx
  801942:	74 07                	je     80194b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801944:	83 c0 01             	add    $0x1,%eax
  801947:	39 c8                	cmp    %ecx,%eax
  801949:	72 f2                	jb     80193d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80194b:	5b                   	pop    %ebx
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	57                   	push   %edi
  801952:	56                   	push   %esi
  801953:	53                   	push   %ebx
  801954:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801957:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195a:	eb 03                	jmp    80195f <strtol+0x11>
		s++;
  80195c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195f:	0f b6 01             	movzbl (%ecx),%eax
  801962:	3c 20                	cmp    $0x20,%al
  801964:	74 f6                	je     80195c <strtol+0xe>
  801966:	3c 09                	cmp    $0x9,%al
  801968:	74 f2                	je     80195c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80196a:	3c 2b                	cmp    $0x2b,%al
  80196c:	75 0a                	jne    801978 <strtol+0x2a>
		s++;
  80196e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801971:	bf 00 00 00 00       	mov    $0x0,%edi
  801976:	eb 11                	jmp    801989 <strtol+0x3b>
  801978:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80197d:	3c 2d                	cmp    $0x2d,%al
  80197f:	75 08                	jne    801989 <strtol+0x3b>
		s++, neg = 1;
  801981:	83 c1 01             	add    $0x1,%ecx
  801984:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801989:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80198f:	75 15                	jne    8019a6 <strtol+0x58>
  801991:	80 39 30             	cmpb   $0x30,(%ecx)
  801994:	75 10                	jne    8019a6 <strtol+0x58>
  801996:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80199a:	75 7c                	jne    801a18 <strtol+0xca>
		s += 2, base = 16;
  80199c:	83 c1 02             	add    $0x2,%ecx
  80199f:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a4:	eb 16                	jmp    8019bc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019a6:	85 db                	test   %ebx,%ebx
  8019a8:	75 12                	jne    8019bc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019af:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b2:	75 08                	jne    8019bc <strtol+0x6e>
		s++, base = 8;
  8019b4:	83 c1 01             	add    $0x1,%ecx
  8019b7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019c4:	0f b6 11             	movzbl (%ecx),%edx
  8019c7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019ca:	89 f3                	mov    %esi,%ebx
  8019cc:	80 fb 09             	cmp    $0x9,%bl
  8019cf:	77 08                	ja     8019d9 <strtol+0x8b>
			dig = *s - '0';
  8019d1:	0f be d2             	movsbl %dl,%edx
  8019d4:	83 ea 30             	sub    $0x30,%edx
  8019d7:	eb 22                	jmp    8019fb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019d9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019dc:	89 f3                	mov    %esi,%ebx
  8019de:	80 fb 19             	cmp    $0x19,%bl
  8019e1:	77 08                	ja     8019eb <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019e3:	0f be d2             	movsbl %dl,%edx
  8019e6:	83 ea 57             	sub    $0x57,%edx
  8019e9:	eb 10                	jmp    8019fb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019eb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019ee:	89 f3                	mov    %esi,%ebx
  8019f0:	80 fb 19             	cmp    $0x19,%bl
  8019f3:	77 16                	ja     801a0b <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019f5:	0f be d2             	movsbl %dl,%edx
  8019f8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019fb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019fe:	7d 0b                	jge    801a0b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a00:	83 c1 01             	add    $0x1,%ecx
  801a03:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a07:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a09:	eb b9                	jmp    8019c4 <strtol+0x76>

	if (endptr)
  801a0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a0f:	74 0d                	je     801a1e <strtol+0xd0>
		*endptr = (char *) s;
  801a11:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a14:	89 0e                	mov    %ecx,(%esi)
  801a16:	eb 06                	jmp    801a1e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a18:	85 db                	test   %ebx,%ebx
  801a1a:	74 98                	je     8019b4 <strtol+0x66>
  801a1c:	eb 9e                	jmp    8019bc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a1e:	89 c2                	mov    %eax,%edx
  801a20:	f7 da                	neg    %edx
  801a22:	85 ff                	test   %edi,%edi
  801a24:	0f 45 c2             	cmovne %edx,%eax
}
  801a27:	5b                   	pop    %ebx
  801a28:	5e                   	pop    %esi
  801a29:	5f                   	pop    %edi
  801a2a:	5d                   	pop    %ebp
  801a2b:	c3                   	ret    

00801a2c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	56                   	push   %esi
  801a30:	53                   	push   %ebx
  801a31:	8b 75 08             	mov    0x8(%ebp),%esi
  801a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801a3a:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801a3c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a41:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	50                   	push   %eax
  801a48:	e8 c6 e8 ff ff       	call   800313 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	85 c0                	test   %eax,%eax
  801a52:	78 0e                	js     801a62 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801a54:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a5a:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801a5d:	8b 52 78             	mov    0x78(%edx),%edx
  801a60:	eb 0a                	jmp    801a6c <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801a62:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801a67:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801a6c:	85 f6                	test   %esi,%esi
  801a6e:	74 02                	je     801a72 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801a70:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801a72:	85 db                	test   %ebx,%ebx
  801a74:	74 02                	je     801a78 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801a76:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	78 08                	js     801a84 <ipc_recv+0x58>
  801a7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a81:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801a84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a87:	5b                   	pop    %ebx
  801a88:	5e                   	pop    %esi
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	57                   	push   %edi
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a97:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801a9d:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801a9f:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801aa4:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801aa7:	ff 75 14             	pushl  0x14(%ebp)
  801aaa:	53                   	push   %ebx
  801aab:	56                   	push   %esi
  801aac:	57                   	push   %edi
  801aad:	e8 3e e8 ff ff       	call   8002f0 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ab8:	75 07                	jne    801ac1 <ipc_send+0x36>
				    sys_yield();
  801aba:	e8 85 e6 ff ff       	call   800144 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801abf:	eb e6                	jmp    801aa7 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	74 12                	je     801ad7 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801ac5:	50                   	push   %eax
  801ac6:	68 60 22 80 00       	push   $0x802260
  801acb:	6a 4b                	push   $0x4b
  801acd:	68 74 22 80 00       	push   $0x802274
  801ad2:	e8 b0 f5 ff ff       	call   801087 <_panic>
			 }
	   }
}
  801ad7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ada:	5b                   	pop    %ebx
  801adb:	5e                   	pop    %esi
  801adc:	5f                   	pop    %edi
  801add:	5d                   	pop    %ebp
  801ade:	c3                   	ret    

00801adf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801ae5:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801aea:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aed:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af3:	8b 52 50             	mov    0x50(%edx),%edx
  801af6:	39 ca                	cmp    %ecx,%edx
  801af8:	75 0d                	jne    801b07 <ipc_find_env+0x28>
				    return envs[i].env_id;
  801afa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801afd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b02:	8b 40 48             	mov    0x48(%eax),%eax
  801b05:	eb 0f                	jmp    801b16 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801b07:	83 c0 01             	add    $0x1,%eax
  801b0a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b0f:	75 d9                	jne    801aea <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801b11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1e:	89 d0                	mov    %edx,%eax
  801b20:	c1 e8 16             	shr    $0x16,%eax
  801b23:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b2a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2f:	f6 c1 01             	test   $0x1,%cl
  801b32:	74 1d                	je     801b51 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b34:	c1 ea 0c             	shr    $0xc,%edx
  801b37:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b3e:	f6 c2 01             	test   $0x1,%dl
  801b41:	74 0e                	je     801b51 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b43:	c1 ea 0c             	shr    $0xc,%edx
  801b46:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b4d:	ef 
  801b4e:	0f b7 c0             	movzwl %ax,%eax
}
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    
  801b53:	66 90                	xchg   %ax,%ax
  801b55:	66 90                	xchg   %ax,%ax
  801b57:	66 90                	xchg   %ax,%ax
  801b59:	66 90                	xchg   %ax,%ax
  801b5b:	66 90                	xchg   %ax,%ax
  801b5d:	66 90                	xchg   %ax,%ax
  801b5f:	90                   	nop

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
