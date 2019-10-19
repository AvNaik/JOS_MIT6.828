
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 46 10 00 00       	call   801092 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 00 22 80 00       	push   $0x802200
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 29 0e 00 00       	call   800e93 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 e8 25 80 00       	push   $0x8025e8
  800079:	6a 1a                	push   $0x1a
  80007b:	68 0c 22 80 00       	push   $0x80220c
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 f9 0f 00 00       	call   801092 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 41 10 00 00       	call   8010f1 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 d4 0d 00 00       	call   800e93 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 e8 25 80 00       	push   $0x8025e8
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 0c 22 80 00       	push   $0x80220c
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 01 10 00 00       	call   8010f1 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800103:	e8 73 0a 00 00       	call   800b7b <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 00 12 00 00       	call   801349 <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 e7 09 00 00       	call   800b3a <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 10 0a 00 00       	call   800b7b <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 24 22 80 00       	push   $0x802224
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 26 27 80 00 	movl   $0x802726,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 2f 09 00 00       	call   800afd <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 54 01 00 00       	call   800368 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 d4 08 00 00       	call   800afd <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 d7 1c 00 00       	call   801f70 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 c4 1d 00 00       	call   8020a0 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 47 22 80 00 	movsbl 0x802247(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f7:	83 fa 01             	cmp    $0x1,%edx
  8002fa:	7e 0e                	jle    80030a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	eb 22                	jmp    80032c <getuint+0x38>
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 10                	je     80031e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	eb 0e                	jmp    80032c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800334:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	3b 50 04             	cmp    0x4(%eax),%edx
  80033d:	73 0a                	jae    800349 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	88 02                	mov    %al,(%edx)
}
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800351:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800354:	50                   	push   %eax
  800355:	ff 75 10             	pushl  0x10(%ebp)
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	e8 05 00 00 00       	call   800368 <vprintfmt>
	va_end(ap);
}
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
  80036e:	83 ec 2c             	sub    $0x2c,%esp
  800371:	8b 75 08             	mov    0x8(%ebp),%esi
  800374:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800377:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037a:	eb 12                	jmp    80038e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037c:	85 c0                	test   %eax,%eax
  80037e:	0f 84 89 03 00 00    	je     80070d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	53                   	push   %ebx
  800388:	50                   	push   %eax
  800389:	ff d6                	call   *%esi
  80038b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038e:	83 c7 01             	add    $0x1,%edi
  800391:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e2                	jne    80037c <vprintfmt+0x14>
  80039a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b8:	eb 07                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 07             	movzbl (%edi),%eax
  8003ca:	0f b6 c8             	movzbl %al,%ecx
  8003cd:	83 e8 23             	sub    $0x23,%eax
  8003d0:	3c 55                	cmp    $0x55,%al
  8003d2:	0f 87 1a 03 00 00    	ja     8006f2 <vprintfmt+0x38a>
  8003d8:	0f b6 c0             	movzbl %al,%eax
  8003db:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e9:	eb d6                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800400:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800403:	83 fa 09             	cmp    $0x9,%edx
  800406:	77 39                	ja     800441 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800408:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040b:	eb e9                	jmp    8003f6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 48 04             	lea    0x4(%eax),%ecx
  800413:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041e:	eb 27                	jmp    800447 <vprintfmt+0xdf>
  800420:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042a:	0f 49 c8             	cmovns %eax,%ecx
  80042d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800433:	eb 8c                	jmp    8003c1 <vprintfmt+0x59>
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800438:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043f:	eb 80                	jmp    8003c1 <vprintfmt+0x59>
  800441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800444:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044b:	0f 89 70 ff ff ff    	jns    8003c1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800451:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800457:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045e:	e9 5e ff ff ff       	jmp    8003c1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800463:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800469:	e9 53 ff ff ff       	jmp    8003c1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	53                   	push   %ebx
  80047b:	ff 30                	pushl  (%eax)
  80047d:	ff d6                	call   *%esi
			break;
  80047f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800485:	e9 04 ff ff ff       	jmp    80038e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 50 04             	lea    0x4(%eax),%edx
  800490:	89 55 14             	mov    %edx,0x14(%ebp)
  800493:	8b 00                	mov    (%eax),%eax
  800495:	99                   	cltd   
  800496:	31 d0                	xor    %edx,%eax
  800498:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049a:	83 f8 0f             	cmp    $0xf,%eax
  80049d:	7f 0b                	jg     8004aa <vprintfmt+0x142>
  80049f:	8b 14 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 5f 22 80 00       	push   $0x80225f
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 94 fe ff ff       	call   80034b <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bd:	e9 cc fe ff ff       	jmp    80038e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c2:	52                   	push   %edx
  8004c3:	68 e1 26 80 00       	push   $0x8026e1
  8004c8:	53                   	push   %ebx
  8004c9:	56                   	push   %esi
  8004ca:	e8 7c fe ff ff       	call   80034b <printfmt>
  8004cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d5:	e9 b4 fe ff ff       	jmp    80038e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	b8 58 22 80 00       	mov    $0x802258,%eax
  8004ec:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f3:	0f 8e 94 00 00 00    	jle    80058d <vprintfmt+0x225>
  8004f9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fd:	0f 84 98 00 00 00    	je     80059b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	ff 75 d0             	pushl  -0x30(%ebp)
  800509:	57                   	push   %edi
  80050a:	e8 86 02 00 00       	call   800795 <strnlen>
  80050f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800521:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800524:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	eb 0f                	jmp    800537 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	ff 75 e0             	pushl  -0x20(%ebp)
  80052f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	83 ef 01             	sub    $0x1,%edi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 ff                	test   %edi,%edi
  800539:	7f ed                	jg     800528 <vprintfmt+0x1c0>
  80053b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800541:	85 c9                	test   %ecx,%ecx
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	0f 49 c1             	cmovns %ecx,%eax
  80054b:	29 c1                	sub    %eax,%ecx
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	89 cb                	mov    %ecx,%ebx
  800558:	eb 4d                	jmp    8005a7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055e:	74 1b                	je     80057b <vprintfmt+0x213>
  800560:	0f be c0             	movsbl %al,%eax
  800563:	83 e8 20             	sub    $0x20,%eax
  800566:	83 f8 5e             	cmp    $0x5e,%eax
  800569:	76 10                	jbe    80057b <vprintfmt+0x213>
					putch('?', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	ff 75 0c             	pushl  0xc(%ebp)
  800571:	6a 3f                	push   $0x3f
  800573:	ff 55 08             	call   *0x8(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb 0d                	jmp    800588 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	52                   	push   %edx
  800582:	ff 55 08             	call   *0x8(%ebp)
  800585:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	83 eb 01             	sub    $0x1,%ebx
  80058b:	eb 1a                	jmp    8005a7 <vprintfmt+0x23f>
  80058d:	89 75 08             	mov    %esi,0x8(%ebp)
  800590:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800593:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800596:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800599:	eb 0c                	jmp    8005a7 <vprintfmt+0x23f>
  80059b:	89 75 08             	mov    %esi,0x8(%ebp)
  80059e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a7:	83 c7 01             	add    $0x1,%edi
  8005aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ae:	0f be d0             	movsbl %al,%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 23                	je     8005d8 <vprintfmt+0x270>
  8005b5:	85 f6                	test   %esi,%esi
  8005b7:	78 a1                	js     80055a <vprintfmt+0x1f2>
  8005b9:	83 ee 01             	sub    $0x1,%esi
  8005bc:	79 9c                	jns    80055a <vprintfmt+0x1f2>
  8005be:	89 df                	mov    %ebx,%edi
  8005c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c6:	eb 18                	jmp    8005e0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	6a 20                	push   $0x20
  8005ce:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d0:	83 ef 01             	sub    $0x1,%edi
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb 08                	jmp    8005e0 <vprintfmt+0x278>
  8005d8:	89 df                	mov    %ebx,%edi
  8005da:	8b 75 08             	mov    0x8(%ebp),%esi
  8005dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	7f e4                	jg     8005c8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	e9 a2 fd ff ff       	jmp    80038e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ec:	83 fa 01             	cmp    $0x1,%edx
  8005ef:	7e 16                	jle    800607 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 08             	lea    0x8(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 50 04             	mov    0x4(%eax),%edx
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800605:	eb 32                	jmp    800639 <vprintfmt+0x2d1>
	else if (lflag)
  800607:	85 d2                	test   %edx,%edx
  800609:	74 18                	je     800623 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 c1                	mov    %eax,%ecx
  80061b:	c1 f9 1f             	sar    $0x1f,%ecx
  80061e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800621:	eb 16                	jmp    800639 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800631:	89 c1                	mov    %eax,%ecx
  800633:	c1 f9 1f             	sar    $0x1f,%ecx
  800636:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800639:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800644:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800648:	79 74                	jns    8006be <vprintfmt+0x356>
				putch('-', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 2d                	push   $0x2d
  800650:	ff d6                	call   *%esi
				num = -(long long) num;
  800652:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800655:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800658:	f7 d8                	neg    %eax
  80065a:	83 d2 00             	adc    $0x0,%edx
  80065d:	f7 da                	neg    %edx
  80065f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800662:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800667:	eb 55                	jmp    8006be <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	e8 83 fc ff ff       	call   8002f4 <getuint>
			base = 10;
  800671:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800676:	eb 46                	jmp    8006be <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	e8 74 fc ff ff       	call   8002f4 <getuint>
			base = 8;
  800680:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800685:	eb 37                	jmp    8006be <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 30                	push   $0x30
  80068d:	ff d6                	call   *%esi
			putch('x', putdat);
  80068f:	83 c4 08             	add    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 78                	push   $0x78
  800695:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006aa:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006af:	eb 0d                	jmp    8006be <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 3b fc ff ff       	call   8002f4 <getuint>
			base = 16;
  8006b9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c5:	57                   	push   %edi
  8006c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	50                   	push   %eax
  8006cc:	89 da                	mov    %ebx,%edx
  8006ce:	89 f0                	mov    %esi,%eax
  8006d0:	e8 70 fb ff ff       	call   800245 <printnum>
			break;
  8006d5:	83 c4 20             	add    $0x20,%esp
  8006d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006db:	e9 ae fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	51                   	push   %ecx
  8006e5:	ff d6                	call   *%esi
			break;
  8006e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ed:	e9 9c fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb 03                	jmp    800702 <vprintfmt+0x39a>
  8006ff:	83 ef 01             	sub    $0x1,%edi
  800702:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800706:	75 f7                	jne    8006ff <vprintfmt+0x397>
  800708:	e9 81 fc ff ff       	jmp    80038e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800710:	5b                   	pop    %ebx
  800711:	5e                   	pop    %esi
  800712:	5f                   	pop    %edi
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 18             	sub    $0x18,%esp
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800721:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800724:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800728:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800732:	85 c0                	test   %eax,%eax
  800734:	74 26                	je     80075c <vsnprintf+0x47>
  800736:	85 d2                	test   %edx,%edx
  800738:	7e 22                	jle    80075c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073a:	ff 75 14             	pushl  0x14(%ebp)
  80073d:	ff 75 10             	pushl  0x10(%ebp)
  800740:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	68 2e 03 80 00       	push   $0x80032e
  800749:	e8 1a fc ff ff       	call   800368 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800751:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	eb 05                	jmp    800761 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800769:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076c:	50                   	push   %eax
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	ff 75 08             	pushl  0x8(%ebp)
  800776:	e8 9a ff ff ff       	call   800715 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
  800788:	eb 03                	jmp    80078d <strlen+0x10>
		n++;
  80078a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800791:	75 f7                	jne    80078a <strlen+0xd>
		n++;
	return n;
}
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079e:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a3:	eb 03                	jmp    8007a8 <strnlen+0x13>
		n++;
  8007a5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	39 c2                	cmp    %eax,%edx
  8007aa:	74 08                	je     8007b4 <strnlen+0x1f>
  8007ac:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b0:	75 f3                	jne    8007a5 <strnlen+0x10>
  8007b2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c0:	89 c2                	mov    %eax,%edx
  8007c2:	83 c2 01             	add    $0x1,%edx
  8007c5:	83 c1 01             	add    $0x1,%ecx
  8007c8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007cf:	84 db                	test   %bl,%bl
  8007d1:	75 ef                	jne    8007c2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dd:	53                   	push   %ebx
  8007de:	e8 9a ff ff ff       	call   80077d <strlen>
  8007e3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e6:	ff 75 0c             	pushl  0xc(%ebp)
  8007e9:	01 d8                	add    %ebx,%eax
  8007eb:	50                   	push   %eax
  8007ec:	e8 c5 ff ff ff       	call   8007b6 <strcpy>
	return dst;
}
  8007f1:	89 d8                	mov    %ebx,%eax
  8007f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	56                   	push   %esi
  8007fc:	53                   	push   %ebx
  8007fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800803:	89 f3                	mov    %esi,%ebx
  800805:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	89 f2                	mov    %esi,%edx
  80080a:	eb 0f                	jmp    80081b <strncpy+0x23>
		*dst++ = *src;
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	0f b6 01             	movzbl (%ecx),%eax
  800812:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800815:	80 39 01             	cmpb   $0x1,(%ecx)
  800818:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	39 da                	cmp    %ebx,%edx
  80081d:	75 ed                	jne    80080c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081f:	89 f0                	mov    %esi,%eax
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	56                   	push   %esi
  800829:	53                   	push   %ebx
  80082a:	8b 75 08             	mov    0x8(%ebp),%esi
  80082d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800830:	8b 55 10             	mov    0x10(%ebp),%edx
  800833:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800835:	85 d2                	test   %edx,%edx
  800837:	74 21                	je     80085a <strlcpy+0x35>
  800839:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083d:	89 f2                	mov    %esi,%edx
  80083f:	eb 09                	jmp    80084a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800841:	83 c2 01             	add    $0x1,%edx
  800844:	83 c1 01             	add    $0x1,%ecx
  800847:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084a:	39 c2                	cmp    %eax,%edx
  80084c:	74 09                	je     800857 <strlcpy+0x32>
  80084e:	0f b6 19             	movzbl (%ecx),%ebx
  800851:	84 db                	test   %bl,%bl
  800853:	75 ec                	jne    800841 <strlcpy+0x1c>
  800855:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800857:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085a:	29 f0                	sub    %esi,%eax
}
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800869:	eb 06                	jmp    800871 <strcmp+0x11>
		p++, q++;
  80086b:	83 c1 01             	add    $0x1,%ecx
  80086e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800871:	0f b6 01             	movzbl (%ecx),%eax
  800874:	84 c0                	test   %al,%al
  800876:	74 04                	je     80087c <strcmp+0x1c>
  800878:	3a 02                	cmp    (%edx),%al
  80087a:	74 ef                	je     80086b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087c:	0f b6 c0             	movzbl %al,%eax
  80087f:	0f b6 12             	movzbl (%edx),%edx
  800882:	29 d0                	sub    %edx,%eax
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	53                   	push   %ebx
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800890:	89 c3                	mov    %eax,%ebx
  800892:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800895:	eb 06                	jmp    80089d <strncmp+0x17>
		n--, p++, q++;
  800897:	83 c0 01             	add    $0x1,%eax
  80089a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089d:	39 d8                	cmp    %ebx,%eax
  80089f:	74 15                	je     8008b6 <strncmp+0x30>
  8008a1:	0f b6 08             	movzbl (%eax),%ecx
  8008a4:	84 c9                	test   %cl,%cl
  8008a6:	74 04                	je     8008ac <strncmp+0x26>
  8008a8:	3a 0a                	cmp    (%edx),%cl
  8008aa:	74 eb                	je     800897 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ac:	0f b6 00             	movzbl (%eax),%eax
  8008af:	0f b6 12             	movzbl (%edx),%edx
  8008b2:	29 d0                	sub    %edx,%eax
  8008b4:	eb 05                	jmp    8008bb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bb:	5b                   	pop    %ebx
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c8:	eb 07                	jmp    8008d1 <strchr+0x13>
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 0f                	je     8008dd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	0f b6 10             	movzbl (%eax),%edx
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	75 f2                	jne    8008ca <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e9:	eb 03                	jmp    8008ee <strfind+0xf>
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 04                	je     8008f9 <strfind+0x1a>
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	75 f2                	jne    8008eb <strfind+0xc>
			break;
	return (char *) s;
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	57                   	push   %edi
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
  800901:	8b 7d 08             	mov    0x8(%ebp),%edi
  800904:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800907:	85 c9                	test   %ecx,%ecx
  800909:	74 36                	je     800941 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800911:	75 28                	jne    80093b <memset+0x40>
  800913:	f6 c1 03             	test   $0x3,%cl
  800916:	75 23                	jne    80093b <memset+0x40>
		c &= 0xFF;
  800918:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091c:	89 d3                	mov    %edx,%ebx
  80091e:	c1 e3 08             	shl    $0x8,%ebx
  800921:	89 d6                	mov    %edx,%esi
  800923:	c1 e6 18             	shl    $0x18,%esi
  800926:	89 d0                	mov    %edx,%eax
  800928:	c1 e0 10             	shl    $0x10,%eax
  80092b:	09 f0                	or     %esi,%eax
  80092d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092f:	89 d8                	mov    %ebx,%eax
  800931:	09 d0                	or     %edx,%eax
  800933:	c1 e9 02             	shr    $0x2,%ecx
  800936:	fc                   	cld    
  800937:	f3 ab                	rep stos %eax,%es:(%edi)
  800939:	eb 06                	jmp    800941 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	fc                   	cld    
  80093f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800941:	89 f8                	mov    %edi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5f                   	pop    %edi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 75 0c             	mov    0xc(%ebp),%esi
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800956:	39 c6                	cmp    %eax,%esi
  800958:	73 35                	jae    80098f <memmove+0x47>
  80095a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095d:	39 d0                	cmp    %edx,%eax
  80095f:	73 2e                	jae    80098f <memmove+0x47>
		s += n;
		d += n;
  800961:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	89 d6                	mov    %edx,%esi
  800966:	09 fe                	or     %edi,%esi
  800968:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096e:	75 13                	jne    800983 <memmove+0x3b>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	75 0e                	jne    800983 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 09                	jmp    80098c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800983:	83 ef 01             	sub    $0x1,%edi
  800986:	8d 72 ff             	lea    -0x1(%edx),%esi
  800989:	fd                   	std    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098c:	fc                   	cld    
  80098d:	eb 1d                	jmp    8009ac <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	89 f2                	mov    %esi,%edx
  800991:	09 c2                	or     %eax,%edx
  800993:	f6 c2 03             	test   $0x3,%dl
  800996:	75 0f                	jne    8009a7 <memmove+0x5f>
  800998:	f6 c1 03             	test   $0x3,%cl
  80099b:	75 0a                	jne    8009a7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099d:	c1 e9 02             	shr    $0x2,%ecx
  8009a0:	89 c7                	mov    %eax,%edi
  8009a2:	fc                   	cld    
  8009a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a5:	eb 05                	jmp    8009ac <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	fc                   	cld    
  8009aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ac:	5e                   	pop    %esi
  8009ad:	5f                   	pop    %edi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b3:	ff 75 10             	pushl  0x10(%ebp)
  8009b6:	ff 75 0c             	pushl  0xc(%ebp)
  8009b9:	ff 75 08             	pushl  0x8(%ebp)
  8009bc:	e8 87 ff ff ff       	call   800948 <memmove>
}
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ce:	89 c6                	mov    %eax,%esi
  8009d0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	eb 1a                	jmp    8009ef <memcmp+0x2c>
		if (*s1 != *s2)
  8009d5:	0f b6 08             	movzbl (%eax),%ecx
  8009d8:	0f b6 1a             	movzbl (%edx),%ebx
  8009db:	38 d9                	cmp    %bl,%cl
  8009dd:	74 0a                	je     8009e9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009df:	0f b6 c1             	movzbl %cl,%eax
  8009e2:	0f b6 db             	movzbl %bl,%ebx
  8009e5:	29 d8                	sub    %ebx,%eax
  8009e7:	eb 0f                	jmp    8009f8 <memcmp+0x35>
		s1++, s2++;
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ef:	39 f0                	cmp    %esi,%eax
  8009f1:	75 e2                	jne    8009d5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5e                   	pop    %esi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	53                   	push   %ebx
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a03:	89 c1                	mov    %eax,%ecx
  800a05:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a08:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0c:	eb 0a                	jmp    800a18 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0e:	0f b6 10             	movzbl (%eax),%edx
  800a11:	39 da                	cmp    %ebx,%edx
  800a13:	74 07                	je     800a1c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	39 c8                	cmp    %ecx,%eax
  800a1a:	72 f2                	jb     800a0e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2b:	eb 03                	jmp    800a30 <strtol+0x11>
		s++;
  800a2d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a30:	0f b6 01             	movzbl (%ecx),%eax
  800a33:	3c 20                	cmp    $0x20,%al
  800a35:	74 f6                	je     800a2d <strtol+0xe>
  800a37:	3c 09                	cmp    $0x9,%al
  800a39:	74 f2                	je     800a2d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3b:	3c 2b                	cmp    $0x2b,%al
  800a3d:	75 0a                	jne    800a49 <strtol+0x2a>
		s++;
  800a3f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a42:	bf 00 00 00 00       	mov    $0x0,%edi
  800a47:	eb 11                	jmp    800a5a <strtol+0x3b>
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4e:	3c 2d                	cmp    $0x2d,%al
  800a50:	75 08                	jne    800a5a <strtol+0x3b>
		s++, neg = 1;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a60:	75 15                	jne    800a77 <strtol+0x58>
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	75 10                	jne    800a77 <strtol+0x58>
  800a67:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6b:	75 7c                	jne    800ae9 <strtol+0xca>
		s += 2, base = 16;
  800a6d:	83 c1 02             	add    $0x2,%ecx
  800a70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a75:	eb 16                	jmp    800a8d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a77:	85 db                	test   %ebx,%ebx
  800a79:	75 12                	jne    800a8d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a80:	80 39 30             	cmpb   $0x30,(%ecx)
  800a83:	75 08                	jne    800a8d <strtol+0x6e>
		s++, base = 8;
  800a85:	83 c1 01             	add    $0x1,%ecx
  800a88:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a92:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a95:	0f b6 11             	movzbl (%ecx),%edx
  800a98:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9b:	89 f3                	mov    %esi,%ebx
  800a9d:	80 fb 09             	cmp    $0x9,%bl
  800aa0:	77 08                	ja     800aaa <strtol+0x8b>
			dig = *s - '0';
  800aa2:	0f be d2             	movsbl %dl,%edx
  800aa5:	83 ea 30             	sub    $0x30,%edx
  800aa8:	eb 22                	jmp    800acc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aaa:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aad:	89 f3                	mov    %esi,%ebx
  800aaf:	80 fb 19             	cmp    $0x19,%bl
  800ab2:	77 08                	ja     800abc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab4:	0f be d2             	movsbl %dl,%edx
  800ab7:	83 ea 57             	sub    $0x57,%edx
  800aba:	eb 10                	jmp    800acc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abf:	89 f3                	mov    %esi,%ebx
  800ac1:	80 fb 19             	cmp    $0x19,%bl
  800ac4:	77 16                	ja     800adc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac6:	0f be d2             	movsbl %dl,%edx
  800ac9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800acf:	7d 0b                	jge    800adc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ada:	eb b9                	jmp    800a95 <strtol+0x76>

	if (endptr)
  800adc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae0:	74 0d                	je     800aef <strtol+0xd0>
		*endptr = (char *) s;
  800ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae5:	89 0e                	mov    %ecx,(%esi)
  800ae7:	eb 06                	jmp    800aef <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae9:	85 db                	test   %ebx,%ebx
  800aeb:	74 98                	je     800a85 <strtol+0x66>
  800aed:	eb 9e                	jmp    800a8d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aef:	89 c2                	mov    %eax,%edx
  800af1:	f7 da                	neg    %edx
  800af3:	85 ff                	test   %edi,%edi
  800af5:	0f 45 c2             	cmovne %edx,%eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0e:	89 c3                	mov    %eax,%ebx
  800b10:	89 c7                	mov    %eax,%edi
  800b12:	89 c6                	mov    %eax,%esi
  800b14:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b48:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	89 cb                	mov    %ecx,%ebx
  800b52:	89 cf                	mov    %ecx,%edi
  800b54:	89 ce                	mov    %ecx,%esi
  800b56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	7e 17                	jle    800b73 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	50                   	push   %eax
  800b60:	6a 03                	push   $0x3
  800b62:	68 3f 25 80 00       	push   $0x80253f
  800b67:	6a 23                	push   $0x23
  800b69:	68 5c 25 80 00       	push   $0x80255c
  800b6e:	e8 e5 f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_yield>:

void
sys_yield(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	be 00 00 00 00       	mov    $0x0,%esi
  800bc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd5:	89 f7                	mov    %esi,%edi
  800bd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 04                	push   $0x4
  800be3:	68 3f 25 80 00       	push   $0x80253f
  800be8:	6a 23                	push   $0x23
  800bea:	68 5c 25 80 00       	push   $0x80255c
  800bef:	e8 64 f5 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c13:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c16:	8b 75 18             	mov    0x18(%ebp),%esi
  800c19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 05                	push   $0x5
  800c25:	68 3f 25 80 00       	push   $0x80253f
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 5c 25 80 00       	push   $0x80255c
  800c31:	e8 22 f5 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 df                	mov    %ebx,%edi
  800c59:	89 de                	mov    %ebx,%esi
  800c5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 06                	push   $0x6
  800c67:	68 3f 25 80 00       	push   $0x80253f
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 5c 25 80 00       	push   $0x80255c
  800c73:	e8 e0 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 08                	push   $0x8
  800ca9:	68 3f 25 80 00       	push   $0x80253f
  800cae:	6a 23                	push   $0x23
  800cb0:	68 5c 25 80 00       	push   $0x80255c
  800cb5:	e8 9e f4 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 df                	mov    %ebx,%edi
  800cdd:	89 de                	mov    %ebx,%esi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 09                	push   $0x9
  800ceb:	68 3f 25 80 00       	push   $0x80253f
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 5c 25 80 00       	push   $0x80255c
  800cf7:	e8 5c f4 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 df                	mov    %ebx,%edi
  800d1f:	89 de                	mov    %ebx,%esi
  800d21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 0a                	push   $0xa
  800d2d:	68 3f 25 80 00       	push   $0x80253f
  800d32:	6a 23                	push   $0x23
  800d34:	68 5c 25 80 00       	push   $0x80255c
  800d39:	e8 1a f4 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d62:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d77:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 cb                	mov    %ecx,%ebx
  800d81:	89 cf                	mov    %ecx,%edi
  800d83:	89 ce                	mov    %ecx,%esi
  800d85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 17                	jle    800da2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 0d                	push   $0xd
  800d91:	68 3f 25 80 00       	push   $0x80253f
  800d96:	6a 23                	push   $0x23
  800d98:	68 5c 25 80 00       	push   $0x80255c
  800d9d:	e8 b6 f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	53                   	push   %ebx
  800dae:	83 ec 04             	sub    $0x4,%esp
  800db1:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  800db4:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  800db6:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  800db9:	89 da                	mov    %ebx,%edx
  800dbb:	c1 ea 0c             	shr    $0xc,%edx
  800dbe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  800dc5:	a8 02                	test   $0x2,%al
  800dc7:	75 12                	jne    800ddb <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  800dc9:	50                   	push   %eax
  800dca:	68 6c 25 80 00       	push   $0x80256c
  800dcf:	6a 21                	push   $0x21
  800dd1:	68 8d 25 80 00       	push   $0x80258d
  800dd6:	e8 7d f3 ff ff       	call   800158 <_panic>
	   } else if (!(pte & PTE_COW)) {
  800ddb:	f6 c6 08             	test   $0x8,%dh
  800dde:	75 14                	jne    800df4 <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  800de0:	83 ec 04             	sub    $0x4,%esp
  800de3:	68 98 25 80 00       	push   $0x802598
  800de8:	6a 23                	push   $0x23
  800dea:	68 8d 25 80 00       	push   $0x80258d
  800def:	e8 64 f3 ff ff       	call   800158 <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  800df4:	83 ec 04             	sub    $0x4,%esp
  800df7:	6a 07                	push   $0x7
  800df9:	68 00 00 40 00       	push   $0x400000
  800dfe:	6a 00                	push   $0x0
  800e00:	e8 b4 fd ff ff       	call   800bb9 <sys_page_alloc>
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	79 12                	jns    800e1e <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  800e0c:	50                   	push   %eax
  800e0d:	68 b5 25 80 00       	push   $0x8025b5
  800e12:	6a 2e                	push   $0x2e
  800e14:	68 8d 25 80 00       	push   $0x80258d
  800e19:	e8 3a f3 ff ff       	call   800158 <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800e1e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e24:	83 ec 04             	sub    $0x4,%esp
  800e27:	68 00 10 00 00       	push   $0x1000
  800e2c:	53                   	push   %ebx
  800e2d:	68 00 00 40 00       	push   $0x400000
  800e32:	e8 11 fb ff ff       	call   800948 <memmove>
	   if ((r = sys_page_map(0,
  800e37:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e3e:	53                   	push   %ebx
  800e3f:	6a 00                	push   $0x0
  800e41:	68 00 00 40 00       	push   $0x400000
  800e46:	6a 00                	push   $0x0
  800e48:	e8 af fd ff ff       	call   800bfc <sys_page_map>
  800e4d:	83 c4 20             	add    $0x20,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	79 12                	jns    800e66 <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  800e54:	50                   	push   %eax
  800e55:	68 c8 25 80 00       	push   $0x8025c8
  800e5a:	6a 36                	push   $0x36
  800e5c:	68 8d 25 80 00       	push   $0x80258d
  800e61:	e8 f2 f2 ff ff       	call   800158 <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	68 00 00 40 00       	push   $0x400000
  800e6e:	6a 00                	push   $0x0
  800e70:	e8 c9 fd ff ff       	call   800c3e <sys_page_unmap>
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	79 12                	jns    800e8e <pgfault+0xe4>
			 panic("unmap %e", r);
  800e7c:	50                   	push   %eax
  800e7d:	68 d8 25 80 00       	push   $0x8025d8
  800e82:	6a 39                	push   $0x39
  800e84:	68 8d 25 80 00       	push   $0x80258d
  800e89:	e8 ca f2 ff ff       	call   800158 <_panic>
	   }
}
  800e8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    

00800e93 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	57                   	push   %edi
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
  800e99:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  800e9c:	68 aa 0d 80 00       	push   $0x800daa
  800ea1:	e8 0b 10 00 00       	call   801eb1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ea6:	b8 07 00 00 00       	mov    $0x7,%eax
  800eab:	cd 30                	int    $0x30
  800ead:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eb0:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	79 15                	jns    800ecf <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  800eba:	50                   	push   %eax
  800ebb:	68 e1 25 80 00       	push   $0x8025e1
  800ec0:	68 81 00 00 00       	push   $0x81
  800ec5:	68 8d 25 80 00       	push   $0x80258d
  800eca:	e8 89 f2 ff ff       	call   800158 <_panic>
  800ecf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800ed6:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  800eda:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ede:	75 1c                	jne    800efc <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  800ee0:	e8 96 fc ff ff       	call   800b7b <sys_getenvid>
  800ee5:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eea:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ef2:	a3 04 40 80 00       	mov    %eax,0x804004
			 return envid;
  800ef7:	e9 71 01 00 00       	jmp    80106d <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  800efc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800eff:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800f06:	a8 01                	test   $0x1,%al
  800f08:	0f 84 18 01 00 00    	je     801026 <fork+0x193>
  800f0e:	89 fb                	mov    %edi,%ebx
  800f10:	c1 e3 0a             	shl    $0xa,%ebx
  800f13:	c1 e7 16             	shl    $0x16,%edi
  800f16:	be 00 00 00 00       	mov    $0x0,%esi
  800f1b:	e9 f4 00 00 00       	jmp    801014 <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  800f20:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800f26:	0f 84 dc 00 00 00    	je     801008 <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  800f2c:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800f32:	0f 87 cc 00 00 00    	ja     801004 <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  800f38:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f3f:	a8 01                	test   $0x1,%al
  800f41:	0f 84 c1 00 00 00    	je     801008 <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  800f47:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  800f4e:	a9 02 08 00 00       	test   $0x802,%eax
  800f53:	74 05                	je     800f5a <fork+0xc7>
  800f55:	f6 c4 04             	test   $0x4,%ah
  800f58:	74 3a                	je     800f94 <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  800f5a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f60:	8b 52 48             	mov    0x48(%edx),%edx
  800f63:	83 ec 0c             	sub    $0xc,%esp
  800f66:	25 07 0e 00 00       	and    $0xe07,%eax
  800f6b:	50                   	push   %eax
  800f6c:	57                   	push   %edi
  800f6d:	ff 75 dc             	pushl  -0x24(%ebp)
  800f70:	57                   	push   %edi
  800f71:	52                   	push   %edx
  800f72:	e8 85 fc ff ff       	call   800bfc <sys_page_map>
  800f77:	83 c4 20             	add    $0x20,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	0f 89 86 00 00 00    	jns    801008 <fork+0x175>
				    panic("sys_page_map: %e", r);
  800f82:	50                   	push   %eax
  800f83:	68 f1 25 80 00       	push   $0x8025f1
  800f88:	6a 52                	push   $0x52
  800f8a:	68 8d 25 80 00       	push   $0x80258d
  800f8f:	e8 c4 f1 ff ff       	call   800158 <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  800f94:	25 05 06 00 00       	and    $0x605,%eax
  800f99:	80 cc 08             	or     $0x8,%ah
  800f9c:	89 c1                	mov    %eax,%ecx
  800f9e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800fa1:	a1 04 40 80 00       	mov    0x804004,%eax
  800fa6:	8b 40 48             	mov    0x48(%eax),%eax
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	51                   	push   %ecx
  800fad:	57                   	push   %edi
  800fae:	ff 75 dc             	pushl  -0x24(%ebp)
  800fb1:	57                   	push   %edi
  800fb2:	50                   	push   %eax
  800fb3:	e8 44 fc ff ff       	call   800bfc <sys_page_map>
  800fb8:	83 c4 20             	add    $0x20,%esp
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	79 12                	jns    800fd1 <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  800fbf:	50                   	push   %eax
  800fc0:	68 f1 25 80 00       	push   $0x8025f1
  800fc5:	6a 5d                	push   $0x5d
  800fc7:	68 8d 25 80 00       	push   $0x80258d
  800fcc:	e8 87 f1 ff ff       	call   800158 <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  800fd1:	a1 04 40 80 00       	mov    0x804004,%eax
  800fd6:	8b 50 48             	mov    0x48(%eax),%edx
  800fd9:	8b 40 48             	mov    0x48(%eax),%eax
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fe2:	57                   	push   %edi
  800fe3:	52                   	push   %edx
  800fe4:	57                   	push   %edi
  800fe5:	50                   	push   %eax
  800fe6:	e8 11 fc ff ff       	call   800bfc <sys_page_map>
  800feb:	83 c4 20             	add    $0x20,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	79 16                	jns    801008 <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  800ff2:	50                   	push   %eax
  800ff3:	68 f1 25 80 00       	push   $0x8025f1
  800ff8:	6a 63                	push   $0x63
  800ffa:	68 8d 25 80 00       	push   $0x80258d
  800fff:	e8 54 f1 ff ff       	call   800158 <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  801004:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  801008:	83 c6 01             	add    $0x1,%esi
  80100b:	83 c3 01             	add    $0x1,%ebx
  80100e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801014:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  80101a:	7f 0a                	jg     801026 <fork+0x193>
  80101c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801020:	0f 85 fa fe ff ff    	jne    800f20 <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  801026:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  80102a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80102d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801032:	7f 0a                	jg     80103e <fork+0x1ab>
  801034:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801038:	0f 85 be fe ff ff    	jne    800efc <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80103e:	83 ec 08             	sub    $0x8,%esp
  801041:	68 0a 1f 80 00       	push   $0x801f0a
  801046:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801049:	56                   	push   %esi
  80104a:	e8 b5 fc ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  80104f:	83 c4 0c             	add    $0xc,%esp
  801052:	6a 06                	push   $0x6
  801054:	68 00 f0 bf ee       	push   $0xeebff000
  801059:	56                   	push   %esi
  80105a:	e8 5a fb ff ff       	call   800bb9 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  80105f:	83 c4 08             	add    $0x8,%esp
  801062:	6a 02                	push   $0x2
  801064:	56                   	push   %esi
  801065:	e8 16 fc ff ff       	call   800c80 <sys_env_set_status>

	   return envid;
  80106a:	83 c4 10             	add    $0x10,%esp
}
  80106d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801070:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801073:	5b                   	pop    %ebx
  801074:	5e                   	pop    %esi
  801075:	5f                   	pop    %edi
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <sfork>:
// Challenge!
	   int
sfork(void)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  80107e:	68 02 26 80 00       	push   $0x802602
  801083:	68 a7 00 00 00       	push   $0xa7
  801088:	68 8d 25 80 00       	push   $0x80258d
  80108d:	e8 c6 f0 ff ff       	call   800158 <_panic>

00801092 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
  801097:	8b 75 08             	mov    0x8(%ebp),%esi
  80109a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80109d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  8010a0:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  8010a2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8010a7:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  8010aa:	83 ec 0c             	sub    $0xc,%esp
  8010ad:	50                   	push   %eax
  8010ae:	e8 b6 fc ff ff       	call   800d69 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 0e                	js     8010c8 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  8010ba:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010c0:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  8010c3:	8b 52 78             	mov    0x78(%edx),%edx
  8010c6:	eb 0a                	jmp    8010d2 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  8010c8:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  8010cd:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  8010d2:	85 f6                	test   %esi,%esi
  8010d4:	74 02                	je     8010d8 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  8010d6:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  8010d8:	85 db                	test   %ebx,%ebx
  8010da:	74 02                	je     8010de <ipc_recv+0x4c>
			 *perm_store = s_perm;
  8010dc:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 08                	js     8010ea <ipc_recv+0x58>
  8010e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e7:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  8010ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	57                   	push   %edi
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801100:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801103:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801105:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  80110a:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  80110d:	ff 75 14             	pushl  0x14(%ebp)
  801110:	53                   	push   %ebx
  801111:	56                   	push   %esi
  801112:	57                   	push   %edi
  801113:	e8 2e fc ff ff       	call   800d46 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801118:	83 c4 10             	add    $0x10,%esp
  80111b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80111e:	75 07                	jne    801127 <ipc_send+0x36>
				    sys_yield();
  801120:	e8 75 fa ff ff       	call   800b9a <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801125:	eb e6                	jmp    80110d <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801127:	85 c0                	test   %eax,%eax
  801129:	74 12                	je     80113d <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  80112b:	50                   	push   %eax
  80112c:	68 18 26 80 00       	push   $0x802618
  801131:	6a 4b                	push   $0x4b
  801133:	68 2c 26 80 00       	push   $0x80262c
  801138:	e8 1b f0 ff ff       	call   800158 <_panic>
			 }
	   }
}
  80113d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801140:	5b                   	pop    %ebx
  801141:	5e                   	pop    %esi
  801142:	5f                   	pop    %edi
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801150:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801153:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801159:	8b 52 50             	mov    0x50(%edx),%edx
  80115c:	39 ca                	cmp    %ecx,%edx
  80115e:	75 0d                	jne    80116d <ipc_find_env+0x28>
				    return envs[i].env_id;
  801160:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801168:	8b 40 48             	mov    0x48(%eax),%eax
  80116b:	eb 0f                	jmp    80117c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  80116d:	83 c0 01             	add    $0x1,%eax
  801170:	3d 00 04 00 00       	cmp    $0x400,%eax
  801175:	75 d9                	jne    801150 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801177:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801181:	8b 45 08             	mov    0x8(%ebp),%eax
  801184:	05 00 00 00 30       	add    $0x30000000,%eax
  801189:	c1 e8 0c             	shr    $0xc,%eax
}
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    

0080118e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801191:	8b 45 08             	mov    0x8(%ebp),%eax
  801194:	05 00 00 00 30       	add    $0x30000000,%eax
  801199:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80119e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ab:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	c1 ea 16             	shr    $0x16,%edx
  8011b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bc:	f6 c2 01             	test   $0x1,%dl
  8011bf:	74 11                	je     8011d2 <fd_alloc+0x2d>
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	c1 ea 0c             	shr    $0xc,%edx
  8011c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cd:	f6 c2 01             	test   $0x1,%dl
  8011d0:	75 09                	jne    8011db <fd_alloc+0x36>
			*fd_store = fd;
  8011d2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d9:	eb 17                	jmp    8011f2 <fd_alloc+0x4d>
  8011db:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011e0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e5:	75 c9                	jne    8011b0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ed:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011fa:	83 f8 1f             	cmp    $0x1f,%eax
  8011fd:	77 36                	ja     801235 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ff:	c1 e0 0c             	shl    $0xc,%eax
  801202:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801207:	89 c2                	mov    %eax,%edx
  801209:	c1 ea 16             	shr    $0x16,%edx
  80120c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801213:	f6 c2 01             	test   $0x1,%dl
  801216:	74 24                	je     80123c <fd_lookup+0x48>
  801218:	89 c2                	mov    %eax,%edx
  80121a:	c1 ea 0c             	shr    $0xc,%edx
  80121d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801224:	f6 c2 01             	test   $0x1,%dl
  801227:	74 1a                	je     801243 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801229:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122c:	89 02                	mov    %eax,(%edx)
	return 0;
  80122e:	b8 00 00 00 00       	mov    $0x0,%eax
  801233:	eb 13                	jmp    801248 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801235:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123a:	eb 0c                	jmp    801248 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801241:	eb 05                	jmp    801248 <fd_lookup+0x54>
  801243:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	83 ec 08             	sub    $0x8,%esp
  801250:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801253:	ba b8 26 80 00       	mov    $0x8026b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801258:	eb 13                	jmp    80126d <dev_lookup+0x23>
  80125a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80125d:	39 08                	cmp    %ecx,(%eax)
  80125f:	75 0c                	jne    80126d <dev_lookup+0x23>
			*dev = devtab[i];
  801261:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801264:	89 01                	mov    %eax,(%ecx)
			return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
  80126b:	eb 2e                	jmp    80129b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126d:	8b 02                	mov    (%edx),%eax
  80126f:	85 c0                	test   %eax,%eax
  801271:	75 e7                	jne    80125a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801273:	a1 04 40 80 00       	mov    0x804004,%eax
  801278:	8b 40 48             	mov    0x48(%eax),%eax
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	51                   	push   %ecx
  80127f:	50                   	push   %eax
  801280:	68 38 26 80 00       	push   $0x802638
  801285:	e8 a7 ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  80128a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	56                   	push   %esi
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 10             	sub    $0x10,%esp
  8012a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b5:	c1 e8 0c             	shr    $0xc,%eax
  8012b8:	50                   	push   %eax
  8012b9:	e8 36 ff ff ff       	call   8011f4 <fd_lookup>
  8012be:	83 c4 08             	add    $0x8,%esp
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	78 05                	js     8012ca <fd_close+0x2d>
	    || fd != fd2)
  8012c5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c8:	74 0c                	je     8012d6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012ca:	84 db                	test   %bl,%bl
  8012cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d1:	0f 44 c2             	cmove  %edx,%eax
  8012d4:	eb 41                	jmp    801317 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012dc:	50                   	push   %eax
  8012dd:	ff 36                	pushl  (%esi)
  8012df:	e8 66 ff ff ff       	call   80124a <dev_lookup>
  8012e4:	89 c3                	mov    %eax,%ebx
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	78 1a                	js     801307 <fd_close+0x6a>
		if (dev->dev_close)
  8012ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	74 0b                	je     801307 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012fc:	83 ec 0c             	sub    $0xc,%esp
  8012ff:	56                   	push   %esi
  801300:	ff d0                	call   *%eax
  801302:	89 c3                	mov    %eax,%ebx
  801304:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	56                   	push   %esi
  80130b:	6a 00                	push   $0x0
  80130d:	e8 2c f9 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	89 d8                	mov    %ebx,%eax
}
  801317:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131a:	5b                   	pop    %ebx
  80131b:	5e                   	pop    %esi
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801324:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801327:	50                   	push   %eax
  801328:	ff 75 08             	pushl  0x8(%ebp)
  80132b:	e8 c4 fe ff ff       	call   8011f4 <fd_lookup>
  801330:	83 c4 08             	add    $0x8,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 10                	js     801347 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	6a 01                	push   $0x1
  80133c:	ff 75 f4             	pushl  -0xc(%ebp)
  80133f:	e8 59 ff ff ff       	call   80129d <fd_close>
  801344:	83 c4 10             	add    $0x10,%esp
}
  801347:	c9                   	leave  
  801348:	c3                   	ret    

00801349 <close_all>:

void
close_all(void)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	53                   	push   %ebx
  80134d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801350:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801355:	83 ec 0c             	sub    $0xc,%esp
  801358:	53                   	push   %ebx
  801359:	e8 c0 ff ff ff       	call   80131e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80135e:	83 c3 01             	add    $0x1,%ebx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	83 fb 20             	cmp    $0x20,%ebx
  801367:	75 ec                	jne    801355 <close_all+0xc>
		close(i);
}
  801369:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136c:	c9                   	leave  
  80136d:	c3                   	ret    

0080136e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	57                   	push   %edi
  801372:	56                   	push   %esi
  801373:	53                   	push   %ebx
  801374:	83 ec 2c             	sub    $0x2c,%esp
  801377:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80137a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137d:	50                   	push   %eax
  80137e:	ff 75 08             	pushl  0x8(%ebp)
  801381:	e8 6e fe ff ff       	call   8011f4 <fd_lookup>
  801386:	83 c4 08             	add    $0x8,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	0f 88 c1 00 00 00    	js     801452 <dup+0xe4>
		return r;
	close(newfdnum);
  801391:	83 ec 0c             	sub    $0xc,%esp
  801394:	56                   	push   %esi
  801395:	e8 84 ff ff ff       	call   80131e <close>

	newfd = INDEX2FD(newfdnum);
  80139a:	89 f3                	mov    %esi,%ebx
  80139c:	c1 e3 0c             	shl    $0xc,%ebx
  80139f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a5:	83 c4 04             	add    $0x4,%esp
  8013a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ab:	e8 de fd ff ff       	call   80118e <fd2data>
  8013b0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013b2:	89 1c 24             	mov    %ebx,(%esp)
  8013b5:	e8 d4 fd ff ff       	call   80118e <fd2data>
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013c0:	89 f8                	mov    %edi,%eax
  8013c2:	c1 e8 16             	shr    $0x16,%eax
  8013c5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013cc:	a8 01                	test   $0x1,%al
  8013ce:	74 37                	je     801407 <dup+0x99>
  8013d0:	89 f8                	mov    %edi,%eax
  8013d2:	c1 e8 0c             	shr    $0xc,%eax
  8013d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013dc:	f6 c2 01             	test   $0x1,%dl
  8013df:	74 26                	je     801407 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e8:	83 ec 0c             	sub    $0xc,%esp
  8013eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f0:	50                   	push   %eax
  8013f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f4:	6a 00                	push   $0x0
  8013f6:	57                   	push   %edi
  8013f7:	6a 00                	push   $0x0
  8013f9:	e8 fe f7 ff ff       	call   800bfc <sys_page_map>
  8013fe:	89 c7                	mov    %eax,%edi
  801400:	83 c4 20             	add    $0x20,%esp
  801403:	85 c0                	test   %eax,%eax
  801405:	78 2e                	js     801435 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801407:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80140a:	89 d0                	mov    %edx,%eax
  80140c:	c1 e8 0c             	shr    $0xc,%eax
  80140f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801416:	83 ec 0c             	sub    $0xc,%esp
  801419:	25 07 0e 00 00       	and    $0xe07,%eax
  80141e:	50                   	push   %eax
  80141f:	53                   	push   %ebx
  801420:	6a 00                	push   $0x0
  801422:	52                   	push   %edx
  801423:	6a 00                	push   $0x0
  801425:	e8 d2 f7 ff ff       	call   800bfc <sys_page_map>
  80142a:	89 c7                	mov    %eax,%edi
  80142c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80142f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801431:	85 ff                	test   %edi,%edi
  801433:	79 1d                	jns    801452 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	53                   	push   %ebx
  801439:	6a 00                	push   $0x0
  80143b:	e8 fe f7 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801440:	83 c4 08             	add    $0x8,%esp
  801443:	ff 75 d4             	pushl  -0x2c(%ebp)
  801446:	6a 00                	push   $0x0
  801448:	e8 f1 f7 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	89 f8                	mov    %edi,%eax
}
  801452:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5f                   	pop    %edi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 14             	sub    $0x14,%esp
  801461:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801464:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	53                   	push   %ebx
  801469:	e8 86 fd ff ff       	call   8011f4 <fd_lookup>
  80146e:	83 c4 08             	add    $0x8,%esp
  801471:	89 c2                	mov    %eax,%edx
  801473:	85 c0                	test   %eax,%eax
  801475:	78 6d                	js     8014e4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147d:	50                   	push   %eax
  80147e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801481:	ff 30                	pushl  (%eax)
  801483:	e8 c2 fd ff ff       	call   80124a <dev_lookup>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 4c                	js     8014db <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801492:	8b 42 08             	mov    0x8(%edx),%eax
  801495:	83 e0 03             	and    $0x3,%eax
  801498:	83 f8 01             	cmp    $0x1,%eax
  80149b:	75 21                	jne    8014be <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80149d:	a1 04 40 80 00       	mov    0x804004,%eax
  8014a2:	8b 40 48             	mov    0x48(%eax),%eax
  8014a5:	83 ec 04             	sub    $0x4,%esp
  8014a8:	53                   	push   %ebx
  8014a9:	50                   	push   %eax
  8014aa:	68 7c 26 80 00       	push   $0x80267c
  8014af:	e8 7d ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014bc:	eb 26                	jmp    8014e4 <read+0x8a>
	}
	if (!dev->dev_read)
  8014be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c1:	8b 40 08             	mov    0x8(%eax),%eax
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	74 17                	je     8014df <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c8:	83 ec 04             	sub    $0x4,%esp
  8014cb:	ff 75 10             	pushl  0x10(%ebp)
  8014ce:	ff 75 0c             	pushl  0xc(%ebp)
  8014d1:	52                   	push   %edx
  8014d2:	ff d0                	call   *%eax
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	eb 09                	jmp    8014e4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014db:	89 c2                	mov    %eax,%edx
  8014dd:	eb 05                	jmp    8014e4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014df:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014e4:	89 d0                	mov    %edx,%eax
  8014e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	57                   	push   %edi
  8014ef:	56                   	push   %esi
  8014f0:	53                   	push   %ebx
  8014f1:	83 ec 0c             	sub    $0xc,%esp
  8014f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ff:	eb 21                	jmp    801522 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	89 f0                	mov    %esi,%eax
  801506:	29 d8                	sub    %ebx,%eax
  801508:	50                   	push   %eax
  801509:	89 d8                	mov    %ebx,%eax
  80150b:	03 45 0c             	add    0xc(%ebp),%eax
  80150e:	50                   	push   %eax
  80150f:	57                   	push   %edi
  801510:	e8 45 ff ff ff       	call   80145a <read>
		if (m < 0)
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 10                	js     80152c <readn+0x41>
			return m;
		if (m == 0)
  80151c:	85 c0                	test   %eax,%eax
  80151e:	74 0a                	je     80152a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801520:	01 c3                	add    %eax,%ebx
  801522:	39 f3                	cmp    %esi,%ebx
  801524:	72 db                	jb     801501 <readn+0x16>
  801526:	89 d8                	mov    %ebx,%eax
  801528:	eb 02                	jmp    80152c <readn+0x41>
  80152a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80152c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152f:	5b                   	pop    %ebx
  801530:	5e                   	pop    %esi
  801531:	5f                   	pop    %edi
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    

00801534 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 14             	sub    $0x14,%esp
  80153b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	53                   	push   %ebx
  801543:	e8 ac fc ff ff       	call   8011f4 <fd_lookup>
  801548:	83 c4 08             	add    $0x8,%esp
  80154b:	89 c2                	mov    %eax,%edx
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 68                	js     8015b9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	ff 30                	pushl  (%eax)
  80155d:	e8 e8 fc ff ff       	call   80124a <dev_lookup>
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	85 c0                	test   %eax,%eax
  801567:	78 47                	js     8015b0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801569:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801570:	75 21                	jne    801593 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801572:	a1 04 40 80 00       	mov    0x804004,%eax
  801577:	8b 40 48             	mov    0x48(%eax),%eax
  80157a:	83 ec 04             	sub    $0x4,%esp
  80157d:	53                   	push   %ebx
  80157e:	50                   	push   %eax
  80157f:	68 98 26 80 00       	push   $0x802698
  801584:	e8 a8 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801591:	eb 26                	jmp    8015b9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801593:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801596:	8b 52 0c             	mov    0xc(%edx),%edx
  801599:	85 d2                	test   %edx,%edx
  80159b:	74 17                	je     8015b4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	ff 75 10             	pushl  0x10(%ebp)
  8015a3:	ff 75 0c             	pushl  0xc(%ebp)
  8015a6:	50                   	push   %eax
  8015a7:	ff d2                	call   *%edx
  8015a9:	89 c2                	mov    %eax,%edx
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	eb 09                	jmp    8015b9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b0:	89 c2                	mov    %eax,%edx
  8015b2:	eb 05                	jmp    8015b9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b9:	89 d0                	mov    %edx,%eax
  8015bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	ff 75 08             	pushl  0x8(%ebp)
  8015cd:	e8 22 fc ff ff       	call   8011f4 <fd_lookup>
  8015d2:	83 c4 08             	add    $0x8,%esp
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 0e                	js     8015e7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015df:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e7:	c9                   	leave  
  8015e8:	c3                   	ret    

008015e9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 14             	sub    $0x14,%esp
  8015f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	53                   	push   %ebx
  8015f8:	e8 f7 fb ff ff       	call   8011f4 <fd_lookup>
  8015fd:	83 c4 08             	add    $0x8,%esp
  801600:	89 c2                	mov    %eax,%edx
  801602:	85 c0                	test   %eax,%eax
  801604:	78 65                	js     80166b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801610:	ff 30                	pushl  (%eax)
  801612:	e8 33 fc ff ff       	call   80124a <dev_lookup>
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 44                	js     801662 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801621:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801625:	75 21                	jne    801648 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801627:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80162c:	8b 40 48             	mov    0x48(%eax),%eax
  80162f:	83 ec 04             	sub    $0x4,%esp
  801632:	53                   	push   %ebx
  801633:	50                   	push   %eax
  801634:	68 58 26 80 00       	push   $0x802658
  801639:	e8 f3 eb ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801646:	eb 23                	jmp    80166b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801648:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164b:	8b 52 18             	mov    0x18(%edx),%edx
  80164e:	85 d2                	test   %edx,%edx
  801650:	74 14                	je     801666 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	ff 75 0c             	pushl  0xc(%ebp)
  801658:	50                   	push   %eax
  801659:	ff d2                	call   *%edx
  80165b:	89 c2                	mov    %eax,%edx
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	eb 09                	jmp    80166b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801662:	89 c2                	mov    %eax,%edx
  801664:	eb 05                	jmp    80166b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801666:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80166b:	89 d0                	mov    %edx,%eax
  80166d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	53                   	push   %ebx
  801676:	83 ec 14             	sub    $0x14,%esp
  801679:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167f:	50                   	push   %eax
  801680:	ff 75 08             	pushl  0x8(%ebp)
  801683:	e8 6c fb ff ff       	call   8011f4 <fd_lookup>
  801688:	83 c4 08             	add    $0x8,%esp
  80168b:	89 c2                	mov    %eax,%edx
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 58                	js     8016e9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801691:	83 ec 08             	sub    $0x8,%esp
  801694:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801697:	50                   	push   %eax
  801698:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169b:	ff 30                	pushl  (%eax)
  80169d:	e8 a8 fb ff ff       	call   80124a <dev_lookup>
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	78 37                	js     8016e0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ac:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016b0:	74 32                	je     8016e4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016b5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016bc:	00 00 00 
	stat->st_isdir = 0;
  8016bf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c6:	00 00 00 
	stat->st_dev = dev;
  8016c9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	53                   	push   %ebx
  8016d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d6:	ff 50 14             	call   *0x14(%eax)
  8016d9:	89 c2                	mov    %eax,%edx
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	eb 09                	jmp    8016e9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	eb 05                	jmp    8016e9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e9:	89 d0                	mov    %edx,%eax
  8016eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f5:	83 ec 08             	sub    $0x8,%esp
  8016f8:	6a 00                	push   $0x0
  8016fa:	ff 75 08             	pushl  0x8(%ebp)
  8016fd:	e8 2c 02 00 00       	call   80192e <open>
  801702:	89 c3                	mov    %eax,%ebx
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	78 1b                	js     801726 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80170b:	83 ec 08             	sub    $0x8,%esp
  80170e:	ff 75 0c             	pushl  0xc(%ebp)
  801711:	50                   	push   %eax
  801712:	e8 5b ff ff ff       	call   801672 <fstat>
  801717:	89 c6                	mov    %eax,%esi
	close(fd);
  801719:	89 1c 24             	mov    %ebx,(%esp)
  80171c:	e8 fd fb ff ff       	call   80131e <close>
	return r;
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	89 f0                	mov    %esi,%eax
}
  801726:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801729:	5b                   	pop    %ebx
  80172a:	5e                   	pop    %esi
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	56                   	push   %esi
  801731:	53                   	push   %ebx
  801732:	89 c6                	mov    %eax,%esi
  801734:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  801736:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80173d:	75 12                	jne    801751 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  80173f:	83 ec 0c             	sub    $0xc,%esp
  801742:	6a 01                	push   $0x1
  801744:	e8 fc f9 ff ff       	call   801145 <ipc_find_env>
  801749:	a3 00 40 80 00       	mov    %eax,0x804000
  80174e:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801751:	6a 07                	push   $0x7
  801753:	68 00 50 80 00       	push   $0x805000
  801758:	56                   	push   %esi
  801759:	ff 35 00 40 80 00    	pushl  0x804000
  80175f:	e8 8d f9 ff ff       	call   8010f1 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  801764:	83 c4 0c             	add    $0xc,%esp
  801767:	6a 00                	push   $0x0
  801769:	53                   	push   %ebx
  80176a:	6a 00                	push   $0x0
  80176c:	e8 21 f9 ff ff       	call   801092 <ipc_recv>
}
  801771:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	8b 40 0c             	mov    0xc(%eax),%eax
  801784:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  801789:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178c:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  801791:	ba 00 00 00 00       	mov    $0x0,%edx
  801796:	b8 02 00 00 00       	mov    $0x2,%eax
  80179b:	e8 8d ff ff ff       	call   80172d <fsipc>
}
  8017a0:	c9                   	leave  
  8017a1:	c3                   	ret    

008017a2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ae:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  8017b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b8:	b8 06 00 00 00       	mov    $0x6,%eax
  8017bd:	e8 6b ff ff ff       	call   80172d <fsipc>
}
  8017c2:	c9                   	leave  
  8017c3:	c3                   	ret    

008017c4 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 04             	sub    $0x4,%esp
  8017cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d4:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017de:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e3:	e8 45 ff ff ff       	call   80172d <fsipc>
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 2c                	js     801818 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	68 00 50 80 00       	push   $0x805000
  8017f4:	53                   	push   %ebx
  8017f5:	e8 bc ef ff ff       	call   8007b6 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8017fa:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801805:	a1 84 50 80 00       	mov    0x805084,%eax
  80180a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801818:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181b:	c9                   	leave  
  80181c:	c3                   	ret    

0080181d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	53                   	push   %ebx
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	8b 40 0c             	mov    0xc(%eax),%eax
  80182d:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  801832:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  801838:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  80183e:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801843:	0f 46 c3             	cmovbe %ebx,%eax
  801846:	50                   	push   %eax
  801847:	ff 75 0c             	pushl  0xc(%ebp)
  80184a:	68 08 50 80 00       	push   $0x805008
  80184f:	e8 f4 f0 ff ff       	call   800948 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  801854:	ba 00 00 00 00       	mov    $0x0,%edx
  801859:	b8 04 00 00 00       	mov    $0x4,%eax
  80185e:	e8 ca fe ff ff       	call   80172d <fsipc>
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	85 c0                	test   %eax,%eax
  801868:	78 3d                	js     8018a7 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  80186a:	39 c3                	cmp    %eax,%ebx
  80186c:	73 19                	jae    801887 <devfile_write+0x6a>
  80186e:	68 c8 26 80 00       	push   $0x8026c8
  801873:	68 cf 26 80 00       	push   $0x8026cf
  801878:	68 9a 00 00 00       	push   $0x9a
  80187d:	68 e4 26 80 00       	push   $0x8026e4
  801882:	e8 d1 e8 ff ff       	call   800158 <_panic>
	   assert (r <= bytes_written);
  801887:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80188c:	7e 19                	jle    8018a7 <devfile_write+0x8a>
  80188e:	68 ef 26 80 00       	push   $0x8026ef
  801893:	68 cf 26 80 00       	push   $0x8026cf
  801898:	68 9b 00 00 00       	push   $0x9b
  80189d:	68 e4 26 80 00       	push   $0x8026e4
  8018a2:	e8 b1 e8 ff ff       	call   800158 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  8018a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ba:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  8018bf:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ca:	b8 03 00 00 00       	mov    $0x3,%eax
  8018cf:	e8 59 fe ff ff       	call   80172d <fsipc>
  8018d4:	89 c3                	mov    %eax,%ebx
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	78 4b                	js     801925 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  8018da:	39 c6                	cmp    %eax,%esi
  8018dc:	73 16                	jae    8018f4 <devfile_read+0x48>
  8018de:	68 c8 26 80 00       	push   $0x8026c8
  8018e3:	68 cf 26 80 00       	push   $0x8026cf
  8018e8:	6a 7c                	push   $0x7c
  8018ea:	68 e4 26 80 00       	push   $0x8026e4
  8018ef:	e8 64 e8 ff ff       	call   800158 <_panic>
	   assert(r <= PGSIZE);
  8018f4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f9:	7e 16                	jle    801911 <devfile_read+0x65>
  8018fb:	68 02 27 80 00       	push   $0x802702
  801900:	68 cf 26 80 00       	push   $0x8026cf
  801905:	6a 7d                	push   $0x7d
  801907:	68 e4 26 80 00       	push   $0x8026e4
  80190c:	e8 47 e8 ff ff       	call   800158 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801911:	83 ec 04             	sub    $0x4,%esp
  801914:	50                   	push   %eax
  801915:	68 00 50 80 00       	push   $0x805000
  80191a:	ff 75 0c             	pushl  0xc(%ebp)
  80191d:	e8 26 f0 ff ff       	call   800948 <memmove>
	   return r;
  801922:	83 c4 10             	add    $0x10,%esp
}
  801925:	89 d8                	mov    %ebx,%eax
  801927:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192a:	5b                   	pop    %ebx
  80192b:	5e                   	pop    %esi
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    

0080192e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	53                   	push   %ebx
  801932:	83 ec 20             	sub    $0x20,%esp
  801935:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  801938:	53                   	push   %ebx
  801939:	e8 3f ee ff ff       	call   80077d <strlen>
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801946:	7f 67                	jg     8019af <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801948:	83 ec 0c             	sub    $0xc,%esp
  80194b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194e:	50                   	push   %eax
  80194f:	e8 51 f8 ff ff       	call   8011a5 <fd_alloc>
  801954:	83 c4 10             	add    $0x10,%esp
			 return r;
  801957:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801959:	85 c0                	test   %eax,%eax
  80195b:	78 57                	js     8019b4 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  80195d:	83 ec 08             	sub    $0x8,%esp
  801960:	53                   	push   %ebx
  801961:	68 00 50 80 00       	push   $0x805000
  801966:	e8 4b ee ff ff       	call   8007b6 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  80196b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196e:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801973:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801976:	b8 01 00 00 00       	mov    $0x1,%eax
  80197b:	e8 ad fd ff ff       	call   80172d <fsipc>
  801980:	89 c3                	mov    %eax,%ebx
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	85 c0                	test   %eax,%eax
  801987:	79 14                	jns    80199d <open+0x6f>
			 fd_close(fd, 0);
  801989:	83 ec 08             	sub    $0x8,%esp
  80198c:	6a 00                	push   $0x0
  80198e:	ff 75 f4             	pushl  -0xc(%ebp)
  801991:	e8 07 f9 ff ff       	call   80129d <fd_close>
			 return r;
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	89 da                	mov    %ebx,%edx
  80199b:	eb 17                	jmp    8019b4 <open+0x86>
	   }

	   return fd2num(fd);
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a3:	e8 d6 f7 ff ff       	call   80117e <fd2num>
  8019a8:	89 c2                	mov    %eax,%edx
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	eb 05                	jmp    8019b4 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  8019af:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  8019b4:	89 d0                	mov    %edx,%eax
  8019b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  8019c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c6:	b8 08 00 00 00       	mov    $0x8,%eax
  8019cb:	e8 5d fd ff ff       	call   80172d <fsipc>
}
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	56                   	push   %esi
  8019d6:	53                   	push   %ebx
  8019d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019da:	83 ec 0c             	sub    $0xc,%esp
  8019dd:	ff 75 08             	pushl  0x8(%ebp)
  8019e0:	e8 a9 f7 ff ff       	call   80118e <fd2data>
  8019e5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e7:	83 c4 08             	add    $0x8,%esp
  8019ea:	68 0e 27 80 00       	push   $0x80270e
  8019ef:	53                   	push   %ebx
  8019f0:	e8 c1 ed ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019f5:	8b 46 04             	mov    0x4(%esi),%eax
  8019f8:	2b 06                	sub    (%esi),%eax
  8019fa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a00:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a07:	00 00 00 
	stat->st_dev = &devpipe;
  801a0a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a11:	30 80 00 
	return 0;
}
  801a14:	b8 00 00 00 00       	mov    $0x0,%eax
  801a19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1c:	5b                   	pop    %ebx
  801a1d:	5e                   	pop    %esi
  801a1e:	5d                   	pop    %ebp
  801a1f:	c3                   	ret    

00801a20 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	53                   	push   %ebx
  801a24:	83 ec 0c             	sub    $0xc,%esp
  801a27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a2a:	53                   	push   %ebx
  801a2b:	6a 00                	push   $0x0
  801a2d:	e8 0c f2 ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a32:	89 1c 24             	mov    %ebx,(%esp)
  801a35:	e8 54 f7 ff ff       	call   80118e <fd2data>
  801a3a:	83 c4 08             	add    $0x8,%esp
  801a3d:	50                   	push   %eax
  801a3e:	6a 00                	push   $0x0
  801a40:	e8 f9 f1 ff ff       	call   800c3e <sys_page_unmap>
}
  801a45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	57                   	push   %edi
  801a4e:	56                   	push   %esi
  801a4f:	53                   	push   %ebx
  801a50:	83 ec 1c             	sub    $0x1c,%esp
  801a53:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a56:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a58:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	ff 75 e0             	pushl  -0x20(%ebp)
  801a66:	e8 c5 04 00 00       	call   801f30 <pageref>
  801a6b:	89 c3                	mov    %eax,%ebx
  801a6d:	89 3c 24             	mov    %edi,(%esp)
  801a70:	e8 bb 04 00 00       	call   801f30 <pageref>
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	39 c3                	cmp    %eax,%ebx
  801a7a:	0f 94 c1             	sete   %cl
  801a7d:	0f b6 c9             	movzbl %cl,%ecx
  801a80:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a83:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a89:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a8c:	39 ce                	cmp    %ecx,%esi
  801a8e:	74 1b                	je     801aab <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a90:	39 c3                	cmp    %eax,%ebx
  801a92:	75 c4                	jne    801a58 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a94:	8b 42 58             	mov    0x58(%edx),%eax
  801a97:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a9a:	50                   	push   %eax
  801a9b:	56                   	push   %esi
  801a9c:	68 15 27 80 00       	push   $0x802715
  801aa1:	e8 8b e7 ff ff       	call   800231 <cprintf>
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	eb ad                	jmp    801a58 <_pipeisclosed+0xe>
	}
}
  801aab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5e                   	pop    %esi
  801ab3:	5f                   	pop    %edi
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    

00801ab6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	57                   	push   %edi
  801aba:	56                   	push   %esi
  801abb:	53                   	push   %ebx
  801abc:	83 ec 28             	sub    $0x28,%esp
  801abf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ac2:	56                   	push   %esi
  801ac3:	e8 c6 f6 ff ff       	call   80118e <fd2data>
  801ac8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	bf 00 00 00 00       	mov    $0x0,%edi
  801ad2:	eb 4b                	jmp    801b1f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ad4:	89 da                	mov    %ebx,%edx
  801ad6:	89 f0                	mov    %esi,%eax
  801ad8:	e8 6d ff ff ff       	call   801a4a <_pipeisclosed>
  801add:	85 c0                	test   %eax,%eax
  801adf:	75 48                	jne    801b29 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ae1:	e8 b4 f0 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae6:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae9:	8b 0b                	mov    (%ebx),%ecx
  801aeb:	8d 51 20             	lea    0x20(%ecx),%edx
  801aee:	39 d0                	cmp    %edx,%eax
  801af0:	73 e2                	jae    801ad4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801af9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801afc:	89 c2                	mov    %eax,%edx
  801afe:	c1 fa 1f             	sar    $0x1f,%edx
  801b01:	89 d1                	mov    %edx,%ecx
  801b03:	c1 e9 1b             	shr    $0x1b,%ecx
  801b06:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b09:	83 e2 1f             	and    $0x1f,%edx
  801b0c:	29 ca                	sub    %ecx,%edx
  801b0e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b12:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b16:	83 c0 01             	add    $0x1,%eax
  801b19:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1c:	83 c7 01             	add    $0x1,%edi
  801b1f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b22:	75 c2                	jne    801ae6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b24:	8b 45 10             	mov    0x10(%ebp),%eax
  801b27:	eb 05                	jmp    801b2e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b29:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b31:	5b                   	pop    %ebx
  801b32:	5e                   	pop    %esi
  801b33:	5f                   	pop    %edi
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	57                   	push   %edi
  801b3a:	56                   	push   %esi
  801b3b:	53                   	push   %ebx
  801b3c:	83 ec 18             	sub    $0x18,%esp
  801b3f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b42:	57                   	push   %edi
  801b43:	e8 46 f6 ff ff       	call   80118e <fd2data>
  801b48:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b52:	eb 3d                	jmp    801b91 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b54:	85 db                	test   %ebx,%ebx
  801b56:	74 04                	je     801b5c <devpipe_read+0x26>
				return i;
  801b58:	89 d8                	mov    %ebx,%eax
  801b5a:	eb 44                	jmp    801ba0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b5c:	89 f2                	mov    %esi,%edx
  801b5e:	89 f8                	mov    %edi,%eax
  801b60:	e8 e5 fe ff ff       	call   801a4a <_pipeisclosed>
  801b65:	85 c0                	test   %eax,%eax
  801b67:	75 32                	jne    801b9b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b69:	e8 2c f0 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b6e:	8b 06                	mov    (%esi),%eax
  801b70:	3b 46 04             	cmp    0x4(%esi),%eax
  801b73:	74 df                	je     801b54 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b75:	99                   	cltd   
  801b76:	c1 ea 1b             	shr    $0x1b,%edx
  801b79:	01 d0                	add    %edx,%eax
  801b7b:	83 e0 1f             	and    $0x1f,%eax
  801b7e:	29 d0                	sub    %edx,%eax
  801b80:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b88:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b8b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8e:	83 c3 01             	add    $0x1,%ebx
  801b91:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b94:	75 d8                	jne    801b6e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b96:	8b 45 10             	mov    0x10(%ebp),%eax
  801b99:	eb 05                	jmp    801ba0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b9b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba3:	5b                   	pop    %ebx
  801ba4:	5e                   	pop    %esi
  801ba5:	5f                   	pop    %edi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    

00801ba8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	56                   	push   %esi
  801bac:	53                   	push   %ebx
  801bad:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb3:	50                   	push   %eax
  801bb4:	e8 ec f5 ff ff       	call   8011a5 <fd_alloc>
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	89 c2                	mov    %eax,%edx
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	0f 88 2c 01 00 00    	js     801cf2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc6:	83 ec 04             	sub    $0x4,%esp
  801bc9:	68 07 04 00 00       	push   $0x407
  801bce:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd1:	6a 00                	push   $0x0
  801bd3:	e8 e1 ef ff ff       	call   800bb9 <sys_page_alloc>
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	89 c2                	mov    %eax,%edx
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	0f 88 0d 01 00 00    	js     801cf2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801be5:	83 ec 0c             	sub    $0xc,%esp
  801be8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801beb:	50                   	push   %eax
  801bec:	e8 b4 f5 ff ff       	call   8011a5 <fd_alloc>
  801bf1:	89 c3                	mov    %eax,%ebx
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	0f 88 e2 00 00 00    	js     801ce0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfe:	83 ec 04             	sub    $0x4,%esp
  801c01:	68 07 04 00 00       	push   $0x407
  801c06:	ff 75 f0             	pushl  -0x10(%ebp)
  801c09:	6a 00                	push   $0x0
  801c0b:	e8 a9 ef ff ff       	call   800bb9 <sys_page_alloc>
  801c10:	89 c3                	mov    %eax,%ebx
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	85 c0                	test   %eax,%eax
  801c17:	0f 88 c3 00 00 00    	js     801ce0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c1d:	83 ec 0c             	sub    $0xc,%esp
  801c20:	ff 75 f4             	pushl  -0xc(%ebp)
  801c23:	e8 66 f5 ff ff       	call   80118e <fd2data>
  801c28:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2a:	83 c4 0c             	add    $0xc,%esp
  801c2d:	68 07 04 00 00       	push   $0x407
  801c32:	50                   	push   %eax
  801c33:	6a 00                	push   $0x0
  801c35:	e8 7f ef ff ff       	call   800bb9 <sys_page_alloc>
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	0f 88 89 00 00 00    	js     801cd0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c47:	83 ec 0c             	sub    $0xc,%esp
  801c4a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4d:	e8 3c f5 ff ff       	call   80118e <fd2data>
  801c52:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c59:	50                   	push   %eax
  801c5a:	6a 00                	push   $0x0
  801c5c:	56                   	push   %esi
  801c5d:	6a 00                	push   $0x0
  801c5f:	e8 98 ef ff ff       	call   800bfc <sys_page_map>
  801c64:	89 c3                	mov    %eax,%ebx
  801c66:	83 c4 20             	add    $0x20,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	78 55                	js     801cc2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c6d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c76:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c82:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c8b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c90:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c97:	83 ec 0c             	sub    $0xc,%esp
  801c9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9d:	e8 dc f4 ff ff       	call   80117e <fd2num>
  801ca2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ca7:	83 c4 04             	add    $0x4,%esp
  801caa:	ff 75 f0             	pushl  -0x10(%ebp)
  801cad:	e8 cc f4 ff ff       	call   80117e <fd2num>
  801cb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc0:	eb 30                	jmp    801cf2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cc2:	83 ec 08             	sub    $0x8,%esp
  801cc5:	56                   	push   %esi
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 71 ef ff ff       	call   800c3e <sys_page_unmap>
  801ccd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cd0:	83 ec 08             	sub    $0x8,%esp
  801cd3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd6:	6a 00                	push   $0x0
  801cd8:	e8 61 ef ff ff       	call   800c3e <sys_page_unmap>
  801cdd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ce0:	83 ec 08             	sub    $0x8,%esp
  801ce3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 51 ef ff ff       	call   800c3e <sys_page_unmap>
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cf2:	89 d0                	mov    %edx,%eax
  801cf4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf7:	5b                   	pop    %ebx
  801cf8:	5e                   	pop    %esi
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d04:	50                   	push   %eax
  801d05:	ff 75 08             	pushl  0x8(%ebp)
  801d08:	e8 e7 f4 ff ff       	call   8011f4 <fd_lookup>
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	85 c0                	test   %eax,%eax
  801d12:	78 18                	js     801d2c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d14:	83 ec 0c             	sub    $0xc,%esp
  801d17:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1a:	e8 6f f4 ff ff       	call   80118e <fd2data>
	return _pipeisclosed(fd, p);
  801d1f:	89 c2                	mov    %eax,%edx
  801d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d24:	e8 21 fd ff ff       	call   801a4a <_pipeisclosed>
  801d29:	83 c4 10             	add    $0x10,%esp
}
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    

00801d2e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d31:	b8 00 00 00 00       	mov    $0x0,%eax
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    

00801d38 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d3e:	68 2d 27 80 00       	push   $0x80272d
  801d43:	ff 75 0c             	pushl  0xc(%ebp)
  801d46:	e8 6b ea ff ff       	call   8007b6 <strcpy>
	return 0;
}
  801d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d50:	c9                   	leave  
  801d51:	c3                   	ret    

00801d52 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	57                   	push   %edi
  801d56:	56                   	push   %esi
  801d57:	53                   	push   %ebx
  801d58:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d63:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d69:	eb 2d                	jmp    801d98 <devcons_write+0x46>
		m = n - tot;
  801d6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d6e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d70:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d73:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d78:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d7b:	83 ec 04             	sub    $0x4,%esp
  801d7e:	53                   	push   %ebx
  801d7f:	03 45 0c             	add    0xc(%ebp),%eax
  801d82:	50                   	push   %eax
  801d83:	57                   	push   %edi
  801d84:	e8 bf eb ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  801d89:	83 c4 08             	add    $0x8,%esp
  801d8c:	53                   	push   %ebx
  801d8d:	57                   	push   %edi
  801d8e:	e8 6a ed ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d93:	01 de                	add    %ebx,%esi
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	89 f0                	mov    %esi,%eax
  801d9a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d9d:	72 cc                	jb     801d6b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da2:	5b                   	pop    %ebx
  801da3:	5e                   	pop    %esi
  801da4:	5f                   	pop    %edi
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801db2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801db6:	74 2a                	je     801de2 <devcons_read+0x3b>
  801db8:	eb 05                	jmp    801dbf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dba:	e8 db ed ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dbf:	e8 57 ed ff ff       	call   800b1b <sys_cgetc>
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	74 f2                	je     801dba <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	78 16                	js     801de2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dcc:	83 f8 04             	cmp    $0x4,%eax
  801dcf:	74 0c                	je     801ddd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd4:	88 02                	mov    %al,(%edx)
	return 1;
  801dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ddb:	eb 05                	jmp    801de2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ddd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801de2:	c9                   	leave  
  801de3:	c3                   	ret    

00801de4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ded:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801df0:	6a 01                	push   $0x1
  801df2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df5:	50                   	push   %eax
  801df6:	e8 02 ed ff ff       	call   800afd <sys_cputs>
}
  801dfb:	83 c4 10             	add    $0x10,%esp
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <getchar>:

int
getchar(void)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e06:	6a 01                	push   $0x1
  801e08:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	6a 00                	push   $0x0
  801e0e:	e8 47 f6 ff ff       	call   80145a <read>
	if (r < 0)
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	85 c0                	test   %eax,%eax
  801e18:	78 0f                	js     801e29 <getchar+0x29>
		return r;
	if (r < 1)
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	7e 06                	jle    801e24 <getchar+0x24>
		return -E_EOF;
	return c;
  801e1e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e22:	eb 05                	jmp    801e29 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e24:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    

00801e2b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e34:	50                   	push   %eax
  801e35:	ff 75 08             	pushl  0x8(%ebp)
  801e38:	e8 b7 f3 ff ff       	call   8011f4 <fd_lookup>
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	85 c0                	test   %eax,%eax
  801e42:	78 11                	js     801e55 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e47:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e4d:	39 10                	cmp    %edx,(%eax)
  801e4f:	0f 94 c0             	sete   %al
  801e52:	0f b6 c0             	movzbl %al,%eax
}
  801e55:	c9                   	leave  
  801e56:	c3                   	ret    

00801e57 <opencons>:

int
opencons(void)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e60:	50                   	push   %eax
  801e61:	e8 3f f3 ff ff       	call   8011a5 <fd_alloc>
  801e66:	83 c4 10             	add    $0x10,%esp
		return r;
  801e69:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 3e                	js     801ead <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e6f:	83 ec 04             	sub    $0x4,%esp
  801e72:	68 07 04 00 00       	push   $0x407
  801e77:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7a:	6a 00                	push   $0x0
  801e7c:	e8 38 ed ff ff       	call   800bb9 <sys_page_alloc>
  801e81:	83 c4 10             	add    $0x10,%esp
		return r;
  801e84:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 23                	js     801ead <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e8a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e93:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e98:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e9f:	83 ec 0c             	sub    $0xc,%esp
  801ea2:	50                   	push   %eax
  801ea3:	e8 d6 f2 ff ff       	call   80117e <fd2num>
  801ea8:	89 c2                	mov    %eax,%edx
  801eaa:	83 c4 10             	add    $0x10,%esp
}
  801ead:	89 d0                	mov    %edx,%eax
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  801eb7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ebe:	75 2a                	jne    801eea <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801ec0:	83 ec 04             	sub    $0x4,%esp
  801ec3:	6a 06                	push   $0x6
  801ec5:	68 00 f0 bf ee       	push   $0xeebff000
  801eca:	6a 00                	push   $0x0
  801ecc:	e8 e8 ec ff ff       	call   800bb9 <sys_page_alloc>
			 if (a < 0)
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	79 12                	jns    801eea <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801ed8:	50                   	push   %eax
  801ed9:	68 39 27 80 00       	push   $0x802739
  801ede:	6a 21                	push   $0x21
  801ee0:	68 53 27 80 00       	push   $0x802753
  801ee5:	e8 6e e2 ff ff       	call   800158 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  801eea:	e8 8c ec ff ff       	call   800b7b <sys_getenvid>
  801eef:	83 ec 08             	sub    $0x8,%esp
  801ef2:	68 0a 1f 80 00       	push   $0x801f0a
  801ef7:	50                   	push   %eax
  801ef8:	e8 07 ee ff ff       	call   800d04 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  801efd:	8b 45 08             	mov    0x8(%ebp),%eax
  801f00:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f05:	83 c4 10             	add    $0x10,%esp
  801f08:	c9                   	leave  
  801f09:	c3                   	ret    

00801f0a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  801f0a:	54                   	push   %esp
movl _pgfault_handler, %eax
  801f0b:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  801f10:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  801f12:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  801f15:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  801f19:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  801f1d:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  801f20:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  801f24:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  801f26:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  801f29:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  801f2a:	83 c4 04             	add    $0x4,%esp
popfl
  801f2d:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  801f2e:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  801f2f:	c3                   	ret    

00801f30 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f36:	89 d0                	mov    %edx,%eax
  801f38:	c1 e8 16             	shr    $0x16,%eax
  801f3b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f42:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f47:	f6 c1 01             	test   $0x1,%cl
  801f4a:	74 1d                	je     801f69 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f4c:	c1 ea 0c             	shr    $0xc,%edx
  801f4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f56:	f6 c2 01             	test   $0x1,%dl
  801f59:	74 0e                	je     801f69 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f5b:	c1 ea 0c             	shr    $0xc,%edx
  801f5e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f65:	ef 
  801f66:	0f b7 c0             	movzwl %ax,%eax
}
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    
  801f6b:	66 90                	xchg   %ax,%ax
  801f6d:	66 90                	xchg   %ax,%ax
  801f6f:	90                   	nop

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f87:	85 f6                	test   %esi,%esi
  801f89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f8d:	89 ca                	mov    %ecx,%edx
  801f8f:	89 f8                	mov    %edi,%eax
  801f91:	75 3d                	jne    801fd0 <__udivdi3+0x60>
  801f93:	39 cf                	cmp    %ecx,%edi
  801f95:	0f 87 c5 00 00 00    	ja     802060 <__udivdi3+0xf0>
  801f9b:	85 ff                	test   %edi,%edi
  801f9d:	89 fd                	mov    %edi,%ebp
  801f9f:	75 0b                	jne    801fac <__udivdi3+0x3c>
  801fa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa6:	31 d2                	xor    %edx,%edx
  801fa8:	f7 f7                	div    %edi
  801faa:	89 c5                	mov    %eax,%ebp
  801fac:	89 c8                	mov    %ecx,%eax
  801fae:	31 d2                	xor    %edx,%edx
  801fb0:	f7 f5                	div    %ebp
  801fb2:	89 c1                	mov    %eax,%ecx
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	89 cf                	mov    %ecx,%edi
  801fb8:	f7 f5                	div    %ebp
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	39 ce                	cmp    %ecx,%esi
  801fd2:	77 74                	ja     802048 <__udivdi3+0xd8>
  801fd4:	0f bd fe             	bsr    %esi,%edi
  801fd7:	83 f7 1f             	xor    $0x1f,%edi
  801fda:	0f 84 98 00 00 00    	je     802078 <__udivdi3+0x108>
  801fe0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	89 c5                	mov    %eax,%ebp
  801fe9:	29 fb                	sub    %edi,%ebx
  801feb:	d3 e6                	shl    %cl,%esi
  801fed:	89 d9                	mov    %ebx,%ecx
  801fef:	d3 ed                	shr    %cl,%ebp
  801ff1:	89 f9                	mov    %edi,%ecx
  801ff3:	d3 e0                	shl    %cl,%eax
  801ff5:	09 ee                	or     %ebp,%esi
  801ff7:	89 d9                	mov    %ebx,%ecx
  801ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffd:	89 d5                	mov    %edx,%ebp
  801fff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802003:	d3 ed                	shr    %cl,%ebp
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e2                	shl    %cl,%edx
  802009:	89 d9                	mov    %ebx,%ecx
  80200b:	d3 e8                	shr    %cl,%eax
  80200d:	09 c2                	or     %eax,%edx
  80200f:	89 d0                	mov    %edx,%eax
  802011:	89 ea                	mov    %ebp,%edx
  802013:	f7 f6                	div    %esi
  802015:	89 d5                	mov    %edx,%ebp
  802017:	89 c3                	mov    %eax,%ebx
  802019:	f7 64 24 0c          	mull   0xc(%esp)
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	72 10                	jb     802031 <__udivdi3+0xc1>
  802021:	8b 74 24 08          	mov    0x8(%esp),%esi
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e6                	shl    %cl,%esi
  802029:	39 c6                	cmp    %eax,%esi
  80202b:	73 07                	jae    802034 <__udivdi3+0xc4>
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	75 03                	jne    802034 <__udivdi3+0xc4>
  802031:	83 eb 01             	sub    $0x1,%ebx
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 d8                	mov    %ebx,%eax
  802038:	89 fa                	mov    %edi,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	31 ff                	xor    %edi,%edi
  80204a:	31 db                	xor    %ebx,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d8                	mov    %ebx,%eax
  802062:	f7 f7                	div    %edi
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 c3                	mov    %eax,%ebx
  802068:	89 d8                	mov    %ebx,%eax
  80206a:	89 fa                	mov    %edi,%edx
  80206c:	83 c4 1c             	add    $0x1c,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	39 ce                	cmp    %ecx,%esi
  80207a:	72 0c                	jb     802088 <__udivdi3+0x118>
  80207c:	31 db                	xor    %ebx,%ebx
  80207e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802082:	0f 87 34 ff ff ff    	ja     801fbc <__udivdi3+0x4c>
  802088:	bb 01 00 00 00       	mov    $0x1,%ebx
  80208d:	e9 2a ff ff ff       	jmp    801fbc <__udivdi3+0x4c>
  802092:	66 90                	xchg   %ax,%ax
  802094:	66 90                	xchg   %ax,%ax
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 d2                	test   %edx,%edx
  8020b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f3                	mov    %esi,%ebx
  8020c3:	89 3c 24             	mov    %edi,(%esp)
  8020c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ca:	75 1c                	jne    8020e8 <__umoddi3+0x48>
  8020cc:	39 f7                	cmp    %esi,%edi
  8020ce:	76 50                	jbe    802120 <__umoddi3+0x80>
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	f7 f7                	div    %edi
  8020d6:	89 d0                	mov    %edx,%eax
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	89 d0                	mov    %edx,%eax
  8020ec:	77 52                	ja     802140 <__umoddi3+0xa0>
  8020ee:	0f bd ea             	bsr    %edx,%ebp
  8020f1:	83 f5 1f             	xor    $0x1f,%ebp
  8020f4:	75 5a                	jne    802150 <__umoddi3+0xb0>
  8020f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020fa:	0f 82 e0 00 00 00    	jb     8021e0 <__umoddi3+0x140>
  802100:	39 0c 24             	cmp    %ecx,(%esp)
  802103:	0f 86 d7 00 00 00    	jbe    8021e0 <__umoddi3+0x140>
  802109:	8b 44 24 08          	mov    0x8(%esp),%eax
  80210d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802111:	83 c4 1c             	add    $0x1c,%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	85 ff                	test   %edi,%edi
  802122:	89 fd                	mov    %edi,%ebp
  802124:	75 0b                	jne    802131 <__umoddi3+0x91>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f7                	div    %edi
  80212f:	89 c5                	mov    %eax,%ebp
  802131:	89 f0                	mov    %esi,%eax
  802133:	31 d2                	xor    %edx,%edx
  802135:	f7 f5                	div    %ebp
  802137:	89 c8                	mov    %ecx,%eax
  802139:	f7 f5                	div    %ebp
  80213b:	89 d0                	mov    %edx,%eax
  80213d:	eb 99                	jmp    8020d8 <__umoddi3+0x38>
  80213f:	90                   	nop
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	83 c4 1c             	add    $0x1c,%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	8b 34 24             	mov    (%esp),%esi
  802153:	bf 20 00 00 00       	mov    $0x20,%edi
  802158:	89 e9                	mov    %ebp,%ecx
  80215a:	29 ef                	sub    %ebp,%edi
  80215c:	d3 e0                	shl    %cl,%eax
  80215e:	89 f9                	mov    %edi,%ecx
  802160:	89 f2                	mov    %esi,%edx
  802162:	d3 ea                	shr    %cl,%edx
  802164:	89 e9                	mov    %ebp,%ecx
  802166:	09 c2                	or     %eax,%edx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 14 24             	mov    %edx,(%esp)
  80216d:	89 f2                	mov    %esi,%edx
  80216f:	d3 e2                	shl    %cl,%edx
  802171:	89 f9                	mov    %edi,%ecx
  802173:	89 54 24 04          	mov    %edx,0x4(%esp)
  802177:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	89 c6                	mov    %eax,%esi
  802181:	d3 e3                	shl    %cl,%ebx
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 d0                	mov    %edx,%eax
  802187:	d3 e8                	shr    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	09 d8                	or     %ebx,%eax
  80218d:	89 d3                	mov    %edx,%ebx
  80218f:	89 f2                	mov    %esi,%edx
  802191:	f7 34 24             	divl   (%esp)
  802194:	89 d6                	mov    %edx,%esi
  802196:	d3 e3                	shl    %cl,%ebx
  802198:	f7 64 24 04          	mull   0x4(%esp)
  80219c:	39 d6                	cmp    %edx,%esi
  80219e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a2:	89 d1                	mov    %edx,%ecx
  8021a4:	89 c3                	mov    %eax,%ebx
  8021a6:	72 08                	jb     8021b0 <__umoddi3+0x110>
  8021a8:	75 11                	jne    8021bb <__umoddi3+0x11b>
  8021aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ae:	73 0b                	jae    8021bb <__umoddi3+0x11b>
  8021b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021b4:	1b 14 24             	sbb    (%esp),%edx
  8021b7:	89 d1                	mov    %edx,%ecx
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021bf:	29 da                	sub    %ebx,%edx
  8021c1:	19 ce                	sbb    %ecx,%esi
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 f0                	mov    %esi,%eax
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	d3 ea                	shr    %cl,%edx
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	d3 ee                	shr    %cl,%esi
  8021d1:	09 d0                	or     %edx,%eax
  8021d3:	89 f2                	mov    %esi,%edx
  8021d5:	83 c4 1c             	add    $0x1c,%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5f                   	pop    %edi
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    
  8021dd:	8d 76 00             	lea    0x0(%esi),%esi
  8021e0:	29 f9                	sub    %edi,%ecx
  8021e2:	19 d6                	sbb    %edx,%esi
  8021e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ec:	e9 18 ff ff ff       	jmp    802109 <__umoddi3+0x69>
