
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 b0 0e 00 00       	call   800eee <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 91 10 00 00       	call   8010ed <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 a0 22 80 00       	push   $0x8022a0
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 59 07 00 00       	call   8007d8 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 4e 08 00 00       	call   8008e1 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 b4 22 80 00       	push   $0x8022b4
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 20 07 00 00       	call   8007d8 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 3c 09 00 00       	call   800a0b <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 6c 10 00 00       	call   80114c <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 14 0b 00 00       	call   800c14 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 ca 06 00 00       	call   8007d8 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 e6 08 00 00       	call   800a0b <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 16 10 00 00       	call   80114c <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 a4 0f 00 00       	call   8010ed <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 a0 22 80 00       	push   $0x8022a0
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 6c 06 00 00       	call   8007d8 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 61 07 00 00       	call   8008e1 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 d4 22 80 00       	push   $0x8022d4
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8001a4:	e8 2d 0a 00 00       	call   800bd6 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 ba 11 00 00       	call   8013a4 <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 a1 09 00 00       	call   800b95 <sys_env_destroy>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 2f 09 00 00       	call   800b58 <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 54 01 00 00       	call   8003c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 d4 08 00 00       	call   800b58 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 45                	ja     800315 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 1c 1d 00 00       	call   802010 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 18                	jmp    80031f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	eb 03                	jmp    800318 <printnum+0x78>
  800315:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f e8                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	pushl  -0x1c(%ebp)
  800329:	ff 75 e0             	pushl  -0x20(%ebp)
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	e8 09 1e 00 00       	call   802140 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 4c 23 80 00 	movsbl 0x80234c(%eax),%eax
  800341:	50                   	push   %eax
  800342:	ff d7                	call   *%edi
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800352:	83 fa 01             	cmp    $0x1,%edx
  800355:	7e 0e                	jle    800365 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	8b 52 04             	mov    0x4(%edx),%edx
  800363:	eb 22                	jmp    800387 <getuint+0x38>
	else if (lflag)
  800365:	85 d2                	test   %edx,%edx
  800367:	74 10                	je     800379 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 0e                	jmp    800387 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 0a                	jae    8003a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	88 02                	mov    %al,(%edx)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	50                   	push   %eax
  8003b0:	ff 75 10             	pushl  0x10(%ebp)
  8003b3:	ff 75 0c             	pushl  0xc(%ebp)
  8003b6:	ff 75 08             	pushl  0x8(%ebp)
  8003b9:	e8 05 00 00 00       	call   8003c3 <vprintfmt>
	va_end(ap);
}
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	57                   	push   %edi
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 2c             	sub    $0x2c,%esp
  8003cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 89 03 00 00    	je     800768 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	53                   	push   %ebx
  8003e3:	50                   	push   %eax
  8003e4:	ff d6                	call   *%esi
  8003e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	83 c7 01             	add    $0x1,%edi
  8003ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f0:	83 f8 25             	cmp    $0x25,%eax
  8003f3:	75 e2                	jne    8003d7 <vprintfmt+0x14>
  8003f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800400:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800407:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80040e:	ba 00 00 00 00       	mov    $0x0,%edx
  800413:	eb 07                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800418:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8d 47 01             	lea    0x1(%edi),%eax
  80041f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800422:	0f b6 07             	movzbl (%edi),%eax
  800425:	0f b6 c8             	movzbl %al,%ecx
  800428:	83 e8 23             	sub    $0x23,%eax
  80042b:	3c 55                	cmp    $0x55,%al
  80042d:	0f 87 1a 03 00 00    	ja     80074d <vprintfmt+0x38a>
  800433:	0f b6 c0             	movzbl %al,%eax
  800436:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800440:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800444:	eb d6                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800449:	b8 00 00 00 00       	mov    $0x0,%eax
  80044e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800451:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800454:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800458:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80045b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80045e:	83 fa 09             	cmp    $0x9,%edx
  800461:	77 39                	ja     80049c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800463:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800466:	eb e9                	jmp    800451 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 48 04             	lea    0x4(%eax),%ecx
  80046e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800471:	8b 00                	mov    (%eax),%eax
  800473:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800479:	eb 27                	jmp    8004a2 <vprintfmt+0xdf>
  80047b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047e:	85 c0                	test   %eax,%eax
  800480:	b9 00 00 00 00       	mov    $0x0,%ecx
  800485:	0f 49 c8             	cmovns %eax,%ecx
  800488:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048e:	eb 8c                	jmp    80041c <vprintfmt+0x59>
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800493:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049a:	eb 80                	jmp    80041c <vprintfmt+0x59>
  80049c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a6:	0f 89 70 ff ff ff    	jns    80041c <vprintfmt+0x59>
				width = precision, precision = -1;
  8004ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b9:	e9 5e ff ff ff       	jmp    80041c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004be:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c4:	e9 53 ff ff ff       	jmp    80041c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 50 04             	lea    0x4(%eax),%edx
  8004cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	ff 30                	pushl  (%eax)
  8004d8:	ff d6                	call   *%esi
			break;
  8004da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e0:	e9 04 ff ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	8d 50 04             	lea    0x4(%eax),%edx
  8004eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ee:	8b 00                	mov    (%eax),%eax
  8004f0:	99                   	cltd   
  8004f1:	31 d0                	xor    %edx,%eax
  8004f3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f5:	83 f8 0f             	cmp    $0xf,%eax
  8004f8:	7f 0b                	jg     800505 <vprintfmt+0x142>
  8004fa:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	75 18                	jne    80051d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800505:	50                   	push   %eax
  800506:	68 64 23 80 00       	push   $0x802364
  80050b:	53                   	push   %ebx
  80050c:	56                   	push   %esi
  80050d:	e8 94 fe ff ff       	call   8003a6 <printfmt>
  800512:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800518:	e9 cc fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80051d:	52                   	push   %edx
  80051e:	68 dd 27 80 00       	push   $0x8027dd
  800523:	53                   	push   %ebx
  800524:	56                   	push   %esi
  800525:	e8 7c fe ff ff       	call   8003a6 <printfmt>
  80052a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800530:	e9 b4 fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800540:	85 ff                	test   %edi,%edi
  800542:	b8 5d 23 80 00       	mov    $0x80235d,%eax
  800547:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054e:	0f 8e 94 00 00 00    	jle    8005e8 <vprintfmt+0x225>
  800554:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800558:	0f 84 98 00 00 00    	je     8005f6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 d0             	pushl  -0x30(%ebp)
  800564:	57                   	push   %edi
  800565:	e8 86 02 00 00       	call   8007f0 <strnlen>
  80056a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056d:	29 c1                	sub    %eax,%ecx
  80056f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800572:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800575:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800579:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80057f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	eb 0f                	jmp    800592 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	53                   	push   %ebx
  800587:	ff 75 e0             	pushl  -0x20(%ebp)
  80058a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058c:	83 ef 01             	sub    $0x1,%edi
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	85 ff                	test   %edi,%edi
  800594:	7f ed                	jg     800583 <vprintfmt+0x1c0>
  800596:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800599:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059c:	85 c9                	test   %ecx,%ecx
  80059e:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a3:	0f 49 c1             	cmovns %ecx,%eax
  8005a6:	29 c1                	sub    %eax,%ecx
  8005a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b1:	89 cb                	mov    %ecx,%ebx
  8005b3:	eb 4d                	jmp    800602 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b9:	74 1b                	je     8005d6 <vprintfmt+0x213>
  8005bb:	0f be c0             	movsbl %al,%eax
  8005be:	83 e8 20             	sub    $0x20,%eax
  8005c1:	83 f8 5e             	cmp    $0x5e,%eax
  8005c4:	76 10                	jbe    8005d6 <vprintfmt+0x213>
					putch('?', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	ff 75 0c             	pushl  0xc(%ebp)
  8005cc:	6a 3f                	push   $0x3f
  8005ce:	ff 55 08             	call   *0x8(%ebp)
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	eb 0d                	jmp    8005e3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	ff 75 0c             	pushl  0xc(%ebp)
  8005dc:	52                   	push   %edx
  8005dd:	ff 55 08             	call   *0x8(%ebp)
  8005e0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e3:	83 eb 01             	sub    $0x1,%ebx
  8005e6:	eb 1a                	jmp    800602 <vprintfmt+0x23f>
  8005e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f4:	eb 0c                	jmp    800602 <vprintfmt+0x23f>
  8005f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800602:	83 c7 01             	add    $0x1,%edi
  800605:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800609:	0f be d0             	movsbl %al,%edx
  80060c:	85 d2                	test   %edx,%edx
  80060e:	74 23                	je     800633 <vprintfmt+0x270>
  800610:	85 f6                	test   %esi,%esi
  800612:	78 a1                	js     8005b5 <vprintfmt+0x1f2>
  800614:	83 ee 01             	sub    $0x1,%esi
  800617:	79 9c                	jns    8005b5 <vprintfmt+0x1f2>
  800619:	89 df                	mov    %ebx,%edi
  80061b:	8b 75 08             	mov    0x8(%ebp),%esi
  80061e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800621:	eb 18                	jmp    80063b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	53                   	push   %ebx
  800627:	6a 20                	push   $0x20
  800629:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062b:	83 ef 01             	sub    $0x1,%edi
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	eb 08                	jmp    80063b <vprintfmt+0x278>
  800633:	89 df                	mov    %ebx,%edi
  800635:	8b 75 08             	mov    0x8(%ebp),%esi
  800638:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063b:	85 ff                	test   %edi,%edi
  80063d:	7f e4                	jg     800623 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800642:	e9 a2 fd ff ff       	jmp    8003e9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800647:	83 fa 01             	cmp    $0x1,%edx
  80064a:	7e 16                	jle    800662 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 08             	lea    0x8(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 50 04             	mov    0x4(%eax),%edx
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800660:	eb 32                	jmp    800694 <vprintfmt+0x2d1>
	else if (lflag)
  800662:	85 d2                	test   %edx,%edx
  800664:	74 18                	je     80067e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	89 c1                	mov    %eax,%ecx
  800676:	c1 f9 1f             	sar    $0x1f,%ecx
  800679:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80067c:	eb 16                	jmp    800694 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 00                	mov    (%eax),%eax
  800689:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068c:	89 c1                	mov    %eax,%ecx
  80068e:	c1 f9 1f             	sar    $0x1f,%ecx
  800691:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800694:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800697:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a3:	79 74                	jns    800719 <vprintfmt+0x356>
				putch('-', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 2d                	push   $0x2d
  8006ab:	ff d6                	call   *%esi
				num = -(long long) num;
  8006ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b3:	f7 d8                	neg    %eax
  8006b5:	83 d2 00             	adc    $0x0,%edx
  8006b8:	f7 da                	neg    %edx
  8006ba:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c2:	eb 55                	jmp    800719 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c7:	e8 83 fc ff ff       	call   80034f <getuint>
			base = 10;
  8006cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d1:	eb 46                	jmp    800719 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	e8 74 fc ff ff       	call   80034f <getuint>
			base = 8;
  8006db:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006e0:	eb 37                	jmp    800719 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 30                	push   $0x30
  8006e8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ea:	83 c4 08             	add    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 78                	push   $0x78
  8006f0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 04             	lea    0x4(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800702:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800705:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80070a:	eb 0d                	jmp    800719 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
  80070f:	e8 3b fc ff ff       	call   80034f <getuint>
			base = 16;
  800714:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800719:	83 ec 0c             	sub    $0xc,%esp
  80071c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800720:	57                   	push   %edi
  800721:	ff 75 e0             	pushl  -0x20(%ebp)
  800724:	51                   	push   %ecx
  800725:	52                   	push   %edx
  800726:	50                   	push   %eax
  800727:	89 da                	mov    %ebx,%edx
  800729:	89 f0                	mov    %esi,%eax
  80072b:	e8 70 fb ff ff       	call   8002a0 <printnum>
			break;
  800730:	83 c4 20             	add    $0x20,%esp
  800733:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800736:	e9 ae fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	51                   	push   %ecx
  800740:	ff d6                	call   *%esi
			break;
  800742:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800748:	e9 9c fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	53                   	push   %ebx
  800751:	6a 25                	push   $0x25
  800753:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	eb 03                	jmp    80075d <vprintfmt+0x39a>
  80075a:	83 ef 01             	sub    $0x1,%edi
  80075d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800761:	75 f7                	jne    80075a <vprintfmt+0x397>
  800763:	e9 81 fc ff ff       	jmp    8003e9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800768:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 18             	sub    $0x18,%esp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800783:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800786:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078d:	85 c0                	test   %eax,%eax
  80078f:	74 26                	je     8007b7 <vsnprintf+0x47>
  800791:	85 d2                	test   %edx,%edx
  800793:	7e 22                	jle    8007b7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800795:	ff 75 14             	pushl  0x14(%ebp)
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079e:	50                   	push   %eax
  80079f:	68 89 03 80 00       	push   $0x800389
  8007a4:	e8 1a fc ff ff       	call   8003c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 05                	jmp    8007bc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    

008007be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c7:	50                   	push   %eax
  8007c8:	ff 75 10             	pushl  0x10(%ebp)
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	ff 75 08             	pushl  0x8(%ebp)
  8007d1:	e8 9a ff ff ff       	call   800770 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 03                	jmp    8007e8 <strlen+0x10>
		n++;
  8007e5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ec:	75 f7                	jne    8007e5 <strlen+0xd>
		n++;
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fe:	eb 03                	jmp    800803 <strnlen+0x13>
		n++;
  800800:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 c2                	cmp    %eax,%edx
  800805:	74 08                	je     80080f <strnlen+0x1f>
  800807:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080b:	75 f3                	jne    800800 <strnlen+0x10>
  80080d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081b:	89 c2                	mov    %eax,%edx
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	83 c1 01             	add    $0x1,%ecx
  800823:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800827:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082a:	84 db                	test   %bl,%bl
  80082c:	75 ef                	jne    80081d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082e:	5b                   	pop    %ebx
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	53                   	push   %ebx
  800835:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800838:	53                   	push   %ebx
  800839:	e8 9a ff ff ff       	call   8007d8 <strlen>
  80083e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800841:	ff 75 0c             	pushl  0xc(%ebp)
  800844:	01 d8                	add    %ebx,%eax
  800846:	50                   	push   %eax
  800847:	e8 c5 ff ff ff       	call   800811 <strcpy>
	return dst;
}
  80084c:	89 d8                	mov    %ebx,%eax
  80084e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 75 08             	mov    0x8(%ebp),%esi
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085e:	89 f3                	mov    %esi,%ebx
  800860:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800863:	89 f2                	mov    %esi,%edx
  800865:	eb 0f                	jmp    800876 <strncpy+0x23>
		*dst++ = *src;
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	0f b6 01             	movzbl (%ecx),%eax
  80086d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800870:	80 39 01             	cmpb   $0x1,(%ecx)
  800873:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800876:	39 da                	cmp    %ebx,%edx
  800878:	75 ed                	jne    800867 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087a:	89 f0                	mov    %esi,%eax
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 75 08             	mov    0x8(%ebp),%esi
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 55 10             	mov    0x10(%ebp),%edx
  80088e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800890:	85 d2                	test   %edx,%edx
  800892:	74 21                	je     8008b5 <strlcpy+0x35>
  800894:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800898:	89 f2                	mov    %esi,%edx
  80089a:	eb 09                	jmp    8008a5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089c:	83 c2 01             	add    $0x1,%edx
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a5:	39 c2                	cmp    %eax,%edx
  8008a7:	74 09                	je     8008b2 <strlcpy+0x32>
  8008a9:	0f b6 19             	movzbl (%ecx),%ebx
  8008ac:	84 db                	test   %bl,%bl
  8008ae:	75 ec                	jne    80089c <strlcpy+0x1c>
  8008b0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b5:	29 f0                	sub    %esi,%eax
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5e                   	pop    %esi
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c4:	eb 06                	jmp    8008cc <strcmp+0x11>
		p++, q++;
  8008c6:	83 c1 01             	add    $0x1,%ecx
  8008c9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cc:	0f b6 01             	movzbl (%ecx),%eax
  8008cf:	84 c0                	test   %al,%al
  8008d1:	74 04                	je     8008d7 <strcmp+0x1c>
  8008d3:	3a 02                	cmp    (%edx),%al
  8008d5:	74 ef                	je     8008c6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 c0             	movzbl %al,%eax
  8008da:	0f b6 12             	movzbl (%edx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	53                   	push   %ebx
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008eb:	89 c3                	mov    %eax,%ebx
  8008ed:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f0:	eb 06                	jmp    8008f8 <strncmp+0x17>
		n--, p++, q++;
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f8:	39 d8                	cmp    %ebx,%eax
  8008fa:	74 15                	je     800911 <strncmp+0x30>
  8008fc:	0f b6 08             	movzbl (%eax),%ecx
  8008ff:	84 c9                	test   %cl,%cl
  800901:	74 04                	je     800907 <strncmp+0x26>
  800903:	3a 0a                	cmp    (%edx),%cl
  800905:	74 eb                	je     8008f2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800907:	0f b6 00             	movzbl (%eax),%eax
  80090a:	0f b6 12             	movzbl (%edx),%edx
  80090d:	29 d0                	sub    %edx,%eax
  80090f:	eb 05                	jmp    800916 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800916:	5b                   	pop    %ebx
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800923:	eb 07                	jmp    80092c <strchr+0x13>
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 0f                	je     800938 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	0f b6 10             	movzbl (%eax),%edx
  80092f:	84 d2                	test   %dl,%dl
  800931:	75 f2                	jne    800925 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800944:	eb 03                	jmp    800949 <strfind+0xf>
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	74 04                	je     800954 <strfind+0x1a>
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f2                	jne    800946 <strfind+0xc>
			break;
	return (char *) s;
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	57                   	push   %edi
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800962:	85 c9                	test   %ecx,%ecx
  800964:	74 36                	je     80099c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800966:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096c:	75 28                	jne    800996 <memset+0x40>
  80096e:	f6 c1 03             	test   $0x3,%cl
  800971:	75 23                	jne    800996 <memset+0x40>
		c &= 0xFF;
  800973:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800977:	89 d3                	mov    %edx,%ebx
  800979:	c1 e3 08             	shl    $0x8,%ebx
  80097c:	89 d6                	mov    %edx,%esi
  80097e:	c1 e6 18             	shl    $0x18,%esi
  800981:	89 d0                	mov    %edx,%eax
  800983:	c1 e0 10             	shl    $0x10,%eax
  800986:	09 f0                	or     %esi,%eax
  800988:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098a:	89 d8                	mov    %ebx,%eax
  80098c:	09 d0                	or     %edx,%eax
  80098e:	c1 e9 02             	shr    $0x2,%ecx
  800991:	fc                   	cld    
  800992:	f3 ab                	rep stos %eax,%es:(%edi)
  800994:	eb 06                	jmp    80099c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800996:	8b 45 0c             	mov    0xc(%ebp),%eax
  800999:	fc                   	cld    
  80099a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099c:	89 f8                	mov    %edi,%eax
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5f                   	pop    %edi
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b1:	39 c6                	cmp    %eax,%esi
  8009b3:	73 35                	jae    8009ea <memmove+0x47>
  8009b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b8:	39 d0                	cmp    %edx,%eax
  8009ba:	73 2e                	jae    8009ea <memmove+0x47>
		s += n;
		d += n;
  8009bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bf:	89 d6                	mov    %edx,%esi
  8009c1:	09 fe                	or     %edi,%esi
  8009c3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c9:	75 13                	jne    8009de <memmove+0x3b>
  8009cb:	f6 c1 03             	test   $0x3,%cl
  8009ce:	75 0e                	jne    8009de <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d0:	83 ef 04             	sub    $0x4,%edi
  8009d3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
  8009d9:	fd                   	std    
  8009da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009dc:	eb 09                	jmp    8009e7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009de:	83 ef 01             	sub    $0x1,%edi
  8009e1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e4:	fd                   	std    
  8009e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e7:	fc                   	cld    
  8009e8:	eb 1d                	jmp    800a07 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ea:	89 f2                	mov    %esi,%edx
  8009ec:	09 c2                	or     %eax,%edx
  8009ee:	f6 c2 03             	test   $0x3,%dl
  8009f1:	75 0f                	jne    800a02 <memmove+0x5f>
  8009f3:	f6 c1 03             	test   $0x3,%cl
  8009f6:	75 0a                	jne    800a02 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009f8:	c1 e9 02             	shr    $0x2,%ecx
  8009fb:	89 c7                	mov    %eax,%edi
  8009fd:	fc                   	cld    
  8009fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a00:	eb 05                	jmp    800a07 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a02:	89 c7                	mov    %eax,%edi
  800a04:	fc                   	cld    
  800a05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0e:	ff 75 10             	pushl  0x10(%ebp)
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	ff 75 08             	pushl  0x8(%ebp)
  800a17:	e8 87 ff ff ff       	call   8009a3 <memmove>
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a29:	89 c6                	mov    %eax,%esi
  800a2b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	eb 1a                	jmp    800a4a <memcmp+0x2c>
		if (*s1 != *s2)
  800a30:	0f b6 08             	movzbl (%eax),%ecx
  800a33:	0f b6 1a             	movzbl (%edx),%ebx
  800a36:	38 d9                	cmp    %bl,%cl
  800a38:	74 0a                	je     800a44 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3a:	0f b6 c1             	movzbl %cl,%eax
  800a3d:	0f b6 db             	movzbl %bl,%ebx
  800a40:	29 d8                	sub    %ebx,%eax
  800a42:	eb 0f                	jmp    800a53 <memcmp+0x35>
		s1++, s2++;
  800a44:	83 c0 01             	add    $0x1,%eax
  800a47:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4a:	39 f0                	cmp    %esi,%eax
  800a4c:	75 e2                	jne    800a30 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5e:	89 c1                	mov    %eax,%ecx
  800a60:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a63:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a67:	eb 0a                	jmp    800a73 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a69:	0f b6 10             	movzbl (%eax),%edx
  800a6c:	39 da                	cmp    %ebx,%edx
  800a6e:	74 07                	je     800a77 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a70:	83 c0 01             	add    $0x1,%eax
  800a73:	39 c8                	cmp    %ecx,%eax
  800a75:	72 f2                	jb     800a69 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a86:	eb 03                	jmp    800a8b <strtol+0x11>
		s++;
  800a88:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8b:	0f b6 01             	movzbl (%ecx),%eax
  800a8e:	3c 20                	cmp    $0x20,%al
  800a90:	74 f6                	je     800a88 <strtol+0xe>
  800a92:	3c 09                	cmp    $0x9,%al
  800a94:	74 f2                	je     800a88 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a96:	3c 2b                	cmp    $0x2b,%al
  800a98:	75 0a                	jne    800aa4 <strtol+0x2a>
		s++;
  800a9a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9d:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa2:	eb 11                	jmp    800ab5 <strtol+0x3b>
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa9:	3c 2d                	cmp    $0x2d,%al
  800aab:	75 08                	jne    800ab5 <strtol+0x3b>
		s++, neg = 1;
  800aad:	83 c1 01             	add    $0x1,%ecx
  800ab0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abb:	75 15                	jne    800ad2 <strtol+0x58>
  800abd:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac0:	75 10                	jne    800ad2 <strtol+0x58>
  800ac2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac6:	75 7c                	jne    800b44 <strtol+0xca>
		s += 2, base = 16;
  800ac8:	83 c1 02             	add    $0x2,%ecx
  800acb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad0:	eb 16                	jmp    800ae8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad2:	85 db                	test   %ebx,%ebx
  800ad4:	75 12                	jne    800ae8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adb:	80 39 30             	cmpb   $0x30,(%ecx)
  800ade:	75 08                	jne    800ae8 <strtol+0x6e>
		s++, base = 8;
  800ae0:	83 c1 01             	add    $0x1,%ecx
  800ae3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af0:	0f b6 11             	movzbl (%ecx),%edx
  800af3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af6:	89 f3                	mov    %esi,%ebx
  800af8:	80 fb 09             	cmp    $0x9,%bl
  800afb:	77 08                	ja     800b05 <strtol+0x8b>
			dig = *s - '0';
  800afd:	0f be d2             	movsbl %dl,%edx
  800b00:	83 ea 30             	sub    $0x30,%edx
  800b03:	eb 22                	jmp    800b27 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b05:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b08:	89 f3                	mov    %esi,%ebx
  800b0a:	80 fb 19             	cmp    $0x19,%bl
  800b0d:	77 08                	ja     800b17 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b0f:	0f be d2             	movsbl %dl,%edx
  800b12:	83 ea 57             	sub    $0x57,%edx
  800b15:	eb 10                	jmp    800b27 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b17:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1a:	89 f3                	mov    %esi,%ebx
  800b1c:	80 fb 19             	cmp    $0x19,%bl
  800b1f:	77 16                	ja     800b37 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b27:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2a:	7d 0b                	jge    800b37 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b33:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b35:	eb b9                	jmp    800af0 <strtol+0x76>

	if (endptr)
  800b37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3b:	74 0d                	je     800b4a <strtol+0xd0>
		*endptr = (char *) s;
  800b3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b40:	89 0e                	mov    %ecx,(%esi)
  800b42:	eb 06                	jmp    800b4a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b44:	85 db                	test   %ebx,%ebx
  800b46:	74 98                	je     800ae0 <strtol+0x66>
  800b48:	eb 9e                	jmp    800ae8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4a:	89 c2                	mov    %eax,%edx
  800b4c:	f7 da                	neg    %edx
  800b4e:	85 ff                	test   %edi,%edi
  800b50:	0f 45 c2             	cmovne %edx,%eax
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	89 c7                	mov    %eax,%edi
  800b6d:	89 c6                	mov    %eax,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 01 00 00 00       	mov    $0x1,%eax
  800b86:	89 d1                	mov    %edx,%ecx
  800b88:	89 d3                	mov    %edx,%ebx
  800b8a:	89 d7                	mov    %edx,%edi
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
  800b9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	89 cb                	mov    %ecx,%ebx
  800bad:	89 cf                	mov    %ecx,%edi
  800baf:	89 ce                	mov    %ecx,%esi
  800bb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7e 17                	jle    800bce <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	50                   	push   %eax
  800bbb:	6a 03                	push   $0x3
  800bbd:	68 3f 26 80 00       	push   $0x80263f
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 5c 26 80 00       	push   $0x80265c
  800bc9:	e8 3e 13 00 00       	call   801f0c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 02 00 00 00       	mov    $0x2,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_yield>:

void
sys_yield(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	be 00 00 00 00       	mov    $0x0,%esi
  800c22:	b8 04 00 00 00       	mov    $0x4,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c30:	89 f7                	mov    %esi,%edi
  800c32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 17                	jle    800c4f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	50                   	push   %eax
  800c3c:	6a 04                	push   $0x4
  800c3e:	68 3f 26 80 00       	push   $0x80263f
  800c43:	6a 23                	push   $0x23
  800c45:	68 5c 26 80 00       	push   $0x80265c
  800c4a:	e8 bd 12 00 00       	call   801f0c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	b8 05 00 00 00       	mov    $0x5,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 75 18             	mov    0x18(%ebp),%esi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 05                	push   $0x5
  800c80:	68 3f 26 80 00       	push   $0x80263f
  800c85:	6a 23                	push   $0x23
  800c87:	68 5c 26 80 00       	push   $0x80265c
  800c8c:	e8 7b 12 00 00       	call   801f0c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 df                	mov    %ebx,%edi
  800cb4:	89 de                	mov    %ebx,%esi
  800cb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 06                	push   $0x6
  800cc2:	68 3f 26 80 00       	push   $0x80263f
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 5c 26 80 00       	push   $0x80265c
  800cce:	e8 39 12 00 00       	call   801f0c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 17                	jle    800d15 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 08                	push   $0x8
  800d04:	68 3f 26 80 00       	push   $0x80263f
  800d09:	6a 23                	push   $0x23
  800d0b:	68 5c 26 80 00       	push   $0x80265c
  800d10:	e8 f7 11 00 00       	call   801f0c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 df                	mov    %ebx,%edi
  800d38:	89 de                	mov    %ebx,%esi
  800d3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 17                	jle    800d57 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 09                	push   $0x9
  800d46:	68 3f 26 80 00       	push   $0x80263f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 5c 26 80 00       	push   $0x80265c
  800d52:	e8 b5 11 00 00       	call   801f0c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	89 df                	mov    %ebx,%edi
  800d7a:	89 de                	mov    %ebx,%esi
  800d7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 17                	jle    800d99 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	50                   	push   %eax
  800d86:	6a 0a                	push   $0xa
  800d88:	68 3f 26 80 00       	push   $0x80263f
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 5c 26 80 00       	push   $0x80265c
  800d94:	e8 73 11 00 00       	call   801f0c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da7:	be 00 00 00 00       	mov    $0x0,%esi
  800dac:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 cb                	mov    %ecx,%ebx
  800ddc:	89 cf                	mov    %ecx,%edi
  800dde:	89 ce                	mov    %ecx,%esi
  800de0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 17                	jle    800dfd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 0d                	push   $0xd
  800dec:	68 3f 26 80 00       	push   $0x80263f
  800df1:	6a 23                	push   $0x23
  800df3:	68 5c 26 80 00       	push   $0x80265c
  800df8:	e8 0f 11 00 00       	call   801f0c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	53                   	push   %ebx
  800e09:	83 ec 04             	sub    $0x4,%esp
  800e0c:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  800e0f:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  800e11:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  800e14:	89 da                	mov    %ebx,%edx
  800e16:	c1 ea 0c             	shr    $0xc,%edx
  800e19:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  800e20:	a8 02                	test   $0x2,%al
  800e22:	75 12                	jne    800e36 <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  800e24:	50                   	push   %eax
  800e25:	68 6c 26 80 00       	push   $0x80266c
  800e2a:	6a 21                	push   $0x21
  800e2c:	68 8d 26 80 00       	push   $0x80268d
  800e31:	e8 d6 10 00 00       	call   801f0c <_panic>
	   } else if (!(pte & PTE_COW)) {
  800e36:	f6 c6 08             	test   $0x8,%dh
  800e39:	75 14                	jne    800e4f <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  800e3b:	83 ec 04             	sub    $0x4,%esp
  800e3e:	68 98 26 80 00       	push   $0x802698
  800e43:	6a 23                	push   $0x23
  800e45:	68 8d 26 80 00       	push   $0x80268d
  800e4a:	e8 bd 10 00 00       	call   801f0c <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  800e4f:	83 ec 04             	sub    $0x4,%esp
  800e52:	6a 07                	push   $0x7
  800e54:	68 00 00 40 00       	push   $0x400000
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 b4 fd ff ff       	call   800c14 <sys_page_alloc>
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	79 12                	jns    800e79 <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  800e67:	50                   	push   %eax
  800e68:	68 b5 26 80 00       	push   $0x8026b5
  800e6d:	6a 2e                	push   $0x2e
  800e6f:	68 8d 26 80 00       	push   $0x80268d
  800e74:	e8 93 10 00 00       	call   801f0c <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800e79:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e7f:	83 ec 04             	sub    $0x4,%esp
  800e82:	68 00 10 00 00       	push   $0x1000
  800e87:	53                   	push   %ebx
  800e88:	68 00 00 40 00       	push   $0x400000
  800e8d:	e8 11 fb ff ff       	call   8009a3 <memmove>
	   if ((r = sys_page_map(0,
  800e92:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e99:	53                   	push   %ebx
  800e9a:	6a 00                	push   $0x0
  800e9c:	68 00 00 40 00       	push   $0x400000
  800ea1:	6a 00                	push   $0x0
  800ea3:	e8 af fd ff ff       	call   800c57 <sys_page_map>
  800ea8:	83 c4 20             	add    $0x20,%esp
  800eab:	85 c0                	test   %eax,%eax
  800ead:	79 12                	jns    800ec1 <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  800eaf:	50                   	push   %eax
  800eb0:	68 c8 26 80 00       	push   $0x8026c8
  800eb5:	6a 36                	push   $0x36
  800eb7:	68 8d 26 80 00       	push   $0x80268d
  800ebc:	e8 4b 10 00 00       	call   801f0c <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  800ec1:	83 ec 08             	sub    $0x8,%esp
  800ec4:	68 00 00 40 00       	push   $0x400000
  800ec9:	6a 00                	push   $0x0
  800ecb:	e8 c9 fd ff ff       	call   800c99 <sys_page_unmap>
  800ed0:	83 c4 10             	add    $0x10,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	79 12                	jns    800ee9 <pgfault+0xe4>
			 panic("unmap %e", r);
  800ed7:	50                   	push   %eax
  800ed8:	68 d8 26 80 00       	push   $0x8026d8
  800edd:	6a 39                	push   $0x39
  800edf:	68 8d 26 80 00       	push   $0x80268d
  800ee4:	e8 23 10 00 00       	call   801f0c <_panic>
	   }
}
  800ee9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    

00800eee <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  800ef7:	68 05 0e 80 00       	push   $0x800e05
  800efc:	e8 51 10 00 00       	call   801f52 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f01:	b8 07 00 00 00       	mov    $0x7,%eax
  800f06:	cd 30                	int    $0x30
  800f08:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f0b:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  800f0e:	83 c4 10             	add    $0x10,%esp
  800f11:	85 c0                	test   %eax,%eax
  800f13:	79 15                	jns    800f2a <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  800f15:	50                   	push   %eax
  800f16:	68 e1 26 80 00       	push   $0x8026e1
  800f1b:	68 81 00 00 00       	push   $0x81
  800f20:	68 8d 26 80 00       	push   $0x80268d
  800f25:	e8 e2 0f 00 00       	call   801f0c <_panic>
  800f2a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800f31:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  800f35:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800f39:	75 1c                	jne    800f57 <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  800f3b:	e8 96 fc ff ff       	call   800bd6 <sys_getenvid>
  800f40:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f45:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f48:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f4d:	a3 04 40 80 00       	mov    %eax,0x804004
			 return envid;
  800f52:	e9 71 01 00 00       	jmp    8010c8 <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  800f57:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800f5a:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800f61:	a8 01                	test   $0x1,%al
  800f63:	0f 84 18 01 00 00    	je     801081 <fork+0x193>
  800f69:	89 fb                	mov    %edi,%ebx
  800f6b:	c1 e3 0a             	shl    $0xa,%ebx
  800f6e:	c1 e7 16             	shl    $0x16,%edi
  800f71:	be 00 00 00 00       	mov    $0x0,%esi
  800f76:	e9 f4 00 00 00       	jmp    80106f <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  800f7b:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800f81:	0f 84 dc 00 00 00    	je     801063 <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  800f87:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800f8d:	0f 87 cc 00 00 00    	ja     80105f <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  800f93:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f9a:	a8 01                	test   $0x1,%al
  800f9c:	0f 84 c1 00 00 00    	je     801063 <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  800fa2:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  800fa9:	a9 02 08 00 00       	test   $0x802,%eax
  800fae:	74 05                	je     800fb5 <fork+0xc7>
  800fb0:	f6 c4 04             	test   $0x4,%ah
  800fb3:	74 3a                	je     800fef <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  800fb5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fbb:	8b 52 48             	mov    0x48(%edx),%edx
  800fbe:	83 ec 0c             	sub    $0xc,%esp
  800fc1:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc6:	50                   	push   %eax
  800fc7:	57                   	push   %edi
  800fc8:	ff 75 dc             	pushl  -0x24(%ebp)
  800fcb:	57                   	push   %edi
  800fcc:	52                   	push   %edx
  800fcd:	e8 85 fc ff ff       	call   800c57 <sys_page_map>
  800fd2:	83 c4 20             	add    $0x20,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	0f 89 86 00 00 00    	jns    801063 <fork+0x175>
				    panic("sys_page_map: %e", r);
  800fdd:	50                   	push   %eax
  800fde:	68 f1 26 80 00       	push   $0x8026f1
  800fe3:	6a 52                	push   $0x52
  800fe5:	68 8d 26 80 00       	push   $0x80268d
  800fea:	e8 1d 0f 00 00       	call   801f0c <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  800fef:	25 05 06 00 00       	and    $0x605,%eax
  800ff4:	80 cc 08             	or     $0x8,%ah
  800ff7:	89 c1                	mov    %eax,%ecx
  800ff9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ffc:	a1 04 40 80 00       	mov    0x804004,%eax
  801001:	8b 40 48             	mov    0x48(%eax),%eax
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	51                   	push   %ecx
  801008:	57                   	push   %edi
  801009:	ff 75 dc             	pushl  -0x24(%ebp)
  80100c:	57                   	push   %edi
  80100d:	50                   	push   %eax
  80100e:	e8 44 fc ff ff       	call   800c57 <sys_page_map>
  801013:	83 c4 20             	add    $0x20,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	79 12                	jns    80102c <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  80101a:	50                   	push   %eax
  80101b:	68 f1 26 80 00       	push   $0x8026f1
  801020:	6a 5d                	push   $0x5d
  801022:	68 8d 26 80 00       	push   $0x80268d
  801027:	e8 e0 0e 00 00       	call   801f0c <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  80102c:	a1 04 40 80 00       	mov    0x804004,%eax
  801031:	8b 50 48             	mov    0x48(%eax),%edx
  801034:	8b 40 48             	mov    0x48(%eax),%eax
  801037:	83 ec 0c             	sub    $0xc,%esp
  80103a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80103d:	57                   	push   %edi
  80103e:	52                   	push   %edx
  80103f:	57                   	push   %edi
  801040:	50                   	push   %eax
  801041:	e8 11 fc ff ff       	call   800c57 <sys_page_map>
  801046:	83 c4 20             	add    $0x20,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 16                	jns    801063 <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  80104d:	50                   	push   %eax
  80104e:	68 f1 26 80 00       	push   $0x8026f1
  801053:	6a 63                	push   $0x63
  801055:	68 8d 26 80 00       	push   $0x80268d
  80105a:	e8 ad 0e 00 00       	call   801f0c <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  80105f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  801063:	83 c6 01             	add    $0x1,%esi
  801066:	83 c3 01             	add    $0x1,%ebx
  801069:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80106f:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  801075:	7f 0a                	jg     801081 <fork+0x193>
  801077:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80107b:	0f 85 fa fe ff ff    	jne    800f7b <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  801081:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  801085:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801088:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80108d:	7f 0a                	jg     801099 <fork+0x1ab>
  80108f:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801093:	0f 85 be fe ff ff    	jne    800f57 <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801099:	83 ec 08             	sub    $0x8,%esp
  80109c:	68 ab 1f 80 00       	push   $0x801fab
  8010a1:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8010a4:	56                   	push   %esi
  8010a5:	e8 b5 fc ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  8010aa:	83 c4 0c             	add    $0xc,%esp
  8010ad:	6a 06                	push   $0x6
  8010af:	68 00 f0 bf ee       	push   $0xeebff000
  8010b4:	56                   	push   %esi
  8010b5:	e8 5a fb ff ff       	call   800c14 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  8010ba:	83 c4 08             	add    $0x8,%esp
  8010bd:	6a 02                	push   $0x2
  8010bf:	56                   	push   %esi
  8010c0:	e8 16 fc ff ff       	call   800cdb <sys_env_set_status>

	   return envid;
  8010c5:	83 c4 10             	add    $0x10,%esp
}
  8010c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8010cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5f                   	pop    %edi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <sfork>:
// Challenge!
	   int
sfork(void)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  8010d9:	68 02 27 80 00       	push   $0x802702
  8010de:	68 a7 00 00 00       	push   $0xa7
  8010e3:	68 8d 26 80 00       	push   $0x80268d
  8010e8:	e8 1f 0e 00 00       	call   801f0c <_panic>

008010ed <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
  8010f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8010f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  8010fb:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  8010fd:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801102:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	50                   	push   %eax
  801109:	e8 b6 fc ff ff       	call   800dc4 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	78 0e                	js     801123 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801115:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80111b:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  80111e:	8b 52 78             	mov    0x78(%edx),%edx
  801121:	eb 0a                	jmp    80112d <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801123:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801128:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  80112d:	85 f6                	test   %esi,%esi
  80112f:	74 02                	je     801133 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801131:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801133:	85 db                	test   %ebx,%ebx
  801135:	74 02                	je     801139 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801137:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 08                	js     801145 <ipc_recv+0x58>
  80113d:	a1 04 40 80 00       	mov    0x804004,%eax
  801142:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801145:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	57                   	push   %edi
  801150:	56                   	push   %esi
  801151:	53                   	push   %ebx
  801152:	83 ec 0c             	sub    $0xc,%esp
  801155:	8b 7d 08             	mov    0x8(%ebp),%edi
  801158:	8b 75 0c             	mov    0xc(%ebp),%esi
  80115b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  80115e:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801160:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801165:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801168:	ff 75 14             	pushl  0x14(%ebp)
  80116b:	53                   	push   %ebx
  80116c:	56                   	push   %esi
  80116d:	57                   	push   %edi
  80116e:	e8 2e fc ff ff       	call   800da1 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801179:	75 07                	jne    801182 <ipc_send+0x36>
				    sys_yield();
  80117b:	e8 75 fa ff ff       	call   800bf5 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801180:	eb e6                	jmp    801168 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801182:	85 c0                	test   %eax,%eax
  801184:	74 12                	je     801198 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801186:	50                   	push   %eax
  801187:	68 18 27 80 00       	push   $0x802718
  80118c:	6a 4b                	push   $0x4b
  80118e:	68 2c 27 80 00       	push   $0x80272c
  801193:	e8 74 0d 00 00       	call   801f0c <_panic>
			 }
	   }
}
  801198:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119b:	5b                   	pop    %ebx
  80119c:	5e                   	pop    %esi
  80119d:	5f                   	pop    %edi
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    

008011a0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  8011a6:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  8011ab:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011ae:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011b4:	8b 52 50             	mov    0x50(%edx),%edx
  8011b7:	39 ca                	cmp    %ecx,%edx
  8011b9:	75 0d                	jne    8011c8 <ipc_find_env+0x28>
				    return envs[i].env_id;
  8011bb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011be:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c3:	8b 40 48             	mov    0x48(%eax),%eax
  8011c6:	eb 0f                	jmp    8011d7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  8011c8:	83 c0 01             	add    $0x1,%eax
  8011cb:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011d0:	75 d9                	jne    8011ab <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011df:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e4:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ef:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801206:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	c1 ea 16             	shr    $0x16,%edx
  801210:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801217:	f6 c2 01             	test   $0x1,%dl
  80121a:	74 11                	je     80122d <fd_alloc+0x2d>
  80121c:	89 c2                	mov    %eax,%edx
  80121e:	c1 ea 0c             	shr    $0xc,%edx
  801221:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801228:	f6 c2 01             	test   $0x1,%dl
  80122b:	75 09                	jne    801236 <fd_alloc+0x36>
			*fd_store = fd;
  80122d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80122f:	b8 00 00 00 00       	mov    $0x0,%eax
  801234:	eb 17                	jmp    80124d <fd_alloc+0x4d>
  801236:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80123b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801240:	75 c9                	jne    80120b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801242:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801248:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801255:	83 f8 1f             	cmp    $0x1f,%eax
  801258:	77 36                	ja     801290 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80125a:	c1 e0 0c             	shl    $0xc,%eax
  80125d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801262:	89 c2                	mov    %eax,%edx
  801264:	c1 ea 16             	shr    $0x16,%edx
  801267:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126e:	f6 c2 01             	test   $0x1,%dl
  801271:	74 24                	je     801297 <fd_lookup+0x48>
  801273:	89 c2                	mov    %eax,%edx
  801275:	c1 ea 0c             	shr    $0xc,%edx
  801278:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127f:	f6 c2 01             	test   $0x1,%dl
  801282:	74 1a                	je     80129e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801284:	8b 55 0c             	mov    0xc(%ebp),%edx
  801287:	89 02                	mov    %eax,(%edx)
	return 0;
  801289:	b8 00 00 00 00       	mov    $0x0,%eax
  80128e:	eb 13                	jmp    8012a3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801290:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801295:	eb 0c                	jmp    8012a3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801297:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129c:	eb 05                	jmp    8012a3 <fd_lookup+0x54>
  80129e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    

008012a5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ae:	ba b4 27 80 00       	mov    $0x8027b4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012b3:	eb 13                	jmp    8012c8 <dev_lookup+0x23>
  8012b5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012b8:	39 08                	cmp    %ecx,(%eax)
  8012ba:	75 0c                	jne    8012c8 <dev_lookup+0x23>
			*dev = devtab[i];
  8012bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012bf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c6:	eb 2e                	jmp    8012f6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c8:	8b 02                	mov    (%edx),%eax
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	75 e7                	jne    8012b5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8012d3:	8b 40 48             	mov    0x48(%eax),%eax
  8012d6:	83 ec 04             	sub    $0x4,%esp
  8012d9:	51                   	push   %ecx
  8012da:	50                   	push   %eax
  8012db:	68 38 27 80 00       	push   $0x802738
  8012e0:	e8 a7 ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  8012e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	56                   	push   %esi
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 10             	sub    $0x10,%esp
  801300:	8b 75 08             	mov    0x8(%ebp),%esi
  801303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801310:	c1 e8 0c             	shr    $0xc,%eax
  801313:	50                   	push   %eax
  801314:	e8 36 ff ff ff       	call   80124f <fd_lookup>
  801319:	83 c4 08             	add    $0x8,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 05                	js     801325 <fd_close+0x2d>
	    || fd != fd2)
  801320:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801323:	74 0c                	je     801331 <fd_close+0x39>
		return (must_exist ? r : 0);
  801325:	84 db                	test   %bl,%bl
  801327:	ba 00 00 00 00       	mov    $0x0,%edx
  80132c:	0f 44 c2             	cmove  %edx,%eax
  80132f:	eb 41                	jmp    801372 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	ff 36                	pushl  (%esi)
  80133a:	e8 66 ff ff ff       	call   8012a5 <dev_lookup>
  80133f:	89 c3                	mov    %eax,%ebx
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	85 c0                	test   %eax,%eax
  801346:	78 1a                	js     801362 <fd_close+0x6a>
		if (dev->dev_close)
  801348:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80134e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801353:	85 c0                	test   %eax,%eax
  801355:	74 0b                	je     801362 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	56                   	push   %esi
  80135b:	ff d0                	call   *%eax
  80135d:	89 c3                	mov    %eax,%ebx
  80135f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	56                   	push   %esi
  801366:	6a 00                	push   $0x0
  801368:	e8 2c f9 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	89 d8                	mov    %ebx,%eax
}
  801372:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801375:	5b                   	pop    %ebx
  801376:	5e                   	pop    %esi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    

00801379 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	ff 75 08             	pushl  0x8(%ebp)
  801386:	e8 c4 fe ff ff       	call   80124f <fd_lookup>
  80138b:	83 c4 08             	add    $0x8,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 10                	js     8013a2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	6a 01                	push   $0x1
  801397:	ff 75 f4             	pushl  -0xc(%ebp)
  80139a:	e8 59 ff ff ff       	call   8012f8 <fd_close>
  80139f:	83 c4 10             	add    $0x10,%esp
}
  8013a2:	c9                   	leave  
  8013a3:	c3                   	ret    

008013a4 <close_all>:

void
close_all(void)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	53                   	push   %ebx
  8013a8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ab:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b0:	83 ec 0c             	sub    $0xc,%esp
  8013b3:	53                   	push   %ebx
  8013b4:	e8 c0 ff ff ff       	call   801379 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b9:	83 c3 01             	add    $0x1,%ebx
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	83 fb 20             	cmp    $0x20,%ebx
  8013c2:	75 ec                	jne    8013b0 <close_all+0xc>
		close(i);
}
  8013c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    

008013c9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	57                   	push   %edi
  8013cd:	56                   	push   %esi
  8013ce:	53                   	push   %ebx
  8013cf:	83 ec 2c             	sub    $0x2c,%esp
  8013d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	ff 75 08             	pushl  0x8(%ebp)
  8013dc:	e8 6e fe ff ff       	call   80124f <fd_lookup>
  8013e1:	83 c4 08             	add    $0x8,%esp
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	0f 88 c1 00 00 00    	js     8014ad <dup+0xe4>
		return r;
	close(newfdnum);
  8013ec:	83 ec 0c             	sub    $0xc,%esp
  8013ef:	56                   	push   %esi
  8013f0:	e8 84 ff ff ff       	call   801379 <close>

	newfd = INDEX2FD(newfdnum);
  8013f5:	89 f3                	mov    %esi,%ebx
  8013f7:	c1 e3 0c             	shl    $0xc,%ebx
  8013fa:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801400:	83 c4 04             	add    $0x4,%esp
  801403:	ff 75 e4             	pushl  -0x1c(%ebp)
  801406:	e8 de fd ff ff       	call   8011e9 <fd2data>
  80140b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80140d:	89 1c 24             	mov    %ebx,(%esp)
  801410:	e8 d4 fd ff ff       	call   8011e9 <fd2data>
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141b:	89 f8                	mov    %edi,%eax
  80141d:	c1 e8 16             	shr    $0x16,%eax
  801420:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801427:	a8 01                	test   $0x1,%al
  801429:	74 37                	je     801462 <dup+0x99>
  80142b:	89 f8                	mov    %edi,%eax
  80142d:	c1 e8 0c             	shr    $0xc,%eax
  801430:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801437:	f6 c2 01             	test   $0x1,%dl
  80143a:	74 26                	je     801462 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80143c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801443:	83 ec 0c             	sub    $0xc,%esp
  801446:	25 07 0e 00 00       	and    $0xe07,%eax
  80144b:	50                   	push   %eax
  80144c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80144f:	6a 00                	push   $0x0
  801451:	57                   	push   %edi
  801452:	6a 00                	push   $0x0
  801454:	e8 fe f7 ff ff       	call   800c57 <sys_page_map>
  801459:	89 c7                	mov    %eax,%edi
  80145b:	83 c4 20             	add    $0x20,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 2e                	js     801490 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801462:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801465:	89 d0                	mov    %edx,%eax
  801467:	c1 e8 0c             	shr    $0xc,%eax
  80146a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801471:	83 ec 0c             	sub    $0xc,%esp
  801474:	25 07 0e 00 00       	and    $0xe07,%eax
  801479:	50                   	push   %eax
  80147a:	53                   	push   %ebx
  80147b:	6a 00                	push   $0x0
  80147d:	52                   	push   %edx
  80147e:	6a 00                	push   $0x0
  801480:	e8 d2 f7 ff ff       	call   800c57 <sys_page_map>
  801485:	89 c7                	mov    %eax,%edi
  801487:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80148a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148c:	85 ff                	test   %edi,%edi
  80148e:	79 1d                	jns    8014ad <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	53                   	push   %ebx
  801494:	6a 00                	push   $0x0
  801496:	e8 fe f7 ff ff       	call   800c99 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80149b:	83 c4 08             	add    $0x8,%esp
  80149e:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a1:	6a 00                	push   $0x0
  8014a3:	e8 f1 f7 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	89 f8                	mov    %edi,%eax
}
  8014ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	53                   	push   %ebx
  8014b9:	83 ec 14             	sub    $0x14,%esp
  8014bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	53                   	push   %ebx
  8014c4:	e8 86 fd ff ff       	call   80124f <fd_lookup>
  8014c9:	83 c4 08             	add    $0x8,%esp
  8014cc:	89 c2                	mov    %eax,%edx
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 6d                	js     80153f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dc:	ff 30                	pushl  (%eax)
  8014de:	e8 c2 fd ff ff       	call   8012a5 <dev_lookup>
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 4c                	js     801536 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ed:	8b 42 08             	mov    0x8(%edx),%eax
  8014f0:	83 e0 03             	and    $0x3,%eax
  8014f3:	83 f8 01             	cmp    $0x1,%eax
  8014f6:	75 21                	jne    801519 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8014fd:	8b 40 48             	mov    0x48(%eax),%eax
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	53                   	push   %ebx
  801504:	50                   	push   %eax
  801505:	68 79 27 80 00       	push   $0x802779
  80150a:	e8 7d ed ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801517:	eb 26                	jmp    80153f <read+0x8a>
	}
	if (!dev->dev_read)
  801519:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151c:	8b 40 08             	mov    0x8(%eax),%eax
  80151f:	85 c0                	test   %eax,%eax
  801521:	74 17                	je     80153a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801523:	83 ec 04             	sub    $0x4,%esp
  801526:	ff 75 10             	pushl  0x10(%ebp)
  801529:	ff 75 0c             	pushl  0xc(%ebp)
  80152c:	52                   	push   %edx
  80152d:	ff d0                	call   *%eax
  80152f:	89 c2                	mov    %eax,%edx
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	eb 09                	jmp    80153f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801536:	89 c2                	mov    %eax,%edx
  801538:	eb 05                	jmp    80153f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80153a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80153f:	89 d0                	mov    %edx,%eax
  801541:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801544:	c9                   	leave  
  801545:	c3                   	ret    

00801546 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	57                   	push   %edi
  80154a:	56                   	push   %esi
  80154b:	53                   	push   %ebx
  80154c:	83 ec 0c             	sub    $0xc,%esp
  80154f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801552:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801555:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155a:	eb 21                	jmp    80157d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80155c:	83 ec 04             	sub    $0x4,%esp
  80155f:	89 f0                	mov    %esi,%eax
  801561:	29 d8                	sub    %ebx,%eax
  801563:	50                   	push   %eax
  801564:	89 d8                	mov    %ebx,%eax
  801566:	03 45 0c             	add    0xc(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	57                   	push   %edi
  80156b:	e8 45 ff ff ff       	call   8014b5 <read>
		if (m < 0)
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	85 c0                	test   %eax,%eax
  801575:	78 10                	js     801587 <readn+0x41>
			return m;
		if (m == 0)
  801577:	85 c0                	test   %eax,%eax
  801579:	74 0a                	je     801585 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157b:	01 c3                	add    %eax,%ebx
  80157d:	39 f3                	cmp    %esi,%ebx
  80157f:	72 db                	jb     80155c <readn+0x16>
  801581:	89 d8                	mov    %ebx,%eax
  801583:	eb 02                	jmp    801587 <readn+0x41>
  801585:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801587:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5e                   	pop    %esi
  80158c:	5f                   	pop    %edi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    

0080158f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 14             	sub    $0x14,%esp
  801596:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801599:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	53                   	push   %ebx
  80159e:	e8 ac fc ff ff       	call   80124f <fd_lookup>
  8015a3:	83 c4 08             	add    $0x8,%esp
  8015a6:	89 c2                	mov    %eax,%edx
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 68                	js     801614 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b6:	ff 30                	pushl  (%eax)
  8015b8:	e8 e8 fc ff ff       	call   8012a5 <dev_lookup>
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 47                	js     80160b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015cb:	75 21                	jne    8015ee <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d2:	8b 40 48             	mov    0x48(%eax),%eax
  8015d5:	83 ec 04             	sub    $0x4,%esp
  8015d8:	53                   	push   %ebx
  8015d9:	50                   	push   %eax
  8015da:	68 95 27 80 00       	push   $0x802795
  8015df:	e8 a8 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ec:	eb 26                	jmp    801614 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f4:	85 d2                	test   %edx,%edx
  8015f6:	74 17                	je     80160f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f8:	83 ec 04             	sub    $0x4,%esp
  8015fb:	ff 75 10             	pushl  0x10(%ebp)
  8015fe:	ff 75 0c             	pushl  0xc(%ebp)
  801601:	50                   	push   %eax
  801602:	ff d2                	call   *%edx
  801604:	89 c2                	mov    %eax,%edx
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	eb 09                	jmp    801614 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160b:	89 c2                	mov    %eax,%edx
  80160d:	eb 05                	jmp    801614 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80160f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801614:	89 d0                	mov    %edx,%eax
  801616:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <seek>:

int
seek(int fdnum, off_t offset)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801621:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	ff 75 08             	pushl  0x8(%ebp)
  801628:	e8 22 fc ff ff       	call   80124f <fd_lookup>
  80162d:	83 c4 08             	add    $0x8,%esp
  801630:	85 c0                	test   %eax,%eax
  801632:	78 0e                	js     801642 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801634:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801637:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80163d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	53                   	push   %ebx
  801648:	83 ec 14             	sub    $0x14,%esp
  80164b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	53                   	push   %ebx
  801653:	e8 f7 fb ff ff       	call   80124f <fd_lookup>
  801658:	83 c4 08             	add    $0x8,%esp
  80165b:	89 c2                	mov    %eax,%edx
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 65                	js     8016c6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801661:	83 ec 08             	sub    $0x8,%esp
  801664:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801667:	50                   	push   %eax
  801668:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166b:	ff 30                	pushl  (%eax)
  80166d:	e8 33 fc ff ff       	call   8012a5 <dev_lookup>
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	85 c0                	test   %eax,%eax
  801677:	78 44                	js     8016bd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801679:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801680:	75 21                	jne    8016a3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801682:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801687:	8b 40 48             	mov    0x48(%eax),%eax
  80168a:	83 ec 04             	sub    $0x4,%esp
  80168d:	53                   	push   %ebx
  80168e:	50                   	push   %eax
  80168f:	68 58 27 80 00       	push   $0x802758
  801694:	e8 f3 eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a1:	eb 23                	jmp    8016c6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a6:	8b 52 18             	mov    0x18(%edx),%edx
  8016a9:	85 d2                	test   %edx,%edx
  8016ab:	74 14                	je     8016c1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	ff 75 0c             	pushl  0xc(%ebp)
  8016b3:	50                   	push   %eax
  8016b4:	ff d2                	call   *%edx
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	eb 09                	jmp    8016c6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	eb 05                	jmp    8016c6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c6:	89 d0                	mov    %edx,%eax
  8016c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cb:	c9                   	leave  
  8016cc:	c3                   	ret    

008016cd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	53                   	push   %ebx
  8016d1:	83 ec 14             	sub    $0x14,%esp
  8016d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016da:	50                   	push   %eax
  8016db:	ff 75 08             	pushl  0x8(%ebp)
  8016de:	e8 6c fb ff ff       	call   80124f <fd_lookup>
  8016e3:	83 c4 08             	add    $0x8,%esp
  8016e6:	89 c2                	mov    %eax,%edx
  8016e8:	85 c0                	test   %eax,%eax
  8016ea:	78 58                	js     801744 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ec:	83 ec 08             	sub    $0x8,%esp
  8016ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f2:	50                   	push   %eax
  8016f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f6:	ff 30                	pushl  (%eax)
  8016f8:	e8 a8 fb ff ff       	call   8012a5 <dev_lookup>
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	85 c0                	test   %eax,%eax
  801702:	78 37                	js     80173b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801704:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801707:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80170b:	74 32                	je     80173f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80170d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801710:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801717:	00 00 00 
	stat->st_isdir = 0;
  80171a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801721:	00 00 00 
	stat->st_dev = dev;
  801724:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80172a:	83 ec 08             	sub    $0x8,%esp
  80172d:	53                   	push   %ebx
  80172e:	ff 75 f0             	pushl  -0x10(%ebp)
  801731:	ff 50 14             	call   *0x14(%eax)
  801734:	89 c2                	mov    %eax,%edx
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	eb 09                	jmp    801744 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173b:	89 c2                	mov    %eax,%edx
  80173d:	eb 05                	jmp    801744 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80173f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801744:	89 d0                	mov    %edx,%eax
  801746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	6a 00                	push   $0x0
  801755:	ff 75 08             	pushl  0x8(%ebp)
  801758:	e8 2c 02 00 00       	call   801989 <open>
  80175d:	89 c3                	mov    %eax,%ebx
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	85 c0                	test   %eax,%eax
  801764:	78 1b                	js     801781 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801766:	83 ec 08             	sub    $0x8,%esp
  801769:	ff 75 0c             	pushl  0xc(%ebp)
  80176c:	50                   	push   %eax
  80176d:	e8 5b ff ff ff       	call   8016cd <fstat>
  801772:	89 c6                	mov    %eax,%esi
	close(fd);
  801774:	89 1c 24             	mov    %ebx,(%esp)
  801777:	e8 fd fb ff ff       	call   801379 <close>
	return r;
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	89 f0                	mov    %esi,%eax
}
  801781:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801784:	5b                   	pop    %ebx
  801785:	5e                   	pop    %esi
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    

00801788 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	56                   	push   %esi
  80178c:	53                   	push   %ebx
  80178d:	89 c6                	mov    %eax,%esi
  80178f:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  801791:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801798:	75 12                	jne    8017ac <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  80179a:	83 ec 0c             	sub    $0xc,%esp
  80179d:	6a 01                	push   $0x1
  80179f:	e8 fc f9 ff ff       	call   8011a0 <ipc_find_env>
  8017a4:	a3 00 40 80 00       	mov    %eax,0x804000
  8017a9:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ac:	6a 07                	push   $0x7
  8017ae:	68 00 50 80 00       	push   $0x805000
  8017b3:	56                   	push   %esi
  8017b4:	ff 35 00 40 80 00    	pushl  0x804000
  8017ba:	e8 8d f9 ff ff       	call   80114c <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  8017bf:	83 c4 0c             	add    $0xc,%esp
  8017c2:	6a 00                	push   $0x0
  8017c4:	53                   	push   %ebx
  8017c5:	6a 00                	push   $0x0
  8017c7:	e8 21 f9 ff ff       	call   8010ed <ipc_recv>
}
  8017cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5e                   	pop    %esi
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017df:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  8017e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e7:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  8017ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f1:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f6:	e8 8d ff ff ff       	call   801788 <fsipc>
}
  8017fb:	c9                   	leave  
  8017fc:	c3                   	ret    

008017fd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	8b 40 0c             	mov    0xc(%eax),%eax
  801809:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  80180e:	ba 00 00 00 00       	mov    $0x0,%edx
  801813:	b8 06 00 00 00       	mov    $0x6,%eax
  801818:	e8 6b ff ff ff       	call   801788 <fsipc>
}
  80181d:	c9                   	leave  
  80181e:	c3                   	ret    

0080181f <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	8b 40 0c             	mov    0xc(%eax),%eax
  80182f:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801834:	ba 00 00 00 00       	mov    $0x0,%edx
  801839:	b8 05 00 00 00       	mov    $0x5,%eax
  80183e:	e8 45 ff ff ff       	call   801788 <fsipc>
  801843:	85 c0                	test   %eax,%eax
  801845:	78 2c                	js     801873 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801847:	83 ec 08             	sub    $0x8,%esp
  80184a:	68 00 50 80 00       	push   $0x805000
  80184f:	53                   	push   %ebx
  801850:	e8 bc ef ff ff       	call   800811 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  801855:	a1 80 50 80 00       	mov    0x805080,%eax
  80185a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801860:	a1 84 50 80 00       	mov    0x805084,%eax
  801865:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	53                   	push   %ebx
  80187c:	83 ec 08             	sub    $0x8,%esp
  80187f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	8b 40 0c             	mov    0xc(%eax),%eax
  801888:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  80188d:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  801893:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801899:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  80189e:	0f 46 c3             	cmovbe %ebx,%eax
  8018a1:	50                   	push   %eax
  8018a2:	ff 75 0c             	pushl  0xc(%ebp)
  8018a5:	68 08 50 80 00       	push   $0x805008
  8018aa:	e8 f4 f0 ff ff       	call   8009a3 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  8018af:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b4:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b9:	e8 ca fe ff ff       	call   801788 <fsipc>
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	78 3d                	js     801902 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  8018c5:	39 c3                	cmp    %eax,%ebx
  8018c7:	73 19                	jae    8018e2 <devfile_write+0x6a>
  8018c9:	68 c4 27 80 00       	push   $0x8027c4
  8018ce:	68 cb 27 80 00       	push   $0x8027cb
  8018d3:	68 9a 00 00 00       	push   $0x9a
  8018d8:	68 e0 27 80 00       	push   $0x8027e0
  8018dd:	e8 2a 06 00 00       	call   801f0c <_panic>
	   assert (r <= bytes_written);
  8018e2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018e7:	7e 19                	jle    801902 <devfile_write+0x8a>
  8018e9:	68 eb 27 80 00       	push   $0x8027eb
  8018ee:	68 cb 27 80 00       	push   $0x8027cb
  8018f3:	68 9b 00 00 00       	push   $0x9b
  8018f8:	68 e0 27 80 00       	push   $0x8027e0
  8018fd:	e8 0a 06 00 00       	call   801f0c <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801902:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	56                   	push   %esi
  80190b:	53                   	push   %ebx
  80190c:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  80190f:	8b 45 08             	mov    0x8(%ebp),%eax
  801912:	8b 40 0c             	mov    0xc(%eax),%eax
  801915:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  80191a:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801920:	ba 00 00 00 00       	mov    $0x0,%edx
  801925:	b8 03 00 00 00       	mov    $0x3,%eax
  80192a:	e8 59 fe ff ff       	call   801788 <fsipc>
  80192f:	89 c3                	mov    %eax,%ebx
  801931:	85 c0                	test   %eax,%eax
  801933:	78 4b                	js     801980 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  801935:	39 c6                	cmp    %eax,%esi
  801937:	73 16                	jae    80194f <devfile_read+0x48>
  801939:	68 c4 27 80 00       	push   $0x8027c4
  80193e:	68 cb 27 80 00       	push   $0x8027cb
  801943:	6a 7c                	push   $0x7c
  801945:	68 e0 27 80 00       	push   $0x8027e0
  80194a:	e8 bd 05 00 00       	call   801f0c <_panic>
	   assert(r <= PGSIZE);
  80194f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801954:	7e 16                	jle    80196c <devfile_read+0x65>
  801956:	68 fe 27 80 00       	push   $0x8027fe
  80195b:	68 cb 27 80 00       	push   $0x8027cb
  801960:	6a 7d                	push   $0x7d
  801962:	68 e0 27 80 00       	push   $0x8027e0
  801967:	e8 a0 05 00 00       	call   801f0c <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80196c:	83 ec 04             	sub    $0x4,%esp
  80196f:	50                   	push   %eax
  801970:	68 00 50 80 00       	push   $0x805000
  801975:	ff 75 0c             	pushl  0xc(%ebp)
  801978:	e8 26 f0 ff ff       	call   8009a3 <memmove>
	   return r;
  80197d:	83 c4 10             	add    $0x10,%esp
}
  801980:	89 d8                	mov    %ebx,%eax
  801982:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801985:	5b                   	pop    %ebx
  801986:	5e                   	pop    %esi
  801987:	5d                   	pop    %ebp
  801988:	c3                   	ret    

00801989 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	53                   	push   %ebx
  80198d:	83 ec 20             	sub    $0x20,%esp
  801990:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  801993:	53                   	push   %ebx
  801994:	e8 3f ee ff ff       	call   8007d8 <strlen>
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a1:	7f 67                	jg     801a0a <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8019a3:	83 ec 0c             	sub    $0xc,%esp
  8019a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a9:	50                   	push   %eax
  8019aa:	e8 51 f8 ff ff       	call   801200 <fd_alloc>
  8019af:	83 c4 10             	add    $0x10,%esp
			 return r;
  8019b2:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	78 57                	js     801a0f <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  8019b8:	83 ec 08             	sub    $0x8,%esp
  8019bb:	53                   	push   %ebx
  8019bc:	68 00 50 80 00       	push   $0x805000
  8019c1:	e8 4b ee ff ff       	call   800811 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  8019c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c9:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d6:	e8 ad fd ff ff       	call   801788 <fsipc>
  8019db:	89 c3                	mov    %eax,%ebx
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	79 14                	jns    8019f8 <open+0x6f>
			 fd_close(fd, 0);
  8019e4:	83 ec 08             	sub    $0x8,%esp
  8019e7:	6a 00                	push   $0x0
  8019e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ec:	e8 07 f9 ff ff       	call   8012f8 <fd_close>
			 return r;
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	89 da                	mov    %ebx,%edx
  8019f6:	eb 17                	jmp    801a0f <open+0x86>
	   }

	   return fd2num(fd);
  8019f8:	83 ec 0c             	sub    $0xc,%esp
  8019fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fe:	e8 d6 f7 ff ff       	call   8011d9 <fd2num>
  801a03:	89 c2                	mov    %eax,%edx
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	eb 05                	jmp    801a0f <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  801a0a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801a0f:	89 d0                	mov    %edx,%eax
  801a11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801a1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a21:	b8 08 00 00 00       	mov    $0x8,%eax
  801a26:	e8 5d fd ff ff       	call   801788 <fsipc>
}
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    

00801a2d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	56                   	push   %esi
  801a31:	53                   	push   %ebx
  801a32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	ff 75 08             	pushl  0x8(%ebp)
  801a3b:	e8 a9 f7 ff ff       	call   8011e9 <fd2data>
  801a40:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a42:	83 c4 08             	add    $0x8,%esp
  801a45:	68 0a 28 80 00       	push   $0x80280a
  801a4a:	53                   	push   %ebx
  801a4b:	e8 c1 ed ff ff       	call   800811 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a50:	8b 46 04             	mov    0x4(%esi),%eax
  801a53:	2b 06                	sub    (%esi),%eax
  801a55:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a5b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a62:	00 00 00 
	stat->st_dev = &devpipe;
  801a65:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801a6c:	30 80 00 
	return 0;
}
  801a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a77:	5b                   	pop    %ebx
  801a78:	5e                   	pop    %esi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	53                   	push   %ebx
  801a7f:	83 ec 0c             	sub    $0xc,%esp
  801a82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a85:	53                   	push   %ebx
  801a86:	6a 00                	push   $0x0
  801a88:	e8 0c f2 ff ff       	call   800c99 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a8d:	89 1c 24             	mov    %ebx,(%esp)
  801a90:	e8 54 f7 ff ff       	call   8011e9 <fd2data>
  801a95:	83 c4 08             	add    $0x8,%esp
  801a98:	50                   	push   %eax
  801a99:	6a 00                	push   $0x0
  801a9b:	e8 f9 f1 ff ff       	call   800c99 <sys_page_unmap>
}
  801aa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	57                   	push   %edi
  801aa9:	56                   	push   %esi
  801aaa:	53                   	push   %ebx
  801aab:	83 ec 1c             	sub    $0x1c,%esp
  801aae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ab1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ab3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	ff 75 e0             	pushl  -0x20(%ebp)
  801ac1:	e8 0b 05 00 00       	call   801fd1 <pageref>
  801ac6:	89 c3                	mov    %eax,%ebx
  801ac8:	89 3c 24             	mov    %edi,(%esp)
  801acb:	e8 01 05 00 00       	call   801fd1 <pageref>
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	39 c3                	cmp    %eax,%ebx
  801ad5:	0f 94 c1             	sete   %cl
  801ad8:	0f b6 c9             	movzbl %cl,%ecx
  801adb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ade:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ae4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ae7:	39 ce                	cmp    %ecx,%esi
  801ae9:	74 1b                	je     801b06 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aeb:	39 c3                	cmp    %eax,%ebx
  801aed:	75 c4                	jne    801ab3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aef:	8b 42 58             	mov    0x58(%edx),%eax
  801af2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af5:	50                   	push   %eax
  801af6:	56                   	push   %esi
  801af7:	68 11 28 80 00       	push   $0x802811
  801afc:	e8 8b e7 ff ff       	call   80028c <cprintf>
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	eb ad                	jmp    801ab3 <_pipeisclosed+0xe>
	}
}
  801b06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0c:	5b                   	pop    %ebx
  801b0d:	5e                   	pop    %esi
  801b0e:	5f                   	pop    %edi
  801b0f:	5d                   	pop    %ebp
  801b10:	c3                   	ret    

00801b11 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	57                   	push   %edi
  801b15:	56                   	push   %esi
  801b16:	53                   	push   %ebx
  801b17:	83 ec 28             	sub    $0x28,%esp
  801b1a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b1d:	56                   	push   %esi
  801b1e:	e8 c6 f6 ff ff       	call   8011e9 <fd2data>
  801b23:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2d:	eb 4b                	jmp    801b7a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b2f:	89 da                	mov    %ebx,%edx
  801b31:	89 f0                	mov    %esi,%eax
  801b33:	e8 6d ff ff ff       	call   801aa5 <_pipeisclosed>
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	75 48                	jne    801b84 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b3c:	e8 b4 f0 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b41:	8b 43 04             	mov    0x4(%ebx),%eax
  801b44:	8b 0b                	mov    (%ebx),%ecx
  801b46:	8d 51 20             	lea    0x20(%ecx),%edx
  801b49:	39 d0                	cmp    %edx,%eax
  801b4b:	73 e2                	jae    801b2f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b50:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b54:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b57:	89 c2                	mov    %eax,%edx
  801b59:	c1 fa 1f             	sar    $0x1f,%edx
  801b5c:	89 d1                	mov    %edx,%ecx
  801b5e:	c1 e9 1b             	shr    $0x1b,%ecx
  801b61:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b64:	83 e2 1f             	and    $0x1f,%edx
  801b67:	29 ca                	sub    %ecx,%edx
  801b69:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b6d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b71:	83 c0 01             	add    $0x1,%eax
  801b74:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b77:	83 c7 01             	add    $0x1,%edi
  801b7a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b7d:	75 c2                	jne    801b41 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b7f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b82:	eb 05                	jmp    801b89 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8c:	5b                   	pop    %ebx
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	57                   	push   %edi
  801b95:	56                   	push   %esi
  801b96:	53                   	push   %ebx
  801b97:	83 ec 18             	sub    $0x18,%esp
  801b9a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b9d:	57                   	push   %edi
  801b9e:	e8 46 f6 ff ff       	call   8011e9 <fd2data>
  801ba3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bad:	eb 3d                	jmp    801bec <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801baf:	85 db                	test   %ebx,%ebx
  801bb1:	74 04                	je     801bb7 <devpipe_read+0x26>
				return i;
  801bb3:	89 d8                	mov    %ebx,%eax
  801bb5:	eb 44                	jmp    801bfb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bb7:	89 f2                	mov    %esi,%edx
  801bb9:	89 f8                	mov    %edi,%eax
  801bbb:	e8 e5 fe ff ff       	call   801aa5 <_pipeisclosed>
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	75 32                	jne    801bf6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bc4:	e8 2c f0 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bc9:	8b 06                	mov    (%esi),%eax
  801bcb:	3b 46 04             	cmp    0x4(%esi),%eax
  801bce:	74 df                	je     801baf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bd0:	99                   	cltd   
  801bd1:	c1 ea 1b             	shr    $0x1b,%edx
  801bd4:	01 d0                	add    %edx,%eax
  801bd6:	83 e0 1f             	and    $0x1f,%eax
  801bd9:	29 d0                	sub    %edx,%eax
  801bdb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801be6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be9:	83 c3 01             	add    $0x1,%ebx
  801bec:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bef:	75 d8                	jne    801bc9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bf1:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf4:	eb 05                	jmp    801bfb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bf6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5f                   	pop    %edi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0e:	50                   	push   %eax
  801c0f:	e8 ec f5 ff ff       	call   801200 <fd_alloc>
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	89 c2                	mov    %eax,%edx
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	0f 88 2c 01 00 00    	js     801d4d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c21:	83 ec 04             	sub    $0x4,%esp
  801c24:	68 07 04 00 00       	push   $0x407
  801c29:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2c:	6a 00                	push   $0x0
  801c2e:	e8 e1 ef ff ff       	call   800c14 <sys_page_alloc>
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	89 c2                	mov    %eax,%edx
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	0f 88 0d 01 00 00    	js     801d4d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c40:	83 ec 0c             	sub    $0xc,%esp
  801c43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c46:	50                   	push   %eax
  801c47:	e8 b4 f5 ff ff       	call   801200 <fd_alloc>
  801c4c:	89 c3                	mov    %eax,%ebx
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	85 c0                	test   %eax,%eax
  801c53:	0f 88 e2 00 00 00    	js     801d3b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c59:	83 ec 04             	sub    $0x4,%esp
  801c5c:	68 07 04 00 00       	push   $0x407
  801c61:	ff 75 f0             	pushl  -0x10(%ebp)
  801c64:	6a 00                	push   $0x0
  801c66:	e8 a9 ef ff ff       	call   800c14 <sys_page_alloc>
  801c6b:	89 c3                	mov    %eax,%ebx
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	85 c0                	test   %eax,%eax
  801c72:	0f 88 c3 00 00 00    	js     801d3b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c78:	83 ec 0c             	sub    $0xc,%esp
  801c7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7e:	e8 66 f5 ff ff       	call   8011e9 <fd2data>
  801c83:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c85:	83 c4 0c             	add    $0xc,%esp
  801c88:	68 07 04 00 00       	push   $0x407
  801c8d:	50                   	push   %eax
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 7f ef ff ff       	call   800c14 <sys_page_alloc>
  801c95:	89 c3                	mov    %eax,%ebx
  801c97:	83 c4 10             	add    $0x10,%esp
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	0f 88 89 00 00 00    	js     801d2b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca2:	83 ec 0c             	sub    $0xc,%esp
  801ca5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca8:	e8 3c f5 ff ff       	call   8011e9 <fd2data>
  801cad:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cb4:	50                   	push   %eax
  801cb5:	6a 00                	push   $0x0
  801cb7:	56                   	push   %esi
  801cb8:	6a 00                	push   $0x0
  801cba:	e8 98 ef ff ff       	call   800c57 <sys_page_map>
  801cbf:	89 c3                	mov    %eax,%ebx
  801cc1:	83 c4 20             	add    $0x20,%esp
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	78 55                	js     801d1d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cc8:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cdd:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ceb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cf2:	83 ec 0c             	sub    $0xc,%esp
  801cf5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf8:	e8 dc f4 ff ff       	call   8011d9 <fd2num>
  801cfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d00:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d02:	83 c4 04             	add    $0x4,%esp
  801d05:	ff 75 f0             	pushl  -0x10(%ebp)
  801d08:	e8 cc f4 ff ff       	call   8011d9 <fd2num>
  801d0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d10:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d13:	83 c4 10             	add    $0x10,%esp
  801d16:	ba 00 00 00 00       	mov    $0x0,%edx
  801d1b:	eb 30                	jmp    801d4d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d1d:	83 ec 08             	sub    $0x8,%esp
  801d20:	56                   	push   %esi
  801d21:	6a 00                	push   $0x0
  801d23:	e8 71 ef ff ff       	call   800c99 <sys_page_unmap>
  801d28:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d2b:	83 ec 08             	sub    $0x8,%esp
  801d2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d31:	6a 00                	push   $0x0
  801d33:	e8 61 ef ff ff       	call   800c99 <sys_page_unmap>
  801d38:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d3b:	83 ec 08             	sub    $0x8,%esp
  801d3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d41:	6a 00                	push   $0x0
  801d43:	e8 51 ef ff ff       	call   800c99 <sys_page_unmap>
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d4d:	89 d0                	mov    %edx,%eax
  801d4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d52:	5b                   	pop    %ebx
  801d53:	5e                   	pop    %esi
  801d54:	5d                   	pop    %ebp
  801d55:	c3                   	ret    

00801d56 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5f:	50                   	push   %eax
  801d60:	ff 75 08             	pushl  0x8(%ebp)
  801d63:	e8 e7 f4 ff ff       	call   80124f <fd_lookup>
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	78 18                	js     801d87 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d6f:	83 ec 0c             	sub    $0xc,%esp
  801d72:	ff 75 f4             	pushl  -0xc(%ebp)
  801d75:	e8 6f f4 ff ff       	call   8011e9 <fd2data>
	return _pipeisclosed(fd, p);
  801d7a:	89 c2                	mov    %eax,%edx
  801d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7f:	e8 21 fd ff ff       	call   801aa5 <_pipeisclosed>
  801d84:	83 c4 10             	add    $0x10,%esp
}
  801d87:	c9                   	leave  
  801d88:	c3                   	ret    

00801d89 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    

00801d93 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d99:	68 29 28 80 00       	push   $0x802829
  801d9e:	ff 75 0c             	pushl  0xc(%ebp)
  801da1:	e8 6b ea ff ff       	call   800811 <strcpy>
	return 0;
}
  801da6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dab:	c9                   	leave  
  801dac:	c3                   	ret    

00801dad <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	57                   	push   %edi
  801db1:	56                   	push   %esi
  801db2:	53                   	push   %ebx
  801db3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dbe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc4:	eb 2d                	jmp    801df3 <devcons_write+0x46>
		m = n - tot;
  801dc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dc9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dcb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dce:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dd3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd6:	83 ec 04             	sub    $0x4,%esp
  801dd9:	53                   	push   %ebx
  801dda:	03 45 0c             	add    0xc(%ebp),%eax
  801ddd:	50                   	push   %eax
  801dde:	57                   	push   %edi
  801ddf:	e8 bf eb ff ff       	call   8009a3 <memmove>
		sys_cputs(buf, m);
  801de4:	83 c4 08             	add    $0x8,%esp
  801de7:	53                   	push   %ebx
  801de8:	57                   	push   %edi
  801de9:	e8 6a ed ff ff       	call   800b58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dee:	01 de                	add    %ebx,%esi
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	89 f0                	mov    %esi,%eax
  801df5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801df8:	72 cc                	jb     801dc6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5f                   	pop    %edi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 08             	sub    $0x8,%esp
  801e08:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e11:	74 2a                	je     801e3d <devcons_read+0x3b>
  801e13:	eb 05                	jmp    801e1a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e15:	e8 db ed ff ff       	call   800bf5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e1a:	e8 57 ed ff ff       	call   800b76 <sys_cgetc>
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	74 f2                	je     801e15 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e23:	85 c0                	test   %eax,%eax
  801e25:	78 16                	js     801e3d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e27:	83 f8 04             	cmp    $0x4,%eax
  801e2a:	74 0c                	je     801e38 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2f:	88 02                	mov    %al,(%edx)
	return 1;
  801e31:	b8 01 00 00 00       	mov    $0x1,%eax
  801e36:	eb 05                	jmp    801e3d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e38:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e3d:	c9                   	leave  
  801e3e:	c3                   	ret    

00801e3f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e45:	8b 45 08             	mov    0x8(%ebp),%eax
  801e48:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e4b:	6a 01                	push   $0x1
  801e4d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e50:	50                   	push   %eax
  801e51:	e8 02 ed ff ff       	call   800b58 <sys_cputs>
}
  801e56:	83 c4 10             	add    $0x10,%esp
  801e59:	c9                   	leave  
  801e5a:	c3                   	ret    

00801e5b <getchar>:

int
getchar(void)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e61:	6a 01                	push   $0x1
  801e63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e66:	50                   	push   %eax
  801e67:	6a 00                	push   $0x0
  801e69:	e8 47 f6 ff ff       	call   8014b5 <read>
	if (r < 0)
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	85 c0                	test   %eax,%eax
  801e73:	78 0f                	js     801e84 <getchar+0x29>
		return r;
	if (r < 1)
  801e75:	85 c0                	test   %eax,%eax
  801e77:	7e 06                	jle    801e7f <getchar+0x24>
		return -E_EOF;
	return c;
  801e79:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e7d:	eb 05                	jmp    801e84 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e7f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

00801e86 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8f:	50                   	push   %eax
  801e90:	ff 75 08             	pushl  0x8(%ebp)
  801e93:	e8 b7 f3 ff ff       	call   80124f <fd_lookup>
  801e98:	83 c4 10             	add    $0x10,%esp
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	78 11                	js     801eb0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea2:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801ea8:	39 10                	cmp    %edx,(%eax)
  801eaa:	0f 94 c0             	sete   %al
  801ead:	0f b6 c0             	movzbl %al,%eax
}
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <opencons>:

int
opencons(void)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebb:	50                   	push   %eax
  801ebc:	e8 3f f3 ff ff       	call   801200 <fd_alloc>
  801ec1:	83 c4 10             	add    $0x10,%esp
		return r;
  801ec4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ec6:	85 c0                	test   %eax,%eax
  801ec8:	78 3e                	js     801f08 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eca:	83 ec 04             	sub    $0x4,%esp
  801ecd:	68 07 04 00 00       	push   $0x407
  801ed2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed5:	6a 00                	push   $0x0
  801ed7:	e8 38 ed ff ff       	call   800c14 <sys_page_alloc>
  801edc:	83 c4 10             	add    $0x10,%esp
		return r;
  801edf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	78 23                	js     801f08 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ee5:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eee:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801efa:	83 ec 0c             	sub    $0xc,%esp
  801efd:	50                   	push   %eax
  801efe:	e8 d6 f2 ff ff       	call   8011d9 <fd2num>
  801f03:	89 c2                	mov    %eax,%edx
  801f05:	83 c4 10             	add    $0x10,%esp
}
  801f08:	89 d0                	mov    %edx,%eax
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f11:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f14:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801f1a:	e8 b7 ec ff ff       	call   800bd6 <sys_getenvid>
  801f1f:	83 ec 0c             	sub    $0xc,%esp
  801f22:	ff 75 0c             	pushl  0xc(%ebp)
  801f25:	ff 75 08             	pushl  0x8(%ebp)
  801f28:	56                   	push   %esi
  801f29:	50                   	push   %eax
  801f2a:	68 38 28 80 00       	push   $0x802838
  801f2f:	e8 58 e3 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f34:	83 c4 18             	add    $0x18,%esp
  801f37:	53                   	push   %ebx
  801f38:	ff 75 10             	pushl  0x10(%ebp)
  801f3b:	e8 fb e2 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801f40:	c7 04 24 22 28 80 00 	movl   $0x802822,(%esp)
  801f47:	e8 40 e3 ff ff       	call   80028c <cprintf>
  801f4c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f4f:	cc                   	int3   
  801f50:	eb fd                	jmp    801f4f <_panic+0x43>

00801f52 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  801f58:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f5f:	75 2a                	jne    801f8b <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801f61:	83 ec 04             	sub    $0x4,%esp
  801f64:	6a 06                	push   $0x6
  801f66:	68 00 f0 bf ee       	push   $0xeebff000
  801f6b:	6a 00                	push   $0x0
  801f6d:	e8 a2 ec ff ff       	call   800c14 <sys_page_alloc>
			 if (a < 0)
  801f72:	83 c4 10             	add    $0x10,%esp
  801f75:	85 c0                	test   %eax,%eax
  801f77:	79 12                	jns    801f8b <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801f79:	50                   	push   %eax
  801f7a:	68 5c 28 80 00       	push   $0x80285c
  801f7f:	6a 21                	push   $0x21
  801f81:	68 76 28 80 00       	push   $0x802876
  801f86:	e8 81 ff ff ff       	call   801f0c <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  801f8b:	e8 46 ec ff ff       	call   800bd6 <sys_getenvid>
  801f90:	83 ec 08             	sub    $0x8,%esp
  801f93:	68 ab 1f 80 00       	push   $0x801fab
  801f98:	50                   	push   %eax
  801f99:	e8 c1 ed ff ff       	call   800d5f <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  801f9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa1:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fa6:	83 c4 10             	add    $0x10,%esp
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    

00801fab <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  801fab:	54                   	push   %esp
movl _pgfault_handler, %eax
  801fac:	a1 00 60 80 00       	mov    0x806000,%eax
call *%eax
  801fb1:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  801fb3:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  801fb6:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  801fba:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  801fbe:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  801fc1:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  801fc5:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  801fc7:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  801fca:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  801fcb:	83 c4 04             	add    $0x4,%esp
popfl
  801fce:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  801fcf:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  801fd0:	c3                   	ret    

00801fd1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd7:	89 d0                	mov    %edx,%eax
  801fd9:	c1 e8 16             	shr    $0x16,%eax
  801fdc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fe3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe8:	f6 c1 01             	test   $0x1,%cl
  801feb:	74 1d                	je     80200a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fed:	c1 ea 0c             	shr    $0xc,%edx
  801ff0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ff7:	f6 c2 01             	test   $0x1,%dl
  801ffa:	74 0e                	je     80200a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ffc:	c1 ea 0c             	shr    $0xc,%edx
  801fff:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802006:	ef 
  802007:	0f b7 c0             	movzwl %ax,%eax
}
  80200a:	5d                   	pop    %ebp
  80200b:	c3                   	ret    
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__udivdi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80201b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80201f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802027:	85 f6                	test   %esi,%esi
  802029:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80202d:	89 ca                	mov    %ecx,%edx
  80202f:	89 f8                	mov    %edi,%eax
  802031:	75 3d                	jne    802070 <__udivdi3+0x60>
  802033:	39 cf                	cmp    %ecx,%edi
  802035:	0f 87 c5 00 00 00    	ja     802100 <__udivdi3+0xf0>
  80203b:	85 ff                	test   %edi,%edi
  80203d:	89 fd                	mov    %edi,%ebp
  80203f:	75 0b                	jne    80204c <__udivdi3+0x3c>
  802041:	b8 01 00 00 00       	mov    $0x1,%eax
  802046:	31 d2                	xor    %edx,%edx
  802048:	f7 f7                	div    %edi
  80204a:	89 c5                	mov    %eax,%ebp
  80204c:	89 c8                	mov    %ecx,%eax
  80204e:	31 d2                	xor    %edx,%edx
  802050:	f7 f5                	div    %ebp
  802052:	89 c1                	mov    %eax,%ecx
  802054:	89 d8                	mov    %ebx,%eax
  802056:	89 cf                	mov    %ecx,%edi
  802058:	f7 f5                	div    %ebp
  80205a:	89 c3                	mov    %eax,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	39 ce                	cmp    %ecx,%esi
  802072:	77 74                	ja     8020e8 <__udivdi3+0xd8>
  802074:	0f bd fe             	bsr    %esi,%edi
  802077:	83 f7 1f             	xor    $0x1f,%edi
  80207a:	0f 84 98 00 00 00    	je     802118 <__udivdi3+0x108>
  802080:	bb 20 00 00 00       	mov    $0x20,%ebx
  802085:	89 f9                	mov    %edi,%ecx
  802087:	89 c5                	mov    %eax,%ebp
  802089:	29 fb                	sub    %edi,%ebx
  80208b:	d3 e6                	shl    %cl,%esi
  80208d:	89 d9                	mov    %ebx,%ecx
  80208f:	d3 ed                	shr    %cl,%ebp
  802091:	89 f9                	mov    %edi,%ecx
  802093:	d3 e0                	shl    %cl,%eax
  802095:	09 ee                	or     %ebp,%esi
  802097:	89 d9                	mov    %ebx,%ecx
  802099:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209d:	89 d5                	mov    %edx,%ebp
  80209f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020a3:	d3 ed                	shr    %cl,%ebp
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e2                	shl    %cl,%edx
  8020a9:	89 d9                	mov    %ebx,%ecx
  8020ab:	d3 e8                	shr    %cl,%eax
  8020ad:	09 c2                	or     %eax,%edx
  8020af:	89 d0                	mov    %edx,%eax
  8020b1:	89 ea                	mov    %ebp,%edx
  8020b3:	f7 f6                	div    %esi
  8020b5:	89 d5                	mov    %edx,%ebp
  8020b7:	89 c3                	mov    %eax,%ebx
  8020b9:	f7 64 24 0c          	mull   0xc(%esp)
  8020bd:	39 d5                	cmp    %edx,%ebp
  8020bf:	72 10                	jb     8020d1 <__udivdi3+0xc1>
  8020c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e6                	shl    %cl,%esi
  8020c9:	39 c6                	cmp    %eax,%esi
  8020cb:	73 07                	jae    8020d4 <__udivdi3+0xc4>
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	75 03                	jne    8020d4 <__udivdi3+0xc4>
  8020d1:	83 eb 01             	sub    $0x1,%ebx
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 d8                	mov    %ebx,%eax
  8020d8:	89 fa                	mov    %edi,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	31 ff                	xor    %edi,%edi
  8020ea:	31 db                	xor    %ebx,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	89 d8                	mov    %ebx,%eax
  802102:	f7 f7                	div    %edi
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 c3                	mov    %eax,%ebx
  802108:	89 d8                	mov    %ebx,%eax
  80210a:	89 fa                	mov    %edi,%edx
  80210c:	83 c4 1c             	add    $0x1c,%esp
  80210f:	5b                   	pop    %ebx
  802110:	5e                   	pop    %esi
  802111:	5f                   	pop    %edi
  802112:	5d                   	pop    %ebp
  802113:	c3                   	ret    
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	39 ce                	cmp    %ecx,%esi
  80211a:	72 0c                	jb     802128 <__udivdi3+0x118>
  80211c:	31 db                	xor    %ebx,%ebx
  80211e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802122:	0f 87 34 ff ff ff    	ja     80205c <__udivdi3+0x4c>
  802128:	bb 01 00 00 00       	mov    $0x1,%ebx
  80212d:	e9 2a ff ff ff       	jmp    80205c <__udivdi3+0x4c>
  802132:	66 90                	xchg   %ax,%ax
  802134:	66 90                	xchg   %ax,%ax
  802136:	66 90                	xchg   %ax,%ax
  802138:	66 90                	xchg   %ax,%ax
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <__umoddi3>:
  802140:	55                   	push   %ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	53                   	push   %ebx
  802144:	83 ec 1c             	sub    $0x1c,%esp
  802147:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80214b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80214f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802153:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802157:	85 d2                	test   %edx,%edx
  802159:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80215d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802161:	89 f3                	mov    %esi,%ebx
  802163:	89 3c 24             	mov    %edi,(%esp)
  802166:	89 74 24 04          	mov    %esi,0x4(%esp)
  80216a:	75 1c                	jne    802188 <__umoddi3+0x48>
  80216c:	39 f7                	cmp    %esi,%edi
  80216e:	76 50                	jbe    8021c0 <__umoddi3+0x80>
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	f7 f7                	div    %edi
  802176:	89 d0                	mov    %edx,%eax
  802178:	31 d2                	xor    %edx,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	39 f2                	cmp    %esi,%edx
  80218a:	89 d0                	mov    %edx,%eax
  80218c:	77 52                	ja     8021e0 <__umoddi3+0xa0>
  80218e:	0f bd ea             	bsr    %edx,%ebp
  802191:	83 f5 1f             	xor    $0x1f,%ebp
  802194:	75 5a                	jne    8021f0 <__umoddi3+0xb0>
  802196:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80219a:	0f 82 e0 00 00 00    	jb     802280 <__umoddi3+0x140>
  8021a0:	39 0c 24             	cmp    %ecx,(%esp)
  8021a3:	0f 86 d7 00 00 00    	jbe    802280 <__umoddi3+0x140>
  8021a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021b1:	83 c4 1c             	add    $0x1c,%esp
  8021b4:	5b                   	pop    %ebx
  8021b5:	5e                   	pop    %esi
  8021b6:	5f                   	pop    %edi
  8021b7:	5d                   	pop    %ebp
  8021b8:	c3                   	ret    
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	85 ff                	test   %edi,%edi
  8021c2:	89 fd                	mov    %edi,%ebp
  8021c4:	75 0b                	jne    8021d1 <__umoddi3+0x91>
  8021c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f7                	div    %edi
  8021cf:	89 c5                	mov    %eax,%ebp
  8021d1:	89 f0                	mov    %esi,%eax
  8021d3:	31 d2                	xor    %edx,%edx
  8021d5:	f7 f5                	div    %ebp
  8021d7:	89 c8                	mov    %ecx,%eax
  8021d9:	f7 f5                	div    %ebp
  8021db:	89 d0                	mov    %edx,%eax
  8021dd:	eb 99                	jmp    802178 <__umoddi3+0x38>
  8021df:	90                   	nop
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	83 c4 1c             	add    $0x1c,%esp
  8021e7:	5b                   	pop    %ebx
  8021e8:	5e                   	pop    %esi
  8021e9:	5f                   	pop    %edi
  8021ea:	5d                   	pop    %ebp
  8021eb:	c3                   	ret    
  8021ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	8b 34 24             	mov    (%esp),%esi
  8021f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021f8:	89 e9                	mov    %ebp,%ecx
  8021fa:	29 ef                	sub    %ebp,%edi
  8021fc:	d3 e0                	shl    %cl,%eax
  8021fe:	89 f9                	mov    %edi,%ecx
  802200:	89 f2                	mov    %esi,%edx
  802202:	d3 ea                	shr    %cl,%edx
  802204:	89 e9                	mov    %ebp,%ecx
  802206:	09 c2                	or     %eax,%edx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 14 24             	mov    %edx,(%esp)
  80220d:	89 f2                	mov    %esi,%edx
  80220f:	d3 e2                	shl    %cl,%edx
  802211:	89 f9                	mov    %edi,%ecx
  802213:	89 54 24 04          	mov    %edx,0x4(%esp)
  802217:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	89 c6                	mov    %eax,%esi
  802221:	d3 e3                	shl    %cl,%ebx
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 d0                	mov    %edx,%eax
  802227:	d3 e8                	shr    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	09 d8                	or     %ebx,%eax
  80222d:	89 d3                	mov    %edx,%ebx
  80222f:	89 f2                	mov    %esi,%edx
  802231:	f7 34 24             	divl   (%esp)
  802234:	89 d6                	mov    %edx,%esi
  802236:	d3 e3                	shl    %cl,%ebx
  802238:	f7 64 24 04          	mull   0x4(%esp)
  80223c:	39 d6                	cmp    %edx,%esi
  80223e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802242:	89 d1                	mov    %edx,%ecx
  802244:	89 c3                	mov    %eax,%ebx
  802246:	72 08                	jb     802250 <__umoddi3+0x110>
  802248:	75 11                	jne    80225b <__umoddi3+0x11b>
  80224a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80224e:	73 0b                	jae    80225b <__umoddi3+0x11b>
  802250:	2b 44 24 04          	sub    0x4(%esp),%eax
  802254:	1b 14 24             	sbb    (%esp),%edx
  802257:	89 d1                	mov    %edx,%ecx
  802259:	89 c3                	mov    %eax,%ebx
  80225b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80225f:	29 da                	sub    %ebx,%edx
  802261:	19 ce                	sbb    %ecx,%esi
  802263:	89 f9                	mov    %edi,%ecx
  802265:	89 f0                	mov    %esi,%eax
  802267:	d3 e0                	shl    %cl,%eax
  802269:	89 e9                	mov    %ebp,%ecx
  80226b:	d3 ea                	shr    %cl,%edx
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	d3 ee                	shr    %cl,%esi
  802271:	09 d0                	or     %edx,%eax
  802273:	89 f2                	mov    %esi,%edx
  802275:	83 c4 1c             	add    $0x1c,%esp
  802278:	5b                   	pop    %ebx
  802279:	5e                   	pop    %esi
  80227a:	5f                   	pop    %edi
  80227b:	5d                   	pop    %ebp
  80227c:	c3                   	ret    
  80227d:	8d 76 00             	lea    0x0(%esi),%esi
  802280:	29 f9                	sub    %edi,%ecx
  802282:	19 d6                	sbb    %edx,%esi
  802284:	89 74 24 04          	mov    %esi,0x4(%esp)
  802288:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80228c:	e9 18 ff ff ff       	jmp    8021a9 <__umoddi3+0x69>
