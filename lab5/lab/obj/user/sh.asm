
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 a2 09 00 00       	call   8009d3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

	   int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	   int t;

	   if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
			 if (debug > 1)
				    cprintf("GETTOKEN NULL\n");
			 return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	   int t;

	   if (s == 0) {
			 if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
				    cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 20 33 80 00       	push   $0x803320
  800060:	e8 a7 0a 00 00       	call   800b0c <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
			 return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	   }

	   if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
			 cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 2f 33 80 00       	push   $0x80332f
  800084:	e8 83 0a 00 00       	call   800b0c <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	   *p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	   *p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	   while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
			 *s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
			 cprintf("GETTOKEN: %s\n", s);

	   *p1 = 0;
	   *p2 = 0;

	   while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 3d 33 80 00       	push   $0x80333d
  8000b0:	e8 d7 11 00 00       	call   80128c <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
			 *s++ = 0;
	   if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
			 if (debug > 1)
				    cprintf("EOL\n");
			 return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	   *p2 = 0;

	   while (strchr(WHITESPACE, *s))
			 *s++ = 0;
	   if (*s == 0) {
			 if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
				    cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 42 33 80 00       	push   $0x803342
  8000dd:	e8 2a 0a 00 00       	call   800b0c <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
			 return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	   }
	   if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 53 33 80 00       	push   $0x803353
  8000fb:	e8 8c 11 00 00       	call   80128c <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
			 t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
			 *p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
			 *s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
			 *p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
			 if (debug > 1)
				    cprintf("TOK %c\n", t);
			 return t;
  800117:	89 f8                	mov    %edi,%eax
	   if (strchr(SYMBOLS, *s)) {
			 t = *s;
			 *p1 = s;
			 *s++ = 0;
			 *p2 = s;
			 if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
				    cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 47 33 80 00       	push   $0x803347
  80012b:	e8 dc 09 00 00       	call   800b0c <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
			 return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	   }
	   *p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	   while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
			 s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
			 if (debug > 1)
				    cprintf("TOK %c\n", t);
			 return t;
	   }
	   *p1 = s;
	   while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 4f 33 80 00       	push   $0x80334f
  800151:	e8 36 11 00 00       	call   80128c <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
			 s++;
	   *p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
			 t = **p2;
			 **p2 = 0;
			 cprintf("WORD: %s\n", *p1);
			 **p2 = t;
	   }
	   return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	   }
	   *p1 = s;
	   while (*s && !strchr(WHITESPACE SYMBOLS, *s))
			 s++;
	   *p2 = s;
	   if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
			 t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
			 **p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
			 cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 5b 33 80 00       	push   $0x80335b
  800180:	e8 87 09 00 00       	call   800b0c <cprintf>
			 **p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	   }
	   return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

	   int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	   static int c, nc;
	   static char* np1, *np2;

	   if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
			 nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
			 return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	   }
	   c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	   *p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	   nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	   return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
	   void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	   char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	   int argc, c, i, r, p[2], fd, pipe_child;

	   pipe_child = 0;
	   gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	   argc = 0;
	   while (1) {
			 switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	   pipe_child = 0;
	   gettoken(s, 0);

again:
	   argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	   while (1) {
			 switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 ea 00 00 00    	je     80032b <runcmd+0x122>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 59 02 00 00    	je     8004a7 <runcmd+0x29e>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 3d 02 00 00       	jmp    800495 <runcmd+0x28c>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 43 01 00 00    	je     8003a9 <runcmd+0x1a0>
  800266:	e9 2a 02 00 00       	jmp    800495 <runcmd+0x28c>

				    case 'w':	// Add an argument
						  if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
								cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 65 33 80 00       	push   $0x803365
  800278:	e8 8f 08 00 00       	call   800b0c <cprintf>
								exit();
  80027d:	e8 97 07 00 00       	call   800a19 <exit>
  800282:	83 c4 10             	add    $0x10,%esp
						  }
						  argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
						  break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

				    case '<':	// Input redirection
						  // Grab the filename from the argument list
						  if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
								cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 c0 34 80 00       	push   $0x8034c0
  8002ac:	e8 5b 08 00 00       	call   800b0c <cprintf>
								exit();
  8002b1:	e8 63 07 00 00       	call   800a19 <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
						  // If not, dup 'fd' onto file descriptor 0,
						  // then close the original 'fd'.

						  // LAB 5: Your code here.
						  //panic("< redirection not implemented");
						  if ((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 9e 20 00 00       	call   802364 <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
								cprintf("open %s for read: %e\n", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 79 33 80 00       	push   $0x803379
  8002db:	e8 2c 08 00 00       	call   800b0c <cprintf>
								exit();
  8002e0:	e8 34 07 00 00       	call   800a19 <exit>
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	eb 08                	jmp    8002f2 <runcmd+0xe9>
						  }
						  if (fd != 0) {
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 38 ff ff ff    	je     80022a <runcmd+0x21>
								if ((r = dup(fd, 0)) < 0) {
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	6a 00                	push   $0x0
  8002f7:	57                   	push   %edi
  8002f8:	e8 a7 1a 00 00       	call   801da4 <dup>
  8002fd:	83 c4 10             	add    $0x10,%esp
  800300:	85 c0                	test   %eax,%eax
  800302:	79 16                	jns    80031a <runcmd+0x111>
									   cprintf("failed dup: %x\n", r);
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	50                   	push   %eax
  800308:	68 8f 33 80 00       	push   $0x80338f
  80030d:	e8 fa 07 00 00       	call   800b0c <cprintf>
									   exit();
  800312:	e8 02 07 00 00       	call   800a19 <exit>
  800317:	83 c4 10             	add    $0x10,%esp
								}
								close(fd);
  80031a:	83 ec 0c             	sub    $0xc,%esp
  80031d:	57                   	push   %edi
  80031e:	e8 31 1a 00 00       	call   801d54 <close>
  800323:	83 c4 10             	add    $0x10,%esp
  800326:	e9 ff fe ff ff       	jmp    80022a <runcmd+0x21>
						  }
						  break;

				    case '>':	// Output redirection
						  // Grab the filename from the argument list
						  if (gettoken(0, &t) != 'w') {
  80032b:	83 ec 08             	sub    $0x8,%esp
  80032e:	53                   	push   %ebx
  80032f:	6a 00                	push   $0x0
  800331:	e8 68 fe ff ff       	call   80019e <gettoken>
  800336:	83 c4 10             	add    $0x10,%esp
  800339:	83 f8 77             	cmp    $0x77,%eax
  80033c:	74 15                	je     800353 <runcmd+0x14a>
								cprintf("syntax error: > not followed by word\n");
  80033e:	83 ec 0c             	sub    $0xc,%esp
  800341:	68 e8 34 80 00       	push   $0x8034e8
  800346:	e8 c1 07 00 00       	call   800b0c <cprintf>
								exit();
  80034b:	e8 c9 06 00 00       	call   800a19 <exit>
  800350:	83 c4 10             	add    $0x10,%esp
						  }
						  if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800353:	83 ec 08             	sub    $0x8,%esp
  800356:	68 01 03 00 00       	push   $0x301
  80035b:	ff 75 a4             	pushl  -0x5c(%ebp)
  80035e:	e8 01 20 00 00       	call   802364 <open>
  800363:	89 c7                	mov    %eax,%edi
  800365:	83 c4 10             	add    $0x10,%esp
  800368:	85 c0                	test   %eax,%eax
  80036a:	79 19                	jns    800385 <runcmd+0x17c>
								cprintf("open %s for write: %e", t, fd);
  80036c:	83 ec 04             	sub    $0x4,%esp
  80036f:	50                   	push   %eax
  800370:	ff 75 a4             	pushl  -0x5c(%ebp)
  800373:	68 9f 33 80 00       	push   $0x80339f
  800378:	e8 8f 07 00 00       	call   800b0c <cprintf>
								exit();
  80037d:	e8 97 06 00 00       	call   800a19 <exit>
  800382:	83 c4 10             	add    $0x10,%esp
						  }
						  if (fd != 1) {
  800385:	83 ff 01             	cmp    $0x1,%edi
  800388:	0f 84 9c fe ff ff    	je     80022a <runcmd+0x21>
								dup(fd, 1);
  80038e:	83 ec 08             	sub    $0x8,%esp
  800391:	6a 01                	push   $0x1
  800393:	57                   	push   %edi
  800394:	e8 0b 1a 00 00       	call   801da4 <dup>
								close(fd);
  800399:	89 3c 24             	mov    %edi,(%esp)
  80039c:	e8 b3 19 00 00       	call   801d54 <close>
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	e9 81 fe ff ff       	jmp    80022a <runcmd+0x21>
						  }
						  break;

				    case '|':	// Pipe
						  if ((r = pipe(p)) < 0) {
  8003a9:	83 ec 0c             	sub    $0xc,%esp
  8003ac:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  8003b2:	50                   	push   %eax
  8003b3:	e8 4c 29 00 00       	call   802d04 <pipe>
  8003b8:	83 c4 10             	add    $0x10,%esp
  8003bb:	85 c0                	test   %eax,%eax
  8003bd:	79 16                	jns    8003d5 <runcmd+0x1cc>
								cprintf("pipe: %e", r);
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	50                   	push   %eax
  8003c3:	68 b5 33 80 00       	push   $0x8033b5
  8003c8:	e8 3f 07 00 00       	call   800b0c <cprintf>
								exit();
  8003cd:	e8 47 06 00 00       	call   800a19 <exit>
  8003d2:	83 c4 10             	add    $0x10,%esp
						  }
						  if (debug)
  8003d5:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003dc:	74 1c                	je     8003fa <runcmd+0x1f1>
								cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003de:	83 ec 04             	sub    $0x4,%esp
  8003e1:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003e7:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003ed:	68 be 33 80 00       	push   $0x8033be
  8003f2:	e8 15 07 00 00       	call   800b0c <cprintf>
  8003f7:	83 c4 10             	add    $0x10,%esp
						  if ((r = fork()) < 0) {
  8003fa:	e8 62 14 00 00       	call   801861 <fork>
  8003ff:	89 c7                	mov    %eax,%edi
  800401:	85 c0                	test   %eax,%eax
  800403:	79 16                	jns    80041b <runcmd+0x212>
								cprintf("fork: %e", r);
  800405:	83 ec 08             	sub    $0x8,%esp
  800408:	50                   	push   %eax
  800409:	68 18 39 80 00       	push   $0x803918
  80040e:	e8 f9 06 00 00       	call   800b0c <cprintf>
								exit();
  800413:	e8 01 06 00 00       	call   800a19 <exit>
  800418:	83 c4 10             	add    $0x10,%esp
						  }
						  if (r == 0) {
  80041b:	85 ff                	test   %edi,%edi
  80041d:	75 3c                	jne    80045b <runcmd+0x252>
								if (p[0] != 0) {
  80041f:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800425:	85 c0                	test   %eax,%eax
  800427:	74 1c                	je     800445 <runcmd+0x23c>
									   dup(p[0], 0);
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	6a 00                	push   $0x0
  80042e:	50                   	push   %eax
  80042f:	e8 70 19 00 00       	call   801da4 <dup>
									   close(p[0]);
  800434:	83 c4 04             	add    $0x4,%esp
  800437:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80043d:	e8 12 19 00 00       	call   801d54 <close>
  800442:	83 c4 10             	add    $0x10,%esp
								}
								close(p[1]);
  800445:	83 ec 0c             	sub    $0xc,%esp
  800448:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80044e:	e8 01 19 00 00       	call   801d54 <close>
								goto again;
  800453:	83 c4 10             	add    $0x10,%esp
  800456:	e9 ca fd ff ff       	jmp    800225 <runcmd+0x1c>
						  } else {
								pipe_child = r;
								if (p[1] != 1) {
  80045b:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800461:	83 f8 01             	cmp    $0x1,%eax
  800464:	74 1c                	je     800482 <runcmd+0x279>
									   dup(p[1], 1);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	6a 01                	push   $0x1
  80046b:	50                   	push   %eax
  80046c:	e8 33 19 00 00       	call   801da4 <dup>
									   close(p[1]);
  800471:	83 c4 04             	add    $0x4,%esp
  800474:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80047a:	e8 d5 18 00 00       	call   801d54 <close>
  80047f:	83 c4 10             	add    $0x10,%esp
								}
								close(p[0]);
  800482:	83 ec 0c             	sub    $0xc,%esp
  800485:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80048b:	e8 c4 18 00 00       	call   801d54 <close>
								goto runit;
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	eb 17                	jmp    8004ac <runcmd+0x2a3>
				    case 0:		// String is complete
						  // Run the current command!
						  goto runit;

				    default:
						  panic("bad return %d from gettoken", c);
  800495:	50                   	push   %eax
  800496:	68 cb 33 80 00       	push   $0x8033cb
  80049b:	6a 7b                	push   $0x7b
  80049d:	68 e7 33 80 00       	push   $0x8033e7
  8004a2:	e8 8c 05 00 00       	call   800a33 <_panic>
runcmd(char* s)
{
	   char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	   int argc, c, i, r, p[2], fd, pipe_child;

	   pipe_child = 0;
  8004a7:	bf 00 00 00 00       	mov    $0x0,%edi
			 }
	   }

runit:
	   // Return immediately if command line was empty.
	   if(argc == 0) {
  8004ac:	85 f6                	test   %esi,%esi
  8004ae:	75 22                	jne    8004d2 <runcmd+0x2c9>
			 if (debug)
  8004b0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004b7:	0f 84 96 01 00 00    	je     800653 <runcmd+0x44a>
				    cprintf("EMPTY COMMAND\n");
  8004bd:	83 ec 0c             	sub    $0xc,%esp
  8004c0:	68 f1 33 80 00       	push   $0x8033f1
  8004c5:	e8 42 06 00 00       	call   800b0c <cprintf>
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	e9 81 01 00 00       	jmp    800653 <runcmd+0x44a>

	   // Clean up command line.
	   // Read all commands from the filesystem: add an initial '/' to
	   // the command name.
	   // This essentially acts like 'PATH=/'.
	   if (argv[0][0] != '/') {
  8004d2:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004d5:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004d8:	74 23                	je     8004fd <runcmd+0x2f4>
			 argv0buf[0] = '/';
  8004da:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
			 strcpy(argv0buf + 1, argv[0]);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	50                   	push   %eax
  8004e5:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004eb:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004f1:	50                   	push   %eax
  8004f2:	e8 8d 0c 00 00       	call   801184 <strcpy>
			 argv[0] = argv0buf;
  8004f7:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004fa:	83 c4 10             	add    $0x10,%esp
	   }
	   argv[argc] = 0;
  8004fd:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  800504:	00 

	   // Print the command.
	   if (debug) {
  800505:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80050c:	74 49                	je     800557 <runcmd+0x34e>
			 cprintf("[%08x] SPAWN:", thisenv->env_id);
  80050e:	a1 24 54 80 00       	mov    0x805424,%eax
  800513:	8b 40 48             	mov    0x48(%eax),%eax
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	50                   	push   %eax
  80051a:	68 00 34 80 00       	push   $0x803400
  80051f:	e8 e8 05 00 00       	call   800b0c <cprintf>
  800524:	8d 5d a8             	lea    -0x58(%ebp),%ebx
			 for (i = 0; argv[i]; i++)
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	eb 11                	jmp    80053d <runcmd+0x334>
				    cprintf(" %s", argv[i]);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	50                   	push   %eax
  800530:	68 88 34 80 00       	push   $0x803488
  800535:	e8 d2 05 00 00       	call   800b0c <cprintf>
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	83 c3 04             	add    $0x4,%ebx
	   argv[argc] = 0;

	   // Print the command.
	   if (debug) {
			 cprintf("[%08x] SPAWN:", thisenv->env_id);
			 for (i = 0; argv[i]; i++)
  800540:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800543:	85 c0                	test   %eax,%eax
  800545:	75 e5                	jne    80052c <runcmd+0x323>
				    cprintf(" %s", argv[i]);
			 cprintf("\n");
  800547:	83 ec 0c             	sub    $0xc,%esp
  80054a:	68 40 33 80 00       	push   $0x803340
  80054f:	e8 b8 05 00 00       	call   800b0c <cprintf>
  800554:	83 c4 10             	add    $0x10,%esp
	   }

	   // Spawn the command!
	   if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80055d:	50                   	push   %eax
  80055e:	ff 75 a8             	pushl  -0x58(%ebp)
  800561:	e8 b2 1f 00 00       	call   802518 <spawn>
  800566:	89 c3                	mov    %eax,%ebx
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	85 c0                	test   %eax,%eax
  80056d:	0f 89 c3 00 00 00    	jns    800636 <runcmd+0x42d>
			 cprintf("spawn %s: %e\n", argv[0], r);
  800573:	83 ec 04             	sub    $0x4,%esp
  800576:	50                   	push   %eax
  800577:	ff 75 a8             	pushl  -0x58(%ebp)
  80057a:	68 0e 34 80 00       	push   $0x80340e
  80057f:	e8 88 05 00 00       	call   800b0c <cprintf>

	   // In the parent, close all file descriptors and wait for the
	   // spawned command to exit.
	   close_all();
  800584:	e8 f6 17 00 00       	call   801d7f <close_all>
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	eb 4c                	jmp    8005da <runcmd+0x3d1>
	   if (r >= 0) {
			 if (debug)
				    cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80058e:	a1 24 54 80 00       	mov    0x805424,%eax
  800593:	8b 40 48             	mov    0x48(%eax),%eax
  800596:	53                   	push   %ebx
  800597:	ff 75 a8             	pushl  -0x58(%ebp)
  80059a:	50                   	push   %eax
  80059b:	68 1c 34 80 00       	push   $0x80341c
  8005a0:	e8 67 05 00 00       	call   800b0c <cprintf>
  8005a5:	83 c4 10             	add    $0x10,%esp
			 wait(r);
  8005a8:	83 ec 0c             	sub    $0xc,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	e8 d9 28 00 00       	call   802e8a <wait>
			 if (debug)
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005bb:	0f 84 8c 00 00 00    	je     80064d <runcmd+0x444>
				    cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005c1:	a1 24 54 80 00       	mov    0x805424,%eax
  8005c6:	8b 40 48             	mov    0x48(%eax),%eax
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	50                   	push   %eax
  8005cd:	68 31 34 80 00       	push   $0x803431
  8005d2:	e8 35 05 00 00       	call   800b0c <cprintf>
  8005d7:	83 c4 10             	add    $0x10,%esp
	   }

	   // If we were the left-hand part of a pipe,
	   // wait for the right-hand part to finish.
	   if (pipe_child) {
  8005da:	85 ff                	test   %edi,%edi
  8005dc:	74 51                	je     80062f <runcmd+0x426>
			 if (debug)
  8005de:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005e5:	74 1a                	je     800601 <runcmd+0x3f8>
				    cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005e7:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ec:	8b 40 48             	mov    0x48(%eax),%eax
  8005ef:	83 ec 04             	sub    $0x4,%esp
  8005f2:	57                   	push   %edi
  8005f3:	50                   	push   %eax
  8005f4:	68 47 34 80 00       	push   $0x803447
  8005f9:	e8 0e 05 00 00       	call   800b0c <cprintf>
  8005fe:	83 c4 10             	add    $0x10,%esp
			 wait(pipe_child);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	57                   	push   %edi
  800605:	e8 80 28 00 00       	call   802e8a <wait>
			 if (debug)
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800614:	74 19                	je     80062f <runcmd+0x426>
				    cprintf("[%08x] wait finished\n", thisenv->env_id);
  800616:	a1 24 54 80 00       	mov    0x805424,%eax
  80061b:	8b 40 48             	mov    0x48(%eax),%eax
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	50                   	push   %eax
  800622:	68 31 34 80 00       	push   $0x803431
  800627:	e8 e0 04 00 00       	call   800b0c <cprintf>
  80062c:	83 c4 10             	add    $0x10,%esp
	   }

	   // Done!
	   exit();
  80062f:	e8 e5 03 00 00       	call   800a19 <exit>
  800634:	eb 1d                	jmp    800653 <runcmd+0x44a>
	   if ((r = spawn(argv[0], (const char**) argv)) < 0)
			 cprintf("spawn %s: %e\n", argv[0], r);

	   // In the parent, close all file descriptors and wait for the
	   // spawned command to exit.
	   close_all();
  800636:	e8 44 17 00 00       	call   801d7f <close_all>
	   if (r >= 0) {
			 if (debug)
  80063b:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800642:	0f 84 60 ff ff ff    	je     8005a8 <runcmd+0x39f>
  800648:	e9 41 ff ff ff       	jmp    80058e <runcmd+0x385>
				    cprintf("[%08x] wait finished\n", thisenv->env_id);
	   }

	   // If we were the left-hand part of a pipe,
	   // wait for the right-hand part to finish.
	   if (pipe_child) {
  80064d:	85 ff                	test   %edi,%edi
  80064f:	75 b0                	jne    800601 <runcmd+0x3f8>
  800651:	eb dc                	jmp    80062f <runcmd+0x426>
				    cprintf("[%08x] wait finished\n", thisenv->env_id);
	   }

	   // Done!
	   exit();
}
  800653:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800656:	5b                   	pop    %ebx
  800657:	5e                   	pop    %esi
  800658:	5f                   	pop    %edi
  800659:	5d                   	pop    %ebp
  80065a:	c3                   	ret    

0080065b <usage>:
}


	   void
usage(void)
{
  80065b:	55                   	push   %ebp
  80065c:	89 e5                	mov    %esp,%ebp
  80065e:	83 ec 14             	sub    $0x14,%esp
	   cprintf("usage: sh [-dix] [command-file]\n");
  800661:	68 10 35 80 00       	push   $0x803510
  800666:	e8 a1 04 00 00       	call   800b0c <cprintf>
	   exit();
  80066b:	e8 a9 03 00 00       	call   800a19 <exit>
}
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	c9                   	leave  
  800674:	c3                   	ret    

00800675 <umain>:

	   void
umain(int argc, char **argv)
{
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	57                   	push   %edi
  800679:	56                   	push   %esi
  80067a:	53                   	push   %ebx
  80067b:	83 ec 30             	sub    $0x30,%esp
  80067e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	   int r, interactive, echocmds;
	   struct Argstate args;

	   interactive = '?';
	   echocmds = 0;
	   argstart(&argc, argv, &args);
  800681:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800684:	50                   	push   %eax
  800685:	57                   	push   %edi
  800686:	8d 45 08             	lea    0x8(%ebp),%eax
  800689:	50                   	push   %eax
  80068a:	e8 d1 13 00 00       	call   801a60 <argstart>
	   while ((r = argnext(&args)) >= 0)
  80068f:	83 c4 10             	add    $0x10,%esp
{
	   int r, interactive, echocmds;
	   struct Argstate args;

	   interactive = '?';
	   echocmds = 0;
  800692:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	   int r, interactive, echocmds;
	   struct Argstate args;

	   interactive = '?';
  800699:	be 3f 00 00 00       	mov    $0x3f,%esi
	   echocmds = 0;
	   argstart(&argc, argv, &args);
	   while ((r = argnext(&args)) >= 0)
  80069e:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8006a1:	eb 2f                	jmp    8006d2 <umain+0x5d>
			 switch (r) {
  8006a3:	83 f8 69             	cmp    $0x69,%eax
  8006a6:	74 25                	je     8006cd <umain+0x58>
  8006a8:	83 f8 78             	cmp    $0x78,%eax
  8006ab:	74 07                	je     8006b4 <umain+0x3f>
  8006ad:	83 f8 64             	cmp    $0x64,%eax
  8006b0:	75 14                	jne    8006c6 <umain+0x51>
  8006b2:	eb 09                	jmp    8006bd <umain+0x48>
						  break;
				    case 'i':
						  interactive = 1;
						  break;
				    case 'x':
						  echocmds = 1;
  8006b4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  8006bb:	eb 15                	jmp    8006d2 <umain+0x5d>
	   echocmds = 0;
	   argstart(&argc, argv, &args);
	   while ((r = argnext(&args)) >= 0)
			 switch (r) {
				    case 'd':
						  debug++;
  8006bd:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
						  break;
  8006c4:	eb 0c                	jmp    8006d2 <umain+0x5d>
						  break;
				    case 'x':
						  echocmds = 1;
						  break;
				    default:
						  usage();
  8006c6:	e8 90 ff ff ff       	call   80065b <usage>
  8006cb:	eb 05                	jmp    8006d2 <umain+0x5d>
			 switch (r) {
				    case 'd':
						  debug++;
						  break;
				    case 'i':
						  interactive = 1;
  8006cd:	be 01 00 00 00       	mov    $0x1,%esi
	   struct Argstate args;

	   interactive = '?';
	   echocmds = 0;
	   argstart(&argc, argv, &args);
	   while ((r = argnext(&args)) >= 0)
  8006d2:	83 ec 0c             	sub    $0xc,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	e8 b5 13 00 00       	call   801a90 <argnext>
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	85 c0                	test   %eax,%eax
  8006e0:	79 c1                	jns    8006a3 <umain+0x2e>
						  break;
				    default:
						  usage();
			 }

	   if (argc > 2)
  8006e2:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006e6:	7e 05                	jle    8006ed <umain+0x78>
			 usage();
  8006e8:	e8 6e ff ff ff       	call   80065b <usage>
	   if (argc == 2) {
  8006ed:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006f1:	75 56                	jne    800749 <umain+0xd4>
			 close(0);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	6a 00                	push   $0x0
  8006f8:	e8 57 16 00 00       	call   801d54 <close>
			 if ((r = open(argv[1], O_RDONLY)) < 0)
  8006fd:	83 c4 08             	add    $0x8,%esp
  800700:	6a 00                	push   $0x0
  800702:	ff 77 04             	pushl  0x4(%edi)
  800705:	e8 5a 1c 00 00       	call   802364 <open>
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	85 c0                	test   %eax,%eax
  80070f:	79 1b                	jns    80072c <umain+0xb7>
				    panic("open %s: %e", argv[1], r);
  800711:	83 ec 0c             	sub    $0xc,%esp
  800714:	50                   	push   %eax
  800715:	ff 77 04             	pushl  0x4(%edi)
  800718:	68 64 34 80 00       	push   $0x803464
  80071d:	68 2b 01 00 00       	push   $0x12b
  800722:	68 e7 33 80 00       	push   $0x8033e7
  800727:	e8 07 03 00 00       	call   800a33 <_panic>
			 assert(r == 0);
  80072c:	85 c0                	test   %eax,%eax
  80072e:	74 19                	je     800749 <umain+0xd4>
  800730:	68 70 34 80 00       	push   $0x803470
  800735:	68 77 34 80 00       	push   $0x803477
  80073a:	68 2c 01 00 00       	push   $0x12c
  80073f:	68 e7 33 80 00       	push   $0x8033e7
  800744:	e8 ea 02 00 00       	call   800a33 <_panic>
	   }
	   if (interactive == '?')
  800749:	83 fe 3f             	cmp    $0x3f,%esi
  80074c:	75 0f                	jne    80075d <umain+0xe8>
			 interactive = iscons(0);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	6a 00                	push   $0x0
  800753:	e8 f5 01 00 00       	call   80094d <iscons>
  800758:	89 c6                	mov    %eax,%esi
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	85 f6                	test   %esi,%esi
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
  800764:	bf 8c 34 80 00       	mov    $0x80348c,%edi
  800769:	0f 44 f8             	cmove  %eax,%edi

	   while (1) {
			 char *buf;

			 buf = readline(interactive ? "$ " : NULL);
  80076c:	83 ec 0c             	sub    $0xc,%esp
  80076f:	57                   	push   %edi
  800770:	e8 e3 08 00 00       	call   801058 <readline>
  800775:	89 c3                	mov    %eax,%ebx
			 if (buf == NULL) {
  800777:	83 c4 10             	add    $0x10,%esp
  80077a:	85 c0                	test   %eax,%eax
  80077c:	75 1e                	jne    80079c <umain+0x127>
				    if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 10                	je     800797 <umain+0x122>
						  cprintf("EXITING\n");
  800787:	83 ec 0c             	sub    $0xc,%esp
  80078a:	68 8f 34 80 00       	push   $0x80348f
  80078f:	e8 78 03 00 00       	call   800b0c <cprintf>
  800794:	83 c4 10             	add    $0x10,%esp
				    exit();	// end of file
  800797:	e8 7d 02 00 00       	call   800a19 <exit>
			 }
			 if (debug)
  80079c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007a3:	74 11                	je     8007b6 <umain+0x141>
				    cprintf("LINE: %s\n", buf);
  8007a5:	83 ec 08             	sub    $0x8,%esp
  8007a8:	53                   	push   %ebx
  8007a9:	68 98 34 80 00       	push   $0x803498
  8007ae:	e8 59 03 00 00       	call   800b0c <cprintf>
  8007b3:	83 c4 10             	add    $0x10,%esp
			 if (buf[0] == '#')
  8007b6:	80 3b 23             	cmpb   $0x23,(%ebx)
  8007b9:	74 b1                	je     80076c <umain+0xf7>
				    continue;
			 if (echocmds)
  8007bb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007bf:	74 11                	je     8007d2 <umain+0x15d>
				    printf("# %s\n", buf);
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	53                   	push   %ebx
  8007c5:	68 a2 34 80 00       	push   $0x8034a2
  8007ca:	e8 33 1d 00 00       	call   802502 <printf>
  8007cf:	83 c4 10             	add    $0x10,%esp
			 if (debug)
  8007d2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007d9:	74 10                	je     8007eb <umain+0x176>
				    cprintf("BEFORE FORK\n");
  8007db:	83 ec 0c             	sub    $0xc,%esp
  8007de:	68 a8 34 80 00       	push   $0x8034a8
  8007e3:	e8 24 03 00 00       	call   800b0c <cprintf>
  8007e8:	83 c4 10             	add    $0x10,%esp
			 if ((r = fork()) < 0)
  8007eb:	e8 71 10 00 00       	call   801861 <fork>
  8007f0:	89 c6                	mov    %eax,%esi
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	79 15                	jns    80080b <umain+0x196>
				    panic("fork: %e", r);
  8007f6:	50                   	push   %eax
  8007f7:	68 18 39 80 00       	push   $0x803918
  8007fc:	68 43 01 00 00       	push   $0x143
  800801:	68 e7 33 80 00       	push   $0x8033e7
  800806:	e8 28 02 00 00       	call   800a33 <_panic>
			 if (debug)
  80080b:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800812:	74 11                	je     800825 <umain+0x1b0>
				    cprintf("FORK: %d\n", r);
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	50                   	push   %eax
  800818:	68 b5 34 80 00       	push   $0x8034b5
  80081d:	e8 ea 02 00 00       	call   800b0c <cprintf>
  800822:	83 c4 10             	add    $0x10,%esp
			 if (r == 0) {
  800825:	85 f6                	test   %esi,%esi
  800827:	75 16                	jne    80083f <umain+0x1ca>
				    runcmd(buf);
  800829:	83 ec 0c             	sub    $0xc,%esp
  80082c:	53                   	push   %ebx
  80082d:	e8 d7 f9 ff ff       	call   800209 <runcmd>
				    exit();
  800832:	e8 e2 01 00 00       	call   800a19 <exit>
  800837:	83 c4 10             	add    $0x10,%esp
  80083a:	e9 2d ff ff ff       	jmp    80076c <umain+0xf7>
			 } else
				    wait(r);
  80083f:	83 ec 0c             	sub    $0xc,%esp
  800842:	56                   	push   %esi
  800843:	e8 42 26 00 00       	call   802e8a <wait>
  800848:	83 c4 10             	add    $0x10,%esp
  80084b:	e9 1c ff ff ff       	jmp    80076c <umain+0xf7>

00800850 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800860:	68 31 35 80 00       	push   $0x803531
  800865:	ff 75 0c             	pushl  0xc(%ebp)
  800868:	e8 17 09 00 00       	call   801184 <strcpy>
	return 0;
}
  80086d:	b8 00 00 00 00       	mov    $0x0,%eax
  800872:	c9                   	leave  
  800873:	c3                   	ret    

00800874 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	57                   	push   %edi
  800878:	56                   	push   %esi
  800879:	53                   	push   %ebx
  80087a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800880:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800885:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80088b:	eb 2d                	jmp    8008ba <devcons_write+0x46>
		m = n - tot;
  80088d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800890:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800892:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800895:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80089a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80089d:	83 ec 04             	sub    $0x4,%esp
  8008a0:	53                   	push   %ebx
  8008a1:	03 45 0c             	add    0xc(%ebp),%eax
  8008a4:	50                   	push   %eax
  8008a5:	57                   	push   %edi
  8008a6:	e8 6b 0a 00 00       	call   801316 <memmove>
		sys_cputs(buf, m);
  8008ab:	83 c4 08             	add    $0x8,%esp
  8008ae:	53                   	push   %ebx
  8008af:	57                   	push   %edi
  8008b0:	e8 16 0c 00 00       	call   8014cb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8008b5:	01 de                	add    %ebx,%esi
  8008b7:	83 c4 10             	add    $0x10,%esp
  8008ba:	89 f0                	mov    %esi,%eax
  8008bc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008bf:	72 cc                	jb     80088d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c4:	5b                   	pop    %ebx
  8008c5:	5e                   	pop    %esi
  8008c6:	5f                   	pop    %edi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	83 ec 08             	sub    $0x8,%esp
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008d8:	74 2a                	je     800904 <devcons_read+0x3b>
  8008da:	eb 05                	jmp    8008e1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008dc:	e8 87 0c 00 00       	call   801568 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008e1:	e8 03 0c 00 00       	call   8014e9 <sys_cgetc>
  8008e6:	85 c0                	test   %eax,%eax
  8008e8:	74 f2                	je     8008dc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008ea:	85 c0                	test   %eax,%eax
  8008ec:	78 16                	js     800904 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008ee:	83 f8 04             	cmp    $0x4,%eax
  8008f1:	74 0c                	je     8008ff <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f6:	88 02                	mov    %al,(%edx)
	return 1;
  8008f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8008fd:	eb 05                	jmp    800904 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800912:	6a 01                	push   $0x1
  800914:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800917:	50                   	push   %eax
  800918:	e8 ae 0b 00 00       	call   8014cb <sys_cputs>
}
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <getchar>:

int
getchar(void)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800928:	6a 01                	push   $0x1
  80092a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80092d:	50                   	push   %eax
  80092e:	6a 00                	push   $0x0
  800930:	e8 5b 15 00 00       	call   801e90 <read>
	if (r < 0)
  800935:	83 c4 10             	add    $0x10,%esp
  800938:	85 c0                	test   %eax,%eax
  80093a:	78 0f                	js     80094b <getchar+0x29>
		return r;
	if (r < 1)
  80093c:	85 c0                	test   %eax,%eax
  80093e:	7e 06                	jle    800946 <getchar+0x24>
		return -E_EOF;
	return c;
  800940:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800944:	eb 05                	jmp    80094b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800946:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800953:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800956:	50                   	push   %eax
  800957:	ff 75 08             	pushl  0x8(%ebp)
  80095a:	e8 cb 12 00 00       	call   801c2a <fd_lookup>
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	85 c0                	test   %eax,%eax
  800964:	78 11                	js     800977 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800966:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800969:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80096f:	39 10                	cmp    %edx,(%eax)
  800971:	0f 94 c0             	sete   %al
  800974:	0f b6 c0             	movzbl %al,%eax
}
  800977:	c9                   	leave  
  800978:	c3                   	ret    

00800979 <opencons>:

int
opencons(void)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80097f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800982:	50                   	push   %eax
  800983:	e8 53 12 00 00       	call   801bdb <fd_alloc>
  800988:	83 c4 10             	add    $0x10,%esp
		return r;
  80098b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80098d:	85 c0                	test   %eax,%eax
  80098f:	78 3e                	js     8009cf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800991:	83 ec 04             	sub    $0x4,%esp
  800994:	68 07 04 00 00       	push   $0x407
  800999:	ff 75 f4             	pushl  -0xc(%ebp)
  80099c:	6a 00                	push   $0x0
  80099e:	e8 e4 0b 00 00       	call   801587 <sys_page_alloc>
  8009a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8009a6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8009a8:	85 c0                	test   %eax,%eax
  8009aa:	78 23                	js     8009cf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8009ac:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8009b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009c1:	83 ec 0c             	sub    $0xc,%esp
  8009c4:	50                   	push   %eax
  8009c5:	e8 ea 11 00 00       	call   801bb4 <fd2num>
  8009ca:	89 c2                	mov    %eax,%edx
  8009cc:	83 c4 10             	add    $0x10,%esp
}
  8009cf:	89 d0                	mov    %edx,%eax
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	56                   	push   %esi
  8009d7:	53                   	push   %ebx
  8009d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009db:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8009de:	e8 66 0b 00 00       	call   801549 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8009e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009e8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009f0:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009f5:	85 db                	test   %ebx,%ebx
  8009f7:	7e 07                	jle    800a00 <libmain+0x2d>
		binaryname = argv[0];
  8009f9:	8b 06                	mov    (%esi),%eax
  8009fb:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800a00:	83 ec 08             	sub    $0x8,%esp
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	e8 6b fc ff ff       	call   800675 <umain>

	// exit gracefully
	exit();
  800a0a:	e8 0a 00 00 00       	call   800a19 <exit>
}
  800a0f:	83 c4 10             	add    $0x10,%esp
  800a12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a1f:	e8 5b 13 00 00       	call   801d7f <close_all>
	sys_env_destroy(0);
  800a24:	83 ec 0c             	sub    $0xc,%esp
  800a27:	6a 00                	push   $0x0
  800a29:	e8 da 0a 00 00       	call   801508 <sys_env_destroy>
}
  800a2e:	83 c4 10             	add    $0x10,%esp
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a38:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a3b:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a41:	e8 03 0b 00 00       	call   801549 <sys_getenvid>
  800a46:	83 ec 0c             	sub    $0xc,%esp
  800a49:	ff 75 0c             	pushl  0xc(%ebp)
  800a4c:	ff 75 08             	pushl  0x8(%ebp)
  800a4f:	56                   	push   %esi
  800a50:	50                   	push   %eax
  800a51:	68 48 35 80 00       	push   $0x803548
  800a56:	e8 b1 00 00 00       	call   800b0c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a5b:	83 c4 18             	add    $0x18,%esp
  800a5e:	53                   	push   %ebx
  800a5f:	ff 75 10             	pushl  0x10(%ebp)
  800a62:	e8 54 00 00 00       	call   800abb <vcprintf>
	cprintf("\n");
  800a67:	c7 04 24 40 33 80 00 	movl   $0x803340,(%esp)
  800a6e:	e8 99 00 00 00       	call   800b0c <cprintf>
  800a73:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a76:	cc                   	int3   
  800a77:	eb fd                	jmp    800a76 <_panic+0x43>

00800a79 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	53                   	push   %ebx
  800a7d:	83 ec 04             	sub    $0x4,%esp
  800a80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a83:	8b 13                	mov    (%ebx),%edx
  800a85:	8d 42 01             	lea    0x1(%edx),%eax
  800a88:	89 03                	mov    %eax,(%ebx)
  800a8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a91:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a96:	75 1a                	jne    800ab2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a98:	83 ec 08             	sub    $0x8,%esp
  800a9b:	68 ff 00 00 00       	push   $0xff
  800aa0:	8d 43 08             	lea    0x8(%ebx),%eax
  800aa3:	50                   	push   %eax
  800aa4:	e8 22 0a 00 00       	call   8014cb <sys_cputs>
		b->idx = 0;
  800aa9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800aaf:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800ab2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800ab6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab9:	c9                   	leave  
  800aba:	c3                   	ret    

00800abb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800ac4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800acb:	00 00 00 
	b.cnt = 0;
  800ace:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ad5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800ad8:	ff 75 0c             	pushl  0xc(%ebp)
  800adb:	ff 75 08             	pushl  0x8(%ebp)
  800ade:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ae4:	50                   	push   %eax
  800ae5:	68 79 0a 80 00       	push   $0x800a79
  800aea:	e8 54 01 00 00       	call   800c43 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800aef:	83 c4 08             	add    $0x8,%esp
  800af2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800af8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800afe:	50                   	push   %eax
  800aff:	e8 c7 09 00 00       	call   8014cb <sys_cputs>

	return b.cnt;
}
  800b04:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b12:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b15:	50                   	push   %eax
  800b16:	ff 75 08             	pushl  0x8(%ebp)
  800b19:	e8 9d ff ff ff       	call   800abb <vcprintf>
	va_end(ap);

	return cnt;
}
  800b1e:	c9                   	leave  
  800b1f:	c3                   	ret    

00800b20 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
  800b26:	83 ec 1c             	sub    $0x1c,%esp
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	89 d6                	mov    %edx,%esi
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b33:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b36:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b39:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b41:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b44:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b47:	39 d3                	cmp    %edx,%ebx
  800b49:	72 05                	jb     800b50 <printnum+0x30>
  800b4b:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b4e:	77 45                	ja     800b95 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b50:	83 ec 0c             	sub    $0xc,%esp
  800b53:	ff 75 18             	pushl  0x18(%ebp)
  800b56:	8b 45 14             	mov    0x14(%ebp),%eax
  800b59:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b5c:	53                   	push   %ebx
  800b5d:	ff 75 10             	pushl  0x10(%ebp)
  800b60:	83 ec 08             	sub    $0x8,%esp
  800b63:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b66:	ff 75 e0             	pushl  -0x20(%ebp)
  800b69:	ff 75 dc             	pushl  -0x24(%ebp)
  800b6c:	ff 75 d8             	pushl  -0x28(%ebp)
  800b6f:	e8 0c 25 00 00       	call   803080 <__udivdi3>
  800b74:	83 c4 18             	add    $0x18,%esp
  800b77:	52                   	push   %edx
  800b78:	50                   	push   %eax
  800b79:	89 f2                	mov    %esi,%edx
  800b7b:	89 f8                	mov    %edi,%eax
  800b7d:	e8 9e ff ff ff       	call   800b20 <printnum>
  800b82:	83 c4 20             	add    $0x20,%esp
  800b85:	eb 18                	jmp    800b9f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b87:	83 ec 08             	sub    $0x8,%esp
  800b8a:	56                   	push   %esi
  800b8b:	ff 75 18             	pushl  0x18(%ebp)
  800b8e:	ff d7                	call   *%edi
  800b90:	83 c4 10             	add    $0x10,%esp
  800b93:	eb 03                	jmp    800b98 <printnum+0x78>
  800b95:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b98:	83 eb 01             	sub    $0x1,%ebx
  800b9b:	85 db                	test   %ebx,%ebx
  800b9d:	7f e8                	jg     800b87 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	56                   	push   %esi
  800ba3:	83 ec 04             	sub    $0x4,%esp
  800ba6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ba9:	ff 75 e0             	pushl  -0x20(%ebp)
  800bac:	ff 75 dc             	pushl  -0x24(%ebp)
  800baf:	ff 75 d8             	pushl  -0x28(%ebp)
  800bb2:	e8 f9 25 00 00       	call   8031b0 <__umoddi3>
  800bb7:	83 c4 14             	add    $0x14,%esp
  800bba:	0f be 80 6b 35 80 00 	movsbl 0x80356b(%eax),%eax
  800bc1:	50                   	push   %eax
  800bc2:	ff d7                	call   *%edi
}
  800bc4:	83 c4 10             	add    $0x10,%esp
  800bc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bd2:	83 fa 01             	cmp    $0x1,%edx
  800bd5:	7e 0e                	jle    800be5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bd7:	8b 10                	mov    (%eax),%edx
  800bd9:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bdc:	89 08                	mov    %ecx,(%eax)
  800bde:	8b 02                	mov    (%edx),%eax
  800be0:	8b 52 04             	mov    0x4(%edx),%edx
  800be3:	eb 22                	jmp    800c07 <getuint+0x38>
	else if (lflag)
  800be5:	85 d2                	test   %edx,%edx
  800be7:	74 10                	je     800bf9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800be9:	8b 10                	mov    (%eax),%edx
  800beb:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bee:	89 08                	mov    %ecx,(%eax)
  800bf0:	8b 02                	mov    (%edx),%eax
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf7:	eb 0e                	jmp    800c07 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bf9:	8b 10                	mov    (%eax),%edx
  800bfb:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bfe:	89 08                	mov    %ecx,(%eax)
  800c00:	8b 02                	mov    (%edx),%eax
  800c02:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c0f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c13:	8b 10                	mov    (%eax),%edx
  800c15:	3b 50 04             	cmp    0x4(%eax),%edx
  800c18:	73 0a                	jae    800c24 <sprintputch+0x1b>
		*b->buf++ = ch;
  800c1a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c1d:	89 08                	mov    %ecx,(%eax)
  800c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c22:	88 02                	mov    %al,(%edx)
}
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c2c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c2f:	50                   	push   %eax
  800c30:	ff 75 10             	pushl  0x10(%ebp)
  800c33:	ff 75 0c             	pushl  0xc(%ebp)
  800c36:	ff 75 08             	pushl  0x8(%ebp)
  800c39:	e8 05 00 00 00       	call   800c43 <vprintfmt>
	va_end(ap);
}
  800c3e:	83 c4 10             	add    $0x10,%esp
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 2c             	sub    $0x2c,%esp
  800c4c:	8b 75 08             	mov    0x8(%ebp),%esi
  800c4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c52:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c55:	eb 12                	jmp    800c69 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c57:	85 c0                	test   %eax,%eax
  800c59:	0f 84 89 03 00 00    	je     800fe8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800c5f:	83 ec 08             	sub    $0x8,%esp
  800c62:	53                   	push   %ebx
  800c63:	50                   	push   %eax
  800c64:	ff d6                	call   *%esi
  800c66:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c69:	83 c7 01             	add    $0x1,%edi
  800c6c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c70:	83 f8 25             	cmp    $0x25,%eax
  800c73:	75 e2                	jne    800c57 <vprintfmt+0x14>
  800c75:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c79:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c80:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c87:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c93:	eb 07                	jmp    800c9c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c95:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c98:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c9c:	8d 47 01             	lea    0x1(%edi),%eax
  800c9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ca2:	0f b6 07             	movzbl (%edi),%eax
  800ca5:	0f b6 c8             	movzbl %al,%ecx
  800ca8:	83 e8 23             	sub    $0x23,%eax
  800cab:	3c 55                	cmp    $0x55,%al
  800cad:	0f 87 1a 03 00 00    	ja     800fcd <vprintfmt+0x38a>
  800cb3:	0f b6 c0             	movzbl %al,%eax
  800cb6:	ff 24 85 a0 36 80 00 	jmp    *0x8036a0(,%eax,4)
  800cbd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cc0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800cc4:	eb d6                	jmp    800c9c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cc6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cd1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cd4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800cd8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800cdb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800cde:	83 fa 09             	cmp    $0x9,%edx
  800ce1:	77 39                	ja     800d1c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ce3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ce6:	eb e9                	jmp    800cd1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800ce8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ceb:	8d 48 04             	lea    0x4(%eax),%ecx
  800cee:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800cf1:	8b 00                	mov    (%eax),%eax
  800cf3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cf6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800cf9:	eb 27                	jmp    800d22 <vprintfmt+0xdf>
  800cfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d05:	0f 49 c8             	cmovns %eax,%ecx
  800d08:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d0b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d0e:	eb 8c                	jmp    800c9c <vprintfmt+0x59>
  800d10:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d13:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800d1a:	eb 80                	jmp    800c9c <vprintfmt+0x59>
  800d1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d1f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d22:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d26:	0f 89 70 ff ff ff    	jns    800c9c <vprintfmt+0x59>
				width = precision, precision = -1;
  800d2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d32:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d39:	e9 5e ff ff ff       	jmp    800c9c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d3e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d44:	e9 53 ff ff ff       	jmp    800c9c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d49:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4c:	8d 50 04             	lea    0x4(%eax),%edx
  800d4f:	89 55 14             	mov    %edx,0x14(%ebp)
  800d52:	83 ec 08             	sub    $0x8,%esp
  800d55:	53                   	push   %ebx
  800d56:	ff 30                	pushl  (%eax)
  800d58:	ff d6                	call   *%esi
			break;
  800d5a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d60:	e9 04 ff ff ff       	jmp    800c69 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d65:	8b 45 14             	mov    0x14(%ebp),%eax
  800d68:	8d 50 04             	lea    0x4(%eax),%edx
  800d6b:	89 55 14             	mov    %edx,0x14(%ebp)
  800d6e:	8b 00                	mov    (%eax),%eax
  800d70:	99                   	cltd   
  800d71:	31 d0                	xor    %edx,%eax
  800d73:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d75:	83 f8 0f             	cmp    $0xf,%eax
  800d78:	7f 0b                	jg     800d85 <vprintfmt+0x142>
  800d7a:	8b 14 85 00 38 80 00 	mov    0x803800(,%eax,4),%edx
  800d81:	85 d2                	test   %edx,%edx
  800d83:	75 18                	jne    800d9d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d85:	50                   	push   %eax
  800d86:	68 83 35 80 00       	push   $0x803583
  800d8b:	53                   	push   %ebx
  800d8c:	56                   	push   %esi
  800d8d:	e8 94 fe ff ff       	call   800c26 <printfmt>
  800d92:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d98:	e9 cc fe ff ff       	jmp    800c69 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d9d:	52                   	push   %edx
  800d9e:	68 89 34 80 00       	push   $0x803489
  800da3:	53                   	push   %ebx
  800da4:	56                   	push   %esi
  800da5:	e8 7c fe ff ff       	call   800c26 <printfmt>
  800daa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800db0:	e9 b4 fe ff ff       	jmp    800c69 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800db5:	8b 45 14             	mov    0x14(%ebp),%eax
  800db8:	8d 50 04             	lea    0x4(%eax),%edx
  800dbb:	89 55 14             	mov    %edx,0x14(%ebp)
  800dbe:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800dc0:	85 ff                	test   %edi,%edi
  800dc2:	b8 7c 35 80 00       	mov    $0x80357c,%eax
  800dc7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800dca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dce:	0f 8e 94 00 00 00    	jle    800e68 <vprintfmt+0x225>
  800dd4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800dd8:	0f 84 98 00 00 00    	je     800e76 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dde:	83 ec 08             	sub    $0x8,%esp
  800de1:	ff 75 d0             	pushl  -0x30(%ebp)
  800de4:	57                   	push   %edi
  800de5:	e8 79 03 00 00       	call   801163 <strnlen>
  800dea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ded:	29 c1                	sub    %eax,%ecx
  800def:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800df2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800df5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800df9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800dfc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800dff:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e01:	eb 0f                	jmp    800e12 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800e03:	83 ec 08             	sub    $0x8,%esp
  800e06:	53                   	push   %ebx
  800e07:	ff 75 e0             	pushl  -0x20(%ebp)
  800e0a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e0c:	83 ef 01             	sub    $0x1,%edi
  800e0f:	83 c4 10             	add    $0x10,%esp
  800e12:	85 ff                	test   %edi,%edi
  800e14:	7f ed                	jg     800e03 <vprintfmt+0x1c0>
  800e16:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800e19:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e1c:	85 c9                	test   %ecx,%ecx
  800e1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e23:	0f 49 c1             	cmovns %ecx,%eax
  800e26:	29 c1                	sub    %eax,%ecx
  800e28:	89 75 08             	mov    %esi,0x8(%ebp)
  800e2b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e2e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e31:	89 cb                	mov    %ecx,%ebx
  800e33:	eb 4d                	jmp    800e82 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e35:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e39:	74 1b                	je     800e56 <vprintfmt+0x213>
  800e3b:	0f be c0             	movsbl %al,%eax
  800e3e:	83 e8 20             	sub    $0x20,%eax
  800e41:	83 f8 5e             	cmp    $0x5e,%eax
  800e44:	76 10                	jbe    800e56 <vprintfmt+0x213>
					putch('?', putdat);
  800e46:	83 ec 08             	sub    $0x8,%esp
  800e49:	ff 75 0c             	pushl  0xc(%ebp)
  800e4c:	6a 3f                	push   $0x3f
  800e4e:	ff 55 08             	call   *0x8(%ebp)
  800e51:	83 c4 10             	add    $0x10,%esp
  800e54:	eb 0d                	jmp    800e63 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800e56:	83 ec 08             	sub    $0x8,%esp
  800e59:	ff 75 0c             	pushl  0xc(%ebp)
  800e5c:	52                   	push   %edx
  800e5d:	ff 55 08             	call   *0x8(%ebp)
  800e60:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e63:	83 eb 01             	sub    $0x1,%ebx
  800e66:	eb 1a                	jmp    800e82 <vprintfmt+0x23f>
  800e68:	89 75 08             	mov    %esi,0x8(%ebp)
  800e6b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e6e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e71:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e74:	eb 0c                	jmp    800e82 <vprintfmt+0x23f>
  800e76:	89 75 08             	mov    %esi,0x8(%ebp)
  800e79:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e7c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e7f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e82:	83 c7 01             	add    $0x1,%edi
  800e85:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e89:	0f be d0             	movsbl %al,%edx
  800e8c:	85 d2                	test   %edx,%edx
  800e8e:	74 23                	je     800eb3 <vprintfmt+0x270>
  800e90:	85 f6                	test   %esi,%esi
  800e92:	78 a1                	js     800e35 <vprintfmt+0x1f2>
  800e94:	83 ee 01             	sub    $0x1,%esi
  800e97:	79 9c                	jns    800e35 <vprintfmt+0x1f2>
  800e99:	89 df                	mov    %ebx,%edi
  800e9b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ea1:	eb 18                	jmp    800ebb <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ea3:	83 ec 08             	sub    $0x8,%esp
  800ea6:	53                   	push   %ebx
  800ea7:	6a 20                	push   $0x20
  800ea9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800eab:	83 ef 01             	sub    $0x1,%edi
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	eb 08                	jmp    800ebb <vprintfmt+0x278>
  800eb3:	89 df                	mov    %ebx,%edi
  800eb5:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ebb:	85 ff                	test   %edi,%edi
  800ebd:	7f e4                	jg     800ea3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ebf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ec2:	e9 a2 fd ff ff       	jmp    800c69 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ec7:	83 fa 01             	cmp    $0x1,%edx
  800eca:	7e 16                	jle    800ee2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800ecc:	8b 45 14             	mov    0x14(%ebp),%eax
  800ecf:	8d 50 08             	lea    0x8(%eax),%edx
  800ed2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ed5:	8b 50 04             	mov    0x4(%eax),%edx
  800ed8:	8b 00                	mov    (%eax),%eax
  800eda:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800edd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ee0:	eb 32                	jmp    800f14 <vprintfmt+0x2d1>
	else if (lflag)
  800ee2:	85 d2                	test   %edx,%edx
  800ee4:	74 18                	je     800efe <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800ee6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee9:	8d 50 04             	lea    0x4(%eax),%edx
  800eec:	89 55 14             	mov    %edx,0x14(%ebp)
  800eef:	8b 00                	mov    (%eax),%eax
  800ef1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ef4:	89 c1                	mov    %eax,%ecx
  800ef6:	c1 f9 1f             	sar    $0x1f,%ecx
  800ef9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800efc:	eb 16                	jmp    800f14 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800efe:	8b 45 14             	mov    0x14(%ebp),%eax
  800f01:	8d 50 04             	lea    0x4(%eax),%edx
  800f04:	89 55 14             	mov    %edx,0x14(%ebp)
  800f07:	8b 00                	mov    (%eax),%eax
  800f09:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f0c:	89 c1                	mov    %eax,%ecx
  800f0e:	c1 f9 1f             	sar    $0x1f,%ecx
  800f11:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800f14:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f17:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f1a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f1f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f23:	79 74                	jns    800f99 <vprintfmt+0x356>
				putch('-', putdat);
  800f25:	83 ec 08             	sub    $0x8,%esp
  800f28:	53                   	push   %ebx
  800f29:	6a 2d                	push   $0x2d
  800f2b:	ff d6                	call   *%esi
				num = -(long long) num;
  800f2d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f30:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f33:	f7 d8                	neg    %eax
  800f35:	83 d2 00             	adc    $0x0,%edx
  800f38:	f7 da                	neg    %edx
  800f3a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f3d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f42:	eb 55                	jmp    800f99 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f44:	8d 45 14             	lea    0x14(%ebp),%eax
  800f47:	e8 83 fc ff ff       	call   800bcf <getuint>
			base = 10;
  800f4c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f51:	eb 46                	jmp    800f99 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800f53:	8d 45 14             	lea    0x14(%ebp),%eax
  800f56:	e8 74 fc ff ff       	call   800bcf <getuint>
			base = 8;
  800f5b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800f60:	eb 37                	jmp    800f99 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800f62:	83 ec 08             	sub    $0x8,%esp
  800f65:	53                   	push   %ebx
  800f66:	6a 30                	push   $0x30
  800f68:	ff d6                	call   *%esi
			putch('x', putdat);
  800f6a:	83 c4 08             	add    $0x8,%esp
  800f6d:	53                   	push   %ebx
  800f6e:	6a 78                	push   $0x78
  800f70:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f72:	8b 45 14             	mov    0x14(%ebp),%eax
  800f75:	8d 50 04             	lea    0x4(%eax),%edx
  800f78:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f7b:	8b 00                	mov    (%eax),%eax
  800f7d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f82:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f85:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f8a:	eb 0d                	jmp    800f99 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f8c:	8d 45 14             	lea    0x14(%ebp),%eax
  800f8f:	e8 3b fc ff ff       	call   800bcf <getuint>
			base = 16;
  800f94:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800fa0:	57                   	push   %edi
  800fa1:	ff 75 e0             	pushl  -0x20(%ebp)
  800fa4:	51                   	push   %ecx
  800fa5:	52                   	push   %edx
  800fa6:	50                   	push   %eax
  800fa7:	89 da                	mov    %ebx,%edx
  800fa9:	89 f0                	mov    %esi,%eax
  800fab:	e8 70 fb ff ff       	call   800b20 <printnum>
			break;
  800fb0:	83 c4 20             	add    $0x20,%esp
  800fb3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fb6:	e9 ae fc ff ff       	jmp    800c69 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	53                   	push   %ebx
  800fbf:	51                   	push   %ecx
  800fc0:	ff d6                	call   *%esi
			break;
  800fc2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fc8:	e9 9c fc ff ff       	jmp    800c69 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	53                   	push   %ebx
  800fd1:	6a 25                	push   $0x25
  800fd3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	eb 03                	jmp    800fdd <vprintfmt+0x39a>
  800fda:	83 ef 01             	sub    $0x1,%edi
  800fdd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fe1:	75 f7                	jne    800fda <vprintfmt+0x397>
  800fe3:	e9 81 fc ff ff       	jmp    800c69 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 18             	sub    $0x18,%esp
  800ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ffc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801003:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801006:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	74 26                	je     801037 <vsnprintf+0x47>
  801011:	85 d2                	test   %edx,%edx
  801013:	7e 22                	jle    801037 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801015:	ff 75 14             	pushl  0x14(%ebp)
  801018:	ff 75 10             	pushl  0x10(%ebp)
  80101b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80101e:	50                   	push   %eax
  80101f:	68 09 0c 80 00       	push   $0x800c09
  801024:	e8 1a fc ff ff       	call   800c43 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801029:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80102c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80102f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	eb 05                	jmp    80103c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801037:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80103c:	c9                   	leave  
  80103d:	c3                   	ret    

0080103e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801044:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801047:	50                   	push   %eax
  801048:	ff 75 10             	pushl  0x10(%ebp)
  80104b:	ff 75 0c             	pushl  0xc(%ebp)
  80104e:	ff 75 08             	pushl  0x8(%ebp)
  801051:	e8 9a ff ff ff       	call   800ff0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801064:	85 c0                	test   %eax,%eax
  801066:	74 13                	je     80107b <readline+0x23>
		fprintf(1, "%s", prompt);
  801068:	83 ec 04             	sub    $0x4,%esp
  80106b:	50                   	push   %eax
  80106c:	68 89 34 80 00       	push   $0x803489
  801071:	6a 01                	push   $0x1
  801073:	e8 73 14 00 00       	call   8024eb <fprintf>
  801078:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	6a 00                	push   $0x0
  801080:	e8 c8 f8 ff ff       	call   80094d <iscons>
  801085:	89 c7                	mov    %eax,%edi
  801087:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80108a:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  80108f:	e8 8e f8 ff ff       	call   800922 <getchar>
  801094:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801096:	85 c0                	test   %eax,%eax
  801098:	79 29                	jns    8010c3 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80109a:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  80109f:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8010a2:	0f 84 9b 00 00 00    	je     801143 <readline+0xeb>
				cprintf("read error: %e\n", c);
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	53                   	push   %ebx
  8010ac:	68 5f 38 80 00       	push   $0x80385f
  8010b1:	e8 56 fa ff ff       	call   800b0c <cprintf>
  8010b6:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010be:	e9 80 00 00 00       	jmp    801143 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010c3:	83 f8 08             	cmp    $0x8,%eax
  8010c6:	0f 94 c2             	sete   %dl
  8010c9:	83 f8 7f             	cmp    $0x7f,%eax
  8010cc:	0f 94 c0             	sete   %al
  8010cf:	08 c2                	or     %al,%dl
  8010d1:	74 1a                	je     8010ed <readline+0x95>
  8010d3:	85 f6                	test   %esi,%esi
  8010d5:	7e 16                	jle    8010ed <readline+0x95>
			if (echoing)
  8010d7:	85 ff                	test   %edi,%edi
  8010d9:	74 0d                	je     8010e8 <readline+0x90>
				cputchar('\b');
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	6a 08                	push   $0x8
  8010e0:	e8 21 f8 ff ff       	call   800906 <cputchar>
  8010e5:	83 c4 10             	add    $0x10,%esp
			i--;
  8010e8:	83 ee 01             	sub    $0x1,%esi
  8010eb:	eb a2                	jmp    80108f <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010ed:	83 fb 1f             	cmp    $0x1f,%ebx
  8010f0:	7e 26                	jle    801118 <readline+0xc0>
  8010f2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010f8:	7f 1e                	jg     801118 <readline+0xc0>
			if (echoing)
  8010fa:	85 ff                	test   %edi,%edi
  8010fc:	74 0c                	je     80110a <readline+0xb2>
				cputchar(c);
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	53                   	push   %ebx
  801102:	e8 ff f7 ff ff       	call   800906 <cputchar>
  801107:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  80110a:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801110:	8d 76 01             	lea    0x1(%esi),%esi
  801113:	e9 77 ff ff ff       	jmp    80108f <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801118:	83 fb 0a             	cmp    $0xa,%ebx
  80111b:	74 09                	je     801126 <readline+0xce>
  80111d:	83 fb 0d             	cmp    $0xd,%ebx
  801120:	0f 85 69 ff ff ff    	jne    80108f <readline+0x37>
			if (echoing)
  801126:	85 ff                	test   %edi,%edi
  801128:	74 0d                	je     801137 <readline+0xdf>
				cputchar('\n');
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	6a 0a                	push   $0xa
  80112f:	e8 d2 f7 ff ff       	call   800906 <cputchar>
  801134:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801137:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80113e:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  801143:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801146:	5b                   	pop    %ebx
  801147:	5e                   	pop    %esi
  801148:	5f                   	pop    %edi
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801151:	b8 00 00 00 00       	mov    $0x0,%eax
  801156:	eb 03                	jmp    80115b <strlen+0x10>
		n++;
  801158:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80115b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80115f:	75 f7                	jne    801158 <strlen+0xd>
		n++;
	return n;
}
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801169:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80116c:	ba 00 00 00 00       	mov    $0x0,%edx
  801171:	eb 03                	jmp    801176 <strnlen+0x13>
		n++;
  801173:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801176:	39 c2                	cmp    %eax,%edx
  801178:	74 08                	je     801182 <strnlen+0x1f>
  80117a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80117e:	75 f3                	jne    801173 <strnlen+0x10>
  801180:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	53                   	push   %ebx
  801188:	8b 45 08             	mov    0x8(%ebp),%eax
  80118b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80118e:	89 c2                	mov    %eax,%edx
  801190:	83 c2 01             	add    $0x1,%edx
  801193:	83 c1 01             	add    $0x1,%ecx
  801196:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80119a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80119d:	84 db                	test   %bl,%bl
  80119f:	75 ef                	jne    801190 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8011a1:	5b                   	pop    %ebx
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	53                   	push   %ebx
  8011a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011ab:	53                   	push   %ebx
  8011ac:	e8 9a ff ff ff       	call   80114b <strlen>
  8011b1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8011b4:	ff 75 0c             	pushl  0xc(%ebp)
  8011b7:	01 d8                	add    %ebx,%eax
  8011b9:	50                   	push   %eax
  8011ba:	e8 c5 ff ff ff       	call   801184 <strcpy>
	return dst;
}
  8011bf:	89 d8                	mov    %ebx,%eax
  8011c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c4:	c9                   	leave  
  8011c5:	c3                   	ret    

008011c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	56                   	push   %esi
  8011ca:	53                   	push   %ebx
  8011cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d1:	89 f3                	mov    %esi,%ebx
  8011d3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011d6:	89 f2                	mov    %esi,%edx
  8011d8:	eb 0f                	jmp    8011e9 <strncpy+0x23>
		*dst++ = *src;
  8011da:	83 c2 01             	add    $0x1,%edx
  8011dd:	0f b6 01             	movzbl (%ecx),%eax
  8011e0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011e3:	80 39 01             	cmpb   $0x1,(%ecx)
  8011e6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011e9:	39 da                	cmp    %ebx,%edx
  8011eb:	75 ed                	jne    8011da <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011ed:	89 f0                	mov    %esi,%eax
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fe:	8b 55 10             	mov    0x10(%ebp),%edx
  801201:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801203:	85 d2                	test   %edx,%edx
  801205:	74 21                	je     801228 <strlcpy+0x35>
  801207:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80120b:	89 f2                	mov    %esi,%edx
  80120d:	eb 09                	jmp    801218 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80120f:	83 c2 01             	add    $0x1,%edx
  801212:	83 c1 01             	add    $0x1,%ecx
  801215:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801218:	39 c2                	cmp    %eax,%edx
  80121a:	74 09                	je     801225 <strlcpy+0x32>
  80121c:	0f b6 19             	movzbl (%ecx),%ebx
  80121f:	84 db                	test   %bl,%bl
  801221:	75 ec                	jne    80120f <strlcpy+0x1c>
  801223:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801225:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801228:	29 f0                	sub    %esi,%eax
}
  80122a:	5b                   	pop    %ebx
  80122b:	5e                   	pop    %esi
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801234:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801237:	eb 06                	jmp    80123f <strcmp+0x11>
		p++, q++;
  801239:	83 c1 01             	add    $0x1,%ecx
  80123c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80123f:	0f b6 01             	movzbl (%ecx),%eax
  801242:	84 c0                	test   %al,%al
  801244:	74 04                	je     80124a <strcmp+0x1c>
  801246:	3a 02                	cmp    (%edx),%al
  801248:	74 ef                	je     801239 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80124a:	0f b6 c0             	movzbl %al,%eax
  80124d:	0f b6 12             	movzbl (%edx),%edx
  801250:	29 d0                	sub    %edx,%eax
}
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	53                   	push   %ebx
  801258:	8b 45 08             	mov    0x8(%ebp),%eax
  80125b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125e:	89 c3                	mov    %eax,%ebx
  801260:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801263:	eb 06                	jmp    80126b <strncmp+0x17>
		n--, p++, q++;
  801265:	83 c0 01             	add    $0x1,%eax
  801268:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80126b:	39 d8                	cmp    %ebx,%eax
  80126d:	74 15                	je     801284 <strncmp+0x30>
  80126f:	0f b6 08             	movzbl (%eax),%ecx
  801272:	84 c9                	test   %cl,%cl
  801274:	74 04                	je     80127a <strncmp+0x26>
  801276:	3a 0a                	cmp    (%edx),%cl
  801278:	74 eb                	je     801265 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80127a:	0f b6 00             	movzbl (%eax),%eax
  80127d:	0f b6 12             	movzbl (%edx),%edx
  801280:	29 d0                	sub    %edx,%eax
  801282:	eb 05                	jmp    801289 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801284:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801289:	5b                   	pop    %ebx
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	8b 45 08             	mov    0x8(%ebp),%eax
  801292:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801296:	eb 07                	jmp    80129f <strchr+0x13>
		if (*s == c)
  801298:	38 ca                	cmp    %cl,%dl
  80129a:	74 0f                	je     8012ab <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80129c:	83 c0 01             	add    $0x1,%eax
  80129f:	0f b6 10             	movzbl (%eax),%edx
  8012a2:	84 d2                	test   %dl,%dl
  8012a4:	75 f2                	jne    801298 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8012a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012b7:	eb 03                	jmp    8012bc <strfind+0xf>
  8012b9:	83 c0 01             	add    $0x1,%eax
  8012bc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012bf:	38 ca                	cmp    %cl,%dl
  8012c1:	74 04                	je     8012c7 <strfind+0x1a>
  8012c3:	84 d2                	test   %dl,%dl
  8012c5:	75 f2                	jne    8012b9 <strfind+0xc>
			break;
	return (char *) s;
}
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012d5:	85 c9                	test   %ecx,%ecx
  8012d7:	74 36                	je     80130f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012df:	75 28                	jne    801309 <memset+0x40>
  8012e1:	f6 c1 03             	test   $0x3,%cl
  8012e4:	75 23                	jne    801309 <memset+0x40>
		c &= 0xFF;
  8012e6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012ea:	89 d3                	mov    %edx,%ebx
  8012ec:	c1 e3 08             	shl    $0x8,%ebx
  8012ef:	89 d6                	mov    %edx,%esi
  8012f1:	c1 e6 18             	shl    $0x18,%esi
  8012f4:	89 d0                	mov    %edx,%eax
  8012f6:	c1 e0 10             	shl    $0x10,%eax
  8012f9:	09 f0                	or     %esi,%eax
  8012fb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8012fd:	89 d8                	mov    %ebx,%eax
  8012ff:	09 d0                	or     %edx,%eax
  801301:	c1 e9 02             	shr    $0x2,%ecx
  801304:	fc                   	cld    
  801305:	f3 ab                	rep stos %eax,%es:(%edi)
  801307:	eb 06                	jmp    80130f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801309:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130c:	fc                   	cld    
  80130d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80130f:	89 f8                	mov    %edi,%eax
  801311:	5b                   	pop    %ebx
  801312:	5e                   	pop    %esi
  801313:	5f                   	pop    %edi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	57                   	push   %edi
  80131a:	56                   	push   %esi
  80131b:	8b 45 08             	mov    0x8(%ebp),%eax
  80131e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801321:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801324:	39 c6                	cmp    %eax,%esi
  801326:	73 35                	jae    80135d <memmove+0x47>
  801328:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80132b:	39 d0                	cmp    %edx,%eax
  80132d:	73 2e                	jae    80135d <memmove+0x47>
		s += n;
		d += n;
  80132f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801332:	89 d6                	mov    %edx,%esi
  801334:	09 fe                	or     %edi,%esi
  801336:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80133c:	75 13                	jne    801351 <memmove+0x3b>
  80133e:	f6 c1 03             	test   $0x3,%cl
  801341:	75 0e                	jne    801351 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801343:	83 ef 04             	sub    $0x4,%edi
  801346:	8d 72 fc             	lea    -0x4(%edx),%esi
  801349:	c1 e9 02             	shr    $0x2,%ecx
  80134c:	fd                   	std    
  80134d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80134f:	eb 09                	jmp    80135a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801351:	83 ef 01             	sub    $0x1,%edi
  801354:	8d 72 ff             	lea    -0x1(%edx),%esi
  801357:	fd                   	std    
  801358:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80135a:	fc                   	cld    
  80135b:	eb 1d                	jmp    80137a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80135d:	89 f2                	mov    %esi,%edx
  80135f:	09 c2                	or     %eax,%edx
  801361:	f6 c2 03             	test   $0x3,%dl
  801364:	75 0f                	jne    801375 <memmove+0x5f>
  801366:	f6 c1 03             	test   $0x3,%cl
  801369:	75 0a                	jne    801375 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80136b:	c1 e9 02             	shr    $0x2,%ecx
  80136e:	89 c7                	mov    %eax,%edi
  801370:	fc                   	cld    
  801371:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801373:	eb 05                	jmp    80137a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801375:	89 c7                	mov    %eax,%edi
  801377:	fc                   	cld    
  801378:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80137a:	5e                   	pop    %esi
  80137b:	5f                   	pop    %edi
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    

0080137e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801381:	ff 75 10             	pushl  0x10(%ebp)
  801384:	ff 75 0c             	pushl  0xc(%ebp)
  801387:	ff 75 08             	pushl  0x8(%ebp)
  80138a:	e8 87 ff ff ff       	call   801316 <memmove>
}
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	56                   	push   %esi
  801395:	53                   	push   %ebx
  801396:	8b 45 08             	mov    0x8(%ebp),%eax
  801399:	8b 55 0c             	mov    0xc(%ebp),%edx
  80139c:	89 c6                	mov    %eax,%esi
  80139e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013a1:	eb 1a                	jmp    8013bd <memcmp+0x2c>
		if (*s1 != *s2)
  8013a3:	0f b6 08             	movzbl (%eax),%ecx
  8013a6:	0f b6 1a             	movzbl (%edx),%ebx
  8013a9:	38 d9                	cmp    %bl,%cl
  8013ab:	74 0a                	je     8013b7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8013ad:	0f b6 c1             	movzbl %cl,%eax
  8013b0:	0f b6 db             	movzbl %bl,%ebx
  8013b3:	29 d8                	sub    %ebx,%eax
  8013b5:	eb 0f                	jmp    8013c6 <memcmp+0x35>
		s1++, s2++;
  8013b7:	83 c0 01             	add    $0x1,%eax
  8013ba:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013bd:	39 f0                	cmp    %esi,%eax
  8013bf:	75 e2                	jne    8013a3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	53                   	push   %ebx
  8013ce:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013d1:	89 c1                	mov    %eax,%ecx
  8013d3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8013d6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013da:	eb 0a                	jmp    8013e6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013dc:	0f b6 10             	movzbl (%eax),%edx
  8013df:	39 da                	cmp    %ebx,%edx
  8013e1:	74 07                	je     8013ea <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013e3:	83 c0 01             	add    $0x1,%eax
  8013e6:	39 c8                	cmp    %ecx,%eax
  8013e8:	72 f2                	jb     8013dc <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013ea:	5b                   	pop    %ebx
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	57                   	push   %edi
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013f9:	eb 03                	jmp    8013fe <strtol+0x11>
		s++;
  8013fb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013fe:	0f b6 01             	movzbl (%ecx),%eax
  801401:	3c 20                	cmp    $0x20,%al
  801403:	74 f6                	je     8013fb <strtol+0xe>
  801405:	3c 09                	cmp    $0x9,%al
  801407:	74 f2                	je     8013fb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801409:	3c 2b                	cmp    $0x2b,%al
  80140b:	75 0a                	jne    801417 <strtol+0x2a>
		s++;
  80140d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801410:	bf 00 00 00 00       	mov    $0x0,%edi
  801415:	eb 11                	jmp    801428 <strtol+0x3b>
  801417:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80141c:	3c 2d                	cmp    $0x2d,%al
  80141e:	75 08                	jne    801428 <strtol+0x3b>
		s++, neg = 1;
  801420:	83 c1 01             	add    $0x1,%ecx
  801423:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801428:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80142e:	75 15                	jne    801445 <strtol+0x58>
  801430:	80 39 30             	cmpb   $0x30,(%ecx)
  801433:	75 10                	jne    801445 <strtol+0x58>
  801435:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801439:	75 7c                	jne    8014b7 <strtol+0xca>
		s += 2, base = 16;
  80143b:	83 c1 02             	add    $0x2,%ecx
  80143e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801443:	eb 16                	jmp    80145b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801445:	85 db                	test   %ebx,%ebx
  801447:	75 12                	jne    80145b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801449:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80144e:	80 39 30             	cmpb   $0x30,(%ecx)
  801451:	75 08                	jne    80145b <strtol+0x6e>
		s++, base = 8;
  801453:	83 c1 01             	add    $0x1,%ecx
  801456:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80145b:	b8 00 00 00 00       	mov    $0x0,%eax
  801460:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801463:	0f b6 11             	movzbl (%ecx),%edx
  801466:	8d 72 d0             	lea    -0x30(%edx),%esi
  801469:	89 f3                	mov    %esi,%ebx
  80146b:	80 fb 09             	cmp    $0x9,%bl
  80146e:	77 08                	ja     801478 <strtol+0x8b>
			dig = *s - '0';
  801470:	0f be d2             	movsbl %dl,%edx
  801473:	83 ea 30             	sub    $0x30,%edx
  801476:	eb 22                	jmp    80149a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801478:	8d 72 9f             	lea    -0x61(%edx),%esi
  80147b:	89 f3                	mov    %esi,%ebx
  80147d:	80 fb 19             	cmp    $0x19,%bl
  801480:	77 08                	ja     80148a <strtol+0x9d>
			dig = *s - 'a' + 10;
  801482:	0f be d2             	movsbl %dl,%edx
  801485:	83 ea 57             	sub    $0x57,%edx
  801488:	eb 10                	jmp    80149a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80148a:	8d 72 bf             	lea    -0x41(%edx),%esi
  80148d:	89 f3                	mov    %esi,%ebx
  80148f:	80 fb 19             	cmp    $0x19,%bl
  801492:	77 16                	ja     8014aa <strtol+0xbd>
			dig = *s - 'A' + 10;
  801494:	0f be d2             	movsbl %dl,%edx
  801497:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80149a:	3b 55 10             	cmp    0x10(%ebp),%edx
  80149d:	7d 0b                	jge    8014aa <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80149f:	83 c1 01             	add    $0x1,%ecx
  8014a2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8014a6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8014a8:	eb b9                	jmp    801463 <strtol+0x76>

	if (endptr)
  8014aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014ae:	74 0d                	je     8014bd <strtol+0xd0>
		*endptr = (char *) s;
  8014b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014b3:	89 0e                	mov    %ecx,(%esi)
  8014b5:	eb 06                	jmp    8014bd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014b7:	85 db                	test   %ebx,%ebx
  8014b9:	74 98                	je     801453 <strtol+0x66>
  8014bb:	eb 9e                	jmp    80145b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8014bd:	89 c2                	mov    %eax,%edx
  8014bf:	f7 da                	neg    %edx
  8014c1:	85 ff                	test   %edi,%edi
  8014c3:	0f 45 c2             	cmovne %edx,%eax
}
  8014c6:	5b                   	pop    %ebx
  8014c7:	5e                   	pop    %esi
  8014c8:	5f                   	pop    %edi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	57                   	push   %edi
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014dc:	89 c3                	mov    %eax,%ebx
  8014de:	89 c7                	mov    %eax,%edi
  8014e0:	89 c6                	mov    %eax,%esi
  8014e2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014e4:	5b                   	pop    %ebx
  8014e5:	5e                   	pop    %esi
  8014e6:	5f                   	pop    %edi
  8014e7:	5d                   	pop    %ebp
  8014e8:	c3                   	ret    

008014e9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	57                   	push   %edi
  8014ed:	56                   	push   %esi
  8014ee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f9:	89 d1                	mov    %edx,%ecx
  8014fb:	89 d3                	mov    %edx,%ebx
  8014fd:	89 d7                	mov    %edx,%edi
  8014ff:	89 d6                	mov    %edx,%esi
  801501:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801503:	5b                   	pop    %ebx
  801504:	5e                   	pop    %esi
  801505:	5f                   	pop    %edi
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    

00801508 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	57                   	push   %edi
  80150c:	56                   	push   %esi
  80150d:	53                   	push   %ebx
  80150e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801511:	b9 00 00 00 00       	mov    $0x0,%ecx
  801516:	b8 03 00 00 00       	mov    $0x3,%eax
  80151b:	8b 55 08             	mov    0x8(%ebp),%edx
  80151e:	89 cb                	mov    %ecx,%ebx
  801520:	89 cf                	mov    %ecx,%edi
  801522:	89 ce                	mov    %ecx,%esi
  801524:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801526:	85 c0                	test   %eax,%eax
  801528:	7e 17                	jle    801541 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	50                   	push   %eax
  80152e:	6a 03                	push   $0x3
  801530:	68 6f 38 80 00       	push   $0x80386f
  801535:	6a 23                	push   $0x23
  801537:	68 8c 38 80 00       	push   $0x80388c
  80153c:	e8 f2 f4 ff ff       	call   800a33 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801541:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801544:	5b                   	pop    %ebx
  801545:	5e                   	pop    %esi
  801546:	5f                   	pop    %edi
  801547:	5d                   	pop    %ebp
  801548:	c3                   	ret    

00801549 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	57                   	push   %edi
  80154d:	56                   	push   %esi
  80154e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
  801554:	b8 02 00 00 00       	mov    $0x2,%eax
  801559:	89 d1                	mov    %edx,%ecx
  80155b:	89 d3                	mov    %edx,%ebx
  80155d:	89 d7                	mov    %edx,%edi
  80155f:	89 d6                	mov    %edx,%esi
  801561:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801563:	5b                   	pop    %ebx
  801564:	5e                   	pop    %esi
  801565:	5f                   	pop    %edi
  801566:	5d                   	pop    %ebp
  801567:	c3                   	ret    

00801568 <sys_yield>:

void
sys_yield(void)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	57                   	push   %edi
  80156c:	56                   	push   %esi
  80156d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80156e:	ba 00 00 00 00       	mov    $0x0,%edx
  801573:	b8 0b 00 00 00       	mov    $0xb,%eax
  801578:	89 d1                	mov    %edx,%ecx
  80157a:	89 d3                	mov    %edx,%ebx
  80157c:	89 d7                	mov    %edx,%edi
  80157e:	89 d6                	mov    %edx,%esi
  801580:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801582:	5b                   	pop    %ebx
  801583:	5e                   	pop    %esi
  801584:	5f                   	pop    %edi
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    

00801587 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	57                   	push   %edi
  80158b:	56                   	push   %esi
  80158c:	53                   	push   %ebx
  80158d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801590:	be 00 00 00 00       	mov    $0x0,%esi
  801595:	b8 04 00 00 00       	mov    $0x4,%eax
  80159a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80159d:	8b 55 08             	mov    0x8(%ebp),%edx
  8015a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015a3:	89 f7                	mov    %esi,%edi
  8015a5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	7e 17                	jle    8015c2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015ab:	83 ec 0c             	sub    $0xc,%esp
  8015ae:	50                   	push   %eax
  8015af:	6a 04                	push   $0x4
  8015b1:	68 6f 38 80 00       	push   $0x80386f
  8015b6:	6a 23                	push   $0x23
  8015b8:	68 8c 38 80 00       	push   $0x80388c
  8015bd:	e8 71 f4 ff ff       	call   800a33 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c5:	5b                   	pop    %ebx
  8015c6:	5e                   	pop    %esi
  8015c7:	5f                   	pop    %edi
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    

008015ca <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	57                   	push   %edi
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8015d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015db:	8b 55 08             	mov    0x8(%ebp),%edx
  8015de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015e1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015e4:	8b 75 18             	mov    0x18(%ebp),%esi
  8015e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	7e 17                	jle    801604 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	50                   	push   %eax
  8015f1:	6a 05                	push   $0x5
  8015f3:	68 6f 38 80 00       	push   $0x80386f
  8015f8:	6a 23                	push   $0x23
  8015fa:	68 8c 38 80 00       	push   $0x80388c
  8015ff:	e8 2f f4 ff ff       	call   800a33 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801604:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801607:	5b                   	pop    %ebx
  801608:	5e                   	pop    %esi
  801609:	5f                   	pop    %edi
  80160a:	5d                   	pop    %ebp
  80160b:	c3                   	ret    

0080160c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	57                   	push   %edi
  801610:	56                   	push   %esi
  801611:	53                   	push   %ebx
  801612:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801615:	bb 00 00 00 00       	mov    $0x0,%ebx
  80161a:	b8 06 00 00 00       	mov    $0x6,%eax
  80161f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801622:	8b 55 08             	mov    0x8(%ebp),%edx
  801625:	89 df                	mov    %ebx,%edi
  801627:	89 de                	mov    %ebx,%esi
  801629:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80162b:	85 c0                	test   %eax,%eax
  80162d:	7e 17                	jle    801646 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80162f:	83 ec 0c             	sub    $0xc,%esp
  801632:	50                   	push   %eax
  801633:	6a 06                	push   $0x6
  801635:	68 6f 38 80 00       	push   $0x80386f
  80163a:	6a 23                	push   $0x23
  80163c:	68 8c 38 80 00       	push   $0x80388c
  801641:	e8 ed f3 ff ff       	call   800a33 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5f                   	pop    %edi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	57                   	push   %edi
  801652:	56                   	push   %esi
  801653:	53                   	push   %ebx
  801654:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801657:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165c:	b8 08 00 00 00       	mov    $0x8,%eax
  801661:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801664:	8b 55 08             	mov    0x8(%ebp),%edx
  801667:	89 df                	mov    %ebx,%edi
  801669:	89 de                	mov    %ebx,%esi
  80166b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80166d:	85 c0                	test   %eax,%eax
  80166f:	7e 17                	jle    801688 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801671:	83 ec 0c             	sub    $0xc,%esp
  801674:	50                   	push   %eax
  801675:	6a 08                	push   $0x8
  801677:	68 6f 38 80 00       	push   $0x80386f
  80167c:	6a 23                	push   $0x23
  80167e:	68 8c 38 80 00       	push   $0x80388c
  801683:	e8 ab f3 ff ff       	call   800a33 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801688:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	57                   	push   %edi
  801694:	56                   	push   %esi
  801695:	53                   	push   %ebx
  801696:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801699:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169e:	b8 09 00 00 00       	mov    $0x9,%eax
  8016a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8016a9:	89 df                	mov    %ebx,%edi
  8016ab:	89 de                	mov    %ebx,%esi
  8016ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	7e 17                	jle    8016ca <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016b3:	83 ec 0c             	sub    $0xc,%esp
  8016b6:	50                   	push   %eax
  8016b7:	6a 09                	push   $0x9
  8016b9:	68 6f 38 80 00       	push   $0x80386f
  8016be:	6a 23                	push   $0x23
  8016c0:	68 8c 38 80 00       	push   $0x80388c
  8016c5:	e8 69 f3 ff ff       	call   800a33 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5f                   	pop    %edi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	57                   	push   %edi
  8016d6:	56                   	push   %esi
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016eb:	89 df                	mov    %ebx,%edi
  8016ed:	89 de                	mov    %ebx,%esi
  8016ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	7e 17                	jle    80170c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016f5:	83 ec 0c             	sub    $0xc,%esp
  8016f8:	50                   	push   %eax
  8016f9:	6a 0a                	push   $0xa
  8016fb:	68 6f 38 80 00       	push   $0x80386f
  801700:	6a 23                	push   $0x23
  801702:	68 8c 38 80 00       	push   $0x80388c
  801707:	e8 27 f3 ff ff       	call   800a33 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80170c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170f:	5b                   	pop    %ebx
  801710:	5e                   	pop    %esi
  801711:	5f                   	pop    %edi
  801712:	5d                   	pop    %ebp
  801713:	c3                   	ret    

00801714 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	57                   	push   %edi
  801718:	56                   	push   %esi
  801719:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80171a:	be 00 00 00 00       	mov    $0x0,%esi
  80171f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801724:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801727:	8b 55 08             	mov    0x8(%ebp),%edx
  80172a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80172d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801730:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	5f                   	pop    %edi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	57                   	push   %edi
  80173b:	56                   	push   %esi
  80173c:	53                   	push   %ebx
  80173d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801740:	b9 00 00 00 00       	mov    $0x0,%ecx
  801745:	b8 0d 00 00 00       	mov    $0xd,%eax
  80174a:	8b 55 08             	mov    0x8(%ebp),%edx
  80174d:	89 cb                	mov    %ecx,%ebx
  80174f:	89 cf                	mov    %ecx,%edi
  801751:	89 ce                	mov    %ecx,%esi
  801753:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801755:	85 c0                	test   %eax,%eax
  801757:	7e 17                	jle    801770 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801759:	83 ec 0c             	sub    $0xc,%esp
  80175c:	50                   	push   %eax
  80175d:	6a 0d                	push   $0xd
  80175f:	68 6f 38 80 00       	push   $0x80386f
  801764:	6a 23                	push   $0x23
  801766:	68 8c 38 80 00       	push   $0x80388c
  80176b:	e8 c3 f2 ff ff       	call   800a33 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801770:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5f                   	pop    %edi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	53                   	push   %ebx
  80177c:	83 ec 04             	sub    $0x4,%esp
  80177f:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  801782:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  801784:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  801787:	89 da                	mov    %ebx,%edx
  801789:	c1 ea 0c             	shr    $0xc,%edx
  80178c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  801793:	a8 02                	test   $0x2,%al
  801795:	75 12                	jne    8017a9 <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  801797:	50                   	push   %eax
  801798:	68 9c 38 80 00       	push   $0x80389c
  80179d:	6a 21                	push   $0x21
  80179f:	68 bd 38 80 00       	push   $0x8038bd
  8017a4:	e8 8a f2 ff ff       	call   800a33 <_panic>
	   } else if (!(pte & PTE_COW)) {
  8017a9:	f6 c6 08             	test   $0x8,%dh
  8017ac:	75 14                	jne    8017c2 <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  8017ae:	83 ec 04             	sub    $0x4,%esp
  8017b1:	68 c8 38 80 00       	push   $0x8038c8
  8017b6:	6a 23                	push   $0x23
  8017b8:	68 bd 38 80 00       	push   $0x8038bd
  8017bd:	e8 71 f2 ff ff       	call   800a33 <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	6a 07                	push   $0x7
  8017c7:	68 00 00 40 00       	push   $0x400000
  8017cc:	6a 00                	push   $0x0
  8017ce:	e8 b4 fd ff ff       	call   801587 <sys_page_alloc>
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	79 12                	jns    8017ec <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  8017da:	50                   	push   %eax
  8017db:	68 e5 38 80 00       	push   $0x8038e5
  8017e0:	6a 2e                	push   $0x2e
  8017e2:	68 bd 38 80 00       	push   $0x8038bd
  8017e7:	e8 47 f2 ff ff       	call   800a33 <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8017ec:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8017f2:	83 ec 04             	sub    $0x4,%esp
  8017f5:	68 00 10 00 00       	push   $0x1000
  8017fa:	53                   	push   %ebx
  8017fb:	68 00 00 40 00       	push   $0x400000
  801800:	e8 11 fb ff ff       	call   801316 <memmove>
	   if ((r = sys_page_map(0,
  801805:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80180c:	53                   	push   %ebx
  80180d:	6a 00                	push   $0x0
  80180f:	68 00 00 40 00       	push   $0x400000
  801814:	6a 00                	push   $0x0
  801816:	e8 af fd ff ff       	call   8015ca <sys_page_map>
  80181b:	83 c4 20             	add    $0x20,%esp
  80181e:	85 c0                	test   %eax,%eax
  801820:	79 12                	jns    801834 <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  801822:	50                   	push   %eax
  801823:	68 f8 38 80 00       	push   $0x8038f8
  801828:	6a 36                	push   $0x36
  80182a:	68 bd 38 80 00       	push   $0x8038bd
  80182f:	e8 ff f1 ff ff       	call   800a33 <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	68 00 00 40 00       	push   $0x400000
  80183c:	6a 00                	push   $0x0
  80183e:	e8 c9 fd ff ff       	call   80160c <sys_page_unmap>
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	85 c0                	test   %eax,%eax
  801848:	79 12                	jns    80185c <pgfault+0xe4>
			 panic("unmap %e", r);
  80184a:	50                   	push   %eax
  80184b:	68 08 39 80 00       	push   $0x803908
  801850:	6a 39                	push   $0x39
  801852:	68 bd 38 80 00       	push   $0x8038bd
  801857:	e8 d7 f1 ff ff       	call   800a33 <_panic>
	   }
}
  80185c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	57                   	push   %edi
  801865:	56                   	push   %esi
  801866:	53                   	push   %ebx
  801867:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  80186a:	68 78 17 80 00       	push   $0x801778
  80186f:	e8 65 16 00 00       	call   802ed9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801874:	b8 07 00 00 00       	mov    $0x7,%eax
  801879:	cd 30                	int    $0x30
  80187b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80187e:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	85 c0                	test   %eax,%eax
  801886:	79 15                	jns    80189d <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  801888:	50                   	push   %eax
  801889:	68 11 39 80 00       	push   $0x803911
  80188e:	68 81 00 00 00       	push   $0x81
  801893:	68 bd 38 80 00       	push   $0x8038bd
  801898:	e8 96 f1 ff ff       	call   800a33 <_panic>
  80189d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8018a4:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  8018a8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018ac:	75 1c                	jne    8018ca <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  8018ae:	e8 96 fc ff ff       	call   801549 <sys_getenvid>
  8018b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018b8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018bb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018c0:	a3 24 54 80 00       	mov    %eax,0x805424
			 return envid;
  8018c5:	e9 71 01 00 00       	jmp    801a3b <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  8018ca:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8018cd:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  8018d4:	a8 01                	test   $0x1,%al
  8018d6:	0f 84 18 01 00 00    	je     8019f4 <fork+0x193>
  8018dc:	89 fb                	mov    %edi,%ebx
  8018de:	c1 e3 0a             	shl    $0xa,%ebx
  8018e1:	c1 e7 16             	shl    $0x16,%edi
  8018e4:	be 00 00 00 00       	mov    $0x0,%esi
  8018e9:	e9 f4 00 00 00       	jmp    8019e2 <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  8018ee:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8018f4:	0f 84 dc 00 00 00    	je     8019d6 <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  8018fa:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801900:	0f 87 cc 00 00 00    	ja     8019d2 <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  801906:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80190d:	a8 01                	test   $0x1,%al
  80190f:	0f 84 c1 00 00 00    	je     8019d6 <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  801915:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  80191c:	a9 02 08 00 00       	test   $0x802,%eax
  801921:	74 05                	je     801928 <fork+0xc7>
  801923:	f6 c4 04             	test   $0x4,%ah
  801926:	74 3a                	je     801962 <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  801928:	8b 15 24 54 80 00    	mov    0x805424,%edx
  80192e:	8b 52 48             	mov    0x48(%edx),%edx
  801931:	83 ec 0c             	sub    $0xc,%esp
  801934:	25 07 0e 00 00       	and    $0xe07,%eax
  801939:	50                   	push   %eax
  80193a:	57                   	push   %edi
  80193b:	ff 75 dc             	pushl  -0x24(%ebp)
  80193e:	57                   	push   %edi
  80193f:	52                   	push   %edx
  801940:	e8 85 fc ff ff       	call   8015ca <sys_page_map>
  801945:	83 c4 20             	add    $0x20,%esp
  801948:	85 c0                	test   %eax,%eax
  80194a:	0f 89 86 00 00 00    	jns    8019d6 <fork+0x175>
				    panic("sys_page_map: %e", r);
  801950:	50                   	push   %eax
  801951:	68 21 39 80 00       	push   $0x803921
  801956:	6a 52                	push   $0x52
  801958:	68 bd 38 80 00       	push   $0x8038bd
  80195d:	e8 d1 f0 ff ff       	call   800a33 <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  801962:	25 05 06 00 00       	and    $0x605,%eax
  801967:	80 cc 08             	or     $0x8,%ah
  80196a:	89 c1                	mov    %eax,%ecx
  80196c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80196f:	a1 24 54 80 00       	mov    0x805424,%eax
  801974:	8b 40 48             	mov    0x48(%eax),%eax
  801977:	83 ec 0c             	sub    $0xc,%esp
  80197a:	51                   	push   %ecx
  80197b:	57                   	push   %edi
  80197c:	ff 75 dc             	pushl  -0x24(%ebp)
  80197f:	57                   	push   %edi
  801980:	50                   	push   %eax
  801981:	e8 44 fc ff ff       	call   8015ca <sys_page_map>
  801986:	83 c4 20             	add    $0x20,%esp
  801989:	85 c0                	test   %eax,%eax
  80198b:	79 12                	jns    80199f <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  80198d:	50                   	push   %eax
  80198e:	68 21 39 80 00       	push   $0x803921
  801993:	6a 5d                	push   $0x5d
  801995:	68 bd 38 80 00       	push   $0x8038bd
  80199a:	e8 94 f0 ff ff       	call   800a33 <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  80199f:	a1 24 54 80 00       	mov    0x805424,%eax
  8019a4:	8b 50 48             	mov    0x48(%eax),%edx
  8019a7:	8b 40 48             	mov    0x48(%eax),%eax
  8019aa:	83 ec 0c             	sub    $0xc,%esp
  8019ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8019b0:	57                   	push   %edi
  8019b1:	52                   	push   %edx
  8019b2:	57                   	push   %edi
  8019b3:	50                   	push   %eax
  8019b4:	e8 11 fc ff ff       	call   8015ca <sys_page_map>
  8019b9:	83 c4 20             	add    $0x20,%esp
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	79 16                	jns    8019d6 <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  8019c0:	50                   	push   %eax
  8019c1:	68 21 39 80 00       	push   $0x803921
  8019c6:	6a 63                	push   $0x63
  8019c8:	68 bd 38 80 00       	push   $0x8038bd
  8019cd:	e8 61 f0 ff ff       	call   800a33 <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  8019d2:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  8019d6:	83 c6 01             	add    $0x1,%esi
  8019d9:	83 c3 01             	add    $0x1,%ebx
  8019dc:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8019e2:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  8019e8:	7f 0a                	jg     8019f4 <fork+0x193>
  8019ea:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8019ee:	0f 85 fa fe ff ff    	jne    8018ee <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  8019f4:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  8019f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019fb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a00:	7f 0a                	jg     801a0c <fork+0x1ab>
  801a02:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801a06:	0f 85 be fe ff ff    	jne    8018ca <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	68 32 2f 80 00       	push   $0x802f32
  801a14:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801a17:	56                   	push   %esi
  801a18:	e8 b5 fc ff ff       	call   8016d2 <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  801a1d:	83 c4 0c             	add    $0xc,%esp
  801a20:	6a 06                	push   $0x6
  801a22:	68 00 f0 bf ee       	push   $0xeebff000
  801a27:	56                   	push   %esi
  801a28:	e8 5a fb ff ff       	call   801587 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  801a2d:	83 c4 08             	add    $0x8,%esp
  801a30:	6a 02                	push   $0x2
  801a32:	56                   	push   %esi
  801a33:	e8 16 fc ff ff       	call   80164e <sys_env_set_status>

	   return envid;
  801a38:	83 c4 10             	add    $0x10,%esp
}
  801a3b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a41:	5b                   	pop    %ebx
  801a42:	5e                   	pop    %esi
  801a43:	5f                   	pop    %edi
  801a44:	5d                   	pop    %ebp
  801a45:	c3                   	ret    

00801a46 <sfork>:
// Challenge!
	   int
sfork(void)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  801a4c:	68 32 39 80 00       	push   $0x803932
  801a51:	68 a7 00 00 00       	push   $0xa7
  801a56:	68 bd 38 80 00       	push   $0x8038bd
  801a5b:	e8 d3 ef ff ff       	call   800a33 <_panic>

00801a60 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	8b 55 08             	mov    0x8(%ebp),%edx
  801a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a69:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a6c:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a6e:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a71:	83 3a 01             	cmpl   $0x1,(%edx)
  801a74:	7e 09                	jle    801a7f <argstart+0x1f>
  801a76:	ba 41 33 80 00       	mov    $0x803341,%edx
  801a7b:	85 c9                	test   %ecx,%ecx
  801a7d:	75 05                	jne    801a84 <argstart+0x24>
  801a7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a84:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801a87:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <argnext>:

int
argnext(struct Argstate *args)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	53                   	push   %ebx
  801a94:	83 ec 04             	sub    $0x4,%esp
  801a97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801a9a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801aa1:	8b 43 08             	mov    0x8(%ebx),%eax
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	74 6f                	je     801b17 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801aa8:	80 38 00             	cmpb   $0x0,(%eax)
  801aab:	75 4e                	jne    801afb <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801aad:	8b 0b                	mov    (%ebx),%ecx
  801aaf:	83 39 01             	cmpl   $0x1,(%ecx)
  801ab2:	74 55                	je     801b09 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801ab4:	8b 53 04             	mov    0x4(%ebx),%edx
  801ab7:	8b 42 04             	mov    0x4(%edx),%eax
  801aba:	80 38 2d             	cmpb   $0x2d,(%eax)
  801abd:	75 4a                	jne    801b09 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801abf:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801ac3:	74 44                	je     801b09 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801ac5:	83 c0 01             	add    $0x1,%eax
  801ac8:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801acb:	83 ec 04             	sub    $0x4,%esp
  801ace:	8b 01                	mov    (%ecx),%eax
  801ad0:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801ad7:	50                   	push   %eax
  801ad8:	8d 42 08             	lea    0x8(%edx),%eax
  801adb:	50                   	push   %eax
  801adc:	83 c2 04             	add    $0x4,%edx
  801adf:	52                   	push   %edx
  801ae0:	e8 31 f8 ff ff       	call   801316 <memmove>
		(*args->argc)--;
  801ae5:	8b 03                	mov    (%ebx),%eax
  801ae7:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801aea:	8b 43 08             	mov    0x8(%ebx),%eax
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	80 38 2d             	cmpb   $0x2d,(%eax)
  801af3:	75 06                	jne    801afb <argnext+0x6b>
  801af5:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801af9:	74 0e                	je     801b09 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801afb:	8b 53 08             	mov    0x8(%ebx),%edx
  801afe:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b01:	83 c2 01             	add    $0x1,%edx
  801b04:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b07:	eb 13                	jmp    801b1c <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b09:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b15:	eb 05                	jmp    801b1c <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1f:	c9                   	leave  
  801b20:	c3                   	ret    

00801b21 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	53                   	push   %ebx
  801b25:	83 ec 04             	sub    $0x4,%esp
  801b28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b2b:	8b 43 08             	mov    0x8(%ebx),%eax
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	74 58                	je     801b8a <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b32:	80 38 00             	cmpb   $0x0,(%eax)
  801b35:	74 0c                	je     801b43 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b37:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b3a:	c7 43 08 41 33 80 00 	movl   $0x803341,0x8(%ebx)
  801b41:	eb 42                	jmp    801b85 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b43:	8b 13                	mov    (%ebx),%edx
  801b45:	83 3a 01             	cmpl   $0x1,(%edx)
  801b48:	7e 2d                	jle    801b77 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b4a:	8b 43 04             	mov    0x4(%ebx),%eax
  801b4d:	8b 48 04             	mov    0x4(%eax),%ecx
  801b50:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b53:	83 ec 04             	sub    $0x4,%esp
  801b56:	8b 12                	mov    (%edx),%edx
  801b58:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b5f:	52                   	push   %edx
  801b60:	8d 50 08             	lea    0x8(%eax),%edx
  801b63:	52                   	push   %edx
  801b64:	83 c0 04             	add    $0x4,%eax
  801b67:	50                   	push   %eax
  801b68:	e8 a9 f7 ff ff       	call   801316 <memmove>
		(*args->argc)--;
  801b6d:	8b 03                	mov    (%ebx),%eax
  801b6f:	83 28 01             	subl   $0x1,(%eax)
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	eb 0e                	jmp    801b85 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801b77:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801b7e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801b85:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b88:	eb 05                	jmp    801b8f <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801b8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	83 ec 08             	sub    $0x8,%esp
  801b9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801b9d:	8b 51 0c             	mov    0xc(%ecx),%edx
  801ba0:	89 d0                	mov    %edx,%eax
  801ba2:	85 d2                	test   %edx,%edx
  801ba4:	75 0c                	jne    801bb2 <argvalue+0x1e>
  801ba6:	83 ec 0c             	sub    $0xc,%esp
  801ba9:	51                   	push   %ecx
  801baa:	e8 72 ff ff ff       	call   801b21 <argnextvalue>
  801baf:	83 c4 10             	add    $0x10,%esp
}
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bba:	05 00 00 00 30       	add    $0x30000000,%eax
  801bbf:	c1 e8 0c             	shr    $0xc,%eax
}
  801bc2:	5d                   	pop    %ebp
  801bc3:	c3                   	ret    

00801bc4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bca:	05 00 00 00 30       	add    $0x30000000,%eax
  801bcf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801bd4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801be6:	89 c2                	mov    %eax,%edx
  801be8:	c1 ea 16             	shr    $0x16,%edx
  801beb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bf2:	f6 c2 01             	test   $0x1,%dl
  801bf5:	74 11                	je     801c08 <fd_alloc+0x2d>
  801bf7:	89 c2                	mov    %eax,%edx
  801bf9:	c1 ea 0c             	shr    $0xc,%edx
  801bfc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c03:	f6 c2 01             	test   $0x1,%dl
  801c06:	75 09                	jne    801c11 <fd_alloc+0x36>
			*fd_store = fd;
  801c08:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0f:	eb 17                	jmp    801c28 <fd_alloc+0x4d>
  801c11:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c16:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c1b:	75 c9                	jne    801be6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c1d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c23:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c28:	5d                   	pop    %ebp
  801c29:	c3                   	ret    

00801c2a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c30:	83 f8 1f             	cmp    $0x1f,%eax
  801c33:	77 36                	ja     801c6b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c35:	c1 e0 0c             	shl    $0xc,%eax
  801c38:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c3d:	89 c2                	mov    %eax,%edx
  801c3f:	c1 ea 16             	shr    $0x16,%edx
  801c42:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c49:	f6 c2 01             	test   $0x1,%dl
  801c4c:	74 24                	je     801c72 <fd_lookup+0x48>
  801c4e:	89 c2                	mov    %eax,%edx
  801c50:	c1 ea 0c             	shr    $0xc,%edx
  801c53:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c5a:	f6 c2 01             	test   $0x1,%dl
  801c5d:	74 1a                	je     801c79 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c62:	89 02                	mov    %eax,(%edx)
	return 0;
  801c64:	b8 00 00 00 00       	mov    $0x0,%eax
  801c69:	eb 13                	jmp    801c7e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c70:	eb 0c                	jmp    801c7e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c77:	eb 05                	jmp    801c7e <fd_lookup+0x54>
  801c79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801c7e:	5d                   	pop    %ebp
  801c7f:	c3                   	ret    

00801c80 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 08             	sub    $0x8,%esp
  801c86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c89:	ba c4 39 80 00       	mov    $0x8039c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801c8e:	eb 13                	jmp    801ca3 <dev_lookup+0x23>
  801c90:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801c93:	39 08                	cmp    %ecx,(%eax)
  801c95:	75 0c                	jne    801ca3 <dev_lookup+0x23>
			*dev = devtab[i];
  801c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c9a:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca1:	eb 2e                	jmp    801cd1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ca3:	8b 02                	mov    (%edx),%eax
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	75 e7                	jne    801c90 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801ca9:	a1 24 54 80 00       	mov    0x805424,%eax
  801cae:	8b 40 48             	mov    0x48(%eax),%eax
  801cb1:	83 ec 04             	sub    $0x4,%esp
  801cb4:	51                   	push   %ecx
  801cb5:	50                   	push   %eax
  801cb6:	68 48 39 80 00       	push   $0x803948
  801cbb:	e8 4c ee ff ff       	call   800b0c <cprintf>
	*dev = 0;
  801cc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801cd1:	c9                   	leave  
  801cd2:	c3                   	ret    

00801cd3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	56                   	push   %esi
  801cd7:	53                   	push   %ebx
  801cd8:	83 ec 10             	sub    $0x10,%esp
  801cdb:	8b 75 08             	mov    0x8(%ebp),%esi
  801cde:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801ce1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce4:	50                   	push   %eax
  801ce5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801ceb:	c1 e8 0c             	shr    $0xc,%eax
  801cee:	50                   	push   %eax
  801cef:	e8 36 ff ff ff       	call   801c2a <fd_lookup>
  801cf4:	83 c4 08             	add    $0x8,%esp
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	78 05                	js     801d00 <fd_close+0x2d>
	    || fd != fd2)
  801cfb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801cfe:	74 0c                	je     801d0c <fd_close+0x39>
		return (must_exist ? r : 0);
  801d00:	84 db                	test   %bl,%bl
  801d02:	ba 00 00 00 00       	mov    $0x0,%edx
  801d07:	0f 44 c2             	cmove  %edx,%eax
  801d0a:	eb 41                	jmp    801d4d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d0c:	83 ec 08             	sub    $0x8,%esp
  801d0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d12:	50                   	push   %eax
  801d13:	ff 36                	pushl  (%esi)
  801d15:	e8 66 ff ff ff       	call   801c80 <dev_lookup>
  801d1a:	89 c3                	mov    %eax,%ebx
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	78 1a                	js     801d3d <fd_close+0x6a>
		if (dev->dev_close)
  801d23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d26:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d29:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	74 0b                	je     801d3d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d32:	83 ec 0c             	sub    $0xc,%esp
  801d35:	56                   	push   %esi
  801d36:	ff d0                	call   *%eax
  801d38:	89 c3                	mov    %eax,%ebx
  801d3a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d3d:	83 ec 08             	sub    $0x8,%esp
  801d40:	56                   	push   %esi
  801d41:	6a 00                	push   $0x0
  801d43:	e8 c4 f8 ff ff       	call   80160c <sys_page_unmap>
	return r;
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	89 d8                	mov    %ebx,%eax
}
  801d4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d50:	5b                   	pop    %ebx
  801d51:	5e                   	pop    %esi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    

00801d54 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5d:	50                   	push   %eax
  801d5e:	ff 75 08             	pushl  0x8(%ebp)
  801d61:	e8 c4 fe ff ff       	call   801c2a <fd_lookup>
  801d66:	83 c4 08             	add    $0x8,%esp
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	78 10                	js     801d7d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801d6d:	83 ec 08             	sub    $0x8,%esp
  801d70:	6a 01                	push   $0x1
  801d72:	ff 75 f4             	pushl  -0xc(%ebp)
  801d75:	e8 59 ff ff ff       	call   801cd3 <fd_close>
  801d7a:	83 c4 10             	add    $0x10,%esp
}
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    

00801d7f <close_all>:

void
close_all(void)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	53                   	push   %ebx
  801d83:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801d86:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801d8b:	83 ec 0c             	sub    $0xc,%esp
  801d8e:	53                   	push   %ebx
  801d8f:	e8 c0 ff ff ff       	call   801d54 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d94:	83 c3 01             	add    $0x1,%ebx
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	83 fb 20             	cmp    $0x20,%ebx
  801d9d:	75 ec                	jne    801d8b <close_all+0xc>
		close(i);
}
  801d9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	57                   	push   %edi
  801da8:	56                   	push   %esi
  801da9:	53                   	push   %ebx
  801daa:	83 ec 2c             	sub    $0x2c,%esp
  801dad:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801db0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801db3:	50                   	push   %eax
  801db4:	ff 75 08             	pushl  0x8(%ebp)
  801db7:	e8 6e fe ff ff       	call   801c2a <fd_lookup>
  801dbc:	83 c4 08             	add    $0x8,%esp
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	0f 88 c1 00 00 00    	js     801e88 <dup+0xe4>
		return r;
	close(newfdnum);
  801dc7:	83 ec 0c             	sub    $0xc,%esp
  801dca:	56                   	push   %esi
  801dcb:	e8 84 ff ff ff       	call   801d54 <close>

	newfd = INDEX2FD(newfdnum);
  801dd0:	89 f3                	mov    %esi,%ebx
  801dd2:	c1 e3 0c             	shl    $0xc,%ebx
  801dd5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801ddb:	83 c4 04             	add    $0x4,%esp
  801dde:	ff 75 e4             	pushl  -0x1c(%ebp)
  801de1:	e8 de fd ff ff       	call   801bc4 <fd2data>
  801de6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801de8:	89 1c 24             	mov    %ebx,(%esp)
  801deb:	e8 d4 fd ff ff       	call   801bc4 <fd2data>
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801df6:	89 f8                	mov    %edi,%eax
  801df8:	c1 e8 16             	shr    $0x16,%eax
  801dfb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e02:	a8 01                	test   $0x1,%al
  801e04:	74 37                	je     801e3d <dup+0x99>
  801e06:	89 f8                	mov    %edi,%eax
  801e08:	c1 e8 0c             	shr    $0xc,%eax
  801e0b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e12:	f6 c2 01             	test   $0x1,%dl
  801e15:	74 26                	je     801e3d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e1e:	83 ec 0c             	sub    $0xc,%esp
  801e21:	25 07 0e 00 00       	and    $0xe07,%eax
  801e26:	50                   	push   %eax
  801e27:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e2a:	6a 00                	push   $0x0
  801e2c:	57                   	push   %edi
  801e2d:	6a 00                	push   $0x0
  801e2f:	e8 96 f7 ff ff       	call   8015ca <sys_page_map>
  801e34:	89 c7                	mov    %eax,%edi
  801e36:	83 c4 20             	add    $0x20,%esp
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	78 2e                	js     801e6b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e3d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e40:	89 d0                	mov    %edx,%eax
  801e42:	c1 e8 0c             	shr    $0xc,%eax
  801e45:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e4c:	83 ec 0c             	sub    $0xc,%esp
  801e4f:	25 07 0e 00 00       	and    $0xe07,%eax
  801e54:	50                   	push   %eax
  801e55:	53                   	push   %ebx
  801e56:	6a 00                	push   $0x0
  801e58:	52                   	push   %edx
  801e59:	6a 00                	push   $0x0
  801e5b:	e8 6a f7 ff ff       	call   8015ca <sys_page_map>
  801e60:	89 c7                	mov    %eax,%edi
  801e62:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801e65:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e67:	85 ff                	test   %edi,%edi
  801e69:	79 1d                	jns    801e88 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e6b:	83 ec 08             	sub    $0x8,%esp
  801e6e:	53                   	push   %ebx
  801e6f:	6a 00                	push   $0x0
  801e71:	e8 96 f7 ff ff       	call   80160c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e76:	83 c4 08             	add    $0x8,%esp
  801e79:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e7c:	6a 00                	push   $0x0
  801e7e:	e8 89 f7 ff ff       	call   80160c <sys_page_unmap>
	return r;
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	89 f8                	mov    %edi,%eax
}
  801e88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8b:	5b                   	pop    %ebx
  801e8c:	5e                   	pop    %esi
  801e8d:	5f                   	pop    %edi
  801e8e:	5d                   	pop    %ebp
  801e8f:	c3                   	ret    

00801e90 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	53                   	push   %ebx
  801e94:	83 ec 14             	sub    $0x14,%esp
  801e97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e9d:	50                   	push   %eax
  801e9e:	53                   	push   %ebx
  801e9f:	e8 86 fd ff ff       	call   801c2a <fd_lookup>
  801ea4:	83 c4 08             	add    $0x8,%esp
  801ea7:	89 c2                	mov    %eax,%edx
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	78 6d                	js     801f1a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ead:	83 ec 08             	sub    $0x8,%esp
  801eb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb3:	50                   	push   %eax
  801eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eb7:	ff 30                	pushl  (%eax)
  801eb9:	e8 c2 fd ff ff       	call   801c80 <dev_lookup>
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	78 4c                	js     801f11 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ec5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ec8:	8b 42 08             	mov    0x8(%edx),%eax
  801ecb:	83 e0 03             	and    $0x3,%eax
  801ece:	83 f8 01             	cmp    $0x1,%eax
  801ed1:	75 21                	jne    801ef4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ed3:	a1 24 54 80 00       	mov    0x805424,%eax
  801ed8:	8b 40 48             	mov    0x48(%eax),%eax
  801edb:	83 ec 04             	sub    $0x4,%esp
  801ede:	53                   	push   %ebx
  801edf:	50                   	push   %eax
  801ee0:	68 89 39 80 00       	push   $0x803989
  801ee5:	e8 22 ec ff ff       	call   800b0c <cprintf>
		return -E_INVAL;
  801eea:	83 c4 10             	add    $0x10,%esp
  801eed:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801ef2:	eb 26                	jmp    801f1a <read+0x8a>
	}
	if (!dev->dev_read)
  801ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef7:	8b 40 08             	mov    0x8(%eax),%eax
  801efa:	85 c0                	test   %eax,%eax
  801efc:	74 17                	je     801f15 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801efe:	83 ec 04             	sub    $0x4,%esp
  801f01:	ff 75 10             	pushl  0x10(%ebp)
  801f04:	ff 75 0c             	pushl  0xc(%ebp)
  801f07:	52                   	push   %edx
  801f08:	ff d0                	call   *%eax
  801f0a:	89 c2                	mov    %eax,%edx
  801f0c:	83 c4 10             	add    $0x10,%esp
  801f0f:	eb 09                	jmp    801f1a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f11:	89 c2                	mov    %eax,%edx
  801f13:	eb 05                	jmp    801f1a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f15:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801f1a:	89 d0                	mov    %edx,%eax
  801f1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f1f:	c9                   	leave  
  801f20:	c3                   	ret    

00801f21 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	57                   	push   %edi
  801f25:	56                   	push   %esi
  801f26:	53                   	push   %ebx
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f30:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f35:	eb 21                	jmp    801f58 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f37:	83 ec 04             	sub    $0x4,%esp
  801f3a:	89 f0                	mov    %esi,%eax
  801f3c:	29 d8                	sub    %ebx,%eax
  801f3e:	50                   	push   %eax
  801f3f:	89 d8                	mov    %ebx,%eax
  801f41:	03 45 0c             	add    0xc(%ebp),%eax
  801f44:	50                   	push   %eax
  801f45:	57                   	push   %edi
  801f46:	e8 45 ff ff ff       	call   801e90 <read>
		if (m < 0)
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	78 10                	js     801f62 <readn+0x41>
			return m;
		if (m == 0)
  801f52:	85 c0                	test   %eax,%eax
  801f54:	74 0a                	je     801f60 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f56:	01 c3                	add    %eax,%ebx
  801f58:	39 f3                	cmp    %esi,%ebx
  801f5a:	72 db                	jb     801f37 <readn+0x16>
  801f5c:	89 d8                	mov    %ebx,%eax
  801f5e:	eb 02                	jmp    801f62 <readn+0x41>
  801f60:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f65:	5b                   	pop    %ebx
  801f66:	5e                   	pop    %esi
  801f67:	5f                   	pop    %edi
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    

00801f6a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	53                   	push   %ebx
  801f6e:	83 ec 14             	sub    $0x14,%esp
  801f71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f74:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f77:	50                   	push   %eax
  801f78:	53                   	push   %ebx
  801f79:	e8 ac fc ff ff       	call   801c2a <fd_lookup>
  801f7e:	83 c4 08             	add    $0x8,%esp
  801f81:	89 c2                	mov    %eax,%edx
  801f83:	85 c0                	test   %eax,%eax
  801f85:	78 68                	js     801fef <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f87:	83 ec 08             	sub    $0x8,%esp
  801f8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8d:	50                   	push   %eax
  801f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f91:	ff 30                	pushl  (%eax)
  801f93:	e8 e8 fc ff ff       	call   801c80 <dev_lookup>
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	78 47                	js     801fe6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801fa6:	75 21                	jne    801fc9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801fa8:	a1 24 54 80 00       	mov    0x805424,%eax
  801fad:	8b 40 48             	mov    0x48(%eax),%eax
  801fb0:	83 ec 04             	sub    $0x4,%esp
  801fb3:	53                   	push   %ebx
  801fb4:	50                   	push   %eax
  801fb5:	68 a5 39 80 00       	push   $0x8039a5
  801fba:	e8 4d eb ff ff       	call   800b0c <cprintf>
		return -E_INVAL;
  801fbf:	83 c4 10             	add    $0x10,%esp
  801fc2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801fc7:	eb 26                	jmp    801fef <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801fc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fcc:	8b 52 0c             	mov    0xc(%edx),%edx
  801fcf:	85 d2                	test   %edx,%edx
  801fd1:	74 17                	je     801fea <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801fd3:	83 ec 04             	sub    $0x4,%esp
  801fd6:	ff 75 10             	pushl  0x10(%ebp)
  801fd9:	ff 75 0c             	pushl  0xc(%ebp)
  801fdc:	50                   	push   %eax
  801fdd:	ff d2                	call   *%edx
  801fdf:	89 c2                	mov    %eax,%edx
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	eb 09                	jmp    801fef <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fe6:	89 c2                	mov    %eax,%edx
  801fe8:	eb 05                	jmp    801fef <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801fea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801fef:	89 d0                	mov    %edx,%eax
  801ff1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff4:	c9                   	leave  
  801ff5:	c3                   	ret    

00801ff6 <seek>:

int
seek(int fdnum, off_t offset)
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
  801ff9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ffc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801fff:	50                   	push   %eax
  802000:	ff 75 08             	pushl  0x8(%ebp)
  802003:	e8 22 fc ff ff       	call   801c2a <fd_lookup>
  802008:	83 c4 08             	add    $0x8,%esp
  80200b:	85 c0                	test   %eax,%eax
  80200d:	78 0e                	js     80201d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80200f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802012:	8b 55 0c             	mov    0xc(%ebp),%edx
  802015:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802018:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80201d:	c9                   	leave  
  80201e:	c3                   	ret    

0080201f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	53                   	push   %ebx
  802023:	83 ec 14             	sub    $0x14,%esp
  802026:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802029:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80202c:	50                   	push   %eax
  80202d:	53                   	push   %ebx
  80202e:	e8 f7 fb ff ff       	call   801c2a <fd_lookup>
  802033:	83 c4 08             	add    $0x8,%esp
  802036:	89 c2                	mov    %eax,%edx
  802038:	85 c0                	test   %eax,%eax
  80203a:	78 65                	js     8020a1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80203c:	83 ec 08             	sub    $0x8,%esp
  80203f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802042:	50                   	push   %eax
  802043:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802046:	ff 30                	pushl  (%eax)
  802048:	e8 33 fc ff ff       	call   801c80 <dev_lookup>
  80204d:	83 c4 10             	add    $0x10,%esp
  802050:	85 c0                	test   %eax,%eax
  802052:	78 44                	js     802098 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802054:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802057:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80205b:	75 21                	jne    80207e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80205d:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802062:	8b 40 48             	mov    0x48(%eax),%eax
  802065:	83 ec 04             	sub    $0x4,%esp
  802068:	53                   	push   %ebx
  802069:	50                   	push   %eax
  80206a:	68 68 39 80 00       	push   $0x803968
  80206f:	e8 98 ea ff ff       	call   800b0c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802074:	83 c4 10             	add    $0x10,%esp
  802077:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80207c:	eb 23                	jmp    8020a1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80207e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802081:	8b 52 18             	mov    0x18(%edx),%edx
  802084:	85 d2                	test   %edx,%edx
  802086:	74 14                	je     80209c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802088:	83 ec 08             	sub    $0x8,%esp
  80208b:	ff 75 0c             	pushl  0xc(%ebp)
  80208e:	50                   	push   %eax
  80208f:	ff d2                	call   *%edx
  802091:	89 c2                	mov    %eax,%edx
  802093:	83 c4 10             	add    $0x10,%esp
  802096:	eb 09                	jmp    8020a1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802098:	89 c2                	mov    %eax,%edx
  80209a:	eb 05                	jmp    8020a1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80209c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8020a1:	89 d0                	mov    %edx,%eax
  8020a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a6:	c9                   	leave  
  8020a7:	c3                   	ret    

008020a8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	53                   	push   %ebx
  8020ac:	83 ec 14             	sub    $0x14,%esp
  8020af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020b5:	50                   	push   %eax
  8020b6:	ff 75 08             	pushl  0x8(%ebp)
  8020b9:	e8 6c fb ff ff       	call   801c2a <fd_lookup>
  8020be:	83 c4 08             	add    $0x8,%esp
  8020c1:	89 c2                	mov    %eax,%edx
  8020c3:	85 c0                	test   %eax,%eax
  8020c5:	78 58                	js     80211f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020c7:	83 ec 08             	sub    $0x8,%esp
  8020ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020cd:	50                   	push   %eax
  8020ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d1:	ff 30                	pushl  (%eax)
  8020d3:	e8 a8 fb ff ff       	call   801c80 <dev_lookup>
  8020d8:	83 c4 10             	add    $0x10,%esp
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	78 37                	js     802116 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8020df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8020e6:	74 32                	je     80211a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8020e8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8020eb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8020f2:	00 00 00 
	stat->st_isdir = 0;
  8020f5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020fc:	00 00 00 
	stat->st_dev = dev;
  8020ff:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802105:	83 ec 08             	sub    $0x8,%esp
  802108:	53                   	push   %ebx
  802109:	ff 75 f0             	pushl  -0x10(%ebp)
  80210c:	ff 50 14             	call   *0x14(%eax)
  80210f:	89 c2                	mov    %eax,%edx
  802111:	83 c4 10             	add    $0x10,%esp
  802114:	eb 09                	jmp    80211f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802116:	89 c2                	mov    %eax,%edx
  802118:	eb 05                	jmp    80211f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80211a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80211f:	89 d0                	mov    %edx,%eax
  802121:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802124:	c9                   	leave  
  802125:	c3                   	ret    

00802126 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	56                   	push   %esi
  80212a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80212b:	83 ec 08             	sub    $0x8,%esp
  80212e:	6a 00                	push   $0x0
  802130:	ff 75 08             	pushl  0x8(%ebp)
  802133:	e8 2c 02 00 00       	call   802364 <open>
  802138:	89 c3                	mov    %eax,%ebx
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	85 c0                	test   %eax,%eax
  80213f:	78 1b                	js     80215c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802141:	83 ec 08             	sub    $0x8,%esp
  802144:	ff 75 0c             	pushl  0xc(%ebp)
  802147:	50                   	push   %eax
  802148:	e8 5b ff ff ff       	call   8020a8 <fstat>
  80214d:	89 c6                	mov    %eax,%esi
	close(fd);
  80214f:	89 1c 24             	mov    %ebx,(%esp)
  802152:	e8 fd fb ff ff       	call   801d54 <close>
	return r;
  802157:	83 c4 10             	add    $0x10,%esp
  80215a:	89 f0                	mov    %esi,%eax
}
  80215c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5d                   	pop    %ebp
  802162:	c3                   	ret    

00802163 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  802163:	55                   	push   %ebp
  802164:	89 e5                	mov    %esp,%ebp
  802166:	56                   	push   %esi
  802167:	53                   	push   %ebx
  802168:	89 c6                	mov    %eax,%esi
  80216a:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  80216c:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802173:	75 12                	jne    802187 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  802175:	83 ec 0c             	sub    $0xc,%esp
  802178:	6a 01                	push   $0x1
  80217a:	e8 8c 0e 00 00       	call   80300b <ipc_find_env>
  80217f:	a3 20 54 80 00       	mov    %eax,0x805420
  802184:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802187:	6a 07                	push   $0x7
  802189:	68 00 60 80 00       	push   $0x806000
  80218e:	56                   	push   %esi
  80218f:	ff 35 20 54 80 00    	pushl  0x805420
  802195:	e8 1d 0e 00 00       	call   802fb7 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  80219a:	83 c4 0c             	add    $0xc,%esp
  80219d:	6a 00                	push   $0x0
  80219f:	53                   	push   %ebx
  8021a0:	6a 00                	push   $0x0
  8021a2:	e8 b1 0d 00 00       	call   802f58 <ipc_recv>
}
  8021a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021aa:	5b                   	pop    %ebx
  8021ab:	5e                   	pop    %esi
  8021ac:	5d                   	pop    %ebp
  8021ad:	c3                   	ret    

008021ae <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021ae:	55                   	push   %ebp
  8021af:	89 e5                	mov    %esp,%ebp
  8021b1:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8021ba:	a3 00 60 80 00       	mov    %eax,0x806000
	   fsipcbuf.set_size.req_size = newsize;
  8021bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c2:	a3 04 60 80 00       	mov    %eax,0x806004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  8021c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8021cc:	b8 02 00 00 00       	mov    $0x2,%eax
  8021d1:	e8 8d ff ff ff       	call   802163 <fsipc>
}
  8021d6:	c9                   	leave  
  8021d7:	c3                   	ret    

008021d8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
  8021db:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8021de:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8021e4:	a3 00 60 80 00       	mov    %eax,0x806000
	   return fsipc(FSREQ_FLUSH, NULL);
  8021e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8021ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8021f3:	e8 6b ff ff ff       	call   802163 <fsipc>
}
  8021f8:	c9                   	leave  
  8021f9:	c3                   	ret    

008021fa <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8021fa:	55                   	push   %ebp
  8021fb:	89 e5                	mov    %esp,%ebp
  8021fd:	53                   	push   %ebx
  8021fe:	83 ec 04             	sub    $0x4,%esp
  802201:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802204:	8b 45 08             	mov    0x8(%ebp),%eax
  802207:	8b 40 0c             	mov    0xc(%eax),%eax
  80220a:	a3 00 60 80 00       	mov    %eax,0x806000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80220f:	ba 00 00 00 00       	mov    $0x0,%edx
  802214:	b8 05 00 00 00       	mov    $0x5,%eax
  802219:	e8 45 ff ff ff       	call   802163 <fsipc>
  80221e:	85 c0                	test   %eax,%eax
  802220:	78 2c                	js     80224e <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802222:	83 ec 08             	sub    $0x8,%esp
  802225:	68 00 60 80 00       	push   $0x806000
  80222a:	53                   	push   %ebx
  80222b:	e8 54 ef ff ff       	call   801184 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  802230:	a1 80 60 80 00       	mov    0x806080,%eax
  802235:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80223b:	a1 84 60 80 00       	mov    0x806084,%eax
  802240:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  802246:	83 c4 10             	add    $0x10,%esp
  802249:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80224e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802251:	c9                   	leave  
  802252:	c3                   	ret    

00802253 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	53                   	push   %ebx
  802257:	83 ec 08             	sub    $0x8,%esp
  80225a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  80225d:	8b 45 08             	mov    0x8(%ebp),%eax
  802260:	8b 40 0c             	mov    0xc(%eax),%eax
  802263:	a3 00 60 80 00       	mov    %eax,0x806000
	   fsipcbuf.write.req_n = n;
  802268:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  80226e:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  802274:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  802279:	0f 46 c3             	cmovbe %ebx,%eax
  80227c:	50                   	push   %eax
  80227d:	ff 75 0c             	pushl  0xc(%ebp)
  802280:	68 08 60 80 00       	push   $0x806008
  802285:	e8 8c f0 ff ff       	call   801316 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  80228a:	ba 00 00 00 00       	mov    $0x0,%edx
  80228f:	b8 04 00 00 00       	mov    $0x4,%eax
  802294:	e8 ca fe ff ff       	call   802163 <fsipc>
  802299:	83 c4 10             	add    $0x10,%esp
  80229c:	85 c0                	test   %eax,%eax
  80229e:	78 3d                	js     8022dd <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  8022a0:	39 c3                	cmp    %eax,%ebx
  8022a2:	73 19                	jae    8022bd <devfile_write+0x6a>
  8022a4:	68 d4 39 80 00       	push   $0x8039d4
  8022a9:	68 77 34 80 00       	push   $0x803477
  8022ae:	68 9a 00 00 00       	push   $0x9a
  8022b3:	68 db 39 80 00       	push   $0x8039db
  8022b8:	e8 76 e7 ff ff       	call   800a33 <_panic>
	   assert (r <= bytes_written);
  8022bd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8022c2:	7e 19                	jle    8022dd <devfile_write+0x8a>
  8022c4:	68 e6 39 80 00       	push   $0x8039e6
  8022c9:	68 77 34 80 00       	push   $0x803477
  8022ce:	68 9b 00 00 00       	push   $0x9b
  8022d3:	68 db 39 80 00       	push   $0x8039db
  8022d8:	e8 56 e7 ff ff       	call   800a33 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  8022dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022e0:	c9                   	leave  
  8022e1:	c3                   	ret    

008022e2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022e2:	55                   	push   %ebp
  8022e3:	89 e5                	mov    %esp,%ebp
  8022e5:	56                   	push   %esi
  8022e6:	53                   	push   %ebx
  8022e7:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8022f0:	a3 00 60 80 00       	mov    %eax,0x806000
	   fsipcbuf.read.req_n = n;
  8022f5:	89 35 04 60 80 00    	mov    %esi,0x806004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8022fb:	ba 00 00 00 00       	mov    $0x0,%edx
  802300:	b8 03 00 00 00       	mov    $0x3,%eax
  802305:	e8 59 fe ff ff       	call   802163 <fsipc>
  80230a:	89 c3                	mov    %eax,%ebx
  80230c:	85 c0                	test   %eax,%eax
  80230e:	78 4b                	js     80235b <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  802310:	39 c6                	cmp    %eax,%esi
  802312:	73 16                	jae    80232a <devfile_read+0x48>
  802314:	68 d4 39 80 00       	push   $0x8039d4
  802319:	68 77 34 80 00       	push   $0x803477
  80231e:	6a 7c                	push   $0x7c
  802320:	68 db 39 80 00       	push   $0x8039db
  802325:	e8 09 e7 ff ff       	call   800a33 <_panic>
	   assert(r <= PGSIZE);
  80232a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80232f:	7e 16                	jle    802347 <devfile_read+0x65>
  802331:	68 f9 39 80 00       	push   $0x8039f9
  802336:	68 77 34 80 00       	push   $0x803477
  80233b:	6a 7d                	push   $0x7d
  80233d:	68 db 39 80 00       	push   $0x8039db
  802342:	e8 ec e6 ff ff       	call   800a33 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802347:	83 ec 04             	sub    $0x4,%esp
  80234a:	50                   	push   %eax
  80234b:	68 00 60 80 00       	push   $0x806000
  802350:	ff 75 0c             	pushl  0xc(%ebp)
  802353:	e8 be ef ff ff       	call   801316 <memmove>
	   return r;
  802358:	83 c4 10             	add    $0x10,%esp
}
  80235b:	89 d8                	mov    %ebx,%eax
  80235d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802360:	5b                   	pop    %ebx
  802361:	5e                   	pop    %esi
  802362:	5d                   	pop    %ebp
  802363:	c3                   	ret    

00802364 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  802364:	55                   	push   %ebp
  802365:	89 e5                	mov    %esp,%ebp
  802367:	53                   	push   %ebx
  802368:	83 ec 20             	sub    $0x20,%esp
  80236b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  80236e:	53                   	push   %ebx
  80236f:	e8 d7 ed ff ff       	call   80114b <strlen>
  802374:	83 c4 10             	add    $0x10,%esp
  802377:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80237c:	7f 67                	jg     8023e5 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  80237e:	83 ec 0c             	sub    $0xc,%esp
  802381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802384:	50                   	push   %eax
  802385:	e8 51 f8 ff ff       	call   801bdb <fd_alloc>
  80238a:	83 c4 10             	add    $0x10,%esp
			 return r;
  80238d:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  80238f:	85 c0                	test   %eax,%eax
  802391:	78 57                	js     8023ea <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  802393:	83 ec 08             	sub    $0x8,%esp
  802396:	53                   	push   %ebx
  802397:	68 00 60 80 00       	push   $0x806000
  80239c:	e8 e3 ed ff ff       	call   801184 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  8023a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a4:	a3 00 64 80 00       	mov    %eax,0x806400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8023a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b1:	e8 ad fd ff ff       	call   802163 <fsipc>
  8023b6:	89 c3                	mov    %eax,%ebx
  8023b8:	83 c4 10             	add    $0x10,%esp
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	79 14                	jns    8023d3 <open+0x6f>
			 fd_close(fd, 0);
  8023bf:	83 ec 08             	sub    $0x8,%esp
  8023c2:	6a 00                	push   $0x0
  8023c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c7:	e8 07 f9 ff ff       	call   801cd3 <fd_close>
			 return r;
  8023cc:	83 c4 10             	add    $0x10,%esp
  8023cf:	89 da                	mov    %ebx,%edx
  8023d1:	eb 17                	jmp    8023ea <open+0x86>
	   }

	   return fd2num(fd);
  8023d3:	83 ec 0c             	sub    $0xc,%esp
  8023d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8023d9:	e8 d6 f7 ff ff       	call   801bb4 <fd2num>
  8023de:	89 c2                	mov    %eax,%edx
  8023e0:	83 c4 10             	add    $0x10,%esp
  8023e3:	eb 05                	jmp    8023ea <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  8023e5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  8023ea:	89 d0                	mov    %edx,%eax
  8023ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023ef:	c9                   	leave  
  8023f0:	c3                   	ret    

008023f1 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  8023f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8023fc:	b8 08 00 00 00       	mov    $0x8,%eax
  802401:	e8 5d fd ff ff       	call   802163 <fsipc>
}
  802406:	c9                   	leave  
  802407:	c3                   	ret    

00802408 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802408:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80240c:	7e 37                	jle    802445 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80240e:	55                   	push   %ebp
  80240f:	89 e5                	mov    %esp,%ebp
  802411:	53                   	push   %ebx
  802412:	83 ec 08             	sub    $0x8,%esp
  802415:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  802417:	ff 70 04             	pushl  0x4(%eax)
  80241a:	8d 40 10             	lea    0x10(%eax),%eax
  80241d:	50                   	push   %eax
  80241e:	ff 33                	pushl  (%ebx)
  802420:	e8 45 fb ff ff       	call   801f6a <write>
		if (result > 0)
  802425:	83 c4 10             	add    $0x10,%esp
  802428:	85 c0                	test   %eax,%eax
  80242a:	7e 03                	jle    80242f <writebuf+0x27>
			b->result += result;
  80242c:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80242f:	3b 43 04             	cmp    0x4(%ebx),%eax
  802432:	74 0d                	je     802441 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  802434:	85 c0                	test   %eax,%eax
  802436:	ba 00 00 00 00       	mov    $0x0,%edx
  80243b:	0f 4f c2             	cmovg  %edx,%eax
  80243e:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802441:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802444:	c9                   	leave  
  802445:	f3 c3                	repz ret 

00802447 <putch>:

static void
putch(int ch, void *thunk)
{
  802447:	55                   	push   %ebp
  802448:	89 e5                	mov    %esp,%ebp
  80244a:	53                   	push   %ebx
  80244b:	83 ec 04             	sub    $0x4,%esp
  80244e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802451:	8b 53 04             	mov    0x4(%ebx),%edx
  802454:	8d 42 01             	lea    0x1(%edx),%eax
  802457:	89 43 04             	mov    %eax,0x4(%ebx)
  80245a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80245d:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802461:	3d 00 01 00 00       	cmp    $0x100,%eax
  802466:	75 0e                	jne    802476 <putch+0x2f>
		writebuf(b);
  802468:	89 d8                	mov    %ebx,%eax
  80246a:	e8 99 ff ff ff       	call   802408 <writebuf>
		b->idx = 0;
  80246f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802476:	83 c4 04             	add    $0x4,%esp
  802479:	5b                   	pop    %ebx
  80247a:	5d                   	pop    %ebp
  80247b:	c3                   	ret    

0080247c <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80247c:	55                   	push   %ebp
  80247d:	89 e5                	mov    %esp,%ebp
  80247f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802485:	8b 45 08             	mov    0x8(%ebp),%eax
  802488:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80248e:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802495:	00 00 00 
	b.result = 0;
  802498:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80249f:	00 00 00 
	b.error = 1;
  8024a2:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8024a9:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8024ac:	ff 75 10             	pushl  0x10(%ebp)
  8024af:	ff 75 0c             	pushl  0xc(%ebp)
  8024b2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024b8:	50                   	push   %eax
  8024b9:	68 47 24 80 00       	push   $0x802447
  8024be:	e8 80 e7 ff ff       	call   800c43 <vprintfmt>
	if (b.idx > 0)
  8024c3:	83 c4 10             	add    $0x10,%esp
  8024c6:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024cd:	7e 0b                	jle    8024da <vfprintf+0x5e>
		writebuf(&b);
  8024cf:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024d5:	e8 2e ff ff ff       	call   802408 <writebuf>

	return (b.result ? b.result : b.error);
  8024da:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024e0:	85 c0                	test   %eax,%eax
  8024e2:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8024e9:	c9                   	leave  
  8024ea:	c3                   	ret    

008024eb <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024eb:	55                   	push   %ebp
  8024ec:	89 e5                	mov    %esp,%ebp
  8024ee:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024f1:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8024f4:	50                   	push   %eax
  8024f5:	ff 75 0c             	pushl  0xc(%ebp)
  8024f8:	ff 75 08             	pushl  0x8(%ebp)
  8024fb:	e8 7c ff ff ff       	call   80247c <vfprintf>
	va_end(ap);

	return cnt;
}
  802500:	c9                   	leave  
  802501:	c3                   	ret    

00802502 <printf>:

int
printf(const char *fmt, ...)
{
  802502:	55                   	push   %ebp
  802503:	89 e5                	mov    %esp,%ebp
  802505:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802508:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80250b:	50                   	push   %eax
  80250c:	ff 75 08             	pushl  0x8(%ebp)
  80250f:	6a 01                	push   $0x1
  802511:	e8 66 ff ff ff       	call   80247c <vfprintf>
	va_end(ap);

	return cnt;
}
  802516:	c9                   	leave  
  802517:	c3                   	ret    

00802518 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
	   int
spawn(const char *prog, const char **argv)
{
  802518:	55                   	push   %ebp
  802519:	89 e5                	mov    %esp,%ebp
  80251b:	57                   	push   %edi
  80251c:	56                   	push   %esi
  80251d:	53                   	push   %ebx
  80251e:	81 ec 94 02 00 00    	sub    $0x294,%esp
	   //   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	   //     correct initial eip and esp values in the child.
	   //
	   //   - Start the child process running with sys_env_set_status().

	   if ((r = open(prog, O_RDONLY)) < 0)
  802524:	6a 00                	push   $0x0
  802526:	ff 75 08             	pushl  0x8(%ebp)
  802529:	e8 36 fe ff ff       	call   802364 <open>
  80252e:	89 c1                	mov    %eax,%ecx
  802530:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  802536:	83 c4 10             	add    $0x10,%esp
  802539:	85 c0                	test   %eax,%eax
  80253b:	0f 88 de 04 00 00    	js     802a1f <spawn+0x507>
			 return r;
	   fd = r;

	   // Read elf header
	   elf = (struct Elf*) elf_buf;
	   if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802541:	83 ec 04             	sub    $0x4,%esp
  802544:	68 00 02 00 00       	push   $0x200
  802549:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80254f:	50                   	push   %eax
  802550:	51                   	push   %ecx
  802551:	e8 cb f9 ff ff       	call   801f21 <readn>
  802556:	83 c4 10             	add    $0x10,%esp
  802559:	3d 00 02 00 00       	cmp    $0x200,%eax
  80255e:	75 0c                	jne    80256c <spawn+0x54>
				    || elf->e_magic != ELF_MAGIC) {
  802560:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802567:	45 4c 46 
  80256a:	74 33                	je     80259f <spawn+0x87>
			 close(fd);
  80256c:	83 ec 0c             	sub    $0xc,%esp
  80256f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802575:	e8 da f7 ff ff       	call   801d54 <close>
			 cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80257a:	83 c4 0c             	add    $0xc,%esp
  80257d:	68 7f 45 4c 46       	push   $0x464c457f
  802582:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802588:	68 05 3a 80 00       	push   $0x803a05
  80258d:	e8 7a e5 ff ff       	call   800b0c <cprintf>
			 return -E_NOT_EXEC;
  802592:	83 c4 10             	add    $0x10,%esp
  802595:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80259a:	e9 12 05 00 00       	jmp    802ab1 <spawn+0x599>
  80259f:	b8 07 00 00 00       	mov    $0x7,%eax
  8025a4:	cd 30                	int    $0x30
  8025a6:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8025ac:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	   }

	   // Create new child environment
	   if ((r = sys_exofork()) < 0)
  8025b2:	85 c0                	test   %eax,%eax
  8025b4:	0f 88 70 04 00 00    	js     802a2a <spawn+0x512>
			 return r;
	   child = r;

	   // Set up trap frame, including initial stack.
	   child_tf = envs[ENVX(child)].env_tf;
  8025ba:	89 c6                	mov    %eax,%esi
  8025bc:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8025c2:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8025c5:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8025cb:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025d1:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	   child_tf.tf_eip = elf->e_entry;
  8025d8:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025de:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
	   for (argc = 0; argv[argc] != 0; argc++)
  8025e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	   char *string_store;
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
  8025e9:	be 00 00 00 00       	mov    $0x0,%esi
  8025ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025f1:	eb 13                	jmp    802606 <spawn+0xee>
	   for (argc = 0; argv[argc] != 0; argc++)
			 string_size += strlen(argv[argc]) + 1;
  8025f3:	83 ec 0c             	sub    $0xc,%esp
  8025f6:	50                   	push   %eax
  8025f7:	e8 4f eb ff ff       	call   80114b <strlen>
  8025fc:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
	   for (argc = 0; argv[argc] != 0; argc++)
  802600:	83 c3 01             	add    $0x1,%ebx
  802603:	83 c4 10             	add    $0x10,%esp
  802606:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80260d:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802610:	85 c0                	test   %eax,%eax
  802612:	75 df                	jne    8025f3 <spawn+0xdb>
  802614:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  80261a:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	   // Determine where to place the strings and the argv array.
	   // Set up pointers into the temporary page 'UTEMP'; we'll map a page
	   // there later, then remap that page into the child environment
	   // at (USTACKTOP - PGSIZE).
	   // strings is the topmost thing on the stack.
	   string_store = (char*) UTEMP + PGSIZE - string_size;
  802620:	bf 00 10 40 00       	mov    $0x401000,%edi
  802625:	29 f7                	sub    %esi,%edi
	   // argv is below that.  There's one argument pointer per argument, plus
	   // a null pointer.
	   argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802627:	89 fa                	mov    %edi,%edx
  802629:	83 e2 fc             	and    $0xfffffffc,%edx
  80262c:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802633:	29 c2                	sub    %eax,%edx
  802635:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	   // Make sure that argv, strings, and the 2 words that hold 'argc'
	   // and 'argv' themselves will all fit in a single stack page.
	   if ((void*) (argv_store - 2) < (void*) UTEMP)
  80263b:	8d 42 f8             	lea    -0x8(%edx),%eax
  80263e:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802643:	0f 86 f1 03 00 00    	jbe    802a3a <spawn+0x522>
			 return -E_NO_MEM;

	   // Allocate the single stack page at UTEMP.
	   if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802649:	83 ec 04             	sub    $0x4,%esp
  80264c:	6a 07                	push   $0x7
  80264e:	68 00 00 40 00       	push   $0x400000
  802653:	6a 00                	push   $0x0
  802655:	e8 2d ef ff ff       	call   801587 <sys_page_alloc>
  80265a:	83 c4 10             	add    $0x10,%esp
  80265d:	85 c0                	test   %eax,%eax
  80265f:	0f 88 dc 03 00 00    	js     802a41 <spawn+0x529>
  802665:	be 00 00 00 00       	mov    $0x0,%esi
  80266a:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  802670:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802673:	eb 30                	jmp    8026a5 <spawn+0x18d>
	   //	  environment.)
	   //
	   //	* Set *init_esp to the initial stack pointer for the child,
	   //	  (Again, use an address valid in the child's environment.)
	   for (i = 0; i < argc; i++) {
			 argv_store[i] = UTEMP2USTACK(string_store);
  802675:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80267b:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802681:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
			 strcpy(string_store, argv[i]);
  802684:	83 ec 08             	sub    $0x8,%esp
  802687:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80268a:	57                   	push   %edi
  80268b:	e8 f4 ea ff ff       	call   801184 <strcpy>
			 string_store += strlen(argv[i]) + 1;
  802690:	83 c4 04             	add    $0x4,%esp
  802693:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802696:	e8 b0 ea ff ff       	call   80114b <strlen>
  80269b:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	   //	  (Again, argv should use an address valid in the child's
	   //	  environment.)
	   //
	   //	* Set *init_esp to the initial stack pointer for the child,
	   //	  (Again, use an address valid in the child's environment.)
	   for (i = 0; i < argc; i++) {
  80269f:	83 c6 01             	add    $0x1,%esi
  8026a2:	83 c4 10             	add    $0x10,%esp
  8026a5:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  8026ab:	7f c8                	jg     802675 <spawn+0x15d>
			 argv_store[i] = UTEMP2USTACK(string_store);
			 strcpy(string_store, argv[i]);
			 string_store += strlen(argv[i]) + 1;
	   }
	   argv_store[argc] = 0;
  8026ad:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8026b3:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8026b9:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	   assert(string_store == (char*)UTEMP + PGSIZE);
  8026c0:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026c6:	74 19                	je     8026e1 <spawn+0x1c9>
  8026c8:	68 90 3a 80 00       	push   $0x803a90
  8026cd:	68 77 34 80 00       	push   $0x803477
  8026d2:	68 f2 00 00 00       	push   $0xf2
  8026d7:	68 1f 3a 80 00       	push   $0x803a1f
  8026dc:	e8 52 e3 ff ff       	call   800a33 <_panic>

	   argv_store[-1] = UTEMP2USTACK(argv_store);
  8026e1:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8026e7:	89 c8                	mov    %ecx,%eax
  8026e9:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8026ee:	89 41 fc             	mov    %eax,-0x4(%ecx)
	   argv_store[-2] = argc;
  8026f1:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8026f7:	89 41 f8             	mov    %eax,-0x8(%ecx)

	   *init_esp = UTEMP2USTACK(&argv_store[-2]);
  8026fa:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  802700:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	   // After completing the stack, map it into the child's address space
	   // and unmap it from ours!
	   if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802706:	83 ec 0c             	sub    $0xc,%esp
  802709:	6a 07                	push   $0x7
  80270b:	68 00 d0 bf ee       	push   $0xeebfd000
  802710:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802716:	68 00 00 40 00       	push   $0x400000
  80271b:	6a 00                	push   $0x0
  80271d:	e8 a8 ee ff ff       	call   8015ca <sys_page_map>
  802722:	89 c3                	mov    %eax,%ebx
  802724:	83 c4 20             	add    $0x20,%esp
  802727:	85 c0                	test   %eax,%eax
  802729:	0f 88 70 03 00 00    	js     802a9f <spawn+0x587>
			 goto error;
	   if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80272f:	83 ec 08             	sub    $0x8,%esp
  802732:	68 00 00 40 00       	push   $0x400000
  802737:	6a 00                	push   $0x0
  802739:	e8 ce ee ff ff       	call   80160c <sys_page_unmap>
  80273e:	89 c3                	mov    %eax,%ebx
  802740:	83 c4 10             	add    $0x10,%esp
  802743:	85 c0                	test   %eax,%eax
  802745:	0f 88 54 03 00 00    	js     802a9f <spawn+0x587>

	   if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
			 return r;

	   // Set up program segments as defined in ELF header.
	   ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80274b:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802751:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802758:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	   for (i = 0; i < elf->e_phnum; i++, ph++) {
  80275e:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802765:	00 00 00 
  802768:	e9 86 01 00 00       	jmp    8028f3 <spawn+0x3db>
			 if (ph->p_type != ELF_PROG_LOAD)
  80276d:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802773:	83 38 01             	cmpl   $0x1,(%eax)
  802776:	0f 85 69 01 00 00    	jne    8028e5 <spawn+0x3cd>
				    continue;
			 perm = PTE_P | PTE_U;
			 if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80277c:	89 c1                	mov    %eax,%ecx
  80277e:	8b 40 18             	mov    0x18(%eax),%eax
  802781:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802787:	83 e0 02             	and    $0x2,%eax
				    perm |= PTE_W;
  80278a:	83 f8 01             	cmp    $0x1,%eax
  80278d:	19 c0                	sbb    %eax,%eax
  80278f:	83 e0 fe             	and    $0xfffffffe,%eax
  802792:	83 c0 07             	add    $0x7,%eax
  802795:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
			 if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80279b:	89 c8                	mov    %ecx,%eax
  80279d:	8b 49 04             	mov    0x4(%ecx),%ecx
  8027a0:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  8027a6:	8b 78 10             	mov    0x10(%eax),%edi
  8027a9:	8b 50 14             	mov    0x14(%eax),%edx
  8027ac:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  8027b2:	8b 70 08             	mov    0x8(%eax),%esi
	   int i, r;
	   void *blk;

	   //cprintf("map_segment %x+%x\n", va, memsz);

	   if ((i = PGOFF(va))) {
  8027b5:	89 f0                	mov    %esi,%eax
  8027b7:	25 ff 0f 00 00       	and    $0xfff,%eax
  8027bc:	74 14                	je     8027d2 <spawn+0x2ba>
			 va -= i;
  8027be:	29 c6                	sub    %eax,%esi
			 memsz += i;
  8027c0:	01 c2                	add    %eax,%edx
  8027c2:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
			 filesz += i;
  8027c8:	01 c7                	add    %eax,%edi
			 fileoffset -= i;
  8027ca:	29 c1                	sub    %eax,%ecx
  8027cc:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	   }

	   for (i = 0; i < memsz; i += PGSIZE) {
  8027d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027d7:	e9 f7 00 00 00       	jmp    8028d3 <spawn+0x3bb>
			 if (i >= filesz) {
  8027dc:	39 df                	cmp    %ebx,%edi
  8027de:	77 27                	ja     802807 <spawn+0x2ef>
				    // allocate a blank page
				    if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027e0:	83 ec 04             	sub    $0x4,%esp
  8027e3:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027e9:	56                   	push   %esi
  8027ea:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8027f0:	e8 92 ed ff ff       	call   801587 <sys_page_alloc>
  8027f5:	83 c4 10             	add    $0x10,%esp
  8027f8:	85 c0                	test   %eax,%eax
  8027fa:	0f 89 c7 00 00 00    	jns    8028c7 <spawn+0x3af>
  802800:	89 c3                	mov    %eax,%ebx
  802802:	e9 48 02 00 00       	jmp    802a4f <spawn+0x537>
						  return r;
			 } else {
				    // from file
				    if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802807:	83 ec 04             	sub    $0x4,%esp
  80280a:	6a 07                	push   $0x7
  80280c:	68 00 00 40 00       	push   $0x400000
  802811:	6a 00                	push   $0x0
  802813:	e8 6f ed ff ff       	call   801587 <sys_page_alloc>
  802818:	83 c4 10             	add    $0x10,%esp
  80281b:	85 c0                	test   %eax,%eax
  80281d:	0f 88 22 02 00 00    	js     802a45 <spawn+0x52d>
						  return r;
				    if ((r = seek(fd, fileoffset + i)) < 0)
  802823:	83 ec 08             	sub    $0x8,%esp
  802826:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80282c:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802832:	50                   	push   %eax
  802833:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802839:	e8 b8 f7 ff ff       	call   801ff6 <seek>
  80283e:	83 c4 10             	add    $0x10,%esp
  802841:	85 c0                	test   %eax,%eax
  802843:	0f 88 00 02 00 00    	js     802a49 <spawn+0x531>
						  return r;
				    if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802849:	83 ec 04             	sub    $0x4,%esp
  80284c:	89 f8                	mov    %edi,%eax
  80284e:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802854:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802859:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80285e:	0f 47 c1             	cmova  %ecx,%eax
  802861:	50                   	push   %eax
  802862:	68 00 00 40 00       	push   $0x400000
  802867:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80286d:	e8 af f6 ff ff       	call   801f21 <readn>
  802872:	83 c4 10             	add    $0x10,%esp
  802875:	85 c0                	test   %eax,%eax
  802877:	0f 88 d0 01 00 00    	js     802a4d <spawn+0x535>
						  return r;
				    if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80287d:	83 ec 0c             	sub    $0xc,%esp
  802880:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802886:	56                   	push   %esi
  802887:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80288d:	68 00 00 40 00       	push   $0x400000
  802892:	6a 00                	push   $0x0
  802894:	e8 31 ed ff ff       	call   8015ca <sys_page_map>
  802899:	83 c4 20             	add    $0x20,%esp
  80289c:	85 c0                	test   %eax,%eax
  80289e:	79 15                	jns    8028b5 <spawn+0x39d>
						  panic("spawn: sys_page_map data: %e", r);
  8028a0:	50                   	push   %eax
  8028a1:	68 2b 3a 80 00       	push   $0x803a2b
  8028a6:	68 25 01 00 00       	push   $0x125
  8028ab:	68 1f 3a 80 00       	push   $0x803a1f
  8028b0:	e8 7e e1 ff ff       	call   800a33 <_panic>
				    sys_page_unmap(0, UTEMP);
  8028b5:	83 ec 08             	sub    $0x8,%esp
  8028b8:	68 00 00 40 00       	push   $0x400000
  8028bd:	6a 00                	push   $0x0
  8028bf:	e8 48 ed ff ff       	call   80160c <sys_page_unmap>
  8028c4:	83 c4 10             	add    $0x10,%esp
			 memsz += i;
			 filesz += i;
			 fileoffset -= i;
	   }

	   for (i = 0; i < memsz; i += PGSIZE) {
  8028c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028cd:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028d3:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8028d9:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  8028df:	0f 87 f7 fe ff ff    	ja     8027dc <spawn+0x2c4>
	   if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
			 return r;

	   // Set up program segments as defined in ELF header.
	   ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	   for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028e5:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8028ec:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8028f3:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028fa:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802900:	0f 8c 67 fe ff ff    	jl     80276d <spawn+0x255>
				    perm |= PTE_W;
			 if ((r = map_segment(child, ph->p_va, ph->p_memsz,
									   fd, ph->p_filesz, ph->p_offset, perm)) < 0)
				    goto error;
	   }
	   close(fd);
  802906:	83 ec 0c             	sub    $0xc,%esp
  802909:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80290f:	e8 40 f4 ff ff       	call   801d54 <close>
  802914:	83 c4 10             	add    $0x10,%esp
	   static int
copy_shared_pages(envid_t child)
{
	   // LAB 5: Your code here.
	   int r;
	   bool is_below_ulim = true;
  802917:	c6 85 94 fd ff ff 01 	movb   $0x1,-0x26c(%ebp)
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
  80291e:	c7 85 8c fd ff ff 00 	movl   $0x0,-0x274(%ebp)
  802925:	00 00 00 
	   {
			 if (!(uvpd[i] & PTE_P)) 
  802928:	8b bd 8c fd ff ff    	mov    -0x274(%ebp),%edi
  80292e:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  802935:	a8 01                	test   $0x1,%al
  802937:	74 7b                	je     8029b4 <spawn+0x49c>
  802939:	89 fb                	mov    %edi,%ebx
  80293b:	c1 e3 0a             	shl    $0xa,%ebx
  80293e:	c1 e7 16             	shl    $0x16,%edi
  802941:	be 00 00 00 00       	mov    $0x0,%esi
  802946:	eb 5b                	jmp    8029a3 <spawn+0x48b>
				    continue;
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) 
			 {
				    unsigned pn = i * NPTENTRIES + j;
				    pte_t pte = uvpt[pn];
  802948:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
				    if (pn >= (UTOP >> PGSHIFT)) 
  80294f:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  802955:	77 39                	ja     802990 <spawn+0x478>
				    {
						  is_below_ulim = false;
				    } else if (pte & PTE_SHARE) 
  802957:	f6 c4 04             	test   $0x4,%ah
  80295a:	74 3b                	je     802997 <spawn+0x47f>
				    {
						  if ((r = sys_page_map(0, (void *)(pn * PGSIZE), child, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  80295c:	83 ec 0c             	sub    $0xc,%esp
  80295f:	25 07 0e 00 00       	and    $0xe07,%eax
  802964:	50                   	push   %eax
  802965:	57                   	push   %edi
  802966:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80296c:	57                   	push   %edi
  80296d:	6a 00                	push   $0x0
  80296f:	e8 56 ec ff ff       	call   8015ca <sys_page_map>
  802974:	83 c4 20             	add    $0x20,%esp
  802977:	85 c0                	test   %eax,%eax
  802979:	79 1c                	jns    802997 <spawn+0x47f>
	   close(fd);
	   fd = -1;

	   // Copy shared library state.
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);
  80297b:	50                   	push   %eax
  80297c:	68 79 3a 80 00       	push   $0x803a79
  802981:	68 82 00 00 00       	push   $0x82
  802986:	68 1f 3a 80 00       	push   $0x803a1f
  80298b:	e8 a3 e0 ff ff       	call   800a33 <_panic>
			 {
				    unsigned pn = i * NPTENTRIES + j;
				    pte_t pte = uvpt[pn];
				    if (pn >= (UTOP >> PGSHIFT)) 
				    {
						  is_below_ulim = false;
  802990:	c6 85 94 fd ff ff 00 	movb   $0x0,-0x26c(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
	   {
			 if (!(uvpd[i] & PTE_P)) 
				    continue;
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) 
  802997:	83 c6 01             	add    $0x1,%esi
  80299a:	83 c3 01             	add    $0x1,%ebx
  80299d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8029a3:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  8029a9:	7f 09                	jg     8029b4 <spawn+0x49c>
  8029ab:	80 bd 94 fd ff ff 00 	cmpb   $0x0,-0x26c(%ebp)
  8029b2:	75 94                	jne    802948 <spawn+0x430>
copy_shared_pages(envid_t child)
{
	   // LAB 5: Your code here.
	   int r;
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
  8029b4:	83 85 8c fd ff ff 01 	addl   $0x1,-0x274(%ebp)
  8029bb:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8029c1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8029c6:	0f 8f a4 00 00 00    	jg     802a70 <spawn+0x558>
  8029cc:	80 bd 94 fd ff ff 00 	cmpb   $0x0,-0x26c(%ebp)
  8029d3:	0f 85 4f ff ff ff    	jne    802928 <spawn+0x410>
  8029d9:	e9 92 00 00 00       	jmp    802a70 <spawn+0x558>
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);

	   child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	   if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
			 panic("sys_env_set_trapframe: %e", r);
  8029de:	50                   	push   %eax
  8029df:	68 48 3a 80 00       	push   $0x803a48
  8029e4:	68 86 00 00 00       	push   $0x86
  8029e9:	68 1f 3a 80 00       	push   $0x803a1f
  8029ee:	e8 40 e0 ff ff       	call   800a33 <_panic>

	   if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8029f3:	83 ec 08             	sub    $0x8,%esp
  8029f6:	6a 02                	push   $0x2
  8029f8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029fe:	e8 4b ec ff ff       	call   80164e <sys_env_set_status>
  802a03:	83 c4 10             	add    $0x10,%esp
  802a06:	85 c0                	test   %eax,%eax
  802a08:	79 28                	jns    802a32 <spawn+0x51a>
			 panic("sys_env_set_status: %e", r);
  802a0a:	50                   	push   %eax
  802a0b:	68 62 3a 80 00       	push   $0x803a62
  802a10:	68 89 00 00 00       	push   $0x89
  802a15:	68 1f 3a 80 00       	push   $0x803a1f
  802a1a:	e8 14 e0 ff ff       	call   800a33 <_panic>
	   //     correct initial eip and esp values in the child.
	   //
	   //   - Start the child process running with sys_env_set_status().

	   if ((r = open(prog, O_RDONLY)) < 0)
			 return r;
  802a1f:	8b 9d 88 fd ff ff    	mov    -0x278(%ebp),%ebx
  802a25:	e9 87 00 00 00       	jmp    802ab1 <spawn+0x599>
			 return -E_NOT_EXEC;
	   }

	   // Create new child environment
	   if ((r = sys_exofork()) < 0)
			 return r;
  802a2a:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a30:	eb 7f                	jmp    802ab1 <spawn+0x599>
			 panic("sys_env_set_trapframe: %e", r);

	   if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
			 panic("sys_env_set_status: %e", r);

	   return child;
  802a32:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a38:	eb 77                	jmp    802ab1 <spawn+0x599>
	   argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	   // Make sure that argv, strings, and the 2 words that hold 'argc'
	   // and 'argv' themselves will all fit in a single stack page.
	   if ((void*) (argv_store - 2) < (void*) UTEMP)
			 return -E_NO_MEM;
  802a3a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802a3f:	eb 70                	jmp    802ab1 <spawn+0x599>

	   // Allocate the single stack page at UTEMP.
	   if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
			 return r;
  802a41:	89 c3                	mov    %eax,%ebx
  802a43:	eb 6c                	jmp    802ab1 <spawn+0x599>
				    // allocate a blank page
				    if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
						  return r;
			 } else {
				    // from file
				    if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a45:	89 c3                	mov    %eax,%ebx
  802a47:	eb 06                	jmp    802a4f <spawn+0x537>
						  return r;
				    if ((r = seek(fd, fileoffset + i)) < 0)
  802a49:	89 c3                	mov    %eax,%ebx
  802a4b:	eb 02                	jmp    802a4f <spawn+0x537>
						  return r;
				    if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a4d:	89 c3                	mov    %eax,%ebx
			 panic("sys_env_set_status: %e", r);

	   return child;

error:
	   sys_env_destroy(child);
  802a4f:	83 ec 0c             	sub    $0xc,%esp
  802a52:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a58:	e8 ab ea ff ff       	call   801508 <sys_env_destroy>
	   close(fd);
  802a5d:	83 c4 04             	add    $0x4,%esp
  802a60:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802a66:	e8 e9 f2 ff ff       	call   801d54 <close>
	   return r;
  802a6b:	83 c4 10             	add    $0x10,%esp
  802a6e:	eb 41                	jmp    802ab1 <spawn+0x599>

	   // Copy shared library state.
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);

	   child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802a70:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802a77:	30 00 00 
	   if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802a7a:	83 ec 08             	sub    $0x8,%esp
  802a7d:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a83:	50                   	push   %eax
  802a84:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a8a:	e8 01 ec ff ff       	call   801690 <sys_env_set_trapframe>
  802a8f:	83 c4 10             	add    $0x10,%esp
  802a92:	85 c0                	test   %eax,%eax
  802a94:	0f 89 59 ff ff ff    	jns    8029f3 <spawn+0x4db>
  802a9a:	e9 3f ff ff ff       	jmp    8029de <spawn+0x4c6>
			 goto error;

	   return 0;

error:
	   sys_page_unmap(0, UTEMP);
  802a9f:	83 ec 08             	sub    $0x8,%esp
  802aa2:	68 00 00 40 00       	push   $0x400000
  802aa7:	6a 00                	push   $0x0
  802aa9:	e8 5e eb ff ff       	call   80160c <sys_page_unmap>
  802aae:	83 c4 10             	add    $0x10,%esp

error:
	   sys_env_destroy(child);
	   close(fd);
	   return r;
}
  802ab1:	89 d8                	mov    %ebx,%eax
  802ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ab6:	5b                   	pop    %ebx
  802ab7:	5e                   	pop    %esi
  802ab8:	5f                   	pop    %edi
  802ab9:	5d                   	pop    %ebp
  802aba:	c3                   	ret    

00802abb <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
	   int
spawnl(const char *prog, const char *arg0, ...)
{
  802abb:	55                   	push   %ebp
  802abc:	89 e5                	mov    %esp,%ebp
  802abe:	56                   	push   %esi
  802abf:	53                   	push   %ebx
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  802ac0:	8d 55 10             	lea    0x10(%ebp),%edx
{
	   // We calculate argc by advancing the args until we hit NULL.
	   // The contract of the function guarantees that the last
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
  802ac3:	b8 00 00 00 00       	mov    $0x0,%eax
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  802ac8:	eb 03                	jmp    802acd <spawnl+0x12>
			 argc++;
  802aca:	83 c0 01             	add    $0x1,%eax
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  802acd:	83 c2 04             	add    $0x4,%edx
  802ad0:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802ad4:	75 f4                	jne    802aca <spawnl+0xf>
			 argc++;
	   va_end(vl);

	   // Now that we have the size of the args, do a second pass
	   // and store the values in a VLA, which has the format of argv
	   const char *argv[argc+2];
  802ad6:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802add:	83 e2 f0             	and    $0xfffffff0,%edx
  802ae0:	29 d4                	sub    %edx,%esp
  802ae2:	8d 54 24 03          	lea    0x3(%esp),%edx
  802ae6:	c1 ea 02             	shr    $0x2,%edx
  802ae9:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802af0:	89 f3                	mov    %esi,%ebx
	   argv[0] = arg0;
  802af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802af5:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	   argv[argc+1] = NULL;
  802afc:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802b03:	00 
  802b04:	89 c2                	mov    %eax,%edx

	   va_start(vl, arg0);
	   unsigned i;
	   for(i=0;i<argc;i++)
  802b06:	b8 00 00 00 00       	mov    $0x0,%eax
  802b0b:	eb 0a                	jmp    802b17 <spawnl+0x5c>
			 argv[i+1] = va_arg(vl, const char *);
  802b0d:	83 c0 01             	add    $0x1,%eax
  802b10:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802b14:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	   argv[0] = arg0;
	   argv[argc+1] = NULL;

	   va_start(vl, arg0);
	   unsigned i;
	   for(i=0;i<argc;i++)
  802b17:	39 d0                	cmp    %edx,%eax
  802b19:	75 f2                	jne    802b0d <spawnl+0x52>
			 argv[i+1] = va_arg(vl, const char *);
	   va_end(vl);
	   return spawn(prog, argv);
  802b1b:	83 ec 08             	sub    $0x8,%esp
  802b1e:	56                   	push   %esi
  802b1f:	ff 75 08             	pushl  0x8(%ebp)
  802b22:	e8 f1 f9 ff ff       	call   802518 <spawn>
}
  802b27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b2a:	5b                   	pop    %ebx
  802b2b:	5e                   	pop    %esi
  802b2c:	5d                   	pop    %ebp
  802b2d:	c3                   	ret    

00802b2e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802b2e:	55                   	push   %ebp
  802b2f:	89 e5                	mov    %esp,%ebp
  802b31:	56                   	push   %esi
  802b32:	53                   	push   %ebx
  802b33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802b36:	83 ec 0c             	sub    $0xc,%esp
  802b39:	ff 75 08             	pushl  0x8(%ebp)
  802b3c:	e8 83 f0 ff ff       	call   801bc4 <fd2data>
  802b41:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802b43:	83 c4 08             	add    $0x8,%esp
  802b46:	68 b8 3a 80 00       	push   $0x803ab8
  802b4b:	53                   	push   %ebx
  802b4c:	e8 33 e6 ff ff       	call   801184 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802b51:	8b 46 04             	mov    0x4(%esi),%eax
  802b54:	2b 06                	sub    (%esi),%eax
  802b56:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802b5c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802b63:	00 00 00 
	stat->st_dev = &devpipe;
  802b66:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802b6d:	40 80 00 
	return 0;
}
  802b70:	b8 00 00 00 00       	mov    $0x0,%eax
  802b75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b78:	5b                   	pop    %ebx
  802b79:	5e                   	pop    %esi
  802b7a:	5d                   	pop    %ebp
  802b7b:	c3                   	ret    

00802b7c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b7c:	55                   	push   %ebp
  802b7d:	89 e5                	mov    %esp,%ebp
  802b7f:	53                   	push   %ebx
  802b80:	83 ec 0c             	sub    $0xc,%esp
  802b83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b86:	53                   	push   %ebx
  802b87:	6a 00                	push   $0x0
  802b89:	e8 7e ea ff ff       	call   80160c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b8e:	89 1c 24             	mov    %ebx,(%esp)
  802b91:	e8 2e f0 ff ff       	call   801bc4 <fd2data>
  802b96:	83 c4 08             	add    $0x8,%esp
  802b99:	50                   	push   %eax
  802b9a:	6a 00                	push   $0x0
  802b9c:	e8 6b ea ff ff       	call   80160c <sys_page_unmap>
}
  802ba1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ba4:	c9                   	leave  
  802ba5:	c3                   	ret    

00802ba6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802ba6:	55                   	push   %ebp
  802ba7:	89 e5                	mov    %esp,%ebp
  802ba9:	57                   	push   %edi
  802baa:	56                   	push   %esi
  802bab:	53                   	push   %ebx
  802bac:	83 ec 1c             	sub    $0x1c,%esp
  802baf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802bb2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802bb4:	a1 24 54 80 00       	mov    0x805424,%eax
  802bb9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802bbc:	83 ec 0c             	sub    $0xc,%esp
  802bbf:	ff 75 e0             	pushl  -0x20(%ebp)
  802bc2:	e8 7d 04 00 00       	call   803044 <pageref>
  802bc7:	89 c3                	mov    %eax,%ebx
  802bc9:	89 3c 24             	mov    %edi,(%esp)
  802bcc:	e8 73 04 00 00       	call   803044 <pageref>
  802bd1:	83 c4 10             	add    $0x10,%esp
  802bd4:	39 c3                	cmp    %eax,%ebx
  802bd6:	0f 94 c1             	sete   %cl
  802bd9:	0f b6 c9             	movzbl %cl,%ecx
  802bdc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802bdf:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802be5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802be8:	39 ce                	cmp    %ecx,%esi
  802bea:	74 1b                	je     802c07 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802bec:	39 c3                	cmp    %eax,%ebx
  802bee:	75 c4                	jne    802bb4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802bf0:	8b 42 58             	mov    0x58(%edx),%eax
  802bf3:	ff 75 e4             	pushl  -0x1c(%ebp)
  802bf6:	50                   	push   %eax
  802bf7:	56                   	push   %esi
  802bf8:	68 bf 3a 80 00       	push   $0x803abf
  802bfd:	e8 0a df ff ff       	call   800b0c <cprintf>
  802c02:	83 c4 10             	add    $0x10,%esp
  802c05:	eb ad                	jmp    802bb4 <_pipeisclosed+0xe>
	}
}
  802c07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c0d:	5b                   	pop    %ebx
  802c0e:	5e                   	pop    %esi
  802c0f:	5f                   	pop    %edi
  802c10:	5d                   	pop    %ebp
  802c11:	c3                   	ret    

00802c12 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802c12:	55                   	push   %ebp
  802c13:	89 e5                	mov    %esp,%ebp
  802c15:	57                   	push   %edi
  802c16:	56                   	push   %esi
  802c17:	53                   	push   %ebx
  802c18:	83 ec 28             	sub    $0x28,%esp
  802c1b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802c1e:	56                   	push   %esi
  802c1f:	e8 a0 ef ff ff       	call   801bc4 <fd2data>
  802c24:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c26:	83 c4 10             	add    $0x10,%esp
  802c29:	bf 00 00 00 00       	mov    $0x0,%edi
  802c2e:	eb 4b                	jmp    802c7b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802c30:	89 da                	mov    %ebx,%edx
  802c32:	89 f0                	mov    %esi,%eax
  802c34:	e8 6d ff ff ff       	call   802ba6 <_pipeisclosed>
  802c39:	85 c0                	test   %eax,%eax
  802c3b:	75 48                	jne    802c85 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802c3d:	e8 26 e9 ff ff       	call   801568 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c42:	8b 43 04             	mov    0x4(%ebx),%eax
  802c45:	8b 0b                	mov    (%ebx),%ecx
  802c47:	8d 51 20             	lea    0x20(%ecx),%edx
  802c4a:	39 d0                	cmp    %edx,%eax
  802c4c:	73 e2                	jae    802c30 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c51:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802c55:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802c58:	89 c2                	mov    %eax,%edx
  802c5a:	c1 fa 1f             	sar    $0x1f,%edx
  802c5d:	89 d1                	mov    %edx,%ecx
  802c5f:	c1 e9 1b             	shr    $0x1b,%ecx
  802c62:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802c65:	83 e2 1f             	and    $0x1f,%edx
  802c68:	29 ca                	sub    %ecx,%edx
  802c6a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802c6e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802c72:	83 c0 01             	add    $0x1,%eax
  802c75:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c78:	83 c7 01             	add    $0x1,%edi
  802c7b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c7e:	75 c2                	jne    802c42 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c80:	8b 45 10             	mov    0x10(%ebp),%eax
  802c83:	eb 05                	jmp    802c8a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c85:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c8d:	5b                   	pop    %ebx
  802c8e:	5e                   	pop    %esi
  802c8f:	5f                   	pop    %edi
  802c90:	5d                   	pop    %ebp
  802c91:	c3                   	ret    

00802c92 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c92:	55                   	push   %ebp
  802c93:	89 e5                	mov    %esp,%ebp
  802c95:	57                   	push   %edi
  802c96:	56                   	push   %esi
  802c97:	53                   	push   %ebx
  802c98:	83 ec 18             	sub    $0x18,%esp
  802c9b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c9e:	57                   	push   %edi
  802c9f:	e8 20 ef ff ff       	call   801bc4 <fd2data>
  802ca4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ca6:	83 c4 10             	add    $0x10,%esp
  802ca9:	bb 00 00 00 00       	mov    $0x0,%ebx
  802cae:	eb 3d                	jmp    802ced <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802cb0:	85 db                	test   %ebx,%ebx
  802cb2:	74 04                	je     802cb8 <devpipe_read+0x26>
				return i;
  802cb4:	89 d8                	mov    %ebx,%eax
  802cb6:	eb 44                	jmp    802cfc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802cb8:	89 f2                	mov    %esi,%edx
  802cba:	89 f8                	mov    %edi,%eax
  802cbc:	e8 e5 fe ff ff       	call   802ba6 <_pipeisclosed>
  802cc1:	85 c0                	test   %eax,%eax
  802cc3:	75 32                	jne    802cf7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802cc5:	e8 9e e8 ff ff       	call   801568 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802cca:	8b 06                	mov    (%esi),%eax
  802ccc:	3b 46 04             	cmp    0x4(%esi),%eax
  802ccf:	74 df                	je     802cb0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802cd1:	99                   	cltd   
  802cd2:	c1 ea 1b             	shr    $0x1b,%edx
  802cd5:	01 d0                	add    %edx,%eax
  802cd7:	83 e0 1f             	and    $0x1f,%eax
  802cda:	29 d0                	sub    %edx,%eax
  802cdc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ce4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802ce7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802cea:	83 c3 01             	add    $0x1,%ebx
  802ced:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802cf0:	75 d8                	jne    802cca <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802cf2:	8b 45 10             	mov    0x10(%ebp),%eax
  802cf5:	eb 05                	jmp    802cfc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802cf7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cff:	5b                   	pop    %ebx
  802d00:	5e                   	pop    %esi
  802d01:	5f                   	pop    %edi
  802d02:	5d                   	pop    %ebp
  802d03:	c3                   	ret    

00802d04 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802d04:	55                   	push   %ebp
  802d05:	89 e5                	mov    %esp,%ebp
  802d07:	56                   	push   %esi
  802d08:	53                   	push   %ebx
  802d09:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802d0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d0f:	50                   	push   %eax
  802d10:	e8 c6 ee ff ff       	call   801bdb <fd_alloc>
  802d15:	83 c4 10             	add    $0x10,%esp
  802d18:	89 c2                	mov    %eax,%edx
  802d1a:	85 c0                	test   %eax,%eax
  802d1c:	0f 88 2c 01 00 00    	js     802e4e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d22:	83 ec 04             	sub    $0x4,%esp
  802d25:	68 07 04 00 00       	push   $0x407
  802d2a:	ff 75 f4             	pushl  -0xc(%ebp)
  802d2d:	6a 00                	push   $0x0
  802d2f:	e8 53 e8 ff ff       	call   801587 <sys_page_alloc>
  802d34:	83 c4 10             	add    $0x10,%esp
  802d37:	89 c2                	mov    %eax,%edx
  802d39:	85 c0                	test   %eax,%eax
  802d3b:	0f 88 0d 01 00 00    	js     802e4e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802d41:	83 ec 0c             	sub    $0xc,%esp
  802d44:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d47:	50                   	push   %eax
  802d48:	e8 8e ee ff ff       	call   801bdb <fd_alloc>
  802d4d:	89 c3                	mov    %eax,%ebx
  802d4f:	83 c4 10             	add    $0x10,%esp
  802d52:	85 c0                	test   %eax,%eax
  802d54:	0f 88 e2 00 00 00    	js     802e3c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d5a:	83 ec 04             	sub    $0x4,%esp
  802d5d:	68 07 04 00 00       	push   $0x407
  802d62:	ff 75 f0             	pushl  -0x10(%ebp)
  802d65:	6a 00                	push   $0x0
  802d67:	e8 1b e8 ff ff       	call   801587 <sys_page_alloc>
  802d6c:	89 c3                	mov    %eax,%ebx
  802d6e:	83 c4 10             	add    $0x10,%esp
  802d71:	85 c0                	test   %eax,%eax
  802d73:	0f 88 c3 00 00 00    	js     802e3c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d79:	83 ec 0c             	sub    $0xc,%esp
  802d7c:	ff 75 f4             	pushl  -0xc(%ebp)
  802d7f:	e8 40 ee ff ff       	call   801bc4 <fd2data>
  802d84:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d86:	83 c4 0c             	add    $0xc,%esp
  802d89:	68 07 04 00 00       	push   $0x407
  802d8e:	50                   	push   %eax
  802d8f:	6a 00                	push   $0x0
  802d91:	e8 f1 e7 ff ff       	call   801587 <sys_page_alloc>
  802d96:	89 c3                	mov    %eax,%ebx
  802d98:	83 c4 10             	add    $0x10,%esp
  802d9b:	85 c0                	test   %eax,%eax
  802d9d:	0f 88 89 00 00 00    	js     802e2c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802da3:	83 ec 0c             	sub    $0xc,%esp
  802da6:	ff 75 f0             	pushl  -0x10(%ebp)
  802da9:	e8 16 ee ff ff       	call   801bc4 <fd2data>
  802dae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802db5:	50                   	push   %eax
  802db6:	6a 00                	push   $0x0
  802db8:	56                   	push   %esi
  802db9:	6a 00                	push   $0x0
  802dbb:	e8 0a e8 ff ff       	call   8015ca <sys_page_map>
  802dc0:	89 c3                	mov    %eax,%ebx
  802dc2:	83 c4 20             	add    $0x20,%esp
  802dc5:	85 c0                	test   %eax,%eax
  802dc7:	78 55                	js     802e1e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802dc9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dd2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dd7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802dde:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802de4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802de7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802df3:	83 ec 0c             	sub    $0xc,%esp
  802df6:	ff 75 f4             	pushl  -0xc(%ebp)
  802df9:	e8 b6 ed ff ff       	call   801bb4 <fd2num>
  802dfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802e01:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802e03:	83 c4 04             	add    $0x4,%esp
  802e06:	ff 75 f0             	pushl  -0x10(%ebp)
  802e09:	e8 a6 ed ff ff       	call   801bb4 <fd2num>
  802e0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802e11:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802e14:	83 c4 10             	add    $0x10,%esp
  802e17:	ba 00 00 00 00       	mov    $0x0,%edx
  802e1c:	eb 30                	jmp    802e4e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802e1e:	83 ec 08             	sub    $0x8,%esp
  802e21:	56                   	push   %esi
  802e22:	6a 00                	push   $0x0
  802e24:	e8 e3 e7 ff ff       	call   80160c <sys_page_unmap>
  802e29:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802e2c:	83 ec 08             	sub    $0x8,%esp
  802e2f:	ff 75 f0             	pushl  -0x10(%ebp)
  802e32:	6a 00                	push   $0x0
  802e34:	e8 d3 e7 ff ff       	call   80160c <sys_page_unmap>
  802e39:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802e3c:	83 ec 08             	sub    $0x8,%esp
  802e3f:	ff 75 f4             	pushl  -0xc(%ebp)
  802e42:	6a 00                	push   $0x0
  802e44:	e8 c3 e7 ff ff       	call   80160c <sys_page_unmap>
  802e49:	83 c4 10             	add    $0x10,%esp
  802e4c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802e4e:	89 d0                	mov    %edx,%eax
  802e50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e53:	5b                   	pop    %ebx
  802e54:	5e                   	pop    %esi
  802e55:	5d                   	pop    %ebp
  802e56:	c3                   	ret    

00802e57 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e57:	55                   	push   %ebp
  802e58:	89 e5                	mov    %esp,%ebp
  802e5a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e60:	50                   	push   %eax
  802e61:	ff 75 08             	pushl  0x8(%ebp)
  802e64:	e8 c1 ed ff ff       	call   801c2a <fd_lookup>
  802e69:	83 c4 10             	add    $0x10,%esp
  802e6c:	85 c0                	test   %eax,%eax
  802e6e:	78 18                	js     802e88 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e70:	83 ec 0c             	sub    $0xc,%esp
  802e73:	ff 75 f4             	pushl  -0xc(%ebp)
  802e76:	e8 49 ed ff ff       	call   801bc4 <fd2data>
	return _pipeisclosed(fd, p);
  802e7b:	89 c2                	mov    %eax,%edx
  802e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e80:	e8 21 fd ff ff       	call   802ba6 <_pipeisclosed>
  802e85:	83 c4 10             	add    $0x10,%esp
}
  802e88:	c9                   	leave  
  802e89:	c3                   	ret    

00802e8a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e8a:	55                   	push   %ebp
  802e8b:	89 e5                	mov    %esp,%ebp
  802e8d:	56                   	push   %esi
  802e8e:	53                   	push   %ebx
  802e8f:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e92:	85 f6                	test   %esi,%esi
  802e94:	75 16                	jne    802eac <wait+0x22>
  802e96:	68 d7 3a 80 00       	push   $0x803ad7
  802e9b:	68 77 34 80 00       	push   $0x803477
  802ea0:	6a 09                	push   $0x9
  802ea2:	68 e2 3a 80 00       	push   $0x803ae2
  802ea7:	e8 87 db ff ff       	call   800a33 <_panic>
	e = &envs[ENVX(envid)];
  802eac:	89 f3                	mov    %esi,%ebx
  802eae:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802eb4:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802eb7:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802ebd:	eb 05                	jmp    802ec4 <wait+0x3a>
		sys_yield();
  802ebf:	e8 a4 e6 ff ff       	call   801568 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ec4:	8b 43 48             	mov    0x48(%ebx),%eax
  802ec7:	39 c6                	cmp    %eax,%esi
  802ec9:	75 07                	jne    802ed2 <wait+0x48>
  802ecb:	8b 43 54             	mov    0x54(%ebx),%eax
  802ece:	85 c0                	test   %eax,%eax
  802ed0:	75 ed                	jne    802ebf <wait+0x35>
		sys_yield();
}
  802ed2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ed5:	5b                   	pop    %ebx
  802ed6:	5e                   	pop    %esi
  802ed7:	5d                   	pop    %ebp
  802ed8:	c3                   	ret    

00802ed9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802ed9:	55                   	push   %ebp
  802eda:	89 e5                	mov    %esp,%ebp
  802edc:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  802edf:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802ee6:	75 2a                	jne    802f12 <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  802ee8:	83 ec 04             	sub    $0x4,%esp
  802eeb:	6a 06                	push   $0x6
  802eed:	68 00 f0 bf ee       	push   $0xeebff000
  802ef2:	6a 00                	push   $0x0
  802ef4:	e8 8e e6 ff ff       	call   801587 <sys_page_alloc>
			 if (a < 0)
  802ef9:	83 c4 10             	add    $0x10,%esp
  802efc:	85 c0                	test   %eax,%eax
  802efe:	79 12                	jns    802f12 <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  802f00:	50                   	push   %eax
  802f01:	68 ed 3a 80 00       	push   $0x803aed
  802f06:	6a 21                	push   $0x21
  802f08:	68 07 3b 80 00       	push   $0x803b07
  802f0d:	e8 21 db ff ff       	call   800a33 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  802f12:	e8 32 e6 ff ff       	call   801549 <sys_getenvid>
  802f17:	83 ec 08             	sub    $0x8,%esp
  802f1a:	68 32 2f 80 00       	push   $0x802f32
  802f1f:	50                   	push   %eax
  802f20:	e8 ad e7 ff ff       	call   8016d2 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  802f25:	8b 45 08             	mov    0x8(%ebp),%eax
  802f28:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802f2d:	83 c4 10             	add    $0x10,%esp
  802f30:	c9                   	leave  
  802f31:	c3                   	ret    

00802f32 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  802f32:	54                   	push   %esp
movl _pgfault_handler, %eax
  802f33:	a1 00 70 80 00       	mov    0x807000,%eax
call *%eax
  802f38:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  802f3a:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  802f3d:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  802f41:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  802f45:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  802f48:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  802f4c:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  802f4e:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  802f51:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  802f52:	83 c4 04             	add    $0x4,%esp
popfl
  802f55:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  802f56:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  802f57:	c3                   	ret    

00802f58 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f58:	55                   	push   %ebp
  802f59:	89 e5                	mov    %esp,%ebp
  802f5b:	56                   	push   %esi
  802f5c:	53                   	push   %ebx
  802f5d:	8b 75 08             	mov    0x8(%ebp),%esi
  802f60:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  802f66:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  802f68:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802f6d:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  802f70:	83 ec 0c             	sub    $0xc,%esp
  802f73:	50                   	push   %eax
  802f74:	e8 be e7 ff ff       	call   801737 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  802f79:	83 c4 10             	add    $0x10,%esp
  802f7c:	85 c0                	test   %eax,%eax
  802f7e:	78 0e                	js     802f8e <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  802f80:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802f86:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  802f89:	8b 52 78             	mov    0x78(%edx),%edx
  802f8c:	eb 0a                	jmp    802f98 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  802f8e:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  802f93:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  802f98:	85 f6                	test   %esi,%esi
  802f9a:	74 02                	je     802f9e <ipc_recv+0x46>
			 *from_env_store = s_envid;
  802f9c:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  802f9e:	85 db                	test   %ebx,%ebx
  802fa0:	74 02                	je     802fa4 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  802fa2:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  802fa4:	85 c0                	test   %eax,%eax
  802fa6:	78 08                	js     802fb0 <ipc_recv+0x58>
  802fa8:	a1 24 54 80 00       	mov    0x805424,%eax
  802fad:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  802fb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fb3:	5b                   	pop    %ebx
  802fb4:	5e                   	pop    %esi
  802fb5:	5d                   	pop    %ebp
  802fb6:	c3                   	ret    

00802fb7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802fb7:	55                   	push   %ebp
  802fb8:	89 e5                	mov    %esp,%ebp
  802fba:	57                   	push   %edi
  802fbb:	56                   	push   %esi
  802fbc:	53                   	push   %ebx
  802fbd:	83 ec 0c             	sub    $0xc,%esp
  802fc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  802fc3:	8b 75 0c             	mov    0xc(%ebp),%esi
  802fc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  802fc9:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  802fcb:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802fd0:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  802fd3:	ff 75 14             	pushl  0x14(%ebp)
  802fd6:	53                   	push   %ebx
  802fd7:	56                   	push   %esi
  802fd8:	57                   	push   %edi
  802fd9:	e8 36 e7 ff ff       	call   801714 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  802fde:	83 c4 10             	add    $0x10,%esp
  802fe1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802fe4:	75 07                	jne    802fed <ipc_send+0x36>
				    sys_yield();
  802fe6:	e8 7d e5 ff ff       	call   801568 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  802feb:	eb e6                	jmp    802fd3 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  802fed:	85 c0                	test   %eax,%eax
  802fef:	74 12                	je     803003 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  802ff1:	50                   	push   %eax
  802ff2:	68 15 3b 80 00       	push   $0x803b15
  802ff7:	6a 4b                	push   $0x4b
  802ff9:	68 29 3b 80 00       	push   $0x803b29
  802ffe:	e8 30 da ff ff       	call   800a33 <_panic>
			 }
	   }
}
  803003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803006:	5b                   	pop    %ebx
  803007:	5e                   	pop    %esi
  803008:	5f                   	pop    %edi
  803009:	5d                   	pop    %ebp
  80300a:	c3                   	ret    

0080300b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  80300b:	55                   	push   %ebp
  80300c:	89 e5                	mov    %esp,%ebp
  80300e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  803011:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  803016:	6b d0 7c             	imul   $0x7c,%eax,%edx
  803019:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80301f:	8b 52 50             	mov    0x50(%edx),%edx
  803022:	39 ca                	cmp    %ecx,%edx
  803024:	75 0d                	jne    803033 <ipc_find_env+0x28>
				    return envs[i].env_id;
  803026:	6b c0 7c             	imul   $0x7c,%eax,%eax
  803029:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80302e:	8b 40 48             	mov    0x48(%eax),%eax
  803031:	eb 0f                	jmp    803042 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  803033:	83 c0 01             	add    $0x1,%eax
  803036:	3d 00 04 00 00       	cmp    $0x400,%eax
  80303b:	75 d9                	jne    803016 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  80303d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803042:	5d                   	pop    %ebp
  803043:	c3                   	ret    

00803044 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803044:	55                   	push   %ebp
  803045:	89 e5                	mov    %esp,%ebp
  803047:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80304a:	89 d0                	mov    %edx,%eax
  80304c:	c1 e8 16             	shr    $0x16,%eax
  80304f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803056:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80305b:	f6 c1 01             	test   $0x1,%cl
  80305e:	74 1d                	je     80307d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803060:	c1 ea 0c             	shr    $0xc,%edx
  803063:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80306a:	f6 c2 01             	test   $0x1,%dl
  80306d:	74 0e                	je     80307d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80306f:	c1 ea 0c             	shr    $0xc,%edx
  803072:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803079:	ef 
  80307a:	0f b7 c0             	movzwl %ax,%eax
}
  80307d:	5d                   	pop    %ebp
  80307e:	c3                   	ret    
  80307f:	90                   	nop

00803080 <__udivdi3>:
  803080:	55                   	push   %ebp
  803081:	57                   	push   %edi
  803082:	56                   	push   %esi
  803083:	53                   	push   %ebx
  803084:	83 ec 1c             	sub    $0x1c,%esp
  803087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80308b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80308f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803097:	85 f6                	test   %esi,%esi
  803099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80309d:	89 ca                	mov    %ecx,%edx
  80309f:	89 f8                	mov    %edi,%eax
  8030a1:	75 3d                	jne    8030e0 <__udivdi3+0x60>
  8030a3:	39 cf                	cmp    %ecx,%edi
  8030a5:	0f 87 c5 00 00 00    	ja     803170 <__udivdi3+0xf0>
  8030ab:	85 ff                	test   %edi,%edi
  8030ad:	89 fd                	mov    %edi,%ebp
  8030af:	75 0b                	jne    8030bc <__udivdi3+0x3c>
  8030b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8030b6:	31 d2                	xor    %edx,%edx
  8030b8:	f7 f7                	div    %edi
  8030ba:	89 c5                	mov    %eax,%ebp
  8030bc:	89 c8                	mov    %ecx,%eax
  8030be:	31 d2                	xor    %edx,%edx
  8030c0:	f7 f5                	div    %ebp
  8030c2:	89 c1                	mov    %eax,%ecx
  8030c4:	89 d8                	mov    %ebx,%eax
  8030c6:	89 cf                	mov    %ecx,%edi
  8030c8:	f7 f5                	div    %ebp
  8030ca:	89 c3                	mov    %eax,%ebx
  8030cc:	89 d8                	mov    %ebx,%eax
  8030ce:	89 fa                	mov    %edi,%edx
  8030d0:	83 c4 1c             	add    $0x1c,%esp
  8030d3:	5b                   	pop    %ebx
  8030d4:	5e                   	pop    %esi
  8030d5:	5f                   	pop    %edi
  8030d6:	5d                   	pop    %ebp
  8030d7:	c3                   	ret    
  8030d8:	90                   	nop
  8030d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8030e0:	39 ce                	cmp    %ecx,%esi
  8030e2:	77 74                	ja     803158 <__udivdi3+0xd8>
  8030e4:	0f bd fe             	bsr    %esi,%edi
  8030e7:	83 f7 1f             	xor    $0x1f,%edi
  8030ea:	0f 84 98 00 00 00    	je     803188 <__udivdi3+0x108>
  8030f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8030f5:	89 f9                	mov    %edi,%ecx
  8030f7:	89 c5                	mov    %eax,%ebp
  8030f9:	29 fb                	sub    %edi,%ebx
  8030fb:	d3 e6                	shl    %cl,%esi
  8030fd:	89 d9                	mov    %ebx,%ecx
  8030ff:	d3 ed                	shr    %cl,%ebp
  803101:	89 f9                	mov    %edi,%ecx
  803103:	d3 e0                	shl    %cl,%eax
  803105:	09 ee                	or     %ebp,%esi
  803107:	89 d9                	mov    %ebx,%ecx
  803109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80310d:	89 d5                	mov    %edx,%ebp
  80310f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803113:	d3 ed                	shr    %cl,%ebp
  803115:	89 f9                	mov    %edi,%ecx
  803117:	d3 e2                	shl    %cl,%edx
  803119:	89 d9                	mov    %ebx,%ecx
  80311b:	d3 e8                	shr    %cl,%eax
  80311d:	09 c2                	or     %eax,%edx
  80311f:	89 d0                	mov    %edx,%eax
  803121:	89 ea                	mov    %ebp,%edx
  803123:	f7 f6                	div    %esi
  803125:	89 d5                	mov    %edx,%ebp
  803127:	89 c3                	mov    %eax,%ebx
  803129:	f7 64 24 0c          	mull   0xc(%esp)
  80312d:	39 d5                	cmp    %edx,%ebp
  80312f:	72 10                	jb     803141 <__udivdi3+0xc1>
  803131:	8b 74 24 08          	mov    0x8(%esp),%esi
  803135:	89 f9                	mov    %edi,%ecx
  803137:	d3 e6                	shl    %cl,%esi
  803139:	39 c6                	cmp    %eax,%esi
  80313b:	73 07                	jae    803144 <__udivdi3+0xc4>
  80313d:	39 d5                	cmp    %edx,%ebp
  80313f:	75 03                	jne    803144 <__udivdi3+0xc4>
  803141:	83 eb 01             	sub    $0x1,%ebx
  803144:	31 ff                	xor    %edi,%edi
  803146:	89 d8                	mov    %ebx,%eax
  803148:	89 fa                	mov    %edi,%edx
  80314a:	83 c4 1c             	add    $0x1c,%esp
  80314d:	5b                   	pop    %ebx
  80314e:	5e                   	pop    %esi
  80314f:	5f                   	pop    %edi
  803150:	5d                   	pop    %ebp
  803151:	c3                   	ret    
  803152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803158:	31 ff                	xor    %edi,%edi
  80315a:	31 db                	xor    %ebx,%ebx
  80315c:	89 d8                	mov    %ebx,%eax
  80315e:	89 fa                	mov    %edi,%edx
  803160:	83 c4 1c             	add    $0x1c,%esp
  803163:	5b                   	pop    %ebx
  803164:	5e                   	pop    %esi
  803165:	5f                   	pop    %edi
  803166:	5d                   	pop    %ebp
  803167:	c3                   	ret    
  803168:	90                   	nop
  803169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803170:	89 d8                	mov    %ebx,%eax
  803172:	f7 f7                	div    %edi
  803174:	31 ff                	xor    %edi,%edi
  803176:	89 c3                	mov    %eax,%ebx
  803178:	89 d8                	mov    %ebx,%eax
  80317a:	89 fa                	mov    %edi,%edx
  80317c:	83 c4 1c             	add    $0x1c,%esp
  80317f:	5b                   	pop    %ebx
  803180:	5e                   	pop    %esi
  803181:	5f                   	pop    %edi
  803182:	5d                   	pop    %ebp
  803183:	c3                   	ret    
  803184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803188:	39 ce                	cmp    %ecx,%esi
  80318a:	72 0c                	jb     803198 <__udivdi3+0x118>
  80318c:	31 db                	xor    %ebx,%ebx
  80318e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803192:	0f 87 34 ff ff ff    	ja     8030cc <__udivdi3+0x4c>
  803198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80319d:	e9 2a ff ff ff       	jmp    8030cc <__udivdi3+0x4c>
  8031a2:	66 90                	xchg   %ax,%ax
  8031a4:	66 90                	xchg   %ax,%ax
  8031a6:	66 90                	xchg   %ax,%ax
  8031a8:	66 90                	xchg   %ax,%ax
  8031aa:	66 90                	xchg   %ax,%ax
  8031ac:	66 90                	xchg   %ax,%ax
  8031ae:	66 90                	xchg   %ax,%ax

008031b0 <__umoddi3>:
  8031b0:	55                   	push   %ebp
  8031b1:	57                   	push   %edi
  8031b2:	56                   	push   %esi
  8031b3:	53                   	push   %ebx
  8031b4:	83 ec 1c             	sub    $0x1c,%esp
  8031b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8031bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8031bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8031c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8031c7:	85 d2                	test   %edx,%edx
  8031c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8031cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8031d1:	89 f3                	mov    %esi,%ebx
  8031d3:	89 3c 24             	mov    %edi,(%esp)
  8031d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8031da:	75 1c                	jne    8031f8 <__umoddi3+0x48>
  8031dc:	39 f7                	cmp    %esi,%edi
  8031de:	76 50                	jbe    803230 <__umoddi3+0x80>
  8031e0:	89 c8                	mov    %ecx,%eax
  8031e2:	89 f2                	mov    %esi,%edx
  8031e4:	f7 f7                	div    %edi
  8031e6:	89 d0                	mov    %edx,%eax
  8031e8:	31 d2                	xor    %edx,%edx
  8031ea:	83 c4 1c             	add    $0x1c,%esp
  8031ed:	5b                   	pop    %ebx
  8031ee:	5e                   	pop    %esi
  8031ef:	5f                   	pop    %edi
  8031f0:	5d                   	pop    %ebp
  8031f1:	c3                   	ret    
  8031f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8031f8:	39 f2                	cmp    %esi,%edx
  8031fa:	89 d0                	mov    %edx,%eax
  8031fc:	77 52                	ja     803250 <__umoddi3+0xa0>
  8031fe:	0f bd ea             	bsr    %edx,%ebp
  803201:	83 f5 1f             	xor    $0x1f,%ebp
  803204:	75 5a                	jne    803260 <__umoddi3+0xb0>
  803206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80320a:	0f 82 e0 00 00 00    	jb     8032f0 <__umoddi3+0x140>
  803210:	39 0c 24             	cmp    %ecx,(%esp)
  803213:	0f 86 d7 00 00 00    	jbe    8032f0 <__umoddi3+0x140>
  803219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80321d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803221:	83 c4 1c             	add    $0x1c,%esp
  803224:	5b                   	pop    %ebx
  803225:	5e                   	pop    %esi
  803226:	5f                   	pop    %edi
  803227:	5d                   	pop    %ebp
  803228:	c3                   	ret    
  803229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803230:	85 ff                	test   %edi,%edi
  803232:	89 fd                	mov    %edi,%ebp
  803234:	75 0b                	jne    803241 <__umoddi3+0x91>
  803236:	b8 01 00 00 00       	mov    $0x1,%eax
  80323b:	31 d2                	xor    %edx,%edx
  80323d:	f7 f7                	div    %edi
  80323f:	89 c5                	mov    %eax,%ebp
  803241:	89 f0                	mov    %esi,%eax
  803243:	31 d2                	xor    %edx,%edx
  803245:	f7 f5                	div    %ebp
  803247:	89 c8                	mov    %ecx,%eax
  803249:	f7 f5                	div    %ebp
  80324b:	89 d0                	mov    %edx,%eax
  80324d:	eb 99                	jmp    8031e8 <__umoddi3+0x38>
  80324f:	90                   	nop
  803250:	89 c8                	mov    %ecx,%eax
  803252:	89 f2                	mov    %esi,%edx
  803254:	83 c4 1c             	add    $0x1c,%esp
  803257:	5b                   	pop    %ebx
  803258:	5e                   	pop    %esi
  803259:	5f                   	pop    %edi
  80325a:	5d                   	pop    %ebp
  80325b:	c3                   	ret    
  80325c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803260:	8b 34 24             	mov    (%esp),%esi
  803263:	bf 20 00 00 00       	mov    $0x20,%edi
  803268:	89 e9                	mov    %ebp,%ecx
  80326a:	29 ef                	sub    %ebp,%edi
  80326c:	d3 e0                	shl    %cl,%eax
  80326e:	89 f9                	mov    %edi,%ecx
  803270:	89 f2                	mov    %esi,%edx
  803272:	d3 ea                	shr    %cl,%edx
  803274:	89 e9                	mov    %ebp,%ecx
  803276:	09 c2                	or     %eax,%edx
  803278:	89 d8                	mov    %ebx,%eax
  80327a:	89 14 24             	mov    %edx,(%esp)
  80327d:	89 f2                	mov    %esi,%edx
  80327f:	d3 e2                	shl    %cl,%edx
  803281:	89 f9                	mov    %edi,%ecx
  803283:	89 54 24 04          	mov    %edx,0x4(%esp)
  803287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80328b:	d3 e8                	shr    %cl,%eax
  80328d:	89 e9                	mov    %ebp,%ecx
  80328f:	89 c6                	mov    %eax,%esi
  803291:	d3 e3                	shl    %cl,%ebx
  803293:	89 f9                	mov    %edi,%ecx
  803295:	89 d0                	mov    %edx,%eax
  803297:	d3 e8                	shr    %cl,%eax
  803299:	89 e9                	mov    %ebp,%ecx
  80329b:	09 d8                	or     %ebx,%eax
  80329d:	89 d3                	mov    %edx,%ebx
  80329f:	89 f2                	mov    %esi,%edx
  8032a1:	f7 34 24             	divl   (%esp)
  8032a4:	89 d6                	mov    %edx,%esi
  8032a6:	d3 e3                	shl    %cl,%ebx
  8032a8:	f7 64 24 04          	mull   0x4(%esp)
  8032ac:	39 d6                	cmp    %edx,%esi
  8032ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8032b2:	89 d1                	mov    %edx,%ecx
  8032b4:	89 c3                	mov    %eax,%ebx
  8032b6:	72 08                	jb     8032c0 <__umoddi3+0x110>
  8032b8:	75 11                	jne    8032cb <__umoddi3+0x11b>
  8032ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8032be:	73 0b                	jae    8032cb <__umoddi3+0x11b>
  8032c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8032c4:	1b 14 24             	sbb    (%esp),%edx
  8032c7:	89 d1                	mov    %edx,%ecx
  8032c9:	89 c3                	mov    %eax,%ebx
  8032cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8032cf:	29 da                	sub    %ebx,%edx
  8032d1:	19 ce                	sbb    %ecx,%esi
  8032d3:	89 f9                	mov    %edi,%ecx
  8032d5:	89 f0                	mov    %esi,%eax
  8032d7:	d3 e0                	shl    %cl,%eax
  8032d9:	89 e9                	mov    %ebp,%ecx
  8032db:	d3 ea                	shr    %cl,%edx
  8032dd:	89 e9                	mov    %ebp,%ecx
  8032df:	d3 ee                	shr    %cl,%esi
  8032e1:	09 d0                	or     %edx,%eax
  8032e3:	89 f2                	mov    %esi,%edx
  8032e5:	83 c4 1c             	add    $0x1c,%esp
  8032e8:	5b                   	pop    %ebx
  8032e9:	5e                   	pop    %esi
  8032ea:	5f                   	pop    %edi
  8032eb:	5d                   	pop    %ebp
  8032ec:	c3                   	ret    
  8032ed:	8d 76 00             	lea    0x0(%esi),%esi
  8032f0:	29 f9                	sub    %edi,%ecx
  8032f2:	19 d6                	sbb    %edx,%esi
  8032f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8032f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8032fc:	e9 18 ff ff ff       	jmp    803219 <__umoddi3+0x69>
