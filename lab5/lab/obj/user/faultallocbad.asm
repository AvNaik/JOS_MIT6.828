
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800040:	68 e0 1e 80 00       	push   $0x801ee0
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 18 0b 00 00       	call   800b76 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 00 1f 80 00       	push   $0x801f00
  80006f:	6a 0f                	push   $0xf
  800071:	68 ea 1e 80 00       	push   $0x801eea
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 2c 1f 80 00       	push   $0x801f2c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 97 06 00 00       	call   800720 <snprintf>
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
  80009c:	e8 c6 0c 00 00       	call   800d67 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 0a 0a 00 00       	call   800aba <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000c0:	e8 73 0a 00 00       	call   800b38 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 ab 0e 00 00       	call   800fb1 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 e7 09 00 00       	call   800af7 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 10 0a 00 00       	call   800b38 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 58 1f 80 00       	push   $0x801f58
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 c2 23 80 00 	movl   $0x8023c2,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 2f 09 00 00       	call   800aba <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 54 01 00 00       	call   800325 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 d4 08 00 00       	call   800aba <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 ea 19 00 00       	call   801c40 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 d7 1a 00 00       	call   801d70 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 7b 1f 80 00 	movsbl 0x801f7b(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b4:	83 fa 01             	cmp    $0x1,%edx
  8002b7:	7e 0e                	jle    8002c7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	8b 52 04             	mov    0x4(%edx),%edx
  8002c5:	eb 22                	jmp    8002e9 <getuint+0x38>
	else if (lflag)
  8002c7:	85 d2                	test   %edx,%edx
  8002c9:	74 10                	je     8002db <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	eb 0e                	jmp    8002e9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fa:	73 0a                	jae    800306 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	88 02                	mov    %al,(%edx)
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 10             	pushl  0x10(%ebp)
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	e8 05 00 00 00       	call   800325 <vprintfmt>
	va_end(ap);
}
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
  80032e:	8b 75 08             	mov    0x8(%ebp),%esi
  800331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800334:	8b 7d 10             	mov    0x10(%ebp),%edi
  800337:	eb 12                	jmp    80034b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800339:	85 c0                	test   %eax,%eax
  80033b:	0f 84 89 03 00 00    	je     8006ca <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	53                   	push   %ebx
  800345:	50                   	push   %eax
  800346:	ff d6                	call   *%esi
  800348:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034b:	83 c7 01             	add    $0x1,%edi
  80034e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800352:	83 f8 25             	cmp    $0x25,%eax
  800355:	75 e2                	jne    800339 <vprintfmt+0x14>
  800357:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800362:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800369:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	eb 07                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8d 47 01             	lea    0x1(%edi),%eax
  800381:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800384:	0f b6 07             	movzbl (%edi),%eax
  800387:	0f b6 c8             	movzbl %al,%ecx
  80038a:	83 e8 23             	sub    $0x23,%eax
  80038d:	3c 55                	cmp    $0x55,%al
  80038f:	0f 87 1a 03 00 00    	ja     8006af <vprintfmt+0x38a>
  800395:	0f b6 c0             	movzbl %al,%eax
  800398:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a6:	eb d6                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c0:	83 fa 09             	cmp    $0x9,%edx
  8003c3:	77 39                	ja     8003fe <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c8:	eb e9                	jmp    8003b3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003db:	eb 27                	jmp    800404 <vprintfmt+0xdf>
  8003dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e7:	0f 49 c8             	cmovns %eax,%ecx
  8003ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f0:	eb 8c                	jmp    80037e <vprintfmt+0x59>
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fc:	eb 80                	jmp    80037e <vprintfmt+0x59>
  8003fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800401:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800404:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800408:	0f 89 70 ff ff ff    	jns    80037e <vprintfmt+0x59>
				width = precision, precision = -1;
  80040e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800411:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800414:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041b:	e9 5e ff ff ff       	jmp    80037e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800420:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800426:	e9 53 ff ff ff       	jmp    80037e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 50 04             	lea    0x4(%eax),%edx
  800431:	89 55 14             	mov    %edx,0x14(%ebp)
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	ff 30                	pushl  (%eax)
  80043a:	ff d6                	call   *%esi
			break;
  80043c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800442:	e9 04 ff ff ff       	jmp    80034b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 00                	mov    (%eax),%eax
  800452:	99                   	cltd   
  800453:	31 d0                	xor    %edx,%eax
  800455:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800457:	83 f8 0f             	cmp    $0xf,%eax
  80045a:	7f 0b                	jg     800467 <vprintfmt+0x142>
  80045c:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  800463:	85 d2                	test   %edx,%edx
  800465:	75 18                	jne    80047f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800467:	50                   	push   %eax
  800468:	68 93 1f 80 00       	push   $0x801f93
  80046d:	53                   	push   %ebx
  80046e:	56                   	push   %esi
  80046f:	e8 94 fe ff ff       	call   800308 <printfmt>
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047a:	e9 cc fe ff ff       	jmp    80034b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047f:	52                   	push   %edx
  800480:	68 7d 23 80 00       	push   $0x80237d
  800485:	53                   	push   %ebx
  800486:	56                   	push   %esi
  800487:	e8 7c fe ff ff       	call   800308 <printfmt>
  80048c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	e9 b4 fe ff ff       	jmp    80034b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 50 04             	lea    0x4(%eax),%edx
  80049d:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a2:	85 ff                	test   %edi,%edi
  8004a4:	b8 8c 1f 80 00       	mov    $0x801f8c,%eax
  8004a9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b0:	0f 8e 94 00 00 00    	jle    80054a <vprintfmt+0x225>
  8004b6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ba:	0f 84 98 00 00 00    	je     800558 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c6:	57                   	push   %edi
  8004c7:	e8 86 02 00 00       	call   800752 <strnlen>
  8004cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004cf:	29 c1                	sub    %eax,%ecx
  8004d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004de:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	eb 0f                	jmp    8004f4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	83 ef 01             	sub    $0x1,%edi
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f ed                	jg     8004e5 <vprintfmt+0x1c0>
  8004f8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004fe:	85 c9                	test   %ecx,%ecx
  800500:	b8 00 00 00 00       	mov    $0x0,%eax
  800505:	0f 49 c1             	cmovns %ecx,%eax
  800508:	29 c1                	sub    %eax,%ecx
  80050a:	89 75 08             	mov    %esi,0x8(%ebp)
  80050d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800510:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800513:	89 cb                	mov    %ecx,%ebx
  800515:	eb 4d                	jmp    800564 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800517:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051b:	74 1b                	je     800538 <vprintfmt+0x213>
  80051d:	0f be c0             	movsbl %al,%eax
  800520:	83 e8 20             	sub    $0x20,%eax
  800523:	83 f8 5e             	cmp    $0x5e,%eax
  800526:	76 10                	jbe    800538 <vprintfmt+0x213>
					putch('?', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	ff 75 0c             	pushl  0xc(%ebp)
  80052e:	6a 3f                	push   $0x3f
  800530:	ff 55 08             	call   *0x8(%ebp)
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	eb 0d                	jmp    800545 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	52                   	push   %edx
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800545:	83 eb 01             	sub    $0x1,%ebx
  800548:	eb 1a                	jmp    800564 <vprintfmt+0x23f>
  80054a:	89 75 08             	mov    %esi,0x8(%ebp)
  80054d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800550:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800553:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800556:	eb 0c                	jmp    800564 <vprintfmt+0x23f>
  800558:	89 75 08             	mov    %esi,0x8(%ebp)
  80055b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800561:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800564:	83 c7 01             	add    $0x1,%edi
  800567:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056b:	0f be d0             	movsbl %al,%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	74 23                	je     800595 <vprintfmt+0x270>
  800572:	85 f6                	test   %esi,%esi
  800574:	78 a1                	js     800517 <vprintfmt+0x1f2>
  800576:	83 ee 01             	sub    $0x1,%esi
  800579:	79 9c                	jns    800517 <vprintfmt+0x1f2>
  80057b:	89 df                	mov    %ebx,%edi
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800583:	eb 18                	jmp    80059d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	53                   	push   %ebx
  800589:	6a 20                	push   $0x20
  80058b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058d:	83 ef 01             	sub    $0x1,%edi
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	eb 08                	jmp    80059d <vprintfmt+0x278>
  800595:	89 df                	mov    %ebx,%edi
  800597:	8b 75 08             	mov    0x8(%ebp),%esi
  80059a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059d:	85 ff                	test   %edi,%edi
  80059f:	7f e4                	jg     800585 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a4:	e9 a2 fd ff ff       	jmp    80034b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a9:	83 fa 01             	cmp    $0x1,%edx
  8005ac:	7e 16                	jle    8005c4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 08             	lea    0x8(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 50 04             	mov    0x4(%eax),%edx
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c2:	eb 32                	jmp    8005f6 <vprintfmt+0x2d1>
	else if (lflag)
  8005c4:	85 d2                	test   %edx,%edx
  8005c6:	74 18                	je     8005e0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 c1                	mov    %eax,%ecx
  8005d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005de:	eb 16                	jmp    8005f6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800601:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800605:	79 74                	jns    80067b <vprintfmt+0x356>
				putch('-', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 2d                	push   $0x2d
  80060d:	ff d6                	call   *%esi
				num = -(long long) num;
  80060f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800612:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800615:	f7 d8                	neg    %eax
  800617:	83 d2 00             	adc    $0x0,%edx
  80061a:	f7 da                	neg    %edx
  80061c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80061f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800624:	eb 55                	jmp    80067b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 83 fc ff ff       	call   8002b1 <getuint>
			base = 10;
  80062e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800633:	eb 46                	jmp    80067b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800635:	8d 45 14             	lea    0x14(%ebp),%eax
  800638:	e8 74 fc ff ff       	call   8002b1 <getuint>
			base = 8;
  80063d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800642:	eb 37                	jmp    80067b <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 30                	push   $0x30
  80064a:	ff d6                	call   *%esi
			putch('x', putdat);
  80064c:	83 c4 08             	add    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 78                	push   $0x78
  800652:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800664:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800667:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066c:	eb 0d                	jmp    80067b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 3b fc ff ff       	call   8002b1 <getuint>
			base = 16;
  800676:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067b:	83 ec 0c             	sub    $0xc,%esp
  80067e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800682:	57                   	push   %edi
  800683:	ff 75 e0             	pushl  -0x20(%ebp)
  800686:	51                   	push   %ecx
  800687:	52                   	push   %edx
  800688:	50                   	push   %eax
  800689:	89 da                	mov    %ebx,%edx
  80068b:	89 f0                	mov    %esi,%eax
  80068d:	e8 70 fb ff ff       	call   800202 <printnum>
			break;
  800692:	83 c4 20             	add    $0x20,%esp
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800698:	e9 ae fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	51                   	push   %ecx
  8006a2:	ff d6                	call   *%esi
			break;
  8006a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006aa:	e9 9c fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 25                	push   $0x25
  8006b5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 03                	jmp    8006bf <vprintfmt+0x39a>
  8006bc:	83 ef 01             	sub    $0x1,%edi
  8006bf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c3:	75 f7                	jne    8006bc <vprintfmt+0x397>
  8006c5:	e9 81 fc ff ff       	jmp    80034b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cd:	5b                   	pop    %ebx
  8006ce:	5e                   	pop    %esi
  8006cf:	5f                   	pop    %edi
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	83 ec 18             	sub    $0x18,%esp
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	74 26                	je     800719 <vsnprintf+0x47>
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	7e 22                	jle    800719 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f7:	ff 75 14             	pushl  0x14(%ebp)
  8006fa:	ff 75 10             	pushl  0x10(%ebp)
  8006fd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800700:	50                   	push   %eax
  800701:	68 eb 02 80 00       	push   $0x8002eb
  800706:	e8 1a fc ff ff       	call   800325 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800711:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 05                	jmp    80071e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800719:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800729:	50                   	push   %eax
  80072a:	ff 75 10             	pushl  0x10(%ebp)
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	e8 9a ff ff ff       	call   8006d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800740:	b8 00 00 00 00       	mov    $0x0,%eax
  800745:	eb 03                	jmp    80074a <strlen+0x10>
		n++;
  800747:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074e:	75 f7                	jne    800747 <strlen+0xd>
		n++;
	return n;
}
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800758:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075b:	ba 00 00 00 00       	mov    $0x0,%edx
  800760:	eb 03                	jmp    800765 <strnlen+0x13>
		n++;
  800762:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	39 c2                	cmp    %eax,%edx
  800767:	74 08                	je     800771 <strnlen+0x1f>
  800769:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076d:	75 f3                	jne    800762 <strnlen+0x10>
  80076f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	83 c2 01             	add    $0x1,%edx
  800782:	83 c1 01             	add    $0x1,%ecx
  800785:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078c:	84 db                	test   %bl,%bl
  80078e:	75 ef                	jne    80077f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800790:	5b                   	pop    %ebx
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079a:	53                   	push   %ebx
  80079b:	e8 9a ff ff ff       	call   80073a <strlen>
  8007a0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a3:	ff 75 0c             	pushl  0xc(%ebp)
  8007a6:	01 d8                	add    %ebx,%eax
  8007a8:	50                   	push   %eax
  8007a9:	e8 c5 ff ff ff       	call   800773 <strcpy>
	return dst;
}
  8007ae:	89 d8                	mov    %ebx,%eax
  8007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c0:	89 f3                	mov    %esi,%ebx
  8007c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	89 f2                	mov    %esi,%edx
  8007c7:	eb 0f                	jmp    8007d8 <strncpy+0x23>
		*dst++ = *src;
  8007c9:	83 c2 01             	add    $0x1,%edx
  8007cc:	0f b6 01             	movzbl (%ecx),%eax
  8007cf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d8:	39 da                	cmp    %ebx,%edx
  8007da:	75 ed                	jne    8007c9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	74 21                	je     800817 <strlcpy+0x35>
  8007f6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fa:	89 f2                	mov    %esi,%edx
  8007fc:	eb 09                	jmp    800807 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	83 c1 01             	add    $0x1,%ecx
  800804:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800807:	39 c2                	cmp    %eax,%edx
  800809:	74 09                	je     800814 <strlcpy+0x32>
  80080b:	0f b6 19             	movzbl (%ecx),%ebx
  80080e:	84 db                	test   %bl,%bl
  800810:	75 ec                	jne    8007fe <strlcpy+0x1c>
  800812:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800814:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800817:	29 f0                	sub    %esi,%eax
}
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800826:	eb 06                	jmp    80082e <strcmp+0x11>
		p++, q++;
  800828:	83 c1 01             	add    $0x1,%ecx
  80082b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082e:	0f b6 01             	movzbl (%ecx),%eax
  800831:	84 c0                	test   %al,%al
  800833:	74 04                	je     800839 <strcmp+0x1c>
  800835:	3a 02                	cmp    (%edx),%al
  800837:	74 ef                	je     800828 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800839:	0f b6 c0             	movzbl %al,%eax
  80083c:	0f b6 12             	movzbl (%edx),%edx
  80083f:	29 d0                	sub    %edx,%eax
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084d:	89 c3                	mov    %eax,%ebx
  80084f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800852:	eb 06                	jmp    80085a <strncmp+0x17>
		n--, p++, q++;
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085a:	39 d8                	cmp    %ebx,%eax
  80085c:	74 15                	je     800873 <strncmp+0x30>
  80085e:	0f b6 08             	movzbl (%eax),%ecx
  800861:	84 c9                	test   %cl,%cl
  800863:	74 04                	je     800869 <strncmp+0x26>
  800865:	3a 0a                	cmp    (%edx),%cl
  800867:	74 eb                	je     800854 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800869:	0f b6 00             	movzbl (%eax),%eax
  80086c:	0f b6 12             	movzbl (%edx),%edx
  80086f:	29 d0                	sub    %edx,%eax
  800871:	eb 05                	jmp    800878 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800878:	5b                   	pop    %ebx
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800885:	eb 07                	jmp    80088e <strchr+0x13>
		if (*s == c)
  800887:	38 ca                	cmp    %cl,%dl
  800889:	74 0f                	je     80089a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088b:	83 c0 01             	add    $0x1,%eax
  80088e:	0f b6 10             	movzbl (%eax),%edx
  800891:	84 d2                	test   %dl,%dl
  800893:	75 f2                	jne    800887 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a6:	eb 03                	jmp    8008ab <strfind+0xf>
  8008a8:	83 c0 01             	add    $0x1,%eax
  8008ab:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	74 04                	je     8008b6 <strfind+0x1a>
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	75 f2                	jne    8008a8 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	57                   	push   %edi
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
  8008be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c4:	85 c9                	test   %ecx,%ecx
  8008c6:	74 36                	je     8008fe <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ce:	75 28                	jne    8008f8 <memset+0x40>
  8008d0:	f6 c1 03             	test   $0x3,%cl
  8008d3:	75 23                	jne    8008f8 <memset+0x40>
		c &= 0xFF;
  8008d5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d9:	89 d3                	mov    %edx,%ebx
  8008db:	c1 e3 08             	shl    $0x8,%ebx
  8008de:	89 d6                	mov    %edx,%esi
  8008e0:	c1 e6 18             	shl    $0x18,%esi
  8008e3:	89 d0                	mov    %edx,%eax
  8008e5:	c1 e0 10             	shl    $0x10,%eax
  8008e8:	09 f0                	or     %esi,%eax
  8008ea:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ec:	89 d8                	mov    %ebx,%eax
  8008ee:	09 d0                	or     %edx,%eax
  8008f0:	c1 e9 02             	shr    $0x2,%ecx
  8008f3:	fc                   	cld    
  8008f4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f6:	eb 06                	jmp    8008fe <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fb:	fc                   	cld    
  8008fc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fe:	89 f8                	mov    %edi,%eax
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5f                   	pop    %edi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800910:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800913:	39 c6                	cmp    %eax,%esi
  800915:	73 35                	jae    80094c <memmove+0x47>
  800917:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	73 2e                	jae    80094c <memmove+0x47>
		s += n;
		d += n;
  80091e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800921:	89 d6                	mov    %edx,%esi
  800923:	09 fe                	or     %edi,%esi
  800925:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092b:	75 13                	jne    800940 <memmove+0x3b>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 0e                	jne    800940 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800932:	83 ef 04             	sub    $0x4,%edi
  800935:	8d 72 fc             	lea    -0x4(%edx),%esi
  800938:	c1 e9 02             	shr    $0x2,%ecx
  80093b:	fd                   	std    
  80093c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093e:	eb 09                	jmp    800949 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800940:	83 ef 01             	sub    $0x1,%edi
  800943:	8d 72 ff             	lea    -0x1(%edx),%esi
  800946:	fd                   	std    
  800947:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800949:	fc                   	cld    
  80094a:	eb 1d                	jmp    800969 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094c:	89 f2                	mov    %esi,%edx
  80094e:	09 c2                	or     %eax,%edx
  800950:	f6 c2 03             	test   $0x3,%dl
  800953:	75 0f                	jne    800964 <memmove+0x5f>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 0a                	jne    800964 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095a:	c1 e9 02             	shr    $0x2,%ecx
  80095d:	89 c7                	mov    %eax,%edi
  80095f:	fc                   	cld    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 05                	jmp    800969 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800964:	89 c7                	mov    %eax,%edi
  800966:	fc                   	cld    
  800967:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800969:	5e                   	pop    %esi
  80096a:	5f                   	pop    %edi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800970:	ff 75 10             	pushl  0x10(%ebp)
  800973:	ff 75 0c             	pushl  0xc(%ebp)
  800976:	ff 75 08             	pushl  0x8(%ebp)
  800979:	e8 87 ff ff ff       	call   800905 <memmove>
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098b:	89 c6                	mov    %eax,%esi
  80098d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800990:	eb 1a                	jmp    8009ac <memcmp+0x2c>
		if (*s1 != *s2)
  800992:	0f b6 08             	movzbl (%eax),%ecx
  800995:	0f b6 1a             	movzbl (%edx),%ebx
  800998:	38 d9                	cmp    %bl,%cl
  80099a:	74 0a                	je     8009a6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099c:	0f b6 c1             	movzbl %cl,%eax
  80099f:	0f b6 db             	movzbl %bl,%ebx
  8009a2:	29 d8                	sub    %ebx,%eax
  8009a4:	eb 0f                	jmp    8009b5 <memcmp+0x35>
		s1++, s2++;
  8009a6:	83 c0 01             	add    $0x1,%eax
  8009a9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ac:	39 f0                	cmp    %esi,%eax
  8009ae:	75 e2                	jne    800992 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c0:	89 c1                	mov    %eax,%ecx
  8009c2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c9:	eb 0a                	jmp    8009d5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cb:	0f b6 10             	movzbl (%eax),%edx
  8009ce:	39 da                	cmp    %ebx,%edx
  8009d0:	74 07                	je     8009d9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	39 c8                	cmp    %ecx,%eax
  8009d7:	72 f2                	jb     8009cb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e8:	eb 03                	jmp    8009ed <strtol+0x11>
		s++;
  8009ea:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ed:	0f b6 01             	movzbl (%ecx),%eax
  8009f0:	3c 20                	cmp    $0x20,%al
  8009f2:	74 f6                	je     8009ea <strtol+0xe>
  8009f4:	3c 09                	cmp    $0x9,%al
  8009f6:	74 f2                	je     8009ea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f8:	3c 2b                	cmp    $0x2b,%al
  8009fa:	75 0a                	jne    800a06 <strtol+0x2a>
		s++;
  8009fc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ff:	bf 00 00 00 00       	mov    $0x0,%edi
  800a04:	eb 11                	jmp    800a17 <strtol+0x3b>
  800a06:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0b:	3c 2d                	cmp    $0x2d,%al
  800a0d:	75 08                	jne    800a17 <strtol+0x3b>
		s++, neg = 1;
  800a0f:	83 c1 01             	add    $0x1,%ecx
  800a12:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1d:	75 15                	jne    800a34 <strtol+0x58>
  800a1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a22:	75 10                	jne    800a34 <strtol+0x58>
  800a24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a28:	75 7c                	jne    800aa6 <strtol+0xca>
		s += 2, base = 16;
  800a2a:	83 c1 02             	add    $0x2,%ecx
  800a2d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a32:	eb 16                	jmp    800a4a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a34:	85 db                	test   %ebx,%ebx
  800a36:	75 12                	jne    800a4a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a38:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a40:	75 08                	jne    800a4a <strtol+0x6e>
		s++, base = 8;
  800a42:	83 c1 01             	add    $0x1,%ecx
  800a45:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a52:	0f b6 11             	movzbl (%ecx),%edx
  800a55:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a58:	89 f3                	mov    %esi,%ebx
  800a5a:	80 fb 09             	cmp    $0x9,%bl
  800a5d:	77 08                	ja     800a67 <strtol+0x8b>
			dig = *s - '0';
  800a5f:	0f be d2             	movsbl %dl,%edx
  800a62:	83 ea 30             	sub    $0x30,%edx
  800a65:	eb 22                	jmp    800a89 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a67:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	80 fb 19             	cmp    $0x19,%bl
  800a6f:	77 08                	ja     800a79 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a71:	0f be d2             	movsbl %dl,%edx
  800a74:	83 ea 57             	sub    $0x57,%edx
  800a77:	eb 10                	jmp    800a89 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a79:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 19             	cmp    $0x19,%bl
  800a81:	77 16                	ja     800a99 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a89:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8c:	7d 0b                	jge    800a99 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a95:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a97:	eb b9                	jmp    800a52 <strtol+0x76>

	if (endptr)
  800a99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9d:	74 0d                	je     800aac <strtol+0xd0>
		*endptr = (char *) s;
  800a9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa2:	89 0e                	mov    %ecx,(%esi)
  800aa4:	eb 06                	jmp    800aac <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	74 98                	je     800a42 <strtol+0x66>
  800aaa:	eb 9e                	jmp    800a4a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aac:	89 c2                	mov    %eax,%edx
  800aae:	f7 da                	neg    %edx
  800ab0:	85 ff                	test   %edi,%edi
  800ab2:	0f 45 c2             	cmovne %edx,%eax
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  800acb:	89 c3                	mov    %eax,%ebx
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	89 c6                	mov    %eax,%esi
  800ad1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae8:	89 d1                	mov    %edx,%ecx
  800aea:	89 d3                	mov    %edx,%ebx
  800aec:	89 d7                	mov    %edx,%edi
  800aee:	89 d6                	mov    %edx,%esi
  800af0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b05:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0d:	89 cb                	mov    %ecx,%ebx
  800b0f:	89 cf                	mov    %ecx,%edi
  800b11:	89 ce                	mov    %ecx,%esi
  800b13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b15:	85 c0                	test   %eax,%eax
  800b17:	7e 17                	jle    800b30 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	50                   	push   %eax
  800b1d:	6a 03                	push   $0x3
  800b1f:	68 7f 22 80 00       	push   $0x80227f
  800b24:	6a 23                	push   $0x23
  800b26:	68 9c 22 80 00       	push   $0x80229c
  800b2b:	e8 e5 f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 02 00 00 00       	mov    $0x2,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_yield>:

void
sys_yield(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	be 00 00 00 00       	mov    $0x0,%esi
  800b84:	b8 04 00 00 00       	mov    $0x4,%eax
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b92:	89 f7                	mov    %esi,%edi
  800b94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b96:	85 c0                	test   %eax,%eax
  800b98:	7e 17                	jle    800bb1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	6a 04                	push   $0x4
  800ba0:	68 7f 22 80 00       	push   $0x80227f
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 9c 22 80 00       	push   $0x80229c
  800bac:	e8 64 f5 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 05                	push   $0x5
  800be2:	68 7f 22 80 00       	push   $0x80227f
  800be7:	6a 23                	push   $0x23
  800be9:	68 9c 22 80 00       	push   $0x80229c
  800bee:	e8 22 f5 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c09:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	89 df                	mov    %ebx,%edi
  800c16:	89 de                	mov    %ebx,%esi
  800c18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 06                	push   $0x6
  800c24:	68 7f 22 80 00       	push   $0x80227f
  800c29:	6a 23                	push   $0x23
  800c2b:	68 9c 22 80 00       	push   $0x80229c
  800c30:	e8 e0 f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	89 df                	mov    %ebx,%edi
  800c58:	89 de                	mov    %ebx,%esi
  800c5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 08                	push   $0x8
  800c66:	68 7f 22 80 00       	push   $0x80227f
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 9c 22 80 00       	push   $0x80229c
  800c72:	e8 9e f4 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 09                	push   $0x9
  800ca8:	68 7f 22 80 00       	push   $0x80227f
  800cad:	6a 23                	push   $0x23
  800caf:	68 9c 22 80 00       	push   $0x80229c
  800cb4:	e8 5c f4 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 0a                	push   $0xa
  800cea:	68 7f 22 80 00       	push   $0x80227f
  800cef:	6a 23                	push   $0x23
  800cf1:	68 9c 22 80 00       	push   $0x80229c
  800cf6:	e8 1a f4 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	be 00 00 00 00       	mov    $0x0,%esi
  800d0e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d34:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	89 cb                	mov    %ecx,%ebx
  800d3e:	89 cf                	mov    %ecx,%edi
  800d40:	89 ce                	mov    %ecx,%esi
  800d42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 0d                	push   $0xd
  800d4e:	68 7f 22 80 00       	push   $0x80227f
  800d53:	6a 23                	push   $0x23
  800d55:	68 9c 22 80 00       	push   $0x80229c
  800d5a:	e8 b6 f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  800d6d:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d74:	75 2a                	jne    800da0 <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  800d76:	83 ec 04             	sub    $0x4,%esp
  800d79:	6a 06                	push   $0x6
  800d7b:	68 00 f0 bf ee       	push   $0xeebff000
  800d80:	6a 00                	push   $0x0
  800d82:	e8 ef fd ff ff       	call   800b76 <sys_page_alloc>
			 if (a < 0)
  800d87:	83 c4 10             	add    $0x10,%esp
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	79 12                	jns    800da0 <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  800d8e:	50                   	push   %eax
  800d8f:	68 aa 22 80 00       	push   $0x8022aa
  800d94:	6a 21                	push   $0x21
  800d96:	68 c4 22 80 00       	push   $0x8022c4
  800d9b:	e8 75 f3 ff ff       	call   800115 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  800da0:	e8 93 fd ff ff       	call   800b38 <sys_getenvid>
  800da5:	83 ec 08             	sub    $0x8,%esp
  800da8:	68 c0 0d 80 00       	push   $0x800dc0
  800dad:	50                   	push   %eax
  800dae:	e8 0e ff ff ff       	call   800cc1 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	c9                   	leave  
  800dbf:	c3                   	ret    

00800dc0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  800dc0:	54                   	push   %esp
movl _pgfault_handler, %eax
  800dc1:	a1 08 40 80 00       	mov    0x804008,%eax
call *%eax
  800dc6:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  800dc8:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  800dcb:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  800dcf:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  800dd3:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  800dd6:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  800dda:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  800ddc:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  800ddf:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  800de0:	83 c4 04             	add    $0x4,%esp
popfl
  800de3:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  800de4:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  800de5:	c3                   	ret    

00800de6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	05 00 00 00 30       	add    $0x30000000,%eax
  800df1:	c1 e8 0c             	shr    $0xc,%eax
}
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	05 00 00 00 30       	add    $0x30000000,%eax
  800e01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e06:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e13:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e18:	89 c2                	mov    %eax,%edx
  800e1a:	c1 ea 16             	shr    $0x16,%edx
  800e1d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e24:	f6 c2 01             	test   $0x1,%dl
  800e27:	74 11                	je     800e3a <fd_alloc+0x2d>
  800e29:	89 c2                	mov    %eax,%edx
  800e2b:	c1 ea 0c             	shr    $0xc,%edx
  800e2e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e35:	f6 c2 01             	test   $0x1,%dl
  800e38:	75 09                	jne    800e43 <fd_alloc+0x36>
			*fd_store = fd;
  800e3a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e41:	eb 17                	jmp    800e5a <fd_alloc+0x4d>
  800e43:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e48:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e4d:	75 c9                	jne    800e18 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e4f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e55:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e62:	83 f8 1f             	cmp    $0x1f,%eax
  800e65:	77 36                	ja     800e9d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e67:	c1 e0 0c             	shl    $0xc,%eax
  800e6a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e6f:	89 c2                	mov    %eax,%edx
  800e71:	c1 ea 16             	shr    $0x16,%edx
  800e74:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e7b:	f6 c2 01             	test   $0x1,%dl
  800e7e:	74 24                	je     800ea4 <fd_lookup+0x48>
  800e80:	89 c2                	mov    %eax,%edx
  800e82:	c1 ea 0c             	shr    $0xc,%edx
  800e85:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8c:	f6 c2 01             	test   $0x1,%dl
  800e8f:	74 1a                	je     800eab <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e94:	89 02                	mov    %eax,(%edx)
	return 0;
  800e96:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9b:	eb 13                	jmp    800eb0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea2:	eb 0c                	jmp    800eb0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea9:	eb 05                	jmp    800eb0 <fd_lookup+0x54>
  800eab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	83 ec 08             	sub    $0x8,%esp
  800eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebb:	ba 54 23 80 00       	mov    $0x802354,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ec0:	eb 13                	jmp    800ed5 <dev_lookup+0x23>
  800ec2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ec5:	39 08                	cmp    %ecx,(%eax)
  800ec7:	75 0c                	jne    800ed5 <dev_lookup+0x23>
			*dev = devtab[i];
  800ec9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ece:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed3:	eb 2e                	jmp    800f03 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ed5:	8b 02                	mov    (%edx),%eax
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	75 e7                	jne    800ec2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800edb:	a1 04 40 80 00       	mov    0x804004,%eax
  800ee0:	8b 40 48             	mov    0x48(%eax),%eax
  800ee3:	83 ec 04             	sub    $0x4,%esp
  800ee6:	51                   	push   %ecx
  800ee7:	50                   	push   %eax
  800ee8:	68 d4 22 80 00       	push   $0x8022d4
  800eed:	e8 fc f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800efb:	83 c4 10             	add    $0x10,%esp
  800efe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f03:	c9                   	leave  
  800f04:	c3                   	ret    

00800f05 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	56                   	push   %esi
  800f09:	53                   	push   %ebx
  800f0a:	83 ec 10             	sub    $0x10,%esp
  800f0d:	8b 75 08             	mov    0x8(%ebp),%esi
  800f10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f16:	50                   	push   %eax
  800f17:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f1d:	c1 e8 0c             	shr    $0xc,%eax
  800f20:	50                   	push   %eax
  800f21:	e8 36 ff ff ff       	call   800e5c <fd_lookup>
  800f26:	83 c4 08             	add    $0x8,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	78 05                	js     800f32 <fd_close+0x2d>
	    || fd != fd2)
  800f2d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f30:	74 0c                	je     800f3e <fd_close+0x39>
		return (must_exist ? r : 0);
  800f32:	84 db                	test   %bl,%bl
  800f34:	ba 00 00 00 00       	mov    $0x0,%edx
  800f39:	0f 44 c2             	cmove  %edx,%eax
  800f3c:	eb 41                	jmp    800f7f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f3e:	83 ec 08             	sub    $0x8,%esp
  800f41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f44:	50                   	push   %eax
  800f45:	ff 36                	pushl  (%esi)
  800f47:	e8 66 ff ff ff       	call   800eb2 <dev_lookup>
  800f4c:	89 c3                	mov    %eax,%ebx
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	85 c0                	test   %eax,%eax
  800f53:	78 1a                	js     800f6f <fd_close+0x6a>
		if (dev->dev_close)
  800f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f58:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f5b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f60:	85 c0                	test   %eax,%eax
  800f62:	74 0b                	je     800f6f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f64:	83 ec 0c             	sub    $0xc,%esp
  800f67:	56                   	push   %esi
  800f68:	ff d0                	call   *%eax
  800f6a:	89 c3                	mov    %eax,%ebx
  800f6c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f6f:	83 ec 08             	sub    $0x8,%esp
  800f72:	56                   	push   %esi
  800f73:	6a 00                	push   $0x0
  800f75:	e8 81 fc ff ff       	call   800bfb <sys_page_unmap>
	return r;
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	89 d8                	mov    %ebx,%eax
}
  800f7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8f:	50                   	push   %eax
  800f90:	ff 75 08             	pushl  0x8(%ebp)
  800f93:	e8 c4 fe ff ff       	call   800e5c <fd_lookup>
  800f98:	83 c4 08             	add    $0x8,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 10                	js     800faf <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f9f:	83 ec 08             	sub    $0x8,%esp
  800fa2:	6a 01                	push   $0x1
  800fa4:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa7:	e8 59 ff ff ff       	call   800f05 <fd_close>
  800fac:	83 c4 10             	add    $0x10,%esp
}
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <close_all>:

void
close_all(void)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	53                   	push   %ebx
  800fb5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	53                   	push   %ebx
  800fc1:	e8 c0 ff ff ff       	call   800f86 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc6:	83 c3 01             	add    $0x1,%ebx
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	83 fb 20             	cmp    $0x20,%ebx
  800fcf:	75 ec                	jne    800fbd <close_all+0xc>
		close(i);
}
  800fd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	57                   	push   %edi
  800fda:	56                   	push   %esi
  800fdb:	53                   	push   %ebx
  800fdc:	83 ec 2c             	sub    $0x2c,%esp
  800fdf:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fe2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe5:	50                   	push   %eax
  800fe6:	ff 75 08             	pushl  0x8(%ebp)
  800fe9:	e8 6e fe ff ff       	call   800e5c <fd_lookup>
  800fee:	83 c4 08             	add    $0x8,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	0f 88 c1 00 00 00    	js     8010ba <dup+0xe4>
		return r;
	close(newfdnum);
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	56                   	push   %esi
  800ffd:	e8 84 ff ff ff       	call   800f86 <close>

	newfd = INDEX2FD(newfdnum);
  801002:	89 f3                	mov    %esi,%ebx
  801004:	c1 e3 0c             	shl    $0xc,%ebx
  801007:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80100d:	83 c4 04             	add    $0x4,%esp
  801010:	ff 75 e4             	pushl  -0x1c(%ebp)
  801013:	e8 de fd ff ff       	call   800df6 <fd2data>
  801018:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80101a:	89 1c 24             	mov    %ebx,(%esp)
  80101d:	e8 d4 fd ff ff       	call   800df6 <fd2data>
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801028:	89 f8                	mov    %edi,%eax
  80102a:	c1 e8 16             	shr    $0x16,%eax
  80102d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801034:	a8 01                	test   $0x1,%al
  801036:	74 37                	je     80106f <dup+0x99>
  801038:	89 f8                	mov    %edi,%eax
  80103a:	c1 e8 0c             	shr    $0xc,%eax
  80103d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801044:	f6 c2 01             	test   $0x1,%dl
  801047:	74 26                	je     80106f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801049:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	25 07 0e 00 00       	and    $0xe07,%eax
  801058:	50                   	push   %eax
  801059:	ff 75 d4             	pushl  -0x2c(%ebp)
  80105c:	6a 00                	push   $0x0
  80105e:	57                   	push   %edi
  80105f:	6a 00                	push   $0x0
  801061:	e8 53 fb ff ff       	call   800bb9 <sys_page_map>
  801066:	89 c7                	mov    %eax,%edi
  801068:	83 c4 20             	add    $0x20,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	78 2e                	js     80109d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80106f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801072:	89 d0                	mov    %edx,%eax
  801074:	c1 e8 0c             	shr    $0xc,%eax
  801077:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107e:	83 ec 0c             	sub    $0xc,%esp
  801081:	25 07 0e 00 00       	and    $0xe07,%eax
  801086:	50                   	push   %eax
  801087:	53                   	push   %ebx
  801088:	6a 00                	push   $0x0
  80108a:	52                   	push   %edx
  80108b:	6a 00                	push   $0x0
  80108d:	e8 27 fb ff ff       	call   800bb9 <sys_page_map>
  801092:	89 c7                	mov    %eax,%edi
  801094:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801097:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801099:	85 ff                	test   %edi,%edi
  80109b:	79 1d                	jns    8010ba <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	53                   	push   %ebx
  8010a1:	6a 00                	push   $0x0
  8010a3:	e8 53 fb ff ff       	call   800bfb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010a8:	83 c4 08             	add    $0x8,%esp
  8010ab:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ae:	6a 00                	push   $0x0
  8010b0:	e8 46 fb ff ff       	call   800bfb <sys_page_unmap>
	return r;
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	89 f8                	mov    %edi,%eax
}
  8010ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010bd:	5b                   	pop    %ebx
  8010be:	5e                   	pop    %esi
  8010bf:	5f                   	pop    %edi
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	53                   	push   %ebx
  8010c6:	83 ec 14             	sub    $0x14,%esp
  8010c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010cf:	50                   	push   %eax
  8010d0:	53                   	push   %ebx
  8010d1:	e8 86 fd ff ff       	call   800e5c <fd_lookup>
  8010d6:	83 c4 08             	add    $0x8,%esp
  8010d9:	89 c2                	mov    %eax,%edx
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	78 6d                	js     80114c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010df:	83 ec 08             	sub    $0x8,%esp
  8010e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e5:	50                   	push   %eax
  8010e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e9:	ff 30                	pushl  (%eax)
  8010eb:	e8 c2 fd ff ff       	call   800eb2 <dev_lookup>
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	78 4c                	js     801143 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010fa:	8b 42 08             	mov    0x8(%edx),%eax
  8010fd:	83 e0 03             	and    $0x3,%eax
  801100:	83 f8 01             	cmp    $0x1,%eax
  801103:	75 21                	jne    801126 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801105:	a1 04 40 80 00       	mov    0x804004,%eax
  80110a:	8b 40 48             	mov    0x48(%eax),%eax
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	53                   	push   %ebx
  801111:	50                   	push   %eax
  801112:	68 18 23 80 00       	push   $0x802318
  801117:	e8 d2 f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801124:	eb 26                	jmp    80114c <read+0x8a>
	}
	if (!dev->dev_read)
  801126:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801129:	8b 40 08             	mov    0x8(%eax),%eax
  80112c:	85 c0                	test   %eax,%eax
  80112e:	74 17                	je     801147 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801130:	83 ec 04             	sub    $0x4,%esp
  801133:	ff 75 10             	pushl  0x10(%ebp)
  801136:	ff 75 0c             	pushl  0xc(%ebp)
  801139:	52                   	push   %edx
  80113a:	ff d0                	call   *%eax
  80113c:	89 c2                	mov    %eax,%edx
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	eb 09                	jmp    80114c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801143:	89 c2                	mov    %eax,%edx
  801145:	eb 05                	jmp    80114c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801147:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80114c:	89 d0                	mov    %edx,%eax
  80114e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80115f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801162:	bb 00 00 00 00       	mov    $0x0,%ebx
  801167:	eb 21                	jmp    80118a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801169:	83 ec 04             	sub    $0x4,%esp
  80116c:	89 f0                	mov    %esi,%eax
  80116e:	29 d8                	sub    %ebx,%eax
  801170:	50                   	push   %eax
  801171:	89 d8                	mov    %ebx,%eax
  801173:	03 45 0c             	add    0xc(%ebp),%eax
  801176:	50                   	push   %eax
  801177:	57                   	push   %edi
  801178:	e8 45 ff ff ff       	call   8010c2 <read>
		if (m < 0)
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	85 c0                	test   %eax,%eax
  801182:	78 10                	js     801194 <readn+0x41>
			return m;
		if (m == 0)
  801184:	85 c0                	test   %eax,%eax
  801186:	74 0a                	je     801192 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801188:	01 c3                	add    %eax,%ebx
  80118a:	39 f3                	cmp    %esi,%ebx
  80118c:	72 db                	jb     801169 <readn+0x16>
  80118e:	89 d8                	mov    %ebx,%eax
  801190:	eb 02                	jmp    801194 <readn+0x41>
  801192:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	53                   	push   %ebx
  8011a0:	83 ec 14             	sub    $0x14,%esp
  8011a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a9:	50                   	push   %eax
  8011aa:	53                   	push   %ebx
  8011ab:	e8 ac fc ff ff       	call   800e5c <fd_lookup>
  8011b0:	83 c4 08             	add    $0x8,%esp
  8011b3:	89 c2                	mov    %eax,%edx
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	78 68                	js     801221 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b9:	83 ec 08             	sub    $0x8,%esp
  8011bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011bf:	50                   	push   %eax
  8011c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c3:	ff 30                	pushl  (%eax)
  8011c5:	e8 e8 fc ff ff       	call   800eb2 <dev_lookup>
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 47                	js     801218 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d8:	75 21                	jne    8011fb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011da:	a1 04 40 80 00       	mov    0x804004,%eax
  8011df:	8b 40 48             	mov    0x48(%eax),%eax
  8011e2:	83 ec 04             	sub    $0x4,%esp
  8011e5:	53                   	push   %ebx
  8011e6:	50                   	push   %eax
  8011e7:	68 34 23 80 00       	push   $0x802334
  8011ec:	e8 fd ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f9:	eb 26                	jmp    801221 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011fe:	8b 52 0c             	mov    0xc(%edx),%edx
  801201:	85 d2                	test   %edx,%edx
  801203:	74 17                	je     80121c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	ff 75 10             	pushl  0x10(%ebp)
  80120b:	ff 75 0c             	pushl  0xc(%ebp)
  80120e:	50                   	push   %eax
  80120f:	ff d2                	call   *%edx
  801211:	89 c2                	mov    %eax,%edx
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	eb 09                	jmp    801221 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801218:	89 c2                	mov    %eax,%edx
  80121a:	eb 05                	jmp    801221 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80121c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801221:	89 d0                	mov    %edx,%eax
  801223:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <seek>:

int
seek(int fdnum, off_t offset)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801231:	50                   	push   %eax
  801232:	ff 75 08             	pushl  0x8(%ebp)
  801235:	e8 22 fc ff ff       	call   800e5c <fd_lookup>
  80123a:	83 c4 08             	add    $0x8,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	78 0e                	js     80124f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801241:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801244:	8b 55 0c             	mov    0xc(%ebp),%edx
  801247:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80124a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80124f:	c9                   	leave  
  801250:	c3                   	ret    

00801251 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	53                   	push   %ebx
  801255:	83 ec 14             	sub    $0x14,%esp
  801258:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125e:	50                   	push   %eax
  80125f:	53                   	push   %ebx
  801260:	e8 f7 fb ff ff       	call   800e5c <fd_lookup>
  801265:	83 c4 08             	add    $0x8,%esp
  801268:	89 c2                	mov    %eax,%edx
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 65                	js     8012d3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801278:	ff 30                	pushl  (%eax)
  80127a:	e8 33 fc ff ff       	call   800eb2 <dev_lookup>
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	78 44                	js     8012ca <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80128d:	75 21                	jne    8012b0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80128f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801294:	8b 40 48             	mov    0x48(%eax),%eax
  801297:	83 ec 04             	sub    $0x4,%esp
  80129a:	53                   	push   %ebx
  80129b:	50                   	push   %eax
  80129c:	68 f4 22 80 00       	push   $0x8022f4
  8012a1:	e8 48 ef ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ae:	eb 23                	jmp    8012d3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b3:	8b 52 18             	mov    0x18(%edx),%edx
  8012b6:	85 d2                	test   %edx,%edx
  8012b8:	74 14                	je     8012ce <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	ff 75 0c             	pushl  0xc(%ebp)
  8012c0:	50                   	push   %eax
  8012c1:	ff d2                	call   *%edx
  8012c3:	89 c2                	mov    %eax,%edx
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	eb 09                	jmp    8012d3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ca:	89 c2                	mov    %eax,%edx
  8012cc:	eb 05                	jmp    8012d3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012d3:	89 d0                	mov    %edx,%eax
  8012d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d8:	c9                   	leave  
  8012d9:	c3                   	ret    

008012da <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 14             	sub    $0x14,%esp
  8012e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e7:	50                   	push   %eax
  8012e8:	ff 75 08             	pushl  0x8(%ebp)
  8012eb:	e8 6c fb ff ff       	call   800e5c <fd_lookup>
  8012f0:	83 c4 08             	add    $0x8,%esp
  8012f3:	89 c2                	mov    %eax,%edx
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 58                	js     801351 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ff:	50                   	push   %eax
  801300:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801303:	ff 30                	pushl  (%eax)
  801305:	e8 a8 fb ff ff       	call   800eb2 <dev_lookup>
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 37                	js     801348 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801311:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801314:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801318:	74 32                	je     80134c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80131a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80131d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801324:	00 00 00 
	stat->st_isdir = 0;
  801327:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80132e:	00 00 00 
	stat->st_dev = dev;
  801331:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	53                   	push   %ebx
  80133b:	ff 75 f0             	pushl  -0x10(%ebp)
  80133e:	ff 50 14             	call   *0x14(%eax)
  801341:	89 c2                	mov    %eax,%edx
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	eb 09                	jmp    801351 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801348:	89 c2                	mov    %eax,%edx
  80134a:	eb 05                	jmp    801351 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80134c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801351:	89 d0                	mov    %edx,%eax
  801353:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	56                   	push   %esi
  80135c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	6a 00                	push   $0x0
  801362:	ff 75 08             	pushl  0x8(%ebp)
  801365:	e8 2c 02 00 00       	call   801596 <open>
  80136a:	89 c3                	mov    %eax,%ebx
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 1b                	js     80138e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	ff 75 0c             	pushl  0xc(%ebp)
  801379:	50                   	push   %eax
  80137a:	e8 5b ff ff ff       	call   8012da <fstat>
  80137f:	89 c6                	mov    %eax,%esi
	close(fd);
  801381:	89 1c 24             	mov    %ebx,(%esp)
  801384:	e8 fd fb ff ff       	call   800f86 <close>
	return r;
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	89 f0                	mov    %esi,%eax
}
  80138e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801391:	5b                   	pop    %ebx
  801392:	5e                   	pop    %esi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	56                   	push   %esi
  801399:	53                   	push   %ebx
  80139a:	89 c6                	mov    %eax,%esi
  80139c:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  80139e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013a5:	75 12                	jne    8013b9 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  8013a7:	83 ec 0c             	sub    $0xc,%esp
  8013aa:	6a 01                	push   $0x1
  8013ac:	e8 1b 08 00 00       	call   801bcc <ipc_find_env>
  8013b1:	a3 00 40 80 00       	mov    %eax,0x804000
  8013b6:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b9:	6a 07                	push   $0x7
  8013bb:	68 00 50 80 00       	push   $0x805000
  8013c0:	56                   	push   %esi
  8013c1:	ff 35 00 40 80 00    	pushl  0x804000
  8013c7:	e8 ac 07 00 00       	call   801b78 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  8013cc:	83 c4 0c             	add    $0xc,%esp
  8013cf:	6a 00                	push   $0x0
  8013d1:	53                   	push   %ebx
  8013d2:	6a 00                	push   $0x0
  8013d4:	e8 40 07 00 00       	call   801b19 <ipc_recv>
}
  8013d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5e                   	pop    %esi
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ec:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  8013f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f4:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  8013f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fe:	b8 02 00 00 00       	mov    $0x2,%eax
  801403:	e8 8d ff ff ff       	call   801395 <fsipc>
}
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	8b 40 0c             	mov    0xc(%eax),%eax
  801416:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  80141b:	ba 00 00 00 00       	mov    $0x0,%edx
  801420:	b8 06 00 00 00       	mov    $0x6,%eax
  801425:	e8 6b ff ff ff       	call   801395 <fsipc>
}
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	53                   	push   %ebx
  801430:	83 ec 04             	sub    $0x4,%esp
  801433:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801436:	8b 45 08             	mov    0x8(%ebp),%eax
  801439:	8b 40 0c             	mov    0xc(%eax),%eax
  80143c:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	b8 05 00 00 00       	mov    $0x5,%eax
  80144b:	e8 45 ff ff ff       	call   801395 <fsipc>
  801450:	85 c0                	test   %eax,%eax
  801452:	78 2c                	js     801480 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801454:	83 ec 08             	sub    $0x8,%esp
  801457:	68 00 50 80 00       	push   $0x805000
  80145c:	53                   	push   %ebx
  80145d:	e8 11 f3 ff ff       	call   800773 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  801462:	a1 80 50 80 00       	mov    0x805080,%eax
  801467:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80146d:	a1 84 50 80 00       	mov    0x805084,%eax
  801472:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801480:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801483:	c9                   	leave  
  801484:	c3                   	ret    

00801485 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	53                   	push   %ebx
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	8b 40 0c             	mov    0xc(%eax),%eax
  801495:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  80149a:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  8014a0:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8014a6:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8014ab:	0f 46 c3             	cmovbe %ebx,%eax
  8014ae:	50                   	push   %eax
  8014af:	ff 75 0c             	pushl  0xc(%ebp)
  8014b2:	68 08 50 80 00       	push   $0x805008
  8014b7:	e8 49 f4 ff ff       	call   800905 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  8014bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c1:	b8 04 00 00 00       	mov    $0x4,%eax
  8014c6:	e8 ca fe ff ff       	call   801395 <fsipc>
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 3d                	js     80150f <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  8014d2:	39 c3                	cmp    %eax,%ebx
  8014d4:	73 19                	jae    8014ef <devfile_write+0x6a>
  8014d6:	68 64 23 80 00       	push   $0x802364
  8014db:	68 6b 23 80 00       	push   $0x80236b
  8014e0:	68 9a 00 00 00       	push   $0x9a
  8014e5:	68 80 23 80 00       	push   $0x802380
  8014ea:	e8 26 ec ff ff       	call   800115 <_panic>
	   assert (r <= bytes_written);
  8014ef:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014f4:	7e 19                	jle    80150f <devfile_write+0x8a>
  8014f6:	68 8b 23 80 00       	push   $0x80238b
  8014fb:	68 6b 23 80 00       	push   $0x80236b
  801500:	68 9b 00 00 00       	push   $0x9b
  801505:	68 80 23 80 00       	push   $0x802380
  80150a:	e8 06 ec ff ff       	call   800115 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  80150f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	56                   	push   %esi
  801518:	53                   	push   %ebx
  801519:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  80151c:	8b 45 08             	mov    0x8(%ebp),%eax
  80151f:	8b 40 0c             	mov    0xc(%eax),%eax
  801522:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  801527:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80152d:	ba 00 00 00 00       	mov    $0x0,%edx
  801532:	b8 03 00 00 00       	mov    $0x3,%eax
  801537:	e8 59 fe ff ff       	call   801395 <fsipc>
  80153c:	89 c3                	mov    %eax,%ebx
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 4b                	js     80158d <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  801542:	39 c6                	cmp    %eax,%esi
  801544:	73 16                	jae    80155c <devfile_read+0x48>
  801546:	68 64 23 80 00       	push   $0x802364
  80154b:	68 6b 23 80 00       	push   $0x80236b
  801550:	6a 7c                	push   $0x7c
  801552:	68 80 23 80 00       	push   $0x802380
  801557:	e8 b9 eb ff ff       	call   800115 <_panic>
	   assert(r <= PGSIZE);
  80155c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801561:	7e 16                	jle    801579 <devfile_read+0x65>
  801563:	68 9e 23 80 00       	push   $0x80239e
  801568:	68 6b 23 80 00       	push   $0x80236b
  80156d:	6a 7d                	push   $0x7d
  80156f:	68 80 23 80 00       	push   $0x802380
  801574:	e8 9c eb ff ff       	call   800115 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801579:	83 ec 04             	sub    $0x4,%esp
  80157c:	50                   	push   %eax
  80157d:	68 00 50 80 00       	push   $0x805000
  801582:	ff 75 0c             	pushl  0xc(%ebp)
  801585:	e8 7b f3 ff ff       	call   800905 <memmove>
	   return r;
  80158a:	83 c4 10             	add    $0x10,%esp
}
  80158d:	89 d8                	mov    %ebx,%eax
  80158f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801592:	5b                   	pop    %ebx
  801593:	5e                   	pop    %esi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    

00801596 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	53                   	push   %ebx
  80159a:	83 ec 20             	sub    $0x20,%esp
  80159d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  8015a0:	53                   	push   %ebx
  8015a1:	e8 94 f1 ff ff       	call   80073a <strlen>
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ae:	7f 67                	jg     801617 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8015b0:	83 ec 0c             	sub    $0xc,%esp
  8015b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	e8 51 f8 ff ff       	call   800e0d <fd_alloc>
  8015bc:	83 c4 10             	add    $0x10,%esp
			 return r;
  8015bf:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 57                	js     80161c <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	53                   	push   %ebx
  8015c9:	68 00 50 80 00       	push   $0x805000
  8015ce:	e8 a0 f1 ff ff       	call   800773 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  8015d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d6:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015de:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e3:	e8 ad fd ff ff       	call   801395 <fsipc>
  8015e8:	89 c3                	mov    %eax,%ebx
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	79 14                	jns    801605 <open+0x6f>
			 fd_close(fd, 0);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	6a 00                	push   $0x0
  8015f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f9:	e8 07 f9 ff ff       	call   800f05 <fd_close>
			 return r;
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	89 da                	mov    %ebx,%edx
  801603:	eb 17                	jmp    80161c <open+0x86>
	   }

	   return fd2num(fd);
  801605:	83 ec 0c             	sub    $0xc,%esp
  801608:	ff 75 f4             	pushl  -0xc(%ebp)
  80160b:	e8 d6 f7 ff ff       	call   800de6 <fd2num>
  801610:	89 c2                	mov    %eax,%edx
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	eb 05                	jmp    80161c <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  801617:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  80161c:	89 d0                	mov    %edx,%eax
  80161e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801629:	ba 00 00 00 00       	mov    $0x0,%edx
  80162e:	b8 08 00 00 00       	mov    $0x8,%eax
  801633:	e8 5d fd ff ff       	call   801395 <fsipc>
}
  801638:	c9                   	leave  
  801639:	c3                   	ret    

0080163a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	56                   	push   %esi
  80163e:	53                   	push   %ebx
  80163f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	ff 75 08             	pushl  0x8(%ebp)
  801648:	e8 a9 f7 ff ff       	call   800df6 <fd2data>
  80164d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80164f:	83 c4 08             	add    $0x8,%esp
  801652:	68 aa 23 80 00       	push   $0x8023aa
  801657:	53                   	push   %ebx
  801658:	e8 16 f1 ff ff       	call   800773 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80165d:	8b 46 04             	mov    0x4(%esi),%eax
  801660:	2b 06                	sub    (%esi),%eax
  801662:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801668:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80166f:	00 00 00 
	stat->st_dev = &devpipe;
  801672:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801679:	30 80 00 
	return 0;
}
  80167c:	b8 00 00 00 00       	mov    $0x0,%eax
  801681:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801684:	5b                   	pop    %ebx
  801685:	5e                   	pop    %esi
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    

00801688 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	53                   	push   %ebx
  80168c:	83 ec 0c             	sub    $0xc,%esp
  80168f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801692:	53                   	push   %ebx
  801693:	6a 00                	push   $0x0
  801695:	e8 61 f5 ff ff       	call   800bfb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80169a:	89 1c 24             	mov    %ebx,(%esp)
  80169d:	e8 54 f7 ff ff       	call   800df6 <fd2data>
  8016a2:	83 c4 08             	add    $0x8,%esp
  8016a5:	50                   	push   %eax
  8016a6:	6a 00                	push   $0x0
  8016a8:	e8 4e f5 ff ff       	call   800bfb <sys_page_unmap>
}
  8016ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	57                   	push   %edi
  8016b6:	56                   	push   %esi
  8016b7:	53                   	push   %ebx
  8016b8:	83 ec 1c             	sub    $0x1c,%esp
  8016bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016be:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016c8:	83 ec 0c             	sub    $0xc,%esp
  8016cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ce:	e8 32 05 00 00       	call   801c05 <pageref>
  8016d3:	89 c3                	mov    %eax,%ebx
  8016d5:	89 3c 24             	mov    %edi,(%esp)
  8016d8:	e8 28 05 00 00       	call   801c05 <pageref>
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	39 c3                	cmp    %eax,%ebx
  8016e2:	0f 94 c1             	sete   %cl
  8016e5:	0f b6 c9             	movzbl %cl,%ecx
  8016e8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016eb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016f1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016f4:	39 ce                	cmp    %ecx,%esi
  8016f6:	74 1b                	je     801713 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016f8:	39 c3                	cmp    %eax,%ebx
  8016fa:	75 c4                	jne    8016c0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016fc:	8b 42 58             	mov    0x58(%edx),%eax
  8016ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801702:	50                   	push   %eax
  801703:	56                   	push   %esi
  801704:	68 b1 23 80 00       	push   $0x8023b1
  801709:	e8 e0 ea ff ff       	call   8001ee <cprintf>
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	eb ad                	jmp    8016c0 <_pipeisclosed+0xe>
	}
}
  801713:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801716:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801719:	5b                   	pop    %ebx
  80171a:	5e                   	pop    %esi
  80171b:	5f                   	pop    %edi
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	57                   	push   %edi
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	83 ec 28             	sub    $0x28,%esp
  801727:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80172a:	56                   	push   %esi
  80172b:	e8 c6 f6 ff ff       	call   800df6 <fd2data>
  801730:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	bf 00 00 00 00       	mov    $0x0,%edi
  80173a:	eb 4b                	jmp    801787 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80173c:	89 da                	mov    %ebx,%edx
  80173e:	89 f0                	mov    %esi,%eax
  801740:	e8 6d ff ff ff       	call   8016b2 <_pipeisclosed>
  801745:	85 c0                	test   %eax,%eax
  801747:	75 48                	jne    801791 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801749:	e8 09 f4 ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80174e:	8b 43 04             	mov    0x4(%ebx),%eax
  801751:	8b 0b                	mov    (%ebx),%ecx
  801753:	8d 51 20             	lea    0x20(%ecx),%edx
  801756:	39 d0                	cmp    %edx,%eax
  801758:	73 e2                	jae    80173c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80175a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801761:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801764:	89 c2                	mov    %eax,%edx
  801766:	c1 fa 1f             	sar    $0x1f,%edx
  801769:	89 d1                	mov    %edx,%ecx
  80176b:	c1 e9 1b             	shr    $0x1b,%ecx
  80176e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801771:	83 e2 1f             	and    $0x1f,%edx
  801774:	29 ca                	sub    %ecx,%edx
  801776:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80177a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80177e:	83 c0 01             	add    $0x1,%eax
  801781:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801784:	83 c7 01             	add    $0x1,%edi
  801787:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80178a:	75 c2                	jne    80174e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80178c:	8b 45 10             	mov    0x10(%ebp),%eax
  80178f:	eb 05                	jmp    801796 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801791:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801796:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801799:	5b                   	pop    %ebx
  80179a:	5e                   	pop    %esi
  80179b:	5f                   	pop    %edi
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    

0080179e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	57                   	push   %edi
  8017a2:	56                   	push   %esi
  8017a3:	53                   	push   %ebx
  8017a4:	83 ec 18             	sub    $0x18,%esp
  8017a7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017aa:	57                   	push   %edi
  8017ab:	e8 46 f6 ff ff       	call   800df6 <fd2data>
  8017b0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ba:	eb 3d                	jmp    8017f9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017bc:	85 db                	test   %ebx,%ebx
  8017be:	74 04                	je     8017c4 <devpipe_read+0x26>
				return i;
  8017c0:	89 d8                	mov    %ebx,%eax
  8017c2:	eb 44                	jmp    801808 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017c4:	89 f2                	mov    %esi,%edx
  8017c6:	89 f8                	mov    %edi,%eax
  8017c8:	e8 e5 fe ff ff       	call   8016b2 <_pipeisclosed>
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	75 32                	jne    801803 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017d1:	e8 81 f3 ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017d6:	8b 06                	mov    (%esi),%eax
  8017d8:	3b 46 04             	cmp    0x4(%esi),%eax
  8017db:	74 df                	je     8017bc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017dd:	99                   	cltd   
  8017de:	c1 ea 1b             	shr    $0x1b,%edx
  8017e1:	01 d0                	add    %edx,%eax
  8017e3:	83 e0 1f             	and    $0x1f,%eax
  8017e6:	29 d0                	sub    %edx,%eax
  8017e8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017f3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f6:	83 c3 01             	add    $0x1,%ebx
  8017f9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017fc:	75 d8                	jne    8017d6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017fe:	8b 45 10             	mov    0x10(%ebp),%eax
  801801:	eb 05                	jmp    801808 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801803:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801808:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80180b:	5b                   	pop    %ebx
  80180c:	5e                   	pop    %esi
  80180d:	5f                   	pop    %edi
  80180e:	5d                   	pop    %ebp
  80180f:	c3                   	ret    

00801810 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	56                   	push   %esi
  801814:	53                   	push   %ebx
  801815:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801818:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181b:	50                   	push   %eax
  80181c:	e8 ec f5 ff ff       	call   800e0d <fd_alloc>
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	89 c2                	mov    %eax,%edx
  801826:	85 c0                	test   %eax,%eax
  801828:	0f 88 2c 01 00 00    	js     80195a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182e:	83 ec 04             	sub    $0x4,%esp
  801831:	68 07 04 00 00       	push   $0x407
  801836:	ff 75 f4             	pushl  -0xc(%ebp)
  801839:	6a 00                	push   $0x0
  80183b:	e8 36 f3 ff ff       	call   800b76 <sys_page_alloc>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	89 c2                	mov    %eax,%edx
  801845:	85 c0                	test   %eax,%eax
  801847:	0f 88 0d 01 00 00    	js     80195a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80184d:	83 ec 0c             	sub    $0xc,%esp
  801850:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801853:	50                   	push   %eax
  801854:	e8 b4 f5 ff ff       	call   800e0d <fd_alloc>
  801859:	89 c3                	mov    %eax,%ebx
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	85 c0                	test   %eax,%eax
  801860:	0f 88 e2 00 00 00    	js     801948 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801866:	83 ec 04             	sub    $0x4,%esp
  801869:	68 07 04 00 00       	push   $0x407
  80186e:	ff 75 f0             	pushl  -0x10(%ebp)
  801871:	6a 00                	push   $0x0
  801873:	e8 fe f2 ff ff       	call   800b76 <sys_page_alloc>
  801878:	89 c3                	mov    %eax,%ebx
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	85 c0                	test   %eax,%eax
  80187f:	0f 88 c3 00 00 00    	js     801948 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801885:	83 ec 0c             	sub    $0xc,%esp
  801888:	ff 75 f4             	pushl  -0xc(%ebp)
  80188b:	e8 66 f5 ff ff       	call   800df6 <fd2data>
  801890:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801892:	83 c4 0c             	add    $0xc,%esp
  801895:	68 07 04 00 00       	push   $0x407
  80189a:	50                   	push   %eax
  80189b:	6a 00                	push   $0x0
  80189d:	e8 d4 f2 ff ff       	call   800b76 <sys_page_alloc>
  8018a2:	89 c3                	mov    %eax,%ebx
  8018a4:	83 c4 10             	add    $0x10,%esp
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	0f 88 89 00 00 00    	js     801938 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018af:	83 ec 0c             	sub    $0xc,%esp
  8018b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b5:	e8 3c f5 ff ff       	call   800df6 <fd2data>
  8018ba:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018c1:	50                   	push   %eax
  8018c2:	6a 00                	push   $0x0
  8018c4:	56                   	push   %esi
  8018c5:	6a 00                	push   $0x0
  8018c7:	e8 ed f2 ff ff       	call   800bb9 <sys_page_map>
  8018cc:	89 c3                	mov    %eax,%ebx
  8018ce:	83 c4 20             	add    $0x20,%esp
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	78 55                	js     80192a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018d5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018de:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018ea:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018ff:	83 ec 0c             	sub    $0xc,%esp
  801902:	ff 75 f4             	pushl  -0xc(%ebp)
  801905:	e8 dc f4 ff ff       	call   800de6 <fd2num>
  80190a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80190d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80190f:	83 c4 04             	add    $0x4,%esp
  801912:	ff 75 f0             	pushl  -0x10(%ebp)
  801915:	e8 cc f4 ff ff       	call   800de6 <fd2num>
  80191a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80191d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	ba 00 00 00 00       	mov    $0x0,%edx
  801928:	eb 30                	jmp    80195a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	56                   	push   %esi
  80192e:	6a 00                	push   $0x0
  801930:	e8 c6 f2 ff ff       	call   800bfb <sys_page_unmap>
  801935:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801938:	83 ec 08             	sub    $0x8,%esp
  80193b:	ff 75 f0             	pushl  -0x10(%ebp)
  80193e:	6a 00                	push   $0x0
  801940:	e8 b6 f2 ff ff       	call   800bfb <sys_page_unmap>
  801945:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801948:	83 ec 08             	sub    $0x8,%esp
  80194b:	ff 75 f4             	pushl  -0xc(%ebp)
  80194e:	6a 00                	push   $0x0
  801950:	e8 a6 f2 ff ff       	call   800bfb <sys_page_unmap>
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80195a:	89 d0                	mov    %edx,%eax
  80195c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195f:	5b                   	pop    %ebx
  801960:	5e                   	pop    %esi
  801961:	5d                   	pop    %ebp
  801962:	c3                   	ret    

00801963 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801969:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196c:	50                   	push   %eax
  80196d:	ff 75 08             	pushl  0x8(%ebp)
  801970:	e8 e7 f4 ff ff       	call   800e5c <fd_lookup>
  801975:	83 c4 10             	add    $0x10,%esp
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 18                	js     801994 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80197c:	83 ec 0c             	sub    $0xc,%esp
  80197f:	ff 75 f4             	pushl  -0xc(%ebp)
  801982:	e8 6f f4 ff ff       	call   800df6 <fd2data>
	return _pipeisclosed(fd, p);
  801987:	89 c2                	mov    %eax,%edx
  801989:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198c:	e8 21 fd ff ff       	call   8016b2 <_pipeisclosed>
  801991:	83 c4 10             	add    $0x10,%esp
}
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801999:	b8 00 00 00 00       	mov    $0x0,%eax
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    

008019a0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019a6:	68 c9 23 80 00       	push   $0x8023c9
  8019ab:	ff 75 0c             	pushl  0xc(%ebp)
  8019ae:	e8 c0 ed ff ff       	call   800773 <strcpy>
	return 0;
}
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	57                   	push   %edi
  8019be:	56                   	push   %esi
  8019bf:	53                   	push   %ebx
  8019c0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019cb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d1:	eb 2d                	jmp    801a00 <devcons_write+0x46>
		m = n - tot;
  8019d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019d6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019d8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019db:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019e0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019e3:	83 ec 04             	sub    $0x4,%esp
  8019e6:	53                   	push   %ebx
  8019e7:	03 45 0c             	add    0xc(%ebp),%eax
  8019ea:	50                   	push   %eax
  8019eb:	57                   	push   %edi
  8019ec:	e8 14 ef ff ff       	call   800905 <memmove>
		sys_cputs(buf, m);
  8019f1:	83 c4 08             	add    $0x8,%esp
  8019f4:	53                   	push   %ebx
  8019f5:	57                   	push   %edi
  8019f6:	e8 bf f0 ff ff       	call   800aba <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019fb:	01 de                	add    %ebx,%esi
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	89 f0                	mov    %esi,%eax
  801a02:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a05:	72 cc                	jb     8019d3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0a:	5b                   	pop    %ebx
  801a0b:	5e                   	pop    %esi
  801a0c:	5f                   	pop    %edi
  801a0d:	5d                   	pop    %ebp
  801a0e:	c3                   	ret    

00801a0f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	83 ec 08             	sub    $0x8,%esp
  801a15:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a1a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a1e:	74 2a                	je     801a4a <devcons_read+0x3b>
  801a20:	eb 05                	jmp    801a27 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a22:	e8 30 f1 ff ff       	call   800b57 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a27:	e8 ac f0 ff ff       	call   800ad8 <sys_cgetc>
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	74 f2                	je     801a22 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a30:	85 c0                	test   %eax,%eax
  801a32:	78 16                	js     801a4a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a34:	83 f8 04             	cmp    $0x4,%eax
  801a37:	74 0c                	je     801a45 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a39:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a3c:	88 02                	mov    %al,(%edx)
	return 1;
  801a3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801a43:	eb 05                	jmp    801a4a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a45:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a52:	8b 45 08             	mov    0x8(%ebp),%eax
  801a55:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a58:	6a 01                	push   $0x1
  801a5a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a5d:	50                   	push   %eax
  801a5e:	e8 57 f0 ff ff       	call   800aba <sys_cputs>
}
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	c9                   	leave  
  801a67:	c3                   	ret    

00801a68 <getchar>:

int
getchar(void)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a6e:	6a 01                	push   $0x1
  801a70:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a73:	50                   	push   %eax
  801a74:	6a 00                	push   $0x0
  801a76:	e8 47 f6 ff ff       	call   8010c2 <read>
	if (r < 0)
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	78 0f                	js     801a91 <getchar+0x29>
		return r;
	if (r < 1)
  801a82:	85 c0                	test   %eax,%eax
  801a84:	7e 06                	jle    801a8c <getchar+0x24>
		return -E_EOF;
	return c;
  801a86:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a8a:	eb 05                	jmp    801a91 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a8c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9c:	50                   	push   %eax
  801a9d:	ff 75 08             	pushl  0x8(%ebp)
  801aa0:	e8 b7 f3 ff ff       	call   800e5c <fd_lookup>
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	78 11                	js     801abd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aaf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab5:	39 10                	cmp    %edx,(%eax)
  801ab7:	0f 94 c0             	sete   %al
  801aba:	0f b6 c0             	movzbl %al,%eax
}
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <opencons>:

int
opencons(void)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ac5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac8:	50                   	push   %eax
  801ac9:	e8 3f f3 ff ff       	call   800e0d <fd_alloc>
  801ace:	83 c4 10             	add    $0x10,%esp
		return r;
  801ad1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	78 3e                	js     801b15 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ad7:	83 ec 04             	sub    $0x4,%esp
  801ada:	68 07 04 00 00       	push   $0x407
  801adf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae2:	6a 00                	push   $0x0
  801ae4:	e8 8d f0 ff ff       	call   800b76 <sys_page_alloc>
  801ae9:	83 c4 10             	add    $0x10,%esp
		return r;
  801aec:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801aee:	85 c0                	test   %eax,%eax
  801af0:	78 23                	js     801b15 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801af2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b00:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b07:	83 ec 0c             	sub    $0xc,%esp
  801b0a:	50                   	push   %eax
  801b0b:	e8 d6 f2 ff ff       	call   800de6 <fd2num>
  801b10:	89 c2                	mov    %eax,%edx
  801b12:	83 c4 10             	add    $0x10,%esp
}
  801b15:	89 d0                	mov    %edx,%eax
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	56                   	push   %esi
  801b1d:	53                   	push   %ebx
  801b1e:	8b 75 08             	mov    0x8(%ebp),%esi
  801b21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801b27:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801b29:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801b2e:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801b31:	83 ec 0c             	sub    $0xc,%esp
  801b34:	50                   	push   %eax
  801b35:	e8 ec f1 ff ff       	call   800d26 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801b3a:	83 c4 10             	add    $0x10,%esp
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	78 0e                	js     801b4f <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801b41:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b47:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801b4a:	8b 52 78             	mov    0x78(%edx),%edx
  801b4d:	eb 0a                	jmp    801b59 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801b4f:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801b54:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801b59:	85 f6                	test   %esi,%esi
  801b5b:	74 02                	je     801b5f <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801b5d:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801b5f:	85 db                	test   %ebx,%ebx
  801b61:	74 02                	je     801b65 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801b63:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801b65:	85 c0                	test   %eax,%eax
  801b67:	78 08                	js     801b71 <ipc_recv+0x58>
  801b69:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6e:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801b71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b74:	5b                   	pop    %ebx
  801b75:	5e                   	pop    %esi
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	57                   	push   %edi
  801b7c:	56                   	push   %esi
  801b7d:	53                   	push   %ebx
  801b7e:	83 ec 0c             	sub    $0xc,%esp
  801b81:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b84:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801b8a:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801b8c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801b91:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801b94:	ff 75 14             	pushl  0x14(%ebp)
  801b97:	53                   	push   %ebx
  801b98:	56                   	push   %esi
  801b99:	57                   	push   %edi
  801b9a:	e8 64 f1 ff ff       	call   800d03 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801b9f:	83 c4 10             	add    $0x10,%esp
  801ba2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ba5:	75 07                	jne    801bae <ipc_send+0x36>
				    sys_yield();
  801ba7:	e8 ab ef ff ff       	call   800b57 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801bac:	eb e6                	jmp    801b94 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	74 12                	je     801bc4 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801bb2:	50                   	push   %eax
  801bb3:	68 d5 23 80 00       	push   $0x8023d5
  801bb8:	6a 4b                	push   $0x4b
  801bba:	68 e9 23 80 00       	push   $0x8023e9
  801bbf:	e8 51 e5 ff ff       	call   800115 <_panic>
			 }
	   }
}
  801bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc7:	5b                   	pop    %ebx
  801bc8:	5e                   	pop    %esi
  801bc9:	5f                   	pop    %edi
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    

00801bcc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801bd2:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801bd7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bda:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801be0:	8b 52 50             	mov    0x50(%edx),%edx
  801be3:	39 ca                	cmp    %ecx,%edx
  801be5:	75 0d                	jne    801bf4 <ipc_find_env+0x28>
				    return envs[i].env_id;
  801be7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bef:	8b 40 48             	mov    0x48(%eax),%eax
  801bf2:	eb 0f                	jmp    801c03 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801bf4:	83 c0 01             	add    $0x1,%eax
  801bf7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bfc:	75 d9                	jne    801bd7 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801bfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c0b:	89 d0                	mov    %edx,%eax
  801c0d:	c1 e8 16             	shr    $0x16,%eax
  801c10:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c17:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c1c:	f6 c1 01             	test   $0x1,%cl
  801c1f:	74 1d                	je     801c3e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c21:	c1 ea 0c             	shr    $0xc,%edx
  801c24:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c2b:	f6 c2 01             	test   $0x1,%dl
  801c2e:	74 0e                	je     801c3e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c30:	c1 ea 0c             	shr    $0xc,%edx
  801c33:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c3a:	ef 
  801c3b:	0f b7 c0             	movzwl %ax,%eax
}
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <__udivdi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 1c             	sub    $0x1c,%esp
  801c47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c57:	85 f6                	test   %esi,%esi
  801c59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c5d:	89 ca                	mov    %ecx,%edx
  801c5f:	89 f8                	mov    %edi,%eax
  801c61:	75 3d                	jne    801ca0 <__udivdi3+0x60>
  801c63:	39 cf                	cmp    %ecx,%edi
  801c65:	0f 87 c5 00 00 00    	ja     801d30 <__udivdi3+0xf0>
  801c6b:	85 ff                	test   %edi,%edi
  801c6d:	89 fd                	mov    %edi,%ebp
  801c6f:	75 0b                	jne    801c7c <__udivdi3+0x3c>
  801c71:	b8 01 00 00 00       	mov    $0x1,%eax
  801c76:	31 d2                	xor    %edx,%edx
  801c78:	f7 f7                	div    %edi
  801c7a:	89 c5                	mov    %eax,%ebp
  801c7c:	89 c8                	mov    %ecx,%eax
  801c7e:	31 d2                	xor    %edx,%edx
  801c80:	f7 f5                	div    %ebp
  801c82:	89 c1                	mov    %eax,%ecx
  801c84:	89 d8                	mov    %ebx,%eax
  801c86:	89 cf                	mov    %ecx,%edi
  801c88:	f7 f5                	div    %ebp
  801c8a:	89 c3                	mov    %eax,%ebx
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	89 fa                	mov    %edi,%edx
  801c90:	83 c4 1c             	add    $0x1c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	90                   	nop
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	39 ce                	cmp    %ecx,%esi
  801ca2:	77 74                	ja     801d18 <__udivdi3+0xd8>
  801ca4:	0f bd fe             	bsr    %esi,%edi
  801ca7:	83 f7 1f             	xor    $0x1f,%edi
  801caa:	0f 84 98 00 00 00    	je     801d48 <__udivdi3+0x108>
  801cb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cb5:	89 f9                	mov    %edi,%ecx
  801cb7:	89 c5                	mov    %eax,%ebp
  801cb9:	29 fb                	sub    %edi,%ebx
  801cbb:	d3 e6                	shl    %cl,%esi
  801cbd:	89 d9                	mov    %ebx,%ecx
  801cbf:	d3 ed                	shr    %cl,%ebp
  801cc1:	89 f9                	mov    %edi,%ecx
  801cc3:	d3 e0                	shl    %cl,%eax
  801cc5:	09 ee                	or     %ebp,%esi
  801cc7:	89 d9                	mov    %ebx,%ecx
  801cc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ccd:	89 d5                	mov    %edx,%ebp
  801ccf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cd3:	d3 ed                	shr    %cl,%ebp
  801cd5:	89 f9                	mov    %edi,%ecx
  801cd7:	d3 e2                	shl    %cl,%edx
  801cd9:	89 d9                	mov    %ebx,%ecx
  801cdb:	d3 e8                	shr    %cl,%eax
  801cdd:	09 c2                	or     %eax,%edx
  801cdf:	89 d0                	mov    %edx,%eax
  801ce1:	89 ea                	mov    %ebp,%edx
  801ce3:	f7 f6                	div    %esi
  801ce5:	89 d5                	mov    %edx,%ebp
  801ce7:	89 c3                	mov    %eax,%ebx
  801ce9:	f7 64 24 0c          	mull   0xc(%esp)
  801ced:	39 d5                	cmp    %edx,%ebp
  801cef:	72 10                	jb     801d01 <__udivdi3+0xc1>
  801cf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	d3 e6                	shl    %cl,%esi
  801cf9:	39 c6                	cmp    %eax,%esi
  801cfb:	73 07                	jae    801d04 <__udivdi3+0xc4>
  801cfd:	39 d5                	cmp    %edx,%ebp
  801cff:	75 03                	jne    801d04 <__udivdi3+0xc4>
  801d01:	83 eb 01             	sub    $0x1,%ebx
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	89 d8                	mov    %ebx,%eax
  801d08:	89 fa                	mov    %edi,%edx
  801d0a:	83 c4 1c             	add    $0x1c,%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d18:	31 ff                	xor    %edi,%edi
  801d1a:	31 db                	xor    %ebx,%ebx
  801d1c:	89 d8                	mov    %ebx,%eax
  801d1e:	89 fa                	mov    %edi,%edx
  801d20:	83 c4 1c             	add    $0x1c,%esp
  801d23:	5b                   	pop    %ebx
  801d24:	5e                   	pop    %esi
  801d25:	5f                   	pop    %edi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    
  801d28:	90                   	nop
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	89 d8                	mov    %ebx,%eax
  801d32:	f7 f7                	div    %edi
  801d34:	31 ff                	xor    %edi,%edi
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	89 fa                	mov    %edi,%edx
  801d3c:	83 c4 1c             	add    $0x1c,%esp
  801d3f:	5b                   	pop    %ebx
  801d40:	5e                   	pop    %esi
  801d41:	5f                   	pop    %edi
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    
  801d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d48:	39 ce                	cmp    %ecx,%esi
  801d4a:	72 0c                	jb     801d58 <__udivdi3+0x118>
  801d4c:	31 db                	xor    %ebx,%ebx
  801d4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d52:	0f 87 34 ff ff ff    	ja     801c8c <__udivdi3+0x4c>
  801d58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d5d:	e9 2a ff ff ff       	jmp    801c8c <__udivdi3+0x4c>
  801d62:	66 90                	xchg   %ax,%ax
  801d64:	66 90                	xchg   %ax,%ax
  801d66:	66 90                	xchg   %ax,%ax
  801d68:	66 90                	xchg   %ax,%ax
  801d6a:	66 90                	xchg   %ax,%ax
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <__umoddi3>:
  801d70:	55                   	push   %ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
  801d74:	83 ec 1c             	sub    $0x1c,%esp
  801d77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d87:	85 d2                	test   %edx,%edx
  801d89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d91:	89 f3                	mov    %esi,%ebx
  801d93:	89 3c 24             	mov    %edi,(%esp)
  801d96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d9a:	75 1c                	jne    801db8 <__umoddi3+0x48>
  801d9c:	39 f7                	cmp    %esi,%edi
  801d9e:	76 50                	jbe    801df0 <__umoddi3+0x80>
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	89 f2                	mov    %esi,%edx
  801da4:	f7 f7                	div    %edi
  801da6:	89 d0                	mov    %edx,%eax
  801da8:	31 d2                	xor    %edx,%edx
  801daa:	83 c4 1c             	add    $0x1c,%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5f                   	pop    %edi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    
  801db2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801db8:	39 f2                	cmp    %esi,%edx
  801dba:	89 d0                	mov    %edx,%eax
  801dbc:	77 52                	ja     801e10 <__umoddi3+0xa0>
  801dbe:	0f bd ea             	bsr    %edx,%ebp
  801dc1:	83 f5 1f             	xor    $0x1f,%ebp
  801dc4:	75 5a                	jne    801e20 <__umoddi3+0xb0>
  801dc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dca:	0f 82 e0 00 00 00    	jb     801eb0 <__umoddi3+0x140>
  801dd0:	39 0c 24             	cmp    %ecx,(%esp)
  801dd3:	0f 86 d7 00 00 00    	jbe    801eb0 <__umoddi3+0x140>
  801dd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ddd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801de1:	83 c4 1c             	add    $0x1c,%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5f                   	pop    %edi
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    
  801de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801df0:	85 ff                	test   %edi,%edi
  801df2:	89 fd                	mov    %edi,%ebp
  801df4:	75 0b                	jne    801e01 <__umoddi3+0x91>
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	f7 f7                	div    %edi
  801dff:	89 c5                	mov    %eax,%ebp
  801e01:	89 f0                	mov    %esi,%eax
  801e03:	31 d2                	xor    %edx,%edx
  801e05:	f7 f5                	div    %ebp
  801e07:	89 c8                	mov    %ecx,%eax
  801e09:	f7 f5                	div    %ebp
  801e0b:	89 d0                	mov    %edx,%eax
  801e0d:	eb 99                	jmp    801da8 <__umoddi3+0x38>
  801e0f:	90                   	nop
  801e10:	89 c8                	mov    %ecx,%eax
  801e12:	89 f2                	mov    %esi,%edx
  801e14:	83 c4 1c             	add    $0x1c,%esp
  801e17:	5b                   	pop    %ebx
  801e18:	5e                   	pop    %esi
  801e19:	5f                   	pop    %edi
  801e1a:	5d                   	pop    %ebp
  801e1b:	c3                   	ret    
  801e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e20:	8b 34 24             	mov    (%esp),%esi
  801e23:	bf 20 00 00 00       	mov    $0x20,%edi
  801e28:	89 e9                	mov    %ebp,%ecx
  801e2a:	29 ef                	sub    %ebp,%edi
  801e2c:	d3 e0                	shl    %cl,%eax
  801e2e:	89 f9                	mov    %edi,%ecx
  801e30:	89 f2                	mov    %esi,%edx
  801e32:	d3 ea                	shr    %cl,%edx
  801e34:	89 e9                	mov    %ebp,%ecx
  801e36:	09 c2                	or     %eax,%edx
  801e38:	89 d8                	mov    %ebx,%eax
  801e3a:	89 14 24             	mov    %edx,(%esp)
  801e3d:	89 f2                	mov    %esi,%edx
  801e3f:	d3 e2                	shl    %cl,%edx
  801e41:	89 f9                	mov    %edi,%ecx
  801e43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e4b:	d3 e8                	shr    %cl,%eax
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	89 c6                	mov    %eax,%esi
  801e51:	d3 e3                	shl    %cl,%ebx
  801e53:	89 f9                	mov    %edi,%ecx
  801e55:	89 d0                	mov    %edx,%eax
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	09 d8                	or     %ebx,%eax
  801e5d:	89 d3                	mov    %edx,%ebx
  801e5f:	89 f2                	mov    %esi,%edx
  801e61:	f7 34 24             	divl   (%esp)
  801e64:	89 d6                	mov    %edx,%esi
  801e66:	d3 e3                	shl    %cl,%ebx
  801e68:	f7 64 24 04          	mull   0x4(%esp)
  801e6c:	39 d6                	cmp    %edx,%esi
  801e6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e72:	89 d1                	mov    %edx,%ecx
  801e74:	89 c3                	mov    %eax,%ebx
  801e76:	72 08                	jb     801e80 <__umoddi3+0x110>
  801e78:	75 11                	jne    801e8b <__umoddi3+0x11b>
  801e7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e7e:	73 0b                	jae    801e8b <__umoddi3+0x11b>
  801e80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e84:	1b 14 24             	sbb    (%esp),%edx
  801e87:	89 d1                	mov    %edx,%ecx
  801e89:	89 c3                	mov    %eax,%ebx
  801e8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e8f:	29 da                	sub    %ebx,%edx
  801e91:	19 ce                	sbb    %ecx,%esi
  801e93:	89 f9                	mov    %edi,%ecx
  801e95:	89 f0                	mov    %esi,%eax
  801e97:	d3 e0                	shl    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	d3 ea                	shr    %cl,%edx
  801e9d:	89 e9                	mov    %ebp,%ecx
  801e9f:	d3 ee                	shr    %cl,%esi
  801ea1:	09 d0                	or     %edx,%eax
  801ea3:	89 f2                	mov    %esi,%edx
  801ea5:	83 c4 1c             	add    $0x1c,%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	29 f9                	sub    %edi,%ecx
  801eb2:	19 d6                	sbb    %edx,%esi
  801eb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ebc:	e9 18 ff ff ff       	jmp    801dd9 <__umoddi3+0x69>
