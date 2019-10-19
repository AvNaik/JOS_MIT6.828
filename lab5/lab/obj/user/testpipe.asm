
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 20 	movl   $0x802420,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 28 1c 00 00       	call   801c76 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 2c 24 80 00       	push   $0x80242c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 35 24 80 00       	push   $0x802435
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 df 0f 00 00       	call   80104d <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 48 29 80 00       	push   $0x802948
  80007a:	6a 11                	push   $0x11
  80007c:	68 35 24 80 00       	push   $0x802435
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 45 24 80 00       	push   $0x802445
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 3a 13 00 00       	call   8013ec <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 62 24 80 00       	push   $0x802462
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 dd 14 00 00       	call   8015b9 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 7f 24 80 00       	push   $0x80247f
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 35 24 80 00       	push   $0x802435
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 0c 09 00 00       	call   800a1a <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 88 24 80 00       	push   $0x802488
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 a4 24 80 00       	push   $0x8024a4
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 45 24 80 00       	push   $0x802445
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 82 12 00 00       	call   8013ec <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 b7 24 80 00       	push   $0x8024b7
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 a6 07 00 00       	call   800937 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 5f 14 00 00       	call   801602 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 84 07 00 00       	call   800937 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 d4 24 80 00       	push   $0x8024d4
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 35 24 80 00       	push   $0x802435
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 15 12 00 00       	call   8013ec <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 19 1c 00 00       	call   801dfc <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 de 	movl   $0x8024de,0x803004
  8001ea:	24 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 7e 1a 00 00       	call   801c76 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 2c 24 80 00       	push   $0x80242c
  800207:	6a 2c                	push   $0x2c
  800209:	68 35 24 80 00       	push   $0x802435
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 35 0e 00 00       	call   80104d <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 48 29 80 00       	push   $0x802948
  800224:	6a 2f                	push   $0x2f
  800226:	68 35 24 80 00       	push   $0x802435
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 ad 11 00 00       	call   8013ec <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 eb 24 80 00       	push   $0x8024eb
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 ed 24 80 00       	push   $0x8024ed
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 a1 13 00 00       	call   801602 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 ef 24 80 00       	push   $0x8024ef
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 63 11 00 00       	call   8013ec <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 58 11 00 00       	call   8013ec <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 60 1b 00 00       	call   801dfc <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 0c 25 80 00 	movl   $0x80250c,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8002bd:	e8 73 0a 00 00       	call   800d35 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 14 11 00 00       	call   801417 <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 e7 09 00 00       	call   800cf4 <sys_env_destroy>
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 10 0a 00 00       	call   800d35 <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 70 25 80 00       	push   $0x802570
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 60 24 80 00 	movl   $0x802460,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 2f 09 00 00       	call   800cb7 <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 54 01 00 00       	call   800522 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 d4 08 00 00       	call   800cb7 <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 2d 1d 00 00       	call   802180 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 1a 1e 00 00       	call   8022b0 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 93 25 80 00 	movsbl 0x802593(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b1:	83 fa 01             	cmp    $0x1,%edx
  8004b4:	7e 0e                	jle    8004c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004bb:	89 08                	mov    %ecx,(%eax)
  8004bd:	8b 02                	mov    (%edx),%eax
  8004bf:	8b 52 04             	mov    0x4(%edx),%edx
  8004c2:	eb 22                	jmp    8004e6 <getuint+0x38>
	else if (lflag)
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	74 10                	je     8004d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	eb 0e                	jmp    8004e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d8:	8b 10                	mov    (%eax),%edx
  8004da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dd:	89 08                	mov    %ecx,(%eax)
  8004df:	8b 02                	mov    (%edx),%eax
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e6:	5d                   	pop    %ebp
  8004e7:	c3                   	ret    

008004e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f2:	8b 10                	mov    (%eax),%edx
  8004f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f7:	73 0a                	jae    800503 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fc:	89 08                	mov    %ecx,(%eax)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	88 02                	mov    %al,(%edx)
}
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050e:	50                   	push   %eax
  80050f:	ff 75 10             	pushl  0x10(%ebp)
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	ff 75 08             	pushl  0x8(%ebp)
  800518:	e8 05 00 00 00       	call   800522 <vprintfmt>
	va_end(ap);
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	53                   	push   %ebx
  800528:	83 ec 2c             	sub    $0x2c,%esp
  80052b:	8b 75 08             	mov    0x8(%ebp),%esi
  80052e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800531:	8b 7d 10             	mov    0x10(%ebp),%edi
  800534:	eb 12                	jmp    800548 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800536:	85 c0                	test   %eax,%eax
  800538:	0f 84 89 03 00 00    	je     8008c7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	50                   	push   %eax
  800543:	ff d6                	call   *%esi
  800545:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800548:	83 c7 01             	add    $0x1,%edi
  80054b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054f:	83 f8 25             	cmp    $0x25,%eax
  800552:	75 e2                	jne    800536 <vprintfmt+0x14>
  800554:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800558:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800566:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056d:	ba 00 00 00 00       	mov    $0x0,%edx
  800572:	eb 07                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800577:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8d 47 01             	lea    0x1(%edi),%eax
  80057e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800581:	0f b6 07             	movzbl (%edi),%eax
  800584:	0f b6 c8             	movzbl %al,%ecx
  800587:	83 e8 23             	sub    $0x23,%eax
  80058a:	3c 55                	cmp    $0x55,%al
  80058c:	0f 87 1a 03 00 00    	ja     8008ac <vprintfmt+0x38a>
  800592:	0f b6 c0             	movzbl %al,%eax
  800595:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
  80059c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a3:	eb d6                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ba:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005bd:	83 fa 09             	cmp    $0x9,%edx
  8005c0:	77 39                	ja     8005fb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c5:	eb e9                	jmp    8005b0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8005cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d8:	eb 27                	jmp    800601 <vprintfmt+0xdf>
  8005da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e4:	0f 49 c8             	cmovns %eax,%ecx
  8005e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ed:	eb 8c                	jmp    80057b <vprintfmt+0x59>
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f9:	eb 80                	jmp    80057b <vprintfmt+0x59>
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800601:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800605:	0f 89 70 ff ff ff    	jns    80057b <vprintfmt+0x59>
				width = precision, precision = -1;
  80060b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80060e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800611:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800618:	e9 5e ff ff ff       	jmp    80057b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800623:	e9 53 ff ff ff       	jmp    80057b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	ff 30                	pushl  (%eax)
  800637:	ff d6                	call   *%esi
			break;
  800639:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063f:	e9 04 ff ff ff       	jmp    800548 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	99                   	cltd   
  800650:	31 d0                	xor    %edx,%eax
  800652:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800654:	83 f8 0f             	cmp    $0xf,%eax
  800657:	7f 0b                	jg     800664 <vprintfmt+0x142>
  800659:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	75 18                	jne    80067c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800664:	50                   	push   %eax
  800665:	68 ab 25 80 00       	push   $0x8025ab
  80066a:	53                   	push   %ebx
  80066b:	56                   	push   %esi
  80066c:	e8 94 fe ff ff       	call   800505 <printfmt>
  800671:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800677:	e9 cc fe ff ff       	jmp    800548 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067c:	52                   	push   %edx
  80067d:	68 21 2a 80 00       	push   $0x802a21
  800682:	53                   	push   %ebx
  800683:	56                   	push   %esi
  800684:	e8 7c fe ff ff       	call   800505 <printfmt>
  800689:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068f:	e9 b4 fe ff ff       	jmp    800548 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069f:	85 ff                	test   %edi,%edi
  8006a1:	b8 a4 25 80 00       	mov    $0x8025a4,%eax
  8006a6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ad:	0f 8e 94 00 00 00    	jle    800747 <vprintfmt+0x225>
  8006b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b7:	0f 84 98 00 00 00    	je     800755 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c3:	57                   	push   %edi
  8006c4:	e8 86 02 00 00       	call   80094f <strnlen>
  8006c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cc:	29 c1                	sub    %eax,%ecx
  8006ce:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006d1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006db:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006de:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e0:	eb 0f                	jmp    8006f1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006eb:	83 ef 01             	sub    $0x1,%edi
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 ff                	test   %edi,%edi
  8006f3:	7f ed                	jg     8006e2 <vprintfmt+0x1c0>
  8006f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800702:	0f 49 c1             	cmovns %ecx,%eax
  800705:	29 c1                	sub    %eax,%ecx
  800707:	89 75 08             	mov    %esi,0x8(%ebp)
  80070a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800710:	89 cb                	mov    %ecx,%ebx
  800712:	eb 4d                	jmp    800761 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800714:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800718:	74 1b                	je     800735 <vprintfmt+0x213>
  80071a:	0f be c0             	movsbl %al,%eax
  80071d:	83 e8 20             	sub    $0x20,%eax
  800720:	83 f8 5e             	cmp    $0x5e,%eax
  800723:	76 10                	jbe    800735 <vprintfmt+0x213>
					putch('?', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	6a 3f                	push   $0x3f
  80072d:	ff 55 08             	call   *0x8(%ebp)
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	eb 0d                	jmp    800742 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	52                   	push   %edx
  80073c:	ff 55 08             	call   *0x8(%ebp)
  80073f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800742:	83 eb 01             	sub    $0x1,%ebx
  800745:	eb 1a                	jmp    800761 <vprintfmt+0x23f>
  800747:	89 75 08             	mov    %esi,0x8(%ebp)
  80074a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800750:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800753:	eb 0c                	jmp    800761 <vprintfmt+0x23f>
  800755:	89 75 08             	mov    %esi,0x8(%ebp)
  800758:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800761:	83 c7 01             	add    $0x1,%edi
  800764:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800768:	0f be d0             	movsbl %al,%edx
  80076b:	85 d2                	test   %edx,%edx
  80076d:	74 23                	je     800792 <vprintfmt+0x270>
  80076f:	85 f6                	test   %esi,%esi
  800771:	78 a1                	js     800714 <vprintfmt+0x1f2>
  800773:	83 ee 01             	sub    $0x1,%esi
  800776:	79 9c                	jns    800714 <vprintfmt+0x1f2>
  800778:	89 df                	mov    %ebx,%edi
  80077a:	8b 75 08             	mov    0x8(%ebp),%esi
  80077d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800780:	eb 18                	jmp    80079a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	53                   	push   %ebx
  800786:	6a 20                	push   $0x20
  800788:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078a:	83 ef 01             	sub    $0x1,%edi
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	eb 08                	jmp    80079a <vprintfmt+0x278>
  800792:	89 df                	mov    %ebx,%edi
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079a:	85 ff                	test   %edi,%edi
  80079c:	7f e4                	jg     800782 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a1:	e9 a2 fd ff ff       	jmp    800548 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a6:	83 fa 01             	cmp    $0x1,%edx
  8007a9:	7e 16                	jle    8007c1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 08             	lea    0x8(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 50 04             	mov    0x4(%eax),%edx
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007bf:	eb 32                	jmp    8007f3 <vprintfmt+0x2d1>
	else if (lflag)
  8007c1:	85 d2                	test   %edx,%edx
  8007c3:	74 18                	je     8007dd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8d 50 04             	lea    0x4(%eax),%edx
  8007cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ce:	8b 00                	mov    (%eax),%eax
  8007d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d3:	89 c1                	mov    %eax,%ecx
  8007d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007db:	eb 16                	jmp    8007f3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 c1                	mov    %eax,%ecx
  8007ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800802:	79 74                	jns    800878 <vprintfmt+0x356>
				putch('-', putdat);
  800804:	83 ec 08             	sub    $0x8,%esp
  800807:	53                   	push   %ebx
  800808:	6a 2d                	push   $0x2d
  80080a:	ff d6                	call   *%esi
				num = -(long long) num;
  80080c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800812:	f7 d8                	neg    %eax
  800814:	83 d2 00             	adc    $0x0,%edx
  800817:	f7 da                	neg    %edx
  800819:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800821:	eb 55                	jmp    800878 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
  800826:	e8 83 fc ff ff       	call   8004ae <getuint>
			base = 10;
  80082b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800830:	eb 46                	jmp    800878 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800832:	8d 45 14             	lea    0x14(%ebp),%eax
  800835:	e8 74 fc ff ff       	call   8004ae <getuint>
			base = 8;
  80083a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80083f:	eb 37                	jmp    800878 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	53                   	push   %ebx
  800845:	6a 30                	push   $0x30
  800847:	ff d6                	call   *%esi
			putch('x', putdat);
  800849:	83 c4 08             	add    $0x8,%esp
  80084c:	53                   	push   %ebx
  80084d:	6a 78                	push   $0x78
  80084f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8d 50 04             	lea    0x4(%eax),%edx
  800857:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80085a:	8b 00                	mov    (%eax),%eax
  80085c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800861:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800864:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800869:	eb 0d                	jmp    800878 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80086b:	8d 45 14             	lea    0x14(%ebp),%eax
  80086e:	e8 3b fc ff ff       	call   8004ae <getuint>
			base = 16;
  800873:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800878:	83 ec 0c             	sub    $0xc,%esp
  80087b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80087f:	57                   	push   %edi
  800880:	ff 75 e0             	pushl  -0x20(%ebp)
  800883:	51                   	push   %ecx
  800884:	52                   	push   %edx
  800885:	50                   	push   %eax
  800886:	89 da                	mov    %ebx,%edx
  800888:	89 f0                	mov    %esi,%eax
  80088a:	e8 70 fb ff ff       	call   8003ff <printnum>
			break;
  80088f:	83 c4 20             	add    $0x20,%esp
  800892:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800895:	e9 ae fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	53                   	push   %ebx
  80089e:	51                   	push   %ecx
  80089f:	ff d6                	call   *%esi
			break;
  8008a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a7:	e9 9c fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	6a 25                	push   $0x25
  8008b2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 03                	jmp    8008bc <vprintfmt+0x39a>
  8008b9:	83 ef 01             	sub    $0x1,%edi
  8008bc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008c0:	75 f7                	jne    8008b9 <vprintfmt+0x397>
  8008c2:	e9 81 fc ff ff       	jmp    800548 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	83 ec 18             	sub    $0x18,%esp
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008de:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ec:	85 c0                	test   %eax,%eax
  8008ee:	74 26                	je     800916 <vsnprintf+0x47>
  8008f0:	85 d2                	test   %edx,%edx
  8008f2:	7e 22                	jle    800916 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f4:	ff 75 14             	pushl  0x14(%ebp)
  8008f7:	ff 75 10             	pushl  0x10(%ebp)
  8008fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fd:	50                   	push   %eax
  8008fe:	68 e8 04 80 00       	push   $0x8004e8
  800903:	e8 1a fc ff ff       	call   800522 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800908:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	eb 05                	jmp    80091b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800916:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800923:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800926:	50                   	push   %eax
  800927:	ff 75 10             	pushl  0x10(%ebp)
  80092a:	ff 75 0c             	pushl  0xc(%ebp)
  80092d:	ff 75 08             	pushl  0x8(%ebp)
  800930:	e8 9a ff ff ff       	call   8008cf <vsnprintf>
	va_end(ap);

	return rc;
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
  800942:	eb 03                	jmp    800947 <strlen+0x10>
		n++;
  800944:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800947:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80094b:	75 f7                	jne    800944 <strlen+0xd>
		n++;
	return n;
}
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800958:	ba 00 00 00 00       	mov    $0x0,%edx
  80095d:	eb 03                	jmp    800962 <strnlen+0x13>
		n++;
  80095f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800962:	39 c2                	cmp    %eax,%edx
  800964:	74 08                	je     80096e <strnlen+0x1f>
  800966:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80096a:	75 f3                	jne    80095f <strnlen+0x10>
  80096c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	83 c1 01             	add    $0x1,%ecx
  800982:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800986:	88 5a ff             	mov    %bl,-0x1(%edx)
  800989:	84 db                	test   %bl,%bl
  80098b:	75 ef                	jne    80097c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80098d:	5b                   	pop    %ebx
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800997:	53                   	push   %ebx
  800998:	e8 9a ff ff ff       	call   800937 <strlen>
  80099d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a0:	ff 75 0c             	pushl  0xc(%ebp)
  8009a3:	01 d8                	add    %ebx,%eax
  8009a5:	50                   	push   %eax
  8009a6:	e8 c5 ff ff ff       	call   800970 <strcpy>
	return dst;
}
  8009ab:	89 d8                	mov    %ebx,%eax
  8009ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bd:	89 f3                	mov    %esi,%ebx
  8009bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c2:	89 f2                	mov    %esi,%edx
  8009c4:	eb 0f                	jmp    8009d5 <strncpy+0x23>
		*dst++ = *src;
  8009c6:	83 c2 01             	add    $0x1,%edx
  8009c9:	0f b6 01             	movzbl (%ecx),%eax
  8009cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d5:	39 da                	cmp    %ebx,%edx
  8009d7:	75 ed                	jne    8009c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d9:	89 f0                	mov    %esi,%eax
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ea:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ed:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ef:	85 d2                	test   %edx,%edx
  8009f1:	74 21                	je     800a14 <strlcpy+0x35>
  8009f3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f7:	89 f2                	mov    %esi,%edx
  8009f9:	eb 09                	jmp    800a04 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	83 c1 01             	add    $0x1,%ecx
  800a01:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a04:	39 c2                	cmp    %eax,%edx
  800a06:	74 09                	je     800a11 <strlcpy+0x32>
  800a08:	0f b6 19             	movzbl (%ecx),%ebx
  800a0b:	84 db                	test   %bl,%bl
  800a0d:	75 ec                	jne    8009fb <strlcpy+0x1c>
  800a0f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a11:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a14:	29 f0                	sub    %esi,%eax
}
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a23:	eb 06                	jmp    800a2b <strcmp+0x11>
		p++, q++;
  800a25:	83 c1 01             	add    $0x1,%ecx
  800a28:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2b:	0f b6 01             	movzbl (%ecx),%eax
  800a2e:	84 c0                	test   %al,%al
  800a30:	74 04                	je     800a36 <strcmp+0x1c>
  800a32:	3a 02                	cmp    (%edx),%al
  800a34:	74 ef                	je     800a25 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a36:	0f b6 c0             	movzbl %al,%eax
  800a39:	0f b6 12             	movzbl (%edx),%edx
  800a3c:	29 d0                	sub    %edx,%eax
}
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4a:	89 c3                	mov    %eax,%ebx
  800a4c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a4f:	eb 06                	jmp    800a57 <strncmp+0x17>
		n--, p++, q++;
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a57:	39 d8                	cmp    %ebx,%eax
  800a59:	74 15                	je     800a70 <strncmp+0x30>
  800a5b:	0f b6 08             	movzbl (%eax),%ecx
  800a5e:	84 c9                	test   %cl,%cl
  800a60:	74 04                	je     800a66 <strncmp+0x26>
  800a62:	3a 0a                	cmp    (%edx),%cl
  800a64:	74 eb                	je     800a51 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a66:	0f b6 00             	movzbl (%eax),%eax
  800a69:	0f b6 12             	movzbl (%edx),%edx
  800a6c:	29 d0                	sub    %edx,%eax
  800a6e:	eb 05                	jmp    800a75 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a75:	5b                   	pop    %ebx
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a82:	eb 07                	jmp    800a8b <strchr+0x13>
		if (*s == c)
  800a84:	38 ca                	cmp    %cl,%dl
  800a86:	74 0f                	je     800a97 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a88:	83 c0 01             	add    $0x1,%eax
  800a8b:	0f b6 10             	movzbl (%eax),%edx
  800a8e:	84 d2                	test   %dl,%dl
  800a90:	75 f2                	jne    800a84 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa3:	eb 03                	jmp    800aa8 <strfind+0xf>
  800aa5:	83 c0 01             	add    $0x1,%eax
  800aa8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aab:	38 ca                	cmp    %cl,%dl
  800aad:	74 04                	je     800ab3 <strfind+0x1a>
  800aaf:	84 d2                	test   %dl,%dl
  800ab1:	75 f2                	jne    800aa5 <strfind+0xc>
			break;
	return (char *) s;
}
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
  800abb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac1:	85 c9                	test   %ecx,%ecx
  800ac3:	74 36                	je     800afb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acb:	75 28                	jne    800af5 <memset+0x40>
  800acd:	f6 c1 03             	test   $0x3,%cl
  800ad0:	75 23                	jne    800af5 <memset+0x40>
		c &= 0xFF;
  800ad2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad6:	89 d3                	mov    %edx,%ebx
  800ad8:	c1 e3 08             	shl    $0x8,%ebx
  800adb:	89 d6                	mov    %edx,%esi
  800add:	c1 e6 18             	shl    $0x18,%esi
  800ae0:	89 d0                	mov    %edx,%eax
  800ae2:	c1 e0 10             	shl    $0x10,%eax
  800ae5:	09 f0                	or     %esi,%eax
  800ae7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ae9:	89 d8                	mov    %ebx,%eax
  800aeb:	09 d0                	or     %edx,%eax
  800aed:	c1 e9 02             	shr    $0x2,%ecx
  800af0:	fc                   	cld    
  800af1:	f3 ab                	rep stos %eax,%es:(%edi)
  800af3:	eb 06                	jmp    800afb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af8:	fc                   	cld    
  800af9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afb:	89 f8                	mov    %edi,%eax
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b10:	39 c6                	cmp    %eax,%esi
  800b12:	73 35                	jae    800b49 <memmove+0x47>
  800b14:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b17:	39 d0                	cmp    %edx,%eax
  800b19:	73 2e                	jae    800b49 <memmove+0x47>
		s += n;
		d += n;
  800b1b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1e:	89 d6                	mov    %edx,%esi
  800b20:	09 fe                	or     %edi,%esi
  800b22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b28:	75 13                	jne    800b3d <memmove+0x3b>
  800b2a:	f6 c1 03             	test   $0x3,%cl
  800b2d:	75 0e                	jne    800b3d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b2f:	83 ef 04             	sub    $0x4,%edi
  800b32:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b35:	c1 e9 02             	shr    $0x2,%ecx
  800b38:	fd                   	std    
  800b39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3b:	eb 09                	jmp    800b46 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3d:	83 ef 01             	sub    $0x1,%edi
  800b40:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b43:	fd                   	std    
  800b44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b46:	fc                   	cld    
  800b47:	eb 1d                	jmp    800b66 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b49:	89 f2                	mov    %esi,%edx
  800b4b:	09 c2                	or     %eax,%edx
  800b4d:	f6 c2 03             	test   $0x3,%dl
  800b50:	75 0f                	jne    800b61 <memmove+0x5f>
  800b52:	f6 c1 03             	test   $0x3,%cl
  800b55:	75 0a                	jne    800b61 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b57:	c1 e9 02             	shr    $0x2,%ecx
  800b5a:	89 c7                	mov    %eax,%edi
  800b5c:	fc                   	cld    
  800b5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5f:	eb 05                	jmp    800b66 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b61:	89 c7                	mov    %eax,%edi
  800b63:	fc                   	cld    
  800b64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b6d:	ff 75 10             	pushl  0x10(%ebp)
  800b70:	ff 75 0c             	pushl  0xc(%ebp)
  800b73:	ff 75 08             	pushl  0x8(%ebp)
  800b76:	e8 87 ff ff ff       	call   800b02 <memmove>
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 45 08             	mov    0x8(%ebp),%eax
  800b85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b88:	89 c6                	mov    %eax,%esi
  800b8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8d:	eb 1a                	jmp    800ba9 <memcmp+0x2c>
		if (*s1 != *s2)
  800b8f:	0f b6 08             	movzbl (%eax),%ecx
  800b92:	0f b6 1a             	movzbl (%edx),%ebx
  800b95:	38 d9                	cmp    %bl,%cl
  800b97:	74 0a                	je     800ba3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b99:	0f b6 c1             	movzbl %cl,%eax
  800b9c:	0f b6 db             	movzbl %bl,%ebx
  800b9f:	29 d8                	sub    %ebx,%eax
  800ba1:	eb 0f                	jmp    800bb2 <memcmp+0x35>
		s1++, s2++;
  800ba3:	83 c0 01             	add    $0x1,%eax
  800ba6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba9:	39 f0                	cmp    %esi,%eax
  800bab:	75 e2                	jne    800b8f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	53                   	push   %ebx
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bbd:	89 c1                	mov    %eax,%ecx
  800bbf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc6:	eb 0a                	jmp    800bd2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc8:	0f b6 10             	movzbl (%eax),%edx
  800bcb:	39 da                	cmp    %ebx,%edx
  800bcd:	74 07                	je     800bd6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bcf:	83 c0 01             	add    $0x1,%eax
  800bd2:	39 c8                	cmp    %ecx,%eax
  800bd4:	72 f2                	jb     800bc8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be5:	eb 03                	jmp    800bea <strtol+0x11>
		s++;
  800be7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bea:	0f b6 01             	movzbl (%ecx),%eax
  800bed:	3c 20                	cmp    $0x20,%al
  800bef:	74 f6                	je     800be7 <strtol+0xe>
  800bf1:	3c 09                	cmp    $0x9,%al
  800bf3:	74 f2                	je     800be7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf5:	3c 2b                	cmp    $0x2b,%al
  800bf7:	75 0a                	jne    800c03 <strtol+0x2a>
		s++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bfc:	bf 00 00 00 00       	mov    $0x0,%edi
  800c01:	eb 11                	jmp    800c14 <strtol+0x3b>
  800c03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c08:	3c 2d                	cmp    $0x2d,%al
  800c0a:	75 08                	jne    800c14 <strtol+0x3b>
		s++, neg = 1;
  800c0c:	83 c1 01             	add    $0x1,%ecx
  800c0f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1a:	75 15                	jne    800c31 <strtol+0x58>
  800c1c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c1f:	75 10                	jne    800c31 <strtol+0x58>
  800c21:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c25:	75 7c                	jne    800ca3 <strtol+0xca>
		s += 2, base = 16;
  800c27:	83 c1 02             	add    $0x2,%ecx
  800c2a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c2f:	eb 16                	jmp    800c47 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c31:	85 db                	test   %ebx,%ebx
  800c33:	75 12                	jne    800c47 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c35:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3d:	75 08                	jne    800c47 <strtol+0x6e>
		s++, base = 8;
  800c3f:	83 c1 01             	add    $0x1,%ecx
  800c42:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c47:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c4f:	0f b6 11             	movzbl (%ecx),%edx
  800c52:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c55:	89 f3                	mov    %esi,%ebx
  800c57:	80 fb 09             	cmp    $0x9,%bl
  800c5a:	77 08                	ja     800c64 <strtol+0x8b>
			dig = *s - '0';
  800c5c:	0f be d2             	movsbl %dl,%edx
  800c5f:	83 ea 30             	sub    $0x30,%edx
  800c62:	eb 22                	jmp    800c86 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c64:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c67:	89 f3                	mov    %esi,%ebx
  800c69:	80 fb 19             	cmp    $0x19,%bl
  800c6c:	77 08                	ja     800c76 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c6e:	0f be d2             	movsbl %dl,%edx
  800c71:	83 ea 57             	sub    $0x57,%edx
  800c74:	eb 10                	jmp    800c86 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c76:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c79:	89 f3                	mov    %esi,%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 16                	ja     800c96 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c80:	0f be d2             	movsbl %dl,%edx
  800c83:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c86:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c89:	7d 0b                	jge    800c96 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c8b:	83 c1 01             	add    $0x1,%ecx
  800c8e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c92:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c94:	eb b9                	jmp    800c4f <strtol+0x76>

	if (endptr)
  800c96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9a:	74 0d                	je     800ca9 <strtol+0xd0>
		*endptr = (char *) s;
  800c9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9f:	89 0e                	mov    %ecx,(%esi)
  800ca1:	eb 06                	jmp    800ca9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca3:	85 db                	test   %ebx,%ebx
  800ca5:	74 98                	je     800c3f <strtol+0x66>
  800ca7:	eb 9e                	jmp    800c47 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ca9:	89 c2                	mov    %eax,%edx
  800cab:	f7 da                	neg    %edx
  800cad:	85 ff                	test   %edi,%edi
  800caf:	0f 45 c2             	cmovne %edx,%eax
}
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	89 c3                	mov    %eax,%ebx
  800cca:	89 c7                	mov    %eax,%edi
  800ccc:	89 c6                	mov    %eax,%esi
  800cce:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce5:	89 d1                	mov    %edx,%ecx
  800ce7:	89 d3                	mov    %edx,%ebx
  800ce9:	89 d7                	mov    %edx,%edi
  800ceb:	89 d6                	mov    %edx,%esi
  800ced:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d02:	b8 03 00 00 00       	mov    $0x3,%eax
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	89 cb                	mov    %ecx,%ebx
  800d0c:	89 cf                	mov    %ecx,%edi
  800d0e:	89 ce                	mov    %ecx,%esi
  800d10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d12:	85 c0                	test   %eax,%eax
  800d14:	7e 17                	jle    800d2d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d16:	83 ec 0c             	sub    $0xc,%esp
  800d19:	50                   	push   %eax
  800d1a:	6a 03                	push   $0x3
  800d1c:	68 9f 28 80 00       	push   $0x80289f
  800d21:	6a 23                	push   $0x23
  800d23:	68 bc 28 80 00       	push   $0x8028bc
  800d28:	e8 e5 f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d40:	b8 02 00 00 00       	mov    $0x2,%eax
  800d45:	89 d1                	mov    %edx,%ecx
  800d47:	89 d3                	mov    %edx,%ebx
  800d49:	89 d7                	mov    %edx,%edi
  800d4b:	89 d6                	mov    %edx,%esi
  800d4d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_yield>:

void
sys_yield(void)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d64:	89 d1                	mov    %edx,%ecx
  800d66:	89 d3                	mov    %edx,%ebx
  800d68:	89 d7                	mov    %edx,%edi
  800d6a:	89 d6                	mov    %edx,%esi
  800d6c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	be 00 00 00 00       	mov    $0x0,%esi
  800d81:	b8 04 00 00 00       	mov    $0x4,%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8f:	89 f7                	mov    %esi,%edi
  800d91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d93:	85 c0                	test   %eax,%eax
  800d95:	7e 17                	jle    800dae <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	50                   	push   %eax
  800d9b:	6a 04                	push   $0x4
  800d9d:	68 9f 28 80 00       	push   $0x80289f
  800da2:	6a 23                	push   $0x23
  800da4:	68 bc 28 80 00       	push   $0x8028bc
  800da9:	e8 64 f5 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd0:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 17                	jle    800df0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	50                   	push   %eax
  800ddd:	6a 05                	push   $0x5
  800ddf:	68 9f 28 80 00       	push   $0x80289f
  800de4:	6a 23                	push   $0x23
  800de6:	68 bc 28 80 00       	push   $0x8028bc
  800deb:	e8 22 f5 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e06:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 df                	mov    %ebx,%edi
  800e13:	89 de                	mov    %ebx,%esi
  800e15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 17                	jle    800e32 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	50                   	push   %eax
  800e1f:	6a 06                	push   $0x6
  800e21:	68 9f 28 80 00       	push   $0x80289f
  800e26:	6a 23                	push   $0x23
  800e28:	68 bc 28 80 00       	push   $0x8028bc
  800e2d:	e8 e0 f4 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	b8 08 00 00 00       	mov    $0x8,%eax
  800e4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	89 df                	mov    %ebx,%edi
  800e55:	89 de                	mov    %ebx,%esi
  800e57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	7e 17                	jle    800e74 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5d:	83 ec 0c             	sub    $0xc,%esp
  800e60:	50                   	push   %eax
  800e61:	6a 08                	push   $0x8
  800e63:	68 9f 28 80 00       	push   $0x80289f
  800e68:	6a 23                	push   $0x23
  800e6a:	68 bc 28 80 00       	push   $0x8028bc
  800e6f:	e8 9e f4 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	57                   	push   %edi
  800e80:	56                   	push   %esi
  800e81:	53                   	push   %ebx
  800e82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	89 df                	mov    %ebx,%edi
  800e97:	89 de                	mov    %ebx,%esi
  800e99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	7e 17                	jle    800eb6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9f:	83 ec 0c             	sub    $0xc,%esp
  800ea2:	50                   	push   %eax
  800ea3:	6a 09                	push   $0x9
  800ea5:	68 9f 28 80 00       	push   $0x80289f
  800eaa:	6a 23                	push   $0x23
  800eac:	68 bc 28 80 00       	push   $0x8028bc
  800eb1:	e8 5c f4 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed7:	89 df                	mov    %ebx,%edi
  800ed9:	89 de                	mov    %ebx,%esi
  800edb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800edd:	85 c0                	test   %eax,%eax
  800edf:	7e 17                	jle    800ef8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee1:	83 ec 0c             	sub    $0xc,%esp
  800ee4:	50                   	push   %eax
  800ee5:	6a 0a                	push   $0xa
  800ee7:	68 9f 28 80 00       	push   $0x80289f
  800eec:	6a 23                	push   $0x23
  800eee:	68 bc 28 80 00       	push   $0x8028bc
  800ef3:	e8 1a f4 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f06:	be 00 00 00 00       	mov    $0x0,%esi
  800f0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f13:	8b 55 08             	mov    0x8(%ebp),%edx
  800f16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f19:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f36:	8b 55 08             	mov    0x8(%ebp),%edx
  800f39:	89 cb                	mov    %ecx,%ebx
  800f3b:	89 cf                	mov    %ecx,%edi
  800f3d:	89 ce                	mov    %ecx,%esi
  800f3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7e 17                	jle    800f5c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f45:	83 ec 0c             	sub    $0xc,%esp
  800f48:	50                   	push   %eax
  800f49:	6a 0d                	push   $0xd
  800f4b:	68 9f 28 80 00       	push   $0x80289f
  800f50:	6a 23                	push   $0x23
  800f52:	68 bc 28 80 00       	push   $0x8028bc
  800f57:	e8 b6 f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	53                   	push   %ebx
  800f68:	83 ec 04             	sub    $0x4,%esp
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  800f6e:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  800f70:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  800f73:	89 da                	mov    %ebx,%edx
  800f75:	c1 ea 0c             	shr    $0xc,%edx
  800f78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  800f7f:	a8 02                	test   $0x2,%al
  800f81:	75 12                	jne    800f95 <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  800f83:	50                   	push   %eax
  800f84:	68 cc 28 80 00       	push   $0x8028cc
  800f89:	6a 21                	push   $0x21
  800f8b:	68 ed 28 80 00       	push   $0x8028ed
  800f90:	e8 7d f3 ff ff       	call   800312 <_panic>
	   } else if (!(pte & PTE_COW)) {
  800f95:	f6 c6 08             	test   $0x8,%dh
  800f98:	75 14                	jne    800fae <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	68 f8 28 80 00       	push   $0x8028f8
  800fa2:	6a 23                	push   $0x23
  800fa4:	68 ed 28 80 00       	push   $0x8028ed
  800fa9:	e8 64 f3 ff ff       	call   800312 <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	6a 07                	push   $0x7
  800fb3:	68 00 00 40 00       	push   $0x400000
  800fb8:	6a 00                	push   $0x0
  800fba:	e8 b4 fd ff ff       	call   800d73 <sys_page_alloc>
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	79 12                	jns    800fd8 <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  800fc6:	50                   	push   %eax
  800fc7:	68 15 29 80 00       	push   $0x802915
  800fcc:	6a 2e                	push   $0x2e
  800fce:	68 ed 28 80 00       	push   $0x8028ed
  800fd3:	e8 3a f3 ff ff       	call   800312 <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800fd8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800fde:	83 ec 04             	sub    $0x4,%esp
  800fe1:	68 00 10 00 00       	push   $0x1000
  800fe6:	53                   	push   %ebx
  800fe7:	68 00 00 40 00       	push   $0x400000
  800fec:	e8 11 fb ff ff       	call   800b02 <memmove>
	   if ((r = sys_page_map(0,
  800ff1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ff8:	53                   	push   %ebx
  800ff9:	6a 00                	push   $0x0
  800ffb:	68 00 00 40 00       	push   $0x400000
  801000:	6a 00                	push   $0x0
  801002:	e8 af fd ff ff       	call   800db6 <sys_page_map>
  801007:	83 c4 20             	add    $0x20,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	79 12                	jns    801020 <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  80100e:	50                   	push   %eax
  80100f:	68 28 29 80 00       	push   $0x802928
  801014:	6a 36                	push   $0x36
  801016:	68 ed 28 80 00       	push   $0x8028ed
  80101b:	e8 f2 f2 ff ff       	call   800312 <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  801020:	83 ec 08             	sub    $0x8,%esp
  801023:	68 00 00 40 00       	push   $0x400000
  801028:	6a 00                	push   $0x0
  80102a:	e8 c9 fd ff ff       	call   800df8 <sys_page_unmap>
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	79 12                	jns    801048 <pgfault+0xe4>
			 panic("unmap %e", r);
  801036:	50                   	push   %eax
  801037:	68 38 29 80 00       	push   $0x802938
  80103c:	6a 39                	push   $0x39
  80103e:	68 ed 28 80 00       	push   $0x8028ed
  801043:	e8 ca f2 ff ff       	call   800312 <_panic>
	   }
}
  801048:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    

0080104d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	57                   	push   %edi
  801051:	56                   	push   %esi
  801052:	53                   	push   %ebx
  801053:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  801056:	68 64 0f 80 00       	push   $0x800f64
  80105b:	e8 6e 0f 00 00       	call   801fce <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801060:	b8 07 00 00 00       	mov    $0x7,%eax
  801065:	cd 30                	int    $0x30
  801067:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80106a:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	79 15                	jns    801089 <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  801074:	50                   	push   %eax
  801075:	68 41 29 80 00       	push   $0x802941
  80107a:	68 81 00 00 00       	push   $0x81
  80107f:	68 ed 28 80 00       	push   $0x8028ed
  801084:	e8 89 f2 ff ff       	call   800312 <_panic>
  801089:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801090:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  801094:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801098:	75 1c                	jne    8010b6 <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  80109a:	e8 96 fc ff ff       	call   800d35 <sys_getenvid>
  80109f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010a4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010a7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010ac:	a3 04 40 80 00       	mov    %eax,0x804004
			 return envid;
  8010b1:	e9 71 01 00 00       	jmp    801227 <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  8010b6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010b9:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  8010c0:	a8 01                	test   $0x1,%al
  8010c2:	0f 84 18 01 00 00    	je     8011e0 <fork+0x193>
  8010c8:	89 fb                	mov    %edi,%ebx
  8010ca:	c1 e3 0a             	shl    $0xa,%ebx
  8010cd:	c1 e7 16             	shl    $0x16,%edi
  8010d0:	be 00 00 00 00       	mov    $0x0,%esi
  8010d5:	e9 f4 00 00 00       	jmp    8011ce <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  8010da:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8010e0:	0f 84 dc 00 00 00    	je     8011c2 <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  8010e6:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8010ec:	0f 87 cc 00 00 00    	ja     8011be <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  8010f2:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010f9:	a8 01                	test   $0x1,%al
  8010fb:	0f 84 c1 00 00 00    	je     8011c2 <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  801101:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  801108:	a9 02 08 00 00       	test   $0x802,%eax
  80110d:	74 05                	je     801114 <fork+0xc7>
  80110f:	f6 c4 04             	test   $0x4,%ah
  801112:	74 3a                	je     80114e <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  801114:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80111a:	8b 52 48             	mov    0x48(%edx),%edx
  80111d:	83 ec 0c             	sub    $0xc,%esp
  801120:	25 07 0e 00 00       	and    $0xe07,%eax
  801125:	50                   	push   %eax
  801126:	57                   	push   %edi
  801127:	ff 75 dc             	pushl  -0x24(%ebp)
  80112a:	57                   	push   %edi
  80112b:	52                   	push   %edx
  80112c:	e8 85 fc ff ff       	call   800db6 <sys_page_map>
  801131:	83 c4 20             	add    $0x20,%esp
  801134:	85 c0                	test   %eax,%eax
  801136:	0f 89 86 00 00 00    	jns    8011c2 <fork+0x175>
				    panic("sys_page_map: %e", r);
  80113c:	50                   	push   %eax
  80113d:	68 51 29 80 00       	push   $0x802951
  801142:	6a 52                	push   $0x52
  801144:	68 ed 28 80 00       	push   $0x8028ed
  801149:	e8 c4 f1 ff ff       	call   800312 <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  80114e:	25 05 06 00 00       	and    $0x605,%eax
  801153:	80 cc 08             	or     $0x8,%ah
  801156:	89 c1                	mov    %eax,%ecx
  801158:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80115b:	a1 04 40 80 00       	mov    0x804004,%eax
  801160:	8b 40 48             	mov    0x48(%eax),%eax
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	51                   	push   %ecx
  801167:	57                   	push   %edi
  801168:	ff 75 dc             	pushl  -0x24(%ebp)
  80116b:	57                   	push   %edi
  80116c:	50                   	push   %eax
  80116d:	e8 44 fc ff ff       	call   800db6 <sys_page_map>
  801172:	83 c4 20             	add    $0x20,%esp
  801175:	85 c0                	test   %eax,%eax
  801177:	79 12                	jns    80118b <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  801179:	50                   	push   %eax
  80117a:	68 51 29 80 00       	push   $0x802951
  80117f:	6a 5d                	push   $0x5d
  801181:	68 ed 28 80 00       	push   $0x8028ed
  801186:	e8 87 f1 ff ff       	call   800312 <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  80118b:	a1 04 40 80 00       	mov    0x804004,%eax
  801190:	8b 50 48             	mov    0x48(%eax),%edx
  801193:	8b 40 48             	mov    0x48(%eax),%eax
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	ff 75 d4             	pushl  -0x2c(%ebp)
  80119c:	57                   	push   %edi
  80119d:	52                   	push   %edx
  80119e:	57                   	push   %edi
  80119f:	50                   	push   %eax
  8011a0:	e8 11 fc ff ff       	call   800db6 <sys_page_map>
  8011a5:	83 c4 20             	add    $0x20,%esp
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	79 16                	jns    8011c2 <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  8011ac:	50                   	push   %eax
  8011ad:	68 51 29 80 00       	push   $0x802951
  8011b2:	6a 63                	push   $0x63
  8011b4:	68 ed 28 80 00       	push   $0x8028ed
  8011b9:	e8 54 f1 ff ff       	call   800312 <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  8011be:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  8011c2:	83 c6 01             	add    $0x1,%esi
  8011c5:	83 c3 01             	add    $0x1,%ebx
  8011c8:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8011ce:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  8011d4:	7f 0a                	jg     8011e0 <fork+0x193>
  8011d6:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8011da:	0f 85 fa fe ff ff    	jne    8010da <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  8011e0:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  8011e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011e7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8011ec:	7f 0a                	jg     8011f8 <fork+0x1ab>
  8011ee:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8011f2:	0f 85 be fe ff ff    	jne    8010b6 <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	68 27 20 80 00       	push   $0x802027
  801200:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801203:	56                   	push   %esi
  801204:	e8 b5 fc ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  801209:	83 c4 0c             	add    $0xc,%esp
  80120c:	6a 06                	push   $0x6
  80120e:	68 00 f0 bf ee       	push   $0xeebff000
  801213:	56                   	push   %esi
  801214:	e8 5a fb ff ff       	call   800d73 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  801219:	83 c4 08             	add    $0x8,%esp
  80121c:	6a 02                	push   $0x2
  80121e:	56                   	push   %esi
  80121f:	e8 16 fc ff ff       	call   800e3a <sys_env_set_status>

	   return envid;
  801224:	83 c4 10             	add    $0x10,%esp
}
  801227:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80122a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5f                   	pop    %edi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <sfork>:
// Challenge!
	   int
sfork(void)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  801238:	68 62 29 80 00       	push   $0x802962
  80123d:	68 a7 00 00 00       	push   $0xa7
  801242:	68 ed 28 80 00       	push   $0x8028ed
  801247:	e8 c6 f0 ff ff       	call   800312 <_panic>

0080124c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80124f:	8b 45 08             	mov    0x8(%ebp),%eax
  801252:	05 00 00 00 30       	add    $0x30000000,%eax
  801257:	c1 e8 0c             	shr    $0xc,%eax
}
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80125f:	8b 45 08             	mov    0x8(%ebp),%eax
  801262:	05 00 00 00 30       	add    $0x30000000,%eax
  801267:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80126c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801279:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80127e:	89 c2                	mov    %eax,%edx
  801280:	c1 ea 16             	shr    $0x16,%edx
  801283:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80128a:	f6 c2 01             	test   $0x1,%dl
  80128d:	74 11                	je     8012a0 <fd_alloc+0x2d>
  80128f:	89 c2                	mov    %eax,%edx
  801291:	c1 ea 0c             	shr    $0xc,%edx
  801294:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80129b:	f6 c2 01             	test   $0x1,%dl
  80129e:	75 09                	jne    8012a9 <fd_alloc+0x36>
			*fd_store = fd;
  8012a0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a7:	eb 17                	jmp    8012c0 <fd_alloc+0x4d>
  8012a9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ae:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012b3:	75 c9                	jne    80127e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012b5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012bb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    

008012c2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012c8:	83 f8 1f             	cmp    $0x1f,%eax
  8012cb:	77 36                	ja     801303 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012cd:	c1 e0 0c             	shl    $0xc,%eax
  8012d0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	c1 ea 16             	shr    $0x16,%edx
  8012da:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e1:	f6 c2 01             	test   $0x1,%dl
  8012e4:	74 24                	je     80130a <fd_lookup+0x48>
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	c1 ea 0c             	shr    $0xc,%edx
  8012eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f2:	f6 c2 01             	test   $0x1,%dl
  8012f5:	74 1a                	je     801311 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fa:	89 02                	mov    %eax,(%edx)
	return 0;
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801301:	eb 13                	jmp    801316 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801303:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801308:	eb 0c                	jmp    801316 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80130a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130f:	eb 05                	jmp    801316 <fd_lookup+0x54>
  801311:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801321:	ba f8 29 80 00       	mov    $0x8029f8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801326:	eb 13                	jmp    80133b <dev_lookup+0x23>
  801328:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80132b:	39 08                	cmp    %ecx,(%eax)
  80132d:	75 0c                	jne    80133b <dev_lookup+0x23>
			*dev = devtab[i];
  80132f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801332:	89 01                	mov    %eax,(%ecx)
			return 0;
  801334:	b8 00 00 00 00       	mov    $0x0,%eax
  801339:	eb 2e                	jmp    801369 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80133b:	8b 02                	mov    (%edx),%eax
  80133d:	85 c0                	test   %eax,%eax
  80133f:	75 e7                	jne    801328 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801341:	a1 04 40 80 00       	mov    0x804004,%eax
  801346:	8b 40 48             	mov    0x48(%eax),%eax
  801349:	83 ec 04             	sub    $0x4,%esp
  80134c:	51                   	push   %ecx
  80134d:	50                   	push   %eax
  80134e:	68 78 29 80 00       	push   $0x802978
  801353:	e8 93 f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  801358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	56                   	push   %esi
  80136f:	53                   	push   %ebx
  801370:	83 ec 10             	sub    $0x10,%esp
  801373:	8b 75 08             	mov    0x8(%ebp),%esi
  801376:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801379:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137c:	50                   	push   %eax
  80137d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801383:	c1 e8 0c             	shr    $0xc,%eax
  801386:	50                   	push   %eax
  801387:	e8 36 ff ff ff       	call   8012c2 <fd_lookup>
  80138c:	83 c4 08             	add    $0x8,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 05                	js     801398 <fd_close+0x2d>
	    || fd != fd2)
  801393:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801396:	74 0c                	je     8013a4 <fd_close+0x39>
		return (must_exist ? r : 0);
  801398:	84 db                	test   %bl,%bl
  80139a:	ba 00 00 00 00       	mov    $0x0,%edx
  80139f:	0f 44 c2             	cmove  %edx,%eax
  8013a2:	eb 41                	jmp    8013e5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013aa:	50                   	push   %eax
  8013ab:	ff 36                	pushl  (%esi)
  8013ad:	e8 66 ff ff ff       	call   801318 <dev_lookup>
  8013b2:	89 c3                	mov    %eax,%ebx
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 1a                	js     8013d5 <fd_close+0x6a>
		if (dev->dev_close)
  8013bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013be:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013c1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	74 0b                	je     8013d5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013ca:	83 ec 0c             	sub    $0xc,%esp
  8013cd:	56                   	push   %esi
  8013ce:	ff d0                	call   *%eax
  8013d0:	89 c3                	mov    %eax,%ebx
  8013d2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	56                   	push   %esi
  8013d9:	6a 00                	push   $0x0
  8013db:	e8 18 fa ff ff       	call   800df8 <sys_page_unmap>
	return r;
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	89 d8                	mov    %ebx,%eax
}
  8013e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5e                   	pop    %esi
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    

008013ec <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f5:	50                   	push   %eax
  8013f6:	ff 75 08             	pushl  0x8(%ebp)
  8013f9:	e8 c4 fe ff ff       	call   8012c2 <fd_lookup>
  8013fe:	83 c4 08             	add    $0x8,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	78 10                	js     801415 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	6a 01                	push   $0x1
  80140a:	ff 75 f4             	pushl  -0xc(%ebp)
  80140d:	e8 59 ff ff ff       	call   80136b <fd_close>
  801412:	83 c4 10             	add    $0x10,%esp
}
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <close_all>:

void
close_all(void)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	53                   	push   %ebx
  80141b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80141e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801423:	83 ec 0c             	sub    $0xc,%esp
  801426:	53                   	push   %ebx
  801427:	e8 c0 ff ff ff       	call   8013ec <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80142c:	83 c3 01             	add    $0x1,%ebx
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	83 fb 20             	cmp    $0x20,%ebx
  801435:	75 ec                	jne    801423 <close_all+0xc>
		close(i);
}
  801437:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	57                   	push   %edi
  801440:	56                   	push   %esi
  801441:	53                   	push   %ebx
  801442:	83 ec 2c             	sub    $0x2c,%esp
  801445:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801448:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80144b:	50                   	push   %eax
  80144c:	ff 75 08             	pushl  0x8(%ebp)
  80144f:	e8 6e fe ff ff       	call   8012c2 <fd_lookup>
  801454:	83 c4 08             	add    $0x8,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	0f 88 c1 00 00 00    	js     801520 <dup+0xe4>
		return r;
	close(newfdnum);
  80145f:	83 ec 0c             	sub    $0xc,%esp
  801462:	56                   	push   %esi
  801463:	e8 84 ff ff ff       	call   8013ec <close>

	newfd = INDEX2FD(newfdnum);
  801468:	89 f3                	mov    %esi,%ebx
  80146a:	c1 e3 0c             	shl    $0xc,%ebx
  80146d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801473:	83 c4 04             	add    $0x4,%esp
  801476:	ff 75 e4             	pushl  -0x1c(%ebp)
  801479:	e8 de fd ff ff       	call   80125c <fd2data>
  80147e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801480:	89 1c 24             	mov    %ebx,(%esp)
  801483:	e8 d4 fd ff ff       	call   80125c <fd2data>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80148e:	89 f8                	mov    %edi,%eax
  801490:	c1 e8 16             	shr    $0x16,%eax
  801493:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80149a:	a8 01                	test   $0x1,%al
  80149c:	74 37                	je     8014d5 <dup+0x99>
  80149e:	89 f8                	mov    %edi,%eax
  8014a0:	c1 e8 0c             	shr    $0xc,%eax
  8014a3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014aa:	f6 c2 01             	test   $0x1,%dl
  8014ad:	74 26                	je     8014d5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014af:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b6:	83 ec 0c             	sub    $0xc,%esp
  8014b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8014be:	50                   	push   %eax
  8014bf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c2:	6a 00                	push   $0x0
  8014c4:	57                   	push   %edi
  8014c5:	6a 00                	push   $0x0
  8014c7:	e8 ea f8 ff ff       	call   800db6 <sys_page_map>
  8014cc:	89 c7                	mov    %eax,%edi
  8014ce:	83 c4 20             	add    $0x20,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 2e                	js     801503 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014d8:	89 d0                	mov    %edx,%eax
  8014da:	c1 e8 0c             	shr    $0xc,%eax
  8014dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ec:	50                   	push   %eax
  8014ed:	53                   	push   %ebx
  8014ee:	6a 00                	push   $0x0
  8014f0:	52                   	push   %edx
  8014f1:	6a 00                	push   $0x0
  8014f3:	e8 be f8 ff ff       	call   800db6 <sys_page_map>
  8014f8:	89 c7                	mov    %eax,%edi
  8014fa:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014fd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ff:	85 ff                	test   %edi,%edi
  801501:	79 1d                	jns    801520 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	53                   	push   %ebx
  801507:	6a 00                	push   $0x0
  801509:	e8 ea f8 ff ff       	call   800df8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80150e:	83 c4 08             	add    $0x8,%esp
  801511:	ff 75 d4             	pushl  -0x2c(%ebp)
  801514:	6a 00                	push   $0x0
  801516:	e8 dd f8 ff ff       	call   800df8 <sys_page_unmap>
	return r;
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	89 f8                	mov    %edi,%eax
}
  801520:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801523:	5b                   	pop    %ebx
  801524:	5e                   	pop    %esi
  801525:	5f                   	pop    %edi
  801526:	5d                   	pop    %ebp
  801527:	c3                   	ret    

00801528 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	53                   	push   %ebx
  80152c:	83 ec 14             	sub    $0x14,%esp
  80152f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801532:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	53                   	push   %ebx
  801537:	e8 86 fd ff ff       	call   8012c2 <fd_lookup>
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	89 c2                	mov    %eax,%edx
  801541:	85 c0                	test   %eax,%eax
  801543:	78 6d                	js     8015b2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801545:	83 ec 08             	sub    $0x8,%esp
  801548:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154f:	ff 30                	pushl  (%eax)
  801551:	e8 c2 fd ff ff       	call   801318 <dev_lookup>
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 4c                	js     8015a9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80155d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801560:	8b 42 08             	mov    0x8(%edx),%eax
  801563:	83 e0 03             	and    $0x3,%eax
  801566:	83 f8 01             	cmp    $0x1,%eax
  801569:	75 21                	jne    80158c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80156b:	a1 04 40 80 00       	mov    0x804004,%eax
  801570:	8b 40 48             	mov    0x48(%eax),%eax
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	53                   	push   %ebx
  801577:	50                   	push   %eax
  801578:	68 bc 29 80 00       	push   $0x8029bc
  80157d:	e8 69 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158a:	eb 26                	jmp    8015b2 <read+0x8a>
	}
	if (!dev->dev_read)
  80158c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158f:	8b 40 08             	mov    0x8(%eax),%eax
  801592:	85 c0                	test   %eax,%eax
  801594:	74 17                	je     8015ad <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801596:	83 ec 04             	sub    $0x4,%esp
  801599:	ff 75 10             	pushl  0x10(%ebp)
  80159c:	ff 75 0c             	pushl  0xc(%ebp)
  80159f:	52                   	push   %edx
  8015a0:	ff d0                	call   *%eax
  8015a2:	89 c2                	mov    %eax,%edx
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	eb 09                	jmp    8015b2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a9:	89 c2                	mov    %eax,%edx
  8015ab:	eb 05                	jmp    8015b2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015b2:	89 d0                	mov    %edx,%eax
  8015b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	57                   	push   %edi
  8015bd:	56                   	push   %esi
  8015be:	53                   	push   %ebx
  8015bf:	83 ec 0c             	sub    $0xc,%esp
  8015c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015c5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015cd:	eb 21                	jmp    8015f0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015cf:	83 ec 04             	sub    $0x4,%esp
  8015d2:	89 f0                	mov    %esi,%eax
  8015d4:	29 d8                	sub    %ebx,%eax
  8015d6:	50                   	push   %eax
  8015d7:	89 d8                	mov    %ebx,%eax
  8015d9:	03 45 0c             	add    0xc(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	57                   	push   %edi
  8015de:	e8 45 ff ff ff       	call   801528 <read>
		if (m < 0)
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 10                	js     8015fa <readn+0x41>
			return m;
		if (m == 0)
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	74 0a                	je     8015f8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ee:	01 c3                	add    %eax,%ebx
  8015f0:	39 f3                	cmp    %esi,%ebx
  8015f2:	72 db                	jb     8015cf <readn+0x16>
  8015f4:	89 d8                	mov    %ebx,%eax
  8015f6:	eb 02                	jmp    8015fa <readn+0x41>
  8015f8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015fd:	5b                   	pop    %ebx
  8015fe:	5e                   	pop    %esi
  8015ff:	5f                   	pop    %edi
  801600:	5d                   	pop    %ebp
  801601:	c3                   	ret    

00801602 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	53                   	push   %ebx
  801606:	83 ec 14             	sub    $0x14,%esp
  801609:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160f:	50                   	push   %eax
  801610:	53                   	push   %ebx
  801611:	e8 ac fc ff ff       	call   8012c2 <fd_lookup>
  801616:	83 c4 08             	add    $0x8,%esp
  801619:	89 c2                	mov    %eax,%edx
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 68                	js     801687 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801625:	50                   	push   %eax
  801626:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801629:	ff 30                	pushl  (%eax)
  80162b:	e8 e8 fc ff ff       	call   801318 <dev_lookup>
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 47                	js     80167e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801637:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80163e:	75 21                	jne    801661 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801640:	a1 04 40 80 00       	mov    0x804004,%eax
  801645:	8b 40 48             	mov    0x48(%eax),%eax
  801648:	83 ec 04             	sub    $0x4,%esp
  80164b:	53                   	push   %ebx
  80164c:	50                   	push   %eax
  80164d:	68 d8 29 80 00       	push   $0x8029d8
  801652:	e8 94 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80165f:	eb 26                	jmp    801687 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801661:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801664:	8b 52 0c             	mov    0xc(%edx),%edx
  801667:	85 d2                	test   %edx,%edx
  801669:	74 17                	je     801682 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80166b:	83 ec 04             	sub    $0x4,%esp
  80166e:	ff 75 10             	pushl  0x10(%ebp)
  801671:	ff 75 0c             	pushl  0xc(%ebp)
  801674:	50                   	push   %eax
  801675:	ff d2                	call   *%edx
  801677:	89 c2                	mov    %eax,%edx
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	eb 09                	jmp    801687 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167e:	89 c2                	mov    %eax,%edx
  801680:	eb 05                	jmp    801687 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801682:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801687:	89 d0                	mov    %edx,%eax
  801689:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <seek>:

int
seek(int fdnum, off_t offset)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801694:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801697:	50                   	push   %eax
  801698:	ff 75 08             	pushl  0x8(%ebp)
  80169b:	e8 22 fc ff ff       	call   8012c2 <fd_lookup>
  8016a0:	83 c4 08             	add    $0x8,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 0e                	js     8016b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 14             	sub    $0x14,%esp
  8016be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c4:	50                   	push   %eax
  8016c5:	53                   	push   %ebx
  8016c6:	e8 f7 fb ff ff       	call   8012c2 <fd_lookup>
  8016cb:	83 c4 08             	add    $0x8,%esp
  8016ce:	89 c2                	mov    %eax,%edx
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	78 65                	js     801739 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d4:	83 ec 08             	sub    $0x8,%esp
  8016d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016da:	50                   	push   %eax
  8016db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016de:	ff 30                	pushl  (%eax)
  8016e0:	e8 33 fc ff ff       	call   801318 <dev_lookup>
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	85 c0                	test   %eax,%eax
  8016ea:	78 44                	js     801730 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f3:	75 21                	jne    801716 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016f5:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016fa:	8b 40 48             	mov    0x48(%eax),%eax
  8016fd:	83 ec 04             	sub    $0x4,%esp
  801700:	53                   	push   %ebx
  801701:	50                   	push   %eax
  801702:	68 98 29 80 00       	push   $0x802998
  801707:	e8 df ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801714:	eb 23                	jmp    801739 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801716:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801719:	8b 52 18             	mov    0x18(%edx),%edx
  80171c:	85 d2                	test   %edx,%edx
  80171e:	74 14                	je     801734 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	ff 75 0c             	pushl  0xc(%ebp)
  801726:	50                   	push   %eax
  801727:	ff d2                	call   *%edx
  801729:	89 c2                	mov    %eax,%edx
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	eb 09                	jmp    801739 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801730:	89 c2                	mov    %eax,%edx
  801732:	eb 05                	jmp    801739 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801734:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801739:	89 d0                	mov    %edx,%eax
  80173b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173e:	c9                   	leave  
  80173f:	c3                   	ret    

00801740 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	53                   	push   %ebx
  801744:	83 ec 14             	sub    $0x14,%esp
  801747:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174d:	50                   	push   %eax
  80174e:	ff 75 08             	pushl  0x8(%ebp)
  801751:	e8 6c fb ff ff       	call   8012c2 <fd_lookup>
  801756:	83 c4 08             	add    $0x8,%esp
  801759:	89 c2                	mov    %eax,%edx
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 58                	js     8017b7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801765:	50                   	push   %eax
  801766:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801769:	ff 30                	pushl  (%eax)
  80176b:	e8 a8 fb ff ff       	call   801318 <dev_lookup>
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	78 37                	js     8017ae <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801777:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80177e:	74 32                	je     8017b2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801780:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801783:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80178a:	00 00 00 
	stat->st_isdir = 0;
  80178d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801794:	00 00 00 
	stat->st_dev = dev;
  801797:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80179d:	83 ec 08             	sub    $0x8,%esp
  8017a0:	53                   	push   %ebx
  8017a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8017a4:	ff 50 14             	call   *0x14(%eax)
  8017a7:	89 c2                	mov    %eax,%edx
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	eb 09                	jmp    8017b7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ae:	89 c2                	mov    %eax,%edx
  8017b0:	eb 05                	jmp    8017b7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017b7:	89 d0                	mov    %edx,%eax
  8017b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    

008017be <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	56                   	push   %esi
  8017c2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017c3:	83 ec 08             	sub    $0x8,%esp
  8017c6:	6a 00                	push   $0x0
  8017c8:	ff 75 08             	pushl  0x8(%ebp)
  8017cb:	e8 2c 02 00 00       	call   8019fc <open>
  8017d0:	89 c3                	mov    %eax,%ebx
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 1b                	js     8017f4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017d9:	83 ec 08             	sub    $0x8,%esp
  8017dc:	ff 75 0c             	pushl  0xc(%ebp)
  8017df:	50                   	push   %eax
  8017e0:	e8 5b ff ff ff       	call   801740 <fstat>
  8017e5:	89 c6                	mov    %eax,%esi
	close(fd);
  8017e7:	89 1c 24             	mov    %ebx,(%esp)
  8017ea:	e8 fd fb ff ff       	call   8013ec <close>
	return r;
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	89 f0                	mov    %esi,%eax
}
  8017f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f7:	5b                   	pop    %ebx
  8017f8:	5e                   	pop    %esi
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    

008017fb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	89 c6                	mov    %eax,%esi
  801802:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  801804:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80180b:	75 12                	jne    80181f <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  80180d:	83 ec 0c             	sub    $0xc,%esp
  801810:	6a 01                	push   $0x1
  801812:	e8 e9 08 00 00       	call   802100 <ipc_find_env>
  801817:	a3 00 40 80 00       	mov    %eax,0x804000
  80181c:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80181f:	6a 07                	push   $0x7
  801821:	68 00 50 80 00       	push   $0x805000
  801826:	56                   	push   %esi
  801827:	ff 35 00 40 80 00    	pushl  0x804000
  80182d:	e8 7a 08 00 00       	call   8020ac <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  801832:	83 c4 0c             	add    $0xc,%esp
  801835:	6a 00                	push   $0x0
  801837:	53                   	push   %ebx
  801838:	6a 00                	push   $0x0
  80183a:	e8 0e 08 00 00       	call   80204d <ipc_recv>
}
  80183f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80184c:	8b 45 08             	mov    0x8(%ebp),%eax
  80184f:	8b 40 0c             	mov    0xc(%eax),%eax
  801852:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  801857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185a:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  80185f:	ba 00 00 00 00       	mov    $0x0,%edx
  801864:	b8 02 00 00 00       	mov    $0x2,%eax
  801869:	e8 8d ff ff ff       	call   8017fb <fsipc>
}
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	8b 40 0c             	mov    0xc(%eax),%eax
  80187c:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  801881:	ba 00 00 00 00       	mov    $0x0,%edx
  801886:	b8 06 00 00 00       	mov    $0x6,%eax
  80188b:	e8 6b ff ff ff       	call   8017fb <fsipc>
}
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	53                   	push   %ebx
  801896:	83 ec 04             	sub    $0x4,%esp
  801899:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80189c:	8b 45 08             	mov    0x8(%ebp),%eax
  80189f:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a2:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b1:	e8 45 ff ff ff       	call   8017fb <fsipc>
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 2c                	js     8018e6 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ba:	83 ec 08             	sub    $0x8,%esp
  8018bd:	68 00 50 80 00       	push   $0x805000
  8018c2:	53                   	push   %ebx
  8018c3:	e8 a8 f0 ff ff       	call   800970 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8018c8:	a1 80 50 80 00       	mov    0x805080,%eax
  8018cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018d3:	a1 84 50 80 00       	mov    0x805084,%eax
  8018d8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8018de:	83 c4 10             	add    $0x10,%esp
  8018e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e9:	c9                   	leave  
  8018ea:	c3                   	ret    

008018eb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 08             	sub    $0x8,%esp
  8018f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018fb:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  801900:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  801906:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  80190c:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801911:	0f 46 c3             	cmovbe %ebx,%eax
  801914:	50                   	push   %eax
  801915:	ff 75 0c             	pushl  0xc(%ebp)
  801918:	68 08 50 80 00       	push   $0x805008
  80191d:	e8 e0 f1 ff ff       	call   800b02 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  801922:	ba 00 00 00 00       	mov    $0x0,%edx
  801927:	b8 04 00 00 00       	mov    $0x4,%eax
  80192c:	e8 ca fe ff ff       	call   8017fb <fsipc>
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	85 c0                	test   %eax,%eax
  801936:	78 3d                	js     801975 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  801938:	39 c3                	cmp    %eax,%ebx
  80193a:	73 19                	jae    801955 <devfile_write+0x6a>
  80193c:	68 08 2a 80 00       	push   $0x802a08
  801941:	68 0f 2a 80 00       	push   $0x802a0f
  801946:	68 9a 00 00 00       	push   $0x9a
  80194b:	68 24 2a 80 00       	push   $0x802a24
  801950:	e8 bd e9 ff ff       	call   800312 <_panic>
	   assert (r <= bytes_written);
  801955:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80195a:	7e 19                	jle    801975 <devfile_write+0x8a>
  80195c:	68 2f 2a 80 00       	push   $0x802a2f
  801961:	68 0f 2a 80 00       	push   $0x802a0f
  801966:	68 9b 00 00 00       	push   $0x9b
  80196b:	68 24 2a 80 00       	push   $0x802a24
  801970:	e8 9d e9 ff ff       	call   800312 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801975:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	56                   	push   %esi
  80197e:	53                   	push   %ebx
  80197f:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  801982:	8b 45 08             	mov    0x8(%ebp),%eax
  801985:	8b 40 0c             	mov    0xc(%eax),%eax
  801988:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  80198d:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801993:	ba 00 00 00 00       	mov    $0x0,%edx
  801998:	b8 03 00 00 00       	mov    $0x3,%eax
  80199d:	e8 59 fe ff ff       	call   8017fb <fsipc>
  8019a2:	89 c3                	mov    %eax,%ebx
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	78 4b                	js     8019f3 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  8019a8:	39 c6                	cmp    %eax,%esi
  8019aa:	73 16                	jae    8019c2 <devfile_read+0x48>
  8019ac:	68 08 2a 80 00       	push   $0x802a08
  8019b1:	68 0f 2a 80 00       	push   $0x802a0f
  8019b6:	6a 7c                	push   $0x7c
  8019b8:	68 24 2a 80 00       	push   $0x802a24
  8019bd:	e8 50 e9 ff ff       	call   800312 <_panic>
	   assert(r <= PGSIZE);
  8019c2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019c7:	7e 16                	jle    8019df <devfile_read+0x65>
  8019c9:	68 42 2a 80 00       	push   $0x802a42
  8019ce:	68 0f 2a 80 00       	push   $0x802a0f
  8019d3:	6a 7d                	push   $0x7d
  8019d5:	68 24 2a 80 00       	push   $0x802a24
  8019da:	e8 33 e9 ff ff       	call   800312 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019df:	83 ec 04             	sub    $0x4,%esp
  8019e2:	50                   	push   %eax
  8019e3:	68 00 50 80 00       	push   $0x805000
  8019e8:	ff 75 0c             	pushl  0xc(%ebp)
  8019eb:	e8 12 f1 ff ff       	call   800b02 <memmove>
	   return r;
  8019f0:	83 c4 10             	add    $0x10,%esp
}
  8019f3:	89 d8                	mov    %ebx,%eax
  8019f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f8:	5b                   	pop    %ebx
  8019f9:	5e                   	pop    %esi
  8019fa:	5d                   	pop    %ebp
  8019fb:	c3                   	ret    

008019fc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 20             	sub    $0x20,%esp
  801a03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  801a06:	53                   	push   %ebx
  801a07:	e8 2b ef ff ff       	call   800937 <strlen>
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a14:	7f 67                	jg     801a7d <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1c:	50                   	push   %eax
  801a1d:	e8 51 f8 ff ff       	call   801273 <fd_alloc>
  801a22:	83 c4 10             	add    $0x10,%esp
			 return r;
  801a25:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801a27:	85 c0                	test   %eax,%eax
  801a29:	78 57                	js     801a82 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  801a2b:	83 ec 08             	sub    $0x8,%esp
  801a2e:	53                   	push   %ebx
  801a2f:	68 00 50 80 00       	push   $0x805000
  801a34:	e8 37 ef ff ff       	call   800970 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  801a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3c:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a44:	b8 01 00 00 00       	mov    $0x1,%eax
  801a49:	e8 ad fd ff ff       	call   8017fb <fsipc>
  801a4e:	89 c3                	mov    %eax,%ebx
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	85 c0                	test   %eax,%eax
  801a55:	79 14                	jns    801a6b <open+0x6f>
			 fd_close(fd, 0);
  801a57:	83 ec 08             	sub    $0x8,%esp
  801a5a:	6a 00                	push   $0x0
  801a5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5f:	e8 07 f9 ff ff       	call   80136b <fd_close>
			 return r;
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	89 da                	mov    %ebx,%edx
  801a69:	eb 17                	jmp    801a82 <open+0x86>
	   }

	   return fd2num(fd);
  801a6b:	83 ec 0c             	sub    $0xc,%esp
  801a6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a71:	e8 d6 f7 ff ff       	call   80124c <fd2num>
  801a76:	89 c2                	mov    %eax,%edx
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	eb 05                	jmp    801a82 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  801a7d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801a82:	89 d0                	mov    %edx,%eax
  801a84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a87:	c9                   	leave  
  801a88:	c3                   	ret    

00801a89 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801a8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a94:	b8 08 00 00 00       	mov    $0x8,%eax
  801a99:	e8 5d fd ff ff       	call   8017fb <fsipc>
}
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	56                   	push   %esi
  801aa4:	53                   	push   %ebx
  801aa5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aa8:	83 ec 0c             	sub    $0xc,%esp
  801aab:	ff 75 08             	pushl  0x8(%ebp)
  801aae:	e8 a9 f7 ff ff       	call   80125c <fd2data>
  801ab3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ab5:	83 c4 08             	add    $0x8,%esp
  801ab8:	68 4e 2a 80 00       	push   $0x802a4e
  801abd:	53                   	push   %ebx
  801abe:	e8 ad ee ff ff       	call   800970 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ac3:	8b 46 04             	mov    0x4(%esi),%eax
  801ac6:	2b 06                	sub    (%esi),%eax
  801ac8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ace:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ad5:	00 00 00 
	stat->st_dev = &devpipe;
  801ad8:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801adf:	30 80 00 
	return 0;
}
  801ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	53                   	push   %ebx
  801af2:	83 ec 0c             	sub    $0xc,%esp
  801af5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801af8:	53                   	push   %ebx
  801af9:	6a 00                	push   $0x0
  801afb:	e8 f8 f2 ff ff       	call   800df8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b00:	89 1c 24             	mov    %ebx,(%esp)
  801b03:	e8 54 f7 ff ff       	call   80125c <fd2data>
  801b08:	83 c4 08             	add    $0x8,%esp
  801b0b:	50                   	push   %eax
  801b0c:	6a 00                	push   $0x0
  801b0e:	e8 e5 f2 ff ff       	call   800df8 <sys_page_unmap>
}
  801b13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b16:	c9                   	leave  
  801b17:	c3                   	ret    

00801b18 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	57                   	push   %edi
  801b1c:	56                   	push   %esi
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 1c             	sub    $0x1c,%esp
  801b21:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b24:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b26:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b2e:	83 ec 0c             	sub    $0xc,%esp
  801b31:	ff 75 e0             	pushl  -0x20(%ebp)
  801b34:	e8 00 06 00 00       	call   802139 <pageref>
  801b39:	89 c3                	mov    %eax,%ebx
  801b3b:	89 3c 24             	mov    %edi,(%esp)
  801b3e:	e8 f6 05 00 00       	call   802139 <pageref>
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	39 c3                	cmp    %eax,%ebx
  801b48:	0f 94 c1             	sete   %cl
  801b4b:	0f b6 c9             	movzbl %cl,%ecx
  801b4e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b51:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b57:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b5a:	39 ce                	cmp    %ecx,%esi
  801b5c:	74 1b                	je     801b79 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b5e:	39 c3                	cmp    %eax,%ebx
  801b60:	75 c4                	jne    801b26 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b62:	8b 42 58             	mov    0x58(%edx),%eax
  801b65:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b68:	50                   	push   %eax
  801b69:	56                   	push   %esi
  801b6a:	68 55 2a 80 00       	push   $0x802a55
  801b6f:	e8 77 e8 ff ff       	call   8003eb <cprintf>
  801b74:	83 c4 10             	add    $0x10,%esp
  801b77:	eb ad                	jmp    801b26 <_pipeisclosed+0xe>
	}
}
  801b79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5f                   	pop    %edi
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    

00801b84 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	57                   	push   %edi
  801b88:	56                   	push   %esi
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 28             	sub    $0x28,%esp
  801b8d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b90:	56                   	push   %esi
  801b91:	e8 c6 f6 ff ff       	call   80125c <fd2data>
  801b96:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	bf 00 00 00 00       	mov    $0x0,%edi
  801ba0:	eb 4b                	jmp    801bed <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ba2:	89 da                	mov    %ebx,%edx
  801ba4:	89 f0                	mov    %esi,%eax
  801ba6:	e8 6d ff ff ff       	call   801b18 <_pipeisclosed>
  801bab:	85 c0                	test   %eax,%eax
  801bad:	75 48                	jne    801bf7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801baf:	e8 a0 f1 ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bb4:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb7:	8b 0b                	mov    (%ebx),%ecx
  801bb9:	8d 51 20             	lea    0x20(%ecx),%edx
  801bbc:	39 d0                	cmp    %edx,%eax
  801bbe:	73 e2                	jae    801ba2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bc7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bca:	89 c2                	mov    %eax,%edx
  801bcc:	c1 fa 1f             	sar    $0x1f,%edx
  801bcf:	89 d1                	mov    %edx,%ecx
  801bd1:	c1 e9 1b             	shr    $0x1b,%ecx
  801bd4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bd7:	83 e2 1f             	and    $0x1f,%edx
  801bda:	29 ca                	sub    %ecx,%edx
  801bdc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801be0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801be4:	83 c0 01             	add    $0x1,%eax
  801be7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bea:	83 c7 01             	add    $0x1,%edi
  801bed:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bf0:	75 c2                	jne    801bb4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bf2:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf5:	eb 05                	jmp    801bfc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bf7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5f                   	pop    %edi
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    

00801c04 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	57                   	push   %edi
  801c08:	56                   	push   %esi
  801c09:	53                   	push   %ebx
  801c0a:	83 ec 18             	sub    $0x18,%esp
  801c0d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c10:	57                   	push   %edi
  801c11:	e8 46 f6 ff ff       	call   80125c <fd2data>
  801c16:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c20:	eb 3d                	jmp    801c5f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c22:	85 db                	test   %ebx,%ebx
  801c24:	74 04                	je     801c2a <devpipe_read+0x26>
				return i;
  801c26:	89 d8                	mov    %ebx,%eax
  801c28:	eb 44                	jmp    801c6e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c2a:	89 f2                	mov    %esi,%edx
  801c2c:	89 f8                	mov    %edi,%eax
  801c2e:	e8 e5 fe ff ff       	call   801b18 <_pipeisclosed>
  801c33:	85 c0                	test   %eax,%eax
  801c35:	75 32                	jne    801c69 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c37:	e8 18 f1 ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c3c:	8b 06                	mov    (%esi),%eax
  801c3e:	3b 46 04             	cmp    0x4(%esi),%eax
  801c41:	74 df                	je     801c22 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c43:	99                   	cltd   
  801c44:	c1 ea 1b             	shr    $0x1b,%edx
  801c47:	01 d0                	add    %edx,%eax
  801c49:	83 e0 1f             	and    $0x1f,%eax
  801c4c:	29 d0                	sub    %edx,%eax
  801c4e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c56:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c59:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c5c:	83 c3 01             	add    $0x1,%ebx
  801c5f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c62:	75 d8                	jne    801c3c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c64:	8b 45 10             	mov    0x10(%ebp),%eax
  801c67:	eb 05                	jmp    801c6e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c69:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c71:	5b                   	pop    %ebx
  801c72:	5e                   	pop    %esi
  801c73:	5f                   	pop    %edi
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    

00801c76 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	56                   	push   %esi
  801c7a:	53                   	push   %ebx
  801c7b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c81:	50                   	push   %eax
  801c82:	e8 ec f5 ff ff       	call   801273 <fd_alloc>
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	89 c2                	mov    %eax,%edx
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	0f 88 2c 01 00 00    	js     801dc0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c94:	83 ec 04             	sub    $0x4,%esp
  801c97:	68 07 04 00 00       	push   $0x407
  801c9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9f:	6a 00                	push   $0x0
  801ca1:	e8 cd f0 ff ff       	call   800d73 <sys_page_alloc>
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	89 c2                	mov    %eax,%edx
  801cab:	85 c0                	test   %eax,%eax
  801cad:	0f 88 0d 01 00 00    	js     801dc0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cb3:	83 ec 0c             	sub    $0xc,%esp
  801cb6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb9:	50                   	push   %eax
  801cba:	e8 b4 f5 ff ff       	call   801273 <fd_alloc>
  801cbf:	89 c3                	mov    %eax,%ebx
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	0f 88 e2 00 00 00    	js     801dae <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccc:	83 ec 04             	sub    $0x4,%esp
  801ccf:	68 07 04 00 00       	push   $0x407
  801cd4:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd7:	6a 00                	push   $0x0
  801cd9:	e8 95 f0 ff ff       	call   800d73 <sys_page_alloc>
  801cde:	89 c3                	mov    %eax,%ebx
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	0f 88 c3 00 00 00    	js     801dae <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf1:	e8 66 f5 ff ff       	call   80125c <fd2data>
  801cf6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf8:	83 c4 0c             	add    $0xc,%esp
  801cfb:	68 07 04 00 00       	push   $0x407
  801d00:	50                   	push   %eax
  801d01:	6a 00                	push   $0x0
  801d03:	e8 6b f0 ff ff       	call   800d73 <sys_page_alloc>
  801d08:	89 c3                	mov    %eax,%ebx
  801d0a:	83 c4 10             	add    $0x10,%esp
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	0f 88 89 00 00 00    	js     801d9e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d15:	83 ec 0c             	sub    $0xc,%esp
  801d18:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1b:	e8 3c f5 ff ff       	call   80125c <fd2data>
  801d20:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d27:	50                   	push   %eax
  801d28:	6a 00                	push   $0x0
  801d2a:	56                   	push   %esi
  801d2b:	6a 00                	push   $0x0
  801d2d:	e8 84 f0 ff ff       	call   800db6 <sys_page_map>
  801d32:	89 c3                	mov    %eax,%ebx
  801d34:	83 c4 20             	add    $0x20,%esp
  801d37:	85 c0                	test   %eax,%eax
  801d39:	78 55                	js     801d90 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d3b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d44:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d49:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d50:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d59:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d5e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d65:	83 ec 0c             	sub    $0xc,%esp
  801d68:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6b:	e8 dc f4 ff ff       	call   80124c <fd2num>
  801d70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d73:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d75:	83 c4 04             	add    $0x4,%esp
  801d78:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7b:	e8 cc f4 ff ff       	call   80124c <fd2num>
  801d80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d83:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	ba 00 00 00 00       	mov    $0x0,%edx
  801d8e:	eb 30                	jmp    801dc0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d90:	83 ec 08             	sub    $0x8,%esp
  801d93:	56                   	push   %esi
  801d94:	6a 00                	push   $0x0
  801d96:	e8 5d f0 ff ff       	call   800df8 <sys_page_unmap>
  801d9b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d9e:	83 ec 08             	sub    $0x8,%esp
  801da1:	ff 75 f0             	pushl  -0x10(%ebp)
  801da4:	6a 00                	push   $0x0
  801da6:	e8 4d f0 ff ff       	call   800df8 <sys_page_unmap>
  801dab:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dae:	83 ec 08             	sub    $0x8,%esp
  801db1:	ff 75 f4             	pushl  -0xc(%ebp)
  801db4:	6a 00                	push   $0x0
  801db6:	e8 3d f0 ff ff       	call   800df8 <sys_page_unmap>
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dc0:	89 d0                	mov    %edx,%eax
  801dc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    

00801dc9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd2:	50                   	push   %eax
  801dd3:	ff 75 08             	pushl  0x8(%ebp)
  801dd6:	e8 e7 f4 ff ff       	call   8012c2 <fd_lookup>
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 18                	js     801dfa <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801de2:	83 ec 0c             	sub    $0xc,%esp
  801de5:	ff 75 f4             	pushl  -0xc(%ebp)
  801de8:	e8 6f f4 ff ff       	call   80125c <fd2data>
	return _pipeisclosed(fd, p);
  801ded:	89 c2                	mov    %eax,%edx
  801def:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df2:	e8 21 fd ff ff       	call   801b18 <_pipeisclosed>
  801df7:	83 c4 10             	add    $0x10,%esp
}
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    

00801dfc <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	56                   	push   %esi
  801e00:	53                   	push   %ebx
  801e01:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e04:	85 f6                	test   %esi,%esi
  801e06:	75 16                	jne    801e1e <wait+0x22>
  801e08:	68 6d 2a 80 00       	push   $0x802a6d
  801e0d:	68 0f 2a 80 00       	push   $0x802a0f
  801e12:	6a 09                	push   $0x9
  801e14:	68 78 2a 80 00       	push   $0x802a78
  801e19:	e8 f4 e4 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801e1e:	89 f3                	mov    %esi,%ebx
  801e20:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e26:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801e29:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e2f:	eb 05                	jmp    801e36 <wait+0x3a>
		sys_yield();
  801e31:	e8 1e ef ff ff       	call   800d54 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e36:	8b 43 48             	mov    0x48(%ebx),%eax
  801e39:	39 c6                	cmp    %eax,%esi
  801e3b:	75 07                	jne    801e44 <wait+0x48>
  801e3d:	8b 43 54             	mov    0x54(%ebx),%eax
  801e40:	85 c0                	test   %eax,%eax
  801e42:	75 ed                	jne    801e31 <wait+0x35>
		sys_yield();
}
  801e44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e47:	5b                   	pop    %ebx
  801e48:	5e                   	pop    %esi
  801e49:	5d                   	pop    %ebp
  801e4a:	c3                   	ret    

00801e4b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e53:	5d                   	pop    %ebp
  801e54:	c3                   	ret    

00801e55 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e5b:	68 83 2a 80 00       	push   $0x802a83
  801e60:	ff 75 0c             	pushl  0xc(%ebp)
  801e63:	e8 08 eb ff ff       	call   800970 <strcpy>
	return 0;
}
  801e68:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	57                   	push   %edi
  801e73:	56                   	push   %esi
  801e74:	53                   	push   %ebx
  801e75:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e80:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e86:	eb 2d                	jmp    801eb5 <devcons_write+0x46>
		m = n - tot;
  801e88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e8b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e8d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e90:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e95:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e98:	83 ec 04             	sub    $0x4,%esp
  801e9b:	53                   	push   %ebx
  801e9c:	03 45 0c             	add    0xc(%ebp),%eax
  801e9f:	50                   	push   %eax
  801ea0:	57                   	push   %edi
  801ea1:	e8 5c ec ff ff       	call   800b02 <memmove>
		sys_cputs(buf, m);
  801ea6:	83 c4 08             	add    $0x8,%esp
  801ea9:	53                   	push   %ebx
  801eaa:	57                   	push   %edi
  801eab:	e8 07 ee ff ff       	call   800cb7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb0:	01 de                	add    %ebx,%esi
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	89 f0                	mov    %esi,%eax
  801eb7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eba:	72 cc                	jb     801e88 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ebc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5f                   	pop    %edi
  801ec2:	5d                   	pop    %ebp
  801ec3:	c3                   	ret    

00801ec4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 08             	sub    $0x8,%esp
  801eca:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ecf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed3:	74 2a                	je     801eff <devcons_read+0x3b>
  801ed5:	eb 05                	jmp    801edc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ed7:	e8 78 ee ff ff       	call   800d54 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801edc:	e8 f4 ed ff ff       	call   800cd5 <sys_cgetc>
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	74 f2                	je     801ed7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 16                	js     801eff <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ee9:	83 f8 04             	cmp    $0x4,%eax
  801eec:	74 0c                	je     801efa <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eee:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef1:	88 02                	mov    %al,(%edx)
	return 1;
  801ef3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef8:	eb 05                	jmp    801eff <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801efa:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eff:	c9                   	leave  
  801f00:	c3                   	ret    

00801f01 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f07:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f0d:	6a 01                	push   $0x1
  801f0f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f12:	50                   	push   %eax
  801f13:	e8 9f ed ff ff       	call   800cb7 <sys_cputs>
}
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	c9                   	leave  
  801f1c:	c3                   	ret    

00801f1d <getchar>:

int
getchar(void)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f23:	6a 01                	push   $0x1
  801f25:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f28:	50                   	push   %eax
  801f29:	6a 00                	push   $0x0
  801f2b:	e8 f8 f5 ff ff       	call   801528 <read>
	if (r < 0)
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	85 c0                	test   %eax,%eax
  801f35:	78 0f                	js     801f46 <getchar+0x29>
		return r;
	if (r < 1)
  801f37:	85 c0                	test   %eax,%eax
  801f39:	7e 06                	jle    801f41 <getchar+0x24>
		return -E_EOF;
	return c;
  801f3b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f3f:	eb 05                	jmp    801f46 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f41:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f46:	c9                   	leave  
  801f47:	c3                   	ret    

00801f48 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f51:	50                   	push   %eax
  801f52:	ff 75 08             	pushl  0x8(%ebp)
  801f55:	e8 68 f3 ff ff       	call   8012c2 <fd_lookup>
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 11                	js     801f72 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f64:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f6a:	39 10                	cmp    %edx,(%eax)
  801f6c:	0f 94 c0             	sete   %al
  801f6f:	0f b6 c0             	movzbl %al,%eax
}
  801f72:	c9                   	leave  
  801f73:	c3                   	ret    

00801f74 <opencons>:

int
opencons(void)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7d:	50                   	push   %eax
  801f7e:	e8 f0 f2 ff ff       	call   801273 <fd_alloc>
  801f83:	83 c4 10             	add    $0x10,%esp
		return r;
  801f86:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	78 3e                	js     801fca <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8c:	83 ec 04             	sub    $0x4,%esp
  801f8f:	68 07 04 00 00       	push   $0x407
  801f94:	ff 75 f4             	pushl  -0xc(%ebp)
  801f97:	6a 00                	push   $0x0
  801f99:	e8 d5 ed ff ff       	call   800d73 <sys_page_alloc>
  801f9e:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	78 23                	js     801fca <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fa7:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fbc:	83 ec 0c             	sub    $0xc,%esp
  801fbf:	50                   	push   %eax
  801fc0:	e8 87 f2 ff ff       	call   80124c <fd2num>
  801fc5:	89 c2                	mov    %eax,%edx
  801fc7:	83 c4 10             	add    $0x10,%esp
}
  801fca:	89 d0                	mov    %edx,%eax
  801fcc:	c9                   	leave  
  801fcd:	c3                   	ret    

00801fce <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  801fd4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fdb:	75 2a                	jne    802007 <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801fdd:	83 ec 04             	sub    $0x4,%esp
  801fe0:	6a 06                	push   $0x6
  801fe2:	68 00 f0 bf ee       	push   $0xeebff000
  801fe7:	6a 00                	push   $0x0
  801fe9:	e8 85 ed ff ff       	call   800d73 <sys_page_alloc>
			 if (a < 0)
  801fee:	83 c4 10             	add    $0x10,%esp
  801ff1:	85 c0                	test   %eax,%eax
  801ff3:	79 12                	jns    802007 <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801ff5:	50                   	push   %eax
  801ff6:	68 8f 2a 80 00       	push   $0x802a8f
  801ffb:	6a 21                	push   $0x21
  801ffd:	68 a9 2a 80 00       	push   $0x802aa9
  802002:	e8 0b e3 ff ff       	call   800312 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  802007:	e8 29 ed ff ff       	call   800d35 <sys_getenvid>
  80200c:	83 ec 08             	sub    $0x8,%esp
  80200f:	68 27 20 80 00       	push   $0x802027
  802014:	50                   	push   %eax
  802015:	e8 a4 ee ff ff       	call   800ebe <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  80201a:	8b 45 08             	mov    0x8(%ebp),%eax
  80201d:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	c9                   	leave  
  802026:	c3                   	ret    

00802027 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  802027:	54                   	push   %esp
movl _pgfault_handler, %eax
  802028:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  80202d:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  80202f:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  802032:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  802036:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  80203a:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  80203d:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  802041:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  802043:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  802046:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  802047:	83 c4 04             	add    $0x4,%esp
popfl
  80204a:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  80204b:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  80204c:	c3                   	ret    

0080204d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	56                   	push   %esi
  802051:	53                   	push   %ebx
  802052:	8b 75 08             	mov    0x8(%ebp),%esi
  802055:	8b 45 0c             	mov    0xc(%ebp),%eax
  802058:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  80205b:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  80205d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802062:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  802065:	83 ec 0c             	sub    $0xc,%esp
  802068:	50                   	push   %eax
  802069:	e8 b5 ee ff ff       	call   800f23 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	85 c0                	test   %eax,%eax
  802073:	78 0e                	js     802083 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  802075:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80207b:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  80207e:	8b 52 78             	mov    0x78(%edx),%edx
  802081:	eb 0a                	jmp    80208d <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  802083:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  802088:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  80208d:	85 f6                	test   %esi,%esi
  80208f:	74 02                	je     802093 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  802091:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  802093:	85 db                	test   %ebx,%ebx
  802095:	74 02                	je     802099 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  802097:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  802099:	85 c0                	test   %eax,%eax
  80209b:	78 08                	js     8020a5 <ipc_recv+0x58>
  80209d:	a1 04 40 80 00       	mov    0x804004,%eax
  8020a2:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  8020a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a8:	5b                   	pop    %ebx
  8020a9:	5e                   	pop    %esi
  8020aa:	5d                   	pop    %ebp
  8020ab:	c3                   	ret    

008020ac <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	57                   	push   %edi
  8020b0:	56                   	push   %esi
  8020b1:	53                   	push   %ebx
  8020b2:	83 ec 0c             	sub    $0xc,%esp
  8020b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  8020be:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  8020c0:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8020c5:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  8020c8:	ff 75 14             	pushl  0x14(%ebp)
  8020cb:	53                   	push   %ebx
  8020cc:	56                   	push   %esi
  8020cd:	57                   	push   %edi
  8020ce:	e8 2d ee ff ff       	call   800f00 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  8020d3:	83 c4 10             	add    $0x10,%esp
  8020d6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d9:	75 07                	jne    8020e2 <ipc_send+0x36>
				    sys_yield();
  8020db:	e8 74 ec ff ff       	call   800d54 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  8020e0:	eb e6                	jmp    8020c8 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	74 12                	je     8020f8 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  8020e6:	50                   	push   %eax
  8020e7:	68 b7 2a 80 00       	push   $0x802ab7
  8020ec:	6a 4b                	push   $0x4b
  8020ee:	68 cb 2a 80 00       	push   $0x802acb
  8020f3:	e8 1a e2 ff ff       	call   800312 <_panic>
			 }
	   }
}
  8020f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fb:	5b                   	pop    %ebx
  8020fc:	5e                   	pop    %esi
  8020fd:	5f                   	pop    %edi
  8020fe:	5d                   	pop    %ebp
  8020ff:	c3                   	ret    

00802100 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  802106:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  80210b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80210e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802114:	8b 52 50             	mov    0x50(%edx),%edx
  802117:	39 ca                	cmp    %ecx,%edx
  802119:	75 0d                	jne    802128 <ipc_find_env+0x28>
				    return envs[i].env_id;
  80211b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80211e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802123:	8b 40 48             	mov    0x48(%eax),%eax
  802126:	eb 0f                	jmp    802137 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  802128:	83 c0 01             	add    $0x1,%eax
  80212b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802130:	75 d9                	jne    80210b <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  802132:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    

00802139 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802139:	55                   	push   %ebp
  80213a:	89 e5                	mov    %esp,%ebp
  80213c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80213f:	89 d0                	mov    %edx,%eax
  802141:	c1 e8 16             	shr    $0x16,%eax
  802144:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80214b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802150:	f6 c1 01             	test   $0x1,%cl
  802153:	74 1d                	je     802172 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802155:	c1 ea 0c             	shr    $0xc,%edx
  802158:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80215f:	f6 c2 01             	test   $0x1,%dl
  802162:	74 0e                	je     802172 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802164:	c1 ea 0c             	shr    $0xc,%edx
  802167:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80216e:	ef 
  80216f:	0f b7 c0             	movzwl %ax,%eax
}
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	66 90                	xchg   %ax,%ax
  802176:	66 90                	xchg   %ax,%ax
  802178:	66 90                	xchg   %ax,%ax
  80217a:	66 90                	xchg   %ax,%ax
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

00802180 <__udivdi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80218b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80218f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 f6                	test   %esi,%esi
  802199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80219d:	89 ca                	mov    %ecx,%edx
  80219f:	89 f8                	mov    %edi,%eax
  8021a1:	75 3d                	jne    8021e0 <__udivdi3+0x60>
  8021a3:	39 cf                	cmp    %ecx,%edi
  8021a5:	0f 87 c5 00 00 00    	ja     802270 <__udivdi3+0xf0>
  8021ab:	85 ff                	test   %edi,%edi
  8021ad:	89 fd                	mov    %edi,%ebp
  8021af:	75 0b                	jne    8021bc <__udivdi3+0x3c>
  8021b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b6:	31 d2                	xor    %edx,%edx
  8021b8:	f7 f7                	div    %edi
  8021ba:	89 c5                	mov    %eax,%ebp
  8021bc:	89 c8                	mov    %ecx,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	f7 f5                	div    %ebp
  8021c2:	89 c1                	mov    %eax,%ecx
  8021c4:	89 d8                	mov    %ebx,%eax
  8021c6:	89 cf                	mov    %ecx,%edi
  8021c8:	f7 f5                	div    %ebp
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	39 ce                	cmp    %ecx,%esi
  8021e2:	77 74                	ja     802258 <__udivdi3+0xd8>
  8021e4:	0f bd fe             	bsr    %esi,%edi
  8021e7:	83 f7 1f             	xor    $0x1f,%edi
  8021ea:	0f 84 98 00 00 00    	je     802288 <__udivdi3+0x108>
  8021f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	89 c5                	mov    %eax,%ebp
  8021f9:	29 fb                	sub    %edi,%ebx
  8021fb:	d3 e6                	shl    %cl,%esi
  8021fd:	89 d9                	mov    %ebx,%ecx
  8021ff:	d3 ed                	shr    %cl,%ebp
  802201:	89 f9                	mov    %edi,%ecx
  802203:	d3 e0                	shl    %cl,%eax
  802205:	09 ee                	or     %ebp,%esi
  802207:	89 d9                	mov    %ebx,%ecx
  802209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220d:	89 d5                	mov    %edx,%ebp
  80220f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802213:	d3 ed                	shr    %cl,%ebp
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e2                	shl    %cl,%edx
  802219:	89 d9                	mov    %ebx,%ecx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	09 c2                	or     %eax,%edx
  80221f:	89 d0                	mov    %edx,%eax
  802221:	89 ea                	mov    %ebp,%edx
  802223:	f7 f6                	div    %esi
  802225:	89 d5                	mov    %edx,%ebp
  802227:	89 c3                	mov    %eax,%ebx
  802229:	f7 64 24 0c          	mull   0xc(%esp)
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	72 10                	jb     802241 <__udivdi3+0xc1>
  802231:	8b 74 24 08          	mov    0x8(%esp),%esi
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e6                	shl    %cl,%esi
  802239:	39 c6                	cmp    %eax,%esi
  80223b:	73 07                	jae    802244 <__udivdi3+0xc4>
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	75 03                	jne    802244 <__udivdi3+0xc4>
  802241:	83 eb 01             	sub    $0x1,%ebx
  802244:	31 ff                	xor    %edi,%edi
  802246:	89 d8                	mov    %ebx,%eax
  802248:	89 fa                	mov    %edi,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	31 ff                	xor    %edi,%edi
  80225a:	31 db                	xor    %ebx,%ebx
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	89 fa                	mov    %edi,%edx
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 d8                	mov    %ebx,%eax
  802272:	f7 f7                	div    %edi
  802274:	31 ff                	xor    %edi,%edi
  802276:	89 c3                	mov    %eax,%ebx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 fa                	mov    %edi,%edx
  80227c:	83 c4 1c             	add    $0x1c,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	39 ce                	cmp    %ecx,%esi
  80228a:	72 0c                	jb     802298 <__udivdi3+0x118>
  80228c:	31 db                	xor    %ebx,%ebx
  80228e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802292:	0f 87 34 ff ff ff    	ja     8021cc <__udivdi3+0x4c>
  802298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80229d:	e9 2a ff ff ff       	jmp    8021cc <__udivdi3+0x4c>
  8022a2:	66 90                	xchg   %ax,%ax
  8022a4:	66 90                	xchg   %ax,%ax
  8022a6:	66 90                	xchg   %ax,%ax
  8022a8:	66 90                	xchg   %ax,%ax
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	83 ec 1c             	sub    $0x1c,%esp
  8022b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022c7:	85 d2                	test   %edx,%edx
  8022c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022d1:	89 f3                	mov    %esi,%ebx
  8022d3:	89 3c 24             	mov    %edi,(%esp)
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	75 1c                	jne    8022f8 <__umoddi3+0x48>
  8022dc:	39 f7                	cmp    %esi,%edi
  8022de:	76 50                	jbe    802330 <__umoddi3+0x80>
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	f7 f7                	div    %edi
  8022e6:	89 d0                	mov    %edx,%eax
  8022e8:	31 d2                	xor    %edx,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	77 52                	ja     802350 <__umoddi3+0xa0>
  8022fe:	0f bd ea             	bsr    %edx,%ebp
  802301:	83 f5 1f             	xor    $0x1f,%ebp
  802304:	75 5a                	jne    802360 <__umoddi3+0xb0>
  802306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	39 0c 24             	cmp    %ecx,(%esp)
  802313:	0f 86 d7 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  802319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80231d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802321:	83 c4 1c             	add    $0x1c,%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	85 ff                	test   %edi,%edi
  802332:	89 fd                	mov    %edi,%ebp
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 f0                	mov    %esi,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 c8                	mov    %ecx,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	eb 99                	jmp    8022e8 <__umoddi3+0x38>
  80234f:	90                   	nop
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	83 c4 1c             	add    $0x1c,%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	8b 34 24             	mov    (%esp),%esi
  802363:	bf 20 00 00 00       	mov    $0x20,%edi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	29 ef                	sub    %ebp,%edi
  80236c:	d3 e0                	shl    %cl,%eax
  80236e:	89 f9                	mov    %edi,%ecx
  802370:	89 f2                	mov    %esi,%edx
  802372:	d3 ea                	shr    %cl,%edx
  802374:	89 e9                	mov    %ebp,%ecx
  802376:	09 c2                	or     %eax,%edx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 14 24             	mov    %edx,(%esp)
  80237d:	89 f2                	mov    %esi,%edx
  80237f:	d3 e2                	shl    %cl,%edx
  802381:	89 f9                	mov    %edi,%ecx
  802383:	89 54 24 04          	mov    %edx,0x4(%esp)
  802387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	89 c6                	mov    %eax,%esi
  802391:	d3 e3                	shl    %cl,%ebx
  802393:	89 f9                	mov    %edi,%ecx
  802395:	89 d0                	mov    %edx,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	09 d8                	or     %ebx,%eax
  80239d:	89 d3                	mov    %edx,%ebx
  80239f:	89 f2                	mov    %esi,%edx
  8023a1:	f7 34 24             	divl   (%esp)
  8023a4:	89 d6                	mov    %edx,%esi
  8023a6:	d3 e3                	shl    %cl,%ebx
  8023a8:	f7 64 24 04          	mull   0x4(%esp)
  8023ac:	39 d6                	cmp    %edx,%esi
  8023ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023b2:	89 d1                	mov    %edx,%ecx
  8023b4:	89 c3                	mov    %eax,%ebx
  8023b6:	72 08                	jb     8023c0 <__umoddi3+0x110>
  8023b8:	75 11                	jne    8023cb <__umoddi3+0x11b>
  8023ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023be:	73 0b                	jae    8023cb <__umoddi3+0x11b>
  8023c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023c4:	1b 14 24             	sbb    (%esp),%edx
  8023c7:	89 d1                	mov    %edx,%ecx
  8023c9:	89 c3                	mov    %eax,%ebx
  8023cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023cf:	29 da                	sub    %ebx,%edx
  8023d1:	19 ce                	sbb    %ecx,%esi
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 f0                	mov    %esi,%eax
  8023d7:	d3 e0                	shl    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	d3 ea                	shr    %cl,%edx
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	d3 ee                	shr    %cl,%esi
  8023e1:	09 d0                	or     %edx,%eax
  8023e3:	89 f2                	mov    %esi,%edx
  8023e5:	83 c4 1c             	add    $0x1c,%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5f                   	pop    %edi
  8023eb:	5d                   	pop    %ebp
  8023ec:	c3                   	ret    
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 f9                	sub    %edi,%ecx
  8023f2:	19 d6                	sbb    %edx,%esi
  8023f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023fc:	e9 18 ff ff ff       	jmp    802319 <__umoddi3+0x69>
