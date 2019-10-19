
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 ee 14 00 00       	call   80153f <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 40 23 80 00       	push   $0x802340
  80006d:	6a 15                	push   $0x15
  80006f:	68 6f 23 80 00       	push   $0x80236f
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 81 23 80 00       	push   $0x802381
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 6b 1b 00 00       	call   801bfc <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 85 23 80 00       	push   $0x802385
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 6f 23 80 00       	push   $0x80236f
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 21 0f 00 00       	call   800fd3 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 c8 27 80 00       	push   $0x8027c8
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 6f 23 80 00       	push   $0x80236f
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 9d 12 00 00       	call   801372 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 92 12 00 00       	call   801372 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 7c 12 00 00       	call   801372 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 34 14 00 00       	call   80153f <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 8e 23 80 00       	push   $0x80238e
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 6f 23 80 00       	push   $0x80236f
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 3a 14 00 00       	call   801588 <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 aa 23 80 00       	push   $0x8023aa
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 6f 23 80 00       	push   $0x80236f
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 c4 	movl   $0x8023c4,0x803000
  800187:	23 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 69 1a 00 00       	call   801bfc <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 85 23 80 00       	push   $0x802385
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 6f 23 80 00       	push   $0x80236f
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 1f 0e 00 00       	call   800fd3 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 c8 27 80 00       	push   $0x8027c8
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 6f 23 80 00       	push   $0x80236f
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 99 11 00 00       	call   801372 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 83 11 00 00       	call   801372 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 7e 13 00 00       	call   801588 <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 cf 23 80 00       	push   $0x8023cf
  800226:	6a 4a                	push   $0x4a
  800228:	68 6f 23 80 00       	push   $0x80236f
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800243:	e8 73 0a 00 00       	call   800cbb <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 14 11 00 00       	call   80139d <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 e7 09 00 00       	call   800c7a <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 10 0a 00 00       	call   800cbb <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 f4 23 80 00       	push   $0x8023f4
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 83 23 80 00 	movl   $0x802383,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 2f 09 00 00       	call   800c3d <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 54 01 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 d4 08 00 00       	call   800c3d <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 d7 1c 00 00       	call   8020b0 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 c4 1d 00 00       	call   8021e0 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 17 24 80 00 	movsbl 0x802417(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800437:	83 fa 01             	cmp    $0x1,%edx
  80043a:	7e 0e                	jle    80044a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800441:	89 08                	mov    %ecx,(%eax)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	8b 52 04             	mov    0x4(%edx),%edx
  800448:	eb 22                	jmp    80046c <getuint+0x38>
	else if (lflag)
  80044a:	85 d2                	test   %edx,%edx
  80044c:	74 10                	je     80045e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 04             	lea    0x4(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	eb 0e                	jmp    80046c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 04             	lea    0x4(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800474:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	3b 50 04             	cmp    0x4(%eax),%edx
  80047d:	73 0a                	jae    800489 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800482:	89 08                	mov    %ecx,(%eax)
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	88 02                	mov    %al,(%edx)
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800491:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800494:	50                   	push   %eax
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	ff 75 08             	pushl  0x8(%ebp)
  80049e:	e8 05 00 00 00       	call   8004a8 <vprintfmt>
	va_end(ap);
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 2c             	sub    $0x2c,%esp
  8004b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ba:	eb 12                	jmp    8004ce <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	0f 84 89 03 00 00    	je     80084d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	50                   	push   %eax
  8004c9:	ff d6                	call   *%esi
  8004cb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ce:	83 c7 01             	add    $0x1,%edi
  8004d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d5:	83 f8 25             	cmp    $0x25,%eax
  8004d8:	75 e2                	jne    8004bc <vprintfmt+0x14>
  8004da:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004de:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f8:	eb 07                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004fd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8d 47 01             	lea    0x1(%edi),%eax
  800504:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800507:	0f b6 07             	movzbl (%edi),%eax
  80050a:	0f b6 c8             	movzbl %al,%ecx
  80050d:	83 e8 23             	sub    $0x23,%eax
  800510:	3c 55                	cmp    $0x55,%al
  800512:	0f 87 1a 03 00 00    	ja     800832 <vprintfmt+0x38a>
  800518:	0f b6 c0             	movzbl %al,%eax
  80051b:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  800522:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800525:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800529:	eb d6                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052e:	b8 00 00 00 00       	mov    $0x0,%eax
  800533:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800536:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800539:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80053d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800540:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800543:	83 fa 09             	cmp    $0x9,%edx
  800546:	77 39                	ja     800581 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800548:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80054b:	eb e9                	jmp    800536 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 48 04             	lea    0x4(%eax),%ecx
  800553:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055e:	eb 27                	jmp    800587 <vprintfmt+0xdf>
  800560:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800563:	85 c0                	test   %eax,%eax
  800565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056a:	0f 49 c8             	cmovns %eax,%ecx
  80056d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800573:	eb 8c                	jmp    800501 <vprintfmt+0x59>
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800578:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057f:	eb 80                	jmp    800501 <vprintfmt+0x59>
  800581:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800584:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	0f 89 70 ff ff ff    	jns    800501 <vprintfmt+0x59>
				width = precision, precision = -1;
  800591:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800594:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800597:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059e:	e9 5e ff ff ff       	jmp    800501 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a9:	e9 53 ff ff ff       	jmp    800501 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	ff 30                	pushl  (%eax)
  8005bd:	ff d6                	call   *%esi
			break;
  8005bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c5:	e9 04 ff ff ff       	jmp    8004ce <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	99                   	cltd   
  8005d6:	31 d0                	xor    %edx,%eax
  8005d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005da:	83 f8 0f             	cmp    $0xf,%eax
  8005dd:	7f 0b                	jg     8005ea <vprintfmt+0x142>
  8005df:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	75 18                	jne    800602 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005ea:	50                   	push   %eax
  8005eb:	68 2f 24 80 00       	push   $0x80242f
  8005f0:	53                   	push   %ebx
  8005f1:	56                   	push   %esi
  8005f2:	e8 94 fe ff ff       	call   80048b <printfmt>
  8005f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fd:	e9 cc fe ff ff       	jmp    8004ce <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800602:	52                   	push   %edx
  800603:	68 a1 28 80 00       	push   $0x8028a1
  800608:	53                   	push   %ebx
  800609:	56                   	push   %esi
  80060a:	e8 7c fe ff ff       	call   80048b <printfmt>
  80060f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800615:	e9 b4 fe ff ff       	jmp    8004ce <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
  800623:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800625:	85 ff                	test   %edi,%edi
  800627:	b8 28 24 80 00       	mov    $0x802428,%eax
  80062c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80062f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800633:	0f 8e 94 00 00 00    	jle    8006cd <vprintfmt+0x225>
  800639:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80063d:	0f 84 98 00 00 00    	je     8006db <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	ff 75 d0             	pushl  -0x30(%ebp)
  800649:	57                   	push   %edi
  80064a:	e8 86 02 00 00       	call   8008d5 <strnlen>
  80064f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800652:	29 c1                	sub    %eax,%ecx
  800654:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800657:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80065a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80065e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800661:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800664:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	eb 0f                	jmp    800677 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	ff 75 e0             	pushl  -0x20(%ebp)
  80066f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800671:	83 ef 01             	sub    $0x1,%edi
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	85 ff                	test   %edi,%edi
  800679:	7f ed                	jg     800668 <vprintfmt+0x1c0>
  80067b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800681:	85 c9                	test   %ecx,%ecx
  800683:	b8 00 00 00 00       	mov    $0x0,%eax
  800688:	0f 49 c1             	cmovns %ecx,%eax
  80068b:	29 c1                	sub    %eax,%ecx
  80068d:	89 75 08             	mov    %esi,0x8(%ebp)
  800690:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800693:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800696:	89 cb                	mov    %ecx,%ebx
  800698:	eb 4d                	jmp    8006e7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80069a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069e:	74 1b                	je     8006bb <vprintfmt+0x213>
  8006a0:	0f be c0             	movsbl %al,%eax
  8006a3:	83 e8 20             	sub    $0x20,%eax
  8006a6:	83 f8 5e             	cmp    $0x5e,%eax
  8006a9:	76 10                	jbe    8006bb <vprintfmt+0x213>
					putch('?', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	ff 75 0c             	pushl  0xc(%ebp)
  8006b1:	6a 3f                	push   $0x3f
  8006b3:	ff 55 08             	call   *0x8(%ebp)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 0d                	jmp    8006c8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	52                   	push   %edx
  8006c2:	ff 55 08             	call   *0x8(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c8:	83 eb 01             	sub    $0x1,%ebx
  8006cb:	eb 1a                	jmp    8006e7 <vprintfmt+0x23f>
  8006cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d9:	eb 0c                	jmp    8006e7 <vprintfmt+0x23f>
  8006db:	89 75 08             	mov    %esi,0x8(%ebp)
  8006de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e7:	83 c7 01             	add    $0x1,%edi
  8006ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ee:	0f be d0             	movsbl %al,%edx
  8006f1:	85 d2                	test   %edx,%edx
  8006f3:	74 23                	je     800718 <vprintfmt+0x270>
  8006f5:	85 f6                	test   %esi,%esi
  8006f7:	78 a1                	js     80069a <vprintfmt+0x1f2>
  8006f9:	83 ee 01             	sub    $0x1,%esi
  8006fc:	79 9c                	jns    80069a <vprintfmt+0x1f2>
  8006fe:	89 df                	mov    %ebx,%edi
  800700:	8b 75 08             	mov    0x8(%ebp),%esi
  800703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800706:	eb 18                	jmp    800720 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 20                	push   $0x20
  80070e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800710:	83 ef 01             	sub    $0x1,%edi
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 08                	jmp    800720 <vprintfmt+0x278>
  800718:	89 df                	mov    %ebx,%edi
  80071a:	8b 75 08             	mov    0x8(%ebp),%esi
  80071d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800720:	85 ff                	test   %edi,%edi
  800722:	7f e4                	jg     800708 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800727:	e9 a2 fd ff ff       	jmp    8004ce <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072c:	83 fa 01             	cmp    $0x1,%edx
  80072f:	7e 16                	jle    800747 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 08             	lea    0x8(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 50 04             	mov    0x4(%eax),%edx
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800742:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800745:	eb 32                	jmp    800779 <vprintfmt+0x2d1>
	else if (lflag)
  800747:	85 d2                	test   %edx,%edx
  800749:	74 18                	je     800763 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 50 04             	lea    0x4(%eax),%edx
  800751:	89 55 14             	mov    %edx,0x14(%ebp)
  800754:	8b 00                	mov    (%eax),%eax
  800756:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800759:	89 c1                	mov    %eax,%ecx
  80075b:	c1 f9 1f             	sar    $0x1f,%ecx
  80075e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800761:	eb 16                	jmp    800779 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800771:	89 c1                	mov    %eax,%ecx
  800773:	c1 f9 1f             	sar    $0x1f,%ecx
  800776:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800779:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800784:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800788:	79 74                	jns    8007fe <vprintfmt+0x356>
				putch('-', putdat);
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	53                   	push   %ebx
  80078e:	6a 2d                	push   $0x2d
  800790:	ff d6                	call   *%esi
				num = -(long long) num;
  800792:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800795:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800798:	f7 d8                	neg    %eax
  80079a:	83 d2 00             	adc    $0x0,%edx
  80079d:	f7 da                	neg    %edx
  80079f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a7:	eb 55                	jmp    8007fe <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ac:	e8 83 fc ff ff       	call   800434 <getuint>
			base = 10;
  8007b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007b6:	eb 46                	jmp    8007fe <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bb:	e8 74 fc ff ff       	call   800434 <getuint>
			base = 8;
  8007c0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007c5:	eb 37                	jmp    8007fe <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 30                	push   $0x30
  8007cd:	ff d6                	call   *%esi
			putch('x', putdat);
  8007cf:	83 c4 08             	add    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	6a 78                	push   $0x78
  8007d5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007e7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ea:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007ef:	eb 0d                	jmp    8007fe <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f4:	e8 3b fc ff ff       	call   800434 <getuint>
			base = 16;
  8007f9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fe:	83 ec 0c             	sub    $0xc,%esp
  800801:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800805:	57                   	push   %edi
  800806:	ff 75 e0             	pushl  -0x20(%ebp)
  800809:	51                   	push   %ecx
  80080a:	52                   	push   %edx
  80080b:	50                   	push   %eax
  80080c:	89 da                	mov    %ebx,%edx
  80080e:	89 f0                	mov    %esi,%eax
  800810:	e8 70 fb ff ff       	call   800385 <printnum>
			break;
  800815:	83 c4 20             	add    $0x20,%esp
  800818:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80081b:	e9 ae fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	51                   	push   %ecx
  800825:	ff d6                	call   *%esi
			break;
  800827:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80082d:	e9 9c fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800832:	83 ec 08             	sub    $0x8,%esp
  800835:	53                   	push   %ebx
  800836:	6a 25                	push   $0x25
  800838:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 03                	jmp    800842 <vprintfmt+0x39a>
  80083f:	83 ef 01             	sub    $0x1,%edi
  800842:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800846:	75 f7                	jne    80083f <vprintfmt+0x397>
  800848:	e9 81 fc ff ff       	jmp    8004ce <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80084d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5f                   	pop    %edi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 18             	sub    $0x18,%esp
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800861:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800864:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800868:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800872:	85 c0                	test   %eax,%eax
  800874:	74 26                	je     80089c <vsnprintf+0x47>
  800876:	85 d2                	test   %edx,%edx
  800878:	7e 22                	jle    80089c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80087a:	ff 75 14             	pushl  0x14(%ebp)
  80087d:	ff 75 10             	pushl  0x10(%ebp)
  800880:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	68 6e 04 80 00       	push   $0x80046e
  800889:	e8 1a fc ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800891:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800894:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	eb 05                	jmp    8008a1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ac:	50                   	push   %eax
  8008ad:	ff 75 10             	pushl  0x10(%ebp)
  8008b0:	ff 75 0c             	pushl  0xc(%ebp)
  8008b3:	ff 75 08             	pushl  0x8(%ebp)
  8008b6:	e8 9a ff ff ff       	call   800855 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	eb 03                	jmp    8008cd <strlen+0x10>
		n++;
  8008ca:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d1:	75 f7                	jne    8008ca <strlen+0xd>
		n++;
	return n;
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008db:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008de:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e3:	eb 03                	jmp    8008e8 <strnlen+0x13>
		n++;
  8008e5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e8:	39 c2                	cmp    %eax,%edx
  8008ea:	74 08                	je     8008f4 <strnlen+0x1f>
  8008ec:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008f0:	75 f3                	jne    8008e5 <strnlen+0x10>
  8008f2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	53                   	push   %ebx
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800900:	89 c2                	mov    %eax,%edx
  800902:	83 c2 01             	add    $0x1,%edx
  800905:	83 c1 01             	add    $0x1,%ecx
  800908:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80090c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090f:	84 db                	test   %bl,%bl
  800911:	75 ef                	jne    800902 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800913:	5b                   	pop    %ebx
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	53                   	push   %ebx
  80091a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091d:	53                   	push   %ebx
  80091e:	e8 9a ff ff ff       	call   8008bd <strlen>
  800923:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800926:	ff 75 0c             	pushl  0xc(%ebp)
  800929:	01 d8                	add    %ebx,%eax
  80092b:	50                   	push   %eax
  80092c:	e8 c5 ff ff ff       	call   8008f6 <strcpy>
	return dst;
}
  800931:	89 d8                	mov    %ebx,%eax
  800933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 75 08             	mov    0x8(%ebp),%esi
  800940:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800943:	89 f3                	mov    %esi,%ebx
  800945:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800948:	89 f2                	mov    %esi,%edx
  80094a:	eb 0f                	jmp    80095b <strncpy+0x23>
		*dst++ = *src;
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800955:	80 39 01             	cmpb   $0x1,(%ecx)
  800958:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095b:	39 da                	cmp    %ebx,%edx
  80095d:	75 ed                	jne    80094c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095f:	89 f0                	mov    %esi,%eax
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 75 08             	mov    0x8(%ebp),%esi
  80096d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800970:	8b 55 10             	mov    0x10(%ebp),%edx
  800973:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800975:	85 d2                	test   %edx,%edx
  800977:	74 21                	je     80099a <strlcpy+0x35>
  800979:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097d:	89 f2                	mov    %esi,%edx
  80097f:	eb 09                	jmp    80098a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800981:	83 c2 01             	add    $0x1,%edx
  800984:	83 c1 01             	add    $0x1,%ecx
  800987:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80098a:	39 c2                	cmp    %eax,%edx
  80098c:	74 09                	je     800997 <strlcpy+0x32>
  80098e:	0f b6 19             	movzbl (%ecx),%ebx
  800991:	84 db                	test   %bl,%bl
  800993:	75 ec                	jne    800981 <strlcpy+0x1c>
  800995:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800997:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099a:	29 f0                	sub    %esi,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a9:	eb 06                	jmp    8009b1 <strcmp+0x11>
		p++, q++;
  8009ab:	83 c1 01             	add    $0x1,%ecx
  8009ae:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b1:	0f b6 01             	movzbl (%ecx),%eax
  8009b4:	84 c0                	test   %al,%al
  8009b6:	74 04                	je     8009bc <strcmp+0x1c>
  8009b8:	3a 02                	cmp    (%edx),%al
  8009ba:	74 ef                	je     8009ab <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bc:	0f b6 c0             	movzbl %al,%eax
  8009bf:	0f b6 12             	movzbl (%edx),%edx
  8009c2:	29 d0                	sub    %edx,%eax
}
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 c3                	mov    %eax,%ebx
  8009d2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d5:	eb 06                	jmp    8009dd <strncmp+0x17>
		n--, p++, q++;
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009dd:	39 d8                	cmp    %ebx,%eax
  8009df:	74 15                	je     8009f6 <strncmp+0x30>
  8009e1:	0f b6 08             	movzbl (%eax),%ecx
  8009e4:	84 c9                	test   %cl,%cl
  8009e6:	74 04                	je     8009ec <strncmp+0x26>
  8009e8:	3a 0a                	cmp    (%edx),%cl
  8009ea:	74 eb                	je     8009d7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ec:	0f b6 00             	movzbl (%eax),%eax
  8009ef:	0f b6 12             	movzbl (%edx),%edx
  8009f2:	29 d0                	sub    %edx,%eax
  8009f4:	eb 05                	jmp    8009fb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a08:	eb 07                	jmp    800a11 <strchr+0x13>
		if (*s == c)
  800a0a:	38 ca                	cmp    %cl,%dl
  800a0c:	74 0f                	je     800a1d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0e:	83 c0 01             	add    $0x1,%eax
  800a11:	0f b6 10             	movzbl (%eax),%edx
  800a14:	84 d2                	test   %dl,%dl
  800a16:	75 f2                	jne    800a0a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a29:	eb 03                	jmp    800a2e <strfind+0xf>
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a31:	38 ca                	cmp    %cl,%dl
  800a33:	74 04                	je     800a39 <strfind+0x1a>
  800a35:	84 d2                	test   %dl,%dl
  800a37:	75 f2                	jne    800a2b <strfind+0xc>
			break;
	return (char *) s;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a47:	85 c9                	test   %ecx,%ecx
  800a49:	74 36                	je     800a81 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a51:	75 28                	jne    800a7b <memset+0x40>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 23                	jne    800a7b <memset+0x40>
		c &= 0xFF;
  800a58:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5c:	89 d3                	mov    %edx,%ebx
  800a5e:	c1 e3 08             	shl    $0x8,%ebx
  800a61:	89 d6                	mov    %edx,%esi
  800a63:	c1 e6 18             	shl    $0x18,%esi
  800a66:	89 d0                	mov    %edx,%eax
  800a68:	c1 e0 10             	shl    $0x10,%eax
  800a6b:	09 f0                	or     %esi,%eax
  800a6d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a6f:	89 d8                	mov    %ebx,%eax
  800a71:	09 d0                	or     %edx,%eax
  800a73:	c1 e9 02             	shr    $0x2,%ecx
  800a76:	fc                   	cld    
  800a77:	f3 ab                	rep stos %eax,%es:(%edi)
  800a79:	eb 06                	jmp    800a81 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7e:	fc                   	cld    
  800a7f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a81:	89 f8                	mov    %edi,%eax
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5f                   	pop    %edi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a96:	39 c6                	cmp    %eax,%esi
  800a98:	73 35                	jae    800acf <memmove+0x47>
  800a9a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9d:	39 d0                	cmp    %edx,%eax
  800a9f:	73 2e                	jae    800acf <memmove+0x47>
		s += n;
		d += n;
  800aa1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	09 fe                	or     %edi,%esi
  800aa8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aae:	75 13                	jne    800ac3 <memmove+0x3b>
  800ab0:	f6 c1 03             	test   $0x3,%cl
  800ab3:	75 0e                	jne    800ac3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ab5:	83 ef 04             	sub    $0x4,%edi
  800ab8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abb:	c1 e9 02             	shr    $0x2,%ecx
  800abe:	fd                   	std    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac1:	eb 09                	jmp    800acc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac3:	83 ef 01             	sub    $0x1,%edi
  800ac6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ac9:	fd                   	std    
  800aca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acc:	fc                   	cld    
  800acd:	eb 1d                	jmp    800aec <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	89 f2                	mov    %esi,%edx
  800ad1:	09 c2                	or     %eax,%edx
  800ad3:	f6 c2 03             	test   $0x3,%dl
  800ad6:	75 0f                	jne    800ae7 <memmove+0x5f>
  800ad8:	f6 c1 03             	test   $0x3,%cl
  800adb:	75 0a                	jne    800ae7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800add:	c1 e9 02             	shr    $0x2,%ecx
  800ae0:	89 c7                	mov    %eax,%edi
  800ae2:	fc                   	cld    
  800ae3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae5:	eb 05                	jmp    800aec <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae7:	89 c7                	mov    %eax,%edi
  800ae9:	fc                   	cld    
  800aea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af3:	ff 75 10             	pushl  0x10(%ebp)
  800af6:	ff 75 0c             	pushl  0xc(%ebp)
  800af9:	ff 75 08             	pushl  0x8(%ebp)
  800afc:	e8 87 ff ff ff       	call   800a88 <memmove>
}
  800b01:	c9                   	leave  
  800b02:	c3                   	ret    

00800b03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0e:	89 c6                	mov    %eax,%esi
  800b10:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b13:	eb 1a                	jmp    800b2f <memcmp+0x2c>
		if (*s1 != *s2)
  800b15:	0f b6 08             	movzbl (%eax),%ecx
  800b18:	0f b6 1a             	movzbl (%edx),%ebx
  800b1b:	38 d9                	cmp    %bl,%cl
  800b1d:	74 0a                	je     800b29 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b1f:	0f b6 c1             	movzbl %cl,%eax
  800b22:	0f b6 db             	movzbl %bl,%ebx
  800b25:	29 d8                	sub    %ebx,%eax
  800b27:	eb 0f                	jmp    800b38 <memcmp+0x35>
		s1++, s2++;
  800b29:	83 c0 01             	add    $0x1,%eax
  800b2c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2f:	39 f0                	cmp    %esi,%eax
  800b31:	75 e2                	jne    800b15 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	53                   	push   %ebx
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b43:	89 c1                	mov    %eax,%ecx
  800b45:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b48:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b4c:	eb 0a                	jmp    800b58 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4e:	0f b6 10             	movzbl (%eax),%edx
  800b51:	39 da                	cmp    %ebx,%edx
  800b53:	74 07                	je     800b5c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b55:	83 c0 01             	add    $0x1,%eax
  800b58:	39 c8                	cmp    %ecx,%eax
  800b5a:	72 f2                	jb     800b4e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6b:	eb 03                	jmp    800b70 <strtol+0x11>
		s++;
  800b6d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b70:	0f b6 01             	movzbl (%ecx),%eax
  800b73:	3c 20                	cmp    $0x20,%al
  800b75:	74 f6                	je     800b6d <strtol+0xe>
  800b77:	3c 09                	cmp    $0x9,%al
  800b79:	74 f2                	je     800b6d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b7b:	3c 2b                	cmp    $0x2b,%al
  800b7d:	75 0a                	jne    800b89 <strtol+0x2a>
		s++;
  800b7f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
  800b87:	eb 11                	jmp    800b9a <strtol+0x3b>
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8e:	3c 2d                	cmp    $0x2d,%al
  800b90:	75 08                	jne    800b9a <strtol+0x3b>
		s++, neg = 1;
  800b92:	83 c1 01             	add    $0x1,%ecx
  800b95:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ba0:	75 15                	jne    800bb7 <strtol+0x58>
  800ba2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba5:	75 10                	jne    800bb7 <strtol+0x58>
  800ba7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bab:	75 7c                	jne    800c29 <strtol+0xca>
		s += 2, base = 16;
  800bad:	83 c1 02             	add    $0x2,%ecx
  800bb0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb5:	eb 16                	jmp    800bcd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bb7:	85 db                	test   %ebx,%ebx
  800bb9:	75 12                	jne    800bcd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bbb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc3:	75 08                	jne    800bcd <strtol+0x6e>
		s++, base = 8;
  800bc5:	83 c1 01             	add    $0x1,%ecx
  800bc8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd5:	0f b6 11             	movzbl (%ecx),%edx
  800bd8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bdb:	89 f3                	mov    %esi,%ebx
  800bdd:	80 fb 09             	cmp    $0x9,%bl
  800be0:	77 08                	ja     800bea <strtol+0x8b>
			dig = *s - '0';
  800be2:	0f be d2             	movsbl %dl,%edx
  800be5:	83 ea 30             	sub    $0x30,%edx
  800be8:	eb 22                	jmp    800c0c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bea:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bed:	89 f3                	mov    %esi,%ebx
  800bef:	80 fb 19             	cmp    $0x19,%bl
  800bf2:	77 08                	ja     800bfc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bf4:	0f be d2             	movsbl %dl,%edx
  800bf7:	83 ea 57             	sub    $0x57,%edx
  800bfa:	eb 10                	jmp    800c0c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bfc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 19             	cmp    $0x19,%bl
  800c04:	77 16                	ja     800c1c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c06:	0f be d2             	movsbl %dl,%edx
  800c09:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c0c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0f:	7d 0b                	jge    800c1c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c11:	83 c1 01             	add    $0x1,%ecx
  800c14:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c18:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c1a:	eb b9                	jmp    800bd5 <strtol+0x76>

	if (endptr)
  800c1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c20:	74 0d                	je     800c2f <strtol+0xd0>
		*endptr = (char *) s;
  800c22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c25:	89 0e                	mov    %ecx,(%esi)
  800c27:	eb 06                	jmp    800c2f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c29:	85 db                	test   %ebx,%ebx
  800c2b:	74 98                	je     800bc5 <strtol+0x66>
  800c2d:	eb 9e                	jmp    800bcd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c2f:	89 c2                	mov    %eax,%edx
  800c31:	f7 da                	neg    %edx
  800c33:	85 ff                	test   %edi,%edi
  800c35:	0f 45 c2             	cmovne %edx,%eax
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	89 c3                	mov    %eax,%ebx
  800c50:	89 c7                	mov    %eax,%edi
  800c52:	89 c6                	mov    %eax,%esi
  800c54:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	ba 00 00 00 00       	mov    $0x0,%edx
  800c66:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6b:	89 d1                	mov    %edx,%ecx
  800c6d:	89 d3                	mov    %edx,%ebx
  800c6f:	89 d7                	mov    %edx,%edi
  800c71:	89 d6                	mov    %edx,%esi
  800c73:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c88:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	89 cb                	mov    %ecx,%ebx
  800c92:	89 cf                	mov    %ecx,%edi
  800c94:	89 ce                	mov    %ecx,%esi
  800c96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	7e 17                	jle    800cb3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	50                   	push   %eax
  800ca0:	6a 03                	push   $0x3
  800ca2:	68 1f 27 80 00       	push   $0x80271f
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 3c 27 80 00       	push   $0x80273c
  800cae:	e8 e5 f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ccb:	89 d1                	mov    %edx,%ecx
  800ccd:	89 d3                	mov    %edx,%ebx
  800ccf:	89 d7                	mov    %edx,%edi
  800cd1:	89 d6                	mov    %edx,%esi
  800cd3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_yield>:

void
sys_yield(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	be 00 00 00 00       	mov    $0x0,%esi
  800d07:	b8 04 00 00 00       	mov    $0x4,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d15:	89 f7                	mov    %esi,%edi
  800d17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 17                	jle    800d34 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 04                	push   $0x4
  800d23:	68 1f 27 80 00       	push   $0x80271f
  800d28:	6a 23                	push   $0x23
  800d2a:	68 3c 27 80 00       	push   $0x80273c
  800d2f:	e8 64 f5 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	b8 05 00 00 00       	mov    $0x5,%eax
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d53:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d56:	8b 75 18             	mov    0x18(%ebp),%esi
  800d59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 17                	jle    800d76 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	50                   	push   %eax
  800d63:	6a 05                	push   $0x5
  800d65:	68 1f 27 80 00       	push   $0x80271f
  800d6a:	6a 23                	push   $0x23
  800d6c:	68 3c 27 80 00       	push   $0x80273c
  800d71:	e8 22 f5 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	89 df                	mov    %ebx,%edi
  800d99:	89 de                	mov    %ebx,%esi
  800d9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	7e 17                	jle    800db8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	50                   	push   %eax
  800da5:	6a 06                	push   $0x6
  800da7:	68 1f 27 80 00       	push   $0x80271f
  800dac:	6a 23                	push   $0x23
  800dae:	68 3c 27 80 00       	push   $0x80273c
  800db3:	e8 e0 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dce:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 de                	mov    %ebx,%esi
  800ddd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 17                	jle    800dfa <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	50                   	push   %eax
  800de7:	6a 08                	push   $0x8
  800de9:	68 1f 27 80 00       	push   $0x80271f
  800dee:	6a 23                	push   $0x23
  800df0:	68 3c 27 80 00       	push   $0x80273c
  800df5:	e8 9e f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e10:	b8 09 00 00 00       	mov    $0x9,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 df                	mov    %ebx,%edi
  800e1d:	89 de                	mov    %ebx,%esi
  800e1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	7e 17                	jle    800e3c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	50                   	push   %eax
  800e29:	6a 09                	push   $0x9
  800e2b:	68 1f 27 80 00       	push   $0x80271f
  800e30:	6a 23                	push   $0x23
  800e32:	68 3c 27 80 00       	push   $0x80273c
  800e37:	e8 5c f4 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 df                	mov    %ebx,%edi
  800e5f:	89 de                	mov    %ebx,%esi
  800e61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e63:	85 c0                	test   %eax,%eax
  800e65:	7e 17                	jle    800e7e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	50                   	push   %eax
  800e6b:	6a 0a                	push   $0xa
  800e6d:	68 1f 27 80 00       	push   $0x80271f
  800e72:	6a 23                	push   $0x23
  800e74:	68 3c 27 80 00       	push   $0x80273c
  800e79:	e8 1a f4 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	be 00 00 00 00       	mov    $0x0,%esi
  800e91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 cb                	mov    %ecx,%ebx
  800ec1:	89 cf                	mov    %ecx,%edi
  800ec3:	89 ce                	mov    %ecx,%esi
  800ec5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	7e 17                	jle    800ee2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	83 ec 0c             	sub    $0xc,%esp
  800ece:	50                   	push   %eax
  800ecf:	6a 0d                	push   $0xd
  800ed1:	68 1f 27 80 00       	push   $0x80271f
  800ed6:	6a 23                	push   $0x23
  800ed8:	68 3c 27 80 00       	push   $0x80273c
  800edd:	e8 b6 f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5f                   	pop    %edi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	53                   	push   %ebx
  800eee:	83 ec 04             	sub    $0x4,%esp
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  800ef4:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  800ef6:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  800ef9:	89 da                	mov    %ebx,%edx
  800efb:	c1 ea 0c             	shr    $0xc,%edx
  800efe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  800f05:	a8 02                	test   $0x2,%al
  800f07:	75 12                	jne    800f1b <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  800f09:	50                   	push   %eax
  800f0a:	68 4c 27 80 00       	push   $0x80274c
  800f0f:	6a 21                	push   $0x21
  800f11:	68 6d 27 80 00       	push   $0x80276d
  800f16:	e8 7d f3 ff ff       	call   800298 <_panic>
	   } else if (!(pte & PTE_COW)) {
  800f1b:	f6 c6 08             	test   $0x8,%dh
  800f1e:	75 14                	jne    800f34 <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  800f20:	83 ec 04             	sub    $0x4,%esp
  800f23:	68 78 27 80 00       	push   $0x802778
  800f28:	6a 23                	push   $0x23
  800f2a:	68 6d 27 80 00       	push   $0x80276d
  800f2f:	e8 64 f3 ff ff       	call   800298 <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  800f34:	83 ec 04             	sub    $0x4,%esp
  800f37:	6a 07                	push   $0x7
  800f39:	68 00 00 40 00       	push   $0x400000
  800f3e:	6a 00                	push   $0x0
  800f40:	e8 b4 fd ff ff       	call   800cf9 <sys_page_alloc>
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	79 12                	jns    800f5e <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  800f4c:	50                   	push   %eax
  800f4d:	68 95 27 80 00       	push   $0x802795
  800f52:	6a 2e                	push   $0x2e
  800f54:	68 6d 27 80 00       	push   $0x80276d
  800f59:	e8 3a f3 ff ff       	call   800298 <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f5e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	68 00 10 00 00       	push   $0x1000
  800f6c:	53                   	push   %ebx
  800f6d:	68 00 00 40 00       	push   $0x400000
  800f72:	e8 11 fb ff ff       	call   800a88 <memmove>
	   if ((r = sys_page_map(0,
  800f77:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f7e:	53                   	push   %ebx
  800f7f:	6a 00                	push   $0x0
  800f81:	68 00 00 40 00       	push   $0x400000
  800f86:	6a 00                	push   $0x0
  800f88:	e8 af fd ff ff       	call   800d3c <sys_page_map>
  800f8d:	83 c4 20             	add    $0x20,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	79 12                	jns    800fa6 <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  800f94:	50                   	push   %eax
  800f95:	68 a8 27 80 00       	push   $0x8027a8
  800f9a:	6a 36                	push   $0x36
  800f9c:	68 6d 27 80 00       	push   $0x80276d
  800fa1:	e8 f2 f2 ff ff       	call   800298 <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  800fa6:	83 ec 08             	sub    $0x8,%esp
  800fa9:	68 00 00 40 00       	push   $0x400000
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 c9 fd ff ff       	call   800d7e <sys_page_unmap>
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	79 12                	jns    800fce <pgfault+0xe4>
			 panic("unmap %e", r);
  800fbc:	50                   	push   %eax
  800fbd:	68 b8 27 80 00       	push   $0x8027b8
  800fc2:	6a 39                	push   $0x39
  800fc4:	68 6d 27 80 00       	push   $0x80276d
  800fc9:	e8 ca f2 ff ff       	call   800298 <_panic>
	   }
}
  800fce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
  800fd9:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  800fdc:	68 ea 0e 80 00       	push   $0x800eea
  800fe1:	e8 1f 0f 00 00       	call   801f05 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fe6:	b8 07 00 00 00       	mov    $0x7,%eax
  800feb:	cd 30                	int    $0x30
  800fed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ff0:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	79 15                	jns    80100f <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  800ffa:	50                   	push   %eax
  800ffb:	68 c1 27 80 00       	push   $0x8027c1
  801000:	68 81 00 00 00       	push   $0x81
  801005:	68 6d 27 80 00       	push   $0x80276d
  80100a:	e8 89 f2 ff ff       	call   800298 <_panic>
  80100f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801016:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  80101a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80101e:	75 1c                	jne    80103c <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  801020:	e8 96 fc ff ff       	call   800cbb <sys_getenvid>
  801025:	25 ff 03 00 00       	and    $0x3ff,%eax
  80102a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80102d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801032:	a3 04 40 80 00       	mov    %eax,0x804004
			 return envid;
  801037:	e9 71 01 00 00       	jmp    8011ad <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  80103c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80103f:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  801046:	a8 01                	test   $0x1,%al
  801048:	0f 84 18 01 00 00    	je     801166 <fork+0x193>
  80104e:	89 fb                	mov    %edi,%ebx
  801050:	c1 e3 0a             	shl    $0xa,%ebx
  801053:	c1 e7 16             	shl    $0x16,%edi
  801056:	be 00 00 00 00       	mov    $0x0,%esi
  80105b:	e9 f4 00 00 00       	jmp    801154 <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  801060:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801066:	0f 84 dc 00 00 00    	je     801148 <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  80106c:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801072:	0f 87 cc 00 00 00    	ja     801144 <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  801078:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80107f:	a8 01                	test   $0x1,%al
  801081:	0f 84 c1 00 00 00    	je     801148 <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  801087:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  80108e:	a9 02 08 00 00       	test   $0x802,%eax
  801093:	74 05                	je     80109a <fork+0xc7>
  801095:	f6 c4 04             	test   $0x4,%ah
  801098:	74 3a                	je     8010d4 <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  80109a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010a0:	8b 52 48             	mov    0x48(%edx),%edx
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ab:	50                   	push   %eax
  8010ac:	57                   	push   %edi
  8010ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8010b0:	57                   	push   %edi
  8010b1:	52                   	push   %edx
  8010b2:	e8 85 fc ff ff       	call   800d3c <sys_page_map>
  8010b7:	83 c4 20             	add    $0x20,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	0f 89 86 00 00 00    	jns    801148 <fork+0x175>
				    panic("sys_page_map: %e", r);
  8010c2:	50                   	push   %eax
  8010c3:	68 d1 27 80 00       	push   $0x8027d1
  8010c8:	6a 52                	push   $0x52
  8010ca:	68 6d 27 80 00       	push   $0x80276d
  8010cf:	e8 c4 f1 ff ff       	call   800298 <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  8010d4:	25 05 06 00 00       	and    $0x605,%eax
  8010d9:	80 cc 08             	or     $0x8,%ah
  8010dc:	89 c1                	mov    %eax,%ecx
  8010de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8010e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e6:	8b 40 48             	mov    0x48(%eax),%eax
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	51                   	push   %ecx
  8010ed:	57                   	push   %edi
  8010ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8010f1:	57                   	push   %edi
  8010f2:	50                   	push   %eax
  8010f3:	e8 44 fc ff ff       	call   800d3c <sys_page_map>
  8010f8:	83 c4 20             	add    $0x20,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	79 12                	jns    801111 <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  8010ff:	50                   	push   %eax
  801100:	68 d1 27 80 00       	push   $0x8027d1
  801105:	6a 5d                	push   $0x5d
  801107:	68 6d 27 80 00       	push   $0x80276d
  80110c:	e8 87 f1 ff ff       	call   800298 <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  801111:	a1 04 40 80 00       	mov    0x804004,%eax
  801116:	8b 50 48             	mov    0x48(%eax),%edx
  801119:	8b 40 48             	mov    0x48(%eax),%eax
  80111c:	83 ec 0c             	sub    $0xc,%esp
  80111f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801122:	57                   	push   %edi
  801123:	52                   	push   %edx
  801124:	57                   	push   %edi
  801125:	50                   	push   %eax
  801126:	e8 11 fc ff ff       	call   800d3c <sys_page_map>
  80112b:	83 c4 20             	add    $0x20,%esp
  80112e:	85 c0                	test   %eax,%eax
  801130:	79 16                	jns    801148 <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  801132:	50                   	push   %eax
  801133:	68 d1 27 80 00       	push   $0x8027d1
  801138:	6a 63                	push   $0x63
  80113a:	68 6d 27 80 00       	push   $0x80276d
  80113f:	e8 54 f1 ff ff       	call   800298 <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  801144:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  801148:	83 c6 01             	add    $0x1,%esi
  80114b:	83 c3 01             	add    $0x1,%ebx
  80114e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801154:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  80115a:	7f 0a                	jg     801166 <fork+0x193>
  80115c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801160:	0f 85 fa fe ff ff    	jne    801060 <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  801166:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  80116a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80116d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801172:	7f 0a                	jg     80117e <fork+0x1ab>
  801174:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801178:	0f 85 be fe ff ff    	jne    80103c <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80117e:	83 ec 08             	sub    $0x8,%esp
  801181:	68 5e 1f 80 00       	push   $0x801f5e
  801186:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801189:	56                   	push   %esi
  80118a:	e8 b5 fc ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  80118f:	83 c4 0c             	add    $0xc,%esp
  801192:	6a 06                	push   $0x6
  801194:	68 00 f0 bf ee       	push   $0xeebff000
  801199:	56                   	push   %esi
  80119a:	e8 5a fb ff ff       	call   800cf9 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  80119f:	83 c4 08             	add    $0x8,%esp
  8011a2:	6a 02                	push   $0x2
  8011a4:	56                   	push   %esi
  8011a5:	e8 16 fc ff ff       	call   800dc0 <sys_env_set_status>

	   return envid;
  8011aa:	83 c4 10             	add    $0x10,%esp
}
  8011ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8011b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b3:	5b                   	pop    %ebx
  8011b4:	5e                   	pop    %esi
  8011b5:	5f                   	pop    %edi
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <sfork>:
// Challenge!
	   int
sfork(void)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  8011be:	68 e2 27 80 00       	push   $0x8027e2
  8011c3:	68 a7 00 00 00       	push   $0xa7
  8011c8:	68 6d 27 80 00       	push   $0x80276d
  8011cd:	e8 c6 f0 ff ff       	call   800298 <_panic>

008011d2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011dd:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ff:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801204:	89 c2                	mov    %eax,%edx
  801206:	c1 ea 16             	shr    $0x16,%edx
  801209:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801210:	f6 c2 01             	test   $0x1,%dl
  801213:	74 11                	je     801226 <fd_alloc+0x2d>
  801215:	89 c2                	mov    %eax,%edx
  801217:	c1 ea 0c             	shr    $0xc,%edx
  80121a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801221:	f6 c2 01             	test   $0x1,%dl
  801224:	75 09                	jne    80122f <fd_alloc+0x36>
			*fd_store = fd;
  801226:	89 01                	mov    %eax,(%ecx)
			return 0;
  801228:	b8 00 00 00 00       	mov    $0x0,%eax
  80122d:	eb 17                	jmp    801246 <fd_alloc+0x4d>
  80122f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801234:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801239:	75 c9                	jne    801204 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80123b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801241:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80124e:	83 f8 1f             	cmp    $0x1f,%eax
  801251:	77 36                	ja     801289 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801253:	c1 e0 0c             	shl    $0xc,%eax
  801256:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	c1 ea 16             	shr    $0x16,%edx
  801260:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801267:	f6 c2 01             	test   $0x1,%dl
  80126a:	74 24                	je     801290 <fd_lookup+0x48>
  80126c:	89 c2                	mov    %eax,%edx
  80126e:	c1 ea 0c             	shr    $0xc,%edx
  801271:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801278:	f6 c2 01             	test   $0x1,%dl
  80127b:	74 1a                	je     801297 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80127d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801280:	89 02                	mov    %eax,(%edx)
	return 0;
  801282:	b8 00 00 00 00       	mov    $0x0,%eax
  801287:	eb 13                	jmp    80129c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801289:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128e:	eb 0c                	jmp    80129c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801290:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801295:	eb 05                	jmp    80129c <fd_lookup+0x54>
  801297:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a7:	ba 78 28 80 00       	mov    $0x802878,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ac:	eb 13                	jmp    8012c1 <dev_lookup+0x23>
  8012ae:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012b1:	39 08                	cmp    %ecx,(%eax)
  8012b3:	75 0c                	jne    8012c1 <dev_lookup+0x23>
			*dev = devtab[i];
  8012b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bf:	eb 2e                	jmp    8012ef <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c1:	8b 02                	mov    (%edx),%eax
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	75 e7                	jne    8012ae <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8012cc:	8b 40 48             	mov    0x48(%eax),%eax
  8012cf:	83 ec 04             	sub    $0x4,%esp
  8012d2:	51                   	push   %ecx
  8012d3:	50                   	push   %eax
  8012d4:	68 f8 27 80 00       	push   $0x8027f8
  8012d9:	e8 93 f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  8012de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ef:	c9                   	leave  
  8012f0:	c3                   	ret    

008012f1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	56                   	push   %esi
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 10             	sub    $0x10,%esp
  8012f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801302:	50                   	push   %eax
  801303:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801309:	c1 e8 0c             	shr    $0xc,%eax
  80130c:	50                   	push   %eax
  80130d:	e8 36 ff ff ff       	call   801248 <fd_lookup>
  801312:	83 c4 08             	add    $0x8,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 05                	js     80131e <fd_close+0x2d>
	    || fd != fd2)
  801319:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80131c:	74 0c                	je     80132a <fd_close+0x39>
		return (must_exist ? r : 0);
  80131e:	84 db                	test   %bl,%bl
  801320:	ba 00 00 00 00       	mov    $0x0,%edx
  801325:	0f 44 c2             	cmove  %edx,%eax
  801328:	eb 41                	jmp    80136b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	ff 36                	pushl  (%esi)
  801333:	e8 66 ff ff ff       	call   80129e <dev_lookup>
  801338:	89 c3                	mov    %eax,%ebx
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 1a                	js     80135b <fd_close+0x6a>
		if (dev->dev_close)
  801341:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801344:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801347:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80134c:	85 c0                	test   %eax,%eax
  80134e:	74 0b                	je     80135b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801350:	83 ec 0c             	sub    $0xc,%esp
  801353:	56                   	push   %esi
  801354:	ff d0                	call   *%eax
  801356:	89 c3                	mov    %eax,%ebx
  801358:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	56                   	push   %esi
  80135f:	6a 00                	push   $0x0
  801361:	e8 18 fa ff ff       	call   800d7e <sys_page_unmap>
	return r;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	89 d8                	mov    %ebx,%eax
}
  80136b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5e                   	pop    %esi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801378:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	ff 75 08             	pushl  0x8(%ebp)
  80137f:	e8 c4 fe ff ff       	call   801248 <fd_lookup>
  801384:	83 c4 08             	add    $0x8,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	78 10                	js     80139b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80138b:	83 ec 08             	sub    $0x8,%esp
  80138e:	6a 01                	push   $0x1
  801390:	ff 75 f4             	pushl  -0xc(%ebp)
  801393:	e8 59 ff ff ff       	call   8012f1 <fd_close>
  801398:	83 c4 10             	add    $0x10,%esp
}
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <close_all>:

void
close_all(void)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	53                   	push   %ebx
  8013a1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013a9:	83 ec 0c             	sub    $0xc,%esp
  8013ac:	53                   	push   %ebx
  8013ad:	e8 c0 ff ff ff       	call   801372 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b2:	83 c3 01             	add    $0x1,%ebx
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	83 fb 20             	cmp    $0x20,%ebx
  8013bb:	75 ec                	jne    8013a9 <close_all+0xc>
		close(i);
}
  8013bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c0:	c9                   	leave  
  8013c1:	c3                   	ret    

008013c2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	57                   	push   %edi
  8013c6:	56                   	push   %esi
  8013c7:	53                   	push   %ebx
  8013c8:	83 ec 2c             	sub    $0x2c,%esp
  8013cb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d1:	50                   	push   %eax
  8013d2:	ff 75 08             	pushl  0x8(%ebp)
  8013d5:	e8 6e fe ff ff       	call   801248 <fd_lookup>
  8013da:	83 c4 08             	add    $0x8,%esp
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	0f 88 c1 00 00 00    	js     8014a6 <dup+0xe4>
		return r;
	close(newfdnum);
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	56                   	push   %esi
  8013e9:	e8 84 ff ff ff       	call   801372 <close>

	newfd = INDEX2FD(newfdnum);
  8013ee:	89 f3                	mov    %esi,%ebx
  8013f0:	c1 e3 0c             	shl    $0xc,%ebx
  8013f3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013f9:	83 c4 04             	add    $0x4,%esp
  8013fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ff:	e8 de fd ff ff       	call   8011e2 <fd2data>
  801404:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801406:	89 1c 24             	mov    %ebx,(%esp)
  801409:	e8 d4 fd ff ff       	call   8011e2 <fd2data>
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801414:	89 f8                	mov    %edi,%eax
  801416:	c1 e8 16             	shr    $0x16,%eax
  801419:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801420:	a8 01                	test   $0x1,%al
  801422:	74 37                	je     80145b <dup+0x99>
  801424:	89 f8                	mov    %edi,%eax
  801426:	c1 e8 0c             	shr    $0xc,%eax
  801429:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801430:	f6 c2 01             	test   $0x1,%dl
  801433:	74 26                	je     80145b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801435:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143c:	83 ec 0c             	sub    $0xc,%esp
  80143f:	25 07 0e 00 00       	and    $0xe07,%eax
  801444:	50                   	push   %eax
  801445:	ff 75 d4             	pushl  -0x2c(%ebp)
  801448:	6a 00                	push   $0x0
  80144a:	57                   	push   %edi
  80144b:	6a 00                	push   $0x0
  80144d:	e8 ea f8 ff ff       	call   800d3c <sys_page_map>
  801452:	89 c7                	mov    %eax,%edi
  801454:	83 c4 20             	add    $0x20,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 2e                	js     801489 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80145e:	89 d0                	mov    %edx,%eax
  801460:	c1 e8 0c             	shr    $0xc,%eax
  801463:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146a:	83 ec 0c             	sub    $0xc,%esp
  80146d:	25 07 0e 00 00       	and    $0xe07,%eax
  801472:	50                   	push   %eax
  801473:	53                   	push   %ebx
  801474:	6a 00                	push   $0x0
  801476:	52                   	push   %edx
  801477:	6a 00                	push   $0x0
  801479:	e8 be f8 ff ff       	call   800d3c <sys_page_map>
  80147e:	89 c7                	mov    %eax,%edi
  801480:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801483:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801485:	85 ff                	test   %edi,%edi
  801487:	79 1d                	jns    8014a6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	53                   	push   %ebx
  80148d:	6a 00                	push   $0x0
  80148f:	e8 ea f8 ff ff       	call   800d7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801494:	83 c4 08             	add    $0x8,%esp
  801497:	ff 75 d4             	pushl  -0x2c(%ebp)
  80149a:	6a 00                	push   $0x0
  80149c:	e8 dd f8 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	89 f8                	mov    %edi,%eax
}
  8014a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a9:	5b                   	pop    %ebx
  8014aa:	5e                   	pop    %esi
  8014ab:	5f                   	pop    %edi
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	53                   	push   %ebx
  8014b2:	83 ec 14             	sub    $0x14,%esp
  8014b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	53                   	push   %ebx
  8014bd:	e8 86 fd ff ff       	call   801248 <fd_lookup>
  8014c2:	83 c4 08             	add    $0x8,%esp
  8014c5:	89 c2                	mov    %eax,%edx
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 6d                	js     801538 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d5:	ff 30                	pushl  (%eax)
  8014d7:	e8 c2 fd ff ff       	call   80129e <dev_lookup>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 4c                	js     80152f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e6:	8b 42 08             	mov    0x8(%edx),%eax
  8014e9:	83 e0 03             	and    $0x3,%eax
  8014ec:	83 f8 01             	cmp    $0x1,%eax
  8014ef:	75 21                	jne    801512 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8014f6:	8b 40 48             	mov    0x48(%eax),%eax
  8014f9:	83 ec 04             	sub    $0x4,%esp
  8014fc:	53                   	push   %ebx
  8014fd:	50                   	push   %eax
  8014fe:	68 3c 28 80 00       	push   $0x80283c
  801503:	e8 69 ee ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801510:	eb 26                	jmp    801538 <read+0x8a>
	}
	if (!dev->dev_read)
  801512:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801515:	8b 40 08             	mov    0x8(%eax),%eax
  801518:	85 c0                	test   %eax,%eax
  80151a:	74 17                	je     801533 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80151c:	83 ec 04             	sub    $0x4,%esp
  80151f:	ff 75 10             	pushl  0x10(%ebp)
  801522:	ff 75 0c             	pushl  0xc(%ebp)
  801525:	52                   	push   %edx
  801526:	ff d0                	call   *%eax
  801528:	89 c2                	mov    %eax,%edx
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	eb 09                	jmp    801538 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152f:	89 c2                	mov    %eax,%edx
  801531:	eb 05                	jmp    801538 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801533:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801538:	89 d0                	mov    %edx,%eax
  80153a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	57                   	push   %edi
  801543:	56                   	push   %esi
  801544:	53                   	push   %ebx
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801553:	eb 21                	jmp    801576 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	89 f0                	mov    %esi,%eax
  80155a:	29 d8                	sub    %ebx,%eax
  80155c:	50                   	push   %eax
  80155d:	89 d8                	mov    %ebx,%eax
  80155f:	03 45 0c             	add    0xc(%ebp),%eax
  801562:	50                   	push   %eax
  801563:	57                   	push   %edi
  801564:	e8 45 ff ff ff       	call   8014ae <read>
		if (m < 0)
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 10                	js     801580 <readn+0x41>
			return m;
		if (m == 0)
  801570:	85 c0                	test   %eax,%eax
  801572:	74 0a                	je     80157e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801574:	01 c3                	add    %eax,%ebx
  801576:	39 f3                	cmp    %esi,%ebx
  801578:	72 db                	jb     801555 <readn+0x16>
  80157a:	89 d8                	mov    %ebx,%eax
  80157c:	eb 02                	jmp    801580 <readn+0x41>
  80157e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801580:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801583:	5b                   	pop    %ebx
  801584:	5e                   	pop    %esi
  801585:	5f                   	pop    %edi
  801586:	5d                   	pop    %ebp
  801587:	c3                   	ret    

00801588 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	53                   	push   %ebx
  80158c:	83 ec 14             	sub    $0x14,%esp
  80158f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801592:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	53                   	push   %ebx
  801597:	e8 ac fc ff ff       	call   801248 <fd_lookup>
  80159c:	83 c4 08             	add    $0x8,%esp
  80159f:	89 c2                	mov    %eax,%edx
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 68                	js     80160d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015af:	ff 30                	pushl  (%eax)
  8015b1:	e8 e8 fc ff ff       	call   80129e <dev_lookup>
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 47                	js     801604 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c4:	75 21                	jne    8015e7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8015cb:	8b 40 48             	mov    0x48(%eax),%eax
  8015ce:	83 ec 04             	sub    $0x4,%esp
  8015d1:	53                   	push   %ebx
  8015d2:	50                   	push   %eax
  8015d3:	68 58 28 80 00       	push   $0x802858
  8015d8:	e8 94 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e5:	eb 26                	jmp    80160d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ea:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ed:	85 d2                	test   %edx,%edx
  8015ef:	74 17                	je     801608 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f1:	83 ec 04             	sub    $0x4,%esp
  8015f4:	ff 75 10             	pushl  0x10(%ebp)
  8015f7:	ff 75 0c             	pushl  0xc(%ebp)
  8015fa:	50                   	push   %eax
  8015fb:	ff d2                	call   *%edx
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	eb 09                	jmp    80160d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801604:	89 c2                	mov    %eax,%edx
  801606:	eb 05                	jmp    80160d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801608:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80160d:	89 d0                	mov    %edx,%eax
  80160f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <seek>:

int
seek(int fdnum, off_t offset)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	ff 75 08             	pushl  0x8(%ebp)
  801621:	e8 22 fc ff ff       	call   801248 <fd_lookup>
  801626:	83 c4 08             	add    $0x8,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 0e                	js     80163b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80162d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801630:	8b 55 0c             	mov    0xc(%ebp),%edx
  801633:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801636:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    

0080163d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	53                   	push   %ebx
  801641:	83 ec 14             	sub    $0x14,%esp
  801644:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801647:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	53                   	push   %ebx
  80164c:	e8 f7 fb ff ff       	call   801248 <fd_lookup>
  801651:	83 c4 08             	add    $0x8,%esp
  801654:	89 c2                	mov    %eax,%edx
  801656:	85 c0                	test   %eax,%eax
  801658:	78 65                	js     8016bf <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801664:	ff 30                	pushl  (%eax)
  801666:	e8 33 fc ff ff       	call   80129e <dev_lookup>
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 44                	js     8016b6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801675:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801679:	75 21                	jne    80169c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80167b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801680:	8b 40 48             	mov    0x48(%eax),%eax
  801683:	83 ec 04             	sub    $0x4,%esp
  801686:	53                   	push   %ebx
  801687:	50                   	push   %eax
  801688:	68 18 28 80 00       	push   $0x802818
  80168d:	e8 df ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80169a:	eb 23                	jmp    8016bf <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80169c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169f:	8b 52 18             	mov    0x18(%edx),%edx
  8016a2:	85 d2                	test   %edx,%edx
  8016a4:	74 14                	je     8016ba <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ac:	50                   	push   %eax
  8016ad:	ff d2                	call   *%edx
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	eb 09                	jmp    8016bf <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	eb 05                	jmp    8016bf <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016bf:	89 d0                	mov    %edx,%eax
  8016c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 14             	sub    $0x14,%esp
  8016cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d3:	50                   	push   %eax
  8016d4:	ff 75 08             	pushl  0x8(%ebp)
  8016d7:	e8 6c fb ff ff       	call   801248 <fd_lookup>
  8016dc:	83 c4 08             	add    $0x8,%esp
  8016df:	89 c2                	mov    %eax,%edx
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 58                	js     80173d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ef:	ff 30                	pushl  (%eax)
  8016f1:	e8 a8 fb ff ff       	call   80129e <dev_lookup>
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 37                	js     801734 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801700:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801704:	74 32                	je     801738 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801706:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801709:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801710:	00 00 00 
	stat->st_isdir = 0;
  801713:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80171a:	00 00 00 
	stat->st_dev = dev;
  80171d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	53                   	push   %ebx
  801727:	ff 75 f0             	pushl  -0x10(%ebp)
  80172a:	ff 50 14             	call   *0x14(%eax)
  80172d:	89 c2                	mov    %eax,%edx
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	eb 09                	jmp    80173d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801734:	89 c2                	mov    %eax,%edx
  801736:	eb 05                	jmp    80173d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801738:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80173d:	89 d0                	mov    %edx,%eax
  80173f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	56                   	push   %esi
  801748:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	6a 00                	push   $0x0
  80174e:	ff 75 08             	pushl  0x8(%ebp)
  801751:	e8 2c 02 00 00       	call   801982 <open>
  801756:	89 c3                	mov    %eax,%ebx
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 1b                	js     80177a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	ff 75 0c             	pushl  0xc(%ebp)
  801765:	50                   	push   %eax
  801766:	e8 5b ff ff ff       	call   8016c6 <fstat>
  80176b:	89 c6                	mov    %eax,%esi
	close(fd);
  80176d:	89 1c 24             	mov    %ebx,(%esp)
  801770:	e8 fd fb ff ff       	call   801372 <close>
	return r;
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	89 f0                	mov    %esi,%eax
}
  80177a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177d:	5b                   	pop    %ebx
  80177e:	5e                   	pop    %esi
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	89 c6                	mov    %eax,%esi
  801788:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  80178a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801791:	75 12                	jne    8017a5 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  801793:	83 ec 0c             	sub    $0xc,%esp
  801796:	6a 01                	push   $0x1
  801798:	e8 9a 08 00 00       	call   802037 <ipc_find_env>
  80179d:	a3 00 40 80 00       	mov    %eax,0x804000
  8017a2:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a5:	6a 07                	push   $0x7
  8017a7:	68 00 50 80 00       	push   $0x805000
  8017ac:	56                   	push   %esi
  8017ad:	ff 35 00 40 80 00    	pushl  0x804000
  8017b3:	e8 2b 08 00 00       	call   801fe3 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  8017b8:	83 c4 0c             	add    $0xc,%esp
  8017bb:	6a 00                	push   $0x0
  8017bd:	53                   	push   %ebx
  8017be:	6a 00                	push   $0x0
  8017c0:	e8 bf 07 00 00       	call   801f84 <ipc_recv>
}
  8017c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c8:	5b                   	pop    %ebx
  8017c9:	5e                   	pop    %esi
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d8:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  8017dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e0:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  8017e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ea:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ef:	e8 8d ff ff ff       	call   801781 <fsipc>
}
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801802:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  801807:	ba 00 00 00 00       	mov    $0x0,%edx
  80180c:	b8 06 00 00 00       	mov    $0x6,%eax
  801811:	e8 6b ff ff ff       	call   801781 <fsipc>
}
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	53                   	push   %ebx
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801822:	8b 45 08             	mov    0x8(%ebp),%eax
  801825:	8b 40 0c             	mov    0xc(%eax),%eax
  801828:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80182d:	ba 00 00 00 00       	mov    $0x0,%edx
  801832:	b8 05 00 00 00       	mov    $0x5,%eax
  801837:	e8 45 ff ff ff       	call   801781 <fsipc>
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 2c                	js     80186c <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	68 00 50 80 00       	push   $0x805000
  801848:	53                   	push   %ebx
  801849:	e8 a8 f0 ff ff       	call   8008f6 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  80184e:	a1 80 50 80 00       	mov    0x805080,%eax
  801853:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801859:	a1 84 50 80 00       	mov    0x805084,%eax
  80185e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186f:	c9                   	leave  
  801870:	c3                   	ret    

00801871 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	53                   	push   %ebx
  801875:	83 ec 08             	sub    $0x8,%esp
  801878:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  80187b:	8b 45 08             	mov    0x8(%ebp),%eax
  80187e:	8b 40 0c             	mov    0xc(%eax),%eax
  801881:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  801886:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  80188c:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801892:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801897:	0f 46 c3             	cmovbe %ebx,%eax
  80189a:	50                   	push   %eax
  80189b:	ff 75 0c             	pushl  0xc(%ebp)
  80189e:	68 08 50 80 00       	push   $0x805008
  8018a3:	e8 e0 f1 ff ff       	call   800a88 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  8018a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ad:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b2:	e8 ca fe ff ff       	call   801781 <fsipc>
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 3d                	js     8018fb <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  8018be:	39 c3                	cmp    %eax,%ebx
  8018c0:	73 19                	jae    8018db <devfile_write+0x6a>
  8018c2:	68 88 28 80 00       	push   $0x802888
  8018c7:	68 8f 28 80 00       	push   $0x80288f
  8018cc:	68 9a 00 00 00       	push   $0x9a
  8018d1:	68 a4 28 80 00       	push   $0x8028a4
  8018d6:	e8 bd e9 ff ff       	call   800298 <_panic>
	   assert (r <= bytes_written);
  8018db:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018e0:	7e 19                	jle    8018fb <devfile_write+0x8a>
  8018e2:	68 af 28 80 00       	push   $0x8028af
  8018e7:	68 8f 28 80 00       	push   $0x80288f
  8018ec:	68 9b 00 00 00       	push   $0x9b
  8018f1:	68 a4 28 80 00       	push   $0x8028a4
  8018f6:	e8 9d e9 ff ff       	call   800298 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  8018fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	56                   	push   %esi
  801904:	53                   	push   %ebx
  801905:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  801908:	8b 45 08             	mov    0x8(%ebp),%eax
  80190b:	8b 40 0c             	mov    0xc(%eax),%eax
  80190e:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  801913:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801919:	ba 00 00 00 00       	mov    $0x0,%edx
  80191e:	b8 03 00 00 00       	mov    $0x3,%eax
  801923:	e8 59 fe ff ff       	call   801781 <fsipc>
  801928:	89 c3                	mov    %eax,%ebx
  80192a:	85 c0                	test   %eax,%eax
  80192c:	78 4b                	js     801979 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  80192e:	39 c6                	cmp    %eax,%esi
  801930:	73 16                	jae    801948 <devfile_read+0x48>
  801932:	68 88 28 80 00       	push   $0x802888
  801937:	68 8f 28 80 00       	push   $0x80288f
  80193c:	6a 7c                	push   $0x7c
  80193e:	68 a4 28 80 00       	push   $0x8028a4
  801943:	e8 50 e9 ff ff       	call   800298 <_panic>
	   assert(r <= PGSIZE);
  801948:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80194d:	7e 16                	jle    801965 <devfile_read+0x65>
  80194f:	68 c2 28 80 00       	push   $0x8028c2
  801954:	68 8f 28 80 00       	push   $0x80288f
  801959:	6a 7d                	push   $0x7d
  80195b:	68 a4 28 80 00       	push   $0x8028a4
  801960:	e8 33 e9 ff ff       	call   800298 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801965:	83 ec 04             	sub    $0x4,%esp
  801968:	50                   	push   %eax
  801969:	68 00 50 80 00       	push   $0x805000
  80196e:	ff 75 0c             	pushl  0xc(%ebp)
  801971:	e8 12 f1 ff ff       	call   800a88 <memmove>
	   return r;
  801976:	83 c4 10             	add    $0x10,%esp
}
  801979:	89 d8                	mov    %ebx,%eax
  80197b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197e:	5b                   	pop    %ebx
  80197f:	5e                   	pop    %esi
  801980:	5d                   	pop    %ebp
  801981:	c3                   	ret    

00801982 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	53                   	push   %ebx
  801986:	83 ec 20             	sub    $0x20,%esp
  801989:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  80198c:	53                   	push   %ebx
  80198d:	e8 2b ef ff ff       	call   8008bd <strlen>
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80199a:	7f 67                	jg     801a03 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  80199c:	83 ec 0c             	sub    $0xc,%esp
  80199f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a2:	50                   	push   %eax
  8019a3:	e8 51 f8 ff ff       	call   8011f9 <fd_alloc>
  8019a8:	83 c4 10             	add    $0x10,%esp
			 return r;
  8019ab:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	78 57                	js     801a08 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  8019b1:	83 ec 08             	sub    $0x8,%esp
  8019b4:	53                   	push   %ebx
  8019b5:	68 00 50 80 00       	push   $0x805000
  8019ba:	e8 37 ef ff ff       	call   8008f6 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  8019bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c2:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8019cf:	e8 ad fd ff ff       	call   801781 <fsipc>
  8019d4:	89 c3                	mov    %eax,%ebx
  8019d6:	83 c4 10             	add    $0x10,%esp
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	79 14                	jns    8019f1 <open+0x6f>
			 fd_close(fd, 0);
  8019dd:	83 ec 08             	sub    $0x8,%esp
  8019e0:	6a 00                	push   $0x0
  8019e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e5:	e8 07 f9 ff ff       	call   8012f1 <fd_close>
			 return r;
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	89 da                	mov    %ebx,%edx
  8019ef:	eb 17                	jmp    801a08 <open+0x86>
	   }

	   return fd2num(fd);
  8019f1:	83 ec 0c             	sub    $0xc,%esp
  8019f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f7:	e8 d6 f7 ff ff       	call   8011d2 <fd2num>
  8019fc:	89 c2                	mov    %eax,%edx
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	eb 05                	jmp    801a08 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  801a03:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801a08:	89 d0                	mov    %edx,%eax
  801a0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801a15:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1a:	b8 08 00 00 00       	mov    $0x8,%eax
  801a1f:	e8 5d fd ff ff       	call   801781 <fsipc>
}
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	56                   	push   %esi
  801a2a:	53                   	push   %ebx
  801a2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	ff 75 08             	pushl  0x8(%ebp)
  801a34:	e8 a9 f7 ff ff       	call   8011e2 <fd2data>
  801a39:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a3b:	83 c4 08             	add    $0x8,%esp
  801a3e:	68 ce 28 80 00       	push   $0x8028ce
  801a43:	53                   	push   %ebx
  801a44:	e8 ad ee ff ff       	call   8008f6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a49:	8b 46 04             	mov    0x4(%esi),%eax
  801a4c:	2b 06                	sub    (%esi),%eax
  801a4e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a54:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a5b:	00 00 00 
	stat->st_dev = &devpipe;
  801a5e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a65:	30 80 00 
	return 0;
}
  801a68:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a70:	5b                   	pop    %ebx
  801a71:	5e                   	pop    %esi
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    

00801a74 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	53                   	push   %ebx
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a7e:	53                   	push   %ebx
  801a7f:	6a 00                	push   $0x0
  801a81:	e8 f8 f2 ff ff       	call   800d7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a86:	89 1c 24             	mov    %ebx,(%esp)
  801a89:	e8 54 f7 ff ff       	call   8011e2 <fd2data>
  801a8e:	83 c4 08             	add    $0x8,%esp
  801a91:	50                   	push   %eax
  801a92:	6a 00                	push   $0x0
  801a94:	e8 e5 f2 ff ff       	call   800d7e <sys_page_unmap>
}
  801a99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	57                   	push   %edi
  801aa2:	56                   	push   %esi
  801aa3:	53                   	push   %ebx
  801aa4:	83 ec 1c             	sub    $0x1c,%esp
  801aa7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aaa:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aac:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ab4:	83 ec 0c             	sub    $0xc,%esp
  801ab7:	ff 75 e0             	pushl  -0x20(%ebp)
  801aba:	e8 b1 05 00 00       	call   802070 <pageref>
  801abf:	89 c3                	mov    %eax,%ebx
  801ac1:	89 3c 24             	mov    %edi,(%esp)
  801ac4:	e8 a7 05 00 00       	call   802070 <pageref>
  801ac9:	83 c4 10             	add    $0x10,%esp
  801acc:	39 c3                	cmp    %eax,%ebx
  801ace:	0f 94 c1             	sete   %cl
  801ad1:	0f b6 c9             	movzbl %cl,%ecx
  801ad4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ad7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801add:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ae0:	39 ce                	cmp    %ecx,%esi
  801ae2:	74 1b                	je     801aff <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ae4:	39 c3                	cmp    %eax,%ebx
  801ae6:	75 c4                	jne    801aac <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae8:	8b 42 58             	mov    0x58(%edx),%eax
  801aeb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aee:	50                   	push   %eax
  801aef:	56                   	push   %esi
  801af0:	68 d5 28 80 00       	push   $0x8028d5
  801af5:	e8 77 e8 ff ff       	call   800371 <cprintf>
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	eb ad                	jmp    801aac <_pipeisclosed+0xe>
	}
}
  801aff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b05:	5b                   	pop    %ebx
  801b06:	5e                   	pop    %esi
  801b07:	5f                   	pop    %edi
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	57                   	push   %edi
  801b0e:	56                   	push   %esi
  801b0f:	53                   	push   %ebx
  801b10:	83 ec 28             	sub    $0x28,%esp
  801b13:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b16:	56                   	push   %esi
  801b17:	e8 c6 f6 ff ff       	call   8011e2 <fd2data>
  801b1c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1e:	83 c4 10             	add    $0x10,%esp
  801b21:	bf 00 00 00 00       	mov    $0x0,%edi
  801b26:	eb 4b                	jmp    801b73 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b28:	89 da                	mov    %ebx,%edx
  801b2a:	89 f0                	mov    %esi,%eax
  801b2c:	e8 6d ff ff ff       	call   801a9e <_pipeisclosed>
  801b31:	85 c0                	test   %eax,%eax
  801b33:	75 48                	jne    801b7d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b35:	e8 a0 f1 ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b3a:	8b 43 04             	mov    0x4(%ebx),%eax
  801b3d:	8b 0b                	mov    (%ebx),%ecx
  801b3f:	8d 51 20             	lea    0x20(%ecx),%edx
  801b42:	39 d0                	cmp    %edx,%eax
  801b44:	73 e2                	jae    801b28 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b49:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b4d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b50:	89 c2                	mov    %eax,%edx
  801b52:	c1 fa 1f             	sar    $0x1f,%edx
  801b55:	89 d1                	mov    %edx,%ecx
  801b57:	c1 e9 1b             	shr    $0x1b,%ecx
  801b5a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b5d:	83 e2 1f             	and    $0x1f,%edx
  801b60:	29 ca                	sub    %ecx,%edx
  801b62:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b66:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b6a:	83 c0 01             	add    $0x1,%eax
  801b6d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b70:	83 c7 01             	add    $0x1,%edi
  801b73:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b76:	75 c2                	jne    801b3a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b78:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7b:	eb 05                	jmp    801b82 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b7d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5f                   	pop    %edi
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    

00801b8a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	57                   	push   %edi
  801b8e:	56                   	push   %esi
  801b8f:	53                   	push   %ebx
  801b90:	83 ec 18             	sub    $0x18,%esp
  801b93:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b96:	57                   	push   %edi
  801b97:	e8 46 f6 ff ff       	call   8011e2 <fd2data>
  801b9c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba6:	eb 3d                	jmp    801be5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ba8:	85 db                	test   %ebx,%ebx
  801baa:	74 04                	je     801bb0 <devpipe_read+0x26>
				return i;
  801bac:	89 d8                	mov    %ebx,%eax
  801bae:	eb 44                	jmp    801bf4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bb0:	89 f2                	mov    %esi,%edx
  801bb2:	89 f8                	mov    %edi,%eax
  801bb4:	e8 e5 fe ff ff       	call   801a9e <_pipeisclosed>
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	75 32                	jne    801bef <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bbd:	e8 18 f1 ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bc2:	8b 06                	mov    (%esi),%eax
  801bc4:	3b 46 04             	cmp    0x4(%esi),%eax
  801bc7:	74 df                	je     801ba8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc9:	99                   	cltd   
  801bca:	c1 ea 1b             	shr    $0x1b,%edx
  801bcd:	01 d0                	add    %edx,%eax
  801bcf:	83 e0 1f             	and    $0x1f,%eax
  801bd2:	29 d0                	sub    %edx,%eax
  801bd4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bdc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bdf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be2:	83 c3 01             	add    $0x1,%ebx
  801be5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801be8:	75 d8                	jne    801bc2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bea:	8b 45 10             	mov    0x10(%ebp),%eax
  801bed:	eb 05                	jmp    801bf4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bef:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf7:	5b                   	pop    %ebx
  801bf8:	5e                   	pop    %esi
  801bf9:	5f                   	pop    %edi
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c07:	50                   	push   %eax
  801c08:	e8 ec f5 ff ff       	call   8011f9 <fd_alloc>
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	89 c2                	mov    %eax,%edx
  801c12:	85 c0                	test   %eax,%eax
  801c14:	0f 88 2c 01 00 00    	js     801d46 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1a:	83 ec 04             	sub    $0x4,%esp
  801c1d:	68 07 04 00 00       	push   $0x407
  801c22:	ff 75 f4             	pushl  -0xc(%ebp)
  801c25:	6a 00                	push   $0x0
  801c27:	e8 cd f0 ff ff       	call   800cf9 <sys_page_alloc>
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	89 c2                	mov    %eax,%edx
  801c31:	85 c0                	test   %eax,%eax
  801c33:	0f 88 0d 01 00 00    	js     801d46 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c39:	83 ec 0c             	sub    $0xc,%esp
  801c3c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c3f:	50                   	push   %eax
  801c40:	e8 b4 f5 ff ff       	call   8011f9 <fd_alloc>
  801c45:	89 c3                	mov    %eax,%ebx
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	0f 88 e2 00 00 00    	js     801d34 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c52:	83 ec 04             	sub    $0x4,%esp
  801c55:	68 07 04 00 00       	push   $0x407
  801c5a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c5d:	6a 00                	push   $0x0
  801c5f:	e8 95 f0 ff ff       	call   800cf9 <sys_page_alloc>
  801c64:	89 c3                	mov    %eax,%ebx
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	0f 88 c3 00 00 00    	js     801d34 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	ff 75 f4             	pushl  -0xc(%ebp)
  801c77:	e8 66 f5 ff ff       	call   8011e2 <fd2data>
  801c7c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7e:	83 c4 0c             	add    $0xc,%esp
  801c81:	68 07 04 00 00       	push   $0x407
  801c86:	50                   	push   %eax
  801c87:	6a 00                	push   $0x0
  801c89:	e8 6b f0 ff ff       	call   800cf9 <sys_page_alloc>
  801c8e:	89 c3                	mov    %eax,%ebx
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	85 c0                	test   %eax,%eax
  801c95:	0f 88 89 00 00 00    	js     801d24 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9b:	83 ec 0c             	sub    $0xc,%esp
  801c9e:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca1:	e8 3c f5 ff ff       	call   8011e2 <fd2data>
  801ca6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cad:	50                   	push   %eax
  801cae:	6a 00                	push   $0x0
  801cb0:	56                   	push   %esi
  801cb1:	6a 00                	push   $0x0
  801cb3:	e8 84 f0 ff ff       	call   800d3c <sys_page_map>
  801cb8:	89 c3                	mov    %eax,%ebx
  801cba:	83 c4 20             	add    $0x20,%esp
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	78 55                	js     801d16 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cc1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cca:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cd6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cdf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf1:	e8 dc f4 ff ff       	call   8011d2 <fd2num>
  801cf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cfb:	83 c4 04             	add    $0x4,%esp
  801cfe:	ff 75 f0             	pushl  -0x10(%ebp)
  801d01:	e8 cc f4 ff ff       	call   8011d2 <fd2num>
  801d06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d09:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d0c:	83 c4 10             	add    $0x10,%esp
  801d0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d14:	eb 30                	jmp    801d46 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d16:	83 ec 08             	sub    $0x8,%esp
  801d19:	56                   	push   %esi
  801d1a:	6a 00                	push   $0x0
  801d1c:	e8 5d f0 ff ff       	call   800d7e <sys_page_unmap>
  801d21:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d24:	83 ec 08             	sub    $0x8,%esp
  801d27:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2a:	6a 00                	push   $0x0
  801d2c:	e8 4d f0 ff ff       	call   800d7e <sys_page_unmap>
  801d31:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d34:	83 ec 08             	sub    $0x8,%esp
  801d37:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3a:	6a 00                	push   $0x0
  801d3c:	e8 3d f0 ff ff       	call   800d7e <sys_page_unmap>
  801d41:	83 c4 10             	add    $0x10,%esp
  801d44:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d46:	89 d0                	mov    %edx,%eax
  801d48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4b:	5b                   	pop    %ebx
  801d4c:	5e                   	pop    %esi
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    

00801d4f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d58:	50                   	push   %eax
  801d59:	ff 75 08             	pushl  0x8(%ebp)
  801d5c:	e8 e7 f4 ff ff       	call   801248 <fd_lookup>
  801d61:	83 c4 10             	add    $0x10,%esp
  801d64:	85 c0                	test   %eax,%eax
  801d66:	78 18                	js     801d80 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d68:	83 ec 0c             	sub    $0xc,%esp
  801d6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6e:	e8 6f f4 ff ff       	call   8011e2 <fd2data>
	return _pipeisclosed(fd, p);
  801d73:	89 c2                	mov    %eax,%edx
  801d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d78:	e8 21 fd ff ff       	call   801a9e <_pipeisclosed>
  801d7d:	83 c4 10             	add    $0x10,%esp
}
  801d80:	c9                   	leave  
  801d81:	c3                   	ret    

00801d82 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d85:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d92:	68 e8 28 80 00       	push   $0x8028e8
  801d97:	ff 75 0c             	pushl  0xc(%ebp)
  801d9a:	e8 57 eb ff ff       	call   8008f6 <strcpy>
	return 0;
}
  801d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    

00801da6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	57                   	push   %edi
  801daa:	56                   	push   %esi
  801dab:	53                   	push   %ebx
  801dac:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbd:	eb 2d                	jmp    801dec <devcons_write+0x46>
		m = n - tot;
  801dbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dc2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dc4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dc7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dcc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dcf:	83 ec 04             	sub    $0x4,%esp
  801dd2:	53                   	push   %ebx
  801dd3:	03 45 0c             	add    0xc(%ebp),%eax
  801dd6:	50                   	push   %eax
  801dd7:	57                   	push   %edi
  801dd8:	e8 ab ec ff ff       	call   800a88 <memmove>
		sys_cputs(buf, m);
  801ddd:	83 c4 08             	add    $0x8,%esp
  801de0:	53                   	push   %ebx
  801de1:	57                   	push   %edi
  801de2:	e8 56 ee ff ff       	call   800c3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de7:	01 de                	add    %ebx,%esi
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	89 f0                	mov    %esi,%eax
  801dee:	3b 75 10             	cmp    0x10(%ebp),%esi
  801df1:	72 cc                	jb     801dbf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801df3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df6:	5b                   	pop    %ebx
  801df7:	5e                   	pop    %esi
  801df8:	5f                   	pop    %edi
  801df9:	5d                   	pop    %ebp
  801dfa:	c3                   	ret    

00801dfb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	83 ec 08             	sub    $0x8,%esp
  801e01:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e0a:	74 2a                	je     801e36 <devcons_read+0x3b>
  801e0c:	eb 05                	jmp    801e13 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e0e:	e8 c7 ee ff ff       	call   800cda <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e13:	e8 43 ee ff ff       	call   800c5b <sys_cgetc>
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	74 f2                	je     801e0e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	78 16                	js     801e36 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e20:	83 f8 04             	cmp    $0x4,%eax
  801e23:	74 0c                	je     801e31 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e28:	88 02                	mov    %al,(%edx)
	return 1;
  801e2a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2f:	eb 05                	jmp    801e36 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e31:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e36:	c9                   	leave  
  801e37:	c3                   	ret    

00801e38 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e41:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e44:	6a 01                	push   $0x1
  801e46:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e49:	50                   	push   %eax
  801e4a:	e8 ee ed ff ff       	call   800c3d <sys_cputs>
}
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	c9                   	leave  
  801e53:	c3                   	ret    

00801e54 <getchar>:

int
getchar(void)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e5a:	6a 01                	push   $0x1
  801e5c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e5f:	50                   	push   %eax
  801e60:	6a 00                	push   $0x0
  801e62:	e8 47 f6 ff ff       	call   8014ae <read>
	if (r < 0)
  801e67:	83 c4 10             	add    $0x10,%esp
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	78 0f                	js     801e7d <getchar+0x29>
		return r;
	if (r < 1)
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	7e 06                	jle    801e78 <getchar+0x24>
		return -E_EOF;
	return c;
  801e72:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e76:	eb 05                	jmp    801e7d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e78:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e7d:	c9                   	leave  
  801e7e:	c3                   	ret    

00801e7f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e88:	50                   	push   %eax
  801e89:	ff 75 08             	pushl  0x8(%ebp)
  801e8c:	e8 b7 f3 ff ff       	call   801248 <fd_lookup>
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	85 c0                	test   %eax,%eax
  801e96:	78 11                	js     801ea9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea1:	39 10                	cmp    %edx,(%eax)
  801ea3:	0f 94 c0             	sete   %al
  801ea6:	0f b6 c0             	movzbl %al,%eax
}
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <opencons>:

int
opencons(void)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb4:	50                   	push   %eax
  801eb5:	e8 3f f3 ff ff       	call   8011f9 <fd_alloc>
  801eba:	83 c4 10             	add    $0x10,%esp
		return r;
  801ebd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	78 3e                	js     801f01 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec3:	83 ec 04             	sub    $0x4,%esp
  801ec6:	68 07 04 00 00       	push   $0x407
  801ecb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ece:	6a 00                	push   $0x0
  801ed0:	e8 24 ee ff ff       	call   800cf9 <sys_page_alloc>
  801ed5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eda:	85 c0                	test   %eax,%eax
  801edc:	78 23                	js     801f01 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ede:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eec:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ef3:	83 ec 0c             	sub    $0xc,%esp
  801ef6:	50                   	push   %eax
  801ef7:	e8 d6 f2 ff ff       	call   8011d2 <fd2num>
  801efc:	89 c2                	mov    %eax,%edx
  801efe:	83 c4 10             	add    $0x10,%esp
}
  801f01:	89 d0                	mov    %edx,%eax
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  801f0b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f12:	75 2a                	jne    801f3e <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801f14:	83 ec 04             	sub    $0x4,%esp
  801f17:	6a 06                	push   $0x6
  801f19:	68 00 f0 bf ee       	push   $0xeebff000
  801f1e:	6a 00                	push   $0x0
  801f20:	e8 d4 ed ff ff       	call   800cf9 <sys_page_alloc>
			 if (a < 0)
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	79 12                	jns    801f3e <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801f2c:	50                   	push   %eax
  801f2d:	68 f4 28 80 00       	push   $0x8028f4
  801f32:	6a 21                	push   $0x21
  801f34:	68 0e 29 80 00       	push   $0x80290e
  801f39:	e8 5a e3 ff ff       	call   800298 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  801f3e:	e8 78 ed ff ff       	call   800cbb <sys_getenvid>
  801f43:	83 ec 08             	sub    $0x8,%esp
  801f46:	68 5e 1f 80 00       	push   $0x801f5e
  801f4b:	50                   	push   %eax
  801f4c:	e8 f3 ee ff ff       	call   800e44 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  801f51:	8b 45 08             	mov    0x8(%ebp),%eax
  801f54:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f59:	83 c4 10             	add    $0x10,%esp
  801f5c:	c9                   	leave  
  801f5d:	c3                   	ret    

00801f5e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  801f5e:	54                   	push   %esp
movl _pgfault_handler, %eax
  801f5f:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  801f64:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  801f66:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  801f69:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  801f6d:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  801f71:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  801f74:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  801f78:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  801f7a:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  801f7d:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  801f7e:	83 c4 04             	add    $0x4,%esp
popfl
  801f81:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  801f82:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  801f83:	c3                   	ret    

00801f84 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	56                   	push   %esi
  801f88:	53                   	push   %ebx
  801f89:	8b 75 08             	mov    0x8(%ebp),%esi
  801f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801f92:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801f94:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f99:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801f9c:	83 ec 0c             	sub    $0xc,%esp
  801f9f:	50                   	push   %eax
  801fa0:	e8 04 ef ff ff       	call   800ea9 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	85 c0                	test   %eax,%eax
  801faa:	78 0e                	js     801fba <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801fac:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fb2:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801fb5:	8b 52 78             	mov    0x78(%edx),%edx
  801fb8:	eb 0a                	jmp    801fc4 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801fba:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801fbf:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801fc4:	85 f6                	test   %esi,%esi
  801fc6:	74 02                	je     801fca <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801fc8:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801fca:	85 db                	test   %ebx,%ebx
  801fcc:	74 02                	je     801fd0 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801fce:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	78 08                	js     801fdc <ipc_recv+0x58>
  801fd4:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd9:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801fdc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fdf:	5b                   	pop    %ebx
  801fe0:	5e                   	pop    %esi
  801fe1:	5d                   	pop    %ebp
  801fe2:	c3                   	ret    

00801fe3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	57                   	push   %edi
  801fe7:	56                   	push   %esi
  801fe8:	53                   	push   %ebx
  801fe9:	83 ec 0c             	sub    $0xc,%esp
  801fec:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fef:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ff2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801ff5:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801ff7:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801ffc:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801fff:	ff 75 14             	pushl  0x14(%ebp)
  802002:	53                   	push   %ebx
  802003:	56                   	push   %esi
  802004:	57                   	push   %edi
  802005:	e8 7c ee ff ff       	call   800e86 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  80200a:	83 c4 10             	add    $0x10,%esp
  80200d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802010:	75 07                	jne    802019 <ipc_send+0x36>
				    sys_yield();
  802012:	e8 c3 ec ff ff       	call   800cda <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  802017:	eb e6                	jmp    801fff <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  802019:	85 c0                	test   %eax,%eax
  80201b:	74 12                	je     80202f <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  80201d:	50                   	push   %eax
  80201e:	68 1c 29 80 00       	push   $0x80291c
  802023:	6a 4b                	push   $0x4b
  802025:	68 30 29 80 00       	push   $0x802930
  80202a:	e8 69 e2 ff ff       	call   800298 <_panic>
			 }
	   }
}
  80202f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802032:	5b                   	pop    %ebx
  802033:	5e                   	pop    %esi
  802034:	5f                   	pop    %edi
  802035:	5d                   	pop    %ebp
  802036:	c3                   	ret    

00802037 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  80203d:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  802042:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802045:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80204b:	8b 52 50             	mov    0x50(%edx),%edx
  80204e:	39 ca                	cmp    %ecx,%edx
  802050:	75 0d                	jne    80205f <ipc_find_env+0x28>
				    return envs[i].env_id;
  802052:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80205a:	8b 40 48             	mov    0x48(%eax),%eax
  80205d:	eb 0f                	jmp    80206e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  80205f:	83 c0 01             	add    $0x1,%eax
  802062:	3d 00 04 00 00       	cmp    $0x400,%eax
  802067:	75 d9                	jne    802042 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80206e:	5d                   	pop    %ebp
  80206f:	c3                   	ret    

00802070 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802076:	89 d0                	mov    %edx,%eax
  802078:	c1 e8 16             	shr    $0x16,%eax
  80207b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802082:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802087:	f6 c1 01             	test   $0x1,%cl
  80208a:	74 1d                	je     8020a9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80208c:	c1 ea 0c             	shr    $0xc,%edx
  80208f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802096:	f6 c2 01             	test   $0x1,%dl
  802099:	74 0e                	je     8020a9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80209b:	c1 ea 0c             	shr    $0xc,%edx
  80209e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020a5:	ef 
  8020a6:	0f b7 c0             	movzwl %ax,%eax
}
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    
  8020ab:	66 90                	xchg   %ax,%ax
  8020ad:	66 90                	xchg   %ax,%ax
  8020af:	90                   	nop

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 f6                	test   %esi,%esi
  8020c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020cd:	89 ca                	mov    %ecx,%edx
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	75 3d                	jne    802110 <__udivdi3+0x60>
  8020d3:	39 cf                	cmp    %ecx,%edi
  8020d5:	0f 87 c5 00 00 00    	ja     8021a0 <__udivdi3+0xf0>
  8020db:	85 ff                	test   %edi,%edi
  8020dd:	89 fd                	mov    %edi,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f7                	div    %edi
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 c8                	mov    %ecx,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	89 cf                	mov    %ecx,%edi
  8020f8:	f7 f5                	div    %ebp
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	39 ce                	cmp    %ecx,%esi
  802112:	77 74                	ja     802188 <__udivdi3+0xd8>
  802114:	0f bd fe             	bsr    %esi,%edi
  802117:	83 f7 1f             	xor    $0x1f,%edi
  80211a:	0f 84 98 00 00 00    	je     8021b8 <__udivdi3+0x108>
  802120:	bb 20 00 00 00       	mov    $0x20,%ebx
  802125:	89 f9                	mov    %edi,%ecx
  802127:	89 c5                	mov    %eax,%ebp
  802129:	29 fb                	sub    %edi,%ebx
  80212b:	d3 e6                	shl    %cl,%esi
  80212d:	89 d9                	mov    %ebx,%ecx
  80212f:	d3 ed                	shr    %cl,%ebp
  802131:	89 f9                	mov    %edi,%ecx
  802133:	d3 e0                	shl    %cl,%eax
  802135:	09 ee                	or     %ebp,%esi
  802137:	89 d9                	mov    %ebx,%ecx
  802139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213d:	89 d5                	mov    %edx,%ebp
  80213f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802143:	d3 ed                	shr    %cl,%ebp
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e2                	shl    %cl,%edx
  802149:	89 d9                	mov    %ebx,%ecx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	09 c2                	or     %eax,%edx
  80214f:	89 d0                	mov    %edx,%eax
  802151:	89 ea                	mov    %ebp,%edx
  802153:	f7 f6                	div    %esi
  802155:	89 d5                	mov    %edx,%ebp
  802157:	89 c3                	mov    %eax,%ebx
  802159:	f7 64 24 0c          	mull   0xc(%esp)
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	72 10                	jb     802171 <__udivdi3+0xc1>
  802161:	8b 74 24 08          	mov    0x8(%esp),%esi
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e6                	shl    %cl,%esi
  802169:	39 c6                	cmp    %eax,%esi
  80216b:	73 07                	jae    802174 <__udivdi3+0xc4>
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	75 03                	jne    802174 <__udivdi3+0xc4>
  802171:	83 eb 01             	sub    $0x1,%ebx
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 d8                	mov    %ebx,%eax
  802178:	89 fa                	mov    %edi,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	31 ff                	xor    %edi,%edi
  80218a:	31 db                	xor    %ebx,%ebx
  80218c:	89 d8                	mov    %ebx,%eax
  80218e:	89 fa                	mov    %edi,%edx
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
  802198:	90                   	nop
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	f7 f7                	div    %edi
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 fa                	mov    %edi,%edx
  8021ac:	83 c4 1c             	add    $0x1c,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	39 ce                	cmp    %ecx,%esi
  8021ba:	72 0c                	jb     8021c8 <__udivdi3+0x118>
  8021bc:	31 db                	xor    %ebx,%ebx
  8021be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021c2:	0f 87 34 ff ff ff    	ja     8020fc <__udivdi3+0x4c>
  8021c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021cd:	e9 2a ff ff ff       	jmp    8020fc <__udivdi3+0x4c>
  8021d2:	66 90                	xchg   %ax,%ax
  8021d4:	66 90                	xchg   %ax,%ax
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 d2                	test   %edx,%edx
  8021f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802201:	89 f3                	mov    %esi,%ebx
  802203:	89 3c 24             	mov    %edi,(%esp)
  802206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220a:	75 1c                	jne    802228 <__umoddi3+0x48>
  80220c:	39 f7                	cmp    %esi,%edi
  80220e:	76 50                	jbe    802260 <__umoddi3+0x80>
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	f7 f7                	div    %edi
  802216:	89 d0                	mov    %edx,%eax
  802218:	31 d2                	xor    %edx,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	89 d0                	mov    %edx,%eax
  80222c:	77 52                	ja     802280 <__umoddi3+0xa0>
  80222e:	0f bd ea             	bsr    %edx,%ebp
  802231:	83 f5 1f             	xor    $0x1f,%ebp
  802234:	75 5a                	jne    802290 <__umoddi3+0xb0>
  802236:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80223a:	0f 82 e0 00 00 00    	jb     802320 <__umoddi3+0x140>
  802240:	39 0c 24             	cmp    %ecx,(%esp)
  802243:	0f 86 d7 00 00 00    	jbe    802320 <__umoddi3+0x140>
  802249:	8b 44 24 08          	mov    0x8(%esp),%eax
  80224d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	85 ff                	test   %edi,%edi
  802262:	89 fd                	mov    %edi,%ebp
  802264:	75 0b                	jne    802271 <__umoddi3+0x91>
  802266:	b8 01 00 00 00       	mov    $0x1,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	f7 f7                	div    %edi
  80226f:	89 c5                	mov    %eax,%ebp
  802271:	89 f0                	mov    %esi,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f5                	div    %ebp
  802277:	89 c8                	mov    %ecx,%eax
  802279:	f7 f5                	div    %ebp
  80227b:	89 d0                	mov    %edx,%eax
  80227d:	eb 99                	jmp    802218 <__umoddi3+0x38>
  80227f:	90                   	nop
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	83 c4 1c             	add    $0x1c,%esp
  802287:	5b                   	pop    %ebx
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	8b 34 24             	mov    (%esp),%esi
  802293:	bf 20 00 00 00       	mov    $0x20,%edi
  802298:	89 e9                	mov    %ebp,%ecx
  80229a:	29 ef                	sub    %ebp,%edi
  80229c:	d3 e0                	shl    %cl,%eax
  80229e:	89 f9                	mov    %edi,%ecx
  8022a0:	89 f2                	mov    %esi,%edx
  8022a2:	d3 ea                	shr    %cl,%edx
  8022a4:	89 e9                	mov    %ebp,%ecx
  8022a6:	09 c2                	or     %eax,%edx
  8022a8:	89 d8                	mov    %ebx,%eax
  8022aa:	89 14 24             	mov    %edx,(%esp)
  8022ad:	89 f2                	mov    %esi,%edx
  8022af:	d3 e2                	shl    %cl,%edx
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	89 c6                	mov    %eax,%esi
  8022c1:	d3 e3                	shl    %cl,%ebx
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 d0                	mov    %edx,%eax
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	09 d8                	or     %ebx,%eax
  8022cd:	89 d3                	mov    %edx,%ebx
  8022cf:	89 f2                	mov    %esi,%edx
  8022d1:	f7 34 24             	divl   (%esp)
  8022d4:	89 d6                	mov    %edx,%esi
  8022d6:	d3 e3                	shl    %cl,%ebx
  8022d8:	f7 64 24 04          	mull   0x4(%esp)
  8022dc:	39 d6                	cmp    %edx,%esi
  8022de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e2:	89 d1                	mov    %edx,%ecx
  8022e4:	89 c3                	mov    %eax,%ebx
  8022e6:	72 08                	jb     8022f0 <__umoddi3+0x110>
  8022e8:	75 11                	jne    8022fb <__umoddi3+0x11b>
  8022ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ee:	73 0b                	jae    8022fb <__umoddi3+0x11b>
  8022f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022f4:	1b 14 24             	sbb    (%esp),%edx
  8022f7:	89 d1                	mov    %edx,%ecx
  8022f9:	89 c3                	mov    %eax,%ebx
  8022fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ff:	29 da                	sub    %ebx,%edx
  802301:	19 ce                	sbb    %ecx,%esi
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 f0                	mov    %esi,%eax
  802307:	d3 e0                	shl    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	d3 ea                	shr    %cl,%edx
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	d3 ee                	shr    %cl,%esi
  802311:	09 d0                	or     %edx,%eax
  802313:	89 f2                	mov    %esi,%edx
  802315:	83 c4 1c             	add    $0x1c,%esp
  802318:	5b                   	pop    %ebx
  802319:	5e                   	pop    %esi
  80231a:	5f                   	pop    %edi
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	29 f9                	sub    %edi,%ecx
  802322:	19 d6                	sbb    %edx,%esi
  802324:	89 74 24 04          	mov    %esi,0x4(%esp)
  802328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80232c:	e9 18 ff ff ff       	jmp    802249 <__umoddi3+0x69>
