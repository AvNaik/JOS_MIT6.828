
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 33 0b 00 00       	call   800b70 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 3f 0e 00 00       	call   800e88 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 2e 0b 00 00       	call   800b8f <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 05 0b 00 00       	call   800b8f <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 40 80 00       	mov    %eax,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 00 22 80 00       	push   $0x802200
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 28 22 80 00       	push   $0x802228
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 3b 22 80 00       	push   $0x80223b
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000f8:	e8 73 0a 00 00       	call   800b70 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 14 11 00 00       	call   801252 <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 e7 09 00 00       	call   800b2f <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 10 0a 00 00       	call   800b70 <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 64 22 80 00       	push   $0x802264
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 57 22 80 00 	movl   $0x802257,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 2f 09 00 00       	call   800af2 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 54 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 d4 08 00 00       	call   800af2 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 d2 1c 00 00       	call   801f60 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 bf 1d 00 00       	call   802090 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 87 22 80 00 	movsbl 0x802287(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ec:	83 fa 01             	cmp    $0x1,%edx
  8002ef:	7e 0e                	jle    8002ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	8b 52 04             	mov    0x4(%edx),%edx
  8002fd:	eb 22                	jmp    800321 <getuint+0x38>
	else if (lflag)
  8002ff:	85 d2                	test   %edx,%edx
  800301:	74 10                	je     800313 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 04             	lea    0x4(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	eb 0e                	jmp    800321 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800329:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 0a                	jae    80033e <sprintputch+0x1b>
		*b->buf++ = ch;
  800334:	8d 4a 01             	lea    0x1(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	88 02                	mov    %al,(%edx)
}
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
	va_end(ap);
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 75 08             	mov    0x8(%ebp),%esi
  800369:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036f:	eb 12                	jmp    800383 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800371:	85 c0                	test   %eax,%eax
  800373:	0f 84 89 03 00 00    	je     800702 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	53                   	push   %ebx
  80037d:	50                   	push   %eax
  80037e:	ff d6                	call   *%esi
  800380:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800383:	83 c7 01             	add    $0x1,%edi
  800386:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038a:	83 f8 25             	cmp    $0x25,%eax
  80038d:	75 e2                	jne    800371 <vprintfmt+0x14>
  80038f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800393:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	eb 07                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8d 47 01             	lea    0x1(%edi),%eax
  8003b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bc:	0f b6 07             	movzbl (%edi),%eax
  8003bf:	0f b6 c8             	movzbl %al,%ecx
  8003c2:	83 e8 23             	sub    $0x23,%eax
  8003c5:	3c 55                	cmp    $0x55,%al
  8003c7:	0f 87 1a 03 00 00    	ja     8006e7 <vprintfmt+0x38a>
  8003cd:	0f b6 c0             	movzbl %al,%eax
  8003d0:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003da:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003de:	eb d6                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ee:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f8:	83 fa 09             	cmp    $0x9,%edx
  8003fb:	77 39                	ja     800436 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800400:	eb e9                	jmp    8003eb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 48 04             	lea    0x4(%eax),%ecx
  800408:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800413:	eb 27                	jmp    80043c <vprintfmt+0xdf>
  800415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800418:	85 c0                	test   %eax,%eax
  80041a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041f:	0f 49 c8             	cmovns %eax,%ecx
  800422:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800428:	eb 8c                	jmp    8003b6 <vprintfmt+0x59>
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800434:	eb 80                	jmp    8003b6 <vprintfmt+0x59>
  800436:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800439:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80043c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800440:	0f 89 70 ff ff ff    	jns    8003b6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800446:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800453:	e9 5e ff ff ff       	jmp    8003b6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800458:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045e:	e9 53 ff ff ff       	jmp    8003b6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	ff 30                	pushl  (%eax)
  800472:	ff d6                	call   *%esi
			break;
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047a:	e9 04 ff ff ff       	jmp    800383 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	99                   	cltd   
  80048b:	31 d0                	xor    %edx,%eax
  80048d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048f:	83 f8 0f             	cmp    $0xf,%eax
  800492:	7f 0b                	jg     80049f <vprintfmt+0x142>
  800494:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 9f 22 80 00       	push   $0x80229f
  8004a5:	53                   	push   %ebx
  8004a6:	56                   	push   %esi
  8004a7:	e8 94 fe ff ff       	call   800340 <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b2:	e9 cc fe ff ff       	jmp    800383 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b7:	52                   	push   %edx
  8004b8:	68 01 27 80 00       	push   $0x802701
  8004bd:	53                   	push   %ebx
  8004be:	56                   	push   %esi
  8004bf:	e8 7c fe ff ff       	call   800340 <printfmt>
  8004c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	e9 b4 fe ff ff       	jmp    800383 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	b8 98 22 80 00       	mov    $0x802298,%eax
  8004e1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e8:	0f 8e 94 00 00 00    	jle    800582 <vprintfmt+0x225>
  8004ee:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f2:	0f 84 98 00 00 00    	je     800590 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8004fe:	57                   	push   %edi
  8004ff:	e8 86 02 00 00       	call   80078a <strnlen>
  800504:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800507:	29 c1                	sub    %eax,%ecx
  800509:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800513:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800516:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800519:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	eb 0f                	jmp    80052c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	ff 75 e0             	pushl  -0x20(%ebp)
  800524:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	83 ef 01             	sub    $0x1,%edi
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	85 ff                	test   %edi,%edi
  80052e:	7f ed                	jg     80051d <vprintfmt+0x1c0>
  800530:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800533:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800536:	85 c9                	test   %ecx,%ecx
  800538:	b8 00 00 00 00       	mov    $0x0,%eax
  80053d:	0f 49 c1             	cmovns %ecx,%eax
  800540:	29 c1                	sub    %eax,%ecx
  800542:	89 75 08             	mov    %esi,0x8(%ebp)
  800545:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800548:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054b:	89 cb                	mov    %ecx,%ebx
  80054d:	eb 4d                	jmp    80059c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800553:	74 1b                	je     800570 <vprintfmt+0x213>
  800555:	0f be c0             	movsbl %al,%eax
  800558:	83 e8 20             	sub    $0x20,%eax
  80055b:	83 f8 5e             	cmp    $0x5e,%eax
  80055e:	76 10                	jbe    800570 <vprintfmt+0x213>
					putch('?', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	ff 75 0c             	pushl  0xc(%ebp)
  800566:	6a 3f                	push   $0x3f
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 0d                	jmp    80057d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	52                   	push   %edx
  800577:	ff 55 08             	call   *0x8(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	83 eb 01             	sub    $0x1,%ebx
  800580:	eb 1a                	jmp    80059c <vprintfmt+0x23f>
  800582:	89 75 08             	mov    %esi,0x8(%ebp)
  800585:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800588:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058e:	eb 0c                	jmp    80059c <vprintfmt+0x23f>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800596:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	83 c7 01             	add    $0x1,%edi
  80059f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a3:	0f be d0             	movsbl %al,%edx
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	74 23                	je     8005cd <vprintfmt+0x270>
  8005aa:	85 f6                	test   %esi,%esi
  8005ac:	78 a1                	js     80054f <vprintfmt+0x1f2>
  8005ae:	83 ee 01             	sub    $0x1,%esi
  8005b1:	79 9c                	jns    80054f <vprintfmt+0x1f2>
  8005b3:	89 df                	mov    %ebx,%edi
  8005b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bb:	eb 18                	jmp    8005d5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	6a 20                	push   $0x20
  8005c3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c5:	83 ef 01             	sub    $0x1,%edi
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 08                	jmp    8005d5 <vprintfmt+0x278>
  8005cd:	89 df                	mov    %ebx,%edi
  8005cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	7f e4                	jg     8005bd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	e9 a2 fd ff ff       	jmp    800383 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e1:	83 fa 01             	cmp    $0x1,%edx
  8005e4:	7e 16                	jle    8005fc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 08             	lea    0x8(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 50 04             	mov    0x4(%eax),%edx
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fa:	eb 32                	jmp    80062e <vprintfmt+0x2d1>
	else if (lflag)
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	74 18                	je     800618 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060e:	89 c1                	mov    %eax,%ecx
  800610:	c1 f9 1f             	sar    $0x1f,%ecx
  800613:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800616:	eb 16                	jmp    80062e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 00                	mov    (%eax),%eax
  800623:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800626:	89 c1                	mov    %eax,%ecx
  800628:	c1 f9 1f             	sar    $0x1f,%ecx
  80062b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800631:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800639:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063d:	79 74                	jns    8006b3 <vprintfmt+0x356>
				putch('-', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	53                   	push   %ebx
  800643:	6a 2d                	push   $0x2d
  800645:	ff d6                	call   *%esi
				num = -(long long) num;
  800647:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064d:	f7 d8                	neg    %eax
  80064f:	83 d2 00             	adc    $0x0,%edx
  800652:	f7 da                	neg    %edx
  800654:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800657:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80065c:	eb 55                	jmp    8006b3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 83 fc ff ff       	call   8002e9 <getuint>
			base = 10;
  800666:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80066b:	eb 46                	jmp    8006b3 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	e8 74 fc ff ff       	call   8002e9 <getuint>
			base = 8;
  800675:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80067a:	eb 37                	jmp    8006b3 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 30                	push   $0x30
  800682:	ff d6                	call   *%esi
			putch('x', putdat);
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 78                	push   $0x78
  80068a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a4:	eb 0d                	jmp    8006b3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 3b fc ff ff       	call   8002e9 <getuint>
			base = 16;
  8006ae:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b3:	83 ec 0c             	sub    $0xc,%esp
  8006b6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ba:	57                   	push   %edi
  8006bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006be:	51                   	push   %ecx
  8006bf:	52                   	push   %edx
  8006c0:	50                   	push   %eax
  8006c1:	89 da                	mov    %ebx,%edx
  8006c3:	89 f0                	mov    %esi,%eax
  8006c5:	e8 70 fb ff ff       	call   80023a <printnum>
			break;
  8006ca:	83 c4 20             	add    $0x20,%esp
  8006cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d0:	e9 ae fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	51                   	push   %ecx
  8006da:	ff d6                	call   *%esi
			break;
  8006dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e2:	e9 9c fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	6a 25                	push   $0x25
  8006ed:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	eb 03                	jmp    8006f7 <vprintfmt+0x39a>
  8006f4:	83 ef 01             	sub    $0x1,%edi
  8006f7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fb:	75 f7                	jne    8006f4 <vprintfmt+0x397>
  8006fd:	e9 81 fc ff ff       	jmp    800383 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 18             	sub    $0x18,%esp
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800716:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800719:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800720:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800727:	85 c0                	test   %eax,%eax
  800729:	74 26                	je     800751 <vsnprintf+0x47>
  80072b:	85 d2                	test   %edx,%edx
  80072d:	7e 22                	jle    800751 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072f:	ff 75 14             	pushl  0x14(%ebp)
  800732:	ff 75 10             	pushl  0x10(%ebp)
  800735:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	68 23 03 80 00       	push   $0x800323
  80073e:	e8 1a fc ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800743:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800746:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb 05                	jmp    800756 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800761:	50                   	push   %eax
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	ff 75 08             	pushl  0x8(%ebp)
  80076b:	e8 9a ff ff ff       	call   80070a <vsnprintf>
	va_end(ap);

	return rc;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 03                	jmp    800782 <strlen+0x10>
		n++;
  80077f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800786:	75 f7                	jne    80077f <strlen+0xd>
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800790:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	ba 00 00 00 00       	mov    $0x0,%edx
  800798:	eb 03                	jmp    80079d <strnlen+0x13>
		n++;
  80079a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079d:	39 c2                	cmp    %eax,%edx
  80079f:	74 08                	je     8007a9 <strnlen+0x1f>
  8007a1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a5:	75 f3                	jne    80079a <strnlen+0x10>
  8007a7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b5:	89 c2                	mov    %eax,%edx
  8007b7:	83 c2 01             	add    $0x1,%edx
  8007ba:	83 c1 01             	add    $0x1,%ecx
  8007bd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c4:	84 db                	test   %bl,%bl
  8007c6:	75 ef                	jne    8007b7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d2:	53                   	push   %ebx
  8007d3:	e8 9a ff ff ff       	call   800772 <strlen>
  8007d8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007db:	ff 75 0c             	pushl  0xc(%ebp)
  8007de:	01 d8                	add    %ebx,%eax
  8007e0:	50                   	push   %eax
  8007e1:	e8 c5 ff ff ff       	call   8007ab <strcpy>
	return dst;
}
  8007e6:	89 d8                	mov    %ebx,%eax
  8007e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	56                   	push   %esi
  8007f1:	53                   	push   %ebx
  8007f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f8:	89 f3                	mov    %esi,%ebx
  8007fa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	89 f2                	mov    %esi,%edx
  8007ff:	eb 0f                	jmp    800810 <strncpy+0x23>
		*dst++ = *src;
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	0f b6 01             	movzbl (%ecx),%eax
  800807:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080a:	80 39 01             	cmpb   $0x1,(%ecx)
  80080d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	39 da                	cmp    %ebx,%edx
  800812:	75 ed                	jne    800801 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800814:	89 f0                	mov    %esi,%eax
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800825:	8b 55 10             	mov    0x10(%ebp),%edx
  800828:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082a:	85 d2                	test   %edx,%edx
  80082c:	74 21                	je     80084f <strlcpy+0x35>
  80082e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800832:	89 f2                	mov    %esi,%edx
  800834:	eb 09                	jmp    80083f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083f:	39 c2                	cmp    %eax,%edx
  800841:	74 09                	je     80084c <strlcpy+0x32>
  800843:	0f b6 19             	movzbl (%ecx),%ebx
  800846:	84 db                	test   %bl,%bl
  800848:	75 ec                	jne    800836 <strlcpy+0x1c>
  80084a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084f:	29 f0                	sub    %esi,%eax
}
  800851:	5b                   	pop    %ebx
  800852:	5e                   	pop    %esi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085e:	eb 06                	jmp    800866 <strcmp+0x11>
		p++, q++;
  800860:	83 c1 01             	add    $0x1,%ecx
  800863:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800866:	0f b6 01             	movzbl (%ecx),%eax
  800869:	84 c0                	test   %al,%al
  80086b:	74 04                	je     800871 <strcmp+0x1c>
  80086d:	3a 02                	cmp    (%edx),%al
  80086f:	74 ef                	je     800860 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	89 c3                	mov    %eax,%ebx
  800887:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088a:	eb 06                	jmp    800892 <strncmp+0x17>
		n--, p++, q++;
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800892:	39 d8                	cmp    %ebx,%eax
  800894:	74 15                	je     8008ab <strncmp+0x30>
  800896:	0f b6 08             	movzbl (%eax),%ecx
  800899:	84 c9                	test   %cl,%cl
  80089b:	74 04                	je     8008a1 <strncmp+0x26>
  80089d:	3a 0a                	cmp    (%edx),%cl
  80089f:	74 eb                	je     80088c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 00             	movzbl (%eax),%eax
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
  8008a9:	eb 05                	jmp    8008b0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bd:	eb 07                	jmp    8008c6 <strchr+0x13>
		if (*s == c)
  8008bf:	38 ca                	cmp    %cl,%dl
  8008c1:	74 0f                	je     8008d2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c3:	83 c0 01             	add    $0x1,%eax
  8008c6:	0f b6 10             	movzbl (%eax),%edx
  8008c9:	84 d2                	test   %dl,%dl
  8008cb:	75 f2                	jne    8008bf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008de:	eb 03                	jmp    8008e3 <strfind+0xf>
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 04                	je     8008ee <strfind+0x1a>
  8008ea:	84 d2                	test   %dl,%dl
  8008ec:	75 f2                	jne    8008e0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	57                   	push   %edi
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fc:	85 c9                	test   %ecx,%ecx
  8008fe:	74 36                	je     800936 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800900:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800906:	75 28                	jne    800930 <memset+0x40>
  800908:	f6 c1 03             	test   $0x3,%cl
  80090b:	75 23                	jne    800930 <memset+0x40>
		c &= 0xFF;
  80090d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800911:	89 d3                	mov    %edx,%ebx
  800913:	c1 e3 08             	shl    $0x8,%ebx
  800916:	89 d6                	mov    %edx,%esi
  800918:	c1 e6 18             	shl    $0x18,%esi
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	c1 e0 10             	shl    $0x10,%eax
  800920:	09 f0                	or     %esi,%eax
  800922:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800924:	89 d8                	mov    %ebx,%eax
  800926:	09 d0                	or     %edx,%eax
  800928:	c1 e9 02             	shr    $0x2,%ecx
  80092b:	fc                   	cld    
  80092c:	f3 ab                	rep stos %eax,%es:(%edi)
  80092e:	eb 06                	jmp    800936 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	fc                   	cld    
  800934:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800936:	89 f8                	mov    %edi,%eax
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 75 0c             	mov    0xc(%ebp),%esi
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094b:	39 c6                	cmp    %eax,%esi
  80094d:	73 35                	jae    800984 <memmove+0x47>
  80094f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800952:	39 d0                	cmp    %edx,%eax
  800954:	73 2e                	jae    800984 <memmove+0x47>
		s += n;
		d += n;
  800956:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	89 d6                	mov    %edx,%esi
  80095b:	09 fe                	or     %edi,%esi
  80095d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800963:	75 13                	jne    800978 <memmove+0x3b>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 0e                	jne    800978 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80096a:	83 ef 04             	sub    $0x4,%edi
  80096d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800970:	c1 e9 02             	shr    $0x2,%ecx
  800973:	fd                   	std    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 09                	jmp    800981 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800978:	83 ef 01             	sub    $0x1,%edi
  80097b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097e:	fd                   	std    
  80097f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800981:	fc                   	cld    
  800982:	eb 1d                	jmp    8009a1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	89 f2                	mov    %esi,%edx
  800986:	09 c2                	or     %eax,%edx
  800988:	f6 c2 03             	test   $0x3,%dl
  80098b:	75 0f                	jne    80099c <memmove+0x5f>
  80098d:	f6 c1 03             	test   $0x3,%cl
  800990:	75 0a                	jne    80099c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800992:	c1 e9 02             	shr    $0x2,%ecx
  800995:	89 c7                	mov    %eax,%edi
  800997:	fc                   	cld    
  800998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099a:	eb 05                	jmp    8009a1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099c:	89 c7                	mov    %eax,%edi
  80099e:	fc                   	cld    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a8:	ff 75 10             	pushl  0x10(%ebp)
  8009ab:	ff 75 0c             	pushl  0xc(%ebp)
  8009ae:	ff 75 08             	pushl  0x8(%ebp)
  8009b1:	e8 87 ff ff ff       	call   80093d <memmove>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c3:	89 c6                	mov    %eax,%esi
  8009c5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c8:	eb 1a                	jmp    8009e4 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ca:	0f b6 08             	movzbl (%eax),%ecx
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	38 d9                	cmp    %bl,%cl
  8009d2:	74 0a                	je     8009de <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d4:	0f b6 c1             	movzbl %cl,%eax
  8009d7:	0f b6 db             	movzbl %bl,%ebx
  8009da:	29 d8                	sub    %ebx,%eax
  8009dc:	eb 0f                	jmp    8009ed <memcmp+0x35>
		s1++, s2++;
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e4:	39 f0                	cmp    %esi,%eax
  8009e6:	75 e2                	jne    8009ca <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f8:	89 c1                	mov    %eax,%ecx
  8009fa:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a01:	eb 0a                	jmp    800a0d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a03:	0f b6 10             	movzbl (%eax),%edx
  800a06:	39 da                	cmp    %ebx,%edx
  800a08:	74 07                	je     800a11 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	39 c8                	cmp    %ecx,%eax
  800a0f:	72 f2                	jb     800a03 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a11:	5b                   	pop    %ebx
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x11>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0xe>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	75 0a                	jne    800a3e <strtol+0x2a>
		s++;
  800a34:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a37:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3c:	eb 11                	jmp    800a4f <strtol+0x3b>
  800a3e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a43:	3c 2d                	cmp    $0x2d,%al
  800a45:	75 08                	jne    800a4f <strtol+0x3b>
		s++, neg = 1;
  800a47:	83 c1 01             	add    $0x1,%ecx
  800a4a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a55:	75 15                	jne    800a6c <strtol+0x58>
  800a57:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5a:	75 10                	jne    800a6c <strtol+0x58>
  800a5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a60:	75 7c                	jne    800ade <strtol+0xca>
		s += 2, base = 16;
  800a62:	83 c1 02             	add    $0x2,%ecx
  800a65:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6a:	eb 16                	jmp    800a82 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	75 12                	jne    800a82 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a70:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a75:	80 39 30             	cmpb   $0x30,(%ecx)
  800a78:	75 08                	jne    800a82 <strtol+0x6e>
		s++, base = 8;
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8a:	0f b6 11             	movzbl (%ecx),%edx
  800a8d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 09             	cmp    $0x9,%bl
  800a95:	77 08                	ja     800a9f <strtol+0x8b>
			dig = *s - '0';
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 30             	sub    $0x30,%edx
  800a9d:	eb 22                	jmp    800ac1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 19             	cmp    $0x19,%bl
  800aa7:	77 08                	ja     800ab1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 57             	sub    $0x57,%edx
  800aaf:	eb 10                	jmp    800ac1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 16                	ja     800ad1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac4:	7d 0b                	jge    800ad1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac6:	83 c1 01             	add    $0x1,%ecx
  800ac9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acf:	eb b9                	jmp    800a8a <strtol+0x76>

	if (endptr)
  800ad1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad5:	74 0d                	je     800ae4 <strtol+0xd0>
		*endptr = (char *) s;
  800ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ada:	89 0e                	mov    %ecx,(%esi)
  800adc:	eb 06                	jmp    800ae4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ade:	85 db                	test   %ebx,%ebx
  800ae0:	74 98                	je     800a7a <strtol+0x66>
  800ae2:	eb 9e                	jmp    800a82 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae4:	89 c2                	mov    %eax,%edx
  800ae6:	f7 da                	neg    %edx
  800ae8:	85 ff                	test   %edi,%edi
  800aea:	0f 45 c2             	cmovne %edx,%eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7e 17                	jle    800b68 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	50                   	push   %eax
  800b55:	6a 03                	push   $0x3
  800b57:	68 7f 25 80 00       	push   $0x80257f
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 9c 25 80 00       	push   $0x80259c
  800b63:	e8 e5 f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_yield>:

void
sys_yield(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 04                	push   $0x4
  800bd8:	68 7f 25 80 00       	push   $0x80257f
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 9c 25 80 00       	push   $0x80259c
  800be4:	e8 64 f5 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 05                	push   $0x5
  800c1a:	68 7f 25 80 00       	push   $0x80257f
  800c1f:	6a 23                	push   $0x23
  800c21:	68 9c 25 80 00       	push   $0x80259c
  800c26:	e8 22 f5 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	b8 06 00 00 00       	mov    $0x6,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 17                	jle    800c6d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 06                	push   $0x6
  800c5c:	68 7f 25 80 00       	push   $0x80257f
  800c61:	6a 23                	push   $0x23
  800c63:	68 9c 25 80 00       	push   $0x80259c
  800c68:	e8 e0 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	b8 08 00 00 00       	mov    $0x8,%eax
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 08                	push   $0x8
  800c9e:	68 7f 25 80 00       	push   $0x80257f
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 9c 25 80 00       	push   $0x80259c
  800caa:	e8 9e f4 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 09                	push   $0x9
  800ce0:	68 7f 25 80 00       	push   $0x80257f
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 9c 25 80 00       	push   $0x80259c
  800cec:	e8 5c f4 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 0a                	push   $0xa
  800d22:	68 7f 25 80 00       	push   $0x80257f
  800d27:	6a 23                	push   $0x23
  800d29:	68 9c 25 80 00       	push   $0x80259c
  800d2e:	e8 1a f4 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	be 00 00 00 00       	mov    $0x0,%esi
  800d46:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 0d                	push   $0xd
  800d86:	68 7f 25 80 00       	push   $0x80257f
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 9c 25 80 00       	push   $0x80259c
  800d92:	e8 b6 f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	53                   	push   %ebx
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  800da9:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  800dab:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  800dae:	89 da                	mov    %ebx,%edx
  800db0:	c1 ea 0c             	shr    $0xc,%edx
  800db3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  800dba:	a8 02                	test   $0x2,%al
  800dbc:	75 12                	jne    800dd0 <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  800dbe:	50                   	push   %eax
  800dbf:	68 ac 25 80 00       	push   $0x8025ac
  800dc4:	6a 21                	push   $0x21
  800dc6:	68 cd 25 80 00       	push   $0x8025cd
  800dcb:	e8 7d f3 ff ff       	call   80014d <_panic>
	   } else if (!(pte & PTE_COW)) {
  800dd0:	f6 c6 08             	test   $0x8,%dh
  800dd3:	75 14                	jne    800de9 <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  800dd5:	83 ec 04             	sub    $0x4,%esp
  800dd8:	68 d8 25 80 00       	push   $0x8025d8
  800ddd:	6a 23                	push   $0x23
  800ddf:	68 cd 25 80 00       	push   $0x8025cd
  800de4:	e8 64 f3 ff ff       	call   80014d <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  800de9:	83 ec 04             	sub    $0x4,%esp
  800dec:	6a 07                	push   $0x7
  800dee:	68 00 00 40 00       	push   $0x400000
  800df3:	6a 00                	push   $0x0
  800df5:	e8 b4 fd ff ff       	call   800bae <sys_page_alloc>
  800dfa:	83 c4 10             	add    $0x10,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	79 12                	jns    800e13 <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  800e01:	50                   	push   %eax
  800e02:	68 f5 25 80 00       	push   $0x8025f5
  800e07:	6a 2e                	push   $0x2e
  800e09:	68 cd 25 80 00       	push   $0x8025cd
  800e0e:	e8 3a f3 ff ff       	call   80014d <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800e13:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e19:	83 ec 04             	sub    $0x4,%esp
  800e1c:	68 00 10 00 00       	push   $0x1000
  800e21:	53                   	push   %ebx
  800e22:	68 00 00 40 00       	push   $0x400000
  800e27:	e8 11 fb ff ff       	call   80093d <memmove>
	   if ((r = sys_page_map(0,
  800e2c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e33:	53                   	push   %ebx
  800e34:	6a 00                	push   $0x0
  800e36:	68 00 00 40 00       	push   $0x400000
  800e3b:	6a 00                	push   $0x0
  800e3d:	e8 af fd ff ff       	call   800bf1 <sys_page_map>
  800e42:	83 c4 20             	add    $0x20,%esp
  800e45:	85 c0                	test   %eax,%eax
  800e47:	79 12                	jns    800e5b <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  800e49:	50                   	push   %eax
  800e4a:	68 08 26 80 00       	push   $0x802608
  800e4f:	6a 36                	push   $0x36
  800e51:	68 cd 25 80 00       	push   $0x8025cd
  800e56:	e8 f2 f2 ff ff       	call   80014d <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  800e5b:	83 ec 08             	sub    $0x8,%esp
  800e5e:	68 00 00 40 00       	push   $0x400000
  800e63:	6a 00                	push   $0x0
  800e65:	e8 c9 fd ff ff       	call   800c33 <sys_page_unmap>
  800e6a:	83 c4 10             	add    $0x10,%esp
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	79 12                	jns    800e83 <pgfault+0xe4>
			 panic("unmap %e", r);
  800e71:	50                   	push   %eax
  800e72:	68 18 26 80 00       	push   $0x802618
  800e77:	6a 39                	push   $0x39
  800e79:	68 cd 25 80 00       	push   $0x8025cd
  800e7e:	e8 ca f2 ff ff       	call   80014d <_panic>
	   }
}
  800e83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e86:	c9                   	leave  
  800e87:	c3                   	ret    

00800e88 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
  800e8e:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  800e91:	68 9f 0d 80 00       	push   $0x800d9f
  800e96:	e8 1f 0f 00 00       	call   801dba <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e9b:	b8 07 00 00 00       	mov    $0x7,%eax
  800ea0:	cd 30                	int    $0x30
  800ea2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ea5:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  800ea8:	83 c4 10             	add    $0x10,%esp
  800eab:	85 c0                	test   %eax,%eax
  800ead:	79 15                	jns    800ec4 <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  800eaf:	50                   	push   %eax
  800eb0:	68 21 26 80 00       	push   $0x802621
  800eb5:	68 81 00 00 00       	push   $0x81
  800eba:	68 cd 25 80 00       	push   $0x8025cd
  800ebf:	e8 89 f2 ff ff       	call   80014d <_panic>
  800ec4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800ecb:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  800ecf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ed3:	75 1c                	jne    800ef1 <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  800ed5:	e8 96 fc ff ff       	call   800b70 <sys_getenvid>
  800eda:	25 ff 03 00 00       	and    $0x3ff,%eax
  800edf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ee2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ee7:	a3 08 40 80 00       	mov    %eax,0x804008
			 return envid;
  800eec:	e9 71 01 00 00       	jmp    801062 <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  800ef1:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800ef4:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800efb:	a8 01                	test   $0x1,%al
  800efd:	0f 84 18 01 00 00    	je     80101b <fork+0x193>
  800f03:	89 fb                	mov    %edi,%ebx
  800f05:	c1 e3 0a             	shl    $0xa,%ebx
  800f08:	c1 e7 16             	shl    $0x16,%edi
  800f0b:	be 00 00 00 00       	mov    $0x0,%esi
  800f10:	e9 f4 00 00 00       	jmp    801009 <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  800f15:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800f1b:	0f 84 dc 00 00 00    	je     800ffd <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  800f21:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800f27:	0f 87 cc 00 00 00    	ja     800ff9 <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  800f2d:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f34:	a8 01                	test   $0x1,%al
  800f36:	0f 84 c1 00 00 00    	je     800ffd <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  800f3c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  800f43:	a9 02 08 00 00       	test   $0x802,%eax
  800f48:	74 05                	je     800f4f <fork+0xc7>
  800f4a:	f6 c4 04             	test   $0x4,%ah
  800f4d:	74 3a                	je     800f89 <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  800f4f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800f55:	8b 52 48             	mov    0x48(%edx),%edx
  800f58:	83 ec 0c             	sub    $0xc,%esp
  800f5b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f60:	50                   	push   %eax
  800f61:	57                   	push   %edi
  800f62:	ff 75 dc             	pushl  -0x24(%ebp)
  800f65:	57                   	push   %edi
  800f66:	52                   	push   %edx
  800f67:	e8 85 fc ff ff       	call   800bf1 <sys_page_map>
  800f6c:	83 c4 20             	add    $0x20,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	0f 89 86 00 00 00    	jns    800ffd <fork+0x175>
				    panic("sys_page_map: %e", r);
  800f77:	50                   	push   %eax
  800f78:	68 31 26 80 00       	push   $0x802631
  800f7d:	6a 52                	push   $0x52
  800f7f:	68 cd 25 80 00       	push   $0x8025cd
  800f84:	e8 c4 f1 ff ff       	call   80014d <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  800f89:	25 05 06 00 00       	and    $0x605,%eax
  800f8e:	80 cc 08             	or     $0x8,%ah
  800f91:	89 c1                	mov    %eax,%ecx
  800f93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f96:	a1 08 40 80 00       	mov    0x804008,%eax
  800f9b:	8b 40 48             	mov    0x48(%eax),%eax
  800f9e:	83 ec 0c             	sub    $0xc,%esp
  800fa1:	51                   	push   %ecx
  800fa2:	57                   	push   %edi
  800fa3:	ff 75 dc             	pushl  -0x24(%ebp)
  800fa6:	57                   	push   %edi
  800fa7:	50                   	push   %eax
  800fa8:	e8 44 fc ff ff       	call   800bf1 <sys_page_map>
  800fad:	83 c4 20             	add    $0x20,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	79 12                	jns    800fc6 <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  800fb4:	50                   	push   %eax
  800fb5:	68 31 26 80 00       	push   $0x802631
  800fba:	6a 5d                	push   $0x5d
  800fbc:	68 cd 25 80 00       	push   $0x8025cd
  800fc1:	e8 87 f1 ff ff       	call   80014d <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  800fc6:	a1 08 40 80 00       	mov    0x804008,%eax
  800fcb:	8b 50 48             	mov    0x48(%eax),%edx
  800fce:	8b 40 48             	mov    0x48(%eax),%eax
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fd7:	57                   	push   %edi
  800fd8:	52                   	push   %edx
  800fd9:	57                   	push   %edi
  800fda:	50                   	push   %eax
  800fdb:	e8 11 fc ff ff       	call   800bf1 <sys_page_map>
  800fe0:	83 c4 20             	add    $0x20,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	79 16                	jns    800ffd <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  800fe7:	50                   	push   %eax
  800fe8:	68 31 26 80 00       	push   $0x802631
  800fed:	6a 63                	push   $0x63
  800fef:	68 cd 25 80 00       	push   $0x8025cd
  800ff4:	e8 54 f1 ff ff       	call   80014d <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  800ff9:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  800ffd:	83 c6 01             	add    $0x1,%esi
  801000:	83 c3 01             	add    $0x1,%ebx
  801003:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801009:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  80100f:	7f 0a                	jg     80101b <fork+0x193>
  801011:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801015:	0f 85 fa fe ff ff    	jne    800f15 <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  80101b:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  80101f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801022:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801027:	7f 0a                	jg     801033 <fork+0x1ab>
  801029:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80102d:	0f 85 be fe ff ff    	jne    800ef1 <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801033:	83 ec 08             	sub    $0x8,%esp
  801036:	68 13 1e 80 00       	push   $0x801e13
  80103b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80103e:	56                   	push   %esi
  80103f:	e8 b5 fc ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  801044:	83 c4 0c             	add    $0xc,%esp
  801047:	6a 06                	push   $0x6
  801049:	68 00 f0 bf ee       	push   $0xeebff000
  80104e:	56                   	push   %esi
  80104f:	e8 5a fb ff ff       	call   800bae <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  801054:	83 c4 08             	add    $0x8,%esp
  801057:	6a 02                	push   $0x2
  801059:	56                   	push   %esi
  80105a:	e8 16 fc ff ff       	call   800c75 <sys_env_set_status>

	   return envid;
  80105f:	83 c4 10             	add    $0x10,%esp
}
  801062:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801065:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <sfork>:
// Challenge!
	   int
sfork(void)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  801073:	68 42 26 80 00       	push   $0x802642
  801078:	68 a7 00 00 00       	push   $0xa7
  80107d:	68 cd 25 80 00       	push   $0x8025cd
  801082:	e8 c6 f0 ff ff       	call   80014d <_panic>

00801087 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80108a:	8b 45 08             	mov    0x8(%ebp),%eax
  80108d:	05 00 00 00 30       	add    $0x30000000,%eax
  801092:	c1 e8 0c             	shr    $0xc,%eax
}
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80109a:	8b 45 08             	mov    0x8(%ebp),%eax
  80109d:	05 00 00 00 30       	add    $0x30000000,%eax
  8010a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010a7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    

008010ae <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010b9:	89 c2                	mov    %eax,%edx
  8010bb:	c1 ea 16             	shr    $0x16,%edx
  8010be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c5:	f6 c2 01             	test   $0x1,%dl
  8010c8:	74 11                	je     8010db <fd_alloc+0x2d>
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	c1 ea 0c             	shr    $0xc,%edx
  8010cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d6:	f6 c2 01             	test   $0x1,%dl
  8010d9:	75 09                	jne    8010e4 <fd_alloc+0x36>
			*fd_store = fd;
  8010db:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e2:	eb 17                	jmp    8010fb <fd_alloc+0x4d>
  8010e4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010e9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010ee:	75 c9                	jne    8010b9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010f0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010f6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    

008010fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801103:	83 f8 1f             	cmp    $0x1f,%eax
  801106:	77 36                	ja     80113e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801108:	c1 e0 0c             	shl    $0xc,%eax
  80110b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801110:	89 c2                	mov    %eax,%edx
  801112:	c1 ea 16             	shr    $0x16,%edx
  801115:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80111c:	f6 c2 01             	test   $0x1,%dl
  80111f:	74 24                	je     801145 <fd_lookup+0x48>
  801121:	89 c2                	mov    %eax,%edx
  801123:	c1 ea 0c             	shr    $0xc,%edx
  801126:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80112d:	f6 c2 01             	test   $0x1,%dl
  801130:	74 1a                	je     80114c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801132:	8b 55 0c             	mov    0xc(%ebp),%edx
  801135:	89 02                	mov    %eax,(%edx)
	return 0;
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
  80113c:	eb 13                	jmp    801151 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80113e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801143:	eb 0c                	jmp    801151 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801145:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114a:	eb 05                	jmp    801151 <fd_lookup+0x54>
  80114c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 08             	sub    $0x8,%esp
  801159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115c:	ba d8 26 80 00       	mov    $0x8026d8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801161:	eb 13                	jmp    801176 <dev_lookup+0x23>
  801163:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801166:	39 08                	cmp    %ecx,(%eax)
  801168:	75 0c                	jne    801176 <dev_lookup+0x23>
			*dev = devtab[i];
  80116a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80116f:	b8 00 00 00 00       	mov    $0x0,%eax
  801174:	eb 2e                	jmp    8011a4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801176:	8b 02                	mov    (%edx),%eax
  801178:	85 c0                	test   %eax,%eax
  80117a:	75 e7                	jne    801163 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80117c:	a1 08 40 80 00       	mov    0x804008,%eax
  801181:	8b 40 48             	mov    0x48(%eax),%eax
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	51                   	push   %ecx
  801188:	50                   	push   %eax
  801189:	68 58 26 80 00       	push   $0x802658
  80118e:	e8 93 f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  801193:	8b 45 0c             	mov    0xc(%ebp),%eax
  801196:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011a4:	c9                   	leave  
  8011a5:	c3                   	ret    

008011a6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	56                   	push   %esi
  8011aa:	53                   	push   %ebx
  8011ab:	83 ec 10             	sub    $0x10,%esp
  8011ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b7:	50                   	push   %eax
  8011b8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011be:	c1 e8 0c             	shr    $0xc,%eax
  8011c1:	50                   	push   %eax
  8011c2:	e8 36 ff ff ff       	call   8010fd <fd_lookup>
  8011c7:	83 c4 08             	add    $0x8,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 05                	js     8011d3 <fd_close+0x2d>
	    || fd != fd2)
  8011ce:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011d1:	74 0c                	je     8011df <fd_close+0x39>
		return (must_exist ? r : 0);
  8011d3:	84 db                	test   %bl,%bl
  8011d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011da:	0f 44 c2             	cmove  %edx,%eax
  8011dd:	eb 41                	jmp    801220 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011df:	83 ec 08             	sub    $0x8,%esp
  8011e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	ff 36                	pushl  (%esi)
  8011e8:	e8 66 ff ff ff       	call   801153 <dev_lookup>
  8011ed:	89 c3                	mov    %eax,%ebx
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	78 1a                	js     801210 <fd_close+0x6a>
		if (dev->dev_close)
  8011f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011fc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801201:	85 c0                	test   %eax,%eax
  801203:	74 0b                	je     801210 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801205:	83 ec 0c             	sub    $0xc,%esp
  801208:	56                   	push   %esi
  801209:	ff d0                	call   *%eax
  80120b:	89 c3                	mov    %eax,%ebx
  80120d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	56                   	push   %esi
  801214:	6a 00                	push   $0x0
  801216:	e8 18 fa ff ff       	call   800c33 <sys_page_unmap>
	return r;
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	89 d8                	mov    %ebx,%eax
}
  801220:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    

00801227 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801230:	50                   	push   %eax
  801231:	ff 75 08             	pushl  0x8(%ebp)
  801234:	e8 c4 fe ff ff       	call   8010fd <fd_lookup>
  801239:	83 c4 08             	add    $0x8,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 10                	js     801250 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	6a 01                	push   $0x1
  801245:	ff 75 f4             	pushl  -0xc(%ebp)
  801248:	e8 59 ff ff ff       	call   8011a6 <fd_close>
  80124d:	83 c4 10             	add    $0x10,%esp
}
  801250:	c9                   	leave  
  801251:	c3                   	ret    

00801252 <close_all>:

void
close_all(void)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	53                   	push   %ebx
  801256:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801259:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80125e:	83 ec 0c             	sub    $0xc,%esp
  801261:	53                   	push   %ebx
  801262:	e8 c0 ff ff ff       	call   801227 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801267:	83 c3 01             	add    $0x1,%ebx
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	83 fb 20             	cmp    $0x20,%ebx
  801270:	75 ec                	jne    80125e <close_all+0xc>
		close(i);
}
  801272:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801275:	c9                   	leave  
  801276:	c3                   	ret    

00801277 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	57                   	push   %edi
  80127b:	56                   	push   %esi
  80127c:	53                   	push   %ebx
  80127d:	83 ec 2c             	sub    $0x2c,%esp
  801280:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801283:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801286:	50                   	push   %eax
  801287:	ff 75 08             	pushl  0x8(%ebp)
  80128a:	e8 6e fe ff ff       	call   8010fd <fd_lookup>
  80128f:	83 c4 08             	add    $0x8,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	0f 88 c1 00 00 00    	js     80135b <dup+0xe4>
		return r;
	close(newfdnum);
  80129a:	83 ec 0c             	sub    $0xc,%esp
  80129d:	56                   	push   %esi
  80129e:	e8 84 ff ff ff       	call   801227 <close>

	newfd = INDEX2FD(newfdnum);
  8012a3:	89 f3                	mov    %esi,%ebx
  8012a5:	c1 e3 0c             	shl    $0xc,%ebx
  8012a8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012ae:	83 c4 04             	add    $0x4,%esp
  8012b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b4:	e8 de fd ff ff       	call   801097 <fd2data>
  8012b9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012bb:	89 1c 24             	mov    %ebx,(%esp)
  8012be:	e8 d4 fd ff ff       	call   801097 <fd2data>
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012c9:	89 f8                	mov    %edi,%eax
  8012cb:	c1 e8 16             	shr    $0x16,%eax
  8012ce:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012d5:	a8 01                	test   $0x1,%al
  8012d7:	74 37                	je     801310 <dup+0x99>
  8012d9:	89 f8                	mov    %edi,%eax
  8012db:	c1 e8 0c             	shr    $0xc,%eax
  8012de:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e5:	f6 c2 01             	test   $0x1,%dl
  8012e8:	74 26                	je     801310 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f1:	83 ec 0c             	sub    $0xc,%esp
  8012f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f9:	50                   	push   %eax
  8012fa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012fd:	6a 00                	push   $0x0
  8012ff:	57                   	push   %edi
  801300:	6a 00                	push   $0x0
  801302:	e8 ea f8 ff ff       	call   800bf1 <sys_page_map>
  801307:	89 c7                	mov    %eax,%edi
  801309:	83 c4 20             	add    $0x20,%esp
  80130c:	85 c0                	test   %eax,%eax
  80130e:	78 2e                	js     80133e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801310:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801313:	89 d0                	mov    %edx,%eax
  801315:	c1 e8 0c             	shr    $0xc,%eax
  801318:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131f:	83 ec 0c             	sub    $0xc,%esp
  801322:	25 07 0e 00 00       	and    $0xe07,%eax
  801327:	50                   	push   %eax
  801328:	53                   	push   %ebx
  801329:	6a 00                	push   $0x0
  80132b:	52                   	push   %edx
  80132c:	6a 00                	push   $0x0
  80132e:	e8 be f8 ff ff       	call   800bf1 <sys_page_map>
  801333:	89 c7                	mov    %eax,%edi
  801335:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801338:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80133a:	85 ff                	test   %edi,%edi
  80133c:	79 1d                	jns    80135b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80133e:	83 ec 08             	sub    $0x8,%esp
  801341:	53                   	push   %ebx
  801342:	6a 00                	push   $0x0
  801344:	e8 ea f8 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801349:	83 c4 08             	add    $0x8,%esp
  80134c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80134f:	6a 00                	push   $0x0
  801351:	e8 dd f8 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	89 f8                	mov    %edi,%eax
}
  80135b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80135e:	5b                   	pop    %ebx
  80135f:	5e                   	pop    %esi
  801360:	5f                   	pop    %edi
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    

00801363 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	53                   	push   %ebx
  801367:	83 ec 14             	sub    $0x14,%esp
  80136a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801370:	50                   	push   %eax
  801371:	53                   	push   %ebx
  801372:	e8 86 fd ff ff       	call   8010fd <fd_lookup>
  801377:	83 c4 08             	add    $0x8,%esp
  80137a:	89 c2                	mov    %eax,%edx
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 6d                	js     8013ed <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801386:	50                   	push   %eax
  801387:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138a:	ff 30                	pushl  (%eax)
  80138c:	e8 c2 fd ff ff       	call   801153 <dev_lookup>
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	85 c0                	test   %eax,%eax
  801396:	78 4c                	js     8013e4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801398:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80139b:	8b 42 08             	mov    0x8(%edx),%eax
  80139e:	83 e0 03             	and    $0x3,%eax
  8013a1:	83 f8 01             	cmp    $0x1,%eax
  8013a4:	75 21                	jne    8013c7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ab:	8b 40 48             	mov    0x48(%eax),%eax
  8013ae:	83 ec 04             	sub    $0x4,%esp
  8013b1:	53                   	push   %ebx
  8013b2:	50                   	push   %eax
  8013b3:	68 9c 26 80 00       	push   $0x80269c
  8013b8:	e8 69 ee ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013c5:	eb 26                	jmp    8013ed <read+0x8a>
	}
	if (!dev->dev_read)
  8013c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ca:	8b 40 08             	mov    0x8(%eax),%eax
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	74 17                	je     8013e8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013d1:	83 ec 04             	sub    $0x4,%esp
  8013d4:	ff 75 10             	pushl  0x10(%ebp)
  8013d7:	ff 75 0c             	pushl  0xc(%ebp)
  8013da:	52                   	push   %edx
  8013db:	ff d0                	call   *%eax
  8013dd:	89 c2                	mov    %eax,%edx
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	eb 09                	jmp    8013ed <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e4:	89 c2                	mov    %eax,%edx
  8013e6:	eb 05                	jmp    8013ed <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013ed:	89 d0                	mov    %edx,%eax
  8013ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    

008013f4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	57                   	push   %edi
  8013f8:	56                   	push   %esi
  8013f9:	53                   	push   %ebx
  8013fa:	83 ec 0c             	sub    $0xc,%esp
  8013fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801400:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801403:	bb 00 00 00 00       	mov    $0x0,%ebx
  801408:	eb 21                	jmp    80142b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80140a:	83 ec 04             	sub    $0x4,%esp
  80140d:	89 f0                	mov    %esi,%eax
  80140f:	29 d8                	sub    %ebx,%eax
  801411:	50                   	push   %eax
  801412:	89 d8                	mov    %ebx,%eax
  801414:	03 45 0c             	add    0xc(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	57                   	push   %edi
  801419:	e8 45 ff ff ff       	call   801363 <read>
		if (m < 0)
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 10                	js     801435 <readn+0x41>
			return m;
		if (m == 0)
  801425:	85 c0                	test   %eax,%eax
  801427:	74 0a                	je     801433 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801429:	01 c3                	add    %eax,%ebx
  80142b:	39 f3                	cmp    %esi,%ebx
  80142d:	72 db                	jb     80140a <readn+0x16>
  80142f:	89 d8                	mov    %ebx,%eax
  801431:	eb 02                	jmp    801435 <readn+0x41>
  801433:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801435:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801438:	5b                   	pop    %ebx
  801439:	5e                   	pop    %esi
  80143a:	5f                   	pop    %edi
  80143b:	5d                   	pop    %ebp
  80143c:	c3                   	ret    

0080143d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	53                   	push   %ebx
  801441:	83 ec 14             	sub    $0x14,%esp
  801444:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801447:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144a:	50                   	push   %eax
  80144b:	53                   	push   %ebx
  80144c:	e8 ac fc ff ff       	call   8010fd <fd_lookup>
  801451:	83 c4 08             	add    $0x8,%esp
  801454:	89 c2                	mov    %eax,%edx
  801456:	85 c0                	test   %eax,%eax
  801458:	78 68                	js     8014c2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801464:	ff 30                	pushl  (%eax)
  801466:	e8 e8 fc ff ff       	call   801153 <dev_lookup>
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 47                	js     8014b9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801472:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801475:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801479:	75 21                	jne    80149c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80147b:	a1 08 40 80 00       	mov    0x804008,%eax
  801480:	8b 40 48             	mov    0x48(%eax),%eax
  801483:	83 ec 04             	sub    $0x4,%esp
  801486:	53                   	push   %ebx
  801487:	50                   	push   %eax
  801488:	68 b8 26 80 00       	push   $0x8026b8
  80148d:	e8 94 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80149a:	eb 26                	jmp    8014c2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80149c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80149f:	8b 52 0c             	mov    0xc(%edx),%edx
  8014a2:	85 d2                	test   %edx,%edx
  8014a4:	74 17                	je     8014bd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014a6:	83 ec 04             	sub    $0x4,%esp
  8014a9:	ff 75 10             	pushl  0x10(%ebp)
  8014ac:	ff 75 0c             	pushl  0xc(%ebp)
  8014af:	50                   	push   %eax
  8014b0:	ff d2                	call   *%edx
  8014b2:	89 c2                	mov    %eax,%edx
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	eb 09                	jmp    8014c2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b9:	89 c2                	mov    %eax,%edx
  8014bb:	eb 05                	jmp    8014c2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014c2:	89 d0                	mov    %edx,%eax
  8014c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c7:	c9                   	leave  
  8014c8:	c3                   	ret    

008014c9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014cf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	ff 75 08             	pushl  0x8(%ebp)
  8014d6:	e8 22 fc ff ff       	call   8010fd <fd_lookup>
  8014db:	83 c4 08             	add    $0x8,%esp
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 0e                	js     8014f0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 14             	sub    $0x14,%esp
  8014f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ff:	50                   	push   %eax
  801500:	53                   	push   %ebx
  801501:	e8 f7 fb ff ff       	call   8010fd <fd_lookup>
  801506:	83 c4 08             	add    $0x8,%esp
  801509:	89 c2                	mov    %eax,%edx
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 65                	js     801574 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150f:	83 ec 08             	sub    $0x8,%esp
  801512:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801515:	50                   	push   %eax
  801516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801519:	ff 30                	pushl  (%eax)
  80151b:	e8 33 fc ff ff       	call   801153 <dev_lookup>
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	85 c0                	test   %eax,%eax
  801525:	78 44                	js     80156b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152e:	75 21                	jne    801551 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801530:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801535:	8b 40 48             	mov    0x48(%eax),%eax
  801538:	83 ec 04             	sub    $0x4,%esp
  80153b:	53                   	push   %ebx
  80153c:	50                   	push   %eax
  80153d:	68 78 26 80 00       	push   $0x802678
  801542:	e8 df ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154f:	eb 23                	jmp    801574 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801551:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801554:	8b 52 18             	mov    0x18(%edx),%edx
  801557:	85 d2                	test   %edx,%edx
  801559:	74 14                	je     80156f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	ff 75 0c             	pushl  0xc(%ebp)
  801561:	50                   	push   %eax
  801562:	ff d2                	call   *%edx
  801564:	89 c2                	mov    %eax,%edx
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	eb 09                	jmp    801574 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156b:	89 c2                	mov    %eax,%edx
  80156d:	eb 05                	jmp    801574 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80156f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801574:	89 d0                	mov    %edx,%eax
  801576:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801579:	c9                   	leave  
  80157a:	c3                   	ret    

0080157b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	53                   	push   %ebx
  80157f:	83 ec 14             	sub    $0x14,%esp
  801582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801585:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	ff 75 08             	pushl  0x8(%ebp)
  80158c:	e8 6c fb ff ff       	call   8010fd <fd_lookup>
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	89 c2                	mov    %eax,%edx
  801596:	85 c0                	test   %eax,%eax
  801598:	78 58                	js     8015f2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a4:	ff 30                	pushl  (%eax)
  8015a6:	e8 a8 fb ff ff       	call   801153 <dev_lookup>
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 37                	js     8015e9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015b9:	74 32                	je     8015ed <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015bb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015be:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015c5:	00 00 00 
	stat->st_isdir = 0;
  8015c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015cf:	00 00 00 
	stat->st_dev = dev;
  8015d2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015d8:	83 ec 08             	sub    $0x8,%esp
  8015db:	53                   	push   %ebx
  8015dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8015df:	ff 50 14             	call   *0x14(%eax)
  8015e2:	89 c2                	mov    %eax,%edx
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	eb 09                	jmp    8015f2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e9:	89 c2                	mov    %eax,%edx
  8015eb:	eb 05                	jmp    8015f2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015f2:	89 d0                	mov    %edx,%eax
  8015f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f7:	c9                   	leave  
  8015f8:	c3                   	ret    

008015f9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	56                   	push   %esi
  8015fd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015fe:	83 ec 08             	sub    $0x8,%esp
  801601:	6a 00                	push   $0x0
  801603:	ff 75 08             	pushl  0x8(%ebp)
  801606:	e8 2c 02 00 00       	call   801837 <open>
  80160b:	89 c3                	mov    %eax,%ebx
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	85 c0                	test   %eax,%eax
  801612:	78 1b                	js     80162f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	ff 75 0c             	pushl  0xc(%ebp)
  80161a:	50                   	push   %eax
  80161b:	e8 5b ff ff ff       	call   80157b <fstat>
  801620:	89 c6                	mov    %eax,%esi
	close(fd);
  801622:	89 1c 24             	mov    %ebx,(%esp)
  801625:	e8 fd fb ff ff       	call   801227 <close>
	return r;
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	89 f0                	mov    %esi,%eax
}
  80162f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801632:	5b                   	pop    %ebx
  801633:	5e                   	pop    %esi
  801634:	5d                   	pop    %ebp
  801635:	c3                   	ret    

00801636 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	56                   	push   %esi
  80163a:	53                   	push   %ebx
  80163b:	89 c6                	mov    %eax,%esi
  80163d:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  80163f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801646:	75 12                	jne    80165a <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	6a 01                	push   $0x1
  80164d:	e8 9a 08 00 00       	call   801eec <ipc_find_env>
  801652:	a3 00 40 80 00       	mov    %eax,0x804000
  801657:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80165a:	6a 07                	push   $0x7
  80165c:	68 00 50 80 00       	push   $0x805000
  801661:	56                   	push   %esi
  801662:	ff 35 00 40 80 00    	pushl  0x804000
  801668:	e8 2b 08 00 00       	call   801e98 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  80166d:	83 c4 0c             	add    $0xc,%esp
  801670:	6a 00                	push   $0x0
  801672:	53                   	push   %ebx
  801673:	6a 00                	push   $0x0
  801675:	e8 bf 07 00 00       	call   801e39 <ipc_recv>
}
  80167a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167d:	5b                   	pop    %ebx
  80167e:	5e                   	pop    %esi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801687:	8b 45 08             	mov    0x8(%ebp),%eax
  80168a:	8b 40 0c             	mov    0xc(%eax),%eax
  80168d:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  801692:	8b 45 0c             	mov    0xc(%ebp),%eax
  801695:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80169a:	ba 00 00 00 00       	mov    $0x0,%edx
  80169f:	b8 02 00 00 00       	mov    $0x2,%eax
  8016a4:	e8 8d ff ff ff       	call   801636 <fsipc>
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b7:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  8016bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c1:	b8 06 00 00 00       	mov    $0x6,%eax
  8016c6:	e8 6b ff ff ff       	call   801636 <fsipc>
}
  8016cb:	c9                   	leave  
  8016cc:	c3                   	ret    

008016cd <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	53                   	push   %ebx
  8016d1:	83 ec 04             	sub    $0x4,%esp
  8016d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016da:	8b 40 0c             	mov    0xc(%eax),%eax
  8016dd:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8016ec:	e8 45 ff ff ff       	call   801636 <fsipc>
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 2c                	js     801721 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016f5:	83 ec 08             	sub    $0x8,%esp
  8016f8:	68 00 50 80 00       	push   $0x805000
  8016fd:	53                   	push   %ebx
  8016fe:	e8 a8 f0 ff ff       	call   8007ab <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  801703:	a1 80 50 80 00       	mov    0x805080,%eax
  801708:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80170e:	a1 84 50 80 00       	mov    0x805084,%eax
  801713:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801721:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801724:	c9                   	leave  
  801725:	c3                   	ret    

00801726 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	53                   	push   %ebx
  80172a:	83 ec 08             	sub    $0x8,%esp
  80172d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  801730:	8b 45 08             	mov    0x8(%ebp),%eax
  801733:	8b 40 0c             	mov    0xc(%eax),%eax
  801736:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  80173b:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  801741:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801747:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  80174c:	0f 46 c3             	cmovbe %ebx,%eax
  80174f:	50                   	push   %eax
  801750:	ff 75 0c             	pushl  0xc(%ebp)
  801753:	68 08 50 80 00       	push   $0x805008
  801758:	e8 e0 f1 ff ff       	call   80093d <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  80175d:	ba 00 00 00 00       	mov    $0x0,%edx
  801762:	b8 04 00 00 00       	mov    $0x4,%eax
  801767:	e8 ca fe ff ff       	call   801636 <fsipc>
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 3d                	js     8017b0 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  801773:	39 c3                	cmp    %eax,%ebx
  801775:	73 19                	jae    801790 <devfile_write+0x6a>
  801777:	68 e8 26 80 00       	push   $0x8026e8
  80177c:	68 ef 26 80 00       	push   $0x8026ef
  801781:	68 9a 00 00 00       	push   $0x9a
  801786:	68 04 27 80 00       	push   $0x802704
  80178b:	e8 bd e9 ff ff       	call   80014d <_panic>
	   assert (r <= bytes_written);
  801790:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801795:	7e 19                	jle    8017b0 <devfile_write+0x8a>
  801797:	68 0f 27 80 00       	push   $0x80270f
  80179c:	68 ef 26 80 00       	push   $0x8026ef
  8017a1:	68 9b 00 00 00       	push   $0x9b
  8017a6:	68 04 27 80 00       	push   $0x802704
  8017ab:	e8 9d e9 ff ff       	call   80014d <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  8017b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    

008017b5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	56                   	push   %esi
  8017b9:	53                   	push   %ebx
  8017ba:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c3:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  8017c8:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d8:	e8 59 fe ff ff       	call   801636 <fsipc>
  8017dd:	89 c3                	mov    %eax,%ebx
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 4b                	js     80182e <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  8017e3:	39 c6                	cmp    %eax,%esi
  8017e5:	73 16                	jae    8017fd <devfile_read+0x48>
  8017e7:	68 e8 26 80 00       	push   $0x8026e8
  8017ec:	68 ef 26 80 00       	push   $0x8026ef
  8017f1:	6a 7c                	push   $0x7c
  8017f3:	68 04 27 80 00       	push   $0x802704
  8017f8:	e8 50 e9 ff ff       	call   80014d <_panic>
	   assert(r <= PGSIZE);
  8017fd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801802:	7e 16                	jle    80181a <devfile_read+0x65>
  801804:	68 22 27 80 00       	push   $0x802722
  801809:	68 ef 26 80 00       	push   $0x8026ef
  80180e:	6a 7d                	push   $0x7d
  801810:	68 04 27 80 00       	push   $0x802704
  801815:	e8 33 e9 ff ff       	call   80014d <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80181a:	83 ec 04             	sub    $0x4,%esp
  80181d:	50                   	push   %eax
  80181e:	68 00 50 80 00       	push   $0x805000
  801823:	ff 75 0c             	pushl  0xc(%ebp)
  801826:	e8 12 f1 ff ff       	call   80093d <memmove>
	   return r;
  80182b:	83 c4 10             	add    $0x10,%esp
}
  80182e:	89 d8                	mov    %ebx,%eax
  801830:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801833:	5b                   	pop    %ebx
  801834:	5e                   	pop    %esi
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	53                   	push   %ebx
  80183b:	83 ec 20             	sub    $0x20,%esp
  80183e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  801841:	53                   	push   %ebx
  801842:	e8 2b ef ff ff       	call   800772 <strlen>
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80184f:	7f 67                	jg     8018b8 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801851:	83 ec 0c             	sub    $0xc,%esp
  801854:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801857:	50                   	push   %eax
  801858:	e8 51 f8 ff ff       	call   8010ae <fd_alloc>
  80185d:	83 c4 10             	add    $0x10,%esp
			 return r;
  801860:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801862:	85 c0                	test   %eax,%eax
  801864:	78 57                	js     8018bd <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	53                   	push   %ebx
  80186a:	68 00 50 80 00       	push   $0x805000
  80186f:	e8 37 ef ff ff       	call   8007ab <strcpy>
	   fsipcbuf.open.req_omode = mode;
  801874:	8b 45 0c             	mov    0xc(%ebp),%eax
  801877:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80187c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187f:	b8 01 00 00 00       	mov    $0x1,%eax
  801884:	e8 ad fd ff ff       	call   801636 <fsipc>
  801889:	89 c3                	mov    %eax,%ebx
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	79 14                	jns    8018a6 <open+0x6f>
			 fd_close(fd, 0);
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	6a 00                	push   $0x0
  801897:	ff 75 f4             	pushl  -0xc(%ebp)
  80189a:	e8 07 f9 ff ff       	call   8011a6 <fd_close>
			 return r;
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	89 da                	mov    %ebx,%edx
  8018a4:	eb 17                	jmp    8018bd <open+0x86>
	   }

	   return fd2num(fd);
  8018a6:	83 ec 0c             	sub    $0xc,%esp
  8018a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ac:	e8 d6 f7 ff ff       	call   801087 <fd2num>
  8018b1:	89 c2                	mov    %eax,%edx
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	eb 05                	jmp    8018bd <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  8018b8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  8018bd:	89 d0                	mov    %edx,%eax
  8018bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  8018ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cf:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d4:	e8 5d fd ff ff       	call   801636 <fsipc>
}
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	56                   	push   %esi
  8018df:	53                   	push   %ebx
  8018e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018e3:	83 ec 0c             	sub    $0xc,%esp
  8018e6:	ff 75 08             	pushl  0x8(%ebp)
  8018e9:	e8 a9 f7 ff ff       	call   801097 <fd2data>
  8018ee:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018f0:	83 c4 08             	add    $0x8,%esp
  8018f3:	68 2e 27 80 00       	push   $0x80272e
  8018f8:	53                   	push   %ebx
  8018f9:	e8 ad ee ff ff       	call   8007ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018fe:	8b 46 04             	mov    0x4(%esi),%eax
  801901:	2b 06                	sub    (%esi),%eax
  801903:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801909:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801910:	00 00 00 
	stat->st_dev = &devpipe;
  801913:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80191a:	30 80 00 
	return 0;
}
  80191d:	b8 00 00 00 00       	mov    $0x0,%eax
  801922:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801925:	5b                   	pop    %ebx
  801926:	5e                   	pop    %esi
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	53                   	push   %ebx
  80192d:	83 ec 0c             	sub    $0xc,%esp
  801930:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801933:	53                   	push   %ebx
  801934:	6a 00                	push   $0x0
  801936:	e8 f8 f2 ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80193b:	89 1c 24             	mov    %ebx,(%esp)
  80193e:	e8 54 f7 ff ff       	call   801097 <fd2data>
  801943:	83 c4 08             	add    $0x8,%esp
  801946:	50                   	push   %eax
  801947:	6a 00                	push   $0x0
  801949:	e8 e5 f2 ff ff       	call   800c33 <sys_page_unmap>
}
  80194e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	57                   	push   %edi
  801957:	56                   	push   %esi
  801958:	53                   	push   %ebx
  801959:	83 ec 1c             	sub    $0x1c,%esp
  80195c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80195f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801961:	a1 08 40 80 00       	mov    0x804008,%eax
  801966:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801969:	83 ec 0c             	sub    $0xc,%esp
  80196c:	ff 75 e0             	pushl  -0x20(%ebp)
  80196f:	e8 b1 05 00 00       	call   801f25 <pageref>
  801974:	89 c3                	mov    %eax,%ebx
  801976:	89 3c 24             	mov    %edi,(%esp)
  801979:	e8 a7 05 00 00       	call   801f25 <pageref>
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	39 c3                	cmp    %eax,%ebx
  801983:	0f 94 c1             	sete   %cl
  801986:	0f b6 c9             	movzbl %cl,%ecx
  801989:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80198c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801992:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801995:	39 ce                	cmp    %ecx,%esi
  801997:	74 1b                	je     8019b4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801999:	39 c3                	cmp    %eax,%ebx
  80199b:	75 c4                	jne    801961 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80199d:	8b 42 58             	mov    0x58(%edx),%eax
  8019a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019a3:	50                   	push   %eax
  8019a4:	56                   	push   %esi
  8019a5:	68 35 27 80 00       	push   $0x802735
  8019aa:	e8 77 e8 ff ff       	call   800226 <cprintf>
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	eb ad                	jmp    801961 <_pipeisclosed+0xe>
	}
}
  8019b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5f                   	pop    %edi
  8019bd:	5d                   	pop    %ebp
  8019be:	c3                   	ret    

008019bf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	57                   	push   %edi
  8019c3:	56                   	push   %esi
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 28             	sub    $0x28,%esp
  8019c8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019cb:	56                   	push   %esi
  8019cc:	e8 c6 f6 ff ff       	call   801097 <fd2data>
  8019d1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	bf 00 00 00 00       	mov    $0x0,%edi
  8019db:	eb 4b                	jmp    801a28 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019dd:	89 da                	mov    %ebx,%edx
  8019df:	89 f0                	mov    %esi,%eax
  8019e1:	e8 6d ff ff ff       	call   801953 <_pipeisclosed>
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	75 48                	jne    801a32 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019ea:	e8 a0 f1 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019ef:	8b 43 04             	mov    0x4(%ebx),%eax
  8019f2:	8b 0b                	mov    (%ebx),%ecx
  8019f4:	8d 51 20             	lea    0x20(%ecx),%edx
  8019f7:	39 d0                	cmp    %edx,%eax
  8019f9:	73 e2                	jae    8019dd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019fe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a02:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a05:	89 c2                	mov    %eax,%edx
  801a07:	c1 fa 1f             	sar    $0x1f,%edx
  801a0a:	89 d1                	mov    %edx,%ecx
  801a0c:	c1 e9 1b             	shr    $0x1b,%ecx
  801a0f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a12:	83 e2 1f             	and    $0x1f,%edx
  801a15:	29 ca                	sub    %ecx,%edx
  801a17:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a1b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a1f:	83 c0 01             	add    $0x1,%eax
  801a22:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a25:	83 c7 01             	add    $0x1,%edi
  801a28:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a2b:	75 c2                	jne    8019ef <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a2d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a30:	eb 05                	jmp    801a37 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a32:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3a:	5b                   	pop    %ebx
  801a3b:	5e                   	pop    %esi
  801a3c:	5f                   	pop    %edi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    

00801a3f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	57                   	push   %edi
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	83 ec 18             	sub    $0x18,%esp
  801a48:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a4b:	57                   	push   %edi
  801a4c:	e8 46 f6 ff ff       	call   801097 <fd2data>
  801a51:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a53:	83 c4 10             	add    $0x10,%esp
  801a56:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a5b:	eb 3d                	jmp    801a9a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a5d:	85 db                	test   %ebx,%ebx
  801a5f:	74 04                	je     801a65 <devpipe_read+0x26>
				return i;
  801a61:	89 d8                	mov    %ebx,%eax
  801a63:	eb 44                	jmp    801aa9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a65:	89 f2                	mov    %esi,%edx
  801a67:	89 f8                	mov    %edi,%eax
  801a69:	e8 e5 fe ff ff       	call   801953 <_pipeisclosed>
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	75 32                	jne    801aa4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a72:	e8 18 f1 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a77:	8b 06                	mov    (%esi),%eax
  801a79:	3b 46 04             	cmp    0x4(%esi),%eax
  801a7c:	74 df                	je     801a5d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a7e:	99                   	cltd   
  801a7f:	c1 ea 1b             	shr    $0x1b,%edx
  801a82:	01 d0                	add    %edx,%eax
  801a84:	83 e0 1f             	and    $0x1f,%eax
  801a87:	29 d0                	sub    %edx,%eax
  801a89:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a91:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a94:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a97:	83 c3 01             	add    $0x1,%ebx
  801a9a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a9d:	75 d8                	jne    801a77 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a9f:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa2:	eb 05                	jmp    801aa9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5f                   	pop    %edi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	56                   	push   %esi
  801ab5:	53                   	push   %ebx
  801ab6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ab9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abc:	50                   	push   %eax
  801abd:	e8 ec f5 ff ff       	call   8010ae <fd_alloc>
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	89 c2                	mov    %eax,%edx
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	0f 88 2c 01 00 00    	js     801bfb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801acf:	83 ec 04             	sub    $0x4,%esp
  801ad2:	68 07 04 00 00       	push   $0x407
  801ad7:	ff 75 f4             	pushl  -0xc(%ebp)
  801ada:	6a 00                	push   $0x0
  801adc:	e8 cd f0 ff ff       	call   800bae <sys_page_alloc>
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	89 c2                	mov    %eax,%edx
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	0f 88 0d 01 00 00    	js     801bfb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801af4:	50                   	push   %eax
  801af5:	e8 b4 f5 ff ff       	call   8010ae <fd_alloc>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	85 c0                	test   %eax,%eax
  801b01:	0f 88 e2 00 00 00    	js     801be9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b07:	83 ec 04             	sub    $0x4,%esp
  801b0a:	68 07 04 00 00       	push   $0x407
  801b0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b12:	6a 00                	push   $0x0
  801b14:	e8 95 f0 ff ff       	call   800bae <sys_page_alloc>
  801b19:	89 c3                	mov    %eax,%ebx
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	0f 88 c3 00 00 00    	js     801be9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b26:	83 ec 0c             	sub    $0xc,%esp
  801b29:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2c:	e8 66 f5 ff ff       	call   801097 <fd2data>
  801b31:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b33:	83 c4 0c             	add    $0xc,%esp
  801b36:	68 07 04 00 00       	push   $0x407
  801b3b:	50                   	push   %eax
  801b3c:	6a 00                	push   $0x0
  801b3e:	e8 6b f0 ff ff       	call   800bae <sys_page_alloc>
  801b43:	89 c3                	mov    %eax,%ebx
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	0f 88 89 00 00 00    	js     801bd9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b50:	83 ec 0c             	sub    $0xc,%esp
  801b53:	ff 75 f0             	pushl  -0x10(%ebp)
  801b56:	e8 3c f5 ff ff       	call   801097 <fd2data>
  801b5b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b62:	50                   	push   %eax
  801b63:	6a 00                	push   $0x0
  801b65:	56                   	push   %esi
  801b66:	6a 00                	push   $0x0
  801b68:	e8 84 f0 ff ff       	call   800bf1 <sys_page_map>
  801b6d:	89 c3                	mov    %eax,%ebx
  801b6f:	83 c4 20             	add    $0x20,%esp
  801b72:	85 c0                	test   %eax,%eax
  801b74:	78 55                	js     801bcb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b76:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b84:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b8b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b94:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b99:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ba0:	83 ec 0c             	sub    $0xc,%esp
  801ba3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba6:	e8 dc f4 ff ff       	call   801087 <fd2num>
  801bab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bae:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bb0:	83 c4 04             	add    $0x4,%esp
  801bb3:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb6:	e8 cc f4 ff ff       	call   801087 <fd2num>
  801bbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbe:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc9:	eb 30                	jmp    801bfb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bcb:	83 ec 08             	sub    $0x8,%esp
  801bce:	56                   	push   %esi
  801bcf:	6a 00                	push   $0x0
  801bd1:	e8 5d f0 ff ff       	call   800c33 <sys_page_unmap>
  801bd6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bd9:	83 ec 08             	sub    $0x8,%esp
  801bdc:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdf:	6a 00                	push   $0x0
  801be1:	e8 4d f0 ff ff       	call   800c33 <sys_page_unmap>
  801be6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801be9:	83 ec 08             	sub    $0x8,%esp
  801bec:	ff 75 f4             	pushl  -0xc(%ebp)
  801bef:	6a 00                	push   $0x0
  801bf1:	e8 3d f0 ff ff       	call   800c33 <sys_page_unmap>
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bfb:	89 d0                	mov    %edx,%eax
  801bfd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    

00801c04 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0d:	50                   	push   %eax
  801c0e:	ff 75 08             	pushl  0x8(%ebp)
  801c11:	e8 e7 f4 ff ff       	call   8010fd <fd_lookup>
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	78 18                	js     801c35 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c1d:	83 ec 0c             	sub    $0xc,%esp
  801c20:	ff 75 f4             	pushl  -0xc(%ebp)
  801c23:	e8 6f f4 ff ff       	call   801097 <fd2data>
	return _pipeisclosed(fd, p);
  801c28:	89 c2                	mov    %eax,%edx
  801c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2d:	e8 21 fd ff ff       	call   801953 <_pipeisclosed>
  801c32:	83 c4 10             	add    $0x10,%esp
}
  801c35:	c9                   	leave  
  801c36:	c3                   	ret    

00801c37 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    

00801c41 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c47:	68 4d 27 80 00       	push   $0x80274d
  801c4c:	ff 75 0c             	pushl  0xc(%ebp)
  801c4f:	e8 57 eb ff ff       	call   8007ab <strcpy>
	return 0;
}
  801c54:	b8 00 00 00 00       	mov    $0x0,%eax
  801c59:	c9                   	leave  
  801c5a:	c3                   	ret    

00801c5b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	57                   	push   %edi
  801c5f:	56                   	push   %esi
  801c60:	53                   	push   %ebx
  801c61:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c67:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c6c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c72:	eb 2d                	jmp    801ca1 <devcons_write+0x46>
		m = n - tot;
  801c74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c77:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c79:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c7c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c81:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c84:	83 ec 04             	sub    $0x4,%esp
  801c87:	53                   	push   %ebx
  801c88:	03 45 0c             	add    0xc(%ebp),%eax
  801c8b:	50                   	push   %eax
  801c8c:	57                   	push   %edi
  801c8d:	e8 ab ec ff ff       	call   80093d <memmove>
		sys_cputs(buf, m);
  801c92:	83 c4 08             	add    $0x8,%esp
  801c95:	53                   	push   %ebx
  801c96:	57                   	push   %edi
  801c97:	e8 56 ee ff ff       	call   800af2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c9c:	01 de                	add    %ebx,%esi
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	89 f0                	mov    %esi,%eax
  801ca3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ca6:	72 cc                	jb     801c74 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cab:	5b                   	pop    %ebx
  801cac:	5e                   	pop    %esi
  801cad:	5f                   	pop    %edi
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    

00801cb0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 08             	sub    $0x8,%esp
  801cb6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cbb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cbf:	74 2a                	je     801ceb <devcons_read+0x3b>
  801cc1:	eb 05                	jmp    801cc8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cc3:	e8 c7 ee ff ff       	call   800b8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cc8:	e8 43 ee ff ff       	call   800b10 <sys_cgetc>
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	74 f2                	je     801cc3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	78 16                	js     801ceb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cd5:	83 f8 04             	cmp    $0x4,%eax
  801cd8:	74 0c                	je     801ce6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cda:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cdd:	88 02                	mov    %al,(%edx)
	return 1;
  801cdf:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce4:	eb 05                	jmp    801ceb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ce6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cf9:	6a 01                	push   $0x1
  801cfb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cfe:	50                   	push   %eax
  801cff:	e8 ee ed ff ff       	call   800af2 <sys_cputs>
}
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	c9                   	leave  
  801d08:	c3                   	ret    

00801d09 <getchar>:

int
getchar(void)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d0f:	6a 01                	push   $0x1
  801d11:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d14:	50                   	push   %eax
  801d15:	6a 00                	push   $0x0
  801d17:	e8 47 f6 ff ff       	call   801363 <read>
	if (r < 0)
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	78 0f                	js     801d32 <getchar+0x29>
		return r;
	if (r < 1)
  801d23:	85 c0                	test   %eax,%eax
  801d25:	7e 06                	jle    801d2d <getchar+0x24>
		return -E_EOF;
	return c;
  801d27:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d2b:	eb 05                	jmp    801d32 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d2d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d32:	c9                   	leave  
  801d33:	c3                   	ret    

00801d34 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3d:	50                   	push   %eax
  801d3e:	ff 75 08             	pushl  0x8(%ebp)
  801d41:	e8 b7 f3 ff ff       	call   8010fd <fd_lookup>
  801d46:	83 c4 10             	add    $0x10,%esp
  801d49:	85 c0                	test   %eax,%eax
  801d4b:	78 11                	js     801d5e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d50:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d56:	39 10                	cmp    %edx,(%eax)
  801d58:	0f 94 c0             	sete   %al
  801d5b:	0f b6 c0             	movzbl %al,%eax
}
  801d5e:	c9                   	leave  
  801d5f:	c3                   	ret    

00801d60 <opencons>:

int
opencons(void)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d69:	50                   	push   %eax
  801d6a:	e8 3f f3 ff ff       	call   8010ae <fd_alloc>
  801d6f:	83 c4 10             	add    $0x10,%esp
		return r;
  801d72:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d74:	85 c0                	test   %eax,%eax
  801d76:	78 3e                	js     801db6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d78:	83 ec 04             	sub    $0x4,%esp
  801d7b:	68 07 04 00 00       	push   $0x407
  801d80:	ff 75 f4             	pushl  -0xc(%ebp)
  801d83:	6a 00                	push   $0x0
  801d85:	e8 24 ee ff ff       	call   800bae <sys_page_alloc>
  801d8a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d8d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	78 23                	js     801db6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d93:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801da8:	83 ec 0c             	sub    $0xc,%esp
  801dab:	50                   	push   %eax
  801dac:	e8 d6 f2 ff ff       	call   801087 <fd2num>
  801db1:	89 c2                	mov    %eax,%edx
  801db3:	83 c4 10             	add    $0x10,%esp
}
  801db6:	89 d0                	mov    %edx,%eax
  801db8:	c9                   	leave  
  801db9:	c3                   	ret    

00801dba <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  801dc0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dc7:	75 2a                	jne    801df3 <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801dc9:	83 ec 04             	sub    $0x4,%esp
  801dcc:	6a 06                	push   $0x6
  801dce:	68 00 f0 bf ee       	push   $0xeebff000
  801dd3:	6a 00                	push   $0x0
  801dd5:	e8 d4 ed ff ff       	call   800bae <sys_page_alloc>
			 if (a < 0)
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	79 12                	jns    801df3 <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801de1:	50                   	push   %eax
  801de2:	68 59 27 80 00       	push   $0x802759
  801de7:	6a 21                	push   $0x21
  801de9:	68 73 27 80 00       	push   $0x802773
  801dee:	e8 5a e3 ff ff       	call   80014d <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  801df3:	e8 78 ed ff ff       	call   800b70 <sys_getenvid>
  801df8:	83 ec 08             	sub    $0x8,%esp
  801dfb:	68 13 1e 80 00       	push   $0x801e13
  801e00:	50                   	push   %eax
  801e01:	e8 f3 ee ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  801e06:	8b 45 08             	mov    0x8(%ebp),%eax
  801e09:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    

00801e13 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  801e13:	54                   	push   %esp
movl _pgfault_handler, %eax
  801e14:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  801e19:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  801e1b:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  801e1e:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  801e22:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  801e26:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  801e29:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  801e2d:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  801e2f:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  801e32:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  801e33:	83 c4 04             	add    $0x4,%esp
popfl
  801e36:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  801e37:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  801e38:	c3                   	ret    

00801e39 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	56                   	push   %esi
  801e3d:	53                   	push   %ebx
  801e3e:	8b 75 08             	mov    0x8(%ebp),%esi
  801e41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801e47:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801e49:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801e4e:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801e51:	83 ec 0c             	sub    $0xc,%esp
  801e54:	50                   	push   %eax
  801e55:	e8 04 ef ff ff       	call   800d5e <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	78 0e                	js     801e6f <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801e61:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e67:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801e6a:	8b 52 78             	mov    0x78(%edx),%edx
  801e6d:	eb 0a                	jmp    801e79 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801e6f:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801e74:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801e79:	85 f6                	test   %esi,%esi
  801e7b:	74 02                	je     801e7f <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801e7d:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801e7f:	85 db                	test   %ebx,%ebx
  801e81:	74 02                	je     801e85 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801e83:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 08                	js     801e91 <ipc_recv+0x58>
  801e89:	a1 08 40 80 00       	mov    0x804008,%eax
  801e8e:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801e91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e94:	5b                   	pop    %ebx
  801e95:	5e                   	pop    %esi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    

00801e98 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	57                   	push   %edi
  801e9c:	56                   	push   %esi
  801e9d:	53                   	push   %ebx
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ea4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ea7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801eaa:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801eac:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801eb1:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801eb4:	ff 75 14             	pushl  0x14(%ebp)
  801eb7:	53                   	push   %ebx
  801eb8:	56                   	push   %esi
  801eb9:	57                   	push   %edi
  801eba:	e8 7c ee ff ff       	call   800d3b <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec5:	75 07                	jne    801ece <ipc_send+0x36>
				    sys_yield();
  801ec7:	e8 c3 ec ff ff       	call   800b8f <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801ecc:	eb e6                	jmp    801eb4 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	74 12                	je     801ee4 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801ed2:	50                   	push   %eax
  801ed3:	68 81 27 80 00       	push   $0x802781
  801ed8:	6a 4b                	push   $0x4b
  801eda:	68 95 27 80 00       	push   $0x802795
  801edf:	e8 69 e2 ff ff       	call   80014d <_panic>
			 }
	   }
}
  801ee4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee7:	5b                   	pop    %ebx
  801ee8:	5e                   	pop    %esi
  801ee9:	5f                   	pop    %edi
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    

00801eec <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801ef2:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801ef7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801efa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f00:	8b 52 50             	mov    0x50(%edx),%edx
  801f03:	39 ca                	cmp    %ecx,%edx
  801f05:	75 0d                	jne    801f14 <ipc_find_env+0x28>
				    return envs[i].env_id;
  801f07:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f0a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f0f:	8b 40 48             	mov    0x48(%eax),%eax
  801f12:	eb 0f                	jmp    801f23 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801f14:	83 c0 01             	add    $0x1,%eax
  801f17:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f1c:	75 d9                	jne    801ef7 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801f1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f23:	5d                   	pop    %ebp
  801f24:	c3                   	ret    

00801f25 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f2b:	89 d0                	mov    %edx,%eax
  801f2d:	c1 e8 16             	shr    $0x16,%eax
  801f30:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3c:	f6 c1 01             	test   $0x1,%cl
  801f3f:	74 1d                	je     801f5e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f41:	c1 ea 0c             	shr    $0xc,%edx
  801f44:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f4b:	f6 c2 01             	test   $0x1,%dl
  801f4e:	74 0e                	je     801f5e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f50:	c1 ea 0c             	shr    $0xc,%edx
  801f53:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f5a:	ef 
  801f5b:	0f b7 c0             	movzwl %ax,%eax
}
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <__udivdi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 1c             	sub    $0x1c,%esp
  801f67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f77:	85 f6                	test   %esi,%esi
  801f79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f7d:	89 ca                	mov    %ecx,%edx
  801f7f:	89 f8                	mov    %edi,%eax
  801f81:	75 3d                	jne    801fc0 <__udivdi3+0x60>
  801f83:	39 cf                	cmp    %ecx,%edi
  801f85:	0f 87 c5 00 00 00    	ja     802050 <__udivdi3+0xf0>
  801f8b:	85 ff                	test   %edi,%edi
  801f8d:	89 fd                	mov    %edi,%ebp
  801f8f:	75 0b                	jne    801f9c <__udivdi3+0x3c>
  801f91:	b8 01 00 00 00       	mov    $0x1,%eax
  801f96:	31 d2                	xor    %edx,%edx
  801f98:	f7 f7                	div    %edi
  801f9a:	89 c5                	mov    %eax,%ebp
  801f9c:	89 c8                	mov    %ecx,%eax
  801f9e:	31 d2                	xor    %edx,%edx
  801fa0:	f7 f5                	div    %ebp
  801fa2:	89 c1                	mov    %eax,%ecx
  801fa4:	89 d8                	mov    %ebx,%eax
  801fa6:	89 cf                	mov    %ecx,%edi
  801fa8:	f7 f5                	div    %ebp
  801faa:	89 c3                	mov    %eax,%ebx
  801fac:	89 d8                	mov    %ebx,%eax
  801fae:	89 fa                	mov    %edi,%edx
  801fb0:	83 c4 1c             	add    $0x1c,%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    
  801fb8:	90                   	nop
  801fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	39 ce                	cmp    %ecx,%esi
  801fc2:	77 74                	ja     802038 <__udivdi3+0xd8>
  801fc4:	0f bd fe             	bsr    %esi,%edi
  801fc7:	83 f7 1f             	xor    $0x1f,%edi
  801fca:	0f 84 98 00 00 00    	je     802068 <__udivdi3+0x108>
  801fd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	89 c5                	mov    %eax,%ebp
  801fd9:	29 fb                	sub    %edi,%ebx
  801fdb:	d3 e6                	shl    %cl,%esi
  801fdd:	89 d9                	mov    %ebx,%ecx
  801fdf:	d3 ed                	shr    %cl,%ebp
  801fe1:	89 f9                	mov    %edi,%ecx
  801fe3:	d3 e0                	shl    %cl,%eax
  801fe5:	09 ee                	or     %ebp,%esi
  801fe7:	89 d9                	mov    %ebx,%ecx
  801fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fed:	89 d5                	mov    %edx,%ebp
  801fef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ff3:	d3 ed                	shr    %cl,%ebp
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e2                	shl    %cl,%edx
  801ff9:	89 d9                	mov    %ebx,%ecx
  801ffb:	d3 e8                	shr    %cl,%eax
  801ffd:	09 c2                	or     %eax,%edx
  801fff:	89 d0                	mov    %edx,%eax
  802001:	89 ea                	mov    %ebp,%edx
  802003:	f7 f6                	div    %esi
  802005:	89 d5                	mov    %edx,%ebp
  802007:	89 c3                	mov    %eax,%ebx
  802009:	f7 64 24 0c          	mull   0xc(%esp)
  80200d:	39 d5                	cmp    %edx,%ebp
  80200f:	72 10                	jb     802021 <__udivdi3+0xc1>
  802011:	8b 74 24 08          	mov    0x8(%esp),%esi
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e6                	shl    %cl,%esi
  802019:	39 c6                	cmp    %eax,%esi
  80201b:	73 07                	jae    802024 <__udivdi3+0xc4>
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	75 03                	jne    802024 <__udivdi3+0xc4>
  802021:	83 eb 01             	sub    $0x1,%ebx
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 d8                	mov    %ebx,%eax
  802028:	89 fa                	mov    %edi,%edx
  80202a:	83 c4 1c             	add    $0x1c,%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    
  802032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802038:	31 ff                	xor    %edi,%edi
  80203a:	31 db                	xor    %ebx,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 d8                	mov    %ebx,%eax
  802052:	f7 f7                	div    %edi
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 c3                	mov    %eax,%ebx
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	89 fa                	mov    %edi,%edx
  80205c:	83 c4 1c             	add    $0x1c,%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    
  802064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802068:	39 ce                	cmp    %ecx,%esi
  80206a:	72 0c                	jb     802078 <__udivdi3+0x118>
  80206c:	31 db                	xor    %ebx,%ebx
  80206e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802072:	0f 87 34 ff ff ff    	ja     801fac <__udivdi3+0x4c>
  802078:	bb 01 00 00 00       	mov    $0x1,%ebx
  80207d:	e9 2a ff ff ff       	jmp    801fac <__udivdi3+0x4c>
  802082:	66 90                	xchg   %ax,%ax
  802084:	66 90                	xchg   %ax,%ax
  802086:	66 90                	xchg   %ax,%ax
  802088:	66 90                	xchg   %ax,%ax
  80208a:	66 90                	xchg   %ax,%ax
  80208c:	66 90                	xchg   %ax,%ax
  80208e:	66 90                	xchg   %ax,%ax

00802090 <__umoddi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80209b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80209f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 d2                	test   %edx,%edx
  8020a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b1:	89 f3                	mov    %esi,%ebx
  8020b3:	89 3c 24             	mov    %edi,(%esp)
  8020b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ba:	75 1c                	jne    8020d8 <__umoddi3+0x48>
  8020bc:	39 f7                	cmp    %esi,%edi
  8020be:	76 50                	jbe    802110 <__umoddi3+0x80>
  8020c0:	89 c8                	mov    %ecx,%eax
  8020c2:	89 f2                	mov    %esi,%edx
  8020c4:	f7 f7                	div    %edi
  8020c6:	89 d0                	mov    %edx,%eax
  8020c8:	31 d2                	xor    %edx,%edx
  8020ca:	83 c4 1c             	add    $0x1c,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d8:	39 f2                	cmp    %esi,%edx
  8020da:	89 d0                	mov    %edx,%eax
  8020dc:	77 52                	ja     802130 <__umoddi3+0xa0>
  8020de:	0f bd ea             	bsr    %edx,%ebp
  8020e1:	83 f5 1f             	xor    $0x1f,%ebp
  8020e4:	75 5a                	jne    802140 <__umoddi3+0xb0>
  8020e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ea:	0f 82 e0 00 00 00    	jb     8021d0 <__umoddi3+0x140>
  8020f0:	39 0c 24             	cmp    %ecx,(%esp)
  8020f3:	0f 86 d7 00 00 00    	jbe    8021d0 <__umoddi3+0x140>
  8020f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802101:	83 c4 1c             	add    $0x1c,%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5f                   	pop    %edi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	85 ff                	test   %edi,%edi
  802112:	89 fd                	mov    %edi,%ebp
  802114:	75 0b                	jne    802121 <__umoddi3+0x91>
  802116:	b8 01 00 00 00       	mov    $0x1,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	f7 f7                	div    %edi
  80211f:	89 c5                	mov    %eax,%ebp
  802121:	89 f0                	mov    %esi,%eax
  802123:	31 d2                	xor    %edx,%edx
  802125:	f7 f5                	div    %ebp
  802127:	89 c8                	mov    %ecx,%eax
  802129:	f7 f5                	div    %ebp
  80212b:	89 d0                	mov    %edx,%eax
  80212d:	eb 99                	jmp    8020c8 <__umoddi3+0x38>
  80212f:	90                   	nop
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	83 c4 1c             	add    $0x1c,%esp
  802137:	5b                   	pop    %ebx
  802138:	5e                   	pop    %esi
  802139:	5f                   	pop    %edi
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	8b 34 24             	mov    (%esp),%esi
  802143:	bf 20 00 00 00       	mov    $0x20,%edi
  802148:	89 e9                	mov    %ebp,%ecx
  80214a:	29 ef                	sub    %ebp,%edi
  80214c:	d3 e0                	shl    %cl,%eax
  80214e:	89 f9                	mov    %edi,%ecx
  802150:	89 f2                	mov    %esi,%edx
  802152:	d3 ea                	shr    %cl,%edx
  802154:	89 e9                	mov    %ebp,%ecx
  802156:	09 c2                	or     %eax,%edx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 14 24             	mov    %edx,(%esp)
  80215d:	89 f2                	mov    %esi,%edx
  80215f:	d3 e2                	shl    %cl,%edx
  802161:	89 f9                	mov    %edi,%ecx
  802163:	89 54 24 04          	mov    %edx,0x4(%esp)
  802167:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	89 e9                	mov    %ebp,%ecx
  80216f:	89 c6                	mov    %eax,%esi
  802171:	d3 e3                	shl    %cl,%ebx
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 d0                	mov    %edx,%eax
  802177:	d3 e8                	shr    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	09 d8                	or     %ebx,%eax
  80217d:	89 d3                	mov    %edx,%ebx
  80217f:	89 f2                	mov    %esi,%edx
  802181:	f7 34 24             	divl   (%esp)
  802184:	89 d6                	mov    %edx,%esi
  802186:	d3 e3                	shl    %cl,%ebx
  802188:	f7 64 24 04          	mull   0x4(%esp)
  80218c:	39 d6                	cmp    %edx,%esi
  80218e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802192:	89 d1                	mov    %edx,%ecx
  802194:	89 c3                	mov    %eax,%ebx
  802196:	72 08                	jb     8021a0 <__umoddi3+0x110>
  802198:	75 11                	jne    8021ab <__umoddi3+0x11b>
  80219a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80219e:	73 0b                	jae    8021ab <__umoddi3+0x11b>
  8021a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021a4:	1b 14 24             	sbb    (%esp),%edx
  8021a7:	89 d1                	mov    %edx,%ecx
  8021a9:	89 c3                	mov    %eax,%ebx
  8021ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021af:	29 da                	sub    %ebx,%edx
  8021b1:	19 ce                	sbb    %ecx,%esi
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 f0                	mov    %esi,%eax
  8021b7:	d3 e0                	shl    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	d3 ea                	shr    %cl,%edx
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	d3 ee                	shr    %cl,%esi
  8021c1:	09 d0                	or     %edx,%eax
  8021c3:	89 f2                	mov    %esi,%edx
  8021c5:	83 c4 1c             	add    $0x1c,%esp
  8021c8:	5b                   	pop    %ebx
  8021c9:	5e                   	pop    %esi
  8021ca:	5f                   	pop    %edi
  8021cb:	5d                   	pop    %ebp
  8021cc:	c3                   	ret    
  8021cd:	8d 76 00             	lea    0x0(%esi),%esi
  8021d0:	29 f9                	sub    %edi,%ecx
  8021d2:	19 d6                	sbb    %edx,%esi
  8021d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021dc:	e9 18 ff ff ff       	jmp    8020f9 <__umoddi3+0x69>
