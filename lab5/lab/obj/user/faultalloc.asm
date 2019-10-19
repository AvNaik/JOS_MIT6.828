
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 00 1f 80 00       	push   $0x801f00
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 2d 0b 00 00       	call   800b8b <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 20 1f 80 00       	push   $0x801f20
  80006f:	6a 0e                	push   $0xe
  800071:	68 0a 1f 80 00       	push   $0x801f0a
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 4c 1f 80 00       	push   $0x801f4c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 ac 06 00 00       	call   800735 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 db 0c 00 00       	call   800d7c <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 1c 1f 80 00       	push   $0x801f1c
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 1c 1f 80 00       	push   $0x801f1c
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000d5:	e8 73 0a 00 00       	call   800b4d <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 ab 0e 00 00       	call   800fc6 <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 e7 09 00 00       	call   800b0c <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 10 0a 00 00       	call   800b4d <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 78 1f 80 00       	push   $0x801f78
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 e2 23 80 00 	movl   $0x8023e2,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 2f 09 00 00       	call   800acf <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 54 01 00 00       	call   80033a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 d4 08 00 00       	call   800acf <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023e:	39 d3                	cmp    %edx,%ebx
  800240:	72 05                	jb     800247 <printnum+0x30>
  800242:	39 45 10             	cmp    %eax,0x10(%ebp)
  800245:	77 45                	ja     80028c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800253:	53                   	push   %ebx
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 f5 19 00 00       	call   801c60 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 18                	jmp    800296 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	eb 03                	jmp    80028f <printnum+0x78>
  80028c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f e8                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 e2 1a 00 00       	call   801d90 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 9b 1f 80 00 	movsbl 0x801f9b(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800306:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	3b 50 04             	cmp    0x4(%eax),%edx
  80030f:	73 0a                	jae    80031b <sprintputch+0x1b>
		*b->buf++ = ch;
  800311:	8d 4a 01             	lea    0x1(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	88 02                	mov    %al,(%edx)
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800323:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 10             	pushl  0x10(%ebp)
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	e8 05 00 00 00       	call   80033a <vprintfmt>
	va_end(ap);
}
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	57                   	push   %edi
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
  800340:	83 ec 2c             	sub    $0x2c,%esp
  800343:	8b 75 08             	mov    0x8(%ebp),%esi
  800346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800349:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034c:	eb 12                	jmp    800360 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034e:	85 c0                	test   %eax,%eax
  800350:	0f 84 89 03 00 00    	je     8006df <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	53                   	push   %ebx
  80035a:	50                   	push   %eax
  80035b:	ff d6                	call   *%esi
  80035d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800360:	83 c7 01             	add    $0x1,%edi
  800363:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800367:	83 f8 25             	cmp    $0x25,%eax
  80036a:	75 e2                	jne    80034e <vprintfmt+0x14>
  80036c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800370:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800377:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
  80038a:	eb 07                	jmp    800393 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8d 47 01             	lea    0x1(%edi),%eax
  800396:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800399:	0f b6 07             	movzbl (%edi),%eax
  80039c:	0f b6 c8             	movzbl %al,%ecx
  80039f:	83 e8 23             	sub    $0x23,%eax
  8003a2:	3c 55                	cmp    $0x55,%al
  8003a4:	0f 87 1a 03 00 00    	ja     8006c4 <vprintfmt+0x38a>
  8003aa:	0f b6 c0             	movzbl %al,%eax
  8003ad:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003bb:	eb d6                	jmp    800393 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003cf:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d5:	83 fa 09             	cmp    $0x9,%edx
  8003d8:	77 39                	ja     800413 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003da:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003dd:	eb e9                	jmp    8003c8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e8:	8b 00                	mov    (%eax),%eax
  8003ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f0:	eb 27                	jmp    800419 <vprintfmt+0xdf>
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fc:	0f 49 c8             	cmovns %eax,%ecx
  8003ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800405:	eb 8c                	jmp    800393 <vprintfmt+0x59>
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800411:	eb 80                	jmp    800393 <vprintfmt+0x59>
  800413:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800416:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800419:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041d:	0f 89 70 ff ff ff    	jns    800393 <vprintfmt+0x59>
				width = precision, precision = -1;
  800423:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800426:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800429:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800430:	e9 5e ff ff ff       	jmp    800393 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800435:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043b:	e9 53 ff ff ff       	jmp    800393 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	53                   	push   %ebx
  80044d:	ff 30                	pushl  (%eax)
  80044f:	ff d6                	call   *%esi
			break;
  800451:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800457:	e9 04 ff ff ff       	jmp    800360 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 00                	mov    (%eax),%eax
  800467:	99                   	cltd   
  800468:	31 d0                	xor    %edx,%eax
  80046a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046c:	83 f8 0f             	cmp    $0xf,%eax
  80046f:	7f 0b                	jg     80047c <vprintfmt+0x142>
  800471:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  800478:	85 d2                	test   %edx,%edx
  80047a:	75 18                	jne    800494 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80047c:	50                   	push   %eax
  80047d:	68 b3 1f 80 00       	push   $0x801fb3
  800482:	53                   	push   %ebx
  800483:	56                   	push   %esi
  800484:	e8 94 fe ff ff       	call   80031d <printfmt>
  800489:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048f:	e9 cc fe ff ff       	jmp    800360 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800494:	52                   	push   %edx
  800495:	68 9d 23 80 00       	push   $0x80239d
  80049a:	53                   	push   %ebx
  80049b:	56                   	push   %esi
  80049c:	e8 7c fe ff ff       	call   80031d <printfmt>
  8004a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a7:	e9 b4 fe ff ff       	jmp    800360 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 50 04             	lea    0x4(%eax),%edx
  8004b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	b8 ac 1f 80 00       	mov    $0x801fac,%eax
  8004be:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c5:	0f 8e 94 00 00 00    	jle    80055f <vprintfmt+0x225>
  8004cb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cf:	0f 84 98 00 00 00    	je     80056d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 d0             	pushl  -0x30(%ebp)
  8004db:	57                   	push   %edi
  8004dc:	e8 86 02 00 00       	call   800767 <strnlen>
  8004e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e4:	29 c1                	sub    %eax,%ecx
  8004e6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ec:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	eb 0f                	jmp    800509 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800501:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 ff                	test   %edi,%edi
  80050b:	7f ed                	jg     8004fa <vprintfmt+0x1c0>
  80050d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800510:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800513:	85 c9                	test   %ecx,%ecx
  800515:	b8 00 00 00 00       	mov    $0x0,%eax
  80051a:	0f 49 c1             	cmovns %ecx,%eax
  80051d:	29 c1                	sub    %eax,%ecx
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	89 cb                	mov    %ecx,%ebx
  80052a:	eb 4d                	jmp    800579 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800530:	74 1b                	je     80054d <vprintfmt+0x213>
  800532:	0f be c0             	movsbl %al,%eax
  800535:	83 e8 20             	sub    $0x20,%eax
  800538:	83 f8 5e             	cmp    $0x5e,%eax
  80053b:	76 10                	jbe    80054d <vprintfmt+0x213>
					putch('?', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	6a 3f                	push   $0x3f
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	52                   	push   %edx
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	83 eb 01             	sub    $0x1,%ebx
  80055d:	eb 1a                	jmp    800579 <vprintfmt+0x23f>
  80055f:	89 75 08             	mov    %esi,0x8(%ebp)
  800562:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800565:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	eb 0c                	jmp    800579 <vprintfmt+0x23f>
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	83 c7 01             	add    $0x1,%edi
  80057c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800580:	0f be d0             	movsbl %al,%edx
  800583:	85 d2                	test   %edx,%edx
  800585:	74 23                	je     8005aa <vprintfmt+0x270>
  800587:	85 f6                	test   %esi,%esi
  800589:	78 a1                	js     80052c <vprintfmt+0x1f2>
  80058b:	83 ee 01             	sub    $0x1,%esi
  80058e:	79 9c                	jns    80052c <vprintfmt+0x1f2>
  800590:	89 df                	mov    %ebx,%edi
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800598:	eb 18                	jmp    8005b2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 20                	push   $0x20
  8005a0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a2:	83 ef 01             	sub    $0x1,%edi
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	eb 08                	jmp    8005b2 <vprintfmt+0x278>
  8005aa:	89 df                	mov    %ebx,%edi
  8005ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8005af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	7f e4                	jg     80059a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b9:	e9 a2 fd ff ff       	jmp    800360 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005be:	83 fa 01             	cmp    $0x1,%edx
  8005c1:	7e 16                	jle    8005d9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 08             	lea    0x8(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	8b 50 04             	mov    0x4(%eax),%edx
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d7:	eb 32                	jmp    80060b <vprintfmt+0x2d1>
	else if (lflag)
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	74 18                	je     8005f5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005eb:	89 c1                	mov    %eax,%ecx
  8005ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f3:	eb 16                	jmp    80060b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	89 c1                	mov    %eax,%ecx
  800605:	c1 f9 1f             	sar    $0x1f,%ecx
  800608:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800611:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800616:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061a:	79 74                	jns    800690 <vprintfmt+0x356>
				putch('-', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 2d                	push   $0x2d
  800622:	ff d6                	call   *%esi
				num = -(long long) num;
  800624:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800627:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062a:	f7 d8                	neg    %eax
  80062c:	83 d2 00             	adc    $0x0,%edx
  80062f:	f7 da                	neg    %edx
  800631:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800639:	eb 55                	jmp    800690 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 83 fc ff ff       	call   8002c6 <getuint>
			base = 10;
  800643:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800648:	eb 46                	jmp    800690 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80064a:	8d 45 14             	lea    0x14(%ebp),%eax
  80064d:	e8 74 fc ff ff       	call   8002c6 <getuint>
			base = 8;
  800652:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800657:	eb 37                	jmp    800690 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	6a 30                	push   $0x30
  80065f:	ff d6                	call   *%esi
			putch('x', putdat);
  800661:	83 c4 08             	add    $0x8,%esp
  800664:	53                   	push   %ebx
  800665:	6a 78                	push   $0x78
  800667:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 50 04             	lea    0x4(%eax),%edx
  80066f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800672:	8b 00                	mov    (%eax),%eax
  800674:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800679:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800681:	eb 0d                	jmp    800690 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 3b fc ff ff       	call   8002c6 <getuint>
			base = 16;
  80068b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800690:	83 ec 0c             	sub    $0xc,%esp
  800693:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800697:	57                   	push   %edi
  800698:	ff 75 e0             	pushl  -0x20(%ebp)
  80069b:	51                   	push   %ecx
  80069c:	52                   	push   %edx
  80069d:	50                   	push   %eax
  80069e:	89 da                	mov    %ebx,%edx
  8006a0:	89 f0                	mov    %esi,%eax
  8006a2:	e8 70 fb ff ff       	call   800217 <printnum>
			break;
  8006a7:	83 c4 20             	add    $0x20,%esp
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ad:	e9 ae fc ff ff       	jmp    800360 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	51                   	push   %ecx
  8006b7:	ff d6                	call   *%esi
			break;
  8006b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006bf:	e9 9c fc ff ff       	jmp    800360 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	6a 25                	push   $0x25
  8006ca:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	eb 03                	jmp    8006d4 <vprintfmt+0x39a>
  8006d1:	83 ef 01             	sub    $0x1,%edi
  8006d4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d8:	75 f7                	jne    8006d1 <vprintfmt+0x397>
  8006da:	e9 81 fc ff ff       	jmp    800360 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e2:	5b                   	pop    %ebx
  8006e3:	5e                   	pop    %esi
  8006e4:	5f                   	pop    %edi
  8006e5:	5d                   	pop    %ebp
  8006e6:	c3                   	ret    

008006e7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	83 ec 18             	sub    $0x18,%esp
  8006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800704:	85 c0                	test   %eax,%eax
  800706:	74 26                	je     80072e <vsnprintf+0x47>
  800708:	85 d2                	test   %edx,%edx
  80070a:	7e 22                	jle    80072e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070c:	ff 75 14             	pushl  0x14(%ebp)
  80070f:	ff 75 10             	pushl  0x10(%ebp)
  800712:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	68 00 03 80 00       	push   $0x800300
  80071b:	e8 1a fc ff ff       	call   80033a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800720:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800723:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800726:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	eb 05                	jmp    800733 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073e:	50                   	push   %eax
  80073f:	ff 75 10             	pushl  0x10(%ebp)
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	ff 75 08             	pushl  0x8(%ebp)
  800748:	e8 9a ff ff ff       	call   8006e7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800755:	b8 00 00 00 00       	mov    $0x0,%eax
  80075a:	eb 03                	jmp    80075f <strlen+0x10>
		n++;
  80075c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800763:	75 f7                	jne    80075c <strlen+0xd>
		n++;
	return n;
}
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800770:	ba 00 00 00 00       	mov    $0x0,%edx
  800775:	eb 03                	jmp    80077a <strnlen+0x13>
		n++;
  800777:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077a:	39 c2                	cmp    %eax,%edx
  80077c:	74 08                	je     800786 <strnlen+0x1f>
  80077e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800782:	75 f3                	jne    800777 <strnlen+0x10>
  800784:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	53                   	push   %ebx
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800792:	89 c2                	mov    %eax,%edx
  800794:	83 c2 01             	add    $0x1,%edx
  800797:	83 c1 01             	add    $0x1,%ecx
  80079a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079e:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a1:	84 db                	test   %bl,%bl
  8007a3:	75 ef                	jne    800794 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a5:	5b                   	pop    %ebx
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007af:	53                   	push   %ebx
  8007b0:	e8 9a ff ff ff       	call   80074f <strlen>
  8007b5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b8:	ff 75 0c             	pushl  0xc(%ebp)
  8007bb:	01 d8                	add    %ebx,%eax
  8007bd:	50                   	push   %eax
  8007be:	e8 c5 ff ff ff       	call   800788 <strcpy>
	return dst;
}
  8007c3:	89 d8                	mov    %ebx,%eax
  8007c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	56                   	push   %esi
  8007ce:	53                   	push   %ebx
  8007cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d5:	89 f3                	mov    %esi,%ebx
  8007d7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007da:	89 f2                	mov    %esi,%edx
  8007dc:	eb 0f                	jmp    8007ed <strncpy+0x23>
		*dst++ = *src;
  8007de:	83 c2 01             	add    $0x1,%edx
  8007e1:	0f b6 01             	movzbl (%ecx),%eax
  8007e4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ea:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ed:	39 da                	cmp    %ebx,%edx
  8007ef:	75 ed                	jne    8007de <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f1:	89 f0                	mov    %esi,%eax
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	8b 55 10             	mov    0x10(%ebp),%edx
  800805:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800807:	85 d2                	test   %edx,%edx
  800809:	74 21                	je     80082c <strlcpy+0x35>
  80080b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080f:	89 f2                	mov    %esi,%edx
  800811:	eb 09                	jmp    80081c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	83 c1 01             	add    $0x1,%ecx
  800819:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80081c:	39 c2                	cmp    %eax,%edx
  80081e:	74 09                	je     800829 <strlcpy+0x32>
  800820:	0f b6 19             	movzbl (%ecx),%ebx
  800823:	84 db                	test   %bl,%bl
  800825:	75 ec                	jne    800813 <strlcpy+0x1c>
  800827:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800829:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082c:	29 f0                	sub    %esi,%eax
}
  80082e:	5b                   	pop    %ebx
  80082f:	5e                   	pop    %esi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083b:	eb 06                	jmp    800843 <strcmp+0x11>
		p++, q++;
  80083d:	83 c1 01             	add    $0x1,%ecx
  800840:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800843:	0f b6 01             	movzbl (%ecx),%eax
  800846:	84 c0                	test   %al,%al
  800848:	74 04                	je     80084e <strcmp+0x1c>
  80084a:	3a 02                	cmp    (%edx),%al
  80084c:	74 ef                	je     80083d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084e:	0f b6 c0             	movzbl %al,%eax
  800851:	0f b6 12             	movzbl (%edx),%edx
  800854:	29 d0                	sub    %edx,%eax
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	53                   	push   %ebx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	89 c3                	mov    %eax,%ebx
  800864:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800867:	eb 06                	jmp    80086f <strncmp+0x17>
		n--, p++, q++;
  800869:	83 c0 01             	add    $0x1,%eax
  80086c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086f:	39 d8                	cmp    %ebx,%eax
  800871:	74 15                	je     800888 <strncmp+0x30>
  800873:	0f b6 08             	movzbl (%eax),%ecx
  800876:	84 c9                	test   %cl,%cl
  800878:	74 04                	je     80087e <strncmp+0x26>
  80087a:	3a 0a                	cmp    (%edx),%cl
  80087c:	74 eb                	je     800869 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087e:	0f b6 00             	movzbl (%eax),%eax
  800881:	0f b6 12             	movzbl (%edx),%edx
  800884:	29 d0                	sub    %edx,%eax
  800886:	eb 05                	jmp    80088d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800888:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088d:	5b                   	pop    %ebx
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089a:	eb 07                	jmp    8008a3 <strchr+0x13>
		if (*s == c)
  80089c:	38 ca                	cmp    %cl,%dl
  80089e:	74 0f                	je     8008af <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a0:	83 c0 01             	add    $0x1,%eax
  8008a3:	0f b6 10             	movzbl (%eax),%edx
  8008a6:	84 d2                	test   %dl,%dl
  8008a8:	75 f2                	jne    80089c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bb:	eb 03                	jmp    8008c0 <strfind+0xf>
  8008bd:	83 c0 01             	add    $0x1,%eax
  8008c0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c3:	38 ca                	cmp    %cl,%dl
  8008c5:	74 04                	je     8008cb <strfind+0x1a>
  8008c7:	84 d2                	test   %dl,%dl
  8008c9:	75 f2                	jne    8008bd <strfind+0xc>
			break;
	return (char *) s;
}
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	57                   	push   %edi
  8008d1:	56                   	push   %esi
  8008d2:	53                   	push   %ebx
  8008d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d9:	85 c9                	test   %ecx,%ecx
  8008db:	74 36                	je     800913 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e3:	75 28                	jne    80090d <memset+0x40>
  8008e5:	f6 c1 03             	test   $0x3,%cl
  8008e8:	75 23                	jne    80090d <memset+0x40>
		c &= 0xFF;
  8008ea:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ee:	89 d3                	mov    %edx,%ebx
  8008f0:	c1 e3 08             	shl    $0x8,%ebx
  8008f3:	89 d6                	mov    %edx,%esi
  8008f5:	c1 e6 18             	shl    $0x18,%esi
  8008f8:	89 d0                	mov    %edx,%eax
  8008fa:	c1 e0 10             	shl    $0x10,%eax
  8008fd:	09 f0                	or     %esi,%eax
  8008ff:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800901:	89 d8                	mov    %ebx,%eax
  800903:	09 d0                	or     %edx,%eax
  800905:	c1 e9 02             	shr    $0x2,%ecx
  800908:	fc                   	cld    
  800909:	f3 ab                	rep stos %eax,%es:(%edi)
  80090b:	eb 06                	jmp    800913 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800910:	fc                   	cld    
  800911:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800913:	89 f8                	mov    %edi,%eax
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5f                   	pop    %edi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	57                   	push   %edi
  80091e:	56                   	push   %esi
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 75 0c             	mov    0xc(%ebp),%esi
  800925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800928:	39 c6                	cmp    %eax,%esi
  80092a:	73 35                	jae    800961 <memmove+0x47>
  80092c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092f:	39 d0                	cmp    %edx,%eax
  800931:	73 2e                	jae    800961 <memmove+0x47>
		s += n;
		d += n;
  800933:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800936:	89 d6                	mov    %edx,%esi
  800938:	09 fe                	or     %edi,%esi
  80093a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800940:	75 13                	jne    800955 <memmove+0x3b>
  800942:	f6 c1 03             	test   $0x3,%cl
  800945:	75 0e                	jne    800955 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800947:	83 ef 04             	sub    $0x4,%edi
  80094a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094d:	c1 e9 02             	shr    $0x2,%ecx
  800950:	fd                   	std    
  800951:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800953:	eb 09                	jmp    80095e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800955:	83 ef 01             	sub    $0x1,%edi
  800958:	8d 72 ff             	lea    -0x1(%edx),%esi
  80095b:	fd                   	std    
  80095c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095e:	fc                   	cld    
  80095f:	eb 1d                	jmp    80097e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800961:	89 f2                	mov    %esi,%edx
  800963:	09 c2                	or     %eax,%edx
  800965:	f6 c2 03             	test   $0x3,%dl
  800968:	75 0f                	jne    800979 <memmove+0x5f>
  80096a:	f6 c1 03             	test   $0x3,%cl
  80096d:	75 0a                	jne    800979 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80096f:	c1 e9 02             	shr    $0x2,%ecx
  800972:	89 c7                	mov    %eax,%edi
  800974:	fc                   	cld    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 05                	jmp    80097e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800979:	89 c7                	mov    %eax,%edi
  80097b:	fc                   	cld    
  80097c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800985:	ff 75 10             	pushl  0x10(%ebp)
  800988:	ff 75 0c             	pushl  0xc(%ebp)
  80098b:	ff 75 08             	pushl  0x8(%ebp)
  80098e:	e8 87 ff ff ff       	call   80091a <memmove>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	89 c6                	mov    %eax,%esi
  8009a2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a5:	eb 1a                	jmp    8009c1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009a7:	0f b6 08             	movzbl (%eax),%ecx
  8009aa:	0f b6 1a             	movzbl (%edx),%ebx
  8009ad:	38 d9                	cmp    %bl,%cl
  8009af:	74 0a                	je     8009bb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b1:	0f b6 c1             	movzbl %cl,%eax
  8009b4:	0f b6 db             	movzbl %bl,%ebx
  8009b7:	29 d8                	sub    %ebx,%eax
  8009b9:	eb 0f                	jmp    8009ca <memcmp+0x35>
		s1++, s2++;
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c1:	39 f0                	cmp    %esi,%eax
  8009c3:	75 e2                	jne    8009a7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	53                   	push   %ebx
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d5:	89 c1                	mov    %eax,%ecx
  8009d7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009da:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009de:	eb 0a                	jmp    8009ea <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e0:	0f b6 10             	movzbl (%eax),%edx
  8009e3:	39 da                	cmp    %ebx,%edx
  8009e5:	74 07                	je     8009ee <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e7:	83 c0 01             	add    $0x1,%eax
  8009ea:	39 c8                	cmp    %ecx,%eax
  8009ec:	72 f2                	jb     8009e0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	57                   	push   %edi
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fd:	eb 03                	jmp    800a02 <strtol+0x11>
		s++;
  8009ff:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a02:	0f b6 01             	movzbl (%ecx),%eax
  800a05:	3c 20                	cmp    $0x20,%al
  800a07:	74 f6                	je     8009ff <strtol+0xe>
  800a09:	3c 09                	cmp    $0x9,%al
  800a0b:	74 f2                	je     8009ff <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0d:	3c 2b                	cmp    $0x2b,%al
  800a0f:	75 0a                	jne    800a1b <strtol+0x2a>
		s++;
  800a11:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a14:	bf 00 00 00 00       	mov    $0x0,%edi
  800a19:	eb 11                	jmp    800a2c <strtol+0x3b>
  800a1b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a20:	3c 2d                	cmp    $0x2d,%al
  800a22:	75 08                	jne    800a2c <strtol+0x3b>
		s++, neg = 1;
  800a24:	83 c1 01             	add    $0x1,%ecx
  800a27:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a32:	75 15                	jne    800a49 <strtol+0x58>
  800a34:	80 39 30             	cmpb   $0x30,(%ecx)
  800a37:	75 10                	jne    800a49 <strtol+0x58>
  800a39:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3d:	75 7c                	jne    800abb <strtol+0xca>
		s += 2, base = 16;
  800a3f:	83 c1 02             	add    $0x2,%ecx
  800a42:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a47:	eb 16                	jmp    800a5f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a49:	85 db                	test   %ebx,%ebx
  800a4b:	75 12                	jne    800a5f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a52:	80 39 30             	cmpb   $0x30,(%ecx)
  800a55:	75 08                	jne    800a5f <strtol+0x6e>
		s++, base = 8;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a67:	0f b6 11             	movzbl (%ecx),%edx
  800a6a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 09             	cmp    $0x9,%bl
  800a72:	77 08                	ja     800a7c <strtol+0x8b>
			dig = *s - '0';
  800a74:	0f be d2             	movsbl %dl,%edx
  800a77:	83 ea 30             	sub    $0x30,%edx
  800a7a:	eb 22                	jmp    800a9e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a7c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 19             	cmp    $0x19,%bl
  800a84:	77 08                	ja     800a8e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 57             	sub    $0x57,%edx
  800a8c:	eb 10                	jmp    800a9e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a8e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	80 fb 19             	cmp    $0x19,%bl
  800a96:	77 16                	ja     800aae <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a98:	0f be d2             	movsbl %dl,%edx
  800a9b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa1:	7d 0b                	jge    800aae <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aa3:	83 c1 01             	add    $0x1,%ecx
  800aa6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aaa:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aac:	eb b9                	jmp    800a67 <strtol+0x76>

	if (endptr)
  800aae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab2:	74 0d                	je     800ac1 <strtol+0xd0>
		*endptr = (char *) s;
  800ab4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab7:	89 0e                	mov    %ecx,(%esi)
  800ab9:	eb 06                	jmp    800ac1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abb:	85 db                	test   %ebx,%ebx
  800abd:	74 98                	je     800a57 <strtol+0x66>
  800abf:	eb 9e                	jmp    800a5f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ac1:	89 c2                	mov    %eax,%edx
  800ac3:	f7 da                	neg    %edx
  800ac5:	85 ff                	test   %edi,%edi
  800ac7:	0f 45 c2             	cmovne %edx,%eax
}
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae0:	89 c3                	mov    %eax,%ebx
  800ae2:	89 c7                	mov    %eax,%edi
  800ae4:	89 c6                	mov    %eax,%esi
  800ae6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_cgetc>:

int
sys_cgetc(void)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af3:	ba 00 00 00 00       	mov    $0x0,%edx
  800af8:	b8 01 00 00 00       	mov    $0x1,%eax
  800afd:	89 d1                	mov    %edx,%ecx
  800aff:	89 d3                	mov    %edx,%ebx
  800b01:	89 d7                	mov    %edx,%edi
  800b03:	89 d6                	mov    %edx,%esi
  800b05:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b22:	89 cb                	mov    %ecx,%ebx
  800b24:	89 cf                	mov    %ecx,%edi
  800b26:	89 ce                	mov    %ecx,%esi
  800b28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	7e 17                	jle    800b45 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	50                   	push   %eax
  800b32:	6a 03                	push   $0x3
  800b34:	68 9f 22 80 00       	push   $0x80229f
  800b39:	6a 23                	push   $0x23
  800b3b:	68 bc 22 80 00       	push   $0x8022bc
  800b40:	e8 e5 f5 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5d:	89 d1                	mov    %edx,%ecx
  800b5f:	89 d3                	mov    %edx,%ebx
  800b61:	89 d7                	mov    %edx,%edi
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_yield>:

void
sys_yield(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	89 d7                	mov    %edx,%edi
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	be 00 00 00 00       	mov    $0x0,%esi
  800b99:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba7:	89 f7                	mov    %esi,%edi
  800ba9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7e 17                	jle    800bc6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 04                	push   $0x4
  800bb5:	68 9f 22 80 00       	push   $0x80229f
  800bba:	6a 23                	push   $0x23
  800bbc:	68 bc 22 80 00       	push   $0x8022bc
  800bc1:	e8 64 f5 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be8:	8b 75 18             	mov    0x18(%ebp),%esi
  800beb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7e 17                	jle    800c08 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 05                	push   $0x5
  800bf7:	68 9f 22 80 00       	push   $0x80229f
  800bfc:	6a 23                	push   $0x23
  800bfe:	68 bc 22 80 00       	push   $0x8022bc
  800c03:	e8 22 f5 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 df                	mov    %ebx,%edi
  800c2b:	89 de                	mov    %ebx,%esi
  800c2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7e 17                	jle    800c4a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	50                   	push   %eax
  800c37:	6a 06                	push   $0x6
  800c39:	68 9f 22 80 00       	push   $0x80229f
  800c3e:	6a 23                	push   $0x23
  800c40:	68 bc 22 80 00       	push   $0x8022bc
  800c45:	e8 e0 f4 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c60:	b8 08 00 00 00       	mov    $0x8,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 df                	mov    %ebx,%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7e 17                	jle    800c8c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	83 ec 0c             	sub    $0xc,%esp
  800c78:	50                   	push   %eax
  800c79:	6a 08                	push   $0x8
  800c7b:	68 9f 22 80 00       	push   $0x80229f
  800c80:	6a 23                	push   $0x23
  800c82:	68 bc 22 80 00       	push   $0x8022bc
  800c87:	e8 9e f4 ff ff       	call   80012a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 17                	jle    800cce <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 09                	push   $0x9
  800cbd:	68 9f 22 80 00       	push   $0x80229f
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 bc 22 80 00       	push   $0x8022bc
  800cc9:	e8 5c f4 ff ff       	call   80012a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	8b 55 08             	mov    0x8(%ebp),%edx
  800cef:	89 df                	mov    %ebx,%edi
  800cf1:	89 de                	mov    %ebx,%esi
  800cf3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7e 17                	jle    800d10 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	6a 0a                	push   $0xa
  800cff:	68 9f 22 80 00       	push   $0x80229f
  800d04:	6a 23                	push   $0x23
  800d06:	68 bc 22 80 00       	push   $0x8022bc
  800d0b:	e8 1a f4 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	be 00 00 00 00       	mov    $0x0,%esi
  800d23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d31:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d34:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d49:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	89 cb                	mov    %ecx,%ebx
  800d53:	89 cf                	mov    %ecx,%edi
  800d55:	89 ce                	mov    %ecx,%esi
  800d57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 17                	jle    800d74 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 0d                	push   $0xd
  800d63:	68 9f 22 80 00       	push   $0x80229f
  800d68:	6a 23                	push   $0x23
  800d6a:	68 bc 22 80 00       	push   $0x8022bc
  800d6f:	e8 b6 f3 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  800d82:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d89:	75 2a                	jne    800db5 <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  800d8b:	83 ec 04             	sub    $0x4,%esp
  800d8e:	6a 06                	push   $0x6
  800d90:	68 00 f0 bf ee       	push   $0xeebff000
  800d95:	6a 00                	push   $0x0
  800d97:	e8 ef fd ff ff       	call   800b8b <sys_page_alloc>
			 if (a < 0)
  800d9c:	83 c4 10             	add    $0x10,%esp
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	79 12                	jns    800db5 <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  800da3:	50                   	push   %eax
  800da4:	68 ca 22 80 00       	push   $0x8022ca
  800da9:	6a 21                	push   $0x21
  800dab:	68 e4 22 80 00       	push   $0x8022e4
  800db0:	e8 75 f3 ff ff       	call   80012a <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  800db5:	e8 93 fd ff ff       	call   800b4d <sys_getenvid>
  800dba:	83 ec 08             	sub    $0x8,%esp
  800dbd:	68 d5 0d 80 00       	push   $0x800dd5
  800dc2:	50                   	push   %eax
  800dc3:	e8 0e ff ff ff       	call   800cd6 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  800dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcb:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800dd0:	83 c4 10             	add    $0x10,%esp
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    

00800dd5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  800dd5:	54                   	push   %esp
movl _pgfault_handler, %eax
  800dd6:	a1 08 40 80 00       	mov    0x804008,%eax
call *%eax
  800ddb:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  800ddd:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  800de0:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  800de4:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  800de8:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  800deb:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  800def:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  800df1:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  800df4:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  800df5:	83 c4 04             	add    $0x4,%esp
popfl
  800df8:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  800df9:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  800dfa:	c3                   	ret    

00800dfb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	05 00 00 00 30       	add    $0x30000000,%eax
  800e06:	c1 e8 0c             	shr    $0xc,%eax
}
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	05 00 00 00 30       	add    $0x30000000,%eax
  800e16:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e1b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e28:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e2d:	89 c2                	mov    %eax,%edx
  800e2f:	c1 ea 16             	shr    $0x16,%edx
  800e32:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e39:	f6 c2 01             	test   $0x1,%dl
  800e3c:	74 11                	je     800e4f <fd_alloc+0x2d>
  800e3e:	89 c2                	mov    %eax,%edx
  800e40:	c1 ea 0c             	shr    $0xc,%edx
  800e43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4a:	f6 c2 01             	test   $0x1,%dl
  800e4d:	75 09                	jne    800e58 <fd_alloc+0x36>
			*fd_store = fd;
  800e4f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e51:	b8 00 00 00 00       	mov    $0x0,%eax
  800e56:	eb 17                	jmp    800e6f <fd_alloc+0x4d>
  800e58:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e5d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e62:	75 c9                	jne    800e2d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e64:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e6a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e77:	83 f8 1f             	cmp    $0x1f,%eax
  800e7a:	77 36                	ja     800eb2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e7c:	c1 e0 0c             	shl    $0xc,%eax
  800e7f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e84:	89 c2                	mov    %eax,%edx
  800e86:	c1 ea 16             	shr    $0x16,%edx
  800e89:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e90:	f6 c2 01             	test   $0x1,%dl
  800e93:	74 24                	je     800eb9 <fd_lookup+0x48>
  800e95:	89 c2                	mov    %eax,%edx
  800e97:	c1 ea 0c             	shr    $0xc,%edx
  800e9a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea1:	f6 c2 01             	test   $0x1,%dl
  800ea4:	74 1a                	je     800ec0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ea6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea9:	89 02                	mov    %eax,(%edx)
	return 0;
  800eab:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb0:	eb 13                	jmp    800ec5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb7:	eb 0c                	jmp    800ec5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebe:	eb 05                	jmp    800ec5 <fd_lookup+0x54>
  800ec0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 08             	sub    $0x8,%esp
  800ecd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed0:	ba 74 23 80 00       	mov    $0x802374,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ed5:	eb 13                	jmp    800eea <dev_lookup+0x23>
  800ed7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eda:	39 08                	cmp    %ecx,(%eax)
  800edc:	75 0c                	jne    800eea <dev_lookup+0x23>
			*dev = devtab[i];
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	eb 2e                	jmp    800f18 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eea:	8b 02                	mov    (%edx),%eax
  800eec:	85 c0                	test   %eax,%eax
  800eee:	75 e7                	jne    800ed7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef0:	a1 04 40 80 00       	mov    0x804004,%eax
  800ef5:	8b 40 48             	mov    0x48(%eax),%eax
  800ef8:	83 ec 04             	sub    $0x4,%esp
  800efb:	51                   	push   %ecx
  800efc:	50                   	push   %eax
  800efd:	68 f4 22 80 00       	push   $0x8022f4
  800f02:	e8 fc f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800f07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f10:	83 c4 10             	add    $0x10,%esp
  800f13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	56                   	push   %esi
  800f1e:	53                   	push   %ebx
  800f1f:	83 ec 10             	sub    $0x10,%esp
  800f22:	8b 75 08             	mov    0x8(%ebp),%esi
  800f25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2b:	50                   	push   %eax
  800f2c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f32:	c1 e8 0c             	shr    $0xc,%eax
  800f35:	50                   	push   %eax
  800f36:	e8 36 ff ff ff       	call   800e71 <fd_lookup>
  800f3b:	83 c4 08             	add    $0x8,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	78 05                	js     800f47 <fd_close+0x2d>
	    || fd != fd2)
  800f42:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f45:	74 0c                	je     800f53 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f47:	84 db                	test   %bl,%bl
  800f49:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4e:	0f 44 c2             	cmove  %edx,%eax
  800f51:	eb 41                	jmp    800f94 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f59:	50                   	push   %eax
  800f5a:	ff 36                	pushl  (%esi)
  800f5c:	e8 66 ff ff ff       	call   800ec7 <dev_lookup>
  800f61:	89 c3                	mov    %eax,%ebx
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 1a                	js     800f84 <fd_close+0x6a>
		if (dev->dev_close)
  800f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f6d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f70:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f75:	85 c0                	test   %eax,%eax
  800f77:	74 0b                	je     800f84 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f79:	83 ec 0c             	sub    $0xc,%esp
  800f7c:	56                   	push   %esi
  800f7d:	ff d0                	call   *%eax
  800f7f:	89 c3                	mov    %eax,%ebx
  800f81:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f84:	83 ec 08             	sub    $0x8,%esp
  800f87:	56                   	push   %esi
  800f88:	6a 00                	push   $0x0
  800f8a:	e8 81 fc ff ff       	call   800c10 <sys_page_unmap>
	return r;
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	89 d8                	mov    %ebx,%eax
}
  800f94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa4:	50                   	push   %eax
  800fa5:	ff 75 08             	pushl  0x8(%ebp)
  800fa8:	e8 c4 fe ff ff       	call   800e71 <fd_lookup>
  800fad:	83 c4 08             	add    $0x8,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	78 10                	js     800fc4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fb4:	83 ec 08             	sub    $0x8,%esp
  800fb7:	6a 01                	push   $0x1
  800fb9:	ff 75 f4             	pushl  -0xc(%ebp)
  800fbc:	e8 59 ff ff ff       	call   800f1a <fd_close>
  800fc1:	83 c4 10             	add    $0x10,%esp
}
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <close_all>:

void
close_all(void)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	53                   	push   %ebx
  800fca:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fcd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fd2:	83 ec 0c             	sub    $0xc,%esp
  800fd5:	53                   	push   %ebx
  800fd6:	e8 c0 ff ff ff       	call   800f9b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fdb:	83 c3 01             	add    $0x1,%ebx
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	83 fb 20             	cmp    $0x20,%ebx
  800fe4:	75 ec                	jne    800fd2 <close_all+0xc>
		close(i);
}
  800fe6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	57                   	push   %edi
  800fef:	56                   	push   %esi
  800ff0:	53                   	push   %ebx
  800ff1:	83 ec 2c             	sub    $0x2c,%esp
  800ff4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ff7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ffa:	50                   	push   %eax
  800ffb:	ff 75 08             	pushl  0x8(%ebp)
  800ffe:	e8 6e fe ff ff       	call   800e71 <fd_lookup>
  801003:	83 c4 08             	add    $0x8,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	0f 88 c1 00 00 00    	js     8010cf <dup+0xe4>
		return r;
	close(newfdnum);
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	56                   	push   %esi
  801012:	e8 84 ff ff ff       	call   800f9b <close>

	newfd = INDEX2FD(newfdnum);
  801017:	89 f3                	mov    %esi,%ebx
  801019:	c1 e3 0c             	shl    $0xc,%ebx
  80101c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801022:	83 c4 04             	add    $0x4,%esp
  801025:	ff 75 e4             	pushl  -0x1c(%ebp)
  801028:	e8 de fd ff ff       	call   800e0b <fd2data>
  80102d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80102f:	89 1c 24             	mov    %ebx,(%esp)
  801032:	e8 d4 fd ff ff       	call   800e0b <fd2data>
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80103d:	89 f8                	mov    %edi,%eax
  80103f:	c1 e8 16             	shr    $0x16,%eax
  801042:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801049:	a8 01                	test   $0x1,%al
  80104b:	74 37                	je     801084 <dup+0x99>
  80104d:	89 f8                	mov    %edi,%eax
  80104f:	c1 e8 0c             	shr    $0xc,%eax
  801052:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801059:	f6 c2 01             	test   $0x1,%dl
  80105c:	74 26                	je     801084 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80105e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801065:	83 ec 0c             	sub    $0xc,%esp
  801068:	25 07 0e 00 00       	and    $0xe07,%eax
  80106d:	50                   	push   %eax
  80106e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801071:	6a 00                	push   $0x0
  801073:	57                   	push   %edi
  801074:	6a 00                	push   $0x0
  801076:	e8 53 fb ff ff       	call   800bce <sys_page_map>
  80107b:	89 c7                	mov    %eax,%edi
  80107d:	83 c4 20             	add    $0x20,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	78 2e                	js     8010b2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801084:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801087:	89 d0                	mov    %edx,%eax
  801089:	c1 e8 0c             	shr    $0xc,%eax
  80108c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	25 07 0e 00 00       	and    $0xe07,%eax
  80109b:	50                   	push   %eax
  80109c:	53                   	push   %ebx
  80109d:	6a 00                	push   $0x0
  80109f:	52                   	push   %edx
  8010a0:	6a 00                	push   $0x0
  8010a2:	e8 27 fb ff ff       	call   800bce <sys_page_map>
  8010a7:	89 c7                	mov    %eax,%edi
  8010a9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010ac:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ae:	85 ff                	test   %edi,%edi
  8010b0:	79 1d                	jns    8010cf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010b2:	83 ec 08             	sub    $0x8,%esp
  8010b5:	53                   	push   %ebx
  8010b6:	6a 00                	push   $0x0
  8010b8:	e8 53 fb ff ff       	call   800c10 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010bd:	83 c4 08             	add    $0x8,%esp
  8010c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c3:	6a 00                	push   $0x0
  8010c5:	e8 46 fb ff ff       	call   800c10 <sys_page_unmap>
	return r;
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	89 f8                	mov    %edi,%eax
}
  8010cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d2:	5b                   	pop    %ebx
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	53                   	push   %ebx
  8010db:	83 ec 14             	sub    $0x14,%esp
  8010de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e4:	50                   	push   %eax
  8010e5:	53                   	push   %ebx
  8010e6:	e8 86 fd ff ff       	call   800e71 <fd_lookup>
  8010eb:	83 c4 08             	add    $0x8,%esp
  8010ee:	89 c2                	mov    %eax,%edx
  8010f0:	85 c0                	test   %eax,%eax
  8010f2:	78 6d                	js     801161 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f4:	83 ec 08             	sub    $0x8,%esp
  8010f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fa:	50                   	push   %eax
  8010fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010fe:	ff 30                	pushl  (%eax)
  801100:	e8 c2 fd ff ff       	call   800ec7 <dev_lookup>
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 4c                	js     801158 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80110c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80110f:	8b 42 08             	mov    0x8(%edx),%eax
  801112:	83 e0 03             	and    $0x3,%eax
  801115:	83 f8 01             	cmp    $0x1,%eax
  801118:	75 21                	jne    80113b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80111a:	a1 04 40 80 00       	mov    0x804004,%eax
  80111f:	8b 40 48             	mov    0x48(%eax),%eax
  801122:	83 ec 04             	sub    $0x4,%esp
  801125:	53                   	push   %ebx
  801126:	50                   	push   %eax
  801127:	68 38 23 80 00       	push   $0x802338
  80112c:	e8 d2 f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801139:	eb 26                	jmp    801161 <read+0x8a>
	}
	if (!dev->dev_read)
  80113b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113e:	8b 40 08             	mov    0x8(%eax),%eax
  801141:	85 c0                	test   %eax,%eax
  801143:	74 17                	je     80115c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	ff 75 10             	pushl  0x10(%ebp)
  80114b:	ff 75 0c             	pushl  0xc(%ebp)
  80114e:	52                   	push   %edx
  80114f:	ff d0                	call   *%eax
  801151:	89 c2                	mov    %eax,%edx
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	eb 09                	jmp    801161 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801158:	89 c2                	mov    %eax,%edx
  80115a:	eb 05                	jmp    801161 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80115c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801161:	89 d0                	mov    %edx,%eax
  801163:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801166:	c9                   	leave  
  801167:	c3                   	ret    

00801168 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	57                   	push   %edi
  80116c:	56                   	push   %esi
  80116d:	53                   	push   %ebx
  80116e:	83 ec 0c             	sub    $0xc,%esp
  801171:	8b 7d 08             	mov    0x8(%ebp),%edi
  801174:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801177:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117c:	eb 21                	jmp    80119f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80117e:	83 ec 04             	sub    $0x4,%esp
  801181:	89 f0                	mov    %esi,%eax
  801183:	29 d8                	sub    %ebx,%eax
  801185:	50                   	push   %eax
  801186:	89 d8                	mov    %ebx,%eax
  801188:	03 45 0c             	add    0xc(%ebp),%eax
  80118b:	50                   	push   %eax
  80118c:	57                   	push   %edi
  80118d:	e8 45 ff ff ff       	call   8010d7 <read>
		if (m < 0)
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	78 10                	js     8011a9 <readn+0x41>
			return m;
		if (m == 0)
  801199:	85 c0                	test   %eax,%eax
  80119b:	74 0a                	je     8011a7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80119d:	01 c3                	add    %eax,%ebx
  80119f:	39 f3                	cmp    %esi,%ebx
  8011a1:	72 db                	jb     80117e <readn+0x16>
  8011a3:	89 d8                	mov    %ebx,%eax
  8011a5:	eb 02                	jmp    8011a9 <readn+0x41>
  8011a7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5e                   	pop    %esi
  8011ae:	5f                   	pop    %edi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 14             	sub    $0x14,%esp
  8011b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011be:	50                   	push   %eax
  8011bf:	53                   	push   %ebx
  8011c0:	e8 ac fc ff ff       	call   800e71 <fd_lookup>
  8011c5:	83 c4 08             	add    $0x8,%esp
  8011c8:	89 c2                	mov    %eax,%edx
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 68                	js     801236 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d8:	ff 30                	pushl  (%eax)
  8011da:	e8 e8 fc ff ff       	call   800ec7 <dev_lookup>
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	78 47                	js     80122d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ed:	75 21                	jne    801210 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f4:	8b 40 48             	mov    0x48(%eax),%eax
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	53                   	push   %ebx
  8011fb:	50                   	push   %eax
  8011fc:	68 54 23 80 00       	push   $0x802354
  801201:	e8 fd ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80120e:	eb 26                	jmp    801236 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801210:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801213:	8b 52 0c             	mov    0xc(%edx),%edx
  801216:	85 d2                	test   %edx,%edx
  801218:	74 17                	je     801231 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80121a:	83 ec 04             	sub    $0x4,%esp
  80121d:	ff 75 10             	pushl  0x10(%ebp)
  801220:	ff 75 0c             	pushl  0xc(%ebp)
  801223:	50                   	push   %eax
  801224:	ff d2                	call   *%edx
  801226:	89 c2                	mov    %eax,%edx
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	eb 09                	jmp    801236 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	eb 05                	jmp    801236 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801231:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801236:	89 d0                	mov    %edx,%eax
  801238:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123b:	c9                   	leave  
  80123c:	c3                   	ret    

0080123d <seek>:

int
seek(int fdnum, off_t offset)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801243:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	ff 75 08             	pushl  0x8(%ebp)
  80124a:	e8 22 fc ff ff       	call   800e71 <fd_lookup>
  80124f:	83 c4 08             	add    $0x8,%esp
  801252:	85 c0                	test   %eax,%eax
  801254:	78 0e                	js     801264 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801256:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801259:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80125f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801264:	c9                   	leave  
  801265:	c3                   	ret    

00801266 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	53                   	push   %ebx
  80126a:	83 ec 14             	sub    $0x14,%esp
  80126d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801270:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801273:	50                   	push   %eax
  801274:	53                   	push   %ebx
  801275:	e8 f7 fb ff ff       	call   800e71 <fd_lookup>
  80127a:	83 c4 08             	add    $0x8,%esp
  80127d:	89 c2                	mov    %eax,%edx
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 65                	js     8012e8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	ff 30                	pushl  (%eax)
  80128f:	e8 33 fc ff ff       	call   800ec7 <dev_lookup>
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 44                	js     8012df <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a2:	75 21                	jne    8012c5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012a4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012a9:	8b 40 48             	mov    0x48(%eax),%eax
  8012ac:	83 ec 04             	sub    $0x4,%esp
  8012af:	53                   	push   %ebx
  8012b0:	50                   	push   %eax
  8012b1:	68 14 23 80 00       	push   $0x802314
  8012b6:	e8 48 ef ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c3:	eb 23                	jmp    8012e8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c8:	8b 52 18             	mov    0x18(%edx),%edx
  8012cb:	85 d2                	test   %edx,%edx
  8012cd:	74 14                	je     8012e3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012cf:	83 ec 08             	sub    $0x8,%esp
  8012d2:	ff 75 0c             	pushl  0xc(%ebp)
  8012d5:	50                   	push   %eax
  8012d6:	ff d2                	call   *%edx
  8012d8:	89 c2                	mov    %eax,%edx
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	eb 09                	jmp    8012e8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	eb 05                	jmp    8012e8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012e8:	89 d0                	mov    %edx,%eax
  8012ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ed:	c9                   	leave  
  8012ee:	c3                   	ret    

008012ef <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	53                   	push   %ebx
  8012f3:	83 ec 14             	sub    $0x14,%esp
  8012f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fc:	50                   	push   %eax
  8012fd:	ff 75 08             	pushl  0x8(%ebp)
  801300:	e8 6c fb ff ff       	call   800e71 <fd_lookup>
  801305:	83 c4 08             	add    $0x8,%esp
  801308:	89 c2                	mov    %eax,%edx
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 58                	js     801366 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801318:	ff 30                	pushl  (%eax)
  80131a:	e8 a8 fb ff ff       	call   800ec7 <dev_lookup>
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	78 37                	js     80135d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801326:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801329:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80132d:	74 32                	je     801361 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80132f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801332:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801339:	00 00 00 
	stat->st_isdir = 0;
  80133c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801343:	00 00 00 
	stat->st_dev = dev;
  801346:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80134c:	83 ec 08             	sub    $0x8,%esp
  80134f:	53                   	push   %ebx
  801350:	ff 75 f0             	pushl  -0x10(%ebp)
  801353:	ff 50 14             	call   *0x14(%eax)
  801356:	89 c2                	mov    %eax,%edx
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	eb 09                	jmp    801366 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135d:	89 c2                	mov    %eax,%edx
  80135f:	eb 05                	jmp    801366 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801361:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801366:	89 d0                	mov    %edx,%eax
  801368:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	56                   	push   %esi
  801371:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	6a 00                	push   $0x0
  801377:	ff 75 08             	pushl  0x8(%ebp)
  80137a:	e8 2c 02 00 00       	call   8015ab <open>
  80137f:	89 c3                	mov    %eax,%ebx
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	78 1b                	js     8013a3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	ff 75 0c             	pushl  0xc(%ebp)
  80138e:	50                   	push   %eax
  80138f:	e8 5b ff ff ff       	call   8012ef <fstat>
  801394:	89 c6                	mov    %eax,%esi
	close(fd);
  801396:	89 1c 24             	mov    %ebx,(%esp)
  801399:	e8 fd fb ff ff       	call   800f9b <close>
	return r;
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	89 f0                	mov    %esi,%eax
}
  8013a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a6:	5b                   	pop    %ebx
  8013a7:	5e                   	pop    %esi
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    

008013aa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	56                   	push   %esi
  8013ae:	53                   	push   %ebx
  8013af:	89 c6                	mov    %eax,%esi
  8013b1:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  8013b3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ba:	75 12                	jne    8013ce <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  8013bc:	83 ec 0c             	sub    $0xc,%esp
  8013bf:	6a 01                	push   $0x1
  8013c1:	e8 1b 08 00 00       	call   801be1 <ipc_find_env>
  8013c6:	a3 00 40 80 00       	mov    %eax,0x804000
  8013cb:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ce:	6a 07                	push   $0x7
  8013d0:	68 00 50 80 00       	push   $0x805000
  8013d5:	56                   	push   %esi
  8013d6:	ff 35 00 40 80 00    	pushl  0x804000
  8013dc:	e8 ac 07 00 00       	call   801b8d <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  8013e1:	83 c4 0c             	add    $0xc,%esp
  8013e4:	6a 00                	push   $0x0
  8013e6:	53                   	push   %ebx
  8013e7:	6a 00                	push   $0x0
  8013e9:	e8 40 07 00 00       	call   801b2e <ipc_recv>
}
  8013ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f1:	5b                   	pop    %ebx
  8013f2:	5e                   	pop    %esi
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801401:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  801406:	8b 45 0c             	mov    0xc(%ebp),%eax
  801409:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80140e:	ba 00 00 00 00       	mov    $0x0,%edx
  801413:	b8 02 00 00 00       	mov    $0x2,%eax
  801418:	e8 8d ff ff ff       	call   8013aa <fsipc>
}
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801425:	8b 45 08             	mov    0x8(%ebp),%eax
  801428:	8b 40 0c             	mov    0xc(%eax),%eax
  80142b:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  801430:	ba 00 00 00 00       	mov    $0x0,%edx
  801435:	b8 06 00 00 00       	mov    $0x6,%eax
  80143a:	e8 6b ff ff ff       	call   8013aa <fsipc>
}
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	53                   	push   %ebx
  801445:	83 ec 04             	sub    $0x4,%esp
  801448:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80144b:	8b 45 08             	mov    0x8(%ebp),%eax
  80144e:	8b 40 0c             	mov    0xc(%eax),%eax
  801451:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801456:	ba 00 00 00 00       	mov    $0x0,%edx
  80145b:	b8 05 00 00 00       	mov    $0x5,%eax
  801460:	e8 45 ff ff ff       	call   8013aa <fsipc>
  801465:	85 c0                	test   %eax,%eax
  801467:	78 2c                	js     801495 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801469:	83 ec 08             	sub    $0x8,%esp
  80146c:	68 00 50 80 00       	push   $0x805000
  801471:	53                   	push   %ebx
  801472:	e8 11 f3 ff ff       	call   800788 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  801477:	a1 80 50 80 00       	mov    0x805080,%eax
  80147c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801482:	a1 84 50 80 00       	mov    0x805084,%eax
  801487:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801495:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	53                   	push   %ebx
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014aa:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  8014af:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  8014b5:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8014bb:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8014c0:	0f 46 c3             	cmovbe %ebx,%eax
  8014c3:	50                   	push   %eax
  8014c4:	ff 75 0c             	pushl  0xc(%ebp)
  8014c7:	68 08 50 80 00       	push   $0x805008
  8014cc:	e8 49 f4 ff ff       	call   80091a <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  8014d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d6:	b8 04 00 00 00       	mov    $0x4,%eax
  8014db:	e8 ca fe ff ff       	call   8013aa <fsipc>
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 3d                	js     801524 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  8014e7:	39 c3                	cmp    %eax,%ebx
  8014e9:	73 19                	jae    801504 <devfile_write+0x6a>
  8014eb:	68 84 23 80 00       	push   $0x802384
  8014f0:	68 8b 23 80 00       	push   $0x80238b
  8014f5:	68 9a 00 00 00       	push   $0x9a
  8014fa:	68 a0 23 80 00       	push   $0x8023a0
  8014ff:	e8 26 ec ff ff       	call   80012a <_panic>
	   assert (r <= bytes_written);
  801504:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801509:	7e 19                	jle    801524 <devfile_write+0x8a>
  80150b:	68 ab 23 80 00       	push   $0x8023ab
  801510:	68 8b 23 80 00       	push   $0x80238b
  801515:	68 9b 00 00 00       	push   $0x9b
  80151a:	68 a0 23 80 00       	push   $0x8023a0
  80151f:	e8 06 ec ff ff       	call   80012a <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801524:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801527:	c9                   	leave  
  801528:	c3                   	ret    

00801529 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	56                   	push   %esi
  80152d:	53                   	push   %ebx
  80152e:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  801531:	8b 45 08             	mov    0x8(%ebp),%eax
  801534:	8b 40 0c             	mov    0xc(%eax),%eax
  801537:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  80153c:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801542:	ba 00 00 00 00       	mov    $0x0,%edx
  801547:	b8 03 00 00 00       	mov    $0x3,%eax
  80154c:	e8 59 fe ff ff       	call   8013aa <fsipc>
  801551:	89 c3                	mov    %eax,%ebx
  801553:	85 c0                	test   %eax,%eax
  801555:	78 4b                	js     8015a2 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  801557:	39 c6                	cmp    %eax,%esi
  801559:	73 16                	jae    801571 <devfile_read+0x48>
  80155b:	68 84 23 80 00       	push   $0x802384
  801560:	68 8b 23 80 00       	push   $0x80238b
  801565:	6a 7c                	push   $0x7c
  801567:	68 a0 23 80 00       	push   $0x8023a0
  80156c:	e8 b9 eb ff ff       	call   80012a <_panic>
	   assert(r <= PGSIZE);
  801571:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801576:	7e 16                	jle    80158e <devfile_read+0x65>
  801578:	68 be 23 80 00       	push   $0x8023be
  80157d:	68 8b 23 80 00       	push   $0x80238b
  801582:	6a 7d                	push   $0x7d
  801584:	68 a0 23 80 00       	push   $0x8023a0
  801589:	e8 9c eb ff ff       	call   80012a <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80158e:	83 ec 04             	sub    $0x4,%esp
  801591:	50                   	push   %eax
  801592:	68 00 50 80 00       	push   $0x805000
  801597:	ff 75 0c             	pushl  0xc(%ebp)
  80159a:	e8 7b f3 ff ff       	call   80091a <memmove>
	   return r;
  80159f:	83 c4 10             	add    $0x10,%esp
}
  8015a2:	89 d8                	mov    %ebx,%eax
  8015a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a7:	5b                   	pop    %ebx
  8015a8:	5e                   	pop    %esi
  8015a9:	5d                   	pop    %ebp
  8015aa:	c3                   	ret    

008015ab <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	53                   	push   %ebx
  8015af:	83 ec 20             	sub    $0x20,%esp
  8015b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  8015b5:	53                   	push   %ebx
  8015b6:	e8 94 f1 ff ff       	call   80074f <strlen>
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015c3:	7f 67                	jg     80162c <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8015c5:	83 ec 0c             	sub    $0xc,%esp
  8015c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	e8 51 f8 ff ff       	call   800e22 <fd_alloc>
  8015d1:	83 c4 10             	add    $0x10,%esp
			 return r;
  8015d4:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 57                	js     801631 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	53                   	push   %ebx
  8015de:	68 00 50 80 00       	push   $0x805000
  8015e3:	e8 a0 f1 ff ff       	call   800788 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  8015e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015eb:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f8:	e8 ad fd ff ff       	call   8013aa <fsipc>
  8015fd:	89 c3                	mov    %eax,%ebx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	79 14                	jns    80161a <open+0x6f>
			 fd_close(fd, 0);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	6a 00                	push   $0x0
  80160b:	ff 75 f4             	pushl  -0xc(%ebp)
  80160e:	e8 07 f9 ff ff       	call   800f1a <fd_close>
			 return r;
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	89 da                	mov    %ebx,%edx
  801618:	eb 17                	jmp    801631 <open+0x86>
	   }

	   return fd2num(fd);
  80161a:	83 ec 0c             	sub    $0xc,%esp
  80161d:	ff 75 f4             	pushl  -0xc(%ebp)
  801620:	e8 d6 f7 ff ff       	call   800dfb <fd2num>
  801625:	89 c2                	mov    %eax,%edx
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	eb 05                	jmp    801631 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  80162c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801631:	89 d0                	mov    %edx,%eax
  801633:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  80163e:	ba 00 00 00 00       	mov    $0x0,%edx
  801643:	b8 08 00 00 00       	mov    $0x8,%eax
  801648:	e8 5d fd ff ff       	call   8013aa <fsipc>
}
  80164d:	c9                   	leave  
  80164e:	c3                   	ret    

0080164f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	56                   	push   %esi
  801653:	53                   	push   %ebx
  801654:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801657:	83 ec 0c             	sub    $0xc,%esp
  80165a:	ff 75 08             	pushl  0x8(%ebp)
  80165d:	e8 a9 f7 ff ff       	call   800e0b <fd2data>
  801662:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801664:	83 c4 08             	add    $0x8,%esp
  801667:	68 ca 23 80 00       	push   $0x8023ca
  80166c:	53                   	push   %ebx
  80166d:	e8 16 f1 ff ff       	call   800788 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801672:	8b 46 04             	mov    0x4(%esi),%eax
  801675:	2b 06                	sub    (%esi),%eax
  801677:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80167d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801684:	00 00 00 
	stat->st_dev = &devpipe;
  801687:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80168e:	30 80 00 
	return 0;
}
  801691:	b8 00 00 00 00       	mov    $0x0,%eax
  801696:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    

0080169d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	53                   	push   %ebx
  8016a1:	83 ec 0c             	sub    $0xc,%esp
  8016a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016a7:	53                   	push   %ebx
  8016a8:	6a 00                	push   $0x0
  8016aa:	e8 61 f5 ff ff       	call   800c10 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016af:	89 1c 24             	mov    %ebx,(%esp)
  8016b2:	e8 54 f7 ff ff       	call   800e0b <fd2data>
  8016b7:	83 c4 08             	add    $0x8,%esp
  8016ba:	50                   	push   %eax
  8016bb:	6a 00                	push   $0x0
  8016bd:	e8 4e f5 ff ff       	call   800c10 <sys_page_unmap>
}
  8016c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	57                   	push   %edi
  8016cb:	56                   	push   %esi
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 1c             	sub    $0x1c,%esp
  8016d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016d3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8016da:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016dd:	83 ec 0c             	sub    $0xc,%esp
  8016e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8016e3:	e8 32 05 00 00       	call   801c1a <pageref>
  8016e8:	89 c3                	mov    %eax,%ebx
  8016ea:	89 3c 24             	mov    %edi,(%esp)
  8016ed:	e8 28 05 00 00       	call   801c1a <pageref>
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	39 c3                	cmp    %eax,%ebx
  8016f7:	0f 94 c1             	sete   %cl
  8016fa:	0f b6 c9             	movzbl %cl,%ecx
  8016fd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801700:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801706:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801709:	39 ce                	cmp    %ecx,%esi
  80170b:	74 1b                	je     801728 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80170d:	39 c3                	cmp    %eax,%ebx
  80170f:	75 c4                	jne    8016d5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801711:	8b 42 58             	mov    0x58(%edx),%eax
  801714:	ff 75 e4             	pushl  -0x1c(%ebp)
  801717:	50                   	push   %eax
  801718:	56                   	push   %esi
  801719:	68 d1 23 80 00       	push   $0x8023d1
  80171e:	e8 e0 ea ff ff       	call   800203 <cprintf>
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	eb ad                	jmp    8016d5 <_pipeisclosed+0xe>
	}
}
  801728:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80172b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5e                   	pop    %esi
  801730:	5f                   	pop    %edi
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	57                   	push   %edi
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
  801739:	83 ec 28             	sub    $0x28,%esp
  80173c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80173f:	56                   	push   %esi
  801740:	e8 c6 f6 ff ff       	call   800e0b <fd2data>
  801745:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	bf 00 00 00 00       	mov    $0x0,%edi
  80174f:	eb 4b                	jmp    80179c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801751:	89 da                	mov    %ebx,%edx
  801753:	89 f0                	mov    %esi,%eax
  801755:	e8 6d ff ff ff       	call   8016c7 <_pipeisclosed>
  80175a:	85 c0                	test   %eax,%eax
  80175c:	75 48                	jne    8017a6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80175e:	e8 09 f4 ff ff       	call   800b6c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801763:	8b 43 04             	mov    0x4(%ebx),%eax
  801766:	8b 0b                	mov    (%ebx),%ecx
  801768:	8d 51 20             	lea    0x20(%ecx),%edx
  80176b:	39 d0                	cmp    %edx,%eax
  80176d:	73 e2                	jae    801751 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80176f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801772:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801776:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801779:	89 c2                	mov    %eax,%edx
  80177b:	c1 fa 1f             	sar    $0x1f,%edx
  80177e:	89 d1                	mov    %edx,%ecx
  801780:	c1 e9 1b             	shr    $0x1b,%ecx
  801783:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801786:	83 e2 1f             	and    $0x1f,%edx
  801789:	29 ca                	sub    %ecx,%edx
  80178b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80178f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801793:	83 c0 01             	add    $0x1,%eax
  801796:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801799:	83 c7 01             	add    $0x1,%edi
  80179c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80179f:	75 c2                	jne    801763 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a4:	eb 05                	jmp    8017ab <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017a6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ae:	5b                   	pop    %ebx
  8017af:	5e                   	pop    %esi
  8017b0:	5f                   	pop    %edi
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	57                   	push   %edi
  8017b7:	56                   	push   %esi
  8017b8:	53                   	push   %ebx
  8017b9:	83 ec 18             	sub    $0x18,%esp
  8017bc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017bf:	57                   	push   %edi
  8017c0:	e8 46 f6 ff ff       	call   800e0b <fd2data>
  8017c5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017cf:	eb 3d                	jmp    80180e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017d1:	85 db                	test   %ebx,%ebx
  8017d3:	74 04                	je     8017d9 <devpipe_read+0x26>
				return i;
  8017d5:	89 d8                	mov    %ebx,%eax
  8017d7:	eb 44                	jmp    80181d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017d9:	89 f2                	mov    %esi,%edx
  8017db:	89 f8                	mov    %edi,%eax
  8017dd:	e8 e5 fe ff ff       	call   8016c7 <_pipeisclosed>
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	75 32                	jne    801818 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017e6:	e8 81 f3 ff ff       	call   800b6c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017eb:	8b 06                	mov    (%esi),%eax
  8017ed:	3b 46 04             	cmp    0x4(%esi),%eax
  8017f0:	74 df                	je     8017d1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017f2:	99                   	cltd   
  8017f3:	c1 ea 1b             	shr    $0x1b,%edx
  8017f6:	01 d0                	add    %edx,%eax
  8017f8:	83 e0 1f             	and    $0x1f,%eax
  8017fb:	29 d0                	sub    %edx,%eax
  8017fd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801805:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801808:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80180b:	83 c3 01             	add    $0x1,%ebx
  80180e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801811:	75 d8                	jne    8017eb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801813:	8b 45 10             	mov    0x10(%ebp),%eax
  801816:	eb 05                	jmp    80181d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801818:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80181d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801820:	5b                   	pop    %ebx
  801821:	5e                   	pop    %esi
  801822:	5f                   	pop    %edi
  801823:	5d                   	pop    %ebp
  801824:	c3                   	ret    

00801825 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80182d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801830:	50                   	push   %eax
  801831:	e8 ec f5 ff ff       	call   800e22 <fd_alloc>
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	89 c2                	mov    %eax,%edx
  80183b:	85 c0                	test   %eax,%eax
  80183d:	0f 88 2c 01 00 00    	js     80196f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801843:	83 ec 04             	sub    $0x4,%esp
  801846:	68 07 04 00 00       	push   $0x407
  80184b:	ff 75 f4             	pushl  -0xc(%ebp)
  80184e:	6a 00                	push   $0x0
  801850:	e8 36 f3 ff ff       	call   800b8b <sys_page_alloc>
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	89 c2                	mov    %eax,%edx
  80185a:	85 c0                	test   %eax,%eax
  80185c:	0f 88 0d 01 00 00    	js     80196f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801862:	83 ec 0c             	sub    $0xc,%esp
  801865:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801868:	50                   	push   %eax
  801869:	e8 b4 f5 ff ff       	call   800e22 <fd_alloc>
  80186e:	89 c3                	mov    %eax,%ebx
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	85 c0                	test   %eax,%eax
  801875:	0f 88 e2 00 00 00    	js     80195d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187b:	83 ec 04             	sub    $0x4,%esp
  80187e:	68 07 04 00 00       	push   $0x407
  801883:	ff 75 f0             	pushl  -0x10(%ebp)
  801886:	6a 00                	push   $0x0
  801888:	e8 fe f2 ff ff       	call   800b8b <sys_page_alloc>
  80188d:	89 c3                	mov    %eax,%ebx
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	85 c0                	test   %eax,%eax
  801894:	0f 88 c3 00 00 00    	js     80195d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80189a:	83 ec 0c             	sub    $0xc,%esp
  80189d:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a0:	e8 66 f5 ff ff       	call   800e0b <fd2data>
  8018a5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a7:	83 c4 0c             	add    $0xc,%esp
  8018aa:	68 07 04 00 00       	push   $0x407
  8018af:	50                   	push   %eax
  8018b0:	6a 00                	push   $0x0
  8018b2:	e8 d4 f2 ff ff       	call   800b8b <sys_page_alloc>
  8018b7:	89 c3                	mov    %eax,%ebx
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	0f 88 89 00 00 00    	js     80194d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c4:	83 ec 0c             	sub    $0xc,%esp
  8018c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ca:	e8 3c f5 ff ff       	call   800e0b <fd2data>
  8018cf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018d6:	50                   	push   %eax
  8018d7:	6a 00                	push   $0x0
  8018d9:	56                   	push   %esi
  8018da:	6a 00                	push   $0x0
  8018dc:	e8 ed f2 ff ff       	call   800bce <sys_page_map>
  8018e1:	89 c3                	mov    %eax,%ebx
  8018e3:	83 c4 20             	add    $0x20,%esp
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 55                	js     80193f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018ea:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018ff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801905:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801908:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80190a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801914:	83 ec 0c             	sub    $0xc,%esp
  801917:	ff 75 f4             	pushl  -0xc(%ebp)
  80191a:	e8 dc f4 ff ff       	call   800dfb <fd2num>
  80191f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801922:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801924:	83 c4 04             	add    $0x4,%esp
  801927:	ff 75 f0             	pushl  -0x10(%ebp)
  80192a:	e8 cc f4 ff ff       	call   800dfb <fd2num>
  80192f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801932:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	ba 00 00 00 00       	mov    $0x0,%edx
  80193d:	eb 30                	jmp    80196f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80193f:	83 ec 08             	sub    $0x8,%esp
  801942:	56                   	push   %esi
  801943:	6a 00                	push   $0x0
  801945:	e8 c6 f2 ff ff       	call   800c10 <sys_page_unmap>
  80194a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80194d:	83 ec 08             	sub    $0x8,%esp
  801950:	ff 75 f0             	pushl  -0x10(%ebp)
  801953:	6a 00                	push   $0x0
  801955:	e8 b6 f2 ff ff       	call   800c10 <sys_page_unmap>
  80195a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80195d:	83 ec 08             	sub    $0x8,%esp
  801960:	ff 75 f4             	pushl  -0xc(%ebp)
  801963:	6a 00                	push   $0x0
  801965:	e8 a6 f2 ff ff       	call   800c10 <sys_page_unmap>
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80196f:	89 d0                	mov    %edx,%eax
  801971:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801974:	5b                   	pop    %ebx
  801975:	5e                   	pop    %esi
  801976:	5d                   	pop    %ebp
  801977:	c3                   	ret    

00801978 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80197e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801981:	50                   	push   %eax
  801982:	ff 75 08             	pushl  0x8(%ebp)
  801985:	e8 e7 f4 ff ff       	call   800e71 <fd_lookup>
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	85 c0                	test   %eax,%eax
  80198f:	78 18                	js     8019a9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801991:	83 ec 0c             	sub    $0xc,%esp
  801994:	ff 75 f4             	pushl  -0xc(%ebp)
  801997:	e8 6f f4 ff ff       	call   800e0b <fd2data>
	return _pipeisclosed(fd, p);
  80199c:	89 c2                	mov    %eax,%edx
  80199e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a1:	e8 21 fd ff ff       	call   8016c7 <_pipeisclosed>
  8019a6:	83 c4 10             	add    $0x10,%esp
}
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b3:	5d                   	pop    %ebp
  8019b4:	c3                   	ret    

008019b5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019bb:	68 e9 23 80 00       	push   $0x8023e9
  8019c0:	ff 75 0c             	pushl  0xc(%ebp)
  8019c3:	e8 c0 ed ff ff       	call   800788 <strcpy>
	return 0;
}
  8019c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	57                   	push   %edi
  8019d3:	56                   	push   %esi
  8019d4:	53                   	push   %ebx
  8019d5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019db:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019e0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019e6:	eb 2d                	jmp    801a15 <devcons_write+0x46>
		m = n - tot;
  8019e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019eb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019ed:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019f0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019f5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019f8:	83 ec 04             	sub    $0x4,%esp
  8019fb:	53                   	push   %ebx
  8019fc:	03 45 0c             	add    0xc(%ebp),%eax
  8019ff:	50                   	push   %eax
  801a00:	57                   	push   %edi
  801a01:	e8 14 ef ff ff       	call   80091a <memmove>
		sys_cputs(buf, m);
  801a06:	83 c4 08             	add    $0x8,%esp
  801a09:	53                   	push   %ebx
  801a0a:	57                   	push   %edi
  801a0b:	e8 bf f0 ff ff       	call   800acf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a10:	01 de                	add    %ebx,%esi
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	89 f0                	mov    %esi,%eax
  801a17:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a1a:	72 cc                	jb     8019e8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1f:	5b                   	pop    %ebx
  801a20:	5e                   	pop    %esi
  801a21:	5f                   	pop    %edi
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	83 ec 08             	sub    $0x8,%esp
  801a2a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a33:	74 2a                	je     801a5f <devcons_read+0x3b>
  801a35:	eb 05                	jmp    801a3c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a37:	e8 30 f1 ff ff       	call   800b6c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a3c:	e8 ac f0 ff ff       	call   800aed <sys_cgetc>
  801a41:	85 c0                	test   %eax,%eax
  801a43:	74 f2                	je     801a37 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a45:	85 c0                	test   %eax,%eax
  801a47:	78 16                	js     801a5f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a49:	83 f8 04             	cmp    $0x4,%eax
  801a4c:	74 0c                	je     801a5a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a51:	88 02                	mov    %al,(%edx)
	return 1;
  801a53:	b8 01 00 00 00       	mov    $0x1,%eax
  801a58:	eb 05                	jmp    801a5f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a5a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a67:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a6d:	6a 01                	push   $0x1
  801a6f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a72:	50                   	push   %eax
  801a73:	e8 57 f0 ff ff       	call   800acf <sys_cputs>
}
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	c9                   	leave  
  801a7c:	c3                   	ret    

00801a7d <getchar>:

int
getchar(void)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a83:	6a 01                	push   $0x1
  801a85:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a88:	50                   	push   %eax
  801a89:	6a 00                	push   $0x0
  801a8b:	e8 47 f6 ff ff       	call   8010d7 <read>
	if (r < 0)
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	85 c0                	test   %eax,%eax
  801a95:	78 0f                	js     801aa6 <getchar+0x29>
		return r;
	if (r < 1)
  801a97:	85 c0                	test   %eax,%eax
  801a99:	7e 06                	jle    801aa1 <getchar+0x24>
		return -E_EOF;
	return c;
  801a9b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a9f:	eb 05                	jmp    801aa6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801aa1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab1:	50                   	push   %eax
  801ab2:	ff 75 08             	pushl  0x8(%ebp)
  801ab5:	e8 b7 f3 ff ff       	call   800e71 <fd_lookup>
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	85 c0                	test   %eax,%eax
  801abf:	78 11                	js     801ad2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aca:	39 10                	cmp    %edx,(%eax)
  801acc:	0f 94 c0             	sete   %al
  801acf:	0f b6 c0             	movzbl %al,%eax
}
  801ad2:	c9                   	leave  
  801ad3:	c3                   	ret    

00801ad4 <opencons>:

int
opencons(void)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ada:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801add:	50                   	push   %eax
  801ade:	e8 3f f3 ff ff       	call   800e22 <fd_alloc>
  801ae3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	78 3e                	js     801b2a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801aec:	83 ec 04             	sub    $0x4,%esp
  801aef:	68 07 04 00 00       	push   $0x407
  801af4:	ff 75 f4             	pushl  -0xc(%ebp)
  801af7:	6a 00                	push   $0x0
  801af9:	e8 8d f0 ff ff       	call   800b8b <sys_page_alloc>
  801afe:	83 c4 10             	add    $0x10,%esp
		return r;
  801b01:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b03:	85 c0                	test   %eax,%eax
  801b05:	78 23                	js     801b2a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b07:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b10:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b15:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b1c:	83 ec 0c             	sub    $0xc,%esp
  801b1f:	50                   	push   %eax
  801b20:	e8 d6 f2 ff ff       	call   800dfb <fd2num>
  801b25:	89 c2                	mov    %eax,%edx
  801b27:	83 c4 10             	add    $0x10,%esp
}
  801b2a:	89 d0                	mov    %edx,%eax
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	56                   	push   %esi
  801b32:	53                   	push   %ebx
  801b33:	8b 75 08             	mov    0x8(%ebp),%esi
  801b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801b3c:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801b3e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801b43:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801b46:	83 ec 0c             	sub    $0xc,%esp
  801b49:	50                   	push   %eax
  801b4a:	e8 ec f1 ff ff       	call   800d3b <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	85 c0                	test   %eax,%eax
  801b54:	78 0e                	js     801b64 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801b56:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b5c:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801b5f:	8b 52 78             	mov    0x78(%edx),%edx
  801b62:	eb 0a                	jmp    801b6e <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801b64:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801b69:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801b6e:	85 f6                	test   %esi,%esi
  801b70:	74 02                	je     801b74 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801b72:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801b74:	85 db                	test   %ebx,%ebx
  801b76:	74 02                	je     801b7a <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801b78:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	78 08                	js     801b86 <ipc_recv+0x58>
  801b7e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b83:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801b86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    

00801b8d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	57                   	push   %edi
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
  801b93:	83 ec 0c             	sub    $0xc,%esp
  801b96:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b99:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801b9f:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801ba1:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801ba6:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801ba9:	ff 75 14             	pushl  0x14(%ebp)
  801bac:	53                   	push   %ebx
  801bad:	56                   	push   %esi
  801bae:	57                   	push   %edi
  801baf:	e8 64 f1 ff ff       	call   800d18 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bba:	75 07                	jne    801bc3 <ipc_send+0x36>
				    sys_yield();
  801bbc:	e8 ab ef ff ff       	call   800b6c <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801bc1:	eb e6                	jmp    801ba9 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	74 12                	je     801bd9 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801bc7:	50                   	push   %eax
  801bc8:	68 f5 23 80 00       	push   $0x8023f5
  801bcd:	6a 4b                	push   $0x4b
  801bcf:	68 09 24 80 00       	push   $0x802409
  801bd4:	e8 51 e5 ff ff       	call   80012a <_panic>
			 }
	   }
}
  801bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdc:	5b                   	pop    %ebx
  801bdd:	5e                   	pop    %esi
  801bde:	5f                   	pop    %edi
  801bdf:	5d                   	pop    %ebp
  801be0:	c3                   	ret    

00801be1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801be7:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801bec:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bef:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bf5:	8b 52 50             	mov    0x50(%edx),%edx
  801bf8:	39 ca                	cmp    %ecx,%edx
  801bfa:	75 0d                	jne    801c09 <ipc_find_env+0x28>
				    return envs[i].env_id;
  801bfc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c04:	8b 40 48             	mov    0x48(%eax),%eax
  801c07:	eb 0f                	jmp    801c18 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801c09:	83 c0 01             	add    $0x1,%eax
  801c0c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c11:	75 d9                	jne    801bec <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801c13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c20:	89 d0                	mov    %edx,%eax
  801c22:	c1 e8 16             	shr    $0x16,%eax
  801c25:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c2c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c31:	f6 c1 01             	test   $0x1,%cl
  801c34:	74 1d                	je     801c53 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c36:	c1 ea 0c             	shr    $0xc,%edx
  801c39:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c40:	f6 c2 01             	test   $0x1,%dl
  801c43:	74 0e                	je     801c53 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c45:	c1 ea 0c             	shr    $0xc,%edx
  801c48:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c4f:	ef 
  801c50:	0f b7 c0             	movzwl %ax,%eax
}
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    
  801c55:	66 90                	xchg   %ax,%ax
  801c57:	66 90                	xchg   %ax,%ax
  801c59:	66 90                	xchg   %ax,%ax
  801c5b:	66 90                	xchg   %ax,%ax
  801c5d:	66 90                	xchg   %ax,%ax
  801c5f:	90                   	nop

00801c60 <__udivdi3>:
  801c60:	55                   	push   %ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 1c             	sub    $0x1c,%esp
  801c67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c77:	85 f6                	test   %esi,%esi
  801c79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c7d:	89 ca                	mov    %ecx,%edx
  801c7f:	89 f8                	mov    %edi,%eax
  801c81:	75 3d                	jne    801cc0 <__udivdi3+0x60>
  801c83:	39 cf                	cmp    %ecx,%edi
  801c85:	0f 87 c5 00 00 00    	ja     801d50 <__udivdi3+0xf0>
  801c8b:	85 ff                	test   %edi,%edi
  801c8d:	89 fd                	mov    %edi,%ebp
  801c8f:	75 0b                	jne    801c9c <__udivdi3+0x3c>
  801c91:	b8 01 00 00 00       	mov    $0x1,%eax
  801c96:	31 d2                	xor    %edx,%edx
  801c98:	f7 f7                	div    %edi
  801c9a:	89 c5                	mov    %eax,%ebp
  801c9c:	89 c8                	mov    %ecx,%eax
  801c9e:	31 d2                	xor    %edx,%edx
  801ca0:	f7 f5                	div    %ebp
  801ca2:	89 c1                	mov    %eax,%ecx
  801ca4:	89 d8                	mov    %ebx,%eax
  801ca6:	89 cf                	mov    %ecx,%edi
  801ca8:	f7 f5                	div    %ebp
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	89 fa                	mov    %edi,%edx
  801cb0:	83 c4 1c             	add    $0x1c,%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    
  801cb8:	90                   	nop
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	39 ce                	cmp    %ecx,%esi
  801cc2:	77 74                	ja     801d38 <__udivdi3+0xd8>
  801cc4:	0f bd fe             	bsr    %esi,%edi
  801cc7:	83 f7 1f             	xor    $0x1f,%edi
  801cca:	0f 84 98 00 00 00    	je     801d68 <__udivdi3+0x108>
  801cd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cd5:	89 f9                	mov    %edi,%ecx
  801cd7:	89 c5                	mov    %eax,%ebp
  801cd9:	29 fb                	sub    %edi,%ebx
  801cdb:	d3 e6                	shl    %cl,%esi
  801cdd:	89 d9                	mov    %ebx,%ecx
  801cdf:	d3 ed                	shr    %cl,%ebp
  801ce1:	89 f9                	mov    %edi,%ecx
  801ce3:	d3 e0                	shl    %cl,%eax
  801ce5:	09 ee                	or     %ebp,%esi
  801ce7:	89 d9                	mov    %ebx,%ecx
  801ce9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ced:	89 d5                	mov    %edx,%ebp
  801cef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cf3:	d3 ed                	shr    %cl,%ebp
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	d3 e2                	shl    %cl,%edx
  801cf9:	89 d9                	mov    %ebx,%ecx
  801cfb:	d3 e8                	shr    %cl,%eax
  801cfd:	09 c2                	or     %eax,%edx
  801cff:	89 d0                	mov    %edx,%eax
  801d01:	89 ea                	mov    %ebp,%edx
  801d03:	f7 f6                	div    %esi
  801d05:	89 d5                	mov    %edx,%ebp
  801d07:	89 c3                	mov    %eax,%ebx
  801d09:	f7 64 24 0c          	mull   0xc(%esp)
  801d0d:	39 d5                	cmp    %edx,%ebp
  801d0f:	72 10                	jb     801d21 <__udivdi3+0xc1>
  801d11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d15:	89 f9                	mov    %edi,%ecx
  801d17:	d3 e6                	shl    %cl,%esi
  801d19:	39 c6                	cmp    %eax,%esi
  801d1b:	73 07                	jae    801d24 <__udivdi3+0xc4>
  801d1d:	39 d5                	cmp    %edx,%ebp
  801d1f:	75 03                	jne    801d24 <__udivdi3+0xc4>
  801d21:	83 eb 01             	sub    $0x1,%ebx
  801d24:	31 ff                	xor    %edi,%edi
  801d26:	89 d8                	mov    %ebx,%eax
  801d28:	89 fa                	mov    %edi,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	31 ff                	xor    %edi,%edi
  801d3a:	31 db                	xor    %ebx,%ebx
  801d3c:	89 d8                	mov    %ebx,%eax
  801d3e:	89 fa                	mov    %edi,%edx
  801d40:	83 c4 1c             	add    $0x1c,%esp
  801d43:	5b                   	pop    %ebx
  801d44:	5e                   	pop    %esi
  801d45:	5f                   	pop    %edi
  801d46:	5d                   	pop    %ebp
  801d47:	c3                   	ret    
  801d48:	90                   	nop
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	89 d8                	mov    %ebx,%eax
  801d52:	f7 f7                	div    %edi
  801d54:	31 ff                	xor    %edi,%edi
  801d56:	89 c3                	mov    %eax,%ebx
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	89 fa                	mov    %edi,%edx
  801d5c:	83 c4 1c             	add    $0x1c,%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5e                   	pop    %esi
  801d61:	5f                   	pop    %edi
  801d62:	5d                   	pop    %ebp
  801d63:	c3                   	ret    
  801d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d68:	39 ce                	cmp    %ecx,%esi
  801d6a:	72 0c                	jb     801d78 <__udivdi3+0x118>
  801d6c:	31 db                	xor    %ebx,%ebx
  801d6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d72:	0f 87 34 ff ff ff    	ja     801cac <__udivdi3+0x4c>
  801d78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d7d:	e9 2a ff ff ff       	jmp    801cac <__udivdi3+0x4c>
  801d82:	66 90                	xchg   %ax,%ax
  801d84:	66 90                	xchg   %ax,%ax
  801d86:	66 90                	xchg   %ax,%ax
  801d88:	66 90                	xchg   %ax,%ax
  801d8a:	66 90                	xchg   %ax,%ax
  801d8c:	66 90                	xchg   %ax,%ax
  801d8e:	66 90                	xchg   %ax,%ax

00801d90 <__umoddi3>:
  801d90:	55                   	push   %ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	83 ec 1c             	sub    $0x1c,%esp
  801d97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801da7:	85 d2                	test   %edx,%edx
  801da9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801db1:	89 f3                	mov    %esi,%ebx
  801db3:	89 3c 24             	mov    %edi,(%esp)
  801db6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dba:	75 1c                	jne    801dd8 <__umoddi3+0x48>
  801dbc:	39 f7                	cmp    %esi,%edi
  801dbe:	76 50                	jbe    801e10 <__umoddi3+0x80>
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	f7 f7                	div    %edi
  801dc6:	89 d0                	mov    %edx,%eax
  801dc8:	31 d2                	xor    %edx,%edx
  801dca:	83 c4 1c             	add    $0x1c,%esp
  801dcd:	5b                   	pop    %ebx
  801dce:	5e                   	pop    %esi
  801dcf:	5f                   	pop    %edi
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    
  801dd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dd8:	39 f2                	cmp    %esi,%edx
  801dda:	89 d0                	mov    %edx,%eax
  801ddc:	77 52                	ja     801e30 <__umoddi3+0xa0>
  801dde:	0f bd ea             	bsr    %edx,%ebp
  801de1:	83 f5 1f             	xor    $0x1f,%ebp
  801de4:	75 5a                	jne    801e40 <__umoddi3+0xb0>
  801de6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dea:	0f 82 e0 00 00 00    	jb     801ed0 <__umoddi3+0x140>
  801df0:	39 0c 24             	cmp    %ecx,(%esp)
  801df3:	0f 86 d7 00 00 00    	jbe    801ed0 <__umoddi3+0x140>
  801df9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e01:	83 c4 1c             	add    $0x1c,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	85 ff                	test   %edi,%edi
  801e12:	89 fd                	mov    %edi,%ebp
  801e14:	75 0b                	jne    801e21 <__umoddi3+0x91>
  801e16:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	f7 f7                	div    %edi
  801e1f:	89 c5                	mov    %eax,%ebp
  801e21:	89 f0                	mov    %esi,%eax
  801e23:	31 d2                	xor    %edx,%edx
  801e25:	f7 f5                	div    %ebp
  801e27:	89 c8                	mov    %ecx,%eax
  801e29:	f7 f5                	div    %ebp
  801e2b:	89 d0                	mov    %edx,%eax
  801e2d:	eb 99                	jmp    801dc8 <__umoddi3+0x38>
  801e2f:	90                   	nop
  801e30:	89 c8                	mov    %ecx,%eax
  801e32:	89 f2                	mov    %esi,%edx
  801e34:	83 c4 1c             	add    $0x1c,%esp
  801e37:	5b                   	pop    %ebx
  801e38:	5e                   	pop    %esi
  801e39:	5f                   	pop    %edi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    
  801e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e40:	8b 34 24             	mov    (%esp),%esi
  801e43:	bf 20 00 00 00       	mov    $0x20,%edi
  801e48:	89 e9                	mov    %ebp,%ecx
  801e4a:	29 ef                	sub    %ebp,%edi
  801e4c:	d3 e0                	shl    %cl,%eax
  801e4e:	89 f9                	mov    %edi,%ecx
  801e50:	89 f2                	mov    %esi,%edx
  801e52:	d3 ea                	shr    %cl,%edx
  801e54:	89 e9                	mov    %ebp,%ecx
  801e56:	09 c2                	or     %eax,%edx
  801e58:	89 d8                	mov    %ebx,%eax
  801e5a:	89 14 24             	mov    %edx,(%esp)
  801e5d:	89 f2                	mov    %esi,%edx
  801e5f:	d3 e2                	shl    %cl,%edx
  801e61:	89 f9                	mov    %edi,%ecx
  801e63:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e6b:	d3 e8                	shr    %cl,%eax
  801e6d:	89 e9                	mov    %ebp,%ecx
  801e6f:	89 c6                	mov    %eax,%esi
  801e71:	d3 e3                	shl    %cl,%ebx
  801e73:	89 f9                	mov    %edi,%ecx
  801e75:	89 d0                	mov    %edx,%eax
  801e77:	d3 e8                	shr    %cl,%eax
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	09 d8                	or     %ebx,%eax
  801e7d:	89 d3                	mov    %edx,%ebx
  801e7f:	89 f2                	mov    %esi,%edx
  801e81:	f7 34 24             	divl   (%esp)
  801e84:	89 d6                	mov    %edx,%esi
  801e86:	d3 e3                	shl    %cl,%ebx
  801e88:	f7 64 24 04          	mull   0x4(%esp)
  801e8c:	39 d6                	cmp    %edx,%esi
  801e8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e92:	89 d1                	mov    %edx,%ecx
  801e94:	89 c3                	mov    %eax,%ebx
  801e96:	72 08                	jb     801ea0 <__umoddi3+0x110>
  801e98:	75 11                	jne    801eab <__umoddi3+0x11b>
  801e9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e9e:	73 0b                	jae    801eab <__umoddi3+0x11b>
  801ea0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ea4:	1b 14 24             	sbb    (%esp),%edx
  801ea7:	89 d1                	mov    %edx,%ecx
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	8b 54 24 08          	mov    0x8(%esp),%edx
  801eaf:	29 da                	sub    %ebx,%edx
  801eb1:	19 ce                	sbb    %ecx,%esi
  801eb3:	89 f9                	mov    %edi,%ecx
  801eb5:	89 f0                	mov    %esi,%eax
  801eb7:	d3 e0                	shl    %cl,%eax
  801eb9:	89 e9                	mov    %ebp,%ecx
  801ebb:	d3 ea                	shr    %cl,%edx
  801ebd:	89 e9                	mov    %ebp,%ecx
  801ebf:	d3 ee                	shr    %cl,%esi
  801ec1:	09 d0                	or     %edx,%eax
  801ec3:	89 f2                	mov    %esi,%edx
  801ec5:	83 c4 1c             	add    $0x1c,%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5f                   	pop    %edi
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    
  801ecd:	8d 76 00             	lea    0x0(%esi),%esi
  801ed0:	29 f9                	sub    %edi,%ecx
  801ed2:	19 d6                	sbb    %edx,%esi
  801ed4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ed8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801edc:	e9 18 ff ff ff       	jmp    801df9 <__umoddi3+0x69>
