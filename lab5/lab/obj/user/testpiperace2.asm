
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
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
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 e0 22 80 00       	push   $0x8022e0
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 49 1b 00 00       	call   801b9a <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 2e 23 80 00       	push   $0x80232e
  80005e:	6a 0d                	push   $0xd
  800060:	68 37 23 80 00       	push   $0x802337
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 02 0f 00 00       	call   800f71 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 88 27 80 00       	push   $0x802788
  80007b:	6a 0f                	push   $0xf
  80007d:	68 37 23 80 00       	push   $0x802337
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 7a 12 00 00       	call   801310 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 4c 23 80 00       	push   $0x80234c
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 88 12 00 00       	call   801360 <dup>
			sys_yield();
  8000d8:	e8 9b 0b 00 00       	call   800c78 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 27 12 00 00       	call   801310 <close>
			sys_yield();
  8000e9:	e8 8a 0b 00 00       	call   800c78 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 cb 1b 00 00       	call   801ced <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 50 23 80 00       	push   $0x802350
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 da 0a 00 00       	call   800c18 <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 6c 23 80 00       	push   $0x80236c
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 7c 1b 00 00       	call   801ced <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 04 23 80 00       	push   $0x802304
  800180:	6a 40                	push   $0x40
  800182:	68 37 23 80 00       	push   $0x802337
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 4b 10 00 00       	call   8011e6 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 82 23 80 00       	push   $0x802382
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 37 23 80 00       	push   $0x802337
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 c1 0f 00 00       	call   801180 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 9a 23 80 00 	movl   $0x80239a,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8001e1:	e8 73 0a 00 00       	call   800c59 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 14 11 00 00       	call   80133b <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 e7 09 00 00       	call   800c18 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 10 0a 00 00       	call   800c59 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 b8 23 80 00       	push   $0x8023b8
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 a6 28 80 00 	movl   $0x8028a6,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 2f 09 00 00       	call   800bdb <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 54 01 00 00       	call   800446 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 d4 08 00 00       	call   800bdb <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 d9 1c 00 00       	call   802050 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 c6 1d 00 00       	call   802180 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 db 23 80 00 	movsbl 0x8023db(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d5:	83 fa 01             	cmp    $0x1,%edx
  8003d8:	7e 0e                	jle    8003e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	8b 52 04             	mov    0x4(%edx),%edx
  8003e6:	eb 22                	jmp    80040a <getuint+0x38>
	else if (lflag)
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 10                	je     8003fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fa:	eb 0e                	jmp    80040a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800401:	89 08                	mov    %ecx,(%eax)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800412:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800416:	8b 10                	mov    (%eax),%edx
  800418:	3b 50 04             	cmp    0x4(%eax),%edx
  80041b:	73 0a                	jae    800427 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800420:	89 08                	mov    %ecx,(%eax)
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	88 02                	mov    %al,(%edx)
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800432:	50                   	push   %eax
  800433:	ff 75 10             	pushl  0x10(%ebp)
  800436:	ff 75 0c             	pushl  0xc(%ebp)
  800439:	ff 75 08             	pushl  0x8(%ebp)
  80043c:	e8 05 00 00 00       	call   800446 <vprintfmt>
	va_end(ap);
}
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 2c             	sub    $0x2c,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800455:	8b 7d 10             	mov    0x10(%ebp),%edi
  800458:	eb 12                	jmp    80046c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045a:	85 c0                	test   %eax,%eax
  80045c:	0f 84 89 03 00 00    	je     8007eb <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	50                   	push   %eax
  800467:	ff d6                	call   *%esi
  800469:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046c:	83 c7 01             	add    $0x1,%edi
  80046f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800473:	83 f8 25             	cmp    $0x25,%eax
  800476:	75 e2                	jne    80045a <vprintfmt+0x14>
  800478:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80047c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800483:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
  800496:	eb 07                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8d 47 01             	lea    0x1(%edi),%eax
  8004a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a5:	0f b6 07             	movzbl (%edi),%eax
  8004a8:	0f b6 c8             	movzbl %al,%ecx
  8004ab:	83 e8 23             	sub    $0x23,%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 1a 03 00 00    	ja     8007d0 <vprintfmt+0x38a>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c7:	eb d6                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004db:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e1:	83 fa 09             	cmp    $0x9,%edx
  8004e4:	77 39                	ja     80051f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e9:	eb e9                	jmp    8004d4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fc:	eb 27                	jmp    800525 <vprintfmt+0xdf>
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	85 c0                	test   %eax,%eax
  800503:	b9 00 00 00 00       	mov    $0x0,%ecx
  800508:	0f 49 c8             	cmovns %eax,%ecx
  80050b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	eb 8c                	jmp    80049f <vprintfmt+0x59>
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800516:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80051d:	eb 80                	jmp    80049f <vprintfmt+0x59>
  80051f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800522:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800525:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800529:	0f 89 70 ff ff ff    	jns    80049f <vprintfmt+0x59>
				width = precision, precision = -1;
  80052f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800535:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80053c:	e9 5e ff ff ff       	jmp    80049f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800541:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800547:	e9 53 ff ff ff       	jmp    80049f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	ff 30                	pushl  (%eax)
  80055b:	ff d6                	call   *%esi
			break;
  80055d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800563:	e9 04 ff ff ff       	jmp    80046c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 00                	mov    (%eax),%eax
  800573:	99                   	cltd   
  800574:	31 d0                	xor    %edx,%eax
  800576:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800578:	83 f8 0f             	cmp    $0xf,%eax
  80057b:	7f 0b                	jg     800588 <vprintfmt+0x142>
  80057d:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  800584:	85 d2                	test   %edx,%edx
  800586:	75 18                	jne    8005a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800588:	50                   	push   %eax
  800589:	68 f3 23 80 00       	push   $0x8023f3
  80058e:	53                   	push   %ebx
  80058f:	56                   	push   %esi
  800590:	e8 94 fe ff ff       	call   800429 <printfmt>
  800595:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059b:	e9 cc fe ff ff       	jmp    80046c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a0:	52                   	push   %edx
  8005a1:	68 61 28 80 00       	push   $0x802861
  8005a6:	53                   	push   %ebx
  8005a7:	56                   	push   %esi
  8005a8:	e8 7c fe ff ff       	call   800429 <printfmt>
  8005ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b3:	e9 b4 fe ff ff       	jmp    80046c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	b8 ec 23 80 00       	mov    $0x8023ec,%eax
  8005ca:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 8e 94 00 00 00    	jle    80066b <vprintfmt+0x225>
  8005d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005db:	0f 84 98 00 00 00    	je     800679 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005e7:	57                   	push   %edi
  8005e8:	e8 86 02 00 00       	call   800873 <strnlen>
  8005ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f0:	29 c1                	sub    %eax,%ecx
  8005f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800602:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	eb 0f                	jmp    800615 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	ff 75 e0             	pushl  -0x20(%ebp)
  80060d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	85 ff                	test   %edi,%edi
  800617:	7f ed                	jg     800606 <vprintfmt+0x1c0>
  800619:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80061f:	85 c9                	test   %ecx,%ecx
  800621:	b8 00 00 00 00       	mov    $0x0,%eax
  800626:	0f 49 c1             	cmovns %ecx,%eax
  800629:	29 c1                	sub    %eax,%ecx
  80062b:	89 75 08             	mov    %esi,0x8(%ebp)
  80062e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800631:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800634:	89 cb                	mov    %ecx,%ebx
  800636:	eb 4d                	jmp    800685 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800638:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063c:	74 1b                	je     800659 <vprintfmt+0x213>
  80063e:	0f be c0             	movsbl %al,%eax
  800641:	83 e8 20             	sub    $0x20,%eax
  800644:	83 f8 5e             	cmp    $0x5e,%eax
  800647:	76 10                	jbe    800659 <vprintfmt+0x213>
					putch('?', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	ff 75 0c             	pushl  0xc(%ebp)
  80064f:	6a 3f                	push   $0x3f
  800651:	ff 55 08             	call   *0x8(%ebp)
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb 0d                	jmp    800666 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	52                   	push   %edx
  800660:	ff 55 08             	call   *0x8(%ebp)
  800663:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800666:	83 eb 01             	sub    $0x1,%ebx
  800669:	eb 1a                	jmp    800685 <vprintfmt+0x23f>
  80066b:	89 75 08             	mov    %esi,0x8(%ebp)
  80066e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800671:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800674:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800677:	eb 0c                	jmp    800685 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	83 c7 01             	add    $0x1,%edi
  800688:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068c:	0f be d0             	movsbl %al,%edx
  80068f:	85 d2                	test   %edx,%edx
  800691:	74 23                	je     8006b6 <vprintfmt+0x270>
  800693:	85 f6                	test   %esi,%esi
  800695:	78 a1                	js     800638 <vprintfmt+0x1f2>
  800697:	83 ee 01             	sub    $0x1,%esi
  80069a:	79 9c                	jns    800638 <vprintfmt+0x1f2>
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a4:	eb 18                	jmp    8006be <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 20                	push   $0x20
  8006ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ae:	83 ef 01             	sub    $0x1,%edi
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb 08                	jmp    8006be <vprintfmt+0x278>
  8006b6:	89 df                	mov    %ebx,%edi
  8006b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006be:	85 ff                	test   %edi,%edi
  8006c0:	7f e4                	jg     8006a6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c5:	e9 a2 fd ff ff       	jmp    80046c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ca:	83 fa 01             	cmp    $0x1,%edx
  8006cd:	7e 16                	jle    8006e5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 08             	lea    0x8(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 50 04             	mov    0x4(%eax),%edx
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e3:	eb 32                	jmp    800717 <vprintfmt+0x2d1>
	else if (lflag)
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	74 18                	je     800701 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 50 04             	lea    0x4(%eax),%edx
  8006ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f7:	89 c1                	mov    %eax,%ecx
  8006f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ff:	eb 16                	jmp    800717 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070f:	89 c1                	mov    %eax,%ecx
  800711:	c1 f9 1f             	sar    $0x1f,%ecx
  800714:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800717:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800722:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800726:	79 74                	jns    80079c <vprintfmt+0x356>
				putch('-', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	53                   	push   %ebx
  80072c:	6a 2d                	push   $0x2d
  80072e:	ff d6                	call   *%esi
				num = -(long long) num;
  800730:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800733:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800736:	f7 d8                	neg    %eax
  800738:	83 d2 00             	adc    $0x0,%edx
  80073b:	f7 da                	neg    %edx
  80073d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800740:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800745:	eb 55                	jmp    80079c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 83 fc ff ff       	call   8003d2 <getuint>
			base = 10;
  80074f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800754:	eb 46                	jmp    80079c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 74 fc ff ff       	call   8003d2 <getuint>
			base = 8;
  80075e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800763:	eb 37                	jmp    80079c <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	53                   	push   %ebx
  800769:	6a 30                	push   $0x30
  80076b:	ff d6                	call   *%esi
			putch('x', putdat);
  80076d:	83 c4 08             	add    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	6a 78                	push   $0x78
  800773:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8d 50 04             	lea    0x4(%eax),%edx
  80077b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077e:	8b 00                	mov    (%eax),%eax
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800785:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800788:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078d:	eb 0d                	jmp    80079c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 3b fc ff ff       	call   8003d2 <getuint>
			base = 16;
  800797:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079c:	83 ec 0c             	sub    $0xc,%esp
  80079f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a3:	57                   	push   %edi
  8007a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a7:	51                   	push   %ecx
  8007a8:	52                   	push   %edx
  8007a9:	50                   	push   %eax
  8007aa:	89 da                	mov    %ebx,%edx
  8007ac:	89 f0                	mov    %esi,%eax
  8007ae:	e8 70 fb ff ff       	call   800323 <printnum>
			break;
  8007b3:	83 c4 20             	add    $0x20,%esp
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b9:	e9 ae fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	51                   	push   %ecx
  8007c3:	ff d6                	call   *%esi
			break;
  8007c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cb:	e9 9c fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	53                   	push   %ebx
  8007d4:	6a 25                	push   $0x25
  8007d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb 03                	jmp    8007e0 <vprintfmt+0x39a>
  8007dd:	83 ef 01             	sub    $0x1,%edi
  8007e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e4:	75 f7                	jne    8007dd <vprintfmt+0x397>
  8007e6:	e9 81 fc ff ff       	jmp    80046c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5f                   	pop    %edi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 18             	sub    $0x18,%esp
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800802:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800806:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800810:	85 c0                	test   %eax,%eax
  800812:	74 26                	je     80083a <vsnprintf+0x47>
  800814:	85 d2                	test   %edx,%edx
  800816:	7e 22                	jle    80083a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800818:	ff 75 14             	pushl  0x14(%ebp)
  80081b:	ff 75 10             	pushl  0x10(%ebp)
  80081e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	68 0c 04 80 00       	push   $0x80040c
  800827:	e8 1a fc ff ff       	call   800446 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	eb 05                	jmp    80083f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084a:	50                   	push   %eax
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 9a ff ff ff       	call   8007f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 03                	jmp    80086b <strlen+0x10>
		n++;
  800868:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086f:	75 f7                	jne    800868 <strlen+0xd>
		n++;
	return n;
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	ba 00 00 00 00       	mov    $0x0,%edx
  800881:	eb 03                	jmp    800886 <strnlen+0x13>
		n++;
  800883:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 08                	je     800892 <strnlen+0x1f>
  80088a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088e:	75 f3                	jne    800883 <strnlen+0x10>
  800890:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	83 c1 01             	add    $0x1,%ecx
  8008a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ad:	84 db                	test   %bl,%bl
  8008af:	75 ef                	jne    8008a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bb:	53                   	push   %ebx
  8008bc:	e8 9a ff ff ff       	call   80085b <strlen>
  8008c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c4:	ff 75 0c             	pushl  0xc(%ebp)
  8008c7:	01 d8                	add    %ebx,%eax
  8008c9:	50                   	push   %eax
  8008ca:	e8 c5 ff ff ff       	call   800894 <strcpy>
	return dst;
}
  8008cf:	89 d8                	mov    %ebx,%eax
  8008d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 75 08             	mov    0x8(%ebp),%esi
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	89 f3                	mov    %esi,%ebx
  8008e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e6:	89 f2                	mov    %esi,%edx
  8008e8:	eb 0f                	jmp    8008f9 <strncpy+0x23>
		*dst++ = *src;
  8008ea:	83 c2 01             	add    $0x1,%edx
  8008ed:	0f b6 01             	movzbl (%ecx),%eax
  8008f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f9:	39 da                	cmp    %ebx,%edx
  8008fb:	75 ed                	jne    8008ea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 75 08             	mov    0x8(%ebp),%esi
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090e:	8b 55 10             	mov    0x10(%ebp),%edx
  800911:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800913:	85 d2                	test   %edx,%edx
  800915:	74 21                	je     800938 <strlcpy+0x35>
  800917:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091b:	89 f2                	mov    %esi,%edx
  80091d:	eb 09                	jmp    800928 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091f:	83 c2 01             	add    $0x1,%edx
  800922:	83 c1 01             	add    $0x1,%ecx
  800925:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800928:	39 c2                	cmp    %eax,%edx
  80092a:	74 09                	je     800935 <strlcpy+0x32>
  80092c:	0f b6 19             	movzbl (%ecx),%ebx
  80092f:	84 db                	test   %bl,%bl
  800931:	75 ec                	jne    80091f <strlcpy+0x1c>
  800933:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800935:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800938:	29 f0                	sub    %esi,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800947:	eb 06                	jmp    80094f <strcmp+0x11>
		p++, q++;
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	84 c0                	test   %al,%al
  800954:	74 04                	je     80095a <strcmp+0x1c>
  800956:	3a 02                	cmp    (%edx),%al
  800958:	74 ef                	je     800949 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095a:	0f b6 c0             	movzbl %al,%eax
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	29 d0                	sub    %edx,%eax
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 c3                	mov    %eax,%ebx
  800970:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800973:	eb 06                	jmp    80097b <strncmp+0x17>
		n--, p++, q++;
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097b:	39 d8                	cmp    %ebx,%eax
  80097d:	74 15                	je     800994 <strncmp+0x30>
  80097f:	0f b6 08             	movzbl (%eax),%ecx
  800982:	84 c9                	test   %cl,%cl
  800984:	74 04                	je     80098a <strncmp+0x26>
  800986:	3a 0a                	cmp    (%edx),%cl
  800988:	74 eb                	je     800975 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098a:	0f b6 00             	movzbl (%eax),%eax
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	29 d0                	sub    %edx,%eax
  800992:	eb 05                	jmp    800999 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800999:	5b                   	pop    %ebx
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a6:	eb 07                	jmp    8009af <strchr+0x13>
		if (*s == c)
  8009a8:	38 ca                	cmp    %cl,%dl
  8009aa:	74 0f                	je     8009bb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	0f b6 10             	movzbl (%eax),%edx
  8009b2:	84 d2                	test   %dl,%dl
  8009b4:	75 f2                	jne    8009a8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c7:	eb 03                	jmp    8009cc <strfind+0xf>
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cf:	38 ca                	cmp    %cl,%dl
  8009d1:	74 04                	je     8009d7 <strfind+0x1a>
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	75 f2                	jne    8009c9 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	57                   	push   %edi
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e5:	85 c9                	test   %ecx,%ecx
  8009e7:	74 36                	je     800a1f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ef:	75 28                	jne    800a19 <memset+0x40>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 23                	jne    800a19 <memset+0x40>
		c &= 0xFF;
  8009f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fa:	89 d3                	mov    %edx,%ebx
  8009fc:	c1 e3 08             	shl    $0x8,%ebx
  8009ff:	89 d6                	mov    %edx,%esi
  800a01:	c1 e6 18             	shl    $0x18,%esi
  800a04:	89 d0                	mov    %edx,%eax
  800a06:	c1 e0 10             	shl    $0x10,%eax
  800a09:	09 f0                	or     %esi,%eax
  800a0b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a0d:	89 d8                	mov    %ebx,%eax
  800a0f:	09 d0                	or     %edx,%eax
  800a11:	c1 e9 02             	shr    $0x2,%ecx
  800a14:	fc                   	cld    
  800a15:	f3 ab                	rep stos %eax,%es:(%edi)
  800a17:	eb 06                	jmp    800a1f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	fc                   	cld    
  800a1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1f:	89 f8                	mov    %edi,%eax
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a34:	39 c6                	cmp    %eax,%esi
  800a36:	73 35                	jae    800a6d <memmove+0x47>
  800a38:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3b:	39 d0                	cmp    %edx,%eax
  800a3d:	73 2e                	jae    800a6d <memmove+0x47>
		s += n;
		d += n;
  800a3f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a42:	89 d6                	mov    %edx,%esi
  800a44:	09 fe                	or     %edi,%esi
  800a46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4c:	75 13                	jne    800a61 <memmove+0x3b>
  800a4e:	f6 c1 03             	test   $0x3,%cl
  800a51:	75 0e                	jne    800a61 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a53:	83 ef 04             	sub    $0x4,%edi
  800a56:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a59:	c1 e9 02             	shr    $0x2,%ecx
  800a5c:	fd                   	std    
  800a5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5f:	eb 09                	jmp    800a6a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a67:	fd                   	std    
  800a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6a:	fc                   	cld    
  800a6b:	eb 1d                	jmp    800a8a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6d:	89 f2                	mov    %esi,%edx
  800a6f:	09 c2                	or     %eax,%edx
  800a71:	f6 c2 03             	test   $0x3,%dl
  800a74:	75 0f                	jne    800a85 <memmove+0x5f>
  800a76:	f6 c1 03             	test   $0x3,%cl
  800a79:	75 0a                	jne    800a85 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a7b:	c1 e9 02             	shr    $0x2,%ecx
  800a7e:	89 c7                	mov    %eax,%edi
  800a80:	fc                   	cld    
  800a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a83:	eb 05                	jmp    800a8a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a85:	89 c7                	mov    %eax,%edi
  800a87:	fc                   	cld    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a91:	ff 75 10             	pushl  0x10(%ebp)
  800a94:	ff 75 0c             	pushl  0xc(%ebp)
  800a97:	ff 75 08             	pushl  0x8(%ebp)
  800a9a:	e8 87 ff ff ff       	call   800a26 <memmove>
}
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    

00800aa1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aac:	89 c6                	mov    %eax,%esi
  800aae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	eb 1a                	jmp    800acd <memcmp+0x2c>
		if (*s1 != *s2)
  800ab3:	0f b6 08             	movzbl (%eax),%ecx
  800ab6:	0f b6 1a             	movzbl (%edx),%ebx
  800ab9:	38 d9                	cmp    %bl,%cl
  800abb:	74 0a                	je     800ac7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800abd:	0f b6 c1             	movzbl %cl,%eax
  800ac0:	0f b6 db             	movzbl %bl,%ebx
  800ac3:	29 d8                	sub    %ebx,%eax
  800ac5:	eb 0f                	jmp    800ad6 <memcmp+0x35>
		s1++, s2++;
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acd:	39 f0                	cmp    %esi,%eax
  800acf:	75 e2                	jne    800ab3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	53                   	push   %ebx
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae1:	89 c1                	mov    %eax,%ecx
  800ae3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aea:	eb 0a                	jmp    800af6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aec:	0f b6 10             	movzbl (%eax),%edx
  800aef:	39 da                	cmp    %ebx,%edx
  800af1:	74 07                	je     800afa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	39 c8                	cmp    %ecx,%eax
  800af8:	72 f2                	jb     800aec <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800afa:	5b                   	pop    %ebx
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b09:	eb 03                	jmp    800b0e <strtol+0x11>
		s++;
  800b0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0e:	0f b6 01             	movzbl (%ecx),%eax
  800b11:	3c 20                	cmp    $0x20,%al
  800b13:	74 f6                	je     800b0b <strtol+0xe>
  800b15:	3c 09                	cmp    $0x9,%al
  800b17:	74 f2                	je     800b0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b19:	3c 2b                	cmp    $0x2b,%al
  800b1b:	75 0a                	jne    800b27 <strtol+0x2a>
		s++;
  800b1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
  800b25:	eb 11                	jmp    800b38 <strtol+0x3b>
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b2c:	3c 2d                	cmp    $0x2d,%al
  800b2e:	75 08                	jne    800b38 <strtol+0x3b>
		s++, neg = 1;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3e:	75 15                	jne    800b55 <strtol+0x58>
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 10                	jne    800b55 <strtol+0x58>
  800b45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b49:	75 7c                	jne    800bc7 <strtol+0xca>
		s += 2, base = 16;
  800b4b:	83 c1 02             	add    $0x2,%ecx
  800b4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b53:	eb 16                	jmp    800b6b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	75 12                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b61:	75 08                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
  800b63:	83 c1 01             	add    $0x1,%ecx
  800b66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b73:	0f b6 11             	movzbl (%ecx),%edx
  800b76:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	80 fb 09             	cmp    $0x9,%bl
  800b7e:	77 08                	ja     800b88 <strtol+0x8b>
			dig = *s - '0';
  800b80:	0f be d2             	movsbl %dl,%edx
  800b83:	83 ea 30             	sub    $0x30,%edx
  800b86:	eb 22                	jmp    800baa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8b:	89 f3                	mov    %esi,%ebx
  800b8d:	80 fb 19             	cmp    $0x19,%bl
  800b90:	77 08                	ja     800b9a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b92:	0f be d2             	movsbl %dl,%edx
  800b95:	83 ea 57             	sub    $0x57,%edx
  800b98:	eb 10                	jmp    800baa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 19             	cmp    $0x19,%bl
  800ba2:	77 16                	ja     800bba <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba4:	0f be d2             	movsbl %dl,%edx
  800ba7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800baa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bad:	7d 0b                	jge    800bba <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800baf:	83 c1 01             	add    $0x1,%ecx
  800bb2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb8:	eb b9                	jmp    800b73 <strtol+0x76>

	if (endptr)
  800bba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbe:	74 0d                	je     800bcd <strtol+0xd0>
		*endptr = (char *) s;
  800bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc3:	89 0e                	mov    %ecx,(%esi)
  800bc5:	eb 06                	jmp    800bcd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc7:	85 db                	test   %ebx,%ebx
  800bc9:	74 98                	je     800b63 <strtol+0x66>
  800bcb:	eb 9e                	jmp    800b6b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	f7 da                	neg    %edx
  800bd1:	85 ff                	test   %edi,%edi
  800bd3:	0f 45 c2             	cmovne %edx,%eax
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	89 c3                	mov    %eax,%ebx
  800bee:	89 c7                	mov    %eax,%edi
  800bf0:	89 c6                	mov    %eax,%esi
  800bf2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	ba 00 00 00 00       	mov    $0x0,%edx
  800c04:	b8 01 00 00 00       	mov    $0x1,%eax
  800c09:	89 d1                	mov    %edx,%ecx
  800c0b:	89 d3                	mov    %edx,%ebx
  800c0d:	89 d7                	mov    %edx,%edi
  800c0f:	89 d6                	mov    %edx,%esi
  800c11:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c26:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 cb                	mov    %ecx,%ebx
  800c30:	89 cf                	mov    %ecx,%edi
  800c32:	89 ce                	mov    %ecx,%esi
  800c34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c36:	85 c0                	test   %eax,%eax
  800c38:	7e 17                	jle    800c51 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	50                   	push   %eax
  800c3e:	6a 03                	push   $0x3
  800c40:	68 df 26 80 00       	push   $0x8026df
  800c45:	6a 23                	push   $0x23
  800c47:	68 fc 26 80 00       	push   $0x8026fc
  800c4c:	e8 e5 f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c64:	b8 02 00 00 00       	mov    $0x2,%eax
  800c69:	89 d1                	mov    %edx,%ecx
  800c6b:	89 d3                	mov    %edx,%ebx
  800c6d:	89 d7                	mov    %edx,%edi
  800c6f:	89 d6                	mov    %edx,%esi
  800c71:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_yield>:

void
sys_yield(void)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c88:	89 d1                	mov    %edx,%ecx
  800c8a:	89 d3                	mov    %edx,%ebx
  800c8c:	89 d7                	mov    %edx,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	be 00 00 00 00       	mov    $0x0,%esi
  800ca5:	b8 04 00 00 00       	mov    $0x4,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb3:	89 f7                	mov    %esi,%edi
  800cb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 04                	push   $0x4
  800cc1:	68 df 26 80 00       	push   $0x8026df
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 fc 26 80 00       	push   $0x8026fc
  800ccd:	e8 64 f5 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf4:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 05                	push   $0x5
  800d03:	68 df 26 80 00       	push   $0x8026df
  800d08:	6a 23                	push   $0x23
  800d0a:	68 fc 26 80 00       	push   $0x8026fc
  800d0f:	e8 22 f5 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 06                	push   $0x6
  800d45:	68 df 26 80 00       	push   $0x8026df
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 fc 26 80 00       	push   $0x8026fc
  800d51:	e8 e0 f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 08                	push   $0x8
  800d87:	68 df 26 80 00       	push   $0x8026df
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 fc 26 80 00       	push   $0x8026fc
  800d93:	e8 9e f4 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 09 00 00 00       	mov    $0x9,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 09                	push   $0x9
  800dc9:	68 df 26 80 00       	push   $0x8026df
  800dce:	6a 23                	push   $0x23
  800dd0:	68 fc 26 80 00       	push   $0x8026fc
  800dd5:	e8 5c f4 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7e 17                	jle    800e1c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 0a                	push   $0xa
  800e0b:	68 df 26 80 00       	push   $0x8026df
  800e10:	6a 23                	push   $0x23
  800e12:	68 fc 26 80 00       	push   $0x8026fc
  800e17:	e8 1a f4 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	be 00 00 00 00       	mov    $0x0,%esi
  800e2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e55:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 cb                	mov    %ecx,%ebx
  800e5f:	89 cf                	mov    %ecx,%edi
  800e61:	89 ce                	mov    %ecx,%esi
  800e63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 17                	jle    800e80 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	83 ec 0c             	sub    $0xc,%esp
  800e6c:	50                   	push   %eax
  800e6d:	6a 0d                	push   $0xd
  800e6f:	68 df 26 80 00       	push   $0x8026df
  800e74:	6a 23                	push   $0x23
  800e76:	68 fc 26 80 00       	push   $0x8026fc
  800e7b:	e8 b6 f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  800e92:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  800e94:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  800e97:	89 da                	mov    %ebx,%edx
  800e99:	c1 ea 0c             	shr    $0xc,%edx
  800e9c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  800ea3:	a8 02                	test   $0x2,%al
  800ea5:	75 12                	jne    800eb9 <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  800ea7:	50                   	push   %eax
  800ea8:	68 0c 27 80 00       	push   $0x80270c
  800ead:	6a 21                	push   $0x21
  800eaf:	68 2d 27 80 00       	push   $0x80272d
  800eb4:	e8 7d f3 ff ff       	call   800236 <_panic>
	   } else if (!(pte & PTE_COW)) {
  800eb9:	f6 c6 08             	test   $0x8,%dh
  800ebc:	75 14                	jne    800ed2 <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	68 38 27 80 00       	push   $0x802738
  800ec6:	6a 23                	push   $0x23
  800ec8:	68 2d 27 80 00       	push   $0x80272d
  800ecd:	e8 64 f3 ff ff       	call   800236 <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  800ed2:	83 ec 04             	sub    $0x4,%esp
  800ed5:	6a 07                	push   $0x7
  800ed7:	68 00 00 40 00       	push   $0x400000
  800edc:	6a 00                	push   $0x0
  800ede:	e8 b4 fd ff ff       	call   800c97 <sys_page_alloc>
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	79 12                	jns    800efc <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  800eea:	50                   	push   %eax
  800eeb:	68 55 27 80 00       	push   $0x802755
  800ef0:	6a 2e                	push   $0x2e
  800ef2:	68 2d 27 80 00       	push   $0x80272d
  800ef7:	e8 3a f3 ff ff       	call   800236 <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800efc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	68 00 10 00 00       	push   $0x1000
  800f0a:	53                   	push   %ebx
  800f0b:	68 00 00 40 00       	push   $0x400000
  800f10:	e8 11 fb ff ff       	call   800a26 <memmove>
	   if ((r = sys_page_map(0,
  800f15:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f1c:	53                   	push   %ebx
  800f1d:	6a 00                	push   $0x0
  800f1f:	68 00 00 40 00       	push   $0x400000
  800f24:	6a 00                	push   $0x0
  800f26:	e8 af fd ff ff       	call   800cda <sys_page_map>
  800f2b:	83 c4 20             	add    $0x20,%esp
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	79 12                	jns    800f44 <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  800f32:	50                   	push   %eax
  800f33:	68 68 27 80 00       	push   $0x802768
  800f38:	6a 36                	push   $0x36
  800f3a:	68 2d 27 80 00       	push   $0x80272d
  800f3f:	e8 f2 f2 ff ff       	call   800236 <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	68 00 00 40 00       	push   $0x400000
  800f4c:	6a 00                	push   $0x0
  800f4e:	e8 c9 fd ff ff       	call   800d1c <sys_page_unmap>
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	79 12                	jns    800f6c <pgfault+0xe4>
			 panic("unmap %e", r);
  800f5a:	50                   	push   %eax
  800f5b:	68 78 27 80 00       	push   $0x802778
  800f60:	6a 39                	push   $0x39
  800f62:	68 2d 27 80 00       	push   $0x80272d
  800f67:	e8 ca f2 ff ff       	call   800236 <_panic>
	   }
}
  800f6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  800f7a:	68 88 0e 80 00       	push   $0x800e88
  800f7f:	e8 1f 0f 00 00       	call   801ea3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f84:	b8 07 00 00 00       	mov    $0x7,%eax
  800f89:	cd 30                	int    $0x30
  800f8b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f8e:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	79 15                	jns    800fad <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  800f98:	50                   	push   %eax
  800f99:	68 81 27 80 00       	push   $0x802781
  800f9e:	68 81 00 00 00       	push   $0x81
  800fa3:	68 2d 27 80 00       	push   $0x80272d
  800fa8:	e8 89 f2 ff ff       	call   800236 <_panic>
  800fad:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800fb4:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  800fb8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800fbc:	75 1c                	jne    800fda <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  800fbe:	e8 96 fc ff ff       	call   800c59 <sys_getenvid>
  800fc3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fcb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fd0:	a3 04 40 80 00       	mov    %eax,0x804004
			 return envid;
  800fd5:	e9 71 01 00 00       	jmp    80114b <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  800fda:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800fdd:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800fe4:	a8 01                	test   $0x1,%al
  800fe6:	0f 84 18 01 00 00    	je     801104 <fork+0x193>
  800fec:	89 fb                	mov    %edi,%ebx
  800fee:	c1 e3 0a             	shl    $0xa,%ebx
  800ff1:	c1 e7 16             	shl    $0x16,%edi
  800ff4:	be 00 00 00 00       	mov    $0x0,%esi
  800ff9:	e9 f4 00 00 00       	jmp    8010f2 <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  800ffe:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801004:	0f 84 dc 00 00 00    	je     8010e6 <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  80100a:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801010:	0f 87 cc 00 00 00    	ja     8010e2 <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  801016:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80101d:	a8 01                	test   $0x1,%al
  80101f:	0f 84 c1 00 00 00    	je     8010e6 <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  801025:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  80102c:	a9 02 08 00 00       	test   $0x802,%eax
  801031:	74 05                	je     801038 <fork+0xc7>
  801033:	f6 c4 04             	test   $0x4,%ah
  801036:	74 3a                	je     801072 <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  801038:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80103e:	8b 52 48             	mov    0x48(%edx),%edx
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	25 07 0e 00 00       	and    $0xe07,%eax
  801049:	50                   	push   %eax
  80104a:	57                   	push   %edi
  80104b:	ff 75 dc             	pushl  -0x24(%ebp)
  80104e:	57                   	push   %edi
  80104f:	52                   	push   %edx
  801050:	e8 85 fc ff ff       	call   800cda <sys_page_map>
  801055:	83 c4 20             	add    $0x20,%esp
  801058:	85 c0                	test   %eax,%eax
  80105a:	0f 89 86 00 00 00    	jns    8010e6 <fork+0x175>
				    panic("sys_page_map: %e", r);
  801060:	50                   	push   %eax
  801061:	68 91 27 80 00       	push   $0x802791
  801066:	6a 52                	push   $0x52
  801068:	68 2d 27 80 00       	push   $0x80272d
  80106d:	e8 c4 f1 ff ff       	call   800236 <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  801072:	25 05 06 00 00       	and    $0x605,%eax
  801077:	80 cc 08             	or     $0x8,%ah
  80107a:	89 c1                	mov    %eax,%ecx
  80107c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80107f:	a1 04 40 80 00       	mov    0x804004,%eax
  801084:	8b 40 48             	mov    0x48(%eax),%eax
  801087:	83 ec 0c             	sub    $0xc,%esp
  80108a:	51                   	push   %ecx
  80108b:	57                   	push   %edi
  80108c:	ff 75 dc             	pushl  -0x24(%ebp)
  80108f:	57                   	push   %edi
  801090:	50                   	push   %eax
  801091:	e8 44 fc ff ff       	call   800cda <sys_page_map>
  801096:	83 c4 20             	add    $0x20,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	79 12                	jns    8010af <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  80109d:	50                   	push   %eax
  80109e:	68 91 27 80 00       	push   $0x802791
  8010a3:	6a 5d                	push   $0x5d
  8010a5:	68 2d 27 80 00       	push   $0x80272d
  8010aa:	e8 87 f1 ff ff       	call   800236 <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  8010af:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b4:	8b 50 48             	mov    0x48(%eax),%edx
  8010b7:	8b 40 48             	mov    0x48(%eax),%eax
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c0:	57                   	push   %edi
  8010c1:	52                   	push   %edx
  8010c2:	57                   	push   %edi
  8010c3:	50                   	push   %eax
  8010c4:	e8 11 fc ff ff       	call   800cda <sys_page_map>
  8010c9:	83 c4 20             	add    $0x20,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	79 16                	jns    8010e6 <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  8010d0:	50                   	push   %eax
  8010d1:	68 91 27 80 00       	push   $0x802791
  8010d6:	6a 63                	push   $0x63
  8010d8:	68 2d 27 80 00       	push   $0x80272d
  8010dd:	e8 54 f1 ff ff       	call   800236 <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  8010e2:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  8010e6:	83 c6 01             	add    $0x1,%esi
  8010e9:	83 c3 01             	add    $0x1,%ebx
  8010ec:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8010f2:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  8010f8:	7f 0a                	jg     801104 <fork+0x193>
  8010fa:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8010fe:	0f 85 fa fe ff ff    	jne    800ffe <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  801104:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  801108:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80110b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801110:	7f 0a                	jg     80111c <fork+0x1ab>
  801112:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801116:	0f 85 be fe ff ff    	jne    800fda <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	68 fc 1e 80 00       	push   $0x801efc
  801124:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801127:	56                   	push   %esi
  801128:	e8 b5 fc ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  80112d:	83 c4 0c             	add    $0xc,%esp
  801130:	6a 06                	push   $0x6
  801132:	68 00 f0 bf ee       	push   $0xeebff000
  801137:	56                   	push   %esi
  801138:	e8 5a fb ff ff       	call   800c97 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  80113d:	83 c4 08             	add    $0x8,%esp
  801140:	6a 02                	push   $0x2
  801142:	56                   	push   %esi
  801143:	e8 16 fc ff ff       	call   800d5e <sys_env_set_status>

	   return envid;
  801148:	83 c4 10             	add    $0x10,%esp
}
  80114b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <sfork>:
// Challenge!
	   int
sfork(void)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  80115c:	68 a2 27 80 00       	push   $0x8027a2
  801161:	68 a7 00 00 00       	push   $0xa7
  801166:	68 2d 27 80 00       	push   $0x80272d
  80116b:	e8 c6 f0 ff ff       	call   800236 <_panic>

00801170 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	05 00 00 00 30       	add    $0x30000000,%eax
  80117b:	c1 e8 0c             	shr    $0xc,%eax
}
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801183:	8b 45 08             	mov    0x8(%ebp),%eax
  801186:	05 00 00 00 30       	add    $0x30000000,%eax
  80118b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801190:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a2:	89 c2                	mov    %eax,%edx
  8011a4:	c1 ea 16             	shr    $0x16,%edx
  8011a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ae:	f6 c2 01             	test   $0x1,%dl
  8011b1:	74 11                	je     8011c4 <fd_alloc+0x2d>
  8011b3:	89 c2                	mov    %eax,%edx
  8011b5:	c1 ea 0c             	shr    $0xc,%edx
  8011b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011bf:	f6 c2 01             	test   $0x1,%dl
  8011c2:	75 09                	jne    8011cd <fd_alloc+0x36>
			*fd_store = fd;
  8011c4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cb:	eb 17                	jmp    8011e4 <fd_alloc+0x4d>
  8011cd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d7:	75 c9                	jne    8011a2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011d9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011df:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    

008011e6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011ec:	83 f8 1f             	cmp    $0x1f,%eax
  8011ef:	77 36                	ja     801227 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f1:	c1 e0 0c             	shl    $0xc,%eax
  8011f4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	c1 ea 16             	shr    $0x16,%edx
  8011fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801205:	f6 c2 01             	test   $0x1,%dl
  801208:	74 24                	je     80122e <fd_lookup+0x48>
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	c1 ea 0c             	shr    $0xc,%edx
  80120f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801216:	f6 c2 01             	test   $0x1,%dl
  801219:	74 1a                	je     801235 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80121b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121e:	89 02                	mov    %eax,(%edx)
	return 0;
  801220:	b8 00 00 00 00       	mov    $0x0,%eax
  801225:	eb 13                	jmp    80123a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801227:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122c:	eb 0c                	jmp    80123a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801233:	eb 05                	jmp    80123a <fd_lookup+0x54>
  801235:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	83 ec 08             	sub    $0x8,%esp
  801242:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801245:	ba 38 28 80 00       	mov    $0x802838,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80124a:	eb 13                	jmp    80125f <dev_lookup+0x23>
  80124c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80124f:	39 08                	cmp    %ecx,(%eax)
  801251:	75 0c                	jne    80125f <dev_lookup+0x23>
			*dev = devtab[i];
  801253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801256:	89 01                	mov    %eax,(%ecx)
			return 0;
  801258:	b8 00 00 00 00       	mov    $0x0,%eax
  80125d:	eb 2e                	jmp    80128d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80125f:	8b 02                	mov    (%edx),%eax
  801261:	85 c0                	test   %eax,%eax
  801263:	75 e7                	jne    80124c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801265:	a1 04 40 80 00       	mov    0x804004,%eax
  80126a:	8b 40 48             	mov    0x48(%eax),%eax
  80126d:	83 ec 04             	sub    $0x4,%esp
  801270:	51                   	push   %ecx
  801271:	50                   	push   %eax
  801272:	68 b8 27 80 00       	push   $0x8027b8
  801277:	e8 93 f0 ff ff       	call   80030f <cprintf>
	*dev = 0;
  80127c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80128d:	c9                   	leave  
  80128e:	c3                   	ret    

0080128f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	56                   	push   %esi
  801293:	53                   	push   %ebx
  801294:	83 ec 10             	sub    $0x10,%esp
  801297:	8b 75 08             	mov    0x8(%ebp),%esi
  80129a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80129d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a0:	50                   	push   %eax
  8012a1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012a7:	c1 e8 0c             	shr    $0xc,%eax
  8012aa:	50                   	push   %eax
  8012ab:	e8 36 ff ff ff       	call   8011e6 <fd_lookup>
  8012b0:	83 c4 08             	add    $0x8,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 05                	js     8012bc <fd_close+0x2d>
	    || fd != fd2)
  8012b7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012ba:	74 0c                	je     8012c8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012bc:	84 db                	test   %bl,%bl
  8012be:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c3:	0f 44 c2             	cmove  %edx,%eax
  8012c6:	eb 41                	jmp    801309 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ce:	50                   	push   %eax
  8012cf:	ff 36                	pushl  (%esi)
  8012d1:	e8 66 ff ff ff       	call   80123c <dev_lookup>
  8012d6:	89 c3                	mov    %eax,%ebx
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 1a                	js     8012f9 <fd_close+0x6a>
		if (dev->dev_close)
  8012df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012e5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	74 0b                	je     8012f9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ee:	83 ec 0c             	sub    $0xc,%esp
  8012f1:	56                   	push   %esi
  8012f2:	ff d0                	call   *%eax
  8012f4:	89 c3                	mov    %eax,%ebx
  8012f6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	56                   	push   %esi
  8012fd:	6a 00                	push   $0x0
  8012ff:	e8 18 fa ff ff       	call   800d1c <sys_page_unmap>
	return r;
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	89 d8                	mov    %ebx,%eax
}
  801309:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130c:	5b                   	pop    %ebx
  80130d:	5e                   	pop    %esi
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    

00801310 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801316:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801319:	50                   	push   %eax
  80131a:	ff 75 08             	pushl  0x8(%ebp)
  80131d:	e8 c4 fe ff ff       	call   8011e6 <fd_lookup>
  801322:	83 c4 08             	add    $0x8,%esp
  801325:	85 c0                	test   %eax,%eax
  801327:	78 10                	js     801339 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	6a 01                	push   $0x1
  80132e:	ff 75 f4             	pushl  -0xc(%ebp)
  801331:	e8 59 ff ff ff       	call   80128f <fd_close>
  801336:	83 c4 10             	add    $0x10,%esp
}
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <close_all>:

void
close_all(void)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	53                   	push   %ebx
  80133f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801342:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801347:	83 ec 0c             	sub    $0xc,%esp
  80134a:	53                   	push   %ebx
  80134b:	e8 c0 ff ff ff       	call   801310 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801350:	83 c3 01             	add    $0x1,%ebx
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	83 fb 20             	cmp    $0x20,%ebx
  801359:	75 ec                	jne    801347 <close_all+0xc>
		close(i);
}
  80135b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135e:	c9                   	leave  
  80135f:	c3                   	ret    

00801360 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	57                   	push   %edi
  801364:	56                   	push   %esi
  801365:	53                   	push   %ebx
  801366:	83 ec 2c             	sub    $0x2c,%esp
  801369:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80136c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80136f:	50                   	push   %eax
  801370:	ff 75 08             	pushl  0x8(%ebp)
  801373:	e8 6e fe ff ff       	call   8011e6 <fd_lookup>
  801378:	83 c4 08             	add    $0x8,%esp
  80137b:	85 c0                	test   %eax,%eax
  80137d:	0f 88 c1 00 00 00    	js     801444 <dup+0xe4>
		return r;
	close(newfdnum);
  801383:	83 ec 0c             	sub    $0xc,%esp
  801386:	56                   	push   %esi
  801387:	e8 84 ff ff ff       	call   801310 <close>

	newfd = INDEX2FD(newfdnum);
  80138c:	89 f3                	mov    %esi,%ebx
  80138e:	c1 e3 0c             	shl    $0xc,%ebx
  801391:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801397:	83 c4 04             	add    $0x4,%esp
  80139a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80139d:	e8 de fd ff ff       	call   801180 <fd2data>
  8013a2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013a4:	89 1c 24             	mov    %ebx,(%esp)
  8013a7:	e8 d4 fd ff ff       	call   801180 <fd2data>
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013b2:	89 f8                	mov    %edi,%eax
  8013b4:	c1 e8 16             	shr    $0x16,%eax
  8013b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013be:	a8 01                	test   $0x1,%al
  8013c0:	74 37                	je     8013f9 <dup+0x99>
  8013c2:	89 f8                	mov    %edi,%eax
  8013c4:	c1 e8 0c             	shr    $0xc,%eax
  8013c7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ce:	f6 c2 01             	test   $0x1,%dl
  8013d1:	74 26                	je     8013f9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013da:	83 ec 0c             	sub    $0xc,%esp
  8013dd:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e2:	50                   	push   %eax
  8013e3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013e6:	6a 00                	push   $0x0
  8013e8:	57                   	push   %edi
  8013e9:	6a 00                	push   $0x0
  8013eb:	e8 ea f8 ff ff       	call   800cda <sys_page_map>
  8013f0:	89 c7                	mov    %eax,%edi
  8013f2:	83 c4 20             	add    $0x20,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 2e                	js     801427 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013fc:	89 d0                	mov    %edx,%eax
  8013fe:	c1 e8 0c             	shr    $0xc,%eax
  801401:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801408:	83 ec 0c             	sub    $0xc,%esp
  80140b:	25 07 0e 00 00       	and    $0xe07,%eax
  801410:	50                   	push   %eax
  801411:	53                   	push   %ebx
  801412:	6a 00                	push   $0x0
  801414:	52                   	push   %edx
  801415:	6a 00                	push   $0x0
  801417:	e8 be f8 ff ff       	call   800cda <sys_page_map>
  80141c:	89 c7                	mov    %eax,%edi
  80141e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801421:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801423:	85 ff                	test   %edi,%edi
  801425:	79 1d                	jns    801444 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	53                   	push   %ebx
  80142b:	6a 00                	push   $0x0
  80142d:	e8 ea f8 ff ff       	call   800d1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801432:	83 c4 08             	add    $0x8,%esp
  801435:	ff 75 d4             	pushl  -0x2c(%ebp)
  801438:	6a 00                	push   $0x0
  80143a:	e8 dd f8 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	89 f8                	mov    %edi,%eax
}
  801444:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801447:	5b                   	pop    %ebx
  801448:	5e                   	pop    %esi
  801449:	5f                   	pop    %edi
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    

0080144c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	53                   	push   %ebx
  801450:	83 ec 14             	sub    $0x14,%esp
  801453:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801456:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801459:	50                   	push   %eax
  80145a:	53                   	push   %ebx
  80145b:	e8 86 fd ff ff       	call   8011e6 <fd_lookup>
  801460:	83 c4 08             	add    $0x8,%esp
  801463:	89 c2                	mov    %eax,%edx
  801465:	85 c0                	test   %eax,%eax
  801467:	78 6d                	js     8014d6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801469:	83 ec 08             	sub    $0x8,%esp
  80146c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146f:	50                   	push   %eax
  801470:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801473:	ff 30                	pushl  (%eax)
  801475:	e8 c2 fd ff ff       	call   80123c <dev_lookup>
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	85 c0                	test   %eax,%eax
  80147f:	78 4c                	js     8014cd <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801481:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801484:	8b 42 08             	mov    0x8(%edx),%eax
  801487:	83 e0 03             	and    $0x3,%eax
  80148a:	83 f8 01             	cmp    $0x1,%eax
  80148d:	75 21                	jne    8014b0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80148f:	a1 04 40 80 00       	mov    0x804004,%eax
  801494:	8b 40 48             	mov    0x48(%eax),%eax
  801497:	83 ec 04             	sub    $0x4,%esp
  80149a:	53                   	push   %ebx
  80149b:	50                   	push   %eax
  80149c:	68 fc 27 80 00       	push   $0x8027fc
  8014a1:	e8 69 ee ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ae:	eb 26                	jmp    8014d6 <read+0x8a>
	}
	if (!dev->dev_read)
  8014b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b3:	8b 40 08             	mov    0x8(%eax),%eax
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	74 17                	je     8014d1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	ff 75 10             	pushl  0x10(%ebp)
  8014c0:	ff 75 0c             	pushl  0xc(%ebp)
  8014c3:	52                   	push   %edx
  8014c4:	ff d0                	call   *%eax
  8014c6:	89 c2                	mov    %eax,%edx
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	eb 09                	jmp    8014d6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cd:	89 c2                	mov    %eax,%edx
  8014cf:	eb 05                	jmp    8014d6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014d6:	89 d0                	mov    %edx,%eax
  8014d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	57                   	push   %edi
  8014e1:	56                   	push   %esi
  8014e2:	53                   	push   %ebx
  8014e3:	83 ec 0c             	sub    $0xc,%esp
  8014e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f1:	eb 21                	jmp    801514 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f3:	83 ec 04             	sub    $0x4,%esp
  8014f6:	89 f0                	mov    %esi,%eax
  8014f8:	29 d8                	sub    %ebx,%eax
  8014fa:	50                   	push   %eax
  8014fb:	89 d8                	mov    %ebx,%eax
  8014fd:	03 45 0c             	add    0xc(%ebp),%eax
  801500:	50                   	push   %eax
  801501:	57                   	push   %edi
  801502:	e8 45 ff ff ff       	call   80144c <read>
		if (m < 0)
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 10                	js     80151e <readn+0x41>
			return m;
		if (m == 0)
  80150e:	85 c0                	test   %eax,%eax
  801510:	74 0a                	je     80151c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801512:	01 c3                	add    %eax,%ebx
  801514:	39 f3                	cmp    %esi,%ebx
  801516:	72 db                	jb     8014f3 <readn+0x16>
  801518:	89 d8                	mov    %ebx,%eax
  80151a:	eb 02                	jmp    80151e <readn+0x41>
  80151c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80151e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801521:	5b                   	pop    %ebx
  801522:	5e                   	pop    %esi
  801523:	5f                   	pop    %edi
  801524:	5d                   	pop    %ebp
  801525:	c3                   	ret    

00801526 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	53                   	push   %ebx
  80152a:	83 ec 14             	sub    $0x14,%esp
  80152d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801530:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801533:	50                   	push   %eax
  801534:	53                   	push   %ebx
  801535:	e8 ac fc ff ff       	call   8011e6 <fd_lookup>
  80153a:	83 c4 08             	add    $0x8,%esp
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 68                	js     8015ab <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154d:	ff 30                	pushl  (%eax)
  80154f:	e8 e8 fc ff ff       	call   80123c <dev_lookup>
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 47                	js     8015a2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80155b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801562:	75 21                	jne    801585 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801564:	a1 04 40 80 00       	mov    0x804004,%eax
  801569:	8b 40 48             	mov    0x48(%eax),%eax
  80156c:	83 ec 04             	sub    $0x4,%esp
  80156f:	53                   	push   %ebx
  801570:	50                   	push   %eax
  801571:	68 18 28 80 00       	push   $0x802818
  801576:	e8 94 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801583:	eb 26                	jmp    8015ab <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801585:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801588:	8b 52 0c             	mov    0xc(%edx),%edx
  80158b:	85 d2                	test   %edx,%edx
  80158d:	74 17                	je     8015a6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80158f:	83 ec 04             	sub    $0x4,%esp
  801592:	ff 75 10             	pushl  0x10(%ebp)
  801595:	ff 75 0c             	pushl  0xc(%ebp)
  801598:	50                   	push   %eax
  801599:	ff d2                	call   *%edx
  80159b:	89 c2                	mov    %eax,%edx
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	eb 09                	jmp    8015ab <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a2:	89 c2                	mov    %eax,%edx
  8015a4:	eb 05                	jmp    8015ab <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015ab:	89 d0                	mov    %edx,%eax
  8015ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    

008015b2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015bb:	50                   	push   %eax
  8015bc:	ff 75 08             	pushl  0x8(%ebp)
  8015bf:	e8 22 fc ff ff       	call   8011e6 <fd_lookup>
  8015c4:	83 c4 08             	add    $0x8,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 0e                	js     8015d9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	53                   	push   %ebx
  8015df:	83 ec 14             	sub    $0x14,%esp
  8015e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	53                   	push   %ebx
  8015ea:	e8 f7 fb ff ff       	call   8011e6 <fd_lookup>
  8015ef:	83 c4 08             	add    $0x8,%esp
  8015f2:	89 c2                	mov    %eax,%edx
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 65                	js     80165d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fe:	50                   	push   %eax
  8015ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801602:	ff 30                	pushl  (%eax)
  801604:	e8 33 fc ff ff       	call   80123c <dev_lookup>
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 44                	js     801654 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801610:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801613:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801617:	75 21                	jne    80163a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801619:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80161e:	8b 40 48             	mov    0x48(%eax),%eax
  801621:	83 ec 04             	sub    $0x4,%esp
  801624:	53                   	push   %ebx
  801625:	50                   	push   %eax
  801626:	68 d8 27 80 00       	push   $0x8027d8
  80162b:	e8 df ec ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801638:	eb 23                	jmp    80165d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80163a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163d:	8b 52 18             	mov    0x18(%edx),%edx
  801640:	85 d2                	test   %edx,%edx
  801642:	74 14                	je     801658 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	ff 75 0c             	pushl  0xc(%ebp)
  80164a:	50                   	push   %eax
  80164b:	ff d2                	call   *%edx
  80164d:	89 c2                	mov    %eax,%edx
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	eb 09                	jmp    80165d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801654:	89 c2                	mov    %eax,%edx
  801656:	eb 05                	jmp    80165d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801658:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80165d:	89 d0                	mov    %edx,%eax
  80165f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801662:	c9                   	leave  
  801663:	c3                   	ret    

00801664 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	53                   	push   %ebx
  801668:	83 ec 14             	sub    $0x14,%esp
  80166b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801671:	50                   	push   %eax
  801672:	ff 75 08             	pushl  0x8(%ebp)
  801675:	e8 6c fb ff ff       	call   8011e6 <fd_lookup>
  80167a:	83 c4 08             	add    $0x8,%esp
  80167d:	89 c2                	mov    %eax,%edx
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 58                	js     8016db <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801683:	83 ec 08             	sub    $0x8,%esp
  801686:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801689:	50                   	push   %eax
  80168a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168d:	ff 30                	pushl  (%eax)
  80168f:	e8 a8 fb ff ff       	call   80123c <dev_lookup>
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	85 c0                	test   %eax,%eax
  801699:	78 37                	js     8016d2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80169b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016a2:	74 32                	je     8016d6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ae:	00 00 00 
	stat->st_isdir = 0;
  8016b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b8:	00 00 00 
	stat->st_dev = dev;
  8016bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c1:	83 ec 08             	sub    $0x8,%esp
  8016c4:	53                   	push   %ebx
  8016c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8016c8:	ff 50 14             	call   *0x14(%eax)
  8016cb:	89 c2                	mov    %eax,%edx
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	eb 09                	jmp    8016db <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d2:	89 c2                	mov    %eax,%edx
  8016d4:	eb 05                	jmp    8016db <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016db:	89 d0                	mov    %edx,%eax
  8016dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	6a 00                	push   $0x0
  8016ec:	ff 75 08             	pushl  0x8(%ebp)
  8016ef:	e8 2c 02 00 00       	call   801920 <open>
  8016f4:	89 c3                	mov    %eax,%ebx
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 1b                	js     801718 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	ff 75 0c             	pushl  0xc(%ebp)
  801703:	50                   	push   %eax
  801704:	e8 5b ff ff ff       	call   801664 <fstat>
  801709:	89 c6                	mov    %eax,%esi
	close(fd);
  80170b:	89 1c 24             	mov    %ebx,(%esp)
  80170e:	e8 fd fb ff ff       	call   801310 <close>
	return r;
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	89 f0                	mov    %esi,%eax
}
  801718:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171b:	5b                   	pop    %ebx
  80171c:	5e                   	pop    %esi
  80171d:	5d                   	pop    %ebp
  80171e:	c3                   	ret    

0080171f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	89 c6                	mov    %eax,%esi
  801726:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  801728:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80172f:	75 12                	jne    801743 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  801731:	83 ec 0c             	sub    $0xc,%esp
  801734:	6a 01                	push   $0x1
  801736:	e8 9a 08 00 00       	call   801fd5 <ipc_find_env>
  80173b:	a3 00 40 80 00       	mov    %eax,0x804000
  801740:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801743:	6a 07                	push   $0x7
  801745:	68 00 50 80 00       	push   $0x805000
  80174a:	56                   	push   %esi
  80174b:	ff 35 00 40 80 00    	pushl  0x804000
  801751:	e8 2b 08 00 00       	call   801f81 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  801756:	83 c4 0c             	add    $0xc,%esp
  801759:	6a 00                	push   $0x0
  80175b:	53                   	push   %ebx
  80175c:	6a 00                	push   $0x0
  80175e:	e8 bf 07 00 00       	call   801f22 <ipc_recv>
}
  801763:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801770:	8b 45 08             	mov    0x8(%ebp),%eax
  801773:	8b 40 0c             	mov    0xc(%eax),%eax
  801776:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  80177b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177e:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  801783:	ba 00 00 00 00       	mov    $0x0,%edx
  801788:	b8 02 00 00 00       	mov    $0x2,%eax
  80178d:	e8 8d ff ff ff       	call   80171f <fsipc>
}
  801792:	c9                   	leave  
  801793:	c3                   	ret    

00801794 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a0:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  8017a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8017af:	e8 6b ff ff ff       	call   80171f <fsipc>
}
  8017b4:	c9                   	leave  
  8017b5:	c3                   	ret    

008017b6 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	53                   	push   %ebx
  8017ba:	83 ec 04             	sub    $0x4,%esp
  8017bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c6:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d5:	e8 45 ff ff ff       	call   80171f <fsipc>
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	78 2c                	js     80180a <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017de:	83 ec 08             	sub    $0x8,%esp
  8017e1:	68 00 50 80 00       	push   $0x805000
  8017e6:	53                   	push   %ebx
  8017e7:	e8 a8 f0 ff ff       	call   800894 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8017ec:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f7:	a1 84 50 80 00       	mov    0x805084,%eax
  8017fc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	53                   	push   %ebx
  801813:	83 ec 08             	sub    $0x8,%esp
  801816:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	8b 40 0c             	mov    0xc(%eax),%eax
  80181f:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  801824:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  80182a:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801830:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801835:	0f 46 c3             	cmovbe %ebx,%eax
  801838:	50                   	push   %eax
  801839:	ff 75 0c             	pushl  0xc(%ebp)
  80183c:	68 08 50 80 00       	push   $0x805008
  801841:	e8 e0 f1 ff ff       	call   800a26 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  801846:	ba 00 00 00 00       	mov    $0x0,%edx
  80184b:	b8 04 00 00 00       	mov    $0x4,%eax
  801850:	e8 ca fe ff ff       	call   80171f <fsipc>
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	78 3d                	js     801899 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  80185c:	39 c3                	cmp    %eax,%ebx
  80185e:	73 19                	jae    801879 <devfile_write+0x6a>
  801860:	68 48 28 80 00       	push   $0x802848
  801865:	68 4f 28 80 00       	push   $0x80284f
  80186a:	68 9a 00 00 00       	push   $0x9a
  80186f:	68 64 28 80 00       	push   $0x802864
  801874:	e8 bd e9 ff ff       	call   800236 <_panic>
	   assert (r <= bytes_written);
  801879:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80187e:	7e 19                	jle    801899 <devfile_write+0x8a>
  801880:	68 6f 28 80 00       	push   $0x80286f
  801885:	68 4f 28 80 00       	push   $0x80284f
  80188a:	68 9b 00 00 00       	push   $0x9b
  80188f:	68 64 28 80 00       	push   $0x802864
  801894:	e8 9d e9 ff ff       	call   800236 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801899:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	56                   	push   %esi
  8018a2:	53                   	push   %ebx
  8018a3:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ac:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  8018b1:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bc:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c1:	e8 59 fe ff ff       	call   80171f <fsipc>
  8018c6:	89 c3                	mov    %eax,%ebx
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 4b                	js     801917 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  8018cc:	39 c6                	cmp    %eax,%esi
  8018ce:	73 16                	jae    8018e6 <devfile_read+0x48>
  8018d0:	68 48 28 80 00       	push   $0x802848
  8018d5:	68 4f 28 80 00       	push   $0x80284f
  8018da:	6a 7c                	push   $0x7c
  8018dc:	68 64 28 80 00       	push   $0x802864
  8018e1:	e8 50 e9 ff ff       	call   800236 <_panic>
	   assert(r <= PGSIZE);
  8018e6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018eb:	7e 16                	jle    801903 <devfile_read+0x65>
  8018ed:	68 82 28 80 00       	push   $0x802882
  8018f2:	68 4f 28 80 00       	push   $0x80284f
  8018f7:	6a 7d                	push   $0x7d
  8018f9:	68 64 28 80 00       	push   $0x802864
  8018fe:	e8 33 e9 ff ff       	call   800236 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801903:	83 ec 04             	sub    $0x4,%esp
  801906:	50                   	push   %eax
  801907:	68 00 50 80 00       	push   $0x805000
  80190c:	ff 75 0c             	pushl  0xc(%ebp)
  80190f:	e8 12 f1 ff ff       	call   800a26 <memmove>
	   return r;
  801914:	83 c4 10             	add    $0x10,%esp
}
  801917:	89 d8                	mov    %ebx,%eax
  801919:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191c:	5b                   	pop    %ebx
  80191d:	5e                   	pop    %esi
  80191e:	5d                   	pop    %ebp
  80191f:	c3                   	ret    

00801920 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	53                   	push   %ebx
  801924:	83 ec 20             	sub    $0x20,%esp
  801927:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  80192a:	53                   	push   %ebx
  80192b:	e8 2b ef ff ff       	call   80085b <strlen>
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801938:	7f 67                	jg     8019a1 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  80193a:	83 ec 0c             	sub    $0xc,%esp
  80193d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801940:	50                   	push   %eax
  801941:	e8 51 f8 ff ff       	call   801197 <fd_alloc>
  801946:	83 c4 10             	add    $0x10,%esp
			 return r;
  801949:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 57                	js     8019a6 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  80194f:	83 ec 08             	sub    $0x8,%esp
  801952:	53                   	push   %ebx
  801953:	68 00 50 80 00       	push   $0x805000
  801958:	e8 37 ef ff ff       	call   800894 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  80195d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801960:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801965:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801968:	b8 01 00 00 00       	mov    $0x1,%eax
  80196d:	e8 ad fd ff ff       	call   80171f <fsipc>
  801972:	89 c3                	mov    %eax,%ebx
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	85 c0                	test   %eax,%eax
  801979:	79 14                	jns    80198f <open+0x6f>
			 fd_close(fd, 0);
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	6a 00                	push   $0x0
  801980:	ff 75 f4             	pushl  -0xc(%ebp)
  801983:	e8 07 f9 ff ff       	call   80128f <fd_close>
			 return r;
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	89 da                	mov    %ebx,%edx
  80198d:	eb 17                	jmp    8019a6 <open+0x86>
	   }

	   return fd2num(fd);
  80198f:	83 ec 0c             	sub    $0xc,%esp
  801992:	ff 75 f4             	pushl  -0xc(%ebp)
  801995:	e8 d6 f7 ff ff       	call   801170 <fd2num>
  80199a:	89 c2                	mov    %eax,%edx
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	eb 05                	jmp    8019a6 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  8019a1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  8019a6:	89 d0                	mov    %edx,%eax
  8019a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ab:	c9                   	leave  
  8019ac:	c3                   	ret    

008019ad <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  8019b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b8:	b8 08 00 00 00       	mov    $0x8,%eax
  8019bd:	e8 5d fd ff ff       	call   80171f <fsipc>
}
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	56                   	push   %esi
  8019c8:	53                   	push   %ebx
  8019c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	ff 75 08             	pushl  0x8(%ebp)
  8019d2:	e8 a9 f7 ff ff       	call   801180 <fd2data>
  8019d7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019d9:	83 c4 08             	add    $0x8,%esp
  8019dc:	68 8e 28 80 00       	push   $0x80288e
  8019e1:	53                   	push   %ebx
  8019e2:	e8 ad ee ff ff       	call   800894 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e7:	8b 46 04             	mov    0x4(%esi),%eax
  8019ea:	2b 06                	sub    (%esi),%eax
  8019ec:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f9:	00 00 00 
	stat->st_dev = &devpipe;
  8019fc:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a03:	30 80 00 
	return 0;
}
  801a06:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    

00801a12 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	53                   	push   %ebx
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a1c:	53                   	push   %ebx
  801a1d:	6a 00                	push   $0x0
  801a1f:	e8 f8 f2 ff ff       	call   800d1c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a24:	89 1c 24             	mov    %ebx,(%esp)
  801a27:	e8 54 f7 ff ff       	call   801180 <fd2data>
  801a2c:	83 c4 08             	add    $0x8,%esp
  801a2f:	50                   	push   %eax
  801a30:	6a 00                	push   $0x0
  801a32:	e8 e5 f2 ff ff       	call   800d1c <sys_page_unmap>
}
  801a37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	57                   	push   %edi
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	83 ec 1c             	sub    $0x1c,%esp
  801a45:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a48:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a52:	83 ec 0c             	sub    $0xc,%esp
  801a55:	ff 75 e0             	pushl  -0x20(%ebp)
  801a58:	e8 b1 05 00 00       	call   80200e <pageref>
  801a5d:	89 c3                	mov    %eax,%ebx
  801a5f:	89 3c 24             	mov    %edi,(%esp)
  801a62:	e8 a7 05 00 00       	call   80200e <pageref>
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	39 c3                	cmp    %eax,%ebx
  801a6c:	0f 94 c1             	sete   %cl
  801a6f:	0f b6 c9             	movzbl %cl,%ecx
  801a72:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a75:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a7b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a7e:	39 ce                	cmp    %ecx,%esi
  801a80:	74 1b                	je     801a9d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a82:	39 c3                	cmp    %eax,%ebx
  801a84:	75 c4                	jne    801a4a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a86:	8b 42 58             	mov    0x58(%edx),%eax
  801a89:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a8c:	50                   	push   %eax
  801a8d:	56                   	push   %esi
  801a8e:	68 95 28 80 00       	push   $0x802895
  801a93:	e8 77 e8 ff ff       	call   80030f <cprintf>
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	eb ad                	jmp    801a4a <_pipeisclosed+0xe>
	}
}
  801a9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa3:	5b                   	pop    %ebx
  801aa4:	5e                   	pop    %esi
  801aa5:	5f                   	pop    %edi
  801aa6:	5d                   	pop    %ebp
  801aa7:	c3                   	ret    

00801aa8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	57                   	push   %edi
  801aac:	56                   	push   %esi
  801aad:	53                   	push   %ebx
  801aae:	83 ec 28             	sub    $0x28,%esp
  801ab1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ab4:	56                   	push   %esi
  801ab5:	e8 c6 f6 ff ff       	call   801180 <fd2data>
  801aba:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac4:	eb 4b                	jmp    801b11 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ac6:	89 da                	mov    %ebx,%edx
  801ac8:	89 f0                	mov    %esi,%eax
  801aca:	e8 6d ff ff ff       	call   801a3c <_pipeisclosed>
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	75 48                	jne    801b1b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ad3:	e8 a0 f1 ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad8:	8b 43 04             	mov    0x4(%ebx),%eax
  801adb:	8b 0b                	mov    (%ebx),%ecx
  801add:	8d 51 20             	lea    0x20(%ecx),%edx
  801ae0:	39 d0                	cmp    %edx,%eax
  801ae2:	73 e2                	jae    801ac6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aeb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aee:	89 c2                	mov    %eax,%edx
  801af0:	c1 fa 1f             	sar    $0x1f,%edx
  801af3:	89 d1                	mov    %edx,%ecx
  801af5:	c1 e9 1b             	shr    $0x1b,%ecx
  801af8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801afb:	83 e2 1f             	and    $0x1f,%edx
  801afe:	29 ca                	sub    %ecx,%edx
  801b00:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b04:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b08:	83 c0 01             	add    $0x1,%eax
  801b0b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0e:	83 c7 01             	add    $0x1,%edi
  801b11:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b14:	75 c2                	jne    801ad8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b16:	8b 45 10             	mov    0x10(%ebp),%eax
  801b19:	eb 05                	jmp    801b20 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5e                   	pop    %esi
  801b25:	5f                   	pop    %edi
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	57                   	push   %edi
  801b2c:	56                   	push   %esi
  801b2d:	53                   	push   %ebx
  801b2e:	83 ec 18             	sub    $0x18,%esp
  801b31:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b34:	57                   	push   %edi
  801b35:	e8 46 f6 ff ff       	call   801180 <fd2data>
  801b3a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b44:	eb 3d                	jmp    801b83 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b46:	85 db                	test   %ebx,%ebx
  801b48:	74 04                	je     801b4e <devpipe_read+0x26>
				return i;
  801b4a:	89 d8                	mov    %ebx,%eax
  801b4c:	eb 44                	jmp    801b92 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b4e:	89 f2                	mov    %esi,%edx
  801b50:	89 f8                	mov    %edi,%eax
  801b52:	e8 e5 fe ff ff       	call   801a3c <_pipeisclosed>
  801b57:	85 c0                	test   %eax,%eax
  801b59:	75 32                	jne    801b8d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b5b:	e8 18 f1 ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b60:	8b 06                	mov    (%esi),%eax
  801b62:	3b 46 04             	cmp    0x4(%esi),%eax
  801b65:	74 df                	je     801b46 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b67:	99                   	cltd   
  801b68:	c1 ea 1b             	shr    $0x1b,%edx
  801b6b:	01 d0                	add    %edx,%eax
  801b6d:	83 e0 1f             	and    $0x1f,%eax
  801b70:	29 d0                	sub    %edx,%eax
  801b72:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b7d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b80:	83 c3 01             	add    $0x1,%ebx
  801b83:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b86:	75 d8                	jne    801b60 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b88:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8b:	eb 05                	jmp    801b92 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b8d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b95:	5b                   	pop    %ebx
  801b96:	5e                   	pop    %esi
  801b97:	5f                   	pop    %edi
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	56                   	push   %esi
  801b9e:	53                   	push   %ebx
  801b9f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ba2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba5:	50                   	push   %eax
  801ba6:	e8 ec f5 ff ff       	call   801197 <fd_alloc>
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	89 c2                	mov    %eax,%edx
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	0f 88 2c 01 00 00    	js     801ce4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb8:	83 ec 04             	sub    $0x4,%esp
  801bbb:	68 07 04 00 00       	push   $0x407
  801bc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc3:	6a 00                	push   $0x0
  801bc5:	e8 cd f0 ff ff       	call   800c97 <sys_page_alloc>
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	89 c2                	mov    %eax,%edx
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	0f 88 0d 01 00 00    	js     801ce4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bdd:	50                   	push   %eax
  801bde:	e8 b4 f5 ff ff       	call   801197 <fd_alloc>
  801be3:	89 c3                	mov    %eax,%ebx
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	85 c0                	test   %eax,%eax
  801bea:	0f 88 e2 00 00 00    	js     801cd2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf0:	83 ec 04             	sub    $0x4,%esp
  801bf3:	68 07 04 00 00       	push   $0x407
  801bf8:	ff 75 f0             	pushl  -0x10(%ebp)
  801bfb:	6a 00                	push   $0x0
  801bfd:	e8 95 f0 ff ff       	call   800c97 <sys_page_alloc>
  801c02:	89 c3                	mov    %eax,%ebx
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	85 c0                	test   %eax,%eax
  801c09:	0f 88 c3 00 00 00    	js     801cd2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	ff 75 f4             	pushl  -0xc(%ebp)
  801c15:	e8 66 f5 ff ff       	call   801180 <fd2data>
  801c1a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1c:	83 c4 0c             	add    $0xc,%esp
  801c1f:	68 07 04 00 00       	push   $0x407
  801c24:	50                   	push   %eax
  801c25:	6a 00                	push   $0x0
  801c27:	e8 6b f0 ff ff       	call   800c97 <sys_page_alloc>
  801c2c:	89 c3                	mov    %eax,%ebx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	85 c0                	test   %eax,%eax
  801c33:	0f 88 89 00 00 00    	js     801cc2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c39:	83 ec 0c             	sub    $0xc,%esp
  801c3c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3f:	e8 3c f5 ff ff       	call   801180 <fd2data>
  801c44:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c4b:	50                   	push   %eax
  801c4c:	6a 00                	push   $0x0
  801c4e:	56                   	push   %esi
  801c4f:	6a 00                	push   $0x0
  801c51:	e8 84 f0 ff ff       	call   800cda <sys_page_map>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	83 c4 20             	add    $0x20,%esp
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	78 55                	js     801cb4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c5f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c68:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c74:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c82:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c89:	83 ec 0c             	sub    $0xc,%esp
  801c8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8f:	e8 dc f4 ff ff       	call   801170 <fd2num>
  801c94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c97:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c99:	83 c4 04             	add    $0x4,%esp
  801c9c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9f:	e8 cc f4 ff ff       	call   801170 <fd2num>
  801ca4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801caa:	83 c4 10             	add    $0x10,%esp
  801cad:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb2:	eb 30                	jmp    801ce4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cb4:	83 ec 08             	sub    $0x8,%esp
  801cb7:	56                   	push   %esi
  801cb8:	6a 00                	push   $0x0
  801cba:	e8 5d f0 ff ff       	call   800d1c <sys_page_unmap>
  801cbf:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cc2:	83 ec 08             	sub    $0x8,%esp
  801cc5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc8:	6a 00                	push   $0x0
  801cca:	e8 4d f0 ff ff       	call   800d1c <sys_page_unmap>
  801ccf:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cd2:	83 ec 08             	sub    $0x8,%esp
  801cd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd8:	6a 00                	push   $0x0
  801cda:	e8 3d f0 ff ff       	call   800d1c <sys_page_unmap>
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ce4:	89 d0                	mov    %edx,%eax
  801ce6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce9:	5b                   	pop    %ebx
  801cea:	5e                   	pop    %esi
  801ceb:	5d                   	pop    %ebp
  801cec:	c3                   	ret    

00801ced <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf6:	50                   	push   %eax
  801cf7:	ff 75 08             	pushl  0x8(%ebp)
  801cfa:	e8 e7 f4 ff ff       	call   8011e6 <fd_lookup>
  801cff:	83 c4 10             	add    $0x10,%esp
  801d02:	85 c0                	test   %eax,%eax
  801d04:	78 18                	js     801d1e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d06:	83 ec 0c             	sub    $0xc,%esp
  801d09:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0c:	e8 6f f4 ff ff       	call   801180 <fd2data>
	return _pipeisclosed(fd, p);
  801d11:	89 c2                	mov    %eax,%edx
  801d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d16:	e8 21 fd ff ff       	call   801a3c <_pipeisclosed>
  801d1b:	83 c4 10             	add    $0x10,%esp
}
  801d1e:	c9                   	leave  
  801d1f:	c3                   	ret    

00801d20 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d23:	b8 00 00 00 00       	mov    $0x0,%eax
  801d28:	5d                   	pop    %ebp
  801d29:	c3                   	ret    

00801d2a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
  801d2d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d30:	68 ad 28 80 00       	push   $0x8028ad
  801d35:	ff 75 0c             	pushl  0xc(%ebp)
  801d38:	e8 57 eb ff ff       	call   800894 <strcpy>
	return 0;
}
  801d3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d42:	c9                   	leave  
  801d43:	c3                   	ret    

00801d44 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	57                   	push   %edi
  801d48:	56                   	push   %esi
  801d49:	53                   	push   %ebx
  801d4a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d50:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d55:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5b:	eb 2d                	jmp    801d8a <devcons_write+0x46>
		m = n - tot;
  801d5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d60:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d62:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d65:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d6a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d6d:	83 ec 04             	sub    $0x4,%esp
  801d70:	53                   	push   %ebx
  801d71:	03 45 0c             	add    0xc(%ebp),%eax
  801d74:	50                   	push   %eax
  801d75:	57                   	push   %edi
  801d76:	e8 ab ec ff ff       	call   800a26 <memmove>
		sys_cputs(buf, m);
  801d7b:	83 c4 08             	add    $0x8,%esp
  801d7e:	53                   	push   %ebx
  801d7f:	57                   	push   %edi
  801d80:	e8 56 ee ff ff       	call   800bdb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d85:	01 de                	add    %ebx,%esi
  801d87:	83 c4 10             	add    $0x10,%esp
  801d8a:	89 f0                	mov    %esi,%eax
  801d8c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d8f:	72 cc                	jb     801d5d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5f                   	pop    %edi
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    

00801d99 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	83 ec 08             	sub    $0x8,%esp
  801d9f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801da4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da8:	74 2a                	je     801dd4 <devcons_read+0x3b>
  801daa:	eb 05                	jmp    801db1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dac:	e8 c7 ee ff ff       	call   800c78 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801db1:	e8 43 ee ff ff       	call   800bf9 <sys_cgetc>
  801db6:	85 c0                	test   %eax,%eax
  801db8:	74 f2                	je     801dac <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	78 16                	js     801dd4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dbe:	83 f8 04             	cmp    $0x4,%eax
  801dc1:	74 0c                	je     801dcf <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc6:	88 02                	mov    %al,(%edx)
	return 1;
  801dc8:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcd:	eb 05                	jmp    801dd4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dcf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801de2:	6a 01                	push   $0x1
  801de4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de7:	50                   	push   %eax
  801de8:	e8 ee ed ff ff       	call   800bdb <sys_cputs>
}
  801ded:	83 c4 10             	add    $0x10,%esp
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <getchar>:

int
getchar(void)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801df8:	6a 01                	push   $0x1
  801dfa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfd:	50                   	push   %eax
  801dfe:	6a 00                	push   $0x0
  801e00:	e8 47 f6 ff ff       	call   80144c <read>
	if (r < 0)
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	78 0f                	js     801e1b <getchar+0x29>
		return r;
	if (r < 1)
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	7e 06                	jle    801e16 <getchar+0x24>
		return -E_EOF;
	return c;
  801e10:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e14:	eb 05                	jmp    801e1b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e16:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e1b:	c9                   	leave  
  801e1c:	c3                   	ret    

00801e1d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e26:	50                   	push   %eax
  801e27:	ff 75 08             	pushl  0x8(%ebp)
  801e2a:	e8 b7 f3 ff ff       	call   8011e6 <fd_lookup>
  801e2f:	83 c4 10             	add    $0x10,%esp
  801e32:	85 c0                	test   %eax,%eax
  801e34:	78 11                	js     801e47 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e39:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e3f:	39 10                	cmp    %edx,(%eax)
  801e41:	0f 94 c0             	sete   %al
  801e44:	0f b6 c0             	movzbl %al,%eax
}
  801e47:	c9                   	leave  
  801e48:	c3                   	ret    

00801e49 <opencons>:

int
opencons(void)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e52:	50                   	push   %eax
  801e53:	e8 3f f3 ff ff       	call   801197 <fd_alloc>
  801e58:	83 c4 10             	add    $0x10,%esp
		return r;
  801e5b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	78 3e                	js     801e9f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e61:	83 ec 04             	sub    $0x4,%esp
  801e64:	68 07 04 00 00       	push   $0x407
  801e69:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6c:	6a 00                	push   $0x0
  801e6e:	e8 24 ee ff ff       	call   800c97 <sys_page_alloc>
  801e73:	83 c4 10             	add    $0x10,%esp
		return r;
  801e76:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	78 23                	js     801e9f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e7c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e85:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e91:	83 ec 0c             	sub    $0xc,%esp
  801e94:	50                   	push   %eax
  801e95:	e8 d6 f2 ff ff       	call   801170 <fd2num>
  801e9a:	89 c2                	mov    %eax,%edx
  801e9c:	83 c4 10             	add    $0x10,%esp
}
  801e9f:	89 d0                	mov    %edx,%eax
  801ea1:	c9                   	leave  
  801ea2:	c3                   	ret    

00801ea3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  801ea9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eb0:	75 2a                	jne    801edc <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801eb2:	83 ec 04             	sub    $0x4,%esp
  801eb5:	6a 06                	push   $0x6
  801eb7:	68 00 f0 bf ee       	push   $0xeebff000
  801ebc:	6a 00                	push   $0x0
  801ebe:	e8 d4 ed ff ff       	call   800c97 <sys_page_alloc>
			 if (a < 0)
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	85 c0                	test   %eax,%eax
  801ec8:	79 12                	jns    801edc <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801eca:	50                   	push   %eax
  801ecb:	68 b9 28 80 00       	push   $0x8028b9
  801ed0:	6a 21                	push   $0x21
  801ed2:	68 d3 28 80 00       	push   $0x8028d3
  801ed7:	e8 5a e3 ff ff       	call   800236 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  801edc:	e8 78 ed ff ff       	call   800c59 <sys_getenvid>
  801ee1:	83 ec 08             	sub    $0x8,%esp
  801ee4:	68 fc 1e 80 00       	push   $0x801efc
  801ee9:	50                   	push   %eax
  801eea:	e8 f3 ee ff ff       	call   800de2 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  801eef:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef2:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ef7:	83 c4 10             	add    $0x10,%esp
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  801efc:	54                   	push   %esp
movl _pgfault_handler, %eax
  801efd:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  801f02:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  801f04:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  801f07:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  801f0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  801f0f:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  801f12:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  801f16:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  801f18:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  801f1b:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  801f1c:	83 c4 04             	add    $0x4,%esp
popfl
  801f1f:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  801f20:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  801f21:	c3                   	ret    

00801f22 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	56                   	push   %esi
  801f26:	53                   	push   %ebx
  801f27:	8b 75 08             	mov    0x8(%ebp),%esi
  801f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801f30:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801f32:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f37:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801f3a:	83 ec 0c             	sub    $0xc,%esp
  801f3d:	50                   	push   %eax
  801f3e:	e8 04 ef ff ff       	call   800e47 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801f43:	83 c4 10             	add    $0x10,%esp
  801f46:	85 c0                	test   %eax,%eax
  801f48:	78 0e                	js     801f58 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801f4a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f50:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801f53:	8b 52 78             	mov    0x78(%edx),%edx
  801f56:	eb 0a                	jmp    801f62 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801f58:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801f5d:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801f62:	85 f6                	test   %esi,%esi
  801f64:	74 02                	je     801f68 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801f66:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801f68:	85 db                	test   %ebx,%ebx
  801f6a:	74 02                	je     801f6e <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801f6c:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 08                	js     801f7a <ipc_recv+0x58>
  801f72:	a1 04 40 80 00       	mov    0x804004,%eax
  801f77:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801f7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    

00801f81 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	57                   	push   %edi
  801f85:	56                   	push   %esi
  801f86:	53                   	push   %ebx
  801f87:	83 ec 0c             	sub    $0xc,%esp
  801f8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801f93:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801f95:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f9a:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801f9d:	ff 75 14             	pushl  0x14(%ebp)
  801fa0:	53                   	push   %ebx
  801fa1:	56                   	push   %esi
  801fa2:	57                   	push   %edi
  801fa3:	e8 7c ee ff ff       	call   800e24 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801fa8:	83 c4 10             	add    $0x10,%esp
  801fab:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fae:	75 07                	jne    801fb7 <ipc_send+0x36>
				    sys_yield();
  801fb0:	e8 c3 ec ff ff       	call   800c78 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801fb5:	eb e6                	jmp    801f9d <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	74 12                	je     801fcd <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801fbb:	50                   	push   %eax
  801fbc:	68 e1 28 80 00       	push   $0x8028e1
  801fc1:	6a 4b                	push   $0x4b
  801fc3:	68 f5 28 80 00       	push   $0x8028f5
  801fc8:	e8 69 e2 ff ff       	call   800236 <_panic>
			 }
	   }
}
  801fcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd0:	5b                   	pop    %ebx
  801fd1:	5e                   	pop    %esi
  801fd2:	5f                   	pop    %edi
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    

00801fd5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801fdb:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801fe0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fe3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fe9:	8b 52 50             	mov    0x50(%edx),%edx
  801fec:	39 ca                	cmp    %ecx,%edx
  801fee:	75 0d                	jne    801ffd <ipc_find_env+0x28>
				    return envs[i].env_id;
  801ff0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ff3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ff8:	8b 40 48             	mov    0x48(%eax),%eax
  801ffb:	eb 0f                	jmp    80200c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801ffd:	83 c0 01             	add    $0x1,%eax
  802000:	3d 00 04 00 00       	cmp    $0x400,%eax
  802005:	75 d9                	jne    801fe0 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  802007:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    

0080200e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802014:	89 d0                	mov    %edx,%eax
  802016:	c1 e8 16             	shr    $0x16,%eax
  802019:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802020:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802025:	f6 c1 01             	test   $0x1,%cl
  802028:	74 1d                	je     802047 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80202a:	c1 ea 0c             	shr    $0xc,%edx
  80202d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802034:	f6 c2 01             	test   $0x1,%dl
  802037:	74 0e                	je     802047 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802039:	c1 ea 0c             	shr    $0xc,%edx
  80203c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802043:	ef 
  802044:	0f b7 c0             	movzwl %ax,%eax
}
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    
  802049:	66 90                	xchg   %ax,%ax
  80204b:	66 90                	xchg   %ax,%ax
  80204d:	66 90                	xchg   %ax,%ax
  80204f:	90                   	nop

00802050 <__udivdi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80205b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80205f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 f6                	test   %esi,%esi
  802069:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80206d:	89 ca                	mov    %ecx,%edx
  80206f:	89 f8                	mov    %edi,%eax
  802071:	75 3d                	jne    8020b0 <__udivdi3+0x60>
  802073:	39 cf                	cmp    %ecx,%edi
  802075:	0f 87 c5 00 00 00    	ja     802140 <__udivdi3+0xf0>
  80207b:	85 ff                	test   %edi,%edi
  80207d:	89 fd                	mov    %edi,%ebp
  80207f:	75 0b                	jne    80208c <__udivdi3+0x3c>
  802081:	b8 01 00 00 00       	mov    $0x1,%eax
  802086:	31 d2                	xor    %edx,%edx
  802088:	f7 f7                	div    %edi
  80208a:	89 c5                	mov    %eax,%ebp
  80208c:	89 c8                	mov    %ecx,%eax
  80208e:	31 d2                	xor    %edx,%edx
  802090:	f7 f5                	div    %ebp
  802092:	89 c1                	mov    %eax,%ecx
  802094:	89 d8                	mov    %ebx,%eax
  802096:	89 cf                	mov    %ecx,%edi
  802098:	f7 f5                	div    %ebp
  80209a:	89 c3                	mov    %eax,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	39 ce                	cmp    %ecx,%esi
  8020b2:	77 74                	ja     802128 <__udivdi3+0xd8>
  8020b4:	0f bd fe             	bsr    %esi,%edi
  8020b7:	83 f7 1f             	xor    $0x1f,%edi
  8020ba:	0f 84 98 00 00 00    	je     802158 <__udivdi3+0x108>
  8020c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	89 c5                	mov    %eax,%ebp
  8020c9:	29 fb                	sub    %edi,%ebx
  8020cb:	d3 e6                	shl    %cl,%esi
  8020cd:	89 d9                	mov    %ebx,%ecx
  8020cf:	d3 ed                	shr    %cl,%ebp
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e0                	shl    %cl,%eax
  8020d5:	09 ee                	or     %ebp,%esi
  8020d7:	89 d9                	mov    %ebx,%ecx
  8020d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020dd:	89 d5                	mov    %edx,%ebp
  8020df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020e3:	d3 ed                	shr    %cl,%ebp
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e2                	shl    %cl,%edx
  8020e9:	89 d9                	mov    %ebx,%ecx
  8020eb:	d3 e8                	shr    %cl,%eax
  8020ed:	09 c2                	or     %eax,%edx
  8020ef:	89 d0                	mov    %edx,%eax
  8020f1:	89 ea                	mov    %ebp,%edx
  8020f3:	f7 f6                	div    %esi
  8020f5:	89 d5                	mov    %edx,%ebp
  8020f7:	89 c3                	mov    %eax,%ebx
  8020f9:	f7 64 24 0c          	mull   0xc(%esp)
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	72 10                	jb     802111 <__udivdi3+0xc1>
  802101:	8b 74 24 08          	mov    0x8(%esp),%esi
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e6                	shl    %cl,%esi
  802109:	39 c6                	cmp    %eax,%esi
  80210b:	73 07                	jae    802114 <__udivdi3+0xc4>
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	75 03                	jne    802114 <__udivdi3+0xc4>
  802111:	83 eb 01             	sub    $0x1,%ebx
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 d8                	mov    %ebx,%eax
  802118:	89 fa                	mov    %edi,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	31 ff                	xor    %edi,%edi
  80212a:	31 db                	xor    %ebx,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	89 d8                	mov    %ebx,%eax
  802142:	f7 f7                	div    %edi
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 c3                	mov    %eax,%ebx
  802148:	89 d8                	mov    %ebx,%eax
  80214a:	89 fa                	mov    %edi,%edx
  80214c:	83 c4 1c             	add    $0x1c,%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5f                   	pop    %edi
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	39 ce                	cmp    %ecx,%esi
  80215a:	72 0c                	jb     802168 <__udivdi3+0x118>
  80215c:	31 db                	xor    %ebx,%ebx
  80215e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802162:	0f 87 34 ff ff ff    	ja     80209c <__udivdi3+0x4c>
  802168:	bb 01 00 00 00       	mov    $0x1,%ebx
  80216d:	e9 2a ff ff ff       	jmp    80209c <__udivdi3+0x4c>
  802172:	66 90                	xchg   %ax,%ax
  802174:	66 90                	xchg   %ax,%ax
  802176:	66 90                	xchg   %ax,%ax
  802178:	66 90                	xchg   %ax,%ax
  80217a:	66 90                	xchg   %ax,%ax
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

00802180 <__umoddi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80218b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80218f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 d2                	test   %edx,%edx
  802199:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80219d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021a1:	89 f3                	mov    %esi,%ebx
  8021a3:	89 3c 24             	mov    %edi,(%esp)
  8021a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021aa:	75 1c                	jne    8021c8 <__umoddi3+0x48>
  8021ac:	39 f7                	cmp    %esi,%edi
  8021ae:	76 50                	jbe    802200 <__umoddi3+0x80>
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	f7 f7                	div    %edi
  8021b6:	89 d0                	mov    %edx,%eax
  8021b8:	31 d2                	xor    %edx,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	39 f2                	cmp    %esi,%edx
  8021ca:	89 d0                	mov    %edx,%eax
  8021cc:	77 52                	ja     802220 <__umoddi3+0xa0>
  8021ce:	0f bd ea             	bsr    %edx,%ebp
  8021d1:	83 f5 1f             	xor    $0x1f,%ebp
  8021d4:	75 5a                	jne    802230 <__umoddi3+0xb0>
  8021d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021da:	0f 82 e0 00 00 00    	jb     8022c0 <__umoddi3+0x140>
  8021e0:	39 0c 24             	cmp    %ecx,(%esp)
  8021e3:	0f 86 d7 00 00 00    	jbe    8022c0 <__umoddi3+0x140>
  8021e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021f1:	83 c4 1c             	add    $0x1c,%esp
  8021f4:	5b                   	pop    %ebx
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	85 ff                	test   %edi,%edi
  802202:	89 fd                	mov    %edi,%ebp
  802204:	75 0b                	jne    802211 <__umoddi3+0x91>
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f7                	div    %edi
  80220f:	89 c5                	mov    %eax,%ebp
  802211:	89 f0                	mov    %esi,%eax
  802213:	31 d2                	xor    %edx,%edx
  802215:	f7 f5                	div    %ebp
  802217:	89 c8                	mov    %ecx,%eax
  802219:	f7 f5                	div    %ebp
  80221b:	89 d0                	mov    %edx,%eax
  80221d:	eb 99                	jmp    8021b8 <__umoddi3+0x38>
  80221f:	90                   	nop
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	83 c4 1c             	add    $0x1c,%esp
  802227:	5b                   	pop    %ebx
  802228:	5e                   	pop    %esi
  802229:	5f                   	pop    %edi
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	8b 34 24             	mov    (%esp),%esi
  802233:	bf 20 00 00 00       	mov    $0x20,%edi
  802238:	89 e9                	mov    %ebp,%ecx
  80223a:	29 ef                	sub    %ebp,%edi
  80223c:	d3 e0                	shl    %cl,%eax
  80223e:	89 f9                	mov    %edi,%ecx
  802240:	89 f2                	mov    %esi,%edx
  802242:	d3 ea                	shr    %cl,%edx
  802244:	89 e9                	mov    %ebp,%ecx
  802246:	09 c2                	or     %eax,%edx
  802248:	89 d8                	mov    %ebx,%eax
  80224a:	89 14 24             	mov    %edx,(%esp)
  80224d:	89 f2                	mov    %esi,%edx
  80224f:	d3 e2                	shl    %cl,%edx
  802251:	89 f9                	mov    %edi,%ecx
  802253:	89 54 24 04          	mov    %edx,0x4(%esp)
  802257:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80225b:	d3 e8                	shr    %cl,%eax
  80225d:	89 e9                	mov    %ebp,%ecx
  80225f:	89 c6                	mov    %eax,%esi
  802261:	d3 e3                	shl    %cl,%ebx
  802263:	89 f9                	mov    %edi,%ecx
  802265:	89 d0                	mov    %edx,%eax
  802267:	d3 e8                	shr    %cl,%eax
  802269:	89 e9                	mov    %ebp,%ecx
  80226b:	09 d8                	or     %ebx,%eax
  80226d:	89 d3                	mov    %edx,%ebx
  80226f:	89 f2                	mov    %esi,%edx
  802271:	f7 34 24             	divl   (%esp)
  802274:	89 d6                	mov    %edx,%esi
  802276:	d3 e3                	shl    %cl,%ebx
  802278:	f7 64 24 04          	mull   0x4(%esp)
  80227c:	39 d6                	cmp    %edx,%esi
  80227e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802282:	89 d1                	mov    %edx,%ecx
  802284:	89 c3                	mov    %eax,%ebx
  802286:	72 08                	jb     802290 <__umoddi3+0x110>
  802288:	75 11                	jne    80229b <__umoddi3+0x11b>
  80228a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80228e:	73 0b                	jae    80229b <__umoddi3+0x11b>
  802290:	2b 44 24 04          	sub    0x4(%esp),%eax
  802294:	1b 14 24             	sbb    (%esp),%edx
  802297:	89 d1                	mov    %edx,%ecx
  802299:	89 c3                	mov    %eax,%ebx
  80229b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80229f:	29 da                	sub    %ebx,%edx
  8022a1:	19 ce                	sbb    %ecx,%esi
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 f0                	mov    %esi,%eax
  8022a7:	d3 e0                	shl    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	d3 ea                	shr    %cl,%edx
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	d3 ee                	shr    %cl,%esi
  8022b1:	09 d0                	or     %edx,%eax
  8022b3:	89 f2                	mov    %esi,%edx
  8022b5:	83 c4 1c             	add    $0x1c,%esp
  8022b8:	5b                   	pop    %ebx
  8022b9:	5e                   	pop    %esi
  8022ba:	5f                   	pop    %edi
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    
  8022bd:	8d 76 00             	lea    0x0(%esi),%esi
  8022c0:	29 f9                	sub    %edi,%ecx
  8022c2:	19 d6                	sbb    %edx,%esi
  8022c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022cc:	e9 18 ff ff ff       	jmp    8021e9 <__umoddi3+0x69>
