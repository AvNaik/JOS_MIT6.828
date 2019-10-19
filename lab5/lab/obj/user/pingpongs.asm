
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 f7 0f 00 00       	call   801038 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 e8 0a 00 00       	call   800b3b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 20 22 80 00       	push   $0x802220
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d1 0a 00 00       	call   800b3b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 3a 22 80 00       	push   $0x80223a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 2a 10 00 00       	call   8010b1 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 b8 0f 00 00       	call   801052 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 88 0a 00 00       	call   800b3b <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 50 22 80 00       	push   $0x802250
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 c7 0f 00 00       	call   8010b1 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800109:	e8 2d 0a 00 00       	call   800b3b <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 ba 11 00 00       	call   801309 <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 a1 09 00 00       	call   800afa <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 2f 09 00 00       	call   800abd <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 54 01 00 00       	call   800328 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 d4 08 00 00       	call   800abd <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022c:	39 d3                	cmp    %edx,%ebx
  80022e:	72 05                	jb     800235 <printnum+0x30>
  800230:	39 45 10             	cmp    %eax,0x10(%ebp)
  800233:	77 45                	ja     80027a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	53                   	push   %ebx
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 27 1d 00 00       	call   801f80 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 18                	jmp    800284 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	eb 03                	jmp    80027d <printnum+0x78>
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f e8                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 14 1e 00 00       	call   8020b0 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 80 22 80 00 	movsbl 0x802280(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b7:	83 fa 01             	cmp    $0x1,%edx
  8002ba:	7e 0e                	jle    8002ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	8b 52 04             	mov    0x4(%edx),%edx
  8002c8:	eb 22                	jmp    8002ec <getuint+0x38>
	else if (lflag)
  8002ca:	85 d2                	test   %edx,%edx
  8002cc:	74 10                	je     8002de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dc:	eb 0e                	jmp    8002ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fd:	73 0a                	jae    800309 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	88 02                	mov    %al,(%edx)
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800311:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800314:	50                   	push   %eax
  800315:	ff 75 10             	pushl  0x10(%ebp)
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	ff 75 08             	pushl  0x8(%ebp)
  80031e:	e8 05 00 00 00       	call   800328 <vprintfmt>
	va_end(ap);
}
  800323:	83 c4 10             	add    $0x10,%esp
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 2c             	sub    $0x2c,%esp
  800331:	8b 75 08             	mov    0x8(%ebp),%esi
  800334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800337:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033a:	eb 12                	jmp    80034e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033c:	85 c0                	test   %eax,%eax
  80033e:	0f 84 89 03 00 00    	je     8006cd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	53                   	push   %ebx
  800348:	50                   	push   %eax
  800349:	ff d6                	call   *%esi
  80034b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034e:	83 c7 01             	add    $0x1,%edi
  800351:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800355:	83 f8 25             	cmp    $0x25,%eax
  800358:	75 e2                	jne    80033c <vprintfmt+0x14>
  80035a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800373:	ba 00 00 00 00       	mov    $0x0,%edx
  800378:	eb 07                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8d 47 01             	lea    0x1(%edi),%eax
  800384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800387:	0f b6 07             	movzbl (%edi),%eax
  80038a:	0f b6 c8             	movzbl %al,%ecx
  80038d:	83 e8 23             	sub    $0x23,%eax
  800390:	3c 55                	cmp    $0x55,%al
  800392:	0f 87 1a 03 00 00    	ja     8006b2 <vprintfmt+0x38a>
  800398:	0f b6 c0             	movzbl %al,%eax
  80039b:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a9:	eb d6                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c3:	83 fa 09             	cmp    $0x9,%edx
  8003c6:	77 39                	ja     800401 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cb:	eb e9                	jmp    8003b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 27                	jmp    800407 <vprintfmt+0xdf>
  8003e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ea:	0f 49 c8             	cmovns %eax,%ecx
  8003ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f3:	eb 8c                	jmp    800381 <vprintfmt+0x59>
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ff:	eb 80                	jmp    800381 <vprintfmt+0x59>
  800401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800404:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800407:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040b:	0f 89 70 ff ff ff    	jns    800381 <vprintfmt+0x59>
				width = precision, precision = -1;
  800411:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800414:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800417:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041e:	e9 5e ff ff ff       	jmp    800381 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800423:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800429:	e9 53 ff ff ff       	jmp    800381 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	53                   	push   %ebx
  80043b:	ff 30                	pushl  (%eax)
  80043d:	ff d6                	call   *%esi
			break;
  80043f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800445:	e9 04 ff ff ff       	jmp    80034e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	8b 00                	mov    (%eax),%eax
  800455:	99                   	cltd   
  800456:	31 d0                	xor    %edx,%eax
  800458:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 0f             	cmp    $0xf,%eax
  80045d:	7f 0b                	jg     80046a <vprintfmt+0x142>
  80045f:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 98 22 80 00       	push   $0x802298
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 94 fe ff ff       	call   80030b <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047d:	e9 cc fe ff ff       	jmp    80034e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800482:	52                   	push   %edx
  800483:	68 1d 27 80 00       	push   $0x80271d
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 7c fe ff ff       	call   80030b <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800495:	e9 b4 fe ff ff       	jmp    80034e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a5:	85 ff                	test   %edi,%edi
  8004a7:	b8 91 22 80 00       	mov    $0x802291,%eax
  8004ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b3:	0f 8e 94 00 00 00    	jle    80054d <vprintfmt+0x225>
  8004b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bd:	0f 84 98 00 00 00    	je     80055b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c9:	57                   	push   %edi
  8004ca:	e8 86 02 00 00       	call   800755 <strnlen>
  8004cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	eb 0f                	jmp    8004f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	7f ed                	jg     8004e8 <vprintfmt+0x1c0>
  8004fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800501:	85 c9                	test   %ecx,%ecx
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	0f 49 c1             	cmovns %ecx,%eax
  80050b:	29 c1                	sub    %eax,%ecx
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	89 cb                	mov    %ecx,%ebx
  800518:	eb 4d                	jmp    800567 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051e:	74 1b                	je     80053b <vprintfmt+0x213>
  800520:	0f be c0             	movsbl %al,%eax
  800523:	83 e8 20             	sub    $0x20,%eax
  800526:	83 f8 5e             	cmp    $0x5e,%eax
  800529:	76 10                	jbe    80053b <vprintfmt+0x213>
					putch('?', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	6a 3f                	push   $0x3f
  800533:	ff 55 08             	call   *0x8(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 0d                	jmp    800548 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	52                   	push   %edx
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	83 eb 01             	sub    $0x1,%ebx
  80054b:	eb 1a                	jmp    800567 <vprintfmt+0x23f>
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800559:	eb 0c                	jmp    800567 <vprintfmt+0x23f>
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800567:	83 c7 01             	add    $0x1,%edi
  80056a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056e:	0f be d0             	movsbl %al,%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	74 23                	je     800598 <vprintfmt+0x270>
  800575:	85 f6                	test   %esi,%esi
  800577:	78 a1                	js     80051a <vprintfmt+0x1f2>
  800579:	83 ee 01             	sub    $0x1,%esi
  80057c:	79 9c                	jns    80051a <vprintfmt+0x1f2>
  80057e:	89 df                	mov    %ebx,%edi
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	eb 18                	jmp    8005a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	6a 20                	push   $0x20
  80058e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	eb 08                	jmp    8005a0 <vprintfmt+0x278>
  800598:	89 df                	mov    %ebx,%edi
  80059a:	8b 75 08             	mov    0x8(%ebp),%esi
  80059d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a0:	85 ff                	test   %edi,%edi
  8005a2:	7f e4                	jg     800588 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	e9 a2 fd ff ff       	jmp    80034e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ac:	83 fa 01             	cmp    $0x1,%edx
  8005af:	7e 16                	jle    8005c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 08             	lea    0x8(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 50 04             	mov    0x4(%eax),%edx
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c5:	eb 32                	jmp    8005f9 <vprintfmt+0x2d1>
	else if (lflag)
  8005c7:	85 d2                	test   %edx,%edx
  8005c9:	74 18                	je     8005e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	89 c1                	mov    %eax,%ecx
  8005db:	c1 f9 1f             	sar    $0x1f,%ecx
  8005de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e1:	eb 16                	jmp    8005f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 c1                	mov    %eax,%ecx
  8005f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800604:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800608:	79 74                	jns    80067e <vprintfmt+0x356>
				putch('-', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 2d                	push   $0x2d
  800610:	ff d6                	call   *%esi
				num = -(long long) num;
  800612:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800615:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800618:	f7 d8                	neg    %eax
  80061a:	83 d2 00             	adc    $0x0,%edx
  80061d:	f7 da                	neg    %edx
  80061f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800622:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800627:	eb 55                	jmp    80067e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800629:	8d 45 14             	lea    0x14(%ebp),%eax
  80062c:	e8 83 fc ff ff       	call   8002b4 <getuint>
			base = 10;
  800631:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800636:	eb 46                	jmp    80067e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800638:	8d 45 14             	lea    0x14(%ebp),%eax
  80063b:	e8 74 fc ff ff       	call   8002b4 <getuint>
			base = 8;
  800640:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800645:	eb 37                	jmp    80067e <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	6a 30                	push   $0x30
  80064d:	ff d6                	call   *%esi
			putch('x', putdat);
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 78                	push   $0x78
  800655:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800660:	8b 00                	mov    (%eax),%eax
  800662:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800667:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066f:	eb 0d                	jmp    80067e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 3b fc ff ff       	call   8002b4 <getuint>
			base = 16;
  800679:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067e:	83 ec 0c             	sub    $0xc,%esp
  800681:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800685:	57                   	push   %edi
  800686:	ff 75 e0             	pushl  -0x20(%ebp)
  800689:	51                   	push   %ecx
  80068a:	52                   	push   %edx
  80068b:	50                   	push   %eax
  80068c:	89 da                	mov    %ebx,%edx
  80068e:	89 f0                	mov    %esi,%eax
  800690:	e8 70 fb ff ff       	call   800205 <printnum>
			break;
  800695:	83 c4 20             	add    $0x20,%esp
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069b:	e9 ae fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	51                   	push   %ecx
  8006a5:	ff d6                	call   *%esi
			break;
  8006a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ad:	e9 9c fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	6a 25                	push   $0x25
  8006b8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	eb 03                	jmp    8006c2 <vprintfmt+0x39a>
  8006bf:	83 ef 01             	sub    $0x1,%edi
  8006c2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c6:	75 f7                	jne    8006bf <vprintfmt+0x397>
  8006c8:	e9 81 fc ff ff       	jmp    80034e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d0:	5b                   	pop    %ebx
  8006d1:	5e                   	pop    %esi
  8006d2:	5f                   	pop    %edi
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	83 ec 18             	sub    $0x18,%esp
  8006db:	8b 45 08             	mov    0x8(%ebp),%eax
  8006de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 26                	je     80071c <vsnprintf+0x47>
  8006f6:	85 d2                	test   %edx,%edx
  8006f8:	7e 22                	jle    80071c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fa:	ff 75 14             	pushl  0x14(%ebp)
  8006fd:	ff 75 10             	pushl  0x10(%ebp)
  800700:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	68 ee 02 80 00       	push   $0x8002ee
  800709:	e8 1a fc ff ff       	call   800328 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800711:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800714:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb 05                	jmp    800721 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072c:	50                   	push   %eax
  80072d:	ff 75 10             	pushl  0x10(%ebp)
  800730:	ff 75 0c             	pushl  0xc(%ebp)
  800733:	ff 75 08             	pushl  0x8(%ebp)
  800736:	e8 9a ff ff ff       	call   8006d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    

0080073d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	eb 03                	jmp    80074d <strlen+0x10>
		n++;
  80074a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800751:	75 f7                	jne    80074a <strlen+0xd>
		n++;
	return n;
}
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075e:	ba 00 00 00 00       	mov    $0x0,%edx
  800763:	eb 03                	jmp    800768 <strnlen+0x13>
		n++;
  800765:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800768:	39 c2                	cmp    %eax,%edx
  80076a:	74 08                	je     800774 <strnlen+0x1f>
  80076c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800770:	75 f3                	jne    800765 <strnlen+0x10>
  800772:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	53                   	push   %ebx
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800780:	89 c2                	mov    %eax,%edx
  800782:	83 c2 01             	add    $0x1,%edx
  800785:	83 c1 01             	add    $0x1,%ecx
  800788:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078f:	84 db                	test   %bl,%bl
  800791:	75 ef                	jne    800782 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800793:	5b                   	pop    %ebx
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079d:	53                   	push   %ebx
  80079e:	e8 9a ff ff ff       	call   80073d <strlen>
  8007a3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a6:	ff 75 0c             	pushl  0xc(%ebp)
  8007a9:	01 d8                	add    %ebx,%eax
  8007ab:	50                   	push   %eax
  8007ac:	e8 c5 ff ff ff       	call   800776 <strcpy>
	return dst;
}
  8007b1:	89 d8                	mov    %ebx,%eax
  8007b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	56                   	push   %esi
  8007bc:	53                   	push   %ebx
  8007bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c3:	89 f3                	mov    %esi,%ebx
  8007c5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c8:	89 f2                	mov    %esi,%edx
  8007ca:	eb 0f                	jmp    8007db <strncpy+0x23>
		*dst++ = *src;
  8007cc:	83 c2 01             	add    $0x1,%edx
  8007cf:	0f b6 01             	movzbl (%ecx),%eax
  8007d2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d5:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007db:	39 da                	cmp    %ebx,%edx
  8007dd:	75 ed                	jne    8007cc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007df:	89 f0                	mov    %esi,%eax
  8007e1:	5b                   	pop    %ebx
  8007e2:	5e                   	pop    %esi
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	56                   	push   %esi
  8007e9:	53                   	push   %ebx
  8007ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	74 21                	je     80081a <strlcpy+0x35>
  8007f9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fd:	89 f2                	mov    %esi,%edx
  8007ff:	eb 09                	jmp    80080a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	83 c1 01             	add    $0x1,%ecx
  800807:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080a:	39 c2                	cmp    %eax,%edx
  80080c:	74 09                	je     800817 <strlcpy+0x32>
  80080e:	0f b6 19             	movzbl (%ecx),%ebx
  800811:	84 db                	test   %bl,%bl
  800813:	75 ec                	jne    800801 <strlcpy+0x1c>
  800815:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800817:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081a:	29 f0                	sub    %esi,%eax
}
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800829:	eb 06                	jmp    800831 <strcmp+0x11>
		p++, q++;
  80082b:	83 c1 01             	add    $0x1,%ecx
  80082e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800831:	0f b6 01             	movzbl (%ecx),%eax
  800834:	84 c0                	test   %al,%al
  800836:	74 04                	je     80083c <strcmp+0x1c>
  800838:	3a 02                	cmp    (%edx),%al
  80083a:	74 ef                	je     80082b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083c:	0f b6 c0             	movzbl %al,%eax
  80083f:	0f b6 12             	movzbl (%edx),%edx
  800842:	29 d0                	sub    %edx,%eax
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	53                   	push   %ebx
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800850:	89 c3                	mov    %eax,%ebx
  800852:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800855:	eb 06                	jmp    80085d <strncmp+0x17>
		n--, p++, q++;
  800857:	83 c0 01             	add    $0x1,%eax
  80085a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085d:	39 d8                	cmp    %ebx,%eax
  80085f:	74 15                	je     800876 <strncmp+0x30>
  800861:	0f b6 08             	movzbl (%eax),%ecx
  800864:	84 c9                	test   %cl,%cl
  800866:	74 04                	je     80086c <strncmp+0x26>
  800868:	3a 0a                	cmp    (%edx),%cl
  80086a:	74 eb                	je     800857 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086c:	0f b6 00             	movzbl (%eax),%eax
  80086f:	0f b6 12             	movzbl (%edx),%edx
  800872:	29 d0                	sub    %edx,%eax
  800874:	eb 05                	jmp    80087b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087b:	5b                   	pop    %ebx
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800888:	eb 07                	jmp    800891 <strchr+0x13>
		if (*s == c)
  80088a:	38 ca                	cmp    %cl,%dl
  80088c:	74 0f                	je     80089d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088e:	83 c0 01             	add    $0x1,%eax
  800891:	0f b6 10             	movzbl (%eax),%edx
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f2                	jne    80088a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a9:	eb 03                	jmp    8008ae <strfind+0xf>
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b1:	38 ca                	cmp    %cl,%dl
  8008b3:	74 04                	je     8008b9 <strfind+0x1a>
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	75 f2                	jne    8008ab <strfind+0xc>
			break;
	return (char *) s;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	57                   	push   %edi
  8008bf:	56                   	push   %esi
  8008c0:	53                   	push   %ebx
  8008c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	74 36                	je     800901 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d1:	75 28                	jne    8008fb <memset+0x40>
  8008d3:	f6 c1 03             	test   $0x3,%cl
  8008d6:	75 23                	jne    8008fb <memset+0x40>
		c &= 0xFF;
  8008d8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dc:	89 d3                	mov    %edx,%ebx
  8008de:	c1 e3 08             	shl    $0x8,%ebx
  8008e1:	89 d6                	mov    %edx,%esi
  8008e3:	c1 e6 18             	shl    $0x18,%esi
  8008e6:	89 d0                	mov    %edx,%eax
  8008e8:	c1 e0 10             	shl    $0x10,%eax
  8008eb:	09 f0                	or     %esi,%eax
  8008ed:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ef:	89 d8                	mov    %ebx,%eax
  8008f1:	09 d0                	or     %edx,%eax
  8008f3:	c1 e9 02             	shr    $0x2,%ecx
  8008f6:	fc                   	cld    
  8008f7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f9:	eb 06                	jmp    800901 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fe:	fc                   	cld    
  8008ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800901:	89 f8                	mov    %edi,%eax
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5f                   	pop    %edi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	57                   	push   %edi
  80090c:	56                   	push   %esi
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	8b 75 0c             	mov    0xc(%ebp),%esi
  800913:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800916:	39 c6                	cmp    %eax,%esi
  800918:	73 35                	jae    80094f <memmove+0x47>
  80091a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091d:	39 d0                	cmp    %edx,%eax
  80091f:	73 2e                	jae    80094f <memmove+0x47>
		s += n;
		d += n;
  800921:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800924:	89 d6                	mov    %edx,%esi
  800926:	09 fe                	or     %edi,%esi
  800928:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092e:	75 13                	jne    800943 <memmove+0x3b>
  800930:	f6 c1 03             	test   $0x3,%cl
  800933:	75 0e                	jne    800943 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800935:	83 ef 04             	sub    $0x4,%edi
  800938:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093b:	c1 e9 02             	shr    $0x2,%ecx
  80093e:	fd                   	std    
  80093f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800941:	eb 09                	jmp    80094c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800943:	83 ef 01             	sub    $0x1,%edi
  800946:	8d 72 ff             	lea    -0x1(%edx),%esi
  800949:	fd                   	std    
  80094a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094c:	fc                   	cld    
  80094d:	eb 1d                	jmp    80096c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094f:	89 f2                	mov    %esi,%edx
  800951:	09 c2                	or     %eax,%edx
  800953:	f6 c2 03             	test   $0x3,%dl
  800956:	75 0f                	jne    800967 <memmove+0x5f>
  800958:	f6 c1 03             	test   $0x3,%cl
  80095b:	75 0a                	jne    800967 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095d:	c1 e9 02             	shr    $0x2,%ecx
  800960:	89 c7                	mov    %eax,%edi
  800962:	fc                   	cld    
  800963:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800965:	eb 05                	jmp    80096c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800967:	89 c7                	mov    %eax,%edi
  800969:	fc                   	cld    
  80096a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096c:	5e                   	pop    %esi
  80096d:	5f                   	pop    %edi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800973:	ff 75 10             	pushl  0x10(%ebp)
  800976:	ff 75 0c             	pushl  0xc(%ebp)
  800979:	ff 75 08             	pushl  0x8(%ebp)
  80097c:	e8 87 ff ff ff       	call   800908 <memmove>
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098e:	89 c6                	mov    %eax,%esi
  800990:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	eb 1a                	jmp    8009af <memcmp+0x2c>
		if (*s1 != *s2)
  800995:	0f b6 08             	movzbl (%eax),%ecx
  800998:	0f b6 1a             	movzbl (%edx),%ebx
  80099b:	38 d9                	cmp    %bl,%cl
  80099d:	74 0a                	je     8009a9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099f:	0f b6 c1             	movzbl %cl,%eax
  8009a2:	0f b6 db             	movzbl %bl,%ebx
  8009a5:	29 d8                	sub    %ebx,%eax
  8009a7:	eb 0f                	jmp    8009b8 <memcmp+0x35>
		s1++, s2++;
  8009a9:	83 c0 01             	add    $0x1,%eax
  8009ac:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009af:	39 f0                	cmp    %esi,%eax
  8009b1:	75 e2                	jne    800995 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c3:	89 c1                	mov    %eax,%ecx
  8009c5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cc:	eb 0a                	jmp    8009d8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ce:	0f b6 10             	movzbl (%eax),%edx
  8009d1:	39 da                	cmp    %ebx,%edx
  8009d3:	74 07                	je     8009dc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d5:	83 c0 01             	add    $0x1,%eax
  8009d8:	39 c8                	cmp    %ecx,%eax
  8009da:	72 f2                	jb     8009ce <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009eb:	eb 03                	jmp    8009f0 <strtol+0x11>
		s++;
  8009ed:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f0:	0f b6 01             	movzbl (%ecx),%eax
  8009f3:	3c 20                	cmp    $0x20,%al
  8009f5:	74 f6                	je     8009ed <strtol+0xe>
  8009f7:	3c 09                	cmp    $0x9,%al
  8009f9:	74 f2                	je     8009ed <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fb:	3c 2b                	cmp    $0x2b,%al
  8009fd:	75 0a                	jne    800a09 <strtol+0x2a>
		s++;
  8009ff:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
  800a07:	eb 11                	jmp    800a1a <strtol+0x3b>
  800a09:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0e:	3c 2d                	cmp    $0x2d,%al
  800a10:	75 08                	jne    800a1a <strtol+0x3b>
		s++, neg = 1;
  800a12:	83 c1 01             	add    $0x1,%ecx
  800a15:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a20:	75 15                	jne    800a37 <strtol+0x58>
  800a22:	80 39 30             	cmpb   $0x30,(%ecx)
  800a25:	75 10                	jne    800a37 <strtol+0x58>
  800a27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2b:	75 7c                	jne    800aa9 <strtol+0xca>
		s += 2, base = 16;
  800a2d:	83 c1 02             	add    $0x2,%ecx
  800a30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a35:	eb 16                	jmp    800a4d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a37:	85 db                	test   %ebx,%ebx
  800a39:	75 12                	jne    800a4d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a40:	80 39 30             	cmpb   $0x30,(%ecx)
  800a43:	75 08                	jne    800a4d <strtol+0x6e>
		s++, base = 8;
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a52:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a55:	0f b6 11             	movzbl (%ecx),%edx
  800a58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5b:	89 f3                	mov    %esi,%ebx
  800a5d:	80 fb 09             	cmp    $0x9,%bl
  800a60:	77 08                	ja     800a6a <strtol+0x8b>
			dig = *s - '0';
  800a62:	0f be d2             	movsbl %dl,%edx
  800a65:	83 ea 30             	sub    $0x30,%edx
  800a68:	eb 22                	jmp    800a8c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 19             	cmp    $0x19,%bl
  800a72:	77 08                	ja     800a7c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a74:	0f be d2             	movsbl %dl,%edx
  800a77:	83 ea 57             	sub    $0x57,%edx
  800a7a:	eb 10                	jmp    800a8c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 19             	cmp    $0x19,%bl
  800a84:	77 16                	ja     800a9c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8f:	7d 0b                	jge    800a9c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a98:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9a:	eb b9                	jmp    800a55 <strtol+0x76>

	if (endptr)
  800a9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa0:	74 0d                	je     800aaf <strtol+0xd0>
		*endptr = (char *) s;
  800aa2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa5:	89 0e                	mov    %ecx,(%esi)
  800aa7:	eb 06                	jmp    800aaf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa9:	85 db                	test   %ebx,%ebx
  800aab:	74 98                	je     800a45 <strtol+0x66>
  800aad:	eb 9e                	jmp    800a4d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aaf:	89 c2                	mov    %eax,%edx
  800ab1:	f7 da                	neg    %edx
  800ab3:	85 ff                	test   %edi,%edi
  800ab5:	0f 45 c2             	cmovne %edx,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ace:	89 c3                	mov    %eax,%ebx
  800ad0:	89 c7                	mov    %eax,%edi
  800ad2:	89 c6                	mov    %eax,%esi
  800ad4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_cgetc>:

int
sys_cgetc(void)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae6:	b8 01 00 00 00       	mov    $0x1,%eax
  800aeb:	89 d1                	mov    %edx,%ecx
  800aed:	89 d3                	mov    %edx,%ebx
  800aef:	89 d7                	mov    %edx,%edi
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b08:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b10:	89 cb                	mov    %ecx,%ebx
  800b12:	89 cf                	mov    %ecx,%edi
  800b14:	89 ce                	mov    %ecx,%esi
  800b16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	7e 17                	jle    800b33 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	50                   	push   %eax
  800b20:	6a 03                	push   $0x3
  800b22:	68 7f 25 80 00       	push   $0x80257f
  800b27:	6a 23                	push   $0x23
  800b29:	68 9c 25 80 00       	push   $0x80259c
  800b2e:	e8 3e 13 00 00       	call   801e71 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4b:	89 d1                	mov    %edx,%ecx
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	89 d7                	mov    %edx,%edi
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_yield>:

void
sys_yield(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	be 00 00 00 00       	mov    $0x0,%esi
  800b87:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b95:	89 f7                	mov    %esi,%edi
  800b97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b99:	85 c0                	test   %eax,%eax
  800b9b:	7e 17                	jle    800bb4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9d:	83 ec 0c             	sub    $0xc,%esp
  800ba0:	50                   	push   %eax
  800ba1:	6a 04                	push   $0x4
  800ba3:	68 7f 25 80 00       	push   $0x80257f
  800ba8:	6a 23                	push   $0x23
  800baa:	68 9c 25 80 00       	push   $0x80259c
  800baf:	e8 bd 12 00 00       	call   801e71 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	b8 05 00 00 00       	mov    $0x5,%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd6:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 17                	jle    800bf6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	50                   	push   %eax
  800be3:	6a 05                	push   $0x5
  800be5:	68 7f 25 80 00       	push   $0x80257f
  800bea:	6a 23                	push   $0x23
  800bec:	68 9c 25 80 00       	push   $0x80259c
  800bf1:	e8 7b 12 00 00       	call   801e71 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	89 df                	mov    %ebx,%edi
  800c19:	89 de                	mov    %ebx,%esi
  800c1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 06                	push   $0x6
  800c27:	68 7f 25 80 00       	push   $0x80257f
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 9c 25 80 00       	push   $0x80259c
  800c33:	e8 39 12 00 00       	call   801e71 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 08                	push   $0x8
  800c69:	68 7f 25 80 00       	push   $0x80257f
  800c6e:	6a 23                	push   $0x23
  800c70:	68 9c 25 80 00       	push   $0x80259c
  800c75:	e8 f7 11 00 00       	call   801e71 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 09 00 00 00       	mov    $0x9,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 09                	push   $0x9
  800cab:	68 7f 25 80 00       	push   $0x80257f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 9c 25 80 00       	push   $0x80259c
  800cb7:	e8 b5 11 00 00       	call   801e71 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 0a                	push   $0xa
  800ced:	68 7f 25 80 00       	push   $0x80257f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 9c 25 80 00       	push   $0x80259c
  800cf9:	e8 73 11 00 00       	call   801e71 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	be 00 00 00 00       	mov    $0x0,%esi
  800d11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d37:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 cb                	mov    %ecx,%ebx
  800d41:	89 cf                	mov    %ecx,%edi
  800d43:	89 ce                	mov    %ecx,%esi
  800d45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7e 17                	jle    800d62 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 0d                	push   $0xd
  800d51:	68 7f 25 80 00       	push   $0x80257f
  800d56:	6a 23                	push   $0x23
  800d58:	68 9c 25 80 00       	push   $0x80259c
  800d5d:	e8 0f 11 00 00       	call   801e71 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 04             	sub    $0x4,%esp
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  800d74:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  800d76:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  800d79:	89 da                	mov    %ebx,%edx
  800d7b:	c1 ea 0c             	shr    $0xc,%edx
  800d7e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  800d85:	a8 02                	test   $0x2,%al
  800d87:	75 12                	jne    800d9b <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  800d89:	50                   	push   %eax
  800d8a:	68 ac 25 80 00       	push   $0x8025ac
  800d8f:	6a 21                	push   $0x21
  800d91:	68 cd 25 80 00       	push   $0x8025cd
  800d96:	e8 d6 10 00 00       	call   801e71 <_panic>
	   } else if (!(pte & PTE_COW)) {
  800d9b:	f6 c6 08             	test   $0x8,%dh
  800d9e:	75 14                	jne    800db4 <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  800da0:	83 ec 04             	sub    $0x4,%esp
  800da3:	68 d8 25 80 00       	push   $0x8025d8
  800da8:	6a 23                	push   $0x23
  800daa:	68 cd 25 80 00       	push   $0x8025cd
  800daf:	e8 bd 10 00 00       	call   801e71 <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  800db4:	83 ec 04             	sub    $0x4,%esp
  800db7:	6a 07                	push   $0x7
  800db9:	68 00 00 40 00       	push   $0x400000
  800dbe:	6a 00                	push   $0x0
  800dc0:	e8 b4 fd ff ff       	call   800b79 <sys_page_alloc>
  800dc5:	83 c4 10             	add    $0x10,%esp
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	79 12                	jns    800dde <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  800dcc:	50                   	push   %eax
  800dcd:	68 f5 25 80 00       	push   $0x8025f5
  800dd2:	6a 2e                	push   $0x2e
  800dd4:	68 cd 25 80 00       	push   $0x8025cd
  800dd9:	e8 93 10 00 00       	call   801e71 <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800dde:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800de4:	83 ec 04             	sub    $0x4,%esp
  800de7:	68 00 10 00 00       	push   $0x1000
  800dec:	53                   	push   %ebx
  800ded:	68 00 00 40 00       	push   $0x400000
  800df2:	e8 11 fb ff ff       	call   800908 <memmove>
	   if ((r = sys_page_map(0,
  800df7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dfe:	53                   	push   %ebx
  800dff:	6a 00                	push   $0x0
  800e01:	68 00 00 40 00       	push   $0x400000
  800e06:	6a 00                	push   $0x0
  800e08:	e8 af fd ff ff       	call   800bbc <sys_page_map>
  800e0d:	83 c4 20             	add    $0x20,%esp
  800e10:	85 c0                	test   %eax,%eax
  800e12:	79 12                	jns    800e26 <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  800e14:	50                   	push   %eax
  800e15:	68 08 26 80 00       	push   $0x802608
  800e1a:	6a 36                	push   $0x36
  800e1c:	68 cd 25 80 00       	push   $0x8025cd
  800e21:	e8 4b 10 00 00       	call   801e71 <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  800e26:	83 ec 08             	sub    $0x8,%esp
  800e29:	68 00 00 40 00       	push   $0x400000
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 c9 fd ff ff       	call   800bfe <sys_page_unmap>
  800e35:	83 c4 10             	add    $0x10,%esp
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	79 12                	jns    800e4e <pgfault+0xe4>
			 panic("unmap %e", r);
  800e3c:	50                   	push   %eax
  800e3d:	68 18 26 80 00       	push   $0x802618
  800e42:	6a 39                	push   $0x39
  800e44:	68 cd 25 80 00       	push   $0x8025cd
  800e49:	e8 23 10 00 00       	call   801e71 <_panic>
	   }
}
  800e4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    

00800e53 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  800e5c:	68 6a 0d 80 00       	push   $0x800d6a
  800e61:	e8 51 10 00 00       	call   801eb7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e66:	b8 07 00 00 00       	mov    $0x7,%eax
  800e6b:	cd 30                	int    $0x30
  800e6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e70:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  800e73:	83 c4 10             	add    $0x10,%esp
  800e76:	85 c0                	test   %eax,%eax
  800e78:	79 15                	jns    800e8f <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  800e7a:	50                   	push   %eax
  800e7b:	68 21 26 80 00       	push   $0x802621
  800e80:	68 81 00 00 00       	push   $0x81
  800e85:	68 cd 25 80 00       	push   $0x8025cd
  800e8a:	e8 e2 0f 00 00       	call   801e71 <_panic>
  800e8f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800e96:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  800e9a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e9e:	75 1c                	jne    800ebc <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  800ea0:	e8 96 fc ff ff       	call   800b3b <sys_getenvid>
  800ea5:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eaa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ead:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eb2:	a3 08 40 80 00       	mov    %eax,0x804008
			 return envid;
  800eb7:	e9 71 01 00 00       	jmp    80102d <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  800ebc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800ebf:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800ec6:	a8 01                	test   $0x1,%al
  800ec8:	0f 84 18 01 00 00    	je     800fe6 <fork+0x193>
  800ece:	89 fb                	mov    %edi,%ebx
  800ed0:	c1 e3 0a             	shl    $0xa,%ebx
  800ed3:	c1 e7 16             	shl    $0x16,%edi
  800ed6:	be 00 00 00 00       	mov    $0x0,%esi
  800edb:	e9 f4 00 00 00       	jmp    800fd4 <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  800ee0:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800ee6:	0f 84 dc 00 00 00    	je     800fc8 <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  800eec:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800ef2:	0f 87 cc 00 00 00    	ja     800fc4 <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  800ef8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800eff:	a8 01                	test   $0x1,%al
  800f01:	0f 84 c1 00 00 00    	je     800fc8 <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  800f07:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  800f0e:	a9 02 08 00 00       	test   $0x802,%eax
  800f13:	74 05                	je     800f1a <fork+0xc7>
  800f15:	f6 c4 04             	test   $0x4,%ah
  800f18:	74 3a                	je     800f54 <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  800f1a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800f20:	8b 52 48             	mov    0x48(%edx),%edx
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	25 07 0e 00 00       	and    $0xe07,%eax
  800f2b:	50                   	push   %eax
  800f2c:	57                   	push   %edi
  800f2d:	ff 75 dc             	pushl  -0x24(%ebp)
  800f30:	57                   	push   %edi
  800f31:	52                   	push   %edx
  800f32:	e8 85 fc ff ff       	call   800bbc <sys_page_map>
  800f37:	83 c4 20             	add    $0x20,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	0f 89 86 00 00 00    	jns    800fc8 <fork+0x175>
				    panic("sys_page_map: %e", r);
  800f42:	50                   	push   %eax
  800f43:	68 31 26 80 00       	push   $0x802631
  800f48:	6a 52                	push   $0x52
  800f4a:	68 cd 25 80 00       	push   $0x8025cd
  800f4f:	e8 1d 0f 00 00       	call   801e71 <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  800f54:	25 05 06 00 00       	and    $0x605,%eax
  800f59:	80 cc 08             	or     $0x8,%ah
  800f5c:	89 c1                	mov    %eax,%ecx
  800f5e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f61:	a1 08 40 80 00       	mov    0x804008,%eax
  800f66:	8b 40 48             	mov    0x48(%eax),%eax
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	51                   	push   %ecx
  800f6d:	57                   	push   %edi
  800f6e:	ff 75 dc             	pushl  -0x24(%ebp)
  800f71:	57                   	push   %edi
  800f72:	50                   	push   %eax
  800f73:	e8 44 fc ff ff       	call   800bbc <sys_page_map>
  800f78:	83 c4 20             	add    $0x20,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	79 12                	jns    800f91 <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  800f7f:	50                   	push   %eax
  800f80:	68 31 26 80 00       	push   $0x802631
  800f85:	6a 5d                	push   $0x5d
  800f87:	68 cd 25 80 00       	push   $0x8025cd
  800f8c:	e8 e0 0e 00 00       	call   801e71 <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  800f91:	a1 08 40 80 00       	mov    0x804008,%eax
  800f96:	8b 50 48             	mov    0x48(%eax),%edx
  800f99:	8b 40 48             	mov    0x48(%eax),%eax
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa2:	57                   	push   %edi
  800fa3:	52                   	push   %edx
  800fa4:	57                   	push   %edi
  800fa5:	50                   	push   %eax
  800fa6:	e8 11 fc ff ff       	call   800bbc <sys_page_map>
  800fab:	83 c4 20             	add    $0x20,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	79 16                	jns    800fc8 <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  800fb2:	50                   	push   %eax
  800fb3:	68 31 26 80 00       	push   $0x802631
  800fb8:	6a 63                	push   $0x63
  800fba:	68 cd 25 80 00       	push   $0x8025cd
  800fbf:	e8 ad 0e 00 00       	call   801e71 <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  800fc4:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  800fc8:	83 c6 01             	add    $0x1,%esi
  800fcb:	83 c3 01             	add    $0x1,%ebx
  800fce:	81 c7 00 10 00 00    	add    $0x1000,%edi
  800fd4:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  800fda:	7f 0a                	jg     800fe6 <fork+0x193>
  800fdc:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fe0:	0f 85 fa fe ff ff    	jne    800ee0 <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  800fe6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  800fea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fed:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ff2:	7f 0a                	jg     800ffe <fork+0x1ab>
  800ff4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ff8:	0f 85 be fe ff ff    	jne    800ebc <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800ffe:	83 ec 08             	sub    $0x8,%esp
  801001:	68 10 1f 80 00       	push   $0x801f10
  801006:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801009:	56                   	push   %esi
  80100a:	e8 b5 fc ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  80100f:	83 c4 0c             	add    $0xc,%esp
  801012:	6a 06                	push   $0x6
  801014:	68 00 f0 bf ee       	push   $0xeebff000
  801019:	56                   	push   %esi
  80101a:	e8 5a fb ff ff       	call   800b79 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  80101f:	83 c4 08             	add    $0x8,%esp
  801022:	6a 02                	push   $0x2
  801024:	56                   	push   %esi
  801025:	e8 16 fc ff ff       	call   800c40 <sys_env_set_status>

	   return envid;
  80102a:	83 c4 10             	add    $0x10,%esp
}
  80102d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801030:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <sfork>:
// Challenge!
	   int
sfork(void)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  80103e:	68 42 26 80 00       	push   $0x802642
  801043:	68 a7 00 00 00       	push   $0xa7
  801048:	68 cd 25 80 00       	push   $0x8025cd
  80104d:	e8 1f 0e 00 00       	call   801e71 <_panic>

00801052 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
  801057:	8b 75 08             	mov    0x8(%ebp),%esi
  80105a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801060:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801062:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801067:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	50                   	push   %eax
  80106e:	e8 b6 fc ff ff       	call   800d29 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 0e                	js     801088 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  80107a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801080:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801083:	8b 52 78             	mov    0x78(%edx),%edx
  801086:	eb 0a                	jmp    801092 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801088:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  80108d:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801092:	85 f6                	test   %esi,%esi
  801094:	74 02                	je     801098 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801096:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801098:	85 db                	test   %ebx,%ebx
  80109a:	74 02                	je     80109e <ipc_recv+0x4c>
			 *perm_store = s_perm;
  80109c:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	78 08                	js     8010aa <ipc_recv+0x58>
  8010a2:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a7:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  8010aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    

008010b1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	57                   	push   %edi
  8010b5:	56                   	push   %esi
  8010b6:	53                   	push   %ebx
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  8010c3:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  8010c5:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8010ca:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  8010cd:	ff 75 14             	pushl  0x14(%ebp)
  8010d0:	53                   	push   %ebx
  8010d1:	56                   	push   %esi
  8010d2:	57                   	push   %edi
  8010d3:	e8 2e fc ff ff       	call   800d06 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010de:	75 07                	jne    8010e7 <ipc_send+0x36>
				    sys_yield();
  8010e0:	e8 75 fa ff ff       	call   800b5a <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  8010e5:	eb e6                	jmp    8010cd <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	74 12                	je     8010fd <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  8010eb:	50                   	push   %eax
  8010ec:	68 58 26 80 00       	push   $0x802658
  8010f1:	6a 4b                	push   $0x4b
  8010f3:	68 6c 26 80 00       	push   $0x80266c
  8010f8:	e8 74 0d 00 00       	call   801e71 <_panic>
			 }
	   }
}
  8010fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801100:	5b                   	pop    %ebx
  801101:	5e                   	pop    %esi
  801102:	5f                   	pop    %edi
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  80110b:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801110:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801113:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801119:	8b 52 50             	mov    0x50(%edx),%edx
  80111c:	39 ca                	cmp    %ecx,%edx
  80111e:	75 0d                	jne    80112d <ipc_find_env+0x28>
				    return envs[i].env_id;
  801120:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801123:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801128:	8b 40 48             	mov    0x48(%eax),%eax
  80112b:	eb 0f                	jmp    80113c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  80112d:	83 c0 01             	add    $0x1,%eax
  801130:	3d 00 04 00 00       	cmp    $0x400,%eax
  801135:	75 d9                	jne    801110 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801141:	8b 45 08             	mov    0x8(%ebp),%eax
  801144:	05 00 00 00 30       	add    $0x30000000,%eax
  801149:	c1 e8 0c             	shr    $0xc,%eax
}
  80114c:	5d                   	pop    %ebp
  80114d:	c3                   	ret    

0080114e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801151:	8b 45 08             	mov    0x8(%ebp),%eax
  801154:	05 00 00 00 30       	add    $0x30000000,%eax
  801159:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80115e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801170:	89 c2                	mov    %eax,%edx
  801172:	c1 ea 16             	shr    $0x16,%edx
  801175:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80117c:	f6 c2 01             	test   $0x1,%dl
  80117f:	74 11                	je     801192 <fd_alloc+0x2d>
  801181:	89 c2                	mov    %eax,%edx
  801183:	c1 ea 0c             	shr    $0xc,%edx
  801186:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118d:	f6 c2 01             	test   $0x1,%dl
  801190:	75 09                	jne    80119b <fd_alloc+0x36>
			*fd_store = fd;
  801192:	89 01                	mov    %eax,(%ecx)
			return 0;
  801194:	b8 00 00 00 00       	mov    $0x0,%eax
  801199:	eb 17                	jmp    8011b2 <fd_alloc+0x4d>
  80119b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011a0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011a5:	75 c9                	jne    801170 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011a7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ad:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011ba:	83 f8 1f             	cmp    $0x1f,%eax
  8011bd:	77 36                	ja     8011f5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011bf:	c1 e0 0c             	shl    $0xc,%eax
  8011c2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011c7:	89 c2                	mov    %eax,%edx
  8011c9:	c1 ea 16             	shr    $0x16,%edx
  8011cc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d3:	f6 c2 01             	test   $0x1,%dl
  8011d6:	74 24                	je     8011fc <fd_lookup+0x48>
  8011d8:	89 c2                	mov    %eax,%edx
  8011da:	c1 ea 0c             	shr    $0xc,%edx
  8011dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e4:	f6 c2 01             	test   $0x1,%dl
  8011e7:	74 1a                	je     801203 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ec:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f3:	eb 13                	jmp    801208 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fa:	eb 0c                	jmp    801208 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801201:	eb 05                	jmp    801208 <fd_lookup+0x54>
  801203:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801213:	ba f4 26 80 00       	mov    $0x8026f4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801218:	eb 13                	jmp    80122d <dev_lookup+0x23>
  80121a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80121d:	39 08                	cmp    %ecx,(%eax)
  80121f:	75 0c                	jne    80122d <dev_lookup+0x23>
			*dev = devtab[i];
  801221:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801224:	89 01                	mov    %eax,(%ecx)
			return 0;
  801226:	b8 00 00 00 00       	mov    $0x0,%eax
  80122b:	eb 2e                	jmp    80125b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80122d:	8b 02                	mov    (%edx),%eax
  80122f:	85 c0                	test   %eax,%eax
  801231:	75 e7                	jne    80121a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801233:	a1 08 40 80 00       	mov    0x804008,%eax
  801238:	8b 40 48             	mov    0x48(%eax),%eax
  80123b:	83 ec 04             	sub    $0x4,%esp
  80123e:	51                   	push   %ecx
  80123f:	50                   	push   %eax
  801240:	68 78 26 80 00       	push   $0x802678
  801245:	e8 a7 ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  80124a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80125b:	c9                   	leave  
  80125c:	c3                   	ret    

0080125d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
  801262:	83 ec 10             	sub    $0x10,%esp
  801265:	8b 75 08             	mov    0x8(%ebp),%esi
  801268:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80126b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801275:	c1 e8 0c             	shr    $0xc,%eax
  801278:	50                   	push   %eax
  801279:	e8 36 ff ff ff       	call   8011b4 <fd_lookup>
  80127e:	83 c4 08             	add    $0x8,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 05                	js     80128a <fd_close+0x2d>
	    || fd != fd2)
  801285:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801288:	74 0c                	je     801296 <fd_close+0x39>
		return (must_exist ? r : 0);
  80128a:	84 db                	test   %bl,%bl
  80128c:	ba 00 00 00 00       	mov    $0x0,%edx
  801291:	0f 44 c2             	cmove  %edx,%eax
  801294:	eb 41                	jmp    8012d7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	ff 36                	pushl  (%esi)
  80129f:	e8 66 ff ff ff       	call   80120a <dev_lookup>
  8012a4:	89 c3                	mov    %eax,%ebx
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 1a                	js     8012c7 <fd_close+0x6a>
		if (dev->dev_close)
  8012ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012b3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	74 0b                	je     8012c7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012bc:	83 ec 0c             	sub    $0xc,%esp
  8012bf:	56                   	push   %esi
  8012c0:	ff d0                	call   *%eax
  8012c2:	89 c3                	mov    %eax,%ebx
  8012c4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	56                   	push   %esi
  8012cb:	6a 00                	push   $0x0
  8012cd:	e8 2c f9 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	89 d8                	mov    %ebx,%eax
}
  8012d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012da:	5b                   	pop    %ebx
  8012db:	5e                   	pop    %esi
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e7:	50                   	push   %eax
  8012e8:	ff 75 08             	pushl  0x8(%ebp)
  8012eb:	e8 c4 fe ff ff       	call   8011b4 <fd_lookup>
  8012f0:	83 c4 08             	add    $0x8,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 10                	js     801307 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012f7:	83 ec 08             	sub    $0x8,%esp
  8012fa:	6a 01                	push   $0x1
  8012fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ff:	e8 59 ff ff ff       	call   80125d <fd_close>
  801304:	83 c4 10             	add    $0x10,%esp
}
  801307:	c9                   	leave  
  801308:	c3                   	ret    

00801309 <close_all>:

void
close_all(void)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	53                   	push   %ebx
  80130d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801310:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801315:	83 ec 0c             	sub    $0xc,%esp
  801318:	53                   	push   %ebx
  801319:	e8 c0 ff ff ff       	call   8012de <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80131e:	83 c3 01             	add    $0x1,%ebx
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	83 fb 20             	cmp    $0x20,%ebx
  801327:	75 ec                	jne    801315 <close_all+0xc>
		close(i);
}
  801329:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132c:	c9                   	leave  
  80132d:	c3                   	ret    

0080132e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	53                   	push   %ebx
  801334:	83 ec 2c             	sub    $0x2c,%esp
  801337:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80133a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80133d:	50                   	push   %eax
  80133e:	ff 75 08             	pushl  0x8(%ebp)
  801341:	e8 6e fe ff ff       	call   8011b4 <fd_lookup>
  801346:	83 c4 08             	add    $0x8,%esp
  801349:	85 c0                	test   %eax,%eax
  80134b:	0f 88 c1 00 00 00    	js     801412 <dup+0xe4>
		return r;
	close(newfdnum);
  801351:	83 ec 0c             	sub    $0xc,%esp
  801354:	56                   	push   %esi
  801355:	e8 84 ff ff ff       	call   8012de <close>

	newfd = INDEX2FD(newfdnum);
  80135a:	89 f3                	mov    %esi,%ebx
  80135c:	c1 e3 0c             	shl    $0xc,%ebx
  80135f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801365:	83 c4 04             	add    $0x4,%esp
  801368:	ff 75 e4             	pushl  -0x1c(%ebp)
  80136b:	e8 de fd ff ff       	call   80114e <fd2data>
  801370:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801372:	89 1c 24             	mov    %ebx,(%esp)
  801375:	e8 d4 fd ff ff       	call   80114e <fd2data>
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801380:	89 f8                	mov    %edi,%eax
  801382:	c1 e8 16             	shr    $0x16,%eax
  801385:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80138c:	a8 01                	test   $0x1,%al
  80138e:	74 37                	je     8013c7 <dup+0x99>
  801390:	89 f8                	mov    %edi,%eax
  801392:	c1 e8 0c             	shr    $0xc,%eax
  801395:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80139c:	f6 c2 01             	test   $0x1,%dl
  80139f:	74 26                	je     8013c7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a8:	83 ec 0c             	sub    $0xc,%esp
  8013ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b0:	50                   	push   %eax
  8013b1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b4:	6a 00                	push   $0x0
  8013b6:	57                   	push   %edi
  8013b7:	6a 00                	push   $0x0
  8013b9:	e8 fe f7 ff ff       	call   800bbc <sys_page_map>
  8013be:	89 c7                	mov    %eax,%edi
  8013c0:	83 c4 20             	add    $0x20,%esp
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 2e                	js     8013f5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013ca:	89 d0                	mov    %edx,%eax
  8013cc:	c1 e8 0c             	shr    $0xc,%eax
  8013cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	25 07 0e 00 00       	and    $0xe07,%eax
  8013de:	50                   	push   %eax
  8013df:	53                   	push   %ebx
  8013e0:	6a 00                	push   $0x0
  8013e2:	52                   	push   %edx
  8013e3:	6a 00                	push   $0x0
  8013e5:	e8 d2 f7 ff ff       	call   800bbc <sys_page_map>
  8013ea:	89 c7                	mov    %eax,%edi
  8013ec:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013ef:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f1:	85 ff                	test   %edi,%edi
  8013f3:	79 1d                	jns    801412 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	53                   	push   %ebx
  8013f9:	6a 00                	push   $0x0
  8013fb:	e8 fe f7 ff ff       	call   800bfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801400:	83 c4 08             	add    $0x8,%esp
  801403:	ff 75 d4             	pushl  -0x2c(%ebp)
  801406:	6a 00                	push   $0x0
  801408:	e8 f1 f7 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	89 f8                	mov    %edi,%eax
}
  801412:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801415:	5b                   	pop    %ebx
  801416:	5e                   	pop    %esi
  801417:	5f                   	pop    %edi
  801418:	5d                   	pop    %ebp
  801419:	c3                   	ret    

0080141a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	53                   	push   %ebx
  80141e:	83 ec 14             	sub    $0x14,%esp
  801421:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801424:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801427:	50                   	push   %eax
  801428:	53                   	push   %ebx
  801429:	e8 86 fd ff ff       	call   8011b4 <fd_lookup>
  80142e:	83 c4 08             	add    $0x8,%esp
  801431:	89 c2                	mov    %eax,%edx
  801433:	85 c0                	test   %eax,%eax
  801435:	78 6d                	js     8014a4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143d:	50                   	push   %eax
  80143e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801441:	ff 30                	pushl  (%eax)
  801443:	e8 c2 fd ff ff       	call   80120a <dev_lookup>
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	85 c0                	test   %eax,%eax
  80144d:	78 4c                	js     80149b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80144f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801452:	8b 42 08             	mov    0x8(%edx),%eax
  801455:	83 e0 03             	and    $0x3,%eax
  801458:	83 f8 01             	cmp    $0x1,%eax
  80145b:	75 21                	jne    80147e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80145d:	a1 08 40 80 00       	mov    0x804008,%eax
  801462:	8b 40 48             	mov    0x48(%eax),%eax
  801465:	83 ec 04             	sub    $0x4,%esp
  801468:	53                   	push   %ebx
  801469:	50                   	push   %eax
  80146a:	68 b9 26 80 00       	push   $0x8026b9
  80146f:	e8 7d ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80147c:	eb 26                	jmp    8014a4 <read+0x8a>
	}
	if (!dev->dev_read)
  80147e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801481:	8b 40 08             	mov    0x8(%eax),%eax
  801484:	85 c0                	test   %eax,%eax
  801486:	74 17                	je     80149f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801488:	83 ec 04             	sub    $0x4,%esp
  80148b:	ff 75 10             	pushl  0x10(%ebp)
  80148e:	ff 75 0c             	pushl  0xc(%ebp)
  801491:	52                   	push   %edx
  801492:	ff d0                	call   *%eax
  801494:	89 c2                	mov    %eax,%edx
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	eb 09                	jmp    8014a4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149b:	89 c2                	mov    %eax,%edx
  80149d:	eb 05                	jmp    8014a4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80149f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014a4:	89 d0                	mov    %edx,%eax
  8014a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	57                   	push   %edi
  8014af:	56                   	push   %esi
  8014b0:	53                   	push   %ebx
  8014b1:	83 ec 0c             	sub    $0xc,%esp
  8014b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014bf:	eb 21                	jmp    8014e2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014c1:	83 ec 04             	sub    $0x4,%esp
  8014c4:	89 f0                	mov    %esi,%eax
  8014c6:	29 d8                	sub    %ebx,%eax
  8014c8:	50                   	push   %eax
  8014c9:	89 d8                	mov    %ebx,%eax
  8014cb:	03 45 0c             	add    0xc(%ebp),%eax
  8014ce:	50                   	push   %eax
  8014cf:	57                   	push   %edi
  8014d0:	e8 45 ff ff ff       	call   80141a <read>
		if (m < 0)
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	78 10                	js     8014ec <readn+0x41>
			return m;
		if (m == 0)
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	74 0a                	je     8014ea <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014e0:	01 c3                	add    %eax,%ebx
  8014e2:	39 f3                	cmp    %esi,%ebx
  8014e4:	72 db                	jb     8014c1 <readn+0x16>
  8014e6:	89 d8                	mov    %ebx,%eax
  8014e8:	eb 02                	jmp    8014ec <readn+0x41>
  8014ea:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ef:	5b                   	pop    %ebx
  8014f0:	5e                   	pop    %esi
  8014f1:	5f                   	pop    %edi
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 14             	sub    $0x14,%esp
  8014fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801501:	50                   	push   %eax
  801502:	53                   	push   %ebx
  801503:	e8 ac fc ff ff       	call   8011b4 <fd_lookup>
  801508:	83 c4 08             	add    $0x8,%esp
  80150b:	89 c2                	mov    %eax,%edx
  80150d:	85 c0                	test   %eax,%eax
  80150f:	78 68                	js     801579 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801517:	50                   	push   %eax
  801518:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151b:	ff 30                	pushl  (%eax)
  80151d:	e8 e8 fc ff ff       	call   80120a <dev_lookup>
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	85 c0                	test   %eax,%eax
  801527:	78 47                	js     801570 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801529:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801530:	75 21                	jne    801553 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801532:	a1 08 40 80 00       	mov    0x804008,%eax
  801537:	8b 40 48             	mov    0x48(%eax),%eax
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	53                   	push   %ebx
  80153e:	50                   	push   %eax
  80153f:	68 d5 26 80 00       	push   $0x8026d5
  801544:	e8 a8 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801551:	eb 26                	jmp    801579 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801553:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801556:	8b 52 0c             	mov    0xc(%edx),%edx
  801559:	85 d2                	test   %edx,%edx
  80155b:	74 17                	je     801574 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	ff 75 10             	pushl  0x10(%ebp)
  801563:	ff 75 0c             	pushl  0xc(%ebp)
  801566:	50                   	push   %eax
  801567:	ff d2                	call   *%edx
  801569:	89 c2                	mov    %eax,%edx
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	eb 09                	jmp    801579 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801570:	89 c2                	mov    %eax,%edx
  801572:	eb 05                	jmp    801579 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801574:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801579:	89 d0                	mov    %edx,%eax
  80157b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <seek>:

int
seek(int fdnum, off_t offset)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801586:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	ff 75 08             	pushl  0x8(%ebp)
  80158d:	e8 22 fc ff ff       	call   8011b4 <fd_lookup>
  801592:	83 c4 08             	add    $0x8,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	78 0e                	js     8015a7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801599:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80159c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 14             	sub    $0x14,%esp
  8015b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	53                   	push   %ebx
  8015b8:	e8 f7 fb ff ff       	call   8011b4 <fd_lookup>
  8015bd:	83 c4 08             	add    $0x8,%esp
  8015c0:	89 c2                	mov    %eax,%edx
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 65                	js     80162b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d0:	ff 30                	pushl  (%eax)
  8015d2:	e8 33 fc ff ff       	call   80120a <dev_lookup>
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 44                	js     801622 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e5:	75 21                	jne    801608 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e7:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ec:	8b 40 48             	mov    0x48(%eax),%eax
  8015ef:	83 ec 04             	sub    $0x4,%esp
  8015f2:	53                   	push   %ebx
  8015f3:	50                   	push   %eax
  8015f4:	68 98 26 80 00       	push   $0x802698
  8015f9:	e8 f3 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801606:	eb 23                	jmp    80162b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801608:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160b:	8b 52 18             	mov    0x18(%edx),%edx
  80160e:	85 d2                	test   %edx,%edx
  801610:	74 14                	je     801626 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	ff 75 0c             	pushl  0xc(%ebp)
  801618:	50                   	push   %eax
  801619:	ff d2                	call   *%edx
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	eb 09                	jmp    80162b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801622:	89 c2                	mov    %eax,%edx
  801624:	eb 05                	jmp    80162b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801626:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80162b:	89 d0                	mov    %edx,%eax
  80162d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	53                   	push   %ebx
  801636:	83 ec 14             	sub    $0x14,%esp
  801639:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163f:	50                   	push   %eax
  801640:	ff 75 08             	pushl  0x8(%ebp)
  801643:	e8 6c fb ff ff       	call   8011b4 <fd_lookup>
  801648:	83 c4 08             	add    $0x8,%esp
  80164b:	89 c2                	mov    %eax,%edx
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 58                	js     8016a9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801657:	50                   	push   %eax
  801658:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165b:	ff 30                	pushl  (%eax)
  80165d:	e8 a8 fb ff ff       	call   80120a <dev_lookup>
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	85 c0                	test   %eax,%eax
  801667:	78 37                	js     8016a0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801669:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801670:	74 32                	je     8016a4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801672:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801675:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80167c:	00 00 00 
	stat->st_isdir = 0;
  80167f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801686:	00 00 00 
	stat->st_dev = dev;
  801689:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	53                   	push   %ebx
  801693:	ff 75 f0             	pushl  -0x10(%ebp)
  801696:	ff 50 14             	call   *0x14(%eax)
  801699:	89 c2                	mov    %eax,%edx
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	eb 09                	jmp    8016a9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	eb 05                	jmp    8016a9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a9:	89 d0                	mov    %edx,%eax
  8016ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	6a 00                	push   $0x0
  8016ba:	ff 75 08             	pushl  0x8(%ebp)
  8016bd:	e8 2c 02 00 00       	call   8018ee <open>
  8016c2:	89 c3                	mov    %eax,%ebx
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 1b                	js     8016e6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016cb:	83 ec 08             	sub    $0x8,%esp
  8016ce:	ff 75 0c             	pushl  0xc(%ebp)
  8016d1:	50                   	push   %eax
  8016d2:	e8 5b ff ff ff       	call   801632 <fstat>
  8016d7:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d9:	89 1c 24             	mov    %ebx,(%esp)
  8016dc:	e8 fd fb ff ff       	call   8012de <close>
	return r;
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	89 f0                	mov    %esi,%eax
}
  8016e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e9:	5b                   	pop    %ebx
  8016ea:	5e                   	pop    %esi
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    

008016ed <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	56                   	push   %esi
  8016f1:	53                   	push   %ebx
  8016f2:	89 c6                	mov    %eax,%esi
  8016f4:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  8016f6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016fd:	75 12                	jne    801711 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  8016ff:	83 ec 0c             	sub    $0xc,%esp
  801702:	6a 01                	push   $0x1
  801704:	e8 fc f9 ff ff       	call   801105 <ipc_find_env>
  801709:	a3 00 40 80 00       	mov    %eax,0x804000
  80170e:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801711:	6a 07                	push   $0x7
  801713:	68 00 50 80 00       	push   $0x805000
  801718:	56                   	push   %esi
  801719:	ff 35 00 40 80 00    	pushl  0x804000
  80171f:	e8 8d f9 ff ff       	call   8010b1 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  801724:	83 c4 0c             	add    $0xc,%esp
  801727:	6a 00                	push   $0x0
  801729:	53                   	push   %ebx
  80172a:	6a 00                	push   $0x0
  80172c:	e8 21 f9 ff ff       	call   801052 <ipc_recv>
}
  801731:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801734:	5b                   	pop    %ebx
  801735:	5e                   	pop    %esi
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    

00801738 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	8b 40 0c             	mov    0xc(%eax),%eax
  801744:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  801749:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174c:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  801751:	ba 00 00 00 00       	mov    $0x0,%edx
  801756:	b8 02 00 00 00       	mov    $0x2,%eax
  80175b:	e8 8d ff ff ff       	call   8016ed <fsipc>
}
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801768:	8b 45 08             	mov    0x8(%ebp),%eax
  80176b:	8b 40 0c             	mov    0xc(%eax),%eax
  80176e:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  801773:	ba 00 00 00 00       	mov    $0x0,%edx
  801778:	b8 06 00 00 00       	mov    $0x6,%eax
  80177d:	e8 6b ff ff ff       	call   8016ed <fsipc>
}
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	53                   	push   %ebx
  801788:	83 ec 04             	sub    $0x4,%esp
  80178b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	8b 40 0c             	mov    0xc(%eax),%eax
  801794:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801799:	ba 00 00 00 00       	mov    $0x0,%edx
  80179e:	b8 05 00 00 00       	mov    $0x5,%eax
  8017a3:	e8 45 ff ff ff       	call   8016ed <fsipc>
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	78 2c                	js     8017d8 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ac:	83 ec 08             	sub    $0x8,%esp
  8017af:	68 00 50 80 00       	push   $0x805000
  8017b4:	53                   	push   %ebx
  8017b5:	e8 bc ef ff ff       	call   800776 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8017ba:	a1 80 50 80 00       	mov    0x805080,%eax
  8017bf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c5:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8017d0:	83 c4 10             	add    $0x10,%esp
  8017d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017db:	c9                   	leave  
  8017dc:	c3                   	ret    

008017dd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	53                   	push   %ebx
  8017e1:	83 ec 08             	sub    $0x8,%esp
  8017e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ed:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  8017f2:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  8017f8:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8017fe:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801803:	0f 46 c3             	cmovbe %ebx,%eax
  801806:	50                   	push   %eax
  801807:	ff 75 0c             	pushl  0xc(%ebp)
  80180a:	68 08 50 80 00       	push   $0x805008
  80180f:	e8 f4 f0 ff ff       	call   800908 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  801814:	ba 00 00 00 00       	mov    $0x0,%edx
  801819:	b8 04 00 00 00       	mov    $0x4,%eax
  80181e:	e8 ca fe ff ff       	call   8016ed <fsipc>
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	85 c0                	test   %eax,%eax
  801828:	78 3d                	js     801867 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  80182a:	39 c3                	cmp    %eax,%ebx
  80182c:	73 19                	jae    801847 <devfile_write+0x6a>
  80182e:	68 04 27 80 00       	push   $0x802704
  801833:	68 0b 27 80 00       	push   $0x80270b
  801838:	68 9a 00 00 00       	push   $0x9a
  80183d:	68 20 27 80 00       	push   $0x802720
  801842:	e8 2a 06 00 00       	call   801e71 <_panic>
	   assert (r <= bytes_written);
  801847:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80184c:	7e 19                	jle    801867 <devfile_write+0x8a>
  80184e:	68 2b 27 80 00       	push   $0x80272b
  801853:	68 0b 27 80 00       	push   $0x80270b
  801858:	68 9b 00 00 00       	push   $0x9b
  80185d:	68 20 27 80 00       	push   $0x802720
  801862:	e8 0a 06 00 00       	call   801e71 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	56                   	push   %esi
  801870:	53                   	push   %ebx
  801871:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  801874:	8b 45 08             	mov    0x8(%ebp),%eax
  801877:	8b 40 0c             	mov    0xc(%eax),%eax
  80187a:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  80187f:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801885:	ba 00 00 00 00       	mov    $0x0,%edx
  80188a:	b8 03 00 00 00       	mov    $0x3,%eax
  80188f:	e8 59 fe ff ff       	call   8016ed <fsipc>
  801894:	89 c3                	mov    %eax,%ebx
  801896:	85 c0                	test   %eax,%eax
  801898:	78 4b                	js     8018e5 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  80189a:	39 c6                	cmp    %eax,%esi
  80189c:	73 16                	jae    8018b4 <devfile_read+0x48>
  80189e:	68 04 27 80 00       	push   $0x802704
  8018a3:	68 0b 27 80 00       	push   $0x80270b
  8018a8:	6a 7c                	push   $0x7c
  8018aa:	68 20 27 80 00       	push   $0x802720
  8018af:	e8 bd 05 00 00       	call   801e71 <_panic>
	   assert(r <= PGSIZE);
  8018b4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b9:	7e 16                	jle    8018d1 <devfile_read+0x65>
  8018bb:	68 3e 27 80 00       	push   $0x80273e
  8018c0:	68 0b 27 80 00       	push   $0x80270b
  8018c5:	6a 7d                	push   $0x7d
  8018c7:	68 20 27 80 00       	push   $0x802720
  8018cc:	e8 a0 05 00 00       	call   801e71 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d1:	83 ec 04             	sub    $0x4,%esp
  8018d4:	50                   	push   %eax
  8018d5:	68 00 50 80 00       	push   $0x805000
  8018da:	ff 75 0c             	pushl  0xc(%ebp)
  8018dd:	e8 26 f0 ff ff       	call   800908 <memmove>
	   return r;
  8018e2:	83 c4 10             	add    $0x10,%esp
}
  8018e5:	89 d8                	mov    %ebx,%eax
  8018e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5d                   	pop    %ebp
  8018ed:	c3                   	ret    

008018ee <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	53                   	push   %ebx
  8018f2:	83 ec 20             	sub    $0x20,%esp
  8018f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  8018f8:	53                   	push   %ebx
  8018f9:	e8 3f ee ff ff       	call   80073d <strlen>
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801906:	7f 67                	jg     80196f <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190e:	50                   	push   %eax
  80190f:	e8 51 f8 ff ff       	call   801165 <fd_alloc>
  801914:	83 c4 10             	add    $0x10,%esp
			 return r;
  801917:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801919:	85 c0                	test   %eax,%eax
  80191b:	78 57                	js     801974 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	53                   	push   %ebx
  801921:	68 00 50 80 00       	push   $0x805000
  801926:	e8 4b ee ff ff       	call   800776 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  80192b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192e:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801933:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801936:	b8 01 00 00 00       	mov    $0x1,%eax
  80193b:	e8 ad fd ff ff       	call   8016ed <fsipc>
  801940:	89 c3                	mov    %eax,%ebx
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	85 c0                	test   %eax,%eax
  801947:	79 14                	jns    80195d <open+0x6f>
			 fd_close(fd, 0);
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	6a 00                	push   $0x0
  80194e:	ff 75 f4             	pushl  -0xc(%ebp)
  801951:	e8 07 f9 ff ff       	call   80125d <fd_close>
			 return r;
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	89 da                	mov    %ebx,%edx
  80195b:	eb 17                	jmp    801974 <open+0x86>
	   }

	   return fd2num(fd);
  80195d:	83 ec 0c             	sub    $0xc,%esp
  801960:	ff 75 f4             	pushl  -0xc(%ebp)
  801963:	e8 d6 f7 ff ff       	call   80113e <fd2num>
  801968:	89 c2                	mov    %eax,%edx
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	eb 05                	jmp    801974 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  80196f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801974:	89 d0                	mov    %edx,%eax
  801976:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801979:	c9                   	leave  
  80197a:	c3                   	ret    

0080197b <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801981:	ba 00 00 00 00       	mov    $0x0,%edx
  801986:	b8 08 00 00 00       	mov    $0x8,%eax
  80198b:	e8 5d fd ff ff       	call   8016ed <fsipc>
}
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	56                   	push   %esi
  801996:	53                   	push   %ebx
  801997:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80199a:	83 ec 0c             	sub    $0xc,%esp
  80199d:	ff 75 08             	pushl  0x8(%ebp)
  8019a0:	e8 a9 f7 ff ff       	call   80114e <fd2data>
  8019a5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019a7:	83 c4 08             	add    $0x8,%esp
  8019aa:	68 4a 27 80 00       	push   $0x80274a
  8019af:	53                   	push   %ebx
  8019b0:	e8 c1 ed ff ff       	call   800776 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019b5:	8b 46 04             	mov    0x4(%esi),%eax
  8019b8:	2b 06                	sub    (%esi),%eax
  8019ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019c0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019c7:	00 00 00 
	stat->st_dev = &devpipe;
  8019ca:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019d1:	30 80 00 
	return 0;
}
  8019d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019dc:	5b                   	pop    %ebx
  8019dd:	5e                   	pop    %esi
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 0c             	sub    $0xc,%esp
  8019e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019ea:	53                   	push   %ebx
  8019eb:	6a 00                	push   $0x0
  8019ed:	e8 0c f2 ff ff       	call   800bfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019f2:	89 1c 24             	mov    %ebx,(%esp)
  8019f5:	e8 54 f7 ff ff       	call   80114e <fd2data>
  8019fa:	83 c4 08             	add    $0x8,%esp
  8019fd:	50                   	push   %eax
  8019fe:	6a 00                	push   $0x0
  801a00:	e8 f9 f1 ff ff       	call   800bfe <sys_page_unmap>
}
  801a05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	57                   	push   %edi
  801a0e:	56                   	push   %esi
  801a0f:	53                   	push   %ebx
  801a10:	83 ec 1c             	sub    $0x1c,%esp
  801a13:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a16:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a18:	a1 08 40 80 00       	mov    0x804008,%eax
  801a1d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	ff 75 e0             	pushl  -0x20(%ebp)
  801a26:	e8 0b 05 00 00       	call   801f36 <pageref>
  801a2b:	89 c3                	mov    %eax,%ebx
  801a2d:	89 3c 24             	mov    %edi,(%esp)
  801a30:	e8 01 05 00 00       	call   801f36 <pageref>
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	39 c3                	cmp    %eax,%ebx
  801a3a:	0f 94 c1             	sete   %cl
  801a3d:	0f b6 c9             	movzbl %cl,%ecx
  801a40:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a43:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a49:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a4c:	39 ce                	cmp    %ecx,%esi
  801a4e:	74 1b                	je     801a6b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a50:	39 c3                	cmp    %eax,%ebx
  801a52:	75 c4                	jne    801a18 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a54:	8b 42 58             	mov    0x58(%edx),%eax
  801a57:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a5a:	50                   	push   %eax
  801a5b:	56                   	push   %esi
  801a5c:	68 51 27 80 00       	push   $0x802751
  801a61:	e8 8b e7 ff ff       	call   8001f1 <cprintf>
  801a66:	83 c4 10             	add    $0x10,%esp
  801a69:	eb ad                	jmp    801a18 <_pipeisclosed+0xe>
	}
}
  801a6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5f                   	pop    %edi
  801a74:	5d                   	pop    %ebp
  801a75:	c3                   	ret    

00801a76 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	57                   	push   %edi
  801a7a:	56                   	push   %esi
  801a7b:	53                   	push   %ebx
  801a7c:	83 ec 28             	sub    $0x28,%esp
  801a7f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a82:	56                   	push   %esi
  801a83:	e8 c6 f6 ff ff       	call   80114e <fd2data>
  801a88:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	bf 00 00 00 00       	mov    $0x0,%edi
  801a92:	eb 4b                	jmp    801adf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a94:	89 da                	mov    %ebx,%edx
  801a96:	89 f0                	mov    %esi,%eax
  801a98:	e8 6d ff ff ff       	call   801a0a <_pipeisclosed>
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	75 48                	jne    801ae9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aa1:	e8 b4 f0 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aa6:	8b 43 04             	mov    0x4(%ebx),%eax
  801aa9:	8b 0b                	mov    (%ebx),%ecx
  801aab:	8d 51 20             	lea    0x20(%ecx),%edx
  801aae:	39 d0                	cmp    %edx,%eax
  801ab0:	73 e2                	jae    801a94 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ab9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801abc:	89 c2                	mov    %eax,%edx
  801abe:	c1 fa 1f             	sar    $0x1f,%edx
  801ac1:	89 d1                	mov    %edx,%ecx
  801ac3:	c1 e9 1b             	shr    $0x1b,%ecx
  801ac6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ac9:	83 e2 1f             	and    $0x1f,%edx
  801acc:	29 ca                	sub    %ecx,%edx
  801ace:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ad2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ad6:	83 c0 01             	add    $0x1,%eax
  801ad9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801adc:	83 c7 01             	add    $0x1,%edi
  801adf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ae2:	75 c2                	jne    801aa6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ae4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae7:	eb 05                	jmp    801aee <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ae9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af1:	5b                   	pop    %ebx
  801af2:	5e                   	pop    %esi
  801af3:	5f                   	pop    %edi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	57                   	push   %edi
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
  801afc:	83 ec 18             	sub    $0x18,%esp
  801aff:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b02:	57                   	push   %edi
  801b03:	e8 46 f6 ff ff       	call   80114e <fd2data>
  801b08:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b12:	eb 3d                	jmp    801b51 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b14:	85 db                	test   %ebx,%ebx
  801b16:	74 04                	je     801b1c <devpipe_read+0x26>
				return i;
  801b18:	89 d8                	mov    %ebx,%eax
  801b1a:	eb 44                	jmp    801b60 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b1c:	89 f2                	mov    %esi,%edx
  801b1e:	89 f8                	mov    %edi,%eax
  801b20:	e8 e5 fe ff ff       	call   801a0a <_pipeisclosed>
  801b25:	85 c0                	test   %eax,%eax
  801b27:	75 32                	jne    801b5b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b29:	e8 2c f0 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b2e:	8b 06                	mov    (%esi),%eax
  801b30:	3b 46 04             	cmp    0x4(%esi),%eax
  801b33:	74 df                	je     801b14 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b35:	99                   	cltd   
  801b36:	c1 ea 1b             	shr    $0x1b,%edx
  801b39:	01 d0                	add    %edx,%eax
  801b3b:	83 e0 1f             	and    $0x1f,%eax
  801b3e:	29 d0                	sub    %edx,%eax
  801b40:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b48:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b4b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4e:	83 c3 01             	add    $0x1,%ebx
  801b51:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b54:	75 d8                	jne    801b2e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b56:	8b 45 10             	mov    0x10(%ebp),%eax
  801b59:	eb 05                	jmp    801b60 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b5b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5f                   	pop    %edi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b73:	50                   	push   %eax
  801b74:	e8 ec f5 ff ff       	call   801165 <fd_alloc>
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	89 c2                	mov    %eax,%edx
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	0f 88 2c 01 00 00    	js     801cb2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b86:	83 ec 04             	sub    $0x4,%esp
  801b89:	68 07 04 00 00       	push   $0x407
  801b8e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b91:	6a 00                	push   $0x0
  801b93:	e8 e1 ef ff ff       	call   800b79 <sys_page_alloc>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	89 c2                	mov    %eax,%edx
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	0f 88 0d 01 00 00    	js     801cb2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ba5:	83 ec 0c             	sub    $0xc,%esp
  801ba8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bab:	50                   	push   %eax
  801bac:	e8 b4 f5 ff ff       	call   801165 <fd_alloc>
  801bb1:	89 c3                	mov    %eax,%ebx
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	0f 88 e2 00 00 00    	js     801ca0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbe:	83 ec 04             	sub    $0x4,%esp
  801bc1:	68 07 04 00 00       	push   $0x407
  801bc6:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc9:	6a 00                	push   $0x0
  801bcb:	e8 a9 ef ff ff       	call   800b79 <sys_page_alloc>
  801bd0:	89 c3                	mov    %eax,%ebx
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	0f 88 c3 00 00 00    	js     801ca0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bdd:	83 ec 0c             	sub    $0xc,%esp
  801be0:	ff 75 f4             	pushl  -0xc(%ebp)
  801be3:	e8 66 f5 ff ff       	call   80114e <fd2data>
  801be8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bea:	83 c4 0c             	add    $0xc,%esp
  801bed:	68 07 04 00 00       	push   $0x407
  801bf2:	50                   	push   %eax
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 7f ef ff ff       	call   800b79 <sys_page_alloc>
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	0f 88 89 00 00 00    	js     801c90 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c07:	83 ec 0c             	sub    $0xc,%esp
  801c0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0d:	e8 3c f5 ff ff       	call   80114e <fd2data>
  801c12:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c19:	50                   	push   %eax
  801c1a:	6a 00                	push   $0x0
  801c1c:	56                   	push   %esi
  801c1d:	6a 00                	push   $0x0
  801c1f:	e8 98 ef ff ff       	call   800bbc <sys_page_map>
  801c24:	89 c3                	mov    %eax,%ebx
  801c26:	83 c4 20             	add    $0x20,%esp
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	78 55                	js     801c82 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c36:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c42:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c50:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c57:	83 ec 0c             	sub    $0xc,%esp
  801c5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5d:	e8 dc f4 ff ff       	call   80113e <fd2num>
  801c62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c65:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c67:	83 c4 04             	add    $0x4,%esp
  801c6a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6d:	e8 cc f4 ff ff       	call   80113e <fd2num>
  801c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c75:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c80:	eb 30                	jmp    801cb2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c82:	83 ec 08             	sub    $0x8,%esp
  801c85:	56                   	push   %esi
  801c86:	6a 00                	push   $0x0
  801c88:	e8 71 ef ff ff       	call   800bfe <sys_page_unmap>
  801c8d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c90:	83 ec 08             	sub    $0x8,%esp
  801c93:	ff 75 f0             	pushl  -0x10(%ebp)
  801c96:	6a 00                	push   $0x0
  801c98:	e8 61 ef ff ff       	call   800bfe <sys_page_unmap>
  801c9d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ca0:	83 ec 08             	sub    $0x8,%esp
  801ca3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 51 ef ff ff       	call   800bfe <sys_page_unmap>
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cb2:	89 d0                	mov    %edx,%eax
  801cb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc4:	50                   	push   %eax
  801cc5:	ff 75 08             	pushl  0x8(%ebp)
  801cc8:	e8 e7 f4 ff ff       	call   8011b4 <fd_lookup>
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	78 18                	js     801cec <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cd4:	83 ec 0c             	sub    $0xc,%esp
  801cd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cda:	e8 6f f4 ff ff       	call   80114e <fd2data>
	return _pipeisclosed(fd, p);
  801cdf:	89 c2                	mov    %eax,%edx
  801ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce4:	e8 21 fd ff ff       	call   801a0a <_pipeisclosed>
  801ce9:	83 c4 10             	add    $0x10,%esp
}
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    

00801cf8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cfe:	68 69 27 80 00       	push   $0x802769
  801d03:	ff 75 0c             	pushl  0xc(%ebp)
  801d06:	e8 6b ea ff ff       	call   800776 <strcpy>
	return 0;
}
  801d0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d10:	c9                   	leave  
  801d11:	c3                   	ret    

00801d12 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	57                   	push   %edi
  801d16:	56                   	push   %esi
  801d17:	53                   	push   %ebx
  801d18:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d1e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d23:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d29:	eb 2d                	jmp    801d58 <devcons_write+0x46>
		m = n - tot;
  801d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d2e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d30:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d33:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d38:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d3b:	83 ec 04             	sub    $0x4,%esp
  801d3e:	53                   	push   %ebx
  801d3f:	03 45 0c             	add    0xc(%ebp),%eax
  801d42:	50                   	push   %eax
  801d43:	57                   	push   %edi
  801d44:	e8 bf eb ff ff       	call   800908 <memmove>
		sys_cputs(buf, m);
  801d49:	83 c4 08             	add    $0x8,%esp
  801d4c:	53                   	push   %ebx
  801d4d:	57                   	push   %edi
  801d4e:	e8 6a ed ff ff       	call   800abd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d53:	01 de                	add    %ebx,%esi
  801d55:	83 c4 10             	add    $0x10,%esp
  801d58:	89 f0                	mov    %esi,%eax
  801d5a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d5d:	72 cc                	jb     801d2b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d62:	5b                   	pop    %ebx
  801d63:	5e                   	pop    %esi
  801d64:	5f                   	pop    %edi
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	83 ec 08             	sub    $0x8,%esp
  801d6d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d76:	74 2a                	je     801da2 <devcons_read+0x3b>
  801d78:	eb 05                	jmp    801d7f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d7a:	e8 db ed ff ff       	call   800b5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d7f:	e8 57 ed ff ff       	call   800adb <sys_cgetc>
  801d84:	85 c0                	test   %eax,%eax
  801d86:	74 f2                	je     801d7a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	78 16                	js     801da2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d8c:	83 f8 04             	cmp    $0x4,%eax
  801d8f:	74 0c                	je     801d9d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d91:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d94:	88 02                	mov    %al,(%edx)
	return 1;
  801d96:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9b:	eb 05                	jmp    801da2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d9d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801daa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dad:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801db0:	6a 01                	push   $0x1
  801db2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db5:	50                   	push   %eax
  801db6:	e8 02 ed ff ff       	call   800abd <sys_cputs>
}
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <getchar>:

int
getchar(void)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dc6:	6a 01                	push   $0x1
  801dc8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dcb:	50                   	push   %eax
  801dcc:	6a 00                	push   $0x0
  801dce:	e8 47 f6 ff ff       	call   80141a <read>
	if (r < 0)
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	78 0f                	js     801de9 <getchar+0x29>
		return r;
	if (r < 1)
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	7e 06                	jle    801de4 <getchar+0x24>
		return -E_EOF;
	return c;
  801dde:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de2:	eb 05                	jmp    801de9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801de4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df4:	50                   	push   %eax
  801df5:	ff 75 08             	pushl  0x8(%ebp)
  801df8:	e8 b7 f3 ff ff       	call   8011b4 <fd_lookup>
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 11                	js     801e15 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e07:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e0d:	39 10                	cmp    %edx,(%eax)
  801e0f:	0f 94 c0             	sete   %al
  801e12:	0f b6 c0             	movzbl %al,%eax
}
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <opencons>:

int
opencons(void)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e20:	50                   	push   %eax
  801e21:	e8 3f f3 ff ff       	call   801165 <fd_alloc>
  801e26:	83 c4 10             	add    $0x10,%esp
		return r;
  801e29:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	78 3e                	js     801e6d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e2f:	83 ec 04             	sub    $0x4,%esp
  801e32:	68 07 04 00 00       	push   $0x407
  801e37:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3a:	6a 00                	push   $0x0
  801e3c:	e8 38 ed ff ff       	call   800b79 <sys_page_alloc>
  801e41:	83 c4 10             	add    $0x10,%esp
		return r;
  801e44:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e46:	85 c0                	test   %eax,%eax
  801e48:	78 23                	js     801e6d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e4a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e53:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e58:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e5f:	83 ec 0c             	sub    $0xc,%esp
  801e62:	50                   	push   %eax
  801e63:	e8 d6 f2 ff ff       	call   80113e <fd2num>
  801e68:	89 c2                	mov    %eax,%edx
  801e6a:	83 c4 10             	add    $0x10,%esp
}
  801e6d:	89 d0                	mov    %edx,%eax
  801e6f:	c9                   	leave  
  801e70:	c3                   	ret    

00801e71 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	56                   	push   %esi
  801e75:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e76:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e79:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e7f:	e8 b7 ec ff ff       	call   800b3b <sys_getenvid>
  801e84:	83 ec 0c             	sub    $0xc,%esp
  801e87:	ff 75 0c             	pushl  0xc(%ebp)
  801e8a:	ff 75 08             	pushl  0x8(%ebp)
  801e8d:	56                   	push   %esi
  801e8e:	50                   	push   %eax
  801e8f:	68 78 27 80 00       	push   $0x802778
  801e94:	e8 58 e3 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e99:	83 c4 18             	add    $0x18,%esp
  801e9c:	53                   	push   %ebx
  801e9d:	ff 75 10             	pushl  0x10(%ebp)
  801ea0:	e8 fb e2 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801ea5:	c7 04 24 62 27 80 00 	movl   $0x802762,(%esp)
  801eac:	e8 40 e3 ff ff       	call   8001f1 <cprintf>
  801eb1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eb4:	cc                   	int3   
  801eb5:	eb fd                	jmp    801eb4 <_panic+0x43>

00801eb7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  801ebd:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ec4:	75 2a                	jne    801ef0 <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801ec6:	83 ec 04             	sub    $0x4,%esp
  801ec9:	6a 06                	push   $0x6
  801ecb:	68 00 f0 bf ee       	push   $0xeebff000
  801ed0:	6a 00                	push   $0x0
  801ed2:	e8 a2 ec ff ff       	call   800b79 <sys_page_alloc>
			 if (a < 0)
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	85 c0                	test   %eax,%eax
  801edc:	79 12                	jns    801ef0 <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801ede:	50                   	push   %eax
  801edf:	68 9c 27 80 00       	push   $0x80279c
  801ee4:	6a 21                	push   $0x21
  801ee6:	68 b6 27 80 00       	push   $0x8027b6
  801eeb:	e8 81 ff ff ff       	call   801e71 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  801ef0:	e8 46 ec ff ff       	call   800b3b <sys_getenvid>
  801ef5:	83 ec 08             	sub    $0x8,%esp
  801ef8:	68 10 1f 80 00       	push   $0x801f10
  801efd:	50                   	push   %eax
  801efe:	e8 c1 ed ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  801f03:	8b 45 08             	mov    0x8(%ebp),%eax
  801f06:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	c9                   	leave  
  801f0f:	c3                   	ret    

00801f10 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  801f10:	54                   	push   %esp
movl _pgfault_handler, %eax
  801f11:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  801f16:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  801f18:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  801f1b:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  801f1f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  801f23:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  801f26:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  801f2a:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  801f2c:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  801f2f:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  801f30:	83 c4 04             	add    $0x4,%esp
popfl
  801f33:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  801f34:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  801f35:	c3                   	ret    

00801f36 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f36:	55                   	push   %ebp
  801f37:	89 e5                	mov    %esp,%ebp
  801f39:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3c:	89 d0                	mov    %edx,%eax
  801f3e:	c1 e8 16             	shr    $0x16,%eax
  801f41:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f48:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4d:	f6 c1 01             	test   $0x1,%cl
  801f50:	74 1d                	je     801f6f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f52:	c1 ea 0c             	shr    $0xc,%edx
  801f55:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f5c:	f6 c2 01             	test   $0x1,%dl
  801f5f:	74 0e                	je     801f6f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f61:	c1 ea 0c             	shr    $0xc,%edx
  801f64:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f6b:	ef 
  801f6c:	0f b7 c0             	movzwl %ax,%eax
}
  801f6f:	5d                   	pop    %ebp
  801f70:	c3                   	ret    
  801f71:	66 90                	xchg   %ax,%ax
  801f73:	66 90                	xchg   %ax,%ax
  801f75:	66 90                	xchg   %ax,%ax
  801f77:	66 90                	xchg   %ax,%ax
  801f79:	66 90                	xchg   %ax,%ax
  801f7b:	66 90                	xchg   %ax,%ax
  801f7d:	66 90                	xchg   %ax,%ax
  801f7f:	90                   	nop

00801f80 <__udivdi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f97:	85 f6                	test   %esi,%esi
  801f99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9d:	89 ca                	mov    %ecx,%edx
  801f9f:	89 f8                	mov    %edi,%eax
  801fa1:	75 3d                	jne    801fe0 <__udivdi3+0x60>
  801fa3:	39 cf                	cmp    %ecx,%edi
  801fa5:	0f 87 c5 00 00 00    	ja     802070 <__udivdi3+0xf0>
  801fab:	85 ff                	test   %edi,%edi
  801fad:	89 fd                	mov    %edi,%ebp
  801faf:	75 0b                	jne    801fbc <__udivdi3+0x3c>
  801fb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb6:	31 d2                	xor    %edx,%edx
  801fb8:	f7 f7                	div    %edi
  801fba:	89 c5                	mov    %eax,%ebp
  801fbc:	89 c8                	mov    %ecx,%eax
  801fbe:	31 d2                	xor    %edx,%edx
  801fc0:	f7 f5                	div    %ebp
  801fc2:	89 c1                	mov    %eax,%ecx
  801fc4:	89 d8                	mov    %ebx,%eax
  801fc6:	89 cf                	mov    %ecx,%edi
  801fc8:	f7 f5                	div    %ebp
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	89 d8                	mov    %ebx,%eax
  801fce:	89 fa                	mov    %edi,%edx
  801fd0:	83 c4 1c             	add    $0x1c,%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    
  801fd8:	90                   	nop
  801fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	39 ce                	cmp    %ecx,%esi
  801fe2:	77 74                	ja     802058 <__udivdi3+0xd8>
  801fe4:	0f bd fe             	bsr    %esi,%edi
  801fe7:	83 f7 1f             	xor    $0x1f,%edi
  801fea:	0f 84 98 00 00 00    	je     802088 <__udivdi3+0x108>
  801ff0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	89 c5                	mov    %eax,%ebp
  801ff9:	29 fb                	sub    %edi,%ebx
  801ffb:	d3 e6                	shl    %cl,%esi
  801ffd:	89 d9                	mov    %ebx,%ecx
  801fff:	d3 ed                	shr    %cl,%ebp
  802001:	89 f9                	mov    %edi,%ecx
  802003:	d3 e0                	shl    %cl,%eax
  802005:	09 ee                	or     %ebp,%esi
  802007:	89 d9                	mov    %ebx,%ecx
  802009:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80200d:	89 d5                	mov    %edx,%ebp
  80200f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802013:	d3 ed                	shr    %cl,%ebp
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e2                	shl    %cl,%edx
  802019:	89 d9                	mov    %ebx,%ecx
  80201b:	d3 e8                	shr    %cl,%eax
  80201d:	09 c2                	or     %eax,%edx
  80201f:	89 d0                	mov    %edx,%eax
  802021:	89 ea                	mov    %ebp,%edx
  802023:	f7 f6                	div    %esi
  802025:	89 d5                	mov    %edx,%ebp
  802027:	89 c3                	mov    %eax,%ebx
  802029:	f7 64 24 0c          	mull   0xc(%esp)
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	72 10                	jb     802041 <__udivdi3+0xc1>
  802031:	8b 74 24 08          	mov    0x8(%esp),%esi
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e6                	shl    %cl,%esi
  802039:	39 c6                	cmp    %eax,%esi
  80203b:	73 07                	jae    802044 <__udivdi3+0xc4>
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	75 03                	jne    802044 <__udivdi3+0xc4>
  802041:	83 eb 01             	sub    $0x1,%ebx
  802044:	31 ff                	xor    %edi,%edi
  802046:	89 d8                	mov    %ebx,%eax
  802048:	89 fa                	mov    %edi,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	31 ff                	xor    %edi,%edi
  80205a:	31 db                	xor    %ebx,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d8                	mov    %ebx,%eax
  802072:	f7 f7                	div    %edi
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 c3                	mov    %eax,%ebx
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	89 fa                	mov    %edi,%edx
  80207c:	83 c4 1c             	add    $0x1c,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    
  802084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802088:	39 ce                	cmp    %ecx,%esi
  80208a:	72 0c                	jb     802098 <__udivdi3+0x118>
  80208c:	31 db                	xor    %ebx,%ebx
  80208e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802092:	0f 87 34 ff ff ff    	ja     801fcc <__udivdi3+0x4c>
  802098:	bb 01 00 00 00       	mov    $0x1,%ebx
  80209d:	e9 2a ff ff ff       	jmp    801fcc <__udivdi3+0x4c>
  8020a2:	66 90                	xchg   %ax,%ax
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__umoddi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 d2                	test   %edx,%edx
  8020c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f3                	mov    %esi,%ebx
  8020d3:	89 3c 24             	mov    %edi,(%esp)
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	75 1c                	jne    8020f8 <__umoddi3+0x48>
  8020dc:	39 f7                	cmp    %esi,%edi
  8020de:	76 50                	jbe    802130 <__umoddi3+0x80>
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	f7 f7                	div    %edi
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	31 d2                	xor    %edx,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	39 f2                	cmp    %esi,%edx
  8020fa:	89 d0                	mov    %edx,%eax
  8020fc:	77 52                	ja     802150 <__umoddi3+0xa0>
  8020fe:	0f bd ea             	bsr    %edx,%ebp
  802101:	83 f5 1f             	xor    $0x1f,%ebp
  802104:	75 5a                	jne    802160 <__umoddi3+0xb0>
  802106:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80210a:	0f 82 e0 00 00 00    	jb     8021f0 <__umoddi3+0x140>
  802110:	39 0c 24             	cmp    %ecx,(%esp)
  802113:	0f 86 d7 00 00 00    	jbe    8021f0 <__umoddi3+0x140>
  802119:	8b 44 24 08          	mov    0x8(%esp),%eax
  80211d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802121:	83 c4 1c             	add    $0x1c,%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	85 ff                	test   %edi,%edi
  802132:	89 fd                	mov    %edi,%ebp
  802134:	75 0b                	jne    802141 <__umoddi3+0x91>
  802136:	b8 01 00 00 00       	mov    $0x1,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	f7 f7                	div    %edi
  80213f:	89 c5                	mov    %eax,%ebp
  802141:	89 f0                	mov    %esi,%eax
  802143:	31 d2                	xor    %edx,%edx
  802145:	f7 f5                	div    %ebp
  802147:	89 c8                	mov    %ecx,%eax
  802149:	f7 f5                	div    %ebp
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	eb 99                	jmp    8020e8 <__umoddi3+0x38>
  80214f:	90                   	nop
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	83 c4 1c             	add    $0x1c,%esp
  802157:	5b                   	pop    %ebx
  802158:	5e                   	pop    %esi
  802159:	5f                   	pop    %edi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	8b 34 24             	mov    (%esp),%esi
  802163:	bf 20 00 00 00       	mov    $0x20,%edi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	29 ef                	sub    %ebp,%edi
  80216c:	d3 e0                	shl    %cl,%eax
  80216e:	89 f9                	mov    %edi,%ecx
  802170:	89 f2                	mov    %esi,%edx
  802172:	d3 ea                	shr    %cl,%edx
  802174:	89 e9                	mov    %ebp,%ecx
  802176:	09 c2                	or     %eax,%edx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 14 24             	mov    %edx,(%esp)
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	d3 e2                	shl    %cl,%edx
  802181:	89 f9                	mov    %edi,%ecx
  802183:	89 54 24 04          	mov    %edx,0x4(%esp)
  802187:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	89 c6                	mov    %eax,%esi
  802191:	d3 e3                	shl    %cl,%ebx
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 d0                	mov    %edx,%eax
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	09 d8                	or     %ebx,%eax
  80219d:	89 d3                	mov    %edx,%ebx
  80219f:	89 f2                	mov    %esi,%edx
  8021a1:	f7 34 24             	divl   (%esp)
  8021a4:	89 d6                	mov    %edx,%esi
  8021a6:	d3 e3                	shl    %cl,%ebx
  8021a8:	f7 64 24 04          	mull   0x4(%esp)
  8021ac:	39 d6                	cmp    %edx,%esi
  8021ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021b2:	89 d1                	mov    %edx,%ecx
  8021b4:	89 c3                	mov    %eax,%ebx
  8021b6:	72 08                	jb     8021c0 <__umoddi3+0x110>
  8021b8:	75 11                	jne    8021cb <__umoddi3+0x11b>
  8021ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021be:	73 0b                	jae    8021cb <__umoddi3+0x11b>
  8021c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021c4:	1b 14 24             	sbb    (%esp),%edx
  8021c7:	89 d1                	mov    %edx,%ecx
  8021c9:	89 c3                	mov    %eax,%ebx
  8021cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021cf:	29 da                	sub    %ebx,%edx
  8021d1:	19 ce                	sbb    %ecx,%esi
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	d3 e0                	shl    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	d3 ea                	shr    %cl,%edx
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	d3 ee                	shr    %cl,%esi
  8021e1:	09 d0                	or     %edx,%eax
  8021e3:	89 f2                	mov    %esi,%edx
  8021e5:	83 c4 1c             	add    $0x1c,%esp
  8021e8:	5b                   	pop    %ebx
  8021e9:	5e                   	pop    %esi
  8021ea:	5f                   	pop    %edi
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
  8021f0:	29 f9                	sub    %edi,%ecx
  8021f2:	19 d6                	sbb    %edx,%esi
  8021f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021fc:	e9 18 ff ff ff       	jmp    802119 <__umoddi3+0x69>
