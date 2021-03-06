
obj/user/faultio.debug:     file format elf32-i386


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
  80002c:	e8 3c 00 00 00       	call   80006d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	74 10                	je     800050 <umain+0x1d>
		cprintf("eflags wrong\n");
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	68 20 1e 80 00       	push   $0x801e20
  800048:	e8 13 01 00 00       	call   800160 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800050:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800055:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80005a:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  80005b:	83 ec 0c             	sub    $0xc,%esp
  80005e:	68 2e 1e 80 00       	push   $0x801e2e
  800063:	e8 f8 00 00 00       	call   800160 <cprintf>
}
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    

0080006d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800078:	e8 2d 0a 00 00       	call   800aaa <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 db                	test   %ebx,%ebx
  800091:	7e 07                	jle    80009a <libmain+0x2d>
		binaryname = argv[0];
  800093:	8b 06                	mov    (%esi),%eax
  800095:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	e8 8f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0a 00 00 00       	call   8000b3 <exit>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b9:	e8 e6 0d 00 00       	call   800ea4 <close_all>
	sys_env_destroy(0);
  8000be:	83 ec 0c             	sub    $0xc,%esp
  8000c1:	6a 00                	push   $0x0
  8000c3:	e8 a1 09 00 00       	call   800a69 <sys_env_destroy>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    

008000cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	53                   	push   %ebx
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d7:	8b 13                	mov    (%ebx),%edx
  8000d9:	8d 42 01             	lea    0x1(%edx),%eax
  8000dc:	89 03                	mov    %eax,(%ebx)
  8000de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ea:	75 1a                	jne    800106 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ec:	83 ec 08             	sub    $0x8,%esp
  8000ef:	68 ff 00 00 00       	push   $0xff
  8000f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f7:	50                   	push   %eax
  8000f8:	e8 2f 09 00 00       	call   800a2c <sys_cputs>
		b->idx = 0;
  8000fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800103:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800106:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80010a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011f:	00 00 00 
	b.cnt = 0;
  800122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012c:	ff 75 0c             	pushl  0xc(%ebp)
  80012f:	ff 75 08             	pushl  0x8(%ebp)
  800132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800138:	50                   	push   %eax
  800139:	68 cd 00 80 00       	push   $0x8000cd
  80013e:	e8 54 01 00 00       	call   800297 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80014c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800152:	50                   	push   %eax
  800153:	e8 d4 08 00 00       	call   800a2c <sys_cputs>

	return b.cnt;
}
  800158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800169:	50                   	push   %eax
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	e8 9d ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 1c             	sub    $0x1c,%esp
  80017d:	89 c7                	mov    %eax,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	8b 55 0c             	mov    0xc(%ebp),%edx
  800187:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800190:	bb 00 00 00 00       	mov    $0x0,%ebx
  800195:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800198:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80019b:	39 d3                	cmp    %edx,%ebx
  80019d:	72 05                	jb     8001a4 <printnum+0x30>
  80019f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a2:	77 45                	ja     8001e9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	ff 75 18             	pushl  0x18(%ebp)
  8001aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ad:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001b0:	53                   	push   %ebx
  8001b1:	ff 75 10             	pushl  0x10(%ebp)
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c3:	e8 b8 19 00 00       	call   801b80 <__udivdi3>
  8001c8:	83 c4 18             	add    $0x18,%esp
  8001cb:	52                   	push   %edx
  8001cc:	50                   	push   %eax
  8001cd:	89 f2                	mov    %esi,%edx
  8001cf:	89 f8                	mov    %edi,%eax
  8001d1:	e8 9e ff ff ff       	call   800174 <printnum>
  8001d6:	83 c4 20             	add    $0x20,%esp
  8001d9:	eb 18                	jmp    8001f3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	56                   	push   %esi
  8001df:	ff 75 18             	pushl  0x18(%ebp)
  8001e2:	ff d7                	call   *%edi
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 03                	jmp    8001ec <printnum+0x78>
  8001e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ec:	83 eb 01             	sub    $0x1,%ebx
  8001ef:	85 db                	test   %ebx,%ebx
  8001f1:	7f e8                	jg     8001db <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f3:	83 ec 08             	sub    $0x8,%esp
  8001f6:	56                   	push   %esi
  8001f7:	83 ec 04             	sub    $0x4,%esp
  8001fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800200:	ff 75 dc             	pushl  -0x24(%ebp)
  800203:	ff 75 d8             	pushl  -0x28(%ebp)
  800206:	e8 a5 1a 00 00       	call   801cb0 <__umoddi3>
  80020b:	83 c4 14             	add    $0x14,%esp
  80020e:	0f be 80 52 1e 80 00 	movsbl 0x801e52(%eax),%eax
  800215:	50                   	push   %eax
  800216:	ff d7                	call   *%edi
}
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800226:	83 fa 01             	cmp    $0x1,%edx
  800229:	7e 0e                	jle    800239 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80022b:	8b 10                	mov    (%eax),%edx
  80022d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800230:	89 08                	mov    %ecx,(%eax)
  800232:	8b 02                	mov    (%edx),%eax
  800234:	8b 52 04             	mov    0x4(%edx),%edx
  800237:	eb 22                	jmp    80025b <getuint+0x38>
	else if (lflag)
  800239:	85 d2                	test   %edx,%edx
  80023b:	74 10                	je     80024d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80023d:	8b 10                	mov    (%eax),%edx
  80023f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800242:	89 08                	mov    %ecx,(%eax)
  800244:	8b 02                	mov    (%edx),%eax
  800246:	ba 00 00 00 00       	mov    $0x0,%edx
  80024b:	eb 0e                	jmp    80025b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80024d:	8b 10                	mov    (%eax),%edx
  80024f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800252:	89 08                	mov    %ecx,(%eax)
  800254:	8b 02                	mov    (%edx),%eax
  800256:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80025b:	5d                   	pop    %ebp
  80025c:	c3                   	ret    

0080025d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800263:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800267:	8b 10                	mov    (%eax),%edx
  800269:	3b 50 04             	cmp    0x4(%eax),%edx
  80026c:	73 0a                	jae    800278 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	88 02                	mov    %al,(%edx)
}
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800280:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800283:	50                   	push   %eax
  800284:	ff 75 10             	pushl  0x10(%ebp)
  800287:	ff 75 0c             	pushl  0xc(%ebp)
  80028a:	ff 75 08             	pushl  0x8(%ebp)
  80028d:	e8 05 00 00 00       	call   800297 <vprintfmt>
	va_end(ap);
}
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	57                   	push   %edi
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 2c             	sub    $0x2c,%esp
  8002a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a9:	eb 12                	jmp    8002bd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ab:	85 c0                	test   %eax,%eax
  8002ad:	0f 84 89 03 00 00    	je     80063c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002b3:	83 ec 08             	sub    $0x8,%esp
  8002b6:	53                   	push   %ebx
  8002b7:	50                   	push   %eax
  8002b8:	ff d6                	call   *%esi
  8002ba:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002bd:	83 c7 01             	add    $0x1,%edi
  8002c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c4:	83 f8 25             	cmp    $0x25,%eax
  8002c7:	75 e2                	jne    8002ab <vprintfmt+0x14>
  8002c9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002cd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002d4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002db:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e7:	eb 07                	jmp    8002f0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ec:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f0:	8d 47 01             	lea    0x1(%edi),%eax
  8002f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f6:	0f b6 07             	movzbl (%edi),%eax
  8002f9:	0f b6 c8             	movzbl %al,%ecx
  8002fc:	83 e8 23             	sub    $0x23,%eax
  8002ff:	3c 55                	cmp    $0x55,%al
  800301:	0f 87 1a 03 00 00    	ja     800621 <vprintfmt+0x38a>
  800307:	0f b6 c0             	movzbl %al,%eax
  80030a:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  800311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800314:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800318:	eb d6                	jmp    8002f0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031d:	b8 00 00 00 00       	mov    $0x0,%eax
  800322:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800325:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800328:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80032c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80032f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800332:	83 fa 09             	cmp    $0x9,%edx
  800335:	77 39                	ja     800370 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800337:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80033a:	eb e9                	jmp    800325 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80033c:	8b 45 14             	mov    0x14(%ebp),%eax
  80033f:	8d 48 04             	lea    0x4(%eax),%ecx
  800342:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800345:	8b 00                	mov    (%eax),%eax
  800347:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80034d:	eb 27                	jmp    800376 <vprintfmt+0xdf>
  80034f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800352:	85 c0                	test   %eax,%eax
  800354:	b9 00 00 00 00       	mov    $0x0,%ecx
  800359:	0f 49 c8             	cmovns %eax,%ecx
  80035c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800362:	eb 8c                	jmp    8002f0 <vprintfmt+0x59>
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800367:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80036e:	eb 80                	jmp    8002f0 <vprintfmt+0x59>
  800370:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800373:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800376:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037a:	0f 89 70 ff ff ff    	jns    8002f0 <vprintfmt+0x59>
				width = precision, precision = -1;
  800380:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800383:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800386:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038d:	e9 5e ff ff ff       	jmp    8002f0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800392:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800398:	e9 53 ff ff ff       	jmp    8002f0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 50 04             	lea    0x4(%eax),%edx
  8003a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	53                   	push   %ebx
  8003aa:	ff 30                	pushl  (%eax)
  8003ac:	ff d6                	call   *%esi
			break;
  8003ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b4:	e9 04 ff ff ff       	jmp    8002bd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 50 04             	lea    0x4(%eax),%edx
  8003bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c2:	8b 00                	mov    (%eax),%eax
  8003c4:	99                   	cltd   
  8003c5:	31 d0                	xor    %edx,%eax
  8003c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c9:	83 f8 0f             	cmp    $0xf,%eax
  8003cc:	7f 0b                	jg     8003d9 <vprintfmt+0x142>
  8003ce:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  8003d5:	85 d2                	test   %edx,%edx
  8003d7:	75 18                	jne    8003f1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003d9:	50                   	push   %eax
  8003da:	68 6a 1e 80 00       	push   $0x801e6a
  8003df:	53                   	push   %ebx
  8003e0:	56                   	push   %esi
  8003e1:	e8 94 fe ff ff       	call   80027a <printfmt>
  8003e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ec:	e9 cc fe ff ff       	jmp    8002bd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f1:	52                   	push   %edx
  8003f2:	68 31 22 80 00       	push   $0x802231
  8003f7:	53                   	push   %ebx
  8003f8:	56                   	push   %esi
  8003f9:	e8 7c fe ff ff       	call   80027a <printfmt>
  8003fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800404:	e9 b4 fe ff ff       	jmp    8002bd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 50 04             	lea    0x4(%eax),%edx
  80040f:	89 55 14             	mov    %edx,0x14(%ebp)
  800412:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800414:	85 ff                	test   %edi,%edi
  800416:	b8 63 1e 80 00       	mov    $0x801e63,%eax
  80041b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80041e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800422:	0f 8e 94 00 00 00    	jle    8004bc <vprintfmt+0x225>
  800428:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042c:	0f 84 98 00 00 00    	je     8004ca <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	ff 75 d0             	pushl  -0x30(%ebp)
  800438:	57                   	push   %edi
  800439:	e8 86 02 00 00       	call   8006c4 <strnlen>
  80043e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800441:	29 c1                	sub    %eax,%ecx
  800443:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800446:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800449:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800450:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800453:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	eb 0f                	jmp    800466 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	53                   	push   %ebx
  80045b:	ff 75 e0             	pushl  -0x20(%ebp)
  80045e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	83 ef 01             	sub    $0x1,%edi
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	85 ff                	test   %edi,%edi
  800468:	7f ed                	jg     800457 <vprintfmt+0x1c0>
  80046a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800470:	85 c9                	test   %ecx,%ecx
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	0f 49 c1             	cmovns %ecx,%eax
  80047a:	29 c1                	sub    %eax,%ecx
  80047c:	89 75 08             	mov    %esi,0x8(%ebp)
  80047f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800482:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800485:	89 cb                	mov    %ecx,%ebx
  800487:	eb 4d                	jmp    8004d6 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800489:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048d:	74 1b                	je     8004aa <vprintfmt+0x213>
  80048f:	0f be c0             	movsbl %al,%eax
  800492:	83 e8 20             	sub    $0x20,%eax
  800495:	83 f8 5e             	cmp    $0x5e,%eax
  800498:	76 10                	jbe    8004aa <vprintfmt+0x213>
					putch('?', putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	ff 75 0c             	pushl  0xc(%ebp)
  8004a0:	6a 3f                	push   $0x3f
  8004a2:	ff 55 08             	call   *0x8(%ebp)
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	eb 0d                	jmp    8004b7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	ff 75 0c             	pushl  0xc(%ebp)
  8004b0:	52                   	push   %edx
  8004b1:	ff 55 08             	call   *0x8(%ebp)
  8004b4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b7:	83 eb 01             	sub    $0x1,%ebx
  8004ba:	eb 1a                	jmp    8004d6 <vprintfmt+0x23f>
  8004bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c8:	eb 0c                	jmp    8004d6 <vprintfmt+0x23f>
  8004ca:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d6:	83 c7 01             	add    $0x1,%edi
  8004d9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004dd:	0f be d0             	movsbl %al,%edx
  8004e0:	85 d2                	test   %edx,%edx
  8004e2:	74 23                	je     800507 <vprintfmt+0x270>
  8004e4:	85 f6                	test   %esi,%esi
  8004e6:	78 a1                	js     800489 <vprintfmt+0x1f2>
  8004e8:	83 ee 01             	sub    $0x1,%esi
  8004eb:	79 9c                	jns    800489 <vprintfmt+0x1f2>
  8004ed:	89 df                	mov    %ebx,%edi
  8004ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f5:	eb 18                	jmp    80050f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	6a 20                	push   $0x20
  8004fd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ff:	83 ef 01             	sub    $0x1,%edi
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	eb 08                	jmp    80050f <vprintfmt+0x278>
  800507:	89 df                	mov    %ebx,%edi
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050f:	85 ff                	test   %edi,%edi
  800511:	7f e4                	jg     8004f7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800516:	e9 a2 fd ff ff       	jmp    8002bd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051b:	83 fa 01             	cmp    $0x1,%edx
  80051e:	7e 16                	jle    800536 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 08             	lea    0x8(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 50 04             	mov    0x4(%eax),%edx
  80052c:	8b 00                	mov    (%eax),%eax
  80052e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800531:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800534:	eb 32                	jmp    800568 <vprintfmt+0x2d1>
	else if (lflag)
  800536:	85 d2                	test   %edx,%edx
  800538:	74 18                	je     800552 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	8b 00                	mov    (%eax),%eax
  800545:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800548:	89 c1                	mov    %eax,%ecx
  80054a:	c1 f9 1f             	sar    $0x1f,%ecx
  80054d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800550:	eb 16                	jmp    800568 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800560:	89 c1                	mov    %eax,%ecx
  800562:	c1 f9 1f             	sar    $0x1f,%ecx
  800565:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800568:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80056b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80056e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800573:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800577:	79 74                	jns    8005ed <vprintfmt+0x356>
				putch('-', putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	53                   	push   %ebx
  80057d:	6a 2d                	push   $0x2d
  80057f:	ff d6                	call   *%esi
				num = -(long long) num;
  800581:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800584:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800587:	f7 d8                	neg    %eax
  800589:	83 d2 00             	adc    $0x0,%edx
  80058c:	f7 da                	neg    %edx
  80058e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800591:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800596:	eb 55                	jmp    8005ed <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800598:	8d 45 14             	lea    0x14(%ebp),%eax
  80059b:	e8 83 fc ff ff       	call   800223 <getuint>
			base = 10;
  8005a0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005a5:	eb 46                	jmp    8005ed <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005aa:	e8 74 fc ff ff       	call   800223 <getuint>
			base = 8;
  8005af:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005b4:	eb 37                	jmp    8005ed <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	53                   	push   %ebx
  8005ba:	6a 30                	push   $0x30
  8005bc:	ff d6                	call   *%esi
			putch('x', putdat);
  8005be:	83 c4 08             	add    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 78                	push   $0x78
  8005c4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005d6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005de:	eb 0d                	jmp    8005ed <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e3:	e8 3b fc ff ff       	call   800223 <getuint>
			base = 16;
  8005e8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ed:	83 ec 0c             	sub    $0xc,%esp
  8005f0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005f4:	57                   	push   %edi
  8005f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f8:	51                   	push   %ecx
  8005f9:	52                   	push   %edx
  8005fa:	50                   	push   %eax
  8005fb:	89 da                	mov    %ebx,%edx
  8005fd:	89 f0                	mov    %esi,%eax
  8005ff:	e8 70 fb ff ff       	call   800174 <printnum>
			break;
  800604:	83 c4 20             	add    $0x20,%esp
  800607:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80060a:	e9 ae fc ff ff       	jmp    8002bd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	51                   	push   %ecx
  800614:	ff d6                	call   *%esi
			break;
  800616:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80061c:	e9 9c fc ff ff       	jmp    8002bd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 25                	push   $0x25
  800627:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	eb 03                	jmp    800631 <vprintfmt+0x39a>
  80062e:	83 ef 01             	sub    $0x1,%edi
  800631:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800635:	75 f7                	jne    80062e <vprintfmt+0x397>
  800637:	e9 81 fc ff ff       	jmp    8002bd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80063c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063f:	5b                   	pop    %ebx
  800640:	5e                   	pop    %esi
  800641:	5f                   	pop    %edi
  800642:	5d                   	pop    %ebp
  800643:	c3                   	ret    

00800644 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800644:	55                   	push   %ebp
  800645:	89 e5                	mov    %esp,%ebp
  800647:	83 ec 18             	sub    $0x18,%esp
  80064a:	8b 45 08             	mov    0x8(%ebp),%eax
  80064d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800650:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800653:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800657:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80065a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800661:	85 c0                	test   %eax,%eax
  800663:	74 26                	je     80068b <vsnprintf+0x47>
  800665:	85 d2                	test   %edx,%edx
  800667:	7e 22                	jle    80068b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800669:	ff 75 14             	pushl  0x14(%ebp)
  80066c:	ff 75 10             	pushl  0x10(%ebp)
  80066f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800672:	50                   	push   %eax
  800673:	68 5d 02 80 00       	push   $0x80025d
  800678:	e8 1a fc ff ff       	call   800297 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80067d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800680:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800683:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800686:	83 c4 10             	add    $0x10,%esp
  800689:	eb 05                	jmp    800690 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80068b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800690:	c9                   	leave  
  800691:	c3                   	ret    

00800692 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800692:	55                   	push   %ebp
  800693:	89 e5                	mov    %esp,%ebp
  800695:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800698:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80069b:	50                   	push   %eax
  80069c:	ff 75 10             	pushl  0x10(%ebp)
  80069f:	ff 75 0c             	pushl  0xc(%ebp)
  8006a2:	ff 75 08             	pushl  0x8(%ebp)
  8006a5:	e8 9a ff ff ff       	call   800644 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006aa:	c9                   	leave  
  8006ab:	c3                   	ret    

008006ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b7:	eb 03                	jmp    8006bc <strlen+0x10>
		n++;
  8006b9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006bc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c0:	75 f7                	jne    8006b9 <strlen+0xd>
		n++;
	return n;
}
  8006c2:	5d                   	pop    %ebp
  8006c3:	c3                   	ret    

008006c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d2:	eb 03                	jmp    8006d7 <strnlen+0x13>
		n++;
  8006d4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d7:	39 c2                	cmp    %eax,%edx
  8006d9:	74 08                	je     8006e3 <strnlen+0x1f>
  8006db:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006df:	75 f3                	jne    8006d4 <strnlen+0x10>
  8006e1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006e3:	5d                   	pop    %ebp
  8006e4:	c3                   	ret    

008006e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	53                   	push   %ebx
  8006e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006ef:	89 c2                	mov    %eax,%edx
  8006f1:	83 c2 01             	add    $0x1,%edx
  8006f4:	83 c1 01             	add    $0x1,%ecx
  8006f7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006fb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006fe:	84 db                	test   %bl,%bl
  800700:	75 ef                	jne    8006f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800702:	5b                   	pop    %ebx
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	53                   	push   %ebx
  800709:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80070c:	53                   	push   %ebx
  80070d:	e8 9a ff ff ff       	call   8006ac <strlen>
  800712:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800715:	ff 75 0c             	pushl  0xc(%ebp)
  800718:	01 d8                	add    %ebx,%eax
  80071a:	50                   	push   %eax
  80071b:	e8 c5 ff ff ff       	call   8006e5 <strcpy>
	return dst;
}
  800720:	89 d8                	mov    %ebx,%eax
  800722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800725:	c9                   	leave  
  800726:	c3                   	ret    

00800727 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	56                   	push   %esi
  80072b:	53                   	push   %ebx
  80072c:	8b 75 08             	mov    0x8(%ebp),%esi
  80072f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800732:	89 f3                	mov    %esi,%ebx
  800734:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800737:	89 f2                	mov    %esi,%edx
  800739:	eb 0f                	jmp    80074a <strncpy+0x23>
		*dst++ = *src;
  80073b:	83 c2 01             	add    $0x1,%edx
  80073e:	0f b6 01             	movzbl (%ecx),%eax
  800741:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800744:	80 39 01             	cmpb   $0x1,(%ecx)
  800747:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074a:	39 da                	cmp    %ebx,%edx
  80074c:	75 ed                	jne    80073b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80074e:	89 f0                	mov    %esi,%eax
  800750:	5b                   	pop    %ebx
  800751:	5e                   	pop    %esi
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	8b 75 08             	mov    0x8(%ebp),%esi
  80075c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075f:	8b 55 10             	mov    0x10(%ebp),%edx
  800762:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800764:	85 d2                	test   %edx,%edx
  800766:	74 21                	je     800789 <strlcpy+0x35>
  800768:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80076c:	89 f2                	mov    %esi,%edx
  80076e:	eb 09                	jmp    800779 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800770:	83 c2 01             	add    $0x1,%edx
  800773:	83 c1 01             	add    $0x1,%ecx
  800776:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800779:	39 c2                	cmp    %eax,%edx
  80077b:	74 09                	je     800786 <strlcpy+0x32>
  80077d:	0f b6 19             	movzbl (%ecx),%ebx
  800780:	84 db                	test   %bl,%bl
  800782:	75 ec                	jne    800770 <strlcpy+0x1c>
  800784:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800786:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800789:	29 f0                	sub    %esi,%eax
}
  80078b:	5b                   	pop    %ebx
  80078c:	5e                   	pop    %esi
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800795:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800798:	eb 06                	jmp    8007a0 <strcmp+0x11>
		p++, q++;
  80079a:	83 c1 01             	add    $0x1,%ecx
  80079d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007a0:	0f b6 01             	movzbl (%ecx),%eax
  8007a3:	84 c0                	test   %al,%al
  8007a5:	74 04                	je     8007ab <strcmp+0x1c>
  8007a7:	3a 02                	cmp    (%edx),%al
  8007a9:	74 ef                	je     80079a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ab:	0f b6 c0             	movzbl %al,%eax
  8007ae:	0f b6 12             	movzbl (%edx),%edx
  8007b1:	29 d0                	sub    %edx,%eax
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	53                   	push   %ebx
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bf:	89 c3                	mov    %eax,%ebx
  8007c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007c4:	eb 06                	jmp    8007cc <strncmp+0x17>
		n--, p++, q++;
  8007c6:	83 c0 01             	add    $0x1,%eax
  8007c9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007cc:	39 d8                	cmp    %ebx,%eax
  8007ce:	74 15                	je     8007e5 <strncmp+0x30>
  8007d0:	0f b6 08             	movzbl (%eax),%ecx
  8007d3:	84 c9                	test   %cl,%cl
  8007d5:	74 04                	je     8007db <strncmp+0x26>
  8007d7:	3a 0a                	cmp    (%edx),%cl
  8007d9:	74 eb                	je     8007c6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007db:	0f b6 00             	movzbl (%eax),%eax
  8007de:	0f b6 12             	movzbl (%edx),%edx
  8007e1:	29 d0                	sub    %edx,%eax
  8007e3:	eb 05                	jmp    8007ea <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007ea:	5b                   	pop    %ebx
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f7:	eb 07                	jmp    800800 <strchr+0x13>
		if (*s == c)
  8007f9:	38 ca                	cmp    %cl,%dl
  8007fb:	74 0f                	je     80080c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007fd:	83 c0 01             	add    $0x1,%eax
  800800:	0f b6 10             	movzbl (%eax),%edx
  800803:	84 d2                	test   %dl,%dl
  800805:	75 f2                	jne    8007f9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800818:	eb 03                	jmp    80081d <strfind+0xf>
  80081a:	83 c0 01             	add    $0x1,%eax
  80081d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800820:	38 ca                	cmp    %cl,%dl
  800822:	74 04                	je     800828 <strfind+0x1a>
  800824:	84 d2                	test   %dl,%dl
  800826:	75 f2                	jne    80081a <strfind+0xc>
			break;
	return (char *) s;
}
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	57                   	push   %edi
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	8b 7d 08             	mov    0x8(%ebp),%edi
  800833:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800836:	85 c9                	test   %ecx,%ecx
  800838:	74 36                	je     800870 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80083a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800840:	75 28                	jne    80086a <memset+0x40>
  800842:	f6 c1 03             	test   $0x3,%cl
  800845:	75 23                	jne    80086a <memset+0x40>
		c &= 0xFF;
  800847:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80084b:	89 d3                	mov    %edx,%ebx
  80084d:	c1 e3 08             	shl    $0x8,%ebx
  800850:	89 d6                	mov    %edx,%esi
  800852:	c1 e6 18             	shl    $0x18,%esi
  800855:	89 d0                	mov    %edx,%eax
  800857:	c1 e0 10             	shl    $0x10,%eax
  80085a:	09 f0                	or     %esi,%eax
  80085c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80085e:	89 d8                	mov    %ebx,%eax
  800860:	09 d0                	or     %edx,%eax
  800862:	c1 e9 02             	shr    $0x2,%ecx
  800865:	fc                   	cld    
  800866:	f3 ab                	rep stos %eax,%es:(%edi)
  800868:	eb 06                	jmp    800870 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80086a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086d:	fc                   	cld    
  80086e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800870:	89 f8                	mov    %edi,%eax
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	57                   	push   %edi
  80087b:	56                   	push   %esi
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800882:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800885:	39 c6                	cmp    %eax,%esi
  800887:	73 35                	jae    8008be <memmove+0x47>
  800889:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80088c:	39 d0                	cmp    %edx,%eax
  80088e:	73 2e                	jae    8008be <memmove+0x47>
		s += n;
		d += n;
  800890:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800893:	89 d6                	mov    %edx,%esi
  800895:	09 fe                	or     %edi,%esi
  800897:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80089d:	75 13                	jne    8008b2 <memmove+0x3b>
  80089f:	f6 c1 03             	test   $0x3,%cl
  8008a2:	75 0e                	jne    8008b2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008a4:	83 ef 04             	sub    $0x4,%edi
  8008a7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008aa:	c1 e9 02             	shr    $0x2,%ecx
  8008ad:	fd                   	std    
  8008ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b0:	eb 09                	jmp    8008bb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008b2:	83 ef 01             	sub    $0x1,%edi
  8008b5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008b8:	fd                   	std    
  8008b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008bb:	fc                   	cld    
  8008bc:	eb 1d                	jmp    8008db <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008be:	89 f2                	mov    %esi,%edx
  8008c0:	09 c2                	or     %eax,%edx
  8008c2:	f6 c2 03             	test   $0x3,%dl
  8008c5:	75 0f                	jne    8008d6 <memmove+0x5f>
  8008c7:	f6 c1 03             	test   $0x3,%cl
  8008ca:	75 0a                	jne    8008d6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008cc:	c1 e9 02             	shr    $0x2,%ecx
  8008cf:	89 c7                	mov    %eax,%edi
  8008d1:	fc                   	cld    
  8008d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d4:	eb 05                	jmp    8008db <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d6:	89 c7                	mov    %eax,%edi
  8008d8:	fc                   	cld    
  8008d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008db:	5e                   	pop    %esi
  8008dc:	5f                   	pop    %edi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008e2:	ff 75 10             	pushl  0x10(%ebp)
  8008e5:	ff 75 0c             	pushl  0xc(%ebp)
  8008e8:	ff 75 08             	pushl  0x8(%ebp)
  8008eb:	e8 87 ff ff ff       	call   800877 <memmove>
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fd:	89 c6                	mov    %eax,%esi
  8008ff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800902:	eb 1a                	jmp    80091e <memcmp+0x2c>
		if (*s1 != *s2)
  800904:	0f b6 08             	movzbl (%eax),%ecx
  800907:	0f b6 1a             	movzbl (%edx),%ebx
  80090a:	38 d9                	cmp    %bl,%cl
  80090c:	74 0a                	je     800918 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80090e:	0f b6 c1             	movzbl %cl,%eax
  800911:	0f b6 db             	movzbl %bl,%ebx
  800914:	29 d8                	sub    %ebx,%eax
  800916:	eb 0f                	jmp    800927 <memcmp+0x35>
		s1++, s2++;
  800918:	83 c0 01             	add    $0x1,%eax
  80091b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091e:	39 f0                	cmp    %esi,%eax
  800920:	75 e2                	jne    800904 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800932:	89 c1                	mov    %eax,%ecx
  800934:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800937:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80093b:	eb 0a                	jmp    800947 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80093d:	0f b6 10             	movzbl (%eax),%edx
  800940:	39 da                	cmp    %ebx,%edx
  800942:	74 07                	je     80094b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800944:	83 c0 01             	add    $0x1,%eax
  800947:	39 c8                	cmp    %ecx,%eax
  800949:	72 f2                	jb     80093d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80094b:	5b                   	pop    %ebx
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	57                   	push   %edi
  800952:	56                   	push   %esi
  800953:	53                   	push   %ebx
  800954:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800957:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095a:	eb 03                	jmp    80095f <strtol+0x11>
		s++;
  80095c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095f:	0f b6 01             	movzbl (%ecx),%eax
  800962:	3c 20                	cmp    $0x20,%al
  800964:	74 f6                	je     80095c <strtol+0xe>
  800966:	3c 09                	cmp    $0x9,%al
  800968:	74 f2                	je     80095c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80096a:	3c 2b                	cmp    $0x2b,%al
  80096c:	75 0a                	jne    800978 <strtol+0x2a>
		s++;
  80096e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800971:	bf 00 00 00 00       	mov    $0x0,%edi
  800976:	eb 11                	jmp    800989 <strtol+0x3b>
  800978:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80097d:	3c 2d                	cmp    $0x2d,%al
  80097f:	75 08                	jne    800989 <strtol+0x3b>
		s++, neg = 1;
  800981:	83 c1 01             	add    $0x1,%ecx
  800984:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800989:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80098f:	75 15                	jne    8009a6 <strtol+0x58>
  800991:	80 39 30             	cmpb   $0x30,(%ecx)
  800994:	75 10                	jne    8009a6 <strtol+0x58>
  800996:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80099a:	75 7c                	jne    800a18 <strtol+0xca>
		s += 2, base = 16;
  80099c:	83 c1 02             	add    $0x2,%ecx
  80099f:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009a4:	eb 16                	jmp    8009bc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009a6:	85 db                	test   %ebx,%ebx
  8009a8:	75 12                	jne    8009bc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009af:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b2:	75 08                	jne    8009bc <strtol+0x6e>
		s++, base = 8;
  8009b4:	83 c1 01             	add    $0x1,%ecx
  8009b7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009c4:	0f b6 11             	movzbl (%ecx),%edx
  8009c7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ca:	89 f3                	mov    %esi,%ebx
  8009cc:	80 fb 09             	cmp    $0x9,%bl
  8009cf:	77 08                	ja     8009d9 <strtol+0x8b>
			dig = *s - '0';
  8009d1:	0f be d2             	movsbl %dl,%edx
  8009d4:	83 ea 30             	sub    $0x30,%edx
  8009d7:	eb 22                	jmp    8009fb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009d9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009dc:	89 f3                	mov    %esi,%ebx
  8009de:	80 fb 19             	cmp    $0x19,%bl
  8009e1:	77 08                	ja     8009eb <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009e3:	0f be d2             	movsbl %dl,%edx
  8009e6:	83 ea 57             	sub    $0x57,%edx
  8009e9:	eb 10                	jmp    8009fb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009eb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009ee:	89 f3                	mov    %esi,%ebx
  8009f0:	80 fb 19             	cmp    $0x19,%bl
  8009f3:	77 16                	ja     800a0b <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009f5:	0f be d2             	movsbl %dl,%edx
  8009f8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009fb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009fe:	7d 0b                	jge    800a0b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a00:	83 c1 01             	add    $0x1,%ecx
  800a03:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a07:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a09:	eb b9                	jmp    8009c4 <strtol+0x76>

	if (endptr)
  800a0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0f:	74 0d                	je     800a1e <strtol+0xd0>
		*endptr = (char *) s;
  800a11:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a14:	89 0e                	mov    %ecx,(%esi)
  800a16:	eb 06                	jmp    800a1e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a18:	85 db                	test   %ebx,%ebx
  800a1a:	74 98                	je     8009b4 <strtol+0x66>
  800a1c:	eb 9e                	jmp    8009bc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a1e:	89 c2                	mov    %eax,%edx
  800a20:	f7 da                	neg    %edx
  800a22:	85 ff                	test   %edi,%edi
  800a24:	0f 45 c2             	cmovne %edx,%eax
}
  800a27:	5b                   	pop    %ebx
  800a28:	5e                   	pop    %esi
  800a29:	5f                   	pop    %edi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3d:	89 c3                	mov    %eax,%ebx
  800a3f:	89 c7                	mov    %eax,%edi
  800a41:	89 c6                	mov    %eax,%esi
  800a43:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a50:	ba 00 00 00 00       	mov    $0x0,%edx
  800a55:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5a:	89 d1                	mov    %edx,%ecx
  800a5c:	89 d3                	mov    %edx,%ebx
  800a5e:	89 d7                	mov    %edx,%edi
  800a60:	89 d6                	mov    %edx,%esi
  800a62:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5f                   	pop    %edi
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a77:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7f:	89 cb                	mov    %ecx,%ebx
  800a81:	89 cf                	mov    %ecx,%edi
  800a83:	89 ce                	mov    %ecx,%esi
  800a85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a87:	85 c0                	test   %eax,%eax
  800a89:	7e 17                	jle    800aa2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a8b:	83 ec 0c             	sub    $0xc,%esp
  800a8e:	50                   	push   %eax
  800a8f:	6a 03                	push   $0x3
  800a91:	68 5f 21 80 00       	push   $0x80215f
  800a96:	6a 23                	push   $0x23
  800a98:	68 7c 21 80 00       	push   $0x80217c
  800a9d:	e8 6a 0f 00 00       	call   801a0c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab5:	b8 02 00 00 00       	mov    $0x2,%eax
  800aba:	89 d1                	mov    %edx,%ecx
  800abc:	89 d3                	mov    %edx,%ebx
  800abe:	89 d7                	mov    %edx,%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_yield>:

void
sys_yield(void)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ad9:	89 d1                	mov    %edx,%ecx
  800adb:	89 d3                	mov    %edx,%ebx
  800add:	89 d7                	mov    %edx,%edi
  800adf:	89 d6                	mov    %edx,%esi
  800ae1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af1:	be 00 00 00 00       	mov    $0x0,%esi
  800af6:	b8 04 00 00 00       	mov    $0x4,%eax
  800afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afe:	8b 55 08             	mov    0x8(%ebp),%edx
  800b01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b04:	89 f7                	mov    %esi,%edi
  800b06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b08:	85 c0                	test   %eax,%eax
  800b0a:	7e 17                	jle    800b23 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0c:	83 ec 0c             	sub    $0xc,%esp
  800b0f:	50                   	push   %eax
  800b10:	6a 04                	push   $0x4
  800b12:	68 5f 21 80 00       	push   $0x80215f
  800b17:	6a 23                	push   $0x23
  800b19:	68 7c 21 80 00       	push   $0x80217c
  800b1e:	e8 e9 0e 00 00       	call   801a0c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b34:	b8 05 00 00 00       	mov    $0x5,%eax
  800b39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b45:	8b 75 18             	mov    0x18(%ebp),%esi
  800b48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	7e 17                	jle    800b65 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	50                   	push   %eax
  800b52:	6a 05                	push   $0x5
  800b54:	68 5f 21 80 00       	push   $0x80215f
  800b59:	6a 23                	push   $0x23
  800b5b:	68 7c 21 80 00       	push   $0x80217c
  800b60:	e8 a7 0e 00 00       	call   801a0c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b7b:	b8 06 00 00 00       	mov    $0x6,%eax
  800b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
  800b86:	89 df                	mov    %ebx,%edi
  800b88:	89 de                	mov    %ebx,%esi
  800b8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8c:	85 c0                	test   %eax,%eax
  800b8e:	7e 17                	jle    800ba7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	50                   	push   %eax
  800b94:	6a 06                	push   $0x6
  800b96:	68 5f 21 80 00       	push   $0x80215f
  800b9b:	6a 23                	push   $0x23
  800b9d:	68 7c 21 80 00       	push   $0x80217c
  800ba2:	e8 65 0e 00 00       	call   801a0c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbd:	b8 08 00 00 00       	mov    $0x8,%eax
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	89 df                	mov    %ebx,%edi
  800bca:	89 de                	mov    %ebx,%esi
  800bcc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 08                	push   $0x8
  800bd8:	68 5f 21 80 00       	push   $0x80215f
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 7c 21 80 00       	push   $0x80217c
  800be4:	e8 23 0e 00 00       	call   801a0c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800bfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bff:	b8 09 00 00 00       	mov    $0x9,%eax
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	89 df                	mov    %ebx,%edi
  800c0c:	89 de                	mov    %ebx,%esi
  800c0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 09                	push   $0x9
  800c1a:	68 5f 21 80 00       	push   $0x80215f
  800c1f:	6a 23                	push   $0x23
  800c21:	68 7c 21 80 00       	push   $0x80217c
  800c26:	e8 e1 0d 00 00       	call   801a0c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800c41:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800c54:	7e 17                	jle    800c6d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 0a                	push   $0xa
  800c5c:	68 5f 21 80 00       	push   $0x80215f
  800c61:	6a 23                	push   $0x23
  800c63:	68 7c 21 80 00       	push   $0x80217c
  800c68:	e8 9f 0d 00 00       	call   801a0c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	be 00 00 00 00       	mov    $0x0,%esi
  800c80:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c91:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cab:	8b 55 08             	mov    0x8(%ebp),%edx
  800cae:	89 cb                	mov    %ecx,%ebx
  800cb0:	89 cf                	mov    %ecx,%edi
  800cb2:	89 ce                	mov    %ecx,%esi
  800cb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 17                	jle    800cd1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	6a 0d                	push   $0xd
  800cc0:	68 5f 21 80 00       	push   $0x80215f
  800cc5:	6a 23                	push   $0x23
  800cc7:	68 7c 21 80 00       	push   $0x80217c
  800ccc:	e8 3b 0d 00 00       	call   801a0c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	05 00 00 00 30       	add    $0x30000000,%eax
  800ce4:	c1 e8 0c             	shr    $0xc,%eax
}
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800cec:	8b 45 08             	mov    0x8(%ebp),%eax
  800cef:	05 00 00 00 30       	add    $0x30000000,%eax
  800cf4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800cf9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d06:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d0b:	89 c2                	mov    %eax,%edx
  800d0d:	c1 ea 16             	shr    $0x16,%edx
  800d10:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d17:	f6 c2 01             	test   $0x1,%dl
  800d1a:	74 11                	je     800d2d <fd_alloc+0x2d>
  800d1c:	89 c2                	mov    %eax,%edx
  800d1e:	c1 ea 0c             	shr    $0xc,%edx
  800d21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d28:	f6 c2 01             	test   $0x1,%dl
  800d2b:	75 09                	jne    800d36 <fd_alloc+0x36>
			*fd_store = fd;
  800d2d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d34:	eb 17                	jmp    800d4d <fd_alloc+0x4d>
  800d36:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d3b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d40:	75 c9                	jne    800d0b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d42:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d48:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d55:	83 f8 1f             	cmp    $0x1f,%eax
  800d58:	77 36                	ja     800d90 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d5a:	c1 e0 0c             	shl    $0xc,%eax
  800d5d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d62:	89 c2                	mov    %eax,%edx
  800d64:	c1 ea 16             	shr    $0x16,%edx
  800d67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d6e:	f6 c2 01             	test   $0x1,%dl
  800d71:	74 24                	je     800d97 <fd_lookup+0x48>
  800d73:	89 c2                	mov    %eax,%edx
  800d75:	c1 ea 0c             	shr    $0xc,%edx
  800d78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d7f:	f6 c2 01             	test   $0x1,%dl
  800d82:	74 1a                	je     800d9e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d87:	89 02                	mov    %eax,(%edx)
	return 0;
  800d89:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8e:	eb 13                	jmp    800da3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d95:	eb 0c                	jmp    800da3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d9c:	eb 05                	jmp    800da3 <fd_lookup+0x54>
  800d9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	83 ec 08             	sub    $0x8,%esp
  800dab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dae:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800db3:	eb 13                	jmp    800dc8 <dev_lookup+0x23>
  800db5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800db8:	39 08                	cmp    %ecx,(%eax)
  800dba:	75 0c                	jne    800dc8 <dev_lookup+0x23>
			*dev = devtab[i];
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc6:	eb 2e                	jmp    800df6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dc8:	8b 02                	mov    (%edx),%eax
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	75 e7                	jne    800db5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dce:	a1 04 40 80 00       	mov    0x804004,%eax
  800dd3:	8b 40 48             	mov    0x48(%eax),%eax
  800dd6:	83 ec 04             	sub    $0x4,%esp
  800dd9:	51                   	push   %ecx
  800dda:	50                   	push   %eax
  800ddb:	68 8c 21 80 00       	push   $0x80218c
  800de0:	e8 7b f3 ff ff       	call   800160 <cprintf>
	*dev = 0;
  800de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800dee:	83 c4 10             	add    $0x10,%esp
  800df1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    

00800df8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 10             	sub    $0x10,%esp
  800e00:	8b 75 08             	mov    0x8(%ebp),%esi
  800e03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e09:	50                   	push   %eax
  800e0a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e10:	c1 e8 0c             	shr    $0xc,%eax
  800e13:	50                   	push   %eax
  800e14:	e8 36 ff ff ff       	call   800d4f <fd_lookup>
  800e19:	83 c4 08             	add    $0x8,%esp
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	78 05                	js     800e25 <fd_close+0x2d>
	    || fd != fd2)
  800e20:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e23:	74 0c                	je     800e31 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e25:	84 db                	test   %bl,%bl
  800e27:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2c:	0f 44 c2             	cmove  %edx,%eax
  800e2f:	eb 41                	jmp    800e72 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e31:	83 ec 08             	sub    $0x8,%esp
  800e34:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e37:	50                   	push   %eax
  800e38:	ff 36                	pushl  (%esi)
  800e3a:	e8 66 ff ff ff       	call   800da5 <dev_lookup>
  800e3f:	89 c3                	mov    %eax,%ebx
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	85 c0                	test   %eax,%eax
  800e46:	78 1a                	js     800e62 <fd_close+0x6a>
		if (dev->dev_close)
  800e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e4b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e4e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e53:	85 c0                	test   %eax,%eax
  800e55:	74 0b                	je     800e62 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e57:	83 ec 0c             	sub    $0xc,%esp
  800e5a:	56                   	push   %esi
  800e5b:	ff d0                	call   *%eax
  800e5d:	89 c3                	mov    %eax,%ebx
  800e5f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e62:	83 ec 08             	sub    $0x8,%esp
  800e65:	56                   	push   %esi
  800e66:	6a 00                	push   $0x0
  800e68:	e8 00 fd ff ff       	call   800b6d <sys_page_unmap>
	return r;
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	89 d8                	mov    %ebx,%eax
}
  800e72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e82:	50                   	push   %eax
  800e83:	ff 75 08             	pushl  0x8(%ebp)
  800e86:	e8 c4 fe ff ff       	call   800d4f <fd_lookup>
  800e8b:	83 c4 08             	add    $0x8,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	78 10                	js     800ea2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800e92:	83 ec 08             	sub    $0x8,%esp
  800e95:	6a 01                	push   $0x1
  800e97:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9a:	e8 59 ff ff ff       	call   800df8 <fd_close>
  800e9f:	83 c4 10             	add    $0x10,%esp
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <close_all>:

void
close_all(void)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	53                   	push   %ebx
  800ea8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800eab:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800eb0:	83 ec 0c             	sub    $0xc,%esp
  800eb3:	53                   	push   %ebx
  800eb4:	e8 c0 ff ff ff       	call   800e79 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800eb9:	83 c3 01             	add    $0x1,%ebx
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	83 fb 20             	cmp    $0x20,%ebx
  800ec2:	75 ec                	jne    800eb0 <close_all+0xc>
		close(i);
}
  800ec4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    

00800ec9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 2c             	sub    $0x2c,%esp
  800ed2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ed5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ed8:	50                   	push   %eax
  800ed9:	ff 75 08             	pushl  0x8(%ebp)
  800edc:	e8 6e fe ff ff       	call   800d4f <fd_lookup>
  800ee1:	83 c4 08             	add    $0x8,%esp
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	0f 88 c1 00 00 00    	js     800fad <dup+0xe4>
		return r;
	close(newfdnum);
  800eec:	83 ec 0c             	sub    $0xc,%esp
  800eef:	56                   	push   %esi
  800ef0:	e8 84 ff ff ff       	call   800e79 <close>

	newfd = INDEX2FD(newfdnum);
  800ef5:	89 f3                	mov    %esi,%ebx
  800ef7:	c1 e3 0c             	shl    $0xc,%ebx
  800efa:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f00:	83 c4 04             	add    $0x4,%esp
  800f03:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f06:	e8 de fd ff ff       	call   800ce9 <fd2data>
  800f0b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f0d:	89 1c 24             	mov    %ebx,(%esp)
  800f10:	e8 d4 fd ff ff       	call   800ce9 <fd2data>
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f1b:	89 f8                	mov    %edi,%eax
  800f1d:	c1 e8 16             	shr    $0x16,%eax
  800f20:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f27:	a8 01                	test   $0x1,%al
  800f29:	74 37                	je     800f62 <dup+0x99>
  800f2b:	89 f8                	mov    %edi,%eax
  800f2d:	c1 e8 0c             	shr    $0xc,%eax
  800f30:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f37:	f6 c2 01             	test   $0x1,%dl
  800f3a:	74 26                	je     800f62 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f3c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f43:	83 ec 0c             	sub    $0xc,%esp
  800f46:	25 07 0e 00 00       	and    $0xe07,%eax
  800f4b:	50                   	push   %eax
  800f4c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f4f:	6a 00                	push   $0x0
  800f51:	57                   	push   %edi
  800f52:	6a 00                	push   $0x0
  800f54:	e8 d2 fb ff ff       	call   800b2b <sys_page_map>
  800f59:	89 c7                	mov    %eax,%edi
  800f5b:	83 c4 20             	add    $0x20,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	78 2e                	js     800f90 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f65:	89 d0                	mov    %edx,%eax
  800f67:	c1 e8 0c             	shr    $0xc,%eax
  800f6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f71:	83 ec 0c             	sub    $0xc,%esp
  800f74:	25 07 0e 00 00       	and    $0xe07,%eax
  800f79:	50                   	push   %eax
  800f7a:	53                   	push   %ebx
  800f7b:	6a 00                	push   $0x0
  800f7d:	52                   	push   %edx
  800f7e:	6a 00                	push   $0x0
  800f80:	e8 a6 fb ff ff       	call   800b2b <sys_page_map>
  800f85:	89 c7                	mov    %eax,%edi
  800f87:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f8a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f8c:	85 ff                	test   %edi,%edi
  800f8e:	79 1d                	jns    800fad <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800f90:	83 ec 08             	sub    $0x8,%esp
  800f93:	53                   	push   %ebx
  800f94:	6a 00                	push   $0x0
  800f96:	e8 d2 fb ff ff       	call   800b6d <sys_page_unmap>
	sys_page_unmap(0, nva);
  800f9b:	83 c4 08             	add    $0x8,%esp
  800f9e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa1:	6a 00                	push   $0x0
  800fa3:	e8 c5 fb ff ff       	call   800b6d <sys_page_unmap>
	return r;
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	89 f8                	mov    %edi,%eax
}
  800fad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    

00800fb5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 14             	sub    $0x14,%esp
  800fbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc2:	50                   	push   %eax
  800fc3:	53                   	push   %ebx
  800fc4:	e8 86 fd ff ff       	call   800d4f <fd_lookup>
  800fc9:	83 c4 08             	add    $0x8,%esp
  800fcc:	89 c2                	mov    %eax,%edx
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 6d                	js     80103f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fd2:	83 ec 08             	sub    $0x8,%esp
  800fd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd8:	50                   	push   %eax
  800fd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fdc:	ff 30                	pushl  (%eax)
  800fde:	e8 c2 fd ff ff       	call   800da5 <dev_lookup>
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	78 4c                	js     801036 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800fea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fed:	8b 42 08             	mov    0x8(%edx),%eax
  800ff0:	83 e0 03             	and    $0x3,%eax
  800ff3:	83 f8 01             	cmp    $0x1,%eax
  800ff6:	75 21                	jne    801019 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ff8:	a1 04 40 80 00       	mov    0x804004,%eax
  800ffd:	8b 40 48             	mov    0x48(%eax),%eax
  801000:	83 ec 04             	sub    $0x4,%esp
  801003:	53                   	push   %ebx
  801004:	50                   	push   %eax
  801005:	68 cd 21 80 00       	push   $0x8021cd
  80100a:	e8 51 f1 ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  80100f:	83 c4 10             	add    $0x10,%esp
  801012:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801017:	eb 26                	jmp    80103f <read+0x8a>
	}
	if (!dev->dev_read)
  801019:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101c:	8b 40 08             	mov    0x8(%eax),%eax
  80101f:	85 c0                	test   %eax,%eax
  801021:	74 17                	je     80103a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	ff 75 10             	pushl  0x10(%ebp)
  801029:	ff 75 0c             	pushl  0xc(%ebp)
  80102c:	52                   	push   %edx
  80102d:	ff d0                	call   *%eax
  80102f:	89 c2                	mov    %eax,%edx
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	eb 09                	jmp    80103f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801036:	89 c2                	mov    %eax,%edx
  801038:	eb 05                	jmp    80103f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80103a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80103f:	89 d0                	mov    %edx,%eax
  801041:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801044:	c9                   	leave  
  801045:	c3                   	ret    

00801046 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	57                   	push   %edi
  80104a:	56                   	push   %esi
  80104b:	53                   	push   %ebx
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801052:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801055:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105a:	eb 21                	jmp    80107d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	89 f0                	mov    %esi,%eax
  801061:	29 d8                	sub    %ebx,%eax
  801063:	50                   	push   %eax
  801064:	89 d8                	mov    %ebx,%eax
  801066:	03 45 0c             	add    0xc(%ebp),%eax
  801069:	50                   	push   %eax
  80106a:	57                   	push   %edi
  80106b:	e8 45 ff ff ff       	call   800fb5 <read>
		if (m < 0)
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	78 10                	js     801087 <readn+0x41>
			return m;
		if (m == 0)
  801077:	85 c0                	test   %eax,%eax
  801079:	74 0a                	je     801085 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80107b:	01 c3                	add    %eax,%ebx
  80107d:	39 f3                	cmp    %esi,%ebx
  80107f:	72 db                	jb     80105c <readn+0x16>
  801081:	89 d8                	mov    %ebx,%eax
  801083:	eb 02                	jmp    801087 <readn+0x41>
  801085:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801087:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108a:	5b                   	pop    %ebx
  80108b:	5e                   	pop    %esi
  80108c:	5f                   	pop    %edi
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    

0080108f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	53                   	push   %ebx
  801093:	83 ec 14             	sub    $0x14,%esp
  801096:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801099:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80109c:	50                   	push   %eax
  80109d:	53                   	push   %ebx
  80109e:	e8 ac fc ff ff       	call   800d4f <fd_lookup>
  8010a3:	83 c4 08             	add    $0x8,%esp
  8010a6:	89 c2                	mov    %eax,%edx
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	78 68                	js     801114 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ac:	83 ec 08             	sub    $0x8,%esp
  8010af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b2:	50                   	push   %eax
  8010b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b6:	ff 30                	pushl  (%eax)
  8010b8:	e8 e8 fc ff ff       	call   800da5 <dev_lookup>
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	78 47                	js     80110b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010cb:	75 21                	jne    8010ee <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d2:	8b 40 48             	mov    0x48(%eax),%eax
  8010d5:	83 ec 04             	sub    $0x4,%esp
  8010d8:	53                   	push   %ebx
  8010d9:	50                   	push   %eax
  8010da:	68 e9 21 80 00       	push   $0x8021e9
  8010df:	e8 7c f0 ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010ec:	eb 26                	jmp    801114 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8010f4:	85 d2                	test   %edx,%edx
  8010f6:	74 17                	je     80110f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010f8:	83 ec 04             	sub    $0x4,%esp
  8010fb:	ff 75 10             	pushl  0x10(%ebp)
  8010fe:	ff 75 0c             	pushl  0xc(%ebp)
  801101:	50                   	push   %eax
  801102:	ff d2                	call   *%edx
  801104:	89 c2                	mov    %eax,%edx
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	eb 09                	jmp    801114 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110b:	89 c2                	mov    %eax,%edx
  80110d:	eb 05                	jmp    801114 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80110f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801114:	89 d0                	mov    %edx,%eax
  801116:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <seek>:

int
seek(int fdnum, off_t offset)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801121:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801124:	50                   	push   %eax
  801125:	ff 75 08             	pushl  0x8(%ebp)
  801128:	e8 22 fc ff ff       	call   800d4f <fd_lookup>
  80112d:	83 c4 08             	add    $0x8,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	78 0e                	js     801142 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801134:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801137:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80113d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801142:	c9                   	leave  
  801143:	c3                   	ret    

00801144 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	53                   	push   %ebx
  801148:	83 ec 14             	sub    $0x14,%esp
  80114b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80114e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	53                   	push   %ebx
  801153:	e8 f7 fb ff ff       	call   800d4f <fd_lookup>
  801158:	83 c4 08             	add    $0x8,%esp
  80115b:	89 c2                	mov    %eax,%edx
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 65                	js     8011c6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801161:	83 ec 08             	sub    $0x8,%esp
  801164:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801167:	50                   	push   %eax
  801168:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116b:	ff 30                	pushl  (%eax)
  80116d:	e8 33 fc ff ff       	call   800da5 <dev_lookup>
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	85 c0                	test   %eax,%eax
  801177:	78 44                	js     8011bd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801179:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801180:	75 21                	jne    8011a3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801182:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801187:	8b 40 48             	mov    0x48(%eax),%eax
  80118a:	83 ec 04             	sub    $0x4,%esp
  80118d:	53                   	push   %ebx
  80118e:	50                   	push   %eax
  80118f:	68 ac 21 80 00       	push   $0x8021ac
  801194:	e8 c7 ef ff ff       	call   800160 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a1:	eb 23                	jmp    8011c6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011a6:	8b 52 18             	mov    0x18(%edx),%edx
  8011a9:	85 d2                	test   %edx,%edx
  8011ab:	74 14                	je     8011c1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	ff 75 0c             	pushl  0xc(%ebp)
  8011b3:	50                   	push   %eax
  8011b4:	ff d2                	call   *%edx
  8011b6:	89 c2                	mov    %eax,%edx
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	eb 09                	jmp    8011c6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bd:	89 c2                	mov    %eax,%edx
  8011bf:	eb 05                	jmp    8011c6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011c6:	89 d0                	mov    %edx,%eax
  8011c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 14             	sub    $0x14,%esp
  8011d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011da:	50                   	push   %eax
  8011db:	ff 75 08             	pushl  0x8(%ebp)
  8011de:	e8 6c fb ff ff       	call   800d4f <fd_lookup>
  8011e3:	83 c4 08             	add    $0x8,%esp
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 58                	js     801244 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ec:	83 ec 08             	sub    $0x8,%esp
  8011ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f2:	50                   	push   %eax
  8011f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f6:	ff 30                	pushl  (%eax)
  8011f8:	e8 a8 fb ff ff       	call   800da5 <dev_lookup>
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	78 37                	js     80123b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801204:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801207:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80120b:	74 32                	je     80123f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80120d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801210:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801217:	00 00 00 
	stat->st_isdir = 0;
  80121a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801221:	00 00 00 
	stat->st_dev = dev;
  801224:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	53                   	push   %ebx
  80122e:	ff 75 f0             	pushl  -0x10(%ebp)
  801231:	ff 50 14             	call   *0x14(%eax)
  801234:	89 c2                	mov    %eax,%edx
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	eb 09                	jmp    801244 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123b:	89 c2                	mov    %eax,%edx
  80123d:	eb 05                	jmp    801244 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80123f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801244:	89 d0                	mov    %edx,%eax
  801246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	56                   	push   %esi
  80124f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	6a 00                	push   $0x0
  801255:	ff 75 08             	pushl  0x8(%ebp)
  801258:	e8 2c 02 00 00       	call   801489 <open>
  80125d:	89 c3                	mov    %eax,%ebx
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	85 c0                	test   %eax,%eax
  801264:	78 1b                	js     801281 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801266:	83 ec 08             	sub    $0x8,%esp
  801269:	ff 75 0c             	pushl  0xc(%ebp)
  80126c:	50                   	push   %eax
  80126d:	e8 5b ff ff ff       	call   8011cd <fstat>
  801272:	89 c6                	mov    %eax,%esi
	close(fd);
  801274:	89 1c 24             	mov    %ebx,(%esp)
  801277:	e8 fd fb ff ff       	call   800e79 <close>
	return r;
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	89 f0                	mov    %esi,%eax
}
  801281:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801284:	5b                   	pop    %ebx
  801285:	5e                   	pop    %esi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	89 c6                	mov    %eax,%esi
  80128f:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  801291:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801298:	75 12                	jne    8012ac <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  80129a:	83 ec 0c             	sub    $0xc,%esp
  80129d:	6a 01                	push   $0x1
  80129f:	e8 61 08 00 00       	call   801b05 <ipc_find_env>
  8012a4:	a3 00 40 80 00       	mov    %eax,0x804000
  8012a9:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012ac:	6a 07                	push   $0x7
  8012ae:	68 00 50 80 00       	push   $0x805000
  8012b3:	56                   	push   %esi
  8012b4:	ff 35 00 40 80 00    	pushl  0x804000
  8012ba:	e8 f2 07 00 00       	call   801ab1 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  8012bf:	83 c4 0c             	add    $0xc,%esp
  8012c2:	6a 00                	push   $0x0
  8012c4:	53                   	push   %ebx
  8012c5:	6a 00                	push   $0x0
  8012c7:	e8 86 07 00 00       	call   801a52 <ipc_recv>
}
  8012cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012cf:	5b                   	pop    %ebx
  8012d0:	5e                   	pop    %esi
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8012df:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  8012e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e7:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  8012ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f1:	b8 02 00 00 00       	mov    $0x2,%eax
  8012f6:	e8 8d ff ff ff       	call   801288 <fsipc>
}
  8012fb:	c9                   	leave  
  8012fc:	c3                   	ret    

008012fd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801303:	8b 45 08             	mov    0x8(%ebp),%eax
  801306:	8b 40 0c             	mov    0xc(%eax),%eax
  801309:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  80130e:	ba 00 00 00 00       	mov    $0x0,%edx
  801313:	b8 06 00 00 00       	mov    $0x6,%eax
  801318:	e8 6b ff ff ff       	call   801288 <fsipc>
}
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	53                   	push   %ebx
  801323:	83 ec 04             	sub    $0x4,%esp
  801326:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801329:	8b 45 08             	mov    0x8(%ebp),%eax
  80132c:	8b 40 0c             	mov    0xc(%eax),%eax
  80132f:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801334:	ba 00 00 00 00       	mov    $0x0,%edx
  801339:	b8 05 00 00 00       	mov    $0x5,%eax
  80133e:	e8 45 ff ff ff       	call   801288 <fsipc>
  801343:	85 c0                	test   %eax,%eax
  801345:	78 2c                	js     801373 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	68 00 50 80 00       	push   $0x805000
  80134f:	53                   	push   %ebx
  801350:	e8 90 f3 ff ff       	call   8006e5 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  801355:	a1 80 50 80 00       	mov    0x805080,%eax
  80135a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801360:	a1 84 50 80 00       	mov    0x805084,%eax
  801365:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	53                   	push   %ebx
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  801382:	8b 45 08             	mov    0x8(%ebp),%eax
  801385:	8b 40 0c             	mov    0xc(%eax),%eax
  801388:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  80138d:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  801393:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801399:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  80139e:	0f 46 c3             	cmovbe %ebx,%eax
  8013a1:	50                   	push   %eax
  8013a2:	ff 75 0c             	pushl  0xc(%ebp)
  8013a5:	68 08 50 80 00       	push   $0x805008
  8013aa:	e8 c8 f4 ff ff       	call   800877 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  8013af:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b4:	b8 04 00 00 00       	mov    $0x4,%eax
  8013b9:	e8 ca fe ff ff       	call   801288 <fsipc>
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 3d                	js     801402 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  8013c5:	39 c3                	cmp    %eax,%ebx
  8013c7:	73 19                	jae    8013e2 <devfile_write+0x6a>
  8013c9:	68 18 22 80 00       	push   $0x802218
  8013ce:	68 1f 22 80 00       	push   $0x80221f
  8013d3:	68 9a 00 00 00       	push   $0x9a
  8013d8:	68 34 22 80 00       	push   $0x802234
  8013dd:	e8 2a 06 00 00       	call   801a0c <_panic>
	   assert (r <= bytes_written);
  8013e2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013e7:	7e 19                	jle    801402 <devfile_write+0x8a>
  8013e9:	68 3f 22 80 00       	push   $0x80223f
  8013ee:	68 1f 22 80 00       	push   $0x80221f
  8013f3:	68 9b 00 00 00       	push   $0x9b
  8013f8:	68 34 22 80 00       	push   $0x802234
  8013fd:	e8 0a 06 00 00       	call   801a0c <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801402:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	56                   	push   %esi
  80140b:	53                   	push   %ebx
  80140c:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  80140f:	8b 45 08             	mov    0x8(%ebp),%eax
  801412:	8b 40 0c             	mov    0xc(%eax),%eax
  801415:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  80141a:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801420:	ba 00 00 00 00       	mov    $0x0,%edx
  801425:	b8 03 00 00 00       	mov    $0x3,%eax
  80142a:	e8 59 fe ff ff       	call   801288 <fsipc>
  80142f:	89 c3                	mov    %eax,%ebx
  801431:	85 c0                	test   %eax,%eax
  801433:	78 4b                	js     801480 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  801435:	39 c6                	cmp    %eax,%esi
  801437:	73 16                	jae    80144f <devfile_read+0x48>
  801439:	68 18 22 80 00       	push   $0x802218
  80143e:	68 1f 22 80 00       	push   $0x80221f
  801443:	6a 7c                	push   $0x7c
  801445:	68 34 22 80 00       	push   $0x802234
  80144a:	e8 bd 05 00 00       	call   801a0c <_panic>
	   assert(r <= PGSIZE);
  80144f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801454:	7e 16                	jle    80146c <devfile_read+0x65>
  801456:	68 52 22 80 00       	push   $0x802252
  80145b:	68 1f 22 80 00       	push   $0x80221f
  801460:	6a 7d                	push   $0x7d
  801462:	68 34 22 80 00       	push   $0x802234
  801467:	e8 a0 05 00 00       	call   801a0c <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	50                   	push   %eax
  801470:	68 00 50 80 00       	push   $0x805000
  801475:	ff 75 0c             	pushl  0xc(%ebp)
  801478:	e8 fa f3 ff ff       	call   800877 <memmove>
	   return r;
  80147d:	83 c4 10             	add    $0x10,%esp
}
  801480:	89 d8                	mov    %ebx,%eax
  801482:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801485:	5b                   	pop    %ebx
  801486:	5e                   	pop    %esi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    

00801489 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	53                   	push   %ebx
  80148d:	83 ec 20             	sub    $0x20,%esp
  801490:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  801493:	53                   	push   %ebx
  801494:	e8 13 f2 ff ff       	call   8006ac <strlen>
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014a1:	7f 67                	jg     80150a <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8014a3:	83 ec 0c             	sub    $0xc,%esp
  8014a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a9:	50                   	push   %eax
  8014aa:	e8 51 f8 ff ff       	call   800d00 <fd_alloc>
  8014af:	83 c4 10             	add    $0x10,%esp
			 return r;
  8014b2:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 57                	js     80150f <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	53                   	push   %ebx
  8014bc:	68 00 50 80 00       	push   $0x805000
  8014c1:	e8 1f f2 ff ff       	call   8006e5 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  8014c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c9:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d6:	e8 ad fd ff ff       	call   801288 <fsipc>
  8014db:	89 c3                	mov    %eax,%ebx
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	79 14                	jns    8014f8 <open+0x6f>
			 fd_close(fd, 0);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	6a 00                	push   $0x0
  8014e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ec:	e8 07 f9 ff ff       	call   800df8 <fd_close>
			 return r;
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	89 da                	mov    %ebx,%edx
  8014f6:	eb 17                	jmp    80150f <open+0x86>
	   }

	   return fd2num(fd);
  8014f8:	83 ec 0c             	sub    $0xc,%esp
  8014fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fe:	e8 d6 f7 ff ff       	call   800cd9 <fd2num>
  801503:	89 c2                	mov    %eax,%edx
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	eb 05                	jmp    80150f <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  80150a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  80150f:	89 d0                	mov    %edx,%eax
  801511:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  80151c:	ba 00 00 00 00       	mov    $0x0,%edx
  801521:	b8 08 00 00 00       	mov    $0x8,%eax
  801526:	e8 5d fd ff ff       	call   801288 <fsipc>
}
  80152b:	c9                   	leave  
  80152c:	c3                   	ret    

0080152d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	56                   	push   %esi
  801531:	53                   	push   %ebx
  801532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801535:	83 ec 0c             	sub    $0xc,%esp
  801538:	ff 75 08             	pushl  0x8(%ebp)
  80153b:	e8 a9 f7 ff ff       	call   800ce9 <fd2data>
  801540:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801542:	83 c4 08             	add    $0x8,%esp
  801545:	68 5e 22 80 00       	push   $0x80225e
  80154a:	53                   	push   %ebx
  80154b:	e8 95 f1 ff ff       	call   8006e5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801550:	8b 46 04             	mov    0x4(%esi),%eax
  801553:	2b 06                	sub    (%esi),%eax
  801555:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80155b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801562:	00 00 00 
	stat->st_dev = &devpipe;
  801565:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80156c:	30 80 00 
	return 0;
}
  80156f:	b8 00 00 00 00       	mov    $0x0,%eax
  801574:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801577:	5b                   	pop    %ebx
  801578:	5e                   	pop    %esi
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    

0080157b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	53                   	push   %ebx
  80157f:	83 ec 0c             	sub    $0xc,%esp
  801582:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801585:	53                   	push   %ebx
  801586:	6a 00                	push   $0x0
  801588:	e8 e0 f5 ff ff       	call   800b6d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80158d:	89 1c 24             	mov    %ebx,(%esp)
  801590:	e8 54 f7 ff ff       	call   800ce9 <fd2data>
  801595:	83 c4 08             	add    $0x8,%esp
  801598:	50                   	push   %eax
  801599:	6a 00                	push   $0x0
  80159b:	e8 cd f5 ff ff       	call   800b6d <sys_page_unmap>
}
  8015a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	57                   	push   %edi
  8015a9:	56                   	push   %esi
  8015aa:	53                   	push   %ebx
  8015ab:	83 ec 1c             	sub    $0x1c,%esp
  8015ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015b1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c1:	e8 78 05 00 00       	call   801b3e <pageref>
  8015c6:	89 c3                	mov    %eax,%ebx
  8015c8:	89 3c 24             	mov    %edi,(%esp)
  8015cb:	e8 6e 05 00 00       	call   801b3e <pageref>
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	39 c3                	cmp    %eax,%ebx
  8015d5:	0f 94 c1             	sete   %cl
  8015d8:	0f b6 c9             	movzbl %cl,%ecx
  8015db:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015de:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015e4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015e7:	39 ce                	cmp    %ecx,%esi
  8015e9:	74 1b                	je     801606 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015eb:	39 c3                	cmp    %eax,%ebx
  8015ed:	75 c4                	jne    8015b3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015ef:	8b 42 58             	mov    0x58(%edx),%eax
  8015f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f5:	50                   	push   %eax
  8015f6:	56                   	push   %esi
  8015f7:	68 65 22 80 00       	push   $0x802265
  8015fc:	e8 5f eb ff ff       	call   800160 <cprintf>
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	eb ad                	jmp    8015b3 <_pipeisclosed+0xe>
	}
}
  801606:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801609:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160c:	5b                   	pop    %ebx
  80160d:	5e                   	pop    %esi
  80160e:	5f                   	pop    %edi
  80160f:	5d                   	pop    %ebp
  801610:	c3                   	ret    

00801611 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	57                   	push   %edi
  801615:	56                   	push   %esi
  801616:	53                   	push   %ebx
  801617:	83 ec 28             	sub    $0x28,%esp
  80161a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80161d:	56                   	push   %esi
  80161e:	e8 c6 f6 ff ff       	call   800ce9 <fd2data>
  801623:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	bf 00 00 00 00       	mov    $0x0,%edi
  80162d:	eb 4b                	jmp    80167a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80162f:	89 da                	mov    %ebx,%edx
  801631:	89 f0                	mov    %esi,%eax
  801633:	e8 6d ff ff ff       	call   8015a5 <_pipeisclosed>
  801638:	85 c0                	test   %eax,%eax
  80163a:	75 48                	jne    801684 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80163c:	e8 88 f4 ff ff       	call   800ac9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801641:	8b 43 04             	mov    0x4(%ebx),%eax
  801644:	8b 0b                	mov    (%ebx),%ecx
  801646:	8d 51 20             	lea    0x20(%ecx),%edx
  801649:	39 d0                	cmp    %edx,%eax
  80164b:	73 e2                	jae    80162f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80164d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801650:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801654:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801657:	89 c2                	mov    %eax,%edx
  801659:	c1 fa 1f             	sar    $0x1f,%edx
  80165c:	89 d1                	mov    %edx,%ecx
  80165e:	c1 e9 1b             	shr    $0x1b,%ecx
  801661:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801664:	83 e2 1f             	and    $0x1f,%edx
  801667:	29 ca                	sub    %ecx,%edx
  801669:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80166d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801671:	83 c0 01             	add    $0x1,%eax
  801674:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801677:	83 c7 01             	add    $0x1,%edi
  80167a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80167d:	75 c2                	jne    801641 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80167f:	8b 45 10             	mov    0x10(%ebp),%eax
  801682:	eb 05                	jmp    801689 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801684:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801689:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168c:	5b                   	pop    %ebx
  80168d:	5e                   	pop    %esi
  80168e:	5f                   	pop    %edi
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    

00801691 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	57                   	push   %edi
  801695:	56                   	push   %esi
  801696:	53                   	push   %ebx
  801697:	83 ec 18             	sub    $0x18,%esp
  80169a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80169d:	57                   	push   %edi
  80169e:	e8 46 f6 ff ff       	call   800ce9 <fd2data>
  8016a3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ad:	eb 3d                	jmp    8016ec <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016af:	85 db                	test   %ebx,%ebx
  8016b1:	74 04                	je     8016b7 <devpipe_read+0x26>
				return i;
  8016b3:	89 d8                	mov    %ebx,%eax
  8016b5:	eb 44                	jmp    8016fb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016b7:	89 f2                	mov    %esi,%edx
  8016b9:	89 f8                	mov    %edi,%eax
  8016bb:	e8 e5 fe ff ff       	call   8015a5 <_pipeisclosed>
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	75 32                	jne    8016f6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016c4:	e8 00 f4 ff ff       	call   800ac9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016c9:	8b 06                	mov    (%esi),%eax
  8016cb:	3b 46 04             	cmp    0x4(%esi),%eax
  8016ce:	74 df                	je     8016af <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016d0:	99                   	cltd   
  8016d1:	c1 ea 1b             	shr    $0x1b,%edx
  8016d4:	01 d0                	add    %edx,%eax
  8016d6:	83 e0 1f             	and    $0x1f,%eax
  8016d9:	29 d0                	sub    %edx,%eax
  8016db:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016e6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016e9:	83 c3 01             	add    $0x1,%ebx
  8016ec:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016ef:	75 d8                	jne    8016c9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8016f4:	eb 05                	jmp    8016fb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016f6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fe:	5b                   	pop    %ebx
  8016ff:	5e                   	pop    %esi
  801700:	5f                   	pop    %edi
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
  801708:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80170b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170e:	50                   	push   %eax
  80170f:	e8 ec f5 ff ff       	call   800d00 <fd_alloc>
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	89 c2                	mov    %eax,%edx
  801719:	85 c0                	test   %eax,%eax
  80171b:	0f 88 2c 01 00 00    	js     80184d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801721:	83 ec 04             	sub    $0x4,%esp
  801724:	68 07 04 00 00       	push   $0x407
  801729:	ff 75 f4             	pushl  -0xc(%ebp)
  80172c:	6a 00                	push   $0x0
  80172e:	e8 b5 f3 ff ff       	call   800ae8 <sys_page_alloc>
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	89 c2                	mov    %eax,%edx
  801738:	85 c0                	test   %eax,%eax
  80173a:	0f 88 0d 01 00 00    	js     80184d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801740:	83 ec 0c             	sub    $0xc,%esp
  801743:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801746:	50                   	push   %eax
  801747:	e8 b4 f5 ff ff       	call   800d00 <fd_alloc>
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	0f 88 e2 00 00 00    	js     80183b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801759:	83 ec 04             	sub    $0x4,%esp
  80175c:	68 07 04 00 00       	push   $0x407
  801761:	ff 75 f0             	pushl  -0x10(%ebp)
  801764:	6a 00                	push   $0x0
  801766:	e8 7d f3 ff ff       	call   800ae8 <sys_page_alloc>
  80176b:	89 c3                	mov    %eax,%ebx
  80176d:	83 c4 10             	add    $0x10,%esp
  801770:	85 c0                	test   %eax,%eax
  801772:	0f 88 c3 00 00 00    	js     80183b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801778:	83 ec 0c             	sub    $0xc,%esp
  80177b:	ff 75 f4             	pushl  -0xc(%ebp)
  80177e:	e8 66 f5 ff ff       	call   800ce9 <fd2data>
  801783:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801785:	83 c4 0c             	add    $0xc,%esp
  801788:	68 07 04 00 00       	push   $0x407
  80178d:	50                   	push   %eax
  80178e:	6a 00                	push   $0x0
  801790:	e8 53 f3 ff ff       	call   800ae8 <sys_page_alloc>
  801795:	89 c3                	mov    %eax,%ebx
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	85 c0                	test   %eax,%eax
  80179c:	0f 88 89 00 00 00    	js     80182b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8017a8:	e8 3c f5 ff ff       	call   800ce9 <fd2data>
  8017ad:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017b4:	50                   	push   %eax
  8017b5:	6a 00                	push   $0x0
  8017b7:	56                   	push   %esi
  8017b8:	6a 00                	push   $0x0
  8017ba:	e8 6c f3 ff ff       	call   800b2b <sys_page_map>
  8017bf:	89 c3                	mov    %eax,%ebx
  8017c1:	83 c4 20             	add    $0x20,%esp
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	78 55                	js     80181d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017c8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017dd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017eb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017f2:	83 ec 0c             	sub    $0xc,%esp
  8017f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f8:	e8 dc f4 ff ff       	call   800cd9 <fd2num>
  8017fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801800:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801802:	83 c4 04             	add    $0x4,%esp
  801805:	ff 75 f0             	pushl  -0x10(%ebp)
  801808:	e8 cc f4 ff ff       	call   800cd9 <fd2num>
  80180d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801810:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	ba 00 00 00 00       	mov    $0x0,%edx
  80181b:	eb 30                	jmp    80184d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80181d:	83 ec 08             	sub    $0x8,%esp
  801820:	56                   	push   %esi
  801821:	6a 00                	push   $0x0
  801823:	e8 45 f3 ff ff       	call   800b6d <sys_page_unmap>
  801828:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	ff 75 f0             	pushl  -0x10(%ebp)
  801831:	6a 00                	push   $0x0
  801833:	e8 35 f3 ff ff       	call   800b6d <sys_page_unmap>
  801838:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80183b:	83 ec 08             	sub    $0x8,%esp
  80183e:	ff 75 f4             	pushl  -0xc(%ebp)
  801841:	6a 00                	push   $0x0
  801843:	e8 25 f3 ff ff       	call   800b6d <sys_page_unmap>
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80184d:	89 d0                	mov    %edx,%eax
  80184f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801852:	5b                   	pop    %ebx
  801853:	5e                   	pop    %esi
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    

00801856 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80185c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185f:	50                   	push   %eax
  801860:	ff 75 08             	pushl  0x8(%ebp)
  801863:	e8 e7 f4 ff ff       	call   800d4f <fd_lookup>
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	85 c0                	test   %eax,%eax
  80186d:	78 18                	js     801887 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	ff 75 f4             	pushl  -0xc(%ebp)
  801875:	e8 6f f4 ff ff       	call   800ce9 <fd2data>
	return _pipeisclosed(fd, p);
  80187a:	89 c2                	mov    %eax,%edx
  80187c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187f:	e8 21 fd ff ff       	call   8015a5 <_pipeisclosed>
  801884:	83 c4 10             	add    $0x10,%esp
}
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80188c:	b8 00 00 00 00       	mov    $0x0,%eax
  801891:	5d                   	pop    %ebp
  801892:	c3                   	ret    

00801893 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801899:	68 7d 22 80 00       	push   $0x80227d
  80189e:	ff 75 0c             	pushl  0xc(%ebp)
  8018a1:	e8 3f ee ff ff       	call   8006e5 <strcpy>
	return 0;
}
  8018a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ab:	c9                   	leave  
  8018ac:	c3                   	ret    

008018ad <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	57                   	push   %edi
  8018b1:	56                   	push   %esi
  8018b2:	53                   	push   %ebx
  8018b3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018b9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018be:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c4:	eb 2d                	jmp    8018f3 <devcons_write+0x46>
		m = n - tot;
  8018c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018c9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018cb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018ce:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018d3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018d6:	83 ec 04             	sub    $0x4,%esp
  8018d9:	53                   	push   %ebx
  8018da:	03 45 0c             	add    0xc(%ebp),%eax
  8018dd:	50                   	push   %eax
  8018de:	57                   	push   %edi
  8018df:	e8 93 ef ff ff       	call   800877 <memmove>
		sys_cputs(buf, m);
  8018e4:	83 c4 08             	add    $0x8,%esp
  8018e7:	53                   	push   %ebx
  8018e8:	57                   	push   %edi
  8018e9:	e8 3e f1 ff ff       	call   800a2c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018ee:	01 de                	add    %ebx,%esi
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	89 f0                	mov    %esi,%eax
  8018f5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018f8:	72 cc                	jb     8018c6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018fd:	5b                   	pop    %ebx
  8018fe:	5e                   	pop    %esi
  8018ff:	5f                   	pop    %edi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    

00801902 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	83 ec 08             	sub    $0x8,%esp
  801908:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80190d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801911:	74 2a                	je     80193d <devcons_read+0x3b>
  801913:	eb 05                	jmp    80191a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801915:	e8 af f1 ff ff       	call   800ac9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80191a:	e8 2b f1 ff ff       	call   800a4a <sys_cgetc>
  80191f:	85 c0                	test   %eax,%eax
  801921:	74 f2                	je     801915 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801923:	85 c0                	test   %eax,%eax
  801925:	78 16                	js     80193d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801927:	83 f8 04             	cmp    $0x4,%eax
  80192a:	74 0c                	je     801938 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80192c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192f:	88 02                	mov    %al,(%edx)
	return 1;
  801931:	b8 01 00 00 00       	mov    $0x1,%eax
  801936:	eb 05                	jmp    80193d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801938:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80193d:	c9                   	leave  
  80193e:	c3                   	ret    

0080193f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801945:	8b 45 08             	mov    0x8(%ebp),%eax
  801948:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80194b:	6a 01                	push   $0x1
  80194d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801950:	50                   	push   %eax
  801951:	e8 d6 f0 ff ff       	call   800a2c <sys_cputs>
}
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <getchar>:

int
getchar(void)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801961:	6a 01                	push   $0x1
  801963:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801966:	50                   	push   %eax
  801967:	6a 00                	push   $0x0
  801969:	e8 47 f6 ff ff       	call   800fb5 <read>
	if (r < 0)
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	85 c0                	test   %eax,%eax
  801973:	78 0f                	js     801984 <getchar+0x29>
		return r;
	if (r < 1)
  801975:	85 c0                	test   %eax,%eax
  801977:	7e 06                	jle    80197f <getchar+0x24>
		return -E_EOF;
	return c;
  801979:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80197d:	eb 05                	jmp    801984 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80197f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801984:	c9                   	leave  
  801985:	c3                   	ret    

00801986 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80198c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198f:	50                   	push   %eax
  801990:	ff 75 08             	pushl  0x8(%ebp)
  801993:	e8 b7 f3 ff ff       	call   800d4f <fd_lookup>
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 11                	js     8019b0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80199f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019a8:	39 10                	cmp    %edx,(%eax)
  8019aa:	0f 94 c0             	sete   %al
  8019ad:	0f b6 c0             	movzbl %al,%eax
}
  8019b0:	c9                   	leave  
  8019b1:	c3                   	ret    

008019b2 <opencons>:

int
opencons(void)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bb:	50                   	push   %eax
  8019bc:	e8 3f f3 ff ff       	call   800d00 <fd_alloc>
  8019c1:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	78 3e                	js     801a08 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019ca:	83 ec 04             	sub    $0x4,%esp
  8019cd:	68 07 04 00 00       	push   $0x407
  8019d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d5:	6a 00                	push   $0x0
  8019d7:	e8 0c f1 ff ff       	call   800ae8 <sys_page_alloc>
  8019dc:	83 c4 10             	add    $0x10,%esp
		return r;
  8019df:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	78 23                	js     801a08 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019e5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ee:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	50                   	push   %eax
  8019fe:	e8 d6 f2 ff ff       	call   800cd9 <fd2num>
  801a03:	89 c2                	mov    %eax,%edx
  801a05:	83 c4 10             	add    $0x10,%esp
}
  801a08:	89 d0                	mov    %edx,%eax
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a11:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a14:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a1a:	e8 8b f0 ff ff       	call   800aaa <sys_getenvid>
  801a1f:	83 ec 0c             	sub    $0xc,%esp
  801a22:	ff 75 0c             	pushl  0xc(%ebp)
  801a25:	ff 75 08             	pushl  0x8(%ebp)
  801a28:	56                   	push   %esi
  801a29:	50                   	push   %eax
  801a2a:	68 8c 22 80 00       	push   $0x80228c
  801a2f:	e8 2c e7 ff ff       	call   800160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a34:	83 c4 18             	add    $0x18,%esp
  801a37:	53                   	push   %ebx
  801a38:	ff 75 10             	pushl  0x10(%ebp)
  801a3b:	e8 cf e6 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  801a40:	c7 04 24 76 22 80 00 	movl   $0x802276,(%esp)
  801a47:	e8 14 e7 ff ff       	call   800160 <cprintf>
  801a4c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a4f:	cc                   	int3   
  801a50:	eb fd                	jmp    801a4f <_panic+0x43>

00801a52 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	56                   	push   %esi
  801a56:	53                   	push   %ebx
  801a57:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801a60:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801a62:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a67:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	50                   	push   %eax
  801a6e:	e8 25 f2 ff ff       	call   800c98 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 0e                	js     801a88 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801a7a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a80:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801a83:	8b 52 78             	mov    0x78(%edx),%edx
  801a86:	eb 0a                	jmp    801a92 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801a88:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801a8d:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801a92:	85 f6                	test   %esi,%esi
  801a94:	74 02                	je     801a98 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801a96:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801a98:	85 db                	test   %ebx,%ebx
  801a9a:	74 02                	je     801a9e <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801a9c:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 08                	js     801aaa <ipc_recv+0x58>
  801aa2:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa7:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801aaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5e                   	pop    %esi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	57                   	push   %edi
  801ab5:	56                   	push   %esi
  801ab6:	53                   	push   %ebx
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	8b 7d 08             	mov    0x8(%ebp),%edi
  801abd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ac0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801ac3:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801ac5:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801aca:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801acd:	ff 75 14             	pushl  0x14(%ebp)
  801ad0:	53                   	push   %ebx
  801ad1:	56                   	push   %esi
  801ad2:	57                   	push   %edi
  801ad3:	e8 9d f1 ff ff       	call   800c75 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ade:	75 07                	jne    801ae7 <ipc_send+0x36>
				    sys_yield();
  801ae0:	e8 e4 ef ff ff       	call   800ac9 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801ae5:	eb e6                	jmp    801acd <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	74 12                	je     801afd <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801aeb:	50                   	push   %eax
  801aec:	68 b0 22 80 00       	push   $0x8022b0
  801af1:	6a 4b                	push   $0x4b
  801af3:	68 c4 22 80 00       	push   $0x8022c4
  801af8:	e8 0f ff ff ff       	call   801a0c <_panic>
			 }
	   }
}
  801afd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b00:	5b                   	pop    %ebx
  801b01:	5e                   	pop    %esi
  801b02:	5f                   	pop    %edi
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    

00801b05 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801b0b:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801b10:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b13:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b19:	8b 52 50             	mov    0x50(%edx),%edx
  801b1c:	39 ca                	cmp    %ecx,%edx
  801b1e:	75 0d                	jne    801b2d <ipc_find_env+0x28>
				    return envs[i].env_id;
  801b20:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b23:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b28:	8b 40 48             	mov    0x48(%eax),%eax
  801b2b:	eb 0f                	jmp    801b3c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801b2d:	83 c0 01             	add    $0x1,%eax
  801b30:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b35:	75 d9                	jne    801b10 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801b37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b44:	89 d0                	mov    %edx,%eax
  801b46:	c1 e8 16             	shr    $0x16,%eax
  801b49:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b50:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b55:	f6 c1 01             	test   $0x1,%cl
  801b58:	74 1d                	je     801b77 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b5a:	c1 ea 0c             	shr    $0xc,%edx
  801b5d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b64:	f6 c2 01             	test   $0x1,%dl
  801b67:	74 0e                	je     801b77 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b69:	c1 ea 0c             	shr    $0xc,%edx
  801b6c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b73:	ef 
  801b74:	0f b7 c0             	movzwl %ax,%eax
}
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    
  801b79:	66 90                	xchg   %ax,%ax
  801b7b:	66 90                	xchg   %ax,%ax
  801b7d:	66 90                	xchg   %ax,%ax
  801b7f:	90                   	nop

00801b80 <__udivdi3>:
  801b80:	55                   	push   %ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 1c             	sub    $0x1c,%esp
  801b87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b97:	85 f6                	test   %esi,%esi
  801b99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b9d:	89 ca                	mov    %ecx,%edx
  801b9f:	89 f8                	mov    %edi,%eax
  801ba1:	75 3d                	jne    801be0 <__udivdi3+0x60>
  801ba3:	39 cf                	cmp    %ecx,%edi
  801ba5:	0f 87 c5 00 00 00    	ja     801c70 <__udivdi3+0xf0>
  801bab:	85 ff                	test   %edi,%edi
  801bad:	89 fd                	mov    %edi,%ebp
  801baf:	75 0b                	jne    801bbc <__udivdi3+0x3c>
  801bb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb6:	31 d2                	xor    %edx,%edx
  801bb8:	f7 f7                	div    %edi
  801bba:	89 c5                	mov    %eax,%ebp
  801bbc:	89 c8                	mov    %ecx,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f5                	div    %ebp
  801bc2:	89 c1                	mov    %eax,%ecx
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	89 cf                	mov    %ecx,%edi
  801bc8:	f7 f5                	div    %ebp
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	89 d8                	mov    %ebx,%eax
  801bce:	89 fa                	mov    %edi,%edx
  801bd0:	83 c4 1c             	add    $0x1c,%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
  801bd8:	90                   	nop
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	39 ce                	cmp    %ecx,%esi
  801be2:	77 74                	ja     801c58 <__udivdi3+0xd8>
  801be4:	0f bd fe             	bsr    %esi,%edi
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	0f 84 98 00 00 00    	je     801c88 <__udivdi3+0x108>
  801bf0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	89 c5                	mov    %eax,%ebp
  801bf9:	29 fb                	sub    %edi,%ebx
  801bfb:	d3 e6                	shl    %cl,%esi
  801bfd:	89 d9                	mov    %ebx,%ecx
  801bff:	d3 ed                	shr    %cl,%ebp
  801c01:	89 f9                	mov    %edi,%ecx
  801c03:	d3 e0                	shl    %cl,%eax
  801c05:	09 ee                	or     %ebp,%esi
  801c07:	89 d9                	mov    %ebx,%ecx
  801c09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0d:	89 d5                	mov    %edx,%ebp
  801c0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c13:	d3 ed                	shr    %cl,%ebp
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e2                	shl    %cl,%edx
  801c19:	89 d9                	mov    %ebx,%ecx
  801c1b:	d3 e8                	shr    %cl,%eax
  801c1d:	09 c2                	or     %eax,%edx
  801c1f:	89 d0                	mov    %edx,%eax
  801c21:	89 ea                	mov    %ebp,%edx
  801c23:	f7 f6                	div    %esi
  801c25:	89 d5                	mov    %edx,%ebp
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	f7 64 24 0c          	mull   0xc(%esp)
  801c2d:	39 d5                	cmp    %edx,%ebp
  801c2f:	72 10                	jb     801c41 <__udivdi3+0xc1>
  801c31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e6                	shl    %cl,%esi
  801c39:	39 c6                	cmp    %eax,%esi
  801c3b:	73 07                	jae    801c44 <__udivdi3+0xc4>
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	75 03                	jne    801c44 <__udivdi3+0xc4>
  801c41:	83 eb 01             	sub    $0x1,%ebx
  801c44:	31 ff                	xor    %edi,%edi
  801c46:	89 d8                	mov    %ebx,%eax
  801c48:	89 fa                	mov    %edi,%edx
  801c4a:	83 c4 1c             	add    $0x1c,%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    
  801c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c58:	31 ff                	xor    %edi,%edi
  801c5a:	31 db                	xor    %ebx,%ebx
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
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	f7 f7                	div    %edi
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	89 d8                	mov    %ebx,%eax
  801c7a:	89 fa                	mov    %edi,%edx
  801c7c:	83 c4 1c             	add    $0x1c,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    
  801c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c88:	39 ce                	cmp    %ecx,%esi
  801c8a:	72 0c                	jb     801c98 <__udivdi3+0x118>
  801c8c:	31 db                	xor    %ebx,%ebx
  801c8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c92:	0f 87 34 ff ff ff    	ja     801bcc <__udivdi3+0x4c>
  801c98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c9d:	e9 2a ff ff ff       	jmp    801bcc <__udivdi3+0x4c>
  801ca2:	66 90                	xchg   %ax,%ax
  801ca4:	66 90                	xchg   %ax,%ax
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 d2                	test   %edx,%edx
  801cc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cd1:	89 f3                	mov    %esi,%ebx
  801cd3:	89 3c 24             	mov    %edi,(%esp)
  801cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cda:	75 1c                	jne    801cf8 <__umoddi3+0x48>
  801cdc:	39 f7                	cmp    %esi,%edi
  801cde:	76 50                	jbe    801d30 <__umoddi3+0x80>
  801ce0:	89 c8                	mov    %ecx,%eax
  801ce2:	89 f2                	mov    %esi,%edx
  801ce4:	f7 f7                	div    %edi
  801ce6:	89 d0                	mov    %edx,%eax
  801ce8:	31 d2                	xor    %edx,%edx
  801cea:	83 c4 1c             	add    $0x1c,%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    
  801cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf8:	39 f2                	cmp    %esi,%edx
  801cfa:	89 d0                	mov    %edx,%eax
  801cfc:	77 52                	ja     801d50 <__umoddi3+0xa0>
  801cfe:	0f bd ea             	bsr    %edx,%ebp
  801d01:	83 f5 1f             	xor    $0x1f,%ebp
  801d04:	75 5a                	jne    801d60 <__umoddi3+0xb0>
  801d06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d0a:	0f 82 e0 00 00 00    	jb     801df0 <__umoddi3+0x140>
  801d10:	39 0c 24             	cmp    %ecx,(%esp)
  801d13:	0f 86 d7 00 00 00    	jbe    801df0 <__umoddi3+0x140>
  801d19:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d21:	83 c4 1c             	add    $0x1c,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	85 ff                	test   %edi,%edi
  801d32:	89 fd                	mov    %edi,%ebp
  801d34:	75 0b                	jne    801d41 <__umoddi3+0x91>
  801d36:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	f7 f7                	div    %edi
  801d3f:	89 c5                	mov    %eax,%ebp
  801d41:	89 f0                	mov    %esi,%eax
  801d43:	31 d2                	xor    %edx,%edx
  801d45:	f7 f5                	div    %ebp
  801d47:	89 c8                	mov    %ecx,%eax
  801d49:	f7 f5                	div    %ebp
  801d4b:	89 d0                	mov    %edx,%eax
  801d4d:	eb 99                	jmp    801ce8 <__umoddi3+0x38>
  801d4f:	90                   	nop
  801d50:	89 c8                	mov    %ecx,%eax
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	83 c4 1c             	add    $0x1c,%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    
  801d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d60:	8b 34 24             	mov    (%esp),%esi
  801d63:	bf 20 00 00 00       	mov    $0x20,%edi
  801d68:	89 e9                	mov    %ebp,%ecx
  801d6a:	29 ef                	sub    %ebp,%edi
  801d6c:	d3 e0                	shl    %cl,%eax
  801d6e:	89 f9                	mov    %edi,%ecx
  801d70:	89 f2                	mov    %esi,%edx
  801d72:	d3 ea                	shr    %cl,%edx
  801d74:	89 e9                	mov    %ebp,%ecx
  801d76:	09 c2                	or     %eax,%edx
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	89 14 24             	mov    %edx,(%esp)
  801d7d:	89 f2                	mov    %esi,%edx
  801d7f:	d3 e2                	shl    %cl,%edx
  801d81:	89 f9                	mov    %edi,%ecx
  801d83:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d8b:	d3 e8                	shr    %cl,%eax
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	89 c6                	mov    %eax,%esi
  801d91:	d3 e3                	shl    %cl,%ebx
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 d0                	mov    %edx,%eax
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	09 d8                	or     %ebx,%eax
  801d9d:	89 d3                	mov    %edx,%ebx
  801d9f:	89 f2                	mov    %esi,%edx
  801da1:	f7 34 24             	divl   (%esp)
  801da4:	89 d6                	mov    %edx,%esi
  801da6:	d3 e3                	shl    %cl,%ebx
  801da8:	f7 64 24 04          	mull   0x4(%esp)
  801dac:	39 d6                	cmp    %edx,%esi
  801dae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801db2:	89 d1                	mov    %edx,%ecx
  801db4:	89 c3                	mov    %eax,%ebx
  801db6:	72 08                	jb     801dc0 <__umoddi3+0x110>
  801db8:	75 11                	jne    801dcb <__umoddi3+0x11b>
  801dba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dbe:	73 0b                	jae    801dcb <__umoddi3+0x11b>
  801dc0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dc4:	1b 14 24             	sbb    (%esp),%edx
  801dc7:	89 d1                	mov    %edx,%ecx
  801dc9:	89 c3                	mov    %eax,%ebx
  801dcb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dcf:	29 da                	sub    %ebx,%edx
  801dd1:	19 ce                	sbb    %ecx,%esi
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 f0                	mov    %esi,%eax
  801dd7:	d3 e0                	shl    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	d3 ea                	shr    %cl,%edx
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	d3 ee                	shr    %cl,%esi
  801de1:	09 d0                	or     %edx,%eax
  801de3:	89 f2                	mov    %esi,%edx
  801de5:	83 c4 1c             	add    $0x1c,%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    
  801ded:	8d 76 00             	lea    0x0(%esi),%esi
  801df0:	29 f9                	sub    %edi,%ecx
  801df2:	19 d6                	sbb    %edx,%esi
  801df4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dfc:	e9 18 ff ff ff       	jmp    801d19 <__umoddi3+0x69>
