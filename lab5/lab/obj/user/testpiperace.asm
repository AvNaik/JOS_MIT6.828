
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
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
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 00 23 80 00       	push   $0x802300
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 7f 1c 00 00       	call   801ccf <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 19 23 80 00       	push   $0x802319
  80005d:	6a 0d                	push   $0xd
  80005f:	68 22 23 80 00       	push   $0x802322
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 11 0f 00 00       	call   800f7f <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 c8 27 80 00       	push   $0x8027c8
  80007a:	6a 10                	push   $0x10
  80007c:	68 22 23 80 00       	push   $0x802322
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 75 13 00 00       	call   80140a <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 7a 1d 00 00       	call   801e22 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 36 23 80 00       	push   $0x802336
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 bd 0b 00 00       	call   800c86 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 a2 10 00 00       	call   80117e <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 51 23 80 00       	push   $0x802351
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 5c 23 80 00       	push   $0x80235c
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 40 13 00 00       	call   80145a <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 25 13 00 00       	call   80145a <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 67 23 80 00       	push   $0x802367
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 ca 1c 00 00       	call   801e22 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 c0 23 80 00       	push   $0x8023c0
  800167:	6a 3a                	push   $0x3a
  800169:	68 22 23 80 00       	push   $0x802322
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 5e 11 00 00       	call   8012e0 <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 7d 23 80 00       	push   $0x80237d
  80018f:	6a 3c                	push   $0x3c
  800191:	68 22 23 80 00       	push   $0x802322
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 d4 10 00 00       	call   80127a <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 10 19 00 00       	call   801abe <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 95 23 80 00       	push   $0x802395
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 ab 23 80 00       	push   $0x8023ab
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8001ef:	e8 73 0a 00 00       	call   800c67 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 00 12 00 00       	call   801435 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 e7 09 00 00       	call   800c26 <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 10 0a 00 00       	call   800c67 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 f4 23 80 00       	push   $0x8023f4
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 17 23 80 00 	movl   $0x802317,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 2f 09 00 00       	call   800be9 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 54 01 00 00       	call   800454 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 d4 08 00 00       	call   800be9 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 db 1c 00 00       	call   802060 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 c8 1d 00 00       	call   802190 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 17 24 80 00 	movsbl 0x802417(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e3:	83 fa 01             	cmp    $0x1,%edx
  8003e6:	7e 0e                	jle    8003f6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	8b 52 04             	mov    0x4(%edx),%edx
  8003f4:	eb 22                	jmp    800418 <getuint+0x38>
	else if (lflag)
  8003f6:	85 d2                	test   %edx,%edx
  8003f8:	74 10                	je     80040a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ff:	89 08                	mov    %ecx,(%eax)
  800401:	8b 02                	mov    (%edx),%eax
  800403:	ba 00 00 00 00       	mov    $0x0,%edx
  800408:	eb 0e                	jmp    800418 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040f:	89 08                	mov    %ecx,(%eax)
  800411:	8b 02                	mov    (%edx),%eax
  800413:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800420:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800424:	8b 10                	mov    (%eax),%edx
  800426:	3b 50 04             	cmp    0x4(%eax),%edx
  800429:	73 0a                	jae    800435 <sprintputch+0x1b>
		*b->buf++ = ch;
  80042b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042e:	89 08                	mov    %ecx,(%eax)
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	88 02                	mov    %al,(%edx)
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80043d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800440:	50                   	push   %eax
  800441:	ff 75 10             	pushl  0x10(%ebp)
  800444:	ff 75 0c             	pushl  0xc(%ebp)
  800447:	ff 75 08             	pushl  0x8(%ebp)
  80044a:	e8 05 00 00 00       	call   800454 <vprintfmt>
	va_end(ap);
}
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 2c             	sub    $0x2c,%esp
  80045d:	8b 75 08             	mov    0x8(%ebp),%esi
  800460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800463:	8b 7d 10             	mov    0x10(%ebp),%edi
  800466:	eb 12                	jmp    80047a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800468:	85 c0                	test   %eax,%eax
  80046a:	0f 84 89 03 00 00    	je     8007f9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	50                   	push   %eax
  800475:	ff d6                	call   *%esi
  800477:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800481:	83 f8 25             	cmp    $0x25,%eax
  800484:	75 e2                	jne    800468 <vprintfmt+0x14>
  800486:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80048a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800491:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800498:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049f:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a4:	eb 07                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8d 47 01             	lea    0x1(%edi),%eax
  8004b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b3:	0f b6 07             	movzbl (%edi),%eax
  8004b6:	0f b6 c8             	movzbl %al,%ecx
  8004b9:	83 e8 23             	sub    $0x23,%eax
  8004bc:	3c 55                	cmp    $0x55,%al
  8004be:	0f 87 1a 03 00 00    	ja     8007de <vprintfmt+0x38a>
  8004c4:	0f b6 c0             	movzbl %al,%eax
  8004c7:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d5:	eb d6                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ec:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004ef:	83 fa 09             	cmp    $0x9,%edx
  8004f2:	77 39                	ja     80052d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f7:	eb e9                	jmp    8004e2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050a:	eb 27                	jmp    800533 <vprintfmt+0xdf>
  80050c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050f:	85 c0                	test   %eax,%eax
  800511:	b9 00 00 00 00       	mov    $0x0,%ecx
  800516:	0f 49 c8             	cmovns %eax,%ecx
  800519:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051f:	eb 8c                	jmp    8004ad <vprintfmt+0x59>
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800524:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052b:	eb 80                	jmp    8004ad <vprintfmt+0x59>
  80052d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800530:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800533:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800537:	0f 89 70 ff ff ff    	jns    8004ad <vprintfmt+0x59>
				width = precision, precision = -1;
  80053d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800540:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800543:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054a:	e9 5e ff ff ff       	jmp    8004ad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800555:	e9 53 ff ff ff       	jmp    8004ad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 30                	pushl  (%eax)
  800569:	ff d6                	call   *%esi
			break;
  80056b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800571:	e9 04 ff ff ff       	jmp    80047a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	99                   	cltd   
  800582:	31 d0                	xor    %edx,%eax
  800584:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800586:	83 f8 0f             	cmp    $0xf,%eax
  800589:	7f 0b                	jg     800596 <vprintfmt+0x142>
  80058b:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	75 18                	jne    8005ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800596:	50                   	push   %eax
  800597:	68 2f 24 80 00       	push   $0x80242f
  80059c:	53                   	push   %ebx
  80059d:	56                   	push   %esi
  80059e:	e8 94 fe ff ff       	call   800437 <printfmt>
  8005a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a9:	e9 cc fe ff ff       	jmp    80047a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ae:	52                   	push   %edx
  8005af:	68 c1 28 80 00       	push   $0x8028c1
  8005b4:	53                   	push   %ebx
  8005b5:	56                   	push   %esi
  8005b6:	e8 7c fe ff ff       	call   800437 <printfmt>
  8005bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c1:	e9 b4 fe ff ff       	jmp    80047a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d1:	85 ff                	test   %edi,%edi
  8005d3:	b8 28 24 80 00       	mov    $0x802428,%eax
  8005d8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005df:	0f 8e 94 00 00 00    	jle    800679 <vprintfmt+0x225>
  8005e5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e9:	0f 84 98 00 00 00    	je     800687 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f5:	57                   	push   %edi
  8005f6:	e8 86 02 00 00       	call   800881 <strnlen>
  8005fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fe:	29 c1                	sub    %eax,%ecx
  800600:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800606:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800610:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800612:	eb 0f                	jmp    800623 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	ff 75 e0             	pushl  -0x20(%ebp)
  80061b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061d:	83 ef 01             	sub    $0x1,%edi
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	85 ff                	test   %edi,%edi
  800625:	7f ed                	jg     800614 <vprintfmt+0x1c0>
  800627:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	b8 00 00 00 00       	mov    $0x0,%eax
  800634:	0f 49 c1             	cmovns %ecx,%eax
  800637:	29 c1                	sub    %eax,%ecx
  800639:	89 75 08             	mov    %esi,0x8(%ebp)
  80063c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800642:	89 cb                	mov    %ecx,%ebx
  800644:	eb 4d                	jmp    800693 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800646:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064a:	74 1b                	je     800667 <vprintfmt+0x213>
  80064c:	0f be c0             	movsbl %al,%eax
  80064f:	83 e8 20             	sub    $0x20,%eax
  800652:	83 f8 5e             	cmp    $0x5e,%eax
  800655:	76 10                	jbe    800667 <vprintfmt+0x213>
					putch('?', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	ff 75 0c             	pushl  0xc(%ebp)
  80065d:	6a 3f                	push   $0x3f
  80065f:	ff 55 08             	call   *0x8(%ebp)
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	eb 0d                	jmp    800674 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	ff 75 0c             	pushl  0xc(%ebp)
  80066d:	52                   	push   %edx
  80066e:	ff 55 08             	call   *0x8(%ebp)
  800671:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800674:	83 eb 01             	sub    $0x1,%ebx
  800677:	eb 1a                	jmp    800693 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	eb 0c                	jmp    800693 <vprintfmt+0x23f>
  800687:	89 75 08             	mov    %esi,0x8(%ebp)
  80068a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800690:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800693:	83 c7 01             	add    $0x1,%edi
  800696:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069a:	0f be d0             	movsbl %al,%edx
  80069d:	85 d2                	test   %edx,%edx
  80069f:	74 23                	je     8006c4 <vprintfmt+0x270>
  8006a1:	85 f6                	test   %esi,%esi
  8006a3:	78 a1                	js     800646 <vprintfmt+0x1f2>
  8006a5:	83 ee 01             	sub    $0x1,%esi
  8006a8:	79 9c                	jns    800646 <vprintfmt+0x1f2>
  8006aa:	89 df                	mov    %ebx,%edi
  8006ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8006af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b2:	eb 18                	jmp    8006cc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	6a 20                	push   $0x20
  8006ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bc:	83 ef 01             	sub    $0x1,%edi
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb 08                	jmp    8006cc <vprintfmt+0x278>
  8006c4:	89 df                	mov    %ebx,%edi
  8006c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cc:	85 ff                	test   %edi,%edi
  8006ce:	7f e4                	jg     8006b4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d3:	e9 a2 fd ff ff       	jmp    80047a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d8:	83 fa 01             	cmp    $0x1,%edx
  8006db:	7e 16                	jle    8006f3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 08             	lea    0x8(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 50 04             	mov    0x4(%eax),%edx
  8006e9:	8b 00                	mov    (%eax),%eax
  8006eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f1:	eb 32                	jmp    800725 <vprintfmt+0x2d1>
	else if (lflag)
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	74 18                	je     80070f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800705:	89 c1                	mov    %eax,%ecx
  800707:	c1 f9 1f             	sar    $0x1f,%ecx
  80070a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80070d:	eb 16                	jmp    800725 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071d:	89 c1                	mov    %eax,%ecx
  80071f:	c1 f9 1f             	sar    $0x1f,%ecx
  800722:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800725:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800728:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800730:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800734:	79 74                	jns    8007aa <vprintfmt+0x356>
				putch('-', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 2d                	push   $0x2d
  80073c:	ff d6                	call   *%esi
				num = -(long long) num;
  80073e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800741:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800744:	f7 d8                	neg    %eax
  800746:	83 d2 00             	adc    $0x0,%edx
  800749:	f7 da                	neg    %edx
  80074b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800753:	eb 55                	jmp    8007aa <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 83 fc ff ff       	call   8003e0 <getuint>
			base = 10;
  80075d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800762:	eb 46                	jmp    8007aa <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800764:	8d 45 14             	lea    0x14(%ebp),%eax
  800767:	e8 74 fc ff ff       	call   8003e0 <getuint>
			base = 8;
  80076c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800771:	eb 37                	jmp    8007aa <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 30                	push   $0x30
  800779:	ff d6                	call   *%esi
			putch('x', putdat);
  80077b:	83 c4 08             	add    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 78                	push   $0x78
  800781:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8d 50 04             	lea    0x4(%eax),%edx
  800789:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078c:	8b 00                	mov    (%eax),%eax
  80078e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800793:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800796:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80079b:	eb 0d                	jmp    8007aa <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079d:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a0:	e8 3b fc ff ff       	call   8003e0 <getuint>
			base = 16;
  8007a5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007aa:	83 ec 0c             	sub    $0xc,%esp
  8007ad:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007b1:	57                   	push   %edi
  8007b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b5:	51                   	push   %ecx
  8007b6:	52                   	push   %edx
  8007b7:	50                   	push   %eax
  8007b8:	89 da                	mov    %ebx,%edx
  8007ba:	89 f0                	mov    %esi,%eax
  8007bc:	e8 70 fb ff ff       	call   800331 <printnum>
			break;
  8007c1:	83 c4 20             	add    $0x20,%esp
  8007c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c7:	e9 ae fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	51                   	push   %ecx
  8007d1:	ff d6                	call   *%esi
			break;
  8007d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d9:	e9 9c fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	53                   	push   %ebx
  8007e2:	6a 25                	push   $0x25
  8007e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	eb 03                	jmp    8007ee <vprintfmt+0x39a>
  8007eb:	83 ef 01             	sub    $0x1,%edi
  8007ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f2:	75 f7                	jne    8007eb <vprintfmt+0x397>
  8007f4:	e9 81 fc ff ff       	jmp    80047a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5f                   	pop    %edi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 18             	sub    $0x18,%esp
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800810:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800814:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800817:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081e:	85 c0                	test   %eax,%eax
  800820:	74 26                	je     800848 <vsnprintf+0x47>
  800822:	85 d2                	test   %edx,%edx
  800824:	7e 22                	jle    800848 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800826:	ff 75 14             	pushl  0x14(%ebp)
  800829:	ff 75 10             	pushl  0x10(%ebp)
  80082c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082f:	50                   	push   %eax
  800830:	68 1a 04 80 00       	push   $0x80041a
  800835:	e8 1a fc ff ff       	call   800454 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800843:	83 c4 10             	add    $0x10,%esp
  800846:	eb 05                	jmp    80084d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800848:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800855:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800858:	50                   	push   %eax
  800859:	ff 75 10             	pushl  0x10(%ebp)
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	ff 75 08             	pushl  0x8(%ebp)
  800862:	e8 9a ff ff ff       	call   800801 <vsnprintf>
	va_end(ap);

	return rc;
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
  800874:	eb 03                	jmp    800879 <strlen+0x10>
		n++;
  800876:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800879:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087d:	75 f7                	jne    800876 <strlen+0xd>
		n++;
	return n;
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800887:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088a:	ba 00 00 00 00       	mov    $0x0,%edx
  80088f:	eb 03                	jmp    800894 <strnlen+0x13>
		n++;
  800891:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800894:	39 c2                	cmp    %eax,%edx
  800896:	74 08                	je     8008a0 <strnlen+0x1f>
  800898:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80089c:	75 f3                	jne    800891 <strnlen+0x10>
  80089e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ac:	89 c2                	mov    %eax,%edx
  8008ae:	83 c2 01             	add    $0x1,%edx
  8008b1:	83 c1 01             	add    $0x1,%ecx
  8008b4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	75 ef                	jne    8008ae <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c9:	53                   	push   %ebx
  8008ca:	e8 9a ff ff ff       	call   800869 <strlen>
  8008cf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d2:	ff 75 0c             	pushl  0xc(%ebp)
  8008d5:	01 d8                	add    %ebx,%eax
  8008d7:	50                   	push   %eax
  8008d8:	e8 c5 ff ff ff       	call   8008a2 <strcpy>
	return dst;
}
  8008dd:	89 d8                	mov    %ebx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ef:	89 f3                	mov    %esi,%ebx
  8008f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	89 f2                	mov    %esi,%edx
  8008f6:	eb 0f                	jmp    800907 <strncpy+0x23>
		*dst++ = *src;
  8008f8:	83 c2 01             	add    $0x1,%edx
  8008fb:	0f b6 01             	movzbl (%ecx),%eax
  8008fe:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800901:	80 39 01             	cmpb   $0x1,(%ecx)
  800904:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800907:	39 da                	cmp    %ebx,%edx
  800909:	75 ed                	jne    8008f8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	8b 75 08             	mov    0x8(%ebp),%esi
  800919:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091c:	8b 55 10             	mov    0x10(%ebp),%edx
  80091f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800921:	85 d2                	test   %edx,%edx
  800923:	74 21                	je     800946 <strlcpy+0x35>
  800925:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800929:	89 f2                	mov    %esi,%edx
  80092b:	eb 09                	jmp    800936 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092d:	83 c2 01             	add    $0x1,%edx
  800930:	83 c1 01             	add    $0x1,%ecx
  800933:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800936:	39 c2                	cmp    %eax,%edx
  800938:	74 09                	je     800943 <strlcpy+0x32>
  80093a:	0f b6 19             	movzbl (%ecx),%ebx
  80093d:	84 db                	test   %bl,%bl
  80093f:	75 ec                	jne    80092d <strlcpy+0x1c>
  800941:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800943:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800946:	29 f0                	sub    %esi,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800955:	eb 06                	jmp    80095d <strcmp+0x11>
		p++, q++;
  800957:	83 c1 01             	add    $0x1,%ecx
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 04                	je     800968 <strcmp+0x1c>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	74 ef                	je     800957 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 c0             	movzbl %al,%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 c3                	mov    %eax,%ebx
  80097e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800981:	eb 06                	jmp    800989 <strncmp+0x17>
		n--, p++, q++;
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800989:	39 d8                	cmp    %ebx,%eax
  80098b:	74 15                	je     8009a2 <strncmp+0x30>
  80098d:	0f b6 08             	movzbl (%eax),%ecx
  800990:	84 c9                	test   %cl,%cl
  800992:	74 04                	je     800998 <strncmp+0x26>
  800994:	3a 0a                	cmp    (%edx),%cl
  800996:	74 eb                	je     800983 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 00             	movzbl (%eax),%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
  8009a0:	eb 05                	jmp    8009a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b4:	eb 07                	jmp    8009bd <strchr+0x13>
		if (*s == c)
  8009b6:	38 ca                	cmp    %cl,%dl
  8009b8:	74 0f                	je     8009c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 f2                	jne    8009b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	eb 03                	jmp    8009da <strfind+0xf>
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009dd:	38 ca                	cmp    %cl,%dl
  8009df:	74 04                	je     8009e5 <strfind+0x1a>
  8009e1:	84 d2                	test   %dl,%dl
  8009e3:	75 f2                	jne    8009d7 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	74 36                	je     800a2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fd:	75 28                	jne    800a27 <memset+0x40>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 23                	jne    800a27 <memset+0x40>
		c &= 0xFF;
  800a04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a08:	89 d3                	mov    %edx,%ebx
  800a0a:	c1 e3 08             	shl    $0x8,%ebx
  800a0d:	89 d6                	mov    %edx,%esi
  800a0f:	c1 e6 18             	shl    $0x18,%esi
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	c1 e0 10             	shl    $0x10,%eax
  800a17:	09 f0                	or     %esi,%eax
  800a19:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a1b:	89 d8                	mov    %ebx,%eax
  800a1d:	09 d0                	or     %edx,%eax
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
  800a22:	fc                   	cld    
  800a23:	f3 ab                	rep stos %eax,%es:(%edi)
  800a25:	eb 06                	jmp    800a2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	fc                   	cld    
  800a2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 35                	jae    800a7b <memmove+0x47>
  800a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 2e                	jae    800a7b <memmove+0x47>
		s += n;
		d += n;
  800a4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	09 fe                	or     %edi,%esi
  800a54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5a:	75 13                	jne    800a6f <memmove+0x3b>
  800a5c:	f6 c1 03             	test   $0x3,%cl
  800a5f:	75 0e                	jne    800a6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a61:	83 ef 04             	sub    $0x4,%edi
  800a64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a67:	c1 e9 02             	shr    $0x2,%ecx
  800a6a:	fd                   	std    
  800a6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6d:	eb 09                	jmp    800a78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a75:	fd                   	std    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a78:	fc                   	cld    
  800a79:	eb 1d                	jmp    800a98 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7b:	89 f2                	mov    %esi,%edx
  800a7d:	09 c2                	or     %eax,%edx
  800a7f:	f6 c2 03             	test   $0x3,%dl
  800a82:	75 0f                	jne    800a93 <memmove+0x5f>
  800a84:	f6 c1 03             	test   $0x3,%cl
  800a87:	75 0a                	jne    800a93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a89:	c1 e9 02             	shr    $0x2,%ecx
  800a8c:	89 c7                	mov    %eax,%edi
  800a8e:	fc                   	cld    
  800a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a91:	eb 05                	jmp    800a98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	fc                   	cld    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a9f:	ff 75 10             	pushl  0x10(%ebp)
  800aa2:	ff 75 0c             	pushl  0xc(%ebp)
  800aa5:	ff 75 08             	pushl  0x8(%ebp)
  800aa8:	e8 87 ff ff ff       	call   800a34 <memmove>
}
  800aad:	c9                   	leave  
  800aae:	c3                   	ret    

00800aaf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aba:	89 c6                	mov    %eax,%esi
  800abc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abf:	eb 1a                	jmp    800adb <memcmp+0x2c>
		if (*s1 != *s2)
  800ac1:	0f b6 08             	movzbl (%eax),%ecx
  800ac4:	0f b6 1a             	movzbl (%edx),%ebx
  800ac7:	38 d9                	cmp    %bl,%cl
  800ac9:	74 0a                	je     800ad5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800acb:	0f b6 c1             	movzbl %cl,%eax
  800ace:	0f b6 db             	movzbl %bl,%ebx
  800ad1:	29 d8                	sub    %ebx,%eax
  800ad3:	eb 0f                	jmp    800ae4 <memcmp+0x35>
		s1++, s2++;
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adb:	39 f0                	cmp    %esi,%eax
  800add:	75 e2                	jne    800ac1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	53                   	push   %ebx
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aef:	89 c1                	mov    %eax,%ecx
  800af1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800af4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af8:	eb 0a                	jmp    800b04 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800afa:	0f b6 10             	movzbl (%eax),%edx
  800afd:	39 da                	cmp    %ebx,%edx
  800aff:	74 07                	je     800b08 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b01:	83 c0 01             	add    $0x1,%eax
  800b04:	39 c8                	cmp    %ecx,%eax
  800b06:	72 f2                	jb     800afa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b08:	5b                   	pop    %ebx
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b17:	eb 03                	jmp    800b1c <strtol+0x11>
		s++;
  800b19:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1c:	0f b6 01             	movzbl (%ecx),%eax
  800b1f:	3c 20                	cmp    $0x20,%al
  800b21:	74 f6                	je     800b19 <strtol+0xe>
  800b23:	3c 09                	cmp    $0x9,%al
  800b25:	74 f2                	je     800b19 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b27:	3c 2b                	cmp    $0x2b,%al
  800b29:	75 0a                	jne    800b35 <strtol+0x2a>
		s++;
  800b2b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b33:	eb 11                	jmp    800b46 <strtol+0x3b>
  800b35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b3a:	3c 2d                	cmp    $0x2d,%al
  800b3c:	75 08                	jne    800b46 <strtol+0x3b>
		s++, neg = 1;
  800b3e:	83 c1 01             	add    $0x1,%ecx
  800b41:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b46:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4c:	75 15                	jne    800b63 <strtol+0x58>
  800b4e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b51:	75 10                	jne    800b63 <strtol+0x58>
  800b53:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b57:	75 7c                	jne    800bd5 <strtol+0xca>
		s += 2, base = 16;
  800b59:	83 c1 02             	add    $0x2,%ecx
  800b5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b61:	eb 16                	jmp    800b79 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b63:	85 db                	test   %ebx,%ebx
  800b65:	75 12                	jne    800b79 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b67:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6f:	75 08                	jne    800b79 <strtol+0x6e>
		s++, base = 8;
  800b71:	83 c1 01             	add    $0x1,%ecx
  800b74:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b81:	0f b6 11             	movzbl (%ecx),%edx
  800b84:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b87:	89 f3                	mov    %esi,%ebx
  800b89:	80 fb 09             	cmp    $0x9,%bl
  800b8c:	77 08                	ja     800b96 <strtol+0x8b>
			dig = *s - '0';
  800b8e:	0f be d2             	movsbl %dl,%edx
  800b91:	83 ea 30             	sub    $0x30,%edx
  800b94:	eb 22                	jmp    800bb8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b96:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	80 fb 19             	cmp    $0x19,%bl
  800b9e:	77 08                	ja     800ba8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ba0:	0f be d2             	movsbl %dl,%edx
  800ba3:	83 ea 57             	sub    $0x57,%edx
  800ba6:	eb 10                	jmp    800bb8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ba8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 16                	ja     800bc8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bb2:	0f be d2             	movsbl %dl,%edx
  800bb5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bb8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbb:	7d 0b                	jge    800bc8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bbd:	83 c1 01             	add    $0x1,%ecx
  800bc0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bc6:	eb b9                	jmp    800b81 <strtol+0x76>

	if (endptr)
  800bc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcc:	74 0d                	je     800bdb <strtol+0xd0>
		*endptr = (char *) s;
  800bce:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd1:	89 0e                	mov    %ecx,(%esi)
  800bd3:	eb 06                	jmp    800bdb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd5:	85 db                	test   %ebx,%ebx
  800bd7:	74 98                	je     800b71 <strtol+0x66>
  800bd9:	eb 9e                	jmp    800b79 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	f7 da                	neg    %edx
  800bdf:	85 ff                	test   %edi,%edi
  800be1:	0f 45 c2             	cmovne %edx,%eax
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	89 c3                	mov    %eax,%ebx
  800bfc:	89 c7                	mov    %eax,%edi
  800bfe:	89 c6                	mov    %eax,%esi
  800c00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 01 00 00 00       	mov    $0x1,%eax
  800c17:	89 d1                	mov    %edx,%ecx
  800c19:	89 d3                	mov    %edx,%ebx
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c34:	b8 03 00 00 00       	mov    $0x3,%eax
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 cb                	mov    %ecx,%ebx
  800c3e:	89 cf                	mov    %ecx,%edi
  800c40:	89 ce                	mov    %ecx,%esi
  800c42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 03                	push   $0x3
  800c4e:	68 1f 27 80 00       	push   $0x80271f
  800c53:	6a 23                	push   $0x23
  800c55:	68 3c 27 80 00       	push   $0x80273c
  800c5a:	e8 e5 f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c72:	b8 02 00 00 00       	mov    $0x2,%eax
  800c77:	89 d1                	mov    %edx,%ecx
  800c79:	89 d3                	mov    %edx,%ebx
  800c7b:	89 d7                	mov    %edx,%edi
  800c7d:	89 d6                	mov    %edx,%esi
  800c7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_yield>:

void
sys_yield(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	be 00 00 00 00       	mov    $0x0,%esi
  800cb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc1:	89 f7                	mov    %esi,%edi
  800cc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 04                	push   $0x4
  800ccf:	68 1f 27 80 00       	push   $0x80271f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 3c 27 80 00       	push   $0x80273c
  800cdb:	e8 64 f5 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d02:	8b 75 18             	mov    0x18(%ebp),%esi
  800d05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 05                	push   $0x5
  800d11:	68 1f 27 80 00       	push   $0x80271f
  800d16:	6a 23                	push   $0x23
  800d18:	68 3c 27 80 00       	push   $0x80273c
  800d1d:	e8 22 f5 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 17                	jle    800d64 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	50                   	push   %eax
  800d51:	6a 06                	push   $0x6
  800d53:	68 1f 27 80 00       	push   $0x80271f
  800d58:	6a 23                	push   $0x23
  800d5a:	68 3c 27 80 00       	push   $0x80273c
  800d5f:	e8 e0 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 17                	jle    800da6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	50                   	push   %eax
  800d93:	6a 08                	push   $0x8
  800d95:	68 1f 27 80 00       	push   $0x80271f
  800d9a:	6a 23                	push   $0x23
  800d9c:	68 3c 27 80 00       	push   $0x80273c
  800da1:	e8 9e f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	89 de                	mov    %ebx,%esi
  800dcb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 17                	jle    800de8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	50                   	push   %eax
  800dd5:	6a 09                	push   $0x9
  800dd7:	68 1f 27 80 00       	push   $0x80271f
  800ddc:	6a 23                	push   $0x23
  800dde:	68 3c 27 80 00       	push   $0x80273c
  800de3:	e8 5c f4 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 17                	jle    800e2a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	50                   	push   %eax
  800e17:	6a 0a                	push   $0xa
  800e19:	68 1f 27 80 00       	push   $0x80271f
  800e1e:	6a 23                	push   $0x23
  800e20:	68 3c 27 80 00       	push   $0x80273c
  800e25:	e8 1a f4 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	be 00 00 00 00       	mov    $0x0,%esi
  800e3d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e63:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	89 cb                	mov    %ecx,%ebx
  800e6d:	89 cf                	mov    %ecx,%edi
  800e6f:	89 ce                	mov    %ecx,%esi
  800e71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	7e 17                	jle    800e8e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	50                   	push   %eax
  800e7b:	6a 0d                	push   $0xd
  800e7d:	68 1f 27 80 00       	push   $0x80271f
  800e82:	6a 23                	push   $0x23
  800e84:	68 3c 27 80 00       	push   $0x80273c
  800e89:	e8 b6 f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	53                   	push   %ebx
  800e9a:	83 ec 04             	sub    $0x4,%esp
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  800ea0:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  800ea2:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  800ea5:	89 da                	mov    %ebx,%edx
  800ea7:	c1 ea 0c             	shr    $0xc,%edx
  800eaa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  800eb1:	a8 02                	test   $0x2,%al
  800eb3:	75 12                	jne    800ec7 <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  800eb5:	50                   	push   %eax
  800eb6:	68 4c 27 80 00       	push   $0x80274c
  800ebb:	6a 21                	push   $0x21
  800ebd:	68 6d 27 80 00       	push   $0x80276d
  800ec2:	e8 7d f3 ff ff       	call   800244 <_panic>
	   } else if (!(pte & PTE_COW)) {
  800ec7:	f6 c6 08             	test   $0x8,%dh
  800eca:	75 14                	jne    800ee0 <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  800ecc:	83 ec 04             	sub    $0x4,%esp
  800ecf:	68 78 27 80 00       	push   $0x802778
  800ed4:	6a 23                	push   $0x23
  800ed6:	68 6d 27 80 00       	push   $0x80276d
  800edb:	e8 64 f3 ff ff       	call   800244 <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  800ee0:	83 ec 04             	sub    $0x4,%esp
  800ee3:	6a 07                	push   $0x7
  800ee5:	68 00 00 40 00       	push   $0x400000
  800eea:	6a 00                	push   $0x0
  800eec:	e8 b4 fd ff ff       	call   800ca5 <sys_page_alloc>
  800ef1:	83 c4 10             	add    $0x10,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	79 12                	jns    800f0a <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  800ef8:	50                   	push   %eax
  800ef9:	68 95 27 80 00       	push   $0x802795
  800efe:	6a 2e                	push   $0x2e
  800f00:	68 6d 27 80 00       	push   $0x80276d
  800f05:	e8 3a f3 ff ff       	call   800244 <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f0a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f10:	83 ec 04             	sub    $0x4,%esp
  800f13:	68 00 10 00 00       	push   $0x1000
  800f18:	53                   	push   %ebx
  800f19:	68 00 00 40 00       	push   $0x400000
  800f1e:	e8 11 fb ff ff       	call   800a34 <memmove>
	   if ((r = sys_page_map(0,
  800f23:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f2a:	53                   	push   %ebx
  800f2b:	6a 00                	push   $0x0
  800f2d:	68 00 00 40 00       	push   $0x400000
  800f32:	6a 00                	push   $0x0
  800f34:	e8 af fd ff ff       	call   800ce8 <sys_page_map>
  800f39:	83 c4 20             	add    $0x20,%esp
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	79 12                	jns    800f52 <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  800f40:	50                   	push   %eax
  800f41:	68 a8 27 80 00       	push   $0x8027a8
  800f46:	6a 36                	push   $0x36
  800f48:	68 6d 27 80 00       	push   $0x80276d
  800f4d:	e8 f2 f2 ff ff       	call   800244 <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  800f52:	83 ec 08             	sub    $0x8,%esp
  800f55:	68 00 00 40 00       	push   $0x400000
  800f5a:	6a 00                	push   $0x0
  800f5c:	e8 c9 fd ff ff       	call   800d2a <sys_page_unmap>
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	79 12                	jns    800f7a <pgfault+0xe4>
			 panic("unmap %e", r);
  800f68:	50                   	push   %eax
  800f69:	68 b8 27 80 00       	push   $0x8027b8
  800f6e:	6a 39                	push   $0x39
  800f70:	68 6d 27 80 00       	push   $0x80276d
  800f75:	e8 ca f2 ff ff       	call   800244 <_panic>
	   }
}
  800f7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	57                   	push   %edi
  800f83:	56                   	push   %esi
  800f84:	53                   	push   %ebx
  800f85:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  800f88:	68 96 0e 80 00       	push   $0x800e96
  800f8d:	e8 46 10 00 00       	call   801fd8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f92:	b8 07 00 00 00       	mov    $0x7,%eax
  800f97:	cd 30                	int    $0x30
  800f99:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f9c:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	79 15                	jns    800fbb <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  800fa6:	50                   	push   %eax
  800fa7:	68 c1 27 80 00       	push   $0x8027c1
  800fac:	68 81 00 00 00       	push   $0x81
  800fb1:	68 6d 27 80 00       	push   $0x80276d
  800fb6:	e8 89 f2 ff ff       	call   800244 <_panic>
  800fbb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800fc2:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  800fc6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800fca:	75 1c                	jne    800fe8 <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  800fcc:	e8 96 fc ff ff       	call   800c67 <sys_getenvid>
  800fd1:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fd6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fd9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fde:	a3 04 40 80 00       	mov    %eax,0x804004
			 return envid;
  800fe3:	e9 71 01 00 00       	jmp    801159 <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  800fe8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800feb:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800ff2:	a8 01                	test   $0x1,%al
  800ff4:	0f 84 18 01 00 00    	je     801112 <fork+0x193>
  800ffa:	89 fb                	mov    %edi,%ebx
  800ffc:	c1 e3 0a             	shl    $0xa,%ebx
  800fff:	c1 e7 16             	shl    $0x16,%edi
  801002:	be 00 00 00 00       	mov    $0x0,%esi
  801007:	e9 f4 00 00 00       	jmp    801100 <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  80100c:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801012:	0f 84 dc 00 00 00    	je     8010f4 <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  801018:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80101e:	0f 87 cc 00 00 00    	ja     8010f0 <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  801024:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80102b:	a8 01                	test   $0x1,%al
  80102d:	0f 84 c1 00 00 00    	je     8010f4 <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  801033:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  80103a:	a9 02 08 00 00       	test   $0x802,%eax
  80103f:	74 05                	je     801046 <fork+0xc7>
  801041:	f6 c4 04             	test   $0x4,%ah
  801044:	74 3a                	je     801080 <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  801046:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80104c:	8b 52 48             	mov    0x48(%edx),%edx
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	25 07 0e 00 00       	and    $0xe07,%eax
  801057:	50                   	push   %eax
  801058:	57                   	push   %edi
  801059:	ff 75 dc             	pushl  -0x24(%ebp)
  80105c:	57                   	push   %edi
  80105d:	52                   	push   %edx
  80105e:	e8 85 fc ff ff       	call   800ce8 <sys_page_map>
  801063:	83 c4 20             	add    $0x20,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	0f 89 86 00 00 00    	jns    8010f4 <fork+0x175>
				    panic("sys_page_map: %e", r);
  80106e:	50                   	push   %eax
  80106f:	68 d1 27 80 00       	push   $0x8027d1
  801074:	6a 52                	push   $0x52
  801076:	68 6d 27 80 00       	push   $0x80276d
  80107b:	e8 c4 f1 ff ff       	call   800244 <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  801080:	25 05 06 00 00       	and    $0x605,%eax
  801085:	80 cc 08             	or     $0x8,%ah
  801088:	89 c1                	mov    %eax,%ecx
  80108a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80108d:	a1 04 40 80 00       	mov    0x804004,%eax
  801092:	8b 40 48             	mov    0x48(%eax),%eax
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	51                   	push   %ecx
  801099:	57                   	push   %edi
  80109a:	ff 75 dc             	pushl  -0x24(%ebp)
  80109d:	57                   	push   %edi
  80109e:	50                   	push   %eax
  80109f:	e8 44 fc ff ff       	call   800ce8 <sys_page_map>
  8010a4:	83 c4 20             	add    $0x20,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	79 12                	jns    8010bd <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  8010ab:	50                   	push   %eax
  8010ac:	68 d1 27 80 00       	push   $0x8027d1
  8010b1:	6a 5d                	push   $0x5d
  8010b3:	68 6d 27 80 00       	push   $0x80276d
  8010b8:	e8 87 f1 ff ff       	call   800244 <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  8010bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c2:	8b 50 48             	mov    0x48(%eax),%edx
  8010c5:	8b 40 48             	mov    0x48(%eax),%eax
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ce:	57                   	push   %edi
  8010cf:	52                   	push   %edx
  8010d0:	57                   	push   %edi
  8010d1:	50                   	push   %eax
  8010d2:	e8 11 fc ff ff       	call   800ce8 <sys_page_map>
  8010d7:	83 c4 20             	add    $0x20,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	79 16                	jns    8010f4 <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  8010de:	50                   	push   %eax
  8010df:	68 d1 27 80 00       	push   $0x8027d1
  8010e4:	6a 63                	push   $0x63
  8010e6:	68 6d 27 80 00       	push   $0x80276d
  8010eb:	e8 54 f1 ff ff       	call   800244 <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  8010f0:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  8010f4:	83 c6 01             	add    $0x1,%esi
  8010f7:	83 c3 01             	add    $0x1,%ebx
  8010fa:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801100:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  801106:	7f 0a                	jg     801112 <fork+0x193>
  801108:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80110c:	0f 85 fa fe ff ff    	jne    80100c <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  801112:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  801116:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801119:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80111e:	7f 0a                	jg     80112a <fork+0x1ab>
  801120:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801124:	0f 85 be fe ff ff    	jne    800fe8 <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	68 31 20 80 00       	push   $0x802031
  801132:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801135:	56                   	push   %esi
  801136:	e8 b5 fc ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  80113b:	83 c4 0c             	add    $0xc,%esp
  80113e:	6a 06                	push   $0x6
  801140:	68 00 f0 bf ee       	push   $0xeebff000
  801145:	56                   	push   %esi
  801146:	e8 5a fb ff ff       	call   800ca5 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  80114b:	83 c4 08             	add    $0x8,%esp
  80114e:	6a 02                	push   $0x2
  801150:	56                   	push   %esi
  801151:	e8 16 fc ff ff       	call   800d6c <sys_env_set_status>

	   return envid;
  801156:	83 c4 10             	add    $0x10,%esp
}
  801159:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80115c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115f:	5b                   	pop    %ebx
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <sfork>:
// Challenge!
	   int
sfork(void)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  80116a:	68 e2 27 80 00       	push   $0x8027e2
  80116f:	68 a7 00 00 00       	push   $0xa7
  801174:	68 6d 27 80 00       	push   $0x80276d
  801179:	e8 c6 f0 ff ff       	call   800244 <_panic>

0080117e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	56                   	push   %esi
  801182:	53                   	push   %ebx
  801183:	8b 75 08             	mov    0x8(%ebp),%esi
  801186:	8b 45 0c             	mov    0xc(%ebp),%eax
  801189:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  80118c:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  80118e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801193:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	50                   	push   %eax
  80119a:	e8 b6 fc ff ff       	call   800e55 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	78 0e                	js     8011b4 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  8011a6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011ac:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  8011af:	8b 52 78             	mov    0x78(%edx),%edx
  8011b2:	eb 0a                	jmp    8011be <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  8011b4:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  8011b9:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  8011be:	85 f6                	test   %esi,%esi
  8011c0:	74 02                	je     8011c4 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  8011c2:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  8011c4:	85 db                	test   %ebx,%ebx
  8011c6:	74 02                	je     8011ca <ipc_recv+0x4c>
			 *perm_store = s_perm;
  8011c8:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 08                	js     8011d6 <ipc_recv+0x58>
  8011ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d3:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  8011d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d9:	5b                   	pop    %ebx
  8011da:	5e                   	pop    %esi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	57                   	push   %edi
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  8011ef:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  8011f1:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8011f6:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  8011f9:	ff 75 14             	pushl  0x14(%ebp)
  8011fc:	53                   	push   %ebx
  8011fd:	56                   	push   %esi
  8011fe:	57                   	push   %edi
  8011ff:	e8 2e fc ff ff       	call   800e32 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80120a:	75 07                	jne    801213 <ipc_send+0x36>
				    sys_yield();
  80120c:	e8 75 fa ff ff       	call   800c86 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801211:	eb e6                	jmp    8011f9 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801213:	85 c0                	test   %eax,%eax
  801215:	74 12                	je     801229 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801217:	50                   	push   %eax
  801218:	68 f8 27 80 00       	push   $0x8027f8
  80121d:	6a 4b                	push   $0x4b
  80121f:	68 0c 28 80 00       	push   $0x80280c
  801224:	e8 1b f0 ff ff       	call   800244 <_panic>
			 }
	   }
}
  801229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122c:	5b                   	pop    %ebx
  80122d:	5e                   	pop    %esi
  80122e:	5f                   	pop    %edi
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801237:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  80123c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80123f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801245:	8b 52 50             	mov    0x50(%edx),%edx
  801248:	39 ca                	cmp    %ecx,%edx
  80124a:	75 0d                	jne    801259 <ipc_find_env+0x28>
				    return envs[i].env_id;
  80124c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80124f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801254:	8b 40 48             	mov    0x48(%eax),%eax
  801257:	eb 0f                	jmp    801268 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801259:	83 c0 01             	add    $0x1,%eax
  80125c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801261:	75 d9                	jne    80123c <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80126d:	8b 45 08             	mov    0x8(%ebp),%eax
  801270:	05 00 00 00 30       	add    $0x30000000,%eax
  801275:	c1 e8 0c             	shr    $0xc,%eax
}
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80127d:	8b 45 08             	mov    0x8(%ebp),%eax
  801280:	05 00 00 00 30       	add    $0x30000000,%eax
  801285:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80128a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80128f:	5d                   	pop    %ebp
  801290:	c3                   	ret    

00801291 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801297:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80129c:	89 c2                	mov    %eax,%edx
  80129e:	c1 ea 16             	shr    $0x16,%edx
  8012a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a8:	f6 c2 01             	test   $0x1,%dl
  8012ab:	74 11                	je     8012be <fd_alloc+0x2d>
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	c1 ea 0c             	shr    $0xc,%edx
  8012b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b9:	f6 c2 01             	test   $0x1,%dl
  8012bc:	75 09                	jne    8012c7 <fd_alloc+0x36>
			*fd_store = fd;
  8012be:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c5:	eb 17                	jmp    8012de <fd_alloc+0x4d>
  8012c7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012cc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d1:	75 c9                	jne    80129c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012d9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012de:	5d                   	pop    %ebp
  8012df:	c3                   	ret    

008012e0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012e6:	83 f8 1f             	cmp    $0x1f,%eax
  8012e9:	77 36                	ja     801321 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012eb:	c1 e0 0c             	shl    $0xc,%eax
  8012ee:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012f3:	89 c2                	mov    %eax,%edx
  8012f5:	c1 ea 16             	shr    $0x16,%edx
  8012f8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ff:	f6 c2 01             	test   $0x1,%dl
  801302:	74 24                	je     801328 <fd_lookup+0x48>
  801304:	89 c2                	mov    %eax,%edx
  801306:	c1 ea 0c             	shr    $0xc,%edx
  801309:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801310:	f6 c2 01             	test   $0x1,%dl
  801313:	74 1a                	je     80132f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801315:	8b 55 0c             	mov    0xc(%ebp),%edx
  801318:	89 02                	mov    %eax,(%edx)
	return 0;
  80131a:	b8 00 00 00 00       	mov    $0x0,%eax
  80131f:	eb 13                	jmp    801334 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801321:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801326:	eb 0c                	jmp    801334 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801328:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132d:	eb 05                	jmp    801334 <fd_lookup+0x54>
  80132f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133f:	ba 98 28 80 00       	mov    $0x802898,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801344:	eb 13                	jmp    801359 <dev_lookup+0x23>
  801346:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801349:	39 08                	cmp    %ecx,(%eax)
  80134b:	75 0c                	jne    801359 <dev_lookup+0x23>
			*dev = devtab[i];
  80134d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801350:	89 01                	mov    %eax,(%ecx)
			return 0;
  801352:	b8 00 00 00 00       	mov    $0x0,%eax
  801357:	eb 2e                	jmp    801387 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801359:	8b 02                	mov    (%edx),%eax
  80135b:	85 c0                	test   %eax,%eax
  80135d:	75 e7                	jne    801346 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80135f:	a1 04 40 80 00       	mov    0x804004,%eax
  801364:	8b 40 48             	mov    0x48(%eax),%eax
  801367:	83 ec 04             	sub    $0x4,%esp
  80136a:	51                   	push   %ecx
  80136b:	50                   	push   %eax
  80136c:	68 18 28 80 00       	push   $0x802818
  801371:	e8 a7 ef ff ff       	call   80031d <cprintf>
	*dev = 0;
  801376:	8b 45 0c             	mov    0xc(%ebp),%eax
  801379:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	56                   	push   %esi
  80138d:	53                   	push   %ebx
  80138e:	83 ec 10             	sub    $0x10,%esp
  801391:	8b 75 08             	mov    0x8(%ebp),%esi
  801394:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013a1:	c1 e8 0c             	shr    $0xc,%eax
  8013a4:	50                   	push   %eax
  8013a5:	e8 36 ff ff ff       	call   8012e0 <fd_lookup>
  8013aa:	83 c4 08             	add    $0x8,%esp
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	78 05                	js     8013b6 <fd_close+0x2d>
	    || fd != fd2)
  8013b1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013b4:	74 0c                	je     8013c2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013b6:	84 db                	test   %bl,%bl
  8013b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bd:	0f 44 c2             	cmove  %edx,%eax
  8013c0:	eb 41                	jmp    801403 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c8:	50                   	push   %eax
  8013c9:	ff 36                	pushl  (%esi)
  8013cb:	e8 66 ff ff ff       	call   801336 <dev_lookup>
  8013d0:	89 c3                	mov    %eax,%ebx
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	78 1a                	js     8013f3 <fd_close+0x6a>
		if (dev->dev_close)
  8013d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013dc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013df:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	74 0b                	je     8013f3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013e8:	83 ec 0c             	sub    $0xc,%esp
  8013eb:	56                   	push   %esi
  8013ec:	ff d0                	call   *%eax
  8013ee:	89 c3                	mov    %eax,%ebx
  8013f0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	56                   	push   %esi
  8013f7:	6a 00                	push   $0x0
  8013f9:	e8 2c f9 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	89 d8                	mov    %ebx,%eax
}
  801403:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801406:	5b                   	pop    %ebx
  801407:	5e                   	pop    %esi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801410:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801413:	50                   	push   %eax
  801414:	ff 75 08             	pushl  0x8(%ebp)
  801417:	e8 c4 fe ff ff       	call   8012e0 <fd_lookup>
  80141c:	83 c4 08             	add    $0x8,%esp
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 10                	js     801433 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	6a 01                	push   $0x1
  801428:	ff 75 f4             	pushl  -0xc(%ebp)
  80142b:	e8 59 ff ff ff       	call   801389 <fd_close>
  801430:	83 c4 10             	add    $0x10,%esp
}
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <close_all>:

void
close_all(void)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	53                   	push   %ebx
  801439:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80143c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801441:	83 ec 0c             	sub    $0xc,%esp
  801444:	53                   	push   %ebx
  801445:	e8 c0 ff ff ff       	call   80140a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80144a:	83 c3 01             	add    $0x1,%ebx
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	83 fb 20             	cmp    $0x20,%ebx
  801453:	75 ec                	jne    801441 <close_all+0xc>
		close(i);
}
  801455:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	57                   	push   %edi
  80145e:	56                   	push   %esi
  80145f:	53                   	push   %ebx
  801460:	83 ec 2c             	sub    $0x2c,%esp
  801463:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801466:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	ff 75 08             	pushl  0x8(%ebp)
  80146d:	e8 6e fe ff ff       	call   8012e0 <fd_lookup>
  801472:	83 c4 08             	add    $0x8,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	0f 88 c1 00 00 00    	js     80153e <dup+0xe4>
		return r;
	close(newfdnum);
  80147d:	83 ec 0c             	sub    $0xc,%esp
  801480:	56                   	push   %esi
  801481:	e8 84 ff ff ff       	call   80140a <close>

	newfd = INDEX2FD(newfdnum);
  801486:	89 f3                	mov    %esi,%ebx
  801488:	c1 e3 0c             	shl    $0xc,%ebx
  80148b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801491:	83 c4 04             	add    $0x4,%esp
  801494:	ff 75 e4             	pushl  -0x1c(%ebp)
  801497:	e8 de fd ff ff       	call   80127a <fd2data>
  80149c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80149e:	89 1c 24             	mov    %ebx,(%esp)
  8014a1:	e8 d4 fd ff ff       	call   80127a <fd2data>
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ac:	89 f8                	mov    %edi,%eax
  8014ae:	c1 e8 16             	shr    $0x16,%eax
  8014b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014b8:	a8 01                	test   $0x1,%al
  8014ba:	74 37                	je     8014f3 <dup+0x99>
  8014bc:	89 f8                	mov    %edi,%eax
  8014be:	c1 e8 0c             	shr    $0xc,%eax
  8014c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014c8:	f6 c2 01             	test   $0x1,%dl
  8014cb:	74 26                	je     8014f3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d4:	83 ec 0c             	sub    $0xc,%esp
  8014d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014dc:	50                   	push   %eax
  8014dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e0:	6a 00                	push   $0x0
  8014e2:	57                   	push   %edi
  8014e3:	6a 00                	push   $0x0
  8014e5:	e8 fe f7 ff ff       	call   800ce8 <sys_page_map>
  8014ea:	89 c7                	mov    %eax,%edi
  8014ec:	83 c4 20             	add    $0x20,%esp
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 2e                	js     801521 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014f6:	89 d0                	mov    %edx,%eax
  8014f8:	c1 e8 0c             	shr    $0xc,%eax
  8014fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801502:	83 ec 0c             	sub    $0xc,%esp
  801505:	25 07 0e 00 00       	and    $0xe07,%eax
  80150a:	50                   	push   %eax
  80150b:	53                   	push   %ebx
  80150c:	6a 00                	push   $0x0
  80150e:	52                   	push   %edx
  80150f:	6a 00                	push   $0x0
  801511:	e8 d2 f7 ff ff       	call   800ce8 <sys_page_map>
  801516:	89 c7                	mov    %eax,%edi
  801518:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80151b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80151d:	85 ff                	test   %edi,%edi
  80151f:	79 1d                	jns    80153e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	53                   	push   %ebx
  801525:	6a 00                	push   $0x0
  801527:	e8 fe f7 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80152c:	83 c4 08             	add    $0x8,%esp
  80152f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801532:	6a 00                	push   $0x0
  801534:	e8 f1 f7 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	89 f8                	mov    %edi,%eax
}
  80153e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801541:	5b                   	pop    %ebx
  801542:	5e                   	pop    %esi
  801543:	5f                   	pop    %edi
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    

00801546 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	53                   	push   %ebx
  80154a:	83 ec 14             	sub    $0x14,%esp
  80154d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801550:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801553:	50                   	push   %eax
  801554:	53                   	push   %ebx
  801555:	e8 86 fd ff ff       	call   8012e0 <fd_lookup>
  80155a:	83 c4 08             	add    $0x8,%esp
  80155d:	89 c2                	mov    %eax,%edx
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 6d                	js     8015d0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156d:	ff 30                	pushl  (%eax)
  80156f:	e8 c2 fd ff ff       	call   801336 <dev_lookup>
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	78 4c                	js     8015c7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80157b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80157e:	8b 42 08             	mov    0x8(%edx),%eax
  801581:	83 e0 03             	and    $0x3,%eax
  801584:	83 f8 01             	cmp    $0x1,%eax
  801587:	75 21                	jne    8015aa <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801589:	a1 04 40 80 00       	mov    0x804004,%eax
  80158e:	8b 40 48             	mov    0x48(%eax),%eax
  801591:	83 ec 04             	sub    $0x4,%esp
  801594:	53                   	push   %ebx
  801595:	50                   	push   %eax
  801596:	68 5c 28 80 00       	push   $0x80285c
  80159b:	e8 7d ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a8:	eb 26                	jmp    8015d0 <read+0x8a>
	}
	if (!dev->dev_read)
  8015aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ad:	8b 40 08             	mov    0x8(%eax),%eax
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	74 17                	je     8015cb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015b4:	83 ec 04             	sub    $0x4,%esp
  8015b7:	ff 75 10             	pushl  0x10(%ebp)
  8015ba:	ff 75 0c             	pushl  0xc(%ebp)
  8015bd:	52                   	push   %edx
  8015be:	ff d0                	call   *%eax
  8015c0:	89 c2                	mov    %eax,%edx
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	eb 09                	jmp    8015d0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c7:	89 c2                	mov    %eax,%edx
  8015c9:	eb 05                	jmp    8015d0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015d0:	89 d0                	mov    %edx,%eax
  8015d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	57                   	push   %edi
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 0c             	sub    $0xc,%esp
  8015e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015eb:	eb 21                	jmp    80160e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ed:	83 ec 04             	sub    $0x4,%esp
  8015f0:	89 f0                	mov    %esi,%eax
  8015f2:	29 d8                	sub    %ebx,%eax
  8015f4:	50                   	push   %eax
  8015f5:	89 d8                	mov    %ebx,%eax
  8015f7:	03 45 0c             	add    0xc(%ebp),%eax
  8015fa:	50                   	push   %eax
  8015fb:	57                   	push   %edi
  8015fc:	e8 45 ff ff ff       	call   801546 <read>
		if (m < 0)
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	85 c0                	test   %eax,%eax
  801606:	78 10                	js     801618 <readn+0x41>
			return m;
		if (m == 0)
  801608:	85 c0                	test   %eax,%eax
  80160a:	74 0a                	je     801616 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160c:	01 c3                	add    %eax,%ebx
  80160e:	39 f3                	cmp    %esi,%ebx
  801610:	72 db                	jb     8015ed <readn+0x16>
  801612:	89 d8                	mov    %ebx,%eax
  801614:	eb 02                	jmp    801618 <readn+0x41>
  801616:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801618:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5f                   	pop    %edi
  80161e:	5d                   	pop    %ebp
  80161f:	c3                   	ret    

00801620 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	53                   	push   %ebx
  801624:	83 ec 14             	sub    $0x14,%esp
  801627:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	53                   	push   %ebx
  80162f:	e8 ac fc ff ff       	call   8012e0 <fd_lookup>
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	89 c2                	mov    %eax,%edx
  801639:	85 c0                	test   %eax,%eax
  80163b:	78 68                	js     8016a5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163d:	83 ec 08             	sub    $0x8,%esp
  801640:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801647:	ff 30                	pushl  (%eax)
  801649:	e8 e8 fc ff ff       	call   801336 <dev_lookup>
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	85 c0                	test   %eax,%eax
  801653:	78 47                	js     80169c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801655:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801658:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80165c:	75 21                	jne    80167f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80165e:	a1 04 40 80 00       	mov    0x804004,%eax
  801663:	8b 40 48             	mov    0x48(%eax),%eax
  801666:	83 ec 04             	sub    $0x4,%esp
  801669:	53                   	push   %ebx
  80166a:	50                   	push   %eax
  80166b:	68 78 28 80 00       	push   $0x802878
  801670:	e8 a8 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80167d:	eb 26                	jmp    8016a5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80167f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801682:	8b 52 0c             	mov    0xc(%edx),%edx
  801685:	85 d2                	test   %edx,%edx
  801687:	74 17                	je     8016a0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801689:	83 ec 04             	sub    $0x4,%esp
  80168c:	ff 75 10             	pushl  0x10(%ebp)
  80168f:	ff 75 0c             	pushl  0xc(%ebp)
  801692:	50                   	push   %eax
  801693:	ff d2                	call   *%edx
  801695:	89 c2                	mov    %eax,%edx
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	eb 09                	jmp    8016a5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169c:	89 c2                	mov    %eax,%edx
  80169e:	eb 05                	jmp    8016a5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016a5:	89 d0                	mov    %edx,%eax
  8016a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016b5:	50                   	push   %eax
  8016b6:	ff 75 08             	pushl  0x8(%ebp)
  8016b9:	e8 22 fc ff ff       	call   8012e0 <fd_lookup>
  8016be:	83 c4 08             	add    $0x8,%esp
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 0e                	js     8016d3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016cb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 14             	sub    $0x14,%esp
  8016dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	53                   	push   %ebx
  8016e4:	e8 f7 fb ff ff       	call   8012e0 <fd_lookup>
  8016e9:	83 c4 08             	add    $0x8,%esp
  8016ec:	89 c2                	mov    %eax,%edx
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 65                	js     801757 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f2:	83 ec 08             	sub    $0x8,%esp
  8016f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f8:	50                   	push   %eax
  8016f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fc:	ff 30                	pushl  (%eax)
  8016fe:	e8 33 fc ff ff       	call   801336 <dev_lookup>
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	78 44                	js     80174e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801711:	75 21                	jne    801734 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801713:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801718:	8b 40 48             	mov    0x48(%eax),%eax
  80171b:	83 ec 04             	sub    $0x4,%esp
  80171e:	53                   	push   %ebx
  80171f:	50                   	push   %eax
  801720:	68 38 28 80 00       	push   $0x802838
  801725:	e8 f3 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801732:	eb 23                	jmp    801757 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801734:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801737:	8b 52 18             	mov    0x18(%edx),%edx
  80173a:	85 d2                	test   %edx,%edx
  80173c:	74 14                	je     801752 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80173e:	83 ec 08             	sub    $0x8,%esp
  801741:	ff 75 0c             	pushl  0xc(%ebp)
  801744:	50                   	push   %eax
  801745:	ff d2                	call   *%edx
  801747:	89 c2                	mov    %eax,%edx
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	eb 09                	jmp    801757 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174e:	89 c2                	mov    %eax,%edx
  801750:	eb 05                	jmp    801757 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801752:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801757:	89 d0                	mov    %edx,%eax
  801759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	53                   	push   %ebx
  801762:	83 ec 14             	sub    $0x14,%esp
  801765:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801768:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	ff 75 08             	pushl  0x8(%ebp)
  80176f:	e8 6c fb ff ff       	call   8012e0 <fd_lookup>
  801774:	83 c4 08             	add    $0x8,%esp
  801777:	89 c2                	mov    %eax,%edx
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 58                	js     8017d5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177d:	83 ec 08             	sub    $0x8,%esp
  801780:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801783:	50                   	push   %eax
  801784:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801787:	ff 30                	pushl  (%eax)
  801789:	e8 a8 fb ff ff       	call   801336 <dev_lookup>
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	85 c0                	test   %eax,%eax
  801793:	78 37                	js     8017cc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801795:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801798:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80179c:	74 32                	je     8017d0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80179e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017a8:	00 00 00 
	stat->st_isdir = 0;
  8017ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b2:	00 00 00 
	stat->st_dev = dev;
  8017b5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	53                   	push   %ebx
  8017bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c2:	ff 50 14             	call   *0x14(%eax)
  8017c5:	89 c2                	mov    %eax,%edx
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	eb 09                	jmp    8017d5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cc:	89 c2                	mov    %eax,%edx
  8017ce:	eb 05                	jmp    8017d5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017d5:	89 d0                	mov    %edx,%eax
  8017d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	56                   	push   %esi
  8017e0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e1:	83 ec 08             	sub    $0x8,%esp
  8017e4:	6a 00                	push   $0x0
  8017e6:	ff 75 08             	pushl  0x8(%ebp)
  8017e9:	e8 2c 02 00 00       	call   801a1a <open>
  8017ee:	89 c3                	mov    %eax,%ebx
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 1b                	js     801812 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	ff 75 0c             	pushl  0xc(%ebp)
  8017fd:	50                   	push   %eax
  8017fe:	e8 5b ff ff ff       	call   80175e <fstat>
  801803:	89 c6                	mov    %eax,%esi
	close(fd);
  801805:	89 1c 24             	mov    %ebx,(%esp)
  801808:	e8 fd fb ff ff       	call   80140a <close>
	return r;
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	89 f0                	mov    %esi,%eax
}
  801812:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801815:	5b                   	pop    %ebx
  801816:	5e                   	pop    %esi
  801817:	5d                   	pop    %ebp
  801818:	c3                   	ret    

00801819 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	56                   	push   %esi
  80181d:	53                   	push   %ebx
  80181e:	89 c6                	mov    %eax,%esi
  801820:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  801822:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801829:	75 12                	jne    80183d <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  80182b:	83 ec 0c             	sub    $0xc,%esp
  80182e:	6a 01                	push   $0x1
  801830:	e8 fc f9 ff ff       	call   801231 <ipc_find_env>
  801835:	a3 00 40 80 00       	mov    %eax,0x804000
  80183a:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80183d:	6a 07                	push   $0x7
  80183f:	68 00 50 80 00       	push   $0x805000
  801844:	56                   	push   %esi
  801845:	ff 35 00 40 80 00    	pushl  0x804000
  80184b:	e8 8d f9 ff ff       	call   8011dd <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  801850:	83 c4 0c             	add    $0xc,%esp
  801853:	6a 00                	push   $0x0
  801855:	53                   	push   %ebx
  801856:	6a 00                	push   $0x0
  801858:	e8 21 f9 ff ff       	call   80117e <ipc_recv>
}
  80185d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801860:	5b                   	pop    %ebx
  801861:	5e                   	pop    %esi
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 40 0c             	mov    0xc(%eax),%eax
  801870:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  801875:	8b 45 0c             	mov    0xc(%ebp),%eax
  801878:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80187d:	ba 00 00 00 00       	mov    $0x0,%edx
  801882:	b8 02 00 00 00       	mov    $0x2,%eax
  801887:	e8 8d ff ff ff       	call   801819 <fsipc>
}
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801894:	8b 45 08             	mov    0x8(%ebp),%eax
  801897:	8b 40 0c             	mov    0xc(%eax),%eax
  80189a:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  80189f:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8018a9:	e8 6b ff ff ff       	call   801819 <fsipc>
}
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	53                   	push   %ebx
  8018b4:	83 ec 04             	sub    $0x4,%esp
  8018b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c0:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8018cf:	e8 45 ff ff ff       	call   801819 <fsipc>
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	78 2c                	js     801904 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018d8:	83 ec 08             	sub    $0x8,%esp
  8018db:	68 00 50 80 00       	push   $0x805000
  8018e0:	53                   	push   %ebx
  8018e1:	e8 bc ef ff ff       	call   8008a2 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8018e6:	a1 80 50 80 00       	mov    0x805080,%eax
  8018eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018f1:	a1 84 50 80 00       	mov    0x805084,%eax
  8018f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801904:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801907:	c9                   	leave  
  801908:	c3                   	ret    

00801909 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	53                   	push   %ebx
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  801913:	8b 45 08             	mov    0x8(%ebp),%eax
  801916:	8b 40 0c             	mov    0xc(%eax),%eax
  801919:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  80191e:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  801924:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  80192a:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  80192f:	0f 46 c3             	cmovbe %ebx,%eax
  801932:	50                   	push   %eax
  801933:	ff 75 0c             	pushl  0xc(%ebp)
  801936:	68 08 50 80 00       	push   $0x805008
  80193b:	e8 f4 f0 ff ff       	call   800a34 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  801940:	ba 00 00 00 00       	mov    $0x0,%edx
  801945:	b8 04 00 00 00       	mov    $0x4,%eax
  80194a:	e8 ca fe ff ff       	call   801819 <fsipc>
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	85 c0                	test   %eax,%eax
  801954:	78 3d                	js     801993 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  801956:	39 c3                	cmp    %eax,%ebx
  801958:	73 19                	jae    801973 <devfile_write+0x6a>
  80195a:	68 a8 28 80 00       	push   $0x8028a8
  80195f:	68 af 28 80 00       	push   $0x8028af
  801964:	68 9a 00 00 00       	push   $0x9a
  801969:	68 c4 28 80 00       	push   $0x8028c4
  80196e:	e8 d1 e8 ff ff       	call   800244 <_panic>
	   assert (r <= bytes_written);
  801973:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801978:	7e 19                	jle    801993 <devfile_write+0x8a>
  80197a:	68 cf 28 80 00       	push   $0x8028cf
  80197f:	68 af 28 80 00       	push   $0x8028af
  801984:	68 9b 00 00 00       	push   $0x9b
  801989:	68 c4 28 80 00       	push   $0x8028c4
  80198e:	e8 b1 e8 ff ff       	call   800244 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801993:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	56                   	push   %esi
  80199c:	53                   	push   %ebx
  80199d:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a6:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  8019ab:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b6:	b8 03 00 00 00       	mov    $0x3,%eax
  8019bb:	e8 59 fe ff ff       	call   801819 <fsipc>
  8019c0:	89 c3                	mov    %eax,%ebx
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	78 4b                	js     801a11 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  8019c6:	39 c6                	cmp    %eax,%esi
  8019c8:	73 16                	jae    8019e0 <devfile_read+0x48>
  8019ca:	68 a8 28 80 00       	push   $0x8028a8
  8019cf:	68 af 28 80 00       	push   $0x8028af
  8019d4:	6a 7c                	push   $0x7c
  8019d6:	68 c4 28 80 00       	push   $0x8028c4
  8019db:	e8 64 e8 ff ff       	call   800244 <_panic>
	   assert(r <= PGSIZE);
  8019e0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019e5:	7e 16                	jle    8019fd <devfile_read+0x65>
  8019e7:	68 e2 28 80 00       	push   $0x8028e2
  8019ec:	68 af 28 80 00       	push   $0x8028af
  8019f1:	6a 7d                	push   $0x7d
  8019f3:	68 c4 28 80 00       	push   $0x8028c4
  8019f8:	e8 47 e8 ff ff       	call   800244 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019fd:	83 ec 04             	sub    $0x4,%esp
  801a00:	50                   	push   %eax
  801a01:	68 00 50 80 00       	push   $0x805000
  801a06:	ff 75 0c             	pushl  0xc(%ebp)
  801a09:	e8 26 f0 ff ff       	call   800a34 <memmove>
	   return r;
  801a0e:	83 c4 10             	add    $0x10,%esp
}
  801a11:	89 d8                	mov    %ebx,%eax
  801a13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a16:	5b                   	pop    %ebx
  801a17:	5e                   	pop    %esi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	53                   	push   %ebx
  801a1e:	83 ec 20             	sub    $0x20,%esp
  801a21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  801a24:	53                   	push   %ebx
  801a25:	e8 3f ee ff ff       	call   800869 <strlen>
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a32:	7f 67                	jg     801a9b <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3a:	50                   	push   %eax
  801a3b:	e8 51 f8 ff ff       	call   801291 <fd_alloc>
  801a40:	83 c4 10             	add    $0x10,%esp
			 return r;
  801a43:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801a45:	85 c0                	test   %eax,%eax
  801a47:	78 57                	js     801aa0 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  801a49:	83 ec 08             	sub    $0x8,%esp
  801a4c:	53                   	push   %ebx
  801a4d:	68 00 50 80 00       	push   $0x805000
  801a52:	e8 4b ee ff ff       	call   8008a2 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  801a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5a:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a62:	b8 01 00 00 00       	mov    $0x1,%eax
  801a67:	e8 ad fd ff ff       	call   801819 <fsipc>
  801a6c:	89 c3                	mov    %eax,%ebx
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	85 c0                	test   %eax,%eax
  801a73:	79 14                	jns    801a89 <open+0x6f>
			 fd_close(fd, 0);
  801a75:	83 ec 08             	sub    $0x8,%esp
  801a78:	6a 00                	push   $0x0
  801a7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7d:	e8 07 f9 ff ff       	call   801389 <fd_close>
			 return r;
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	89 da                	mov    %ebx,%edx
  801a87:	eb 17                	jmp    801aa0 <open+0x86>
	   }

	   return fd2num(fd);
  801a89:	83 ec 0c             	sub    $0xc,%esp
  801a8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8f:	e8 d6 f7 ff ff       	call   80126a <fd2num>
  801a94:	89 c2                	mov    %eax,%edx
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	eb 05                	jmp    801aa0 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  801a9b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801aa0:	89 d0                	mov    %edx,%eax
  801aa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801aad:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab2:	b8 08 00 00 00       	mov    $0x8,%eax
  801ab7:	e8 5d fd ff ff       	call   801819 <fsipc>
}
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    

00801abe <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ac4:	89 d0                	mov    %edx,%eax
  801ac6:	c1 e8 16             	shr    $0x16,%eax
  801ac9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ad0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ad5:	f6 c1 01             	test   $0x1,%cl
  801ad8:	74 1d                	je     801af7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ada:	c1 ea 0c             	shr    $0xc,%edx
  801add:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ae4:	f6 c2 01             	test   $0x1,%dl
  801ae7:	74 0e                	je     801af7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ae9:	c1 ea 0c             	shr    $0xc,%edx
  801aec:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801af3:	ef 
  801af4:	0f b7 c0             	movzwl %ax,%eax
}
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	56                   	push   %esi
  801afd:	53                   	push   %ebx
  801afe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b01:	83 ec 0c             	sub    $0xc,%esp
  801b04:	ff 75 08             	pushl  0x8(%ebp)
  801b07:	e8 6e f7 ff ff       	call   80127a <fd2data>
  801b0c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b0e:	83 c4 08             	add    $0x8,%esp
  801b11:	68 ee 28 80 00       	push   $0x8028ee
  801b16:	53                   	push   %ebx
  801b17:	e8 86 ed ff ff       	call   8008a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b1c:	8b 46 04             	mov    0x4(%esi),%eax
  801b1f:	2b 06                	sub    (%esi),%eax
  801b21:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b27:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b2e:	00 00 00 
	stat->st_dev = &devpipe;
  801b31:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b38:	30 80 00 
	return 0;
}
  801b3b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5e                   	pop    %esi
  801b45:	5d                   	pop    %ebp
  801b46:	c3                   	ret    

00801b47 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	53                   	push   %ebx
  801b4b:	83 ec 0c             	sub    $0xc,%esp
  801b4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b51:	53                   	push   %ebx
  801b52:	6a 00                	push   $0x0
  801b54:	e8 d1 f1 ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b59:	89 1c 24             	mov    %ebx,(%esp)
  801b5c:	e8 19 f7 ff ff       	call   80127a <fd2data>
  801b61:	83 c4 08             	add    $0x8,%esp
  801b64:	50                   	push   %eax
  801b65:	6a 00                	push   $0x0
  801b67:	e8 be f1 ff ff       	call   800d2a <sys_page_unmap>
}
  801b6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b6f:	c9                   	leave  
  801b70:	c3                   	ret    

00801b71 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	57                   	push   %edi
  801b75:	56                   	push   %esi
  801b76:	53                   	push   %ebx
  801b77:	83 ec 1c             	sub    $0x1c,%esp
  801b7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b7d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b7f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b84:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b87:	83 ec 0c             	sub    $0xc,%esp
  801b8a:	ff 75 e0             	pushl  -0x20(%ebp)
  801b8d:	e8 2c ff ff ff       	call   801abe <pageref>
  801b92:	89 c3                	mov    %eax,%ebx
  801b94:	89 3c 24             	mov    %edi,(%esp)
  801b97:	e8 22 ff ff ff       	call   801abe <pageref>
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	39 c3                	cmp    %eax,%ebx
  801ba1:	0f 94 c1             	sete   %cl
  801ba4:	0f b6 c9             	movzbl %cl,%ecx
  801ba7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801baa:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bb0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bb3:	39 ce                	cmp    %ecx,%esi
  801bb5:	74 1b                	je     801bd2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bb7:	39 c3                	cmp    %eax,%ebx
  801bb9:	75 c4                	jne    801b7f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bbb:	8b 42 58             	mov    0x58(%edx),%eax
  801bbe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bc1:	50                   	push   %eax
  801bc2:	56                   	push   %esi
  801bc3:	68 f5 28 80 00       	push   $0x8028f5
  801bc8:	e8 50 e7 ff ff       	call   80031d <cprintf>
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	eb ad                	jmp    801b7f <_pipeisclosed+0xe>
	}
}
  801bd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd8:	5b                   	pop    %ebx
  801bd9:	5e                   	pop    %esi
  801bda:	5f                   	pop    %edi
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	57                   	push   %edi
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	83 ec 28             	sub    $0x28,%esp
  801be6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801be9:	56                   	push   %esi
  801bea:	e8 8b f6 ff ff       	call   80127a <fd2data>
  801bef:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	bf 00 00 00 00       	mov    $0x0,%edi
  801bf9:	eb 4b                	jmp    801c46 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bfb:	89 da                	mov    %ebx,%edx
  801bfd:	89 f0                	mov    %esi,%eax
  801bff:	e8 6d ff ff ff       	call   801b71 <_pipeisclosed>
  801c04:	85 c0                	test   %eax,%eax
  801c06:	75 48                	jne    801c50 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c08:	e8 79 f0 ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c0d:	8b 43 04             	mov    0x4(%ebx),%eax
  801c10:	8b 0b                	mov    (%ebx),%ecx
  801c12:	8d 51 20             	lea    0x20(%ecx),%edx
  801c15:	39 d0                	cmp    %edx,%eax
  801c17:	73 e2                	jae    801bfb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c1c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c20:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c23:	89 c2                	mov    %eax,%edx
  801c25:	c1 fa 1f             	sar    $0x1f,%edx
  801c28:	89 d1                	mov    %edx,%ecx
  801c2a:	c1 e9 1b             	shr    $0x1b,%ecx
  801c2d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c30:	83 e2 1f             	and    $0x1f,%edx
  801c33:	29 ca                	sub    %ecx,%edx
  801c35:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c39:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c3d:	83 c0 01             	add    $0x1,%eax
  801c40:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c43:	83 c7 01             	add    $0x1,%edi
  801c46:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c49:	75 c2                	jne    801c0d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c4b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c4e:	eb 05                	jmp    801c55 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c50:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c58:	5b                   	pop    %ebx
  801c59:	5e                   	pop    %esi
  801c5a:	5f                   	pop    %edi
  801c5b:	5d                   	pop    %ebp
  801c5c:	c3                   	ret    

00801c5d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	57                   	push   %edi
  801c61:	56                   	push   %esi
  801c62:	53                   	push   %ebx
  801c63:	83 ec 18             	sub    $0x18,%esp
  801c66:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c69:	57                   	push   %edi
  801c6a:	e8 0b f6 ff ff       	call   80127a <fd2data>
  801c6f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c79:	eb 3d                	jmp    801cb8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c7b:	85 db                	test   %ebx,%ebx
  801c7d:	74 04                	je     801c83 <devpipe_read+0x26>
				return i;
  801c7f:	89 d8                	mov    %ebx,%eax
  801c81:	eb 44                	jmp    801cc7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c83:	89 f2                	mov    %esi,%edx
  801c85:	89 f8                	mov    %edi,%eax
  801c87:	e8 e5 fe ff ff       	call   801b71 <_pipeisclosed>
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	75 32                	jne    801cc2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c90:	e8 f1 ef ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c95:	8b 06                	mov    (%esi),%eax
  801c97:	3b 46 04             	cmp    0x4(%esi),%eax
  801c9a:	74 df                	je     801c7b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c9c:	99                   	cltd   
  801c9d:	c1 ea 1b             	shr    $0x1b,%edx
  801ca0:	01 d0                	add    %edx,%eax
  801ca2:	83 e0 1f             	and    $0x1f,%eax
  801ca5:	29 d0                	sub    %edx,%eax
  801ca7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801caf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cb2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb5:	83 c3 01             	add    $0x1,%ebx
  801cb8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cbb:	75 d8                	jne    801c95 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cbd:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc0:	eb 05                	jmp    801cc7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cc2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5f                   	pop    %edi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cda:	50                   	push   %eax
  801cdb:	e8 b1 f5 ff ff       	call   801291 <fd_alloc>
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	89 c2                	mov    %eax,%edx
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	0f 88 2c 01 00 00    	js     801e19 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ced:	83 ec 04             	sub    $0x4,%esp
  801cf0:	68 07 04 00 00       	push   $0x407
  801cf5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf8:	6a 00                	push   $0x0
  801cfa:	e8 a6 ef ff ff       	call   800ca5 <sys_page_alloc>
  801cff:	83 c4 10             	add    $0x10,%esp
  801d02:	89 c2                	mov    %eax,%edx
  801d04:	85 c0                	test   %eax,%eax
  801d06:	0f 88 0d 01 00 00    	js     801e19 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d0c:	83 ec 0c             	sub    $0xc,%esp
  801d0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d12:	50                   	push   %eax
  801d13:	e8 79 f5 ff ff       	call   801291 <fd_alloc>
  801d18:	89 c3                	mov    %eax,%ebx
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	0f 88 e2 00 00 00    	js     801e07 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d25:	83 ec 04             	sub    $0x4,%esp
  801d28:	68 07 04 00 00       	push   $0x407
  801d2d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d30:	6a 00                	push   $0x0
  801d32:	e8 6e ef ff ff       	call   800ca5 <sys_page_alloc>
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	0f 88 c3 00 00 00    	js     801e07 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d44:	83 ec 0c             	sub    $0xc,%esp
  801d47:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4a:	e8 2b f5 ff ff       	call   80127a <fd2data>
  801d4f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d51:	83 c4 0c             	add    $0xc,%esp
  801d54:	68 07 04 00 00       	push   $0x407
  801d59:	50                   	push   %eax
  801d5a:	6a 00                	push   $0x0
  801d5c:	e8 44 ef ff ff       	call   800ca5 <sys_page_alloc>
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	85 c0                	test   %eax,%eax
  801d68:	0f 88 89 00 00 00    	js     801df7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d6e:	83 ec 0c             	sub    $0xc,%esp
  801d71:	ff 75 f0             	pushl  -0x10(%ebp)
  801d74:	e8 01 f5 ff ff       	call   80127a <fd2data>
  801d79:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d80:	50                   	push   %eax
  801d81:	6a 00                	push   $0x0
  801d83:	56                   	push   %esi
  801d84:	6a 00                	push   $0x0
  801d86:	e8 5d ef ff ff       	call   800ce8 <sys_page_map>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	83 c4 20             	add    $0x20,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 55                	js     801de9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d94:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801da9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dbe:	83 ec 0c             	sub    $0xc,%esp
  801dc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc4:	e8 a1 f4 ff ff       	call   80126a <fd2num>
  801dc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dcc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dce:	83 c4 04             	add    $0x4,%esp
  801dd1:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd4:	e8 91 f4 ff ff       	call   80126a <fd2num>
  801dd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ddc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	ba 00 00 00 00       	mov    $0x0,%edx
  801de7:	eb 30                	jmp    801e19 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801de9:	83 ec 08             	sub    $0x8,%esp
  801dec:	56                   	push   %esi
  801ded:	6a 00                	push   $0x0
  801def:	e8 36 ef ff ff       	call   800d2a <sys_page_unmap>
  801df4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801df7:	83 ec 08             	sub    $0x8,%esp
  801dfa:	ff 75 f0             	pushl  -0x10(%ebp)
  801dfd:	6a 00                	push   $0x0
  801dff:	e8 26 ef ff ff       	call   800d2a <sys_page_unmap>
  801e04:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0d:	6a 00                	push   $0x0
  801e0f:	e8 16 ef ff ff       	call   800d2a <sys_page_unmap>
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e19:	89 d0                	mov    %edx,%eax
  801e1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e1e:	5b                   	pop    %ebx
  801e1f:	5e                   	pop    %esi
  801e20:	5d                   	pop    %ebp
  801e21:	c3                   	ret    

00801e22 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2b:	50                   	push   %eax
  801e2c:	ff 75 08             	pushl  0x8(%ebp)
  801e2f:	e8 ac f4 ff ff       	call   8012e0 <fd_lookup>
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 18                	js     801e53 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e3b:	83 ec 0c             	sub    $0xc,%esp
  801e3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e41:	e8 34 f4 ff ff       	call   80127a <fd2data>
	return _pipeisclosed(fd, p);
  801e46:	89 c2                	mov    %eax,%edx
  801e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4b:	e8 21 fd ff ff       	call   801b71 <_pipeisclosed>
  801e50:	83 c4 10             	add    $0x10,%esp
}
  801e53:	c9                   	leave  
  801e54:	c3                   	ret    

00801e55 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e58:	b8 00 00 00 00       	mov    $0x0,%eax
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    

00801e5f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e65:	68 0d 29 80 00       	push   $0x80290d
  801e6a:	ff 75 0c             	pushl  0xc(%ebp)
  801e6d:	e8 30 ea ff ff       	call   8008a2 <strcpy>
	return 0;
}
  801e72:	b8 00 00 00 00       	mov    $0x0,%eax
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	57                   	push   %edi
  801e7d:	56                   	push   %esi
  801e7e:	53                   	push   %ebx
  801e7f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e85:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e8a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e90:	eb 2d                	jmp    801ebf <devcons_write+0x46>
		m = n - tot;
  801e92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e95:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e97:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e9a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e9f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ea2:	83 ec 04             	sub    $0x4,%esp
  801ea5:	53                   	push   %ebx
  801ea6:	03 45 0c             	add    0xc(%ebp),%eax
  801ea9:	50                   	push   %eax
  801eaa:	57                   	push   %edi
  801eab:	e8 84 eb ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  801eb0:	83 c4 08             	add    $0x8,%esp
  801eb3:	53                   	push   %ebx
  801eb4:	57                   	push   %edi
  801eb5:	e8 2f ed ff ff       	call   800be9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eba:	01 de                	add    %ebx,%esi
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	89 f0                	mov    %esi,%eax
  801ec1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ec4:	72 cc                	jb     801e92 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ec6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec9:	5b                   	pop    %ebx
  801eca:	5e                   	pop    %esi
  801ecb:	5f                   	pop    %edi
  801ecc:	5d                   	pop    %ebp
  801ecd:	c3                   	ret    

00801ece <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 08             	sub    $0x8,%esp
  801ed4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ed9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801edd:	74 2a                	je     801f09 <devcons_read+0x3b>
  801edf:	eb 05                	jmp    801ee6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ee1:	e8 a0 ed ff ff       	call   800c86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ee6:	e8 1c ed ff ff       	call   800c07 <sys_cgetc>
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	74 f2                	je     801ee1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	78 16                	js     801f09 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ef3:	83 f8 04             	cmp    $0x4,%eax
  801ef6:	74 0c                	je     801f04 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ef8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801efb:	88 02                	mov    %al,(%edx)
	return 1;
  801efd:	b8 01 00 00 00       	mov    $0x1,%eax
  801f02:	eb 05                	jmp    801f09 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f04:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f09:	c9                   	leave  
  801f0a:	c3                   	ret    

00801f0b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f11:	8b 45 08             	mov    0x8(%ebp),%eax
  801f14:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f17:	6a 01                	push   $0x1
  801f19:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f1c:	50                   	push   %eax
  801f1d:	e8 c7 ec ff ff       	call   800be9 <sys_cputs>
}
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	c9                   	leave  
  801f26:	c3                   	ret    

00801f27 <getchar>:

int
getchar(void)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f2d:	6a 01                	push   $0x1
  801f2f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f32:	50                   	push   %eax
  801f33:	6a 00                	push   $0x0
  801f35:	e8 0c f6 ff ff       	call   801546 <read>
	if (r < 0)
  801f3a:	83 c4 10             	add    $0x10,%esp
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	78 0f                	js     801f50 <getchar+0x29>
		return r;
	if (r < 1)
  801f41:	85 c0                	test   %eax,%eax
  801f43:	7e 06                	jle    801f4b <getchar+0x24>
		return -E_EOF;
	return c;
  801f45:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f49:	eb 05                	jmp    801f50 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f4b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    

00801f52 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5b:	50                   	push   %eax
  801f5c:	ff 75 08             	pushl  0x8(%ebp)
  801f5f:	e8 7c f3 ff ff       	call   8012e0 <fd_lookup>
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	85 c0                	test   %eax,%eax
  801f69:	78 11                	js     801f7c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f74:	39 10                	cmp    %edx,(%eax)
  801f76:	0f 94 c0             	sete   %al
  801f79:	0f b6 c0             	movzbl %al,%eax
}
  801f7c:	c9                   	leave  
  801f7d:	c3                   	ret    

00801f7e <opencons>:

int
opencons(void)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f87:	50                   	push   %eax
  801f88:	e8 04 f3 ff ff       	call   801291 <fd_alloc>
  801f8d:	83 c4 10             	add    $0x10,%esp
		return r;
  801f90:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f92:	85 c0                	test   %eax,%eax
  801f94:	78 3e                	js     801fd4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f96:	83 ec 04             	sub    $0x4,%esp
  801f99:	68 07 04 00 00       	push   $0x407
  801f9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa1:	6a 00                	push   $0x0
  801fa3:	e8 fd ec ff ff       	call   800ca5 <sys_page_alloc>
  801fa8:	83 c4 10             	add    $0x10,%esp
		return r;
  801fab:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fad:	85 c0                	test   %eax,%eax
  801faf:	78 23                	js     801fd4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fb1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fba:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fc6:	83 ec 0c             	sub    $0xc,%esp
  801fc9:	50                   	push   %eax
  801fca:	e8 9b f2 ff ff       	call   80126a <fd2num>
  801fcf:	89 c2                	mov    %eax,%edx
  801fd1:	83 c4 10             	add    $0x10,%esp
}
  801fd4:	89 d0                	mov    %edx,%eax
  801fd6:	c9                   	leave  
  801fd7:	c3                   	ret    

00801fd8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  801fde:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fe5:	75 2a                	jne    802011 <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801fe7:	83 ec 04             	sub    $0x4,%esp
  801fea:	6a 06                	push   $0x6
  801fec:	68 00 f0 bf ee       	push   $0xeebff000
  801ff1:	6a 00                	push   $0x0
  801ff3:	e8 ad ec ff ff       	call   800ca5 <sys_page_alloc>
			 if (a < 0)
  801ff8:	83 c4 10             	add    $0x10,%esp
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	79 12                	jns    802011 <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801fff:	50                   	push   %eax
  802000:	68 19 29 80 00       	push   $0x802919
  802005:	6a 21                	push   $0x21
  802007:	68 33 29 80 00       	push   $0x802933
  80200c:	e8 33 e2 ff ff       	call   800244 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  802011:	e8 51 ec ff ff       	call   800c67 <sys_getenvid>
  802016:	83 ec 08             	sub    $0x8,%esp
  802019:	68 31 20 80 00       	push   $0x802031
  80201e:	50                   	push   %eax
  80201f:	e8 cc ed ff ff       	call   800df0 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  802024:	8b 45 08             	mov    0x8(%ebp),%eax
  802027:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80202c:	83 c4 10             	add    $0x10,%esp
  80202f:	c9                   	leave  
  802030:	c3                   	ret    

00802031 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  802031:	54                   	push   %esp
movl _pgfault_handler, %eax
  802032:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  802037:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  802039:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  80203c:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  802040:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  802044:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  802047:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  80204b:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  80204d:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  802050:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  802051:	83 c4 04             	add    $0x4,%esp
popfl
  802054:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  802055:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  802056:	c3                   	ret    
  802057:	66 90                	xchg   %ax,%ax
  802059:	66 90                	xchg   %ax,%ax
  80205b:	66 90                	xchg   %ax,%ax
  80205d:	66 90                	xchg   %ax,%ax
  80205f:	90                   	nop

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80206b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80206f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 f6                	test   %esi,%esi
  802079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80207d:	89 ca                	mov    %ecx,%edx
  80207f:	89 f8                	mov    %edi,%eax
  802081:	75 3d                	jne    8020c0 <__udivdi3+0x60>
  802083:	39 cf                	cmp    %ecx,%edi
  802085:	0f 87 c5 00 00 00    	ja     802150 <__udivdi3+0xf0>
  80208b:	85 ff                	test   %edi,%edi
  80208d:	89 fd                	mov    %edi,%ebp
  80208f:	75 0b                	jne    80209c <__udivdi3+0x3c>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	31 d2                	xor    %edx,%edx
  802098:	f7 f7                	div    %edi
  80209a:	89 c5                	mov    %eax,%ebp
  80209c:	89 c8                	mov    %ecx,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f5                	div    %ebp
  8020a2:	89 c1                	mov    %eax,%ecx
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	89 cf                	mov    %ecx,%edi
  8020a8:	f7 f5                	div    %ebp
  8020aa:	89 c3                	mov    %eax,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	39 ce                	cmp    %ecx,%esi
  8020c2:	77 74                	ja     802138 <__udivdi3+0xd8>
  8020c4:	0f bd fe             	bsr    %esi,%edi
  8020c7:	83 f7 1f             	xor    $0x1f,%edi
  8020ca:	0f 84 98 00 00 00    	je     802168 <__udivdi3+0x108>
  8020d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	89 c5                	mov    %eax,%ebp
  8020d9:	29 fb                	sub    %edi,%ebx
  8020db:	d3 e6                	shl    %cl,%esi
  8020dd:	89 d9                	mov    %ebx,%ecx
  8020df:	d3 ed                	shr    %cl,%ebp
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	09 ee                	or     %ebp,%esi
  8020e7:	89 d9                	mov    %ebx,%ecx
  8020e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ed:	89 d5                	mov    %edx,%ebp
  8020ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020f3:	d3 ed                	shr    %cl,%ebp
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e2                	shl    %cl,%edx
  8020f9:	89 d9                	mov    %ebx,%ecx
  8020fb:	d3 e8                	shr    %cl,%eax
  8020fd:	09 c2                	or     %eax,%edx
  8020ff:	89 d0                	mov    %edx,%eax
  802101:	89 ea                	mov    %ebp,%edx
  802103:	f7 f6                	div    %esi
  802105:	89 d5                	mov    %edx,%ebp
  802107:	89 c3                	mov    %eax,%ebx
  802109:	f7 64 24 0c          	mull   0xc(%esp)
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	72 10                	jb     802121 <__udivdi3+0xc1>
  802111:	8b 74 24 08          	mov    0x8(%esp),%esi
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e6                	shl    %cl,%esi
  802119:	39 c6                	cmp    %eax,%esi
  80211b:	73 07                	jae    802124 <__udivdi3+0xc4>
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	75 03                	jne    802124 <__udivdi3+0xc4>
  802121:	83 eb 01             	sub    $0x1,%ebx
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 d8                	mov    %ebx,%eax
  802128:	89 fa                	mov    %edi,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	31 ff                	xor    %edi,%edi
  80213a:	31 db                	xor    %ebx,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 d8                	mov    %ebx,%eax
  802152:	f7 f7                	div    %edi
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 c3                	mov    %eax,%ebx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 fa                	mov    %edi,%edx
  80215c:	83 c4 1c             	add    $0x1c,%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5f                   	pop    %edi
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	39 ce                	cmp    %ecx,%esi
  80216a:	72 0c                	jb     802178 <__udivdi3+0x118>
  80216c:	31 db                	xor    %ebx,%ebx
  80216e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802172:	0f 87 34 ff ff ff    	ja     8020ac <__udivdi3+0x4c>
  802178:	bb 01 00 00 00       	mov    $0x1,%ebx
  80217d:	e9 2a ff ff ff       	jmp    8020ac <__udivdi3+0x4c>
  802182:	66 90                	xchg   %ax,%ax
  802184:	66 90                	xchg   %ax,%ax
  802186:	66 90                	xchg   %ax,%ax
  802188:	66 90                	xchg   %ax,%ax
  80218a:	66 90                	xchg   %ax,%ax
  80218c:	66 90                	xchg   %ax,%ax
  80218e:	66 90                	xchg   %ax,%ax

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80219b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80219f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 d2                	test   %edx,%edx
  8021a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b1:	89 f3                	mov    %esi,%ebx
  8021b3:	89 3c 24             	mov    %edi,(%esp)
  8021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ba:	75 1c                	jne    8021d8 <__umoddi3+0x48>
  8021bc:	39 f7                	cmp    %esi,%edi
  8021be:	76 50                	jbe    802210 <__umoddi3+0x80>
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	f7 f7                	div    %edi
  8021c6:	89 d0                	mov    %edx,%eax
  8021c8:	31 d2                	xor    %edx,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	89 d0                	mov    %edx,%eax
  8021dc:	77 52                	ja     802230 <__umoddi3+0xa0>
  8021de:	0f bd ea             	bsr    %edx,%ebp
  8021e1:	83 f5 1f             	xor    $0x1f,%ebp
  8021e4:	75 5a                	jne    802240 <__umoddi3+0xb0>
  8021e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ea:	0f 82 e0 00 00 00    	jb     8022d0 <__umoddi3+0x140>
  8021f0:	39 0c 24             	cmp    %ecx,(%esp)
  8021f3:	0f 86 d7 00 00 00    	jbe    8022d0 <__umoddi3+0x140>
  8021f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802201:	83 c4 1c             	add    $0x1c,%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	85 ff                	test   %edi,%edi
  802212:	89 fd                	mov    %edi,%ebp
  802214:	75 0b                	jne    802221 <__umoddi3+0x91>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f7                	div    %edi
  80221f:	89 c5                	mov    %eax,%ebp
  802221:	89 f0                	mov    %esi,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f5                	div    %ebp
  802227:	89 c8                	mov    %ecx,%eax
  802229:	f7 f5                	div    %ebp
  80222b:	89 d0                	mov    %edx,%eax
  80222d:	eb 99                	jmp    8021c8 <__umoddi3+0x38>
  80222f:	90                   	nop
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	8b 34 24             	mov    (%esp),%esi
  802243:	bf 20 00 00 00       	mov    $0x20,%edi
  802248:	89 e9                	mov    %ebp,%ecx
  80224a:	29 ef                	sub    %ebp,%edi
  80224c:	d3 e0                	shl    %cl,%eax
  80224e:	89 f9                	mov    %edi,%ecx
  802250:	89 f2                	mov    %esi,%edx
  802252:	d3 ea                	shr    %cl,%edx
  802254:	89 e9                	mov    %ebp,%ecx
  802256:	09 c2                	or     %eax,%edx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 14 24             	mov    %edx,(%esp)
  80225d:	89 f2                	mov    %esi,%edx
  80225f:	d3 e2                	shl    %cl,%edx
  802261:	89 f9                	mov    %edi,%ecx
  802263:	89 54 24 04          	mov    %edx,0x4(%esp)
  802267:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	89 c6                	mov    %eax,%esi
  802271:	d3 e3                	shl    %cl,%ebx
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 d0                	mov    %edx,%eax
  802277:	d3 e8                	shr    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	09 d8                	or     %ebx,%eax
  80227d:	89 d3                	mov    %edx,%ebx
  80227f:	89 f2                	mov    %esi,%edx
  802281:	f7 34 24             	divl   (%esp)
  802284:	89 d6                	mov    %edx,%esi
  802286:	d3 e3                	shl    %cl,%ebx
  802288:	f7 64 24 04          	mull   0x4(%esp)
  80228c:	39 d6                	cmp    %edx,%esi
  80228e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802292:	89 d1                	mov    %edx,%ecx
  802294:	89 c3                	mov    %eax,%ebx
  802296:	72 08                	jb     8022a0 <__umoddi3+0x110>
  802298:	75 11                	jne    8022ab <__umoddi3+0x11b>
  80229a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80229e:	73 0b                	jae    8022ab <__umoddi3+0x11b>
  8022a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022a4:	1b 14 24             	sbb    (%esp),%edx
  8022a7:	89 d1                	mov    %edx,%ecx
  8022a9:	89 c3                	mov    %eax,%ebx
  8022ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022af:	29 da                	sub    %ebx,%edx
  8022b1:	19 ce                	sbb    %ecx,%esi
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 f0                	mov    %esi,%eax
  8022b7:	d3 e0                	shl    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	d3 ea                	shr    %cl,%edx
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	d3 ee                	shr    %cl,%esi
  8022c1:	09 d0                	or     %edx,%eax
  8022c3:	89 f2                	mov    %esi,%edx
  8022c5:	83 c4 1c             	add    $0x1c,%esp
  8022c8:	5b                   	pop    %ebx
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    
  8022cd:	8d 76 00             	lea    0x0(%esi),%esi
  8022d0:	29 f9                	sub    %edi,%ecx
  8022d2:	19 d6                	sbb    %edx,%esi
  8022d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022dc:	e9 18 ff ff ff       	jmp    8021f9 <__umoddi3+0x69>
