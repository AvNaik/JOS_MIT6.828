
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 80 1e 80 00       	push   $0x801e80
  80003e:	e8 d2 01 00 00       	call   800215 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 fb 1e 80 00       	push   $0x801efb
  80005b:	6a 11                	push   $0x11
  80005d:	68 18 1f 80 00       	push   $0x801f18
  800062:	e8 d5 00 00 00       	call   80013c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 a0 1e 80 00       	push   $0x801ea0
  80009b:	6a 16                	push   $0x16
  80009d:	68 18 1f 80 00       	push   $0x801f18
  8000a2:	e8 95 00 00 00       	call   80013c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 c8 1e 80 00       	push   $0x801ec8
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 27 1f 80 00       	push   $0x801f27
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 18 1f 80 00       	push   $0x801f18
  8000d7:	e8 60 00 00 00       	call   80013c <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000e7:	e8 73 0a 00 00       	call   800b5f <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 2c 0e 00 00       	call   800f59 <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 e7 09 00 00       	call   800b1e <sys_env_destroy>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014a:	e8 10 0a 00 00       	call   800b5f <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 48 1f 80 00       	push   $0x801f48
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 16 1f 80 00 	movl   $0x801f16,(%esp)
  800177:	e8 99 00 00 00       	call   800215 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 2f 09 00 00       	call   800ae1 <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 54 01 00 00       	call   80034c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 d4 08 00 00       	call   800ae1 <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800250:	39 d3                	cmp    %edx,%ebx
  800252:	72 05                	jb     800259 <printnum+0x30>
  800254:	39 45 10             	cmp    %eax,0x10(%ebp)
  800257:	77 45                	ja     80029e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 18             	pushl  0x18(%ebp)
  80025f:	8b 45 14             	mov    0x14(%ebp),%eax
  800262:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800265:	53                   	push   %ebx
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 73 19 00 00       	call   801bf0 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9e ff ff ff       	call   800229 <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 18                	jmp    8002a8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	eb 03                	jmp    8002a1 <printnum+0x78>
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f e8                	jg     800290 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bb:	e8 60 1a 00 00       	call   801d20 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 6b 1f 80 00 	movsbl 0x801f6b(%eax),%eax
  8002ca:	50                   	push   %eax
  8002cb:	ff d7                	call   *%edi
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002db:	83 fa 01             	cmp    $0x1,%edx
  8002de:	7e 0e                	jle    8002ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ec:	eb 22                	jmp    800310 <getuint+0x38>
	else if (lflag)
  8002ee:	85 d2                	test   %edx,%edx
  8002f0:	74 10                	je     800302 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	eb 0e                	jmp    800310 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800318:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	3b 50 04             	cmp    0x4(%eax),%edx
  800321:	73 0a                	jae    80032d <sprintputch+0x1b>
		*b->buf++ = ch;
  800323:	8d 4a 01             	lea    0x1(%edx),%ecx
  800326:	89 08                	mov    %ecx,(%eax)
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	88 02                	mov    %al,(%edx)
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800335:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800338:	50                   	push   %eax
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	e8 05 00 00 00       	call   80034c <vprintfmt>
	va_end(ap);
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 2c             	sub    $0x2c,%esp
  800355:	8b 75 08             	mov    0x8(%ebp),%esi
  800358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035e:	eb 12                	jmp    800372 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800360:	85 c0                	test   %eax,%eax
  800362:	0f 84 89 03 00 00    	je     8006f1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	53                   	push   %ebx
  80036c:	50                   	push   %eax
  80036d:	ff d6                	call   *%esi
  80036f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800372:	83 c7 01             	add    $0x1,%edi
  800375:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e2                	jne    800360 <vprintfmt+0x14>
  80037e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800382:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800389:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800390:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 07                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8d 47 01             	lea    0x1(%edi),%eax
  8003a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ab:	0f b6 07             	movzbl (%edi),%eax
  8003ae:	0f b6 c8             	movzbl %al,%ecx
  8003b1:	83 e8 23             	sub    $0x23,%eax
  8003b4:	3c 55                	cmp    $0x55,%al
  8003b6:	0f 87 1a 03 00 00    	ja     8006d6 <vprintfmt+0x38a>
  8003bc:	0f b6 c0             	movzbl %al,%eax
  8003bf:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cd:	eb d6                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003dd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e7:	83 fa 09             	cmp    $0x9,%edx
  8003ea:	77 39                	ja     800425 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ef:	eb e9                	jmp    8003da <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800402:	eb 27                	jmp    80042b <vprintfmt+0xdf>
  800404:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	0f 49 c8             	cmovns %eax,%ecx
  800411:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800417:	eb 8c                	jmp    8003a5 <vprintfmt+0x59>
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800423:	eb 80                	jmp    8003a5 <vprintfmt+0x59>
  800425:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800428:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80042b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042f:	0f 89 70 ff ff ff    	jns    8003a5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800435:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800442:	e9 5e ff ff ff       	jmp    8003a5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800447:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044d:	e9 53 ff ff ff       	jmp    8003a5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	53                   	push   %ebx
  80045f:	ff 30                	pushl  (%eax)
  800461:	ff d6                	call   *%esi
			break;
  800463:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800469:	e9 04 ff ff ff       	jmp    800372 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 00                	mov    (%eax),%eax
  800479:	99                   	cltd   
  80047a:	31 d0                	xor    %edx,%eax
  80047c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047e:	83 f8 0f             	cmp    $0xf,%eax
  800481:	7f 0b                	jg     80048e <vprintfmt+0x142>
  800483:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	75 18                	jne    8004a6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048e:	50                   	push   %eax
  80048f:	68 83 1f 80 00       	push   $0x801f83
  800494:	53                   	push   %ebx
  800495:	56                   	push   %esi
  800496:	e8 94 fe ff ff       	call   80032f <printfmt>
  80049b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a1:	e9 cc fe ff ff       	jmp    800372 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a6:	52                   	push   %edx
  8004a7:	68 35 23 80 00       	push   $0x802335
  8004ac:	53                   	push   %ebx
  8004ad:	56                   	push   %esi
  8004ae:	e8 7c fe ff ff       	call   80032f <printfmt>
  8004b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b9:	e9 b4 fe ff ff       	jmp    800372 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 50 04             	lea    0x4(%eax),%edx
  8004c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	b8 7c 1f 80 00       	mov    $0x801f7c,%eax
  8004d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d7:	0f 8e 94 00 00 00    	jle    800571 <vprintfmt+0x225>
  8004dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e1:	0f 84 98 00 00 00    	je     80057f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ed:	57                   	push   %edi
  8004ee:	e8 86 02 00 00       	call   800779 <strnlen>
  8004f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f6:	29 c1                	sub    %eax,%ecx
  8004f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800502:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800505:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800508:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	eb 0f                	jmp    80051b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 e0             	pushl  -0x20(%ebp)
  800513:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	85 ff                	test   %edi,%edi
  80051d:	7f ed                	jg     80050c <vprintfmt+0x1c0>
  80051f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800522:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800525:	85 c9                	test   %ecx,%ecx
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
  80052c:	0f 49 c1             	cmovns %ecx,%eax
  80052f:	29 c1                	sub    %eax,%ecx
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	89 cb                	mov    %ecx,%ebx
  80053c:	eb 4d                	jmp    80058b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800542:	74 1b                	je     80055f <vprintfmt+0x213>
  800544:	0f be c0             	movsbl %al,%eax
  800547:	83 e8 20             	sub    $0x20,%eax
  80054a:	83 f8 5e             	cmp    $0x5e,%eax
  80054d:	76 10                	jbe    80055f <vprintfmt+0x213>
					putch('?', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	ff 75 0c             	pushl  0xc(%ebp)
  800555:	6a 3f                	push   $0x3f
  800557:	ff 55 08             	call   *0x8(%ebp)
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	eb 0d                	jmp    80056c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 0c             	pushl  0xc(%ebp)
  800565:	52                   	push   %edx
  800566:	ff 55 08             	call   *0x8(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056c:	83 eb 01             	sub    $0x1,%ebx
  80056f:	eb 1a                	jmp    80058b <vprintfmt+0x23f>
  800571:	89 75 08             	mov    %esi,0x8(%ebp)
  800574:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800577:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057d:	eb 0c                	jmp    80058b <vprintfmt+0x23f>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	83 c7 01             	add    $0x1,%edi
  80058e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800592:	0f be d0             	movsbl %al,%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	74 23                	je     8005bc <vprintfmt+0x270>
  800599:	85 f6                	test   %esi,%esi
  80059b:	78 a1                	js     80053e <vprintfmt+0x1f2>
  80059d:	83 ee 01             	sub    $0x1,%esi
  8005a0:	79 9c                	jns    80053e <vprintfmt+0x1f2>
  8005a2:	89 df                	mov    %ebx,%edi
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005aa:	eb 18                	jmp    8005c4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 20                	push   $0x20
  8005b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	eb 08                	jmp    8005c4 <vprintfmt+0x278>
  8005bc:	89 df                	mov    %ebx,%edi
  8005be:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f e4                	jg     8005ac <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cb:	e9 a2 fd ff ff       	jmp    800372 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d0:	83 fa 01             	cmp    $0x1,%edx
  8005d3:	7e 16                	jle    8005eb <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 08             	lea    0x8(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 50 04             	mov    0x4(%eax),%edx
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e9:	eb 32                	jmp    80061d <vprintfmt+0x2d1>
	else if (lflag)
  8005eb:	85 d2                	test   %edx,%edx
  8005ed:	74 18                	je     800607 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fd:	89 c1                	mov    %eax,%ecx
  8005ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800602:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800605:	eb 16                	jmp    80061d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 50 04             	lea    0x4(%eax),%edx
  80060d:	89 55 14             	mov    %edx,0x14(%ebp)
  800610:	8b 00                	mov    (%eax),%eax
  800612:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800615:	89 c1                	mov    %eax,%ecx
  800617:	c1 f9 1f             	sar    $0x1f,%ecx
  80061a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800620:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800623:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800628:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062c:	79 74                	jns    8006a2 <vprintfmt+0x356>
				putch('-', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 2d                	push   $0x2d
  800634:	ff d6                	call   *%esi
				num = -(long long) num;
  800636:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800639:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063c:	f7 d8                	neg    %eax
  80063e:	83 d2 00             	adc    $0x0,%edx
  800641:	f7 da                	neg    %edx
  800643:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800646:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064b:	eb 55                	jmp    8006a2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064d:	8d 45 14             	lea    0x14(%ebp),%eax
  800650:	e8 83 fc ff ff       	call   8002d8 <getuint>
			base = 10;
  800655:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065a:	eb 46                	jmp    8006a2 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80065c:	8d 45 14             	lea    0x14(%ebp),%eax
  80065f:	e8 74 fc ff ff       	call   8002d8 <getuint>
			base = 8;
  800664:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800669:	eb 37                	jmp    8006a2 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 30                	push   $0x30
  800671:	ff d6                	call   *%esi
			putch('x', putdat);
  800673:	83 c4 08             	add    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 78                	push   $0x78
  800679:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 50 04             	lea    0x4(%eax),%edx
  800681:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800684:	8b 00                	mov    (%eax),%eax
  800686:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800693:	eb 0d                	jmp    8006a2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800695:	8d 45 14             	lea    0x14(%ebp),%eax
  800698:	e8 3b fc ff ff       	call   8002d8 <getuint>
			base = 16;
  80069d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a2:	83 ec 0c             	sub    $0xc,%esp
  8006a5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a9:	57                   	push   %edi
  8006aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ad:	51                   	push   %ecx
  8006ae:	52                   	push   %edx
  8006af:	50                   	push   %eax
  8006b0:	89 da                	mov    %ebx,%edx
  8006b2:	89 f0                	mov    %esi,%eax
  8006b4:	e8 70 fb ff ff       	call   800229 <printnum>
			break;
  8006b9:	83 c4 20             	add    $0x20,%esp
  8006bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bf:	e9 ae fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	51                   	push   %ecx
  8006c9:	ff d6                	call   *%esi
			break;
  8006cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d1:	e9 9c fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	6a 25                	push   $0x25
  8006dc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb 03                	jmp    8006e6 <vprintfmt+0x39a>
  8006e3:	83 ef 01             	sub    $0x1,%edi
  8006e6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ea:	75 f7                	jne    8006e3 <vprintfmt+0x397>
  8006ec:	e9 81 fc ff ff       	jmp    800372 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f4:	5b                   	pop    %ebx
  8006f5:	5e                   	pop    %esi
  8006f6:	5f                   	pop    %edi
  8006f7:	5d                   	pop    %ebp
  8006f8:	c3                   	ret    

008006f9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	83 ec 18             	sub    $0x18,%esp
  8006ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800702:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800705:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800708:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800716:	85 c0                	test   %eax,%eax
  800718:	74 26                	je     800740 <vsnprintf+0x47>
  80071a:	85 d2                	test   %edx,%edx
  80071c:	7e 22                	jle    800740 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071e:	ff 75 14             	pushl  0x14(%ebp)
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800727:	50                   	push   %eax
  800728:	68 12 03 80 00       	push   $0x800312
  80072d:	e8 1a fc ff ff       	call   80034c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800732:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800735:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	eb 05                	jmp    800745 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800740:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800750:	50                   	push   %eax
  800751:	ff 75 10             	pushl  0x10(%ebp)
  800754:	ff 75 0c             	pushl  0xc(%ebp)
  800757:	ff 75 08             	pushl  0x8(%ebp)
  80075a:	e8 9a ff ff ff       	call   8006f9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800767:	b8 00 00 00 00       	mov    $0x0,%eax
  80076c:	eb 03                	jmp    800771 <strlen+0x10>
		n++;
  80076e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800771:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800775:	75 f7                	jne    80076e <strlen+0xd>
		n++;
	return n;
}
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800782:	ba 00 00 00 00       	mov    $0x0,%edx
  800787:	eb 03                	jmp    80078c <strnlen+0x13>
		n++;
  800789:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078c:	39 c2                	cmp    %eax,%edx
  80078e:	74 08                	je     800798 <strnlen+0x1f>
  800790:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800794:	75 f3                	jne    800789 <strnlen+0x10>
  800796:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	53                   	push   %ebx
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	83 c2 01             	add    $0x1,%edx
  8007a9:	83 c1 01             	add    $0x1,%ecx
  8007ac:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b3:	84 db                	test   %bl,%bl
  8007b5:	75 ef                	jne    8007a6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b7:	5b                   	pop    %ebx
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c1:	53                   	push   %ebx
  8007c2:	e8 9a ff ff ff       	call   800761 <strlen>
  8007c7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ca:	ff 75 0c             	pushl  0xc(%ebp)
  8007cd:	01 d8                	add    %ebx,%eax
  8007cf:	50                   	push   %eax
  8007d0:	e8 c5 ff ff ff       	call   80079a <strcpy>
	return dst;
}
  8007d5:	89 d8                	mov    %ebx,%eax
  8007d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	89 f3                	mov    %esi,%ebx
  8007e9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ec:	89 f2                	mov    %esi,%edx
  8007ee:	eb 0f                	jmp    8007ff <strncpy+0x23>
		*dst++ = *src;
  8007f0:	83 c2 01             	add    $0x1,%edx
  8007f3:	0f b6 01             	movzbl (%ecx),%eax
  8007f6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f9:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ff:	39 da                	cmp    %ebx,%edx
  800801:	75 ed                	jne    8007f0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800803:	89 f0                	mov    %esi,%eax
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	56                   	push   %esi
  80080d:	53                   	push   %ebx
  80080e:	8b 75 08             	mov    0x8(%ebp),%esi
  800811:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800814:	8b 55 10             	mov    0x10(%ebp),%edx
  800817:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800819:	85 d2                	test   %edx,%edx
  80081b:	74 21                	je     80083e <strlcpy+0x35>
  80081d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800821:	89 f2                	mov    %esi,%edx
  800823:	eb 09                	jmp    80082e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800825:	83 c2 01             	add    $0x1,%edx
  800828:	83 c1 01             	add    $0x1,%ecx
  80082b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082e:	39 c2                	cmp    %eax,%edx
  800830:	74 09                	je     80083b <strlcpy+0x32>
  800832:	0f b6 19             	movzbl (%ecx),%ebx
  800835:	84 db                	test   %bl,%bl
  800837:	75 ec                	jne    800825 <strlcpy+0x1c>
  800839:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083e:	29 f0                	sub    %esi,%eax
}
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084d:	eb 06                	jmp    800855 <strcmp+0x11>
		p++, q++;
  80084f:	83 c1 01             	add    $0x1,%ecx
  800852:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800855:	0f b6 01             	movzbl (%ecx),%eax
  800858:	84 c0                	test   %al,%al
  80085a:	74 04                	je     800860 <strcmp+0x1c>
  80085c:	3a 02                	cmp    (%edx),%al
  80085e:	74 ef                	je     80084f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800860:	0f b6 c0             	movzbl %al,%eax
  800863:	0f b6 12             	movzbl (%edx),%edx
  800866:	29 d0                	sub    %edx,%eax
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
  800874:	89 c3                	mov    %eax,%ebx
  800876:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800879:	eb 06                	jmp    800881 <strncmp+0x17>
		n--, p++, q++;
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800881:	39 d8                	cmp    %ebx,%eax
  800883:	74 15                	je     80089a <strncmp+0x30>
  800885:	0f b6 08             	movzbl (%eax),%ecx
  800888:	84 c9                	test   %cl,%cl
  80088a:	74 04                	je     800890 <strncmp+0x26>
  80088c:	3a 0a                	cmp    (%edx),%cl
  80088e:	74 eb                	je     80087b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800890:	0f b6 00             	movzbl (%eax),%eax
  800893:	0f b6 12             	movzbl (%edx),%edx
  800896:	29 d0                	sub    %edx,%eax
  800898:	eb 05                	jmp    80089f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089f:	5b                   	pop    %ebx
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ac:	eb 07                	jmp    8008b5 <strchr+0x13>
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	74 0f                	je     8008c1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	0f b6 10             	movzbl (%eax),%edx
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	75 f2                	jne    8008ae <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cd:	eb 03                	jmp    8008d2 <strfind+0xf>
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 04                	je     8008dd <strfind+0x1a>
  8008d9:	84 d2                	test   %dl,%dl
  8008db:	75 f2                	jne    8008cf <strfind+0xc>
			break;
	return (char *) s;
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	57                   	push   %edi
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008eb:	85 c9                	test   %ecx,%ecx
  8008ed:	74 36                	je     800925 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f5:	75 28                	jne    80091f <memset+0x40>
  8008f7:	f6 c1 03             	test   $0x3,%cl
  8008fa:	75 23                	jne    80091f <memset+0x40>
		c &= 0xFF;
  8008fc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800900:	89 d3                	mov    %edx,%ebx
  800902:	c1 e3 08             	shl    $0x8,%ebx
  800905:	89 d6                	mov    %edx,%esi
  800907:	c1 e6 18             	shl    $0x18,%esi
  80090a:	89 d0                	mov    %edx,%eax
  80090c:	c1 e0 10             	shl    $0x10,%eax
  80090f:	09 f0                	or     %esi,%eax
  800911:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800913:	89 d8                	mov    %ebx,%eax
  800915:	09 d0                	or     %edx,%eax
  800917:	c1 e9 02             	shr    $0x2,%ecx
  80091a:	fc                   	cld    
  80091b:	f3 ab                	rep stos %eax,%es:(%edi)
  80091d:	eb 06                	jmp    800925 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800922:	fc                   	cld    
  800923:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800925:	89 f8                	mov    %edi,%eax
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5f                   	pop    %edi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	57                   	push   %edi
  800930:	56                   	push   %esi
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 75 0c             	mov    0xc(%ebp),%esi
  800937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093a:	39 c6                	cmp    %eax,%esi
  80093c:	73 35                	jae    800973 <memmove+0x47>
  80093e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800941:	39 d0                	cmp    %edx,%eax
  800943:	73 2e                	jae    800973 <memmove+0x47>
		s += n;
		d += n;
  800945:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800948:	89 d6                	mov    %edx,%esi
  80094a:	09 fe                	or     %edi,%esi
  80094c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800952:	75 13                	jne    800967 <memmove+0x3b>
  800954:	f6 c1 03             	test   $0x3,%cl
  800957:	75 0e                	jne    800967 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800959:	83 ef 04             	sub    $0x4,%edi
  80095c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095f:	c1 e9 02             	shr    $0x2,%ecx
  800962:	fd                   	std    
  800963:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800965:	eb 09                	jmp    800970 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800967:	83 ef 01             	sub    $0x1,%edi
  80096a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096d:	fd                   	std    
  80096e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800970:	fc                   	cld    
  800971:	eb 1d                	jmp    800990 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	89 f2                	mov    %esi,%edx
  800975:	09 c2                	or     %eax,%edx
  800977:	f6 c2 03             	test   $0x3,%dl
  80097a:	75 0f                	jne    80098b <memmove+0x5f>
  80097c:	f6 c1 03             	test   $0x3,%cl
  80097f:	75 0a                	jne    80098b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800981:	c1 e9 02             	shr    $0x2,%ecx
  800984:	89 c7                	mov    %eax,%edi
  800986:	fc                   	cld    
  800987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800989:	eb 05                	jmp    800990 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098b:	89 c7                	mov    %eax,%edi
  80098d:	fc                   	cld    
  80098e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800997:	ff 75 10             	pushl  0x10(%ebp)
  80099a:	ff 75 0c             	pushl  0xc(%ebp)
  80099d:	ff 75 08             	pushl  0x8(%ebp)
  8009a0:	e8 87 ff ff ff       	call   80092c <memmove>
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b2:	89 c6                	mov    %eax,%esi
  8009b4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b7:	eb 1a                	jmp    8009d3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b9:	0f b6 08             	movzbl (%eax),%ecx
  8009bc:	0f b6 1a             	movzbl (%edx),%ebx
  8009bf:	38 d9                	cmp    %bl,%cl
  8009c1:	74 0a                	je     8009cd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c3:	0f b6 c1             	movzbl %cl,%eax
  8009c6:	0f b6 db             	movzbl %bl,%ebx
  8009c9:	29 d8                	sub    %ebx,%eax
  8009cb:	eb 0f                	jmp    8009dc <memcmp+0x35>
		s1++, s2++;
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	39 f0                	cmp    %esi,%eax
  8009d5:	75 e2                	jne    8009b9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5e                   	pop    %esi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	53                   	push   %ebx
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e7:	89 c1                	mov    %eax,%ecx
  8009e9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ec:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f0:	eb 0a                	jmp    8009fc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f2:	0f b6 10             	movzbl (%eax),%edx
  8009f5:	39 da                	cmp    %ebx,%edx
  8009f7:	74 07                	je     800a00 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	39 c8                	cmp    %ecx,%eax
  8009fe:	72 f2                	jb     8009f2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a00:	5b                   	pop    %ebx
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0f:	eb 03                	jmp    800a14 <strtol+0x11>
		s++;
  800a11:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a14:	0f b6 01             	movzbl (%ecx),%eax
  800a17:	3c 20                	cmp    $0x20,%al
  800a19:	74 f6                	je     800a11 <strtol+0xe>
  800a1b:	3c 09                	cmp    $0x9,%al
  800a1d:	74 f2                	je     800a11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1f:	3c 2b                	cmp    $0x2b,%al
  800a21:	75 0a                	jne    800a2d <strtol+0x2a>
		s++;
  800a23:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a26:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2b:	eb 11                	jmp    800a3e <strtol+0x3b>
  800a2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a32:	3c 2d                	cmp    $0x2d,%al
  800a34:	75 08                	jne    800a3e <strtol+0x3b>
		s++, neg = 1;
  800a36:	83 c1 01             	add    $0x1,%ecx
  800a39:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a44:	75 15                	jne    800a5b <strtol+0x58>
  800a46:	80 39 30             	cmpb   $0x30,(%ecx)
  800a49:	75 10                	jne    800a5b <strtol+0x58>
  800a4b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4f:	75 7c                	jne    800acd <strtol+0xca>
		s += 2, base = 16;
  800a51:	83 c1 02             	add    $0x2,%ecx
  800a54:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a59:	eb 16                	jmp    800a71 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a5b:	85 db                	test   %ebx,%ebx
  800a5d:	75 12                	jne    800a71 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a64:	80 39 30             	cmpb   $0x30,(%ecx)
  800a67:	75 08                	jne    800a71 <strtol+0x6e>
		s++, base = 8;
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
  800a76:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a79:	0f b6 11             	movzbl (%ecx),%edx
  800a7c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 09             	cmp    $0x9,%bl
  800a84:	77 08                	ja     800a8e <strtol+0x8b>
			dig = *s - '0';
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 30             	sub    $0x30,%edx
  800a8c:	eb 22                	jmp    800ab0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	80 fb 19             	cmp    $0x19,%bl
  800a96:	77 08                	ja     800aa0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a98:	0f be d2             	movsbl %dl,%edx
  800a9b:	83 ea 57             	sub    $0x57,%edx
  800a9e:	eb 10                	jmp    800ab0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aa0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa3:	89 f3                	mov    %esi,%ebx
  800aa5:	80 fb 19             	cmp    $0x19,%bl
  800aa8:	77 16                	ja     800ac0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aaa:	0f be d2             	movsbl %dl,%edx
  800aad:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab3:	7d 0b                	jge    800ac0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab5:	83 c1 01             	add    $0x1,%ecx
  800ab8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abe:	eb b9                	jmp    800a79 <strtol+0x76>

	if (endptr)
  800ac0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac4:	74 0d                	je     800ad3 <strtol+0xd0>
		*endptr = (char *) s;
  800ac6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac9:	89 0e                	mov    %ecx,(%esi)
  800acb:	eb 06                	jmp    800ad3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acd:	85 db                	test   %ebx,%ebx
  800acf:	74 98                	je     800a69 <strtol+0x66>
  800ad1:	eb 9e                	jmp    800a71 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad3:	89 c2                	mov    %eax,%edx
  800ad5:	f7 da                	neg    %edx
  800ad7:	85 ff                	test   %edi,%edi
  800ad9:	0f 45 c2             	cmovne %edx,%eax
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aef:	8b 55 08             	mov    0x8(%ebp),%edx
  800af2:	89 c3                	mov    %eax,%ebx
  800af4:	89 c7                	mov    %eax,%edi
  800af6:	89 c6                	mov    %eax,%esi
  800af8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_cgetc>:

int
sys_cgetc(void)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0f:	89 d1                	mov    %edx,%ecx
  800b11:	89 d3                	mov    %edx,%ebx
  800b13:	89 d7                	mov    %edx,%edi
  800b15:	89 d6                	mov    %edx,%esi
  800b17:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b31:	8b 55 08             	mov    0x8(%ebp),%edx
  800b34:	89 cb                	mov    %ecx,%ebx
  800b36:	89 cf                	mov    %ecx,%edi
  800b38:	89 ce                	mov    %ecx,%esi
  800b3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	7e 17                	jle    800b57 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	50                   	push   %eax
  800b44:	6a 03                	push   $0x3
  800b46:	68 5f 22 80 00       	push   $0x80225f
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 7c 22 80 00       	push   $0x80227c
  800b52:	e8 e5 f5 ff ff       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_yield>:

void
sys_yield(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8e:	89 d1                	mov    %edx,%ecx
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	89 d7                	mov    %edx,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	be 00 00 00 00       	mov    $0x0,%esi
  800bab:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb9:	89 f7                	mov    %esi,%edi
  800bbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7e 17                	jle    800bd8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 04                	push   $0x4
  800bc7:	68 5f 22 80 00       	push   $0x80225f
  800bcc:	6a 23                	push   $0x23
  800bce:	68 7c 22 80 00       	push   $0x80227c
  800bd3:	e8 64 f5 ff ff       	call   80013c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bfa:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 17                	jle    800c1a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 05                	push   $0x5
  800c09:	68 5f 22 80 00       	push   $0x80225f
  800c0e:	6a 23                	push   $0x23
  800c10:	68 7c 22 80 00       	push   $0x80227c
  800c15:	e8 22 f5 ff ff       	call   80013c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c30:	b8 06 00 00 00       	mov    $0x6,%eax
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	89 df                	mov    %ebx,%edi
  800c3d:	89 de                	mov    %ebx,%esi
  800c3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 17                	jle    800c5c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 06                	push   $0x6
  800c4b:	68 5f 22 80 00       	push   $0x80225f
  800c50:	6a 23                	push   $0x23
  800c52:	68 7c 22 80 00       	push   $0x80227c
  800c57:	e8 e0 f4 ff ff       	call   80013c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c72:	b8 08 00 00 00       	mov    $0x8,%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 df                	mov    %ebx,%edi
  800c7f:	89 de                	mov    %ebx,%esi
  800c81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7e 17                	jle    800c9e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	6a 08                	push   $0x8
  800c8d:	68 5f 22 80 00       	push   $0x80225f
  800c92:	6a 23                	push   $0x23
  800c94:	68 7c 22 80 00       	push   $0x80227c
  800c99:	e8 9e f4 ff ff       	call   80013c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 df                	mov    %ebx,%edi
  800cc1:	89 de                	mov    %ebx,%esi
  800cc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 09                	push   $0x9
  800ccf:	68 5f 22 80 00       	push   $0x80225f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 7c 22 80 00       	push   $0x80227c
  800cdb:	e8 5c f4 ff ff       	call   80013c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800cf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	89 df                	mov    %ebx,%edi
  800d03:	89 de                	mov    %ebx,%esi
  800d05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 0a                	push   $0xa
  800d11:	68 5f 22 80 00       	push   $0x80225f
  800d16:	6a 23                	push   $0x23
  800d18:	68 7c 22 80 00       	push   $0x80227c
  800d1d:	e8 1a f4 ff ff       	call   80013c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	be 00 00 00 00       	mov    $0x0,%esi
  800d35:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d43:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d46:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 cb                	mov    %ecx,%ebx
  800d65:	89 cf                	mov    %ecx,%edi
  800d67:	89 ce                	mov    %ecx,%esi
  800d69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 17                	jle    800d86 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 0d                	push   $0xd
  800d75:	68 5f 22 80 00       	push   $0x80225f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 7c 22 80 00       	push   $0x80227c
  800d81:	e8 b6 f3 ff ff       	call   80013c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	05 00 00 00 30       	add    $0x30000000,%eax
  800d99:	c1 e8 0c             	shr    $0xc,%eax
}
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	05 00 00 00 30       	add    $0x30000000,%eax
  800da9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dae:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dc0:	89 c2                	mov    %eax,%edx
  800dc2:	c1 ea 16             	shr    $0x16,%edx
  800dc5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dcc:	f6 c2 01             	test   $0x1,%dl
  800dcf:	74 11                	je     800de2 <fd_alloc+0x2d>
  800dd1:	89 c2                	mov    %eax,%edx
  800dd3:	c1 ea 0c             	shr    $0xc,%edx
  800dd6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ddd:	f6 c2 01             	test   $0x1,%dl
  800de0:	75 09                	jne    800deb <fd_alloc+0x36>
			*fd_store = fd;
  800de2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800de4:	b8 00 00 00 00       	mov    $0x0,%eax
  800de9:	eb 17                	jmp    800e02 <fd_alloc+0x4d>
  800deb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800df0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800df5:	75 c9                	jne    800dc0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800df7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dfd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e0a:	83 f8 1f             	cmp    $0x1f,%eax
  800e0d:	77 36                	ja     800e45 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e0f:	c1 e0 0c             	shl    $0xc,%eax
  800e12:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e17:	89 c2                	mov    %eax,%edx
  800e19:	c1 ea 16             	shr    $0x16,%edx
  800e1c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e23:	f6 c2 01             	test   $0x1,%dl
  800e26:	74 24                	je     800e4c <fd_lookup+0x48>
  800e28:	89 c2                	mov    %eax,%edx
  800e2a:	c1 ea 0c             	shr    $0xc,%edx
  800e2d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e34:	f6 c2 01             	test   $0x1,%dl
  800e37:	74 1a                	je     800e53 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3c:	89 02                	mov    %eax,(%edx)
	return 0;
  800e3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e43:	eb 13                	jmp    800e58 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e4a:	eb 0c                	jmp    800e58 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e51:	eb 05                	jmp    800e58 <fd_lookup+0x54>
  800e53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e63:	ba 0c 23 80 00       	mov    $0x80230c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e68:	eb 13                	jmp    800e7d <dev_lookup+0x23>
  800e6a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e6d:	39 08                	cmp    %ecx,(%eax)
  800e6f:	75 0c                	jne    800e7d <dev_lookup+0x23>
			*dev = devtab[i];
  800e71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e74:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e76:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7b:	eb 2e                	jmp    800eab <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e7d:	8b 02                	mov    (%edx),%eax
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	75 e7                	jne    800e6a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e83:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800e88:	8b 40 48             	mov    0x48(%eax),%eax
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	51                   	push   %ecx
  800e8f:	50                   	push   %eax
  800e90:	68 8c 22 80 00       	push   $0x80228c
  800e95:	e8 7b f3 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ea3:	83 c4 10             	add    $0x10,%esp
  800ea6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	83 ec 10             	sub    $0x10,%esp
  800eb5:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ebb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebe:	50                   	push   %eax
  800ebf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ec5:	c1 e8 0c             	shr    $0xc,%eax
  800ec8:	50                   	push   %eax
  800ec9:	e8 36 ff ff ff       	call   800e04 <fd_lookup>
  800ece:	83 c4 08             	add    $0x8,%esp
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	78 05                	js     800eda <fd_close+0x2d>
	    || fd != fd2)
  800ed5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ed8:	74 0c                	je     800ee6 <fd_close+0x39>
		return (must_exist ? r : 0);
  800eda:	84 db                	test   %bl,%bl
  800edc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee1:	0f 44 c2             	cmove  %edx,%eax
  800ee4:	eb 41                	jmp    800f27 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ee6:	83 ec 08             	sub    $0x8,%esp
  800ee9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eec:	50                   	push   %eax
  800eed:	ff 36                	pushl  (%esi)
  800eef:	e8 66 ff ff ff       	call   800e5a <dev_lookup>
  800ef4:	89 c3                	mov    %eax,%ebx
  800ef6:	83 c4 10             	add    $0x10,%esp
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	78 1a                	js     800f17 <fd_close+0x6a>
		if (dev->dev_close)
  800efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f00:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f03:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	74 0b                	je     800f17 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f0c:	83 ec 0c             	sub    $0xc,%esp
  800f0f:	56                   	push   %esi
  800f10:	ff d0                	call   *%eax
  800f12:	89 c3                	mov    %eax,%ebx
  800f14:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f17:	83 ec 08             	sub    $0x8,%esp
  800f1a:	56                   	push   %esi
  800f1b:	6a 00                	push   $0x0
  800f1d:	e8 00 fd ff ff       	call   800c22 <sys_page_unmap>
	return r;
  800f22:	83 c4 10             	add    $0x10,%esp
  800f25:	89 d8                	mov    %ebx,%eax
}
  800f27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f37:	50                   	push   %eax
  800f38:	ff 75 08             	pushl  0x8(%ebp)
  800f3b:	e8 c4 fe ff ff       	call   800e04 <fd_lookup>
  800f40:	83 c4 08             	add    $0x8,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	78 10                	js     800f57 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f47:	83 ec 08             	sub    $0x8,%esp
  800f4a:	6a 01                	push   $0x1
  800f4c:	ff 75 f4             	pushl  -0xc(%ebp)
  800f4f:	e8 59 ff ff ff       	call   800ead <fd_close>
  800f54:	83 c4 10             	add    $0x10,%esp
}
  800f57:	c9                   	leave  
  800f58:	c3                   	ret    

00800f59 <close_all>:

void
close_all(void)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	53                   	push   %ebx
  800f5d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f60:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f65:	83 ec 0c             	sub    $0xc,%esp
  800f68:	53                   	push   %ebx
  800f69:	e8 c0 ff ff ff       	call   800f2e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f6e:	83 c3 01             	add    $0x1,%ebx
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	83 fb 20             	cmp    $0x20,%ebx
  800f77:	75 ec                	jne    800f65 <close_all+0xc>
		close(i);
}
  800f79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
  800f84:	83 ec 2c             	sub    $0x2c,%esp
  800f87:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f8a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f8d:	50                   	push   %eax
  800f8e:	ff 75 08             	pushl  0x8(%ebp)
  800f91:	e8 6e fe ff ff       	call   800e04 <fd_lookup>
  800f96:	83 c4 08             	add    $0x8,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	0f 88 c1 00 00 00    	js     801062 <dup+0xe4>
		return r;
	close(newfdnum);
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	56                   	push   %esi
  800fa5:	e8 84 ff ff ff       	call   800f2e <close>

	newfd = INDEX2FD(newfdnum);
  800faa:	89 f3                	mov    %esi,%ebx
  800fac:	c1 e3 0c             	shl    $0xc,%ebx
  800faf:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fb5:	83 c4 04             	add    $0x4,%esp
  800fb8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fbb:	e8 de fd ff ff       	call   800d9e <fd2data>
  800fc0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fc2:	89 1c 24             	mov    %ebx,(%esp)
  800fc5:	e8 d4 fd ff ff       	call   800d9e <fd2data>
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fd0:	89 f8                	mov    %edi,%eax
  800fd2:	c1 e8 16             	shr    $0x16,%eax
  800fd5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fdc:	a8 01                	test   $0x1,%al
  800fde:	74 37                	je     801017 <dup+0x99>
  800fe0:	89 f8                	mov    %edi,%eax
  800fe2:	c1 e8 0c             	shr    $0xc,%eax
  800fe5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fec:	f6 c2 01             	test   $0x1,%dl
  800fef:	74 26                	je     801017 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800ff1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff8:	83 ec 0c             	sub    $0xc,%esp
  800ffb:	25 07 0e 00 00       	and    $0xe07,%eax
  801000:	50                   	push   %eax
  801001:	ff 75 d4             	pushl  -0x2c(%ebp)
  801004:	6a 00                	push   $0x0
  801006:	57                   	push   %edi
  801007:	6a 00                	push   $0x0
  801009:	e8 d2 fb ff ff       	call   800be0 <sys_page_map>
  80100e:	89 c7                	mov    %eax,%edi
  801010:	83 c4 20             	add    $0x20,%esp
  801013:	85 c0                	test   %eax,%eax
  801015:	78 2e                	js     801045 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801017:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80101a:	89 d0                	mov    %edx,%eax
  80101c:	c1 e8 0c             	shr    $0xc,%eax
  80101f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	25 07 0e 00 00       	and    $0xe07,%eax
  80102e:	50                   	push   %eax
  80102f:	53                   	push   %ebx
  801030:	6a 00                	push   $0x0
  801032:	52                   	push   %edx
  801033:	6a 00                	push   $0x0
  801035:	e8 a6 fb ff ff       	call   800be0 <sys_page_map>
  80103a:	89 c7                	mov    %eax,%edi
  80103c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80103f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801041:	85 ff                	test   %edi,%edi
  801043:	79 1d                	jns    801062 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801045:	83 ec 08             	sub    $0x8,%esp
  801048:	53                   	push   %ebx
  801049:	6a 00                	push   $0x0
  80104b:	e8 d2 fb ff ff       	call   800c22 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801050:	83 c4 08             	add    $0x8,%esp
  801053:	ff 75 d4             	pushl  -0x2c(%ebp)
  801056:	6a 00                	push   $0x0
  801058:	e8 c5 fb ff ff       	call   800c22 <sys_page_unmap>
	return r;
  80105d:	83 c4 10             	add    $0x10,%esp
  801060:	89 f8                	mov    %edi,%eax
}
  801062:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	53                   	push   %ebx
  80106e:	83 ec 14             	sub    $0x14,%esp
  801071:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801074:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801077:	50                   	push   %eax
  801078:	53                   	push   %ebx
  801079:	e8 86 fd ff ff       	call   800e04 <fd_lookup>
  80107e:	83 c4 08             	add    $0x8,%esp
  801081:	89 c2                	mov    %eax,%edx
  801083:	85 c0                	test   %eax,%eax
  801085:	78 6d                	js     8010f4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801087:	83 ec 08             	sub    $0x8,%esp
  80108a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80108d:	50                   	push   %eax
  80108e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801091:	ff 30                	pushl  (%eax)
  801093:	e8 c2 fd ff ff       	call   800e5a <dev_lookup>
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	78 4c                	js     8010eb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80109f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010a2:	8b 42 08             	mov    0x8(%edx),%eax
  8010a5:	83 e0 03             	and    $0x3,%eax
  8010a8:	83 f8 01             	cmp    $0x1,%eax
  8010ab:	75 21                	jne    8010ce <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ad:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8010b2:	8b 40 48             	mov    0x48(%eax),%eax
  8010b5:	83 ec 04             	sub    $0x4,%esp
  8010b8:	53                   	push   %ebx
  8010b9:	50                   	push   %eax
  8010ba:	68 d0 22 80 00       	push   $0x8022d0
  8010bf:	e8 51 f1 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010cc:	eb 26                	jmp    8010f4 <read+0x8a>
	}
	if (!dev->dev_read)
  8010ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d1:	8b 40 08             	mov    0x8(%eax),%eax
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	74 17                	je     8010ef <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	ff 75 10             	pushl  0x10(%ebp)
  8010de:	ff 75 0c             	pushl  0xc(%ebp)
  8010e1:	52                   	push   %edx
  8010e2:	ff d0                	call   *%eax
  8010e4:	89 c2                	mov    %eax,%edx
  8010e6:	83 c4 10             	add    $0x10,%esp
  8010e9:	eb 09                	jmp    8010f4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010eb:	89 c2                	mov    %eax,%edx
  8010ed:	eb 05                	jmp    8010f4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010ef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010f4:	89 d0                	mov    %edx,%eax
  8010f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f9:	c9                   	leave  
  8010fa:	c3                   	ret    

008010fb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	83 ec 0c             	sub    $0xc,%esp
  801104:	8b 7d 08             	mov    0x8(%ebp),%edi
  801107:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80110a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110f:	eb 21                	jmp    801132 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801111:	83 ec 04             	sub    $0x4,%esp
  801114:	89 f0                	mov    %esi,%eax
  801116:	29 d8                	sub    %ebx,%eax
  801118:	50                   	push   %eax
  801119:	89 d8                	mov    %ebx,%eax
  80111b:	03 45 0c             	add    0xc(%ebp),%eax
  80111e:	50                   	push   %eax
  80111f:	57                   	push   %edi
  801120:	e8 45 ff ff ff       	call   80106a <read>
		if (m < 0)
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	85 c0                	test   %eax,%eax
  80112a:	78 10                	js     80113c <readn+0x41>
			return m;
		if (m == 0)
  80112c:	85 c0                	test   %eax,%eax
  80112e:	74 0a                	je     80113a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801130:	01 c3                	add    %eax,%ebx
  801132:	39 f3                	cmp    %esi,%ebx
  801134:	72 db                	jb     801111 <readn+0x16>
  801136:	89 d8                	mov    %ebx,%eax
  801138:	eb 02                	jmp    80113c <readn+0x41>
  80113a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80113c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113f:	5b                   	pop    %ebx
  801140:	5e                   	pop    %esi
  801141:	5f                   	pop    %edi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
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
  801153:	e8 ac fc ff ff       	call   800e04 <fd_lookup>
  801158:	83 c4 08             	add    $0x8,%esp
  80115b:	89 c2                	mov    %eax,%edx
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 68                	js     8011c9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801161:	83 ec 08             	sub    $0x8,%esp
  801164:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801167:	50                   	push   %eax
  801168:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116b:	ff 30                	pushl  (%eax)
  80116d:	e8 e8 fc ff ff       	call   800e5a <dev_lookup>
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	85 c0                	test   %eax,%eax
  801177:	78 47                	js     8011c0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801179:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801180:	75 21                	jne    8011a3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801182:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801187:	8b 40 48             	mov    0x48(%eax),%eax
  80118a:	83 ec 04             	sub    $0x4,%esp
  80118d:	53                   	push   %ebx
  80118e:	50                   	push   %eax
  80118f:	68 ec 22 80 00       	push   $0x8022ec
  801194:	e8 7c f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a1:	eb 26                	jmp    8011c9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011a6:	8b 52 0c             	mov    0xc(%edx),%edx
  8011a9:	85 d2                	test   %edx,%edx
  8011ab:	74 17                	je     8011c4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011ad:	83 ec 04             	sub    $0x4,%esp
  8011b0:	ff 75 10             	pushl  0x10(%ebp)
  8011b3:	ff 75 0c             	pushl  0xc(%ebp)
  8011b6:	50                   	push   %eax
  8011b7:	ff d2                	call   *%edx
  8011b9:	89 c2                	mov    %eax,%edx
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	eb 09                	jmp    8011c9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c0:	89 c2                	mov    %eax,%edx
  8011c2:	eb 05                	jmp    8011c9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011c4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011c9:	89 d0                	mov    %edx,%eax
  8011cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ce:	c9                   	leave  
  8011cf:	c3                   	ret    

008011d0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011d9:	50                   	push   %eax
  8011da:	ff 75 08             	pushl  0x8(%ebp)
  8011dd:	e8 22 fc ff ff       	call   800e04 <fd_lookup>
  8011e2:	83 c4 08             	add    $0x8,%esp
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	78 0e                	js     8011f7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ef:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011f7:	c9                   	leave  
  8011f8:	c3                   	ret    

008011f9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 14             	sub    $0x14,%esp
  801200:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801203:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801206:	50                   	push   %eax
  801207:	53                   	push   %ebx
  801208:	e8 f7 fb ff ff       	call   800e04 <fd_lookup>
  80120d:	83 c4 08             	add    $0x8,%esp
  801210:	89 c2                	mov    %eax,%edx
  801212:	85 c0                	test   %eax,%eax
  801214:	78 65                	js     80127b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801216:	83 ec 08             	sub    $0x8,%esp
  801219:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121c:	50                   	push   %eax
  80121d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801220:	ff 30                	pushl  (%eax)
  801222:	e8 33 fc ff ff       	call   800e5a <dev_lookup>
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	85 c0                	test   %eax,%eax
  80122c:	78 44                	js     801272 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80122e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801231:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801235:	75 21                	jne    801258 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801237:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80123c:	8b 40 48             	mov    0x48(%eax),%eax
  80123f:	83 ec 04             	sub    $0x4,%esp
  801242:	53                   	push   %ebx
  801243:	50                   	push   %eax
  801244:	68 ac 22 80 00       	push   $0x8022ac
  801249:	e8 c7 ef ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801256:	eb 23                	jmp    80127b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801258:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125b:	8b 52 18             	mov    0x18(%edx),%edx
  80125e:	85 d2                	test   %edx,%edx
  801260:	74 14                	je     801276 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801262:	83 ec 08             	sub    $0x8,%esp
  801265:	ff 75 0c             	pushl  0xc(%ebp)
  801268:	50                   	push   %eax
  801269:	ff d2                	call   *%edx
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	eb 09                	jmp    80127b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801272:	89 c2                	mov    %eax,%edx
  801274:	eb 05                	jmp    80127b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801276:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80127b:	89 d0                	mov    %edx,%eax
  80127d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801280:	c9                   	leave  
  801281:	c3                   	ret    

00801282 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	53                   	push   %ebx
  801286:	83 ec 14             	sub    $0x14,%esp
  801289:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128f:	50                   	push   %eax
  801290:	ff 75 08             	pushl  0x8(%ebp)
  801293:	e8 6c fb ff ff       	call   800e04 <fd_lookup>
  801298:	83 c4 08             	add    $0x8,%esp
  80129b:	89 c2                	mov    %eax,%edx
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 58                	js     8012f9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ab:	ff 30                	pushl  (%eax)
  8012ad:	e8 a8 fb ff ff       	call   800e5a <dev_lookup>
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 37                	js     8012f0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012bc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012c0:	74 32                	je     8012f4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012c2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012c5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012cc:	00 00 00 
	stat->st_isdir = 0;
  8012cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012d6:	00 00 00 
	stat->st_dev = dev;
  8012d9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012df:	83 ec 08             	sub    $0x8,%esp
  8012e2:	53                   	push   %ebx
  8012e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e6:	ff 50 14             	call   *0x14(%eax)
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	eb 09                	jmp    8012f9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f0:	89 c2                	mov    %eax,%edx
  8012f2:	eb 05                	jmp    8012f9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012f9:	89 d0                	mov    %edx,%eax
  8012fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	56                   	push   %esi
  801304:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	6a 00                	push   $0x0
  80130a:	ff 75 08             	pushl  0x8(%ebp)
  80130d:	e8 2c 02 00 00       	call   80153e <open>
  801312:	89 c3                	mov    %eax,%ebx
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 1b                	js     801336 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	ff 75 0c             	pushl  0xc(%ebp)
  801321:	50                   	push   %eax
  801322:	e8 5b ff ff ff       	call   801282 <fstat>
  801327:	89 c6                	mov    %eax,%esi
	close(fd);
  801329:	89 1c 24             	mov    %ebx,(%esp)
  80132c:	e8 fd fb ff ff       	call   800f2e <close>
	return r;
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	89 f0                	mov    %esi,%eax
}
  801336:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801339:	5b                   	pop    %ebx
  80133a:	5e                   	pop    %esi
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    

0080133d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	56                   	push   %esi
  801341:	53                   	push   %ebx
  801342:	89 c6                	mov    %eax,%esi
  801344:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  801346:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80134d:	75 12                	jne    801361 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	6a 01                	push   $0x1
  801354:	e8 1b 08 00 00       	call   801b74 <ipc_find_env>
  801359:	a3 00 40 80 00       	mov    %eax,0x804000
  80135e:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801361:	6a 07                	push   $0x7
  801363:	68 00 50 c0 00       	push   $0xc05000
  801368:	56                   	push   %esi
  801369:	ff 35 00 40 80 00    	pushl  0x804000
  80136f:	e8 ac 07 00 00       	call   801b20 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  801374:	83 c4 0c             	add    $0xc,%esp
  801377:	6a 00                	push   $0x0
  801379:	53                   	push   %ebx
  80137a:	6a 00                	push   $0x0
  80137c:	e8 40 07 00 00       	call   801ac1 <ipc_recv>
}
  801381:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801384:	5b                   	pop    %ebx
  801385:	5e                   	pop    %esi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80138e:	8b 45 08             	mov    0x8(%ebp),%eax
  801391:	8b 40 0c             	mov    0xc(%eax),%eax
  801394:	a3 00 50 c0 00       	mov    %eax,0xc05000
	   fsipcbuf.set_size.req_size = newsize;
  801399:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139c:	a3 04 50 c0 00       	mov    %eax,0xc05004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  8013a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a6:	b8 02 00 00 00       	mov    $0x2,%eax
  8013ab:	e8 8d ff ff ff       	call   80133d <fsipc>
}
  8013b0:	c9                   	leave  
  8013b1:	c3                   	ret    

008013b2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8013be:	a3 00 50 c0 00       	mov    %eax,0xc05000
	   return fsipc(FSREQ_FLUSH, NULL);
  8013c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c8:	b8 06 00 00 00       	mov    $0x6,%eax
  8013cd:	e8 6b ff ff ff       	call   80133d <fsipc>
}
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    

008013d4 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	53                   	push   %ebx
  8013d8:	83 ec 04             	sub    $0x4,%esp
  8013db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013de:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e4:	a3 00 50 c0 00       	mov    %eax,0xc05000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8013f3:	e8 45 ff ff ff       	call   80133d <fsipc>
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 2c                	js     801428 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	68 00 50 c0 00       	push   $0xc05000
  801404:	53                   	push   %ebx
  801405:	e8 90 f3 ff ff       	call   80079a <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  80140a:	a1 80 50 c0 00       	mov    0xc05080,%eax
  80140f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801415:	a1 84 50 c0 00       	mov    0xc05084,%eax
  80141a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801428:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142b:	c9                   	leave  
  80142c:	c3                   	ret    

0080142d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	53                   	push   %ebx
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  801437:	8b 45 08             	mov    0x8(%ebp),%eax
  80143a:	8b 40 0c             	mov    0xc(%eax),%eax
  80143d:	a3 00 50 c0 00       	mov    %eax,0xc05000
	   fsipcbuf.write.req_n = n;
  801442:	89 1d 04 50 c0 00    	mov    %ebx,0xc05004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  801448:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  80144e:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801453:	0f 46 c3             	cmovbe %ebx,%eax
  801456:	50                   	push   %eax
  801457:	ff 75 0c             	pushl  0xc(%ebp)
  80145a:	68 08 50 c0 00       	push   $0xc05008
  80145f:	e8 c8 f4 ff ff       	call   80092c <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  801464:	ba 00 00 00 00       	mov    $0x0,%edx
  801469:	b8 04 00 00 00       	mov    $0x4,%eax
  80146e:	e8 ca fe ff ff       	call   80133d <fsipc>
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	85 c0                	test   %eax,%eax
  801478:	78 3d                	js     8014b7 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  80147a:	39 c3                	cmp    %eax,%ebx
  80147c:	73 19                	jae    801497 <devfile_write+0x6a>
  80147e:	68 1c 23 80 00       	push   $0x80231c
  801483:	68 23 23 80 00       	push   $0x802323
  801488:	68 9a 00 00 00       	push   $0x9a
  80148d:	68 38 23 80 00       	push   $0x802338
  801492:	e8 a5 ec ff ff       	call   80013c <_panic>
	   assert (r <= bytes_written);
  801497:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80149c:	7e 19                	jle    8014b7 <devfile_write+0x8a>
  80149e:	68 43 23 80 00       	push   $0x802343
  8014a3:	68 23 23 80 00       	push   $0x802323
  8014a8:	68 9b 00 00 00       	push   $0x9b
  8014ad:	68 38 23 80 00       	push   $0x802338
  8014b2:	e8 85 ec ff ff       	call   80013c <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  8014b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	56                   	push   %esi
  8014c0:	53                   	push   %ebx
  8014c1:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ca:	a3 00 50 c0 00       	mov    %eax,0xc05000
	   fsipcbuf.read.req_n = n;
  8014cf:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014da:	b8 03 00 00 00       	mov    $0x3,%eax
  8014df:	e8 59 fe ff ff       	call   80133d <fsipc>
  8014e4:	89 c3                	mov    %eax,%ebx
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 4b                	js     801535 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  8014ea:	39 c6                	cmp    %eax,%esi
  8014ec:	73 16                	jae    801504 <devfile_read+0x48>
  8014ee:	68 1c 23 80 00       	push   $0x80231c
  8014f3:	68 23 23 80 00       	push   $0x802323
  8014f8:	6a 7c                	push   $0x7c
  8014fa:	68 38 23 80 00       	push   $0x802338
  8014ff:	e8 38 ec ff ff       	call   80013c <_panic>
	   assert(r <= PGSIZE);
  801504:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801509:	7e 16                	jle    801521 <devfile_read+0x65>
  80150b:	68 56 23 80 00       	push   $0x802356
  801510:	68 23 23 80 00       	push   $0x802323
  801515:	6a 7d                	push   $0x7d
  801517:	68 38 23 80 00       	push   $0x802338
  80151c:	e8 1b ec ff ff       	call   80013c <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	50                   	push   %eax
  801525:	68 00 50 c0 00       	push   $0xc05000
  80152a:	ff 75 0c             	pushl  0xc(%ebp)
  80152d:	e8 fa f3 ff ff       	call   80092c <memmove>
	   return r;
  801532:	83 c4 10             	add    $0x10,%esp
}
  801535:	89 d8                	mov    %ebx,%eax
  801537:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153a:	5b                   	pop    %ebx
  80153b:	5e                   	pop    %esi
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    

0080153e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	53                   	push   %ebx
  801542:	83 ec 20             	sub    $0x20,%esp
  801545:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  801548:	53                   	push   %ebx
  801549:	e8 13 f2 ff ff       	call   800761 <strlen>
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801556:	7f 67                	jg     8015bf <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801558:	83 ec 0c             	sub    $0xc,%esp
  80155b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155e:	50                   	push   %eax
  80155f:	e8 51 f8 ff ff       	call   800db5 <fd_alloc>
  801564:	83 c4 10             	add    $0x10,%esp
			 return r;
  801567:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 57                	js     8015c4 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	53                   	push   %ebx
  801571:	68 00 50 c0 00       	push   $0xc05000
  801576:	e8 1f f2 ff ff       	call   80079a <strcpy>
	   fsipcbuf.open.req_omode = mode;
  80157b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157e:	a3 00 54 c0 00       	mov    %eax,0xc05400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801583:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801586:	b8 01 00 00 00       	mov    $0x1,%eax
  80158b:	e8 ad fd ff ff       	call   80133d <fsipc>
  801590:	89 c3                	mov    %eax,%ebx
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	79 14                	jns    8015ad <open+0x6f>
			 fd_close(fd, 0);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	6a 00                	push   $0x0
  80159e:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a1:	e8 07 f9 ff ff       	call   800ead <fd_close>
			 return r;
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	89 da                	mov    %ebx,%edx
  8015ab:	eb 17                	jmp    8015c4 <open+0x86>
	   }

	   return fd2num(fd);
  8015ad:	83 ec 0c             	sub    $0xc,%esp
  8015b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b3:	e8 d6 f7 ff ff       	call   800d8e <fd2num>
  8015b8:	89 c2                	mov    %eax,%edx
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	eb 05                	jmp    8015c4 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  8015bf:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  8015c4:	89 d0                	mov    %edx,%eax
  8015c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c9:	c9                   	leave  
  8015ca:	c3                   	ret    

008015cb <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  8015d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d6:	b8 08 00 00 00       	mov    $0x8,%eax
  8015db:	e8 5d fd ff ff       	call   80133d <fsipc>
}
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	ff 75 08             	pushl  0x8(%ebp)
  8015f0:	e8 a9 f7 ff ff       	call   800d9e <fd2data>
  8015f5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015f7:	83 c4 08             	add    $0x8,%esp
  8015fa:	68 62 23 80 00       	push   $0x802362
  8015ff:	53                   	push   %ebx
  801600:	e8 95 f1 ff ff       	call   80079a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801605:	8b 46 04             	mov    0x4(%esi),%eax
  801608:	2b 06                	sub    (%esi),%eax
  80160a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801610:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801617:	00 00 00 
	stat->st_dev = &devpipe;
  80161a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801621:	30 80 00 
	return 0;
}
  801624:	b8 00 00 00 00       	mov    $0x0,%eax
  801629:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5e                   	pop    %esi
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	53                   	push   %ebx
  801634:	83 ec 0c             	sub    $0xc,%esp
  801637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80163a:	53                   	push   %ebx
  80163b:	6a 00                	push   $0x0
  80163d:	e8 e0 f5 ff ff       	call   800c22 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801642:	89 1c 24             	mov    %ebx,(%esp)
  801645:	e8 54 f7 ff ff       	call   800d9e <fd2data>
  80164a:	83 c4 08             	add    $0x8,%esp
  80164d:	50                   	push   %eax
  80164e:	6a 00                	push   $0x0
  801650:	e8 cd f5 ff ff       	call   800c22 <sys_page_unmap>
}
  801655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	57                   	push   %edi
  80165e:	56                   	push   %esi
  80165f:	53                   	push   %ebx
  801660:	83 ec 1c             	sub    $0x1c,%esp
  801663:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801666:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801668:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80166d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801670:	83 ec 0c             	sub    $0xc,%esp
  801673:	ff 75 e0             	pushl  -0x20(%ebp)
  801676:	e8 32 05 00 00       	call   801bad <pageref>
  80167b:	89 c3                	mov    %eax,%ebx
  80167d:	89 3c 24             	mov    %edi,(%esp)
  801680:	e8 28 05 00 00       	call   801bad <pageref>
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	39 c3                	cmp    %eax,%ebx
  80168a:	0f 94 c1             	sete   %cl
  80168d:	0f b6 c9             	movzbl %cl,%ecx
  801690:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801693:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801699:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80169c:	39 ce                	cmp    %ecx,%esi
  80169e:	74 1b                	je     8016bb <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016a0:	39 c3                	cmp    %eax,%ebx
  8016a2:	75 c4                	jne    801668 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016a4:	8b 42 58             	mov    0x58(%edx),%eax
  8016a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016aa:	50                   	push   %eax
  8016ab:	56                   	push   %esi
  8016ac:	68 69 23 80 00       	push   $0x802369
  8016b1:	e8 5f eb ff ff       	call   800215 <cprintf>
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	eb ad                	jmp    801668 <_pipeisclosed+0xe>
	}
}
  8016bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c1:	5b                   	pop    %ebx
  8016c2:	5e                   	pop    %esi
  8016c3:	5f                   	pop    %edi
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	57                   	push   %edi
  8016ca:	56                   	push   %esi
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 28             	sub    $0x28,%esp
  8016cf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016d2:	56                   	push   %esi
  8016d3:	e8 c6 f6 ff ff       	call   800d9e <fd2data>
  8016d8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8016e2:	eb 4b                	jmp    80172f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016e4:	89 da                	mov    %ebx,%edx
  8016e6:	89 f0                	mov    %esi,%eax
  8016e8:	e8 6d ff ff ff       	call   80165a <_pipeisclosed>
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	75 48                	jne    801739 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016f1:	e8 88 f4 ff ff       	call   800b7e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016f6:	8b 43 04             	mov    0x4(%ebx),%eax
  8016f9:	8b 0b                	mov    (%ebx),%ecx
  8016fb:	8d 51 20             	lea    0x20(%ecx),%edx
  8016fe:	39 d0                	cmp    %edx,%eax
  801700:	73 e2                	jae    8016e4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801702:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801705:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801709:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80170c:	89 c2                	mov    %eax,%edx
  80170e:	c1 fa 1f             	sar    $0x1f,%edx
  801711:	89 d1                	mov    %edx,%ecx
  801713:	c1 e9 1b             	shr    $0x1b,%ecx
  801716:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801719:	83 e2 1f             	and    $0x1f,%edx
  80171c:	29 ca                	sub    %ecx,%edx
  80171e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801722:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801726:	83 c0 01             	add    $0x1,%eax
  801729:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172c:	83 c7 01             	add    $0x1,%edi
  80172f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801732:	75 c2                	jne    8016f6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801734:	8b 45 10             	mov    0x10(%ebp),%eax
  801737:	eb 05                	jmp    80173e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801739:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80173e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801741:	5b                   	pop    %ebx
  801742:	5e                   	pop    %esi
  801743:	5f                   	pop    %edi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    

00801746 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	57                   	push   %edi
  80174a:	56                   	push   %esi
  80174b:	53                   	push   %ebx
  80174c:	83 ec 18             	sub    $0x18,%esp
  80174f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801752:	57                   	push   %edi
  801753:	e8 46 f6 ff ff       	call   800d9e <fd2data>
  801758:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801762:	eb 3d                	jmp    8017a1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801764:	85 db                	test   %ebx,%ebx
  801766:	74 04                	je     80176c <devpipe_read+0x26>
				return i;
  801768:	89 d8                	mov    %ebx,%eax
  80176a:	eb 44                	jmp    8017b0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80176c:	89 f2                	mov    %esi,%edx
  80176e:	89 f8                	mov    %edi,%eax
  801770:	e8 e5 fe ff ff       	call   80165a <_pipeisclosed>
  801775:	85 c0                	test   %eax,%eax
  801777:	75 32                	jne    8017ab <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801779:	e8 00 f4 ff ff       	call   800b7e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80177e:	8b 06                	mov    (%esi),%eax
  801780:	3b 46 04             	cmp    0x4(%esi),%eax
  801783:	74 df                	je     801764 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801785:	99                   	cltd   
  801786:	c1 ea 1b             	shr    $0x1b,%edx
  801789:	01 d0                	add    %edx,%eax
  80178b:	83 e0 1f             	and    $0x1f,%eax
  80178e:	29 d0                	sub    %edx,%eax
  801790:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801795:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801798:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80179b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80179e:	83 c3 01             	add    $0x1,%ebx
  8017a1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017a4:	75 d8                	jne    80177e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a9:	eb 05                	jmp    8017b0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ab:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	5f                   	pop    %edi
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	56                   	push   %esi
  8017bc:	53                   	push   %ebx
  8017bd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c3:	50                   	push   %eax
  8017c4:	e8 ec f5 ff ff       	call   800db5 <fd_alloc>
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	89 c2                	mov    %eax,%edx
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	0f 88 2c 01 00 00    	js     801902 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d6:	83 ec 04             	sub    $0x4,%esp
  8017d9:	68 07 04 00 00       	push   $0x407
  8017de:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e1:	6a 00                	push   $0x0
  8017e3:	e8 b5 f3 ff ff       	call   800b9d <sys_page_alloc>
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	0f 88 0d 01 00 00    	js     801902 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017f5:	83 ec 0c             	sub    $0xc,%esp
  8017f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fb:	50                   	push   %eax
  8017fc:	e8 b4 f5 ff ff       	call   800db5 <fd_alloc>
  801801:	89 c3                	mov    %eax,%ebx
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	85 c0                	test   %eax,%eax
  801808:	0f 88 e2 00 00 00    	js     8018f0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180e:	83 ec 04             	sub    $0x4,%esp
  801811:	68 07 04 00 00       	push   $0x407
  801816:	ff 75 f0             	pushl  -0x10(%ebp)
  801819:	6a 00                	push   $0x0
  80181b:	e8 7d f3 ff ff       	call   800b9d <sys_page_alloc>
  801820:	89 c3                	mov    %eax,%ebx
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	0f 88 c3 00 00 00    	js     8018f0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80182d:	83 ec 0c             	sub    $0xc,%esp
  801830:	ff 75 f4             	pushl  -0xc(%ebp)
  801833:	e8 66 f5 ff ff       	call   800d9e <fd2data>
  801838:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80183a:	83 c4 0c             	add    $0xc,%esp
  80183d:	68 07 04 00 00       	push   $0x407
  801842:	50                   	push   %eax
  801843:	6a 00                	push   $0x0
  801845:	e8 53 f3 ff ff       	call   800b9d <sys_page_alloc>
  80184a:	89 c3                	mov    %eax,%ebx
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	0f 88 89 00 00 00    	js     8018e0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801857:	83 ec 0c             	sub    $0xc,%esp
  80185a:	ff 75 f0             	pushl  -0x10(%ebp)
  80185d:	e8 3c f5 ff ff       	call   800d9e <fd2data>
  801862:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801869:	50                   	push   %eax
  80186a:	6a 00                	push   $0x0
  80186c:	56                   	push   %esi
  80186d:	6a 00                	push   $0x0
  80186f:	e8 6c f3 ff ff       	call   800be0 <sys_page_map>
  801874:	89 c3                	mov    %eax,%ebx
  801876:	83 c4 20             	add    $0x20,%esp
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 55                	js     8018d2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80187d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801883:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801886:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801892:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801898:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80189d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018a7:	83 ec 0c             	sub    $0xc,%esp
  8018aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ad:	e8 dc f4 ff ff       	call   800d8e <fd2num>
  8018b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018b7:	83 c4 04             	add    $0x4,%esp
  8018ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8018bd:	e8 cc f4 ff ff       	call   800d8e <fd2num>
  8018c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018c5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	eb 30                	jmp    801902 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	56                   	push   %esi
  8018d6:	6a 00                	push   $0x0
  8018d8:	e8 45 f3 ff ff       	call   800c22 <sys_page_unmap>
  8018dd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e6:	6a 00                	push   $0x0
  8018e8:	e8 35 f3 ff ff       	call   800c22 <sys_page_unmap>
  8018ed:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f6:	6a 00                	push   $0x0
  8018f8:	e8 25 f3 ff ff       	call   800c22 <sys_page_unmap>
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801902:	89 d0                	mov    %edx,%eax
  801904:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801907:	5b                   	pop    %ebx
  801908:	5e                   	pop    %esi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801911:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801914:	50                   	push   %eax
  801915:	ff 75 08             	pushl  0x8(%ebp)
  801918:	e8 e7 f4 ff ff       	call   800e04 <fd_lookup>
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	78 18                	js     80193c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801924:	83 ec 0c             	sub    $0xc,%esp
  801927:	ff 75 f4             	pushl  -0xc(%ebp)
  80192a:	e8 6f f4 ff ff       	call   800d9e <fd2data>
	return _pipeisclosed(fd, p);
  80192f:	89 c2                	mov    %eax,%edx
  801931:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801934:	e8 21 fd ff ff       	call   80165a <_pipeisclosed>
  801939:	83 c4 10             	add    $0x10,%esp
}
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801941:	b8 00 00 00 00       	mov    $0x0,%eax
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80194e:	68 81 23 80 00       	push   $0x802381
  801953:	ff 75 0c             	pushl  0xc(%ebp)
  801956:	e8 3f ee ff ff       	call   80079a <strcpy>
	return 0;
}
  80195b:	b8 00 00 00 00       	mov    $0x0,%eax
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	57                   	push   %edi
  801966:	56                   	push   %esi
  801967:	53                   	push   %ebx
  801968:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80196e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801973:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801979:	eb 2d                	jmp    8019a8 <devcons_write+0x46>
		m = n - tot;
  80197b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80197e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801980:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801983:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801988:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80198b:	83 ec 04             	sub    $0x4,%esp
  80198e:	53                   	push   %ebx
  80198f:	03 45 0c             	add    0xc(%ebp),%eax
  801992:	50                   	push   %eax
  801993:	57                   	push   %edi
  801994:	e8 93 ef ff ff       	call   80092c <memmove>
		sys_cputs(buf, m);
  801999:	83 c4 08             	add    $0x8,%esp
  80199c:	53                   	push   %ebx
  80199d:	57                   	push   %edi
  80199e:	e8 3e f1 ff ff       	call   800ae1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a3:	01 de                	add    %ebx,%esi
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	89 f0                	mov    %esi,%eax
  8019aa:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019ad:	72 cc                	jb     80197b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b2:	5b                   	pop    %ebx
  8019b3:	5e                   	pop    %esi
  8019b4:	5f                   	pop    %edi
  8019b5:	5d                   	pop    %ebp
  8019b6:	c3                   	ret    

008019b7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	83 ec 08             	sub    $0x8,%esp
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019c6:	74 2a                	je     8019f2 <devcons_read+0x3b>
  8019c8:	eb 05                	jmp    8019cf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019ca:	e8 af f1 ff ff       	call   800b7e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019cf:	e8 2b f1 ff ff       	call   800aff <sys_cgetc>
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	74 f2                	je     8019ca <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	78 16                	js     8019f2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019dc:	83 f8 04             	cmp    $0x4,%eax
  8019df:	74 0c                	je     8019ed <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019e4:	88 02                	mov    %al,(%edx)
	return 1;
  8019e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019eb:	eb 05                	jmp    8019f2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a00:	6a 01                	push   $0x1
  801a02:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a05:	50                   	push   %eax
  801a06:	e8 d6 f0 ff ff       	call   800ae1 <sys_cputs>
}
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <getchar>:

int
getchar(void)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a16:	6a 01                	push   $0x1
  801a18:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a1b:	50                   	push   %eax
  801a1c:	6a 00                	push   $0x0
  801a1e:	e8 47 f6 ff ff       	call   80106a <read>
	if (r < 0)
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	85 c0                	test   %eax,%eax
  801a28:	78 0f                	js     801a39 <getchar+0x29>
		return r;
	if (r < 1)
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	7e 06                	jle    801a34 <getchar+0x24>
		return -E_EOF;
	return c;
  801a2e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a32:	eb 05                	jmp    801a39 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a34:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a44:	50                   	push   %eax
  801a45:	ff 75 08             	pushl  0x8(%ebp)
  801a48:	e8 b7 f3 ff ff       	call   800e04 <fd_lookup>
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	85 c0                	test   %eax,%eax
  801a52:	78 11                	js     801a65 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a57:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a5d:	39 10                	cmp    %edx,(%eax)
  801a5f:	0f 94 c0             	sete   %al
  801a62:	0f b6 c0             	movzbl %al,%eax
}
  801a65:	c9                   	leave  
  801a66:	c3                   	ret    

00801a67 <opencons>:

int
opencons(void)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a70:	50                   	push   %eax
  801a71:	e8 3f f3 ff ff       	call   800db5 <fd_alloc>
  801a76:	83 c4 10             	add    $0x10,%esp
		return r;
  801a79:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 3e                	js     801abd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a7f:	83 ec 04             	sub    $0x4,%esp
  801a82:	68 07 04 00 00       	push   $0x407
  801a87:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8a:	6a 00                	push   $0x0
  801a8c:	e8 0c f1 ff ff       	call   800b9d <sys_page_alloc>
  801a91:	83 c4 10             	add    $0x10,%esp
		return r;
  801a94:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 23                	js     801abd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a9a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	50                   	push   %eax
  801ab3:	e8 d6 f2 ff ff       	call   800d8e <fd2num>
  801ab8:	89 c2                	mov    %eax,%edx
  801aba:	83 c4 10             	add    $0x10,%esp
}
  801abd:	89 d0                	mov    %edx,%eax
  801abf:	c9                   	leave  
  801ac0:	c3                   	ret    

00801ac1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	56                   	push   %esi
  801ac5:	53                   	push   %ebx
  801ac6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801acf:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801ad1:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801ad6:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	50                   	push   %eax
  801add:	e8 6b f2 ff ff       	call   800d4d <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 0e                	js     801af7 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801ae9:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801aef:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801af2:	8b 52 78             	mov    0x78(%edx),%edx
  801af5:	eb 0a                	jmp    801b01 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801af7:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801afc:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801b01:	85 f6                	test   %esi,%esi
  801b03:	74 02                	je     801b07 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801b05:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801b07:	85 db                	test   %ebx,%ebx
  801b09:	74 02                	je     801b0d <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801b0b:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	78 08                	js     801b19 <ipc_recv+0x58>
  801b11:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b16:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801b19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b1c:	5b                   	pop    %ebx
  801b1d:	5e                   	pop    %esi
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	57                   	push   %edi
  801b24:	56                   	push   %esi
  801b25:	53                   	push   %ebx
  801b26:	83 ec 0c             	sub    $0xc,%esp
  801b29:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801b32:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801b34:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801b39:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801b3c:	ff 75 14             	pushl  0x14(%ebp)
  801b3f:	53                   	push   %ebx
  801b40:	56                   	push   %esi
  801b41:	57                   	push   %edi
  801b42:	e8 e3 f1 ff ff       	call   800d2a <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b4d:	75 07                	jne    801b56 <ipc_send+0x36>
				    sys_yield();
  801b4f:	e8 2a f0 ff ff       	call   800b7e <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801b54:	eb e6                	jmp    801b3c <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801b56:	85 c0                	test   %eax,%eax
  801b58:	74 12                	je     801b6c <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801b5a:	50                   	push   %eax
  801b5b:	68 8d 23 80 00       	push   $0x80238d
  801b60:	6a 4b                	push   $0x4b
  801b62:	68 a1 23 80 00       	push   $0x8023a1
  801b67:	e8 d0 e5 ff ff       	call   80013c <_panic>
			 }
	   }
}
  801b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5e                   	pop    %esi
  801b71:	5f                   	pop    %edi
  801b72:	5d                   	pop    %ebp
  801b73:	c3                   	ret    

00801b74 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801b7a:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801b7f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b82:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b88:	8b 52 50             	mov    0x50(%edx),%edx
  801b8b:	39 ca                	cmp    %ecx,%edx
  801b8d:	75 0d                	jne    801b9c <ipc_find_env+0x28>
				    return envs[i].env_id;
  801b8f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b92:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b97:	8b 40 48             	mov    0x48(%eax),%eax
  801b9a:	eb 0f                	jmp    801bab <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801b9c:	83 c0 01             	add    $0x1,%eax
  801b9f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ba4:	75 d9                	jne    801b7f <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801ba6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    

00801bad <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bb3:	89 d0                	mov    %edx,%eax
  801bb5:	c1 e8 16             	shr    $0x16,%eax
  801bb8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bbf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bc4:	f6 c1 01             	test   $0x1,%cl
  801bc7:	74 1d                	je     801be6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bc9:	c1 ea 0c             	shr    $0xc,%edx
  801bcc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bd3:	f6 c2 01             	test   $0x1,%dl
  801bd6:	74 0e                	je     801be6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bd8:	c1 ea 0c             	shr    $0xc,%edx
  801bdb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801be2:	ef 
  801be3:	0f b7 c0             	movzwl %ax,%eax
}
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	66 90                	xchg   %ax,%ax
  801bea:	66 90                	xchg   %ax,%ax
  801bec:	66 90                	xchg   %ax,%ax
  801bee:	66 90                	xchg   %ax,%ax

00801bf0 <__udivdi3>:
  801bf0:	55                   	push   %ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 1c             	sub    $0x1c,%esp
  801bf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c07:	85 f6                	test   %esi,%esi
  801c09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c0d:	89 ca                	mov    %ecx,%edx
  801c0f:	89 f8                	mov    %edi,%eax
  801c11:	75 3d                	jne    801c50 <__udivdi3+0x60>
  801c13:	39 cf                	cmp    %ecx,%edi
  801c15:	0f 87 c5 00 00 00    	ja     801ce0 <__udivdi3+0xf0>
  801c1b:	85 ff                	test   %edi,%edi
  801c1d:	89 fd                	mov    %edi,%ebp
  801c1f:	75 0b                	jne    801c2c <__udivdi3+0x3c>
  801c21:	b8 01 00 00 00       	mov    $0x1,%eax
  801c26:	31 d2                	xor    %edx,%edx
  801c28:	f7 f7                	div    %edi
  801c2a:	89 c5                	mov    %eax,%ebp
  801c2c:	89 c8                	mov    %ecx,%eax
  801c2e:	31 d2                	xor    %edx,%edx
  801c30:	f7 f5                	div    %ebp
  801c32:	89 c1                	mov    %eax,%ecx
  801c34:	89 d8                	mov    %ebx,%eax
  801c36:	89 cf                	mov    %ecx,%edi
  801c38:	f7 f5                	div    %ebp
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	39 ce                	cmp    %ecx,%esi
  801c52:	77 74                	ja     801cc8 <__udivdi3+0xd8>
  801c54:	0f bd fe             	bsr    %esi,%edi
  801c57:	83 f7 1f             	xor    $0x1f,%edi
  801c5a:	0f 84 98 00 00 00    	je     801cf8 <__udivdi3+0x108>
  801c60:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	89 c5                	mov    %eax,%ebp
  801c69:	29 fb                	sub    %edi,%ebx
  801c6b:	d3 e6                	shl    %cl,%esi
  801c6d:	89 d9                	mov    %ebx,%ecx
  801c6f:	d3 ed                	shr    %cl,%ebp
  801c71:	89 f9                	mov    %edi,%ecx
  801c73:	d3 e0                	shl    %cl,%eax
  801c75:	09 ee                	or     %ebp,%esi
  801c77:	89 d9                	mov    %ebx,%ecx
  801c79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c7d:	89 d5                	mov    %edx,%ebp
  801c7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c83:	d3 ed                	shr    %cl,%ebp
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e2                	shl    %cl,%edx
  801c89:	89 d9                	mov    %ebx,%ecx
  801c8b:	d3 e8                	shr    %cl,%eax
  801c8d:	09 c2                	or     %eax,%edx
  801c8f:	89 d0                	mov    %edx,%eax
  801c91:	89 ea                	mov    %ebp,%edx
  801c93:	f7 f6                	div    %esi
  801c95:	89 d5                	mov    %edx,%ebp
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	f7 64 24 0c          	mull   0xc(%esp)
  801c9d:	39 d5                	cmp    %edx,%ebp
  801c9f:	72 10                	jb     801cb1 <__udivdi3+0xc1>
  801ca1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 e6                	shl    %cl,%esi
  801ca9:	39 c6                	cmp    %eax,%esi
  801cab:	73 07                	jae    801cb4 <__udivdi3+0xc4>
  801cad:	39 d5                	cmp    %edx,%ebp
  801caf:	75 03                	jne    801cb4 <__udivdi3+0xc4>
  801cb1:	83 eb 01             	sub    $0x1,%ebx
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 d8                	mov    %ebx,%eax
  801cb8:	89 fa                	mov    %edi,%edx
  801cba:	83 c4 1c             	add    $0x1c,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    
  801cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc8:	31 ff                	xor    %edi,%edi
  801cca:	31 db                	xor    %ebx,%ebx
  801ccc:	89 d8                	mov    %ebx,%eax
  801cce:	89 fa                	mov    %edi,%edx
  801cd0:	83 c4 1c             	add    $0x1c,%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
  801cd8:	90                   	nop
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	89 d8                	mov    %ebx,%eax
  801ce2:	f7 f7                	div    %edi
  801ce4:	31 ff                	xor    %edi,%edi
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	89 fa                	mov    %edi,%edx
  801cec:	83 c4 1c             	add    $0x1c,%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5e                   	pop    %esi
  801cf1:	5f                   	pop    %edi
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	39 ce                	cmp    %ecx,%esi
  801cfa:	72 0c                	jb     801d08 <__udivdi3+0x118>
  801cfc:	31 db                	xor    %ebx,%ebx
  801cfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d02:	0f 87 34 ff ff ff    	ja     801c3c <__udivdi3+0x4c>
  801d08:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d0d:	e9 2a ff ff ff       	jmp    801c3c <__udivdi3+0x4c>
  801d12:	66 90                	xchg   %ax,%ax
  801d14:	66 90                	xchg   %ax,%ax
  801d16:	66 90                	xchg   %ax,%ax
  801d18:	66 90                	xchg   %ax,%ax
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <__umoddi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d37:	85 d2                	test   %edx,%edx
  801d39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d41:	89 f3                	mov    %esi,%ebx
  801d43:	89 3c 24             	mov    %edi,(%esp)
  801d46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d4a:	75 1c                	jne    801d68 <__umoddi3+0x48>
  801d4c:	39 f7                	cmp    %esi,%edi
  801d4e:	76 50                	jbe    801da0 <__umoddi3+0x80>
  801d50:	89 c8                	mov    %ecx,%eax
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	f7 f7                	div    %edi
  801d56:	89 d0                	mov    %edx,%eax
  801d58:	31 d2                	xor    %edx,%edx
  801d5a:	83 c4 1c             	add    $0x1c,%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d68:	39 f2                	cmp    %esi,%edx
  801d6a:	89 d0                	mov    %edx,%eax
  801d6c:	77 52                	ja     801dc0 <__umoddi3+0xa0>
  801d6e:	0f bd ea             	bsr    %edx,%ebp
  801d71:	83 f5 1f             	xor    $0x1f,%ebp
  801d74:	75 5a                	jne    801dd0 <__umoddi3+0xb0>
  801d76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d7a:	0f 82 e0 00 00 00    	jb     801e60 <__umoddi3+0x140>
  801d80:	39 0c 24             	cmp    %ecx,(%esp)
  801d83:	0f 86 d7 00 00 00    	jbe    801e60 <__umoddi3+0x140>
  801d89:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d91:	83 c4 1c             	add    $0x1c,%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5f                   	pop    %edi
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	85 ff                	test   %edi,%edi
  801da2:	89 fd                	mov    %edi,%ebp
  801da4:	75 0b                	jne    801db1 <__umoddi3+0x91>
  801da6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dab:	31 d2                	xor    %edx,%edx
  801dad:	f7 f7                	div    %edi
  801daf:	89 c5                	mov    %eax,%ebp
  801db1:	89 f0                	mov    %esi,%eax
  801db3:	31 d2                	xor    %edx,%edx
  801db5:	f7 f5                	div    %ebp
  801db7:	89 c8                	mov    %ecx,%eax
  801db9:	f7 f5                	div    %ebp
  801dbb:	89 d0                	mov    %edx,%eax
  801dbd:	eb 99                	jmp    801d58 <__umoddi3+0x38>
  801dbf:	90                   	nop
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	83 c4 1c             	add    $0x1c,%esp
  801dc7:	5b                   	pop    %ebx
  801dc8:	5e                   	pop    %esi
  801dc9:	5f                   	pop    %edi
  801dca:	5d                   	pop    %ebp
  801dcb:	c3                   	ret    
  801dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	8b 34 24             	mov    (%esp),%esi
  801dd3:	bf 20 00 00 00       	mov    $0x20,%edi
  801dd8:	89 e9                	mov    %ebp,%ecx
  801dda:	29 ef                	sub    %ebp,%edi
  801ddc:	d3 e0                	shl    %cl,%eax
  801dde:	89 f9                	mov    %edi,%ecx
  801de0:	89 f2                	mov    %esi,%edx
  801de2:	d3 ea                	shr    %cl,%edx
  801de4:	89 e9                	mov    %ebp,%ecx
  801de6:	09 c2                	or     %eax,%edx
  801de8:	89 d8                	mov    %ebx,%eax
  801dea:	89 14 24             	mov    %edx,(%esp)
  801ded:	89 f2                	mov    %esi,%edx
  801def:	d3 e2                	shl    %cl,%edx
  801df1:	89 f9                	mov    %edi,%ecx
  801df3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801df7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dfb:	d3 e8                	shr    %cl,%eax
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	89 c6                	mov    %eax,%esi
  801e01:	d3 e3                	shl    %cl,%ebx
  801e03:	89 f9                	mov    %edi,%ecx
  801e05:	89 d0                	mov    %edx,%eax
  801e07:	d3 e8                	shr    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	09 d8                	or     %ebx,%eax
  801e0d:	89 d3                	mov    %edx,%ebx
  801e0f:	89 f2                	mov    %esi,%edx
  801e11:	f7 34 24             	divl   (%esp)
  801e14:	89 d6                	mov    %edx,%esi
  801e16:	d3 e3                	shl    %cl,%ebx
  801e18:	f7 64 24 04          	mull   0x4(%esp)
  801e1c:	39 d6                	cmp    %edx,%esi
  801e1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e22:	89 d1                	mov    %edx,%ecx
  801e24:	89 c3                	mov    %eax,%ebx
  801e26:	72 08                	jb     801e30 <__umoddi3+0x110>
  801e28:	75 11                	jne    801e3b <__umoddi3+0x11b>
  801e2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e2e:	73 0b                	jae    801e3b <__umoddi3+0x11b>
  801e30:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e34:	1b 14 24             	sbb    (%esp),%edx
  801e37:	89 d1                	mov    %edx,%ecx
  801e39:	89 c3                	mov    %eax,%ebx
  801e3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e3f:	29 da                	sub    %ebx,%edx
  801e41:	19 ce                	sbb    %ecx,%esi
  801e43:	89 f9                	mov    %edi,%ecx
  801e45:	89 f0                	mov    %esi,%eax
  801e47:	d3 e0                	shl    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	d3 ea                	shr    %cl,%edx
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	d3 ee                	shr    %cl,%esi
  801e51:	09 d0                	or     %edx,%eax
  801e53:	89 f2                	mov    %esi,%edx
  801e55:	83 c4 1c             	add    $0x1c,%esp
  801e58:	5b                   	pop    %ebx
  801e59:	5e                   	pop    %esi
  801e5a:	5f                   	pop    %edi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    
  801e5d:	8d 76 00             	lea    0x0(%esi),%esi
  801e60:	29 f9                	sub    %edi,%ecx
  801e62:	19 d6                	sbb    %edx,%esi
  801e64:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e6c:	e9 18 ff ff ff       	jmp    801d89 <__umoddi3+0x69>
