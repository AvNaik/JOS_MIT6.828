
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 9f 0c 00 00       	call   800ce6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 34 13 00 00       	call   80138d <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 d1 12 00 00       	call   801339 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 61 12 00 00       	call   8012da <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 e0 23 80 00       	mov    $0x8023e0,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 eb 23 80 00       	push   $0x8023eb
  8000ad:	6a 20                	push   $0x20
  8000af:	68 05 24 80 00       	push   $0x802405
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 a0 25 80 00       	push   $0x8025a0
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 05 24 80 00       	push   $0x802405
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 15 24 80 00       	mov    $0x802415,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 1e 24 80 00       	push   $0x80241e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 05 24 80 00       	push   $0x802405
  8000f1:	e8 92 05 00 00       	call   800688 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 c4 25 80 00       	push   $0x8025c4
  800119:	6a 27                	push   $0x27
  80011b:	68 05 24 80 00       	push   $0x802405
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 36 24 80 00       	push   $0x802436
  80012d:	e8 2f 06 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 30 80 00    	call   *0x80301c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 4a 24 80 00       	push   $0x80244a
  800154:	6a 2b                	push   $0x2b
  800156:	68 05 24 80 00       	push   $0x802405
  80015b:	e8 28 05 00 00       	call   800688 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 3f 0b 00 00       	call   800cad <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 29 0b 00 00       	call   800cad <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 f4 25 80 00       	push   $0x8025f4
  80018f:	6a 2d                	push   $0x2d
  800191:	68 05 24 80 00       	push   $0x802405
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 58 24 80 00       	push   $0x802458
  8001a3:	e8 b9 05 00 00       	call   800761 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 6d 0c 00 00       	call   800e2b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 30 80 00    	call   *0x803010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 6b 24 80 00       	push   $0x80246b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 05 24 80 00       	push   $0x802405
  8001e6:	e8 9d 04 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 90 0b 00 00       	call   800d90 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 79 24 80 00       	push   $0x802479
  80020f:	6a 34                	push   $0x34
  800211:	68 05 24 80 00       	push   $0x802405
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 97 24 80 00       	push   $0x802497
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 30 80 00    	call   *0x803018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 aa 24 80 00       	push   $0x8024aa
  800242:	6a 38                	push   $0x38
  800244:	68 05 24 80 00       	push   $0x802405
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 b9 24 80 00       	push   $0x8024b9
  800256:	e8 06 05 00 00       	call   800761 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 e4 0e 00 00       	call   80116e <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 30 80 00    	call   *0x803010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 1c 26 80 00       	push   $0x80261c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 05 24 80 00       	push   $0x802405
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 cd 24 80 00       	push   $0x8024cd
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 e3 24 80 00       	mov    $0x8024e3,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 ed 24 80 00       	push   $0x8024ed
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 05 24 80 00       	push   $0x802405
  8002ed:	e8 96 03 00 00       	call   800688 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 30 80 00    	pushl  0x803000
  800301:	e8 a7 09 00 00       	call   800cad <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 30 80 00    	pushl  0x803000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 30 80 00    	pushl  0x803000
  800322:	e8 86 09 00 00       	call   800cad <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 06 25 80 00       	push   $0x802506
  800334:	6a 4b                	push   $0x4b
  800336:	68 05 24 80 00       	push   $0x802405
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 15 25 80 00       	push   $0x802515
  800348:	e8 14 04 00 00       	call   800761 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 be 0a 00 00       	call   800e2b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 30 80 00    	call   *0x803010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 54 26 80 00       	push   $0x802654
  800390:	6a 51                	push   $0x51
  800392:	68 05 24 80 00       	push   $0x802405
  800397:	e8 ec 02 00 00       	call   800688 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 30 80 00    	pushl  0x803000
  8003a5:	e8 03 09 00 00       	call   800cad <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 74 26 80 00       	push   $0x802674
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 05 24 80 00       	push   $0x802405
  8003be:	e8 c5 02 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 30 80 00    	pushl  0x803000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 b8 09 00 00       	call   800d90 <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 ac 26 80 00       	push   $0x8026ac
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 05 24 80 00       	push   $0x802405
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 dc 26 80 00       	push   $0x8026dc
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 e0 23 80 00       	push   $0x8023e0
  80040a:	e8 67 17 00 00       	call   801b76 <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 f1 23 80 00       	push   $0x8023f1
  800426:	6a 5a                	push   $0x5a
  800428:	68 05 24 80 00       	push   $0x802405
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 29 25 80 00       	push   $0x802529
  80043e:	6a 5c                	push   $0x5c
  800440:	68 05 24 80 00       	push   $0x802405
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 15 24 80 00       	push   $0x802415
  800454:	e8 1d 17 00 00       	call   801b76 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 24 24 80 00       	push   $0x802424
  800466:	6a 5f                	push   $0x5f
  800468:	68 05 24 80 00       	push   $0x802405
  80046d:	e8 16 02 00 00       	call   800688 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 00 27 80 00       	push   $0x802700
  800498:	6a 62                	push   $0x62
  80049a:	68 05 24 80 00       	push   $0x802405
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 3c 24 80 00       	push   $0x80243c
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 44 25 80 00       	push   $0x802544
  8004be:	e8 b3 16 00 00       	call   801b76 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 49 25 80 00       	push   $0x802549
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 05 24 80 00       	push   $0x802405
  8004d9:	e8 aa 01 00 00       	call   800688 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 37 09 00 00       	call   800e2b <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 65 12 00 00       	call   80177c <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 58 25 80 00       	push   $0x802558
  800528:	6a 6c                	push   $0x6c
  80052a:	68 05 24 80 00       	push   $0x802405
  80052f:	e8 54 01 00 00       	call   800688 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 1a 10 00 00       	call   801566 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 44 25 80 00       	push   $0x802544
  800556:	e8 1b 16 00 00       	call   801b76 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 6a 25 80 00       	push   $0x80256a
  80056a:	6a 71                	push   $0x71
  80056c:	68 05 24 80 00       	push   $0x802405
  800571:	e8 12 01 00 00       	call   800688 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 9d 11 00 00       	call   801733 <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 78 25 80 00       	push   $0x802578
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 05 24 80 00       	push   $0x802405
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 28 27 80 00       	push   $0x802728
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 05 24 80 00       	push   $0x802405
  8005d0:	e8 b3 00 00 00       	call   800688 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 54 27 80 00       	push   $0x802754
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 05 24 80 00       	push   $0x802405
  8005f0:	e8 93 00 00 00       	call   800688 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 55 0f 00 00       	call   801566 <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 89 25 80 00 	movl   $0x802589,(%esp)
  800618:	e8 44 01 00 00       	call   800761 <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800633:	e8 73 0a 00 00       	call   8010ab <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800640:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800645:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7e 07                	jle    800655 <libmain+0x2d>
		binaryname = argv[0];
  80064e:	8b 06                	mov    (%esi),%eax
  800650:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	e8 1f fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80065f:	e8 0a 00 00 00       	call   80066e <exit>
}
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800674:	e8 18 0f 00 00       	call   801591 <close_all>
	sys_env_destroy(0);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	6a 00                	push   $0x0
  80067e:	e8 e7 09 00 00       	call   80106a <sys_env_destroy>
}
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800690:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800696:	e8 10 0a 00 00       	call   8010ab <sys_getenvid>
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	50                   	push   %eax
  8006a6:	68 ac 27 80 00       	push   $0x8027ac
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  8006c3:	e8 99 00 00 00       	call   800761 <cprintf>
  8006c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cb:	cc                   	int3   
  8006cc:	eb fd                	jmp    8006cb <_panic+0x43>

008006ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d8:	8b 13                	mov    (%ebx),%edx
  8006da:	8d 42 01             	lea    0x1(%edx),%eax
  8006dd:	89 03                	mov    %eax,(%ebx)
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006eb:	75 1a                	jne    800707 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	68 ff 00 00 00       	push   $0xff
  8006f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 2f 09 00 00       	call   80102d <sys_cputs>
		b->idx = 0;
  8006fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800704:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800707:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800719:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800720:	00 00 00 
	b.cnt = 0;
  800723:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80072a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 ce 06 80 00       	push   $0x8006ce
  80073f:	e8 54 01 00 00       	call   800898 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	e8 d4 08 00 00       	call   80102d <sys_cputs>

	return b.cnt;
}
  800759:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800767:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9d ff ff ff       	call   800710 <vcprintf>
	va_end(ap);

	return cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	89 c7                	mov    %eax,%edi
  800780:	89 d6                	mov    %edx,%esi
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800799:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079c:	39 d3                	cmp    %edx,%ebx
  80079e:	72 05                	jb     8007a5 <printnum+0x30>
  8007a0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007a3:	77 45                	ja     8007ea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	ff 75 18             	pushl  0x18(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007b1:	53                   	push   %ebx
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007be:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c4:	e8 77 19 00 00       	call   802140 <__udivdi3>
  8007c9:	83 c4 18             	add    $0x18,%esp
  8007cc:	52                   	push   %edx
  8007cd:	50                   	push   %eax
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	89 f8                	mov    %edi,%eax
  8007d2:	e8 9e ff ff ff       	call   800775 <printnum>
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	eb 18                	jmp    8007f4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	ff 75 18             	pushl  0x18(%ebp)
  8007e3:	ff d7                	call   *%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <printnum+0x78>
  8007ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f e8                	jg     8007dc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 dc             	pushl  -0x24(%ebp)
  800804:	ff 75 d8             	pushl  -0x28(%ebp)
  800807:	e8 64 1a 00 00       	call   802270 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 cf 27 80 00 	movsbl 0x8027cf(%eax),%eax
  800816:	50                   	push   %eax
  800817:	ff d7                	call   *%edi
}
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800827:	83 fa 01             	cmp    $0x1,%edx
  80082a:	7e 0e                	jle    80083a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800831:	89 08                	mov    %ecx,(%eax)
  800833:	8b 02                	mov    (%edx),%eax
  800835:	8b 52 04             	mov    0x4(%edx),%edx
  800838:	eb 22                	jmp    80085c <getuint+0x38>
	else if (lflag)
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 10                	je     80084e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	8d 4a 04             	lea    0x4(%edx),%ecx
  800843:	89 08                	mov    %ecx,(%eax)
  800845:	8b 02                	mov    (%edx),%eax
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 0e                	jmp    80085c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80084e:	8b 10                	mov    (%eax),%edx
  800850:	8d 4a 04             	lea    0x4(%edx),%ecx
  800853:	89 08                	mov    %ecx,(%eax)
  800855:	8b 02                	mov    (%edx),%eax
  800857:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800864:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800868:	8b 10                	mov    (%eax),%edx
  80086a:	3b 50 04             	cmp    0x4(%eax),%edx
  80086d:	73 0a                	jae    800879 <sprintputch+0x1b>
		*b->buf++ = ch;
  80086f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800872:	89 08                	mov    %ecx,(%eax)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	88 02                	mov    %al,(%edx)
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800884:	50                   	push   %eax
  800885:	ff 75 10             	pushl  0x10(%ebp)
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	ff 75 08             	pushl  0x8(%ebp)
  80088e:	e8 05 00 00 00       	call   800898 <vprintfmt>
	va_end(ap);
}
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	57                   	push   %edi
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	83 ec 2c             	sub    $0x2c,%esp
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008aa:	eb 12                	jmp    8008be <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	0f 84 89 03 00 00    	je     800c3d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	50                   	push   %eax
  8008b9:	ff d6                	call   *%esi
  8008bb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008be:	83 c7 01             	add    $0x1,%edi
  8008c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c5:	83 f8 25             	cmp    $0x25,%eax
  8008c8:	75 e2                	jne    8008ac <vprintfmt+0x14>
  8008ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e8:	eb 07                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008ed:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f1:	8d 47 01             	lea    0x1(%edi),%eax
  8008f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f7:	0f b6 07             	movzbl (%edi),%eax
  8008fa:	0f b6 c8             	movzbl %al,%ecx
  8008fd:	83 e8 23             	sub    $0x23,%eax
  800900:	3c 55                	cmp    $0x55,%al
  800902:	0f 87 1a 03 00 00    	ja     800c22 <vprintfmt+0x38a>
  800908:	0f b6 c0             	movzbl %al,%eax
  80090b:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
  800912:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800915:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800919:	eb d6                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800926:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800929:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80092d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800930:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800933:	83 fa 09             	cmp    $0x9,%edx
  800936:	77 39                	ja     800971 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800938:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80093b:	eb e9                	jmp    800926 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80093d:	8b 45 14             	mov    0x14(%ebp),%eax
  800940:	8d 48 04             	lea    0x4(%eax),%ecx
  800943:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800946:	8b 00                	mov    (%eax),%eax
  800948:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80094e:	eb 27                	jmp    800977 <vprintfmt+0xdf>
  800950:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800953:	85 c0                	test   %eax,%eax
  800955:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095a:	0f 49 c8             	cmovns %eax,%ecx
  80095d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800960:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800963:	eb 8c                	jmp    8008f1 <vprintfmt+0x59>
  800965:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800968:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80096f:	eb 80                	jmp    8008f1 <vprintfmt+0x59>
  800971:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800974:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800977:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80097b:	0f 89 70 ff ff ff    	jns    8008f1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800981:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800984:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800987:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80098e:	e9 5e ff ff ff       	jmp    8008f1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800993:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800996:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800999:	e9 53 ff ff ff       	jmp    8008f1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80099e:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a1:	8d 50 04             	lea    0x4(%eax),%edx
  8009a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	53                   	push   %ebx
  8009ab:	ff 30                	pushl  (%eax)
  8009ad:	ff d6                	call   *%esi
			break;
  8009af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009b5:	e9 04 ff ff ff       	jmp    8008be <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bd:	8d 50 04             	lea    0x4(%eax),%edx
  8009c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c3:	8b 00                	mov    (%eax),%eax
  8009c5:	99                   	cltd   
  8009c6:	31 d0                	xor    %edx,%eax
  8009c8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ca:	83 f8 0f             	cmp    $0xf,%eax
  8009cd:	7f 0b                	jg     8009da <vprintfmt+0x142>
  8009cf:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  8009d6:	85 d2                	test   %edx,%edx
  8009d8:	75 18                	jne    8009f2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009da:	50                   	push   %eax
  8009db:	68 e7 27 80 00       	push   $0x8027e7
  8009e0:	53                   	push   %ebx
  8009e1:	56                   	push   %esi
  8009e2:	e8 94 fe ff ff       	call   80087b <printfmt>
  8009e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009ed:	e9 cc fe ff ff       	jmp    8008be <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009f2:	52                   	push   %edx
  8009f3:	68 d1 2b 80 00       	push   $0x802bd1
  8009f8:	53                   	push   %ebx
  8009f9:	56                   	push   %esi
  8009fa:	e8 7c fe ff ff       	call   80087b <printfmt>
  8009ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a05:	e9 b4 fe ff ff       	jmp    8008be <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0d:	8d 50 04             	lea    0x4(%eax),%edx
  800a10:	89 55 14             	mov    %edx,0x14(%ebp)
  800a13:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a15:	85 ff                	test   %edi,%edi
  800a17:	b8 e0 27 80 00       	mov    $0x8027e0,%eax
  800a1c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a23:	0f 8e 94 00 00 00    	jle    800abd <vprintfmt+0x225>
  800a29:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a2d:	0f 84 98 00 00 00    	je     800acb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	ff 75 d0             	pushl  -0x30(%ebp)
  800a39:	57                   	push   %edi
  800a3a:	e8 86 02 00 00       	call   800cc5 <strnlen>
  800a3f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a42:	29 c1                	sub    %eax,%ecx
  800a44:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a47:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a4a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a51:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a54:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a56:	eb 0f                	jmp    800a67 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	53                   	push   %ebx
  800a5c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a5f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	83 c4 10             	add    $0x10,%esp
  800a67:	85 ff                	test   %edi,%edi
  800a69:	7f ed                	jg     800a58 <vprintfmt+0x1c0>
  800a6b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a6e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a71:	85 c9                	test   %ecx,%ecx
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	0f 49 c1             	cmovns %ecx,%eax
  800a7b:	29 c1                	sub    %eax,%ecx
  800a7d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a80:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a83:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a86:	89 cb                	mov    %ecx,%ebx
  800a88:	eb 4d                	jmp    800ad7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a8a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a8e:	74 1b                	je     800aab <vprintfmt+0x213>
  800a90:	0f be c0             	movsbl %al,%eax
  800a93:	83 e8 20             	sub    $0x20,%eax
  800a96:	83 f8 5e             	cmp    $0x5e,%eax
  800a99:	76 10                	jbe    800aab <vprintfmt+0x213>
					putch('?', putdat);
  800a9b:	83 ec 08             	sub    $0x8,%esp
  800a9e:	ff 75 0c             	pushl  0xc(%ebp)
  800aa1:	6a 3f                	push   $0x3f
  800aa3:	ff 55 08             	call   *0x8(%ebp)
  800aa6:	83 c4 10             	add    $0x10,%esp
  800aa9:	eb 0d                	jmp    800ab8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800aab:	83 ec 08             	sub    $0x8,%esp
  800aae:	ff 75 0c             	pushl  0xc(%ebp)
  800ab1:	52                   	push   %edx
  800ab2:	ff 55 08             	call   *0x8(%ebp)
  800ab5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab8:	83 eb 01             	sub    $0x1,%ebx
  800abb:	eb 1a                	jmp    800ad7 <vprintfmt+0x23f>
  800abd:	89 75 08             	mov    %esi,0x8(%ebp)
  800ac0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ac3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ac6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ac9:	eb 0c                	jmp    800ad7 <vprintfmt+0x23f>
  800acb:	89 75 08             	mov    %esi,0x8(%ebp)
  800ace:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ad1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ad4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ad7:	83 c7 01             	add    $0x1,%edi
  800ada:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ade:	0f be d0             	movsbl %al,%edx
  800ae1:	85 d2                	test   %edx,%edx
  800ae3:	74 23                	je     800b08 <vprintfmt+0x270>
  800ae5:	85 f6                	test   %esi,%esi
  800ae7:	78 a1                	js     800a8a <vprintfmt+0x1f2>
  800ae9:	83 ee 01             	sub    $0x1,%esi
  800aec:	79 9c                	jns    800a8a <vprintfmt+0x1f2>
  800aee:	89 df                	mov    %ebx,%edi
  800af0:	8b 75 08             	mov    0x8(%ebp),%esi
  800af3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af6:	eb 18                	jmp    800b10 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800af8:	83 ec 08             	sub    $0x8,%esp
  800afb:	53                   	push   %ebx
  800afc:	6a 20                	push   $0x20
  800afe:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b00:	83 ef 01             	sub    $0x1,%edi
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	eb 08                	jmp    800b10 <vprintfmt+0x278>
  800b08:	89 df                	mov    %ebx,%edi
  800b0a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b10:	85 ff                	test   %edi,%edi
  800b12:	7f e4                	jg     800af8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b17:	e9 a2 fd ff ff       	jmp    8008be <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b1c:	83 fa 01             	cmp    $0x1,%edx
  800b1f:	7e 16                	jle    800b37 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800b21:	8b 45 14             	mov    0x14(%ebp),%eax
  800b24:	8d 50 08             	lea    0x8(%eax),%edx
  800b27:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2a:	8b 50 04             	mov    0x4(%eax),%edx
  800b2d:	8b 00                	mov    (%eax),%eax
  800b2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b32:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b35:	eb 32                	jmp    800b69 <vprintfmt+0x2d1>
	else if (lflag)
  800b37:	85 d2                	test   %edx,%edx
  800b39:	74 18                	je     800b53 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3e:	8d 50 04             	lea    0x4(%eax),%edx
  800b41:	89 55 14             	mov    %edx,0x14(%ebp)
  800b44:	8b 00                	mov    (%eax),%eax
  800b46:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b49:	89 c1                	mov    %eax,%ecx
  800b4b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b4e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b51:	eb 16                	jmp    800b69 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b53:	8b 45 14             	mov    0x14(%ebp),%eax
  800b56:	8d 50 04             	lea    0x4(%eax),%edx
  800b59:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5c:	8b 00                	mov    (%eax),%eax
  800b5e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b61:	89 c1                	mov    %eax,%ecx
  800b63:	c1 f9 1f             	sar    $0x1f,%ecx
  800b66:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b69:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b6c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b6f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b74:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b78:	79 74                	jns    800bee <vprintfmt+0x356>
				putch('-', putdat);
  800b7a:	83 ec 08             	sub    $0x8,%esp
  800b7d:	53                   	push   %ebx
  800b7e:	6a 2d                	push   $0x2d
  800b80:	ff d6                	call   *%esi
				num = -(long long) num;
  800b82:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b85:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b88:	f7 d8                	neg    %eax
  800b8a:	83 d2 00             	adc    $0x0,%edx
  800b8d:	f7 da                	neg    %edx
  800b8f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b92:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b97:	eb 55                	jmp    800bee <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b99:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9c:	e8 83 fc ff ff       	call   800824 <getuint>
			base = 10;
  800ba1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ba6:	eb 46                	jmp    800bee <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800ba8:	8d 45 14             	lea    0x14(%ebp),%eax
  800bab:	e8 74 fc ff ff       	call   800824 <getuint>
			base = 8;
  800bb0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800bb5:	eb 37                	jmp    800bee <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800bb7:	83 ec 08             	sub    $0x8,%esp
  800bba:	53                   	push   %ebx
  800bbb:	6a 30                	push   $0x30
  800bbd:	ff d6                	call   *%esi
			putch('x', putdat);
  800bbf:	83 c4 08             	add    $0x8,%esp
  800bc2:	53                   	push   %ebx
  800bc3:	6a 78                	push   $0x78
  800bc5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bca:	8d 50 04             	lea    0x4(%eax),%edx
  800bcd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bd0:	8b 00                	mov    (%eax),%eax
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bd7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bda:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bdf:	eb 0d                	jmp    800bee <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800be1:	8d 45 14             	lea    0x14(%ebp),%eax
  800be4:	e8 3b fc ff ff       	call   800824 <getuint>
			base = 16;
  800be9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bf5:	57                   	push   %edi
  800bf6:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf9:	51                   	push   %ecx
  800bfa:	52                   	push   %edx
  800bfb:	50                   	push   %eax
  800bfc:	89 da                	mov    %ebx,%edx
  800bfe:	89 f0                	mov    %esi,%eax
  800c00:	e8 70 fb ff ff       	call   800775 <printnum>
			break;
  800c05:	83 c4 20             	add    $0x20,%esp
  800c08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c0b:	e9 ae fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c10:	83 ec 08             	sub    $0x8,%esp
  800c13:	53                   	push   %ebx
  800c14:	51                   	push   %ecx
  800c15:	ff d6                	call   *%esi
			break;
  800c17:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c1d:	e9 9c fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c22:	83 ec 08             	sub    $0x8,%esp
  800c25:	53                   	push   %ebx
  800c26:	6a 25                	push   $0x25
  800c28:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	eb 03                	jmp    800c32 <vprintfmt+0x39a>
  800c2f:	83 ef 01             	sub    $0x1,%edi
  800c32:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c36:	75 f7                	jne    800c2f <vprintfmt+0x397>
  800c38:	e9 81 fc ff ff       	jmp    8008be <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 18             	sub    $0x18,%esp
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c51:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c54:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c58:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	74 26                	je     800c8c <vsnprintf+0x47>
  800c66:	85 d2                	test   %edx,%edx
  800c68:	7e 22                	jle    800c8c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c6a:	ff 75 14             	pushl  0x14(%ebp)
  800c6d:	ff 75 10             	pushl  0x10(%ebp)
  800c70:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c73:	50                   	push   %eax
  800c74:	68 5e 08 80 00       	push   $0x80085e
  800c79:	e8 1a fc ff ff       	call   800898 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c81:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c87:	83 c4 10             	add    $0x10,%esp
  800c8a:	eb 05                	jmp    800c91 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c99:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c9c:	50                   	push   %eax
  800c9d:	ff 75 10             	pushl  0x10(%ebp)
  800ca0:	ff 75 0c             	pushl  0xc(%ebp)
  800ca3:	ff 75 08             	pushl  0x8(%ebp)
  800ca6:	e8 9a ff ff ff       	call   800c45 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb8:	eb 03                	jmp    800cbd <strlen+0x10>
		n++;
  800cba:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cbd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cc1:	75 f7                	jne    800cba <strlen+0xd>
		n++;
	return n;
}
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cce:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd3:	eb 03                	jmp    800cd8 <strnlen+0x13>
		n++;
  800cd5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd8:	39 c2                	cmp    %eax,%edx
  800cda:	74 08                	je     800ce4 <strnlen+0x1f>
  800cdc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ce0:	75 f3                	jne    800cd5 <strnlen+0x10>
  800ce2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	53                   	push   %ebx
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cf0:	89 c2                	mov    %eax,%edx
  800cf2:	83 c2 01             	add    $0x1,%edx
  800cf5:	83 c1 01             	add    $0x1,%ecx
  800cf8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cfc:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cff:	84 db                	test   %bl,%bl
  800d01:	75 ef                	jne    800cf2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d03:	5b                   	pop    %ebx
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	53                   	push   %ebx
  800d0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d0d:	53                   	push   %ebx
  800d0e:	e8 9a ff ff ff       	call   800cad <strlen>
  800d13:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d16:	ff 75 0c             	pushl  0xc(%ebp)
  800d19:	01 d8                	add    %ebx,%eax
  800d1b:	50                   	push   %eax
  800d1c:	e8 c5 ff ff ff       	call   800ce6 <strcpy>
	return dst;
}
  800d21:	89 d8                	mov    %ebx,%eax
  800d23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	89 f3                	mov    %esi,%ebx
  800d35:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d38:	89 f2                	mov    %esi,%edx
  800d3a:	eb 0f                	jmp    800d4b <strncpy+0x23>
		*dst++ = *src;
  800d3c:	83 c2 01             	add    $0x1,%edx
  800d3f:	0f b6 01             	movzbl (%ecx),%eax
  800d42:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d45:	80 39 01             	cmpb   $0x1,(%ecx)
  800d48:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d4b:	39 da                	cmp    %ebx,%edx
  800d4d:	75 ed                	jne    800d3c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d4f:	89 f0                	mov    %esi,%eax
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 10             	mov    0x10(%ebp),%edx
  800d63:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d65:	85 d2                	test   %edx,%edx
  800d67:	74 21                	je     800d8a <strlcpy+0x35>
  800d69:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d6d:	89 f2                	mov    %esi,%edx
  800d6f:	eb 09                	jmp    800d7a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d71:	83 c2 01             	add    $0x1,%edx
  800d74:	83 c1 01             	add    $0x1,%ecx
  800d77:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d7a:	39 c2                	cmp    %eax,%edx
  800d7c:	74 09                	je     800d87 <strlcpy+0x32>
  800d7e:	0f b6 19             	movzbl (%ecx),%ebx
  800d81:	84 db                	test   %bl,%bl
  800d83:	75 ec                	jne    800d71 <strlcpy+0x1c>
  800d85:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d87:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d8a:	29 f0                	sub    %esi,%eax
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d96:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d99:	eb 06                	jmp    800da1 <strcmp+0x11>
		p++, q++;
  800d9b:	83 c1 01             	add    $0x1,%ecx
  800d9e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800da1:	0f b6 01             	movzbl (%ecx),%eax
  800da4:	84 c0                	test   %al,%al
  800da6:	74 04                	je     800dac <strcmp+0x1c>
  800da8:	3a 02                	cmp    (%edx),%al
  800daa:	74 ef                	je     800d9b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dac:	0f b6 c0             	movzbl %al,%eax
  800daf:	0f b6 12             	movzbl (%edx),%edx
  800db2:	29 d0                	sub    %edx,%eax
}
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	53                   	push   %ebx
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc0:	89 c3                	mov    %eax,%ebx
  800dc2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800dc5:	eb 06                	jmp    800dcd <strncmp+0x17>
		n--, p++, q++;
  800dc7:	83 c0 01             	add    $0x1,%eax
  800dca:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dcd:	39 d8                	cmp    %ebx,%eax
  800dcf:	74 15                	je     800de6 <strncmp+0x30>
  800dd1:	0f b6 08             	movzbl (%eax),%ecx
  800dd4:	84 c9                	test   %cl,%cl
  800dd6:	74 04                	je     800ddc <strncmp+0x26>
  800dd8:	3a 0a                	cmp    (%edx),%cl
  800dda:	74 eb                	je     800dc7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ddc:	0f b6 00             	movzbl (%eax),%eax
  800ddf:	0f b6 12             	movzbl (%edx),%edx
  800de2:	29 d0                	sub    %edx,%eax
  800de4:	eb 05                	jmp    800deb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800de6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800deb:	5b                   	pop    %ebx
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
  800df4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800df8:	eb 07                	jmp    800e01 <strchr+0x13>
		if (*s == c)
  800dfa:	38 ca                	cmp    %cl,%dl
  800dfc:	74 0f                	je     800e0d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dfe:	83 c0 01             	add    $0x1,%eax
  800e01:	0f b6 10             	movzbl (%eax),%edx
  800e04:	84 d2                	test   %dl,%dl
  800e06:	75 f2                	jne    800dfa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e19:	eb 03                	jmp    800e1e <strfind+0xf>
  800e1b:	83 c0 01             	add    $0x1,%eax
  800e1e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e21:	38 ca                	cmp    %cl,%dl
  800e23:	74 04                	je     800e29 <strfind+0x1a>
  800e25:	84 d2                	test   %dl,%dl
  800e27:	75 f2                	jne    800e1b <strfind+0xc>
			break;
	return (char *) s;
}
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	57                   	push   %edi
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e37:	85 c9                	test   %ecx,%ecx
  800e39:	74 36                	je     800e71 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e3b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e41:	75 28                	jne    800e6b <memset+0x40>
  800e43:	f6 c1 03             	test   $0x3,%cl
  800e46:	75 23                	jne    800e6b <memset+0x40>
		c &= 0xFF;
  800e48:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e4c:	89 d3                	mov    %edx,%ebx
  800e4e:	c1 e3 08             	shl    $0x8,%ebx
  800e51:	89 d6                	mov    %edx,%esi
  800e53:	c1 e6 18             	shl    $0x18,%esi
  800e56:	89 d0                	mov    %edx,%eax
  800e58:	c1 e0 10             	shl    $0x10,%eax
  800e5b:	09 f0                	or     %esi,%eax
  800e5d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e5f:	89 d8                	mov    %ebx,%eax
  800e61:	09 d0                	or     %edx,%eax
  800e63:	c1 e9 02             	shr    $0x2,%ecx
  800e66:	fc                   	cld    
  800e67:	f3 ab                	rep stos %eax,%es:(%edi)
  800e69:	eb 06                	jmp    800e71 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6e:	fc                   	cld    
  800e6f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e71:	89 f8                	mov    %edi,%eax
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	57                   	push   %edi
  800e7c:	56                   	push   %esi
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e83:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e86:	39 c6                	cmp    %eax,%esi
  800e88:	73 35                	jae    800ebf <memmove+0x47>
  800e8a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e8d:	39 d0                	cmp    %edx,%eax
  800e8f:	73 2e                	jae    800ebf <memmove+0x47>
		s += n;
		d += n;
  800e91:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e94:	89 d6                	mov    %edx,%esi
  800e96:	09 fe                	or     %edi,%esi
  800e98:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e9e:	75 13                	jne    800eb3 <memmove+0x3b>
  800ea0:	f6 c1 03             	test   $0x3,%cl
  800ea3:	75 0e                	jne    800eb3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ea5:	83 ef 04             	sub    $0x4,%edi
  800ea8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800eab:	c1 e9 02             	shr    $0x2,%ecx
  800eae:	fd                   	std    
  800eaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eb1:	eb 09                	jmp    800ebc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800eb3:	83 ef 01             	sub    $0x1,%edi
  800eb6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800eb9:	fd                   	std    
  800eba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ebc:	fc                   	cld    
  800ebd:	eb 1d                	jmp    800edc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ebf:	89 f2                	mov    %esi,%edx
  800ec1:	09 c2                	or     %eax,%edx
  800ec3:	f6 c2 03             	test   $0x3,%dl
  800ec6:	75 0f                	jne    800ed7 <memmove+0x5f>
  800ec8:	f6 c1 03             	test   $0x3,%cl
  800ecb:	75 0a                	jne    800ed7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ecd:	c1 e9 02             	shr    $0x2,%ecx
  800ed0:	89 c7                	mov    %eax,%edi
  800ed2:	fc                   	cld    
  800ed3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed5:	eb 05                	jmp    800edc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ed7:	89 c7                	mov    %eax,%edi
  800ed9:	fc                   	cld    
  800eda:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ee3:	ff 75 10             	pushl  0x10(%ebp)
  800ee6:	ff 75 0c             	pushl  0xc(%ebp)
  800ee9:	ff 75 08             	pushl  0x8(%ebp)
  800eec:	e8 87 ff ff ff       	call   800e78 <memmove>
}
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
  800ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  800efb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efe:	89 c6                	mov    %eax,%esi
  800f00:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f03:	eb 1a                	jmp    800f1f <memcmp+0x2c>
		if (*s1 != *s2)
  800f05:	0f b6 08             	movzbl (%eax),%ecx
  800f08:	0f b6 1a             	movzbl (%edx),%ebx
  800f0b:	38 d9                	cmp    %bl,%cl
  800f0d:	74 0a                	je     800f19 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f0f:	0f b6 c1             	movzbl %cl,%eax
  800f12:	0f b6 db             	movzbl %bl,%ebx
  800f15:	29 d8                	sub    %ebx,%eax
  800f17:	eb 0f                	jmp    800f28 <memcmp+0x35>
		s1++, s2++;
  800f19:	83 c0 01             	add    $0x1,%eax
  800f1c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f1f:	39 f0                	cmp    %esi,%eax
  800f21:	75 e2                	jne    800f05 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	53                   	push   %ebx
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f33:	89 c1                	mov    %eax,%ecx
  800f35:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f38:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f3c:	eb 0a                	jmp    800f48 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f3e:	0f b6 10             	movzbl (%eax),%edx
  800f41:	39 da                	cmp    %ebx,%edx
  800f43:	74 07                	je     800f4c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f45:	83 c0 01             	add    $0x1,%eax
  800f48:	39 c8                	cmp    %ecx,%eax
  800f4a:	72 f2                	jb     800f3e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f4c:	5b                   	pop    %ebx
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f5b:	eb 03                	jmp    800f60 <strtol+0x11>
		s++;
  800f5d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f60:	0f b6 01             	movzbl (%ecx),%eax
  800f63:	3c 20                	cmp    $0x20,%al
  800f65:	74 f6                	je     800f5d <strtol+0xe>
  800f67:	3c 09                	cmp    $0x9,%al
  800f69:	74 f2                	je     800f5d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f6b:	3c 2b                	cmp    $0x2b,%al
  800f6d:	75 0a                	jne    800f79 <strtol+0x2a>
		s++;
  800f6f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f72:	bf 00 00 00 00       	mov    $0x0,%edi
  800f77:	eb 11                	jmp    800f8a <strtol+0x3b>
  800f79:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f7e:	3c 2d                	cmp    $0x2d,%al
  800f80:	75 08                	jne    800f8a <strtol+0x3b>
		s++, neg = 1;
  800f82:	83 c1 01             	add    $0x1,%ecx
  800f85:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f8a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f90:	75 15                	jne    800fa7 <strtol+0x58>
  800f92:	80 39 30             	cmpb   $0x30,(%ecx)
  800f95:	75 10                	jne    800fa7 <strtol+0x58>
  800f97:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f9b:	75 7c                	jne    801019 <strtol+0xca>
		s += 2, base = 16;
  800f9d:	83 c1 02             	add    $0x2,%ecx
  800fa0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fa5:	eb 16                	jmp    800fbd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fa7:	85 db                	test   %ebx,%ebx
  800fa9:	75 12                	jne    800fbd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fab:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fb0:	80 39 30             	cmpb   $0x30,(%ecx)
  800fb3:	75 08                	jne    800fbd <strtol+0x6e>
		s++, base = 8;
  800fb5:	83 c1 01             	add    $0x1,%ecx
  800fb8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fc5:	0f b6 11             	movzbl (%ecx),%edx
  800fc8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fcb:	89 f3                	mov    %esi,%ebx
  800fcd:	80 fb 09             	cmp    $0x9,%bl
  800fd0:	77 08                	ja     800fda <strtol+0x8b>
			dig = *s - '0';
  800fd2:	0f be d2             	movsbl %dl,%edx
  800fd5:	83 ea 30             	sub    $0x30,%edx
  800fd8:	eb 22                	jmp    800ffc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800fda:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fdd:	89 f3                	mov    %esi,%ebx
  800fdf:	80 fb 19             	cmp    $0x19,%bl
  800fe2:	77 08                	ja     800fec <strtol+0x9d>
			dig = *s - 'a' + 10;
  800fe4:	0f be d2             	movsbl %dl,%edx
  800fe7:	83 ea 57             	sub    $0x57,%edx
  800fea:	eb 10                	jmp    800ffc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800fec:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fef:	89 f3                	mov    %esi,%ebx
  800ff1:	80 fb 19             	cmp    $0x19,%bl
  800ff4:	77 16                	ja     80100c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ff6:	0f be d2             	movsbl %dl,%edx
  800ff9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ffc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fff:	7d 0b                	jge    80100c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801001:	83 c1 01             	add    $0x1,%ecx
  801004:	0f af 45 10          	imul   0x10(%ebp),%eax
  801008:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80100a:	eb b9                	jmp    800fc5 <strtol+0x76>

	if (endptr)
  80100c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801010:	74 0d                	je     80101f <strtol+0xd0>
		*endptr = (char *) s;
  801012:	8b 75 0c             	mov    0xc(%ebp),%esi
  801015:	89 0e                	mov    %ecx,(%esi)
  801017:	eb 06                	jmp    80101f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801019:	85 db                	test   %ebx,%ebx
  80101b:	74 98                	je     800fb5 <strtol+0x66>
  80101d:	eb 9e                	jmp    800fbd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80101f:	89 c2                	mov    %eax,%edx
  801021:	f7 da                	neg    %edx
  801023:	85 ff                	test   %edi,%edi
  801025:	0f 45 c2             	cmovne %edx,%eax
}
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	57                   	push   %edi
  801031:	56                   	push   %esi
  801032:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801033:	b8 00 00 00 00       	mov    $0x0,%eax
  801038:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103b:	8b 55 08             	mov    0x8(%ebp),%edx
  80103e:	89 c3                	mov    %eax,%ebx
  801040:	89 c7                	mov    %eax,%edi
  801042:	89 c6                	mov    %eax,%esi
  801044:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801046:	5b                   	pop    %ebx
  801047:	5e                   	pop    %esi
  801048:	5f                   	pop    %edi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <sys_cgetc>:

int
sys_cgetc(void)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801051:	ba 00 00 00 00       	mov    $0x0,%edx
  801056:	b8 01 00 00 00       	mov    $0x1,%eax
  80105b:	89 d1                	mov    %edx,%ecx
  80105d:	89 d3                	mov    %edx,%ebx
  80105f:	89 d7                	mov    %edx,%edi
  801061:	89 d6                	mov    %edx,%esi
  801063:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	57                   	push   %edi
  80106e:	56                   	push   %esi
  80106f:	53                   	push   %ebx
  801070:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801073:	b9 00 00 00 00       	mov    $0x0,%ecx
  801078:	b8 03 00 00 00       	mov    $0x3,%eax
  80107d:	8b 55 08             	mov    0x8(%ebp),%edx
  801080:	89 cb                	mov    %ecx,%ebx
  801082:	89 cf                	mov    %ecx,%edi
  801084:	89 ce                	mov    %ecx,%esi
  801086:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801088:	85 c0                	test   %eax,%eax
  80108a:	7e 17                	jle    8010a3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	50                   	push   %eax
  801090:	6a 03                	push   $0x3
  801092:	68 df 2a 80 00       	push   $0x802adf
  801097:	6a 23                	push   $0x23
  801099:	68 fc 2a 80 00       	push   $0x802afc
  80109e:	e8 e5 f5 ff ff       	call   800688 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	57                   	push   %edi
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b6:	b8 02 00 00 00       	mov    $0x2,%eax
  8010bb:	89 d1                	mov    %edx,%ecx
  8010bd:	89 d3                	mov    %edx,%ebx
  8010bf:	89 d7                	mov    %edx,%edi
  8010c1:	89 d6                	mov    %edx,%esi
  8010c3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sys_yield>:

void
sys_yield(void)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010da:	89 d1                	mov    %edx,%ecx
  8010dc:	89 d3                	mov    %edx,%ebx
  8010de:	89 d7                	mov    %edx,%edi
  8010e0:	89 d6                	mov    %edx,%esi
  8010e2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f2:	be 00 00 00 00       	mov    $0x0,%esi
  8010f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8010fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801102:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801105:	89 f7                	mov    %esi,%edi
  801107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801109:	85 c0                	test   %eax,%eax
  80110b:	7e 17                	jle    801124 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	50                   	push   %eax
  801111:	6a 04                	push   $0x4
  801113:	68 df 2a 80 00       	push   $0x802adf
  801118:	6a 23                	push   $0x23
  80111a:	68 fc 2a 80 00       	push   $0x802afc
  80111f:	e8 64 f5 ff ff       	call   800688 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	57                   	push   %edi
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
  801132:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801135:	b8 05 00 00 00       	mov    $0x5,%eax
  80113a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113d:	8b 55 08             	mov    0x8(%ebp),%edx
  801140:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801143:	8b 7d 14             	mov    0x14(%ebp),%edi
  801146:	8b 75 18             	mov    0x18(%ebp),%esi
  801149:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80114b:	85 c0                	test   %eax,%eax
  80114d:	7e 17                	jle    801166 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	50                   	push   %eax
  801153:	6a 05                	push   $0x5
  801155:	68 df 2a 80 00       	push   $0x802adf
  80115a:	6a 23                	push   $0x23
  80115c:	68 fc 2a 80 00       	push   $0x802afc
  801161:	e8 22 f5 ff ff       	call   800688 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801177:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117c:	b8 06 00 00 00       	mov    $0x6,%eax
  801181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801184:	8b 55 08             	mov    0x8(%ebp),%edx
  801187:	89 df                	mov    %ebx,%edi
  801189:	89 de                	mov    %ebx,%esi
  80118b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80118d:	85 c0                	test   %eax,%eax
  80118f:	7e 17                	jle    8011a8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801191:	83 ec 0c             	sub    $0xc,%esp
  801194:	50                   	push   %eax
  801195:	6a 06                	push   $0x6
  801197:	68 df 2a 80 00       	push   $0x802adf
  80119c:	6a 23                	push   $0x23
  80119e:	68 fc 2a 80 00       	push   $0x802afc
  8011a3:	e8 e0 f4 ff ff       	call   800688 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5f                   	pop    %edi
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	57                   	push   %edi
  8011b4:	56                   	push   %esi
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011be:	b8 08 00 00 00       	mov    $0x8,%eax
  8011c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c9:	89 df                	mov    %ebx,%edi
  8011cb:	89 de                	mov    %ebx,%esi
  8011cd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	7e 17                	jle    8011ea <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d3:	83 ec 0c             	sub    $0xc,%esp
  8011d6:	50                   	push   %eax
  8011d7:	6a 08                	push   $0x8
  8011d9:	68 df 2a 80 00       	push   $0x802adf
  8011de:	6a 23                	push   $0x23
  8011e0:	68 fc 2a 80 00       	push   $0x802afc
  8011e5:	e8 9e f4 ff ff       	call   800688 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	57                   	push   %edi
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801200:	b8 09 00 00 00       	mov    $0x9,%eax
  801205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801208:	8b 55 08             	mov    0x8(%ebp),%edx
  80120b:	89 df                	mov    %ebx,%edi
  80120d:	89 de                	mov    %ebx,%esi
  80120f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801211:	85 c0                	test   %eax,%eax
  801213:	7e 17                	jle    80122c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801215:	83 ec 0c             	sub    $0xc,%esp
  801218:	50                   	push   %eax
  801219:	6a 09                	push   $0x9
  80121b:	68 df 2a 80 00       	push   $0x802adf
  801220:	6a 23                	push   $0x23
  801222:	68 fc 2a 80 00       	push   $0x802afc
  801227:	e8 5c f4 ff ff       	call   800688 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80122c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5f                   	pop    %edi
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	57                   	push   %edi
  801238:	56                   	push   %esi
  801239:	53                   	push   %ebx
  80123a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80123d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801242:	b8 0a 00 00 00       	mov    $0xa,%eax
  801247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124a:	8b 55 08             	mov    0x8(%ebp),%edx
  80124d:	89 df                	mov    %ebx,%edi
  80124f:	89 de                	mov    %ebx,%esi
  801251:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801253:	85 c0                	test   %eax,%eax
  801255:	7e 17                	jle    80126e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801257:	83 ec 0c             	sub    $0xc,%esp
  80125a:	50                   	push   %eax
  80125b:	6a 0a                	push   $0xa
  80125d:	68 df 2a 80 00       	push   $0x802adf
  801262:	6a 23                	push   $0x23
  801264:	68 fc 2a 80 00       	push   $0x802afc
  801269:	e8 1a f4 ff ff       	call   800688 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80126e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801271:	5b                   	pop    %ebx
  801272:	5e                   	pop    %esi
  801273:	5f                   	pop    %edi
  801274:	5d                   	pop    %ebp
  801275:	c3                   	ret    

00801276 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	57                   	push   %edi
  80127a:	56                   	push   %esi
  80127b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127c:	be 00 00 00 00       	mov    $0x0,%esi
  801281:	b8 0c 00 00 00       	mov    $0xc,%eax
  801286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801289:	8b 55 08             	mov    0x8(%ebp),%edx
  80128c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801292:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5f                   	pop    %edi
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	57                   	push   %edi
  80129d:	56                   	push   %esi
  80129e:	53                   	push   %ebx
  80129f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8012af:	89 cb                	mov    %ecx,%ebx
  8012b1:	89 cf                	mov    %ecx,%edi
  8012b3:	89 ce                	mov    %ecx,%esi
  8012b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	7e 17                	jle    8012d2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	50                   	push   %eax
  8012bf:	6a 0d                	push   $0xd
  8012c1:	68 df 2a 80 00       	push   $0x802adf
  8012c6:	6a 23                	push   $0x23
  8012c8:	68 fc 2a 80 00       	push   $0x802afc
  8012cd:	e8 b6 f3 ff ff       	call   800688 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	56                   	push   %esi
  8012de:	53                   	push   %ebx
  8012df:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  8012e8:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  8012ea:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8012ef:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  8012f2:	83 ec 0c             	sub    $0xc,%esp
  8012f5:	50                   	push   %eax
  8012f6:	e8 9e ff ff ff       	call   801299 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 0e                	js     801310 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801302:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801308:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  80130b:	8b 52 78             	mov    0x78(%edx),%edx
  80130e:	eb 0a                	jmp    80131a <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801310:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801315:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  80131a:	85 f6                	test   %esi,%esi
  80131c:	74 02                	je     801320 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  80131e:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801320:	85 db                	test   %ebx,%ebx
  801322:	74 02                	je     801326 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801324:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801326:	85 c0                	test   %eax,%eax
  801328:	78 08                	js     801332 <ipc_recv+0x58>
  80132a:	a1 04 40 80 00       	mov    0x804004,%eax
  80132f:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801332:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    

00801339 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	57                   	push   %edi
  80133d:	56                   	push   %esi
  80133e:	53                   	push   %ebx
  80133f:	83 ec 0c             	sub    $0xc,%esp
  801342:	8b 7d 08             	mov    0x8(%ebp),%edi
  801345:	8b 75 0c             	mov    0xc(%ebp),%esi
  801348:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  80134b:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  80134d:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801352:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801355:	ff 75 14             	pushl  0x14(%ebp)
  801358:	53                   	push   %ebx
  801359:	56                   	push   %esi
  80135a:	57                   	push   %edi
  80135b:	e8 16 ff ff ff       	call   801276 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801366:	75 07                	jne    80136f <ipc_send+0x36>
				    sys_yield();
  801368:	e8 5d fd ff ff       	call   8010ca <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  80136d:	eb e6                	jmp    801355 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  80136f:	85 c0                	test   %eax,%eax
  801371:	74 12                	je     801385 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801373:	50                   	push   %eax
  801374:	68 0a 2b 80 00       	push   $0x802b0a
  801379:	6a 4b                	push   $0x4b
  80137b:	68 1e 2b 80 00       	push   $0x802b1e
  801380:	e8 03 f3 ff ff       	call   800688 <_panic>
			 }
	   }
}
  801385:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801388:	5b                   	pop    %ebx
  801389:	5e                   	pop    %esi
  80138a:	5f                   	pop    %edi
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801393:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801398:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80139b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013a1:	8b 52 50             	mov    0x50(%edx),%edx
  8013a4:	39 ca                	cmp    %ecx,%edx
  8013a6:	75 0d                	jne    8013b5 <ipc_find_env+0x28>
				    return envs[i].env_id;
  8013a8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013ab:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013b0:	8b 40 48             	mov    0x48(%eax),%eax
  8013b3:	eb 0f                	jmp    8013c4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  8013b5:	83 c0 01             	add    $0x1,%eax
  8013b8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013bd:	75 d9                	jne    801398 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  8013bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    

008013c6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cc:	05 00 00 00 30       	add    $0x30000000,%eax
  8013d1:	c1 e8 0c             	shr    $0xc,%eax
}
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013dc:	05 00 00 00 30       	add    $0x30000000,%eax
  8013e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013e6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013f8:	89 c2                	mov    %eax,%edx
  8013fa:	c1 ea 16             	shr    $0x16,%edx
  8013fd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801404:	f6 c2 01             	test   $0x1,%dl
  801407:	74 11                	je     80141a <fd_alloc+0x2d>
  801409:	89 c2                	mov    %eax,%edx
  80140b:	c1 ea 0c             	shr    $0xc,%edx
  80140e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801415:	f6 c2 01             	test   $0x1,%dl
  801418:	75 09                	jne    801423 <fd_alloc+0x36>
			*fd_store = fd;
  80141a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80141c:	b8 00 00 00 00       	mov    $0x0,%eax
  801421:	eb 17                	jmp    80143a <fd_alloc+0x4d>
  801423:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801428:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80142d:	75 c9                	jne    8013f8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80142f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801435:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801442:	83 f8 1f             	cmp    $0x1f,%eax
  801445:	77 36                	ja     80147d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801447:	c1 e0 0c             	shl    $0xc,%eax
  80144a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80144f:	89 c2                	mov    %eax,%edx
  801451:	c1 ea 16             	shr    $0x16,%edx
  801454:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80145b:	f6 c2 01             	test   $0x1,%dl
  80145e:	74 24                	je     801484 <fd_lookup+0x48>
  801460:	89 c2                	mov    %eax,%edx
  801462:	c1 ea 0c             	shr    $0xc,%edx
  801465:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80146c:	f6 c2 01             	test   $0x1,%dl
  80146f:	74 1a                	je     80148b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801471:	8b 55 0c             	mov    0xc(%ebp),%edx
  801474:	89 02                	mov    %eax,(%edx)
	return 0;
  801476:	b8 00 00 00 00       	mov    $0x0,%eax
  80147b:	eb 13                	jmp    801490 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80147d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801482:	eb 0c                	jmp    801490 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801484:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801489:	eb 05                	jmp    801490 <fd_lookup+0x54>
  80148b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	83 ec 08             	sub    $0x8,%esp
  801498:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80149b:	ba a8 2b 80 00       	mov    $0x802ba8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014a0:	eb 13                	jmp    8014b5 <dev_lookup+0x23>
  8014a2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014a5:	39 08                	cmp    %ecx,(%eax)
  8014a7:	75 0c                	jne    8014b5 <dev_lookup+0x23>
			*dev = devtab[i];
  8014a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ac:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b3:	eb 2e                	jmp    8014e3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014b5:	8b 02                	mov    (%edx),%eax
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	75 e7                	jne    8014a2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8014c0:	8b 40 48             	mov    0x48(%eax),%eax
  8014c3:	83 ec 04             	sub    $0x4,%esp
  8014c6:	51                   	push   %ecx
  8014c7:	50                   	push   %eax
  8014c8:	68 28 2b 80 00       	push   $0x802b28
  8014cd:	e8 8f f2 ff ff       	call   800761 <cprintf>
	*dev = 0;
  8014d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	56                   	push   %esi
  8014e9:	53                   	push   %ebx
  8014ea:	83 ec 10             	sub    $0x10,%esp
  8014ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f6:	50                   	push   %eax
  8014f7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014fd:	c1 e8 0c             	shr    $0xc,%eax
  801500:	50                   	push   %eax
  801501:	e8 36 ff ff ff       	call   80143c <fd_lookup>
  801506:	83 c4 08             	add    $0x8,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 05                	js     801512 <fd_close+0x2d>
	    || fd != fd2)
  80150d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801510:	74 0c                	je     80151e <fd_close+0x39>
		return (must_exist ? r : 0);
  801512:	84 db                	test   %bl,%bl
  801514:	ba 00 00 00 00       	mov    $0x0,%edx
  801519:	0f 44 c2             	cmove  %edx,%eax
  80151c:	eb 41                	jmp    80155f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80151e:	83 ec 08             	sub    $0x8,%esp
  801521:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801524:	50                   	push   %eax
  801525:	ff 36                	pushl  (%esi)
  801527:	e8 66 ff ff ff       	call   801492 <dev_lookup>
  80152c:	89 c3                	mov    %eax,%ebx
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	85 c0                	test   %eax,%eax
  801533:	78 1a                	js     80154f <fd_close+0x6a>
		if (dev->dev_close)
  801535:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801538:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80153b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801540:	85 c0                	test   %eax,%eax
  801542:	74 0b                	je     80154f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801544:	83 ec 0c             	sub    $0xc,%esp
  801547:	56                   	push   %esi
  801548:	ff d0                	call   *%eax
  80154a:	89 c3                	mov    %eax,%ebx
  80154c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	56                   	push   %esi
  801553:	6a 00                	push   $0x0
  801555:	e8 14 fc ff ff       	call   80116e <sys_page_unmap>
	return r;
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	89 d8                	mov    %ebx,%eax
}
  80155f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801562:	5b                   	pop    %ebx
  801563:	5e                   	pop    %esi
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80156c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156f:	50                   	push   %eax
  801570:	ff 75 08             	pushl  0x8(%ebp)
  801573:	e8 c4 fe ff ff       	call   80143c <fd_lookup>
  801578:	83 c4 08             	add    $0x8,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 10                	js     80158f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	6a 01                	push   $0x1
  801584:	ff 75 f4             	pushl  -0xc(%ebp)
  801587:	e8 59 ff ff ff       	call   8014e5 <fd_close>
  80158c:	83 c4 10             	add    $0x10,%esp
}
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <close_all>:

void
close_all(void)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	53                   	push   %ebx
  801595:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801598:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80159d:	83 ec 0c             	sub    $0xc,%esp
  8015a0:	53                   	push   %ebx
  8015a1:	e8 c0 ff ff ff       	call   801566 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015a6:	83 c3 01             	add    $0x1,%ebx
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	83 fb 20             	cmp    $0x20,%ebx
  8015af:	75 ec                	jne    80159d <close_all+0xc>
		close(i);
}
  8015b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	57                   	push   %edi
  8015ba:	56                   	push   %esi
  8015bb:	53                   	push   %ebx
  8015bc:	83 ec 2c             	sub    $0x2c,%esp
  8015bf:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	ff 75 08             	pushl  0x8(%ebp)
  8015c9:	e8 6e fe ff ff       	call   80143c <fd_lookup>
  8015ce:	83 c4 08             	add    $0x8,%esp
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	0f 88 c1 00 00 00    	js     80169a <dup+0xe4>
		return r;
	close(newfdnum);
  8015d9:	83 ec 0c             	sub    $0xc,%esp
  8015dc:	56                   	push   %esi
  8015dd:	e8 84 ff ff ff       	call   801566 <close>

	newfd = INDEX2FD(newfdnum);
  8015e2:	89 f3                	mov    %esi,%ebx
  8015e4:	c1 e3 0c             	shl    $0xc,%ebx
  8015e7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015ed:	83 c4 04             	add    $0x4,%esp
  8015f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f3:	e8 de fd ff ff       	call   8013d6 <fd2data>
  8015f8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015fa:	89 1c 24             	mov    %ebx,(%esp)
  8015fd:	e8 d4 fd ff ff       	call   8013d6 <fd2data>
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801608:	89 f8                	mov    %edi,%eax
  80160a:	c1 e8 16             	shr    $0x16,%eax
  80160d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801614:	a8 01                	test   $0x1,%al
  801616:	74 37                	je     80164f <dup+0x99>
  801618:	89 f8                	mov    %edi,%eax
  80161a:	c1 e8 0c             	shr    $0xc,%eax
  80161d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801624:	f6 c2 01             	test   $0x1,%dl
  801627:	74 26                	je     80164f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801629:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801630:	83 ec 0c             	sub    $0xc,%esp
  801633:	25 07 0e 00 00       	and    $0xe07,%eax
  801638:	50                   	push   %eax
  801639:	ff 75 d4             	pushl  -0x2c(%ebp)
  80163c:	6a 00                	push   $0x0
  80163e:	57                   	push   %edi
  80163f:	6a 00                	push   $0x0
  801641:	e8 e6 fa ff ff       	call   80112c <sys_page_map>
  801646:	89 c7                	mov    %eax,%edi
  801648:	83 c4 20             	add    $0x20,%esp
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 2e                	js     80167d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80164f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801652:	89 d0                	mov    %edx,%eax
  801654:	c1 e8 0c             	shr    $0xc,%eax
  801657:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80165e:	83 ec 0c             	sub    $0xc,%esp
  801661:	25 07 0e 00 00       	and    $0xe07,%eax
  801666:	50                   	push   %eax
  801667:	53                   	push   %ebx
  801668:	6a 00                	push   $0x0
  80166a:	52                   	push   %edx
  80166b:	6a 00                	push   $0x0
  80166d:	e8 ba fa ff ff       	call   80112c <sys_page_map>
  801672:	89 c7                	mov    %eax,%edi
  801674:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801677:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801679:	85 ff                	test   %edi,%edi
  80167b:	79 1d                	jns    80169a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80167d:	83 ec 08             	sub    $0x8,%esp
  801680:	53                   	push   %ebx
  801681:	6a 00                	push   $0x0
  801683:	e8 e6 fa ff ff       	call   80116e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801688:	83 c4 08             	add    $0x8,%esp
  80168b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80168e:	6a 00                	push   $0x0
  801690:	e8 d9 fa ff ff       	call   80116e <sys_page_unmap>
	return r;
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	89 f8                	mov    %edi,%eax
}
  80169a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169d:	5b                   	pop    %ebx
  80169e:	5e                   	pop    %esi
  80169f:	5f                   	pop    %edi
  8016a0:	5d                   	pop    %ebp
  8016a1:	c3                   	ret    

008016a2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	53                   	push   %ebx
  8016a6:	83 ec 14             	sub    $0x14,%esp
  8016a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	53                   	push   %ebx
  8016b1:	e8 86 fd ff ff       	call   80143c <fd_lookup>
  8016b6:	83 c4 08             	add    $0x8,%esp
  8016b9:	89 c2                	mov    %eax,%edx
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 6d                	js     80172c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bf:	83 ec 08             	sub    $0x8,%esp
  8016c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c5:	50                   	push   %eax
  8016c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c9:	ff 30                	pushl  (%eax)
  8016cb:	e8 c2 fd ff ff       	call   801492 <dev_lookup>
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	78 4c                	js     801723 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016da:	8b 42 08             	mov    0x8(%edx),%eax
  8016dd:	83 e0 03             	and    $0x3,%eax
  8016e0:	83 f8 01             	cmp    $0x1,%eax
  8016e3:	75 21                	jne    801706 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016e5:	a1 04 40 80 00       	mov    0x804004,%eax
  8016ea:	8b 40 48             	mov    0x48(%eax),%eax
  8016ed:	83 ec 04             	sub    $0x4,%esp
  8016f0:	53                   	push   %ebx
  8016f1:	50                   	push   %eax
  8016f2:	68 6c 2b 80 00       	push   $0x802b6c
  8016f7:	e8 65 f0 ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801704:	eb 26                	jmp    80172c <read+0x8a>
	}
	if (!dev->dev_read)
  801706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801709:	8b 40 08             	mov    0x8(%eax),%eax
  80170c:	85 c0                	test   %eax,%eax
  80170e:	74 17                	je     801727 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801710:	83 ec 04             	sub    $0x4,%esp
  801713:	ff 75 10             	pushl  0x10(%ebp)
  801716:	ff 75 0c             	pushl  0xc(%ebp)
  801719:	52                   	push   %edx
  80171a:	ff d0                	call   *%eax
  80171c:	89 c2                	mov    %eax,%edx
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	eb 09                	jmp    80172c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801723:	89 c2                	mov    %eax,%edx
  801725:	eb 05                	jmp    80172c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801727:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80172c:	89 d0                	mov    %edx,%eax
  80172e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801731:	c9                   	leave  
  801732:	c3                   	ret    

00801733 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	57                   	push   %edi
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
  801739:	83 ec 0c             	sub    $0xc,%esp
  80173c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80173f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801742:	bb 00 00 00 00       	mov    $0x0,%ebx
  801747:	eb 21                	jmp    80176a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801749:	83 ec 04             	sub    $0x4,%esp
  80174c:	89 f0                	mov    %esi,%eax
  80174e:	29 d8                	sub    %ebx,%eax
  801750:	50                   	push   %eax
  801751:	89 d8                	mov    %ebx,%eax
  801753:	03 45 0c             	add    0xc(%ebp),%eax
  801756:	50                   	push   %eax
  801757:	57                   	push   %edi
  801758:	e8 45 ff ff ff       	call   8016a2 <read>
		if (m < 0)
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	85 c0                	test   %eax,%eax
  801762:	78 10                	js     801774 <readn+0x41>
			return m;
		if (m == 0)
  801764:	85 c0                	test   %eax,%eax
  801766:	74 0a                	je     801772 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801768:	01 c3                	add    %eax,%ebx
  80176a:	39 f3                	cmp    %esi,%ebx
  80176c:	72 db                	jb     801749 <readn+0x16>
  80176e:	89 d8                	mov    %ebx,%eax
  801770:	eb 02                	jmp    801774 <readn+0x41>
  801772:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801774:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801777:	5b                   	pop    %ebx
  801778:	5e                   	pop    %esi
  801779:	5f                   	pop    %edi
  80177a:	5d                   	pop    %ebp
  80177b:	c3                   	ret    

0080177c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	53                   	push   %ebx
  801780:	83 ec 14             	sub    $0x14,%esp
  801783:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801786:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801789:	50                   	push   %eax
  80178a:	53                   	push   %ebx
  80178b:	e8 ac fc ff ff       	call   80143c <fd_lookup>
  801790:	83 c4 08             	add    $0x8,%esp
  801793:	89 c2                	mov    %eax,%edx
  801795:	85 c0                	test   %eax,%eax
  801797:	78 68                	js     801801 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801799:	83 ec 08             	sub    $0x8,%esp
  80179c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179f:	50                   	push   %eax
  8017a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a3:	ff 30                	pushl  (%eax)
  8017a5:	e8 e8 fc ff ff       	call   801492 <dev_lookup>
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 47                	js     8017f8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b8:	75 21                	jne    8017db <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8017bf:	8b 40 48             	mov    0x48(%eax),%eax
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	53                   	push   %ebx
  8017c6:	50                   	push   %eax
  8017c7:	68 88 2b 80 00       	push   $0x802b88
  8017cc:	e8 90 ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  8017d1:	83 c4 10             	add    $0x10,%esp
  8017d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017d9:	eb 26                	jmp    801801 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017de:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e1:	85 d2                	test   %edx,%edx
  8017e3:	74 17                	je     8017fc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017e5:	83 ec 04             	sub    $0x4,%esp
  8017e8:	ff 75 10             	pushl  0x10(%ebp)
  8017eb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ee:	50                   	push   %eax
  8017ef:	ff d2                	call   *%edx
  8017f1:	89 c2                	mov    %eax,%edx
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	eb 09                	jmp    801801 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f8:	89 c2                	mov    %eax,%edx
  8017fa:	eb 05                	jmp    801801 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801801:	89 d0                	mov    %edx,%eax
  801803:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801806:	c9                   	leave  
  801807:	c3                   	ret    

00801808 <seek>:

int
seek(int fdnum, off_t offset)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80180e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801811:	50                   	push   %eax
  801812:	ff 75 08             	pushl  0x8(%ebp)
  801815:	e8 22 fc ff ff       	call   80143c <fd_lookup>
  80181a:	83 c4 08             	add    $0x8,%esp
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 0e                	js     80182f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801821:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801824:	8b 55 0c             	mov    0xc(%ebp),%edx
  801827:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80182a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182f:	c9                   	leave  
  801830:	c3                   	ret    

00801831 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	53                   	push   %ebx
  801835:	83 ec 14             	sub    $0x14,%esp
  801838:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80183b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183e:	50                   	push   %eax
  80183f:	53                   	push   %ebx
  801840:	e8 f7 fb ff ff       	call   80143c <fd_lookup>
  801845:	83 c4 08             	add    $0x8,%esp
  801848:	89 c2                	mov    %eax,%edx
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 65                	js     8018b3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184e:	83 ec 08             	sub    $0x8,%esp
  801851:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801854:	50                   	push   %eax
  801855:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801858:	ff 30                	pushl  (%eax)
  80185a:	e8 33 fc ff ff       	call   801492 <dev_lookup>
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	78 44                	js     8018aa <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801869:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80186d:	75 21                	jne    801890 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80186f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801874:	8b 40 48             	mov    0x48(%eax),%eax
  801877:	83 ec 04             	sub    $0x4,%esp
  80187a:	53                   	push   %ebx
  80187b:	50                   	push   %eax
  80187c:	68 48 2b 80 00       	push   $0x802b48
  801881:	e8 db ee ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80188e:	eb 23                	jmp    8018b3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801890:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801893:	8b 52 18             	mov    0x18(%edx),%edx
  801896:	85 d2                	test   %edx,%edx
  801898:	74 14                	je     8018ae <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80189a:	83 ec 08             	sub    $0x8,%esp
  80189d:	ff 75 0c             	pushl  0xc(%ebp)
  8018a0:	50                   	push   %eax
  8018a1:	ff d2                	call   *%edx
  8018a3:	89 c2                	mov    %eax,%edx
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	eb 09                	jmp    8018b3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018aa:	89 c2                	mov    %eax,%edx
  8018ac:	eb 05                	jmp    8018b3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018b3:	89 d0                	mov    %edx,%eax
  8018b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b8:	c9                   	leave  
  8018b9:	c3                   	ret    

008018ba <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	53                   	push   %ebx
  8018be:	83 ec 14             	sub    $0x14,%esp
  8018c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c7:	50                   	push   %eax
  8018c8:	ff 75 08             	pushl  0x8(%ebp)
  8018cb:	e8 6c fb ff ff       	call   80143c <fd_lookup>
  8018d0:	83 c4 08             	add    $0x8,%esp
  8018d3:	89 c2                	mov    %eax,%edx
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	78 58                	js     801931 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d9:	83 ec 08             	sub    $0x8,%esp
  8018dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018df:	50                   	push   %eax
  8018e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e3:	ff 30                	pushl  (%eax)
  8018e5:	e8 a8 fb ff ff       	call   801492 <dev_lookup>
  8018ea:	83 c4 10             	add    $0x10,%esp
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 37                	js     801928 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018f8:	74 32                	je     80192c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018fa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018fd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801904:	00 00 00 
	stat->st_isdir = 0;
  801907:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80190e:	00 00 00 
	stat->st_dev = dev;
  801911:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	53                   	push   %ebx
  80191b:	ff 75 f0             	pushl  -0x10(%ebp)
  80191e:	ff 50 14             	call   *0x14(%eax)
  801921:	89 c2                	mov    %eax,%edx
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	eb 09                	jmp    801931 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801928:	89 c2                	mov    %eax,%edx
  80192a:	eb 05                	jmp    801931 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80192c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801931:	89 d0                	mov    %edx,%eax
  801933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	56                   	push   %esi
  80193c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80193d:	83 ec 08             	sub    $0x8,%esp
  801940:	6a 00                	push   $0x0
  801942:	ff 75 08             	pushl  0x8(%ebp)
  801945:	e8 2c 02 00 00       	call   801b76 <open>
  80194a:	89 c3                	mov    %eax,%ebx
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 1b                	js     80196e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801953:	83 ec 08             	sub    $0x8,%esp
  801956:	ff 75 0c             	pushl  0xc(%ebp)
  801959:	50                   	push   %eax
  80195a:	e8 5b ff ff ff       	call   8018ba <fstat>
  80195f:	89 c6                	mov    %eax,%esi
	close(fd);
  801961:	89 1c 24             	mov    %ebx,(%esp)
  801964:	e8 fd fb ff ff       	call   801566 <close>
	return r;
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	89 f0                	mov    %esi,%eax
}
  80196e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801971:	5b                   	pop    %ebx
  801972:	5e                   	pop    %esi
  801973:	5d                   	pop    %ebp
  801974:	c3                   	ret    

00801975 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	56                   	push   %esi
  801979:	53                   	push   %ebx
  80197a:	89 c6                	mov    %eax,%esi
  80197c:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  80197e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801985:	75 12                	jne    801999 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	6a 01                	push   $0x1
  80198c:	e8 fc f9 ff ff       	call   80138d <ipc_find_env>
  801991:	a3 00 40 80 00       	mov    %eax,0x804000
  801996:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801999:	6a 07                	push   $0x7
  80199b:	68 00 50 80 00       	push   $0x805000
  8019a0:	56                   	push   %esi
  8019a1:	ff 35 00 40 80 00    	pushl  0x804000
  8019a7:	e8 8d f9 ff ff       	call   801339 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  8019ac:	83 c4 0c             	add    $0xc,%esp
  8019af:	6a 00                	push   $0x0
  8019b1:	53                   	push   %ebx
  8019b2:	6a 00                	push   $0x0
  8019b4:	e8 21 f9 ff ff       	call   8012da <ipc_recv>
}
  8019b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019bc:	5b                   	pop    %ebx
  8019bd:	5e                   	pop    %esi
  8019be:	5d                   	pop    %ebp
  8019bf:	c3                   	ret    

008019c0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019cc:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  8019d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d4:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  8019d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019de:	b8 02 00 00 00       	mov    $0x2,%eax
  8019e3:	e8 8d ff ff ff       	call   801975 <fsipc>
}
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f6:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  8019fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801a00:	b8 06 00 00 00       	mov    $0x6,%eax
  801a05:	e8 6b ff ff ff       	call   801975 <fsipc>
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	53                   	push   %ebx
  801a10:	83 ec 04             	sub    $0x4,%esp
  801a13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a16:	8b 45 08             	mov    0x8(%ebp),%eax
  801a19:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1c:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a21:	ba 00 00 00 00       	mov    $0x0,%edx
  801a26:	b8 05 00 00 00       	mov    $0x5,%eax
  801a2b:	e8 45 ff ff ff       	call   801975 <fsipc>
  801a30:	85 c0                	test   %eax,%eax
  801a32:	78 2c                	js     801a60 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a34:	83 ec 08             	sub    $0x8,%esp
  801a37:	68 00 50 80 00       	push   $0x805000
  801a3c:	53                   	push   %ebx
  801a3d:	e8 a4 f2 ff ff       	call   800ce6 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  801a42:	a1 80 50 80 00       	mov    0x805080,%eax
  801a47:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a4d:	a1 84 50 80 00       	mov    0x805084,%eax
  801a52:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a63:	c9                   	leave  
  801a64:	c3                   	ret    

00801a65 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	53                   	push   %ebx
  801a69:	83 ec 08             	sub    $0x8,%esp
  801a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a72:	8b 40 0c             	mov    0xc(%eax),%eax
  801a75:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  801a7a:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  801a80:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801a86:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801a8b:	0f 46 c3             	cmovbe %ebx,%eax
  801a8e:	50                   	push   %eax
  801a8f:	ff 75 0c             	pushl  0xc(%ebp)
  801a92:	68 08 50 80 00       	push   $0x805008
  801a97:	e8 dc f3 ff ff       	call   800e78 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  801a9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa1:	b8 04 00 00 00       	mov    $0x4,%eax
  801aa6:	e8 ca fe ff ff       	call   801975 <fsipc>
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 3d                	js     801aef <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  801ab2:	39 c3                	cmp    %eax,%ebx
  801ab4:	73 19                	jae    801acf <devfile_write+0x6a>
  801ab6:	68 b8 2b 80 00       	push   $0x802bb8
  801abb:	68 bf 2b 80 00       	push   $0x802bbf
  801ac0:	68 9a 00 00 00       	push   $0x9a
  801ac5:	68 d4 2b 80 00       	push   $0x802bd4
  801aca:	e8 b9 eb ff ff       	call   800688 <_panic>
	   assert (r <= bytes_written);
  801acf:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ad4:	7e 19                	jle    801aef <devfile_write+0x8a>
  801ad6:	68 df 2b 80 00       	push   $0x802bdf
  801adb:	68 bf 2b 80 00       	push   $0x802bbf
  801ae0:	68 9b 00 00 00       	push   $0x9b
  801ae5:	68 d4 2b 80 00       	push   $0x802bd4
  801aea:	e8 99 eb ff ff       	call   800688 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  801aef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af2:	c9                   	leave  
  801af3:	c3                   	ret    

00801af4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	56                   	push   %esi
  801af8:	53                   	push   %ebx
  801af9:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  801afc:	8b 45 08             	mov    0x8(%ebp),%eax
  801aff:	8b 40 0c             	mov    0xc(%eax),%eax
  801b02:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  801b07:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b12:	b8 03 00 00 00       	mov    $0x3,%eax
  801b17:	e8 59 fe ff ff       	call   801975 <fsipc>
  801b1c:	89 c3                	mov    %eax,%ebx
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 4b                	js     801b6d <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  801b22:	39 c6                	cmp    %eax,%esi
  801b24:	73 16                	jae    801b3c <devfile_read+0x48>
  801b26:	68 b8 2b 80 00       	push   $0x802bb8
  801b2b:	68 bf 2b 80 00       	push   $0x802bbf
  801b30:	6a 7c                	push   $0x7c
  801b32:	68 d4 2b 80 00       	push   $0x802bd4
  801b37:	e8 4c eb ff ff       	call   800688 <_panic>
	   assert(r <= PGSIZE);
  801b3c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b41:	7e 16                	jle    801b59 <devfile_read+0x65>
  801b43:	68 f2 2b 80 00       	push   $0x802bf2
  801b48:	68 bf 2b 80 00       	push   $0x802bbf
  801b4d:	6a 7d                	push   $0x7d
  801b4f:	68 d4 2b 80 00       	push   $0x802bd4
  801b54:	e8 2f eb ff ff       	call   800688 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b59:	83 ec 04             	sub    $0x4,%esp
  801b5c:	50                   	push   %eax
  801b5d:	68 00 50 80 00       	push   $0x805000
  801b62:	ff 75 0c             	pushl  0xc(%ebp)
  801b65:	e8 0e f3 ff ff       	call   800e78 <memmove>
	   return r;
  801b6a:	83 c4 10             	add    $0x10,%esp
}
  801b6d:	89 d8                	mov    %ebx,%eax
  801b6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b72:	5b                   	pop    %ebx
  801b73:	5e                   	pop    %esi
  801b74:	5d                   	pop    %ebp
  801b75:	c3                   	ret    

00801b76 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	53                   	push   %ebx
  801b7a:	83 ec 20             	sub    $0x20,%esp
  801b7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  801b80:	53                   	push   %ebx
  801b81:	e8 27 f1 ff ff       	call   800cad <strlen>
  801b86:	83 c4 10             	add    $0x10,%esp
  801b89:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b8e:	7f 67                	jg     801bf7 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801b90:	83 ec 0c             	sub    $0xc,%esp
  801b93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b96:	50                   	push   %eax
  801b97:	e8 51 f8 ff ff       	call   8013ed <fd_alloc>
  801b9c:	83 c4 10             	add    $0x10,%esp
			 return r;
  801b9f:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 57                	js     801bfc <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  801ba5:	83 ec 08             	sub    $0x8,%esp
  801ba8:	53                   	push   %ebx
  801ba9:	68 00 50 80 00       	push   $0x805000
  801bae:	e8 33 f1 ff ff       	call   800ce6 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  801bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb6:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bbe:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc3:	e8 ad fd ff ff       	call   801975 <fsipc>
  801bc8:	89 c3                	mov    %eax,%ebx
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	79 14                	jns    801be5 <open+0x6f>
			 fd_close(fd, 0);
  801bd1:	83 ec 08             	sub    $0x8,%esp
  801bd4:	6a 00                	push   $0x0
  801bd6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd9:	e8 07 f9 ff ff       	call   8014e5 <fd_close>
			 return r;
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	89 da                	mov    %ebx,%edx
  801be3:	eb 17                	jmp    801bfc <open+0x86>
	   }

	   return fd2num(fd);
  801be5:	83 ec 0c             	sub    $0xc,%esp
  801be8:	ff 75 f4             	pushl  -0xc(%ebp)
  801beb:	e8 d6 f7 ff ff       	call   8013c6 <fd2num>
  801bf0:	89 c2                	mov    %eax,%edx
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	eb 05                	jmp    801bfc <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  801bf7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801bfc:	89 d0                	mov    %edx,%eax
  801bfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c01:	c9                   	leave  
  801c02:	c3                   	ret    

00801c03 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801c09:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0e:	b8 08 00 00 00       	mov    $0x8,%eax
  801c13:	e8 5d fd ff ff       	call   801975 <fsipc>
}
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    

00801c1a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	56                   	push   %esi
  801c1e:	53                   	push   %ebx
  801c1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c22:	83 ec 0c             	sub    $0xc,%esp
  801c25:	ff 75 08             	pushl  0x8(%ebp)
  801c28:	e8 a9 f7 ff ff       	call   8013d6 <fd2data>
  801c2d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c2f:	83 c4 08             	add    $0x8,%esp
  801c32:	68 fe 2b 80 00       	push   $0x802bfe
  801c37:	53                   	push   %ebx
  801c38:	e8 a9 f0 ff ff       	call   800ce6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c3d:	8b 46 04             	mov    0x4(%esi),%eax
  801c40:	2b 06                	sub    (%esi),%eax
  801c42:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c48:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c4f:	00 00 00 
	stat->st_dev = &devpipe;
  801c52:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801c59:	30 80 00 
	return 0;
}
  801c5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    

00801c68 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	53                   	push   %ebx
  801c6c:	83 ec 0c             	sub    $0xc,%esp
  801c6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c72:	53                   	push   %ebx
  801c73:	6a 00                	push   $0x0
  801c75:	e8 f4 f4 ff ff       	call   80116e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c7a:	89 1c 24             	mov    %ebx,(%esp)
  801c7d:	e8 54 f7 ff ff       	call   8013d6 <fd2data>
  801c82:	83 c4 08             	add    $0x8,%esp
  801c85:	50                   	push   %eax
  801c86:	6a 00                	push   $0x0
  801c88:	e8 e1 f4 ff ff       	call   80116e <sys_page_unmap>
}
  801c8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c90:	c9                   	leave  
  801c91:	c3                   	ret    

00801c92 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	57                   	push   %edi
  801c96:	56                   	push   %esi
  801c97:	53                   	push   %ebx
  801c98:	83 ec 1c             	sub    $0x1c,%esp
  801c9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c9e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ca0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ca5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ca8:	83 ec 0c             	sub    $0xc,%esp
  801cab:	ff 75 e0             	pushl  -0x20(%ebp)
  801cae:	e8 46 04 00 00       	call   8020f9 <pageref>
  801cb3:	89 c3                	mov    %eax,%ebx
  801cb5:	89 3c 24             	mov    %edi,(%esp)
  801cb8:	e8 3c 04 00 00       	call   8020f9 <pageref>
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	39 c3                	cmp    %eax,%ebx
  801cc2:	0f 94 c1             	sete   %cl
  801cc5:	0f b6 c9             	movzbl %cl,%ecx
  801cc8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ccb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cd1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cd4:	39 ce                	cmp    %ecx,%esi
  801cd6:	74 1b                	je     801cf3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801cd8:	39 c3                	cmp    %eax,%ebx
  801cda:	75 c4                	jne    801ca0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cdc:	8b 42 58             	mov    0x58(%edx),%eax
  801cdf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ce2:	50                   	push   %eax
  801ce3:	56                   	push   %esi
  801ce4:	68 05 2c 80 00       	push   $0x802c05
  801ce9:	e8 73 ea ff ff       	call   800761 <cprintf>
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	eb ad                	jmp    801ca0 <_pipeisclosed+0xe>
	}
}
  801cf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf9:	5b                   	pop    %ebx
  801cfa:	5e                   	pop    %esi
  801cfb:	5f                   	pop    %edi
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 28             	sub    $0x28,%esp
  801d07:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d0a:	56                   	push   %esi
  801d0b:	e8 c6 f6 ff ff       	call   8013d6 <fd2data>
  801d10:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	bf 00 00 00 00       	mov    $0x0,%edi
  801d1a:	eb 4b                	jmp    801d67 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d1c:	89 da                	mov    %ebx,%edx
  801d1e:	89 f0                	mov    %esi,%eax
  801d20:	e8 6d ff ff ff       	call   801c92 <_pipeisclosed>
  801d25:	85 c0                	test   %eax,%eax
  801d27:	75 48                	jne    801d71 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d29:	e8 9c f3 ff ff       	call   8010ca <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d2e:	8b 43 04             	mov    0x4(%ebx),%eax
  801d31:	8b 0b                	mov    (%ebx),%ecx
  801d33:	8d 51 20             	lea    0x20(%ecx),%edx
  801d36:	39 d0                	cmp    %edx,%eax
  801d38:	73 e2                	jae    801d1c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d3d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d41:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d44:	89 c2                	mov    %eax,%edx
  801d46:	c1 fa 1f             	sar    $0x1f,%edx
  801d49:	89 d1                	mov    %edx,%ecx
  801d4b:	c1 e9 1b             	shr    $0x1b,%ecx
  801d4e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d51:	83 e2 1f             	and    $0x1f,%edx
  801d54:	29 ca                	sub    %ecx,%edx
  801d56:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d5a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d5e:	83 c0 01             	add    $0x1,%eax
  801d61:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d64:	83 c7 01             	add    $0x1,%edi
  801d67:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d6a:	75 c2                	jne    801d2e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d6c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d6f:	eb 05                	jmp    801d76 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d71:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d79:	5b                   	pop    %ebx
  801d7a:	5e                   	pop    %esi
  801d7b:	5f                   	pop    %edi
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    

00801d7e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	57                   	push   %edi
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	83 ec 18             	sub    $0x18,%esp
  801d87:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d8a:	57                   	push   %edi
  801d8b:	e8 46 f6 ff ff       	call   8013d6 <fd2data>
  801d90:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d9a:	eb 3d                	jmp    801dd9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d9c:	85 db                	test   %ebx,%ebx
  801d9e:	74 04                	je     801da4 <devpipe_read+0x26>
				return i;
  801da0:	89 d8                	mov    %ebx,%eax
  801da2:	eb 44                	jmp    801de8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801da4:	89 f2                	mov    %esi,%edx
  801da6:	89 f8                	mov    %edi,%eax
  801da8:	e8 e5 fe ff ff       	call   801c92 <_pipeisclosed>
  801dad:	85 c0                	test   %eax,%eax
  801daf:	75 32                	jne    801de3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801db1:	e8 14 f3 ff ff       	call   8010ca <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801db6:	8b 06                	mov    (%esi),%eax
  801db8:	3b 46 04             	cmp    0x4(%esi),%eax
  801dbb:	74 df                	je     801d9c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dbd:	99                   	cltd   
  801dbe:	c1 ea 1b             	shr    $0x1b,%edx
  801dc1:	01 d0                	add    %edx,%eax
  801dc3:	83 e0 1f             	and    $0x1f,%eax
  801dc6:	29 d0                	sub    %edx,%eax
  801dc8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801dd3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dd6:	83 c3 01             	add    $0x1,%ebx
  801dd9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ddc:	75 d8                	jne    801db6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dde:	8b 45 10             	mov    0x10(%ebp),%eax
  801de1:	eb 05                	jmp    801de8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801de3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801deb:	5b                   	pop    %ebx
  801dec:	5e                   	pop    %esi
  801ded:	5f                   	pop    %edi
  801dee:	5d                   	pop    %ebp
  801def:	c3                   	ret    

00801df0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	56                   	push   %esi
  801df4:	53                   	push   %ebx
  801df5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801df8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfb:	50                   	push   %eax
  801dfc:	e8 ec f5 ff ff       	call   8013ed <fd_alloc>
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	89 c2                	mov    %eax,%edx
  801e06:	85 c0                	test   %eax,%eax
  801e08:	0f 88 2c 01 00 00    	js     801f3a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0e:	83 ec 04             	sub    $0x4,%esp
  801e11:	68 07 04 00 00       	push   $0x407
  801e16:	ff 75 f4             	pushl  -0xc(%ebp)
  801e19:	6a 00                	push   $0x0
  801e1b:	e8 c9 f2 ff ff       	call   8010e9 <sys_page_alloc>
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	89 c2                	mov    %eax,%edx
  801e25:	85 c0                	test   %eax,%eax
  801e27:	0f 88 0d 01 00 00    	js     801f3a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e2d:	83 ec 0c             	sub    $0xc,%esp
  801e30:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e33:	50                   	push   %eax
  801e34:	e8 b4 f5 ff ff       	call   8013ed <fd_alloc>
  801e39:	89 c3                	mov    %eax,%ebx
  801e3b:	83 c4 10             	add    $0x10,%esp
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	0f 88 e2 00 00 00    	js     801f28 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e46:	83 ec 04             	sub    $0x4,%esp
  801e49:	68 07 04 00 00       	push   $0x407
  801e4e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e51:	6a 00                	push   $0x0
  801e53:	e8 91 f2 ff ff       	call   8010e9 <sys_page_alloc>
  801e58:	89 c3                	mov    %eax,%ebx
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	0f 88 c3 00 00 00    	js     801f28 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e65:	83 ec 0c             	sub    $0xc,%esp
  801e68:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6b:	e8 66 f5 ff ff       	call   8013d6 <fd2data>
  801e70:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e72:	83 c4 0c             	add    $0xc,%esp
  801e75:	68 07 04 00 00       	push   $0x407
  801e7a:	50                   	push   %eax
  801e7b:	6a 00                	push   $0x0
  801e7d:	e8 67 f2 ff ff       	call   8010e9 <sys_page_alloc>
  801e82:	89 c3                	mov    %eax,%ebx
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	85 c0                	test   %eax,%eax
  801e89:	0f 88 89 00 00 00    	js     801f18 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	ff 75 f0             	pushl  -0x10(%ebp)
  801e95:	e8 3c f5 ff ff       	call   8013d6 <fd2data>
  801e9a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ea1:	50                   	push   %eax
  801ea2:	6a 00                	push   $0x0
  801ea4:	56                   	push   %esi
  801ea5:	6a 00                	push   $0x0
  801ea7:	e8 80 f2 ff ff       	call   80112c <sys_page_map>
  801eac:	89 c3                	mov    %eax,%ebx
  801eae:	83 c4 20             	add    $0x20,%esp
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	78 55                	js     801f0a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801eb5:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eca:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ed0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ed3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ed5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ed8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801edf:	83 ec 0c             	sub    $0xc,%esp
  801ee2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee5:	e8 dc f4 ff ff       	call   8013c6 <fd2num>
  801eea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eed:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801eef:	83 c4 04             	add    $0x4,%esp
  801ef2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ef5:	e8 cc f4 ff ff       	call   8013c6 <fd2num>
  801efa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801efd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	ba 00 00 00 00       	mov    $0x0,%edx
  801f08:	eb 30                	jmp    801f3a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f0a:	83 ec 08             	sub    $0x8,%esp
  801f0d:	56                   	push   %esi
  801f0e:	6a 00                	push   $0x0
  801f10:	e8 59 f2 ff ff       	call   80116e <sys_page_unmap>
  801f15:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f18:	83 ec 08             	sub    $0x8,%esp
  801f1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801f1e:	6a 00                	push   $0x0
  801f20:	e8 49 f2 ff ff       	call   80116e <sys_page_unmap>
  801f25:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f28:	83 ec 08             	sub    $0x8,%esp
  801f2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2e:	6a 00                	push   $0x0
  801f30:	e8 39 f2 ff ff       	call   80116e <sys_page_unmap>
  801f35:	83 c4 10             	add    $0x10,%esp
  801f38:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f3a:	89 d0                	mov    %edx,%eax
  801f3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5d                   	pop    %ebp
  801f42:	c3                   	ret    

00801f43 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4c:	50                   	push   %eax
  801f4d:	ff 75 08             	pushl  0x8(%ebp)
  801f50:	e8 e7 f4 ff ff       	call   80143c <fd_lookup>
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	78 18                	js     801f74 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f5c:	83 ec 0c             	sub    $0xc,%esp
  801f5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f62:	e8 6f f4 ff ff       	call   8013d6 <fd2data>
	return _pipeisclosed(fd, p);
  801f67:	89 c2                	mov    %eax,%edx
  801f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6c:	e8 21 fd ff ff       	call   801c92 <_pipeisclosed>
  801f71:	83 c4 10             	add    $0x10,%esp
}
  801f74:	c9                   	leave  
  801f75:	c3                   	ret    

00801f76 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f76:	55                   	push   %ebp
  801f77:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f79:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f86:	68 1d 2c 80 00       	push   $0x802c1d
  801f8b:	ff 75 0c             	pushl  0xc(%ebp)
  801f8e:	e8 53 ed ff ff       	call   800ce6 <strcpy>
	return 0;
}
  801f93:	b8 00 00 00 00       	mov    $0x0,%eax
  801f98:	c9                   	leave  
  801f99:	c3                   	ret    

00801f9a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	57                   	push   %edi
  801f9e:	56                   	push   %esi
  801f9f:	53                   	push   %ebx
  801fa0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fa6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fb1:	eb 2d                	jmp    801fe0 <devcons_write+0x46>
		m = n - tot;
  801fb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fb6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fb8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fbb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fc0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fc3:	83 ec 04             	sub    $0x4,%esp
  801fc6:	53                   	push   %ebx
  801fc7:	03 45 0c             	add    0xc(%ebp),%eax
  801fca:	50                   	push   %eax
  801fcb:	57                   	push   %edi
  801fcc:	e8 a7 ee ff ff       	call   800e78 <memmove>
		sys_cputs(buf, m);
  801fd1:	83 c4 08             	add    $0x8,%esp
  801fd4:	53                   	push   %ebx
  801fd5:	57                   	push   %edi
  801fd6:	e8 52 f0 ff ff       	call   80102d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fdb:	01 de                	add    %ebx,%esi
  801fdd:	83 c4 10             	add    $0x10,%esp
  801fe0:	89 f0                	mov    %esi,%eax
  801fe2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fe5:	72 cc                	jb     801fb3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fe7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fea:	5b                   	pop    %ebx
  801feb:	5e                   	pop    %esi
  801fec:	5f                   	pop    %edi
  801fed:	5d                   	pop    %ebp
  801fee:	c3                   	ret    

00801fef <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
  801ff2:	83 ec 08             	sub    $0x8,%esp
  801ff5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ffa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ffe:	74 2a                	je     80202a <devcons_read+0x3b>
  802000:	eb 05                	jmp    802007 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802002:	e8 c3 f0 ff ff       	call   8010ca <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802007:	e8 3f f0 ff ff       	call   80104b <sys_cgetc>
  80200c:	85 c0                	test   %eax,%eax
  80200e:	74 f2                	je     802002 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802010:	85 c0                	test   %eax,%eax
  802012:	78 16                	js     80202a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802014:	83 f8 04             	cmp    $0x4,%eax
  802017:	74 0c                	je     802025 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802019:	8b 55 0c             	mov    0xc(%ebp),%edx
  80201c:	88 02                	mov    %al,(%edx)
	return 1;
  80201e:	b8 01 00 00 00       	mov    $0x1,%eax
  802023:	eb 05                	jmp    80202a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802025:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80202a:	c9                   	leave  
  80202b:	c3                   	ret    

0080202c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802032:	8b 45 08             	mov    0x8(%ebp),%eax
  802035:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802038:	6a 01                	push   $0x1
  80203a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80203d:	50                   	push   %eax
  80203e:	e8 ea ef ff ff       	call   80102d <sys_cputs>
}
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	c9                   	leave  
  802047:	c3                   	ret    

00802048 <getchar>:

int
getchar(void)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80204e:	6a 01                	push   $0x1
  802050:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802053:	50                   	push   %eax
  802054:	6a 00                	push   $0x0
  802056:	e8 47 f6 ff ff       	call   8016a2 <read>
	if (r < 0)
  80205b:	83 c4 10             	add    $0x10,%esp
  80205e:	85 c0                	test   %eax,%eax
  802060:	78 0f                	js     802071 <getchar+0x29>
		return r;
	if (r < 1)
  802062:	85 c0                	test   %eax,%eax
  802064:	7e 06                	jle    80206c <getchar+0x24>
		return -E_EOF;
	return c;
  802066:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80206a:	eb 05                	jmp    802071 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80206c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802071:	c9                   	leave  
  802072:	c3                   	ret    

00802073 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802073:	55                   	push   %ebp
  802074:	89 e5                	mov    %esp,%ebp
  802076:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802079:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80207c:	50                   	push   %eax
  80207d:	ff 75 08             	pushl  0x8(%ebp)
  802080:	e8 b7 f3 ff ff       	call   80143c <fd_lookup>
  802085:	83 c4 10             	add    $0x10,%esp
  802088:	85 c0                	test   %eax,%eax
  80208a:	78 11                	js     80209d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80208c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208f:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802095:	39 10                	cmp    %edx,(%eax)
  802097:	0f 94 c0             	sete   %al
  80209a:	0f b6 c0             	movzbl %al,%eax
}
  80209d:	c9                   	leave  
  80209e:	c3                   	ret    

0080209f <opencons>:

int
opencons(void)
{
  80209f:	55                   	push   %ebp
  8020a0:	89 e5                	mov    %esp,%ebp
  8020a2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a8:	50                   	push   %eax
  8020a9:	e8 3f f3 ff ff       	call   8013ed <fd_alloc>
  8020ae:	83 c4 10             	add    $0x10,%esp
		return r;
  8020b1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	78 3e                	js     8020f5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020b7:	83 ec 04             	sub    $0x4,%esp
  8020ba:	68 07 04 00 00       	push   $0x407
  8020bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c2:	6a 00                	push   $0x0
  8020c4:	e8 20 f0 ff ff       	call   8010e9 <sys_page_alloc>
  8020c9:	83 c4 10             	add    $0x10,%esp
		return r;
  8020cc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020ce:	85 c0                	test   %eax,%eax
  8020d0:	78 23                	js     8020f5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020d2:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020db:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020e7:	83 ec 0c             	sub    $0xc,%esp
  8020ea:	50                   	push   %eax
  8020eb:	e8 d6 f2 ff ff       	call   8013c6 <fd2num>
  8020f0:	89 c2                	mov    %eax,%edx
  8020f2:	83 c4 10             	add    $0x10,%esp
}
  8020f5:	89 d0                	mov    %edx,%eax
  8020f7:	c9                   	leave  
  8020f8:	c3                   	ret    

008020f9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020f9:	55                   	push   %ebp
  8020fa:	89 e5                	mov    %esp,%ebp
  8020fc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ff:	89 d0                	mov    %edx,%eax
  802101:	c1 e8 16             	shr    $0x16,%eax
  802104:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80210b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802110:	f6 c1 01             	test   $0x1,%cl
  802113:	74 1d                	je     802132 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802115:	c1 ea 0c             	shr    $0xc,%edx
  802118:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80211f:	f6 c2 01             	test   $0x1,%dl
  802122:	74 0e                	je     802132 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802124:	c1 ea 0c             	shr    $0xc,%edx
  802127:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80212e:	ef 
  80212f:	0f b7 c0             	movzwl %ax,%eax
}
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    
  802134:	66 90                	xchg   %ax,%ax
  802136:	66 90                	xchg   %ax,%ax
  802138:	66 90                	xchg   %ax,%ax
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <__udivdi3>:
  802140:	55                   	push   %ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	53                   	push   %ebx
  802144:	83 ec 1c             	sub    $0x1c,%esp
  802147:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80214b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80214f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802153:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802157:	85 f6                	test   %esi,%esi
  802159:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80215d:	89 ca                	mov    %ecx,%edx
  80215f:	89 f8                	mov    %edi,%eax
  802161:	75 3d                	jne    8021a0 <__udivdi3+0x60>
  802163:	39 cf                	cmp    %ecx,%edi
  802165:	0f 87 c5 00 00 00    	ja     802230 <__udivdi3+0xf0>
  80216b:	85 ff                	test   %edi,%edi
  80216d:	89 fd                	mov    %edi,%ebp
  80216f:	75 0b                	jne    80217c <__udivdi3+0x3c>
  802171:	b8 01 00 00 00       	mov    $0x1,%eax
  802176:	31 d2                	xor    %edx,%edx
  802178:	f7 f7                	div    %edi
  80217a:	89 c5                	mov    %eax,%ebp
  80217c:	89 c8                	mov    %ecx,%eax
  80217e:	31 d2                	xor    %edx,%edx
  802180:	f7 f5                	div    %ebp
  802182:	89 c1                	mov    %eax,%ecx
  802184:	89 d8                	mov    %ebx,%eax
  802186:	89 cf                	mov    %ecx,%edi
  802188:	f7 f5                	div    %ebp
  80218a:	89 c3                	mov    %eax,%ebx
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
  8021a0:	39 ce                	cmp    %ecx,%esi
  8021a2:	77 74                	ja     802218 <__udivdi3+0xd8>
  8021a4:	0f bd fe             	bsr    %esi,%edi
  8021a7:	83 f7 1f             	xor    $0x1f,%edi
  8021aa:	0f 84 98 00 00 00    	je     802248 <__udivdi3+0x108>
  8021b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	89 c5                	mov    %eax,%ebp
  8021b9:	29 fb                	sub    %edi,%ebx
  8021bb:	d3 e6                	shl    %cl,%esi
  8021bd:	89 d9                	mov    %ebx,%ecx
  8021bf:	d3 ed                	shr    %cl,%ebp
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	d3 e0                	shl    %cl,%eax
  8021c5:	09 ee                	or     %ebp,%esi
  8021c7:	89 d9                	mov    %ebx,%ecx
  8021c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021cd:	89 d5                	mov    %edx,%ebp
  8021cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021d3:	d3 ed                	shr    %cl,%ebp
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	d3 e2                	shl    %cl,%edx
  8021d9:	89 d9                	mov    %ebx,%ecx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	09 c2                	or     %eax,%edx
  8021df:	89 d0                	mov    %edx,%eax
  8021e1:	89 ea                	mov    %ebp,%edx
  8021e3:	f7 f6                	div    %esi
  8021e5:	89 d5                	mov    %edx,%ebp
  8021e7:	89 c3                	mov    %eax,%ebx
  8021e9:	f7 64 24 0c          	mull   0xc(%esp)
  8021ed:	39 d5                	cmp    %edx,%ebp
  8021ef:	72 10                	jb     802201 <__udivdi3+0xc1>
  8021f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	d3 e6                	shl    %cl,%esi
  8021f9:	39 c6                	cmp    %eax,%esi
  8021fb:	73 07                	jae    802204 <__udivdi3+0xc4>
  8021fd:	39 d5                	cmp    %edx,%ebp
  8021ff:	75 03                	jne    802204 <__udivdi3+0xc4>
  802201:	83 eb 01             	sub    $0x1,%ebx
  802204:	31 ff                	xor    %edi,%edi
  802206:	89 d8                	mov    %ebx,%eax
  802208:	89 fa                	mov    %edi,%edx
  80220a:	83 c4 1c             	add    $0x1c,%esp
  80220d:	5b                   	pop    %ebx
  80220e:	5e                   	pop    %esi
  80220f:	5f                   	pop    %edi
  802210:	5d                   	pop    %ebp
  802211:	c3                   	ret    
  802212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802218:	31 ff                	xor    %edi,%edi
  80221a:	31 db                	xor    %ebx,%ebx
  80221c:	89 d8                	mov    %ebx,%eax
  80221e:	89 fa                	mov    %edi,%edx
  802220:	83 c4 1c             	add    $0x1c,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
  802228:	90                   	nop
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 d8                	mov    %ebx,%eax
  802232:	f7 f7                	div    %edi
  802234:	31 ff                	xor    %edi,%edi
  802236:	89 c3                	mov    %eax,%ebx
  802238:	89 d8                	mov    %ebx,%eax
  80223a:	89 fa                	mov    %edi,%edx
  80223c:	83 c4 1c             	add    $0x1c,%esp
  80223f:	5b                   	pop    %ebx
  802240:	5e                   	pop    %esi
  802241:	5f                   	pop    %edi
  802242:	5d                   	pop    %ebp
  802243:	c3                   	ret    
  802244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802248:	39 ce                	cmp    %ecx,%esi
  80224a:	72 0c                	jb     802258 <__udivdi3+0x118>
  80224c:	31 db                	xor    %ebx,%ebx
  80224e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802252:	0f 87 34 ff ff ff    	ja     80218c <__udivdi3+0x4c>
  802258:	bb 01 00 00 00       	mov    $0x1,%ebx
  80225d:	e9 2a ff ff ff       	jmp    80218c <__udivdi3+0x4c>
  802262:	66 90                	xchg   %ax,%ax
  802264:	66 90                	xchg   %ax,%ax
  802266:	66 90                	xchg   %ax,%ax
  802268:	66 90                	xchg   %ax,%ax
  80226a:	66 90                	xchg   %ax,%ax
  80226c:	66 90                	xchg   %ax,%ax
  80226e:	66 90                	xchg   %ax,%ax

00802270 <__umoddi3>:
  802270:	55                   	push   %ebp
  802271:	57                   	push   %edi
  802272:	56                   	push   %esi
  802273:	53                   	push   %ebx
  802274:	83 ec 1c             	sub    $0x1c,%esp
  802277:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80227b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80227f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802283:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802287:	85 d2                	test   %edx,%edx
  802289:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80228d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802291:	89 f3                	mov    %esi,%ebx
  802293:	89 3c 24             	mov    %edi,(%esp)
  802296:	89 74 24 04          	mov    %esi,0x4(%esp)
  80229a:	75 1c                	jne    8022b8 <__umoddi3+0x48>
  80229c:	39 f7                	cmp    %esi,%edi
  80229e:	76 50                	jbe    8022f0 <__umoddi3+0x80>
  8022a0:	89 c8                	mov    %ecx,%eax
  8022a2:	89 f2                	mov    %esi,%edx
  8022a4:	f7 f7                	div    %edi
  8022a6:	89 d0                	mov    %edx,%eax
  8022a8:	31 d2                	xor    %edx,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	39 f2                	cmp    %esi,%edx
  8022ba:	89 d0                	mov    %edx,%eax
  8022bc:	77 52                	ja     802310 <__umoddi3+0xa0>
  8022be:	0f bd ea             	bsr    %edx,%ebp
  8022c1:	83 f5 1f             	xor    $0x1f,%ebp
  8022c4:	75 5a                	jne    802320 <__umoddi3+0xb0>
  8022c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ca:	0f 82 e0 00 00 00    	jb     8023b0 <__umoddi3+0x140>
  8022d0:	39 0c 24             	cmp    %ecx,(%esp)
  8022d3:	0f 86 d7 00 00 00    	jbe    8023b0 <__umoddi3+0x140>
  8022d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022e1:	83 c4 1c             	add    $0x1c,%esp
  8022e4:	5b                   	pop    %ebx
  8022e5:	5e                   	pop    %esi
  8022e6:	5f                   	pop    %edi
  8022e7:	5d                   	pop    %ebp
  8022e8:	c3                   	ret    
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	85 ff                	test   %edi,%edi
  8022f2:	89 fd                	mov    %edi,%ebp
  8022f4:	75 0b                	jne    802301 <__umoddi3+0x91>
  8022f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022fb:	31 d2                	xor    %edx,%edx
  8022fd:	f7 f7                	div    %edi
  8022ff:	89 c5                	mov    %eax,%ebp
  802301:	89 f0                	mov    %esi,%eax
  802303:	31 d2                	xor    %edx,%edx
  802305:	f7 f5                	div    %ebp
  802307:	89 c8                	mov    %ecx,%eax
  802309:	f7 f5                	div    %ebp
  80230b:	89 d0                	mov    %edx,%eax
  80230d:	eb 99                	jmp    8022a8 <__umoddi3+0x38>
  80230f:	90                   	nop
  802310:	89 c8                	mov    %ecx,%eax
  802312:	89 f2                	mov    %esi,%edx
  802314:	83 c4 1c             	add    $0x1c,%esp
  802317:	5b                   	pop    %ebx
  802318:	5e                   	pop    %esi
  802319:	5f                   	pop    %edi
  80231a:	5d                   	pop    %ebp
  80231b:	c3                   	ret    
  80231c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802320:	8b 34 24             	mov    (%esp),%esi
  802323:	bf 20 00 00 00       	mov    $0x20,%edi
  802328:	89 e9                	mov    %ebp,%ecx
  80232a:	29 ef                	sub    %ebp,%edi
  80232c:	d3 e0                	shl    %cl,%eax
  80232e:	89 f9                	mov    %edi,%ecx
  802330:	89 f2                	mov    %esi,%edx
  802332:	d3 ea                	shr    %cl,%edx
  802334:	89 e9                	mov    %ebp,%ecx
  802336:	09 c2                	or     %eax,%edx
  802338:	89 d8                	mov    %ebx,%eax
  80233a:	89 14 24             	mov    %edx,(%esp)
  80233d:	89 f2                	mov    %esi,%edx
  80233f:	d3 e2                	shl    %cl,%edx
  802341:	89 f9                	mov    %edi,%ecx
  802343:	89 54 24 04          	mov    %edx,0x4(%esp)
  802347:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80234b:	d3 e8                	shr    %cl,%eax
  80234d:	89 e9                	mov    %ebp,%ecx
  80234f:	89 c6                	mov    %eax,%esi
  802351:	d3 e3                	shl    %cl,%ebx
  802353:	89 f9                	mov    %edi,%ecx
  802355:	89 d0                	mov    %edx,%eax
  802357:	d3 e8                	shr    %cl,%eax
  802359:	89 e9                	mov    %ebp,%ecx
  80235b:	09 d8                	or     %ebx,%eax
  80235d:	89 d3                	mov    %edx,%ebx
  80235f:	89 f2                	mov    %esi,%edx
  802361:	f7 34 24             	divl   (%esp)
  802364:	89 d6                	mov    %edx,%esi
  802366:	d3 e3                	shl    %cl,%ebx
  802368:	f7 64 24 04          	mull   0x4(%esp)
  80236c:	39 d6                	cmp    %edx,%esi
  80236e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802372:	89 d1                	mov    %edx,%ecx
  802374:	89 c3                	mov    %eax,%ebx
  802376:	72 08                	jb     802380 <__umoddi3+0x110>
  802378:	75 11                	jne    80238b <__umoddi3+0x11b>
  80237a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80237e:	73 0b                	jae    80238b <__umoddi3+0x11b>
  802380:	2b 44 24 04          	sub    0x4(%esp),%eax
  802384:	1b 14 24             	sbb    (%esp),%edx
  802387:	89 d1                	mov    %edx,%ecx
  802389:	89 c3                	mov    %eax,%ebx
  80238b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80238f:	29 da                	sub    %ebx,%edx
  802391:	19 ce                	sbb    %ecx,%esi
  802393:	89 f9                	mov    %edi,%ecx
  802395:	89 f0                	mov    %esi,%eax
  802397:	d3 e0                	shl    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	d3 ea                	shr    %cl,%edx
  80239d:	89 e9                	mov    %ebp,%ecx
  80239f:	d3 ee                	shr    %cl,%esi
  8023a1:	09 d0                	or     %edx,%eax
  8023a3:	89 f2                	mov    %esi,%edx
  8023a5:	83 c4 1c             	add    $0x1c,%esp
  8023a8:	5b                   	pop    %ebx
  8023a9:	5e                   	pop    %esi
  8023aa:	5f                   	pop    %edi
  8023ab:	5d                   	pop    %ebp
  8023ac:	c3                   	ret    
  8023ad:	8d 76 00             	lea    0x0(%esi),%esi
  8023b0:	29 f9                	sub    %edi,%ecx
  8023b2:	19 d6                	sbb    %edx,%esi
  8023b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023bc:	e9 18 ff ff ff       	jmp    8022d9 <__umoddi3+0x69>
