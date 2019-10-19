
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 a0 1e 80 00       	push   $0x801ea0
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 69 0a 00 00       	call   800abd <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 20 0a 00 00       	call   800a7c <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 7b 0c 00 00       	call   800cec <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80008b:	e8 2d 0a 00 00       	call   800abd <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 65 0e 00 00       	call   800f36 <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 a1 09 00 00       	call   800a7c <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 2f 09 00 00       	call   800a3f <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 54 01 00 00       	call   8002aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 d4 08 00 00       	call   800a3f <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ae:	39 d3                	cmp    %edx,%ebx
  8001b0:	72 05                	jb     8001b7 <printnum+0x30>
  8001b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b5:	77 45                	ja     8001fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	ff 75 10             	pushl  0x10(%ebp)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 35 1a 00 00       	call   801c10 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 18                	jmp    800206 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb 03                	jmp    8001ff <printnum+0x78>
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f e8                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	83 ec 04             	sub    $0x4,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 22 1b 00 00       	call   801d40 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 c6 1e 80 00 	movsbl 0x801ec6(%eax),%eax
  800228:	50                   	push   %eax
  800229:	ff d7                	call   *%edi
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800239:	83 fa 01             	cmp    $0x1,%edx
  80023c:	7e 0e                	jle    80024c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 08             	lea    0x8(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	8b 52 04             	mov    0x4(%edx),%edx
  80024a:	eb 22                	jmp    80026e <getuint+0x38>
	else if (lflag)
  80024c:	85 d2                	test   %edx,%edx
  80024e:	74 10                	je     800260 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 04             	lea    0x4(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
  80025e:	eb 0e                	jmp    80026e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 04             	lea    0x4(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800276:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	3b 50 04             	cmp    0x4(%eax),%edx
  80027f:	73 0a                	jae    80028b <sprintputch+0x1b>
		*b->buf++ = ch;
  800281:	8d 4a 01             	lea    0x1(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	88 02                	mov    %al,(%edx)
}
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800293:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800296:	50                   	push   %eax
  800297:	ff 75 10             	pushl  0x10(%ebp)
  80029a:	ff 75 0c             	pushl  0xc(%ebp)
  80029d:	ff 75 08             	pushl  0x8(%ebp)
  8002a0:	e8 05 00 00 00       	call   8002aa <vprintfmt>
	va_end(ap);
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 2c             	sub    $0x2c,%esp
  8002b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bc:	eb 12                	jmp    8002d0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	0f 84 89 03 00 00    	je     80064f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	53                   	push   %ebx
  8002ca:	50                   	push   %eax
  8002cb:	ff d6                	call   *%esi
  8002cd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d0:	83 c7 01             	add    $0x1,%edi
  8002d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d7:	83 f8 25             	cmp    $0x25,%eax
  8002da:	75 e2                	jne    8002be <vprintfmt+0x14>
  8002dc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fa:	eb 07                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ff:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8d 47 01             	lea    0x1(%edi),%eax
  800306:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800309:	0f b6 07             	movzbl (%edi),%eax
  80030c:	0f b6 c8             	movzbl %al,%ecx
  80030f:	83 e8 23             	sub    $0x23,%eax
  800312:	3c 55                	cmp    $0x55,%al
  800314:	0f 87 1a 03 00 00    	ja     800634 <vprintfmt+0x38a>
  80031a:	0f b6 c0             	movzbl %al,%eax
  80031d:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800327:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032b:	eb d6                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800330:	b8 00 00 00 00       	mov    $0x0,%eax
  800335:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800338:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80033f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800342:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800345:	83 fa 09             	cmp    $0x9,%edx
  800348:	77 39                	ja     800383 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80034d:	eb e9                	jmp    800338 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80034f:	8b 45 14             	mov    0x14(%ebp),%eax
  800352:	8d 48 04             	lea    0x4(%eax),%ecx
  800355:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800358:	8b 00                	mov    (%eax),%eax
  80035a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800360:	eb 27                	jmp    800389 <vprintfmt+0xdf>
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	85 c0                	test   %eax,%eax
  800367:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036c:	0f 49 c8             	cmovns %eax,%ecx
  80036f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800375:	eb 8c                	jmp    800303 <vprintfmt+0x59>
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800381:	eb 80                	jmp    800303 <vprintfmt+0x59>
  800383:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800386:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800389:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038d:	0f 89 70 ff ff ff    	jns    800303 <vprintfmt+0x59>
				width = precision, precision = -1;
  800393:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800396:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800399:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a0:	e9 5e ff ff ff       	jmp    800303 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ab:	e9 53 ff ff ff       	jmp    800303 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 50 04             	lea    0x4(%eax),%edx
  8003b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	53                   	push   %ebx
  8003bd:	ff 30                	pushl  (%eax)
  8003bf:	ff d6                	call   *%esi
			break;
  8003c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c7:	e9 04 ff ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 50 04             	lea    0x4(%eax),%edx
  8003d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	99                   	cltd   
  8003d8:	31 d0                	xor    %edx,%eax
  8003da:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dc:	83 f8 0f             	cmp    $0xf,%eax
  8003df:	7f 0b                	jg     8003ec <vprintfmt+0x142>
  8003e1:	8b 14 85 60 21 80 00 	mov    0x802160(,%eax,4),%edx
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	75 18                	jne    800404 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ec:	50                   	push   %eax
  8003ed:	68 de 1e 80 00       	push   $0x801ede
  8003f2:	53                   	push   %ebx
  8003f3:	56                   	push   %esi
  8003f4:	e8 94 fe ff ff       	call   80028d <printfmt>
  8003f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ff:	e9 cc fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800404:	52                   	push   %edx
  800405:	68 b9 22 80 00       	push   $0x8022b9
  80040a:	53                   	push   %ebx
  80040b:	56                   	push   %esi
  80040c:	e8 7c fe ff ff       	call   80028d <printfmt>
  800411:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800417:	e9 b4 fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
  800425:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800427:	85 ff                	test   %edi,%edi
  800429:	b8 d7 1e 80 00       	mov    $0x801ed7,%eax
  80042e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	0f 8e 94 00 00 00    	jle    8004cf <vprintfmt+0x225>
  80043b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80043f:	0f 84 98 00 00 00    	je     8004dd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	ff 75 d0             	pushl  -0x30(%ebp)
  80044b:	57                   	push   %edi
  80044c:	e8 86 02 00 00       	call   8006d7 <strnlen>
  800451:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800454:	29 c1                	sub    %eax,%ecx
  800456:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800459:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800460:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800463:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800466:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	eb 0f                	jmp    800479 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	53                   	push   %ebx
  80046e:	ff 75 e0             	pushl  -0x20(%ebp)
  800471:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	83 ef 01             	sub    $0x1,%edi
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	85 ff                	test   %edi,%edi
  80047b:	7f ed                	jg     80046a <vprintfmt+0x1c0>
  80047d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800480:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800483:	85 c9                	test   %ecx,%ecx
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	0f 49 c1             	cmovns %ecx,%eax
  80048d:	29 c1                	sub    %eax,%ecx
  80048f:	89 75 08             	mov    %esi,0x8(%ebp)
  800492:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800498:	89 cb                	mov    %ecx,%ebx
  80049a:	eb 4d                	jmp    8004e9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a0:	74 1b                	je     8004bd <vprintfmt+0x213>
  8004a2:	0f be c0             	movsbl %al,%eax
  8004a5:	83 e8 20             	sub    $0x20,%eax
  8004a8:	83 f8 5e             	cmp    $0x5e,%eax
  8004ab:	76 10                	jbe    8004bd <vprintfmt+0x213>
					putch('?', putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	6a 3f                	push   $0x3f
  8004b5:	ff 55 08             	call   *0x8(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	eb 0d                	jmp    8004ca <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	52                   	push   %edx
  8004c4:	ff 55 08             	call   *0x8(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	83 eb 01             	sub    $0x1,%ebx
  8004cd:	eb 1a                	jmp    8004e9 <vprintfmt+0x23f>
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004db:	eb 0c                	jmp    8004e9 <vprintfmt+0x23f>
  8004dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f0:	0f be d0             	movsbl %al,%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 23                	je     80051a <vprintfmt+0x270>
  8004f7:	85 f6                	test   %esi,%esi
  8004f9:	78 a1                	js     80049c <vprintfmt+0x1f2>
  8004fb:	83 ee 01             	sub    $0x1,%esi
  8004fe:	79 9c                	jns    80049c <vprintfmt+0x1f2>
  800500:	89 df                	mov    %ebx,%edi
  800502:	8b 75 08             	mov    0x8(%ebp),%esi
  800505:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800508:	eb 18                	jmp    800522 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	53                   	push   %ebx
  80050e:	6a 20                	push   $0x20
  800510:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800512:	83 ef 01             	sub    $0x1,%edi
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	eb 08                	jmp    800522 <vprintfmt+0x278>
  80051a:	89 df                	mov    %ebx,%edi
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	85 ff                	test   %edi,%edi
  800524:	7f e4                	jg     80050a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800529:	e9 a2 fd ff ff       	jmp    8002d0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052e:	83 fa 01             	cmp    $0x1,%edx
  800531:	7e 16                	jle    800549 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 08             	lea    0x8(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 50 04             	mov    0x4(%eax),%edx
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800544:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800547:	eb 32                	jmp    80057b <vprintfmt+0x2d1>
	else if (lflag)
  800549:	85 d2                	test   %edx,%edx
  80054b:	74 18                	je     800565 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 04             	lea    0x4(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055b:	89 c1                	mov    %eax,%ecx
  80055d:	c1 f9 1f             	sar    $0x1f,%ecx
  800560:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800563:	eb 16                	jmp    80057b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800573:	89 c1                	mov    %eax,%ecx
  800575:	c1 f9 1f             	sar    $0x1f,%ecx
  800578:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800581:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800586:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058a:	79 74                	jns    800600 <vprintfmt+0x356>
				putch('-', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	6a 2d                	push   $0x2d
  800592:	ff d6                	call   *%esi
				num = -(long long) num;
  800594:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800597:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059a:	f7 d8                	neg    %eax
  80059c:	83 d2 00             	adc    $0x0,%edx
  80059f:	f7 da                	neg    %edx
  8005a1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005a9:	eb 55                	jmp    800600 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	e8 83 fc ff ff       	call   800236 <getuint>
			base = 10;
  8005b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005b8:	eb 46                	jmp    800600 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bd:	e8 74 fc ff ff       	call   800236 <getuint>
			base = 8;
  8005c2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005c7:	eb 37                	jmp    800600 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 30                	push   $0x30
  8005cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d1:	83 c4 08             	add    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 78                	push   $0x78
  8005d7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 04             	lea    0x4(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ec:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f1:	eb 0d                	jmp    800600 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 3b fc ff ff       	call   800236 <getuint>
			base = 16;
  8005fb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800600:	83 ec 0c             	sub    $0xc,%esp
  800603:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800607:	57                   	push   %edi
  800608:	ff 75 e0             	pushl  -0x20(%ebp)
  80060b:	51                   	push   %ecx
  80060c:	52                   	push   %edx
  80060d:	50                   	push   %eax
  80060e:	89 da                	mov    %ebx,%edx
  800610:	89 f0                	mov    %esi,%eax
  800612:	e8 70 fb ff ff       	call   800187 <printnum>
			break;
  800617:	83 c4 20             	add    $0x20,%esp
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061d:	e9 ae fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	51                   	push   %ecx
  800627:	ff d6                	call   *%esi
			break;
  800629:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80062f:	e9 9c fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 25                	push   $0x25
  80063a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	eb 03                	jmp    800644 <vprintfmt+0x39a>
  800641:	83 ef 01             	sub    $0x1,%edi
  800644:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800648:	75 f7                	jne    800641 <vprintfmt+0x397>
  80064a:	e9 81 fc ff ff       	jmp    8002d0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80064f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800652:	5b                   	pop    %ebx
  800653:	5e                   	pop    %esi
  800654:	5f                   	pop    %edi
  800655:	5d                   	pop    %ebp
  800656:	c3                   	ret    

00800657 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	83 ec 18             	sub    $0x18,%esp
  80065d:	8b 45 08             	mov    0x8(%ebp),%eax
  800660:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800663:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800666:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800674:	85 c0                	test   %eax,%eax
  800676:	74 26                	je     80069e <vsnprintf+0x47>
  800678:	85 d2                	test   %edx,%edx
  80067a:	7e 22                	jle    80069e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067c:	ff 75 14             	pushl  0x14(%ebp)
  80067f:	ff 75 10             	pushl  0x10(%ebp)
  800682:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800685:	50                   	push   %eax
  800686:	68 70 02 80 00       	push   $0x800270
  80068b:	e8 1a fc ff ff       	call   8002aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800690:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800693:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	eb 05                	jmp    8006a3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a3:	c9                   	leave  
  8006a4:	c3                   	ret    

008006a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ae:	50                   	push   %eax
  8006af:	ff 75 10             	pushl  0x10(%ebp)
  8006b2:	ff 75 0c             	pushl  0xc(%ebp)
  8006b5:	ff 75 08             	pushl  0x8(%ebp)
  8006b8:	e8 9a ff ff ff       	call   800657 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ca:	eb 03                	jmp    8006cf <strlen+0x10>
		n++;
  8006cc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d3:	75 f7                	jne    8006cc <strlen+0xd>
		n++;
	return n;
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e5:	eb 03                	jmp    8006ea <strnlen+0x13>
		n++;
  8006e7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ea:	39 c2                	cmp    %eax,%edx
  8006ec:	74 08                	je     8006f6 <strnlen+0x1f>
  8006ee:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f2:	75 f3                	jne    8006e7 <strnlen+0x10>
  8006f4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	53                   	push   %ebx
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800702:	89 c2                	mov    %eax,%edx
  800704:	83 c2 01             	add    $0x1,%edx
  800707:	83 c1 01             	add    $0x1,%ecx
  80070a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800711:	84 db                	test   %bl,%bl
  800713:	75 ef                	jne    800704 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800715:	5b                   	pop    %ebx
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071f:	53                   	push   %ebx
  800720:	e8 9a ff ff ff       	call   8006bf <strlen>
  800725:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	01 d8                	add    %ebx,%eax
  80072d:	50                   	push   %eax
  80072e:	e8 c5 ff ff ff       	call   8006f8 <strcpy>
	return dst;
}
  800733:	89 d8                	mov    %ebx,%eax
  800735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	56                   	push   %esi
  80073e:	53                   	push   %ebx
  80073f:	8b 75 08             	mov    0x8(%ebp),%esi
  800742:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800745:	89 f3                	mov    %esi,%ebx
  800747:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074a:	89 f2                	mov    %esi,%edx
  80074c:	eb 0f                	jmp    80075d <strncpy+0x23>
		*dst++ = *src;
  80074e:	83 c2 01             	add    $0x1,%edx
  800751:	0f b6 01             	movzbl (%ecx),%eax
  800754:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800757:	80 39 01             	cmpb   $0x1,(%ecx)
  80075a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075d:	39 da                	cmp    %ebx,%edx
  80075f:	75 ed                	jne    80074e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800761:	89 f0                	mov    %esi,%eax
  800763:	5b                   	pop    %ebx
  800764:	5e                   	pop    %esi
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	8b 75 08             	mov    0x8(%ebp),%esi
  80076f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800772:	8b 55 10             	mov    0x10(%ebp),%edx
  800775:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800777:	85 d2                	test   %edx,%edx
  800779:	74 21                	je     80079c <strlcpy+0x35>
  80077b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80077f:	89 f2                	mov    %esi,%edx
  800781:	eb 09                	jmp    80078c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	83 c1 01             	add    $0x1,%ecx
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078c:	39 c2                	cmp    %eax,%edx
  80078e:	74 09                	je     800799 <strlcpy+0x32>
  800790:	0f b6 19             	movzbl (%ecx),%ebx
  800793:	84 db                	test   %bl,%bl
  800795:	75 ec                	jne    800783 <strlcpy+0x1c>
  800797:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800799:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079c:	29 f0                	sub    %esi,%eax
}
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ab:	eb 06                	jmp    8007b3 <strcmp+0x11>
		p++, q++;
  8007ad:	83 c1 01             	add    $0x1,%ecx
  8007b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b3:	0f b6 01             	movzbl (%ecx),%eax
  8007b6:	84 c0                	test   %al,%al
  8007b8:	74 04                	je     8007be <strcmp+0x1c>
  8007ba:	3a 02                	cmp    (%edx),%al
  8007bc:	74 ef                	je     8007ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007be:	0f b6 c0             	movzbl %al,%eax
  8007c1:	0f b6 12             	movzbl (%edx),%edx
  8007c4:	29 d0                	sub    %edx,%eax
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d2:	89 c3                	mov    %eax,%ebx
  8007d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d7:	eb 06                	jmp    8007df <strncmp+0x17>
		n--, p++, q++;
  8007d9:	83 c0 01             	add    $0x1,%eax
  8007dc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007df:	39 d8                	cmp    %ebx,%eax
  8007e1:	74 15                	je     8007f8 <strncmp+0x30>
  8007e3:	0f b6 08             	movzbl (%eax),%ecx
  8007e6:	84 c9                	test   %cl,%cl
  8007e8:	74 04                	je     8007ee <strncmp+0x26>
  8007ea:	3a 0a                	cmp    (%edx),%cl
  8007ec:	74 eb                	je     8007d9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ee:	0f b6 00             	movzbl (%eax),%eax
  8007f1:	0f b6 12             	movzbl (%edx),%edx
  8007f4:	29 d0                	sub    %edx,%eax
  8007f6:	eb 05                	jmp    8007fd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080a:	eb 07                	jmp    800813 <strchr+0x13>
		if (*s == c)
  80080c:	38 ca                	cmp    %cl,%dl
  80080e:	74 0f                	je     80081f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	0f b6 10             	movzbl (%eax),%edx
  800816:	84 d2                	test   %dl,%dl
  800818:	75 f2                	jne    80080c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	eb 03                	jmp    800830 <strfind+0xf>
  80082d:	83 c0 01             	add    $0x1,%eax
  800830:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800833:	38 ca                	cmp    %cl,%dl
  800835:	74 04                	je     80083b <strfind+0x1a>
  800837:	84 d2                	test   %dl,%dl
  800839:	75 f2                	jne    80082d <strfind+0xc>
			break;
	return (char *) s;
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	57                   	push   %edi
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 7d 08             	mov    0x8(%ebp),%edi
  800846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800849:	85 c9                	test   %ecx,%ecx
  80084b:	74 36                	je     800883 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800853:	75 28                	jne    80087d <memset+0x40>
  800855:	f6 c1 03             	test   $0x3,%cl
  800858:	75 23                	jne    80087d <memset+0x40>
		c &= 0xFF;
  80085a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085e:	89 d3                	mov    %edx,%ebx
  800860:	c1 e3 08             	shl    $0x8,%ebx
  800863:	89 d6                	mov    %edx,%esi
  800865:	c1 e6 18             	shl    $0x18,%esi
  800868:	89 d0                	mov    %edx,%eax
  80086a:	c1 e0 10             	shl    $0x10,%eax
  80086d:	09 f0                	or     %esi,%eax
  80086f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800871:	89 d8                	mov    %ebx,%eax
  800873:	09 d0                	or     %edx,%eax
  800875:	c1 e9 02             	shr    $0x2,%ecx
  800878:	fc                   	cld    
  800879:	f3 ab                	rep stos %eax,%es:(%edi)
  80087b:	eb 06                	jmp    800883 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	fc                   	cld    
  800881:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800883:	89 f8                	mov    %edi,%eax
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5f                   	pop    %edi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 75 0c             	mov    0xc(%ebp),%esi
  800895:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800898:	39 c6                	cmp    %eax,%esi
  80089a:	73 35                	jae    8008d1 <memmove+0x47>
  80089c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089f:	39 d0                	cmp    %edx,%eax
  8008a1:	73 2e                	jae    8008d1 <memmove+0x47>
		s += n;
		d += n;
  8008a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a6:	89 d6                	mov    %edx,%esi
  8008a8:	09 fe                	or     %edi,%esi
  8008aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b0:	75 13                	jne    8008c5 <memmove+0x3b>
  8008b2:	f6 c1 03             	test   $0x3,%cl
  8008b5:	75 0e                	jne    8008c5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008b7:	83 ef 04             	sub    $0x4,%edi
  8008ba:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bd:	c1 e9 02             	shr    $0x2,%ecx
  8008c0:	fd                   	std    
  8008c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c3:	eb 09                	jmp    8008ce <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c5:	83 ef 01             	sub    $0x1,%edi
  8008c8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008cb:	fd                   	std    
  8008cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ce:	fc                   	cld    
  8008cf:	eb 1d                	jmp    8008ee <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d1:	89 f2                	mov    %esi,%edx
  8008d3:	09 c2                	or     %eax,%edx
  8008d5:	f6 c2 03             	test   $0x3,%dl
  8008d8:	75 0f                	jne    8008e9 <memmove+0x5f>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 0a                	jne    8008e9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008df:	c1 e9 02             	shr    $0x2,%ecx
  8008e2:	89 c7                	mov    %eax,%edi
  8008e4:	fc                   	cld    
  8008e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e7:	eb 05                	jmp    8008ee <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e9:	89 c7                	mov    %eax,%edi
  8008eb:	fc                   	cld    
  8008ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f5:	ff 75 10             	pushl  0x10(%ebp)
  8008f8:	ff 75 0c             	pushl  0xc(%ebp)
  8008fb:	ff 75 08             	pushl  0x8(%ebp)
  8008fe:	e8 87 ff ff ff       	call   80088a <memmove>
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 c6                	mov    %eax,%esi
  800912:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800915:	eb 1a                	jmp    800931 <memcmp+0x2c>
		if (*s1 != *s2)
  800917:	0f b6 08             	movzbl (%eax),%ecx
  80091a:	0f b6 1a             	movzbl (%edx),%ebx
  80091d:	38 d9                	cmp    %bl,%cl
  80091f:	74 0a                	je     80092b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800921:	0f b6 c1             	movzbl %cl,%eax
  800924:	0f b6 db             	movzbl %bl,%ebx
  800927:	29 d8                	sub    %ebx,%eax
  800929:	eb 0f                	jmp    80093a <memcmp+0x35>
		s1++, s2++;
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800931:	39 f0                	cmp    %esi,%eax
  800933:	75 e2                	jne    800917 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800945:	89 c1                	mov    %eax,%ecx
  800947:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80094a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094e:	eb 0a                	jmp    80095a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800950:	0f b6 10             	movzbl (%eax),%edx
  800953:	39 da                	cmp    %ebx,%edx
  800955:	74 07                	je     80095e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	39 c8                	cmp    %ecx,%eax
  80095c:	72 f2                	jb     800950 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095e:	5b                   	pop    %ebx
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	57                   	push   %edi
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096d:	eb 03                	jmp    800972 <strtol+0x11>
		s++;
  80096f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800972:	0f b6 01             	movzbl (%ecx),%eax
  800975:	3c 20                	cmp    $0x20,%al
  800977:	74 f6                	je     80096f <strtol+0xe>
  800979:	3c 09                	cmp    $0x9,%al
  80097b:	74 f2                	je     80096f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80097d:	3c 2b                	cmp    $0x2b,%al
  80097f:	75 0a                	jne    80098b <strtol+0x2a>
		s++;
  800981:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800984:	bf 00 00 00 00       	mov    $0x0,%edi
  800989:	eb 11                	jmp    80099c <strtol+0x3b>
  80098b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800990:	3c 2d                	cmp    $0x2d,%al
  800992:	75 08                	jne    80099c <strtol+0x3b>
		s++, neg = 1;
  800994:	83 c1 01             	add    $0x1,%ecx
  800997:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a2:	75 15                	jne    8009b9 <strtol+0x58>
  8009a4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a7:	75 10                	jne    8009b9 <strtol+0x58>
  8009a9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ad:	75 7c                	jne    800a2b <strtol+0xca>
		s += 2, base = 16;
  8009af:	83 c1 02             	add    $0x2,%ecx
  8009b2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b7:	eb 16                	jmp    8009cf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009b9:	85 db                	test   %ebx,%ebx
  8009bb:	75 12                	jne    8009cf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009bd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c5:	75 08                	jne    8009cf <strtol+0x6e>
		s++, base = 8;
  8009c7:	83 c1 01             	add    $0x1,%ecx
  8009ca:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d7:	0f b6 11             	movzbl (%ecx),%edx
  8009da:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	80 fb 09             	cmp    $0x9,%bl
  8009e2:	77 08                	ja     8009ec <strtol+0x8b>
			dig = *s - '0';
  8009e4:	0f be d2             	movsbl %dl,%edx
  8009e7:	83 ea 30             	sub    $0x30,%edx
  8009ea:	eb 22                	jmp    800a0e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ec:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ef:	89 f3                	mov    %esi,%ebx
  8009f1:	80 fb 19             	cmp    $0x19,%bl
  8009f4:	77 08                	ja     8009fe <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009f6:	0f be d2             	movsbl %dl,%edx
  8009f9:	83 ea 57             	sub    $0x57,%edx
  8009fc:	eb 10                	jmp    800a0e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009fe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	80 fb 19             	cmp    $0x19,%bl
  800a06:	77 16                	ja     800a1e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a08:	0f be d2             	movsbl %dl,%edx
  800a0b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a0e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a11:	7d 0b                	jge    800a1e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a1a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a1c:	eb b9                	jmp    8009d7 <strtol+0x76>

	if (endptr)
  800a1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a22:	74 0d                	je     800a31 <strtol+0xd0>
		*endptr = (char *) s;
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	89 0e                	mov    %ecx,(%esi)
  800a29:	eb 06                	jmp    800a31 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2b:	85 db                	test   %ebx,%ebx
  800a2d:	74 98                	je     8009c7 <strtol+0x66>
  800a2f:	eb 9e                	jmp    8009cf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a31:	89 c2                	mov    %eax,%edx
  800a33:	f7 da                	neg    %edx
  800a35:	85 ff                	test   %edi,%edi
  800a37:	0f 45 c2             	cmovne %edx,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a50:	89 c3                	mov    %eax,%ebx
  800a52:	89 c7                	mov    %eax,%edi
  800a54:	89 c6                	mov    %eax,%esi
  800a56:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6d:	89 d1                	mov    %edx,%ecx
  800a6f:	89 d3                	mov    %edx,%ebx
  800a71:	89 d7                	mov    %edx,%edi
  800a73:	89 d6                	mov    %edx,%esi
  800a75:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a92:	89 cb                	mov    %ecx,%ebx
  800a94:	89 cf                	mov    %ecx,%edi
  800a96:	89 ce                	mov    %ecx,%esi
  800a98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	7e 17                	jle    800ab5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9e:	83 ec 0c             	sub    $0xc,%esp
  800aa1:	50                   	push   %eax
  800aa2:	6a 03                	push   $0x3
  800aa4:	68 bf 21 80 00       	push   $0x8021bf
  800aa9:	6a 23                	push   $0x23
  800aab:	68 dc 21 80 00       	push   $0x8021dc
  800ab0:	e8 e9 0f 00 00       	call   801a9e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac8:	b8 02 00 00 00       	mov    $0x2,%eax
  800acd:	89 d1                	mov    %edx,%ecx
  800acf:	89 d3                	mov    %edx,%ebx
  800ad1:	89 d7                	mov    %edx,%edi
  800ad3:	89 d6                	mov    %edx,%esi
  800ad5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_yield>:

void
sys_yield(void)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aec:	89 d1                	mov    %edx,%ecx
  800aee:	89 d3                	mov    %edx,%ebx
  800af0:	89 d7                	mov    %edx,%edi
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	be 00 00 00 00       	mov    $0x0,%esi
  800b09:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b17:	89 f7                	mov    %esi,%edi
  800b19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 17                	jle    800b36 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	6a 04                	push   $0x4
  800b25:	68 bf 21 80 00       	push   $0x8021bf
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 dc 21 80 00       	push   $0x8021dc
  800b31:	e8 68 0f 00 00       	call   801a9e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b58:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7e 17                	jle    800b78 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	50                   	push   %eax
  800b65:	6a 05                	push   $0x5
  800b67:	68 bf 21 80 00       	push   $0x8021bf
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 dc 21 80 00       	push   $0x8021dc
  800b73:	e8 26 0f 00 00       	call   801a9e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 df                	mov    %ebx,%edi
  800b9b:	89 de                	mov    %ebx,%esi
  800b9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7e 17                	jle    800bba <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 06                	push   $0x6
  800ba9:	68 bf 21 80 00       	push   $0x8021bf
  800bae:	6a 23                	push   $0x23
  800bb0:	68 dc 21 80 00       	push   $0x8021dc
  800bb5:	e8 e4 0e 00 00       	call   801a9e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	89 df                	mov    %ebx,%edi
  800bdd:	89 de                	mov    %ebx,%esi
  800bdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 08                	push   $0x8
  800beb:	68 bf 21 80 00       	push   $0x8021bf
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 dc 21 80 00       	push   $0x8021dc
  800bf7:	e8 a2 0e 00 00       	call   801a9e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 09 00 00 00       	mov    $0x9,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 09                	push   $0x9
  800c2d:	68 bf 21 80 00       	push   $0x8021bf
  800c32:	6a 23                	push   $0x23
  800c34:	68 dc 21 80 00       	push   $0x8021dc
  800c39:	e8 60 0e 00 00       	call   801a9e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 0a                	push   $0xa
  800c6f:	68 bf 21 80 00       	push   $0x8021bf
  800c74:	6a 23                	push   $0x23
  800c76:	68 dc 21 80 00       	push   $0x8021dc
  800c7b:	e8 1e 0e 00 00       	call   801a9e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	be 00 00 00 00       	mov    $0x0,%esi
  800c93:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 cb                	mov    %ecx,%ebx
  800cc3:	89 cf                	mov    %ecx,%edi
  800cc5:	89 ce                	mov    %ecx,%esi
  800cc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 17                	jle    800ce4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 0d                	push   $0xd
  800cd3:	68 bf 21 80 00       	push   $0x8021bf
  800cd8:	6a 23                	push   $0x23
  800cda:	68 dc 21 80 00       	push   $0x8021dc
  800cdf:	e8 ba 0d 00 00       	call   801a9e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  800cf2:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800cf9:	75 2a                	jne    800d25 <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  800cfb:	83 ec 04             	sub    $0x4,%esp
  800cfe:	6a 06                	push   $0x6
  800d00:	68 00 f0 bf ee       	push   $0xeebff000
  800d05:	6a 00                	push   $0x0
  800d07:	e8 ef fd ff ff       	call   800afb <sys_page_alloc>
			 if (a < 0)
  800d0c:	83 c4 10             	add    $0x10,%esp
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	79 12                	jns    800d25 <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  800d13:	50                   	push   %eax
  800d14:	68 ea 21 80 00       	push   $0x8021ea
  800d19:	6a 21                	push   $0x21
  800d1b:	68 04 22 80 00       	push   $0x802204
  800d20:	e8 79 0d 00 00       	call   801a9e <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  800d25:	e8 93 fd ff ff       	call   800abd <sys_getenvid>
  800d2a:	83 ec 08             	sub    $0x8,%esp
  800d2d:	68 45 0d 80 00       	push   $0x800d45
  800d32:	50                   	push   %eax
  800d33:	e8 0e ff ff ff       	call   800c46 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    

00800d45 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  800d45:	54                   	push   %esp
movl _pgfault_handler, %eax
  800d46:	a1 08 40 80 00       	mov    0x804008,%eax
call *%eax
  800d4b:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  800d4d:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  800d50:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  800d54:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  800d58:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  800d5b:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  800d5f:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  800d61:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  800d64:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  800d65:	83 c4 04             	add    $0x4,%esp
popfl
  800d68:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  800d69:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  800d6a:	c3                   	ret    

00800d6b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d71:	05 00 00 00 30       	add    $0x30000000,%eax
  800d76:	c1 e8 0c             	shr    $0xc,%eax
}
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	05 00 00 00 30       	add    $0x30000000,%eax
  800d86:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d8b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d98:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d9d:	89 c2                	mov    %eax,%edx
  800d9f:	c1 ea 16             	shr    $0x16,%edx
  800da2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da9:	f6 c2 01             	test   $0x1,%dl
  800dac:	74 11                	je     800dbf <fd_alloc+0x2d>
  800dae:	89 c2                	mov    %eax,%edx
  800db0:	c1 ea 0c             	shr    $0xc,%edx
  800db3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dba:	f6 c2 01             	test   $0x1,%dl
  800dbd:	75 09                	jne    800dc8 <fd_alloc+0x36>
			*fd_store = fd;
  800dbf:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc6:	eb 17                	jmp    800ddf <fd_alloc+0x4d>
  800dc8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dcd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dd2:	75 c9                	jne    800d9d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dd4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dda:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800de7:	83 f8 1f             	cmp    $0x1f,%eax
  800dea:	77 36                	ja     800e22 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dec:	c1 e0 0c             	shl    $0xc,%eax
  800def:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800df4:	89 c2                	mov    %eax,%edx
  800df6:	c1 ea 16             	shr    $0x16,%edx
  800df9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e00:	f6 c2 01             	test   $0x1,%dl
  800e03:	74 24                	je     800e29 <fd_lookup+0x48>
  800e05:	89 c2                	mov    %eax,%edx
  800e07:	c1 ea 0c             	shr    $0xc,%edx
  800e0a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e11:	f6 c2 01             	test   $0x1,%dl
  800e14:	74 1a                	je     800e30 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e19:	89 02                	mov    %eax,(%edx)
	return 0;
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e20:	eb 13                	jmp    800e35 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e27:	eb 0c                	jmp    800e35 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e2e:	eb 05                	jmp    800e35 <fd_lookup+0x54>
  800e30:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	83 ec 08             	sub    $0x8,%esp
  800e3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e40:	ba 90 22 80 00       	mov    $0x802290,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e45:	eb 13                	jmp    800e5a <dev_lookup+0x23>
  800e47:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e4a:	39 08                	cmp    %ecx,(%eax)
  800e4c:	75 0c                	jne    800e5a <dev_lookup+0x23>
			*dev = devtab[i];
  800e4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e51:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e53:	b8 00 00 00 00       	mov    $0x0,%eax
  800e58:	eb 2e                	jmp    800e88 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e5a:	8b 02                	mov    (%edx),%eax
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	75 e7                	jne    800e47 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e60:	a1 04 40 80 00       	mov    0x804004,%eax
  800e65:	8b 40 48             	mov    0x48(%eax),%eax
  800e68:	83 ec 04             	sub    $0x4,%esp
  800e6b:	51                   	push   %ecx
  800e6c:	50                   	push   %eax
  800e6d:	68 14 22 80 00       	push   $0x802214
  800e72:	e8 fc f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800e77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e88:	c9                   	leave  
  800e89:	c3                   	ret    

00800e8a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 10             	sub    $0x10,%esp
  800e92:	8b 75 08             	mov    0x8(%ebp),%esi
  800e95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e9b:	50                   	push   %eax
  800e9c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ea2:	c1 e8 0c             	shr    $0xc,%eax
  800ea5:	50                   	push   %eax
  800ea6:	e8 36 ff ff ff       	call   800de1 <fd_lookup>
  800eab:	83 c4 08             	add    $0x8,%esp
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	78 05                	js     800eb7 <fd_close+0x2d>
	    || fd != fd2)
  800eb2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eb5:	74 0c                	je     800ec3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800eb7:	84 db                	test   %bl,%bl
  800eb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebe:	0f 44 c2             	cmove  %edx,%eax
  800ec1:	eb 41                	jmp    800f04 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ec3:	83 ec 08             	sub    $0x8,%esp
  800ec6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ec9:	50                   	push   %eax
  800eca:	ff 36                	pushl  (%esi)
  800ecc:	e8 66 ff ff ff       	call   800e37 <dev_lookup>
  800ed1:	89 c3                	mov    %eax,%ebx
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	78 1a                	js     800ef4 <fd_close+0x6a>
		if (dev->dev_close)
  800eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800edd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ee0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	74 0b                	je     800ef4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	56                   	push   %esi
  800eed:	ff d0                	call   *%eax
  800eef:	89 c3                	mov    %eax,%ebx
  800ef1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ef4:	83 ec 08             	sub    $0x8,%esp
  800ef7:	56                   	push   %esi
  800ef8:	6a 00                	push   $0x0
  800efa:	e8 81 fc ff ff       	call   800b80 <sys_page_unmap>
	return r;
  800eff:	83 c4 10             	add    $0x10,%esp
  800f02:	89 d8                	mov    %ebx,%eax
}
  800f04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f14:	50                   	push   %eax
  800f15:	ff 75 08             	pushl  0x8(%ebp)
  800f18:	e8 c4 fe ff ff       	call   800de1 <fd_lookup>
  800f1d:	83 c4 08             	add    $0x8,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 10                	js     800f34 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f24:	83 ec 08             	sub    $0x8,%esp
  800f27:	6a 01                	push   $0x1
  800f29:	ff 75 f4             	pushl  -0xc(%ebp)
  800f2c:	e8 59 ff ff ff       	call   800e8a <fd_close>
  800f31:	83 c4 10             	add    $0x10,%esp
}
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    

00800f36 <close_all>:

void
close_all(void)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	53                   	push   %ebx
  800f3a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f3d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f42:	83 ec 0c             	sub    $0xc,%esp
  800f45:	53                   	push   %ebx
  800f46:	e8 c0 ff ff ff       	call   800f0b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f4b:	83 c3 01             	add    $0x1,%ebx
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	83 fb 20             	cmp    $0x20,%ebx
  800f54:	75 ec                	jne    800f42 <close_all+0xc>
		close(i);
}
  800f56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f59:	c9                   	leave  
  800f5a:	c3                   	ret    

00800f5b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	57                   	push   %edi
  800f5f:	56                   	push   %esi
  800f60:	53                   	push   %ebx
  800f61:	83 ec 2c             	sub    $0x2c,%esp
  800f64:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f67:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f6a:	50                   	push   %eax
  800f6b:	ff 75 08             	pushl  0x8(%ebp)
  800f6e:	e8 6e fe ff ff       	call   800de1 <fd_lookup>
  800f73:	83 c4 08             	add    $0x8,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	0f 88 c1 00 00 00    	js     80103f <dup+0xe4>
		return r;
	close(newfdnum);
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	56                   	push   %esi
  800f82:	e8 84 ff ff ff       	call   800f0b <close>

	newfd = INDEX2FD(newfdnum);
  800f87:	89 f3                	mov    %esi,%ebx
  800f89:	c1 e3 0c             	shl    $0xc,%ebx
  800f8c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f92:	83 c4 04             	add    $0x4,%esp
  800f95:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f98:	e8 de fd ff ff       	call   800d7b <fd2data>
  800f9d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f9f:	89 1c 24             	mov    %ebx,(%esp)
  800fa2:	e8 d4 fd ff ff       	call   800d7b <fd2data>
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fad:	89 f8                	mov    %edi,%eax
  800faf:	c1 e8 16             	shr    $0x16,%eax
  800fb2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb9:	a8 01                	test   $0x1,%al
  800fbb:	74 37                	je     800ff4 <dup+0x99>
  800fbd:	89 f8                	mov    %edi,%eax
  800fbf:	c1 e8 0c             	shr    $0xc,%eax
  800fc2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc9:	f6 c2 01             	test   $0x1,%dl
  800fcc:	74 26                	je     800ff4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	25 07 0e 00 00       	and    $0xe07,%eax
  800fdd:	50                   	push   %eax
  800fde:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fe1:	6a 00                	push   $0x0
  800fe3:	57                   	push   %edi
  800fe4:	6a 00                	push   $0x0
  800fe6:	e8 53 fb ff ff       	call   800b3e <sys_page_map>
  800feb:	89 c7                	mov    %eax,%edi
  800fed:	83 c4 20             	add    $0x20,%esp
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	78 2e                	js     801022 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ff4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ff7:	89 d0                	mov    %edx,%eax
  800ff9:	c1 e8 0c             	shr    $0xc,%eax
  800ffc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	25 07 0e 00 00       	and    $0xe07,%eax
  80100b:	50                   	push   %eax
  80100c:	53                   	push   %ebx
  80100d:	6a 00                	push   $0x0
  80100f:	52                   	push   %edx
  801010:	6a 00                	push   $0x0
  801012:	e8 27 fb ff ff       	call   800b3e <sys_page_map>
  801017:	89 c7                	mov    %eax,%edi
  801019:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80101c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80101e:	85 ff                	test   %edi,%edi
  801020:	79 1d                	jns    80103f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801022:	83 ec 08             	sub    $0x8,%esp
  801025:	53                   	push   %ebx
  801026:	6a 00                	push   $0x0
  801028:	e8 53 fb ff ff       	call   800b80 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80102d:	83 c4 08             	add    $0x8,%esp
  801030:	ff 75 d4             	pushl  -0x2c(%ebp)
  801033:	6a 00                	push   $0x0
  801035:	e8 46 fb ff ff       	call   800b80 <sys_page_unmap>
	return r;
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	89 f8                	mov    %edi,%eax
}
  80103f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801042:	5b                   	pop    %ebx
  801043:	5e                   	pop    %esi
  801044:	5f                   	pop    %edi
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	53                   	push   %ebx
  80104b:	83 ec 14             	sub    $0x14,%esp
  80104e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801051:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801054:	50                   	push   %eax
  801055:	53                   	push   %ebx
  801056:	e8 86 fd ff ff       	call   800de1 <fd_lookup>
  80105b:	83 c4 08             	add    $0x8,%esp
  80105e:	89 c2                	mov    %eax,%edx
  801060:	85 c0                	test   %eax,%eax
  801062:	78 6d                	js     8010d1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106a:	50                   	push   %eax
  80106b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80106e:	ff 30                	pushl  (%eax)
  801070:	e8 c2 fd ff ff       	call   800e37 <dev_lookup>
  801075:	83 c4 10             	add    $0x10,%esp
  801078:	85 c0                	test   %eax,%eax
  80107a:	78 4c                	js     8010c8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80107c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80107f:	8b 42 08             	mov    0x8(%edx),%eax
  801082:	83 e0 03             	and    $0x3,%eax
  801085:	83 f8 01             	cmp    $0x1,%eax
  801088:	75 21                	jne    8010ab <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80108a:	a1 04 40 80 00       	mov    0x804004,%eax
  80108f:	8b 40 48             	mov    0x48(%eax),%eax
  801092:	83 ec 04             	sub    $0x4,%esp
  801095:	53                   	push   %ebx
  801096:	50                   	push   %eax
  801097:	68 55 22 80 00       	push   $0x802255
  80109c:	e8 d2 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010a9:	eb 26                	jmp    8010d1 <read+0x8a>
	}
	if (!dev->dev_read)
  8010ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ae:	8b 40 08             	mov    0x8(%eax),%eax
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	74 17                	je     8010cc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010b5:	83 ec 04             	sub    $0x4,%esp
  8010b8:	ff 75 10             	pushl  0x10(%ebp)
  8010bb:	ff 75 0c             	pushl  0xc(%ebp)
  8010be:	52                   	push   %edx
  8010bf:	ff d0                	call   *%eax
  8010c1:	89 c2                	mov    %eax,%edx
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	eb 09                	jmp    8010d1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c8:	89 c2                	mov    %eax,%edx
  8010ca:	eb 05                	jmp    8010d1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010d1:	89 d0                	mov    %edx,%eax
  8010d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d6:	c9                   	leave  
  8010d7:	c3                   	ret    

008010d8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	57                   	push   %edi
  8010dc:	56                   	push   %esi
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 0c             	sub    $0xc,%esp
  8010e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ec:	eb 21                	jmp    80110f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	89 f0                	mov    %esi,%eax
  8010f3:	29 d8                	sub    %ebx,%eax
  8010f5:	50                   	push   %eax
  8010f6:	89 d8                	mov    %ebx,%eax
  8010f8:	03 45 0c             	add    0xc(%ebp),%eax
  8010fb:	50                   	push   %eax
  8010fc:	57                   	push   %edi
  8010fd:	e8 45 ff ff ff       	call   801047 <read>
		if (m < 0)
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	85 c0                	test   %eax,%eax
  801107:	78 10                	js     801119 <readn+0x41>
			return m;
		if (m == 0)
  801109:	85 c0                	test   %eax,%eax
  80110b:	74 0a                	je     801117 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80110d:	01 c3                	add    %eax,%ebx
  80110f:	39 f3                	cmp    %esi,%ebx
  801111:	72 db                	jb     8010ee <readn+0x16>
  801113:	89 d8                	mov    %ebx,%eax
  801115:	eb 02                	jmp    801119 <readn+0x41>
  801117:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801119:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111c:	5b                   	pop    %ebx
  80111d:	5e                   	pop    %esi
  80111e:	5f                   	pop    %edi
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    

00801121 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	53                   	push   %ebx
  801125:	83 ec 14             	sub    $0x14,%esp
  801128:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80112b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112e:	50                   	push   %eax
  80112f:	53                   	push   %ebx
  801130:	e8 ac fc ff ff       	call   800de1 <fd_lookup>
  801135:	83 c4 08             	add    $0x8,%esp
  801138:	89 c2                	mov    %eax,%edx
  80113a:	85 c0                	test   %eax,%eax
  80113c:	78 68                	js     8011a6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113e:	83 ec 08             	sub    $0x8,%esp
  801141:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801144:	50                   	push   %eax
  801145:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801148:	ff 30                	pushl  (%eax)
  80114a:	e8 e8 fc ff ff       	call   800e37 <dev_lookup>
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	78 47                	js     80119d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801156:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801159:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80115d:	75 21                	jne    801180 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80115f:	a1 04 40 80 00       	mov    0x804004,%eax
  801164:	8b 40 48             	mov    0x48(%eax),%eax
  801167:	83 ec 04             	sub    $0x4,%esp
  80116a:	53                   	push   %ebx
  80116b:	50                   	push   %eax
  80116c:	68 71 22 80 00       	push   $0x802271
  801171:	e8 fd ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80117e:	eb 26                	jmp    8011a6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801180:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801183:	8b 52 0c             	mov    0xc(%edx),%edx
  801186:	85 d2                	test   %edx,%edx
  801188:	74 17                	je     8011a1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80118a:	83 ec 04             	sub    $0x4,%esp
  80118d:	ff 75 10             	pushl  0x10(%ebp)
  801190:	ff 75 0c             	pushl  0xc(%ebp)
  801193:	50                   	push   %eax
  801194:	ff d2                	call   *%edx
  801196:	89 c2                	mov    %eax,%edx
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	eb 09                	jmp    8011a6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	eb 05                	jmp    8011a6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011a1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011a6:	89 d0                	mov    %edx,%eax
  8011a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ab:	c9                   	leave  
  8011ac:	c3                   	ret    

008011ad <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011b6:	50                   	push   %eax
  8011b7:	ff 75 08             	pushl  0x8(%ebp)
  8011ba:	e8 22 fc ff ff       	call   800de1 <fd_lookup>
  8011bf:	83 c4 08             	add    $0x8,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 0e                	js     8011d4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011cc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d4:	c9                   	leave  
  8011d5:	c3                   	ret    

008011d6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	53                   	push   %ebx
  8011da:	83 ec 14             	sub    $0x14,%esp
  8011dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e3:	50                   	push   %eax
  8011e4:	53                   	push   %ebx
  8011e5:	e8 f7 fb ff ff       	call   800de1 <fd_lookup>
  8011ea:	83 c4 08             	add    $0x8,%esp
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	78 65                	js     801258 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f3:	83 ec 08             	sub    $0x8,%esp
  8011f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fd:	ff 30                	pushl  (%eax)
  8011ff:	e8 33 fc ff ff       	call   800e37 <dev_lookup>
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	78 44                	js     80124f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801212:	75 21                	jne    801235 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801214:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801219:	8b 40 48             	mov    0x48(%eax),%eax
  80121c:	83 ec 04             	sub    $0x4,%esp
  80121f:	53                   	push   %ebx
  801220:	50                   	push   %eax
  801221:	68 34 22 80 00       	push   $0x802234
  801226:	e8 48 ef ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801233:	eb 23                	jmp    801258 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801235:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801238:	8b 52 18             	mov    0x18(%edx),%edx
  80123b:	85 d2                	test   %edx,%edx
  80123d:	74 14                	je     801253 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80123f:	83 ec 08             	sub    $0x8,%esp
  801242:	ff 75 0c             	pushl  0xc(%ebp)
  801245:	50                   	push   %eax
  801246:	ff d2                	call   *%edx
  801248:	89 c2                	mov    %eax,%edx
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	eb 09                	jmp    801258 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124f:	89 c2                	mov    %eax,%edx
  801251:	eb 05                	jmp    801258 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801253:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801258:	89 d0                	mov    %edx,%eax
  80125a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125d:	c9                   	leave  
  80125e:	c3                   	ret    

0080125f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	53                   	push   %ebx
  801263:	83 ec 14             	sub    $0x14,%esp
  801266:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801269:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	ff 75 08             	pushl  0x8(%ebp)
  801270:	e8 6c fb ff ff       	call   800de1 <fd_lookup>
  801275:	83 c4 08             	add    $0x8,%esp
  801278:	89 c2                	mov    %eax,%edx
  80127a:	85 c0                	test   %eax,%eax
  80127c:	78 58                	js     8012d6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127e:	83 ec 08             	sub    $0x8,%esp
  801281:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801284:	50                   	push   %eax
  801285:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801288:	ff 30                	pushl  (%eax)
  80128a:	e8 a8 fb ff ff       	call   800e37 <dev_lookup>
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	78 37                	js     8012cd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801296:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801299:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80129d:	74 32                	je     8012d1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80129f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012a2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012a9:	00 00 00 
	stat->st_isdir = 0;
  8012ac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012b3:	00 00 00 
	stat->st_dev = dev;
  8012b6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012bc:	83 ec 08             	sub    $0x8,%esp
  8012bf:	53                   	push   %ebx
  8012c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c3:	ff 50 14             	call   *0x14(%eax)
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	eb 09                	jmp    8012d6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cd:	89 c2                	mov    %eax,%edx
  8012cf:	eb 05                	jmp    8012d6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012d6:	89 d0                	mov    %edx,%eax
  8012d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    

008012dd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	56                   	push   %esi
  8012e1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012e2:	83 ec 08             	sub    $0x8,%esp
  8012e5:	6a 00                	push   $0x0
  8012e7:	ff 75 08             	pushl  0x8(%ebp)
  8012ea:	e8 2c 02 00 00       	call   80151b <open>
  8012ef:	89 c3                	mov    %eax,%ebx
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	78 1b                	js     801313 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	ff 75 0c             	pushl  0xc(%ebp)
  8012fe:	50                   	push   %eax
  8012ff:	e8 5b ff ff ff       	call   80125f <fstat>
  801304:	89 c6                	mov    %eax,%esi
	close(fd);
  801306:	89 1c 24             	mov    %ebx,(%esp)
  801309:	e8 fd fb ff ff       	call   800f0b <close>
	return r;
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	89 f0                	mov    %esi,%eax
}
  801313:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801316:	5b                   	pop    %ebx
  801317:	5e                   	pop    %esi
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    

0080131a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	56                   	push   %esi
  80131e:	53                   	push   %ebx
  80131f:	89 c6                	mov    %eax,%esi
  801321:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  801323:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80132a:	75 12                	jne    80133e <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  80132c:	83 ec 0c             	sub    $0xc,%esp
  80132f:	6a 01                	push   $0x1
  801331:	e8 61 08 00 00       	call   801b97 <ipc_find_env>
  801336:	a3 00 40 80 00       	mov    %eax,0x804000
  80133b:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80133e:	6a 07                	push   $0x7
  801340:	68 00 50 80 00       	push   $0x805000
  801345:	56                   	push   %esi
  801346:	ff 35 00 40 80 00    	pushl  0x804000
  80134c:	e8 f2 07 00 00       	call   801b43 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  801351:	83 c4 0c             	add    $0xc,%esp
  801354:	6a 00                	push   $0x0
  801356:	53                   	push   %ebx
  801357:	6a 00                	push   $0x0
  801359:	e8 86 07 00 00       	call   801ae4 <ipc_recv>
}
  80135e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801361:	5b                   	pop    %ebx
  801362:	5e                   	pop    %esi
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    

00801365 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80136b:	8b 45 08             	mov    0x8(%ebp),%eax
  80136e:	8b 40 0c             	mov    0xc(%eax),%eax
  801371:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  801376:	8b 45 0c             	mov    0xc(%ebp),%eax
  801379:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80137e:	ba 00 00 00 00       	mov    $0x0,%edx
  801383:	b8 02 00 00 00       	mov    $0x2,%eax
  801388:	e8 8d ff ff ff       	call   80131a <fsipc>
}
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801395:	8b 45 08             	mov    0x8(%ebp),%eax
  801398:	8b 40 0c             	mov    0xc(%eax),%eax
  80139b:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  8013a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8013aa:	e8 6b ff ff ff       	call   80131a <fsipc>
}
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	53                   	push   %ebx
  8013b5:	83 ec 04             	sub    $0x4,%esp
  8013b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013be:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c1:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cb:	b8 05 00 00 00       	mov    $0x5,%eax
  8013d0:	e8 45 ff ff ff       	call   80131a <fsipc>
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	78 2c                	js     801405 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	68 00 50 80 00       	push   $0x805000
  8013e1:	53                   	push   %ebx
  8013e2:	e8 11 f3 ff ff       	call   8006f8 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8013e7:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ec:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013f2:	a1 84 50 80 00       	mov    0x805084,%eax
  8013f7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801405:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	53                   	push   %ebx
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  801414:	8b 45 08             	mov    0x8(%ebp),%eax
  801417:	8b 40 0c             	mov    0xc(%eax),%eax
  80141a:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  80141f:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  801425:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  80142b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801430:	0f 46 c3             	cmovbe %ebx,%eax
  801433:	50                   	push   %eax
  801434:	ff 75 0c             	pushl  0xc(%ebp)
  801437:	68 08 50 80 00       	push   $0x805008
  80143c:	e8 49 f4 ff ff       	call   80088a <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	b8 04 00 00 00       	mov    $0x4,%eax
  80144b:	e8 ca fe ff ff       	call   80131a <fsipc>
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	78 3d                	js     801494 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  801457:	39 c3                	cmp    %eax,%ebx
  801459:	73 19                	jae    801474 <devfile_write+0x6a>
  80145b:	68 a0 22 80 00       	push   $0x8022a0
  801460:	68 a7 22 80 00       	push   $0x8022a7
  801465:	68 9a 00 00 00       	push   $0x9a
  80146a:	68 bc 22 80 00       	push   $0x8022bc
  80146f:	e8 2a 06 00 00       	call   801a9e <_panic>
	   assert (r <= bytes_written);
  801474:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801479:	7e 19                	jle    801494 <devfile_write+0x8a>
  80147b:	68 c7 22 80 00       	push   $0x8022c7
  801480:	68 a7 22 80 00       	push   $0x8022a7
  801485:	68 9b 00 00 00       	push   $0x9b
  80148a:	68 bc 22 80 00       	push   $0x8022bc
  80148f:	e8 0a 06 00 00       	call   801a9e <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801494:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801497:	c9                   	leave  
  801498:	c3                   	ret    

00801499 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	56                   	push   %esi
  80149d:	53                   	push   %ebx
  80149e:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a7:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  8014ac:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b7:	b8 03 00 00 00       	mov    $0x3,%eax
  8014bc:	e8 59 fe ff ff       	call   80131a <fsipc>
  8014c1:	89 c3                	mov    %eax,%ebx
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 4b                	js     801512 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  8014c7:	39 c6                	cmp    %eax,%esi
  8014c9:	73 16                	jae    8014e1 <devfile_read+0x48>
  8014cb:	68 a0 22 80 00       	push   $0x8022a0
  8014d0:	68 a7 22 80 00       	push   $0x8022a7
  8014d5:	6a 7c                	push   $0x7c
  8014d7:	68 bc 22 80 00       	push   $0x8022bc
  8014dc:	e8 bd 05 00 00       	call   801a9e <_panic>
	   assert(r <= PGSIZE);
  8014e1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014e6:	7e 16                	jle    8014fe <devfile_read+0x65>
  8014e8:	68 da 22 80 00       	push   $0x8022da
  8014ed:	68 a7 22 80 00       	push   $0x8022a7
  8014f2:	6a 7d                	push   $0x7d
  8014f4:	68 bc 22 80 00       	push   $0x8022bc
  8014f9:	e8 a0 05 00 00       	call   801a9e <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014fe:	83 ec 04             	sub    $0x4,%esp
  801501:	50                   	push   %eax
  801502:	68 00 50 80 00       	push   $0x805000
  801507:	ff 75 0c             	pushl  0xc(%ebp)
  80150a:	e8 7b f3 ff ff       	call   80088a <memmove>
	   return r;
  80150f:	83 c4 10             	add    $0x10,%esp
}
  801512:	89 d8                	mov    %ebx,%eax
  801514:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801517:	5b                   	pop    %ebx
  801518:	5e                   	pop    %esi
  801519:	5d                   	pop    %ebp
  80151a:	c3                   	ret    

0080151b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	53                   	push   %ebx
  80151f:	83 ec 20             	sub    $0x20,%esp
  801522:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  801525:	53                   	push   %ebx
  801526:	e8 94 f1 ff ff       	call   8006bf <strlen>
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801533:	7f 67                	jg     80159c <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801535:	83 ec 0c             	sub    $0xc,%esp
  801538:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153b:	50                   	push   %eax
  80153c:	e8 51 f8 ff ff       	call   800d92 <fd_alloc>
  801541:	83 c4 10             	add    $0x10,%esp
			 return r;
  801544:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801546:	85 c0                	test   %eax,%eax
  801548:	78 57                	js     8015a1 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  80154a:	83 ec 08             	sub    $0x8,%esp
  80154d:	53                   	push   %ebx
  80154e:	68 00 50 80 00       	push   $0x805000
  801553:	e8 a0 f1 ff ff       	call   8006f8 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  801558:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155b:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801560:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801563:	b8 01 00 00 00       	mov    $0x1,%eax
  801568:	e8 ad fd ff ff       	call   80131a <fsipc>
  80156d:	89 c3                	mov    %eax,%ebx
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	79 14                	jns    80158a <open+0x6f>
			 fd_close(fd, 0);
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	6a 00                	push   $0x0
  80157b:	ff 75 f4             	pushl  -0xc(%ebp)
  80157e:	e8 07 f9 ff ff       	call   800e8a <fd_close>
			 return r;
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	89 da                	mov    %ebx,%edx
  801588:	eb 17                	jmp    8015a1 <open+0x86>
	   }

	   return fd2num(fd);
  80158a:	83 ec 0c             	sub    $0xc,%esp
  80158d:	ff 75 f4             	pushl  -0xc(%ebp)
  801590:	e8 d6 f7 ff ff       	call   800d6b <fd2num>
  801595:	89 c2                	mov    %eax,%edx
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	eb 05                	jmp    8015a1 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  80159c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  8015a1:	89 d0                	mov    %edx,%eax
  8015a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  8015ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b3:	b8 08 00 00 00       	mov    $0x8,%eax
  8015b8:	e8 5d fd ff ff       	call   80131a <fsipc>
}
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	56                   	push   %esi
  8015c3:	53                   	push   %ebx
  8015c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015c7:	83 ec 0c             	sub    $0xc,%esp
  8015ca:	ff 75 08             	pushl  0x8(%ebp)
  8015cd:	e8 a9 f7 ff ff       	call   800d7b <fd2data>
  8015d2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015d4:	83 c4 08             	add    $0x8,%esp
  8015d7:	68 e6 22 80 00       	push   $0x8022e6
  8015dc:	53                   	push   %ebx
  8015dd:	e8 16 f1 ff ff       	call   8006f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015e2:	8b 46 04             	mov    0x4(%esi),%eax
  8015e5:	2b 06                	sub    (%esi),%eax
  8015e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015f4:	00 00 00 
	stat->st_dev = &devpipe;
  8015f7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015fe:	30 80 00 
	return 0;
}
  801601:	b8 00 00 00 00       	mov    $0x0,%eax
  801606:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801609:	5b                   	pop    %ebx
  80160a:	5e                   	pop    %esi
  80160b:	5d                   	pop    %ebp
  80160c:	c3                   	ret    

0080160d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	53                   	push   %ebx
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801617:	53                   	push   %ebx
  801618:	6a 00                	push   $0x0
  80161a:	e8 61 f5 ff ff       	call   800b80 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80161f:	89 1c 24             	mov    %ebx,(%esp)
  801622:	e8 54 f7 ff ff       	call   800d7b <fd2data>
  801627:	83 c4 08             	add    $0x8,%esp
  80162a:	50                   	push   %eax
  80162b:	6a 00                	push   $0x0
  80162d:	e8 4e f5 ff ff       	call   800b80 <sys_page_unmap>
}
  801632:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801635:	c9                   	leave  
  801636:	c3                   	ret    

00801637 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	57                   	push   %edi
  80163b:	56                   	push   %esi
  80163c:	53                   	push   %ebx
  80163d:	83 ec 1c             	sub    $0x1c,%esp
  801640:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801643:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801645:	a1 04 40 80 00       	mov    0x804004,%eax
  80164a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80164d:	83 ec 0c             	sub    $0xc,%esp
  801650:	ff 75 e0             	pushl  -0x20(%ebp)
  801653:	e8 78 05 00 00       	call   801bd0 <pageref>
  801658:	89 c3                	mov    %eax,%ebx
  80165a:	89 3c 24             	mov    %edi,(%esp)
  80165d:	e8 6e 05 00 00       	call   801bd0 <pageref>
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	39 c3                	cmp    %eax,%ebx
  801667:	0f 94 c1             	sete   %cl
  80166a:	0f b6 c9             	movzbl %cl,%ecx
  80166d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801670:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801676:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801679:	39 ce                	cmp    %ecx,%esi
  80167b:	74 1b                	je     801698 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80167d:	39 c3                	cmp    %eax,%ebx
  80167f:	75 c4                	jne    801645 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801681:	8b 42 58             	mov    0x58(%edx),%eax
  801684:	ff 75 e4             	pushl  -0x1c(%ebp)
  801687:	50                   	push   %eax
  801688:	56                   	push   %esi
  801689:	68 ed 22 80 00       	push   $0x8022ed
  80168e:	e8 e0 ea ff ff       	call   800173 <cprintf>
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	eb ad                	jmp    801645 <_pipeisclosed+0xe>
	}
}
  801698:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80169b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169e:	5b                   	pop    %ebx
  80169f:	5e                   	pop    %esi
  8016a0:	5f                   	pop    %edi
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    

008016a3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	57                   	push   %edi
  8016a7:	56                   	push   %esi
  8016a8:	53                   	push   %ebx
  8016a9:	83 ec 28             	sub    $0x28,%esp
  8016ac:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016af:	56                   	push   %esi
  8016b0:	e8 c6 f6 ff ff       	call   800d7b <fd2data>
  8016b5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8016bf:	eb 4b                	jmp    80170c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016c1:	89 da                	mov    %ebx,%edx
  8016c3:	89 f0                	mov    %esi,%eax
  8016c5:	e8 6d ff ff ff       	call   801637 <_pipeisclosed>
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	75 48                	jne    801716 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016ce:	e8 09 f4 ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016d3:	8b 43 04             	mov    0x4(%ebx),%eax
  8016d6:	8b 0b                	mov    (%ebx),%ecx
  8016d8:	8d 51 20             	lea    0x20(%ecx),%edx
  8016db:	39 d0                	cmp    %edx,%eax
  8016dd:	73 e2                	jae    8016c1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016e6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	c1 fa 1f             	sar    $0x1f,%edx
  8016ee:	89 d1                	mov    %edx,%ecx
  8016f0:	c1 e9 1b             	shr    $0x1b,%ecx
  8016f3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016f6:	83 e2 1f             	and    $0x1f,%edx
  8016f9:	29 ca                	sub    %ecx,%edx
  8016fb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016ff:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801703:	83 c0 01             	add    $0x1,%eax
  801706:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801709:	83 c7 01             	add    $0x1,%edi
  80170c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80170f:	75 c2                	jne    8016d3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801711:	8b 45 10             	mov    0x10(%ebp),%eax
  801714:	eb 05                	jmp    80171b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801716:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80171b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5f                   	pop    %edi
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	57                   	push   %edi
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
  801729:	83 ec 18             	sub    $0x18,%esp
  80172c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80172f:	57                   	push   %edi
  801730:	e8 46 f6 ff ff       	call   800d7b <fd2data>
  801735:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80173f:	eb 3d                	jmp    80177e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801741:	85 db                	test   %ebx,%ebx
  801743:	74 04                	je     801749 <devpipe_read+0x26>
				return i;
  801745:	89 d8                	mov    %ebx,%eax
  801747:	eb 44                	jmp    80178d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801749:	89 f2                	mov    %esi,%edx
  80174b:	89 f8                	mov    %edi,%eax
  80174d:	e8 e5 fe ff ff       	call   801637 <_pipeisclosed>
  801752:	85 c0                	test   %eax,%eax
  801754:	75 32                	jne    801788 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801756:	e8 81 f3 ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80175b:	8b 06                	mov    (%esi),%eax
  80175d:	3b 46 04             	cmp    0x4(%esi),%eax
  801760:	74 df                	je     801741 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801762:	99                   	cltd   
  801763:	c1 ea 1b             	shr    $0x1b,%edx
  801766:	01 d0                	add    %edx,%eax
  801768:	83 e0 1f             	and    $0x1f,%eax
  80176b:	29 d0                	sub    %edx,%eax
  80176d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801772:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801775:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801778:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80177b:	83 c3 01             	add    $0x1,%ebx
  80177e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801781:	75 d8                	jne    80175b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801783:	8b 45 10             	mov    0x10(%ebp),%eax
  801786:	eb 05                	jmp    80178d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801788:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80178d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	5f                   	pop    %edi
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
  80179a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80179d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a0:	50                   	push   %eax
  8017a1:	e8 ec f5 ff ff       	call   800d92 <fd_alloc>
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	89 c2                	mov    %eax,%edx
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	0f 88 2c 01 00 00    	js     8018df <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b3:	83 ec 04             	sub    $0x4,%esp
  8017b6:	68 07 04 00 00       	push   $0x407
  8017bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8017be:	6a 00                	push   $0x0
  8017c0:	e8 36 f3 ff ff       	call   800afb <sys_page_alloc>
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	89 c2                	mov    %eax,%edx
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	0f 88 0d 01 00 00    	js     8018df <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017d2:	83 ec 0c             	sub    $0xc,%esp
  8017d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d8:	50                   	push   %eax
  8017d9:	e8 b4 f5 ff ff       	call   800d92 <fd_alloc>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	0f 88 e2 00 00 00    	js     8018cd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017eb:	83 ec 04             	sub    $0x4,%esp
  8017ee:	68 07 04 00 00       	push   $0x407
  8017f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f6:	6a 00                	push   $0x0
  8017f8:	e8 fe f2 ff ff       	call   800afb <sys_page_alloc>
  8017fd:	89 c3                	mov    %eax,%ebx
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	85 c0                	test   %eax,%eax
  801804:	0f 88 c3 00 00 00    	js     8018cd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80180a:	83 ec 0c             	sub    $0xc,%esp
  80180d:	ff 75 f4             	pushl  -0xc(%ebp)
  801810:	e8 66 f5 ff ff       	call   800d7b <fd2data>
  801815:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801817:	83 c4 0c             	add    $0xc,%esp
  80181a:	68 07 04 00 00       	push   $0x407
  80181f:	50                   	push   %eax
  801820:	6a 00                	push   $0x0
  801822:	e8 d4 f2 ff ff       	call   800afb <sys_page_alloc>
  801827:	89 c3                	mov    %eax,%ebx
  801829:	83 c4 10             	add    $0x10,%esp
  80182c:	85 c0                	test   %eax,%eax
  80182e:	0f 88 89 00 00 00    	js     8018bd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801834:	83 ec 0c             	sub    $0xc,%esp
  801837:	ff 75 f0             	pushl  -0x10(%ebp)
  80183a:	e8 3c f5 ff ff       	call   800d7b <fd2data>
  80183f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801846:	50                   	push   %eax
  801847:	6a 00                	push   $0x0
  801849:	56                   	push   %esi
  80184a:	6a 00                	push   $0x0
  80184c:	e8 ed f2 ff ff       	call   800b3e <sys_page_map>
  801851:	89 c3                	mov    %eax,%ebx
  801853:	83 c4 20             	add    $0x20,%esp
  801856:	85 c0                	test   %eax,%eax
  801858:	78 55                	js     8018af <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80185a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801860:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801863:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801865:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801868:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80186f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801878:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80187a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801884:	83 ec 0c             	sub    $0xc,%esp
  801887:	ff 75 f4             	pushl  -0xc(%ebp)
  80188a:	e8 dc f4 ff ff       	call   800d6b <fd2num>
  80188f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801892:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801894:	83 c4 04             	add    $0x4,%esp
  801897:	ff 75 f0             	pushl  -0x10(%ebp)
  80189a:	e8 cc f4 ff ff       	call   800d6b <fd2num>
  80189f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018a2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ad:	eb 30                	jmp    8018df <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018af:	83 ec 08             	sub    $0x8,%esp
  8018b2:	56                   	push   %esi
  8018b3:	6a 00                	push   $0x0
  8018b5:	e8 c6 f2 ff ff       	call   800b80 <sys_page_unmap>
  8018ba:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018bd:	83 ec 08             	sub    $0x8,%esp
  8018c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c3:	6a 00                	push   $0x0
  8018c5:	e8 b6 f2 ff ff       	call   800b80 <sys_page_unmap>
  8018ca:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018cd:	83 ec 08             	sub    $0x8,%esp
  8018d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d3:	6a 00                	push   $0x0
  8018d5:	e8 a6 f2 ff ff       	call   800b80 <sys_page_unmap>
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018df:	89 d0                	mov    %edx,%eax
  8018e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e4:	5b                   	pop    %ebx
  8018e5:	5e                   	pop    %esi
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f1:	50                   	push   %eax
  8018f2:	ff 75 08             	pushl  0x8(%ebp)
  8018f5:	e8 e7 f4 ff ff       	call   800de1 <fd_lookup>
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	78 18                	js     801919 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801901:	83 ec 0c             	sub    $0xc,%esp
  801904:	ff 75 f4             	pushl  -0xc(%ebp)
  801907:	e8 6f f4 ff ff       	call   800d7b <fd2data>
	return _pipeisclosed(fd, p);
  80190c:	89 c2                	mov    %eax,%edx
  80190e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801911:	e8 21 fd ff ff       	call   801637 <_pipeisclosed>
  801916:	83 c4 10             	add    $0x10,%esp
}
  801919:	c9                   	leave  
  80191a:	c3                   	ret    

0080191b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80191e:	b8 00 00 00 00       	mov    $0x0,%eax
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    

00801925 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80192b:	68 05 23 80 00       	push   $0x802305
  801930:	ff 75 0c             	pushl  0xc(%ebp)
  801933:	e8 c0 ed ff ff       	call   8006f8 <strcpy>
	return 0;
}
  801938:	b8 00 00 00 00       	mov    $0x0,%eax
  80193d:	c9                   	leave  
  80193e:	c3                   	ret    

0080193f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	57                   	push   %edi
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80194b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801950:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801956:	eb 2d                	jmp    801985 <devcons_write+0x46>
		m = n - tot;
  801958:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80195b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80195d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801960:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801965:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801968:	83 ec 04             	sub    $0x4,%esp
  80196b:	53                   	push   %ebx
  80196c:	03 45 0c             	add    0xc(%ebp),%eax
  80196f:	50                   	push   %eax
  801970:	57                   	push   %edi
  801971:	e8 14 ef ff ff       	call   80088a <memmove>
		sys_cputs(buf, m);
  801976:	83 c4 08             	add    $0x8,%esp
  801979:	53                   	push   %ebx
  80197a:	57                   	push   %edi
  80197b:	e8 bf f0 ff ff       	call   800a3f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801980:	01 de                	add    %ebx,%esi
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	89 f0                	mov    %esi,%eax
  801987:	3b 75 10             	cmp    0x10(%ebp),%esi
  80198a:	72 cc                	jb     801958 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80198c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5f                   	pop    %edi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	83 ec 08             	sub    $0x8,%esp
  80199a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80199f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019a3:	74 2a                	je     8019cf <devcons_read+0x3b>
  8019a5:	eb 05                	jmp    8019ac <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019a7:	e8 30 f1 ff ff       	call   800adc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019ac:	e8 ac f0 ff ff       	call   800a5d <sys_cgetc>
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	74 f2                	je     8019a7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	78 16                	js     8019cf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019b9:	83 f8 04             	cmp    $0x4,%eax
  8019bc:	74 0c                	je     8019ca <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c1:	88 02                	mov    %al,(%edx)
	return 1;
  8019c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c8:	eb 05                	jmp    8019cf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019ca:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    

008019d1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019da:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019dd:	6a 01                	push   $0x1
  8019df:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019e2:	50                   	push   %eax
  8019e3:	e8 57 f0 ff ff       	call   800a3f <sys_cputs>
}
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    

008019ed <getchar>:

int
getchar(void)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019f3:	6a 01                	push   $0x1
  8019f5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019f8:	50                   	push   %eax
  8019f9:	6a 00                	push   $0x0
  8019fb:	e8 47 f6 ff ff       	call   801047 <read>
	if (r < 0)
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 0f                	js     801a16 <getchar+0x29>
		return r;
	if (r < 1)
  801a07:	85 c0                	test   %eax,%eax
  801a09:	7e 06                	jle    801a11 <getchar+0x24>
		return -E_EOF;
	return c;
  801a0b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a0f:	eb 05                	jmp    801a16 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a11:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a21:	50                   	push   %eax
  801a22:	ff 75 08             	pushl  0x8(%ebp)
  801a25:	e8 b7 f3 ff ff       	call   800de1 <fd_lookup>
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	78 11                	js     801a42 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a34:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a3a:	39 10                	cmp    %edx,(%eax)
  801a3c:	0f 94 c0             	sete   %al
  801a3f:	0f b6 c0             	movzbl %al,%eax
}
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <opencons>:

int
opencons(void)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4d:	50                   	push   %eax
  801a4e:	e8 3f f3 ff ff       	call   800d92 <fd_alloc>
  801a53:	83 c4 10             	add    $0x10,%esp
		return r;
  801a56:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 3e                	js     801a9a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a5c:	83 ec 04             	sub    $0x4,%esp
  801a5f:	68 07 04 00 00       	push   $0x407
  801a64:	ff 75 f4             	pushl  -0xc(%ebp)
  801a67:	6a 00                	push   $0x0
  801a69:	e8 8d f0 ff ff       	call   800afb <sys_page_alloc>
  801a6e:	83 c4 10             	add    $0x10,%esp
		return r;
  801a71:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 23                	js     801a9a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a77:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a80:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a85:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	50                   	push   %eax
  801a90:	e8 d6 f2 ff ff       	call   800d6b <fd2num>
  801a95:	89 c2                	mov    %eax,%edx
  801a97:	83 c4 10             	add    $0x10,%esp
}
  801a9a:	89 d0                	mov    %edx,%eax
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801aa3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801aa6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801aac:	e8 0c f0 ff ff       	call   800abd <sys_getenvid>
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	ff 75 0c             	pushl  0xc(%ebp)
  801ab7:	ff 75 08             	pushl  0x8(%ebp)
  801aba:	56                   	push   %esi
  801abb:	50                   	push   %eax
  801abc:	68 14 23 80 00       	push   $0x802314
  801ac1:	e8 ad e6 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ac6:	83 c4 18             	add    $0x18,%esp
  801ac9:	53                   	push   %ebx
  801aca:	ff 75 10             	pushl  0x10(%ebp)
  801acd:	e8 50 e6 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801ad2:	c7 04 24 fe 22 80 00 	movl   $0x8022fe,(%esp)
  801ad9:	e8 95 e6 ff ff       	call   800173 <cprintf>
  801ade:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ae1:	cc                   	int3   
  801ae2:	eb fd                	jmp    801ae1 <_panic+0x43>

00801ae4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	8b 75 08             	mov    0x8(%ebp),%esi
  801aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801af2:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801af4:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801af9:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801afc:	83 ec 0c             	sub    $0xc,%esp
  801aff:	50                   	push   %eax
  801b00:	e8 a6 f1 ff ff       	call   800cab <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	78 0e                	js     801b1a <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801b0c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b12:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801b15:	8b 52 78             	mov    0x78(%edx),%edx
  801b18:	eb 0a                	jmp    801b24 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801b1a:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801b1f:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801b24:	85 f6                	test   %esi,%esi
  801b26:	74 02                	je     801b2a <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801b28:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801b2a:	85 db                	test   %ebx,%ebx
  801b2c:	74 02                	je     801b30 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801b2e:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801b30:	85 c0                	test   %eax,%eax
  801b32:	78 08                	js     801b3c <ipc_recv+0x58>
  801b34:	a1 04 40 80 00       	mov    0x804004,%eax
  801b39:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801b3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	57                   	push   %edi
  801b47:	56                   	push   %esi
  801b48:	53                   	push   %ebx
  801b49:	83 ec 0c             	sub    $0xc,%esp
  801b4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801b55:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801b57:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801b5c:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801b5f:	ff 75 14             	pushl  0x14(%ebp)
  801b62:	53                   	push   %ebx
  801b63:	56                   	push   %esi
  801b64:	57                   	push   %edi
  801b65:	e8 1e f1 ff ff       	call   800c88 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b70:	75 07                	jne    801b79 <ipc_send+0x36>
				    sys_yield();
  801b72:	e8 65 ef ff ff       	call   800adc <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801b77:	eb e6                	jmp    801b5f <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	74 12                	je     801b8f <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801b7d:	50                   	push   %eax
  801b7e:	68 38 23 80 00       	push   $0x802338
  801b83:	6a 4b                	push   $0x4b
  801b85:	68 4c 23 80 00       	push   $0x80234c
  801b8a:	e8 0f ff ff ff       	call   801a9e <_panic>
			 }
	   }
}
  801b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5f                   	pop    %edi
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801b9d:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801ba2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ba5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bab:	8b 52 50             	mov    0x50(%edx),%edx
  801bae:	39 ca                	cmp    %ecx,%edx
  801bb0:	75 0d                	jne    801bbf <ipc_find_env+0x28>
				    return envs[i].env_id;
  801bb2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bb5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bba:	8b 40 48             	mov    0x48(%eax),%eax
  801bbd:	eb 0f                	jmp    801bce <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801bbf:	83 c0 01             	add    $0x1,%eax
  801bc2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bc7:	75 d9                	jne    801ba2 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd6:	89 d0                	mov    %edx,%eax
  801bd8:	c1 e8 16             	shr    $0x16,%eax
  801bdb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801be2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be7:	f6 c1 01             	test   $0x1,%cl
  801bea:	74 1d                	je     801c09 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bec:	c1 ea 0c             	shr    $0xc,%edx
  801bef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bf6:	f6 c2 01             	test   $0x1,%dl
  801bf9:	74 0e                	je     801c09 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bfb:	c1 ea 0c             	shr    $0xc,%edx
  801bfe:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c05:	ef 
  801c06:	0f b7 c0             	movzwl %ax,%eax
}
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    
  801c0b:	66 90                	xchg   %ax,%ax
  801c0d:	66 90                	xchg   %ax,%ax
  801c0f:	90                   	nop

00801c10 <__udivdi3>:
  801c10:	55                   	push   %ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	83 ec 1c             	sub    $0x1c,%esp
  801c17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c27:	85 f6                	test   %esi,%esi
  801c29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c2d:	89 ca                	mov    %ecx,%edx
  801c2f:	89 f8                	mov    %edi,%eax
  801c31:	75 3d                	jne    801c70 <__udivdi3+0x60>
  801c33:	39 cf                	cmp    %ecx,%edi
  801c35:	0f 87 c5 00 00 00    	ja     801d00 <__udivdi3+0xf0>
  801c3b:	85 ff                	test   %edi,%edi
  801c3d:	89 fd                	mov    %edi,%ebp
  801c3f:	75 0b                	jne    801c4c <__udivdi3+0x3c>
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	31 d2                	xor    %edx,%edx
  801c48:	f7 f7                	div    %edi
  801c4a:	89 c5                	mov    %eax,%ebp
  801c4c:	89 c8                	mov    %ecx,%eax
  801c4e:	31 d2                	xor    %edx,%edx
  801c50:	f7 f5                	div    %ebp
  801c52:	89 c1                	mov    %eax,%ecx
  801c54:	89 d8                	mov    %ebx,%eax
  801c56:	89 cf                	mov    %ecx,%edi
  801c58:	f7 f5                	div    %ebp
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
  801c68:	90                   	nop
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	39 ce                	cmp    %ecx,%esi
  801c72:	77 74                	ja     801ce8 <__udivdi3+0xd8>
  801c74:	0f bd fe             	bsr    %esi,%edi
  801c77:	83 f7 1f             	xor    $0x1f,%edi
  801c7a:	0f 84 98 00 00 00    	je     801d18 <__udivdi3+0x108>
  801c80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	89 c5                	mov    %eax,%ebp
  801c89:	29 fb                	sub    %edi,%ebx
  801c8b:	d3 e6                	shl    %cl,%esi
  801c8d:	89 d9                	mov    %ebx,%ecx
  801c8f:	d3 ed                	shr    %cl,%ebp
  801c91:	89 f9                	mov    %edi,%ecx
  801c93:	d3 e0                	shl    %cl,%eax
  801c95:	09 ee                	or     %ebp,%esi
  801c97:	89 d9                	mov    %ebx,%ecx
  801c99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c9d:	89 d5                	mov    %edx,%ebp
  801c9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ca3:	d3 ed                	shr    %cl,%ebp
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 e2                	shl    %cl,%edx
  801ca9:	89 d9                	mov    %ebx,%ecx
  801cab:	d3 e8                	shr    %cl,%eax
  801cad:	09 c2                	or     %eax,%edx
  801caf:	89 d0                	mov    %edx,%eax
  801cb1:	89 ea                	mov    %ebp,%edx
  801cb3:	f7 f6                	div    %esi
  801cb5:	89 d5                	mov    %edx,%ebp
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	f7 64 24 0c          	mull   0xc(%esp)
  801cbd:	39 d5                	cmp    %edx,%ebp
  801cbf:	72 10                	jb     801cd1 <__udivdi3+0xc1>
  801cc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 e6                	shl    %cl,%esi
  801cc9:	39 c6                	cmp    %eax,%esi
  801ccb:	73 07                	jae    801cd4 <__udivdi3+0xc4>
  801ccd:	39 d5                	cmp    %edx,%ebp
  801ccf:	75 03                	jne    801cd4 <__udivdi3+0xc4>
  801cd1:	83 eb 01             	sub    $0x1,%ebx
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 d8                	mov    %ebx,%eax
  801cd8:	89 fa                	mov    %edi,%edx
  801cda:	83 c4 1c             	add    $0x1c,%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
  801ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce8:	31 ff                	xor    %edi,%edi
  801cea:	31 db                	xor    %ebx,%ebx
  801cec:	89 d8                	mov    %ebx,%eax
  801cee:	89 fa                	mov    %edi,%edx
  801cf0:	83 c4 1c             	add    $0x1c,%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    
  801cf8:	90                   	nop
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 d8                	mov    %ebx,%eax
  801d02:	f7 f7                	div    %edi
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	89 fa                	mov    %edi,%edx
  801d0c:	83 c4 1c             	add    $0x1c,%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    
  801d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d18:	39 ce                	cmp    %ecx,%esi
  801d1a:	72 0c                	jb     801d28 <__udivdi3+0x118>
  801d1c:	31 db                	xor    %ebx,%ebx
  801d1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d22:	0f 87 34 ff ff ff    	ja     801c5c <__udivdi3+0x4c>
  801d28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d2d:	e9 2a ff ff ff       	jmp    801c5c <__udivdi3+0x4c>
  801d32:	66 90                	xchg   %ax,%ax
  801d34:	66 90                	xchg   %ax,%ax
  801d36:	66 90                	xchg   %ax,%ax
  801d38:	66 90                	xchg   %ax,%ax
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__umoddi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 1c             	sub    $0x1c,%esp
  801d47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d57:	85 d2                	test   %edx,%edx
  801d59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d61:	89 f3                	mov    %esi,%ebx
  801d63:	89 3c 24             	mov    %edi,(%esp)
  801d66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6a:	75 1c                	jne    801d88 <__umoddi3+0x48>
  801d6c:	39 f7                	cmp    %esi,%edi
  801d6e:	76 50                	jbe    801dc0 <__umoddi3+0x80>
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	f7 f7                	div    %edi
  801d76:	89 d0                	mov    %edx,%eax
  801d78:	31 d2                	xor    %edx,%edx
  801d7a:	83 c4 1c             	add    $0x1c,%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    
  801d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d88:	39 f2                	cmp    %esi,%edx
  801d8a:	89 d0                	mov    %edx,%eax
  801d8c:	77 52                	ja     801de0 <__umoddi3+0xa0>
  801d8e:	0f bd ea             	bsr    %edx,%ebp
  801d91:	83 f5 1f             	xor    $0x1f,%ebp
  801d94:	75 5a                	jne    801df0 <__umoddi3+0xb0>
  801d96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d9a:	0f 82 e0 00 00 00    	jb     801e80 <__umoddi3+0x140>
  801da0:	39 0c 24             	cmp    %ecx,(%esp)
  801da3:	0f 86 d7 00 00 00    	jbe    801e80 <__umoddi3+0x140>
  801da9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dad:	8b 54 24 04          	mov    0x4(%esp),%edx
  801db1:	83 c4 1c             	add    $0x1c,%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5f                   	pop    %edi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	85 ff                	test   %edi,%edi
  801dc2:	89 fd                	mov    %edi,%ebp
  801dc4:	75 0b                	jne    801dd1 <__umoddi3+0x91>
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f7                	div    %edi
  801dcf:	89 c5                	mov    %eax,%ebp
  801dd1:	89 f0                	mov    %esi,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f5                	div    %ebp
  801dd7:	89 c8                	mov    %ecx,%eax
  801dd9:	f7 f5                	div    %ebp
  801ddb:	89 d0                	mov    %edx,%eax
  801ddd:	eb 99                	jmp    801d78 <__umoddi3+0x38>
  801ddf:	90                   	nop
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	83 c4 1c             	add    $0x1c,%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5e                   	pop    %esi
  801de9:	5f                   	pop    %edi
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    
  801dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df0:	8b 34 24             	mov    (%esp),%esi
  801df3:	bf 20 00 00 00       	mov    $0x20,%edi
  801df8:	89 e9                	mov    %ebp,%ecx
  801dfa:	29 ef                	sub    %ebp,%edi
  801dfc:	d3 e0                	shl    %cl,%eax
  801dfe:	89 f9                	mov    %edi,%ecx
  801e00:	89 f2                	mov    %esi,%edx
  801e02:	d3 ea                	shr    %cl,%edx
  801e04:	89 e9                	mov    %ebp,%ecx
  801e06:	09 c2                	or     %eax,%edx
  801e08:	89 d8                	mov    %ebx,%eax
  801e0a:	89 14 24             	mov    %edx,(%esp)
  801e0d:	89 f2                	mov    %esi,%edx
  801e0f:	d3 e2                	shl    %cl,%edx
  801e11:	89 f9                	mov    %edi,%ecx
  801e13:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e1b:	d3 e8                	shr    %cl,%eax
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	89 c6                	mov    %eax,%esi
  801e21:	d3 e3                	shl    %cl,%ebx
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 d0                	mov    %edx,%eax
  801e27:	d3 e8                	shr    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	09 d8                	or     %ebx,%eax
  801e2d:	89 d3                	mov    %edx,%ebx
  801e2f:	89 f2                	mov    %esi,%edx
  801e31:	f7 34 24             	divl   (%esp)
  801e34:	89 d6                	mov    %edx,%esi
  801e36:	d3 e3                	shl    %cl,%ebx
  801e38:	f7 64 24 04          	mull   0x4(%esp)
  801e3c:	39 d6                	cmp    %edx,%esi
  801e3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e42:	89 d1                	mov    %edx,%ecx
  801e44:	89 c3                	mov    %eax,%ebx
  801e46:	72 08                	jb     801e50 <__umoddi3+0x110>
  801e48:	75 11                	jne    801e5b <__umoddi3+0x11b>
  801e4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e4e:	73 0b                	jae    801e5b <__umoddi3+0x11b>
  801e50:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e54:	1b 14 24             	sbb    (%esp),%edx
  801e57:	89 d1                	mov    %edx,%ecx
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e5f:	29 da                	sub    %ebx,%edx
  801e61:	19 ce                	sbb    %ecx,%esi
  801e63:	89 f9                	mov    %edi,%ecx
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	d3 e0                	shl    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	d3 ea                	shr    %cl,%edx
  801e6d:	89 e9                	mov    %ebp,%ecx
  801e6f:	d3 ee                	shr    %cl,%esi
  801e71:	09 d0                	or     %edx,%eax
  801e73:	89 f2                	mov    %esi,%edx
  801e75:	83 c4 1c             	add    $0x1c,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    
  801e7d:	8d 76 00             	lea    0x0(%esi),%esi
  801e80:	29 f9                	sub    %edi,%ecx
  801e82:	19 d6                	sbb    %edx,%esi
  801e84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e8c:	e9 18 ff ff ff       	jmp    801da9 <__umoddi3+0x69>
