
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 d2 0d 00 00       	call   800e13 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 ac 0a 00 00       	call   800afb <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 e0 21 80 00       	push   $0x8021e0
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 05 10 00 00       	call   801071 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 93 0f 00 00       	call   801012 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 72 0a 00 00       	call   800afb <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 f6 21 80 00       	push   $0x8021f6
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 c3 0f 00 00       	call   801071 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000c9:	e8 2d 0a 00 00       	call   800afb <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 ba 11 00 00       	call   8012c9 <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 a1 09 00 00       	call   800aba <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 2f 09 00 00       	call   800a7d <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 54 01 00 00       	call   8002e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 d4 08 00 00       	call   800a7d <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 27 1d 00 00       	call   801f40 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 14 1e 00 00       	call   802070 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 13 22 80 00 	movsbl 0x802213(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800277:	83 fa 01             	cmp    $0x1,%edx
  80027a:	7e 0e                	jle    80028a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	8b 52 04             	mov    0x4(%edx),%edx
  800288:	eb 22                	jmp    8002ac <getuint+0x38>
	else if (lflag)
  80028a:	85 d2                	test   %edx,%edx
  80028c:	74 10                	je     80029e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
  80029c:	eb 0e                	jmp    8002ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bd:	73 0a                	jae    8002c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	88 02                	mov    %al,(%edx)
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	e8 05 00 00 00       	call   8002e8 <vprintfmt>
	va_end(ap);
}
  8002e3:	83 c4 10             	add    $0x10,%esp
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 2c             	sub    $0x2c,%esp
  8002f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fa:	eb 12                	jmp    80030e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	0f 84 89 03 00 00    	je     80068d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	53                   	push   %ebx
  800308:	50                   	push   %eax
  800309:	ff d6                	call   *%esi
  80030b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030e:	83 c7 01             	add    $0x1,%edi
  800311:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800315:	83 f8 25             	cmp    $0x25,%eax
  800318:	75 e2                	jne    8002fc <vprintfmt+0x14>
  80031a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800325:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800333:	ba 00 00 00 00       	mov    $0x0,%edx
  800338:	eb 07                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8d 47 01             	lea    0x1(%edi),%eax
  800344:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800347:	0f b6 07             	movzbl (%edi),%eax
  80034a:	0f b6 c8             	movzbl %al,%ecx
  80034d:	83 e8 23             	sub    $0x23,%eax
  800350:	3c 55                	cmp    $0x55,%al
  800352:	0f 87 1a 03 00 00    	ja     800672 <vprintfmt+0x38a>
  800358:	0f b6 c0             	movzbl %al,%eax
  80035b:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800365:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800369:	eb d6                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036e:	b8 00 00 00 00       	mov    $0x0,%eax
  800373:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800376:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800379:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800380:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800383:	83 fa 09             	cmp    $0x9,%edx
  800386:	77 39                	ja     8003c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800388:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038b:	eb e9                	jmp    800376 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8d 48 04             	lea    0x4(%eax),%ecx
  800393:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039e:	eb 27                	jmp    8003c7 <vprintfmt+0xdf>
  8003a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003aa:	0f 49 c8             	cmovns %eax,%ecx
  8003ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b3:	eb 8c                	jmp    800341 <vprintfmt+0x59>
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003bf:	eb 80                	jmp    800341 <vprintfmt+0x59>
  8003c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cb:	0f 89 70 ff ff ff    	jns    800341 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003de:	e9 5e ff ff ff       	jmp    800341 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e9:	e9 53 ff ff ff       	jmp    800341 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8d 50 04             	lea    0x4(%eax),%edx
  8003f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	53                   	push   %ebx
  8003fb:	ff 30                	pushl  (%eax)
  8003fd:	ff d6                	call   *%esi
			break;
  8003ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800405:	e9 04 ff ff ff       	jmp    80030e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 50 04             	lea    0x4(%eax),%edx
  800410:	89 55 14             	mov    %edx,0x14(%ebp)
  800413:	8b 00                	mov    (%eax),%eax
  800415:	99                   	cltd   
  800416:	31 d0                	xor    %edx,%eax
  800418:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041a:	83 f8 0f             	cmp    $0xf,%eax
  80041d:	7f 0b                	jg     80042a <vprintfmt+0x142>
  80041f:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 2b 22 80 00       	push   $0x80222b
  800430:	53                   	push   %ebx
  800431:	56                   	push   %esi
  800432:	e8 94 fe ff ff       	call   8002cb <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 cc fe ff ff       	jmp    80030e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800442:	52                   	push   %edx
  800443:	68 bd 26 80 00       	push   $0x8026bd
  800448:	53                   	push   %ebx
  800449:	56                   	push   %esi
  80044a:	e8 7c fe ff ff       	call   8002cb <printfmt>
  80044f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800455:	e9 b4 fe ff ff       	jmp    80030e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800465:	85 ff                	test   %edi,%edi
  800467:	b8 24 22 80 00       	mov    $0x802224,%eax
  80046c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800473:	0f 8e 94 00 00 00    	jle    80050d <vprintfmt+0x225>
  800479:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047d:	0f 84 98 00 00 00    	je     80051b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 d0             	pushl  -0x30(%ebp)
  800489:	57                   	push   %edi
  80048a:	e8 86 02 00 00       	call   800715 <strnlen>
  80048f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800492:	29 c1                	sub    %eax,%ecx
  800494:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	eb 0f                	jmp    8004b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	53                   	push   %ebx
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 ef 01             	sub    $0x1,%edi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	7f ed                	jg     8004a8 <vprintfmt+0x1c0>
  8004bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c1:	85 c9                	test   %ecx,%ecx
  8004c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c8:	0f 49 c1             	cmovns %ecx,%eax
  8004cb:	29 c1                	sub    %eax,%ecx
  8004cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d6:	89 cb                	mov    %ecx,%ebx
  8004d8:	eb 4d                	jmp    800527 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004de:	74 1b                	je     8004fb <vprintfmt+0x213>
  8004e0:	0f be c0             	movsbl %al,%eax
  8004e3:	83 e8 20             	sub    $0x20,%eax
  8004e6:	83 f8 5e             	cmp    $0x5e,%eax
  8004e9:	76 10                	jbe    8004fb <vprintfmt+0x213>
					putch('?', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	ff 75 0c             	pushl  0xc(%ebp)
  8004f1:	6a 3f                	push   $0x3f
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb 0d                	jmp    800508 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	ff 75 0c             	pushl  0xc(%ebp)
  800501:	52                   	push   %edx
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800508:	83 eb 01             	sub    $0x1,%ebx
  80050b:	eb 1a                	jmp    800527 <vprintfmt+0x23f>
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800519:	eb 0c                	jmp    800527 <vprintfmt+0x23f>
  80051b:	89 75 08             	mov    %esi,0x8(%ebp)
  80051e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800521:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800524:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800527:	83 c7 01             	add    $0x1,%edi
  80052a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052e:	0f be d0             	movsbl %al,%edx
  800531:	85 d2                	test   %edx,%edx
  800533:	74 23                	je     800558 <vprintfmt+0x270>
  800535:	85 f6                	test   %esi,%esi
  800537:	78 a1                	js     8004da <vprintfmt+0x1f2>
  800539:	83 ee 01             	sub    $0x1,%esi
  80053c:	79 9c                	jns    8004da <vprintfmt+0x1f2>
  80053e:	89 df                	mov    %ebx,%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800546:	eb 18                	jmp    800560 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	6a 20                	push   $0x20
  80054e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800550:	83 ef 01             	sub    $0x1,%edi
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb 08                	jmp    800560 <vprintfmt+0x278>
  800558:	89 df                	mov    %ebx,%edi
  80055a:	8b 75 08             	mov    0x8(%ebp),%esi
  80055d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800560:	85 ff                	test   %edi,%edi
  800562:	7f e4                	jg     800548 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800567:	e9 a2 fd ff ff       	jmp    80030e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056c:	83 fa 01             	cmp    $0x1,%edx
  80056f:	7e 16                	jle    800587 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 08             	lea    0x8(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 50 04             	mov    0x4(%eax),%edx
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800585:	eb 32                	jmp    8005b9 <vprintfmt+0x2d1>
	else if (lflag)
  800587:	85 d2                	test   %edx,%edx
  800589:	74 18                	je     8005a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 00                	mov    (%eax),%eax
  800596:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800599:	89 c1                	mov    %eax,%ecx
  80059b:	c1 f9 1f             	sar    $0x1f,%ecx
  80059e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a1:	eb 16                	jmp    8005b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 04             	lea    0x4(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 c1                	mov    %eax,%ecx
  8005b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c8:	79 74                	jns    80063e <vprintfmt+0x356>
				putch('-', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 2d                	push   $0x2d
  8005d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d8:	f7 d8                	neg    %eax
  8005da:	83 d2 00             	adc    $0x0,%edx
  8005dd:	f7 da                	neg    %edx
  8005df:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e7:	eb 55                	jmp    80063e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ec:	e8 83 fc ff ff       	call   800274 <getuint>
			base = 10;
  8005f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f6:	eb 46                	jmp    80063e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fb:	e8 74 fc ff ff       	call   800274 <getuint>
			base = 8;
  800600:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800605:	eb 37                	jmp    80063e <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 30                	push   $0x30
  80060d:	ff d6                	call   *%esi
			putch('x', putdat);
  80060f:	83 c4 08             	add    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 78                	push   $0x78
  800615:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800620:	8b 00                	mov    (%eax),%eax
  800622:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800627:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80062f:	eb 0d                	jmp    80063e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800631:	8d 45 14             	lea    0x14(%ebp),%eax
  800634:	e8 3b fc ff ff       	call   800274 <getuint>
			base = 16;
  800639:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063e:	83 ec 0c             	sub    $0xc,%esp
  800641:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800645:	57                   	push   %edi
  800646:	ff 75 e0             	pushl  -0x20(%ebp)
  800649:	51                   	push   %ecx
  80064a:	52                   	push   %edx
  80064b:	50                   	push   %eax
  80064c:	89 da                	mov    %ebx,%edx
  80064e:	89 f0                	mov    %esi,%eax
  800650:	e8 70 fb ff ff       	call   8001c5 <printnum>
			break;
  800655:	83 c4 20             	add    $0x20,%esp
  800658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065b:	e9 ae fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	51                   	push   %ecx
  800665:	ff d6                	call   *%esi
			break;
  800667:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066d:	e9 9c fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 25                	push   $0x25
  800678:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	eb 03                	jmp    800682 <vprintfmt+0x39a>
  80067f:	83 ef 01             	sub    $0x1,%edi
  800682:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800686:	75 f7                	jne    80067f <vprintfmt+0x397>
  800688:	e9 81 fc ff ff       	jmp    80030e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80068d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800690:	5b                   	pop    %ebx
  800691:	5e                   	pop    %esi
  800692:	5f                   	pop    %edi
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    

00800695 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	83 ec 18             	sub    $0x18,%esp
  80069b:	8b 45 08             	mov    0x8(%ebp),%eax
  80069e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	74 26                	je     8006dc <vsnprintf+0x47>
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	7e 22                	jle    8006dc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ba:	ff 75 14             	pushl  0x14(%ebp)
  8006bd:	ff 75 10             	pushl  0x10(%ebp)
  8006c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c3:	50                   	push   %eax
  8006c4:	68 ae 02 80 00       	push   $0x8002ae
  8006c9:	e8 1a fc ff ff       	call   8002e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	eb 05                	jmp    8006e1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ec:	50                   	push   %eax
  8006ed:	ff 75 10             	pushl  0x10(%ebp)
  8006f0:	ff 75 0c             	pushl  0xc(%ebp)
  8006f3:	ff 75 08             	pushl  0x8(%ebp)
  8006f6:	e8 9a ff ff ff       	call   800695 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	eb 03                	jmp    80070d <strlen+0x10>
		n++;
  80070a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800711:	75 f7                	jne    80070a <strlen+0xd>
		n++;
	return n;
}
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071e:	ba 00 00 00 00       	mov    $0x0,%edx
  800723:	eb 03                	jmp    800728 <strnlen+0x13>
		n++;
  800725:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800728:	39 c2                	cmp    %eax,%edx
  80072a:	74 08                	je     800734 <strnlen+0x1f>
  80072c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800730:	75 f3                	jne    800725 <strnlen+0x10>
  800732:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	53                   	push   %ebx
  80073a:	8b 45 08             	mov    0x8(%ebp),%eax
  80073d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800740:	89 c2                	mov    %eax,%edx
  800742:	83 c2 01             	add    $0x1,%edx
  800745:	83 c1 01             	add    $0x1,%ecx
  800748:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80074f:	84 db                	test   %bl,%bl
  800751:	75 ef                	jne    800742 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800753:	5b                   	pop    %ebx
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	53                   	push   %ebx
  80075a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075d:	53                   	push   %ebx
  80075e:	e8 9a ff ff ff       	call   8006fd <strlen>
  800763:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	01 d8                	add    %ebx,%eax
  80076b:	50                   	push   %eax
  80076c:	e8 c5 ff ff ff       	call   800736 <strcpy>
	return dst;
}
  800771:	89 d8                	mov    %ebx,%eax
  800773:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	56                   	push   %esi
  80077c:	53                   	push   %ebx
  80077d:	8b 75 08             	mov    0x8(%ebp),%esi
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800783:	89 f3                	mov    %esi,%ebx
  800785:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800788:	89 f2                	mov    %esi,%edx
  80078a:	eb 0f                	jmp    80079b <strncpy+0x23>
		*dst++ = *src;
  80078c:	83 c2 01             	add    $0x1,%edx
  80078f:	0f b6 01             	movzbl (%ecx),%eax
  800792:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800795:	80 39 01             	cmpb   $0x1,(%ecx)
  800798:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079b:	39 da                	cmp    %ebx,%edx
  80079d:	75 ed                	jne    80078c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80079f:	89 f0                	mov    %esi,%eax
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	56                   	push   %esi
  8007a9:	53                   	push   %ebx
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	74 21                	je     8007da <strlcpy+0x35>
  8007b9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007bd:	89 f2                	mov    %esi,%edx
  8007bf:	eb 09                	jmp    8007ca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c1:	83 c2 01             	add    $0x1,%edx
  8007c4:	83 c1 01             	add    $0x1,%ecx
  8007c7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ca:	39 c2                	cmp    %eax,%edx
  8007cc:	74 09                	je     8007d7 <strlcpy+0x32>
  8007ce:	0f b6 19             	movzbl (%ecx),%ebx
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	75 ec                	jne    8007c1 <strlcpy+0x1c>
  8007d5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007da:	29 f0                	sub    %esi,%eax
}
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e9:	eb 06                	jmp    8007f1 <strcmp+0x11>
		p++, q++;
  8007eb:	83 c1 01             	add    $0x1,%ecx
  8007ee:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f1:	0f b6 01             	movzbl (%ecx),%eax
  8007f4:	84 c0                	test   %al,%al
  8007f6:	74 04                	je     8007fc <strcmp+0x1c>
  8007f8:	3a 02                	cmp    (%edx),%al
  8007fa:	74 ef                	je     8007eb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fc:	0f b6 c0             	movzbl %al,%eax
  8007ff:	0f b6 12             	movzbl (%edx),%edx
  800802:	29 d0                	sub    %edx,%eax
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	53                   	push   %ebx
  80080a:	8b 45 08             	mov    0x8(%ebp),%eax
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800810:	89 c3                	mov    %eax,%ebx
  800812:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800815:	eb 06                	jmp    80081d <strncmp+0x17>
		n--, p++, q++;
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081d:	39 d8                	cmp    %ebx,%eax
  80081f:	74 15                	je     800836 <strncmp+0x30>
  800821:	0f b6 08             	movzbl (%eax),%ecx
  800824:	84 c9                	test   %cl,%cl
  800826:	74 04                	je     80082c <strncmp+0x26>
  800828:	3a 0a                	cmp    (%edx),%cl
  80082a:	74 eb                	je     800817 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082c:	0f b6 00             	movzbl (%eax),%eax
  80082f:	0f b6 12             	movzbl (%edx),%edx
  800832:	29 d0                	sub    %edx,%eax
  800834:	eb 05                	jmp    80083b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083b:	5b                   	pop    %ebx
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800848:	eb 07                	jmp    800851 <strchr+0x13>
		if (*s == c)
  80084a:	38 ca                	cmp    %cl,%dl
  80084c:	74 0f                	je     80085d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	0f b6 10             	movzbl (%eax),%edx
  800854:	84 d2                	test   %dl,%dl
  800856:	75 f2                	jne    80084a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800869:	eb 03                	jmp    80086e <strfind+0xf>
  80086b:	83 c0 01             	add    $0x1,%eax
  80086e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800871:	38 ca                	cmp    %cl,%dl
  800873:	74 04                	je     800879 <strfind+0x1a>
  800875:	84 d2                	test   %dl,%dl
  800877:	75 f2                	jne    80086b <strfind+0xc>
			break;
	return (char *) s;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	57                   	push   %edi
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 7d 08             	mov    0x8(%ebp),%edi
  800884:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800887:	85 c9                	test   %ecx,%ecx
  800889:	74 36                	je     8008c1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800891:	75 28                	jne    8008bb <memset+0x40>
  800893:	f6 c1 03             	test   $0x3,%cl
  800896:	75 23                	jne    8008bb <memset+0x40>
		c &= 0xFF;
  800898:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089c:	89 d3                	mov    %edx,%ebx
  80089e:	c1 e3 08             	shl    $0x8,%ebx
  8008a1:	89 d6                	mov    %edx,%esi
  8008a3:	c1 e6 18             	shl    $0x18,%esi
  8008a6:	89 d0                	mov    %edx,%eax
  8008a8:	c1 e0 10             	shl    $0x10,%eax
  8008ab:	09 f0                	or     %esi,%eax
  8008ad:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008af:	89 d8                	mov    %ebx,%eax
  8008b1:	09 d0                	or     %edx,%eax
  8008b3:	c1 e9 02             	shr    $0x2,%ecx
  8008b6:	fc                   	cld    
  8008b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b9:	eb 06                	jmp    8008c1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008be:	fc                   	cld    
  8008bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c1:	89 f8                	mov    %edi,%eax
  8008c3:	5b                   	pop    %ebx
  8008c4:	5e                   	pop    %esi
  8008c5:	5f                   	pop    %edi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	57                   	push   %edi
  8008cc:	56                   	push   %esi
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d6:	39 c6                	cmp    %eax,%esi
  8008d8:	73 35                	jae    80090f <memmove+0x47>
  8008da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008dd:	39 d0                	cmp    %edx,%eax
  8008df:	73 2e                	jae    80090f <memmove+0x47>
		s += n;
		d += n;
  8008e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e4:	89 d6                	mov    %edx,%esi
  8008e6:	09 fe                	or     %edi,%esi
  8008e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ee:	75 13                	jne    800903 <memmove+0x3b>
  8008f0:	f6 c1 03             	test   $0x3,%cl
  8008f3:	75 0e                	jne    800903 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f5:	83 ef 04             	sub    $0x4,%edi
  8008f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
  8008fe:	fd                   	std    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb 09                	jmp    80090c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800903:	83 ef 01             	sub    $0x1,%edi
  800906:	8d 72 ff             	lea    -0x1(%edx),%esi
  800909:	fd                   	std    
  80090a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090c:	fc                   	cld    
  80090d:	eb 1d                	jmp    80092c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090f:	89 f2                	mov    %esi,%edx
  800911:	09 c2                	or     %eax,%edx
  800913:	f6 c2 03             	test   $0x3,%dl
  800916:	75 0f                	jne    800927 <memmove+0x5f>
  800918:	f6 c1 03             	test   $0x3,%cl
  80091b:	75 0a                	jne    800927 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80091d:	c1 e9 02             	shr    $0x2,%ecx
  800920:	89 c7                	mov    %eax,%edi
  800922:	fc                   	cld    
  800923:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800925:	eb 05                	jmp    80092c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800927:	89 c7                	mov    %eax,%edi
  800929:	fc                   	cld    
  80092a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800933:	ff 75 10             	pushl  0x10(%ebp)
  800936:	ff 75 0c             	pushl  0xc(%ebp)
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 87 ff ff ff       	call   8008c8 <memmove>
}
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094e:	89 c6                	mov    %eax,%esi
  800950:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800953:	eb 1a                	jmp    80096f <memcmp+0x2c>
		if (*s1 != *s2)
  800955:	0f b6 08             	movzbl (%eax),%ecx
  800958:	0f b6 1a             	movzbl (%edx),%ebx
  80095b:	38 d9                	cmp    %bl,%cl
  80095d:	74 0a                	je     800969 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80095f:	0f b6 c1             	movzbl %cl,%eax
  800962:	0f b6 db             	movzbl %bl,%ebx
  800965:	29 d8                	sub    %ebx,%eax
  800967:	eb 0f                	jmp    800978 <memcmp+0x35>
		s1++, s2++;
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096f:	39 f0                	cmp    %esi,%eax
  800971:	75 e2                	jne    800955 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	53                   	push   %ebx
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800983:	89 c1                	mov    %eax,%ecx
  800985:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800988:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098c:	eb 0a                	jmp    800998 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098e:	0f b6 10             	movzbl (%eax),%edx
  800991:	39 da                	cmp    %ebx,%edx
  800993:	74 07                	je     80099c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800995:	83 c0 01             	add    $0x1,%eax
  800998:	39 c8                	cmp    %ecx,%eax
  80099a:	72 f2                	jb     80098e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099c:	5b                   	pop    %ebx
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ab:	eb 03                	jmp    8009b0 <strtol+0x11>
		s++;
  8009ad:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b0:	0f b6 01             	movzbl (%ecx),%eax
  8009b3:	3c 20                	cmp    $0x20,%al
  8009b5:	74 f6                	je     8009ad <strtol+0xe>
  8009b7:	3c 09                	cmp    $0x9,%al
  8009b9:	74 f2                	je     8009ad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009bb:	3c 2b                	cmp    $0x2b,%al
  8009bd:	75 0a                	jne    8009c9 <strtol+0x2a>
		s++;
  8009bf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c7:	eb 11                	jmp    8009da <strtol+0x3b>
  8009c9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ce:	3c 2d                	cmp    $0x2d,%al
  8009d0:	75 08                	jne    8009da <strtol+0x3b>
		s++, neg = 1;
  8009d2:	83 c1 01             	add    $0x1,%ecx
  8009d5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009da:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e0:	75 15                	jne    8009f7 <strtol+0x58>
  8009e2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e5:	75 10                	jne    8009f7 <strtol+0x58>
  8009e7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009eb:	75 7c                	jne    800a69 <strtol+0xca>
		s += 2, base = 16;
  8009ed:	83 c1 02             	add    $0x2,%ecx
  8009f0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f5:	eb 16                	jmp    800a0d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009f7:	85 db                	test   %ebx,%ebx
  8009f9:	75 12                	jne    800a0d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a00:	80 39 30             	cmpb   $0x30,(%ecx)
  800a03:	75 08                	jne    800a0d <strtol+0x6e>
		s++, base = 8;
  800a05:	83 c1 01             	add    $0x1,%ecx
  800a08:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a12:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a15:	0f b6 11             	movzbl (%ecx),%edx
  800a18:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1b:	89 f3                	mov    %esi,%ebx
  800a1d:	80 fb 09             	cmp    $0x9,%bl
  800a20:	77 08                	ja     800a2a <strtol+0x8b>
			dig = *s - '0';
  800a22:	0f be d2             	movsbl %dl,%edx
  800a25:	83 ea 30             	sub    $0x30,%edx
  800a28:	eb 22                	jmp    800a4c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a2d:	89 f3                	mov    %esi,%ebx
  800a2f:	80 fb 19             	cmp    $0x19,%bl
  800a32:	77 08                	ja     800a3c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a34:	0f be d2             	movsbl %dl,%edx
  800a37:	83 ea 57             	sub    $0x57,%edx
  800a3a:	eb 10                	jmp    800a4c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a3f:	89 f3                	mov    %esi,%ebx
  800a41:	80 fb 19             	cmp    $0x19,%bl
  800a44:	77 16                	ja     800a5c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a46:	0f be d2             	movsbl %dl,%edx
  800a49:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4f:	7d 0b                	jge    800a5c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a51:	83 c1 01             	add    $0x1,%ecx
  800a54:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a58:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5a:	eb b9                	jmp    800a15 <strtol+0x76>

	if (endptr)
  800a5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a60:	74 0d                	je     800a6f <strtol+0xd0>
		*endptr = (char *) s;
  800a62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a65:	89 0e                	mov    %ecx,(%esi)
  800a67:	eb 06                	jmp    800a6f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a69:	85 db                	test   %ebx,%ebx
  800a6b:	74 98                	je     800a05 <strtol+0x66>
  800a6d:	eb 9e                	jmp    800a0d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a6f:	89 c2                	mov    %eax,%edx
  800a71:	f7 da                	neg    %edx
  800a73:	85 ff                	test   %edi,%edi
  800a75:	0f 45 c2             	cmovne %edx,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8e:	89 c3                	mov    %eax,%ebx
  800a90:	89 c7                	mov    %eax,%edi
  800a92:	89 c6                	mov    %eax,%esi
  800a94:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800aab:	89 d1                	mov    %edx,%ecx
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	89 d7                	mov    %edx,%edi
  800ab1:	89 d6                	mov    %edx,%esi
  800ab3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac8:	b8 03 00 00 00       	mov    $0x3,%eax
  800acd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad0:	89 cb                	mov    %ecx,%ebx
  800ad2:	89 cf                	mov    %ecx,%edi
  800ad4:	89 ce                	mov    %ecx,%esi
  800ad6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	7e 17                	jle    800af3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	50                   	push   %eax
  800ae0:	6a 03                	push   $0x3
  800ae2:	68 1f 25 80 00       	push   $0x80251f
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 3c 25 80 00       	push   $0x80253c
  800aee:	e8 3e 13 00 00       	call   801e31 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0b:	89 d1                	mov    %edx,%ecx
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	89 d7                	mov    %edx,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_yield>:

void
sys_yield(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	be 00 00 00 00       	mov    $0x0,%esi
  800b47:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	89 f7                	mov    %esi,%edi
  800b57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 17                	jle    800b74 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	50                   	push   %eax
  800b61:	6a 04                	push   $0x4
  800b63:	68 1f 25 80 00       	push   $0x80251f
  800b68:	6a 23                	push   $0x23
  800b6a:	68 3c 25 80 00       	push   $0x80253c
  800b6f:	e8 bd 12 00 00       	call   801e31 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b96:	8b 75 18             	mov    0x18(%ebp),%esi
  800b99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 17                	jle    800bb6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 05                	push   $0x5
  800ba5:	68 1f 25 80 00       	push   $0x80251f
  800baa:	6a 23                	push   $0x23
  800bac:	68 3c 25 80 00       	push   $0x80253c
  800bb1:	e8 7b 12 00 00       	call   801e31 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcc:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 df                	mov    %ebx,%edi
  800bd9:	89 de                	mov    %ebx,%esi
  800bdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 17                	jle    800bf8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 06                	push   $0x6
  800be7:	68 1f 25 80 00       	push   $0x80251f
  800bec:	6a 23                	push   $0x23
  800bee:	68 3c 25 80 00       	push   $0x80253c
  800bf3:	e8 39 12 00 00       	call   801e31 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 df                	mov    %ebx,%edi
  800c1b:	89 de                	mov    %ebx,%esi
  800c1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 08                	push   $0x8
  800c29:	68 1f 25 80 00       	push   $0x80251f
  800c2e:	6a 23                	push   $0x23
  800c30:	68 3c 25 80 00       	push   $0x80253c
  800c35:	e8 f7 11 00 00       	call   801e31 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c50:	b8 09 00 00 00       	mov    $0x9,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 df                	mov    %ebx,%edi
  800c5d:	89 de                	mov    %ebx,%esi
  800c5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 09                	push   $0x9
  800c6b:	68 1f 25 80 00       	push   $0x80251f
  800c70:	6a 23                	push   $0x23
  800c72:	68 3c 25 80 00       	push   $0x80253c
  800c77:	e8 b5 11 00 00       	call   801e31 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 df                	mov    %ebx,%edi
  800c9f:	89 de                	mov    %ebx,%esi
  800ca1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 0a                	push   $0xa
  800cad:	68 1f 25 80 00       	push   $0x80251f
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 3c 25 80 00       	push   $0x80253c
  800cb9:	e8 73 11 00 00       	call   801e31 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 cb                	mov    %ecx,%ebx
  800d01:	89 cf                	mov    %ecx,%edi
  800d03:	89 ce                	mov    %ecx,%esi
  800d05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 0d                	push   $0xd
  800d11:	68 1f 25 80 00       	push   $0x80251f
  800d16:	6a 23                	push   $0x23
  800d18:	68 3c 25 80 00       	push   $0x80253c
  800d1d:	e8 0f 11 00 00       	call   801e31 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 04             	sub    $0x4,%esp
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  800d34:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  800d36:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  800d39:	89 da                	mov    %ebx,%edx
  800d3b:	c1 ea 0c             	shr    $0xc,%edx
  800d3e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  800d45:	a8 02                	test   $0x2,%al
  800d47:	75 12                	jne    800d5b <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  800d49:	50                   	push   %eax
  800d4a:	68 4c 25 80 00       	push   $0x80254c
  800d4f:	6a 21                	push   $0x21
  800d51:	68 6d 25 80 00       	push   $0x80256d
  800d56:	e8 d6 10 00 00       	call   801e31 <_panic>
	   } else if (!(pte & PTE_COW)) {
  800d5b:	f6 c6 08             	test   $0x8,%dh
  800d5e:	75 14                	jne    800d74 <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	68 78 25 80 00       	push   $0x802578
  800d68:	6a 23                	push   $0x23
  800d6a:	68 6d 25 80 00       	push   $0x80256d
  800d6f:	e8 bd 10 00 00       	call   801e31 <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  800d74:	83 ec 04             	sub    $0x4,%esp
  800d77:	6a 07                	push   $0x7
  800d79:	68 00 00 40 00       	push   $0x400000
  800d7e:	6a 00                	push   $0x0
  800d80:	e8 b4 fd ff ff       	call   800b39 <sys_page_alloc>
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	79 12                	jns    800d9e <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  800d8c:	50                   	push   %eax
  800d8d:	68 95 25 80 00       	push   $0x802595
  800d92:	6a 2e                	push   $0x2e
  800d94:	68 6d 25 80 00       	push   $0x80256d
  800d99:	e8 93 10 00 00       	call   801e31 <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800d9e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800da4:	83 ec 04             	sub    $0x4,%esp
  800da7:	68 00 10 00 00       	push   $0x1000
  800dac:	53                   	push   %ebx
  800dad:	68 00 00 40 00       	push   $0x400000
  800db2:	e8 11 fb ff ff       	call   8008c8 <memmove>
	   if ((r = sys_page_map(0,
  800db7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dbe:	53                   	push   %ebx
  800dbf:	6a 00                	push   $0x0
  800dc1:	68 00 00 40 00       	push   $0x400000
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 af fd ff ff       	call   800b7c <sys_page_map>
  800dcd:	83 c4 20             	add    $0x20,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	79 12                	jns    800de6 <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  800dd4:	50                   	push   %eax
  800dd5:	68 a8 25 80 00       	push   $0x8025a8
  800dda:	6a 36                	push   $0x36
  800ddc:	68 6d 25 80 00       	push   $0x80256d
  800de1:	e8 4b 10 00 00       	call   801e31 <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  800de6:	83 ec 08             	sub    $0x8,%esp
  800de9:	68 00 00 40 00       	push   $0x400000
  800dee:	6a 00                	push   $0x0
  800df0:	e8 c9 fd ff ff       	call   800bbe <sys_page_unmap>
  800df5:	83 c4 10             	add    $0x10,%esp
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	79 12                	jns    800e0e <pgfault+0xe4>
			 panic("unmap %e", r);
  800dfc:	50                   	push   %eax
  800dfd:	68 b8 25 80 00       	push   $0x8025b8
  800e02:	6a 39                	push   $0x39
  800e04:	68 6d 25 80 00       	push   $0x80256d
  800e09:	e8 23 10 00 00       	call   801e31 <_panic>
	   }
}
  800e0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    

00800e13 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  800e1c:	68 2a 0d 80 00       	push   $0x800d2a
  800e21:	e8 51 10 00 00       	call   801e77 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e26:	b8 07 00 00 00       	mov    $0x7,%eax
  800e2b:	cd 30                	int    $0x30
  800e2d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e30:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  800e33:	83 c4 10             	add    $0x10,%esp
  800e36:	85 c0                	test   %eax,%eax
  800e38:	79 15                	jns    800e4f <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  800e3a:	50                   	push   %eax
  800e3b:	68 c1 25 80 00       	push   $0x8025c1
  800e40:	68 81 00 00 00       	push   $0x81
  800e45:	68 6d 25 80 00       	push   $0x80256d
  800e4a:	e8 e2 0f 00 00       	call   801e31 <_panic>
  800e4f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800e56:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  800e5a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e5e:	75 1c                	jne    800e7c <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  800e60:	e8 96 fc ff ff       	call   800afb <sys_getenvid>
  800e65:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e6a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e6d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e72:	a3 04 40 80 00       	mov    %eax,0x804004
			 return envid;
  800e77:	e9 71 01 00 00       	jmp    800fed <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  800e7c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800e7f:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800e86:	a8 01                	test   $0x1,%al
  800e88:	0f 84 18 01 00 00    	je     800fa6 <fork+0x193>
  800e8e:	89 fb                	mov    %edi,%ebx
  800e90:	c1 e3 0a             	shl    $0xa,%ebx
  800e93:	c1 e7 16             	shl    $0x16,%edi
  800e96:	be 00 00 00 00       	mov    $0x0,%esi
  800e9b:	e9 f4 00 00 00       	jmp    800f94 <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  800ea0:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800ea6:	0f 84 dc 00 00 00    	je     800f88 <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  800eac:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800eb2:	0f 87 cc 00 00 00    	ja     800f84 <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  800eb8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ebf:	a8 01                	test   $0x1,%al
  800ec1:	0f 84 c1 00 00 00    	je     800f88 <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  800ec7:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  800ece:	a9 02 08 00 00       	test   $0x802,%eax
  800ed3:	74 05                	je     800eda <fork+0xc7>
  800ed5:	f6 c4 04             	test   $0x4,%ah
  800ed8:	74 3a                	je     800f14 <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  800eda:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800ee0:	8b 52 48             	mov    0x48(%edx),%edx
  800ee3:	83 ec 0c             	sub    $0xc,%esp
  800ee6:	25 07 0e 00 00       	and    $0xe07,%eax
  800eeb:	50                   	push   %eax
  800eec:	57                   	push   %edi
  800eed:	ff 75 dc             	pushl  -0x24(%ebp)
  800ef0:	57                   	push   %edi
  800ef1:	52                   	push   %edx
  800ef2:	e8 85 fc ff ff       	call   800b7c <sys_page_map>
  800ef7:	83 c4 20             	add    $0x20,%esp
  800efa:	85 c0                	test   %eax,%eax
  800efc:	0f 89 86 00 00 00    	jns    800f88 <fork+0x175>
				    panic("sys_page_map: %e", r);
  800f02:	50                   	push   %eax
  800f03:	68 d1 25 80 00       	push   $0x8025d1
  800f08:	6a 52                	push   $0x52
  800f0a:	68 6d 25 80 00       	push   $0x80256d
  800f0f:	e8 1d 0f 00 00       	call   801e31 <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  800f14:	25 05 06 00 00       	and    $0x605,%eax
  800f19:	80 cc 08             	or     $0x8,%ah
  800f1c:	89 c1                	mov    %eax,%ecx
  800f1e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f21:	a1 04 40 80 00       	mov    0x804004,%eax
  800f26:	8b 40 48             	mov    0x48(%eax),%eax
  800f29:	83 ec 0c             	sub    $0xc,%esp
  800f2c:	51                   	push   %ecx
  800f2d:	57                   	push   %edi
  800f2e:	ff 75 dc             	pushl  -0x24(%ebp)
  800f31:	57                   	push   %edi
  800f32:	50                   	push   %eax
  800f33:	e8 44 fc ff ff       	call   800b7c <sys_page_map>
  800f38:	83 c4 20             	add    $0x20,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	79 12                	jns    800f51 <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  800f3f:	50                   	push   %eax
  800f40:	68 d1 25 80 00       	push   $0x8025d1
  800f45:	6a 5d                	push   $0x5d
  800f47:	68 6d 25 80 00       	push   $0x80256d
  800f4c:	e8 e0 0e 00 00       	call   801e31 <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  800f51:	a1 04 40 80 00       	mov    0x804004,%eax
  800f56:	8b 50 48             	mov    0x48(%eax),%edx
  800f59:	8b 40 48             	mov    0x48(%eax),%eax
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f62:	57                   	push   %edi
  800f63:	52                   	push   %edx
  800f64:	57                   	push   %edi
  800f65:	50                   	push   %eax
  800f66:	e8 11 fc ff ff       	call   800b7c <sys_page_map>
  800f6b:	83 c4 20             	add    $0x20,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	79 16                	jns    800f88 <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  800f72:	50                   	push   %eax
  800f73:	68 d1 25 80 00       	push   $0x8025d1
  800f78:	6a 63                	push   $0x63
  800f7a:	68 6d 25 80 00       	push   $0x80256d
  800f7f:	e8 ad 0e 00 00       	call   801e31 <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  800f84:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  800f88:	83 c6 01             	add    $0x1,%esi
  800f8b:	83 c3 01             	add    $0x1,%ebx
  800f8e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  800f94:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  800f9a:	7f 0a                	jg     800fa6 <fork+0x193>
  800f9c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fa0:	0f 85 fa fe ff ff    	jne    800ea0 <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  800fa6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  800faa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fad:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800fb2:	7f 0a                	jg     800fbe <fork+0x1ab>
  800fb4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fb8:	0f 85 be fe ff ff    	jne    800e7c <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fbe:	83 ec 08             	sub    $0x8,%esp
  800fc1:	68 d0 1e 80 00       	push   $0x801ed0
  800fc6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800fc9:	56                   	push   %esi
  800fca:	e8 b5 fc ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  800fcf:	83 c4 0c             	add    $0xc,%esp
  800fd2:	6a 06                	push   $0x6
  800fd4:	68 00 f0 bf ee       	push   $0xeebff000
  800fd9:	56                   	push   %esi
  800fda:	e8 5a fb ff ff       	call   800b39 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  800fdf:	83 c4 08             	add    $0x8,%esp
  800fe2:	6a 02                	push   $0x2
  800fe4:	56                   	push   %esi
  800fe5:	e8 16 fc ff ff       	call   800c00 <sys_env_set_status>

	   return envid;
  800fea:	83 c4 10             	add    $0x10,%esp
}
  800fed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ff0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff3:	5b                   	pop    %ebx
  800ff4:	5e                   	pop    %esi
  800ff5:	5f                   	pop    %edi
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    

00800ff8 <sfork>:
// Challenge!
	   int
sfork(void)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  800ffe:	68 e2 25 80 00       	push   $0x8025e2
  801003:	68 a7 00 00 00       	push   $0xa7
  801008:	68 6d 25 80 00       	push   $0x80256d
  80100d:	e8 1f 0e 00 00       	call   801e31 <_panic>

00801012 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	56                   	push   %esi
  801016:	53                   	push   %ebx
  801017:	8b 75 08             	mov    0x8(%ebp),%esi
  80101a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801020:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801022:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801027:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  80102a:	83 ec 0c             	sub    $0xc,%esp
  80102d:	50                   	push   %eax
  80102e:	e8 b6 fc ff ff       	call   800ce9 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801033:	83 c4 10             	add    $0x10,%esp
  801036:	85 c0                	test   %eax,%eax
  801038:	78 0e                	js     801048 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  80103a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801040:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801043:	8b 52 78             	mov    0x78(%edx),%edx
  801046:	eb 0a                	jmp    801052 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801048:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  80104d:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801052:	85 f6                	test   %esi,%esi
  801054:	74 02                	je     801058 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801056:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801058:	85 db                	test   %ebx,%ebx
  80105a:	74 02                	je     80105e <ipc_recv+0x4c>
			 *perm_store = s_perm;
  80105c:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 08                	js     80106a <ipc_recv+0x58>
  801062:	a1 04 40 80 00       	mov    0x804004,%eax
  801067:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  80106a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80106d:	5b                   	pop    %ebx
  80106e:	5e                   	pop    %esi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	57                   	push   %edi
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80107d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801080:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801083:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801085:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  80108a:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  80108d:	ff 75 14             	pushl  0x14(%ebp)
  801090:	53                   	push   %ebx
  801091:	56                   	push   %esi
  801092:	57                   	push   %edi
  801093:	e8 2e fc ff ff       	call   800cc6 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80109e:	75 07                	jne    8010a7 <ipc_send+0x36>
				    sys_yield();
  8010a0:	e8 75 fa ff ff       	call   800b1a <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  8010a5:	eb e6                	jmp    80108d <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	74 12                	je     8010bd <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  8010ab:	50                   	push   %eax
  8010ac:	68 f8 25 80 00       	push   $0x8025f8
  8010b1:	6a 4b                	push   $0x4b
  8010b3:	68 0c 26 80 00       	push   $0x80260c
  8010b8:	e8 74 0d 00 00       	call   801e31 <_panic>
			 }
	   }
}
  8010bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5e                   	pop    %esi
  8010c2:	5f                   	pop    %edi
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  8010cb:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  8010d0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010d3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010d9:	8b 52 50             	mov    0x50(%edx),%edx
  8010dc:	39 ca                	cmp    %ecx,%edx
  8010de:	75 0d                	jne    8010ed <ipc_find_env+0x28>
				    return envs[i].env_id;
  8010e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010e8:	8b 40 48             	mov    0x48(%eax),%eax
  8010eb:	eb 0f                	jmp    8010fc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  8010ed:	83 c0 01             	add    $0x1,%eax
  8010f0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010f5:	75 d9                	jne    8010d0 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  8010f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801101:	8b 45 08             	mov    0x8(%ebp),%eax
  801104:	05 00 00 00 30       	add    $0x30000000,%eax
  801109:	c1 e8 0c             	shr    $0xc,%eax
}
  80110c:	5d                   	pop    %ebp
  80110d:	c3                   	ret    

0080110e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
  801114:	05 00 00 00 30       	add    $0x30000000,%eax
  801119:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80111e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801130:	89 c2                	mov    %eax,%edx
  801132:	c1 ea 16             	shr    $0x16,%edx
  801135:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80113c:	f6 c2 01             	test   $0x1,%dl
  80113f:	74 11                	je     801152 <fd_alloc+0x2d>
  801141:	89 c2                	mov    %eax,%edx
  801143:	c1 ea 0c             	shr    $0xc,%edx
  801146:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114d:	f6 c2 01             	test   $0x1,%dl
  801150:	75 09                	jne    80115b <fd_alloc+0x36>
			*fd_store = fd;
  801152:	89 01                	mov    %eax,(%ecx)
			return 0;
  801154:	b8 00 00 00 00       	mov    $0x0,%eax
  801159:	eb 17                	jmp    801172 <fd_alloc+0x4d>
  80115b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801160:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801165:	75 c9                	jne    801130 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801167:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80116d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80117a:	83 f8 1f             	cmp    $0x1f,%eax
  80117d:	77 36                	ja     8011b5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80117f:	c1 e0 0c             	shl    $0xc,%eax
  801182:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801187:	89 c2                	mov    %eax,%edx
  801189:	c1 ea 16             	shr    $0x16,%edx
  80118c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801193:	f6 c2 01             	test   $0x1,%dl
  801196:	74 24                	je     8011bc <fd_lookup+0x48>
  801198:	89 c2                	mov    %eax,%edx
  80119a:	c1 ea 0c             	shr    $0xc,%edx
  80119d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a4:	f6 c2 01             	test   $0x1,%dl
  8011a7:	74 1a                	je     8011c3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ac:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b3:	eb 13                	jmp    8011c8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ba:	eb 0c                	jmp    8011c8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c1:	eb 05                	jmp    8011c8 <fd_lookup+0x54>
  8011c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    

008011ca <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	83 ec 08             	sub    $0x8,%esp
  8011d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d3:	ba 94 26 80 00       	mov    $0x802694,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011d8:	eb 13                	jmp    8011ed <dev_lookup+0x23>
  8011da:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011dd:	39 08                	cmp    %ecx,(%eax)
  8011df:	75 0c                	jne    8011ed <dev_lookup+0x23>
			*dev = devtab[i];
  8011e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011eb:	eb 2e                	jmp    80121b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011ed:	8b 02                	mov    (%edx),%eax
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	75 e7                	jne    8011da <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f8:	8b 40 48             	mov    0x48(%eax),%eax
  8011fb:	83 ec 04             	sub    $0x4,%esp
  8011fe:	51                   	push   %ecx
  8011ff:	50                   	push   %eax
  801200:	68 18 26 80 00       	push   $0x802618
  801205:	e8 a7 ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  80120a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    

0080121d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	56                   	push   %esi
  801221:	53                   	push   %ebx
  801222:	83 ec 10             	sub    $0x10,%esp
  801225:	8b 75 08             	mov    0x8(%ebp),%esi
  801228:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80122b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801235:	c1 e8 0c             	shr    $0xc,%eax
  801238:	50                   	push   %eax
  801239:	e8 36 ff ff ff       	call   801174 <fd_lookup>
  80123e:	83 c4 08             	add    $0x8,%esp
  801241:	85 c0                	test   %eax,%eax
  801243:	78 05                	js     80124a <fd_close+0x2d>
	    || fd != fd2)
  801245:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801248:	74 0c                	je     801256 <fd_close+0x39>
		return (must_exist ? r : 0);
  80124a:	84 db                	test   %bl,%bl
  80124c:	ba 00 00 00 00       	mov    $0x0,%edx
  801251:	0f 44 c2             	cmove  %edx,%eax
  801254:	eb 41                	jmp    801297 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801256:	83 ec 08             	sub    $0x8,%esp
  801259:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	ff 36                	pushl  (%esi)
  80125f:	e8 66 ff ff ff       	call   8011ca <dev_lookup>
  801264:	89 c3                	mov    %eax,%ebx
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 1a                	js     801287 <fd_close+0x6a>
		if (dev->dev_close)
  80126d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801270:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801273:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801278:	85 c0                	test   %eax,%eax
  80127a:	74 0b                	je     801287 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80127c:	83 ec 0c             	sub    $0xc,%esp
  80127f:	56                   	push   %esi
  801280:	ff d0                	call   *%eax
  801282:	89 c3                	mov    %eax,%ebx
  801284:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	56                   	push   %esi
  80128b:	6a 00                	push   $0x0
  80128d:	e8 2c f9 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	89 d8                	mov    %ebx,%eax
}
  801297:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129a:	5b                   	pop    %ebx
  80129b:	5e                   	pop    %esi
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	ff 75 08             	pushl  0x8(%ebp)
  8012ab:	e8 c4 fe ff ff       	call   801174 <fd_lookup>
  8012b0:	83 c4 08             	add    $0x8,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 10                	js     8012c7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012b7:	83 ec 08             	sub    $0x8,%esp
  8012ba:	6a 01                	push   $0x1
  8012bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8012bf:	e8 59 ff ff ff       	call   80121d <fd_close>
  8012c4:	83 c4 10             	add    $0x10,%esp
}
  8012c7:	c9                   	leave  
  8012c8:	c3                   	ret    

008012c9 <close_all>:

void
close_all(void)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d5:	83 ec 0c             	sub    $0xc,%esp
  8012d8:	53                   	push   %ebx
  8012d9:	e8 c0 ff ff ff       	call   80129e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012de:	83 c3 01             	add    $0x1,%ebx
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	83 fb 20             	cmp    $0x20,%ebx
  8012e7:	75 ec                	jne    8012d5 <close_all+0xc>
		close(i);
}
  8012e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    

008012ee <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 2c             	sub    $0x2c,%esp
  8012f7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012fd:	50                   	push   %eax
  8012fe:	ff 75 08             	pushl  0x8(%ebp)
  801301:	e8 6e fe ff ff       	call   801174 <fd_lookup>
  801306:	83 c4 08             	add    $0x8,%esp
  801309:	85 c0                	test   %eax,%eax
  80130b:	0f 88 c1 00 00 00    	js     8013d2 <dup+0xe4>
		return r;
	close(newfdnum);
  801311:	83 ec 0c             	sub    $0xc,%esp
  801314:	56                   	push   %esi
  801315:	e8 84 ff ff ff       	call   80129e <close>

	newfd = INDEX2FD(newfdnum);
  80131a:	89 f3                	mov    %esi,%ebx
  80131c:	c1 e3 0c             	shl    $0xc,%ebx
  80131f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801325:	83 c4 04             	add    $0x4,%esp
  801328:	ff 75 e4             	pushl  -0x1c(%ebp)
  80132b:	e8 de fd ff ff       	call   80110e <fd2data>
  801330:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801332:	89 1c 24             	mov    %ebx,(%esp)
  801335:	e8 d4 fd ff ff       	call   80110e <fd2data>
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801340:	89 f8                	mov    %edi,%eax
  801342:	c1 e8 16             	shr    $0x16,%eax
  801345:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80134c:	a8 01                	test   $0x1,%al
  80134e:	74 37                	je     801387 <dup+0x99>
  801350:	89 f8                	mov    %edi,%eax
  801352:	c1 e8 0c             	shr    $0xc,%eax
  801355:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80135c:	f6 c2 01             	test   $0x1,%dl
  80135f:	74 26                	je     801387 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801361:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	25 07 0e 00 00       	and    $0xe07,%eax
  801370:	50                   	push   %eax
  801371:	ff 75 d4             	pushl  -0x2c(%ebp)
  801374:	6a 00                	push   $0x0
  801376:	57                   	push   %edi
  801377:	6a 00                	push   $0x0
  801379:	e8 fe f7 ff ff       	call   800b7c <sys_page_map>
  80137e:	89 c7                	mov    %eax,%edi
  801380:	83 c4 20             	add    $0x20,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 2e                	js     8013b5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801387:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80138a:	89 d0                	mov    %edx,%eax
  80138c:	c1 e8 0c             	shr    $0xc,%eax
  80138f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	25 07 0e 00 00       	and    $0xe07,%eax
  80139e:	50                   	push   %eax
  80139f:	53                   	push   %ebx
  8013a0:	6a 00                	push   $0x0
  8013a2:	52                   	push   %edx
  8013a3:	6a 00                	push   $0x0
  8013a5:	e8 d2 f7 ff ff       	call   800b7c <sys_page_map>
  8013aa:	89 c7                	mov    %eax,%edi
  8013ac:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013af:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b1:	85 ff                	test   %edi,%edi
  8013b3:	79 1d                	jns    8013d2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	53                   	push   %ebx
  8013b9:	6a 00                	push   $0x0
  8013bb:	e8 fe f7 ff ff       	call   800bbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013c0:	83 c4 08             	add    $0x8,%esp
  8013c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c6:	6a 00                	push   $0x0
  8013c8:	e8 f1 f7 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	89 f8                	mov    %edi,%eax
}
  8013d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5e                   	pop    %esi
  8013d7:	5f                   	pop    %edi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	53                   	push   %ebx
  8013de:	83 ec 14             	sub    $0x14,%esp
  8013e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e7:	50                   	push   %eax
  8013e8:	53                   	push   %ebx
  8013e9:	e8 86 fd ff ff       	call   801174 <fd_lookup>
  8013ee:	83 c4 08             	add    $0x8,%esp
  8013f1:	89 c2                	mov    %eax,%edx
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 6d                	js     801464 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fd:	50                   	push   %eax
  8013fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801401:	ff 30                	pushl  (%eax)
  801403:	e8 c2 fd ff ff       	call   8011ca <dev_lookup>
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 4c                	js     80145b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80140f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801412:	8b 42 08             	mov    0x8(%edx),%eax
  801415:	83 e0 03             	and    $0x3,%eax
  801418:	83 f8 01             	cmp    $0x1,%eax
  80141b:	75 21                	jne    80143e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80141d:	a1 04 40 80 00       	mov    0x804004,%eax
  801422:	8b 40 48             	mov    0x48(%eax),%eax
  801425:	83 ec 04             	sub    $0x4,%esp
  801428:	53                   	push   %ebx
  801429:	50                   	push   %eax
  80142a:	68 59 26 80 00       	push   $0x802659
  80142f:	e8 7d ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80143c:	eb 26                	jmp    801464 <read+0x8a>
	}
	if (!dev->dev_read)
  80143e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801441:	8b 40 08             	mov    0x8(%eax),%eax
  801444:	85 c0                	test   %eax,%eax
  801446:	74 17                	je     80145f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801448:	83 ec 04             	sub    $0x4,%esp
  80144b:	ff 75 10             	pushl  0x10(%ebp)
  80144e:	ff 75 0c             	pushl  0xc(%ebp)
  801451:	52                   	push   %edx
  801452:	ff d0                	call   *%eax
  801454:	89 c2                	mov    %eax,%edx
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	eb 09                	jmp    801464 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145b:	89 c2                	mov    %eax,%edx
  80145d:	eb 05                	jmp    801464 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80145f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801464:	89 d0                	mov    %edx,%eax
  801466:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	57                   	push   %edi
  80146f:	56                   	push   %esi
  801470:	53                   	push   %ebx
  801471:	83 ec 0c             	sub    $0xc,%esp
  801474:	8b 7d 08             	mov    0x8(%ebp),%edi
  801477:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80147a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80147f:	eb 21                	jmp    8014a2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801481:	83 ec 04             	sub    $0x4,%esp
  801484:	89 f0                	mov    %esi,%eax
  801486:	29 d8                	sub    %ebx,%eax
  801488:	50                   	push   %eax
  801489:	89 d8                	mov    %ebx,%eax
  80148b:	03 45 0c             	add    0xc(%ebp),%eax
  80148e:	50                   	push   %eax
  80148f:	57                   	push   %edi
  801490:	e8 45 ff ff ff       	call   8013da <read>
		if (m < 0)
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 10                	js     8014ac <readn+0x41>
			return m;
		if (m == 0)
  80149c:	85 c0                	test   %eax,%eax
  80149e:	74 0a                	je     8014aa <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a0:	01 c3                	add    %eax,%ebx
  8014a2:	39 f3                	cmp    %esi,%ebx
  8014a4:	72 db                	jb     801481 <readn+0x16>
  8014a6:	89 d8                	mov    %ebx,%eax
  8014a8:	eb 02                	jmp    8014ac <readn+0x41>
  8014aa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014af:	5b                   	pop    %ebx
  8014b0:	5e                   	pop    %esi
  8014b1:	5f                   	pop    %edi
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    

008014b4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	53                   	push   %ebx
  8014b8:	83 ec 14             	sub    $0x14,%esp
  8014bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	53                   	push   %ebx
  8014c3:	e8 ac fc ff ff       	call   801174 <fd_lookup>
  8014c8:	83 c4 08             	add    $0x8,%esp
  8014cb:	89 c2                	mov    %eax,%edx
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 68                	js     801539 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014db:	ff 30                	pushl  (%eax)
  8014dd:	e8 e8 fc ff ff       	call   8011ca <dev_lookup>
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 47                	js     801530 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f0:	75 21                	jne    801513 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8014f7:	8b 40 48             	mov    0x48(%eax),%eax
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	53                   	push   %ebx
  8014fe:	50                   	push   %eax
  8014ff:	68 75 26 80 00       	push   $0x802675
  801504:	e8 a8 ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801511:	eb 26                	jmp    801539 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801513:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801516:	8b 52 0c             	mov    0xc(%edx),%edx
  801519:	85 d2                	test   %edx,%edx
  80151b:	74 17                	je     801534 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80151d:	83 ec 04             	sub    $0x4,%esp
  801520:	ff 75 10             	pushl  0x10(%ebp)
  801523:	ff 75 0c             	pushl  0xc(%ebp)
  801526:	50                   	push   %eax
  801527:	ff d2                	call   *%edx
  801529:	89 c2                	mov    %eax,%edx
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	eb 09                	jmp    801539 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801530:	89 c2                	mov    %eax,%edx
  801532:	eb 05                	jmp    801539 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801534:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801539:	89 d0                	mov    %edx,%eax
  80153b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <seek>:

int
seek(int fdnum, off_t offset)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801546:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	ff 75 08             	pushl  0x8(%ebp)
  80154d:	e8 22 fc ff ff       	call   801174 <fd_lookup>
  801552:	83 c4 08             	add    $0x8,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	78 0e                	js     801567 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801559:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80155c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801562:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801567:	c9                   	leave  
  801568:	c3                   	ret    

00801569 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	53                   	push   %ebx
  80156d:	83 ec 14             	sub    $0x14,%esp
  801570:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801573:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	53                   	push   %ebx
  801578:	e8 f7 fb ff ff       	call   801174 <fd_lookup>
  80157d:	83 c4 08             	add    $0x8,%esp
  801580:	89 c2                	mov    %eax,%edx
  801582:	85 c0                	test   %eax,%eax
  801584:	78 65                	js     8015eb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158c:	50                   	push   %eax
  80158d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801590:	ff 30                	pushl  (%eax)
  801592:	e8 33 fc ff ff       	call   8011ca <dev_lookup>
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 44                	js     8015e2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a5:	75 21                	jne    8015c8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015a7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ac:	8b 40 48             	mov    0x48(%eax),%eax
  8015af:	83 ec 04             	sub    $0x4,%esp
  8015b2:	53                   	push   %ebx
  8015b3:	50                   	push   %eax
  8015b4:	68 38 26 80 00       	push   $0x802638
  8015b9:	e8 f3 eb ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c6:	eb 23                	jmp    8015eb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cb:	8b 52 18             	mov    0x18(%edx),%edx
  8015ce:	85 d2                	test   %edx,%edx
  8015d0:	74 14                	je     8015e6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	ff 75 0c             	pushl  0xc(%ebp)
  8015d8:	50                   	push   %eax
  8015d9:	ff d2                	call   *%edx
  8015db:	89 c2                	mov    %eax,%edx
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	eb 09                	jmp    8015eb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e2:	89 c2                	mov    %eax,%edx
  8015e4:	eb 05                	jmp    8015eb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015eb:	89 d0                	mov    %edx,%eax
  8015ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 14             	sub    $0x14,%esp
  8015f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ff:	50                   	push   %eax
  801600:	ff 75 08             	pushl  0x8(%ebp)
  801603:	e8 6c fb ff ff       	call   801174 <fd_lookup>
  801608:	83 c4 08             	add    $0x8,%esp
  80160b:	89 c2                	mov    %eax,%edx
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 58                	js     801669 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161b:	ff 30                	pushl  (%eax)
  80161d:	e8 a8 fb ff ff       	call   8011ca <dev_lookup>
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	85 c0                	test   %eax,%eax
  801627:	78 37                	js     801660 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801629:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801630:	74 32                	je     801664 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801632:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801635:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80163c:	00 00 00 
	stat->st_isdir = 0;
  80163f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801646:	00 00 00 
	stat->st_dev = dev;
  801649:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80164f:	83 ec 08             	sub    $0x8,%esp
  801652:	53                   	push   %ebx
  801653:	ff 75 f0             	pushl  -0x10(%ebp)
  801656:	ff 50 14             	call   *0x14(%eax)
  801659:	89 c2                	mov    %eax,%edx
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	eb 09                	jmp    801669 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801660:	89 c2                	mov    %eax,%edx
  801662:	eb 05                	jmp    801669 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801664:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801669:	89 d0                	mov    %edx,%eax
  80166b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166e:	c9                   	leave  
  80166f:	c3                   	ret    

00801670 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	56                   	push   %esi
  801674:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	6a 00                	push   $0x0
  80167a:	ff 75 08             	pushl  0x8(%ebp)
  80167d:	e8 2c 02 00 00       	call   8018ae <open>
  801682:	89 c3                	mov    %eax,%ebx
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	85 c0                	test   %eax,%eax
  801689:	78 1b                	js     8016a6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	ff 75 0c             	pushl  0xc(%ebp)
  801691:	50                   	push   %eax
  801692:	e8 5b ff ff ff       	call   8015f2 <fstat>
  801697:	89 c6                	mov    %eax,%esi
	close(fd);
  801699:	89 1c 24             	mov    %ebx,(%esp)
  80169c:	e8 fd fb ff ff       	call   80129e <close>
	return r;
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	89 f0                	mov    %esi,%eax
}
  8016a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5e                   	pop    %esi
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	56                   	push   %esi
  8016b1:	53                   	push   %ebx
  8016b2:	89 c6                	mov    %eax,%esi
  8016b4:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  8016b6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016bd:	75 12                	jne    8016d1 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  8016bf:	83 ec 0c             	sub    $0xc,%esp
  8016c2:	6a 01                	push   $0x1
  8016c4:	e8 fc f9 ff ff       	call   8010c5 <ipc_find_env>
  8016c9:	a3 00 40 80 00       	mov    %eax,0x804000
  8016ce:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016d1:	6a 07                	push   $0x7
  8016d3:	68 00 50 80 00       	push   $0x805000
  8016d8:	56                   	push   %esi
  8016d9:	ff 35 00 40 80 00    	pushl  0x804000
  8016df:	e8 8d f9 ff ff       	call   801071 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  8016e4:	83 c4 0c             	add    $0xc,%esp
  8016e7:	6a 00                	push   $0x0
  8016e9:	53                   	push   %ebx
  8016ea:	6a 00                	push   $0x0
  8016ec:	e8 21 f9 ff ff       	call   801012 <ipc_recv>
}
  8016f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f4:	5b                   	pop    %ebx
  8016f5:	5e                   	pop    %esi
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    

008016f8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801701:	8b 40 0c             	mov    0xc(%eax),%eax
  801704:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  801709:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170c:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  801711:	ba 00 00 00 00       	mov    $0x0,%edx
  801716:	b8 02 00 00 00       	mov    $0x2,%eax
  80171b:	e8 8d ff ff ff       	call   8016ad <fsipc>
}
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801728:	8b 45 08             	mov    0x8(%ebp),%eax
  80172b:	8b 40 0c             	mov    0xc(%eax),%eax
  80172e:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  801733:	ba 00 00 00 00       	mov    $0x0,%edx
  801738:	b8 06 00 00 00       	mov    $0x6,%eax
  80173d:	e8 6b ff ff ff       	call   8016ad <fsipc>
}
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	83 ec 04             	sub    $0x4,%esp
  80174b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80174e:	8b 45 08             	mov    0x8(%ebp),%eax
  801751:	8b 40 0c             	mov    0xc(%eax),%eax
  801754:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801759:	ba 00 00 00 00       	mov    $0x0,%edx
  80175e:	b8 05 00 00 00       	mov    $0x5,%eax
  801763:	e8 45 ff ff ff       	call   8016ad <fsipc>
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 2c                	js     801798 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176c:	83 ec 08             	sub    $0x8,%esp
  80176f:	68 00 50 80 00       	push   $0x805000
  801774:	53                   	push   %ebx
  801775:	e8 bc ef ff ff       	call   800736 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  80177a:	a1 80 50 80 00       	mov    0x805080,%eax
  80177f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801785:	a1 84 50 80 00       	mov    0x805084,%eax
  80178a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179b:	c9                   	leave  
  80179c:	c3                   	ret    

0080179d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	53                   	push   %ebx
  8017a1:	83 ec 08             	sub    $0x8,%esp
  8017a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ad:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  8017b2:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  8017b8:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8017be:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8017c3:	0f 46 c3             	cmovbe %ebx,%eax
  8017c6:	50                   	push   %eax
  8017c7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ca:	68 08 50 80 00       	push   $0x805008
  8017cf:	e8 f4 f0 ff ff       	call   8008c8 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  8017d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d9:	b8 04 00 00 00       	mov    $0x4,%eax
  8017de:	e8 ca fe ff ff       	call   8016ad <fsipc>
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 3d                	js     801827 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  8017ea:	39 c3                	cmp    %eax,%ebx
  8017ec:	73 19                	jae    801807 <devfile_write+0x6a>
  8017ee:	68 a4 26 80 00       	push   $0x8026a4
  8017f3:	68 ab 26 80 00       	push   $0x8026ab
  8017f8:	68 9a 00 00 00       	push   $0x9a
  8017fd:	68 c0 26 80 00       	push   $0x8026c0
  801802:	e8 2a 06 00 00       	call   801e31 <_panic>
	   assert (r <= bytes_written);
  801807:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80180c:	7e 19                	jle    801827 <devfile_write+0x8a>
  80180e:	68 cb 26 80 00       	push   $0x8026cb
  801813:	68 ab 26 80 00       	push   $0x8026ab
  801818:	68 9b 00 00 00       	push   $0x9b
  80181d:	68 c0 26 80 00       	push   $0x8026c0
  801822:	e8 0a 06 00 00       	call   801e31 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801827:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182a:	c9                   	leave  
  80182b:	c3                   	ret    

0080182c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	56                   	push   %esi
  801830:	53                   	push   %ebx
  801831:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  801834:	8b 45 08             	mov    0x8(%ebp),%eax
  801837:	8b 40 0c             	mov    0xc(%eax),%eax
  80183a:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  80183f:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801845:	ba 00 00 00 00       	mov    $0x0,%edx
  80184a:	b8 03 00 00 00       	mov    $0x3,%eax
  80184f:	e8 59 fe ff ff       	call   8016ad <fsipc>
  801854:	89 c3                	mov    %eax,%ebx
  801856:	85 c0                	test   %eax,%eax
  801858:	78 4b                	js     8018a5 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  80185a:	39 c6                	cmp    %eax,%esi
  80185c:	73 16                	jae    801874 <devfile_read+0x48>
  80185e:	68 a4 26 80 00       	push   $0x8026a4
  801863:	68 ab 26 80 00       	push   $0x8026ab
  801868:	6a 7c                	push   $0x7c
  80186a:	68 c0 26 80 00       	push   $0x8026c0
  80186f:	e8 bd 05 00 00       	call   801e31 <_panic>
	   assert(r <= PGSIZE);
  801874:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801879:	7e 16                	jle    801891 <devfile_read+0x65>
  80187b:	68 de 26 80 00       	push   $0x8026de
  801880:	68 ab 26 80 00       	push   $0x8026ab
  801885:	6a 7d                	push   $0x7d
  801887:	68 c0 26 80 00       	push   $0x8026c0
  80188c:	e8 a0 05 00 00       	call   801e31 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801891:	83 ec 04             	sub    $0x4,%esp
  801894:	50                   	push   %eax
  801895:	68 00 50 80 00       	push   $0x805000
  80189a:	ff 75 0c             	pushl  0xc(%ebp)
  80189d:	e8 26 f0 ff ff       	call   8008c8 <memmove>
	   return r;
  8018a2:	83 c4 10             	add    $0x10,%esp
}
  8018a5:	89 d8                	mov    %ebx,%eax
  8018a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018aa:	5b                   	pop    %ebx
  8018ab:	5e                   	pop    %esi
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	53                   	push   %ebx
  8018b2:	83 ec 20             	sub    $0x20,%esp
  8018b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  8018b8:	53                   	push   %ebx
  8018b9:	e8 3f ee ff ff       	call   8006fd <strlen>
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018c6:	7f 67                	jg     80192f <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8018c8:	83 ec 0c             	sub    $0xc,%esp
  8018cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ce:	50                   	push   %eax
  8018cf:	e8 51 f8 ff ff       	call   801125 <fd_alloc>
  8018d4:	83 c4 10             	add    $0x10,%esp
			 return r;
  8018d7:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	78 57                	js     801934 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	53                   	push   %ebx
  8018e1:	68 00 50 80 00       	push   $0x805000
  8018e6:	e8 4b ee ff ff       	call   800736 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  8018eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ee:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8018fb:	e8 ad fd ff ff       	call   8016ad <fsipc>
  801900:	89 c3                	mov    %eax,%ebx
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	85 c0                	test   %eax,%eax
  801907:	79 14                	jns    80191d <open+0x6f>
			 fd_close(fd, 0);
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	6a 00                	push   $0x0
  80190e:	ff 75 f4             	pushl  -0xc(%ebp)
  801911:	e8 07 f9 ff ff       	call   80121d <fd_close>
			 return r;
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	89 da                	mov    %ebx,%edx
  80191b:	eb 17                	jmp    801934 <open+0x86>
	   }

	   return fd2num(fd);
  80191d:	83 ec 0c             	sub    $0xc,%esp
  801920:	ff 75 f4             	pushl  -0xc(%ebp)
  801923:	e8 d6 f7 ff ff       	call   8010fe <fd2num>
  801928:	89 c2                	mov    %eax,%edx
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	eb 05                	jmp    801934 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  80192f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801934:	89 d0                	mov    %edx,%eax
  801936:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801939:	c9                   	leave  
  80193a:	c3                   	ret    

0080193b <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801941:	ba 00 00 00 00       	mov    $0x0,%edx
  801946:	b8 08 00 00 00       	mov    $0x8,%eax
  80194b:	e8 5d fd ff ff       	call   8016ad <fsipc>
}
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	56                   	push   %esi
  801956:	53                   	push   %ebx
  801957:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80195a:	83 ec 0c             	sub    $0xc,%esp
  80195d:	ff 75 08             	pushl  0x8(%ebp)
  801960:	e8 a9 f7 ff ff       	call   80110e <fd2data>
  801965:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801967:	83 c4 08             	add    $0x8,%esp
  80196a:	68 ea 26 80 00       	push   $0x8026ea
  80196f:	53                   	push   %ebx
  801970:	e8 c1 ed ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801975:	8b 46 04             	mov    0x4(%esi),%eax
  801978:	2b 06                	sub    (%esi),%eax
  80197a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801980:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801987:	00 00 00 
	stat->st_dev = &devpipe;
  80198a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801991:	30 80 00 
	return 0;
}
  801994:	b8 00 00 00 00       	mov    $0x0,%eax
  801999:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199c:	5b                   	pop    %ebx
  80199d:	5e                   	pop    %esi
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    

008019a0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	53                   	push   %ebx
  8019a4:	83 ec 0c             	sub    $0xc,%esp
  8019a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019aa:	53                   	push   %ebx
  8019ab:	6a 00                	push   $0x0
  8019ad:	e8 0c f2 ff ff       	call   800bbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019b2:	89 1c 24             	mov    %ebx,(%esp)
  8019b5:	e8 54 f7 ff ff       	call   80110e <fd2data>
  8019ba:	83 c4 08             	add    $0x8,%esp
  8019bd:	50                   	push   %eax
  8019be:	6a 00                	push   $0x0
  8019c0:	e8 f9 f1 ff ff       	call   800bbe <sys_page_unmap>
}
  8019c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	57                   	push   %edi
  8019ce:	56                   	push   %esi
  8019cf:	53                   	push   %ebx
  8019d0:	83 ec 1c             	sub    $0x1c,%esp
  8019d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019d6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8019dd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8019e6:	e8 0b 05 00 00       	call   801ef6 <pageref>
  8019eb:	89 c3                	mov    %eax,%ebx
  8019ed:	89 3c 24             	mov    %edi,(%esp)
  8019f0:	e8 01 05 00 00       	call   801ef6 <pageref>
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	39 c3                	cmp    %eax,%ebx
  8019fa:	0f 94 c1             	sete   %cl
  8019fd:	0f b6 c9             	movzbl %cl,%ecx
  801a00:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a03:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a09:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a0c:	39 ce                	cmp    %ecx,%esi
  801a0e:	74 1b                	je     801a2b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a10:	39 c3                	cmp    %eax,%ebx
  801a12:	75 c4                	jne    8019d8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a14:	8b 42 58             	mov    0x58(%edx),%eax
  801a17:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a1a:	50                   	push   %eax
  801a1b:	56                   	push   %esi
  801a1c:	68 f1 26 80 00       	push   $0x8026f1
  801a21:	e8 8b e7 ff ff       	call   8001b1 <cprintf>
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	eb ad                	jmp    8019d8 <_pipeisclosed+0xe>
	}
}
  801a2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	5f                   	pop    %edi
  801a34:	5d                   	pop    %ebp
  801a35:	c3                   	ret    

00801a36 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	57                   	push   %edi
  801a3a:	56                   	push   %esi
  801a3b:	53                   	push   %ebx
  801a3c:	83 ec 28             	sub    $0x28,%esp
  801a3f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a42:	56                   	push   %esi
  801a43:	e8 c6 f6 ff ff       	call   80110e <fd2data>
  801a48:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	bf 00 00 00 00       	mov    $0x0,%edi
  801a52:	eb 4b                	jmp    801a9f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a54:	89 da                	mov    %ebx,%edx
  801a56:	89 f0                	mov    %esi,%eax
  801a58:	e8 6d ff ff ff       	call   8019ca <_pipeisclosed>
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	75 48                	jne    801aa9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a61:	e8 b4 f0 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a66:	8b 43 04             	mov    0x4(%ebx),%eax
  801a69:	8b 0b                	mov    (%ebx),%ecx
  801a6b:	8d 51 20             	lea    0x20(%ecx),%edx
  801a6e:	39 d0                	cmp    %edx,%eax
  801a70:	73 e2                	jae    801a54 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a75:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a79:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a7c:	89 c2                	mov    %eax,%edx
  801a7e:	c1 fa 1f             	sar    $0x1f,%edx
  801a81:	89 d1                	mov    %edx,%ecx
  801a83:	c1 e9 1b             	shr    $0x1b,%ecx
  801a86:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a89:	83 e2 1f             	and    $0x1f,%edx
  801a8c:	29 ca                	sub    %ecx,%edx
  801a8e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a92:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a96:	83 c0 01             	add    $0x1,%eax
  801a99:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9c:	83 c7 01             	add    $0x1,%edi
  801a9f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aa2:	75 c2                	jne    801a66 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aa4:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa7:	eb 05                	jmp    801aae <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5e                   	pop    %esi
  801ab3:	5f                   	pop    %edi
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    

00801ab6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	57                   	push   %edi
  801aba:	56                   	push   %esi
  801abb:	53                   	push   %ebx
  801abc:	83 ec 18             	sub    $0x18,%esp
  801abf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ac2:	57                   	push   %edi
  801ac3:	e8 46 f6 ff ff       	call   80110e <fd2data>
  801ac8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad2:	eb 3d                	jmp    801b11 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ad4:	85 db                	test   %ebx,%ebx
  801ad6:	74 04                	je     801adc <devpipe_read+0x26>
				return i;
  801ad8:	89 d8                	mov    %ebx,%eax
  801ada:	eb 44                	jmp    801b20 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801adc:	89 f2                	mov    %esi,%edx
  801ade:	89 f8                	mov    %edi,%eax
  801ae0:	e8 e5 fe ff ff       	call   8019ca <_pipeisclosed>
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	75 32                	jne    801b1b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ae9:	e8 2c f0 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801aee:	8b 06                	mov    (%esi),%eax
  801af0:	3b 46 04             	cmp    0x4(%esi),%eax
  801af3:	74 df                	je     801ad4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801af5:	99                   	cltd   
  801af6:	c1 ea 1b             	shr    $0x1b,%edx
  801af9:	01 d0                	add    %edx,%eax
  801afb:	83 e0 1f             	and    $0x1f,%eax
  801afe:	29 d0                	sub    %edx,%eax
  801b00:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b08:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b0b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0e:	83 c3 01             	add    $0x1,%ebx
  801b11:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b14:	75 d8                	jne    801aee <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b16:	8b 45 10             	mov    0x10(%ebp),%eax
  801b19:	eb 05                	jmp    801b20 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5e                   	pop    %esi
  801b25:	5f                   	pop    %edi
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	56                   	push   %esi
  801b2c:	53                   	push   %ebx
  801b2d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b33:	50                   	push   %eax
  801b34:	e8 ec f5 ff ff       	call   801125 <fd_alloc>
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	89 c2                	mov    %eax,%edx
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	0f 88 2c 01 00 00    	js     801c72 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b46:	83 ec 04             	sub    $0x4,%esp
  801b49:	68 07 04 00 00       	push   $0x407
  801b4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b51:	6a 00                	push   $0x0
  801b53:	e8 e1 ef ff ff       	call   800b39 <sys_page_alloc>
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	89 c2                	mov    %eax,%edx
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	0f 88 0d 01 00 00    	js     801c72 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b65:	83 ec 0c             	sub    $0xc,%esp
  801b68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b6b:	50                   	push   %eax
  801b6c:	e8 b4 f5 ff ff       	call   801125 <fd_alloc>
  801b71:	89 c3                	mov    %eax,%ebx
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	85 c0                	test   %eax,%eax
  801b78:	0f 88 e2 00 00 00    	js     801c60 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7e:	83 ec 04             	sub    $0x4,%esp
  801b81:	68 07 04 00 00       	push   $0x407
  801b86:	ff 75 f0             	pushl  -0x10(%ebp)
  801b89:	6a 00                	push   $0x0
  801b8b:	e8 a9 ef ff ff       	call   800b39 <sys_page_alloc>
  801b90:	89 c3                	mov    %eax,%ebx
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	85 c0                	test   %eax,%eax
  801b97:	0f 88 c3 00 00 00    	js     801c60 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b9d:	83 ec 0c             	sub    $0xc,%esp
  801ba0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba3:	e8 66 f5 ff ff       	call   80110e <fd2data>
  801ba8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801baa:	83 c4 0c             	add    $0xc,%esp
  801bad:	68 07 04 00 00       	push   $0x407
  801bb2:	50                   	push   %eax
  801bb3:	6a 00                	push   $0x0
  801bb5:	e8 7f ef ff ff       	call   800b39 <sys_page_alloc>
  801bba:	89 c3                	mov    %eax,%ebx
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	0f 88 89 00 00 00    	js     801c50 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc7:	83 ec 0c             	sub    $0xc,%esp
  801bca:	ff 75 f0             	pushl  -0x10(%ebp)
  801bcd:	e8 3c f5 ff ff       	call   80110e <fd2data>
  801bd2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bd9:	50                   	push   %eax
  801bda:	6a 00                	push   $0x0
  801bdc:	56                   	push   %esi
  801bdd:	6a 00                	push   $0x0
  801bdf:	e8 98 ef ff ff       	call   800b7c <sys_page_map>
  801be4:	89 c3                	mov    %eax,%ebx
  801be6:	83 c4 20             	add    $0x20,%esp
  801be9:	85 c0                	test   %eax,%eax
  801beb:	78 55                	js     801c42 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bed:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c02:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c0b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c10:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c17:	83 ec 0c             	sub    $0xc,%esp
  801c1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1d:	e8 dc f4 ff ff       	call   8010fe <fd2num>
  801c22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c25:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c27:	83 c4 04             	add    $0x4,%esp
  801c2a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2d:	e8 cc f4 ff ff       	call   8010fe <fd2num>
  801c32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c35:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c40:	eb 30                	jmp    801c72 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c42:	83 ec 08             	sub    $0x8,%esp
  801c45:	56                   	push   %esi
  801c46:	6a 00                	push   $0x0
  801c48:	e8 71 ef ff ff       	call   800bbe <sys_page_unmap>
  801c4d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c50:	83 ec 08             	sub    $0x8,%esp
  801c53:	ff 75 f0             	pushl  -0x10(%ebp)
  801c56:	6a 00                	push   $0x0
  801c58:	e8 61 ef ff ff       	call   800bbe <sys_page_unmap>
  801c5d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c60:	83 ec 08             	sub    $0x8,%esp
  801c63:	ff 75 f4             	pushl  -0xc(%ebp)
  801c66:	6a 00                	push   $0x0
  801c68:	e8 51 ef ff ff       	call   800bbe <sys_page_unmap>
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c72:	89 d0                	mov    %edx,%eax
  801c74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c77:	5b                   	pop    %ebx
  801c78:	5e                   	pop    %esi
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    

00801c7b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c84:	50                   	push   %eax
  801c85:	ff 75 08             	pushl  0x8(%ebp)
  801c88:	e8 e7 f4 ff ff       	call   801174 <fd_lookup>
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	85 c0                	test   %eax,%eax
  801c92:	78 18                	js     801cac <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9a:	e8 6f f4 ff ff       	call   80110e <fd2data>
	return _pipeisclosed(fd, p);
  801c9f:	89 c2                	mov    %eax,%edx
  801ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca4:	e8 21 fd ff ff       	call   8019ca <_pipeisclosed>
  801ca9:	83 c4 10             	add    $0x10,%esp
}
  801cac:	c9                   	leave  
  801cad:	c3                   	ret    

00801cae <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    

00801cb8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cbe:	68 09 27 80 00       	push   $0x802709
  801cc3:	ff 75 0c             	pushl  0xc(%ebp)
  801cc6:	e8 6b ea ff ff       	call   800736 <strcpy>
	return 0;
}
  801ccb:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd0:	c9                   	leave  
  801cd1:	c3                   	ret    

00801cd2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	57                   	push   %edi
  801cd6:	56                   	push   %esi
  801cd7:	53                   	push   %ebx
  801cd8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cde:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ce3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce9:	eb 2d                	jmp    801d18 <devcons_write+0x46>
		m = n - tot;
  801ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cee:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cf0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cf3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cf8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cfb:	83 ec 04             	sub    $0x4,%esp
  801cfe:	53                   	push   %ebx
  801cff:	03 45 0c             	add    0xc(%ebp),%eax
  801d02:	50                   	push   %eax
  801d03:	57                   	push   %edi
  801d04:	e8 bf eb ff ff       	call   8008c8 <memmove>
		sys_cputs(buf, m);
  801d09:	83 c4 08             	add    $0x8,%esp
  801d0c:	53                   	push   %ebx
  801d0d:	57                   	push   %edi
  801d0e:	e8 6a ed ff ff       	call   800a7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d13:	01 de                	add    %ebx,%esi
  801d15:	83 c4 10             	add    $0x10,%esp
  801d18:	89 f0                	mov    %esi,%eax
  801d1a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d1d:	72 cc                	jb     801ceb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5e                   	pop    %esi
  801d24:	5f                   	pop    %edi
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    

00801d27 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	83 ec 08             	sub    $0x8,%esp
  801d2d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d32:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d36:	74 2a                	je     801d62 <devcons_read+0x3b>
  801d38:	eb 05                	jmp    801d3f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d3a:	e8 db ed ff ff       	call   800b1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d3f:	e8 57 ed ff ff       	call   800a9b <sys_cgetc>
  801d44:	85 c0                	test   %eax,%eax
  801d46:	74 f2                	je     801d3a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	78 16                	js     801d62 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d4c:	83 f8 04             	cmp    $0x4,%eax
  801d4f:	74 0c                	je     801d5d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d51:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d54:	88 02                	mov    %al,(%edx)
	return 1;
  801d56:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5b:	eb 05                	jmp    801d62 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d5d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d62:	c9                   	leave  
  801d63:	c3                   	ret    

00801d64 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d70:	6a 01                	push   $0x1
  801d72:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d75:	50                   	push   %eax
  801d76:	e8 02 ed ff ff       	call   800a7d <sys_cputs>
}
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    

00801d80 <getchar>:

int
getchar(void)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d86:	6a 01                	push   $0x1
  801d88:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d8b:	50                   	push   %eax
  801d8c:	6a 00                	push   $0x0
  801d8e:	e8 47 f6 ff ff       	call   8013da <read>
	if (r < 0)
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	85 c0                	test   %eax,%eax
  801d98:	78 0f                	js     801da9 <getchar+0x29>
		return r;
	if (r < 1)
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	7e 06                	jle    801da4 <getchar+0x24>
		return -E_EOF;
	return c;
  801d9e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801da2:	eb 05                	jmp    801da9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801da4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    

00801dab <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db4:	50                   	push   %eax
  801db5:	ff 75 08             	pushl  0x8(%ebp)
  801db8:	e8 b7 f3 ff ff       	call   801174 <fd_lookup>
  801dbd:	83 c4 10             	add    $0x10,%esp
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	78 11                	js     801dd5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dcd:	39 10                	cmp    %edx,(%eax)
  801dcf:	0f 94 c0             	sete   %al
  801dd2:	0f b6 c0             	movzbl %al,%eax
}
  801dd5:	c9                   	leave  
  801dd6:	c3                   	ret    

00801dd7 <opencons>:

int
opencons(void)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ddd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de0:	50                   	push   %eax
  801de1:	e8 3f f3 ff ff       	call   801125 <fd_alloc>
  801de6:	83 c4 10             	add    $0x10,%esp
		return r;
  801de9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801deb:	85 c0                	test   %eax,%eax
  801ded:	78 3e                	js     801e2d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801def:	83 ec 04             	sub    $0x4,%esp
  801df2:	68 07 04 00 00       	push   $0x407
  801df7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfa:	6a 00                	push   $0x0
  801dfc:	e8 38 ed ff ff       	call   800b39 <sys_page_alloc>
  801e01:	83 c4 10             	add    $0x10,%esp
		return r;
  801e04:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e06:	85 c0                	test   %eax,%eax
  801e08:	78 23                	js     801e2d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e0a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e13:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e18:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e1f:	83 ec 0c             	sub    $0xc,%esp
  801e22:	50                   	push   %eax
  801e23:	e8 d6 f2 ff ff       	call   8010fe <fd2num>
  801e28:	89 c2                	mov    %eax,%edx
  801e2a:	83 c4 10             	add    $0x10,%esp
}
  801e2d:	89 d0                	mov    %edx,%eax
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	56                   	push   %esi
  801e35:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e36:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e39:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e3f:	e8 b7 ec ff ff       	call   800afb <sys_getenvid>
  801e44:	83 ec 0c             	sub    $0xc,%esp
  801e47:	ff 75 0c             	pushl  0xc(%ebp)
  801e4a:	ff 75 08             	pushl  0x8(%ebp)
  801e4d:	56                   	push   %esi
  801e4e:	50                   	push   %eax
  801e4f:	68 18 27 80 00       	push   $0x802718
  801e54:	e8 58 e3 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e59:	83 c4 18             	add    $0x18,%esp
  801e5c:	53                   	push   %ebx
  801e5d:	ff 75 10             	pushl  0x10(%ebp)
  801e60:	e8 fb e2 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801e65:	c7 04 24 02 27 80 00 	movl   $0x802702,(%esp)
  801e6c:	e8 40 e3 ff ff       	call   8001b1 <cprintf>
  801e71:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e74:	cc                   	int3   
  801e75:	eb fd                	jmp    801e74 <_panic+0x43>

00801e77 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  801e7d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e84:	75 2a                	jne    801eb0 <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801e86:	83 ec 04             	sub    $0x4,%esp
  801e89:	6a 06                	push   $0x6
  801e8b:	68 00 f0 bf ee       	push   $0xeebff000
  801e90:	6a 00                	push   $0x0
  801e92:	e8 a2 ec ff ff       	call   800b39 <sys_page_alloc>
			 if (a < 0)
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	79 12                	jns    801eb0 <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801e9e:	50                   	push   %eax
  801e9f:	68 3c 27 80 00       	push   $0x80273c
  801ea4:	6a 21                	push   $0x21
  801ea6:	68 56 27 80 00       	push   $0x802756
  801eab:	e8 81 ff ff ff       	call   801e31 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  801eb0:	e8 46 ec ff ff       	call   800afb <sys_getenvid>
  801eb5:	83 ec 08             	sub    $0x8,%esp
  801eb8:	68 d0 1e 80 00       	push   $0x801ed0
  801ebd:	50                   	push   %eax
  801ebe:	e8 c1 ed ff ff       	call   800c84 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  801ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec6:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ecb:	83 c4 10             	add    $0x10,%esp
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  801ed0:	54                   	push   %esp
movl _pgfault_handler, %eax
  801ed1:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  801ed6:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  801ed8:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  801edb:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  801edf:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  801ee3:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  801ee6:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  801eea:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  801eec:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  801eef:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  801ef0:	83 c4 04             	add    $0x4,%esp
popfl
  801ef3:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  801ef4:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  801ef5:	c3                   	ret    

00801ef6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801efc:	89 d0                	mov    %edx,%eax
  801efe:	c1 e8 16             	shr    $0x16,%eax
  801f01:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f08:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f0d:	f6 c1 01             	test   $0x1,%cl
  801f10:	74 1d                	je     801f2f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f12:	c1 ea 0c             	shr    $0xc,%edx
  801f15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f1c:	f6 c2 01             	test   $0x1,%dl
  801f1f:	74 0e                	je     801f2f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f21:	c1 ea 0c             	shr    $0xc,%edx
  801f24:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f2b:	ef 
  801f2c:	0f b7 c0             	movzwl %ax,%eax
}
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    
  801f31:	66 90                	xchg   %ax,%ax
  801f33:	66 90                	xchg   %ax,%ax
  801f35:	66 90                	xchg   %ax,%ax
  801f37:	66 90                	xchg   %ax,%ax
  801f39:	66 90                	xchg   %ax,%ax
  801f3b:	66 90                	xchg   %ax,%ax
  801f3d:	66 90                	xchg   %ax,%ax
  801f3f:	90                   	nop

00801f40 <__udivdi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 1c             	sub    $0x1c,%esp
  801f47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f57:	85 f6                	test   %esi,%esi
  801f59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f5d:	89 ca                	mov    %ecx,%edx
  801f5f:	89 f8                	mov    %edi,%eax
  801f61:	75 3d                	jne    801fa0 <__udivdi3+0x60>
  801f63:	39 cf                	cmp    %ecx,%edi
  801f65:	0f 87 c5 00 00 00    	ja     802030 <__udivdi3+0xf0>
  801f6b:	85 ff                	test   %edi,%edi
  801f6d:	89 fd                	mov    %edi,%ebp
  801f6f:	75 0b                	jne    801f7c <__udivdi3+0x3c>
  801f71:	b8 01 00 00 00       	mov    $0x1,%eax
  801f76:	31 d2                	xor    %edx,%edx
  801f78:	f7 f7                	div    %edi
  801f7a:	89 c5                	mov    %eax,%ebp
  801f7c:	89 c8                	mov    %ecx,%eax
  801f7e:	31 d2                	xor    %edx,%edx
  801f80:	f7 f5                	div    %ebp
  801f82:	89 c1                	mov    %eax,%ecx
  801f84:	89 d8                	mov    %ebx,%eax
  801f86:	89 cf                	mov    %ecx,%edi
  801f88:	f7 f5                	div    %ebp
  801f8a:	89 c3                	mov    %eax,%ebx
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	89 fa                	mov    %edi,%edx
  801f90:	83 c4 1c             	add    $0x1c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
  801f98:	90                   	nop
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	39 ce                	cmp    %ecx,%esi
  801fa2:	77 74                	ja     802018 <__udivdi3+0xd8>
  801fa4:	0f bd fe             	bsr    %esi,%edi
  801fa7:	83 f7 1f             	xor    $0x1f,%edi
  801faa:	0f 84 98 00 00 00    	je     802048 <__udivdi3+0x108>
  801fb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	89 c5                	mov    %eax,%ebp
  801fb9:	29 fb                	sub    %edi,%ebx
  801fbb:	d3 e6                	shl    %cl,%esi
  801fbd:	89 d9                	mov    %ebx,%ecx
  801fbf:	d3 ed                	shr    %cl,%ebp
  801fc1:	89 f9                	mov    %edi,%ecx
  801fc3:	d3 e0                	shl    %cl,%eax
  801fc5:	09 ee                	or     %ebp,%esi
  801fc7:	89 d9                	mov    %ebx,%ecx
  801fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fcd:	89 d5                	mov    %edx,%ebp
  801fcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fd3:	d3 ed                	shr    %cl,%ebp
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e2                	shl    %cl,%edx
  801fd9:	89 d9                	mov    %ebx,%ecx
  801fdb:	d3 e8                	shr    %cl,%eax
  801fdd:	09 c2                	or     %eax,%edx
  801fdf:	89 d0                	mov    %edx,%eax
  801fe1:	89 ea                	mov    %ebp,%edx
  801fe3:	f7 f6                	div    %esi
  801fe5:	89 d5                	mov    %edx,%ebp
  801fe7:	89 c3                	mov    %eax,%ebx
  801fe9:	f7 64 24 0c          	mull   0xc(%esp)
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	72 10                	jb     802001 <__udivdi3+0xc1>
  801ff1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e6                	shl    %cl,%esi
  801ff9:	39 c6                	cmp    %eax,%esi
  801ffb:	73 07                	jae    802004 <__udivdi3+0xc4>
  801ffd:	39 d5                	cmp    %edx,%ebp
  801fff:	75 03                	jne    802004 <__udivdi3+0xc4>
  802001:	83 eb 01             	sub    $0x1,%ebx
  802004:	31 ff                	xor    %edi,%edi
  802006:	89 d8                	mov    %ebx,%eax
  802008:	89 fa                	mov    %edi,%edx
  80200a:	83 c4 1c             	add    $0x1c,%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5f                   	pop    %edi
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
  802012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802018:	31 ff                	xor    %edi,%edi
  80201a:	31 db                	xor    %ebx,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	89 d8                	mov    %ebx,%eax
  802032:	f7 f7                	div    %edi
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 c3                	mov    %eax,%ebx
  802038:	89 d8                	mov    %ebx,%eax
  80203a:	89 fa                	mov    %edi,%edx
  80203c:	83 c4 1c             	add    $0x1c,%esp
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5f                   	pop    %edi
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    
  802044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802048:	39 ce                	cmp    %ecx,%esi
  80204a:	72 0c                	jb     802058 <__udivdi3+0x118>
  80204c:	31 db                	xor    %ebx,%ebx
  80204e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802052:	0f 87 34 ff ff ff    	ja     801f8c <__udivdi3+0x4c>
  802058:	bb 01 00 00 00       	mov    $0x1,%ebx
  80205d:	e9 2a ff ff ff       	jmp    801f8c <__udivdi3+0x4c>
  802062:	66 90                	xchg   %ax,%ax
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__umoddi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80207b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80207f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 d2                	test   %edx,%edx
  802089:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80208d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802091:	89 f3                	mov    %esi,%ebx
  802093:	89 3c 24             	mov    %edi,(%esp)
  802096:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209a:	75 1c                	jne    8020b8 <__umoddi3+0x48>
  80209c:	39 f7                	cmp    %esi,%edi
  80209e:	76 50                	jbe    8020f0 <__umoddi3+0x80>
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	f7 f7                	div    %edi
  8020a6:	89 d0                	mov    %edx,%eax
  8020a8:	31 d2                	xor    %edx,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	39 f2                	cmp    %esi,%edx
  8020ba:	89 d0                	mov    %edx,%eax
  8020bc:	77 52                	ja     802110 <__umoddi3+0xa0>
  8020be:	0f bd ea             	bsr    %edx,%ebp
  8020c1:	83 f5 1f             	xor    $0x1f,%ebp
  8020c4:	75 5a                	jne    802120 <__umoddi3+0xb0>
  8020c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ca:	0f 82 e0 00 00 00    	jb     8021b0 <__umoddi3+0x140>
  8020d0:	39 0c 24             	cmp    %ecx,(%esp)
  8020d3:	0f 86 d7 00 00 00    	jbe    8021b0 <__umoddi3+0x140>
  8020d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020e1:	83 c4 1c             	add    $0x1c,%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	85 ff                	test   %edi,%edi
  8020f2:	89 fd                	mov    %edi,%ebp
  8020f4:	75 0b                	jne    802101 <__umoddi3+0x91>
  8020f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	f7 f7                	div    %edi
  8020ff:	89 c5                	mov    %eax,%ebp
  802101:	89 f0                	mov    %esi,%eax
  802103:	31 d2                	xor    %edx,%edx
  802105:	f7 f5                	div    %ebp
  802107:	89 c8                	mov    %ecx,%eax
  802109:	f7 f5                	div    %ebp
  80210b:	89 d0                	mov    %edx,%eax
  80210d:	eb 99                	jmp    8020a8 <__umoddi3+0x38>
  80210f:	90                   	nop
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	83 c4 1c             	add    $0x1c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	8b 34 24             	mov    (%esp),%esi
  802123:	bf 20 00 00 00       	mov    $0x20,%edi
  802128:	89 e9                	mov    %ebp,%ecx
  80212a:	29 ef                	sub    %ebp,%edi
  80212c:	d3 e0                	shl    %cl,%eax
  80212e:	89 f9                	mov    %edi,%ecx
  802130:	89 f2                	mov    %esi,%edx
  802132:	d3 ea                	shr    %cl,%edx
  802134:	89 e9                	mov    %ebp,%ecx
  802136:	09 c2                	or     %eax,%edx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 14 24             	mov    %edx,(%esp)
  80213d:	89 f2                	mov    %esi,%edx
  80213f:	d3 e2                	shl    %cl,%edx
  802141:	89 f9                	mov    %edi,%ecx
  802143:	89 54 24 04          	mov    %edx,0x4(%esp)
  802147:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	89 e9                	mov    %ebp,%ecx
  80214f:	89 c6                	mov    %eax,%esi
  802151:	d3 e3                	shl    %cl,%ebx
  802153:	89 f9                	mov    %edi,%ecx
  802155:	89 d0                	mov    %edx,%eax
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	09 d8                	or     %ebx,%eax
  80215d:	89 d3                	mov    %edx,%ebx
  80215f:	89 f2                	mov    %esi,%edx
  802161:	f7 34 24             	divl   (%esp)
  802164:	89 d6                	mov    %edx,%esi
  802166:	d3 e3                	shl    %cl,%ebx
  802168:	f7 64 24 04          	mull   0x4(%esp)
  80216c:	39 d6                	cmp    %edx,%esi
  80216e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802172:	89 d1                	mov    %edx,%ecx
  802174:	89 c3                	mov    %eax,%ebx
  802176:	72 08                	jb     802180 <__umoddi3+0x110>
  802178:	75 11                	jne    80218b <__umoddi3+0x11b>
  80217a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80217e:	73 0b                	jae    80218b <__umoddi3+0x11b>
  802180:	2b 44 24 04          	sub    0x4(%esp),%eax
  802184:	1b 14 24             	sbb    (%esp),%edx
  802187:	89 d1                	mov    %edx,%ecx
  802189:	89 c3                	mov    %eax,%ebx
  80218b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80218f:	29 da                	sub    %ebx,%edx
  802191:	19 ce                	sbb    %ecx,%esi
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 f0                	mov    %esi,%eax
  802197:	d3 e0                	shl    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	d3 ea                	shr    %cl,%edx
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	d3 ee                	shr    %cl,%esi
  8021a1:	09 d0                	or     %edx,%eax
  8021a3:	89 f2                	mov    %esi,%edx
  8021a5:	83 c4 1c             	add    $0x1c,%esp
  8021a8:	5b                   	pop    %ebx
  8021a9:	5e                   	pop    %esi
  8021aa:	5f                   	pop    %edi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
  8021b0:	29 f9                	sub    %edi,%ecx
  8021b2:	19 d6                	sbb    %edx,%esi
  8021b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021bc:	e9 18 ff ff ff       	jmp    8020d9 <__umoddi3+0x69>
