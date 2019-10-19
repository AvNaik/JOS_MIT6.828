
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 30 80 00    	pushl  0x803000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 ed 07 00 00       	call   800836 <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 c0 0b 00 00       	call   800c39 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 ec 28 80 00       	push   $0x8028ec
  800086:	6a 13                	push   $0x13
  800088:	68 ff 28 80 00       	push   $0x8028ff
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 7c 0e 00 00       	call   800f13 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 55 2d 80 00       	push   $0x802d55
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 ff 28 80 00       	push   $0x8028ff
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 70 07 00 00       	call   800836 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 01 22 00 00       	call   8022d8 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f6 07 00 00       	call   8008e0 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba e6 28 80 00       	mov    $0x8028e6,%edx
  8000f4:	b8 e0 28 80 00       	mov    $0x8028e0,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 13 29 80 00       	push   $0x802913
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 2e 29 80 00       	push   $0x80292e
  80010e:	68 33 29 80 00       	push   $0x802933
  800113:	68 32 29 80 00       	push   $0x802932
  800118:	e8 ec 1d 00 00       	call   801f09 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 40 29 80 00       	push   $0x802940
  80012a:	6a 21                	push   $0x21
  80012c:	68 ff 28 80 00       	push   $0x8028ff
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 99 21 00 00       	call   8022d8 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 8e 07 00 00       	call   8008e0 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba e6 28 80 00       	mov    $0x8028e6,%edx
  80015c:	b8 e0 28 80 00       	mov    $0x8028e0,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 4a 29 80 00       	push   $0x80294a
  80016a:	e8 42 01 00 00       	call   8002b1 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800183:	e8 73 0a 00 00       	call   800bfb <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c4:	e8 14 11 00 00       	call   8012dd <close_all>
	sys_env_destroy(0);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	6a 00                	push   $0x0
  8001ce:	e8 e7 09 00 00       	call   800bba <sys_env_destroy>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8001e6:	e8 10 0a 00 00       	call   800bfb <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 90 29 80 00       	push   $0x802990
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 24 2f 80 00 	movl   $0x802f24,(%esp)
  800213:	e8 99 00 00 00       	call   8002b1 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x43>

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 13                	mov    (%ebx),%edx
  80022a:	8d 42 01             	lea    0x1(%edx),%eax
  80022d:	89 03                	mov    %eax,(%ebx)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 1a                	jne    800257 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	68 ff 00 00 00       	push   $0xff
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 2f 09 00 00       	call   800b7d <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800254:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800257:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800269:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800270:	00 00 00 
	b.cnt = 0;
  800273:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	68 1e 02 80 00       	push   $0x80021e
  80028f:	e8 54 01 00 00       	call   8003e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800294:	83 c4 08             	add    $0x8,%esp
  800297:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 d4 08 00 00       	call   800b7d <sys_cputs>

	return b.cnt;
}
  8002a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 9d ff ff ff       	call   800260 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ec:	39 d3                	cmp    %edx,%ebx
  8002ee:	72 05                	jb     8002f5 <printnum+0x30>
  8002f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f3:	77 45                	ja     80033a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	ff 75 18             	pushl  0x18(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800301:	53                   	push   %ebx
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 37 23 00 00       	call   802650 <__udivdi3>
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	89 f2                	mov    %esi,%edx
  800320:	89 f8                	mov    %edi,%eax
  800322:	e8 9e ff ff ff       	call   8002c5 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 18                	jmp    800344 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	ff d7                	call   *%edi
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	eb 03                	jmp    80033d <printnum+0x78>
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f e8                	jg     80032c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034e:	ff 75 e0             	pushl  -0x20(%ebp)
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	ff 75 d8             	pushl  -0x28(%ebp)
  800357:	e8 24 24 00 00       	call   802780 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 b3 29 80 00 	movsbl 0x8029b3(%eax),%eax
  800366:	50                   	push   %eax
  800367:	ff d7                	call   *%edi
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800377:	83 fa 01             	cmp    $0x1,%edx
  80037a:	7e 0e                	jle    80038a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	8b 52 04             	mov    0x4(%edx),%edx
  800388:	eb 22                	jmp    8003ac <getuint+0x38>
	else if (lflag)
  80038a:	85 d2                	test   %edx,%edx
  80038c:	74 10                	je     80039e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 4a 04             	lea    0x4(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 0e                	jmp    8003ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bd:	73 0a                	jae    8003c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c7:	88 02                	mov    %al,(%edx)
}
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d4:	50                   	push   %eax
  8003d5:	ff 75 10             	pushl  0x10(%ebp)
  8003d8:	ff 75 0c             	pushl  0xc(%ebp)
  8003db:	ff 75 08             	pushl  0x8(%ebp)
  8003de:	e8 05 00 00 00       	call   8003e8 <vprintfmt>
	va_end(ap);
}
  8003e3:	83 c4 10             	add    $0x10,%esp
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	57                   	push   %edi
  8003ec:	56                   	push   %esi
  8003ed:	53                   	push   %ebx
  8003ee:	83 ec 2c             	sub    $0x2c,%esp
  8003f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003fa:	eb 12                	jmp    80040e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	0f 84 89 03 00 00    	je     80078d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	50                   	push   %eax
  800409:	ff d6                	call   *%esi
  80040b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040e:	83 c7 01             	add    $0x1,%edi
  800411:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800415:	83 f8 25             	cmp    $0x25,%eax
  800418:	75 e2                	jne    8003fc <vprintfmt+0x14>
  80041a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80041e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800425:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800433:	ba 00 00 00 00       	mov    $0x0,%edx
  800438:	eb 07                	jmp    800441 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8d 47 01             	lea    0x1(%edi),%eax
  800444:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800447:	0f b6 07             	movzbl (%edi),%eax
  80044a:	0f b6 c8             	movzbl %al,%ecx
  80044d:	83 e8 23             	sub    $0x23,%eax
  800450:	3c 55                	cmp    $0x55,%al
  800452:	0f 87 1a 03 00 00    	ja     800772 <vprintfmt+0x38a>
  800458:	0f b6 c0             	movzbl %al,%eax
  80045b:	ff 24 85 00 2b 80 00 	jmp    *0x802b00(,%eax,4)
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800465:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800469:	eb d6                	jmp    800441 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800476:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800479:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80047d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800480:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800483:	83 fa 09             	cmp    $0x9,%edx
  800486:	77 39                	ja     8004c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800488:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048b:	eb e9                	jmp    800476 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 48 04             	lea    0x4(%eax),%ecx
  800493:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049e:	eb 27                	jmp    8004c7 <vprintfmt+0xdf>
  8004a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004aa:	0f 49 c8             	cmovns %eax,%ecx
  8004ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b3:	eb 8c                	jmp    800441 <vprintfmt+0x59>
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004bf:	eb 80                	jmp    800441 <vprintfmt+0x59>
  8004c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cb:	0f 89 70 ff ff ff    	jns    800441 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004de:	e9 5e ff ff ff       	jmp    800441 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e9:	e9 53 ff ff ff       	jmp    800441 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8d 50 04             	lea    0x4(%eax),%edx
  8004f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 30                	pushl  (%eax)
  8004fd:	ff d6                	call   *%esi
			break;
  8004ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800505:	e9 04 ff ff ff       	jmp    80040e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	8b 00                	mov    (%eax),%eax
  800515:	99                   	cltd   
  800516:	31 d0                	xor    %edx,%eax
  800518:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051a:	83 f8 0f             	cmp    $0xf,%eax
  80051d:	7f 0b                	jg     80052a <vprintfmt+0x142>
  80051f:	8b 14 85 60 2c 80 00 	mov    0x802c60(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 cb 29 80 00       	push   $0x8029cb
  800530:	53                   	push   %ebx
  800531:	56                   	push   %esi
  800532:	e8 94 fe ff ff       	call   8003cb <printfmt>
  800537:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053d:	e9 cc fe ff ff       	jmp    80040e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800542:	52                   	push   %edx
  800543:	68 2d 2e 80 00       	push   $0x802e2d
  800548:	53                   	push   %ebx
  800549:	56                   	push   %esi
  80054a:	e8 7c fe ff ff       	call   8003cb <printfmt>
  80054f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800555:	e9 b4 fe ff ff       	jmp    80040e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800565:	85 ff                	test   %edi,%edi
  800567:	b8 c4 29 80 00       	mov    $0x8029c4,%eax
  80056c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80056f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800573:	0f 8e 94 00 00 00    	jle    80060d <vprintfmt+0x225>
  800579:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057d:	0f 84 98 00 00 00    	je     80061b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	ff 75 d0             	pushl  -0x30(%ebp)
  800589:	57                   	push   %edi
  80058a:	e8 86 02 00 00       	call   800815 <strnlen>
  80058f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800592:	29 c1                	sub    %eax,%ecx
  800594:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800597:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80059e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a6:	eb 0f                	jmp    8005b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8005af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	83 ef 01             	sub    $0x1,%edi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	85 ff                	test   %edi,%edi
  8005b9:	7f ed                	jg     8005a8 <vprintfmt+0x1c0>
  8005bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c1:	85 c9                	test   %ecx,%ecx
  8005c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c8:	0f 49 c1             	cmovns %ecx,%eax
  8005cb:	29 c1                	sub    %eax,%ecx
  8005cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d6:	89 cb                	mov    %ecx,%ebx
  8005d8:	eb 4d                	jmp    800627 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005de:	74 1b                	je     8005fb <vprintfmt+0x213>
  8005e0:	0f be c0             	movsbl %al,%eax
  8005e3:	83 e8 20             	sub    $0x20,%eax
  8005e6:	83 f8 5e             	cmp    $0x5e,%eax
  8005e9:	76 10                	jbe    8005fb <vprintfmt+0x213>
					putch('?', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	ff 75 0c             	pushl  0xc(%ebp)
  8005f1:	6a 3f                	push   $0x3f
  8005f3:	ff 55 08             	call   *0x8(%ebp)
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	eb 0d                	jmp    800608 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	ff 75 0c             	pushl  0xc(%ebp)
  800601:	52                   	push   %edx
  800602:	ff 55 08             	call   *0x8(%ebp)
  800605:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800608:	83 eb 01             	sub    $0x1,%ebx
  80060b:	eb 1a                	jmp    800627 <vprintfmt+0x23f>
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800619:	eb 0c                	jmp    800627 <vprintfmt+0x23f>
  80061b:	89 75 08             	mov    %esi,0x8(%ebp)
  80061e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800621:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800624:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800627:	83 c7 01             	add    $0x1,%edi
  80062a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062e:	0f be d0             	movsbl %al,%edx
  800631:	85 d2                	test   %edx,%edx
  800633:	74 23                	je     800658 <vprintfmt+0x270>
  800635:	85 f6                	test   %esi,%esi
  800637:	78 a1                	js     8005da <vprintfmt+0x1f2>
  800639:	83 ee 01             	sub    $0x1,%esi
  80063c:	79 9c                	jns    8005da <vprintfmt+0x1f2>
  80063e:	89 df                	mov    %ebx,%edi
  800640:	8b 75 08             	mov    0x8(%ebp),%esi
  800643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800646:	eb 18                	jmp    800660 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 20                	push   $0x20
  80064e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800650:	83 ef 01             	sub    $0x1,%edi
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	eb 08                	jmp    800660 <vprintfmt+0x278>
  800658:	89 df                	mov    %ebx,%edi
  80065a:	8b 75 08             	mov    0x8(%ebp),%esi
  80065d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800660:	85 ff                	test   %edi,%edi
  800662:	7f e4                	jg     800648 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800667:	e9 a2 fd ff ff       	jmp    80040e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066c:	83 fa 01             	cmp    $0x1,%edx
  80066f:	7e 16                	jle    800687 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 50 08             	lea    0x8(%eax),%edx
  800677:	89 55 14             	mov    %edx,0x14(%ebp)
  80067a:	8b 50 04             	mov    0x4(%eax),%edx
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800682:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800685:	eb 32                	jmp    8006b9 <vprintfmt+0x2d1>
	else if (lflag)
  800687:	85 d2                	test   %edx,%edx
  800689:	74 18                	je     8006a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 50 04             	lea    0x4(%eax),%edx
  800691:	89 55 14             	mov    %edx,0x14(%ebp)
  800694:	8b 00                	mov    (%eax),%eax
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	89 c1                	mov    %eax,%ecx
  80069b:	c1 f9 1f             	sar    $0x1f,%ecx
  80069e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a1:	eb 16                	jmp    8006b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 50 04             	lea    0x4(%eax),%edx
  8006a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ac:	8b 00                	mov    (%eax),%eax
  8006ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b1:	89 c1                	mov    %eax,%ecx
  8006b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c8:	79 74                	jns    80073e <vprintfmt+0x356>
				putch('-', putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 2d                	push   $0x2d
  8006d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006d8:	f7 d8                	neg    %eax
  8006da:	83 d2 00             	adc    $0x0,%edx
  8006dd:	f7 da                	neg    %edx
  8006df:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e7:	eb 55                	jmp    80073e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ec:	e8 83 fc ff ff       	call   800374 <getuint>
			base = 10;
  8006f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f6:	eb 46                	jmp    80073e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fb:	e8 74 fc ff ff       	call   800374 <getuint>
			base = 8;
  800700:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800705:	eb 37                	jmp    80073e <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	6a 30                	push   $0x30
  80070d:	ff d6                	call   *%esi
			putch('x', putdat);
  80070f:	83 c4 08             	add    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	6a 78                	push   $0x78
  800715:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 50 04             	lea    0x4(%eax),%edx
  80071d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800720:	8b 00                	mov    (%eax),%eax
  800722:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800727:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80072f:	eb 0d                	jmp    80073e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800731:	8d 45 14             	lea    0x14(%ebp),%eax
  800734:	e8 3b fc ff ff       	call   800374 <getuint>
			base = 16;
  800739:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073e:	83 ec 0c             	sub    $0xc,%esp
  800741:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800745:	57                   	push   %edi
  800746:	ff 75 e0             	pushl  -0x20(%ebp)
  800749:	51                   	push   %ecx
  80074a:	52                   	push   %edx
  80074b:	50                   	push   %eax
  80074c:	89 da                	mov    %ebx,%edx
  80074e:	89 f0                	mov    %esi,%eax
  800750:	e8 70 fb ff ff       	call   8002c5 <printnum>
			break;
  800755:	83 c4 20             	add    $0x20,%esp
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075b:	e9 ae fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	53                   	push   %ebx
  800764:	51                   	push   %ecx
  800765:	ff d6                	call   *%esi
			break;
  800767:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076d:	e9 9c fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 25                	push   $0x25
  800778:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	eb 03                	jmp    800782 <vprintfmt+0x39a>
  80077f:	83 ef 01             	sub    $0x1,%edi
  800782:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800786:	75 f7                	jne    80077f <vprintfmt+0x397>
  800788:	e9 81 fc ff ff       	jmp    80040e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800790:	5b                   	pop    %ebx
  800791:	5e                   	pop    %esi
  800792:	5f                   	pop    %edi
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 18             	sub    $0x18,%esp
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	74 26                	je     8007dc <vsnprintf+0x47>
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	7e 22                	jle    8007dc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ba:	ff 75 14             	pushl  0x14(%ebp)
  8007bd:	ff 75 10             	pushl  0x10(%ebp)
  8007c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	68 ae 03 80 00       	push   $0x8003ae
  8007c9:	e8 1a fc ff ff       	call   8003e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d7:	83 c4 10             	add    $0x10,%esp
  8007da:	eb 05                	jmp    8007e1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ec:	50                   	push   %eax
  8007ed:	ff 75 10             	pushl  0x10(%ebp)
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	ff 75 08             	pushl  0x8(%ebp)
  8007f6:	e8 9a ff ff ff       	call   800795 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	eb 03                	jmp    80080d <strlen+0x10>
		n++;
  80080a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800811:	75 f7                	jne    80080a <strlen+0xd>
		n++;
	return n;
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081e:	ba 00 00 00 00       	mov    $0x0,%edx
  800823:	eb 03                	jmp    800828 <strnlen+0x13>
		n++;
  800825:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800828:	39 c2                	cmp    %eax,%edx
  80082a:	74 08                	je     800834 <strnlen+0x1f>
  80082c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800830:	75 f3                	jne    800825 <strnlen+0x10>
  800832:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800840:	89 c2                	mov    %eax,%edx
  800842:	83 c2 01             	add    $0x1,%edx
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084f:	84 db                	test   %bl,%bl
  800851:	75 ef                	jne    800842 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800853:	5b                   	pop    %ebx
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	53                   	push   %ebx
  80085a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085d:	53                   	push   %ebx
  80085e:	e8 9a ff ff ff       	call   8007fd <strlen>
  800863:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	01 d8                	add    %ebx,%eax
  80086b:	50                   	push   %eax
  80086c:	e8 c5 ff ff ff       	call   800836 <strcpy>
	return dst;
}
  800871:	89 d8                	mov    %ebx,%eax
  800873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 75 08             	mov    0x8(%ebp),%esi
  800880:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800883:	89 f3                	mov    %esi,%ebx
  800885:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	89 f2                	mov    %esi,%edx
  80088a:	eb 0f                	jmp    80089b <strncpy+0x23>
		*dst++ = *src;
  80088c:	83 c2 01             	add    $0x1,%edx
  80088f:	0f b6 01             	movzbl (%ecx),%eax
  800892:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800895:	80 39 01             	cmpb   $0x1,(%ecx)
  800898:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089b:	39 da                	cmp    %ebx,%edx
  80089d:	75 ed                	jne    80088c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089f:	89 f0                	mov    %esi,%eax
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b5:	85 d2                	test   %edx,%edx
  8008b7:	74 21                	je     8008da <strlcpy+0x35>
  8008b9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bd:	89 f2                	mov    %esi,%edx
  8008bf:	eb 09                	jmp    8008ca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c1:	83 c2 01             	add    $0x1,%edx
  8008c4:	83 c1 01             	add    $0x1,%ecx
  8008c7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ca:	39 c2                	cmp    %eax,%edx
  8008cc:	74 09                	je     8008d7 <strlcpy+0x32>
  8008ce:	0f b6 19             	movzbl (%ecx),%ebx
  8008d1:	84 db                	test   %bl,%bl
  8008d3:	75 ec                	jne    8008c1 <strlcpy+0x1c>
  8008d5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008da:	29 f0                	sub    %esi,%eax
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e9:	eb 06                	jmp    8008f1 <strcmp+0x11>
		p++, q++;
  8008eb:	83 c1 01             	add    $0x1,%ecx
  8008ee:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f1:	0f b6 01             	movzbl (%ecx),%eax
  8008f4:	84 c0                	test   %al,%al
  8008f6:	74 04                	je     8008fc <strcmp+0x1c>
  8008f8:	3a 02                	cmp    (%edx),%al
  8008fa:	74 ef                	je     8008eb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fc:	0f b6 c0             	movzbl %al,%eax
  8008ff:	0f b6 12             	movzbl (%edx),%edx
  800902:	29 d0                	sub    %edx,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 c3                	mov    %eax,%ebx
  800912:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800915:	eb 06                	jmp    80091d <strncmp+0x17>
		n--, p++, q++;
  800917:	83 c0 01             	add    $0x1,%eax
  80091a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091d:	39 d8                	cmp    %ebx,%eax
  80091f:	74 15                	je     800936 <strncmp+0x30>
  800921:	0f b6 08             	movzbl (%eax),%ecx
  800924:	84 c9                	test   %cl,%cl
  800926:	74 04                	je     80092c <strncmp+0x26>
  800928:	3a 0a                	cmp    (%edx),%cl
  80092a:	74 eb                	je     800917 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092c:	0f b6 00             	movzbl (%eax),%eax
  80092f:	0f b6 12             	movzbl (%edx),%edx
  800932:	29 d0                	sub    %edx,%eax
  800934:	eb 05                	jmp    80093b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093b:	5b                   	pop    %ebx
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800948:	eb 07                	jmp    800951 <strchr+0x13>
		if (*s == c)
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	74 0f                	je     80095d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094e:	83 c0 01             	add    $0x1,%eax
  800951:	0f b6 10             	movzbl (%eax),%edx
  800954:	84 d2                	test   %dl,%dl
  800956:	75 f2                	jne    80094a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800969:	eb 03                	jmp    80096e <strfind+0xf>
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800971:	38 ca                	cmp    %cl,%dl
  800973:	74 04                	je     800979 <strfind+0x1a>
  800975:	84 d2                	test   %dl,%dl
  800977:	75 f2                	jne    80096b <strfind+0xc>
			break;
	return (char *) s;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 7d 08             	mov    0x8(%ebp),%edi
  800984:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800987:	85 c9                	test   %ecx,%ecx
  800989:	74 36                	je     8009c1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800991:	75 28                	jne    8009bb <memset+0x40>
  800993:	f6 c1 03             	test   $0x3,%cl
  800996:	75 23                	jne    8009bb <memset+0x40>
		c &= 0xFF;
  800998:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099c:	89 d3                	mov    %edx,%ebx
  80099e:	c1 e3 08             	shl    $0x8,%ebx
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	c1 e6 18             	shl    $0x18,%esi
  8009a6:	89 d0                	mov    %edx,%eax
  8009a8:	c1 e0 10             	shl    $0x10,%eax
  8009ab:	09 f0                	or     %esi,%eax
  8009ad:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009af:	89 d8                	mov    %ebx,%eax
  8009b1:	09 d0                	or     %edx,%eax
  8009b3:	c1 e9 02             	shr    $0x2,%ecx
  8009b6:	fc                   	cld    
  8009b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b9:	eb 06                	jmp    8009c1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009be:	fc                   	cld    
  8009bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c1:	89 f8                	mov    %edi,%eax
  8009c3:	5b                   	pop    %ebx
  8009c4:	5e                   	pop    %esi
  8009c5:	5f                   	pop    %edi
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d6:	39 c6                	cmp    %eax,%esi
  8009d8:	73 35                	jae    800a0f <memmove+0x47>
  8009da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009dd:	39 d0                	cmp    %edx,%eax
  8009df:	73 2e                	jae    800a0f <memmove+0x47>
		s += n;
		d += n;
  8009e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e4:	89 d6                	mov    %edx,%esi
  8009e6:	09 fe                	or     %edi,%esi
  8009e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ee:	75 13                	jne    800a03 <memmove+0x3b>
  8009f0:	f6 c1 03             	test   $0x3,%cl
  8009f3:	75 0e                	jne    800a03 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f5:	83 ef 04             	sub    $0x4,%edi
  8009f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
  8009fe:	fd                   	std    
  8009ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a01:	eb 09                	jmp    800a0c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a03:	83 ef 01             	sub    $0x1,%edi
  800a06:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a09:	fd                   	std    
  800a0a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0c:	fc                   	cld    
  800a0d:	eb 1d                	jmp    800a2c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	89 f2                	mov    %esi,%edx
  800a11:	09 c2                	or     %eax,%edx
  800a13:	f6 c2 03             	test   $0x3,%dl
  800a16:	75 0f                	jne    800a27 <memmove+0x5f>
  800a18:	f6 c1 03             	test   $0x3,%cl
  800a1b:	75 0a                	jne    800a27 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a1d:	c1 e9 02             	shr    $0x2,%ecx
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a25:	eb 05                	jmp    800a2c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a27:	89 c7                	mov    %eax,%edi
  800a29:	fc                   	cld    
  800a2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2c:	5e                   	pop    %esi
  800a2d:	5f                   	pop    %edi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a33:	ff 75 10             	pushl  0x10(%ebp)
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	ff 75 08             	pushl  0x8(%ebp)
  800a3c:	e8 87 ff ff ff       	call   8009c8 <memmove>
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4e:	89 c6                	mov    %eax,%esi
  800a50:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a53:	eb 1a                	jmp    800a6f <memcmp+0x2c>
		if (*s1 != *s2)
  800a55:	0f b6 08             	movzbl (%eax),%ecx
  800a58:	0f b6 1a             	movzbl (%edx),%ebx
  800a5b:	38 d9                	cmp    %bl,%cl
  800a5d:	74 0a                	je     800a69 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a5f:	0f b6 c1             	movzbl %cl,%eax
  800a62:	0f b6 db             	movzbl %bl,%ebx
  800a65:	29 d8                	sub    %ebx,%eax
  800a67:	eb 0f                	jmp    800a78 <memcmp+0x35>
		s1++, s2++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6f:	39 f0                	cmp    %esi,%eax
  800a71:	75 e2                	jne    800a55 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	53                   	push   %ebx
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a83:	89 c1                	mov    %eax,%ecx
  800a85:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a88:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8c:	eb 0a                	jmp    800a98 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8e:	0f b6 10             	movzbl (%eax),%edx
  800a91:	39 da                	cmp    %ebx,%edx
  800a93:	74 07                	je     800a9c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a95:	83 c0 01             	add    $0x1,%eax
  800a98:	39 c8                	cmp    %ecx,%eax
  800a9a:	72 f2                	jb     800a8e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aab:	eb 03                	jmp    800ab0 <strtol+0x11>
		s++;
  800aad:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab0:	0f b6 01             	movzbl (%ecx),%eax
  800ab3:	3c 20                	cmp    $0x20,%al
  800ab5:	74 f6                	je     800aad <strtol+0xe>
  800ab7:	3c 09                	cmp    $0x9,%al
  800ab9:	74 f2                	je     800aad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abb:	3c 2b                	cmp    $0x2b,%al
  800abd:	75 0a                	jne    800ac9 <strtol+0x2a>
		s++;
  800abf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac7:	eb 11                	jmp    800ada <strtol+0x3b>
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ace:	3c 2d                	cmp    $0x2d,%al
  800ad0:	75 08                	jne    800ada <strtol+0x3b>
		s++, neg = 1;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae0:	75 15                	jne    800af7 <strtol+0x58>
  800ae2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae5:	75 10                	jne    800af7 <strtol+0x58>
  800ae7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aeb:	75 7c                	jne    800b69 <strtol+0xca>
		s += 2, base = 16;
  800aed:	83 c1 02             	add    $0x2,%ecx
  800af0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af5:	eb 16                	jmp    800b0d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af7:	85 db                	test   %ebx,%ebx
  800af9:	75 12                	jne    800b0d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b00:	80 39 30             	cmpb   $0x30,(%ecx)
  800b03:	75 08                	jne    800b0d <strtol+0x6e>
		s++, base = 8;
  800b05:	83 c1 01             	add    $0x1,%ecx
  800b08:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b15:	0f b6 11             	movzbl (%ecx),%edx
  800b18:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1b:	89 f3                	mov    %esi,%ebx
  800b1d:	80 fb 09             	cmp    $0x9,%bl
  800b20:	77 08                	ja     800b2a <strtol+0x8b>
			dig = *s - '0';
  800b22:	0f be d2             	movsbl %dl,%edx
  800b25:	83 ea 30             	sub    $0x30,%edx
  800b28:	eb 22                	jmp    800b4c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2d:	89 f3                	mov    %esi,%ebx
  800b2f:	80 fb 19             	cmp    $0x19,%bl
  800b32:	77 08                	ja     800b3c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b34:	0f be d2             	movsbl %dl,%edx
  800b37:	83 ea 57             	sub    $0x57,%edx
  800b3a:	eb 10                	jmp    800b4c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 16                	ja     800b5c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b46:	0f be d2             	movsbl %dl,%edx
  800b49:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b4f:	7d 0b                	jge    800b5c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b58:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b5a:	eb b9                	jmp    800b15 <strtol+0x76>

	if (endptr)
  800b5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b60:	74 0d                	je     800b6f <strtol+0xd0>
		*endptr = (char *) s;
  800b62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b65:	89 0e                	mov    %ecx,(%esi)
  800b67:	eb 06                	jmp    800b6f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b69:	85 db                	test   %ebx,%ebx
  800b6b:	74 98                	je     800b05 <strtol+0x66>
  800b6d:	eb 9e                	jmp    800b0d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	f7 da                	neg    %edx
  800b73:	85 ff                	test   %edi,%edi
  800b75:	0f 45 c2             	cmovne %edx,%eax
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	89 c3                	mov    %eax,%ebx
  800b90:	89 c7                	mov    %eax,%edi
  800b92:	89 c6                	mov    %eax,%esi
  800b94:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bab:	89 d1                	mov    %edx,%ecx
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	89 d7                	mov    %edx,%edi
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	89 cb                	mov    %ecx,%ebx
  800bd2:	89 cf                	mov    %ecx,%edi
  800bd4:	89 ce                	mov    %ecx,%esi
  800bd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 03                	push   $0x3
  800be2:	68 bf 2c 80 00       	push   $0x802cbf
  800be7:	6a 23                	push   $0x23
  800be9:	68 dc 2c 80 00       	push   $0x802cdc
  800bee:	e8 e5 f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	ba 00 00 00 00       	mov    $0x0,%edx
  800c06:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0b:	89 d1                	mov    %edx,%ecx
  800c0d:	89 d3                	mov    %edx,%ebx
  800c0f:	89 d7                	mov    %edx,%edi
  800c11:	89 d6                	mov    %edx,%esi
  800c13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_yield>:

void
sys_yield(void)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c42:	be 00 00 00 00       	mov    $0x0,%esi
  800c47:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c55:	89 f7                	mov    %esi,%edi
  800c57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 17                	jle    800c74 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 04                	push   $0x4
  800c63:	68 bf 2c 80 00       	push   $0x802cbf
  800c68:	6a 23                	push   $0x23
  800c6a:	68 dc 2c 80 00       	push   $0x802cdc
  800c6f:	e8 64 f5 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
  800c82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c85:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c96:	8b 75 18             	mov    0x18(%ebp),%esi
  800c99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	7e 17                	jle    800cb6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	50                   	push   %eax
  800ca3:	6a 05                	push   $0x5
  800ca5:	68 bf 2c 80 00       	push   $0x802cbf
  800caa:	6a 23                	push   $0x23
  800cac:	68 dc 2c 80 00       	push   $0x802cdc
  800cb1:	e8 22 f5 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccc:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 df                	mov    %ebx,%edi
  800cd9:	89 de                	mov    %ebx,%esi
  800cdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 17                	jle    800cf8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	50                   	push   %eax
  800ce5:	6a 06                	push   $0x6
  800ce7:	68 bf 2c 80 00       	push   $0x802cbf
  800cec:	6a 23                	push   $0x23
  800cee:	68 dc 2c 80 00       	push   $0x802cdc
  800cf3:	e8 e0 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 df                	mov    %ebx,%edi
  800d1b:	89 de                	mov    %ebx,%esi
  800d1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 17                	jle    800d3a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	50                   	push   %eax
  800d27:	6a 08                	push   $0x8
  800d29:	68 bf 2c 80 00       	push   $0x802cbf
  800d2e:	6a 23                	push   $0x23
  800d30:	68 dc 2c 80 00       	push   $0x802cdc
  800d35:	e8 9e f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d50:	b8 09 00 00 00       	mov    $0x9,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 df                	mov    %ebx,%edi
  800d5d:	89 de                	mov    %ebx,%esi
  800d5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 17                	jle    800d7c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 09                	push   $0x9
  800d6b:	68 bf 2c 80 00       	push   $0x802cbf
  800d70:	6a 23                	push   $0x23
  800d72:	68 dc 2c 80 00       	push   $0x802cdc
  800d77:	e8 5c f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
  800d8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 df                	mov    %ebx,%edi
  800d9f:	89 de                	mov    %ebx,%esi
  800da1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 17                	jle    800dbe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	50                   	push   %eax
  800dab:	6a 0a                	push   $0xa
  800dad:	68 bf 2c 80 00       	push   $0x802cbf
  800db2:	6a 23                	push   $0x23
  800db4:	68 dc 2c 80 00       	push   $0x802cdc
  800db9:	e8 1a f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	be 00 00 00 00       	mov    $0x0,%esi
  800dd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 cb                	mov    %ecx,%ebx
  800e01:	89 cf                	mov    %ecx,%edi
  800e03:	89 ce                	mov    %ecx,%esi
  800e05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 0d                	push   $0xd
  800e11:	68 bf 2c 80 00       	push   $0x802cbf
  800e16:	6a 23                	push   $0x23
  800e18:	68 dc 2c 80 00       	push   $0x802cdc
  800e1d:	e8 b6 f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  800e34:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  800e36:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  800e39:	89 da                	mov    %ebx,%edx
  800e3b:	c1 ea 0c             	shr    $0xc,%edx
  800e3e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  800e45:	a8 02                	test   $0x2,%al
  800e47:	75 12                	jne    800e5b <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  800e49:	50                   	push   %eax
  800e4a:	68 ec 2c 80 00       	push   $0x802cec
  800e4f:	6a 21                	push   $0x21
  800e51:	68 0d 2d 80 00       	push   $0x802d0d
  800e56:	e8 7d f3 ff ff       	call   8001d8 <_panic>
	   } else if (!(pte & PTE_COW)) {
  800e5b:	f6 c6 08             	test   $0x8,%dh
  800e5e:	75 14                	jne    800e74 <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  800e60:	83 ec 04             	sub    $0x4,%esp
  800e63:	68 18 2d 80 00       	push   $0x802d18
  800e68:	6a 23                	push   $0x23
  800e6a:	68 0d 2d 80 00       	push   $0x802d0d
  800e6f:	e8 64 f3 ff ff       	call   8001d8 <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  800e74:	83 ec 04             	sub    $0x4,%esp
  800e77:	6a 07                	push   $0x7
  800e79:	68 00 00 40 00       	push   $0x400000
  800e7e:	6a 00                	push   $0x0
  800e80:	e8 b4 fd ff ff       	call   800c39 <sys_page_alloc>
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	79 12                	jns    800e9e <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  800e8c:	50                   	push   %eax
  800e8d:	68 ec 28 80 00       	push   $0x8028ec
  800e92:	6a 2e                	push   $0x2e
  800e94:	68 0d 2d 80 00       	push   $0x802d0d
  800e99:	e8 3a f3 ff ff       	call   8001d8 <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800e9e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800ea4:	83 ec 04             	sub    $0x4,%esp
  800ea7:	68 00 10 00 00       	push   $0x1000
  800eac:	53                   	push   %ebx
  800ead:	68 00 00 40 00       	push   $0x400000
  800eb2:	e8 11 fb ff ff       	call   8009c8 <memmove>
	   if ((r = sys_page_map(0,
  800eb7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ebe:	53                   	push   %ebx
  800ebf:	6a 00                	push   $0x0
  800ec1:	68 00 00 40 00       	push   $0x400000
  800ec6:	6a 00                	push   $0x0
  800ec8:	e8 af fd ff ff       	call   800c7c <sys_page_map>
  800ecd:	83 c4 20             	add    $0x20,%esp
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	79 12                	jns    800ee6 <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  800ed4:	50                   	push   %eax
  800ed5:	68 35 2d 80 00       	push   $0x802d35
  800eda:	6a 36                	push   $0x36
  800edc:	68 0d 2d 80 00       	push   $0x802d0d
  800ee1:	e8 f2 f2 ff ff       	call   8001d8 <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  800ee6:	83 ec 08             	sub    $0x8,%esp
  800ee9:	68 00 00 40 00       	push   $0x400000
  800eee:	6a 00                	push   $0x0
  800ef0:	e8 c9 fd ff ff       	call   800cbe <sys_page_unmap>
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	79 12                	jns    800f0e <pgfault+0xe4>
			 panic("unmap %e", r);
  800efc:	50                   	push   %eax
  800efd:	68 45 2d 80 00       	push   $0x802d45
  800f02:	6a 39                	push   $0x39
  800f04:	68 0d 2d 80 00       	push   $0x802d0d
  800f09:	e8 ca f2 ff ff       	call   8001d8 <_panic>
	   }
}
  800f0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f11:	c9                   	leave  
  800f12:	c3                   	ret    

00800f13 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  800f1c:	68 2a 0e 80 00       	push   $0x800e2a
  800f21:	e8 84 15 00 00       	call   8024aa <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f26:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2b:	cd 30                	int    $0x30
  800f2d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f30:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	79 15                	jns    800f4f <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  800f3a:	50                   	push   %eax
  800f3b:	68 4e 2d 80 00       	push   $0x802d4e
  800f40:	68 81 00 00 00       	push   $0x81
  800f45:	68 0d 2d 80 00       	push   $0x802d0d
  800f4a:	e8 89 f2 ff ff       	call   8001d8 <_panic>
  800f4f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800f56:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  800f5a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800f5e:	75 1c                	jne    800f7c <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  800f60:	e8 96 fc ff ff       	call   800bfb <sys_getenvid>
  800f65:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f6a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f6d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f72:	a3 04 40 80 00       	mov    %eax,0x804004
			 return envid;
  800f77:	e9 71 01 00 00       	jmp    8010ed <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  800f7c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800f7f:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800f86:	a8 01                	test   $0x1,%al
  800f88:	0f 84 18 01 00 00    	je     8010a6 <fork+0x193>
  800f8e:	89 fb                	mov    %edi,%ebx
  800f90:	c1 e3 0a             	shl    $0xa,%ebx
  800f93:	c1 e7 16             	shl    $0x16,%edi
  800f96:	be 00 00 00 00       	mov    $0x0,%esi
  800f9b:	e9 f4 00 00 00       	jmp    801094 <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  800fa0:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800fa6:	0f 84 dc 00 00 00    	je     801088 <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  800fac:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800fb2:	0f 87 cc 00 00 00    	ja     801084 <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  800fb8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fbf:	a8 01                	test   $0x1,%al
  800fc1:	0f 84 c1 00 00 00    	je     801088 <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  800fc7:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  800fce:	a9 02 08 00 00       	test   $0x802,%eax
  800fd3:	74 05                	je     800fda <fork+0xc7>
  800fd5:	f6 c4 04             	test   $0x4,%ah
  800fd8:	74 3a                	je     801014 <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  800fda:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fe0:	8b 52 48             	mov    0x48(%edx),%edx
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	25 07 0e 00 00       	and    $0xe07,%eax
  800feb:	50                   	push   %eax
  800fec:	57                   	push   %edi
  800fed:	ff 75 dc             	pushl  -0x24(%ebp)
  800ff0:	57                   	push   %edi
  800ff1:	52                   	push   %edx
  800ff2:	e8 85 fc ff ff       	call   800c7c <sys_page_map>
  800ff7:	83 c4 20             	add    $0x20,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	0f 89 86 00 00 00    	jns    801088 <fork+0x175>
				    panic("sys_page_map: %e", r);
  801002:	50                   	push   %eax
  801003:	68 5e 2d 80 00       	push   $0x802d5e
  801008:	6a 52                	push   $0x52
  80100a:	68 0d 2d 80 00       	push   $0x802d0d
  80100f:	e8 c4 f1 ff ff       	call   8001d8 <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  801014:	25 05 06 00 00       	and    $0x605,%eax
  801019:	80 cc 08             	or     $0x8,%ah
  80101c:	89 c1                	mov    %eax,%ecx
  80101e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801021:	a1 04 40 80 00       	mov    0x804004,%eax
  801026:	8b 40 48             	mov    0x48(%eax),%eax
  801029:	83 ec 0c             	sub    $0xc,%esp
  80102c:	51                   	push   %ecx
  80102d:	57                   	push   %edi
  80102e:	ff 75 dc             	pushl  -0x24(%ebp)
  801031:	57                   	push   %edi
  801032:	50                   	push   %eax
  801033:	e8 44 fc ff ff       	call   800c7c <sys_page_map>
  801038:	83 c4 20             	add    $0x20,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	79 12                	jns    801051 <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  80103f:	50                   	push   %eax
  801040:	68 5e 2d 80 00       	push   $0x802d5e
  801045:	6a 5d                	push   $0x5d
  801047:	68 0d 2d 80 00       	push   $0x802d0d
  80104c:	e8 87 f1 ff ff       	call   8001d8 <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  801051:	a1 04 40 80 00       	mov    0x804004,%eax
  801056:	8b 50 48             	mov    0x48(%eax),%edx
  801059:	8b 40 48             	mov    0x48(%eax),%eax
  80105c:	83 ec 0c             	sub    $0xc,%esp
  80105f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801062:	57                   	push   %edi
  801063:	52                   	push   %edx
  801064:	57                   	push   %edi
  801065:	50                   	push   %eax
  801066:	e8 11 fc ff ff       	call   800c7c <sys_page_map>
  80106b:	83 c4 20             	add    $0x20,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	79 16                	jns    801088 <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  801072:	50                   	push   %eax
  801073:	68 5e 2d 80 00       	push   $0x802d5e
  801078:	6a 63                	push   $0x63
  80107a:	68 0d 2d 80 00       	push   $0x802d0d
  80107f:	e8 54 f1 ff ff       	call   8001d8 <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  801084:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  801088:	83 c6 01             	add    $0x1,%esi
  80108b:	83 c3 01             	add    $0x1,%ebx
  80108e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801094:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  80109a:	7f 0a                	jg     8010a6 <fork+0x193>
  80109c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8010a0:	0f 85 fa fe ff ff    	jne    800fa0 <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  8010a6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  8010aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010ad:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8010b2:	7f 0a                	jg     8010be <fork+0x1ab>
  8010b4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8010b8:	0f 85 be fe ff ff    	jne    800f7c <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010be:	83 ec 08             	sub    $0x8,%esp
  8010c1:	68 03 25 80 00       	push   $0x802503
  8010c6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8010c9:	56                   	push   %esi
  8010ca:	e8 b5 fc ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  8010cf:	83 c4 0c             	add    $0xc,%esp
  8010d2:	6a 06                	push   $0x6
  8010d4:	68 00 f0 bf ee       	push   $0xeebff000
  8010d9:	56                   	push   %esi
  8010da:	e8 5a fb ff ff       	call   800c39 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  8010df:	83 c4 08             	add    $0x8,%esp
  8010e2:	6a 02                	push   $0x2
  8010e4:	56                   	push   %esi
  8010e5:	e8 16 fc ff ff       	call   800d00 <sys_env_set_status>

	   return envid;
  8010ea:	83 c4 10             	add    $0x10,%esp
}
  8010ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8010f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5e                   	pop    %esi
  8010f5:	5f                   	pop    %edi
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <sfork>:
// Challenge!
	   int
sfork(void)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  8010fe:	68 6f 2d 80 00       	push   $0x802d6f
  801103:	68 a7 00 00 00       	push   $0xa7
  801108:	68 0d 2d 80 00       	push   $0x802d0d
  80110d:	e8 c6 f0 ff ff       	call   8001d8 <_panic>

00801112 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801115:	8b 45 08             	mov    0x8(%ebp),%eax
  801118:	05 00 00 00 30       	add    $0x30000000,%eax
  80111d:	c1 e8 0c             	shr    $0xc,%eax
}
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801125:	8b 45 08             	mov    0x8(%ebp),%eax
  801128:	05 00 00 00 30       	add    $0x30000000,%eax
  80112d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801132:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801137:	5d                   	pop    %ebp
  801138:	c3                   	ret    

00801139 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801144:	89 c2                	mov    %eax,%edx
  801146:	c1 ea 16             	shr    $0x16,%edx
  801149:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801150:	f6 c2 01             	test   $0x1,%dl
  801153:	74 11                	je     801166 <fd_alloc+0x2d>
  801155:	89 c2                	mov    %eax,%edx
  801157:	c1 ea 0c             	shr    $0xc,%edx
  80115a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801161:	f6 c2 01             	test   $0x1,%dl
  801164:	75 09                	jne    80116f <fd_alloc+0x36>
			*fd_store = fd;
  801166:	89 01                	mov    %eax,(%ecx)
			return 0;
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
  80116d:	eb 17                	jmp    801186 <fd_alloc+0x4d>
  80116f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801174:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801179:	75 c9                	jne    801144 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80117b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801181:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80118e:	83 f8 1f             	cmp    $0x1f,%eax
  801191:	77 36                	ja     8011c9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801193:	c1 e0 0c             	shl    $0xc,%eax
  801196:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80119b:	89 c2                	mov    %eax,%edx
  80119d:	c1 ea 16             	shr    $0x16,%edx
  8011a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a7:	f6 c2 01             	test   $0x1,%dl
  8011aa:	74 24                	je     8011d0 <fd_lookup+0x48>
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	c1 ea 0c             	shr    $0xc,%edx
  8011b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b8:	f6 c2 01             	test   $0x1,%dl
  8011bb:	74 1a                	je     8011d7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c0:	89 02                	mov    %eax,(%edx)
	return 0;
  8011c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c7:	eb 13                	jmp    8011dc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ce:	eb 0c                	jmp    8011dc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d5:	eb 05                	jmp    8011dc <fd_lookup+0x54>
  8011d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e7:	ba 04 2e 80 00       	mov    $0x802e04,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ec:	eb 13                	jmp    801201 <dev_lookup+0x23>
  8011ee:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011f1:	39 08                	cmp    %ecx,(%eax)
  8011f3:	75 0c                	jne    801201 <dev_lookup+0x23>
			*dev = devtab[i];
  8011f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ff:	eb 2e                	jmp    80122f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801201:	8b 02                	mov    (%edx),%eax
  801203:	85 c0                	test   %eax,%eax
  801205:	75 e7                	jne    8011ee <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801207:	a1 04 40 80 00       	mov    0x804004,%eax
  80120c:	8b 40 48             	mov    0x48(%eax),%eax
  80120f:	83 ec 04             	sub    $0x4,%esp
  801212:	51                   	push   %ecx
  801213:	50                   	push   %eax
  801214:	68 88 2d 80 00       	push   $0x802d88
  801219:	e8 93 f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  80121e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801221:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80122f:	c9                   	leave  
  801230:	c3                   	ret    

00801231 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	83 ec 10             	sub    $0x10,%esp
  801239:	8b 75 08             	mov    0x8(%ebp),%esi
  80123c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80123f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801242:	50                   	push   %eax
  801243:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801249:	c1 e8 0c             	shr    $0xc,%eax
  80124c:	50                   	push   %eax
  80124d:	e8 36 ff ff ff       	call   801188 <fd_lookup>
  801252:	83 c4 08             	add    $0x8,%esp
  801255:	85 c0                	test   %eax,%eax
  801257:	78 05                	js     80125e <fd_close+0x2d>
	    || fd != fd2)
  801259:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80125c:	74 0c                	je     80126a <fd_close+0x39>
		return (must_exist ? r : 0);
  80125e:	84 db                	test   %bl,%bl
  801260:	ba 00 00 00 00       	mov    $0x0,%edx
  801265:	0f 44 c2             	cmove  %edx,%eax
  801268:	eb 41                	jmp    8012ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801270:	50                   	push   %eax
  801271:	ff 36                	pushl  (%esi)
  801273:	e8 66 ff ff ff       	call   8011de <dev_lookup>
  801278:	89 c3                	mov    %eax,%ebx
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 1a                	js     80129b <fd_close+0x6a>
		if (dev->dev_close)
  801281:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801284:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801287:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80128c:	85 c0                	test   %eax,%eax
  80128e:	74 0b                	je     80129b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801290:	83 ec 0c             	sub    $0xc,%esp
  801293:	56                   	push   %esi
  801294:	ff d0                	call   *%eax
  801296:	89 c3                	mov    %eax,%ebx
  801298:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	56                   	push   %esi
  80129f:	6a 00                	push   $0x0
  8012a1:	e8 18 fa ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	89 d8                	mov    %ebx,%eax
}
  8012ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ae:	5b                   	pop    %ebx
  8012af:	5e                   	pop    %esi
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bb:	50                   	push   %eax
  8012bc:	ff 75 08             	pushl  0x8(%ebp)
  8012bf:	e8 c4 fe ff ff       	call   801188 <fd_lookup>
  8012c4:	83 c4 08             	add    $0x8,%esp
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	78 10                	js     8012db <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012cb:	83 ec 08             	sub    $0x8,%esp
  8012ce:	6a 01                	push   $0x1
  8012d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d3:	e8 59 ff ff ff       	call   801231 <fd_close>
  8012d8:	83 c4 10             	add    $0x10,%esp
}
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    

008012dd <close_all>:

void
close_all(void)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	53                   	push   %ebx
  8012e1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012e9:	83 ec 0c             	sub    $0xc,%esp
  8012ec:	53                   	push   %ebx
  8012ed:	e8 c0 ff ff ff       	call   8012b2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f2:	83 c3 01             	add    $0x1,%ebx
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	83 fb 20             	cmp    $0x20,%ebx
  8012fb:	75 ec                	jne    8012e9 <close_all+0xc>
		close(i);
}
  8012fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	57                   	push   %edi
  801306:	56                   	push   %esi
  801307:	53                   	push   %ebx
  801308:	83 ec 2c             	sub    $0x2c,%esp
  80130b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80130e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	ff 75 08             	pushl  0x8(%ebp)
  801315:	e8 6e fe ff ff       	call   801188 <fd_lookup>
  80131a:	83 c4 08             	add    $0x8,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	0f 88 c1 00 00 00    	js     8013e6 <dup+0xe4>
		return r;
	close(newfdnum);
  801325:	83 ec 0c             	sub    $0xc,%esp
  801328:	56                   	push   %esi
  801329:	e8 84 ff ff ff       	call   8012b2 <close>

	newfd = INDEX2FD(newfdnum);
  80132e:	89 f3                	mov    %esi,%ebx
  801330:	c1 e3 0c             	shl    $0xc,%ebx
  801333:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801339:	83 c4 04             	add    $0x4,%esp
  80133c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80133f:	e8 de fd ff ff       	call   801122 <fd2data>
  801344:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801346:	89 1c 24             	mov    %ebx,(%esp)
  801349:	e8 d4 fd ff ff       	call   801122 <fd2data>
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801354:	89 f8                	mov    %edi,%eax
  801356:	c1 e8 16             	shr    $0x16,%eax
  801359:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801360:	a8 01                	test   $0x1,%al
  801362:	74 37                	je     80139b <dup+0x99>
  801364:	89 f8                	mov    %edi,%eax
  801366:	c1 e8 0c             	shr    $0xc,%eax
  801369:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801370:	f6 c2 01             	test   $0x1,%dl
  801373:	74 26                	je     80139b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801375:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137c:	83 ec 0c             	sub    $0xc,%esp
  80137f:	25 07 0e 00 00       	and    $0xe07,%eax
  801384:	50                   	push   %eax
  801385:	ff 75 d4             	pushl  -0x2c(%ebp)
  801388:	6a 00                	push   $0x0
  80138a:	57                   	push   %edi
  80138b:	6a 00                	push   $0x0
  80138d:	e8 ea f8 ff ff       	call   800c7c <sys_page_map>
  801392:	89 c7                	mov    %eax,%edi
  801394:	83 c4 20             	add    $0x20,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	78 2e                	js     8013c9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80139e:	89 d0                	mov    %edx,%eax
  8013a0:	c1 e8 0c             	shr    $0xc,%eax
  8013a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b2:	50                   	push   %eax
  8013b3:	53                   	push   %ebx
  8013b4:	6a 00                	push   $0x0
  8013b6:	52                   	push   %edx
  8013b7:	6a 00                	push   $0x0
  8013b9:	e8 be f8 ff ff       	call   800c7c <sys_page_map>
  8013be:	89 c7                	mov    %eax,%edi
  8013c0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013c3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c5:	85 ff                	test   %edi,%edi
  8013c7:	79 1d                	jns    8013e6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013c9:	83 ec 08             	sub    $0x8,%esp
  8013cc:	53                   	push   %ebx
  8013cd:	6a 00                	push   $0x0
  8013cf:	e8 ea f8 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013d4:	83 c4 08             	add    $0x8,%esp
  8013d7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013da:	6a 00                	push   $0x0
  8013dc:	e8 dd f8 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	89 f8                	mov    %edi,%eax
}
  8013e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e9:	5b                   	pop    %ebx
  8013ea:	5e                   	pop    %esi
  8013eb:	5f                   	pop    %edi
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    

008013ee <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	53                   	push   %ebx
  8013f2:	83 ec 14             	sub    $0x14,%esp
  8013f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013fb:	50                   	push   %eax
  8013fc:	53                   	push   %ebx
  8013fd:	e8 86 fd ff ff       	call   801188 <fd_lookup>
  801402:	83 c4 08             	add    $0x8,%esp
  801405:	89 c2                	mov    %eax,%edx
  801407:	85 c0                	test   %eax,%eax
  801409:	78 6d                	js     801478 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801411:	50                   	push   %eax
  801412:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801415:	ff 30                	pushl  (%eax)
  801417:	e8 c2 fd ff ff       	call   8011de <dev_lookup>
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 4c                	js     80146f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801423:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801426:	8b 42 08             	mov    0x8(%edx),%eax
  801429:	83 e0 03             	and    $0x3,%eax
  80142c:	83 f8 01             	cmp    $0x1,%eax
  80142f:	75 21                	jne    801452 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801431:	a1 04 40 80 00       	mov    0x804004,%eax
  801436:	8b 40 48             	mov    0x48(%eax),%eax
  801439:	83 ec 04             	sub    $0x4,%esp
  80143c:	53                   	push   %ebx
  80143d:	50                   	push   %eax
  80143e:	68 c9 2d 80 00       	push   $0x802dc9
  801443:	e8 69 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801450:	eb 26                	jmp    801478 <read+0x8a>
	}
	if (!dev->dev_read)
  801452:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801455:	8b 40 08             	mov    0x8(%eax),%eax
  801458:	85 c0                	test   %eax,%eax
  80145a:	74 17                	je     801473 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80145c:	83 ec 04             	sub    $0x4,%esp
  80145f:	ff 75 10             	pushl  0x10(%ebp)
  801462:	ff 75 0c             	pushl  0xc(%ebp)
  801465:	52                   	push   %edx
  801466:	ff d0                	call   *%eax
  801468:	89 c2                	mov    %eax,%edx
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	eb 09                	jmp    801478 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146f:	89 c2                	mov    %eax,%edx
  801471:	eb 05                	jmp    801478 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801473:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801478:	89 d0                	mov    %edx,%eax
  80147a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	57                   	push   %edi
  801483:	56                   	push   %esi
  801484:	53                   	push   %ebx
  801485:	83 ec 0c             	sub    $0xc,%esp
  801488:	8b 7d 08             	mov    0x8(%ebp),%edi
  80148b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801493:	eb 21                	jmp    8014b6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801495:	83 ec 04             	sub    $0x4,%esp
  801498:	89 f0                	mov    %esi,%eax
  80149a:	29 d8                	sub    %ebx,%eax
  80149c:	50                   	push   %eax
  80149d:	89 d8                	mov    %ebx,%eax
  80149f:	03 45 0c             	add    0xc(%ebp),%eax
  8014a2:	50                   	push   %eax
  8014a3:	57                   	push   %edi
  8014a4:	e8 45 ff ff ff       	call   8013ee <read>
		if (m < 0)
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 10                	js     8014c0 <readn+0x41>
			return m;
		if (m == 0)
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	74 0a                	je     8014be <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b4:	01 c3                	add    %eax,%ebx
  8014b6:	39 f3                	cmp    %esi,%ebx
  8014b8:	72 db                	jb     801495 <readn+0x16>
  8014ba:	89 d8                	mov    %ebx,%eax
  8014bc:	eb 02                	jmp    8014c0 <readn+0x41>
  8014be:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c3:	5b                   	pop    %ebx
  8014c4:	5e                   	pop    %esi
  8014c5:	5f                   	pop    %edi
  8014c6:	5d                   	pop    %ebp
  8014c7:	c3                   	ret    

008014c8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	53                   	push   %ebx
  8014cc:	83 ec 14             	sub    $0x14,%esp
  8014cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d5:	50                   	push   %eax
  8014d6:	53                   	push   %ebx
  8014d7:	e8 ac fc ff ff       	call   801188 <fd_lookup>
  8014dc:	83 c4 08             	add    $0x8,%esp
  8014df:	89 c2                	mov    %eax,%edx
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 68                	js     80154d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014eb:	50                   	push   %eax
  8014ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ef:	ff 30                	pushl  (%eax)
  8014f1:	e8 e8 fc ff ff       	call   8011de <dev_lookup>
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 47                	js     801544 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801500:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801504:	75 21                	jne    801527 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801506:	a1 04 40 80 00       	mov    0x804004,%eax
  80150b:	8b 40 48             	mov    0x48(%eax),%eax
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	53                   	push   %ebx
  801512:	50                   	push   %eax
  801513:	68 e5 2d 80 00       	push   $0x802de5
  801518:	e8 94 ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801525:	eb 26                	jmp    80154d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801527:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152a:	8b 52 0c             	mov    0xc(%edx),%edx
  80152d:	85 d2                	test   %edx,%edx
  80152f:	74 17                	je     801548 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	ff 75 10             	pushl  0x10(%ebp)
  801537:	ff 75 0c             	pushl  0xc(%ebp)
  80153a:	50                   	push   %eax
  80153b:	ff d2                	call   *%edx
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	eb 09                	jmp    80154d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801544:	89 c2                	mov    %eax,%edx
  801546:	eb 05                	jmp    80154d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801548:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80154d:	89 d0                	mov    %edx,%eax
  80154f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <seek>:

int
seek(int fdnum, off_t offset)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80155a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	ff 75 08             	pushl  0x8(%ebp)
  801561:	e8 22 fc ff ff       	call   801188 <fd_lookup>
  801566:	83 c4 08             	add    $0x8,%esp
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 0e                	js     80157b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80156d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801570:	8b 55 0c             	mov    0xc(%ebp),%edx
  801573:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801576:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157b:	c9                   	leave  
  80157c:	c3                   	ret    

0080157d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	53                   	push   %ebx
  801581:	83 ec 14             	sub    $0x14,%esp
  801584:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801587:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	53                   	push   %ebx
  80158c:	e8 f7 fb ff ff       	call   801188 <fd_lookup>
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	89 c2                	mov    %eax,%edx
  801596:	85 c0                	test   %eax,%eax
  801598:	78 65                	js     8015ff <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a4:	ff 30                	pushl  (%eax)
  8015a6:	e8 33 fc ff ff       	call   8011de <dev_lookup>
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 44                	js     8015f6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b9:	75 21                	jne    8015dc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015bb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c0:	8b 40 48             	mov    0x48(%eax),%eax
  8015c3:	83 ec 04             	sub    $0x4,%esp
  8015c6:	53                   	push   %ebx
  8015c7:	50                   	push   %eax
  8015c8:	68 a8 2d 80 00       	push   $0x802da8
  8015cd:	e8 df ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015da:	eb 23                	jmp    8015ff <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015df:	8b 52 18             	mov    0x18(%edx),%edx
  8015e2:	85 d2                	test   %edx,%edx
  8015e4:	74 14                	je     8015fa <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ec:	50                   	push   %eax
  8015ed:	ff d2                	call   *%edx
  8015ef:	89 c2                	mov    %eax,%edx
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	eb 09                	jmp    8015ff <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f6:	89 c2                	mov    %eax,%edx
  8015f8:	eb 05                	jmp    8015ff <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015ff:	89 d0                	mov    %edx,%eax
  801601:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	53                   	push   %ebx
  80160a:	83 ec 14             	sub    $0x14,%esp
  80160d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801610:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	e8 6c fb ff ff       	call   801188 <fd_lookup>
  80161c:	83 c4 08             	add    $0x8,%esp
  80161f:	89 c2                	mov    %eax,%edx
  801621:	85 c0                	test   %eax,%eax
  801623:	78 58                	js     80167d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162f:	ff 30                	pushl  (%eax)
  801631:	e8 a8 fb ff ff       	call   8011de <dev_lookup>
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	85 c0                	test   %eax,%eax
  80163b:	78 37                	js     801674 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801640:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801644:	74 32                	je     801678 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801646:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801649:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801650:	00 00 00 
	stat->st_isdir = 0;
  801653:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80165a:	00 00 00 
	stat->st_dev = dev;
  80165d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	53                   	push   %ebx
  801667:	ff 75 f0             	pushl  -0x10(%ebp)
  80166a:	ff 50 14             	call   *0x14(%eax)
  80166d:	89 c2                	mov    %eax,%edx
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	eb 09                	jmp    80167d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801674:	89 c2                	mov    %eax,%edx
  801676:	eb 05                	jmp    80167d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801678:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80167d:	89 d0                	mov    %edx,%eax
  80167f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	56                   	push   %esi
  801688:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	6a 00                	push   $0x0
  80168e:	ff 75 08             	pushl  0x8(%ebp)
  801691:	e8 2c 02 00 00       	call   8018c2 <open>
  801696:	89 c3                	mov    %eax,%ebx
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 1b                	js     8016ba <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80169f:	83 ec 08             	sub    $0x8,%esp
  8016a2:	ff 75 0c             	pushl  0xc(%ebp)
  8016a5:	50                   	push   %eax
  8016a6:	e8 5b ff ff ff       	call   801606 <fstat>
  8016ab:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ad:	89 1c 24             	mov    %ebx,(%esp)
  8016b0:	e8 fd fb ff ff       	call   8012b2 <close>
	return r;
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	89 f0                	mov    %esi,%eax
}
  8016ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5e                   	pop    %esi
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	89 c6                	mov    %eax,%esi
  8016c8:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  8016ca:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016d1:	75 12                	jne    8016e5 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  8016d3:	83 ec 0c             	sub    $0xc,%esp
  8016d6:	6a 01                	push   $0x1
  8016d8:	e8 ff 0e 00 00       	call   8025dc <ipc_find_env>
  8016dd:	a3 00 40 80 00       	mov    %eax,0x804000
  8016e2:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016e5:	6a 07                	push   $0x7
  8016e7:	68 00 50 80 00       	push   $0x805000
  8016ec:	56                   	push   %esi
  8016ed:	ff 35 00 40 80 00    	pushl  0x804000
  8016f3:	e8 90 0e 00 00       	call   802588 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  8016f8:	83 c4 0c             	add    $0xc,%esp
  8016fb:	6a 00                	push   $0x0
  8016fd:	53                   	push   %ebx
  8016fe:	6a 00                	push   $0x0
  801700:	e8 24 0e 00 00       	call   802529 <ipc_recv>
}
  801705:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801708:	5b                   	pop    %ebx
  801709:	5e                   	pop    %esi
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	8b 40 0c             	mov    0xc(%eax),%eax
  801718:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  80171d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801720:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  801725:	ba 00 00 00 00       	mov    $0x0,%edx
  80172a:	b8 02 00 00 00       	mov    $0x2,%eax
  80172f:	e8 8d ff ff ff       	call   8016c1 <fsipc>
}
  801734:	c9                   	leave  
  801735:	c3                   	ret    

00801736 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80173c:	8b 45 08             	mov    0x8(%ebp),%eax
  80173f:	8b 40 0c             	mov    0xc(%eax),%eax
  801742:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  801747:	ba 00 00 00 00       	mov    $0x0,%edx
  80174c:	b8 06 00 00 00       	mov    $0x6,%eax
  801751:	e8 6b ff ff ff       	call   8016c1 <fsipc>
}
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	53                   	push   %ebx
  80175c:	83 ec 04             	sub    $0x4,%esp
  80175f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801762:	8b 45 08             	mov    0x8(%ebp),%eax
  801765:	8b 40 0c             	mov    0xc(%eax),%eax
  801768:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 05 00 00 00       	mov    $0x5,%eax
  801777:	e8 45 ff ff ff       	call   8016c1 <fsipc>
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 2c                	js     8017ac <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801780:	83 ec 08             	sub    $0x8,%esp
  801783:	68 00 50 80 00       	push   $0x805000
  801788:	53                   	push   %ebx
  801789:	e8 a8 f0 ff ff       	call   800836 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  80178e:	a1 80 50 80 00       	mov    0x805080,%eax
  801793:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801799:	a1 84 50 80 00       	mov    0x805084,%eax
  80179e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	53                   	push   %ebx
  8017b5:	83 ec 08             	sub    $0x8,%esp
  8017b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c1:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  8017c6:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  8017cc:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8017d2:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8017d7:	0f 46 c3             	cmovbe %ebx,%eax
  8017da:	50                   	push   %eax
  8017db:	ff 75 0c             	pushl  0xc(%ebp)
  8017de:	68 08 50 80 00       	push   $0x805008
  8017e3:	e8 e0 f1 ff ff       	call   8009c8 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  8017e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ed:	b8 04 00 00 00       	mov    $0x4,%eax
  8017f2:	e8 ca fe ff ff       	call   8016c1 <fsipc>
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 3d                	js     80183b <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  8017fe:	39 c3                	cmp    %eax,%ebx
  801800:	73 19                	jae    80181b <devfile_write+0x6a>
  801802:	68 14 2e 80 00       	push   $0x802e14
  801807:	68 1b 2e 80 00       	push   $0x802e1b
  80180c:	68 9a 00 00 00       	push   $0x9a
  801811:	68 30 2e 80 00       	push   $0x802e30
  801816:	e8 bd e9 ff ff       	call   8001d8 <_panic>
	   assert (r <= bytes_written);
  80181b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801820:	7e 19                	jle    80183b <devfile_write+0x8a>
  801822:	68 3b 2e 80 00       	push   $0x802e3b
  801827:	68 1b 2e 80 00       	push   $0x802e1b
  80182c:	68 9b 00 00 00       	push   $0x9b
  801831:	68 30 2e 80 00       	push   $0x802e30
  801836:	e8 9d e9 ff ff       	call   8001d8 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  80183b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	56                   	push   %esi
  801844:	53                   	push   %ebx
  801845:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  801848:	8b 45 08             	mov    0x8(%ebp),%eax
  80184b:	8b 40 0c             	mov    0xc(%eax),%eax
  80184e:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  801853:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801859:	ba 00 00 00 00       	mov    $0x0,%edx
  80185e:	b8 03 00 00 00       	mov    $0x3,%eax
  801863:	e8 59 fe ff ff       	call   8016c1 <fsipc>
  801868:	89 c3                	mov    %eax,%ebx
  80186a:	85 c0                	test   %eax,%eax
  80186c:	78 4b                	js     8018b9 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  80186e:	39 c6                	cmp    %eax,%esi
  801870:	73 16                	jae    801888 <devfile_read+0x48>
  801872:	68 14 2e 80 00       	push   $0x802e14
  801877:	68 1b 2e 80 00       	push   $0x802e1b
  80187c:	6a 7c                	push   $0x7c
  80187e:	68 30 2e 80 00       	push   $0x802e30
  801883:	e8 50 e9 ff ff       	call   8001d8 <_panic>
	   assert(r <= PGSIZE);
  801888:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80188d:	7e 16                	jle    8018a5 <devfile_read+0x65>
  80188f:	68 4e 2e 80 00       	push   $0x802e4e
  801894:	68 1b 2e 80 00       	push   $0x802e1b
  801899:	6a 7d                	push   $0x7d
  80189b:	68 30 2e 80 00       	push   $0x802e30
  8018a0:	e8 33 e9 ff ff       	call   8001d8 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018a5:	83 ec 04             	sub    $0x4,%esp
  8018a8:	50                   	push   %eax
  8018a9:	68 00 50 80 00       	push   $0x805000
  8018ae:	ff 75 0c             	pushl  0xc(%ebp)
  8018b1:	e8 12 f1 ff ff       	call   8009c8 <memmove>
	   return r;
  8018b6:	83 c4 10             	add    $0x10,%esp
}
  8018b9:	89 d8                	mov    %ebx,%eax
  8018bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018be:	5b                   	pop    %ebx
  8018bf:	5e                   	pop    %esi
  8018c0:	5d                   	pop    %ebp
  8018c1:	c3                   	ret    

008018c2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	53                   	push   %ebx
  8018c6:	83 ec 20             	sub    $0x20,%esp
  8018c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  8018cc:	53                   	push   %ebx
  8018cd:	e8 2b ef ff ff       	call   8007fd <strlen>
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018da:	7f 67                	jg     801943 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8018dc:	83 ec 0c             	sub    $0xc,%esp
  8018df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e2:	50                   	push   %eax
  8018e3:	e8 51 f8 ff ff       	call   801139 <fd_alloc>
  8018e8:	83 c4 10             	add    $0x10,%esp
			 return r;
  8018eb:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 57                	js     801948 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  8018f1:	83 ec 08             	sub    $0x8,%esp
  8018f4:	53                   	push   %ebx
  8018f5:	68 00 50 80 00       	push   $0x805000
  8018fa:	e8 37 ef ff ff       	call   800836 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  8018ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801902:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801907:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190a:	b8 01 00 00 00       	mov    $0x1,%eax
  80190f:	e8 ad fd ff ff       	call   8016c1 <fsipc>
  801914:	89 c3                	mov    %eax,%ebx
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	85 c0                	test   %eax,%eax
  80191b:	79 14                	jns    801931 <open+0x6f>
			 fd_close(fd, 0);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	6a 00                	push   $0x0
  801922:	ff 75 f4             	pushl  -0xc(%ebp)
  801925:	e8 07 f9 ff ff       	call   801231 <fd_close>
			 return r;
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	89 da                	mov    %ebx,%edx
  80192f:	eb 17                	jmp    801948 <open+0x86>
	   }

	   return fd2num(fd);
  801931:	83 ec 0c             	sub    $0xc,%esp
  801934:	ff 75 f4             	pushl  -0xc(%ebp)
  801937:	e8 d6 f7 ff ff       	call   801112 <fd2num>
  80193c:	89 c2                	mov    %eax,%edx
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	eb 05                	jmp    801948 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  801943:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801948:	89 d0                	mov    %edx,%eax
  80194a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801955:	ba 00 00 00 00       	mov    $0x0,%edx
  80195a:	b8 08 00 00 00       	mov    $0x8,%eax
  80195f:	e8 5d fd ff ff       	call   8016c1 <fsipc>
}
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
	   int
spawn(const char *prog, const char **argv)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	57                   	push   %edi
  80196a:	56                   	push   %esi
  80196b:	53                   	push   %ebx
  80196c:	81 ec 94 02 00 00    	sub    $0x294,%esp
	   //   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	   //     correct initial eip and esp values in the child.
	   //
	   //   - Start the child process running with sys_env_set_status().

	   if ((r = open(prog, O_RDONLY)) < 0)
  801972:	6a 00                	push   $0x0
  801974:	ff 75 08             	pushl  0x8(%ebp)
  801977:	e8 46 ff ff ff       	call   8018c2 <open>
  80197c:	89 c1                	mov    %eax,%ecx
  80197e:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	0f 88 de 04 00 00    	js     801e6d <spawn+0x507>
			 return r;
	   fd = r;

	   // Read elf header
	   elf = (struct Elf*) elf_buf;
	   if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80198f:	83 ec 04             	sub    $0x4,%esp
  801992:	68 00 02 00 00       	push   $0x200
  801997:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80199d:	50                   	push   %eax
  80199e:	51                   	push   %ecx
  80199f:	e8 db fa ff ff       	call   80147f <readn>
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019ac:	75 0c                	jne    8019ba <spawn+0x54>
				    || elf->e_magic != ELF_MAGIC) {
  8019ae:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019b5:	45 4c 46 
  8019b8:	74 33                	je     8019ed <spawn+0x87>
			 close(fd);
  8019ba:	83 ec 0c             	sub    $0xc,%esp
  8019bd:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019c3:	e8 ea f8 ff ff       	call   8012b2 <close>
			 cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019c8:	83 c4 0c             	add    $0xc,%esp
  8019cb:	68 7f 45 4c 46       	push   $0x464c457f
  8019d0:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019d6:	68 5a 2e 80 00       	push   $0x802e5a
  8019db:	e8 d1 e8 ff ff       	call   8002b1 <cprintf>
			 return -E_NOT_EXEC;
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8019e8:	e9 12 05 00 00       	jmp    801eff <spawn+0x599>
  8019ed:	b8 07 00 00 00       	mov    $0x7,%eax
  8019f2:	cd 30                	int    $0x30
  8019f4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019fa:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	   }

	   // Create new child environment
	   if ((r = sys_exofork()) < 0)
  801a00:	85 c0                	test   %eax,%eax
  801a02:	0f 88 70 04 00 00    	js     801e78 <spawn+0x512>
			 return r;
	   child = r;

	   // Set up trap frame, including initial stack.
	   child_tf = envs[ENVX(child)].env_tf;
  801a08:	89 c6                	mov    %eax,%esi
  801a0a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a10:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801a13:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a19:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a1f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	   child_tf.tf_eip = elf->e_entry;
  801a26:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a2c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
	   for (argc = 0; argv[argc] != 0; argc++)
  801a32:	bb 00 00 00 00       	mov    $0x0,%ebx
	   char *string_store;
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
  801a37:	be 00 00 00 00       	mov    $0x0,%esi
  801a3c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a3f:	eb 13                	jmp    801a54 <spawn+0xee>
	   for (argc = 0; argv[argc] != 0; argc++)
			 string_size += strlen(argv[argc]) + 1;
  801a41:	83 ec 0c             	sub    $0xc,%esp
  801a44:	50                   	push   %eax
  801a45:	e8 b3 ed ff ff       	call   8007fd <strlen>
  801a4a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
	   for (argc = 0; argv[argc] != 0; argc++)
  801a4e:	83 c3 01             	add    $0x1,%ebx
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a5b:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	75 df                	jne    801a41 <spawn+0xdb>
  801a62:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801a68:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	   // Determine where to place the strings and the argv array.
	   // Set up pointers into the temporary page 'UTEMP'; we'll map a page
	   // there later, then remap that page into the child environment
	   // at (USTACKTOP - PGSIZE).
	   // strings is the topmost thing on the stack.
	   string_store = (char*) UTEMP + PGSIZE - string_size;
  801a6e:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a73:	29 f7                	sub    %esi,%edi
	   // argv is below that.  There's one argument pointer per argument, plus
	   // a null pointer.
	   argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a75:	89 fa                	mov    %edi,%edx
  801a77:	83 e2 fc             	and    $0xfffffffc,%edx
  801a7a:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a81:	29 c2                	sub    %eax,%edx
  801a83:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	   // Make sure that argv, strings, and the 2 words that hold 'argc'
	   // and 'argv' themselves will all fit in a single stack page.
	   if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a89:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a8c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a91:	0f 86 f1 03 00 00    	jbe    801e88 <spawn+0x522>
			 return -E_NO_MEM;

	   // Allocate the single stack page at UTEMP.
	   if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a97:	83 ec 04             	sub    $0x4,%esp
  801a9a:	6a 07                	push   $0x7
  801a9c:	68 00 00 40 00       	push   $0x400000
  801aa1:	6a 00                	push   $0x0
  801aa3:	e8 91 f1 ff ff       	call   800c39 <sys_page_alloc>
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	85 c0                	test   %eax,%eax
  801aad:	0f 88 dc 03 00 00    	js     801e8f <spawn+0x529>
  801ab3:	be 00 00 00 00       	mov    $0x0,%esi
  801ab8:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801abe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ac1:	eb 30                	jmp    801af3 <spawn+0x18d>
	   //	  environment.)
	   //
	   //	* Set *init_esp to the initial stack pointer for the child,
	   //	  (Again, use an address valid in the child's environment.)
	   for (i = 0; i < argc; i++) {
			 argv_store[i] = UTEMP2USTACK(string_store);
  801ac3:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801ac9:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801acf:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
			 strcpy(string_store, argv[i]);
  801ad2:	83 ec 08             	sub    $0x8,%esp
  801ad5:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ad8:	57                   	push   %edi
  801ad9:	e8 58 ed ff ff       	call   800836 <strcpy>
			 string_store += strlen(argv[i]) + 1;
  801ade:	83 c4 04             	add    $0x4,%esp
  801ae1:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ae4:	e8 14 ed ff ff       	call   8007fd <strlen>
  801ae9:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	   //	  (Again, argv should use an address valid in the child's
	   //	  environment.)
	   //
	   //	* Set *init_esp to the initial stack pointer for the child,
	   //	  (Again, use an address valid in the child's environment.)
	   for (i = 0; i < argc; i++) {
  801aed:	83 c6 01             	add    $0x1,%esi
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801af9:	7f c8                	jg     801ac3 <spawn+0x15d>
			 argv_store[i] = UTEMP2USTACK(string_store);
			 strcpy(string_store, argv[i]);
			 string_store += strlen(argv[i]) + 1;
	   }
	   argv_store[argc] = 0;
  801afb:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b01:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801b07:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	   assert(string_store == (char*)UTEMP + PGSIZE);
  801b0e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b14:	74 19                	je     801b2f <spawn+0x1c9>
  801b16:	68 e4 2e 80 00       	push   $0x802ee4
  801b1b:	68 1b 2e 80 00       	push   $0x802e1b
  801b20:	68 f2 00 00 00       	push   $0xf2
  801b25:	68 74 2e 80 00       	push   $0x802e74
  801b2a:	e8 a9 e6 ff ff       	call   8001d8 <_panic>

	   argv_store[-1] = UTEMP2USTACK(argv_store);
  801b2f:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b35:	89 c8                	mov    %ecx,%eax
  801b37:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b3c:	89 41 fc             	mov    %eax,-0x4(%ecx)
	   argv_store[-2] = argc;
  801b3f:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801b45:	89 41 f8             	mov    %eax,-0x8(%ecx)

	   *init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b48:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801b4e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	   // After completing the stack, map it into the child's address space
	   // and unmap it from ours!
	   if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b54:	83 ec 0c             	sub    $0xc,%esp
  801b57:	6a 07                	push   $0x7
  801b59:	68 00 d0 bf ee       	push   $0xeebfd000
  801b5e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b64:	68 00 00 40 00       	push   $0x400000
  801b69:	6a 00                	push   $0x0
  801b6b:	e8 0c f1 ff ff       	call   800c7c <sys_page_map>
  801b70:	89 c3                	mov    %eax,%ebx
  801b72:	83 c4 20             	add    $0x20,%esp
  801b75:	85 c0                	test   %eax,%eax
  801b77:	0f 88 70 03 00 00    	js     801eed <spawn+0x587>
			 goto error;
	   if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b7d:	83 ec 08             	sub    $0x8,%esp
  801b80:	68 00 00 40 00       	push   $0x400000
  801b85:	6a 00                	push   $0x0
  801b87:	e8 32 f1 ff ff       	call   800cbe <sys_page_unmap>
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	85 c0                	test   %eax,%eax
  801b93:	0f 88 54 03 00 00    	js     801eed <spawn+0x587>

	   if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
			 return r;

	   // Set up program segments as defined in ELF header.
	   ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b99:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b9f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ba6:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	   for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bac:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801bb3:	00 00 00 
  801bb6:	e9 86 01 00 00       	jmp    801d41 <spawn+0x3db>
			 if (ph->p_type != ELF_PROG_LOAD)
  801bbb:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801bc1:	83 38 01             	cmpl   $0x1,(%eax)
  801bc4:	0f 85 69 01 00 00    	jne    801d33 <spawn+0x3cd>
				    continue;
			 perm = PTE_P | PTE_U;
			 if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801bca:	89 c1                	mov    %eax,%ecx
  801bcc:	8b 40 18             	mov    0x18(%eax),%eax
  801bcf:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801bd5:	83 e0 02             	and    $0x2,%eax
				    perm |= PTE_W;
  801bd8:	83 f8 01             	cmp    $0x1,%eax
  801bdb:	19 c0                	sbb    %eax,%eax
  801bdd:	83 e0 fe             	and    $0xfffffffe,%eax
  801be0:	83 c0 07             	add    $0x7,%eax
  801be3:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
			 if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801be9:	89 c8                	mov    %ecx,%eax
  801beb:	8b 49 04             	mov    0x4(%ecx),%ecx
  801bee:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801bf4:	8b 78 10             	mov    0x10(%eax),%edi
  801bf7:	8b 50 14             	mov    0x14(%eax),%edx
  801bfa:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801c00:	8b 70 08             	mov    0x8(%eax),%esi
	   int i, r;
	   void *blk;

	   //cprintf("map_segment %x+%x\n", va, memsz);

	   if ((i = PGOFF(va))) {
  801c03:	89 f0                	mov    %esi,%eax
  801c05:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c0a:	74 14                	je     801c20 <spawn+0x2ba>
			 va -= i;
  801c0c:	29 c6                	sub    %eax,%esi
			 memsz += i;
  801c0e:	01 c2                	add    %eax,%edx
  801c10:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
			 filesz += i;
  801c16:	01 c7                	add    %eax,%edi
			 fileoffset -= i;
  801c18:	29 c1                	sub    %eax,%ecx
  801c1a:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	   }

	   for (i = 0; i < memsz; i += PGSIZE) {
  801c20:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c25:	e9 f7 00 00 00       	jmp    801d21 <spawn+0x3bb>
			 if (i >= filesz) {
  801c2a:	39 df                	cmp    %ebx,%edi
  801c2c:	77 27                	ja     801c55 <spawn+0x2ef>
				    // allocate a blank page
				    if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c2e:	83 ec 04             	sub    $0x4,%esp
  801c31:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c37:	56                   	push   %esi
  801c38:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801c3e:	e8 f6 ef ff ff       	call   800c39 <sys_page_alloc>
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	85 c0                	test   %eax,%eax
  801c48:	0f 89 c7 00 00 00    	jns    801d15 <spawn+0x3af>
  801c4e:	89 c3                	mov    %eax,%ebx
  801c50:	e9 48 02 00 00       	jmp    801e9d <spawn+0x537>
						  return r;
			 } else {
				    // from file
				    if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c55:	83 ec 04             	sub    $0x4,%esp
  801c58:	6a 07                	push   $0x7
  801c5a:	68 00 00 40 00       	push   $0x400000
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 d3 ef ff ff       	call   800c39 <sys_page_alloc>
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	0f 88 22 02 00 00    	js     801e93 <spawn+0x52d>
						  return r;
				    if ((r = seek(fd, fileoffset + i)) < 0)
  801c71:	83 ec 08             	sub    $0x8,%esp
  801c74:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c7a:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c80:	50                   	push   %eax
  801c81:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c87:	e8 c8 f8 ff ff       	call   801554 <seek>
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	85 c0                	test   %eax,%eax
  801c91:	0f 88 00 02 00 00    	js     801e97 <spawn+0x531>
						  return r;
				    if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c97:	83 ec 04             	sub    $0x4,%esp
  801c9a:	89 f8                	mov    %edi,%eax
  801c9c:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801ca2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ca7:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801cac:	0f 47 c1             	cmova  %ecx,%eax
  801caf:	50                   	push   %eax
  801cb0:	68 00 00 40 00       	push   $0x400000
  801cb5:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cbb:	e8 bf f7 ff ff       	call   80147f <readn>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	0f 88 d0 01 00 00    	js     801e9b <spawn+0x535>
						  return r;
				    if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cd4:	56                   	push   %esi
  801cd5:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801cdb:	68 00 00 40 00       	push   $0x400000
  801ce0:	6a 00                	push   $0x0
  801ce2:	e8 95 ef ff ff       	call   800c7c <sys_page_map>
  801ce7:	83 c4 20             	add    $0x20,%esp
  801cea:	85 c0                	test   %eax,%eax
  801cec:	79 15                	jns    801d03 <spawn+0x39d>
						  panic("spawn: sys_page_map data: %e", r);
  801cee:	50                   	push   %eax
  801cef:	68 80 2e 80 00       	push   $0x802e80
  801cf4:	68 25 01 00 00       	push   $0x125
  801cf9:	68 74 2e 80 00       	push   $0x802e74
  801cfe:	e8 d5 e4 ff ff       	call   8001d8 <_panic>
				    sys_page_unmap(0, UTEMP);
  801d03:	83 ec 08             	sub    $0x8,%esp
  801d06:	68 00 00 40 00       	push   $0x400000
  801d0b:	6a 00                	push   $0x0
  801d0d:	e8 ac ef ff ff       	call   800cbe <sys_page_unmap>
  801d12:	83 c4 10             	add    $0x10,%esp
			 memsz += i;
			 filesz += i;
			 fileoffset -= i;
	   }

	   for (i = 0; i < memsz; i += PGSIZE) {
  801d15:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d1b:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d21:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d27:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801d2d:	0f 87 f7 fe ff ff    	ja     801c2a <spawn+0x2c4>
	   if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
			 return r;

	   // Set up program segments as defined in ELF header.
	   ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	   for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d33:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d3a:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d41:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d48:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d4e:	0f 8c 67 fe ff ff    	jl     801bbb <spawn+0x255>
				    perm |= PTE_W;
			 if ((r = map_segment(child, ph->p_va, ph->p_memsz,
									   fd, ph->p_filesz, ph->p_offset, perm)) < 0)
				    goto error;
	   }
	   close(fd);
  801d54:	83 ec 0c             	sub    $0xc,%esp
  801d57:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d5d:	e8 50 f5 ff ff       	call   8012b2 <close>
  801d62:	83 c4 10             	add    $0x10,%esp
	   static int
copy_shared_pages(envid_t child)
{
	   // LAB 5: Your code here.
	   int r;
	   bool is_below_ulim = true;
  801d65:	c6 85 94 fd ff ff 01 	movb   $0x1,-0x26c(%ebp)
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
  801d6c:	c7 85 8c fd ff ff 00 	movl   $0x0,-0x274(%ebp)
  801d73:	00 00 00 
	   {
			 if (!(uvpd[i] & PTE_P)) 
  801d76:	8b bd 8c fd ff ff    	mov    -0x274(%ebp),%edi
  801d7c:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  801d83:	a8 01                	test   $0x1,%al
  801d85:	74 7b                	je     801e02 <spawn+0x49c>
  801d87:	89 fb                	mov    %edi,%ebx
  801d89:	c1 e3 0a             	shl    $0xa,%ebx
  801d8c:	c1 e7 16             	shl    $0x16,%edi
  801d8f:	be 00 00 00 00       	mov    $0x0,%esi
  801d94:	eb 5b                	jmp    801df1 <spawn+0x48b>
				    continue;
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) 
			 {
				    unsigned pn = i * NPTENTRIES + j;
				    pte_t pte = uvpt[pn];
  801d96:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
				    if (pn >= (UTOP >> PGSHIFT)) 
  801d9d:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801da3:	77 39                	ja     801dde <spawn+0x478>
				    {
						  is_below_ulim = false;
				    } else if (pte & PTE_SHARE) 
  801da5:	f6 c4 04             	test   $0x4,%ah
  801da8:	74 3b                	je     801de5 <spawn+0x47f>
				    {
						  if ((r = sys_page_map(0, (void *)(pn * PGSIZE), child, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  801daa:	83 ec 0c             	sub    $0xc,%esp
  801dad:	25 07 0e 00 00       	and    $0xe07,%eax
  801db2:	50                   	push   %eax
  801db3:	57                   	push   %edi
  801db4:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801dba:	57                   	push   %edi
  801dbb:	6a 00                	push   $0x0
  801dbd:	e8 ba ee ff ff       	call   800c7c <sys_page_map>
  801dc2:	83 c4 20             	add    $0x20,%esp
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	79 1c                	jns    801de5 <spawn+0x47f>
	   close(fd);
	   fd = -1;

	   // Copy shared library state.
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);
  801dc9:	50                   	push   %eax
  801dca:	68 ce 2e 80 00       	push   $0x802ece
  801dcf:	68 82 00 00 00       	push   $0x82
  801dd4:	68 74 2e 80 00       	push   $0x802e74
  801dd9:	e8 fa e3 ff ff       	call   8001d8 <_panic>
			 {
				    unsigned pn = i * NPTENTRIES + j;
				    pte_t pte = uvpt[pn];
				    if (pn >= (UTOP >> PGSHIFT)) 
				    {
						  is_below_ulim = false;
  801dde:	c6 85 94 fd ff ff 00 	movb   $0x0,-0x26c(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
	   {
			 if (!(uvpd[i] & PTE_P)) 
				    continue;
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) 
  801de5:	83 c6 01             	add    $0x1,%esi
  801de8:	83 c3 01             	add    $0x1,%ebx
  801deb:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801df1:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  801df7:	7f 09                	jg     801e02 <spawn+0x49c>
  801df9:	80 bd 94 fd ff ff 00 	cmpb   $0x0,-0x26c(%ebp)
  801e00:	75 94                	jne    801d96 <spawn+0x430>
copy_shared_pages(envid_t child)
{
	   // LAB 5: Your code here.
	   int r;
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
  801e02:	83 85 8c fd ff ff 01 	addl   $0x1,-0x274(%ebp)
  801e09:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801e0f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e14:	0f 8f a4 00 00 00    	jg     801ebe <spawn+0x558>
  801e1a:	80 bd 94 fd ff ff 00 	cmpb   $0x0,-0x26c(%ebp)
  801e21:	0f 85 4f ff ff ff    	jne    801d76 <spawn+0x410>
  801e27:	e9 92 00 00 00       	jmp    801ebe <spawn+0x558>
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);

	   child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	   if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
			 panic("sys_env_set_trapframe: %e", r);
  801e2c:	50                   	push   %eax
  801e2d:	68 9d 2e 80 00       	push   $0x802e9d
  801e32:	68 86 00 00 00       	push   $0x86
  801e37:	68 74 2e 80 00       	push   $0x802e74
  801e3c:	e8 97 e3 ff ff       	call   8001d8 <_panic>

	   if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e41:	83 ec 08             	sub    $0x8,%esp
  801e44:	6a 02                	push   $0x2
  801e46:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e4c:	e8 af ee ff ff       	call   800d00 <sys_env_set_status>
  801e51:	83 c4 10             	add    $0x10,%esp
  801e54:	85 c0                	test   %eax,%eax
  801e56:	79 28                	jns    801e80 <spawn+0x51a>
			 panic("sys_env_set_status: %e", r);
  801e58:	50                   	push   %eax
  801e59:	68 b7 2e 80 00       	push   $0x802eb7
  801e5e:	68 89 00 00 00       	push   $0x89
  801e63:	68 74 2e 80 00       	push   $0x802e74
  801e68:	e8 6b e3 ff ff       	call   8001d8 <_panic>
	   //     correct initial eip and esp values in the child.
	   //
	   //   - Start the child process running with sys_env_set_status().

	   if ((r = open(prog, O_RDONLY)) < 0)
			 return r;
  801e6d:	8b 9d 88 fd ff ff    	mov    -0x278(%ebp),%ebx
  801e73:	e9 87 00 00 00       	jmp    801eff <spawn+0x599>
			 return -E_NOT_EXEC;
	   }

	   // Create new child environment
	   if ((r = sys_exofork()) < 0)
			 return r;
  801e78:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e7e:	eb 7f                	jmp    801eff <spawn+0x599>
			 panic("sys_env_set_trapframe: %e", r);

	   if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
			 panic("sys_env_set_status: %e", r);

	   return child;
  801e80:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e86:	eb 77                	jmp    801eff <spawn+0x599>
	   argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	   // Make sure that argv, strings, and the 2 words that hold 'argc'
	   // and 'argv' themselves will all fit in a single stack page.
	   if ((void*) (argv_store - 2) < (void*) UTEMP)
			 return -E_NO_MEM;
  801e88:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e8d:	eb 70                	jmp    801eff <spawn+0x599>

	   // Allocate the single stack page at UTEMP.
	   if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
			 return r;
  801e8f:	89 c3                	mov    %eax,%ebx
  801e91:	eb 6c                	jmp    801eff <spawn+0x599>
				    // allocate a blank page
				    if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
						  return r;
			 } else {
				    // from file
				    if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e93:	89 c3                	mov    %eax,%ebx
  801e95:	eb 06                	jmp    801e9d <spawn+0x537>
						  return r;
				    if ((r = seek(fd, fileoffset + i)) < 0)
  801e97:	89 c3                	mov    %eax,%ebx
  801e99:	eb 02                	jmp    801e9d <spawn+0x537>
						  return r;
				    if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e9b:	89 c3                	mov    %eax,%ebx
			 panic("sys_env_set_status: %e", r);

	   return child;

error:
	   sys_env_destroy(child);
  801e9d:	83 ec 0c             	sub    $0xc,%esp
  801ea0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ea6:	e8 0f ed ff ff       	call   800bba <sys_env_destroy>
	   close(fd);
  801eab:	83 c4 04             	add    $0x4,%esp
  801eae:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801eb4:	e8 f9 f3 ff ff       	call   8012b2 <close>
	   return r;
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	eb 41                	jmp    801eff <spawn+0x599>

	   // Copy shared library state.
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);

	   child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801ebe:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ec5:	30 00 00 
	   if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ec8:	83 ec 08             	sub    $0x8,%esp
  801ecb:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ed1:	50                   	push   %eax
  801ed2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ed8:	e8 65 ee ff ff       	call   800d42 <sys_env_set_trapframe>
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	0f 89 59 ff ff ff    	jns    801e41 <spawn+0x4db>
  801ee8:	e9 3f ff ff ff       	jmp    801e2c <spawn+0x4c6>
			 goto error;

	   return 0;

error:
	   sys_page_unmap(0, UTEMP);
  801eed:	83 ec 08             	sub    $0x8,%esp
  801ef0:	68 00 00 40 00       	push   $0x400000
  801ef5:	6a 00                	push   $0x0
  801ef7:	e8 c2 ed ff ff       	call   800cbe <sys_page_unmap>
  801efc:	83 c4 10             	add    $0x10,%esp

error:
	   sys_env_destroy(child);
	   close(fd);
	   return r;
}
  801eff:	89 d8                	mov    %ebx,%eax
  801f01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f04:	5b                   	pop    %ebx
  801f05:	5e                   	pop    %esi
  801f06:	5f                   	pop    %edi
  801f07:	5d                   	pop    %ebp
  801f08:	c3                   	ret    

00801f09 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
	   int
spawnl(const char *prog, const char *arg0, ...)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	56                   	push   %esi
  801f0d:	53                   	push   %ebx
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  801f0e:	8d 55 10             	lea    0x10(%ebp),%edx
{
	   // We calculate argc by advancing the args until we hit NULL.
	   // The contract of the function guarantees that the last
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
  801f11:	b8 00 00 00 00       	mov    $0x0,%eax
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  801f16:	eb 03                	jmp    801f1b <spawnl+0x12>
			 argc++;
  801f18:	83 c0 01             	add    $0x1,%eax
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  801f1b:	83 c2 04             	add    $0x4,%edx
  801f1e:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801f22:	75 f4                	jne    801f18 <spawnl+0xf>
			 argc++;
	   va_end(vl);

	   // Now that we have the size of the args, do a second pass
	   // and store the values in a VLA, which has the format of argv
	   const char *argv[argc+2];
  801f24:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801f2b:	83 e2 f0             	and    $0xfffffff0,%edx
  801f2e:	29 d4                	sub    %edx,%esp
  801f30:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f34:	c1 ea 02             	shr    $0x2,%edx
  801f37:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f3e:	89 f3                	mov    %esi,%ebx
	   argv[0] = arg0;
  801f40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f43:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	   argv[argc+1] = NULL;
  801f4a:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f51:	00 
  801f52:	89 c2                	mov    %eax,%edx

	   va_start(vl, arg0);
	   unsigned i;
	   for(i=0;i<argc;i++)
  801f54:	b8 00 00 00 00       	mov    $0x0,%eax
  801f59:	eb 0a                	jmp    801f65 <spawnl+0x5c>
			 argv[i+1] = va_arg(vl, const char *);
  801f5b:	83 c0 01             	add    $0x1,%eax
  801f5e:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f62:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	   argv[0] = arg0;
	   argv[argc+1] = NULL;

	   va_start(vl, arg0);
	   unsigned i;
	   for(i=0;i<argc;i++)
  801f65:	39 d0                	cmp    %edx,%eax
  801f67:	75 f2                	jne    801f5b <spawnl+0x52>
			 argv[i+1] = va_arg(vl, const char *);
	   va_end(vl);
	   return spawn(prog, argv);
  801f69:	83 ec 08             	sub    $0x8,%esp
  801f6c:	56                   	push   %esi
  801f6d:	ff 75 08             	pushl  0x8(%ebp)
  801f70:	e8 f1 f9 ff ff       	call   801966 <spawn>
}
  801f75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f78:	5b                   	pop    %ebx
  801f79:	5e                   	pop    %esi
  801f7a:	5d                   	pop    %ebp
  801f7b:	c3                   	ret    

00801f7c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	56                   	push   %esi
  801f80:	53                   	push   %ebx
  801f81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f84:	83 ec 0c             	sub    $0xc,%esp
  801f87:	ff 75 08             	pushl  0x8(%ebp)
  801f8a:	e8 93 f1 ff ff       	call   801122 <fd2data>
  801f8f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f91:	83 c4 08             	add    $0x8,%esp
  801f94:	68 0c 2f 80 00       	push   $0x802f0c
  801f99:	53                   	push   %ebx
  801f9a:	e8 97 e8 ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f9f:	8b 46 04             	mov    0x4(%esi),%eax
  801fa2:	2b 06                	sub    (%esi),%eax
  801fa4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801faa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fb1:	00 00 00 
	stat->st_dev = &devpipe;
  801fb4:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801fbb:	30 80 00 
	return 0;
}
  801fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc6:	5b                   	pop    %ebx
  801fc7:	5e                   	pop    %esi
  801fc8:	5d                   	pop    %ebp
  801fc9:	c3                   	ret    

00801fca <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	53                   	push   %ebx
  801fce:	83 ec 0c             	sub    $0xc,%esp
  801fd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fd4:	53                   	push   %ebx
  801fd5:	6a 00                	push   $0x0
  801fd7:	e8 e2 ec ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fdc:	89 1c 24             	mov    %ebx,(%esp)
  801fdf:	e8 3e f1 ff ff       	call   801122 <fd2data>
  801fe4:	83 c4 08             	add    $0x8,%esp
  801fe7:	50                   	push   %eax
  801fe8:	6a 00                	push   $0x0
  801fea:	e8 cf ec ff ff       	call   800cbe <sys_page_unmap>
}
  801fef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff2:	c9                   	leave  
  801ff3:	c3                   	ret    

00801ff4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	57                   	push   %edi
  801ff8:	56                   	push   %esi
  801ff9:	53                   	push   %ebx
  801ffa:	83 ec 1c             	sub    $0x1c,%esp
  801ffd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802000:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802002:	a1 04 40 80 00       	mov    0x804004,%eax
  802007:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80200a:	83 ec 0c             	sub    $0xc,%esp
  80200d:	ff 75 e0             	pushl  -0x20(%ebp)
  802010:	e8 00 06 00 00       	call   802615 <pageref>
  802015:	89 c3                	mov    %eax,%ebx
  802017:	89 3c 24             	mov    %edi,(%esp)
  80201a:	e8 f6 05 00 00       	call   802615 <pageref>
  80201f:	83 c4 10             	add    $0x10,%esp
  802022:	39 c3                	cmp    %eax,%ebx
  802024:	0f 94 c1             	sete   %cl
  802027:	0f b6 c9             	movzbl %cl,%ecx
  80202a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80202d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802033:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802036:	39 ce                	cmp    %ecx,%esi
  802038:	74 1b                	je     802055 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80203a:	39 c3                	cmp    %eax,%ebx
  80203c:	75 c4                	jne    802002 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80203e:	8b 42 58             	mov    0x58(%edx),%eax
  802041:	ff 75 e4             	pushl  -0x1c(%ebp)
  802044:	50                   	push   %eax
  802045:	56                   	push   %esi
  802046:	68 13 2f 80 00       	push   $0x802f13
  80204b:	e8 61 e2 ff ff       	call   8002b1 <cprintf>
  802050:	83 c4 10             	add    $0x10,%esp
  802053:	eb ad                	jmp    802002 <_pipeisclosed+0xe>
	}
}
  802055:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802058:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205b:	5b                   	pop    %ebx
  80205c:	5e                   	pop    %esi
  80205d:	5f                   	pop    %edi
  80205e:	5d                   	pop    %ebp
  80205f:	c3                   	ret    

00802060 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	57                   	push   %edi
  802064:	56                   	push   %esi
  802065:	53                   	push   %ebx
  802066:	83 ec 28             	sub    $0x28,%esp
  802069:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80206c:	56                   	push   %esi
  80206d:	e8 b0 f0 ff ff       	call   801122 <fd2data>
  802072:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802074:	83 c4 10             	add    $0x10,%esp
  802077:	bf 00 00 00 00       	mov    $0x0,%edi
  80207c:	eb 4b                	jmp    8020c9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80207e:	89 da                	mov    %ebx,%edx
  802080:	89 f0                	mov    %esi,%eax
  802082:	e8 6d ff ff ff       	call   801ff4 <_pipeisclosed>
  802087:	85 c0                	test   %eax,%eax
  802089:	75 48                	jne    8020d3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80208b:	e8 8a eb ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802090:	8b 43 04             	mov    0x4(%ebx),%eax
  802093:	8b 0b                	mov    (%ebx),%ecx
  802095:	8d 51 20             	lea    0x20(%ecx),%edx
  802098:	39 d0                	cmp    %edx,%eax
  80209a:	73 e2                	jae    80207e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80209c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80209f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020a3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020a6:	89 c2                	mov    %eax,%edx
  8020a8:	c1 fa 1f             	sar    $0x1f,%edx
  8020ab:	89 d1                	mov    %edx,%ecx
  8020ad:	c1 e9 1b             	shr    $0x1b,%ecx
  8020b0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020b3:	83 e2 1f             	and    $0x1f,%edx
  8020b6:	29 ca                	sub    %ecx,%edx
  8020b8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020c0:	83 c0 01             	add    $0x1,%eax
  8020c3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c6:	83 c7 01             	add    $0x1,%edi
  8020c9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020cc:	75 c2                	jne    802090 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d1:	eb 05                	jmp    8020d8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020d3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020db:	5b                   	pop    %ebx
  8020dc:	5e                   	pop    %esi
  8020dd:	5f                   	pop    %edi
  8020de:	5d                   	pop    %ebp
  8020df:	c3                   	ret    

008020e0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	57                   	push   %edi
  8020e4:	56                   	push   %esi
  8020e5:	53                   	push   %ebx
  8020e6:	83 ec 18             	sub    $0x18,%esp
  8020e9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020ec:	57                   	push   %edi
  8020ed:	e8 30 f0 ff ff       	call   801122 <fd2data>
  8020f2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f4:	83 c4 10             	add    $0x10,%esp
  8020f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020fc:	eb 3d                	jmp    80213b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020fe:	85 db                	test   %ebx,%ebx
  802100:	74 04                	je     802106 <devpipe_read+0x26>
				return i;
  802102:	89 d8                	mov    %ebx,%eax
  802104:	eb 44                	jmp    80214a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802106:	89 f2                	mov    %esi,%edx
  802108:	89 f8                	mov    %edi,%eax
  80210a:	e8 e5 fe ff ff       	call   801ff4 <_pipeisclosed>
  80210f:	85 c0                	test   %eax,%eax
  802111:	75 32                	jne    802145 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802113:	e8 02 eb ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802118:	8b 06                	mov    (%esi),%eax
  80211a:	3b 46 04             	cmp    0x4(%esi),%eax
  80211d:	74 df                	je     8020fe <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80211f:	99                   	cltd   
  802120:	c1 ea 1b             	shr    $0x1b,%edx
  802123:	01 d0                	add    %edx,%eax
  802125:	83 e0 1f             	and    $0x1f,%eax
  802128:	29 d0                	sub    %edx,%eax
  80212a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80212f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802132:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802135:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802138:	83 c3 01             	add    $0x1,%ebx
  80213b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80213e:	75 d8                	jne    802118 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802140:	8b 45 10             	mov    0x10(%ebp),%eax
  802143:	eb 05                	jmp    80214a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802145:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80214a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    

00802152 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802152:	55                   	push   %ebp
  802153:	89 e5                	mov    %esp,%ebp
  802155:	56                   	push   %esi
  802156:	53                   	push   %ebx
  802157:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80215a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80215d:	50                   	push   %eax
  80215e:	e8 d6 ef ff ff       	call   801139 <fd_alloc>
  802163:	83 c4 10             	add    $0x10,%esp
  802166:	89 c2                	mov    %eax,%edx
  802168:	85 c0                	test   %eax,%eax
  80216a:	0f 88 2c 01 00 00    	js     80229c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802170:	83 ec 04             	sub    $0x4,%esp
  802173:	68 07 04 00 00       	push   $0x407
  802178:	ff 75 f4             	pushl  -0xc(%ebp)
  80217b:	6a 00                	push   $0x0
  80217d:	e8 b7 ea ff ff       	call   800c39 <sys_page_alloc>
  802182:	83 c4 10             	add    $0x10,%esp
  802185:	89 c2                	mov    %eax,%edx
  802187:	85 c0                	test   %eax,%eax
  802189:	0f 88 0d 01 00 00    	js     80229c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80218f:	83 ec 0c             	sub    $0xc,%esp
  802192:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802195:	50                   	push   %eax
  802196:	e8 9e ef ff ff       	call   801139 <fd_alloc>
  80219b:	89 c3                	mov    %eax,%ebx
  80219d:	83 c4 10             	add    $0x10,%esp
  8021a0:	85 c0                	test   %eax,%eax
  8021a2:	0f 88 e2 00 00 00    	js     80228a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021a8:	83 ec 04             	sub    $0x4,%esp
  8021ab:	68 07 04 00 00       	push   $0x407
  8021b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b3:	6a 00                	push   $0x0
  8021b5:	e8 7f ea ff ff       	call   800c39 <sys_page_alloc>
  8021ba:	89 c3                	mov    %eax,%ebx
  8021bc:	83 c4 10             	add    $0x10,%esp
  8021bf:	85 c0                	test   %eax,%eax
  8021c1:	0f 88 c3 00 00 00    	js     80228a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021c7:	83 ec 0c             	sub    $0xc,%esp
  8021ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8021cd:	e8 50 ef ff ff       	call   801122 <fd2data>
  8021d2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d4:	83 c4 0c             	add    $0xc,%esp
  8021d7:	68 07 04 00 00       	push   $0x407
  8021dc:	50                   	push   %eax
  8021dd:	6a 00                	push   $0x0
  8021df:	e8 55 ea ff ff       	call   800c39 <sys_page_alloc>
  8021e4:	89 c3                	mov    %eax,%ebx
  8021e6:	83 c4 10             	add    $0x10,%esp
  8021e9:	85 c0                	test   %eax,%eax
  8021eb:	0f 88 89 00 00 00    	js     80227a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021f1:	83 ec 0c             	sub    $0xc,%esp
  8021f4:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f7:	e8 26 ef ff ff       	call   801122 <fd2data>
  8021fc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802203:	50                   	push   %eax
  802204:	6a 00                	push   $0x0
  802206:	56                   	push   %esi
  802207:	6a 00                	push   $0x0
  802209:	e8 6e ea ff ff       	call   800c7c <sys_page_map>
  80220e:	89 c3                	mov    %eax,%ebx
  802210:	83 c4 20             	add    $0x20,%esp
  802213:	85 c0                	test   %eax,%eax
  802215:	78 55                	js     80226c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802217:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80221d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802220:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802225:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80222c:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802232:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802235:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802237:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80223a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802241:	83 ec 0c             	sub    $0xc,%esp
  802244:	ff 75 f4             	pushl  -0xc(%ebp)
  802247:	e8 c6 ee ff ff       	call   801112 <fd2num>
  80224c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80224f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802251:	83 c4 04             	add    $0x4,%esp
  802254:	ff 75 f0             	pushl  -0x10(%ebp)
  802257:	e8 b6 ee ff ff       	call   801112 <fd2num>
  80225c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80225f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802262:	83 c4 10             	add    $0x10,%esp
  802265:	ba 00 00 00 00       	mov    $0x0,%edx
  80226a:	eb 30                	jmp    80229c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80226c:	83 ec 08             	sub    $0x8,%esp
  80226f:	56                   	push   %esi
  802270:	6a 00                	push   $0x0
  802272:	e8 47 ea ff ff       	call   800cbe <sys_page_unmap>
  802277:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80227a:	83 ec 08             	sub    $0x8,%esp
  80227d:	ff 75 f0             	pushl  -0x10(%ebp)
  802280:	6a 00                	push   $0x0
  802282:	e8 37 ea ff ff       	call   800cbe <sys_page_unmap>
  802287:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80228a:	83 ec 08             	sub    $0x8,%esp
  80228d:	ff 75 f4             	pushl  -0xc(%ebp)
  802290:	6a 00                	push   $0x0
  802292:	e8 27 ea ff ff       	call   800cbe <sys_page_unmap>
  802297:	83 c4 10             	add    $0x10,%esp
  80229a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80229c:	89 d0                	mov    %edx,%eax
  80229e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022a1:	5b                   	pop    %ebx
  8022a2:	5e                   	pop    %esi
  8022a3:	5d                   	pop    %ebp
  8022a4:	c3                   	ret    

008022a5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022a5:	55                   	push   %ebp
  8022a6:	89 e5                	mov    %esp,%ebp
  8022a8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ae:	50                   	push   %eax
  8022af:	ff 75 08             	pushl  0x8(%ebp)
  8022b2:	e8 d1 ee ff ff       	call   801188 <fd_lookup>
  8022b7:	83 c4 10             	add    $0x10,%esp
  8022ba:	85 c0                	test   %eax,%eax
  8022bc:	78 18                	js     8022d6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022be:	83 ec 0c             	sub    $0xc,%esp
  8022c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c4:	e8 59 ee ff ff       	call   801122 <fd2data>
	return _pipeisclosed(fd, p);
  8022c9:	89 c2                	mov    %eax,%edx
  8022cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ce:	e8 21 fd ff ff       	call   801ff4 <_pipeisclosed>
  8022d3:	83 c4 10             	add    $0x10,%esp
}
  8022d6:	c9                   	leave  
  8022d7:	c3                   	ret    

008022d8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8022d8:	55                   	push   %ebp
  8022d9:	89 e5                	mov    %esp,%ebp
  8022db:	56                   	push   %esi
  8022dc:	53                   	push   %ebx
  8022dd:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8022e0:	85 f6                	test   %esi,%esi
  8022e2:	75 16                	jne    8022fa <wait+0x22>
  8022e4:	68 2b 2f 80 00       	push   $0x802f2b
  8022e9:	68 1b 2e 80 00       	push   $0x802e1b
  8022ee:	6a 09                	push   $0x9
  8022f0:	68 36 2f 80 00       	push   $0x802f36
  8022f5:	e8 de de ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  8022fa:	89 f3                	mov    %esi,%ebx
  8022fc:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802302:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802305:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80230b:	eb 05                	jmp    802312 <wait+0x3a>
		sys_yield();
  80230d:	e8 08 e9 ff ff       	call   800c1a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802312:	8b 43 48             	mov    0x48(%ebx),%eax
  802315:	39 c6                	cmp    %eax,%esi
  802317:	75 07                	jne    802320 <wait+0x48>
  802319:	8b 43 54             	mov    0x54(%ebx),%eax
  80231c:	85 c0                	test   %eax,%eax
  80231e:	75 ed                	jne    80230d <wait+0x35>
		sys_yield();
}
  802320:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802323:	5b                   	pop    %ebx
  802324:	5e                   	pop    %esi
  802325:	5d                   	pop    %ebp
  802326:	c3                   	ret    

00802327 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802327:	55                   	push   %ebp
  802328:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80232a:	b8 00 00 00 00       	mov    $0x0,%eax
  80232f:	5d                   	pop    %ebp
  802330:	c3                   	ret    

00802331 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802331:	55                   	push   %ebp
  802332:	89 e5                	mov    %esp,%ebp
  802334:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802337:	68 41 2f 80 00       	push   $0x802f41
  80233c:	ff 75 0c             	pushl  0xc(%ebp)
  80233f:	e8 f2 e4 ff ff       	call   800836 <strcpy>
	return 0;
}
  802344:	b8 00 00 00 00       	mov    $0x0,%eax
  802349:	c9                   	leave  
  80234a:	c3                   	ret    

0080234b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80234b:	55                   	push   %ebp
  80234c:	89 e5                	mov    %esp,%ebp
  80234e:	57                   	push   %edi
  80234f:	56                   	push   %esi
  802350:	53                   	push   %ebx
  802351:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802357:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80235c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802362:	eb 2d                	jmp    802391 <devcons_write+0x46>
		m = n - tot;
  802364:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802367:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802369:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80236c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802371:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802374:	83 ec 04             	sub    $0x4,%esp
  802377:	53                   	push   %ebx
  802378:	03 45 0c             	add    0xc(%ebp),%eax
  80237b:	50                   	push   %eax
  80237c:	57                   	push   %edi
  80237d:	e8 46 e6 ff ff       	call   8009c8 <memmove>
		sys_cputs(buf, m);
  802382:	83 c4 08             	add    $0x8,%esp
  802385:	53                   	push   %ebx
  802386:	57                   	push   %edi
  802387:	e8 f1 e7 ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80238c:	01 de                	add    %ebx,%esi
  80238e:	83 c4 10             	add    $0x10,%esp
  802391:	89 f0                	mov    %esi,%eax
  802393:	3b 75 10             	cmp    0x10(%ebp),%esi
  802396:	72 cc                	jb     802364 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80239b:	5b                   	pop    %ebx
  80239c:	5e                   	pop    %esi
  80239d:	5f                   	pop    %edi
  80239e:	5d                   	pop    %ebp
  80239f:	c3                   	ret    

008023a0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023a0:	55                   	push   %ebp
  8023a1:	89 e5                	mov    %esp,%ebp
  8023a3:	83 ec 08             	sub    $0x8,%esp
  8023a6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8023ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023af:	74 2a                	je     8023db <devcons_read+0x3b>
  8023b1:	eb 05                	jmp    8023b8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023b3:	e8 62 e8 ff ff       	call   800c1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023b8:	e8 de e7 ff ff       	call   800b9b <sys_cgetc>
  8023bd:	85 c0                	test   %eax,%eax
  8023bf:	74 f2                	je     8023b3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023c1:	85 c0                	test   %eax,%eax
  8023c3:	78 16                	js     8023db <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023c5:	83 f8 04             	cmp    $0x4,%eax
  8023c8:	74 0c                	je     8023d6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8023ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023cd:	88 02                	mov    %al,(%edx)
	return 1;
  8023cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8023d4:	eb 05                	jmp    8023db <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023d6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023db:	c9                   	leave  
  8023dc:	c3                   	ret    

008023dd <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023dd:	55                   	push   %ebp
  8023de:	89 e5                	mov    %esp,%ebp
  8023e0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023e6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023e9:	6a 01                	push   $0x1
  8023eb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023ee:	50                   	push   %eax
  8023ef:	e8 89 e7 ff ff       	call   800b7d <sys_cputs>
}
  8023f4:	83 c4 10             	add    $0x10,%esp
  8023f7:	c9                   	leave  
  8023f8:	c3                   	ret    

008023f9 <getchar>:

int
getchar(void)
{
  8023f9:	55                   	push   %ebp
  8023fa:	89 e5                	mov    %esp,%ebp
  8023fc:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023ff:	6a 01                	push   $0x1
  802401:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802404:	50                   	push   %eax
  802405:	6a 00                	push   $0x0
  802407:	e8 e2 ef ff ff       	call   8013ee <read>
	if (r < 0)
  80240c:	83 c4 10             	add    $0x10,%esp
  80240f:	85 c0                	test   %eax,%eax
  802411:	78 0f                	js     802422 <getchar+0x29>
		return r;
	if (r < 1)
  802413:	85 c0                	test   %eax,%eax
  802415:	7e 06                	jle    80241d <getchar+0x24>
		return -E_EOF;
	return c;
  802417:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80241b:	eb 05                	jmp    802422 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80241d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802422:	c9                   	leave  
  802423:	c3                   	ret    

00802424 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802424:	55                   	push   %ebp
  802425:	89 e5                	mov    %esp,%ebp
  802427:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80242a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80242d:	50                   	push   %eax
  80242e:	ff 75 08             	pushl  0x8(%ebp)
  802431:	e8 52 ed ff ff       	call   801188 <fd_lookup>
  802436:	83 c4 10             	add    $0x10,%esp
  802439:	85 c0                	test   %eax,%eax
  80243b:	78 11                	js     80244e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80243d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802440:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802446:	39 10                	cmp    %edx,(%eax)
  802448:	0f 94 c0             	sete   %al
  80244b:	0f b6 c0             	movzbl %al,%eax
}
  80244e:	c9                   	leave  
  80244f:	c3                   	ret    

00802450 <opencons>:

int
opencons(void)
{
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802456:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802459:	50                   	push   %eax
  80245a:	e8 da ec ff ff       	call   801139 <fd_alloc>
  80245f:	83 c4 10             	add    $0x10,%esp
		return r;
  802462:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802464:	85 c0                	test   %eax,%eax
  802466:	78 3e                	js     8024a6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802468:	83 ec 04             	sub    $0x4,%esp
  80246b:	68 07 04 00 00       	push   $0x407
  802470:	ff 75 f4             	pushl  -0xc(%ebp)
  802473:	6a 00                	push   $0x0
  802475:	e8 bf e7 ff ff       	call   800c39 <sys_page_alloc>
  80247a:	83 c4 10             	add    $0x10,%esp
		return r;
  80247d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80247f:	85 c0                	test   %eax,%eax
  802481:	78 23                	js     8024a6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802483:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802489:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80248e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802491:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802498:	83 ec 0c             	sub    $0xc,%esp
  80249b:	50                   	push   %eax
  80249c:	e8 71 ec ff ff       	call   801112 <fd2num>
  8024a1:	89 c2                	mov    %eax,%edx
  8024a3:	83 c4 10             	add    $0x10,%esp
}
  8024a6:	89 d0                	mov    %edx,%eax
  8024a8:	c9                   	leave  
  8024a9:	c3                   	ret    

008024aa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024aa:	55                   	push   %ebp
  8024ab:	89 e5                	mov    %esp,%ebp
  8024ad:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  8024b0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8024b7:	75 2a                	jne    8024e3 <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  8024b9:	83 ec 04             	sub    $0x4,%esp
  8024bc:	6a 06                	push   $0x6
  8024be:	68 00 f0 bf ee       	push   $0xeebff000
  8024c3:	6a 00                	push   $0x0
  8024c5:	e8 6f e7 ff ff       	call   800c39 <sys_page_alloc>
			 if (a < 0)
  8024ca:	83 c4 10             	add    $0x10,%esp
  8024cd:	85 c0                	test   %eax,%eax
  8024cf:	79 12                	jns    8024e3 <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  8024d1:	50                   	push   %eax
  8024d2:	68 4d 2f 80 00       	push   $0x802f4d
  8024d7:	6a 21                	push   $0x21
  8024d9:	68 67 2f 80 00       	push   $0x802f67
  8024de:	e8 f5 dc ff ff       	call   8001d8 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  8024e3:	e8 13 e7 ff ff       	call   800bfb <sys_getenvid>
  8024e8:	83 ec 08             	sub    $0x8,%esp
  8024eb:	68 03 25 80 00       	push   $0x802503
  8024f0:	50                   	push   %eax
  8024f1:	e8 8e e8 ff ff       	call   800d84 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  8024f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f9:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8024fe:	83 c4 10             	add    $0x10,%esp
  802501:	c9                   	leave  
  802502:	c3                   	ret    

00802503 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  802503:	54                   	push   %esp
movl _pgfault_handler, %eax
  802504:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  802509:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  80250b:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  80250e:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  802512:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  802516:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  802519:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  80251d:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  80251f:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  802522:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  802523:	83 c4 04             	add    $0x4,%esp
popfl
  802526:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  802527:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  802528:	c3                   	ret    

00802529 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802529:	55                   	push   %ebp
  80252a:	89 e5                	mov    %esp,%ebp
  80252c:	56                   	push   %esi
  80252d:	53                   	push   %ebx
  80252e:	8b 75 08             	mov    0x8(%ebp),%esi
  802531:	8b 45 0c             	mov    0xc(%ebp),%eax
  802534:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  802537:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  802539:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80253e:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  802541:	83 ec 0c             	sub    $0xc,%esp
  802544:	50                   	push   %eax
  802545:	e8 9f e8 ff ff       	call   800de9 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  80254a:	83 c4 10             	add    $0x10,%esp
  80254d:	85 c0                	test   %eax,%eax
  80254f:	78 0e                	js     80255f <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  802551:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802557:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  80255a:	8b 52 78             	mov    0x78(%edx),%edx
  80255d:	eb 0a                	jmp    802569 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  80255f:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  802564:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  802569:	85 f6                	test   %esi,%esi
  80256b:	74 02                	je     80256f <ipc_recv+0x46>
			 *from_env_store = s_envid;
  80256d:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  80256f:	85 db                	test   %ebx,%ebx
  802571:	74 02                	je     802575 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  802573:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  802575:	85 c0                	test   %eax,%eax
  802577:	78 08                	js     802581 <ipc_recv+0x58>
  802579:	a1 04 40 80 00       	mov    0x804004,%eax
  80257e:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  802581:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802584:	5b                   	pop    %ebx
  802585:	5e                   	pop    %esi
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    

00802588 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802588:	55                   	push   %ebp
  802589:	89 e5                	mov    %esp,%ebp
  80258b:	57                   	push   %edi
  80258c:	56                   	push   %esi
  80258d:	53                   	push   %ebx
  80258e:	83 ec 0c             	sub    $0xc,%esp
  802591:	8b 7d 08             	mov    0x8(%ebp),%edi
  802594:	8b 75 0c             	mov    0xc(%ebp),%esi
  802597:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  80259a:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  80259c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8025a1:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  8025a4:	ff 75 14             	pushl  0x14(%ebp)
  8025a7:	53                   	push   %ebx
  8025a8:	56                   	push   %esi
  8025a9:	57                   	push   %edi
  8025aa:	e8 17 e8 ff ff       	call   800dc6 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  8025af:	83 c4 10             	add    $0x10,%esp
  8025b2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025b5:	75 07                	jne    8025be <ipc_send+0x36>
				    sys_yield();
  8025b7:	e8 5e e6 ff ff       	call   800c1a <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  8025bc:	eb e6                	jmp    8025a4 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  8025be:	85 c0                	test   %eax,%eax
  8025c0:	74 12                	je     8025d4 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  8025c2:	50                   	push   %eax
  8025c3:	68 75 2f 80 00       	push   $0x802f75
  8025c8:	6a 4b                	push   $0x4b
  8025ca:	68 89 2f 80 00       	push   $0x802f89
  8025cf:	e8 04 dc ff ff       	call   8001d8 <_panic>
			 }
	   }
}
  8025d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025d7:	5b                   	pop    %ebx
  8025d8:	5e                   	pop    %esi
  8025d9:	5f                   	pop    %edi
  8025da:	5d                   	pop    %ebp
  8025db:	c3                   	ret    

008025dc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  8025dc:	55                   	push   %ebp
  8025dd:	89 e5                	mov    %esp,%ebp
  8025df:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  8025e2:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  8025e7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025ea:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025f0:	8b 52 50             	mov    0x50(%edx),%edx
  8025f3:	39 ca                	cmp    %ecx,%edx
  8025f5:	75 0d                	jne    802604 <ipc_find_env+0x28>
				    return envs[i].env_id;
  8025f7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025fa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025ff:	8b 40 48             	mov    0x48(%eax),%eax
  802602:	eb 0f                	jmp    802613 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  802604:	83 c0 01             	add    $0x1,%eax
  802607:	3d 00 04 00 00       	cmp    $0x400,%eax
  80260c:	75 d9                	jne    8025e7 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  80260e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802613:	5d                   	pop    %ebp
  802614:	c3                   	ret    

00802615 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802615:	55                   	push   %ebp
  802616:	89 e5                	mov    %esp,%ebp
  802618:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80261b:	89 d0                	mov    %edx,%eax
  80261d:	c1 e8 16             	shr    $0x16,%eax
  802620:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802627:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80262c:	f6 c1 01             	test   $0x1,%cl
  80262f:	74 1d                	je     80264e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802631:	c1 ea 0c             	shr    $0xc,%edx
  802634:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80263b:	f6 c2 01             	test   $0x1,%dl
  80263e:	74 0e                	je     80264e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802640:	c1 ea 0c             	shr    $0xc,%edx
  802643:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80264a:	ef 
  80264b:	0f b7 c0             	movzwl %ax,%eax
}
  80264e:	5d                   	pop    %ebp
  80264f:	c3                   	ret    

00802650 <__udivdi3>:
  802650:	55                   	push   %ebp
  802651:	57                   	push   %edi
  802652:	56                   	push   %esi
  802653:	53                   	push   %ebx
  802654:	83 ec 1c             	sub    $0x1c,%esp
  802657:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80265b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80265f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802663:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802667:	85 f6                	test   %esi,%esi
  802669:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80266d:	89 ca                	mov    %ecx,%edx
  80266f:	89 f8                	mov    %edi,%eax
  802671:	75 3d                	jne    8026b0 <__udivdi3+0x60>
  802673:	39 cf                	cmp    %ecx,%edi
  802675:	0f 87 c5 00 00 00    	ja     802740 <__udivdi3+0xf0>
  80267b:	85 ff                	test   %edi,%edi
  80267d:	89 fd                	mov    %edi,%ebp
  80267f:	75 0b                	jne    80268c <__udivdi3+0x3c>
  802681:	b8 01 00 00 00       	mov    $0x1,%eax
  802686:	31 d2                	xor    %edx,%edx
  802688:	f7 f7                	div    %edi
  80268a:	89 c5                	mov    %eax,%ebp
  80268c:	89 c8                	mov    %ecx,%eax
  80268e:	31 d2                	xor    %edx,%edx
  802690:	f7 f5                	div    %ebp
  802692:	89 c1                	mov    %eax,%ecx
  802694:	89 d8                	mov    %ebx,%eax
  802696:	89 cf                	mov    %ecx,%edi
  802698:	f7 f5                	div    %ebp
  80269a:	89 c3                	mov    %eax,%ebx
  80269c:	89 d8                	mov    %ebx,%eax
  80269e:	89 fa                	mov    %edi,%edx
  8026a0:	83 c4 1c             	add    $0x1c,%esp
  8026a3:	5b                   	pop    %ebx
  8026a4:	5e                   	pop    %esi
  8026a5:	5f                   	pop    %edi
  8026a6:	5d                   	pop    %ebp
  8026a7:	c3                   	ret    
  8026a8:	90                   	nop
  8026a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	39 ce                	cmp    %ecx,%esi
  8026b2:	77 74                	ja     802728 <__udivdi3+0xd8>
  8026b4:	0f bd fe             	bsr    %esi,%edi
  8026b7:	83 f7 1f             	xor    $0x1f,%edi
  8026ba:	0f 84 98 00 00 00    	je     802758 <__udivdi3+0x108>
  8026c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026c5:	89 f9                	mov    %edi,%ecx
  8026c7:	89 c5                	mov    %eax,%ebp
  8026c9:	29 fb                	sub    %edi,%ebx
  8026cb:	d3 e6                	shl    %cl,%esi
  8026cd:	89 d9                	mov    %ebx,%ecx
  8026cf:	d3 ed                	shr    %cl,%ebp
  8026d1:	89 f9                	mov    %edi,%ecx
  8026d3:	d3 e0                	shl    %cl,%eax
  8026d5:	09 ee                	or     %ebp,%esi
  8026d7:	89 d9                	mov    %ebx,%ecx
  8026d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026dd:	89 d5                	mov    %edx,%ebp
  8026df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026e3:	d3 ed                	shr    %cl,%ebp
  8026e5:	89 f9                	mov    %edi,%ecx
  8026e7:	d3 e2                	shl    %cl,%edx
  8026e9:	89 d9                	mov    %ebx,%ecx
  8026eb:	d3 e8                	shr    %cl,%eax
  8026ed:	09 c2                	or     %eax,%edx
  8026ef:	89 d0                	mov    %edx,%eax
  8026f1:	89 ea                	mov    %ebp,%edx
  8026f3:	f7 f6                	div    %esi
  8026f5:	89 d5                	mov    %edx,%ebp
  8026f7:	89 c3                	mov    %eax,%ebx
  8026f9:	f7 64 24 0c          	mull   0xc(%esp)
  8026fd:	39 d5                	cmp    %edx,%ebp
  8026ff:	72 10                	jb     802711 <__udivdi3+0xc1>
  802701:	8b 74 24 08          	mov    0x8(%esp),%esi
  802705:	89 f9                	mov    %edi,%ecx
  802707:	d3 e6                	shl    %cl,%esi
  802709:	39 c6                	cmp    %eax,%esi
  80270b:	73 07                	jae    802714 <__udivdi3+0xc4>
  80270d:	39 d5                	cmp    %edx,%ebp
  80270f:	75 03                	jne    802714 <__udivdi3+0xc4>
  802711:	83 eb 01             	sub    $0x1,%ebx
  802714:	31 ff                	xor    %edi,%edi
  802716:	89 d8                	mov    %ebx,%eax
  802718:	89 fa                	mov    %edi,%edx
  80271a:	83 c4 1c             	add    $0x1c,%esp
  80271d:	5b                   	pop    %ebx
  80271e:	5e                   	pop    %esi
  80271f:	5f                   	pop    %edi
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    
  802722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802728:	31 ff                	xor    %edi,%edi
  80272a:	31 db                	xor    %ebx,%ebx
  80272c:	89 d8                	mov    %ebx,%eax
  80272e:	89 fa                	mov    %edi,%edx
  802730:	83 c4 1c             	add    $0x1c,%esp
  802733:	5b                   	pop    %ebx
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    
  802738:	90                   	nop
  802739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802740:	89 d8                	mov    %ebx,%eax
  802742:	f7 f7                	div    %edi
  802744:	31 ff                	xor    %edi,%edi
  802746:	89 c3                	mov    %eax,%ebx
  802748:	89 d8                	mov    %ebx,%eax
  80274a:	89 fa                	mov    %edi,%edx
  80274c:	83 c4 1c             	add    $0x1c,%esp
  80274f:	5b                   	pop    %ebx
  802750:	5e                   	pop    %esi
  802751:	5f                   	pop    %edi
  802752:	5d                   	pop    %ebp
  802753:	c3                   	ret    
  802754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802758:	39 ce                	cmp    %ecx,%esi
  80275a:	72 0c                	jb     802768 <__udivdi3+0x118>
  80275c:	31 db                	xor    %ebx,%ebx
  80275e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802762:	0f 87 34 ff ff ff    	ja     80269c <__udivdi3+0x4c>
  802768:	bb 01 00 00 00       	mov    $0x1,%ebx
  80276d:	e9 2a ff ff ff       	jmp    80269c <__udivdi3+0x4c>
  802772:	66 90                	xchg   %ax,%ax
  802774:	66 90                	xchg   %ax,%ax
  802776:	66 90                	xchg   %ax,%ax
  802778:	66 90                	xchg   %ax,%ax
  80277a:	66 90                	xchg   %ax,%ax
  80277c:	66 90                	xchg   %ax,%ax
  80277e:	66 90                	xchg   %ax,%ax

00802780 <__umoddi3>:
  802780:	55                   	push   %ebp
  802781:	57                   	push   %edi
  802782:	56                   	push   %esi
  802783:	53                   	push   %ebx
  802784:	83 ec 1c             	sub    $0x1c,%esp
  802787:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80278b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80278f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802793:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802797:	85 d2                	test   %edx,%edx
  802799:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80279d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027a1:	89 f3                	mov    %esi,%ebx
  8027a3:	89 3c 24             	mov    %edi,(%esp)
  8027a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027aa:	75 1c                	jne    8027c8 <__umoddi3+0x48>
  8027ac:	39 f7                	cmp    %esi,%edi
  8027ae:	76 50                	jbe    802800 <__umoddi3+0x80>
  8027b0:	89 c8                	mov    %ecx,%eax
  8027b2:	89 f2                	mov    %esi,%edx
  8027b4:	f7 f7                	div    %edi
  8027b6:	89 d0                	mov    %edx,%eax
  8027b8:	31 d2                	xor    %edx,%edx
  8027ba:	83 c4 1c             	add    $0x1c,%esp
  8027bd:	5b                   	pop    %ebx
  8027be:	5e                   	pop    %esi
  8027bf:	5f                   	pop    %edi
  8027c0:	5d                   	pop    %ebp
  8027c1:	c3                   	ret    
  8027c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027c8:	39 f2                	cmp    %esi,%edx
  8027ca:	89 d0                	mov    %edx,%eax
  8027cc:	77 52                	ja     802820 <__umoddi3+0xa0>
  8027ce:	0f bd ea             	bsr    %edx,%ebp
  8027d1:	83 f5 1f             	xor    $0x1f,%ebp
  8027d4:	75 5a                	jne    802830 <__umoddi3+0xb0>
  8027d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027da:	0f 82 e0 00 00 00    	jb     8028c0 <__umoddi3+0x140>
  8027e0:	39 0c 24             	cmp    %ecx,(%esp)
  8027e3:	0f 86 d7 00 00 00    	jbe    8028c0 <__umoddi3+0x140>
  8027e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027f1:	83 c4 1c             	add    $0x1c,%esp
  8027f4:	5b                   	pop    %ebx
  8027f5:	5e                   	pop    %esi
  8027f6:	5f                   	pop    %edi
  8027f7:	5d                   	pop    %ebp
  8027f8:	c3                   	ret    
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	85 ff                	test   %edi,%edi
  802802:	89 fd                	mov    %edi,%ebp
  802804:	75 0b                	jne    802811 <__umoddi3+0x91>
  802806:	b8 01 00 00 00       	mov    $0x1,%eax
  80280b:	31 d2                	xor    %edx,%edx
  80280d:	f7 f7                	div    %edi
  80280f:	89 c5                	mov    %eax,%ebp
  802811:	89 f0                	mov    %esi,%eax
  802813:	31 d2                	xor    %edx,%edx
  802815:	f7 f5                	div    %ebp
  802817:	89 c8                	mov    %ecx,%eax
  802819:	f7 f5                	div    %ebp
  80281b:	89 d0                	mov    %edx,%eax
  80281d:	eb 99                	jmp    8027b8 <__umoddi3+0x38>
  80281f:	90                   	nop
  802820:	89 c8                	mov    %ecx,%eax
  802822:	89 f2                	mov    %esi,%edx
  802824:	83 c4 1c             	add    $0x1c,%esp
  802827:	5b                   	pop    %ebx
  802828:	5e                   	pop    %esi
  802829:	5f                   	pop    %edi
  80282a:	5d                   	pop    %ebp
  80282b:	c3                   	ret    
  80282c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802830:	8b 34 24             	mov    (%esp),%esi
  802833:	bf 20 00 00 00       	mov    $0x20,%edi
  802838:	89 e9                	mov    %ebp,%ecx
  80283a:	29 ef                	sub    %ebp,%edi
  80283c:	d3 e0                	shl    %cl,%eax
  80283e:	89 f9                	mov    %edi,%ecx
  802840:	89 f2                	mov    %esi,%edx
  802842:	d3 ea                	shr    %cl,%edx
  802844:	89 e9                	mov    %ebp,%ecx
  802846:	09 c2                	or     %eax,%edx
  802848:	89 d8                	mov    %ebx,%eax
  80284a:	89 14 24             	mov    %edx,(%esp)
  80284d:	89 f2                	mov    %esi,%edx
  80284f:	d3 e2                	shl    %cl,%edx
  802851:	89 f9                	mov    %edi,%ecx
  802853:	89 54 24 04          	mov    %edx,0x4(%esp)
  802857:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80285b:	d3 e8                	shr    %cl,%eax
  80285d:	89 e9                	mov    %ebp,%ecx
  80285f:	89 c6                	mov    %eax,%esi
  802861:	d3 e3                	shl    %cl,%ebx
  802863:	89 f9                	mov    %edi,%ecx
  802865:	89 d0                	mov    %edx,%eax
  802867:	d3 e8                	shr    %cl,%eax
  802869:	89 e9                	mov    %ebp,%ecx
  80286b:	09 d8                	or     %ebx,%eax
  80286d:	89 d3                	mov    %edx,%ebx
  80286f:	89 f2                	mov    %esi,%edx
  802871:	f7 34 24             	divl   (%esp)
  802874:	89 d6                	mov    %edx,%esi
  802876:	d3 e3                	shl    %cl,%ebx
  802878:	f7 64 24 04          	mull   0x4(%esp)
  80287c:	39 d6                	cmp    %edx,%esi
  80287e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802882:	89 d1                	mov    %edx,%ecx
  802884:	89 c3                	mov    %eax,%ebx
  802886:	72 08                	jb     802890 <__umoddi3+0x110>
  802888:	75 11                	jne    80289b <__umoddi3+0x11b>
  80288a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80288e:	73 0b                	jae    80289b <__umoddi3+0x11b>
  802890:	2b 44 24 04          	sub    0x4(%esp),%eax
  802894:	1b 14 24             	sbb    (%esp),%edx
  802897:	89 d1                	mov    %edx,%ecx
  802899:	89 c3                	mov    %eax,%ebx
  80289b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80289f:	29 da                	sub    %ebx,%edx
  8028a1:	19 ce                	sbb    %ecx,%esi
  8028a3:	89 f9                	mov    %edi,%ecx
  8028a5:	89 f0                	mov    %esi,%eax
  8028a7:	d3 e0                	shl    %cl,%eax
  8028a9:	89 e9                	mov    %ebp,%ecx
  8028ab:	d3 ea                	shr    %cl,%edx
  8028ad:	89 e9                	mov    %ebp,%ecx
  8028af:	d3 ee                	shr    %cl,%esi
  8028b1:	09 d0                	or     %edx,%eax
  8028b3:	89 f2                	mov    %esi,%edx
  8028b5:	83 c4 1c             	add    $0x1c,%esp
  8028b8:	5b                   	pop    %ebx
  8028b9:	5e                   	pop    %esi
  8028ba:	5f                   	pop    %edi
  8028bb:	5d                   	pop    %ebp
  8028bc:	c3                   	ret    
  8028bd:	8d 76 00             	lea    0x0(%esi),%esi
  8028c0:	29 f9                	sub    %edi,%ecx
  8028c2:	19 d6                	sbb    %edx,%esi
  8028c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028cc:	e9 18 ff ff ff       	jmp    8027e9 <__umoddi3+0x69>
