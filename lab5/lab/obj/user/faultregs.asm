
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 66 05 00 00       	call   800597 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 f1 23 80 00       	push   $0x8023f1
  800049:	68 c0 23 80 00       	push   $0x8023c0
  80004e:	e8 7d 06 00 00       	call   8006d0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 d0 23 80 00       	push   $0x8023d0
  80005c:	68 d4 23 80 00       	push   $0x8023d4
  800061:	e8 6a 06 00 00       	call   8006d0 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 e4 23 80 00       	push   $0x8023e4
  800077:	e8 54 06 00 00       	call   8006d0 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 e8 23 80 00       	push   $0x8023e8
  80008e:	e8 3d 06 00 00       	call   8006d0 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 f2 23 80 00       	push   $0x8023f2
  8000a6:	68 d4 23 80 00       	push   $0x8023d4
  8000ab:	e8 20 06 00 00       	call   8006d0 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 e4 23 80 00       	push   $0x8023e4
  8000c3:	e8 08 06 00 00       	call   8006d0 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 e8 23 80 00       	push   $0x8023e8
  8000d5:	e8 f6 05 00 00       	call   8006d0 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 f6 23 80 00       	push   $0x8023f6
  8000ed:	68 d4 23 80 00       	push   $0x8023d4
  8000f2:	e8 d9 05 00 00       	call   8006d0 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 e4 23 80 00       	push   $0x8023e4
  80010a:	e8 c1 05 00 00       	call   8006d0 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 e8 23 80 00       	push   $0x8023e8
  80011c:	e8 af 05 00 00       	call   8006d0 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 fa 23 80 00       	push   $0x8023fa
  800134:	68 d4 23 80 00       	push   $0x8023d4
  800139:	e8 92 05 00 00       	call   8006d0 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 e4 23 80 00       	push   $0x8023e4
  800151:	e8 7a 05 00 00       	call   8006d0 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 e8 23 80 00       	push   $0x8023e8
  800163:	e8 68 05 00 00       	call   8006d0 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 fe 23 80 00       	push   $0x8023fe
  80017b:	68 d4 23 80 00       	push   $0x8023d4
  800180:	e8 4b 05 00 00       	call   8006d0 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 e4 23 80 00       	push   $0x8023e4
  800198:	e8 33 05 00 00       	call   8006d0 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 e8 23 80 00       	push   $0x8023e8
  8001aa:	e8 21 05 00 00       	call   8006d0 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 02 24 80 00       	push   $0x802402
  8001c2:	68 d4 23 80 00       	push   $0x8023d4
  8001c7:	e8 04 05 00 00       	call   8006d0 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 e4 23 80 00       	push   $0x8023e4
  8001df:	e8 ec 04 00 00       	call   8006d0 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 e8 23 80 00       	push   $0x8023e8
  8001f1:	e8 da 04 00 00       	call   8006d0 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 06 24 80 00       	push   $0x802406
  800209:	68 d4 23 80 00       	push   $0x8023d4
  80020e:	e8 bd 04 00 00       	call   8006d0 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 e4 23 80 00       	push   $0x8023e4
  800226:	e8 a5 04 00 00       	call   8006d0 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 e8 23 80 00       	push   $0x8023e8
  800238:	e8 93 04 00 00       	call   8006d0 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 0a 24 80 00       	push   $0x80240a
  800250:	68 d4 23 80 00       	push   $0x8023d4
  800255:	e8 76 04 00 00       	call   8006d0 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 e4 23 80 00       	push   $0x8023e4
  80026d:	e8 5e 04 00 00       	call   8006d0 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 e8 23 80 00       	push   $0x8023e8
  80027f:	e8 4c 04 00 00       	call   8006d0 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 0e 24 80 00       	push   $0x80240e
  800297:	68 d4 23 80 00       	push   $0x8023d4
  80029c:	e8 2f 04 00 00       	call   8006d0 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 e4 23 80 00       	push   $0x8023e4
  8002b4:	e8 17 04 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 15 24 80 00       	push   $0x802415
  8002c4:	68 d4 23 80 00       	push   $0x8023d4
  8002c9:	e8 02 04 00 00       	call   8006d0 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 e8 23 80 00       	push   $0x8023e8
  8002e3:	e8 e8 03 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 15 24 80 00       	push   $0x802415
  8002f3:	68 d4 23 80 00       	push   $0x8023d4
  8002f8:	e8 d3 03 00 00       	call   8006d0 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 e4 23 80 00       	push   $0x8023e4
  800312:	e8 b9 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 19 24 80 00       	push   $0x802419
  800322:	e8 a9 03 00 00       	call   8006d0 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 e8 23 80 00       	push   $0x8023e8
  800338:	e8 93 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 19 24 80 00       	push   $0x802419
  800348:	e8 83 03 00 00       	call   8006d0 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 e4 23 80 00       	push   $0x8023e4
  80035a:	e8 71 03 00 00       	call   8006d0 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 e8 23 80 00       	push   $0x8023e8
  80036c:	e8 5f 03 00 00       	call   8006d0 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 e4 23 80 00       	push   $0x8023e4
  80037e:	e8 4d 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 19 24 80 00       	push   $0x802419
  80038e:	e8 3d 03 00 00       	call   8006d0 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 80 24 80 00       	push   $0x802480
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 27 24 80 00       	push   $0x802427
  8003c6:	e8 2c 02 00 00       	call   8005f7 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800425:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80042b:	8b 40 30             	mov    0x30(%eax),%eax
  80042e:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	68 3f 24 80 00       	push   $0x80243f
  80043b:	68 4d 24 80 00       	push   $0x80244d
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba 38 24 80 00       	mov    $0x802438,%edx
  80044a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 f3 0b 00 00       	call   801058 <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 54 24 80 00       	push   $0x802454
  800472:	6a 5c                	push   $0x5c
  800474:	68 27 24 80 00       	push   $0x802427
  800479:	e8 79 01 00 00       	call   8005f7 <_panic>
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <umain>:

void
umain(int argc, char **argv)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800486:	68 a0 03 80 00       	push   $0x8003a0
  80048b:	e8 b9 0d 00 00       	call   801249 <set_pgfault_handler>

	asm volatile(
  800490:	50                   	push   %eax
  800491:	9c                   	pushf  
  800492:	58                   	pop    %eax
  800493:	0d d5 08 00 00       	or     $0x8d5,%eax
  800498:	50                   	push   %eax
  800499:	9d                   	popf   
  80049a:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  80049f:	8d 05 da 04 80 00    	lea    0x8004da,%eax
  8004a5:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004aa:	58                   	pop    %eax
  8004ab:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004b1:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b7:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004bd:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004c3:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c9:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004cf:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004d4:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004da:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e1:	00 00 00 
  8004e4:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004ea:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004f0:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f6:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004fc:	89 15 14 40 80 00    	mov    %edx,0x804014
  800502:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800508:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80050d:	89 25 28 40 80 00    	mov    %esp,0x804028
  800513:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800519:	8b 35 84 40 80 00    	mov    0x804084,%esi
  80051f:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  800525:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  80052b:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800531:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800537:	a1 9c 40 80 00       	mov    0x80409c,%eax
  80053c:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800542:	50                   	push   %eax
  800543:	9c                   	pushf  
  800544:	58                   	pop    %eax
  800545:	a3 24 40 80 00       	mov    %eax,0x804024
  80054a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800555:	74 10                	je     800567 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800557:	83 ec 0c             	sub    $0xc,%esp
  80055a:	68 b4 24 80 00       	push   $0x8024b4
  80055f:	e8 6c 01 00 00       	call   8006d0 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 67 24 80 00       	push   $0x802467
  800579:	68 78 24 80 00       	push   $0x802478
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba 38 24 80 00       	mov    $0x802438,%edx
  800588:	b8 80 40 80 00       	mov    $0x804080,%eax
  80058d:	e8 a1 fa ff ff       	call   800033 <check_regs>
}
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80059f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8005a2:	e8 73 0a 00 00       	call   80101a <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8005a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b4:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b9:	85 db                	test   %ebx,%ebx
  8005bb:	7e 07                	jle    8005c4 <libmain+0x2d>
		binaryname = argv[0];
  8005bd:	8b 06                	mov    (%esi),%eax
  8005bf:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	56                   	push   %esi
  8005c8:	53                   	push   %ebx
  8005c9:	e8 b2 fe ff ff       	call   800480 <umain>

	// exit gracefully
	exit();
  8005ce:	e8 0a 00 00 00       	call   8005dd <exit>
}
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d9:	5b                   	pop    %ebx
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	c3                   	ret    

008005dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005e3:	e8 ab 0e 00 00       	call   801493 <close_all>
	sys_env_destroy(0);
  8005e8:	83 ec 0c             	sub    $0xc,%esp
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 e7 09 00 00       	call   800fd9 <sys_env_destroy>
}
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	c9                   	leave  
  8005f6:	c3                   	ret    

008005f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	56                   	push   %esi
  8005fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005ff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800605:	e8 10 0a 00 00       	call   80101a <sys_getenvid>
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	ff 75 0c             	pushl  0xc(%ebp)
  800610:	ff 75 08             	pushl  0x8(%ebp)
  800613:	56                   	push   %esi
  800614:	50                   	push   %eax
  800615:	68 e0 24 80 00       	push   $0x8024e0
  80061a:	e8 b1 00 00 00       	call   8006d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80061f:	83 c4 18             	add    $0x18,%esp
  800622:	53                   	push   %ebx
  800623:	ff 75 10             	pushl  0x10(%ebp)
  800626:	e8 54 00 00 00       	call   80067f <vcprintf>
	cprintf("\n");
  80062b:	c7 04 24 f0 23 80 00 	movl   $0x8023f0,(%esp)
  800632:	e8 99 00 00 00       	call   8006d0 <cprintf>
  800637:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80063a:	cc                   	int3   
  80063b:	eb fd                	jmp    80063a <_panic+0x43>

0080063d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	53                   	push   %ebx
  800641:	83 ec 04             	sub    $0x4,%esp
  800644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800647:	8b 13                	mov    (%ebx),%edx
  800649:	8d 42 01             	lea    0x1(%edx),%eax
  80064c:	89 03                	mov    %eax,(%ebx)
  80064e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800651:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800655:	3d ff 00 00 00       	cmp    $0xff,%eax
  80065a:	75 1a                	jne    800676 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	68 ff 00 00 00       	push   $0xff
  800664:	8d 43 08             	lea    0x8(%ebx),%eax
  800667:	50                   	push   %eax
  800668:	e8 2f 09 00 00       	call   800f9c <sys_cputs>
		b->idx = 0;
  80066d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800673:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800676:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80067a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800688:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80068f:	00 00 00 
	b.cnt = 0;
  800692:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800699:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80069c:	ff 75 0c             	pushl  0xc(%ebp)
  80069f:	ff 75 08             	pushl  0x8(%ebp)
  8006a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	68 3d 06 80 00       	push   $0x80063d
  8006ae:	e8 54 01 00 00       	call   800807 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c2:	50                   	push   %eax
  8006c3:	e8 d4 08 00 00       	call   800f9c <sys_cputs>

	return b.cnt;
}
  8006c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d9:	50                   	push   %eax
  8006da:	ff 75 08             	pushl  0x8(%ebp)
  8006dd:	e8 9d ff ff ff       	call   80067f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	57                   	push   %edi
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
  8006ea:	83 ec 1c             	sub    $0x1c,%esp
  8006ed:	89 c7                	mov    %eax,%edi
  8006ef:	89 d6                	mov    %edx,%esi
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800700:	bb 00 00 00 00       	mov    $0x0,%ebx
  800705:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800708:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070b:	39 d3                	cmp    %edx,%ebx
  80070d:	72 05                	jb     800714 <printnum+0x30>
  80070f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800712:	77 45                	ja     800759 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800714:	83 ec 0c             	sub    $0xc,%esp
  800717:	ff 75 18             	pushl  0x18(%ebp)
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800720:	53                   	push   %ebx
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072a:	ff 75 e0             	pushl  -0x20(%ebp)
  80072d:	ff 75 dc             	pushl  -0x24(%ebp)
  800730:	ff 75 d8             	pushl  -0x28(%ebp)
  800733:	e8 f8 19 00 00       	call   802130 <__udivdi3>
  800738:	83 c4 18             	add    $0x18,%esp
  80073b:	52                   	push   %edx
  80073c:	50                   	push   %eax
  80073d:	89 f2                	mov    %esi,%edx
  80073f:	89 f8                	mov    %edi,%eax
  800741:	e8 9e ff ff ff       	call   8006e4 <printnum>
  800746:	83 c4 20             	add    $0x20,%esp
  800749:	eb 18                	jmp    800763 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	56                   	push   %esi
  80074f:	ff 75 18             	pushl  0x18(%ebp)
  800752:	ff d7                	call   *%edi
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	eb 03                	jmp    80075c <printnum+0x78>
  800759:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80075c:	83 eb 01             	sub    $0x1,%ebx
  80075f:	85 db                	test   %ebx,%ebx
  800761:	7f e8                	jg     80074b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	56                   	push   %esi
  800767:	83 ec 04             	sub    $0x4,%esp
  80076a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80076d:	ff 75 e0             	pushl  -0x20(%ebp)
  800770:	ff 75 dc             	pushl  -0x24(%ebp)
  800773:	ff 75 d8             	pushl  -0x28(%ebp)
  800776:	e8 e5 1a 00 00       	call   802260 <__umoddi3>
  80077b:	83 c4 14             	add    $0x14,%esp
  80077e:	0f be 80 03 25 80 00 	movsbl 0x802503(%eax),%eax
  800785:	50                   	push   %eax
  800786:	ff d7                	call   *%edi
}
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5f                   	pop    %edi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800796:	83 fa 01             	cmp    $0x1,%edx
  800799:	7e 0e                	jle    8007a9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007a0:	89 08                	mov    %ecx,(%eax)
  8007a2:	8b 02                	mov    (%edx),%eax
  8007a4:	8b 52 04             	mov    0x4(%edx),%edx
  8007a7:	eb 22                	jmp    8007cb <getuint+0x38>
	else if (lflag)
  8007a9:	85 d2                	test   %edx,%edx
  8007ab:	74 10                	je     8007bd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007ad:	8b 10                	mov    (%eax),%edx
  8007af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b2:	89 08                	mov    %ecx,(%eax)
  8007b4:	8b 02                	mov    (%edx),%eax
  8007b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bb:	eb 0e                	jmp    8007cb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007bd:	8b 10                	mov    (%eax),%edx
  8007bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007c2:	89 08                	mov    %ecx,(%eax)
  8007c4:	8b 02                	mov    (%edx),%eax
  8007c6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007d7:	8b 10                	mov    (%eax),%edx
  8007d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8007dc:	73 0a                	jae    8007e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007e1:	89 08                	mov    %ecx,(%eax)
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	88 02                	mov    %al,(%edx)
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007f3:	50                   	push   %eax
  8007f4:	ff 75 10             	pushl  0x10(%ebp)
  8007f7:	ff 75 0c             	pushl  0xc(%ebp)
  8007fa:	ff 75 08             	pushl  0x8(%ebp)
  8007fd:	e8 05 00 00 00       	call   800807 <vprintfmt>
	va_end(ap);
}
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	57                   	push   %edi
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	83 ec 2c             	sub    $0x2c,%esp
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800816:	8b 7d 10             	mov    0x10(%ebp),%edi
  800819:	eb 12                	jmp    80082d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80081b:	85 c0                	test   %eax,%eax
  80081d:	0f 84 89 03 00 00    	je     800bac <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	ff d6                	call   *%esi
  80082a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082d:	83 c7 01             	add    $0x1,%edi
  800830:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800834:	83 f8 25             	cmp    $0x25,%eax
  800837:	75 e2                	jne    80081b <vprintfmt+0x14>
  800839:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80083d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800844:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80084b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800852:	ba 00 00 00 00       	mov    $0x0,%edx
  800857:	eb 07                	jmp    800860 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800859:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80085c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800860:	8d 47 01             	lea    0x1(%edi),%eax
  800863:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800866:	0f b6 07             	movzbl (%edi),%eax
  800869:	0f b6 c8             	movzbl %al,%ecx
  80086c:	83 e8 23             	sub    $0x23,%eax
  80086f:	3c 55                	cmp    $0x55,%al
  800871:	0f 87 1a 03 00 00    	ja     800b91 <vprintfmt+0x38a>
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  800881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800884:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800888:	eb d6                	jmp    800860 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
  800892:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800895:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800898:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80089c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80089f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8008a2:	83 fa 09             	cmp    $0x9,%edx
  8008a5:	77 39                	ja     8008e0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008aa:	eb e9                	jmp    800895 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	8d 48 04             	lea    0x4(%eax),%ecx
  8008b2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008b5:	8b 00                	mov    (%eax),%eax
  8008b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008bd:	eb 27                	jmp    8008e6 <vprintfmt+0xdf>
  8008bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c2:	85 c0                	test   %eax,%eax
  8008c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c9:	0f 49 c8             	cmovns %eax,%ecx
  8008cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d2:	eb 8c                	jmp    800860 <vprintfmt+0x59>
  8008d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008de:	eb 80                	jmp    800860 <vprintfmt+0x59>
  8008e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008e3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008ea:	0f 89 70 ff ff ff    	jns    800860 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008fd:	e9 5e ff ff ff       	jmp    800860 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800902:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800905:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800908:	e9 53 ff ff ff       	jmp    800860 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80090d:	8b 45 14             	mov    0x14(%ebp),%eax
  800910:	8d 50 04             	lea    0x4(%eax),%edx
  800913:	89 55 14             	mov    %edx,0x14(%ebp)
  800916:	83 ec 08             	sub    $0x8,%esp
  800919:	53                   	push   %ebx
  80091a:	ff 30                	pushl  (%eax)
  80091c:	ff d6                	call   *%esi
			break;
  80091e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800921:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800924:	e9 04 ff ff ff       	jmp    80082d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800929:	8b 45 14             	mov    0x14(%ebp),%eax
  80092c:	8d 50 04             	lea    0x4(%eax),%edx
  80092f:	89 55 14             	mov    %edx,0x14(%ebp)
  800932:	8b 00                	mov    (%eax),%eax
  800934:	99                   	cltd   
  800935:	31 d0                	xor    %edx,%eax
  800937:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800939:	83 f8 0f             	cmp    $0xf,%eax
  80093c:	7f 0b                	jg     800949 <vprintfmt+0x142>
  80093e:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  800945:	85 d2                	test   %edx,%edx
  800947:	75 18                	jne    800961 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800949:	50                   	push   %eax
  80094a:	68 1b 25 80 00       	push   $0x80251b
  80094f:	53                   	push   %ebx
  800950:	56                   	push   %esi
  800951:	e8 94 fe ff ff       	call   8007ea <printfmt>
  800956:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800959:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80095c:	e9 cc fe ff ff       	jmp    80082d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800961:	52                   	push   %edx
  800962:	68 fd 28 80 00       	push   $0x8028fd
  800967:	53                   	push   %ebx
  800968:	56                   	push   %esi
  800969:	e8 7c fe ff ff       	call   8007ea <printfmt>
  80096e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800971:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800974:	e9 b4 fe ff ff       	jmp    80082d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800979:	8b 45 14             	mov    0x14(%ebp),%eax
  80097c:	8d 50 04             	lea    0x4(%eax),%edx
  80097f:	89 55 14             	mov    %edx,0x14(%ebp)
  800982:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800984:	85 ff                	test   %edi,%edi
  800986:	b8 14 25 80 00       	mov    $0x802514,%eax
  80098b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80098e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800992:	0f 8e 94 00 00 00    	jle    800a2c <vprintfmt+0x225>
  800998:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80099c:	0f 84 98 00 00 00    	je     800a3a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	ff 75 d0             	pushl  -0x30(%ebp)
  8009a8:	57                   	push   %edi
  8009a9:	e8 86 02 00 00       	call   800c34 <strnlen>
  8009ae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009b1:	29 c1                	sub    %eax,%ecx
  8009b3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009b6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009c3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c5:	eb 0f                	jmp    8009d6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009c7:	83 ec 08             	sub    $0x8,%esp
  8009ca:	53                   	push   %ebx
  8009cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ce:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d0:	83 ef 01             	sub    $0x1,%edi
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	85 ff                	test   %edi,%edi
  8009d8:	7f ed                	jg     8009c7 <vprintfmt+0x1c0>
  8009da:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009dd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009e0:	85 c9                	test   %ecx,%ecx
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e7:	0f 49 c1             	cmovns %ecx,%eax
  8009ea:	29 c1                	sub    %eax,%ecx
  8009ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8009ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f5:	89 cb                	mov    %ecx,%ebx
  8009f7:	eb 4d                	jmp    800a46 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009fd:	74 1b                	je     800a1a <vprintfmt+0x213>
  8009ff:	0f be c0             	movsbl %al,%eax
  800a02:	83 e8 20             	sub    $0x20,%eax
  800a05:	83 f8 5e             	cmp    $0x5e,%eax
  800a08:	76 10                	jbe    800a1a <vprintfmt+0x213>
					putch('?', putdat);
  800a0a:	83 ec 08             	sub    $0x8,%esp
  800a0d:	ff 75 0c             	pushl  0xc(%ebp)
  800a10:	6a 3f                	push   $0x3f
  800a12:	ff 55 08             	call   *0x8(%ebp)
  800a15:	83 c4 10             	add    $0x10,%esp
  800a18:	eb 0d                	jmp    800a27 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a1a:	83 ec 08             	sub    $0x8,%esp
  800a1d:	ff 75 0c             	pushl  0xc(%ebp)
  800a20:	52                   	push   %edx
  800a21:	ff 55 08             	call   *0x8(%ebp)
  800a24:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a27:	83 eb 01             	sub    $0x1,%ebx
  800a2a:	eb 1a                	jmp    800a46 <vprintfmt+0x23f>
  800a2c:	89 75 08             	mov    %esi,0x8(%ebp)
  800a2f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a32:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a35:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a38:	eb 0c                	jmp    800a46 <vprintfmt+0x23f>
  800a3a:	89 75 08             	mov    %esi,0x8(%ebp)
  800a3d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a40:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a43:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a46:	83 c7 01             	add    $0x1,%edi
  800a49:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a4d:	0f be d0             	movsbl %al,%edx
  800a50:	85 d2                	test   %edx,%edx
  800a52:	74 23                	je     800a77 <vprintfmt+0x270>
  800a54:	85 f6                	test   %esi,%esi
  800a56:	78 a1                	js     8009f9 <vprintfmt+0x1f2>
  800a58:	83 ee 01             	sub    $0x1,%esi
  800a5b:	79 9c                	jns    8009f9 <vprintfmt+0x1f2>
  800a5d:	89 df                	mov    %ebx,%edi
  800a5f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a65:	eb 18                	jmp    800a7f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a67:	83 ec 08             	sub    $0x8,%esp
  800a6a:	53                   	push   %ebx
  800a6b:	6a 20                	push   $0x20
  800a6d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	83 c4 10             	add    $0x10,%esp
  800a75:	eb 08                	jmp    800a7f <vprintfmt+0x278>
  800a77:	89 df                	mov    %ebx,%edi
  800a79:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7f:	85 ff                	test   %edi,%edi
  800a81:	7f e4                	jg     800a67 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a86:	e9 a2 fd ff ff       	jmp    80082d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a8b:	83 fa 01             	cmp    $0x1,%edx
  800a8e:	7e 16                	jle    800aa6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a90:	8b 45 14             	mov    0x14(%ebp),%eax
  800a93:	8d 50 08             	lea    0x8(%eax),%edx
  800a96:	89 55 14             	mov    %edx,0x14(%ebp)
  800a99:	8b 50 04             	mov    0x4(%eax),%edx
  800a9c:	8b 00                	mov    (%eax),%eax
  800a9e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa4:	eb 32                	jmp    800ad8 <vprintfmt+0x2d1>
	else if (lflag)
  800aa6:	85 d2                	test   %edx,%edx
  800aa8:	74 18                	je     800ac2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800aaa:	8b 45 14             	mov    0x14(%ebp),%eax
  800aad:	8d 50 04             	lea    0x4(%eax),%edx
  800ab0:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab3:	8b 00                	mov    (%eax),%eax
  800ab5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab8:	89 c1                	mov    %eax,%ecx
  800aba:	c1 f9 1f             	sar    $0x1f,%ecx
  800abd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ac0:	eb 16                	jmp    800ad8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ac2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac5:	8d 50 04             	lea    0x4(%eax),%edx
  800ac8:	89 55 14             	mov    %edx,0x14(%ebp)
  800acb:	8b 00                	mov    (%eax),%eax
  800acd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ad0:	89 c1                	mov    %eax,%ecx
  800ad2:	c1 f9 1f             	sar    $0x1f,%ecx
  800ad5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800adb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ade:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ae3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ae7:	79 74                	jns    800b5d <vprintfmt+0x356>
				putch('-', putdat);
  800ae9:	83 ec 08             	sub    $0x8,%esp
  800aec:	53                   	push   %ebx
  800aed:	6a 2d                	push   $0x2d
  800aef:	ff d6                	call   *%esi
				num = -(long long) num;
  800af1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800af4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800af7:	f7 d8                	neg    %eax
  800af9:	83 d2 00             	adc    $0x0,%edx
  800afc:	f7 da                	neg    %edx
  800afe:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b01:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b06:	eb 55                	jmp    800b5d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b08:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0b:	e8 83 fc ff ff       	call   800793 <getuint>
			base = 10;
  800b10:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b15:	eb 46                	jmp    800b5d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b17:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1a:	e8 74 fc ff ff       	call   800793 <getuint>
			base = 8;
  800b1f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b24:	eb 37                	jmp    800b5d <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b26:	83 ec 08             	sub    $0x8,%esp
  800b29:	53                   	push   %ebx
  800b2a:	6a 30                	push   $0x30
  800b2c:	ff d6                	call   *%esi
			putch('x', putdat);
  800b2e:	83 c4 08             	add    $0x8,%esp
  800b31:	53                   	push   %ebx
  800b32:	6a 78                	push   $0x78
  800b34:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b36:	8b 45 14             	mov    0x14(%ebp),%eax
  800b39:	8d 50 04             	lea    0x4(%eax),%edx
  800b3c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b3f:	8b 00                	mov    (%eax),%eax
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b46:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b49:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b4e:	eb 0d                	jmp    800b5d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b50:	8d 45 14             	lea    0x14(%ebp),%eax
  800b53:	e8 3b fc ff ff       	call   800793 <getuint>
			base = 16;
  800b58:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b64:	57                   	push   %edi
  800b65:	ff 75 e0             	pushl  -0x20(%ebp)
  800b68:	51                   	push   %ecx
  800b69:	52                   	push   %edx
  800b6a:	50                   	push   %eax
  800b6b:	89 da                	mov    %ebx,%edx
  800b6d:	89 f0                	mov    %esi,%eax
  800b6f:	e8 70 fb ff ff       	call   8006e4 <printnum>
			break;
  800b74:	83 c4 20             	add    $0x20,%esp
  800b77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b7a:	e9 ae fc ff ff       	jmp    80082d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b7f:	83 ec 08             	sub    $0x8,%esp
  800b82:	53                   	push   %ebx
  800b83:	51                   	push   %ecx
  800b84:	ff d6                	call   *%esi
			break;
  800b86:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b89:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b8c:	e9 9c fc ff ff       	jmp    80082d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b91:	83 ec 08             	sub    $0x8,%esp
  800b94:	53                   	push   %ebx
  800b95:	6a 25                	push   $0x25
  800b97:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b99:	83 c4 10             	add    $0x10,%esp
  800b9c:	eb 03                	jmp    800ba1 <vprintfmt+0x39a>
  800b9e:	83 ef 01             	sub    $0x1,%edi
  800ba1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ba5:	75 f7                	jne    800b9e <vprintfmt+0x397>
  800ba7:	e9 81 fc ff ff       	jmp    80082d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800bac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	83 ec 18             	sub    $0x18,%esp
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bc3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bc7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	74 26                	je     800bfb <vsnprintf+0x47>
  800bd5:	85 d2                	test   %edx,%edx
  800bd7:	7e 22                	jle    800bfb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd9:	ff 75 14             	pushl  0x14(%ebp)
  800bdc:	ff 75 10             	pushl  0x10(%ebp)
  800bdf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800be2:	50                   	push   %eax
  800be3:	68 cd 07 80 00       	push   $0x8007cd
  800be8:	e8 1a fc ff ff       	call   800807 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf6:	83 c4 10             	add    $0x10,%esp
  800bf9:	eb 05                	jmp    800c00 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bfb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c08:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c0b:	50                   	push   %eax
  800c0c:	ff 75 10             	pushl  0x10(%ebp)
  800c0f:	ff 75 0c             	pushl  0xc(%ebp)
  800c12:	ff 75 08             	pushl  0x8(%ebp)
  800c15:	e8 9a ff ff ff       	call   800bb4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c1a:	c9                   	leave  
  800c1b:	c3                   	ret    

00800c1c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
  800c27:	eb 03                	jmp    800c2c <strlen+0x10>
		n++;
  800c29:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c2c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c30:	75 f7                	jne    800c29 <strlen+0xd>
		n++;
	return n;
}
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c42:	eb 03                	jmp    800c47 <strnlen+0x13>
		n++;
  800c44:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c47:	39 c2                	cmp    %eax,%edx
  800c49:	74 08                	je     800c53 <strnlen+0x1f>
  800c4b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c4f:	75 f3                	jne    800c44 <strnlen+0x10>
  800c51:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	53                   	push   %ebx
  800c59:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c5f:	89 c2                	mov    %eax,%edx
  800c61:	83 c2 01             	add    $0x1,%edx
  800c64:	83 c1 01             	add    $0x1,%ecx
  800c67:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c6b:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c6e:	84 db                	test   %bl,%bl
  800c70:	75 ef                	jne    800c61 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c72:	5b                   	pop    %ebx
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	53                   	push   %ebx
  800c79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c7c:	53                   	push   %ebx
  800c7d:	e8 9a ff ff ff       	call   800c1c <strlen>
  800c82:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c85:	ff 75 0c             	pushl  0xc(%ebp)
  800c88:	01 d8                	add    %ebx,%eax
  800c8a:	50                   	push   %eax
  800c8b:	e8 c5 ff ff ff       	call   800c55 <strcpy>
	return dst;
}
  800c90:	89 d8                	mov    %ebx,%eax
  800c92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	8b 75 08             	mov    0x8(%ebp),%esi
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	89 f3                	mov    %esi,%ebx
  800ca4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ca7:	89 f2                	mov    %esi,%edx
  800ca9:	eb 0f                	jmp    800cba <strncpy+0x23>
		*dst++ = *src;
  800cab:	83 c2 01             	add    $0x1,%edx
  800cae:	0f b6 01             	movzbl (%ecx),%eax
  800cb1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cb4:	80 39 01             	cmpb   $0x1,(%ecx)
  800cb7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cba:	39 da                	cmp    %ebx,%edx
  800cbc:	75 ed                	jne    800cab <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cbe:	89 f0                	mov    %esi,%eax
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	8b 75 08             	mov    0x8(%ebp),%esi
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	8b 55 10             	mov    0x10(%ebp),%edx
  800cd2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cd4:	85 d2                	test   %edx,%edx
  800cd6:	74 21                	je     800cf9 <strlcpy+0x35>
  800cd8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cdc:	89 f2                	mov    %esi,%edx
  800cde:	eb 09                	jmp    800ce9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ce0:	83 c2 01             	add    $0x1,%edx
  800ce3:	83 c1 01             	add    $0x1,%ecx
  800ce6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ce9:	39 c2                	cmp    %eax,%edx
  800ceb:	74 09                	je     800cf6 <strlcpy+0x32>
  800ced:	0f b6 19             	movzbl (%ecx),%ebx
  800cf0:	84 db                	test   %bl,%bl
  800cf2:	75 ec                	jne    800ce0 <strlcpy+0x1c>
  800cf4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cf6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cf9:	29 f0                	sub    %esi,%eax
}
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d05:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d08:	eb 06                	jmp    800d10 <strcmp+0x11>
		p++, q++;
  800d0a:	83 c1 01             	add    $0x1,%ecx
  800d0d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d10:	0f b6 01             	movzbl (%ecx),%eax
  800d13:	84 c0                	test   %al,%al
  800d15:	74 04                	je     800d1b <strcmp+0x1c>
  800d17:	3a 02                	cmp    (%edx),%al
  800d19:	74 ef                	je     800d0a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d1b:	0f b6 c0             	movzbl %al,%eax
  800d1e:	0f b6 12             	movzbl (%edx),%edx
  800d21:	29 d0                	sub    %edx,%eax
}
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	53                   	push   %ebx
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d2f:	89 c3                	mov    %eax,%ebx
  800d31:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d34:	eb 06                	jmp    800d3c <strncmp+0x17>
		n--, p++, q++;
  800d36:	83 c0 01             	add    $0x1,%eax
  800d39:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d3c:	39 d8                	cmp    %ebx,%eax
  800d3e:	74 15                	je     800d55 <strncmp+0x30>
  800d40:	0f b6 08             	movzbl (%eax),%ecx
  800d43:	84 c9                	test   %cl,%cl
  800d45:	74 04                	je     800d4b <strncmp+0x26>
  800d47:	3a 0a                	cmp    (%edx),%cl
  800d49:	74 eb                	je     800d36 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d4b:	0f b6 00             	movzbl (%eax),%eax
  800d4e:	0f b6 12             	movzbl (%edx),%edx
  800d51:	29 d0                	sub    %edx,%eax
  800d53:	eb 05                	jmp    800d5a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d55:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d67:	eb 07                	jmp    800d70 <strchr+0x13>
		if (*s == c)
  800d69:	38 ca                	cmp    %cl,%dl
  800d6b:	74 0f                	je     800d7c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d6d:	83 c0 01             	add    $0x1,%eax
  800d70:	0f b6 10             	movzbl (%eax),%edx
  800d73:	84 d2                	test   %dl,%dl
  800d75:	75 f2                	jne    800d69 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d88:	eb 03                	jmp    800d8d <strfind+0xf>
  800d8a:	83 c0 01             	add    $0x1,%eax
  800d8d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d90:	38 ca                	cmp    %cl,%dl
  800d92:	74 04                	je     800d98 <strfind+0x1a>
  800d94:	84 d2                	test   %dl,%dl
  800d96:	75 f2                	jne    800d8a <strfind+0xc>
			break;
	return (char *) s;
}
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800da3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800da6:	85 c9                	test   %ecx,%ecx
  800da8:	74 36                	je     800de0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800daa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800db0:	75 28                	jne    800dda <memset+0x40>
  800db2:	f6 c1 03             	test   $0x3,%cl
  800db5:	75 23                	jne    800dda <memset+0x40>
		c &= 0xFF;
  800db7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dbb:	89 d3                	mov    %edx,%ebx
  800dbd:	c1 e3 08             	shl    $0x8,%ebx
  800dc0:	89 d6                	mov    %edx,%esi
  800dc2:	c1 e6 18             	shl    $0x18,%esi
  800dc5:	89 d0                	mov    %edx,%eax
  800dc7:	c1 e0 10             	shl    $0x10,%eax
  800dca:	09 f0                	or     %esi,%eax
  800dcc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800dce:	89 d8                	mov    %ebx,%eax
  800dd0:	09 d0                	or     %edx,%eax
  800dd2:	c1 e9 02             	shr    $0x2,%ecx
  800dd5:	fc                   	cld    
  800dd6:	f3 ab                	rep stos %eax,%es:(%edi)
  800dd8:	eb 06                	jmp    800de0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddd:	fc                   	cld    
  800dde:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800de0:	89 f8                	mov    %edi,%eax
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
  800def:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800df5:	39 c6                	cmp    %eax,%esi
  800df7:	73 35                	jae    800e2e <memmove+0x47>
  800df9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dfc:	39 d0                	cmp    %edx,%eax
  800dfe:	73 2e                	jae    800e2e <memmove+0x47>
		s += n;
		d += n;
  800e00:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e03:	89 d6                	mov    %edx,%esi
  800e05:	09 fe                	or     %edi,%esi
  800e07:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e0d:	75 13                	jne    800e22 <memmove+0x3b>
  800e0f:	f6 c1 03             	test   $0x3,%cl
  800e12:	75 0e                	jne    800e22 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e14:	83 ef 04             	sub    $0x4,%edi
  800e17:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e1a:	c1 e9 02             	shr    $0x2,%ecx
  800e1d:	fd                   	std    
  800e1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e20:	eb 09                	jmp    800e2b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e22:	83 ef 01             	sub    $0x1,%edi
  800e25:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e28:	fd                   	std    
  800e29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e2b:	fc                   	cld    
  800e2c:	eb 1d                	jmp    800e4b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e2e:	89 f2                	mov    %esi,%edx
  800e30:	09 c2                	or     %eax,%edx
  800e32:	f6 c2 03             	test   $0x3,%dl
  800e35:	75 0f                	jne    800e46 <memmove+0x5f>
  800e37:	f6 c1 03             	test   $0x3,%cl
  800e3a:	75 0a                	jne    800e46 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e3c:	c1 e9 02             	shr    $0x2,%ecx
  800e3f:	89 c7                	mov    %eax,%edi
  800e41:	fc                   	cld    
  800e42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e44:	eb 05                	jmp    800e4b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e46:	89 c7                	mov    %eax,%edi
  800e48:	fc                   	cld    
  800e49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e52:	ff 75 10             	pushl  0x10(%ebp)
  800e55:	ff 75 0c             	pushl  0xc(%ebp)
  800e58:	ff 75 08             	pushl  0x8(%ebp)
  800e5b:	e8 87 ff ff ff       	call   800de7 <memmove>
}
  800e60:	c9                   	leave  
  800e61:	c3                   	ret    

00800e62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6d:	89 c6                	mov    %eax,%esi
  800e6f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e72:	eb 1a                	jmp    800e8e <memcmp+0x2c>
		if (*s1 != *s2)
  800e74:	0f b6 08             	movzbl (%eax),%ecx
  800e77:	0f b6 1a             	movzbl (%edx),%ebx
  800e7a:	38 d9                	cmp    %bl,%cl
  800e7c:	74 0a                	je     800e88 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e7e:	0f b6 c1             	movzbl %cl,%eax
  800e81:	0f b6 db             	movzbl %bl,%ebx
  800e84:	29 d8                	sub    %ebx,%eax
  800e86:	eb 0f                	jmp    800e97 <memcmp+0x35>
		s1++, s2++;
  800e88:	83 c0 01             	add    $0x1,%eax
  800e8b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e8e:	39 f0                	cmp    %esi,%eax
  800e90:	75 e2                	jne    800e74 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	53                   	push   %ebx
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ea2:	89 c1                	mov    %eax,%ecx
  800ea4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eab:	eb 0a                	jmp    800eb7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ead:	0f b6 10             	movzbl (%eax),%edx
  800eb0:	39 da                	cmp    %ebx,%edx
  800eb2:	74 07                	je     800ebb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb4:	83 c0 01             	add    $0x1,%eax
  800eb7:	39 c8                	cmp    %ecx,%eax
  800eb9:	72 f2                	jb     800ead <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ebb:	5b                   	pop    %ebx
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eca:	eb 03                	jmp    800ecf <strtol+0x11>
		s++;
  800ecc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ecf:	0f b6 01             	movzbl (%ecx),%eax
  800ed2:	3c 20                	cmp    $0x20,%al
  800ed4:	74 f6                	je     800ecc <strtol+0xe>
  800ed6:	3c 09                	cmp    $0x9,%al
  800ed8:	74 f2                	je     800ecc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eda:	3c 2b                	cmp    $0x2b,%al
  800edc:	75 0a                	jne    800ee8 <strtol+0x2a>
		s++;
  800ede:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ee1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ee6:	eb 11                	jmp    800ef9 <strtol+0x3b>
  800ee8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800eed:	3c 2d                	cmp    $0x2d,%al
  800eef:	75 08                	jne    800ef9 <strtol+0x3b>
		s++, neg = 1;
  800ef1:	83 c1 01             	add    $0x1,%ecx
  800ef4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ef9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800eff:	75 15                	jne    800f16 <strtol+0x58>
  800f01:	80 39 30             	cmpb   $0x30,(%ecx)
  800f04:	75 10                	jne    800f16 <strtol+0x58>
  800f06:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f0a:	75 7c                	jne    800f88 <strtol+0xca>
		s += 2, base = 16;
  800f0c:	83 c1 02             	add    $0x2,%ecx
  800f0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f14:	eb 16                	jmp    800f2c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f16:	85 db                	test   %ebx,%ebx
  800f18:	75 12                	jne    800f2c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f1a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800f22:	75 08                	jne    800f2c <strtol+0x6e>
		s++, base = 8;
  800f24:	83 c1 01             	add    $0x1,%ecx
  800f27:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f31:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f34:	0f b6 11             	movzbl (%ecx),%edx
  800f37:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f3a:	89 f3                	mov    %esi,%ebx
  800f3c:	80 fb 09             	cmp    $0x9,%bl
  800f3f:	77 08                	ja     800f49 <strtol+0x8b>
			dig = *s - '0';
  800f41:	0f be d2             	movsbl %dl,%edx
  800f44:	83 ea 30             	sub    $0x30,%edx
  800f47:	eb 22                	jmp    800f6b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f49:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f4c:	89 f3                	mov    %esi,%ebx
  800f4e:	80 fb 19             	cmp    $0x19,%bl
  800f51:	77 08                	ja     800f5b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f53:	0f be d2             	movsbl %dl,%edx
  800f56:	83 ea 57             	sub    $0x57,%edx
  800f59:	eb 10                	jmp    800f6b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f5b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f5e:	89 f3                	mov    %esi,%ebx
  800f60:	80 fb 19             	cmp    $0x19,%bl
  800f63:	77 16                	ja     800f7b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f65:	0f be d2             	movsbl %dl,%edx
  800f68:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f6b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f6e:	7d 0b                	jge    800f7b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f70:	83 c1 01             	add    $0x1,%ecx
  800f73:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f77:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f79:	eb b9                	jmp    800f34 <strtol+0x76>

	if (endptr)
  800f7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f7f:	74 0d                	je     800f8e <strtol+0xd0>
		*endptr = (char *) s;
  800f81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f84:	89 0e                	mov    %ecx,(%esi)
  800f86:	eb 06                	jmp    800f8e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f88:	85 db                	test   %ebx,%ebx
  800f8a:	74 98                	je     800f24 <strtol+0x66>
  800f8c:	eb 9e                	jmp    800f2c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f8e:	89 c2                	mov    %eax,%edx
  800f90:	f7 da                	neg    %edx
  800f92:	85 ff                	test   %edi,%edi
  800f94:	0f 45 c2             	cmovne %edx,%eax
}
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	57                   	push   %edi
  800fa0:	56                   	push   %esi
  800fa1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800faa:	8b 55 08             	mov    0x8(%ebp),%edx
  800fad:	89 c3                	mov    %eax,%ebx
  800faf:	89 c7                	mov    %eax,%edi
  800fb1:	89 c6                	mov    %eax,%esi
  800fb3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <sys_cgetc>:

int
sys_cgetc(void)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800fca:	89 d1                	mov    %edx,%ecx
  800fcc:	89 d3                	mov    %edx,%ebx
  800fce:	89 d7                	mov    %edx,%edi
  800fd0:	89 d6                	mov    %edx,%esi
  800fd2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe7:	b8 03 00 00 00       	mov    $0x3,%eax
  800fec:	8b 55 08             	mov    0x8(%ebp),%edx
  800fef:	89 cb                	mov    %ecx,%ebx
  800ff1:	89 cf                	mov    %ecx,%edi
  800ff3:	89 ce                	mov    %ecx,%esi
  800ff5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	7e 17                	jle    801012 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	50                   	push   %eax
  800fff:	6a 03                	push   $0x3
  801001:	68 ff 27 80 00       	push   $0x8027ff
  801006:	6a 23                	push   $0x23
  801008:	68 1c 28 80 00       	push   $0x80281c
  80100d:	e8 e5 f5 ff ff       	call   8005f7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801020:	ba 00 00 00 00       	mov    $0x0,%edx
  801025:	b8 02 00 00 00       	mov    $0x2,%eax
  80102a:	89 d1                	mov    %edx,%ecx
  80102c:	89 d3                	mov    %edx,%ebx
  80102e:	89 d7                	mov    %edx,%edi
  801030:	89 d6                	mov    %edx,%esi
  801032:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_yield>:

void
sys_yield(void)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103f:	ba 00 00 00 00       	mov    $0x0,%edx
  801044:	b8 0b 00 00 00       	mov    $0xb,%eax
  801049:	89 d1                	mov    %edx,%ecx
  80104b:	89 d3                	mov    %edx,%ebx
  80104d:	89 d7                	mov    %edx,%edi
  80104f:	89 d6                	mov    %edx,%esi
  801051:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801061:	be 00 00 00 00       	mov    $0x0,%esi
  801066:	b8 04 00 00 00       	mov    $0x4,%eax
  80106b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106e:	8b 55 08             	mov    0x8(%ebp),%edx
  801071:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801074:	89 f7                	mov    %esi,%edi
  801076:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801078:	85 c0                	test   %eax,%eax
  80107a:	7e 17                	jle    801093 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	50                   	push   %eax
  801080:	6a 04                	push   $0x4
  801082:	68 ff 27 80 00       	push   $0x8027ff
  801087:	6a 23                	push   $0x23
  801089:	68 1c 28 80 00       	push   $0x80281c
  80108e:	e8 64 f5 ff ff       	call   8005f7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801096:	5b                   	pop    %ebx
  801097:	5e                   	pop    %esi
  801098:	5f                   	pop    %edi
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    

0080109b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a4:	b8 05 00 00 00       	mov    $0x5,%eax
  8010a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8010af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b5:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	7e 17                	jle    8010d5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	50                   	push   %eax
  8010c2:	6a 05                	push   $0x5
  8010c4:	68 ff 27 80 00       	push   $0x8027ff
  8010c9:	6a 23                	push   $0x23
  8010cb:	68 1c 28 80 00       	push   $0x80281c
  8010d0:	e8 22 f5 ff ff       	call   8005f7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	57                   	push   %edi
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
  8010e3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f6:	89 df                	mov    %ebx,%edi
  8010f8:	89 de                	mov    %ebx,%esi
  8010fa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	7e 17                	jle    801117 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801100:	83 ec 0c             	sub    $0xc,%esp
  801103:	50                   	push   %eax
  801104:	6a 06                	push   $0x6
  801106:	68 ff 27 80 00       	push   $0x8027ff
  80110b:	6a 23                	push   $0x23
  80110d:	68 1c 28 80 00       	push   $0x80281c
  801112:	e8 e0 f4 ff ff       	call   8005f7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801117:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111a:	5b                   	pop    %ebx
  80111b:	5e                   	pop    %esi
  80111c:	5f                   	pop    %edi
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    

0080111f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	57                   	push   %edi
  801123:	56                   	push   %esi
  801124:	53                   	push   %ebx
  801125:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801128:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112d:	b8 08 00 00 00       	mov    $0x8,%eax
  801132:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801135:	8b 55 08             	mov    0x8(%ebp),%edx
  801138:	89 df                	mov    %ebx,%edi
  80113a:	89 de                	mov    %ebx,%esi
  80113c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80113e:	85 c0                	test   %eax,%eax
  801140:	7e 17                	jle    801159 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801142:	83 ec 0c             	sub    $0xc,%esp
  801145:	50                   	push   %eax
  801146:	6a 08                	push   $0x8
  801148:	68 ff 27 80 00       	push   $0x8027ff
  80114d:	6a 23                	push   $0x23
  80114f:	68 1c 28 80 00       	push   $0x80281c
  801154:	e8 9e f4 ff ff       	call   8005f7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801159:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5f                   	pop    %edi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	57                   	push   %edi
  801165:	56                   	push   %esi
  801166:	53                   	push   %ebx
  801167:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116f:	b8 09 00 00 00       	mov    $0x9,%eax
  801174:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801177:	8b 55 08             	mov    0x8(%ebp),%edx
  80117a:	89 df                	mov    %ebx,%edi
  80117c:	89 de                	mov    %ebx,%esi
  80117e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801180:	85 c0                	test   %eax,%eax
  801182:	7e 17                	jle    80119b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	50                   	push   %eax
  801188:	6a 09                	push   $0x9
  80118a:	68 ff 27 80 00       	push   $0x8027ff
  80118f:	6a 23                	push   $0x23
  801191:	68 1c 28 80 00       	push   $0x80281c
  801196:	e8 5c f4 ff ff       	call   8005f7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80119b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119e:	5b                   	pop    %ebx
  80119f:	5e                   	pop    %esi
  8011a0:	5f                   	pop    %edi
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	57                   	push   %edi
  8011a7:	56                   	push   %esi
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bc:	89 df                	mov    %ebx,%edi
  8011be:	89 de                	mov    %ebx,%esi
  8011c0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	7e 17                	jle    8011dd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c6:	83 ec 0c             	sub    $0xc,%esp
  8011c9:	50                   	push   %eax
  8011ca:	6a 0a                	push   $0xa
  8011cc:	68 ff 27 80 00       	push   $0x8027ff
  8011d1:	6a 23                	push   $0x23
  8011d3:	68 1c 28 80 00       	push   $0x80281c
  8011d8:	e8 1a f4 ff ff       	call   8005f7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011eb:	be 00 00 00 00       	mov    $0x0,%esi
  8011f0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  801201:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801211:	b9 00 00 00 00       	mov    $0x0,%ecx
  801216:	b8 0d 00 00 00       	mov    $0xd,%eax
  80121b:	8b 55 08             	mov    0x8(%ebp),%edx
  80121e:	89 cb                	mov    %ecx,%ebx
  801220:	89 cf                	mov    %ecx,%edi
  801222:	89 ce                	mov    %ecx,%esi
  801224:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801226:	85 c0                	test   %eax,%eax
  801228:	7e 17                	jle    801241 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122a:	83 ec 0c             	sub    $0xc,%esp
  80122d:	50                   	push   %eax
  80122e:	6a 0d                	push   $0xd
  801230:	68 ff 27 80 00       	push   $0x8027ff
  801235:	6a 23                	push   $0x23
  801237:	68 1c 28 80 00       	push   $0x80281c
  80123c:	e8 b6 f3 ff ff       	call   8005f7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5f                   	pop    %edi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  80124f:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  801256:	75 2a                	jne    801282 <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  801258:	83 ec 04             	sub    $0x4,%esp
  80125b:	6a 06                	push   $0x6
  80125d:	68 00 f0 bf ee       	push   $0xeebff000
  801262:	6a 00                	push   $0x0
  801264:	e8 ef fd ff ff       	call   801058 <sys_page_alloc>
			 if (a < 0)
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	85 c0                	test   %eax,%eax
  80126e:	79 12                	jns    801282 <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  801270:	50                   	push   %eax
  801271:	68 2a 28 80 00       	push   $0x80282a
  801276:	6a 21                	push   $0x21
  801278:	68 44 28 80 00       	push   $0x802844
  80127d:	e8 75 f3 ff ff       	call   8005f7 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  801282:	e8 93 fd ff ff       	call   80101a <sys_getenvid>
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	68 a2 12 80 00       	push   $0x8012a2
  80128f:	50                   	push   %eax
  801290:	e8 0e ff ff ff       	call   8011a3 <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  801295:	8b 45 08             	mov    0x8(%ebp),%eax
  801298:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	c9                   	leave  
  8012a1:	c3                   	ret    

008012a2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  8012a2:	54                   	push   %esp
movl _pgfault_handler, %eax
  8012a3:	a1 b4 40 80 00       	mov    0x8040b4,%eax
call *%eax
  8012a8:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  8012aa:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  8012ad:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  8012b1:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  8012b5:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  8012b8:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  8012bc:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  8012be:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  8012c1:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  8012c2:	83 c4 04             	add    $0x4,%esp
popfl
  8012c5:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  8012c6:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  8012c7:	c3                   	ret    

008012c8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ce:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d3:	c1 e8 0c             	shr    $0xc,%eax
}
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    

008012d8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012db:	8b 45 08             	mov    0x8(%ebp),%eax
  8012de:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012e8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    

008012ef <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012fa:	89 c2                	mov    %eax,%edx
  8012fc:	c1 ea 16             	shr    $0x16,%edx
  8012ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801306:	f6 c2 01             	test   $0x1,%dl
  801309:	74 11                	je     80131c <fd_alloc+0x2d>
  80130b:	89 c2                	mov    %eax,%edx
  80130d:	c1 ea 0c             	shr    $0xc,%edx
  801310:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801317:	f6 c2 01             	test   $0x1,%dl
  80131a:	75 09                	jne    801325 <fd_alloc+0x36>
			*fd_store = fd;
  80131c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80131e:	b8 00 00 00 00       	mov    $0x0,%eax
  801323:	eb 17                	jmp    80133c <fd_alloc+0x4d>
  801325:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80132a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80132f:	75 c9                	jne    8012fa <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801331:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801337:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801344:	83 f8 1f             	cmp    $0x1f,%eax
  801347:	77 36                	ja     80137f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801349:	c1 e0 0c             	shl    $0xc,%eax
  80134c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801351:	89 c2                	mov    %eax,%edx
  801353:	c1 ea 16             	shr    $0x16,%edx
  801356:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80135d:	f6 c2 01             	test   $0x1,%dl
  801360:	74 24                	je     801386 <fd_lookup+0x48>
  801362:	89 c2                	mov    %eax,%edx
  801364:	c1 ea 0c             	shr    $0xc,%edx
  801367:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80136e:	f6 c2 01             	test   $0x1,%dl
  801371:	74 1a                	je     80138d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801373:	8b 55 0c             	mov    0xc(%ebp),%edx
  801376:	89 02                	mov    %eax,(%edx)
	return 0;
  801378:	b8 00 00 00 00       	mov    $0x0,%eax
  80137d:	eb 13                	jmp    801392 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80137f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801384:	eb 0c                	jmp    801392 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801386:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138b:	eb 05                	jmp    801392 <fd_lookup+0x54>
  80138d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    

00801394 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139d:	ba d4 28 80 00       	mov    $0x8028d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013a2:	eb 13                	jmp    8013b7 <dev_lookup+0x23>
  8013a4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013a7:	39 08                	cmp    %ecx,(%eax)
  8013a9:	75 0c                	jne    8013b7 <dev_lookup+0x23>
			*dev = devtab[i];
  8013ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ae:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b5:	eb 2e                	jmp    8013e5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013b7:	8b 02                	mov    (%edx),%eax
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	75 e7                	jne    8013a4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013bd:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8013c2:	8b 40 48             	mov    0x48(%eax),%eax
  8013c5:	83 ec 04             	sub    $0x4,%esp
  8013c8:	51                   	push   %ecx
  8013c9:	50                   	push   %eax
  8013ca:	68 54 28 80 00       	push   $0x802854
  8013cf:	e8 fc f2 ff ff       	call   8006d0 <cprintf>
	*dev = 0;
  8013d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	56                   	push   %esi
  8013eb:	53                   	push   %ebx
  8013ec:	83 ec 10             	sub    $0x10,%esp
  8013ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f8:	50                   	push   %eax
  8013f9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013ff:	c1 e8 0c             	shr    $0xc,%eax
  801402:	50                   	push   %eax
  801403:	e8 36 ff ff ff       	call   80133e <fd_lookup>
  801408:	83 c4 08             	add    $0x8,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 05                	js     801414 <fd_close+0x2d>
	    || fd != fd2)
  80140f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801412:	74 0c                	je     801420 <fd_close+0x39>
		return (must_exist ? r : 0);
  801414:	84 db                	test   %bl,%bl
  801416:	ba 00 00 00 00       	mov    $0x0,%edx
  80141b:	0f 44 c2             	cmove  %edx,%eax
  80141e:	eb 41                	jmp    801461 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801426:	50                   	push   %eax
  801427:	ff 36                	pushl  (%esi)
  801429:	e8 66 ff ff ff       	call   801394 <dev_lookup>
  80142e:	89 c3                	mov    %eax,%ebx
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	78 1a                	js     801451 <fd_close+0x6a>
		if (dev->dev_close)
  801437:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80143d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801442:	85 c0                	test   %eax,%eax
  801444:	74 0b                	je     801451 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801446:	83 ec 0c             	sub    $0xc,%esp
  801449:	56                   	push   %esi
  80144a:	ff d0                	call   *%eax
  80144c:	89 c3                	mov    %eax,%ebx
  80144e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	56                   	push   %esi
  801455:	6a 00                	push   $0x0
  801457:	e8 81 fc ff ff       	call   8010dd <sys_page_unmap>
	return r;
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	89 d8                	mov    %ebx,%eax
}
  801461:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801464:	5b                   	pop    %ebx
  801465:	5e                   	pop    %esi
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	ff 75 08             	pushl  0x8(%ebp)
  801475:	e8 c4 fe ff ff       	call   80133e <fd_lookup>
  80147a:	83 c4 08             	add    $0x8,%esp
  80147d:	85 c0                	test   %eax,%eax
  80147f:	78 10                	js     801491 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	6a 01                	push   $0x1
  801486:	ff 75 f4             	pushl  -0xc(%ebp)
  801489:	e8 59 ff ff ff       	call   8013e7 <fd_close>
  80148e:	83 c4 10             	add    $0x10,%esp
}
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <close_all>:

void
close_all(void)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	53                   	push   %ebx
  801497:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80149a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80149f:	83 ec 0c             	sub    $0xc,%esp
  8014a2:	53                   	push   %ebx
  8014a3:	e8 c0 ff ff ff       	call   801468 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014a8:	83 c3 01             	add    $0x1,%ebx
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	83 fb 20             	cmp    $0x20,%ebx
  8014b1:	75 ec                	jne    80149f <close_all+0xc>
		close(i);
}
  8014b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b6:	c9                   	leave  
  8014b7:	c3                   	ret    

008014b8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	57                   	push   %edi
  8014bc:	56                   	push   %esi
  8014bd:	53                   	push   %ebx
  8014be:	83 ec 2c             	sub    $0x2c,%esp
  8014c1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	ff 75 08             	pushl  0x8(%ebp)
  8014cb:	e8 6e fe ff ff       	call   80133e <fd_lookup>
  8014d0:	83 c4 08             	add    $0x8,%esp
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	0f 88 c1 00 00 00    	js     80159c <dup+0xe4>
		return r;
	close(newfdnum);
  8014db:	83 ec 0c             	sub    $0xc,%esp
  8014de:	56                   	push   %esi
  8014df:	e8 84 ff ff ff       	call   801468 <close>

	newfd = INDEX2FD(newfdnum);
  8014e4:	89 f3                	mov    %esi,%ebx
  8014e6:	c1 e3 0c             	shl    $0xc,%ebx
  8014e9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014ef:	83 c4 04             	add    $0x4,%esp
  8014f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014f5:	e8 de fd ff ff       	call   8012d8 <fd2data>
  8014fa:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014fc:	89 1c 24             	mov    %ebx,(%esp)
  8014ff:	e8 d4 fd ff ff       	call   8012d8 <fd2data>
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80150a:	89 f8                	mov    %edi,%eax
  80150c:	c1 e8 16             	shr    $0x16,%eax
  80150f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801516:	a8 01                	test   $0x1,%al
  801518:	74 37                	je     801551 <dup+0x99>
  80151a:	89 f8                	mov    %edi,%eax
  80151c:	c1 e8 0c             	shr    $0xc,%eax
  80151f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801526:	f6 c2 01             	test   $0x1,%dl
  801529:	74 26                	je     801551 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80152b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801532:	83 ec 0c             	sub    $0xc,%esp
  801535:	25 07 0e 00 00       	and    $0xe07,%eax
  80153a:	50                   	push   %eax
  80153b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80153e:	6a 00                	push   $0x0
  801540:	57                   	push   %edi
  801541:	6a 00                	push   $0x0
  801543:	e8 53 fb ff ff       	call   80109b <sys_page_map>
  801548:	89 c7                	mov    %eax,%edi
  80154a:	83 c4 20             	add    $0x20,%esp
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 2e                	js     80157f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801551:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801554:	89 d0                	mov    %edx,%eax
  801556:	c1 e8 0c             	shr    $0xc,%eax
  801559:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801560:	83 ec 0c             	sub    $0xc,%esp
  801563:	25 07 0e 00 00       	and    $0xe07,%eax
  801568:	50                   	push   %eax
  801569:	53                   	push   %ebx
  80156a:	6a 00                	push   $0x0
  80156c:	52                   	push   %edx
  80156d:	6a 00                	push   $0x0
  80156f:	e8 27 fb ff ff       	call   80109b <sys_page_map>
  801574:	89 c7                	mov    %eax,%edi
  801576:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801579:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80157b:	85 ff                	test   %edi,%edi
  80157d:	79 1d                	jns    80159c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	53                   	push   %ebx
  801583:	6a 00                	push   $0x0
  801585:	e8 53 fb ff ff       	call   8010dd <sys_page_unmap>
	sys_page_unmap(0, nva);
  80158a:	83 c4 08             	add    $0x8,%esp
  80158d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801590:	6a 00                	push   $0x0
  801592:	e8 46 fb ff ff       	call   8010dd <sys_page_unmap>
	return r;
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	89 f8                	mov    %edi,%eax
}
  80159c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80159f:	5b                   	pop    %ebx
  8015a0:	5e                   	pop    %esi
  8015a1:	5f                   	pop    %edi
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    

008015a4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	53                   	push   %ebx
  8015a8:	83 ec 14             	sub    $0x14,%esp
  8015ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	53                   	push   %ebx
  8015b3:	e8 86 fd ff ff       	call   80133e <fd_lookup>
  8015b8:	83 c4 08             	add    $0x8,%esp
  8015bb:	89 c2                	mov    %eax,%edx
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 6d                	js     80162e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cb:	ff 30                	pushl  (%eax)
  8015cd:	e8 c2 fd ff ff       	call   801394 <dev_lookup>
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 4c                	js     801625 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015dc:	8b 42 08             	mov    0x8(%edx),%eax
  8015df:	83 e0 03             	and    $0x3,%eax
  8015e2:	83 f8 01             	cmp    $0x1,%eax
  8015e5:	75 21                	jne    801608 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e7:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8015ec:	8b 40 48             	mov    0x48(%eax),%eax
  8015ef:	83 ec 04             	sub    $0x4,%esp
  8015f2:	53                   	push   %ebx
  8015f3:	50                   	push   %eax
  8015f4:	68 98 28 80 00       	push   $0x802898
  8015f9:	e8 d2 f0 ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801606:	eb 26                	jmp    80162e <read+0x8a>
	}
	if (!dev->dev_read)
  801608:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160b:	8b 40 08             	mov    0x8(%eax),%eax
  80160e:	85 c0                	test   %eax,%eax
  801610:	74 17                	je     801629 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801612:	83 ec 04             	sub    $0x4,%esp
  801615:	ff 75 10             	pushl  0x10(%ebp)
  801618:	ff 75 0c             	pushl  0xc(%ebp)
  80161b:	52                   	push   %edx
  80161c:	ff d0                	call   *%eax
  80161e:	89 c2                	mov    %eax,%edx
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	eb 09                	jmp    80162e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801625:	89 c2                	mov    %eax,%edx
  801627:	eb 05                	jmp    80162e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801629:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80162e:	89 d0                	mov    %edx,%eax
  801630:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801633:	c9                   	leave  
  801634:	c3                   	ret    

00801635 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	57                   	push   %edi
  801639:	56                   	push   %esi
  80163a:	53                   	push   %ebx
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801641:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801644:	bb 00 00 00 00       	mov    $0x0,%ebx
  801649:	eb 21                	jmp    80166c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80164b:	83 ec 04             	sub    $0x4,%esp
  80164e:	89 f0                	mov    %esi,%eax
  801650:	29 d8                	sub    %ebx,%eax
  801652:	50                   	push   %eax
  801653:	89 d8                	mov    %ebx,%eax
  801655:	03 45 0c             	add    0xc(%ebp),%eax
  801658:	50                   	push   %eax
  801659:	57                   	push   %edi
  80165a:	e8 45 ff ff ff       	call   8015a4 <read>
		if (m < 0)
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	85 c0                	test   %eax,%eax
  801664:	78 10                	js     801676 <readn+0x41>
			return m;
		if (m == 0)
  801666:	85 c0                	test   %eax,%eax
  801668:	74 0a                	je     801674 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80166a:	01 c3                	add    %eax,%ebx
  80166c:	39 f3                	cmp    %esi,%ebx
  80166e:	72 db                	jb     80164b <readn+0x16>
  801670:	89 d8                	mov    %ebx,%eax
  801672:	eb 02                	jmp    801676 <readn+0x41>
  801674:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801676:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801679:	5b                   	pop    %ebx
  80167a:	5e                   	pop    %esi
  80167b:	5f                   	pop    %edi
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	53                   	push   %ebx
  801682:	83 ec 14             	sub    $0x14,%esp
  801685:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801688:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168b:	50                   	push   %eax
  80168c:	53                   	push   %ebx
  80168d:	e8 ac fc ff ff       	call   80133e <fd_lookup>
  801692:	83 c4 08             	add    $0x8,%esp
  801695:	89 c2                	mov    %eax,%edx
  801697:	85 c0                	test   %eax,%eax
  801699:	78 68                	js     801703 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	ff 30                	pushl  (%eax)
  8016a7:	e8 e8 fc ff ff       	call   801394 <dev_lookup>
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 47                	js     8016fa <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ba:	75 21                	jne    8016dd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016bc:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8016c1:	8b 40 48             	mov    0x48(%eax),%eax
  8016c4:	83 ec 04             	sub    $0x4,%esp
  8016c7:	53                   	push   %ebx
  8016c8:	50                   	push   %eax
  8016c9:	68 b4 28 80 00       	push   $0x8028b4
  8016ce:	e8 fd ef ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016db:	eb 26                	jmp    801703 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e0:	8b 52 0c             	mov    0xc(%edx),%edx
  8016e3:	85 d2                	test   %edx,%edx
  8016e5:	74 17                	je     8016fe <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016e7:	83 ec 04             	sub    $0x4,%esp
  8016ea:	ff 75 10             	pushl  0x10(%ebp)
  8016ed:	ff 75 0c             	pushl  0xc(%ebp)
  8016f0:	50                   	push   %eax
  8016f1:	ff d2                	call   *%edx
  8016f3:	89 c2                	mov    %eax,%edx
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	eb 09                	jmp    801703 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	eb 05                	jmp    801703 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801703:	89 d0                	mov    %edx,%eax
  801705:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <seek>:

int
seek(int fdnum, off_t offset)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801710:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801713:	50                   	push   %eax
  801714:	ff 75 08             	pushl  0x8(%ebp)
  801717:	e8 22 fc ff ff       	call   80133e <fd_lookup>
  80171c:	83 c4 08             	add    $0x8,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 0e                	js     801731 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801723:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801726:	8b 55 0c             	mov    0xc(%ebp),%edx
  801729:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80172c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801731:	c9                   	leave  
  801732:	c3                   	ret    

00801733 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	53                   	push   %ebx
  801737:	83 ec 14             	sub    $0x14,%esp
  80173a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801740:	50                   	push   %eax
  801741:	53                   	push   %ebx
  801742:	e8 f7 fb ff ff       	call   80133e <fd_lookup>
  801747:	83 c4 08             	add    $0x8,%esp
  80174a:	89 c2                	mov    %eax,%edx
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 65                	js     8017b5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801756:	50                   	push   %eax
  801757:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175a:	ff 30                	pushl  (%eax)
  80175c:	e8 33 fc ff ff       	call   801394 <dev_lookup>
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	85 c0                	test   %eax,%eax
  801766:	78 44                	js     8017ac <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801768:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80176f:	75 21                	jne    801792 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801771:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801776:	8b 40 48             	mov    0x48(%eax),%eax
  801779:	83 ec 04             	sub    $0x4,%esp
  80177c:	53                   	push   %ebx
  80177d:	50                   	push   %eax
  80177e:	68 74 28 80 00       	push   $0x802874
  801783:	e8 48 ef ff ff       	call   8006d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801790:	eb 23                	jmp    8017b5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801792:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801795:	8b 52 18             	mov    0x18(%edx),%edx
  801798:	85 d2                	test   %edx,%edx
  80179a:	74 14                	je     8017b0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80179c:	83 ec 08             	sub    $0x8,%esp
  80179f:	ff 75 0c             	pushl  0xc(%ebp)
  8017a2:	50                   	push   %eax
  8017a3:	ff d2                	call   *%edx
  8017a5:	89 c2                	mov    %eax,%edx
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	eb 09                	jmp    8017b5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ac:	89 c2                	mov    %eax,%edx
  8017ae:	eb 05                	jmp    8017b5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017b5:	89 d0                	mov    %edx,%eax
  8017b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ba:	c9                   	leave  
  8017bb:	c3                   	ret    

008017bc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	53                   	push   %ebx
  8017c0:	83 ec 14             	sub    $0x14,%esp
  8017c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c9:	50                   	push   %eax
  8017ca:	ff 75 08             	pushl  0x8(%ebp)
  8017cd:	e8 6c fb ff ff       	call   80133e <fd_lookup>
  8017d2:	83 c4 08             	add    $0x8,%esp
  8017d5:	89 c2                	mov    %eax,%edx
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	78 58                	js     801833 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017db:	83 ec 08             	sub    $0x8,%esp
  8017de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e1:	50                   	push   %eax
  8017e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e5:	ff 30                	pushl  (%eax)
  8017e7:	e8 a8 fb ff ff       	call   801394 <dev_lookup>
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	78 37                	js     80182a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017fa:	74 32                	je     80182e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017fc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ff:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801806:	00 00 00 
	stat->st_isdir = 0;
  801809:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801810:	00 00 00 
	stat->st_dev = dev;
  801813:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801819:	83 ec 08             	sub    $0x8,%esp
  80181c:	53                   	push   %ebx
  80181d:	ff 75 f0             	pushl  -0x10(%ebp)
  801820:	ff 50 14             	call   *0x14(%eax)
  801823:	89 c2                	mov    %eax,%edx
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	eb 09                	jmp    801833 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182a:	89 c2                	mov    %eax,%edx
  80182c:	eb 05                	jmp    801833 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80182e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801833:	89 d0                	mov    %edx,%eax
  801835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801838:	c9                   	leave  
  801839:	c3                   	ret    

0080183a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	56                   	push   %esi
  80183e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80183f:	83 ec 08             	sub    $0x8,%esp
  801842:	6a 00                	push   $0x0
  801844:	ff 75 08             	pushl  0x8(%ebp)
  801847:	e8 2c 02 00 00       	call   801a78 <open>
  80184c:	89 c3                	mov    %eax,%ebx
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	85 c0                	test   %eax,%eax
  801853:	78 1b                	js     801870 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	ff 75 0c             	pushl  0xc(%ebp)
  80185b:	50                   	push   %eax
  80185c:	e8 5b ff ff ff       	call   8017bc <fstat>
  801861:	89 c6                	mov    %eax,%esi
	close(fd);
  801863:	89 1c 24             	mov    %ebx,(%esp)
  801866:	e8 fd fb ff ff       	call   801468 <close>
	return r;
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	89 f0                	mov    %esi,%eax
}
  801870:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801873:	5b                   	pop    %ebx
  801874:	5e                   	pop    %esi
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    

00801877 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	56                   	push   %esi
  80187b:	53                   	push   %ebx
  80187c:	89 c6                	mov    %eax,%esi
  80187e:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  801880:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801887:	75 12                	jne    80189b <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  801889:	83 ec 0c             	sub    $0xc,%esp
  80188c:	6a 01                	push   $0x1
  80188e:	e8 1b 08 00 00       	call   8020ae <ipc_find_env>
  801893:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801898:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80189b:	6a 07                	push   $0x7
  80189d:	68 00 50 80 00       	push   $0x805000
  8018a2:	56                   	push   %esi
  8018a3:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8018a9:	e8 ac 07 00 00       	call   80205a <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  8018ae:	83 c4 0c             	add    $0xc,%esp
  8018b1:	6a 00                	push   $0x0
  8018b3:	53                   	push   %ebx
  8018b4:	6a 00                	push   $0x0
  8018b6:	e8 40 07 00 00       	call   801ffb <ipc_recv>
}
  8018bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018be:	5b                   	pop    %ebx
  8018bf:	5e                   	pop    %esi
  8018c0:	5d                   	pop    %ebp
  8018c1:	c3                   	ret    

008018c2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ce:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  8018d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d6:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  8018db:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e0:	b8 02 00 00 00       	mov    $0x2,%eax
  8018e5:	e8 8d ff ff ff       	call   801877 <fsipc>
}
  8018ea:	c9                   	leave  
  8018eb:	c3                   	ret    

008018ec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f8:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 06 00 00 00       	mov    $0x6,%eax
  801907:	e8 6b ff ff ff       	call   801877 <fsipc>
}
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	53                   	push   %ebx
  801912:	83 ec 04             	sub    $0x4,%esp
  801915:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801918:	8b 45 08             	mov    0x8(%ebp),%eax
  80191b:	8b 40 0c             	mov    0xc(%eax),%eax
  80191e:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801923:	ba 00 00 00 00       	mov    $0x0,%edx
  801928:	b8 05 00 00 00       	mov    $0x5,%eax
  80192d:	e8 45 ff ff ff       	call   801877 <fsipc>
  801932:	85 c0                	test   %eax,%eax
  801934:	78 2c                	js     801962 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801936:	83 ec 08             	sub    $0x8,%esp
  801939:	68 00 50 80 00       	push   $0x805000
  80193e:	53                   	push   %ebx
  80193f:	e8 11 f3 ff ff       	call   800c55 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  801944:	a1 80 50 80 00       	mov    0x805080,%eax
  801949:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80194f:	a1 84 50 80 00       	mov    0x805084,%eax
  801954:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801962:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	53                   	push   %ebx
  80196b:	83 ec 08             	sub    $0x8,%esp
  80196e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  801971:	8b 45 08             	mov    0x8(%ebp),%eax
  801974:	8b 40 0c             	mov    0xc(%eax),%eax
  801977:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  80197c:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  801982:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801988:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  80198d:	0f 46 c3             	cmovbe %ebx,%eax
  801990:	50                   	push   %eax
  801991:	ff 75 0c             	pushl  0xc(%ebp)
  801994:	68 08 50 80 00       	push   $0x805008
  801999:	e8 49 f4 ff ff       	call   800de7 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  80199e:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8019a8:	e8 ca fe ff ff       	call   801877 <fsipc>
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	78 3d                	js     8019f1 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  8019b4:	39 c3                	cmp    %eax,%ebx
  8019b6:	73 19                	jae    8019d1 <devfile_write+0x6a>
  8019b8:	68 e4 28 80 00       	push   $0x8028e4
  8019bd:	68 eb 28 80 00       	push   $0x8028eb
  8019c2:	68 9a 00 00 00       	push   $0x9a
  8019c7:	68 00 29 80 00       	push   $0x802900
  8019cc:	e8 26 ec ff ff       	call   8005f7 <_panic>
	   assert (r <= bytes_written);
  8019d1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019d6:	7e 19                	jle    8019f1 <devfile_write+0x8a>
  8019d8:	68 0b 29 80 00       	push   $0x80290b
  8019dd:	68 eb 28 80 00       	push   $0x8028eb
  8019e2:	68 9b 00 00 00       	push   $0x9b
  8019e7:	68 00 29 80 00       	push   $0x802900
  8019ec:	e8 06 ec ff ff       	call   8005f7 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  8019f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	56                   	push   %esi
  8019fa:	53                   	push   %ebx
  8019fb:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	8b 40 0c             	mov    0xc(%eax),%eax
  801a04:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  801a09:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a14:	b8 03 00 00 00       	mov    $0x3,%eax
  801a19:	e8 59 fe ff ff       	call   801877 <fsipc>
  801a1e:	89 c3                	mov    %eax,%ebx
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 4b                	js     801a6f <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  801a24:	39 c6                	cmp    %eax,%esi
  801a26:	73 16                	jae    801a3e <devfile_read+0x48>
  801a28:	68 e4 28 80 00       	push   $0x8028e4
  801a2d:	68 eb 28 80 00       	push   $0x8028eb
  801a32:	6a 7c                	push   $0x7c
  801a34:	68 00 29 80 00       	push   $0x802900
  801a39:	e8 b9 eb ff ff       	call   8005f7 <_panic>
	   assert(r <= PGSIZE);
  801a3e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a43:	7e 16                	jle    801a5b <devfile_read+0x65>
  801a45:	68 1e 29 80 00       	push   $0x80291e
  801a4a:	68 eb 28 80 00       	push   $0x8028eb
  801a4f:	6a 7d                	push   $0x7d
  801a51:	68 00 29 80 00       	push   $0x802900
  801a56:	e8 9c eb ff ff       	call   8005f7 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a5b:	83 ec 04             	sub    $0x4,%esp
  801a5e:	50                   	push   %eax
  801a5f:	68 00 50 80 00       	push   $0x805000
  801a64:	ff 75 0c             	pushl  0xc(%ebp)
  801a67:	e8 7b f3 ff ff       	call   800de7 <memmove>
	   return r;
  801a6c:	83 c4 10             	add    $0x10,%esp
}
  801a6f:	89 d8                	mov    %ebx,%eax
  801a71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a74:	5b                   	pop    %ebx
  801a75:	5e                   	pop    %esi
  801a76:	5d                   	pop    %ebp
  801a77:	c3                   	ret    

00801a78 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	53                   	push   %ebx
  801a7c:	83 ec 20             	sub    $0x20,%esp
  801a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  801a82:	53                   	push   %ebx
  801a83:	e8 94 f1 ff ff       	call   800c1c <strlen>
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a90:	7f 67                	jg     801af9 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801a92:	83 ec 0c             	sub    $0xc,%esp
  801a95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a98:	50                   	push   %eax
  801a99:	e8 51 f8 ff ff       	call   8012ef <fd_alloc>
  801a9e:	83 c4 10             	add    $0x10,%esp
			 return r;
  801aa1:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	78 57                	js     801afe <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  801aa7:	83 ec 08             	sub    $0x8,%esp
  801aaa:	53                   	push   %ebx
  801aab:	68 00 50 80 00       	push   $0x805000
  801ab0:	e8 a0 f1 ff ff       	call   800c55 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  801ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab8:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801abd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ac0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ac5:	e8 ad fd ff ff       	call   801877 <fsipc>
  801aca:	89 c3                	mov    %eax,%ebx
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	79 14                	jns    801ae7 <open+0x6f>
			 fd_close(fd, 0);
  801ad3:	83 ec 08             	sub    $0x8,%esp
  801ad6:	6a 00                	push   $0x0
  801ad8:	ff 75 f4             	pushl  -0xc(%ebp)
  801adb:	e8 07 f9 ff ff       	call   8013e7 <fd_close>
			 return r;
  801ae0:	83 c4 10             	add    $0x10,%esp
  801ae3:	89 da                	mov    %ebx,%edx
  801ae5:	eb 17                	jmp    801afe <open+0x86>
	   }

	   return fd2num(fd);
  801ae7:	83 ec 0c             	sub    $0xc,%esp
  801aea:	ff 75 f4             	pushl  -0xc(%ebp)
  801aed:	e8 d6 f7 ff ff       	call   8012c8 <fd2num>
  801af2:	89 c2                	mov    %eax,%edx
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	eb 05                	jmp    801afe <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  801af9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  801afe:	89 d0                	mov    %edx,%eax
  801b00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  801b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b10:	b8 08 00 00 00       	mov    $0x8,%eax
  801b15:	e8 5d fd ff ff       	call   801877 <fsipc>
}
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	56                   	push   %esi
  801b20:	53                   	push   %ebx
  801b21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b24:	83 ec 0c             	sub    $0xc,%esp
  801b27:	ff 75 08             	pushl  0x8(%ebp)
  801b2a:	e8 a9 f7 ff ff       	call   8012d8 <fd2data>
  801b2f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b31:	83 c4 08             	add    $0x8,%esp
  801b34:	68 2a 29 80 00       	push   $0x80292a
  801b39:	53                   	push   %ebx
  801b3a:	e8 16 f1 ff ff       	call   800c55 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b3f:	8b 46 04             	mov    0x4(%esi),%eax
  801b42:	2b 06                	sub    (%esi),%eax
  801b44:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b4a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b51:	00 00 00 
	stat->st_dev = &devpipe;
  801b54:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b5b:	30 80 00 
	return 0;
}
  801b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b66:	5b                   	pop    %ebx
  801b67:	5e                   	pop    %esi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	53                   	push   %ebx
  801b6e:	83 ec 0c             	sub    $0xc,%esp
  801b71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b74:	53                   	push   %ebx
  801b75:	6a 00                	push   $0x0
  801b77:	e8 61 f5 ff ff       	call   8010dd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b7c:	89 1c 24             	mov    %ebx,(%esp)
  801b7f:	e8 54 f7 ff ff       	call   8012d8 <fd2data>
  801b84:	83 c4 08             	add    $0x8,%esp
  801b87:	50                   	push   %eax
  801b88:	6a 00                	push   $0x0
  801b8a:	e8 4e f5 ff ff       	call   8010dd <sys_page_unmap>
}
  801b8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	57                   	push   %edi
  801b98:	56                   	push   %esi
  801b99:	53                   	push   %ebx
  801b9a:	83 ec 1c             	sub    $0x1c,%esp
  801b9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ba0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ba2:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801ba7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801baa:	83 ec 0c             	sub    $0xc,%esp
  801bad:	ff 75 e0             	pushl  -0x20(%ebp)
  801bb0:	e8 32 05 00 00       	call   8020e7 <pageref>
  801bb5:	89 c3                	mov    %eax,%ebx
  801bb7:	89 3c 24             	mov    %edi,(%esp)
  801bba:	e8 28 05 00 00       	call   8020e7 <pageref>
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	39 c3                	cmp    %eax,%ebx
  801bc4:	0f 94 c1             	sete   %cl
  801bc7:	0f b6 c9             	movzbl %cl,%ecx
  801bca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bcd:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801bd3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bd6:	39 ce                	cmp    %ecx,%esi
  801bd8:	74 1b                	je     801bf5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bda:	39 c3                	cmp    %eax,%ebx
  801bdc:	75 c4                	jne    801ba2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bde:	8b 42 58             	mov    0x58(%edx),%eax
  801be1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801be4:	50                   	push   %eax
  801be5:	56                   	push   %esi
  801be6:	68 31 29 80 00       	push   $0x802931
  801beb:	e8 e0 ea ff ff       	call   8006d0 <cprintf>
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	eb ad                	jmp    801ba2 <_pipeisclosed+0xe>
	}
}
  801bf5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfb:	5b                   	pop    %ebx
  801bfc:	5e                   	pop    %esi
  801bfd:	5f                   	pop    %edi
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    

00801c00 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	57                   	push   %edi
  801c04:	56                   	push   %esi
  801c05:	53                   	push   %ebx
  801c06:	83 ec 28             	sub    $0x28,%esp
  801c09:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c0c:	56                   	push   %esi
  801c0d:	e8 c6 f6 ff ff       	call   8012d8 <fd2data>
  801c12:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	bf 00 00 00 00       	mov    $0x0,%edi
  801c1c:	eb 4b                	jmp    801c69 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c1e:	89 da                	mov    %ebx,%edx
  801c20:	89 f0                	mov    %esi,%eax
  801c22:	e8 6d ff ff ff       	call   801b94 <_pipeisclosed>
  801c27:	85 c0                	test   %eax,%eax
  801c29:	75 48                	jne    801c73 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c2b:	e8 09 f4 ff ff       	call   801039 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c30:	8b 43 04             	mov    0x4(%ebx),%eax
  801c33:	8b 0b                	mov    (%ebx),%ecx
  801c35:	8d 51 20             	lea    0x20(%ecx),%edx
  801c38:	39 d0                	cmp    %edx,%eax
  801c3a:	73 e2                	jae    801c1e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c3f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c43:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c46:	89 c2                	mov    %eax,%edx
  801c48:	c1 fa 1f             	sar    $0x1f,%edx
  801c4b:	89 d1                	mov    %edx,%ecx
  801c4d:	c1 e9 1b             	shr    $0x1b,%ecx
  801c50:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c53:	83 e2 1f             	and    $0x1f,%edx
  801c56:	29 ca                	sub    %ecx,%edx
  801c58:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c5c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c60:	83 c0 01             	add    $0x1,%eax
  801c63:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c66:	83 c7 01             	add    $0x1,%edi
  801c69:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c6c:	75 c2                	jne    801c30 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c6e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c71:	eb 05                	jmp    801c78 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c73:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7b:	5b                   	pop    %ebx
  801c7c:	5e                   	pop    %esi
  801c7d:	5f                   	pop    %edi
  801c7e:	5d                   	pop    %ebp
  801c7f:	c3                   	ret    

00801c80 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	57                   	push   %edi
  801c84:	56                   	push   %esi
  801c85:	53                   	push   %ebx
  801c86:	83 ec 18             	sub    $0x18,%esp
  801c89:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c8c:	57                   	push   %edi
  801c8d:	e8 46 f6 ff ff       	call   8012d8 <fd2data>
  801c92:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c9c:	eb 3d                	jmp    801cdb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c9e:	85 db                	test   %ebx,%ebx
  801ca0:	74 04                	je     801ca6 <devpipe_read+0x26>
				return i;
  801ca2:	89 d8                	mov    %ebx,%eax
  801ca4:	eb 44                	jmp    801cea <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ca6:	89 f2                	mov    %esi,%edx
  801ca8:	89 f8                	mov    %edi,%eax
  801caa:	e8 e5 fe ff ff       	call   801b94 <_pipeisclosed>
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	75 32                	jne    801ce5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cb3:	e8 81 f3 ff ff       	call   801039 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cb8:	8b 06                	mov    (%esi),%eax
  801cba:	3b 46 04             	cmp    0x4(%esi),%eax
  801cbd:	74 df                	je     801c9e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cbf:	99                   	cltd   
  801cc0:	c1 ea 1b             	shr    $0x1b,%edx
  801cc3:	01 d0                	add    %edx,%eax
  801cc5:	83 e0 1f             	and    $0x1f,%eax
  801cc8:	29 d0                	sub    %edx,%eax
  801cca:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cd5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd8:	83 c3 01             	add    $0x1,%ebx
  801cdb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cde:	75 d8                	jne    801cb8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ce0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ce3:	eb 05                	jmp    801cea <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ce5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    

00801cf2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	56                   	push   %esi
  801cf6:	53                   	push   %ebx
  801cf7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfd:	50                   	push   %eax
  801cfe:	e8 ec f5 ff ff       	call   8012ef <fd_alloc>
  801d03:	83 c4 10             	add    $0x10,%esp
  801d06:	89 c2                	mov    %eax,%edx
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	0f 88 2c 01 00 00    	js     801e3c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d10:	83 ec 04             	sub    $0x4,%esp
  801d13:	68 07 04 00 00       	push   $0x407
  801d18:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1b:	6a 00                	push   $0x0
  801d1d:	e8 36 f3 ff ff       	call   801058 <sys_page_alloc>
  801d22:	83 c4 10             	add    $0x10,%esp
  801d25:	89 c2                	mov    %eax,%edx
  801d27:	85 c0                	test   %eax,%eax
  801d29:	0f 88 0d 01 00 00    	js     801e3c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d2f:	83 ec 0c             	sub    $0xc,%esp
  801d32:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d35:	50                   	push   %eax
  801d36:	e8 b4 f5 ff ff       	call   8012ef <fd_alloc>
  801d3b:	89 c3                	mov    %eax,%ebx
  801d3d:	83 c4 10             	add    $0x10,%esp
  801d40:	85 c0                	test   %eax,%eax
  801d42:	0f 88 e2 00 00 00    	js     801e2a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d48:	83 ec 04             	sub    $0x4,%esp
  801d4b:	68 07 04 00 00       	push   $0x407
  801d50:	ff 75 f0             	pushl  -0x10(%ebp)
  801d53:	6a 00                	push   $0x0
  801d55:	e8 fe f2 ff ff       	call   801058 <sys_page_alloc>
  801d5a:	89 c3                	mov    %eax,%ebx
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	0f 88 c3 00 00 00    	js     801e2a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d67:	83 ec 0c             	sub    $0xc,%esp
  801d6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6d:	e8 66 f5 ff ff       	call   8012d8 <fd2data>
  801d72:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d74:	83 c4 0c             	add    $0xc,%esp
  801d77:	68 07 04 00 00       	push   $0x407
  801d7c:	50                   	push   %eax
  801d7d:	6a 00                	push   $0x0
  801d7f:	e8 d4 f2 ff ff       	call   801058 <sys_page_alloc>
  801d84:	89 c3                	mov    %eax,%ebx
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	0f 88 89 00 00 00    	js     801e1a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d91:	83 ec 0c             	sub    $0xc,%esp
  801d94:	ff 75 f0             	pushl  -0x10(%ebp)
  801d97:	e8 3c f5 ff ff       	call   8012d8 <fd2data>
  801d9c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801da3:	50                   	push   %eax
  801da4:	6a 00                	push   $0x0
  801da6:	56                   	push   %esi
  801da7:	6a 00                	push   $0x0
  801da9:	e8 ed f2 ff ff       	call   80109b <sys_page_map>
  801dae:	89 c3                	mov    %eax,%ebx
  801db0:	83 c4 20             	add    $0x20,%esp
  801db3:	85 c0                	test   %eax,%eax
  801db5:	78 55                	js     801e0c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801db7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dcc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dd5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dda:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801de1:	83 ec 0c             	sub    $0xc,%esp
  801de4:	ff 75 f4             	pushl  -0xc(%ebp)
  801de7:	e8 dc f4 ff ff       	call   8012c8 <fd2num>
  801dec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801def:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801df1:	83 c4 04             	add    $0x4,%esp
  801df4:	ff 75 f0             	pushl  -0x10(%ebp)
  801df7:	e8 cc f4 ff ff       	call   8012c8 <fd2num>
  801dfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dff:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	ba 00 00 00 00       	mov    $0x0,%edx
  801e0a:	eb 30                	jmp    801e3c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e0c:	83 ec 08             	sub    $0x8,%esp
  801e0f:	56                   	push   %esi
  801e10:	6a 00                	push   $0x0
  801e12:	e8 c6 f2 ff ff       	call   8010dd <sys_page_unmap>
  801e17:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e1a:	83 ec 08             	sub    $0x8,%esp
  801e1d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e20:	6a 00                	push   $0x0
  801e22:	e8 b6 f2 ff ff       	call   8010dd <sys_page_unmap>
  801e27:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e2a:	83 ec 08             	sub    $0x8,%esp
  801e2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e30:	6a 00                	push   $0x0
  801e32:	e8 a6 f2 ff ff       	call   8010dd <sys_page_unmap>
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e3c:	89 d0                	mov    %edx,%eax
  801e3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e41:	5b                   	pop    %ebx
  801e42:	5e                   	pop    %esi
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    

00801e45 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4e:	50                   	push   %eax
  801e4f:	ff 75 08             	pushl  0x8(%ebp)
  801e52:	e8 e7 f4 ff ff       	call   80133e <fd_lookup>
  801e57:	83 c4 10             	add    $0x10,%esp
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	78 18                	js     801e76 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e5e:	83 ec 0c             	sub    $0xc,%esp
  801e61:	ff 75 f4             	pushl  -0xc(%ebp)
  801e64:	e8 6f f4 ff ff       	call   8012d8 <fd2data>
	return _pipeisclosed(fd, p);
  801e69:	89 c2                	mov    %eax,%edx
  801e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6e:	e8 21 fd ff ff       	call   801b94 <_pipeisclosed>
  801e73:	83 c4 10             	add    $0x10,%esp
}
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e80:	5d                   	pop    %ebp
  801e81:	c3                   	ret    

00801e82 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e88:	68 49 29 80 00       	push   $0x802949
  801e8d:	ff 75 0c             	pushl  0xc(%ebp)
  801e90:	e8 c0 ed ff ff       	call   800c55 <strcpy>
	return 0;
}
  801e95:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9a:	c9                   	leave  
  801e9b:	c3                   	ret    

00801e9c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	57                   	push   %edi
  801ea0:	56                   	push   %esi
  801ea1:	53                   	push   %ebx
  801ea2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ea8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ead:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb3:	eb 2d                	jmp    801ee2 <devcons_write+0x46>
		m = n - tot;
  801eb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eb8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801eba:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ebd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ec2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ec5:	83 ec 04             	sub    $0x4,%esp
  801ec8:	53                   	push   %ebx
  801ec9:	03 45 0c             	add    0xc(%ebp),%eax
  801ecc:	50                   	push   %eax
  801ecd:	57                   	push   %edi
  801ece:	e8 14 ef ff ff       	call   800de7 <memmove>
		sys_cputs(buf, m);
  801ed3:	83 c4 08             	add    $0x8,%esp
  801ed6:	53                   	push   %ebx
  801ed7:	57                   	push   %edi
  801ed8:	e8 bf f0 ff ff       	call   800f9c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801edd:	01 de                	add    %ebx,%esi
  801edf:	83 c4 10             	add    $0x10,%esp
  801ee2:	89 f0                	mov    %esi,%eax
  801ee4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ee7:	72 cc                	jb     801eb5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ee9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eec:	5b                   	pop    %ebx
  801eed:	5e                   	pop    %esi
  801eee:	5f                   	pop    %edi
  801eef:	5d                   	pop    %ebp
  801ef0:	c3                   	ret    

00801ef1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	83 ec 08             	sub    $0x8,%esp
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801efc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f00:	74 2a                	je     801f2c <devcons_read+0x3b>
  801f02:	eb 05                	jmp    801f09 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f04:	e8 30 f1 ff ff       	call   801039 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f09:	e8 ac f0 ff ff       	call   800fba <sys_cgetc>
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	74 f2                	je     801f04 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f12:	85 c0                	test   %eax,%eax
  801f14:	78 16                	js     801f2c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f16:	83 f8 04             	cmp    $0x4,%eax
  801f19:	74 0c                	je     801f27 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f1e:	88 02                	mov    %al,(%edx)
	return 1;
  801f20:	b8 01 00 00 00       	mov    $0x1,%eax
  801f25:	eb 05                	jmp    801f2c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f27:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    

00801f2e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f34:	8b 45 08             	mov    0x8(%ebp),%eax
  801f37:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f3a:	6a 01                	push   $0x1
  801f3c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f3f:	50                   	push   %eax
  801f40:	e8 57 f0 ff ff       	call   800f9c <sys_cputs>
}
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	c9                   	leave  
  801f49:	c3                   	ret    

00801f4a <getchar>:

int
getchar(void)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f50:	6a 01                	push   $0x1
  801f52:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f55:	50                   	push   %eax
  801f56:	6a 00                	push   $0x0
  801f58:	e8 47 f6 ff ff       	call   8015a4 <read>
	if (r < 0)
  801f5d:	83 c4 10             	add    $0x10,%esp
  801f60:	85 c0                	test   %eax,%eax
  801f62:	78 0f                	js     801f73 <getchar+0x29>
		return r;
	if (r < 1)
  801f64:	85 c0                	test   %eax,%eax
  801f66:	7e 06                	jle    801f6e <getchar+0x24>
		return -E_EOF;
	return c;
  801f68:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f6c:	eb 05                	jmp    801f73 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f6e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7e:	50                   	push   %eax
  801f7f:	ff 75 08             	pushl  0x8(%ebp)
  801f82:	e8 b7 f3 ff ff       	call   80133e <fd_lookup>
  801f87:	83 c4 10             	add    $0x10,%esp
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	78 11                	js     801f9f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f91:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f97:	39 10                	cmp    %edx,(%eax)
  801f99:	0f 94 c0             	sete   %al
  801f9c:	0f b6 c0             	movzbl %al,%eax
}
  801f9f:	c9                   	leave  
  801fa0:	c3                   	ret    

00801fa1 <opencons>:

int
opencons(void)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801faa:	50                   	push   %eax
  801fab:	e8 3f f3 ff ff       	call   8012ef <fd_alloc>
  801fb0:	83 c4 10             	add    $0x10,%esp
		return r;
  801fb3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	78 3e                	js     801ff7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fb9:	83 ec 04             	sub    $0x4,%esp
  801fbc:	68 07 04 00 00       	push   $0x407
  801fc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc4:	6a 00                	push   $0x0
  801fc6:	e8 8d f0 ff ff       	call   801058 <sys_page_alloc>
  801fcb:	83 c4 10             	add    $0x10,%esp
		return r;
  801fce:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	78 23                	js     801ff7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fd4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fe9:	83 ec 0c             	sub    $0xc,%esp
  801fec:	50                   	push   %eax
  801fed:	e8 d6 f2 ff ff       	call   8012c8 <fd2num>
  801ff2:	89 c2                	mov    %eax,%edx
  801ff4:	83 c4 10             	add    $0x10,%esp
}
  801ff7:	89 d0                	mov    %edx,%eax
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    

00801ffb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	56                   	push   %esi
  801fff:	53                   	push   %ebx
  802000:	8b 75 08             	mov    0x8(%ebp),%esi
  802003:	8b 45 0c             	mov    0xc(%ebp),%eax
  802006:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  802009:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  80200b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802010:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  802013:	83 ec 0c             	sub    $0xc,%esp
  802016:	50                   	push   %eax
  802017:	e8 ec f1 ff ff       	call   801208 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  80201c:	83 c4 10             	add    $0x10,%esp
  80201f:	85 c0                	test   %eax,%eax
  802021:	78 0e                	js     802031 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  802023:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  802029:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  80202c:	8b 52 78             	mov    0x78(%edx),%edx
  80202f:	eb 0a                	jmp    80203b <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  802031:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  802036:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  80203b:	85 f6                	test   %esi,%esi
  80203d:	74 02                	je     802041 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  80203f:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  802041:	85 db                	test   %ebx,%ebx
  802043:	74 02                	je     802047 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  802045:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  802047:	85 c0                	test   %eax,%eax
  802049:	78 08                	js     802053 <ipc_recv+0x58>
  80204b:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802050:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  802053:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802056:	5b                   	pop    %ebx
  802057:	5e                   	pop    %esi
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    

0080205a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	57                   	push   %edi
  80205e:	56                   	push   %esi
  80205f:	53                   	push   %ebx
  802060:	83 ec 0c             	sub    $0xc,%esp
  802063:	8b 7d 08             	mov    0x8(%ebp),%edi
  802066:	8b 75 0c             	mov    0xc(%ebp),%esi
  802069:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  80206c:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  80206e:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802073:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  802076:	ff 75 14             	pushl  0x14(%ebp)
  802079:	53                   	push   %ebx
  80207a:	56                   	push   %esi
  80207b:	57                   	push   %edi
  80207c:	e8 64 f1 ff ff       	call   8011e5 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  802081:	83 c4 10             	add    $0x10,%esp
  802084:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802087:	75 07                	jne    802090 <ipc_send+0x36>
				    sys_yield();
  802089:	e8 ab ef ff ff       	call   801039 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  80208e:	eb e6                	jmp    802076 <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  802090:	85 c0                	test   %eax,%eax
  802092:	74 12                	je     8020a6 <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  802094:	50                   	push   %eax
  802095:	68 55 29 80 00       	push   $0x802955
  80209a:	6a 4b                	push   $0x4b
  80209c:	68 69 29 80 00       	push   $0x802969
  8020a1:	e8 51 e5 ff ff       	call   8005f7 <_panic>
			 }
	   }
}
  8020a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a9:	5b                   	pop    %ebx
  8020aa:	5e                   	pop    %esi
  8020ab:	5f                   	pop    %edi
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    

008020ae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  8020b4:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  8020b9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020bc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020c2:	8b 52 50             	mov    0x50(%edx),%edx
  8020c5:	39 ca                	cmp    %ecx,%edx
  8020c7:	75 0d                	jne    8020d6 <ipc_find_env+0x28>
				    return envs[i].env_id;
  8020c9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020d1:	8b 40 48             	mov    0x48(%eax),%eax
  8020d4:	eb 0f                	jmp    8020e5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  8020d6:	83 c0 01             	add    $0x1,%eax
  8020d9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020de:	75 d9                	jne    8020b9 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  8020e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020e5:	5d                   	pop    %ebp
  8020e6:	c3                   	ret    

008020e7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ed:	89 d0                	mov    %edx,%eax
  8020ef:	c1 e8 16             	shr    $0x16,%eax
  8020f2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020f9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020fe:	f6 c1 01             	test   $0x1,%cl
  802101:	74 1d                	je     802120 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802103:	c1 ea 0c             	shr    $0xc,%edx
  802106:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80210d:	f6 c2 01             	test   $0x1,%dl
  802110:	74 0e                	je     802120 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802112:	c1 ea 0c             	shr    $0xc,%edx
  802115:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80211c:	ef 
  80211d:	0f b7 c0             	movzwl %ax,%eax
}
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	66 90                	xchg   %ax,%ax
  802124:	66 90                	xchg   %ax,%ax
  802126:	66 90                	xchg   %ax,%ax
  802128:	66 90                	xchg   %ax,%ax
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__udivdi3>:
  802130:	55                   	push   %ebp
  802131:	57                   	push   %edi
  802132:	56                   	push   %esi
  802133:	53                   	push   %ebx
  802134:	83 ec 1c             	sub    $0x1c,%esp
  802137:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80213b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80213f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802143:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802147:	85 f6                	test   %esi,%esi
  802149:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80214d:	89 ca                	mov    %ecx,%edx
  80214f:	89 f8                	mov    %edi,%eax
  802151:	75 3d                	jne    802190 <__udivdi3+0x60>
  802153:	39 cf                	cmp    %ecx,%edi
  802155:	0f 87 c5 00 00 00    	ja     802220 <__udivdi3+0xf0>
  80215b:	85 ff                	test   %edi,%edi
  80215d:	89 fd                	mov    %edi,%ebp
  80215f:	75 0b                	jne    80216c <__udivdi3+0x3c>
  802161:	b8 01 00 00 00       	mov    $0x1,%eax
  802166:	31 d2                	xor    %edx,%edx
  802168:	f7 f7                	div    %edi
  80216a:	89 c5                	mov    %eax,%ebp
  80216c:	89 c8                	mov    %ecx,%eax
  80216e:	31 d2                	xor    %edx,%edx
  802170:	f7 f5                	div    %ebp
  802172:	89 c1                	mov    %eax,%ecx
  802174:	89 d8                	mov    %ebx,%eax
  802176:	89 cf                	mov    %ecx,%edi
  802178:	f7 f5                	div    %ebp
  80217a:	89 c3                	mov    %eax,%ebx
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	89 fa                	mov    %edi,%edx
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	39 ce                	cmp    %ecx,%esi
  802192:	77 74                	ja     802208 <__udivdi3+0xd8>
  802194:	0f bd fe             	bsr    %esi,%edi
  802197:	83 f7 1f             	xor    $0x1f,%edi
  80219a:	0f 84 98 00 00 00    	je     802238 <__udivdi3+0x108>
  8021a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	89 c5                	mov    %eax,%ebp
  8021a9:	29 fb                	sub    %edi,%ebx
  8021ab:	d3 e6                	shl    %cl,%esi
  8021ad:	89 d9                	mov    %ebx,%ecx
  8021af:	d3 ed                	shr    %cl,%ebp
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	d3 e0                	shl    %cl,%eax
  8021b5:	09 ee                	or     %ebp,%esi
  8021b7:	89 d9                	mov    %ebx,%ecx
  8021b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021bd:	89 d5                	mov    %edx,%ebp
  8021bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021c3:	d3 ed                	shr    %cl,%ebp
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e2                	shl    %cl,%edx
  8021c9:	89 d9                	mov    %ebx,%ecx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	09 c2                	or     %eax,%edx
  8021cf:	89 d0                	mov    %edx,%eax
  8021d1:	89 ea                	mov    %ebp,%edx
  8021d3:	f7 f6                	div    %esi
  8021d5:	89 d5                	mov    %edx,%ebp
  8021d7:	89 c3                	mov    %eax,%ebx
  8021d9:	f7 64 24 0c          	mull   0xc(%esp)
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	72 10                	jb     8021f1 <__udivdi3+0xc1>
  8021e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	d3 e6                	shl    %cl,%esi
  8021e9:	39 c6                	cmp    %eax,%esi
  8021eb:	73 07                	jae    8021f4 <__udivdi3+0xc4>
  8021ed:	39 d5                	cmp    %edx,%ebp
  8021ef:	75 03                	jne    8021f4 <__udivdi3+0xc4>
  8021f1:	83 eb 01             	sub    $0x1,%ebx
  8021f4:	31 ff                	xor    %edi,%edi
  8021f6:	89 d8                	mov    %ebx,%eax
  8021f8:	89 fa                	mov    %edi,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	31 ff                	xor    %edi,%edi
  80220a:	31 db                	xor    %ebx,%ebx
  80220c:	89 d8                	mov    %ebx,%eax
  80220e:	89 fa                	mov    %edi,%edx
  802210:	83 c4 1c             	add    $0x1c,%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    
  802218:	90                   	nop
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 d8                	mov    %ebx,%eax
  802222:	f7 f7                	div    %edi
  802224:	31 ff                	xor    %edi,%edi
  802226:	89 c3                	mov    %eax,%ebx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 fa                	mov    %edi,%edx
  80222c:	83 c4 1c             	add    $0x1c,%esp
  80222f:	5b                   	pop    %ebx
  802230:	5e                   	pop    %esi
  802231:	5f                   	pop    %edi
  802232:	5d                   	pop    %ebp
  802233:	c3                   	ret    
  802234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802238:	39 ce                	cmp    %ecx,%esi
  80223a:	72 0c                	jb     802248 <__udivdi3+0x118>
  80223c:	31 db                	xor    %ebx,%ebx
  80223e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802242:	0f 87 34 ff ff ff    	ja     80217c <__udivdi3+0x4c>
  802248:	bb 01 00 00 00       	mov    $0x1,%ebx
  80224d:	e9 2a ff ff ff       	jmp    80217c <__udivdi3+0x4c>
  802252:	66 90                	xchg   %ax,%ax
  802254:	66 90                	xchg   %ax,%ax
  802256:	66 90                	xchg   %ax,%ax
  802258:	66 90                	xchg   %ax,%ax
  80225a:	66 90                	xchg   %ax,%ax
  80225c:	66 90                	xchg   %ax,%ax
  80225e:	66 90                	xchg   %ax,%ax

00802260 <__umoddi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	53                   	push   %ebx
  802264:	83 ec 1c             	sub    $0x1c,%esp
  802267:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80226b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80226f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802277:	85 d2                	test   %edx,%edx
  802279:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80227d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802281:	89 f3                	mov    %esi,%ebx
  802283:	89 3c 24             	mov    %edi,(%esp)
  802286:	89 74 24 04          	mov    %esi,0x4(%esp)
  80228a:	75 1c                	jne    8022a8 <__umoddi3+0x48>
  80228c:	39 f7                	cmp    %esi,%edi
  80228e:	76 50                	jbe    8022e0 <__umoddi3+0x80>
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	f7 f7                	div    %edi
  802296:	89 d0                	mov    %edx,%eax
  802298:	31 d2                	xor    %edx,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	39 f2                	cmp    %esi,%edx
  8022aa:	89 d0                	mov    %edx,%eax
  8022ac:	77 52                	ja     802300 <__umoddi3+0xa0>
  8022ae:	0f bd ea             	bsr    %edx,%ebp
  8022b1:	83 f5 1f             	xor    $0x1f,%ebp
  8022b4:	75 5a                	jne    802310 <__umoddi3+0xb0>
  8022b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ba:	0f 82 e0 00 00 00    	jb     8023a0 <__umoddi3+0x140>
  8022c0:	39 0c 24             	cmp    %ecx,(%esp)
  8022c3:	0f 86 d7 00 00 00    	jbe    8023a0 <__umoddi3+0x140>
  8022c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022d1:	83 c4 1c             	add    $0x1c,%esp
  8022d4:	5b                   	pop    %ebx
  8022d5:	5e                   	pop    %esi
  8022d6:	5f                   	pop    %edi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	85 ff                	test   %edi,%edi
  8022e2:	89 fd                	mov    %edi,%ebp
  8022e4:	75 0b                	jne    8022f1 <__umoddi3+0x91>
  8022e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	f7 f7                	div    %edi
  8022ef:	89 c5                	mov    %eax,%ebp
  8022f1:	89 f0                	mov    %esi,%eax
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	f7 f5                	div    %ebp
  8022f7:	89 c8                	mov    %ecx,%eax
  8022f9:	f7 f5                	div    %ebp
  8022fb:	89 d0                	mov    %edx,%eax
  8022fd:	eb 99                	jmp    802298 <__umoddi3+0x38>
  8022ff:	90                   	nop
  802300:	89 c8                	mov    %ecx,%eax
  802302:	89 f2                	mov    %esi,%edx
  802304:	83 c4 1c             	add    $0x1c,%esp
  802307:	5b                   	pop    %ebx
  802308:	5e                   	pop    %esi
  802309:	5f                   	pop    %edi
  80230a:	5d                   	pop    %ebp
  80230b:	c3                   	ret    
  80230c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802310:	8b 34 24             	mov    (%esp),%esi
  802313:	bf 20 00 00 00       	mov    $0x20,%edi
  802318:	89 e9                	mov    %ebp,%ecx
  80231a:	29 ef                	sub    %ebp,%edi
  80231c:	d3 e0                	shl    %cl,%eax
  80231e:	89 f9                	mov    %edi,%ecx
  802320:	89 f2                	mov    %esi,%edx
  802322:	d3 ea                	shr    %cl,%edx
  802324:	89 e9                	mov    %ebp,%ecx
  802326:	09 c2                	or     %eax,%edx
  802328:	89 d8                	mov    %ebx,%eax
  80232a:	89 14 24             	mov    %edx,(%esp)
  80232d:	89 f2                	mov    %esi,%edx
  80232f:	d3 e2                	shl    %cl,%edx
  802331:	89 f9                	mov    %edi,%ecx
  802333:	89 54 24 04          	mov    %edx,0x4(%esp)
  802337:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80233b:	d3 e8                	shr    %cl,%eax
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	89 c6                	mov    %eax,%esi
  802341:	d3 e3                	shl    %cl,%ebx
  802343:	89 f9                	mov    %edi,%ecx
  802345:	89 d0                	mov    %edx,%eax
  802347:	d3 e8                	shr    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	09 d8                	or     %ebx,%eax
  80234d:	89 d3                	mov    %edx,%ebx
  80234f:	89 f2                	mov    %esi,%edx
  802351:	f7 34 24             	divl   (%esp)
  802354:	89 d6                	mov    %edx,%esi
  802356:	d3 e3                	shl    %cl,%ebx
  802358:	f7 64 24 04          	mull   0x4(%esp)
  80235c:	39 d6                	cmp    %edx,%esi
  80235e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802362:	89 d1                	mov    %edx,%ecx
  802364:	89 c3                	mov    %eax,%ebx
  802366:	72 08                	jb     802370 <__umoddi3+0x110>
  802368:	75 11                	jne    80237b <__umoddi3+0x11b>
  80236a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80236e:	73 0b                	jae    80237b <__umoddi3+0x11b>
  802370:	2b 44 24 04          	sub    0x4(%esp),%eax
  802374:	1b 14 24             	sbb    (%esp),%edx
  802377:	89 d1                	mov    %edx,%ecx
  802379:	89 c3                	mov    %eax,%ebx
  80237b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80237f:	29 da                	sub    %ebx,%edx
  802381:	19 ce                	sbb    %ecx,%esi
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 f0                	mov    %esi,%eax
  802387:	d3 e0                	shl    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	d3 ea                	shr    %cl,%edx
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	d3 ee                	shr    %cl,%esi
  802391:	09 d0                	or     %edx,%eax
  802393:	89 f2                	mov    %esi,%edx
  802395:	83 c4 1c             	add    $0x1c,%esp
  802398:	5b                   	pop    %ebx
  802399:	5e                   	pop    %esi
  80239a:	5f                   	pop    %edi
  80239b:	5d                   	pop    %ebp
  80239c:	c3                   	ret    
  80239d:	8d 76 00             	lea    0x0(%esi),%esi
  8023a0:	29 f9                	sub    %edi,%ecx
  8023a2:	19 d6                	sbb    %edx,%esi
  8023a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ac:	e9 18 ff ff ff       	jmp    8022c9 <__umoddi3+0x69>
