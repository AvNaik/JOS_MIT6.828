
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 20 23 80 00       	push   $0x802320
  800043:	e8 ba 18 00 00       	call   801902 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 25 23 80 00       	push   $0x802325
  800057:	6a 0c                	push   $0xc
  800059:	68 33 23 80 00       	push   $0x802333
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 26 15 00 00       	call   801594 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 3e 14 00 00       	call   8014bf <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 48 23 80 00       	push   $0x802348
  800090:	6a 0f                	push   $0xf
  800092:	68 33 23 80 00       	push   $0x802333
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 b2 0e 00 00       	call   800f53 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 28 28 80 00       	push   $0x802828
  8000ad:	6a 12                	push   $0x12
  8000af:	68 33 23 80 00       	push   $0x802333
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 c8 14 00 00       	call   801594 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 88 23 80 00 	movl   $0x802388,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 d4 13 00 00       	call   8014bf <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 cc 23 80 00       	push   $0x8023cc
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 33 23 80 00       	push   $0x802333
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 68 09 00 00       	call   800a83 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 f8 23 80 00       	push   $0x8023f8
  80012a:	6a 19                	push   $0x19
  80012c:	68 33 23 80 00       	push   $0x802333
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 52 23 80 00       	push   $0x802352
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 46 14 00 00       	call   801594 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 9c 11 00 00       	call   8012f2 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 9b 1b 00 00       	call   801d02 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 45 13 00 00       	call   8014bf <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 30 24 80 00       	push   $0x802430
  80018b:	6a 21                	push   $0x21
  80018d:	68 33 23 80 00       	push   $0x802333
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 6b 23 80 00       	push   $0x80236b
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 46 11 00 00       	call   8012f2 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8001c3:	e8 73 0a 00 00       	call   800c3b <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 14 11 00 00       	call   80131d <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 e7 09 00 00       	call   800bfa <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 10 0a 00 00       	call   800c3b <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 60 24 80 00       	push   $0x802460
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 69 23 80 00 	movl   $0x802369,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 2f 09 00 00       	call   800bbd <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 54 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 d4 08 00 00       	call   800bbd <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 27 1d 00 00       	call   802080 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 14 1e 00 00       	call   8021b0 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b7:	83 fa 01             	cmp    $0x1,%edx
  8003ba:	7e 0e                	jle    8003ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	8b 52 04             	mov    0x4(%edx),%edx
  8003c8:	eb 22                	jmp    8003ec <getuint+0x38>
	else if (lflag)
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	74 10                	je     8003de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 0e                	jmp    8003ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
	va_end(ap);
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043a:	eb 12                	jmp    80044e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043c:	85 c0                	test   %eax,%eax
  80043e:	0f 84 89 03 00 00    	je     8007cd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	50                   	push   %eax
  800449:	ff d6                	call   *%esi
  80044b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044e:	83 c7 01             	add    $0x1,%edi
  800451:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e2                	jne    80043c <vprintfmt+0x14>
  80045a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80045e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800465:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
  800478:	eb 07                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8d 47 01             	lea    0x1(%edi),%eax
  800484:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800487:	0f b6 07             	movzbl (%edi),%eax
  80048a:	0f b6 c8             	movzbl %al,%ecx
  80048d:	83 e8 23             	sub    $0x23,%eax
  800490:	3c 55                	cmp    $0x55,%al
  800492:	0f 87 1a 03 00 00    	ja     8007b2 <vprintfmt+0x38a>
  800498:	0f b6 c0             	movzbl %al,%eax
  80049b:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a9:	eb d6                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004c3:	83 fa 09             	cmp    $0x9,%edx
  8004c6:	77 39                	ja     800501 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004cb:	eb e9                	jmp    8004b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8004d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d6:	8b 00                	mov    (%eax),%eax
  8004d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004de:	eb 27                	jmp    800507 <vprintfmt+0xdf>
  8004e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ea:	0f 49 c8             	cmovns %eax,%ecx
  8004ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f3:	eb 8c                	jmp    800481 <vprintfmt+0x59>
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ff:	eb 80                	jmp    800481 <vprintfmt+0x59>
  800501:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800507:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050b:	0f 89 70 ff ff ff    	jns    800481 <vprintfmt+0x59>
				width = precision, precision = -1;
  800511:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051e:	e9 5e ff ff ff       	jmp    800481 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800523:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800529:	e9 53 ff ff ff       	jmp    800481 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	ff 30                	pushl  (%eax)
  80053d:	ff d6                	call   *%esi
			break;
  80053f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800545:	e9 04 ff ff ff       	jmp    80044e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	99                   	cltd   
  800556:	31 d0                	xor    %edx,%eax
  800558:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 f8 0f             	cmp    $0xf,%eax
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x142>
  80055f:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 9b 24 80 00       	push   $0x80249b
  800570:	53                   	push   %ebx
  800571:	56                   	push   %esi
  800572:	e8 94 fe ff ff       	call   80040b <printfmt>
  800577:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80057d:	e9 cc fe ff ff       	jmp    80044e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800582:	52                   	push   %edx
  800583:	68 01 29 80 00       	push   $0x802901
  800588:	53                   	push   %ebx
  800589:	56                   	push   %esi
  80058a:	e8 7c fe ff ff       	call   80040b <printfmt>
  80058f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800595:	e9 b4 fe ff ff       	jmp    80044e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a5:	85 ff                	test   %edi,%edi
  8005a7:	b8 94 24 80 00       	mov    $0x802494,%eax
  8005ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b3:	0f 8e 94 00 00 00    	jle    80064d <vprintfmt+0x225>
  8005b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005bd:	0f 84 98 00 00 00    	je     80065b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c9:	57                   	push   %edi
  8005ca:	e8 86 02 00 00       	call   800855 <strnlen>
  8005cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d2:	29 c1                	sub    %eax,%ecx
  8005d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	eb 0f                	jmp    8005f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 ef 01             	sub    $0x1,%edi
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	7f ed                	jg     8005e8 <vprintfmt+0x1c0>
  8005fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800601:	85 c9                	test   %ecx,%ecx
  800603:	b8 00 00 00 00       	mov    $0x0,%eax
  800608:	0f 49 c1             	cmovns %ecx,%eax
  80060b:	29 c1                	sub    %eax,%ecx
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	89 cb                	mov    %ecx,%ebx
  800618:	eb 4d                	jmp    800667 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061e:	74 1b                	je     80063b <vprintfmt+0x213>
  800620:	0f be c0             	movsbl %al,%eax
  800623:	83 e8 20             	sub    $0x20,%eax
  800626:	83 f8 5e             	cmp    $0x5e,%eax
  800629:	76 10                	jbe    80063b <vprintfmt+0x213>
					putch('?', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	6a 3f                	push   $0x3f
  800633:	ff 55 08             	call   *0x8(%ebp)
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	ff 75 0c             	pushl  0xc(%ebp)
  800641:	52                   	push   %edx
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	83 eb 01             	sub    $0x1,%ebx
  80064b:	eb 1a                	jmp    800667 <vprintfmt+0x23f>
  80064d:	89 75 08             	mov    %esi,0x8(%ebp)
  800650:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800653:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800656:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800659:	eb 0c                	jmp    800667 <vprintfmt+0x23f>
  80065b:	89 75 08             	mov    %esi,0x8(%ebp)
  80065e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800661:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800664:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800667:	83 c7 01             	add    $0x1,%edi
  80066a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066e:	0f be d0             	movsbl %al,%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	74 23                	je     800698 <vprintfmt+0x270>
  800675:	85 f6                	test   %esi,%esi
  800677:	78 a1                	js     80061a <vprintfmt+0x1f2>
  800679:	83 ee 01             	sub    $0x1,%esi
  80067c:	79 9c                	jns    80061a <vprintfmt+0x1f2>
  80067e:	89 df                	mov    %ebx,%edi
  800680:	8b 75 08             	mov    0x8(%ebp),%esi
  800683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800686:	eb 18                	jmp    8006a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 20                	push   $0x20
  80068e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800690:	83 ef 01             	sub    $0x1,%edi
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	eb 08                	jmp    8006a0 <vprintfmt+0x278>
  800698:	89 df                	mov    %ebx,%edi
  80069a:	8b 75 08             	mov    0x8(%ebp),%esi
  80069d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a0:	85 ff                	test   %edi,%edi
  8006a2:	7f e4                	jg     800688 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a7:	e9 a2 fd ff ff       	jmp    80044e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ac:	83 fa 01             	cmp    $0x1,%edx
  8006af:	7e 16                	jle    8006c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 08             	lea    0x8(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ba:	8b 50 04             	mov    0x4(%eax),%edx
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c5:	eb 32                	jmp    8006f9 <vprintfmt+0x2d1>
	else if (lflag)
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	74 18                	je     8006e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d9:	89 c1                	mov    %eax,%ecx
  8006db:	c1 f9 1f             	sar    $0x1f,%ecx
  8006de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e1:	eb 16                	jmp    8006f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 50 04             	lea    0x4(%eax),%edx
  8006e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f1:	89 c1                	mov    %eax,%ecx
  8006f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800704:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800708:	79 74                	jns    80077e <vprintfmt+0x356>
				putch('-', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 2d                	push   $0x2d
  800710:	ff d6                	call   *%esi
				num = -(long long) num;
  800712:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800715:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800718:	f7 d8                	neg    %eax
  80071a:	83 d2 00             	adc    $0x0,%edx
  80071d:	f7 da                	neg    %edx
  80071f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800727:	eb 55                	jmp    80077e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
  80072c:	e8 83 fc ff ff       	call   8003b4 <getuint>
			base = 10;
  800731:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800736:	eb 46                	jmp    80077e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
  80073b:	e8 74 fc ff ff       	call   8003b4 <getuint>
			base = 8;
  800740:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800745:	eb 37                	jmp    80077e <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	6a 30                	push   $0x30
  80074d:	ff d6                	call   *%esi
			putch('x', putdat);
  80074f:	83 c4 08             	add    $0x8,%esp
  800752:	53                   	push   %ebx
  800753:	6a 78                	push   $0x78
  800755:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 50 04             	lea    0x4(%eax),%edx
  80075d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800760:	8b 00                	mov    (%eax),%eax
  800762:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800767:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80076a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80076f:	eb 0d                	jmp    80077e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
  800774:	e8 3b fc ff ff       	call   8003b4 <getuint>
			base = 16;
  800779:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077e:	83 ec 0c             	sub    $0xc,%esp
  800781:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800785:	57                   	push   %edi
  800786:	ff 75 e0             	pushl  -0x20(%ebp)
  800789:	51                   	push   %ecx
  80078a:	52                   	push   %edx
  80078b:	50                   	push   %eax
  80078c:	89 da                	mov    %ebx,%edx
  80078e:	89 f0                	mov    %esi,%eax
  800790:	e8 70 fb ff ff       	call   800305 <printnum>
			break;
  800795:	83 c4 20             	add    $0x20,%esp
  800798:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079b:	e9 ae fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	53                   	push   %ebx
  8007a4:	51                   	push   %ecx
  8007a5:	ff d6                	call   *%esi
			break;
  8007a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ad:	e9 9c fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	53                   	push   %ebx
  8007b6:	6a 25                	push   $0x25
  8007b8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb 03                	jmp    8007c2 <vprintfmt+0x39a>
  8007bf:	83 ef 01             	sub    $0x1,%edi
  8007c2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c6:	75 f7                	jne    8007bf <vprintfmt+0x397>
  8007c8:	e9 81 fc ff ff       	jmp    80044e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d0:	5b                   	pop    %ebx
  8007d1:	5e                   	pop    %esi
  8007d2:	5f                   	pop    %edi
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	83 ec 18             	sub    $0x18,%esp
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	74 26                	je     80081c <vsnprintf+0x47>
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	7e 22                	jle    80081c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fa:	ff 75 14             	pushl  0x14(%ebp)
  8007fd:	ff 75 10             	pushl  0x10(%ebp)
  800800:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800803:	50                   	push   %eax
  800804:	68 ee 03 80 00       	push   $0x8003ee
  800809:	e8 1a fc ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80080e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800811:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	eb 05                	jmp    800821 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800829:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082c:	50                   	push   %eax
  80082d:	ff 75 10             	pushl  0x10(%ebp)
  800830:	ff 75 0c             	pushl  0xc(%ebp)
  800833:	ff 75 08             	pushl  0x8(%ebp)
  800836:	e8 9a ff ff ff       	call   8007d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
  800848:	eb 03                	jmp    80084d <strlen+0x10>
		n++;
  80084a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800851:	75 f7                	jne    80084a <strlen+0xd>
		n++;
	return n;
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085e:	ba 00 00 00 00       	mov    $0x0,%edx
  800863:	eb 03                	jmp    800868 <strnlen+0x13>
		n++;
  800865:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800868:	39 c2                	cmp    %eax,%edx
  80086a:	74 08                	je     800874 <strnlen+0x1f>
  80086c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800870:	75 f3                	jne    800865 <strnlen+0x10>
  800872:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800880:	89 c2                	mov    %eax,%edx
  800882:	83 c2 01             	add    $0x1,%edx
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ef                	jne    800882 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089d:	53                   	push   %ebx
  80089e:	e8 9a ff ff ff       	call   80083d <strlen>
  8008a3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a6:	ff 75 0c             	pushl  0xc(%ebp)
  8008a9:	01 d8                	add    %ebx,%eax
  8008ab:	50                   	push   %eax
  8008ac:	e8 c5 ff ff ff       	call   800876 <strcpy>
	return dst;
}
  8008b1:	89 d8                	mov    %ebx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c3:	89 f3                	mov    %esi,%ebx
  8008c5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c8:	89 f2                	mov    %esi,%edx
  8008ca:	eb 0f                	jmp    8008db <strncpy+0x23>
		*dst++ = *src;
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	0f b6 01             	movzbl (%ecx),%eax
  8008d2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d5:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008db:	39 da                	cmp    %ebx,%edx
  8008dd:	75 ed                	jne    8008cc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008df:	89 f0                	mov    %esi,%eax
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	74 21                	je     80091a <strlcpy+0x35>
  8008f9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008fd:	89 f2                	mov    %esi,%edx
  8008ff:	eb 09                	jmp    80090a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	83 c1 01             	add    $0x1,%ecx
  800907:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090a:	39 c2                	cmp    %eax,%edx
  80090c:	74 09                	je     800917 <strlcpy+0x32>
  80090e:	0f b6 19             	movzbl (%ecx),%ebx
  800911:	84 db                	test   %bl,%bl
  800913:	75 ec                	jne    800901 <strlcpy+0x1c>
  800915:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800917:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091a:	29 f0                	sub    %esi,%eax
}
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800929:	eb 06                	jmp    800931 <strcmp+0x11>
		p++, q++;
  80092b:	83 c1 01             	add    $0x1,%ecx
  80092e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800931:	0f b6 01             	movzbl (%ecx),%eax
  800934:	84 c0                	test   %al,%al
  800936:	74 04                	je     80093c <strcmp+0x1c>
  800938:	3a 02                	cmp    (%edx),%al
  80093a:	74 ef                	je     80092b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093c:	0f b6 c0             	movzbl %al,%eax
  80093f:	0f b6 12             	movzbl (%edx),%edx
  800942:	29 d0                	sub    %edx,%eax
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 c3                	mov    %eax,%ebx
  800952:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800955:	eb 06                	jmp    80095d <strncmp+0x17>
		n--, p++, q++;
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095d:	39 d8                	cmp    %ebx,%eax
  80095f:	74 15                	je     800976 <strncmp+0x30>
  800961:	0f b6 08             	movzbl (%eax),%ecx
  800964:	84 c9                	test   %cl,%cl
  800966:	74 04                	je     80096c <strncmp+0x26>
  800968:	3a 0a                	cmp    (%edx),%cl
  80096a:	74 eb                	je     800957 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096c:	0f b6 00             	movzbl (%eax),%eax
  80096f:	0f b6 12             	movzbl (%edx),%edx
  800972:	29 d0                	sub    %edx,%eax
  800974:	eb 05                	jmp    80097b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097b:	5b                   	pop    %ebx
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800988:	eb 07                	jmp    800991 <strchr+0x13>
		if (*s == c)
  80098a:	38 ca                	cmp    %cl,%dl
  80098c:	74 0f                	je     80099d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	0f b6 10             	movzbl (%eax),%edx
  800994:	84 d2                	test   %dl,%dl
  800996:	75 f2                	jne    80098a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a9:	eb 03                	jmp    8009ae <strfind+0xf>
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b1:	38 ca                	cmp    %cl,%dl
  8009b3:	74 04                	je     8009b9 <strfind+0x1a>
  8009b5:	84 d2                	test   %dl,%dl
  8009b7:	75 f2                	jne    8009ab <strfind+0xc>
			break;
	return (char *) s;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	57                   	push   %edi
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c7:	85 c9                	test   %ecx,%ecx
  8009c9:	74 36                	je     800a01 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d1:	75 28                	jne    8009fb <memset+0x40>
  8009d3:	f6 c1 03             	test   $0x3,%cl
  8009d6:	75 23                	jne    8009fb <memset+0x40>
		c &= 0xFF;
  8009d8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009dc:	89 d3                	mov    %edx,%ebx
  8009de:	c1 e3 08             	shl    $0x8,%ebx
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	c1 e6 18             	shl    $0x18,%esi
  8009e6:	89 d0                	mov    %edx,%eax
  8009e8:	c1 e0 10             	shl    $0x10,%eax
  8009eb:	09 f0                	or     %esi,%eax
  8009ed:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ef:	89 d8                	mov    %ebx,%eax
  8009f1:	09 d0                	or     %edx,%eax
  8009f3:	c1 e9 02             	shr    $0x2,%ecx
  8009f6:	fc                   	cld    
  8009f7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f9:	eb 06                	jmp    800a01 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	fc                   	cld    
  8009ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a01:	89 f8                	mov    %edi,%eax
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5f                   	pop    %edi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a16:	39 c6                	cmp    %eax,%esi
  800a18:	73 35                	jae    800a4f <memmove+0x47>
  800a1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1d:	39 d0                	cmp    %edx,%eax
  800a1f:	73 2e                	jae    800a4f <memmove+0x47>
		s += n;
		d += n;
  800a21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	89 d6                	mov    %edx,%esi
  800a26:	09 fe                	or     %edi,%esi
  800a28:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2e:	75 13                	jne    800a43 <memmove+0x3b>
  800a30:	f6 c1 03             	test   $0x3,%cl
  800a33:	75 0e                	jne    800a43 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a35:	83 ef 04             	sub    $0x4,%edi
  800a38:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
  800a3e:	fd                   	std    
  800a3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a41:	eb 09                	jmp    800a4c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a43:	83 ef 01             	sub    $0x1,%edi
  800a46:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a49:	fd                   	std    
  800a4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4c:	fc                   	cld    
  800a4d:	eb 1d                	jmp    800a6c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	89 f2                	mov    %esi,%edx
  800a51:	09 c2                	or     %eax,%edx
  800a53:	f6 c2 03             	test   $0x3,%dl
  800a56:	75 0f                	jne    800a67 <memmove+0x5f>
  800a58:	f6 c1 03             	test   $0x3,%cl
  800a5b:	75 0a                	jne    800a67 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a5d:	c1 e9 02             	shr    $0x2,%ecx
  800a60:	89 c7                	mov    %eax,%edi
  800a62:	fc                   	cld    
  800a63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a65:	eb 05                	jmp    800a6c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a67:	89 c7                	mov    %eax,%edi
  800a69:	fc                   	cld    
  800a6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a73:	ff 75 10             	pushl  0x10(%ebp)
  800a76:	ff 75 0c             	pushl  0xc(%ebp)
  800a79:	ff 75 08             	pushl  0x8(%ebp)
  800a7c:	e8 87 ff ff ff       	call   800a08 <memmove>
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	89 c6                	mov    %eax,%esi
  800a90:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	eb 1a                	jmp    800aaf <memcmp+0x2c>
		if (*s1 != *s2)
  800a95:	0f b6 08             	movzbl (%eax),%ecx
  800a98:	0f b6 1a             	movzbl (%edx),%ebx
  800a9b:	38 d9                	cmp    %bl,%cl
  800a9d:	74 0a                	je     800aa9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a9f:	0f b6 c1             	movzbl %cl,%eax
  800aa2:	0f b6 db             	movzbl %bl,%ebx
  800aa5:	29 d8                	sub    %ebx,%eax
  800aa7:	eb 0f                	jmp    800ab8 <memcmp+0x35>
		s1++, s2++;
  800aa9:	83 c0 01             	add    $0x1,%eax
  800aac:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaf:	39 f0                	cmp    %esi,%eax
  800ab1:	75 e2                	jne    800a95 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	53                   	push   %ebx
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac3:	89 c1                	mov    %eax,%ecx
  800ac5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acc:	eb 0a                	jmp    800ad8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ace:	0f b6 10             	movzbl (%eax),%edx
  800ad1:	39 da                	cmp    %ebx,%edx
  800ad3:	74 07                	je     800adc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	39 c8                	cmp    %ecx,%eax
  800ada:	72 f2                	jb     800ace <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aeb:	eb 03                	jmp    800af0 <strtol+0x11>
		s++;
  800aed:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af0:	0f b6 01             	movzbl (%ecx),%eax
  800af3:	3c 20                	cmp    $0x20,%al
  800af5:	74 f6                	je     800aed <strtol+0xe>
  800af7:	3c 09                	cmp    $0x9,%al
  800af9:	74 f2                	je     800aed <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800afb:	3c 2b                	cmp    $0x2b,%al
  800afd:	75 0a                	jne    800b09 <strtol+0x2a>
		s++;
  800aff:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b02:	bf 00 00 00 00       	mov    $0x0,%edi
  800b07:	eb 11                	jmp    800b1a <strtol+0x3b>
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0e:	3c 2d                	cmp    $0x2d,%al
  800b10:	75 08                	jne    800b1a <strtol+0x3b>
		s++, neg = 1;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b20:	75 15                	jne    800b37 <strtol+0x58>
  800b22:	80 39 30             	cmpb   $0x30,(%ecx)
  800b25:	75 10                	jne    800b37 <strtol+0x58>
  800b27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2b:	75 7c                	jne    800ba9 <strtol+0xca>
		s += 2, base = 16;
  800b2d:	83 c1 02             	add    $0x2,%ecx
  800b30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b35:	eb 16                	jmp    800b4d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b37:	85 db                	test   %ebx,%ebx
  800b39:	75 12                	jne    800b4d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 08                	jne    800b4d <strtol+0x6e>
		s++, base = 8;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b52:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b55:	0f b6 11             	movzbl (%ecx),%edx
  800b58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b5b:	89 f3                	mov    %esi,%ebx
  800b5d:	80 fb 09             	cmp    $0x9,%bl
  800b60:	77 08                	ja     800b6a <strtol+0x8b>
			dig = *s - '0';
  800b62:	0f be d2             	movsbl %dl,%edx
  800b65:	83 ea 30             	sub    $0x30,%edx
  800b68:	eb 22                	jmp    800b8c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6d:	89 f3                	mov    %esi,%ebx
  800b6f:	80 fb 19             	cmp    $0x19,%bl
  800b72:	77 08                	ja     800b7c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b74:	0f be d2             	movsbl %dl,%edx
  800b77:	83 ea 57             	sub    $0x57,%edx
  800b7a:	eb 10                	jmp    800b8c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7f:	89 f3                	mov    %esi,%ebx
  800b81:	80 fb 19             	cmp    $0x19,%bl
  800b84:	77 16                	ja     800b9c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b86:	0f be d2             	movsbl %dl,%edx
  800b89:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b8c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b8f:	7d 0b                	jge    800b9c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b98:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b9a:	eb b9                	jmp    800b55 <strtol+0x76>

	if (endptr)
  800b9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba0:	74 0d                	je     800baf <strtol+0xd0>
		*endptr = (char *) s;
  800ba2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba5:	89 0e                	mov    %ecx,(%esi)
  800ba7:	eb 06                	jmp    800baf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba9:	85 db                	test   %ebx,%ebx
  800bab:	74 98                	je     800b45 <strtol+0x66>
  800bad:	eb 9e                	jmp    800b4d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800baf:	89 c2                	mov    %eax,%edx
  800bb1:	f7 da                	neg    %edx
  800bb3:	85 ff                	test   %edi,%edi
  800bb5:	0f 45 c2             	cmovne %edx,%eax
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 c3                	mov    %eax,%ebx
  800bd0:	89 c7                	mov    %eax,%edi
  800bd2:	89 c6                	mov    %eax,%esi
  800bd4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cgetc>:

int
sys_cgetc(void)
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
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	b8 01 00 00 00       	mov    $0x1,%eax
  800beb:	89 d1                	mov    %edx,%ecx
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	89 d7                	mov    %edx,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c08:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 cb                	mov    %ecx,%ebx
  800c12:	89 cf                	mov    %ecx,%edi
  800c14:	89 ce                	mov    %ecx,%esi
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 03                	push   $0x3
  800c22:	68 7f 27 80 00       	push   $0x80277f
  800c27:	6a 23                	push   $0x23
  800c29:	68 9c 27 80 00       	push   $0x80279c
  800c2e:	e8 e5 f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4b:	89 d1                	mov    %edx,%ecx
  800c4d:	89 d3                	mov    %edx,%ebx
  800c4f:	89 d7                	mov    %edx,%edi
  800c51:	89 d6                	mov    %edx,%esi
  800c53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_yield>:

void
sys_yield(void)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	89 d3                	mov    %edx,%ebx
  800c6e:	89 d7                	mov    %edx,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	be 00 00 00 00       	mov    $0x0,%esi
  800c87:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c95:	89 f7                	mov    %esi,%edi
  800c97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 04                	push   $0x4
  800ca3:	68 7f 27 80 00       	push   $0x80277f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 9c 27 80 00       	push   $0x80279c
  800caf:	e8 64 f5 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd6:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 05                	push   $0x5
  800ce5:	68 7f 27 80 00       	push   $0x80277f
  800cea:	6a 23                	push   $0x23
  800cec:	68 9c 27 80 00       	push   $0x80279c
  800cf1:	e8 22 f5 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 df                	mov    %ebx,%edi
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 06                	push   $0x6
  800d27:	68 7f 27 80 00       	push   $0x80277f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 9c 27 80 00       	push   $0x80279c
  800d33:	e8 e0 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 08                	push   $0x8
  800d69:	68 7f 27 80 00       	push   $0x80277f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 9c 27 80 00       	push   $0x80279c
  800d75:	e8 9e f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d90:	b8 09 00 00 00       	mov    $0x9,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	89 df                	mov    %ebx,%edi
  800d9d:	89 de                	mov    %ebx,%esi
  800d9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7e 17                	jle    800dbc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 09                	push   $0x9
  800dab:	68 7f 27 80 00       	push   $0x80277f
  800db0:	6a 23                	push   $0x23
  800db2:	68 9c 27 80 00       	push   $0x80279c
  800db7:	e8 5c f4 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	89 df                	mov    %ebx,%edi
  800ddf:	89 de                	mov    %ebx,%esi
  800de1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 17                	jle    800dfe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	50                   	push   %eax
  800deb:	6a 0a                	push   $0xa
  800ded:	68 7f 27 80 00       	push   $0x80277f
  800df2:	6a 23                	push   $0x23
  800df4:	68 9c 27 80 00       	push   $0x80279c
  800df9:	e8 1a f4 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	be 00 00 00 00       	mov    $0x0,%esi
  800e11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e37:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	89 cb                	mov    %ecx,%ebx
  800e41:	89 cf                	mov    %ecx,%edi
  800e43:	89 ce                	mov    %ecx,%esi
  800e45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7e 17                	jle    800e62 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	50                   	push   %eax
  800e4f:	6a 0d                	push   $0xd
  800e51:	68 7f 27 80 00       	push   $0x80277f
  800e56:	6a 23                	push   $0x23
  800e58:	68 9c 27 80 00       	push   $0x80279c
  800e5d:	e8 b6 f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 04             	sub    $0x4,%esp
  800e71:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  800e74:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  800e76:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  800e79:	89 da                	mov    %ebx,%edx
  800e7b:	c1 ea 0c             	shr    $0xc,%edx
  800e7e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  800e85:	a8 02                	test   $0x2,%al
  800e87:	75 12                	jne    800e9b <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  800e89:	50                   	push   %eax
  800e8a:	68 ac 27 80 00       	push   $0x8027ac
  800e8f:	6a 21                	push   $0x21
  800e91:	68 cd 27 80 00       	push   $0x8027cd
  800e96:	e8 7d f3 ff ff       	call   800218 <_panic>
	   } else if (!(pte & PTE_COW)) {
  800e9b:	f6 c6 08             	test   $0x8,%dh
  800e9e:	75 14                	jne    800eb4 <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  800ea0:	83 ec 04             	sub    $0x4,%esp
  800ea3:	68 d8 27 80 00       	push   $0x8027d8
  800ea8:	6a 23                	push   $0x23
  800eaa:	68 cd 27 80 00       	push   $0x8027cd
  800eaf:	e8 64 f3 ff ff       	call   800218 <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  800eb4:	83 ec 04             	sub    $0x4,%esp
  800eb7:	6a 07                	push   $0x7
  800eb9:	68 00 00 40 00       	push   $0x400000
  800ebe:	6a 00                	push   $0x0
  800ec0:	e8 b4 fd ff ff       	call   800c79 <sys_page_alloc>
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	79 12                	jns    800ede <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  800ecc:	50                   	push   %eax
  800ecd:	68 f5 27 80 00       	push   $0x8027f5
  800ed2:	6a 2e                	push   $0x2e
  800ed4:	68 cd 27 80 00       	push   $0x8027cd
  800ed9:	e8 3a f3 ff ff       	call   800218 <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800ede:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800ee4:	83 ec 04             	sub    $0x4,%esp
  800ee7:	68 00 10 00 00       	push   $0x1000
  800eec:	53                   	push   %ebx
  800eed:	68 00 00 40 00       	push   $0x400000
  800ef2:	e8 11 fb ff ff       	call   800a08 <memmove>
	   if ((r = sys_page_map(0,
  800ef7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800efe:	53                   	push   %ebx
  800eff:	6a 00                	push   $0x0
  800f01:	68 00 00 40 00       	push   $0x400000
  800f06:	6a 00                	push   $0x0
  800f08:	e8 af fd ff ff       	call   800cbc <sys_page_map>
  800f0d:	83 c4 20             	add    $0x20,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	79 12                	jns    800f26 <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  800f14:	50                   	push   %eax
  800f15:	68 08 28 80 00       	push   $0x802808
  800f1a:	6a 36                	push   $0x36
  800f1c:	68 cd 27 80 00       	push   $0x8027cd
  800f21:	e8 f2 f2 ff ff       	call   800218 <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  800f26:	83 ec 08             	sub    $0x8,%esp
  800f29:	68 00 00 40 00       	push   $0x400000
  800f2e:	6a 00                	push   $0x0
  800f30:	e8 c9 fd ff ff       	call   800cfe <sys_page_unmap>
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	79 12                	jns    800f4e <pgfault+0xe4>
			 panic("unmap %e", r);
  800f3c:	50                   	push   %eax
  800f3d:	68 18 28 80 00       	push   $0x802818
  800f42:	6a 39                	push   $0x39
  800f44:	68 cd 27 80 00       	push   $0x8027cd
  800f49:	e8 ca f2 ff ff       	call   800218 <_panic>
	   }
}
  800f4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	57                   	push   %edi
  800f57:	56                   	push   %esi
  800f58:	53                   	push   %ebx
  800f59:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  800f5c:	68 6a 0e 80 00       	push   $0x800e6a
  800f61:	e8 6e 0f 00 00       	call   801ed4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f66:	b8 07 00 00 00       	mov    $0x7,%eax
  800f6b:	cd 30                	int    $0x30
  800f6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f70:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  800f73:	83 c4 10             	add    $0x10,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	79 15                	jns    800f8f <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  800f7a:	50                   	push   %eax
  800f7b:	68 21 28 80 00       	push   $0x802821
  800f80:	68 81 00 00 00       	push   $0x81
  800f85:	68 cd 27 80 00       	push   $0x8027cd
  800f8a:	e8 89 f2 ff ff       	call   800218 <_panic>
  800f8f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800f96:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  800f9a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800f9e:	75 1c                	jne    800fbc <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  800fa0:	e8 96 fc ff ff       	call   800c3b <sys_getenvid>
  800fa5:	25 ff 03 00 00       	and    $0x3ff,%eax
  800faa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fb2:	a3 20 44 80 00       	mov    %eax,0x804420
			 return envid;
  800fb7:	e9 71 01 00 00       	jmp    80112d <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  800fbc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800fbf:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800fc6:	a8 01                	test   $0x1,%al
  800fc8:	0f 84 18 01 00 00    	je     8010e6 <fork+0x193>
  800fce:	89 fb                	mov    %edi,%ebx
  800fd0:	c1 e3 0a             	shl    $0xa,%ebx
  800fd3:	c1 e7 16             	shl    $0x16,%edi
  800fd6:	be 00 00 00 00       	mov    $0x0,%esi
  800fdb:	e9 f4 00 00 00       	jmp    8010d4 <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  800fe0:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800fe6:	0f 84 dc 00 00 00    	je     8010c8 <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  800fec:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800ff2:	0f 87 cc 00 00 00    	ja     8010c4 <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  800ff8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fff:	a8 01                	test   $0x1,%al
  801001:	0f 84 c1 00 00 00    	je     8010c8 <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  801007:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  80100e:	a9 02 08 00 00       	test   $0x802,%eax
  801013:	74 05                	je     80101a <fork+0xc7>
  801015:	f6 c4 04             	test   $0x4,%ah
  801018:	74 3a                	je     801054 <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  80101a:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801020:	8b 52 48             	mov    0x48(%edx),%edx
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	25 07 0e 00 00       	and    $0xe07,%eax
  80102b:	50                   	push   %eax
  80102c:	57                   	push   %edi
  80102d:	ff 75 dc             	pushl  -0x24(%ebp)
  801030:	57                   	push   %edi
  801031:	52                   	push   %edx
  801032:	e8 85 fc ff ff       	call   800cbc <sys_page_map>
  801037:	83 c4 20             	add    $0x20,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	0f 89 86 00 00 00    	jns    8010c8 <fork+0x175>
				    panic("sys_page_map: %e", r);
  801042:	50                   	push   %eax
  801043:	68 31 28 80 00       	push   $0x802831
  801048:	6a 52                	push   $0x52
  80104a:	68 cd 27 80 00       	push   $0x8027cd
  80104f:	e8 c4 f1 ff ff       	call   800218 <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  801054:	25 05 06 00 00       	and    $0x605,%eax
  801059:	80 cc 08             	or     $0x8,%ah
  80105c:	89 c1                	mov    %eax,%ecx
  80105e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801061:	a1 20 44 80 00       	mov    0x804420,%eax
  801066:	8b 40 48             	mov    0x48(%eax),%eax
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	51                   	push   %ecx
  80106d:	57                   	push   %edi
  80106e:	ff 75 dc             	pushl  -0x24(%ebp)
  801071:	57                   	push   %edi
  801072:	50                   	push   %eax
  801073:	e8 44 fc ff ff       	call   800cbc <sys_page_map>
  801078:	83 c4 20             	add    $0x20,%esp
  80107b:	85 c0                	test   %eax,%eax
  80107d:	79 12                	jns    801091 <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  80107f:	50                   	push   %eax
  801080:	68 31 28 80 00       	push   $0x802831
  801085:	6a 5d                	push   $0x5d
  801087:	68 cd 27 80 00       	push   $0x8027cd
  80108c:	e8 87 f1 ff ff       	call   800218 <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  801091:	a1 20 44 80 00       	mov    0x804420,%eax
  801096:	8b 50 48             	mov    0x48(%eax),%edx
  801099:	8b 40 48             	mov    0x48(%eax),%eax
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a2:	57                   	push   %edi
  8010a3:	52                   	push   %edx
  8010a4:	57                   	push   %edi
  8010a5:	50                   	push   %eax
  8010a6:	e8 11 fc ff ff       	call   800cbc <sys_page_map>
  8010ab:	83 c4 20             	add    $0x20,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	79 16                	jns    8010c8 <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  8010b2:	50                   	push   %eax
  8010b3:	68 31 28 80 00       	push   $0x802831
  8010b8:	6a 63                	push   $0x63
  8010ba:	68 cd 27 80 00       	push   $0x8027cd
  8010bf:	e8 54 f1 ff ff       	call   800218 <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  8010c4:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  8010c8:	83 c6 01             	add    $0x1,%esi
  8010cb:	83 c3 01             	add    $0x1,%ebx
  8010ce:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8010d4:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  8010da:	7f 0a                	jg     8010e6 <fork+0x193>
  8010dc:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8010e0:	0f 85 fa fe ff ff    	jne    800fe0 <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  8010e6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  8010ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010ed:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8010f2:	7f 0a                	jg     8010fe <fork+0x1ab>
  8010f4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8010f8:	0f 85 be fe ff ff    	jne    800fbc <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010fe:	83 ec 08             	sub    $0x8,%esp
  801101:	68 2d 1f 80 00       	push   $0x801f2d
  801106:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801109:	56                   	push   %esi
  80110a:	e8 b5 fc ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  80110f:	83 c4 0c             	add    $0xc,%esp
  801112:	6a 06                	push   $0x6
  801114:	68 00 f0 bf ee       	push   $0xeebff000
  801119:	56                   	push   %esi
  80111a:	e8 5a fb ff ff       	call   800c79 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  80111f:	83 c4 08             	add    $0x8,%esp
  801122:	6a 02                	push   $0x2
  801124:	56                   	push   %esi
  801125:	e8 16 fc ff ff       	call   800d40 <sys_env_set_status>

	   return envid;
  80112a:	83 c4 10             	add    $0x10,%esp
}
  80112d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    

00801138 <sfork>:
// Challenge!
	   int
sfork(void)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  80113e:	68 42 28 80 00       	push   $0x802842
  801143:	68 a7 00 00 00       	push   $0xa7
  801148:	68 cd 27 80 00       	push   $0x8027cd
  80114d:	e8 c6 f0 ff ff       	call   800218 <_panic>

00801152 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801155:	8b 45 08             	mov    0x8(%ebp),%eax
  801158:	05 00 00 00 30       	add    $0x30000000,%eax
  80115d:	c1 e8 0c             	shr    $0xc,%eax
}
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801165:	8b 45 08             	mov    0x8(%ebp),%eax
  801168:	05 00 00 00 30       	add    $0x30000000,%eax
  80116d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801172:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801177:	5d                   	pop    %ebp
  801178:	c3                   	ret    

00801179 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801184:	89 c2                	mov    %eax,%edx
  801186:	c1 ea 16             	shr    $0x16,%edx
  801189:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801190:	f6 c2 01             	test   $0x1,%dl
  801193:	74 11                	je     8011a6 <fd_alloc+0x2d>
  801195:	89 c2                	mov    %eax,%edx
  801197:	c1 ea 0c             	shr    $0xc,%edx
  80119a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a1:	f6 c2 01             	test   $0x1,%dl
  8011a4:	75 09                	jne    8011af <fd_alloc+0x36>
			*fd_store = fd;
  8011a6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ad:	eb 17                	jmp    8011c6 <fd_alloc+0x4d>
  8011af:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011b4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b9:	75 c9                	jne    801184 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011bb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011c1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011ce:	83 f8 1f             	cmp    $0x1f,%eax
  8011d1:	77 36                	ja     801209 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d3:	c1 e0 0c             	shl    $0xc,%eax
  8011d6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	c1 ea 16             	shr    $0x16,%edx
  8011e0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e7:	f6 c2 01             	test   $0x1,%dl
  8011ea:	74 24                	je     801210 <fd_lookup+0x48>
  8011ec:	89 c2                	mov    %eax,%edx
  8011ee:	c1 ea 0c             	shr    $0xc,%edx
  8011f1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f8:	f6 c2 01             	test   $0x1,%dl
  8011fb:	74 1a                	je     801217 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801200:	89 02                	mov    %eax,(%edx)
	return 0;
  801202:	b8 00 00 00 00       	mov    $0x0,%eax
  801207:	eb 13                	jmp    80121c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801209:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120e:	eb 0c                	jmp    80121c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801210:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801215:	eb 05                	jmp    80121c <fd_lookup+0x54>
  801217:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	83 ec 08             	sub    $0x8,%esp
  801224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801227:	ba d8 28 80 00       	mov    $0x8028d8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80122c:	eb 13                	jmp    801241 <dev_lookup+0x23>
  80122e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801231:	39 08                	cmp    %ecx,(%eax)
  801233:	75 0c                	jne    801241 <dev_lookup+0x23>
			*dev = devtab[i];
  801235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801238:	89 01                	mov    %eax,(%ecx)
			return 0;
  80123a:	b8 00 00 00 00       	mov    $0x0,%eax
  80123f:	eb 2e                	jmp    80126f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801241:	8b 02                	mov    (%edx),%eax
  801243:	85 c0                	test   %eax,%eax
  801245:	75 e7                	jne    80122e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801247:	a1 20 44 80 00       	mov    0x804420,%eax
  80124c:	8b 40 48             	mov    0x48(%eax),%eax
  80124f:	83 ec 04             	sub    $0x4,%esp
  801252:	51                   	push   %ecx
  801253:	50                   	push   %eax
  801254:	68 58 28 80 00       	push   $0x802858
  801259:	e8 93 f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  80125e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801261:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80126f:	c9                   	leave  
  801270:	c3                   	ret    

00801271 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	56                   	push   %esi
  801275:	53                   	push   %ebx
  801276:	83 ec 10             	sub    $0x10,%esp
  801279:	8b 75 08             	mov    0x8(%ebp),%esi
  80127c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80127f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801289:	c1 e8 0c             	shr    $0xc,%eax
  80128c:	50                   	push   %eax
  80128d:	e8 36 ff ff ff       	call   8011c8 <fd_lookup>
  801292:	83 c4 08             	add    $0x8,%esp
  801295:	85 c0                	test   %eax,%eax
  801297:	78 05                	js     80129e <fd_close+0x2d>
	    || fd != fd2)
  801299:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80129c:	74 0c                	je     8012aa <fd_close+0x39>
		return (must_exist ? r : 0);
  80129e:	84 db                	test   %bl,%bl
  8012a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a5:	0f 44 c2             	cmove  %edx,%eax
  8012a8:	eb 41                	jmp    8012eb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	ff 36                	pushl  (%esi)
  8012b3:	e8 66 ff ff ff       	call   80121e <dev_lookup>
  8012b8:	89 c3                	mov    %eax,%ebx
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	78 1a                	js     8012db <fd_close+0x6a>
		if (dev->dev_close)
  8012c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012c7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	74 0b                	je     8012db <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012d0:	83 ec 0c             	sub    $0xc,%esp
  8012d3:	56                   	push   %esi
  8012d4:	ff d0                	call   *%eax
  8012d6:	89 c3                	mov    %eax,%ebx
  8012d8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	56                   	push   %esi
  8012df:	6a 00                	push   $0x0
  8012e1:	e8 18 fa ff ff       	call   800cfe <sys_page_unmap>
	return r;
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	89 d8                	mov    %ebx,%eax
}
  8012eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ee:	5b                   	pop    %ebx
  8012ef:	5e                   	pop    %esi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fb:	50                   	push   %eax
  8012fc:	ff 75 08             	pushl  0x8(%ebp)
  8012ff:	e8 c4 fe ff ff       	call   8011c8 <fd_lookup>
  801304:	83 c4 08             	add    $0x8,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	78 10                	js     80131b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	6a 01                	push   $0x1
  801310:	ff 75 f4             	pushl  -0xc(%ebp)
  801313:	e8 59 ff ff ff       	call   801271 <fd_close>
  801318:	83 c4 10             	add    $0x10,%esp
}
  80131b:	c9                   	leave  
  80131c:	c3                   	ret    

0080131d <close_all>:

void
close_all(void)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	53                   	push   %ebx
  801321:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801324:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801329:	83 ec 0c             	sub    $0xc,%esp
  80132c:	53                   	push   %ebx
  80132d:	e8 c0 ff ff ff       	call   8012f2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801332:	83 c3 01             	add    $0x1,%ebx
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	83 fb 20             	cmp    $0x20,%ebx
  80133b:	75 ec                	jne    801329 <close_all+0xc>
		close(i);
}
  80133d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	57                   	push   %edi
  801346:	56                   	push   %esi
  801347:	53                   	push   %ebx
  801348:	83 ec 2c             	sub    $0x2c,%esp
  80134b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80134e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801351:	50                   	push   %eax
  801352:	ff 75 08             	pushl  0x8(%ebp)
  801355:	e8 6e fe ff ff       	call   8011c8 <fd_lookup>
  80135a:	83 c4 08             	add    $0x8,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	0f 88 c1 00 00 00    	js     801426 <dup+0xe4>
		return r;
	close(newfdnum);
  801365:	83 ec 0c             	sub    $0xc,%esp
  801368:	56                   	push   %esi
  801369:	e8 84 ff ff ff       	call   8012f2 <close>

	newfd = INDEX2FD(newfdnum);
  80136e:	89 f3                	mov    %esi,%ebx
  801370:	c1 e3 0c             	shl    $0xc,%ebx
  801373:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801379:	83 c4 04             	add    $0x4,%esp
  80137c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80137f:	e8 de fd ff ff       	call   801162 <fd2data>
  801384:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801386:	89 1c 24             	mov    %ebx,(%esp)
  801389:	e8 d4 fd ff ff       	call   801162 <fd2data>
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801394:	89 f8                	mov    %edi,%eax
  801396:	c1 e8 16             	shr    $0x16,%eax
  801399:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013a0:	a8 01                	test   $0x1,%al
  8013a2:	74 37                	je     8013db <dup+0x99>
  8013a4:	89 f8                	mov    %edi,%eax
  8013a6:	c1 e8 0c             	shr    $0xc,%eax
  8013a9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b0:	f6 c2 01             	test   $0x1,%dl
  8013b3:	74 26                	je     8013db <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013bc:	83 ec 0c             	sub    $0xc,%esp
  8013bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c4:	50                   	push   %eax
  8013c5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c8:	6a 00                	push   $0x0
  8013ca:	57                   	push   %edi
  8013cb:	6a 00                	push   $0x0
  8013cd:	e8 ea f8 ff ff       	call   800cbc <sys_page_map>
  8013d2:	89 c7                	mov    %eax,%edi
  8013d4:	83 c4 20             	add    $0x20,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 2e                	js     801409 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013de:	89 d0                	mov    %edx,%eax
  8013e0:	c1 e8 0c             	shr    $0xc,%eax
  8013e3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ea:	83 ec 0c             	sub    $0xc,%esp
  8013ed:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f2:	50                   	push   %eax
  8013f3:	53                   	push   %ebx
  8013f4:	6a 00                	push   $0x0
  8013f6:	52                   	push   %edx
  8013f7:	6a 00                	push   $0x0
  8013f9:	e8 be f8 ff ff       	call   800cbc <sys_page_map>
  8013fe:	89 c7                	mov    %eax,%edi
  801400:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801403:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801405:	85 ff                	test   %edi,%edi
  801407:	79 1d                	jns    801426 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801409:	83 ec 08             	sub    $0x8,%esp
  80140c:	53                   	push   %ebx
  80140d:	6a 00                	push   $0x0
  80140f:	e8 ea f8 ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801414:	83 c4 08             	add    $0x8,%esp
  801417:	ff 75 d4             	pushl  -0x2c(%ebp)
  80141a:	6a 00                	push   $0x0
  80141c:	e8 dd f8 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	89 f8                	mov    %edi,%eax
}
  801426:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801429:	5b                   	pop    %ebx
  80142a:	5e                   	pop    %esi
  80142b:	5f                   	pop    %edi
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	53                   	push   %ebx
  801432:	83 ec 14             	sub    $0x14,%esp
  801435:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801438:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143b:	50                   	push   %eax
  80143c:	53                   	push   %ebx
  80143d:	e8 86 fd ff ff       	call   8011c8 <fd_lookup>
  801442:	83 c4 08             	add    $0x8,%esp
  801445:	89 c2                	mov    %eax,%edx
  801447:	85 c0                	test   %eax,%eax
  801449:	78 6d                	js     8014b8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801455:	ff 30                	pushl  (%eax)
  801457:	e8 c2 fd ff ff       	call   80121e <dev_lookup>
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 4c                	js     8014af <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801463:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801466:	8b 42 08             	mov    0x8(%edx),%eax
  801469:	83 e0 03             	and    $0x3,%eax
  80146c:	83 f8 01             	cmp    $0x1,%eax
  80146f:	75 21                	jne    801492 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801471:	a1 20 44 80 00       	mov    0x804420,%eax
  801476:	8b 40 48             	mov    0x48(%eax),%eax
  801479:	83 ec 04             	sub    $0x4,%esp
  80147c:	53                   	push   %ebx
  80147d:	50                   	push   %eax
  80147e:	68 9c 28 80 00       	push   $0x80289c
  801483:	e8 69 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801490:	eb 26                	jmp    8014b8 <read+0x8a>
	}
	if (!dev->dev_read)
  801492:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801495:	8b 40 08             	mov    0x8(%eax),%eax
  801498:	85 c0                	test   %eax,%eax
  80149a:	74 17                	je     8014b3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80149c:	83 ec 04             	sub    $0x4,%esp
  80149f:	ff 75 10             	pushl  0x10(%ebp)
  8014a2:	ff 75 0c             	pushl  0xc(%ebp)
  8014a5:	52                   	push   %edx
  8014a6:	ff d0                	call   *%eax
  8014a8:	89 c2                	mov    %eax,%edx
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	eb 09                	jmp    8014b8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014af:	89 c2                	mov    %eax,%edx
  8014b1:	eb 05                	jmp    8014b8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014b8:	89 d0                	mov    %edx,%eax
  8014ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    

008014bf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	57                   	push   %edi
  8014c3:	56                   	push   %esi
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d3:	eb 21                	jmp    8014f6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d5:	83 ec 04             	sub    $0x4,%esp
  8014d8:	89 f0                	mov    %esi,%eax
  8014da:	29 d8                	sub    %ebx,%eax
  8014dc:	50                   	push   %eax
  8014dd:	89 d8                	mov    %ebx,%eax
  8014df:	03 45 0c             	add    0xc(%ebp),%eax
  8014e2:	50                   	push   %eax
  8014e3:	57                   	push   %edi
  8014e4:	e8 45 ff ff ff       	call   80142e <read>
		if (m < 0)
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 10                	js     801500 <readn+0x41>
			return m;
		if (m == 0)
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	74 0a                	je     8014fe <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f4:	01 c3                	add    %eax,%ebx
  8014f6:	39 f3                	cmp    %esi,%ebx
  8014f8:	72 db                	jb     8014d5 <readn+0x16>
  8014fa:	89 d8                	mov    %ebx,%eax
  8014fc:	eb 02                	jmp    801500 <readn+0x41>
  8014fe:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801500:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801503:	5b                   	pop    %ebx
  801504:	5e                   	pop    %esi
  801505:	5f                   	pop    %edi
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    

00801508 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	53                   	push   %ebx
  80150c:	83 ec 14             	sub    $0x14,%esp
  80150f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801512:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801515:	50                   	push   %eax
  801516:	53                   	push   %ebx
  801517:	e8 ac fc ff ff       	call   8011c8 <fd_lookup>
  80151c:	83 c4 08             	add    $0x8,%esp
  80151f:	89 c2                	mov    %eax,%edx
  801521:	85 c0                	test   %eax,%eax
  801523:	78 68                	js     80158d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801525:	83 ec 08             	sub    $0x8,%esp
  801528:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152b:	50                   	push   %eax
  80152c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152f:	ff 30                	pushl  (%eax)
  801531:	e8 e8 fc ff ff       	call   80121e <dev_lookup>
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 47                	js     801584 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801540:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801544:	75 21                	jne    801567 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801546:	a1 20 44 80 00       	mov    0x804420,%eax
  80154b:	8b 40 48             	mov    0x48(%eax),%eax
  80154e:	83 ec 04             	sub    $0x4,%esp
  801551:	53                   	push   %ebx
  801552:	50                   	push   %eax
  801553:	68 b8 28 80 00       	push   $0x8028b8
  801558:	e8 94 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  80155d:	83 c4 10             	add    $0x10,%esp
  801560:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801565:	eb 26                	jmp    80158d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801567:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156a:	8b 52 0c             	mov    0xc(%edx),%edx
  80156d:	85 d2                	test   %edx,%edx
  80156f:	74 17                	je     801588 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801571:	83 ec 04             	sub    $0x4,%esp
  801574:	ff 75 10             	pushl  0x10(%ebp)
  801577:	ff 75 0c             	pushl  0xc(%ebp)
  80157a:	50                   	push   %eax
  80157b:	ff d2                	call   *%edx
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	eb 09                	jmp    80158d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801584:	89 c2                	mov    %eax,%edx
  801586:	eb 05                	jmp    80158d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801588:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80158d:	89 d0                	mov    %edx,%eax
  80158f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801592:	c9                   	leave  
  801593:	c3                   	ret    

00801594 <seek>:

int
seek(int fdnum, off_t offset)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	ff 75 08             	pushl  0x8(%ebp)
  8015a1:	e8 22 fc ff ff       	call   8011c8 <fd_lookup>
  8015a6:	83 c4 08             	add    $0x8,%esp
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 0e                	js     8015bb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 14             	sub    $0x14,%esp
  8015c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ca:	50                   	push   %eax
  8015cb:	53                   	push   %ebx
  8015cc:	e8 f7 fb ff ff       	call   8011c8 <fd_lookup>
  8015d1:	83 c4 08             	add    $0x8,%esp
  8015d4:	89 c2                	mov    %eax,%edx
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 65                	js     80163f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e0:	50                   	push   %eax
  8015e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e4:	ff 30                	pushl  (%eax)
  8015e6:	e8 33 fc ff ff       	call   80121e <dev_lookup>
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 44                	js     801636 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f9:	75 21                	jne    80161c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015fb:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801600:	8b 40 48             	mov    0x48(%eax),%eax
  801603:	83 ec 04             	sub    $0x4,%esp
  801606:	53                   	push   %ebx
  801607:	50                   	push   %eax
  801608:	68 78 28 80 00       	push   $0x802878
  80160d:	e8 df ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80161a:	eb 23                	jmp    80163f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80161c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161f:	8b 52 18             	mov    0x18(%edx),%edx
  801622:	85 d2                	test   %edx,%edx
  801624:	74 14                	je     80163a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801626:	83 ec 08             	sub    $0x8,%esp
  801629:	ff 75 0c             	pushl  0xc(%ebp)
  80162c:	50                   	push   %eax
  80162d:	ff d2                	call   *%edx
  80162f:	89 c2                	mov    %eax,%edx
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	eb 09                	jmp    80163f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801636:	89 c2                	mov    %eax,%edx
  801638:	eb 05                	jmp    80163f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80163a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80163f:	89 d0                	mov    %edx,%eax
  801641:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	53                   	push   %ebx
  80164a:	83 ec 14             	sub    $0x14,%esp
  80164d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801650:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	ff 75 08             	pushl  0x8(%ebp)
  801657:	e8 6c fb ff ff       	call   8011c8 <fd_lookup>
  80165c:	83 c4 08             	add    $0x8,%esp
  80165f:	89 c2                	mov    %eax,%edx
  801661:	85 c0                	test   %eax,%eax
  801663:	78 58                	js     8016bd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166f:	ff 30                	pushl  (%eax)
  801671:	e8 a8 fb ff ff       	call   80121e <dev_lookup>
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 37                	js     8016b4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80167d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801680:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801684:	74 32                	je     8016b8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801686:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801689:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801690:	00 00 00 
	stat->st_isdir = 0;
  801693:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80169a:	00 00 00 
	stat->st_dev = dev;
  80169d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	53                   	push   %ebx
  8016a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8016aa:	ff 50 14             	call   *0x14(%eax)
  8016ad:	89 c2                	mov    %eax,%edx
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	eb 09                	jmp    8016bd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b4:	89 c2                	mov    %eax,%edx
  8016b6:	eb 05                	jmp    8016bd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016bd:	89 d0                	mov    %edx,%eax
  8016bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	56                   	push   %esi
  8016c8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	6a 00                	push   $0x0
  8016ce:	ff 75 08             	pushl  0x8(%ebp)
  8016d1:	e8 2c 02 00 00       	call   801902 <open>
  8016d6:	89 c3                	mov    %eax,%ebx
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	78 1b                	js     8016fa <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	ff 75 0c             	pushl  0xc(%ebp)
  8016e5:	50                   	push   %eax
  8016e6:	e8 5b ff ff ff       	call   801646 <fstat>
  8016eb:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ed:	89 1c 24             	mov    %ebx,(%esp)
  8016f0:	e8 fd fb ff ff       	call   8012f2 <close>
	return r;
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	89 f0                	mov    %esi,%eax
}
  8016fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fd:	5b                   	pop    %ebx
  8016fe:	5e                   	pop    %esi
  8016ff:	5d                   	pop    %ebp
  801700:	c3                   	ret    

00801701 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
  801706:	89 c6                	mov    %eax,%esi
  801708:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  80170a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801711:	75 12                	jne    801725 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  801713:	83 ec 0c             	sub    $0xc,%esp
  801716:	6a 01                	push   $0x1
  801718:	e8 e9 08 00 00       	call   802006 <ipc_find_env>
  80171d:	a3 00 40 80 00       	mov    %eax,0x804000
  801722:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801725:	6a 07                	push   $0x7
  801727:	68 00 50 80 00       	push   $0x805000
  80172c:	56                   	push   %esi
  80172d:	ff 35 00 40 80 00    	pushl  0x804000
  801733:	e8 7a 08 00 00       	call   801fb2 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  801738:	83 c4 0c             	add    $0xc,%esp
  80173b:	6a 00                	push   $0x0
  80173d:	53                   	push   %ebx
  80173e:	6a 00                	push   $0x0
  801740:	e8 0e 08 00 00       	call   801f53 <ipc_recv>
}
  801745:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801748:	5b                   	pop    %ebx
  801749:	5e                   	pop    %esi
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801752:	8b 45 08             	mov    0x8(%ebp),%eax
  801755:	8b 40 0c             	mov    0xc(%eax),%eax
  801758:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  80175d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801760:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  801765:	ba 00 00 00 00       	mov    $0x0,%edx
  80176a:	b8 02 00 00 00       	mov    $0x2,%eax
  80176f:	e8 8d ff ff ff       	call   801701 <fsipc>
}
  801774:	c9                   	leave  
  801775:	c3                   	ret    

00801776 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80177c:	8b 45 08             	mov    0x8(%ebp),%eax
  80177f:	8b 40 0c             	mov    0xc(%eax),%eax
  801782:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  801787:	ba 00 00 00 00       	mov    $0x0,%edx
  80178c:	b8 06 00 00 00       	mov    $0x6,%eax
  801791:	e8 6b ff ff ff       	call   801701 <fsipc>
}
  801796:	c9                   	leave  
  801797:	c3                   	ret    

00801798 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	53                   	push   %ebx
  80179c:	83 ec 04             	sub    $0x4,%esp
  80179f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a8:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b7:	e8 45 ff ff ff       	call   801701 <fsipc>
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 2c                	js     8017ec <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c0:	83 ec 08             	sub    $0x8,%esp
  8017c3:	68 00 50 80 00       	push   $0x805000
  8017c8:	53                   	push   %ebx
  8017c9:	e8 a8 f0 ff ff       	call   800876 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8017ce:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d9:	a1 84 50 80 00       	mov    0x805084,%eax
  8017de:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	53                   	push   %ebx
  8017f5:	83 ec 08             	sub    $0x8,%esp
  8017f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801801:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  801806:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  80180c:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801812:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801817:	0f 46 c3             	cmovbe %ebx,%eax
  80181a:	50                   	push   %eax
  80181b:	ff 75 0c             	pushl  0xc(%ebp)
  80181e:	68 08 50 80 00       	push   $0x805008
  801823:	e8 e0 f1 ff ff       	call   800a08 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  801828:	ba 00 00 00 00       	mov    $0x0,%edx
  80182d:	b8 04 00 00 00       	mov    $0x4,%eax
  801832:	e8 ca fe ff ff       	call   801701 <fsipc>
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	85 c0                	test   %eax,%eax
  80183c:	78 3d                	js     80187b <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  80183e:	39 c3                	cmp    %eax,%ebx
  801840:	73 19                	jae    80185b <devfile_write+0x6a>
  801842:	68 e8 28 80 00       	push   $0x8028e8
  801847:	68 ef 28 80 00       	push   $0x8028ef
  80184c:	68 9a 00 00 00       	push   $0x9a
  801851:	68 04 29 80 00       	push   $0x802904
  801856:	e8 bd e9 ff ff       	call   800218 <_panic>
	   assert (r <= bytes_written);
  80185b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801860:	7e 19                	jle    80187b <devfile_write+0x8a>
  801862:	68 0f 29 80 00       	push   $0x80290f
  801867:	68 ef 28 80 00       	push   $0x8028ef
  80186c:	68 9b 00 00 00       	push   $0x9b
  801871:	68 04 29 80 00       	push   $0x802904
  801876:	e8 9d e9 ff ff       	call   800218 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  80187b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
  801885:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  801888:	8b 45 08             	mov    0x8(%ebp),%eax
  80188b:	8b 40 0c             	mov    0xc(%eax),%eax
  80188e:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  801893:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801899:	ba 00 00 00 00       	mov    $0x0,%edx
  80189e:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a3:	e8 59 fe ff ff       	call   801701 <fsipc>
  8018a8:	89 c3                	mov    %eax,%ebx
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 4b                	js     8018f9 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  8018ae:	39 c6                	cmp    %eax,%esi
  8018b0:	73 16                	jae    8018c8 <devfile_read+0x48>
  8018b2:	68 e8 28 80 00       	push   $0x8028e8
  8018b7:	68 ef 28 80 00       	push   $0x8028ef
  8018bc:	6a 7c                	push   $0x7c
  8018be:	68 04 29 80 00       	push   $0x802904
  8018c3:	e8 50 e9 ff ff       	call   800218 <_panic>
	   assert(r <= PGSIZE);
  8018c8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018cd:	7e 16                	jle    8018e5 <devfile_read+0x65>
  8018cf:	68 22 29 80 00       	push   $0x802922
  8018d4:	68 ef 28 80 00       	push   $0x8028ef
  8018d9:	6a 7d                	push   $0x7d
  8018db:	68 04 29 80 00       	push   $0x802904
  8018e0:	e8 33 e9 ff ff       	call   800218 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018e5:	83 ec 04             	sub    $0x4,%esp
  8018e8:	50                   	push   %eax
  8018e9:	68 00 50 80 00       	push   $0x805000
  8018ee:	ff 75 0c             	pushl  0xc(%ebp)
  8018f1:	e8 12 f1 ff ff       	call   800a08 <memmove>
	   return r;
  8018f6:	83 c4 10             	add    $0x10,%esp
}
  8018f9:	89 d8                	mov    %ebx,%eax
  8018fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5e                   	pop    %esi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    

00801902 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	83 ec 20             	sub    $0x20,%esp
  801909:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  80190c:	53                   	push   %ebx
  80190d:	e8 2b ef ff ff       	call   80083d <strlen>
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80191a:	7f 67                	jg     801983 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  80191c:	83 ec 0c             	sub    $0xc,%esp
  80191f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801922:	50                   	push   %eax
  801923:	e8 51 f8 ff ff       	call   801179 <fd_alloc>
  801928:	83 c4 10             	add    $0x10,%esp
			 return r;
  80192b:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  80192d:	85 c0                	test   %eax,%eax
  80192f:	78 57                	js     801988 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	53                   	push   %ebx
  801935:	68 00 50 80 00       	push   $0x805000
  80193a:	e8 37 ef ff ff       	call   800876 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  80193f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801942:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801947:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194a:	b8 01 00 00 00       	mov    $0x1,%eax
  80194f:	e8 ad fd ff ff       	call   801701 <fsipc>
  801954:	89 c3                	mov    %eax,%ebx
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	85 c0                	test   %eax,%eax
  80195b:	79 14                	jns    801971 <open+0x6f>
			 fd_close(fd, 0);
  80195d:	83 ec 08             	sub    $0x8,%esp
  801960:	6a 00                	push   $0x0
  801962:	ff 75 f4             	pushl  -0xc(%ebp)
  801965:	e8 07 f9 ff ff       	call   801271 <fd_close>
			 return r;
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	89 da                	mov    %ebx,%edx
  80196f:	eb 17                	jmp    801988 <open+0x86>
	   }

	   return fd2num(fd);
  801971:	83 ec 0c             	sub    $0xc,%esp
  801974:	ff 75 f4             	pushl  -0xc(%ebp)
  801977:	e8 d6 f7 ff ff       	call   801152 <fd2num>
  80197c:	89 c2                	mov    %eax,%edx
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	eb 05                	jmp    801988 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  801983:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801988:	89 d0                	mov    %edx,%eax
  80198a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801995:	ba 00 00 00 00       	mov    $0x0,%edx
  80199a:	b8 08 00 00 00       	mov    $0x8,%eax
  80199f:	e8 5d fd ff ff       	call   801701 <fsipc>
}
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    

008019a6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	56                   	push   %esi
  8019aa:	53                   	push   %ebx
  8019ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	ff 75 08             	pushl  0x8(%ebp)
  8019b4:	e8 a9 f7 ff ff       	call   801162 <fd2data>
  8019b9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019bb:	83 c4 08             	add    $0x8,%esp
  8019be:	68 2e 29 80 00       	push   $0x80292e
  8019c3:	53                   	push   %ebx
  8019c4:	e8 ad ee ff ff       	call   800876 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019c9:	8b 46 04             	mov    0x4(%esi),%eax
  8019cc:	2b 06                	sub    (%esi),%eax
  8019ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019db:	00 00 00 
	stat->st_dev = &devpipe;
  8019de:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019e5:	30 80 00 
	return 0;
}
  8019e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f0:	5b                   	pop    %ebx
  8019f1:	5e                   	pop    %esi
  8019f2:	5d                   	pop    %ebp
  8019f3:	c3                   	ret    

008019f4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	53                   	push   %ebx
  8019f8:	83 ec 0c             	sub    $0xc,%esp
  8019fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019fe:	53                   	push   %ebx
  8019ff:	6a 00                	push   $0x0
  801a01:	e8 f8 f2 ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a06:	89 1c 24             	mov    %ebx,(%esp)
  801a09:	e8 54 f7 ff ff       	call   801162 <fd2data>
  801a0e:	83 c4 08             	add    $0x8,%esp
  801a11:	50                   	push   %eax
  801a12:	6a 00                	push   $0x0
  801a14:	e8 e5 f2 ff ff       	call   800cfe <sys_page_unmap>
}
  801a19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	57                   	push   %edi
  801a22:	56                   	push   %esi
  801a23:	53                   	push   %ebx
  801a24:	83 ec 1c             	sub    $0x1c,%esp
  801a27:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a2a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a2c:	a1 20 44 80 00       	mov    0x804420,%eax
  801a31:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	ff 75 e0             	pushl  -0x20(%ebp)
  801a3a:	e8 00 06 00 00       	call   80203f <pageref>
  801a3f:	89 c3                	mov    %eax,%ebx
  801a41:	89 3c 24             	mov    %edi,(%esp)
  801a44:	e8 f6 05 00 00       	call   80203f <pageref>
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	39 c3                	cmp    %eax,%ebx
  801a4e:	0f 94 c1             	sete   %cl
  801a51:	0f b6 c9             	movzbl %cl,%ecx
  801a54:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a57:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a5d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a60:	39 ce                	cmp    %ecx,%esi
  801a62:	74 1b                	je     801a7f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a64:	39 c3                	cmp    %eax,%ebx
  801a66:	75 c4                	jne    801a2c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a68:	8b 42 58             	mov    0x58(%edx),%eax
  801a6b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a6e:	50                   	push   %eax
  801a6f:	56                   	push   %esi
  801a70:	68 35 29 80 00       	push   $0x802935
  801a75:	e8 77 e8 ff ff       	call   8002f1 <cprintf>
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	eb ad                	jmp    801a2c <_pipeisclosed+0xe>
	}
}
  801a7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5f                   	pop    %edi
  801a88:	5d                   	pop    %ebp
  801a89:	c3                   	ret    

00801a8a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	57                   	push   %edi
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	83 ec 28             	sub    $0x28,%esp
  801a93:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a96:	56                   	push   %esi
  801a97:	e8 c6 f6 ff ff       	call   801162 <fd2data>
  801a9c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	bf 00 00 00 00       	mov    $0x0,%edi
  801aa6:	eb 4b                	jmp    801af3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aa8:	89 da                	mov    %ebx,%edx
  801aaa:	89 f0                	mov    %esi,%eax
  801aac:	e8 6d ff ff ff       	call   801a1e <_pipeisclosed>
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	75 48                	jne    801afd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ab5:	e8 a0 f1 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aba:	8b 43 04             	mov    0x4(%ebx),%eax
  801abd:	8b 0b                	mov    (%ebx),%ecx
  801abf:	8d 51 20             	lea    0x20(%ecx),%edx
  801ac2:	39 d0                	cmp    %edx,%eax
  801ac4:	73 e2                	jae    801aa8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ac6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801acd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ad0:	89 c2                	mov    %eax,%edx
  801ad2:	c1 fa 1f             	sar    $0x1f,%edx
  801ad5:	89 d1                	mov    %edx,%ecx
  801ad7:	c1 e9 1b             	shr    $0x1b,%ecx
  801ada:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801add:	83 e2 1f             	and    $0x1f,%edx
  801ae0:	29 ca                	sub    %ecx,%edx
  801ae2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ae6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aea:	83 c0 01             	add    $0x1,%eax
  801aed:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af0:	83 c7 01             	add    $0x1,%edi
  801af3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801af6:	75 c2                	jne    801aba <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801af8:	8b 45 10             	mov    0x10(%ebp),%eax
  801afb:	eb 05                	jmp    801b02 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801afd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b05:	5b                   	pop    %ebx
  801b06:	5e                   	pop    %esi
  801b07:	5f                   	pop    %edi
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	57                   	push   %edi
  801b0e:	56                   	push   %esi
  801b0f:	53                   	push   %ebx
  801b10:	83 ec 18             	sub    $0x18,%esp
  801b13:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b16:	57                   	push   %edi
  801b17:	e8 46 f6 ff ff       	call   801162 <fd2data>
  801b1c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1e:	83 c4 10             	add    $0x10,%esp
  801b21:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b26:	eb 3d                	jmp    801b65 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b28:	85 db                	test   %ebx,%ebx
  801b2a:	74 04                	je     801b30 <devpipe_read+0x26>
				return i;
  801b2c:	89 d8                	mov    %ebx,%eax
  801b2e:	eb 44                	jmp    801b74 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b30:	89 f2                	mov    %esi,%edx
  801b32:	89 f8                	mov    %edi,%eax
  801b34:	e8 e5 fe ff ff       	call   801a1e <_pipeisclosed>
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	75 32                	jne    801b6f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b3d:	e8 18 f1 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b42:	8b 06                	mov    (%esi),%eax
  801b44:	3b 46 04             	cmp    0x4(%esi),%eax
  801b47:	74 df                	je     801b28 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b49:	99                   	cltd   
  801b4a:	c1 ea 1b             	shr    $0x1b,%edx
  801b4d:	01 d0                	add    %edx,%eax
  801b4f:	83 e0 1f             	and    $0x1f,%eax
  801b52:	29 d0                	sub    %edx,%eax
  801b54:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b5c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b5f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b62:	83 c3 01             	add    $0x1,%ebx
  801b65:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b68:	75 d8                	jne    801b42 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b6a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6d:	eb 05                	jmp    801b74 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b6f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b77:	5b                   	pop    %ebx
  801b78:	5e                   	pop    %esi
  801b79:	5f                   	pop    %edi
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	56                   	push   %esi
  801b80:	53                   	push   %ebx
  801b81:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b87:	50                   	push   %eax
  801b88:	e8 ec f5 ff ff       	call   801179 <fd_alloc>
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	89 c2                	mov    %eax,%edx
  801b92:	85 c0                	test   %eax,%eax
  801b94:	0f 88 2c 01 00 00    	js     801cc6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9a:	83 ec 04             	sub    $0x4,%esp
  801b9d:	68 07 04 00 00       	push   $0x407
  801ba2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba5:	6a 00                	push   $0x0
  801ba7:	e8 cd f0 ff ff       	call   800c79 <sys_page_alloc>
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	89 c2                	mov    %eax,%edx
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	0f 88 0d 01 00 00    	js     801cc6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bb9:	83 ec 0c             	sub    $0xc,%esp
  801bbc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bbf:	50                   	push   %eax
  801bc0:	e8 b4 f5 ff ff       	call   801179 <fd_alloc>
  801bc5:	89 c3                	mov    %eax,%ebx
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	0f 88 e2 00 00 00    	js     801cb4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd2:	83 ec 04             	sub    $0x4,%esp
  801bd5:	68 07 04 00 00       	push   $0x407
  801bda:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdd:	6a 00                	push   $0x0
  801bdf:	e8 95 f0 ff ff       	call   800c79 <sys_page_alloc>
  801be4:	89 c3                	mov    %eax,%ebx
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	85 c0                	test   %eax,%eax
  801beb:	0f 88 c3 00 00 00    	js     801cb4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bf1:	83 ec 0c             	sub    $0xc,%esp
  801bf4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf7:	e8 66 f5 ff ff       	call   801162 <fd2data>
  801bfc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfe:	83 c4 0c             	add    $0xc,%esp
  801c01:	68 07 04 00 00       	push   $0x407
  801c06:	50                   	push   %eax
  801c07:	6a 00                	push   $0x0
  801c09:	e8 6b f0 ff ff       	call   800c79 <sys_page_alloc>
  801c0e:	89 c3                	mov    %eax,%ebx
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	85 c0                	test   %eax,%eax
  801c15:	0f 88 89 00 00 00    	js     801ca4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1b:	83 ec 0c             	sub    $0xc,%esp
  801c1e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c21:	e8 3c f5 ff ff       	call   801162 <fd2data>
  801c26:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c2d:	50                   	push   %eax
  801c2e:	6a 00                	push   $0x0
  801c30:	56                   	push   %esi
  801c31:	6a 00                	push   $0x0
  801c33:	e8 84 f0 ff ff       	call   800cbc <sys_page_map>
  801c38:	89 c3                	mov    %eax,%ebx
  801c3a:	83 c4 20             	add    $0x20,%esp
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	78 55                	js     801c96 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c41:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c56:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c5f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c64:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c6b:	83 ec 0c             	sub    $0xc,%esp
  801c6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c71:	e8 dc f4 ff ff       	call   801152 <fd2num>
  801c76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c79:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c7b:	83 c4 04             	add    $0x4,%esp
  801c7e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c81:	e8 cc f4 ff ff       	call   801152 <fd2num>
  801c86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c89:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c94:	eb 30                	jmp    801cc6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c96:	83 ec 08             	sub    $0x8,%esp
  801c99:	56                   	push   %esi
  801c9a:	6a 00                	push   $0x0
  801c9c:	e8 5d f0 ff ff       	call   800cfe <sys_page_unmap>
  801ca1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ca4:	83 ec 08             	sub    $0x8,%esp
  801ca7:	ff 75 f0             	pushl  -0x10(%ebp)
  801caa:	6a 00                	push   $0x0
  801cac:	e8 4d f0 ff ff       	call   800cfe <sys_page_unmap>
  801cb1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cb4:	83 ec 08             	sub    $0x8,%esp
  801cb7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cba:	6a 00                	push   $0x0
  801cbc:	e8 3d f0 ff ff       	call   800cfe <sys_page_unmap>
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cc6:	89 d0                	mov    %edx,%eax
  801cc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd8:	50                   	push   %eax
  801cd9:	ff 75 08             	pushl  0x8(%ebp)
  801cdc:	e8 e7 f4 ff ff       	call   8011c8 <fd_lookup>
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	78 18                	js     801d00 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ce8:	83 ec 0c             	sub    $0xc,%esp
  801ceb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cee:	e8 6f f4 ff ff       	call   801162 <fd2data>
	return _pipeisclosed(fd, p);
  801cf3:	89 c2                	mov    %eax,%edx
  801cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf8:	e8 21 fd ff ff       	call   801a1e <_pipeisclosed>
  801cfd:	83 c4 10             	add    $0x10,%esp
}
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	56                   	push   %esi
  801d06:	53                   	push   %ebx
  801d07:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d0a:	85 f6                	test   %esi,%esi
  801d0c:	75 16                	jne    801d24 <wait+0x22>
  801d0e:	68 4d 29 80 00       	push   $0x80294d
  801d13:	68 ef 28 80 00       	push   $0x8028ef
  801d18:	6a 09                	push   $0x9
  801d1a:	68 58 29 80 00       	push   $0x802958
  801d1f:	e8 f4 e4 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801d24:	89 f3                	mov    %esi,%ebx
  801d26:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d2c:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d2f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d35:	eb 05                	jmp    801d3c <wait+0x3a>
		sys_yield();
  801d37:	e8 1e ef ff ff       	call   800c5a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d3c:	8b 43 48             	mov    0x48(%ebx),%eax
  801d3f:	39 c6                	cmp    %eax,%esi
  801d41:	75 07                	jne    801d4a <wait+0x48>
  801d43:	8b 43 54             	mov    0x54(%ebx),%eax
  801d46:	85 c0                	test   %eax,%eax
  801d48:	75 ed                	jne    801d37 <wait+0x35>
		sys_yield();
}
  801d4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5d                   	pop    %ebp
  801d50:	c3                   	ret    

00801d51 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d54:	b8 00 00 00 00       	mov    $0x0,%eax
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    

00801d5b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d61:	68 63 29 80 00       	push   $0x802963
  801d66:	ff 75 0c             	pushl  0xc(%ebp)
  801d69:	e8 08 eb ff ff       	call   800876 <strcpy>
	return 0;
}
  801d6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    

00801d75 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	57                   	push   %edi
  801d79:	56                   	push   %esi
  801d7a:	53                   	push   %ebx
  801d7b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d81:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d86:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8c:	eb 2d                	jmp    801dbb <devcons_write+0x46>
		m = n - tot;
  801d8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d91:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d93:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d96:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d9b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d9e:	83 ec 04             	sub    $0x4,%esp
  801da1:	53                   	push   %ebx
  801da2:	03 45 0c             	add    0xc(%ebp),%eax
  801da5:	50                   	push   %eax
  801da6:	57                   	push   %edi
  801da7:	e8 5c ec ff ff       	call   800a08 <memmove>
		sys_cputs(buf, m);
  801dac:	83 c4 08             	add    $0x8,%esp
  801daf:	53                   	push   %ebx
  801db0:	57                   	push   %edi
  801db1:	e8 07 ee ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db6:	01 de                	add    %ebx,%esi
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	89 f0                	mov    %esi,%eax
  801dbd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc0:	72 cc                	jb     801d8e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5f                   	pop    %edi
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    

00801dca <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	83 ec 08             	sub    $0x8,%esp
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dd5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd9:	74 2a                	je     801e05 <devcons_read+0x3b>
  801ddb:	eb 05                	jmp    801de2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ddd:	e8 78 ee ff ff       	call   800c5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de2:	e8 f4 ed ff ff       	call   800bdb <sys_cgetc>
  801de7:	85 c0                	test   %eax,%eax
  801de9:	74 f2                	je     801ddd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801deb:	85 c0                	test   %eax,%eax
  801ded:	78 16                	js     801e05 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801def:	83 f8 04             	cmp    $0x4,%eax
  801df2:	74 0c                	je     801e00 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801df4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df7:	88 02                	mov    %al,(%edx)
	return 1;
  801df9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfe:	eb 05                	jmp    801e05 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e00:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e05:	c9                   	leave  
  801e06:	c3                   	ret    

00801e07 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e10:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e13:	6a 01                	push   $0x1
  801e15:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e18:	50                   	push   %eax
  801e19:	e8 9f ed ff ff       	call   800bbd <sys_cputs>
}
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    

00801e23 <getchar>:

int
getchar(void)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e29:	6a 01                	push   $0x1
  801e2b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2e:	50                   	push   %eax
  801e2f:	6a 00                	push   $0x0
  801e31:	e8 f8 f5 ff ff       	call   80142e <read>
	if (r < 0)
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	78 0f                	js     801e4c <getchar+0x29>
		return r;
	if (r < 1)
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	7e 06                	jle    801e47 <getchar+0x24>
		return -E_EOF;
	return c;
  801e41:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e45:	eb 05                	jmp    801e4c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e47:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e4c:	c9                   	leave  
  801e4d:	c3                   	ret    

00801e4e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e57:	50                   	push   %eax
  801e58:	ff 75 08             	pushl  0x8(%ebp)
  801e5b:	e8 68 f3 ff ff       	call   8011c8 <fd_lookup>
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	85 c0                	test   %eax,%eax
  801e65:	78 11                	js     801e78 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e70:	39 10                	cmp    %edx,(%eax)
  801e72:	0f 94 c0             	sete   %al
  801e75:	0f b6 c0             	movzbl %al,%eax
}
  801e78:	c9                   	leave  
  801e79:	c3                   	ret    

00801e7a <opencons>:

int
opencons(void)
{
  801e7a:	55                   	push   %ebp
  801e7b:	89 e5                	mov    %esp,%ebp
  801e7d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e83:	50                   	push   %eax
  801e84:	e8 f0 f2 ff ff       	call   801179 <fd_alloc>
  801e89:	83 c4 10             	add    $0x10,%esp
		return r;
  801e8c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	78 3e                	js     801ed0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e92:	83 ec 04             	sub    $0x4,%esp
  801e95:	68 07 04 00 00       	push   $0x407
  801e9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9d:	6a 00                	push   $0x0
  801e9f:	e8 d5 ed ff ff       	call   800c79 <sys_page_alloc>
  801ea4:	83 c4 10             	add    $0x10,%esp
		return r;
  801ea7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	78 23                	js     801ed0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ead:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec2:	83 ec 0c             	sub    $0xc,%esp
  801ec5:	50                   	push   %eax
  801ec6:	e8 87 f2 ff ff       	call   801152 <fd2num>
  801ecb:	89 c2                	mov    %eax,%edx
  801ecd:	83 c4 10             	add    $0x10,%esp
}
  801ed0:	89 d0                	mov    %edx,%eax
  801ed2:	c9                   	leave  
  801ed3:	c3                   	ret    

00801ed4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  801eda:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ee1:	75 2a                	jne    801f0d <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801ee3:	83 ec 04             	sub    $0x4,%esp
  801ee6:	6a 06                	push   $0x6
  801ee8:	68 00 f0 bf ee       	push   $0xeebff000
  801eed:	6a 00                	push   $0x0
  801eef:	e8 85 ed ff ff       	call   800c79 <sys_page_alloc>
			 if (a < 0)
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	79 12                	jns    801f0d <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801efb:	50                   	push   %eax
  801efc:	68 6f 29 80 00       	push   $0x80296f
  801f01:	6a 21                	push   $0x21
  801f03:	68 89 29 80 00       	push   $0x802989
  801f08:	e8 0b e3 ff ff       	call   800218 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  801f0d:	e8 29 ed ff ff       	call   800c3b <sys_getenvid>
  801f12:	83 ec 08             	sub    $0x8,%esp
  801f15:	68 2d 1f 80 00       	push   $0x801f2d
  801f1a:	50                   	push   %eax
  801f1b:	e8 a4 ee ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  801f20:	8b 45 08             	mov    0x8(%ebp),%eax
  801f23:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	c9                   	leave  
  801f2c:	c3                   	ret    

00801f2d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  801f2d:	54                   	push   %esp
movl _pgfault_handler, %eax
  801f2e:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  801f33:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  801f35:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  801f38:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  801f3c:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  801f40:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  801f43:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  801f47:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  801f49:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  801f4c:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  801f4d:	83 c4 04             	add    $0x4,%esp
popfl
  801f50:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  801f51:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  801f52:	c3                   	ret    

00801f53 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	56                   	push   %esi
  801f57:	53                   	push   %ebx
  801f58:	8b 75 08             	mov    0x8(%ebp),%esi
  801f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801f61:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801f63:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f68:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801f6b:	83 ec 0c             	sub    $0xc,%esp
  801f6e:	50                   	push   %eax
  801f6f:	e8 b5 ee ff ff       	call   800e29 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	85 c0                	test   %eax,%eax
  801f79:	78 0e                	js     801f89 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801f7b:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801f81:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801f84:	8b 52 78             	mov    0x78(%edx),%edx
  801f87:	eb 0a                	jmp    801f93 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801f89:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801f8e:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801f93:	85 f6                	test   %esi,%esi
  801f95:	74 02                	je     801f99 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801f97:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801f99:	85 db                	test   %ebx,%ebx
  801f9b:	74 02                	je     801f9f <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801f9d:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	78 08                	js     801fab <ipc_recv+0x58>
  801fa3:	a1 20 44 80 00       	mov    0x804420,%eax
  801fa8:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801fab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fae:	5b                   	pop    %ebx
  801faf:	5e                   	pop    %esi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    

00801fb2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	57                   	push   %edi
  801fb6:	56                   	push   %esi
  801fb7:	53                   	push   %ebx
  801fb8:	83 ec 0c             	sub    $0xc,%esp
  801fbb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fbe:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801fc4:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801fc6:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801fcb:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801fce:	ff 75 14             	pushl  0x14(%ebp)
  801fd1:	53                   	push   %ebx
  801fd2:	56                   	push   %esi
  801fd3:	57                   	push   %edi
  801fd4:	e8 2d ee ff ff       	call   800e06 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801fd9:	83 c4 10             	add    $0x10,%esp
  801fdc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fdf:	75 07                	jne    801fe8 <ipc_send+0x36>
				    sys_yield();
  801fe1:	e8 74 ec ff ff       	call   800c5a <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801fe6:	eb e6                	jmp    801fce <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	74 12                	je     801ffe <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801fec:	50                   	push   %eax
  801fed:	68 97 29 80 00       	push   $0x802997
  801ff2:	6a 4b                	push   $0x4b
  801ff4:	68 ab 29 80 00       	push   $0x8029ab
  801ff9:	e8 1a e2 ff ff       	call   800218 <_panic>
			 }
	   }
}
  801ffe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802001:	5b                   	pop    %ebx
  802002:	5e                   	pop    %esi
  802003:	5f                   	pop    %edi
  802004:	5d                   	pop    %ebp
  802005:	c3                   	ret    

00802006 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  80200c:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  802011:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802014:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80201a:	8b 52 50             	mov    0x50(%edx),%edx
  80201d:	39 ca                	cmp    %ecx,%edx
  80201f:	75 0d                	jne    80202e <ipc_find_env+0x28>
				    return envs[i].env_id;
  802021:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802024:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802029:	8b 40 48             	mov    0x48(%eax),%eax
  80202c:	eb 0f                	jmp    80203d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  80202e:	83 c0 01             	add    $0x1,%eax
  802031:	3d 00 04 00 00       	cmp    $0x400,%eax
  802036:	75 d9                	jne    802011 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  802038:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    

0080203f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80203f:	55                   	push   %ebp
  802040:	89 e5                	mov    %esp,%ebp
  802042:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802045:	89 d0                	mov    %edx,%eax
  802047:	c1 e8 16             	shr    $0x16,%eax
  80204a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802051:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802056:	f6 c1 01             	test   $0x1,%cl
  802059:	74 1d                	je     802078 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80205b:	c1 ea 0c             	shr    $0xc,%edx
  80205e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802065:	f6 c2 01             	test   $0x1,%dl
  802068:	74 0e                	je     802078 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80206a:	c1 ea 0c             	shr    $0xc,%edx
  80206d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802074:	ef 
  802075:	0f b7 c0             	movzwl %ax,%eax
}
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    
  80207a:	66 90                	xchg   %ax,%ax
  80207c:	66 90                	xchg   %ax,%ax
  80207e:	66 90                	xchg   %ax,%ax

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
