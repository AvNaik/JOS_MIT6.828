
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 40 24 80 00       	push   $0x802440
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 5e 24 80 00       	push   $0x80245e
  800056:	68 5e 24 80 00       	push   $0x80245e
  80005b:	e8 c4 1a 00 00       	call   801b24 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 64 24 80 00       	push   $0x802464
  80006d:	6a 09                	push   $0x9
  80006f:	68 7c 24 80 00       	push   $0x80247c
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800086:	e8 73 0a 00 00       	call   800afe <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 2c 0e 00 00       	call   800ef8 <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 e7 09 00 00       	call   800abd <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 10 0a 00 00       	call   800afe <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 98 24 80 00       	push   $0x802498
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 88 29 80 00 	movl   $0x802988,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 2f 09 00 00       	call   800a80 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 54 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 d4 08 00 00       	call   800a80 <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 45                	ja     80023d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 84 1f 00 00       	call   8021a0 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 18                	jmp    800247 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb 03                	jmp    800240 <printnum+0x78>
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f e8                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 71 20 00 00       	call   8022d0 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 bb 24 80 00 	movsbl 0x8024bb(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027a:	83 fa 01             	cmp    $0x1,%edx
  80027d:	7e 0e                	jle    80028d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 08             	lea    0x8(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	8b 52 04             	mov    0x4(%edx),%edx
  80028b:	eb 22                	jmp    8002af <getuint+0x38>
	else if (lflag)
  80028d:	85 d2                	test   %edx,%edx
  80028f:	74 10                	je     8002a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 04             	lea    0x4(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
  80029f:	eb 0e                	jmp    8002af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a6:	89 08                	mov    %ecx,(%eax)
  8002a8:	8b 02                	mov    (%edx),%eax
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 89 03 00 00    	je     800690 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 c8             	movzbl %al,%ecx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 1a 03 00 00    	ja     800675 <vprintfmt+0x38a>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800383:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800386:	83 fa 09             	cmp    $0x9,%edx
  800389:	77 39                	ja     8003c4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 48 04             	lea    0x4(%eax),%ecx
  800396:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a1:	eb 27                	jmp    8003ca <vprintfmt+0xdf>
  8003a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ad:	0f 49 c8             	cmovns %eax,%ecx
  8003b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b6:	eb 8c                	jmp    800344 <vprintfmt+0x59>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c2:	eb 80                	jmp    800344 <vprintfmt+0x59>
  8003c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ce:	0f 89 70 ff ff ff    	jns    800344 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e1:	e9 5e ff ff ff       	jmp    800344 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ec:	e9 53 ff ff ff       	jmp    800344 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	53                   	push   %ebx
  8003fe:	ff 30                	pushl  (%eax)
  800400:	ff d6                	call   *%esi
			break;
  800402:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800408:	e9 04 ff ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	89 55 14             	mov    %edx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	99                   	cltd   
  800419:	31 d0                	xor    %edx,%eax
  80041b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041d:	83 f8 0f             	cmp    $0xf,%eax
  800420:	7f 0b                	jg     80042d <vprintfmt+0x142>
  800422:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  800429:	85 d2                	test   %edx,%edx
  80042b:	75 18                	jne    800445 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042d:	50                   	push   %eax
  80042e:	68 d3 24 80 00       	push   $0x8024d3
  800433:	53                   	push   %ebx
  800434:	56                   	push   %esi
  800435:	e8 94 fe ff ff       	call   8002ce <printfmt>
  80043a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800440:	e9 cc fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	68 91 28 80 00       	push   $0x802891
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 7c fe ff ff       	call   8002ce <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800458:	e9 b4 fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800468:	85 ff                	test   %edi,%edi
  80046a:	b8 cc 24 80 00       	mov    $0x8024cc,%eax
  80046f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800472:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800476:	0f 8e 94 00 00 00    	jle    800510 <vprintfmt+0x225>
  80047c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800480:	0f 84 98 00 00 00    	je     80051e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 d0             	pushl  -0x30(%ebp)
  80048c:	57                   	push   %edi
  80048d:	e8 86 02 00 00       	call   800718 <strnlen>
  800492:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800495:	29 c1                	sub    %eax,%ecx
  800497:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	eb 0f                	jmp    8004ba <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	83 ef 01             	sub    $0x1,%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	7f ed                	jg     8004ab <vprintfmt+0x1c0>
  8004be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c4:	85 c9                	test   %ecx,%ecx
  8004c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cb:	0f 49 c1             	cmovns %ecx,%eax
  8004ce:	29 c1                	sub    %eax,%ecx
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	89 cb                	mov    %ecx,%ebx
  8004db:	eb 4d                	jmp    80052a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e1:	74 1b                	je     8004fe <vprintfmt+0x213>
  8004e3:	0f be c0             	movsbl %al,%eax
  8004e6:	83 e8 20             	sub    $0x20,%eax
  8004e9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ec:	76 10                	jbe    8004fe <vprintfmt+0x213>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 0d                	jmp    80050b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	52                   	push   %edx
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	eb 1a                	jmp    80052a <vprintfmt+0x23f>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	eb 0c                	jmp    80052a <vprintfmt+0x23f>
  80051e:	89 75 08             	mov    %esi,0x8(%ebp)
  800521:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800524:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800527:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052a:	83 c7 01             	add    $0x1,%edi
  80052d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800531:	0f be d0             	movsbl %al,%edx
  800534:	85 d2                	test   %edx,%edx
  800536:	74 23                	je     80055b <vprintfmt+0x270>
  800538:	85 f6                	test   %esi,%esi
  80053a:	78 a1                	js     8004dd <vprintfmt+0x1f2>
  80053c:	83 ee 01             	sub    $0x1,%esi
  80053f:	79 9c                	jns    8004dd <vprintfmt+0x1f2>
  800541:	89 df                	mov    %ebx,%edi
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	eb 18                	jmp    800563 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 20                	push   $0x20
  800551:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 08                	jmp    800563 <vprintfmt+0x278>
  80055b:	89 df                	mov    %ebx,%edi
  80055d:	8b 75 08             	mov    0x8(%ebp),%esi
  800560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800563:	85 ff                	test   %edi,%edi
  800565:	7f e4                	jg     80054b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056a:	e9 a2 fd ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 fa 01             	cmp    $0x1,%edx
  800572:	7e 16                	jle    80058a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 08             	lea    0x8(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 50 04             	mov    0x4(%eax),%edx
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800588:	eb 32                	jmp    8005bc <vprintfmt+0x2d1>
	else if (lflag)
  80058a:	85 d2                	test   %edx,%edx
  80058c:	74 18                	je     8005a6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 c1                	mov    %eax,%ecx
  80059e:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a4:	eb 16                	jmp    8005bc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	89 c1                	mov    %eax,%ecx
  8005b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cb:	79 74                	jns    800641 <vprintfmt+0x356>
				putch('-', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	6a 2d                	push   $0x2d
  8005d3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005db:	f7 d8                	neg    %eax
  8005dd:	83 d2 00             	adc    $0x0,%edx
  8005e0:	f7 da                	neg    %edx
  8005e2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ea:	eb 55                	jmp    800641 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ef:	e8 83 fc ff ff       	call   800277 <getuint>
			base = 10;
  8005f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f9:	eb 46                	jmp    800641 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 74 fc ff ff       	call   800277 <getuint>
			base = 8;
  800603:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800608:	eb 37                	jmp    800641 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 30                	push   $0x30
  800610:	ff d6                	call   *%esi
			putch('x', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 78                	push   $0x78
  800618:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800623:	8b 00                	mov    (%eax),%eax
  800625:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800632:	eb 0d                	jmp    800641 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800634:	8d 45 14             	lea    0x14(%ebp),%eax
  800637:	e8 3b fc ff ff       	call   800277 <getuint>
			base = 16;
  80063c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800641:	83 ec 0c             	sub    $0xc,%esp
  800644:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800648:	57                   	push   %edi
  800649:	ff 75 e0             	pushl  -0x20(%ebp)
  80064c:	51                   	push   %ecx
  80064d:	52                   	push   %edx
  80064e:	50                   	push   %eax
  80064f:	89 da                	mov    %ebx,%edx
  800651:	89 f0                	mov    %esi,%eax
  800653:	e8 70 fb ff ff       	call   8001c8 <printnum>
			break;
  800658:	83 c4 20             	add    $0x20,%esp
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065e:	e9 ae fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	51                   	push   %ecx
  800668:	ff d6                	call   *%esi
			break;
  80066a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800670:	e9 9c fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	6a 25                	push   $0x25
  80067b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	eb 03                	jmp    800685 <vprintfmt+0x39a>
  800682:	83 ef 01             	sub    $0x1,%edi
  800685:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800689:	75 f7                	jne    800682 <vprintfmt+0x397>
  80068b:	e9 81 fc ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800693:	5b                   	pop    %ebx
  800694:	5e                   	pop    %esi
  800695:	5f                   	pop    %edi
  800696:	5d                   	pop    %ebp
  800697:	c3                   	ret    

00800698 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	83 ec 18             	sub    $0x18,%esp
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b5:	85 c0                	test   %eax,%eax
  8006b7:	74 26                	je     8006df <vsnprintf+0x47>
  8006b9:	85 d2                	test   %edx,%edx
  8006bb:	7e 22                	jle    8006df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bd:	ff 75 14             	pushl  0x14(%ebp)
  8006c0:	ff 75 10             	pushl  0x10(%ebp)
  8006c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c6:	50                   	push   %eax
  8006c7:	68 b1 02 80 00       	push   $0x8002b1
  8006cc:	e8 1a fc ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 05                	jmp    8006e4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e4:	c9                   	leave  
  8006e5:	c3                   	ret    

008006e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ef:	50                   	push   %eax
  8006f0:	ff 75 10             	pushl  0x10(%ebp)
  8006f3:	ff 75 0c             	pushl  0xc(%ebp)
  8006f6:	ff 75 08             	pushl  0x8(%ebp)
  8006f9:	e8 9a ff ff ff       	call   800698 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800706:	b8 00 00 00 00       	mov    $0x0,%eax
  80070b:	eb 03                	jmp    800710 <strlen+0x10>
		n++;
  80070d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800710:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800714:	75 f7                	jne    80070d <strlen+0xd>
		n++;
	return n;
}
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800721:	ba 00 00 00 00       	mov    $0x0,%edx
  800726:	eb 03                	jmp    80072b <strnlen+0x13>
		n++;
  800728:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072b:	39 c2                	cmp    %eax,%edx
  80072d:	74 08                	je     800737 <strnlen+0x1f>
  80072f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800733:	75 f3                	jne    800728 <strnlen+0x10>
  800735:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	53                   	push   %ebx
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800743:	89 c2                	mov    %eax,%edx
  800745:	83 c2 01             	add    $0x1,%edx
  800748:	83 c1 01             	add    $0x1,%ecx
  80074b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800752:	84 db                	test   %bl,%bl
  800754:	75 ef                	jne    800745 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800756:	5b                   	pop    %ebx
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800760:	53                   	push   %ebx
  800761:	e8 9a ff ff ff       	call   800700 <strlen>
  800766:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	01 d8                	add    %ebx,%eax
  80076e:	50                   	push   %eax
  80076f:	e8 c5 ff ff ff       	call   800739 <strcpy>
	return dst;
}
  800774:	89 d8                	mov    %ebx,%eax
  800776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	56                   	push   %esi
  80077f:	53                   	push   %ebx
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800786:	89 f3                	mov    %esi,%ebx
  800788:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078b:	89 f2                	mov    %esi,%edx
  80078d:	eb 0f                	jmp    80079e <strncpy+0x23>
		*dst++ = *src;
  80078f:	83 c2 01             	add    $0x1,%edx
  800792:	0f b6 01             	movzbl (%ecx),%eax
  800795:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800798:	80 39 01             	cmpb   $0x1,(%ecx)
  80079b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079e:	39 da                	cmp    %ebx,%edx
  8007a0:	75 ed                	jne    80078f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	5b                   	pop    %ebx
  8007a5:	5e                   	pop    %esi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b8:	85 d2                	test   %edx,%edx
  8007ba:	74 21                	je     8007dd <strlcpy+0x35>
  8007bc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c0:	89 f2                	mov    %esi,%edx
  8007c2:	eb 09                	jmp    8007cd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cd:	39 c2                	cmp    %eax,%edx
  8007cf:	74 09                	je     8007da <strlcpy+0x32>
  8007d1:	0f b6 19             	movzbl (%ecx),%ebx
  8007d4:	84 db                	test   %bl,%bl
  8007d6:	75 ec                	jne    8007c4 <strlcpy+0x1c>
  8007d8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007da:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007dd:	29 f0                	sub    %esi,%eax
}
  8007df:	5b                   	pop    %ebx
  8007e0:	5e                   	pop    %esi
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ec:	eb 06                	jmp    8007f4 <strcmp+0x11>
		p++, q++;
  8007ee:	83 c1 01             	add    $0x1,%ecx
  8007f1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f4:	0f b6 01             	movzbl (%ecx),%eax
  8007f7:	84 c0                	test   %al,%al
  8007f9:	74 04                	je     8007ff <strcmp+0x1c>
  8007fb:	3a 02                	cmp    (%edx),%al
  8007fd:	74 ef                	je     8007ee <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ff:	0f b6 c0             	movzbl %al,%eax
  800802:	0f b6 12             	movzbl (%edx),%edx
  800805:	29 d0                	sub    %edx,%eax
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
  800813:	89 c3                	mov    %eax,%ebx
  800815:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800818:	eb 06                	jmp    800820 <strncmp+0x17>
		n--, p++, q++;
  80081a:	83 c0 01             	add    $0x1,%eax
  80081d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800820:	39 d8                	cmp    %ebx,%eax
  800822:	74 15                	je     800839 <strncmp+0x30>
  800824:	0f b6 08             	movzbl (%eax),%ecx
  800827:	84 c9                	test   %cl,%cl
  800829:	74 04                	je     80082f <strncmp+0x26>
  80082b:	3a 0a                	cmp    (%edx),%cl
  80082d:	74 eb                	je     80081a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082f:	0f b6 00             	movzbl (%eax),%eax
  800832:	0f b6 12             	movzbl (%edx),%edx
  800835:	29 d0                	sub    %edx,%eax
  800837:	eb 05                	jmp    80083e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083e:	5b                   	pop    %ebx
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084b:	eb 07                	jmp    800854 <strchr+0x13>
		if (*s == c)
  80084d:	38 ca                	cmp    %cl,%dl
  80084f:	74 0f                	je     800860 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	0f b6 10             	movzbl (%eax),%edx
  800857:	84 d2                	test   %dl,%dl
  800859:	75 f2                	jne    80084d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086c:	eb 03                	jmp    800871 <strfind+0xf>
  80086e:	83 c0 01             	add    $0x1,%eax
  800871:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800874:	38 ca                	cmp    %cl,%dl
  800876:	74 04                	je     80087c <strfind+0x1a>
  800878:	84 d2                	test   %dl,%dl
  80087a:	75 f2                	jne    80086e <strfind+0xc>
			break;
	return (char *) s;
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	57                   	push   %edi
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 7d 08             	mov    0x8(%ebp),%edi
  800887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	74 36                	je     8008c4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800894:	75 28                	jne    8008be <memset+0x40>
  800896:	f6 c1 03             	test   $0x3,%cl
  800899:	75 23                	jne    8008be <memset+0x40>
		c &= 0xFF;
  80089b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089f:	89 d3                	mov    %edx,%ebx
  8008a1:	c1 e3 08             	shl    $0x8,%ebx
  8008a4:	89 d6                	mov    %edx,%esi
  8008a6:	c1 e6 18             	shl    $0x18,%esi
  8008a9:	89 d0                	mov    %edx,%eax
  8008ab:	c1 e0 10             	shl    $0x10,%eax
  8008ae:	09 f0                	or     %esi,%eax
  8008b0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b2:	89 d8                	mov    %ebx,%eax
  8008b4:	09 d0                	or     %edx,%eax
  8008b6:	c1 e9 02             	shr    $0x2,%ecx
  8008b9:	fc                   	cld    
  8008ba:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bc:	eb 06                	jmp    8008c4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c1:	fc                   	cld    
  8008c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c4:	89 f8                	mov    %edi,%eax
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5f                   	pop    %edi
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	57                   	push   %edi
  8008cf:	56                   	push   %esi
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d9:	39 c6                	cmp    %eax,%esi
  8008db:	73 35                	jae    800912 <memmove+0x47>
  8008dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e0:	39 d0                	cmp    %edx,%eax
  8008e2:	73 2e                	jae    800912 <memmove+0x47>
		s += n;
		d += n;
  8008e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e7:	89 d6                	mov    %edx,%esi
  8008e9:	09 fe                	or     %edi,%esi
  8008eb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f1:	75 13                	jne    800906 <memmove+0x3b>
  8008f3:	f6 c1 03             	test   $0x3,%cl
  8008f6:	75 0e                	jne    800906 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f8:	83 ef 04             	sub    $0x4,%edi
  8008fb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fe:	c1 e9 02             	shr    $0x2,%ecx
  800901:	fd                   	std    
  800902:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800904:	eb 09                	jmp    80090f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800906:	83 ef 01             	sub    $0x1,%edi
  800909:	8d 72 ff             	lea    -0x1(%edx),%esi
  80090c:	fd                   	std    
  80090d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090f:	fc                   	cld    
  800910:	eb 1d                	jmp    80092f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800912:	89 f2                	mov    %esi,%edx
  800914:	09 c2                	or     %eax,%edx
  800916:	f6 c2 03             	test   $0x3,%dl
  800919:	75 0f                	jne    80092a <memmove+0x5f>
  80091b:	f6 c1 03             	test   $0x3,%cl
  80091e:	75 0a                	jne    80092a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800920:	c1 e9 02             	shr    $0x2,%ecx
  800923:	89 c7                	mov    %eax,%edi
  800925:	fc                   	cld    
  800926:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800928:	eb 05                	jmp    80092f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092a:	89 c7                	mov    %eax,%edi
  80092c:	fc                   	cld    
  80092d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092f:	5e                   	pop    %esi
  800930:	5f                   	pop    %edi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800936:	ff 75 10             	pushl  0x10(%ebp)
  800939:	ff 75 0c             	pushl  0xc(%ebp)
  80093c:	ff 75 08             	pushl  0x8(%ebp)
  80093f:	e8 87 ff ff ff       	call   8008cb <memmove>
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800951:	89 c6                	mov    %eax,%esi
  800953:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800956:	eb 1a                	jmp    800972 <memcmp+0x2c>
		if (*s1 != *s2)
  800958:	0f b6 08             	movzbl (%eax),%ecx
  80095b:	0f b6 1a             	movzbl (%edx),%ebx
  80095e:	38 d9                	cmp    %bl,%cl
  800960:	74 0a                	je     80096c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800962:	0f b6 c1             	movzbl %cl,%eax
  800965:	0f b6 db             	movzbl %bl,%ebx
  800968:	29 d8                	sub    %ebx,%eax
  80096a:	eb 0f                	jmp    80097b <memcmp+0x35>
		s1++, s2++;
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800972:	39 f0                	cmp    %esi,%eax
  800974:	75 e2                	jne    800958 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800986:	89 c1                	mov    %eax,%ecx
  800988:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098f:	eb 0a                	jmp    80099b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800991:	0f b6 10             	movzbl (%eax),%edx
  800994:	39 da                	cmp    %ebx,%edx
  800996:	74 07                	je     80099f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	39 c8                	cmp    %ecx,%eax
  80099d:	72 f2                	jb     800991 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ae:	eb 03                	jmp    8009b3 <strtol+0x11>
		s++;
  8009b0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	3c 20                	cmp    $0x20,%al
  8009b8:	74 f6                	je     8009b0 <strtol+0xe>
  8009ba:	3c 09                	cmp    $0x9,%al
  8009bc:	74 f2                	je     8009b0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009be:	3c 2b                	cmp    $0x2b,%al
  8009c0:	75 0a                	jne    8009cc <strtol+0x2a>
		s++;
  8009c2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ca:	eb 11                	jmp    8009dd <strtol+0x3b>
  8009cc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d1:	3c 2d                	cmp    $0x2d,%al
  8009d3:	75 08                	jne    8009dd <strtol+0x3b>
		s++, neg = 1;
  8009d5:	83 c1 01             	add    $0x1,%ecx
  8009d8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009dd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e3:	75 15                	jne    8009fa <strtol+0x58>
  8009e5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e8:	75 10                	jne    8009fa <strtol+0x58>
  8009ea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ee:	75 7c                	jne    800a6c <strtol+0xca>
		s += 2, base = 16;
  8009f0:	83 c1 02             	add    $0x2,%ecx
  8009f3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f8:	eb 16                	jmp    800a10 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009fa:	85 db                	test   %ebx,%ebx
  8009fc:	75 12                	jne    800a10 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a03:	80 39 30             	cmpb   $0x30,(%ecx)
  800a06:	75 08                	jne    800a10 <strtol+0x6e>
		s++, base = 8;
  800a08:	83 c1 01             	add    $0x1,%ecx
  800a0b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
  800a15:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a18:	0f b6 11             	movzbl (%ecx),%edx
  800a1b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1e:	89 f3                	mov    %esi,%ebx
  800a20:	80 fb 09             	cmp    $0x9,%bl
  800a23:	77 08                	ja     800a2d <strtol+0x8b>
			dig = *s - '0';
  800a25:	0f be d2             	movsbl %dl,%edx
  800a28:	83 ea 30             	sub    $0x30,%edx
  800a2b:	eb 22                	jmp    800a4f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a30:	89 f3                	mov    %esi,%ebx
  800a32:	80 fb 19             	cmp    $0x19,%bl
  800a35:	77 08                	ja     800a3f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a37:	0f be d2             	movsbl %dl,%edx
  800a3a:	83 ea 57             	sub    $0x57,%edx
  800a3d:	eb 10                	jmp    800a4f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	80 fb 19             	cmp    $0x19,%bl
  800a47:	77 16                	ja     800a5f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a49:	0f be d2             	movsbl %dl,%edx
  800a4c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a52:	7d 0b                	jge    800a5f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5d:	eb b9                	jmp    800a18 <strtol+0x76>

	if (endptr)
  800a5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a63:	74 0d                	je     800a72 <strtol+0xd0>
		*endptr = (char *) s;
  800a65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a68:	89 0e                	mov    %ecx,(%esi)
  800a6a:	eb 06                	jmp    800a72 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	74 98                	je     800a08 <strtol+0x66>
  800a70:	eb 9e                	jmp    800a10 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a72:	89 c2                	mov    %eax,%edx
  800a74:	f7 da                	neg    %edx
  800a76:	85 ff                	test   %edi,%edi
  800a78:	0f 45 c2             	cmovne %edx,%eax
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5f                   	pop    %edi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	89 c6                	mov    %eax,%esi
  800a97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aae:	89 d1                	mov    %edx,%ecx
  800ab0:	89 d3                	mov    %edx,%ebx
  800ab2:	89 d7                	mov    %edx,%edi
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	89 cb                	mov    %ecx,%ebx
  800ad5:	89 cf                	mov    %ecx,%edi
  800ad7:	89 ce                	mov    %ecx,%esi
  800ad9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800adb:	85 c0                	test   %eax,%eax
  800add:	7e 17                	jle    800af6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adf:	83 ec 0c             	sub    $0xc,%esp
  800ae2:	50                   	push   %eax
  800ae3:	6a 03                	push   $0x3
  800ae5:	68 bf 27 80 00       	push   $0x8027bf
  800aea:	6a 23                	push   $0x23
  800aec:	68 dc 27 80 00       	push   $0x8027dc
  800af1:	e8 e5 f5 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_yield>:

void
sys_yield(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2d:	89 d1                	mov    %edx,%ecx
  800b2f:	89 d3                	mov    %edx,%ebx
  800b31:	89 d7                	mov    %edx,%edi
  800b33:	89 d6                	mov    %edx,%esi
  800b35:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	be 00 00 00 00       	mov    $0x0,%esi
  800b4a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b58:	89 f7                	mov    %esi,%edi
  800b5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	7e 17                	jle    800b77 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	50                   	push   %eax
  800b64:	6a 04                	push   $0x4
  800b66:	68 bf 27 80 00       	push   $0x8027bf
  800b6b:	6a 23                	push   $0x23
  800b6d:	68 dc 27 80 00       	push   $0x8027dc
  800b72:	e8 64 f5 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b99:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 17                	jle    800bb9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 05                	push   $0x5
  800ba8:	68 bf 27 80 00       	push   $0x8027bf
  800bad:	6a 23                	push   $0x23
  800baf:	68 dc 27 80 00       	push   $0x8027dc
  800bb4:	e8 22 f5 ff ff       	call   8000db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcf:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	89 df                	mov    %ebx,%edi
  800bdc:	89 de                	mov    %ebx,%esi
  800bde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 17                	jle    800bfb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 06                	push   $0x6
  800bea:	68 bf 27 80 00       	push   $0x8027bf
  800bef:	6a 23                	push   $0x23
  800bf1:	68 dc 27 80 00       	push   $0x8027dc
  800bf6:	e8 e0 f4 ff ff       	call   8000db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c11:	b8 08 00 00 00       	mov    $0x8,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 df                	mov    %ebx,%edi
  800c1e:	89 de                	mov    %ebx,%esi
  800c20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 08                	push   $0x8
  800c2c:	68 bf 27 80 00       	push   $0x8027bf
  800c31:	6a 23                	push   $0x23
  800c33:	68 dc 27 80 00       	push   $0x8027dc
  800c38:	e8 9e f4 ff ff       	call   8000db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c53:	b8 09 00 00 00       	mov    $0x9,%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	89 df                	mov    %ebx,%edi
  800c60:	89 de                	mov    %ebx,%esi
  800c62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 09                	push   $0x9
  800c6e:	68 bf 27 80 00       	push   $0x8027bf
  800c73:	6a 23                	push   $0x23
  800c75:	68 dc 27 80 00       	push   $0x8027dc
  800c7a:	e8 5c f4 ff ff       	call   8000db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 17                	jle    800cc1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 0a                	push   $0xa
  800cb0:	68 bf 27 80 00       	push   $0x8027bf
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 dc 27 80 00       	push   $0x8027dc
  800cbc:	e8 1a f4 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	be 00 00 00 00       	mov    $0x0,%esi
  800cd4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfa:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 cb                	mov    %ecx,%ebx
  800d04:	89 cf                	mov    %ecx,%edi
  800d06:	89 ce                	mov    %ecx,%esi
  800d08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 17                	jle    800d25 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	6a 0d                	push   $0xd
  800d14:	68 bf 27 80 00       	push   $0x8027bf
  800d19:	6a 23                	push   $0x23
  800d1b:	68 dc 27 80 00       	push   $0x8027dc
  800d20:	e8 b6 f3 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d30:	8b 45 08             	mov    0x8(%ebp),%eax
  800d33:	05 00 00 00 30       	add    $0x30000000,%eax
  800d38:	c1 e8 0c             	shr    $0xc,%eax
}
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d40:	8b 45 08             	mov    0x8(%ebp),%eax
  800d43:	05 00 00 00 30       	add    $0x30000000,%eax
  800d48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d4d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d5f:	89 c2                	mov    %eax,%edx
  800d61:	c1 ea 16             	shr    $0x16,%edx
  800d64:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d6b:	f6 c2 01             	test   $0x1,%dl
  800d6e:	74 11                	je     800d81 <fd_alloc+0x2d>
  800d70:	89 c2                	mov    %eax,%edx
  800d72:	c1 ea 0c             	shr    $0xc,%edx
  800d75:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d7c:	f6 c2 01             	test   $0x1,%dl
  800d7f:	75 09                	jne    800d8a <fd_alloc+0x36>
			*fd_store = fd;
  800d81:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d83:	b8 00 00 00 00       	mov    $0x0,%eax
  800d88:	eb 17                	jmp    800da1 <fd_alloc+0x4d>
  800d8a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d8f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d94:	75 c9                	jne    800d5f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d96:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d9c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800da9:	83 f8 1f             	cmp    $0x1f,%eax
  800dac:	77 36                	ja     800de4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dae:	c1 e0 0c             	shl    $0xc,%eax
  800db1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800db6:	89 c2                	mov    %eax,%edx
  800db8:	c1 ea 16             	shr    $0x16,%edx
  800dbb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc2:	f6 c2 01             	test   $0x1,%dl
  800dc5:	74 24                	je     800deb <fd_lookup+0x48>
  800dc7:	89 c2                	mov    %eax,%edx
  800dc9:	c1 ea 0c             	shr    $0xc,%edx
  800dcc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd3:	f6 c2 01             	test   $0x1,%dl
  800dd6:	74 1a                	je     800df2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ddb:	89 02                	mov    %eax,(%edx)
	return 0;
  800ddd:	b8 00 00 00 00       	mov    $0x0,%eax
  800de2:	eb 13                	jmp    800df7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de9:	eb 0c                	jmp    800df7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800deb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800df0:	eb 05                	jmp    800df7 <fd_lookup+0x54>
  800df2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	83 ec 08             	sub    $0x8,%esp
  800dff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e02:	ba 68 28 80 00       	mov    $0x802868,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e07:	eb 13                	jmp    800e1c <dev_lookup+0x23>
  800e09:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e0c:	39 08                	cmp    %ecx,(%eax)
  800e0e:	75 0c                	jne    800e1c <dev_lookup+0x23>
			*dev = devtab[i];
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e15:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1a:	eb 2e                	jmp    800e4a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e1c:	8b 02                	mov    (%edx),%eax
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	75 e7                	jne    800e09 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e22:	a1 04 40 80 00       	mov    0x804004,%eax
  800e27:	8b 40 48             	mov    0x48(%eax),%eax
  800e2a:	83 ec 04             	sub    $0x4,%esp
  800e2d:	51                   	push   %ecx
  800e2e:	50                   	push   %eax
  800e2f:	68 ec 27 80 00       	push   $0x8027ec
  800e34:	e8 7b f3 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800e39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    

00800e4c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	83 ec 10             	sub    $0x10,%esp
  800e54:	8b 75 08             	mov    0x8(%ebp),%esi
  800e57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5d:	50                   	push   %eax
  800e5e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e64:	c1 e8 0c             	shr    $0xc,%eax
  800e67:	50                   	push   %eax
  800e68:	e8 36 ff ff ff       	call   800da3 <fd_lookup>
  800e6d:	83 c4 08             	add    $0x8,%esp
  800e70:	85 c0                	test   %eax,%eax
  800e72:	78 05                	js     800e79 <fd_close+0x2d>
	    || fd != fd2)
  800e74:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e77:	74 0c                	je     800e85 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e79:	84 db                	test   %bl,%bl
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	0f 44 c2             	cmove  %edx,%eax
  800e83:	eb 41                	jmp    800ec6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e8b:	50                   	push   %eax
  800e8c:	ff 36                	pushl  (%esi)
  800e8e:	e8 66 ff ff ff       	call   800df9 <dev_lookup>
  800e93:	89 c3                	mov    %eax,%ebx
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	78 1a                	js     800eb6 <fd_close+0x6a>
		if (dev->dev_close)
  800e9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ea2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	74 0b                	je     800eb6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eab:	83 ec 0c             	sub    $0xc,%esp
  800eae:	56                   	push   %esi
  800eaf:	ff d0                	call   *%eax
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eb6:	83 ec 08             	sub    $0x8,%esp
  800eb9:	56                   	push   %esi
  800eba:	6a 00                	push   $0x0
  800ebc:	e8 00 fd ff ff       	call   800bc1 <sys_page_unmap>
	return r;
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	89 d8                	mov    %ebx,%eax
}
  800ec6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed6:	50                   	push   %eax
  800ed7:	ff 75 08             	pushl  0x8(%ebp)
  800eda:	e8 c4 fe ff ff       	call   800da3 <fd_lookup>
  800edf:	83 c4 08             	add    $0x8,%esp
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	78 10                	js     800ef6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ee6:	83 ec 08             	sub    $0x8,%esp
  800ee9:	6a 01                	push   $0x1
  800eeb:	ff 75 f4             	pushl  -0xc(%ebp)
  800eee:	e8 59 ff ff ff       	call   800e4c <fd_close>
  800ef3:	83 c4 10             	add    $0x10,%esp
}
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    

00800ef8 <close_all>:

void
close_all(void)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	53                   	push   %ebx
  800efc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800eff:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f04:	83 ec 0c             	sub    $0xc,%esp
  800f07:	53                   	push   %ebx
  800f08:	e8 c0 ff ff ff       	call   800ecd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f0d:	83 c3 01             	add    $0x1,%ebx
  800f10:	83 c4 10             	add    $0x10,%esp
  800f13:	83 fb 20             	cmp    $0x20,%ebx
  800f16:	75 ec                	jne    800f04 <close_all+0xc>
		close(i);
}
  800f18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1b:	c9                   	leave  
  800f1c:	c3                   	ret    

00800f1d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	57                   	push   %edi
  800f21:	56                   	push   %esi
  800f22:	53                   	push   %ebx
  800f23:	83 ec 2c             	sub    $0x2c,%esp
  800f26:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f29:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f2c:	50                   	push   %eax
  800f2d:	ff 75 08             	pushl  0x8(%ebp)
  800f30:	e8 6e fe ff ff       	call   800da3 <fd_lookup>
  800f35:	83 c4 08             	add    $0x8,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	0f 88 c1 00 00 00    	js     801001 <dup+0xe4>
		return r;
	close(newfdnum);
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	56                   	push   %esi
  800f44:	e8 84 ff ff ff       	call   800ecd <close>

	newfd = INDEX2FD(newfdnum);
  800f49:	89 f3                	mov    %esi,%ebx
  800f4b:	c1 e3 0c             	shl    $0xc,%ebx
  800f4e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f54:	83 c4 04             	add    $0x4,%esp
  800f57:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5a:	e8 de fd ff ff       	call   800d3d <fd2data>
  800f5f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f61:	89 1c 24             	mov    %ebx,(%esp)
  800f64:	e8 d4 fd ff ff       	call   800d3d <fd2data>
  800f69:	83 c4 10             	add    $0x10,%esp
  800f6c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f6f:	89 f8                	mov    %edi,%eax
  800f71:	c1 e8 16             	shr    $0x16,%eax
  800f74:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f7b:	a8 01                	test   $0x1,%al
  800f7d:	74 37                	je     800fb6 <dup+0x99>
  800f7f:	89 f8                	mov    %edi,%eax
  800f81:	c1 e8 0c             	shr    $0xc,%eax
  800f84:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f8b:	f6 c2 01             	test   $0x1,%dl
  800f8e:	74 26                	je     800fb6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f90:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f97:	83 ec 0c             	sub    $0xc,%esp
  800f9a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f9f:	50                   	push   %eax
  800fa0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa3:	6a 00                	push   $0x0
  800fa5:	57                   	push   %edi
  800fa6:	6a 00                	push   $0x0
  800fa8:	e8 d2 fb ff ff       	call   800b7f <sys_page_map>
  800fad:	89 c7                	mov    %eax,%edi
  800faf:	83 c4 20             	add    $0x20,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	78 2e                	js     800fe4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fb9:	89 d0                	mov    %edx,%eax
  800fbb:	c1 e8 0c             	shr    $0xc,%eax
  800fbe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc5:	83 ec 0c             	sub    $0xc,%esp
  800fc8:	25 07 0e 00 00       	and    $0xe07,%eax
  800fcd:	50                   	push   %eax
  800fce:	53                   	push   %ebx
  800fcf:	6a 00                	push   $0x0
  800fd1:	52                   	push   %edx
  800fd2:	6a 00                	push   $0x0
  800fd4:	e8 a6 fb ff ff       	call   800b7f <sys_page_map>
  800fd9:	89 c7                	mov    %eax,%edi
  800fdb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fde:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe0:	85 ff                	test   %edi,%edi
  800fe2:	79 1d                	jns    801001 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fe4:	83 ec 08             	sub    $0x8,%esp
  800fe7:	53                   	push   %ebx
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 d2 fb ff ff       	call   800bc1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fef:	83 c4 08             	add    $0x8,%esp
  800ff2:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 c5 fb ff ff       	call   800bc1 <sys_page_unmap>
	return r;
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	89 f8                	mov    %edi,%eax
}
  801001:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801004:	5b                   	pop    %ebx
  801005:	5e                   	pop    %esi
  801006:	5f                   	pop    %edi
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	53                   	push   %ebx
  80100d:	83 ec 14             	sub    $0x14,%esp
  801010:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801013:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801016:	50                   	push   %eax
  801017:	53                   	push   %ebx
  801018:	e8 86 fd ff ff       	call   800da3 <fd_lookup>
  80101d:	83 c4 08             	add    $0x8,%esp
  801020:	89 c2                	mov    %eax,%edx
  801022:	85 c0                	test   %eax,%eax
  801024:	78 6d                	js     801093 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801026:	83 ec 08             	sub    $0x8,%esp
  801029:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102c:	50                   	push   %eax
  80102d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801030:	ff 30                	pushl  (%eax)
  801032:	e8 c2 fd ff ff       	call   800df9 <dev_lookup>
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	78 4c                	js     80108a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80103e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801041:	8b 42 08             	mov    0x8(%edx),%eax
  801044:	83 e0 03             	and    $0x3,%eax
  801047:	83 f8 01             	cmp    $0x1,%eax
  80104a:	75 21                	jne    80106d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80104c:	a1 04 40 80 00       	mov    0x804004,%eax
  801051:	8b 40 48             	mov    0x48(%eax),%eax
  801054:	83 ec 04             	sub    $0x4,%esp
  801057:	53                   	push   %ebx
  801058:	50                   	push   %eax
  801059:	68 2d 28 80 00       	push   $0x80282d
  80105e:	e8 51 f1 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80106b:	eb 26                	jmp    801093 <read+0x8a>
	}
	if (!dev->dev_read)
  80106d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801070:	8b 40 08             	mov    0x8(%eax),%eax
  801073:	85 c0                	test   %eax,%eax
  801075:	74 17                	je     80108e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	ff 75 10             	pushl  0x10(%ebp)
  80107d:	ff 75 0c             	pushl  0xc(%ebp)
  801080:	52                   	push   %edx
  801081:	ff d0                	call   *%eax
  801083:	89 c2                	mov    %eax,%edx
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	eb 09                	jmp    801093 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80108a:	89 c2                	mov    %eax,%edx
  80108c:	eb 05                	jmp    801093 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80108e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801093:	89 d0                	mov    %edx,%eax
  801095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ae:	eb 21                	jmp    8010d1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010b0:	83 ec 04             	sub    $0x4,%esp
  8010b3:	89 f0                	mov    %esi,%eax
  8010b5:	29 d8                	sub    %ebx,%eax
  8010b7:	50                   	push   %eax
  8010b8:	89 d8                	mov    %ebx,%eax
  8010ba:	03 45 0c             	add    0xc(%ebp),%eax
  8010bd:	50                   	push   %eax
  8010be:	57                   	push   %edi
  8010bf:	e8 45 ff ff ff       	call   801009 <read>
		if (m < 0)
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 10                	js     8010db <readn+0x41>
			return m;
		if (m == 0)
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	74 0a                	je     8010d9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010cf:	01 c3                	add    %eax,%ebx
  8010d1:	39 f3                	cmp    %esi,%ebx
  8010d3:	72 db                	jb     8010b0 <readn+0x16>
  8010d5:	89 d8                	mov    %ebx,%eax
  8010d7:	eb 02                	jmp    8010db <readn+0x41>
  8010d9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 14             	sub    $0x14,%esp
  8010ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f0:	50                   	push   %eax
  8010f1:	53                   	push   %ebx
  8010f2:	e8 ac fc ff ff       	call   800da3 <fd_lookup>
  8010f7:	83 c4 08             	add    $0x8,%esp
  8010fa:	89 c2                	mov    %eax,%edx
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	78 68                	js     801168 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801100:	83 ec 08             	sub    $0x8,%esp
  801103:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801106:	50                   	push   %eax
  801107:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80110a:	ff 30                	pushl  (%eax)
  80110c:	e8 e8 fc ff ff       	call   800df9 <dev_lookup>
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	78 47                	js     80115f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801118:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80111f:	75 21                	jne    801142 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801121:	a1 04 40 80 00       	mov    0x804004,%eax
  801126:	8b 40 48             	mov    0x48(%eax),%eax
  801129:	83 ec 04             	sub    $0x4,%esp
  80112c:	53                   	push   %ebx
  80112d:	50                   	push   %eax
  80112e:	68 49 28 80 00       	push   $0x802849
  801133:	e8 7c f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801140:	eb 26                	jmp    801168 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801142:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801145:	8b 52 0c             	mov    0xc(%edx),%edx
  801148:	85 d2                	test   %edx,%edx
  80114a:	74 17                	je     801163 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80114c:	83 ec 04             	sub    $0x4,%esp
  80114f:	ff 75 10             	pushl  0x10(%ebp)
  801152:	ff 75 0c             	pushl  0xc(%ebp)
  801155:	50                   	push   %eax
  801156:	ff d2                	call   *%edx
  801158:	89 c2                	mov    %eax,%edx
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	eb 09                	jmp    801168 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115f:	89 c2                	mov    %eax,%edx
  801161:	eb 05                	jmp    801168 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801163:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801168:	89 d0                	mov    %edx,%eax
  80116a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    

0080116f <seek>:

int
seek(int fdnum, off_t offset)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801175:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801178:	50                   	push   %eax
  801179:	ff 75 08             	pushl  0x8(%ebp)
  80117c:	e8 22 fc ff ff       	call   800da3 <fd_lookup>
  801181:	83 c4 08             	add    $0x8,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	78 0e                	js     801196 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801188:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80118b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801191:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801196:	c9                   	leave  
  801197:	c3                   	ret    

00801198 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	53                   	push   %ebx
  80119c:	83 ec 14             	sub    $0x14,%esp
  80119f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a5:	50                   	push   %eax
  8011a6:	53                   	push   %ebx
  8011a7:	e8 f7 fb ff ff       	call   800da3 <fd_lookup>
  8011ac:	83 c4 08             	add    $0x8,%esp
  8011af:	89 c2                	mov    %eax,%edx
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 65                	js     80121a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011bb:	50                   	push   %eax
  8011bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bf:	ff 30                	pushl  (%eax)
  8011c1:	e8 33 fc ff ff       	call   800df9 <dev_lookup>
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 44                	js     801211 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d4:	75 21                	jne    8011f7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011d6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011db:	8b 40 48             	mov    0x48(%eax),%eax
  8011de:	83 ec 04             	sub    $0x4,%esp
  8011e1:	53                   	push   %ebx
  8011e2:	50                   	push   %eax
  8011e3:	68 0c 28 80 00       	push   $0x80280c
  8011e8:	e8 c7 ef ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f5:	eb 23                	jmp    80121a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011fa:	8b 52 18             	mov    0x18(%edx),%edx
  8011fd:	85 d2                	test   %edx,%edx
  8011ff:	74 14                	je     801215 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801201:	83 ec 08             	sub    $0x8,%esp
  801204:	ff 75 0c             	pushl  0xc(%ebp)
  801207:	50                   	push   %eax
  801208:	ff d2                	call   *%edx
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	eb 09                	jmp    80121a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801211:	89 c2                	mov    %eax,%edx
  801213:	eb 05                	jmp    80121a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801215:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80121a:	89 d0                	mov    %edx,%eax
  80121c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121f:	c9                   	leave  
  801220:	c3                   	ret    

00801221 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	53                   	push   %ebx
  801225:	83 ec 14             	sub    $0x14,%esp
  801228:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80122b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	ff 75 08             	pushl  0x8(%ebp)
  801232:	e8 6c fb ff ff       	call   800da3 <fd_lookup>
  801237:	83 c4 08             	add    $0x8,%esp
  80123a:	89 c2                	mov    %eax,%edx
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 58                	js     801298 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124a:	ff 30                	pushl  (%eax)
  80124c:	e8 a8 fb ff ff       	call   800df9 <dev_lookup>
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	78 37                	js     80128f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80125f:	74 32                	je     801293 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801261:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801264:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80126b:	00 00 00 
	stat->st_isdir = 0;
  80126e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801275:	00 00 00 
	stat->st_dev = dev;
  801278:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80127e:	83 ec 08             	sub    $0x8,%esp
  801281:	53                   	push   %ebx
  801282:	ff 75 f0             	pushl  -0x10(%ebp)
  801285:	ff 50 14             	call   *0x14(%eax)
  801288:	89 c2                	mov    %eax,%edx
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	eb 09                	jmp    801298 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128f:	89 c2                	mov    %eax,%edx
  801291:	eb 05                	jmp    801298 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801293:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801298:	89 d0                	mov    %edx,%eax
  80129a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129d:	c9                   	leave  
  80129e:	c3                   	ret    

0080129f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012a4:	83 ec 08             	sub    $0x8,%esp
  8012a7:	6a 00                	push   $0x0
  8012a9:	ff 75 08             	pushl  0x8(%ebp)
  8012ac:	e8 2c 02 00 00       	call   8014dd <open>
  8012b1:	89 c3                	mov    %eax,%ebx
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	78 1b                	js     8012d5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	ff 75 0c             	pushl  0xc(%ebp)
  8012c0:	50                   	push   %eax
  8012c1:	e8 5b ff ff ff       	call   801221 <fstat>
  8012c6:	89 c6                	mov    %eax,%esi
	close(fd);
  8012c8:	89 1c 24             	mov    %ebx,(%esp)
  8012cb:	e8 fd fb ff ff       	call   800ecd <close>
	return r;
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	89 f0                	mov    %esi,%eax
}
  8012d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d8:	5b                   	pop    %ebx
  8012d9:	5e                   	pop    %esi
  8012da:	5d                   	pop    %ebp
  8012db:	c3                   	ret    

008012dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	56                   	push   %esi
  8012e0:	53                   	push   %ebx
  8012e1:	89 c6                	mov    %eax,%esi
  8012e3:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  8012e5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012ec:	75 12                	jne    801300 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  8012ee:	83 ec 0c             	sub    $0xc,%esp
  8012f1:	6a 01                	push   $0x1
  8012f3:	e8 31 0e 00 00       	call   802129 <ipc_find_env>
  8012f8:	a3 00 40 80 00       	mov    %eax,0x804000
  8012fd:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801300:	6a 07                	push   $0x7
  801302:	68 00 50 80 00       	push   $0x805000
  801307:	56                   	push   %esi
  801308:	ff 35 00 40 80 00    	pushl  0x804000
  80130e:	e8 c2 0d 00 00       	call   8020d5 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  801313:	83 c4 0c             	add    $0xc,%esp
  801316:	6a 00                	push   $0x0
  801318:	53                   	push   %ebx
  801319:	6a 00                	push   $0x0
  80131b:	e8 56 0d 00 00       	call   802076 <ipc_recv>
}
  801320:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801323:	5b                   	pop    %ebx
  801324:	5e                   	pop    %esi
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    

00801327 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80132d:	8b 45 08             	mov    0x8(%ebp),%eax
  801330:	8b 40 0c             	mov    0xc(%eax),%eax
  801333:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  801338:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133b:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  801340:	ba 00 00 00 00       	mov    $0x0,%edx
  801345:	b8 02 00 00 00       	mov    $0x2,%eax
  80134a:	e8 8d ff ff ff       	call   8012dc <fsipc>
}
  80134f:	c9                   	leave  
  801350:	c3                   	ret    

00801351 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801357:	8b 45 08             	mov    0x8(%ebp),%eax
  80135a:	8b 40 0c             	mov    0xc(%eax),%eax
  80135d:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  801362:	ba 00 00 00 00       	mov    $0x0,%edx
  801367:	b8 06 00 00 00       	mov    $0x6,%eax
  80136c:	e8 6b ff ff ff       	call   8012dc <fsipc>
}
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	53                   	push   %ebx
  801377:	83 ec 04             	sub    $0x4,%esp
  80137a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80137d:	8b 45 08             	mov    0x8(%ebp),%eax
  801380:	8b 40 0c             	mov    0xc(%eax),%eax
  801383:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801388:	ba 00 00 00 00       	mov    $0x0,%edx
  80138d:	b8 05 00 00 00       	mov    $0x5,%eax
  801392:	e8 45 ff ff ff       	call   8012dc <fsipc>
  801397:	85 c0                	test   %eax,%eax
  801399:	78 2c                	js     8013c7 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80139b:	83 ec 08             	sub    $0x8,%esp
  80139e:	68 00 50 80 00       	push   $0x805000
  8013a3:	53                   	push   %ebx
  8013a4:	e8 90 f3 ff ff       	call   800739 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8013a9:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013b4:	a1 84 50 80 00       	mov    0x805084,%eax
  8013b9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ca:	c9                   	leave  
  8013cb:	c3                   	ret    

008013cc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013dc:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  8013e1:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  8013e7:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8013ed:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8013f2:	0f 46 c3             	cmovbe %ebx,%eax
  8013f5:	50                   	push   %eax
  8013f6:	ff 75 0c             	pushl  0xc(%ebp)
  8013f9:	68 08 50 80 00       	push   $0x805008
  8013fe:	e8 c8 f4 ff ff       	call   8008cb <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  801403:	ba 00 00 00 00       	mov    $0x0,%edx
  801408:	b8 04 00 00 00       	mov    $0x4,%eax
  80140d:	e8 ca fe ff ff       	call   8012dc <fsipc>
  801412:	83 c4 10             	add    $0x10,%esp
  801415:	85 c0                	test   %eax,%eax
  801417:	78 3d                	js     801456 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  801419:	39 c3                	cmp    %eax,%ebx
  80141b:	73 19                	jae    801436 <devfile_write+0x6a>
  80141d:	68 78 28 80 00       	push   $0x802878
  801422:	68 7f 28 80 00       	push   $0x80287f
  801427:	68 9a 00 00 00       	push   $0x9a
  80142c:	68 94 28 80 00       	push   $0x802894
  801431:	e8 a5 ec ff ff       	call   8000db <_panic>
	   assert (r <= bytes_written);
  801436:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80143b:	7e 19                	jle    801456 <devfile_write+0x8a>
  80143d:	68 9f 28 80 00       	push   $0x80289f
  801442:	68 7f 28 80 00       	push   $0x80287f
  801447:	68 9b 00 00 00       	push   $0x9b
  80144c:	68 94 28 80 00       	push   $0x802894
  801451:	e8 85 ec ff ff       	call   8000db <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801456:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801459:	c9                   	leave  
  80145a:	c3                   	ret    

0080145b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	56                   	push   %esi
  80145f:	53                   	push   %ebx
  801460:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	8b 40 0c             	mov    0xc(%eax),%eax
  801469:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  80146e:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801474:	ba 00 00 00 00       	mov    $0x0,%edx
  801479:	b8 03 00 00 00       	mov    $0x3,%eax
  80147e:	e8 59 fe ff ff       	call   8012dc <fsipc>
  801483:	89 c3                	mov    %eax,%ebx
  801485:	85 c0                	test   %eax,%eax
  801487:	78 4b                	js     8014d4 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  801489:	39 c6                	cmp    %eax,%esi
  80148b:	73 16                	jae    8014a3 <devfile_read+0x48>
  80148d:	68 78 28 80 00       	push   $0x802878
  801492:	68 7f 28 80 00       	push   $0x80287f
  801497:	6a 7c                	push   $0x7c
  801499:	68 94 28 80 00       	push   $0x802894
  80149e:	e8 38 ec ff ff       	call   8000db <_panic>
	   assert(r <= PGSIZE);
  8014a3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014a8:	7e 16                	jle    8014c0 <devfile_read+0x65>
  8014aa:	68 b2 28 80 00       	push   $0x8028b2
  8014af:	68 7f 28 80 00       	push   $0x80287f
  8014b4:	6a 7d                	push   $0x7d
  8014b6:	68 94 28 80 00       	push   $0x802894
  8014bb:	e8 1b ec ff ff       	call   8000db <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	50                   	push   %eax
  8014c4:	68 00 50 80 00       	push   $0x805000
  8014c9:	ff 75 0c             	pushl  0xc(%ebp)
  8014cc:	e8 fa f3 ff ff       	call   8008cb <memmove>
	   return r;
  8014d1:	83 c4 10             	add    $0x10,%esp
}
  8014d4:	89 d8                	mov    %ebx,%eax
  8014d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d9:	5b                   	pop    %ebx
  8014da:	5e                   	pop    %esi
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 20             	sub    $0x20,%esp
  8014e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  8014e7:	53                   	push   %ebx
  8014e8:	e8 13 f2 ff ff       	call   800700 <strlen>
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014f5:	7f 67                	jg     80155e <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8014f7:	83 ec 0c             	sub    $0xc,%esp
  8014fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	e8 51 f8 ff ff       	call   800d54 <fd_alloc>
  801503:	83 c4 10             	add    $0x10,%esp
			 return r;
  801506:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 57                	js     801563 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	53                   	push   %ebx
  801510:	68 00 50 80 00       	push   $0x805000
  801515:	e8 1f f2 ff ff       	call   800739 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  80151a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151d:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801522:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801525:	b8 01 00 00 00       	mov    $0x1,%eax
  80152a:	e8 ad fd ff ff       	call   8012dc <fsipc>
  80152f:	89 c3                	mov    %eax,%ebx
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	79 14                	jns    80154c <open+0x6f>
			 fd_close(fd, 0);
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	6a 00                	push   $0x0
  80153d:	ff 75 f4             	pushl  -0xc(%ebp)
  801540:	e8 07 f9 ff ff       	call   800e4c <fd_close>
			 return r;
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	89 da                	mov    %ebx,%edx
  80154a:	eb 17                	jmp    801563 <open+0x86>
	   }

	   return fd2num(fd);
  80154c:	83 ec 0c             	sub    $0xc,%esp
  80154f:	ff 75 f4             	pushl  -0xc(%ebp)
  801552:	e8 d6 f7 ff ff       	call   800d2d <fd2num>
  801557:	89 c2                	mov    %eax,%edx
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	eb 05                	jmp    801563 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  80155e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801563:	89 d0                	mov    %edx,%eax
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801570:	ba 00 00 00 00       	mov    $0x0,%edx
  801575:	b8 08 00 00 00       	mov    $0x8,%eax
  80157a:	e8 5d fd ff ff       	call   8012dc <fsipc>
}
  80157f:	c9                   	leave  
  801580:	c3                   	ret    

00801581 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
	   int
spawn(const char *prog, const char **argv)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	57                   	push   %edi
  801585:	56                   	push   %esi
  801586:	53                   	push   %ebx
  801587:	81 ec 94 02 00 00    	sub    $0x294,%esp
	   //   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	   //     correct initial eip and esp values in the child.
	   //
	   //   - Start the child process running with sys_env_set_status().

	   if ((r = open(prog, O_RDONLY)) < 0)
  80158d:	6a 00                	push   $0x0
  80158f:	ff 75 08             	pushl  0x8(%ebp)
  801592:	e8 46 ff ff ff       	call   8014dd <open>
  801597:	89 c1                	mov    %eax,%ecx
  801599:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	0f 88 de 04 00 00    	js     801a88 <spawn+0x507>
			 return r;
	   fd = r;

	   // Read elf header
	   elf = (struct Elf*) elf_buf;
	   if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015aa:	83 ec 04             	sub    $0x4,%esp
  8015ad:	68 00 02 00 00       	push   $0x200
  8015b2:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015b8:	50                   	push   %eax
  8015b9:	51                   	push   %ecx
  8015ba:	e8 db fa ff ff       	call   80109a <readn>
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015c7:	75 0c                	jne    8015d5 <spawn+0x54>
				    || elf->e_magic != ELF_MAGIC) {
  8015c9:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8015d0:	45 4c 46 
  8015d3:	74 33                	je     801608 <spawn+0x87>
			 close(fd);
  8015d5:	83 ec 0c             	sub    $0xc,%esp
  8015d8:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8015de:	e8 ea f8 ff ff       	call   800ecd <close>
			 cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8015e3:	83 c4 0c             	add    $0xc,%esp
  8015e6:	68 7f 45 4c 46       	push   $0x464c457f
  8015eb:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8015f1:	68 be 28 80 00       	push   $0x8028be
  8015f6:	e8 b9 eb ff ff       	call   8001b4 <cprintf>
			 return -E_NOT_EXEC;
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801603:	e9 12 05 00 00       	jmp    801b1a <spawn+0x599>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801608:	b8 07 00 00 00       	mov    $0x7,%eax
  80160d:	cd 30                	int    $0x30
  80160f:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801615:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	   }

	   // Create new child environment
	   if ((r = sys_exofork()) < 0)
  80161b:	85 c0                	test   %eax,%eax
  80161d:	0f 88 70 04 00 00    	js     801a93 <spawn+0x512>
			 return r;
	   child = r;

	   // Set up trap frame, including initial stack.
	   child_tf = envs[ENVX(child)].env_tf;
  801623:	89 c6                	mov    %eax,%esi
  801625:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80162b:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80162e:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801634:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80163a:	b9 11 00 00 00       	mov    $0x11,%ecx
  80163f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	   child_tf.tf_eip = elf->e_entry;
  801641:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801647:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
	   for (argc = 0; argv[argc] != 0; argc++)
  80164d:	bb 00 00 00 00       	mov    $0x0,%ebx
	   char *string_store;
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
  801652:	be 00 00 00 00       	mov    $0x0,%esi
  801657:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80165a:	eb 13                	jmp    80166f <spawn+0xee>
	   for (argc = 0; argv[argc] != 0; argc++)
			 string_size += strlen(argv[argc]) + 1;
  80165c:	83 ec 0c             	sub    $0xc,%esp
  80165f:	50                   	push   %eax
  801660:	e8 9b f0 ff ff       	call   800700 <strlen>
  801665:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
	   for (argc = 0; argv[argc] != 0; argc++)
  801669:	83 c3 01             	add    $0x1,%ebx
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801676:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801679:	85 c0                	test   %eax,%eax
  80167b:	75 df                	jne    80165c <spawn+0xdb>
  80167d:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801683:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	   // Determine where to place the strings and the argv array.
	   // Set up pointers into the temporary page 'UTEMP'; we'll map a page
	   // there later, then remap that page into the child environment
	   // at (USTACKTOP - PGSIZE).
	   // strings is the topmost thing on the stack.
	   string_store = (char*) UTEMP + PGSIZE - string_size;
  801689:	bf 00 10 40 00       	mov    $0x401000,%edi
  80168e:	29 f7                	sub    %esi,%edi
	   // argv is below that.  There's one argument pointer per argument, plus
	   // a null pointer.
	   argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801690:	89 fa                	mov    %edi,%edx
  801692:	83 e2 fc             	and    $0xfffffffc,%edx
  801695:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80169c:	29 c2                	sub    %eax,%edx
  80169e:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	   // Make sure that argv, strings, and the 2 words that hold 'argc'
	   // and 'argv' themselves will all fit in a single stack page.
	   if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016a4:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016a7:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016ac:	0f 86 f1 03 00 00    	jbe    801aa3 <spawn+0x522>
			 return -E_NO_MEM;

	   // Allocate the single stack page at UTEMP.
	   if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016b2:	83 ec 04             	sub    $0x4,%esp
  8016b5:	6a 07                	push   $0x7
  8016b7:	68 00 00 40 00       	push   $0x400000
  8016bc:	6a 00                	push   $0x0
  8016be:	e8 79 f4 ff ff       	call   800b3c <sys_page_alloc>
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	0f 88 dc 03 00 00    	js     801aaa <spawn+0x529>
  8016ce:	be 00 00 00 00       	mov    $0x0,%esi
  8016d3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8016d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016dc:	eb 30                	jmp    80170e <spawn+0x18d>
	   //	  environment.)
	   //
	   //	* Set *init_esp to the initial stack pointer for the child,
	   //	  (Again, use an address valid in the child's environment.)
	   for (i = 0; i < argc; i++) {
			 argv_store[i] = UTEMP2USTACK(string_store);
  8016de:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8016e4:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8016ea:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
			 strcpy(string_store, argv[i]);
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016f3:	57                   	push   %edi
  8016f4:	e8 40 f0 ff ff       	call   800739 <strcpy>
			 string_store += strlen(argv[i]) + 1;
  8016f9:	83 c4 04             	add    $0x4,%esp
  8016fc:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016ff:	e8 fc ef ff ff       	call   800700 <strlen>
  801704:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	   //	  (Again, argv should use an address valid in the child's
	   //	  environment.)
	   //
	   //	* Set *init_esp to the initial stack pointer for the child,
	   //	  (Again, use an address valid in the child's environment.)
	   for (i = 0; i < argc; i++) {
  801708:	83 c6 01             	add    $0x1,%esi
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801714:	7f c8                	jg     8016de <spawn+0x15d>
			 argv_store[i] = UTEMP2USTACK(string_store);
			 strcpy(string_store, argv[i]);
			 string_store += strlen(argv[i]) + 1;
	   }
	   argv_store[argc] = 0;
  801716:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80171c:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801722:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	   assert(string_store == (char*)UTEMP + PGSIZE);
  801729:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80172f:	74 19                	je     80174a <spawn+0x1c9>
  801731:	68 48 29 80 00       	push   $0x802948
  801736:	68 7f 28 80 00       	push   $0x80287f
  80173b:	68 f2 00 00 00       	push   $0xf2
  801740:	68 d8 28 80 00       	push   $0x8028d8
  801745:	e8 91 e9 ff ff       	call   8000db <_panic>

	   argv_store[-1] = UTEMP2USTACK(argv_store);
  80174a:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801750:	89 c8                	mov    %ecx,%eax
  801752:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801757:	89 41 fc             	mov    %eax,-0x4(%ecx)
	   argv_store[-2] = argc;
  80175a:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801760:	89 41 f8             	mov    %eax,-0x8(%ecx)

	   *init_esp = UTEMP2USTACK(&argv_store[-2]);
  801763:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801769:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	   // After completing the stack, map it into the child's address space
	   // and unmap it from ours!
	   if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80176f:	83 ec 0c             	sub    $0xc,%esp
  801772:	6a 07                	push   $0x7
  801774:	68 00 d0 bf ee       	push   $0xeebfd000
  801779:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80177f:	68 00 00 40 00       	push   $0x400000
  801784:	6a 00                	push   $0x0
  801786:	e8 f4 f3 ff ff       	call   800b7f <sys_page_map>
  80178b:	89 c3                	mov    %eax,%ebx
  80178d:	83 c4 20             	add    $0x20,%esp
  801790:	85 c0                	test   %eax,%eax
  801792:	0f 88 70 03 00 00    	js     801b08 <spawn+0x587>
			 goto error;
	   if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	68 00 00 40 00       	push   $0x400000
  8017a0:	6a 00                	push   $0x0
  8017a2:	e8 1a f4 ff ff       	call   800bc1 <sys_page_unmap>
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	0f 88 54 03 00 00    	js     801b08 <spawn+0x587>

	   if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
			 return r;

	   // Set up program segments as defined in ELF header.
	   ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017b4:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017ba:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017c1:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	   for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017c7:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8017ce:	00 00 00 
  8017d1:	e9 86 01 00 00       	jmp    80195c <spawn+0x3db>
			 if (ph->p_type != ELF_PROG_LOAD)
  8017d6:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8017dc:	83 38 01             	cmpl   $0x1,(%eax)
  8017df:	0f 85 69 01 00 00    	jne    80194e <spawn+0x3cd>
				    continue;
			 perm = PTE_P | PTE_U;
			 if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8017e5:	89 c1                	mov    %eax,%ecx
  8017e7:	8b 40 18             	mov    0x18(%eax),%eax
  8017ea:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8017f0:	83 e0 02             	and    $0x2,%eax
				    perm |= PTE_W;
  8017f3:	83 f8 01             	cmp    $0x1,%eax
  8017f6:	19 c0                	sbb    %eax,%eax
  8017f8:	83 e0 fe             	and    $0xfffffffe,%eax
  8017fb:	83 c0 07             	add    $0x7,%eax
  8017fe:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
			 if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801804:	89 c8                	mov    %ecx,%eax
  801806:	8b 49 04             	mov    0x4(%ecx),%ecx
  801809:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  80180f:	8b 78 10             	mov    0x10(%eax),%edi
  801812:	8b 50 14             	mov    0x14(%eax),%edx
  801815:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  80181b:	8b 70 08             	mov    0x8(%eax),%esi
	   int i, r;
	   void *blk;

	   //cprintf("map_segment %x+%x\n", va, memsz);

	   if ((i = PGOFF(va))) {
  80181e:	89 f0                	mov    %esi,%eax
  801820:	25 ff 0f 00 00       	and    $0xfff,%eax
  801825:	74 14                	je     80183b <spawn+0x2ba>
			 va -= i;
  801827:	29 c6                	sub    %eax,%esi
			 memsz += i;
  801829:	01 c2                	add    %eax,%edx
  80182b:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
			 filesz += i;
  801831:	01 c7                	add    %eax,%edi
			 fileoffset -= i;
  801833:	29 c1                	sub    %eax,%ecx
  801835:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	   }

	   for (i = 0; i < memsz; i += PGSIZE) {
  80183b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801840:	e9 f7 00 00 00       	jmp    80193c <spawn+0x3bb>
			 if (i >= filesz) {
  801845:	39 df                	cmp    %ebx,%edi
  801847:	77 27                	ja     801870 <spawn+0x2ef>
				    // allocate a blank page
				    if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801849:	83 ec 04             	sub    $0x4,%esp
  80184c:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801852:	56                   	push   %esi
  801853:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801859:	e8 de f2 ff ff       	call   800b3c <sys_page_alloc>
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	85 c0                	test   %eax,%eax
  801863:	0f 89 c7 00 00 00    	jns    801930 <spawn+0x3af>
  801869:	89 c3                	mov    %eax,%ebx
  80186b:	e9 48 02 00 00       	jmp    801ab8 <spawn+0x537>
						  return r;
			 } else {
				    // from file
				    if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801870:	83 ec 04             	sub    $0x4,%esp
  801873:	6a 07                	push   $0x7
  801875:	68 00 00 40 00       	push   $0x400000
  80187a:	6a 00                	push   $0x0
  80187c:	e8 bb f2 ff ff       	call   800b3c <sys_page_alloc>
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	85 c0                	test   %eax,%eax
  801886:	0f 88 22 02 00 00    	js     801aae <spawn+0x52d>
						  return r;
				    if ((r = seek(fd, fileoffset + i)) < 0)
  80188c:	83 ec 08             	sub    $0x8,%esp
  80188f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801895:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80189b:	50                   	push   %eax
  80189c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018a2:	e8 c8 f8 ff ff       	call   80116f <seek>
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	0f 88 00 02 00 00    	js     801ab2 <spawn+0x531>
						  return r;
				    if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018b2:	83 ec 04             	sub    $0x4,%esp
  8018b5:	89 f8                	mov    %edi,%eax
  8018b7:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8018bd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c2:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8018c7:	0f 47 c1             	cmova  %ecx,%eax
  8018ca:	50                   	push   %eax
  8018cb:	68 00 00 40 00       	push   $0x400000
  8018d0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018d6:	e8 bf f7 ff ff       	call   80109a <readn>
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	0f 88 d0 01 00 00    	js     801ab6 <spawn+0x535>
						  return r;
				    if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8018e6:	83 ec 0c             	sub    $0xc,%esp
  8018e9:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018ef:	56                   	push   %esi
  8018f0:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8018f6:	68 00 00 40 00       	push   $0x400000
  8018fb:	6a 00                	push   $0x0
  8018fd:	e8 7d f2 ff ff       	call   800b7f <sys_page_map>
  801902:	83 c4 20             	add    $0x20,%esp
  801905:	85 c0                	test   %eax,%eax
  801907:	79 15                	jns    80191e <spawn+0x39d>
						  panic("spawn: sys_page_map data: %e", r);
  801909:	50                   	push   %eax
  80190a:	68 e4 28 80 00       	push   $0x8028e4
  80190f:	68 25 01 00 00       	push   $0x125
  801914:	68 d8 28 80 00       	push   $0x8028d8
  801919:	e8 bd e7 ff ff       	call   8000db <_panic>
				    sys_page_unmap(0, UTEMP);
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	68 00 00 40 00       	push   $0x400000
  801926:	6a 00                	push   $0x0
  801928:	e8 94 f2 ff ff       	call   800bc1 <sys_page_unmap>
  80192d:	83 c4 10             	add    $0x10,%esp
			 memsz += i;
			 filesz += i;
			 fileoffset -= i;
	   }

	   for (i = 0; i < memsz; i += PGSIZE) {
  801930:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801936:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80193c:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801942:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801948:	0f 87 f7 fe ff ff    	ja     801845 <spawn+0x2c4>
	   if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
			 return r;

	   // Set up program segments as defined in ELF header.
	   ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	   for (i = 0; i < elf->e_phnum; i++, ph++) {
  80194e:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801955:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80195c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801963:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801969:	0f 8c 67 fe ff ff    	jl     8017d6 <spawn+0x255>
				    perm |= PTE_W;
			 if ((r = map_segment(child, ph->p_va, ph->p_memsz,
									   fd, ph->p_filesz, ph->p_offset, perm)) < 0)
				    goto error;
	   }
	   close(fd);
  80196f:	83 ec 0c             	sub    $0xc,%esp
  801972:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801978:	e8 50 f5 ff ff       	call   800ecd <close>
  80197d:	83 c4 10             	add    $0x10,%esp
	   static int
copy_shared_pages(envid_t child)
{
	   // LAB 5: Your code here.
	   int r;
	   bool is_below_ulim = true;
  801980:	c6 85 94 fd ff ff 01 	movb   $0x1,-0x26c(%ebp)
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
  801987:	c7 85 8c fd ff ff 00 	movl   $0x0,-0x274(%ebp)
  80198e:	00 00 00 
	   {
			 if (!(uvpd[i] & PTE_P)) 
  801991:	8b bd 8c fd ff ff    	mov    -0x274(%ebp),%edi
  801997:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  80199e:	a8 01                	test   $0x1,%al
  8019a0:	74 7b                	je     801a1d <spawn+0x49c>
  8019a2:	89 fb                	mov    %edi,%ebx
  8019a4:	c1 e3 0a             	shl    $0xa,%ebx
  8019a7:	c1 e7 16             	shl    $0x16,%edi
  8019aa:	be 00 00 00 00       	mov    $0x0,%esi
  8019af:	eb 5b                	jmp    801a0c <spawn+0x48b>
				    continue;
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) 
			 {
				    unsigned pn = i * NPTENTRIES + j;
				    pte_t pte = uvpt[pn];
  8019b1:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
				    if (pn >= (UTOP >> PGSHIFT)) 
  8019b8:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8019be:	77 39                	ja     8019f9 <spawn+0x478>
				    {
						  is_below_ulim = false;
				    } else if (pte & PTE_SHARE) 
  8019c0:	f6 c4 04             	test   $0x4,%ah
  8019c3:	74 3b                	je     801a00 <spawn+0x47f>
				    {
						  if ((r = sys_page_map(0, (void *)(pn * PGSIZE), child, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  8019c5:	83 ec 0c             	sub    $0xc,%esp
  8019c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8019cd:	50                   	push   %eax
  8019ce:	57                   	push   %edi
  8019cf:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8019d5:	57                   	push   %edi
  8019d6:	6a 00                	push   $0x0
  8019d8:	e8 a2 f1 ff ff       	call   800b7f <sys_page_map>
  8019dd:	83 c4 20             	add    $0x20,%esp
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	79 1c                	jns    801a00 <spawn+0x47f>
	   close(fd);
	   fd = -1;

	   // Copy shared library state.
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);
  8019e4:	50                   	push   %eax
  8019e5:	68 32 29 80 00       	push   $0x802932
  8019ea:	68 82 00 00 00       	push   $0x82
  8019ef:	68 d8 28 80 00       	push   $0x8028d8
  8019f4:	e8 e2 e6 ff ff       	call   8000db <_panic>
			 {
				    unsigned pn = i * NPTENTRIES + j;
				    pte_t pte = uvpt[pn];
				    if (pn >= (UTOP >> PGSHIFT)) 
				    {
						  is_below_ulim = false;
  8019f9:	c6 85 94 fd ff ff 00 	movb   $0x0,-0x26c(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
	   {
			 if (!(uvpd[i] & PTE_P)) 
				    continue;
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) 
  801a00:	83 c6 01             	add    $0x1,%esi
  801a03:	83 c3 01             	add    $0x1,%ebx
  801a06:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801a0c:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  801a12:	7f 09                	jg     801a1d <spawn+0x49c>
  801a14:	80 bd 94 fd ff ff 00 	cmpb   $0x0,-0x26c(%ebp)
  801a1b:	75 94                	jne    8019b1 <spawn+0x430>
copy_shared_pages(envid_t child)
{
	   // LAB 5: Your code here.
	   int r;
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
  801a1d:	83 85 8c fd ff ff 01 	addl   $0x1,-0x274(%ebp)
  801a24:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801a2a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a2f:	0f 8f a4 00 00 00    	jg     801ad9 <spawn+0x558>
  801a35:	80 bd 94 fd ff ff 00 	cmpb   $0x0,-0x26c(%ebp)
  801a3c:	0f 85 4f ff ff ff    	jne    801991 <spawn+0x410>
  801a42:	e9 92 00 00 00       	jmp    801ad9 <spawn+0x558>
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);

	   child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	   if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
			 panic("sys_env_set_trapframe: %e", r);
  801a47:	50                   	push   %eax
  801a48:	68 01 29 80 00       	push   $0x802901
  801a4d:	68 86 00 00 00       	push   $0x86
  801a52:	68 d8 28 80 00       	push   $0x8028d8
  801a57:	e8 7f e6 ff ff       	call   8000db <_panic>

	   if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	6a 02                	push   $0x2
  801a61:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a67:	e8 97 f1 ff ff       	call   800c03 <sys_env_set_status>
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	79 28                	jns    801a9b <spawn+0x51a>
			 panic("sys_env_set_status: %e", r);
  801a73:	50                   	push   %eax
  801a74:	68 1b 29 80 00       	push   $0x80291b
  801a79:	68 89 00 00 00       	push   $0x89
  801a7e:	68 d8 28 80 00       	push   $0x8028d8
  801a83:	e8 53 e6 ff ff       	call   8000db <_panic>
	   //     correct initial eip and esp values in the child.
	   //
	   //   - Start the child process running with sys_env_set_status().

	   if ((r = open(prog, O_RDONLY)) < 0)
			 return r;
  801a88:	8b 9d 88 fd ff ff    	mov    -0x278(%ebp),%ebx
  801a8e:	e9 87 00 00 00       	jmp    801b1a <spawn+0x599>
			 return -E_NOT_EXEC;
	   }

	   // Create new child environment
	   if ((r = sys_exofork()) < 0)
			 return r;
  801a93:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a99:	eb 7f                	jmp    801b1a <spawn+0x599>
			 panic("sys_env_set_trapframe: %e", r);

	   if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
			 panic("sys_env_set_status: %e", r);

	   return child;
  801a9b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801aa1:	eb 77                	jmp    801b1a <spawn+0x599>
	   argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	   // Make sure that argv, strings, and the 2 words that hold 'argc'
	   // and 'argv' themselves will all fit in a single stack page.
	   if ((void*) (argv_store - 2) < (void*) UTEMP)
			 return -E_NO_MEM;
  801aa3:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801aa8:	eb 70                	jmp    801b1a <spawn+0x599>

	   // Allocate the single stack page at UTEMP.
	   if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
			 return r;
  801aaa:	89 c3                	mov    %eax,%ebx
  801aac:	eb 6c                	jmp    801b1a <spawn+0x599>
				    // allocate a blank page
				    if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
						  return r;
			 } else {
				    // from file
				    if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801aae:	89 c3                	mov    %eax,%ebx
  801ab0:	eb 06                	jmp    801ab8 <spawn+0x537>
						  return r;
				    if ((r = seek(fd, fileoffset + i)) < 0)
  801ab2:	89 c3                	mov    %eax,%ebx
  801ab4:	eb 02                	jmp    801ab8 <spawn+0x537>
						  return r;
				    if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ab6:	89 c3                	mov    %eax,%ebx
			 panic("sys_env_set_status: %e", r);

	   return child;

error:
	   sys_env_destroy(child);
  801ab8:	83 ec 0c             	sub    $0xc,%esp
  801abb:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ac1:	e8 f7 ef ff ff       	call   800abd <sys_env_destroy>
	   close(fd);
  801ac6:	83 c4 04             	add    $0x4,%esp
  801ac9:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801acf:	e8 f9 f3 ff ff       	call   800ecd <close>
	   return r;
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	eb 41                	jmp    801b1a <spawn+0x599>

	   // Copy shared library state.
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);

	   child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801ad9:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ae0:	30 00 00 
	   if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ae3:	83 ec 08             	sub    $0x8,%esp
  801ae6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801aec:	50                   	push   %eax
  801aed:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801af3:	e8 4d f1 ff ff       	call   800c45 <sys_env_set_trapframe>
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	85 c0                	test   %eax,%eax
  801afd:	0f 89 59 ff ff ff    	jns    801a5c <spawn+0x4db>
  801b03:	e9 3f ff ff ff       	jmp    801a47 <spawn+0x4c6>
			 goto error;

	   return 0;

error:
	   sys_page_unmap(0, UTEMP);
  801b08:	83 ec 08             	sub    $0x8,%esp
  801b0b:	68 00 00 40 00       	push   $0x400000
  801b10:	6a 00                	push   $0x0
  801b12:	e8 aa f0 ff ff       	call   800bc1 <sys_page_unmap>
  801b17:	83 c4 10             	add    $0x10,%esp

error:
	   sys_env_destroy(child);
	   close(fd);
	   return r;
}
  801b1a:	89 d8                	mov    %ebx,%eax
  801b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1f:	5b                   	pop    %ebx
  801b20:	5e                   	pop    %esi
  801b21:	5f                   	pop    %edi
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
	   int
spawnl(const char *prog, const char *arg0, ...)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  801b29:	8d 55 10             	lea    0x10(%ebp),%edx
{
	   // We calculate argc by advancing the args until we hit NULL.
	   // The contract of the function guarantees that the last
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
  801b2c:	b8 00 00 00 00       	mov    $0x0,%eax
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  801b31:	eb 03                	jmp    801b36 <spawnl+0x12>
			 argc++;
  801b33:	83 c0 01             	add    $0x1,%eax
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  801b36:	83 c2 04             	add    $0x4,%edx
  801b39:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b3d:	75 f4                	jne    801b33 <spawnl+0xf>
			 argc++;
	   va_end(vl);

	   // Now that we have the size of the args, do a second pass
	   // and store the values in a VLA, which has the format of argv
	   const char *argv[argc+2];
  801b3f:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b46:	83 e2 f0             	and    $0xfffffff0,%edx
  801b49:	29 d4                	sub    %edx,%esp
  801b4b:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b4f:	c1 ea 02             	shr    $0x2,%edx
  801b52:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b59:	89 f3                	mov    %esi,%ebx
	   argv[0] = arg0;
  801b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b5e:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	   argv[argc+1] = NULL;
  801b65:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b6c:	00 
  801b6d:	89 c2                	mov    %eax,%edx

	   va_start(vl, arg0);
	   unsigned i;
	   for(i=0;i<argc;i++)
  801b6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b74:	eb 0a                	jmp    801b80 <spawnl+0x5c>
			 argv[i+1] = va_arg(vl, const char *);
  801b76:	83 c0 01             	add    $0x1,%eax
  801b79:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801b7d:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	   argv[0] = arg0;
	   argv[argc+1] = NULL;

	   va_start(vl, arg0);
	   unsigned i;
	   for(i=0;i<argc;i++)
  801b80:	39 d0                	cmp    %edx,%eax
  801b82:	75 f2                	jne    801b76 <spawnl+0x52>
			 argv[i+1] = va_arg(vl, const char *);
	   va_end(vl);
	   return spawn(prog, argv);
  801b84:	83 ec 08             	sub    $0x8,%esp
  801b87:	56                   	push   %esi
  801b88:	ff 75 08             	pushl  0x8(%ebp)
  801b8b:	e8 f1 f9 ff ff       	call   801581 <spawn>
}
  801b90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b9f:	83 ec 0c             	sub    $0xc,%esp
  801ba2:	ff 75 08             	pushl  0x8(%ebp)
  801ba5:	e8 93 f1 ff ff       	call   800d3d <fd2data>
  801baa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bac:	83 c4 08             	add    $0x8,%esp
  801baf:	68 70 29 80 00       	push   $0x802970
  801bb4:	53                   	push   %ebx
  801bb5:	e8 7f eb ff ff       	call   800739 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bba:	8b 46 04             	mov    0x4(%esi),%eax
  801bbd:	2b 06                	sub    (%esi),%eax
  801bbf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bc5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bcc:	00 00 00 
	stat->st_dev = &devpipe;
  801bcf:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bd6:	30 80 00 
	return 0;
}
  801bd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be1:	5b                   	pop    %ebx
  801be2:	5e                   	pop    %esi
  801be3:	5d                   	pop    %ebp
  801be4:	c3                   	ret    

00801be5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	53                   	push   %ebx
  801be9:	83 ec 0c             	sub    $0xc,%esp
  801bec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bef:	53                   	push   %ebx
  801bf0:	6a 00                	push   $0x0
  801bf2:	e8 ca ef ff ff       	call   800bc1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bf7:	89 1c 24             	mov    %ebx,(%esp)
  801bfa:	e8 3e f1 ff ff       	call   800d3d <fd2data>
  801bff:	83 c4 08             	add    $0x8,%esp
  801c02:	50                   	push   %eax
  801c03:	6a 00                	push   $0x0
  801c05:	e8 b7 ef ff ff       	call   800bc1 <sys_page_unmap>
}
  801c0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0d:	c9                   	leave  
  801c0e:	c3                   	ret    

00801c0f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	57                   	push   %edi
  801c13:	56                   	push   %esi
  801c14:	53                   	push   %ebx
  801c15:	83 ec 1c             	sub    $0x1c,%esp
  801c18:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c1b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c1d:	a1 04 40 80 00       	mov    0x804004,%eax
  801c22:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c25:	83 ec 0c             	sub    $0xc,%esp
  801c28:	ff 75 e0             	pushl  -0x20(%ebp)
  801c2b:	e8 32 05 00 00       	call   802162 <pageref>
  801c30:	89 c3                	mov    %eax,%ebx
  801c32:	89 3c 24             	mov    %edi,(%esp)
  801c35:	e8 28 05 00 00       	call   802162 <pageref>
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	39 c3                	cmp    %eax,%ebx
  801c3f:	0f 94 c1             	sete   %cl
  801c42:	0f b6 c9             	movzbl %cl,%ecx
  801c45:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c48:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c4e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c51:	39 ce                	cmp    %ecx,%esi
  801c53:	74 1b                	je     801c70 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c55:	39 c3                	cmp    %eax,%ebx
  801c57:	75 c4                	jne    801c1d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c59:	8b 42 58             	mov    0x58(%edx),%eax
  801c5c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c5f:	50                   	push   %eax
  801c60:	56                   	push   %esi
  801c61:	68 77 29 80 00       	push   $0x802977
  801c66:	e8 49 e5 ff ff       	call   8001b4 <cprintf>
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	eb ad                	jmp    801c1d <_pipeisclosed+0xe>
	}
}
  801c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c76:	5b                   	pop    %ebx
  801c77:	5e                   	pop    %esi
  801c78:	5f                   	pop    %edi
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    

00801c7b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	57                   	push   %edi
  801c7f:	56                   	push   %esi
  801c80:	53                   	push   %ebx
  801c81:	83 ec 28             	sub    $0x28,%esp
  801c84:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c87:	56                   	push   %esi
  801c88:	e8 b0 f0 ff ff       	call   800d3d <fd2data>
  801c8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c8f:	83 c4 10             	add    $0x10,%esp
  801c92:	bf 00 00 00 00       	mov    $0x0,%edi
  801c97:	eb 4b                	jmp    801ce4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c99:	89 da                	mov    %ebx,%edx
  801c9b:	89 f0                	mov    %esi,%eax
  801c9d:	e8 6d ff ff ff       	call   801c0f <_pipeisclosed>
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	75 48                	jne    801cee <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ca6:	e8 72 ee ff ff       	call   800b1d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cab:	8b 43 04             	mov    0x4(%ebx),%eax
  801cae:	8b 0b                	mov    (%ebx),%ecx
  801cb0:	8d 51 20             	lea    0x20(%ecx),%edx
  801cb3:	39 d0                	cmp    %edx,%eax
  801cb5:	73 e2                	jae    801c99 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cbe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cc1:	89 c2                	mov    %eax,%edx
  801cc3:	c1 fa 1f             	sar    $0x1f,%edx
  801cc6:	89 d1                	mov    %edx,%ecx
  801cc8:	c1 e9 1b             	shr    $0x1b,%ecx
  801ccb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cce:	83 e2 1f             	and    $0x1f,%edx
  801cd1:	29 ca                	sub    %ecx,%edx
  801cd3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cd7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cdb:	83 c0 01             	add    $0x1,%eax
  801cde:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce1:	83 c7 01             	add    $0x1,%edi
  801ce4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ce7:	75 c2                	jne    801cab <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ce9:	8b 45 10             	mov    0x10(%ebp),%eax
  801cec:	eb 05                	jmp    801cf3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cee:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf6:	5b                   	pop    %ebx
  801cf7:	5e                   	pop    %esi
  801cf8:	5f                   	pop    %edi
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	57                   	push   %edi
  801cff:	56                   	push   %esi
  801d00:	53                   	push   %ebx
  801d01:	83 ec 18             	sub    $0x18,%esp
  801d04:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d07:	57                   	push   %edi
  801d08:	e8 30 f0 ff ff       	call   800d3d <fd2data>
  801d0d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d17:	eb 3d                	jmp    801d56 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d19:	85 db                	test   %ebx,%ebx
  801d1b:	74 04                	je     801d21 <devpipe_read+0x26>
				return i;
  801d1d:	89 d8                	mov    %ebx,%eax
  801d1f:	eb 44                	jmp    801d65 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d21:	89 f2                	mov    %esi,%edx
  801d23:	89 f8                	mov    %edi,%eax
  801d25:	e8 e5 fe ff ff       	call   801c0f <_pipeisclosed>
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	75 32                	jne    801d60 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d2e:	e8 ea ed ff ff       	call   800b1d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d33:	8b 06                	mov    (%esi),%eax
  801d35:	3b 46 04             	cmp    0x4(%esi),%eax
  801d38:	74 df                	je     801d19 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d3a:	99                   	cltd   
  801d3b:	c1 ea 1b             	shr    $0x1b,%edx
  801d3e:	01 d0                	add    %edx,%eax
  801d40:	83 e0 1f             	and    $0x1f,%eax
  801d43:	29 d0                	sub    %edx,%eax
  801d45:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d4d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d50:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d53:	83 c3 01             	add    $0x1,%ebx
  801d56:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d59:	75 d8                	jne    801d33 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d5e:	eb 05                	jmp    801d65 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d60:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    

00801d6d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	56                   	push   %esi
  801d71:	53                   	push   %ebx
  801d72:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d78:	50                   	push   %eax
  801d79:	e8 d6 ef ff ff       	call   800d54 <fd_alloc>
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	89 c2                	mov    %eax,%edx
  801d83:	85 c0                	test   %eax,%eax
  801d85:	0f 88 2c 01 00 00    	js     801eb7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8b:	83 ec 04             	sub    $0x4,%esp
  801d8e:	68 07 04 00 00       	push   $0x407
  801d93:	ff 75 f4             	pushl  -0xc(%ebp)
  801d96:	6a 00                	push   $0x0
  801d98:	e8 9f ed ff ff       	call   800b3c <sys_page_alloc>
  801d9d:	83 c4 10             	add    $0x10,%esp
  801da0:	89 c2                	mov    %eax,%edx
  801da2:	85 c0                	test   %eax,%eax
  801da4:	0f 88 0d 01 00 00    	js     801eb7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801daa:	83 ec 0c             	sub    $0xc,%esp
  801dad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801db0:	50                   	push   %eax
  801db1:	e8 9e ef ff ff       	call   800d54 <fd_alloc>
  801db6:	89 c3                	mov    %eax,%ebx
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	0f 88 e2 00 00 00    	js     801ea5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc3:	83 ec 04             	sub    $0x4,%esp
  801dc6:	68 07 04 00 00       	push   $0x407
  801dcb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dce:	6a 00                	push   $0x0
  801dd0:	e8 67 ed ff ff       	call   800b3c <sys_page_alloc>
  801dd5:	89 c3                	mov    %eax,%ebx
  801dd7:	83 c4 10             	add    $0x10,%esp
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	0f 88 c3 00 00 00    	js     801ea5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801de2:	83 ec 0c             	sub    $0xc,%esp
  801de5:	ff 75 f4             	pushl  -0xc(%ebp)
  801de8:	e8 50 ef ff ff       	call   800d3d <fd2data>
  801ded:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801def:	83 c4 0c             	add    $0xc,%esp
  801df2:	68 07 04 00 00       	push   $0x407
  801df7:	50                   	push   %eax
  801df8:	6a 00                	push   $0x0
  801dfa:	e8 3d ed ff ff       	call   800b3c <sys_page_alloc>
  801dff:	89 c3                	mov    %eax,%ebx
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	85 c0                	test   %eax,%eax
  801e06:	0f 88 89 00 00 00    	js     801e95 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0c:	83 ec 0c             	sub    $0xc,%esp
  801e0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e12:	e8 26 ef ff ff       	call   800d3d <fd2data>
  801e17:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e1e:	50                   	push   %eax
  801e1f:	6a 00                	push   $0x0
  801e21:	56                   	push   %esi
  801e22:	6a 00                	push   $0x0
  801e24:	e8 56 ed ff ff       	call   800b7f <sys_page_map>
  801e29:	89 c3                	mov    %eax,%ebx
  801e2b:	83 c4 20             	add    $0x20,%esp
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 55                	js     801e87 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e32:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e40:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e47:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e50:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e55:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e5c:	83 ec 0c             	sub    $0xc,%esp
  801e5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e62:	e8 c6 ee ff ff       	call   800d2d <fd2num>
  801e67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e6a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e6c:	83 c4 04             	add    $0x4,%esp
  801e6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e72:	e8 b6 ee ff ff       	call   800d2d <fd2num>
  801e77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e7a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	ba 00 00 00 00       	mov    $0x0,%edx
  801e85:	eb 30                	jmp    801eb7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e87:	83 ec 08             	sub    $0x8,%esp
  801e8a:	56                   	push   %esi
  801e8b:	6a 00                	push   $0x0
  801e8d:	e8 2f ed ff ff       	call   800bc1 <sys_page_unmap>
  801e92:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e95:	83 ec 08             	sub    $0x8,%esp
  801e98:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9b:	6a 00                	push   $0x0
  801e9d:	e8 1f ed ff ff       	call   800bc1 <sys_page_unmap>
  801ea2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ea5:	83 ec 08             	sub    $0x8,%esp
  801ea8:	ff 75 f4             	pushl  -0xc(%ebp)
  801eab:	6a 00                	push   $0x0
  801ead:	e8 0f ed ff ff       	call   800bc1 <sys_page_unmap>
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801eb7:	89 d0                	mov    %edx,%eax
  801eb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebc:	5b                   	pop    %ebx
  801ebd:	5e                   	pop    %esi
  801ebe:	5d                   	pop    %ebp
  801ebf:	c3                   	ret    

00801ec0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec9:	50                   	push   %eax
  801eca:	ff 75 08             	pushl  0x8(%ebp)
  801ecd:	e8 d1 ee ff ff       	call   800da3 <fd_lookup>
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	78 18                	js     801ef1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ed9:	83 ec 0c             	sub    $0xc,%esp
  801edc:	ff 75 f4             	pushl  -0xc(%ebp)
  801edf:	e8 59 ee ff ff       	call   800d3d <fd2data>
	return _pipeisclosed(fd, p);
  801ee4:	89 c2                	mov    %eax,%edx
  801ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee9:	e8 21 fd ff ff       	call   801c0f <_pipeisclosed>
  801eee:	83 c4 10             	add    $0x10,%esp
}
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    

00801ef3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ef6:	b8 00 00 00 00       	mov    $0x0,%eax
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    

00801efd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f03:	68 8f 29 80 00       	push   $0x80298f
  801f08:	ff 75 0c             	pushl  0xc(%ebp)
  801f0b:	e8 29 e8 ff ff       	call   800739 <strcpy>
	return 0;
}
  801f10:	b8 00 00 00 00       	mov    $0x0,%eax
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    

00801f17 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	57                   	push   %edi
  801f1b:	56                   	push   %esi
  801f1c:	53                   	push   %ebx
  801f1d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f23:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f28:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f2e:	eb 2d                	jmp    801f5d <devcons_write+0x46>
		m = n - tot;
  801f30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f33:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f35:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f38:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f3d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f40:	83 ec 04             	sub    $0x4,%esp
  801f43:	53                   	push   %ebx
  801f44:	03 45 0c             	add    0xc(%ebp),%eax
  801f47:	50                   	push   %eax
  801f48:	57                   	push   %edi
  801f49:	e8 7d e9 ff ff       	call   8008cb <memmove>
		sys_cputs(buf, m);
  801f4e:	83 c4 08             	add    $0x8,%esp
  801f51:	53                   	push   %ebx
  801f52:	57                   	push   %edi
  801f53:	e8 28 eb ff ff       	call   800a80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f58:	01 de                	add    %ebx,%esi
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	89 f0                	mov    %esi,%eax
  801f5f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f62:	72 cc                	jb     801f30 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f67:	5b                   	pop    %ebx
  801f68:	5e                   	pop    %esi
  801f69:	5f                   	pop    %edi
  801f6a:	5d                   	pop    %ebp
  801f6b:	c3                   	ret    

00801f6c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	83 ec 08             	sub    $0x8,%esp
  801f72:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f7b:	74 2a                	je     801fa7 <devcons_read+0x3b>
  801f7d:	eb 05                	jmp    801f84 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f7f:	e8 99 eb ff ff       	call   800b1d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f84:	e8 15 eb ff ff       	call   800a9e <sys_cgetc>
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	74 f2                	je     801f7f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	78 16                	js     801fa7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f91:	83 f8 04             	cmp    $0x4,%eax
  801f94:	74 0c                	je     801fa2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f96:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f99:	88 02                	mov    %al,(%edx)
	return 1;
  801f9b:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa0:	eb 05                	jmp    801fa7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fa2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fa7:	c9                   	leave  
  801fa8:	c3                   	ret    

00801fa9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801faf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fb5:	6a 01                	push   $0x1
  801fb7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fba:	50                   	push   %eax
  801fbb:	e8 c0 ea ff ff       	call   800a80 <sys_cputs>
}
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <getchar>:

int
getchar(void)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fcb:	6a 01                	push   $0x1
  801fcd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd0:	50                   	push   %eax
  801fd1:	6a 00                	push   $0x0
  801fd3:	e8 31 f0 ff ff       	call   801009 <read>
	if (r < 0)
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	78 0f                	js     801fee <getchar+0x29>
		return r;
	if (r < 1)
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	7e 06                	jle    801fe9 <getchar+0x24>
		return -E_EOF;
	return c;
  801fe3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fe7:	eb 05                	jmp    801fee <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fe9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff9:	50                   	push   %eax
  801ffa:	ff 75 08             	pushl  0x8(%ebp)
  801ffd:	e8 a1 ed ff ff       	call   800da3 <fd_lookup>
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	78 11                	js     80201a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802009:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802012:	39 10                	cmp    %edx,(%eax)
  802014:	0f 94 c0             	sete   %al
  802017:	0f b6 c0             	movzbl %al,%eax
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    

0080201c <opencons>:

int
opencons(void)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802022:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802025:	50                   	push   %eax
  802026:	e8 29 ed ff ff       	call   800d54 <fd_alloc>
  80202b:	83 c4 10             	add    $0x10,%esp
		return r;
  80202e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802030:	85 c0                	test   %eax,%eax
  802032:	78 3e                	js     802072 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802034:	83 ec 04             	sub    $0x4,%esp
  802037:	68 07 04 00 00       	push   $0x407
  80203c:	ff 75 f4             	pushl  -0xc(%ebp)
  80203f:	6a 00                	push   $0x0
  802041:	e8 f6 ea ff ff       	call   800b3c <sys_page_alloc>
  802046:	83 c4 10             	add    $0x10,%esp
		return r;
  802049:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 23                	js     802072 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80204f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802058:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802064:	83 ec 0c             	sub    $0xc,%esp
  802067:	50                   	push   %eax
  802068:	e8 c0 ec ff ff       	call   800d2d <fd2num>
  80206d:	89 c2                	mov    %eax,%edx
  80206f:	83 c4 10             	add    $0x10,%esp
}
  802072:	89 d0                	mov    %edx,%eax
  802074:	c9                   	leave  
  802075:	c3                   	ret    

00802076 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	56                   	push   %esi
  80207a:	53                   	push   %ebx
  80207b:	8b 75 08             	mov    0x8(%ebp),%esi
  80207e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802081:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  802084:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  802086:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80208b:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  80208e:	83 ec 0c             	sub    $0xc,%esp
  802091:	50                   	push   %eax
  802092:	e8 55 ec ff ff       	call   800cec <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  802097:	83 c4 10             	add    $0x10,%esp
  80209a:	85 c0                	test   %eax,%eax
  80209c:	78 0e                	js     8020ac <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  80209e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8020a4:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  8020a7:	8b 52 78             	mov    0x78(%edx),%edx
  8020aa:	eb 0a                	jmp    8020b6 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  8020ac:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  8020b1:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  8020b6:	85 f6                	test   %esi,%esi
  8020b8:	74 02                	je     8020bc <ipc_recv+0x46>
			 *from_env_store = s_envid;
  8020ba:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  8020bc:	85 db                	test   %ebx,%ebx
  8020be:	74 02                	je     8020c2 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  8020c0:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  8020c2:	85 c0                	test   %eax,%eax
  8020c4:	78 08                	js     8020ce <ipc_recv+0x58>
  8020c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8020cb:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  8020ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020d1:	5b                   	pop    %ebx
  8020d2:	5e                   	pop    %esi
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    

008020d5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	57                   	push   %edi
  8020d9:	56                   	push   %esi
  8020da:	53                   	push   %ebx
  8020db:	83 ec 0c             	sub    $0xc,%esp
  8020de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  8020e7:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  8020e9:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8020ee:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  8020f1:	ff 75 14             	pushl  0x14(%ebp)
  8020f4:	53                   	push   %ebx
  8020f5:	56                   	push   %esi
  8020f6:	57                   	push   %edi
  8020f7:	e8 cd eb ff ff       	call   800cc9 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  8020fc:	83 c4 10             	add    $0x10,%esp
  8020ff:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802102:	75 07                	jne    80210b <ipc_send+0x36>
				    sys_yield();
  802104:	e8 14 ea ff ff       	call   800b1d <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  802109:	eb e6                	jmp    8020f1 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  80210b:	85 c0                	test   %eax,%eax
  80210d:	74 12                	je     802121 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  80210f:	50                   	push   %eax
  802110:	68 9b 29 80 00       	push   $0x80299b
  802115:	6a 4b                	push   $0x4b
  802117:	68 af 29 80 00       	push   $0x8029af
  80211c:	e8 ba df ff ff       	call   8000db <_panic>
			 }
	   }
}
  802121:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    

00802129 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  80212f:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  802134:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802137:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80213d:	8b 52 50             	mov    0x50(%edx),%edx
  802140:	39 ca                	cmp    %ecx,%edx
  802142:	75 0d                	jne    802151 <ipc_find_env+0x28>
				    return envs[i].env_id;
  802144:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802147:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80214c:	8b 40 48             	mov    0x48(%eax),%eax
  80214f:	eb 0f                	jmp    802160 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  802151:	83 c0 01             	add    $0x1,%eax
  802154:	3d 00 04 00 00       	cmp    $0x400,%eax
  802159:	75 d9                	jne    802134 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  80215b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    

00802162 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802162:	55                   	push   %ebp
  802163:	89 e5                	mov    %esp,%ebp
  802165:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802168:	89 d0                	mov    %edx,%eax
  80216a:	c1 e8 16             	shr    $0x16,%eax
  80216d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802174:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802179:	f6 c1 01             	test   $0x1,%cl
  80217c:	74 1d                	je     80219b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80217e:	c1 ea 0c             	shr    $0xc,%edx
  802181:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802188:	f6 c2 01             	test   $0x1,%dl
  80218b:	74 0e                	je     80219b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80218d:	c1 ea 0c             	shr    $0xc,%edx
  802190:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802197:	ef 
  802198:	0f b7 c0             	movzwl %ax,%eax
}
  80219b:	5d                   	pop    %ebp
  80219c:	c3                   	ret    
  80219d:	66 90                	xchg   %ax,%ax
  80219f:	90                   	nop

008021a0 <__udivdi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 f6                	test   %esi,%esi
  8021b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021bd:	89 ca                	mov    %ecx,%edx
  8021bf:	89 f8                	mov    %edi,%eax
  8021c1:	75 3d                	jne    802200 <__udivdi3+0x60>
  8021c3:	39 cf                	cmp    %ecx,%edi
  8021c5:	0f 87 c5 00 00 00    	ja     802290 <__udivdi3+0xf0>
  8021cb:	85 ff                	test   %edi,%edi
  8021cd:	89 fd                	mov    %edi,%ebp
  8021cf:	75 0b                	jne    8021dc <__udivdi3+0x3c>
  8021d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d6:	31 d2                	xor    %edx,%edx
  8021d8:	f7 f7                	div    %edi
  8021da:	89 c5                	mov    %eax,%ebp
  8021dc:	89 c8                	mov    %ecx,%eax
  8021de:	31 d2                	xor    %edx,%edx
  8021e0:	f7 f5                	div    %ebp
  8021e2:	89 c1                	mov    %eax,%ecx
  8021e4:	89 d8                	mov    %ebx,%eax
  8021e6:	89 cf                	mov    %ecx,%edi
  8021e8:	f7 f5                	div    %ebp
  8021ea:	89 c3                	mov    %eax,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	39 ce                	cmp    %ecx,%esi
  802202:	77 74                	ja     802278 <__udivdi3+0xd8>
  802204:	0f bd fe             	bsr    %esi,%edi
  802207:	83 f7 1f             	xor    $0x1f,%edi
  80220a:	0f 84 98 00 00 00    	je     8022a8 <__udivdi3+0x108>
  802210:	bb 20 00 00 00       	mov    $0x20,%ebx
  802215:	89 f9                	mov    %edi,%ecx
  802217:	89 c5                	mov    %eax,%ebp
  802219:	29 fb                	sub    %edi,%ebx
  80221b:	d3 e6                	shl    %cl,%esi
  80221d:	89 d9                	mov    %ebx,%ecx
  80221f:	d3 ed                	shr    %cl,%ebp
  802221:	89 f9                	mov    %edi,%ecx
  802223:	d3 e0                	shl    %cl,%eax
  802225:	09 ee                	or     %ebp,%esi
  802227:	89 d9                	mov    %ebx,%ecx
  802229:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80222d:	89 d5                	mov    %edx,%ebp
  80222f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802233:	d3 ed                	shr    %cl,%ebp
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e2                	shl    %cl,%edx
  802239:	89 d9                	mov    %ebx,%ecx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	09 c2                	or     %eax,%edx
  80223f:	89 d0                	mov    %edx,%eax
  802241:	89 ea                	mov    %ebp,%edx
  802243:	f7 f6                	div    %esi
  802245:	89 d5                	mov    %edx,%ebp
  802247:	89 c3                	mov    %eax,%ebx
  802249:	f7 64 24 0c          	mull   0xc(%esp)
  80224d:	39 d5                	cmp    %edx,%ebp
  80224f:	72 10                	jb     802261 <__udivdi3+0xc1>
  802251:	8b 74 24 08          	mov    0x8(%esp),%esi
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e6                	shl    %cl,%esi
  802259:	39 c6                	cmp    %eax,%esi
  80225b:	73 07                	jae    802264 <__udivdi3+0xc4>
  80225d:	39 d5                	cmp    %edx,%ebp
  80225f:	75 03                	jne    802264 <__udivdi3+0xc4>
  802261:	83 eb 01             	sub    $0x1,%ebx
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 d8                	mov    %ebx,%eax
  802268:	89 fa                	mov    %edi,%edx
  80226a:	83 c4 1c             	add    $0x1c,%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5f                   	pop    %edi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    
  802272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802278:	31 ff                	xor    %edi,%edi
  80227a:	31 db                	xor    %ebx,%ebx
  80227c:	89 d8                	mov    %ebx,%eax
  80227e:	89 fa                	mov    %edi,%edx
  802280:	83 c4 1c             	add    $0x1c,%esp
  802283:	5b                   	pop    %ebx
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    
  802288:	90                   	nop
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 d8                	mov    %ebx,%eax
  802292:	f7 f7                	div    %edi
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 c3                	mov    %eax,%ebx
  802298:	89 d8                	mov    %ebx,%eax
  80229a:	89 fa                	mov    %edi,%edx
  80229c:	83 c4 1c             	add    $0x1c,%esp
  80229f:	5b                   	pop    %ebx
  8022a0:	5e                   	pop    %esi
  8022a1:	5f                   	pop    %edi
  8022a2:	5d                   	pop    %ebp
  8022a3:	c3                   	ret    
  8022a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a8:	39 ce                	cmp    %ecx,%esi
  8022aa:	72 0c                	jb     8022b8 <__udivdi3+0x118>
  8022ac:	31 db                	xor    %ebx,%ebx
  8022ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022b2:	0f 87 34 ff ff ff    	ja     8021ec <__udivdi3+0x4c>
  8022b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022bd:	e9 2a ff ff ff       	jmp    8021ec <__udivdi3+0x4c>
  8022c2:	66 90                	xchg   %ax,%ax
  8022c4:	66 90                	xchg   %ax,%ax
  8022c6:	66 90                	xchg   %ax,%ax
  8022c8:	66 90                	xchg   %ax,%ax
  8022ca:	66 90                	xchg   %ax,%ax
  8022cc:	66 90                	xchg   %ax,%ax
  8022ce:	66 90                	xchg   %ax,%ax

008022d0 <__umoddi3>:
  8022d0:	55                   	push   %ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 1c             	sub    $0x1c,%esp
  8022d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022e7:	85 d2                	test   %edx,%edx
  8022e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022f1:	89 f3                	mov    %esi,%ebx
  8022f3:	89 3c 24             	mov    %edi,(%esp)
  8022f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022fa:	75 1c                	jne    802318 <__umoddi3+0x48>
  8022fc:	39 f7                	cmp    %esi,%edi
  8022fe:	76 50                	jbe    802350 <__umoddi3+0x80>
  802300:	89 c8                	mov    %ecx,%eax
  802302:	89 f2                	mov    %esi,%edx
  802304:	f7 f7                	div    %edi
  802306:	89 d0                	mov    %edx,%eax
  802308:	31 d2                	xor    %edx,%edx
  80230a:	83 c4 1c             	add    $0x1c,%esp
  80230d:	5b                   	pop    %ebx
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    
  802312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802318:	39 f2                	cmp    %esi,%edx
  80231a:	89 d0                	mov    %edx,%eax
  80231c:	77 52                	ja     802370 <__umoddi3+0xa0>
  80231e:	0f bd ea             	bsr    %edx,%ebp
  802321:	83 f5 1f             	xor    $0x1f,%ebp
  802324:	75 5a                	jne    802380 <__umoddi3+0xb0>
  802326:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80232a:	0f 82 e0 00 00 00    	jb     802410 <__umoddi3+0x140>
  802330:	39 0c 24             	cmp    %ecx,(%esp)
  802333:	0f 86 d7 00 00 00    	jbe    802410 <__umoddi3+0x140>
  802339:	8b 44 24 08          	mov    0x8(%esp),%eax
  80233d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802341:	83 c4 1c             	add    $0x1c,%esp
  802344:	5b                   	pop    %ebx
  802345:	5e                   	pop    %esi
  802346:	5f                   	pop    %edi
  802347:	5d                   	pop    %ebp
  802348:	c3                   	ret    
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	85 ff                	test   %edi,%edi
  802352:	89 fd                	mov    %edi,%ebp
  802354:	75 0b                	jne    802361 <__umoddi3+0x91>
  802356:	b8 01 00 00 00       	mov    $0x1,%eax
  80235b:	31 d2                	xor    %edx,%edx
  80235d:	f7 f7                	div    %edi
  80235f:	89 c5                	mov    %eax,%ebp
  802361:	89 f0                	mov    %esi,%eax
  802363:	31 d2                	xor    %edx,%edx
  802365:	f7 f5                	div    %ebp
  802367:	89 c8                	mov    %ecx,%eax
  802369:	f7 f5                	div    %ebp
  80236b:	89 d0                	mov    %edx,%eax
  80236d:	eb 99                	jmp    802308 <__umoddi3+0x38>
  80236f:	90                   	nop
  802370:	89 c8                	mov    %ecx,%eax
  802372:	89 f2                	mov    %esi,%edx
  802374:	83 c4 1c             	add    $0x1c,%esp
  802377:	5b                   	pop    %ebx
  802378:	5e                   	pop    %esi
  802379:	5f                   	pop    %edi
  80237a:	5d                   	pop    %ebp
  80237b:	c3                   	ret    
  80237c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802380:	8b 34 24             	mov    (%esp),%esi
  802383:	bf 20 00 00 00       	mov    $0x20,%edi
  802388:	89 e9                	mov    %ebp,%ecx
  80238a:	29 ef                	sub    %ebp,%edi
  80238c:	d3 e0                	shl    %cl,%eax
  80238e:	89 f9                	mov    %edi,%ecx
  802390:	89 f2                	mov    %esi,%edx
  802392:	d3 ea                	shr    %cl,%edx
  802394:	89 e9                	mov    %ebp,%ecx
  802396:	09 c2                	or     %eax,%edx
  802398:	89 d8                	mov    %ebx,%eax
  80239a:	89 14 24             	mov    %edx,(%esp)
  80239d:	89 f2                	mov    %esi,%edx
  80239f:	d3 e2                	shl    %cl,%edx
  8023a1:	89 f9                	mov    %edi,%ecx
  8023a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023ab:	d3 e8                	shr    %cl,%eax
  8023ad:	89 e9                	mov    %ebp,%ecx
  8023af:	89 c6                	mov    %eax,%esi
  8023b1:	d3 e3                	shl    %cl,%ebx
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	89 d0                	mov    %edx,%eax
  8023b7:	d3 e8                	shr    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	09 d8                	or     %ebx,%eax
  8023bd:	89 d3                	mov    %edx,%ebx
  8023bf:	89 f2                	mov    %esi,%edx
  8023c1:	f7 34 24             	divl   (%esp)
  8023c4:	89 d6                	mov    %edx,%esi
  8023c6:	d3 e3                	shl    %cl,%ebx
  8023c8:	f7 64 24 04          	mull   0x4(%esp)
  8023cc:	39 d6                	cmp    %edx,%esi
  8023ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023d2:	89 d1                	mov    %edx,%ecx
  8023d4:	89 c3                	mov    %eax,%ebx
  8023d6:	72 08                	jb     8023e0 <__umoddi3+0x110>
  8023d8:	75 11                	jne    8023eb <__umoddi3+0x11b>
  8023da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023de:	73 0b                	jae    8023eb <__umoddi3+0x11b>
  8023e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023e4:	1b 14 24             	sbb    (%esp),%edx
  8023e7:	89 d1                	mov    %edx,%ecx
  8023e9:	89 c3                	mov    %eax,%ebx
  8023eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023ef:	29 da                	sub    %ebx,%edx
  8023f1:	19 ce                	sbb    %ecx,%esi
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 f0                	mov    %esi,%eax
  8023f7:	d3 e0                	shl    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	d3 ea                	shr    %cl,%edx
  8023fd:	89 e9                	mov    %ebp,%ecx
  8023ff:	d3 ee                	shr    %cl,%esi
  802401:	09 d0                	or     %edx,%eax
  802403:	89 f2                	mov    %esi,%edx
  802405:	83 c4 1c             	add    $0x1c,%esp
  802408:	5b                   	pop    %ebx
  802409:	5e                   	pop    %esi
  80240a:	5f                   	pop    %edi
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    
  80240d:	8d 76 00             	lea    0x0(%esi),%esi
  802410:	29 f9                	sub    %edi,%ecx
  802412:	19 d6                	sbb    %edx,%esi
  802414:	89 74 24 04          	mov    %esi,0x4(%esp)
  802418:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80241c:	e9 18 ff ff ff       	jmp    802339 <__umoddi3+0x69>
