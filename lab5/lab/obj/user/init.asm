
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 20 26 80 00       	push   $0x802620
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 30 80 00       	push   $0x803000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 e8 26 80 00       	push   $0x8026e8
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 2f 26 80 00       	push   $0x80262f
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 50 80 00       	push   $0x805020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 24 27 80 00       	push   $0x802724
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 46 26 80 00       	push   $0x802646
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 5c 26 80 00       	push   $0x80265c
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 72 09 00 00       	call   800a7d <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 68 26 80 00       	push   $0x802668
  800123:	56                   	push   %esi
  800124:	e8 54 09 00 00       	call   800a7d <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 48 09 00 00       	call   800a7d <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 69 26 80 00       	push   $0x802669
  80013d:	56                   	push   %esi
  80013e:	e8 3a 09 00 00       	call   800a7d <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 6b 26 80 00       	push   $0x80266b
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 77 10 00 00       	call   8011f1 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 81 26 80 00       	push   $0x802681
  80018c:	6a 37                	push   $0x37
  80018e:	68 8e 26 80 00       	push   $0x80268e
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 9a 26 80 00       	push   $0x80269a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 8e 26 80 00       	push   $0x80268e
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 87 10 00 00       	call   801241 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 b4 26 80 00       	push   $0x8026b4
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 8e 26 80 00       	push   $0x80268e
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 bc 26 80 00       	push   $0x8026bc
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 d0 26 80 00       	push   $0x8026d0
  8001ea:	68 cf 26 80 00       	push   $0x8026cf
  8001ef:	e8 54 1c 00 00       	call   801e48 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 d3 26 80 00       	push   $0x8026d3
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 00 20 00 00       	call   802217 <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 53 27 80 00       	push   $0x802753
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 24 08 00 00       	call   800a5d <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 78 09 00 00       	call   800bef <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 23 0b 00 00       	call   800da4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	74 2a                	je     8002d0 <devcons_read+0x3b>
  8002a6:	eb 05                	jmp    8002ad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 94 0b 00 00       	call   800e41 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 10 0b 00 00       	call   800dc2 <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 bb 0a 00 00       	call   800da4 <sys_cputs>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 2c 10 00 00       	call   80132d <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 9c 0d 00 00       	call   8010c7 <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 24 0d 00 00       	call   801078 <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 f1 0a 00 00       	call   800e60 <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 bb 0c 00 00       	call   801051 <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8003aa:	e8 73 0a 00 00       	call   800e22 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bc:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	e8 88 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d6:	e8 0a 00 00 00       	call   8003e5 <exit>
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003eb:	e8 2c 0e 00 00       	call   80121c <close_all>
	sys_env_destroy(0);
  8003f0:	83 ec 0c             	sub    $0xc,%esp
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 e7 09 00 00       	call   800de1 <sys_env_destroy>
}
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800407:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80040d:	e8 10 0a 00 00       	call   800e22 <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 6c 27 80 00       	push   $0x80276c
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 68 2c 80 00 	movl   $0x802c68,(%esp)
  80043a:	e8 99 00 00 00       	call   8004d8 <cprintf>
  80043f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800442:	cc                   	int3   
  800443:	eb fd                	jmp    800442 <_panic+0x43>

00800445 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	53                   	push   %ebx
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044f:	8b 13                	mov    (%ebx),%edx
  800451:	8d 42 01             	lea    0x1(%edx),%eax
  800454:	89 03                	mov    %eax,(%ebx)
  800456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800459:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800462:	75 1a                	jne    80047e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	68 ff 00 00 00       	push   $0xff
  80046c:	8d 43 08             	lea    0x8(%ebx),%eax
  80046f:	50                   	push   %eax
  800470:	e8 2f 09 00 00       	call   800da4 <sys_cputs>
		b->idx = 0;
  800475:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80047b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80047e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	ff 75 08             	pushl  0x8(%ebp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	68 45 04 80 00       	push   $0x800445
  8004b6:	e8 54 01 00 00       	call   80060f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 d4 08 00 00       	call   800da4 <sys_cputs>

	return b.cnt;
}
  8004d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e1:	50                   	push   %eax
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 9d ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 1c             	sub    $0x1c,%esp
  8004f5:	89 c7                	mov    %eax,%edi
  8004f7:	89 d6                	mov    %edx,%esi
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800502:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800505:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800508:	bb 00 00 00 00       	mov    $0x0,%ebx
  80050d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800510:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800513:	39 d3                	cmp    %edx,%ebx
  800515:	72 05                	jb     80051c <printnum+0x30>
  800517:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051a:	77 45                	ja     800561 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	ff 75 18             	pushl  0x18(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800528:	53                   	push   %ebx
  800529:	ff 75 10             	pushl  0x10(%ebp)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800532:	ff 75 e0             	pushl  -0x20(%ebp)
  800535:	ff 75 dc             	pushl  -0x24(%ebp)
  800538:	ff 75 d8             	pushl  -0x28(%ebp)
  80053b:	e8 50 1e 00 00       	call   802390 <__udivdi3>
  800540:	83 c4 18             	add    $0x18,%esp
  800543:	52                   	push   %edx
  800544:	50                   	push   %eax
  800545:	89 f2                	mov    %esi,%edx
  800547:	89 f8                	mov    %edi,%eax
  800549:	e8 9e ff ff ff       	call   8004ec <printnum>
  80054e:	83 c4 20             	add    $0x20,%esp
  800551:	eb 18                	jmp    80056b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	ff 75 18             	pushl  0x18(%ebp)
  80055a:	ff d7                	call   *%edi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 03                	jmp    800564 <printnum+0x78>
  800561:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	85 db                	test   %ebx,%ebx
  800569:	7f e8                	jg     800553 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	56                   	push   %esi
  80056f:	83 ec 04             	sub    $0x4,%esp
  800572:	ff 75 e4             	pushl  -0x1c(%ebp)
  800575:	ff 75 e0             	pushl  -0x20(%ebp)
  800578:	ff 75 dc             	pushl  -0x24(%ebp)
  80057b:	ff 75 d8             	pushl  -0x28(%ebp)
  80057e:	e8 3d 1f 00 00       	call   8024c0 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 8f 27 80 00 	movsbl 0x80278f(%eax),%eax
  80058d:	50                   	push   %eax
  80058e:	ff d7                	call   *%edi
}
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5f                   	pop    %edi
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80059e:	83 fa 01             	cmp    $0x1,%edx
  8005a1:	7e 0e                	jle    8005b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a8:	89 08                	mov    %ecx,(%eax)
  8005aa:	8b 02                	mov    (%edx),%eax
  8005ac:	8b 52 04             	mov    0x4(%edx),%edx
  8005af:	eb 22                	jmp    8005d3 <getuint+0x38>
	else if (lflag)
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 10                	je     8005c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ba:	89 08                	mov    %ecx,(%eax)
  8005bc:	8b 02                	mov    (%edx),%eax
  8005be:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c3:	eb 0e                	jmp    8005d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ca:	89 08                	mov    %ecx,(%eax)
  8005cc:	8b 02                	mov    (%edx),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    

008005d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e4:	73 0a                	jae    8005f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e9:	89 08                	mov    %ecx,(%eax)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	88 02                	mov    %al,(%edx)
}
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 10             	pushl  0x10(%ebp)
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	ff 75 08             	pushl  0x8(%ebp)
  800605:	e8 05 00 00 00       	call   80060f <vprintfmt>
	va_end(ap);
}
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	57                   	push   %edi
  800613:	56                   	push   %esi
  800614:	53                   	push   %ebx
  800615:	83 ec 2c             	sub    $0x2c,%esp
  800618:	8b 75 08             	mov    0x8(%ebp),%esi
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800621:	eb 12                	jmp    800635 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800623:	85 c0                	test   %eax,%eax
  800625:	0f 84 89 03 00 00    	je     8009b4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	ff d6                	call   *%esi
  800632:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800635:	83 c7 01             	add    $0x1,%edi
  800638:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063c:	83 f8 25             	cmp    $0x25,%eax
  80063f:	75 e2                	jne    800623 <vprintfmt+0x14>
  800641:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800645:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80064c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800653:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80065a:	ba 00 00 00 00       	mov    $0x0,%edx
  80065f:	eb 07                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800664:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8d 47 01             	lea    0x1(%edi),%eax
  80066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066e:	0f b6 07             	movzbl (%edi),%eax
  800671:	0f b6 c8             	movzbl %al,%ecx
  800674:	83 e8 23             	sub    $0x23,%eax
  800677:	3c 55                	cmp    $0x55,%al
  800679:	0f 87 1a 03 00 00    	ja     800999 <vprintfmt+0x38a>
  80067f:	0f b6 c0             	movzbl %al,%eax
  800682:	ff 24 85 e0 28 80 00 	jmp    *0x8028e0(,%eax,4)
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80068c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800690:	eb d6                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800695:	b8 00 00 00 00       	mov    $0x0,%eax
  80069a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80069d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8006a0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8006a4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8006a7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8006aa:	83 fa 09             	cmp    $0x9,%edx
  8006ad:	77 39                	ja     8006e8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006b2:	eb e9                	jmp    80069d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006c5:	eb 27                	jmp    8006ee <vprintfmt+0xdf>
  8006c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d1:	0f 49 c8             	cmovns %eax,%ecx
  8006d4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	eb 8c                	jmp    800668 <vprintfmt+0x59>
  8006dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006e6:	eb 80                	jmp    800668 <vprintfmt+0x59>
  8006e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006eb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f2:	0f 89 70 ff ff ff    	jns    800668 <vprintfmt+0x59>
				width = precision, precision = -1;
  8006f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800705:	e9 5e ff ff ff       	jmp    800668 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80070a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800710:	e9 53 ff ff ff       	jmp    800668 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8d 50 04             	lea    0x4(%eax),%edx
  80071b:	89 55 14             	mov    %edx,0x14(%ebp)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	ff 30                	pushl  (%eax)
  800724:	ff d6                	call   *%esi
			break;
  800726:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80072c:	e9 04 ff ff ff       	jmp    800635 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 04             	lea    0x4(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	99                   	cltd   
  80073d:	31 d0                	xor    %edx,%eax
  80073f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800741:	83 f8 0f             	cmp    $0xf,%eax
  800744:	7f 0b                	jg     800751 <vprintfmt+0x142>
  800746:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  80074d:	85 d2                	test   %edx,%edx
  80074f:	75 18                	jne    800769 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800751:	50                   	push   %eax
  800752:	68 a7 27 80 00       	push   $0x8027a7
  800757:	53                   	push   %ebx
  800758:	56                   	push   %esi
  800759:	e8 94 fe ff ff       	call   8005f2 <printfmt>
  80075e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800764:	e9 cc fe ff ff       	jmp    800635 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800769:	52                   	push   %edx
  80076a:	68 71 2b 80 00       	push   $0x802b71
  80076f:	53                   	push   %ebx
  800770:	56                   	push   %esi
  800771:	e8 7c fe ff ff       	call   8005f2 <printfmt>
  800776:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800779:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077c:	e9 b4 fe ff ff       	jmp    800635 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8d 50 04             	lea    0x4(%eax),%edx
  800787:	89 55 14             	mov    %edx,0x14(%ebp)
  80078a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80078c:	85 ff                	test   %edi,%edi
  80078e:	b8 a0 27 80 00       	mov    $0x8027a0,%eax
  800793:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800796:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80079a:	0f 8e 94 00 00 00    	jle    800834 <vprintfmt+0x225>
  8007a0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007a4:	0f 84 98 00 00 00    	je     800842 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	ff 75 d0             	pushl  -0x30(%ebp)
  8007b0:	57                   	push   %edi
  8007b1:	e8 86 02 00 00       	call   800a3c <strnlen>
  8007b6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007b9:	29 c1                	sub    %eax,%ecx
  8007bb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007be:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007c1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007c8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007cb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cd:	eb 0f                	jmp    8007de <vprintfmt+0x1cf>
					putch(padc, putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d8:	83 ef 01             	sub    $0x1,%edi
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	85 ff                	test   %edi,%edi
  8007e0:	7f ed                	jg     8007cf <vprintfmt+0x1c0>
  8007e2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007e5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007e8:	85 c9                	test   %ecx,%ecx
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	0f 49 c1             	cmovns %ecx,%eax
  8007f2:	29 c1                	sub    %eax,%ecx
  8007f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8007f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007fd:	89 cb                	mov    %ecx,%ebx
  8007ff:	eb 4d                	jmp    80084e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800801:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800805:	74 1b                	je     800822 <vprintfmt+0x213>
  800807:	0f be c0             	movsbl %al,%eax
  80080a:	83 e8 20             	sub    $0x20,%eax
  80080d:	83 f8 5e             	cmp    $0x5e,%eax
  800810:	76 10                	jbe    800822 <vprintfmt+0x213>
					putch('?', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	ff 75 0c             	pushl  0xc(%ebp)
  800818:	6a 3f                	push   $0x3f
  80081a:	ff 55 08             	call   *0x8(%ebp)
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	eb 0d                	jmp    80082f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	52                   	push   %edx
  800829:	ff 55 08             	call   *0x8(%ebp)
  80082c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80082f:	83 eb 01             	sub    $0x1,%ebx
  800832:	eb 1a                	jmp    80084e <vprintfmt+0x23f>
  800834:	89 75 08             	mov    %esi,0x8(%ebp)
  800837:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80083a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80083d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800840:	eb 0c                	jmp    80084e <vprintfmt+0x23f>
  800842:	89 75 08             	mov    %esi,0x8(%ebp)
  800845:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800848:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80084b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80084e:	83 c7 01             	add    $0x1,%edi
  800851:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800855:	0f be d0             	movsbl %al,%edx
  800858:	85 d2                	test   %edx,%edx
  80085a:	74 23                	je     80087f <vprintfmt+0x270>
  80085c:	85 f6                	test   %esi,%esi
  80085e:	78 a1                	js     800801 <vprintfmt+0x1f2>
  800860:	83 ee 01             	sub    $0x1,%esi
  800863:	79 9c                	jns    800801 <vprintfmt+0x1f2>
  800865:	89 df                	mov    %ebx,%edi
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086d:	eb 18                	jmp    800887 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	53                   	push   %ebx
  800873:	6a 20                	push   $0x20
  800875:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800877:	83 ef 01             	sub    $0x1,%edi
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	eb 08                	jmp    800887 <vprintfmt+0x278>
  80087f:	89 df                	mov    %ebx,%edi
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800887:	85 ff                	test   %edi,%edi
  800889:	7f e4                	jg     80086f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088e:	e9 a2 fd ff ff       	jmp    800635 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800893:	83 fa 01             	cmp    $0x1,%edx
  800896:	7e 16                	jle    8008ae <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 50 08             	lea    0x8(%eax),%edx
  80089e:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a1:	8b 50 04             	mov    0x4(%eax),%edx
  8008a4:	8b 00                	mov    (%eax),%eax
  8008a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008ac:	eb 32                	jmp    8008e0 <vprintfmt+0x2d1>
	else if (lflag)
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	74 18                	je     8008ca <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 50 04             	lea    0x4(%eax),%edx
  8008b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c0:	89 c1                	mov    %eax,%ecx
  8008c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8008c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008c8:	eb 16                	jmp    8008e0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 50 04             	lea    0x4(%eax),%edx
  8008d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d3:	8b 00                	mov    (%eax),%eax
  8008d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d8:	89 c1                	mov    %eax,%ecx
  8008da:	c1 f9 1f             	sar    $0x1f,%ecx
  8008dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008ef:	79 74                	jns    800965 <vprintfmt+0x356>
				putch('-', putdat);
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	53                   	push   %ebx
  8008f5:	6a 2d                	push   $0x2d
  8008f7:	ff d6                	call   *%esi
				num = -(long long) num;
  8008f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008ff:	f7 d8                	neg    %eax
  800901:	83 d2 00             	adc    $0x0,%edx
  800904:	f7 da                	neg    %edx
  800906:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800909:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80090e:	eb 55                	jmp    800965 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800910:	8d 45 14             	lea    0x14(%ebp),%eax
  800913:	e8 83 fc ff ff       	call   80059b <getuint>
			base = 10;
  800918:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80091d:	eb 46                	jmp    800965 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80091f:	8d 45 14             	lea    0x14(%ebp),%eax
  800922:	e8 74 fc ff ff       	call   80059b <getuint>
			base = 8;
  800927:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80092c:	eb 37                	jmp    800965 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  80092e:	83 ec 08             	sub    $0x8,%esp
  800931:	53                   	push   %ebx
  800932:	6a 30                	push   $0x30
  800934:	ff d6                	call   *%esi
			putch('x', putdat);
  800936:	83 c4 08             	add    $0x8,%esp
  800939:	53                   	push   %ebx
  80093a:	6a 78                	push   $0x78
  80093c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 50 04             	lea    0x4(%eax),%edx
  800944:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800947:	8b 00                	mov    (%eax),%eax
  800949:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80094e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800951:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800956:	eb 0d                	jmp    800965 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800958:	8d 45 14             	lea    0x14(%ebp),%eax
  80095b:	e8 3b fc ff ff       	call   80059b <getuint>
			base = 16;
  800960:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800965:	83 ec 0c             	sub    $0xc,%esp
  800968:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80096c:	57                   	push   %edi
  80096d:	ff 75 e0             	pushl  -0x20(%ebp)
  800970:	51                   	push   %ecx
  800971:	52                   	push   %edx
  800972:	50                   	push   %eax
  800973:	89 da                	mov    %ebx,%edx
  800975:	89 f0                	mov    %esi,%eax
  800977:	e8 70 fb ff ff       	call   8004ec <printnum>
			break;
  80097c:	83 c4 20             	add    $0x20,%esp
  80097f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800982:	e9 ae fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800987:	83 ec 08             	sub    $0x8,%esp
  80098a:	53                   	push   %ebx
  80098b:	51                   	push   %ecx
  80098c:	ff d6                	call   *%esi
			break;
  80098e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800991:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800994:	e9 9c fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800999:	83 ec 08             	sub    $0x8,%esp
  80099c:	53                   	push   %ebx
  80099d:	6a 25                	push   $0x25
  80099f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a1:	83 c4 10             	add    $0x10,%esp
  8009a4:	eb 03                	jmp    8009a9 <vprintfmt+0x39a>
  8009a6:	83 ef 01             	sub    $0x1,%edi
  8009a9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009ad:	75 f7                	jne    8009a6 <vprintfmt+0x397>
  8009af:	e9 81 fc ff ff       	jmp    800635 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 18             	sub    $0x18,%esp
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d9:	85 c0                	test   %eax,%eax
  8009db:	74 26                	je     800a03 <vsnprintf+0x47>
  8009dd:	85 d2                	test   %edx,%edx
  8009df:	7e 22                	jle    800a03 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009e1:	ff 75 14             	pushl  0x14(%ebp)
  8009e4:	ff 75 10             	pushl  0x10(%ebp)
  8009e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ea:	50                   	push   %eax
  8009eb:	68 d5 05 80 00       	push   $0x8005d5
  8009f0:	e8 1a fc ff ff       	call   80060f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fe:	83 c4 10             	add    $0x10,%esp
  800a01:	eb 05                	jmp    800a08 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a10:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a13:	50                   	push   %eax
  800a14:	ff 75 10             	pushl  0x10(%ebp)
  800a17:	ff 75 0c             	pushl  0xc(%ebp)
  800a1a:	ff 75 08             	pushl  0x8(%ebp)
  800a1d:	e8 9a ff ff ff       	call   8009bc <vsnprintf>
	va_end(ap);

	return rc;
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2f:	eb 03                	jmp    800a34 <strlen+0x10>
		n++;
  800a31:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a34:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a38:	75 f7                	jne    800a31 <strlen+0xd>
		n++;
	return n;
}
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	eb 03                	jmp    800a4f <strnlen+0x13>
		n++;
  800a4c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	39 c2                	cmp    %eax,%edx
  800a51:	74 08                	je     800a5b <strnlen+0x1f>
  800a53:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a57:	75 f3                	jne    800a4c <strnlen+0x10>
  800a59:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	53                   	push   %ebx
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a67:	89 c2                	mov    %eax,%edx
  800a69:	83 c2 01             	add    $0x1,%edx
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a73:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a76:	84 db                	test   %bl,%bl
  800a78:	75 ef                	jne    800a69 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a84:	53                   	push   %ebx
  800a85:	e8 9a ff ff ff       	call   800a24 <strlen>
  800a8a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a8d:	ff 75 0c             	pushl  0xc(%ebp)
  800a90:	01 d8                	add    %ebx,%eax
  800a92:	50                   	push   %eax
  800a93:	e8 c5 ff ff ff       	call   800a5d <strcpy>
	return dst;
}
  800a98:	89 d8                	mov    %ebx,%eax
  800a9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aaf:	89 f2                	mov    %esi,%edx
  800ab1:	eb 0f                	jmp    800ac2 <strncpy+0x23>
		*dst++ = *src;
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	0f b6 01             	movzbl (%ecx),%eax
  800ab9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800abc:	80 39 01             	cmpb   $0x1,(%ecx)
  800abf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac2:	39 da                	cmp    %ebx,%edx
  800ac4:	75 ed                	jne    800ab3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ac6:	89 f0                	mov    %esi,%eax
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad7:	8b 55 10             	mov    0x10(%ebp),%edx
  800ada:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800adc:	85 d2                	test   %edx,%edx
  800ade:	74 21                	je     800b01 <strlcpy+0x35>
  800ae0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ae4:	89 f2                	mov    %esi,%edx
  800ae6:	eb 09                	jmp    800af1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ae8:	83 c2 01             	add    $0x1,%edx
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af1:	39 c2                	cmp    %eax,%edx
  800af3:	74 09                	je     800afe <strlcpy+0x32>
  800af5:	0f b6 19             	movzbl (%ecx),%ebx
  800af8:	84 db                	test   %bl,%bl
  800afa:	75 ec                	jne    800ae8 <strlcpy+0x1c>
  800afc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800afe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b01:	29 f0                	sub    %esi,%eax
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b10:	eb 06                	jmp    800b18 <strcmp+0x11>
		p++, q++;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b18:	0f b6 01             	movzbl (%ecx),%eax
  800b1b:	84 c0                	test   %al,%al
  800b1d:	74 04                	je     800b23 <strcmp+0x1c>
  800b1f:	3a 02                	cmp    (%edx),%al
  800b21:	74 ef                	je     800b12 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b23:	0f b6 c0             	movzbl %al,%eax
  800b26:	0f b6 12             	movzbl (%edx),%edx
  800b29:	29 d0                	sub    %edx,%eax
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	53                   	push   %ebx
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b37:	89 c3                	mov    %eax,%ebx
  800b39:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b3c:	eb 06                	jmp    800b44 <strncmp+0x17>
		n--, p++, q++;
  800b3e:	83 c0 01             	add    $0x1,%eax
  800b41:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b44:	39 d8                	cmp    %ebx,%eax
  800b46:	74 15                	je     800b5d <strncmp+0x30>
  800b48:	0f b6 08             	movzbl (%eax),%ecx
  800b4b:	84 c9                	test   %cl,%cl
  800b4d:	74 04                	je     800b53 <strncmp+0x26>
  800b4f:	3a 0a                	cmp    (%edx),%cl
  800b51:	74 eb                	je     800b3e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b53:	0f b6 00             	movzbl (%eax),%eax
  800b56:	0f b6 12             	movzbl (%edx),%edx
  800b59:	29 d0                	sub    %edx,%eax
  800b5b:	eb 05                	jmp    800b62 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b62:	5b                   	pop    %ebx
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b6f:	eb 07                	jmp    800b78 <strchr+0x13>
		if (*s == c)
  800b71:	38 ca                	cmp    %cl,%dl
  800b73:	74 0f                	je     800b84 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b75:	83 c0 01             	add    $0x1,%eax
  800b78:	0f b6 10             	movzbl (%eax),%edx
  800b7b:	84 d2                	test   %dl,%dl
  800b7d:	75 f2                	jne    800b71 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b90:	eb 03                	jmp    800b95 <strfind+0xf>
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b98:	38 ca                	cmp    %cl,%dl
  800b9a:	74 04                	je     800ba0 <strfind+0x1a>
  800b9c:	84 d2                	test   %dl,%dl
  800b9e:	75 f2                	jne    800b92 <strfind+0xc>
			break;
	return (char *) s;
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bae:	85 c9                	test   %ecx,%ecx
  800bb0:	74 36                	je     800be8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb8:	75 28                	jne    800be2 <memset+0x40>
  800bba:	f6 c1 03             	test   $0x3,%cl
  800bbd:	75 23                	jne    800be2 <memset+0x40>
		c &= 0xFF;
  800bbf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc3:	89 d3                	mov    %edx,%ebx
  800bc5:	c1 e3 08             	shl    $0x8,%ebx
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	c1 e6 18             	shl    $0x18,%esi
  800bcd:	89 d0                	mov    %edx,%eax
  800bcf:	c1 e0 10             	shl    $0x10,%eax
  800bd2:	09 f0                	or     %esi,%eax
  800bd4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bd6:	89 d8                	mov    %ebx,%eax
  800bd8:	09 d0                	or     %edx,%eax
  800bda:	c1 e9 02             	shr    $0x2,%ecx
  800bdd:	fc                   	cld    
  800bde:	f3 ab                	rep stos %eax,%es:(%edi)
  800be0:	eb 06                	jmp    800be8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be5:	fc                   	cld    
  800be6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800be8:	89 f8                	mov    %edi,%eax
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bfd:	39 c6                	cmp    %eax,%esi
  800bff:	73 35                	jae    800c36 <memmove+0x47>
  800c01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c04:	39 d0                	cmp    %edx,%eax
  800c06:	73 2e                	jae    800c36 <memmove+0x47>
		s += n;
		d += n;
  800c08:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	09 fe                	or     %edi,%esi
  800c0f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c15:	75 13                	jne    800c2a <memmove+0x3b>
  800c17:	f6 c1 03             	test   $0x3,%cl
  800c1a:	75 0e                	jne    800c2a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c1c:	83 ef 04             	sub    $0x4,%edi
  800c1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c22:	c1 e9 02             	shr    $0x2,%ecx
  800c25:	fd                   	std    
  800c26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c28:	eb 09                	jmp    800c33 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c2a:	83 ef 01             	sub    $0x1,%edi
  800c2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c30:	fd                   	std    
  800c31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c33:	fc                   	cld    
  800c34:	eb 1d                	jmp    800c53 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c36:	89 f2                	mov    %esi,%edx
  800c38:	09 c2                	or     %eax,%edx
  800c3a:	f6 c2 03             	test   $0x3,%dl
  800c3d:	75 0f                	jne    800c4e <memmove+0x5f>
  800c3f:	f6 c1 03             	test   $0x3,%cl
  800c42:	75 0a                	jne    800c4e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c44:	c1 e9 02             	shr    $0x2,%ecx
  800c47:	89 c7                	mov    %eax,%edi
  800c49:	fc                   	cld    
  800c4a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4c:	eb 05                	jmp    800c53 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c4e:	89 c7                	mov    %eax,%edi
  800c50:	fc                   	cld    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c5a:	ff 75 10             	pushl  0x10(%ebp)
  800c5d:	ff 75 0c             	pushl  0xc(%ebp)
  800c60:	ff 75 08             	pushl  0x8(%ebp)
  800c63:	e8 87 ff ff ff       	call   800bef <memmove>
}
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c75:	89 c6                	mov    %eax,%esi
  800c77:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7a:	eb 1a                	jmp    800c96 <memcmp+0x2c>
		if (*s1 != *s2)
  800c7c:	0f b6 08             	movzbl (%eax),%ecx
  800c7f:	0f b6 1a             	movzbl (%edx),%ebx
  800c82:	38 d9                	cmp    %bl,%cl
  800c84:	74 0a                	je     800c90 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c86:	0f b6 c1             	movzbl %cl,%eax
  800c89:	0f b6 db             	movzbl %bl,%ebx
  800c8c:	29 d8                	sub    %ebx,%eax
  800c8e:	eb 0f                	jmp    800c9f <memcmp+0x35>
		s1++, s2++;
  800c90:	83 c0 01             	add    $0x1,%eax
  800c93:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c96:	39 f0                	cmp    %esi,%eax
  800c98:	75 e2                	jne    800c7c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	53                   	push   %ebx
  800ca7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800caa:	89 c1                	mov    %eax,%ecx
  800cac:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800caf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb3:	eb 0a                	jmp    800cbf <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb5:	0f b6 10             	movzbl (%eax),%edx
  800cb8:	39 da                	cmp    %ebx,%edx
  800cba:	74 07                	je     800cc3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cbc:	83 c0 01             	add    $0x1,%eax
  800cbf:	39 c8                	cmp    %ecx,%eax
  800cc1:	72 f2                	jb     800cb5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cc3:	5b                   	pop    %ebx
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd2:	eb 03                	jmp    800cd7 <strtol+0x11>
		s++;
  800cd4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd7:	0f b6 01             	movzbl (%ecx),%eax
  800cda:	3c 20                	cmp    $0x20,%al
  800cdc:	74 f6                	je     800cd4 <strtol+0xe>
  800cde:	3c 09                	cmp    $0x9,%al
  800ce0:	74 f2                	je     800cd4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce2:	3c 2b                	cmp    $0x2b,%al
  800ce4:	75 0a                	jne    800cf0 <strtol+0x2a>
		s++;
  800ce6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cee:	eb 11                	jmp    800d01 <strtol+0x3b>
  800cf0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cf5:	3c 2d                	cmp    $0x2d,%al
  800cf7:	75 08                	jne    800d01 <strtol+0x3b>
		s++, neg = 1;
  800cf9:	83 c1 01             	add    $0x1,%ecx
  800cfc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d01:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d07:	75 15                	jne    800d1e <strtol+0x58>
  800d09:	80 39 30             	cmpb   $0x30,(%ecx)
  800d0c:	75 10                	jne    800d1e <strtol+0x58>
  800d0e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d12:	75 7c                	jne    800d90 <strtol+0xca>
		s += 2, base = 16;
  800d14:	83 c1 02             	add    $0x2,%ecx
  800d17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d1c:	eb 16                	jmp    800d34 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d1e:	85 db                	test   %ebx,%ebx
  800d20:	75 12                	jne    800d34 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d22:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d27:	80 39 30             	cmpb   $0x30,(%ecx)
  800d2a:	75 08                	jne    800d34 <strtol+0x6e>
		s++, base = 8;
  800d2c:	83 c1 01             	add    $0x1,%ecx
  800d2f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d34:	b8 00 00 00 00       	mov    $0x0,%eax
  800d39:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d3c:	0f b6 11             	movzbl (%ecx),%edx
  800d3f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d42:	89 f3                	mov    %esi,%ebx
  800d44:	80 fb 09             	cmp    $0x9,%bl
  800d47:	77 08                	ja     800d51 <strtol+0x8b>
			dig = *s - '0';
  800d49:	0f be d2             	movsbl %dl,%edx
  800d4c:	83 ea 30             	sub    $0x30,%edx
  800d4f:	eb 22                	jmp    800d73 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d51:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d54:	89 f3                	mov    %esi,%ebx
  800d56:	80 fb 19             	cmp    $0x19,%bl
  800d59:	77 08                	ja     800d63 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d5b:	0f be d2             	movsbl %dl,%edx
  800d5e:	83 ea 57             	sub    $0x57,%edx
  800d61:	eb 10                	jmp    800d73 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d63:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d66:	89 f3                	mov    %esi,%ebx
  800d68:	80 fb 19             	cmp    $0x19,%bl
  800d6b:	77 16                	ja     800d83 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d6d:	0f be d2             	movsbl %dl,%edx
  800d70:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d73:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d76:	7d 0b                	jge    800d83 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d78:	83 c1 01             	add    $0x1,%ecx
  800d7b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d7f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d81:	eb b9                	jmp    800d3c <strtol+0x76>

	if (endptr)
  800d83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d87:	74 0d                	je     800d96 <strtol+0xd0>
		*endptr = (char *) s;
  800d89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8c:	89 0e                	mov    %ecx,(%esi)
  800d8e:	eb 06                	jmp    800d96 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d90:	85 db                	test   %ebx,%ebx
  800d92:	74 98                	je     800d2c <strtol+0x66>
  800d94:	eb 9e                	jmp    800d34 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d96:	89 c2                	mov    %eax,%edx
  800d98:	f7 da                	neg    %edx
  800d9a:	85 ff                	test   %edi,%edi
  800d9c:	0f 45 c2             	cmovne %edx,%eax
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	b8 00 00 00 00       	mov    $0x0,%eax
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	89 c3                	mov    %eax,%ebx
  800db7:	89 c7                	mov    %eax,%edi
  800db9:	89 c6                	mov    %eax,%esi
  800dbb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcd:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd2:	89 d1                	mov    %edx,%ecx
  800dd4:	89 d3                	mov    %edx,%ebx
  800dd6:	89 d7                	mov    %edx,%edi
  800dd8:	89 d6                	mov    %edx,%esi
  800dda:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800def:	b8 03 00 00 00       	mov    $0x3,%eax
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 cb                	mov    %ecx,%ebx
  800df9:	89 cf                	mov    %ecx,%edi
  800dfb:	89 ce                	mov    %ecx,%esi
  800dfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 17                	jle    800e1a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	6a 03                	push   $0x3
  800e09:	68 9f 2a 80 00       	push   $0x802a9f
  800e0e:	6a 23                	push   $0x23
  800e10:	68 bc 2a 80 00       	push   $0x802abc
  800e15:	e8 e5 f5 ff ff       	call   8003ff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e32:	89 d1                	mov    %edx,%ecx
  800e34:	89 d3                	mov    %edx,%ebx
  800e36:	89 d7                	mov    %edx,%edi
  800e38:	89 d6                	mov    %edx,%esi
  800e3a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_yield>:

void
sys_yield(void)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e47:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e51:	89 d1                	mov    %edx,%ecx
  800e53:	89 d3                	mov    %edx,%ebx
  800e55:	89 d7                	mov    %edx,%edi
  800e57:	89 d6                	mov    %edx,%esi
  800e59:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	be 00 00 00 00       	mov    $0x0,%esi
  800e6e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7c:	89 f7                	mov    %esi,%edi
  800e7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 17                	jle    800e9b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	50                   	push   %eax
  800e88:	6a 04                	push   $0x4
  800e8a:	68 9f 2a 80 00       	push   $0x802a9f
  800e8f:	6a 23                	push   $0x23
  800e91:	68 bc 2a 80 00       	push   $0x802abc
  800e96:	e8 64 f5 ff ff       	call   8003ff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ebd:	8b 75 18             	mov    0x18(%ebp),%esi
  800ec0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 17                	jle    800edd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	83 ec 0c             	sub    $0xc,%esp
  800ec9:	50                   	push   %eax
  800eca:	6a 05                	push   $0x5
  800ecc:	68 9f 2a 80 00       	push   $0x802a9f
  800ed1:	6a 23                	push   $0x23
  800ed3:	68 bc 2a 80 00       	push   $0x802abc
  800ed8:	e8 22 f5 ff ff       	call   8003ff <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800edd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	89 df                	mov    %ebx,%edi
  800f00:	89 de                	mov    %ebx,%esi
  800f02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7e 17                	jle    800f1f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	50                   	push   %eax
  800f0c:	6a 06                	push   $0x6
  800f0e:	68 9f 2a 80 00       	push   $0x802a9f
  800f13:	6a 23                	push   $0x23
  800f15:	68 bc 2a 80 00       	push   $0x802abc
  800f1a:	e8 e0 f4 ff ff       	call   8003ff <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f35:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f40:	89 df                	mov    %ebx,%edi
  800f42:	89 de                	mov    %ebx,%esi
  800f44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f46:	85 c0                	test   %eax,%eax
  800f48:	7e 17                	jle    800f61 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	50                   	push   %eax
  800f4e:	6a 08                	push   $0x8
  800f50:	68 9f 2a 80 00       	push   $0x802a9f
  800f55:	6a 23                	push   $0x23
  800f57:	68 bc 2a 80 00       	push   $0x802abc
  800f5c:	e8 9e f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f77:	b8 09 00 00 00       	mov    $0x9,%eax
  800f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f82:	89 df                	mov    %ebx,%edi
  800f84:	89 de                	mov    %ebx,%esi
  800f86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	7e 17                	jle    800fa3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	50                   	push   %eax
  800f90:	6a 09                	push   $0x9
  800f92:	68 9f 2a 80 00       	push   $0x802a9f
  800f97:	6a 23                	push   $0x23
  800f99:	68 bc 2a 80 00       	push   $0x802abc
  800f9e:	e8 5c f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	57                   	push   %edi
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
  800fb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc4:	89 df                	mov    %ebx,%edi
  800fc6:	89 de                	mov    %ebx,%esi
  800fc8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	7e 17                	jle    800fe5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	50                   	push   %eax
  800fd2:	6a 0a                	push   $0xa
  800fd4:	68 9f 2a 80 00       	push   $0x802a9f
  800fd9:	6a 23                	push   $0x23
  800fdb:	68 bc 2a 80 00       	push   $0x802abc
  800fe0:	e8 1a f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fe5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    

00800fed <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	57                   	push   %edi
  800ff1:	56                   	push   %esi
  800ff2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff3:	be 00 00 00 00       	mov    $0x0,%esi
  800ff8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ffd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801006:	8b 7d 14             	mov    0x14(%ebp),%edi
  801009:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801019:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	89 cb                	mov    %ecx,%ebx
  801028:	89 cf                	mov    %ecx,%edi
  80102a:	89 ce                	mov    %ecx,%esi
  80102c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102e:	85 c0                	test   %eax,%eax
  801030:	7e 17                	jle    801049 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	50                   	push   %eax
  801036:	6a 0d                	push   $0xd
  801038:	68 9f 2a 80 00       	push   $0x802a9f
  80103d:	6a 23                	push   $0x23
  80103f:	68 bc 2a 80 00       	push   $0x802abc
  801044:	e8 b6 f3 ff ff       	call   8003ff <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801054:	8b 45 08             	mov    0x8(%ebp),%eax
  801057:	05 00 00 00 30       	add    $0x30000000,%eax
  80105c:	c1 e8 0c             	shr    $0xc,%eax
}
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801064:	8b 45 08             	mov    0x8(%ebp),%eax
  801067:	05 00 00 00 30       	add    $0x30000000,%eax
  80106c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801071:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801083:	89 c2                	mov    %eax,%edx
  801085:	c1 ea 16             	shr    $0x16,%edx
  801088:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108f:	f6 c2 01             	test   $0x1,%dl
  801092:	74 11                	je     8010a5 <fd_alloc+0x2d>
  801094:	89 c2                	mov    %eax,%edx
  801096:	c1 ea 0c             	shr    $0xc,%edx
  801099:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010a0:	f6 c2 01             	test   $0x1,%dl
  8010a3:	75 09                	jne    8010ae <fd_alloc+0x36>
			*fd_store = fd;
  8010a5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ac:	eb 17                	jmp    8010c5 <fd_alloc+0x4d>
  8010ae:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010b3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010b8:	75 c9                	jne    801083 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010ba:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010c0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010c5:	5d                   	pop    %ebp
  8010c6:	c3                   	ret    

008010c7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010cd:	83 f8 1f             	cmp    $0x1f,%eax
  8010d0:	77 36                	ja     801108 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d2:	c1 e0 0c             	shl    $0xc,%eax
  8010d5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010da:	89 c2                	mov    %eax,%edx
  8010dc:	c1 ea 16             	shr    $0x16,%edx
  8010df:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e6:	f6 c2 01             	test   $0x1,%dl
  8010e9:	74 24                	je     80110f <fd_lookup+0x48>
  8010eb:	89 c2                	mov    %eax,%edx
  8010ed:	c1 ea 0c             	shr    $0xc,%edx
  8010f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f7:	f6 c2 01             	test   $0x1,%dl
  8010fa:	74 1a                	je     801116 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ff:	89 02                	mov    %eax,(%edx)
	return 0;
  801101:	b8 00 00 00 00       	mov    $0x0,%eax
  801106:	eb 13                	jmp    80111b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801108:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110d:	eb 0c                	jmp    80111b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80110f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801114:	eb 05                	jmp    80111b <fd_lookup+0x54>
  801116:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	83 ec 08             	sub    $0x8,%esp
  801123:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801126:	ba 48 2b 80 00       	mov    $0x802b48,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80112b:	eb 13                	jmp    801140 <dev_lookup+0x23>
  80112d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801130:	39 08                	cmp    %ecx,(%eax)
  801132:	75 0c                	jne    801140 <dev_lookup+0x23>
			*dev = devtab[i];
  801134:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801137:	89 01                	mov    %eax,(%ecx)
			return 0;
  801139:	b8 00 00 00 00       	mov    $0x0,%eax
  80113e:	eb 2e                	jmp    80116e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801140:	8b 02                	mov    (%edx),%eax
  801142:	85 c0                	test   %eax,%eax
  801144:	75 e7                	jne    80112d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801146:	a1 90 67 80 00       	mov    0x806790,%eax
  80114b:	8b 40 48             	mov    0x48(%eax),%eax
  80114e:	83 ec 04             	sub    $0x4,%esp
  801151:	51                   	push   %ecx
  801152:	50                   	push   %eax
  801153:	68 cc 2a 80 00       	push   $0x802acc
  801158:	e8 7b f3 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  80115d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801160:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80116e:	c9                   	leave  
  80116f:	c3                   	ret    

00801170 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	56                   	push   %esi
  801174:	53                   	push   %ebx
  801175:	83 ec 10             	sub    $0x10,%esp
  801178:	8b 75 08             	mov    0x8(%ebp),%esi
  80117b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80117e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801188:	c1 e8 0c             	shr    $0xc,%eax
  80118b:	50                   	push   %eax
  80118c:	e8 36 ff ff ff       	call   8010c7 <fd_lookup>
  801191:	83 c4 08             	add    $0x8,%esp
  801194:	85 c0                	test   %eax,%eax
  801196:	78 05                	js     80119d <fd_close+0x2d>
	    || fd != fd2)
  801198:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80119b:	74 0c                	je     8011a9 <fd_close+0x39>
		return (must_exist ? r : 0);
  80119d:	84 db                	test   %bl,%bl
  80119f:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a4:	0f 44 c2             	cmove  %edx,%eax
  8011a7:	eb 41                	jmp    8011ea <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011a9:	83 ec 08             	sub    $0x8,%esp
  8011ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011af:	50                   	push   %eax
  8011b0:	ff 36                	pushl  (%esi)
  8011b2:	e8 66 ff ff ff       	call   80111d <dev_lookup>
  8011b7:	89 c3                	mov    %eax,%ebx
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 1a                	js     8011da <fd_close+0x6a>
		if (dev->dev_close)
  8011c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011c6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	74 0b                	je     8011da <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011cf:	83 ec 0c             	sub    $0xc,%esp
  8011d2:	56                   	push   %esi
  8011d3:	ff d0                	call   *%eax
  8011d5:	89 c3                	mov    %eax,%ebx
  8011d7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011da:	83 ec 08             	sub    $0x8,%esp
  8011dd:	56                   	push   %esi
  8011de:	6a 00                	push   $0x0
  8011e0:	e8 00 fd ff ff       	call   800ee5 <sys_page_unmap>
	return r;
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	89 d8                	mov    %ebx,%eax
}
  8011ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fa:	50                   	push   %eax
  8011fb:	ff 75 08             	pushl  0x8(%ebp)
  8011fe:	e8 c4 fe ff ff       	call   8010c7 <fd_lookup>
  801203:	83 c4 08             	add    $0x8,%esp
  801206:	85 c0                	test   %eax,%eax
  801208:	78 10                	js     80121a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	6a 01                	push   $0x1
  80120f:	ff 75 f4             	pushl  -0xc(%ebp)
  801212:	e8 59 ff ff ff       	call   801170 <fd_close>
  801217:	83 c4 10             	add    $0x10,%esp
}
  80121a:	c9                   	leave  
  80121b:	c3                   	ret    

0080121c <close_all>:

void
close_all(void)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	53                   	push   %ebx
  801220:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801223:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801228:	83 ec 0c             	sub    $0xc,%esp
  80122b:	53                   	push   %ebx
  80122c:	e8 c0 ff ff ff       	call   8011f1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801231:	83 c3 01             	add    $0x1,%ebx
  801234:	83 c4 10             	add    $0x10,%esp
  801237:	83 fb 20             	cmp    $0x20,%ebx
  80123a:	75 ec                	jne    801228 <close_all+0xc>
		close(i);
}
  80123c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	57                   	push   %edi
  801245:	56                   	push   %esi
  801246:	53                   	push   %ebx
  801247:	83 ec 2c             	sub    $0x2c,%esp
  80124a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80124d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	ff 75 08             	pushl  0x8(%ebp)
  801254:	e8 6e fe ff ff       	call   8010c7 <fd_lookup>
  801259:	83 c4 08             	add    $0x8,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	0f 88 c1 00 00 00    	js     801325 <dup+0xe4>
		return r;
	close(newfdnum);
  801264:	83 ec 0c             	sub    $0xc,%esp
  801267:	56                   	push   %esi
  801268:	e8 84 ff ff ff       	call   8011f1 <close>

	newfd = INDEX2FD(newfdnum);
  80126d:	89 f3                	mov    %esi,%ebx
  80126f:	c1 e3 0c             	shl    $0xc,%ebx
  801272:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801278:	83 c4 04             	add    $0x4,%esp
  80127b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80127e:	e8 de fd ff ff       	call   801061 <fd2data>
  801283:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801285:	89 1c 24             	mov    %ebx,(%esp)
  801288:	e8 d4 fd ff ff       	call   801061 <fd2data>
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801293:	89 f8                	mov    %edi,%eax
  801295:	c1 e8 16             	shr    $0x16,%eax
  801298:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80129f:	a8 01                	test   $0x1,%al
  8012a1:	74 37                	je     8012da <dup+0x99>
  8012a3:	89 f8                	mov    %edi,%eax
  8012a5:	c1 e8 0c             	shr    $0xc,%eax
  8012a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012af:	f6 c2 01             	test   $0x1,%dl
  8012b2:	74 26                	je     8012da <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c3:	50                   	push   %eax
  8012c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012c7:	6a 00                	push   $0x0
  8012c9:	57                   	push   %edi
  8012ca:	6a 00                	push   $0x0
  8012cc:	e8 d2 fb ff ff       	call   800ea3 <sys_page_map>
  8012d1:	89 c7                	mov    %eax,%edi
  8012d3:	83 c4 20             	add    $0x20,%esp
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 2e                	js     801308 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012dd:	89 d0                	mov    %edx,%eax
  8012df:	c1 e8 0c             	shr    $0xc,%eax
  8012e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e9:	83 ec 0c             	sub    $0xc,%esp
  8012ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f1:	50                   	push   %eax
  8012f2:	53                   	push   %ebx
  8012f3:	6a 00                	push   $0x0
  8012f5:	52                   	push   %edx
  8012f6:	6a 00                	push   $0x0
  8012f8:	e8 a6 fb ff ff       	call   800ea3 <sys_page_map>
  8012fd:	89 c7                	mov    %eax,%edi
  8012ff:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801302:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801304:	85 ff                	test   %edi,%edi
  801306:	79 1d                	jns    801325 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	53                   	push   %ebx
  80130c:	6a 00                	push   $0x0
  80130e:	e8 d2 fb ff ff       	call   800ee5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801313:	83 c4 08             	add    $0x8,%esp
  801316:	ff 75 d4             	pushl  -0x2c(%ebp)
  801319:	6a 00                	push   $0x0
  80131b:	e8 c5 fb ff ff       	call   800ee5 <sys_page_unmap>
	return r;
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	89 f8                	mov    %edi,%eax
}
  801325:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5f                   	pop    %edi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	53                   	push   %ebx
  801331:	83 ec 14             	sub    $0x14,%esp
  801334:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801337:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133a:	50                   	push   %eax
  80133b:	53                   	push   %ebx
  80133c:	e8 86 fd ff ff       	call   8010c7 <fd_lookup>
  801341:	83 c4 08             	add    $0x8,%esp
  801344:	89 c2                	mov    %eax,%edx
  801346:	85 c0                	test   %eax,%eax
  801348:	78 6d                	js     8013b7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801350:	50                   	push   %eax
  801351:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801354:	ff 30                	pushl  (%eax)
  801356:	e8 c2 fd ff ff       	call   80111d <dev_lookup>
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 4c                	js     8013ae <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801362:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801365:	8b 42 08             	mov    0x8(%edx),%eax
  801368:	83 e0 03             	and    $0x3,%eax
  80136b:	83 f8 01             	cmp    $0x1,%eax
  80136e:	75 21                	jne    801391 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801370:	a1 90 67 80 00       	mov    0x806790,%eax
  801375:	8b 40 48             	mov    0x48(%eax),%eax
  801378:	83 ec 04             	sub    $0x4,%esp
  80137b:	53                   	push   %ebx
  80137c:	50                   	push   %eax
  80137d:	68 0d 2b 80 00       	push   $0x802b0d
  801382:	e8 51 f1 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80138f:	eb 26                	jmp    8013b7 <read+0x8a>
	}
	if (!dev->dev_read)
  801391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801394:	8b 40 08             	mov    0x8(%eax),%eax
  801397:	85 c0                	test   %eax,%eax
  801399:	74 17                	je     8013b2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80139b:	83 ec 04             	sub    $0x4,%esp
  80139e:	ff 75 10             	pushl  0x10(%ebp)
  8013a1:	ff 75 0c             	pushl  0xc(%ebp)
  8013a4:	52                   	push   %edx
  8013a5:	ff d0                	call   *%eax
  8013a7:	89 c2                	mov    %eax,%edx
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	eb 09                	jmp    8013b7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	eb 05                	jmp    8013b7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013b7:	89 d0                	mov    %edx,%eax
  8013b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	57                   	push   %edi
  8013c2:	56                   	push   %esi
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 0c             	sub    $0xc,%esp
  8013c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d2:	eb 21                	jmp    8013f5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013d4:	83 ec 04             	sub    $0x4,%esp
  8013d7:	89 f0                	mov    %esi,%eax
  8013d9:	29 d8                	sub    %ebx,%eax
  8013db:	50                   	push   %eax
  8013dc:	89 d8                	mov    %ebx,%eax
  8013de:	03 45 0c             	add    0xc(%ebp),%eax
  8013e1:	50                   	push   %eax
  8013e2:	57                   	push   %edi
  8013e3:	e8 45 ff ff ff       	call   80132d <read>
		if (m < 0)
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	78 10                	js     8013ff <readn+0x41>
			return m;
		if (m == 0)
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	74 0a                	je     8013fd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f3:	01 c3                	add    %eax,%ebx
  8013f5:	39 f3                	cmp    %esi,%ebx
  8013f7:	72 db                	jb     8013d4 <readn+0x16>
  8013f9:	89 d8                	mov    %ebx,%eax
  8013fb:	eb 02                	jmp    8013ff <readn+0x41>
  8013fd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801402:	5b                   	pop    %ebx
  801403:	5e                   	pop    %esi
  801404:	5f                   	pop    %edi
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	53                   	push   %ebx
  80140b:	83 ec 14             	sub    $0x14,%esp
  80140e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801411:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	53                   	push   %ebx
  801416:	e8 ac fc ff ff       	call   8010c7 <fd_lookup>
  80141b:	83 c4 08             	add    $0x8,%esp
  80141e:	89 c2                	mov    %eax,%edx
  801420:	85 c0                	test   %eax,%eax
  801422:	78 68                	js     80148c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142a:	50                   	push   %eax
  80142b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142e:	ff 30                	pushl  (%eax)
  801430:	e8 e8 fc ff ff       	call   80111d <dev_lookup>
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 47                	js     801483 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80143c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801443:	75 21                	jne    801466 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801445:	a1 90 67 80 00       	mov    0x806790,%eax
  80144a:	8b 40 48             	mov    0x48(%eax),%eax
  80144d:	83 ec 04             	sub    $0x4,%esp
  801450:	53                   	push   %ebx
  801451:	50                   	push   %eax
  801452:	68 29 2b 80 00       	push   $0x802b29
  801457:	e8 7c f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801464:	eb 26                	jmp    80148c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801466:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801469:	8b 52 0c             	mov    0xc(%edx),%edx
  80146c:	85 d2                	test   %edx,%edx
  80146e:	74 17                	je     801487 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801470:	83 ec 04             	sub    $0x4,%esp
  801473:	ff 75 10             	pushl  0x10(%ebp)
  801476:	ff 75 0c             	pushl  0xc(%ebp)
  801479:	50                   	push   %eax
  80147a:	ff d2                	call   *%edx
  80147c:	89 c2                	mov    %eax,%edx
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	eb 09                	jmp    80148c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801483:	89 c2                	mov    %eax,%edx
  801485:	eb 05                	jmp    80148c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801487:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80148c:	89 d0                	mov    %edx,%eax
  80148e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <seek>:

int
seek(int fdnum, off_t offset)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801499:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	ff 75 08             	pushl  0x8(%ebp)
  8014a0:	e8 22 fc ff ff       	call   8010c7 <fd_lookup>
  8014a5:	83 c4 08             	add    $0x8,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 0e                	js     8014ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 14             	sub    $0x14,%esp
  8014c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	53                   	push   %ebx
  8014cb:	e8 f7 fb ff ff       	call   8010c7 <fd_lookup>
  8014d0:	83 c4 08             	add    $0x8,%esp
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 65                	js     80153e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e3:	ff 30                	pushl  (%eax)
  8014e5:	e8 33 fc ff ff       	call   80111d <dev_lookup>
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 44                	js     801535 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f8:	75 21                	jne    80151b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014fa:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014ff:	8b 40 48             	mov    0x48(%eax),%eax
  801502:	83 ec 04             	sub    $0x4,%esp
  801505:	53                   	push   %ebx
  801506:	50                   	push   %eax
  801507:	68 ec 2a 80 00       	push   $0x802aec
  80150c:	e8 c7 ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801519:	eb 23                	jmp    80153e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80151b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151e:	8b 52 18             	mov    0x18(%edx),%edx
  801521:	85 d2                	test   %edx,%edx
  801523:	74 14                	je     801539 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801525:	83 ec 08             	sub    $0x8,%esp
  801528:	ff 75 0c             	pushl  0xc(%ebp)
  80152b:	50                   	push   %eax
  80152c:	ff d2                	call   *%edx
  80152e:	89 c2                	mov    %eax,%edx
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	eb 09                	jmp    80153e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801535:	89 c2                	mov    %eax,%edx
  801537:	eb 05                	jmp    80153e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801539:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80153e:	89 d0                	mov    %edx,%eax
  801540:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801543:	c9                   	leave  
  801544:	c3                   	ret    

00801545 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	53                   	push   %ebx
  801549:	83 ec 14             	sub    $0x14,%esp
  80154c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	ff 75 08             	pushl  0x8(%ebp)
  801556:	e8 6c fb ff ff       	call   8010c7 <fd_lookup>
  80155b:	83 c4 08             	add    $0x8,%esp
  80155e:	89 c2                	mov    %eax,%edx
  801560:	85 c0                	test   %eax,%eax
  801562:	78 58                	js     8015bc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156a:	50                   	push   %eax
  80156b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156e:	ff 30                	pushl  (%eax)
  801570:	e8 a8 fb ff ff       	call   80111d <dev_lookup>
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 37                	js     8015b3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80157c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801583:	74 32                	je     8015b7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801585:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801588:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80158f:	00 00 00 
	stat->st_isdir = 0;
  801592:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801599:	00 00 00 
	stat->st_dev = dev;
  80159c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015a2:	83 ec 08             	sub    $0x8,%esp
  8015a5:	53                   	push   %ebx
  8015a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8015a9:	ff 50 14             	call   *0x14(%eax)
  8015ac:	89 c2                	mov    %eax,%edx
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	eb 09                	jmp    8015bc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b3:	89 c2                	mov    %eax,%edx
  8015b5:	eb 05                	jmp    8015bc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015bc:	89 d0                	mov    %edx,%eax
  8015be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015c8:	83 ec 08             	sub    $0x8,%esp
  8015cb:	6a 00                	push   $0x0
  8015cd:	ff 75 08             	pushl  0x8(%ebp)
  8015d0:	e8 2c 02 00 00       	call   801801 <open>
  8015d5:	89 c3                	mov    %eax,%ebx
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 1b                	js     8015f9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	ff 75 0c             	pushl  0xc(%ebp)
  8015e4:	50                   	push   %eax
  8015e5:	e8 5b ff ff ff       	call   801545 <fstat>
  8015ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ec:	89 1c 24             	mov    %ebx,(%esp)
  8015ef:	e8 fd fb ff ff       	call   8011f1 <close>
	return r;
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	89 f0                	mov    %esi,%eax
}
  8015f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5e                   	pop    %esi
  8015fe:	5d                   	pop    %ebp
  8015ff:	c3                   	ret    

00801600 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	89 c6                	mov    %eax,%esi
  801607:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  801609:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801610:	75 12                	jne    801624 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  801612:	83 ec 0c             	sub    $0xc,%esp
  801615:	6a 01                	push   $0x1
  801617:	e8 fd 0c 00 00       	call   802319 <ipc_find_env>
  80161c:	a3 00 50 80 00       	mov    %eax,0x805000
  801621:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801624:	6a 07                	push   $0x7
  801626:	68 00 70 80 00       	push   $0x807000
  80162b:	56                   	push   %esi
  80162c:	ff 35 00 50 80 00    	pushl  0x805000
  801632:	e8 8e 0c 00 00       	call   8022c5 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  801637:	83 c4 0c             	add    $0xc,%esp
  80163a:	6a 00                	push   $0x0
  80163c:	53                   	push   %ebx
  80163d:	6a 00                	push   $0x0
  80163f:	e8 22 0c 00 00       	call   802266 <ipc_recv>
}
  801644:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801651:	8b 45 08             	mov    0x8(%ebp),%eax
  801654:	8b 40 0c             	mov    0xc(%eax),%eax
  801657:	a3 00 70 80 00       	mov    %eax,0x807000
	   fsipcbuf.set_size.req_size = newsize;
  80165c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165f:	a3 04 70 80 00       	mov    %eax,0x807004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  801664:	ba 00 00 00 00       	mov    $0x0,%edx
  801669:	b8 02 00 00 00       	mov    $0x2,%eax
  80166e:	e8 8d ff ff ff       	call   801600 <fsipc>
}
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80167b:	8b 45 08             	mov    0x8(%ebp),%eax
  80167e:	8b 40 0c             	mov    0xc(%eax),%eax
  801681:	a3 00 70 80 00       	mov    %eax,0x807000
	   return fsipc(FSREQ_FLUSH, NULL);
  801686:	ba 00 00 00 00       	mov    $0x0,%edx
  80168b:	b8 06 00 00 00       	mov    $0x6,%eax
  801690:	e8 6b ff ff ff       	call   801600 <fsipc>
}
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	83 ec 04             	sub    $0x4,%esp
  80169e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a7:	a3 00 70 80 00       	mov    %eax,0x807000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b6:	e8 45 ff ff ff       	call   801600 <fsipc>
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 2c                	js     8016eb <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016bf:	83 ec 08             	sub    $0x8,%esp
  8016c2:	68 00 70 80 00       	push   $0x807000
  8016c7:	53                   	push   %ebx
  8016c8:	e8 90 f3 ff ff       	call   800a5d <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  8016cd:	a1 80 70 80 00       	mov    0x807080,%eax
  8016d2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016d8:	a1 84 70 80 00       	mov    0x807084,%eax
  8016dd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801700:	a3 00 70 80 00       	mov    %eax,0x807000
	   fsipcbuf.write.req_n = n;
  801705:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  80170b:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801711:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801716:	0f 46 c3             	cmovbe %ebx,%eax
  801719:	50                   	push   %eax
  80171a:	ff 75 0c             	pushl  0xc(%ebp)
  80171d:	68 08 70 80 00       	push   $0x807008
  801722:	e8 c8 f4 ff ff       	call   800bef <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  801727:	ba 00 00 00 00       	mov    $0x0,%edx
  80172c:	b8 04 00 00 00       	mov    $0x4,%eax
  801731:	e8 ca fe ff ff       	call   801600 <fsipc>
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 3d                	js     80177a <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  80173d:	39 c3                	cmp    %eax,%ebx
  80173f:	73 19                	jae    80175a <devfile_write+0x6a>
  801741:	68 58 2b 80 00       	push   $0x802b58
  801746:	68 5f 2b 80 00       	push   $0x802b5f
  80174b:	68 9a 00 00 00       	push   $0x9a
  801750:	68 74 2b 80 00       	push   $0x802b74
  801755:	e8 a5 ec ff ff       	call   8003ff <_panic>
	   assert (r <= bytes_written);
  80175a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80175f:	7e 19                	jle    80177a <devfile_write+0x8a>
  801761:	68 7f 2b 80 00       	push   $0x802b7f
  801766:	68 5f 2b 80 00       	push   $0x802b5f
  80176b:	68 9b 00 00 00       	push   $0x9b
  801770:	68 74 2b 80 00       	push   $0x802b74
  801775:	e8 85 ec ff ff       	call   8003ff <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  80177a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	56                   	push   %esi
  801783:	53                   	push   %ebx
  801784:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  801787:	8b 45 08             	mov    0x8(%ebp),%eax
  80178a:	8b 40 0c             	mov    0xc(%eax),%eax
  80178d:	a3 00 70 80 00       	mov    %eax,0x807000
	   fsipcbuf.read.req_n = n;
  801792:	89 35 04 70 80 00    	mov    %esi,0x807004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801798:	ba 00 00 00 00       	mov    $0x0,%edx
  80179d:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a2:	e8 59 fe ff ff       	call   801600 <fsipc>
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 4b                	js     8017f8 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  8017ad:	39 c6                	cmp    %eax,%esi
  8017af:	73 16                	jae    8017c7 <devfile_read+0x48>
  8017b1:	68 58 2b 80 00       	push   $0x802b58
  8017b6:	68 5f 2b 80 00       	push   $0x802b5f
  8017bb:	6a 7c                	push   $0x7c
  8017bd:	68 74 2b 80 00       	push   $0x802b74
  8017c2:	e8 38 ec ff ff       	call   8003ff <_panic>
	   assert(r <= PGSIZE);
  8017c7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017cc:	7e 16                	jle    8017e4 <devfile_read+0x65>
  8017ce:	68 92 2b 80 00       	push   $0x802b92
  8017d3:	68 5f 2b 80 00       	push   $0x802b5f
  8017d8:	6a 7d                	push   $0x7d
  8017da:	68 74 2b 80 00       	push   $0x802b74
  8017df:	e8 1b ec ff ff       	call   8003ff <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e4:	83 ec 04             	sub    $0x4,%esp
  8017e7:	50                   	push   %eax
  8017e8:	68 00 70 80 00       	push   $0x807000
  8017ed:	ff 75 0c             	pushl  0xc(%ebp)
  8017f0:	e8 fa f3 ff ff       	call   800bef <memmove>
	   return r;
  8017f5:	83 c4 10             	add    $0x10,%esp
}
  8017f8:	89 d8                	mov    %ebx,%eax
  8017fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fd:	5b                   	pop    %ebx
  8017fe:	5e                   	pop    %esi
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	53                   	push   %ebx
  801805:	83 ec 20             	sub    $0x20,%esp
  801808:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  80180b:	53                   	push   %ebx
  80180c:	e8 13 f2 ff ff       	call   800a24 <strlen>
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801819:	7f 67                	jg     801882 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  80181b:	83 ec 0c             	sub    $0xc,%esp
  80181e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801821:	50                   	push   %eax
  801822:	e8 51 f8 ff ff       	call   801078 <fd_alloc>
  801827:	83 c4 10             	add    $0x10,%esp
			 return r;
  80182a:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  80182c:	85 c0                	test   %eax,%eax
  80182e:	78 57                	js     801887 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	53                   	push   %ebx
  801834:	68 00 70 80 00       	push   $0x807000
  801839:	e8 1f f2 ff ff       	call   800a5d <strcpy>
	   fsipcbuf.open.req_omode = mode;
  80183e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801841:	a3 00 74 80 00       	mov    %eax,0x807400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801846:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801849:	b8 01 00 00 00       	mov    $0x1,%eax
  80184e:	e8 ad fd ff ff       	call   801600 <fsipc>
  801853:	89 c3                	mov    %eax,%ebx
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	79 14                	jns    801870 <open+0x6f>
			 fd_close(fd, 0);
  80185c:	83 ec 08             	sub    $0x8,%esp
  80185f:	6a 00                	push   $0x0
  801861:	ff 75 f4             	pushl  -0xc(%ebp)
  801864:	e8 07 f9 ff ff       	call   801170 <fd_close>
			 return r;
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	89 da                	mov    %ebx,%edx
  80186e:	eb 17                	jmp    801887 <open+0x86>
	   }

	   return fd2num(fd);
  801870:	83 ec 0c             	sub    $0xc,%esp
  801873:	ff 75 f4             	pushl  -0xc(%ebp)
  801876:	e8 d6 f7 ff ff       	call   801051 <fd2num>
  80187b:	89 c2                	mov    %eax,%edx
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	eb 05                	jmp    801887 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  801882:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801887:	89 d0                	mov    %edx,%eax
  801889:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801894:	ba 00 00 00 00       	mov    $0x0,%edx
  801899:	b8 08 00 00 00       	mov    $0x8,%eax
  80189e:	e8 5d fd ff ff       	call   801600 <fsipc>
}
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
	   int
spawn(const char *prog, const char **argv)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	57                   	push   %edi
  8018a9:	56                   	push   %esi
  8018aa:	53                   	push   %ebx
  8018ab:	81 ec 94 02 00 00    	sub    $0x294,%esp
	   //   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	   //     correct initial eip and esp values in the child.
	   //
	   //   - Start the child process running with sys_env_set_status().

	   if ((r = open(prog, O_RDONLY)) < 0)
  8018b1:	6a 00                	push   $0x0
  8018b3:	ff 75 08             	pushl  0x8(%ebp)
  8018b6:	e8 46 ff ff ff       	call   801801 <open>
  8018bb:	89 c1                	mov    %eax,%ecx
  8018bd:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	0f 88 de 04 00 00    	js     801dac <spawn+0x507>
			 return r;
	   fd = r;

	   // Read elf header
	   elf = (struct Elf*) elf_buf;
	   if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018ce:	83 ec 04             	sub    $0x4,%esp
  8018d1:	68 00 02 00 00       	push   $0x200
  8018d6:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018dc:	50                   	push   %eax
  8018dd:	51                   	push   %ecx
  8018de:	e8 db fa ff ff       	call   8013be <readn>
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018eb:	75 0c                	jne    8018f9 <spawn+0x54>
				    || elf->e_magic != ELF_MAGIC) {
  8018ed:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018f4:	45 4c 46 
  8018f7:	74 33                	je     80192c <spawn+0x87>
			 close(fd);
  8018f9:	83 ec 0c             	sub    $0xc,%esp
  8018fc:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801902:	e8 ea f8 ff ff       	call   8011f1 <close>
			 cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801907:	83 c4 0c             	add    $0xc,%esp
  80190a:	68 7f 45 4c 46       	push   $0x464c457f
  80190f:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801915:	68 9e 2b 80 00       	push   $0x802b9e
  80191a:	e8 b9 eb ff ff       	call   8004d8 <cprintf>
			 return -E_NOT_EXEC;
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801927:	e9 12 05 00 00       	jmp    801e3e <spawn+0x599>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80192c:	b8 07 00 00 00       	mov    $0x7,%eax
  801931:	cd 30                	int    $0x30
  801933:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801939:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	   }

	   // Create new child environment
	   if ((r = sys_exofork()) < 0)
  80193f:	85 c0                	test   %eax,%eax
  801941:	0f 88 70 04 00 00    	js     801db7 <spawn+0x512>
			 return r;
	   child = r;

	   // Set up trap frame, including initial stack.
	   child_tf = envs[ENVX(child)].env_tf;
  801947:	89 c6                	mov    %eax,%esi
  801949:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80194f:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801952:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801958:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80195e:	b9 11 00 00 00       	mov    $0x11,%ecx
  801963:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	   child_tf.tf_eip = elf->e_entry;
  801965:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80196b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
	   for (argc = 0; argv[argc] != 0; argc++)
  801971:	bb 00 00 00 00       	mov    $0x0,%ebx
	   char *string_store;
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
  801976:	be 00 00 00 00       	mov    $0x0,%esi
  80197b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80197e:	eb 13                	jmp    801993 <spawn+0xee>
	   for (argc = 0; argv[argc] != 0; argc++)
			 string_size += strlen(argv[argc]) + 1;
  801980:	83 ec 0c             	sub    $0xc,%esp
  801983:	50                   	push   %eax
  801984:	e8 9b f0 ff ff       	call   800a24 <strlen>
  801989:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	   uintptr_t *argv_store;

	   // Count the number of arguments (argc)
	   // and the total amount of space needed for strings (string_size).
	   string_size = 0;
	   for (argc = 0; argv[argc] != 0; argc++)
  80198d:	83 c3 01             	add    $0x1,%ebx
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80199a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80199d:	85 c0                	test   %eax,%eax
  80199f:	75 df                	jne    801980 <spawn+0xdb>
  8019a1:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8019a7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	   // Determine where to place the strings and the argv array.
	   // Set up pointers into the temporary page 'UTEMP'; we'll map a page
	   // there later, then remap that page into the child environment
	   // at (USTACKTOP - PGSIZE).
	   // strings is the topmost thing on the stack.
	   string_store = (char*) UTEMP + PGSIZE - string_size;
  8019ad:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019b2:	29 f7                	sub    %esi,%edi
	   // argv is below that.  There's one argument pointer per argument, plus
	   // a null pointer.
	   argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019b4:	89 fa                	mov    %edi,%edx
  8019b6:	83 e2 fc             	and    $0xfffffffc,%edx
  8019b9:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019c0:	29 c2                	sub    %eax,%edx
  8019c2:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	   // Make sure that argv, strings, and the 2 words that hold 'argc'
	   // and 'argv' themselves will all fit in a single stack page.
	   if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019c8:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019cb:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019d0:	0f 86 f1 03 00 00    	jbe    801dc7 <spawn+0x522>
			 return -E_NO_MEM;

	   // Allocate the single stack page at UTEMP.
	   if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019d6:	83 ec 04             	sub    $0x4,%esp
  8019d9:	6a 07                	push   $0x7
  8019db:	68 00 00 40 00       	push   $0x400000
  8019e0:	6a 00                	push   $0x0
  8019e2:	e8 79 f4 ff ff       	call   800e60 <sys_page_alloc>
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	0f 88 dc 03 00 00    	js     801dce <spawn+0x529>
  8019f2:	be 00 00 00 00       	mov    $0x0,%esi
  8019f7:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8019fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a00:	eb 30                	jmp    801a32 <spawn+0x18d>
	   //	  environment.)
	   //
	   //	* Set *init_esp to the initial stack pointer for the child,
	   //	  (Again, use an address valid in the child's environment.)
	   for (i = 0; i < argc; i++) {
			 argv_store[i] = UTEMP2USTACK(string_store);
  801a02:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a08:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a0e:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
			 strcpy(string_store, argv[i]);
  801a11:	83 ec 08             	sub    $0x8,%esp
  801a14:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a17:	57                   	push   %edi
  801a18:	e8 40 f0 ff ff       	call   800a5d <strcpy>
			 string_store += strlen(argv[i]) + 1;
  801a1d:	83 c4 04             	add    $0x4,%esp
  801a20:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a23:	e8 fc ef ff ff       	call   800a24 <strlen>
  801a28:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	   //	  (Again, argv should use an address valid in the child's
	   //	  environment.)
	   //
	   //	* Set *init_esp to the initial stack pointer for the child,
	   //	  (Again, use an address valid in the child's environment.)
	   for (i = 0; i < argc; i++) {
  801a2c:	83 c6 01             	add    $0x1,%esi
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801a38:	7f c8                	jg     801a02 <spawn+0x15d>
			 argv_store[i] = UTEMP2USTACK(string_store);
			 strcpy(string_store, argv[i]);
			 string_store += strlen(argv[i]) + 1;
	   }
	   argv_store[argc] = 0;
  801a3a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a40:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801a46:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	   assert(string_store == (char*)UTEMP + PGSIZE);
  801a4d:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a53:	74 19                	je     801a6e <spawn+0x1c9>
  801a55:	68 28 2c 80 00       	push   $0x802c28
  801a5a:	68 5f 2b 80 00       	push   $0x802b5f
  801a5f:	68 f2 00 00 00       	push   $0xf2
  801a64:	68 b8 2b 80 00       	push   $0x802bb8
  801a69:	e8 91 e9 ff ff       	call   8003ff <_panic>

	   argv_store[-1] = UTEMP2USTACK(argv_store);
  801a6e:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a74:	89 c8                	mov    %ecx,%eax
  801a76:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a7b:	89 41 fc             	mov    %eax,-0x4(%ecx)
	   argv_store[-2] = argc;
  801a7e:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801a84:	89 41 f8             	mov    %eax,-0x8(%ecx)

	   *init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a87:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801a8d:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	   // After completing the stack, map it into the child's address space
	   // and unmap it from ours!
	   if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	6a 07                	push   $0x7
  801a98:	68 00 d0 bf ee       	push   $0xeebfd000
  801a9d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aa3:	68 00 00 40 00       	push   $0x400000
  801aa8:	6a 00                	push   $0x0
  801aaa:	e8 f4 f3 ff ff       	call   800ea3 <sys_page_map>
  801aaf:	89 c3                	mov    %eax,%ebx
  801ab1:	83 c4 20             	add    $0x20,%esp
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	0f 88 70 03 00 00    	js     801e2c <spawn+0x587>
			 goto error;
	   if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801abc:	83 ec 08             	sub    $0x8,%esp
  801abf:	68 00 00 40 00       	push   $0x400000
  801ac4:	6a 00                	push   $0x0
  801ac6:	e8 1a f4 ff ff       	call   800ee5 <sys_page_unmap>
  801acb:	89 c3                	mov    %eax,%ebx
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	0f 88 54 03 00 00    	js     801e2c <spawn+0x587>

	   if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
			 return r;

	   // Set up program segments as defined in ELF header.
	   ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ad8:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ade:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ae5:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	   for (i = 0; i < elf->e_phnum; i++, ph++) {
  801aeb:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801af2:	00 00 00 
  801af5:	e9 86 01 00 00       	jmp    801c80 <spawn+0x3db>
			 if (ph->p_type != ELF_PROG_LOAD)
  801afa:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b00:	83 38 01             	cmpl   $0x1,(%eax)
  801b03:	0f 85 69 01 00 00    	jne    801c72 <spawn+0x3cd>
				    continue;
			 perm = PTE_P | PTE_U;
			 if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b09:	89 c1                	mov    %eax,%ecx
  801b0b:	8b 40 18             	mov    0x18(%eax),%eax
  801b0e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b14:	83 e0 02             	and    $0x2,%eax
				    perm |= PTE_W;
  801b17:	83 f8 01             	cmp    $0x1,%eax
  801b1a:	19 c0                	sbb    %eax,%eax
  801b1c:	83 e0 fe             	and    $0xfffffffe,%eax
  801b1f:	83 c0 07             	add    $0x7,%eax
  801b22:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
			 if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b28:	89 c8                	mov    %ecx,%eax
  801b2a:	8b 49 04             	mov    0x4(%ecx),%ecx
  801b2d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801b33:	8b 78 10             	mov    0x10(%eax),%edi
  801b36:	8b 50 14             	mov    0x14(%eax),%edx
  801b39:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801b3f:	8b 70 08             	mov    0x8(%eax),%esi
	   int i, r;
	   void *blk;

	   //cprintf("map_segment %x+%x\n", va, memsz);

	   if ((i = PGOFF(va))) {
  801b42:	89 f0                	mov    %esi,%eax
  801b44:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b49:	74 14                	je     801b5f <spawn+0x2ba>
			 va -= i;
  801b4b:	29 c6                	sub    %eax,%esi
			 memsz += i;
  801b4d:	01 c2                	add    %eax,%edx
  801b4f:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
			 filesz += i;
  801b55:	01 c7                	add    %eax,%edi
			 fileoffset -= i;
  801b57:	29 c1                	sub    %eax,%ecx
  801b59:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	   }

	   for (i = 0; i < memsz; i += PGSIZE) {
  801b5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b64:	e9 f7 00 00 00       	jmp    801c60 <spawn+0x3bb>
			 if (i >= filesz) {
  801b69:	39 df                	cmp    %ebx,%edi
  801b6b:	77 27                	ja     801b94 <spawn+0x2ef>
				    // allocate a blank page
				    if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b6d:	83 ec 04             	sub    $0x4,%esp
  801b70:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b76:	56                   	push   %esi
  801b77:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801b7d:	e8 de f2 ff ff       	call   800e60 <sys_page_alloc>
  801b82:	83 c4 10             	add    $0x10,%esp
  801b85:	85 c0                	test   %eax,%eax
  801b87:	0f 89 c7 00 00 00    	jns    801c54 <spawn+0x3af>
  801b8d:	89 c3                	mov    %eax,%ebx
  801b8f:	e9 48 02 00 00       	jmp    801ddc <spawn+0x537>
						  return r;
			 } else {
				    // from file
				    if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b94:	83 ec 04             	sub    $0x4,%esp
  801b97:	6a 07                	push   $0x7
  801b99:	68 00 00 40 00       	push   $0x400000
  801b9e:	6a 00                	push   $0x0
  801ba0:	e8 bb f2 ff ff       	call   800e60 <sys_page_alloc>
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	0f 88 22 02 00 00    	js     801dd2 <spawn+0x52d>
						  return r;
				    if ((r = seek(fd, fileoffset + i)) < 0)
  801bb0:	83 ec 08             	sub    $0x8,%esp
  801bb3:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bb9:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bbf:	50                   	push   %eax
  801bc0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bc6:	e8 c8 f8 ff ff       	call   801493 <seek>
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	0f 88 00 02 00 00    	js     801dd6 <spawn+0x531>
						  return r;
				    if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bd6:	83 ec 04             	sub    $0x4,%esp
  801bd9:	89 f8                	mov    %edi,%eax
  801bdb:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801be1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801be6:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801beb:	0f 47 c1             	cmova  %ecx,%eax
  801bee:	50                   	push   %eax
  801bef:	68 00 00 40 00       	push   $0x400000
  801bf4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bfa:	e8 bf f7 ff ff       	call   8013be <readn>
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	85 c0                	test   %eax,%eax
  801c04:	0f 88 d0 01 00 00    	js     801dda <spawn+0x535>
						  return r;
				    if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c0a:	83 ec 0c             	sub    $0xc,%esp
  801c0d:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c13:	56                   	push   %esi
  801c14:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801c1a:	68 00 00 40 00       	push   $0x400000
  801c1f:	6a 00                	push   $0x0
  801c21:	e8 7d f2 ff ff       	call   800ea3 <sys_page_map>
  801c26:	83 c4 20             	add    $0x20,%esp
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	79 15                	jns    801c42 <spawn+0x39d>
						  panic("spawn: sys_page_map data: %e", r);
  801c2d:	50                   	push   %eax
  801c2e:	68 c4 2b 80 00       	push   $0x802bc4
  801c33:	68 25 01 00 00       	push   $0x125
  801c38:	68 b8 2b 80 00       	push   $0x802bb8
  801c3d:	e8 bd e7 ff ff       	call   8003ff <_panic>
				    sys_page_unmap(0, UTEMP);
  801c42:	83 ec 08             	sub    $0x8,%esp
  801c45:	68 00 00 40 00       	push   $0x400000
  801c4a:	6a 00                	push   $0x0
  801c4c:	e8 94 f2 ff ff       	call   800ee5 <sys_page_unmap>
  801c51:	83 c4 10             	add    $0x10,%esp
			 memsz += i;
			 filesz += i;
			 fileoffset -= i;
	   }

	   for (i = 0; i < memsz; i += PGSIZE) {
  801c54:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c5a:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c60:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c66:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801c6c:	0f 87 f7 fe ff ff    	ja     801b69 <spawn+0x2c4>
	   if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
			 return r;

	   // Set up program segments as defined in ELF header.
	   ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	   for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c72:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c79:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c80:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c87:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c8d:	0f 8c 67 fe ff ff    	jl     801afa <spawn+0x255>
				    perm |= PTE_W;
			 if ((r = map_segment(child, ph->p_va, ph->p_memsz,
									   fd, ph->p_filesz, ph->p_offset, perm)) < 0)
				    goto error;
	   }
	   close(fd);
  801c93:	83 ec 0c             	sub    $0xc,%esp
  801c96:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c9c:	e8 50 f5 ff ff       	call   8011f1 <close>
  801ca1:	83 c4 10             	add    $0x10,%esp
	   static int
copy_shared_pages(envid_t child)
{
	   // LAB 5: Your code here.
	   int r;
	   bool is_below_ulim = true;
  801ca4:	c6 85 94 fd ff ff 01 	movb   $0x1,-0x26c(%ebp)
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
  801cab:	c7 85 8c fd ff ff 00 	movl   $0x0,-0x274(%ebp)
  801cb2:	00 00 00 
	   {
			 if (!(uvpd[i] & PTE_P)) 
  801cb5:	8b bd 8c fd ff ff    	mov    -0x274(%ebp),%edi
  801cbb:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  801cc2:	a8 01                	test   $0x1,%al
  801cc4:	74 7b                	je     801d41 <spawn+0x49c>
  801cc6:	89 fb                	mov    %edi,%ebx
  801cc8:	c1 e3 0a             	shl    $0xa,%ebx
  801ccb:	c1 e7 16             	shl    $0x16,%edi
  801cce:	be 00 00 00 00       	mov    $0x0,%esi
  801cd3:	eb 5b                	jmp    801d30 <spawn+0x48b>
				    continue;
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) 
			 {
				    unsigned pn = i * NPTENTRIES + j;
				    pte_t pte = uvpt[pn];
  801cd5:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
				    if (pn >= (UTOP >> PGSHIFT)) 
  801cdc:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801ce2:	77 39                	ja     801d1d <spawn+0x478>
				    {
						  is_below_ulim = false;
				    } else if (pte & PTE_SHARE) 
  801ce4:	f6 c4 04             	test   $0x4,%ah
  801ce7:	74 3b                	je     801d24 <spawn+0x47f>
				    {
						  if ((r = sys_page_map(0, (void *)(pn * PGSIZE), child, (void *)(pn * PGSIZE), pte & PTE_SYSCALL)) < 0) {
  801ce9:	83 ec 0c             	sub    $0xc,%esp
  801cec:	25 07 0e 00 00       	and    $0xe07,%eax
  801cf1:	50                   	push   %eax
  801cf2:	57                   	push   %edi
  801cf3:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801cf9:	57                   	push   %edi
  801cfa:	6a 00                	push   $0x0
  801cfc:	e8 a2 f1 ff ff       	call   800ea3 <sys_page_map>
  801d01:	83 c4 20             	add    $0x20,%esp
  801d04:	85 c0                	test   %eax,%eax
  801d06:	79 1c                	jns    801d24 <spawn+0x47f>
	   close(fd);
	   fd = -1;

	   // Copy shared library state.
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);
  801d08:	50                   	push   %eax
  801d09:	68 12 2c 80 00       	push   $0x802c12
  801d0e:	68 82 00 00 00       	push   $0x82
  801d13:	68 b8 2b 80 00       	push   $0x802bb8
  801d18:	e8 e2 e6 ff ff       	call   8003ff <_panic>
			 {
				    unsigned pn = i * NPTENTRIES + j;
				    pte_t pte = uvpt[pn];
				    if (pn >= (UTOP >> PGSHIFT)) 
				    {
						  is_below_ulim = false;
  801d1d:	c6 85 94 fd ff ff 00 	movb   $0x0,-0x26c(%ebp)
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
	   {
			 if (!(uvpd[i] & PTE_P)) 
				    continue;
			 for (int j = 0; is_below_ulim && j < NPTENTRIES; j++) 
  801d24:	83 c6 01             	add    $0x1,%esi
  801d27:	83 c3 01             	add    $0x1,%ebx
  801d2a:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801d30:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
  801d36:	7f 09                	jg     801d41 <spawn+0x49c>
  801d38:	80 bd 94 fd ff ff 00 	cmpb   $0x0,-0x26c(%ebp)
  801d3f:	75 94                	jne    801cd5 <spawn+0x430>
copy_shared_pages(envid_t child)
{
	   // LAB 5: Your code here.
	   int r;
	   bool is_below_ulim = true;
	   for (int i = 0; is_below_ulim && i < NPDENTRIES ; i++) 
  801d41:	83 85 8c fd ff ff 01 	addl   $0x1,-0x274(%ebp)
  801d48:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801d4e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d53:	0f 8f a4 00 00 00    	jg     801dfd <spawn+0x558>
  801d59:	80 bd 94 fd ff ff 00 	cmpb   $0x0,-0x26c(%ebp)
  801d60:	0f 85 4f ff ff ff    	jne    801cb5 <spawn+0x410>
  801d66:	e9 92 00 00 00       	jmp    801dfd <spawn+0x558>
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);

	   child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	   if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
			 panic("sys_env_set_trapframe: %e", r);
  801d6b:	50                   	push   %eax
  801d6c:	68 e1 2b 80 00       	push   $0x802be1
  801d71:	68 86 00 00 00       	push   $0x86
  801d76:	68 b8 2b 80 00       	push   $0x802bb8
  801d7b:	e8 7f e6 ff ff       	call   8003ff <_panic>

	   if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d80:	83 ec 08             	sub    $0x8,%esp
  801d83:	6a 02                	push   $0x2
  801d85:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d8b:	e8 97 f1 ff ff       	call   800f27 <sys_env_set_status>
  801d90:	83 c4 10             	add    $0x10,%esp
  801d93:	85 c0                	test   %eax,%eax
  801d95:	79 28                	jns    801dbf <spawn+0x51a>
			 panic("sys_env_set_status: %e", r);
  801d97:	50                   	push   %eax
  801d98:	68 fb 2b 80 00       	push   $0x802bfb
  801d9d:	68 89 00 00 00       	push   $0x89
  801da2:	68 b8 2b 80 00       	push   $0x802bb8
  801da7:	e8 53 e6 ff ff       	call   8003ff <_panic>
	   //     correct initial eip and esp values in the child.
	   //
	   //   - Start the child process running with sys_env_set_status().

	   if ((r = open(prog, O_RDONLY)) < 0)
			 return r;
  801dac:	8b 9d 88 fd ff ff    	mov    -0x278(%ebp),%ebx
  801db2:	e9 87 00 00 00       	jmp    801e3e <spawn+0x599>
			 return -E_NOT_EXEC;
	   }

	   // Create new child environment
	   if ((r = sys_exofork()) < 0)
			 return r;
  801db7:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801dbd:	eb 7f                	jmp    801e3e <spawn+0x599>
			 panic("sys_env_set_trapframe: %e", r);

	   if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
			 panic("sys_env_set_status: %e", r);

	   return child;
  801dbf:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801dc5:	eb 77                	jmp    801e3e <spawn+0x599>
	   argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	   // Make sure that argv, strings, and the 2 words that hold 'argc'
	   // and 'argv' themselves will all fit in a single stack page.
	   if ((void*) (argv_store - 2) < (void*) UTEMP)
			 return -E_NO_MEM;
  801dc7:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801dcc:	eb 70                	jmp    801e3e <spawn+0x599>

	   // Allocate the single stack page at UTEMP.
	   if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
			 return r;
  801dce:	89 c3                	mov    %eax,%ebx
  801dd0:	eb 6c                	jmp    801e3e <spawn+0x599>
				    // allocate a blank page
				    if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
						  return r;
			 } else {
				    // from file
				    if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801dd2:	89 c3                	mov    %eax,%ebx
  801dd4:	eb 06                	jmp    801ddc <spawn+0x537>
						  return r;
				    if ((r = seek(fd, fileoffset + i)) < 0)
  801dd6:	89 c3                	mov    %eax,%ebx
  801dd8:	eb 02                	jmp    801ddc <spawn+0x537>
						  return r;
				    if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801dda:	89 c3                	mov    %eax,%ebx
			 panic("sys_env_set_status: %e", r);

	   return child;

error:
	   sys_env_destroy(child);
  801ddc:	83 ec 0c             	sub    $0xc,%esp
  801ddf:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801de5:	e8 f7 ef ff ff       	call   800de1 <sys_env_destroy>
	   close(fd);
  801dea:	83 c4 04             	add    $0x4,%esp
  801ded:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801df3:	e8 f9 f3 ff ff       	call   8011f1 <close>
	   return r;
  801df8:	83 c4 10             	add    $0x10,%esp
  801dfb:	eb 41                	jmp    801e3e <spawn+0x599>

	   // Copy shared library state.
	   if ((r = copy_shared_pages(child)) < 0)
			 panic("copy_shared_pages: %e", r);

	   child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801dfd:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e04:	30 00 00 
	   if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e10:	50                   	push   %eax
  801e11:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e17:	e8 4d f1 ff ff       	call   800f69 <sys_env_set_trapframe>
  801e1c:	83 c4 10             	add    $0x10,%esp
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	0f 89 59 ff ff ff    	jns    801d80 <spawn+0x4db>
  801e27:	e9 3f ff ff ff       	jmp    801d6b <spawn+0x4c6>
			 goto error;

	   return 0;

error:
	   sys_page_unmap(0, UTEMP);
  801e2c:	83 ec 08             	sub    $0x8,%esp
  801e2f:	68 00 00 40 00       	push   $0x400000
  801e34:	6a 00                	push   $0x0
  801e36:	e8 aa f0 ff ff       	call   800ee5 <sys_page_unmap>
  801e3b:	83 c4 10             	add    $0x10,%esp

error:
	   sys_env_destroy(child);
	   close(fd);
	   return r;
}
  801e3e:	89 d8                	mov    %ebx,%eax
  801e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e43:	5b                   	pop    %ebx
  801e44:	5e                   	pop    %esi
  801e45:	5f                   	pop    %edi
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    

00801e48 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
	   int
spawnl(const char *prog, const char *arg0, ...)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	56                   	push   %esi
  801e4c:	53                   	push   %ebx
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  801e4d:	8d 55 10             	lea    0x10(%ebp),%edx
{
	   // We calculate argc by advancing the args until we hit NULL.
	   // The contract of the function guarantees that the last
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
  801e50:	b8 00 00 00 00       	mov    $0x0,%eax
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  801e55:	eb 03                	jmp    801e5a <spawnl+0x12>
			 argc++;
  801e57:	83 c0 01             	add    $0x1,%eax
	   // argument will always be NULL, and that none of the other
	   // arguments will be NULL.
	   int argc=0;
	   va_list vl;
	   va_start(vl, arg0);
	   while(va_arg(vl, void *) != NULL)
  801e5a:	83 c2 04             	add    $0x4,%edx
  801e5d:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e61:	75 f4                	jne    801e57 <spawnl+0xf>
			 argc++;
	   va_end(vl);

	   // Now that we have the size of the args, do a second pass
	   // and store the values in a VLA, which has the format of argv
	   const char *argv[argc+2];
  801e63:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e6a:	83 e2 f0             	and    $0xfffffff0,%edx
  801e6d:	29 d4                	sub    %edx,%esp
  801e6f:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e73:	c1 ea 02             	shr    $0x2,%edx
  801e76:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e7d:	89 f3                	mov    %esi,%ebx
	   argv[0] = arg0;
  801e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e82:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	   argv[argc+1] = NULL;
  801e89:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e90:	00 
  801e91:	89 c2                	mov    %eax,%edx

	   va_start(vl, arg0);
	   unsigned i;
	   for(i=0;i<argc;i++)
  801e93:	b8 00 00 00 00       	mov    $0x0,%eax
  801e98:	eb 0a                	jmp    801ea4 <spawnl+0x5c>
			 argv[i+1] = va_arg(vl, const char *);
  801e9a:	83 c0 01             	add    $0x1,%eax
  801e9d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ea1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	   argv[0] = arg0;
	   argv[argc+1] = NULL;

	   va_start(vl, arg0);
	   unsigned i;
	   for(i=0;i<argc;i++)
  801ea4:	39 d0                	cmp    %edx,%eax
  801ea6:	75 f2                	jne    801e9a <spawnl+0x52>
			 argv[i+1] = va_arg(vl, const char *);
	   va_end(vl);
	   return spawn(prog, argv);
  801ea8:	83 ec 08             	sub    $0x8,%esp
  801eab:	56                   	push   %esi
  801eac:	ff 75 08             	pushl  0x8(%ebp)
  801eaf:	e8 f1 f9 ff ff       	call   8018a5 <spawn>
}
  801eb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    

00801ebb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	56                   	push   %esi
  801ebf:	53                   	push   %ebx
  801ec0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	ff 75 08             	pushl  0x8(%ebp)
  801ec9:	e8 93 f1 ff ff       	call   801061 <fd2data>
  801ece:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ed0:	83 c4 08             	add    $0x8,%esp
  801ed3:	68 50 2c 80 00       	push   $0x802c50
  801ed8:	53                   	push   %ebx
  801ed9:	e8 7f eb ff ff       	call   800a5d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ede:	8b 46 04             	mov    0x4(%esi),%eax
  801ee1:	2b 06                	sub    (%esi),%eax
  801ee3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ee9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ef0:	00 00 00 
	stat->st_dev = &devpipe;
  801ef3:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801efa:	47 80 00 
	return 0;
}
  801efd:	b8 00 00 00 00       	mov    $0x0,%eax
  801f02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f05:	5b                   	pop    %ebx
  801f06:	5e                   	pop    %esi
  801f07:	5d                   	pop    %ebp
  801f08:	c3                   	ret    

00801f09 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	53                   	push   %ebx
  801f0d:	83 ec 0c             	sub    $0xc,%esp
  801f10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f13:	53                   	push   %ebx
  801f14:	6a 00                	push   $0x0
  801f16:	e8 ca ef ff ff       	call   800ee5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f1b:	89 1c 24             	mov    %ebx,(%esp)
  801f1e:	e8 3e f1 ff ff       	call   801061 <fd2data>
  801f23:	83 c4 08             	add    $0x8,%esp
  801f26:	50                   	push   %eax
  801f27:	6a 00                	push   $0x0
  801f29:	e8 b7 ef ff ff       	call   800ee5 <sys_page_unmap>
}
  801f2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    

00801f33 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	57                   	push   %edi
  801f37:	56                   	push   %esi
  801f38:	53                   	push   %ebx
  801f39:	83 ec 1c             	sub    $0x1c,%esp
  801f3c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f3f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f41:	a1 90 67 80 00       	mov    0x806790,%eax
  801f46:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f49:	83 ec 0c             	sub    $0xc,%esp
  801f4c:	ff 75 e0             	pushl  -0x20(%ebp)
  801f4f:	e8 fe 03 00 00       	call   802352 <pageref>
  801f54:	89 c3                	mov    %eax,%ebx
  801f56:	89 3c 24             	mov    %edi,(%esp)
  801f59:	e8 f4 03 00 00       	call   802352 <pageref>
  801f5e:	83 c4 10             	add    $0x10,%esp
  801f61:	39 c3                	cmp    %eax,%ebx
  801f63:	0f 94 c1             	sete   %cl
  801f66:	0f b6 c9             	movzbl %cl,%ecx
  801f69:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f6c:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801f72:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f75:	39 ce                	cmp    %ecx,%esi
  801f77:	74 1b                	je     801f94 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f79:	39 c3                	cmp    %eax,%ebx
  801f7b:	75 c4                	jne    801f41 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f7d:	8b 42 58             	mov    0x58(%edx),%eax
  801f80:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f83:	50                   	push   %eax
  801f84:	56                   	push   %esi
  801f85:	68 57 2c 80 00       	push   $0x802c57
  801f8a:	e8 49 e5 ff ff       	call   8004d8 <cprintf>
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	eb ad                	jmp    801f41 <_pipeisclosed+0xe>
	}
}
  801f94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9a:	5b                   	pop    %ebx
  801f9b:	5e                   	pop    %esi
  801f9c:	5f                   	pop    %edi
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    

00801f9f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	57                   	push   %edi
  801fa3:	56                   	push   %esi
  801fa4:	53                   	push   %ebx
  801fa5:	83 ec 28             	sub    $0x28,%esp
  801fa8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fab:	56                   	push   %esi
  801fac:	e8 b0 f0 ff ff       	call   801061 <fd2data>
  801fb1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	bf 00 00 00 00       	mov    $0x0,%edi
  801fbb:	eb 4b                	jmp    802008 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fbd:	89 da                	mov    %ebx,%edx
  801fbf:	89 f0                	mov    %esi,%eax
  801fc1:	e8 6d ff ff ff       	call   801f33 <_pipeisclosed>
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	75 48                	jne    802012 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fca:	e8 72 ee ff ff       	call   800e41 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fcf:	8b 43 04             	mov    0x4(%ebx),%eax
  801fd2:	8b 0b                	mov    (%ebx),%ecx
  801fd4:	8d 51 20             	lea    0x20(%ecx),%edx
  801fd7:	39 d0                	cmp    %edx,%eax
  801fd9:	73 e2                	jae    801fbd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fde:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fe2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fe5:	89 c2                	mov    %eax,%edx
  801fe7:	c1 fa 1f             	sar    $0x1f,%edx
  801fea:	89 d1                	mov    %edx,%ecx
  801fec:	c1 e9 1b             	shr    $0x1b,%ecx
  801fef:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ff2:	83 e2 1f             	and    $0x1f,%edx
  801ff5:	29 ca                	sub    %ecx,%edx
  801ff7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ffb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fff:	83 c0 01             	add    $0x1,%eax
  802002:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802005:	83 c7 01             	add    $0x1,%edi
  802008:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80200b:	75 c2                	jne    801fcf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80200d:	8b 45 10             	mov    0x10(%ebp),%eax
  802010:	eb 05                	jmp    802017 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802012:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802017:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201a:	5b                   	pop    %ebx
  80201b:	5e                   	pop    %esi
  80201c:	5f                   	pop    %edi
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    

0080201f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	57                   	push   %edi
  802023:	56                   	push   %esi
  802024:	53                   	push   %ebx
  802025:	83 ec 18             	sub    $0x18,%esp
  802028:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80202b:	57                   	push   %edi
  80202c:	e8 30 f0 ff ff       	call   801061 <fd2data>
  802031:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	bb 00 00 00 00       	mov    $0x0,%ebx
  80203b:	eb 3d                	jmp    80207a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80203d:	85 db                	test   %ebx,%ebx
  80203f:	74 04                	je     802045 <devpipe_read+0x26>
				return i;
  802041:	89 d8                	mov    %ebx,%eax
  802043:	eb 44                	jmp    802089 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802045:	89 f2                	mov    %esi,%edx
  802047:	89 f8                	mov    %edi,%eax
  802049:	e8 e5 fe ff ff       	call   801f33 <_pipeisclosed>
  80204e:	85 c0                	test   %eax,%eax
  802050:	75 32                	jne    802084 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802052:	e8 ea ed ff ff       	call   800e41 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802057:	8b 06                	mov    (%esi),%eax
  802059:	3b 46 04             	cmp    0x4(%esi),%eax
  80205c:	74 df                	je     80203d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80205e:	99                   	cltd   
  80205f:	c1 ea 1b             	shr    $0x1b,%edx
  802062:	01 d0                	add    %edx,%eax
  802064:	83 e0 1f             	and    $0x1f,%eax
  802067:	29 d0                	sub    %edx,%eax
  802069:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80206e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802071:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802074:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802077:	83 c3 01             	add    $0x1,%ebx
  80207a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80207d:	75 d8                	jne    802057 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80207f:	8b 45 10             	mov    0x10(%ebp),%eax
  802082:	eb 05                	jmp    802089 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802084:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802089:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208c:	5b                   	pop    %ebx
  80208d:	5e                   	pop    %esi
  80208e:	5f                   	pop    %edi
  80208f:	5d                   	pop    %ebp
  802090:	c3                   	ret    

00802091 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802091:	55                   	push   %ebp
  802092:	89 e5                	mov    %esp,%ebp
  802094:	56                   	push   %esi
  802095:	53                   	push   %ebx
  802096:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802099:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209c:	50                   	push   %eax
  80209d:	e8 d6 ef ff ff       	call   801078 <fd_alloc>
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	89 c2                	mov    %eax,%edx
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	0f 88 2c 01 00 00    	js     8021db <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020af:	83 ec 04             	sub    $0x4,%esp
  8020b2:	68 07 04 00 00       	push   $0x407
  8020b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ba:	6a 00                	push   $0x0
  8020bc:	e8 9f ed ff ff       	call   800e60 <sys_page_alloc>
  8020c1:	83 c4 10             	add    $0x10,%esp
  8020c4:	89 c2                	mov    %eax,%edx
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	0f 88 0d 01 00 00    	js     8021db <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020ce:	83 ec 0c             	sub    $0xc,%esp
  8020d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020d4:	50                   	push   %eax
  8020d5:	e8 9e ef ff ff       	call   801078 <fd_alloc>
  8020da:	89 c3                	mov    %eax,%ebx
  8020dc:	83 c4 10             	add    $0x10,%esp
  8020df:	85 c0                	test   %eax,%eax
  8020e1:	0f 88 e2 00 00 00    	js     8021c9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e7:	83 ec 04             	sub    $0x4,%esp
  8020ea:	68 07 04 00 00       	push   $0x407
  8020ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f2:	6a 00                	push   $0x0
  8020f4:	e8 67 ed ff ff       	call   800e60 <sys_page_alloc>
  8020f9:	89 c3                	mov    %eax,%ebx
  8020fb:	83 c4 10             	add    $0x10,%esp
  8020fe:	85 c0                	test   %eax,%eax
  802100:	0f 88 c3 00 00 00    	js     8021c9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802106:	83 ec 0c             	sub    $0xc,%esp
  802109:	ff 75 f4             	pushl  -0xc(%ebp)
  80210c:	e8 50 ef ff ff       	call   801061 <fd2data>
  802111:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802113:	83 c4 0c             	add    $0xc,%esp
  802116:	68 07 04 00 00       	push   $0x407
  80211b:	50                   	push   %eax
  80211c:	6a 00                	push   $0x0
  80211e:	e8 3d ed ff ff       	call   800e60 <sys_page_alloc>
  802123:	89 c3                	mov    %eax,%ebx
  802125:	83 c4 10             	add    $0x10,%esp
  802128:	85 c0                	test   %eax,%eax
  80212a:	0f 88 89 00 00 00    	js     8021b9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802130:	83 ec 0c             	sub    $0xc,%esp
  802133:	ff 75 f0             	pushl  -0x10(%ebp)
  802136:	e8 26 ef ff ff       	call   801061 <fd2data>
  80213b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802142:	50                   	push   %eax
  802143:	6a 00                	push   $0x0
  802145:	56                   	push   %esi
  802146:	6a 00                	push   $0x0
  802148:	e8 56 ed ff ff       	call   800ea3 <sys_page_map>
  80214d:	89 c3                	mov    %eax,%ebx
  80214f:	83 c4 20             	add    $0x20,%esp
  802152:	85 c0                	test   %eax,%eax
  802154:	78 55                	js     8021ab <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802156:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  80215c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802161:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802164:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80216b:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802171:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802174:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802176:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802179:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802180:	83 ec 0c             	sub    $0xc,%esp
  802183:	ff 75 f4             	pushl  -0xc(%ebp)
  802186:	e8 c6 ee ff ff       	call   801051 <fd2num>
  80218b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80218e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802190:	83 c4 04             	add    $0x4,%esp
  802193:	ff 75 f0             	pushl  -0x10(%ebp)
  802196:	e8 b6 ee ff ff       	call   801051 <fd2num>
  80219b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80219e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021a1:	83 c4 10             	add    $0x10,%esp
  8021a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8021a9:	eb 30                	jmp    8021db <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021ab:	83 ec 08             	sub    $0x8,%esp
  8021ae:	56                   	push   %esi
  8021af:	6a 00                	push   $0x0
  8021b1:	e8 2f ed ff ff       	call   800ee5 <sys_page_unmap>
  8021b6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021b9:	83 ec 08             	sub    $0x8,%esp
  8021bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8021bf:	6a 00                	push   $0x0
  8021c1:	e8 1f ed ff ff       	call   800ee5 <sys_page_unmap>
  8021c6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021c9:	83 ec 08             	sub    $0x8,%esp
  8021cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8021cf:	6a 00                	push   $0x0
  8021d1:	e8 0f ed ff ff       	call   800ee5 <sys_page_unmap>
  8021d6:	83 c4 10             	add    $0x10,%esp
  8021d9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021db:	89 d0                	mov    %edx,%eax
  8021dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021e0:	5b                   	pop    %ebx
  8021e1:	5e                   	pop    %esi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    

008021e4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ed:	50                   	push   %eax
  8021ee:	ff 75 08             	pushl  0x8(%ebp)
  8021f1:	e8 d1 ee ff ff       	call   8010c7 <fd_lookup>
  8021f6:	83 c4 10             	add    $0x10,%esp
  8021f9:	85 c0                	test   %eax,%eax
  8021fb:	78 18                	js     802215 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021fd:	83 ec 0c             	sub    $0xc,%esp
  802200:	ff 75 f4             	pushl  -0xc(%ebp)
  802203:	e8 59 ee ff ff       	call   801061 <fd2data>
	return _pipeisclosed(fd, p);
  802208:	89 c2                	mov    %eax,%edx
  80220a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220d:	e8 21 fd ff ff       	call   801f33 <_pipeisclosed>
  802212:	83 c4 10             	add    $0x10,%esp
}
  802215:	c9                   	leave  
  802216:	c3                   	ret    

00802217 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	56                   	push   %esi
  80221b:	53                   	push   %ebx
  80221c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80221f:	85 f6                	test   %esi,%esi
  802221:	75 16                	jne    802239 <wait+0x22>
  802223:	68 6f 2c 80 00       	push   $0x802c6f
  802228:	68 5f 2b 80 00       	push   $0x802b5f
  80222d:	6a 09                	push   $0x9
  80222f:	68 7a 2c 80 00       	push   $0x802c7a
  802234:	e8 c6 e1 ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  802239:	89 f3                	mov    %esi,%ebx
  80223b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802241:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802244:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80224a:	eb 05                	jmp    802251 <wait+0x3a>
		sys_yield();
  80224c:	e8 f0 eb ff ff       	call   800e41 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802251:	8b 43 48             	mov    0x48(%ebx),%eax
  802254:	39 c6                	cmp    %eax,%esi
  802256:	75 07                	jne    80225f <wait+0x48>
  802258:	8b 43 54             	mov    0x54(%ebx),%eax
  80225b:	85 c0                	test   %eax,%eax
  80225d:	75 ed                	jne    80224c <wait+0x35>
		sys_yield();
}
  80225f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802262:	5b                   	pop    %ebx
  802263:	5e                   	pop    %esi
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    

00802266 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	56                   	push   %esi
  80226a:	53                   	push   %ebx
  80226b:	8b 75 08             	mov    0x8(%ebp),%esi
  80226e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802271:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  802274:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  802276:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80227b:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  80227e:	83 ec 0c             	sub    $0xc,%esp
  802281:	50                   	push   %eax
  802282:	e8 89 ed ff ff       	call   801010 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  802287:	83 c4 10             	add    $0x10,%esp
  80228a:	85 c0                	test   %eax,%eax
  80228c:	78 0e                	js     80229c <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  80228e:	8b 15 90 67 80 00    	mov    0x806790,%edx
  802294:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  802297:	8b 52 78             	mov    0x78(%edx),%edx
  80229a:	eb 0a                	jmp    8022a6 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  80229c:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  8022a1:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  8022a6:	85 f6                	test   %esi,%esi
  8022a8:	74 02                	je     8022ac <ipc_recv+0x46>
			 *from_env_store = s_envid;
  8022aa:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  8022ac:	85 db                	test   %ebx,%ebx
  8022ae:	74 02                	je     8022b2 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  8022b0:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  8022b2:	85 c0                	test   %eax,%eax
  8022b4:	78 08                	js     8022be <ipc_recv+0x58>
  8022b6:	a1 90 67 80 00       	mov    0x806790,%eax
  8022bb:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  8022be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022c1:	5b                   	pop    %ebx
  8022c2:	5e                   	pop    %esi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    

008022c5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	57                   	push   %edi
  8022c9:	56                   	push   %esi
  8022ca:	53                   	push   %ebx
  8022cb:	83 ec 0c             	sub    $0xc,%esp
  8022ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  8022d7:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  8022d9:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8022de:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  8022e1:	ff 75 14             	pushl  0x14(%ebp)
  8022e4:	53                   	push   %ebx
  8022e5:	56                   	push   %esi
  8022e6:	57                   	push   %edi
  8022e7:	e8 01 ed ff ff       	call   800fed <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  8022ec:	83 c4 10             	add    $0x10,%esp
  8022ef:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022f2:	75 07                	jne    8022fb <ipc_send+0x36>
				    sys_yield();
  8022f4:	e8 48 eb ff ff       	call   800e41 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  8022f9:	eb e6                	jmp    8022e1 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  8022fb:	85 c0                	test   %eax,%eax
  8022fd:	74 12                	je     802311 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  8022ff:	50                   	push   %eax
  802300:	68 85 2c 80 00       	push   $0x802c85
  802305:	6a 4b                	push   $0x4b
  802307:	68 99 2c 80 00       	push   $0x802c99
  80230c:	e8 ee e0 ff ff       	call   8003ff <_panic>
			 }
	   }
}
  802311:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802314:	5b                   	pop    %ebx
  802315:	5e                   	pop    %esi
  802316:	5f                   	pop    %edi
  802317:	5d                   	pop    %ebp
  802318:	c3                   	ret    

00802319 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  802319:	55                   	push   %ebp
  80231a:	89 e5                	mov    %esp,%ebp
  80231c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  80231f:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  802324:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802327:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80232d:	8b 52 50             	mov    0x50(%edx),%edx
  802330:	39 ca                	cmp    %ecx,%edx
  802332:	75 0d                	jne    802341 <ipc_find_env+0x28>
				    return envs[i].env_id;
  802334:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802337:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80233c:	8b 40 48             	mov    0x48(%eax),%eax
  80233f:	eb 0f                	jmp    802350 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  802341:	83 c0 01             	add    $0x1,%eax
  802344:	3d 00 04 00 00       	cmp    $0x400,%eax
  802349:	75 d9                	jne    802324 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  80234b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    

00802352 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802352:	55                   	push   %ebp
  802353:	89 e5                	mov    %esp,%ebp
  802355:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802358:	89 d0                	mov    %edx,%eax
  80235a:	c1 e8 16             	shr    $0x16,%eax
  80235d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802364:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802369:	f6 c1 01             	test   $0x1,%cl
  80236c:	74 1d                	je     80238b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80236e:	c1 ea 0c             	shr    $0xc,%edx
  802371:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802378:	f6 c2 01             	test   $0x1,%dl
  80237b:	74 0e                	je     80238b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80237d:	c1 ea 0c             	shr    $0xc,%edx
  802380:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802387:	ef 
  802388:	0f b7 c0             	movzwl %ax,%eax
}
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	66 90                	xchg   %ax,%ax
  80238f:	90                   	nop

00802390 <__udivdi3>:
  802390:	55                   	push   %ebp
  802391:	57                   	push   %edi
  802392:	56                   	push   %esi
  802393:	53                   	push   %ebx
  802394:	83 ec 1c             	sub    $0x1c,%esp
  802397:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80239b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80239f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023a7:	85 f6                	test   %esi,%esi
  8023a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023ad:	89 ca                	mov    %ecx,%edx
  8023af:	89 f8                	mov    %edi,%eax
  8023b1:	75 3d                	jne    8023f0 <__udivdi3+0x60>
  8023b3:	39 cf                	cmp    %ecx,%edi
  8023b5:	0f 87 c5 00 00 00    	ja     802480 <__udivdi3+0xf0>
  8023bb:	85 ff                	test   %edi,%edi
  8023bd:	89 fd                	mov    %edi,%ebp
  8023bf:	75 0b                	jne    8023cc <__udivdi3+0x3c>
  8023c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c6:	31 d2                	xor    %edx,%edx
  8023c8:	f7 f7                	div    %edi
  8023ca:	89 c5                	mov    %eax,%ebp
  8023cc:	89 c8                	mov    %ecx,%eax
  8023ce:	31 d2                	xor    %edx,%edx
  8023d0:	f7 f5                	div    %ebp
  8023d2:	89 c1                	mov    %eax,%ecx
  8023d4:	89 d8                	mov    %ebx,%eax
  8023d6:	89 cf                	mov    %ecx,%edi
  8023d8:	f7 f5                	div    %ebp
  8023da:	89 c3                	mov    %eax,%ebx
  8023dc:	89 d8                	mov    %ebx,%eax
  8023de:	89 fa                	mov    %edi,%edx
  8023e0:	83 c4 1c             	add    $0x1c,%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5f                   	pop    %edi
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    
  8023e8:	90                   	nop
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	39 ce                	cmp    %ecx,%esi
  8023f2:	77 74                	ja     802468 <__udivdi3+0xd8>
  8023f4:	0f bd fe             	bsr    %esi,%edi
  8023f7:	83 f7 1f             	xor    $0x1f,%edi
  8023fa:	0f 84 98 00 00 00    	je     802498 <__udivdi3+0x108>
  802400:	bb 20 00 00 00       	mov    $0x20,%ebx
  802405:	89 f9                	mov    %edi,%ecx
  802407:	89 c5                	mov    %eax,%ebp
  802409:	29 fb                	sub    %edi,%ebx
  80240b:	d3 e6                	shl    %cl,%esi
  80240d:	89 d9                	mov    %ebx,%ecx
  80240f:	d3 ed                	shr    %cl,%ebp
  802411:	89 f9                	mov    %edi,%ecx
  802413:	d3 e0                	shl    %cl,%eax
  802415:	09 ee                	or     %ebp,%esi
  802417:	89 d9                	mov    %ebx,%ecx
  802419:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80241d:	89 d5                	mov    %edx,%ebp
  80241f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802423:	d3 ed                	shr    %cl,%ebp
  802425:	89 f9                	mov    %edi,%ecx
  802427:	d3 e2                	shl    %cl,%edx
  802429:	89 d9                	mov    %ebx,%ecx
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	09 c2                	or     %eax,%edx
  80242f:	89 d0                	mov    %edx,%eax
  802431:	89 ea                	mov    %ebp,%edx
  802433:	f7 f6                	div    %esi
  802435:	89 d5                	mov    %edx,%ebp
  802437:	89 c3                	mov    %eax,%ebx
  802439:	f7 64 24 0c          	mull   0xc(%esp)
  80243d:	39 d5                	cmp    %edx,%ebp
  80243f:	72 10                	jb     802451 <__udivdi3+0xc1>
  802441:	8b 74 24 08          	mov    0x8(%esp),%esi
  802445:	89 f9                	mov    %edi,%ecx
  802447:	d3 e6                	shl    %cl,%esi
  802449:	39 c6                	cmp    %eax,%esi
  80244b:	73 07                	jae    802454 <__udivdi3+0xc4>
  80244d:	39 d5                	cmp    %edx,%ebp
  80244f:	75 03                	jne    802454 <__udivdi3+0xc4>
  802451:	83 eb 01             	sub    $0x1,%ebx
  802454:	31 ff                	xor    %edi,%edi
  802456:	89 d8                	mov    %ebx,%eax
  802458:	89 fa                	mov    %edi,%edx
  80245a:	83 c4 1c             	add    $0x1c,%esp
  80245d:	5b                   	pop    %ebx
  80245e:	5e                   	pop    %esi
  80245f:	5f                   	pop    %edi
  802460:	5d                   	pop    %ebp
  802461:	c3                   	ret    
  802462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802468:	31 ff                	xor    %edi,%edi
  80246a:	31 db                	xor    %ebx,%ebx
  80246c:	89 d8                	mov    %ebx,%eax
  80246e:	89 fa                	mov    %edi,%edx
  802470:	83 c4 1c             	add    $0x1c,%esp
  802473:	5b                   	pop    %ebx
  802474:	5e                   	pop    %esi
  802475:	5f                   	pop    %edi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    
  802478:	90                   	nop
  802479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802480:	89 d8                	mov    %ebx,%eax
  802482:	f7 f7                	div    %edi
  802484:	31 ff                	xor    %edi,%edi
  802486:	89 c3                	mov    %eax,%ebx
  802488:	89 d8                	mov    %ebx,%eax
  80248a:	89 fa                	mov    %edi,%edx
  80248c:	83 c4 1c             	add    $0x1c,%esp
  80248f:	5b                   	pop    %ebx
  802490:	5e                   	pop    %esi
  802491:	5f                   	pop    %edi
  802492:	5d                   	pop    %ebp
  802493:	c3                   	ret    
  802494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802498:	39 ce                	cmp    %ecx,%esi
  80249a:	72 0c                	jb     8024a8 <__udivdi3+0x118>
  80249c:	31 db                	xor    %ebx,%ebx
  80249e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024a2:	0f 87 34 ff ff ff    	ja     8023dc <__udivdi3+0x4c>
  8024a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024ad:	e9 2a ff ff ff       	jmp    8023dc <__udivdi3+0x4c>
  8024b2:	66 90                	xchg   %ax,%ax
  8024b4:	66 90                	xchg   %ax,%ax
  8024b6:	66 90                	xchg   %ax,%ax
  8024b8:	66 90                	xchg   %ax,%ax
  8024ba:	66 90                	xchg   %ax,%ax
  8024bc:	66 90                	xchg   %ax,%ax
  8024be:	66 90                	xchg   %ax,%ax

008024c0 <__umoddi3>:
  8024c0:	55                   	push   %ebp
  8024c1:	57                   	push   %edi
  8024c2:	56                   	push   %esi
  8024c3:	53                   	push   %ebx
  8024c4:	83 ec 1c             	sub    $0x1c,%esp
  8024c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024d7:	85 d2                	test   %edx,%edx
  8024d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024e1:	89 f3                	mov    %esi,%ebx
  8024e3:	89 3c 24             	mov    %edi,(%esp)
  8024e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024ea:	75 1c                	jne    802508 <__umoddi3+0x48>
  8024ec:	39 f7                	cmp    %esi,%edi
  8024ee:	76 50                	jbe    802540 <__umoddi3+0x80>
  8024f0:	89 c8                	mov    %ecx,%eax
  8024f2:	89 f2                	mov    %esi,%edx
  8024f4:	f7 f7                	div    %edi
  8024f6:	89 d0                	mov    %edx,%eax
  8024f8:	31 d2                	xor    %edx,%edx
  8024fa:	83 c4 1c             	add    $0x1c,%esp
  8024fd:	5b                   	pop    %ebx
  8024fe:	5e                   	pop    %esi
  8024ff:	5f                   	pop    %edi
  802500:	5d                   	pop    %ebp
  802501:	c3                   	ret    
  802502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802508:	39 f2                	cmp    %esi,%edx
  80250a:	89 d0                	mov    %edx,%eax
  80250c:	77 52                	ja     802560 <__umoddi3+0xa0>
  80250e:	0f bd ea             	bsr    %edx,%ebp
  802511:	83 f5 1f             	xor    $0x1f,%ebp
  802514:	75 5a                	jne    802570 <__umoddi3+0xb0>
  802516:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80251a:	0f 82 e0 00 00 00    	jb     802600 <__umoddi3+0x140>
  802520:	39 0c 24             	cmp    %ecx,(%esp)
  802523:	0f 86 d7 00 00 00    	jbe    802600 <__umoddi3+0x140>
  802529:	8b 44 24 08          	mov    0x8(%esp),%eax
  80252d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802531:	83 c4 1c             	add    $0x1c,%esp
  802534:	5b                   	pop    %ebx
  802535:	5e                   	pop    %esi
  802536:	5f                   	pop    %edi
  802537:	5d                   	pop    %ebp
  802538:	c3                   	ret    
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	85 ff                	test   %edi,%edi
  802542:	89 fd                	mov    %edi,%ebp
  802544:	75 0b                	jne    802551 <__umoddi3+0x91>
  802546:	b8 01 00 00 00       	mov    $0x1,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	f7 f7                	div    %edi
  80254f:	89 c5                	mov    %eax,%ebp
  802551:	89 f0                	mov    %esi,%eax
  802553:	31 d2                	xor    %edx,%edx
  802555:	f7 f5                	div    %ebp
  802557:	89 c8                	mov    %ecx,%eax
  802559:	f7 f5                	div    %ebp
  80255b:	89 d0                	mov    %edx,%eax
  80255d:	eb 99                	jmp    8024f8 <__umoddi3+0x38>
  80255f:	90                   	nop
  802560:	89 c8                	mov    %ecx,%eax
  802562:	89 f2                	mov    %esi,%edx
  802564:	83 c4 1c             	add    $0x1c,%esp
  802567:	5b                   	pop    %ebx
  802568:	5e                   	pop    %esi
  802569:	5f                   	pop    %edi
  80256a:	5d                   	pop    %ebp
  80256b:	c3                   	ret    
  80256c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802570:	8b 34 24             	mov    (%esp),%esi
  802573:	bf 20 00 00 00       	mov    $0x20,%edi
  802578:	89 e9                	mov    %ebp,%ecx
  80257a:	29 ef                	sub    %ebp,%edi
  80257c:	d3 e0                	shl    %cl,%eax
  80257e:	89 f9                	mov    %edi,%ecx
  802580:	89 f2                	mov    %esi,%edx
  802582:	d3 ea                	shr    %cl,%edx
  802584:	89 e9                	mov    %ebp,%ecx
  802586:	09 c2                	or     %eax,%edx
  802588:	89 d8                	mov    %ebx,%eax
  80258a:	89 14 24             	mov    %edx,(%esp)
  80258d:	89 f2                	mov    %esi,%edx
  80258f:	d3 e2                	shl    %cl,%edx
  802591:	89 f9                	mov    %edi,%ecx
  802593:	89 54 24 04          	mov    %edx,0x4(%esp)
  802597:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80259b:	d3 e8                	shr    %cl,%eax
  80259d:	89 e9                	mov    %ebp,%ecx
  80259f:	89 c6                	mov    %eax,%esi
  8025a1:	d3 e3                	shl    %cl,%ebx
  8025a3:	89 f9                	mov    %edi,%ecx
  8025a5:	89 d0                	mov    %edx,%eax
  8025a7:	d3 e8                	shr    %cl,%eax
  8025a9:	89 e9                	mov    %ebp,%ecx
  8025ab:	09 d8                	or     %ebx,%eax
  8025ad:	89 d3                	mov    %edx,%ebx
  8025af:	89 f2                	mov    %esi,%edx
  8025b1:	f7 34 24             	divl   (%esp)
  8025b4:	89 d6                	mov    %edx,%esi
  8025b6:	d3 e3                	shl    %cl,%ebx
  8025b8:	f7 64 24 04          	mull   0x4(%esp)
  8025bc:	39 d6                	cmp    %edx,%esi
  8025be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025c2:	89 d1                	mov    %edx,%ecx
  8025c4:	89 c3                	mov    %eax,%ebx
  8025c6:	72 08                	jb     8025d0 <__umoddi3+0x110>
  8025c8:	75 11                	jne    8025db <__umoddi3+0x11b>
  8025ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025ce:	73 0b                	jae    8025db <__umoddi3+0x11b>
  8025d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025d4:	1b 14 24             	sbb    (%esp),%edx
  8025d7:	89 d1                	mov    %edx,%ecx
  8025d9:	89 c3                	mov    %eax,%ebx
  8025db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025df:	29 da                	sub    %ebx,%edx
  8025e1:	19 ce                	sbb    %ecx,%esi
  8025e3:	89 f9                	mov    %edi,%ecx
  8025e5:	89 f0                	mov    %esi,%eax
  8025e7:	d3 e0                	shl    %cl,%eax
  8025e9:	89 e9                	mov    %ebp,%ecx
  8025eb:	d3 ea                	shr    %cl,%edx
  8025ed:	89 e9                	mov    %ebp,%ecx
  8025ef:	d3 ee                	shr    %cl,%esi
  8025f1:	09 d0                	or     %edx,%eax
  8025f3:	89 f2                	mov    %esi,%edx
  8025f5:	83 c4 1c             	add    $0x1c,%esp
  8025f8:	5b                   	pop    %ebx
  8025f9:	5e                   	pop    %esi
  8025fa:	5f                   	pop    %edi
  8025fb:	5d                   	pop    %ebp
  8025fc:	c3                   	ret    
  8025fd:	8d 76 00             	lea    0x0(%esi),%esi
  802600:	29 f9                	sub    %edi,%ecx
  802602:	19 d6                	sbb    %edx,%esi
  802604:	89 74 24 04          	mov    %esi,0x4(%esp)
  802608:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80260c:	e9 18 ff ff ff       	jmp    802529 <__umoddi3+0x69>
