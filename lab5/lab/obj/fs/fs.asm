
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 d2 1a 00 00       	call   801b03 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 20 39 80 00       	push   $0x803920
  8000b7:	e8 80 1b 00 00       	call   801c3c <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 37 39 80 00       	push   $0x803937
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 47 39 80 00       	push   $0x803947
  8000e0:	e8 7e 1a 00 00       	call   801b63 <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 50 39 80 00       	push   $0x803950
  80010b:	68 5d 39 80 00       	push   $0x80395d
  800110:	6a 44                	push   $0x44
  800112:	68 47 39 80 00       	push   $0x803947
  800117:	e8 47 1a 00 00       	call   801b63 <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 50 39 80 00       	push   $0x803950
  8001cf:	68 5d 39 80 00       	push   $0x80395d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 47 39 80 00       	push   $0x803947
  8001db:	e8 83 19 00 00       	call   801b63 <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
	   static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
	   void *addr = (void *) utf->utf_fault_va;
  800280:	8b 1a                	mov    (%edx),%ebx
	   uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800282:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800288:	89 c6                	mov    %eax,%esi
  80028a:	c1 ee 0c             	shr    $0xc,%esi
	   int r;

	   // Check that the fault was within the block cache region
	   if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80028d:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800292:	76 1b                	jbe    8002af <bc_pgfault+0x3b>
			 panic("page fault in FS: eip %08x, va %08x, err %04x",
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	ff 72 04             	pushl  0x4(%edx)
  80029a:	53                   	push   %ebx
  80029b:	ff 72 28             	pushl  0x28(%edx)
  80029e:	68 74 39 80 00       	push   $0x803974
  8002a3:	6a 27                	push   $0x27
  8002a5:	68 98 3a 80 00       	push   $0x803a98
  8002aa:	e8 b4 18 00 00       	call   801b63 <_panic>
						  utf->utf_eip, addr, utf->utf_err);

	   // Sanity check the block number.
	   if (super && blockno >= super->s_nblocks)
  8002af:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002b4:	85 c0                	test   %eax,%eax
  8002b6:	74 17                	je     8002cf <bc_pgfault+0x5b>
  8002b8:	3b 70 04             	cmp    0x4(%eax),%esi
  8002bb:	72 12                	jb     8002cf <bc_pgfault+0x5b>
			 panic("reading non-existent block %08x\n", blockno);
  8002bd:	56                   	push   %esi
  8002be:	68 a4 39 80 00       	push   $0x8039a4
  8002c3:	6a 2b                	push   $0x2b
  8002c5:	68 98 3a 80 00       	push   $0x803a98
  8002ca:	e8 94 18 00 00       	call   801b63 <_panic>
	   // the disk.
	   //
	   // LAB 5: you code here:
	   static_assert(PGSIZE == BLKSIZE);

	   if ((r = sys_page_alloc(thisenv -> env_id, ROUNDDOWN (addr, PGSIZE), PTE_W | PTE_P | PTE_U)) < 0)
  8002cf:	89 df                	mov    %ebx,%edi
  8002d1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  8002d7:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002dc:	8b 40 48             	mov    0x48(%eax),%eax
  8002df:	83 ec 04             	sub    $0x4,%esp
  8002e2:	6a 07                	push   $0x7
  8002e4:	57                   	push   %edi
  8002e5:	50                   	push   %eax
  8002e6:	e8 d9 22 00 00       	call   8025c4 <sys_page_alloc>
  8002eb:	83 c4 10             	add    $0x10,%esp
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	79 12                	jns    800304 <bc_pgfault+0x90>
	   {
			 panic ("sys_page_alloc failed in file system. %e", r);
  8002f2:	50                   	push   %eax
  8002f3:	68 c8 39 80 00       	push   $0x8039c8
  8002f8:	6a 37                	push   $0x37
  8002fa:	68 98 3a 80 00       	push   $0x803a98
  8002ff:	e8 5f 18 00 00       	call   801b63 <_panic>
	   }

	   if ((r = ide_read((BLKSIZE/SECTSIZE) * blockno, ROUNDDOWN (addr, PGSIZE), (BLKSIZE/SECTSIZE))) < 0)
  800304:	83 ec 04             	sub    $0x4,%esp
  800307:	6a 08                	push   $0x8
  800309:	57                   	push   %edi
  80030a:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800311:	50                   	push   %eax
  800312:	e8 d5 fd ff ff       	call   8000ec <ide_read>
  800317:	83 c4 10             	add    $0x10,%esp
  80031a:	85 c0                	test   %eax,%eax
  80031c:	79 12                	jns    800330 <bc_pgfault+0xbc>
	   {
			 panic ("IDE Read Failed. %e \n", r);
  80031e:	50                   	push   %eax
  80031f:	68 a0 3a 80 00       	push   $0x803aa0
  800324:	6a 3c                	push   $0x3c
  800326:	68 98 3a 80 00       	push   $0x803a98
  80032b:	e8 33 18 00 00       	call   801b63 <_panic>
	   }

	   // Clear the dirty bit for the disk block page since we just read the
	   // block from disk
	   if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800330:	89 d8                	mov    %ebx,%eax
  800332:	c1 e8 0c             	shr    $0xc,%eax
  800335:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	25 07 0e 00 00       	and    $0xe07,%eax
  800344:	50                   	push   %eax
  800345:	53                   	push   %ebx
  800346:	6a 00                	push   $0x0
  800348:	53                   	push   %ebx
  800349:	6a 00                	push   $0x0
  80034b:	e8 b7 22 00 00       	call   802607 <sys_page_map>
  800350:	83 c4 20             	add    $0x20,%esp
  800353:	85 c0                	test   %eax,%eax
  800355:	79 12                	jns    800369 <bc_pgfault+0xf5>
			 panic("in bc_pgfault, sys_page_map: %e", r);
  800357:	50                   	push   %eax
  800358:	68 f4 39 80 00       	push   $0x8039f4
  80035d:	6a 42                	push   $0x42
  80035f:	68 98 3a 80 00       	push   $0x803a98
  800364:	e8 fa 17 00 00       	call   801b63 <_panic>

	   // Check that the block we read was allocated. (exercise for
	   // the reader: why do we do this *after* reading the block
	   // in?)
	   if (bitmap && block_is_free(blockno))
  800369:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800370:	74 22                	je     800394 <bc_pgfault+0x120>
  800372:	83 ec 0c             	sub    $0xc,%esp
  800375:	56                   	push   %esi
  800376:	e8 97 04 00 00       	call   800812 <block_is_free>
  80037b:	83 c4 10             	add    $0x10,%esp
  80037e:	84 c0                	test   %al,%al
  800380:	74 12                	je     800394 <bc_pgfault+0x120>
			 panic("reading free block %08x\n", blockno);
  800382:	56                   	push   %esi
  800383:	68 b6 3a 80 00       	push   $0x803ab6
  800388:	6a 48                	push   $0x48
  80038a:	68 98 3a 80 00       	push   $0x803a98
  80038f:	e8 cf 17 00 00       	call   801b63 <_panic>
}
  800394:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800397:	5b                   	pop    %ebx
  800398:	5e                   	pop    %esi
  800399:	5f                   	pop    %edi
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    

0080039c <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
	   void*
diskaddr(uint32_t blockno)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
	   if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8003a5:	85 c0                	test   %eax,%eax
  8003a7:	74 0f                	je     8003b8 <diskaddr+0x1c>
  8003a9:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8003af:	85 d2                	test   %edx,%edx
  8003b1:	74 17                	je     8003ca <diskaddr+0x2e>
  8003b3:	3b 42 04             	cmp    0x4(%edx),%eax
  8003b6:	72 12                	jb     8003ca <diskaddr+0x2e>
			 panic("bad block number %08x in diskaddr", blockno);
  8003b8:	50                   	push   %eax
  8003b9:	68 14 3a 80 00       	push   $0x803a14
  8003be:	6a 09                	push   $0x9
  8003c0:	68 98 3a 80 00       	push   $0x803a98
  8003c5:	e8 99 17 00 00       	call   801b63 <_panic>
	   return (char*) (DISKMAP + blockno * BLKSIZE);
  8003ca:	05 00 00 01 00       	add    $0x10000,%eax
  8003cf:	c1 e0 0c             	shl    $0xc,%eax
}
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <va_is_mapped>:

// Is this virtual address mapped?
	   bool
va_is_mapped(void *va)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	8b 55 08             	mov    0x8(%ebp),%edx
	   return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003da:	89 d0                	mov    %edx,%eax
  8003dc:	c1 e8 16             	shr    $0x16,%eax
  8003df:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003eb:	f6 c1 01             	test   $0x1,%cl
  8003ee:	74 0d                	je     8003fd <va_is_mapped+0x29>
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003fa:	83 e0 01             	and    $0x1,%eax
  8003fd:	83 e0 01             	and    $0x1,%eax
}
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    

00800402 <va_is_dirty>:

// Is this virtual address dirty?
	   bool
va_is_dirty(void *va)
{
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
	   return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	c1 e8 0c             	shr    $0xc,%eax
  80040b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800412:	c1 e8 06             	shr    $0x6,%eax
  800415:	83 e0 01             	and    $0x1,%eax
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
	   void
flush_block(void *addr)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	56                   	push   %esi
  80041e:	53                   	push   %ebx
  80041f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	   if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800422:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800428:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80042d:	76 12                	jbe    800441 <flush_block+0x27>
			 panic("flush_block of bad va %08x", addr);
  80042f:	53                   	push   %ebx
  800430:	68 cf 3a 80 00       	push   $0x803acf
  800435:	6a 58                	push   $0x58
  800437:	68 98 3a 80 00       	push   $0x803a98
  80043c:	e8 22 17 00 00       	call   801b63 <_panic>

	   // LAB 5: Your code here.
	   static_assert(PGSIZE == BLKSIZE);
	   int a  = 0;

	   if (!va_is_mapped (addr) || !va_is_dirty (addr))
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	53                   	push   %ebx
  800445:	e8 8a ff ff ff       	call   8003d4 <va_is_mapped>
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	84 c0                	test   %al,%al
  80044f:	0f 84 80 00 00 00    	je     8004d5 <flush_block+0xbb>
  800455:	83 ec 0c             	sub    $0xc,%esp
  800458:	53                   	push   %ebx
  800459:	e8 a4 ff ff ff       	call   800402 <va_is_dirty>
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	84 c0                	test   %al,%al
  800463:	74 70                	je     8004d5 <flush_block+0xbb>
			 return;

	   if ((a = ide_write ((BLKSIZE/SECTSIZE)*blockno, ROUNDDOWN (addr, PGSIZE), (BLKSIZE/SECTSIZE))) < 0)
  800465:	89 de                	mov    %ebx,%esi
  800467:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  80046d:	83 ec 04             	sub    $0x4,%esp
  800470:	6a 08                	push   $0x8
  800472:	56                   	push   %esi
  800473:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800479:	c1 e8 0c             	shr    $0xc,%eax
  80047c:	c1 e0 03             	shl    $0x3,%eax
  80047f:	50                   	push   %eax
  800480:	e8 2b fd ff ff       	call   8001b0 <ide_write>
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	85 c0                	test   %eax,%eax
  80048a:	79 12                	jns    80049e <flush_block+0x84>
	   {
			 panic ("IDE_WRITE FAILED. %e \n", a);
  80048c:	50                   	push   %eax
  80048d:	68 ea 3a 80 00       	push   $0x803aea
  800492:	6a 63                	push   $0x63
  800494:	68 98 3a 80 00       	push   $0x803a98
  800499:	e8 c5 16 00 00       	call   801b63 <_panic>
	   }

	   if ((a = sys_page_map(0, ROUNDDOWN (addr, PGSIZE), 0, ROUNDDOWN (addr, PGSIZE), uvpt[PGNUM(addr)]&PTE_SYSCALL)) < 0)
  80049e:	c1 eb 0c             	shr    $0xc,%ebx
  8004a1:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8004a8:	83 ec 0c             	sub    $0xc,%esp
  8004ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8004b0:	50                   	push   %eax
  8004b1:	56                   	push   %esi
  8004b2:	6a 00                	push   $0x0
  8004b4:	56                   	push   %esi
  8004b5:	6a 00                	push   $0x0
  8004b7:	e8 4b 21 00 00       	call   802607 <sys_page_map>
  8004bc:	83 c4 20             	add    $0x20,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	79 12                	jns    8004d5 <flush_block+0xbb>
	   {
			 panic ("Failed to clear dirty bit in file system envirnment %e \n", a);
  8004c3:	50                   	push   %eax
  8004c4:	68 38 3a 80 00       	push   $0x803a38
  8004c9:	6a 68                	push   $0x68
  8004cb:	68 98 3a 80 00       	push   $0x803a98
  8004d0:	e8 8e 16 00 00       	call   801b63 <_panic>
	   }

	   //panic("flush_block not implemented");
}
  8004d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004d8:	5b                   	pop    %ebx
  8004d9:	5e                   	pop    %esi
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <bc_init>:
	   cprintf("block cache is good\n");
}

	   void
bc_init(void)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	53                   	push   %ebx
  8004e0:	81 ec 20 02 00 00    	sub    $0x220,%esp
	   struct Super super;
	   set_pgfault_handler(bc_pgfault);
  8004e6:	68 74 02 80 00       	push   $0x800274
  8004eb:	e8 c5 22 00 00       	call   8027b5 <set_pgfault_handler>
check_bc(void)
{
	   struct Super backup;

	   // back up super block
	   memmove(&backup, diskaddr(1), sizeof backup);
  8004f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004f7:	e8 a0 fe ff ff       	call   80039c <diskaddr>
  8004fc:	83 c4 0c             	add    $0xc,%esp
  8004ff:	68 08 01 00 00       	push   $0x108
  800504:	50                   	push   %eax
  800505:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80050b:	50                   	push   %eax
  80050c:	e8 42 1e 00 00       	call   802353 <memmove>

	   // smash it
	   strcpy(diskaddr(1), "OOPS!\n");
  800511:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800518:	e8 7f fe ff ff       	call   80039c <diskaddr>
  80051d:	83 c4 08             	add    $0x8,%esp
  800520:	68 01 3b 80 00       	push   $0x803b01
  800525:	50                   	push   %eax
  800526:	e8 96 1c 00 00       	call   8021c1 <strcpy>
	   flush_block(diskaddr(1));
  80052b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800532:	e8 65 fe ff ff       	call   80039c <diskaddr>
  800537:	89 04 24             	mov    %eax,(%esp)
  80053a:	e8 db fe ff ff       	call   80041a <flush_block>
	   assert(va_is_mapped(diskaddr(1)));
  80053f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800546:	e8 51 fe ff ff       	call   80039c <diskaddr>
  80054b:	89 04 24             	mov    %eax,(%esp)
  80054e:	e8 81 fe ff ff       	call   8003d4 <va_is_mapped>
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	84 c0                	test   %al,%al
  800558:	75 16                	jne    800570 <bc_init+0x94>
  80055a:	68 23 3b 80 00       	push   $0x803b23
  80055f:	68 5d 39 80 00       	push   $0x80395d
  800564:	6a 7b                	push   $0x7b
  800566:	68 98 3a 80 00       	push   $0x803a98
  80056b:	e8 f3 15 00 00       	call   801b63 <_panic>
	   assert(!va_is_dirty(diskaddr(1)));
  800570:	83 ec 0c             	sub    $0xc,%esp
  800573:	6a 01                	push   $0x1
  800575:	e8 22 fe ff ff       	call   80039c <diskaddr>
  80057a:	89 04 24             	mov    %eax,(%esp)
  80057d:	e8 80 fe ff ff       	call   800402 <va_is_dirty>
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	84 c0                	test   %al,%al
  800587:	74 16                	je     80059f <bc_init+0xc3>
  800589:	68 08 3b 80 00       	push   $0x803b08
  80058e:	68 5d 39 80 00       	push   $0x80395d
  800593:	6a 7c                	push   $0x7c
  800595:	68 98 3a 80 00       	push   $0x803a98
  80059a:	e8 c4 15 00 00       	call   801b63 <_panic>

	   // clear it out
	   sys_page_unmap(0, diskaddr(1));
  80059f:	83 ec 0c             	sub    $0xc,%esp
  8005a2:	6a 01                	push   $0x1
  8005a4:	e8 f3 fd ff ff       	call   80039c <diskaddr>
  8005a9:	83 c4 08             	add    $0x8,%esp
  8005ac:	50                   	push   %eax
  8005ad:	6a 00                	push   $0x0
  8005af:	e8 95 20 00 00       	call   802649 <sys_page_unmap>
	   assert(!va_is_mapped(diskaddr(1)));
  8005b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005bb:	e8 dc fd ff ff       	call   80039c <diskaddr>
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	e8 0c fe ff ff       	call   8003d4 <va_is_mapped>
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	84 c0                	test   %al,%al
  8005cd:	74 19                	je     8005e8 <bc_init+0x10c>
  8005cf:	68 22 3b 80 00       	push   $0x803b22
  8005d4:	68 5d 39 80 00       	push   $0x80395d
  8005d9:	68 80 00 00 00       	push   $0x80
  8005de:	68 98 3a 80 00       	push   $0x803a98
  8005e3:	e8 7b 15 00 00       	call   801b63 <_panic>

	   // read it back in
	   assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005e8:	83 ec 0c             	sub    $0xc,%esp
  8005eb:	6a 01                	push   $0x1
  8005ed:	e8 aa fd ff ff       	call   80039c <diskaddr>
  8005f2:	83 c4 08             	add    $0x8,%esp
  8005f5:	68 01 3b 80 00       	push   $0x803b01
  8005fa:	50                   	push   %eax
  8005fb:	e8 6b 1c 00 00       	call   80226b <strcmp>
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	85 c0                	test   %eax,%eax
  800605:	74 19                	je     800620 <bc_init+0x144>
  800607:	68 74 3a 80 00       	push   $0x803a74
  80060c:	68 5d 39 80 00       	push   $0x80395d
  800611:	68 83 00 00 00       	push   $0x83
  800616:	68 98 3a 80 00       	push   $0x803a98
  80061b:	e8 43 15 00 00       	call   801b63 <_panic>

	   // fix it
	   memmove(diskaddr(1), &backup, sizeof backup);
  800620:	83 ec 0c             	sub    $0xc,%esp
  800623:	6a 01                	push   $0x1
  800625:	e8 72 fd ff ff       	call   80039c <diskaddr>
  80062a:	83 c4 0c             	add    $0xc,%esp
  80062d:	68 08 01 00 00       	push   $0x108
  800632:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  800638:	53                   	push   %ebx
  800639:	50                   	push   %eax
  80063a:	e8 14 1d 00 00       	call   802353 <memmove>
	   flush_block(diskaddr(1));
  80063f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800646:	e8 51 fd ff ff       	call   80039c <diskaddr>
  80064b:	89 04 24             	mov    %eax,(%esp)
  80064e:	e8 c7 fd ff ff       	call   80041a <flush_block>

	   // Now repeat the same experiment, but pass an unaligned address to
	   // flush_block.

	   // back up super block
	   memmove(&backup, diskaddr(1), sizeof backup);
  800653:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80065a:	e8 3d fd ff ff       	call   80039c <diskaddr>
  80065f:	83 c4 0c             	add    $0xc,%esp
  800662:	68 08 01 00 00       	push   $0x108
  800667:	50                   	push   %eax
  800668:	53                   	push   %ebx
  800669:	e8 e5 1c 00 00       	call   802353 <memmove>

	   // smash it
	   strcpy(diskaddr(1), "OOPS!\n");
  80066e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800675:	e8 22 fd ff ff       	call   80039c <diskaddr>
  80067a:	83 c4 08             	add    $0x8,%esp
  80067d:	68 01 3b 80 00       	push   $0x803b01
  800682:	50                   	push   %eax
  800683:	e8 39 1b 00 00       	call   8021c1 <strcpy>

	   // Pass an unaligned address to flush_block.
	   flush_block(diskaddr(1) + 20);
  800688:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80068f:	e8 08 fd ff ff       	call   80039c <diskaddr>
  800694:	83 c0 14             	add    $0x14,%eax
  800697:	89 04 24             	mov    %eax,(%esp)
  80069a:	e8 7b fd ff ff       	call   80041a <flush_block>
	   assert(va_is_mapped(diskaddr(1)));
  80069f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006a6:	e8 f1 fc ff ff       	call   80039c <diskaddr>
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	e8 21 fd ff ff       	call   8003d4 <va_is_mapped>
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	84 c0                	test   %al,%al
  8006b8:	75 19                	jne    8006d3 <bc_init+0x1f7>
  8006ba:	68 23 3b 80 00       	push   $0x803b23
  8006bf:	68 5d 39 80 00       	push   $0x80395d
  8006c4:	68 94 00 00 00       	push   $0x94
  8006c9:	68 98 3a 80 00       	push   $0x803a98
  8006ce:	e8 90 14 00 00       	call   801b63 <_panic>
	   // Skip the !va_is_dirty() check because it makes the bug somewhat
	   // obscure and hence harder to debug.
	   //assert(!va_is_dirty(diskaddr(1)));

	   // clear it out
	   sys_page_unmap(0, diskaddr(1));
  8006d3:	83 ec 0c             	sub    $0xc,%esp
  8006d6:	6a 01                	push   $0x1
  8006d8:	e8 bf fc ff ff       	call   80039c <diskaddr>
  8006dd:	83 c4 08             	add    $0x8,%esp
  8006e0:	50                   	push   %eax
  8006e1:	6a 00                	push   $0x0
  8006e3:	e8 61 1f 00 00       	call   802649 <sys_page_unmap>
	   assert(!va_is_mapped(diskaddr(1)));
  8006e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006ef:	e8 a8 fc ff ff       	call   80039c <diskaddr>
  8006f4:	89 04 24             	mov    %eax,(%esp)
  8006f7:	e8 d8 fc ff ff       	call   8003d4 <va_is_mapped>
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	84 c0                	test   %al,%al
  800701:	74 19                	je     80071c <bc_init+0x240>
  800703:	68 22 3b 80 00       	push   $0x803b22
  800708:	68 5d 39 80 00       	push   $0x80395d
  80070d:	68 9c 00 00 00       	push   $0x9c
  800712:	68 98 3a 80 00       	push   $0x803a98
  800717:	e8 47 14 00 00       	call   801b63 <_panic>

	   // read it back in
	   assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  80071c:	83 ec 0c             	sub    $0xc,%esp
  80071f:	6a 01                	push   $0x1
  800721:	e8 76 fc ff ff       	call   80039c <diskaddr>
  800726:	83 c4 08             	add    $0x8,%esp
  800729:	68 01 3b 80 00       	push   $0x803b01
  80072e:	50                   	push   %eax
  80072f:	e8 37 1b 00 00       	call   80226b <strcmp>
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	85 c0                	test   %eax,%eax
  800739:	74 19                	je     800754 <bc_init+0x278>
  80073b:	68 74 3a 80 00       	push   $0x803a74
  800740:	68 5d 39 80 00       	push   $0x80395d
  800745:	68 9f 00 00 00       	push   $0x9f
  80074a:	68 98 3a 80 00       	push   $0x803a98
  80074f:	e8 0f 14 00 00       	call   801b63 <_panic>

	   // fix it
	   memmove(diskaddr(1), &backup, sizeof backup);
  800754:	83 ec 0c             	sub    $0xc,%esp
  800757:	6a 01                	push   $0x1
  800759:	e8 3e fc ff ff       	call   80039c <diskaddr>
  80075e:	83 c4 0c             	add    $0xc,%esp
  800761:	68 08 01 00 00       	push   $0x108
  800766:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  80076c:	52                   	push   %edx
  80076d:	50                   	push   %eax
  80076e:	e8 e0 1b 00 00       	call   802353 <memmove>
	   flush_block(diskaddr(1));
  800773:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80077a:	e8 1d fc ff ff       	call   80039c <diskaddr>
  80077f:	89 04 24             	mov    %eax,(%esp)
  800782:	e8 93 fc ff ff       	call   80041a <flush_block>

	   cprintf("block cache is good\n");
  800787:	c7 04 24 3d 3b 80 00 	movl   $0x803b3d,(%esp)
  80078e:	e8 a9 14 00 00       	call   801c3c <cprintf>
	   struct Super super;
	   set_pgfault_handler(bc_pgfault);
	   check_bc();

	   // cache the super block by reading it once
	   memmove(&super, diskaddr(1), sizeof super);
  800793:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80079a:	e8 fd fb ff ff       	call   80039c <diskaddr>
  80079f:	83 c4 0c             	add    $0xc,%esp
  8007a2:	68 08 01 00 00       	push   $0x108
  8007a7:	50                   	push   %eax
  8007a8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007ae:	50                   	push   %eax
  8007af:	e8 9f 1b 00 00       	call   802353 <memmove>
}
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
	   void
check_super(void)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	83 ec 08             	sub    $0x8,%esp
	   if (super->s_magic != FS_MAGIC)
  8007c2:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007c7:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8007cd:	74 14                	je     8007e3 <check_super+0x27>
			 panic("bad file system magic number");
  8007cf:	83 ec 04             	sub    $0x4,%esp
  8007d2:	68 52 3b 80 00       	push   $0x803b52
  8007d7:	6a 0f                	push   $0xf
  8007d9:	68 6f 3b 80 00       	push   $0x803b6f
  8007de:	e8 80 13 00 00       	call   801b63 <_panic>

	   if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007e3:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007ea:	76 14                	jbe    800800 <check_super+0x44>
			 panic("file system is too large");
  8007ec:	83 ec 04             	sub    $0x4,%esp
  8007ef:	68 77 3b 80 00       	push   $0x803b77
  8007f4:	6a 12                	push   $0x12
  8007f6:	68 6f 3b 80 00       	push   $0x803b6f
  8007fb:	e8 63 13 00 00       	call   801b63 <_panic>

	   cprintf("superblock is good\n");
  800800:	83 ec 0c             	sub    $0xc,%esp
  800803:	68 90 3b 80 00       	push   $0x803b90
  800808:	e8 2f 14 00 00       	call   801c3c <cprintf>
}
  80080d:	83 c4 10             	add    $0x10,%esp
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
	   bool
block_is_free(uint32_t blockno)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   if (super == 0 || blockno >= super->s_nblocks)
  800819:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80081f:	85 d2                	test   %edx,%edx
  800821:	74 24                	je     800847 <block_is_free+0x35>
			 return 0;
  800823:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
	   bool
block_is_free(uint32_t blockno)
{
	   if (super == 0 || blockno >= super->s_nblocks)
  800828:	39 4a 04             	cmp    %ecx,0x4(%edx)
  80082b:	76 1f                	jbe    80084c <block_is_free+0x3a>
			 return 0;
	   if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80082d:	89 cb                	mov    %ecx,%ebx
  80082f:	c1 eb 05             	shr    $0x5,%ebx
  800832:	b8 01 00 00 00       	mov    $0x1,%eax
  800837:	d3 e0                	shl    %cl,%eax
  800839:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80083f:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800842:	0f 95 c0             	setne  %al
  800845:	eb 05                	jmp    80084c <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
	   bool
block_is_free(uint32_t blockno)
{
	   if (super == 0 || blockno >= super->s_nblocks)
			 return 0;
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
	   if (bitmap[blockno / 32] & (1 << (blockno % 32)))
			 return 1;
	   return 0;
}
  80084c:	5b                   	pop    %ebx
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <free_block>:

// Mark a block free in the bitmap
	   void
free_block(uint32_t blockno)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 04             	sub    $0x4,%esp
  800856:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   // Blockno zero is the null pointer of block numbers.
	   if (blockno == 0)
  800859:	85 c9                	test   %ecx,%ecx
  80085b:	75 14                	jne    800871 <free_block+0x22>
			 panic("attempt to free zero block");
  80085d:	83 ec 04             	sub    $0x4,%esp
  800860:	68 a4 3b 80 00       	push   $0x803ba4
  800865:	6a 2d                	push   $0x2d
  800867:	68 6f 3b 80 00       	push   $0x803b6f
  80086c:	e8 f2 12 00 00       	call   801b63 <_panic>
	   bitmap[blockno/32] |= 1<<(blockno%32);
  800871:	89 cb                	mov    %ecx,%ebx
  800873:	c1 eb 05             	shr    $0x5,%ebx
  800876:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80087c:	b8 01 00 00 00       	mov    $0x1,%eax
  800881:	d3 e0                	shl    %cl,%eax
  800883:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800886:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
	   int
alloc_block(void)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	57                   	push   %edi
  80088f:	56                   	push   %esi
  800890:	53                   	push   %ebx
  800891:	83 ec 1c             	sub    $0x1c,%esp
	   // contains the in-use bits for BLKBITSIZE blocks.  There are
	   // super->s_nblocks blocks in the disk altogether.

	   // LAB 5: Your code here.

	   int bitmaplim = DIV_CEIL(super->s_nblocks, 32);
  800894:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800899:	8b 78 04             	mov    0x4(%eax),%edi
  80089c:	89 f8                	mov    %edi,%eax
  80089e:	c1 e8 05             	shr    $0x5,%eax
  8008a1:	f7 c7 1f 00 00 00    	test   $0x1f,%edi
  8008a7:	74 08                	je     8008b1 <alloc_block+0x26>
  8008a9:	89 f8                	mov    %edi,%eax
  8008ab:	c1 e8 05             	shr    $0x5,%eax
  8008ae:	83 c0 01             	add    $0x1,%eax

	   int i;
	   for (i = 0; i < bitmaplim; i++) {
			 if (bitmap[i] != 0) {
  8008b1:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
	   // LAB 5: Your code here.

	   int bitmaplim = DIV_CEIL(super->s_nblocks, 32);

	   int i;
	   for (i = 0; i < bitmaplim; i++) {
  8008b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008bc:	eb 09                	jmp    8008c7 <alloc_block+0x3c>
			 if (bitmap[i] != 0) {
  8008be:	83 3c 9a 00          	cmpl   $0x0,(%edx,%ebx,4)
  8008c2:	75 07                	jne    8008cb <alloc_block+0x40>
	   // LAB 5: Your code here.

	   int bitmaplim = DIV_CEIL(super->s_nblocks, 32);

	   int i;
	   for (i = 0; i < bitmaplim; i++) {
  8008c4:	83 c3 01             	add    $0x1,%ebx
  8008c7:	39 c3                	cmp    %eax,%ebx
  8008c9:	7c f3                	jl     8008be <alloc_block+0x33>
			 if (bitmap[i] != 0) {
				    break;
			 }
	   }
	   if (i == bitmaplim) {
  8008cb:	39 c3                	cmp    %eax,%ebx
  8008cd:	0f 84 8a 00 00 00    	je     80095d <alloc_block+0xd2>
	   }

	   // now find which bit is set
	   uint32_t j;
	   for (j = 0; j < 32; j++) {
			 if (bitmap[i] & (1 << j)) {
  8008d3:	8d 04 9a             	lea    (%edx,%ebx,4),%eax
  8008d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008d9:	8b 30                	mov    (%eax),%esi
  8008db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8008e5:	89 c2                	mov    %eax,%edx
  8008e7:	d3 e2                	shl    %cl,%edx
  8008e9:	85 f2                	test   %esi,%edx
  8008eb:	75 1e                	jne    80090b <alloc_block+0x80>
			 return -E_NO_DISK;
	   }

	   // now find which bit is set
	   uint32_t j;
	   for (j = 0; j < 32; j++) {
  8008ed:	83 c1 01             	add    $0x1,%ecx
  8008f0:	83 f9 20             	cmp    $0x20,%ecx
  8008f3:	75 f0                	jne    8008e5 <alloc_block+0x5a>
			 if (bitmap[i] & (1 << j)) {
				    break;
			 }
	   }
	   assert(j < 32); // at least one bit must be 1
  8008f5:	68 bf 3b 80 00       	push   $0x803bbf
  8008fa:	68 5d 39 80 00       	push   $0x80395d
  8008ff:	6a 55                	push   $0x55
  800901:	68 6f 3b 80 00       	push   $0x803b6f
  800906:	e8 58 12 00 00       	call   801b63 <_panic>

	   int blockno = 32 * i + j;
  80090b:	c1 e3 05             	shl    $0x5,%ebx
  80090e:	01 cb                	add    %ecx,%ebx
	   if (blockno >= super->s_nblocks) {
  800910:	39 df                	cmp    %ebx,%edi
  800912:	76 50                	jbe    800964 <alloc_block+0xd9>
			 return -E_NO_DISK;
	   }

	   // clear the chosen bit
	   bitmap[i] &= ~(1 << j);
  800914:	f7 d2                	not    %edx
  800916:	21 f2                	and    %esi,%edx
  800918:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80091b:	89 10                	mov    %edx,(%eax)

	   for (int k = 0, bmb = DIV_CEIL(super->s_nblocks, BLKBITSIZE); k < bmb; k++) 
  80091d:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800922:	8b 40 04             	mov    0x4(%eax),%eax
  800925:	89 c7                	mov    %eax,%edi
  800927:	c1 ef 0f             	shr    $0xf,%edi
  80092a:	a9 ff 7f 00 00       	test   $0x7fff,%eax
  80092f:	74 03                	je     800934 <alloc_block+0xa9>
  800931:	8d 7f 01             	lea    0x1(%edi),%edi
  800934:	be 00 00 00 00       	mov    $0x0,%esi
  800939:	eb 1a                	jmp    800955 <alloc_block+0xca>
	   {
			 uint32_t *bmaddr = &bitmap[k * (BLKSIZE / 32)];

			 flush_block (bmaddr);
  80093b:	83 ec 0c             	sub    $0xc,%esp
  80093e:	89 f0                	mov    %esi,%eax
  800940:	c1 e0 09             	shl    $0x9,%eax
  800943:	03 05 04 a0 80 00    	add    0x80a004,%eax
  800949:	50                   	push   %eax
  80094a:	e8 cb fa ff ff       	call   80041a <flush_block>
	   }

	   // clear the chosen bit
	   bitmap[i] &= ~(1 << j);

	   for (int k = 0, bmb = DIV_CEIL(super->s_nblocks, BLKBITSIZE); k < bmb; k++) 
  80094f:	83 c6 01             	add    $0x1,%esi
  800952:	83 c4 10             	add    $0x10,%esp
  800955:	39 fe                	cmp    %edi,%esi
  800957:	7c e2                	jl     80093b <alloc_block+0xb0>

			 flush_block (bmaddr);

	   }
	   //	panic("alloc_block not implemented");
	   return blockno;
  800959:	89 d8                	mov    %ebx,%eax
  80095b:	eb 0c                	jmp    800969 <alloc_block+0xde>
			 if (bitmap[i] != 0) {
				    break;
			 }
	   }
	   if (i == bitmaplim) {
			 return -E_NO_DISK;
  80095d:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800962:	eb 05                	jmp    800969 <alloc_block+0xde>
	   }
	   assert(j < 32); // at least one bit must be 1

	   int blockno = 32 * i + j;
	   if (blockno >= super->s_nblocks) {
			 return -E_NO_DISK;
  800964:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
			 flush_block (bmaddr);

	   }
	   //	panic("alloc_block not implemented");
	   return blockno;
}
  800969:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5f                   	pop    %edi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
	   static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	57                   	push   %edi
  800975:	56                   	push   %esi
  800976:	53                   	push   %ebx
  800977:	83 ec 0c             	sub    $0xc,%esp
  80097a:	89 ce                	mov    %ecx,%esi
  80097c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   // LAB 5: Your code here.

	   if (filebno >= NDIRECT+NINDIRECT)
  80097f:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  800985:	0f 87 91 00 00 00    	ja     800a1c <file_block_walk+0xab>
  80098b:	89 d3                	mov    %edx,%ebx
			 return -E_INVAL;

	   if (filebno < NDIRECT)
  80098d:	83 fa 09             	cmp    $0x9,%edx
  800990:	77 13                	ja     8009a5 <file_block_walk+0x34>
	   {
			 *ppdiskbno = f->f_direct + filebno;
  800992:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  800999:	89 06                	mov    %eax,(%esi)
			 return 0;
  80099b:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a0:	e9 8a 00 00 00       	jmp    800a2f <file_block_walk+0xbe>
	   }

	   if (f->f_indirect == 0 && !alloc)
  8009a5:	8b 90 b0 00 00 00    	mov    0xb0(%eax),%edx
  8009ab:	85 d2                	test   %edx,%edx
  8009ad:	75 04                	jne    8009b3 <file_block_walk+0x42>
  8009af:	84 c9                	test   %cl,%cl
  8009b1:	74 70                	je     800a23 <file_block_walk+0xb2>
  8009b3:	89 c7                	mov    %eax,%edi
	   {
			 return -E_NOT_FOUND;
	   } else if (f->f_indirect == 0 && alloc)
  8009b5:	85 d2                	test   %edx,%edx
  8009b7:	75 45                	jne    8009fe <file_block_walk+0x8d>
  8009b9:	84 c9                	test   %cl,%cl
  8009bb:	74 41                	je     8009fe <file_block_walk+0x8d>
	   {
			 int blocknum = alloc_block ();
  8009bd:	e8 c9 fe ff ff       	call   80088b <alloc_block>
			 if (blocknum < 0)
  8009c2:	85 c0                	test   %eax,%eax
  8009c4:	78 64                	js     800a2a <file_block_walk+0xb9>
				    return -E_NO_DISK;
			 f->f_indirect = blocknum;
  8009c6:	89 87 b0 00 00 00    	mov    %eax,0xb0(%edi)
			 memset (diskaddr(f->f_indirect), 0, BLKSIZE);
  8009cc:	83 ec 0c             	sub    $0xc,%esp
  8009cf:	50                   	push   %eax
  8009d0:	e8 c7 f9 ff ff       	call   80039c <diskaddr>
  8009d5:	83 c4 0c             	add    $0xc,%esp
  8009d8:	68 00 10 00 00       	push   $0x1000
  8009dd:	6a 00                	push   $0x0
  8009df:	50                   	push   %eax
  8009e0:	e8 21 19 00 00       	call   802306 <memset>
			 flush_block (diskaddr(f->f_indirect));
  8009e5:	83 c4 04             	add    $0x4,%esp
  8009e8:	ff b7 b0 00 00 00    	pushl  0xb0(%edi)
  8009ee:	e8 a9 f9 ff ff       	call   80039c <diskaddr>
  8009f3:	89 04 24             	mov    %eax,(%esp)
  8009f6:	e8 1f fa ff ff       	call   80041a <flush_block>
  8009fb:	83 c4 10             	add    $0x10,%esp
	   }

	   uint32_t *blk = (uint32_t *) diskaddr(f->f_indirect);
  8009fe:	83 ec 0c             	sub    $0xc,%esp
  800a01:	ff b7 b0 00 00 00    	pushl  0xb0(%edi)
  800a07:	e8 90 f9 ff ff       	call   80039c <diskaddr>
	   *ppdiskbno = &blk[filebno - NDIRECT];
  800a0c:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800a10:	89 06                	mov    %eax,(%esi)
	   return 0;
  800a12:	83 c4 10             	add    $0x10,%esp
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1a:	eb 13                	jmp    800a2f <file_block_walk+0xbe>
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
	   // LAB 5: Your code here.

	   if (filebno >= NDIRECT+NINDIRECT)
			 return -E_INVAL;
  800a1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a21:	eb 0c                	jmp    800a2f <file_block_walk+0xbe>
			 return 0;
	   }

	   if (f->f_indirect == 0 && !alloc)
	   {
			 return -E_NOT_FOUND;
  800a23:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800a28:	eb 05                	jmp    800a2f <file_block_walk+0xbe>
	   } else if (f->f_indirect == 0 && alloc)
	   {
			 int blocknum = alloc_block ();
			 if (blocknum < 0)
				    return -E_NO_DISK;
  800a2a:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
	   *ppdiskbno = &blk[filebno - NDIRECT];
	   return 0;

	   //	   panic("file_block_walk not implemented");

}
  800a2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
	   void
check_bitmap(void)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
	   uint32_t i;

	   // Make sure all bitmap blocks are marked in-use
	   for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a3c:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800a41:	8b 70 04             	mov    0x4(%eax),%esi
  800a44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a49:	eb 29                	jmp    800a74 <check_bitmap+0x3d>
			 assert(!block_is_free(2+i));
  800a4b:	8d 43 02             	lea    0x2(%ebx),%eax
  800a4e:	50                   	push   %eax
  800a4f:	e8 be fd ff ff       	call   800812 <block_is_free>
  800a54:	83 c4 04             	add    $0x4,%esp
  800a57:	84 c0                	test   %al,%al
  800a59:	74 16                	je     800a71 <check_bitmap+0x3a>
  800a5b:	68 c6 3b 80 00       	push   $0x803bc6
  800a60:	68 5d 39 80 00       	push   $0x80395d
  800a65:	6a 75                	push   $0x75
  800a67:	68 6f 3b 80 00       	push   $0x803b6f
  800a6c:	e8 f2 10 00 00       	call   801b63 <_panic>
check_bitmap(void)
{
	   uint32_t i;

	   // Make sure all bitmap blocks are marked in-use
	   for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a71:	83 c3 01             	add    $0x1,%ebx
  800a74:	89 d8                	mov    %ebx,%eax
  800a76:	c1 e0 0f             	shl    $0xf,%eax
  800a79:	39 f0                	cmp    %esi,%eax
  800a7b:	72 ce                	jb     800a4b <check_bitmap+0x14>
			 assert(!block_is_free(2+i));

	   // Make sure the reserved and root blocks are marked in-use.
	   assert(!block_is_free(0));
  800a7d:	83 ec 0c             	sub    $0xc,%esp
  800a80:	6a 00                	push   $0x0
  800a82:	e8 8b fd ff ff       	call   800812 <block_is_free>
  800a87:	83 c4 10             	add    $0x10,%esp
  800a8a:	84 c0                	test   %al,%al
  800a8c:	74 16                	je     800aa4 <check_bitmap+0x6d>
  800a8e:	68 da 3b 80 00       	push   $0x803bda
  800a93:	68 5d 39 80 00       	push   $0x80395d
  800a98:	6a 78                	push   $0x78
  800a9a:	68 6f 3b 80 00       	push   $0x803b6f
  800a9f:	e8 bf 10 00 00       	call   801b63 <_panic>
	   assert(!block_is_free(1));
  800aa4:	83 ec 0c             	sub    $0xc,%esp
  800aa7:	6a 01                	push   $0x1
  800aa9:	e8 64 fd ff ff       	call   800812 <block_is_free>
  800aae:	83 c4 10             	add    $0x10,%esp
  800ab1:	84 c0                	test   %al,%al
  800ab3:	74 16                	je     800acb <check_bitmap+0x94>
  800ab5:	68 ec 3b 80 00       	push   $0x803bec
  800aba:	68 5d 39 80 00       	push   $0x80395d
  800abf:	6a 79                	push   $0x79
  800ac1:	68 6f 3b 80 00       	push   $0x803b6f
  800ac6:	e8 98 10 00 00       	call   801b63 <_panic>

	   cprintf("bitmap is good\n");
  800acb:	83 ec 0c             	sub    $0xc,%esp
  800ace:	68 fe 3b 80 00       	push   $0x803bfe
  800ad3:	e8 64 11 00 00       	call   801c3c <cprintf>
}
  800ad8:	83 c4 10             	add    $0x10,%esp
  800adb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <fs_init>:


// Initialize the file system
	   void
fs_init(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	83 ec 08             	sub    $0x8,%esp
	   static_assert(sizeof(struct File) == 256);

	   // Find a JOS disk.  Use the second IDE disk (number 1) if available
	   if (ide_probe_disk1())
  800ae8:	e8 72 f5 ff ff       	call   80005f <ide_probe_disk1>
  800aed:	84 c0                	test   %al,%al
  800aef:	74 0f                	je     800b00 <fs_init+0x1e>
			 ide_set_disk(1);
  800af1:	83 ec 0c             	sub    $0xc,%esp
  800af4:	6a 01                	push   $0x1
  800af6:	e8 c8 f5 ff ff       	call   8000c3 <ide_set_disk>
  800afb:	83 c4 10             	add    $0x10,%esp
  800afe:	eb 0d                	jmp    800b0d <fs_init+0x2b>
	   else
			 ide_set_disk(0);
  800b00:	83 ec 0c             	sub    $0xc,%esp
  800b03:	6a 00                	push   $0x0
  800b05:	e8 b9 f5 ff ff       	call   8000c3 <ide_set_disk>
  800b0a:	83 c4 10             	add    $0x10,%esp
	   bc_init();
  800b0d:	e8 ca f9 ff ff       	call   8004dc <bc_init>

	   // Set "super" to point to the super block.
	   super = diskaddr(1);
  800b12:	83 ec 0c             	sub    $0xc,%esp
  800b15:	6a 01                	push   $0x1
  800b17:	e8 80 f8 ff ff       	call   80039c <diskaddr>
  800b1c:	a3 08 a0 80 00       	mov    %eax,0x80a008
	   check_super();
  800b21:	e8 96 fc ff ff       	call   8007bc <check_super>

	   // Set "bitmap" to the beginning of the first bitmap block.
	   bitmap = diskaddr(2);
  800b26:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b2d:	e8 6a f8 ff ff       	call   80039c <diskaddr>
  800b32:	a3 04 a0 80 00       	mov    %eax,0x80a004
	   check_bitmap();
  800b37:	e8 fb fe ff ff       	call   800a37 <check_bitmap>

}
  800b3c:	83 c4 10             	add    $0x10,%esp
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    

00800b41 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
	   int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	83 ec 18             	sub    $0x18,%esp
  800b47:	8b 55 0c             	mov    0xc(%ebp),%edx
	   // LAB 5: Your code here.

	   if (filebno >= NDIRECT + NINDIRECT)
  800b4a:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  800b50:	77 50                	ja     800ba2 <file_get_block+0x61>
			 return -E_INVAL;

	   uint32_t* ptr = NULL;
  800b52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	   int a;

	   if ((a = file_block_walk (f, filebno, &ptr, true)) < 0)
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	6a 01                	push   $0x1
  800b5e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800b61:	8b 45 08             	mov    0x8(%ebp),%eax
  800b64:	e8 08 fe ff ff       	call   800971 <file_block_walk>
  800b69:	83 c4 10             	add    $0x10,%esp
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	78 3e                	js     800bae <file_get_block+0x6d>
			 return a;

	   if (*ptr == 0)
  800b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b73:	83 38 00             	cmpl   $0x0,(%eax)
  800b76:	75 0e                	jne    800b86 <file_get_block+0x45>
	   {
			 int blocknum = alloc_block ();
  800b78:	e8 0e fd ff ff       	call   80088b <alloc_block>
			 if (blocknum < 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	78 28                	js     800ba9 <file_get_block+0x68>
				    return -E_NO_DISK;

			 *ptr = blocknum;
  800b81:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b84:	89 02                	mov    %eax,(%edx)
	   }

	   *blk = (char*) diskaddr (*ptr);
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b8c:	ff 30                	pushl  (%eax)
  800b8e:	e8 09 f8 ff ff       	call   80039c <diskaddr>
  800b93:	8b 55 10             	mov    0x10(%ebp),%edx
  800b96:	89 02                	mov    %eax,(%edx)
	   return 0;
  800b98:	83 c4 10             	add    $0x10,%esp
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba0:	eb 0c                	jmp    800bae <file_get_block+0x6d>
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
	   // LAB 5: Your code here.

	   if (filebno >= NDIRECT + NINDIRECT)
			 return -E_INVAL;
  800ba2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ba7:	eb 05                	jmp    800bae <file_get_block+0x6d>

	   if (*ptr == 0)
	   {
			 int blocknum = alloc_block ();
			 if (blocknum < 0)
				    return -E_NO_DISK;
  800ba9:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax

	   *blk = (char*) diskaddr (*ptr);
	   return 0;

	   //panic("file_get_block not implemented");
}
  800bae:	c9                   	leave  
  800baf:	c3                   	ret    

00800bb0 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
	   static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800bbc:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800bc2:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800bc8:	eb 03                	jmp    800bcd <walk_path+0x1d>
// Skip over slashes.
	   static const char*
skip_slash(const char *p)
{
	   while (*p == '/')
			 p++;
  800bca:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
	   static const char*
skip_slash(const char *p)
{
	   while (*p == '/')
  800bcd:	80 38 2f             	cmpb   $0x2f,(%eax)
  800bd0:	74 f8                	je     800bca <walk_path+0x1a>
	   int r;

	   // if (*path != '/')
	   //	return -E_BAD_PATH;
	   path = skip_slash(path);
	   f = &super->s_root;
  800bd2:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800bd8:	83 c1 08             	add    $0x8,%ecx
  800bdb:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	   dir = 0;
	   name[0] = 0;
  800be1:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	   if (pdir)
  800be8:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800bee:	85 c9                	test   %ecx,%ecx
  800bf0:	74 06                	je     800bf8 <walk_path+0x48>
			 *pdir = 0;
  800bf2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	   *pf = 0;
  800bf8:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800bfe:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	   // if (*path != '/')
	   //	return -E_BAD_PATH;
	   path = skip_slash(path);
	   f = &super->s_root;
	   dir = 0;
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
			 p = path;
			 while (*path != '/' && *path != '\0')
				    path++;
			 if (path - p >= MAXNAMELEN)
				    return -E_BAD_PATH;
			 memmove(name, p, path - p);
  800c09:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	   name[0] = 0;

	   if (pdir)
			 *pdir = 0;
	   *pf = 0;
	   while (*path != '\0') {
  800c0f:	e9 5f 01 00 00       	jmp    800d73 <walk_path+0x1c3>
			 dir = f;
			 p = path;
			 while (*path != '/' && *path != '\0')
				    path++;
  800c14:	83 c7 01             	add    $0x1,%edi
  800c17:	eb 02                	jmp    800c1b <walk_path+0x6b>
  800c19:	89 c7                	mov    %eax,%edi
			 *pdir = 0;
	   *pf = 0;
	   while (*path != '\0') {
			 dir = f;
			 p = path;
			 while (*path != '/' && *path != '\0')
  800c1b:	0f b6 17             	movzbl (%edi),%edx
  800c1e:	80 fa 2f             	cmp    $0x2f,%dl
  800c21:	74 04                	je     800c27 <walk_path+0x77>
  800c23:	84 d2                	test   %dl,%dl
  800c25:	75 ed                	jne    800c14 <walk_path+0x64>
				    path++;
			 if (path - p >= MAXNAMELEN)
  800c27:	89 fb                	mov    %edi,%ebx
  800c29:	29 c3                	sub    %eax,%ebx
  800c2b:	83 fb 7f             	cmp    $0x7f,%ebx
  800c2e:	0f 8f 69 01 00 00    	jg     800d9d <walk_path+0x1ed>
				    return -E_BAD_PATH;
			 memmove(name, p, path - p);
  800c34:	83 ec 04             	sub    $0x4,%esp
  800c37:	53                   	push   %ebx
  800c38:	50                   	push   %eax
  800c39:	56                   	push   %esi
  800c3a:	e8 14 17 00 00       	call   802353 <memmove>
			 name[path - p] = '\0';
  800c3f:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800c46:	00 
  800c47:	83 c4 10             	add    $0x10,%esp
  800c4a:	eb 03                	jmp    800c4f <walk_path+0x9f>
// Skip over slashes.
	   static const char*
skip_slash(const char *p)
{
	   while (*p == '/')
			 p++;
  800c4c:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
	   static const char*
skip_slash(const char *p)
{
	   while (*p == '/')
  800c4f:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800c52:	74 f8                	je     800c4c <walk_path+0x9c>
				    return -E_BAD_PATH;
			 memmove(name, p, path - p);
			 name[path - p] = '\0';
			 path = skip_slash(path);

			 if (dir->f_type != FTYPE_DIR)
  800c54:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800c5a:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800c61:	0f 85 3d 01 00 00    	jne    800da4 <walk_path+0x1f4>
	   struct File *f;

	   // Search dir for name.
	   // We maintain the invariant that the size of a directory-file
	   // is always a multiple of the file system's block size.
	   assert((dir->f_size % BLKSIZE) == 0);
  800c67:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800c6d:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800c72:	74 19                	je     800c8d <walk_path+0xdd>
  800c74:	68 0e 3c 80 00       	push   $0x803c0e
  800c79:	68 5d 39 80 00       	push   $0x80395d
  800c7e:	68 02 01 00 00       	push   $0x102
  800c83:	68 6f 3b 80 00       	push   $0x803b6f
  800c88:	e8 d6 0e 00 00       	call   801b63 <_panic>
	   nblock = dir->f_size / BLKSIZE;
  800c8d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800c93:	85 c0                	test   %eax,%eax
  800c95:	0f 48 c2             	cmovs  %edx,%eax
  800c98:	c1 f8 0c             	sar    $0xc,%eax
  800c9b:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	   for (i = 0; i < nblock; i++) {
  800ca1:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800ca8:	00 00 00 
  800cab:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800cb1:	eb 5e                	jmp    800d11 <walk_path+0x161>
			 if ((r = file_get_block(dir, i, &blk)) < 0)
  800cb3:	83 ec 04             	sub    $0x4,%esp
  800cb6:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800cbc:	50                   	push   %eax
  800cbd:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800cc3:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800cc9:	e8 73 fe ff ff       	call   800b41 <file_get_block>
  800cce:	83 c4 10             	add    $0x10,%esp
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	0f 88 ee 00 00 00    	js     800dc7 <walk_path+0x217>
				    return r;
			 f = (struct File*) blk;
  800cd9:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800cdf:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
			 for (j = 0; j < BLKFILES; j++)
				    if (strcmp(f[j].f_name, name) == 0) {
  800ce5:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800ceb:	83 ec 08             	sub    $0x8,%esp
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	e8 76 15 00 00       	call   80226b <strcmp>
  800cf5:	83 c4 10             	add    $0x10,%esp
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	0f 84 ab 00 00 00    	je     800dab <walk_path+0x1fb>
  800d00:	81 c3 00 01 00 00    	add    $0x100,%ebx
	   nblock = dir->f_size / BLKSIZE;
	   for (i = 0; i < nblock; i++) {
			 if ((r = file_get_block(dir, i, &blk)) < 0)
				    return r;
			 f = (struct File*) blk;
			 for (j = 0; j < BLKFILES; j++)
  800d06:	39 fb                	cmp    %edi,%ebx
  800d08:	75 db                	jne    800ce5 <walk_path+0x135>
	   // Search dir for name.
	   // We maintain the invariant that the size of a directory-file
	   // is always a multiple of the file system's block size.
	   assert((dir->f_size % BLKSIZE) == 0);
	   nblock = dir->f_size / BLKSIZE;
	   for (i = 0; i < nblock; i++) {
  800d0a:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800d11:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800d17:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800d1d:	75 94                	jne    800cb3 <walk_path+0x103>
  800d1f:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
								*pdir = dir;
						  if (lastelem)
								strcpy(lastelem, name);
						  *pf = 0;
				    }
				    return r;
  800d25:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

			 if (dir->f_type != FTYPE_DIR)
				    return -E_NOT_FOUND;

			 if ((r = dir_lookup(dir, name, &f)) < 0) {
				    if (r == -E_NOT_FOUND && *path == '\0') {
  800d2a:	80 3f 00             	cmpb   $0x0,(%edi)
  800d2d:	0f 85 a3 00 00 00    	jne    800dd6 <walk_path+0x226>
						  if (pdir)
  800d33:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	74 08                	je     800d45 <walk_path+0x195>
								*pdir = dir;
  800d3d:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d43:	89 08                	mov    %ecx,(%eax)
						  if (lastelem)
  800d45:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800d49:	74 15                	je     800d60 <walk_path+0x1b0>
								strcpy(lastelem, name);
  800d4b:	83 ec 08             	sub    $0x8,%esp
  800d4e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800d54:	50                   	push   %eax
  800d55:	ff 75 08             	pushl  0x8(%ebp)
  800d58:	e8 64 14 00 00       	call   8021c1 <strcpy>
  800d5d:	83 c4 10             	add    $0x10,%esp
						  *pf = 0;
  800d60:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d66:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
				    }
				    return r;
  800d6c:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d71:	eb 63                	jmp    800dd6 <walk_path+0x226>
	   name[0] = 0;

	   if (pdir)
			 *pdir = 0;
	   *pf = 0;
	   while (*path != '\0') {
  800d73:	80 38 00             	cmpb   $0x0,(%eax)
  800d76:	0f 85 9d fe ff ff    	jne    800c19 <walk_path+0x69>
				    }
				    return r;
			 }
	   }

	   if (pdir)
  800d7c:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d82:	85 c0                	test   %eax,%eax
  800d84:	74 02                	je     800d88 <walk_path+0x1d8>
			 *pdir = dir;
  800d86:	89 10                	mov    %edx,(%eax)
	   *pf = f;
  800d88:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d8e:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d94:	89 08                	mov    %ecx,(%eax)
	   return 0;
  800d96:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9b:	eb 39                	jmp    800dd6 <walk_path+0x226>
			 dir = f;
			 p = path;
			 while (*path != '/' && *path != '\0')
				    path++;
			 if (path - p >= MAXNAMELEN)
				    return -E_BAD_PATH;
  800d9d:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800da2:	eb 32                	jmp    800dd6 <walk_path+0x226>
			 memmove(name, p, path - p);
			 name[path - p] = '\0';
			 path = skip_slash(path);

			 if (dir->f_type != FTYPE_DIR)
				    return -E_NOT_FOUND;
  800da4:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800da9:	eb 2b                	jmp    800dd6 <walk_path+0x226>
  800dab:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800db1:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	   for (i = 0; i < nblock; i++) {
			 if ((r = file_get_block(dir, i, &blk)) < 0)
				    return r;
			 f = (struct File*) blk;
			 for (j = 0; j < BLKFILES; j++)
				    if (strcmp(f[j].f_name, name) == 0) {
  800db7:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800dbd:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800dc3:	89 f8                	mov    %edi,%eax
  800dc5:	eb ac                	jmp    800d73 <walk_path+0x1c3>
  800dc7:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

			 if (dir->f_type != FTYPE_DIR)
				    return -E_NOT_FOUND;

			 if ((r = dir_lookup(dir, name, &f)) < 0) {
				    if (r == -E_NOT_FOUND && *path == '\0') {
  800dcd:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800dd0:	0f 84 4f ff ff ff    	je     800d25 <walk_path+0x175>

	   if (pdir)
			 *pdir = dir;
	   *pf = f;
	   return 0;
}
  800dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
	   int
file_open(const char *path, struct File **pf)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	83 ec 14             	sub    $0x14,%esp
	   return walk_path(path, 0, pf, 0);
  800de4:	6a 00                	push   $0x0
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	e8 ba fd ff ff       	call   800bb0 <walk_path>
}
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    

00800df8 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
	   ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	83 ec 2c             	sub    $0x2c,%esp
  800e01:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e04:	8b 4d 14             	mov    0x14(%ebp),%ecx
	   int r, bn;
	   off_t pos;
	   char *blk;

	   if (offset >= f->f_size)
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0a:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
			 return 0;
  800e10:	b8 00 00 00 00       	mov    $0x0,%eax
{
	   int r, bn;
	   off_t pos;
	   char *blk;

	   if (offset >= f->f_size)
  800e15:	39 ca                	cmp    %ecx,%edx
  800e17:	7e 7c                	jle    800e95 <file_read+0x9d>
			 return 0;

	   count = MIN(count, f->f_size - offset);
  800e19:	29 ca                	sub    %ecx,%edx
  800e1b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e1e:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800e22:	89 55 d0             	mov    %edx,-0x30(%ebp)

	   for (pos = offset; pos < offset + count; ) {
  800e25:	89 ce                	mov    %ecx,%esi
  800e27:	01 d1                	add    %edx,%ecx
  800e29:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800e2c:	eb 5d                	jmp    800e8b <file_read+0x93>
			 if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e34:	50                   	push   %eax
  800e35:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800e3b:	85 f6                	test   %esi,%esi
  800e3d:	0f 49 c6             	cmovns %esi,%eax
  800e40:	c1 f8 0c             	sar    $0xc,%eax
  800e43:	50                   	push   %eax
  800e44:	ff 75 08             	pushl  0x8(%ebp)
  800e47:	e8 f5 fc ff ff       	call   800b41 <file_get_block>
  800e4c:	83 c4 10             	add    $0x10,%esp
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	78 42                	js     800e95 <file_read+0x9d>
				    return r;
			 bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800e53:	89 f2                	mov    %esi,%edx
  800e55:	c1 fa 1f             	sar    $0x1f,%edx
  800e58:	c1 ea 14             	shr    $0x14,%edx
  800e5b:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e5e:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e63:	29 d0                	sub    %edx,%eax
  800e65:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e68:	29 da                	sub    %ebx,%edx
  800e6a:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800e6f:	29 c3                	sub    %eax,%ebx
  800e71:	39 da                	cmp    %ebx,%edx
  800e73:	0f 46 da             	cmovbe %edx,%ebx
			 memmove(buf, blk + pos % BLKSIZE, bn);
  800e76:	83 ec 04             	sub    $0x4,%esp
  800e79:	53                   	push   %ebx
  800e7a:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e7d:	50                   	push   %eax
  800e7e:	57                   	push   %edi
  800e7f:	e8 cf 14 00 00       	call   802353 <memmove>
			 pos += bn;
  800e84:	01 de                	add    %ebx,%esi
			 buf += bn;
  800e86:	01 df                	add    %ebx,%edi
  800e88:	83 c4 10             	add    $0x10,%esp
	   if (offset >= f->f_size)
			 return 0;

	   count = MIN(count, f->f_size - offset);

	   for (pos = offset; pos < offset + count; ) {
  800e8b:	89 f3                	mov    %esi,%ebx
  800e8d:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e90:	77 9c                	ja     800e2e <file_read+0x36>
			 memmove(buf, blk + pos % BLKSIZE, bn);
			 pos += bn;
			 buf += bn;
	   }

	   return count;
  800e92:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800e95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
	   int
file_set_size(struct File *f, off_t newsize)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 2c             	sub    $0x2c,%esp
  800ea6:	8b 75 08             	mov    0x8(%ebp),%esi
	   if (f->f_size > newsize)
  800ea9:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800eaf:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800eb2:	0f 8e a7 00 00 00    	jle    800f5f <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	   int r;
	   uint32_t bno, old_nblocks, new_nblocks;

	   old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800eb8:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800ebe:	05 ff 0f 00 00       	add    $0xfff,%eax
  800ec3:	0f 49 f8             	cmovns %eax,%edi
  800ec6:	c1 ff 0c             	sar    $0xc,%edi
	   new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800ec9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecc:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800ed1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed4:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800eda:	0f 49 c2             	cmovns %edx,%eax
  800edd:	c1 f8 0c             	sar    $0xc,%eax
  800ee0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	   for (bno = new_nblocks; bno < old_nblocks; bno++)
  800ee3:	89 c3                	mov    %eax,%ebx
  800ee5:	eb 39                	jmp    800f20 <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	   int r;
	   uint32_t *ptr;

	   if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800ee7:	83 ec 0c             	sub    $0xc,%esp
  800eea:	6a 00                	push   $0x0
  800eec:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800eef:	89 da                	mov    %ebx,%edx
  800ef1:	89 f0                	mov    %esi,%eax
  800ef3:	e8 79 fa ff ff       	call   800971 <file_block_walk>
  800ef8:	83 c4 10             	add    $0x10,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	78 4d                	js     800f4c <file_set_size+0xaf>
			 return r;
	   if (*ptr) {
  800eff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f02:	8b 00                	mov    (%eax),%eax
  800f04:	85 c0                	test   %eax,%eax
  800f06:	74 15                	je     800f1d <file_set_size+0x80>
			 free_block(*ptr);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	50                   	push   %eax
  800f0c:	e8 3e f9 ff ff       	call   80084f <free_block>
			 *ptr = 0;
  800f11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800f1a:	83 c4 10             	add    $0x10,%esp
	   int r;
	   uint32_t bno, old_nblocks, new_nblocks;

	   old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	   new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	   for (bno = new_nblocks; bno < old_nblocks; bno++)
  800f1d:	83 c3 01             	add    $0x1,%ebx
  800f20:	39 df                	cmp    %ebx,%edi
  800f22:	77 c3                	ja     800ee7 <file_set_size+0x4a>
			 if ((r = file_free_block(f, bno)) < 0)
				    cprintf("warning: file_free_block: %e", r);

	   if (new_nblocks <= NDIRECT && f->f_indirect) {
  800f24:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800f28:	77 35                	ja     800f5f <file_set_size+0xc2>
  800f2a:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800f30:	85 c0                	test   %eax,%eax
  800f32:	74 2b                	je     800f5f <file_set_size+0xc2>
			 free_block(f->f_indirect);
  800f34:	83 ec 0c             	sub    $0xc,%esp
  800f37:	50                   	push   %eax
  800f38:	e8 12 f9 ff ff       	call   80084f <free_block>
			 f->f_indirect = 0;
  800f3d:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800f44:	00 00 00 
  800f47:	83 c4 10             	add    $0x10,%esp
  800f4a:	eb 13                	jmp    800f5f <file_set_size+0xc2>

	   old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	   new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	   for (bno = new_nblocks; bno < old_nblocks; bno++)
			 if ((r = file_free_block(f, bno)) < 0)
				    cprintf("warning: file_free_block: %e", r);
  800f4c:	83 ec 08             	sub    $0x8,%esp
  800f4f:	50                   	push   %eax
  800f50:	68 2b 3c 80 00       	push   $0x803c2b
  800f55:	e8 e2 0c 00 00       	call   801c3c <cprintf>
  800f5a:	83 c4 10             	add    $0x10,%esp
  800f5d:	eb be                	jmp    800f1d <file_set_size+0x80>
	   int
file_set_size(struct File *f, off_t newsize)
{
	   if (f->f_size > newsize)
			 file_truncate_blocks(f, newsize);
	   f->f_size = newsize;
  800f5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f62:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	   flush_block(f);
  800f68:	83 ec 0c             	sub    $0xc,%esp
  800f6b:	56                   	push   %esi
  800f6c:	e8 a9 f4 ff ff       	call   80041a <flush_block>
	   return 0;
}
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
  800f76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5f                   	pop    %edi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
	   int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
  800f84:	83 ec 2c             	sub    $0x2c,%esp
  800f87:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f8a:	8b 75 14             	mov    0x14(%ebp),%esi
	   int r, bn;
	   off_t pos;
	   char *blk;

	   // Extend file if necessary
	   if (offset + count > f->f_size)
  800f8d:	89 f0                	mov    %esi,%eax
  800f8f:	03 45 10             	add    0x10(%ebp),%eax
  800f92:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f98:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800f9e:	76 72                	jbe    801012 <file_write+0x94>
			 if ((r = file_set_size(f, offset + count)) < 0)
  800fa0:	83 ec 08             	sub    $0x8,%esp
  800fa3:	50                   	push   %eax
  800fa4:	51                   	push   %ecx
  800fa5:	e8 f3 fe ff ff       	call   800e9d <file_set_size>
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	85 c0                	test   %eax,%eax
  800faf:	79 61                	jns    801012 <file_write+0x94>
  800fb1:	eb 69                	jmp    80101c <file_write+0x9e>
				    return r;

	   for (pos = offset; pos < offset + count; ) {
			 if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800fb3:	83 ec 04             	sub    $0x4,%esp
  800fb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fb9:	50                   	push   %eax
  800fba:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800fc0:	85 f6                	test   %esi,%esi
  800fc2:	0f 49 c6             	cmovns %esi,%eax
  800fc5:	c1 f8 0c             	sar    $0xc,%eax
  800fc8:	50                   	push   %eax
  800fc9:	ff 75 08             	pushl  0x8(%ebp)
  800fcc:	e8 70 fb ff ff       	call   800b41 <file_get_block>
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 44                	js     80101c <file_write+0x9e>
				    return r;
			 bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800fd8:	89 f2                	mov    %esi,%edx
  800fda:	c1 fa 1f             	sar    $0x1f,%edx
  800fdd:	c1 ea 14             	shr    $0x14,%edx
  800fe0:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800fe3:	25 ff 0f 00 00       	and    $0xfff,%eax
  800fe8:	29 d0                	sub    %edx,%eax
  800fea:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800fed:	29 d9                	sub    %ebx,%ecx
  800fef:	89 cb                	mov    %ecx,%ebx
  800ff1:	ba 00 10 00 00       	mov    $0x1000,%edx
  800ff6:	29 c2                	sub    %eax,%edx
  800ff8:	39 d1                	cmp    %edx,%ecx
  800ffa:	0f 47 da             	cmova  %edx,%ebx
			 memmove(blk + pos % BLKSIZE, buf, bn);
  800ffd:	83 ec 04             	sub    $0x4,%esp
  801000:	53                   	push   %ebx
  801001:	57                   	push   %edi
  801002:	03 45 e4             	add    -0x1c(%ebp),%eax
  801005:	50                   	push   %eax
  801006:	e8 48 13 00 00       	call   802353 <memmove>
			 pos += bn;
  80100b:	01 de                	add    %ebx,%esi
			 buf += bn;
  80100d:	01 df                	add    %ebx,%edi
  80100f:	83 c4 10             	add    $0x10,%esp
	   // Extend file if necessary
	   if (offset + count > f->f_size)
			 if ((r = file_set_size(f, offset + count)) < 0)
				    return r;

	   for (pos = offset; pos < offset + count; ) {
  801012:	89 f3                	mov    %esi,%ebx
  801014:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  801017:	77 9a                	ja     800fb3 <file_write+0x35>
			 memmove(blk + pos % BLKSIZE, buf, bn);
			 pos += bn;
			 buf += bn;
	   }

	   return count;
  801019:	8b 45 10             	mov    0x10(%ebp),%eax
}
  80101c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101f:	5b                   	pop    %ebx
  801020:	5e                   	pop    %esi
  801021:	5f                   	pop    %edi
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
	   void
file_flush(struct File *f)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	56                   	push   %esi
  801028:	53                   	push   %ebx
  801029:	83 ec 10             	sub    $0x10,%esp
  80102c:	8b 75 08             	mov    0x8(%ebp),%esi
	   int i;
	   uint32_t *pdiskbno;

	   for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  80102f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801034:	eb 3c                	jmp    801072 <file_flush+0x4e>
			 if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801036:	83 ec 0c             	sub    $0xc,%esp
  801039:	6a 00                	push   $0x0
  80103b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  80103e:	89 da                	mov    %ebx,%edx
  801040:	89 f0                	mov    %esi,%eax
  801042:	e8 2a f9 ff ff       	call   800971 <file_block_walk>
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	78 21                	js     80106f <file_flush+0x4b>
						  pdiskbno == NULL || *pdiskbno == 0)
  80104e:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	   int i;
	   uint32_t *pdiskbno;

	   for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
			 if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801051:	85 c0                	test   %eax,%eax
  801053:	74 1a                	je     80106f <file_flush+0x4b>
						  pdiskbno == NULL || *pdiskbno == 0)
  801055:	8b 00                	mov    (%eax),%eax
  801057:	85 c0                	test   %eax,%eax
  801059:	74 14                	je     80106f <file_flush+0x4b>
				    continue;
			 flush_block(diskaddr(*pdiskbno));
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	50                   	push   %eax
  80105f:	e8 38 f3 ff ff       	call   80039c <diskaddr>
  801064:	89 04 24             	mov    %eax,(%esp)
  801067:	e8 ae f3 ff ff       	call   80041a <flush_block>
  80106c:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	   int i;
	   uint32_t *pdiskbno;

	   for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  80106f:	83 c3 01             	add    $0x1,%ebx
  801072:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  801078:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  80107e:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  801084:	85 c9                	test   %ecx,%ecx
  801086:	0f 49 c1             	cmovns %ecx,%eax
  801089:	c1 f8 0c             	sar    $0xc,%eax
  80108c:	39 c3                	cmp    %eax,%ebx
  80108e:	7c a6                	jl     801036 <file_flush+0x12>
			 if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
						  pdiskbno == NULL || *pdiskbno == 0)
				    continue;
			 flush_block(diskaddr(*pdiskbno));
	   }
	   flush_block(f);
  801090:	83 ec 0c             	sub    $0xc,%esp
  801093:	56                   	push   %esi
  801094:	e8 81 f3 ff ff       	call   80041a <flush_block>
	   if (f->f_indirect)
  801099:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	74 14                	je     8010ba <file_flush+0x96>
			 flush_block(diskaddr(f->f_indirect));
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	50                   	push   %eax
  8010aa:	e8 ed f2 ff ff       	call   80039c <diskaddr>
  8010af:	89 04 24             	mov    %eax,(%esp)
  8010b2:	e8 63 f3 ff ff       	call   80041a <flush_block>
  8010b7:	83 c4 10             	add    $0x10,%esp
}
  8010ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010bd:	5b                   	pop    %ebx
  8010be:	5e                   	pop    %esi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
	   int
file_create(const char *path, struct File **pf)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	57                   	push   %edi
  8010c5:	56                   	push   %esi
  8010c6:	53                   	push   %ebx
  8010c7:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	   char name[MAXNAMELEN];
	   int r;
	   struct File *dir, *f;

	   if ((r = walk_path(path, &dir, &f, name)) == 0)
  8010cd:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8010d3:	50                   	push   %eax
  8010d4:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  8010da:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e3:	e8 c8 fa ff ff       	call   800bb0 <walk_path>
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	0f 84 d1 00 00 00    	je     8011c4 <file_create+0x103>
			 return -E_FILE_EXISTS;
	   if (r != -E_NOT_FOUND || dir == 0)
  8010f3:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8010f6:	0f 85 0c 01 00 00    	jne    801208 <file_create+0x147>
  8010fc:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  801102:	85 f6                	test   %esi,%esi
  801104:	0f 84 c1 00 00 00    	je     8011cb <file_create+0x10a>
	   int r;
	   uint32_t nblock, i, j;
	   char *blk;
	   struct File *f;

	   assert((dir->f_size % BLKSIZE) == 0);
  80110a:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  801110:	a9 ff 0f 00 00       	test   $0xfff,%eax
  801115:	74 19                	je     801130 <file_create+0x6f>
  801117:	68 0e 3c 80 00       	push   $0x803c0e
  80111c:	68 5d 39 80 00       	push   $0x80395d
  801121:	68 1b 01 00 00       	push   $0x11b
  801126:	68 6f 3b 80 00       	push   $0x803b6f
  80112b:	e8 33 0a 00 00       	call   801b63 <_panic>
	   nblock = dir->f_size / BLKSIZE;
  801130:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801136:	85 c0                	test   %eax,%eax
  801138:	0f 48 c2             	cmovs  %edx,%eax
  80113b:	c1 f8 0c             	sar    $0xc,%eax
  80113e:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	   for (i = 0; i < nblock; i++) {
  801144:	bb 00 00 00 00       	mov    $0x0,%ebx
			 if ((r = file_get_block(dir, i, &blk)) < 0)
  801149:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  80114f:	eb 3b                	jmp    80118c <file_create+0xcb>
  801151:	83 ec 04             	sub    $0x4,%esp
  801154:	57                   	push   %edi
  801155:	53                   	push   %ebx
  801156:	56                   	push   %esi
  801157:	e8 e5 f9 ff ff       	call   800b41 <file_get_block>
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	0f 88 a1 00 00 00    	js     801208 <file_create+0x147>
				    return r;
			 f = (struct File*) blk;
  801167:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  80116d:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
			 for (j = 0; j < BLKFILES; j++)
				    if (f[j].f_name[0] == '\0') {
  801173:	80 38 00             	cmpb   $0x0,(%eax)
  801176:	75 08                	jne    801180 <file_create+0xbf>
						  *file = &f[j];
  801178:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  80117e:	eb 52                	jmp    8011d2 <file_create+0x111>
  801180:	05 00 01 00 00       	add    $0x100,%eax
	   nblock = dir->f_size / BLKSIZE;
	   for (i = 0; i < nblock; i++) {
			 if ((r = file_get_block(dir, i, &blk)) < 0)
				    return r;
			 f = (struct File*) blk;
			 for (j = 0; j < BLKFILES; j++)
  801185:	39 d0                	cmp    %edx,%eax
  801187:	75 ea                	jne    801173 <file_create+0xb2>
	   char *blk;
	   struct File *f;

	   assert((dir->f_size % BLKSIZE) == 0);
	   nblock = dir->f_size / BLKSIZE;
	   for (i = 0; i < nblock; i++) {
  801189:	83 c3 01             	add    $0x1,%ebx
  80118c:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  801192:	75 bd                	jne    801151 <file_create+0x90>
				    if (f[j].f_name[0] == '\0') {
						  *file = &f[j];
						  return 0;
				    }
	   }
	   dir->f_size += BLKSIZE;
  801194:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  80119b:	10 00 00 
	   if ((r = file_get_block(dir, i, &blk)) < 0)
  80119e:	83 ec 04             	sub    $0x4,%esp
  8011a1:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8011a7:	50                   	push   %eax
  8011a8:	53                   	push   %ebx
  8011a9:	56                   	push   %esi
  8011aa:	e8 92 f9 ff ff       	call   800b41 <file_get_block>
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	78 52                	js     801208 <file_create+0x147>
			 return r;
	   f = (struct File*) blk;
	   *file = &f[0];
  8011b6:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8011bc:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8011c2:	eb 0e                	jmp    8011d2 <file_create+0x111>
	   char name[MAXNAMELEN];
	   int r;
	   struct File *dir, *f;

	   if ((r = walk_path(path, &dir, &f, name)) == 0)
			 return -E_FILE_EXISTS;
  8011c4:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  8011c9:	eb 3d                	jmp    801208 <file_create+0x147>
	   if (r != -E_NOT_FOUND || dir == 0)
			 return r;
  8011cb:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8011d0:	eb 36                	jmp    801208 <file_create+0x147>
	   if ((r = dir_alloc_file(dir, &f)) < 0)
			 return r;

	   strcpy(f->f_name, name);
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8011db:	50                   	push   %eax
  8011dc:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  8011e2:	e8 da 0f 00 00       	call   8021c1 <strcpy>
	   *pf = f;
  8011e7:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  8011ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f0:	89 10                	mov    %edx,(%eax)
	   file_flush(dir);
  8011f2:	83 c4 04             	add    $0x4,%esp
  8011f5:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  8011fb:	e8 24 fe ff ff       	call   801024 <file_flush>
	   return 0;
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5f                   	pop    %edi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <fs_sync>:


// Sync the entire file system.  A big hammer.
	   void
fs_sync(void)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	53                   	push   %ebx
  801214:	83 ec 04             	sub    $0x4,%esp
	   int i;
	   for (i = 1; i < super->s_nblocks; i++)
  801217:	bb 01 00 00 00       	mov    $0x1,%ebx
  80121c:	eb 17                	jmp    801235 <fs_sync+0x25>
			 flush_block(diskaddr(i));
  80121e:	83 ec 0c             	sub    $0xc,%esp
  801221:	53                   	push   %ebx
  801222:	e8 75 f1 ff ff       	call   80039c <diskaddr>
  801227:	89 04 24             	mov    %eax,(%esp)
  80122a:	e8 eb f1 ff ff       	call   80041a <flush_block>
// Sync the entire file system.  A big hammer.
	   void
fs_sync(void)
{
	   int i;
	   for (i = 1; i < super->s_nblocks; i++)
  80122f:	83 c3 01             	add    $0x1,%ebx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80123a:	39 58 04             	cmp    %ebx,0x4(%eax)
  80123d:	77 df                	ja     80121e <fs_sync+0xe>
			 flush_block(diskaddr(i));
}
  80123f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <serve_sync>:
}


	   int
serve_sync(envid_t envid, union Fsipc *req)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	83 ec 08             	sub    $0x8,%esp
	   fs_sync();
  80124a:	e8 c1 ff ff ff       	call   801210 <fs_sync>
	   return 0;
}
  80124f:	b8 00 00 00 00       	mov    $0x0,%eax
  801254:	c9                   	leave  
  801255:	c3                   	ret    

00801256 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

	   void
serve_init(void)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	ba 60 50 80 00       	mov    $0x805060,%edx
	   int i;
	   uintptr_t va = FILEVA;
  80125e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	   for (i = 0; i < MAXOPEN; i++) {
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
			 opentab[i].o_fileid = i;
  801268:	89 02                	mov    %eax,(%edx)
			 opentab[i].o_fd = (struct Fd*) va;
  80126a:	89 4a 0c             	mov    %ecx,0xc(%edx)
			 va += PGSIZE;
  80126d:	81 c1 00 10 00 00    	add    $0x1000,%ecx
	   void
serve_init(void)
{
	   int i;
	   uintptr_t va = FILEVA;
	   for (i = 0; i < MAXOPEN; i++) {
  801273:	83 c0 01             	add    $0x1,%eax
  801276:	83 c2 10             	add    $0x10,%edx
  801279:	3d 00 04 00 00       	cmp    $0x400,%eax
  80127e:	75 e8                	jne    801268 <serve_init+0x12>
			 opentab[i].o_fileid = i;
			 opentab[i].o_fd = (struct Fd*) va;
			 va += PGSIZE;
	   }
}
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <openfile_alloc>:

// Allocate an open file.
	   int
openfile_alloc(struct OpenFile **o)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	56                   	push   %esi
  801286:	53                   	push   %ebx
  801287:	8b 75 08             	mov    0x8(%ebp),%esi
	   int i, r;

	   // Find an available open-file table entry
	   for (i = 0; i < MAXOPEN; i++) {
  80128a:	bb 00 00 00 00       	mov    $0x0,%ebx
			 switch (pageref(opentab[i].o_fd)) {
  80128f:	83 ec 0c             	sub    $0xc,%esp
  801292:	89 d8                	mov    %ebx,%eax
  801294:	c1 e0 04             	shl    $0x4,%eax
  801297:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  80129d:	e8 d2 1e 00 00       	call   803174 <pageref>
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	74 07                	je     8012b0 <openfile_alloc+0x2e>
  8012a9:	83 f8 01             	cmp    $0x1,%eax
  8012ac:	74 20                	je     8012ce <openfile_alloc+0x4c>
  8012ae:	eb 51                	jmp    801301 <openfile_alloc+0x7f>
				    case 0:
						  if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8012b0:	83 ec 04             	sub    $0x4,%esp
  8012b3:	6a 07                	push   $0x7
  8012b5:	89 d8                	mov    %ebx,%eax
  8012b7:	c1 e0 04             	shl    $0x4,%eax
  8012ba:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8012c0:	6a 00                	push   $0x0
  8012c2:	e8 fd 12 00 00       	call   8025c4 <sys_page_alloc>
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	78 43                	js     801311 <openfile_alloc+0x8f>
								return r;
						  /* fall through */
				    case 1:
						  opentab[i].o_fileid += MAXOPEN;
  8012ce:	c1 e3 04             	shl    $0x4,%ebx
  8012d1:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  8012d7:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8012de:	04 00 00 
						  *o = &opentab[i];
  8012e1:	89 06                	mov    %eax,(%esi)
						  memset(opentab[i].o_fd, 0, PGSIZE);
  8012e3:	83 ec 04             	sub    $0x4,%esp
  8012e6:	68 00 10 00 00       	push   $0x1000
  8012eb:	6a 00                	push   $0x0
  8012ed:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  8012f3:	e8 0e 10 00 00       	call   802306 <memset>
						  return (*o)->o_fileid;
  8012f8:	8b 06                	mov    (%esi),%eax
  8012fa:	8b 00                	mov    (%eax),%eax
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	eb 10                	jmp    801311 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	   int i, r;

	   // Find an available open-file table entry
	   for (i = 0; i < MAXOPEN; i++) {
  801301:	83 c3 01             	add    $0x1,%ebx
  801304:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80130a:	75 83                	jne    80128f <openfile_alloc+0xd>
						  *o = &opentab[i];
						  memset(opentab[i].o_fd, 0, PGSIZE);
						  return (*o)->o_fileid;
			 }
	   }
	   return -E_MAX_OPEN;
  80130c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801311:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801314:	5b                   	pop    %ebx
  801315:	5e                   	pop    %esi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <openfile_lookup>:

// Look up an open file for envid.
	   int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	57                   	push   %edi
  80131c:	56                   	push   %esi
  80131d:	53                   	push   %ebx
  80131e:	83 ec 18             	sub    $0x18,%esp
  801321:	8b 7d 0c             	mov    0xc(%ebp),%edi
	   struct OpenFile *o;

	   o = &opentab[fileid % MAXOPEN];
  801324:	89 fb                	mov    %edi,%ebx
  801326:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80132c:	89 de                	mov    %ebx,%esi
  80132e:	c1 e6 04             	shl    $0x4,%esi
	   if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801331:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
	   int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	   struct OpenFile *o;

	   o = &opentab[fileid % MAXOPEN];
  801337:	81 c6 60 50 80 00    	add    $0x805060,%esi
	   if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80133d:	e8 32 1e 00 00       	call   803174 <pageref>
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	83 f8 01             	cmp    $0x1,%eax
  801348:	7e 17                	jle    801361 <openfile_lookup+0x49>
  80134a:	c1 e3 04             	shl    $0x4,%ebx
  80134d:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  801353:	75 13                	jne    801368 <openfile_lookup+0x50>
			 return -E_INVAL;
	   *po = o;
  801355:	8b 45 10             	mov    0x10(%ebp),%eax
  801358:	89 30                	mov    %esi,(%eax)
	   return 0;
  80135a:	b8 00 00 00 00       	mov    $0x0,%eax
  80135f:	eb 0c                	jmp    80136d <openfile_lookup+0x55>
{
	   struct OpenFile *o;

	   o = &opentab[fileid % MAXOPEN];
	   if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
			 return -E_INVAL;
  801361:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801366:	eb 05                	jmp    80136d <openfile_lookup+0x55>
  801368:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	   *po = o;
	   return 0;
}
  80136d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5f                   	pop    %edi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
	   int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	53                   	push   %ebx
  801379:	83 ec 18             	sub    $0x18,%esp
  80137c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   // Every file system IPC call has the same general structure.
	   // Here's how it goes.

	   // First, use openfile_lookup to find the relevant open file.
	   // On failure, return the error code to the client with ipc_send.
	   if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80137f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	ff 33                	pushl  (%ebx)
  801385:	ff 75 08             	pushl  0x8(%ebp)
  801388:	e8 8b ff ff ff       	call   801318 <openfile_lookup>
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	85 c0                	test   %eax,%eax
  801392:	78 14                	js     8013a8 <serve_set_size+0x33>
			 return r;

	   // Second, call the relevant file system function (from fs/fs.c).
	   // On failure, return the error code to the client.
	   return file_set_size(o->o_file, req->req_size);
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	ff 73 04             	pushl  0x4(%ebx)
  80139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139d:	ff 70 04             	pushl  0x4(%eax)
  8013a0:	e8 f8 fa ff ff       	call   800e9d <file_set_size>
  8013a5:	83 c4 10             	add    $0x10,%esp
}
  8013a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ab:	c9                   	leave  
  8013ac:	c3                   	ret    

008013ad <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
	   int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 18             	sub    $0x18,%esp
  8013b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	   // Lab 5: Your code here:
	   struct OpenFile *o;
	   int a;

	   if ((a = openfile_lookup (envid, req -> req_fileid, &o)) < 0)
  8013b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ba:	50                   	push   %eax
  8013bb:	ff 33                	pushl  (%ebx)
  8013bd:	ff 75 08             	pushl  0x8(%ebp)
  8013c0:	e8 53 ff ff ff       	call   801318 <openfile_lookup>
  8013c5:	83 c4 10             	add    $0x10,%esp
			 return a;
  8013c8:	89 c2                	mov    %eax,%edx

	   // Lab 5: Your code here:
	   struct OpenFile *o;
	   int a;

	   if ((a = openfile_lookup (envid, req -> req_fileid, &o)) < 0)
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 2b                	js     8013f9 <serve_read+0x4c>
			 return a;

	   int bytes_read = 0;
	   if (( bytes_read = file_read (o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  8013ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d1:	8b 50 0c             	mov    0xc(%eax),%edx
  8013d4:	ff 72 04             	pushl  0x4(%edx)
  8013d7:	ff 73 04             	pushl  0x4(%ebx)
  8013da:	53                   	push   %ebx
  8013db:	ff 70 04             	pushl  0x4(%eax)
  8013de:	e8 15 fa ff ff       	call   800df8 <file_read>
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 0d                	js     8013f7 <serve_read+0x4a>
			 return bytes_read;

	   o->o_fd->fd_offset += bytes_read;
  8013ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ed:	8b 52 0c             	mov    0xc(%edx),%edx
  8013f0:	01 42 04             	add    %eax,0x4(%edx)
	   return bytes_read;
  8013f3:	89 c2                	mov    %eax,%edx
  8013f5:	eb 02                	jmp    8013f9 <serve_read+0x4c>
	   if ((a = openfile_lookup (envid, req -> req_fileid, &o)) < 0)
			 return a;

	   int bytes_read = 0;
	   if (( bytes_read = file_read (o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) < 0)
			 return bytes_read;
  8013f7:	89 c2                	mov    %eax,%edx

	   o->o_fd->fd_offset += bytes_read;
	   return bytes_read;
}
  8013f9:	89 d0                	mov    %edx,%eax
  8013fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    

00801400 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
	   int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	53                   	push   %ebx
  801404:	83 ec 18             	sub    $0x18,%esp
  801407:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	   // LAB 5: Your code here.

	   struct OpenFile* o;
	   int a ; 
	   if ((a = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80140a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140d:	50                   	push   %eax
  80140e:	ff 33                	pushl  (%ebx)
  801410:	ff 75 08             	pushl  0x8(%ebp)
  801413:	e8 00 ff ff ff       	call   801318 <openfile_lookup>
  801418:	83 c4 10             	add    $0x10,%esp
			 return a;
  80141b:	89 c2                	mov    %eax,%edx

	   // LAB 5: Your code here.

	   struct OpenFile* o;
	   int a ; 
	   if ((a = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 2e                	js     80144f <serve_write+0x4f>
			 return a;

	   int bytes_written = 0;
	   if ((bytes_written = file_write (o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  801421:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801424:	8b 50 0c             	mov    0xc(%eax),%edx
  801427:	ff 72 04             	pushl  0x4(%edx)
  80142a:	ff 73 04             	pushl  0x4(%ebx)
  80142d:	83 c3 08             	add    $0x8,%ebx
  801430:	53                   	push   %ebx
  801431:	ff 70 04             	pushl  0x4(%eax)
  801434:	e8 45 fb ff ff       	call   800f7e <file_write>
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 0d                	js     80144d <serve_write+0x4d>
			 return bytes_written;

	   o->o_fd->fd_offset += bytes_written;
  801440:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801443:	8b 52 0c             	mov    0xc(%edx),%edx
  801446:	01 42 04             	add    %eax,0x4(%edx)

	   return bytes_written;
  801449:	89 c2                	mov    %eax,%edx
  80144b:	eb 02                	jmp    80144f <serve_write+0x4f>
	   if ((a = openfile_lookup(envid, req->req_fileid, &o)) < 0)
			 return a;

	   int bytes_written = 0;
	   if ((bytes_written = file_write (o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
			 return bytes_written;
  80144d:	89 c2                	mov    %eax,%edx

	   o->o_fd->fd_offset += bytes_written;

	   return bytes_written;
	   //	   panic("serve_write not implemented");
}
  80144f:	89 d0                	mov    %edx,%eax
  801451:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
	   int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	53                   	push   %ebx
  80145a:	83 ec 18             	sub    $0x18,%esp
  80145d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   if (debug)
			 cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	   if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801460:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	ff 33                	pushl  (%ebx)
  801466:	ff 75 08             	pushl  0x8(%ebp)
  801469:	e8 aa fe ff ff       	call   801318 <openfile_lookup>
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	78 3f                	js     8014b4 <serve_stat+0x5e>
			 return r;

	   strcpy(ret->ret_name, o->o_file->f_name);
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147b:	ff 70 04             	pushl  0x4(%eax)
  80147e:	53                   	push   %ebx
  80147f:	e8 3d 0d 00 00       	call   8021c1 <strcpy>
	   ret->ret_size = o->o_file->f_size;
  801484:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801487:	8b 50 04             	mov    0x4(%eax),%edx
  80148a:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801490:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	   ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  801496:	8b 40 04             	mov    0x4(%eax),%eax
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8014a3:	0f 94 c0             	sete   %al
  8014a6:	0f b6 c0             	movzbl %al,%eax
  8014a9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  8014af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    

008014b9 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
	   int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	83 ec 1c             	sub    $0x1c,%esp
	   int r;

	   if (debug)
			 cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	   if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c6:	ff 30                	pushl  (%eax)
  8014c8:	ff 75 08             	pushl  0x8(%ebp)
  8014cb:	e8 48 fe ff ff       	call   801318 <openfile_lookup>
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	78 16                	js     8014ed <serve_flush+0x34>
			 return r;
	   file_flush(o->o_file);
  8014d7:	83 ec 0c             	sub    $0xc,%esp
  8014da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014dd:	ff 70 04             	pushl  0x4(%eax)
  8014e0:	e8 3f fb ff ff       	call   801024 <file_flush>
	   return 0;
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ed:	c9                   	leave  
  8014ee:	c3                   	ret    

008014ef <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
	   int
serve_open(envid_t envid, struct Fsreq_open *req,
			 void **pg_store, int *perm_store)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	53                   	push   %ebx
  8014f3:	81 ec 18 04 00 00    	sub    $0x418,%esp
  8014f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	   if (debug)
			 cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	   // Copy in the path, making sure it's null-terminated
	   memmove(path, req->req_path, MAXPATHLEN);
  8014fc:	68 00 04 00 00       	push   $0x400
  801501:	53                   	push   %ebx
  801502:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	e8 45 0e 00 00       	call   802353 <memmove>
	   path[MAXPATHLEN-1] = 0;
  80150e:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	   // Find an open file ID
	   if ((r = openfile_alloc(&o)) < 0) {
  801512:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801518:	89 04 24             	mov    %eax,(%esp)
  80151b:	e8 62 fd ff ff       	call   801282 <openfile_alloc>
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	85 c0                	test   %eax,%eax
  801525:	0f 88 f0 00 00 00    	js     80161b <serve_open+0x12c>
			 return r;
	   }
	   fileid = r;

	   // Open the file
	   if (req->req_omode & O_CREAT) {
  80152b:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801532:	74 33                	je     801567 <serve_open+0x78>
			 if ((r = file_create(path, &f)) < 0) {
  801534:	83 ec 08             	sub    $0x8,%esp
  801537:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80153d:	50                   	push   %eax
  80153e:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801544:	50                   	push   %eax
  801545:	e8 77 fb ff ff       	call   8010c1 <file_create>
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	85 c0                	test   %eax,%eax
  80154f:	79 37                	jns    801588 <serve_open+0x99>
				    if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801551:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801558:	0f 85 bd 00 00 00    	jne    80161b <serve_open+0x12c>
  80155e:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801561:	0f 85 b4 00 00 00    	jne    80161b <serve_open+0x12c>
						  cprintf("file_create failed: %e", r);
				    return r;
			 }
	   } else {
try_open:
			 if ((r = file_open(path, &f)) < 0) {
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	e8 61 f8 ff ff       	call   800dde <file_open>
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	85 c0                	test   %eax,%eax
  801582:	0f 88 93 00 00 00    	js     80161b <serve_open+0x12c>
				    return r;
			 }
	   }

	   // Truncate
	   if (req->req_omode & O_TRUNC) {
  801588:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  80158f:	74 17                	je     8015a8 <serve_open+0xb9>
			 if ((r = file_set_size(f, 0)) < 0) {
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	6a 00                	push   $0x0
  801596:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  80159c:	e8 fc f8 ff ff       	call   800e9d <file_set_size>
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 73                	js     80161b <serve_open+0x12c>
				    if (debug)
						  cprintf("file_set_size failed: %e", r);
				    return r;
			 }
	   }
	   if ((r = file_open(path, &f)) < 0) {
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8015b8:	50                   	push   %eax
  8015b9:	e8 20 f8 ff ff       	call   800dde <file_open>
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 56                	js     80161b <serve_open+0x12c>
				    cprintf("file_open failed: %e", r);
			 return r;
	   }

	   // Save the file pointer
	   o->o_file = f;
  8015c5:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015cb:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8015d1:	89 50 04             	mov    %edx,0x4(%eax)

	   // Fill out the Fd structure
	   o->o_fd->fd_file.id = o->o_fileid;
  8015d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8015d7:	8b 08                	mov    (%eax),%ecx
  8015d9:	89 4a 0c             	mov    %ecx,0xc(%edx)
	   o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8015dc:	8b 48 0c             	mov    0xc(%eax),%ecx
  8015df:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8015e5:	83 e2 03             	and    $0x3,%edx
  8015e8:	89 51 08             	mov    %edx,0x8(%ecx)
	   o->o_fd->fd_dev_id = devfile.dev_id;
  8015eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ee:	8b 15 64 90 80 00    	mov    0x809064,%edx
  8015f4:	89 10                	mov    %edx,(%eax)
	   o->o_mode = req->req_omode;
  8015f6:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015fc:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801602:	89 50 08             	mov    %edx,0x8(%eax)
	   if (debug)
			 cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	   // Share the FD page with the caller by setting *pg_store,
	   // store its permission in *perm_store
	   *pg_store = o->o_fd;
  801605:	8b 50 0c             	mov    0xc(%eax),%edx
  801608:	8b 45 10             	mov    0x10(%ebp),%eax
  80160b:	89 10                	mov    %edx,(%eax)
	   *perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  80160d:	8b 45 14             	mov    0x14(%ebp),%eax
  801610:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	   return 0;
  801616:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80161b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    

00801620 <serve>:
	   [FSREQ_SYNC] =		serve_sync
};

	   void
serve(void)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	56                   	push   %esi
  801624:	53                   	push   %ebx
  801625:	83 ec 10             	sub    $0x10,%esp
	   int perm, r;
	   void *pg;

	   while (1) {
			 perm = 0;
			 req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801628:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  80162b:	8d 75 f4             	lea    -0xc(%ebp),%esi
	   uint32_t req, whom;
	   int perm, r;
	   void *pg;

	   while (1) {
			 perm = 0;
  80162e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			 req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801635:	83 ec 04             	sub    $0x4,%esp
  801638:	53                   	push   %ebx
  801639:	ff 35 44 50 80 00    	pushl  0x805044
  80163f:	56                   	push   %esi
  801640:	e8 ef 11 00 00       	call   802834 <ipc_recv>
			 if (debug)
				    cprintf("fs req %d from %08x [page %08x: %s]\n",
								req, whom, uvpt[PGNUM(fsreq)], fsreq);

			 // All requests must contain an argument page
			 if (!(perm & PTE_P)) {
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  80164c:	75 15                	jne    801663 <serve+0x43>
				    cprintf("Invalid request from %08x: no argument page\n",
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	ff 75 f4             	pushl  -0xc(%ebp)
  801654:	68 48 3c 80 00       	push   $0x803c48
  801659:	e8 de 05 00 00       	call   801c3c <cprintf>
								whom);
				    continue; // just leave it hanging...
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	eb cb                	jmp    80162e <serve+0xe>
			 }

			 pg = NULL;
  801663:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
			 if (req == FSREQ_OPEN) {
  80166a:	83 f8 01             	cmp    $0x1,%eax
  80166d:	75 18                	jne    801687 <serve+0x67>
				    r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  80166f:	53                   	push   %ebx
  801670:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801673:	50                   	push   %eax
  801674:	ff 35 44 50 80 00    	pushl  0x805044
  80167a:	ff 75 f4             	pushl  -0xc(%ebp)
  80167d:	e8 6d fe ff ff       	call   8014ef <serve_open>
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	eb 3c                	jmp    8016c3 <serve+0xa3>
			 } else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  801687:	83 f8 08             	cmp    $0x8,%eax
  80168a:	77 1e                	ja     8016aa <serve+0x8a>
  80168c:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  801693:	85 d2                	test   %edx,%edx
  801695:	74 13                	je     8016aa <serve+0x8a>
				    r = handlers[req](whom, fsreq);
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	ff 35 44 50 80 00    	pushl  0x805044
  8016a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a3:	ff d2                	call   *%edx
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	eb 19                	jmp    8016c3 <serve+0xa3>
			 } else {
				    cprintf("Invalid request code %d from %08x\n", req, whom);
  8016aa:	83 ec 04             	sub    $0x4,%esp
  8016ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b0:	50                   	push   %eax
  8016b1:	68 78 3c 80 00       	push   $0x803c78
  8016b6:	e8 81 05 00 00       	call   801c3c <cprintf>
  8016bb:	83 c4 10             	add    $0x10,%esp
				    r = -E_INVAL;
  8016be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			 }
			 ipc_send(whom, r, pg, perm);
  8016c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8016c6:	ff 75 ec             	pushl  -0x14(%ebp)
  8016c9:	50                   	push   %eax
  8016ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8016cd:	e8 c1 11 00 00       	call   802893 <ipc_send>
			 sys_page_unmap(0, fsreq);
  8016d2:	83 c4 08             	add    $0x8,%esp
  8016d5:	ff 35 44 50 80 00    	pushl  0x805044
  8016db:	6a 00                	push   $0x0
  8016dd:	e8 67 0f 00 00       	call   802649 <sys_page_unmap>
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	e9 44 ff ff ff       	jmp    80162e <serve+0xe>

008016ea <umain>:
	   }
}

	   void
umain(int argc, char **argv)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	83 ec 14             	sub    $0x14,%esp
	   static_assert(sizeof(struct File) == 256);
	   binaryname = "fs";
  8016f0:	c7 05 60 90 80 00 9b 	movl   $0x803c9b,0x809060
  8016f7:	3c 80 00 
	   cprintf("FS is running\n");
  8016fa:	68 9e 3c 80 00       	push   $0x803c9e
  8016ff:	e8 38 05 00 00       	call   801c3c <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801704:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801709:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80170e:	66 ef                	out    %ax,(%dx)

	   // Check that we are able to do I/O
	   outw(0x8A00, 0x8A00);
	   cprintf("FS can do I/O\n");
  801710:	c7 04 24 ad 3c 80 00 	movl   $0x803cad,(%esp)
  801717:	e8 20 05 00 00       	call   801c3c <cprintf>

	   serve_init();
  80171c:	e8 35 fb ff ff       	call   801256 <serve_init>
	   fs_init();
  801721:	e8 bc f3 ff ff       	call   800ae2 <fs_init>
	   fs_test();
  801726:	e8 05 00 00 00       	call   801730 <fs_test>
	   serve();
  80172b:	e8 f0 fe ff ff       	call   801620 <serve>

00801730 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	53                   	push   %ebx
  801734:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801737:	6a 07                	push   $0x7
  801739:	68 00 10 00 00       	push   $0x1000
  80173e:	6a 00                	push   $0x0
  801740:	e8 7f 0e 00 00       	call   8025c4 <sys_page_alloc>
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	85 c0                	test   %eax,%eax
  80174a:	79 12                	jns    80175e <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  80174c:	50                   	push   %eax
  80174d:	68 bc 3c 80 00       	push   $0x803cbc
  801752:	6a 12                	push   $0x12
  801754:	68 cf 3c 80 00       	push   $0x803ccf
  801759:	e8 05 04 00 00       	call   801b63 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80175e:	83 ec 04             	sub    $0x4,%esp
  801761:	68 00 10 00 00       	push   $0x1000
  801766:	ff 35 04 a0 80 00    	pushl  0x80a004
  80176c:	68 00 10 00 00       	push   $0x1000
  801771:	e8 dd 0b 00 00       	call   802353 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801776:	e8 10 f1 ff ff       	call   80088b <alloc_block>
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	79 12                	jns    801794 <fs_test+0x64>
		panic("alloc_block: %e", r);
  801782:	50                   	push   %eax
  801783:	68 d9 3c 80 00       	push   $0x803cd9
  801788:	6a 17                	push   $0x17
  80178a:	68 cf 3c 80 00       	push   $0x803ccf
  80178f:	e8 cf 03 00 00       	call   801b63 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801794:	8d 50 1f             	lea    0x1f(%eax),%edx
  801797:	85 c0                	test   %eax,%eax
  801799:	0f 49 d0             	cmovns %eax,%edx
  80179c:	c1 fa 05             	sar    $0x5,%edx
  80179f:	89 c3                	mov    %eax,%ebx
  8017a1:	c1 fb 1f             	sar    $0x1f,%ebx
  8017a4:	c1 eb 1b             	shr    $0x1b,%ebx
  8017a7:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8017aa:	83 e1 1f             	and    $0x1f,%ecx
  8017ad:	29 d9                	sub    %ebx,%ecx
  8017af:	b8 01 00 00 00       	mov    $0x1,%eax
  8017b4:	d3 e0                	shl    %cl,%eax
  8017b6:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8017bd:	75 16                	jne    8017d5 <fs_test+0xa5>
  8017bf:	68 e9 3c 80 00       	push   $0x803ce9
  8017c4:	68 5d 39 80 00       	push   $0x80395d
  8017c9:	6a 19                	push   $0x19
  8017cb:	68 cf 3c 80 00       	push   $0x803ccf
  8017d0:	e8 8e 03 00 00       	call   801b63 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8017d5:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8017db:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8017de:	74 16                	je     8017f6 <fs_test+0xc6>
  8017e0:	68 64 3e 80 00       	push   $0x803e64
  8017e5:	68 5d 39 80 00       	push   $0x80395d
  8017ea:	6a 1b                	push   $0x1b
  8017ec:	68 cf 3c 80 00       	push   $0x803ccf
  8017f1:	e8 6d 03 00 00       	call   801b63 <_panic>
	cprintf("alloc_block is good\n");
  8017f6:	83 ec 0c             	sub    $0xc,%esp
  8017f9:	68 04 3d 80 00       	push   $0x803d04
  8017fe:	e8 39 04 00 00       	call   801c3c <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801803:	83 c4 08             	add    $0x8,%esp
  801806:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801809:	50                   	push   %eax
  80180a:	68 19 3d 80 00       	push   $0x803d19
  80180f:	e8 ca f5 ff ff       	call   800dde <file_open>
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80181a:	74 1b                	je     801837 <fs_test+0x107>
  80181c:	89 c2                	mov    %eax,%edx
  80181e:	c1 ea 1f             	shr    $0x1f,%edx
  801821:	84 d2                	test   %dl,%dl
  801823:	74 12                	je     801837 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801825:	50                   	push   %eax
  801826:	68 24 3d 80 00       	push   $0x803d24
  80182b:	6a 1f                	push   $0x1f
  80182d:	68 cf 3c 80 00       	push   $0x803ccf
  801832:	e8 2c 03 00 00       	call   801b63 <_panic>
	else if (r == 0)
  801837:	85 c0                	test   %eax,%eax
  801839:	75 14                	jne    80184f <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80183b:	83 ec 04             	sub    $0x4,%esp
  80183e:	68 84 3e 80 00       	push   $0x803e84
  801843:	6a 21                	push   $0x21
  801845:	68 cf 3c 80 00       	push   $0x803ccf
  80184a:	e8 14 03 00 00       	call   801b63 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801855:	50                   	push   %eax
  801856:	68 3d 3d 80 00       	push   $0x803d3d
  80185b:	e8 7e f5 ff ff       	call   800dde <file_open>
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	85 c0                	test   %eax,%eax
  801865:	79 12                	jns    801879 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  801867:	50                   	push   %eax
  801868:	68 46 3d 80 00       	push   $0x803d46
  80186d:	6a 23                	push   $0x23
  80186f:	68 cf 3c 80 00       	push   $0x803ccf
  801874:	e8 ea 02 00 00       	call   801b63 <_panic>
	cprintf("file_open is good\n");
  801879:	83 ec 0c             	sub    $0xc,%esp
  80187c:	68 5d 3d 80 00       	push   $0x803d5d
  801881:	e8 b6 03 00 00       	call   801c3c <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801886:	83 c4 0c             	add    $0xc,%esp
  801889:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188c:	50                   	push   %eax
  80188d:	6a 00                	push   $0x0
  80188f:	ff 75 f4             	pushl  -0xc(%ebp)
  801892:	e8 aa f2 ff ff       	call   800b41 <file_get_block>
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	79 12                	jns    8018b0 <fs_test+0x180>
		panic("file_get_block: %e", r);
  80189e:	50                   	push   %eax
  80189f:	68 70 3d 80 00       	push   $0x803d70
  8018a4:	6a 27                	push   $0x27
  8018a6:	68 cf 3c 80 00       	push   $0x803ccf
  8018ab:	e8 b3 02 00 00       	call   801b63 <_panic>
	if (strcmp(blk, msg) != 0)
  8018b0:	83 ec 08             	sub    $0x8,%esp
  8018b3:	68 a4 3e 80 00       	push   $0x803ea4
  8018b8:	ff 75 f0             	pushl  -0x10(%ebp)
  8018bb:	e8 ab 09 00 00       	call   80226b <strcmp>
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	74 14                	je     8018db <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8018c7:	83 ec 04             	sub    $0x4,%esp
  8018ca:	68 cc 3e 80 00       	push   $0x803ecc
  8018cf:	6a 29                	push   $0x29
  8018d1:	68 cf 3c 80 00       	push   $0x803ccf
  8018d6:	e8 88 02 00 00       	call   801b63 <_panic>
	cprintf("file_get_block is good\n");
  8018db:	83 ec 0c             	sub    $0xc,%esp
  8018de:	68 83 3d 80 00       	push   $0x803d83
  8018e3:	e8 54 03 00 00       	call   801c3c <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8018e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018eb:	0f b6 10             	movzbl (%eax),%edx
  8018ee:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8018f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f3:	c1 e8 0c             	shr    $0xc,%eax
  8018f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	a8 40                	test   $0x40,%al
  801902:	75 16                	jne    80191a <fs_test+0x1ea>
  801904:	68 9c 3d 80 00       	push   $0x803d9c
  801909:	68 5d 39 80 00       	push   $0x80395d
  80190e:	6a 2d                	push   $0x2d
  801910:	68 cf 3c 80 00       	push   $0x803ccf
  801915:	e8 49 02 00 00       	call   801b63 <_panic>
	file_flush(f);
  80191a:	83 ec 0c             	sub    $0xc,%esp
  80191d:	ff 75 f4             	pushl  -0xc(%ebp)
  801920:	e8 ff f6 ff ff       	call   801024 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801925:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801928:	c1 e8 0c             	shr    $0xc,%eax
  80192b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	a8 40                	test   $0x40,%al
  801937:	74 16                	je     80194f <fs_test+0x21f>
  801939:	68 9b 3d 80 00       	push   $0x803d9b
  80193e:	68 5d 39 80 00       	push   $0x80395d
  801943:	6a 2f                	push   $0x2f
  801945:	68 cf 3c 80 00       	push   $0x803ccf
  80194a:	e8 14 02 00 00       	call   801b63 <_panic>
	cprintf("file_flush is good\n");
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	68 b7 3d 80 00       	push   $0x803db7
  801957:	e8 e0 02 00 00       	call   801c3c <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  80195c:	83 c4 08             	add    $0x8,%esp
  80195f:	6a 00                	push   $0x0
  801961:	ff 75 f4             	pushl  -0xc(%ebp)
  801964:	e8 34 f5 ff ff       	call   800e9d <file_set_size>
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	85 c0                	test   %eax,%eax
  80196e:	79 12                	jns    801982 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801970:	50                   	push   %eax
  801971:	68 cb 3d 80 00       	push   $0x803dcb
  801976:	6a 33                	push   $0x33
  801978:	68 cf 3c 80 00       	push   $0x803ccf
  80197d:	e8 e1 01 00 00       	call   801b63 <_panic>
	assert(f->f_direct[0] == 0);
  801982:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801985:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  80198c:	74 16                	je     8019a4 <fs_test+0x274>
  80198e:	68 dd 3d 80 00       	push   $0x803ddd
  801993:	68 5d 39 80 00       	push   $0x80395d
  801998:	6a 34                	push   $0x34
  80199a:	68 cf 3c 80 00       	push   $0x803ccf
  80199f:	e8 bf 01 00 00       	call   801b63 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019a4:	c1 e8 0c             	shr    $0xc,%eax
  8019a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019ae:	a8 40                	test   $0x40,%al
  8019b0:	74 16                	je     8019c8 <fs_test+0x298>
  8019b2:	68 f1 3d 80 00       	push   $0x803df1
  8019b7:	68 5d 39 80 00       	push   $0x80395d
  8019bc:	6a 35                	push   $0x35
  8019be:	68 cf 3c 80 00       	push   $0x803ccf
  8019c3:	e8 9b 01 00 00       	call   801b63 <_panic>
	cprintf("file_truncate is good\n");
  8019c8:	83 ec 0c             	sub    $0xc,%esp
  8019cb:	68 0b 3e 80 00       	push   $0x803e0b
  8019d0:	e8 67 02 00 00       	call   801c3c <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8019d5:	c7 04 24 a4 3e 80 00 	movl   $0x803ea4,(%esp)
  8019dc:	e8 a7 07 00 00       	call   802188 <strlen>
  8019e1:	83 c4 08             	add    $0x8,%esp
  8019e4:	50                   	push   %eax
  8019e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e8:	e8 b0 f4 ff ff       	call   800e9d <file_set_size>
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	79 12                	jns    801a06 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  8019f4:	50                   	push   %eax
  8019f5:	68 22 3e 80 00       	push   $0x803e22
  8019fa:	6a 39                	push   $0x39
  8019fc:	68 cf 3c 80 00       	push   $0x803ccf
  801a01:	e8 5d 01 00 00       	call   801b63 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a09:	89 c2                	mov    %eax,%edx
  801a0b:	c1 ea 0c             	shr    $0xc,%edx
  801a0e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a15:	f6 c2 40             	test   $0x40,%dl
  801a18:	74 16                	je     801a30 <fs_test+0x300>
  801a1a:	68 f1 3d 80 00       	push   $0x803df1
  801a1f:	68 5d 39 80 00       	push   $0x80395d
  801a24:	6a 3a                	push   $0x3a
  801a26:	68 cf 3c 80 00       	push   $0x803ccf
  801a2b:	e8 33 01 00 00       	call   801b63 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801a30:	83 ec 04             	sub    $0x4,%esp
  801a33:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801a36:	52                   	push   %edx
  801a37:	6a 00                	push   $0x0
  801a39:	50                   	push   %eax
  801a3a:	e8 02 f1 ff ff       	call   800b41 <file_get_block>
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	85 c0                	test   %eax,%eax
  801a44:	79 12                	jns    801a58 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801a46:	50                   	push   %eax
  801a47:	68 36 3e 80 00       	push   $0x803e36
  801a4c:	6a 3c                	push   $0x3c
  801a4e:	68 cf 3c 80 00       	push   $0x803ccf
  801a53:	e8 0b 01 00 00       	call   801b63 <_panic>
	strcpy(blk, msg);
  801a58:	83 ec 08             	sub    $0x8,%esp
  801a5b:	68 a4 3e 80 00       	push   $0x803ea4
  801a60:	ff 75 f0             	pushl  -0x10(%ebp)
  801a63:	e8 59 07 00 00       	call   8021c1 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6b:	c1 e8 0c             	shr    $0xc,%eax
  801a6e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	a8 40                	test   $0x40,%al
  801a7a:	75 16                	jne    801a92 <fs_test+0x362>
  801a7c:	68 9c 3d 80 00       	push   $0x803d9c
  801a81:	68 5d 39 80 00       	push   $0x80395d
  801a86:	6a 3e                	push   $0x3e
  801a88:	68 cf 3c 80 00       	push   $0x803ccf
  801a8d:	e8 d1 00 00 00       	call   801b63 <_panic>
	file_flush(f);
  801a92:	83 ec 0c             	sub    $0xc,%esp
  801a95:	ff 75 f4             	pushl  -0xc(%ebp)
  801a98:	e8 87 f5 ff ff       	call   801024 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aa0:	c1 e8 0c             	shr    $0xc,%eax
  801aa3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	a8 40                	test   $0x40,%al
  801aaf:	74 16                	je     801ac7 <fs_test+0x397>
  801ab1:	68 9b 3d 80 00       	push   $0x803d9b
  801ab6:	68 5d 39 80 00       	push   $0x80395d
  801abb:	6a 40                	push   $0x40
  801abd:	68 cf 3c 80 00       	push   $0x803ccf
  801ac2:	e8 9c 00 00 00       	call   801b63 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aca:	c1 e8 0c             	shr    $0xc,%eax
  801acd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ad4:	a8 40                	test   $0x40,%al
  801ad6:	74 16                	je     801aee <fs_test+0x3be>
  801ad8:	68 f1 3d 80 00       	push   $0x803df1
  801add:	68 5d 39 80 00       	push   $0x80395d
  801ae2:	6a 41                	push   $0x41
  801ae4:	68 cf 3c 80 00       	push   $0x803ccf
  801ae9:	e8 75 00 00 00       	call   801b63 <_panic>
	cprintf("file rewrite is good\n");
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	68 4b 3e 80 00       	push   $0x803e4b
  801af6:	e8 41 01 00 00       	call   801c3c <cprintf>
}
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b01:	c9                   	leave  
  801b02:	c3                   	ret    

00801b03 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	56                   	push   %esi
  801b07:	53                   	push   %ebx
  801b08:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b0b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  801b0e:	e8 73 0a 00 00       	call   802586 <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  801b13:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b18:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b1b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b20:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801b25:	85 db                	test   %ebx,%ebx
  801b27:	7e 07                	jle    801b30 <libmain+0x2d>
		binaryname = argv[0];
  801b29:	8b 06                	mov    (%esi),%eax
  801b2b:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801b30:	83 ec 08             	sub    $0x8,%esp
  801b33:	56                   	push   %esi
  801b34:	53                   	push   %ebx
  801b35:	e8 b0 fb ff ff       	call   8016ea <umain>

	// exit gracefully
	exit();
  801b3a:	e8 0a 00 00 00       	call   801b49 <exit>
}
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b45:	5b                   	pop    %ebx
  801b46:	5e                   	pop    %esi
  801b47:	5d                   	pop    %ebp
  801b48:	c3                   	ret    

00801b49 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801b4f:	e8 97 0f 00 00       	call   802aeb <close_all>
	sys_env_destroy(0);
  801b54:	83 ec 0c             	sub    $0xc,%esp
  801b57:	6a 00                	push   $0x0
  801b59:	e8 e7 09 00 00       	call   802545 <sys_env_destroy>
}
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	c9                   	leave  
  801b62:	c3                   	ret    

00801b63 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b68:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b6b:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801b71:	e8 10 0a 00 00       	call   802586 <sys_getenvid>
  801b76:	83 ec 0c             	sub    $0xc,%esp
  801b79:	ff 75 0c             	pushl  0xc(%ebp)
  801b7c:	ff 75 08             	pushl  0x8(%ebp)
  801b7f:	56                   	push   %esi
  801b80:	50                   	push   %eax
  801b81:	68 fc 3e 80 00       	push   $0x803efc
  801b86:	e8 b1 00 00 00       	call   801c3c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b8b:	83 c4 18             	add    $0x18,%esp
  801b8e:	53                   	push   %ebx
  801b8f:	ff 75 10             	pushl  0x10(%ebp)
  801b92:	e8 54 00 00 00       	call   801beb <vcprintf>
	cprintf("\n");
  801b97:	c7 04 24 ff 3a 80 00 	movl   $0x803aff,(%esp)
  801b9e:	e8 99 00 00 00       	call   801c3c <cprintf>
  801ba3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ba6:	cc                   	int3   
  801ba7:	eb fd                	jmp    801ba6 <_panic+0x43>

00801ba9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	53                   	push   %ebx
  801bad:	83 ec 04             	sub    $0x4,%esp
  801bb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801bb3:	8b 13                	mov    (%ebx),%edx
  801bb5:	8d 42 01             	lea    0x1(%edx),%eax
  801bb8:	89 03                	mov    %eax,(%ebx)
  801bba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801bc1:	3d ff 00 00 00       	cmp    $0xff,%eax
  801bc6:	75 1a                	jne    801be2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801bc8:	83 ec 08             	sub    $0x8,%esp
  801bcb:	68 ff 00 00 00       	push   $0xff
  801bd0:	8d 43 08             	lea    0x8(%ebx),%eax
  801bd3:	50                   	push   %eax
  801bd4:	e8 2f 09 00 00       	call   802508 <sys_cputs>
		b->idx = 0;
  801bd9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bdf:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801be2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801be6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be9:	c9                   	leave  
  801bea:	c3                   	ret    

00801beb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801bf4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801bfb:	00 00 00 
	b.cnt = 0;
  801bfe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801c05:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801c08:	ff 75 0c             	pushl  0xc(%ebp)
  801c0b:	ff 75 08             	pushl  0x8(%ebp)
  801c0e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801c14:	50                   	push   %eax
  801c15:	68 a9 1b 80 00       	push   $0x801ba9
  801c1a:	e8 54 01 00 00       	call   801d73 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801c1f:	83 c4 08             	add    $0x8,%esp
  801c22:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801c28:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801c2e:	50                   	push   %eax
  801c2f:	e8 d4 08 00 00       	call   802508 <sys_cputs>

	return b.cnt;
}
  801c34:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801c3a:	c9                   	leave  
  801c3b:	c3                   	ret    

00801c3c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c42:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801c45:	50                   	push   %eax
  801c46:	ff 75 08             	pushl  0x8(%ebp)
  801c49:	e8 9d ff ff ff       	call   801beb <vcprintf>
	va_end(ap);

	return cnt;
}
  801c4e:	c9                   	leave  
  801c4f:	c3                   	ret    

00801c50 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	57                   	push   %edi
  801c54:	56                   	push   %esi
  801c55:	53                   	push   %ebx
  801c56:	83 ec 1c             	sub    $0x1c,%esp
  801c59:	89 c7                	mov    %eax,%edi
  801c5b:	89 d6                	mov    %edx,%esi
  801c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c60:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c63:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c66:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801c69:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801c6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c71:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801c74:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801c77:	39 d3                	cmp    %edx,%ebx
  801c79:	72 05                	jb     801c80 <printnum+0x30>
  801c7b:	39 45 10             	cmp    %eax,0x10(%ebp)
  801c7e:	77 45                	ja     801cc5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801c80:	83 ec 0c             	sub    $0xc,%esp
  801c83:	ff 75 18             	pushl  0x18(%ebp)
  801c86:	8b 45 14             	mov    0x14(%ebp),%eax
  801c89:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801c8c:	53                   	push   %ebx
  801c8d:	ff 75 10             	pushl  0x10(%ebp)
  801c90:	83 ec 08             	sub    $0x8,%esp
  801c93:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c96:	ff 75 e0             	pushl  -0x20(%ebp)
  801c99:	ff 75 dc             	pushl  -0x24(%ebp)
  801c9c:	ff 75 d8             	pushl  -0x28(%ebp)
  801c9f:	e8 ec 19 00 00       	call   803690 <__udivdi3>
  801ca4:	83 c4 18             	add    $0x18,%esp
  801ca7:	52                   	push   %edx
  801ca8:	50                   	push   %eax
  801ca9:	89 f2                	mov    %esi,%edx
  801cab:	89 f8                	mov    %edi,%eax
  801cad:	e8 9e ff ff ff       	call   801c50 <printnum>
  801cb2:	83 c4 20             	add    $0x20,%esp
  801cb5:	eb 18                	jmp    801ccf <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801cb7:	83 ec 08             	sub    $0x8,%esp
  801cba:	56                   	push   %esi
  801cbb:	ff 75 18             	pushl  0x18(%ebp)
  801cbe:	ff d7                	call   *%edi
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	eb 03                	jmp    801cc8 <printnum+0x78>
  801cc5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801cc8:	83 eb 01             	sub    $0x1,%ebx
  801ccb:	85 db                	test   %ebx,%ebx
  801ccd:	7f e8                	jg     801cb7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801ccf:	83 ec 08             	sub    $0x8,%esp
  801cd2:	56                   	push   %esi
  801cd3:	83 ec 04             	sub    $0x4,%esp
  801cd6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cd9:	ff 75 e0             	pushl  -0x20(%ebp)
  801cdc:	ff 75 dc             	pushl  -0x24(%ebp)
  801cdf:	ff 75 d8             	pushl  -0x28(%ebp)
  801ce2:	e8 d9 1a 00 00       	call   8037c0 <__umoddi3>
  801ce7:	83 c4 14             	add    $0x14,%esp
  801cea:	0f be 80 1f 3f 80 00 	movsbl 0x803f1f(%eax),%eax
  801cf1:	50                   	push   %eax
  801cf2:	ff d7                	call   *%edi
}
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cfa:	5b                   	pop    %ebx
  801cfb:	5e                   	pop    %esi
  801cfc:	5f                   	pop    %edi
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    

00801cff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801d02:	83 fa 01             	cmp    $0x1,%edx
  801d05:	7e 0e                	jle    801d15 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801d07:	8b 10                	mov    (%eax),%edx
  801d09:	8d 4a 08             	lea    0x8(%edx),%ecx
  801d0c:	89 08                	mov    %ecx,(%eax)
  801d0e:	8b 02                	mov    (%edx),%eax
  801d10:	8b 52 04             	mov    0x4(%edx),%edx
  801d13:	eb 22                	jmp    801d37 <getuint+0x38>
	else if (lflag)
  801d15:	85 d2                	test   %edx,%edx
  801d17:	74 10                	je     801d29 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801d19:	8b 10                	mov    (%eax),%edx
  801d1b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801d1e:	89 08                	mov    %ecx,(%eax)
  801d20:	8b 02                	mov    (%edx),%eax
  801d22:	ba 00 00 00 00       	mov    $0x0,%edx
  801d27:	eb 0e                	jmp    801d37 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801d29:	8b 10                	mov    (%eax),%edx
  801d2b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801d2e:	89 08                	mov    %ecx,(%eax)
  801d30:	8b 02                	mov    (%edx),%eax
  801d32:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    

00801d39 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801d3f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801d43:	8b 10                	mov    (%eax),%edx
  801d45:	3b 50 04             	cmp    0x4(%eax),%edx
  801d48:	73 0a                	jae    801d54 <sprintputch+0x1b>
		*b->buf++ = ch;
  801d4a:	8d 4a 01             	lea    0x1(%edx),%ecx
  801d4d:	89 08                	mov    %ecx,(%eax)
  801d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d52:	88 02                	mov    %al,(%edx)
}
  801d54:	5d                   	pop    %ebp
  801d55:	c3                   	ret    

00801d56 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801d5c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801d5f:	50                   	push   %eax
  801d60:	ff 75 10             	pushl  0x10(%ebp)
  801d63:	ff 75 0c             	pushl  0xc(%ebp)
  801d66:	ff 75 08             	pushl  0x8(%ebp)
  801d69:	e8 05 00 00 00       	call   801d73 <vprintfmt>
	va_end(ap);
}
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	57                   	push   %edi
  801d77:	56                   	push   %esi
  801d78:	53                   	push   %ebx
  801d79:	83 ec 2c             	sub    $0x2c,%esp
  801d7c:	8b 75 08             	mov    0x8(%ebp),%esi
  801d7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d82:	8b 7d 10             	mov    0x10(%ebp),%edi
  801d85:	eb 12                	jmp    801d99 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801d87:	85 c0                	test   %eax,%eax
  801d89:	0f 84 89 03 00 00    	je     802118 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801d8f:	83 ec 08             	sub    $0x8,%esp
  801d92:	53                   	push   %ebx
  801d93:	50                   	push   %eax
  801d94:	ff d6                	call   *%esi
  801d96:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801d99:	83 c7 01             	add    $0x1,%edi
  801d9c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801da0:	83 f8 25             	cmp    $0x25,%eax
  801da3:	75 e2                	jne    801d87 <vprintfmt+0x14>
  801da5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801da9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801db0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801db7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801dbe:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc3:	eb 07                	jmp    801dcc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801dc8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dcc:	8d 47 01             	lea    0x1(%edi),%eax
  801dcf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801dd2:	0f b6 07             	movzbl (%edi),%eax
  801dd5:	0f b6 c8             	movzbl %al,%ecx
  801dd8:	83 e8 23             	sub    $0x23,%eax
  801ddb:	3c 55                	cmp    $0x55,%al
  801ddd:	0f 87 1a 03 00 00    	ja     8020fd <vprintfmt+0x38a>
  801de3:	0f b6 c0             	movzbl %al,%eax
  801de6:	ff 24 85 60 40 80 00 	jmp    *0x804060(,%eax,4)
  801ded:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801df0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801df4:	eb d6                	jmp    801dcc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801df6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801df9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801e01:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801e04:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801e08:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801e0b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801e0e:	83 fa 09             	cmp    $0x9,%edx
  801e11:	77 39                	ja     801e4c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801e13:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801e16:	eb e9                	jmp    801e01 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801e18:	8b 45 14             	mov    0x14(%ebp),%eax
  801e1b:	8d 48 04             	lea    0x4(%eax),%ecx
  801e1e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801e21:	8b 00                	mov    (%eax),%eax
  801e23:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801e29:	eb 27                	jmp    801e52 <vprintfmt+0xdf>
  801e2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e35:	0f 49 c8             	cmovns %eax,%ecx
  801e38:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e3b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e3e:	eb 8c                	jmp    801dcc <vprintfmt+0x59>
  801e40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801e43:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801e4a:	eb 80                	jmp    801dcc <vprintfmt+0x59>
  801e4c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e4f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801e52:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e56:	0f 89 70 ff ff ff    	jns    801dcc <vprintfmt+0x59>
				width = precision, precision = -1;
  801e5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801e5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e62:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801e69:	e9 5e ff ff ff       	jmp    801dcc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801e6e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e71:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801e74:	e9 53 ff ff ff       	jmp    801dcc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801e79:	8b 45 14             	mov    0x14(%ebp),%eax
  801e7c:	8d 50 04             	lea    0x4(%eax),%edx
  801e7f:	89 55 14             	mov    %edx,0x14(%ebp)
  801e82:	83 ec 08             	sub    $0x8,%esp
  801e85:	53                   	push   %ebx
  801e86:	ff 30                	pushl  (%eax)
  801e88:	ff d6                	call   *%esi
			break;
  801e8a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801e90:	e9 04 ff ff ff       	jmp    801d99 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801e95:	8b 45 14             	mov    0x14(%ebp),%eax
  801e98:	8d 50 04             	lea    0x4(%eax),%edx
  801e9b:	89 55 14             	mov    %edx,0x14(%ebp)
  801e9e:	8b 00                	mov    (%eax),%eax
  801ea0:	99                   	cltd   
  801ea1:	31 d0                	xor    %edx,%eax
  801ea3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801ea5:	83 f8 0f             	cmp    $0xf,%eax
  801ea8:	7f 0b                	jg     801eb5 <vprintfmt+0x142>
  801eaa:	8b 14 85 c0 41 80 00 	mov    0x8041c0(,%eax,4),%edx
  801eb1:	85 d2                	test   %edx,%edx
  801eb3:	75 18                	jne    801ecd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801eb5:	50                   	push   %eax
  801eb6:	68 37 3f 80 00       	push   $0x803f37
  801ebb:	53                   	push   %ebx
  801ebc:	56                   	push   %esi
  801ebd:	e8 94 fe ff ff       	call   801d56 <printfmt>
  801ec2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ec5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801ec8:	e9 cc fe ff ff       	jmp    801d99 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801ecd:	52                   	push   %edx
  801ece:	68 6f 39 80 00       	push   $0x80396f
  801ed3:	53                   	push   %ebx
  801ed4:	56                   	push   %esi
  801ed5:	e8 7c fe ff ff       	call   801d56 <printfmt>
  801eda:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801edd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ee0:	e9 b4 fe ff ff       	jmp    801d99 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801ee5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ee8:	8d 50 04             	lea    0x4(%eax),%edx
  801eeb:	89 55 14             	mov    %edx,0x14(%ebp)
  801eee:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801ef0:	85 ff                	test   %edi,%edi
  801ef2:	b8 30 3f 80 00       	mov    $0x803f30,%eax
  801ef7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801efa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801efe:	0f 8e 94 00 00 00    	jle    801f98 <vprintfmt+0x225>
  801f04:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801f08:	0f 84 98 00 00 00    	je     801fa6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801f0e:	83 ec 08             	sub    $0x8,%esp
  801f11:	ff 75 d0             	pushl  -0x30(%ebp)
  801f14:	57                   	push   %edi
  801f15:	e8 86 02 00 00       	call   8021a0 <strnlen>
  801f1a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801f1d:	29 c1                	sub    %eax,%ecx
  801f1f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801f22:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801f25:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801f29:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f2c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801f2f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801f31:	eb 0f                	jmp    801f42 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801f33:	83 ec 08             	sub    $0x8,%esp
  801f36:	53                   	push   %ebx
  801f37:	ff 75 e0             	pushl  -0x20(%ebp)
  801f3a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801f3c:	83 ef 01             	sub    $0x1,%edi
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	85 ff                	test   %edi,%edi
  801f44:	7f ed                	jg     801f33 <vprintfmt+0x1c0>
  801f46:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801f49:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801f4c:	85 c9                	test   %ecx,%ecx
  801f4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f53:	0f 49 c1             	cmovns %ecx,%eax
  801f56:	29 c1                	sub    %eax,%ecx
  801f58:	89 75 08             	mov    %esi,0x8(%ebp)
  801f5b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f5e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f61:	89 cb                	mov    %ecx,%ebx
  801f63:	eb 4d                	jmp    801fb2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801f65:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801f69:	74 1b                	je     801f86 <vprintfmt+0x213>
  801f6b:	0f be c0             	movsbl %al,%eax
  801f6e:	83 e8 20             	sub    $0x20,%eax
  801f71:	83 f8 5e             	cmp    $0x5e,%eax
  801f74:	76 10                	jbe    801f86 <vprintfmt+0x213>
					putch('?', putdat);
  801f76:	83 ec 08             	sub    $0x8,%esp
  801f79:	ff 75 0c             	pushl  0xc(%ebp)
  801f7c:	6a 3f                	push   $0x3f
  801f7e:	ff 55 08             	call   *0x8(%ebp)
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	eb 0d                	jmp    801f93 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801f86:	83 ec 08             	sub    $0x8,%esp
  801f89:	ff 75 0c             	pushl  0xc(%ebp)
  801f8c:	52                   	push   %edx
  801f8d:	ff 55 08             	call   *0x8(%ebp)
  801f90:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801f93:	83 eb 01             	sub    $0x1,%ebx
  801f96:	eb 1a                	jmp    801fb2 <vprintfmt+0x23f>
  801f98:	89 75 08             	mov    %esi,0x8(%ebp)
  801f9b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f9e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801fa1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801fa4:	eb 0c                	jmp    801fb2 <vprintfmt+0x23f>
  801fa6:	89 75 08             	mov    %esi,0x8(%ebp)
  801fa9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801fac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801faf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801fb2:	83 c7 01             	add    $0x1,%edi
  801fb5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801fb9:	0f be d0             	movsbl %al,%edx
  801fbc:	85 d2                	test   %edx,%edx
  801fbe:	74 23                	je     801fe3 <vprintfmt+0x270>
  801fc0:	85 f6                	test   %esi,%esi
  801fc2:	78 a1                	js     801f65 <vprintfmt+0x1f2>
  801fc4:	83 ee 01             	sub    $0x1,%esi
  801fc7:	79 9c                	jns    801f65 <vprintfmt+0x1f2>
  801fc9:	89 df                	mov    %ebx,%edi
  801fcb:	8b 75 08             	mov    0x8(%ebp),%esi
  801fce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801fd1:	eb 18                	jmp    801feb <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801fd3:	83 ec 08             	sub    $0x8,%esp
  801fd6:	53                   	push   %ebx
  801fd7:	6a 20                	push   $0x20
  801fd9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801fdb:	83 ef 01             	sub    $0x1,%edi
  801fde:	83 c4 10             	add    $0x10,%esp
  801fe1:	eb 08                	jmp    801feb <vprintfmt+0x278>
  801fe3:	89 df                	mov    %ebx,%edi
  801fe5:	8b 75 08             	mov    0x8(%ebp),%esi
  801fe8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801feb:	85 ff                	test   %edi,%edi
  801fed:	7f e4                	jg     801fd3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ff2:	e9 a2 fd ff ff       	jmp    801d99 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801ff7:	83 fa 01             	cmp    $0x1,%edx
  801ffa:	7e 16                	jle    802012 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801ffc:	8b 45 14             	mov    0x14(%ebp),%eax
  801fff:	8d 50 08             	lea    0x8(%eax),%edx
  802002:	89 55 14             	mov    %edx,0x14(%ebp)
  802005:	8b 50 04             	mov    0x4(%eax),%edx
  802008:	8b 00                	mov    (%eax),%eax
  80200a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80200d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  802010:	eb 32                	jmp    802044 <vprintfmt+0x2d1>
	else if (lflag)
  802012:	85 d2                	test   %edx,%edx
  802014:	74 18                	je     80202e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  802016:	8b 45 14             	mov    0x14(%ebp),%eax
  802019:	8d 50 04             	lea    0x4(%eax),%edx
  80201c:	89 55 14             	mov    %edx,0x14(%ebp)
  80201f:	8b 00                	mov    (%eax),%eax
  802021:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802024:	89 c1                	mov    %eax,%ecx
  802026:	c1 f9 1f             	sar    $0x1f,%ecx
  802029:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80202c:	eb 16                	jmp    802044 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80202e:	8b 45 14             	mov    0x14(%ebp),%eax
  802031:	8d 50 04             	lea    0x4(%eax),%edx
  802034:	89 55 14             	mov    %edx,0x14(%ebp)
  802037:	8b 00                	mov    (%eax),%eax
  802039:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80203c:	89 c1                	mov    %eax,%ecx
  80203e:	c1 f9 1f             	sar    $0x1f,%ecx
  802041:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  802044:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802047:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80204a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80204f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  802053:	79 74                	jns    8020c9 <vprintfmt+0x356>
				putch('-', putdat);
  802055:	83 ec 08             	sub    $0x8,%esp
  802058:	53                   	push   %ebx
  802059:	6a 2d                	push   $0x2d
  80205b:	ff d6                	call   *%esi
				num = -(long long) num;
  80205d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802060:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802063:	f7 d8                	neg    %eax
  802065:	83 d2 00             	adc    $0x0,%edx
  802068:	f7 da                	neg    %edx
  80206a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80206d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  802072:	eb 55                	jmp    8020c9 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  802074:	8d 45 14             	lea    0x14(%ebp),%eax
  802077:	e8 83 fc ff ff       	call   801cff <getuint>
			base = 10;
  80207c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  802081:	eb 46                	jmp    8020c9 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  802083:	8d 45 14             	lea    0x14(%ebp),%eax
  802086:	e8 74 fc ff ff       	call   801cff <getuint>
			base = 8;
  80208b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  802090:	eb 37                	jmp    8020c9 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  802092:	83 ec 08             	sub    $0x8,%esp
  802095:	53                   	push   %ebx
  802096:	6a 30                	push   $0x30
  802098:	ff d6                	call   *%esi
			putch('x', putdat);
  80209a:	83 c4 08             	add    $0x8,%esp
  80209d:	53                   	push   %ebx
  80209e:	6a 78                	push   $0x78
  8020a0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8020a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8020a5:	8d 50 04             	lea    0x4(%eax),%edx
  8020a8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8020ab:	8b 00                	mov    (%eax),%eax
  8020ad:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8020b2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8020b5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8020ba:	eb 0d                	jmp    8020c9 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8020bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8020bf:	e8 3b fc ff ff       	call   801cff <getuint>
			base = 16;
  8020c4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8020c9:	83 ec 0c             	sub    $0xc,%esp
  8020cc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8020d0:	57                   	push   %edi
  8020d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8020d4:	51                   	push   %ecx
  8020d5:	52                   	push   %edx
  8020d6:	50                   	push   %eax
  8020d7:	89 da                	mov    %ebx,%edx
  8020d9:	89 f0                	mov    %esi,%eax
  8020db:	e8 70 fb ff ff       	call   801c50 <printnum>
			break;
  8020e0:	83 c4 20             	add    $0x20,%esp
  8020e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8020e6:	e9 ae fc ff ff       	jmp    801d99 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8020eb:	83 ec 08             	sub    $0x8,%esp
  8020ee:	53                   	push   %ebx
  8020ef:	51                   	push   %ecx
  8020f0:	ff d6                	call   *%esi
			break;
  8020f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8020f8:	e9 9c fc ff ff       	jmp    801d99 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8020fd:	83 ec 08             	sub    $0x8,%esp
  802100:	53                   	push   %ebx
  802101:	6a 25                	push   $0x25
  802103:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  802105:	83 c4 10             	add    $0x10,%esp
  802108:	eb 03                	jmp    80210d <vprintfmt+0x39a>
  80210a:	83 ef 01             	sub    $0x1,%edi
  80210d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  802111:	75 f7                	jne    80210a <vprintfmt+0x397>
  802113:	e9 81 fc ff ff       	jmp    801d99 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  802118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80211b:	5b                   	pop    %ebx
  80211c:	5e                   	pop    %esi
  80211d:	5f                   	pop    %edi
  80211e:	5d                   	pop    %ebp
  80211f:	c3                   	ret    

00802120 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	83 ec 18             	sub    $0x18,%esp
  802126:	8b 45 08             	mov    0x8(%ebp),%eax
  802129:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80212c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80212f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802133:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802136:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80213d:	85 c0                	test   %eax,%eax
  80213f:	74 26                	je     802167 <vsnprintf+0x47>
  802141:	85 d2                	test   %edx,%edx
  802143:	7e 22                	jle    802167 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802145:	ff 75 14             	pushl  0x14(%ebp)
  802148:	ff 75 10             	pushl  0x10(%ebp)
  80214b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80214e:	50                   	push   %eax
  80214f:	68 39 1d 80 00       	push   $0x801d39
  802154:	e8 1a fc ff ff       	call   801d73 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802159:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80215c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80215f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	eb 05                	jmp    80216c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  802167:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80216c:	c9                   	leave  
  80216d:	c3                   	ret    

0080216e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802174:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802177:	50                   	push   %eax
  802178:	ff 75 10             	pushl  0x10(%ebp)
  80217b:	ff 75 0c             	pushl  0xc(%ebp)
  80217e:	ff 75 08             	pushl  0x8(%ebp)
  802181:	e8 9a ff ff ff       	call   802120 <vsnprintf>
	va_end(ap);

	return rc;
}
  802186:	c9                   	leave  
  802187:	c3                   	ret    

00802188 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802188:	55                   	push   %ebp
  802189:	89 e5                	mov    %esp,%ebp
  80218b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80218e:	b8 00 00 00 00       	mov    $0x0,%eax
  802193:	eb 03                	jmp    802198 <strlen+0x10>
		n++;
  802195:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802198:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80219c:	75 f7                	jne    802195 <strlen+0xd>
		n++;
	return n;
}
  80219e:	5d                   	pop    %ebp
  80219f:	c3                   	ret    

008021a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8021a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8021ae:	eb 03                	jmp    8021b3 <strnlen+0x13>
		n++;
  8021b0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8021b3:	39 c2                	cmp    %eax,%edx
  8021b5:	74 08                	je     8021bf <strnlen+0x1f>
  8021b7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8021bb:	75 f3                	jne    8021b0 <strnlen+0x10>
  8021bd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8021bf:	5d                   	pop    %ebp
  8021c0:	c3                   	ret    

008021c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8021c1:	55                   	push   %ebp
  8021c2:	89 e5                	mov    %esp,%ebp
  8021c4:	53                   	push   %ebx
  8021c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8021cb:	89 c2                	mov    %eax,%edx
  8021cd:	83 c2 01             	add    $0x1,%edx
  8021d0:	83 c1 01             	add    $0x1,%ecx
  8021d3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8021d7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8021da:	84 db                	test   %bl,%bl
  8021dc:	75 ef                	jne    8021cd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8021de:	5b                   	pop    %ebx
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	53                   	push   %ebx
  8021e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8021e8:	53                   	push   %ebx
  8021e9:	e8 9a ff ff ff       	call   802188 <strlen>
  8021ee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8021f1:	ff 75 0c             	pushl  0xc(%ebp)
  8021f4:	01 d8                	add    %ebx,%eax
  8021f6:	50                   	push   %eax
  8021f7:	e8 c5 ff ff ff       	call   8021c1 <strcpy>
	return dst;
}
  8021fc:	89 d8                	mov    %ebx,%eax
  8021fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802201:	c9                   	leave  
  802202:	c3                   	ret    

00802203 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802203:	55                   	push   %ebp
  802204:	89 e5                	mov    %esp,%ebp
  802206:	56                   	push   %esi
  802207:	53                   	push   %ebx
  802208:	8b 75 08             	mov    0x8(%ebp),%esi
  80220b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80220e:	89 f3                	mov    %esi,%ebx
  802210:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802213:	89 f2                	mov    %esi,%edx
  802215:	eb 0f                	jmp    802226 <strncpy+0x23>
		*dst++ = *src;
  802217:	83 c2 01             	add    $0x1,%edx
  80221a:	0f b6 01             	movzbl (%ecx),%eax
  80221d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802220:	80 39 01             	cmpb   $0x1,(%ecx)
  802223:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802226:	39 da                	cmp    %ebx,%edx
  802228:	75 ed                	jne    802217 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80222a:	89 f0                	mov    %esi,%eax
  80222c:	5b                   	pop    %ebx
  80222d:	5e                   	pop    %esi
  80222e:	5d                   	pop    %ebp
  80222f:	c3                   	ret    

00802230 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	56                   	push   %esi
  802234:	53                   	push   %ebx
  802235:	8b 75 08             	mov    0x8(%ebp),%esi
  802238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80223b:	8b 55 10             	mov    0x10(%ebp),%edx
  80223e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802240:	85 d2                	test   %edx,%edx
  802242:	74 21                	je     802265 <strlcpy+0x35>
  802244:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802248:	89 f2                	mov    %esi,%edx
  80224a:	eb 09                	jmp    802255 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80224c:	83 c2 01             	add    $0x1,%edx
  80224f:	83 c1 01             	add    $0x1,%ecx
  802252:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802255:	39 c2                	cmp    %eax,%edx
  802257:	74 09                	je     802262 <strlcpy+0x32>
  802259:	0f b6 19             	movzbl (%ecx),%ebx
  80225c:	84 db                	test   %bl,%bl
  80225e:	75 ec                	jne    80224c <strlcpy+0x1c>
  802260:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  802262:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802265:	29 f0                	sub    %esi,%eax
}
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    

0080226b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80226b:	55                   	push   %ebp
  80226c:	89 e5                	mov    %esp,%ebp
  80226e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802271:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802274:	eb 06                	jmp    80227c <strcmp+0x11>
		p++, q++;
  802276:	83 c1 01             	add    $0x1,%ecx
  802279:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80227c:	0f b6 01             	movzbl (%ecx),%eax
  80227f:	84 c0                	test   %al,%al
  802281:	74 04                	je     802287 <strcmp+0x1c>
  802283:	3a 02                	cmp    (%edx),%al
  802285:	74 ef                	je     802276 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802287:	0f b6 c0             	movzbl %al,%eax
  80228a:	0f b6 12             	movzbl (%edx),%edx
  80228d:	29 d0                	sub    %edx,%eax
}
  80228f:	5d                   	pop    %ebp
  802290:	c3                   	ret    

00802291 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
  802294:	53                   	push   %ebx
  802295:	8b 45 08             	mov    0x8(%ebp),%eax
  802298:	8b 55 0c             	mov    0xc(%ebp),%edx
  80229b:	89 c3                	mov    %eax,%ebx
  80229d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8022a0:	eb 06                	jmp    8022a8 <strncmp+0x17>
		n--, p++, q++;
  8022a2:	83 c0 01             	add    $0x1,%eax
  8022a5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8022a8:	39 d8                	cmp    %ebx,%eax
  8022aa:	74 15                	je     8022c1 <strncmp+0x30>
  8022ac:	0f b6 08             	movzbl (%eax),%ecx
  8022af:	84 c9                	test   %cl,%cl
  8022b1:	74 04                	je     8022b7 <strncmp+0x26>
  8022b3:	3a 0a                	cmp    (%edx),%cl
  8022b5:	74 eb                	je     8022a2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8022b7:	0f b6 00             	movzbl (%eax),%eax
  8022ba:	0f b6 12             	movzbl (%edx),%edx
  8022bd:	29 d0                	sub    %edx,%eax
  8022bf:	eb 05                	jmp    8022c6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8022c1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8022c6:	5b                   	pop    %ebx
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    

008022c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022d3:	eb 07                	jmp    8022dc <strchr+0x13>
		if (*s == c)
  8022d5:	38 ca                	cmp    %cl,%dl
  8022d7:	74 0f                	je     8022e8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8022d9:	83 c0 01             	add    $0x1,%eax
  8022dc:	0f b6 10             	movzbl (%eax),%edx
  8022df:	84 d2                	test   %dl,%dl
  8022e1:	75 f2                	jne    8022d5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8022e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    

008022ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022f4:	eb 03                	jmp    8022f9 <strfind+0xf>
  8022f6:	83 c0 01             	add    $0x1,%eax
  8022f9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8022fc:	38 ca                	cmp    %cl,%dl
  8022fe:	74 04                	je     802304 <strfind+0x1a>
  802300:	84 d2                	test   %dl,%dl
  802302:	75 f2                	jne    8022f6 <strfind+0xc>
			break;
	return (char *) s;
}
  802304:	5d                   	pop    %ebp
  802305:	c3                   	ret    

00802306 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802306:	55                   	push   %ebp
  802307:	89 e5                	mov    %esp,%ebp
  802309:	57                   	push   %edi
  80230a:	56                   	push   %esi
  80230b:	53                   	push   %ebx
  80230c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80230f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802312:	85 c9                	test   %ecx,%ecx
  802314:	74 36                	je     80234c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802316:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80231c:	75 28                	jne    802346 <memset+0x40>
  80231e:	f6 c1 03             	test   $0x3,%cl
  802321:	75 23                	jne    802346 <memset+0x40>
		c &= 0xFF;
  802323:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802327:	89 d3                	mov    %edx,%ebx
  802329:	c1 e3 08             	shl    $0x8,%ebx
  80232c:	89 d6                	mov    %edx,%esi
  80232e:	c1 e6 18             	shl    $0x18,%esi
  802331:	89 d0                	mov    %edx,%eax
  802333:	c1 e0 10             	shl    $0x10,%eax
  802336:	09 f0                	or     %esi,%eax
  802338:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80233a:	89 d8                	mov    %ebx,%eax
  80233c:	09 d0                	or     %edx,%eax
  80233e:	c1 e9 02             	shr    $0x2,%ecx
  802341:	fc                   	cld    
  802342:	f3 ab                	rep stos %eax,%es:(%edi)
  802344:	eb 06                	jmp    80234c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802346:	8b 45 0c             	mov    0xc(%ebp),%eax
  802349:	fc                   	cld    
  80234a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80234c:	89 f8                	mov    %edi,%eax
  80234e:	5b                   	pop    %ebx
  80234f:	5e                   	pop    %esi
  802350:	5f                   	pop    %edi
  802351:	5d                   	pop    %ebp
  802352:	c3                   	ret    

00802353 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802353:	55                   	push   %ebp
  802354:	89 e5                	mov    %esp,%ebp
  802356:	57                   	push   %edi
  802357:	56                   	push   %esi
  802358:	8b 45 08             	mov    0x8(%ebp),%eax
  80235b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80235e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802361:	39 c6                	cmp    %eax,%esi
  802363:	73 35                	jae    80239a <memmove+0x47>
  802365:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802368:	39 d0                	cmp    %edx,%eax
  80236a:	73 2e                	jae    80239a <memmove+0x47>
		s += n;
		d += n;
  80236c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80236f:	89 d6                	mov    %edx,%esi
  802371:	09 fe                	or     %edi,%esi
  802373:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802379:	75 13                	jne    80238e <memmove+0x3b>
  80237b:	f6 c1 03             	test   $0x3,%cl
  80237e:	75 0e                	jne    80238e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  802380:	83 ef 04             	sub    $0x4,%edi
  802383:	8d 72 fc             	lea    -0x4(%edx),%esi
  802386:	c1 e9 02             	shr    $0x2,%ecx
  802389:	fd                   	std    
  80238a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80238c:	eb 09                	jmp    802397 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80238e:	83 ef 01             	sub    $0x1,%edi
  802391:	8d 72 ff             	lea    -0x1(%edx),%esi
  802394:	fd                   	std    
  802395:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802397:	fc                   	cld    
  802398:	eb 1d                	jmp    8023b7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80239a:	89 f2                	mov    %esi,%edx
  80239c:	09 c2                	or     %eax,%edx
  80239e:	f6 c2 03             	test   $0x3,%dl
  8023a1:	75 0f                	jne    8023b2 <memmove+0x5f>
  8023a3:	f6 c1 03             	test   $0x3,%cl
  8023a6:	75 0a                	jne    8023b2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8023a8:	c1 e9 02             	shr    $0x2,%ecx
  8023ab:	89 c7                	mov    %eax,%edi
  8023ad:	fc                   	cld    
  8023ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8023b0:	eb 05                	jmp    8023b7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8023b2:	89 c7                	mov    %eax,%edi
  8023b4:	fc                   	cld    
  8023b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8023b7:	5e                   	pop    %esi
  8023b8:	5f                   	pop    %edi
  8023b9:	5d                   	pop    %ebp
  8023ba:	c3                   	ret    

008023bb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8023bb:	55                   	push   %ebp
  8023bc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8023be:	ff 75 10             	pushl  0x10(%ebp)
  8023c1:	ff 75 0c             	pushl  0xc(%ebp)
  8023c4:	ff 75 08             	pushl  0x8(%ebp)
  8023c7:	e8 87 ff ff ff       	call   802353 <memmove>
}
  8023cc:	c9                   	leave  
  8023cd:	c3                   	ret    

008023ce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8023ce:	55                   	push   %ebp
  8023cf:	89 e5                	mov    %esp,%ebp
  8023d1:	56                   	push   %esi
  8023d2:	53                   	push   %ebx
  8023d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023d9:	89 c6                	mov    %eax,%esi
  8023db:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023de:	eb 1a                	jmp    8023fa <memcmp+0x2c>
		if (*s1 != *s2)
  8023e0:	0f b6 08             	movzbl (%eax),%ecx
  8023e3:	0f b6 1a             	movzbl (%edx),%ebx
  8023e6:	38 d9                	cmp    %bl,%cl
  8023e8:	74 0a                	je     8023f4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8023ea:	0f b6 c1             	movzbl %cl,%eax
  8023ed:	0f b6 db             	movzbl %bl,%ebx
  8023f0:	29 d8                	sub    %ebx,%eax
  8023f2:	eb 0f                	jmp    802403 <memcmp+0x35>
		s1++, s2++;
  8023f4:	83 c0 01             	add    $0x1,%eax
  8023f7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023fa:	39 f0                	cmp    %esi,%eax
  8023fc:	75 e2                	jne    8023e0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8023fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802403:	5b                   	pop    %ebx
  802404:	5e                   	pop    %esi
  802405:	5d                   	pop    %ebp
  802406:	c3                   	ret    

00802407 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802407:	55                   	push   %ebp
  802408:	89 e5                	mov    %esp,%ebp
  80240a:	53                   	push   %ebx
  80240b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80240e:	89 c1                	mov    %eax,%ecx
  802410:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802413:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802417:	eb 0a                	jmp    802423 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  802419:	0f b6 10             	movzbl (%eax),%edx
  80241c:	39 da                	cmp    %ebx,%edx
  80241e:	74 07                	je     802427 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802420:	83 c0 01             	add    $0x1,%eax
  802423:	39 c8                	cmp    %ecx,%eax
  802425:	72 f2                	jb     802419 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802427:	5b                   	pop    %ebx
  802428:	5d                   	pop    %ebp
  802429:	c3                   	ret    

0080242a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80242a:	55                   	push   %ebp
  80242b:	89 e5                	mov    %esp,%ebp
  80242d:	57                   	push   %edi
  80242e:	56                   	push   %esi
  80242f:	53                   	push   %ebx
  802430:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802433:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802436:	eb 03                	jmp    80243b <strtol+0x11>
		s++;
  802438:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80243b:	0f b6 01             	movzbl (%ecx),%eax
  80243e:	3c 20                	cmp    $0x20,%al
  802440:	74 f6                	je     802438 <strtol+0xe>
  802442:	3c 09                	cmp    $0x9,%al
  802444:	74 f2                	je     802438 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802446:	3c 2b                	cmp    $0x2b,%al
  802448:	75 0a                	jne    802454 <strtol+0x2a>
		s++;
  80244a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80244d:	bf 00 00 00 00       	mov    $0x0,%edi
  802452:	eb 11                	jmp    802465 <strtol+0x3b>
  802454:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802459:	3c 2d                	cmp    $0x2d,%al
  80245b:	75 08                	jne    802465 <strtol+0x3b>
		s++, neg = 1;
  80245d:	83 c1 01             	add    $0x1,%ecx
  802460:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802465:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80246b:	75 15                	jne    802482 <strtol+0x58>
  80246d:	80 39 30             	cmpb   $0x30,(%ecx)
  802470:	75 10                	jne    802482 <strtol+0x58>
  802472:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  802476:	75 7c                	jne    8024f4 <strtol+0xca>
		s += 2, base = 16;
  802478:	83 c1 02             	add    $0x2,%ecx
  80247b:	bb 10 00 00 00       	mov    $0x10,%ebx
  802480:	eb 16                	jmp    802498 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  802482:	85 db                	test   %ebx,%ebx
  802484:	75 12                	jne    802498 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802486:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80248b:	80 39 30             	cmpb   $0x30,(%ecx)
  80248e:	75 08                	jne    802498 <strtol+0x6e>
		s++, base = 8;
  802490:	83 c1 01             	add    $0x1,%ecx
  802493:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  802498:	b8 00 00 00 00       	mov    $0x0,%eax
  80249d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8024a0:	0f b6 11             	movzbl (%ecx),%edx
  8024a3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8024a6:	89 f3                	mov    %esi,%ebx
  8024a8:	80 fb 09             	cmp    $0x9,%bl
  8024ab:	77 08                	ja     8024b5 <strtol+0x8b>
			dig = *s - '0';
  8024ad:	0f be d2             	movsbl %dl,%edx
  8024b0:	83 ea 30             	sub    $0x30,%edx
  8024b3:	eb 22                	jmp    8024d7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8024b5:	8d 72 9f             	lea    -0x61(%edx),%esi
  8024b8:	89 f3                	mov    %esi,%ebx
  8024ba:	80 fb 19             	cmp    $0x19,%bl
  8024bd:	77 08                	ja     8024c7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8024bf:	0f be d2             	movsbl %dl,%edx
  8024c2:	83 ea 57             	sub    $0x57,%edx
  8024c5:	eb 10                	jmp    8024d7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8024c7:	8d 72 bf             	lea    -0x41(%edx),%esi
  8024ca:	89 f3                	mov    %esi,%ebx
  8024cc:	80 fb 19             	cmp    $0x19,%bl
  8024cf:	77 16                	ja     8024e7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8024d1:	0f be d2             	movsbl %dl,%edx
  8024d4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8024d7:	3b 55 10             	cmp    0x10(%ebp),%edx
  8024da:	7d 0b                	jge    8024e7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8024dc:	83 c1 01             	add    $0x1,%ecx
  8024df:	0f af 45 10          	imul   0x10(%ebp),%eax
  8024e3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8024e5:	eb b9                	jmp    8024a0 <strtol+0x76>

	if (endptr)
  8024e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8024eb:	74 0d                	je     8024fa <strtol+0xd0>
		*endptr = (char *) s;
  8024ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024f0:	89 0e                	mov    %ecx,(%esi)
  8024f2:	eb 06                	jmp    8024fa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8024f4:	85 db                	test   %ebx,%ebx
  8024f6:	74 98                	je     802490 <strtol+0x66>
  8024f8:	eb 9e                	jmp    802498 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8024fa:	89 c2                	mov    %eax,%edx
  8024fc:	f7 da                	neg    %edx
  8024fe:	85 ff                	test   %edi,%edi
  802500:	0f 45 c2             	cmovne %edx,%eax
}
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    

00802508 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802508:	55                   	push   %ebp
  802509:	89 e5                	mov    %esp,%ebp
  80250b:	57                   	push   %edi
  80250c:	56                   	push   %esi
  80250d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80250e:	b8 00 00 00 00       	mov    $0x0,%eax
  802513:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802516:	8b 55 08             	mov    0x8(%ebp),%edx
  802519:	89 c3                	mov    %eax,%ebx
  80251b:	89 c7                	mov    %eax,%edi
  80251d:	89 c6                	mov    %eax,%esi
  80251f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802521:	5b                   	pop    %ebx
  802522:	5e                   	pop    %esi
  802523:	5f                   	pop    %edi
  802524:	5d                   	pop    %ebp
  802525:	c3                   	ret    

00802526 <sys_cgetc>:

int
sys_cgetc(void)
{
  802526:	55                   	push   %ebp
  802527:	89 e5                	mov    %esp,%ebp
  802529:	57                   	push   %edi
  80252a:	56                   	push   %esi
  80252b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80252c:	ba 00 00 00 00       	mov    $0x0,%edx
  802531:	b8 01 00 00 00       	mov    $0x1,%eax
  802536:	89 d1                	mov    %edx,%ecx
  802538:	89 d3                	mov    %edx,%ebx
  80253a:	89 d7                	mov    %edx,%edi
  80253c:	89 d6                	mov    %edx,%esi
  80253e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802540:	5b                   	pop    %ebx
  802541:	5e                   	pop    %esi
  802542:	5f                   	pop    %edi
  802543:	5d                   	pop    %ebp
  802544:	c3                   	ret    

00802545 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802545:	55                   	push   %ebp
  802546:	89 e5                	mov    %esp,%ebp
  802548:	57                   	push   %edi
  802549:	56                   	push   %esi
  80254a:	53                   	push   %ebx
  80254b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80254e:	b9 00 00 00 00       	mov    $0x0,%ecx
  802553:	b8 03 00 00 00       	mov    $0x3,%eax
  802558:	8b 55 08             	mov    0x8(%ebp),%edx
  80255b:	89 cb                	mov    %ecx,%ebx
  80255d:	89 cf                	mov    %ecx,%edi
  80255f:	89 ce                	mov    %ecx,%esi
  802561:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802563:	85 c0                	test   %eax,%eax
  802565:	7e 17                	jle    80257e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802567:	83 ec 0c             	sub    $0xc,%esp
  80256a:	50                   	push   %eax
  80256b:	6a 03                	push   $0x3
  80256d:	68 1f 42 80 00       	push   $0x80421f
  802572:	6a 23                	push   $0x23
  802574:	68 3c 42 80 00       	push   $0x80423c
  802579:	e8 e5 f5 ff ff       	call   801b63 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80257e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802581:	5b                   	pop    %ebx
  802582:	5e                   	pop    %esi
  802583:	5f                   	pop    %edi
  802584:	5d                   	pop    %ebp
  802585:	c3                   	ret    

00802586 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802586:	55                   	push   %ebp
  802587:	89 e5                	mov    %esp,%ebp
  802589:	57                   	push   %edi
  80258a:	56                   	push   %esi
  80258b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80258c:	ba 00 00 00 00       	mov    $0x0,%edx
  802591:	b8 02 00 00 00       	mov    $0x2,%eax
  802596:	89 d1                	mov    %edx,%ecx
  802598:	89 d3                	mov    %edx,%ebx
  80259a:	89 d7                	mov    %edx,%edi
  80259c:	89 d6                	mov    %edx,%esi
  80259e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8025a0:	5b                   	pop    %ebx
  8025a1:	5e                   	pop    %esi
  8025a2:	5f                   	pop    %edi
  8025a3:	5d                   	pop    %ebp
  8025a4:	c3                   	ret    

008025a5 <sys_yield>:

void
sys_yield(void)
{
  8025a5:	55                   	push   %ebp
  8025a6:	89 e5                	mov    %esp,%ebp
  8025a8:	57                   	push   %edi
  8025a9:	56                   	push   %esi
  8025aa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8025b0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8025b5:	89 d1                	mov    %edx,%ecx
  8025b7:	89 d3                	mov    %edx,%ebx
  8025b9:	89 d7                	mov    %edx,%edi
  8025bb:	89 d6                	mov    %edx,%esi
  8025bd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8025bf:	5b                   	pop    %ebx
  8025c0:	5e                   	pop    %esi
  8025c1:	5f                   	pop    %edi
  8025c2:	5d                   	pop    %ebp
  8025c3:	c3                   	ret    

008025c4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8025c4:	55                   	push   %ebp
  8025c5:	89 e5                	mov    %esp,%ebp
  8025c7:	57                   	push   %edi
  8025c8:	56                   	push   %esi
  8025c9:	53                   	push   %ebx
  8025ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025cd:	be 00 00 00 00       	mov    $0x0,%esi
  8025d2:	b8 04 00 00 00       	mov    $0x4,%eax
  8025d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025da:	8b 55 08             	mov    0x8(%ebp),%edx
  8025dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025e0:	89 f7                	mov    %esi,%edi
  8025e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025e4:	85 c0                	test   %eax,%eax
  8025e6:	7e 17                	jle    8025ff <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025e8:	83 ec 0c             	sub    $0xc,%esp
  8025eb:	50                   	push   %eax
  8025ec:	6a 04                	push   $0x4
  8025ee:	68 1f 42 80 00       	push   $0x80421f
  8025f3:	6a 23                	push   $0x23
  8025f5:	68 3c 42 80 00       	push   $0x80423c
  8025fa:	e8 64 f5 ff ff       	call   801b63 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8025ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802602:	5b                   	pop    %ebx
  802603:	5e                   	pop    %esi
  802604:	5f                   	pop    %edi
  802605:	5d                   	pop    %ebp
  802606:	c3                   	ret    

00802607 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802607:	55                   	push   %ebp
  802608:	89 e5                	mov    %esp,%ebp
  80260a:	57                   	push   %edi
  80260b:	56                   	push   %esi
  80260c:	53                   	push   %ebx
  80260d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802610:	b8 05 00 00 00       	mov    $0x5,%eax
  802615:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802618:	8b 55 08             	mov    0x8(%ebp),%edx
  80261b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80261e:	8b 7d 14             	mov    0x14(%ebp),%edi
  802621:	8b 75 18             	mov    0x18(%ebp),%esi
  802624:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802626:	85 c0                	test   %eax,%eax
  802628:	7e 17                	jle    802641 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80262a:	83 ec 0c             	sub    $0xc,%esp
  80262d:	50                   	push   %eax
  80262e:	6a 05                	push   $0x5
  802630:	68 1f 42 80 00       	push   $0x80421f
  802635:	6a 23                	push   $0x23
  802637:	68 3c 42 80 00       	push   $0x80423c
  80263c:	e8 22 f5 ff ff       	call   801b63 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802641:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802644:	5b                   	pop    %ebx
  802645:	5e                   	pop    %esi
  802646:	5f                   	pop    %edi
  802647:	5d                   	pop    %ebp
  802648:	c3                   	ret    

00802649 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802649:	55                   	push   %ebp
  80264a:	89 e5                	mov    %esp,%ebp
  80264c:	57                   	push   %edi
  80264d:	56                   	push   %esi
  80264e:	53                   	push   %ebx
  80264f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802652:	bb 00 00 00 00       	mov    $0x0,%ebx
  802657:	b8 06 00 00 00       	mov    $0x6,%eax
  80265c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80265f:	8b 55 08             	mov    0x8(%ebp),%edx
  802662:	89 df                	mov    %ebx,%edi
  802664:	89 de                	mov    %ebx,%esi
  802666:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802668:	85 c0                	test   %eax,%eax
  80266a:	7e 17                	jle    802683 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80266c:	83 ec 0c             	sub    $0xc,%esp
  80266f:	50                   	push   %eax
  802670:	6a 06                	push   $0x6
  802672:	68 1f 42 80 00       	push   $0x80421f
  802677:	6a 23                	push   $0x23
  802679:	68 3c 42 80 00       	push   $0x80423c
  80267e:	e8 e0 f4 ff ff       	call   801b63 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802683:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802686:	5b                   	pop    %ebx
  802687:	5e                   	pop    %esi
  802688:	5f                   	pop    %edi
  802689:	5d                   	pop    %ebp
  80268a:	c3                   	ret    

0080268b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80268b:	55                   	push   %ebp
  80268c:	89 e5                	mov    %esp,%ebp
  80268e:	57                   	push   %edi
  80268f:	56                   	push   %esi
  802690:	53                   	push   %ebx
  802691:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802694:	bb 00 00 00 00       	mov    $0x0,%ebx
  802699:	b8 08 00 00 00       	mov    $0x8,%eax
  80269e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8026a4:	89 df                	mov    %ebx,%edi
  8026a6:	89 de                	mov    %ebx,%esi
  8026a8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026aa:	85 c0                	test   %eax,%eax
  8026ac:	7e 17                	jle    8026c5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026ae:	83 ec 0c             	sub    $0xc,%esp
  8026b1:	50                   	push   %eax
  8026b2:	6a 08                	push   $0x8
  8026b4:	68 1f 42 80 00       	push   $0x80421f
  8026b9:	6a 23                	push   $0x23
  8026bb:	68 3c 42 80 00       	push   $0x80423c
  8026c0:	e8 9e f4 ff ff       	call   801b63 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8026c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026c8:	5b                   	pop    %ebx
  8026c9:	5e                   	pop    %esi
  8026ca:	5f                   	pop    %edi
  8026cb:	5d                   	pop    %ebp
  8026cc:	c3                   	ret    

008026cd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8026cd:	55                   	push   %ebp
  8026ce:	89 e5                	mov    %esp,%ebp
  8026d0:	57                   	push   %edi
  8026d1:	56                   	push   %esi
  8026d2:	53                   	push   %ebx
  8026d3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026db:	b8 09 00 00 00       	mov    $0x9,%eax
  8026e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8026e6:	89 df                	mov    %ebx,%edi
  8026e8:	89 de                	mov    %ebx,%esi
  8026ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026ec:	85 c0                	test   %eax,%eax
  8026ee:	7e 17                	jle    802707 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026f0:	83 ec 0c             	sub    $0xc,%esp
  8026f3:	50                   	push   %eax
  8026f4:	6a 09                	push   $0x9
  8026f6:	68 1f 42 80 00       	push   $0x80421f
  8026fb:	6a 23                	push   $0x23
  8026fd:	68 3c 42 80 00       	push   $0x80423c
  802702:	e8 5c f4 ff ff       	call   801b63 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802707:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80270a:	5b                   	pop    %ebx
  80270b:	5e                   	pop    %esi
  80270c:	5f                   	pop    %edi
  80270d:	5d                   	pop    %ebp
  80270e:	c3                   	ret    

0080270f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80270f:	55                   	push   %ebp
  802710:	89 e5                	mov    %esp,%ebp
  802712:	57                   	push   %edi
  802713:	56                   	push   %esi
  802714:	53                   	push   %ebx
  802715:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802718:	bb 00 00 00 00       	mov    $0x0,%ebx
  80271d:	b8 0a 00 00 00       	mov    $0xa,%eax
  802722:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802725:	8b 55 08             	mov    0x8(%ebp),%edx
  802728:	89 df                	mov    %ebx,%edi
  80272a:	89 de                	mov    %ebx,%esi
  80272c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80272e:	85 c0                	test   %eax,%eax
  802730:	7e 17                	jle    802749 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802732:	83 ec 0c             	sub    $0xc,%esp
  802735:	50                   	push   %eax
  802736:	6a 0a                	push   $0xa
  802738:	68 1f 42 80 00       	push   $0x80421f
  80273d:	6a 23                	push   $0x23
  80273f:	68 3c 42 80 00       	push   $0x80423c
  802744:	e8 1a f4 ff ff       	call   801b63 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802749:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80274c:	5b                   	pop    %ebx
  80274d:	5e                   	pop    %esi
  80274e:	5f                   	pop    %edi
  80274f:	5d                   	pop    %ebp
  802750:	c3                   	ret    

00802751 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802751:	55                   	push   %ebp
  802752:	89 e5                	mov    %esp,%ebp
  802754:	57                   	push   %edi
  802755:	56                   	push   %esi
  802756:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802757:	be 00 00 00 00       	mov    $0x0,%esi
  80275c:	b8 0c 00 00 00       	mov    $0xc,%eax
  802761:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802764:	8b 55 08             	mov    0x8(%ebp),%edx
  802767:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80276a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80276d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80276f:	5b                   	pop    %ebx
  802770:	5e                   	pop    %esi
  802771:	5f                   	pop    %edi
  802772:	5d                   	pop    %ebp
  802773:	c3                   	ret    

00802774 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802774:	55                   	push   %ebp
  802775:	89 e5                	mov    %esp,%ebp
  802777:	57                   	push   %edi
  802778:	56                   	push   %esi
  802779:	53                   	push   %ebx
  80277a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80277d:	b9 00 00 00 00       	mov    $0x0,%ecx
  802782:	b8 0d 00 00 00       	mov    $0xd,%eax
  802787:	8b 55 08             	mov    0x8(%ebp),%edx
  80278a:	89 cb                	mov    %ecx,%ebx
  80278c:	89 cf                	mov    %ecx,%edi
  80278e:	89 ce                	mov    %ecx,%esi
  802790:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802792:	85 c0                	test   %eax,%eax
  802794:	7e 17                	jle    8027ad <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802796:	83 ec 0c             	sub    $0xc,%esp
  802799:	50                   	push   %eax
  80279a:	6a 0d                	push   $0xd
  80279c:	68 1f 42 80 00       	push   $0x80421f
  8027a1:	6a 23                	push   $0x23
  8027a3:	68 3c 42 80 00       	push   $0x80423c
  8027a8:	e8 b6 f3 ff ff       	call   801b63 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8027ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027b0:	5b                   	pop    %ebx
  8027b1:	5e                   	pop    %esi
  8027b2:	5f                   	pop    %edi
  8027b3:	5d                   	pop    %ebp
  8027b4:	c3                   	ret    

008027b5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
	   void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8027b5:	55                   	push   %ebp
  8027b6:	89 e5                	mov    %esp,%ebp
  8027b8:	83 ec 08             	sub    $0x8,%esp
	   int r;
	   if (_pgfault_handler == 0) {
  8027bb:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  8027c2:	75 2a                	jne    8027ee <set_pgfault_handler+0x39>
			 // First time through!
			 // LAB 4: Your code here.
			 int a = sys_page_alloc (0, (void *) (UXSTACKTOP -PGSIZE), PTE_U | PTE_W);
  8027c4:	83 ec 04             	sub    $0x4,%esp
  8027c7:	6a 06                	push   $0x6
  8027c9:	68 00 f0 bf ee       	push   $0xeebff000
  8027ce:	6a 00                	push   $0x0
  8027d0:	e8 ef fd ff ff       	call   8025c4 <sys_page_alloc>
			 if (a < 0)
  8027d5:	83 c4 10             	add    $0x10,%esp
  8027d8:	85 c0                	test   %eax,%eax
  8027da:	79 12                	jns    8027ee <set_pgfault_handler+0x39>
				    panic ("sys_page_alloc Failed. %e", a);
  8027dc:	50                   	push   %eax
  8027dd:	68 4a 42 80 00       	push   $0x80424a
  8027e2:	6a 21                	push   $0x21
  8027e4:	68 64 42 80 00       	push   $0x804264
  8027e9:	e8 75 f3 ff ff       	call   801b63 <_panic>
			 //panic("set_pgfault_handler not implemented");
	   }

	   sys_env_set_pgfault_upcall (sys_getenvid(),  _pgfault_upcall);
  8027ee:	e8 93 fd ff ff       	call   802586 <sys_getenvid>
  8027f3:	83 ec 08             	sub    $0x8,%esp
  8027f6:	68 0e 28 80 00       	push   $0x80280e
  8027fb:	50                   	push   %eax
  8027fc:	e8 0e ff ff ff       	call   80270f <sys_env_set_pgfault_upcall>

	   // Save handler pointer for assembly to call.
	   _pgfault_handler = handler;
  802801:	8b 45 08             	mov    0x8(%ebp),%eax
  802804:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  802809:	83 c4 10             	add    $0x10,%esp
  80280c:	c9                   	leave  
  80280d:	c3                   	ret    

0080280e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
// Call the C page fault handler.
pushl %esp			// function argument: pointer to UTF
  80280e:	54                   	push   %esp
movl _pgfault_handler, %eax
  80280f:	a1 10 a0 80 00       	mov    0x80a010,%eax
call *%eax
  802814:	ff d0                	call   *%eax
addl $4, %esp			// pop function argument
  802816:	83 c4 04             	add    $0x4,%esp
// registers are available for intermediate calculations.  You
// may find that you have to rearrange your code in non-obvious
// ways as registers become unavailable as scratch space.
//
// LAB 4: Your code here.
   movl 40(%esp), %eax	//grab trap-time eip
  802819:	8b 44 24 28          	mov    0x28(%esp),%eax
   movl 48(%esp), %ebx	// grab trap-time esp
  80281d:	8b 5c 24 30          	mov    0x30(%esp),%ebx
   subl $4, %ebx		//Reserve slot for eip to be pushed on to the stack of either the environement that has faulted, if call to this handler is not recursive, or this handler itself, if call is recursive.
  802821:	83 eb 04             	sub    $0x4,%ebx
   movl %ebx, 48(%esp)	//adjust trap-time esp so ret will pop the eip
  802824:	89 5c 24 30          	mov    %ebx,0x30(%esp)
   mov %eax, (%ebx)	//push eip on to the trap time stack, in case of recursive call, or on the stack of the faulting environment in case of non-recursive call.
  802828:	89 03                	mov    %eax,(%ebx)
   addl $8, %esp		//skip the fault_va and error code since we have no use of them
  80282a:	83 c4 08             	add    $0x8,%esp

// Restore the trap-time registers.  After you do this, you
// can no longer modify any general-purpose registers.
// LAB 4: Your code here.
popal
  80282d:	61                   	popa   

// Restore eflags from the stack.  After you do this, you can
// no longer use arithmetic operations or anything else that
// modifies eflags.
// LAB 4: Your code here.
addl $4, %esp		//We skip the trap time eip since it is no use to us.
  80282e:	83 c4 04             	add    $0x4,%esp
popfl
  802831:	9d                   	popf   

// Switch back to the adjusted trap-time stack.
// LAB 4: Your code here.
popl %esp		//restore the value of trap-time esp i.e. esp of either the faulting envornment or the handler itself (if the call is recursive)
  802832:	5c                   	pop    %esp

// Return to re-execute the instruction that faulted.
// LAB 4: Your code here.
ret			//return to either the faulting environment or the handler in case of recursive call.
  802833:	c3                   	ret    

00802834 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802834:	55                   	push   %ebp
  802835:	89 e5                	mov    %esp,%ebp
  802837:	56                   	push   %esi
  802838:	53                   	push   %ebx
  802839:	8b 75 08             	mov    0x8(%ebp),%esi
  80283c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80283f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  802842:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  802844:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802849:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  80284c:	83 ec 0c             	sub    $0xc,%esp
  80284f:	50                   	push   %eax
  802850:	e8 1f ff ff ff       	call   802774 <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  802855:	83 c4 10             	add    $0x10,%esp
  802858:	85 c0                	test   %eax,%eax
  80285a:	78 0e                	js     80286a <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  80285c:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  802862:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  802865:	8b 52 78             	mov    0x78(%edx),%edx
  802868:	eb 0a                	jmp    802874 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  80286a:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  80286f:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  802874:	85 f6                	test   %esi,%esi
  802876:	74 02                	je     80287a <ipc_recv+0x46>
			 *from_env_store = s_envid;
  802878:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  80287a:	85 db                	test   %ebx,%ebx
  80287c:	74 02                	je     802880 <ipc_recv+0x4c>
			 *perm_store = s_perm;
  80287e:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  802880:	85 c0                	test   %eax,%eax
  802882:	78 08                	js     80288c <ipc_recv+0x58>
  802884:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802889:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  80288c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80288f:	5b                   	pop    %ebx
  802890:	5e                   	pop    %esi
  802891:	5d                   	pop    %ebp
  802892:	c3                   	ret    

00802893 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802893:	55                   	push   %ebp
  802894:	89 e5                	mov    %esp,%ebp
  802896:	57                   	push   %edi
  802897:	56                   	push   %esi
  802898:	53                   	push   %ebx
  802899:	83 ec 0c             	sub    $0xc,%esp
  80289c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80289f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8028a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  8028a5:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  8028a7:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8028ac:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  8028af:	ff 75 14             	pushl  0x14(%ebp)
  8028b2:	53                   	push   %ebx
  8028b3:	56                   	push   %esi
  8028b4:	57                   	push   %edi
  8028b5:	e8 97 fe ff ff       	call   802751 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  8028ba:	83 c4 10             	add    $0x10,%esp
  8028bd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028c0:	75 07                	jne    8028c9 <ipc_send+0x36>
				    sys_yield();
  8028c2:	e8 de fc ff ff       	call   8025a5 <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  8028c7:	eb e6                	jmp    8028af <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  8028c9:	85 c0                	test   %eax,%eax
  8028cb:	74 12                	je     8028df <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  8028cd:	50                   	push   %eax
  8028ce:	68 72 42 80 00       	push   $0x804272
  8028d3:	6a 4b                	push   $0x4b
  8028d5:	68 86 42 80 00       	push   $0x804286
  8028da:	e8 84 f2 ff ff       	call   801b63 <_panic>
			 }
	   }
}
  8028df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028e2:	5b                   	pop    %ebx
  8028e3:	5e                   	pop    %esi
  8028e4:	5f                   	pop    %edi
  8028e5:	5d                   	pop    %ebp
  8028e6:	c3                   	ret    

008028e7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  8028e7:	55                   	push   %ebp
  8028e8:	89 e5                	mov    %esp,%ebp
  8028ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  8028ed:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  8028f2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8028f5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8028fb:	8b 52 50             	mov    0x50(%edx),%edx
  8028fe:	39 ca                	cmp    %ecx,%edx
  802900:	75 0d                	jne    80290f <ipc_find_env+0x28>
				    return envs[i].env_id;
  802902:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802905:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80290a:	8b 40 48             	mov    0x48(%eax),%eax
  80290d:	eb 0f                	jmp    80291e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  80290f:	83 c0 01             	add    $0x1,%eax
  802912:	3d 00 04 00 00       	cmp    $0x400,%eax
  802917:	75 d9                	jne    8028f2 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  802919:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80291e:	5d                   	pop    %ebp
  80291f:	c3                   	ret    

00802920 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802920:	55                   	push   %ebp
  802921:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802923:	8b 45 08             	mov    0x8(%ebp),%eax
  802926:	05 00 00 00 30       	add    $0x30000000,%eax
  80292b:	c1 e8 0c             	shr    $0xc,%eax
}
  80292e:	5d                   	pop    %ebp
  80292f:	c3                   	ret    

00802930 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802930:	55                   	push   %ebp
  802931:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802933:	8b 45 08             	mov    0x8(%ebp),%eax
  802936:	05 00 00 00 30       	add    $0x30000000,%eax
  80293b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802940:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802945:	5d                   	pop    %ebp
  802946:	c3                   	ret    

00802947 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802947:	55                   	push   %ebp
  802948:	89 e5                	mov    %esp,%ebp
  80294a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80294d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802952:	89 c2                	mov    %eax,%edx
  802954:	c1 ea 16             	shr    $0x16,%edx
  802957:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80295e:	f6 c2 01             	test   $0x1,%dl
  802961:	74 11                	je     802974 <fd_alloc+0x2d>
  802963:	89 c2                	mov    %eax,%edx
  802965:	c1 ea 0c             	shr    $0xc,%edx
  802968:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80296f:	f6 c2 01             	test   $0x1,%dl
  802972:	75 09                	jne    80297d <fd_alloc+0x36>
			*fd_store = fd;
  802974:	89 01                	mov    %eax,(%ecx)
			return 0;
  802976:	b8 00 00 00 00       	mov    $0x0,%eax
  80297b:	eb 17                	jmp    802994 <fd_alloc+0x4d>
  80297d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802982:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802987:	75 c9                	jne    802952 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802989:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80298f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802994:	5d                   	pop    %ebp
  802995:	c3                   	ret    

00802996 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802996:	55                   	push   %ebp
  802997:	89 e5                	mov    %esp,%ebp
  802999:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80299c:	83 f8 1f             	cmp    $0x1f,%eax
  80299f:	77 36                	ja     8029d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8029a1:	c1 e0 0c             	shl    $0xc,%eax
  8029a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8029a9:	89 c2                	mov    %eax,%edx
  8029ab:	c1 ea 16             	shr    $0x16,%edx
  8029ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8029b5:	f6 c2 01             	test   $0x1,%dl
  8029b8:	74 24                	je     8029de <fd_lookup+0x48>
  8029ba:	89 c2                	mov    %eax,%edx
  8029bc:	c1 ea 0c             	shr    $0xc,%edx
  8029bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8029c6:	f6 c2 01             	test   $0x1,%dl
  8029c9:	74 1a                	je     8029e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8029cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8029ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8029d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8029d5:	eb 13                	jmp    8029ea <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8029d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029dc:	eb 0c                	jmp    8029ea <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8029de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029e3:	eb 05                	jmp    8029ea <fd_lookup+0x54>
  8029e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8029ea:	5d                   	pop    %ebp
  8029eb:	c3                   	ret    

008029ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8029ec:	55                   	push   %ebp
  8029ed:	89 e5                	mov    %esp,%ebp
  8029ef:	83 ec 08             	sub    $0x8,%esp
  8029f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029f5:	ba 10 43 80 00       	mov    $0x804310,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8029fa:	eb 13                	jmp    802a0f <dev_lookup+0x23>
  8029fc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8029ff:	39 08                	cmp    %ecx,(%eax)
  802a01:	75 0c                	jne    802a0f <dev_lookup+0x23>
			*dev = devtab[i];
  802a03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a06:	89 01                	mov    %eax,(%ecx)
			return 0;
  802a08:	b8 00 00 00 00       	mov    $0x0,%eax
  802a0d:	eb 2e                	jmp    802a3d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802a0f:	8b 02                	mov    (%edx),%eax
  802a11:	85 c0                	test   %eax,%eax
  802a13:	75 e7                	jne    8029fc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802a15:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802a1a:	8b 40 48             	mov    0x48(%eax),%eax
  802a1d:	83 ec 04             	sub    $0x4,%esp
  802a20:	51                   	push   %ecx
  802a21:	50                   	push   %eax
  802a22:	68 90 42 80 00       	push   $0x804290
  802a27:	e8 10 f2 ff ff       	call   801c3c <cprintf>
	*dev = 0;
  802a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a2f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802a35:	83 c4 10             	add    $0x10,%esp
  802a38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802a3d:	c9                   	leave  
  802a3e:	c3                   	ret    

00802a3f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802a3f:	55                   	push   %ebp
  802a40:	89 e5                	mov    %esp,%ebp
  802a42:	56                   	push   %esi
  802a43:	53                   	push   %ebx
  802a44:	83 ec 10             	sub    $0x10,%esp
  802a47:	8b 75 08             	mov    0x8(%ebp),%esi
  802a4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802a4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a50:	50                   	push   %eax
  802a51:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802a57:	c1 e8 0c             	shr    $0xc,%eax
  802a5a:	50                   	push   %eax
  802a5b:	e8 36 ff ff ff       	call   802996 <fd_lookup>
  802a60:	83 c4 08             	add    $0x8,%esp
  802a63:	85 c0                	test   %eax,%eax
  802a65:	78 05                	js     802a6c <fd_close+0x2d>
	    || fd != fd2)
  802a67:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802a6a:	74 0c                	je     802a78 <fd_close+0x39>
		return (must_exist ? r : 0);
  802a6c:	84 db                	test   %bl,%bl
  802a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  802a73:	0f 44 c2             	cmove  %edx,%eax
  802a76:	eb 41                	jmp    802ab9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802a78:	83 ec 08             	sub    $0x8,%esp
  802a7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a7e:	50                   	push   %eax
  802a7f:	ff 36                	pushl  (%esi)
  802a81:	e8 66 ff ff ff       	call   8029ec <dev_lookup>
  802a86:	89 c3                	mov    %eax,%ebx
  802a88:	83 c4 10             	add    $0x10,%esp
  802a8b:	85 c0                	test   %eax,%eax
  802a8d:	78 1a                	js     802aa9 <fd_close+0x6a>
		if (dev->dev_close)
  802a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a92:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802a95:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802a9a:	85 c0                	test   %eax,%eax
  802a9c:	74 0b                	je     802aa9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802a9e:	83 ec 0c             	sub    $0xc,%esp
  802aa1:	56                   	push   %esi
  802aa2:	ff d0                	call   *%eax
  802aa4:	89 c3                	mov    %eax,%ebx
  802aa6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802aa9:	83 ec 08             	sub    $0x8,%esp
  802aac:	56                   	push   %esi
  802aad:	6a 00                	push   $0x0
  802aaf:	e8 95 fb ff ff       	call   802649 <sys_page_unmap>
	return r;
  802ab4:	83 c4 10             	add    $0x10,%esp
  802ab7:	89 d8                	mov    %ebx,%eax
}
  802ab9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802abc:	5b                   	pop    %ebx
  802abd:	5e                   	pop    %esi
  802abe:	5d                   	pop    %ebp
  802abf:	c3                   	ret    

00802ac0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802ac0:	55                   	push   %ebp
  802ac1:	89 e5                	mov    %esp,%ebp
  802ac3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802ac6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ac9:	50                   	push   %eax
  802aca:	ff 75 08             	pushl  0x8(%ebp)
  802acd:	e8 c4 fe ff ff       	call   802996 <fd_lookup>
  802ad2:	83 c4 08             	add    $0x8,%esp
  802ad5:	85 c0                	test   %eax,%eax
  802ad7:	78 10                	js     802ae9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802ad9:	83 ec 08             	sub    $0x8,%esp
  802adc:	6a 01                	push   $0x1
  802ade:	ff 75 f4             	pushl  -0xc(%ebp)
  802ae1:	e8 59 ff ff ff       	call   802a3f <fd_close>
  802ae6:	83 c4 10             	add    $0x10,%esp
}
  802ae9:	c9                   	leave  
  802aea:	c3                   	ret    

00802aeb <close_all>:

void
close_all(void)
{
  802aeb:	55                   	push   %ebp
  802aec:	89 e5                	mov    %esp,%ebp
  802aee:	53                   	push   %ebx
  802aef:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802af2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802af7:	83 ec 0c             	sub    $0xc,%esp
  802afa:	53                   	push   %ebx
  802afb:	e8 c0 ff ff ff       	call   802ac0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802b00:	83 c3 01             	add    $0x1,%ebx
  802b03:	83 c4 10             	add    $0x10,%esp
  802b06:	83 fb 20             	cmp    $0x20,%ebx
  802b09:	75 ec                	jne    802af7 <close_all+0xc>
		close(i);
}
  802b0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b0e:	c9                   	leave  
  802b0f:	c3                   	ret    

00802b10 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802b10:	55                   	push   %ebp
  802b11:	89 e5                	mov    %esp,%ebp
  802b13:	57                   	push   %edi
  802b14:	56                   	push   %esi
  802b15:	53                   	push   %ebx
  802b16:	83 ec 2c             	sub    $0x2c,%esp
  802b19:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802b1c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802b1f:	50                   	push   %eax
  802b20:	ff 75 08             	pushl  0x8(%ebp)
  802b23:	e8 6e fe ff ff       	call   802996 <fd_lookup>
  802b28:	83 c4 08             	add    $0x8,%esp
  802b2b:	85 c0                	test   %eax,%eax
  802b2d:	0f 88 c1 00 00 00    	js     802bf4 <dup+0xe4>
		return r;
	close(newfdnum);
  802b33:	83 ec 0c             	sub    $0xc,%esp
  802b36:	56                   	push   %esi
  802b37:	e8 84 ff ff ff       	call   802ac0 <close>

	newfd = INDEX2FD(newfdnum);
  802b3c:	89 f3                	mov    %esi,%ebx
  802b3e:	c1 e3 0c             	shl    $0xc,%ebx
  802b41:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802b47:	83 c4 04             	add    $0x4,%esp
  802b4a:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b4d:	e8 de fd ff ff       	call   802930 <fd2data>
  802b52:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802b54:	89 1c 24             	mov    %ebx,(%esp)
  802b57:	e8 d4 fd ff ff       	call   802930 <fd2data>
  802b5c:	83 c4 10             	add    $0x10,%esp
  802b5f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802b62:	89 f8                	mov    %edi,%eax
  802b64:	c1 e8 16             	shr    $0x16,%eax
  802b67:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b6e:	a8 01                	test   $0x1,%al
  802b70:	74 37                	je     802ba9 <dup+0x99>
  802b72:	89 f8                	mov    %edi,%eax
  802b74:	c1 e8 0c             	shr    $0xc,%eax
  802b77:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802b7e:	f6 c2 01             	test   $0x1,%dl
  802b81:	74 26                	je     802ba9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802b83:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b8a:	83 ec 0c             	sub    $0xc,%esp
  802b8d:	25 07 0e 00 00       	and    $0xe07,%eax
  802b92:	50                   	push   %eax
  802b93:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b96:	6a 00                	push   $0x0
  802b98:	57                   	push   %edi
  802b99:	6a 00                	push   $0x0
  802b9b:	e8 67 fa ff ff       	call   802607 <sys_page_map>
  802ba0:	89 c7                	mov    %eax,%edi
  802ba2:	83 c4 20             	add    $0x20,%esp
  802ba5:	85 c0                	test   %eax,%eax
  802ba7:	78 2e                	js     802bd7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802ba9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802bac:	89 d0                	mov    %edx,%eax
  802bae:	c1 e8 0c             	shr    $0xc,%eax
  802bb1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802bb8:	83 ec 0c             	sub    $0xc,%esp
  802bbb:	25 07 0e 00 00       	and    $0xe07,%eax
  802bc0:	50                   	push   %eax
  802bc1:	53                   	push   %ebx
  802bc2:	6a 00                	push   $0x0
  802bc4:	52                   	push   %edx
  802bc5:	6a 00                	push   $0x0
  802bc7:	e8 3b fa ff ff       	call   802607 <sys_page_map>
  802bcc:	89 c7                	mov    %eax,%edi
  802bce:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802bd1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802bd3:	85 ff                	test   %edi,%edi
  802bd5:	79 1d                	jns    802bf4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802bd7:	83 ec 08             	sub    $0x8,%esp
  802bda:	53                   	push   %ebx
  802bdb:	6a 00                	push   $0x0
  802bdd:	e8 67 fa ff ff       	call   802649 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802be2:	83 c4 08             	add    $0x8,%esp
  802be5:	ff 75 d4             	pushl  -0x2c(%ebp)
  802be8:	6a 00                	push   $0x0
  802bea:	e8 5a fa ff ff       	call   802649 <sys_page_unmap>
	return r;
  802bef:	83 c4 10             	add    $0x10,%esp
  802bf2:	89 f8                	mov    %edi,%eax
}
  802bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bf7:	5b                   	pop    %ebx
  802bf8:	5e                   	pop    %esi
  802bf9:	5f                   	pop    %edi
  802bfa:	5d                   	pop    %ebp
  802bfb:	c3                   	ret    

00802bfc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802bfc:	55                   	push   %ebp
  802bfd:	89 e5                	mov    %esp,%ebp
  802bff:	53                   	push   %ebx
  802c00:	83 ec 14             	sub    $0x14,%esp
  802c03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c06:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c09:	50                   	push   %eax
  802c0a:	53                   	push   %ebx
  802c0b:	e8 86 fd ff ff       	call   802996 <fd_lookup>
  802c10:	83 c4 08             	add    $0x8,%esp
  802c13:	89 c2                	mov    %eax,%edx
  802c15:	85 c0                	test   %eax,%eax
  802c17:	78 6d                	js     802c86 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c19:	83 ec 08             	sub    $0x8,%esp
  802c1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c1f:	50                   	push   %eax
  802c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c23:	ff 30                	pushl  (%eax)
  802c25:	e8 c2 fd ff ff       	call   8029ec <dev_lookup>
  802c2a:	83 c4 10             	add    $0x10,%esp
  802c2d:	85 c0                	test   %eax,%eax
  802c2f:	78 4c                	js     802c7d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802c31:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802c34:	8b 42 08             	mov    0x8(%edx),%eax
  802c37:	83 e0 03             	and    $0x3,%eax
  802c3a:	83 f8 01             	cmp    $0x1,%eax
  802c3d:	75 21                	jne    802c60 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802c3f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802c44:	8b 40 48             	mov    0x48(%eax),%eax
  802c47:	83 ec 04             	sub    $0x4,%esp
  802c4a:	53                   	push   %ebx
  802c4b:	50                   	push   %eax
  802c4c:	68 d4 42 80 00       	push   $0x8042d4
  802c51:	e8 e6 ef ff ff       	call   801c3c <cprintf>
		return -E_INVAL;
  802c56:	83 c4 10             	add    $0x10,%esp
  802c59:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c5e:	eb 26                	jmp    802c86 <read+0x8a>
	}
	if (!dev->dev_read)
  802c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c63:	8b 40 08             	mov    0x8(%eax),%eax
  802c66:	85 c0                	test   %eax,%eax
  802c68:	74 17                	je     802c81 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802c6a:	83 ec 04             	sub    $0x4,%esp
  802c6d:	ff 75 10             	pushl  0x10(%ebp)
  802c70:	ff 75 0c             	pushl  0xc(%ebp)
  802c73:	52                   	push   %edx
  802c74:	ff d0                	call   *%eax
  802c76:	89 c2                	mov    %eax,%edx
  802c78:	83 c4 10             	add    $0x10,%esp
  802c7b:	eb 09                	jmp    802c86 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c7d:	89 c2                	mov    %eax,%edx
  802c7f:	eb 05                	jmp    802c86 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802c81:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802c86:	89 d0                	mov    %edx,%eax
  802c88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c8b:	c9                   	leave  
  802c8c:	c3                   	ret    

00802c8d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802c8d:	55                   	push   %ebp
  802c8e:	89 e5                	mov    %esp,%ebp
  802c90:	57                   	push   %edi
  802c91:	56                   	push   %esi
  802c92:	53                   	push   %ebx
  802c93:	83 ec 0c             	sub    $0xc,%esp
  802c96:	8b 7d 08             	mov    0x8(%ebp),%edi
  802c99:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802ca1:	eb 21                	jmp    802cc4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802ca3:	83 ec 04             	sub    $0x4,%esp
  802ca6:	89 f0                	mov    %esi,%eax
  802ca8:	29 d8                	sub    %ebx,%eax
  802caa:	50                   	push   %eax
  802cab:	89 d8                	mov    %ebx,%eax
  802cad:	03 45 0c             	add    0xc(%ebp),%eax
  802cb0:	50                   	push   %eax
  802cb1:	57                   	push   %edi
  802cb2:	e8 45 ff ff ff       	call   802bfc <read>
		if (m < 0)
  802cb7:	83 c4 10             	add    $0x10,%esp
  802cba:	85 c0                	test   %eax,%eax
  802cbc:	78 10                	js     802cce <readn+0x41>
			return m;
		if (m == 0)
  802cbe:	85 c0                	test   %eax,%eax
  802cc0:	74 0a                	je     802ccc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802cc2:	01 c3                	add    %eax,%ebx
  802cc4:	39 f3                	cmp    %esi,%ebx
  802cc6:	72 db                	jb     802ca3 <readn+0x16>
  802cc8:	89 d8                	mov    %ebx,%eax
  802cca:	eb 02                	jmp    802cce <readn+0x41>
  802ccc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cd1:	5b                   	pop    %ebx
  802cd2:	5e                   	pop    %esi
  802cd3:	5f                   	pop    %edi
  802cd4:	5d                   	pop    %ebp
  802cd5:	c3                   	ret    

00802cd6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802cd6:	55                   	push   %ebp
  802cd7:	89 e5                	mov    %esp,%ebp
  802cd9:	53                   	push   %ebx
  802cda:	83 ec 14             	sub    $0x14,%esp
  802cdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ce0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ce3:	50                   	push   %eax
  802ce4:	53                   	push   %ebx
  802ce5:	e8 ac fc ff ff       	call   802996 <fd_lookup>
  802cea:	83 c4 08             	add    $0x8,%esp
  802ced:	89 c2                	mov    %eax,%edx
  802cef:	85 c0                	test   %eax,%eax
  802cf1:	78 68                	js     802d5b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cf3:	83 ec 08             	sub    $0x8,%esp
  802cf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cf9:	50                   	push   %eax
  802cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cfd:	ff 30                	pushl  (%eax)
  802cff:	e8 e8 fc ff ff       	call   8029ec <dev_lookup>
  802d04:	83 c4 10             	add    $0x10,%esp
  802d07:	85 c0                	test   %eax,%eax
  802d09:	78 47                	js     802d52 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d0e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d12:	75 21                	jne    802d35 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802d14:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802d19:	8b 40 48             	mov    0x48(%eax),%eax
  802d1c:	83 ec 04             	sub    $0x4,%esp
  802d1f:	53                   	push   %ebx
  802d20:	50                   	push   %eax
  802d21:	68 f0 42 80 00       	push   $0x8042f0
  802d26:	e8 11 ef ff ff       	call   801c3c <cprintf>
		return -E_INVAL;
  802d2b:	83 c4 10             	add    $0x10,%esp
  802d2e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d33:	eb 26                	jmp    802d5b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802d35:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d38:	8b 52 0c             	mov    0xc(%edx),%edx
  802d3b:	85 d2                	test   %edx,%edx
  802d3d:	74 17                	je     802d56 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802d3f:	83 ec 04             	sub    $0x4,%esp
  802d42:	ff 75 10             	pushl  0x10(%ebp)
  802d45:	ff 75 0c             	pushl  0xc(%ebp)
  802d48:	50                   	push   %eax
  802d49:	ff d2                	call   *%edx
  802d4b:	89 c2                	mov    %eax,%edx
  802d4d:	83 c4 10             	add    $0x10,%esp
  802d50:	eb 09                	jmp    802d5b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d52:	89 c2                	mov    %eax,%edx
  802d54:	eb 05                	jmp    802d5b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802d56:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802d5b:	89 d0                	mov    %edx,%eax
  802d5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d60:	c9                   	leave  
  802d61:	c3                   	ret    

00802d62 <seek>:

int
seek(int fdnum, off_t offset)
{
  802d62:	55                   	push   %ebp
  802d63:	89 e5                	mov    %esp,%ebp
  802d65:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d68:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802d6b:	50                   	push   %eax
  802d6c:	ff 75 08             	pushl  0x8(%ebp)
  802d6f:	e8 22 fc ff ff       	call   802996 <fd_lookup>
  802d74:	83 c4 08             	add    $0x8,%esp
  802d77:	85 c0                	test   %eax,%eax
  802d79:	78 0e                	js     802d89 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802d7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802d7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d81:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802d84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802d89:	c9                   	leave  
  802d8a:	c3                   	ret    

00802d8b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802d8b:	55                   	push   %ebp
  802d8c:	89 e5                	mov    %esp,%ebp
  802d8e:	53                   	push   %ebx
  802d8f:	83 ec 14             	sub    $0x14,%esp
  802d92:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d95:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d98:	50                   	push   %eax
  802d99:	53                   	push   %ebx
  802d9a:	e8 f7 fb ff ff       	call   802996 <fd_lookup>
  802d9f:	83 c4 08             	add    $0x8,%esp
  802da2:	89 c2                	mov    %eax,%edx
  802da4:	85 c0                	test   %eax,%eax
  802da6:	78 65                	js     802e0d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802da8:	83 ec 08             	sub    $0x8,%esp
  802dab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802dae:	50                   	push   %eax
  802daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802db2:	ff 30                	pushl  (%eax)
  802db4:	e8 33 fc ff ff       	call   8029ec <dev_lookup>
  802db9:	83 c4 10             	add    $0x10,%esp
  802dbc:	85 c0                	test   %eax,%eax
  802dbe:	78 44                	js     802e04 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dc3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802dc7:	75 21                	jne    802dea <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802dc9:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802dce:	8b 40 48             	mov    0x48(%eax),%eax
  802dd1:	83 ec 04             	sub    $0x4,%esp
  802dd4:	53                   	push   %ebx
  802dd5:	50                   	push   %eax
  802dd6:	68 b0 42 80 00       	push   $0x8042b0
  802ddb:	e8 5c ee ff ff       	call   801c3c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802de0:	83 c4 10             	add    $0x10,%esp
  802de3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802de8:	eb 23                	jmp    802e0d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802dea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ded:	8b 52 18             	mov    0x18(%edx),%edx
  802df0:	85 d2                	test   %edx,%edx
  802df2:	74 14                	je     802e08 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802df4:	83 ec 08             	sub    $0x8,%esp
  802df7:	ff 75 0c             	pushl  0xc(%ebp)
  802dfa:	50                   	push   %eax
  802dfb:	ff d2                	call   *%edx
  802dfd:	89 c2                	mov    %eax,%edx
  802dff:	83 c4 10             	add    $0x10,%esp
  802e02:	eb 09                	jmp    802e0d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e04:	89 c2                	mov    %eax,%edx
  802e06:	eb 05                	jmp    802e0d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802e08:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802e0d:	89 d0                	mov    %edx,%eax
  802e0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e12:	c9                   	leave  
  802e13:	c3                   	ret    

00802e14 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802e14:	55                   	push   %ebp
  802e15:	89 e5                	mov    %esp,%ebp
  802e17:	53                   	push   %ebx
  802e18:	83 ec 14             	sub    $0x14,%esp
  802e1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e1e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e21:	50                   	push   %eax
  802e22:	ff 75 08             	pushl  0x8(%ebp)
  802e25:	e8 6c fb ff ff       	call   802996 <fd_lookup>
  802e2a:	83 c4 08             	add    $0x8,%esp
  802e2d:	89 c2                	mov    %eax,%edx
  802e2f:	85 c0                	test   %eax,%eax
  802e31:	78 58                	js     802e8b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e33:	83 ec 08             	sub    $0x8,%esp
  802e36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e39:	50                   	push   %eax
  802e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e3d:	ff 30                	pushl  (%eax)
  802e3f:	e8 a8 fb ff ff       	call   8029ec <dev_lookup>
  802e44:	83 c4 10             	add    $0x10,%esp
  802e47:	85 c0                	test   %eax,%eax
  802e49:	78 37                	js     802e82 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e4e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802e52:	74 32                	je     802e86 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802e54:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802e57:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802e5e:	00 00 00 
	stat->st_isdir = 0;
  802e61:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802e68:	00 00 00 
	stat->st_dev = dev;
  802e6b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802e71:	83 ec 08             	sub    $0x8,%esp
  802e74:	53                   	push   %ebx
  802e75:	ff 75 f0             	pushl  -0x10(%ebp)
  802e78:	ff 50 14             	call   *0x14(%eax)
  802e7b:	89 c2                	mov    %eax,%edx
  802e7d:	83 c4 10             	add    $0x10,%esp
  802e80:	eb 09                	jmp    802e8b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e82:	89 c2                	mov    %eax,%edx
  802e84:	eb 05                	jmp    802e8b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802e86:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802e8b:	89 d0                	mov    %edx,%eax
  802e8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e90:	c9                   	leave  
  802e91:	c3                   	ret    

00802e92 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802e92:	55                   	push   %ebp
  802e93:	89 e5                	mov    %esp,%ebp
  802e95:	56                   	push   %esi
  802e96:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802e97:	83 ec 08             	sub    $0x8,%esp
  802e9a:	6a 00                	push   $0x0
  802e9c:	ff 75 08             	pushl  0x8(%ebp)
  802e9f:	e8 2c 02 00 00       	call   8030d0 <open>
  802ea4:	89 c3                	mov    %eax,%ebx
  802ea6:	83 c4 10             	add    $0x10,%esp
  802ea9:	85 c0                	test   %eax,%eax
  802eab:	78 1b                	js     802ec8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802ead:	83 ec 08             	sub    $0x8,%esp
  802eb0:	ff 75 0c             	pushl  0xc(%ebp)
  802eb3:	50                   	push   %eax
  802eb4:	e8 5b ff ff ff       	call   802e14 <fstat>
  802eb9:	89 c6                	mov    %eax,%esi
	close(fd);
  802ebb:	89 1c 24             	mov    %ebx,(%esp)
  802ebe:	e8 fd fb ff ff       	call   802ac0 <close>
	return r;
  802ec3:	83 c4 10             	add    $0x10,%esp
  802ec6:	89 f0                	mov    %esi,%eax
}
  802ec8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ecb:	5b                   	pop    %ebx
  802ecc:	5e                   	pop    %esi
  802ecd:	5d                   	pop    %ebp
  802ece:	c3                   	ret    

00802ecf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  802ecf:	55                   	push   %ebp
  802ed0:	89 e5                	mov    %esp,%ebp
  802ed2:	56                   	push   %esi
  802ed3:	53                   	push   %ebx
  802ed4:	89 c6                	mov    %eax,%esi
  802ed6:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  802ed8:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802edf:	75 12                	jne    802ef3 <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  802ee1:	83 ec 0c             	sub    $0xc,%esp
  802ee4:	6a 01                	push   $0x1
  802ee6:	e8 fc f9 ff ff       	call   8028e7 <ipc_find_env>
  802eeb:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802ef0:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802ef3:	6a 07                	push   $0x7
  802ef5:	68 00 b0 80 00       	push   $0x80b000
  802efa:	56                   	push   %esi
  802efb:	ff 35 00 a0 80 00    	pushl  0x80a000
  802f01:	e8 8d f9 ff ff       	call   802893 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  802f06:	83 c4 0c             	add    $0xc,%esp
  802f09:	6a 00                	push   $0x0
  802f0b:	53                   	push   %ebx
  802f0c:	6a 00                	push   $0x0
  802f0e:	e8 21 f9 ff ff       	call   802834 <ipc_recv>
}
  802f13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f16:	5b                   	pop    %ebx
  802f17:	5e                   	pop    %esi
  802f18:	5d                   	pop    %ebp
  802f19:	c3                   	ret    

00802f1a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802f1a:	55                   	push   %ebp
  802f1b:	89 e5                	mov    %esp,%ebp
  802f1d:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802f20:	8b 45 08             	mov    0x8(%ebp),%eax
  802f23:	8b 40 0c             	mov    0xc(%eax),%eax
  802f26:	a3 00 b0 80 00       	mov    %eax,0x80b000
	   fsipcbuf.set_size.req_size = newsize;
  802f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f2e:	a3 04 b0 80 00       	mov    %eax,0x80b004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  802f33:	ba 00 00 00 00       	mov    $0x0,%edx
  802f38:	b8 02 00 00 00       	mov    $0x2,%eax
  802f3d:	e8 8d ff ff ff       	call   802ecf <fsipc>
}
  802f42:	c9                   	leave  
  802f43:	c3                   	ret    

00802f44 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  802f44:	55                   	push   %ebp
  802f45:	89 e5                	mov    %esp,%ebp
  802f47:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  802f4d:	8b 40 0c             	mov    0xc(%eax),%eax
  802f50:	a3 00 b0 80 00       	mov    %eax,0x80b000
	   return fsipc(FSREQ_FLUSH, NULL);
  802f55:	ba 00 00 00 00       	mov    $0x0,%edx
  802f5a:	b8 06 00 00 00       	mov    $0x6,%eax
  802f5f:	e8 6b ff ff ff       	call   802ecf <fsipc>
}
  802f64:	c9                   	leave  
  802f65:	c3                   	ret    

00802f66 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802f66:	55                   	push   %ebp
  802f67:	89 e5                	mov    %esp,%ebp
  802f69:	53                   	push   %ebx
  802f6a:	83 ec 04             	sub    $0x4,%esp
  802f6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802f70:	8b 45 08             	mov    0x8(%ebp),%eax
  802f73:	8b 40 0c             	mov    0xc(%eax),%eax
  802f76:	a3 00 b0 80 00       	mov    %eax,0x80b000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802f7b:	ba 00 00 00 00       	mov    $0x0,%edx
  802f80:	b8 05 00 00 00       	mov    $0x5,%eax
  802f85:	e8 45 ff ff ff       	call   802ecf <fsipc>
  802f8a:	85 c0                	test   %eax,%eax
  802f8c:	78 2c                	js     802fba <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802f8e:	83 ec 08             	sub    $0x8,%esp
  802f91:	68 00 b0 80 00       	push   $0x80b000
  802f96:	53                   	push   %ebx
  802f97:	e8 25 f2 ff ff       	call   8021c1 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  802f9c:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802fa1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802fa7:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802fac:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  802fb2:	83 c4 10             	add    $0x10,%esp
  802fb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802fba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fbd:	c9                   	leave  
  802fbe:	c3                   	ret    

00802fbf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802fbf:	55                   	push   %ebp
  802fc0:	89 e5                	mov    %esp,%ebp
  802fc2:	53                   	push   %ebx
  802fc3:	83 ec 08             	sub    $0x8,%esp
  802fc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  802fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  802fcc:	8b 40 0c             	mov    0xc(%eax),%eax
  802fcf:	a3 00 b0 80 00       	mov    %eax,0x80b000
	   fsipcbuf.write.req_n = n;
  802fd4:	89 1d 04 b0 80 00    	mov    %ebx,0x80b004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  802fda:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  802fe0:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  802fe5:	0f 46 c3             	cmovbe %ebx,%eax
  802fe8:	50                   	push   %eax
  802fe9:	ff 75 0c             	pushl  0xc(%ebp)
  802fec:	68 08 b0 80 00       	push   $0x80b008
  802ff1:	e8 5d f3 ff ff       	call   802353 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  802ff6:	ba 00 00 00 00       	mov    $0x0,%edx
  802ffb:	b8 04 00 00 00       	mov    $0x4,%eax
  803000:	e8 ca fe ff ff       	call   802ecf <fsipc>
  803005:	83 c4 10             	add    $0x10,%esp
  803008:	85 c0                	test   %eax,%eax
  80300a:	78 3d                	js     803049 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  80300c:	39 c3                	cmp    %eax,%ebx
  80300e:	73 19                	jae    803029 <devfile_write+0x6a>
  803010:	68 20 43 80 00       	push   $0x804320
  803015:	68 5d 39 80 00       	push   $0x80395d
  80301a:	68 9a 00 00 00       	push   $0x9a
  80301f:	68 27 43 80 00       	push   $0x804327
  803024:	e8 3a eb ff ff       	call   801b63 <_panic>
	   assert (r <= bytes_written);
  803029:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80302e:	7e 19                	jle    803049 <devfile_write+0x8a>
  803030:	68 32 43 80 00       	push   $0x804332
  803035:	68 5d 39 80 00       	push   $0x80395d
  80303a:	68 9b 00 00 00       	push   $0x9b
  80303f:	68 27 43 80 00       	push   $0x804327
  803044:	e8 1a eb ff ff       	call   801b63 <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  803049:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80304c:	c9                   	leave  
  80304d:	c3                   	ret    

0080304e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80304e:	55                   	push   %ebp
  80304f:	89 e5                	mov    %esp,%ebp
  803051:	56                   	push   %esi
  803052:	53                   	push   %ebx
  803053:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  803056:	8b 45 08             	mov    0x8(%ebp),%eax
  803059:	8b 40 0c             	mov    0xc(%eax),%eax
  80305c:	a3 00 b0 80 00       	mov    %eax,0x80b000
	   fsipcbuf.read.req_n = n;
  803061:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  803067:	ba 00 00 00 00       	mov    $0x0,%edx
  80306c:	b8 03 00 00 00       	mov    $0x3,%eax
  803071:	e8 59 fe ff ff       	call   802ecf <fsipc>
  803076:	89 c3                	mov    %eax,%ebx
  803078:	85 c0                	test   %eax,%eax
  80307a:	78 4b                	js     8030c7 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  80307c:	39 c6                	cmp    %eax,%esi
  80307e:	73 16                	jae    803096 <devfile_read+0x48>
  803080:	68 20 43 80 00       	push   $0x804320
  803085:	68 5d 39 80 00       	push   $0x80395d
  80308a:	6a 7c                	push   $0x7c
  80308c:	68 27 43 80 00       	push   $0x804327
  803091:	e8 cd ea ff ff       	call   801b63 <_panic>
	   assert(r <= PGSIZE);
  803096:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80309b:	7e 16                	jle    8030b3 <devfile_read+0x65>
  80309d:	68 45 43 80 00       	push   $0x804345
  8030a2:	68 5d 39 80 00       	push   $0x80395d
  8030a7:	6a 7d                	push   $0x7d
  8030a9:	68 27 43 80 00       	push   $0x804327
  8030ae:	e8 b0 ea ff ff       	call   801b63 <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8030b3:	83 ec 04             	sub    $0x4,%esp
  8030b6:	50                   	push   %eax
  8030b7:	68 00 b0 80 00       	push   $0x80b000
  8030bc:	ff 75 0c             	pushl  0xc(%ebp)
  8030bf:	e8 8f f2 ff ff       	call   802353 <memmove>
	   return r;
  8030c4:	83 c4 10             	add    $0x10,%esp
}
  8030c7:	89 d8                	mov    %ebx,%eax
  8030c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8030cc:	5b                   	pop    %ebx
  8030cd:	5e                   	pop    %esi
  8030ce:	5d                   	pop    %ebp
  8030cf:	c3                   	ret    

008030d0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  8030d0:	55                   	push   %ebp
  8030d1:	89 e5                	mov    %esp,%ebp
  8030d3:	53                   	push   %ebx
  8030d4:	83 ec 20             	sub    $0x20,%esp
  8030d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  8030da:	53                   	push   %ebx
  8030db:	e8 a8 f0 ff ff       	call   802188 <strlen>
  8030e0:	83 c4 10             	add    $0x10,%esp
  8030e3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8030e8:	7f 67                	jg     803151 <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8030ea:	83 ec 0c             	sub    $0xc,%esp
  8030ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030f0:	50                   	push   %eax
  8030f1:	e8 51 f8 ff ff       	call   802947 <fd_alloc>
  8030f6:	83 c4 10             	add    $0x10,%esp
			 return r;
  8030f9:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  8030fb:	85 c0                	test   %eax,%eax
  8030fd:	78 57                	js     803156 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  8030ff:	83 ec 08             	sub    $0x8,%esp
  803102:	53                   	push   %ebx
  803103:	68 00 b0 80 00       	push   $0x80b000
  803108:	e8 b4 f0 ff ff       	call   8021c1 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  80310d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803110:	a3 00 b4 80 00       	mov    %eax,0x80b400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803115:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803118:	b8 01 00 00 00       	mov    $0x1,%eax
  80311d:	e8 ad fd ff ff       	call   802ecf <fsipc>
  803122:	89 c3                	mov    %eax,%ebx
  803124:	83 c4 10             	add    $0x10,%esp
  803127:	85 c0                	test   %eax,%eax
  803129:	79 14                	jns    80313f <open+0x6f>
			 fd_close(fd, 0);
  80312b:	83 ec 08             	sub    $0x8,%esp
  80312e:	6a 00                	push   $0x0
  803130:	ff 75 f4             	pushl  -0xc(%ebp)
  803133:	e8 07 f9 ff ff       	call   802a3f <fd_close>
			 return r;
  803138:	83 c4 10             	add    $0x10,%esp
  80313b:	89 da                	mov    %ebx,%edx
  80313d:	eb 17                	jmp    803156 <open+0x86>
	   }

	   return fd2num(fd);
  80313f:	83 ec 0c             	sub    $0xc,%esp
  803142:	ff 75 f4             	pushl  -0xc(%ebp)
  803145:	e8 d6 f7 ff ff       	call   802920 <fd2num>
  80314a:	89 c2                	mov    %eax,%edx
  80314c:	83 c4 10             	add    $0x10,%esp
  80314f:	eb 05                	jmp    803156 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  803151:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  803156:	89 d0                	mov    %edx,%eax
  803158:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80315b:	c9                   	leave  
  80315c:	c3                   	ret    

0080315d <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  80315d:	55                   	push   %ebp
  80315e:	89 e5                	mov    %esp,%ebp
  803160:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  803163:	ba 00 00 00 00       	mov    $0x0,%edx
  803168:	b8 08 00 00 00       	mov    $0x8,%eax
  80316d:	e8 5d fd ff ff       	call   802ecf <fsipc>
}
  803172:	c9                   	leave  
  803173:	c3                   	ret    

00803174 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803174:	55                   	push   %ebp
  803175:	89 e5                	mov    %esp,%ebp
  803177:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80317a:	89 d0                	mov    %edx,%eax
  80317c:	c1 e8 16             	shr    $0x16,%eax
  80317f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803186:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80318b:	f6 c1 01             	test   $0x1,%cl
  80318e:	74 1d                	je     8031ad <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803190:	c1 ea 0c             	shr    $0xc,%edx
  803193:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80319a:	f6 c2 01             	test   $0x1,%dl
  80319d:	74 0e                	je     8031ad <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80319f:	c1 ea 0c             	shr    $0xc,%edx
  8031a2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8031a9:	ef 
  8031aa:	0f b7 c0             	movzwl %ax,%eax
}
  8031ad:	5d                   	pop    %ebp
  8031ae:	c3                   	ret    

008031af <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8031af:	55                   	push   %ebp
  8031b0:	89 e5                	mov    %esp,%ebp
  8031b2:	56                   	push   %esi
  8031b3:	53                   	push   %ebx
  8031b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8031b7:	83 ec 0c             	sub    $0xc,%esp
  8031ba:	ff 75 08             	pushl  0x8(%ebp)
  8031bd:	e8 6e f7 ff ff       	call   802930 <fd2data>
  8031c2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8031c4:	83 c4 08             	add    $0x8,%esp
  8031c7:	68 51 43 80 00       	push   $0x804351
  8031cc:	53                   	push   %ebx
  8031cd:	e8 ef ef ff ff       	call   8021c1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8031d2:	8b 46 04             	mov    0x4(%esi),%eax
  8031d5:	2b 06                	sub    (%esi),%eax
  8031d7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8031dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8031e4:	00 00 00 
	stat->st_dev = &devpipe;
  8031e7:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  8031ee:	90 80 00 
	return 0;
}
  8031f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8031f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8031f9:	5b                   	pop    %ebx
  8031fa:	5e                   	pop    %esi
  8031fb:	5d                   	pop    %ebp
  8031fc:	c3                   	ret    

008031fd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8031fd:	55                   	push   %ebp
  8031fe:	89 e5                	mov    %esp,%ebp
  803200:	53                   	push   %ebx
  803201:	83 ec 0c             	sub    $0xc,%esp
  803204:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803207:	53                   	push   %ebx
  803208:	6a 00                	push   $0x0
  80320a:	e8 3a f4 ff ff       	call   802649 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80320f:	89 1c 24             	mov    %ebx,(%esp)
  803212:	e8 19 f7 ff ff       	call   802930 <fd2data>
  803217:	83 c4 08             	add    $0x8,%esp
  80321a:	50                   	push   %eax
  80321b:	6a 00                	push   $0x0
  80321d:	e8 27 f4 ff ff       	call   802649 <sys_page_unmap>
}
  803222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803225:	c9                   	leave  
  803226:	c3                   	ret    

00803227 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803227:	55                   	push   %ebp
  803228:	89 e5                	mov    %esp,%ebp
  80322a:	57                   	push   %edi
  80322b:	56                   	push   %esi
  80322c:	53                   	push   %ebx
  80322d:	83 ec 1c             	sub    $0x1c,%esp
  803230:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803233:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803235:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80323a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80323d:	83 ec 0c             	sub    $0xc,%esp
  803240:	ff 75 e0             	pushl  -0x20(%ebp)
  803243:	e8 2c ff ff ff       	call   803174 <pageref>
  803248:	89 c3                	mov    %eax,%ebx
  80324a:	89 3c 24             	mov    %edi,(%esp)
  80324d:	e8 22 ff ff ff       	call   803174 <pageref>
  803252:	83 c4 10             	add    $0x10,%esp
  803255:	39 c3                	cmp    %eax,%ebx
  803257:	0f 94 c1             	sete   %cl
  80325a:	0f b6 c9             	movzbl %cl,%ecx
  80325d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  803260:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  803266:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803269:	39 ce                	cmp    %ecx,%esi
  80326b:	74 1b                	je     803288 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80326d:	39 c3                	cmp    %eax,%ebx
  80326f:	75 c4                	jne    803235 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803271:	8b 42 58             	mov    0x58(%edx),%eax
  803274:	ff 75 e4             	pushl  -0x1c(%ebp)
  803277:	50                   	push   %eax
  803278:	56                   	push   %esi
  803279:	68 58 43 80 00       	push   $0x804358
  80327e:	e8 b9 e9 ff ff       	call   801c3c <cprintf>
  803283:	83 c4 10             	add    $0x10,%esp
  803286:	eb ad                	jmp    803235 <_pipeisclosed+0xe>
	}
}
  803288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80328b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80328e:	5b                   	pop    %ebx
  80328f:	5e                   	pop    %esi
  803290:	5f                   	pop    %edi
  803291:	5d                   	pop    %ebp
  803292:	c3                   	ret    

00803293 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803293:	55                   	push   %ebp
  803294:	89 e5                	mov    %esp,%ebp
  803296:	57                   	push   %edi
  803297:	56                   	push   %esi
  803298:	53                   	push   %ebx
  803299:	83 ec 28             	sub    $0x28,%esp
  80329c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80329f:	56                   	push   %esi
  8032a0:	e8 8b f6 ff ff       	call   802930 <fd2data>
  8032a5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8032a7:	83 c4 10             	add    $0x10,%esp
  8032aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8032af:	eb 4b                	jmp    8032fc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8032b1:	89 da                	mov    %ebx,%edx
  8032b3:	89 f0                	mov    %esi,%eax
  8032b5:	e8 6d ff ff ff       	call   803227 <_pipeisclosed>
  8032ba:	85 c0                	test   %eax,%eax
  8032bc:	75 48                	jne    803306 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8032be:	e8 e2 f2 ff ff       	call   8025a5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8032c3:	8b 43 04             	mov    0x4(%ebx),%eax
  8032c6:	8b 0b                	mov    (%ebx),%ecx
  8032c8:	8d 51 20             	lea    0x20(%ecx),%edx
  8032cb:	39 d0                	cmp    %edx,%eax
  8032cd:	73 e2                	jae    8032b1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8032cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8032d2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8032d6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8032d9:	89 c2                	mov    %eax,%edx
  8032db:	c1 fa 1f             	sar    $0x1f,%edx
  8032de:	89 d1                	mov    %edx,%ecx
  8032e0:	c1 e9 1b             	shr    $0x1b,%ecx
  8032e3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8032e6:	83 e2 1f             	and    $0x1f,%edx
  8032e9:	29 ca                	sub    %ecx,%edx
  8032eb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8032ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8032f3:	83 c0 01             	add    $0x1,%eax
  8032f6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8032f9:	83 c7 01             	add    $0x1,%edi
  8032fc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8032ff:	75 c2                	jne    8032c3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803301:	8b 45 10             	mov    0x10(%ebp),%eax
  803304:	eb 05                	jmp    80330b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803306:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80330b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80330e:	5b                   	pop    %ebx
  80330f:	5e                   	pop    %esi
  803310:	5f                   	pop    %edi
  803311:	5d                   	pop    %ebp
  803312:	c3                   	ret    

00803313 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803313:	55                   	push   %ebp
  803314:	89 e5                	mov    %esp,%ebp
  803316:	57                   	push   %edi
  803317:	56                   	push   %esi
  803318:	53                   	push   %ebx
  803319:	83 ec 18             	sub    $0x18,%esp
  80331c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80331f:	57                   	push   %edi
  803320:	e8 0b f6 ff ff       	call   802930 <fd2data>
  803325:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803327:	83 c4 10             	add    $0x10,%esp
  80332a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80332f:	eb 3d                	jmp    80336e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803331:	85 db                	test   %ebx,%ebx
  803333:	74 04                	je     803339 <devpipe_read+0x26>
				return i;
  803335:	89 d8                	mov    %ebx,%eax
  803337:	eb 44                	jmp    80337d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803339:	89 f2                	mov    %esi,%edx
  80333b:	89 f8                	mov    %edi,%eax
  80333d:	e8 e5 fe ff ff       	call   803227 <_pipeisclosed>
  803342:	85 c0                	test   %eax,%eax
  803344:	75 32                	jne    803378 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803346:	e8 5a f2 ff ff       	call   8025a5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80334b:	8b 06                	mov    (%esi),%eax
  80334d:	3b 46 04             	cmp    0x4(%esi),%eax
  803350:	74 df                	je     803331 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803352:	99                   	cltd   
  803353:	c1 ea 1b             	shr    $0x1b,%edx
  803356:	01 d0                	add    %edx,%eax
  803358:	83 e0 1f             	and    $0x1f,%eax
  80335b:	29 d0                	sub    %edx,%eax
  80335d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803362:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803365:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  803368:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80336b:	83 c3 01             	add    $0x1,%ebx
  80336e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803371:	75 d8                	jne    80334b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803373:	8b 45 10             	mov    0x10(%ebp),%eax
  803376:	eb 05                	jmp    80337d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803378:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80337d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803380:	5b                   	pop    %ebx
  803381:	5e                   	pop    %esi
  803382:	5f                   	pop    %edi
  803383:	5d                   	pop    %ebp
  803384:	c3                   	ret    

00803385 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803385:	55                   	push   %ebp
  803386:	89 e5                	mov    %esp,%ebp
  803388:	56                   	push   %esi
  803389:	53                   	push   %ebx
  80338a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80338d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803390:	50                   	push   %eax
  803391:	e8 b1 f5 ff ff       	call   802947 <fd_alloc>
  803396:	83 c4 10             	add    $0x10,%esp
  803399:	89 c2                	mov    %eax,%edx
  80339b:	85 c0                	test   %eax,%eax
  80339d:	0f 88 2c 01 00 00    	js     8034cf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8033a3:	83 ec 04             	sub    $0x4,%esp
  8033a6:	68 07 04 00 00       	push   $0x407
  8033ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8033ae:	6a 00                	push   $0x0
  8033b0:	e8 0f f2 ff ff       	call   8025c4 <sys_page_alloc>
  8033b5:	83 c4 10             	add    $0x10,%esp
  8033b8:	89 c2                	mov    %eax,%edx
  8033ba:	85 c0                	test   %eax,%eax
  8033bc:	0f 88 0d 01 00 00    	js     8034cf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8033c2:	83 ec 0c             	sub    $0xc,%esp
  8033c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8033c8:	50                   	push   %eax
  8033c9:	e8 79 f5 ff ff       	call   802947 <fd_alloc>
  8033ce:	89 c3                	mov    %eax,%ebx
  8033d0:	83 c4 10             	add    $0x10,%esp
  8033d3:	85 c0                	test   %eax,%eax
  8033d5:	0f 88 e2 00 00 00    	js     8034bd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8033db:	83 ec 04             	sub    $0x4,%esp
  8033de:	68 07 04 00 00       	push   $0x407
  8033e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8033e6:	6a 00                	push   $0x0
  8033e8:	e8 d7 f1 ff ff       	call   8025c4 <sys_page_alloc>
  8033ed:	89 c3                	mov    %eax,%ebx
  8033ef:	83 c4 10             	add    $0x10,%esp
  8033f2:	85 c0                	test   %eax,%eax
  8033f4:	0f 88 c3 00 00 00    	js     8034bd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8033fa:	83 ec 0c             	sub    $0xc,%esp
  8033fd:	ff 75 f4             	pushl  -0xc(%ebp)
  803400:	e8 2b f5 ff ff       	call   802930 <fd2data>
  803405:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803407:	83 c4 0c             	add    $0xc,%esp
  80340a:	68 07 04 00 00       	push   $0x407
  80340f:	50                   	push   %eax
  803410:	6a 00                	push   $0x0
  803412:	e8 ad f1 ff ff       	call   8025c4 <sys_page_alloc>
  803417:	89 c3                	mov    %eax,%ebx
  803419:	83 c4 10             	add    $0x10,%esp
  80341c:	85 c0                	test   %eax,%eax
  80341e:	0f 88 89 00 00 00    	js     8034ad <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803424:	83 ec 0c             	sub    $0xc,%esp
  803427:	ff 75 f0             	pushl  -0x10(%ebp)
  80342a:	e8 01 f5 ff ff       	call   802930 <fd2data>
  80342f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803436:	50                   	push   %eax
  803437:	6a 00                	push   $0x0
  803439:	56                   	push   %esi
  80343a:	6a 00                	push   $0x0
  80343c:	e8 c6 f1 ff ff       	call   802607 <sys_page_map>
  803441:	89 c3                	mov    %eax,%ebx
  803443:	83 c4 20             	add    $0x20,%esp
  803446:	85 c0                	test   %eax,%eax
  803448:	78 55                	js     80349f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80344a:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803450:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803453:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803455:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803458:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80345f:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803465:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803468:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80346a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80346d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803474:	83 ec 0c             	sub    $0xc,%esp
  803477:	ff 75 f4             	pushl  -0xc(%ebp)
  80347a:	e8 a1 f4 ff ff       	call   802920 <fd2num>
  80347f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803482:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803484:	83 c4 04             	add    $0x4,%esp
  803487:	ff 75 f0             	pushl  -0x10(%ebp)
  80348a:	e8 91 f4 ff ff       	call   802920 <fd2num>
  80348f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803492:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803495:	83 c4 10             	add    $0x10,%esp
  803498:	ba 00 00 00 00       	mov    $0x0,%edx
  80349d:	eb 30                	jmp    8034cf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80349f:	83 ec 08             	sub    $0x8,%esp
  8034a2:	56                   	push   %esi
  8034a3:	6a 00                	push   $0x0
  8034a5:	e8 9f f1 ff ff       	call   802649 <sys_page_unmap>
  8034aa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8034ad:	83 ec 08             	sub    $0x8,%esp
  8034b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8034b3:	6a 00                	push   $0x0
  8034b5:	e8 8f f1 ff ff       	call   802649 <sys_page_unmap>
  8034ba:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8034bd:	83 ec 08             	sub    $0x8,%esp
  8034c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8034c3:	6a 00                	push   $0x0
  8034c5:	e8 7f f1 ff ff       	call   802649 <sys_page_unmap>
  8034ca:	83 c4 10             	add    $0x10,%esp
  8034cd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8034cf:	89 d0                	mov    %edx,%eax
  8034d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8034d4:	5b                   	pop    %ebx
  8034d5:	5e                   	pop    %esi
  8034d6:	5d                   	pop    %ebp
  8034d7:	c3                   	ret    

008034d8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8034d8:	55                   	push   %ebp
  8034d9:	89 e5                	mov    %esp,%ebp
  8034db:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8034de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8034e1:	50                   	push   %eax
  8034e2:	ff 75 08             	pushl  0x8(%ebp)
  8034e5:	e8 ac f4 ff ff       	call   802996 <fd_lookup>
  8034ea:	83 c4 10             	add    $0x10,%esp
  8034ed:	85 c0                	test   %eax,%eax
  8034ef:	78 18                	js     803509 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8034f1:	83 ec 0c             	sub    $0xc,%esp
  8034f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8034f7:	e8 34 f4 ff ff       	call   802930 <fd2data>
	return _pipeisclosed(fd, p);
  8034fc:	89 c2                	mov    %eax,%edx
  8034fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803501:	e8 21 fd ff ff       	call   803227 <_pipeisclosed>
  803506:	83 c4 10             	add    $0x10,%esp
}
  803509:	c9                   	leave  
  80350a:	c3                   	ret    

0080350b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80350b:	55                   	push   %ebp
  80350c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80350e:	b8 00 00 00 00       	mov    $0x0,%eax
  803513:	5d                   	pop    %ebp
  803514:	c3                   	ret    

00803515 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803515:	55                   	push   %ebp
  803516:	89 e5                	mov    %esp,%ebp
  803518:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80351b:	68 70 43 80 00       	push   $0x804370
  803520:	ff 75 0c             	pushl  0xc(%ebp)
  803523:	e8 99 ec ff ff       	call   8021c1 <strcpy>
	return 0;
}
  803528:	b8 00 00 00 00       	mov    $0x0,%eax
  80352d:	c9                   	leave  
  80352e:	c3                   	ret    

0080352f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80352f:	55                   	push   %ebp
  803530:	89 e5                	mov    %esp,%ebp
  803532:	57                   	push   %edi
  803533:	56                   	push   %esi
  803534:	53                   	push   %ebx
  803535:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80353b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803540:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803546:	eb 2d                	jmp    803575 <devcons_write+0x46>
		m = n - tot;
  803548:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80354b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80354d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803550:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803555:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803558:	83 ec 04             	sub    $0x4,%esp
  80355b:	53                   	push   %ebx
  80355c:	03 45 0c             	add    0xc(%ebp),%eax
  80355f:	50                   	push   %eax
  803560:	57                   	push   %edi
  803561:	e8 ed ed ff ff       	call   802353 <memmove>
		sys_cputs(buf, m);
  803566:	83 c4 08             	add    $0x8,%esp
  803569:	53                   	push   %ebx
  80356a:	57                   	push   %edi
  80356b:	e8 98 ef ff ff       	call   802508 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803570:	01 de                	add    %ebx,%esi
  803572:	83 c4 10             	add    $0x10,%esp
  803575:	89 f0                	mov    %esi,%eax
  803577:	3b 75 10             	cmp    0x10(%ebp),%esi
  80357a:	72 cc                	jb     803548 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80357c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80357f:	5b                   	pop    %ebx
  803580:	5e                   	pop    %esi
  803581:	5f                   	pop    %edi
  803582:	5d                   	pop    %ebp
  803583:	c3                   	ret    

00803584 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803584:	55                   	push   %ebp
  803585:	89 e5                	mov    %esp,%ebp
  803587:	83 ec 08             	sub    $0x8,%esp
  80358a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80358f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803593:	74 2a                	je     8035bf <devcons_read+0x3b>
  803595:	eb 05                	jmp    80359c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803597:	e8 09 f0 ff ff       	call   8025a5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80359c:	e8 85 ef ff ff       	call   802526 <sys_cgetc>
  8035a1:	85 c0                	test   %eax,%eax
  8035a3:	74 f2                	je     803597 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8035a5:	85 c0                	test   %eax,%eax
  8035a7:	78 16                	js     8035bf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8035a9:	83 f8 04             	cmp    $0x4,%eax
  8035ac:	74 0c                	je     8035ba <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8035ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8035b1:	88 02                	mov    %al,(%edx)
	return 1;
  8035b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8035b8:	eb 05                	jmp    8035bf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8035ba:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8035bf:	c9                   	leave  
  8035c0:	c3                   	ret    

008035c1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8035c1:	55                   	push   %ebp
  8035c2:	89 e5                	mov    %esp,%ebp
  8035c4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8035c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8035ca:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8035cd:	6a 01                	push   $0x1
  8035cf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8035d2:	50                   	push   %eax
  8035d3:	e8 30 ef ff ff       	call   802508 <sys_cputs>
}
  8035d8:	83 c4 10             	add    $0x10,%esp
  8035db:	c9                   	leave  
  8035dc:	c3                   	ret    

008035dd <getchar>:

int
getchar(void)
{
  8035dd:	55                   	push   %ebp
  8035de:	89 e5                	mov    %esp,%ebp
  8035e0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8035e3:	6a 01                	push   $0x1
  8035e5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8035e8:	50                   	push   %eax
  8035e9:	6a 00                	push   $0x0
  8035eb:	e8 0c f6 ff ff       	call   802bfc <read>
	if (r < 0)
  8035f0:	83 c4 10             	add    $0x10,%esp
  8035f3:	85 c0                	test   %eax,%eax
  8035f5:	78 0f                	js     803606 <getchar+0x29>
		return r;
	if (r < 1)
  8035f7:	85 c0                	test   %eax,%eax
  8035f9:	7e 06                	jle    803601 <getchar+0x24>
		return -E_EOF;
	return c;
  8035fb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8035ff:	eb 05                	jmp    803606 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803601:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803606:	c9                   	leave  
  803607:	c3                   	ret    

00803608 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803608:	55                   	push   %ebp
  803609:	89 e5                	mov    %esp,%ebp
  80360b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80360e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803611:	50                   	push   %eax
  803612:	ff 75 08             	pushl  0x8(%ebp)
  803615:	e8 7c f3 ff ff       	call   802996 <fd_lookup>
  80361a:	83 c4 10             	add    $0x10,%esp
  80361d:	85 c0                	test   %eax,%eax
  80361f:	78 11                	js     803632 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803621:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803624:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80362a:	39 10                	cmp    %edx,(%eax)
  80362c:	0f 94 c0             	sete   %al
  80362f:	0f b6 c0             	movzbl %al,%eax
}
  803632:	c9                   	leave  
  803633:	c3                   	ret    

00803634 <opencons>:

int
opencons(void)
{
  803634:	55                   	push   %ebp
  803635:	89 e5                	mov    %esp,%ebp
  803637:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80363a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80363d:	50                   	push   %eax
  80363e:	e8 04 f3 ff ff       	call   802947 <fd_alloc>
  803643:	83 c4 10             	add    $0x10,%esp
		return r;
  803646:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803648:	85 c0                	test   %eax,%eax
  80364a:	78 3e                	js     80368a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80364c:	83 ec 04             	sub    $0x4,%esp
  80364f:	68 07 04 00 00       	push   $0x407
  803654:	ff 75 f4             	pushl  -0xc(%ebp)
  803657:	6a 00                	push   $0x0
  803659:	e8 66 ef ff ff       	call   8025c4 <sys_page_alloc>
  80365e:	83 c4 10             	add    $0x10,%esp
		return r;
  803661:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803663:	85 c0                	test   %eax,%eax
  803665:	78 23                	js     80368a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803667:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80366d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803670:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803672:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803675:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80367c:	83 ec 0c             	sub    $0xc,%esp
  80367f:	50                   	push   %eax
  803680:	e8 9b f2 ff ff       	call   802920 <fd2num>
  803685:	89 c2                	mov    %eax,%edx
  803687:	83 c4 10             	add    $0x10,%esp
}
  80368a:	89 d0                	mov    %edx,%eax
  80368c:	c9                   	leave  
  80368d:	c3                   	ret    
  80368e:	66 90                	xchg   %ax,%ax

00803690 <__udivdi3>:
  803690:	55                   	push   %ebp
  803691:	57                   	push   %edi
  803692:	56                   	push   %esi
  803693:	53                   	push   %ebx
  803694:	83 ec 1c             	sub    $0x1c,%esp
  803697:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80369b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80369f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8036a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8036a7:	85 f6                	test   %esi,%esi
  8036a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8036ad:	89 ca                	mov    %ecx,%edx
  8036af:	89 f8                	mov    %edi,%eax
  8036b1:	75 3d                	jne    8036f0 <__udivdi3+0x60>
  8036b3:	39 cf                	cmp    %ecx,%edi
  8036b5:	0f 87 c5 00 00 00    	ja     803780 <__udivdi3+0xf0>
  8036bb:	85 ff                	test   %edi,%edi
  8036bd:	89 fd                	mov    %edi,%ebp
  8036bf:	75 0b                	jne    8036cc <__udivdi3+0x3c>
  8036c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8036c6:	31 d2                	xor    %edx,%edx
  8036c8:	f7 f7                	div    %edi
  8036ca:	89 c5                	mov    %eax,%ebp
  8036cc:	89 c8                	mov    %ecx,%eax
  8036ce:	31 d2                	xor    %edx,%edx
  8036d0:	f7 f5                	div    %ebp
  8036d2:	89 c1                	mov    %eax,%ecx
  8036d4:	89 d8                	mov    %ebx,%eax
  8036d6:	89 cf                	mov    %ecx,%edi
  8036d8:	f7 f5                	div    %ebp
  8036da:	89 c3                	mov    %eax,%ebx
  8036dc:	89 d8                	mov    %ebx,%eax
  8036de:	89 fa                	mov    %edi,%edx
  8036e0:	83 c4 1c             	add    $0x1c,%esp
  8036e3:	5b                   	pop    %ebx
  8036e4:	5e                   	pop    %esi
  8036e5:	5f                   	pop    %edi
  8036e6:	5d                   	pop    %ebp
  8036e7:	c3                   	ret    
  8036e8:	90                   	nop
  8036e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8036f0:	39 ce                	cmp    %ecx,%esi
  8036f2:	77 74                	ja     803768 <__udivdi3+0xd8>
  8036f4:	0f bd fe             	bsr    %esi,%edi
  8036f7:	83 f7 1f             	xor    $0x1f,%edi
  8036fa:	0f 84 98 00 00 00    	je     803798 <__udivdi3+0x108>
  803700:	bb 20 00 00 00       	mov    $0x20,%ebx
  803705:	89 f9                	mov    %edi,%ecx
  803707:	89 c5                	mov    %eax,%ebp
  803709:	29 fb                	sub    %edi,%ebx
  80370b:	d3 e6                	shl    %cl,%esi
  80370d:	89 d9                	mov    %ebx,%ecx
  80370f:	d3 ed                	shr    %cl,%ebp
  803711:	89 f9                	mov    %edi,%ecx
  803713:	d3 e0                	shl    %cl,%eax
  803715:	09 ee                	or     %ebp,%esi
  803717:	89 d9                	mov    %ebx,%ecx
  803719:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80371d:	89 d5                	mov    %edx,%ebp
  80371f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803723:	d3 ed                	shr    %cl,%ebp
  803725:	89 f9                	mov    %edi,%ecx
  803727:	d3 e2                	shl    %cl,%edx
  803729:	89 d9                	mov    %ebx,%ecx
  80372b:	d3 e8                	shr    %cl,%eax
  80372d:	09 c2                	or     %eax,%edx
  80372f:	89 d0                	mov    %edx,%eax
  803731:	89 ea                	mov    %ebp,%edx
  803733:	f7 f6                	div    %esi
  803735:	89 d5                	mov    %edx,%ebp
  803737:	89 c3                	mov    %eax,%ebx
  803739:	f7 64 24 0c          	mull   0xc(%esp)
  80373d:	39 d5                	cmp    %edx,%ebp
  80373f:	72 10                	jb     803751 <__udivdi3+0xc1>
  803741:	8b 74 24 08          	mov    0x8(%esp),%esi
  803745:	89 f9                	mov    %edi,%ecx
  803747:	d3 e6                	shl    %cl,%esi
  803749:	39 c6                	cmp    %eax,%esi
  80374b:	73 07                	jae    803754 <__udivdi3+0xc4>
  80374d:	39 d5                	cmp    %edx,%ebp
  80374f:	75 03                	jne    803754 <__udivdi3+0xc4>
  803751:	83 eb 01             	sub    $0x1,%ebx
  803754:	31 ff                	xor    %edi,%edi
  803756:	89 d8                	mov    %ebx,%eax
  803758:	89 fa                	mov    %edi,%edx
  80375a:	83 c4 1c             	add    $0x1c,%esp
  80375d:	5b                   	pop    %ebx
  80375e:	5e                   	pop    %esi
  80375f:	5f                   	pop    %edi
  803760:	5d                   	pop    %ebp
  803761:	c3                   	ret    
  803762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803768:	31 ff                	xor    %edi,%edi
  80376a:	31 db                	xor    %ebx,%ebx
  80376c:	89 d8                	mov    %ebx,%eax
  80376e:	89 fa                	mov    %edi,%edx
  803770:	83 c4 1c             	add    $0x1c,%esp
  803773:	5b                   	pop    %ebx
  803774:	5e                   	pop    %esi
  803775:	5f                   	pop    %edi
  803776:	5d                   	pop    %ebp
  803777:	c3                   	ret    
  803778:	90                   	nop
  803779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803780:	89 d8                	mov    %ebx,%eax
  803782:	f7 f7                	div    %edi
  803784:	31 ff                	xor    %edi,%edi
  803786:	89 c3                	mov    %eax,%ebx
  803788:	89 d8                	mov    %ebx,%eax
  80378a:	89 fa                	mov    %edi,%edx
  80378c:	83 c4 1c             	add    $0x1c,%esp
  80378f:	5b                   	pop    %ebx
  803790:	5e                   	pop    %esi
  803791:	5f                   	pop    %edi
  803792:	5d                   	pop    %ebp
  803793:	c3                   	ret    
  803794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803798:	39 ce                	cmp    %ecx,%esi
  80379a:	72 0c                	jb     8037a8 <__udivdi3+0x118>
  80379c:	31 db                	xor    %ebx,%ebx
  80379e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8037a2:	0f 87 34 ff ff ff    	ja     8036dc <__udivdi3+0x4c>
  8037a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8037ad:	e9 2a ff ff ff       	jmp    8036dc <__udivdi3+0x4c>
  8037b2:	66 90                	xchg   %ax,%ax
  8037b4:	66 90                	xchg   %ax,%ax
  8037b6:	66 90                	xchg   %ax,%ax
  8037b8:	66 90                	xchg   %ax,%ax
  8037ba:	66 90                	xchg   %ax,%ax
  8037bc:	66 90                	xchg   %ax,%ax
  8037be:	66 90                	xchg   %ax,%ax

008037c0 <__umoddi3>:
  8037c0:	55                   	push   %ebp
  8037c1:	57                   	push   %edi
  8037c2:	56                   	push   %esi
  8037c3:	53                   	push   %ebx
  8037c4:	83 ec 1c             	sub    $0x1c,%esp
  8037c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8037cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8037cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8037d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8037d7:	85 d2                	test   %edx,%edx
  8037d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8037dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8037e1:	89 f3                	mov    %esi,%ebx
  8037e3:	89 3c 24             	mov    %edi,(%esp)
  8037e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8037ea:	75 1c                	jne    803808 <__umoddi3+0x48>
  8037ec:	39 f7                	cmp    %esi,%edi
  8037ee:	76 50                	jbe    803840 <__umoddi3+0x80>
  8037f0:	89 c8                	mov    %ecx,%eax
  8037f2:	89 f2                	mov    %esi,%edx
  8037f4:	f7 f7                	div    %edi
  8037f6:	89 d0                	mov    %edx,%eax
  8037f8:	31 d2                	xor    %edx,%edx
  8037fa:	83 c4 1c             	add    $0x1c,%esp
  8037fd:	5b                   	pop    %ebx
  8037fe:	5e                   	pop    %esi
  8037ff:	5f                   	pop    %edi
  803800:	5d                   	pop    %ebp
  803801:	c3                   	ret    
  803802:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803808:	39 f2                	cmp    %esi,%edx
  80380a:	89 d0                	mov    %edx,%eax
  80380c:	77 52                	ja     803860 <__umoddi3+0xa0>
  80380e:	0f bd ea             	bsr    %edx,%ebp
  803811:	83 f5 1f             	xor    $0x1f,%ebp
  803814:	75 5a                	jne    803870 <__umoddi3+0xb0>
  803816:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80381a:	0f 82 e0 00 00 00    	jb     803900 <__umoddi3+0x140>
  803820:	39 0c 24             	cmp    %ecx,(%esp)
  803823:	0f 86 d7 00 00 00    	jbe    803900 <__umoddi3+0x140>
  803829:	8b 44 24 08          	mov    0x8(%esp),%eax
  80382d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803831:	83 c4 1c             	add    $0x1c,%esp
  803834:	5b                   	pop    %ebx
  803835:	5e                   	pop    %esi
  803836:	5f                   	pop    %edi
  803837:	5d                   	pop    %ebp
  803838:	c3                   	ret    
  803839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803840:	85 ff                	test   %edi,%edi
  803842:	89 fd                	mov    %edi,%ebp
  803844:	75 0b                	jne    803851 <__umoddi3+0x91>
  803846:	b8 01 00 00 00       	mov    $0x1,%eax
  80384b:	31 d2                	xor    %edx,%edx
  80384d:	f7 f7                	div    %edi
  80384f:	89 c5                	mov    %eax,%ebp
  803851:	89 f0                	mov    %esi,%eax
  803853:	31 d2                	xor    %edx,%edx
  803855:	f7 f5                	div    %ebp
  803857:	89 c8                	mov    %ecx,%eax
  803859:	f7 f5                	div    %ebp
  80385b:	89 d0                	mov    %edx,%eax
  80385d:	eb 99                	jmp    8037f8 <__umoddi3+0x38>
  80385f:	90                   	nop
  803860:	89 c8                	mov    %ecx,%eax
  803862:	89 f2                	mov    %esi,%edx
  803864:	83 c4 1c             	add    $0x1c,%esp
  803867:	5b                   	pop    %ebx
  803868:	5e                   	pop    %esi
  803869:	5f                   	pop    %edi
  80386a:	5d                   	pop    %ebp
  80386b:	c3                   	ret    
  80386c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803870:	8b 34 24             	mov    (%esp),%esi
  803873:	bf 20 00 00 00       	mov    $0x20,%edi
  803878:	89 e9                	mov    %ebp,%ecx
  80387a:	29 ef                	sub    %ebp,%edi
  80387c:	d3 e0                	shl    %cl,%eax
  80387e:	89 f9                	mov    %edi,%ecx
  803880:	89 f2                	mov    %esi,%edx
  803882:	d3 ea                	shr    %cl,%edx
  803884:	89 e9                	mov    %ebp,%ecx
  803886:	09 c2                	or     %eax,%edx
  803888:	89 d8                	mov    %ebx,%eax
  80388a:	89 14 24             	mov    %edx,(%esp)
  80388d:	89 f2                	mov    %esi,%edx
  80388f:	d3 e2                	shl    %cl,%edx
  803891:	89 f9                	mov    %edi,%ecx
  803893:	89 54 24 04          	mov    %edx,0x4(%esp)
  803897:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80389b:	d3 e8                	shr    %cl,%eax
  80389d:	89 e9                	mov    %ebp,%ecx
  80389f:	89 c6                	mov    %eax,%esi
  8038a1:	d3 e3                	shl    %cl,%ebx
  8038a3:	89 f9                	mov    %edi,%ecx
  8038a5:	89 d0                	mov    %edx,%eax
  8038a7:	d3 e8                	shr    %cl,%eax
  8038a9:	89 e9                	mov    %ebp,%ecx
  8038ab:	09 d8                	or     %ebx,%eax
  8038ad:	89 d3                	mov    %edx,%ebx
  8038af:	89 f2                	mov    %esi,%edx
  8038b1:	f7 34 24             	divl   (%esp)
  8038b4:	89 d6                	mov    %edx,%esi
  8038b6:	d3 e3                	shl    %cl,%ebx
  8038b8:	f7 64 24 04          	mull   0x4(%esp)
  8038bc:	39 d6                	cmp    %edx,%esi
  8038be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8038c2:	89 d1                	mov    %edx,%ecx
  8038c4:	89 c3                	mov    %eax,%ebx
  8038c6:	72 08                	jb     8038d0 <__umoddi3+0x110>
  8038c8:	75 11                	jne    8038db <__umoddi3+0x11b>
  8038ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8038ce:	73 0b                	jae    8038db <__umoddi3+0x11b>
  8038d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8038d4:	1b 14 24             	sbb    (%esp),%edx
  8038d7:	89 d1                	mov    %edx,%ecx
  8038d9:	89 c3                	mov    %eax,%ebx
  8038db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8038df:	29 da                	sub    %ebx,%edx
  8038e1:	19 ce                	sbb    %ecx,%esi
  8038e3:	89 f9                	mov    %edi,%ecx
  8038e5:	89 f0                	mov    %esi,%eax
  8038e7:	d3 e0                	shl    %cl,%eax
  8038e9:	89 e9                	mov    %ebp,%ecx
  8038eb:	d3 ea                	shr    %cl,%edx
  8038ed:	89 e9                	mov    %ebp,%ecx
  8038ef:	d3 ee                	shr    %cl,%esi
  8038f1:	09 d0                	or     %edx,%eax
  8038f3:	89 f2                	mov    %esi,%edx
  8038f5:	83 c4 1c             	add    $0x1c,%esp
  8038f8:	5b                   	pop    %ebx
  8038f9:	5e                   	pop    %esi
  8038fa:	5f                   	pop    %edi
  8038fb:	5d                   	pop    %ebp
  8038fc:	c3                   	ret    
  8038fd:	8d 76 00             	lea    0x0(%esi),%esi
  803900:	29 f9                	sub    %edi,%ecx
  803902:	19 d6                	sbb    %edx,%esi
  803904:	89 74 24 04          	mov    %esi,0x4(%esp)
  803908:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80390c:	e9 18 ff ff ff       	jmp    803829 <__umoddi3+0x69>
