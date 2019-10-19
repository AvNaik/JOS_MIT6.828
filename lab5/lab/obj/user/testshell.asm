
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 11 18 00 00       	call   801860 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 07 18 00 00       	call   801860 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 06 0e 00 00       	call   800e89 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 68 16 00 00       	call   8016fa <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 fa 2a 80 00       	push   $0x802afa
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 d1 0d 00 00       	call   800e89 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 33 16 00 00       	call   8016fa <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 f5 2a 80 00       	push   $0x802af5
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 c3 14 00 00       	call   8015be <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 b7 14 00 00       	call   8015be <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 08 2b 80 00       	push   $0x802b08
  80011b:	e8 ae 1a 00 00       	call   801bce <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 15 2b 80 00       	push   $0x802b15
  80012f:	6a 13                	push   $0x13
  800131:	68 2b 2b 80 00       	push   $0x802b2b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 17 23 00 00       	call   80245e <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 3c 2b 80 00       	push   $0x802b3c
  800154:	6a 15                	push   $0x15
  800156:	68 2b 2b 80 00       	push   $0x802b2b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 a4 2a 80 00       	push   $0x802aa4
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 aa 10 00 00       	call   80121f <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 88 2f 80 00       	push   $0x802f88
  800182:	6a 1a                	push   $0x1a
  800184:	68 2b 2b 80 00       	push   $0x802b2b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 71 14 00 00       	call   80160e <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 66 14 00 00       	call   80160e <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 0e 14 00 00       	call   8015be <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 06 14 00 00       	call   8015be <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 45 2b 80 00       	push   $0x802b45
  8001bf:	68 12 2b 80 00       	push   $0x802b12
  8001c4:	68 48 2b 80 00       	push   $0x802b48
  8001c9:	e8 47 20 00 00       	call   802215 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 4c 2b 80 00       	push   $0x802b4c
  8001dd:	6a 21                	push   $0x21
  8001df:	68 2b 2b 80 00       	push   $0x802b2b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 cb 13 00 00       	call   8015be <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 bf 13 00 00       	call   8015be <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 dd 23 00 00       	call   8025e4 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 a6 13 00 00       	call   8015be <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 9e 13 00 00       	call   8015be <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 56 2b 80 00       	push   $0x802b56
  800230:	e8 99 19 00 00       	call   801bce <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 c8 2a 80 00       	push   $0x802ac8
  800245:	6a 2c                	push   $0x2c
  800247:	68 2b 2b 80 00       	push   $0x802b2b
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 8e 14 00 00       	call   8016fa <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 7b 14 00 00       	call   8016fa <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 64 2b 80 00       	push   $0x802b64
  80028c:	6a 33                	push   $0x33
  80028e:	68 2b 2b 80 00       	push   $0x802b2b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 7e 2b 80 00       	push   $0x802b7e
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 2b 2b 80 00       	push   $0x802b2b
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 98 2b 80 00       	push   $0x802b98
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 ad 2b 80 00       	push   $0x802bad
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 24 08 00 00       	call   800b42 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 78 09 00 00       	call   800cd4 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 23 0b 00 00       	call   800e89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 94 0b 00 00       	call   800f26 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 10 0b 00 00       	call   800ea7 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 bb 0a 00 00       	call   800e89 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 14 13 00 00       	call   8016fa <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 84 10 00 00       	call   801494 <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 0c 10 00 00       	call   801445 <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 f1 0a 00 00       	call   800f45 <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 a3 0f 00 00       	call   80141e <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80048f:	e8 73 0a 00 00       	call   800f07 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 14 11 00 00       	call   8015e9 <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 e7 09 00 00       	call   800ec6 <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 10 0a 00 00       	call   800f07 <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 c4 2b 80 00       	push   $0x802bc4
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 f8 2a 80 00 	movl   $0x802af8,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 2f 09 00 00       	call   800e89 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 54 01 00 00       	call   8006f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 d4 08 00 00       	call   800e89 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 bb 21 00 00       	call   8027e0 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 a8 22 00 00       	call   802910 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 e7 2b 80 00 	movsbl 0x802be7(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 0e                	jle    800696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	8b 52 04             	mov    0x4(%edx),%edx
  800694:	eb 22                	jmp    8006b8 <getuint+0x38>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 10                	je     8006aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a8:	eb 0e                	jmp    8006b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c9:	73 0a                	jae    8006d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ce:	89 08                	mov    %ecx,(%eax)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	88 02                	mov    %al,(%edx)
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 05 00 00 00       	call   8006f4 <vprintfmt>
	va_end(ap);
}
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 2c             	sub    $0x2c,%esp
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800703:	8b 7d 10             	mov    0x10(%ebp),%edi
  800706:	eb 12                	jmp    80071a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 89 03 00 00    	je     800a99 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071a:	83 c7 01             	add    $0x1,%edi
  80071d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800721:	83 f8 25             	cmp    $0x25,%eax
  800724:	75 e2                	jne    800708 <vprintfmt+0x14>
  800726:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80072a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800731:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800738:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 07                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800749:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8d 47 01             	lea    0x1(%edi),%eax
  800750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800753:	0f b6 07             	movzbl (%edi),%eax
  800756:	0f b6 c8             	movzbl %al,%ecx
  800759:	83 e8 23             	sub    $0x23,%eax
  80075c:	3c 55                	cmp    $0x55,%al
  80075e:	0f 87 1a 03 00 00    	ja     800a7e <vprintfmt+0x38a>
  800764:	0f b6 c0             	movzbl %al,%eax
  800767:	ff 24 85 20 2d 80 00 	jmp    *0x802d20(,%eax,4)
  80076e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800771:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800775:	eb d6                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800782:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800785:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800789:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80078c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80078f:	83 fa 09             	cmp    $0x9,%edx
  800792:	77 39                	ja     8007cd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800794:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800797:	eb e9                	jmp    800782 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 48 04             	lea    0x4(%eax),%ecx
  80079f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007aa:	eb 27                	jmp    8007d3 <vprintfmt+0xdf>
  8007ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	0f 49 c8             	cmovns %eax,%ecx
  8007b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bf:	eb 8c                	jmp    80074d <vprintfmt+0x59>
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007cb:	eb 80                	jmp    80074d <vprintfmt+0x59>
  8007cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d7:	0f 89 70 ff ff ff    	jns    80074d <vprintfmt+0x59>
				width = precision, precision = -1;
  8007dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ea:	e9 5e ff ff ff       	jmp    80074d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ef:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f5:	e9 53 ff ff ff       	jmp    80074d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	ff 30                	pushl  (%eax)
  800809:	ff d6                	call   *%esi
			break;
  80080b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800811:	e9 04 ff ff ff       	jmp    80071a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	99                   	cltd   
  800822:	31 d0                	xor    %edx,%eax
  800824:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800826:	83 f8 0f             	cmp    $0xf,%eax
  800829:	7f 0b                	jg     800836 <vprintfmt+0x142>
  80082b:	8b 14 85 80 2e 80 00 	mov    0x802e80(,%eax,4),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	75 18                	jne    80084e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800836:	50                   	push   %eax
  800837:	68 ff 2b 80 00       	push   $0x802bff
  80083c:	53                   	push   %ebx
  80083d:	56                   	push   %esi
  80083e:	e8 94 fe ff ff       	call   8006d7 <printfmt>
  800843:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800849:	e9 cc fe ff ff       	jmp    80071a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80084e:	52                   	push   %edx
  80084f:	68 5d 30 80 00       	push   $0x80305d
  800854:	53                   	push   %ebx
  800855:	56                   	push   %esi
  800856:	e8 7c fe ff ff       	call   8006d7 <printfmt>
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800861:	e9 b4 fe ff ff       	jmp    80071a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)
  80086f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800871:	85 ff                	test   %edi,%edi
  800873:	b8 f8 2b 80 00       	mov    $0x802bf8,%eax
  800878:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80087b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80087f:	0f 8e 94 00 00 00    	jle    800919 <vprintfmt+0x225>
  800885:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800889:	0f 84 98 00 00 00    	je     800927 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	ff 75 d0             	pushl  -0x30(%ebp)
  800895:	57                   	push   %edi
  800896:	e8 86 02 00 00       	call   800b21 <strnlen>
  80089b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80089e:	29 c1                	sub    %eax,%ecx
  8008a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b2:	eb 0f                	jmp    8008c3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	85 ff                	test   %edi,%edi
  8008c5:	7f ed                	jg     8008b4 <vprintfmt+0x1c0>
  8008c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008ca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008cd:	85 c9                	test   %ecx,%ecx
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	0f 49 c1             	cmovns %ecx,%eax
  8008d7:	29 c1                	sub    %eax,%ecx
  8008d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e2:	89 cb                	mov    %ecx,%ebx
  8008e4:	eb 4d                	jmp    800933 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ea:	74 1b                	je     800907 <vprintfmt+0x213>
  8008ec:	0f be c0             	movsbl %al,%eax
  8008ef:	83 e8 20             	sub    $0x20,%eax
  8008f2:	83 f8 5e             	cmp    $0x5e,%eax
  8008f5:	76 10                	jbe    800907 <vprintfmt+0x213>
					putch('?', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	6a 3f                	push   $0x3f
  8008ff:	ff 55 08             	call   *0x8(%ebp)
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 0d                	jmp    800914 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	52                   	push   %edx
  80090e:	ff 55 08             	call   *0x8(%ebp)
  800911:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800914:	83 eb 01             	sub    $0x1,%ebx
  800917:	eb 1a                	jmp    800933 <vprintfmt+0x23f>
  800919:	89 75 08             	mov    %esi,0x8(%ebp)
  80091c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80091f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800922:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800925:	eb 0c                	jmp    800933 <vprintfmt+0x23f>
  800927:	89 75 08             	mov    %esi,0x8(%ebp)
  80092a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80092d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800930:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800933:	83 c7 01             	add    $0x1,%edi
  800936:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093a:	0f be d0             	movsbl %al,%edx
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 23                	je     800964 <vprintfmt+0x270>
  800941:	85 f6                	test   %esi,%esi
  800943:	78 a1                	js     8008e6 <vprintfmt+0x1f2>
  800945:	83 ee 01             	sub    $0x1,%esi
  800948:	79 9c                	jns    8008e6 <vprintfmt+0x1f2>
  80094a:	89 df                	mov    %ebx,%edi
  80094c:	8b 75 08             	mov    0x8(%ebp),%esi
  80094f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800952:	eb 18                	jmp    80096c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 20                	push   $0x20
  80095a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	eb 08                	jmp    80096c <vprintfmt+0x278>
  800964:	89 df                	mov    %ebx,%edi
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096c:	85 ff                	test   %edi,%edi
  80096e:	7f e4                	jg     800954 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800973:	e9 a2 fd ff ff       	jmp    80071a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800978:	83 fa 01             	cmp    $0x1,%edx
  80097b:	7e 16                	jle    800993 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 50 08             	lea    0x8(%eax),%edx
  800983:	89 55 14             	mov    %edx,0x14(%ebp)
  800986:	8b 50 04             	mov    0x4(%eax),%edx
  800989:	8b 00                	mov    (%eax),%eax
  80098b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800991:	eb 32                	jmp    8009c5 <vprintfmt+0x2d1>
	else if (lflag)
  800993:	85 d2                	test   %edx,%edx
  800995:	74 18                	je     8009af <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	8b 00                	mov    (%eax),%eax
  8009a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a5:	89 c1                	mov    %eax,%ecx
  8009a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009ad:	eb 16                	jmp    8009c5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009bd:	89 c1                	mov    %eax,%ecx
  8009bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009d4:	79 74                	jns    800a4a <vprintfmt+0x356>
				putch('-', putdat);
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	53                   	push   %ebx
  8009da:	6a 2d                	push   $0x2d
  8009dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8009de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e4:	f7 d8                	neg    %eax
  8009e6:	83 d2 00             	adc    $0x0,%edx
  8009e9:	f7 da                	neg    %edx
  8009eb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f3:	eb 55                	jmp    800a4a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f8:	e8 83 fc ff ff       	call   800680 <getuint>
			base = 10;
  8009fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a02:	eb 46                	jmp    800a4a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800a04:	8d 45 14             	lea    0x14(%ebp),%eax
  800a07:	e8 74 fc ff ff       	call   800680 <getuint>
			base = 8;
  800a0c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a11:	eb 37                	jmp    800a4a <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	53                   	push   %ebx
  800a17:	6a 30                	push   $0x30
  800a19:	ff d6                	call   *%esi
			putch('x', putdat);
  800a1b:	83 c4 08             	add    $0x8,%esp
  800a1e:	53                   	push   %ebx
  800a1f:	6a 78                	push   $0x78
  800a21:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	8d 50 04             	lea    0x4(%eax),%edx
  800a29:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2c:	8b 00                	mov    (%eax),%eax
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a33:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a36:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a3b:	eb 0d                	jmp    800a4a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a40:	e8 3b fc ff ff       	call   800680 <getuint>
			base = 16;
  800a45:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4a:	83 ec 0c             	sub    $0xc,%esp
  800a4d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a51:	57                   	push   %edi
  800a52:	ff 75 e0             	pushl  -0x20(%ebp)
  800a55:	51                   	push   %ecx
  800a56:	52                   	push   %edx
  800a57:	50                   	push   %eax
  800a58:	89 da                	mov    %ebx,%edx
  800a5a:	89 f0                	mov    %esi,%eax
  800a5c:	e8 70 fb ff ff       	call   8005d1 <printnum>
			break;
  800a61:	83 c4 20             	add    $0x20,%esp
  800a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a67:	e9 ae fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	53                   	push   %ebx
  800a70:	51                   	push   %ecx
  800a71:	ff d6                	call   *%esi
			break;
  800a73:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a79:	e9 9c fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	53                   	push   %ebx
  800a82:	6a 25                	push   $0x25
  800a84:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a86:	83 c4 10             	add    $0x10,%esp
  800a89:	eb 03                	jmp    800a8e <vprintfmt+0x39a>
  800a8b:	83 ef 01             	sub    $0x1,%edi
  800a8e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a92:	75 f7                	jne    800a8b <vprintfmt+0x397>
  800a94:	e9 81 fc ff ff       	jmp    80071a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 18             	sub    $0x18,%esp
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	74 26                	je     800ae8 <vsnprintf+0x47>
  800ac2:	85 d2                	test   %edx,%edx
  800ac4:	7e 22                	jle    800ae8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac6:	ff 75 14             	pushl  0x14(%ebp)
  800ac9:	ff 75 10             	pushl  0x10(%ebp)
  800acc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800acf:	50                   	push   %eax
  800ad0:	68 ba 06 80 00       	push   $0x8006ba
  800ad5:	e8 1a fc ff ff       	call   8006f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800add:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	eb 05                	jmp    800aed <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af8:	50                   	push   %eax
  800af9:	ff 75 10             	pushl  0x10(%ebp)
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	e8 9a ff ff ff       	call   800aa1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	eb 03                	jmp    800b19 <strlen+0x10>
		n++;
  800b16:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b19:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b1d:	75 f7                	jne    800b16 <strlen+0xd>
		n++;
	return n;
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	eb 03                	jmp    800b34 <strnlen+0x13>
		n++;
  800b31:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b34:	39 c2                	cmp    %eax,%edx
  800b36:	74 08                	je     800b40 <strnlen+0x1f>
  800b38:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b3c:	75 f3                	jne    800b31 <strnlen+0x10>
  800b3e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b4c:	89 c2                	mov    %eax,%edx
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b58:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5b:	84 db                	test   %bl,%bl
  800b5d:	75 ef                	jne    800b4e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b69:	53                   	push   %ebx
  800b6a:	e8 9a ff ff ff       	call   800b09 <strlen>
  800b6f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b72:	ff 75 0c             	pushl  0xc(%ebp)
  800b75:	01 d8                	add    %ebx,%eax
  800b77:	50                   	push   %eax
  800b78:	e8 c5 ff ff ff       	call   800b42 <strcpy>
	return dst;
}
  800b7d:	89 d8                	mov    %ebx,%eax
  800b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b94:	89 f2                	mov    %esi,%edx
  800b96:	eb 0f                	jmp    800ba7 <strncpy+0x23>
		*dst++ = *src;
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba1:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba7:	39 da                	cmp    %ebx,%edx
  800ba9:	75 ed                	jne    800b98 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bab:	89 f0                	mov    %esi,%eax
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 10             	mov    0x10(%ebp),%edx
  800bbf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc1:	85 d2                	test   %edx,%edx
  800bc3:	74 21                	je     800be6 <strlcpy+0x35>
  800bc5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bc9:	89 f2                	mov    %esi,%edx
  800bcb:	eb 09                	jmp    800bd6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd6:	39 c2                	cmp    %eax,%edx
  800bd8:	74 09                	je     800be3 <strlcpy+0x32>
  800bda:	0f b6 19             	movzbl (%ecx),%ebx
  800bdd:	84 db                	test   %bl,%bl
  800bdf:	75 ec                	jne    800bcd <strlcpy+0x1c>
  800be1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800be3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be6:	29 f0                	sub    %esi,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf5:	eb 06                	jmp    800bfd <strcmp+0x11>
		p++, q++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bfd:	0f b6 01             	movzbl (%ecx),%eax
  800c00:	84 c0                	test   %al,%al
  800c02:	74 04                	je     800c08 <strcmp+0x1c>
  800c04:	3a 02                	cmp    (%edx),%al
  800c06:	74 ef                	je     800bf7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 c0             	movzbl %al,%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c21:	eb 06                	jmp    800c29 <strncmp+0x17>
		n--, p++, q++;
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c29:	39 d8                	cmp    %ebx,%eax
  800c2b:	74 15                	je     800c42 <strncmp+0x30>
  800c2d:	0f b6 08             	movzbl (%eax),%ecx
  800c30:	84 c9                	test   %cl,%cl
  800c32:	74 04                	je     800c38 <strncmp+0x26>
  800c34:	3a 0a                	cmp    (%edx),%cl
  800c36:	74 eb                	je     800c23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c38:	0f b6 00             	movzbl (%eax),%eax
  800c3b:	0f b6 12             	movzbl (%edx),%edx
  800c3e:	29 d0                	sub    %edx,%eax
  800c40:	eb 05                	jmp    800c47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c54:	eb 07                	jmp    800c5d <strchr+0x13>
		if (*s == c)
  800c56:	38 ca                	cmp    %cl,%dl
  800c58:	74 0f                	je     800c69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 f2                	jne    800c56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	eb 03                	jmp    800c7a <strfind+0xf>
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c7d:	38 ca                	cmp    %cl,%dl
  800c7f:	74 04                	je     800c85 <strfind+0x1a>
  800c81:	84 d2                	test   %dl,%dl
  800c83:	75 f2                	jne    800c77 <strfind+0xc>
			break;
	return (char *) s;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c93:	85 c9                	test   %ecx,%ecx
  800c95:	74 36                	je     800ccd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9d:	75 28                	jne    800cc7 <memset+0x40>
  800c9f:	f6 c1 03             	test   $0x3,%cl
  800ca2:	75 23                	jne    800cc7 <memset+0x40>
		c &= 0xFF;
  800ca4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	c1 e3 08             	shl    $0x8,%ebx
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	c1 e6 18             	shl    $0x18,%esi
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	c1 e0 10             	shl    $0x10,%eax
  800cb7:	09 f0                	or     %esi,%eax
  800cb9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cbb:	89 d8                	mov    %ebx,%eax
  800cbd:	09 d0                	or     %edx,%eax
  800cbf:	c1 e9 02             	shr    $0x2,%ecx
  800cc2:	fc                   	cld    
  800cc3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc5:	eb 06                	jmp    800ccd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	fc                   	cld    
  800ccb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce2:	39 c6                	cmp    %eax,%esi
  800ce4:	73 35                	jae    800d1b <memmove+0x47>
  800ce6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	73 2e                	jae    800d1b <memmove+0x47>
		s += n;
		d += n;
  800ced:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	09 fe                	or     %edi,%esi
  800cf4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfa:	75 13                	jne    800d0f <memmove+0x3b>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 0e                	jne    800d0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d01:	83 ef 04             	sub    $0x4,%edi
  800d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d07:	c1 e9 02             	shr    $0x2,%ecx
  800d0a:	fd                   	std    
  800d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0d:	eb 09                	jmp    800d18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d0f:	83 ef 01             	sub    $0x1,%edi
  800d12:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d15:	fd                   	std    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d18:	fc                   	cld    
  800d19:	eb 1d                	jmp    800d38 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	09 c2                	or     %eax,%edx
  800d1f:	f6 c2 03             	test   $0x3,%dl
  800d22:	75 0f                	jne    800d33 <memmove+0x5f>
  800d24:	f6 c1 03             	test   $0x3,%cl
  800d27:	75 0a                	jne    800d33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d29:	c1 e9 02             	shr    $0x2,%ecx
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	fc                   	cld    
  800d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d31:	eb 05                	jmp    800d38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d33:	89 c7                	mov    %eax,%edi
  800d35:	fc                   	cld    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d3f:	ff 75 10             	pushl  0x10(%ebp)
  800d42:	ff 75 0c             	pushl  0xc(%ebp)
  800d45:	ff 75 08             	pushl  0x8(%ebp)
  800d48:	e8 87 ff ff ff       	call   800cd4 <memmove>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5a:	89 c6                	mov    %eax,%esi
  800d5c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5f:	eb 1a                	jmp    800d7b <memcmp+0x2c>
		if (*s1 != *s2)
  800d61:	0f b6 08             	movzbl (%eax),%ecx
  800d64:	0f b6 1a             	movzbl (%edx),%ebx
  800d67:	38 d9                	cmp    %bl,%cl
  800d69:	74 0a                	je     800d75 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d6b:	0f b6 c1             	movzbl %cl,%eax
  800d6e:	0f b6 db             	movzbl %bl,%ebx
  800d71:	29 d8                	sub    %ebx,%eax
  800d73:	eb 0f                	jmp    800d84 <memcmp+0x35>
		s1++, s2++;
  800d75:	83 c0 01             	add    $0x1,%eax
  800d78:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7b:	39 f0                	cmp    %esi,%eax
  800d7d:	75 e2                	jne    800d61 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	53                   	push   %ebx
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d94:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d98:	eb 0a                	jmp    800da4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9a:	0f b6 10             	movzbl (%eax),%edx
  800d9d:	39 da                	cmp    %ebx,%edx
  800d9f:	74 07                	je     800da8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800da1:	83 c0 01             	add    $0x1,%eax
  800da4:	39 c8                	cmp    %ecx,%eax
  800da6:	72 f2                	jb     800d9a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da8:	5b                   	pop    %ebx
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db7:	eb 03                	jmp    800dbc <strtol+0x11>
		s++;
  800db9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dbc:	0f b6 01             	movzbl (%ecx),%eax
  800dbf:	3c 20                	cmp    $0x20,%al
  800dc1:	74 f6                	je     800db9 <strtol+0xe>
  800dc3:	3c 09                	cmp    $0x9,%al
  800dc5:	74 f2                	je     800db9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc7:	3c 2b                	cmp    $0x2b,%al
  800dc9:	75 0a                	jne    800dd5 <strtol+0x2a>
		s++;
  800dcb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dce:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd3:	eb 11                	jmp    800de6 <strtol+0x3b>
  800dd5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dda:	3c 2d                	cmp    $0x2d,%al
  800ddc:	75 08                	jne    800de6 <strtol+0x3b>
		s++, neg = 1;
  800dde:	83 c1 01             	add    $0x1,%ecx
  800de1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dec:	75 15                	jne    800e03 <strtol+0x58>
  800dee:	80 39 30             	cmpb   $0x30,(%ecx)
  800df1:	75 10                	jne    800e03 <strtol+0x58>
  800df3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800df7:	75 7c                	jne    800e75 <strtol+0xca>
		s += 2, base = 16;
  800df9:	83 c1 02             	add    $0x2,%ecx
  800dfc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e01:	eb 16                	jmp    800e19 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	75 12                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e07:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e0f:	75 08                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
  800e11:	83 c1 01             	add    $0x1,%ecx
  800e14:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e19:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e21:	0f b6 11             	movzbl (%ecx),%edx
  800e24:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e27:	89 f3                	mov    %esi,%ebx
  800e29:	80 fb 09             	cmp    $0x9,%bl
  800e2c:	77 08                	ja     800e36 <strtol+0x8b>
			dig = *s - '0';
  800e2e:	0f be d2             	movsbl %dl,%edx
  800e31:	83 ea 30             	sub    $0x30,%edx
  800e34:	eb 22                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e36:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e39:	89 f3                	mov    %esi,%ebx
  800e3b:	80 fb 19             	cmp    $0x19,%bl
  800e3e:	77 08                	ja     800e48 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e40:	0f be d2             	movsbl %dl,%edx
  800e43:	83 ea 57             	sub    $0x57,%edx
  800e46:	eb 10                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e48:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e4b:	89 f3                	mov    %esi,%ebx
  800e4d:	80 fb 19             	cmp    $0x19,%bl
  800e50:	77 16                	ja     800e68 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e52:	0f be d2             	movsbl %dl,%edx
  800e55:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e58:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e5b:	7d 0b                	jge    800e68 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e5d:	83 c1 01             	add    $0x1,%ecx
  800e60:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e64:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e66:	eb b9                	jmp    800e21 <strtol+0x76>

	if (endptr)
  800e68:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6c:	74 0d                	je     800e7b <strtol+0xd0>
		*endptr = (char *) s;
  800e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e71:	89 0e                	mov    %ecx,(%esi)
  800e73:	eb 06                	jmp    800e7b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e75:	85 db                	test   %ebx,%ebx
  800e77:	74 98                	je     800e11 <strtol+0x66>
  800e79:	eb 9e                	jmp    800e19 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	f7 da                	neg    %edx
  800e7f:	85 ff                	test   %edi,%edi
  800e81:	0f 45 c2             	cmovne %edx,%eax
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	89 c6                	mov    %eax,%esi
  800ea0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb7:	89 d1                	mov    %edx,%ecx
  800eb9:	89 d3                	mov    %edx,%ebx
  800ebb:	89 d7                	mov    %edx,%edi
  800ebd:	89 d6                	mov    %edx,%esi
  800ebf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 03                	push   $0x3
  800eee:	68 df 2e 80 00       	push   $0x802edf
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 fc 2e 80 00       	push   $0x802efc
  800efa:	e8 e5 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f12:	b8 02 00 00 00       	mov    $0x2,%eax
  800f17:	89 d1                	mov    %edx,%ecx
  800f19:	89 d3                	mov    %edx,%ebx
  800f1b:	89 d7                	mov    %edx,%edi
  800f1d:	89 d6                	mov    %edx,%esi
  800f1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_yield>:

void
sys_yield(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	89 d7                	mov    %edx,%edi
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	be 00 00 00 00       	mov    $0x0,%esi
  800f53:	b8 04 00 00 00       	mov    $0x4,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	89 f7                	mov    %esi,%edi
  800f63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 17                	jle    800f80 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	50                   	push   %eax
  800f6d:	6a 04                	push   $0x4
  800f6f:	68 df 2e 80 00       	push   $0x802edf
  800f74:	6a 23                	push   $0x23
  800f76:	68 fc 2e 80 00       	push   $0x802efc
  800f7b:	e8 64 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f91:	b8 05 00 00 00       	mov    $0x5,%eax
  800f96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa2:	8b 75 18             	mov    0x18(%ebp),%esi
  800fa5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 17                	jle    800fc2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	50                   	push   %eax
  800faf:	6a 05                	push   $0x5
  800fb1:	68 df 2e 80 00       	push   $0x802edf
  800fb6:	6a 23                	push   $0x23
  800fb8:	68 fc 2e 80 00       	push   $0x802efc
  800fbd:	e8 22 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 df                	mov    %ebx,%edi
  800fe5:	89 de                	mov    %ebx,%esi
  800fe7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	7e 17                	jle    801004 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	50                   	push   %eax
  800ff1:	6a 06                	push   $0x6
  800ff3:	68 df 2e 80 00       	push   $0x802edf
  800ff8:	6a 23                	push   $0x23
  800ffa:	68 fc 2e 80 00       	push   $0x802efc
  800fff:	e8 e0 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801015:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101a:	b8 08 00 00 00       	mov    $0x8,%eax
  80101f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	89 df                	mov    %ebx,%edi
  801027:	89 de                	mov    %ebx,%esi
  801029:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	7e 17                	jle    801046 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	6a 08                	push   $0x8
  801035:	68 df 2e 80 00       	push   $0x802edf
  80103a:	6a 23                	push   $0x23
  80103c:	68 fc 2e 80 00       	push   $0x802efc
  801041:	e8 9e f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801057:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105c:	b8 09 00 00 00       	mov    $0x9,%eax
  801061:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801064:	8b 55 08             	mov    0x8(%ebp),%edx
  801067:	89 df                	mov    %ebx,%edi
  801069:	89 de                	mov    %ebx,%esi
  80106b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	7e 17                	jle    801088 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	50                   	push   %eax
  801075:	6a 09                	push   $0x9
  801077:	68 df 2e 80 00       	push   $0x802edf
  80107c:	6a 23                	push   $0x23
  80107e:	68 fc 2e 80 00       	push   $0x802efc
  801083:	e8 5c f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	89 df                	mov    %ebx,%edi
  8010ab:	89 de                	mov    %ebx,%esi
  8010ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	7e 17                	jle    8010ca <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	50                   	push   %eax
  8010b7:	6a 0a                	push   $0xa
  8010b9:	68 df 2e 80 00       	push   $0x802edf
  8010be:	6a 23                	push   $0x23
  8010c0:	68 fc 2e 80 00       	push   $0x802efc
  8010c5:	e8 1a f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d8:	be 00 00 00 00       	mov    $0x0,%esi
  8010dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ee:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801103:	b8 0d 00 00 00       	mov    $0xd,%eax
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	89 cb                	mov    %ecx,%ebx
  80110d:	89 cf                	mov    %ecx,%edi
  80110f:	89 ce                	mov    %ecx,%esi
  801111:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	7e 17                	jle    80112e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 0d                	push   $0xd
  80111d:	68 df 2e 80 00       	push   $0x802edf
  801122:	6a 23                	push   $0x23
  801124:	68 fc 2e 80 00       	push   $0x802efc
  801129:	e8 b6 f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
	   static void
pgfault(struct UTrapframe *utf)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	53                   	push   %ebx
  80113a:	83 ec 04             	sub    $0x4,%esp
  80113d:	8b 45 08             	mov    0x8(%ebp),%eax
	   void *addr = (void *) utf->utf_fault_va;
  801140:	8b 18                	mov    (%eax),%ebx
	   uint32_t err = utf->utf_err;
  801142:	8b 40 04             	mov    0x4(%eax),%eax
	   // Hint:
	   //   Use the read-only page table mappings at uvpt
	   //   (see <inc/memlayout.h>).

	   // LAB 4: Your code here.
	   pte_t pte = uvpt[(uintptr_t)addr >> PGSHIFT];
  801145:	89 da                	mov    %ebx,%edx
  801147:	c1 ea 0c             	shr    $0xc,%edx
  80114a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	   if (!(err & 2)) {
  801151:	a8 02                	test   $0x2,%al
  801153:	75 12                	jne    801167 <pgfault+0x31>
			 panic("pgfault was not a write. err: %x", err);
  801155:	50                   	push   %eax
  801156:	68 0c 2f 80 00       	push   $0x802f0c
  80115b:	6a 21                	push   $0x21
  80115d:	68 2d 2f 80 00       	push   $0x802f2d
  801162:	e8 7d f3 ff ff       	call   8004e4 <_panic>
	   } else if (!(pte & PTE_COW)) {
  801167:	f6 c6 08             	test   $0x8,%dh
  80116a:	75 14                	jne    801180 <pgfault+0x4a>
			 panic("pgfault is not copy on write");
  80116c:	83 ec 04             	sub    $0x4,%esp
  80116f:	68 38 2f 80 00       	push   $0x802f38
  801174:	6a 23                	push   $0x23
  801176:	68 2d 2f 80 00       	push   $0x802f2d
  80117b:	e8 64 f3 ff ff       	call   8004e4 <_panic>
	   // page to the old page's address.
	   // Hint:
	   //   You should make three system calls.
	   // LAB 4: Your code here.
	   int perm = PTE_P | PTE_U | PTE_W;
	   if ((r = sys_page_alloc(0, UTEMP, perm)) < 0) {
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	6a 07                	push   $0x7
  801185:	68 00 00 40 00       	push   $0x400000
  80118a:	6a 00                	push   $0x0
  80118c:	e8 b4 fd ff ff       	call   800f45 <sys_page_alloc>
  801191:	83 c4 10             	add    $0x10,%esp
  801194:	85 c0                	test   %eax,%eax
  801196:	79 12                	jns    8011aa <pgfault+0x74>
			 panic("sys_page_alloc: %e", r);
  801198:	50                   	push   %eax
  801199:	68 55 2f 80 00       	push   $0x802f55
  80119e:	6a 2e                	push   $0x2e
  8011a0:	68 2d 2f 80 00       	push   $0x802f2d
  8011a5:	e8 3a f3 ff ff       	call   8004e4 <_panic>
	   }
	   memmove(UTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8011aa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8011b0:	83 ec 04             	sub    $0x4,%esp
  8011b3:	68 00 10 00 00       	push   $0x1000
  8011b8:	53                   	push   %ebx
  8011b9:	68 00 00 40 00       	push   $0x400000
  8011be:	e8 11 fb ff ff       	call   800cd4 <memmove>
	   if ((r = sys_page_map(0,
  8011c3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8011ca:	53                   	push   %ebx
  8011cb:	6a 00                	push   $0x0
  8011cd:	68 00 00 40 00       	push   $0x400000
  8011d2:	6a 00                	push   $0x0
  8011d4:	e8 af fd ff ff       	call   800f88 <sys_page_map>
  8011d9:	83 c4 20             	add    $0x20,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	79 12                	jns    8011f2 <pgfault+0xbc>
								UTEMP,
								0,
								ROUNDDOWN(addr, PGSIZE),
								perm)) < 0) {
			 panic("sys_page_map %e", r);
  8011e0:	50                   	push   %eax
  8011e1:	68 68 2f 80 00       	push   $0x802f68
  8011e6:	6a 36                	push   $0x36
  8011e8:	68 2d 2f 80 00       	push   $0x802f2d
  8011ed:	e8 f2 f2 ff ff       	call   8004e4 <_panic>
	   }
	   if ((r = sys_page_unmap(0, UTEMP)) < 0) {
  8011f2:	83 ec 08             	sub    $0x8,%esp
  8011f5:	68 00 00 40 00       	push   $0x400000
  8011fa:	6a 00                	push   $0x0
  8011fc:	e8 c9 fd ff ff       	call   800fca <sys_page_unmap>
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	79 12                	jns    80121a <pgfault+0xe4>
			 panic("unmap %e", r);
  801208:	50                   	push   %eax
  801209:	68 78 2f 80 00       	push   $0x802f78
  80120e:	6a 39                	push   $0x39
  801210:	68 2d 2f 80 00       	push   $0x802f2d
  801215:	e8 ca f2 ff ff       	call   8004e4 <_panic>
	   }
}
  80121a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
	   envid_t
fork(void)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	57                   	push   %edi
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
  801225:	83 ec 38             	sub    $0x38,%esp
	   // LAB 4: Your code here.
	   set_pgfault_handler(pgfault);
  801228:	68 36 11 80 00       	push   $0x801136
  80122d:	e8 01 14 00 00       	call   802633 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801232:	b8 07 00 00 00       	mov    $0x7,%eax
  801237:	cd 30                	int    $0x30
  801239:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80123c:	89 45 dc             	mov    %eax,-0x24(%ebp)

	   envid_t envid = sys_exofork();
	   if (envid < 0) {
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	79 15                	jns    80125b <fork+0x3c>
			 panic("sys_exofork: %e", envid);
  801246:	50                   	push   %eax
  801247:	68 81 2f 80 00       	push   $0x802f81
  80124c:	68 81 00 00 00       	push   $0x81
  801251:	68 2d 2f 80 00       	push   $0x802f2d
  801256:	e8 89 f2 ff ff       	call   8004e4 <_panic>
  80125b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801262:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
	   } else if (envid == 0) {  // child
  801266:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80126a:	75 1c                	jne    801288 <fork+0x69>
			 thisenv = &envs[ENVX(sys_getenvid())];
  80126c:	e8 96 fc ff ff       	call   800f07 <sys_getenvid>
  801271:	25 ff 03 00 00       	and    $0x3ff,%eax
  801276:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801279:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80127e:	a3 04 50 80 00       	mov    %eax,0x805004
			 return envid;
  801283:	e9 71 01 00 00       	jmp    8013f9 <fork+0x1da>
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
  801288:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80128b:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  801292:	a8 01                	test   $0x1,%al
  801294:	0f 84 18 01 00 00    	je     8013b2 <fork+0x193>
  80129a:	89 fb                	mov    %edi,%ebx
  80129c:	c1 e3 0a             	shl    $0xa,%ebx
  80129f:	c1 e7 16             	shl    $0x16,%edi
  8012a2:	be 00 00 00 00       	mov    $0x0,%esi
  8012a7:	e9 f4 00 00 00       	jmp    8013a0 <fork+0x181>
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
  8012ac:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8012b2:	0f 84 dc 00 00 00    	je     801394 <fork+0x175>
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
  8012b8:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8012be:	0f 87 cc 00 00 00    	ja     801390 <fork+0x171>
						  is_below_ulim = false;
				    } else if (uvpt[pn] & PTE_P) {
  8012c4:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8012cb:	a8 01                	test   $0x1,%al
  8012cd:	0f 84 c1 00 00 00    	je     801394 <fork+0x175>
	   static int
duppage(envid_t envid, unsigned pn)
{
	   // LAB 4: Your code here.
	   int r;
	   pte_t pte = uvpt[pn];
  8012d3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

	   if ((!(pte & PTE_W) && !(pte & PTE_COW)) || (pte & PTE_SHARE)) 
  8012da:	a9 02 08 00 00       	test   $0x802,%eax
  8012df:	74 05                	je     8012e6 <fork+0xc7>
  8012e1:	f6 c4 04             	test   $0x4,%ah
  8012e4:	74 3a                	je     801320 <fork+0x101>
	   {
			 if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  8012e6:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8012ec:	8b 52 48             	mov    0x48(%edx),%edx
  8012ef:	83 ec 0c             	sub    $0xc,%esp
  8012f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f7:	50                   	push   %eax
  8012f8:	57                   	push   %edi
  8012f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8012fc:	57                   	push   %edi
  8012fd:	52                   	push   %edx
  8012fe:	e8 85 fc ff ff       	call   800f88 <sys_page_map>
  801303:	83 c4 20             	add    $0x20,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	0f 89 86 00 00 00    	jns    801394 <fork+0x175>
				    panic("sys_page_map: %e", r);
  80130e:	50                   	push   %eax
  80130f:	68 91 2f 80 00       	push   $0x802f91
  801314:	6a 52                	push   $0x52
  801316:	68 2d 2f 80 00       	push   $0x802f2d
  80131b:	e8 c4 f1 ff ff       	call   8004e4 <_panic>

	   // remove write bit and set copy on write
	   pte &= ~PTE_W;
	   pte |= PTE_COW;

	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE),pte & PTE_SYSCALL)) < 0) 
  801320:	25 05 06 00 00       	and    $0x605,%eax
  801325:	80 cc 08             	or     $0x8,%ah
  801328:	89 c1                	mov    %eax,%ecx
  80132a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80132d:	a1 04 50 80 00       	mov    0x805004,%eax
  801332:	8b 40 48             	mov    0x48(%eax),%eax
  801335:	83 ec 0c             	sub    $0xc,%esp
  801338:	51                   	push   %ecx
  801339:	57                   	push   %edi
  80133a:	ff 75 dc             	pushl  -0x24(%ebp)
  80133d:	57                   	push   %edi
  80133e:	50                   	push   %eax
  80133f:	e8 44 fc ff ff       	call   800f88 <sys_page_map>
  801344:	83 c4 20             	add    $0x20,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	79 12                	jns    80135d <fork+0x13e>
	   {
			 panic("sys_page_map: %e", r);
  80134b:	50                   	push   %eax
  80134c:	68 91 2f 80 00       	push   $0x802f91
  801351:	6a 5d                	push   $0x5d
  801353:	68 2d 2f 80 00       	push   $0x802f2d
  801358:	e8 87 f1 ff ff       	call   8004e4 <_panic>
	   }

	   // remap our page to have copy on write
	   if ((r = sys_page_map(thisenv->env_id, (void *)(pn * PGSIZE), thisenv->env_id, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) 
  80135d:	a1 04 50 80 00       	mov    0x805004,%eax
  801362:	8b 50 48             	mov    0x48(%eax),%edx
  801365:	8b 40 48             	mov    0x48(%eax),%eax
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80136e:	57                   	push   %edi
  80136f:	52                   	push   %edx
  801370:	57                   	push   %edi
  801371:	50                   	push   %eax
  801372:	e8 11 fc ff ff       	call   800f88 <sys_page_map>
  801377:	83 c4 20             	add    $0x20,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	79 16                	jns    801394 <fork+0x175>
	   {
			 panic("sys_page_map: %e", r);
  80137e:	50                   	push   %eax
  80137f:	68 91 2f 80 00       	push   $0x802f91
  801384:	6a 63                	push   $0x63
  801386:	68 2d 2f 80 00       	push   $0x802f2d
  80138b:	e8 54 f1 ff ff       	call   8004e4 <_panic>
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
				    unsigned pn = i * NPTENTRIES + j;
				    if (pn == ((UXSTACKTOP - PGSIZE) >> PGSHIFT)) {
						  continue;
				    } else if (pn >= (UTOP >> PGSHIFT)) {
						  is_below_ulim = false;
  801390:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
			 if (!(uvpd[i] & PTE_P)) {
				    continue;
			 }
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) {
  801394:	83 c6 01             	add    $0x1,%esi
  801397:	83 c3 01             	add    $0x1,%ebx
  80139a:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8013a0:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  8013a6:	7f 0a                	jg     8013b2 <fork+0x193>
  8013a8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8013ac:	0f 85 fa fe ff ff    	jne    8012ac <fork+0x8d>
			 thisenv = &envs[ENVX(sys_getenvid())];
			 return envid;
	   }

	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) {
  8013b2:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  8013b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013b9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8013be:	7f 0a                	jg     8013ca <fork+0x1ab>
  8013c0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8013c4:	0f 85 be fe ff ff    	jne    801288 <fork+0x69>
			 }
	   }

	   // install upcall
	   extern void _pgfault_upcall();
	   sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	68 8c 26 80 00       	push   $0x80268c
  8013d2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013d5:	56                   	push   %esi
  8013d6:	e8 b5 fc ff ff       	call   801090 <sys_env_set_pgfault_upcall>
	   // allocate the user exception stack (not COW)
	   sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U);
  8013db:	83 c4 0c             	add    $0xc,%esp
  8013de:	6a 06                	push   $0x6
  8013e0:	68 00 f0 bf ee       	push   $0xeebff000
  8013e5:	56                   	push   %esi
  8013e6:	e8 5a fb ff ff       	call   800f45 <sys_page_alloc>
	   // let the child start
	   sys_env_set_status(envid, ENV_RUNNABLE);
  8013eb:	83 c4 08             	add    $0x8,%esp
  8013ee:	6a 02                	push   $0x2
  8013f0:	56                   	push   %esi
  8013f1:	e8 16 fc ff ff       	call   80100c <sys_env_set_status>

	   return envid;
  8013f6:	83 c4 10             	add    $0x10,%esp
}
  8013f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8013fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5e                   	pop    %esi
  801401:	5f                   	pop    %edi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <sfork>:
// Challenge!
	   int
sfork(void)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	83 ec 0c             	sub    $0xc,%esp
	   panic("sfork not implemented");
  80140a:	68 a2 2f 80 00       	push   $0x802fa2
  80140f:	68 a7 00 00 00       	push   $0xa7
  801414:	68 2d 2f 80 00       	push   $0x802f2d
  801419:	e8 c6 f0 ff ff       	call   8004e4 <_panic>

0080141e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	05 00 00 00 30       	add    $0x30000000,%eax
  801429:	c1 e8 0c             	shr    $0xc,%eax
}
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801431:	8b 45 08             	mov    0x8(%ebp),%eax
  801434:	05 00 00 00 30       	add    $0x30000000,%eax
  801439:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80143e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    

00801445 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801450:	89 c2                	mov    %eax,%edx
  801452:	c1 ea 16             	shr    $0x16,%edx
  801455:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80145c:	f6 c2 01             	test   $0x1,%dl
  80145f:	74 11                	je     801472 <fd_alloc+0x2d>
  801461:	89 c2                	mov    %eax,%edx
  801463:	c1 ea 0c             	shr    $0xc,%edx
  801466:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80146d:	f6 c2 01             	test   $0x1,%dl
  801470:	75 09                	jne    80147b <fd_alloc+0x36>
			*fd_store = fd;
  801472:	89 01                	mov    %eax,(%ecx)
			return 0;
  801474:	b8 00 00 00 00       	mov    $0x0,%eax
  801479:	eb 17                	jmp    801492 <fd_alloc+0x4d>
  80147b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801480:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801485:	75 c9                	jne    801450 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801487:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80148d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801492:	5d                   	pop    %ebp
  801493:	c3                   	ret    

00801494 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80149a:	83 f8 1f             	cmp    $0x1f,%eax
  80149d:	77 36                	ja     8014d5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80149f:	c1 e0 0c             	shl    $0xc,%eax
  8014a2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014a7:	89 c2                	mov    %eax,%edx
  8014a9:	c1 ea 16             	shr    $0x16,%edx
  8014ac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014b3:	f6 c2 01             	test   $0x1,%dl
  8014b6:	74 24                	je     8014dc <fd_lookup+0x48>
  8014b8:	89 c2                	mov    %eax,%edx
  8014ba:	c1 ea 0c             	shr    $0xc,%edx
  8014bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014c4:	f6 c2 01             	test   $0x1,%dl
  8014c7:	74 1a                	je     8014e3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014cc:	89 02                	mov    %eax,(%edx)
	return 0;
  8014ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d3:	eb 13                	jmp    8014e8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014da:	eb 0c                	jmp    8014e8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e1:	eb 05                	jmp    8014e8 <fd_lookup+0x54>
  8014e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    

008014ea <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f3:	ba 34 30 80 00       	mov    $0x803034,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014f8:	eb 13                	jmp    80150d <dev_lookup+0x23>
  8014fa:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014fd:	39 08                	cmp    %ecx,(%eax)
  8014ff:	75 0c                	jne    80150d <dev_lookup+0x23>
			*dev = devtab[i];
  801501:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801504:	89 01                	mov    %eax,(%ecx)
			return 0;
  801506:	b8 00 00 00 00       	mov    $0x0,%eax
  80150b:	eb 2e                	jmp    80153b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80150d:	8b 02                	mov    (%edx),%eax
  80150f:	85 c0                	test   %eax,%eax
  801511:	75 e7                	jne    8014fa <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801513:	a1 04 50 80 00       	mov    0x805004,%eax
  801518:	8b 40 48             	mov    0x48(%eax),%eax
  80151b:	83 ec 04             	sub    $0x4,%esp
  80151e:	51                   	push   %ecx
  80151f:	50                   	push   %eax
  801520:	68 b8 2f 80 00       	push   $0x802fb8
  801525:	e8 93 f0 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  80152a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	56                   	push   %esi
  801541:	53                   	push   %ebx
  801542:	83 ec 10             	sub    $0x10,%esp
  801545:	8b 75 08             	mov    0x8(%ebp),%esi
  801548:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80154b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801555:	c1 e8 0c             	shr    $0xc,%eax
  801558:	50                   	push   %eax
  801559:	e8 36 ff ff ff       	call   801494 <fd_lookup>
  80155e:	83 c4 08             	add    $0x8,%esp
  801561:	85 c0                	test   %eax,%eax
  801563:	78 05                	js     80156a <fd_close+0x2d>
	    || fd != fd2)
  801565:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801568:	74 0c                	je     801576 <fd_close+0x39>
		return (must_exist ? r : 0);
  80156a:	84 db                	test   %bl,%bl
  80156c:	ba 00 00 00 00       	mov    $0x0,%edx
  801571:	0f 44 c2             	cmove  %edx,%eax
  801574:	eb 41                	jmp    8015b7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157c:	50                   	push   %eax
  80157d:	ff 36                	pushl  (%esi)
  80157f:	e8 66 ff ff ff       	call   8014ea <dev_lookup>
  801584:	89 c3                	mov    %eax,%ebx
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 1a                	js     8015a7 <fd_close+0x6a>
		if (dev->dev_close)
  80158d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801590:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801593:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801598:	85 c0                	test   %eax,%eax
  80159a:	74 0b                	je     8015a7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80159c:	83 ec 0c             	sub    $0xc,%esp
  80159f:	56                   	push   %esi
  8015a0:	ff d0                	call   *%eax
  8015a2:	89 c3                	mov    %eax,%ebx
  8015a4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	56                   	push   %esi
  8015ab:	6a 00                	push   $0x0
  8015ad:	e8 18 fa ff ff       	call   800fca <sys_page_unmap>
	return r;
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	89 d8                	mov    %ebx,%eax
}
  8015b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ba:	5b                   	pop    %ebx
  8015bb:	5e                   	pop    %esi
  8015bc:	5d                   	pop    %ebp
  8015bd:	c3                   	ret    

008015be <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	ff 75 08             	pushl  0x8(%ebp)
  8015cb:	e8 c4 fe ff ff       	call   801494 <fd_lookup>
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 10                	js     8015e7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	6a 01                	push   $0x1
  8015dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8015df:	e8 59 ff ff ff       	call   80153d <fd_close>
  8015e4:	83 c4 10             	add    $0x10,%esp
}
  8015e7:	c9                   	leave  
  8015e8:	c3                   	ret    

008015e9 <close_all>:

void
close_all(void)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015f5:	83 ec 0c             	sub    $0xc,%esp
  8015f8:	53                   	push   %ebx
  8015f9:	e8 c0 ff ff ff       	call   8015be <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015fe:	83 c3 01             	add    $0x1,%ebx
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	83 fb 20             	cmp    $0x20,%ebx
  801607:	75 ec                	jne    8015f5 <close_all+0xc>
		close(i);
}
  801609:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    

0080160e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	57                   	push   %edi
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
  801614:	83 ec 2c             	sub    $0x2c,%esp
  801617:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80161a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	ff 75 08             	pushl  0x8(%ebp)
  801621:	e8 6e fe ff ff       	call   801494 <fd_lookup>
  801626:	83 c4 08             	add    $0x8,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	0f 88 c1 00 00 00    	js     8016f2 <dup+0xe4>
		return r;
	close(newfdnum);
  801631:	83 ec 0c             	sub    $0xc,%esp
  801634:	56                   	push   %esi
  801635:	e8 84 ff ff ff       	call   8015be <close>

	newfd = INDEX2FD(newfdnum);
  80163a:	89 f3                	mov    %esi,%ebx
  80163c:	c1 e3 0c             	shl    $0xc,%ebx
  80163f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801645:	83 c4 04             	add    $0x4,%esp
  801648:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164b:	e8 de fd ff ff       	call   80142e <fd2data>
  801650:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801652:	89 1c 24             	mov    %ebx,(%esp)
  801655:	e8 d4 fd ff ff       	call   80142e <fd2data>
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801660:	89 f8                	mov    %edi,%eax
  801662:	c1 e8 16             	shr    $0x16,%eax
  801665:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80166c:	a8 01                	test   $0x1,%al
  80166e:	74 37                	je     8016a7 <dup+0x99>
  801670:	89 f8                	mov    %edi,%eax
  801672:	c1 e8 0c             	shr    $0xc,%eax
  801675:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80167c:	f6 c2 01             	test   $0x1,%dl
  80167f:	74 26                	je     8016a7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801681:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801688:	83 ec 0c             	sub    $0xc,%esp
  80168b:	25 07 0e 00 00       	and    $0xe07,%eax
  801690:	50                   	push   %eax
  801691:	ff 75 d4             	pushl  -0x2c(%ebp)
  801694:	6a 00                	push   $0x0
  801696:	57                   	push   %edi
  801697:	6a 00                	push   $0x0
  801699:	e8 ea f8 ff ff       	call   800f88 <sys_page_map>
  80169e:	89 c7                	mov    %eax,%edi
  8016a0:	83 c4 20             	add    $0x20,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 2e                	js     8016d5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016aa:	89 d0                	mov    %edx,%eax
  8016ac:	c1 e8 0c             	shr    $0xc,%eax
  8016af:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b6:	83 ec 0c             	sub    $0xc,%esp
  8016b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8016be:	50                   	push   %eax
  8016bf:	53                   	push   %ebx
  8016c0:	6a 00                	push   $0x0
  8016c2:	52                   	push   %edx
  8016c3:	6a 00                	push   $0x0
  8016c5:	e8 be f8 ff ff       	call   800f88 <sys_page_map>
  8016ca:	89 c7                	mov    %eax,%edi
  8016cc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016cf:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016d1:	85 ff                	test   %edi,%edi
  8016d3:	79 1d                	jns    8016f2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	53                   	push   %ebx
  8016d9:	6a 00                	push   $0x0
  8016db:	e8 ea f8 ff ff       	call   800fca <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016e0:	83 c4 08             	add    $0x8,%esp
  8016e3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016e6:	6a 00                	push   $0x0
  8016e8:	e8 dd f8 ff ff       	call   800fca <sys_page_unmap>
	return r;
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	89 f8                	mov    %edi,%eax
}
  8016f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5f                   	pop    %edi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 14             	sub    $0x14,%esp
  801701:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801704:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801707:	50                   	push   %eax
  801708:	53                   	push   %ebx
  801709:	e8 86 fd ff ff       	call   801494 <fd_lookup>
  80170e:	83 c4 08             	add    $0x8,%esp
  801711:	89 c2                	mov    %eax,%edx
  801713:	85 c0                	test   %eax,%eax
  801715:	78 6d                	js     801784 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801717:	83 ec 08             	sub    $0x8,%esp
  80171a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171d:	50                   	push   %eax
  80171e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801721:	ff 30                	pushl  (%eax)
  801723:	e8 c2 fd ff ff       	call   8014ea <dev_lookup>
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	85 c0                	test   %eax,%eax
  80172d:	78 4c                	js     80177b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80172f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801732:	8b 42 08             	mov    0x8(%edx),%eax
  801735:	83 e0 03             	and    $0x3,%eax
  801738:	83 f8 01             	cmp    $0x1,%eax
  80173b:	75 21                	jne    80175e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80173d:	a1 04 50 80 00       	mov    0x805004,%eax
  801742:	8b 40 48             	mov    0x48(%eax),%eax
  801745:	83 ec 04             	sub    $0x4,%esp
  801748:	53                   	push   %ebx
  801749:	50                   	push   %eax
  80174a:	68 f9 2f 80 00       	push   $0x802ff9
  80174f:	e8 69 ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80175c:	eb 26                	jmp    801784 <read+0x8a>
	}
	if (!dev->dev_read)
  80175e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801761:	8b 40 08             	mov    0x8(%eax),%eax
  801764:	85 c0                	test   %eax,%eax
  801766:	74 17                	je     80177f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801768:	83 ec 04             	sub    $0x4,%esp
  80176b:	ff 75 10             	pushl  0x10(%ebp)
  80176e:	ff 75 0c             	pushl  0xc(%ebp)
  801771:	52                   	push   %edx
  801772:	ff d0                	call   *%eax
  801774:	89 c2                	mov    %eax,%edx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	eb 09                	jmp    801784 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177b:	89 c2                	mov    %eax,%edx
  80177d:	eb 05                	jmp    801784 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80177f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801784:	89 d0                	mov    %edx,%eax
  801786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	57                   	push   %edi
  80178f:	56                   	push   %esi
  801790:	53                   	push   %ebx
  801791:	83 ec 0c             	sub    $0xc,%esp
  801794:	8b 7d 08             	mov    0x8(%ebp),%edi
  801797:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80179a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80179f:	eb 21                	jmp    8017c2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017a1:	83 ec 04             	sub    $0x4,%esp
  8017a4:	89 f0                	mov    %esi,%eax
  8017a6:	29 d8                	sub    %ebx,%eax
  8017a8:	50                   	push   %eax
  8017a9:	89 d8                	mov    %ebx,%eax
  8017ab:	03 45 0c             	add    0xc(%ebp),%eax
  8017ae:	50                   	push   %eax
  8017af:	57                   	push   %edi
  8017b0:	e8 45 ff ff ff       	call   8016fa <read>
		if (m < 0)
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	78 10                	js     8017cc <readn+0x41>
			return m;
		if (m == 0)
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	74 0a                	je     8017ca <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c0:	01 c3                	add    %eax,%ebx
  8017c2:	39 f3                	cmp    %esi,%ebx
  8017c4:	72 db                	jb     8017a1 <readn+0x16>
  8017c6:	89 d8                	mov    %ebx,%eax
  8017c8:	eb 02                	jmp    8017cc <readn+0x41>
  8017ca:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5e                   	pop    %esi
  8017d1:	5f                   	pop    %edi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	53                   	push   %ebx
  8017d8:	83 ec 14             	sub    $0x14,%esp
  8017db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e1:	50                   	push   %eax
  8017e2:	53                   	push   %ebx
  8017e3:	e8 ac fc ff ff       	call   801494 <fd_lookup>
  8017e8:	83 c4 08             	add    $0x8,%esp
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 68                	js     801859 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f7:	50                   	push   %eax
  8017f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fb:	ff 30                	pushl  (%eax)
  8017fd:	e8 e8 fc ff ff       	call   8014ea <dev_lookup>
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	85 c0                	test   %eax,%eax
  801807:	78 47                	js     801850 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801810:	75 21                	jne    801833 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801812:	a1 04 50 80 00       	mov    0x805004,%eax
  801817:	8b 40 48             	mov    0x48(%eax),%eax
  80181a:	83 ec 04             	sub    $0x4,%esp
  80181d:	53                   	push   %ebx
  80181e:	50                   	push   %eax
  80181f:	68 15 30 80 00       	push   $0x803015
  801824:	e8 94 ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801829:	83 c4 10             	add    $0x10,%esp
  80182c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801831:	eb 26                	jmp    801859 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801833:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801836:	8b 52 0c             	mov    0xc(%edx),%edx
  801839:	85 d2                	test   %edx,%edx
  80183b:	74 17                	je     801854 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80183d:	83 ec 04             	sub    $0x4,%esp
  801840:	ff 75 10             	pushl  0x10(%ebp)
  801843:	ff 75 0c             	pushl  0xc(%ebp)
  801846:	50                   	push   %eax
  801847:	ff d2                	call   *%edx
  801849:	89 c2                	mov    %eax,%edx
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	eb 09                	jmp    801859 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801850:	89 c2                	mov    %eax,%edx
  801852:	eb 05                	jmp    801859 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801854:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801859:	89 d0                	mov    %edx,%eax
  80185b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <seek>:

int
seek(int fdnum, off_t offset)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801866:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801869:	50                   	push   %eax
  80186a:	ff 75 08             	pushl  0x8(%ebp)
  80186d:	e8 22 fc ff ff       	call   801494 <fd_lookup>
  801872:	83 c4 08             	add    $0x8,%esp
  801875:	85 c0                	test   %eax,%eax
  801877:	78 0e                	js     801887 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801879:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80187c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80187f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801882:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	53                   	push   %ebx
  80188d:	83 ec 14             	sub    $0x14,%esp
  801890:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801893:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801896:	50                   	push   %eax
  801897:	53                   	push   %ebx
  801898:	e8 f7 fb ff ff       	call   801494 <fd_lookup>
  80189d:	83 c4 08             	add    $0x8,%esp
  8018a0:	89 c2                	mov    %eax,%edx
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 65                	js     80190b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ac:	50                   	push   %eax
  8018ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b0:	ff 30                	pushl  (%eax)
  8018b2:	e8 33 fc ff ff       	call   8014ea <dev_lookup>
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 44                	js     801902 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c5:	75 21                	jne    8018e8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018c7:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018cc:	8b 40 48             	mov    0x48(%eax),%eax
  8018cf:	83 ec 04             	sub    $0x4,%esp
  8018d2:	53                   	push   %ebx
  8018d3:	50                   	push   %eax
  8018d4:	68 d8 2f 80 00       	push   $0x802fd8
  8018d9:	e8 df ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018de:	83 c4 10             	add    $0x10,%esp
  8018e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018e6:	eb 23                	jmp    80190b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018eb:	8b 52 18             	mov    0x18(%edx),%edx
  8018ee:	85 d2                	test   %edx,%edx
  8018f0:	74 14                	je     801906 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018f2:	83 ec 08             	sub    $0x8,%esp
  8018f5:	ff 75 0c             	pushl  0xc(%ebp)
  8018f8:	50                   	push   %eax
  8018f9:	ff d2                	call   *%edx
  8018fb:	89 c2                	mov    %eax,%edx
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	eb 09                	jmp    80190b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801902:	89 c2                	mov    %eax,%edx
  801904:	eb 05                	jmp    80190b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801906:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80190b:	89 d0                	mov    %edx,%eax
  80190d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801910:	c9                   	leave  
  801911:	c3                   	ret    

00801912 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	53                   	push   %ebx
  801916:	83 ec 14             	sub    $0x14,%esp
  801919:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80191c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80191f:	50                   	push   %eax
  801920:	ff 75 08             	pushl  0x8(%ebp)
  801923:	e8 6c fb ff ff       	call   801494 <fd_lookup>
  801928:	83 c4 08             	add    $0x8,%esp
  80192b:	89 c2                	mov    %eax,%edx
  80192d:	85 c0                	test   %eax,%eax
  80192f:	78 58                	js     801989 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801937:	50                   	push   %eax
  801938:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193b:	ff 30                	pushl  (%eax)
  80193d:	e8 a8 fb ff ff       	call   8014ea <dev_lookup>
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	85 c0                	test   %eax,%eax
  801947:	78 37                	js     801980 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801949:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801950:	74 32                	je     801984 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801952:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801955:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80195c:	00 00 00 
	stat->st_isdir = 0;
  80195f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801966:	00 00 00 
	stat->st_dev = dev;
  801969:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	53                   	push   %ebx
  801973:	ff 75 f0             	pushl  -0x10(%ebp)
  801976:	ff 50 14             	call   *0x14(%eax)
  801979:	89 c2                	mov    %eax,%edx
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	eb 09                	jmp    801989 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801980:	89 c2                	mov    %eax,%edx
  801982:	eb 05                	jmp    801989 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801984:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801989:	89 d0                	mov    %edx,%eax
  80198b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801995:	83 ec 08             	sub    $0x8,%esp
  801998:	6a 00                	push   $0x0
  80199a:	ff 75 08             	pushl  0x8(%ebp)
  80199d:	e8 2c 02 00 00       	call   801bce <open>
  8019a2:	89 c3                	mov    %eax,%ebx
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 1b                	js     8019c6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	ff 75 0c             	pushl  0xc(%ebp)
  8019b1:	50                   	push   %eax
  8019b2:	e8 5b ff ff ff       	call   801912 <fstat>
  8019b7:	89 c6                	mov    %eax,%esi
	close(fd);
  8019b9:	89 1c 24             	mov    %ebx,(%esp)
  8019bc:	e8 fd fb ff ff       	call   8015be <close>
	return r;
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	89 f0                	mov    %esi,%eax
}
  8019c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c9:	5b                   	pop    %ebx
  8019ca:	5e                   	pop    %esi
  8019cb:	5d                   	pop    %ebp
  8019cc:	c3                   	ret    

008019cd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
  8019d2:	89 c6                	mov    %eax,%esi
  8019d4:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  8019d6:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019dd:	75 12                	jne    8019f1 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  8019df:	83 ec 0c             	sub    $0xc,%esp
  8019e2:	6a 01                	push   $0x1
  8019e4:	e8 7c 0d 00 00       	call   802765 <ipc_find_env>
  8019e9:	a3 00 50 80 00       	mov    %eax,0x805000
  8019ee:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019f1:	6a 07                	push   $0x7
  8019f3:	68 00 60 80 00       	push   $0x806000
  8019f8:	56                   	push   %esi
  8019f9:	ff 35 00 50 80 00    	pushl  0x805000
  8019ff:	e8 0d 0d 00 00       	call   802711 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  801a04:	83 c4 0c             	add    $0xc,%esp
  801a07:	6a 00                	push   $0x0
  801a09:	53                   	push   %ebx
  801a0a:	6a 00                	push   $0x0
  801a0c:	e8 a1 0c 00 00       	call   8026b2 <ipc_recv>
}
  801a11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a14:	5b                   	pop    %ebx
  801a15:	5e                   	pop    %esi
  801a16:	5d                   	pop    %ebp
  801a17:	c3                   	ret    

00801a18 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a21:	8b 40 0c             	mov    0xc(%eax),%eax
  801a24:	a3 00 60 80 00       	mov    %eax,0x806000
	   fsipcbuf.set_size.req_size = newsize;
  801a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2c:	a3 04 60 80 00       	mov    %eax,0x806004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
  801a36:	b8 02 00 00 00       	mov    $0x2,%eax
  801a3b:	e8 8d ff ff ff       	call   8019cd <fsipc>
}
  801a40:	c9                   	leave  
  801a41:	c3                   	ret    

00801a42 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4e:	a3 00 60 80 00       	mov    %eax,0x806000
	   return fsipc(FSREQ_FLUSH, NULL);
  801a53:	ba 00 00 00 00       	mov    $0x0,%edx
  801a58:	b8 06 00 00 00       	mov    $0x6,%eax
  801a5d:	e8 6b ff ff ff       	call   8019cd <fsipc>
}
  801a62:	c9                   	leave  
  801a63:	c3                   	ret    

00801a64 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	53                   	push   %ebx
  801a68:	83 ec 04             	sub    $0x4,%esp
  801a6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	8b 40 0c             	mov    0xc(%eax),%eax
  801a74:	a3 00 60 80 00       	mov    %eax,0x806000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a79:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7e:	b8 05 00 00 00       	mov    $0x5,%eax
  801a83:	e8 45 ff ff ff       	call   8019cd <fsipc>
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	78 2c                	js     801ab8 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a8c:	83 ec 08             	sub    $0x8,%esp
  801a8f:	68 00 60 80 00       	push   $0x806000
  801a94:	53                   	push   %ebx
  801a95:	e8 a8 f0 ff ff       	call   800b42 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  801a9a:	a1 80 60 80 00       	mov    0x806080,%eax
  801a9f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aa5:	a1 84 60 80 00       	mov    0x806084,%eax
  801aaa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abb:	c9                   	leave  
  801abc:	c3                   	ret    

00801abd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 08             	sub    $0x8,%esp
  801ac4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aca:	8b 40 0c             	mov    0xc(%eax),%eax
  801acd:	a3 00 60 80 00       	mov    %eax,0x806000
	   fsipcbuf.write.req_n = n;
  801ad2:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  801ad8:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801ade:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801ae3:	0f 46 c3             	cmovbe %ebx,%eax
  801ae6:	50                   	push   %eax
  801ae7:	ff 75 0c             	pushl  0xc(%ebp)
  801aea:	68 08 60 80 00       	push   $0x806008
  801aef:	e8 e0 f1 ff ff       	call   800cd4 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  801af4:	ba 00 00 00 00       	mov    $0x0,%edx
  801af9:	b8 04 00 00 00       	mov    $0x4,%eax
  801afe:	e8 ca fe ff ff       	call   8019cd <fsipc>
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 3d                	js     801b47 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  801b0a:	39 c3                	cmp    %eax,%ebx
  801b0c:	73 19                	jae    801b27 <devfile_write+0x6a>
  801b0e:	68 44 30 80 00       	push   $0x803044
  801b13:	68 4b 30 80 00       	push   $0x80304b
  801b18:	68 9a 00 00 00       	push   $0x9a
  801b1d:	68 60 30 80 00       	push   $0x803060
  801b22:	e8 bd e9 ff ff       	call   8004e4 <_panic>
	   assert (r <= bytes_written);
  801b27:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b2c:	7e 19                	jle    801b47 <devfile_write+0x8a>
  801b2e:	68 6b 30 80 00       	push   $0x80306b
  801b33:	68 4b 30 80 00       	push   $0x80304b
  801b38:	68 9b 00 00 00       	push   $0x9b
  801b3d:	68 60 30 80 00       	push   $0x803060
  801b42:	e8 9d e9 ff ff       	call   8004e4 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801b47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	56                   	push   %esi
  801b50:	53                   	push   %ebx
  801b51:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b54:	8b 45 08             	mov    0x8(%ebp),%eax
  801b57:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5a:	a3 00 60 80 00       	mov    %eax,0x806000
	   fsipcbuf.read.req_n = n;
  801b5f:	89 35 04 60 80 00    	mov    %esi,0x806004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b65:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6a:	b8 03 00 00 00       	mov    $0x3,%eax
  801b6f:	e8 59 fe ff ff       	call   8019cd <fsipc>
  801b74:	89 c3                	mov    %eax,%ebx
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 4b                	js     801bc5 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  801b7a:	39 c6                	cmp    %eax,%esi
  801b7c:	73 16                	jae    801b94 <devfile_read+0x48>
  801b7e:	68 44 30 80 00       	push   $0x803044
  801b83:	68 4b 30 80 00       	push   $0x80304b
  801b88:	6a 7c                	push   $0x7c
  801b8a:	68 60 30 80 00       	push   $0x803060
  801b8f:	e8 50 e9 ff ff       	call   8004e4 <_panic>
	   assert(r <= PGSIZE);
  801b94:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b99:	7e 16                	jle    801bb1 <devfile_read+0x65>
  801b9b:	68 7e 30 80 00       	push   $0x80307e
  801ba0:	68 4b 30 80 00       	push   $0x80304b
  801ba5:	6a 7d                	push   $0x7d
  801ba7:	68 60 30 80 00       	push   $0x803060
  801bac:	e8 33 e9 ff ff       	call   8004e4 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bb1:	83 ec 04             	sub    $0x4,%esp
  801bb4:	50                   	push   %eax
  801bb5:	68 00 60 80 00       	push   $0x806000
  801bba:	ff 75 0c             	pushl  0xc(%ebp)
  801bbd:	e8 12 f1 ff ff       	call   800cd4 <memmove>
	   return r;
  801bc2:	83 c4 10             	add    $0x10,%esp
}
  801bc5:	89 d8                	mov    %ebx,%eax
  801bc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bca:	5b                   	pop    %ebx
  801bcb:	5e                   	pop    %esi
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    

00801bce <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	53                   	push   %ebx
  801bd2:	83 ec 20             	sub    $0x20,%esp
  801bd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  801bd8:	53                   	push   %ebx
  801bd9:	e8 2b ef ff ff       	call   800b09 <strlen>
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801be6:	7f 67                	jg     801c4f <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801be8:	83 ec 0c             	sub    $0xc,%esp
  801beb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bee:	50                   	push   %eax
  801bef:	e8 51 f8 ff ff       	call   801445 <fd_alloc>
  801bf4:	83 c4 10             	add    $0x10,%esp
			 return r;
  801bf7:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	78 57                	js     801c54 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  801bfd:	83 ec 08             	sub    $0x8,%esp
  801c00:	53                   	push   %ebx
  801c01:	68 00 60 80 00       	push   $0x806000
  801c06:	e8 37 ef ff ff       	call   800b42 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  801c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0e:	a3 00 64 80 00       	mov    %eax,0x806400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c13:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c16:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1b:	e8 ad fd ff ff       	call   8019cd <fsipc>
  801c20:	89 c3                	mov    %eax,%ebx
  801c22:	83 c4 10             	add    $0x10,%esp
  801c25:	85 c0                	test   %eax,%eax
  801c27:	79 14                	jns    801c3d <open+0x6f>
			 fd_close(fd, 0);
  801c29:	83 ec 08             	sub    $0x8,%esp
  801c2c:	6a 00                	push   $0x0
  801c2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c31:	e8 07 f9 ff ff       	call   80153d <fd_close>
			 return r;
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	89 da                	mov    %ebx,%edx
  801c3b:	eb 17                	jmp    801c54 <open+0x86>
	   }

	   return fd2num(fd);
  801c3d:	83 ec 0c             	sub    $0xc,%esp
  801c40:	ff 75 f4             	pushl  -0xc(%ebp)
  801c43:	e8 d6 f7 ff ff       	call   80141e <fd2num>
  801c48:	89 c2                	mov    %eax,%edx
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	eb 05                	jmp    801c54 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  801c4f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801c54:	89 d0                	mov    %edx,%eax
  801c56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c59:	c9                   	leave  
  801c5a:	c3                   	ret    

00801c5b <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801c61:	ba 00 00 00 00       	mov    $0x0,%edx
  801c66:	b8 08 00 00 00       	mov    $0x8,%eax
  801c6b:	e8 5d fd ff ff       	call   8019cd <fsipc>
}
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
	   int
spawn(const char *prog, const char **argv)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	57                   	push   %edi
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	81 ec 94 02 00 00    	sub    $0x294,%esp
	   //   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	   //     correct initial eip and esp values in the child.
	   //
	   //   - Start the child process running with sys_env_set_status().

	   if ((r = open(prog, O_RDONLY)) < 0)
  801c7e:	6a 00                	push   $0x0
  801c80:	ff 75 08             	pushl  0x8(%ebp)
  801c83:	e8 46 ff ff ff       	call   801bce <open>
  801c88:	89 c1                	mov    %eax,%ecx
  801c8a:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	85 c0                	test   %eax,%eax
  801c95:	0f 88 de 04 00 00    	js     802179 <spawn+0x507>
			 return r;
	   fd = r;

	   // Read elf header
	   elf = (struct Elf*) elf_buf;
	   if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c9b:	83 ec 04             	sub    $0x4,%esp
  801c9e:	68 00 02 00 00       	push   $0x200
  801ca3:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801ca9:	50                   	push   %eax
  801caa:	51                   	push   %ecx
  801cab:	e8 db fa ff ff       	call   80178b <readn>
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	3d 00 02 00 00       	cmp    $0x200,%eax
  801cb8:	75 0c                	jne    801cc6 <spawn+0x54>
				    || elf->e_magic != ELF_MAGIC) {
  801cba:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801cc1:	45 4c 46 
  801cc4:	74 33                	je     801cf9 <spawn+0x87>
			 close(fd);
  801cc6:	83 ec 0c             	sub    $0xc,%esp
  801cc9:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801ccf:	e8 ea f8 ff ff       	call   8015be <close>
			 cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801cd4:	83 c4 0c             	add    $0xc,%esp
  801cd7:	68 7f 45 4c 46       	push   $0x464c457f
  801cdc:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801ce2:	68 8a 30 80 00       	push   $0x80308a
  801ce7:	e8 d1 e8 ff ff       	call   8005bd <cprintf>
			 return -E_NOT_EXEC;
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801cf4:	e9 12 05 00 00       	jmp    80220b <spawn+0x599>
  801cf9:	b8 07 00 00 00       	mov    $0x7,%eax
  801cfe:	cd 30                	int    $0x30
  801d00:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d06:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	   }

	   // Create new child environment
	   if ((r = sys_exofork()) < 0)
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	0f 88 70 04 00 00    	js     802184 <spawn+0x512>
			 return r;
	   child = r;

	   // Set up trap frame, including initial stack.
	   child_tf = envs[ENVX(child)].env_tf;
  801d14:	89 c6                	mov    %eax,%esi
  801d16:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801d1c:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801d1f:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d25:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d2b:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	   child_tf.tf_eip = elf->e_entry;
  801d32:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d38:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
	   for (argc = 0; argv[argc] != 0; argc++)
  801d3e:	bb 00 00 00 00       	mov    $0x0,%ebx
	   char *string_store;
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
  801d43:	be 00 00 00 00       	mov    $0x0,%esi
  801d48:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d4b:	eb 13                	jmp    801d60 <spawn+0xee>
	   for (argc = 0; argv[argc] != 0; argc++)
			 string_size += strlen(argv[argc]) + 1;
  801d4d:	83 ec 0c             	sub    $0xc,%esp
  801d50:	50                   	push   %eax
  801d51:	e8 b3 ed ff ff       	call   800b09 <strlen>
  801d56:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
	   for (argc = 0; argv[argc] != 0; argc++)
  801d5a:	83 c3 01             	add    $0x1,%ebx
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d67:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	75 df                	jne    801d4d <spawn+0xdb>
  801d6e:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801d74:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	   // Determine where to place the strings and the argv array.
	   // Set up pointers into the temporary page 'UTEMP'; we'll map a page
	   // there later, then remap that page into the child environment
	   // at (USTACKTOP - PGSIZE).
	   // strings is the topmost thing on the stack.
	   string_store = (char*) UTEMP + PGSIZE - string_size;
  801d7a:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d7f:	29 f7                	sub    %esi,%edi
	   // argv is below that.  There's one argument pointer per argument, plus
	   // a null pointer.
	   argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d81:	89 fa                	mov    %edi,%edx
  801d83:	83 e2 fc             	and    $0xfffffffc,%edx
  801d86:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d8d:	29 c2                	sub    %eax,%edx
  801d8f:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	   // Make sure that argv, strings, and the 2 words that hold 'argc'
	   // and 'argv' themselves will all fit in a single stack page.
	   if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d95:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d98:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d9d:	0f 86 f1 03 00 00    	jbe    802194 <spawn+0x522>
			 return -E_NO_MEM;

	   // Allocate the single stack page at UTEMP.
	   if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801da3:	83 ec 04             	sub    $0x4,%esp
  801da6:	6a 07                	push   $0x7
  801da8:	68 00 00 40 00       	push   $0x400000
  801dad:	6a 00                	push   $0x0
  801daf:	e8 91 f1 ff ff       	call   800f45 <sys_page_alloc>
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	85 c0                	test   %eax,%eax
  801db9:	0f 88 dc 03 00 00    	js     80219b <spawn+0x529>
  801dbf:	be 00 00 00 00       	mov    $0x0,%esi
  801dc4:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801dca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dcd:	eb 30                	jmp    801dff <spawn+0x18d>
	   //	  environment.)
	   //
	   //	* Set *init_esp to the initial stack pointer for the child,
	   //	  (Again, use an address valid in the child's environment.)
	   for (i = 0; i < argc; i++) {
			 argv_store[i] = UTEMP2USTACK(string_store);
  801dcf:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801dd5:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801ddb:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
			 strcpy(string_store, argv[i]);
  801dde:	83 ec 08             	sub    $0x8,%esp
  801de1:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801de4:	57                   	push   %edi
  801de5:	e8 58 ed ff ff       	call   800b42 <strcpy>
			 string_store += strlen(argv[i]) + 1;
  801dea:	83 c4 04             	add    $0x4,%esp
  801ded:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801df0:	e8 14 ed ff ff       	call   800b09 <strlen>
  801df5:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	   //	  (Again, argv should use an address valid in the child's
	   //	  environment.)
	   //
	   //	* Set *init_esp to the initial stack pointer for the child,
	   //	  (Again, use an address valid in the child's environment.)
	   for (i = 0; i < argc; i++) {
  801df9:	83 c6 01             	add    $0x1,%esi
  801dfc:	83 c4 10             	add    $0x10,%esp
  801dff:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801e05:	7f c8                	jg     801dcf <spawn+0x15d>
			 argv_store[i] = UTEMP2USTACK(string_store);
			 strcpy(string_store, argv[i]);
			 string_store += strlen(argv[i]) + 1;
	   }
	   argv_store[argc] = 0;
  801e07:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e0d:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801e13:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	   assert(string_store == (char*)UTEMP + PGSIZE);
  801e1a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e20:	74 19                	je     801e3b <spawn+0x1c9>
  801e22:	68 14 31 80 00       	push   $0x803114
  801e27:	68 4b 30 80 00       	push   $0x80304b
  801e2c:	68 f2 00 00 00       	push   $0xf2
  801e31:	68 a4 30 80 00       	push   $0x8030a4
  801e36:	e8 a9 e6 ff ff       	call   8004e4 <_panic>

	   argv_store[-1] = UTEMP2USTACK(argv_store);
  801e3b:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801e41:	89 c8                	mov    %ecx,%eax
  801e43:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e48:	89 41 fc             	mov    %eax,-0x4(%ecx)
	   argv_store[-2] = argc;
  801e4b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e51:	89 41 f8             	mov    %eax,-0x8(%ecx)

	   *init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e54:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801e5a:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	   // After completing the stack, map it into the child's address space
	   // and unmap it from ours!
	   if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e60:	83 ec 0c             	sub    $0xc,%esp
  801e63:	6a 07                	push   $0x7
  801e65:	68 00 d0 bf ee       	push   $0xeebfd000
  801e6a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e70:	68 00 00 40 00       	push   $0x400000
  801e75:	6a 00                	push   $0x0
  801e77:	e8 0c f1 ff ff       	call   800f88 <sys_page_map>
  801e7c:	89 c3                	mov    %eax,%ebx
  801e7e:	83 c4 20             	add    $0x20,%esp
  801e81:	85 c0                	test   %eax,%eax
  801e83:	0f 88 70 03 00 00    	js     8021f9 <spawn+0x587>
			 goto error;
	   if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e89:	83 ec 08             	sub    $0x8,%esp
  801e8c:	68 00 00 40 00       	push   $0x400000
  801e91:	6a 00                	push   $0x0
  801e93:	e8 32 f1 ff ff       	call   800fca <sys_page_unmap>
  801e98:	89 c3                	mov    %eax,%ebx
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	0f 88 54 03 00 00    	js     8021f9 <spawn+0x587>

	   if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
			 return r;

	   // Set up program segments as defined in ELF header.
	   ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ea5:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801eab:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801eb2:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	   for (i = 0; i < elf->e_phnum; i++, ph++) {
  801eb8:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801ebf:	00 00 00 
  801ec2:	e9 86 01 00 00       	jmp    80204d <spawn+0x3db>
			 if (ph->p_type != ELF_PROG_LOAD)
  801ec7:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ecd:	83 38 01             	cmpl   $0x1,(%eax)
  801ed0:	0f 85 69 01 00 00    	jne    80203f <spawn+0x3cd>
				    continue;
			 perm = PTE_P | PTE_U;
			 if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ed6:	89 c1                	mov    %eax,%ecx
  801ed8:	8b 40 18             	mov    0x18(%eax),%eax
  801edb:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ee1:	83 e0 02             	and    $0x2,%eax
				    perm |= PTE_W;
  801ee4:	83 f8 01             	cmp    $0x1,%eax
  801ee7:	19 c0                	sbb    %eax,%eax
  801ee9:	83 e0 fe             	and    $0xfffffffe,%eax
  801eec:	83 c0 07             	add    $0x7,%eax
  801eef:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
			 if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ef5:	89 c8                	mov    %ecx,%eax
  801ef7:	8b 49 04             	mov    0x4(%ecx),%ecx
  801efa:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801f00:	8b 78 10             	mov    0x10(%eax),%edi
  801f03:	8b 50 14             	mov    0x14(%eax),%edx
  801f06:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801f0c:	8b 70 08             	mov    0x8(%eax),%esi
	   int i, r;
	   void *blk;

	   //cprintf("map_segment %x+%x\n", va, memsz);

	   if ((i = PGOFF(va))) {
  801f0f:	89 f0                	mov    %esi,%eax
  801f11:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f16:	74 14                	je     801f2c <spawn+0x2ba>
			 va -= i;
  801f18:	29 c6                	sub    %eax,%esi
			 memsz += i;
  801f1a:	01 c2                	add    %eax,%edx
  801f1c:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
			 filesz += i;
  801f22:	01 c7                	add    %eax,%edi
			 fileoffset -= i;
  801f24:	29 c1                	sub    %eax,%ecx
  801f26:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	   }

	   for (i = 0; i < memsz; i += PGSIZE) {
  801f2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f31:	e9 f7 00 00 00       	jmp    80202d <spawn+0x3bb>
			 if (i >= filesz) {
  801f36:	39 df                	cmp    %ebx,%edi
  801f38:	77 27                	ja     801f61 <spawn+0x2ef>
				    // allocate a blank page
				    if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f3a:	83 ec 04             	sub    $0x4,%esp
  801f3d:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f43:	56                   	push   %esi
  801f44:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801f4a:	e8 f6 ef ff ff       	call   800f45 <sys_page_alloc>
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	85 c0                	test   %eax,%eax
  801f54:	0f 89 c7 00 00 00    	jns    802021 <spawn+0x3af>
  801f5a:	89 c3                	mov    %eax,%ebx
  801f5c:	e9 48 02 00 00       	jmp    8021a9 <spawn+0x537>
						  return r;
			 } else {
				    // from file
				    if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f61:	83 ec 04             	sub    $0x4,%esp
  801f64:	6a 07                	push   $0x7
  801f66:	68 00 00 40 00       	push   $0x400000
  801f6b:	6a 00                	push   $0x0
  801f6d:	e8 d3 ef ff ff       	call   800f45 <sys_page_alloc>
  801f72:	83 c4 10             	add    $0x10,%esp
  801f75:	85 c0                	test   %eax,%eax
  801f77:	0f 88 22 02 00 00    	js     80219f <spawn+0x52d>
						  return r;
				    if ((r = seek(fd, fileoffset + i)) < 0)
  801f7d:	83 ec 08             	sub    $0x8,%esp
  801f80:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f86:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f8c:	50                   	push   %eax
  801f8d:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f93:	e8 c8 f8 ff ff       	call   801860 <seek>
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	0f 88 00 02 00 00    	js     8021a3 <spawn+0x531>
						  return r;
				    if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801fa3:	83 ec 04             	sub    $0x4,%esp
  801fa6:	89 f8                	mov    %edi,%eax
  801fa8:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801fae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801fb3:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801fb8:	0f 47 c1             	cmova  %ecx,%eax
  801fbb:	50                   	push   %eax
  801fbc:	68 00 00 40 00       	push   $0x400000
  801fc1:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fc7:	e8 bf f7 ff ff       	call   80178b <readn>
  801fcc:	83 c4 10             	add    $0x10,%esp
  801fcf:	85 c0                	test   %eax,%eax
  801fd1:	0f 88 d0 01 00 00    	js     8021a7 <spawn+0x535>
						  return r;
				    if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801fd7:	83 ec 0c             	sub    $0xc,%esp
  801fda:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fe0:	56                   	push   %esi
  801fe1:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801fe7:	68 00 00 40 00       	push   $0x400000
  801fec:	6a 00                	push   $0x0
  801fee:	e8 95 ef ff ff       	call   800f88 <sys_page_map>
  801ff3:	83 c4 20             	add    $0x20,%esp
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	79 15                	jns    80200f <spawn+0x39d>
						  panic("spawn: sys_page_map data: %e", r);
  801ffa:	50                   	push   %eax
  801ffb:	68 b0 30 80 00       	push   $0x8030b0
  802000:	68 25 01 00 00       	push   $0x125
  802005:	68 a4 30 80 00       	push   $0x8030a4
  80200a:	e8 d5 e4 ff ff       	call   8004e4 <_panic>
				    sys_page_unmap(0, UTEMP);
  80200f:	83 ec 08             	sub    $0x8,%esp
  802012:	68 00 00 40 00       	push   $0x400000
  802017:	6a 00                	push   $0x0
  802019:	e8 ac ef ff ff       	call   800fca <sys_page_unmap>
  80201e:	83 c4 10             	add    $0x10,%esp
			 memsz += i;
			 filesz += i;
			 fileoffset -= i;
	   }

	   for (i = 0; i < memsz; i += PGSIZE) {
  802021:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802027:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80202d:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802033:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  802039:	0f 87 f7 fe ff ff    	ja     801f36 <spawn+0x2c4>
	   if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
			 return r;

	   // Set up program segments as defined in ELF header.
	   ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	   for (i = 0; i < elf->e_phnum; i++, ph++) {
  80203f:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802046:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80204d:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802054:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80205a:	0f 8c 67 fe ff ff    	jl     801ec7 <spawn+0x255>
				    perm |= PTE_W;
			 if ((r = map_segment(child, ph->p_va, ph->p_memsz,
									   fd, ph->p_filesz, ph->p_offset, perm)) < 0)
				    goto error;
	   }
	   close(fd);
  802060:	83 ec 0c             	sub    $0xc,%esp
  802063:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802069:	e8 50 f5 ff ff       	call   8015be <close>
  80206e:	83 c4 10             	add    $0x10,%esp
	   static int
copy_shared_pages(envid_t child)
{
	   // LAB 5: Your code here.
	   int r;
	   bool is_below_ulim = true;
  802071:	c6 85 94 fd ff ff 01 	movb   $0x1,-0x26c(%ebp)
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
  802078:	c7 85 8c fd ff ff 00 	movl   $0x0,-0x274(%ebp)
  80207f:	00 00 00 
	   {
			 if (!(uvpd[i] & PTE_P)) 
  802082:	8b bd 8c fd ff ff    	mov    -0x274(%ebp),%edi
  802088:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  80208f:	a8 01                	test   $0x1,%al
  802091:	74 7b                	je     80210e <spawn+0x49c>
  802093:	89 fb                	mov    %edi,%ebx
  802095:	c1 e3 0a             	shl    $0xa,%ebx
  802098:	c1 e7 16             	shl    $0x16,%edi
  80209b:	be 00 00 00 00       	mov    $0x0,%esi
  8020a0:	eb 5b                	jmp    8020fd <spawn+0x48b>
				    continue;
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) 
			 {
				    unsigned pn = i * NPTENTRIES + j;
				    pte_t pte = uvpt[pn];
  8020a2:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
				    if (pn >= (UTOP >> PGSHIFT)) 
  8020a9:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8020af:	77 39                	ja     8020ea <spawn+0x478>
				    {
						  is_below_ulim = false;
				    } else if (pte & PTE_SHARE) 
  8020b1:	f6 c4 04             	test   $0x4,%ah
  8020b4:	74 3b                	je     8020f1 <spawn+0x47f>
				    {
						  if ((r = sys_page_map(0, (void *)(pn * PGSIZE), child, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  8020b6:	83 ec 0c             	sub    $0xc,%esp
  8020b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8020be:	50                   	push   %eax
  8020bf:	57                   	push   %edi
  8020c0:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8020c6:	57                   	push   %edi
  8020c7:	6a 00                	push   $0x0
  8020c9:	e8 ba ee ff ff       	call   800f88 <sys_page_map>
  8020ce:	83 c4 20             	add    $0x20,%esp
  8020d1:	85 c0                	test   %eax,%eax
  8020d3:	79 1c                	jns    8020f1 <spawn+0x47f>
	   close(fd);
	   fd = -1;

	   // Copy shared library state.
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);
  8020d5:	50                   	push   %eax
  8020d6:	68 fe 30 80 00       	push   $0x8030fe
  8020db:	68 82 00 00 00       	push   $0x82
  8020e0:	68 a4 30 80 00       	push   $0x8030a4
  8020e5:	e8 fa e3 ff ff       	call   8004e4 <_panic>
			 {
				    unsigned pn = i * NPTENTRIES + j;
				    pte_t pte = uvpt[pn];
				    if (pn >= (UTOP >> PGSHIFT)) 
				    {
						  is_below_ulim = false;
  8020ea:	c6 85 94 fd ff ff 00 	movb   $0x0,-0x26c(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
	   {
			 if (!(uvpd[i] & PTE_P)) 
				    continue;
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) 
  8020f1:	83 c6 01             	add    $0x1,%esi
  8020f4:	83 c3 01             	add    $0x1,%ebx
  8020f7:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8020fd:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  802103:	7f 09                	jg     80210e <spawn+0x49c>
  802105:	80 bd 94 fd ff ff 00 	cmpb   $0x0,-0x26c(%ebp)
  80210c:	75 94                	jne    8020a2 <spawn+0x430>
copy_shared_pages(envid_t child)
{
	   // LAB 5: Your code here.
	   int r;
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
  80210e:	83 85 8c fd ff ff 01 	addl   $0x1,-0x274(%ebp)
  802115:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  80211b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802120:	0f 8f a4 00 00 00    	jg     8021ca <spawn+0x558>
  802126:	80 bd 94 fd ff ff 00 	cmpb   $0x0,-0x26c(%ebp)
  80212d:	0f 85 4f ff ff ff    	jne    802082 <spawn+0x410>
  802133:	e9 92 00 00 00       	jmp    8021ca <spawn+0x558>
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);

	   child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	   if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
			 panic("sys_env_set_trapframe: %e", r);
  802138:	50                   	push   %eax
  802139:	68 cd 30 80 00       	push   $0x8030cd
  80213e:	68 86 00 00 00       	push   $0x86
  802143:	68 a4 30 80 00       	push   $0x8030a4
  802148:	e8 97 e3 ff ff       	call   8004e4 <_panic>

	   if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80214d:	83 ec 08             	sub    $0x8,%esp
  802150:	6a 02                	push   $0x2
  802152:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802158:	e8 af ee ff ff       	call   80100c <sys_env_set_status>
  80215d:	83 c4 10             	add    $0x10,%esp
  802160:	85 c0                	test   %eax,%eax
  802162:	79 28                	jns    80218c <spawn+0x51a>
			 panic("sys_env_set_status: %e", r);
  802164:	50                   	push   %eax
  802165:	68 e7 30 80 00       	push   $0x8030e7
  80216a:	68 89 00 00 00       	push   $0x89
  80216f:	68 a4 30 80 00       	push   $0x8030a4
  802174:	e8 6b e3 ff ff       	call   8004e4 <_panic>
	   //     correct initial eip and esp values in the child.
	   //
	   //   - Start the child process running with sys_env_set_status().

	   if ((r = open(prog, O_RDONLY)) < 0)
			 return r;
  802179:	8b 9d 88 fd ff ff    	mov    -0x278(%ebp),%ebx
  80217f:	e9 87 00 00 00       	jmp    80220b <spawn+0x599>
			 return -E_NOT_EXEC;
	   }

	   // Create new child environment
	   if ((r = sys_exofork()) < 0)
			 return r;
  802184:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80218a:	eb 7f                	jmp    80220b <spawn+0x599>
			 panic("sys_env_set_trapframe: %e", r);

	   if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
			 panic("sys_env_set_status: %e", r);

	   return child;
  80218c:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802192:	eb 77                	jmp    80220b <spawn+0x599>
	   argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	   // Make sure that argv, strings, and the 2 words that hold 'argc'
	   // and 'argv' themselves will all fit in a single stack page.
	   if ((void*) (argv_store - 2) < (void*) UTEMP)
			 return -E_NO_MEM;
  802194:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802199:	eb 70                	jmp    80220b <spawn+0x599>

	   // Allocate the single stack page at UTEMP.
	   if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
			 return r;
  80219b:	89 c3                	mov    %eax,%ebx
  80219d:	eb 6c                	jmp    80220b <spawn+0x599>
				    // allocate a blank page
				    if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
						  return r;
			 } else {
				    // from file
				    if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80219f:	89 c3                	mov    %eax,%ebx
  8021a1:	eb 06                	jmp    8021a9 <spawn+0x537>
						  return r;
				    if ((r = seek(fd, fileoffset + i)) < 0)
  8021a3:	89 c3                	mov    %eax,%ebx
  8021a5:	eb 02                	jmp    8021a9 <spawn+0x537>
						  return r;
				    if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8021a7:	89 c3                	mov    %eax,%ebx
			 panic("sys_env_set_status: %e", r);

	   return child;

error:
	   sys_env_destroy(child);
  8021a9:	83 ec 0c             	sub    $0xc,%esp
  8021ac:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021b2:	e8 0f ed ff ff       	call   800ec6 <sys_env_destroy>
	   close(fd);
  8021b7:	83 c4 04             	add    $0x4,%esp
  8021ba:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8021c0:	e8 f9 f3 ff ff       	call   8015be <close>
	   return r;
  8021c5:	83 c4 10             	add    $0x10,%esp
  8021c8:	eb 41                	jmp    80220b <spawn+0x599>

	   // Copy shared library state.
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);

	   child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8021ca:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8021d1:	30 00 00 
	   if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8021d4:	83 ec 08             	sub    $0x8,%esp
  8021d7:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8021dd:	50                   	push   %eax
  8021de:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021e4:	e8 65 ee ff ff       	call   80104e <sys_env_set_trapframe>
  8021e9:	83 c4 10             	add    $0x10,%esp
  8021ec:	85 c0                	test   %eax,%eax
  8021ee:	0f 89 59 ff ff ff    	jns    80214d <spawn+0x4db>
  8021f4:	e9 3f ff ff ff       	jmp    802138 <spawn+0x4c6>
			 goto error;

	   return 0;

error:
	   sys_page_unmap(0, UTEMP);
  8021f9:	83 ec 08             	sub    $0x8,%esp
  8021fc:	68 00 00 40 00       	push   $0x400000
  802201:	6a 00                	push   $0x0
  802203:	e8 c2 ed ff ff       	call   800fca <sys_page_unmap>
  802208:	83 c4 10             	add    $0x10,%esp

error:
	   sys_env_destroy(child);
	   close(fd);
	   return r;
}
  80220b:	89 d8                	mov    %ebx,%eax
  80220d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802210:	5b                   	pop    %ebx
  802211:	5e                   	pop    %esi
  802212:	5f                   	pop    %edi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    

00802215 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
	   int
spawnl(const char *prog, const char *arg0, ...)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	56                   	push   %esi
  802219:	53                   	push   %ebx
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  80221a:	8d 55 10             	lea    0x10(%ebp),%edx
{
	   // We calculate argc by advancing the args until we hit NULL.
	   // The contract of the function guarantees that the last
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
  80221d:	b8 00 00 00 00       	mov    $0x0,%eax
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  802222:	eb 03                	jmp    802227 <spawnl+0x12>
			 argc++;
  802224:	83 c0 01             	add    $0x1,%eax
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  802227:	83 c2 04             	add    $0x4,%edx
  80222a:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  80222e:	75 f4                	jne    802224 <spawnl+0xf>
			 argc++;
	   va_end(vl);

	   // Now that we have the size of the args, do a second pass
	   // and store the values in a VLA, which has the format of argv
	   const char *argv[argc+2];
  802230:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802237:	83 e2 f0             	and    $0xfffffff0,%edx
  80223a:	29 d4                	sub    %edx,%esp
  80223c:	8d 54 24 03          	lea    0x3(%esp),%edx
  802240:	c1 ea 02             	shr    $0x2,%edx
  802243:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  80224a:	89 f3                	mov    %esi,%ebx
	   argv[0] = arg0;
  80224c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80224f:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	   argv[argc+1] = NULL;
  802256:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80225d:	00 
  80225e:	89 c2                	mov    %eax,%edx

	   va_start(vl, arg0);
	   unsigned i;
	   for(i=0;i<argc;i++)
  802260:	b8 00 00 00 00       	mov    $0x0,%eax
  802265:	eb 0a                	jmp    802271 <spawnl+0x5c>
			 argv[i+1] = va_arg(vl, const char *);
  802267:	83 c0 01             	add    $0x1,%eax
  80226a:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  80226e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	   argv[0] = arg0;
	   argv[argc+1] = NULL;

	   va_start(vl, arg0);
	   unsigned i;
	   for(i=0;i<argc;i++)
  802271:	39 d0                	cmp    %edx,%eax
  802273:	75 f2                	jne    802267 <spawnl+0x52>
			 argv[i+1] = va_arg(vl, const char *);
	   va_end(vl);
	   return spawn(prog, argv);
  802275:	83 ec 08             	sub    $0x8,%esp
  802278:	56                   	push   %esi
  802279:	ff 75 08             	pushl  0x8(%ebp)
  80227c:	e8 f1 f9 ff ff       	call   801c72 <spawn>
}
  802281:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    

00802288 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	56                   	push   %esi
  80228c:	53                   	push   %ebx
  80228d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802290:	83 ec 0c             	sub    $0xc,%esp
  802293:	ff 75 08             	pushl  0x8(%ebp)
  802296:	e8 93 f1 ff ff       	call   80142e <fd2data>
  80229b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80229d:	83 c4 08             	add    $0x8,%esp
  8022a0:	68 3c 31 80 00       	push   $0x80313c
  8022a5:	53                   	push   %ebx
  8022a6:	e8 97 e8 ff ff       	call   800b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8022ab:	8b 46 04             	mov    0x4(%esi),%eax
  8022ae:	2b 06                	sub    (%esi),%eax
  8022b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8022b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022bd:	00 00 00 
	stat->st_dev = &devpipe;
  8022c0:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8022c7:	40 80 00 
	return 0;
}
  8022ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8022cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022d2:	5b                   	pop    %ebx
  8022d3:	5e                   	pop    %esi
  8022d4:	5d                   	pop    %ebp
  8022d5:	c3                   	ret    

008022d6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	53                   	push   %ebx
  8022da:	83 ec 0c             	sub    $0xc,%esp
  8022dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8022e0:	53                   	push   %ebx
  8022e1:	6a 00                	push   $0x0
  8022e3:	e8 e2 ec ff ff       	call   800fca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8022e8:	89 1c 24             	mov    %ebx,(%esp)
  8022eb:	e8 3e f1 ff ff       	call   80142e <fd2data>
  8022f0:	83 c4 08             	add    $0x8,%esp
  8022f3:	50                   	push   %eax
  8022f4:	6a 00                	push   $0x0
  8022f6:	e8 cf ec ff ff       	call   800fca <sys_page_unmap>
}
  8022fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022fe:	c9                   	leave  
  8022ff:	c3                   	ret    

00802300 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802300:	55                   	push   %ebp
  802301:	89 e5                	mov    %esp,%ebp
  802303:	57                   	push   %edi
  802304:	56                   	push   %esi
  802305:	53                   	push   %ebx
  802306:	83 ec 1c             	sub    $0x1c,%esp
  802309:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80230c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80230e:	a1 04 50 80 00       	mov    0x805004,%eax
  802313:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802316:	83 ec 0c             	sub    $0xc,%esp
  802319:	ff 75 e0             	pushl  -0x20(%ebp)
  80231c:	e8 7d 04 00 00       	call   80279e <pageref>
  802321:	89 c3                	mov    %eax,%ebx
  802323:	89 3c 24             	mov    %edi,(%esp)
  802326:	e8 73 04 00 00       	call   80279e <pageref>
  80232b:	83 c4 10             	add    $0x10,%esp
  80232e:	39 c3                	cmp    %eax,%ebx
  802330:	0f 94 c1             	sete   %cl
  802333:	0f b6 c9             	movzbl %cl,%ecx
  802336:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802339:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80233f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802342:	39 ce                	cmp    %ecx,%esi
  802344:	74 1b                	je     802361 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802346:	39 c3                	cmp    %eax,%ebx
  802348:	75 c4                	jne    80230e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80234a:	8b 42 58             	mov    0x58(%edx),%eax
  80234d:	ff 75 e4             	pushl  -0x1c(%ebp)
  802350:	50                   	push   %eax
  802351:	56                   	push   %esi
  802352:	68 43 31 80 00       	push   $0x803143
  802357:	e8 61 e2 ff ff       	call   8005bd <cprintf>
  80235c:	83 c4 10             	add    $0x10,%esp
  80235f:	eb ad                	jmp    80230e <_pipeisclosed+0xe>
	}
}
  802361:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802364:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802367:	5b                   	pop    %ebx
  802368:	5e                   	pop    %esi
  802369:	5f                   	pop    %edi
  80236a:	5d                   	pop    %ebp
  80236b:	c3                   	ret    

0080236c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80236c:	55                   	push   %ebp
  80236d:	89 e5                	mov    %esp,%ebp
  80236f:	57                   	push   %edi
  802370:	56                   	push   %esi
  802371:	53                   	push   %ebx
  802372:	83 ec 28             	sub    $0x28,%esp
  802375:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802378:	56                   	push   %esi
  802379:	e8 b0 f0 ff ff       	call   80142e <fd2data>
  80237e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802380:	83 c4 10             	add    $0x10,%esp
  802383:	bf 00 00 00 00       	mov    $0x0,%edi
  802388:	eb 4b                	jmp    8023d5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80238a:	89 da                	mov    %ebx,%edx
  80238c:	89 f0                	mov    %esi,%eax
  80238e:	e8 6d ff ff ff       	call   802300 <_pipeisclosed>
  802393:	85 c0                	test   %eax,%eax
  802395:	75 48                	jne    8023df <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802397:	e8 8a eb ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80239c:	8b 43 04             	mov    0x4(%ebx),%eax
  80239f:	8b 0b                	mov    (%ebx),%ecx
  8023a1:	8d 51 20             	lea    0x20(%ecx),%edx
  8023a4:	39 d0                	cmp    %edx,%eax
  8023a6:	73 e2                	jae    80238a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023ab:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8023af:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8023b2:	89 c2                	mov    %eax,%edx
  8023b4:	c1 fa 1f             	sar    $0x1f,%edx
  8023b7:	89 d1                	mov    %edx,%ecx
  8023b9:	c1 e9 1b             	shr    $0x1b,%ecx
  8023bc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8023bf:	83 e2 1f             	and    $0x1f,%edx
  8023c2:	29 ca                	sub    %ecx,%edx
  8023c4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8023c8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8023cc:	83 c0 01             	add    $0x1,%eax
  8023cf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023d2:	83 c7 01             	add    $0x1,%edi
  8023d5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8023d8:	75 c2                	jne    80239c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8023da:	8b 45 10             	mov    0x10(%ebp),%eax
  8023dd:	eb 05                	jmp    8023e4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023df:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8023e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023e7:	5b                   	pop    %ebx
  8023e8:	5e                   	pop    %esi
  8023e9:	5f                   	pop    %edi
  8023ea:	5d                   	pop    %ebp
  8023eb:	c3                   	ret    

008023ec <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	57                   	push   %edi
  8023f0:	56                   	push   %esi
  8023f1:	53                   	push   %ebx
  8023f2:	83 ec 18             	sub    $0x18,%esp
  8023f5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8023f8:	57                   	push   %edi
  8023f9:	e8 30 f0 ff ff       	call   80142e <fd2data>
  8023fe:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802400:	83 c4 10             	add    $0x10,%esp
  802403:	bb 00 00 00 00       	mov    $0x0,%ebx
  802408:	eb 3d                	jmp    802447 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80240a:	85 db                	test   %ebx,%ebx
  80240c:	74 04                	je     802412 <devpipe_read+0x26>
				return i;
  80240e:	89 d8                	mov    %ebx,%eax
  802410:	eb 44                	jmp    802456 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802412:	89 f2                	mov    %esi,%edx
  802414:	89 f8                	mov    %edi,%eax
  802416:	e8 e5 fe ff ff       	call   802300 <_pipeisclosed>
  80241b:	85 c0                	test   %eax,%eax
  80241d:	75 32                	jne    802451 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80241f:	e8 02 eb ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802424:	8b 06                	mov    (%esi),%eax
  802426:	3b 46 04             	cmp    0x4(%esi),%eax
  802429:	74 df                	je     80240a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80242b:	99                   	cltd   
  80242c:	c1 ea 1b             	shr    $0x1b,%edx
  80242f:	01 d0                	add    %edx,%eax
  802431:	83 e0 1f             	and    $0x1f,%eax
  802434:	29 d0                	sub    %edx,%eax
  802436:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80243b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80243e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802441:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802444:	83 c3 01             	add    $0x1,%ebx
  802447:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80244a:	75 d8                	jne    802424 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80244c:	8b 45 10             	mov    0x10(%ebp),%eax
  80244f:	eb 05                	jmp    802456 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802451:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802456:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802459:	5b                   	pop    %ebx
  80245a:	5e                   	pop    %esi
  80245b:	5f                   	pop    %edi
  80245c:	5d                   	pop    %ebp
  80245d:	c3                   	ret    

0080245e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80245e:	55                   	push   %ebp
  80245f:	89 e5                	mov    %esp,%ebp
  802461:	56                   	push   %esi
  802462:	53                   	push   %ebx
  802463:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802466:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802469:	50                   	push   %eax
  80246a:	e8 d6 ef ff ff       	call   801445 <fd_alloc>
  80246f:	83 c4 10             	add    $0x10,%esp
  802472:	89 c2                	mov    %eax,%edx
  802474:	85 c0                	test   %eax,%eax
  802476:	0f 88 2c 01 00 00    	js     8025a8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80247c:	83 ec 04             	sub    $0x4,%esp
  80247f:	68 07 04 00 00       	push   $0x407
  802484:	ff 75 f4             	pushl  -0xc(%ebp)
  802487:	6a 00                	push   $0x0
  802489:	e8 b7 ea ff ff       	call   800f45 <sys_page_alloc>
  80248e:	83 c4 10             	add    $0x10,%esp
  802491:	89 c2                	mov    %eax,%edx
  802493:	85 c0                	test   %eax,%eax
  802495:	0f 88 0d 01 00 00    	js     8025a8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80249b:	83 ec 0c             	sub    $0xc,%esp
  80249e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8024a1:	50                   	push   %eax
  8024a2:	e8 9e ef ff ff       	call   801445 <fd_alloc>
  8024a7:	89 c3                	mov    %eax,%ebx
  8024a9:	83 c4 10             	add    $0x10,%esp
  8024ac:	85 c0                	test   %eax,%eax
  8024ae:	0f 88 e2 00 00 00    	js     802596 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024b4:	83 ec 04             	sub    $0x4,%esp
  8024b7:	68 07 04 00 00       	push   $0x407
  8024bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8024bf:	6a 00                	push   $0x0
  8024c1:	e8 7f ea ff ff       	call   800f45 <sys_page_alloc>
  8024c6:	89 c3                	mov    %eax,%ebx
  8024c8:	83 c4 10             	add    $0x10,%esp
  8024cb:	85 c0                	test   %eax,%eax
  8024cd:	0f 88 c3 00 00 00    	js     802596 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8024d3:	83 ec 0c             	sub    $0xc,%esp
  8024d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8024d9:	e8 50 ef ff ff       	call   80142e <fd2data>
  8024de:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024e0:	83 c4 0c             	add    $0xc,%esp
  8024e3:	68 07 04 00 00       	push   $0x407
  8024e8:	50                   	push   %eax
  8024e9:	6a 00                	push   $0x0
  8024eb:	e8 55 ea ff ff       	call   800f45 <sys_page_alloc>
  8024f0:	89 c3                	mov    %eax,%ebx
  8024f2:	83 c4 10             	add    $0x10,%esp
  8024f5:	85 c0                	test   %eax,%eax
  8024f7:	0f 88 89 00 00 00    	js     802586 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024fd:	83 ec 0c             	sub    $0xc,%esp
  802500:	ff 75 f0             	pushl  -0x10(%ebp)
  802503:	e8 26 ef ff ff       	call   80142e <fd2data>
  802508:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80250f:	50                   	push   %eax
  802510:	6a 00                	push   $0x0
  802512:	56                   	push   %esi
  802513:	6a 00                	push   $0x0
  802515:	e8 6e ea ff ff       	call   800f88 <sys_page_map>
  80251a:	89 c3                	mov    %eax,%ebx
  80251c:	83 c4 20             	add    $0x20,%esp
  80251f:	85 c0                	test   %eax,%eax
  802521:	78 55                	js     802578 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802523:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802529:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80252c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80252e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802531:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802538:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80253e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802541:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802546:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80254d:	83 ec 0c             	sub    $0xc,%esp
  802550:	ff 75 f4             	pushl  -0xc(%ebp)
  802553:	e8 c6 ee ff ff       	call   80141e <fd2num>
  802558:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80255b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80255d:	83 c4 04             	add    $0x4,%esp
  802560:	ff 75 f0             	pushl  -0x10(%ebp)
  802563:	e8 b6 ee ff ff       	call   80141e <fd2num>
  802568:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80256b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80256e:	83 c4 10             	add    $0x10,%esp
  802571:	ba 00 00 00 00       	mov    $0x0,%edx
  802576:	eb 30                	jmp    8025a8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802578:	83 ec 08             	sub    $0x8,%esp
  80257b:	56                   	push   %esi
  80257c:	6a 00                	push   $0x0
  80257e:	e8 47 ea ff ff       	call   800fca <sys_page_unmap>
  802583:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802586:	83 ec 08             	sub    $0x8,%esp
  802589:	ff 75 f0             	pushl  -0x10(%ebp)
  80258c:	6a 00                	push   $0x0
  80258e:	e8 37 ea ff ff       	call   800fca <sys_page_unmap>
  802593:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802596:	83 ec 08             	sub    $0x8,%esp
  802599:	ff 75 f4             	pushl  -0xc(%ebp)
  80259c:	6a 00                	push   $0x0
  80259e:	e8 27 ea ff ff       	call   800fca <sys_page_unmap>
  8025a3:	83 c4 10             	add    $0x10,%esp
  8025a6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8025a8:	89 d0                	mov    %edx,%eax
  8025aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025ad:	5b                   	pop    %ebx
  8025ae:	5e                   	pop    %esi
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    

008025b1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8025b1:	55                   	push   %ebp
  8025b2:	89 e5                	mov    %esp,%ebp
  8025b4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025ba:	50                   	push   %eax
  8025bb:	ff 75 08             	pushl  0x8(%ebp)
  8025be:	e8 d1 ee ff ff       	call   801494 <fd_lookup>
  8025c3:	83 c4 10             	add    $0x10,%esp
  8025c6:	85 c0                	test   %eax,%eax
  8025c8:	78 18                	js     8025e2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8025ca:	83 ec 0c             	sub    $0xc,%esp
  8025cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8025d0:	e8 59 ee ff ff       	call   80142e <fd2data>
	return _pipeisclosed(fd, p);
  8025d5:	89 c2                	mov    %eax,%edx
  8025d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025da:	e8 21 fd ff ff       	call   802300 <_pipeisclosed>
  8025df:	83 c4 10             	add    $0x10,%esp
}
  8025e2:	c9                   	leave  
  8025e3:	c3                   	ret    

008025e4 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8025e4:	55                   	push   %ebp
  8025e5:	89 e5                	mov    %esp,%ebp
  8025e7:	56                   	push   %esi
  8025e8:	53                   	push   %ebx
  8025e9:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8025ec:	85 f6                	test   %esi,%esi
  8025ee:	75 16                	jne    802606 <wait+0x22>
  8025f0:	68 5b 31 80 00       	push   $0x80315b
  8025f5:	68 4b 30 80 00       	push   $0x80304b
  8025fa:	6a 09                	push   $0x9
  8025fc:	68 66 31 80 00       	push   $0x803166
  802601:	e8 de de ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  802606:	89 f3                	mov    %esi,%ebx
  802608:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80260e:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802611:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802617:	eb 05                	jmp    80261e <wait+0x3a>
		sys_yield();
  802619:	e8 08 e9 ff ff       	call   800f26 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80261e:	8b 43 48             	mov    0x48(%ebx),%eax
  802621:	39 c6                	cmp    %eax,%esi
  802623:	75 07                	jne    80262c <wait+0x48>
  802625:	8b 43 54             	mov    0x54(%ebx),%eax
  802628:	85 c0                	test   %eax,%eax
  80262a:	75 ed                	jne    802619 <wait+0x35>
		sys_yield();
}
  80262c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80262f:	5b                   	pop    %ebx
  802630:	5e                   	pop    %esi
  802631:	5d                   	pop    %ebp
  802632:	c3                   	ret    

00802633 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802633:	55                   	push   %ebp
  802634:	89 e5                	mov    %esp,%ebp
  802636:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  802639:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802640:	75 2a                	jne    80266c <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  802642:	83 ec 04             	sub    $0x4,%esp
  802645:	6a 06                	push   $0x6
  802647:	68 00 f0 bf ee       	push   $0xeebff000
  80264c:	6a 00                	push   $0x0
  80264e:	e8 f2 e8 ff ff       	call   800f45 <sys_page_alloc>
			 if (a < 0)
  802653:	83 c4 10             	add    $0x10,%esp
  802656:	85 c0                	test   %eax,%eax
  802658:	79 12                	jns    80266c <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  80265a:	50                   	push   %eax
  80265b:	68 71 31 80 00       	push   $0x803171
  802660:	6a 21                	push   $0x21
  802662:	68 8b 31 80 00       	push   $0x80318b
  802667:	e8 78 de ff ff       	call   8004e4 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  80266c:	e8 96 e8 ff ff       	call   800f07 <sys_getenvid>
  802671:	83 ec 08             	sub    $0x8,%esp
  802674:	68 8c 26 80 00       	push   $0x80268c
  802679:	50                   	push   %eax
  80267a:	e8 11 ea ff ff       	call   801090 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  80267f:	8b 45 08             	mov    0x8(%ebp),%eax
  802682:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802687:	83 c4 10             	add    $0x10,%esp
  80268a:	c9                   	leave  
  80268b:	c3                   	ret    

0080268c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  80268c:	54                   	push   %esp
movl _pgfault_handler, %eax
  80268d:	a1 00 70 80 00       	mov    0x807000,%eax
call *%eax
  802692:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  802694:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  802697:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  80269b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  80269f:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  8026a2:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  8026a6:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  8026a8:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  8026ab:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  8026ac:	83 c4 04             	add    $0x4,%esp
popfl
  8026af:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  8026b0:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  8026b1:	c3                   	ret    

008026b2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026b2:	55                   	push   %ebp
  8026b3:	89 e5                	mov    %esp,%ebp
  8026b5:	56                   	push   %esi
  8026b6:	53                   	push   %ebx
  8026b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8026ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  8026c0:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  8026c2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8026c7:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  8026ca:	83 ec 0c             	sub    $0xc,%esp
  8026cd:	50                   	push   %eax
  8026ce:	e8 22 ea ff ff       	call   8010f5 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  8026d3:	83 c4 10             	add    $0x10,%esp
  8026d6:	85 c0                	test   %eax,%eax
  8026d8:	78 0e                	js     8026e8 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  8026da:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8026e0:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  8026e3:	8b 52 78             	mov    0x78(%edx),%edx
  8026e6:	eb 0a                	jmp    8026f2 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  8026e8:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  8026ed:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  8026f2:	85 f6                	test   %esi,%esi
  8026f4:	74 02                	je     8026f8 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  8026f6:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  8026f8:	85 db                	test   %ebx,%ebx
  8026fa:	74 02                	je     8026fe <ipc_recv+0x4c>
			 *perm_store = s_perm;
  8026fc:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  8026fe:	85 c0                	test   %eax,%eax
  802700:	78 08                	js     80270a <ipc_recv+0x58>
  802702:	a1 04 50 80 00       	mov    0x805004,%eax
  802707:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  80270a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80270d:	5b                   	pop    %ebx
  80270e:	5e                   	pop    %esi
  80270f:	5d                   	pop    %ebp
  802710:	c3                   	ret    

00802711 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802711:	55                   	push   %ebp
  802712:	89 e5                	mov    %esp,%ebp
  802714:	57                   	push   %edi
  802715:	56                   	push   %esi
  802716:	53                   	push   %ebx
  802717:	83 ec 0c             	sub    $0xc,%esp
  80271a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80271d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802720:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  802723:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  802725:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  80272a:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  80272d:	ff 75 14             	pushl  0x14(%ebp)
  802730:	53                   	push   %ebx
  802731:	56                   	push   %esi
  802732:	57                   	push   %edi
  802733:	e8 9a e9 ff ff       	call   8010d2 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  802738:	83 c4 10             	add    $0x10,%esp
  80273b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80273e:	75 07                	jne    802747 <ipc_send+0x36>
				    sys_yield();
  802740:	e8 e1 e7 ff ff       	call   800f26 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  802745:	eb e6                	jmp    80272d <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  802747:	85 c0                	test   %eax,%eax
  802749:	74 12                	je     80275d <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  80274b:	50                   	push   %eax
  80274c:	68 99 31 80 00       	push   $0x803199
  802751:	6a 4b                	push   $0x4b
  802753:	68 ad 31 80 00       	push   $0x8031ad
  802758:	e8 87 dd ff ff       	call   8004e4 <_panic>
			 }
	   }
}
  80275d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802760:	5b                   	pop    %ebx
  802761:	5e                   	pop    %esi
  802762:	5f                   	pop    %edi
  802763:	5d                   	pop    %ebp
  802764:	c3                   	ret    

00802765 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  802765:	55                   	push   %ebp
  802766:	89 e5                	mov    %esp,%ebp
  802768:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  80276b:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  802770:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802773:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802779:	8b 52 50             	mov    0x50(%edx),%edx
  80277c:	39 ca                	cmp    %ecx,%edx
  80277e:	75 0d                	jne    80278d <ipc_find_env+0x28>
				    return envs[i].env_id;
  802780:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802783:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802788:	8b 40 48             	mov    0x48(%eax),%eax
  80278b:	eb 0f                	jmp    80279c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  80278d:	83 c0 01             	add    $0x1,%eax
  802790:	3d 00 04 00 00       	cmp    $0x400,%eax
  802795:	75 d9                	jne    802770 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  802797:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80279c:	5d                   	pop    %ebp
  80279d:	c3                   	ret    

0080279e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80279e:	55                   	push   %ebp
  80279f:	89 e5                	mov    %esp,%ebp
  8027a1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027a4:	89 d0                	mov    %edx,%eax
  8027a6:	c1 e8 16             	shr    $0x16,%eax
  8027a9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8027b0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027b5:	f6 c1 01             	test   $0x1,%cl
  8027b8:	74 1d                	je     8027d7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8027ba:	c1 ea 0c             	shr    $0xc,%edx
  8027bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8027c4:	f6 c2 01             	test   $0x1,%dl
  8027c7:	74 0e                	je     8027d7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027c9:	c1 ea 0c             	shr    $0xc,%edx
  8027cc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8027d3:	ef 
  8027d4:	0f b7 c0             	movzwl %ax,%eax
}
  8027d7:	5d                   	pop    %ebp
  8027d8:	c3                   	ret    
  8027d9:	66 90                	xchg   %ax,%ax
  8027db:	66 90                	xchg   %ax,%ax
  8027dd:	66 90                	xchg   %ax,%ax
  8027df:	90                   	nop

008027e0 <__udivdi3>:
  8027e0:	55                   	push   %ebp
  8027e1:	57                   	push   %edi
  8027e2:	56                   	push   %esi
  8027e3:	53                   	push   %ebx
  8027e4:	83 ec 1c             	sub    $0x1c,%esp
  8027e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027f7:	85 f6                	test   %esi,%esi
  8027f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027fd:	89 ca                	mov    %ecx,%edx
  8027ff:	89 f8                	mov    %edi,%eax
  802801:	75 3d                	jne    802840 <__udivdi3+0x60>
  802803:	39 cf                	cmp    %ecx,%edi
  802805:	0f 87 c5 00 00 00    	ja     8028d0 <__udivdi3+0xf0>
  80280b:	85 ff                	test   %edi,%edi
  80280d:	89 fd                	mov    %edi,%ebp
  80280f:	75 0b                	jne    80281c <__udivdi3+0x3c>
  802811:	b8 01 00 00 00       	mov    $0x1,%eax
  802816:	31 d2                	xor    %edx,%edx
  802818:	f7 f7                	div    %edi
  80281a:	89 c5                	mov    %eax,%ebp
  80281c:	89 c8                	mov    %ecx,%eax
  80281e:	31 d2                	xor    %edx,%edx
  802820:	f7 f5                	div    %ebp
  802822:	89 c1                	mov    %eax,%ecx
  802824:	89 d8                	mov    %ebx,%eax
  802826:	89 cf                	mov    %ecx,%edi
  802828:	f7 f5                	div    %ebp
  80282a:	89 c3                	mov    %eax,%ebx
  80282c:	89 d8                	mov    %ebx,%eax
  80282e:	89 fa                	mov    %edi,%edx
  802830:	83 c4 1c             	add    $0x1c,%esp
  802833:	5b                   	pop    %ebx
  802834:	5e                   	pop    %esi
  802835:	5f                   	pop    %edi
  802836:	5d                   	pop    %ebp
  802837:	c3                   	ret    
  802838:	90                   	nop
  802839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802840:	39 ce                	cmp    %ecx,%esi
  802842:	77 74                	ja     8028b8 <__udivdi3+0xd8>
  802844:	0f bd fe             	bsr    %esi,%edi
  802847:	83 f7 1f             	xor    $0x1f,%edi
  80284a:	0f 84 98 00 00 00    	je     8028e8 <__udivdi3+0x108>
  802850:	bb 20 00 00 00       	mov    $0x20,%ebx
  802855:	89 f9                	mov    %edi,%ecx
  802857:	89 c5                	mov    %eax,%ebp
  802859:	29 fb                	sub    %edi,%ebx
  80285b:	d3 e6                	shl    %cl,%esi
  80285d:	89 d9                	mov    %ebx,%ecx
  80285f:	d3 ed                	shr    %cl,%ebp
  802861:	89 f9                	mov    %edi,%ecx
  802863:	d3 e0                	shl    %cl,%eax
  802865:	09 ee                	or     %ebp,%esi
  802867:	89 d9                	mov    %ebx,%ecx
  802869:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80286d:	89 d5                	mov    %edx,%ebp
  80286f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802873:	d3 ed                	shr    %cl,%ebp
  802875:	89 f9                	mov    %edi,%ecx
  802877:	d3 e2                	shl    %cl,%edx
  802879:	89 d9                	mov    %ebx,%ecx
  80287b:	d3 e8                	shr    %cl,%eax
  80287d:	09 c2                	or     %eax,%edx
  80287f:	89 d0                	mov    %edx,%eax
  802881:	89 ea                	mov    %ebp,%edx
  802883:	f7 f6                	div    %esi
  802885:	89 d5                	mov    %edx,%ebp
  802887:	89 c3                	mov    %eax,%ebx
  802889:	f7 64 24 0c          	mull   0xc(%esp)
  80288d:	39 d5                	cmp    %edx,%ebp
  80288f:	72 10                	jb     8028a1 <__udivdi3+0xc1>
  802891:	8b 74 24 08          	mov    0x8(%esp),%esi
  802895:	89 f9                	mov    %edi,%ecx
  802897:	d3 e6                	shl    %cl,%esi
  802899:	39 c6                	cmp    %eax,%esi
  80289b:	73 07                	jae    8028a4 <__udivdi3+0xc4>
  80289d:	39 d5                	cmp    %edx,%ebp
  80289f:	75 03                	jne    8028a4 <__udivdi3+0xc4>
  8028a1:	83 eb 01             	sub    $0x1,%ebx
  8028a4:	31 ff                	xor    %edi,%edi
  8028a6:	89 d8                	mov    %ebx,%eax
  8028a8:	89 fa                	mov    %edi,%edx
  8028aa:	83 c4 1c             	add    $0x1c,%esp
  8028ad:	5b                   	pop    %ebx
  8028ae:	5e                   	pop    %esi
  8028af:	5f                   	pop    %edi
  8028b0:	5d                   	pop    %ebp
  8028b1:	c3                   	ret    
  8028b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028b8:	31 ff                	xor    %edi,%edi
  8028ba:	31 db                	xor    %ebx,%ebx
  8028bc:	89 d8                	mov    %ebx,%eax
  8028be:	89 fa                	mov    %edi,%edx
  8028c0:	83 c4 1c             	add    $0x1c,%esp
  8028c3:	5b                   	pop    %ebx
  8028c4:	5e                   	pop    %esi
  8028c5:	5f                   	pop    %edi
  8028c6:	5d                   	pop    %ebp
  8028c7:	c3                   	ret    
  8028c8:	90                   	nop
  8028c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028d0:	89 d8                	mov    %ebx,%eax
  8028d2:	f7 f7                	div    %edi
  8028d4:	31 ff                	xor    %edi,%edi
  8028d6:	89 c3                	mov    %eax,%ebx
  8028d8:	89 d8                	mov    %ebx,%eax
  8028da:	89 fa                	mov    %edi,%edx
  8028dc:	83 c4 1c             	add    $0x1c,%esp
  8028df:	5b                   	pop    %ebx
  8028e0:	5e                   	pop    %esi
  8028e1:	5f                   	pop    %edi
  8028e2:	5d                   	pop    %ebp
  8028e3:	c3                   	ret    
  8028e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028e8:	39 ce                	cmp    %ecx,%esi
  8028ea:	72 0c                	jb     8028f8 <__udivdi3+0x118>
  8028ec:	31 db                	xor    %ebx,%ebx
  8028ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028f2:	0f 87 34 ff ff ff    	ja     80282c <__udivdi3+0x4c>
  8028f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028fd:	e9 2a ff ff ff       	jmp    80282c <__udivdi3+0x4c>
  802902:	66 90                	xchg   %ax,%ax
  802904:	66 90                	xchg   %ax,%ax
  802906:	66 90                	xchg   %ax,%ax
  802908:	66 90                	xchg   %ax,%ax
  80290a:	66 90                	xchg   %ax,%ax
  80290c:	66 90                	xchg   %ax,%ax
  80290e:	66 90                	xchg   %ax,%ax

00802910 <__umoddi3>:
  802910:	55                   	push   %ebp
  802911:	57                   	push   %edi
  802912:	56                   	push   %esi
  802913:	53                   	push   %ebx
  802914:	83 ec 1c             	sub    $0x1c,%esp
  802917:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80291b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80291f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802923:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802927:	85 d2                	test   %edx,%edx
  802929:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80292d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802931:	89 f3                	mov    %esi,%ebx
  802933:	89 3c 24             	mov    %edi,(%esp)
  802936:	89 74 24 04          	mov    %esi,0x4(%esp)
  80293a:	75 1c                	jne    802958 <__umoddi3+0x48>
  80293c:	39 f7                	cmp    %esi,%edi
  80293e:	76 50                	jbe    802990 <__umoddi3+0x80>
  802940:	89 c8                	mov    %ecx,%eax
  802942:	89 f2                	mov    %esi,%edx
  802944:	f7 f7                	div    %edi
  802946:	89 d0                	mov    %edx,%eax
  802948:	31 d2                	xor    %edx,%edx
  80294a:	83 c4 1c             	add    $0x1c,%esp
  80294d:	5b                   	pop    %ebx
  80294e:	5e                   	pop    %esi
  80294f:	5f                   	pop    %edi
  802950:	5d                   	pop    %ebp
  802951:	c3                   	ret    
  802952:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802958:	39 f2                	cmp    %esi,%edx
  80295a:	89 d0                	mov    %edx,%eax
  80295c:	77 52                	ja     8029b0 <__umoddi3+0xa0>
  80295e:	0f bd ea             	bsr    %edx,%ebp
  802961:	83 f5 1f             	xor    $0x1f,%ebp
  802964:	75 5a                	jne    8029c0 <__umoddi3+0xb0>
  802966:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80296a:	0f 82 e0 00 00 00    	jb     802a50 <__umoddi3+0x140>
  802970:	39 0c 24             	cmp    %ecx,(%esp)
  802973:	0f 86 d7 00 00 00    	jbe    802a50 <__umoddi3+0x140>
  802979:	8b 44 24 08          	mov    0x8(%esp),%eax
  80297d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802981:	83 c4 1c             	add    $0x1c,%esp
  802984:	5b                   	pop    %ebx
  802985:	5e                   	pop    %esi
  802986:	5f                   	pop    %edi
  802987:	5d                   	pop    %ebp
  802988:	c3                   	ret    
  802989:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802990:	85 ff                	test   %edi,%edi
  802992:	89 fd                	mov    %edi,%ebp
  802994:	75 0b                	jne    8029a1 <__umoddi3+0x91>
  802996:	b8 01 00 00 00       	mov    $0x1,%eax
  80299b:	31 d2                	xor    %edx,%edx
  80299d:	f7 f7                	div    %edi
  80299f:	89 c5                	mov    %eax,%ebp
  8029a1:	89 f0                	mov    %esi,%eax
  8029a3:	31 d2                	xor    %edx,%edx
  8029a5:	f7 f5                	div    %ebp
  8029a7:	89 c8                	mov    %ecx,%eax
  8029a9:	f7 f5                	div    %ebp
  8029ab:	89 d0                	mov    %edx,%eax
  8029ad:	eb 99                	jmp    802948 <__umoddi3+0x38>
  8029af:	90                   	nop
  8029b0:	89 c8                	mov    %ecx,%eax
  8029b2:	89 f2                	mov    %esi,%edx
  8029b4:	83 c4 1c             	add    $0x1c,%esp
  8029b7:	5b                   	pop    %ebx
  8029b8:	5e                   	pop    %esi
  8029b9:	5f                   	pop    %edi
  8029ba:	5d                   	pop    %ebp
  8029bb:	c3                   	ret    
  8029bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029c0:	8b 34 24             	mov    (%esp),%esi
  8029c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8029c8:	89 e9                	mov    %ebp,%ecx
  8029ca:	29 ef                	sub    %ebp,%edi
  8029cc:	d3 e0                	shl    %cl,%eax
  8029ce:	89 f9                	mov    %edi,%ecx
  8029d0:	89 f2                	mov    %esi,%edx
  8029d2:	d3 ea                	shr    %cl,%edx
  8029d4:	89 e9                	mov    %ebp,%ecx
  8029d6:	09 c2                	or     %eax,%edx
  8029d8:	89 d8                	mov    %ebx,%eax
  8029da:	89 14 24             	mov    %edx,(%esp)
  8029dd:	89 f2                	mov    %esi,%edx
  8029df:	d3 e2                	shl    %cl,%edx
  8029e1:	89 f9                	mov    %edi,%ecx
  8029e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029eb:	d3 e8                	shr    %cl,%eax
  8029ed:	89 e9                	mov    %ebp,%ecx
  8029ef:	89 c6                	mov    %eax,%esi
  8029f1:	d3 e3                	shl    %cl,%ebx
  8029f3:	89 f9                	mov    %edi,%ecx
  8029f5:	89 d0                	mov    %edx,%eax
  8029f7:	d3 e8                	shr    %cl,%eax
  8029f9:	89 e9                	mov    %ebp,%ecx
  8029fb:	09 d8                	or     %ebx,%eax
  8029fd:	89 d3                	mov    %edx,%ebx
  8029ff:	89 f2                	mov    %esi,%edx
  802a01:	f7 34 24             	divl   (%esp)
  802a04:	89 d6                	mov    %edx,%esi
  802a06:	d3 e3                	shl    %cl,%ebx
  802a08:	f7 64 24 04          	mull   0x4(%esp)
  802a0c:	39 d6                	cmp    %edx,%esi
  802a0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a12:	89 d1                	mov    %edx,%ecx
  802a14:	89 c3                	mov    %eax,%ebx
  802a16:	72 08                	jb     802a20 <__umoddi3+0x110>
  802a18:	75 11                	jne    802a2b <__umoddi3+0x11b>
  802a1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802a1e:	73 0b                	jae    802a2b <__umoddi3+0x11b>
  802a20:	2b 44 24 04          	sub    0x4(%esp),%eax
  802a24:	1b 14 24             	sbb    (%esp),%edx
  802a27:	89 d1                	mov    %edx,%ecx
  802a29:	89 c3                	mov    %eax,%ebx
  802a2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802a2f:	29 da                	sub    %ebx,%edx
  802a31:	19 ce                	sbb    %ecx,%esi
  802a33:	89 f9                	mov    %edi,%ecx
  802a35:	89 f0                	mov    %esi,%eax
  802a37:	d3 e0                	shl    %cl,%eax
  802a39:	89 e9                	mov    %ebp,%ecx
  802a3b:	d3 ea                	shr    %cl,%edx
  802a3d:	89 e9                	mov    %ebp,%ecx
  802a3f:	d3 ee                	shr    %cl,%esi
  802a41:	09 d0                	or     %edx,%eax
  802a43:	89 f2                	mov    %esi,%edx
  802a45:	83 c4 1c             	add    $0x1c,%esp
  802a48:	5b                   	pop    %ebx
  802a49:	5e                   	pop    %esi
  802a4a:	5f                   	pop    %edi
  802a4b:	5d                   	pop    %ebp
  802a4c:	c3                   	ret    
  802a4d:	8d 76 00             	lea    0x0(%esi),%esi
  802a50:	29 f9                	sub    %edi,%ecx
  802a52:	19 d6                	sbb    %edx,%esi
  802a54:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a5c:	e9 18 ff ff ff       	jmp    802979 <__umoddi3+0x69>
