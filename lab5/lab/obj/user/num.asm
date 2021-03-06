
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 40 20 80 00       	push   $0x802040
  800062:	e8 1e 17 00 00       	call   801785 <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 6c 11 00 00       	call   8011ed <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 45 20 80 00       	push   $0x802045
  800095:	6a 13                	push   $0x13
  800097:	68 60 20 80 00       	push   $0x802060
  80009c:	e8 44 01 00 00       	call   8001e5 <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 56 10 00 00       	call   801113 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %e", s, n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 6b 20 80 00       	push   $0x80206b
  8000d8:	6a 18                	push   $0x18
  8000da:	68 60 20 80 00       	push   $0x802060
  8000df:	e8 01 01 00 00       	call   8001e5 <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 80 	movl   $0x802080,0x803004
  8000fb:	20 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 84 20 80 00       	push   $0x802084
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 b3 14 00 00       	call   8015e7 <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 8c 20 80 00       	push   $0x80208c
  80014b:	6a 27                	push   $0x27
  80014d:	68 60 20 80 00       	push   $0x802060
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 6d 0e 00 00       	call   800fd7 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 4e 00 00 00       	call   8001cb <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800190:	e8 73 0a 00 00       	call   800c08 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  800195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a2:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a7:	85 db                	test   %ebx,%ebx
  8001a9:	7e 07                	jle    8001b2 <libmain+0x2d>
		binaryname = argv[0];
  8001ab:	8b 06                	mov    (%esi),%eax
  8001ad:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
  8001b7:	e8 2f ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001bc:	e8 0a 00 00 00       	call   8001cb <exit>
}
  8001c1:	83 c4 10             	add    $0x10,%esp
  8001c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d1:	e8 2c 0e 00 00       	call   801002 <close_all>
	sys_env_destroy(0);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	6a 00                	push   $0x0
  8001db:	e8 e7 09 00 00       	call   800bc7 <sys_env_destroy>
}
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ed:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001f3:	e8 10 0a 00 00       	call   800c08 <sys_getenvid>
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	56                   	push   %esi
  800202:	50                   	push   %eax
  800203:	68 a8 20 80 00       	push   $0x8020a8
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 da 24 80 00 	movl   $0x8024da,(%esp)
  800220:	e8 99 00 00 00       	call   8002be <cprintf>
  800225:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800228:	cc                   	int3   
  800229:	eb fd                	jmp    800228 <_panic+0x43>

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 04             	sub    $0x4,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 13                	mov    (%ebx),%edx
  800237:	8d 42 01             	lea    0x1(%edx),%eax
  80023a:	89 03                	mov    %eax,(%ebx)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 1a                	jne    800264 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	68 ff 00 00 00       	push   $0xff
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	50                   	push   %eax
  800256:	e8 2f 09 00 00       	call   800b8a <sys_cputs>
		b->idx = 0;
  80025b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800261:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800264:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	68 2b 02 80 00       	push   $0x80022b
  80029c:	e8 54 01 00 00       	call   8003f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a1:	83 c4 08             	add    $0x8,%esp
  8002a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 d4 08 00 00       	call   800b8a <sys_cputs>

	return b.cnt;
}
  8002b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 9d ff ff ff       	call   80026d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 1c             	sub    $0x1c,%esp
  8002db:	89 c7                	mov    %eax,%edi
  8002dd:	89 d6                	mov    %edx,%esi
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002f6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002f9:	39 d3                	cmp    %edx,%ebx
  8002fb:	72 05                	jb     800302 <printnum+0x30>
  8002fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800300:	77 45                	ja     800347 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	ff 75 18             	pushl  0x18(%ebp)
  800308:	8b 45 14             	mov    0x14(%ebp),%eax
  80030b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030e:	53                   	push   %ebx
  80030f:	ff 75 10             	pushl  0x10(%ebp)
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	ff 75 dc             	pushl  -0x24(%ebp)
  80031e:	ff 75 d8             	pushl  -0x28(%ebp)
  800321:	e8 8a 1a 00 00       	call   801db0 <__udivdi3>
  800326:	83 c4 18             	add    $0x18,%esp
  800329:	52                   	push   %edx
  80032a:	50                   	push   %eax
  80032b:	89 f2                	mov    %esi,%edx
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	e8 9e ff ff ff       	call   8002d2 <printnum>
  800334:	83 c4 20             	add    $0x20,%esp
  800337:	eb 18                	jmp    800351 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	ff d7                	call   *%edi
  800342:	83 c4 10             	add    $0x10,%esp
  800345:	eb 03                	jmp    80034a <printnum+0x78>
  800347:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034a:	83 eb 01             	sub    $0x1,%ebx
  80034d:	85 db                	test   %ebx,%ebx
  80034f:	7f e8                	jg     800339 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	56                   	push   %esi
  800355:	83 ec 04             	sub    $0x4,%esp
  800358:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035b:	ff 75 e0             	pushl  -0x20(%ebp)
  80035e:	ff 75 dc             	pushl  -0x24(%ebp)
  800361:	ff 75 d8             	pushl  -0x28(%ebp)
  800364:	e8 77 1b 00 00       	call   801ee0 <__umoddi3>
  800369:	83 c4 14             	add    $0x14,%esp
  80036c:	0f be 80 cb 20 80 00 	movsbl 0x8020cb(%eax),%eax
  800373:	50                   	push   %eax
  800374:	ff d7                	call   *%edi
}
  800376:	83 c4 10             	add    $0x10,%esp
  800379:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037c:	5b                   	pop    %ebx
  80037d:	5e                   	pop    %esi
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800384:	83 fa 01             	cmp    $0x1,%edx
  800387:	7e 0e                	jle    800397 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	8b 52 04             	mov    0x4(%edx),%edx
  800395:	eb 22                	jmp    8003b9 <getuint+0x38>
	else if (lflag)
  800397:	85 d2                	test   %edx,%edx
  800399:	74 10                	je     8003ab <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039b:	8b 10                	mov    (%eax),%edx
  80039d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a0:	89 08                	mov    %ecx,(%eax)
  8003a2:	8b 02                	mov    (%edx),%eax
  8003a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a9:	eb 0e                	jmp    8003b9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ab:	8b 10                	mov    (%eax),%edx
  8003ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b0:	89 08                	mov    %ecx,(%eax)
  8003b2:	8b 02                	mov    (%edx),%eax
  8003b4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c5:	8b 10                	mov    (%eax),%edx
  8003c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ca:	73 0a                	jae    8003d6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	88 02                	mov    %al,(%edx)
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e1:	50                   	push   %eax
  8003e2:	ff 75 10             	pushl  0x10(%ebp)
  8003e5:	ff 75 0c             	pushl  0xc(%ebp)
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	e8 05 00 00 00       	call   8003f5 <vprintfmt>
	va_end(ap);
}
  8003f0:	83 c4 10             	add    $0x10,%esp
  8003f3:	c9                   	leave  
  8003f4:	c3                   	ret    

008003f5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	57                   	push   %edi
  8003f9:	56                   	push   %esi
  8003fa:	53                   	push   %ebx
  8003fb:	83 ec 2c             	sub    $0x2c,%esp
  8003fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800401:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800404:	8b 7d 10             	mov    0x10(%ebp),%edi
  800407:	eb 12                	jmp    80041b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800409:	85 c0                	test   %eax,%eax
  80040b:	0f 84 89 03 00 00    	je     80079a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	50                   	push   %eax
  800416:	ff d6                	call   *%esi
  800418:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041b:	83 c7 01             	add    $0x1,%edi
  80041e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800422:	83 f8 25             	cmp    $0x25,%eax
  800425:	75 e2                	jne    800409 <vprintfmt+0x14>
  800427:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80042b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800432:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800439:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800440:	ba 00 00 00 00       	mov    $0x0,%edx
  800445:	eb 07                	jmp    80044e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80044a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8d 47 01             	lea    0x1(%edi),%eax
  800451:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800454:	0f b6 07             	movzbl (%edi),%eax
  800457:	0f b6 c8             	movzbl %al,%ecx
  80045a:	83 e8 23             	sub    $0x23,%eax
  80045d:	3c 55                	cmp    $0x55,%al
  80045f:	0f 87 1a 03 00 00    	ja     80077f <vprintfmt+0x38a>
  800465:	0f b6 c0             	movzbl %al,%eax
  800468:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800472:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800476:	eb d6                	jmp    80044e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047b:	b8 00 00 00 00       	mov    $0x0,%eax
  800480:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800483:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800486:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80048a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80048d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800490:	83 fa 09             	cmp    $0x9,%edx
  800493:	77 39                	ja     8004ce <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800495:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800498:	eb e9                	jmp    800483 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 48 04             	lea    0x4(%eax),%ecx
  8004a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ab:	eb 27                	jmp    8004d4 <vprintfmt+0xdf>
  8004ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b7:	0f 49 c8             	cmovns %eax,%ecx
  8004ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c0:	eb 8c                	jmp    80044e <vprintfmt+0x59>
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004cc:	eb 80                	jmp    80044e <vprintfmt+0x59>
  8004ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004d1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d8:	0f 89 70 ff ff ff    	jns    80044e <vprintfmt+0x59>
				width = precision, precision = -1;
  8004de:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004eb:	e9 5e ff ff ff       	jmp    80044e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f6:	e9 53 ff ff ff       	jmp    80044e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 04             	lea    0x4(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	ff 30                	pushl  (%eax)
  80050a:	ff d6                	call   *%esi
			break;
  80050c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800512:	e9 04 ff ff ff       	jmp    80041b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 00                	mov    (%eax),%eax
  800522:	99                   	cltd   
  800523:	31 d0                	xor    %edx,%eax
  800525:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800527:	83 f8 0f             	cmp    $0xf,%eax
  80052a:	7f 0b                	jg     800537 <vprintfmt+0x142>
  80052c:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	75 18                	jne    80054f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800537:	50                   	push   %eax
  800538:	68 e3 20 80 00       	push   $0x8020e3
  80053d:	53                   	push   %ebx
  80053e:	56                   	push   %esi
  80053f:	e8 94 fe ff ff       	call   8003d8 <printfmt>
  800544:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80054a:	e9 cc fe ff ff       	jmp    80041b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80054f:	52                   	push   %edx
  800550:	68 95 24 80 00       	push   $0x802495
  800555:	53                   	push   %ebx
  800556:	56                   	push   %esi
  800557:	e8 7c fe ff ff       	call   8003d8 <printfmt>
  80055c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	e9 b4 fe ff ff       	jmp    80041b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800572:	85 ff                	test   %edi,%edi
  800574:	b8 dc 20 80 00       	mov    $0x8020dc,%eax
  800579:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80057c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800580:	0f 8e 94 00 00 00    	jle    80061a <vprintfmt+0x225>
  800586:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80058a:	0f 84 98 00 00 00    	je     800628 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	ff 75 d0             	pushl  -0x30(%ebp)
  800596:	57                   	push   %edi
  800597:	e8 86 02 00 00       	call   800822 <strnlen>
  80059c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80059f:	29 c1                	sub    %eax,%ecx
  8005a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	eb 0f                	jmp    8005c4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	53                   	push   %ebx
  8005b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005be:	83 ef 01             	sub    $0x1,%edi
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f ed                	jg     8005b5 <vprintfmt+0x1c0>
  8005c8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005cb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d5:	0f 49 c1             	cmovns %ecx,%eax
  8005d8:	29 c1                	sub    %eax,%ecx
  8005da:	89 75 08             	mov    %esi,0x8(%ebp)
  8005dd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e3:	89 cb                	mov    %ecx,%ebx
  8005e5:	eb 4d                	jmp    800634 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005eb:	74 1b                	je     800608 <vprintfmt+0x213>
  8005ed:	0f be c0             	movsbl %al,%eax
  8005f0:	83 e8 20             	sub    $0x20,%eax
  8005f3:	83 f8 5e             	cmp    $0x5e,%eax
  8005f6:	76 10                	jbe    800608 <vprintfmt+0x213>
					putch('?', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	ff 75 0c             	pushl  0xc(%ebp)
  8005fe:	6a 3f                	push   $0x3f
  800600:	ff 55 08             	call   *0x8(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
  800606:	eb 0d                	jmp    800615 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	ff 75 0c             	pushl  0xc(%ebp)
  80060e:	52                   	push   %edx
  80060f:	ff 55 08             	call   *0x8(%ebp)
  800612:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800615:	83 eb 01             	sub    $0x1,%ebx
  800618:	eb 1a                	jmp    800634 <vprintfmt+0x23f>
  80061a:	89 75 08             	mov    %esi,0x8(%ebp)
  80061d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800620:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800623:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800626:	eb 0c                	jmp    800634 <vprintfmt+0x23f>
  800628:	89 75 08             	mov    %esi,0x8(%ebp)
  80062b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80062e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800631:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800634:	83 c7 01             	add    $0x1,%edi
  800637:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063b:	0f be d0             	movsbl %al,%edx
  80063e:	85 d2                	test   %edx,%edx
  800640:	74 23                	je     800665 <vprintfmt+0x270>
  800642:	85 f6                	test   %esi,%esi
  800644:	78 a1                	js     8005e7 <vprintfmt+0x1f2>
  800646:	83 ee 01             	sub    $0x1,%esi
  800649:	79 9c                	jns    8005e7 <vprintfmt+0x1f2>
  80064b:	89 df                	mov    %ebx,%edi
  80064d:	8b 75 08             	mov    0x8(%ebp),%esi
  800650:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800653:	eb 18                	jmp    80066d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 20                	push   $0x20
  80065b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065d:	83 ef 01             	sub    $0x1,%edi
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	eb 08                	jmp    80066d <vprintfmt+0x278>
  800665:	89 df                	mov    %ebx,%edi
  800667:	8b 75 08             	mov    0x8(%ebp),%esi
  80066a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80066d:	85 ff                	test   %edi,%edi
  80066f:	7f e4                	jg     800655 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800674:	e9 a2 fd ff ff       	jmp    80041b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800679:	83 fa 01             	cmp    $0x1,%edx
  80067c:	7e 16                	jle    800694 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 08             	lea    0x8(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 50 04             	mov    0x4(%eax),%edx
  80068a:	8b 00                	mov    (%eax),%eax
  80068c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800692:	eb 32                	jmp    8006c6 <vprintfmt+0x2d1>
	else if (lflag)
  800694:	85 d2                	test   %edx,%edx
  800696:	74 18                	je     8006b0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a6:	89 c1                	mov    %eax,%ecx
  8006a8:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ae:	eb 16                	jmp    8006c6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 50 04             	lea    0x4(%eax),%edx
  8006b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b9:	8b 00                	mov    (%eax),%eax
  8006bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006be:	89 c1                	mov    %eax,%ecx
  8006c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d5:	79 74                	jns    80074b <vprintfmt+0x356>
				putch('-', putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	6a 2d                	push   $0x2d
  8006dd:	ff d6                	call   *%esi
				num = -(long long) num;
  8006df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e5:	f7 d8                	neg    %eax
  8006e7:	83 d2 00             	adc    $0x0,%edx
  8006ea:	f7 da                	neg    %edx
  8006ec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f4:	eb 55                	jmp    80074b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 83 fc ff ff       	call   800381 <getuint>
			base = 10;
  8006fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800703:	eb 46                	jmp    80074b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800705:	8d 45 14             	lea    0x14(%ebp),%eax
  800708:	e8 74 fc ff ff       	call   800381 <getuint>
			base = 8;
  80070d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800712:	eb 37                	jmp    80074b <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 30                	push   $0x30
  80071a:	ff d6                	call   *%esi
			putch('x', putdat);
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	6a 78                	push   $0x78
  800722:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800734:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800737:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80073c:	eb 0d                	jmp    80074b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073e:	8d 45 14             	lea    0x14(%ebp),%eax
  800741:	e8 3b fc ff ff       	call   800381 <getuint>
			base = 16;
  800746:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80074b:	83 ec 0c             	sub    $0xc,%esp
  80074e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800752:	57                   	push   %edi
  800753:	ff 75 e0             	pushl  -0x20(%ebp)
  800756:	51                   	push   %ecx
  800757:	52                   	push   %edx
  800758:	50                   	push   %eax
  800759:	89 da                	mov    %ebx,%edx
  80075b:	89 f0                	mov    %esi,%eax
  80075d:	e8 70 fb ff ff       	call   8002d2 <printnum>
			break;
  800762:	83 c4 20             	add    $0x20,%esp
  800765:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800768:	e9 ae fc ff ff       	jmp    80041b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	51                   	push   %ecx
  800772:	ff d6                	call   *%esi
			break;
  800774:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80077a:	e9 9c fc ff ff       	jmp    80041b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	53                   	push   %ebx
  800783:	6a 25                	push   $0x25
  800785:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	eb 03                	jmp    80078f <vprintfmt+0x39a>
  80078c:	83 ef 01             	sub    $0x1,%edi
  80078f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800793:	75 f7                	jne    80078c <vprintfmt+0x397>
  800795:	e9 81 fc ff ff       	jmp    80041b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80079a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	5f                   	pop    %edi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 18             	sub    $0x18,%esp
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	74 26                	je     8007e9 <vsnprintf+0x47>
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	7e 22                	jle    8007e9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c7:	ff 75 14             	pushl  0x14(%ebp)
  8007ca:	ff 75 10             	pushl  0x10(%ebp)
  8007cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	68 bb 03 80 00       	push   $0x8003bb
  8007d6:	e8 1a fc ff ff       	call   8003f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007de:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	eb 05                	jmp    8007ee <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f9:	50                   	push   %eax
  8007fa:	ff 75 10             	pushl  0x10(%ebp)
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	ff 75 08             	pushl  0x8(%ebp)
  800803:	e8 9a ff ff ff       	call   8007a2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	eb 03                	jmp    80081a <strlen+0x10>
		n++;
  800817:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80081a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081e:	75 f7                	jne    800817 <strlen+0xd>
		n++;
	return n;
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800828:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082b:	ba 00 00 00 00       	mov    $0x0,%edx
  800830:	eb 03                	jmp    800835 <strnlen+0x13>
		n++;
  800832:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800835:	39 c2                	cmp    %eax,%edx
  800837:	74 08                	je     800841 <strnlen+0x1f>
  800839:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80083d:	75 f3                	jne    800832 <strnlen+0x10>
  80083f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084d:	89 c2                	mov    %eax,%edx
  80084f:	83 c2 01             	add    $0x1,%edx
  800852:	83 c1 01             	add    $0x1,%ecx
  800855:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800859:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085c:	84 db                	test   %bl,%bl
  80085e:	75 ef                	jne    80084f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800860:	5b                   	pop    %ebx
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80086a:	53                   	push   %ebx
  80086b:	e8 9a ff ff ff       	call   80080a <strlen>
  800870:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800873:	ff 75 0c             	pushl  0xc(%ebp)
  800876:	01 d8                	add    %ebx,%eax
  800878:	50                   	push   %eax
  800879:	e8 c5 ff ff ff       	call   800843 <strcpy>
	return dst;
}
  80087e:	89 d8                	mov    %ebx,%eax
  800880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	56                   	push   %esi
  800889:	53                   	push   %ebx
  80088a:	8b 75 08             	mov    0x8(%ebp),%esi
  80088d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800890:	89 f3                	mov    %esi,%ebx
  800892:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800895:	89 f2                	mov    %esi,%edx
  800897:	eb 0f                	jmp    8008a8 <strncpy+0x23>
		*dst++ = *src;
  800899:	83 c2 01             	add    $0x1,%edx
  80089c:	0f b6 01             	movzbl (%ecx),%eax
  80089f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a2:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a8:	39 da                	cmp    %ebx,%edx
  8008aa:	75 ed                	jne    800899 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ac:	89 f0                	mov    %esi,%eax
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	8b 55 10             	mov    0x10(%ebp),%edx
  8008c0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c2:	85 d2                	test   %edx,%edx
  8008c4:	74 21                	je     8008e7 <strlcpy+0x35>
  8008c6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ca:	89 f2                	mov    %esi,%edx
  8008cc:	eb 09                	jmp    8008d7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ce:	83 c2 01             	add    $0x1,%edx
  8008d1:	83 c1 01             	add    $0x1,%ecx
  8008d4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d7:	39 c2                	cmp    %eax,%edx
  8008d9:	74 09                	je     8008e4 <strlcpy+0x32>
  8008db:	0f b6 19             	movzbl (%ecx),%ebx
  8008de:	84 db                	test   %bl,%bl
  8008e0:	75 ec                	jne    8008ce <strlcpy+0x1c>
  8008e2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e7:	29 f0                	sub    %esi,%eax
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f6:	eb 06                	jmp    8008fe <strcmp+0x11>
		p++, q++;
  8008f8:	83 c1 01             	add    $0x1,%ecx
  8008fb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008fe:	0f b6 01             	movzbl (%ecx),%eax
  800901:	84 c0                	test   %al,%al
  800903:	74 04                	je     800909 <strcmp+0x1c>
  800905:	3a 02                	cmp    (%edx),%al
  800907:	74 ef                	je     8008f8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800909:	0f b6 c0             	movzbl %al,%eax
  80090c:	0f b6 12             	movzbl (%edx),%edx
  80090f:	29 d0                	sub    %edx,%eax
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	53                   	push   %ebx
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091d:	89 c3                	mov    %eax,%ebx
  80091f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800922:	eb 06                	jmp    80092a <strncmp+0x17>
		n--, p++, q++;
  800924:	83 c0 01             	add    $0x1,%eax
  800927:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80092a:	39 d8                	cmp    %ebx,%eax
  80092c:	74 15                	je     800943 <strncmp+0x30>
  80092e:	0f b6 08             	movzbl (%eax),%ecx
  800931:	84 c9                	test   %cl,%cl
  800933:	74 04                	je     800939 <strncmp+0x26>
  800935:	3a 0a                	cmp    (%edx),%cl
  800937:	74 eb                	je     800924 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800939:	0f b6 00             	movzbl (%eax),%eax
  80093c:	0f b6 12             	movzbl (%edx),%edx
  80093f:	29 d0                	sub    %edx,%eax
  800941:	eb 05                	jmp    800948 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800948:	5b                   	pop    %ebx
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800955:	eb 07                	jmp    80095e <strchr+0x13>
		if (*s == c)
  800957:	38 ca                	cmp    %cl,%dl
  800959:	74 0f                	je     80096a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	0f b6 10             	movzbl (%eax),%edx
  800961:	84 d2                	test   %dl,%dl
  800963:	75 f2                	jne    800957 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800976:	eb 03                	jmp    80097b <strfind+0xf>
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80097e:	38 ca                	cmp    %cl,%dl
  800980:	74 04                	je     800986 <strfind+0x1a>
  800982:	84 d2                	test   %dl,%dl
  800984:	75 f2                	jne    800978 <strfind+0xc>
			break;
	return (char *) s;
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	53                   	push   %ebx
  80098e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800991:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800994:	85 c9                	test   %ecx,%ecx
  800996:	74 36                	je     8009ce <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800998:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099e:	75 28                	jne    8009c8 <memset+0x40>
  8009a0:	f6 c1 03             	test   $0x3,%cl
  8009a3:	75 23                	jne    8009c8 <memset+0x40>
		c &= 0xFF;
  8009a5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a9:	89 d3                	mov    %edx,%ebx
  8009ab:	c1 e3 08             	shl    $0x8,%ebx
  8009ae:	89 d6                	mov    %edx,%esi
  8009b0:	c1 e6 18             	shl    $0x18,%esi
  8009b3:	89 d0                	mov    %edx,%eax
  8009b5:	c1 e0 10             	shl    $0x10,%eax
  8009b8:	09 f0                	or     %esi,%eax
  8009ba:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009bc:	89 d8                	mov    %ebx,%eax
  8009be:	09 d0                	or     %edx,%eax
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
  8009c3:	fc                   	cld    
  8009c4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c6:	eb 06                	jmp    8009ce <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cb:	fc                   	cld    
  8009cc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ce:	89 f8                	mov    %edi,%eax
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5f                   	pop    %edi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	57                   	push   %edi
  8009d9:	56                   	push   %esi
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e3:	39 c6                	cmp    %eax,%esi
  8009e5:	73 35                	jae    800a1c <memmove+0x47>
  8009e7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ea:	39 d0                	cmp    %edx,%eax
  8009ec:	73 2e                	jae    800a1c <memmove+0x47>
		s += n;
		d += n;
  8009ee:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f1:	89 d6                	mov    %edx,%esi
  8009f3:	09 fe                	or     %edi,%esi
  8009f5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009fb:	75 13                	jne    800a10 <memmove+0x3b>
  8009fd:	f6 c1 03             	test   $0x3,%cl
  800a00:	75 0e                	jne    800a10 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a02:	83 ef 04             	sub    $0x4,%edi
  800a05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a08:	c1 e9 02             	shr    $0x2,%ecx
  800a0b:	fd                   	std    
  800a0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0e:	eb 09                	jmp    800a19 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a10:	83 ef 01             	sub    $0x1,%edi
  800a13:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a16:	fd                   	std    
  800a17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a19:	fc                   	cld    
  800a1a:	eb 1d                	jmp    800a39 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1c:	89 f2                	mov    %esi,%edx
  800a1e:	09 c2                	or     %eax,%edx
  800a20:	f6 c2 03             	test   $0x3,%dl
  800a23:	75 0f                	jne    800a34 <memmove+0x5f>
  800a25:	f6 c1 03             	test   $0x3,%cl
  800a28:	75 0a                	jne    800a34 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a2a:	c1 e9 02             	shr    $0x2,%ecx
  800a2d:	89 c7                	mov    %eax,%edi
  800a2f:	fc                   	cld    
  800a30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a32:	eb 05                	jmp    800a39 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a34:	89 c7                	mov    %eax,%edi
  800a36:	fc                   	cld    
  800a37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a40:	ff 75 10             	pushl  0x10(%ebp)
  800a43:	ff 75 0c             	pushl  0xc(%ebp)
  800a46:	ff 75 08             	pushl  0x8(%ebp)
  800a49:	e8 87 ff ff ff       	call   8009d5 <memmove>
}
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5b:	89 c6                	mov    %eax,%esi
  800a5d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a60:	eb 1a                	jmp    800a7c <memcmp+0x2c>
		if (*s1 != *s2)
  800a62:	0f b6 08             	movzbl (%eax),%ecx
  800a65:	0f b6 1a             	movzbl (%edx),%ebx
  800a68:	38 d9                	cmp    %bl,%cl
  800a6a:	74 0a                	je     800a76 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a6c:	0f b6 c1             	movzbl %cl,%eax
  800a6f:	0f b6 db             	movzbl %bl,%ebx
  800a72:	29 d8                	sub    %ebx,%eax
  800a74:	eb 0f                	jmp    800a85 <memcmp+0x35>
		s1++, s2++;
  800a76:	83 c0 01             	add    $0x1,%eax
  800a79:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7c:	39 f0                	cmp    %esi,%eax
  800a7e:	75 e2                	jne    800a62 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	53                   	push   %ebx
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a90:	89 c1                	mov    %eax,%ecx
  800a92:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a95:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a99:	eb 0a                	jmp    800aa5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a9b:	0f b6 10             	movzbl (%eax),%edx
  800a9e:	39 da                	cmp    %ebx,%edx
  800aa0:	74 07                	je     800aa9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa2:	83 c0 01             	add    $0x1,%eax
  800aa5:	39 c8                	cmp    %ecx,%eax
  800aa7:	72 f2                	jb     800a9b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab8:	eb 03                	jmp    800abd <strtol+0x11>
		s++;
  800aba:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abd:	0f b6 01             	movzbl (%ecx),%eax
  800ac0:	3c 20                	cmp    $0x20,%al
  800ac2:	74 f6                	je     800aba <strtol+0xe>
  800ac4:	3c 09                	cmp    $0x9,%al
  800ac6:	74 f2                	je     800aba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac8:	3c 2b                	cmp    $0x2b,%al
  800aca:	75 0a                	jne    800ad6 <strtol+0x2a>
		s++;
  800acc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800acf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad4:	eb 11                	jmp    800ae7 <strtol+0x3b>
  800ad6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800adb:	3c 2d                	cmp    $0x2d,%al
  800add:	75 08                	jne    800ae7 <strtol+0x3b>
		s++, neg = 1;
  800adf:	83 c1 01             	add    $0x1,%ecx
  800ae2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aed:	75 15                	jne    800b04 <strtol+0x58>
  800aef:	80 39 30             	cmpb   $0x30,(%ecx)
  800af2:	75 10                	jne    800b04 <strtol+0x58>
  800af4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af8:	75 7c                	jne    800b76 <strtol+0xca>
		s += 2, base = 16;
  800afa:	83 c1 02             	add    $0x2,%ecx
  800afd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b02:	eb 16                	jmp    800b1a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b04:	85 db                	test   %ebx,%ebx
  800b06:	75 12                	jne    800b1a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b08:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b10:	75 08                	jne    800b1a <strtol+0x6e>
		s++, base = 8;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b22:	0f b6 11             	movzbl (%ecx),%edx
  800b25:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b28:	89 f3                	mov    %esi,%ebx
  800b2a:	80 fb 09             	cmp    $0x9,%bl
  800b2d:	77 08                	ja     800b37 <strtol+0x8b>
			dig = *s - '0';
  800b2f:	0f be d2             	movsbl %dl,%edx
  800b32:	83 ea 30             	sub    $0x30,%edx
  800b35:	eb 22                	jmp    800b59 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b37:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b3a:	89 f3                	mov    %esi,%ebx
  800b3c:	80 fb 19             	cmp    $0x19,%bl
  800b3f:	77 08                	ja     800b49 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b41:	0f be d2             	movsbl %dl,%edx
  800b44:	83 ea 57             	sub    $0x57,%edx
  800b47:	eb 10                	jmp    800b59 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b49:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b4c:	89 f3                	mov    %esi,%ebx
  800b4e:	80 fb 19             	cmp    $0x19,%bl
  800b51:	77 16                	ja     800b69 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b53:	0f be d2             	movsbl %dl,%edx
  800b56:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b59:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b5c:	7d 0b                	jge    800b69 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b5e:	83 c1 01             	add    $0x1,%ecx
  800b61:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b65:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b67:	eb b9                	jmp    800b22 <strtol+0x76>

	if (endptr)
  800b69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6d:	74 0d                	je     800b7c <strtol+0xd0>
		*endptr = (char *) s;
  800b6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b72:	89 0e                	mov    %ecx,(%esi)
  800b74:	eb 06                	jmp    800b7c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b76:	85 db                	test   %ebx,%ebx
  800b78:	74 98                	je     800b12 <strtol+0x66>
  800b7a:	eb 9e                	jmp    800b1a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b7c:	89 c2                	mov    %eax,%edx
  800b7e:	f7 da                	neg    %edx
  800b80:	85 ff                	test   %edi,%edi
  800b82:	0f 45 c2             	cmovne %edx,%eax
}
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b90:	b8 00 00 00 00       	mov    $0x0,%eax
  800b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	89 c3                	mov    %eax,%ebx
  800b9d:	89 c7                	mov    %eax,%edi
  800b9f:	89 c6                	mov    %eax,%esi
  800ba1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb8:	89 d1                	mov    %edx,%ecx
  800bba:	89 d3                	mov    %edx,%ebx
  800bbc:	89 d7                	mov    %edx,%edi
  800bbe:	89 d6                	mov    %edx,%esi
  800bc0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
  800bcd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd5:	b8 03 00 00 00       	mov    $0x3,%eax
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	89 cb                	mov    %ecx,%ebx
  800bdf:	89 cf                	mov    %ecx,%edi
  800be1:	89 ce                	mov    %ecx,%esi
  800be3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7e 17                	jle    800c00 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 03                	push   $0x3
  800bef:	68 bf 23 80 00       	push   $0x8023bf
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 dc 23 80 00       	push   $0x8023dc
  800bfb:	e8 e5 f5 ff ff       	call   8001e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c13:	b8 02 00 00 00       	mov    $0x2,%eax
  800c18:	89 d1                	mov    %edx,%ecx
  800c1a:	89 d3                	mov    %edx,%ebx
  800c1c:	89 d7                	mov    %edx,%edi
  800c1e:	89 d6                	mov    %edx,%esi
  800c20:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_yield>:

void
sys_yield(void)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c32:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c37:	89 d1                	mov    %edx,%ecx
  800c39:	89 d3                	mov    %edx,%ebx
  800c3b:	89 d7                	mov    %edx,%edi
  800c3d:	89 d6                	mov    %edx,%esi
  800c3f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c4f:	be 00 00 00 00       	mov    $0x0,%esi
  800c54:	b8 04 00 00 00       	mov    $0x4,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c62:	89 f7                	mov    %esi,%edi
  800c64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 17                	jle    800c81 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 04                	push   $0x4
  800c70:	68 bf 23 80 00       	push   $0x8023bf
  800c75:	6a 23                	push   $0x23
  800c77:	68 dc 23 80 00       	push   $0x8023dc
  800c7c:	e8 64 f5 ff ff       	call   8001e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	b8 05 00 00 00       	mov    $0x5,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca3:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7e 17                	jle    800cc3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 05                	push   $0x5
  800cb2:	68 bf 23 80 00       	push   $0x8023bf
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 dc 23 80 00       	push   $0x8023dc
  800cbe:	e8 22 f5 ff ff       	call   8001e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	b8 06 00 00 00       	mov    $0x6,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 06                	push   $0x6
  800cf4:	68 bf 23 80 00       	push   $0x8023bf
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 dc 23 80 00       	push   $0x8023dc
  800d00:	e8 e0 f4 ff ff       	call   8001e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	89 de                	mov    %ebx,%esi
  800d2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7e 17                	jle    800d47 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	50                   	push   %eax
  800d34:	6a 08                	push   $0x8
  800d36:	68 bf 23 80 00       	push   $0x8023bf
  800d3b:	6a 23                	push   $0x23
  800d3d:	68 dc 23 80 00       	push   $0x8023dc
  800d42:	e8 9e f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	89 df                	mov    %ebx,%edi
  800d6a:	89 de                	mov    %ebx,%esi
  800d6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	7e 17                	jle    800d89 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	50                   	push   %eax
  800d76:	6a 09                	push   $0x9
  800d78:	68 bf 23 80 00       	push   $0x8023bf
  800d7d:	6a 23                	push   $0x23
  800d7f:	68 dc 23 80 00       	push   $0x8023dc
  800d84:	e8 5c f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	89 df                	mov    %ebx,%edi
  800dac:	89 de                	mov    %ebx,%esi
  800dae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db0:	85 c0                	test   %eax,%eax
  800db2:	7e 17                	jle    800dcb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	50                   	push   %eax
  800db8:	6a 0a                	push   $0xa
  800dba:	68 bf 23 80 00       	push   $0x8023bf
  800dbf:	6a 23                	push   $0x23
  800dc1:	68 dc 23 80 00       	push   $0x8023dc
  800dc6:	e8 1a f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	be 00 00 00 00       	mov    $0x0,%esi
  800dde:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800def:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e04:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	89 cb                	mov    %ecx,%ebx
  800e0e:	89 cf                	mov    %ecx,%edi
  800e10:	89 ce                	mov    %ecx,%esi
  800e12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	7e 17                	jle    800e2f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	50                   	push   %eax
  800e1c:	6a 0d                	push   $0xd
  800e1e:	68 bf 23 80 00       	push   $0x8023bf
  800e23:	6a 23                	push   $0x23
  800e25:	68 dc 23 80 00       	push   $0x8023dc
  800e2a:	e8 b6 f3 ff ff       	call   8001e5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3d:	05 00 00 00 30       	add    $0x30000000,%eax
  800e42:	c1 e8 0c             	shr    $0xc,%eax
}
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4d:	05 00 00 00 30       	add    $0x30000000,%eax
  800e52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e57:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e64:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e69:	89 c2                	mov    %eax,%edx
  800e6b:	c1 ea 16             	shr    $0x16,%edx
  800e6e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e75:	f6 c2 01             	test   $0x1,%dl
  800e78:	74 11                	je     800e8b <fd_alloc+0x2d>
  800e7a:	89 c2                	mov    %eax,%edx
  800e7c:	c1 ea 0c             	shr    $0xc,%edx
  800e7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e86:	f6 c2 01             	test   $0x1,%dl
  800e89:	75 09                	jne    800e94 <fd_alloc+0x36>
			*fd_store = fd;
  800e8b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e92:	eb 17                	jmp    800eab <fd_alloc+0x4d>
  800e94:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e99:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e9e:	75 c9                	jne    800e69 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ea0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ea6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eb3:	83 f8 1f             	cmp    $0x1f,%eax
  800eb6:	77 36                	ja     800eee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb8:	c1 e0 0c             	shl    $0xc,%eax
  800ebb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ec0:	89 c2                	mov    %eax,%edx
  800ec2:	c1 ea 16             	shr    $0x16,%edx
  800ec5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ecc:	f6 c2 01             	test   $0x1,%dl
  800ecf:	74 24                	je     800ef5 <fd_lookup+0x48>
  800ed1:	89 c2                	mov    %eax,%edx
  800ed3:	c1 ea 0c             	shr    $0xc,%edx
  800ed6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800edd:	f6 c2 01             	test   $0x1,%dl
  800ee0:	74 1a                	je     800efc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee5:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eec:	eb 13                	jmp    800f01 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef3:	eb 0c                	jmp    800f01 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efa:	eb 05                	jmp    800f01 <fd_lookup+0x54>
  800efc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	83 ec 08             	sub    $0x8,%esp
  800f09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0c:	ba 6c 24 80 00       	mov    $0x80246c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f11:	eb 13                	jmp    800f26 <dev_lookup+0x23>
  800f13:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f16:	39 08                	cmp    %ecx,(%eax)
  800f18:	75 0c                	jne    800f26 <dev_lookup+0x23>
			*dev = devtab[i];
  800f1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f24:	eb 2e                	jmp    800f54 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f26:	8b 02                	mov    (%edx),%eax
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	75 e7                	jne    800f13 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f2c:	a1 08 40 80 00       	mov    0x804008,%eax
  800f31:	8b 40 48             	mov    0x48(%eax),%eax
  800f34:	83 ec 04             	sub    $0x4,%esp
  800f37:	51                   	push   %ecx
  800f38:	50                   	push   %eax
  800f39:	68 ec 23 80 00       	push   $0x8023ec
  800f3e:	e8 7b f3 ff ff       	call   8002be <cprintf>
	*dev = 0;
  800f43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f46:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f54:	c9                   	leave  
  800f55:	c3                   	ret    

00800f56 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	56                   	push   %esi
  800f5a:	53                   	push   %ebx
  800f5b:	83 ec 10             	sub    $0x10,%esp
  800f5e:	8b 75 08             	mov    0x8(%ebp),%esi
  800f61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f67:	50                   	push   %eax
  800f68:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f6e:	c1 e8 0c             	shr    $0xc,%eax
  800f71:	50                   	push   %eax
  800f72:	e8 36 ff ff ff       	call   800ead <fd_lookup>
  800f77:	83 c4 08             	add    $0x8,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	78 05                	js     800f83 <fd_close+0x2d>
	    || fd != fd2)
  800f7e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f81:	74 0c                	je     800f8f <fd_close+0x39>
		return (must_exist ? r : 0);
  800f83:	84 db                	test   %bl,%bl
  800f85:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8a:	0f 44 c2             	cmove  %edx,%eax
  800f8d:	eb 41                	jmp    800fd0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f8f:	83 ec 08             	sub    $0x8,%esp
  800f92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f95:	50                   	push   %eax
  800f96:	ff 36                	pushl  (%esi)
  800f98:	e8 66 ff ff ff       	call   800f03 <dev_lookup>
  800f9d:	89 c3                	mov    %eax,%ebx
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	78 1a                	js     800fc0 <fd_close+0x6a>
		if (dev->dev_close)
  800fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fac:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	74 0b                	je     800fc0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fb5:	83 ec 0c             	sub    $0xc,%esp
  800fb8:	56                   	push   %esi
  800fb9:	ff d0                	call   *%eax
  800fbb:	89 c3                	mov    %eax,%ebx
  800fbd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fc0:	83 ec 08             	sub    $0x8,%esp
  800fc3:	56                   	push   %esi
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 00 fd ff ff       	call   800ccb <sys_page_unmap>
	return r;
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	89 d8                	mov    %ebx,%eax
}
  800fd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe0:	50                   	push   %eax
  800fe1:	ff 75 08             	pushl  0x8(%ebp)
  800fe4:	e8 c4 fe ff ff       	call   800ead <fd_lookup>
  800fe9:	83 c4 08             	add    $0x8,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 10                	js     801000 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ff0:	83 ec 08             	sub    $0x8,%esp
  800ff3:	6a 01                	push   $0x1
  800ff5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff8:	e8 59 ff ff ff       	call   800f56 <fd_close>
  800ffd:	83 c4 10             	add    $0x10,%esp
}
  801000:	c9                   	leave  
  801001:	c3                   	ret    

00801002 <close_all>:

void
close_all(void)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	53                   	push   %ebx
  801006:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801009:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	53                   	push   %ebx
  801012:	e8 c0 ff ff ff       	call   800fd7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801017:	83 c3 01             	add    $0x1,%ebx
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	83 fb 20             	cmp    $0x20,%ebx
  801020:	75 ec                	jne    80100e <close_all+0xc>
		close(i);
}
  801022:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	83 ec 2c             	sub    $0x2c,%esp
  801030:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801033:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801036:	50                   	push   %eax
  801037:	ff 75 08             	pushl  0x8(%ebp)
  80103a:	e8 6e fe ff ff       	call   800ead <fd_lookup>
  80103f:	83 c4 08             	add    $0x8,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	0f 88 c1 00 00 00    	js     80110b <dup+0xe4>
		return r;
	close(newfdnum);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	56                   	push   %esi
  80104e:	e8 84 ff ff ff       	call   800fd7 <close>

	newfd = INDEX2FD(newfdnum);
  801053:	89 f3                	mov    %esi,%ebx
  801055:	c1 e3 0c             	shl    $0xc,%ebx
  801058:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80105e:	83 c4 04             	add    $0x4,%esp
  801061:	ff 75 e4             	pushl  -0x1c(%ebp)
  801064:	e8 de fd ff ff       	call   800e47 <fd2data>
  801069:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80106b:	89 1c 24             	mov    %ebx,(%esp)
  80106e:	e8 d4 fd ff ff       	call   800e47 <fd2data>
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801079:	89 f8                	mov    %edi,%eax
  80107b:	c1 e8 16             	shr    $0x16,%eax
  80107e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801085:	a8 01                	test   $0x1,%al
  801087:	74 37                	je     8010c0 <dup+0x99>
  801089:	89 f8                	mov    %edi,%eax
  80108b:	c1 e8 0c             	shr    $0xc,%eax
  80108e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801095:	f6 c2 01             	test   $0x1,%dl
  801098:	74 26                	je     8010c0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80109a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a9:	50                   	push   %eax
  8010aa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ad:	6a 00                	push   $0x0
  8010af:	57                   	push   %edi
  8010b0:	6a 00                	push   $0x0
  8010b2:	e8 d2 fb ff ff       	call   800c89 <sys_page_map>
  8010b7:	89 c7                	mov    %eax,%edi
  8010b9:	83 c4 20             	add    $0x20,%esp
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	78 2e                	js     8010ee <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010c3:	89 d0                	mov    %edx,%eax
  8010c5:	c1 e8 0c             	shr    $0xc,%eax
  8010c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d7:	50                   	push   %eax
  8010d8:	53                   	push   %ebx
  8010d9:	6a 00                	push   $0x0
  8010db:	52                   	push   %edx
  8010dc:	6a 00                	push   $0x0
  8010de:	e8 a6 fb ff ff       	call   800c89 <sys_page_map>
  8010e3:	89 c7                	mov    %eax,%edi
  8010e5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010e8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ea:	85 ff                	test   %edi,%edi
  8010ec:	79 1d                	jns    80110b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010ee:	83 ec 08             	sub    $0x8,%esp
  8010f1:	53                   	push   %ebx
  8010f2:	6a 00                	push   $0x0
  8010f4:	e8 d2 fb ff ff       	call   800ccb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f9:	83 c4 08             	add    $0x8,%esp
  8010fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ff:	6a 00                	push   $0x0
  801101:	e8 c5 fb ff ff       	call   800ccb <sys_page_unmap>
	return r;
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	89 f8                	mov    %edi,%eax
}
  80110b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5f                   	pop    %edi
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    

00801113 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	53                   	push   %ebx
  801117:	83 ec 14             	sub    $0x14,%esp
  80111a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80111d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801120:	50                   	push   %eax
  801121:	53                   	push   %ebx
  801122:	e8 86 fd ff ff       	call   800ead <fd_lookup>
  801127:	83 c4 08             	add    $0x8,%esp
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	85 c0                	test   %eax,%eax
  80112e:	78 6d                	js     80119d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801136:	50                   	push   %eax
  801137:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113a:	ff 30                	pushl  (%eax)
  80113c:	e8 c2 fd ff ff       	call   800f03 <dev_lookup>
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	85 c0                	test   %eax,%eax
  801146:	78 4c                	js     801194 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801148:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80114b:	8b 42 08             	mov    0x8(%edx),%eax
  80114e:	83 e0 03             	and    $0x3,%eax
  801151:	83 f8 01             	cmp    $0x1,%eax
  801154:	75 21                	jne    801177 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801156:	a1 08 40 80 00       	mov    0x804008,%eax
  80115b:	8b 40 48             	mov    0x48(%eax),%eax
  80115e:	83 ec 04             	sub    $0x4,%esp
  801161:	53                   	push   %ebx
  801162:	50                   	push   %eax
  801163:	68 30 24 80 00       	push   $0x802430
  801168:	e8 51 f1 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  80116d:	83 c4 10             	add    $0x10,%esp
  801170:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801175:	eb 26                	jmp    80119d <read+0x8a>
	}
	if (!dev->dev_read)
  801177:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117a:	8b 40 08             	mov    0x8(%eax),%eax
  80117d:	85 c0                	test   %eax,%eax
  80117f:	74 17                	je     801198 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	ff 75 10             	pushl  0x10(%ebp)
  801187:	ff 75 0c             	pushl  0xc(%ebp)
  80118a:	52                   	push   %edx
  80118b:	ff d0                	call   *%eax
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	eb 09                	jmp    80119d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801194:	89 c2                	mov    %eax,%edx
  801196:	eb 05                	jmp    80119d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801198:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80119d:	89 d0                	mov    %edx,%eax
  80119f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	57                   	push   %edi
  8011a8:	56                   	push   %esi
  8011a9:	53                   	push   %ebx
  8011aa:	83 ec 0c             	sub    $0xc,%esp
  8011ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b8:	eb 21                	jmp    8011db <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011ba:	83 ec 04             	sub    $0x4,%esp
  8011bd:	89 f0                	mov    %esi,%eax
  8011bf:	29 d8                	sub    %ebx,%eax
  8011c1:	50                   	push   %eax
  8011c2:	89 d8                	mov    %ebx,%eax
  8011c4:	03 45 0c             	add    0xc(%ebp),%eax
  8011c7:	50                   	push   %eax
  8011c8:	57                   	push   %edi
  8011c9:	e8 45 ff ff ff       	call   801113 <read>
		if (m < 0)
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	78 10                	js     8011e5 <readn+0x41>
			return m;
		if (m == 0)
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	74 0a                	je     8011e3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d9:	01 c3                	add    %eax,%ebx
  8011db:	39 f3                	cmp    %esi,%ebx
  8011dd:	72 db                	jb     8011ba <readn+0x16>
  8011df:	89 d8                	mov    %ebx,%eax
  8011e1:	eb 02                	jmp    8011e5 <readn+0x41>
  8011e3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	53                   	push   %ebx
  8011f1:	83 ec 14             	sub    $0x14,%esp
  8011f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fa:	50                   	push   %eax
  8011fb:	53                   	push   %ebx
  8011fc:	e8 ac fc ff ff       	call   800ead <fd_lookup>
  801201:	83 c4 08             	add    $0x8,%esp
  801204:	89 c2                	mov    %eax,%edx
  801206:	85 c0                	test   %eax,%eax
  801208:	78 68                	js     801272 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801210:	50                   	push   %eax
  801211:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801214:	ff 30                	pushl  (%eax)
  801216:	e8 e8 fc ff ff       	call   800f03 <dev_lookup>
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	85 c0                	test   %eax,%eax
  801220:	78 47                	js     801269 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801222:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801225:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801229:	75 21                	jne    80124c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80122b:	a1 08 40 80 00       	mov    0x804008,%eax
  801230:	8b 40 48             	mov    0x48(%eax),%eax
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	53                   	push   %ebx
  801237:	50                   	push   %eax
  801238:	68 4c 24 80 00       	push   $0x80244c
  80123d:	e8 7c f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124a:	eb 26                	jmp    801272 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80124c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124f:	8b 52 0c             	mov    0xc(%edx),%edx
  801252:	85 d2                	test   %edx,%edx
  801254:	74 17                	je     80126d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801256:	83 ec 04             	sub    $0x4,%esp
  801259:	ff 75 10             	pushl  0x10(%ebp)
  80125c:	ff 75 0c             	pushl  0xc(%ebp)
  80125f:	50                   	push   %eax
  801260:	ff d2                	call   *%edx
  801262:	89 c2                	mov    %eax,%edx
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	eb 09                	jmp    801272 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801269:	89 c2                	mov    %eax,%edx
  80126b:	eb 05                	jmp    801272 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80126d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801272:	89 d0                	mov    %edx,%eax
  801274:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801277:	c9                   	leave  
  801278:	c3                   	ret    

00801279 <seek>:

int
seek(int fdnum, off_t offset)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80127f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	ff 75 08             	pushl  0x8(%ebp)
  801286:	e8 22 fc ff ff       	call   800ead <fd_lookup>
  80128b:	83 c4 08             	add    $0x8,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 0e                	js     8012a0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801292:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801295:	8b 55 0c             	mov    0xc(%ebp),%edx
  801298:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80129b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a0:	c9                   	leave  
  8012a1:	c3                   	ret    

008012a2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	53                   	push   %ebx
  8012a6:	83 ec 14             	sub    $0x14,%esp
  8012a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012af:	50                   	push   %eax
  8012b0:	53                   	push   %ebx
  8012b1:	e8 f7 fb ff ff       	call   800ead <fd_lookup>
  8012b6:	83 c4 08             	add    $0x8,%esp
  8012b9:	89 c2                	mov    %eax,%edx
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 65                	js     801324 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c5:	50                   	push   %eax
  8012c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c9:	ff 30                	pushl  (%eax)
  8012cb:	e8 33 fc ff ff       	call   800f03 <dev_lookup>
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 44                	js     80131b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012de:	75 21                	jne    801301 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012e0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e5:	8b 40 48             	mov    0x48(%eax),%eax
  8012e8:	83 ec 04             	sub    $0x4,%esp
  8012eb:	53                   	push   %ebx
  8012ec:	50                   	push   %eax
  8012ed:	68 0c 24 80 00       	push   $0x80240c
  8012f2:	e8 c7 ef ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ff:	eb 23                	jmp    801324 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801301:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801304:	8b 52 18             	mov    0x18(%edx),%edx
  801307:	85 d2                	test   %edx,%edx
  801309:	74 14                	je     80131f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	ff 75 0c             	pushl  0xc(%ebp)
  801311:	50                   	push   %eax
  801312:	ff d2                	call   *%edx
  801314:	89 c2                	mov    %eax,%edx
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	eb 09                	jmp    801324 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131b:	89 c2                	mov    %eax,%edx
  80131d:	eb 05                	jmp    801324 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80131f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801324:	89 d0                	mov    %edx,%eax
  801326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801329:	c9                   	leave  
  80132a:	c3                   	ret    

0080132b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	53                   	push   %ebx
  80132f:	83 ec 14             	sub    $0x14,%esp
  801332:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801335:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	ff 75 08             	pushl  0x8(%ebp)
  80133c:	e8 6c fb ff ff       	call   800ead <fd_lookup>
  801341:	83 c4 08             	add    $0x8,%esp
  801344:	89 c2                	mov    %eax,%edx
  801346:	85 c0                	test   %eax,%eax
  801348:	78 58                	js     8013a2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801350:	50                   	push   %eax
  801351:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801354:	ff 30                	pushl  (%eax)
  801356:	e8 a8 fb ff ff       	call   800f03 <dev_lookup>
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 37                	js     801399 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801362:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801365:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801369:	74 32                	je     80139d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80136b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80136e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801375:	00 00 00 
	stat->st_isdir = 0;
  801378:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80137f:	00 00 00 
	stat->st_dev = dev;
  801382:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	53                   	push   %ebx
  80138c:	ff 75 f0             	pushl  -0x10(%ebp)
  80138f:	ff 50 14             	call   *0x14(%eax)
  801392:	89 c2                	mov    %eax,%edx
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	eb 09                	jmp    8013a2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801399:	89 c2                	mov    %eax,%edx
  80139b:	eb 05                	jmp    8013a2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80139d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013a2:	89 d0                	mov    %edx,%eax
  8013a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a7:	c9                   	leave  
  8013a8:	c3                   	ret    

008013a9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	56                   	push   %esi
  8013ad:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ae:	83 ec 08             	sub    $0x8,%esp
  8013b1:	6a 00                	push   $0x0
  8013b3:	ff 75 08             	pushl  0x8(%ebp)
  8013b6:	e8 2c 02 00 00       	call   8015e7 <open>
  8013bb:	89 c3                	mov    %eax,%ebx
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 1b                	js     8013df <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013c4:	83 ec 08             	sub    $0x8,%esp
  8013c7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ca:	50                   	push   %eax
  8013cb:	e8 5b ff ff ff       	call   80132b <fstat>
  8013d0:	89 c6                	mov    %eax,%esi
	close(fd);
  8013d2:	89 1c 24             	mov    %ebx,(%esp)
  8013d5:	e8 fd fb ff ff       	call   800fd7 <close>
	return r;
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	89 f0                	mov    %esi,%eax
}
  8013df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e2:	5b                   	pop    %ebx
  8013e3:	5e                   	pop    %esi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	56                   	push   %esi
  8013ea:	53                   	push   %ebx
  8013eb:	89 c6                	mov    %eax,%esi
  8013ed:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  8013ef:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8013f6:	75 12                	jne    80140a <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	6a 01                	push   $0x1
  8013fd:	e8 2b 09 00 00       	call   801d2d <ipc_find_env>
  801402:	a3 04 40 80 00       	mov    %eax,0x804004
  801407:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80140a:	6a 07                	push   $0x7
  80140c:	68 00 50 80 00       	push   $0x805000
  801411:	56                   	push   %esi
  801412:	ff 35 04 40 80 00    	pushl  0x804004
  801418:	e8 bc 08 00 00       	call   801cd9 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  80141d:	83 c4 0c             	add    $0xc,%esp
  801420:	6a 00                	push   $0x0
  801422:	53                   	push   %ebx
  801423:	6a 00                	push   $0x0
  801425:	e8 50 08 00 00       	call   801c7a <ipc_recv>
}
  80142a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142d:	5b                   	pop    %ebx
  80142e:	5e                   	pop    %esi
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801437:	8b 45 08             	mov    0x8(%ebp),%eax
  80143a:	8b 40 0c             	mov    0xc(%eax),%eax
  80143d:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  801442:	8b 45 0c             	mov    0xc(%ebp),%eax
  801445:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80144a:	ba 00 00 00 00       	mov    $0x0,%edx
  80144f:	b8 02 00 00 00       	mov    $0x2,%eax
  801454:	e8 8d ff ff ff       	call   8013e6 <fsipc>
}
  801459:	c9                   	leave  
  80145a:	c3                   	ret    

0080145b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801461:	8b 45 08             	mov    0x8(%ebp),%eax
  801464:	8b 40 0c             	mov    0xc(%eax),%eax
  801467:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  80146c:	ba 00 00 00 00       	mov    $0x0,%edx
  801471:	b8 06 00 00 00       	mov    $0x6,%eax
  801476:	e8 6b ff ff ff       	call   8013e6 <fsipc>
}
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	53                   	push   %ebx
  801481:	83 ec 04             	sub    $0x4,%esp
  801484:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801487:	8b 45 08             	mov    0x8(%ebp),%eax
  80148a:	8b 40 0c             	mov    0xc(%eax),%eax
  80148d:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801492:	ba 00 00 00 00       	mov    $0x0,%edx
  801497:	b8 05 00 00 00       	mov    $0x5,%eax
  80149c:	e8 45 ff ff ff       	call   8013e6 <fsipc>
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 2c                	js     8014d1 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	68 00 50 80 00       	push   $0x805000
  8014ad:	53                   	push   %ebx
  8014ae:	e8 90 f3 ff ff       	call   800843 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8014b3:	a1 80 50 80 00       	mov    0x805080,%eax
  8014b8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014be:	a1 84 50 80 00       	mov    0x805084,%eax
  8014c3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d4:	c9                   	leave  
  8014d5:	c3                   	ret    

008014d6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	53                   	push   %ebx
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e6:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  8014eb:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  8014f1:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8014f7:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8014fc:	0f 46 c3             	cmovbe %ebx,%eax
  8014ff:	50                   	push   %eax
  801500:	ff 75 0c             	pushl  0xc(%ebp)
  801503:	68 08 50 80 00       	push   $0x805008
  801508:	e8 c8 f4 ff ff       	call   8009d5 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  80150d:	ba 00 00 00 00       	mov    $0x0,%edx
  801512:	b8 04 00 00 00       	mov    $0x4,%eax
  801517:	e8 ca fe ff ff       	call   8013e6 <fsipc>
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 3d                	js     801560 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  801523:	39 c3                	cmp    %eax,%ebx
  801525:	73 19                	jae    801540 <devfile_write+0x6a>
  801527:	68 7c 24 80 00       	push   $0x80247c
  80152c:	68 83 24 80 00       	push   $0x802483
  801531:	68 9a 00 00 00       	push   $0x9a
  801536:	68 98 24 80 00       	push   $0x802498
  80153b:	e8 a5 ec ff ff       	call   8001e5 <_panic>
	   assert (r <= bytes_written);
  801540:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801545:	7e 19                	jle    801560 <devfile_write+0x8a>
  801547:	68 a3 24 80 00       	push   $0x8024a3
  80154c:	68 83 24 80 00       	push   $0x802483
  801551:	68 9b 00 00 00       	push   $0x9b
  801556:	68 98 24 80 00       	push   $0x802498
  80155b:	e8 85 ec ff ff       	call   8001e5 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801560:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801563:	c9                   	leave  
  801564:	c3                   	ret    

00801565 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	56                   	push   %esi
  801569:	53                   	push   %ebx
  80156a:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  80156d:	8b 45 08             	mov    0x8(%ebp),%eax
  801570:	8b 40 0c             	mov    0xc(%eax),%eax
  801573:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  801578:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80157e:	ba 00 00 00 00       	mov    $0x0,%edx
  801583:	b8 03 00 00 00       	mov    $0x3,%eax
  801588:	e8 59 fe ff ff       	call   8013e6 <fsipc>
  80158d:	89 c3                	mov    %eax,%ebx
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 4b                	js     8015de <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  801593:	39 c6                	cmp    %eax,%esi
  801595:	73 16                	jae    8015ad <devfile_read+0x48>
  801597:	68 7c 24 80 00       	push   $0x80247c
  80159c:	68 83 24 80 00       	push   $0x802483
  8015a1:	6a 7c                	push   $0x7c
  8015a3:	68 98 24 80 00       	push   $0x802498
  8015a8:	e8 38 ec ff ff       	call   8001e5 <_panic>
	   assert(r <= PGSIZE);
  8015ad:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015b2:	7e 16                	jle    8015ca <devfile_read+0x65>
  8015b4:	68 b6 24 80 00       	push   $0x8024b6
  8015b9:	68 83 24 80 00       	push   $0x802483
  8015be:	6a 7d                	push   $0x7d
  8015c0:	68 98 24 80 00       	push   $0x802498
  8015c5:	e8 1b ec ff ff       	call   8001e5 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ca:	83 ec 04             	sub    $0x4,%esp
  8015cd:	50                   	push   %eax
  8015ce:	68 00 50 80 00       	push   $0x805000
  8015d3:	ff 75 0c             	pushl  0xc(%ebp)
  8015d6:	e8 fa f3 ff ff       	call   8009d5 <memmove>
	   return r;
  8015db:	83 c4 10             	add    $0x10,%esp
}
  8015de:	89 d8                	mov    %ebx,%eax
  8015e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e3:	5b                   	pop    %ebx
  8015e4:	5e                   	pop    %esi
  8015e5:	5d                   	pop    %ebp
  8015e6:	c3                   	ret    

008015e7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	53                   	push   %ebx
  8015eb:	83 ec 20             	sub    $0x20,%esp
  8015ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  8015f1:	53                   	push   %ebx
  8015f2:	e8 13 f2 ff ff       	call   80080a <strlen>
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ff:	7f 67                	jg     801668 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801601:	83 ec 0c             	sub    $0xc,%esp
  801604:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801607:	50                   	push   %eax
  801608:	e8 51 f8 ff ff       	call   800e5e <fd_alloc>
  80160d:	83 c4 10             	add    $0x10,%esp
			 return r;
  801610:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801612:	85 c0                	test   %eax,%eax
  801614:	78 57                	js     80166d <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	53                   	push   %ebx
  80161a:	68 00 50 80 00       	push   $0x805000
  80161f:	e8 1f f2 ff ff       	call   800843 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  801624:	8b 45 0c             	mov    0xc(%ebp),%eax
  801627:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80162c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162f:	b8 01 00 00 00       	mov    $0x1,%eax
  801634:	e8 ad fd ff ff       	call   8013e6 <fsipc>
  801639:	89 c3                	mov    %eax,%ebx
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	85 c0                	test   %eax,%eax
  801640:	79 14                	jns    801656 <open+0x6f>
			 fd_close(fd, 0);
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	6a 00                	push   $0x0
  801647:	ff 75 f4             	pushl  -0xc(%ebp)
  80164a:	e8 07 f9 ff ff       	call   800f56 <fd_close>
			 return r;
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	89 da                	mov    %ebx,%edx
  801654:	eb 17                	jmp    80166d <open+0x86>
	   }

	   return fd2num(fd);
  801656:	83 ec 0c             	sub    $0xc,%esp
  801659:	ff 75 f4             	pushl  -0xc(%ebp)
  80165c:	e8 d6 f7 ff ff       	call   800e37 <fd2num>
  801661:	89 c2                	mov    %eax,%edx
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	eb 05                	jmp    80166d <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  801668:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  80166d:	89 d0                	mov    %edx,%eax
  80166f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  80167a:	ba 00 00 00 00       	mov    $0x0,%edx
  80167f:	b8 08 00 00 00       	mov    $0x8,%eax
  801684:	e8 5d fd ff ff       	call   8013e6 <fsipc>
}
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80168b:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80168f:	7e 37                	jle    8016c8 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	53                   	push   %ebx
  801695:	83 ec 08             	sub    $0x8,%esp
  801698:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80169a:	ff 70 04             	pushl  0x4(%eax)
  80169d:	8d 40 10             	lea    0x10(%eax),%eax
  8016a0:	50                   	push   %eax
  8016a1:	ff 33                	pushl  (%ebx)
  8016a3:	e8 45 fb ff ff       	call   8011ed <write>
		if (result > 0)
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	7e 03                	jle    8016b2 <writebuf+0x27>
			b->result += result;
  8016af:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016b2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016b5:	74 0d                	je     8016c4 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016be:	0f 4f c2             	cmovg  %edx,%eax
  8016c1:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c7:	c9                   	leave  
  8016c8:	f3 c3                	repz ret 

008016ca <putch>:

static void
putch(int ch, void *thunk)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 04             	sub    $0x4,%esp
  8016d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016d4:	8b 53 04             	mov    0x4(%ebx),%edx
  8016d7:	8d 42 01             	lea    0x1(%edx),%eax
  8016da:	89 43 04             	mov    %eax,0x4(%ebx)
  8016dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e0:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016e4:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016e9:	75 0e                	jne    8016f9 <putch+0x2f>
		writebuf(b);
  8016eb:	89 d8                	mov    %ebx,%eax
  8016ed:	e8 99 ff ff ff       	call   80168b <writebuf>
		b->idx = 0;
  8016f2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016f9:	83 c4 04             	add    $0x4,%esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801708:	8b 45 08             	mov    0x8(%ebp),%eax
  80170b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801711:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801718:	00 00 00 
	b.result = 0;
  80171b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801722:	00 00 00 
	b.error = 1;
  801725:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80172c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80172f:	ff 75 10             	pushl  0x10(%ebp)
  801732:	ff 75 0c             	pushl  0xc(%ebp)
  801735:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80173b:	50                   	push   %eax
  80173c:	68 ca 16 80 00       	push   $0x8016ca
  801741:	e8 af ec ff ff       	call   8003f5 <vprintfmt>
	if (b.idx > 0)
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801750:	7e 0b                	jle    80175d <vfprintf+0x5e>
		writebuf(&b);
  801752:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801758:	e8 2e ff ff ff       	call   80168b <writebuf>

	return (b.result ? b.result : b.error);
  80175d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801763:	85 c0                	test   %eax,%eax
  801765:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    

0080176e <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801774:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801777:	50                   	push   %eax
  801778:	ff 75 0c             	pushl  0xc(%ebp)
  80177b:	ff 75 08             	pushl  0x8(%ebp)
  80177e:	e8 7c ff ff ff       	call   8016ff <vfprintf>
	va_end(ap);

	return cnt;
}
  801783:	c9                   	leave  
  801784:	c3                   	ret    

00801785 <printf>:

int
printf(const char *fmt, ...)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80178b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80178e:	50                   	push   %eax
  80178f:	ff 75 08             	pushl  0x8(%ebp)
  801792:	6a 01                	push   $0x1
  801794:	e8 66 ff ff ff       	call   8016ff <vfprintf>
	va_end(ap);

	return cnt;
}
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	56                   	push   %esi
  80179f:	53                   	push   %ebx
  8017a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017a3:	83 ec 0c             	sub    $0xc,%esp
  8017a6:	ff 75 08             	pushl  0x8(%ebp)
  8017a9:	e8 99 f6 ff ff       	call   800e47 <fd2data>
  8017ae:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017b0:	83 c4 08             	add    $0x8,%esp
  8017b3:	68 c2 24 80 00       	push   $0x8024c2
  8017b8:	53                   	push   %ebx
  8017b9:	e8 85 f0 ff ff       	call   800843 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017be:	8b 46 04             	mov    0x4(%esi),%eax
  8017c1:	2b 06                	sub    (%esi),%eax
  8017c3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017c9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017d0:	00 00 00 
	stat->st_dev = &devpipe;
  8017d3:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8017da:	30 80 00 
	return 0;
}
  8017dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	53                   	push   %ebx
  8017ed:	83 ec 0c             	sub    $0xc,%esp
  8017f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017f3:	53                   	push   %ebx
  8017f4:	6a 00                	push   $0x0
  8017f6:	e8 d0 f4 ff ff       	call   800ccb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017fb:	89 1c 24             	mov    %ebx,(%esp)
  8017fe:	e8 44 f6 ff ff       	call   800e47 <fd2data>
  801803:	83 c4 08             	add    $0x8,%esp
  801806:	50                   	push   %eax
  801807:	6a 00                	push   $0x0
  801809:	e8 bd f4 ff ff       	call   800ccb <sys_page_unmap>
}
  80180e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801811:	c9                   	leave  
  801812:	c3                   	ret    

00801813 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	57                   	push   %edi
  801817:	56                   	push   %esi
  801818:	53                   	push   %ebx
  801819:	83 ec 1c             	sub    $0x1c,%esp
  80181c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80181f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801821:	a1 08 40 80 00       	mov    0x804008,%eax
  801826:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801829:	83 ec 0c             	sub    $0xc,%esp
  80182c:	ff 75 e0             	pushl  -0x20(%ebp)
  80182f:	e8 32 05 00 00       	call   801d66 <pageref>
  801834:	89 c3                	mov    %eax,%ebx
  801836:	89 3c 24             	mov    %edi,(%esp)
  801839:	e8 28 05 00 00       	call   801d66 <pageref>
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	39 c3                	cmp    %eax,%ebx
  801843:	0f 94 c1             	sete   %cl
  801846:	0f b6 c9             	movzbl %cl,%ecx
  801849:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80184c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801852:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801855:	39 ce                	cmp    %ecx,%esi
  801857:	74 1b                	je     801874 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801859:	39 c3                	cmp    %eax,%ebx
  80185b:	75 c4                	jne    801821 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80185d:	8b 42 58             	mov    0x58(%edx),%eax
  801860:	ff 75 e4             	pushl  -0x1c(%ebp)
  801863:	50                   	push   %eax
  801864:	56                   	push   %esi
  801865:	68 c9 24 80 00       	push   $0x8024c9
  80186a:	e8 4f ea ff ff       	call   8002be <cprintf>
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	eb ad                	jmp    801821 <_pipeisclosed+0xe>
	}
}
  801874:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801877:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5f                   	pop    %edi
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	57                   	push   %edi
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
  801885:	83 ec 28             	sub    $0x28,%esp
  801888:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80188b:	56                   	push   %esi
  80188c:	e8 b6 f5 ff ff       	call   800e47 <fd2data>
  801891:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	bf 00 00 00 00       	mov    $0x0,%edi
  80189b:	eb 4b                	jmp    8018e8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80189d:	89 da                	mov    %ebx,%edx
  80189f:	89 f0                	mov    %esi,%eax
  8018a1:	e8 6d ff ff ff       	call   801813 <_pipeisclosed>
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	75 48                	jne    8018f2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018aa:	e8 78 f3 ff ff       	call   800c27 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018af:	8b 43 04             	mov    0x4(%ebx),%eax
  8018b2:	8b 0b                	mov    (%ebx),%ecx
  8018b4:	8d 51 20             	lea    0x20(%ecx),%edx
  8018b7:	39 d0                	cmp    %edx,%eax
  8018b9:	73 e2                	jae    80189d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018be:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018c2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018c5:	89 c2                	mov    %eax,%edx
  8018c7:	c1 fa 1f             	sar    $0x1f,%edx
  8018ca:	89 d1                	mov    %edx,%ecx
  8018cc:	c1 e9 1b             	shr    $0x1b,%ecx
  8018cf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018d2:	83 e2 1f             	and    $0x1f,%edx
  8018d5:	29 ca                	sub    %ecx,%edx
  8018d7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018df:	83 c0 01             	add    $0x1,%eax
  8018e2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018e5:	83 c7 01             	add    $0x1,%edi
  8018e8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018eb:	75 c2                	jne    8018af <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8018f0:	eb 05                	jmp    8018f7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018f2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5f                   	pop    %edi
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	57                   	push   %edi
  801903:	56                   	push   %esi
  801904:	53                   	push   %ebx
  801905:	83 ec 18             	sub    $0x18,%esp
  801908:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80190b:	57                   	push   %edi
  80190c:	e8 36 f5 ff ff       	call   800e47 <fd2data>
  801911:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	bb 00 00 00 00       	mov    $0x0,%ebx
  80191b:	eb 3d                	jmp    80195a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80191d:	85 db                	test   %ebx,%ebx
  80191f:	74 04                	je     801925 <devpipe_read+0x26>
				return i;
  801921:	89 d8                	mov    %ebx,%eax
  801923:	eb 44                	jmp    801969 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801925:	89 f2                	mov    %esi,%edx
  801927:	89 f8                	mov    %edi,%eax
  801929:	e8 e5 fe ff ff       	call   801813 <_pipeisclosed>
  80192e:	85 c0                	test   %eax,%eax
  801930:	75 32                	jne    801964 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801932:	e8 f0 f2 ff ff       	call   800c27 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801937:	8b 06                	mov    (%esi),%eax
  801939:	3b 46 04             	cmp    0x4(%esi),%eax
  80193c:	74 df                	je     80191d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80193e:	99                   	cltd   
  80193f:	c1 ea 1b             	shr    $0x1b,%edx
  801942:	01 d0                	add    %edx,%eax
  801944:	83 e0 1f             	and    $0x1f,%eax
  801947:	29 d0                	sub    %edx,%eax
  801949:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80194e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801951:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801954:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801957:	83 c3 01             	add    $0x1,%ebx
  80195a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80195d:	75 d8                	jne    801937 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80195f:	8b 45 10             	mov    0x10(%ebp),%eax
  801962:	eb 05                	jmp    801969 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801964:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801969:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80196c:	5b                   	pop    %ebx
  80196d:	5e                   	pop    %esi
  80196e:	5f                   	pop    %edi
  80196f:	5d                   	pop    %ebp
  801970:	c3                   	ret    

00801971 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	56                   	push   %esi
  801975:	53                   	push   %ebx
  801976:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801979:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197c:	50                   	push   %eax
  80197d:	e8 dc f4 ff ff       	call   800e5e <fd_alloc>
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	89 c2                	mov    %eax,%edx
  801987:	85 c0                	test   %eax,%eax
  801989:	0f 88 2c 01 00 00    	js     801abb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80198f:	83 ec 04             	sub    $0x4,%esp
  801992:	68 07 04 00 00       	push   $0x407
  801997:	ff 75 f4             	pushl  -0xc(%ebp)
  80199a:	6a 00                	push   $0x0
  80199c:	e8 a5 f2 ff ff       	call   800c46 <sys_page_alloc>
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	89 c2                	mov    %eax,%edx
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	0f 88 0d 01 00 00    	js     801abb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b4:	50                   	push   %eax
  8019b5:	e8 a4 f4 ff ff       	call   800e5e <fd_alloc>
  8019ba:	89 c3                	mov    %eax,%ebx
  8019bc:	83 c4 10             	add    $0x10,%esp
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	0f 88 e2 00 00 00    	js     801aa9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c7:	83 ec 04             	sub    $0x4,%esp
  8019ca:	68 07 04 00 00       	push   $0x407
  8019cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8019d2:	6a 00                	push   $0x0
  8019d4:	e8 6d f2 ff ff       	call   800c46 <sys_page_alloc>
  8019d9:	89 c3                	mov    %eax,%ebx
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	0f 88 c3 00 00 00    	js     801aa9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ec:	e8 56 f4 ff ff       	call   800e47 <fd2data>
  8019f1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f3:	83 c4 0c             	add    $0xc,%esp
  8019f6:	68 07 04 00 00       	push   $0x407
  8019fb:	50                   	push   %eax
  8019fc:	6a 00                	push   $0x0
  8019fe:	e8 43 f2 ff ff       	call   800c46 <sys_page_alloc>
  801a03:	89 c3                	mov    %eax,%ebx
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	0f 88 89 00 00 00    	js     801a99 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a10:	83 ec 0c             	sub    $0xc,%esp
  801a13:	ff 75 f0             	pushl  -0x10(%ebp)
  801a16:	e8 2c f4 ff ff       	call   800e47 <fd2data>
  801a1b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a22:	50                   	push   %eax
  801a23:	6a 00                	push   $0x0
  801a25:	56                   	push   %esi
  801a26:	6a 00                	push   $0x0
  801a28:	e8 5c f2 ff ff       	call   800c89 <sys_page_map>
  801a2d:	89 c3                	mov    %eax,%ebx
  801a2f:	83 c4 20             	add    $0x20,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 55                	js     801a8b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a36:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a44:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a4b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a54:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a59:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	ff 75 f4             	pushl  -0xc(%ebp)
  801a66:	e8 cc f3 ff ff       	call   800e37 <fd2num>
  801a6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a6e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a70:	83 c4 04             	add    $0x4,%esp
  801a73:	ff 75 f0             	pushl  -0x10(%ebp)
  801a76:	e8 bc f3 ff ff       	call   800e37 <fd2num>
  801a7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a7e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a81:	83 c4 10             	add    $0x10,%esp
  801a84:	ba 00 00 00 00       	mov    $0x0,%edx
  801a89:	eb 30                	jmp    801abb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a8b:	83 ec 08             	sub    $0x8,%esp
  801a8e:	56                   	push   %esi
  801a8f:	6a 00                	push   $0x0
  801a91:	e8 35 f2 ff ff       	call   800ccb <sys_page_unmap>
  801a96:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a99:	83 ec 08             	sub    $0x8,%esp
  801a9c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a9f:	6a 00                	push   $0x0
  801aa1:	e8 25 f2 ff ff       	call   800ccb <sys_page_unmap>
  801aa6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801aa9:	83 ec 08             	sub    $0x8,%esp
  801aac:	ff 75 f4             	pushl  -0xc(%ebp)
  801aaf:	6a 00                	push   $0x0
  801ab1:	e8 15 f2 ff ff       	call   800ccb <sys_page_unmap>
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801abb:	89 d0                	mov    %edx,%eax
  801abd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac0:	5b                   	pop    %ebx
  801ac1:	5e                   	pop    %esi
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    

00801ac4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acd:	50                   	push   %eax
  801ace:	ff 75 08             	pushl  0x8(%ebp)
  801ad1:	e8 d7 f3 ff ff       	call   800ead <fd_lookup>
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	78 18                	js     801af5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801add:	83 ec 0c             	sub    $0xc,%esp
  801ae0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae3:	e8 5f f3 ff ff       	call   800e47 <fd2data>
	return _pipeisclosed(fd, p);
  801ae8:	89 c2                	mov    %eax,%edx
  801aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aed:	e8 21 fd ff ff       	call   801813 <_pipeisclosed>
  801af2:	83 c4 10             	add    $0x10,%esp
}
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801afa:	b8 00 00 00 00       	mov    $0x0,%eax
  801aff:	5d                   	pop    %ebp
  801b00:	c3                   	ret    

00801b01 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b07:	68 e1 24 80 00       	push   $0x8024e1
  801b0c:	ff 75 0c             	pushl  0xc(%ebp)
  801b0f:	e8 2f ed ff ff       	call   800843 <strcpy>
	return 0;
}
  801b14:	b8 00 00 00 00       	mov    $0x0,%eax
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	57                   	push   %edi
  801b1f:	56                   	push   %esi
  801b20:	53                   	push   %ebx
  801b21:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b27:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b2c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b32:	eb 2d                	jmp    801b61 <devcons_write+0x46>
		m = n - tot;
  801b34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b37:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b39:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b3c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b41:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b44:	83 ec 04             	sub    $0x4,%esp
  801b47:	53                   	push   %ebx
  801b48:	03 45 0c             	add    0xc(%ebp),%eax
  801b4b:	50                   	push   %eax
  801b4c:	57                   	push   %edi
  801b4d:	e8 83 ee ff ff       	call   8009d5 <memmove>
		sys_cputs(buf, m);
  801b52:	83 c4 08             	add    $0x8,%esp
  801b55:	53                   	push   %ebx
  801b56:	57                   	push   %edi
  801b57:	e8 2e f0 ff ff       	call   800b8a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b5c:	01 de                	add    %ebx,%esi
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	89 f0                	mov    %esi,%eax
  801b63:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b66:	72 cc                	jb     801b34 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6b:	5b                   	pop    %ebx
  801b6c:	5e                   	pop    %esi
  801b6d:	5f                   	pop    %edi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	83 ec 08             	sub    $0x8,%esp
  801b76:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b7f:	74 2a                	je     801bab <devcons_read+0x3b>
  801b81:	eb 05                	jmp    801b88 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b83:	e8 9f f0 ff ff       	call   800c27 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b88:	e8 1b f0 ff ff       	call   800ba8 <sys_cgetc>
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	74 f2                	je     801b83 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b91:	85 c0                	test   %eax,%eax
  801b93:	78 16                	js     801bab <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b95:	83 f8 04             	cmp    $0x4,%eax
  801b98:	74 0c                	je     801ba6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b9d:	88 02                	mov    %al,(%edx)
	return 1;
  801b9f:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba4:	eb 05                	jmp    801bab <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ba6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801bab:	c9                   	leave  
  801bac:	c3                   	ret    

00801bad <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bb9:	6a 01                	push   $0x1
  801bbb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bbe:	50                   	push   %eax
  801bbf:	e8 c6 ef ff ff       	call   800b8a <sys_cputs>
}
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	c9                   	leave  
  801bc8:	c3                   	ret    

00801bc9 <getchar>:

int
getchar(void)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bcf:	6a 01                	push   $0x1
  801bd1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bd4:	50                   	push   %eax
  801bd5:	6a 00                	push   $0x0
  801bd7:	e8 37 f5 ff ff       	call   801113 <read>
	if (r < 0)
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	78 0f                	js     801bf2 <getchar+0x29>
		return r;
	if (r < 1)
  801be3:	85 c0                	test   %eax,%eax
  801be5:	7e 06                	jle    801bed <getchar+0x24>
		return -E_EOF;
	return c;
  801be7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801beb:	eb 05                	jmp    801bf2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bed:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bf2:	c9                   	leave  
  801bf3:	c3                   	ret    

00801bf4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfd:	50                   	push   %eax
  801bfe:	ff 75 08             	pushl  0x8(%ebp)
  801c01:	e8 a7 f2 ff ff       	call   800ead <fd_lookup>
  801c06:	83 c4 10             	add    $0x10,%esp
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	78 11                	js     801c1e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c10:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c16:	39 10                	cmp    %edx,(%eax)
  801c18:	0f 94 c0             	sete   %al
  801c1b:	0f b6 c0             	movzbl %al,%eax
}
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <opencons>:

int
opencons(void)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c29:	50                   	push   %eax
  801c2a:	e8 2f f2 ff ff       	call   800e5e <fd_alloc>
  801c2f:	83 c4 10             	add    $0x10,%esp
		return r;
  801c32:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c34:	85 c0                	test   %eax,%eax
  801c36:	78 3e                	js     801c76 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c38:	83 ec 04             	sub    $0x4,%esp
  801c3b:	68 07 04 00 00       	push   $0x407
  801c40:	ff 75 f4             	pushl  -0xc(%ebp)
  801c43:	6a 00                	push   $0x0
  801c45:	e8 fc ef ff ff       	call   800c46 <sys_page_alloc>
  801c4a:	83 c4 10             	add    $0x10,%esp
		return r;
  801c4d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	78 23                	js     801c76 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c53:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c61:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c68:	83 ec 0c             	sub    $0xc,%esp
  801c6b:	50                   	push   %eax
  801c6c:	e8 c6 f1 ff ff       	call   800e37 <fd2num>
  801c71:	89 c2                	mov    %eax,%edx
  801c73:	83 c4 10             	add    $0x10,%esp
}
  801c76:	89 d0                	mov    %edx,%eax
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    

00801c7a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	56                   	push   %esi
  801c7e:	53                   	push   %ebx
  801c7f:	8b 75 08             	mov    0x8(%ebp),%esi
  801c82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801c88:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801c8a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801c8f:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801c92:	83 ec 0c             	sub    $0xc,%esp
  801c95:	50                   	push   %eax
  801c96:	e8 5b f1 ff ff       	call   800df6 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	78 0e                	js     801cb0 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801ca2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ca8:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801cab:	8b 52 78             	mov    0x78(%edx),%edx
  801cae:	eb 0a                	jmp    801cba <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801cb0:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801cb5:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801cba:	85 f6                	test   %esi,%esi
  801cbc:	74 02                	je     801cc0 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801cbe:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801cc0:	85 db                	test   %ebx,%ebx
  801cc2:	74 02                	je     801cc6 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801cc4:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 08                	js     801cd2 <ipc_recv+0x58>
  801cca:	a1 08 40 80 00       	mov    0x804008,%eax
  801ccf:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801cd2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd5:	5b                   	pop    %ebx
  801cd6:	5e                   	pop    %esi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    

00801cd9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	57                   	push   %edi
  801cdd:	56                   	push   %esi
  801cde:	53                   	push   %ebx
  801cdf:	83 ec 0c             	sub    $0xc,%esp
  801ce2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ce5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801ceb:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801ced:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801cf2:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801cf5:	ff 75 14             	pushl  0x14(%ebp)
  801cf8:	53                   	push   %ebx
  801cf9:	56                   	push   %esi
  801cfa:	57                   	push   %edi
  801cfb:	e8 d3 f0 ff ff       	call   800dd3 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d06:	75 07                	jne    801d0f <ipc_send+0x36>
				    sys_yield();
  801d08:	e8 1a ef ff ff       	call   800c27 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801d0d:	eb e6                	jmp    801cf5 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	74 12                	je     801d25 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801d13:	50                   	push   %eax
  801d14:	68 ed 24 80 00       	push   $0x8024ed
  801d19:	6a 4b                	push   $0x4b
  801d1b:	68 01 25 80 00       	push   $0x802501
  801d20:	e8 c0 e4 ff ff       	call   8001e5 <_panic>
			 }
	   }
}
  801d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d28:	5b                   	pop    %ebx
  801d29:	5e                   	pop    %esi
  801d2a:	5f                   	pop    %edi
  801d2b:	5d                   	pop    %ebp
  801d2c:	c3                   	ret    

00801d2d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
  801d30:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801d38:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d3b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d41:	8b 52 50             	mov    0x50(%edx),%edx
  801d44:	39 ca                	cmp    %ecx,%edx
  801d46:	75 0d                	jne    801d55 <ipc_find_env+0x28>
				    return envs[i].env_id;
  801d48:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d4b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d50:	8b 40 48             	mov    0x48(%eax),%eax
  801d53:	eb 0f                	jmp    801d64 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801d55:	83 c0 01             	add    $0x1,%eax
  801d58:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d5d:	75 d9                	jne    801d38 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801d5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d6c:	89 d0                	mov    %edx,%eax
  801d6e:	c1 e8 16             	shr    $0x16,%eax
  801d71:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d78:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d7d:	f6 c1 01             	test   $0x1,%cl
  801d80:	74 1d                	je     801d9f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d82:	c1 ea 0c             	shr    $0xc,%edx
  801d85:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d8c:	f6 c2 01             	test   $0x1,%dl
  801d8f:	74 0e                	je     801d9f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d91:	c1 ea 0c             	shr    $0xc,%edx
  801d94:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d9b:	ef 
  801d9c:	0f b7 c0             	movzwl %ax,%eax
}
  801d9f:	5d                   	pop    %ebp
  801da0:	c3                   	ret    
  801da1:	66 90                	xchg   %ax,%ax
  801da3:	66 90                	xchg   %ax,%ax
  801da5:	66 90                	xchg   %ax,%ax
  801da7:	66 90                	xchg   %ax,%ax
  801da9:	66 90                	xchg   %ax,%ax
  801dab:	66 90                	xchg   %ax,%ax
  801dad:	66 90                	xchg   %ax,%ax
  801daf:	90                   	nop

00801db0 <__udivdi3>:
  801db0:	55                   	push   %ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	83 ec 1c             	sub    $0x1c,%esp
  801db7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801dbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801dbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dc7:	85 f6                	test   %esi,%esi
  801dc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dcd:	89 ca                	mov    %ecx,%edx
  801dcf:	89 f8                	mov    %edi,%eax
  801dd1:	75 3d                	jne    801e10 <__udivdi3+0x60>
  801dd3:	39 cf                	cmp    %ecx,%edi
  801dd5:	0f 87 c5 00 00 00    	ja     801ea0 <__udivdi3+0xf0>
  801ddb:	85 ff                	test   %edi,%edi
  801ddd:	89 fd                	mov    %edi,%ebp
  801ddf:	75 0b                	jne    801dec <__udivdi3+0x3c>
  801de1:	b8 01 00 00 00       	mov    $0x1,%eax
  801de6:	31 d2                	xor    %edx,%edx
  801de8:	f7 f7                	div    %edi
  801dea:	89 c5                	mov    %eax,%ebp
  801dec:	89 c8                	mov    %ecx,%eax
  801dee:	31 d2                	xor    %edx,%edx
  801df0:	f7 f5                	div    %ebp
  801df2:	89 c1                	mov    %eax,%ecx
  801df4:	89 d8                	mov    %ebx,%eax
  801df6:	89 cf                	mov    %ecx,%edi
  801df8:	f7 f5                	div    %ebp
  801dfa:	89 c3                	mov    %eax,%ebx
  801dfc:	89 d8                	mov    %ebx,%eax
  801dfe:	89 fa                	mov    %edi,%edx
  801e00:	83 c4 1c             	add    $0x1c,%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    
  801e08:	90                   	nop
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	39 ce                	cmp    %ecx,%esi
  801e12:	77 74                	ja     801e88 <__udivdi3+0xd8>
  801e14:	0f bd fe             	bsr    %esi,%edi
  801e17:	83 f7 1f             	xor    $0x1f,%edi
  801e1a:	0f 84 98 00 00 00    	je     801eb8 <__udivdi3+0x108>
  801e20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e25:	89 f9                	mov    %edi,%ecx
  801e27:	89 c5                	mov    %eax,%ebp
  801e29:	29 fb                	sub    %edi,%ebx
  801e2b:	d3 e6                	shl    %cl,%esi
  801e2d:	89 d9                	mov    %ebx,%ecx
  801e2f:	d3 ed                	shr    %cl,%ebp
  801e31:	89 f9                	mov    %edi,%ecx
  801e33:	d3 e0                	shl    %cl,%eax
  801e35:	09 ee                	or     %ebp,%esi
  801e37:	89 d9                	mov    %ebx,%ecx
  801e39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e3d:	89 d5                	mov    %edx,%ebp
  801e3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e43:	d3 ed                	shr    %cl,%ebp
  801e45:	89 f9                	mov    %edi,%ecx
  801e47:	d3 e2                	shl    %cl,%edx
  801e49:	89 d9                	mov    %ebx,%ecx
  801e4b:	d3 e8                	shr    %cl,%eax
  801e4d:	09 c2                	or     %eax,%edx
  801e4f:	89 d0                	mov    %edx,%eax
  801e51:	89 ea                	mov    %ebp,%edx
  801e53:	f7 f6                	div    %esi
  801e55:	89 d5                	mov    %edx,%ebp
  801e57:	89 c3                	mov    %eax,%ebx
  801e59:	f7 64 24 0c          	mull   0xc(%esp)
  801e5d:	39 d5                	cmp    %edx,%ebp
  801e5f:	72 10                	jb     801e71 <__udivdi3+0xc1>
  801e61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e65:	89 f9                	mov    %edi,%ecx
  801e67:	d3 e6                	shl    %cl,%esi
  801e69:	39 c6                	cmp    %eax,%esi
  801e6b:	73 07                	jae    801e74 <__udivdi3+0xc4>
  801e6d:	39 d5                	cmp    %edx,%ebp
  801e6f:	75 03                	jne    801e74 <__udivdi3+0xc4>
  801e71:	83 eb 01             	sub    $0x1,%ebx
  801e74:	31 ff                	xor    %edi,%edi
  801e76:	89 d8                	mov    %ebx,%eax
  801e78:	89 fa                	mov    %edi,%edx
  801e7a:	83 c4 1c             	add    $0x1c,%esp
  801e7d:	5b                   	pop    %ebx
  801e7e:	5e                   	pop    %esi
  801e7f:	5f                   	pop    %edi
  801e80:	5d                   	pop    %ebp
  801e81:	c3                   	ret    
  801e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e88:	31 ff                	xor    %edi,%edi
  801e8a:	31 db                	xor    %ebx,%ebx
  801e8c:	89 d8                	mov    %ebx,%eax
  801e8e:	89 fa                	mov    %edi,%edx
  801e90:	83 c4 1c             	add    $0x1c,%esp
  801e93:	5b                   	pop    %ebx
  801e94:	5e                   	pop    %esi
  801e95:	5f                   	pop    %edi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    
  801e98:	90                   	nop
  801e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ea0:	89 d8                	mov    %ebx,%eax
  801ea2:	f7 f7                	div    %edi
  801ea4:	31 ff                	xor    %edi,%edi
  801ea6:	89 c3                	mov    %eax,%ebx
  801ea8:	89 d8                	mov    %ebx,%eax
  801eaa:	89 fa                	mov    %edi,%edx
  801eac:	83 c4 1c             	add    $0x1c,%esp
  801eaf:	5b                   	pop    %ebx
  801eb0:	5e                   	pop    %esi
  801eb1:	5f                   	pop    %edi
  801eb2:	5d                   	pop    %ebp
  801eb3:	c3                   	ret    
  801eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801eb8:	39 ce                	cmp    %ecx,%esi
  801eba:	72 0c                	jb     801ec8 <__udivdi3+0x118>
  801ebc:	31 db                	xor    %ebx,%ebx
  801ebe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ec2:	0f 87 34 ff ff ff    	ja     801dfc <__udivdi3+0x4c>
  801ec8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ecd:	e9 2a ff ff ff       	jmp    801dfc <__udivdi3+0x4c>
  801ed2:	66 90                	xchg   %ax,%ax
  801ed4:	66 90                	xchg   %ax,%ax
  801ed6:	66 90                	xchg   %ax,%ax
  801ed8:	66 90                	xchg   %ax,%ax
  801eda:	66 90                	xchg   %ax,%ax
  801edc:	66 90                	xchg   %ax,%ax
  801ede:	66 90                	xchg   %ax,%ax

00801ee0 <__umoddi3>:
  801ee0:	55                   	push   %ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 1c             	sub    $0x1c,%esp
  801ee7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801eeb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801eef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ef3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ef7:	85 d2                	test   %edx,%edx
  801ef9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801efd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f01:	89 f3                	mov    %esi,%ebx
  801f03:	89 3c 24             	mov    %edi,(%esp)
  801f06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f0a:	75 1c                	jne    801f28 <__umoddi3+0x48>
  801f0c:	39 f7                	cmp    %esi,%edi
  801f0e:	76 50                	jbe    801f60 <__umoddi3+0x80>
  801f10:	89 c8                	mov    %ecx,%eax
  801f12:	89 f2                	mov    %esi,%edx
  801f14:	f7 f7                	div    %edi
  801f16:	89 d0                	mov    %edx,%eax
  801f18:	31 d2                	xor    %edx,%edx
  801f1a:	83 c4 1c             	add    $0x1c,%esp
  801f1d:	5b                   	pop    %ebx
  801f1e:	5e                   	pop    %esi
  801f1f:	5f                   	pop    %edi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    
  801f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f28:	39 f2                	cmp    %esi,%edx
  801f2a:	89 d0                	mov    %edx,%eax
  801f2c:	77 52                	ja     801f80 <__umoddi3+0xa0>
  801f2e:	0f bd ea             	bsr    %edx,%ebp
  801f31:	83 f5 1f             	xor    $0x1f,%ebp
  801f34:	75 5a                	jne    801f90 <__umoddi3+0xb0>
  801f36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f3a:	0f 82 e0 00 00 00    	jb     802020 <__umoddi3+0x140>
  801f40:	39 0c 24             	cmp    %ecx,(%esp)
  801f43:	0f 86 d7 00 00 00    	jbe    802020 <__umoddi3+0x140>
  801f49:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f51:	83 c4 1c             	add    $0x1c,%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5f                   	pop    %edi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    
  801f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f60:	85 ff                	test   %edi,%edi
  801f62:	89 fd                	mov    %edi,%ebp
  801f64:	75 0b                	jne    801f71 <__umoddi3+0x91>
  801f66:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6b:	31 d2                	xor    %edx,%edx
  801f6d:	f7 f7                	div    %edi
  801f6f:	89 c5                	mov    %eax,%ebp
  801f71:	89 f0                	mov    %esi,%eax
  801f73:	31 d2                	xor    %edx,%edx
  801f75:	f7 f5                	div    %ebp
  801f77:	89 c8                	mov    %ecx,%eax
  801f79:	f7 f5                	div    %ebp
  801f7b:	89 d0                	mov    %edx,%eax
  801f7d:	eb 99                	jmp    801f18 <__umoddi3+0x38>
  801f7f:	90                   	nop
  801f80:	89 c8                	mov    %ecx,%eax
  801f82:	89 f2                	mov    %esi,%edx
  801f84:	83 c4 1c             	add    $0x1c,%esp
  801f87:	5b                   	pop    %ebx
  801f88:	5e                   	pop    %esi
  801f89:	5f                   	pop    %edi
  801f8a:	5d                   	pop    %ebp
  801f8b:	c3                   	ret    
  801f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f90:	8b 34 24             	mov    (%esp),%esi
  801f93:	bf 20 00 00 00       	mov    $0x20,%edi
  801f98:	89 e9                	mov    %ebp,%ecx
  801f9a:	29 ef                	sub    %ebp,%edi
  801f9c:	d3 e0                	shl    %cl,%eax
  801f9e:	89 f9                	mov    %edi,%ecx
  801fa0:	89 f2                	mov    %esi,%edx
  801fa2:	d3 ea                	shr    %cl,%edx
  801fa4:	89 e9                	mov    %ebp,%ecx
  801fa6:	09 c2                	or     %eax,%edx
  801fa8:	89 d8                	mov    %ebx,%eax
  801faa:	89 14 24             	mov    %edx,(%esp)
  801fad:	89 f2                	mov    %esi,%edx
  801faf:	d3 e2                	shl    %cl,%edx
  801fb1:	89 f9                	mov    %edi,%ecx
  801fb3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fb7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801fbb:	d3 e8                	shr    %cl,%eax
  801fbd:	89 e9                	mov    %ebp,%ecx
  801fbf:	89 c6                	mov    %eax,%esi
  801fc1:	d3 e3                	shl    %cl,%ebx
  801fc3:	89 f9                	mov    %edi,%ecx
  801fc5:	89 d0                	mov    %edx,%eax
  801fc7:	d3 e8                	shr    %cl,%eax
  801fc9:	89 e9                	mov    %ebp,%ecx
  801fcb:	09 d8                	or     %ebx,%eax
  801fcd:	89 d3                	mov    %edx,%ebx
  801fcf:	89 f2                	mov    %esi,%edx
  801fd1:	f7 34 24             	divl   (%esp)
  801fd4:	89 d6                	mov    %edx,%esi
  801fd6:	d3 e3                	shl    %cl,%ebx
  801fd8:	f7 64 24 04          	mull   0x4(%esp)
  801fdc:	39 d6                	cmp    %edx,%esi
  801fde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fe2:	89 d1                	mov    %edx,%ecx
  801fe4:	89 c3                	mov    %eax,%ebx
  801fe6:	72 08                	jb     801ff0 <__umoddi3+0x110>
  801fe8:	75 11                	jne    801ffb <__umoddi3+0x11b>
  801fea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801fee:	73 0b                	jae    801ffb <__umoddi3+0x11b>
  801ff0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ff4:	1b 14 24             	sbb    (%esp),%edx
  801ff7:	89 d1                	mov    %edx,%ecx
  801ff9:	89 c3                	mov    %eax,%ebx
  801ffb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801fff:	29 da                	sub    %ebx,%edx
  802001:	19 ce                	sbb    %ecx,%esi
  802003:	89 f9                	mov    %edi,%ecx
  802005:	89 f0                	mov    %esi,%eax
  802007:	d3 e0                	shl    %cl,%eax
  802009:	89 e9                	mov    %ebp,%ecx
  80200b:	d3 ea                	shr    %cl,%edx
  80200d:	89 e9                	mov    %ebp,%ecx
  80200f:	d3 ee                	shr    %cl,%esi
  802011:	09 d0                	or     %edx,%eax
  802013:	89 f2                	mov    %esi,%edx
  802015:	83 c4 1c             	add    $0x1c,%esp
  802018:	5b                   	pop    %ebx
  802019:	5e                   	pop    %esi
  80201a:	5f                   	pop    %edi
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    
  80201d:	8d 76 00             	lea    0x0(%esi),%esi
  802020:	29 f9                	sub    %edi,%ecx
  802022:	19 d6                	sbb    %edx,%esi
  802024:	89 74 24 04          	mov    %esi,0x4(%esp)
  802028:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80202c:	e9 18 ff ff ff       	jmp    801f49 <__umoddi3+0x69>
