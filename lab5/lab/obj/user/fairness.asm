
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 9e 0a 00 00       	call   800ade <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 af 0c 00 00       	call   800d0d <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 40 1e 80 00       	push   $0x801e40
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 51 1e 80 00       	push   $0x801e51
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 d0 0c 00 00       	call   800d6c <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000ac:	e8 2d 0a 00 00       	call   800ade <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 d2 0e 00 00       	call   800fc4 <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 a1 09 00 00       	call   800a9d <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 2f 09 00 00       	call   800a60 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 54 01 00 00       	call   8002cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 d4 08 00 00       	call   800a60 <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 45                	ja     80021d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 b4 19 00 00       	call   801bb0 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 18                	jmp    800227 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb 03                	jmp    800220 <printnum+0x78>
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	85 db                	test   %ebx,%ebx
  800225:	7f e8                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 a1 1a 00 00       	call   801ce0 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 72 1e 80 00 	movsbl 0x801e72(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d7                	call   *%edi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025a:	83 fa 01             	cmp    $0x1,%edx
  80025d:	7e 0e                	jle    80026d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025f:	8b 10                	mov    (%eax),%edx
  800261:	8d 4a 08             	lea    0x8(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 02                	mov    (%edx),%eax
  800268:	8b 52 04             	mov    0x4(%edx),%edx
  80026b:	eb 22                	jmp    80028f <getuint+0x38>
	else if (lflag)
  80026d:	85 d2                	test   %edx,%edx
  80026f:	74 10                	je     800281 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
  80027f:	eb 0e                	jmp    80028f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 04             	lea    0x4(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800297:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a0:	73 0a                	jae    8002ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	88 02                	mov    %al,(%edx)
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	50                   	push   %eax
  8002b8:	ff 75 10             	pushl  0x10(%ebp)
  8002bb:	ff 75 0c             	pushl  0xc(%ebp)
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	e8 05 00 00 00       	call   8002cb <vprintfmt>
	va_end(ap);
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
  8002d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002dd:	eb 12                	jmp    8002f1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	0f 84 89 03 00 00    	je     800670 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	53                   	push   %ebx
  8002eb:	50                   	push   %eax
  8002ec:	ff d6                	call   *%esi
  8002ee:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f1:	83 c7 01             	add    $0x1,%edi
  8002f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f8:	83 f8 25             	cmp    $0x25,%eax
  8002fb:	75 e2                	jne    8002df <vprintfmt+0x14>
  8002fd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800301:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800308:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80030f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
  80031b:	eb 07                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800320:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8d 47 01             	lea    0x1(%edi),%eax
  800327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032a:	0f b6 07             	movzbl (%edi),%eax
  80032d:	0f b6 c8             	movzbl %al,%ecx
  800330:	83 e8 23             	sub    $0x23,%eax
  800333:	3c 55                	cmp    $0x55,%al
  800335:	0f 87 1a 03 00 00    	ja     800655 <vprintfmt+0x38a>
  80033b:	0f b6 c0             	movzbl %al,%eax
  80033e:	ff 24 85 c0 1f 80 00 	jmp    *0x801fc0(,%eax,4)
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800348:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034c:	eb d6                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800351:	b8 00 00 00 00       	mov    $0x0,%eax
  800356:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800359:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800360:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800363:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800366:	83 fa 09             	cmp    $0x9,%edx
  800369:	77 39                	ja     8003a4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036e:	eb e9                	jmp    800359 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 48 04             	lea    0x4(%eax),%ecx
  800376:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800381:	eb 27                	jmp    8003aa <vprintfmt+0xdf>
  800383:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800386:	85 c0                	test   %eax,%eax
  800388:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038d:	0f 49 c8             	cmovns %eax,%ecx
  800390:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800396:	eb 8c                	jmp    800324 <vprintfmt+0x59>
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a2:	eb 80                	jmp    800324 <vprintfmt+0x59>
  8003a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ae:	0f 89 70 ff ff ff    	jns    800324 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c1:	e9 5e ff ff ff       	jmp    800324 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cc:	e9 53 ff ff ff       	jmp    800324 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 50 04             	lea    0x4(%eax),%edx
  8003d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	53                   	push   %ebx
  8003de:	ff 30                	pushl  (%eax)
  8003e0:	ff d6                	call   *%esi
			break;
  8003e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e8:	e9 04 ff ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	8b 00                	mov    (%eax),%eax
  8003f8:	99                   	cltd   
  8003f9:	31 d0                	xor    %edx,%eax
  8003fb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fd:	83 f8 0f             	cmp    $0xf,%eax
  800400:	7f 0b                	jg     80040d <vprintfmt+0x142>
  800402:	8b 14 85 20 21 80 00 	mov    0x802120(,%eax,4),%edx
  800409:	85 d2                	test   %edx,%edx
  80040b:	75 18                	jne    800425 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040d:	50                   	push   %eax
  80040e:	68 8a 1e 80 00       	push   $0x801e8a
  800413:	53                   	push   %ebx
  800414:	56                   	push   %esi
  800415:	e8 94 fe ff ff       	call   8002ae <printfmt>
  80041a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800420:	e9 cc fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800425:	52                   	push   %edx
  800426:	68 6d 22 80 00       	push   $0x80226d
  80042b:	53                   	push   %ebx
  80042c:	56                   	push   %esi
  80042d:	e8 7c fe ff ff       	call   8002ae <printfmt>
  800432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800438:	e9 b4 fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800448:	85 ff                	test   %edi,%edi
  80044a:	b8 83 1e 80 00       	mov    $0x801e83,%eax
  80044f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800452:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800456:	0f 8e 94 00 00 00    	jle    8004f0 <vprintfmt+0x225>
  80045c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800460:	0f 84 98 00 00 00    	je     8004fe <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	ff 75 d0             	pushl  -0x30(%ebp)
  80046c:	57                   	push   %edi
  80046d:	e8 86 02 00 00       	call   8006f8 <strnlen>
  800472:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800475:	29 c1                	sub    %eax,%ecx
  800477:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800481:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800484:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800487:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	eb 0f                	jmp    80049a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	53                   	push   %ebx
  80048f:	ff 75 e0             	pushl  -0x20(%ebp)
  800492:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800494:	83 ef 01             	sub    $0x1,%edi
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	85 ff                	test   %edi,%edi
  80049c:	7f ed                	jg     80048b <vprintfmt+0x1c0>
  80049e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a4:	85 c9                	test   %ecx,%ecx
  8004a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ab:	0f 49 c1             	cmovns %ecx,%eax
  8004ae:	29 c1                	sub    %eax,%ecx
  8004b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b9:	89 cb                	mov    %ecx,%ebx
  8004bb:	eb 4d                	jmp    80050a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c1:	74 1b                	je     8004de <vprintfmt+0x213>
  8004c3:	0f be c0             	movsbl %al,%eax
  8004c6:	83 e8 20             	sub    $0x20,%eax
  8004c9:	83 f8 5e             	cmp    $0x5e,%eax
  8004cc:	76 10                	jbe    8004de <vprintfmt+0x213>
					putch('?', putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	ff 75 0c             	pushl  0xc(%ebp)
  8004d4:	6a 3f                	push   $0x3f
  8004d6:	ff 55 08             	call   *0x8(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	eb 0d                	jmp    8004eb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	ff 75 0c             	pushl  0xc(%ebp)
  8004e4:	52                   	push   %edx
  8004e5:	ff 55 08             	call   *0x8(%ebp)
  8004e8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004eb:	83 eb 01             	sub    $0x1,%ebx
  8004ee:	eb 1a                	jmp    80050a <vprintfmt+0x23f>
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fc:	eb 0c                	jmp    80050a <vprintfmt+0x23f>
  8004fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800501:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800504:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800507:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050a:	83 c7 01             	add    $0x1,%edi
  80050d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800511:	0f be d0             	movsbl %al,%edx
  800514:	85 d2                	test   %edx,%edx
  800516:	74 23                	je     80053b <vprintfmt+0x270>
  800518:	85 f6                	test   %esi,%esi
  80051a:	78 a1                	js     8004bd <vprintfmt+0x1f2>
  80051c:	83 ee 01             	sub    $0x1,%esi
  80051f:	79 9c                	jns    8004bd <vprintfmt+0x1f2>
  800521:	89 df                	mov    %ebx,%edi
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	eb 18                	jmp    800543 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	53                   	push   %ebx
  80052f:	6a 20                	push   $0x20
  800531:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800533:	83 ef 01             	sub    $0x1,%edi
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 08                	jmp    800543 <vprintfmt+0x278>
  80053b:	89 df                	mov    %ebx,%edi
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	85 ff                	test   %edi,%edi
  800545:	7f e4                	jg     80052b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054a:	e9 a2 fd ff ff       	jmp    8002f1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054f:	83 fa 01             	cmp    $0x1,%edx
  800552:	7e 16                	jle    80056a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 08             	lea    0x8(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 50 04             	mov    0x4(%eax),%edx
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800568:	eb 32                	jmp    80059c <vprintfmt+0x2d1>
	else if (lflag)
  80056a:	85 d2                	test   %edx,%edx
  80056c:	74 18                	je     800586 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 50 04             	lea    0x4(%eax),%edx
  800574:	89 55 14             	mov    %edx,0x14(%ebp)
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 c1                	mov    %eax,%ecx
  80057e:	c1 f9 1f             	sar    $0x1f,%ecx
  800581:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800584:	eb 16                	jmp    80059c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 c1                	mov    %eax,%ecx
  800596:	c1 f9 1f             	sar    $0x1f,%ecx
  800599:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ab:	79 74                	jns    800621 <vprintfmt+0x356>
				putch('-', putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	53                   	push   %ebx
  8005b1:	6a 2d                	push   $0x2d
  8005b3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005bb:	f7 d8                	neg    %eax
  8005bd:	83 d2 00             	adc    $0x0,%edx
  8005c0:	f7 da                	neg    %edx
  8005c2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ca:	eb 55                	jmp    800621 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cf:	e8 83 fc ff ff       	call   800257 <getuint>
			base = 10;
  8005d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d9:	eb 46                	jmp    800621 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005db:	8d 45 14             	lea    0x14(%ebp),%eax
  8005de:	e8 74 fc ff ff       	call   800257 <getuint>
			base = 8;
  8005e3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e8:	eb 37                	jmp    800621 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	53                   	push   %ebx
  8005ee:	6a 30                	push   $0x30
  8005f0:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f2:	83 c4 08             	add    $0x8,%esp
  8005f5:	53                   	push   %ebx
  8005f6:	6a 78                	push   $0x78
  8005f8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800603:	8b 00                	mov    (%eax),%eax
  800605:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800612:	eb 0d                	jmp    800621 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800614:	8d 45 14             	lea    0x14(%ebp),%eax
  800617:	e8 3b fc ff ff       	call   800257 <getuint>
			base = 16;
  80061c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800628:	57                   	push   %edi
  800629:	ff 75 e0             	pushl  -0x20(%ebp)
  80062c:	51                   	push   %ecx
  80062d:	52                   	push   %edx
  80062e:	50                   	push   %eax
  80062f:	89 da                	mov    %ebx,%edx
  800631:	89 f0                	mov    %esi,%eax
  800633:	e8 70 fb ff ff       	call   8001a8 <printnum>
			break;
  800638:	83 c4 20             	add    $0x20,%esp
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063e:	e9 ae fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	51                   	push   %ecx
  800648:	ff d6                	call   *%esi
			break;
  80064a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800650:	e9 9c fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 25                	push   $0x25
  80065b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	eb 03                	jmp    800665 <vprintfmt+0x39a>
  800662:	83 ef 01             	sub    $0x1,%edi
  800665:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800669:	75 f7                	jne    800662 <vprintfmt+0x397>
  80066b:	e9 81 fc ff ff       	jmp    8002f1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	83 ec 18             	sub    $0x18,%esp
  80067e:	8b 45 08             	mov    0x8(%ebp),%eax
  800681:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800684:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800687:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800695:	85 c0                	test   %eax,%eax
  800697:	74 26                	je     8006bf <vsnprintf+0x47>
  800699:	85 d2                	test   %edx,%edx
  80069b:	7e 22                	jle    8006bf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069d:	ff 75 14             	pushl  0x14(%ebp)
  8006a0:	ff 75 10             	pushl  0x10(%ebp)
  8006a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a6:	50                   	push   %eax
  8006a7:	68 91 02 80 00       	push   $0x800291
  8006ac:	e8 1a fc ff ff       	call   8002cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	eb 05                	jmp    8006c4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c4:	c9                   	leave  
  8006c5:	c3                   	ret    

008006c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006cf:	50                   	push   %eax
  8006d0:	ff 75 10             	pushl  0x10(%ebp)
  8006d3:	ff 75 0c             	pushl  0xc(%ebp)
  8006d6:	ff 75 08             	pushl  0x8(%ebp)
  8006d9:	e8 9a ff ff ff       	call   800678 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 03                	jmp    8006f0 <strlen+0x10>
		n++;
  8006ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f4:	75 f7                	jne    8006ed <strlen+0xd>
		n++;
	return n;
}
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fe:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800701:	ba 00 00 00 00       	mov    $0x0,%edx
  800706:	eb 03                	jmp    80070b <strnlen+0x13>
		n++;
  800708:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070b:	39 c2                	cmp    %eax,%edx
  80070d:	74 08                	je     800717 <strnlen+0x1f>
  80070f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800713:	75 f3                	jne    800708 <strnlen+0x10>
  800715:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	53                   	push   %ebx
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800723:	89 c2                	mov    %eax,%edx
  800725:	83 c2 01             	add    $0x1,%edx
  800728:	83 c1 01             	add    $0x1,%ecx
  80072b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800732:	84 db                	test   %bl,%bl
  800734:	75 ef                	jne    800725 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800736:	5b                   	pop    %ebx
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	53                   	push   %ebx
  80073d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800740:	53                   	push   %ebx
  800741:	e8 9a ff ff ff       	call   8006e0 <strlen>
  800746:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800749:	ff 75 0c             	pushl  0xc(%ebp)
  80074c:	01 d8                	add    %ebx,%eax
  80074e:	50                   	push   %eax
  80074f:	e8 c5 ff ff ff       	call   800719 <strcpy>
	return dst;
}
  800754:	89 d8                	mov    %ebx,%eax
  800756:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	56                   	push   %esi
  80075f:	53                   	push   %ebx
  800760:	8b 75 08             	mov    0x8(%ebp),%esi
  800763:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800766:	89 f3                	mov    %esi,%ebx
  800768:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076b:	89 f2                	mov    %esi,%edx
  80076d:	eb 0f                	jmp    80077e <strncpy+0x23>
		*dst++ = *src;
  80076f:	83 c2 01             	add    $0x1,%edx
  800772:	0f b6 01             	movzbl (%ecx),%eax
  800775:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800778:	80 39 01             	cmpb   $0x1,(%ecx)
  80077b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077e:	39 da                	cmp    %ebx,%edx
  800780:	75 ed                	jne    80076f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800782:	89 f0                	mov    %esi,%eax
  800784:	5b                   	pop    %ebx
  800785:	5e                   	pop    %esi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	56                   	push   %esi
  80078c:	53                   	push   %ebx
  80078d:	8b 75 08             	mov    0x8(%ebp),%esi
  800790:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800793:	8b 55 10             	mov    0x10(%ebp),%edx
  800796:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800798:	85 d2                	test   %edx,%edx
  80079a:	74 21                	je     8007bd <strlcpy+0x35>
  80079c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a0:	89 f2                	mov    %esi,%edx
  8007a2:	eb 09                	jmp    8007ad <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a4:	83 c2 01             	add    $0x1,%edx
  8007a7:	83 c1 01             	add    $0x1,%ecx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ad:	39 c2                	cmp    %eax,%edx
  8007af:	74 09                	je     8007ba <strlcpy+0x32>
  8007b1:	0f b6 19             	movzbl (%ecx),%ebx
  8007b4:	84 db                	test   %bl,%bl
  8007b6:	75 ec                	jne    8007a4 <strlcpy+0x1c>
  8007b8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ba:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007bd:	29 f0                	sub    %esi,%eax
}
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cc:	eb 06                	jmp    8007d4 <strcmp+0x11>
		p++, q++;
  8007ce:	83 c1 01             	add    $0x1,%ecx
  8007d1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d4:	0f b6 01             	movzbl (%ecx),%eax
  8007d7:	84 c0                	test   %al,%al
  8007d9:	74 04                	je     8007df <strcmp+0x1c>
  8007db:	3a 02                	cmp    (%edx),%al
  8007dd:	74 ef                	je     8007ce <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007df:	0f b6 c0             	movzbl %al,%eax
  8007e2:	0f b6 12             	movzbl (%edx),%edx
  8007e5:	29 d0                	sub    %edx,%eax
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f3:	89 c3                	mov    %eax,%ebx
  8007f5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f8:	eb 06                	jmp    800800 <strncmp+0x17>
		n--, p++, q++;
  8007fa:	83 c0 01             	add    $0x1,%eax
  8007fd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800800:	39 d8                	cmp    %ebx,%eax
  800802:	74 15                	je     800819 <strncmp+0x30>
  800804:	0f b6 08             	movzbl (%eax),%ecx
  800807:	84 c9                	test   %cl,%cl
  800809:	74 04                	je     80080f <strncmp+0x26>
  80080b:	3a 0a                	cmp    (%edx),%cl
  80080d:	74 eb                	je     8007fa <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080f:	0f b6 00             	movzbl (%eax),%eax
  800812:	0f b6 12             	movzbl (%edx),%edx
  800815:	29 d0                	sub    %edx,%eax
  800817:	eb 05                	jmp    80081e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081e:	5b                   	pop    %ebx
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	eb 07                	jmp    800834 <strchr+0x13>
		if (*s == c)
  80082d:	38 ca                	cmp    %cl,%dl
  80082f:	74 0f                	je     800840 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800831:	83 c0 01             	add    $0x1,%eax
  800834:	0f b6 10             	movzbl (%eax),%edx
  800837:	84 d2                	test   %dl,%dl
  800839:	75 f2                	jne    80082d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084c:	eb 03                	jmp    800851 <strfind+0xf>
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800854:	38 ca                	cmp    %cl,%dl
  800856:	74 04                	je     80085c <strfind+0x1a>
  800858:	84 d2                	test   %dl,%dl
  80085a:	75 f2                	jne    80084e <strfind+0xc>
			break;
	return (char *) s;
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	57                   	push   %edi
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 7d 08             	mov    0x8(%ebp),%edi
  800867:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086a:	85 c9                	test   %ecx,%ecx
  80086c:	74 36                	je     8008a4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800874:	75 28                	jne    80089e <memset+0x40>
  800876:	f6 c1 03             	test   $0x3,%cl
  800879:	75 23                	jne    80089e <memset+0x40>
		c &= 0xFF;
  80087b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087f:	89 d3                	mov    %edx,%ebx
  800881:	c1 e3 08             	shl    $0x8,%ebx
  800884:	89 d6                	mov    %edx,%esi
  800886:	c1 e6 18             	shl    $0x18,%esi
  800889:	89 d0                	mov    %edx,%eax
  80088b:	c1 e0 10             	shl    $0x10,%eax
  80088e:	09 f0                	or     %esi,%eax
  800890:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800892:	89 d8                	mov    %ebx,%eax
  800894:	09 d0                	or     %edx,%eax
  800896:	c1 e9 02             	shr    $0x2,%ecx
  800899:	fc                   	cld    
  80089a:	f3 ab                	rep stos %eax,%es:(%edi)
  80089c:	eb 06                	jmp    8008a4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a1:	fc                   	cld    
  8008a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a4:	89 f8                	mov    %edi,%eax
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	57                   	push   %edi
  8008af:	56                   	push   %esi
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b9:	39 c6                	cmp    %eax,%esi
  8008bb:	73 35                	jae    8008f2 <memmove+0x47>
  8008bd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c0:	39 d0                	cmp    %edx,%eax
  8008c2:	73 2e                	jae    8008f2 <memmove+0x47>
		s += n;
		d += n;
  8008c4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c7:	89 d6                	mov    %edx,%esi
  8008c9:	09 fe                	or     %edi,%esi
  8008cb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d1:	75 13                	jne    8008e6 <memmove+0x3b>
  8008d3:	f6 c1 03             	test   $0x3,%cl
  8008d6:	75 0e                	jne    8008e6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d8:	83 ef 04             	sub    $0x4,%edi
  8008db:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008de:	c1 e9 02             	shr    $0x2,%ecx
  8008e1:	fd                   	std    
  8008e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e4:	eb 09                	jmp    8008ef <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e6:	83 ef 01             	sub    $0x1,%edi
  8008e9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ec:	fd                   	std    
  8008ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ef:	fc                   	cld    
  8008f0:	eb 1d                	jmp    80090f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f2:	89 f2                	mov    %esi,%edx
  8008f4:	09 c2                	or     %eax,%edx
  8008f6:	f6 c2 03             	test   $0x3,%dl
  8008f9:	75 0f                	jne    80090a <memmove+0x5f>
  8008fb:	f6 c1 03             	test   $0x3,%cl
  8008fe:	75 0a                	jne    80090a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800900:	c1 e9 02             	shr    $0x2,%ecx
  800903:	89 c7                	mov    %eax,%edi
  800905:	fc                   	cld    
  800906:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800908:	eb 05                	jmp    80090f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090a:	89 c7                	mov    %eax,%edi
  80090c:	fc                   	cld    
  80090d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090f:	5e                   	pop    %esi
  800910:	5f                   	pop    %edi
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800916:	ff 75 10             	pushl  0x10(%ebp)
  800919:	ff 75 0c             	pushl  0xc(%ebp)
  80091c:	ff 75 08             	pushl  0x8(%ebp)
  80091f:	e8 87 ff ff ff       	call   8008ab <memmove>
}
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	89 c6                	mov    %eax,%esi
  800933:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800936:	eb 1a                	jmp    800952 <memcmp+0x2c>
		if (*s1 != *s2)
  800938:	0f b6 08             	movzbl (%eax),%ecx
  80093b:	0f b6 1a             	movzbl (%edx),%ebx
  80093e:	38 d9                	cmp    %bl,%cl
  800940:	74 0a                	je     80094c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800942:	0f b6 c1             	movzbl %cl,%eax
  800945:	0f b6 db             	movzbl %bl,%ebx
  800948:	29 d8                	sub    %ebx,%eax
  80094a:	eb 0f                	jmp    80095b <memcmp+0x35>
		s1++, s2++;
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800952:	39 f0                	cmp    %esi,%eax
  800954:	75 e2                	jne    800938 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	53                   	push   %ebx
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800966:	89 c1                	mov    %eax,%ecx
  800968:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096f:	eb 0a                	jmp    80097b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800971:	0f b6 10             	movzbl (%eax),%edx
  800974:	39 da                	cmp    %ebx,%edx
  800976:	74 07                	je     80097f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	39 c8                	cmp    %ecx,%eax
  80097d:	72 f2                	jb     800971 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097f:	5b                   	pop    %ebx
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	57                   	push   %edi
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098e:	eb 03                	jmp    800993 <strtol+0x11>
		s++;
  800990:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800993:	0f b6 01             	movzbl (%ecx),%eax
  800996:	3c 20                	cmp    $0x20,%al
  800998:	74 f6                	je     800990 <strtol+0xe>
  80099a:	3c 09                	cmp    $0x9,%al
  80099c:	74 f2                	je     800990 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099e:	3c 2b                	cmp    $0x2b,%al
  8009a0:	75 0a                	jne    8009ac <strtol+0x2a>
		s++;
  8009a2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009aa:	eb 11                	jmp    8009bd <strtol+0x3b>
  8009ac:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b1:	3c 2d                	cmp    $0x2d,%al
  8009b3:	75 08                	jne    8009bd <strtol+0x3b>
		s++, neg = 1;
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c3:	75 15                	jne    8009da <strtol+0x58>
  8009c5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c8:	75 10                	jne    8009da <strtol+0x58>
  8009ca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ce:	75 7c                	jne    800a4c <strtol+0xca>
		s += 2, base = 16;
  8009d0:	83 c1 02             	add    $0x2,%ecx
  8009d3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d8:	eb 16                	jmp    8009f0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009da:	85 db                	test   %ebx,%ebx
  8009dc:	75 12                	jne    8009f0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009de:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e6:	75 08                	jne    8009f0 <strtol+0x6e>
		s++, base = 8;
  8009e8:	83 c1 01             	add    $0x1,%ecx
  8009eb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f8:	0f b6 11             	movzbl (%ecx),%edx
  8009fb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fe:	89 f3                	mov    %esi,%ebx
  800a00:	80 fb 09             	cmp    $0x9,%bl
  800a03:	77 08                	ja     800a0d <strtol+0x8b>
			dig = *s - '0';
  800a05:	0f be d2             	movsbl %dl,%edx
  800a08:	83 ea 30             	sub    $0x30,%edx
  800a0b:	eb 22                	jmp    800a2f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a10:	89 f3                	mov    %esi,%ebx
  800a12:	80 fb 19             	cmp    $0x19,%bl
  800a15:	77 08                	ja     800a1f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a17:	0f be d2             	movsbl %dl,%edx
  800a1a:	83 ea 57             	sub    $0x57,%edx
  800a1d:	eb 10                	jmp    800a2f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a1f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a22:	89 f3                	mov    %esi,%ebx
  800a24:	80 fb 19             	cmp    $0x19,%bl
  800a27:	77 16                	ja     800a3f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a29:	0f be d2             	movsbl %dl,%edx
  800a2c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a32:	7d 0b                	jge    800a3f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a34:	83 c1 01             	add    $0x1,%ecx
  800a37:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3d:	eb b9                	jmp    8009f8 <strtol+0x76>

	if (endptr)
  800a3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a43:	74 0d                	je     800a52 <strtol+0xd0>
		*endptr = (char *) s;
  800a45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a48:	89 0e                	mov    %ecx,(%esi)
  800a4a:	eb 06                	jmp    800a52 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4c:	85 db                	test   %ebx,%ebx
  800a4e:	74 98                	je     8009e8 <strtol+0x66>
  800a50:	eb 9e                	jmp    8009f0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a52:	89 c2                	mov    %eax,%edx
  800a54:	f7 da                	neg    %edx
  800a56:	85 ff                	test   %edi,%edi
  800a58:	0f 45 c2             	cmovne %edx,%eax
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	89 c3                	mov    %eax,%ebx
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	89 c6                	mov    %eax,%esi
  800a77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8e:	89 d1                	mov    %edx,%ecx
  800a90:	89 d3                	mov    %edx,%ebx
  800a92:	89 d7                	mov    %edx,%edi
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aab:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab3:	89 cb                	mov    %ecx,%ebx
  800ab5:	89 cf                	mov    %ecx,%edi
  800ab7:	89 ce                	mov    %ecx,%esi
  800ab9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800abb:	85 c0                	test   %eax,%eax
  800abd:	7e 17                	jle    800ad6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	50                   	push   %eax
  800ac3:	6a 03                	push   $0x3
  800ac5:	68 7f 21 80 00       	push   $0x80217f
  800aca:	6a 23                	push   $0x23
  800acc:	68 9c 21 80 00       	push   $0x80219c
  800ad1:	e8 56 10 00 00       	call   801b2c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 02 00 00 00       	mov    $0x2,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_yield>:

void
sys_yield(void)
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
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0d:	89 d1                	mov    %edx,%ecx
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	89 d7                	mov    %edx,%edi
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	be 00 00 00 00       	mov    $0x0,%esi
  800b2a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b38:	89 f7                	mov    %esi,%edi
  800b3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	7e 17                	jle    800b57 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	50                   	push   %eax
  800b44:	6a 04                	push   $0x4
  800b46:	68 7f 21 80 00       	push   $0x80217f
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 9c 21 80 00       	push   $0x80219c
  800b52:	e8 d5 0f 00 00       	call   801b2c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b79:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	7e 17                	jle    800b99 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	50                   	push   %eax
  800b86:	6a 05                	push   $0x5
  800b88:	68 7f 21 80 00       	push   $0x80217f
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 9c 21 80 00       	push   $0x80219c
  800b94:	e8 93 0f 00 00       	call   801b2c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800baf:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bba:	89 df                	mov    %ebx,%edi
  800bbc:	89 de                	mov    %ebx,%esi
  800bbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 17                	jle    800bdb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	50                   	push   %eax
  800bc8:	6a 06                	push   $0x6
  800bca:	68 7f 21 80 00       	push   $0x80217f
  800bcf:	6a 23                	push   $0x23
  800bd1:	68 9c 21 80 00       	push   $0x80219c
  800bd6:	e8 51 0f 00 00       	call   801b2c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf1:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	89 df                	mov    %ebx,%edi
  800bfe:	89 de                	mov    %ebx,%esi
  800c00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c02:	85 c0                	test   %eax,%eax
  800c04:	7e 17                	jle    800c1d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	50                   	push   %eax
  800c0a:	6a 08                	push   $0x8
  800c0c:	68 7f 21 80 00       	push   $0x80217f
  800c11:	6a 23                	push   $0x23
  800c13:	68 9c 21 80 00       	push   $0x80219c
  800c18:	e8 0f 0f 00 00       	call   801b2c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c33:	b8 09 00 00 00       	mov    $0x9,%eax
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	89 df                	mov    %ebx,%edi
  800c40:	89 de                	mov    %ebx,%esi
  800c42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 09                	push   $0x9
  800c4e:	68 7f 21 80 00       	push   $0x80217f
  800c53:	6a 23                	push   $0x23
  800c55:	68 9c 21 80 00       	push   $0x80219c
  800c5a:	e8 cd 0e 00 00       	call   801b2c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c75:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	89 df                	mov    %ebx,%edi
  800c82:	89 de                	mov    %ebx,%esi
  800c84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7e 17                	jle    800ca1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8a:	83 ec 0c             	sub    $0xc,%esp
  800c8d:	50                   	push   %eax
  800c8e:	6a 0a                	push   $0xa
  800c90:	68 7f 21 80 00       	push   $0x80217f
  800c95:	6a 23                	push   $0x23
  800c97:	68 9c 21 80 00       	push   $0x80219c
  800c9c:	e8 8b 0e 00 00       	call   801b2c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	be 00 00 00 00       	mov    $0x0,%esi
  800cb4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cda:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 cb                	mov    %ecx,%ebx
  800ce4:	89 cf                	mov    %ecx,%edi
  800ce6:	89 ce                	mov    %ecx,%esi
  800ce8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 0d                	push   $0xd
  800cf4:	68 7f 21 80 00       	push   $0x80217f
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 9c 21 80 00       	push   $0x80219c
  800d00:	e8 27 0e 00 00       	call   801b2c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	8b 75 08             	mov    0x8(%ebp),%esi
  800d15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  800d1b:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  800d1d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  800d22:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  800d25:	83 ec 0c             	sub    $0xc,%esp
  800d28:	50                   	push   %eax
  800d29:	e8 9e ff ff ff       	call   800ccc <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  800d2e:	83 c4 10             	add    $0x10,%esp
  800d31:	85 c0                	test   %eax,%eax
  800d33:	78 0e                	js     800d43 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  800d35:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d3b:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  800d3e:	8b 52 78             	mov    0x78(%edx),%edx
  800d41:	eb 0a                	jmp    800d4d <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  800d43:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  800d48:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  800d4d:	85 f6                	test   %esi,%esi
  800d4f:	74 02                	je     800d53 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  800d51:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  800d53:	85 db                	test   %ebx,%ebx
  800d55:	74 02                	je     800d59 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  800d57:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	78 08                	js     800d65 <ipc_recv+0x58>
  800d5d:	a1 04 40 80 00       	mov    0x804004,%eax
  800d62:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  800d65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  800d7e:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  800d80:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  800d85:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  800d88:	ff 75 14             	pushl  0x14(%ebp)
  800d8b:	53                   	push   %ebx
  800d8c:	56                   	push   %esi
  800d8d:	57                   	push   %edi
  800d8e:	e8 16 ff ff ff       	call   800ca9 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  800d93:	83 c4 10             	add    $0x10,%esp
  800d96:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800d99:	75 07                	jne    800da2 <ipc_send+0x36>
				    sys_yield();
  800d9b:	e8 5d fd ff ff       	call   800afd <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  800da0:	eb e6                	jmp    800d88 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  800da2:	85 c0                	test   %eax,%eax
  800da4:	74 12                	je     800db8 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  800da6:	50                   	push   %eax
  800da7:	68 aa 21 80 00       	push   $0x8021aa
  800dac:	6a 4b                	push   $0x4b
  800dae:	68 be 21 80 00       	push   $0x8021be
  800db3:	e8 74 0d 00 00       	call   801b2c <_panic>
			 }
	   }
}
  800db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  800dc6:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  800dcb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800dce:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800dd4:	8b 52 50             	mov    0x50(%edx),%edx
  800dd7:	39 ca                	cmp    %ecx,%edx
  800dd9:	75 0d                	jne    800de8 <ipc_find_env+0x28>
				    return envs[i].env_id;
  800ddb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800dde:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800de3:	8b 40 48             	mov    0x48(%eax),%eax
  800de6:	eb 0f                	jmp    800df7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  800de8:	83 c0 01             	add    $0x1,%eax
  800deb:	3d 00 04 00 00       	cmp    $0x400,%eax
  800df0:	75 d9                	jne    800dcb <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  800df2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dff:	05 00 00 00 30       	add    $0x30000000,%eax
  800e04:	c1 e8 0c             	shr    $0xc,%eax
}
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0f:	05 00 00 00 30       	add    $0x30000000,%eax
  800e14:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e19:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e26:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e2b:	89 c2                	mov    %eax,%edx
  800e2d:	c1 ea 16             	shr    $0x16,%edx
  800e30:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e37:	f6 c2 01             	test   $0x1,%dl
  800e3a:	74 11                	je     800e4d <fd_alloc+0x2d>
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	c1 ea 0c             	shr    $0xc,%edx
  800e41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e48:	f6 c2 01             	test   $0x1,%dl
  800e4b:	75 09                	jne    800e56 <fd_alloc+0x36>
			*fd_store = fd;
  800e4d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e54:	eb 17                	jmp    800e6d <fd_alloc+0x4d>
  800e56:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e5b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e60:	75 c9                	jne    800e2b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e62:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e68:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e75:	83 f8 1f             	cmp    $0x1f,%eax
  800e78:	77 36                	ja     800eb0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e7a:	c1 e0 0c             	shl    $0xc,%eax
  800e7d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e82:	89 c2                	mov    %eax,%edx
  800e84:	c1 ea 16             	shr    $0x16,%edx
  800e87:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e8e:	f6 c2 01             	test   $0x1,%dl
  800e91:	74 24                	je     800eb7 <fd_lookup+0x48>
  800e93:	89 c2                	mov    %eax,%edx
  800e95:	c1 ea 0c             	shr    $0xc,%edx
  800e98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e9f:	f6 c2 01             	test   $0x1,%dl
  800ea2:	74 1a                	je     800ebe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ea4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea7:	89 02                	mov    %eax,(%edx)
	return 0;
  800ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eae:	eb 13                	jmp    800ec3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb5:	eb 0c                	jmp    800ec3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebc:	eb 05                	jmp    800ec3 <fd_lookup+0x54>
  800ebe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	83 ec 08             	sub    $0x8,%esp
  800ecb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ece:	ba 44 22 80 00       	mov    $0x802244,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ed3:	eb 13                	jmp    800ee8 <dev_lookup+0x23>
  800ed5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ed8:	39 08                	cmp    %ecx,(%eax)
  800eda:	75 0c                	jne    800ee8 <dev_lookup+0x23>
			*dev = devtab[i];
  800edc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edf:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	eb 2e                	jmp    800f16 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ee8:	8b 02                	mov    (%edx),%eax
  800eea:	85 c0                	test   %eax,%eax
  800eec:	75 e7                	jne    800ed5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eee:	a1 04 40 80 00       	mov    0x804004,%eax
  800ef3:	8b 40 48             	mov    0x48(%eax),%eax
  800ef6:	83 ec 04             	sub    $0x4,%esp
  800ef9:	51                   	push   %ecx
  800efa:	50                   	push   %eax
  800efb:	68 c8 21 80 00       	push   $0x8021c8
  800f00:	e8 8f f2 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800f05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f0e:	83 c4 10             	add    $0x10,%esp
  800f11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f16:	c9                   	leave  
  800f17:	c3                   	ret    

00800f18 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	83 ec 10             	sub    $0x10,%esp
  800f20:	8b 75 08             	mov    0x8(%ebp),%esi
  800f23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f29:	50                   	push   %eax
  800f2a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f30:	c1 e8 0c             	shr    $0xc,%eax
  800f33:	50                   	push   %eax
  800f34:	e8 36 ff ff ff       	call   800e6f <fd_lookup>
  800f39:	83 c4 08             	add    $0x8,%esp
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	78 05                	js     800f45 <fd_close+0x2d>
	    || fd != fd2)
  800f40:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f43:	74 0c                	je     800f51 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f45:	84 db                	test   %bl,%bl
  800f47:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4c:	0f 44 c2             	cmove  %edx,%eax
  800f4f:	eb 41                	jmp    800f92 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f51:	83 ec 08             	sub    $0x8,%esp
  800f54:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f57:	50                   	push   %eax
  800f58:	ff 36                	pushl  (%esi)
  800f5a:	e8 66 ff ff ff       	call   800ec5 <dev_lookup>
  800f5f:	89 c3                	mov    %eax,%ebx
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	78 1a                	js     800f82 <fd_close+0x6a>
		if (dev->dev_close)
  800f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f6b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f6e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f73:	85 c0                	test   %eax,%eax
  800f75:	74 0b                	je     800f82 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f77:	83 ec 0c             	sub    $0xc,%esp
  800f7a:	56                   	push   %esi
  800f7b:	ff d0                	call   *%eax
  800f7d:	89 c3                	mov    %eax,%ebx
  800f7f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f82:	83 ec 08             	sub    $0x8,%esp
  800f85:	56                   	push   %esi
  800f86:	6a 00                	push   $0x0
  800f88:	e8 14 fc ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	89 d8                	mov    %ebx,%eax
}
  800f92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa2:	50                   	push   %eax
  800fa3:	ff 75 08             	pushl  0x8(%ebp)
  800fa6:	e8 c4 fe ff ff       	call   800e6f <fd_lookup>
  800fab:	83 c4 08             	add    $0x8,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	78 10                	js     800fc2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fb2:	83 ec 08             	sub    $0x8,%esp
  800fb5:	6a 01                	push   $0x1
  800fb7:	ff 75 f4             	pushl  -0xc(%ebp)
  800fba:	e8 59 ff ff ff       	call   800f18 <fd_close>
  800fbf:	83 c4 10             	add    $0x10,%esp
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <close_all>:

void
close_all(void)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fcb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fd0:	83 ec 0c             	sub    $0xc,%esp
  800fd3:	53                   	push   %ebx
  800fd4:	e8 c0 ff ff ff       	call   800f99 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd9:	83 c3 01             	add    $0x1,%ebx
  800fdc:	83 c4 10             	add    $0x10,%esp
  800fdf:	83 fb 20             	cmp    $0x20,%ebx
  800fe2:	75 ec                	jne    800fd0 <close_all+0xc>
		close(i);
}
  800fe4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
  800fef:	83 ec 2c             	sub    $0x2c,%esp
  800ff2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ff5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff8:	50                   	push   %eax
  800ff9:	ff 75 08             	pushl  0x8(%ebp)
  800ffc:	e8 6e fe ff ff       	call   800e6f <fd_lookup>
  801001:	83 c4 08             	add    $0x8,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	0f 88 c1 00 00 00    	js     8010cd <dup+0xe4>
		return r;
	close(newfdnum);
  80100c:	83 ec 0c             	sub    $0xc,%esp
  80100f:	56                   	push   %esi
  801010:	e8 84 ff ff ff       	call   800f99 <close>

	newfd = INDEX2FD(newfdnum);
  801015:	89 f3                	mov    %esi,%ebx
  801017:	c1 e3 0c             	shl    $0xc,%ebx
  80101a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801020:	83 c4 04             	add    $0x4,%esp
  801023:	ff 75 e4             	pushl  -0x1c(%ebp)
  801026:	e8 de fd ff ff       	call   800e09 <fd2data>
  80102b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80102d:	89 1c 24             	mov    %ebx,(%esp)
  801030:	e8 d4 fd ff ff       	call   800e09 <fd2data>
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80103b:	89 f8                	mov    %edi,%eax
  80103d:	c1 e8 16             	shr    $0x16,%eax
  801040:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801047:	a8 01                	test   $0x1,%al
  801049:	74 37                	je     801082 <dup+0x99>
  80104b:	89 f8                	mov    %edi,%eax
  80104d:	c1 e8 0c             	shr    $0xc,%eax
  801050:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801057:	f6 c2 01             	test   $0x1,%dl
  80105a:	74 26                	je     801082 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80105c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	25 07 0e 00 00       	and    $0xe07,%eax
  80106b:	50                   	push   %eax
  80106c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80106f:	6a 00                	push   $0x0
  801071:	57                   	push   %edi
  801072:	6a 00                	push   $0x0
  801074:	e8 e6 fa ff ff       	call   800b5f <sys_page_map>
  801079:	89 c7                	mov    %eax,%edi
  80107b:	83 c4 20             	add    $0x20,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	78 2e                	js     8010b0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801082:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801085:	89 d0                	mov    %edx,%eax
  801087:	c1 e8 0c             	shr    $0xc,%eax
  80108a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	25 07 0e 00 00       	and    $0xe07,%eax
  801099:	50                   	push   %eax
  80109a:	53                   	push   %ebx
  80109b:	6a 00                	push   $0x0
  80109d:	52                   	push   %edx
  80109e:	6a 00                	push   $0x0
  8010a0:	e8 ba fa ff ff       	call   800b5f <sys_page_map>
  8010a5:	89 c7                	mov    %eax,%edi
  8010a7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010aa:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ac:	85 ff                	test   %edi,%edi
  8010ae:	79 1d                	jns    8010cd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010b0:	83 ec 08             	sub    $0x8,%esp
  8010b3:	53                   	push   %ebx
  8010b4:	6a 00                	push   $0x0
  8010b6:	e8 e6 fa ff ff       	call   800ba1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010bb:	83 c4 08             	add    $0x8,%esp
  8010be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c1:	6a 00                	push   $0x0
  8010c3:	e8 d9 fa ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	89 f8                	mov    %edi,%eax
}
  8010cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	53                   	push   %ebx
  8010d9:	83 ec 14             	sub    $0x14,%esp
  8010dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e2:	50                   	push   %eax
  8010e3:	53                   	push   %ebx
  8010e4:	e8 86 fd ff ff       	call   800e6f <fd_lookup>
  8010e9:	83 c4 08             	add    $0x8,%esp
  8010ec:	89 c2                	mov    %eax,%edx
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	78 6d                	js     80115f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f2:	83 ec 08             	sub    $0x8,%esp
  8010f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f8:	50                   	push   %eax
  8010f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010fc:	ff 30                	pushl  (%eax)
  8010fe:	e8 c2 fd ff ff       	call   800ec5 <dev_lookup>
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	85 c0                	test   %eax,%eax
  801108:	78 4c                	js     801156 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80110a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80110d:	8b 42 08             	mov    0x8(%edx),%eax
  801110:	83 e0 03             	and    $0x3,%eax
  801113:	83 f8 01             	cmp    $0x1,%eax
  801116:	75 21                	jne    801139 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801118:	a1 04 40 80 00       	mov    0x804004,%eax
  80111d:	8b 40 48             	mov    0x48(%eax),%eax
  801120:	83 ec 04             	sub    $0x4,%esp
  801123:	53                   	push   %ebx
  801124:	50                   	push   %eax
  801125:	68 09 22 80 00       	push   $0x802209
  80112a:	e8 65 f0 ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801137:	eb 26                	jmp    80115f <read+0x8a>
	}
	if (!dev->dev_read)
  801139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113c:	8b 40 08             	mov    0x8(%eax),%eax
  80113f:	85 c0                	test   %eax,%eax
  801141:	74 17                	je     80115a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801143:	83 ec 04             	sub    $0x4,%esp
  801146:	ff 75 10             	pushl  0x10(%ebp)
  801149:	ff 75 0c             	pushl  0xc(%ebp)
  80114c:	52                   	push   %edx
  80114d:	ff d0                	call   *%eax
  80114f:	89 c2                	mov    %eax,%edx
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	eb 09                	jmp    80115f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801156:	89 c2                	mov    %eax,%edx
  801158:	eb 05                	jmp    80115f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80115a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80115f:	89 d0                	mov    %edx,%eax
  801161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	57                   	push   %edi
  80116a:	56                   	push   %esi
  80116b:	53                   	push   %ebx
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801172:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801175:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117a:	eb 21                	jmp    80119d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	89 f0                	mov    %esi,%eax
  801181:	29 d8                	sub    %ebx,%eax
  801183:	50                   	push   %eax
  801184:	89 d8                	mov    %ebx,%eax
  801186:	03 45 0c             	add    0xc(%ebp),%eax
  801189:	50                   	push   %eax
  80118a:	57                   	push   %edi
  80118b:	e8 45 ff ff ff       	call   8010d5 <read>
		if (m < 0)
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	85 c0                	test   %eax,%eax
  801195:	78 10                	js     8011a7 <readn+0x41>
			return m;
		if (m == 0)
  801197:	85 c0                	test   %eax,%eax
  801199:	74 0a                	je     8011a5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80119b:	01 c3                	add    %eax,%ebx
  80119d:	39 f3                	cmp    %esi,%ebx
  80119f:	72 db                	jb     80117c <readn+0x16>
  8011a1:	89 d8                	mov    %ebx,%eax
  8011a3:	eb 02                	jmp    8011a7 <readn+0x41>
  8011a5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011aa:	5b                   	pop    %ebx
  8011ab:	5e                   	pop    %esi
  8011ac:	5f                   	pop    %edi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	53                   	push   %ebx
  8011b3:	83 ec 14             	sub    $0x14,%esp
  8011b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011bc:	50                   	push   %eax
  8011bd:	53                   	push   %ebx
  8011be:	e8 ac fc ff ff       	call   800e6f <fd_lookup>
  8011c3:	83 c4 08             	add    $0x8,%esp
  8011c6:	89 c2                	mov    %eax,%edx
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	78 68                	js     801234 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011cc:	83 ec 08             	sub    $0x8,%esp
  8011cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d2:	50                   	push   %eax
  8011d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d6:	ff 30                	pushl  (%eax)
  8011d8:	e8 e8 fc ff ff       	call   800ec5 <dev_lookup>
  8011dd:	83 c4 10             	add    $0x10,%esp
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	78 47                	js     80122b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011eb:	75 21                	jne    80120e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f2:	8b 40 48             	mov    0x48(%eax),%eax
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	53                   	push   %ebx
  8011f9:	50                   	push   %eax
  8011fa:	68 25 22 80 00       	push   $0x802225
  8011ff:	e8 90 ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80120c:	eb 26                	jmp    801234 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80120e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801211:	8b 52 0c             	mov    0xc(%edx),%edx
  801214:	85 d2                	test   %edx,%edx
  801216:	74 17                	je     80122f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801218:	83 ec 04             	sub    $0x4,%esp
  80121b:	ff 75 10             	pushl  0x10(%ebp)
  80121e:	ff 75 0c             	pushl  0xc(%ebp)
  801221:	50                   	push   %eax
  801222:	ff d2                	call   *%edx
  801224:	89 c2                	mov    %eax,%edx
  801226:	83 c4 10             	add    $0x10,%esp
  801229:	eb 09                	jmp    801234 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122b:	89 c2                	mov    %eax,%edx
  80122d:	eb 05                	jmp    801234 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80122f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801234:	89 d0                	mov    %edx,%eax
  801236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <seek>:

int
seek(int fdnum, off_t offset)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801241:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	ff 75 08             	pushl  0x8(%ebp)
  801248:	e8 22 fc ff ff       	call   800e6f <fd_lookup>
  80124d:	83 c4 08             	add    $0x8,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	78 0e                	js     801262 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801254:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80125d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801262:	c9                   	leave  
  801263:	c3                   	ret    

00801264 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	53                   	push   %ebx
  801268:	83 ec 14             	sub    $0x14,%esp
  80126b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	53                   	push   %ebx
  801273:	e8 f7 fb ff ff       	call   800e6f <fd_lookup>
  801278:	83 c4 08             	add    $0x8,%esp
  80127b:	89 c2                	mov    %eax,%edx
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 65                	js     8012e6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801287:	50                   	push   %eax
  801288:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128b:	ff 30                	pushl  (%eax)
  80128d:	e8 33 fc ff ff       	call   800ec5 <dev_lookup>
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	85 c0                	test   %eax,%eax
  801297:	78 44                	js     8012dd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801299:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a0:	75 21                	jne    8012c3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012a2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012a7:	8b 40 48             	mov    0x48(%eax),%eax
  8012aa:	83 ec 04             	sub    $0x4,%esp
  8012ad:	53                   	push   %ebx
  8012ae:	50                   	push   %eax
  8012af:	68 e8 21 80 00       	push   $0x8021e8
  8012b4:	e8 db ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c1:	eb 23                	jmp    8012e6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c6:	8b 52 18             	mov    0x18(%edx),%edx
  8012c9:	85 d2                	test   %edx,%edx
  8012cb:	74 14                	je     8012e1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012cd:	83 ec 08             	sub    $0x8,%esp
  8012d0:	ff 75 0c             	pushl  0xc(%ebp)
  8012d3:	50                   	push   %eax
  8012d4:	ff d2                	call   *%edx
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	eb 09                	jmp    8012e6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012dd:	89 c2                	mov    %eax,%edx
  8012df:	eb 05                	jmp    8012e6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012e6:	89 d0                	mov    %edx,%eax
  8012e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012eb:	c9                   	leave  
  8012ec:	c3                   	ret    

008012ed <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	53                   	push   %ebx
  8012f1:	83 ec 14             	sub    $0x14,%esp
  8012f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fa:	50                   	push   %eax
  8012fb:	ff 75 08             	pushl  0x8(%ebp)
  8012fe:	e8 6c fb ff ff       	call   800e6f <fd_lookup>
  801303:	83 c4 08             	add    $0x8,%esp
  801306:	89 c2                	mov    %eax,%edx
  801308:	85 c0                	test   %eax,%eax
  80130a:	78 58                	js     801364 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801312:	50                   	push   %eax
  801313:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801316:	ff 30                	pushl  (%eax)
  801318:	e8 a8 fb ff ff       	call   800ec5 <dev_lookup>
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 37                	js     80135b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801324:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801327:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80132b:	74 32                	je     80135f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80132d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801330:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801337:	00 00 00 
	stat->st_isdir = 0;
  80133a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801341:	00 00 00 
	stat->st_dev = dev;
  801344:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	53                   	push   %ebx
  80134e:	ff 75 f0             	pushl  -0x10(%ebp)
  801351:	ff 50 14             	call   *0x14(%eax)
  801354:	89 c2                	mov    %eax,%edx
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	eb 09                	jmp    801364 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135b:	89 c2                	mov    %eax,%edx
  80135d:	eb 05                	jmp    801364 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80135f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801364:	89 d0                	mov    %edx,%eax
  801366:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	56                   	push   %esi
  80136f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	6a 00                	push   $0x0
  801375:	ff 75 08             	pushl  0x8(%ebp)
  801378:	e8 2c 02 00 00       	call   8015a9 <open>
  80137d:	89 c3                	mov    %eax,%ebx
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	78 1b                	js     8013a1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	ff 75 0c             	pushl  0xc(%ebp)
  80138c:	50                   	push   %eax
  80138d:	e8 5b ff ff ff       	call   8012ed <fstat>
  801392:	89 c6                	mov    %eax,%esi
	close(fd);
  801394:	89 1c 24             	mov    %ebx,(%esp)
  801397:	e8 fd fb ff ff       	call   800f99 <close>
	return r;
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	89 f0                	mov    %esi,%eax
}
  8013a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a4:	5b                   	pop    %ebx
  8013a5:	5e                   	pop    %esi
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	56                   	push   %esi
  8013ac:	53                   	push   %ebx
  8013ad:	89 c6                	mov    %eax,%esi
  8013af:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  8013b1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013b8:	75 12                	jne    8013cc <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ba:	83 ec 0c             	sub    $0xc,%esp
  8013bd:	6a 01                	push   $0x1
  8013bf:	e8 fc f9 ff ff       	call   800dc0 <ipc_find_env>
  8013c4:	a3 00 40 80 00       	mov    %eax,0x804000
  8013c9:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013cc:	6a 07                	push   $0x7
  8013ce:	68 00 50 80 00       	push   $0x805000
  8013d3:	56                   	push   %esi
  8013d4:	ff 35 00 40 80 00    	pushl  0x804000
  8013da:	e8 8d f9 ff ff       	call   800d6c <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  8013df:	83 c4 0c             	add    $0xc,%esp
  8013e2:	6a 00                	push   $0x0
  8013e4:	53                   	push   %ebx
  8013e5:	6a 00                	push   $0x0
  8013e7:	e8 21 f9 ff ff       	call   800d0d <ipc_recv>
}
  8013ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ef:	5b                   	pop    %ebx
  8013f0:	5e                   	pop    %esi
  8013f1:	5d                   	pop    %ebp
  8013f2:	c3                   	ret    

008013f3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ff:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  801404:	8b 45 0c             	mov    0xc(%ebp),%eax
  801407:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80140c:	ba 00 00 00 00       	mov    $0x0,%edx
  801411:	b8 02 00 00 00       	mov    $0x2,%eax
  801416:	e8 8d ff ff ff       	call   8013a8 <fsipc>
}
  80141b:	c9                   	leave  
  80141c:	c3                   	ret    

0080141d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801423:	8b 45 08             	mov    0x8(%ebp),%eax
  801426:	8b 40 0c             	mov    0xc(%eax),%eax
  801429:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  80142e:	ba 00 00 00 00       	mov    $0x0,%edx
  801433:	b8 06 00 00 00       	mov    $0x6,%eax
  801438:	e8 6b ff ff ff       	call   8013a8 <fsipc>
}
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	53                   	push   %ebx
  801443:	83 ec 04             	sub    $0x4,%esp
  801446:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801449:	8b 45 08             	mov    0x8(%ebp),%eax
  80144c:	8b 40 0c             	mov    0xc(%eax),%eax
  80144f:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801454:	ba 00 00 00 00       	mov    $0x0,%edx
  801459:	b8 05 00 00 00       	mov    $0x5,%eax
  80145e:	e8 45 ff ff ff       	call   8013a8 <fsipc>
  801463:	85 c0                	test   %eax,%eax
  801465:	78 2c                	js     801493 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	68 00 50 80 00       	push   $0x805000
  80146f:	53                   	push   %ebx
  801470:	e8 a4 f2 ff ff       	call   800719 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  801475:	a1 80 50 80 00       	mov    0x805080,%eax
  80147a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801480:	a1 84 50 80 00       	mov    0x805084,%eax
  801485:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801493:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801496:	c9                   	leave  
  801497:	c3                   	ret    

00801498 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	53                   	push   %ebx
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a8:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  8014ad:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  8014b3:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8014b9:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8014be:	0f 46 c3             	cmovbe %ebx,%eax
  8014c1:	50                   	push   %eax
  8014c2:	ff 75 0c             	pushl  0xc(%ebp)
  8014c5:	68 08 50 80 00       	push   $0x805008
  8014ca:	e8 dc f3 ff ff       	call   8008ab <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  8014cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d4:	b8 04 00 00 00       	mov    $0x4,%eax
  8014d9:	e8 ca fe ff ff       	call   8013a8 <fsipc>
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 3d                	js     801522 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  8014e5:	39 c3                	cmp    %eax,%ebx
  8014e7:	73 19                	jae    801502 <devfile_write+0x6a>
  8014e9:	68 54 22 80 00       	push   $0x802254
  8014ee:	68 5b 22 80 00       	push   $0x80225b
  8014f3:	68 9a 00 00 00       	push   $0x9a
  8014f8:	68 70 22 80 00       	push   $0x802270
  8014fd:	e8 2a 06 00 00       	call   801b2c <_panic>
	   assert (r <= bytes_written);
  801502:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801507:	7e 19                	jle    801522 <devfile_write+0x8a>
  801509:	68 7b 22 80 00       	push   $0x80227b
  80150e:	68 5b 22 80 00       	push   $0x80225b
  801513:	68 9b 00 00 00       	push   $0x9b
  801518:	68 70 22 80 00       	push   $0x802270
  80151d:	e8 0a 06 00 00       	call   801b2c <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	56                   	push   %esi
  80152b:	53                   	push   %ebx
  80152c:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  80152f:	8b 45 08             	mov    0x8(%ebp),%eax
  801532:	8b 40 0c             	mov    0xc(%eax),%eax
  801535:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  80153a:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801540:	ba 00 00 00 00       	mov    $0x0,%edx
  801545:	b8 03 00 00 00       	mov    $0x3,%eax
  80154a:	e8 59 fe ff ff       	call   8013a8 <fsipc>
  80154f:	89 c3                	mov    %eax,%ebx
  801551:	85 c0                	test   %eax,%eax
  801553:	78 4b                	js     8015a0 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  801555:	39 c6                	cmp    %eax,%esi
  801557:	73 16                	jae    80156f <devfile_read+0x48>
  801559:	68 54 22 80 00       	push   $0x802254
  80155e:	68 5b 22 80 00       	push   $0x80225b
  801563:	6a 7c                	push   $0x7c
  801565:	68 70 22 80 00       	push   $0x802270
  80156a:	e8 bd 05 00 00       	call   801b2c <_panic>
	   assert(r <= PGSIZE);
  80156f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801574:	7e 16                	jle    80158c <devfile_read+0x65>
  801576:	68 8e 22 80 00       	push   $0x80228e
  80157b:	68 5b 22 80 00       	push   $0x80225b
  801580:	6a 7d                	push   $0x7d
  801582:	68 70 22 80 00       	push   $0x802270
  801587:	e8 a0 05 00 00       	call   801b2c <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80158c:	83 ec 04             	sub    $0x4,%esp
  80158f:	50                   	push   %eax
  801590:	68 00 50 80 00       	push   $0x805000
  801595:	ff 75 0c             	pushl  0xc(%ebp)
  801598:	e8 0e f3 ff ff       	call   8008ab <memmove>
	   return r;
  80159d:	83 c4 10             	add    $0x10,%esp
}
  8015a0:	89 d8                	mov    %ebx,%eax
  8015a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a5:	5b                   	pop    %ebx
  8015a6:	5e                   	pop    %esi
  8015a7:	5d                   	pop    %ebp
  8015a8:	c3                   	ret    

008015a9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 20             	sub    $0x20,%esp
  8015b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  8015b3:	53                   	push   %ebx
  8015b4:	e8 27 f1 ff ff       	call   8006e0 <strlen>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015c1:	7f 67                	jg     80162a <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8015c3:	83 ec 0c             	sub    $0xc,%esp
  8015c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	e8 51 f8 ff ff       	call   800e20 <fd_alloc>
  8015cf:	83 c4 10             	add    $0x10,%esp
			 return r;
  8015d2:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 57                	js     80162f <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  8015d8:	83 ec 08             	sub    $0x8,%esp
  8015db:	53                   	push   %ebx
  8015dc:	68 00 50 80 00       	push   $0x805000
  8015e1:	e8 33 f1 ff ff       	call   800719 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  8015e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e9:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f6:	e8 ad fd ff ff       	call   8013a8 <fsipc>
  8015fb:	89 c3                	mov    %eax,%ebx
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	85 c0                	test   %eax,%eax
  801602:	79 14                	jns    801618 <open+0x6f>
			 fd_close(fd, 0);
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	6a 00                	push   $0x0
  801609:	ff 75 f4             	pushl  -0xc(%ebp)
  80160c:	e8 07 f9 ff ff       	call   800f18 <fd_close>
			 return r;
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	89 da                	mov    %ebx,%edx
  801616:	eb 17                	jmp    80162f <open+0x86>
	   }

	   return fd2num(fd);
  801618:	83 ec 0c             	sub    $0xc,%esp
  80161b:	ff 75 f4             	pushl  -0xc(%ebp)
  80161e:	e8 d6 f7 ff ff       	call   800df9 <fd2num>
  801623:	89 c2                	mov    %eax,%edx
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	eb 05                	jmp    80162f <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  80162a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  80162f:	89 d0                	mov    %edx,%eax
  801631:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801634:	c9                   	leave  
  801635:	c3                   	ret    

00801636 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  80163c:	ba 00 00 00 00       	mov    $0x0,%edx
  801641:	b8 08 00 00 00       	mov    $0x8,%eax
  801646:	e8 5d fd ff ff       	call   8013a8 <fsipc>
}
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    

0080164d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	56                   	push   %esi
  801651:	53                   	push   %ebx
  801652:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801655:	83 ec 0c             	sub    $0xc,%esp
  801658:	ff 75 08             	pushl  0x8(%ebp)
  80165b:	e8 a9 f7 ff ff       	call   800e09 <fd2data>
  801660:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801662:	83 c4 08             	add    $0x8,%esp
  801665:	68 9a 22 80 00       	push   $0x80229a
  80166a:	53                   	push   %ebx
  80166b:	e8 a9 f0 ff ff       	call   800719 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801670:	8b 46 04             	mov    0x4(%esi),%eax
  801673:	2b 06                	sub    (%esi),%eax
  801675:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80167b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801682:	00 00 00 
	stat->st_dev = &devpipe;
  801685:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80168c:	30 80 00 
	return 0;
}
  80168f:	b8 00 00 00 00       	mov    $0x0,%eax
  801694:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801697:	5b                   	pop    %ebx
  801698:	5e                   	pop    %esi
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	53                   	push   %ebx
  80169f:	83 ec 0c             	sub    $0xc,%esp
  8016a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016a5:	53                   	push   %ebx
  8016a6:	6a 00                	push   $0x0
  8016a8:	e8 f4 f4 ff ff       	call   800ba1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016ad:	89 1c 24             	mov    %ebx,(%esp)
  8016b0:	e8 54 f7 ff ff       	call   800e09 <fd2data>
  8016b5:	83 c4 08             	add    $0x8,%esp
  8016b8:	50                   	push   %eax
  8016b9:	6a 00                	push   $0x0
  8016bb:	e8 e1 f4 ff ff       	call   800ba1 <sys_page_unmap>
}
  8016c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	57                   	push   %edi
  8016c9:	56                   	push   %esi
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 1c             	sub    $0x1c,%esp
  8016ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016d1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016d3:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016db:	83 ec 0c             	sub    $0xc,%esp
  8016de:	ff 75 e0             	pushl  -0x20(%ebp)
  8016e1:	e8 8c 04 00 00       	call   801b72 <pageref>
  8016e6:	89 c3                	mov    %eax,%ebx
  8016e8:	89 3c 24             	mov    %edi,(%esp)
  8016eb:	e8 82 04 00 00       	call   801b72 <pageref>
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	39 c3                	cmp    %eax,%ebx
  8016f5:	0f 94 c1             	sete   %cl
  8016f8:	0f b6 c9             	movzbl %cl,%ecx
  8016fb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016fe:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801704:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801707:	39 ce                	cmp    %ecx,%esi
  801709:	74 1b                	je     801726 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80170b:	39 c3                	cmp    %eax,%ebx
  80170d:	75 c4                	jne    8016d3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80170f:	8b 42 58             	mov    0x58(%edx),%eax
  801712:	ff 75 e4             	pushl  -0x1c(%ebp)
  801715:	50                   	push   %eax
  801716:	56                   	push   %esi
  801717:	68 a1 22 80 00       	push   $0x8022a1
  80171c:	e8 73 ea ff ff       	call   800194 <cprintf>
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	eb ad                	jmp    8016d3 <_pipeisclosed+0xe>
	}
}
  801726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801729:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172c:	5b                   	pop    %ebx
  80172d:	5e                   	pop    %esi
  80172e:	5f                   	pop    %edi
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	57                   	push   %edi
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
  801737:	83 ec 28             	sub    $0x28,%esp
  80173a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80173d:	56                   	push   %esi
  80173e:	e8 c6 f6 ff ff       	call   800e09 <fd2data>
  801743:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	bf 00 00 00 00       	mov    $0x0,%edi
  80174d:	eb 4b                	jmp    80179a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80174f:	89 da                	mov    %ebx,%edx
  801751:	89 f0                	mov    %esi,%eax
  801753:	e8 6d ff ff ff       	call   8016c5 <_pipeisclosed>
  801758:	85 c0                	test   %eax,%eax
  80175a:	75 48                	jne    8017a4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80175c:	e8 9c f3 ff ff       	call   800afd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801761:	8b 43 04             	mov    0x4(%ebx),%eax
  801764:	8b 0b                	mov    (%ebx),%ecx
  801766:	8d 51 20             	lea    0x20(%ecx),%edx
  801769:	39 d0                	cmp    %edx,%eax
  80176b:	73 e2                	jae    80174f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80176d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801770:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801774:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801777:	89 c2                	mov    %eax,%edx
  801779:	c1 fa 1f             	sar    $0x1f,%edx
  80177c:	89 d1                	mov    %edx,%ecx
  80177e:	c1 e9 1b             	shr    $0x1b,%ecx
  801781:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801784:	83 e2 1f             	and    $0x1f,%edx
  801787:	29 ca                	sub    %ecx,%edx
  801789:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80178d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801791:	83 c0 01             	add    $0x1,%eax
  801794:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801797:	83 c7 01             	add    $0x1,%edi
  80179a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80179d:	75 c2                	jne    801761 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80179f:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a2:	eb 05                	jmp    8017a9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017a4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5e                   	pop    %esi
  8017ae:	5f                   	pop    %edi
  8017af:	5d                   	pop    %ebp
  8017b0:	c3                   	ret    

008017b1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	57                   	push   %edi
  8017b5:	56                   	push   %esi
  8017b6:	53                   	push   %ebx
  8017b7:	83 ec 18             	sub    $0x18,%esp
  8017ba:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017bd:	57                   	push   %edi
  8017be:	e8 46 f6 ff ff       	call   800e09 <fd2data>
  8017c3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017cd:	eb 3d                	jmp    80180c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017cf:	85 db                	test   %ebx,%ebx
  8017d1:	74 04                	je     8017d7 <devpipe_read+0x26>
				return i;
  8017d3:	89 d8                	mov    %ebx,%eax
  8017d5:	eb 44                	jmp    80181b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017d7:	89 f2                	mov    %esi,%edx
  8017d9:	89 f8                	mov    %edi,%eax
  8017db:	e8 e5 fe ff ff       	call   8016c5 <_pipeisclosed>
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	75 32                	jne    801816 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017e4:	e8 14 f3 ff ff       	call   800afd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017e9:	8b 06                	mov    (%esi),%eax
  8017eb:	3b 46 04             	cmp    0x4(%esi),%eax
  8017ee:	74 df                	je     8017cf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017f0:	99                   	cltd   
  8017f1:	c1 ea 1b             	shr    $0x1b,%edx
  8017f4:	01 d0                	add    %edx,%eax
  8017f6:	83 e0 1f             	and    $0x1f,%eax
  8017f9:	29 d0                	sub    %edx,%eax
  8017fb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801803:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801806:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801809:	83 c3 01             	add    $0x1,%ebx
  80180c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80180f:	75 d8                	jne    8017e9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801811:	8b 45 10             	mov    0x10(%ebp),%eax
  801814:	eb 05                	jmp    80181b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801816:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80181b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181e:	5b                   	pop    %ebx
  80181f:	5e                   	pop    %esi
  801820:	5f                   	pop    %edi
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	56                   	push   %esi
  801827:	53                   	push   %ebx
  801828:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80182b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182e:	50                   	push   %eax
  80182f:	e8 ec f5 ff ff       	call   800e20 <fd_alloc>
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	89 c2                	mov    %eax,%edx
  801839:	85 c0                	test   %eax,%eax
  80183b:	0f 88 2c 01 00 00    	js     80196d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801841:	83 ec 04             	sub    $0x4,%esp
  801844:	68 07 04 00 00       	push   $0x407
  801849:	ff 75 f4             	pushl  -0xc(%ebp)
  80184c:	6a 00                	push   $0x0
  80184e:	e8 c9 f2 ff ff       	call   800b1c <sys_page_alloc>
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	89 c2                	mov    %eax,%edx
  801858:	85 c0                	test   %eax,%eax
  80185a:	0f 88 0d 01 00 00    	js     80196d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801860:	83 ec 0c             	sub    $0xc,%esp
  801863:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801866:	50                   	push   %eax
  801867:	e8 b4 f5 ff ff       	call   800e20 <fd_alloc>
  80186c:	89 c3                	mov    %eax,%ebx
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	85 c0                	test   %eax,%eax
  801873:	0f 88 e2 00 00 00    	js     80195b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801879:	83 ec 04             	sub    $0x4,%esp
  80187c:	68 07 04 00 00       	push   $0x407
  801881:	ff 75 f0             	pushl  -0x10(%ebp)
  801884:	6a 00                	push   $0x0
  801886:	e8 91 f2 ff ff       	call   800b1c <sys_page_alloc>
  80188b:	89 c3                	mov    %eax,%ebx
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	85 c0                	test   %eax,%eax
  801892:	0f 88 c3 00 00 00    	js     80195b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801898:	83 ec 0c             	sub    $0xc,%esp
  80189b:	ff 75 f4             	pushl  -0xc(%ebp)
  80189e:	e8 66 f5 ff ff       	call   800e09 <fd2data>
  8018a3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a5:	83 c4 0c             	add    $0xc,%esp
  8018a8:	68 07 04 00 00       	push   $0x407
  8018ad:	50                   	push   %eax
  8018ae:	6a 00                	push   $0x0
  8018b0:	e8 67 f2 ff ff       	call   800b1c <sys_page_alloc>
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	0f 88 89 00 00 00    	js     80194b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c2:	83 ec 0c             	sub    $0xc,%esp
  8018c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c8:	e8 3c f5 ff ff       	call   800e09 <fd2data>
  8018cd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018d4:	50                   	push   %eax
  8018d5:	6a 00                	push   $0x0
  8018d7:	56                   	push   %esi
  8018d8:	6a 00                	push   $0x0
  8018da:	e8 80 f2 ff ff       	call   800b5f <sys_page_map>
  8018df:	89 c3                	mov    %eax,%ebx
  8018e1:	83 c4 20             	add    $0x20,%esp
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	78 55                	js     80193d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018e8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018fd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801903:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801906:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801908:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	ff 75 f4             	pushl  -0xc(%ebp)
  801918:	e8 dc f4 ff ff       	call   800df9 <fd2num>
  80191d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801920:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801922:	83 c4 04             	add    $0x4,%esp
  801925:	ff 75 f0             	pushl  -0x10(%ebp)
  801928:	e8 cc f4 ff ff       	call   800df9 <fd2num>
  80192d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801930:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	ba 00 00 00 00       	mov    $0x0,%edx
  80193b:	eb 30                	jmp    80196d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80193d:	83 ec 08             	sub    $0x8,%esp
  801940:	56                   	push   %esi
  801941:	6a 00                	push   $0x0
  801943:	e8 59 f2 ff ff       	call   800ba1 <sys_page_unmap>
  801948:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80194b:	83 ec 08             	sub    $0x8,%esp
  80194e:	ff 75 f0             	pushl  -0x10(%ebp)
  801951:	6a 00                	push   $0x0
  801953:	e8 49 f2 ff ff       	call   800ba1 <sys_page_unmap>
  801958:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80195b:	83 ec 08             	sub    $0x8,%esp
  80195e:	ff 75 f4             	pushl  -0xc(%ebp)
  801961:	6a 00                	push   $0x0
  801963:	e8 39 f2 ff ff       	call   800ba1 <sys_page_unmap>
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80196d:	89 d0                	mov    %edx,%eax
  80196f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801972:	5b                   	pop    %ebx
  801973:	5e                   	pop    %esi
  801974:	5d                   	pop    %ebp
  801975:	c3                   	ret    

00801976 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80197c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197f:	50                   	push   %eax
  801980:	ff 75 08             	pushl  0x8(%ebp)
  801983:	e8 e7 f4 ff ff       	call   800e6f <fd_lookup>
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	85 c0                	test   %eax,%eax
  80198d:	78 18                	js     8019a7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80198f:	83 ec 0c             	sub    $0xc,%esp
  801992:	ff 75 f4             	pushl  -0xc(%ebp)
  801995:	e8 6f f4 ff ff       	call   800e09 <fd2data>
	return _pipeisclosed(fd, p);
  80199a:	89 c2                	mov    %eax,%edx
  80199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199f:	e8 21 fd ff ff       	call   8016c5 <_pipeisclosed>
  8019a4:	83 c4 10             	add    $0x10,%esp
}
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    

008019a9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b1:	5d                   	pop    %ebp
  8019b2:	c3                   	ret    

008019b3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019b9:	68 b9 22 80 00       	push   $0x8022b9
  8019be:	ff 75 0c             	pushl  0xc(%ebp)
  8019c1:	e8 53 ed ff ff       	call   800719 <strcpy>
	return 0;
}
  8019c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cb:	c9                   	leave  
  8019cc:	c3                   	ret    

008019cd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	57                   	push   %edi
  8019d1:	56                   	push   %esi
  8019d2:	53                   	push   %ebx
  8019d3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019de:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019e4:	eb 2d                	jmp    801a13 <devcons_write+0x46>
		m = n - tot;
  8019e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019e9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019eb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019ee:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019f3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019f6:	83 ec 04             	sub    $0x4,%esp
  8019f9:	53                   	push   %ebx
  8019fa:	03 45 0c             	add    0xc(%ebp),%eax
  8019fd:	50                   	push   %eax
  8019fe:	57                   	push   %edi
  8019ff:	e8 a7 ee ff ff       	call   8008ab <memmove>
		sys_cputs(buf, m);
  801a04:	83 c4 08             	add    $0x8,%esp
  801a07:	53                   	push   %ebx
  801a08:	57                   	push   %edi
  801a09:	e8 52 f0 ff ff       	call   800a60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a0e:	01 de                	add    %ebx,%esi
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	89 f0                	mov    %esi,%eax
  801a15:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a18:	72 cc                	jb     8019e6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1d:	5b                   	pop    %ebx
  801a1e:	5e                   	pop    %esi
  801a1f:	5f                   	pop    %edi
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 08             	sub    $0x8,%esp
  801a28:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a31:	74 2a                	je     801a5d <devcons_read+0x3b>
  801a33:	eb 05                	jmp    801a3a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a35:	e8 c3 f0 ff ff       	call   800afd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a3a:	e8 3f f0 ff ff       	call   800a7e <sys_cgetc>
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	74 f2                	je     801a35 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a43:	85 c0                	test   %eax,%eax
  801a45:	78 16                	js     801a5d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a47:	83 f8 04             	cmp    $0x4,%eax
  801a4a:	74 0c                	je     801a58 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a4f:	88 02                	mov    %al,(%edx)
	return 1;
  801a51:	b8 01 00 00 00       	mov    $0x1,%eax
  801a56:	eb 05                	jmp    801a5d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a58:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a65:	8b 45 08             	mov    0x8(%ebp),%eax
  801a68:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a6b:	6a 01                	push   $0x1
  801a6d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a70:	50                   	push   %eax
  801a71:	e8 ea ef ff ff       	call   800a60 <sys_cputs>
}
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <getchar>:

int
getchar(void)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a81:	6a 01                	push   $0x1
  801a83:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a86:	50                   	push   %eax
  801a87:	6a 00                	push   $0x0
  801a89:	e8 47 f6 ff ff       	call   8010d5 <read>
	if (r < 0)
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	85 c0                	test   %eax,%eax
  801a93:	78 0f                	js     801aa4 <getchar+0x29>
		return r;
	if (r < 1)
  801a95:	85 c0                	test   %eax,%eax
  801a97:	7e 06                	jle    801a9f <getchar+0x24>
		return -E_EOF;
	return c;
  801a99:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a9d:	eb 05                	jmp    801aa4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a9f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aaf:	50                   	push   %eax
  801ab0:	ff 75 08             	pushl  0x8(%ebp)
  801ab3:	e8 b7 f3 ff ff       	call   800e6f <fd_lookup>
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	85 c0                	test   %eax,%eax
  801abd:	78 11                	js     801ad0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ac8:	39 10                	cmp    %edx,(%eax)
  801aca:	0f 94 c0             	sete   %al
  801acd:	0f b6 c0             	movzbl %al,%eax
}
  801ad0:	c9                   	leave  
  801ad1:	c3                   	ret    

00801ad2 <opencons>:

int
opencons(void)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ad8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801adb:	50                   	push   %eax
  801adc:	e8 3f f3 ff ff       	call   800e20 <fd_alloc>
  801ae1:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	78 3e                	js     801b28 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801aea:	83 ec 04             	sub    $0x4,%esp
  801aed:	68 07 04 00 00       	push   $0x407
  801af2:	ff 75 f4             	pushl  -0xc(%ebp)
  801af5:	6a 00                	push   $0x0
  801af7:	e8 20 f0 ff ff       	call   800b1c <sys_page_alloc>
  801afc:	83 c4 10             	add    $0x10,%esp
		return r;
  801aff:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b01:	85 c0                	test   %eax,%eax
  801b03:	78 23                	js     801b28 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b05:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b13:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b1a:	83 ec 0c             	sub    $0xc,%esp
  801b1d:	50                   	push   %eax
  801b1e:	e8 d6 f2 ff ff       	call   800df9 <fd2num>
  801b23:	89 c2                	mov    %eax,%edx
  801b25:	83 c4 10             	add    $0x10,%esp
}
  801b28:	89 d0                	mov    %edx,%eax
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    

00801b2c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	56                   	push   %esi
  801b30:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b31:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b34:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b3a:	e8 9f ef ff ff       	call   800ade <sys_getenvid>
  801b3f:	83 ec 0c             	sub    $0xc,%esp
  801b42:	ff 75 0c             	pushl  0xc(%ebp)
  801b45:	ff 75 08             	pushl  0x8(%ebp)
  801b48:	56                   	push   %esi
  801b49:	50                   	push   %eax
  801b4a:	68 c8 22 80 00       	push   $0x8022c8
  801b4f:	e8 40 e6 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b54:	83 c4 18             	add    $0x18,%esp
  801b57:	53                   	push   %ebx
  801b58:	ff 75 10             	pushl  0x10(%ebp)
  801b5b:	e8 e3 e5 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801b60:	c7 04 24 b2 22 80 00 	movl   $0x8022b2,(%esp)
  801b67:	e8 28 e6 ff ff       	call   800194 <cprintf>
  801b6c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b6f:	cc                   	int3   
  801b70:	eb fd                	jmp    801b6f <_panic+0x43>

00801b72 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b78:	89 d0                	mov    %edx,%eax
  801b7a:	c1 e8 16             	shr    $0x16,%eax
  801b7d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b89:	f6 c1 01             	test   $0x1,%cl
  801b8c:	74 1d                	je     801bab <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b8e:	c1 ea 0c             	shr    $0xc,%edx
  801b91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b98:	f6 c2 01             	test   $0x1,%dl
  801b9b:	74 0e                	je     801bab <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b9d:	c1 ea 0c             	shr    $0xc,%edx
  801ba0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ba7:	ef 
  801ba8:	0f b7 c0             	movzwl %ax,%eax
}
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    
  801bad:	66 90                	xchg   %ax,%ax
  801baf:	90                   	nop

00801bb0 <__udivdi3>:
  801bb0:	55                   	push   %ebp
  801bb1:	57                   	push   %edi
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 1c             	sub    $0x1c,%esp
  801bb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bc7:	85 f6                	test   %esi,%esi
  801bc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bcd:	89 ca                	mov    %ecx,%edx
  801bcf:	89 f8                	mov    %edi,%eax
  801bd1:	75 3d                	jne    801c10 <__udivdi3+0x60>
  801bd3:	39 cf                	cmp    %ecx,%edi
  801bd5:	0f 87 c5 00 00 00    	ja     801ca0 <__udivdi3+0xf0>
  801bdb:	85 ff                	test   %edi,%edi
  801bdd:	89 fd                	mov    %edi,%ebp
  801bdf:	75 0b                	jne    801bec <__udivdi3+0x3c>
  801be1:	b8 01 00 00 00       	mov    $0x1,%eax
  801be6:	31 d2                	xor    %edx,%edx
  801be8:	f7 f7                	div    %edi
  801bea:	89 c5                	mov    %eax,%ebp
  801bec:	89 c8                	mov    %ecx,%eax
  801bee:	31 d2                	xor    %edx,%edx
  801bf0:	f7 f5                	div    %ebp
  801bf2:	89 c1                	mov    %eax,%ecx
  801bf4:	89 d8                	mov    %ebx,%eax
  801bf6:	89 cf                	mov    %ecx,%edi
  801bf8:	f7 f5                	div    %ebp
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	89 fa                	mov    %edi,%edx
  801c00:	83 c4 1c             	add    $0x1c,%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5e                   	pop    %esi
  801c05:	5f                   	pop    %edi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    
  801c08:	90                   	nop
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	39 ce                	cmp    %ecx,%esi
  801c12:	77 74                	ja     801c88 <__udivdi3+0xd8>
  801c14:	0f bd fe             	bsr    %esi,%edi
  801c17:	83 f7 1f             	xor    $0x1f,%edi
  801c1a:	0f 84 98 00 00 00    	je     801cb8 <__udivdi3+0x108>
  801c20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	89 c5                	mov    %eax,%ebp
  801c29:	29 fb                	sub    %edi,%ebx
  801c2b:	d3 e6                	shl    %cl,%esi
  801c2d:	89 d9                	mov    %ebx,%ecx
  801c2f:	d3 ed                	shr    %cl,%ebp
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e0                	shl    %cl,%eax
  801c35:	09 ee                	or     %ebp,%esi
  801c37:	89 d9                	mov    %ebx,%ecx
  801c39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c3d:	89 d5                	mov    %edx,%ebp
  801c3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c43:	d3 ed                	shr    %cl,%ebp
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e2                	shl    %cl,%edx
  801c49:	89 d9                	mov    %ebx,%ecx
  801c4b:	d3 e8                	shr    %cl,%eax
  801c4d:	09 c2                	or     %eax,%edx
  801c4f:	89 d0                	mov    %edx,%eax
  801c51:	89 ea                	mov    %ebp,%edx
  801c53:	f7 f6                	div    %esi
  801c55:	89 d5                	mov    %edx,%ebp
  801c57:	89 c3                	mov    %eax,%ebx
  801c59:	f7 64 24 0c          	mull   0xc(%esp)
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	72 10                	jb     801c71 <__udivdi3+0xc1>
  801c61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e6                	shl    %cl,%esi
  801c69:	39 c6                	cmp    %eax,%esi
  801c6b:	73 07                	jae    801c74 <__udivdi3+0xc4>
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	75 03                	jne    801c74 <__udivdi3+0xc4>
  801c71:	83 eb 01             	sub    $0x1,%ebx
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 d8                	mov    %ebx,%eax
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	31 ff                	xor    %edi,%edi
  801c8a:	31 db                	xor    %ebx,%ebx
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	89 fa                	mov    %edi,%edx
  801c90:	83 c4 1c             	add    $0x1c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	90                   	nop
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	f7 f7                	div    %edi
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	89 d8                	mov    %ebx,%eax
  801caa:	89 fa                	mov    %edi,%edx
  801cac:	83 c4 1c             	add    $0x1c,%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5f                   	pop    %edi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    
  801cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	39 ce                	cmp    %ecx,%esi
  801cba:	72 0c                	jb     801cc8 <__udivdi3+0x118>
  801cbc:	31 db                	xor    %ebx,%ebx
  801cbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cc2:	0f 87 34 ff ff ff    	ja     801bfc <__udivdi3+0x4c>
  801cc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ccd:	e9 2a ff ff ff       	jmp    801bfc <__udivdi3+0x4c>
  801cd2:	66 90                	xchg   %ax,%ax
  801cd4:	66 90                	xchg   %ax,%ax
  801cd6:	66 90                	xchg   %ax,%ax
  801cd8:	66 90                	xchg   %ax,%ax
  801cda:	66 90                	xchg   %ax,%ax
  801cdc:	66 90                	xchg   %ax,%ax
  801cde:	66 90                	xchg   %ax,%ax

00801ce0 <__umoddi3>:
  801ce0:	55                   	push   %ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ceb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cf7:	85 d2                	test   %edx,%edx
  801cf9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d01:	89 f3                	mov    %esi,%ebx
  801d03:	89 3c 24             	mov    %edi,(%esp)
  801d06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d0a:	75 1c                	jne    801d28 <__umoddi3+0x48>
  801d0c:	39 f7                	cmp    %esi,%edi
  801d0e:	76 50                	jbe    801d60 <__umoddi3+0x80>
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	f7 f7                	div    %edi
  801d16:	89 d0                	mov    %edx,%eax
  801d18:	31 d2                	xor    %edx,%edx
  801d1a:	83 c4 1c             	add    $0x1c,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d28:	39 f2                	cmp    %esi,%edx
  801d2a:	89 d0                	mov    %edx,%eax
  801d2c:	77 52                	ja     801d80 <__umoddi3+0xa0>
  801d2e:	0f bd ea             	bsr    %edx,%ebp
  801d31:	83 f5 1f             	xor    $0x1f,%ebp
  801d34:	75 5a                	jne    801d90 <__umoddi3+0xb0>
  801d36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d3a:	0f 82 e0 00 00 00    	jb     801e20 <__umoddi3+0x140>
  801d40:	39 0c 24             	cmp    %ecx,(%esp)
  801d43:	0f 86 d7 00 00 00    	jbe    801e20 <__umoddi3+0x140>
  801d49:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d51:	83 c4 1c             	add    $0x1c,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
  801d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d60:	85 ff                	test   %edi,%edi
  801d62:	89 fd                	mov    %edi,%ebp
  801d64:	75 0b                	jne    801d71 <__umoddi3+0x91>
  801d66:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6b:	31 d2                	xor    %edx,%edx
  801d6d:	f7 f7                	div    %edi
  801d6f:	89 c5                	mov    %eax,%ebp
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	31 d2                	xor    %edx,%edx
  801d75:	f7 f5                	div    %ebp
  801d77:	89 c8                	mov    %ecx,%eax
  801d79:	f7 f5                	div    %ebp
  801d7b:	89 d0                	mov    %edx,%eax
  801d7d:	eb 99                	jmp    801d18 <__umoddi3+0x38>
  801d7f:	90                   	nop
  801d80:	89 c8                	mov    %ecx,%eax
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	83 c4 1c             	add    $0x1c,%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
  801d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d90:	8b 34 24             	mov    (%esp),%esi
  801d93:	bf 20 00 00 00       	mov    $0x20,%edi
  801d98:	89 e9                	mov    %ebp,%ecx
  801d9a:	29 ef                	sub    %ebp,%edi
  801d9c:	d3 e0                	shl    %cl,%eax
  801d9e:	89 f9                	mov    %edi,%ecx
  801da0:	89 f2                	mov    %esi,%edx
  801da2:	d3 ea                	shr    %cl,%edx
  801da4:	89 e9                	mov    %ebp,%ecx
  801da6:	09 c2                	or     %eax,%edx
  801da8:	89 d8                	mov    %ebx,%eax
  801daa:	89 14 24             	mov    %edx,(%esp)
  801dad:	89 f2                	mov    %esi,%edx
  801daf:	d3 e2                	shl    %cl,%edx
  801db1:	89 f9                	mov    %edi,%ecx
  801db3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dbb:	d3 e8                	shr    %cl,%eax
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	89 c6                	mov    %eax,%esi
  801dc1:	d3 e3                	shl    %cl,%ebx
  801dc3:	89 f9                	mov    %edi,%ecx
  801dc5:	89 d0                	mov    %edx,%eax
  801dc7:	d3 e8                	shr    %cl,%eax
  801dc9:	89 e9                	mov    %ebp,%ecx
  801dcb:	09 d8                	or     %ebx,%eax
  801dcd:	89 d3                	mov    %edx,%ebx
  801dcf:	89 f2                	mov    %esi,%edx
  801dd1:	f7 34 24             	divl   (%esp)
  801dd4:	89 d6                	mov    %edx,%esi
  801dd6:	d3 e3                	shl    %cl,%ebx
  801dd8:	f7 64 24 04          	mull   0x4(%esp)
  801ddc:	39 d6                	cmp    %edx,%esi
  801dde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de2:	89 d1                	mov    %edx,%ecx
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	72 08                	jb     801df0 <__umoddi3+0x110>
  801de8:	75 11                	jne    801dfb <__umoddi3+0x11b>
  801dea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dee:	73 0b                	jae    801dfb <__umoddi3+0x11b>
  801df0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801df4:	1b 14 24             	sbb    (%esp),%edx
  801df7:	89 d1                	mov    %edx,%ecx
  801df9:	89 c3                	mov    %eax,%ebx
  801dfb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dff:	29 da                	sub    %ebx,%edx
  801e01:	19 ce                	sbb    %ecx,%esi
  801e03:	89 f9                	mov    %edi,%ecx
  801e05:	89 f0                	mov    %esi,%eax
  801e07:	d3 e0                	shl    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	d3 ea                	shr    %cl,%edx
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	d3 ee                	shr    %cl,%esi
  801e11:	09 d0                	or     %edx,%eax
  801e13:	89 f2                	mov    %esi,%edx
  801e15:	83 c4 1c             	add    $0x1c,%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5e                   	pop    %esi
  801e1a:	5f                   	pop    %edi
  801e1b:	5d                   	pop    %ebp
  801e1c:	c3                   	ret    
  801e1d:	8d 76 00             	lea    0x0(%esi),%esi
  801e20:	29 f9                	sub    %edi,%ecx
  801e22:	19 d6                	sbb    %edx,%esi
  801e24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e2c:	e9 18 ff ff ff       	jmp    801d49 <__umoddi3+0x69>
