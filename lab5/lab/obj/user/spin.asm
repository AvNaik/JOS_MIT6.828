
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 c0 21 80 00       	push   $0x8021c0
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 c1 0d 00 00       	call   800e0a <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 38 22 80 00       	push   $0x802238
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 e8 21 80 00       	push   $0x8021e8
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 9b 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800076:	e8 96 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80007b:	e8 91 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800080:	e8 8c 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800085:	e8 87 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80008a:	e8 82 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80008f:	e8 7d 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800094:	e8 78 0a 00 00       	call   800b11 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 10 22 80 00 	movl   $0x802210,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 04 0a 00 00       	call   800ab1 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000c0:	e8 2d 0a 00 00       	call   800af2 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 ce 10 00 00       	call   8011d4 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 a1 09 00 00       	call   800ab1 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 2f 09 00 00       	call   800a74 <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 54 01 00 00       	call   8002df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 d4 08 00 00       	call   800a74 <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e3:	39 d3                	cmp    %edx,%ebx
  8001e5:	72 05                	jb     8001ec <printnum+0x30>
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 45                	ja     800231 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	ff 75 18             	pushl  0x18(%ebp)
  8001f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f8:	53                   	push   %ebx
  8001f9:	ff 75 10             	pushl  0x10(%ebp)
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 20 1d 00 00       	call   801f30 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 18                	jmp    80023b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 03                	jmp    800234 <printnum+0x78>
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f e8                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 0d 1e 00 00       	call   802060 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 60 22 80 00 	movsbl 0x802260(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026e:	83 fa 01             	cmp    $0x1,%edx
  800271:	7e 0e                	jle    800281 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 08             	lea    0x8(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	8b 52 04             	mov    0x4(%edx),%edx
  80027f:	eb 22                	jmp    8002a3 <getuint+0x38>
	else if (lflag)
  800281:	85 d2                	test   %edx,%edx
  800283:	74 10                	je     800295 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	ba 00 00 00 00       	mov    $0x0,%edx
  800293:	eb 0e                	jmp    8002a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b4:	73 0a                	jae    8002c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002be:	88 02                	mov    %al,(%edx)
}
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cb:	50                   	push   %eax
  8002cc:	ff 75 10             	pushl  0x10(%ebp)
  8002cf:	ff 75 0c             	pushl  0xc(%ebp)
  8002d2:	ff 75 08             	pushl  0x8(%ebp)
  8002d5:	e8 05 00 00 00       	call   8002df <vprintfmt>
	va_end(ap);
}
  8002da:	83 c4 10             	add    $0x10,%esp
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	83 ec 2c             	sub    $0x2c,%esp
  8002e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f1:	eb 12                	jmp    800305 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	0f 84 89 03 00 00    	je     800684 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	53                   	push   %ebx
  8002ff:	50                   	push   %eax
  800300:	ff d6                	call   *%esi
  800302:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	83 c7 01             	add    $0x1,%edi
  800308:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030c:	83 f8 25             	cmp    $0x25,%eax
  80030f:	75 e2                	jne    8002f3 <vprintfmt+0x14>
  800311:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800315:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800323:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
  80032f:	eb 07                	jmp    800338 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800334:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8d 47 01             	lea    0x1(%edi),%eax
  80033b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033e:	0f b6 07             	movzbl (%edi),%eax
  800341:	0f b6 c8             	movzbl %al,%ecx
  800344:	83 e8 23             	sub    $0x23,%eax
  800347:	3c 55                	cmp    $0x55,%al
  800349:	0f 87 1a 03 00 00    	ja     800669 <vprintfmt+0x38a>
  80034f:	0f b6 c0             	movzbl %al,%eax
  800352:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800360:	eb d6                	jmp    800338 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800365:	b8 00 00 00 00       	mov    $0x0,%eax
  80036a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800370:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800374:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800377:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80037a:	83 fa 09             	cmp    $0x9,%edx
  80037d:	77 39                	ja     8003b8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800382:	eb e9                	jmp    80036d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 48 04             	lea    0x4(%eax),%ecx
  80038a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80038d:	8b 00                	mov    (%eax),%eax
  80038f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800395:	eb 27                	jmp    8003be <vprintfmt+0xdf>
  800397:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039a:	85 c0                	test   %eax,%eax
  80039c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a1:	0f 49 c8             	cmovns %eax,%ecx
  8003a4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003aa:	eb 8c                	jmp    800338 <vprintfmt+0x59>
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003af:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b6:	eb 80                	jmp    800338 <vprintfmt+0x59>
  8003b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003bb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c2:	0f 89 70 ff ff ff    	jns    800338 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d5:	e9 5e ff ff ff       	jmp    800338 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003da:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e0:	e9 53 ff ff ff       	jmp    800338 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8d 50 04             	lea    0x4(%eax),%edx
  8003eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ee:	83 ec 08             	sub    $0x8,%esp
  8003f1:	53                   	push   %ebx
  8003f2:	ff 30                	pushl  (%eax)
  8003f4:	ff d6                	call   *%esi
			break;
  8003f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003fc:	e9 04 ff ff ff       	jmp    800305 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 50 04             	lea    0x4(%eax),%edx
  800407:	89 55 14             	mov    %edx,0x14(%ebp)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	99                   	cltd   
  80040d:	31 d0                	xor    %edx,%eax
  80040f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800411:	83 f8 0f             	cmp    $0xf,%eax
  800414:	7f 0b                	jg     800421 <vprintfmt+0x142>
  800416:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  80041d:	85 d2                	test   %edx,%edx
  80041f:	75 18                	jne    800439 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800421:	50                   	push   %eax
  800422:	68 78 22 80 00       	push   $0x802278
  800427:	53                   	push   %ebx
  800428:	56                   	push   %esi
  800429:	e8 94 fe ff ff       	call   8002c2 <printfmt>
  80042e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800434:	e9 cc fe ff ff       	jmp    800305 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800439:	52                   	push   %edx
  80043a:	68 dd 26 80 00       	push   $0x8026dd
  80043f:	53                   	push   %ebx
  800440:	56                   	push   %esi
  800441:	e8 7c fe ff ff       	call   8002c2 <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044c:	e9 b4 fe ff ff       	jmp    800305 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045c:	85 ff                	test   %edi,%edi
  80045e:	b8 71 22 80 00       	mov    $0x802271,%eax
  800463:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800466:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046a:	0f 8e 94 00 00 00    	jle    800504 <vprintfmt+0x225>
  800470:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800474:	0f 84 98 00 00 00    	je     800512 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	ff 75 d0             	pushl  -0x30(%ebp)
  800480:	57                   	push   %edi
  800481:	e8 86 02 00 00       	call   80070c <strnlen>
  800486:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800489:	29 c1                	sub    %eax,%ecx
  80048b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80048e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800491:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800495:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800498:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	eb 0f                	jmp    8004ae <vprintfmt+0x1cf>
					putch(padc, putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	53                   	push   %ebx
  8004a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	83 ef 01             	sub    $0x1,%edi
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	85 ff                	test   %edi,%edi
  8004b0:	7f ed                	jg     80049f <vprintfmt+0x1c0>
  8004b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b8:	85 c9                	test   %ecx,%ecx
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	0f 49 c1             	cmovns %ecx,%eax
  8004c2:	29 c1                	sub    %eax,%ecx
  8004c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cd:	89 cb                	mov    %ecx,%ebx
  8004cf:	eb 4d                	jmp    80051e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d5:	74 1b                	je     8004f2 <vprintfmt+0x213>
  8004d7:	0f be c0             	movsbl %al,%eax
  8004da:	83 e8 20             	sub    $0x20,%eax
  8004dd:	83 f8 5e             	cmp    $0x5e,%eax
  8004e0:	76 10                	jbe    8004f2 <vprintfmt+0x213>
					putch('?', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	ff 75 0c             	pushl  0xc(%ebp)
  8004e8:	6a 3f                	push   $0x3f
  8004ea:	ff 55 08             	call   *0x8(%ebp)
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	eb 0d                	jmp    8004ff <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	ff 75 0c             	pushl  0xc(%ebp)
  8004f8:	52                   	push   %edx
  8004f9:	ff 55 08             	call   *0x8(%ebp)
  8004fc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ff:	83 eb 01             	sub    $0x1,%ebx
  800502:	eb 1a                	jmp    80051e <vprintfmt+0x23f>
  800504:	89 75 08             	mov    %esi,0x8(%ebp)
  800507:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800510:	eb 0c                	jmp    80051e <vprintfmt+0x23f>
  800512:	89 75 08             	mov    %esi,0x8(%ebp)
  800515:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800518:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051e:	83 c7 01             	add    $0x1,%edi
  800521:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800525:	0f be d0             	movsbl %al,%edx
  800528:	85 d2                	test   %edx,%edx
  80052a:	74 23                	je     80054f <vprintfmt+0x270>
  80052c:	85 f6                	test   %esi,%esi
  80052e:	78 a1                	js     8004d1 <vprintfmt+0x1f2>
  800530:	83 ee 01             	sub    $0x1,%esi
  800533:	79 9c                	jns    8004d1 <vprintfmt+0x1f2>
  800535:	89 df                	mov    %ebx,%edi
  800537:	8b 75 08             	mov    0x8(%ebp),%esi
  80053a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053d:	eb 18                	jmp    800557 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	6a 20                	push   $0x20
  800545:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800547:	83 ef 01             	sub    $0x1,%edi
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb 08                	jmp    800557 <vprintfmt+0x278>
  80054f:	89 df                	mov    %ebx,%edi
  800551:	8b 75 08             	mov    0x8(%ebp),%esi
  800554:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800557:	85 ff                	test   %edi,%edi
  800559:	7f e4                	jg     80053f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055e:	e9 a2 fd ff ff       	jmp    800305 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800563:	83 fa 01             	cmp    $0x1,%edx
  800566:	7e 16                	jle    80057e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 08             	lea    0x8(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 50 04             	mov    0x4(%eax),%edx
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057c:	eb 32                	jmp    8005b0 <vprintfmt+0x2d1>
	else if (lflag)
  80057e:	85 d2                	test   %edx,%edx
  800580:	74 18                	je     80059a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 04             	lea    0x4(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	89 c1                	mov    %eax,%ecx
  800592:	c1 f9 1f             	sar    $0x1f,%ecx
  800595:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800598:	eb 16                	jmp    8005b0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a8:	89 c1                	mov    %eax,%ecx
  8005aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005bb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005bf:	79 74                	jns    800635 <vprintfmt+0x356>
				putch('-', putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	6a 2d                	push   $0x2d
  8005c7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005cf:	f7 d8                	neg    %eax
  8005d1:	83 d2 00             	adc    $0x0,%edx
  8005d4:	f7 da                	neg    %edx
  8005d6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005de:	eb 55                	jmp    800635 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e3:	e8 83 fc ff ff       	call   80026b <getuint>
			base = 10;
  8005e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ed:	eb 46                	jmp    800635 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f2:	e8 74 fc ff ff       	call   80026b <getuint>
			base = 8;
  8005f7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005fc:	eb 37                	jmp    800635 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 30                	push   $0x30
  800604:	ff d6                	call   *%esi
			putch('x', putdat);
  800606:	83 c4 08             	add    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 78                	push   $0x78
  80060c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800617:	8b 00                	mov    (%eax),%eax
  800619:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80061e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800621:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800626:	eb 0d                	jmp    800635 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800628:	8d 45 14             	lea    0x14(%ebp),%eax
  80062b:	e8 3b fc ff ff       	call   80026b <getuint>
			base = 16;
  800630:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800635:	83 ec 0c             	sub    $0xc,%esp
  800638:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063c:	57                   	push   %edi
  80063d:	ff 75 e0             	pushl  -0x20(%ebp)
  800640:	51                   	push   %ecx
  800641:	52                   	push   %edx
  800642:	50                   	push   %eax
  800643:	89 da                	mov    %ebx,%edx
  800645:	89 f0                	mov    %esi,%eax
  800647:	e8 70 fb ff ff       	call   8001bc <printnum>
			break;
  80064c:	83 c4 20             	add    $0x20,%esp
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800652:	e9 ae fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	51                   	push   %ecx
  80065c:	ff d6                	call   *%esi
			break;
  80065e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800664:	e9 9c fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	53                   	push   %ebx
  80066d:	6a 25                	push   $0x25
  80066f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	eb 03                	jmp    800679 <vprintfmt+0x39a>
  800676:	83 ef 01             	sub    $0x1,%edi
  800679:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80067d:	75 f7                	jne    800676 <vprintfmt+0x397>
  80067f:	e9 81 fc ff ff       	jmp    800305 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800684:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800687:	5b                   	pop    %ebx
  800688:	5e                   	pop    %esi
  800689:	5f                   	pop    %edi
  80068a:	5d                   	pop    %ebp
  80068b:	c3                   	ret    

0080068c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	83 ec 18             	sub    $0x18,%esp
  800692:	8b 45 08             	mov    0x8(%ebp),%eax
  800695:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800698:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	74 26                	je     8006d3 <vsnprintf+0x47>
  8006ad:	85 d2                	test   %edx,%edx
  8006af:	7e 22                	jle    8006d3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b1:	ff 75 14             	pushl  0x14(%ebp)
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	68 a5 02 80 00       	push   $0x8002a5
  8006c0:	e8 1a fc ff ff       	call   8002df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 05                	jmp    8006d8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d8:	c9                   	leave  
  8006d9:	c3                   	ret    

008006da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e3:	50                   	push   %eax
  8006e4:	ff 75 10             	pushl  0x10(%ebp)
  8006e7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ea:	ff 75 08             	pushl  0x8(%ebp)
  8006ed:	e8 9a ff ff ff       	call   80068c <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ff:	eb 03                	jmp    800704 <strlen+0x10>
		n++;
  800701:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800704:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800708:	75 f7                	jne    800701 <strlen+0xd>
		n++;
	return n;
}
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800712:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800715:	ba 00 00 00 00       	mov    $0x0,%edx
  80071a:	eb 03                	jmp    80071f <strnlen+0x13>
		n++;
  80071c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071f:	39 c2                	cmp    %eax,%edx
  800721:	74 08                	je     80072b <strnlen+0x1f>
  800723:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800727:	75 f3                	jne    80071c <strnlen+0x10>
  800729:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	53                   	push   %ebx
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800737:	89 c2                	mov    %eax,%edx
  800739:	83 c2 01             	add    $0x1,%edx
  80073c:	83 c1 01             	add    $0x1,%ecx
  80073f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800743:	88 5a ff             	mov    %bl,-0x1(%edx)
  800746:	84 db                	test   %bl,%bl
  800748:	75 ef                	jne    800739 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074a:	5b                   	pop    %ebx
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	53                   	push   %ebx
  800751:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800754:	53                   	push   %ebx
  800755:	e8 9a ff ff ff       	call   8006f4 <strlen>
  80075a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	01 d8                	add    %ebx,%eax
  800762:	50                   	push   %eax
  800763:	e8 c5 ff ff ff       	call   80072d <strcpy>
	return dst;
}
  800768:	89 d8                	mov    %ebx,%eax
  80076a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	56                   	push   %esi
  800773:	53                   	push   %ebx
  800774:	8b 75 08             	mov    0x8(%ebp),%esi
  800777:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077a:	89 f3                	mov    %esi,%ebx
  80077c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077f:	89 f2                	mov    %esi,%edx
  800781:	eb 0f                	jmp    800792 <strncpy+0x23>
		*dst++ = *src;
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	0f b6 01             	movzbl (%ecx),%eax
  800789:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078c:	80 39 01             	cmpb   $0x1,(%ecx)
  80078f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800792:	39 da                	cmp    %ebx,%edx
  800794:	75 ed                	jne    800783 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800796:	89 f0                	mov    %esi,%eax
  800798:	5b                   	pop    %ebx
  800799:	5e                   	pop    %esi
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007aa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 21                	je     8007d1 <strlcpy+0x35>
  8007b0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b4:	89 f2                	mov    %esi,%edx
  8007b6:	eb 09                	jmp    8007c1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b8:	83 c2 01             	add    $0x1,%edx
  8007bb:	83 c1 01             	add    $0x1,%ecx
  8007be:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c1:	39 c2                	cmp    %eax,%edx
  8007c3:	74 09                	je     8007ce <strlcpy+0x32>
  8007c5:	0f b6 19             	movzbl (%ecx),%ebx
  8007c8:	84 db                	test   %bl,%bl
  8007ca:	75 ec                	jne    8007b8 <strlcpy+0x1c>
  8007cc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ce:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d1:	29 f0                	sub    %esi,%eax
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5e                   	pop    %esi
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e0:	eb 06                	jmp    8007e8 <strcmp+0x11>
		p++, q++;
  8007e2:	83 c1 01             	add    $0x1,%ecx
  8007e5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e8:	0f b6 01             	movzbl (%ecx),%eax
  8007eb:	84 c0                	test   %al,%al
  8007ed:	74 04                	je     8007f3 <strcmp+0x1c>
  8007ef:	3a 02                	cmp    (%edx),%al
  8007f1:	74 ef                	je     8007e2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f3:	0f b6 c0             	movzbl %al,%eax
  8007f6:	0f b6 12             	movzbl (%edx),%edx
  8007f9:	29 d0                	sub    %edx,%eax
}
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	53                   	push   %ebx
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
  800807:	89 c3                	mov    %eax,%ebx
  800809:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080c:	eb 06                	jmp    800814 <strncmp+0x17>
		n--, p++, q++;
  80080e:	83 c0 01             	add    $0x1,%eax
  800811:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800814:	39 d8                	cmp    %ebx,%eax
  800816:	74 15                	je     80082d <strncmp+0x30>
  800818:	0f b6 08             	movzbl (%eax),%ecx
  80081b:	84 c9                	test   %cl,%cl
  80081d:	74 04                	je     800823 <strncmp+0x26>
  80081f:	3a 0a                	cmp    (%edx),%cl
  800821:	74 eb                	je     80080e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800823:	0f b6 00             	movzbl (%eax),%eax
  800826:	0f b6 12             	movzbl (%edx),%edx
  800829:	29 d0                	sub    %edx,%eax
  80082b:	eb 05                	jmp    800832 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800832:	5b                   	pop    %ebx
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083f:	eb 07                	jmp    800848 <strchr+0x13>
		if (*s == c)
  800841:	38 ca                	cmp    %cl,%dl
  800843:	74 0f                	je     800854 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800845:	83 c0 01             	add    $0x1,%eax
  800848:	0f b6 10             	movzbl (%eax),%edx
  80084b:	84 d2                	test   %dl,%dl
  80084d:	75 f2                	jne    800841 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800860:	eb 03                	jmp    800865 <strfind+0xf>
  800862:	83 c0 01             	add    $0x1,%eax
  800865:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 04                	je     800870 <strfind+0x1a>
  80086c:	84 d2                	test   %dl,%dl
  80086e:	75 f2                	jne    800862 <strfind+0xc>
			break;
	return (char *) s;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	57                   	push   %edi
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80087e:	85 c9                	test   %ecx,%ecx
  800880:	74 36                	je     8008b8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800882:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800888:	75 28                	jne    8008b2 <memset+0x40>
  80088a:	f6 c1 03             	test   $0x3,%cl
  80088d:	75 23                	jne    8008b2 <memset+0x40>
		c &= 0xFF;
  80088f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800893:	89 d3                	mov    %edx,%ebx
  800895:	c1 e3 08             	shl    $0x8,%ebx
  800898:	89 d6                	mov    %edx,%esi
  80089a:	c1 e6 18             	shl    $0x18,%esi
  80089d:	89 d0                	mov    %edx,%eax
  80089f:	c1 e0 10             	shl    $0x10,%eax
  8008a2:	09 f0                	or     %esi,%eax
  8008a4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008a6:	89 d8                	mov    %ebx,%eax
  8008a8:	09 d0                	or     %edx,%eax
  8008aa:	c1 e9 02             	shr    $0x2,%ecx
  8008ad:	fc                   	cld    
  8008ae:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b0:	eb 06                	jmp    8008b8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b5:	fc                   	cld    
  8008b6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b8:	89 f8                	mov    %edi,%eax
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5f                   	pop    %edi
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	57                   	push   %edi
  8008c3:	56                   	push   %esi
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008cd:	39 c6                	cmp    %eax,%esi
  8008cf:	73 35                	jae    800906 <memmove+0x47>
  8008d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d4:	39 d0                	cmp    %edx,%eax
  8008d6:	73 2e                	jae    800906 <memmove+0x47>
		s += n;
		d += n;
  8008d8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008db:	89 d6                	mov    %edx,%esi
  8008dd:	09 fe                	or     %edi,%esi
  8008df:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e5:	75 13                	jne    8008fa <memmove+0x3b>
  8008e7:	f6 c1 03             	test   $0x3,%cl
  8008ea:	75 0e                	jne    8008fa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008ec:	83 ef 04             	sub    $0x4,%edi
  8008ef:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f2:	c1 e9 02             	shr    $0x2,%ecx
  8008f5:	fd                   	std    
  8008f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f8:	eb 09                	jmp    800903 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fa:	83 ef 01             	sub    $0x1,%edi
  8008fd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800900:	fd                   	std    
  800901:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800903:	fc                   	cld    
  800904:	eb 1d                	jmp    800923 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800906:	89 f2                	mov    %esi,%edx
  800908:	09 c2                	or     %eax,%edx
  80090a:	f6 c2 03             	test   $0x3,%dl
  80090d:	75 0f                	jne    80091e <memmove+0x5f>
  80090f:	f6 c1 03             	test   $0x3,%cl
  800912:	75 0a                	jne    80091e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800914:	c1 e9 02             	shr    $0x2,%ecx
  800917:	89 c7                	mov    %eax,%edi
  800919:	fc                   	cld    
  80091a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091c:	eb 05                	jmp    800923 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091e:	89 c7                	mov    %eax,%edi
  800920:	fc                   	cld    
  800921:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800923:	5e                   	pop    %esi
  800924:	5f                   	pop    %edi
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80092a:	ff 75 10             	pushl  0x10(%ebp)
  80092d:	ff 75 0c             	pushl  0xc(%ebp)
  800930:	ff 75 08             	pushl  0x8(%ebp)
  800933:	e8 87 ff ff ff       	call   8008bf <memmove>
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
  800945:	89 c6                	mov    %eax,%esi
  800947:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094a:	eb 1a                	jmp    800966 <memcmp+0x2c>
		if (*s1 != *s2)
  80094c:	0f b6 08             	movzbl (%eax),%ecx
  80094f:	0f b6 1a             	movzbl (%edx),%ebx
  800952:	38 d9                	cmp    %bl,%cl
  800954:	74 0a                	je     800960 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800956:	0f b6 c1             	movzbl %cl,%eax
  800959:	0f b6 db             	movzbl %bl,%ebx
  80095c:	29 d8                	sub    %ebx,%eax
  80095e:	eb 0f                	jmp    80096f <memcmp+0x35>
		s1++, s2++;
  800960:	83 c0 01             	add    $0x1,%eax
  800963:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800966:	39 f0                	cmp    %esi,%eax
  800968:	75 e2                	jne    80094c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	53                   	push   %ebx
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80097a:	89 c1                	mov    %eax,%ecx
  80097c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80097f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800983:	eb 0a                	jmp    80098f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	39 da                	cmp    %ebx,%edx
  80098a:	74 07                	je     800993 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	39 c8                	cmp    %ecx,%eax
  800991:	72 f2                	jb     800985 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800993:	5b                   	pop    %ebx
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	57                   	push   %edi
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a2:	eb 03                	jmp    8009a7 <strtol+0x11>
		s++;
  8009a4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a7:	0f b6 01             	movzbl (%ecx),%eax
  8009aa:	3c 20                	cmp    $0x20,%al
  8009ac:	74 f6                	je     8009a4 <strtol+0xe>
  8009ae:	3c 09                	cmp    $0x9,%al
  8009b0:	74 f2                	je     8009a4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b2:	3c 2b                	cmp    $0x2b,%al
  8009b4:	75 0a                	jne    8009c0 <strtol+0x2a>
		s++;
  8009b6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009be:	eb 11                	jmp    8009d1 <strtol+0x3b>
  8009c0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c5:	3c 2d                	cmp    $0x2d,%al
  8009c7:	75 08                	jne    8009d1 <strtol+0x3b>
		s++, neg = 1;
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d7:	75 15                	jne    8009ee <strtol+0x58>
  8009d9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009dc:	75 10                	jne    8009ee <strtol+0x58>
  8009de:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e2:	75 7c                	jne    800a60 <strtol+0xca>
		s += 2, base = 16;
  8009e4:	83 c1 02             	add    $0x2,%ecx
  8009e7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ec:	eb 16                	jmp    800a04 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ee:	85 db                	test   %ebx,%ebx
  8009f0:	75 12                	jne    800a04 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fa:	75 08                	jne    800a04 <strtol+0x6e>
		s++, base = 8;
  8009fc:	83 c1 01             	add    $0x1,%ecx
  8009ff:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
  800a09:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0c:	0f b6 11             	movzbl (%ecx),%edx
  800a0f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a12:	89 f3                	mov    %esi,%ebx
  800a14:	80 fb 09             	cmp    $0x9,%bl
  800a17:	77 08                	ja     800a21 <strtol+0x8b>
			dig = *s - '0';
  800a19:	0f be d2             	movsbl %dl,%edx
  800a1c:	83 ea 30             	sub    $0x30,%edx
  800a1f:	eb 22                	jmp    800a43 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a21:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a24:	89 f3                	mov    %esi,%ebx
  800a26:	80 fb 19             	cmp    $0x19,%bl
  800a29:	77 08                	ja     800a33 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a2b:	0f be d2             	movsbl %dl,%edx
  800a2e:	83 ea 57             	sub    $0x57,%edx
  800a31:	eb 10                	jmp    800a43 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a33:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a36:	89 f3                	mov    %esi,%ebx
  800a38:	80 fb 19             	cmp    $0x19,%bl
  800a3b:	77 16                	ja     800a53 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a3d:	0f be d2             	movsbl %dl,%edx
  800a40:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a43:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a46:	7d 0b                	jge    800a53 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a4f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a51:	eb b9                	jmp    800a0c <strtol+0x76>

	if (endptr)
  800a53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a57:	74 0d                	je     800a66 <strtol+0xd0>
		*endptr = (char *) s;
  800a59:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5c:	89 0e                	mov    %ecx,(%esi)
  800a5e:	eb 06                	jmp    800a66 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a60:	85 db                	test   %ebx,%ebx
  800a62:	74 98                	je     8009fc <strtol+0x66>
  800a64:	eb 9e                	jmp    800a04 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a66:	89 c2                	mov    %eax,%edx
  800a68:	f7 da                	neg    %edx
  800a6a:	85 ff                	test   %edi,%edi
  800a6c:	0f 45 c2             	cmovne %edx,%eax
}
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	89 c3                	mov    %eax,%ebx
  800a87:	89 c7                	mov    %eax,%edi
  800a89:	89 c6                	mov    %eax,%esi
  800a8b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa2:	89 d1                	mov    %edx,%ecx
  800aa4:	89 d3                	mov    %edx,%ebx
  800aa6:	89 d7                	mov    %edx,%edi
  800aa8:	89 d6                	mov    %edx,%esi
  800aaa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	89 cb                	mov    %ecx,%ebx
  800ac9:	89 cf                	mov    %ecx,%edi
  800acb:	89 ce                	mov    %ecx,%esi
  800acd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	7e 17                	jle    800aea <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad3:	83 ec 0c             	sub    $0xc,%esp
  800ad6:	50                   	push   %eax
  800ad7:	6a 03                	push   $0x3
  800ad9:	68 5f 25 80 00       	push   $0x80255f
  800ade:	6a 23                	push   $0x23
  800ae0:	68 7c 25 80 00       	push   $0x80257c
  800ae5:	e8 52 12 00 00       	call   801d3c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 02 00 00 00       	mov    $0x2,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_yield>:

void
sys_yield(void)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b17:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b21:	89 d1                	mov    %edx,%ecx
  800b23:	89 d3                	mov    %edx,%ebx
  800b25:	89 d7                	mov    %edx,%edi
  800b27:	89 d6                	mov    %edx,%esi
  800b29:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	be 00 00 00 00       	mov    $0x0,%esi
  800b3e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4c:	89 f7                	mov    %esi,%edi
  800b4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b50:	85 c0                	test   %eax,%eax
  800b52:	7e 17                	jle    800b6b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	50                   	push   %eax
  800b58:	6a 04                	push   $0x4
  800b5a:	68 5f 25 80 00       	push   $0x80255f
  800b5f:	6a 23                	push   $0x23
  800b61:	68 7c 25 80 00       	push   $0x80257c
  800b66:	e8 d1 11 00 00       	call   801d3c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b8d:	8b 75 18             	mov    0x18(%ebp),%esi
  800b90:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b92:	85 c0                	test   %eax,%eax
  800b94:	7e 17                	jle    800bad <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	50                   	push   %eax
  800b9a:	6a 05                	push   $0x5
  800b9c:	68 5f 25 80 00       	push   $0x80255f
  800ba1:	6a 23                	push   $0x23
  800ba3:	68 7c 25 80 00       	push   $0x80257c
  800ba8:	e8 8f 11 00 00       	call   801d3c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc3:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 df                	mov    %ebx,%edi
  800bd0:	89 de                	mov    %ebx,%esi
  800bd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	7e 17                	jle    800bef <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	50                   	push   %eax
  800bdc:	6a 06                	push   $0x6
  800bde:	68 5f 25 80 00       	push   $0x80255f
  800be3:	6a 23                	push   $0x23
  800be5:	68 7c 25 80 00       	push   $0x80257c
  800bea:	e8 4d 11 00 00       	call   801d3c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c05:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 df                	mov    %ebx,%edi
  800c12:	89 de                	mov    %ebx,%esi
  800c14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 17                	jle    800c31 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 08                	push   $0x8
  800c20:	68 5f 25 80 00       	push   $0x80255f
  800c25:	6a 23                	push   $0x23
  800c27:	68 7c 25 80 00       	push   $0x80257c
  800c2c:	e8 0b 11 00 00       	call   801d3c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c47:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	89 df                	mov    %ebx,%edi
  800c54:	89 de                	mov    %ebx,%esi
  800c56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 09                	push   $0x9
  800c62:	68 5f 25 80 00       	push   $0x80255f
  800c67:	6a 23                	push   $0x23
  800c69:	68 7c 25 80 00       	push   $0x80257c
  800c6e:	e8 c9 10 00 00       	call   801d3c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	89 df                	mov    %ebx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 17                	jle    800cb5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 0a                	push   $0xa
  800ca4:	68 5f 25 80 00       	push   $0x80255f
  800ca9:	6a 23                	push   $0x23
  800cab:	68 7c 25 80 00       	push   $0x80257c
  800cb0:	e8 87 10 00 00       	call   801d3c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	be 00 00 00 00       	mov    $0x0,%esi
  800cc8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cee:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 cb                	mov    %ecx,%ebx
  800cf8:	89 cf                	mov    %ecx,%edi
  800cfa:	89 ce                	mov    %ecx,%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 0d                	push   $0xd
  800d08:	68 5f 25 80 00       	push   $0x80255f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 7c 25 80 00       	push   $0x80257c
  800d14:	e8 23 10 00 00       	call   801d3c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	53                   	push   %ebx
  800d25:	83 ec 04             	sub    $0x4,%esp
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  800d2b:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  800d2d:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  800d30:	89 da                	mov    %ebx,%edx
  800d32:	c1 ea 0c             	shr    $0xc,%edx
  800d35:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  800d3c:	a8 02                	test   $0x2,%al
  800d3e:	75 12                	jne    800d52 <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  800d40:	50                   	push   %eax
  800d41:	68 8c 25 80 00       	push   $0x80258c
  800d46:	6a 21                	push   $0x21
  800d48:	68 ad 25 80 00       	push   $0x8025ad
  800d4d:	e8 ea 0f 00 00       	call   801d3c <_panic>
	   } else if (!(pte & PTE_COW)) {
  800d52:	f6 c6 08             	test   $0x8,%dh
  800d55:	75 14                	jne    800d6b <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  800d57:	83 ec 04             	sub    $0x4,%esp
  800d5a:	68 b8 25 80 00       	push   $0x8025b8
  800d5f:	6a 23                	push   $0x23
  800d61:	68 ad 25 80 00       	push   $0x8025ad
  800d66:	e8 d1 0f 00 00       	call   801d3c <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  800d6b:	83 ec 04             	sub    $0x4,%esp
  800d6e:	6a 07                	push   $0x7
  800d70:	68 00 00 40 00       	push   $0x400000
  800d75:	6a 00                	push   $0x0
  800d77:	e8 b4 fd ff ff       	call   800b30 <sys_page_alloc>
  800d7c:	83 c4 10             	add    $0x10,%esp
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	79 12                	jns    800d95 <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  800d83:	50                   	push   %eax
  800d84:	68 d5 25 80 00       	push   $0x8025d5
  800d89:	6a 2e                	push   $0x2e
  800d8b:	68 ad 25 80 00       	push   $0x8025ad
  800d90:	e8 a7 0f 00 00       	call   801d3c <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800d95:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800d9b:	83 ec 04             	sub    $0x4,%esp
  800d9e:	68 00 10 00 00       	push   $0x1000
  800da3:	53                   	push   %ebx
  800da4:	68 00 00 40 00       	push   $0x400000
  800da9:	e8 11 fb ff ff       	call   8008bf <memmove>
	   if ((r = sys_page_map(0,
  800dae:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800db5:	53                   	push   %ebx
  800db6:	6a 00                	push   $0x0
  800db8:	68 00 00 40 00       	push   $0x400000
  800dbd:	6a 00                	push   $0x0
  800dbf:	e8 af fd ff ff       	call   800b73 <sys_page_map>
  800dc4:	83 c4 20             	add    $0x20,%esp
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	79 12                	jns    800ddd <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  800dcb:	50                   	push   %eax
  800dcc:	68 e8 25 80 00       	push   $0x8025e8
  800dd1:	6a 36                	push   $0x36
  800dd3:	68 ad 25 80 00       	push   $0x8025ad
  800dd8:	e8 5f 0f 00 00       	call   801d3c <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  800ddd:	83 ec 08             	sub    $0x8,%esp
  800de0:	68 00 00 40 00       	push   $0x400000
  800de5:	6a 00                	push   $0x0
  800de7:	e8 c9 fd ff ff       	call   800bb5 <sys_page_unmap>
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	79 12                	jns    800e05 <pgfault+0xe4>
			 panic("unmap %e", r);
  800df3:	50                   	push   %eax
  800df4:	68 f8 25 80 00       	push   $0x8025f8
  800df9:	6a 39                	push   $0x39
  800dfb:	68 ad 25 80 00       	push   $0x8025ad
  800e00:	e8 37 0f 00 00       	call   801d3c <_panic>
	   }
}
  800e05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e08:	c9                   	leave  
  800e09:	c3                   	ret    

00800e0a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  800e13:	68 21 0d 80 00       	push   $0x800d21
  800e18:	e8 65 0f 00 00       	call   801d82 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e1d:	b8 07 00 00 00       	mov    $0x7,%eax
  800e22:	cd 30                	int    $0x30
  800e24:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e27:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  800e2a:	83 c4 10             	add    $0x10,%esp
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	79 15                	jns    800e46 <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  800e31:	50                   	push   %eax
  800e32:	68 01 26 80 00       	push   $0x802601
  800e37:	68 81 00 00 00       	push   $0x81
  800e3c:	68 ad 25 80 00       	push   $0x8025ad
  800e41:	e8 f6 0e 00 00       	call   801d3c <_panic>
  800e46:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800e4d:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  800e51:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e55:	75 1c                	jne    800e73 <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  800e57:	e8 96 fc ff ff       	call   800af2 <sys_getenvid>
  800e5c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e61:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e64:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e69:	a3 04 40 80 00       	mov    %eax,0x804004
			 return envid;
  800e6e:	e9 71 01 00 00       	jmp    800fe4 <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  800e73:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800e76:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800e7d:	a8 01                	test   $0x1,%al
  800e7f:	0f 84 18 01 00 00    	je     800f9d <fork+0x193>
  800e85:	89 fb                	mov    %edi,%ebx
  800e87:	c1 e3 0a             	shl    $0xa,%ebx
  800e8a:	c1 e7 16             	shl    $0x16,%edi
  800e8d:	be 00 00 00 00       	mov    $0x0,%esi
  800e92:	e9 f4 00 00 00       	jmp    800f8b <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  800e97:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800e9d:	0f 84 dc 00 00 00    	je     800f7f <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  800ea3:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800ea9:	0f 87 cc 00 00 00    	ja     800f7b <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  800eaf:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800eb6:	a8 01                	test   $0x1,%al
  800eb8:	0f 84 c1 00 00 00    	je     800f7f <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  800ebe:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  800ec5:	a9 02 08 00 00       	test   $0x802,%eax
  800eca:	74 05                	je     800ed1 <fork+0xc7>
  800ecc:	f6 c4 04             	test   $0x4,%ah
  800ecf:	74 3a                	je     800f0b <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  800ed1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800ed7:	8b 52 48             	mov    0x48(%edx),%edx
  800eda:	83 ec 0c             	sub    $0xc,%esp
  800edd:	25 07 0e 00 00       	and    $0xe07,%eax
  800ee2:	50                   	push   %eax
  800ee3:	57                   	push   %edi
  800ee4:	ff 75 dc             	pushl  -0x24(%ebp)
  800ee7:	57                   	push   %edi
  800ee8:	52                   	push   %edx
  800ee9:	e8 85 fc ff ff       	call   800b73 <sys_page_map>
  800eee:	83 c4 20             	add    $0x20,%esp
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	0f 89 86 00 00 00    	jns    800f7f <fork+0x175>
				    panic("sys_page_map: %e", r);
  800ef9:	50                   	push   %eax
  800efa:	68 11 26 80 00       	push   $0x802611
  800eff:	6a 52                	push   $0x52
  800f01:	68 ad 25 80 00       	push   $0x8025ad
  800f06:	e8 31 0e 00 00       	call   801d3c <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  800f0b:	25 05 06 00 00       	and    $0x605,%eax
  800f10:	80 cc 08             	or     $0x8,%ah
  800f13:	89 c1                	mov    %eax,%ecx
  800f15:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f18:	a1 04 40 80 00       	mov    0x804004,%eax
  800f1d:	8b 40 48             	mov    0x48(%eax),%eax
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	51                   	push   %ecx
  800f24:	57                   	push   %edi
  800f25:	ff 75 dc             	pushl  -0x24(%ebp)
  800f28:	57                   	push   %edi
  800f29:	50                   	push   %eax
  800f2a:	e8 44 fc ff ff       	call   800b73 <sys_page_map>
  800f2f:	83 c4 20             	add    $0x20,%esp
  800f32:	85 c0                	test   %eax,%eax
  800f34:	79 12                	jns    800f48 <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  800f36:	50                   	push   %eax
  800f37:	68 11 26 80 00       	push   $0x802611
  800f3c:	6a 5d                	push   $0x5d
  800f3e:	68 ad 25 80 00       	push   $0x8025ad
  800f43:	e8 f4 0d 00 00       	call   801d3c <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  800f48:	a1 04 40 80 00       	mov    0x804004,%eax
  800f4d:	8b 50 48             	mov    0x48(%eax),%edx
  800f50:	8b 40 48             	mov    0x48(%eax),%eax
  800f53:	83 ec 0c             	sub    $0xc,%esp
  800f56:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f59:	57                   	push   %edi
  800f5a:	52                   	push   %edx
  800f5b:	57                   	push   %edi
  800f5c:	50                   	push   %eax
  800f5d:	e8 11 fc ff ff       	call   800b73 <sys_page_map>
  800f62:	83 c4 20             	add    $0x20,%esp
  800f65:	85 c0                	test   %eax,%eax
  800f67:	79 16                	jns    800f7f <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  800f69:	50                   	push   %eax
  800f6a:	68 11 26 80 00       	push   $0x802611
  800f6f:	6a 63                	push   $0x63
  800f71:	68 ad 25 80 00       	push   $0x8025ad
  800f76:	e8 c1 0d 00 00       	call   801d3c <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  800f7b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  800f7f:	83 c6 01             	add    $0x1,%esi
  800f82:	83 c3 01             	add    $0x1,%ebx
  800f85:	81 c7 00 10 00 00    	add    $0x1000,%edi
  800f8b:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  800f91:	7f 0a                	jg     800f9d <fork+0x193>
  800f93:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f97:	0f 85 fa fe ff ff    	jne    800e97 <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  800f9d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  800fa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fa4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800fa9:	7f 0a                	jg     800fb5 <fork+0x1ab>
  800fab:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800faf:	0f 85 be fe ff ff    	jne    800e73 <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fb5:	83 ec 08             	sub    $0x8,%esp
  800fb8:	68 db 1d 80 00       	push   $0x801ddb
  800fbd:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800fc0:	56                   	push   %esi
  800fc1:	e8 b5 fc ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  800fc6:	83 c4 0c             	add    $0xc,%esp
  800fc9:	6a 06                	push   $0x6
  800fcb:	68 00 f0 bf ee       	push   $0xeebff000
  800fd0:	56                   	push   %esi
  800fd1:	e8 5a fb ff ff       	call   800b30 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  800fd6:	83 c4 08             	add    $0x8,%esp
  800fd9:	6a 02                	push   $0x2
  800fdb:	56                   	push   %esi
  800fdc:	e8 16 fc ff ff       	call   800bf7 <sys_env_set_status>

	   return envid;
  800fe1:	83 c4 10             	add    $0x10,%esp
}
  800fe4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fe7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fea:	5b                   	pop    %ebx
  800feb:	5e                   	pop    %esi
  800fec:	5f                   	pop    %edi
  800fed:	5d                   	pop    %ebp
  800fee:	c3                   	ret    

00800fef <sfork>:
// Challenge!
	   int
sfork(void)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  800ff5:	68 22 26 80 00       	push   $0x802622
  800ffa:	68 a7 00 00 00       	push   $0xa7
  800fff:	68 ad 25 80 00       	push   $0x8025ad
  801004:	e8 33 0d 00 00       	call   801d3c <_panic>

00801009 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80100c:	8b 45 08             	mov    0x8(%ebp),%eax
  80100f:	05 00 00 00 30       	add    $0x30000000,%eax
  801014:	c1 e8 0c             	shr    $0xc,%eax
}
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80101c:	8b 45 08             	mov    0x8(%ebp),%eax
  80101f:	05 00 00 00 30       	add    $0x30000000,%eax
  801024:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801029:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801036:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80103b:	89 c2                	mov    %eax,%edx
  80103d:	c1 ea 16             	shr    $0x16,%edx
  801040:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801047:	f6 c2 01             	test   $0x1,%dl
  80104a:	74 11                	je     80105d <fd_alloc+0x2d>
  80104c:	89 c2                	mov    %eax,%edx
  80104e:	c1 ea 0c             	shr    $0xc,%edx
  801051:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801058:	f6 c2 01             	test   $0x1,%dl
  80105b:	75 09                	jne    801066 <fd_alloc+0x36>
			*fd_store = fd;
  80105d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80105f:	b8 00 00 00 00       	mov    $0x0,%eax
  801064:	eb 17                	jmp    80107d <fd_alloc+0x4d>
  801066:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80106b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801070:	75 c9                	jne    80103b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801072:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801078:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80107d:	5d                   	pop    %ebp
  80107e:	c3                   	ret    

0080107f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801085:	83 f8 1f             	cmp    $0x1f,%eax
  801088:	77 36                	ja     8010c0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80108a:	c1 e0 0c             	shl    $0xc,%eax
  80108d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801092:	89 c2                	mov    %eax,%edx
  801094:	c1 ea 16             	shr    $0x16,%edx
  801097:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80109e:	f6 c2 01             	test   $0x1,%dl
  8010a1:	74 24                	je     8010c7 <fd_lookup+0x48>
  8010a3:	89 c2                	mov    %eax,%edx
  8010a5:	c1 ea 0c             	shr    $0xc,%edx
  8010a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010af:	f6 c2 01             	test   $0x1,%dl
  8010b2:	74 1a                	je     8010ce <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b7:	89 02                	mov    %eax,(%edx)
	return 0;
  8010b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010be:	eb 13                	jmp    8010d3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010c5:	eb 0c                	jmp    8010d3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010cc:	eb 05                	jmp    8010d3 <fd_lookup+0x54>
  8010ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	83 ec 08             	sub    $0x8,%esp
  8010db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010de:	ba b4 26 80 00       	mov    $0x8026b4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010e3:	eb 13                	jmp    8010f8 <dev_lookup+0x23>
  8010e5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010e8:	39 08                	cmp    %ecx,(%eax)
  8010ea:	75 0c                	jne    8010f8 <dev_lookup+0x23>
			*dev = devtab[i];
  8010ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ef:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f6:	eb 2e                	jmp    801126 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010f8:	8b 02                	mov    (%edx),%eax
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	75 e7                	jne    8010e5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801103:	8b 40 48             	mov    0x48(%eax),%eax
  801106:	83 ec 04             	sub    $0x4,%esp
  801109:	51                   	push   %ecx
  80110a:	50                   	push   %eax
  80110b:	68 38 26 80 00       	push   $0x802638
  801110:	e8 93 f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  801115:	8b 45 0c             	mov    0xc(%ebp),%eax
  801118:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801126:	c9                   	leave  
  801127:	c3                   	ret    

00801128 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	56                   	push   %esi
  80112c:	53                   	push   %ebx
  80112d:	83 ec 10             	sub    $0x10,%esp
  801130:	8b 75 08             	mov    0x8(%ebp),%esi
  801133:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801136:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801139:	50                   	push   %eax
  80113a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801140:	c1 e8 0c             	shr    $0xc,%eax
  801143:	50                   	push   %eax
  801144:	e8 36 ff ff ff       	call   80107f <fd_lookup>
  801149:	83 c4 08             	add    $0x8,%esp
  80114c:	85 c0                	test   %eax,%eax
  80114e:	78 05                	js     801155 <fd_close+0x2d>
	    || fd != fd2)
  801150:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801153:	74 0c                	je     801161 <fd_close+0x39>
		return (must_exist ? r : 0);
  801155:	84 db                	test   %bl,%bl
  801157:	ba 00 00 00 00       	mov    $0x0,%edx
  80115c:	0f 44 c2             	cmove  %edx,%eax
  80115f:	eb 41                	jmp    8011a2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801161:	83 ec 08             	sub    $0x8,%esp
  801164:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801167:	50                   	push   %eax
  801168:	ff 36                	pushl  (%esi)
  80116a:	e8 66 ff ff ff       	call   8010d5 <dev_lookup>
  80116f:	89 c3                	mov    %eax,%ebx
  801171:	83 c4 10             	add    $0x10,%esp
  801174:	85 c0                	test   %eax,%eax
  801176:	78 1a                	js     801192 <fd_close+0x6a>
		if (dev->dev_close)
  801178:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80117e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801183:	85 c0                	test   %eax,%eax
  801185:	74 0b                	je     801192 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801187:	83 ec 0c             	sub    $0xc,%esp
  80118a:	56                   	push   %esi
  80118b:	ff d0                	call   *%eax
  80118d:	89 c3                	mov    %eax,%ebx
  80118f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801192:	83 ec 08             	sub    $0x8,%esp
  801195:	56                   	push   %esi
  801196:	6a 00                	push   $0x0
  801198:	e8 18 fa ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  80119d:	83 c4 10             	add    $0x10,%esp
  8011a0:	89 d8                	mov    %ebx,%eax
}
  8011a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011a5:	5b                   	pop    %ebx
  8011a6:	5e                   	pop    %esi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	ff 75 08             	pushl  0x8(%ebp)
  8011b6:	e8 c4 fe ff ff       	call   80107f <fd_lookup>
  8011bb:	83 c4 08             	add    $0x8,%esp
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	78 10                	js     8011d2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011c2:	83 ec 08             	sub    $0x8,%esp
  8011c5:	6a 01                	push   $0x1
  8011c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ca:	e8 59 ff ff ff       	call   801128 <fd_close>
  8011cf:	83 c4 10             	add    $0x10,%esp
}
  8011d2:	c9                   	leave  
  8011d3:	c3                   	ret    

008011d4 <close_all>:

void
close_all(void)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	53                   	push   %ebx
  8011d8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011db:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011e0:	83 ec 0c             	sub    $0xc,%esp
  8011e3:	53                   	push   %ebx
  8011e4:	e8 c0 ff ff ff       	call   8011a9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011e9:	83 c3 01             	add    $0x1,%ebx
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	83 fb 20             	cmp    $0x20,%ebx
  8011f2:	75 ec                	jne    8011e0 <close_all+0xc>
		close(i);
}
  8011f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f7:	c9                   	leave  
  8011f8:	c3                   	ret    

008011f9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	57                   	push   %edi
  8011fd:	56                   	push   %esi
  8011fe:	53                   	push   %ebx
  8011ff:	83 ec 2c             	sub    $0x2c,%esp
  801202:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801205:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801208:	50                   	push   %eax
  801209:	ff 75 08             	pushl  0x8(%ebp)
  80120c:	e8 6e fe ff ff       	call   80107f <fd_lookup>
  801211:	83 c4 08             	add    $0x8,%esp
  801214:	85 c0                	test   %eax,%eax
  801216:	0f 88 c1 00 00 00    	js     8012dd <dup+0xe4>
		return r;
	close(newfdnum);
  80121c:	83 ec 0c             	sub    $0xc,%esp
  80121f:	56                   	push   %esi
  801220:	e8 84 ff ff ff       	call   8011a9 <close>

	newfd = INDEX2FD(newfdnum);
  801225:	89 f3                	mov    %esi,%ebx
  801227:	c1 e3 0c             	shl    $0xc,%ebx
  80122a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801230:	83 c4 04             	add    $0x4,%esp
  801233:	ff 75 e4             	pushl  -0x1c(%ebp)
  801236:	e8 de fd ff ff       	call   801019 <fd2data>
  80123b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80123d:	89 1c 24             	mov    %ebx,(%esp)
  801240:	e8 d4 fd ff ff       	call   801019 <fd2data>
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80124b:	89 f8                	mov    %edi,%eax
  80124d:	c1 e8 16             	shr    $0x16,%eax
  801250:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801257:	a8 01                	test   $0x1,%al
  801259:	74 37                	je     801292 <dup+0x99>
  80125b:	89 f8                	mov    %edi,%eax
  80125d:	c1 e8 0c             	shr    $0xc,%eax
  801260:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801267:	f6 c2 01             	test   $0x1,%dl
  80126a:	74 26                	je     801292 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80126c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801273:	83 ec 0c             	sub    $0xc,%esp
  801276:	25 07 0e 00 00       	and    $0xe07,%eax
  80127b:	50                   	push   %eax
  80127c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80127f:	6a 00                	push   $0x0
  801281:	57                   	push   %edi
  801282:	6a 00                	push   $0x0
  801284:	e8 ea f8 ff ff       	call   800b73 <sys_page_map>
  801289:	89 c7                	mov    %eax,%edi
  80128b:	83 c4 20             	add    $0x20,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 2e                	js     8012c0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801292:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801295:	89 d0                	mov    %edx,%eax
  801297:	c1 e8 0c             	shr    $0xc,%eax
  80129a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012a1:	83 ec 0c             	sub    $0xc,%esp
  8012a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8012a9:	50                   	push   %eax
  8012aa:	53                   	push   %ebx
  8012ab:	6a 00                	push   $0x0
  8012ad:	52                   	push   %edx
  8012ae:	6a 00                	push   $0x0
  8012b0:	e8 be f8 ff ff       	call   800b73 <sys_page_map>
  8012b5:	89 c7                	mov    %eax,%edi
  8012b7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012ba:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012bc:	85 ff                	test   %edi,%edi
  8012be:	79 1d                	jns    8012dd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	53                   	push   %ebx
  8012c4:	6a 00                	push   $0x0
  8012c6:	e8 ea f8 ff ff       	call   800bb5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012cb:	83 c4 08             	add    $0x8,%esp
  8012ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012d1:	6a 00                	push   $0x0
  8012d3:	e8 dd f8 ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	89 f8                	mov    %edi,%eax
}
  8012dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e0:	5b                   	pop    %ebx
  8012e1:	5e                   	pop    %esi
  8012e2:	5f                   	pop    %edi
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	53                   	push   %ebx
  8012e9:	83 ec 14             	sub    $0x14,%esp
  8012ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	53                   	push   %ebx
  8012f4:	e8 86 fd ff ff       	call   80107f <fd_lookup>
  8012f9:	83 c4 08             	add    $0x8,%esp
  8012fc:	89 c2                	mov    %eax,%edx
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 6d                	js     80136f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801302:	83 ec 08             	sub    $0x8,%esp
  801305:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801308:	50                   	push   %eax
  801309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130c:	ff 30                	pushl  (%eax)
  80130e:	e8 c2 fd ff ff       	call   8010d5 <dev_lookup>
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 4c                	js     801366 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80131a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80131d:	8b 42 08             	mov    0x8(%edx),%eax
  801320:	83 e0 03             	and    $0x3,%eax
  801323:	83 f8 01             	cmp    $0x1,%eax
  801326:	75 21                	jne    801349 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801328:	a1 04 40 80 00       	mov    0x804004,%eax
  80132d:	8b 40 48             	mov    0x48(%eax),%eax
  801330:	83 ec 04             	sub    $0x4,%esp
  801333:	53                   	push   %ebx
  801334:	50                   	push   %eax
  801335:	68 79 26 80 00       	push   $0x802679
  80133a:	e8 69 ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801347:	eb 26                	jmp    80136f <read+0x8a>
	}
	if (!dev->dev_read)
  801349:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134c:	8b 40 08             	mov    0x8(%eax),%eax
  80134f:	85 c0                	test   %eax,%eax
  801351:	74 17                	je     80136a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801353:	83 ec 04             	sub    $0x4,%esp
  801356:	ff 75 10             	pushl  0x10(%ebp)
  801359:	ff 75 0c             	pushl  0xc(%ebp)
  80135c:	52                   	push   %edx
  80135d:	ff d0                	call   *%eax
  80135f:	89 c2                	mov    %eax,%edx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	eb 09                	jmp    80136f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801366:	89 c2                	mov    %eax,%edx
  801368:	eb 05                	jmp    80136f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80136a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80136f:	89 d0                	mov    %edx,%eax
  801371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	57                   	push   %edi
  80137a:	56                   	push   %esi
  80137b:	53                   	push   %ebx
  80137c:	83 ec 0c             	sub    $0xc,%esp
  80137f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801382:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801385:	bb 00 00 00 00       	mov    $0x0,%ebx
  80138a:	eb 21                	jmp    8013ad <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80138c:	83 ec 04             	sub    $0x4,%esp
  80138f:	89 f0                	mov    %esi,%eax
  801391:	29 d8                	sub    %ebx,%eax
  801393:	50                   	push   %eax
  801394:	89 d8                	mov    %ebx,%eax
  801396:	03 45 0c             	add    0xc(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	57                   	push   %edi
  80139b:	e8 45 ff ff ff       	call   8012e5 <read>
		if (m < 0)
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 10                	js     8013b7 <readn+0x41>
			return m;
		if (m == 0)
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	74 0a                	je     8013b5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ab:	01 c3                	add    %eax,%ebx
  8013ad:	39 f3                	cmp    %esi,%ebx
  8013af:	72 db                	jb     80138c <readn+0x16>
  8013b1:	89 d8                	mov    %ebx,%eax
  8013b3:	eb 02                	jmp    8013b7 <readn+0x41>
  8013b5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ba:	5b                   	pop    %ebx
  8013bb:	5e                   	pop    %esi
  8013bc:	5f                   	pop    %edi
  8013bd:	5d                   	pop    %ebp
  8013be:	c3                   	ret    

008013bf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	53                   	push   %ebx
  8013c3:	83 ec 14             	sub    $0x14,%esp
  8013c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cc:	50                   	push   %eax
  8013cd:	53                   	push   %ebx
  8013ce:	e8 ac fc ff ff       	call   80107f <fd_lookup>
  8013d3:	83 c4 08             	add    $0x8,%esp
  8013d6:	89 c2                	mov    %eax,%edx
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 68                	js     801444 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e6:	ff 30                	pushl  (%eax)
  8013e8:	e8 e8 fc ff ff       	call   8010d5 <dev_lookup>
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	78 47                	js     80143b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013fb:	75 21                	jne    80141e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013fd:	a1 04 40 80 00       	mov    0x804004,%eax
  801402:	8b 40 48             	mov    0x48(%eax),%eax
  801405:	83 ec 04             	sub    $0x4,%esp
  801408:	53                   	push   %ebx
  801409:	50                   	push   %eax
  80140a:	68 95 26 80 00       	push   $0x802695
  80140f:	e8 94 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80141c:	eb 26                	jmp    801444 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80141e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801421:	8b 52 0c             	mov    0xc(%edx),%edx
  801424:	85 d2                	test   %edx,%edx
  801426:	74 17                	je     80143f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801428:	83 ec 04             	sub    $0x4,%esp
  80142b:	ff 75 10             	pushl  0x10(%ebp)
  80142e:	ff 75 0c             	pushl  0xc(%ebp)
  801431:	50                   	push   %eax
  801432:	ff d2                	call   *%edx
  801434:	89 c2                	mov    %eax,%edx
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	eb 09                	jmp    801444 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143b:	89 c2                	mov    %eax,%edx
  80143d:	eb 05                	jmp    801444 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80143f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801444:	89 d0                	mov    %edx,%eax
  801446:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801449:	c9                   	leave  
  80144a:	c3                   	ret    

0080144b <seek>:

int
seek(int fdnum, off_t offset)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801451:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	ff 75 08             	pushl  0x8(%ebp)
  801458:	e8 22 fc ff ff       	call   80107f <fd_lookup>
  80145d:	83 c4 08             	add    $0x8,%esp
  801460:	85 c0                	test   %eax,%eax
  801462:	78 0e                	js     801472 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801464:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801467:	8b 55 0c             	mov    0xc(%ebp),%edx
  80146a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80146d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	53                   	push   %ebx
  801478:	83 ec 14             	sub    $0x14,%esp
  80147b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	53                   	push   %ebx
  801483:	e8 f7 fb ff ff       	call   80107f <fd_lookup>
  801488:	83 c4 08             	add    $0x8,%esp
  80148b:	89 c2                	mov    %eax,%edx
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 65                	js     8014f6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149b:	ff 30                	pushl  (%eax)
  80149d:	e8 33 fc ff ff       	call   8010d5 <dev_lookup>
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 44                	js     8014ed <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b0:	75 21                	jne    8014d3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014b2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014b7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	53                   	push   %ebx
  8014be:	50                   	push   %eax
  8014bf:	68 58 26 80 00       	push   $0x802658
  8014c4:	e8 df ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d1:	eb 23                	jmp    8014f6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d6:	8b 52 18             	mov    0x18(%edx),%edx
  8014d9:	85 d2                	test   %edx,%edx
  8014db:	74 14                	je     8014f1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	ff 75 0c             	pushl  0xc(%ebp)
  8014e3:	50                   	push   %eax
  8014e4:	ff d2                	call   *%edx
  8014e6:	89 c2                	mov    %eax,%edx
  8014e8:	83 c4 10             	add    $0x10,%esp
  8014eb:	eb 09                	jmp    8014f6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	eb 05                	jmp    8014f6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014f6:	89 d0                	mov    %edx,%eax
  8014f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fb:	c9                   	leave  
  8014fc:	c3                   	ret    

008014fd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	53                   	push   %ebx
  801501:	83 ec 14             	sub    $0x14,%esp
  801504:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801507:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	ff 75 08             	pushl  0x8(%ebp)
  80150e:	e8 6c fb ff ff       	call   80107f <fd_lookup>
  801513:	83 c4 08             	add    $0x8,%esp
  801516:	89 c2                	mov    %eax,%edx
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 58                	js     801574 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801526:	ff 30                	pushl  (%eax)
  801528:	e8 a8 fb ff ff       	call   8010d5 <dev_lookup>
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	78 37                	js     80156b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801534:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801537:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80153b:	74 32                	je     80156f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80153d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801540:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801547:	00 00 00 
	stat->st_isdir = 0;
  80154a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801551:	00 00 00 
	stat->st_dev = dev;
  801554:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	53                   	push   %ebx
  80155e:	ff 75 f0             	pushl  -0x10(%ebp)
  801561:	ff 50 14             	call   *0x14(%eax)
  801564:	89 c2                	mov    %eax,%edx
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	eb 09                	jmp    801574 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156b:	89 c2                	mov    %eax,%edx
  80156d:	eb 05                	jmp    801574 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80156f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801574:	89 d0                	mov    %edx,%eax
  801576:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801579:	c9                   	leave  
  80157a:	c3                   	ret    

0080157b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	56                   	push   %esi
  80157f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	6a 00                	push   $0x0
  801585:	ff 75 08             	pushl  0x8(%ebp)
  801588:	e8 2c 02 00 00       	call   8017b9 <open>
  80158d:	89 c3                	mov    %eax,%ebx
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	85 c0                	test   %eax,%eax
  801594:	78 1b                	js     8015b1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	ff 75 0c             	pushl  0xc(%ebp)
  80159c:	50                   	push   %eax
  80159d:	e8 5b ff ff ff       	call   8014fd <fstat>
  8015a2:	89 c6                	mov    %eax,%esi
	close(fd);
  8015a4:	89 1c 24             	mov    %ebx,(%esp)
  8015a7:	e8 fd fb ff ff       	call   8011a9 <close>
	return r;
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	89 f0                	mov    %esi,%eax
}
  8015b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5e                   	pop    %esi
  8015b6:	5d                   	pop    %ebp
  8015b7:	c3                   	ret    

008015b8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	56                   	push   %esi
  8015bc:	53                   	push   %ebx
  8015bd:	89 c6                	mov    %eax,%esi
  8015bf:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  8015c1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015c8:	75 12                	jne    8015dc <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  8015ca:	83 ec 0c             	sub    $0xc,%esp
  8015cd:	6a 01                	push   $0x1
  8015cf:	e8 e0 08 00 00       	call   801eb4 <ipc_find_env>
  8015d4:	a3 00 40 80 00       	mov    %eax,0x804000
  8015d9:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015dc:	6a 07                	push   $0x7
  8015de:	68 00 50 80 00       	push   $0x805000
  8015e3:	56                   	push   %esi
  8015e4:	ff 35 00 40 80 00    	pushl  0x804000
  8015ea:	e8 71 08 00 00       	call   801e60 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  8015ef:	83 c4 0c             	add    $0xc,%esp
  8015f2:	6a 00                	push   $0x0
  8015f4:	53                   	push   %ebx
  8015f5:	6a 00                	push   $0x0
  8015f7:	e8 05 08 00 00       	call   801e01 <ipc_recv>
}
  8015fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ff:	5b                   	pop    %ebx
  801600:	5e                   	pop    %esi
  801601:	5d                   	pop    %ebp
  801602:	c3                   	ret    

00801603 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801609:	8b 45 08             	mov    0x8(%ebp),%eax
  80160c:	8b 40 0c             	mov    0xc(%eax),%eax
  80160f:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  801614:	8b 45 0c             	mov    0xc(%ebp),%eax
  801617:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80161c:	ba 00 00 00 00       	mov    $0x0,%edx
  801621:	b8 02 00 00 00       	mov    $0x2,%eax
  801626:	e8 8d ff ff ff       	call   8015b8 <fsipc>
}
  80162b:	c9                   	leave  
  80162c:	c3                   	ret    

0080162d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801633:	8b 45 08             	mov    0x8(%ebp),%eax
  801636:	8b 40 0c             	mov    0xc(%eax),%eax
  801639:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  80163e:	ba 00 00 00 00       	mov    $0x0,%edx
  801643:	b8 06 00 00 00       	mov    $0x6,%eax
  801648:	e8 6b ff ff ff       	call   8015b8 <fsipc>
}
  80164d:	c9                   	leave  
  80164e:	c3                   	ret    

0080164f <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	53                   	push   %ebx
  801653:	83 ec 04             	sub    $0x4,%esp
  801656:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801659:	8b 45 08             	mov    0x8(%ebp),%eax
  80165c:	8b 40 0c             	mov    0xc(%eax),%eax
  80165f:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801664:	ba 00 00 00 00       	mov    $0x0,%edx
  801669:	b8 05 00 00 00       	mov    $0x5,%eax
  80166e:	e8 45 ff ff ff       	call   8015b8 <fsipc>
  801673:	85 c0                	test   %eax,%eax
  801675:	78 2c                	js     8016a3 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801677:	83 ec 08             	sub    $0x8,%esp
  80167a:	68 00 50 80 00       	push   $0x805000
  80167f:	53                   	push   %ebx
  801680:	e8 a8 f0 ff ff       	call   80072d <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  801685:	a1 80 50 80 00       	mov    0x805080,%eax
  80168a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801690:	a1 84 50 80 00       	mov    0x805084,%eax
  801695:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	53                   	push   %ebx
  8016ac:	83 ec 08             	sub    $0x8,%esp
  8016af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b8:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  8016bd:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  8016c3:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8016c9:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8016ce:	0f 46 c3             	cmovbe %ebx,%eax
  8016d1:	50                   	push   %eax
  8016d2:	ff 75 0c             	pushl  0xc(%ebp)
  8016d5:	68 08 50 80 00       	push   $0x805008
  8016da:	e8 e0 f1 ff ff       	call   8008bf <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  8016df:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e4:	b8 04 00 00 00       	mov    $0x4,%eax
  8016e9:	e8 ca fe ff ff       	call   8015b8 <fsipc>
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 3d                	js     801732 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  8016f5:	39 c3                	cmp    %eax,%ebx
  8016f7:	73 19                	jae    801712 <devfile_write+0x6a>
  8016f9:	68 c4 26 80 00       	push   $0x8026c4
  8016fe:	68 cb 26 80 00       	push   $0x8026cb
  801703:	68 9a 00 00 00       	push   $0x9a
  801708:	68 e0 26 80 00       	push   $0x8026e0
  80170d:	e8 2a 06 00 00       	call   801d3c <_panic>
	   assert (r <= bytes_written);
  801712:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801717:	7e 19                	jle    801732 <devfile_write+0x8a>
  801719:	68 eb 26 80 00       	push   $0x8026eb
  80171e:	68 cb 26 80 00       	push   $0x8026cb
  801723:	68 9b 00 00 00       	push   $0x9b
  801728:	68 e0 26 80 00       	push   $0x8026e0
  80172d:	e8 0a 06 00 00       	call   801d3c <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801732:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	8b 40 0c             	mov    0xc(%eax),%eax
  801745:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  80174a:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801750:	ba 00 00 00 00       	mov    $0x0,%edx
  801755:	b8 03 00 00 00       	mov    $0x3,%eax
  80175a:	e8 59 fe ff ff       	call   8015b8 <fsipc>
  80175f:	89 c3                	mov    %eax,%ebx
  801761:	85 c0                	test   %eax,%eax
  801763:	78 4b                	js     8017b0 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  801765:	39 c6                	cmp    %eax,%esi
  801767:	73 16                	jae    80177f <devfile_read+0x48>
  801769:	68 c4 26 80 00       	push   $0x8026c4
  80176e:	68 cb 26 80 00       	push   $0x8026cb
  801773:	6a 7c                	push   $0x7c
  801775:	68 e0 26 80 00       	push   $0x8026e0
  80177a:	e8 bd 05 00 00       	call   801d3c <_panic>
	   assert(r <= PGSIZE);
  80177f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801784:	7e 16                	jle    80179c <devfile_read+0x65>
  801786:	68 fe 26 80 00       	push   $0x8026fe
  80178b:	68 cb 26 80 00       	push   $0x8026cb
  801790:	6a 7d                	push   $0x7d
  801792:	68 e0 26 80 00       	push   $0x8026e0
  801797:	e8 a0 05 00 00       	call   801d3c <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80179c:	83 ec 04             	sub    $0x4,%esp
  80179f:	50                   	push   %eax
  8017a0:	68 00 50 80 00       	push   $0x805000
  8017a5:	ff 75 0c             	pushl  0xc(%ebp)
  8017a8:	e8 12 f1 ff ff       	call   8008bf <memmove>
	   return r;
  8017ad:	83 c4 10             	add    $0x10,%esp
}
  8017b0:	89 d8                	mov    %ebx,%eax
  8017b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b5:	5b                   	pop    %ebx
  8017b6:	5e                   	pop    %esi
  8017b7:	5d                   	pop    %ebp
  8017b8:	c3                   	ret    

008017b9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	53                   	push   %ebx
  8017bd:	83 ec 20             	sub    $0x20,%esp
  8017c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  8017c3:	53                   	push   %ebx
  8017c4:	e8 2b ef ff ff       	call   8006f4 <strlen>
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017d1:	7f 67                	jg     80183a <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8017d3:	83 ec 0c             	sub    $0xc,%esp
  8017d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d9:	50                   	push   %eax
  8017da:	e8 51 f8 ff ff       	call   801030 <fd_alloc>
  8017df:	83 c4 10             	add    $0x10,%esp
			 return r;
  8017e2:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 57                	js     80183f <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	53                   	push   %ebx
  8017ec:	68 00 50 80 00       	push   $0x805000
  8017f1:	e8 37 ef ff ff       	call   80072d <strcpy>
	   fsipcbuf.open.req_omode = mode;
  8017f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f9:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801801:	b8 01 00 00 00       	mov    $0x1,%eax
  801806:	e8 ad fd ff ff       	call   8015b8 <fsipc>
  80180b:	89 c3                	mov    %eax,%ebx
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	79 14                	jns    801828 <open+0x6f>
			 fd_close(fd, 0);
  801814:	83 ec 08             	sub    $0x8,%esp
  801817:	6a 00                	push   $0x0
  801819:	ff 75 f4             	pushl  -0xc(%ebp)
  80181c:	e8 07 f9 ff ff       	call   801128 <fd_close>
			 return r;
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	89 da                	mov    %ebx,%edx
  801826:	eb 17                	jmp    80183f <open+0x86>
	   }

	   return fd2num(fd);
  801828:	83 ec 0c             	sub    $0xc,%esp
  80182b:	ff 75 f4             	pushl  -0xc(%ebp)
  80182e:	e8 d6 f7 ff ff       	call   801009 <fd2num>
  801833:	89 c2                	mov    %eax,%edx
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	eb 05                	jmp    80183f <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  80183a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  80183f:	89 d0                	mov    %edx,%eax
  801841:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  80184c:	ba 00 00 00 00       	mov    $0x0,%edx
  801851:	b8 08 00 00 00       	mov    $0x8,%eax
  801856:	e8 5d fd ff ff       	call   8015b8 <fsipc>
}
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	56                   	push   %esi
  801861:	53                   	push   %ebx
  801862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801865:	83 ec 0c             	sub    $0xc,%esp
  801868:	ff 75 08             	pushl  0x8(%ebp)
  80186b:	e8 a9 f7 ff ff       	call   801019 <fd2data>
  801870:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801872:	83 c4 08             	add    $0x8,%esp
  801875:	68 0a 27 80 00       	push   $0x80270a
  80187a:	53                   	push   %ebx
  80187b:	e8 ad ee ff ff       	call   80072d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801880:	8b 46 04             	mov    0x4(%esi),%eax
  801883:	2b 06                	sub    (%esi),%eax
  801885:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80188b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801892:	00 00 00 
	stat->st_dev = &devpipe;
  801895:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80189c:	30 80 00 
	return 0;
}
  80189f:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a7:	5b                   	pop    %ebx
  8018a8:	5e                   	pop    %esi
  8018a9:	5d                   	pop    %ebp
  8018aa:	c3                   	ret    

008018ab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	53                   	push   %ebx
  8018af:	83 ec 0c             	sub    $0xc,%esp
  8018b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018b5:	53                   	push   %ebx
  8018b6:	6a 00                	push   $0x0
  8018b8:	e8 f8 f2 ff ff       	call   800bb5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018bd:	89 1c 24             	mov    %ebx,(%esp)
  8018c0:	e8 54 f7 ff ff       	call   801019 <fd2data>
  8018c5:	83 c4 08             	add    $0x8,%esp
  8018c8:	50                   	push   %eax
  8018c9:	6a 00                	push   $0x0
  8018cb:	e8 e5 f2 ff ff       	call   800bb5 <sys_page_unmap>
}
  8018d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	57                   	push   %edi
  8018d9:	56                   	push   %esi
  8018da:	53                   	push   %ebx
  8018db:	83 ec 1c             	sub    $0x1c,%esp
  8018de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018e1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018eb:	83 ec 0c             	sub    $0xc,%esp
  8018ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8018f1:	e8 f7 05 00 00       	call   801eed <pageref>
  8018f6:	89 c3                	mov    %eax,%ebx
  8018f8:	89 3c 24             	mov    %edi,(%esp)
  8018fb:	e8 ed 05 00 00       	call   801eed <pageref>
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	39 c3                	cmp    %eax,%ebx
  801905:	0f 94 c1             	sete   %cl
  801908:	0f b6 c9             	movzbl %cl,%ecx
  80190b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80190e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801914:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801917:	39 ce                	cmp    %ecx,%esi
  801919:	74 1b                	je     801936 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80191b:	39 c3                	cmp    %eax,%ebx
  80191d:	75 c4                	jne    8018e3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80191f:	8b 42 58             	mov    0x58(%edx),%eax
  801922:	ff 75 e4             	pushl  -0x1c(%ebp)
  801925:	50                   	push   %eax
  801926:	56                   	push   %esi
  801927:	68 11 27 80 00       	push   $0x802711
  80192c:	e8 77 e8 ff ff       	call   8001a8 <cprintf>
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	eb ad                	jmp    8018e3 <_pipeisclosed+0xe>
	}
}
  801936:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801939:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80193c:	5b                   	pop    %ebx
  80193d:	5e                   	pop    %esi
  80193e:	5f                   	pop    %edi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	57                   	push   %edi
  801945:	56                   	push   %esi
  801946:	53                   	push   %ebx
  801947:	83 ec 28             	sub    $0x28,%esp
  80194a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80194d:	56                   	push   %esi
  80194e:	e8 c6 f6 ff ff       	call   801019 <fd2data>
  801953:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	bf 00 00 00 00       	mov    $0x0,%edi
  80195d:	eb 4b                	jmp    8019aa <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80195f:	89 da                	mov    %ebx,%edx
  801961:	89 f0                	mov    %esi,%eax
  801963:	e8 6d ff ff ff       	call   8018d5 <_pipeisclosed>
  801968:	85 c0                	test   %eax,%eax
  80196a:	75 48                	jne    8019b4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80196c:	e8 a0 f1 ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801971:	8b 43 04             	mov    0x4(%ebx),%eax
  801974:	8b 0b                	mov    (%ebx),%ecx
  801976:	8d 51 20             	lea    0x20(%ecx),%edx
  801979:	39 d0                	cmp    %edx,%eax
  80197b:	73 e2                	jae    80195f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80197d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801980:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801984:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801987:	89 c2                	mov    %eax,%edx
  801989:	c1 fa 1f             	sar    $0x1f,%edx
  80198c:	89 d1                	mov    %edx,%ecx
  80198e:	c1 e9 1b             	shr    $0x1b,%ecx
  801991:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801994:	83 e2 1f             	and    $0x1f,%edx
  801997:	29 ca                	sub    %ecx,%edx
  801999:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80199d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019a1:	83 c0 01             	add    $0x1,%eax
  8019a4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a7:	83 c7 01             	add    $0x1,%edi
  8019aa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019ad:	75 c2                	jne    801971 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019af:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b2:	eb 05                	jmp    8019b9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019b4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019bc:	5b                   	pop    %ebx
  8019bd:	5e                   	pop    %esi
  8019be:	5f                   	pop    %edi
  8019bf:	5d                   	pop    %ebp
  8019c0:	c3                   	ret    

008019c1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	57                   	push   %edi
  8019c5:	56                   	push   %esi
  8019c6:	53                   	push   %ebx
  8019c7:	83 ec 18             	sub    $0x18,%esp
  8019ca:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019cd:	57                   	push   %edi
  8019ce:	e8 46 f6 ff ff       	call   801019 <fd2data>
  8019d3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d5:	83 c4 10             	add    $0x10,%esp
  8019d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019dd:	eb 3d                	jmp    801a1c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019df:	85 db                	test   %ebx,%ebx
  8019e1:	74 04                	je     8019e7 <devpipe_read+0x26>
				return i;
  8019e3:	89 d8                	mov    %ebx,%eax
  8019e5:	eb 44                	jmp    801a2b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019e7:	89 f2                	mov    %esi,%edx
  8019e9:	89 f8                	mov    %edi,%eax
  8019eb:	e8 e5 fe ff ff       	call   8018d5 <_pipeisclosed>
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	75 32                	jne    801a26 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019f4:	e8 18 f1 ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019f9:	8b 06                	mov    (%esi),%eax
  8019fb:	3b 46 04             	cmp    0x4(%esi),%eax
  8019fe:	74 df                	je     8019df <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a00:	99                   	cltd   
  801a01:	c1 ea 1b             	shr    $0x1b,%edx
  801a04:	01 d0                	add    %edx,%eax
  801a06:	83 e0 1f             	and    $0x1f,%eax
  801a09:	29 d0                	sub    %edx,%eax
  801a0b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a13:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a16:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a19:	83 c3 01             	add    $0x1,%ebx
  801a1c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a1f:	75 d8                	jne    8019f9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a21:	8b 45 10             	mov    0x10(%ebp),%eax
  801a24:	eb 05                	jmp    801a2b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a26:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5e                   	pop    %esi
  801a30:	5f                   	pop    %edi
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    

00801a33 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	56                   	push   %esi
  801a37:	53                   	push   %ebx
  801a38:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3e:	50                   	push   %eax
  801a3f:	e8 ec f5 ff ff       	call   801030 <fd_alloc>
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	89 c2                	mov    %eax,%edx
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	0f 88 2c 01 00 00    	js     801b7d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a51:	83 ec 04             	sub    $0x4,%esp
  801a54:	68 07 04 00 00       	push   $0x407
  801a59:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5c:	6a 00                	push   $0x0
  801a5e:	e8 cd f0 ff ff       	call   800b30 <sys_page_alloc>
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	89 c2                	mov    %eax,%edx
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	0f 88 0d 01 00 00    	js     801b7d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a76:	50                   	push   %eax
  801a77:	e8 b4 f5 ff ff       	call   801030 <fd_alloc>
  801a7c:	89 c3                	mov    %eax,%ebx
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	85 c0                	test   %eax,%eax
  801a83:	0f 88 e2 00 00 00    	js     801b6b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a89:	83 ec 04             	sub    $0x4,%esp
  801a8c:	68 07 04 00 00       	push   $0x407
  801a91:	ff 75 f0             	pushl  -0x10(%ebp)
  801a94:	6a 00                	push   $0x0
  801a96:	e8 95 f0 ff ff       	call   800b30 <sys_page_alloc>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	0f 88 c3 00 00 00    	js     801b6b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801aa8:	83 ec 0c             	sub    $0xc,%esp
  801aab:	ff 75 f4             	pushl  -0xc(%ebp)
  801aae:	e8 66 f5 ff ff       	call   801019 <fd2data>
  801ab3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab5:	83 c4 0c             	add    $0xc,%esp
  801ab8:	68 07 04 00 00       	push   $0x407
  801abd:	50                   	push   %eax
  801abe:	6a 00                	push   $0x0
  801ac0:	e8 6b f0 ff ff       	call   800b30 <sys_page_alloc>
  801ac5:	89 c3                	mov    %eax,%ebx
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	85 c0                	test   %eax,%eax
  801acc:	0f 88 89 00 00 00    	js     801b5b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad2:	83 ec 0c             	sub    $0xc,%esp
  801ad5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad8:	e8 3c f5 ff ff       	call   801019 <fd2data>
  801add:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ae4:	50                   	push   %eax
  801ae5:	6a 00                	push   $0x0
  801ae7:	56                   	push   %esi
  801ae8:	6a 00                	push   $0x0
  801aea:	e8 84 f0 ff ff       	call   800b73 <sys_page_map>
  801aef:	89 c3                	mov    %eax,%ebx
  801af1:	83 c4 20             	add    $0x20,%esp
  801af4:	85 c0                	test   %eax,%eax
  801af6:	78 55                	js     801b4d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801af8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b01:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b06:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b16:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b22:	83 ec 0c             	sub    $0xc,%esp
  801b25:	ff 75 f4             	pushl  -0xc(%ebp)
  801b28:	e8 dc f4 ff ff       	call   801009 <fd2num>
  801b2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b30:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b32:	83 c4 04             	add    $0x4,%esp
  801b35:	ff 75 f0             	pushl  -0x10(%ebp)
  801b38:	e8 cc f4 ff ff       	call   801009 <fd2num>
  801b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b40:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4b:	eb 30                	jmp    801b7d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b4d:	83 ec 08             	sub    $0x8,%esp
  801b50:	56                   	push   %esi
  801b51:	6a 00                	push   $0x0
  801b53:	e8 5d f0 ff ff       	call   800bb5 <sys_page_unmap>
  801b58:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b5b:	83 ec 08             	sub    $0x8,%esp
  801b5e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b61:	6a 00                	push   $0x0
  801b63:	e8 4d f0 ff ff       	call   800bb5 <sys_page_unmap>
  801b68:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b6b:	83 ec 08             	sub    $0x8,%esp
  801b6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b71:	6a 00                	push   $0x0
  801b73:	e8 3d f0 ff ff       	call   800bb5 <sys_page_unmap>
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b7d:	89 d0                	mov    %edx,%eax
  801b7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8f:	50                   	push   %eax
  801b90:	ff 75 08             	pushl  0x8(%ebp)
  801b93:	e8 e7 f4 ff ff       	call   80107f <fd_lookup>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	78 18                	js     801bb7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b9f:	83 ec 0c             	sub    $0xc,%esp
  801ba2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba5:	e8 6f f4 ff ff       	call   801019 <fd2data>
	return _pipeisclosed(fd, p);
  801baa:	89 c2                	mov    %eax,%edx
  801bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801baf:	e8 21 fd ff ff       	call   8018d5 <_pipeisclosed>
  801bb4:	83 c4 10             	add    $0x10,%esp
}
  801bb7:	c9                   	leave  
  801bb8:	c3                   	ret    

00801bb9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    

00801bc3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bc9:	68 29 27 80 00       	push   $0x802729
  801bce:	ff 75 0c             	pushl  0xc(%ebp)
  801bd1:	e8 57 eb ff ff       	call   80072d <strcpy>
	return 0;
}
  801bd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	57                   	push   %edi
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bee:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf4:	eb 2d                	jmp    801c23 <devcons_write+0x46>
		m = n - tot;
  801bf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bf9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bfb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bfe:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c03:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c06:	83 ec 04             	sub    $0x4,%esp
  801c09:	53                   	push   %ebx
  801c0a:	03 45 0c             	add    0xc(%ebp),%eax
  801c0d:	50                   	push   %eax
  801c0e:	57                   	push   %edi
  801c0f:	e8 ab ec ff ff       	call   8008bf <memmove>
		sys_cputs(buf, m);
  801c14:	83 c4 08             	add    $0x8,%esp
  801c17:	53                   	push   %ebx
  801c18:	57                   	push   %edi
  801c19:	e8 56 ee ff ff       	call   800a74 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c1e:	01 de                	add    %ebx,%esi
  801c20:	83 c4 10             	add    $0x10,%esp
  801c23:	89 f0                	mov    %esi,%eax
  801c25:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c28:	72 cc                	jb     801bf6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    

00801c32 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	83 ec 08             	sub    $0x8,%esp
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c41:	74 2a                	je     801c6d <devcons_read+0x3b>
  801c43:	eb 05                	jmp    801c4a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c45:	e8 c7 ee ff ff       	call   800b11 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c4a:	e8 43 ee ff ff       	call   800a92 <sys_cgetc>
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	74 f2                	je     801c45 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c53:	85 c0                	test   %eax,%eax
  801c55:	78 16                	js     801c6d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c57:	83 f8 04             	cmp    $0x4,%eax
  801c5a:	74 0c                	je     801c68 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5f:	88 02                	mov    %al,(%edx)
	return 1;
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	eb 05                	jmp    801c6d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c68:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c6d:	c9                   	leave  
  801c6e:	c3                   	ret    

00801c6f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c75:	8b 45 08             	mov    0x8(%ebp),%eax
  801c78:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c7b:	6a 01                	push   $0x1
  801c7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c80:	50                   	push   %eax
  801c81:	e8 ee ed ff ff       	call   800a74 <sys_cputs>
}
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    

00801c8b <getchar>:

int
getchar(void)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c91:	6a 01                	push   $0x1
  801c93:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c96:	50                   	push   %eax
  801c97:	6a 00                	push   $0x0
  801c99:	e8 47 f6 ff ff       	call   8012e5 <read>
	if (r < 0)
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	78 0f                	js     801cb4 <getchar+0x29>
		return r;
	if (r < 1)
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	7e 06                	jle    801caf <getchar+0x24>
		return -E_EOF;
	return c;
  801ca9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cad:	eb 05                	jmp    801cb4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801caf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cb4:	c9                   	leave  
  801cb5:	c3                   	ret    

00801cb6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbf:	50                   	push   %eax
  801cc0:	ff 75 08             	pushl  0x8(%ebp)
  801cc3:	e8 b7 f3 ff ff       	call   80107f <fd_lookup>
  801cc8:	83 c4 10             	add    $0x10,%esp
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	78 11                	js     801ce0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd8:	39 10                	cmp    %edx,(%eax)
  801cda:	0f 94 c0             	sete   %al
  801cdd:	0f b6 c0             	movzbl %al,%eax
}
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    

00801ce2 <opencons>:

int
opencons(void)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ceb:	50                   	push   %eax
  801cec:	e8 3f f3 ff ff       	call   801030 <fd_alloc>
  801cf1:	83 c4 10             	add    $0x10,%esp
		return r;
  801cf4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 3e                	js     801d38 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cfa:	83 ec 04             	sub    $0x4,%esp
  801cfd:	68 07 04 00 00       	push   $0x407
  801d02:	ff 75 f4             	pushl  -0xc(%ebp)
  801d05:	6a 00                	push   $0x0
  801d07:	e8 24 ee ff ff       	call   800b30 <sys_page_alloc>
  801d0c:	83 c4 10             	add    $0x10,%esp
		return r;
  801d0f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d11:	85 c0                	test   %eax,%eax
  801d13:	78 23                	js     801d38 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d15:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d23:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d2a:	83 ec 0c             	sub    $0xc,%esp
  801d2d:	50                   	push   %eax
  801d2e:	e8 d6 f2 ff ff       	call   801009 <fd2num>
  801d33:	89 c2                	mov    %eax,%edx
  801d35:	83 c4 10             	add    $0x10,%esp
}
  801d38:	89 d0                	mov    %edx,%eax
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d41:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d44:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d4a:	e8 a3 ed ff ff       	call   800af2 <sys_getenvid>
  801d4f:	83 ec 0c             	sub    $0xc,%esp
  801d52:	ff 75 0c             	pushl  0xc(%ebp)
  801d55:	ff 75 08             	pushl  0x8(%ebp)
  801d58:	56                   	push   %esi
  801d59:	50                   	push   %eax
  801d5a:	68 38 27 80 00       	push   $0x802738
  801d5f:	e8 44 e4 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d64:	83 c4 18             	add    $0x18,%esp
  801d67:	53                   	push   %ebx
  801d68:	ff 75 10             	pushl  0x10(%ebp)
  801d6b:	e8 e7 e3 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801d70:	c7 04 24 54 22 80 00 	movl   $0x802254,(%esp)
  801d77:	e8 2c e4 ff ff       	call   8001a8 <cprintf>
  801d7c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d7f:	cc                   	int3   
  801d80:	eb fd                	jmp    801d7f <_panic+0x43>

00801d82 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  801d88:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d8f:	75 2a                	jne    801dbb <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801d91:	83 ec 04             	sub    $0x4,%esp
  801d94:	6a 06                	push   $0x6
  801d96:	68 00 f0 bf ee       	push   $0xeebff000
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 8e ed ff ff       	call   800b30 <sys_page_alloc>
			 if (a < 0)
  801da2:	83 c4 10             	add    $0x10,%esp
  801da5:	85 c0                	test   %eax,%eax
  801da7:	79 12                	jns    801dbb <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801da9:	50                   	push   %eax
  801daa:	68 5c 27 80 00       	push   $0x80275c
  801daf:	6a 21                	push   $0x21
  801db1:	68 76 27 80 00       	push   $0x802776
  801db6:	e8 81 ff ff ff       	call   801d3c <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  801dbb:	e8 32 ed ff ff       	call   800af2 <sys_getenvid>
  801dc0:	83 ec 08             	sub    $0x8,%esp
  801dc3:	68 db 1d 80 00       	push   $0x801ddb
  801dc8:	50                   	push   %eax
  801dc9:	e8 ad ee ff ff       	call   800c7b <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  801dce:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd1:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	c9                   	leave  
  801dda:	c3                   	ret    

00801ddb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  801ddb:	54                   	push   %esp
movl _pgfault_handler, %eax
  801ddc:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  801de1:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  801de3:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  801de6:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  801dea:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  801dee:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  801df1:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  801df5:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  801df7:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  801dfa:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  801dfb:	83 c4 04             	add    $0x4,%esp
popfl
  801dfe:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  801dff:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  801e00:	c3                   	ret    

00801e01 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e01:	55                   	push   %ebp
  801e02:	89 e5                	mov    %esp,%ebp
  801e04:	56                   	push   %esi
  801e05:	53                   	push   %ebx
  801e06:	8b 75 08             	mov    0x8(%ebp),%esi
  801e09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801e0f:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801e11:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801e16:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801e19:	83 ec 0c             	sub    $0xc,%esp
  801e1c:	50                   	push   %eax
  801e1d:	e8 be ee ff ff       	call   800ce0 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 0e                	js     801e37 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801e29:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e2f:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801e32:	8b 52 78             	mov    0x78(%edx),%edx
  801e35:	eb 0a                	jmp    801e41 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801e37:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801e3c:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801e41:	85 f6                	test   %esi,%esi
  801e43:	74 02                	je     801e47 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801e45:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801e47:	85 db                	test   %ebx,%ebx
  801e49:	74 02                	je     801e4d <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801e4b:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	78 08                	js     801e59 <ipc_recv+0x58>
  801e51:	a1 04 40 80 00       	mov    0x804004,%eax
  801e56:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801e59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e5c:	5b                   	pop    %ebx
  801e5d:	5e                   	pop    %esi
  801e5e:	5d                   	pop    %ebp
  801e5f:	c3                   	ret    

00801e60 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	57                   	push   %edi
  801e64:	56                   	push   %esi
  801e65:	53                   	push   %ebx
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801e72:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801e74:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801e79:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801e7c:	ff 75 14             	pushl  0x14(%ebp)
  801e7f:	53                   	push   %ebx
  801e80:	56                   	push   %esi
  801e81:	57                   	push   %edi
  801e82:	e8 36 ee ff ff       	call   800cbd <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e8d:	75 07                	jne    801e96 <ipc_send+0x36>
				    sys_yield();
  801e8f:	e8 7d ec ff ff       	call   800b11 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801e94:	eb e6                	jmp    801e7c <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801e96:	85 c0                	test   %eax,%eax
  801e98:	74 12                	je     801eac <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801e9a:	50                   	push   %eax
  801e9b:	68 84 27 80 00       	push   $0x802784
  801ea0:	6a 4b                	push   $0x4b
  801ea2:	68 98 27 80 00       	push   $0x802798
  801ea7:	e8 90 fe ff ff       	call   801d3c <_panic>
			 }
	   }
}
  801eac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eaf:	5b                   	pop    %ebx
  801eb0:	5e                   	pop    %esi
  801eb1:	5f                   	pop    %edi
  801eb2:	5d                   	pop    %ebp
  801eb3:	c3                   	ret    

00801eb4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801eba:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801ebf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ec2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ec8:	8b 52 50             	mov    0x50(%edx),%edx
  801ecb:	39 ca                	cmp    %ecx,%edx
  801ecd:	75 0d                	jne    801edc <ipc_find_env+0x28>
				    return envs[i].env_id;
  801ecf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ed2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ed7:	8b 40 48             	mov    0x48(%eax),%eax
  801eda:	eb 0f                	jmp    801eeb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801edc:	83 c0 01             	add    $0x1,%eax
  801edf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ee4:	75 d9                	jne    801ebf <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801ee6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    

00801eed <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef3:	89 d0                	mov    %edx,%eax
  801ef5:	c1 e8 16             	shr    $0x16,%eax
  801ef8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eff:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f04:	f6 c1 01             	test   $0x1,%cl
  801f07:	74 1d                	je     801f26 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f09:	c1 ea 0c             	shr    $0xc,%edx
  801f0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f13:	f6 c2 01             	test   $0x1,%dl
  801f16:	74 0e                	je     801f26 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f18:	c1 ea 0c             	shr    $0xc,%edx
  801f1b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f22:	ef 
  801f23:	0f b7 c0             	movzwl %ax,%eax
}
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    
  801f28:	66 90                	xchg   %ax,%ax
  801f2a:	66 90                	xchg   %ax,%ax
  801f2c:	66 90                	xchg   %ax,%ax
  801f2e:	66 90                	xchg   %ax,%ax

00801f30 <__udivdi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	83 ec 1c             	sub    $0x1c,%esp
  801f37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f47:	85 f6                	test   %esi,%esi
  801f49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f4d:	89 ca                	mov    %ecx,%edx
  801f4f:	89 f8                	mov    %edi,%eax
  801f51:	75 3d                	jne    801f90 <__udivdi3+0x60>
  801f53:	39 cf                	cmp    %ecx,%edi
  801f55:	0f 87 c5 00 00 00    	ja     802020 <__udivdi3+0xf0>
  801f5b:	85 ff                	test   %edi,%edi
  801f5d:	89 fd                	mov    %edi,%ebp
  801f5f:	75 0b                	jne    801f6c <__udivdi3+0x3c>
  801f61:	b8 01 00 00 00       	mov    $0x1,%eax
  801f66:	31 d2                	xor    %edx,%edx
  801f68:	f7 f7                	div    %edi
  801f6a:	89 c5                	mov    %eax,%ebp
  801f6c:	89 c8                	mov    %ecx,%eax
  801f6e:	31 d2                	xor    %edx,%edx
  801f70:	f7 f5                	div    %ebp
  801f72:	89 c1                	mov    %eax,%ecx
  801f74:	89 d8                	mov    %ebx,%eax
  801f76:	89 cf                	mov    %ecx,%edi
  801f78:	f7 f5                	div    %ebp
  801f7a:	89 c3                	mov    %eax,%ebx
  801f7c:	89 d8                	mov    %ebx,%eax
  801f7e:	89 fa                	mov    %edi,%edx
  801f80:	83 c4 1c             	add    $0x1c,%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
  801f88:	90                   	nop
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	39 ce                	cmp    %ecx,%esi
  801f92:	77 74                	ja     802008 <__udivdi3+0xd8>
  801f94:	0f bd fe             	bsr    %esi,%edi
  801f97:	83 f7 1f             	xor    $0x1f,%edi
  801f9a:	0f 84 98 00 00 00    	je     802038 <__udivdi3+0x108>
  801fa0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	89 c5                	mov    %eax,%ebp
  801fa9:	29 fb                	sub    %edi,%ebx
  801fab:	d3 e6                	shl    %cl,%esi
  801fad:	89 d9                	mov    %ebx,%ecx
  801faf:	d3 ed                	shr    %cl,%ebp
  801fb1:	89 f9                	mov    %edi,%ecx
  801fb3:	d3 e0                	shl    %cl,%eax
  801fb5:	09 ee                	or     %ebp,%esi
  801fb7:	89 d9                	mov    %ebx,%ecx
  801fb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbd:	89 d5                	mov    %edx,%ebp
  801fbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fc3:	d3 ed                	shr    %cl,%ebp
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	d3 e2                	shl    %cl,%edx
  801fc9:	89 d9                	mov    %ebx,%ecx
  801fcb:	d3 e8                	shr    %cl,%eax
  801fcd:	09 c2                	or     %eax,%edx
  801fcf:	89 d0                	mov    %edx,%eax
  801fd1:	89 ea                	mov    %ebp,%edx
  801fd3:	f7 f6                	div    %esi
  801fd5:	89 d5                	mov    %edx,%ebp
  801fd7:	89 c3                	mov    %eax,%ebx
  801fd9:	f7 64 24 0c          	mull   0xc(%esp)
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	72 10                	jb     801ff1 <__udivdi3+0xc1>
  801fe1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	d3 e6                	shl    %cl,%esi
  801fe9:	39 c6                	cmp    %eax,%esi
  801feb:	73 07                	jae    801ff4 <__udivdi3+0xc4>
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	75 03                	jne    801ff4 <__udivdi3+0xc4>
  801ff1:	83 eb 01             	sub    $0x1,%ebx
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	89 d8                	mov    %ebx,%eax
  801ff8:	89 fa                	mov    %edi,%edx
  801ffa:	83 c4 1c             	add    $0x1c,%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    
  802002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802008:	31 ff                	xor    %edi,%edi
  80200a:	31 db                	xor    %ebx,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	89 d8                	mov    %ebx,%eax
  802022:	f7 f7                	div    %edi
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 c3                	mov    %eax,%ebx
  802028:	89 d8                	mov    %ebx,%eax
  80202a:	89 fa                	mov    %edi,%edx
  80202c:	83 c4 1c             	add    $0x1c,%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    
  802034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802038:	39 ce                	cmp    %ecx,%esi
  80203a:	72 0c                	jb     802048 <__udivdi3+0x118>
  80203c:	31 db                	xor    %ebx,%ebx
  80203e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802042:	0f 87 34 ff ff ff    	ja     801f7c <__udivdi3+0x4c>
  802048:	bb 01 00 00 00       	mov    $0x1,%ebx
  80204d:	e9 2a ff ff ff       	jmp    801f7c <__udivdi3+0x4c>
  802052:	66 90                	xchg   %ax,%ax
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__umoddi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80206b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80206f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 d2                	test   %edx,%edx
  802079:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80207d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802081:	89 f3                	mov    %esi,%ebx
  802083:	89 3c 24             	mov    %edi,(%esp)
  802086:	89 74 24 04          	mov    %esi,0x4(%esp)
  80208a:	75 1c                	jne    8020a8 <__umoddi3+0x48>
  80208c:	39 f7                	cmp    %esi,%edi
  80208e:	76 50                	jbe    8020e0 <__umoddi3+0x80>
  802090:	89 c8                	mov    %ecx,%eax
  802092:	89 f2                	mov    %esi,%edx
  802094:	f7 f7                	div    %edi
  802096:	89 d0                	mov    %edx,%eax
  802098:	31 d2                	xor    %edx,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	39 f2                	cmp    %esi,%edx
  8020aa:	89 d0                	mov    %edx,%eax
  8020ac:	77 52                	ja     802100 <__umoddi3+0xa0>
  8020ae:	0f bd ea             	bsr    %edx,%ebp
  8020b1:	83 f5 1f             	xor    $0x1f,%ebp
  8020b4:	75 5a                	jne    802110 <__umoddi3+0xb0>
  8020b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ba:	0f 82 e0 00 00 00    	jb     8021a0 <__umoddi3+0x140>
  8020c0:	39 0c 24             	cmp    %ecx,(%esp)
  8020c3:	0f 86 d7 00 00 00    	jbe    8021a0 <__umoddi3+0x140>
  8020c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020d1:	83 c4 1c             	add    $0x1c,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5f                   	pop    %edi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	85 ff                	test   %edi,%edi
  8020e2:	89 fd                	mov    %edi,%ebp
  8020e4:	75 0b                	jne    8020f1 <__umoddi3+0x91>
  8020e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	f7 f7                	div    %edi
  8020ef:	89 c5                	mov    %eax,%ebp
  8020f1:	89 f0                	mov    %esi,%eax
  8020f3:	31 d2                	xor    %edx,%edx
  8020f5:	f7 f5                	div    %ebp
  8020f7:	89 c8                	mov    %ecx,%eax
  8020f9:	f7 f5                	div    %ebp
  8020fb:	89 d0                	mov    %edx,%eax
  8020fd:	eb 99                	jmp    802098 <__umoddi3+0x38>
  8020ff:	90                   	nop
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	83 c4 1c             	add    $0x1c,%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	8b 34 24             	mov    (%esp),%esi
  802113:	bf 20 00 00 00       	mov    $0x20,%edi
  802118:	89 e9                	mov    %ebp,%ecx
  80211a:	29 ef                	sub    %ebp,%edi
  80211c:	d3 e0                	shl    %cl,%eax
  80211e:	89 f9                	mov    %edi,%ecx
  802120:	89 f2                	mov    %esi,%edx
  802122:	d3 ea                	shr    %cl,%edx
  802124:	89 e9                	mov    %ebp,%ecx
  802126:	09 c2                	or     %eax,%edx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 14 24             	mov    %edx,(%esp)
  80212d:	89 f2                	mov    %esi,%edx
  80212f:	d3 e2                	shl    %cl,%edx
  802131:	89 f9                	mov    %edi,%ecx
  802133:	89 54 24 04          	mov    %edx,0x4(%esp)
  802137:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	89 c6                	mov    %eax,%esi
  802141:	d3 e3                	shl    %cl,%ebx
  802143:	89 f9                	mov    %edi,%ecx
  802145:	89 d0                	mov    %edx,%eax
  802147:	d3 e8                	shr    %cl,%eax
  802149:	89 e9                	mov    %ebp,%ecx
  80214b:	09 d8                	or     %ebx,%eax
  80214d:	89 d3                	mov    %edx,%ebx
  80214f:	89 f2                	mov    %esi,%edx
  802151:	f7 34 24             	divl   (%esp)
  802154:	89 d6                	mov    %edx,%esi
  802156:	d3 e3                	shl    %cl,%ebx
  802158:	f7 64 24 04          	mull   0x4(%esp)
  80215c:	39 d6                	cmp    %edx,%esi
  80215e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802162:	89 d1                	mov    %edx,%ecx
  802164:	89 c3                	mov    %eax,%ebx
  802166:	72 08                	jb     802170 <__umoddi3+0x110>
  802168:	75 11                	jne    80217b <__umoddi3+0x11b>
  80216a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80216e:	73 0b                	jae    80217b <__umoddi3+0x11b>
  802170:	2b 44 24 04          	sub    0x4(%esp),%eax
  802174:	1b 14 24             	sbb    (%esp),%edx
  802177:	89 d1                	mov    %edx,%ecx
  802179:	89 c3                	mov    %eax,%ebx
  80217b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80217f:	29 da                	sub    %ebx,%edx
  802181:	19 ce                	sbb    %ecx,%esi
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 f0                	mov    %esi,%eax
  802187:	d3 e0                	shl    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	d3 ea                	shr    %cl,%edx
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	d3 ee                	shr    %cl,%esi
  802191:	09 d0                	or     %edx,%eax
  802193:	89 f2                	mov    %esi,%edx
  802195:	83 c4 1c             	add    $0x1c,%esp
  802198:	5b                   	pop    %ebx
  802199:	5e                   	pop    %esi
  80219a:	5f                   	pop    %edi
  80219b:	5d                   	pop    %ebp
  80219c:	c3                   	ret    
  80219d:	8d 76 00             	lea    0x0(%esi),%esi
  8021a0:	29 f9                	sub    %edi,%ecx
  8021a2:	19 d6                	sbb    %edx,%esi
  8021a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ac:	e9 18 ff ff ff       	jmp    8020c9 <__umoddi3+0x69>
