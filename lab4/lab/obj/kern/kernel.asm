
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 fe 22 f0    	mov    %esi,0xf022fe80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 49 5b 00 00       	call   f0105baa <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 40 62 10 f0       	push   $0xf0106240
f010006d:	e8 e2 37 00 00       	call   f0103854 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 b2 37 00 00       	call   f010382e <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 e1 65 10 f0 	movl   $0xf01065e1,(%esp)
f0100083:	e8 cc 37 00 00       	call   f0103854 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 94 08 00 00       	call   f0100929 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:



void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 04             	sub    $0x4,%esp
	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000a1:	e8 82 05 00 00       	call   f0100628 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a6:	83 ec 08             	sub    $0x8,%esp
f01000a9:	68 ac 1a 00 00       	push   $0x1aac
f01000ae:	68 ac 62 10 f0       	push   $0xf01062ac
f01000b3:	e8 9c 37 00 00       	call   f0103854 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 7e 13 00 00       	call   f010143b <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 9b 2f 00 00       	call   f010305d <env_init>
	trap_init();
f01000c2:	e8 6b 38 00 00       	call   f0103932 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 d4 57 00 00       	call   f01058a0 <mp_init>
	lapic_init();
f01000cc:	e8 f4 5a 00 00       	call   f0105bc5 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 a5 36 00 00       	call   f010377b <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d6:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000dd:	e8 36 5d 00 00       	call   f0105e18 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e2:	83 c4 10             	add    $0x10,%esp
f01000e5:	83 3d 88 fe 22 f0 07 	cmpl   $0x7,0xf022fe88
f01000ec:	77 16                	ja     f0100104 <i386_init+0x6a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000ee:	68 00 70 00 00       	push   $0x7000
f01000f3:	68 64 62 10 f0       	push   $0xf0106264
f01000f8:	6a 56                	push   $0x56
f01000fa:	68 c7 62 10 f0       	push   $0xf01062c7
f01000ff:	e8 3c ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100104:	83 ec 04             	sub    $0x4,%esp
f0100107:	b8 06 58 10 f0       	mov    $0xf0105806,%eax
f010010c:	2d 8c 57 10 f0       	sub    $0xf010578c,%eax
f0100111:	50                   	push   %eax
f0100112:	68 8c 57 10 f0       	push   $0xf010578c
f0100117:	68 00 70 00 f0       	push   $0xf0007000
f010011c:	e8 b3 54 00 00       	call   f01055d4 <memmove>
f0100121:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100124:	bb 20 00 23 f0       	mov    $0xf0230020,%ebx
f0100129:	eb 4d                	jmp    f0100178 <i386_init+0xde>
		if (c == cpus + cpunum())  // We've started already.
f010012b:	e8 7a 5a 00 00       	call   f0105baa <cpunum>
f0100130:	6b c0 74             	imul   $0x74,%eax,%eax
f0100133:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0100138:	39 c3                	cmp    %eax,%ebx
f010013a:	74 39                	je     f0100175 <i386_init+0xdb>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010013c:	89 d8                	mov    %ebx,%eax
f010013e:	2d 20 00 23 f0       	sub    $0xf0230020,%eax
f0100143:	c1 f8 02             	sar    $0x2,%eax
f0100146:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010014c:	c1 e0 0f             	shl    $0xf,%eax
f010014f:	05 00 90 23 f0       	add    $0xf0239000,%eax
f0100154:	a3 84 fe 22 f0       	mov    %eax,0xf022fe84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100159:	83 ec 08             	sub    $0x8,%esp
f010015c:	68 00 70 00 00       	push   $0x7000
f0100161:	0f b6 03             	movzbl (%ebx),%eax
f0100164:	50                   	push   %eax
f0100165:	e8 a9 5b 00 00       	call   f0105d13 <lapic_startap>
f010016a:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010016d:	8b 43 04             	mov    0x4(%ebx),%eax
f0100170:	83 f8 01             	cmp    $0x1,%eax
f0100173:	75 f8                	jne    f010016d <i386_init+0xd3>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100175:	83 c3 74             	add    $0x74,%ebx
f0100178:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f010017f:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0100184:	39 c3                	cmp    %eax,%ebx
f0100186:	72 a3                	jb     f010012b <i386_init+0x91>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100188:	83 ec 08             	sub    $0x8,%esp
f010018b:	6a 00                	push   $0x0
f010018d:	68 cc 4e 22 f0       	push   $0xf0224ecc
f0100192:	e8 9f 30 00 00       	call   f0103236 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
//	ENV_CREATE(user_forktree, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100197:	e8 5f 42 00 00       	call   f01043fb <sched_yield>

f010019c <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f010019c:	55                   	push   %ebp
f010019d:	89 e5                	mov    %esp,%ebp
f010019f:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001a2:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001ac:	77 12                	ja     f01001c0 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001ae:	50                   	push   %eax
f01001af:	68 88 62 10 f0       	push   $0xf0106288
f01001b4:	6a 6d                	push   $0x6d
f01001b6:	68 c7 62 10 f0       	push   $0xf01062c7
f01001bb:	e8 80 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001c0:	05 00 00 00 10       	add    $0x10000000,%eax
f01001c5:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001c8:	e8 dd 59 00 00       	call   f0105baa <cpunum>
f01001cd:	83 ec 08             	sub    $0x8,%esp
f01001d0:	50                   	push   %eax
f01001d1:	68 d3 62 10 f0       	push   $0xf01062d3
f01001d6:	e8 79 36 00 00       	call   f0103854 <cprintf>

	lapic_init();
f01001db:	e8 e5 59 00 00       	call   f0105bc5 <lapic_init>
	env_init_percpu();
f01001e0:	e8 48 2e 00 00       	call   f010302d <env_init_percpu>
	trap_init_percpu();
f01001e5:	e8 7e 36 00 00       	call   f0103868 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001ea:	e8 bb 59 00 00       	call   f0105baa <cpunum>
f01001ef:	6b d0 74             	imul   $0x74,%eax,%edx
f01001f2:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01001fd:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100201:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100208:	e8 0b 5c 00 00       	call   f0105e18 <spin_lock>
	//
	// Your code here:

	lock_kernel();
	// Remove this after you finish Exercise 6
	sched_yield ();
f010020d:	e8 e9 41 00 00       	call   f01043fb <sched_yield>

f0100212 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100212:	55                   	push   %ebp
f0100213:	89 e5                	mov    %esp,%ebp
f0100215:	53                   	push   %ebx
f0100216:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100219:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010021c:	ff 75 0c             	pushl  0xc(%ebp)
f010021f:	ff 75 08             	pushl  0x8(%ebp)
f0100222:	68 e9 62 10 f0       	push   $0xf01062e9
f0100227:	e8 28 36 00 00       	call   f0103854 <cprintf>
	vcprintf(fmt, ap);
f010022c:	83 c4 08             	add    $0x8,%esp
f010022f:	53                   	push   %ebx
f0100230:	ff 75 10             	pushl  0x10(%ebp)
f0100233:	e8 f6 35 00 00       	call   f010382e <vcprintf>
	cprintf("\n");
f0100238:	c7 04 24 e1 65 10 f0 	movl   $0xf01065e1,(%esp)
f010023f:	e8 10 36 00 00       	call   f0103854 <cprintf>
	va_end(ap);
}
f0100244:	83 c4 10             	add    $0x10,%esp
f0100247:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010024a:	c9                   	leave  
f010024b:	c3                   	ret    

f010024c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010024c:	55                   	push   %ebp
f010024d:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010024f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100254:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100255:	a8 01                	test   $0x1,%al
f0100257:	74 0b                	je     f0100264 <serial_proc_data+0x18>
f0100259:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010025e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010025f:	0f b6 c0             	movzbl %al,%eax
f0100262:	eb 05                	jmp    f0100269 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100269:	5d                   	pop    %ebp
f010026a:	c3                   	ret    

f010026b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010026b:	55                   	push   %ebp
f010026c:	89 e5                	mov    %esp,%ebp
f010026e:	53                   	push   %ebx
f010026f:	83 ec 04             	sub    $0x4,%esp
f0100272:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100274:	eb 2b                	jmp    f01002a1 <cons_intr+0x36>
		if (c == 0)
f0100276:	85 c0                	test   %eax,%eax
f0100278:	74 27                	je     f01002a1 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010027a:	8b 0d 24 f2 22 f0    	mov    0xf022f224,%ecx
f0100280:	8d 51 01             	lea    0x1(%ecx),%edx
f0100283:	89 15 24 f2 22 f0    	mov    %edx,0xf022f224
f0100289:	88 81 20 f0 22 f0    	mov    %al,-0xfdd0fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010028f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100295:	75 0a                	jne    f01002a1 <cons_intr+0x36>
			cons.wpos = 0;
f0100297:	c7 05 24 f2 22 f0 00 	movl   $0x0,0xf022f224
f010029e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002a1:	ff d3                	call   *%ebx
f01002a3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002a6:	75 ce                	jne    f0100276 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002a8:	83 c4 04             	add    $0x4,%esp
f01002ab:	5b                   	pop    %ebx
f01002ac:	5d                   	pop    %ebp
f01002ad:	c3                   	ret    

f01002ae <kbd_proc_data>:
f01002ae:	ba 64 00 00 00       	mov    $0x64,%edx
f01002b3:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002b4:	a8 01                	test   $0x1,%al
f01002b6:	0f 84 f8 00 00 00    	je     f01003b4 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002bc:	a8 20                	test   $0x20,%al
f01002be:	0f 85 f6 00 00 00    	jne    f01003ba <kbd_proc_data+0x10c>
f01002c4:	ba 60 00 00 00       	mov    $0x60,%edx
f01002c9:	ec                   	in     (%dx),%al
f01002ca:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002cc:	3c e0                	cmp    $0xe0,%al
f01002ce:	75 0d                	jne    f01002dd <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002d0:	83 0d 00 f0 22 f0 40 	orl    $0x40,0xf022f000
		return 0;
f01002d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01002dc:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002dd:	55                   	push   %ebp
f01002de:	89 e5                	mov    %esp,%ebp
f01002e0:	53                   	push   %ebx
f01002e1:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002e4:	84 c0                	test   %al,%al
f01002e6:	79 36                	jns    f010031e <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002e8:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f01002ee:	89 cb                	mov    %ecx,%ebx
f01002f0:	83 e3 40             	and    $0x40,%ebx
f01002f3:	83 e0 7f             	and    $0x7f,%eax
f01002f6:	85 db                	test   %ebx,%ebx
f01002f8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002fb:	0f b6 d2             	movzbl %dl,%edx
f01002fe:	0f b6 82 60 64 10 f0 	movzbl -0xfef9ba0(%edx),%eax
f0100305:	83 c8 40             	or     $0x40,%eax
f0100308:	0f b6 c0             	movzbl %al,%eax
f010030b:	f7 d0                	not    %eax
f010030d:	21 c8                	and    %ecx,%eax
f010030f:	a3 00 f0 22 f0       	mov    %eax,0xf022f000
		return 0;
f0100314:	b8 00 00 00 00       	mov    $0x0,%eax
f0100319:	e9 a4 00 00 00       	jmp    f01003c2 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010031e:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f0100324:	f6 c1 40             	test   $0x40,%cl
f0100327:	74 0e                	je     f0100337 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100329:	83 c8 80             	or     $0xffffff80,%eax
f010032c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010032e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100331:	89 0d 00 f0 22 f0    	mov    %ecx,0xf022f000
	}

	shift |= shiftcode[data];
f0100337:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010033a:	0f b6 82 60 64 10 f0 	movzbl -0xfef9ba0(%edx),%eax
f0100341:	0b 05 00 f0 22 f0    	or     0xf022f000,%eax
f0100347:	0f b6 8a 60 63 10 f0 	movzbl -0xfef9ca0(%edx),%ecx
f010034e:	31 c8                	xor    %ecx,%eax
f0100350:	a3 00 f0 22 f0       	mov    %eax,0xf022f000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100355:	89 c1                	mov    %eax,%ecx
f0100357:	83 e1 03             	and    $0x3,%ecx
f010035a:	8b 0c 8d 40 63 10 f0 	mov    -0xfef9cc0(,%ecx,4),%ecx
f0100361:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100365:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100368:	a8 08                	test   $0x8,%al
f010036a:	74 1b                	je     f0100387 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010036c:	89 da                	mov    %ebx,%edx
f010036e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100371:	83 f9 19             	cmp    $0x19,%ecx
f0100374:	77 05                	ja     f010037b <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f0100376:	83 eb 20             	sub    $0x20,%ebx
f0100379:	eb 0c                	jmp    f0100387 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010037b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010037e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100381:	83 fa 19             	cmp    $0x19,%edx
f0100384:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100387:	f7 d0                	not    %eax
f0100389:	a8 06                	test   $0x6,%al
f010038b:	75 33                	jne    f01003c0 <kbd_proc_data+0x112>
f010038d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100393:	75 2b                	jne    f01003c0 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100395:	83 ec 0c             	sub    $0xc,%esp
f0100398:	68 03 63 10 f0       	push   $0xf0106303
f010039d:	e8 b2 34 00 00       	call   f0103854 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a2:	ba 92 00 00 00       	mov    $0x92,%edx
f01003a7:	b8 03 00 00 00       	mov    $0x3,%eax
f01003ac:	ee                   	out    %al,(%dx)
f01003ad:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003b0:	89 d8                	mov    %ebx,%eax
f01003b2:	eb 0e                	jmp    f01003c2 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003b9:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003bf:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c0:	89 d8                	mov    %ebx,%eax
}
f01003c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003c5:	c9                   	leave  
f01003c6:	c3                   	ret    

f01003c7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003c7:	55                   	push   %ebp
f01003c8:	89 e5                	mov    %esp,%ebp
f01003ca:	57                   	push   %edi
f01003cb:	56                   	push   %esi
f01003cc:	53                   	push   %ebx
f01003cd:	83 ec 1c             	sub    $0x1c,%esp
f01003d0:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003d2:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003d7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003dc:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003e1:	eb 09                	jmp    f01003ec <cons_putc+0x25>
f01003e3:	89 ca                	mov    %ecx,%edx
f01003e5:	ec                   	in     (%dx),%al
f01003e6:	ec                   	in     (%dx),%al
f01003e7:	ec                   	in     (%dx),%al
f01003e8:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003e9:	83 c3 01             	add    $0x1,%ebx
f01003ec:	89 f2                	mov    %esi,%edx
f01003ee:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003ef:	a8 20                	test   $0x20,%al
f01003f1:	75 08                	jne    f01003fb <cons_putc+0x34>
f01003f3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003f9:	7e e8                	jle    f01003e3 <cons_putc+0x1c>
f01003fb:	89 f8                	mov    %edi,%eax
f01003fd:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100400:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100405:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100406:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010040b:	be 79 03 00 00       	mov    $0x379,%esi
f0100410:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100415:	eb 09                	jmp    f0100420 <cons_putc+0x59>
f0100417:	89 ca                	mov    %ecx,%edx
f0100419:	ec                   	in     (%dx),%al
f010041a:	ec                   	in     (%dx),%al
f010041b:	ec                   	in     (%dx),%al
f010041c:	ec                   	in     (%dx),%al
f010041d:	83 c3 01             	add    $0x1,%ebx
f0100420:	89 f2                	mov    %esi,%edx
f0100422:	ec                   	in     (%dx),%al
f0100423:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100429:	7f 04                	jg     f010042f <cons_putc+0x68>
f010042b:	84 c0                	test   %al,%al
f010042d:	79 e8                	jns    f0100417 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010042f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100434:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100438:	ee                   	out    %al,(%dx)
f0100439:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010043e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100443:	ee                   	out    %al,(%dx)
f0100444:	b8 08 00 00 00       	mov    $0x8,%eax
f0100449:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010044a:	89 fa                	mov    %edi,%edx
f010044c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100452:	89 f8                	mov    %edi,%eax
f0100454:	80 cc 07             	or     $0x7,%ah
f0100457:	85 d2                	test   %edx,%edx
f0100459:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010045c:	89 f8                	mov    %edi,%eax
f010045e:	0f b6 c0             	movzbl %al,%eax
f0100461:	83 f8 09             	cmp    $0x9,%eax
f0100464:	74 74                	je     f01004da <cons_putc+0x113>
f0100466:	83 f8 09             	cmp    $0x9,%eax
f0100469:	7f 0a                	jg     f0100475 <cons_putc+0xae>
f010046b:	83 f8 08             	cmp    $0x8,%eax
f010046e:	74 14                	je     f0100484 <cons_putc+0xbd>
f0100470:	e9 99 00 00 00       	jmp    f010050e <cons_putc+0x147>
f0100475:	83 f8 0a             	cmp    $0xa,%eax
f0100478:	74 3a                	je     f01004b4 <cons_putc+0xed>
f010047a:	83 f8 0d             	cmp    $0xd,%eax
f010047d:	74 3d                	je     f01004bc <cons_putc+0xf5>
f010047f:	e9 8a 00 00 00       	jmp    f010050e <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100484:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f010048b:	66 85 c0             	test   %ax,%ax
f010048e:	0f 84 e6 00 00 00    	je     f010057a <cons_putc+0x1b3>
			crt_pos--;
f0100494:	83 e8 01             	sub    $0x1,%eax
f0100497:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010049d:	0f b7 c0             	movzwl %ax,%eax
f01004a0:	66 81 e7 00 ff       	and    $0xff00,%di
f01004a5:	83 cf 20             	or     $0x20,%edi
f01004a8:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f01004ae:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004b2:	eb 78                	jmp    f010052c <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004b4:	66 83 05 28 f2 22 f0 	addw   $0x50,0xf022f228
f01004bb:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004bc:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f01004c3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004c9:	c1 e8 16             	shr    $0x16,%eax
f01004cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004cf:	c1 e0 04             	shl    $0x4,%eax
f01004d2:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
f01004d8:	eb 52                	jmp    f010052c <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004da:	b8 20 00 00 00       	mov    $0x20,%eax
f01004df:	e8 e3 fe ff ff       	call   f01003c7 <cons_putc>
		cons_putc(' ');
f01004e4:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e9:	e8 d9 fe ff ff       	call   f01003c7 <cons_putc>
		cons_putc(' ');
f01004ee:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f3:	e8 cf fe ff ff       	call   f01003c7 <cons_putc>
		cons_putc(' ');
f01004f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fd:	e8 c5 fe ff ff       	call   f01003c7 <cons_putc>
		cons_putc(' ');
f0100502:	b8 20 00 00 00       	mov    $0x20,%eax
f0100507:	e8 bb fe ff ff       	call   f01003c7 <cons_putc>
f010050c:	eb 1e                	jmp    f010052c <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010050e:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f0100515:	8d 50 01             	lea    0x1(%eax),%edx
f0100518:	66 89 15 28 f2 22 f0 	mov    %dx,0xf022f228
f010051f:	0f b7 c0             	movzwl %ax,%eax
f0100522:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f0100528:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010052c:	66 81 3d 28 f2 22 f0 	cmpw   $0x7cf,0xf022f228
f0100533:	cf 07 
f0100535:	76 43                	jbe    f010057a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100537:	a1 2c f2 22 f0       	mov    0xf022f22c,%eax
f010053c:	83 ec 04             	sub    $0x4,%esp
f010053f:	68 00 0f 00 00       	push   $0xf00
f0100544:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010054a:	52                   	push   %edx
f010054b:	50                   	push   %eax
f010054c:	e8 83 50 00 00       	call   f01055d4 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100551:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f0100557:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010055d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100563:	83 c4 10             	add    $0x10,%esp
f0100566:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010056b:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010056e:	39 d0                	cmp    %edx,%eax
f0100570:	75 f4                	jne    f0100566 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100572:	66 83 2d 28 f2 22 f0 	subw   $0x50,0xf022f228
f0100579:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010057a:	8b 0d 30 f2 22 f0    	mov    0xf022f230,%ecx
f0100580:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100585:	89 ca                	mov    %ecx,%edx
f0100587:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100588:	0f b7 1d 28 f2 22 f0 	movzwl 0xf022f228,%ebx
f010058f:	8d 71 01             	lea    0x1(%ecx),%esi
f0100592:	89 d8                	mov    %ebx,%eax
f0100594:	66 c1 e8 08          	shr    $0x8,%ax
f0100598:	89 f2                	mov    %esi,%edx
f010059a:	ee                   	out    %al,(%dx)
f010059b:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a0:	89 ca                	mov    %ecx,%edx
f01005a2:	ee                   	out    %al,(%dx)
f01005a3:	89 d8                	mov    %ebx,%eax
f01005a5:	89 f2                	mov    %esi,%edx
f01005a7:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005ab:	5b                   	pop    %ebx
f01005ac:	5e                   	pop    %esi
f01005ad:	5f                   	pop    %edi
f01005ae:	5d                   	pop    %ebp
f01005af:	c3                   	ret    

f01005b0 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005b0:	80 3d 34 f2 22 f0 00 	cmpb   $0x0,0xf022f234
f01005b7:	74 11                	je     f01005ca <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005b9:	55                   	push   %ebp
f01005ba:	89 e5                	mov    %esp,%ebp
f01005bc:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005bf:	b8 4c 02 10 f0       	mov    $0xf010024c,%eax
f01005c4:	e8 a2 fc ff ff       	call   f010026b <cons_intr>
}
f01005c9:	c9                   	leave  
f01005ca:	f3 c3                	repz ret 

f01005cc <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005cc:	55                   	push   %ebp
f01005cd:	89 e5                	mov    %esp,%ebp
f01005cf:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005d2:	b8 ae 02 10 f0       	mov    $0xf01002ae,%eax
f01005d7:	e8 8f fc ff ff       	call   f010026b <cons_intr>
}
f01005dc:	c9                   	leave  
f01005dd:	c3                   	ret    

f01005de <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005de:	55                   	push   %ebp
f01005df:	89 e5                	mov    %esp,%ebp
f01005e1:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005e4:	e8 c7 ff ff ff       	call   f01005b0 <serial_intr>
	kbd_intr();
f01005e9:	e8 de ff ff ff       	call   f01005cc <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005ee:	a1 20 f2 22 f0       	mov    0xf022f220,%eax
f01005f3:	3b 05 24 f2 22 f0    	cmp    0xf022f224,%eax
f01005f9:	74 26                	je     f0100621 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01005fb:	8d 50 01             	lea    0x1(%eax),%edx
f01005fe:	89 15 20 f2 22 f0    	mov    %edx,0xf022f220
f0100604:	0f b6 88 20 f0 22 f0 	movzbl -0xfdd0fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010060b:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010060d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100613:	75 11                	jne    f0100626 <cons_getc+0x48>
			cons.rpos = 0;
f0100615:	c7 05 20 f2 22 f0 00 	movl   $0x0,0xf022f220
f010061c:	00 00 00 
f010061f:	eb 05                	jmp    f0100626 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100621:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100626:	c9                   	leave  
f0100627:	c3                   	ret    

f0100628 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100628:	55                   	push   %ebp
f0100629:	89 e5                	mov    %esp,%ebp
f010062b:	57                   	push   %edi
f010062c:	56                   	push   %esi
f010062d:	53                   	push   %ebx
f010062e:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100631:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100638:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010063f:	5a a5 
	if (*cp != 0xA55A) {
f0100641:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100648:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010064c:	74 11                	je     f010065f <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010064e:	c7 05 30 f2 22 f0 b4 	movl   $0x3b4,0xf022f230
f0100655:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100658:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010065d:	eb 16                	jmp    f0100675 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010065f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100666:	c7 05 30 f2 22 f0 d4 	movl   $0x3d4,0xf022f230
f010066d:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100670:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100675:	8b 3d 30 f2 22 f0    	mov    0xf022f230,%edi
f010067b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100680:	89 fa                	mov    %edi,%edx
f0100682:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100683:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100686:	89 da                	mov    %ebx,%edx
f0100688:	ec                   	in     (%dx),%al
f0100689:	0f b6 c8             	movzbl %al,%ecx
f010068c:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100694:	89 fa                	mov    %edi,%edx
f0100696:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100697:	89 da                	mov    %ebx,%edx
f0100699:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010069a:	89 35 2c f2 22 f0    	mov    %esi,0xf022f22c
	crt_pos = pos;
f01006a0:	0f b6 c0             	movzbl %al,%eax
f01006a3:	09 c8                	or     %ecx,%eax
f01006a5:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006ab:	e8 1c ff ff ff       	call   f01005cc <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006b0:	83 ec 0c             	sub    $0xc,%esp
f01006b3:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006ba:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006bf:	50                   	push   %eax
f01006c0:	e8 3e 30 00 00       	call   f0103703 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c5:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01006cf:	89 f2                	mov    %esi,%edx
f01006d1:	ee                   	out    %al,(%dx)
f01006d2:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006d7:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006dc:	ee                   	out    %al,(%dx)
f01006dd:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006e2:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006e7:	89 da                	mov    %ebx,%edx
f01006e9:	ee                   	out    %al,(%dx)
f01006ea:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f4:	ee                   	out    %al,(%dx)
f01006f5:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006fa:	b8 03 00 00 00       	mov    $0x3,%eax
f01006ff:	ee                   	out    %al,(%dx)
f0100700:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100705:	b8 00 00 00 00       	mov    $0x0,%eax
f010070a:	ee                   	out    %al,(%dx)
f010070b:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100710:	b8 01 00 00 00       	mov    $0x1,%eax
f0100715:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100716:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010071b:	ec                   	in     (%dx),%al
f010071c:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010071e:	83 c4 10             	add    $0x10,%esp
f0100721:	3c ff                	cmp    $0xff,%al
f0100723:	0f 95 05 34 f2 22 f0 	setne  0xf022f234
f010072a:	89 f2                	mov    %esi,%edx
f010072c:	ec                   	in     (%dx),%al
f010072d:	89 da                	mov    %ebx,%edx
f010072f:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100730:	80 f9 ff             	cmp    $0xff,%cl
f0100733:	75 10                	jne    f0100745 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f0100735:	83 ec 0c             	sub    $0xc,%esp
f0100738:	68 0f 63 10 f0       	push   $0xf010630f
f010073d:	e8 12 31 00 00       	call   f0103854 <cprintf>
f0100742:	83 c4 10             	add    $0x10,%esp
}
f0100745:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100748:	5b                   	pop    %ebx
f0100749:	5e                   	pop    %esi
f010074a:	5f                   	pop    %edi
f010074b:	5d                   	pop    %ebp
f010074c:	c3                   	ret    

f010074d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010074d:	55                   	push   %ebp
f010074e:	89 e5                	mov    %esp,%ebp
f0100750:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100753:	8b 45 08             	mov    0x8(%ebp),%eax
f0100756:	e8 6c fc ff ff       	call   f01003c7 <cons_putc>
}
f010075b:	c9                   	leave  
f010075c:	c3                   	ret    

f010075d <getchar>:

int
getchar(void)
{
f010075d:	55                   	push   %ebp
f010075e:	89 e5                	mov    %esp,%ebp
f0100760:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100763:	e8 76 fe ff ff       	call   f01005de <cons_getc>
f0100768:	85 c0                	test   %eax,%eax
f010076a:	74 f7                	je     f0100763 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010076c:	c9                   	leave  
f010076d:	c3                   	ret    

f010076e <iscons>:

int
iscons(int fdnum)
{
f010076e:	55                   	push   %ebp
f010076f:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100771:	b8 01 00 00 00       	mov    $0x1,%eax
f0100776:	5d                   	pop    %ebp
f0100777:	c3                   	ret    

f0100778 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

	   int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100778:	55                   	push   %ebp
f0100779:	89 e5                	mov    %esp,%ebp
f010077b:	83 ec 0c             	sub    $0xc,%esp
	   int i;

	   for (i = 0; i < ARRAY_SIZE(commands); i++)
			 cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010077e:	68 60 65 10 f0       	push   $0xf0106560
f0100783:	68 7e 65 10 f0       	push   $0xf010657e
f0100788:	68 83 65 10 f0       	push   $0xf0106583
f010078d:	e8 c2 30 00 00       	call   f0103854 <cprintf>
f0100792:	83 c4 0c             	add    $0xc,%esp
f0100795:	68 50 66 10 f0       	push   $0xf0106650
f010079a:	68 8c 65 10 f0       	push   $0xf010658c
f010079f:	68 83 65 10 f0       	push   $0xf0106583
f01007a4:	e8 ab 30 00 00       	call   f0103854 <cprintf>
f01007a9:	83 c4 0c             	add    $0xc,%esp
f01007ac:	68 95 65 10 f0       	push   $0xf0106595
f01007b1:	68 ad 65 10 f0       	push   $0xf01065ad
f01007b6:	68 83 65 10 f0       	push   $0xf0106583
f01007bb:	e8 94 30 00 00       	call   f0103854 <cprintf>
	   return 0;
}
f01007c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c5:	c9                   	leave  
f01007c6:	c3                   	ret    

f01007c7 <mon_kerninfo>:

	   int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007c7:	55                   	push   %ebp
f01007c8:	89 e5                	mov    %esp,%ebp
f01007ca:	83 ec 14             	sub    $0x14,%esp
	   extern char _start[], entry[], etext[], edata[], end[];

	   cprintf("Special kernel symbols:\n");
f01007cd:	68 b7 65 10 f0       	push   $0xf01065b7
f01007d2:	e8 7d 30 00 00       	call   f0103854 <cprintf>
	   cprintf("  _start                  %08x (phys)\n", _start);
f01007d7:	83 c4 08             	add    $0x8,%esp
f01007da:	68 0c 00 10 00       	push   $0x10000c
f01007df:	68 78 66 10 f0       	push   $0xf0106678
f01007e4:	e8 6b 30 00 00       	call   f0103854 <cprintf>
	   cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e9:	83 c4 0c             	add    $0xc,%esp
f01007ec:	68 0c 00 10 00       	push   $0x10000c
f01007f1:	68 0c 00 10 f0       	push   $0xf010000c
f01007f6:	68 a0 66 10 f0       	push   $0xf01066a0
f01007fb:	e8 54 30 00 00       	call   f0103854 <cprintf>
	   cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	68 31 62 10 00       	push   $0x106231
f0100808:	68 31 62 10 f0       	push   $0xf0106231
f010080d:	68 c4 66 10 f0       	push   $0xf01066c4
f0100812:	e8 3d 30 00 00       	call   f0103854 <cprintf>
	   cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100817:	83 c4 0c             	add    $0xc,%esp
f010081a:	68 00 f0 22 00       	push   $0x22f000
f010081f:	68 00 f0 22 f0       	push   $0xf022f000
f0100824:	68 e8 66 10 f0       	push   $0xf01066e8
f0100829:	e8 26 30 00 00       	call   f0103854 <cprintf>
	   cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010082e:	83 c4 0c             	add    $0xc,%esp
f0100831:	68 08 10 27 00       	push   $0x271008
f0100836:	68 08 10 27 f0       	push   $0xf0271008
f010083b:	68 0c 67 10 f0       	push   $0xf010670c
f0100840:	e8 0f 30 00 00       	call   f0103854 <cprintf>
	   cprintf("Kernel executable memory footprint: %dKB\n",
				    ROUNDUP(end - entry, 1024) / 1024);
f0100845:	b8 07 14 27 f0       	mov    $0xf0271407,%eax
f010084a:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	   cprintf("  _start                  %08x (phys)\n", _start);
	   cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	   cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	   cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	   cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	   cprintf("Kernel executable memory footprint: %dKB\n",
f010084f:	83 c4 08             	add    $0x8,%esp
f0100852:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100857:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010085d:	85 c0                	test   %eax,%eax
f010085f:	0f 48 c2             	cmovs  %edx,%eax
f0100862:	c1 f8 0a             	sar    $0xa,%eax
f0100865:	50                   	push   %eax
f0100866:	68 30 67 10 f0       	push   $0xf0106730
f010086b:	e8 e4 2f 00 00       	call   f0103854 <cprintf>
				    ROUNDUP(end - entry, 1024) / 1024);
	   return 0;
}
f0100870:	b8 00 00 00 00       	mov    $0x0,%eax
f0100875:	c9                   	leave  
f0100876:	c3                   	ret    

f0100877 <mon_backtrace>:
	   int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100877:	55                   	push   %ebp
f0100878:	89 e5                	mov    %esp,%ebp
f010087a:	57                   	push   %edi
f010087b:	56                   	push   %esi
f010087c:	53                   	push   %ebx
f010087d:	83 ec 48             	sub    $0x48,%esp
	   // Your code here.

	   uint32_t func_ebp = 0, ueip = 0, arg = 0;
	   asm volatile("movl %%ebp,%0" : "=r" (func_ebp));
f0100880:	89 ee                	mov    %ebp,%esi
	   cprintf("Stack Backtrace: \n");
f0100882:	68 d0 65 10 f0       	push   $0xf01065d0
f0100887:	e8 c8 2f 00 00       	call   f0103854 <cprintf>
	   uint32_t baseframe = func_ebp;
	   while(baseframe != 0)
f010088c:	83 c4 10             	add    $0x10,%esp
f010088f:	e9 80 00 00 00       	jmp    f0100914 <mon_backtrace+0x9d>
	   {
			 ueip = *((uint32_t *)baseframe + 1);
f0100894:	8b 46 04             	mov    0x4(%esi),%eax
f0100897:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			 cprintf("ebp %08x eip %08x args ", baseframe, ueip);
f010089a:	83 ec 04             	sub    $0x4,%esp
f010089d:	50                   	push   %eax
f010089e:	56                   	push   %esi
f010089f:	68 e3 65 10 f0       	push   $0xf01065e3
f01008a4:	e8 ab 2f 00 00       	call   f0103854 <cprintf>
f01008a9:	8d 5e 08             	lea    0x8(%esi),%ebx
f01008ac:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01008af:	83 c4 10             	add    $0x10,%esp
			 for (int i = 2; i < 7; i ++)
			 {
				    arg = *((uint32_t*) baseframe + i);
				    cprintf(" %08x ", arg);
f01008b2:	83 ec 08             	sub    $0x8,%esp
f01008b5:	ff 33                	pushl  (%ebx)
f01008b7:	68 fb 65 10 f0       	push   $0xf01065fb
f01008bc:	e8 93 2f 00 00       	call   f0103854 <cprintf>
f01008c1:	83 c3 04             	add    $0x4,%ebx
	   uint32_t baseframe = func_ebp;
	   while(baseframe != 0)
	   {
			 ueip = *((uint32_t *)baseframe + 1);
			 cprintf("ebp %08x eip %08x args ", baseframe, ueip);
			 for (int i = 2; i < 7; i ++)
f01008c4:	83 c4 10             	add    $0x10,%esp
f01008c7:	39 fb                	cmp    %edi,%ebx
f01008c9:	75 e7                	jne    f01008b2 <mon_backtrace+0x3b>
			 {
				    arg = *((uint32_t*) baseframe + i);
				    cprintf(" %08x ", arg);
			 }

			 cprintf("\n");
f01008cb:	83 ec 0c             	sub    $0xc,%esp
f01008ce:	68 e1 65 10 f0       	push   $0xf01065e1
f01008d3:	e8 7c 2f 00 00       	call   f0103854 <cprintf>
			 struct Eipdebuginfo information;
			 debuginfo_eip (ueip, &information);
f01008d8:	83 c4 08             	add    $0x8,%esp
f01008db:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008de:	50                   	push   %eax
f01008df:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01008e2:	53                   	push   %ebx
f01008e3:	e8 9e 42 00 00       	call   f0104b86 <debuginfo_eip>
			 uintptr_t offset = ueip - information.eip_fn_addr;
f01008e8:	2b 5d e0             	sub    -0x20(%ebp),%ebx
			 cprintf("\t%s:%d: ", information.eip_file, information.eip_line);
f01008eb:	83 c4 0c             	add    $0xc,%esp
f01008ee:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008f1:	ff 75 d0             	pushl  -0x30(%ebp)
f01008f4:	68 02 66 10 f0       	push   $0xf0106602
f01008f9:	e8 56 2f 00 00       	call   f0103854 <cprintf>
			 cprintf("%.*s+%d\n",information.eip_fn_namelen, information.eip_fn_name, offset);
f01008fe:	53                   	push   %ebx
f01008ff:	ff 75 d8             	pushl  -0x28(%ebp)
f0100902:	ff 75 dc             	pushl  -0x24(%ebp)
f0100905:	68 0b 66 10 f0       	push   $0xf010660b
f010090a:	e8 45 2f 00 00       	call   f0103854 <cprintf>

			 baseframe = *(uint32_t *) baseframe;
f010090f:	8b 36                	mov    (%esi),%esi
f0100911:	83 c4 20             	add    $0x20,%esp

	   uint32_t func_ebp = 0, ueip = 0, arg = 0;
	   asm volatile("movl %%ebp,%0" : "=r" (func_ebp));
	   cprintf("Stack Backtrace: \n");
	   uint32_t baseframe = func_ebp;
	   while(baseframe != 0)
f0100914:	85 f6                	test   %esi,%esi
f0100916:	0f 85 78 ff ff ff    	jne    f0100894 <mon_backtrace+0x1d>


	   }

	   return 0;
}
f010091c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100921:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100924:	5b                   	pop    %ebx
f0100925:	5e                   	pop    %esi
f0100926:	5f                   	pop    %edi
f0100927:	5d                   	pop    %ebp
f0100928:	c3                   	ret    

f0100929 <monitor>:
	   return 0;
}

	   void
monitor(struct Trapframe *tf)
{
f0100929:	55                   	push   %ebp
f010092a:	89 e5                	mov    %esp,%ebp
f010092c:	57                   	push   %edi
f010092d:	56                   	push   %esi
f010092e:	53                   	push   %ebx
f010092f:	83 ec 58             	sub    $0x58,%esp
	   char *buf;

	   cprintf("Welcome to the JOS kernel monitor!\n");
f0100932:	68 5c 67 10 f0       	push   $0xf010675c
f0100937:	e8 18 2f 00 00       	call   f0103854 <cprintf>
	   cprintf("Type 'help' for a list of commands.\n");
f010093c:	c7 04 24 80 67 10 f0 	movl   $0xf0106780,(%esp)
f0100943:	e8 0c 2f 00 00       	call   f0103854 <cprintf>

	if (tf != NULL)
f0100948:	83 c4 10             	add    $0x10,%esp
f010094b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010094f:	74 0e                	je     f010095f <monitor+0x36>
		print_trapframe(tf);
f0100951:	83 ec 0c             	sub    $0xc,%esp
f0100954:	ff 75 08             	pushl  0x8(%ebp)
f0100957:	e8 11 34 00 00       	call   f0103d6d <print_trapframe>
f010095c:	83 c4 10             	add    $0x10,%esp

	   while (1) {
			 buf = readline("K> ");
f010095f:	83 ec 0c             	sub    $0xc,%esp
f0100962:	68 14 66 10 f0       	push   $0xf0106614
f0100967:	e8 c4 49 00 00       	call   f0105330 <readline>
f010096c:	89 c3                	mov    %eax,%ebx
			 if (buf != NULL)
f010096e:	83 c4 10             	add    $0x10,%esp
f0100971:	85 c0                	test   %eax,%eax
f0100973:	74 ea                	je     f010095f <monitor+0x36>
	   char *argv[MAXARGS];
	   int i;

	   // Parse the command buffer into whitespace-separated arguments
	   argc = 0;
	   argv[argc] = 0;
f0100975:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	   int argc;
	   char *argv[MAXARGS];
	   int i;

	   // Parse the command buffer into whitespace-separated arguments
	   argc = 0;
f010097c:	be 00 00 00 00       	mov    $0x0,%esi
f0100981:	eb 0a                	jmp    f010098d <monitor+0x64>
	   argv[argc] = 0;
	   while (1) {
			 // gobble whitespace
			 while (*buf && strchr(WHITESPACE, *buf))
				    *buf++ = 0;
f0100983:	c6 03 00             	movb   $0x0,(%ebx)
f0100986:	89 f7                	mov    %esi,%edi
f0100988:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010098b:	89 fe                	mov    %edi,%esi
	   // Parse the command buffer into whitespace-separated arguments
	   argc = 0;
	   argv[argc] = 0;
	   while (1) {
			 // gobble whitespace
			 while (*buf && strchr(WHITESPACE, *buf))
f010098d:	0f b6 03             	movzbl (%ebx),%eax
f0100990:	84 c0                	test   %al,%al
f0100992:	74 63                	je     f01009f7 <monitor+0xce>
f0100994:	83 ec 08             	sub    $0x8,%esp
f0100997:	0f be c0             	movsbl %al,%eax
f010099a:	50                   	push   %eax
f010099b:	68 18 66 10 f0       	push   $0xf0106618
f01009a0:	e8 a5 4b 00 00       	call   f010554a <strchr>
f01009a5:	83 c4 10             	add    $0x10,%esp
f01009a8:	85 c0                	test   %eax,%eax
f01009aa:	75 d7                	jne    f0100983 <monitor+0x5a>
				    *buf++ = 0;
			 if (*buf == 0)
f01009ac:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009af:	74 46                	je     f01009f7 <monitor+0xce>
				    break;

			 // save and scan past next arg
			 if (argc == MAXARGS-1) {
f01009b1:	83 fe 0f             	cmp    $0xf,%esi
f01009b4:	75 14                	jne    f01009ca <monitor+0xa1>
				    cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009b6:	83 ec 08             	sub    $0x8,%esp
f01009b9:	6a 10                	push   $0x10
f01009bb:	68 1d 66 10 f0       	push   $0xf010661d
f01009c0:	e8 8f 2e 00 00       	call   f0103854 <cprintf>
f01009c5:	83 c4 10             	add    $0x10,%esp
f01009c8:	eb 95                	jmp    f010095f <monitor+0x36>
				    return 0;
			 }
			 argv[argc++] = buf;
f01009ca:	8d 7e 01             	lea    0x1(%esi),%edi
f01009cd:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009d1:	eb 03                	jmp    f01009d6 <monitor+0xad>
			 while (*buf && !strchr(WHITESPACE, *buf))
				    buf++;
f01009d3:	83 c3 01             	add    $0x1,%ebx
			 if (argc == MAXARGS-1) {
				    cprintf("Too many arguments (max %d)\n", MAXARGS);
				    return 0;
			 }
			 argv[argc++] = buf;
			 while (*buf && !strchr(WHITESPACE, *buf))
f01009d6:	0f b6 03             	movzbl (%ebx),%eax
f01009d9:	84 c0                	test   %al,%al
f01009db:	74 ae                	je     f010098b <monitor+0x62>
f01009dd:	83 ec 08             	sub    $0x8,%esp
f01009e0:	0f be c0             	movsbl %al,%eax
f01009e3:	50                   	push   %eax
f01009e4:	68 18 66 10 f0       	push   $0xf0106618
f01009e9:	e8 5c 4b 00 00       	call   f010554a <strchr>
f01009ee:	83 c4 10             	add    $0x10,%esp
f01009f1:	85 c0                	test   %eax,%eax
f01009f3:	74 de                	je     f01009d3 <monitor+0xaa>
f01009f5:	eb 94                	jmp    f010098b <monitor+0x62>
				    buf++;
	   }
	   argv[argc] = 0;
f01009f7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009fe:	00 

	   // Lookup and invoke the command
	   if (argc == 0)
f01009ff:	85 f6                	test   %esi,%esi
f0100a01:	0f 84 58 ff ff ff    	je     f010095f <monitor+0x36>
f0100a07:	bb 00 00 00 00       	mov    $0x0,%ebx
			 return 0;
	   for (i = 0; i < ARRAY_SIZE(commands); i++) {
			 if (strcmp(argv[0], commands[i].name) == 0)
f0100a0c:	83 ec 08             	sub    $0x8,%esp
f0100a0f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a12:	ff 34 85 c0 67 10 f0 	pushl  -0xfef9840(,%eax,4)
f0100a19:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a1c:	e8 cb 4a 00 00       	call   f01054ec <strcmp>
f0100a21:	83 c4 10             	add    $0x10,%esp
f0100a24:	85 c0                	test   %eax,%eax
f0100a26:	75 21                	jne    f0100a49 <monitor+0x120>
				    return commands[i].func(argc, argv, tf);
f0100a28:	83 ec 04             	sub    $0x4,%esp
f0100a2b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a2e:	ff 75 08             	pushl  0x8(%ebp)
f0100a31:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a34:	52                   	push   %edx
f0100a35:	56                   	push   %esi
f0100a36:	ff 14 85 c8 67 10 f0 	call   *-0xfef9838(,%eax,4)
		print_trapframe(tf);

	   while (1) {
			 buf = readline("K> ");
			 if (buf != NULL)
				    if (runcmd(buf, tf) < 0)
f0100a3d:	83 c4 10             	add    $0x10,%esp
f0100a40:	85 c0                	test   %eax,%eax
f0100a42:	78 25                	js     f0100a69 <monitor+0x140>
f0100a44:	e9 16 ff ff ff       	jmp    f010095f <monitor+0x36>
	   argv[argc] = 0;

	   // Lookup and invoke the command
	   if (argc == 0)
			 return 0;
	   for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a49:	83 c3 01             	add    $0x1,%ebx
f0100a4c:	83 fb 03             	cmp    $0x3,%ebx
f0100a4f:	75 bb                	jne    f0100a0c <monitor+0xe3>
			 if (strcmp(argv[0], commands[i].name) == 0)
				    return commands[i].func(argc, argv, tf);
	   }
	   cprintf("Unknown command '%s'\n", argv[0]);
f0100a51:	83 ec 08             	sub    $0x8,%esp
f0100a54:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a57:	68 3a 66 10 f0       	push   $0xf010663a
f0100a5c:	e8 f3 2d 00 00       	call   f0103854 <cprintf>
f0100a61:	83 c4 10             	add    $0x10,%esp
f0100a64:	e9 f6 fe ff ff       	jmp    f010095f <monitor+0x36>
			 buf = readline("K> ");
			 if (buf != NULL)
				    if (runcmd(buf, tf) < 0)
						  break;
	   }
}
f0100a69:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a6c:	5b                   	pop    %ebx
f0100a6d:	5e                   	pop    %esi
f0100a6e:	5f                   	pop    %edi
f0100a6f:	5d                   	pop    %ebp
f0100a70:	c3                   	ret    

f0100a71 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

	   static int
nvram_read(int r)
{
f0100a71:	55                   	push   %ebp
f0100a72:	89 e5                	mov    %esp,%ebp
f0100a74:	56                   	push   %esi
f0100a75:	53                   	push   %ebx
f0100a76:	89 c3                	mov    %eax,%ebx
	   return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a78:	83 ec 0c             	sub    $0xc,%esp
f0100a7b:	50                   	push   %eax
f0100a7c:	e8 54 2c 00 00       	call   f01036d5 <mc146818_read>
f0100a81:	89 c6                	mov    %eax,%esi
f0100a83:	83 c3 01             	add    $0x1,%ebx
f0100a86:	89 1c 24             	mov    %ebx,(%esp)
f0100a89:	e8 47 2c 00 00       	call   f01036d5 <mc146818_read>
f0100a8e:	c1 e0 08             	shl    $0x8,%eax
f0100a91:	09 f0                	or     %esi,%eax
}
f0100a93:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a96:	5b                   	pop    %ebx
f0100a97:	5e                   	pop    %esi
f0100a98:	5d                   	pop    %ebp
f0100a99:	c3                   	ret    

f0100a9a <boot_alloc>:
	   // Initialize nextfree if this is the first time.
	   // 'end' is a magic symbol automatically generated by the linker,
	   // which points to the end of the kernel's bss segment:
	   // the first virtual address that the linker did *not* assign
	   // to any kernel code or global variables.
	   if (!nextfree) {
f0100a9a:	83 3d 38 f2 22 f0 00 	cmpl   $0x0,0xf022f238
f0100aa1:	75 11                	jne    f0100ab4 <boot_alloc+0x1a>
			 extern char end[];
			 nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aa3:	ba 07 20 27 f0       	mov    $0xf0272007,%edx
f0100aa8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aae:	89 15 38 f2 22 f0    	mov    %edx,0xf022f238
	   }

	   result = nextfree;
f0100ab4:	8b 0d 38 f2 22 f0    	mov    0xf022f238,%ecx
	   // nextfree.  Make sure nextfree is kept aligned
	   // to a multiple of PGSIZE.
	   //
	   // LAB 2: Your code here.

	   nextfree = ROUNDUP ( result + n, PGSIZE);
f0100aba:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100ac1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ac7:	89 15 38 f2 22 f0    	mov    %edx,0xf022f238
	   if ((uintptr_t)nextfree >= (KERNBASE + PTSIZE))
f0100acd:	81 fa ff ff 3f f0    	cmp    $0xf03fffff,%edx
f0100ad3:	76 25                	jbe    f0100afa <boot_alloc+0x60>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
	   static void *
boot_alloc(uint32_t n)
{
f0100ad5:	55                   	push   %ebp
f0100ad6:	89 e5                	mov    %esp,%ebp
f0100ad8:	53                   	push   %ebx
f0100ad9:	83 ec 10             	sub    $0x10,%esp
f0100adc:	89 c3                	mov    %eax,%ebx
	   // LAB 2: Your code here.

	   nextfree = ROUNDUP ( result + n, PGSIZE);
	   if ((uintptr_t)nextfree >= (KERNBASE + PTSIZE))
	   {
			 cprintf("OUT OF MEMORY");
f0100ade:	68 e4 67 10 f0       	push   $0xf01067e4
f0100ae3:	e8 6c 2d 00 00       	call   f0103854 <cprintf>
			 panic ("boot alloc Failed to allocate %d bytes", n);
f0100ae8:	53                   	push   %ebx
f0100ae9:	68 60 6b 10 f0       	push   $0xf0106b60
f0100aee:	6a 73                	push   $0x73
f0100af0:	68 f2 67 10 f0       	push   $0xf01067f2
f0100af5:	e8 46 f5 ff ff       	call   f0100040 <_panic>
	   }

	   return result;
}
f0100afa:	89 c8                	mov    %ecx,%eax
f0100afc:	c3                   	ret    

f0100afd <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	   pte_t *p;

	   pgdir = &pgdir[PDX(va)];
	   if (!(*pgdir & PTE_P))
f0100afd:	89 d1                	mov    %edx,%ecx
f0100aff:	c1 e9 16             	shr    $0x16,%ecx
f0100b02:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b05:	a8 01                	test   $0x1,%al
f0100b07:	74 52                	je     f0100b5b <check_va2pa+0x5e>
			 return ~0;
	   p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b0e:	89 c1                	mov    %eax,%ecx
f0100b10:	c1 e9 0c             	shr    $0xc,%ecx
f0100b13:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0100b19:	72 1b                	jb     f0100b36 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

	   static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b1b:	55                   	push   %ebp
f0100b1c:	89 e5                	mov    %esp,%ebp
f0100b1e:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b21:	50                   	push   %eax
f0100b22:	68 64 62 10 f0       	push   $0xf0106264
f0100b27:	68 af 03 00 00       	push   $0x3af
f0100b2c:	68 f2 67 10 f0       	push   $0xf01067f2
f0100b31:	e8 0a f5 ff ff       	call   f0100040 <_panic>

	   pgdir = &pgdir[PDX(va)];
	   if (!(*pgdir & PTE_P))
			 return ~0;
	   p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	   if (!(p[PTX(va)] & PTE_P))
f0100b36:	c1 ea 0c             	shr    $0xc,%edx
f0100b39:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b3f:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b46:	89 c2                	mov    %eax,%edx
f0100b48:	83 e2 01             	and    $0x1,%edx
			 return ~0;
	   return PTE_ADDR(p[PTX(va)]);
f0100b4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b50:	85 d2                	test   %edx,%edx
f0100b52:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b57:	0f 44 c2             	cmove  %edx,%eax
f0100b5a:	c3                   	ret    
{
	   pte_t *p;

	   pgdir = &pgdir[PDX(va)];
	   if (!(*pgdir & PTE_P))
			 return ~0;
f0100b5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	   p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	   if (!(p[PTX(va)] & PTE_P))
			 return ~0;
	   return PTE_ADDR(p[PTX(va)]);
}
f0100b60:	c3                   	ret    

f0100b61 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
	   static void
check_page_free_list(bool only_low_memory)
{
f0100b61:	55                   	push   %ebp
f0100b62:	89 e5                	mov    %esp,%ebp
f0100b64:	57                   	push   %edi
f0100b65:	56                   	push   %esi
f0100b66:	53                   	push   %ebx
f0100b67:	83 ec 2c             	sub    $0x2c,%esp

	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b6a:	84 c0                	test   %al,%al
f0100b6c:	0f 85 a0 02 00 00    	jne    f0100e12 <check_page_free_list+0x2b1>
f0100b72:	e9 ad 02 00 00       	jmp    f0100e24 <check_page_free_list+0x2c3>
	   int nfree_basemem = 0, nfree_extmem = 0;
	   char *first_free_page;

	   if (!page_free_list)
			 panic("'page_free_list' is a null pointer!");
f0100b77:	83 ec 04             	sub    $0x4,%esp
f0100b7a:	68 88 6b 10 f0       	push   $0xf0106b88
f0100b7f:	68 e1 02 00 00       	push   $0x2e1
f0100b84:	68 f2 67 10 f0       	push   $0xf01067f2
f0100b89:	e8 b2 f4 ff ff       	call   f0100040 <_panic>

	   if (only_low_memory) {
			 // Move pages with lower addresses first in the free
			 // list, since entry_pgdir does not map all pages.
			 struct PageInfo *pp1, *pp2;
			 struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b8e:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b91:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b94:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b97:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			 for (pp = page_free_list; pp; pp = pp->pp_link) {
				    int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b9a:	89 c2                	mov    %eax,%edx
f0100b9c:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0100ba2:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ba8:	0f 95 c2             	setne  %dl
f0100bab:	0f b6 d2             	movzbl %dl,%edx
				    *tp[pagetype] = pp;
f0100bae:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bb2:	89 01                	mov    %eax,(%ecx)
				    tp[pagetype] = &pp->pp_link;
f0100bb4:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	   if (only_low_memory) {
			 // Move pages with lower addresses first in the free
			 // list, since entry_pgdir does not map all pages.
			 struct PageInfo *pp1, *pp2;
			 struct PageInfo **tp[2] = { &pp1, &pp2 };
			 for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bb8:	8b 00                	mov    (%eax),%eax
f0100bba:	85 c0                	test   %eax,%eax
f0100bbc:	75 dc                	jne    f0100b9a <check_page_free_list+0x39>
				    int pagetype = PDX(page2pa(pp)) >= pdx_limit;
				    *tp[pagetype] = pp;
				    tp[pagetype] = &pp->pp_link;
			 }
			 *tp[1] = 0;
f0100bbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bc1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			 *tp[0] = pp2;
f0100bc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bca:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bcd:	89 10                	mov    %edx,(%eax)
			 page_free_list = pp1;
f0100bcf:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bd2:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
	   static void
check_page_free_list(bool only_low_memory)
{

	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bd7:	be 01 00 00 00       	mov    $0x1,%esi
			 page_free_list = pp1;
	   }

	   // if there's a page that shouldn't be on the free list,
	   // try to make sure it eventually causes trouble.
	   for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bdc:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
f0100be2:	eb 53                	jmp    f0100c37 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100be4:	89 d8                	mov    %ebx,%eax
f0100be6:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0100bec:	c1 f8 03             	sar    $0x3,%eax
f0100bef:	c1 e0 0c             	shl    $0xc,%eax
			 if (PDX(page2pa(pp)) < pdx_limit)
f0100bf2:	89 c2                	mov    %eax,%edx
f0100bf4:	c1 ea 16             	shr    $0x16,%edx
f0100bf7:	39 f2                	cmp    %esi,%edx
f0100bf9:	73 3a                	jae    f0100c35 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bfb:	89 c2                	mov    %eax,%edx
f0100bfd:	c1 ea 0c             	shr    $0xc,%edx
f0100c00:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0100c06:	72 12                	jb     f0100c1a <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c08:	50                   	push   %eax
f0100c09:	68 64 62 10 f0       	push   $0xf0106264
f0100c0e:	6a 58                	push   $0x58
f0100c10:	68 fe 67 10 f0       	push   $0xf01067fe
f0100c15:	e8 26 f4 ff ff       	call   f0100040 <_panic>
				    memset(page2kva(pp), 0x97, 128);
f0100c1a:	83 ec 04             	sub    $0x4,%esp
f0100c1d:	68 80 00 00 00       	push   $0x80
f0100c22:	68 97 00 00 00       	push   $0x97
f0100c27:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c2c:	50                   	push   %eax
f0100c2d:	e8 55 49 00 00       	call   f0105587 <memset>
f0100c32:	83 c4 10             	add    $0x10,%esp
			 page_free_list = pp1;
	   }

	   // if there's a page that shouldn't be on the free list,
	   // try to make sure it eventually causes trouble.
	   for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c35:	8b 1b                	mov    (%ebx),%ebx
f0100c37:	85 db                	test   %ebx,%ebx
f0100c39:	75 a9                	jne    f0100be4 <check_page_free_list+0x83>
			 if (PDX(page2pa(pp)) < pdx_limit)
				    memset(page2kva(pp), 0x97, 128);

	   first_free_page = (char *) boot_alloc(0);
f0100c3b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c40:	e8 55 fe ff ff       	call   f0100a9a <boot_alloc>
f0100c45:	89 45 cc             	mov    %eax,-0x34(%ebp)
	   for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c48:	8b 15 40 f2 22 f0    	mov    0xf022f240,%edx
			 // check that we didn't corrupt the free list itself
			 assert(pp >= pages);
f0100c4e:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
			 assert(pp < pages + npages);
f0100c54:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0100c59:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c5c:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c5f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			 assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c62:	89 4d d0             	mov    %ecx,-0x30(%ebp)
check_page_free_list(bool only_low_memory)
{

	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	   int nfree_basemem = 0, nfree_extmem = 0;
f0100c65:	be 00 00 00 00       	mov    $0x0,%esi
	   for (pp = page_free_list; pp; pp = pp->pp_link)
			 if (PDX(page2pa(pp)) < pdx_limit)
				    memset(page2kva(pp), 0x97, 128);

	   first_free_page = (char *) boot_alloc(0);
	   for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c6a:	e9 52 01 00 00       	jmp    f0100dc1 <check_page_free_list+0x260>
			 // check that we didn't corrupt the free list itself
			 assert(pp >= pages);
f0100c6f:	39 ca                	cmp    %ecx,%edx
f0100c71:	73 19                	jae    f0100c8c <check_page_free_list+0x12b>
f0100c73:	68 0c 68 10 f0       	push   $0xf010680c
f0100c78:	68 18 68 10 f0       	push   $0xf0106818
f0100c7d:	68 fb 02 00 00       	push   $0x2fb
f0100c82:	68 f2 67 10 f0       	push   $0xf01067f2
f0100c87:	e8 b4 f3 ff ff       	call   f0100040 <_panic>
			 assert(pp < pages + npages);
f0100c8c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c8f:	72 19                	jb     f0100caa <check_page_free_list+0x149>
f0100c91:	68 2d 68 10 f0       	push   $0xf010682d
f0100c96:	68 18 68 10 f0       	push   $0xf0106818
f0100c9b:	68 fc 02 00 00       	push   $0x2fc
f0100ca0:	68 f2 67 10 f0       	push   $0xf01067f2
f0100ca5:	e8 96 f3 ff ff       	call   f0100040 <_panic>
			 assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100caa:	89 d0                	mov    %edx,%eax
f0100cac:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100caf:	a8 07                	test   $0x7,%al
f0100cb1:	74 19                	je     f0100ccc <check_page_free_list+0x16b>
f0100cb3:	68 ac 6b 10 f0       	push   $0xf0106bac
f0100cb8:	68 18 68 10 f0       	push   $0xf0106818
f0100cbd:	68 fd 02 00 00       	push   $0x2fd
f0100cc2:	68 f2 67 10 f0       	push   $0xf01067f2
f0100cc7:	e8 74 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ccc:	c1 f8 03             	sar    $0x3,%eax
f0100ccf:	c1 e0 0c             	shl    $0xc,%eax

			 // check a few pages that shouldn't be on the free list
			 assert(page2pa(pp) != 0);
f0100cd2:	85 c0                	test   %eax,%eax
f0100cd4:	75 19                	jne    f0100cef <check_page_free_list+0x18e>
f0100cd6:	68 41 68 10 f0       	push   $0xf0106841
f0100cdb:	68 18 68 10 f0       	push   $0xf0106818
f0100ce0:	68 00 03 00 00       	push   $0x300
f0100ce5:	68 f2 67 10 f0       	push   $0xf01067f2
f0100cea:	e8 51 f3 ff ff       	call   f0100040 <_panic>
			 assert(page2pa(pp) != IOPHYSMEM);
f0100cef:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cf4:	75 19                	jne    f0100d0f <check_page_free_list+0x1ae>
f0100cf6:	68 52 68 10 f0       	push   $0xf0106852
f0100cfb:	68 18 68 10 f0       	push   $0xf0106818
f0100d00:	68 01 03 00 00       	push   $0x301
f0100d05:	68 f2 67 10 f0       	push   $0xf01067f2
f0100d0a:	e8 31 f3 ff ff       	call   f0100040 <_panic>
			 assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d0f:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d14:	75 19                	jne    f0100d2f <check_page_free_list+0x1ce>
f0100d16:	68 e0 6b 10 f0       	push   $0xf0106be0
f0100d1b:	68 18 68 10 f0       	push   $0xf0106818
f0100d20:	68 02 03 00 00       	push   $0x302
f0100d25:	68 f2 67 10 f0       	push   $0xf01067f2
f0100d2a:	e8 11 f3 ff ff       	call   f0100040 <_panic>
			 assert(page2pa(pp) != EXTPHYSMEM);
f0100d2f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d34:	75 19                	jne    f0100d4f <check_page_free_list+0x1ee>
f0100d36:	68 6b 68 10 f0       	push   $0xf010686b
f0100d3b:	68 18 68 10 f0       	push   $0xf0106818
f0100d40:	68 03 03 00 00       	push   $0x303
f0100d45:	68 f2 67 10 f0       	push   $0xf01067f2
f0100d4a:	e8 f1 f2 ff ff       	call   f0100040 <_panic>
			 assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d4f:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d54:	0f 86 f1 00 00 00    	jbe    f0100e4b <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d5a:	89 c7                	mov    %eax,%edi
f0100d5c:	c1 ef 0c             	shr    $0xc,%edi
f0100d5f:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d62:	77 12                	ja     f0100d76 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d64:	50                   	push   %eax
f0100d65:	68 64 62 10 f0       	push   $0xf0106264
f0100d6a:	6a 58                	push   $0x58
f0100d6c:	68 fe 67 10 f0       	push   $0xf01067fe
f0100d71:	e8 ca f2 ff ff       	call   f0100040 <_panic>
f0100d76:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d7c:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d7f:	0f 86 b6 00 00 00    	jbe    f0100e3b <check_page_free_list+0x2da>
f0100d85:	68 04 6c 10 f0       	push   $0xf0106c04
f0100d8a:	68 18 68 10 f0       	push   $0xf0106818
f0100d8f:	68 04 03 00 00       	push   $0x304
f0100d94:	68 f2 67 10 f0       	push   $0xf01067f2
f0100d99:	e8 a2 f2 ff ff       	call   f0100040 <_panic>
			 // (new test for lab 4)
			 assert(page2pa(pp) != MPENTRY_PADDR);
f0100d9e:	68 85 68 10 f0       	push   $0xf0106885
f0100da3:	68 18 68 10 f0       	push   $0xf0106818
f0100da8:	68 06 03 00 00       	push   $0x306
f0100dad:	68 f2 67 10 f0       	push   $0xf01067f2
f0100db2:	e8 89 f2 ff ff       	call   f0100040 <_panic>

			 if (page2pa(pp) < EXTPHYSMEM)
				    ++nfree_basemem;
f0100db7:	83 c6 01             	add    $0x1,%esi
f0100dba:	eb 03                	jmp    f0100dbf <check_page_free_list+0x25e>
			 else
				    ++nfree_extmem;
f0100dbc:	83 c3 01             	add    $0x1,%ebx
	   for (pp = page_free_list; pp; pp = pp->pp_link)
			 if (PDX(page2pa(pp)) < pdx_limit)
				    memset(page2kva(pp), 0x97, 128);

	   first_free_page = (char *) boot_alloc(0);
	   for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dbf:	8b 12                	mov    (%edx),%edx
f0100dc1:	85 d2                	test   %edx,%edx
f0100dc3:	0f 85 a6 fe ff ff    	jne    f0100c6f <check_page_free_list+0x10e>
				    ++nfree_basemem;
			 else
				    ++nfree_extmem;
	   }

	   assert(nfree_basemem > 0);
f0100dc9:	85 f6                	test   %esi,%esi
f0100dcb:	7f 19                	jg     f0100de6 <check_page_free_list+0x285>
f0100dcd:	68 a2 68 10 f0       	push   $0xf01068a2
f0100dd2:	68 18 68 10 f0       	push   $0xf0106818
f0100dd7:	68 0e 03 00 00       	push   $0x30e
f0100ddc:	68 f2 67 10 f0       	push   $0xf01067f2
f0100de1:	e8 5a f2 ff ff       	call   f0100040 <_panic>
	   assert(nfree_extmem > 0);
f0100de6:	85 db                	test   %ebx,%ebx
f0100de8:	7f 19                	jg     f0100e03 <check_page_free_list+0x2a2>
f0100dea:	68 b4 68 10 f0       	push   $0xf01068b4
f0100def:	68 18 68 10 f0       	push   $0xf0106818
f0100df4:	68 0f 03 00 00       	push   $0x30f
f0100df9:	68 f2 67 10 f0       	push   $0xf01067f2
f0100dfe:	e8 3d f2 ff ff       	call   f0100040 <_panic>

	   cprintf("check_page_free_list() succeeded!\n");
f0100e03:	83 ec 0c             	sub    $0xc,%esp
f0100e06:	68 4c 6c 10 f0       	push   $0xf0106c4c
f0100e0b:	e8 44 2a 00 00       	call   f0103854 <cprintf>
}
f0100e10:	eb 49                	jmp    f0100e5b <check_page_free_list+0x2fa>
	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	   int nfree_basemem = 0, nfree_extmem = 0;
	   char *first_free_page;

	   if (!page_free_list)
f0100e12:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0100e17:	85 c0                	test   %eax,%eax
f0100e19:	0f 85 6f fd ff ff    	jne    f0100b8e <check_page_free_list+0x2d>
f0100e1f:	e9 53 fd ff ff       	jmp    f0100b77 <check_page_free_list+0x16>
f0100e24:	83 3d 40 f2 22 f0 00 	cmpl   $0x0,0xf022f240
f0100e2b:	0f 84 46 fd ff ff    	je     f0100b77 <check_page_free_list+0x16>
	   static void
check_page_free_list(bool only_low_memory)
{

	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e31:	be 00 04 00 00       	mov    $0x400,%esi
f0100e36:	e9 a1 fd ff ff       	jmp    f0100bdc <check_page_free_list+0x7b>
			 assert(page2pa(pp) != IOPHYSMEM);
			 assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
			 assert(page2pa(pp) != EXTPHYSMEM);
			 assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
			 // (new test for lab 4)
			 assert(page2pa(pp) != MPENTRY_PADDR);
f0100e3b:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e40:	0f 85 76 ff ff ff    	jne    f0100dbc <check_page_free_list+0x25b>
f0100e46:	e9 53 ff ff ff       	jmp    f0100d9e <check_page_free_list+0x23d>
f0100e4b:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e50:	0f 85 61 ff ff ff    	jne    f0100db7 <check_page_free_list+0x256>
f0100e56:	e9 43 ff ff ff       	jmp    f0100d9e <check_page_free_list+0x23d>

	   assert(nfree_basemem > 0);
	   assert(nfree_extmem > 0);

	   cprintf("check_page_free_list() succeeded!\n");
}
f0100e5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e5e:	5b                   	pop    %ebx
f0100e5f:	5e                   	pop    %esi
f0100e60:	5f                   	pop    %edi
f0100e61:	5d                   	pop    %ebp
f0100e62:	c3                   	ret    

f0100e63 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
	   void
page_init(void)
{
f0100e63:	55                   	push   %ebp
f0100e64:	89 e5                	mov    %esp,%ebp
f0100e66:	57                   	push   %edi
f0100e67:	56                   	push   %esi
f0100e68:	53                   	push   %ebx
f0100e69:	83 ec 0c             	sub    $0xc,%esp
	   // LAB 4:
	   // Change your code to mark the physical page at MPENTRY_PADDR
	   // as in use
	   extern unsigned char mpentry_start [], mpentry_end [];
	   assert((uintptr_t)(mpentry_end - mpentry_start) <= PGSIZE);
f0100e6c:	b8 06 58 10 f0       	mov    $0xf0105806,%eax
f0100e71:	2d 8c 57 10 f0       	sub    $0xf010578c,%eax
f0100e76:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0100e7b:	76 19                	jbe    f0100e96 <page_init+0x33>
f0100e7d:	68 70 6c 10 f0       	push   $0xf0106c70
f0100e82:	68 18 68 10 f0       	push   $0xf0106818
f0100e87:	68 38 01 00 00       	push   $0x138
f0100e8c:	68 f2 67 10 f0       	push   $0xf01067f2
f0100e91:	e8 aa f1 ff ff       	call   f0100040 <_panic>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e96:	83 3d 88 fe 22 f0 07 	cmpl   $0x7,0xf022fe88
f0100e9d:	77 14                	ja     f0100eb3 <page_init+0x50>
		panic("pa2page called with invalid pa");
f0100e9f:	83 ec 04             	sub    $0x4,%esp
f0100ea2:	68 a4 6c 10 f0       	push   $0xf0106ca4
f0100ea7:	6a 51                	push   $0x51
f0100ea9:	68 fe 67 10 f0       	push   $0xf01067fe
f0100eae:	e8 8d f1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0100eb3:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
	   struct PageInfo* start_ap = pa2page(MPENTRY_PADDR);
	   start_ap -> pp_ref = 1;
f0100eb8:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
	   // The example code here marks all physical pages as free.
	   // However this is not truly the case.  What memory is free?
	   //  1) Mark physical page 0 as in use.
	   //     This way we preserve the real-mode IDT and BIOS structures
	   //     in case we ever need them.  (Currently we don't, but...)
	   pages[0].pp_ref = 1;
f0100ebe:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	   pages [0].pp_link = NULL;
f0100ec4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	   //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	   //     is free.
	   for (int i = 1; i < npages_basemem; i++)
f0100eca:	8b 35 44 f2 22 f0    	mov    0xf022f244,%esi
f0100ed0:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
f0100ed6:	bf 00 00 00 00       	mov    $0x0,%edi
f0100edb:	b8 01 00 00 00       	mov    $0x1,%eax
f0100ee0:	eb 2e                	jmp    f0100f10 <page_init+0xad>
f0100ee2:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
	   {
	   if (pages[i].pp_ref ==1)
f0100ee9:	89 ca                	mov    %ecx,%edx
f0100eeb:	03 15 90 fe 22 f0    	add    0xf022fe90,%edx
f0100ef1:	66 83 7a 04 01       	cmpw   $0x1,0x4(%edx)
f0100ef6:	74 15                	je     f0100f0d <page_init+0xaa>
	   continue;
	   pages[i].pp_ref = 0;
f0100ef8:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
	   pages[i].pp_link = page_free_list;
f0100efe:	89 1a                	mov    %ebx,(%edx)
	   page_free_list = &pages [i];
f0100f00:	03 0d 90 fe 22 f0    	add    0xf022fe90,%ecx
f0100f06:	89 cb                	mov    %ecx,%ebx
f0100f08:	bf 01 00 00 00       	mov    $0x1,%edi
	   //     in case we ever need them.  (Currently we don't, but...)
	   pages[0].pp_ref = 1;
	   pages [0].pp_link = NULL;
	   //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	   //     is free.
	   for (int i = 1; i < npages_basemem; i++)
f0100f0d:	83 c0 01             	add    $0x1,%eax
f0100f10:	39 c6                	cmp    %eax,%esi
f0100f12:	77 ce                	ja     f0100ee2 <page_init+0x7f>
f0100f14:	89 f8                	mov    %edi,%eax
f0100f16:	84 c0                	test   %al,%al
f0100f18:	74 06                	je     f0100f20 <page_init+0xbd>
f0100f1a:	89 1d 40 f2 22 f0    	mov    %ebx,0xf022f240
	   pages[i].pp_link = page_free_list;
	   page_free_list = &pages [i];
	   }
	   //  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	   //     never be allocated.
	   uint32_t free_pa = (uint32_t)PADDR (boot_alloc (0));
f0100f20:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f25:	e8 70 fb ff ff       	call   f0100a9a <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f2a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f2f:	77 15                	ja     f0100f46 <page_init+0xe3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f31:	50                   	push   %eax
f0100f32:	68 88 62 10 f0       	push   $0xf0106288
f0100f37:	68 4f 01 00 00       	push   $0x14f
f0100f3c:	68 f2 67 10 f0       	push   $0xf01067f2
f0100f41:	e8 fa f0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100f46:	05 00 00 00 10       	add    $0x10000000,%eax
	   assert (free_pa % PGSIZE == 0);
f0100f4b:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0100f50:	74 19                	je     f0100f6b <page_init+0x108>
f0100f52:	68 c5 68 10 f0       	push   $0xf01068c5
f0100f57:	68 18 68 10 f0       	push   $0xf0106818
f0100f5c:	68 50 01 00 00       	push   $0x150
f0100f61:	68 f2 67 10 f0       	push   $0xf01067f2
f0100f66:	e8 d5 f0 ff ff       	call   f0100040 <_panic>
	   uint32_t free_pa_index = free_pa / PGSIZE;
f0100f6b:	c1 e8 0c             	shr    $0xc,%eax
	   for (int i = npages_basemem; i < free_pa_index; i++)
f0100f6e:	8b 15 44 f2 22 f0    	mov    0xf022f244,%edx
f0100f74:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100f7b:	eb 1a                	jmp    f0100f97 <page_init+0x134>
	   {
	   pages[i].pp_ref = 1;
f0100f7d:	89 cb                	mov    %ecx,%ebx
f0100f7f:	03 1d 90 fe 22 f0    	add    0xf022fe90,%ebx
f0100f85:	66 c7 43 04 01 00    	movw   $0x1,0x4(%ebx)
	   pages[i].pp_link = NULL;
f0100f8b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	   //  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	   //     never be allocated.
	   uint32_t free_pa = (uint32_t)PADDR (boot_alloc (0));
	   assert (free_pa % PGSIZE == 0);
	   uint32_t free_pa_index = free_pa / PGSIZE;
	   for (int i = npages_basemem; i < free_pa_index; i++)
f0100f91:	83 c2 01             	add    $0x1,%edx
f0100f94:	83 c1 08             	add    $0x8,%ecx
f0100f97:	39 d0                	cmp    %edx,%eax
f0100f99:	77 e2                	ja     f0100f7d <page_init+0x11a>
	   //     page tables and other data structures?
	   //
	   // Change the code to reflect this.
	   // NB: DO NOT actually touch the physical memory corresponding to
	   // free pages!
	   for (int i = free_pa_index; i < npages; i++)
f0100f9b:	89 c2                	mov    %eax,%edx
f0100f9d:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
f0100fa3:	c1 e0 03             	shl    $0x3,%eax
f0100fa6:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fab:	eb 23                	jmp    f0100fd0 <page_init+0x16d>
	   {
	   pages[i].pp_ref = 0;
f0100fad:	89 c1                	mov    %eax,%ecx
f0100faf:	03 0d 90 fe 22 f0    	add    0xf022fe90,%ecx
f0100fb5:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
	   pages[i].pp_link = page_free_list;
f0100fbb:	89 19                	mov    %ebx,(%ecx)
	   page_free_list = &pages[i];
f0100fbd:	89 c3                	mov    %eax,%ebx
f0100fbf:	03 1d 90 fe 22 f0    	add    0xf022fe90,%ebx
	   //     page tables and other data structures?
	   //
	   // Change the code to reflect this.
	   // NB: DO NOT actually touch the physical memory corresponding to
	   // free pages!
	   for (int i = free_pa_index; i < npages; i++)
f0100fc5:	83 c2 01             	add    $0x1,%edx
f0100fc8:	83 c0 08             	add    $0x8,%eax
f0100fcb:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100fd0:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0100fd6:	72 d5                	jb     f0100fad <page_init+0x14a>
f0100fd8:	84 c9                	test   %cl,%cl
f0100fda:	74 06                	je     f0100fe2 <page_init+0x17f>
f0100fdc:	89 1d 40 f2 22 f0    	mov    %ebx,0xf022f240
	   pages[i].pp_ref = 0;
	   pages[i].pp_link = page_free_list;
	   page_free_list = &pages[i];
	   }

	    }
f0100fe2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fe5:	5b                   	pop    %ebx
f0100fe6:	5e                   	pop    %esi
f0100fe7:	5f                   	pop    %edi
f0100fe8:	5d                   	pop    %ebp
f0100fe9:	c3                   	ret    

f0100fea <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
	   struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fea:	55                   	push   %ebp
f0100feb:	89 e5                	mov    %esp,%ebp
f0100fed:	53                   	push   %ebx
f0100fee:	83 ec 04             	sub    $0x4,%esp
	   // Fill this function in

	   struct PageInfo* allocate_page = page_free_list;
f0100ff1:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
	   if (allocate_page == NULL)
f0100ff7:	85 db                	test   %ebx,%ebx
f0100ff9:	74 5c                	je     f0101057 <page_alloc+0x6d>
			 return NULL;

	   page_free_list = allocate_page -> pp_link;
f0100ffb:	8b 03                	mov    (%ebx),%eax
f0100ffd:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
	   allocate_page -> pp_link = NULL;
f0101002:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	   if (alloc_flags & ALLOC_ZERO)
			 memset (page2kva (allocate_page), 0, PGSIZE);

	   return allocate_page;
f0101008:	89 d8                	mov    %ebx,%eax
			 return NULL;

	   page_free_list = allocate_page -> pp_link;
	   allocate_page -> pp_link = NULL;

	   if (alloc_flags & ALLOC_ZERO)
f010100a:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010100e:	74 4c                	je     f010105c <page_alloc+0x72>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101010:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101016:	c1 f8 03             	sar    $0x3,%eax
f0101019:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010101c:	89 c2                	mov    %eax,%edx
f010101e:	c1 ea 0c             	shr    $0xc,%edx
f0101021:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101027:	72 12                	jb     f010103b <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101029:	50                   	push   %eax
f010102a:	68 64 62 10 f0       	push   $0xf0106264
f010102f:	6a 58                	push   $0x58
f0101031:	68 fe 67 10 f0       	push   $0xf01067fe
f0101036:	e8 05 f0 ff ff       	call   f0100040 <_panic>
			 memset (page2kva (allocate_page), 0, PGSIZE);
f010103b:	83 ec 04             	sub    $0x4,%esp
f010103e:	68 00 10 00 00       	push   $0x1000
f0101043:	6a 00                	push   $0x0
f0101045:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010104a:	50                   	push   %eax
f010104b:	e8 37 45 00 00       	call   f0105587 <memset>
f0101050:	83 c4 10             	add    $0x10,%esp

	   return allocate_page;
f0101053:	89 d8                	mov    %ebx,%eax
f0101055:	eb 05                	jmp    f010105c <page_alloc+0x72>
{
	   // Fill this function in

	   struct PageInfo* allocate_page = page_free_list;
	   if (allocate_page == NULL)
			 return NULL;
f0101057:	b8 00 00 00 00       	mov    $0x0,%eax

	   if (alloc_flags & ALLOC_ZERO)
			 memset (page2kva (allocate_page), 0, PGSIZE);

	   return allocate_page;
}
f010105c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010105f:	c9                   	leave  
f0101060:	c3                   	ret    

f0101061 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
	   void
page_free(struct PageInfo *pp)
{
f0101061:	55                   	push   %ebp
f0101062:	89 e5                	mov    %esp,%ebp
f0101064:	83 ec 08             	sub    $0x8,%esp
f0101067:	8b 45 08             	mov    0x8(%ebp),%eax
	   // Fill this function in
	   // Hint: You may want to panic if pp->pp_ref is nonzero or
	   // pp->pp_link is not NULL.

	   assert (pp->pp_ref == 0);
f010106a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010106f:	74 19                	je     f010108a <page_free+0x29>
f0101071:	68 db 68 10 f0       	push   $0xf01068db
f0101076:	68 18 68 10 f0       	push   $0xf0106818
f010107b:	68 92 01 00 00       	push   $0x192
f0101080:	68 f2 67 10 f0       	push   $0xf01067f2
f0101085:	e8 b6 ef ff ff       	call   f0100040 <_panic>
	   assert (pp->pp_link == NULL);
f010108a:	83 38 00             	cmpl   $0x0,(%eax)
f010108d:	74 19                	je     f01010a8 <page_free+0x47>
f010108f:	68 eb 68 10 f0       	push   $0xf01068eb
f0101094:	68 18 68 10 f0       	push   $0xf0106818
f0101099:	68 93 01 00 00       	push   $0x193
f010109e:	68 f2 67 10 f0       	push   $0xf01067f2
f01010a3:	e8 98 ef ff ff       	call   f0100040 <_panic>

	   pp->pp_ref = 0;
f01010a8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	   pp->pp_link = page_free_list;
f01010ae:	8b 15 40 f2 22 f0    	mov    0xf022f240,%edx
f01010b4:	89 10                	mov    %edx,(%eax)
	   page_free_list = pp;
f01010b6:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
}
f01010bb:	c9                   	leave  
f01010bc:	c3                   	ret    

f01010bd <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
	   void
page_decref(struct PageInfo* pp)
{
f01010bd:	55                   	push   %ebp
f01010be:	89 e5                	mov    %esp,%ebp
f01010c0:	83 ec 08             	sub    $0x8,%esp
f01010c3:	8b 55 08             	mov    0x8(%ebp),%edx
	   if (--pp->pp_ref == 0)
f01010c6:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01010ca:	83 e8 01             	sub    $0x1,%eax
f01010cd:	66 89 42 04          	mov    %ax,0x4(%edx)
f01010d1:	66 85 c0             	test   %ax,%ax
f01010d4:	75 0c                	jne    f01010e2 <page_decref+0x25>
			 page_free(pp);
f01010d6:	83 ec 0c             	sub    $0xc,%esp
f01010d9:	52                   	push   %edx
f01010da:	e8 82 ff ff ff       	call   f0101061 <page_free>
f01010df:	83 c4 10             	add    $0x10,%esp
}
f01010e2:	c9                   	leave  
f01010e3:	c3                   	ret    

f01010e4 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
	   pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01010e4:	55                   	push   %ebp
f01010e5:	89 e5                	mov    %esp,%ebp
f01010e7:	56                   	push   %esi
f01010e8:	53                   	push   %ebx
f01010e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   // Fill this function in

	   uintptr_t address = (uintptr_t) va;
	   pde_t pde_offset = pgdir [PDX(address)];
f01010ec:	89 de                	mov    %ebx,%esi
f01010ee:	c1 ee 16             	shr    $0x16,%esi
f01010f1:	c1 e6 02             	shl    $0x2,%esi
f01010f4:	03 75 08             	add    0x8(%ebp),%esi
f01010f7:	8b 06                	mov    (%esi),%eax
	   if (!(pde_offset & PTE_P) && create)
f01010f9:	89 c2                	mov    %eax,%edx
f01010fb:	83 e2 01             	and    $0x1,%edx
f01010fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101102:	74 2d                	je     f0101131 <pgdir_walk+0x4d>
f0101104:	85 d2                	test   %edx,%edx
f0101106:	75 29                	jne    f0101131 <pgdir_walk+0x4d>
	   {
			 struct PageInfo* new_page = page_alloc (ALLOC_ZERO);
f0101108:	83 ec 0c             	sub    $0xc,%esp
f010110b:	6a 01                	push   $0x1
f010110d:	e8 d8 fe ff ff       	call   f0100fea <page_alloc>
			 if (!new_page) return NULL;
f0101112:	83 c4 10             	add    $0x10,%esp
f0101115:	85 c0                	test   %eax,%eax
f0101117:	74 55                	je     f010116e <pgdir_walk+0x8a>

			 new_page -> pp_ref ++;
f0101119:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			 pde_offset = page2pa (new_page) | PTE_W | PTE_U | PTE_P;
f010111e:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101124:	c1 f8 03             	sar    $0x3,%eax
f0101127:	c1 e0 0c             	shl    $0xc,%eax
f010112a:	83 c8 07             	or     $0x7,%eax
			 pgdir [PDX(address)] = pde_offset;
f010112d:	89 06                	mov    %eax,(%esi)
	   // Fill this function in

	   uintptr_t address = (uintptr_t) va;
	   pde_t pde_offset = pgdir [PDX(address)];
	   if (!(pde_offset & PTE_P) && create)
	   {
f010112f:	eb 04                	jmp    f0101135 <pgdir_walk+0x51>
			 if (!new_page) return NULL;

			 new_page -> pp_ref ++;
			 pde_offset = page2pa (new_page) | PTE_W | PTE_U | PTE_P;
			 pgdir [PDX(address)] = pde_offset;
	   } else if (!(pde_offset & PTE_P)) return NULL;
f0101131:	85 d2                	test   %edx,%edx
f0101133:	74 40                	je     f0101175 <pgdir_walk+0x91>

	   physaddr_t pt_pa = PTE_ADDR(pde_offset);
f0101135:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010113a:	89 c2                	mov    %eax,%edx
f010113c:	c1 ea 0c             	shr    $0xc,%edx
f010113f:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101145:	72 15                	jb     f010115c <pgdir_walk+0x78>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101147:	50                   	push   %eax
f0101148:	68 64 62 10 f0       	push   $0xf0106264
f010114d:	68 cd 01 00 00       	push   $0x1cd
f0101152:	68 f2 67 10 f0       	push   $0xf01067f2
f0101157:	e8 e4 ee ff ff       	call   f0100040 <_panic>
	   pte_t* pt_va = KADDR(pt_pa);
	   return &pt_va [PTX(address)];
f010115c:	c1 eb 0a             	shr    $0xa,%ebx
f010115f:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101165:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f010116c:	eb 0c                	jmp    f010117a <pgdir_walk+0x96>
	   uintptr_t address = (uintptr_t) va;
	   pde_t pde_offset = pgdir [PDX(address)];
	   if (!(pde_offset & PTE_P) && create)
	   {
			 struct PageInfo* new_page = page_alloc (ALLOC_ZERO);
			 if (!new_page) return NULL;
f010116e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101173:	eb 05                	jmp    f010117a <pgdir_walk+0x96>

			 new_page -> pp_ref ++;
			 pde_offset = page2pa (new_page) | PTE_W | PTE_U | PTE_P;
			 pgdir [PDX(address)] = pde_offset;
	   } else if (!(pde_offset & PTE_P)) return NULL;
f0101175:	b8 00 00 00 00       	mov    $0x0,%eax

	   physaddr_t pt_pa = PTE_ADDR(pde_offset);
	   pte_t* pt_va = KADDR(pt_pa);
	   return &pt_va [PTX(address)];
}
f010117a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010117d:	5b                   	pop    %ebx
f010117e:	5e                   	pop    %esi
f010117f:	5d                   	pop    %ebp
f0101180:	c3                   	ret    

f0101181 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
	   static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101181:	55                   	push   %ebp
f0101182:	89 e5                	mov    %esp,%ebp
f0101184:	57                   	push   %edi
f0101185:	56                   	push   %esi
f0101186:	53                   	push   %ebx
f0101187:	83 ec 1c             	sub    $0x1c,%esp
f010118a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010118d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101190:	c1 e9 0c             	shr    $0xc,%ecx
f0101193:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	   /*
		 if (va % PGSIZE != 0 || pa % PGSIZE != 0 || size % PGSIZE != 0)
		 panic ("boot_map_region cannot be executed \n");
	    */
	   uint32_t no_pages = size / PGSIZE;
	   for (int i = 0; i < no_pages; i ++)
f0101196:	89 c3                	mov    %eax,%ebx
f0101198:	be 00 00 00 00       	mov    $0x0,%esi
	   {
			 pte_t* pte_entry = pgdir_walk (pgdir, (void*) (va + i*PGSIZE), 1);
f010119d:	89 d7                	mov    %edx,%edi
f010119f:	29 c7                	sub    %eax,%edi
			 assert (pte_entry != NULL);
			 *pte_entry = (pa + i *PGSIZE) | perm | PTE_P;
f01011a1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011a4:	83 c8 01             	or     $0x1,%eax
f01011a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	   /*
		 if (va % PGSIZE != 0 || pa % PGSIZE != 0 || size % PGSIZE != 0)
		 panic ("boot_map_region cannot be executed \n");
	    */
	   uint32_t no_pages = size / PGSIZE;
	   for (int i = 0; i < no_pages; i ++)
f01011aa:	eb 41                	jmp    f01011ed <boot_map_region+0x6c>
	   {
			 pte_t* pte_entry = pgdir_walk (pgdir, (void*) (va + i*PGSIZE), 1);
f01011ac:	83 ec 04             	sub    $0x4,%esp
f01011af:	6a 01                	push   $0x1
f01011b1:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01011b4:	50                   	push   %eax
f01011b5:	ff 75 e0             	pushl  -0x20(%ebp)
f01011b8:	e8 27 ff ff ff       	call   f01010e4 <pgdir_walk>
			 assert (pte_entry != NULL);
f01011bd:	83 c4 10             	add    $0x10,%esp
f01011c0:	85 c0                	test   %eax,%eax
f01011c2:	75 19                	jne    f01011dd <boot_map_region+0x5c>
f01011c4:	68 ff 68 10 f0       	push   $0xf01068ff
f01011c9:	68 18 68 10 f0       	push   $0xf0106818
f01011ce:	68 e8 01 00 00       	push   $0x1e8
f01011d3:	68 f2 67 10 f0       	push   $0xf01067f2
f01011d8:	e8 63 ee ff ff       	call   f0100040 <_panic>
			 *pte_entry = (pa + i *PGSIZE) | perm | PTE_P;
f01011dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01011e0:	09 da                	or     %ebx,%edx
f01011e2:	89 10                	mov    %edx,(%eax)
	   /*
		 if (va % PGSIZE != 0 || pa % PGSIZE != 0 || size % PGSIZE != 0)
		 panic ("boot_map_region cannot be executed \n");
	    */
	   uint32_t no_pages = size / PGSIZE;
	   for (int i = 0; i < no_pages; i ++)
f01011e4:	83 c6 01             	add    $0x1,%esi
f01011e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01011ed:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01011f0:	75 ba                	jne    f01011ac <boot_map_region+0x2b>
	   {
			 pte_t* pte_entry = pgdir_walk (pgdir, (void*) (va + i*PGSIZE), 1);
			 assert (pte_entry != NULL);
			 *pte_entry = (pa + i *PGSIZE) | perm | PTE_P;
	   }
}
f01011f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011f5:	5b                   	pop    %ebx
f01011f6:	5e                   	pop    %esi
f01011f7:	5f                   	pop    %edi
f01011f8:	5d                   	pop    %ebp
f01011f9:	c3                   	ret    

f01011fa <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
	   struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01011fa:	55                   	push   %ebp
f01011fb:	89 e5                	mov    %esp,%ebp
f01011fd:	53                   	push   %ebx
f01011fe:	83 ec 08             	sub    $0x8,%esp
f0101201:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // Fill this function in

	   pte_t* pte_entry = pgdir_walk (pgdir, va, 0);
f0101204:	6a 00                	push   $0x0
f0101206:	ff 75 0c             	pushl  0xc(%ebp)
f0101209:	ff 75 08             	pushl  0x8(%ebp)
f010120c:	e8 d3 fe ff ff       	call   f01010e4 <pgdir_walk>

	   if (!pte_entry || !(*pte_entry & PTE_P))
f0101211:	83 c4 10             	add    $0x10,%esp
f0101214:	85 c0                	test   %eax,%eax
f0101216:	74 37                	je     f010124f <page_lookup+0x55>
f0101218:	f6 00 01             	testb  $0x1,(%eax)
f010121b:	74 39                	je     f0101256 <page_lookup+0x5c>
			 return NULL;

	   if (pte_store)
f010121d:	85 db                	test   %ebx,%ebx
f010121f:	74 02                	je     f0101223 <page_lookup+0x29>
			 *pte_store = pte_entry;
f0101221:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101223:	8b 00                	mov    (%eax),%eax
f0101225:	c1 e8 0c             	shr    $0xc,%eax
f0101228:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f010122e:	72 14                	jb     f0101244 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101230:	83 ec 04             	sub    $0x4,%esp
f0101233:	68 a4 6c 10 f0       	push   $0xf0106ca4
f0101238:	6a 51                	push   $0x51
f010123a:	68 fe 67 10 f0       	push   $0xf01067fe
f010123f:	e8 fc ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101244:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f010124a:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	   return pa2page(PTE_ADDR(*pte_entry));
f010124d:	eb 0c                	jmp    f010125b <page_lookup+0x61>
	   // Fill this function in

	   pte_t* pte_entry = pgdir_walk (pgdir, va, 0);

	   if (!pte_entry || !(*pte_entry & PTE_P))
			 return NULL;
f010124f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101254:	eb 05                	jmp    f010125b <page_lookup+0x61>
f0101256:	b8 00 00 00 00       	mov    $0x0,%eax

	   if (pte_store)
			 *pte_store = pte_entry;

	   return pa2page(PTE_ADDR(*pte_entry));
}
f010125b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010125e:	c9                   	leave  
f010125f:	c3                   	ret    

f0101260 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
	   void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101260:	55                   	push   %ebp
f0101261:	89 e5                	mov    %esp,%ebp
f0101263:	83 ec 08             	sub    $0x8,%esp

	   // Flush the entry only if we're modifying the current address space.
	   if (!curenv || curenv->env_pgdir == pgdir)
f0101266:	e8 3f 49 00 00       	call   f0105baa <cpunum>
f010126b:	6b c0 74             	imul   $0x74,%eax,%eax
f010126e:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0101275:	74 16                	je     f010128d <tlb_invalidate+0x2d>
f0101277:	e8 2e 49 00 00       	call   f0105baa <cpunum>
f010127c:	6b c0 74             	imul   $0x74,%eax,%eax
f010127f:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0101285:	8b 55 08             	mov    0x8(%ebp),%edx
f0101288:	39 50 60             	cmp    %edx,0x60(%eax)
f010128b:	75 06                	jne    f0101293 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010128d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101290:	0f 01 38             	invlpg (%eax)
			 invlpg(va);
}
f0101293:	c9                   	leave  
f0101294:	c3                   	ret    

f0101295 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
	   void
page_remove(pde_t *pgdir, void *va)
{
f0101295:	55                   	push   %ebp
f0101296:	89 e5                	mov    %esp,%ebp
f0101298:	56                   	push   %esi
f0101299:	53                   	push   %ebx
f010129a:	83 ec 14             	sub    $0x14,%esp
f010129d:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01012a0:	8b 75 0c             	mov    0xc(%ebp),%esi
	   // Fill this function in

	   pte_t* pte_address = NULL;
f01012a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	   struct PageInfo* pp = page_lookup (pgdir, va, &pte_address);
f01012aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012ad:	50                   	push   %eax
f01012ae:	56                   	push   %esi
f01012af:	53                   	push   %ebx
f01012b0:	e8 45 ff ff ff       	call   f01011fa <page_lookup>
	   if (!pp)
f01012b5:	83 c4 10             	add    $0x10,%esp
f01012b8:	85 c0                	test   %eax,%eax
f01012ba:	74 1f                	je     f01012db <page_remove+0x46>
			 return;

	   *pte_address = 0;
f01012bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01012bf:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	   page_decref(pp);
f01012c5:	83 ec 0c             	sub    $0xc,%esp
f01012c8:	50                   	push   %eax
f01012c9:	e8 ef fd ff ff       	call   f01010bd <page_decref>
	   tlb_invalidate (pgdir, va);
f01012ce:	83 c4 08             	add    $0x8,%esp
f01012d1:	56                   	push   %esi
f01012d2:	53                   	push   %ebx
f01012d3:	e8 88 ff ff ff       	call   f0101260 <tlb_invalidate>
f01012d8:	83 c4 10             	add    $0x10,%esp

}
f01012db:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012de:	5b                   	pop    %ebx
f01012df:	5e                   	pop    %esi
f01012e0:	5d                   	pop    %ebp
f01012e1:	c3                   	ret    

f01012e2 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
	   int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01012e2:	55                   	push   %ebp
f01012e3:	89 e5                	mov    %esp,%ebp
f01012e5:	57                   	push   %edi
f01012e6:	56                   	push   %esi
f01012e7:	53                   	push   %ebx
f01012e8:	83 ec 10             	sub    $0x10,%esp
f01012eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012ee:	8b 7d 10             	mov    0x10(%ebp),%edi
	   // Fill this function in

	   pte_t* pte_entry = pgdir_walk (pgdir, va, true);
f01012f1:	6a 01                	push   $0x1
f01012f3:	57                   	push   %edi
f01012f4:	ff 75 08             	pushl  0x8(%ebp)
f01012f7:	e8 e8 fd ff ff       	call   f01010e4 <pgdir_walk>

	   if (!pte_entry) return -E_NO_MEM;
f01012fc:	83 c4 10             	add    $0x10,%esp
f01012ff:	85 c0                	test   %eax,%eax
f0101301:	0f 84 a2 00 00 00    	je     f01013a9 <page_insert+0xc7>
f0101307:	89 c6                	mov    %eax,%esi

	   if (PTE_ADDR(*pte_entry) == page2pa (pp))
f0101309:	8b 10                	mov    (%eax),%edx
f010130b:	89 d1                	mov    %edx,%ecx
f010130d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101313:	89 d8                	mov    %ebx,%eax
f0101315:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010131b:	c1 f8 03             	sar    $0x3,%eax
f010131e:	c1 e0 0c             	shl    $0xc,%eax
f0101321:	39 c1                	cmp    %eax,%ecx
f0101323:	75 30                	jne    f0101355 <page_insert+0x73>
	   {
			 if ((*pte_entry & 0x1FF) == perm) return 0;
f0101325:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
f010132b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101330:	3b 55 14             	cmp    0x14(%ebp),%edx
f0101333:	74 79                	je     f01013ae <page_insert+0xcc>

			 *pte_entry = page2pa (pp) | perm | PTE_P;
f0101335:	8b 45 14             	mov    0x14(%ebp),%eax
f0101338:	83 c8 01             	or     $0x1,%eax
f010133b:	09 c1                	or     %eax,%ecx
f010133d:	89 0e                	mov    %ecx,(%esi)
			 tlb_invalidate (pgdir, va);
f010133f:	83 ec 08             	sub    $0x8,%esp
f0101342:	57                   	push   %edi
f0101343:	ff 75 08             	pushl  0x8(%ebp)
f0101346:	e8 15 ff ff ff       	call   f0101260 <tlb_invalidate>
			 return 0;
f010134b:	83 c4 10             	add    $0x10,%esp
f010134e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101353:	eb 59                	jmp    f01013ae <page_insert+0xcc>
	   }

	   if (*pte_entry & PTE_P)
f0101355:	f6 c2 01             	test   $0x1,%dl
f0101358:	74 2d                	je     f0101387 <page_insert+0xa5>
	   {
			 page_remove (pgdir, va);
f010135a:	83 ec 08             	sub    $0x8,%esp
f010135d:	57                   	push   %edi
f010135e:	ff 75 08             	pushl  0x8(%ebp)
f0101361:	e8 2f ff ff ff       	call   f0101295 <page_remove>
			 assert (*pte_entry ==0);
f0101366:	83 c4 10             	add    $0x10,%esp
f0101369:	83 3e 00             	cmpl   $0x0,(%esi)
f010136c:	74 19                	je     f0101387 <page_insert+0xa5>
f010136e:	68 11 69 10 f0       	push   $0xf0106911
f0101373:	68 18 68 10 f0       	push   $0xf0106818
f0101378:	68 1b 02 00 00       	push   $0x21b
f010137d:	68 f2 67 10 f0       	push   $0xf01067f2
f0101382:	e8 b9 ec ff ff       	call   f0100040 <_panic>
	   }

	   pp -> pp_ref ++;
f0101387:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	   *pte_entry = page2pa (pp) | perm | PTE_P;
f010138c:	2b 1d 90 fe 22 f0    	sub    0xf022fe90,%ebx
f0101392:	c1 fb 03             	sar    $0x3,%ebx
f0101395:	c1 e3 0c             	shl    $0xc,%ebx
f0101398:	8b 45 14             	mov    0x14(%ebp),%eax
f010139b:	83 c8 01             	or     $0x1,%eax
f010139e:	09 c3                	or     %eax,%ebx
f01013a0:	89 1e                	mov    %ebx,(%esi)
	   return 0;
f01013a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01013a7:	eb 05                	jmp    f01013ae <page_insert+0xcc>
{
	   // Fill this function in

	   pte_t* pte_entry = pgdir_walk (pgdir, va, true);

	   if (!pte_entry) return -E_NO_MEM;
f01013a9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	   }

	   pp -> pp_ref ++;
	   *pte_entry = page2pa (pp) | perm | PTE_P;
	   return 0;
}
f01013ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013b1:	5b                   	pop    %ebx
f01013b2:	5e                   	pop    %esi
f01013b3:	5f                   	pop    %edi
f01013b4:	5d                   	pop    %ebp
f01013b5:	c3                   	ret    

f01013b6 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
	   void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01013b6:	55                   	push   %ebp
f01013b7:	89 e5                	mov    %esp,%ebp
f01013b9:	53                   	push   %ebx
f01013ba:	83 ec 04             	sub    $0x4,%esp
f01013bd:	8b 45 08             	mov    0x8(%ebp),%eax
	   // okay to simply panic if this happens).
	   //
	   // Hint: The staff solution uses boot_map_region.
	   //
	   // Your code here:
		 assert (pa % PGSIZE == 0);
f01013c0:	a9 ff 0f 00 00       	test   $0xfff,%eax
f01013c5:	74 19                	je     f01013e0 <mmio_map_region+0x2a>
f01013c7:	68 ca 68 10 f0       	push   $0xf01068ca
f01013cc:	68 18 68 10 f0       	push   $0xf0106818
f01013d1:	68 8a 02 00 00       	push   $0x28a
f01013d6:	68 f2 67 10 f0       	push   $0xf01067f2
f01013db:	e8 60 ec ff ff       	call   f0100040 <_panic>
		 size = ROUNDUP (size, PGSIZE);
f01013e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013e3:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f01013e9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		 if ((base + size) > MMIOLIM)
f01013ef:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f01013f5:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f01013f8:	81 f9 00 00 c0 ef    	cmp    $0xefc00000,%ecx
f01013fe:	76 17                	jbe    f0101417 <mmio_map_region+0x61>
		 panic ("Memory to be allocated greater than MMIOLIM. Out of memory \n");
f0101400:	83 ec 04             	sub    $0x4,%esp
f0101403:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0101408:	68 8d 02 00 00       	push   $0x28d
f010140d:	68 f2 67 10 f0       	push   $0xf01067f2
f0101412:	e8 29 ec ff ff       	call   f0100040 <_panic>

		 boot_map_region(kern_pgdir, base, size, pa, PTE_W | PTE_PCD | PTE_PWT | PTE_P);
f0101417:	83 ec 08             	sub    $0x8,%esp
f010141a:	6a 1b                	push   $0x1b
f010141c:	50                   	push   %eax
f010141d:	89 d9                	mov    %ebx,%ecx
f010141f:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101424:	e8 58 fd ff ff       	call   f0101181 <boot_map_region>
		 void* return_base = (void*) base;
f0101429:	a1 00 03 12 f0       	mov    0xf0120300,%eax
		 base += size;
f010142e:	01 c3                	add    %eax,%ebx
f0101430:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
		 return return_base;

	   //panic("mmio_map_region not implemented");
	   }
f0101436:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101439:	c9                   	leave  
f010143a:	c3                   	ret    

f010143b <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	   void
mem_init(void)
{
f010143b:	55                   	push   %ebp
f010143c:	89 e5                	mov    %esp,%ebp
f010143e:	57                   	push   %edi
f010143f:	56                   	push   %esi
f0101440:	53                   	push   %ebx
f0101441:	83 ec 3c             	sub    $0x3c,%esp
{
	   size_t basemem, extmem, ext16mem, totalmem;

	   // Use CMOS calls to measure available base & extended memory.
	   // (CMOS calls return results in kilobytes.)
	   basemem = nvram_read(NVRAM_BASELO);
f0101444:	b8 15 00 00 00       	mov    $0x15,%eax
f0101449:	e8 23 f6 ff ff       	call   f0100a71 <nvram_read>
f010144e:	89 c3                	mov    %eax,%ebx
	   extmem = nvram_read(NVRAM_EXTLO);
f0101450:	b8 17 00 00 00       	mov    $0x17,%eax
f0101455:	e8 17 f6 ff ff       	call   f0100a71 <nvram_read>
f010145a:	89 c6                	mov    %eax,%esi
	   ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010145c:	b8 34 00 00 00       	mov    $0x34,%eax
f0101461:	e8 0b f6 ff ff       	call   f0100a71 <nvram_read>
f0101466:	c1 e0 06             	shl    $0x6,%eax

	   // Calculate the number of physical pages available in both base
	   // and extended memory.
	   if (ext16mem)
f0101469:	85 c0                	test   %eax,%eax
f010146b:	74 07                	je     f0101474 <mem_init+0x39>
			 totalmem = 16 * 1024 + ext16mem;
f010146d:	05 00 40 00 00       	add    $0x4000,%eax
f0101472:	eb 0b                	jmp    f010147f <mem_init+0x44>
	   else if (extmem)
			 totalmem = 1 * 1024 + extmem;
f0101474:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010147a:	85 f6                	test   %esi,%esi
f010147c:	0f 44 c3             	cmove  %ebx,%eax
	   else
			 totalmem = basemem;

	   npages = totalmem / (PGSIZE / 1024);
f010147f:	89 c2                	mov    %eax,%edx
f0101481:	c1 ea 02             	shr    $0x2,%edx
f0101484:	89 15 88 fe 22 f0    	mov    %edx,0xf022fe88
	   npages_basemem = basemem / (PGSIZE / 1024);
f010148a:	89 da                	mov    %ebx,%edx
f010148c:	c1 ea 02             	shr    $0x2,%edx
f010148f:	89 15 44 f2 22 f0    	mov    %edx,0xf022f244

	   cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101495:	89 c2                	mov    %eax,%edx
f0101497:	29 da                	sub    %ebx,%edx
f0101499:	52                   	push   %edx
f010149a:	53                   	push   %ebx
f010149b:	50                   	push   %eax
f010149c:	68 04 6d 10 f0       	push   $0xf0106d04
f01014a1:	e8 ae 23 00 00       	call   f0103854 <cprintf>
	   // Remove this line when you're ready to test this function.
	   //	   panic("mem_init: This function is not finished\n");

	   //////////////////////////////////////////////////////////////////////
	   // create initial page directory.
	   kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014a6:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014ab:	e8 ea f5 ff ff       	call   f0100a9a <boot_alloc>
f01014b0:	a3 8c fe 22 f0       	mov    %eax,0xf022fe8c
	   memset(kern_pgdir, 0, PGSIZE);
f01014b5:	83 c4 0c             	add    $0xc,%esp
f01014b8:	68 00 10 00 00       	push   $0x1000
f01014bd:	6a 00                	push   $0x0
f01014bf:	50                   	push   %eax
f01014c0:	e8 c2 40 00 00       	call   f0105587 <memset>
	   // a virtual page table at virtual address UVPT.
	   // (For now, you don't have understand the greater purpose of the
	   // following line.)

	   // Permissions: kernel R, user R
	   kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01014c5:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01014ca:	83 c4 10             	add    $0x10,%esp
f01014cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014d2:	77 15                	ja     f01014e9 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014d4:	50                   	push   %eax
f01014d5:	68 88 62 10 f0       	push   $0xf0106288
f01014da:	68 9b 00 00 00       	push   $0x9b
f01014df:	68 f2 67 10 f0       	push   $0xf01067f2
f01014e4:	e8 57 eb ff ff       	call   f0100040 <_panic>
f01014e9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01014ef:	83 ca 05             	or     $0x5,%edx
f01014f2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	   // each physical page, there is a corresponding struct PageInfo in this
	   // array.  'npages' is the number of physical pages in memory.  Use memset
	   // to initialize all fields of each struct PageInfo to 0.
	   // Your code goes here:

	   pages = (struct PageInfo *) boot_alloc(npages * sizeof (struct PageInfo));
f01014f8:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f01014fd:	c1 e0 03             	shl    $0x3,%eax
f0101500:	e8 95 f5 ff ff       	call   f0100a9a <boot_alloc>
f0101505:	a3 90 fe 22 f0       	mov    %eax,0xf022fe90
	   memset (pages, 0, npages * sizeof(struct PageInfo));
f010150a:	83 ec 04             	sub    $0x4,%esp
f010150d:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f0101513:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010151a:	52                   	push   %edx
f010151b:	6a 00                	push   $0x0
f010151d:	50                   	push   %eax
f010151e:	e8 64 40 00 00       	call   f0105587 <memset>

	   //////////////////////////////////////////////////////////////////////
	   // Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	   // LAB 3: Your code here.

	   envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f0101523:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101528:	e8 6d f5 ff ff       	call   f0100a9a <boot_alloc>
f010152d:	a3 48 f2 22 f0       	mov    %eax,0xf022f248
	   memset(envs, 0, NENV * sizeof(struct Env));
f0101532:	83 c4 0c             	add    $0xc,%esp
f0101535:	68 00 f0 01 00       	push   $0x1f000
f010153a:	6a 00                	push   $0x0
f010153c:	50                   	push   %eax
f010153d:	e8 45 40 00 00       	call   f0105587 <memset>
	   // Now that we've allocated the initial kernel data structures, we set
	   // up the list of free physical pages. Once we've done so, all further
	   // memory management will go through the page_* functions. In
	   // particular, we can now map memory using boot_map_region
	   // or page_insert
	   page_init();
f0101542:	e8 1c f9 ff ff       	call   f0100e63 <page_init>

	   check_page_free_list(1);
f0101547:	b8 01 00 00 00       	mov    $0x1,%eax
f010154c:	e8 10 f6 ff ff       	call   f0100b61 <check_page_free_list>
	   int nfree;
	   struct PageInfo *fl;
	   char *c;
	   int i;

	   if (!pages)
f0101551:	83 c4 10             	add    $0x10,%esp
f0101554:	83 3d 90 fe 22 f0 00 	cmpl   $0x0,0xf022fe90
f010155b:	75 17                	jne    f0101574 <mem_init+0x139>
			 panic("'pages' is a null pointer!");
f010155d:	83 ec 04             	sub    $0x4,%esp
f0101560:	68 20 69 10 f0       	push   $0xf0106920
f0101565:	68 22 03 00 00       	push   $0x322
f010156a:	68 f2 67 10 f0       	push   $0xf01067f2
f010156f:	e8 cc ea ff ff       	call   f0100040 <_panic>

	   // check number of free pages
	   for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101574:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101579:	bb 00 00 00 00       	mov    $0x0,%ebx
f010157e:	eb 05                	jmp    f0101585 <mem_init+0x14a>
			 ++nfree;
f0101580:	83 c3 01             	add    $0x1,%ebx

	   if (!pages)
			 panic("'pages' is a null pointer!");

	   // check number of free pages
	   for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101583:	8b 00                	mov    (%eax),%eax
f0101585:	85 c0                	test   %eax,%eax
f0101587:	75 f7                	jne    f0101580 <mem_init+0x145>
			 ++nfree;

	   // should be able to allocate three pages
	   pp0 = pp1 = pp2 = 0;
	   assert((pp0 = page_alloc(0)));
f0101589:	83 ec 0c             	sub    $0xc,%esp
f010158c:	6a 00                	push   $0x0
f010158e:	e8 57 fa ff ff       	call   f0100fea <page_alloc>
f0101593:	89 c7                	mov    %eax,%edi
f0101595:	83 c4 10             	add    $0x10,%esp
f0101598:	85 c0                	test   %eax,%eax
f010159a:	75 19                	jne    f01015b5 <mem_init+0x17a>
f010159c:	68 3b 69 10 f0       	push   $0xf010693b
f01015a1:	68 18 68 10 f0       	push   $0xf0106818
f01015a6:	68 2a 03 00 00       	push   $0x32a
f01015ab:	68 f2 67 10 f0       	push   $0xf01067f2
f01015b0:	e8 8b ea ff ff       	call   f0100040 <_panic>
	   assert((pp1 = page_alloc(0)));
f01015b5:	83 ec 0c             	sub    $0xc,%esp
f01015b8:	6a 00                	push   $0x0
f01015ba:	e8 2b fa ff ff       	call   f0100fea <page_alloc>
f01015bf:	89 c6                	mov    %eax,%esi
f01015c1:	83 c4 10             	add    $0x10,%esp
f01015c4:	85 c0                	test   %eax,%eax
f01015c6:	75 19                	jne    f01015e1 <mem_init+0x1a6>
f01015c8:	68 51 69 10 f0       	push   $0xf0106951
f01015cd:	68 18 68 10 f0       	push   $0xf0106818
f01015d2:	68 2b 03 00 00       	push   $0x32b
f01015d7:	68 f2 67 10 f0       	push   $0xf01067f2
f01015dc:	e8 5f ea ff ff       	call   f0100040 <_panic>
	   assert((pp2 = page_alloc(0)));
f01015e1:	83 ec 0c             	sub    $0xc,%esp
f01015e4:	6a 00                	push   $0x0
f01015e6:	e8 ff f9 ff ff       	call   f0100fea <page_alloc>
f01015eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015ee:	83 c4 10             	add    $0x10,%esp
f01015f1:	85 c0                	test   %eax,%eax
f01015f3:	75 19                	jne    f010160e <mem_init+0x1d3>
f01015f5:	68 67 69 10 f0       	push   $0xf0106967
f01015fa:	68 18 68 10 f0       	push   $0xf0106818
f01015ff:	68 2c 03 00 00       	push   $0x32c
f0101604:	68 f2 67 10 f0       	push   $0xf01067f2
f0101609:	e8 32 ea ff ff       	call   f0100040 <_panic>

	   assert(pp0);
	   assert(pp1 && pp1 != pp0);
f010160e:	39 f7                	cmp    %esi,%edi
f0101610:	75 19                	jne    f010162b <mem_init+0x1f0>
f0101612:	68 7d 69 10 f0       	push   $0xf010697d
f0101617:	68 18 68 10 f0       	push   $0xf0106818
f010161c:	68 2f 03 00 00       	push   $0x32f
f0101621:	68 f2 67 10 f0       	push   $0xf01067f2
f0101626:	e8 15 ea ff ff       	call   f0100040 <_panic>
	   assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010162b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010162e:	39 c6                	cmp    %eax,%esi
f0101630:	74 04                	je     f0101636 <mem_init+0x1fb>
f0101632:	39 c7                	cmp    %eax,%edi
f0101634:	75 19                	jne    f010164f <mem_init+0x214>
f0101636:	68 40 6d 10 f0       	push   $0xf0106d40
f010163b:	68 18 68 10 f0       	push   $0xf0106818
f0101640:	68 30 03 00 00       	push   $0x330
f0101645:	68 f2 67 10 f0       	push   $0xf01067f2
f010164a:	e8 f1 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010164f:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
	   assert(page2pa(pp0) < npages*PGSIZE);
f0101655:	8b 15 88 fe 22 f0    	mov    0xf022fe88,%edx
f010165b:	c1 e2 0c             	shl    $0xc,%edx
f010165e:	89 f8                	mov    %edi,%eax
f0101660:	29 c8                	sub    %ecx,%eax
f0101662:	c1 f8 03             	sar    $0x3,%eax
f0101665:	c1 e0 0c             	shl    $0xc,%eax
f0101668:	39 d0                	cmp    %edx,%eax
f010166a:	72 19                	jb     f0101685 <mem_init+0x24a>
f010166c:	68 8f 69 10 f0       	push   $0xf010698f
f0101671:	68 18 68 10 f0       	push   $0xf0106818
f0101676:	68 31 03 00 00       	push   $0x331
f010167b:	68 f2 67 10 f0       	push   $0xf01067f2
f0101680:	e8 bb e9 ff ff       	call   f0100040 <_panic>
	   assert(page2pa(pp1) < npages*PGSIZE);
f0101685:	89 f0                	mov    %esi,%eax
f0101687:	29 c8                	sub    %ecx,%eax
f0101689:	c1 f8 03             	sar    $0x3,%eax
f010168c:	c1 e0 0c             	shl    $0xc,%eax
f010168f:	39 c2                	cmp    %eax,%edx
f0101691:	77 19                	ja     f01016ac <mem_init+0x271>
f0101693:	68 ac 69 10 f0       	push   $0xf01069ac
f0101698:	68 18 68 10 f0       	push   $0xf0106818
f010169d:	68 32 03 00 00       	push   $0x332
f01016a2:	68 f2 67 10 f0       	push   $0xf01067f2
f01016a7:	e8 94 e9 ff ff       	call   f0100040 <_panic>
	   assert(page2pa(pp2) < npages*PGSIZE);
f01016ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016af:	29 c8                	sub    %ecx,%eax
f01016b1:	c1 f8 03             	sar    $0x3,%eax
f01016b4:	c1 e0 0c             	shl    $0xc,%eax
f01016b7:	39 c2                	cmp    %eax,%edx
f01016b9:	77 19                	ja     f01016d4 <mem_init+0x299>
f01016bb:	68 c9 69 10 f0       	push   $0xf01069c9
f01016c0:	68 18 68 10 f0       	push   $0xf0106818
f01016c5:	68 33 03 00 00       	push   $0x333
f01016ca:	68 f2 67 10 f0       	push   $0xf01067f2
f01016cf:	e8 6c e9 ff ff       	call   f0100040 <_panic>

	   // temporarily steal the rest of the free pages
	   fl = page_free_list;
f01016d4:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f01016d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	   page_free_list = 0;
f01016dc:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f01016e3:	00 00 00 

	   // should be no free memory
	   assert(!page_alloc(0));
f01016e6:	83 ec 0c             	sub    $0xc,%esp
f01016e9:	6a 00                	push   $0x0
f01016eb:	e8 fa f8 ff ff       	call   f0100fea <page_alloc>
f01016f0:	83 c4 10             	add    $0x10,%esp
f01016f3:	85 c0                	test   %eax,%eax
f01016f5:	74 19                	je     f0101710 <mem_init+0x2d5>
f01016f7:	68 e6 69 10 f0       	push   $0xf01069e6
f01016fc:	68 18 68 10 f0       	push   $0xf0106818
f0101701:	68 3a 03 00 00       	push   $0x33a
f0101706:	68 f2 67 10 f0       	push   $0xf01067f2
f010170b:	e8 30 e9 ff ff       	call   f0100040 <_panic>

	   // free and re-allocate?
	   page_free(pp0);
f0101710:	83 ec 0c             	sub    $0xc,%esp
f0101713:	57                   	push   %edi
f0101714:	e8 48 f9 ff ff       	call   f0101061 <page_free>
	   page_free(pp1);
f0101719:	89 34 24             	mov    %esi,(%esp)
f010171c:	e8 40 f9 ff ff       	call   f0101061 <page_free>
	   page_free(pp2);
f0101721:	83 c4 04             	add    $0x4,%esp
f0101724:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101727:	e8 35 f9 ff ff       	call   f0101061 <page_free>
	   pp0 = pp1 = pp2 = 0;
	   assert((pp0 = page_alloc(0)));
f010172c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101733:	e8 b2 f8 ff ff       	call   f0100fea <page_alloc>
f0101738:	89 c6                	mov    %eax,%esi
f010173a:	83 c4 10             	add    $0x10,%esp
f010173d:	85 c0                	test   %eax,%eax
f010173f:	75 19                	jne    f010175a <mem_init+0x31f>
f0101741:	68 3b 69 10 f0       	push   $0xf010693b
f0101746:	68 18 68 10 f0       	push   $0xf0106818
f010174b:	68 41 03 00 00       	push   $0x341
f0101750:	68 f2 67 10 f0       	push   $0xf01067f2
f0101755:	e8 e6 e8 ff ff       	call   f0100040 <_panic>
	   assert((pp1 = page_alloc(0)));
f010175a:	83 ec 0c             	sub    $0xc,%esp
f010175d:	6a 00                	push   $0x0
f010175f:	e8 86 f8 ff ff       	call   f0100fea <page_alloc>
f0101764:	89 c7                	mov    %eax,%edi
f0101766:	83 c4 10             	add    $0x10,%esp
f0101769:	85 c0                	test   %eax,%eax
f010176b:	75 19                	jne    f0101786 <mem_init+0x34b>
f010176d:	68 51 69 10 f0       	push   $0xf0106951
f0101772:	68 18 68 10 f0       	push   $0xf0106818
f0101777:	68 42 03 00 00       	push   $0x342
f010177c:	68 f2 67 10 f0       	push   $0xf01067f2
f0101781:	e8 ba e8 ff ff       	call   f0100040 <_panic>
	   assert((pp2 = page_alloc(0)));
f0101786:	83 ec 0c             	sub    $0xc,%esp
f0101789:	6a 00                	push   $0x0
f010178b:	e8 5a f8 ff ff       	call   f0100fea <page_alloc>
f0101790:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101793:	83 c4 10             	add    $0x10,%esp
f0101796:	85 c0                	test   %eax,%eax
f0101798:	75 19                	jne    f01017b3 <mem_init+0x378>
f010179a:	68 67 69 10 f0       	push   $0xf0106967
f010179f:	68 18 68 10 f0       	push   $0xf0106818
f01017a4:	68 43 03 00 00       	push   $0x343
f01017a9:	68 f2 67 10 f0       	push   $0xf01067f2
f01017ae:	e8 8d e8 ff ff       	call   f0100040 <_panic>
	   assert(pp0);
	   assert(pp1 && pp1 != pp0);
f01017b3:	39 fe                	cmp    %edi,%esi
f01017b5:	75 19                	jne    f01017d0 <mem_init+0x395>
f01017b7:	68 7d 69 10 f0       	push   $0xf010697d
f01017bc:	68 18 68 10 f0       	push   $0xf0106818
f01017c1:	68 45 03 00 00       	push   $0x345
f01017c6:	68 f2 67 10 f0       	push   $0xf01067f2
f01017cb:	e8 70 e8 ff ff       	call   f0100040 <_panic>
	   assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017d3:	39 c7                	cmp    %eax,%edi
f01017d5:	74 04                	je     f01017db <mem_init+0x3a0>
f01017d7:	39 c6                	cmp    %eax,%esi
f01017d9:	75 19                	jne    f01017f4 <mem_init+0x3b9>
f01017db:	68 40 6d 10 f0       	push   $0xf0106d40
f01017e0:	68 18 68 10 f0       	push   $0xf0106818
f01017e5:	68 46 03 00 00       	push   $0x346
f01017ea:	68 f2 67 10 f0       	push   $0xf01067f2
f01017ef:	e8 4c e8 ff ff       	call   f0100040 <_panic>
	   assert(!page_alloc(0));
f01017f4:	83 ec 0c             	sub    $0xc,%esp
f01017f7:	6a 00                	push   $0x0
f01017f9:	e8 ec f7 ff ff       	call   f0100fea <page_alloc>
f01017fe:	83 c4 10             	add    $0x10,%esp
f0101801:	85 c0                	test   %eax,%eax
f0101803:	74 19                	je     f010181e <mem_init+0x3e3>
f0101805:	68 e6 69 10 f0       	push   $0xf01069e6
f010180a:	68 18 68 10 f0       	push   $0xf0106818
f010180f:	68 47 03 00 00       	push   $0x347
f0101814:	68 f2 67 10 f0       	push   $0xf01067f2
f0101819:	e8 22 e8 ff ff       	call   f0100040 <_panic>
f010181e:	89 f0                	mov    %esi,%eax
f0101820:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101826:	c1 f8 03             	sar    $0x3,%eax
f0101829:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010182c:	89 c2                	mov    %eax,%edx
f010182e:	c1 ea 0c             	shr    $0xc,%edx
f0101831:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101837:	72 12                	jb     f010184b <mem_init+0x410>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101839:	50                   	push   %eax
f010183a:	68 64 62 10 f0       	push   $0xf0106264
f010183f:	6a 58                	push   $0x58
f0101841:	68 fe 67 10 f0       	push   $0xf01067fe
f0101846:	e8 f5 e7 ff ff       	call   f0100040 <_panic>

	   // test flags
	   memset(page2kva(pp0), 1, PGSIZE);
f010184b:	83 ec 04             	sub    $0x4,%esp
f010184e:	68 00 10 00 00       	push   $0x1000
f0101853:	6a 01                	push   $0x1
f0101855:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010185a:	50                   	push   %eax
f010185b:	e8 27 3d 00 00       	call   f0105587 <memset>
	   page_free(pp0);
f0101860:	89 34 24             	mov    %esi,(%esp)
f0101863:	e8 f9 f7 ff ff       	call   f0101061 <page_free>
	   assert((pp = page_alloc(ALLOC_ZERO)));
f0101868:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010186f:	e8 76 f7 ff ff       	call   f0100fea <page_alloc>
f0101874:	83 c4 10             	add    $0x10,%esp
f0101877:	85 c0                	test   %eax,%eax
f0101879:	75 19                	jne    f0101894 <mem_init+0x459>
f010187b:	68 f5 69 10 f0       	push   $0xf01069f5
f0101880:	68 18 68 10 f0       	push   $0xf0106818
f0101885:	68 4c 03 00 00       	push   $0x34c
f010188a:	68 f2 67 10 f0       	push   $0xf01067f2
f010188f:	e8 ac e7 ff ff       	call   f0100040 <_panic>
	   assert(pp && pp0 == pp);
f0101894:	39 c6                	cmp    %eax,%esi
f0101896:	74 19                	je     f01018b1 <mem_init+0x476>
f0101898:	68 13 6a 10 f0       	push   $0xf0106a13
f010189d:	68 18 68 10 f0       	push   $0xf0106818
f01018a2:	68 4d 03 00 00       	push   $0x34d
f01018a7:	68 f2 67 10 f0       	push   $0xf01067f2
f01018ac:	e8 8f e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018b1:	89 f0                	mov    %esi,%eax
f01018b3:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f01018b9:	c1 f8 03             	sar    $0x3,%eax
f01018bc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018bf:	89 c2                	mov    %eax,%edx
f01018c1:	c1 ea 0c             	shr    $0xc,%edx
f01018c4:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f01018ca:	72 12                	jb     f01018de <mem_init+0x4a3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018cc:	50                   	push   %eax
f01018cd:	68 64 62 10 f0       	push   $0xf0106264
f01018d2:	6a 58                	push   $0x58
f01018d4:	68 fe 67 10 f0       	push   $0xf01067fe
f01018d9:	e8 62 e7 ff ff       	call   f0100040 <_panic>
f01018de:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01018e4:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	   c = page2kva(pp);
	   for (i = 0; i < PGSIZE; i++)
			 assert(c[i] == 0);
f01018ea:	80 38 00             	cmpb   $0x0,(%eax)
f01018ed:	74 19                	je     f0101908 <mem_init+0x4cd>
f01018ef:	68 23 6a 10 f0       	push   $0xf0106a23
f01018f4:	68 18 68 10 f0       	push   $0xf0106818
f01018f9:	68 50 03 00 00       	push   $0x350
f01018fe:	68 f2 67 10 f0       	push   $0xf01067f2
f0101903:	e8 38 e7 ff ff       	call   f0100040 <_panic>
f0101908:	83 c0 01             	add    $0x1,%eax
	   memset(page2kva(pp0), 1, PGSIZE);
	   page_free(pp0);
	   assert((pp = page_alloc(ALLOC_ZERO)));
	   assert(pp && pp0 == pp);
	   c = page2kva(pp);
	   for (i = 0; i < PGSIZE; i++)
f010190b:	39 d0                	cmp    %edx,%eax
f010190d:	75 db                	jne    f01018ea <mem_init+0x4af>
			 assert(c[i] == 0);

	   // give free list back
	   page_free_list = fl;
f010190f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101912:	a3 40 f2 22 f0       	mov    %eax,0xf022f240

	   // free the pages we took
	   page_free(pp0);
f0101917:	83 ec 0c             	sub    $0xc,%esp
f010191a:	56                   	push   %esi
f010191b:	e8 41 f7 ff ff       	call   f0101061 <page_free>
	   page_free(pp1);
f0101920:	89 3c 24             	mov    %edi,(%esp)
f0101923:	e8 39 f7 ff ff       	call   f0101061 <page_free>
	   page_free(pp2);
f0101928:	83 c4 04             	add    $0x4,%esp
f010192b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010192e:	e8 2e f7 ff ff       	call   f0101061 <page_free>

	   // number of free pages should be the same
	   for (pp = page_free_list; pp; pp = pp->pp_link)
f0101933:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101938:	83 c4 10             	add    $0x10,%esp
f010193b:	eb 05                	jmp    f0101942 <mem_init+0x507>
			 --nfree;
f010193d:	83 eb 01             	sub    $0x1,%ebx
	   page_free(pp0);
	   page_free(pp1);
	   page_free(pp2);

	   // number of free pages should be the same
	   for (pp = page_free_list; pp; pp = pp->pp_link)
f0101940:	8b 00                	mov    (%eax),%eax
f0101942:	85 c0                	test   %eax,%eax
f0101944:	75 f7                	jne    f010193d <mem_init+0x502>
			 --nfree;
	   assert(nfree == 0);
f0101946:	85 db                	test   %ebx,%ebx
f0101948:	74 19                	je     f0101963 <mem_init+0x528>
f010194a:	68 2d 6a 10 f0       	push   $0xf0106a2d
f010194f:	68 18 68 10 f0       	push   $0xf0106818
f0101954:	68 5d 03 00 00       	push   $0x35d
f0101959:	68 f2 67 10 f0       	push   $0xf01067f2
f010195e:	e8 dd e6 ff ff       	call   f0100040 <_panic>

	   cprintf("check_page_alloc() succeeded!\n");
f0101963:	83 ec 0c             	sub    $0xc,%esp
f0101966:	68 60 6d 10 f0       	push   $0xf0106d60
f010196b:	e8 e4 1e 00 00       	call   f0103854 <cprintf>
	   int i;
	   extern pde_t entry_pgdir[];

	   // should be able to allocate three pages
	   pp0 = pp1 = pp2 = 0;
	   assert((pp0 = page_alloc(0)));
f0101970:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101977:	e8 6e f6 ff ff       	call   f0100fea <page_alloc>
f010197c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010197f:	83 c4 10             	add    $0x10,%esp
f0101982:	85 c0                	test   %eax,%eax
f0101984:	75 19                	jne    f010199f <mem_init+0x564>
f0101986:	68 3b 69 10 f0       	push   $0xf010693b
f010198b:	68 18 68 10 f0       	push   $0xf0106818
f0101990:	68 c5 03 00 00       	push   $0x3c5
f0101995:	68 f2 67 10 f0       	push   $0xf01067f2
f010199a:	e8 a1 e6 ff ff       	call   f0100040 <_panic>
	   assert((pp1 = page_alloc(0)));
f010199f:	83 ec 0c             	sub    $0xc,%esp
f01019a2:	6a 00                	push   $0x0
f01019a4:	e8 41 f6 ff ff       	call   f0100fea <page_alloc>
f01019a9:	89 c3                	mov    %eax,%ebx
f01019ab:	83 c4 10             	add    $0x10,%esp
f01019ae:	85 c0                	test   %eax,%eax
f01019b0:	75 19                	jne    f01019cb <mem_init+0x590>
f01019b2:	68 51 69 10 f0       	push   $0xf0106951
f01019b7:	68 18 68 10 f0       	push   $0xf0106818
f01019bc:	68 c6 03 00 00       	push   $0x3c6
f01019c1:	68 f2 67 10 f0       	push   $0xf01067f2
f01019c6:	e8 75 e6 ff ff       	call   f0100040 <_panic>
	   assert((pp2 = page_alloc(0)));
f01019cb:	83 ec 0c             	sub    $0xc,%esp
f01019ce:	6a 00                	push   $0x0
f01019d0:	e8 15 f6 ff ff       	call   f0100fea <page_alloc>
f01019d5:	89 c6                	mov    %eax,%esi
f01019d7:	83 c4 10             	add    $0x10,%esp
f01019da:	85 c0                	test   %eax,%eax
f01019dc:	75 19                	jne    f01019f7 <mem_init+0x5bc>
f01019de:	68 67 69 10 f0       	push   $0xf0106967
f01019e3:	68 18 68 10 f0       	push   $0xf0106818
f01019e8:	68 c7 03 00 00       	push   $0x3c7
f01019ed:	68 f2 67 10 f0       	push   $0xf01067f2
f01019f2:	e8 49 e6 ff ff       	call   f0100040 <_panic>

	   assert(pp0);
	   assert(pp1 && pp1 != pp0);
f01019f7:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01019fa:	75 19                	jne    f0101a15 <mem_init+0x5da>
f01019fc:	68 7d 69 10 f0       	push   $0xf010697d
f0101a01:	68 18 68 10 f0       	push   $0xf0106818
f0101a06:	68 ca 03 00 00       	push   $0x3ca
f0101a0b:	68 f2 67 10 f0       	push   $0xf01067f2
f0101a10:	e8 2b e6 ff ff       	call   f0100040 <_panic>
	   assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a15:	39 c3                	cmp    %eax,%ebx
f0101a17:	74 05                	je     f0101a1e <mem_init+0x5e3>
f0101a19:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a1c:	75 19                	jne    f0101a37 <mem_init+0x5fc>
f0101a1e:	68 40 6d 10 f0       	push   $0xf0106d40
f0101a23:	68 18 68 10 f0       	push   $0xf0106818
f0101a28:	68 cb 03 00 00       	push   $0x3cb
f0101a2d:	68 f2 67 10 f0       	push   $0xf01067f2
f0101a32:	e8 09 e6 ff ff       	call   f0100040 <_panic>

	   // temporarily steal the rest of the free pages
	   fl = page_free_list;
f0101a37:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101a3c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	   page_free_list = 0;
f0101a3f:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f0101a46:	00 00 00 

	   // should be no free memory
	   assert(!page_alloc(0));
f0101a49:	83 ec 0c             	sub    $0xc,%esp
f0101a4c:	6a 00                	push   $0x0
f0101a4e:	e8 97 f5 ff ff       	call   f0100fea <page_alloc>
f0101a53:	83 c4 10             	add    $0x10,%esp
f0101a56:	85 c0                	test   %eax,%eax
f0101a58:	74 19                	je     f0101a73 <mem_init+0x638>
f0101a5a:	68 e6 69 10 f0       	push   $0xf01069e6
f0101a5f:	68 18 68 10 f0       	push   $0xf0106818
f0101a64:	68 d2 03 00 00       	push   $0x3d2
f0101a69:	68 f2 67 10 f0       	push   $0xf01067f2
f0101a6e:	e8 cd e5 ff ff       	call   f0100040 <_panic>

	   // there is no page allocated at address 0
	   assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a73:	83 ec 04             	sub    $0x4,%esp
f0101a76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a79:	50                   	push   %eax
f0101a7a:	6a 00                	push   $0x0
f0101a7c:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101a82:	e8 73 f7 ff ff       	call   f01011fa <page_lookup>
f0101a87:	83 c4 10             	add    $0x10,%esp
f0101a8a:	85 c0                	test   %eax,%eax
f0101a8c:	74 19                	je     f0101aa7 <mem_init+0x66c>
f0101a8e:	68 80 6d 10 f0       	push   $0xf0106d80
f0101a93:	68 18 68 10 f0       	push   $0xf0106818
f0101a98:	68 d5 03 00 00       	push   $0x3d5
f0101a9d:	68 f2 67 10 f0       	push   $0xf01067f2
f0101aa2:	e8 99 e5 ff ff       	call   f0100040 <_panic>

	   // there is no free memory, so we can't allocate a page table
	   assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101aa7:	6a 02                	push   $0x2
f0101aa9:	6a 00                	push   $0x0
f0101aab:	53                   	push   %ebx
f0101aac:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101ab2:	e8 2b f8 ff ff       	call   f01012e2 <page_insert>
f0101ab7:	83 c4 10             	add    $0x10,%esp
f0101aba:	85 c0                	test   %eax,%eax
f0101abc:	78 19                	js     f0101ad7 <mem_init+0x69c>
f0101abe:	68 b8 6d 10 f0       	push   $0xf0106db8
f0101ac3:	68 18 68 10 f0       	push   $0xf0106818
f0101ac8:	68 d8 03 00 00       	push   $0x3d8
f0101acd:	68 f2 67 10 f0       	push   $0xf01067f2
f0101ad2:	e8 69 e5 ff ff       	call   f0100040 <_panic>

	   // free pp0 and try again: pp0 should be used for page table
	   page_free(pp0);
f0101ad7:	83 ec 0c             	sub    $0xc,%esp
f0101ada:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101add:	e8 7f f5 ff ff       	call   f0101061 <page_free>
	   assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101ae2:	6a 02                	push   $0x2
f0101ae4:	6a 00                	push   $0x0
f0101ae6:	53                   	push   %ebx
f0101ae7:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101aed:	e8 f0 f7 ff ff       	call   f01012e2 <page_insert>
f0101af2:	83 c4 20             	add    $0x20,%esp
f0101af5:	85 c0                	test   %eax,%eax
f0101af7:	74 19                	je     f0101b12 <mem_init+0x6d7>
f0101af9:	68 e8 6d 10 f0       	push   $0xf0106de8
f0101afe:	68 18 68 10 f0       	push   $0xf0106818
f0101b03:	68 dc 03 00 00       	push   $0x3dc
f0101b08:	68 f2 67 10 f0       	push   $0xf01067f2
f0101b0d:	e8 2e e5 ff ff       	call   f0100040 <_panic>
	   assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b12:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b18:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0101b1d:	89 c1                	mov    %eax,%ecx
f0101b1f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b22:	8b 17                	mov    (%edi),%edx
f0101b24:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b2a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b2d:	29 c8                	sub    %ecx,%eax
f0101b2f:	c1 f8 03             	sar    $0x3,%eax
f0101b32:	c1 e0 0c             	shl    $0xc,%eax
f0101b35:	39 c2                	cmp    %eax,%edx
f0101b37:	74 19                	je     f0101b52 <mem_init+0x717>
f0101b39:	68 18 6e 10 f0       	push   $0xf0106e18
f0101b3e:	68 18 68 10 f0       	push   $0xf0106818
f0101b43:	68 dd 03 00 00       	push   $0x3dd
f0101b48:	68 f2 67 10 f0       	push   $0xf01067f2
f0101b4d:	e8 ee e4 ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b52:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b57:	89 f8                	mov    %edi,%eax
f0101b59:	e8 9f ef ff ff       	call   f0100afd <check_va2pa>
f0101b5e:	89 da                	mov    %ebx,%edx
f0101b60:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b63:	c1 fa 03             	sar    $0x3,%edx
f0101b66:	c1 e2 0c             	shl    $0xc,%edx
f0101b69:	39 d0                	cmp    %edx,%eax
f0101b6b:	74 19                	je     f0101b86 <mem_init+0x74b>
f0101b6d:	68 40 6e 10 f0       	push   $0xf0106e40
f0101b72:	68 18 68 10 f0       	push   $0xf0106818
f0101b77:	68 de 03 00 00       	push   $0x3de
f0101b7c:	68 f2 67 10 f0       	push   $0xf01067f2
f0101b81:	e8 ba e4 ff ff       	call   f0100040 <_panic>
	   assert(pp1->pp_ref == 1);
f0101b86:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b8b:	74 19                	je     f0101ba6 <mem_init+0x76b>
f0101b8d:	68 38 6a 10 f0       	push   $0xf0106a38
f0101b92:	68 18 68 10 f0       	push   $0xf0106818
f0101b97:	68 df 03 00 00       	push   $0x3df
f0101b9c:	68 f2 67 10 f0       	push   $0xf01067f2
f0101ba1:	e8 9a e4 ff ff       	call   f0100040 <_panic>
	   assert(pp0->pp_ref == 1);
f0101ba6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ba9:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bae:	74 19                	je     f0101bc9 <mem_init+0x78e>
f0101bb0:	68 49 6a 10 f0       	push   $0xf0106a49
f0101bb5:	68 18 68 10 f0       	push   $0xf0106818
f0101bba:	68 e0 03 00 00       	push   $0x3e0
f0101bbf:	68 f2 67 10 f0       	push   $0xf01067f2
f0101bc4:	e8 77 e4 ff ff       	call   f0100040 <_panic>

	   // should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	   assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bc9:	6a 02                	push   $0x2
f0101bcb:	68 00 10 00 00       	push   $0x1000
f0101bd0:	56                   	push   %esi
f0101bd1:	57                   	push   %edi
f0101bd2:	e8 0b f7 ff ff       	call   f01012e2 <page_insert>
f0101bd7:	83 c4 10             	add    $0x10,%esp
f0101bda:	85 c0                	test   %eax,%eax
f0101bdc:	74 19                	je     f0101bf7 <mem_init+0x7bc>
f0101bde:	68 70 6e 10 f0       	push   $0xf0106e70
f0101be3:	68 18 68 10 f0       	push   $0xf0106818
f0101be8:	68 e3 03 00 00       	push   $0x3e3
f0101bed:	68 f2 67 10 f0       	push   $0xf01067f2
f0101bf2:	e8 49 e4 ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bf7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bfc:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101c01:	e8 f7 ee ff ff       	call   f0100afd <check_va2pa>
f0101c06:	89 f2                	mov    %esi,%edx
f0101c08:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101c0e:	c1 fa 03             	sar    $0x3,%edx
f0101c11:	c1 e2 0c             	shl    $0xc,%edx
f0101c14:	39 d0                	cmp    %edx,%eax
f0101c16:	74 19                	je     f0101c31 <mem_init+0x7f6>
f0101c18:	68 ac 6e 10 f0       	push   $0xf0106eac
f0101c1d:	68 18 68 10 f0       	push   $0xf0106818
f0101c22:	68 e4 03 00 00       	push   $0x3e4
f0101c27:	68 f2 67 10 f0       	push   $0xf01067f2
f0101c2c:	e8 0f e4 ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 1);
f0101c31:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c36:	74 19                	je     f0101c51 <mem_init+0x816>
f0101c38:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101c3d:	68 18 68 10 f0       	push   $0xf0106818
f0101c42:	68 e5 03 00 00       	push   $0x3e5
f0101c47:	68 f2 67 10 f0       	push   $0xf01067f2
f0101c4c:	e8 ef e3 ff ff       	call   f0100040 <_panic>

	   // should be no free memory
	   assert(!page_alloc(0));
f0101c51:	83 ec 0c             	sub    $0xc,%esp
f0101c54:	6a 00                	push   $0x0
f0101c56:	e8 8f f3 ff ff       	call   f0100fea <page_alloc>
f0101c5b:	83 c4 10             	add    $0x10,%esp
f0101c5e:	85 c0                	test   %eax,%eax
f0101c60:	74 19                	je     f0101c7b <mem_init+0x840>
f0101c62:	68 e6 69 10 f0       	push   $0xf01069e6
f0101c67:	68 18 68 10 f0       	push   $0xf0106818
f0101c6c:	68 e8 03 00 00       	push   $0x3e8
f0101c71:	68 f2 67 10 f0       	push   $0xf01067f2
f0101c76:	e8 c5 e3 ff ff       	call   f0100040 <_panic>

	   // should be able to map pp2 at PGSIZE because it's already there
	   assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c7b:	6a 02                	push   $0x2
f0101c7d:	68 00 10 00 00       	push   $0x1000
f0101c82:	56                   	push   %esi
f0101c83:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101c89:	e8 54 f6 ff ff       	call   f01012e2 <page_insert>
f0101c8e:	83 c4 10             	add    $0x10,%esp
f0101c91:	85 c0                	test   %eax,%eax
f0101c93:	74 19                	je     f0101cae <mem_init+0x873>
f0101c95:	68 70 6e 10 f0       	push   $0xf0106e70
f0101c9a:	68 18 68 10 f0       	push   $0xf0106818
f0101c9f:	68 eb 03 00 00       	push   $0x3eb
f0101ca4:	68 f2 67 10 f0       	push   $0xf01067f2
f0101ca9:	e8 92 e3 ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cae:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cb3:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101cb8:	e8 40 ee ff ff       	call   f0100afd <check_va2pa>
f0101cbd:	89 f2                	mov    %esi,%edx
f0101cbf:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101cc5:	c1 fa 03             	sar    $0x3,%edx
f0101cc8:	c1 e2 0c             	shl    $0xc,%edx
f0101ccb:	39 d0                	cmp    %edx,%eax
f0101ccd:	74 19                	je     f0101ce8 <mem_init+0x8ad>
f0101ccf:	68 ac 6e 10 f0       	push   $0xf0106eac
f0101cd4:	68 18 68 10 f0       	push   $0xf0106818
f0101cd9:	68 ec 03 00 00       	push   $0x3ec
f0101cde:	68 f2 67 10 f0       	push   $0xf01067f2
f0101ce3:	e8 58 e3 ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 1);
f0101ce8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ced:	74 19                	je     f0101d08 <mem_init+0x8cd>
f0101cef:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101cf4:	68 18 68 10 f0       	push   $0xf0106818
f0101cf9:	68 ed 03 00 00       	push   $0x3ed
f0101cfe:	68 f2 67 10 f0       	push   $0xf01067f2
f0101d03:	e8 38 e3 ff ff       	call   f0100040 <_panic>

	   // pp2 should NOT be on the free list
	   // could happen in ref counts are handled sloppily in page_insert
	   assert(!page_alloc(0));
f0101d08:	83 ec 0c             	sub    $0xc,%esp
f0101d0b:	6a 00                	push   $0x0
f0101d0d:	e8 d8 f2 ff ff       	call   f0100fea <page_alloc>
f0101d12:	83 c4 10             	add    $0x10,%esp
f0101d15:	85 c0                	test   %eax,%eax
f0101d17:	74 19                	je     f0101d32 <mem_init+0x8f7>
f0101d19:	68 e6 69 10 f0       	push   $0xf01069e6
f0101d1e:	68 18 68 10 f0       	push   $0xf0106818
f0101d23:	68 f1 03 00 00       	push   $0x3f1
f0101d28:	68 f2 67 10 f0       	push   $0xf01067f2
f0101d2d:	e8 0e e3 ff ff       	call   f0100040 <_panic>

	   // check that pgdir_walk returns a pointer to the pte
	   ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d32:	8b 15 8c fe 22 f0    	mov    0xf022fe8c,%edx
f0101d38:	8b 02                	mov    (%edx),%eax
f0101d3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d3f:	89 c1                	mov    %eax,%ecx
f0101d41:	c1 e9 0c             	shr    $0xc,%ecx
f0101d44:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0101d4a:	72 15                	jb     f0101d61 <mem_init+0x926>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d4c:	50                   	push   %eax
f0101d4d:	68 64 62 10 f0       	push   $0xf0106264
f0101d52:	68 f4 03 00 00       	push   $0x3f4
f0101d57:	68 f2 67 10 f0       	push   $0xf01067f2
f0101d5c:	e8 df e2 ff ff       	call   f0100040 <_panic>
f0101d61:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	   assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d69:	83 ec 04             	sub    $0x4,%esp
f0101d6c:	6a 00                	push   $0x0
f0101d6e:	68 00 10 00 00       	push   $0x1000
f0101d73:	52                   	push   %edx
f0101d74:	e8 6b f3 ff ff       	call   f01010e4 <pgdir_walk>
f0101d79:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d7c:	8d 51 04             	lea    0x4(%ecx),%edx
f0101d7f:	83 c4 10             	add    $0x10,%esp
f0101d82:	39 d0                	cmp    %edx,%eax
f0101d84:	74 19                	je     f0101d9f <mem_init+0x964>
f0101d86:	68 dc 6e 10 f0       	push   $0xf0106edc
f0101d8b:	68 18 68 10 f0       	push   $0xf0106818
f0101d90:	68 f5 03 00 00       	push   $0x3f5
f0101d95:	68 f2 67 10 f0       	push   $0xf01067f2
f0101d9a:	e8 a1 e2 ff ff       	call   f0100040 <_panic>

	   // should be able to change permissions too.
	   assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d9f:	6a 06                	push   $0x6
f0101da1:	68 00 10 00 00       	push   $0x1000
f0101da6:	56                   	push   %esi
f0101da7:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101dad:	e8 30 f5 ff ff       	call   f01012e2 <page_insert>
f0101db2:	83 c4 10             	add    $0x10,%esp
f0101db5:	85 c0                	test   %eax,%eax
f0101db7:	74 19                	je     f0101dd2 <mem_init+0x997>
f0101db9:	68 1c 6f 10 f0       	push   $0xf0106f1c
f0101dbe:	68 18 68 10 f0       	push   $0xf0106818
f0101dc3:	68 f8 03 00 00       	push   $0x3f8
f0101dc8:	68 f2 67 10 f0       	push   $0xf01067f2
f0101dcd:	e8 6e e2 ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dd2:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101dd8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ddd:	89 f8                	mov    %edi,%eax
f0101ddf:	e8 19 ed ff ff       	call   f0100afd <check_va2pa>
f0101de4:	89 f2                	mov    %esi,%edx
f0101de6:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101dec:	c1 fa 03             	sar    $0x3,%edx
f0101def:	c1 e2 0c             	shl    $0xc,%edx
f0101df2:	39 d0                	cmp    %edx,%eax
f0101df4:	74 19                	je     f0101e0f <mem_init+0x9d4>
f0101df6:	68 ac 6e 10 f0       	push   $0xf0106eac
f0101dfb:	68 18 68 10 f0       	push   $0xf0106818
f0101e00:	68 f9 03 00 00       	push   $0x3f9
f0101e05:	68 f2 67 10 f0       	push   $0xf01067f2
f0101e0a:	e8 31 e2 ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 1);
f0101e0f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e14:	74 19                	je     f0101e2f <mem_init+0x9f4>
f0101e16:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0101e1b:	68 18 68 10 f0       	push   $0xf0106818
f0101e20:	68 fa 03 00 00       	push   $0x3fa
f0101e25:	68 f2 67 10 f0       	push   $0xf01067f2
f0101e2a:	e8 11 e2 ff ff       	call   f0100040 <_panic>
	   assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e2f:	83 ec 04             	sub    $0x4,%esp
f0101e32:	6a 00                	push   $0x0
f0101e34:	68 00 10 00 00       	push   $0x1000
f0101e39:	57                   	push   %edi
f0101e3a:	e8 a5 f2 ff ff       	call   f01010e4 <pgdir_walk>
f0101e3f:	83 c4 10             	add    $0x10,%esp
f0101e42:	f6 00 04             	testb  $0x4,(%eax)
f0101e45:	75 19                	jne    f0101e60 <mem_init+0xa25>
f0101e47:	68 5c 6f 10 f0       	push   $0xf0106f5c
f0101e4c:	68 18 68 10 f0       	push   $0xf0106818
f0101e51:	68 fb 03 00 00       	push   $0x3fb
f0101e56:	68 f2 67 10 f0       	push   $0xf01067f2
f0101e5b:	e8 e0 e1 ff ff       	call   f0100040 <_panic>
	   assert(kern_pgdir[0] & PTE_U);
f0101e60:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101e65:	f6 00 04             	testb  $0x4,(%eax)
f0101e68:	75 19                	jne    f0101e83 <mem_init+0xa48>
f0101e6a:	68 6b 6a 10 f0       	push   $0xf0106a6b
f0101e6f:	68 18 68 10 f0       	push   $0xf0106818
f0101e74:	68 fc 03 00 00       	push   $0x3fc
f0101e79:	68 f2 67 10 f0       	push   $0xf01067f2
f0101e7e:	e8 bd e1 ff ff       	call   f0100040 <_panic>

	   // should be able to remap with fewer permissions
	   assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e83:	6a 02                	push   $0x2
f0101e85:	68 00 10 00 00       	push   $0x1000
f0101e8a:	56                   	push   %esi
f0101e8b:	50                   	push   %eax
f0101e8c:	e8 51 f4 ff ff       	call   f01012e2 <page_insert>
f0101e91:	83 c4 10             	add    $0x10,%esp
f0101e94:	85 c0                	test   %eax,%eax
f0101e96:	74 19                	je     f0101eb1 <mem_init+0xa76>
f0101e98:	68 70 6e 10 f0       	push   $0xf0106e70
f0101e9d:	68 18 68 10 f0       	push   $0xf0106818
f0101ea2:	68 ff 03 00 00       	push   $0x3ff
f0101ea7:	68 f2 67 10 f0       	push   $0xf01067f2
f0101eac:	e8 8f e1 ff ff       	call   f0100040 <_panic>
	   assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101eb1:	83 ec 04             	sub    $0x4,%esp
f0101eb4:	6a 00                	push   $0x0
f0101eb6:	68 00 10 00 00       	push   $0x1000
f0101ebb:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101ec1:	e8 1e f2 ff ff       	call   f01010e4 <pgdir_walk>
f0101ec6:	83 c4 10             	add    $0x10,%esp
f0101ec9:	f6 00 02             	testb  $0x2,(%eax)
f0101ecc:	75 19                	jne    f0101ee7 <mem_init+0xaac>
f0101ece:	68 90 6f 10 f0       	push   $0xf0106f90
f0101ed3:	68 18 68 10 f0       	push   $0xf0106818
f0101ed8:	68 00 04 00 00       	push   $0x400
f0101edd:	68 f2 67 10 f0       	push   $0xf01067f2
f0101ee2:	e8 59 e1 ff ff       	call   f0100040 <_panic>
	   assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ee7:	83 ec 04             	sub    $0x4,%esp
f0101eea:	6a 00                	push   $0x0
f0101eec:	68 00 10 00 00       	push   $0x1000
f0101ef1:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101ef7:	e8 e8 f1 ff ff       	call   f01010e4 <pgdir_walk>
f0101efc:	83 c4 10             	add    $0x10,%esp
f0101eff:	f6 00 04             	testb  $0x4,(%eax)
f0101f02:	74 19                	je     f0101f1d <mem_init+0xae2>
f0101f04:	68 c4 6f 10 f0       	push   $0xf0106fc4
f0101f09:	68 18 68 10 f0       	push   $0xf0106818
f0101f0e:	68 01 04 00 00       	push   $0x401
f0101f13:	68 f2 67 10 f0       	push   $0xf01067f2
f0101f18:	e8 23 e1 ff ff       	call   f0100040 <_panic>

	   // should not be able to map at PTSIZE because need free page for page table
	   assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f1d:	6a 02                	push   $0x2
f0101f1f:	68 00 00 40 00       	push   $0x400000
f0101f24:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f27:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f2d:	e8 b0 f3 ff ff       	call   f01012e2 <page_insert>
f0101f32:	83 c4 10             	add    $0x10,%esp
f0101f35:	85 c0                	test   %eax,%eax
f0101f37:	78 19                	js     f0101f52 <mem_init+0xb17>
f0101f39:	68 fc 6f 10 f0       	push   $0xf0106ffc
f0101f3e:	68 18 68 10 f0       	push   $0xf0106818
f0101f43:	68 04 04 00 00       	push   $0x404
f0101f48:	68 f2 67 10 f0       	push   $0xf01067f2
f0101f4d:	e8 ee e0 ff ff       	call   f0100040 <_panic>

	   // insert pp1 at PGSIZE (replacing pp2)
	   assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f52:	6a 02                	push   $0x2
f0101f54:	68 00 10 00 00       	push   $0x1000
f0101f59:	53                   	push   %ebx
f0101f5a:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f60:	e8 7d f3 ff ff       	call   f01012e2 <page_insert>
f0101f65:	83 c4 10             	add    $0x10,%esp
f0101f68:	85 c0                	test   %eax,%eax
f0101f6a:	74 19                	je     f0101f85 <mem_init+0xb4a>
f0101f6c:	68 34 70 10 f0       	push   $0xf0107034
f0101f71:	68 18 68 10 f0       	push   $0xf0106818
f0101f76:	68 07 04 00 00       	push   $0x407
f0101f7b:	68 f2 67 10 f0       	push   $0xf01067f2
f0101f80:	e8 bb e0 ff ff       	call   f0100040 <_panic>
	   assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f85:	83 ec 04             	sub    $0x4,%esp
f0101f88:	6a 00                	push   $0x0
f0101f8a:	68 00 10 00 00       	push   $0x1000
f0101f8f:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f95:	e8 4a f1 ff ff       	call   f01010e4 <pgdir_walk>
f0101f9a:	83 c4 10             	add    $0x10,%esp
f0101f9d:	f6 00 04             	testb  $0x4,(%eax)
f0101fa0:	74 19                	je     f0101fbb <mem_init+0xb80>
f0101fa2:	68 c4 6f 10 f0       	push   $0xf0106fc4
f0101fa7:	68 18 68 10 f0       	push   $0xf0106818
f0101fac:	68 08 04 00 00       	push   $0x408
f0101fb1:	68 f2 67 10 f0       	push   $0xf01067f2
f0101fb6:	e8 85 e0 ff ff       	call   f0100040 <_panic>

	   // should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	   assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fbb:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101fc1:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fc6:	89 f8                	mov    %edi,%eax
f0101fc8:	e8 30 eb ff ff       	call   f0100afd <check_va2pa>
f0101fcd:	89 c1                	mov    %eax,%ecx
f0101fcf:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101fd2:	89 d8                	mov    %ebx,%eax
f0101fd4:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101fda:	c1 f8 03             	sar    $0x3,%eax
f0101fdd:	c1 e0 0c             	shl    $0xc,%eax
f0101fe0:	39 c1                	cmp    %eax,%ecx
f0101fe2:	74 19                	je     f0101ffd <mem_init+0xbc2>
f0101fe4:	68 70 70 10 f0       	push   $0xf0107070
f0101fe9:	68 18 68 10 f0       	push   $0xf0106818
f0101fee:	68 0b 04 00 00       	push   $0x40b
f0101ff3:	68 f2 67 10 f0       	push   $0xf01067f2
f0101ff8:	e8 43 e0 ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ffd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102002:	89 f8                	mov    %edi,%eax
f0102004:	e8 f4 ea ff ff       	call   f0100afd <check_va2pa>
f0102009:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010200c:	74 19                	je     f0102027 <mem_init+0xbec>
f010200e:	68 9c 70 10 f0       	push   $0xf010709c
f0102013:	68 18 68 10 f0       	push   $0xf0106818
f0102018:	68 0c 04 00 00       	push   $0x40c
f010201d:	68 f2 67 10 f0       	push   $0xf01067f2
f0102022:	e8 19 e0 ff ff       	call   f0100040 <_panic>
	   // ... and ref counts should reflect this
	   assert(pp1->pp_ref == 2);
f0102027:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010202c:	74 19                	je     f0102047 <mem_init+0xc0c>
f010202e:	68 81 6a 10 f0       	push   $0xf0106a81
f0102033:	68 18 68 10 f0       	push   $0xf0106818
f0102038:	68 0e 04 00 00       	push   $0x40e
f010203d:	68 f2 67 10 f0       	push   $0xf01067f2
f0102042:	e8 f9 df ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 0);
f0102047:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010204c:	74 19                	je     f0102067 <mem_init+0xc2c>
f010204e:	68 92 6a 10 f0       	push   $0xf0106a92
f0102053:	68 18 68 10 f0       	push   $0xf0106818
f0102058:	68 0f 04 00 00       	push   $0x40f
f010205d:	68 f2 67 10 f0       	push   $0xf01067f2
f0102062:	e8 d9 df ff ff       	call   f0100040 <_panic>

	   // pp2 should be returned by page_alloc
	   assert((pp = page_alloc(0)) && pp == pp2);
f0102067:	83 ec 0c             	sub    $0xc,%esp
f010206a:	6a 00                	push   $0x0
f010206c:	e8 79 ef ff ff       	call   f0100fea <page_alloc>
f0102071:	83 c4 10             	add    $0x10,%esp
f0102074:	85 c0                	test   %eax,%eax
f0102076:	74 04                	je     f010207c <mem_init+0xc41>
f0102078:	39 c6                	cmp    %eax,%esi
f010207a:	74 19                	je     f0102095 <mem_init+0xc5a>
f010207c:	68 cc 70 10 f0       	push   $0xf01070cc
f0102081:	68 18 68 10 f0       	push   $0xf0106818
f0102086:	68 12 04 00 00       	push   $0x412
f010208b:	68 f2 67 10 f0       	push   $0xf01067f2
f0102090:	e8 ab df ff ff       	call   f0100040 <_panic>

	   // unmapping pp1 at 0 should keep pp1 at PGSIZE
	   page_remove(kern_pgdir, 0x0);
f0102095:	83 ec 08             	sub    $0x8,%esp
f0102098:	6a 00                	push   $0x0
f010209a:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01020a0:	e8 f0 f1 ff ff       	call   f0101295 <page_remove>
	   assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020a5:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f01020ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01020b0:	89 f8                	mov    %edi,%eax
f01020b2:	e8 46 ea ff ff       	call   f0100afd <check_va2pa>
f01020b7:	83 c4 10             	add    $0x10,%esp
f01020ba:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020bd:	74 19                	je     f01020d8 <mem_init+0xc9d>
f01020bf:	68 f0 70 10 f0       	push   $0xf01070f0
f01020c4:	68 18 68 10 f0       	push   $0xf0106818
f01020c9:	68 16 04 00 00       	push   $0x416
f01020ce:	68 f2 67 10 f0       	push   $0xf01067f2
f01020d3:	e8 68 df ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01020d8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020dd:	89 f8                	mov    %edi,%eax
f01020df:	e8 19 ea ff ff       	call   f0100afd <check_va2pa>
f01020e4:	89 da                	mov    %ebx,%edx
f01020e6:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f01020ec:	c1 fa 03             	sar    $0x3,%edx
f01020ef:	c1 e2 0c             	shl    $0xc,%edx
f01020f2:	39 d0                	cmp    %edx,%eax
f01020f4:	74 19                	je     f010210f <mem_init+0xcd4>
f01020f6:	68 9c 70 10 f0       	push   $0xf010709c
f01020fb:	68 18 68 10 f0       	push   $0xf0106818
f0102100:	68 17 04 00 00       	push   $0x417
f0102105:	68 f2 67 10 f0       	push   $0xf01067f2
f010210a:	e8 31 df ff ff       	call   f0100040 <_panic>
	   assert(pp1->pp_ref == 1);
f010210f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102114:	74 19                	je     f010212f <mem_init+0xcf4>
f0102116:	68 38 6a 10 f0       	push   $0xf0106a38
f010211b:	68 18 68 10 f0       	push   $0xf0106818
f0102120:	68 18 04 00 00       	push   $0x418
f0102125:	68 f2 67 10 f0       	push   $0xf01067f2
f010212a:	e8 11 df ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 0);
f010212f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102134:	74 19                	je     f010214f <mem_init+0xd14>
f0102136:	68 92 6a 10 f0       	push   $0xf0106a92
f010213b:	68 18 68 10 f0       	push   $0xf0106818
f0102140:	68 19 04 00 00       	push   $0x419
f0102145:	68 f2 67 10 f0       	push   $0xf01067f2
f010214a:	e8 f1 de ff ff       	call   f0100040 <_panic>

	   // test re-inserting pp1 at PGSIZE
	   assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010214f:	6a 00                	push   $0x0
f0102151:	68 00 10 00 00       	push   $0x1000
f0102156:	53                   	push   %ebx
f0102157:	57                   	push   %edi
f0102158:	e8 85 f1 ff ff       	call   f01012e2 <page_insert>
f010215d:	83 c4 10             	add    $0x10,%esp
f0102160:	85 c0                	test   %eax,%eax
f0102162:	74 19                	je     f010217d <mem_init+0xd42>
f0102164:	68 14 71 10 f0       	push   $0xf0107114
f0102169:	68 18 68 10 f0       	push   $0xf0106818
f010216e:	68 1c 04 00 00       	push   $0x41c
f0102173:	68 f2 67 10 f0       	push   $0xf01067f2
f0102178:	e8 c3 de ff ff       	call   f0100040 <_panic>
	   assert(pp1->pp_ref);
f010217d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102182:	75 19                	jne    f010219d <mem_init+0xd62>
f0102184:	68 a3 6a 10 f0       	push   $0xf0106aa3
f0102189:	68 18 68 10 f0       	push   $0xf0106818
f010218e:	68 1d 04 00 00       	push   $0x41d
f0102193:	68 f2 67 10 f0       	push   $0xf01067f2
f0102198:	e8 a3 de ff ff       	call   f0100040 <_panic>
	   assert(pp1->pp_link == NULL);
f010219d:	83 3b 00             	cmpl   $0x0,(%ebx)
f01021a0:	74 19                	je     f01021bb <mem_init+0xd80>
f01021a2:	68 af 6a 10 f0       	push   $0xf0106aaf
f01021a7:	68 18 68 10 f0       	push   $0xf0106818
f01021ac:	68 1e 04 00 00       	push   $0x41e
f01021b1:	68 f2 67 10 f0       	push   $0xf01067f2
f01021b6:	e8 85 de ff ff       	call   f0100040 <_panic>

	   // unmapping pp1 at PGSIZE should free it
	   page_remove(kern_pgdir, (void*) PGSIZE);
f01021bb:	83 ec 08             	sub    $0x8,%esp
f01021be:	68 00 10 00 00       	push   $0x1000
f01021c3:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01021c9:	e8 c7 f0 ff ff       	call   f0101295 <page_remove>
	   assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021ce:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f01021d4:	ba 00 00 00 00       	mov    $0x0,%edx
f01021d9:	89 f8                	mov    %edi,%eax
f01021db:	e8 1d e9 ff ff       	call   f0100afd <check_va2pa>
f01021e0:	83 c4 10             	add    $0x10,%esp
f01021e3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021e6:	74 19                	je     f0102201 <mem_init+0xdc6>
f01021e8:	68 f0 70 10 f0       	push   $0xf01070f0
f01021ed:	68 18 68 10 f0       	push   $0xf0106818
f01021f2:	68 22 04 00 00       	push   $0x422
f01021f7:	68 f2 67 10 f0       	push   $0xf01067f2
f01021fc:	e8 3f de ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102201:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102206:	89 f8                	mov    %edi,%eax
f0102208:	e8 f0 e8 ff ff       	call   f0100afd <check_va2pa>
f010220d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102210:	74 19                	je     f010222b <mem_init+0xdf0>
f0102212:	68 4c 71 10 f0       	push   $0xf010714c
f0102217:	68 18 68 10 f0       	push   $0xf0106818
f010221c:	68 23 04 00 00       	push   $0x423
f0102221:	68 f2 67 10 f0       	push   $0xf01067f2
f0102226:	e8 15 de ff ff       	call   f0100040 <_panic>
	   assert(pp1->pp_ref == 0);
f010222b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102230:	74 19                	je     f010224b <mem_init+0xe10>
f0102232:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102237:	68 18 68 10 f0       	push   $0xf0106818
f010223c:	68 24 04 00 00       	push   $0x424
f0102241:	68 f2 67 10 f0       	push   $0xf01067f2
f0102246:	e8 f5 dd ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 0);
f010224b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102250:	74 19                	je     f010226b <mem_init+0xe30>
f0102252:	68 92 6a 10 f0       	push   $0xf0106a92
f0102257:	68 18 68 10 f0       	push   $0xf0106818
f010225c:	68 25 04 00 00       	push   $0x425
f0102261:	68 f2 67 10 f0       	push   $0xf01067f2
f0102266:	e8 d5 dd ff ff       	call   f0100040 <_panic>

	   // so it should be returned by page_alloc
	   assert((pp = page_alloc(0)) && pp == pp1);
f010226b:	83 ec 0c             	sub    $0xc,%esp
f010226e:	6a 00                	push   $0x0
f0102270:	e8 75 ed ff ff       	call   f0100fea <page_alloc>
f0102275:	83 c4 10             	add    $0x10,%esp
f0102278:	39 c3                	cmp    %eax,%ebx
f010227a:	75 04                	jne    f0102280 <mem_init+0xe45>
f010227c:	85 c0                	test   %eax,%eax
f010227e:	75 19                	jne    f0102299 <mem_init+0xe5e>
f0102280:	68 74 71 10 f0       	push   $0xf0107174
f0102285:	68 18 68 10 f0       	push   $0xf0106818
f010228a:	68 28 04 00 00       	push   $0x428
f010228f:	68 f2 67 10 f0       	push   $0xf01067f2
f0102294:	e8 a7 dd ff ff       	call   f0100040 <_panic>

	   // should be no free memory
	   assert(!page_alloc(0));
f0102299:	83 ec 0c             	sub    $0xc,%esp
f010229c:	6a 00                	push   $0x0
f010229e:	e8 47 ed ff ff       	call   f0100fea <page_alloc>
f01022a3:	83 c4 10             	add    $0x10,%esp
f01022a6:	85 c0                	test   %eax,%eax
f01022a8:	74 19                	je     f01022c3 <mem_init+0xe88>
f01022aa:	68 e6 69 10 f0       	push   $0xf01069e6
f01022af:	68 18 68 10 f0       	push   $0xf0106818
f01022b4:	68 2b 04 00 00       	push   $0x42b
f01022b9:	68 f2 67 10 f0       	push   $0xf01067f2
f01022be:	e8 7d dd ff ff       	call   f0100040 <_panic>

	   // forcibly take pp0 back
	   assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022c3:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f01022c9:	8b 11                	mov    (%ecx),%edx
f01022cb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01022d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022d4:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f01022da:	c1 f8 03             	sar    $0x3,%eax
f01022dd:	c1 e0 0c             	shl    $0xc,%eax
f01022e0:	39 c2                	cmp    %eax,%edx
f01022e2:	74 19                	je     f01022fd <mem_init+0xec2>
f01022e4:	68 18 6e 10 f0       	push   $0xf0106e18
f01022e9:	68 18 68 10 f0       	push   $0xf0106818
f01022ee:	68 2e 04 00 00       	push   $0x42e
f01022f3:	68 f2 67 10 f0       	push   $0xf01067f2
f01022f8:	e8 43 dd ff ff       	call   f0100040 <_panic>
	   kern_pgdir[0] = 0;
f01022fd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	   assert(pp0->pp_ref == 1);
f0102303:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102306:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010230b:	74 19                	je     f0102326 <mem_init+0xeeb>
f010230d:	68 49 6a 10 f0       	push   $0xf0106a49
f0102312:	68 18 68 10 f0       	push   $0xf0106818
f0102317:	68 30 04 00 00       	push   $0x430
f010231c:	68 f2 67 10 f0       	push   $0xf01067f2
f0102321:	e8 1a dd ff ff       	call   f0100040 <_panic>
	   pp0->pp_ref = 0;
f0102326:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102329:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	   // check pointer arithmetic in pgdir_walk
	   page_free(pp0);
f010232f:	83 ec 0c             	sub    $0xc,%esp
f0102332:	50                   	push   %eax
f0102333:	e8 29 ed ff ff       	call   f0101061 <page_free>
	   va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	   ptep = pgdir_walk(kern_pgdir, va, 1);
f0102338:	83 c4 0c             	add    $0xc,%esp
f010233b:	6a 01                	push   $0x1
f010233d:	68 00 10 40 00       	push   $0x401000
f0102342:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102348:	e8 97 ed ff ff       	call   f01010e4 <pgdir_walk>
f010234d:	89 c7                	mov    %eax,%edi
f010234f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	   ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102352:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102357:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010235a:	8b 40 04             	mov    0x4(%eax),%eax
f010235d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102362:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f0102368:	89 c2                	mov    %eax,%edx
f010236a:	c1 ea 0c             	shr    $0xc,%edx
f010236d:	83 c4 10             	add    $0x10,%esp
f0102370:	39 ca                	cmp    %ecx,%edx
f0102372:	72 15                	jb     f0102389 <mem_init+0xf4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102374:	50                   	push   %eax
f0102375:	68 64 62 10 f0       	push   $0xf0106264
f010237a:	68 37 04 00 00       	push   $0x437
f010237f:	68 f2 67 10 f0       	push   $0xf01067f2
f0102384:	e8 b7 dc ff ff       	call   f0100040 <_panic>
	   assert(ptep == ptep1 + PTX(va));
f0102389:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010238e:	39 c7                	cmp    %eax,%edi
f0102390:	74 19                	je     f01023ab <mem_init+0xf70>
f0102392:	68 d5 6a 10 f0       	push   $0xf0106ad5
f0102397:	68 18 68 10 f0       	push   $0xf0106818
f010239c:	68 38 04 00 00       	push   $0x438
f01023a1:	68 f2 67 10 f0       	push   $0xf01067f2
f01023a6:	e8 95 dc ff ff       	call   f0100040 <_panic>
	   kern_pgdir[PDX(va)] = 0;
f01023ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01023ae:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	   pp0->pp_ref = 0;
f01023b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023b8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023be:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f01023c4:	c1 f8 03             	sar    $0x3,%eax
f01023c7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023ca:	89 c2                	mov    %eax,%edx
f01023cc:	c1 ea 0c             	shr    $0xc,%edx
f01023cf:	39 d1                	cmp    %edx,%ecx
f01023d1:	77 12                	ja     f01023e5 <mem_init+0xfaa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023d3:	50                   	push   %eax
f01023d4:	68 64 62 10 f0       	push   $0xf0106264
f01023d9:	6a 58                	push   $0x58
f01023db:	68 fe 67 10 f0       	push   $0xf01067fe
f01023e0:	e8 5b dc ff ff       	call   f0100040 <_panic>

	   // check that new page tables get cleared
	   memset(page2kva(pp0), 0xFF, PGSIZE);
f01023e5:	83 ec 04             	sub    $0x4,%esp
f01023e8:	68 00 10 00 00       	push   $0x1000
f01023ed:	68 ff 00 00 00       	push   $0xff
f01023f2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023f7:	50                   	push   %eax
f01023f8:	e8 8a 31 00 00       	call   f0105587 <memset>
	   page_free(pp0);
f01023fd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102400:	89 3c 24             	mov    %edi,(%esp)
f0102403:	e8 59 ec ff ff       	call   f0101061 <page_free>
	   pgdir_walk(kern_pgdir, 0x0, 1);
f0102408:	83 c4 0c             	add    $0xc,%esp
f010240b:	6a 01                	push   $0x1
f010240d:	6a 00                	push   $0x0
f010240f:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102415:	e8 ca ec ff ff       	call   f01010e4 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010241a:	89 fa                	mov    %edi,%edx
f010241c:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0102422:	c1 fa 03             	sar    $0x3,%edx
f0102425:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102428:	89 d0                	mov    %edx,%eax
f010242a:	c1 e8 0c             	shr    $0xc,%eax
f010242d:	83 c4 10             	add    $0x10,%esp
f0102430:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0102436:	72 12                	jb     f010244a <mem_init+0x100f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102438:	52                   	push   %edx
f0102439:	68 64 62 10 f0       	push   $0xf0106264
f010243e:	6a 58                	push   $0x58
f0102440:	68 fe 67 10 f0       	push   $0xf01067fe
f0102445:	e8 f6 db ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010244a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	   ptep = (pte_t *) page2kva(pp0);
f0102450:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102453:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	   for(i=0; i<NPTENTRIES; i++)
			 assert((ptep[i] & PTE_P) == 0);
f0102459:	f6 00 01             	testb  $0x1,(%eax)
f010245c:	74 19                	je     f0102477 <mem_init+0x103c>
f010245e:	68 ed 6a 10 f0       	push   $0xf0106aed
f0102463:	68 18 68 10 f0       	push   $0xf0106818
f0102468:	68 42 04 00 00       	push   $0x442
f010246d:	68 f2 67 10 f0       	push   $0xf01067f2
f0102472:	e8 c9 db ff ff       	call   f0100040 <_panic>
f0102477:	83 c0 04             	add    $0x4,%eax
	   // check that new page tables get cleared
	   memset(page2kva(pp0), 0xFF, PGSIZE);
	   page_free(pp0);
	   pgdir_walk(kern_pgdir, 0x0, 1);
	   ptep = (pte_t *) page2kva(pp0);
	   for(i=0; i<NPTENTRIES; i++)
f010247a:	39 d0                	cmp    %edx,%eax
f010247c:	75 db                	jne    f0102459 <mem_init+0x101e>
			 assert((ptep[i] & PTE_P) == 0);
	   kern_pgdir[0] = 0;
f010247e:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102483:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	   pp0->pp_ref = 0;
f0102489:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010248c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	   // give free list back
	   page_free_list = fl;
f0102492:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102495:	89 0d 40 f2 22 f0    	mov    %ecx,0xf022f240

	   // free the pages we took
	   page_free(pp0);
f010249b:	83 ec 0c             	sub    $0xc,%esp
f010249e:	50                   	push   %eax
f010249f:	e8 bd eb ff ff       	call   f0101061 <page_free>
	   page_free(pp1);
f01024a4:	89 1c 24             	mov    %ebx,(%esp)
f01024a7:	e8 b5 eb ff ff       	call   f0101061 <page_free>
	   page_free(pp2);
f01024ac:	89 34 24             	mov    %esi,(%esp)
f01024af:	e8 ad eb ff ff       	call   f0101061 <page_free>

	   // test mmio_map_region
	   mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01024b4:	83 c4 08             	add    $0x8,%esp
f01024b7:	68 01 10 00 00       	push   $0x1001
f01024bc:	6a 00                	push   $0x0
f01024be:	e8 f3 ee ff ff       	call   f01013b6 <mmio_map_region>
f01024c3:	89 c3                	mov    %eax,%ebx
	   mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01024c5:	83 c4 08             	add    $0x8,%esp
f01024c8:	68 00 10 00 00       	push   $0x1000
f01024cd:	6a 00                	push   $0x0
f01024cf:	e8 e2 ee ff ff       	call   f01013b6 <mmio_map_region>
f01024d4:	89 c6                	mov    %eax,%esi
	   // check that they're in the right region
	   assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01024d6:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f01024dc:	83 c4 10             	add    $0x10,%esp
f01024df:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01024e5:	76 07                	jbe    f01024ee <mem_init+0x10b3>
f01024e7:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01024ec:	76 19                	jbe    f0102507 <mem_init+0x10cc>
f01024ee:	68 98 71 10 f0       	push   $0xf0107198
f01024f3:	68 18 68 10 f0       	push   $0xf0106818
f01024f8:	68 52 04 00 00       	push   $0x452
f01024fd:	68 f2 67 10 f0       	push   $0xf01067f2
f0102502:	e8 39 db ff ff       	call   f0100040 <_panic>
	   assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102507:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f010250d:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102513:	77 08                	ja     f010251d <mem_init+0x10e2>
f0102515:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010251b:	77 19                	ja     f0102536 <mem_init+0x10fb>
f010251d:	68 c0 71 10 f0       	push   $0xf01071c0
f0102522:	68 18 68 10 f0       	push   $0xf0106818
f0102527:	68 53 04 00 00       	push   $0x453
f010252c:	68 f2 67 10 f0       	push   $0xf01067f2
f0102531:	e8 0a db ff ff       	call   f0100040 <_panic>
	   // check that they're page-aligned
	   assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102536:	89 da                	mov    %ebx,%edx
f0102538:	09 f2                	or     %esi,%edx
f010253a:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102540:	74 19                	je     f010255b <mem_init+0x1120>
f0102542:	68 e8 71 10 f0       	push   $0xf01071e8
f0102547:	68 18 68 10 f0       	push   $0xf0106818
f010254c:	68 55 04 00 00       	push   $0x455
f0102551:	68 f2 67 10 f0       	push   $0xf01067f2
f0102556:	e8 e5 da ff ff       	call   f0100040 <_panic>
	   // check that they don't overlap
	   assert(mm1 + 8192 <= mm2);
f010255b:	39 c6                	cmp    %eax,%esi
f010255d:	73 19                	jae    f0102578 <mem_init+0x113d>
f010255f:	68 04 6b 10 f0       	push   $0xf0106b04
f0102564:	68 18 68 10 f0       	push   $0xf0106818
f0102569:	68 57 04 00 00       	push   $0x457
f010256e:	68 f2 67 10 f0       	push   $0xf01067f2
f0102573:	e8 c8 da ff ff       	call   f0100040 <_panic>
	   // check page mappings
	   assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102578:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f010257e:	89 da                	mov    %ebx,%edx
f0102580:	89 f8                	mov    %edi,%eax
f0102582:	e8 76 e5 ff ff       	call   f0100afd <check_va2pa>
f0102587:	85 c0                	test   %eax,%eax
f0102589:	74 19                	je     f01025a4 <mem_init+0x1169>
f010258b:	68 10 72 10 f0       	push   $0xf0107210
f0102590:	68 18 68 10 f0       	push   $0xf0106818
f0102595:	68 59 04 00 00       	push   $0x459
f010259a:	68 f2 67 10 f0       	push   $0xf01067f2
f010259f:	e8 9c da ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01025a4:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01025aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01025ad:	89 c2                	mov    %eax,%edx
f01025af:	89 f8                	mov    %edi,%eax
f01025b1:	e8 47 e5 ff ff       	call   f0100afd <check_va2pa>
f01025b6:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01025bb:	74 19                	je     f01025d6 <mem_init+0x119b>
f01025bd:	68 34 72 10 f0       	push   $0xf0107234
f01025c2:	68 18 68 10 f0       	push   $0xf0106818
f01025c7:	68 5a 04 00 00       	push   $0x45a
f01025cc:	68 f2 67 10 f0       	push   $0xf01067f2
f01025d1:	e8 6a da ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, mm2) == 0);
f01025d6:	89 f2                	mov    %esi,%edx
f01025d8:	89 f8                	mov    %edi,%eax
f01025da:	e8 1e e5 ff ff       	call   f0100afd <check_va2pa>
f01025df:	85 c0                	test   %eax,%eax
f01025e1:	74 19                	je     f01025fc <mem_init+0x11c1>
f01025e3:	68 64 72 10 f0       	push   $0xf0107264
f01025e8:	68 18 68 10 f0       	push   $0xf0106818
f01025ed:	68 5b 04 00 00       	push   $0x45b
f01025f2:	68 f2 67 10 f0       	push   $0xf01067f2
f01025f7:	e8 44 da ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01025fc:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102602:	89 f8                	mov    %edi,%eax
f0102604:	e8 f4 e4 ff ff       	call   f0100afd <check_va2pa>
f0102609:	83 f8 ff             	cmp    $0xffffffff,%eax
f010260c:	74 19                	je     f0102627 <mem_init+0x11ec>
f010260e:	68 88 72 10 f0       	push   $0xf0107288
f0102613:	68 18 68 10 f0       	push   $0xf0106818
f0102618:	68 5c 04 00 00       	push   $0x45c
f010261d:	68 f2 67 10 f0       	push   $0xf01067f2
f0102622:	e8 19 da ff ff       	call   f0100040 <_panic>
	   // check permissions
	   assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102627:	83 ec 04             	sub    $0x4,%esp
f010262a:	6a 00                	push   $0x0
f010262c:	53                   	push   %ebx
f010262d:	57                   	push   %edi
f010262e:	e8 b1 ea ff ff       	call   f01010e4 <pgdir_walk>
f0102633:	83 c4 10             	add    $0x10,%esp
f0102636:	f6 00 1a             	testb  $0x1a,(%eax)
f0102639:	75 19                	jne    f0102654 <mem_init+0x1219>
f010263b:	68 b4 72 10 f0       	push   $0xf01072b4
f0102640:	68 18 68 10 f0       	push   $0xf0106818
f0102645:	68 5e 04 00 00       	push   $0x45e
f010264a:	68 f2 67 10 f0       	push   $0xf01067f2
f010264f:	e8 ec d9 ff ff       	call   f0100040 <_panic>
	   assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102654:	83 ec 04             	sub    $0x4,%esp
f0102657:	6a 00                	push   $0x0
f0102659:	53                   	push   %ebx
f010265a:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102660:	e8 7f ea ff ff       	call   f01010e4 <pgdir_walk>
f0102665:	8b 00                	mov    (%eax),%eax
f0102667:	83 c4 10             	add    $0x10,%esp
f010266a:	83 e0 04             	and    $0x4,%eax
f010266d:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102670:	74 19                	je     f010268b <mem_init+0x1250>
f0102672:	68 f8 72 10 f0       	push   $0xf01072f8
f0102677:	68 18 68 10 f0       	push   $0xf0106818
f010267c:	68 5f 04 00 00       	push   $0x45f
f0102681:	68 f2 67 10 f0       	push   $0xf01067f2
f0102686:	e8 b5 d9 ff ff       	call   f0100040 <_panic>
	   // clear the mappings
	   *pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010268b:	83 ec 04             	sub    $0x4,%esp
f010268e:	6a 00                	push   $0x0
f0102690:	53                   	push   %ebx
f0102691:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102697:	e8 48 ea ff ff       	call   f01010e4 <pgdir_walk>
f010269c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	   *pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01026a2:	83 c4 0c             	add    $0xc,%esp
f01026a5:	6a 00                	push   $0x0
f01026a7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01026aa:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01026b0:	e8 2f ea ff ff       	call   f01010e4 <pgdir_walk>
f01026b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	   *pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01026bb:	83 c4 0c             	add    $0xc,%esp
f01026be:	6a 00                	push   $0x0
f01026c0:	56                   	push   %esi
f01026c1:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01026c7:	e8 18 ea ff ff       	call   f01010e4 <pgdir_walk>
f01026cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	   cprintf("check_page() succeeded!\n");
f01026d2:	c7 04 24 16 6b 10 f0 	movl   $0xf0106b16,(%esp)
f01026d9:	e8 76 11 00 00       	call   f0103854 <cprintf>
	   //    - the new image at UPAGES -- kernel R, user R
	   //      (ie. perm = PTE_U | PTE_P)
	   //    - pages itself -- kernel RW, user NONE
	   // Your code goes here:

	   boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f01026de:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026e3:	83 c4 10             	add    $0x10,%esp
f01026e6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026eb:	77 15                	ja     f0102702 <mem_init+0x12c7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026ed:	50                   	push   %eax
f01026ee:	68 88 62 10 f0       	push   $0xf0106288
f01026f3:	68 c7 00 00 00       	push   $0xc7
f01026f8:	68 f2 67 10 f0       	push   $0xf01067f2
f01026fd:	e8 3e d9 ff ff       	call   f0100040 <_panic>
f0102702:	83 ec 08             	sub    $0x8,%esp
f0102705:	6a 05                	push   $0x5
f0102707:	05 00 00 00 10       	add    $0x10000000,%eax
f010270c:	50                   	push   %eax
f010270d:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102712:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102717:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f010271c:	e8 60 ea ff ff       	call   f0101181 <boot_map_region>
	   // (ie. perm = PTE_U | PTE_P).
	   // Permissions:
	   //    - the new image at UENVS  -- kernel R, user R
	   //    - envs itself -- kernel RW, user NONE
	   // LAB 3: Your code here.
	   boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f0102721:	a1 48 f2 22 f0       	mov    0xf022f248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102726:	83 c4 10             	add    $0x10,%esp
f0102729:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010272e:	77 15                	ja     f0102745 <mem_init+0x130a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102730:	50                   	push   %eax
f0102731:	68 88 62 10 f0       	push   $0xf0106288
f0102736:	68 d0 00 00 00       	push   $0xd0
f010273b:	68 f2 67 10 f0       	push   $0xf01067f2
f0102740:	e8 fb d8 ff ff       	call   f0100040 <_panic>
f0102745:	83 ec 08             	sub    $0x8,%esp
f0102748:	6a 05                	push   $0x5
f010274a:	05 00 00 00 10       	add    $0x10000000,%eax
f010274f:	50                   	push   %eax
f0102750:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102755:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010275a:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f010275f:	e8 1d ea ff ff       	call   f0101181 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102764:	83 c4 10             	add    $0x10,%esp
f0102767:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f010276c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102771:	77 15                	ja     f0102788 <mem_init+0x134d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102773:	50                   	push   %eax
f0102774:	68 88 62 10 f0       	push   $0xf0106288
f0102779:	68 de 00 00 00       	push   $0xde
f010277e:	68 f2 67 10 f0       	push   $0xf01067f2
f0102783:	e8 b8 d8 ff ff       	call   f0100040 <_panic>
	   //       the kernel overflows its stack, it will fault rather than
	   //       overwrite memory.  Known as a "guard page".
	   //     Permissions: kernel RW, user NONE
	   // Your code goes here:
	   uintptr_t address = KSTACKTOP - KSTKSIZE;
	   boot_map_region (kern_pgdir, address, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f0102788:	83 ec 08             	sub    $0x8,%esp
f010278b:	6a 03                	push   $0x3
f010278d:	68 00 60 11 00       	push   $0x116000
f0102792:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102797:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010279c:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01027a1:	e8 db e9 ff ff       	call   f0101181 <boot_map_region>
	   // We might not have 2^32 - KERNBASE bytes of physical memory, but
	   // we just set up the mapping anyway.
	   // Permissions: kernel RW, user NONE
	   // Your code goes here:
	   uint32_t pa_range = 0xFFFFFFFF - KERNBASE +1;
	   boot_map_region (kern_pgdir, KERNBASE, pa_range, 0, PTE_W | PTE_P);
f01027a6:	83 c4 08             	add    $0x8,%esp
f01027a9:	6a 03                	push   $0x3
f01027ab:	6a 00                	push   $0x0
f01027ad:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01027b2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01027b7:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01027bc:	e8 c0 e9 ff ff       	call   f0101181 <boot_map_region>
f01027c1:	c7 45 c4 00 10 23 f0 	movl   $0xf0231000,-0x3c(%ebp)
f01027c8:	83 c4 10             	add    $0x10,%esp
f01027cb:	bb 00 10 23 f0       	mov    $0xf0231000,%ebx
f01027d0:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027d5:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01027db:	77 15                	ja     f01027f2 <mem_init+0x13b7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027dd:	53                   	push   %ebx
f01027de:	68 88 62 10 f0       	push   $0xf0106288
f01027e3:	68 21 01 00 00       	push   $0x121
f01027e8:	68 f2 67 10 f0       	push   $0xf01067f2
f01027ed:	e8 4e d8 ff ff       	call   f0100040 <_panic>
	   //
	   // LAB 4: Your code here:
		 for (int i = 0; i < NCPU; i ++)
		 {
		 uintptr_t stack_start = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
		 boot_map_region (kern_pgdir, stack_start - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W | PTE_P);
f01027f2:	83 ec 08             	sub    $0x8,%esp
f01027f5:	6a 03                	push   $0x3
f01027f7:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01027fd:	50                   	push   %eax
f01027fe:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102803:	89 f2                	mov    %esi,%edx
f0102805:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f010280a:	e8 72 e9 ff ff       	call   f0101181 <boot_map_region>
f010280f:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102815:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	   //             it will fault rather than overwrite another CPU's stack.
	   //             Known as a "guard page".
	   //     Permissions: kernel RW, user NONE
	   //
	   // LAB 4: Your code here:
		 for (int i = 0; i < NCPU; i ++)
f010281b:	83 c4 10             	add    $0x10,%esp
f010281e:	b8 00 10 27 f0       	mov    $0xf0271000,%eax
f0102823:	39 d8                	cmp    %ebx,%eax
f0102825:	75 ae                	jne    f01027d5 <mem_init+0x139a>
{

	   uint32_t i, n;
	   pde_t *pgdir;

	   pgdir = kern_pgdir;
f0102827:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi

	   // check pages array
	   n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010282d:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0102832:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102835:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010283c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102841:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	   for (i = 0; i < n; i += PGSIZE)
			 assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102844:	8b 35 90 fe 22 f0    	mov    0xf022fe90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010284a:	89 75 d0             	mov    %esi,-0x30(%ebp)

	   pgdir = kern_pgdir;

	   // check pages array
	   n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
f010284d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102852:	eb 55                	jmp    f01028a9 <mem_init+0x146e>
			 assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102854:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010285a:	89 f8                	mov    %edi,%eax
f010285c:	e8 9c e2 ff ff       	call   f0100afd <check_va2pa>
f0102861:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102868:	77 15                	ja     f010287f <mem_init+0x1444>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010286a:	56                   	push   %esi
f010286b:	68 88 62 10 f0       	push   $0xf0106288
f0102870:	68 76 03 00 00       	push   $0x376
f0102875:	68 f2 67 10 f0       	push   $0xf01067f2
f010287a:	e8 c1 d7 ff ff       	call   f0100040 <_panic>
f010287f:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102886:	39 c2                	cmp    %eax,%edx
f0102888:	74 19                	je     f01028a3 <mem_init+0x1468>
f010288a:	68 2c 73 10 f0       	push   $0xf010732c
f010288f:	68 18 68 10 f0       	push   $0xf0106818
f0102894:	68 76 03 00 00       	push   $0x376
f0102899:	68 f2 67 10 f0       	push   $0xf01067f2
f010289e:	e8 9d d7 ff ff       	call   f0100040 <_panic>

	   pgdir = kern_pgdir;

	   // check pages array
	   n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
f01028a3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028a9:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01028ac:	77 a6                	ja     f0102854 <mem_init+0x1419>
			 assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	   // check envs array (new test for lab 3)
	   n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
			 assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028ae:	8b 35 48 f2 22 f0    	mov    0xf022f248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028b4:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01028b7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01028bc:	89 da                	mov    %ebx,%edx
f01028be:	89 f8                	mov    %edi,%eax
f01028c0:	e8 38 e2 ff ff       	call   f0100afd <check_va2pa>
f01028c5:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01028cc:	77 15                	ja     f01028e3 <mem_init+0x14a8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028ce:	56                   	push   %esi
f01028cf:	68 88 62 10 f0       	push   $0xf0106288
f01028d4:	68 7b 03 00 00       	push   $0x37b
f01028d9:	68 f2 67 10 f0       	push   $0xf01067f2
f01028de:	e8 5d d7 ff ff       	call   f0100040 <_panic>
f01028e3:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01028ea:	39 d0                	cmp    %edx,%eax
f01028ec:	74 19                	je     f0102907 <mem_init+0x14cc>
f01028ee:	68 60 73 10 f0       	push   $0xf0107360
f01028f3:	68 18 68 10 f0       	push   $0xf0106818
f01028f8:	68 7b 03 00 00       	push   $0x37b
f01028fd:	68 f2 67 10 f0       	push   $0xf01067f2
f0102902:	e8 39 d7 ff ff       	call   f0100040 <_panic>
f0102907:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	   for (i = 0; i < n; i += PGSIZE)
			 assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	   // check envs array (new test for lab 3)
	   n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
f010290d:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102913:	75 a7                	jne    f01028bc <mem_init+0x1481>
			 assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	   // check phys mem
	   for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102915:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102918:	c1 e6 0c             	shl    $0xc,%esi
f010291b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102920:	eb 30                	jmp    f0102952 <mem_init+0x1517>
			 assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102922:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102928:	89 f8                	mov    %edi,%eax
f010292a:	e8 ce e1 ff ff       	call   f0100afd <check_va2pa>
f010292f:	39 c3                	cmp    %eax,%ebx
f0102931:	74 19                	je     f010294c <mem_init+0x1511>
f0102933:	68 94 73 10 f0       	push   $0xf0107394
f0102938:	68 18 68 10 f0       	push   $0xf0106818
f010293d:	68 7f 03 00 00       	push   $0x37f
f0102942:	68 f2 67 10 f0       	push   $0xf01067f2
f0102947:	e8 f4 d6 ff ff       	call   f0100040 <_panic>
	   n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
			 assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	   // check phys mem
	   for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010294c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102952:	39 f3                	cmp    %esi,%ebx
f0102954:	72 cc                	jb     f0102922 <mem_init+0x14e7>
f0102956:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010295b:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010295e:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102961:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102964:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f010296a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010296d:	89 c3                	mov    %eax,%ebx
	   // check kernel stack
	   // (updated in lab 4 to check per-CPU kernel stacks)
	   for (n = 0; n < NCPU; n++) {
			 uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
			 for (i = 0; i < KSTKSIZE; i += PGSIZE)
				    assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010296f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102972:	05 00 80 00 20       	add    $0x20008000,%eax
f0102977:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010297a:	89 da                	mov    %ebx,%edx
f010297c:	89 f8                	mov    %edi,%eax
f010297e:	e8 7a e1 ff ff       	call   f0100afd <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102983:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102989:	77 15                	ja     f01029a0 <mem_init+0x1565>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010298b:	56                   	push   %esi
f010298c:	68 88 62 10 f0       	push   $0xf0106288
f0102991:	68 87 03 00 00       	push   $0x387
f0102996:	68 f2 67 10 f0       	push   $0xf01067f2
f010299b:	e8 a0 d6 ff ff       	call   f0100040 <_panic>
f01029a0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01029a3:	8d 94 0b 00 10 23 f0 	lea    -0xfdcf000(%ebx,%ecx,1),%edx
f01029aa:	39 d0                	cmp    %edx,%eax
f01029ac:	74 19                	je     f01029c7 <mem_init+0x158c>
f01029ae:	68 bc 73 10 f0       	push   $0xf01073bc
f01029b3:	68 18 68 10 f0       	push   $0xf0106818
f01029b8:	68 87 03 00 00       	push   $0x387
f01029bd:	68 f2 67 10 f0       	push   $0xf01067f2
f01029c2:	e8 79 d6 ff ff       	call   f0100040 <_panic>
f01029c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	   // check kernel stack
	   // (updated in lab 4 to check per-CPU kernel stacks)
	   for (n = 0; n < NCPU; n++) {
			 uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
			 for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029cd:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f01029d0:	75 a8                	jne    f010297a <mem_init+0x153f>
f01029d2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01029d5:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01029db:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01029de:	89 c6                	mov    %eax,%esi
				    assert(check_va2pa(pgdir, base + KSTKGAP + i)
								== PADDR(percpu_kstacks[n]) + i);
			 for (i = 0; i < KSTKGAP; i += PGSIZE)
				    assert(check_va2pa(pgdir, base + i) == ~0);
f01029e0:	89 da                	mov    %ebx,%edx
f01029e2:	89 f8                	mov    %edi,%eax
f01029e4:	e8 14 e1 ff ff       	call   f0100afd <check_va2pa>
f01029e9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029ec:	74 19                	je     f0102a07 <mem_init+0x15cc>
f01029ee:	68 04 74 10 f0       	push   $0xf0107404
f01029f3:	68 18 68 10 f0       	push   $0xf0106818
f01029f8:	68 89 03 00 00       	push   $0x389
f01029fd:	68 f2 67 10 f0       	push   $0xf01067f2
f0102a02:	e8 39 d6 ff ff       	call   f0100040 <_panic>
f0102a07:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	   for (n = 0; n < NCPU; n++) {
			 uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
			 for (i = 0; i < KSTKSIZE; i += PGSIZE)
				    assert(check_va2pa(pgdir, base + KSTKGAP + i)
								== PADDR(percpu_kstacks[n]) + i);
			 for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a0d:	39 f3                	cmp    %esi,%ebx
f0102a0f:	75 cf                	jne    f01029e0 <mem_init+0x15a5>
f0102a11:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102a14:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102a1b:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102a22:	81 c6 00 80 00 00    	add    $0x8000,%esi
	   for (i = 0; i < npages * PGSIZE; i += PGSIZE)
			 assert(check_va2pa(pgdir, KERNBASE + i) == i);

	   // check kernel stack
	   // (updated in lab 4 to check per-CPU kernel stacks)
	   for (n = 0; n < NCPU; n++) {
f0102a28:	b8 00 10 27 f0       	mov    $0xf0271000,%eax
f0102a2d:	39 f0                	cmp    %esi,%eax
f0102a2f:	0f 85 2c ff ff ff    	jne    f0102961 <mem_init+0x1526>
f0102a35:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a3a:	eb 2a                	jmp    f0102a66 <mem_init+0x162b>
				    assert(check_va2pa(pgdir, base + i) == ~0);
	   }

	   // check PDE permissions
	   for (i = 0; i < NPDENTRIES; i++) {
			 switch (i) {
f0102a3c:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102a42:	83 fa 04             	cmp    $0x4,%edx
f0102a45:	77 1f                	ja     f0102a66 <mem_init+0x162b>
				    case PDX(UVPT):
				    case PDX(KSTACKTOP-1):
				    case PDX(UPAGES):
				    case PDX(UENVS):
				    case PDX(MMIOBASE):
						  assert(pgdir[i] & PTE_P);
f0102a47:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a4b:	75 7e                	jne    f0102acb <mem_init+0x1690>
f0102a4d:	68 2f 6b 10 f0       	push   $0xf0106b2f
f0102a52:	68 18 68 10 f0       	push   $0xf0106818
f0102a57:	68 94 03 00 00       	push   $0x394
f0102a5c:	68 f2 67 10 f0       	push   $0xf01067f2
f0102a61:	e8 da d5 ff ff       	call   f0100040 <_panic>
						  break;
				    default:
						  if (i >= PDX(KERNBASE)) {
f0102a66:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a6b:	76 3f                	jbe    f0102aac <mem_init+0x1671>
								assert(pgdir[i] & PTE_P);
f0102a6d:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102a70:	f6 c2 01             	test   $0x1,%dl
f0102a73:	75 19                	jne    f0102a8e <mem_init+0x1653>
f0102a75:	68 2f 6b 10 f0       	push   $0xf0106b2f
f0102a7a:	68 18 68 10 f0       	push   $0xf0106818
f0102a7f:	68 98 03 00 00       	push   $0x398
f0102a84:	68 f2 67 10 f0       	push   $0xf01067f2
f0102a89:	e8 b2 d5 ff ff       	call   f0100040 <_panic>
								assert(pgdir[i] & PTE_W);
f0102a8e:	f6 c2 02             	test   $0x2,%dl
f0102a91:	75 38                	jne    f0102acb <mem_init+0x1690>
f0102a93:	68 40 6b 10 f0       	push   $0xf0106b40
f0102a98:	68 18 68 10 f0       	push   $0xf0106818
f0102a9d:	68 99 03 00 00       	push   $0x399
f0102aa2:	68 f2 67 10 f0       	push   $0xf01067f2
f0102aa7:	e8 94 d5 ff ff       	call   f0100040 <_panic>
						  } else
								assert(pgdir[i] == 0);
f0102aac:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102ab0:	74 19                	je     f0102acb <mem_init+0x1690>
f0102ab2:	68 51 6b 10 f0       	push   $0xf0106b51
f0102ab7:	68 18 68 10 f0       	push   $0xf0106818
f0102abc:	68 9b 03 00 00       	push   $0x39b
f0102ac1:	68 f2 67 10 f0       	push   $0xf01067f2
f0102ac6:	e8 75 d5 ff ff       	call   f0100040 <_panic>
			 for (i = 0; i < KSTKGAP; i += PGSIZE)
				    assert(check_va2pa(pgdir, base + i) == ~0);
	   }

	   // check PDE permissions
	   for (i = 0; i < NPDENTRIES; i++) {
f0102acb:	83 c0 01             	add    $0x1,%eax
f0102ace:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102ad3:	0f 86 63 ff ff ff    	jbe    f0102a3c <mem_init+0x1601>
						  } else
								assert(pgdir[i] == 0);
						  break;
			 }
	   }
	   cprintf("check_kern_pgdir() succeeded!\n");
f0102ad9:	83 ec 0c             	sub    $0xc,%esp
f0102adc:	68 28 74 10 f0       	push   $0xf0107428
f0102ae1:	e8 6e 0d 00 00       	call   f0103854 <cprintf>
	   // somewhere between KERNBASE and KERNBASE+4MB right now, which is
	   // mapped the same way by both page tables.
	   //
	   // If the machine reboots at this point, you've probably set up your
	   // kern_pgdir wrong.
	   lcr3(PADDR(kern_pgdir));
f0102ae6:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102aeb:	83 c4 10             	add    $0x10,%esp
f0102aee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102af3:	77 15                	ja     f0102b0a <mem_init+0x16cf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102af5:	50                   	push   %eax
f0102af6:	68 88 62 10 f0       	push   $0xf0106288
f0102afb:	68 f9 00 00 00       	push   $0xf9
f0102b00:	68 f2 67 10 f0       	push   $0xf01067f2
f0102b05:	e8 36 d5 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b0a:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b0f:	0f 22 d8             	mov    %eax,%cr3

	   check_page_free_list(0);
f0102b12:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b17:	e8 45 e0 ff ff       	call   f0100b61 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b1c:	0f 20 c0             	mov    %cr0,%eax
f0102b1f:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b22:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102b27:	0f 22 c0             	mov    %eax,%cr0
	   uintptr_t va;
	   int i;

	   // check that we can read and write installed pages
	   pp1 = pp2 = 0;
	   assert((pp0 = page_alloc(0)));
f0102b2a:	83 ec 0c             	sub    $0xc,%esp
f0102b2d:	6a 00                	push   $0x0
f0102b2f:	e8 b6 e4 ff ff       	call   f0100fea <page_alloc>
f0102b34:	89 c3                	mov    %eax,%ebx
f0102b36:	83 c4 10             	add    $0x10,%esp
f0102b39:	85 c0                	test   %eax,%eax
f0102b3b:	75 19                	jne    f0102b56 <mem_init+0x171b>
f0102b3d:	68 3b 69 10 f0       	push   $0xf010693b
f0102b42:	68 18 68 10 f0       	push   $0xf0106818
f0102b47:	68 74 04 00 00       	push   $0x474
f0102b4c:	68 f2 67 10 f0       	push   $0xf01067f2
f0102b51:	e8 ea d4 ff ff       	call   f0100040 <_panic>
	   assert((pp1 = page_alloc(0)));
f0102b56:	83 ec 0c             	sub    $0xc,%esp
f0102b59:	6a 00                	push   $0x0
f0102b5b:	e8 8a e4 ff ff       	call   f0100fea <page_alloc>
f0102b60:	89 c7                	mov    %eax,%edi
f0102b62:	83 c4 10             	add    $0x10,%esp
f0102b65:	85 c0                	test   %eax,%eax
f0102b67:	75 19                	jne    f0102b82 <mem_init+0x1747>
f0102b69:	68 51 69 10 f0       	push   $0xf0106951
f0102b6e:	68 18 68 10 f0       	push   $0xf0106818
f0102b73:	68 75 04 00 00       	push   $0x475
f0102b78:	68 f2 67 10 f0       	push   $0xf01067f2
f0102b7d:	e8 be d4 ff ff       	call   f0100040 <_panic>
	   assert((pp2 = page_alloc(0)));
f0102b82:	83 ec 0c             	sub    $0xc,%esp
f0102b85:	6a 00                	push   $0x0
f0102b87:	e8 5e e4 ff ff       	call   f0100fea <page_alloc>
f0102b8c:	89 c6                	mov    %eax,%esi
f0102b8e:	83 c4 10             	add    $0x10,%esp
f0102b91:	85 c0                	test   %eax,%eax
f0102b93:	75 19                	jne    f0102bae <mem_init+0x1773>
f0102b95:	68 67 69 10 f0       	push   $0xf0106967
f0102b9a:	68 18 68 10 f0       	push   $0xf0106818
f0102b9f:	68 76 04 00 00       	push   $0x476
f0102ba4:	68 f2 67 10 f0       	push   $0xf01067f2
f0102ba9:	e8 92 d4 ff ff       	call   f0100040 <_panic>
	   page_free(pp0);
f0102bae:	83 ec 0c             	sub    $0xc,%esp
f0102bb1:	53                   	push   %ebx
f0102bb2:	e8 aa e4 ff ff       	call   f0101061 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bb7:	89 f8                	mov    %edi,%eax
f0102bb9:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102bbf:	c1 f8 03             	sar    $0x3,%eax
f0102bc2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bc5:	89 c2                	mov    %eax,%edx
f0102bc7:	c1 ea 0c             	shr    $0xc,%edx
f0102bca:	83 c4 10             	add    $0x10,%esp
f0102bcd:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102bd3:	72 12                	jb     f0102be7 <mem_init+0x17ac>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bd5:	50                   	push   %eax
f0102bd6:	68 64 62 10 f0       	push   $0xf0106264
f0102bdb:	6a 58                	push   $0x58
f0102bdd:	68 fe 67 10 f0       	push   $0xf01067fe
f0102be2:	e8 59 d4 ff ff       	call   f0100040 <_panic>
	   memset(page2kva(pp1), 1, PGSIZE);
f0102be7:	83 ec 04             	sub    $0x4,%esp
f0102bea:	68 00 10 00 00       	push   $0x1000
f0102bef:	6a 01                	push   $0x1
f0102bf1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bf6:	50                   	push   %eax
f0102bf7:	e8 8b 29 00 00       	call   f0105587 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bfc:	89 f0                	mov    %esi,%eax
f0102bfe:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102c04:	c1 f8 03             	sar    $0x3,%eax
f0102c07:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c0a:	89 c2                	mov    %eax,%edx
f0102c0c:	c1 ea 0c             	shr    $0xc,%edx
f0102c0f:	83 c4 10             	add    $0x10,%esp
f0102c12:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102c18:	72 12                	jb     f0102c2c <mem_init+0x17f1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c1a:	50                   	push   %eax
f0102c1b:	68 64 62 10 f0       	push   $0xf0106264
f0102c20:	6a 58                	push   $0x58
f0102c22:	68 fe 67 10 f0       	push   $0xf01067fe
f0102c27:	e8 14 d4 ff ff       	call   f0100040 <_panic>
	   memset(page2kva(pp2), 2, PGSIZE);
f0102c2c:	83 ec 04             	sub    $0x4,%esp
f0102c2f:	68 00 10 00 00       	push   $0x1000
f0102c34:	6a 02                	push   $0x2
f0102c36:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c3b:	50                   	push   %eax
f0102c3c:	e8 46 29 00 00       	call   f0105587 <memset>
	   page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c41:	6a 02                	push   $0x2
f0102c43:	68 00 10 00 00       	push   $0x1000
f0102c48:	57                   	push   %edi
f0102c49:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102c4f:	e8 8e e6 ff ff       	call   f01012e2 <page_insert>
	   assert(pp1->pp_ref == 1);
f0102c54:	83 c4 20             	add    $0x20,%esp
f0102c57:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c5c:	74 19                	je     f0102c77 <mem_init+0x183c>
f0102c5e:	68 38 6a 10 f0       	push   $0xf0106a38
f0102c63:	68 18 68 10 f0       	push   $0xf0106818
f0102c68:	68 7b 04 00 00       	push   $0x47b
f0102c6d:	68 f2 67 10 f0       	push   $0xf01067f2
f0102c72:	e8 c9 d3 ff ff       	call   f0100040 <_panic>
	   assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c77:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c7e:	01 01 01 
f0102c81:	74 19                	je     f0102c9c <mem_init+0x1861>
f0102c83:	68 48 74 10 f0       	push   $0xf0107448
f0102c88:	68 18 68 10 f0       	push   $0xf0106818
f0102c8d:	68 7c 04 00 00       	push   $0x47c
f0102c92:	68 f2 67 10 f0       	push   $0xf01067f2
f0102c97:	e8 a4 d3 ff ff       	call   f0100040 <_panic>
	   page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c9c:	6a 02                	push   $0x2
f0102c9e:	68 00 10 00 00       	push   $0x1000
f0102ca3:	56                   	push   %esi
f0102ca4:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102caa:	e8 33 e6 ff ff       	call   f01012e2 <page_insert>
	   assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102caf:	83 c4 10             	add    $0x10,%esp
f0102cb2:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cb9:	02 02 02 
f0102cbc:	74 19                	je     f0102cd7 <mem_init+0x189c>
f0102cbe:	68 6c 74 10 f0       	push   $0xf010746c
f0102cc3:	68 18 68 10 f0       	push   $0xf0106818
f0102cc8:	68 7e 04 00 00       	push   $0x47e
f0102ccd:	68 f2 67 10 f0       	push   $0xf01067f2
f0102cd2:	e8 69 d3 ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 1);
f0102cd7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cdc:	74 19                	je     f0102cf7 <mem_init+0x18bc>
f0102cde:	68 5a 6a 10 f0       	push   $0xf0106a5a
f0102ce3:	68 18 68 10 f0       	push   $0xf0106818
f0102ce8:	68 7f 04 00 00       	push   $0x47f
f0102ced:	68 f2 67 10 f0       	push   $0xf01067f2
f0102cf2:	e8 49 d3 ff ff       	call   f0100040 <_panic>
	   assert(pp1->pp_ref == 0);
f0102cf7:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cfc:	74 19                	je     f0102d17 <mem_init+0x18dc>
f0102cfe:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102d03:	68 18 68 10 f0       	push   $0xf0106818
f0102d08:	68 80 04 00 00       	push   $0x480
f0102d0d:	68 f2 67 10 f0       	push   $0xf01067f2
f0102d12:	e8 29 d3 ff ff       	call   f0100040 <_panic>
	   *(uint32_t *)PGSIZE = 0x03030303U;
f0102d17:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d1e:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d21:	89 f0                	mov    %esi,%eax
f0102d23:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102d29:	c1 f8 03             	sar    $0x3,%eax
f0102d2c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d2f:	89 c2                	mov    %eax,%edx
f0102d31:	c1 ea 0c             	shr    $0xc,%edx
f0102d34:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102d3a:	72 12                	jb     f0102d4e <mem_init+0x1913>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d3c:	50                   	push   %eax
f0102d3d:	68 64 62 10 f0       	push   $0xf0106264
f0102d42:	6a 58                	push   $0x58
f0102d44:	68 fe 67 10 f0       	push   $0xf01067fe
f0102d49:	e8 f2 d2 ff ff       	call   f0100040 <_panic>
	   assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d4e:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d55:	03 03 03 
f0102d58:	74 19                	je     f0102d73 <mem_init+0x1938>
f0102d5a:	68 90 74 10 f0       	push   $0xf0107490
f0102d5f:	68 18 68 10 f0       	push   $0xf0106818
f0102d64:	68 82 04 00 00       	push   $0x482
f0102d69:	68 f2 67 10 f0       	push   $0xf01067f2
f0102d6e:	e8 cd d2 ff ff       	call   f0100040 <_panic>
	   page_remove(kern_pgdir, (void*) PGSIZE);
f0102d73:	83 ec 08             	sub    $0x8,%esp
f0102d76:	68 00 10 00 00       	push   $0x1000
f0102d7b:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102d81:	e8 0f e5 ff ff       	call   f0101295 <page_remove>
	   assert(pp2->pp_ref == 0);
f0102d86:	83 c4 10             	add    $0x10,%esp
f0102d89:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d8e:	74 19                	je     f0102da9 <mem_init+0x196e>
f0102d90:	68 92 6a 10 f0       	push   $0xf0106a92
f0102d95:	68 18 68 10 f0       	push   $0xf0106818
f0102d9a:	68 84 04 00 00       	push   $0x484
f0102d9f:	68 f2 67 10 f0       	push   $0xf01067f2
f0102da4:	e8 97 d2 ff ff       	call   f0100040 <_panic>

	   // forcibly take pp0 back
	   assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102da9:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f0102daf:	8b 11                	mov    (%ecx),%edx
f0102db1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102db7:	89 d8                	mov    %ebx,%eax
f0102db9:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102dbf:	c1 f8 03             	sar    $0x3,%eax
f0102dc2:	c1 e0 0c             	shl    $0xc,%eax
f0102dc5:	39 c2                	cmp    %eax,%edx
f0102dc7:	74 19                	je     f0102de2 <mem_init+0x19a7>
f0102dc9:	68 18 6e 10 f0       	push   $0xf0106e18
f0102dce:	68 18 68 10 f0       	push   $0xf0106818
f0102dd3:	68 87 04 00 00       	push   $0x487
f0102dd8:	68 f2 67 10 f0       	push   $0xf01067f2
f0102ddd:	e8 5e d2 ff ff       	call   f0100040 <_panic>
	   kern_pgdir[0] = 0;
f0102de2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	   assert(pp0->pp_ref == 1);
f0102de8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102ded:	74 19                	je     f0102e08 <mem_init+0x19cd>
f0102def:	68 49 6a 10 f0       	push   $0xf0106a49
f0102df4:	68 18 68 10 f0       	push   $0xf0106818
f0102df9:	68 89 04 00 00       	push   $0x489
f0102dfe:	68 f2 67 10 f0       	push   $0xf01067f2
f0102e03:	e8 38 d2 ff ff       	call   f0100040 <_panic>
	   pp0->pp_ref = 0;
f0102e08:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	   // free the pages we took
	   page_free(pp0);
f0102e0e:	83 ec 0c             	sub    $0xc,%esp
f0102e11:	53                   	push   %ebx
f0102e12:	e8 4a e2 ff ff       	call   f0101061 <page_free>

	   cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e17:	c7 04 24 bc 74 10 f0 	movl   $0xf01074bc,(%esp)
f0102e1e:	e8 31 0a 00 00       	call   f0103854 <cprintf>
	   cr0 &= ~(CR0_TS|CR0_EM);
	   lcr0(cr0);

	   // Some more checks, only possible after kern_pgdir is installed.
	   check_page_installed_pgdir();
}
f0102e23:	83 c4 10             	add    $0x10,%esp
f0102e26:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e29:	5b                   	pop    %ebx
f0102e2a:	5e                   	pop    %esi
f0102e2b:	5f                   	pop    %edi
f0102e2c:	5d                   	pop    %ebp
f0102e2d:	c3                   	ret    

f0102e2e <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
	   int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e2e:	55                   	push   %ebp
f0102e2f:	89 e5                	mov    %esp,%ebp
f0102e31:	57                   	push   %edi
f0102e32:	56                   	push   %esi
f0102e33:	53                   	push   %ebx
f0102e34:	83 ec 2c             	sub    $0x2c,%esp
f0102e37:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
	   // LAB 3: Your code here.

	   for (char* a = (char*) va; a < (char*) va + len; a = ROUNDDOWN (a + PGSIZE, PGSIZE))
f0102e3d:	89 c3                	mov    %eax,%ebx
f0102e3f:	03 45 10             	add    0x10(%ebp),%eax
f0102e42:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	   {
			 pte_t* pte = NULL;
			 struct PageInfo* mapped_page = page_lookup (env -> env_pgdir, (void*) a, &pte);
f0102e45:	8d 75 e4             	lea    -0x1c(%ebp),%esi
	   int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	   // LAB 3: Your code here.

	   for (char* a = (char*) va; a < (char*) va + len; a = ROUNDDOWN (a + PGSIZE, PGSIZE))
f0102e48:	eb 49                	jmp    f0102e93 <user_mem_check+0x65>
	   {
			 pte_t* pte = NULL;
f0102e4a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			 struct PageInfo* mapped_page = page_lookup (env -> env_pgdir, (void*) a, &pte);
f0102e51:	83 ec 04             	sub    $0x4,%esp
f0102e54:	56                   	push   %esi
f0102e55:	53                   	push   %ebx
f0102e56:	ff 77 60             	pushl  0x60(%edi)
f0102e59:	e8 9c e3 ff ff       	call   f01011fa <page_lookup>

			 if ((!mapped_page) || !(*pte & (perm | PTE_P)) || ((uintptr_t)a >= ULIM))
f0102e5e:	83 c4 10             	add    $0x10,%esp
f0102e61:	85 c0                	test   %eax,%eax
f0102e63:	74 15                	je     f0102e7a <user_mem_check+0x4c>
f0102e65:	8b 55 14             	mov    0x14(%ebp),%edx
f0102e68:	83 ca 01             	or     $0x1,%edx
f0102e6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e6e:	85 10                	test   %edx,(%eax)
f0102e70:	74 08                	je     f0102e7a <user_mem_check+0x4c>
f0102e72:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102e78:	76 0d                	jbe    f0102e87 <user_mem_check+0x59>
			 {
				    user_mem_check_addr = (uintptr_t) a;
f0102e7a:	89 1d 3c f2 22 f0    	mov    %ebx,0xf022f23c
				    return -E_FAULT;
f0102e80:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e85:	eb 16                	jmp    f0102e9d <user_mem_check+0x6f>
	   int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	   // LAB 3: Your code here.

	   for (char* a = (char*) va; a < (char*) va + len; a = ROUNDDOWN (a + PGSIZE, PGSIZE))
f0102e87:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e8d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102e93:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102e96:	72 b2                	jb     f0102e4a <user_mem_check+0x1c>
			 {
				    user_mem_check_addr = (uintptr_t) a;
				    return -E_FAULT;
			 }
	   }
	   return 0;
f0102e98:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ea0:	5b                   	pop    %ebx
f0102ea1:	5e                   	pop    %esi
f0102ea2:	5f                   	pop    %edi
f0102ea3:	5d                   	pop    %ebp
f0102ea4:	c3                   	ret    

f0102ea5 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
	   void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102ea5:	55                   	push   %ebp
f0102ea6:	89 e5                	mov    %esp,%ebp
f0102ea8:	53                   	push   %ebx
f0102ea9:	83 ec 04             	sub    $0x4,%esp
f0102eac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102eaf:	8b 45 14             	mov    0x14(%ebp),%eax
f0102eb2:	83 c8 04             	or     $0x4,%eax
f0102eb5:	50                   	push   %eax
f0102eb6:	ff 75 10             	pushl  0x10(%ebp)
f0102eb9:	ff 75 0c             	pushl  0xc(%ebp)
f0102ebc:	53                   	push   %ebx
f0102ebd:	e8 6c ff ff ff       	call   f0102e2e <user_mem_check>
f0102ec2:	83 c4 10             	add    $0x10,%esp
f0102ec5:	85 c0                	test   %eax,%eax
f0102ec7:	79 21                	jns    f0102eea <user_mem_assert+0x45>
			 cprintf("[%08x] user_mem_check assertion failure for "
f0102ec9:	83 ec 04             	sub    $0x4,%esp
f0102ecc:	ff 35 3c f2 22 f0    	pushl  0xf022f23c
f0102ed2:	ff 73 48             	pushl  0x48(%ebx)
f0102ed5:	68 e8 74 10 f0       	push   $0xf01074e8
f0102eda:	e8 75 09 00 00       	call   f0103854 <cprintf>
						  "va %08x\n", env->env_id, user_mem_check_addr);
			 env_destroy(env);	// may not return
f0102edf:	89 1c 24             	mov    %ebx,(%esp)
f0102ee2:	e8 a4 06 00 00       	call   f010358b <env_destroy>
f0102ee7:	83 c4 10             	add    $0x10,%esp
	   }
}
f0102eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102eed:	c9                   	leave  
f0102eee:	c3                   	ret    

f0102eef <region_alloc>:
	   // Hint: It is easier to use region_alloc if the caller can pass
	   //   'va' and 'len' values that are not page-aligned.
	   //   You should round va down, and round (va + len) up.
	   //   (Watch out for corner-cases!)

	   if (len == 0)
f0102eef:	85 c9                	test   %ecx,%ecx
f0102ef1:	0f 84 97 00 00 00    	je     f0102f8e <region_alloc+0x9f>
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
	   static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102ef7:	55                   	push   %ebp
f0102ef8:	89 e5                	mov    %esp,%ebp
f0102efa:	57                   	push   %edi
f0102efb:	56                   	push   %esi
f0102efc:	53                   	push   %ebx
f0102efd:	83 ec 1c             	sub    $0x1c,%esp
f0102f00:	89 d3                	mov    %edx,%ebx
f0102f02:	89 c7                	mov    %eax,%edi
	   //   (Watch out for corner-cases!)

	   if (len == 0)
			 return;

	   uintptr_t h_addr = ROUNDUP ((uintptr_t) va + len, PGSIZE);
f0102f04:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
	   uintptr_t l_addr = ROUNDDOWN ((uintptr_t) va, PGSIZE);
f0102f0b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f16:	29 d8                	sub    %ebx,%eax
f0102f18:	c1 e8 0c             	shr    $0xc,%eax
f0102f1b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	   uintptr_t page_count = (h_addr - l_addr) / PGSIZE;

	   for (int i = 0; i < page_count; i ++)
f0102f1e:	be 00 00 00 00       	mov    $0x0,%esi
f0102f23:	eb 5d                	jmp    f0102f82 <region_alloc+0x93>
	   {
			 struct PageInfo* new_page = page_alloc(ALLOC_ZERO);
f0102f25:	83 ec 0c             	sub    $0xc,%esp
f0102f28:	6a 01                	push   $0x1
f0102f2a:	e8 bb e0 ff ff       	call   f0100fea <page_alloc>
			 assert (new_page);
f0102f2f:	83 c4 10             	add    $0x10,%esp
f0102f32:	85 c0                	test   %eax,%eax
f0102f34:	75 19                	jne    f0102f4f <region_alloc+0x60>
f0102f36:	68 1d 75 10 f0       	push   $0xf010751d
f0102f3b:	68 18 68 10 f0       	push   $0xf0106818
f0102f40:	68 36 01 00 00       	push   $0x136
f0102f45:	68 26 75 10 f0       	push   $0xf0107526
f0102f4a:	e8 f1 d0 ff ff       	call   f0100040 <_panic>

			 void* addr = (void *) (l_addr + (i * PGSIZE));
			 if ((page_insert(e -> env_pgdir, new_page, addr, PTE_U | PTE_W)) < 0)
f0102f4f:	6a 06                	push   $0x6
f0102f51:	53                   	push   %ebx
f0102f52:	50                   	push   %eax
f0102f53:	ff 77 60             	pushl  0x60(%edi)
f0102f56:	e8 87 e3 ff ff       	call   f01012e2 <page_insert>
f0102f5b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f61:	83 c4 10             	add    $0x10,%esp
f0102f64:	85 c0                	test   %eax,%eax
f0102f66:	79 17                	jns    f0102f7f <region_alloc+0x90>
				    panic ("Page Insert Failed \n");
f0102f68:	83 ec 04             	sub    $0x4,%esp
f0102f6b:	68 31 75 10 f0       	push   $0xf0107531
f0102f70:	68 3a 01 00 00       	push   $0x13a
f0102f75:	68 26 75 10 f0       	push   $0xf0107526
f0102f7a:	e8 c1 d0 ff ff       	call   f0100040 <_panic>

	   uintptr_t h_addr = ROUNDUP ((uintptr_t) va + len, PGSIZE);
	   uintptr_t l_addr = ROUNDDOWN ((uintptr_t) va, PGSIZE);
	   uintptr_t page_count = (h_addr - l_addr) / PGSIZE;

	   for (int i = 0; i < page_count; i ++)
f0102f7f:	83 c6 01             	add    $0x1,%esi
f0102f82:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0102f85:	75 9e                	jne    f0102f25 <region_alloc+0x36>

			 void* addr = (void *) (l_addr + (i * PGSIZE));
			 if ((page_insert(e -> env_pgdir, new_page, addr, PTE_U | PTE_W)) < 0)
				    panic ("Page Insert Failed \n");
	   }
}
f0102f87:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f8a:	5b                   	pop    %ebx
f0102f8b:	5e                   	pop    %esi
f0102f8c:	5f                   	pop    %edi
f0102f8d:	5d                   	pop    %ebp
f0102f8e:	f3 c3                	repz ret 

f0102f90 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
	   int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f90:	55                   	push   %ebp
f0102f91:	89 e5                	mov    %esp,%ebp
f0102f93:	56                   	push   %esi
f0102f94:	53                   	push   %ebx
f0102f95:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f98:	8b 55 10             	mov    0x10(%ebp),%edx
	   struct Env *e;

	   // If envid is zero, return the current environment.
	   if (envid == 0) {
f0102f9b:	85 c0                	test   %eax,%eax
f0102f9d:	75 1a                	jne    f0102fb9 <envid2env+0x29>
			 *env_store = curenv;
f0102f9f:	e8 06 2c 00 00       	call   f0105baa <cpunum>
f0102fa4:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fa7:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0102fad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102fb0:	89 01                	mov    %eax,(%ecx)
			 return 0;
f0102fb2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fb7:	eb 70                	jmp    f0103029 <envid2env+0x99>
	   // Look up the Env structure via the index part of the envid,
	   // then check the env_id field in that struct Env
	   // to ensure that the envid is not stale
	   // (i.e., does not refer to a _previous_ environment
	   // that used the same slot in the envs[] array).
	   e = &envs[ENVX(envid)];
f0102fb9:	89 c3                	mov    %eax,%ebx
f0102fbb:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102fc1:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102fc4:	03 1d 48 f2 22 f0    	add    0xf022f248,%ebx
	   if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102fca:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102fce:	74 05                	je     f0102fd5 <envid2env+0x45>
f0102fd0:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102fd3:	74 10                	je     f0102fe5 <envid2env+0x55>
			 *env_store = 0;
f0102fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			 return -E_BAD_ENV;
f0102fde:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fe3:	eb 44                	jmp    f0103029 <envid2env+0x99>
	   // Check that the calling environment has legitimate permission
	   // to manipulate the specified environment.
	   // If checkperm is set, the specified environment
	   // must be either the current environment
	   // or an immediate child of the current environment.
	   if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fe5:	84 d2                	test   %dl,%dl
f0102fe7:	74 36                	je     f010301f <envid2env+0x8f>
f0102fe9:	e8 bc 2b 00 00       	call   f0105baa <cpunum>
f0102fee:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ff1:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f0102ff7:	74 26                	je     f010301f <envid2env+0x8f>
f0102ff9:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102ffc:	e8 a9 2b 00 00       	call   f0105baa <cpunum>
f0103001:	6b c0 74             	imul   $0x74,%eax,%eax
f0103004:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010300a:	3b 70 48             	cmp    0x48(%eax),%esi
f010300d:	74 10                	je     f010301f <envid2env+0x8f>
			 *env_store = 0;
f010300f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103012:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			 return -E_BAD_ENV;
f0103018:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010301d:	eb 0a                	jmp    f0103029 <envid2env+0x99>
	   }

	   *env_store = e;
f010301f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103022:	89 18                	mov    %ebx,(%eax)
	   return 0;
f0103024:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103029:	5b                   	pop    %ebx
f010302a:	5e                   	pop    %esi
f010302b:	5d                   	pop    %ebp
f010302c:	c3                   	ret    

f010302d <env_init_percpu>:
}

// Load GDT and segment descriptors.
	   void
env_init_percpu(void)
{
f010302d:	55                   	push   %ebp
f010302e:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0103030:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0103035:	0f 01 10             	lgdtl  (%eax)
	   lgdt(&gdt_pd);
	   // The kernel never uses GS or FS, so we leave those set to
	   // the user data segment.
	   asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103038:	b8 23 00 00 00       	mov    $0x23,%eax
f010303d:	8e e8                	mov    %eax,%gs
	   asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010303f:	8e e0                	mov    %eax,%fs
	   // The kernel does use ES, DS, and SS.  We'll change between
	   // the kernel and user data segments as needed.
	   asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103041:	b8 10 00 00 00       	mov    $0x10,%eax
f0103046:	8e c0                	mov    %eax,%es
	   asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103048:	8e d8                	mov    %eax,%ds
	   asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010304a:	8e d0                	mov    %eax,%ss
	   // Load the kernel text segment into CS.
	   asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010304c:	ea 53 30 10 f0 08 00 	ljmp   $0x8,$0xf0103053
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0103053:	b8 00 00 00 00       	mov    $0x0,%eax
f0103058:	0f 00 d0             	lldt   %ax
	   // For good measure, clear the local descriptor table (LDT),
	   // since we don't use it.
	   lldt(0);
}
f010305b:	5d                   	pop    %ebp
f010305c:	c3                   	ret    

f010305d <env_init>:
env_init(void)
{
	   // Set up envs array
	   // LAB 3: Your code here.

	   env_free_list = &envs[0];
f010305d:	8b 0d 48 f2 22 f0    	mov    0xf022f248,%ecx
f0103063:	89 0d 4c f2 22 f0    	mov    %ecx,0xf022f24c
	   envs[0].env_id = 0;
f0103069:	c7 41 48 00 00 00 00 	movl   $0x0,0x48(%ecx)
f0103070:	8d 41 7c             	lea    0x7c(%ecx),%eax
f0103073:	8d 91 00 f0 01 00    	lea    0x1f000(%ecx),%edx

	   for (int i = 1; i < NENV; i++)
	   {
			 envs [i-1].env_link = &envs[i];
f0103079:	89 40 c8             	mov    %eax,-0x38(%eax)
			 envs [i].env_id = 0;
f010307c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
f0103083:	83 c0 7c             	add    $0x7c,%eax
	   // LAB 3: Your code here.

	   env_free_list = &envs[0];
	   envs[0].env_id = 0;

	   for (int i = 1; i < NENV; i++)
f0103086:	39 d0                	cmp    %edx,%eax
f0103088:	75 ef                	jne    f0103079 <env_init+0x1c>
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
	   void
env_init(void)
{
f010308a:	55                   	push   %ebp
f010308b:	89 e5                	mov    %esp,%ebp
	   {
			 envs [i-1].env_link = &envs[i];
			 envs [i].env_id = 0;
	   }

	   envs [NENV - 1].env_link = NULL;
f010308d:	c7 81 c8 ef 01 00 00 	movl   $0x0,0x1efc8(%ecx)
f0103094:	00 00 00 
	   // Per-CPU part of the initialization
	   env_init_percpu();
f0103097:	e8 91 ff ff ff       	call   f010302d <env_init_percpu>
}
f010309c:	5d                   	pop    %ebp
f010309d:	c3                   	ret    

f010309e <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
	   int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010309e:	55                   	push   %ebp
f010309f:	89 e5                	mov    %esp,%ebp
f01030a1:	57                   	push   %edi
f01030a2:	56                   	push   %esi
f01030a3:	53                   	push   %ebx
f01030a4:	83 ec 1c             	sub    $0x1c,%esp
	   int32_t generation;
	   int r;
	   struct Env *e;

	   if (!(e = env_free_list))
f01030a7:	8b 1d 4c f2 22 f0    	mov    0xf022f24c,%ebx
f01030ad:	85 db                	test   %ebx,%ebx
f01030af:	0f 84 6d 01 00 00    	je     f0103222 <env_alloc+0x184>
{
	   int i;
	   struct PageInfo *p = NULL;

	   // Allocate a page for the page directory
	   if (!(p = page_alloc(ALLOC_ZERO)))
f01030b5:	83 ec 0c             	sub    $0xc,%esp
f01030b8:	6a 01                	push   $0x1
f01030ba:	e8 2b df ff ff       	call   f0100fea <page_alloc>
f01030bf:	89 c6                	mov    %eax,%esi
f01030c1:	83 c4 10             	add    $0x10,%esp
f01030c4:	85 c0                	test   %eax,%eax
f01030c6:	0f 84 5d 01 00 00    	je     f0103229 <env_alloc+0x18b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01030cc:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f01030d2:	c1 f8 03             	sar    $0x3,%eax
f01030d5:	c1 e0 0c             	shl    $0xc,%eax
f01030d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030db:	c1 e8 0c             	shr    $0xc,%eax
f01030de:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01030e4:	72 14                	jb     f01030fa <env_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030e6:	ff 75 e4             	pushl  -0x1c(%ebp)
f01030e9:	68 64 62 10 f0       	push   $0xf0106264
f01030ee:	6a 58                	push   $0x58
f01030f0:	68 fe 67 10 f0       	push   $0xf01067fe
f01030f5:	e8 46 cf ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01030fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030fd:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
	   //    - The functions in kern/pmap.h are handy.

	   // LAB 3: Your code here.

	   pde_t *e_pgdir = page2kva(p);
	   memcpy(e_pgdir, kern_pgdir, PGSIZE);
f0103103:	83 ec 04             	sub    $0x4,%esp
f0103106:	68 00 10 00 00       	push   $0x1000
f010310b:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0103111:	57                   	push   %edi
f0103112:	e8 25 25 00 00       	call   f010563c <memcpy>
	   p->pp_ref++;
f0103117:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	   e->env_pgdir = e_pgdir;
f010311c:	89 7b 60             	mov    %edi,0x60(%ebx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010311f:	83 c4 10             	add    $0x10,%esp
f0103122:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0103128:	77 15                	ja     f010313f <env_alloc+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010312a:	57                   	push   %edi
f010312b:	68 88 62 10 f0       	push   $0xf0106288
f0103130:	68 cc 00 00 00       	push   $0xcc
f0103135:	68 26 75 10 f0       	push   $0xf0107526
f010313a:	e8 01 cf ff ff       	call   f0100040 <_panic>
	   // UVPT maps the env's own page table read-only.
	   // Permissions: kernel R, user R
	   e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010313f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103142:	83 c8 05             	or     $0x5,%eax
f0103145:	89 87 f4 0e 00 00    	mov    %eax,0xef4(%edi)
	   // Allocate and set up the page directory for this environment.
	   if ((r = env_setup_vm(e)) < 0)
			 return r;

	   // Generate an env_id for this environment.
	   generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010314b:	8b 43 48             	mov    0x48(%ebx),%eax
f010314e:	05 00 10 00 00       	add    $0x1000,%eax
	   if (generation <= 0)	// Don't create a negative env_id.
f0103153:	25 00 fc ff ff       	and    $0xfffffc00,%eax
			 generation = 1 << ENVGENSHIFT;
f0103158:	ba 00 10 00 00       	mov    $0x1000,%edx
f010315d:	0f 4e c2             	cmovle %edx,%eax
	   e->env_id = generation | (e - envs);
f0103160:	89 da                	mov    %ebx,%edx
f0103162:	2b 15 48 f2 22 f0    	sub    0xf022f248,%edx
f0103168:	c1 fa 02             	sar    $0x2,%edx
f010316b:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103171:	09 d0                	or     %edx,%eax
f0103173:	89 43 48             	mov    %eax,0x48(%ebx)

	   // Set the basic status variables.
	   e->env_parent_id = parent_id;
f0103176:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103179:	89 43 4c             	mov    %eax,0x4c(%ebx)
	   e->env_type = ENV_TYPE_USER;
f010317c:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	   e->env_status = ENV_RUNNABLE;
f0103183:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	   e->env_runs = 0;
f010318a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	   // Clear out all the saved register state,
	   // to prevent the register values
	   // of a prior environment inhabiting this Env structure
	   // from "leaking" into our new environment.
	   memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103191:	83 ec 04             	sub    $0x4,%esp
f0103194:	6a 44                	push   $0x44
f0103196:	6a 00                	push   $0x0
f0103198:	53                   	push   %ebx
f0103199:	e8 e9 23 00 00       	call   f0105587 <memset>
	   // The low 2 bits of each segment register contains the
	   // Requestor Privilege Level (RPL); 3 means user mode.  When
	   // we switch privilege levels, the hardware does various
	   // checks involving the RPL and the Descriptor Privilege Level
	   // (DPL) stored in the descriptors themselves.
	   e->env_tf.tf_ds = GD_UD | 3;
f010319e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	   e->env_tf.tf_es = GD_UD | 3;
f01031a4:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	   e->env_tf.tf_ss = GD_UD | 3;
f01031aa:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	   e->env_tf.tf_esp = USTACKTOP;
f01031b0:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	   e->env_tf.tf_cs = GD_UT | 3;
f01031b7:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	   // You will set e->env_tf.tf_eip later.

	   // Enable interrupts while in user mode.
	   // LAB 4: Your code here.
	   e -> env_tf.tf_eflags |= FL_IF;
f01031bd:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	   // Clear the page fault handler until user installs one.
	   e->env_pgfault_upcall = 0;
f01031c4:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	   // Also clear the IPC receiving flag.
	   e->env_ipc_recving = 0;
f01031cb:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	   // commit the allocation
	   env_free_list = e->env_link;
f01031cf:	8b 43 44             	mov    0x44(%ebx),%eax
f01031d2:	a3 4c f2 22 f0       	mov    %eax,0xf022f24c
	   *newenv_store = e;
f01031d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01031da:	89 18                	mov    %ebx,(%eax)

	   cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01031dc:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01031df:	e8 c6 29 00 00       	call   f0105baa <cpunum>
f01031e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01031e7:	83 c4 10             	add    $0x10,%esp
f01031ea:	ba 00 00 00 00       	mov    $0x0,%edx
f01031ef:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01031f6:	74 11                	je     f0103209 <env_alloc+0x16b>
f01031f8:	e8 ad 29 00 00       	call   f0105baa <cpunum>
f01031fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103200:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103206:	8b 50 48             	mov    0x48(%eax),%edx
f0103209:	83 ec 04             	sub    $0x4,%esp
f010320c:	53                   	push   %ebx
f010320d:	52                   	push   %edx
f010320e:	68 46 75 10 f0       	push   $0xf0107546
f0103213:	e8 3c 06 00 00       	call   f0103854 <cprintf>
	   return 0;
f0103218:	83 c4 10             	add    $0x10,%esp
f010321b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103220:	eb 0c                	jmp    f010322e <env_alloc+0x190>
	   int32_t generation;
	   int r;
	   struct Env *e;

	   if (!(e = env_free_list))
			 return -E_NO_FREE_ENV;
f0103222:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103227:	eb 05                	jmp    f010322e <env_alloc+0x190>
	   int i;
	   struct PageInfo *p = NULL;

	   // Allocate a page for the page directory
	   if (!(p = page_alloc(ALLOC_ZERO)))
			 return -E_NO_MEM;
f0103229:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	   env_free_list = e->env_link;
	   *newenv_store = e;

	   cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	   return 0;
}
f010322e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103231:	5b                   	pop    %ebx
f0103232:	5e                   	pop    %esi
f0103233:	5f                   	pop    %edi
f0103234:	5d                   	pop    %ebp
f0103235:	c3                   	ret    

f0103236 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
	   void
env_create(uint8_t *binary, enum EnvType type)
{
f0103236:	55                   	push   %ebp
f0103237:	89 e5                	mov    %esp,%ebp
f0103239:	57                   	push   %edi
f010323a:	56                   	push   %esi
f010323b:	53                   	push   %ebx
f010323c:	83 ec 34             	sub    $0x34,%esp
f010323f:	8b 7d 08             	mov    0x8(%ebp),%edi
	   // LAB 3: Your code here.
	   struct Env* new_env = NULL;
f0103242:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   if ((env_alloc(&new_env, 0)) < 0)
f0103249:	6a 00                	push   $0x0
f010324b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010324e:	50                   	push   %eax
f010324f:	e8 4a fe ff ff       	call   f010309e <env_alloc>
f0103254:	83 c4 10             	add    $0x10,%esp
f0103257:	85 c0                	test   %eax,%eax
f0103259:	79 17                	jns    f0103272 <env_create+0x3c>
			 panic ("Environment Allocation Failed \n");
f010325b:	83 ec 04             	sub    $0x4,%esp
f010325e:	68 b8 75 10 f0       	push   $0xf01075b8
f0103263:	68 a7 01 00 00       	push   $0x1a7
f0103268:	68 26 75 10 f0       	push   $0xf0107526
f010326d:	e8 ce cd ff ff       	call   f0100040 <_panic>

	   load_icode (new_env, binary);
f0103272:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103275:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	   // LAB 3: Your code here.

	   struct Elf* p_binary = (struct Elf*) binary;

	   if (p_binary -> e_magic != ELF_MAGIC)
f0103278:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010327e:	74 17                	je     f0103297 <env_create+0x61>
			 panic ("Invalid ELF File \n");
f0103280:	83 ec 04             	sub    $0x4,%esp
f0103283:	68 5b 75 10 f0       	push   $0xf010755b
f0103288:	68 78 01 00 00       	push   $0x178
f010328d:	68 26 75 10 f0       	push   $0xf0107526
f0103292:	e8 a9 cd ff ff       	call   f0100040 <_panic>

	   lcr3 (PADDR(e -> env_pgdir));
f0103297:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010329a:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010329d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032a2:	77 15                	ja     f01032b9 <env_create+0x83>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032a4:	50                   	push   %eax
f01032a5:	68 88 62 10 f0       	push   $0xf0106288
f01032aa:	68 7a 01 00 00       	push   $0x17a
f01032af:	68 26 75 10 f0       	push   $0xf0107526
f01032b4:	e8 87 cd ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01032b9:	05 00 00 00 10       	add    $0x10000000,%eax
f01032be:	0f 22 d8             	mov    %eax,%cr3

	   struct Proghdr* ph_browse = (struct Proghdr*) (binary + p_binary -> e_phoff);
f01032c1:	89 fb                	mov    %edi,%ebx
f01032c3:	03 5f 1c             	add    0x1c(%edi),%ebx
	   struct Proghdr* ph_entries = ph_browse + p_binary -> e_phnum;
f01032c6:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01032ca:	c1 e6 05             	shl    $0x5,%esi
f01032cd:	01 de                	add    %ebx,%esi
f01032cf:	eb 70                	jmp    f0103341 <env_create+0x10b>

	   for (; ph_browse < ph_entries ; ph_browse ++)
	   {
			 if (ph_browse -> p_type != ELF_PROG_LOAD)
f01032d1:	83 3b 01             	cmpl   $0x1,(%ebx)
f01032d4:	75 68                	jne    f010333e <env_create+0x108>
				    continue;

			 if (ph_browse -> p_filesz > ph_browse -> p_memsz)
f01032d6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01032d9:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01032dc:	76 17                	jbe    f01032f5 <env_create+0xbf>
				    panic("Error in ElF File \n");
f01032de:	83 ec 04             	sub    $0x4,%esp
f01032e1:	68 6e 75 10 f0       	push   $0xf010756e
f01032e6:	68 85 01 00 00       	push   $0x185
f01032eb:	68 26 75 10 f0       	push   $0xf0107526
f01032f0:	e8 4b cd ff ff       	call   f0100040 <_panic>

			 region_alloc (e, (void*)ph_browse -> p_va, ph_browse -> p_memsz);
f01032f5:	8b 53 08             	mov    0x8(%ebx),%edx
f01032f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032fb:	e8 ef fb ff ff       	call   f0102eef <region_alloc>
			 memset ((void*)ph_browse -> p_va ,0 , ph_browse -> p_memsz);
f0103300:	83 ec 04             	sub    $0x4,%esp
f0103303:	ff 73 14             	pushl  0x14(%ebx)
f0103306:	6a 00                	push   $0x0
f0103308:	ff 73 08             	pushl  0x8(%ebx)
f010330b:	e8 77 22 00 00       	call   f0105587 <memset>
			 void* seg_offset = (void*) (binary + ph_browse -> p_offset);
			 memcpy ((void*)ph_browse -> p_va, seg_offset, ph_browse -> p_filesz);
f0103310:	83 c4 0c             	add    $0xc,%esp
f0103313:	ff 73 10             	pushl  0x10(%ebx)
f0103316:	89 f8                	mov    %edi,%eax
f0103318:	03 43 04             	add    0x4(%ebx),%eax
f010331b:	50                   	push   %eax
f010331c:	ff 73 08             	pushl  0x8(%ebx)
f010331f:	e8 18 23 00 00       	call   f010563c <memcpy>
			 memset ((void*)ph_browse -> p_va + ph_browse -> p_filesz , 0, (ph_browse -> p_memsz - ph_browse -> p_filesz));
f0103324:	8b 43 10             	mov    0x10(%ebx),%eax
f0103327:	83 c4 0c             	add    $0xc,%esp
f010332a:	8b 53 14             	mov    0x14(%ebx),%edx
f010332d:	29 c2                	sub    %eax,%edx
f010332f:	52                   	push   %edx
f0103330:	6a 00                	push   $0x0
f0103332:	03 43 08             	add    0x8(%ebx),%eax
f0103335:	50                   	push   %eax
f0103336:	e8 4c 22 00 00       	call   f0105587 <memset>
f010333b:	83 c4 10             	add    $0x10,%esp
	   lcr3 (PADDR(e -> env_pgdir));

	   struct Proghdr* ph_browse = (struct Proghdr*) (binary + p_binary -> e_phoff);
	   struct Proghdr* ph_entries = ph_browse + p_binary -> e_phnum;

	   for (; ph_browse < ph_entries ; ph_browse ++)
f010333e:	83 c3 20             	add    $0x20,%ebx
f0103341:	39 de                	cmp    %ebx,%esi
f0103343:	77 8c                	ja     f01032d1 <env_create+0x9b>
			 void* seg_offset = (void*) (binary + ph_browse -> p_offset);
			 memcpy ((void*)ph_browse -> p_va, seg_offset, ph_browse -> p_filesz);
			 memset ((void*)ph_browse -> p_va + ph_browse -> p_filesz , 0, (ph_browse -> p_memsz - ph_browse -> p_filesz));
	   }

	   e -> env_tf.tf_eip = p_binary -> e_entry;
f0103345:	8b 47 18             	mov    0x18(%edi),%eax
f0103348:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010334b:	89 47 30             	mov    %eax,0x30(%edi)

	   // Now map one page for the program's initial stack
	   // at virtual address USTACKTOP - PGSIZE.
	   // LAB 3: Your code here.

	   region_alloc (e, (void*) (USTACKTOP - PGSIZE), PGSIZE);
f010334e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103353:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103358:	89 f8                	mov    %edi,%eax
f010335a:	e8 90 fb ff ff       	call   f0102eef <region_alloc>
	   memset ((void*) (USTACKTOP - PGSIZE), 0, PGSIZE);
f010335f:	83 ec 04             	sub    $0x4,%esp
f0103362:	68 00 10 00 00       	push   $0x1000
f0103367:	6a 00                	push   $0x0
f0103369:	68 00 d0 bf ee       	push   $0xeebfd000
f010336e:	e8 14 22 00 00       	call   f0105587 <memset>

	   lcr3(PADDR(kern_pgdir));
f0103373:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103378:	83 c4 10             	add    $0x10,%esp
f010337b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103380:	77 15                	ja     f0103397 <env_create+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103382:	50                   	push   %eax
f0103383:	68 88 62 10 f0       	push   $0xf0106288
f0103388:	68 97 01 00 00       	push   $0x197
f010338d:	68 26 75 10 f0       	push   $0xf0107526
f0103392:	e8 a9 cc ff ff       	call   f0100040 <_panic>
f0103397:	05 00 00 00 10       	add    $0x10000000,%eax
f010339c:	0f 22 d8             	mov    %eax,%cr3
	   struct Env* new_env = NULL;
	   if ((env_alloc(&new_env, 0)) < 0)
			 panic ("Environment Allocation Failed \n");

	   load_icode (new_env, binary);
	   new_env -> env_type = type;
f010339f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033a2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033a5:	89 50 50             	mov    %edx,0x50(%eax)
}
f01033a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033ab:	5b                   	pop    %ebx
f01033ac:	5e                   	pop    %esi
f01033ad:	5f                   	pop    %edi
f01033ae:	5d                   	pop    %ebp
f01033af:	c3                   	ret    

f01033b0 <env_free>:
//
// Frees env e and all memory it uses.
//
	   void
env_free(struct Env *e)
{
f01033b0:	55                   	push   %ebp
f01033b1:	89 e5                	mov    %esp,%ebp
f01033b3:	57                   	push   %edi
f01033b4:	56                   	push   %esi
f01033b5:	53                   	push   %ebx
f01033b6:	83 ec 1c             	sub    $0x1c,%esp
f01033b9:	8b 7d 08             	mov    0x8(%ebp),%edi
	   physaddr_t pa;

	   // If freeing the current environment, switch to kern_pgdir
	   // before freeing the page directory, just in case the page
	   // gets reused.
	   if (e == curenv)
f01033bc:	e8 e9 27 00 00       	call   f0105baa <cpunum>
f01033c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01033c4:	39 b8 28 00 23 f0    	cmp    %edi,-0xfdcffd8(%eax)
f01033ca:	75 29                	jne    f01033f5 <env_free+0x45>
			 lcr3(PADDR(kern_pgdir));
f01033cc:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033d1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033d6:	77 15                	ja     f01033ed <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033d8:	50                   	push   %eax
f01033d9:	68 88 62 10 f0       	push   $0xf0106288
f01033de:	68 bb 01 00 00       	push   $0x1bb
f01033e3:	68 26 75 10 f0       	push   $0xf0107526
f01033e8:	e8 53 cc ff ff       	call   f0100040 <_panic>
f01033ed:	05 00 00 00 10       	add    $0x10000000,%eax
f01033f2:	0f 22 d8             	mov    %eax,%cr3

	   // Note the environment's demise.
	   cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01033f5:	8b 5f 48             	mov    0x48(%edi),%ebx
f01033f8:	e8 ad 27 00 00       	call   f0105baa <cpunum>
f01033fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103400:	ba 00 00 00 00       	mov    $0x0,%edx
f0103405:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010340c:	74 11                	je     f010341f <env_free+0x6f>
f010340e:	e8 97 27 00 00       	call   f0105baa <cpunum>
f0103413:	6b c0 74             	imul   $0x74,%eax,%eax
f0103416:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010341c:	8b 50 48             	mov    0x48(%eax),%edx
f010341f:	83 ec 04             	sub    $0x4,%esp
f0103422:	53                   	push   %ebx
f0103423:	52                   	push   %edx
f0103424:	68 82 75 10 f0       	push   $0xf0107582
f0103429:	e8 26 04 00 00       	call   f0103854 <cprintf>
f010342e:	83 c4 10             	add    $0x10,%esp

	   // Flush all mapped pages in the user portion of the address space
	   static_assert(UTOP % PTSIZE == 0);
	   for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103431:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103438:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010343b:	89 d0                	mov    %edx,%eax
f010343d:	c1 e0 02             	shl    $0x2,%eax
f0103440:	89 45 dc             	mov    %eax,-0x24(%ebp)

			 // only look at mapped page tables
			 if (!(e->env_pgdir[pdeno] & PTE_P))
f0103443:	8b 47 60             	mov    0x60(%edi),%eax
f0103446:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103449:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010344f:	0f 84 a8 00 00 00    	je     f01034fd <env_free+0x14d>
				    continue;

			 // find the pa and va of the page table
			 pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103455:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010345b:	89 f0                	mov    %esi,%eax
f010345d:	c1 e8 0c             	shr    $0xc,%eax
f0103460:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103463:	39 05 88 fe 22 f0    	cmp    %eax,0xf022fe88
f0103469:	77 15                	ja     f0103480 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010346b:	56                   	push   %esi
f010346c:	68 64 62 10 f0       	push   $0xf0106264
f0103471:	68 ca 01 00 00       	push   $0x1ca
f0103476:	68 26 75 10 f0       	push   $0xf0107526
f010347b:	e8 c0 cb ff ff       	call   f0100040 <_panic>
			 pt = (pte_t*) KADDR(pa);

			 // unmap all PTEs in this page table
			 for (pteno = 0; pteno <= PTX(~0); pteno++) {
				    if (pt[pteno] & PTE_P)
						  page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103480:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103483:	c1 e0 16             	shl    $0x16,%eax
f0103486:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			 // find the pa and va of the page table
			 pa = PTE_ADDR(e->env_pgdir[pdeno]);
			 pt = (pte_t*) KADDR(pa);

			 // unmap all PTEs in this page table
			 for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103489:	bb 00 00 00 00       	mov    $0x0,%ebx
				    if (pt[pteno] & PTE_P)
f010348e:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103495:	01 
f0103496:	74 17                	je     f01034af <env_free+0xff>
						  page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103498:	83 ec 08             	sub    $0x8,%esp
f010349b:	89 d8                	mov    %ebx,%eax
f010349d:	c1 e0 0c             	shl    $0xc,%eax
f01034a0:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034a3:	50                   	push   %eax
f01034a4:	ff 77 60             	pushl  0x60(%edi)
f01034a7:	e8 e9 dd ff ff       	call   f0101295 <page_remove>
f01034ac:	83 c4 10             	add    $0x10,%esp
			 // find the pa and va of the page table
			 pa = PTE_ADDR(e->env_pgdir[pdeno]);
			 pt = (pte_t*) KADDR(pa);

			 // unmap all PTEs in this page table
			 for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034af:	83 c3 01             	add    $0x1,%ebx
f01034b2:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034b8:	75 d4                	jne    f010348e <env_free+0xde>
				    if (pt[pteno] & PTE_P)
						  page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
			 }

			 // free the page table itself
			 e->env_pgdir[pdeno] = 0;
f01034ba:	8b 47 60             	mov    0x60(%edi),%eax
f01034bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034c0:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034ca:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01034d0:	72 14                	jb     f01034e6 <env_free+0x136>
		panic("pa2page called with invalid pa");
f01034d2:	83 ec 04             	sub    $0x4,%esp
f01034d5:	68 a4 6c 10 f0       	push   $0xf0106ca4
f01034da:	6a 51                	push   $0x51
f01034dc:	68 fe 67 10 f0       	push   $0xf01067fe
f01034e1:	e8 5a cb ff ff       	call   f0100040 <_panic>
			 page_decref(pa2page(pa));
f01034e6:	83 ec 0c             	sub    $0xc,%esp
f01034e9:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f01034ee:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034f1:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01034f4:	50                   	push   %eax
f01034f5:	e8 c3 db ff ff       	call   f01010bd <page_decref>
f01034fa:	83 c4 10             	add    $0x10,%esp
	   // Note the environment's demise.
	   cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	   // Flush all mapped pages in the user portion of the address space
	   static_assert(UTOP % PTSIZE == 0);
	   for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034fd:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103501:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103504:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103509:	0f 85 29 ff ff ff    	jne    f0103438 <env_free+0x88>
			 e->env_pgdir[pdeno] = 0;
			 page_decref(pa2page(pa));
	   }

	   // free the page directory
	   pa = PADDR(e->env_pgdir);
f010350f:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103512:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103517:	77 15                	ja     f010352e <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103519:	50                   	push   %eax
f010351a:	68 88 62 10 f0       	push   $0xf0106288
f010351f:	68 d8 01 00 00       	push   $0x1d8
f0103524:	68 26 75 10 f0       	push   $0xf0107526
f0103529:	e8 12 cb ff ff       	call   f0100040 <_panic>
	   e->env_pgdir = 0;
f010352e:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103535:	05 00 00 00 10       	add    $0x10000000,%eax
f010353a:	c1 e8 0c             	shr    $0xc,%eax
f010353d:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0103543:	72 14                	jb     f0103559 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103545:	83 ec 04             	sub    $0x4,%esp
f0103548:	68 a4 6c 10 f0       	push   $0xf0106ca4
f010354d:	6a 51                	push   $0x51
f010354f:	68 fe 67 10 f0       	push   $0xf01067fe
f0103554:	e8 e7 ca ff ff       	call   f0100040 <_panic>
	   page_decref(pa2page(pa));
f0103559:	83 ec 0c             	sub    $0xc,%esp
f010355c:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f0103562:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103565:	50                   	push   %eax
f0103566:	e8 52 db ff ff       	call   f01010bd <page_decref>

	   // return the environment to the free list
	   e->env_status = ENV_FREE;
f010356b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	   e->env_link = env_free_list;
f0103572:	a1 4c f2 22 f0       	mov    0xf022f24c,%eax
f0103577:	89 47 44             	mov    %eax,0x44(%edi)
	   env_free_list = e;
f010357a:	89 3d 4c f2 22 f0    	mov    %edi,0xf022f24c
}
f0103580:	83 c4 10             	add    $0x10,%esp
f0103583:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103586:	5b                   	pop    %ebx
f0103587:	5e                   	pop    %esi
f0103588:	5f                   	pop    %edi
f0103589:	5d                   	pop    %ebp
f010358a:	c3                   	ret    

f010358b <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
	   void
env_destroy(struct Env *e)
{
f010358b:	55                   	push   %ebp
f010358c:	89 e5                	mov    %esp,%ebp
f010358e:	53                   	push   %ebx
f010358f:	83 ec 04             	sub    $0x4,%esp
f0103592:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // If e is currently running on other CPUs, we change its state to
	   // ENV_DYING. A zombie environment will be freed the next time
	   // it traps to the kernel.
	   if (e->env_status == ENV_RUNNING && curenv != e) {
f0103595:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103599:	75 29                	jne    f01035c4 <env_destroy+0x39>
f010359b:	e8 0a 26 00 00       	call   f0105baa <cpunum>
f01035a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01035a3:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f01035a9:	74 19                	je     f01035c4 <env_destroy+0x39>
			 e->env_status = ENV_DYING;
f01035ab:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
			 cprintf("Environment dead \n");
f01035b2:	83 ec 0c             	sub    $0xc,%esp
f01035b5:	68 98 75 10 f0       	push   $0xf0107598
f01035ba:	e8 95 02 00 00       	call   f0103854 <cprintf>

			 return;
f01035bf:	83 c4 10             	add    $0x10,%esp
f01035c2:	eb 33                	jmp    f01035f7 <env_destroy+0x6c>
	   }

	   env_free(e);
f01035c4:	83 ec 0c             	sub    $0xc,%esp
f01035c7:	53                   	push   %ebx
f01035c8:	e8 e3 fd ff ff       	call   f01033b0 <env_free>

	   if (curenv == e) {
f01035cd:	e8 d8 25 00 00       	call   f0105baa <cpunum>
f01035d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01035d5:	83 c4 10             	add    $0x10,%esp
f01035d8:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f01035de:	75 17                	jne    f01035f7 <env_destroy+0x6c>
			 curenv = NULL;
f01035e0:	e8 c5 25 00 00       	call   f0105baa <cpunum>
f01035e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e8:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f01035ef:	00 00 00 
			 sched_yield();
f01035f2:	e8 04 0e 00 00       	call   f01043fb <sched_yield>
	   }
}
f01035f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035fa:	c9                   	leave  
f01035fb:	c3                   	ret    

f01035fc <env_pop_tf>:
//
// This function does not return.
//
	   void
env_pop_tf(struct Trapframe *tf)
{
f01035fc:	55                   	push   %ebp
f01035fd:	89 e5                	mov    %esp,%ebp
f01035ff:	53                   	push   %ebx
f0103600:	83 ec 04             	sub    $0x4,%esp
	   // Record the CPU we are running on for user-space debugging
	   curenv->env_cpunum = cpunum();
f0103603:	e8 a2 25 00 00       	call   f0105baa <cpunum>
f0103608:	6b c0 74             	imul   $0x74,%eax,%eax
f010360b:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f0103611:	e8 94 25 00 00       	call   f0105baa <cpunum>
f0103616:	89 43 5c             	mov    %eax,0x5c(%ebx)

	   asm volatile(
f0103619:	8b 65 08             	mov    0x8(%ebp),%esp
f010361c:	61                   	popa   
f010361d:	07                   	pop    %es
f010361e:	1f                   	pop    %ds
f010361f:	83 c4 08             	add    $0x8,%esp
f0103622:	cf                   	iret   
				    "\tpopl %%es\n"
				    "\tpopl %%ds\n"
				    "\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
				    "\tiret\n"
				    : : "g" (tf) : "memory");
	   panic("iret failed");  /* mostly to placate the compiler */
f0103623:	83 ec 04             	sub    $0x4,%esp
f0103626:	68 ab 75 10 f0       	push   $0xf01075ab
f010362b:	68 11 02 00 00       	push   $0x211
f0103630:	68 26 75 10 f0       	push   $0xf0107526
f0103635:	e8 06 ca ff ff       	call   f0100040 <_panic>

f010363a <env_run>:
//
// This function does not return.
//
	   void
env_run(struct Env *e)
{
f010363a:	55                   	push   %ebp
f010363b:	89 e5                	mov    %esp,%ebp
f010363d:	53                   	push   %ebx
f010363e:	83 ec 04             	sub    $0x4,%esp
f0103641:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   //	and make sure you have set the relevant parts of
	   //	e->env_tf to sensible values.

	   // LAB 3: Your code here.

	   if (curenv != NULL && curenv -> env_status == ENV_RUNNING)
f0103644:	e8 61 25 00 00       	call   f0105baa <cpunum>
f0103649:	6b c0 74             	imul   $0x74,%eax,%eax
f010364c:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0103653:	74 29                	je     f010367e <env_run+0x44>
f0103655:	e8 50 25 00 00       	call   f0105baa <cpunum>
f010365a:	6b c0 74             	imul   $0x74,%eax,%eax
f010365d:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103663:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103667:	75 15                	jne    f010367e <env_run+0x44>
			 curenv -> env_status = ENV_RUNNABLE;
f0103669:	e8 3c 25 00 00       	call   f0105baa <cpunum>
f010366e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103671:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103677:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	   curenv = e;
f010367e:	e8 27 25 00 00       	call   f0105baa <cpunum>
f0103683:	6b c0 74             	imul   $0x74,%eax,%eax
f0103686:	89 98 28 00 23 f0    	mov    %ebx,-0xfdcffd8(%eax)
	   e -> env_status = ENV_RUNNING;
f010368c:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	   e-> env_runs ++;
f0103693:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	   lcr3(PADDR(e -> env_pgdir));
f0103697:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010369a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010369f:	77 15                	ja     f01036b6 <env_run+0x7c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036a1:	50                   	push   %eax
f01036a2:	68 88 62 10 f0       	push   $0xf0106288
f01036a7:	68 36 02 00 00       	push   $0x236
f01036ac:	68 26 75 10 f0       	push   $0xf0107526
f01036b1:	e8 8a c9 ff ff       	call   f0100040 <_panic>
f01036b6:	05 00 00 00 10       	add    $0x10000000,%eax
f01036bb:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036be:	83 ec 0c             	sub    $0xc,%esp
f01036c1:	68 c0 03 12 f0       	push   $0xf01203c0
f01036c6:	e8 ea 27 00 00       	call   f0105eb5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01036cb:	f3 90                	pause  

	   unlock_kernel();
	   env_pop_tf (&e -> env_tf);
f01036cd:	89 1c 24             	mov    %ebx,(%esp)
f01036d0:	e8 27 ff ff ff       	call   f01035fc <env_pop_tf>

f01036d5 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036d5:	55                   	push   %ebp
f01036d6:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036d8:	ba 70 00 00 00       	mov    $0x70,%edx
f01036dd:	8b 45 08             	mov    0x8(%ebp),%eax
f01036e0:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036e1:	ba 71 00 00 00       	mov    $0x71,%edx
f01036e6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01036e7:	0f b6 c0             	movzbl %al,%eax
}
f01036ea:	5d                   	pop    %ebp
f01036eb:	c3                   	ret    

f01036ec <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01036ec:	55                   	push   %ebp
f01036ed:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036ef:	ba 70 00 00 00       	mov    $0x70,%edx
f01036f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01036f7:	ee                   	out    %al,(%dx)
f01036f8:	ba 71 00 00 00       	mov    $0x71,%edx
f01036fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103700:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103701:	5d                   	pop    %ebp
f0103702:	c3                   	ret    

f0103703 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103703:	55                   	push   %ebp
f0103704:	89 e5                	mov    %esp,%ebp
f0103706:	56                   	push   %esi
f0103707:	53                   	push   %ebx
f0103708:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010370b:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103711:	80 3d 50 f2 22 f0 00 	cmpb   $0x0,0xf022f250
f0103718:	74 5a                	je     f0103774 <irq_setmask_8259A+0x71>
f010371a:	89 c6                	mov    %eax,%esi
f010371c:	ba 21 00 00 00       	mov    $0x21,%edx
f0103721:	ee                   	out    %al,(%dx)
f0103722:	66 c1 e8 08          	shr    $0x8,%ax
f0103726:	ba a1 00 00 00       	mov    $0xa1,%edx
f010372b:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010372c:	83 ec 0c             	sub    $0xc,%esp
f010372f:	68 d8 75 10 f0       	push   $0xf01075d8
f0103734:	e8 1b 01 00 00       	call   f0103854 <cprintf>
f0103739:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010373c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103741:	0f b7 f6             	movzwl %si,%esi
f0103744:	f7 d6                	not    %esi
f0103746:	0f a3 de             	bt     %ebx,%esi
f0103749:	73 11                	jae    f010375c <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010374b:	83 ec 08             	sub    $0x8,%esp
f010374e:	53                   	push   %ebx
f010374f:	68 3f 7b 10 f0       	push   $0xf0107b3f
f0103754:	e8 fb 00 00 00       	call   f0103854 <cprintf>
f0103759:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010375c:	83 c3 01             	add    $0x1,%ebx
f010375f:	83 fb 10             	cmp    $0x10,%ebx
f0103762:	75 e2                	jne    f0103746 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103764:	83 ec 0c             	sub    $0xc,%esp
f0103767:	68 e1 65 10 f0       	push   $0xf01065e1
f010376c:	e8 e3 00 00 00       	call   f0103854 <cprintf>
f0103771:	83 c4 10             	add    $0x10,%esp
}
f0103774:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103777:	5b                   	pop    %ebx
f0103778:	5e                   	pop    %esi
f0103779:	5d                   	pop    %ebp
f010377a:	c3                   	ret    

f010377b <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010377b:	c6 05 50 f2 22 f0 01 	movb   $0x1,0xf022f250
f0103782:	ba 21 00 00 00       	mov    $0x21,%edx
f0103787:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010378c:	ee                   	out    %al,(%dx)
f010378d:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103792:	ee                   	out    %al,(%dx)
f0103793:	ba 20 00 00 00       	mov    $0x20,%edx
f0103798:	b8 11 00 00 00       	mov    $0x11,%eax
f010379d:	ee                   	out    %al,(%dx)
f010379e:	ba 21 00 00 00       	mov    $0x21,%edx
f01037a3:	b8 20 00 00 00       	mov    $0x20,%eax
f01037a8:	ee                   	out    %al,(%dx)
f01037a9:	b8 04 00 00 00       	mov    $0x4,%eax
f01037ae:	ee                   	out    %al,(%dx)
f01037af:	b8 03 00 00 00       	mov    $0x3,%eax
f01037b4:	ee                   	out    %al,(%dx)
f01037b5:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037ba:	b8 11 00 00 00       	mov    $0x11,%eax
f01037bf:	ee                   	out    %al,(%dx)
f01037c0:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037c5:	b8 28 00 00 00       	mov    $0x28,%eax
f01037ca:	ee                   	out    %al,(%dx)
f01037cb:	b8 02 00 00 00       	mov    $0x2,%eax
f01037d0:	ee                   	out    %al,(%dx)
f01037d1:	b8 01 00 00 00       	mov    $0x1,%eax
f01037d6:	ee                   	out    %al,(%dx)
f01037d7:	ba 20 00 00 00       	mov    $0x20,%edx
f01037dc:	b8 68 00 00 00       	mov    $0x68,%eax
f01037e1:	ee                   	out    %al,(%dx)
f01037e2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01037e7:	ee                   	out    %al,(%dx)
f01037e8:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037ed:	b8 68 00 00 00       	mov    $0x68,%eax
f01037f2:	ee                   	out    %al,(%dx)
f01037f3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01037f8:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01037f9:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103800:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103804:	74 13                	je     f0103819 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103806:	55                   	push   %ebp
f0103807:	89 e5                	mov    %esp,%ebp
f0103809:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f010380c:	0f b7 c0             	movzwl %ax,%eax
f010380f:	50                   	push   %eax
f0103810:	e8 ee fe ff ff       	call   f0103703 <irq_setmask_8259A>
f0103815:	83 c4 10             	add    $0x10,%esp
}
f0103818:	c9                   	leave  
f0103819:	f3 c3                	repz ret 

f010381b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010381b:	55                   	push   %ebp
f010381c:	89 e5                	mov    %esp,%ebp
f010381e:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103821:	ff 75 08             	pushl  0x8(%ebp)
f0103824:	e8 24 cf ff ff       	call   f010074d <cputchar>
	*cnt++;
}
f0103829:	83 c4 10             	add    $0x10,%esp
f010382c:	c9                   	leave  
f010382d:	c3                   	ret    

f010382e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010382e:	55                   	push   %ebp
f010382f:	89 e5                	mov    %esp,%ebp
f0103831:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103834:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010383b:	ff 75 0c             	pushl  0xc(%ebp)
f010383e:	ff 75 08             	pushl  0x8(%ebp)
f0103841:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103844:	50                   	push   %eax
f0103845:	68 1b 38 10 f0       	push   $0xf010381b
f010384a:	e8 cc 16 00 00       	call   f0104f1b <vprintfmt>
	return cnt;
}
f010384f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103852:	c9                   	leave  
f0103853:	c3                   	ret    

f0103854 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103854:	55                   	push   %ebp
f0103855:	89 e5                	mov    %esp,%ebp
f0103857:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010385a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010385d:	50                   	push   %eax
f010385e:	ff 75 08             	pushl  0x8(%ebp)
f0103861:	e8 c8 ff ff ff       	call   f010382e <vcprintf>
	va_end(ap);

	return cnt;
}
f0103866:	c9                   	leave  
f0103867:	c3                   	ret    

f0103868 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
	   void
trap_init_percpu(void)
{
f0103868:	55                   	push   %ebp
f0103869:	89 e5                	mov    %esp,%ebp
f010386b:	56                   	push   %esi
f010386c:	53                   	push   %ebx
	   //
	   // LAB 4: Your code here:

	   // Setup a TSS so that we get the right stack
	   // when we trap to the kernel.
	   struct Taskstate* ts_cpu = &thiscpu -> cpu_ts;
f010386d:	e8 38 23 00 00       	call   f0105baa <cpunum>
f0103872:	6b f0 74             	imul   $0x74,%eax,%esi
f0103875:	8d 9e 2c 00 23 f0    	lea    -0xfdcffd4(%esi),%ebx
	   ts_cpu -> ts_esp0 = KSTACKTOP - thiscpu -> cpu_id * (KSTKSIZE + KSTKGAP);
f010387b:	e8 2a 23 00 00       	call   f0105baa <cpunum>
f0103880:	6b c0 74             	imul   $0x74,%eax,%eax
f0103883:	0f b6 90 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%edx
f010388a:	c1 e2 10             	shl    $0x10,%edx
f010388d:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103892:	29 d0                	sub    %edx,%eax
f0103894:	89 86 30 00 23 f0    	mov    %eax,-0xfdcffd0(%esi)
	   ts_cpu -> ts_ss0 = GD_KD;
f010389a:	66 c7 86 34 00 23 f0 	movw   $0x10,-0xfdcffcc(%esi)
f01038a1:	10 00 
	   ts_cpu -> ts_iomb = sizeof (struct Taskstate);
f01038a3:	66 c7 86 92 00 23 f0 	movw   $0x68,-0xfdcff6e(%esi)
f01038aa:	68 00 

	   // Initialize the TSS slot of the gdt.
	   gdt[(GD_TSS0 >> 3) + thiscpu -> cpu_id] = SEG16(STS_T32A, (uint32_t) (ts_cpu),
f01038ac:	e8 f9 22 00 00       	call   f0105baa <cpunum>
f01038b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01038b4:	0f b6 80 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%eax
f01038bb:	83 c0 05             	add    $0x5,%eax
f01038be:	66 c7 04 c5 40 03 12 	movw   $0x67,-0xfedfcc0(,%eax,8)
f01038c5:	f0 67 00 
f01038c8:	66 89 1c c5 42 03 12 	mov    %bx,-0xfedfcbe(,%eax,8)
f01038cf:	f0 
f01038d0:	89 da                	mov    %ebx,%edx
f01038d2:	c1 ea 10             	shr    $0x10,%edx
f01038d5:	88 14 c5 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%eax,8)
f01038dc:	c6 04 c5 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%eax,8)
f01038e3:	99 
f01038e4:	c6 04 c5 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%eax,8)
f01038eb:	40 
f01038ec:	c1 eb 18             	shr    $0x18,%ebx
f01038ef:	88 1c c5 47 03 12 f0 	mov    %bl,-0xfedfcb9(,%eax,8)
				    sizeof(struct Taskstate) - 1, 0);
	   gdt[(GD_TSS0 >> 3) + thiscpu -> cpu_id].sd_s = 0;
f01038f6:	e8 af 22 00 00       	call   f0105baa <cpunum>
f01038fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01038fe:	0f b6 80 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%eax
f0103905:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f010390c:	ef 

	   // Load the TSS selector (like other segment selectors, the
	   // bottom three bits are special; we leave them 0)
	   ltr(GD_TSS0 + (thiscpu -> cpu_id << 3));
f010390d:	e8 98 22 00 00       	call   f0105baa <cpunum>
f0103912:	6b c0 74             	imul   $0x74,%eax,%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103915:	0f b6 80 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%eax
f010391c:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103923:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103926:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f010392b:	0f 01 18             	lidtl  (%eax)
	   // bottom three bits are special; we leave them 0)
	   ltr(GD_TSS0);

	   // Load the IDT
	   lidt(&idt_pd);*/
}
f010392e:	5b                   	pop    %ebx
f010392f:	5e                   	pop    %esi
f0103930:	5d                   	pop    %ebp
f0103931:	c3                   	ret    

f0103932 <trap_init>:
{
	   extern struct Segdesc gdt[];

	   // LAB 3: Your code here.

	   SETGATE(idt[T_DIVIDE], false, GD_KT, divide_exception, 0);
f0103932:	b8 9c 42 10 f0       	mov    $0xf010429c,%eax
f0103937:	66 a3 60 f2 22 f0    	mov    %ax,0xf022f260
f010393d:	66 c7 05 62 f2 22 f0 	movw   $0x8,0xf022f262
f0103944:	08 00 
f0103946:	c6 05 64 f2 22 f0 00 	movb   $0x0,0xf022f264
f010394d:	c6 05 65 f2 22 f0 8e 	movb   $0x8e,0xf022f265
f0103954:	c1 e8 10             	shr    $0x10,%eax
f0103957:	66 a3 66 f2 22 f0    	mov    %ax,0xf022f266
	   SETGATE(idt[T_DEBUG], false, GD_KT, debug_exception, 0);
f010395d:	b8 a2 42 10 f0       	mov    $0xf01042a2,%eax
f0103962:	66 a3 68 f2 22 f0    	mov    %ax,0xf022f268
f0103968:	66 c7 05 6a f2 22 f0 	movw   $0x8,0xf022f26a
f010396f:	08 00 
f0103971:	c6 05 6c f2 22 f0 00 	movb   $0x0,0xf022f26c
f0103978:	c6 05 6d f2 22 f0 8e 	movb   $0x8e,0xf022f26d
f010397f:	c1 e8 10             	shr    $0x10,%eax
f0103982:	66 a3 6e f2 22 f0    	mov    %ax,0xf022f26e
	   SETGATE(idt[T_NMI], false, GD_KT, nmi_interupt, 0);
f0103988:	b8 a8 42 10 f0       	mov    $0xf01042a8,%eax
f010398d:	66 a3 70 f2 22 f0    	mov    %ax,0xf022f270
f0103993:	66 c7 05 72 f2 22 f0 	movw   $0x8,0xf022f272
f010399a:	08 00 
f010399c:	c6 05 74 f2 22 f0 00 	movb   $0x0,0xf022f274
f01039a3:	c6 05 75 f2 22 f0 8e 	movb   $0x8e,0xf022f275
f01039aa:	c1 e8 10             	shr    $0x10,%eax
f01039ad:	66 a3 76 f2 22 f0    	mov    %ax,0xf022f276
	   SETGATE(idt[T_BRKPT], false, GD_KT, breakpoint_exception, 3);
f01039b3:	b8 ae 42 10 f0       	mov    $0xf01042ae,%eax
f01039b8:	66 a3 78 f2 22 f0    	mov    %ax,0xf022f278
f01039be:	66 c7 05 7a f2 22 f0 	movw   $0x8,0xf022f27a
f01039c5:	08 00 
f01039c7:	c6 05 7c f2 22 f0 00 	movb   $0x0,0xf022f27c
f01039ce:	c6 05 7d f2 22 f0 ee 	movb   $0xee,0xf022f27d
f01039d5:	c1 e8 10             	shr    $0x10,%eax
f01039d8:	66 a3 7e f2 22 f0    	mov    %ax,0xf022f27e
	   SETGATE(idt[T_OFLOW], false, GD_KT, overflow_exception, 0);
f01039de:	b8 b4 42 10 f0       	mov    $0xf01042b4,%eax
f01039e3:	66 a3 80 f2 22 f0    	mov    %ax,0xf022f280
f01039e9:	66 c7 05 82 f2 22 f0 	movw   $0x8,0xf022f282
f01039f0:	08 00 
f01039f2:	c6 05 84 f2 22 f0 00 	movb   $0x0,0xf022f284
f01039f9:	c6 05 85 f2 22 f0 8e 	movb   $0x8e,0xf022f285
f0103a00:	c1 e8 10             	shr    $0x10,%eax
f0103a03:	66 a3 86 f2 22 f0    	mov    %ax,0xf022f286
	   SETGATE(idt[T_BOUND], false, GD_KT, bounds_check_exception, 0);
f0103a09:	b8 ba 42 10 f0       	mov    $0xf01042ba,%eax
f0103a0e:	66 a3 88 f2 22 f0    	mov    %ax,0xf022f288
f0103a14:	66 c7 05 8a f2 22 f0 	movw   $0x8,0xf022f28a
f0103a1b:	08 00 
f0103a1d:	c6 05 8c f2 22 f0 00 	movb   $0x0,0xf022f28c
f0103a24:	c6 05 8d f2 22 f0 8e 	movb   $0x8e,0xf022f28d
f0103a2b:	c1 e8 10             	shr    $0x10,%eax
f0103a2e:	66 a3 8e f2 22 f0    	mov    %ax,0xf022f28e
	   SETGATE(idt[T_ILLOP], false, GD_KT, illegal_opcode_exception, 0);
f0103a34:	b8 c0 42 10 f0       	mov    $0xf01042c0,%eax
f0103a39:	66 a3 90 f2 22 f0    	mov    %ax,0xf022f290
f0103a3f:	66 c7 05 92 f2 22 f0 	movw   $0x8,0xf022f292
f0103a46:	08 00 
f0103a48:	c6 05 94 f2 22 f0 00 	movb   $0x0,0xf022f294
f0103a4f:	c6 05 95 f2 22 f0 8e 	movb   $0x8e,0xf022f295
f0103a56:	c1 e8 10             	shr    $0x10,%eax
f0103a59:	66 a3 96 f2 22 f0    	mov    %ax,0xf022f296
	   SETGATE(idt[T_DEVICE], false, GD_KT, coprocessor_exception, 0);
f0103a5f:	b8 c6 42 10 f0       	mov    $0xf01042c6,%eax
f0103a64:	66 a3 98 f2 22 f0    	mov    %ax,0xf022f298
f0103a6a:	66 c7 05 9a f2 22 f0 	movw   $0x8,0xf022f29a
f0103a71:	08 00 
f0103a73:	c6 05 9c f2 22 f0 00 	movb   $0x0,0xf022f29c
f0103a7a:	c6 05 9d f2 22 f0 8e 	movb   $0x8e,0xf022f29d
f0103a81:	c1 e8 10             	shr    $0x10,%eax
f0103a84:	66 a3 9e f2 22 f0    	mov    %ax,0xf022f29e
	   SETGATE(idt[T_DBLFLT], false, GD_KT, double_fault_exception, 0);
f0103a8a:	b8 cc 42 10 f0       	mov    $0xf01042cc,%eax
f0103a8f:	66 a3 a0 f2 22 f0    	mov    %ax,0xf022f2a0
f0103a95:	66 c7 05 a2 f2 22 f0 	movw   $0x8,0xf022f2a2
f0103a9c:	08 00 
f0103a9e:	c6 05 a4 f2 22 f0 00 	movb   $0x0,0xf022f2a4
f0103aa5:	c6 05 a5 f2 22 f0 8e 	movb   $0x8e,0xf022f2a5
f0103aac:	c1 e8 10             	shr    $0x10,%eax
f0103aaf:	66 a3 a6 f2 22 f0    	mov    %ax,0xf022f2a6
	   SETGATE(idt[T_TSS], false, GD_KT, tss_exception, 0);
f0103ab5:	b8 d0 42 10 f0       	mov    $0xf01042d0,%eax
f0103aba:	66 a3 b0 f2 22 f0    	mov    %ax,0xf022f2b0
f0103ac0:	66 c7 05 b2 f2 22 f0 	movw   $0x8,0xf022f2b2
f0103ac7:	08 00 
f0103ac9:	c6 05 b4 f2 22 f0 00 	movb   $0x0,0xf022f2b4
f0103ad0:	c6 05 b5 f2 22 f0 8e 	movb   $0x8e,0xf022f2b5
f0103ad7:	c1 e8 10             	shr    $0x10,%eax
f0103ada:	66 a3 b6 f2 22 f0    	mov    %ax,0xf022f2b6
	   SETGATE(idt[T_SEGNP], false, GD_KT, segment_np_exception, 0);
f0103ae0:	b8 d4 42 10 f0       	mov    $0xf01042d4,%eax
f0103ae5:	66 a3 b8 f2 22 f0    	mov    %ax,0xf022f2b8
f0103aeb:	66 c7 05 ba f2 22 f0 	movw   $0x8,0xf022f2ba
f0103af2:	08 00 
f0103af4:	c6 05 bc f2 22 f0 00 	movb   $0x0,0xf022f2bc
f0103afb:	c6 05 bd f2 22 f0 8e 	movb   $0x8e,0xf022f2bd
f0103b02:	c1 e8 10             	shr    $0x10,%eax
f0103b05:	66 a3 be f2 22 f0    	mov    %ax,0xf022f2be
	   SETGATE(idt[T_STACK], false, GD_KT, stack_np_excecption, 0);
f0103b0b:	b8 d8 42 10 f0       	mov    $0xf01042d8,%eax
f0103b10:	66 a3 c0 f2 22 f0    	mov    %ax,0xf022f2c0
f0103b16:	66 c7 05 c2 f2 22 f0 	movw   $0x8,0xf022f2c2
f0103b1d:	08 00 
f0103b1f:	c6 05 c4 f2 22 f0 00 	movb   $0x0,0xf022f2c4
f0103b26:	c6 05 c5 f2 22 f0 8e 	movb   $0x8e,0xf022f2c5
f0103b2d:	c1 e8 10             	shr    $0x10,%eax
f0103b30:	66 a3 c6 f2 22 f0    	mov    %ax,0xf022f2c6
	   SETGATE(idt[T_GPFLT], false, GD_KT, general_protection_fault, 0);
f0103b36:	b8 dc 42 10 f0       	mov    $0xf01042dc,%eax
f0103b3b:	66 a3 c8 f2 22 f0    	mov    %ax,0xf022f2c8
f0103b41:	66 c7 05 ca f2 22 f0 	movw   $0x8,0xf022f2ca
f0103b48:	08 00 
f0103b4a:	c6 05 cc f2 22 f0 00 	movb   $0x0,0xf022f2cc
f0103b51:	c6 05 cd f2 22 f0 8e 	movb   $0x8e,0xf022f2cd
f0103b58:	c1 e8 10             	shr    $0x10,%eax
f0103b5b:	66 a3 ce f2 22 f0    	mov    %ax,0xf022f2ce
	   SETGATE(idt[T_PGFLT], false, GD_KT, page_fault_exception,0);
f0103b61:	b8 e0 42 10 f0       	mov    $0xf01042e0,%eax
f0103b66:	66 a3 d0 f2 22 f0    	mov    %ax,0xf022f2d0
f0103b6c:	66 c7 05 d2 f2 22 f0 	movw   $0x8,0xf022f2d2
f0103b73:	08 00 
f0103b75:	c6 05 d4 f2 22 f0 00 	movb   $0x0,0xf022f2d4
f0103b7c:	c6 05 d5 f2 22 f0 8e 	movb   $0x8e,0xf022f2d5
f0103b83:	c1 e8 10             	shr    $0x10,%eax
f0103b86:	66 a3 d6 f2 22 f0    	mov    %ax,0xf022f2d6
	   SETGATE(idt[T_FPERR], false, GD_KT, fp_err_exception, 0);
f0103b8c:	b8 e4 42 10 f0       	mov    $0xf01042e4,%eax
f0103b91:	66 a3 e0 f2 22 f0    	mov    %ax,0xf022f2e0
f0103b97:	66 c7 05 e2 f2 22 f0 	movw   $0x8,0xf022f2e2
f0103b9e:	08 00 
f0103ba0:	c6 05 e4 f2 22 f0 00 	movb   $0x0,0xf022f2e4
f0103ba7:	c6 05 e5 f2 22 f0 8e 	movb   $0x8e,0xf022f2e5
f0103bae:	c1 e8 10             	shr    $0x10,%eax
f0103bb1:	66 a3 e6 f2 22 f0    	mov    %ax,0xf022f2e6
	   SETGATE(idt[T_ALIGN], false, GD_KT, alignment_exception, 0);
f0103bb7:	b8 ea 42 10 f0       	mov    $0xf01042ea,%eax
f0103bbc:	66 a3 e8 f2 22 f0    	mov    %ax,0xf022f2e8
f0103bc2:	66 c7 05 ea f2 22 f0 	movw   $0x8,0xf022f2ea
f0103bc9:	08 00 
f0103bcb:	c6 05 ec f2 22 f0 00 	movb   $0x0,0xf022f2ec
f0103bd2:	c6 05 ed f2 22 f0 8e 	movb   $0x8e,0xf022f2ed
f0103bd9:	c1 e8 10             	shr    $0x10,%eax
f0103bdc:	66 a3 ee f2 22 f0    	mov    %ax,0xf022f2ee
	   SETGATE(idt[T_MCHK], false, GD_KT, machine_exception, 0);
f0103be2:	b8 ee 42 10 f0       	mov    $0xf01042ee,%eax
f0103be7:	66 a3 f0 f2 22 f0    	mov    %ax,0xf022f2f0
f0103bed:	66 c7 05 f2 f2 22 f0 	movw   $0x8,0xf022f2f2
f0103bf4:	08 00 
f0103bf6:	c6 05 f4 f2 22 f0 00 	movb   $0x0,0xf022f2f4
f0103bfd:	c6 05 f5 f2 22 f0 8e 	movb   $0x8e,0xf022f2f5
f0103c04:	c1 e8 10             	shr    $0x10,%eax
f0103c07:	66 a3 f6 f2 22 f0    	mov    %ax,0xf022f2f6
	   SETGATE(idt[T_SIMDERR], false, GD_KT, SIMDerr_exception, 0);
f0103c0d:	b8 f4 42 10 f0       	mov    $0xf01042f4,%eax
f0103c12:	66 a3 f8 f2 22 f0    	mov    %ax,0xf022f2f8
f0103c18:	66 c7 05 fa f2 22 f0 	movw   $0x8,0xf022f2fa
f0103c1f:	08 00 
f0103c21:	c6 05 fc f2 22 f0 00 	movb   $0x0,0xf022f2fc
f0103c28:	c6 05 fd f2 22 f0 8e 	movb   $0x8e,0xf022f2fd
f0103c2f:	c1 e8 10             	shr    $0x10,%eax
f0103c32:	66 a3 fe f2 22 f0    	mov    %ax,0xf022f2fe

	   SETGATE (idt[T_SYSCALL], false, GD_KT, syscall_interrupt, 3);
f0103c38:	b8 fa 42 10 f0       	mov    $0xf01042fa,%eax
f0103c3d:	66 a3 e0 f3 22 f0    	mov    %ax,0xf022f3e0
f0103c43:	66 c7 05 e2 f3 22 f0 	movw   $0x8,0xf022f3e2
f0103c4a:	08 00 
f0103c4c:	c6 05 e4 f3 22 f0 00 	movb   $0x0,0xf022f3e4
f0103c53:	c6 05 e5 f3 22 f0 ee 	movb   $0xee,0xf022f3e5
f0103c5a:	c1 e8 10             	shr    $0x10,%eax
f0103c5d:	66 a3 e6 f3 22 f0    	mov    %ax,0xf022f3e6


	   for (int i = 0; i < 15; i ++)
	   {
			 SETGATE (idt[IRQ_OFFSET + i], false, GD_KT, IRQ_ErrorINT, 0);
f0103c63:	ba 10 43 10 f0       	mov    $0xf0104310,%edx
f0103c68:	c1 ea 10             	shr    $0x10,%edx
f0103c6b:	b8 20 00 00 00       	mov    $0x20,%eax
f0103c70:	b9 10 43 10 f0       	mov    $0xf0104310,%ecx
f0103c75:	66 89 0c c5 60 f2 22 	mov    %cx,-0xfdd0da0(,%eax,8)
f0103c7c:	f0 
f0103c7d:	66 c7 04 c5 62 f2 22 	movw   $0x8,-0xfdd0d9e(,%eax,8)
f0103c84:	f0 08 00 
f0103c87:	c6 04 c5 64 f2 22 f0 	movb   $0x0,-0xfdd0d9c(,%eax,8)
f0103c8e:	00 
f0103c8f:	c6 04 c5 65 f2 22 f0 	movb   $0x8e,-0xfdd0d9b(,%eax,8)
f0103c96:	8e 
f0103c97:	66 89 14 c5 66 f2 22 	mov    %dx,-0xfdd0d9a(,%eax,8)
f0103c9e:	f0 
f0103c9f:	83 c0 01             	add    $0x1,%eax
	   SETGATE(idt[T_SIMDERR], false, GD_KT, SIMDerr_exception, 0);

	   SETGATE (idt[T_SYSCALL], false, GD_KT, syscall_interrupt, 3);


	   for (int i = 0; i < 15; i ++)
f0103ca2:	83 f8 2f             	cmp    $0x2f,%eax
f0103ca5:	75 ce                	jne    f0103c75 <trap_init+0x343>
}


	   void
trap_init(void)
{
f0103ca7:	55                   	push   %ebp
f0103ca8:	89 e5                	mov    %esp,%ebp
f0103caa:	83 ec 08             	sub    $0x8,%esp
	   for (int i = 0; i < 15; i ++)
	   {
			 SETGATE (idt[IRQ_OFFSET + i], false, GD_KT, IRQ_ErrorINT, 0);
	   }

	   SETGATE (idt[IRQ_OFFSET + IRQ_TIMER], false, GD_KT, IRQ_TimerINT, 0);
f0103cad:	b8 0a 43 10 f0       	mov    $0xf010430a,%eax
f0103cb2:	66 a3 60 f3 22 f0    	mov    %ax,0xf022f360
f0103cb8:	66 c7 05 62 f3 22 f0 	movw   $0x8,0xf022f362
f0103cbf:	08 00 
f0103cc1:	c6 05 64 f3 22 f0 00 	movb   $0x0,0xf022f364
f0103cc8:	c6 05 65 f3 22 f0 8e 	movb   $0x8e,0xf022f365
f0103ccf:	c1 e8 10             	shr    $0x10,%eax
f0103cd2:	66 a3 66 f3 22 f0    	mov    %ax,0xf022f366

	   // Per-CPU setup 
	   trap_init_percpu();
f0103cd8:	e8 8b fb ff ff       	call   f0103868 <trap_init_percpu>
}
f0103cdd:	c9                   	leave  
f0103cde:	c3                   	ret    

f0103cdf <print_regs>:
	   }
}

	   void
print_regs(struct PushRegs *regs)
{
f0103cdf:	55                   	push   %ebp
f0103ce0:	89 e5                	mov    %esp,%ebp
f0103ce2:	53                   	push   %ebx
f0103ce3:	83 ec 0c             	sub    $0xc,%esp
f0103ce6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103ce9:	ff 33                	pushl  (%ebx)
f0103ceb:	68 ec 75 10 f0       	push   $0xf01075ec
f0103cf0:	e8 5f fb ff ff       	call   f0103854 <cprintf>
	   cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103cf5:	83 c4 08             	add    $0x8,%esp
f0103cf8:	ff 73 04             	pushl  0x4(%ebx)
f0103cfb:	68 fb 75 10 f0       	push   $0xf01075fb
f0103d00:	e8 4f fb ff ff       	call   f0103854 <cprintf>
	   cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103d05:	83 c4 08             	add    $0x8,%esp
f0103d08:	ff 73 08             	pushl  0x8(%ebx)
f0103d0b:	68 0a 76 10 f0       	push   $0xf010760a
f0103d10:	e8 3f fb ff ff       	call   f0103854 <cprintf>
	   cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103d15:	83 c4 08             	add    $0x8,%esp
f0103d18:	ff 73 0c             	pushl  0xc(%ebx)
f0103d1b:	68 19 76 10 f0       	push   $0xf0107619
f0103d20:	e8 2f fb ff ff       	call   f0103854 <cprintf>
	   cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d25:	83 c4 08             	add    $0x8,%esp
f0103d28:	ff 73 10             	pushl  0x10(%ebx)
f0103d2b:	68 28 76 10 f0       	push   $0xf0107628
f0103d30:	e8 1f fb ff ff       	call   f0103854 <cprintf>
	   cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d35:	83 c4 08             	add    $0x8,%esp
f0103d38:	ff 73 14             	pushl  0x14(%ebx)
f0103d3b:	68 37 76 10 f0       	push   $0xf0107637
f0103d40:	e8 0f fb ff ff       	call   f0103854 <cprintf>
	   cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103d45:	83 c4 08             	add    $0x8,%esp
f0103d48:	ff 73 18             	pushl  0x18(%ebx)
f0103d4b:	68 46 76 10 f0       	push   $0xf0107646
f0103d50:	e8 ff fa ff ff       	call   f0103854 <cprintf>
	   cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103d55:	83 c4 08             	add    $0x8,%esp
f0103d58:	ff 73 1c             	pushl  0x1c(%ebx)
f0103d5b:	68 55 76 10 f0       	push   $0xf0107655
f0103d60:	e8 ef fa ff ff       	call   f0103854 <cprintf>
}
f0103d65:	83 c4 10             	add    $0x10,%esp
f0103d68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d6b:	c9                   	leave  
f0103d6c:	c3                   	ret    

f0103d6d <print_trapframe>:
	   lidt(&idt_pd);*/
}

	   void
print_trapframe(struct Trapframe *tf)
{
f0103d6d:	55                   	push   %ebp
f0103d6e:	89 e5                	mov    %esp,%ebp
f0103d70:	56                   	push   %esi
f0103d71:	53                   	push   %ebx
f0103d72:	8b 5d 08             	mov    0x8(%ebp),%ebx

	   cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103d75:	e8 30 1e 00 00       	call   f0105baa <cpunum>
f0103d7a:	83 ec 04             	sub    $0x4,%esp
f0103d7d:	50                   	push   %eax
f0103d7e:	53                   	push   %ebx
f0103d7f:	68 b9 76 10 f0       	push   $0xf01076b9
f0103d84:	e8 cb fa ff ff       	call   f0103854 <cprintf>
	   print_regs(&tf->tf_regs);
f0103d89:	89 1c 24             	mov    %ebx,(%esp)
f0103d8c:	e8 4e ff ff ff       	call   f0103cdf <print_regs>
	   cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d91:	83 c4 08             	add    $0x8,%esp
f0103d94:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103d98:	50                   	push   %eax
f0103d99:	68 d7 76 10 f0       	push   $0xf01076d7
f0103d9e:	e8 b1 fa ff ff       	call   f0103854 <cprintf>
	   cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103da3:	83 c4 08             	add    $0x8,%esp
f0103da6:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103daa:	50                   	push   %eax
f0103dab:	68 ea 76 10 f0       	push   $0xf01076ea
f0103db0:	e8 9f fa ff ff       	call   f0103854 <cprintf>
	   cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103db5:	8b 43 28             	mov    0x28(%ebx),%eax
			 "Alignment Check",
			 "Machine-Check",
			 "SIMD Floating-Point Exception"
	   };

	   if (trapno < ARRAY_SIZE(excnames))
f0103db8:	83 c4 10             	add    $0x10,%esp
f0103dbb:	83 f8 13             	cmp    $0x13,%eax
f0103dbe:	77 09                	ja     f0103dc9 <print_trapframe+0x5c>
			 return excnames[trapno];
f0103dc0:	8b 14 85 00 7a 10 f0 	mov    -0xfef8600(,%eax,4),%edx
f0103dc7:	eb 1f                	jmp    f0103de8 <print_trapframe+0x7b>
	   if (trapno == T_SYSCALL)
f0103dc9:	83 f8 30             	cmp    $0x30,%eax
f0103dcc:	74 15                	je     f0103de3 <print_trapframe+0x76>
			 return "System call";
	   if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103dce:	8d 50 e0             	lea    -0x20(%eax),%edx
			 return "Hardware Interrupt";
	   return "(unknown trap)";
f0103dd1:	83 fa 10             	cmp    $0x10,%edx
f0103dd4:	b9 83 76 10 f0       	mov    $0xf0107683,%ecx
f0103dd9:	ba 70 76 10 f0       	mov    $0xf0107670,%edx
f0103dde:	0f 43 d1             	cmovae %ecx,%edx
f0103de1:	eb 05                	jmp    f0103de8 <print_trapframe+0x7b>
	   };

	   if (trapno < ARRAY_SIZE(excnames))
			 return excnames[trapno];
	   if (trapno == T_SYSCALL)
			 return "System call";
f0103de3:	ba 64 76 10 f0       	mov    $0xf0107664,%edx

	   cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	   print_regs(&tf->tf_regs);
	   cprintf("  es   0x----%04x\n", tf->tf_es);
	   cprintf("  ds   0x----%04x\n", tf->tf_ds);
	   cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103de8:	83 ec 04             	sub    $0x4,%esp
f0103deb:	52                   	push   %edx
f0103dec:	50                   	push   %eax
f0103ded:	68 fd 76 10 f0       	push   $0xf01076fd
f0103df2:	e8 5d fa ff ff       	call   f0103854 <cprintf>
	   // If this trap was a page fault that just happened
	   // (so %cr2 is meaningful), print the faulting linear address.
	   if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103df7:	83 c4 10             	add    $0x10,%esp
f0103dfa:	3b 1d 60 fa 22 f0    	cmp    0xf022fa60,%ebx
f0103e00:	75 1a                	jne    f0103e1c <print_trapframe+0xaf>
f0103e02:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e06:	75 14                	jne    f0103e1c <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103e08:	0f 20 d0             	mov    %cr2,%eax
			 cprintf("  cr2  0x%08x\n", rcr2());
f0103e0b:	83 ec 08             	sub    $0x8,%esp
f0103e0e:	50                   	push   %eax
f0103e0f:	68 0f 77 10 f0       	push   $0xf010770f
f0103e14:	e8 3b fa ff ff       	call   f0103854 <cprintf>
f0103e19:	83 c4 10             	add    $0x10,%esp
	   cprintf("  err  0x%08x", tf->tf_err);
f0103e1c:	83 ec 08             	sub    $0x8,%esp
f0103e1f:	ff 73 2c             	pushl  0x2c(%ebx)
f0103e22:	68 1e 77 10 f0       	push   $0xf010771e
f0103e27:	e8 28 fa ff ff       	call   f0103854 <cprintf>
	   // For page faults, print decoded fault error code:
	   // U/K=fault occurred in user/kernel mode
	   // W/R=a write/read caused the fault
	   // PR=a protection violation caused the fault (NP=page not present).
	   if (tf->tf_trapno == T_PGFLT)
f0103e2c:	83 c4 10             	add    $0x10,%esp
f0103e2f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e33:	75 49                	jne    f0103e7e <print_trapframe+0x111>
			 cprintf(" [%s, %s, %s]\n",
						  tf->tf_err & 4 ? "user" : "kernel",
						  tf->tf_err & 2 ? "write" : "read",
						  tf->tf_err & 1 ? "protection" : "not-present");
f0103e35:	8b 43 2c             	mov    0x2c(%ebx),%eax
	   // For page faults, print decoded fault error code:
	   // U/K=fault occurred in user/kernel mode
	   // W/R=a write/read caused the fault
	   // PR=a protection violation caused the fault (NP=page not present).
	   if (tf->tf_trapno == T_PGFLT)
			 cprintf(" [%s, %s, %s]\n",
f0103e38:	89 c2                	mov    %eax,%edx
f0103e3a:	83 e2 01             	and    $0x1,%edx
f0103e3d:	ba 9d 76 10 f0       	mov    $0xf010769d,%edx
f0103e42:	b9 92 76 10 f0       	mov    $0xf0107692,%ecx
f0103e47:	0f 44 ca             	cmove  %edx,%ecx
f0103e4a:	89 c2                	mov    %eax,%edx
f0103e4c:	83 e2 02             	and    $0x2,%edx
f0103e4f:	ba af 76 10 f0       	mov    $0xf01076af,%edx
f0103e54:	be a9 76 10 f0       	mov    $0xf01076a9,%esi
f0103e59:	0f 45 d6             	cmovne %esi,%edx
f0103e5c:	83 e0 04             	and    $0x4,%eax
f0103e5f:	be 12 78 10 f0       	mov    $0xf0107812,%esi
f0103e64:	b8 b4 76 10 f0       	mov    $0xf01076b4,%eax
f0103e69:	0f 44 c6             	cmove  %esi,%eax
f0103e6c:	51                   	push   %ecx
f0103e6d:	52                   	push   %edx
f0103e6e:	50                   	push   %eax
f0103e6f:	68 2c 77 10 f0       	push   $0xf010772c
f0103e74:	e8 db f9 ff ff       	call   f0103854 <cprintf>
f0103e79:	83 c4 10             	add    $0x10,%esp
f0103e7c:	eb 10                	jmp    f0103e8e <print_trapframe+0x121>
						  tf->tf_err & 4 ? "user" : "kernel",
						  tf->tf_err & 2 ? "write" : "read",
						  tf->tf_err & 1 ? "protection" : "not-present");
	   else
			 cprintf("\n");
f0103e7e:	83 ec 0c             	sub    $0xc,%esp
f0103e81:	68 e1 65 10 f0       	push   $0xf01065e1
f0103e86:	e8 c9 f9 ff ff       	call   f0103854 <cprintf>
f0103e8b:	83 c4 10             	add    $0x10,%esp
	   cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e8e:	83 ec 08             	sub    $0x8,%esp
f0103e91:	ff 73 30             	pushl  0x30(%ebx)
f0103e94:	68 3b 77 10 f0       	push   $0xf010773b
f0103e99:	e8 b6 f9 ff ff       	call   f0103854 <cprintf>
	   cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103e9e:	83 c4 08             	add    $0x8,%esp
f0103ea1:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103ea5:	50                   	push   %eax
f0103ea6:	68 4a 77 10 f0       	push   $0xf010774a
f0103eab:	e8 a4 f9 ff ff       	call   f0103854 <cprintf>
	   cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103eb0:	83 c4 08             	add    $0x8,%esp
f0103eb3:	ff 73 38             	pushl  0x38(%ebx)
f0103eb6:	68 5d 77 10 f0       	push   $0xf010775d
f0103ebb:	e8 94 f9 ff ff       	call   f0103854 <cprintf>
	   if ((tf->tf_cs & 3) != 0) {
f0103ec0:	83 c4 10             	add    $0x10,%esp
f0103ec3:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103ec7:	74 25                	je     f0103eee <print_trapframe+0x181>
			 cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103ec9:	83 ec 08             	sub    $0x8,%esp
f0103ecc:	ff 73 3c             	pushl  0x3c(%ebx)
f0103ecf:	68 6c 77 10 f0       	push   $0xf010776c
f0103ed4:	e8 7b f9 ff ff       	call   f0103854 <cprintf>
			 cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103ed9:	83 c4 08             	add    $0x8,%esp
f0103edc:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103ee0:	50                   	push   %eax
f0103ee1:	68 7b 77 10 f0       	push   $0xf010777b
f0103ee6:	e8 69 f9 ff ff       	call   f0103854 <cprintf>
f0103eeb:	83 c4 10             	add    $0x10,%esp
	   }
}
f0103eee:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103ef1:	5b                   	pop    %ebx
f0103ef2:	5e                   	pop    %esi
f0103ef3:	5d                   	pop    %ebp
f0103ef4:	c3                   	ret    

f0103ef5 <page_fault_handler>:
}


	   void
page_fault_handler(struct Trapframe *tf)
{
f0103ef5:	55                   	push   %ebp
f0103ef6:	89 e5                	mov    %esp,%ebp
f0103ef8:	57                   	push   %edi
f0103ef9:	56                   	push   %esi
f0103efa:	53                   	push   %ebx
f0103efb:	83 ec 1c             	sub    $0x1c,%esp
f0103efe:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103f01:	0f 20 d6             	mov    %cr2,%esi
	   fault_va = rcr2();

	   // Handle kernel-mode page faults.
	   // LAB 3: Your code here.

	   if((tf -> tf_cs & 0x03) == 0)
f0103f04:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f08:	75 15                	jne    f0103f1f <page_fault_handler+0x2a>
			 panic ("Page Fault in Kernel at address %x", fault_va);
f0103f0a:	56                   	push   %esi
f0103f0b:	68 5c 79 10 f0       	push   $0xf010795c
f0103f10:	68 63 01 00 00       	push   $0x163
f0103f15:	68 8e 77 10 f0       	push   $0xf010778e
f0103f1a:	e8 21 c1 ff ff       	call   f0100040 <_panic>
	   //   To change what the user environment runs, modify 'curenv->env_tf'
	   //   (the 'tf' variable points at 'curenv->env_tf').

	   // LAB 4: Your code here.

	   if (curenv -> env_pgfault_upcall)
f0103f1f:	e8 86 1c 00 00       	call   f0105baa <cpunum>
f0103f24:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f27:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103f2d:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103f31:	0f 84 af 00 00 00    	je     f0103fe6 <page_fault_handler+0xf1>
	   {
			 uintptr_t stack_top = UXSTACKTOP;
			 uintptr_t stack_bottom = UXSTACKTOP - PGSIZE;

			 if (tf -> tf_esp < UXSTACKTOP && tf -> tf_esp >= stack_bottom)
f0103f37:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f3a:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
				    stack_top = tf -> tf_esp - 4;
f0103f40:	83 e8 04             	sub    $0x4,%eax
f0103f43:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103f49:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0103f4e:	0f 46 f8             	cmovbe %eax,%edi

			 struct UTrapframe* utf_addr = (struct UTrapframe *) (stack_top - sizeof (struct UTrapframe));
f0103f51:	8d 47 cc             	lea    -0x34(%edi),%eax
f0103f54:	89 45 e4             	mov    %eax,-0x1c(%ebp)

			 user_mem_assert (curenv, (void *) utf_addr, sizeof (struct UTrapframe), PTE_U | PTE_W | PTE_P);
f0103f57:	e8 4e 1c 00 00       	call   f0105baa <cpunum>
f0103f5c:	6a 07                	push   $0x7
f0103f5e:	6a 34                	push   $0x34
f0103f60:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103f63:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f66:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0103f6c:	e8 34 ef ff ff       	call   f0102ea5 <user_mem_assert>

			 utf_addr -> utf_fault_va = fault_va;
f0103f71:	89 77 cc             	mov    %esi,-0x34(%edi)
			 utf_addr -> utf_err = tf -> tf_err;
f0103f74:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103f77:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103f7a:	89 42 04             	mov    %eax,0x4(%edx)
			 utf_addr -> utf_regs = tf -> tf_regs;
f0103f7d:	83 ef 2c             	sub    $0x2c,%edi
f0103f80:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103f85:	89 de                	mov    %ebx,%esi
f0103f87:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			 utf_addr -> utf_eip = tf -> tf_eip;
f0103f89:	8b 43 30             	mov    0x30(%ebx),%eax
f0103f8c:	89 42 28             	mov    %eax,0x28(%edx)
			 utf_addr -> utf_eflags = tf -> tf_eflags;
f0103f8f:	8b 43 38             	mov    0x38(%ebx),%eax
f0103f92:	89 d6                	mov    %edx,%esi
f0103f94:	89 42 2c             	mov    %eax,0x2c(%edx)
			 utf_addr -> utf_esp = tf -> tf_esp;
f0103f97:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f9a:	89 42 30             	mov    %eax,0x30(%edx)

			 curenv -> env_tf.tf_eip = (uintptr_t)(curenv -> env_pgfault_upcall);
f0103f9d:	e8 08 1c 00 00       	call   f0105baa <cpunum>
f0103fa2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fa5:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f0103fab:	e8 fa 1b 00 00       	call   f0105baa <cpunum>
f0103fb0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fb3:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103fb9:	8b 40 64             	mov    0x64(%eax),%eax
f0103fbc:	89 43 30             	mov    %eax,0x30(%ebx)
			 curenv -> env_tf.tf_esp = (uintptr_t) utf_addr;
f0103fbf:	e8 e6 1b 00 00       	call   f0105baa <cpunum>
f0103fc4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc7:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103fcd:	89 70 3c             	mov    %esi,0x3c(%eax)

			 env_run (curenv);
f0103fd0:	e8 d5 1b 00 00       	call   f0105baa <cpunum>
f0103fd5:	83 c4 04             	add    $0x4,%esp
f0103fd8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fdb:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0103fe1:	e8 54 f6 ff ff       	call   f010363a <env_run>
	   }

	   // Destroy the environment that caused the fault.
	   cprintf("Page fault upcall not defined for the environment \n");
f0103fe6:	83 ec 0c             	sub    $0xc,%esp
f0103fe9:	68 80 79 10 f0       	push   $0xf0107980
f0103fee:	e8 61 f8 ff ff       	call   f0103854 <cprintf>
	   cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ff3:	8b 7b 30             	mov    0x30(%ebx),%edi
				    curenv->env_id, fault_va, tf->tf_eip);
f0103ff6:	e8 af 1b 00 00       	call   f0105baa <cpunum>
			 env_run (curenv);
	   }

	   // Destroy the environment that caused the fault.
	   cprintf("Page fault upcall not defined for the environment \n");
	   cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ffb:	57                   	push   %edi
f0103ffc:	56                   	push   %esi
				    curenv->env_id, fault_va, tf->tf_eip);
f0103ffd:	6b c0 74             	imul   $0x74,%eax,%eax
			 env_run (curenv);
	   }

	   // Destroy the environment that caused the fault.
	   cprintf("Page fault upcall not defined for the environment \n");
	   cprintf("[%08x] user fault va %08x ip %08x\n",
f0104000:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104006:	ff 70 48             	pushl  0x48(%eax)
f0104009:	68 b4 79 10 f0       	push   $0xf01079b4
f010400e:	e8 41 f8 ff ff       	call   f0103854 <cprintf>
				    curenv->env_id, fault_va, tf->tf_eip);
	   print_trapframe(tf);
f0104013:	83 c4 14             	add    $0x14,%esp
f0104016:	53                   	push   %ebx
f0104017:	e8 51 fd ff ff       	call   f0103d6d <print_trapframe>
	   env_destroy(curenv);
f010401c:	e8 89 1b 00 00       	call   f0105baa <cpunum>
f0104021:	83 c4 04             	add    $0x4,%esp
f0104024:	6b c0 74             	imul   $0x74,%eax,%eax
f0104027:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f010402d:	e8 59 f5 ff ff       	call   f010358b <env_destroy>
}
f0104032:	83 c4 10             	add    $0x10,%esp
f0104035:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104038:	5b                   	pop    %ebx
f0104039:	5e                   	pop    %esi
f010403a:	5f                   	pop    %edi
f010403b:	5d                   	pop    %ebp
f010403c:	c3                   	ret    

f010403d <trap>:
	   }
}

	   void
trap(struct Trapframe *tf)
{
f010403d:	55                   	push   %ebp
f010403e:	89 e5                	mov    %esp,%ebp
f0104040:	57                   	push   %edi
f0104041:	56                   	push   %esi
f0104042:	8b 75 08             	mov    0x8(%ebp),%esi
	   // The environment may have set DF and some versions
	   // of GCC rely on DF being clear
	   asm volatile("cld" ::: "cc");
f0104045:	fc                   	cld    

	   // Halt the CPU if some other CPU has called panic()
	   extern char *panicstr;
	   if (panicstr)
f0104046:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f010404d:	74 01                	je     f0104050 <trap+0x13>
			 asm volatile("hlt");
f010404f:	f4                   	hlt    

	   // Re-acqurie the big kernel lock if we were halted in
	   // sched_yield()
	   if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104050:	e8 55 1b 00 00       	call   f0105baa <cpunum>
f0104055:	6b d0 74             	imul   $0x74,%eax,%edx
f0104058:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010405e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104063:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104067:	83 f8 02             	cmp    $0x2,%eax
f010406a:	75 10                	jne    f010407c <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010406c:	83 ec 0c             	sub    $0xc,%esp
f010406f:	68 c0 03 12 f0       	push   $0xf01203c0
f0104074:	e8 9f 1d 00 00       	call   f0105e18 <spin_lock>
f0104079:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010407c:	9c                   	pushf  
f010407d:	58                   	pop    %eax
			 lock_kernel();
	   // Check that interrupts are disabled.  If this assertion
	   // fails, DO NOT be tempted to fix it by inserting a "cli" in
	   // the interrupt path.
	   if (read_eflags() & FL_IF) {
f010407e:	f6 c4 02             	test   $0x2,%ah
f0104081:	74 2f                	je     f01040b2 <trap+0x75>
			 cprintf("TYPE 0x%08x\n", tf->tf_trapno);
f0104083:	83 ec 08             	sub    $0x8,%esp
f0104086:	ff 76 28             	pushl  0x28(%esi)
f0104089:	68 9a 77 10 f0       	push   $0xf010779a
f010408e:	e8 c1 f7 ff ff       	call   f0103854 <cprintf>
			 print_trapframe(tf);
f0104093:	89 34 24             	mov    %esi,(%esp)
f0104096:	e8 d2 fc ff ff       	call   f0103d6d <print_trapframe>
			 panic("interrupts are not disabled");
f010409b:	83 c4 0c             	add    $0xc,%esp
f010409e:	68 a7 77 10 f0       	push   $0xf01077a7
f01040a3:	68 29 01 00 00       	push   $0x129
f01040a8:	68 8e 77 10 f0       	push   $0xf010778e
f01040ad:	e8 8e bf ff ff       	call   f0100040 <_panic>
f01040b2:	9c                   	pushf  
f01040b3:	58                   	pop    %eax
	   }
	   assert(!(read_eflags() & FL_IF));
f01040b4:	f6 c4 02             	test   $0x2,%ah
f01040b7:	74 19                	je     f01040d2 <trap+0x95>
f01040b9:	68 c3 77 10 f0       	push   $0xf01077c3
f01040be:	68 18 68 10 f0       	push   $0xf0106818
f01040c3:	68 2b 01 00 00       	push   $0x12b
f01040c8:	68 8e 77 10 f0       	push   $0xf010778e
f01040cd:	e8 6e bf ff ff       	call   f0100040 <_panic>

	   if ((tf->tf_cs & 3) == 3) {
f01040d2:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01040d6:	83 e0 03             	and    $0x3,%eax
f01040d9:	66 83 f8 03          	cmp    $0x3,%ax
f01040dd:	0f 85 a0 00 00 00    	jne    f0104183 <trap+0x146>
f01040e3:	83 ec 0c             	sub    $0xc,%esp
f01040e6:	68 c0 03 12 f0       	push   $0xf01203c0
f01040eb:	e8 28 1d 00 00       	call   f0105e18 <spin_lock>
			 // Trapped from user mode.
			 // Acquire the big kernel lock before doing any
			 // serious kernel work.
			 // LAB 4: Your code here.
			 lock_kernel();
			 assert(curenv);
f01040f0:	e8 b5 1a 00 00       	call   f0105baa <cpunum>
f01040f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01040f8:	83 c4 10             	add    $0x10,%esp
f01040fb:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0104102:	75 19                	jne    f010411d <trap+0xe0>
f0104104:	68 dc 77 10 f0       	push   $0xf01077dc
f0104109:	68 18 68 10 f0       	push   $0xf0106818
f010410e:	68 33 01 00 00       	push   $0x133
f0104113:	68 8e 77 10 f0       	push   $0xf010778e
f0104118:	e8 23 bf ff ff       	call   f0100040 <_panic>


			 // Garbage collect if current enviroment is a zombie
			 if (curenv->env_status == ENV_DYING) {
f010411d:	e8 88 1a 00 00       	call   f0105baa <cpunum>
f0104122:	6b c0 74             	imul   $0x74,%eax,%eax
f0104125:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010412b:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010412f:	75 2d                	jne    f010415e <trap+0x121>
				    env_free(curenv);
f0104131:	e8 74 1a 00 00       	call   f0105baa <cpunum>
f0104136:	83 ec 0c             	sub    $0xc,%esp
f0104139:	6b c0 74             	imul   $0x74,%eax,%eax
f010413c:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104142:	e8 69 f2 ff ff       	call   f01033b0 <env_free>
				    curenv = NULL;
f0104147:	e8 5e 1a 00 00       	call   f0105baa <cpunum>
f010414c:	6b c0 74             	imul   $0x74,%eax,%eax
f010414f:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f0104156:	00 00 00 
				    sched_yield();
f0104159:	e8 9d 02 00 00       	call   f01043fb <sched_yield>
			 }

			 // Copy trap frame (which is currently on the stack)
			 // into 'curenv->env_tf', so that running the environment
			 // will restart at the trap point.
			 curenv->env_tf = *tf;
f010415e:	e8 47 1a 00 00       	call   f0105baa <cpunum>
f0104163:	6b c0 74             	imul   $0x74,%eax,%eax
f0104166:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010416c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104171:	89 c7                	mov    %eax,%edi
f0104173:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			 // The trapframe on the stack should be ignored from here on.
			 tf = &curenv->env_tf;
f0104175:	e8 30 1a 00 00       	call   f0105baa <cpunum>
f010417a:	6b c0 74             	imul   $0x74,%eax,%eax
f010417d:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
	   }

	   // Record that tf is the last real trapframe so
	   // print_trapframe can print some additional information.
	   last_tf = tf;
f0104183:	89 35 60 fa 22 f0    	mov    %esi,0xf022fa60
{

	   // Handle processor exceptions.
	   // LAB 3: Your code here.

	   if (tf -> tf_trapno == T_PGFLT)
f0104189:	8b 46 28             	mov    0x28(%esi),%eax
f010418c:	83 f8 0e             	cmp    $0xe,%eax
f010418f:	75 11                	jne    f01041a2 <trap+0x165>
	   {
			 page_fault_handler(tf);
f0104191:	83 ec 0c             	sub    $0xc,%esp
f0104194:	56                   	push   %esi
f0104195:	e8 5b fd ff ff       	call   f0103ef5 <page_fault_handler>
f010419a:	83 c4 10             	add    $0x10,%esp
f010419d:	e9 ba 00 00 00       	jmp    f010425c <trap+0x21f>
			 return;
	   } else if (tf -> tf_trapno == T_BRKPT)
f01041a2:	83 f8 03             	cmp    $0x3,%eax
f01041a5:	75 11                	jne    f01041b8 <trap+0x17b>
	   {
			 monitor (tf);
f01041a7:	83 ec 0c             	sub    $0xc,%esp
f01041aa:	56                   	push   %esi
f01041ab:	e8 79 c7 ff ff       	call   f0100929 <monitor>
f01041b0:	83 c4 10             	add    $0x10,%esp
f01041b3:	e9 a4 00 00 00       	jmp    f010425c <trap+0x21f>
			 return;
	   } else if (tf -> tf_trapno == T_SYSCALL)
f01041b8:	83 f8 30             	cmp    $0x30,%eax
f01041bb:	75 21                	jne    f01041de <trap+0x1a1>
	   {
			 //			 cprintf("SYSCALL Initiated \n");
			 int32_t return_value = syscall (tf -> tf_regs.reg_eax, tf -> tf_regs.reg_edx, tf -> tf_regs.reg_ecx, tf -> tf_regs.reg_ebx, tf -> tf_regs.reg_edi, tf -> tf_regs.reg_esi);
f01041bd:	83 ec 08             	sub    $0x8,%esp
f01041c0:	ff 76 04             	pushl  0x4(%esi)
f01041c3:	ff 36                	pushl  (%esi)
f01041c5:	ff 76 10             	pushl  0x10(%esi)
f01041c8:	ff 76 18             	pushl  0x18(%esi)
f01041cb:	ff 76 14             	pushl  0x14(%esi)
f01041ce:	ff 76 1c             	pushl  0x1c(%esi)
f01041d1:	e8 ed 02 00 00       	call   f01044c3 <syscall>
			 tf -> tf_regs.reg_eax = return_value;
f01041d6:	89 46 1c             	mov    %eax,0x1c(%esi)
f01041d9:	83 c4 20             	add    $0x20,%esp
f01041dc:	eb 7e                	jmp    f010425c <trap+0x21f>
	   }

	   // Handle spurious interrupts
	   // The hardware sometimes raises these because of noise on the
	   // IRQ line or other reasons. We don't care.
	   if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01041de:	83 f8 27             	cmp    $0x27,%eax
f01041e1:	75 1a                	jne    f01041fd <trap+0x1c0>
			 cprintf("Spurious interrupt on irq 7\n");
f01041e3:	83 ec 0c             	sub    $0xc,%esp
f01041e6:	68 e3 77 10 f0       	push   $0xf01077e3
f01041eb:	e8 64 f6 ff ff       	call   f0103854 <cprintf>
			 print_trapframe(tf);
f01041f0:	89 34 24             	mov    %esi,(%esp)
f01041f3:	e8 75 fb ff ff       	call   f0103d6d <print_trapframe>
f01041f8:	83 c4 10             	add    $0x10,%esp
f01041fb:	eb 5f                	jmp    f010425c <trap+0x21f>
	   }

	   // Handle clock interrupts. Don't forget to acknowledge the
	   // interrupt using lapic_eoi() before calling the scheduler!
	   // LAB 4: Your code here.
	   if (tf -> tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f01041fd:	83 f8 20             	cmp    $0x20,%eax
f0104200:	75 0a                	jne    f010420c <trap+0x1cf>
	   {
			 lapic_eoi();
f0104202:	e8 ee 1a 00 00       	call   f0105cf5 <lapic_eoi>
			 sched_yield();
f0104207:	e8 ef 01 00 00       	call   f01043fb <sched_yield>
	   }

	   // Unexpected trap: The user process or the kernel has a bug.
	   print_trapframe(tf);
f010420c:	83 ec 0c             	sub    $0xc,%esp
f010420f:	56                   	push   %esi
f0104210:	e8 58 fb ff ff       	call   f0103d6d <print_trapframe>
	   if (tf->tf_cs == GD_KT)
f0104215:	83 c4 10             	add    $0x10,%esp
f0104218:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010421d:	75 17                	jne    f0104236 <trap+0x1f9>
			 panic("unhandled trap in kernel");
f010421f:	83 ec 04             	sub    $0x4,%esp
f0104222:	68 00 78 10 f0       	push   $0xf0107800
f0104227:	68 0b 01 00 00       	push   $0x10b
f010422c:	68 8e 77 10 f0       	push   $0xf010778e
f0104231:	e8 0a be ff ff       	call   f0100040 <_panic>
	   else {
			 cprintf("Unhandled trap in user space \n");
f0104236:	83 ec 0c             	sub    $0xc,%esp
f0104239:	68 d8 79 10 f0       	push   $0xf01079d8
f010423e:	e8 11 f6 ff ff       	call   f0103854 <cprintf>
			 env_destroy(curenv);
f0104243:	e8 62 19 00 00       	call   f0105baa <cpunum>
f0104248:	83 c4 04             	add    $0x4,%esp
f010424b:	6b c0 74             	imul   $0x74,%eax,%eax
f010424e:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104254:	e8 32 f3 ff ff       	call   f010358b <env_destroy>
f0104259:	83 c4 10             	add    $0x10,%esp
	   trap_dispatch(tf);

	   // If we made it to this point, then no other environment was
	   // scheduled, so we should return to the current environment
	   // if doing so makes sense.
	   if (curenv && curenv->env_status == ENV_RUNNING)
f010425c:	e8 49 19 00 00       	call   f0105baa <cpunum>
f0104261:	6b c0 74             	imul   $0x74,%eax,%eax
f0104264:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010426b:	74 2a                	je     f0104297 <trap+0x25a>
f010426d:	e8 38 19 00 00       	call   f0105baa <cpunum>
f0104272:	6b c0 74             	imul   $0x74,%eax,%eax
f0104275:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010427b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010427f:	75 16                	jne    f0104297 <trap+0x25a>
			 env_run(curenv);
f0104281:	e8 24 19 00 00       	call   f0105baa <cpunum>
f0104286:	83 ec 0c             	sub    $0xc,%esp
f0104289:	6b c0 74             	imul   $0x74,%eax,%eax
f010428c:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104292:	e8 a3 f3 ff ff       	call   f010363a <env_run>
	   else
			 sched_yield();
f0104297:	e8 5f 01 00 00       	call   f01043fb <sched_yield>

f010429c <divide_exception>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC (divide_exception, T_DIVIDE);
f010429c:	6a 00                	push   $0x0
f010429e:	6a 00                	push   $0x0
f01042a0:	eb 74                	jmp    f0104316 <_alltraps>

f01042a2 <debug_exception>:
TRAPHANDLER_NOEC (debug_exception, T_DEBUG);
f01042a2:	6a 00                	push   $0x0
f01042a4:	6a 01                	push   $0x1
f01042a6:	eb 6e                	jmp    f0104316 <_alltraps>

f01042a8 <nmi_interupt>:
TRAPHANDLER_NOEC (nmi_interupt, T_NMI);
f01042a8:	6a 00                	push   $0x0
f01042aa:	6a 02                	push   $0x2
f01042ac:	eb 68                	jmp    f0104316 <_alltraps>

f01042ae <breakpoint_exception>:
TRAPHANDLER_NOEC (breakpoint_exception, T_BRKPT);
f01042ae:	6a 00                	push   $0x0
f01042b0:	6a 03                	push   $0x3
f01042b2:	eb 62                	jmp    f0104316 <_alltraps>

f01042b4 <overflow_exception>:
TRAPHANDLER_NOEC (overflow_exception, T_OFLOW);
f01042b4:	6a 00                	push   $0x0
f01042b6:	6a 04                	push   $0x4
f01042b8:	eb 5c                	jmp    f0104316 <_alltraps>

f01042ba <bounds_check_exception>:
TRAPHANDLER_NOEC (bounds_check_exception, T_BOUND);
f01042ba:	6a 00                	push   $0x0
f01042bc:	6a 05                	push   $0x5
f01042be:	eb 56                	jmp    f0104316 <_alltraps>

f01042c0 <illegal_opcode_exception>:
TRAPHANDLER_NOEC (illegal_opcode_exception, T_ILLOP);
f01042c0:	6a 00                	push   $0x0
f01042c2:	6a 06                	push   $0x6
f01042c4:	eb 50                	jmp    f0104316 <_alltraps>

f01042c6 <coprocessor_exception>:
TRAPHANDLER_NOEC (coprocessor_exception, T_DEVICE);
f01042c6:	6a 00                	push   $0x0
f01042c8:	6a 07                	push   $0x7
f01042ca:	eb 4a                	jmp    f0104316 <_alltraps>

f01042cc <double_fault_exception>:
TRAPHANDLER (double_fault_exception, T_DBLFLT);
f01042cc:	6a 08                	push   $0x8
f01042ce:	eb 46                	jmp    f0104316 <_alltraps>

f01042d0 <tss_exception>:
TRAPHANDLER (tss_exception, T_TSS);
f01042d0:	6a 0a                	push   $0xa
f01042d2:	eb 42                	jmp    f0104316 <_alltraps>

f01042d4 <segment_np_exception>:
TRAPHANDLER (segment_np_exception, T_SEGNP);
f01042d4:	6a 0b                	push   $0xb
f01042d6:	eb 3e                	jmp    f0104316 <_alltraps>

f01042d8 <stack_np_excecption>:
TRAPHANDLER (stack_np_excecption, T_STACK);
f01042d8:	6a 0c                	push   $0xc
f01042da:	eb 3a                	jmp    f0104316 <_alltraps>

f01042dc <general_protection_fault>:
TRAPHANDLER (general_protection_fault, T_GPFLT);
f01042dc:	6a 0d                	push   $0xd
f01042de:	eb 36                	jmp    f0104316 <_alltraps>

f01042e0 <page_fault_exception>:
TRAPHANDLER (page_fault_exception, T_PGFLT);
f01042e0:	6a 0e                	push   $0xe
f01042e2:	eb 32                	jmp    f0104316 <_alltraps>

f01042e4 <fp_err_exception>:
TRAPHANDLER_NOEC (fp_err_exception, T_FPERR);
f01042e4:	6a 00                	push   $0x0
f01042e6:	6a 10                	push   $0x10
f01042e8:	eb 2c                	jmp    f0104316 <_alltraps>

f01042ea <alignment_exception>:
TRAPHANDLER (alignment_exception, T_ALIGN);
f01042ea:	6a 11                	push   $0x11
f01042ec:	eb 28                	jmp    f0104316 <_alltraps>

f01042ee <machine_exception>:
TRAPHANDLER_NOEC (machine_exception, T_MCHK);
f01042ee:	6a 00                	push   $0x0
f01042f0:	6a 12                	push   $0x12
f01042f2:	eb 22                	jmp    f0104316 <_alltraps>

f01042f4 <SIMDerr_exception>:
TRAPHANDLER_NOEC  (SIMDerr_exception, T_SIMDERR);
f01042f4:	6a 00                	push   $0x0
f01042f6:	6a 13                	push   $0x13
f01042f8:	eb 1c                	jmp    f0104316 <_alltraps>

f01042fa <syscall_interrupt>:

TRAPHANDLER_NOEC (syscall_interrupt, T_SYSCALL);
f01042fa:	6a 00                	push   $0x0
f01042fc:	6a 30                	push   $0x30
f01042fe:	eb 16                	jmp    f0104316 <_alltraps>

f0104300 <t_default>:

TRAPHANDLER_NOEC(t_default, T_DEFAULT);
f0104300:	6a 00                	push   $0x0
f0104302:	68 f4 01 00 00       	push   $0x1f4
f0104307:	eb 0d                	jmp    f0104316 <_alltraps>
f0104309:	90                   	nop

f010430a <IRQ_TimerINT>:

TRAPHANDLER_NOEC (IRQ_TimerINT, IRQ_OFFSET + IRQ_TIMER);
f010430a:	6a 00                	push   $0x0
f010430c:	6a 20                	push   $0x20
f010430e:	eb 06                	jmp    f0104316 <_alltraps>

f0104310 <IRQ_ErrorINT>:
TRAPHANDLER_NOEC (IRQ_ErrorINT, IRQ_OFFSET + IRQ_ERROR);
f0104310:	6a 00                	push   $0x0
f0104312:	6a 33                	push   $0x33
f0104314:	eb 00                	jmp    f0104316 <_alltraps>

f0104316 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
pushl %ds
f0104316:	1e                   	push   %ds
pushl %es
f0104317:	06                   	push   %es
pushal
f0104318:	60                   	pusha  
movw $GD_KD, %ax
f0104319:	66 b8 10 00          	mov    $0x10,%ax
movw %ax, %ds
f010431d:	8e d8                	mov    %eax,%ds
movw %ax, %es
f010431f:	8e c0                	mov    %eax,%es
pushl %esp
f0104321:	54                   	push   %esp
call trap
f0104322:	e8 16 fd ff ff       	call   f010403d <trap>

f0104327 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
	   void
sched_halt(void)
{
f0104327:	55                   	push   %ebp
f0104328:	89 e5                	mov    %esp,%ebp
f010432a:	83 ec 08             	sub    $0x8,%esp
f010432d:	a1 48 f2 22 f0       	mov    0xf022f248,%eax
f0104332:	8d 50 54             	lea    0x54(%eax),%edx
	   int i;

	   // For debugging and testing purposes, if there are no runnable
	   // environments in the system, then drop into the kernel monitor.
	   for (i = 0; i < NENV; i++) {
f0104335:	b9 00 00 00 00       	mov    $0x0,%ecx
			 if ((envs[i].env_status == ENV_RUNNABLE ||
f010433a:	8b 02                	mov    (%edx),%eax
f010433c:	83 e8 01             	sub    $0x1,%eax
f010433f:	83 f8 02             	cmp    $0x2,%eax
f0104342:	76 10                	jbe    f0104354 <sched_halt+0x2d>
{
	   int i;

	   // For debugging and testing purposes, if there are no runnable
	   // environments in the system, then drop into the kernel monitor.
	   for (i = 0; i < NENV; i++) {
f0104344:	83 c1 01             	add    $0x1,%ecx
f0104347:	83 c2 7c             	add    $0x7c,%edx
f010434a:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104350:	75 e8                	jne    f010433a <sched_halt+0x13>
f0104352:	eb 08                	jmp    f010435c <sched_halt+0x35>
			 if ((envs[i].env_status == ENV_RUNNABLE ||
								envs[i].env_status == ENV_RUNNING ||
								envs[i].env_status == ENV_DYING))
				    break;
	   }
	   if (i == NENV) {
f0104354:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010435a:	75 1f                	jne    f010437b <sched_halt+0x54>
			 cprintf("No runnable environments in the system!\n");
f010435c:	83 ec 0c             	sub    $0xc,%esp
f010435f:	68 50 7a 10 f0       	push   $0xf0107a50
f0104364:	e8 eb f4 ff ff       	call   f0103854 <cprintf>
f0104369:	83 c4 10             	add    $0x10,%esp
			 while (1)
				    monitor(NULL);
f010436c:	83 ec 0c             	sub    $0xc,%esp
f010436f:	6a 00                	push   $0x0
f0104371:	e8 b3 c5 ff ff       	call   f0100929 <monitor>
f0104376:	83 c4 10             	add    $0x10,%esp
f0104379:	eb f1                	jmp    f010436c <sched_halt+0x45>
	   }

	   // Mark that no environment is running on this CPU
	   curenv = NULL;
f010437b:	e8 2a 18 00 00       	call   f0105baa <cpunum>
f0104380:	6b c0 74             	imul   $0x74,%eax,%eax
f0104383:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f010438a:	00 00 00 
	   lcr3(PADDR(kern_pgdir));
f010438d:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104392:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104397:	77 12                	ja     f01043ab <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104399:	50                   	push   %eax
f010439a:	68 88 62 10 f0       	push   $0xf0106288
f010439f:	6a 55                	push   $0x55
f01043a1:	68 9c 7a 10 f0       	push   $0xf0107a9c
f01043a6:	e8 95 bc ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01043ab:	05 00 00 00 10       	add    $0x10000000,%eax
f01043b0:	0f 22 d8             	mov    %eax,%cr3

	   // Mark that this CPU is in the HALT state, so that when
	   // timer interupts come in, we know we should re-acquire the
	   // big kernel lock
	   xchg(&thiscpu->cpu_status, CPU_HALTED);
f01043b3:	e8 f2 17 00 00       	call   f0105baa <cpunum>
f01043b8:	6b d0 74             	imul   $0x74,%eax,%edx
f01043bb:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01043c1:	b8 02 00 00 00       	mov    $0x2,%eax
f01043c6:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01043ca:	83 ec 0c             	sub    $0xc,%esp
f01043cd:	68 c0 03 12 f0       	push   $0xf01203c0
f01043d2:	e8 de 1a 00 00       	call   f0105eb5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01043d7:	f3 90                	pause  
				    // Uncomment the following line after completing exercise 13
				    		"sti\n"
				    "1:\n"
				    "hlt\n"
				    "jmp 1b\n"
				    : : "a" (thiscpu->cpu_ts.ts_esp0));
f01043d9:	e8 cc 17 00 00       	call   f0105baa <cpunum>
f01043de:	6b c0 74             	imul   $0x74,%eax,%eax

	   // Release the big kernel lock as if we were "leaving" the kernel
	   unlock_kernel();

	   // Reset stack pointer, enable interrupts and then halt.
	   asm volatile (
f01043e1:	8b 80 30 00 23 f0    	mov    -0xfdcffd0(%eax),%eax
f01043e7:	bd 00 00 00 00       	mov    $0x0,%ebp
f01043ec:	89 c4                	mov    %eax,%esp
f01043ee:	6a 00                	push   $0x0
f01043f0:	6a 00                	push   $0x0
f01043f2:	fb                   	sti    
f01043f3:	f4                   	hlt    
f01043f4:	eb fd                	jmp    f01043f3 <sched_halt+0xcc>
				    		"sti\n"
				    "1:\n"
				    "hlt\n"
				    "jmp 1b\n"
				    : : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01043f6:	83 c4 10             	add    $0x10,%esp
f01043f9:	c9                   	leave  
f01043fa:	c3                   	ret    

f01043fb <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
	   void
sched_yield(void)
{
f01043fb:	55                   	push   %ebp
f01043fc:	89 e5                	mov    %esp,%ebp
f01043fe:	56                   	push   %esi
f01043ff:	53                   	push   %ebx
	   // no runnable environments, simply drop through to the code
	   // below to halt the cpu.

	   // LAB 4: Your code here.

	   int begin = curenv ? ENVX(curenv -> env_id) + 1 : 0;
f0104400:	e8 a5 17 00 00       	call   f0105baa <cpunum>
f0104405:	6b c0 74             	imul   $0x74,%eax,%eax
f0104408:	b9 00 00 00 00       	mov    $0x0,%ecx
f010440d:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0104414:	74 1a                	je     f0104430 <sched_yield+0x35>
f0104416:	e8 8f 17 00 00       	call   f0105baa <cpunum>
f010441b:	6b c0 74             	imul   $0x74,%eax,%eax
f010441e:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104424:	8b 48 48             	mov    0x48(%eax),%ecx
f0104427:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f010442d:	83 c1 01             	add    $0x1,%ecx
	   bool found = false;

	   for (int i = 0; i < NENV; i++)
	   {
			 index = (begin + i) % NENV;
			 if (envs[index].env_status == ENV_RUNNABLE)
f0104430:	8b 1d 48 f2 22 f0    	mov    0xf022f248,%ebx
f0104436:	89 ca                	mov    %ecx,%edx
f0104438:	81 c1 00 04 00 00    	add    $0x400,%ecx
f010443e:	89 d6                	mov    %edx,%esi
f0104440:	c1 fe 1f             	sar    $0x1f,%esi
f0104443:	c1 ee 16             	shr    $0x16,%esi
f0104446:	8d 04 32             	lea    (%edx,%esi,1),%eax
f0104449:	25 ff 03 00 00       	and    $0x3ff,%eax
f010444e:	29 f0                	sub    %esi,%eax
f0104450:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104453:	01 d8                	add    %ebx,%eax
f0104455:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104459:	74 4c                	je     f01044a7 <sched_yield+0xac>
f010445b:	83 c2 01             	add    $0x1,%edx

	   int begin = curenv ? ENVX(curenv -> env_id) + 1 : 0;
	   int index = begin;
	   bool found = false;

	   for (int i = 0; i < NENV; i++)
f010445e:	39 ca                	cmp    %ecx,%edx
f0104460:	75 dc                	jne    f010443e <sched_yield+0x43>
f0104462:	eb 4c                	jmp    f01044b0 <sched_yield+0xb5>
	   }

	   if (found)
	   {
			 env_run (&envs [index]);
	   } else if (curenv && curenv -> env_status == ENV_RUNNING)
f0104464:	e8 41 17 00 00       	call   f0105baa <cpunum>
f0104469:	6b c0 74             	imul   $0x74,%eax,%eax
f010446c:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104472:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104476:	75 16                	jne    f010448e <sched_yield+0x93>
	   {
			 env_run (curenv);
f0104478:	e8 2d 17 00 00       	call   f0105baa <cpunum>
f010447d:	83 ec 0c             	sub    $0xc,%esp
f0104480:	6b c0 74             	imul   $0x74,%eax,%eax
f0104483:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104489:	e8 ac f1 ff ff       	call   f010363a <env_run>
	   } else 
	   {
			 // sched_halt never returns
			 sched_halt();
f010448e:	e8 94 fe ff ff       	call   f0104327 <sched_halt>
	   }
	   panic("sched_yield attempted to return");
f0104493:	83 ec 04             	sub    $0x4,%esp
f0104496:	68 7c 7a 10 f0       	push   $0xf0107a7c
f010449b:	6a 3a                	push   $0x3a
f010449d:	68 9c 7a 10 f0       	push   $0xf0107a9c
f01044a2:	e8 99 bb ff ff       	call   f0100040 <_panic>
			 }
	   }

	   if (found)
	   {
			 env_run (&envs [index]);
f01044a7:	83 ec 0c             	sub    $0xc,%esp
f01044aa:	50                   	push   %eax
f01044ab:	e8 8a f1 ff ff       	call   f010363a <env_run>
	   } else if (curenv && curenv -> env_status == ENV_RUNNING)
f01044b0:	e8 f5 16 00 00       	call   f0105baa <cpunum>
f01044b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01044b8:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01044bf:	75 a3                	jne    f0104464 <sched_yield+0x69>
f01044c1:	eb cb                	jmp    f010448e <sched_yield+0x93>

f01044c3 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
	   int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01044c3:	55                   	push   %ebp
f01044c4:	89 e5                	mov    %esp,%ebp
f01044c6:	57                   	push   %edi
f01044c7:	56                   	push   %esi
f01044c8:	53                   	push   %ebx
f01044c9:	83 ec 1c             	sub    $0x1c,%esp
f01044cc:	8b 45 08             	mov    0x8(%ebp),%eax
	   // Return any appropriate return value.
	   // LAB 3: Your code here.

	   //	panic("syscall not implemented");

	   switch (syscallno) {
f01044cf:	83 f8 0c             	cmp    $0xc,%eax
f01044d2:	0f 87 04 05 00 00    	ja     f01049dc <syscall+0x519>
f01044d8:	ff 24 85 e4 7a 10 f0 	jmp    *-0xfef851c(,%eax,4)
	   // Check that the user has permission to read memory [s, s+len).
	   // Destroy the environment if not.

	   // LAB 3: Your code here.
	   //	   if (curenv -> env_tf.tf_cs &3)
	   user_mem_assert (curenv, (void*)s, len, PTE_U | PTE_P);
f01044df:	e8 c6 16 00 00       	call   f0105baa <cpunum>
f01044e4:	6a 05                	push   $0x5
f01044e6:	ff 75 10             	pushl  0x10(%ebp)
f01044e9:	ff 75 0c             	pushl  0xc(%ebp)
f01044ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ef:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01044f5:	e8 ab e9 ff ff       	call   f0102ea5 <user_mem_assert>

	   // Print the string supplied by the user.
	   cprintf("%.*s", len, s);
f01044fa:	83 c4 0c             	add    $0xc,%esp
f01044fd:	ff 75 0c             	pushl  0xc(%ebp)
f0104500:	ff 75 10             	pushl  0x10(%ebp)
f0104503:	68 a9 7a 10 f0       	push   $0xf0107aa9
f0104508:	e8 47 f3 ff ff       	call   f0103854 <cprintf>
f010450d:	83 c4 10             	add    $0x10,%esp
	   //	panic("syscall not implemented");

	   switch (syscallno) {
			 case SYS_cputs:
				    sys_cputs (( char*) a1, a2);
				    return 0;
f0104510:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104515:	e9 6c 05 00 00       	jmp    f0104a86 <syscall+0x5c3>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
	   static int
sys_cgetc(void)
{
	   return cons_getc();
f010451a:	e8 bf c0 ff ff       	call   f01005de <cons_getc>
f010451f:	89 c3                	mov    %eax,%ebx
	   switch (syscallno) {
			 case SYS_cputs:
				    sys_cputs (( char*) a1, a2);
				    return 0;
			 case SYS_cgetc:
				    return sys_cgetc ();
f0104521:	e9 60 05 00 00       	jmp    f0104a86 <syscall+0x5c3>

// Returns the current environment's envid.
	   static envid_t
sys_getenvid(void)
{
	   return curenv->env_id;
f0104526:	e8 7f 16 00 00       	call   f0105baa <cpunum>
f010452b:	6b c0 74             	imul   $0x74,%eax,%eax
f010452e:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104534:	8b 58 48             	mov    0x48(%eax),%ebx
				    sys_cputs (( char*) a1, a2);
				    return 0;
			 case SYS_cgetc:
				    return sys_cgetc ();
			 case SYS_getenvid:
				    return sys_getenvid();
f0104537:	e9 4a 05 00 00       	jmp    f0104a86 <syscall+0x5c3>
sys_env_destroy(envid_t envid)
{
	   int r;
	   struct Env *e;

	   if ((r = envid2env(envid, &e, 1)) < 0)
f010453c:	83 ec 04             	sub    $0x4,%esp
f010453f:	6a 01                	push   $0x1
f0104541:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104544:	50                   	push   %eax
f0104545:	ff 75 0c             	pushl  0xc(%ebp)
f0104548:	e8 43 ea ff ff       	call   f0102f90 <envid2env>
f010454d:	83 c4 10             	add    $0x10,%esp
			 return r;
f0104550:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	   int r;
	   struct Env *e;

	   if ((r = envid2env(envid, &e, 1)) < 0)
f0104552:	85 c0                	test   %eax,%eax
f0104554:	0f 88 2c 05 00 00    	js     f0104a86 <syscall+0x5c3>
			 return r;
	   if (e == curenv)
f010455a:	e8 4b 16 00 00       	call   f0105baa <cpunum>
f010455f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104562:	6b c0 74             	imul   $0x74,%eax,%eax
f0104565:	39 90 28 00 23 f0    	cmp    %edx,-0xfdcffd8(%eax)
f010456b:	75 23                	jne    f0104590 <syscall+0xcd>
			 cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010456d:	e8 38 16 00 00       	call   f0105baa <cpunum>
f0104572:	83 ec 08             	sub    $0x8,%esp
f0104575:	6b c0 74             	imul   $0x74,%eax,%eax
f0104578:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010457e:	ff 70 48             	pushl  0x48(%eax)
f0104581:	68 ae 7a 10 f0       	push   $0xf0107aae
f0104586:	e8 c9 f2 ff ff       	call   f0103854 <cprintf>
f010458b:	83 c4 10             	add    $0x10,%esp
f010458e:	eb 25                	jmp    f01045b5 <syscall+0xf2>
	   else
			 cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104590:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104593:	e8 12 16 00 00       	call   f0105baa <cpunum>
f0104598:	83 ec 04             	sub    $0x4,%esp
f010459b:	53                   	push   %ebx
f010459c:	6b c0 74             	imul   $0x74,%eax,%eax
f010459f:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01045a5:	ff 70 48             	pushl  0x48(%eax)
f01045a8:	68 c9 7a 10 f0       	push   $0xf0107ac9
f01045ad:	e8 a2 f2 ff ff       	call   f0103854 <cprintf>
f01045b2:	83 c4 10             	add    $0x10,%esp
	   env_destroy(e);
f01045b5:	83 ec 0c             	sub    $0xc,%esp
f01045b8:	ff 75 e4             	pushl  -0x1c(%ebp)
f01045bb:	e8 cb ef ff ff       	call   f010358b <env_destroy>
f01045c0:	83 c4 10             	add    $0x10,%esp
	   return 0;
f01045c3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01045c8:	e9 b9 04 00 00       	jmp    f0104a86 <syscall+0x5c3>

// Deschedule current environment and pick a different one to run.
	   static void
sys_yield(void)
{
	   sched_yield();
f01045cd:	e8 29 fe ff ff       	call   f01043fb <sched_yield>
	   // from the current environment -- but tweaked so sys_exofork
	   // will appear to return 0.

	   // LAB 4: Your code here.

	   struct Env* new_env = NULL;
f01045d2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   int a = env_alloc (&new_env, curenv -> env_id);
f01045d9:	e8 cc 15 00 00       	call   f0105baa <cpunum>
f01045de:	83 ec 08             	sub    $0x8,%esp
f01045e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01045e4:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01045ea:	ff 70 48             	pushl  0x48(%eax)
f01045ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045f0:	50                   	push   %eax
f01045f1:	e8 a8 ea ff ff       	call   f010309e <env_alloc>
	   if (a < 0)
f01045f6:	83 c4 10             	add    $0x10,%esp
			 return a;
f01045f9:	89 c3                	mov    %eax,%ebx

	   // LAB 4: Your code here.

	   struct Env* new_env = NULL;
	   int a = env_alloc (&new_env, curenv -> env_id);
	   if (a < 0)
f01045fb:	85 c0                	test   %eax,%eax
f01045fd:	0f 88 83 04 00 00    	js     f0104a86 <syscall+0x5c3>
			 return a;

	   new_env -> env_status = ENV_NOT_RUNNABLE;
f0104603:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104606:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	   new_env -> env_tf = curenv -> env_tf;
f010460d:	e8 98 15 00 00       	call   f0105baa <cpunum>
f0104612:	6b c0 74             	imul   $0x74,%eax,%eax
f0104615:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
f010461b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104620:	89 df                	mov    %ebx,%edi
f0104622:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	   new_env -> env_tf.tf_regs.reg_eax = 0;
f0104624:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104627:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	   return new_env -> env_id;
f010462e:	8b 58 48             	mov    0x48(%eax),%ebx
f0104631:	e9 50 04 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   // You should set envid2env's third argument to 1, which will
	   // check whether the current environment has permission to set
	   // envid's status.

	   // LAB 4: Your code here.
	   struct Env* new_env = NULL;
f0104636:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   int a = envid2env (envid, &new_env, 1);
f010463d:	83 ec 04             	sub    $0x4,%esp
f0104640:	6a 01                	push   $0x1
f0104642:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104645:	50                   	push   %eax
f0104646:	ff 75 0c             	pushl  0xc(%ebp)
f0104649:	e8 42 e9 ff ff       	call   f0102f90 <envid2env>

	   if (a < 0)
f010464e:	83 c4 10             	add    $0x10,%esp
f0104651:	85 c0                	test   %eax,%eax
f0104653:	78 13                	js     f0104668 <syscall+0x1a5>
			 return a;

	   if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
			 -E_INVAL;

	   new_env -> env_status = status;
f0104655:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104658:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010465b:	89 48 54             	mov    %ecx,0x54(%eax)
	   return 0;
f010465e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104663:	e9 1e 04 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   // LAB 4: Your code here.
	   struct Env* new_env = NULL;
	   int a = envid2env (envid, &new_env, 1);

	   if (a < 0)
			 return a;
f0104668:	89 c3                	mov    %eax,%ebx
				    sys_yield();
				    return 0;
			 case SYS_exofork:
				    return sys_exofork();
			 case SYS_env_set_status:
				    return sys_env_set_status((envid_t) a1, (int) a2);
f010466a:	e9 17 04 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	   // LAB 4: Your code here.

	   struct Env* new_env = NULL;
f010466f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   int a = envid2env (envid, &new_env, 1);
f0104676:	83 ec 04             	sub    $0x4,%esp
f0104679:	6a 01                	push   $0x1
f010467b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010467e:	50                   	push   %eax
f010467f:	ff 75 0c             	pushl  0xc(%ebp)
f0104682:	e8 09 e9 ff ff       	call   f0102f90 <envid2env>
	   if (a < 0)
f0104687:	83 c4 10             	add    $0x10,%esp
f010468a:	85 c0                	test   %eax,%eax
f010468c:	78 13                	js     f01046a1 <syscall+0x1de>
			 return a;

	   new_env -> env_pgfault_upcall = func;
f010468e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104691:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104694:	89 78 64             	mov    %edi,0x64(%eax)
	   return 0;
f0104697:	bb 00 00 00 00       	mov    $0x0,%ebx
f010469c:	e9 e5 03 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   // LAB 4: Your code here.

	   struct Env* new_env = NULL;
	   int a = envid2env (envid, &new_env, 1);
	   if (a < 0)
			 return a;
f01046a1:	89 c3                	mov    %eax,%ebx
			 case SYS_exofork:
				    return sys_exofork();
			 case SYS_env_set_status:
				    return sys_env_set_status((envid_t) a1, (int) a2);
			 case SYS_env_set_pgfault_upcall:
				    return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
f01046a3:	e9 de 03 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   //   parameters for correctness.
	   //   If page_insert() fails, remember to free the page you
	   //   allocated!

	   // LAB 4: Your code here.
	   struct Env* new_env = NULL;
f01046a8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   int a = envid2env (envid, &new_env, 1);
f01046af:	83 ec 04             	sub    $0x4,%esp
f01046b2:	6a 01                	push   $0x1
f01046b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046b7:	50                   	push   %eax
f01046b8:	ff 75 0c             	pushl  0xc(%ebp)
f01046bb:	e8 d0 e8 ff ff       	call   f0102f90 <envid2env>

	   if (a < 0)
f01046c0:	83 c4 10             	add    $0x10,%esp
f01046c3:	85 c0                	test   %eax,%eax
f01046c5:	78 66                	js     f010472d <syscall+0x26a>
			 return a;
	   if ((uintptr_t)va >= UTOP || (uintptr_t) va % PGSIZE != 0)
f01046c7:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01046ce:	77 64                	ja     f0104734 <syscall+0x271>
f01046d0:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01046d7:	75 65                	jne    f010473e <syscall+0x27b>
			 return -E_INVAL;

	   if ((perm & ~PTE_SYSCALL) != 0)
f01046d9:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01046dc:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f01046e2:	75 64                	jne    f0104748 <syscall+0x285>
			 return -E_INVAL;

	   struct PageInfo* np = page_alloc(ALLOC_ZERO);
f01046e4:	83 ec 0c             	sub    $0xc,%esp
f01046e7:	6a 01                	push   $0x1
f01046e9:	e8 fc c8 ff ff       	call   f0100fea <page_alloc>
f01046ee:	89 c6                	mov    %eax,%esi
	   if (!np)
f01046f0:	83 c4 10             	add    $0x10,%esp
f01046f3:	85 c0                	test   %eax,%eax
f01046f5:	74 5b                	je     f0104752 <syscall+0x28f>
			 return -E_NO_MEM;

	   a = page_insert (new_env -> env_pgdir, np, va, perm | PTE_U | PTE_P);//PTE_SYSCALL);
f01046f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01046fa:	83 c8 05             	or     $0x5,%eax
f01046fd:	50                   	push   %eax
f01046fe:	ff 75 10             	pushl  0x10(%ebp)
f0104701:	56                   	push   %esi
f0104702:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104705:	ff 70 60             	pushl  0x60(%eax)
f0104708:	e8 d5 cb ff ff       	call   f01012e2 <page_insert>
f010470d:	89 c7                	mov    %eax,%edi
	   if (a < 0)
f010470f:	83 c4 10             	add    $0x10,%esp
f0104712:	85 c0                	test   %eax,%eax
f0104714:	0f 89 6c 03 00 00    	jns    f0104a86 <syscall+0x5c3>
	   {
			 page_free (np);
f010471a:	83 ec 0c             	sub    $0xc,%esp
f010471d:	56                   	push   %esi
f010471e:	e8 3e c9 ff ff       	call   f0101061 <page_free>
f0104723:	83 c4 10             	add    $0x10,%esp
			 return a;
f0104726:	89 fb                	mov    %edi,%ebx
f0104728:	e9 59 03 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   // LAB 4: Your code here.
	   struct Env* new_env = NULL;
	   int a = envid2env (envid, &new_env, 1);

	   if (a < 0)
			 return a;
f010472d:	89 c3                	mov    %eax,%ebx
f010472f:	e9 52 03 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   if ((uintptr_t)va >= UTOP || (uintptr_t) va % PGSIZE != 0)
			 return -E_INVAL;
f0104734:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104739:	e9 48 03 00 00       	jmp    f0104a86 <syscall+0x5c3>
f010473e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104743:	e9 3e 03 00 00       	jmp    f0104a86 <syscall+0x5c3>

	   if ((perm & ~PTE_SYSCALL) != 0)
			 return -E_INVAL;
f0104748:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010474d:	e9 34 03 00 00       	jmp    f0104a86 <syscall+0x5c3>

	   struct PageInfo* np = page_alloc(ALLOC_ZERO);
	   if (!np)
			 return -E_NO_MEM;
f0104752:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
			 case SYS_env_set_status:
				    return sys_env_set_status((envid_t) a1, (int) a2);
			 case SYS_env_set_pgfault_upcall:
				    return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
			 case SYS_page_alloc:
				    return sys_page_alloc((envid_t) a1, (void *)a2, (int) a3);
f0104757:	e9 2a 03 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   //   parameters for correctness.
	   //   Use the third argument to page_lookup() to
	   //   check the current permissions on the page.

	   // LAB 4: Your code here.
	   struct Env* source_env = NULL;
f010475c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	   struct Env* dest_env = NULL;
f0104763:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			 return -E_INVAL;

	   uintptr_t sa = (uintptr_t) srcva;
	   uintptr_t da = (uintptr_t) dstva;

	   if (sa >= UTOP || (sa % PGSIZE) != 0 || da >= UTOP || (da % PGSIZE) != 0)
f010476a:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104771:	0f 85 97 00 00 00    	jne    f010480e <syscall+0x34b>
f0104777:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010477e:	0f 87 8a 00 00 00    	ja     f010480e <syscall+0x34b>
f0104784:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010478b:	0f 85 87 00 00 00    	jne    f0104818 <syscall+0x355>
f0104791:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104798:	77 7e                	ja     f0104818 <syscall+0x355>
f010479a:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01047a1:	75 7f                	jne    f0104822 <syscall+0x35f>
			 return -E_INVAL;


	   a = envid2env (srcenvid, &source_env, 1);
f01047a3:	83 ec 04             	sub    $0x4,%esp
f01047a6:	6a 01                	push   $0x1
f01047a8:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01047ab:	50                   	push   %eax
f01047ac:	ff 75 0c             	pushl  0xc(%ebp)
f01047af:	e8 dc e7 ff ff       	call   f0102f90 <envid2env>
	   if (a < 0)
			 return a;
	   a = envid2env (dstenvid, &dest_env, 1);
f01047b4:	83 c4 0c             	add    $0xc,%esp
f01047b7:	6a 01                	push   $0x1
f01047b9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01047bc:	50                   	push   %eax
f01047bd:	ff 75 14             	pushl  0x14(%ebp)
f01047c0:	e8 cb e7 ff ff       	call   f0102f90 <envid2env>
	   if (a < 0)
			 return a;

	   struct PageInfo* np = page_lookup (source_env -> env_pgdir, srcva, &pte);
f01047c5:	83 c4 0c             	add    $0xc,%esp
f01047c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047cb:	50                   	push   %eax
f01047cc:	ff 75 10             	pushl  0x10(%ebp)
f01047cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01047d2:	ff 70 60             	pushl  0x60(%eax)
f01047d5:	e8 20 ca ff ff       	call   f01011fa <page_lookup>
	   if (!np)
f01047da:	83 c4 10             	add    $0x10,%esp
f01047dd:	85 c0                	test   %eax,%eax
f01047df:	74 4b                	je     f010482c <syscall+0x369>
			 return -E_INVAL;

	   if ((perm & PTE_W) && !(*pte & PTE_W))
f01047e1:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01047e5:	74 08                	je     f01047ef <syscall+0x32c>
f01047e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01047ea:	f6 02 02             	testb  $0x2,(%edx)
f01047ed:	74 47                	je     f0104836 <syscall+0x373>
			 return -E_INVAL;

	   a = page_insert (dest_env -> env_pgdir, np, dstva, perm);
f01047ef:	ff 75 1c             	pushl  0x1c(%ebp)
f01047f2:	ff 75 18             	pushl  0x18(%ebp)
f01047f5:	50                   	push   %eax
f01047f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047f9:	ff 70 60             	pushl  0x60(%eax)
f01047fc:	e8 e1 ca ff ff       	call   f01012e2 <page_insert>
f0104801:	83 c4 10             	add    $0x10,%esp
	   if (a < 0)
			 return a;

	   return 0;
f0104804:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104809:	e9 78 02 00 00       	jmp    f0104a86 <syscall+0x5c3>

	   uintptr_t sa = (uintptr_t) srcva;
	   uintptr_t da = (uintptr_t) dstva;

	   if (sa >= UTOP || (sa % PGSIZE) != 0 || da >= UTOP || (da % PGSIZE) != 0)
			 return -E_INVAL;
f010480e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104813:	e9 6e 02 00 00       	jmp    f0104a86 <syscall+0x5c3>
f0104818:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010481d:	e9 64 02 00 00       	jmp    f0104a86 <syscall+0x5c3>
f0104822:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104827:	e9 5a 02 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   if (a < 0)
			 return a;

	   struct PageInfo* np = page_lookup (source_env -> env_pgdir, srcva, &pte);
	   if (!np)
			 return -E_INVAL;
f010482c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104831:	e9 50 02 00 00       	jmp    f0104a86 <syscall+0x5c3>

	   if ((perm & PTE_W) && !(*pte & PTE_W))
			 return -E_INVAL;
f0104836:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			 case SYS_env_set_pgfault_upcall:
				    return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
			 case SYS_page_alloc:
				    return sys_page_alloc((envid_t) a1, (void *)a2, (int) a3);
			 case SYS_page_map:
				    return sys_page_map((envid_t) a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
f010483b:	e9 46 02 00 00       	jmp    f0104a86 <syscall+0x5c3>
sys_page_unmap(envid_t envid, void *va)
{
	   // Hint: This function is a wrapper around page_remove().

	   // LAB 4: Your code here.
	   struct Env* e_env = NULL;
f0104840:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   uint32_t a = 0;

	   if ((uintptr_t) va % PGSIZE != 0 || (uintptr_t) va >= UTOP)
f0104847:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010484e:	75 38                	jne    f0104888 <syscall+0x3c5>
f0104850:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104857:	77 2f                	ja     f0104888 <syscall+0x3c5>
			 return -E_INVAL;

	   a = envid2env (envid, &e_env, 1);
f0104859:	83 ec 04             	sub    $0x4,%esp
f010485c:	6a 01                	push   $0x1
f010485e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104861:	50                   	push   %eax
f0104862:	ff 75 0c             	pushl  0xc(%ebp)
f0104865:	e8 26 e7 ff ff       	call   f0102f90 <envid2env>
	   if (a < 0)
			 return a;

	   page_remove (e_env -> env_pgdir, va);
f010486a:	83 c4 08             	add    $0x8,%esp
f010486d:	ff 75 10             	pushl  0x10(%ebp)
f0104870:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104873:	ff 70 60             	pushl  0x60(%eax)
f0104876:	e8 1a ca ff ff       	call   f0101295 <page_remove>
f010487b:	83 c4 10             	add    $0x10,%esp

	   return 0;
f010487e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104883:	e9 fe 01 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   // LAB 4: Your code here.
	   struct Env* e_env = NULL;
	   uint32_t a = 0;

	   if ((uintptr_t) va % PGSIZE != 0 || (uintptr_t) va >= UTOP)
			 return -E_INVAL;
f0104888:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			 case SYS_page_alloc:
				    return sys_page_alloc((envid_t) a1, (void *)a2, (int) a3);
			 case SYS_page_map:
				    return sys_page_map((envid_t) a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
			 case SYS_page_unmap:
				    return sys_page_unmap((envid_t) a1, (void *) a2);
f010488d:	e9 f4 01 00 00       	jmp    f0104a86 <syscall+0x5c3>
sys_ipc_recv(void *dstva)
{
	   // LAB 4: Your code here.
	   uintptr_t address = (intptr_t) dstva;

	   if ((address < UTOP) && (address % PGSIZE) != 0)
f0104892:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104899:	0f 87 51 01 00 00    	ja     f01049f0 <syscall+0x52d>
f010489f:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01048a6:	0f 85 3a 01 00 00    	jne    f01049e6 <syscall+0x523>
f01048ac:	e9 80 01 00 00       	jmp    f0104a31 <syscall+0x56e>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	   // LAB 4: Your code here.
	   int a  = 0;
	   int r_perm = 0;
	   struct Env* d_env = NULL;
f01048b1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

	   uintptr_t address = (uintptr_t) srcva;

	   a = envid2env (envid, &d_env, 0);
f01048b8:	83 ec 04             	sub    $0x4,%esp
f01048bb:	6a 00                	push   $0x0
f01048bd:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01048c0:	50                   	push   %eax
f01048c1:	ff 75 0c             	pushl  0xc(%ebp)
f01048c4:	e8 c7 e6 ff ff       	call   f0102f90 <envid2env>
	   if (a < 0)
f01048c9:	83 c4 10             	add    $0x10,%esp
f01048cc:	85 c0                	test   %eax,%eax
f01048ce:	0f 88 e3 00 00 00    	js     f01049b7 <syscall+0x4f4>
	   {
			 return a;
	   } else if (!(d_env -> env_ipc_recving))
f01048d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048d7:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01048db:	0f 84 dd 00 00 00    	je     f01049be <syscall+0x4fb>
	   {
			 return -E_IPC_NOT_RECV;
	   } else if ((address < UTOP) && (address % PGSIZE) != 0)
f01048e1:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01048e8:	0f 87 8c 00 00 00    	ja     f010497a <syscall+0x4b7>
f01048ee:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01048f5:	0f 85 cd 00 00 00    	jne    f01049c8 <syscall+0x505>
	   {	return -E_INVAL;
	   } else if ((address < UTOP) && (perm & ~PTE_SYSCALL) != 0)
f01048fb:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104902:	0f 85 ca 00 00 00    	jne    f01049d2 <syscall+0x50f>
			 return -E_INVAL;
	   }

	   if (address < UTOP)
	   {
			 pte_t* pte = NULL;
f0104908:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			 struct PageInfo* page = page_lookup (curenv -> env_pgdir, srcva, &pte);
f010490f:	e8 96 12 00 00       	call   f0105baa <cpunum>
f0104914:	83 ec 04             	sub    $0x4,%esp
f0104917:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010491a:	52                   	push   %edx
f010491b:	ff 75 14             	pushl  0x14(%ebp)
f010491e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104921:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104927:	ff 70 60             	pushl  0x60(%eax)
f010492a:	e8 cb c8 ff ff       	call   f01011fa <page_lookup>
			 if (!page)
f010492f:	83 c4 10             	add    $0x10,%esp
f0104932:	85 c0                	test   %eax,%eax
f0104934:	74 33                	je     f0104969 <syscall+0x4a6>
			 {
				    return -E_INVAL;
			 } else if ((perm & PTE_W) && !(*pte &PTE_W))
f0104936:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010493a:	74 11                	je     f010494d <syscall+0x48a>
			 {
				    return -E_INVAL;
f010493c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			 pte_t* pte = NULL;
			 struct PageInfo* page = page_lookup (curenv -> env_pgdir, srcva, &pte);
			 if (!page)
			 {
				    return -E_INVAL;
			 } else if ((perm & PTE_W) && !(*pte &PTE_W))
f0104941:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104944:	f6 02 02             	testb  $0x2,(%edx)
f0104947:	0f 84 39 01 00 00    	je     f0104a86 <syscall+0x5c3>
			 {
				    return -E_INVAL;
			 }

			 a = page_insert (d_env -> env_pgdir, page, d_env -> env_ipc_dstva, perm);
f010494d:	8b 75 18             	mov    0x18(%ebp),%esi
f0104950:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104953:	56                   	push   %esi
f0104954:	ff 72 6c             	pushl  0x6c(%edx)
f0104957:	50                   	push   %eax
f0104958:	ff 72 60             	pushl  0x60(%edx)
f010495b:	e8 82 c9 ff ff       	call   f01012e2 <page_insert>
			 if (a < 0)
f0104960:	83 c4 10             	add    $0x10,%esp
f0104963:	85 c0                	test   %eax,%eax
f0104965:	79 18                	jns    f010497f <syscall+0x4bc>
f0104967:	eb 0a                	jmp    f0104973 <syscall+0x4b0>
	   {
			 pte_t* pte = NULL;
			 struct PageInfo* page = page_lookup (curenv -> env_pgdir, srcva, &pte);
			 if (!page)
			 {
				    return -E_INVAL;
f0104969:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010496e:	e9 13 01 00 00       	jmp    f0104a86 <syscall+0x5c3>
				    return -E_INVAL;
			 }

			 a = page_insert (d_env -> env_pgdir, page, d_env -> env_ipc_dstva, perm);
			 if (a < 0)
				    return a;
f0104973:	89 c3                	mov    %eax,%ebx
f0104975:	e9 0c 01 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	   // LAB 4: Your code here.
	   int a  = 0;
	   int r_perm = 0;
f010497a:	be 00 00 00 00       	mov    $0x0,%esi
				    return a;

			 r_perm = perm;
	   }

	   d_env->env_ipc_value = value;
f010497f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104982:	8b 45 10             	mov    0x10(%ebp),%eax
f0104985:	89 43 70             	mov    %eax,0x70(%ebx)
	   d_env->env_ipc_from = curenv->env_id;
f0104988:	e8 1d 12 00 00       	call   f0105baa <cpunum>
f010498d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104990:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104996:	8b 40 48             	mov    0x48(%eax),%eax
f0104999:	89 43 74             	mov    %eax,0x74(%ebx)
	   d_env->env_ipc_perm = r_perm;
f010499c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010499f:	89 70 78             	mov    %esi,0x78(%eax)
	   d_env->env_ipc_recving = false;
f01049a2:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	   d_env->env_status = ENV_RUNNABLE;
f01049a6:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	   return 0;
f01049ad:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049b2:	e9 cf 00 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   uintptr_t address = (uintptr_t) srcva;

	   a = envid2env (envid, &d_env, 0);
	   if (a < 0)
	   {
			 return a;
f01049b7:	89 c3                	mov    %eax,%ebx
f01049b9:	e9 c8 00 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   } else if (!(d_env -> env_ipc_recving))
	   {
			 return -E_IPC_NOT_RECV;
f01049be:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f01049c3:	e9 be 00 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   } else if ((address < UTOP) && (address % PGSIZE) != 0)
	   {	return -E_INVAL;
f01049c8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049cd:	e9 b4 00 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   } else if ((address < UTOP) && (perm & ~PTE_SYSCALL) != 0)
	   {
			 return -E_INVAL;
f01049d2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
				    return sys_page_unmap((envid_t) a1, (void *) a2);

			 case SYS_ipc_recv:
				    return sys_ipc_recv((void *)a1);
			 case SYS_ipc_try_send:
				    return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f01049d7:	e9 aa 00 00 00       	jmp    f0104a86 <syscall+0x5c3>
			 default:
				    return -E_INVAL;
f01049dc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049e1:	e9 a0 00 00 00       	jmp    f0104a86 <syscall+0x5c3>
				    return sys_page_map((envid_t) a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
			 case SYS_page_unmap:
				    return sys_page_unmap((envid_t) a1, (void *) a2);

			 case SYS_ipc_recv:
				    return sys_ipc_recv((void *)a1);
f01049e6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049eb:	e9 96 00 00 00       	jmp    f0104a86 <syscall+0x5c3>
	   if ((address < UTOP) && (address % PGSIZE) != 0)
	   {
			 return -E_INVAL;
	   }

	   curenv -> env_status = ENV_NOT_RUNNABLE;
f01049f0:	e8 b5 11 00 00       	call   f0105baa <cpunum>
f01049f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f8:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01049fe:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	   curenv -> env_ipc_recving = true;
f0104a05:	e8 a0 11 00 00       	call   f0105baa <cpunum>
f0104a0a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a0d:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104a13:	c6 40 68 01          	movb   $0x1,0x68(%eax)

	   if (address >= UTOP)
	   {
			 curenv -> env_tf.tf_regs.reg_eax = 0;
f0104a17:	e8 8e 11 00 00       	call   f0105baa <cpunum>
f0104a1c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a1f:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104a25:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
			 sched_yield();
f0104a2c:	e8 ca f9 ff ff       	call   f01043fb <sched_yield>
	   if ((address < UTOP) && (address % PGSIZE) != 0)
	   {
			 return -E_INVAL;
	   }

	   curenv -> env_status = ENV_NOT_RUNNABLE;
f0104a31:	e8 74 11 00 00       	call   f0105baa <cpunum>
f0104a36:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a39:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104a3f:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	   curenv -> env_ipc_recving = true;
f0104a46:	e8 5f 11 00 00       	call   f0105baa <cpunum>
f0104a4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a4e:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104a54:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	   {
			 curenv -> env_tf.tf_regs.reg_eax = 0;
			 sched_yield();
	   }

	   curenv -> env_ipc_dstva = dstva;
f0104a58:	e8 4d 11 00 00       	call   f0105baa <cpunum>
f0104a5d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a60:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104a69:	89 48 6c             	mov    %ecx,0x6c(%eax)
	   curenv -> env_tf.tf_regs.reg_eax = 0;
f0104a6c:	e8 39 11 00 00       	call   f0105baa <cpunum>
f0104a71:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a74:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104a7a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	   sched_yield();
f0104a81:	e8 75 f9 ff ff       	call   f01043fb <sched_yield>
			 case SYS_ipc_try_send:
				    return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
			 default:
				    return -E_INVAL;
	   }
}
f0104a86:	89 d8                	mov    %ebx,%eax
f0104a88:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104a8b:	5b                   	pop    %ebx
f0104a8c:	5e                   	pop    %esi
f0104a8d:	5f                   	pop    %edi
f0104a8e:	5d                   	pop    %ebp
f0104a8f:	c3                   	ret    

f0104a90 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
	   static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			 int type, uintptr_t addr)
{
f0104a90:	55                   	push   %ebp
f0104a91:	89 e5                	mov    %esp,%ebp
f0104a93:	57                   	push   %edi
f0104a94:	56                   	push   %esi
f0104a95:	53                   	push   %ebx
f0104a96:	83 ec 14             	sub    $0x14,%esp
f0104a99:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104a9c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104a9f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104aa2:	8b 7d 08             	mov    0x8(%ebp),%edi
	   int l = *region_left, r = *region_right, any_matches = 0;
f0104aa5:	8b 1a                	mov    (%edx),%ebx
f0104aa7:	8b 01                	mov    (%ecx),%eax
f0104aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104aac:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	   while (l <= r) {
f0104ab3:	eb 7f                	jmp    f0104b34 <stab_binsearch+0xa4>
			 int true_m = (l + r) / 2, m = true_m;
f0104ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104ab8:	01 d8                	add    %ebx,%eax
f0104aba:	89 c6                	mov    %eax,%esi
f0104abc:	c1 ee 1f             	shr    $0x1f,%esi
f0104abf:	01 c6                	add    %eax,%esi
f0104ac1:	d1 fe                	sar    %esi
f0104ac3:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104ac6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ac9:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104acc:	89 f0                	mov    %esi,%eax

			 // search for earliest stab with right type
			 while (m >= l && stabs[m].n_type != type)
f0104ace:	eb 03                	jmp    f0104ad3 <stab_binsearch+0x43>
				    m--;
f0104ad0:	83 e8 01             	sub    $0x1,%eax

	   while (l <= r) {
			 int true_m = (l + r) / 2, m = true_m;

			 // search for earliest stab with right type
			 while (m >= l && stabs[m].n_type != type)
f0104ad3:	39 c3                	cmp    %eax,%ebx
f0104ad5:	7f 0d                	jg     f0104ae4 <stab_binsearch+0x54>
f0104ad7:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104adb:	83 ea 0c             	sub    $0xc,%edx
f0104ade:	39 f9                	cmp    %edi,%ecx
f0104ae0:	75 ee                	jne    f0104ad0 <stab_binsearch+0x40>
f0104ae2:	eb 05                	jmp    f0104ae9 <stab_binsearch+0x59>
				    m--;
			 if (m < l) {	// no match in [l, m]
				    l = true_m + 1;
f0104ae4:	8d 5e 01             	lea    0x1(%esi),%ebx
				    continue;
f0104ae7:	eb 4b                	jmp    f0104b34 <stab_binsearch+0xa4>
			 }

			 // actual binary search
			 any_matches = 1;
			 if (stabs[m].n_value < addr) {
f0104ae9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104aec:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104aef:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104af3:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104af6:	76 11                	jbe    f0104b09 <stab_binsearch+0x79>
				    *region_left = m;
f0104af8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104afb:	89 03                	mov    %eax,(%ebx)
				    l = true_m + 1;
f0104afd:	8d 5e 01             	lea    0x1(%esi),%ebx
				    l = true_m + 1;
				    continue;
			 }

			 // actual binary search
			 any_matches = 1;
f0104b00:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b07:	eb 2b                	jmp    f0104b34 <stab_binsearch+0xa4>
			 if (stabs[m].n_value < addr) {
				    *region_left = m;
				    l = true_m + 1;
			 } else if (stabs[m].n_value > addr) {
f0104b09:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104b0c:	73 14                	jae    f0104b22 <stab_binsearch+0x92>
				    *region_right = m - 1;
f0104b0e:	83 e8 01             	sub    $0x1,%eax
f0104b11:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104b14:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b17:	89 06                	mov    %eax,(%esi)
				    l = true_m + 1;
				    continue;
			 }

			 // actual binary search
			 any_matches = 1;
f0104b19:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b20:	eb 12                	jmp    f0104b34 <stab_binsearch+0xa4>
				    *region_right = m - 1;
				    r = m - 1;
			 } else {
				    // exact match for 'addr', but continue loop to find
				    // *region_right
				    *region_left = m;
f0104b22:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b25:	89 06                	mov    %eax,(%esi)
				    l = m;
				    addr++;
f0104b27:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104b2b:	89 c3                	mov    %eax,%ebx
				    l = true_m + 1;
				    continue;
			 }

			 // actual binary search
			 any_matches = 1;
f0104b2d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			 int type, uintptr_t addr)
{
	   int l = *region_left, r = *region_right, any_matches = 0;

	   while (l <= r) {
f0104b34:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104b37:	0f 8e 78 ff ff ff    	jle    f0104ab5 <stab_binsearch+0x25>
				    l = m;
				    addr++;
			 }
	   }

	   if (!any_matches)
f0104b3d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104b41:	75 0f                	jne    f0104b52 <stab_binsearch+0xc2>
			 *region_right = *region_left - 1;
f0104b43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b46:	8b 00                	mov    (%eax),%eax
f0104b48:	83 e8 01             	sub    $0x1,%eax
f0104b4b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b4e:	89 06                	mov    %eax,(%esi)
f0104b50:	eb 2c                	jmp    f0104b7e <stab_binsearch+0xee>
	   else {
			 // find rightmost region containing 'addr'
			 for (l = *region_right;
f0104b52:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b55:	8b 00                	mov    (%eax),%eax
						  l > *region_left && stabs[l].n_type != type;
f0104b57:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b5a:	8b 0e                	mov    (%esi),%ecx
f0104b5c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b5f:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104b62:	8d 14 96             	lea    (%esi,%edx,4),%edx

	   if (!any_matches)
			 *region_right = *region_left - 1;
	   else {
			 // find rightmost region containing 'addr'
			 for (l = *region_right;
f0104b65:	eb 03                	jmp    f0104b6a <stab_binsearch+0xda>
						  l > *region_left && stabs[l].n_type != type;
						  l--)
f0104b67:	83 e8 01             	sub    $0x1,%eax

	   if (!any_matches)
			 *region_right = *region_left - 1;
	   else {
			 // find rightmost region containing 'addr'
			 for (l = *region_right;
f0104b6a:	39 c8                	cmp    %ecx,%eax
f0104b6c:	7e 0b                	jle    f0104b79 <stab_binsearch+0xe9>
						  l > *region_left && stabs[l].n_type != type;
f0104b6e:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104b72:	83 ea 0c             	sub    $0xc,%edx
f0104b75:	39 df                	cmp    %ebx,%edi
f0104b77:	75 ee                	jne    f0104b67 <stab_binsearch+0xd7>
						  l--)
				    /* do nothing */;
			 *region_left = l;
f0104b79:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b7c:	89 06                	mov    %eax,(%esi)
	   }
}
f0104b7e:	83 c4 14             	add    $0x14,%esp
f0104b81:	5b                   	pop    %ebx
f0104b82:	5e                   	pop    %esi
f0104b83:	5f                   	pop    %edi
f0104b84:	5d                   	pop    %ebp
f0104b85:	c3                   	ret    

f0104b86 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
	   int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104b86:	55                   	push   %ebp
f0104b87:	89 e5                	mov    %esp,%ebp
f0104b89:	57                   	push   %edi
f0104b8a:	56                   	push   %esi
f0104b8b:	53                   	push   %ebx
f0104b8c:	83 ec 2c             	sub    $0x2c,%esp
f0104b8f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104b92:	8b 75 0c             	mov    0xc(%ebp),%esi
	   const struct Stab *stabs, *stab_end;
	   const char *stabstr, *stabstr_end;
	   int lfile, rfile, lfun, rfun, lline, rline;

	   // Initialize *info
	   info->eip_file = "<unknown>";
f0104b95:	c7 06 18 7b 10 f0    	movl   $0xf0107b18,(%esi)
	   info->eip_line = 0;
f0104b9b:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	   info->eip_fn_name = "<unknown>";
f0104ba2:	c7 46 08 18 7b 10 f0 	movl   $0xf0107b18,0x8(%esi)
	   info->eip_fn_namelen = 9;
f0104ba9:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	   info->eip_fn_addr = addr;
f0104bb0:	89 7e 10             	mov    %edi,0x10(%esi)
	   info->eip_fn_narg = 0;
f0104bb3:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
f0104bba:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104bc0:	0f 87 a3 00 00 00    	ja     f0104c69 <debuginfo_eip+0xe3>

			 // Make sure this memory is valid.
			 // Return -1 if it is not.  Hint: Call user_mem_check.
			 // LAB 3: Your code here.

			 if (user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
f0104bc6:	e8 df 0f 00 00       	call   f0105baa <cpunum>
f0104bcb:	6a 04                	push   $0x4
f0104bcd:	6a 10                	push   $0x10
f0104bcf:	68 00 00 20 00       	push   $0x200000
f0104bd4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd7:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104bdd:	e8 4c e2 ff ff       	call   f0102e2e <user_mem_check>
f0104be2:	83 c4 10             	add    $0x10,%esp
f0104be5:	85 c0                	test   %eax,%eax
f0104be7:	0f 88 d4 01 00 00    	js     f0104dc1 <debuginfo_eip+0x23b>
				 return -1;

			 stabs = usd->stabs;
f0104bed:	a1 00 00 20 00       	mov    0x200000,%eax
f0104bf2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			 stab_end = usd->stab_end;
f0104bf5:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
			 stabstr = usd->stabstr;
f0104bfb:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104c01:	89 55 cc             	mov    %edx,-0x34(%ebp)
			 stabstr_end = usd->stabstr_end;
f0104c04:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104c09:	89 45 d0             	mov    %eax,-0x30(%ebp)

			 // Make sure the STABS and string table memory is valid.
			 // LAB 3: Your code here.

			 if ((user_mem_check (curenv, (void*) stabs, (uintptr_t)(stab_end - stabs), PTE_U) < 0) || (user_mem_check (curenv, (void*) stabstr, (uintptr_t)(stabstr_end - stabstr), PTE_U) < 0))
f0104c0c:	e8 99 0f 00 00       	call   f0105baa <cpunum>
f0104c11:	6a 04                	push   $0x4
f0104c13:	89 da                	mov    %ebx,%edx
f0104c15:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104c18:	29 ca                	sub    %ecx,%edx
f0104c1a:	c1 fa 02             	sar    $0x2,%edx
f0104c1d:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104c23:	52                   	push   %edx
f0104c24:	51                   	push   %ecx
f0104c25:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c28:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104c2e:	e8 fb e1 ff ff       	call   f0102e2e <user_mem_check>
f0104c33:	83 c4 10             	add    $0x10,%esp
f0104c36:	85 c0                	test   %eax,%eax
f0104c38:	0f 88 8a 01 00 00    	js     f0104dc8 <debuginfo_eip+0x242>
f0104c3e:	e8 67 0f 00 00       	call   f0105baa <cpunum>
f0104c43:	6a 04                	push   $0x4
f0104c45:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104c48:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104c4b:	29 ca                	sub    %ecx,%edx
f0104c4d:	52                   	push   %edx
f0104c4e:	51                   	push   %ecx
f0104c4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c52:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104c58:	e8 d1 e1 ff ff       	call   f0102e2e <user_mem_check>
f0104c5d:	83 c4 10             	add    $0x10,%esp
f0104c60:	85 c0                	test   %eax,%eax
f0104c62:	79 1f                	jns    f0104c83 <debuginfo_eip+0xfd>
f0104c64:	e9 66 01 00 00       	jmp    f0104dcf <debuginfo_eip+0x249>
	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
			 stabs = __STAB_BEGIN__;
			 stab_end = __STAB_END__;
			 stabstr = __STABSTR_BEGIN__;
			 stabstr_end = __STABSTR_END__;
f0104c69:	c7 45 d0 bc 5a 11 f0 	movl   $0xf0115abc,-0x30(%ebp)

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
			 stabs = __STAB_BEGIN__;
			 stab_end = __STAB_END__;
			 stabstr = __STABSTR_BEGIN__;
f0104c70:	c7 45 cc 81 23 11 f0 	movl   $0xf0112381,-0x34(%ebp)
	   info->eip_fn_narg = 0;

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
			 stabs = __STAB_BEGIN__;
			 stab_end = __STAB_END__;
f0104c77:	bb 80 23 11 f0       	mov    $0xf0112380,%ebx
	   info->eip_fn_addr = addr;
	   info->eip_fn_narg = 0;

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
			 stabs = __STAB_BEGIN__;
f0104c7c:	c7 45 d4 f4 7f 10 f0 	movl   $0xf0107ff4,-0x2c(%ebp)
			 if ((user_mem_check (curenv, (void*) stabs, (uintptr_t)(stab_end - stabs), PTE_U) < 0) || (user_mem_check (curenv, (void*) stabstr, (uintptr_t)(stabstr_end - stabstr), PTE_U) < 0))
				 return -1;
   }

	   // String table validity checks
	   if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104c83:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104c86:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0104c89:	0f 83 47 01 00 00    	jae    f0104dd6 <debuginfo_eip+0x250>
f0104c8f:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104c93:	0f 85 44 01 00 00    	jne    f0104ddd <debuginfo_eip+0x257>
	   // 'eip'.  First, we find the basic source file containing 'eip'.
	   // Then, we look in that source file for the function.  Then we look
	   // for the line number.

	   // Search the entire set of stabs for the source file (type N_SO).
	   lfile = 0;
f0104c99:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   rfile = (stab_end - stabs) - 1;
f0104ca0:	2b 5d d4             	sub    -0x2c(%ebp),%ebx
f0104ca3:	c1 fb 02             	sar    $0x2,%ebx
f0104ca6:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0104cac:	83 e8 01             	sub    $0x1,%eax
f0104caf:	89 45 e0             	mov    %eax,-0x20(%ebp)
	   stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104cb2:	83 ec 08             	sub    $0x8,%esp
f0104cb5:	57                   	push   %edi
f0104cb6:	6a 64                	push   $0x64
f0104cb8:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104cbb:	89 d1                	mov    %edx,%ecx
f0104cbd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104cc0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104cc3:	89 d8                	mov    %ebx,%eax
f0104cc5:	e8 c6 fd ff ff       	call   f0104a90 <stab_binsearch>
	   if (lfile == 0)
f0104cca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ccd:	83 c4 10             	add    $0x10,%esp
f0104cd0:	85 c0                	test   %eax,%eax
f0104cd2:	0f 84 0c 01 00 00    	je     f0104de4 <debuginfo_eip+0x25e>
			 return -1;

	   // Search within that file's stabs for the function definition
	   // (N_FUN).
	   lfun = lfile;
f0104cd8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	   rfun = rfile;
f0104cdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cde:	89 45 d8             	mov    %eax,-0x28(%ebp)
	   stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104ce1:	83 ec 08             	sub    $0x8,%esp
f0104ce4:	57                   	push   %edi
f0104ce5:	6a 24                	push   $0x24
f0104ce7:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104cea:	89 d1                	mov    %edx,%ecx
f0104cec:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104cef:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104cf2:	89 d8                	mov    %ebx,%eax
f0104cf4:	e8 97 fd ff ff       	call   f0104a90 <stab_binsearch>

	   if (lfun <= rfun) {
f0104cf9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104cfc:	83 c4 10             	add    $0x10,%esp
f0104cff:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104d02:	7f 24                	jg     f0104d28 <debuginfo_eip+0x1a2>
			 // stabs[lfun] points to the function name
			 // in the string table, but check bounds just in case.
			 if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104d04:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d07:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104d0a:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0104d0d:	8b 02                	mov    (%edx),%eax
f0104d0f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104d12:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104d15:	29 f9                	sub    %edi,%ecx
f0104d17:	39 c8                	cmp    %ecx,%eax
f0104d19:	73 05                	jae    f0104d20 <debuginfo_eip+0x19a>
				    info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104d1b:	01 f8                	add    %edi,%eax
f0104d1d:	89 46 08             	mov    %eax,0x8(%esi)
			 info->eip_fn_addr = stabs[lfun].n_value;
f0104d20:	8b 42 08             	mov    0x8(%edx),%eax
f0104d23:	89 46 10             	mov    %eax,0x10(%esi)
f0104d26:	eb 06                	jmp    f0104d2e <debuginfo_eip+0x1a8>
			 lline = lfun;
			 rline = rfun;
	   } else {
			 // Couldn't find function stab!  Maybe we're in an assembly
			 // file.  Search the whole file for the line number.
			 info->eip_fn_addr = addr;
f0104d28:	89 7e 10             	mov    %edi,0x10(%esi)
			 lline = lfile;
f0104d2b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			 rline = rfile;
	   }
	   // Ignore stuff after the colon.
	   info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104d2e:	83 ec 08             	sub    $0x8,%esp
f0104d31:	6a 3a                	push   $0x3a
f0104d33:	ff 76 08             	pushl  0x8(%esi)
f0104d36:	e8 30 08 00 00       	call   f010556b <strfind>
f0104d3b:	2b 46 08             	sub    0x8(%esi),%eax
f0104d3e:	89 46 0c             	mov    %eax,0xc(%esi)
	   // Search backwards from the line number for the relevant filename
	   // stab.
	   // We can't just use the "lfile" stab because inlined functions
	   // can interpolate code from a different file!
	   // Such included source files use the N_SOL stab type.
	   while (lline >= lfile
f0104d41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d44:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d47:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104d4a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104d4d:	83 c4 10             	add    $0x10,%esp
f0104d50:	eb 06                	jmp    f0104d58 <debuginfo_eip+0x1d2>
				    && stabs[lline].n_type != N_SOL
				    && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
			 lline--;
f0104d52:	83 eb 01             	sub    $0x1,%ebx
f0104d55:	83 e8 0c             	sub    $0xc,%eax
	   // Search backwards from the line number for the relevant filename
	   // stab.
	   // We can't just use the "lfile" stab because inlined functions
	   // can interpolate code from a different file!
	   // Such included source files use the N_SOL stab type.
	   while (lline >= lfile
f0104d58:	39 fb                	cmp    %edi,%ebx
f0104d5a:	7c 2d                	jl     f0104d89 <debuginfo_eip+0x203>
				    && stabs[lline].n_type != N_SOL
f0104d5c:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104d60:	80 fa 84             	cmp    $0x84,%dl
f0104d63:	74 0b                	je     f0104d70 <debuginfo_eip+0x1ea>
				    && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104d65:	80 fa 64             	cmp    $0x64,%dl
f0104d68:	75 e8                	jne    f0104d52 <debuginfo_eip+0x1cc>
f0104d6a:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104d6e:	74 e2                	je     f0104d52 <debuginfo_eip+0x1cc>
			 lline--;
	   if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104d70:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d73:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104d76:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104d79:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104d7c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104d7f:	29 f8                	sub    %edi,%eax
f0104d81:	39 c2                	cmp    %eax,%edx
f0104d83:	73 04                	jae    f0104d89 <debuginfo_eip+0x203>
			 info->eip_file = stabstr + stabs[lline].n_strx;
f0104d85:	01 fa                	add    %edi,%edx
f0104d87:	89 16                	mov    %edx,(%esi)


	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
f0104d89:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104d8c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
			 for (lline = lfun + 1;
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
				    info->eip_fn_narg++;

	   return 0;
f0104d8f:	b8 00 00 00 00       	mov    $0x0,%eax
			 info->eip_file = stabstr + stabs[lline].n_strx;


	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
f0104d94:	39 cb                	cmp    %ecx,%ebx
f0104d96:	7d 58                	jge    f0104df0 <debuginfo_eip+0x26a>
			 for (lline = lfun + 1;
f0104d98:	8d 53 01             	lea    0x1(%ebx),%edx
f0104d9b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d9e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104da1:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104da4:	eb 07                	jmp    f0104dad <debuginfo_eip+0x227>
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
				    info->eip_fn_narg++;
f0104da6:	83 46 14 01          	addl   $0x1,0x14(%esi)
	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
			 for (lline = lfun + 1;
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
f0104daa:	83 c2 01             	add    $0x1,%edx


	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
			 for (lline = lfun + 1;
f0104dad:	39 ca                	cmp    %ecx,%edx
f0104daf:	74 3a                	je     f0104deb <debuginfo_eip+0x265>
f0104db1:	83 c0 0c             	add    $0xc,%eax
						  lline < rfun && stabs[lline].n_type == N_PSYM;
f0104db4:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104db8:	74 ec                	je     f0104da6 <debuginfo_eip+0x220>
						  lline++)
				    info->eip_fn_narg++;

	   return 0;
f0104dba:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dbf:	eb 2f                	jmp    f0104df0 <debuginfo_eip+0x26a>
			 // Make sure this memory is valid.
			 // Return -1 if it is not.  Hint: Call user_mem_check.
			 // LAB 3: Your code here.

			 if (user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
				 return -1;
f0104dc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104dc6:	eb 28                	jmp    f0104df0 <debuginfo_eip+0x26a>

			 // Make sure the STABS and string table memory is valid.
			 // LAB 3: Your code here.

			 if ((user_mem_check (curenv, (void*) stabs, (uintptr_t)(stab_end - stabs), PTE_U) < 0) || (user_mem_check (curenv, (void*) stabstr, (uintptr_t)(stabstr_end - stabstr), PTE_U) < 0))
				 return -1;
f0104dc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104dcd:	eb 21                	jmp    f0104df0 <debuginfo_eip+0x26a>
f0104dcf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104dd4:	eb 1a                	jmp    f0104df0 <debuginfo_eip+0x26a>
   }

	   // String table validity checks
	   if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
			 return -1;
f0104dd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ddb:	eb 13                	jmp    f0104df0 <debuginfo_eip+0x26a>
f0104ddd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104de2:	eb 0c                	jmp    f0104df0 <debuginfo_eip+0x26a>
	   // Search the entire set of stabs for the source file (type N_SO).
	   lfile = 0;
	   rfile = (stab_end - stabs) - 1;
	   stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	   if (lfile == 0)
			 return -1;
f0104de4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104de9:	eb 05                	jmp    f0104df0 <debuginfo_eip+0x26a>
			 for (lline = lfun + 1;
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
				    info->eip_fn_narg++;

	   return 0;
f0104deb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104df3:	5b                   	pop    %ebx
f0104df4:	5e                   	pop    %esi
f0104df5:	5f                   	pop    %edi
f0104df6:	5d                   	pop    %ebp
f0104df7:	c3                   	ret    

f0104df8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104df8:	55                   	push   %ebp
f0104df9:	89 e5                	mov    %esp,%ebp
f0104dfb:	57                   	push   %edi
f0104dfc:	56                   	push   %esi
f0104dfd:	53                   	push   %ebx
f0104dfe:	83 ec 1c             	sub    $0x1c,%esp
f0104e01:	89 c7                	mov    %eax,%edi
f0104e03:	89 d6                	mov    %edx,%esi
f0104e05:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e08:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e0b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e0e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104e11:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e14:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e19:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104e1c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104e1f:	39 d3                	cmp    %edx,%ebx
f0104e21:	72 05                	jb     f0104e28 <printnum+0x30>
f0104e23:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104e26:	77 45                	ja     f0104e6d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104e28:	83 ec 0c             	sub    $0xc,%esp
f0104e2b:	ff 75 18             	pushl  0x18(%ebp)
f0104e2e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e31:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104e34:	53                   	push   %ebx
f0104e35:	ff 75 10             	pushl  0x10(%ebp)
f0104e38:	83 ec 08             	sub    $0x8,%esp
f0104e3b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e3e:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e41:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e44:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e47:	e8 64 11 00 00       	call   f0105fb0 <__udivdi3>
f0104e4c:	83 c4 18             	add    $0x18,%esp
f0104e4f:	52                   	push   %edx
f0104e50:	50                   	push   %eax
f0104e51:	89 f2                	mov    %esi,%edx
f0104e53:	89 f8                	mov    %edi,%eax
f0104e55:	e8 9e ff ff ff       	call   f0104df8 <printnum>
f0104e5a:	83 c4 20             	add    $0x20,%esp
f0104e5d:	eb 18                	jmp    f0104e77 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104e5f:	83 ec 08             	sub    $0x8,%esp
f0104e62:	56                   	push   %esi
f0104e63:	ff 75 18             	pushl  0x18(%ebp)
f0104e66:	ff d7                	call   *%edi
f0104e68:	83 c4 10             	add    $0x10,%esp
f0104e6b:	eb 03                	jmp    f0104e70 <printnum+0x78>
f0104e6d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104e70:	83 eb 01             	sub    $0x1,%ebx
f0104e73:	85 db                	test   %ebx,%ebx
f0104e75:	7f e8                	jg     f0104e5f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104e77:	83 ec 08             	sub    $0x8,%esp
f0104e7a:	56                   	push   %esi
f0104e7b:	83 ec 04             	sub    $0x4,%esp
f0104e7e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e81:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e84:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e87:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e8a:	e8 51 12 00 00       	call   f01060e0 <__umoddi3>
f0104e8f:	83 c4 14             	add    $0x14,%esp
f0104e92:	0f be 80 22 7b 10 f0 	movsbl -0xfef84de(%eax),%eax
f0104e99:	50                   	push   %eax
f0104e9a:	ff d7                	call   *%edi
}
f0104e9c:	83 c4 10             	add    $0x10,%esp
f0104e9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ea2:	5b                   	pop    %ebx
f0104ea3:	5e                   	pop    %esi
f0104ea4:	5f                   	pop    %edi
f0104ea5:	5d                   	pop    %ebp
f0104ea6:	c3                   	ret    

f0104ea7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104ea7:	55                   	push   %ebp
f0104ea8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104eaa:	83 fa 01             	cmp    $0x1,%edx
f0104ead:	7e 0e                	jle    f0104ebd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104eaf:	8b 10                	mov    (%eax),%edx
f0104eb1:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104eb4:	89 08                	mov    %ecx,(%eax)
f0104eb6:	8b 02                	mov    (%edx),%eax
f0104eb8:	8b 52 04             	mov    0x4(%edx),%edx
f0104ebb:	eb 22                	jmp    f0104edf <getuint+0x38>
	else if (lflag)
f0104ebd:	85 d2                	test   %edx,%edx
f0104ebf:	74 10                	je     f0104ed1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104ec1:	8b 10                	mov    (%eax),%edx
f0104ec3:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104ec6:	89 08                	mov    %ecx,(%eax)
f0104ec8:	8b 02                	mov    (%edx),%eax
f0104eca:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ecf:	eb 0e                	jmp    f0104edf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104ed1:	8b 10                	mov    (%eax),%edx
f0104ed3:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104ed6:	89 08                	mov    %ecx,(%eax)
f0104ed8:	8b 02                	mov    (%edx),%eax
f0104eda:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104edf:	5d                   	pop    %ebp
f0104ee0:	c3                   	ret    

f0104ee1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104ee1:	55                   	push   %ebp
f0104ee2:	89 e5                	mov    %esp,%ebp
f0104ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104ee7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104eeb:	8b 10                	mov    (%eax),%edx
f0104eed:	3b 50 04             	cmp    0x4(%eax),%edx
f0104ef0:	73 0a                	jae    f0104efc <sprintputch+0x1b>
		*b->buf++ = ch;
f0104ef2:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104ef5:	89 08                	mov    %ecx,(%eax)
f0104ef7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104efa:	88 02                	mov    %al,(%edx)
}
f0104efc:	5d                   	pop    %ebp
f0104efd:	c3                   	ret    

f0104efe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104efe:	55                   	push   %ebp
f0104eff:	89 e5                	mov    %esp,%ebp
f0104f01:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104f04:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104f07:	50                   	push   %eax
f0104f08:	ff 75 10             	pushl  0x10(%ebp)
f0104f0b:	ff 75 0c             	pushl  0xc(%ebp)
f0104f0e:	ff 75 08             	pushl  0x8(%ebp)
f0104f11:	e8 05 00 00 00       	call   f0104f1b <vprintfmt>
	va_end(ap);
}
f0104f16:	83 c4 10             	add    $0x10,%esp
f0104f19:	c9                   	leave  
f0104f1a:	c3                   	ret    

f0104f1b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104f1b:	55                   	push   %ebp
f0104f1c:	89 e5                	mov    %esp,%ebp
f0104f1e:	57                   	push   %edi
f0104f1f:	56                   	push   %esi
f0104f20:	53                   	push   %ebx
f0104f21:	83 ec 2c             	sub    $0x2c,%esp
f0104f24:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f2a:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f2d:	eb 12                	jmp    f0104f41 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104f2f:	85 c0                	test   %eax,%eax
f0104f31:	0f 84 89 03 00 00    	je     f01052c0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104f37:	83 ec 08             	sub    $0x8,%esp
f0104f3a:	53                   	push   %ebx
f0104f3b:	50                   	push   %eax
f0104f3c:	ff d6                	call   *%esi
f0104f3e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104f41:	83 c7 01             	add    $0x1,%edi
f0104f44:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104f48:	83 f8 25             	cmp    $0x25,%eax
f0104f4b:	75 e2                	jne    f0104f2f <vprintfmt+0x14>
f0104f4d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104f51:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104f58:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104f5f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104f66:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f6b:	eb 07                	jmp    f0104f74 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104f70:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f74:	8d 47 01             	lea    0x1(%edi),%eax
f0104f77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104f7a:	0f b6 07             	movzbl (%edi),%eax
f0104f7d:	0f b6 c8             	movzbl %al,%ecx
f0104f80:	83 e8 23             	sub    $0x23,%eax
f0104f83:	3c 55                	cmp    $0x55,%al
f0104f85:	0f 87 1a 03 00 00    	ja     f01052a5 <vprintfmt+0x38a>
f0104f8b:	0f b6 c0             	movzbl %al,%eax
f0104f8e:	ff 24 85 e0 7b 10 f0 	jmp    *-0xfef8420(,%eax,4)
f0104f95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104f98:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104f9c:	eb d6                	jmp    f0104f74 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fa1:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fa6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104fa9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104fac:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104fb0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104fb3:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104fb6:	83 fa 09             	cmp    $0x9,%edx
f0104fb9:	77 39                	ja     f0104ff4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104fbb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104fbe:	eb e9                	jmp    f0104fa9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104fc0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fc3:	8d 48 04             	lea    0x4(%eax),%ecx
f0104fc6:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104fc9:	8b 00                	mov    (%eax),%eax
f0104fcb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104fd1:	eb 27                	jmp    f0104ffa <vprintfmt+0xdf>
f0104fd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fd6:	85 c0                	test   %eax,%eax
f0104fd8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104fdd:	0f 49 c8             	cmovns %eax,%ecx
f0104fe0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fe3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fe6:	eb 8c                	jmp    f0104f74 <vprintfmt+0x59>
f0104fe8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104feb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104ff2:	eb 80                	jmp    f0104f74 <vprintfmt+0x59>
f0104ff4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ff7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104ffa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ffe:	0f 89 70 ff ff ff    	jns    f0104f74 <vprintfmt+0x59>
				width = precision, precision = -1;
f0105004:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105007:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010500a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105011:	e9 5e ff ff ff       	jmp    f0104f74 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105016:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105019:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010501c:	e9 53 ff ff ff       	jmp    f0104f74 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105021:	8b 45 14             	mov    0x14(%ebp),%eax
f0105024:	8d 50 04             	lea    0x4(%eax),%edx
f0105027:	89 55 14             	mov    %edx,0x14(%ebp)
f010502a:	83 ec 08             	sub    $0x8,%esp
f010502d:	53                   	push   %ebx
f010502e:	ff 30                	pushl  (%eax)
f0105030:	ff d6                	call   *%esi
			break;
f0105032:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105035:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105038:	e9 04 ff ff ff       	jmp    f0104f41 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010503d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105040:	8d 50 04             	lea    0x4(%eax),%edx
f0105043:	89 55 14             	mov    %edx,0x14(%ebp)
f0105046:	8b 00                	mov    (%eax),%eax
f0105048:	99                   	cltd   
f0105049:	31 d0                	xor    %edx,%eax
f010504b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010504d:	83 f8 08             	cmp    $0x8,%eax
f0105050:	7f 0b                	jg     f010505d <vprintfmt+0x142>
f0105052:	8b 14 85 40 7d 10 f0 	mov    -0xfef82c0(,%eax,4),%edx
f0105059:	85 d2                	test   %edx,%edx
f010505b:	75 18                	jne    f0105075 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f010505d:	50                   	push   %eax
f010505e:	68 3a 7b 10 f0       	push   $0xf0107b3a
f0105063:	53                   	push   %ebx
f0105064:	56                   	push   %esi
f0105065:	e8 94 fe ff ff       	call   f0104efe <printfmt>
f010506a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010506d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105070:	e9 cc fe ff ff       	jmp    f0104f41 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0105075:	52                   	push   %edx
f0105076:	68 2a 68 10 f0       	push   $0xf010682a
f010507b:	53                   	push   %ebx
f010507c:	56                   	push   %esi
f010507d:	e8 7c fe ff ff       	call   f0104efe <printfmt>
f0105082:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105085:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105088:	e9 b4 fe ff ff       	jmp    f0104f41 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010508d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105090:	8d 50 04             	lea    0x4(%eax),%edx
f0105093:	89 55 14             	mov    %edx,0x14(%ebp)
f0105096:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105098:	85 ff                	test   %edi,%edi
f010509a:	b8 33 7b 10 f0       	mov    $0xf0107b33,%eax
f010509f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01050a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01050a6:	0f 8e 94 00 00 00    	jle    f0105140 <vprintfmt+0x225>
f01050ac:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01050b0:	0f 84 98 00 00 00    	je     f010514e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f01050b6:	83 ec 08             	sub    $0x8,%esp
f01050b9:	ff 75 d0             	pushl  -0x30(%ebp)
f01050bc:	57                   	push   %edi
f01050bd:	e8 5f 03 00 00       	call   f0105421 <strnlen>
f01050c2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01050c5:	29 c1                	sub    %eax,%ecx
f01050c7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01050ca:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01050cd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01050d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01050d4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01050d7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01050d9:	eb 0f                	jmp    f01050ea <vprintfmt+0x1cf>
					putch(padc, putdat);
f01050db:	83 ec 08             	sub    $0x8,%esp
f01050de:	53                   	push   %ebx
f01050df:	ff 75 e0             	pushl  -0x20(%ebp)
f01050e2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01050e4:	83 ef 01             	sub    $0x1,%edi
f01050e7:	83 c4 10             	add    $0x10,%esp
f01050ea:	85 ff                	test   %edi,%edi
f01050ec:	7f ed                	jg     f01050db <vprintfmt+0x1c0>
f01050ee:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01050f1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01050f4:	85 c9                	test   %ecx,%ecx
f01050f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01050fb:	0f 49 c1             	cmovns %ecx,%eax
f01050fe:	29 c1                	sub    %eax,%ecx
f0105100:	89 75 08             	mov    %esi,0x8(%ebp)
f0105103:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105106:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105109:	89 cb                	mov    %ecx,%ebx
f010510b:	eb 4d                	jmp    f010515a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010510d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105111:	74 1b                	je     f010512e <vprintfmt+0x213>
f0105113:	0f be c0             	movsbl %al,%eax
f0105116:	83 e8 20             	sub    $0x20,%eax
f0105119:	83 f8 5e             	cmp    $0x5e,%eax
f010511c:	76 10                	jbe    f010512e <vprintfmt+0x213>
					putch('?', putdat);
f010511e:	83 ec 08             	sub    $0x8,%esp
f0105121:	ff 75 0c             	pushl  0xc(%ebp)
f0105124:	6a 3f                	push   $0x3f
f0105126:	ff 55 08             	call   *0x8(%ebp)
f0105129:	83 c4 10             	add    $0x10,%esp
f010512c:	eb 0d                	jmp    f010513b <vprintfmt+0x220>
				else
					putch(ch, putdat);
f010512e:	83 ec 08             	sub    $0x8,%esp
f0105131:	ff 75 0c             	pushl  0xc(%ebp)
f0105134:	52                   	push   %edx
f0105135:	ff 55 08             	call   *0x8(%ebp)
f0105138:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010513b:	83 eb 01             	sub    $0x1,%ebx
f010513e:	eb 1a                	jmp    f010515a <vprintfmt+0x23f>
f0105140:	89 75 08             	mov    %esi,0x8(%ebp)
f0105143:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105146:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105149:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010514c:	eb 0c                	jmp    f010515a <vprintfmt+0x23f>
f010514e:	89 75 08             	mov    %esi,0x8(%ebp)
f0105151:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105154:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105157:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010515a:	83 c7 01             	add    $0x1,%edi
f010515d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105161:	0f be d0             	movsbl %al,%edx
f0105164:	85 d2                	test   %edx,%edx
f0105166:	74 23                	je     f010518b <vprintfmt+0x270>
f0105168:	85 f6                	test   %esi,%esi
f010516a:	78 a1                	js     f010510d <vprintfmt+0x1f2>
f010516c:	83 ee 01             	sub    $0x1,%esi
f010516f:	79 9c                	jns    f010510d <vprintfmt+0x1f2>
f0105171:	89 df                	mov    %ebx,%edi
f0105173:	8b 75 08             	mov    0x8(%ebp),%esi
f0105176:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105179:	eb 18                	jmp    f0105193 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010517b:	83 ec 08             	sub    $0x8,%esp
f010517e:	53                   	push   %ebx
f010517f:	6a 20                	push   $0x20
f0105181:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105183:	83 ef 01             	sub    $0x1,%edi
f0105186:	83 c4 10             	add    $0x10,%esp
f0105189:	eb 08                	jmp    f0105193 <vprintfmt+0x278>
f010518b:	89 df                	mov    %ebx,%edi
f010518d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105190:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105193:	85 ff                	test   %edi,%edi
f0105195:	7f e4                	jg     f010517b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105197:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010519a:	e9 a2 fd ff ff       	jmp    f0104f41 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010519f:	83 fa 01             	cmp    $0x1,%edx
f01051a2:	7e 16                	jle    f01051ba <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01051a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01051a7:	8d 50 08             	lea    0x8(%eax),%edx
f01051aa:	89 55 14             	mov    %edx,0x14(%ebp)
f01051ad:	8b 50 04             	mov    0x4(%eax),%edx
f01051b0:	8b 00                	mov    (%eax),%eax
f01051b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01051b8:	eb 32                	jmp    f01051ec <vprintfmt+0x2d1>
	else if (lflag)
f01051ba:	85 d2                	test   %edx,%edx
f01051bc:	74 18                	je     f01051d6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01051be:	8b 45 14             	mov    0x14(%ebp),%eax
f01051c1:	8d 50 04             	lea    0x4(%eax),%edx
f01051c4:	89 55 14             	mov    %edx,0x14(%ebp)
f01051c7:	8b 00                	mov    (%eax),%eax
f01051c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051cc:	89 c1                	mov    %eax,%ecx
f01051ce:	c1 f9 1f             	sar    $0x1f,%ecx
f01051d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01051d4:	eb 16                	jmp    f01051ec <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01051d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01051d9:	8d 50 04             	lea    0x4(%eax),%edx
f01051dc:	89 55 14             	mov    %edx,0x14(%ebp)
f01051df:	8b 00                	mov    (%eax),%eax
f01051e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051e4:	89 c1                	mov    %eax,%ecx
f01051e6:	c1 f9 1f             	sar    $0x1f,%ecx
f01051e9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01051ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01051ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01051f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01051f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01051fb:	79 74                	jns    f0105271 <vprintfmt+0x356>
				putch('-', putdat);
f01051fd:	83 ec 08             	sub    $0x8,%esp
f0105200:	53                   	push   %ebx
f0105201:	6a 2d                	push   $0x2d
f0105203:	ff d6                	call   *%esi
				num = -(long long) num;
f0105205:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105208:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010520b:	f7 d8                	neg    %eax
f010520d:	83 d2 00             	adc    $0x0,%edx
f0105210:	f7 da                	neg    %edx
f0105212:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105215:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010521a:	eb 55                	jmp    f0105271 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010521c:	8d 45 14             	lea    0x14(%ebp),%eax
f010521f:	e8 83 fc ff ff       	call   f0104ea7 <getuint>
			base = 10;
f0105224:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105229:	eb 46                	jmp    f0105271 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f010522b:	8d 45 14             	lea    0x14(%ebp),%eax
f010522e:	e8 74 fc ff ff       	call   f0104ea7 <getuint>
			base = 8;
f0105233:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105238:	eb 37                	jmp    f0105271 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
f010523a:	83 ec 08             	sub    $0x8,%esp
f010523d:	53                   	push   %ebx
f010523e:	6a 30                	push   $0x30
f0105240:	ff d6                	call   *%esi
			putch('x', putdat);
f0105242:	83 c4 08             	add    $0x8,%esp
f0105245:	53                   	push   %ebx
f0105246:	6a 78                	push   $0x78
f0105248:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010524a:	8b 45 14             	mov    0x14(%ebp),%eax
f010524d:	8d 50 04             	lea    0x4(%eax),%edx
f0105250:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105253:	8b 00                	mov    (%eax),%eax
f0105255:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010525a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010525d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105262:	eb 0d                	jmp    f0105271 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105264:	8d 45 14             	lea    0x14(%ebp),%eax
f0105267:	e8 3b fc ff ff       	call   f0104ea7 <getuint>
			base = 16;
f010526c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105271:	83 ec 0c             	sub    $0xc,%esp
f0105274:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105278:	57                   	push   %edi
f0105279:	ff 75 e0             	pushl  -0x20(%ebp)
f010527c:	51                   	push   %ecx
f010527d:	52                   	push   %edx
f010527e:	50                   	push   %eax
f010527f:	89 da                	mov    %ebx,%edx
f0105281:	89 f0                	mov    %esi,%eax
f0105283:	e8 70 fb ff ff       	call   f0104df8 <printnum>
			break;
f0105288:	83 c4 20             	add    $0x20,%esp
f010528b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010528e:	e9 ae fc ff ff       	jmp    f0104f41 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105293:	83 ec 08             	sub    $0x8,%esp
f0105296:	53                   	push   %ebx
f0105297:	51                   	push   %ecx
f0105298:	ff d6                	call   *%esi
			break;
f010529a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010529d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01052a0:	e9 9c fc ff ff       	jmp    f0104f41 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01052a5:	83 ec 08             	sub    $0x8,%esp
f01052a8:	53                   	push   %ebx
f01052a9:	6a 25                	push   $0x25
f01052ab:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01052ad:	83 c4 10             	add    $0x10,%esp
f01052b0:	eb 03                	jmp    f01052b5 <vprintfmt+0x39a>
f01052b2:	83 ef 01             	sub    $0x1,%edi
f01052b5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01052b9:	75 f7                	jne    f01052b2 <vprintfmt+0x397>
f01052bb:	e9 81 fc ff ff       	jmp    f0104f41 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01052c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01052c3:	5b                   	pop    %ebx
f01052c4:	5e                   	pop    %esi
f01052c5:	5f                   	pop    %edi
f01052c6:	5d                   	pop    %ebp
f01052c7:	c3                   	ret    

f01052c8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01052c8:	55                   	push   %ebp
f01052c9:	89 e5                	mov    %esp,%ebp
f01052cb:	83 ec 18             	sub    $0x18,%esp
f01052ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01052d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01052d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01052d7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01052db:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01052de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01052e5:	85 c0                	test   %eax,%eax
f01052e7:	74 26                	je     f010530f <vsnprintf+0x47>
f01052e9:	85 d2                	test   %edx,%edx
f01052eb:	7e 22                	jle    f010530f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01052ed:	ff 75 14             	pushl  0x14(%ebp)
f01052f0:	ff 75 10             	pushl  0x10(%ebp)
f01052f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01052f6:	50                   	push   %eax
f01052f7:	68 e1 4e 10 f0       	push   $0xf0104ee1
f01052fc:	e8 1a fc ff ff       	call   f0104f1b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105301:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105304:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105307:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010530a:	83 c4 10             	add    $0x10,%esp
f010530d:	eb 05                	jmp    f0105314 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010530f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105314:	c9                   	leave  
f0105315:	c3                   	ret    

f0105316 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105316:	55                   	push   %ebp
f0105317:	89 e5                	mov    %esp,%ebp
f0105319:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010531c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010531f:	50                   	push   %eax
f0105320:	ff 75 10             	pushl  0x10(%ebp)
f0105323:	ff 75 0c             	pushl  0xc(%ebp)
f0105326:	ff 75 08             	pushl  0x8(%ebp)
f0105329:	e8 9a ff ff ff       	call   f01052c8 <vsnprintf>
	va_end(ap);

	return rc;
}
f010532e:	c9                   	leave  
f010532f:	c3                   	ret    

f0105330 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105330:	55                   	push   %ebp
f0105331:	89 e5                	mov    %esp,%ebp
f0105333:	57                   	push   %edi
f0105334:	56                   	push   %esi
f0105335:	53                   	push   %ebx
f0105336:	83 ec 0c             	sub    $0xc,%esp
f0105339:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010533c:	85 c0                	test   %eax,%eax
f010533e:	74 11                	je     f0105351 <readline+0x21>
		cprintf("%s", prompt);
f0105340:	83 ec 08             	sub    $0x8,%esp
f0105343:	50                   	push   %eax
f0105344:	68 2a 68 10 f0       	push   $0xf010682a
f0105349:	e8 06 e5 ff ff       	call   f0103854 <cprintf>
f010534e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105351:	83 ec 0c             	sub    $0xc,%esp
f0105354:	6a 00                	push   $0x0
f0105356:	e8 13 b4 ff ff       	call   f010076e <iscons>
f010535b:	89 c7                	mov    %eax,%edi
f010535d:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105360:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105365:	e8 f3 b3 ff ff       	call   f010075d <getchar>
f010536a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010536c:	85 c0                	test   %eax,%eax
f010536e:	79 18                	jns    f0105388 <readline+0x58>
			cprintf("read error: %e\n", c);
f0105370:	83 ec 08             	sub    $0x8,%esp
f0105373:	50                   	push   %eax
f0105374:	68 64 7d 10 f0       	push   $0xf0107d64
f0105379:	e8 d6 e4 ff ff       	call   f0103854 <cprintf>
			return NULL;
f010537e:	83 c4 10             	add    $0x10,%esp
f0105381:	b8 00 00 00 00       	mov    $0x0,%eax
f0105386:	eb 79                	jmp    f0105401 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105388:	83 f8 08             	cmp    $0x8,%eax
f010538b:	0f 94 c2             	sete   %dl
f010538e:	83 f8 7f             	cmp    $0x7f,%eax
f0105391:	0f 94 c0             	sete   %al
f0105394:	08 c2                	or     %al,%dl
f0105396:	74 1a                	je     f01053b2 <readline+0x82>
f0105398:	85 f6                	test   %esi,%esi
f010539a:	7e 16                	jle    f01053b2 <readline+0x82>
			if (echoing)
f010539c:	85 ff                	test   %edi,%edi
f010539e:	74 0d                	je     f01053ad <readline+0x7d>
				cputchar('\b');
f01053a0:	83 ec 0c             	sub    $0xc,%esp
f01053a3:	6a 08                	push   $0x8
f01053a5:	e8 a3 b3 ff ff       	call   f010074d <cputchar>
f01053aa:	83 c4 10             	add    $0x10,%esp
			i--;
f01053ad:	83 ee 01             	sub    $0x1,%esi
f01053b0:	eb b3                	jmp    f0105365 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01053b2:	83 fb 1f             	cmp    $0x1f,%ebx
f01053b5:	7e 23                	jle    f01053da <readline+0xaa>
f01053b7:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01053bd:	7f 1b                	jg     f01053da <readline+0xaa>
			if (echoing)
f01053bf:	85 ff                	test   %edi,%edi
f01053c1:	74 0c                	je     f01053cf <readline+0x9f>
				cputchar(c);
f01053c3:	83 ec 0c             	sub    $0xc,%esp
f01053c6:	53                   	push   %ebx
f01053c7:	e8 81 b3 ff ff       	call   f010074d <cputchar>
f01053cc:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01053cf:	88 9e 80 fa 22 f0    	mov    %bl,-0xfdd0580(%esi)
f01053d5:	8d 76 01             	lea    0x1(%esi),%esi
f01053d8:	eb 8b                	jmp    f0105365 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01053da:	83 fb 0a             	cmp    $0xa,%ebx
f01053dd:	74 05                	je     f01053e4 <readline+0xb4>
f01053df:	83 fb 0d             	cmp    $0xd,%ebx
f01053e2:	75 81                	jne    f0105365 <readline+0x35>
			if (echoing)
f01053e4:	85 ff                	test   %edi,%edi
f01053e6:	74 0d                	je     f01053f5 <readline+0xc5>
				cputchar('\n');
f01053e8:	83 ec 0c             	sub    $0xc,%esp
f01053eb:	6a 0a                	push   $0xa
f01053ed:	e8 5b b3 ff ff       	call   f010074d <cputchar>
f01053f2:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01053f5:	c6 86 80 fa 22 f0 00 	movb   $0x0,-0xfdd0580(%esi)
			return buf;
f01053fc:	b8 80 fa 22 f0       	mov    $0xf022fa80,%eax
		}
	}
}
f0105401:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105404:	5b                   	pop    %ebx
f0105405:	5e                   	pop    %esi
f0105406:	5f                   	pop    %edi
f0105407:	5d                   	pop    %ebp
f0105408:	c3                   	ret    

f0105409 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105409:	55                   	push   %ebp
f010540a:	89 e5                	mov    %esp,%ebp
f010540c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010540f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105414:	eb 03                	jmp    f0105419 <strlen+0x10>
		n++;
f0105416:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105419:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010541d:	75 f7                	jne    f0105416 <strlen+0xd>
		n++;
	return n;
}
f010541f:	5d                   	pop    %ebp
f0105420:	c3                   	ret    

f0105421 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105421:	55                   	push   %ebp
f0105422:	89 e5                	mov    %esp,%ebp
f0105424:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105427:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010542a:	ba 00 00 00 00       	mov    $0x0,%edx
f010542f:	eb 03                	jmp    f0105434 <strnlen+0x13>
		n++;
f0105431:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105434:	39 c2                	cmp    %eax,%edx
f0105436:	74 08                	je     f0105440 <strnlen+0x1f>
f0105438:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010543c:	75 f3                	jne    f0105431 <strnlen+0x10>
f010543e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105440:	5d                   	pop    %ebp
f0105441:	c3                   	ret    

f0105442 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105442:	55                   	push   %ebp
f0105443:	89 e5                	mov    %esp,%ebp
f0105445:	53                   	push   %ebx
f0105446:	8b 45 08             	mov    0x8(%ebp),%eax
f0105449:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010544c:	89 c2                	mov    %eax,%edx
f010544e:	83 c2 01             	add    $0x1,%edx
f0105451:	83 c1 01             	add    $0x1,%ecx
f0105454:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105458:	88 5a ff             	mov    %bl,-0x1(%edx)
f010545b:	84 db                	test   %bl,%bl
f010545d:	75 ef                	jne    f010544e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010545f:	5b                   	pop    %ebx
f0105460:	5d                   	pop    %ebp
f0105461:	c3                   	ret    

f0105462 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105462:	55                   	push   %ebp
f0105463:	89 e5                	mov    %esp,%ebp
f0105465:	53                   	push   %ebx
f0105466:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105469:	53                   	push   %ebx
f010546a:	e8 9a ff ff ff       	call   f0105409 <strlen>
f010546f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105472:	ff 75 0c             	pushl  0xc(%ebp)
f0105475:	01 d8                	add    %ebx,%eax
f0105477:	50                   	push   %eax
f0105478:	e8 c5 ff ff ff       	call   f0105442 <strcpy>
	return dst;
}
f010547d:	89 d8                	mov    %ebx,%eax
f010547f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105482:	c9                   	leave  
f0105483:	c3                   	ret    

f0105484 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105484:	55                   	push   %ebp
f0105485:	89 e5                	mov    %esp,%ebp
f0105487:	56                   	push   %esi
f0105488:	53                   	push   %ebx
f0105489:	8b 75 08             	mov    0x8(%ebp),%esi
f010548c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010548f:	89 f3                	mov    %esi,%ebx
f0105491:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105494:	89 f2                	mov    %esi,%edx
f0105496:	eb 0f                	jmp    f01054a7 <strncpy+0x23>
		*dst++ = *src;
f0105498:	83 c2 01             	add    $0x1,%edx
f010549b:	0f b6 01             	movzbl (%ecx),%eax
f010549e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01054a1:	80 39 01             	cmpb   $0x1,(%ecx)
f01054a4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01054a7:	39 da                	cmp    %ebx,%edx
f01054a9:	75 ed                	jne    f0105498 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01054ab:	89 f0                	mov    %esi,%eax
f01054ad:	5b                   	pop    %ebx
f01054ae:	5e                   	pop    %esi
f01054af:	5d                   	pop    %ebp
f01054b0:	c3                   	ret    

f01054b1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01054b1:	55                   	push   %ebp
f01054b2:	89 e5                	mov    %esp,%ebp
f01054b4:	56                   	push   %esi
f01054b5:	53                   	push   %ebx
f01054b6:	8b 75 08             	mov    0x8(%ebp),%esi
f01054b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01054bc:	8b 55 10             	mov    0x10(%ebp),%edx
f01054bf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01054c1:	85 d2                	test   %edx,%edx
f01054c3:	74 21                	je     f01054e6 <strlcpy+0x35>
f01054c5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01054c9:	89 f2                	mov    %esi,%edx
f01054cb:	eb 09                	jmp    f01054d6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01054cd:	83 c2 01             	add    $0x1,%edx
f01054d0:	83 c1 01             	add    $0x1,%ecx
f01054d3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01054d6:	39 c2                	cmp    %eax,%edx
f01054d8:	74 09                	je     f01054e3 <strlcpy+0x32>
f01054da:	0f b6 19             	movzbl (%ecx),%ebx
f01054dd:	84 db                	test   %bl,%bl
f01054df:	75 ec                	jne    f01054cd <strlcpy+0x1c>
f01054e1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01054e3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01054e6:	29 f0                	sub    %esi,%eax
}
f01054e8:	5b                   	pop    %ebx
f01054e9:	5e                   	pop    %esi
f01054ea:	5d                   	pop    %ebp
f01054eb:	c3                   	ret    

f01054ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01054ec:	55                   	push   %ebp
f01054ed:	89 e5                	mov    %esp,%ebp
f01054ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01054f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01054f5:	eb 06                	jmp    f01054fd <strcmp+0x11>
		p++, q++;
f01054f7:	83 c1 01             	add    $0x1,%ecx
f01054fa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01054fd:	0f b6 01             	movzbl (%ecx),%eax
f0105500:	84 c0                	test   %al,%al
f0105502:	74 04                	je     f0105508 <strcmp+0x1c>
f0105504:	3a 02                	cmp    (%edx),%al
f0105506:	74 ef                	je     f01054f7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105508:	0f b6 c0             	movzbl %al,%eax
f010550b:	0f b6 12             	movzbl (%edx),%edx
f010550e:	29 d0                	sub    %edx,%eax
}
f0105510:	5d                   	pop    %ebp
f0105511:	c3                   	ret    

f0105512 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105512:	55                   	push   %ebp
f0105513:	89 e5                	mov    %esp,%ebp
f0105515:	53                   	push   %ebx
f0105516:	8b 45 08             	mov    0x8(%ebp),%eax
f0105519:	8b 55 0c             	mov    0xc(%ebp),%edx
f010551c:	89 c3                	mov    %eax,%ebx
f010551e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105521:	eb 06                	jmp    f0105529 <strncmp+0x17>
		n--, p++, q++;
f0105523:	83 c0 01             	add    $0x1,%eax
f0105526:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105529:	39 d8                	cmp    %ebx,%eax
f010552b:	74 15                	je     f0105542 <strncmp+0x30>
f010552d:	0f b6 08             	movzbl (%eax),%ecx
f0105530:	84 c9                	test   %cl,%cl
f0105532:	74 04                	je     f0105538 <strncmp+0x26>
f0105534:	3a 0a                	cmp    (%edx),%cl
f0105536:	74 eb                	je     f0105523 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105538:	0f b6 00             	movzbl (%eax),%eax
f010553b:	0f b6 12             	movzbl (%edx),%edx
f010553e:	29 d0                	sub    %edx,%eax
f0105540:	eb 05                	jmp    f0105547 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105542:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105547:	5b                   	pop    %ebx
f0105548:	5d                   	pop    %ebp
f0105549:	c3                   	ret    

f010554a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010554a:	55                   	push   %ebp
f010554b:	89 e5                	mov    %esp,%ebp
f010554d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105550:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105554:	eb 07                	jmp    f010555d <strchr+0x13>
		if (*s == c)
f0105556:	38 ca                	cmp    %cl,%dl
f0105558:	74 0f                	je     f0105569 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010555a:	83 c0 01             	add    $0x1,%eax
f010555d:	0f b6 10             	movzbl (%eax),%edx
f0105560:	84 d2                	test   %dl,%dl
f0105562:	75 f2                	jne    f0105556 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105564:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105569:	5d                   	pop    %ebp
f010556a:	c3                   	ret    

f010556b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010556b:	55                   	push   %ebp
f010556c:	89 e5                	mov    %esp,%ebp
f010556e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105571:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105575:	eb 03                	jmp    f010557a <strfind+0xf>
f0105577:	83 c0 01             	add    $0x1,%eax
f010557a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010557d:	38 ca                	cmp    %cl,%dl
f010557f:	74 04                	je     f0105585 <strfind+0x1a>
f0105581:	84 d2                	test   %dl,%dl
f0105583:	75 f2                	jne    f0105577 <strfind+0xc>
			break;
	return (char *) s;
}
f0105585:	5d                   	pop    %ebp
f0105586:	c3                   	ret    

f0105587 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105587:	55                   	push   %ebp
f0105588:	89 e5                	mov    %esp,%ebp
f010558a:	57                   	push   %edi
f010558b:	56                   	push   %esi
f010558c:	53                   	push   %ebx
f010558d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105590:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105593:	85 c9                	test   %ecx,%ecx
f0105595:	74 36                	je     f01055cd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105597:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010559d:	75 28                	jne    f01055c7 <memset+0x40>
f010559f:	f6 c1 03             	test   $0x3,%cl
f01055a2:	75 23                	jne    f01055c7 <memset+0x40>
		c &= 0xFF;
f01055a4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01055a8:	89 d3                	mov    %edx,%ebx
f01055aa:	c1 e3 08             	shl    $0x8,%ebx
f01055ad:	89 d6                	mov    %edx,%esi
f01055af:	c1 e6 18             	shl    $0x18,%esi
f01055b2:	89 d0                	mov    %edx,%eax
f01055b4:	c1 e0 10             	shl    $0x10,%eax
f01055b7:	09 f0                	or     %esi,%eax
f01055b9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01055bb:	89 d8                	mov    %ebx,%eax
f01055bd:	09 d0                	or     %edx,%eax
f01055bf:	c1 e9 02             	shr    $0x2,%ecx
f01055c2:	fc                   	cld    
f01055c3:	f3 ab                	rep stos %eax,%es:(%edi)
f01055c5:	eb 06                	jmp    f01055cd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01055c7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01055ca:	fc                   	cld    
f01055cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01055cd:	89 f8                	mov    %edi,%eax
f01055cf:	5b                   	pop    %ebx
f01055d0:	5e                   	pop    %esi
f01055d1:	5f                   	pop    %edi
f01055d2:	5d                   	pop    %ebp
f01055d3:	c3                   	ret    

f01055d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01055d4:	55                   	push   %ebp
f01055d5:	89 e5                	mov    %esp,%ebp
f01055d7:	57                   	push   %edi
f01055d8:	56                   	push   %esi
f01055d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01055dc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01055df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01055e2:	39 c6                	cmp    %eax,%esi
f01055e4:	73 35                	jae    f010561b <memmove+0x47>
f01055e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01055e9:	39 d0                	cmp    %edx,%eax
f01055eb:	73 2e                	jae    f010561b <memmove+0x47>
		s += n;
		d += n;
f01055ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01055f0:	89 d6                	mov    %edx,%esi
f01055f2:	09 fe                	or     %edi,%esi
f01055f4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01055fa:	75 13                	jne    f010560f <memmove+0x3b>
f01055fc:	f6 c1 03             	test   $0x3,%cl
f01055ff:	75 0e                	jne    f010560f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105601:	83 ef 04             	sub    $0x4,%edi
f0105604:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105607:	c1 e9 02             	shr    $0x2,%ecx
f010560a:	fd                   	std    
f010560b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010560d:	eb 09                	jmp    f0105618 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010560f:	83 ef 01             	sub    $0x1,%edi
f0105612:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105615:	fd                   	std    
f0105616:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105618:	fc                   	cld    
f0105619:	eb 1d                	jmp    f0105638 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010561b:	89 f2                	mov    %esi,%edx
f010561d:	09 c2                	or     %eax,%edx
f010561f:	f6 c2 03             	test   $0x3,%dl
f0105622:	75 0f                	jne    f0105633 <memmove+0x5f>
f0105624:	f6 c1 03             	test   $0x3,%cl
f0105627:	75 0a                	jne    f0105633 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105629:	c1 e9 02             	shr    $0x2,%ecx
f010562c:	89 c7                	mov    %eax,%edi
f010562e:	fc                   	cld    
f010562f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105631:	eb 05                	jmp    f0105638 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105633:	89 c7                	mov    %eax,%edi
f0105635:	fc                   	cld    
f0105636:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105638:	5e                   	pop    %esi
f0105639:	5f                   	pop    %edi
f010563a:	5d                   	pop    %ebp
f010563b:	c3                   	ret    

f010563c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010563c:	55                   	push   %ebp
f010563d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010563f:	ff 75 10             	pushl  0x10(%ebp)
f0105642:	ff 75 0c             	pushl  0xc(%ebp)
f0105645:	ff 75 08             	pushl  0x8(%ebp)
f0105648:	e8 87 ff ff ff       	call   f01055d4 <memmove>
}
f010564d:	c9                   	leave  
f010564e:	c3                   	ret    

f010564f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010564f:	55                   	push   %ebp
f0105650:	89 e5                	mov    %esp,%ebp
f0105652:	56                   	push   %esi
f0105653:	53                   	push   %ebx
f0105654:	8b 45 08             	mov    0x8(%ebp),%eax
f0105657:	8b 55 0c             	mov    0xc(%ebp),%edx
f010565a:	89 c6                	mov    %eax,%esi
f010565c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010565f:	eb 1a                	jmp    f010567b <memcmp+0x2c>
		if (*s1 != *s2)
f0105661:	0f b6 08             	movzbl (%eax),%ecx
f0105664:	0f b6 1a             	movzbl (%edx),%ebx
f0105667:	38 d9                	cmp    %bl,%cl
f0105669:	74 0a                	je     f0105675 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010566b:	0f b6 c1             	movzbl %cl,%eax
f010566e:	0f b6 db             	movzbl %bl,%ebx
f0105671:	29 d8                	sub    %ebx,%eax
f0105673:	eb 0f                	jmp    f0105684 <memcmp+0x35>
		s1++, s2++;
f0105675:	83 c0 01             	add    $0x1,%eax
f0105678:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010567b:	39 f0                	cmp    %esi,%eax
f010567d:	75 e2                	jne    f0105661 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010567f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105684:	5b                   	pop    %ebx
f0105685:	5e                   	pop    %esi
f0105686:	5d                   	pop    %ebp
f0105687:	c3                   	ret    

f0105688 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105688:	55                   	push   %ebp
f0105689:	89 e5                	mov    %esp,%ebp
f010568b:	53                   	push   %ebx
f010568c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010568f:	89 c1                	mov    %eax,%ecx
f0105691:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105694:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105698:	eb 0a                	jmp    f01056a4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010569a:	0f b6 10             	movzbl (%eax),%edx
f010569d:	39 da                	cmp    %ebx,%edx
f010569f:	74 07                	je     f01056a8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01056a1:	83 c0 01             	add    $0x1,%eax
f01056a4:	39 c8                	cmp    %ecx,%eax
f01056a6:	72 f2                	jb     f010569a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01056a8:	5b                   	pop    %ebx
f01056a9:	5d                   	pop    %ebp
f01056aa:	c3                   	ret    

f01056ab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01056ab:	55                   	push   %ebp
f01056ac:	89 e5                	mov    %esp,%ebp
f01056ae:	57                   	push   %edi
f01056af:	56                   	push   %esi
f01056b0:	53                   	push   %ebx
f01056b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01056b7:	eb 03                	jmp    f01056bc <strtol+0x11>
		s++;
f01056b9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01056bc:	0f b6 01             	movzbl (%ecx),%eax
f01056bf:	3c 20                	cmp    $0x20,%al
f01056c1:	74 f6                	je     f01056b9 <strtol+0xe>
f01056c3:	3c 09                	cmp    $0x9,%al
f01056c5:	74 f2                	je     f01056b9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01056c7:	3c 2b                	cmp    $0x2b,%al
f01056c9:	75 0a                	jne    f01056d5 <strtol+0x2a>
		s++;
f01056cb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01056ce:	bf 00 00 00 00       	mov    $0x0,%edi
f01056d3:	eb 11                	jmp    f01056e6 <strtol+0x3b>
f01056d5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01056da:	3c 2d                	cmp    $0x2d,%al
f01056dc:	75 08                	jne    f01056e6 <strtol+0x3b>
		s++, neg = 1;
f01056de:	83 c1 01             	add    $0x1,%ecx
f01056e1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01056e6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01056ec:	75 15                	jne    f0105703 <strtol+0x58>
f01056ee:	80 39 30             	cmpb   $0x30,(%ecx)
f01056f1:	75 10                	jne    f0105703 <strtol+0x58>
f01056f3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01056f7:	75 7c                	jne    f0105775 <strtol+0xca>
		s += 2, base = 16;
f01056f9:	83 c1 02             	add    $0x2,%ecx
f01056fc:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105701:	eb 16                	jmp    f0105719 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105703:	85 db                	test   %ebx,%ebx
f0105705:	75 12                	jne    f0105719 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105707:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010570c:	80 39 30             	cmpb   $0x30,(%ecx)
f010570f:	75 08                	jne    f0105719 <strtol+0x6e>
		s++, base = 8;
f0105711:	83 c1 01             	add    $0x1,%ecx
f0105714:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105719:	b8 00 00 00 00       	mov    $0x0,%eax
f010571e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105721:	0f b6 11             	movzbl (%ecx),%edx
f0105724:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105727:	89 f3                	mov    %esi,%ebx
f0105729:	80 fb 09             	cmp    $0x9,%bl
f010572c:	77 08                	ja     f0105736 <strtol+0x8b>
			dig = *s - '0';
f010572e:	0f be d2             	movsbl %dl,%edx
f0105731:	83 ea 30             	sub    $0x30,%edx
f0105734:	eb 22                	jmp    f0105758 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105736:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105739:	89 f3                	mov    %esi,%ebx
f010573b:	80 fb 19             	cmp    $0x19,%bl
f010573e:	77 08                	ja     f0105748 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105740:	0f be d2             	movsbl %dl,%edx
f0105743:	83 ea 57             	sub    $0x57,%edx
f0105746:	eb 10                	jmp    f0105758 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105748:	8d 72 bf             	lea    -0x41(%edx),%esi
f010574b:	89 f3                	mov    %esi,%ebx
f010574d:	80 fb 19             	cmp    $0x19,%bl
f0105750:	77 16                	ja     f0105768 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105752:	0f be d2             	movsbl %dl,%edx
f0105755:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105758:	3b 55 10             	cmp    0x10(%ebp),%edx
f010575b:	7d 0b                	jge    f0105768 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010575d:	83 c1 01             	add    $0x1,%ecx
f0105760:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105764:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105766:	eb b9                	jmp    f0105721 <strtol+0x76>

	if (endptr)
f0105768:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010576c:	74 0d                	je     f010577b <strtol+0xd0>
		*endptr = (char *) s;
f010576e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105771:	89 0e                	mov    %ecx,(%esi)
f0105773:	eb 06                	jmp    f010577b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105775:	85 db                	test   %ebx,%ebx
f0105777:	74 98                	je     f0105711 <strtol+0x66>
f0105779:	eb 9e                	jmp    f0105719 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010577b:	89 c2                	mov    %eax,%edx
f010577d:	f7 da                	neg    %edx
f010577f:	85 ff                	test   %edi,%edi
f0105781:	0f 45 c2             	cmovne %edx,%eax
}
f0105784:	5b                   	pop    %ebx
f0105785:	5e                   	pop    %esi
f0105786:	5f                   	pop    %edi
f0105787:	5d                   	pop    %ebp
f0105788:	c3                   	ret    
f0105789:	66 90                	xchg   %ax,%ax
f010578b:	90                   	nop

f010578c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010578c:	fa                   	cli    

	xorw    %ax, %ax
f010578d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010578f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105791:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105793:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105795:	0f 01 16             	lgdtl  (%esi)
f0105798:	74 70                	je     f010580a <mpsearch1+0x3>
	movl    %cr0, %eax
f010579a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010579d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01057a1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01057a4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01057aa:	08 00                	or     %al,(%eax)

f01057ac <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01057ac:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01057b0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01057b2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01057b4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01057b6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01057ba:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01057bc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01057be:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f01057c3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01057c6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01057c9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01057ce:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01057d1:	8b 25 84 fe 22 f0    	mov    0xf022fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01057d7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01057dc:	b8 9c 01 10 f0       	mov    $0xf010019c,%eax
	call    *%eax
f01057e1:	ff d0                	call   *%eax

f01057e3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01057e3:	eb fe                	jmp    f01057e3 <spin>
f01057e5:	8d 76 00             	lea    0x0(%esi),%esi

f01057e8 <gdt>:
	...
f01057f0:	ff                   	(bad)  
f01057f1:	ff 00                	incl   (%eax)
f01057f3:	00 00                	add    %al,(%eax)
f01057f5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01057fc:	00                   	.byte 0x0
f01057fd:	92                   	xchg   %eax,%edx
f01057fe:	cf                   	iret   
	...

f0105800 <gdtdesc>:
f0105800:	17                   	pop    %ss
f0105801:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105806 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105806:	90                   	nop

f0105807 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105807:	55                   	push   %ebp
f0105808:	89 e5                	mov    %esp,%ebp
f010580a:	57                   	push   %edi
f010580b:	56                   	push   %esi
f010580c:	53                   	push   %ebx
f010580d:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105810:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f0105816:	89 c3                	mov    %eax,%ebx
f0105818:	c1 eb 0c             	shr    $0xc,%ebx
f010581b:	39 cb                	cmp    %ecx,%ebx
f010581d:	72 12                	jb     f0105831 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010581f:	50                   	push   %eax
f0105820:	68 64 62 10 f0       	push   $0xf0106264
f0105825:	6a 57                	push   $0x57
f0105827:	68 01 7f 10 f0       	push   $0xf0107f01
f010582c:	e8 0f a8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105831:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105837:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105839:	89 c2                	mov    %eax,%edx
f010583b:	c1 ea 0c             	shr    $0xc,%edx
f010583e:	39 ca                	cmp    %ecx,%edx
f0105840:	72 12                	jb     f0105854 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105842:	50                   	push   %eax
f0105843:	68 64 62 10 f0       	push   $0xf0106264
f0105848:	6a 57                	push   $0x57
f010584a:	68 01 7f 10 f0       	push   $0xf0107f01
f010584f:	e8 ec a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105854:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010585a:	eb 2f                	jmp    f010588b <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010585c:	83 ec 04             	sub    $0x4,%esp
f010585f:	6a 04                	push   $0x4
f0105861:	68 11 7f 10 f0       	push   $0xf0107f11
f0105866:	53                   	push   %ebx
f0105867:	e8 e3 fd ff ff       	call   f010564f <memcmp>
f010586c:	83 c4 10             	add    $0x10,%esp
f010586f:	85 c0                	test   %eax,%eax
f0105871:	75 15                	jne    f0105888 <mpsearch1+0x81>
f0105873:	89 da                	mov    %ebx,%edx
f0105875:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105878:	0f b6 0a             	movzbl (%edx),%ecx
f010587b:	01 c8                	add    %ecx,%eax
f010587d:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105880:	39 d7                	cmp    %edx,%edi
f0105882:	75 f4                	jne    f0105878 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105884:	84 c0                	test   %al,%al
f0105886:	74 0e                	je     f0105896 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105888:	83 c3 10             	add    $0x10,%ebx
f010588b:	39 f3                	cmp    %esi,%ebx
f010588d:	72 cd                	jb     f010585c <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010588f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105894:	eb 02                	jmp    f0105898 <mpsearch1+0x91>
f0105896:	89 d8                	mov    %ebx,%eax
}
f0105898:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010589b:	5b                   	pop    %ebx
f010589c:	5e                   	pop    %esi
f010589d:	5f                   	pop    %edi
f010589e:	5d                   	pop    %ebp
f010589f:	c3                   	ret    

f01058a0 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01058a0:	55                   	push   %ebp
f01058a1:	89 e5                	mov    %esp,%ebp
f01058a3:	57                   	push   %edi
f01058a4:	56                   	push   %esi
f01058a5:	53                   	push   %ebx
f01058a6:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01058a9:	c7 05 c0 03 23 f0 20 	movl   $0xf0230020,0xf02303c0
f01058b0:	00 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01058b3:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f01058ba:	75 16                	jne    f01058d2 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01058bc:	68 00 04 00 00       	push   $0x400
f01058c1:	68 64 62 10 f0       	push   $0xf0106264
f01058c6:	6a 6f                	push   $0x6f
f01058c8:	68 01 7f 10 f0       	push   $0xf0107f01
f01058cd:	e8 6e a7 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01058d2:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01058d9:	85 c0                	test   %eax,%eax
f01058db:	74 16                	je     f01058f3 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01058dd:	c1 e0 04             	shl    $0x4,%eax
f01058e0:	ba 00 04 00 00       	mov    $0x400,%edx
f01058e5:	e8 1d ff ff ff       	call   f0105807 <mpsearch1>
f01058ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058ed:	85 c0                	test   %eax,%eax
f01058ef:	75 3c                	jne    f010592d <mp_init+0x8d>
f01058f1:	eb 20                	jmp    f0105913 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f01058f3:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01058fa:	c1 e0 0a             	shl    $0xa,%eax
f01058fd:	2d 00 04 00 00       	sub    $0x400,%eax
f0105902:	ba 00 04 00 00       	mov    $0x400,%edx
f0105907:	e8 fb fe ff ff       	call   f0105807 <mpsearch1>
f010590c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010590f:	85 c0                	test   %eax,%eax
f0105911:	75 1a                	jne    f010592d <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105913:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105918:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010591d:	e8 e5 fe ff ff       	call   f0105807 <mpsearch1>
f0105922:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105925:	85 c0                	test   %eax,%eax
f0105927:	0f 84 5d 02 00 00    	je     f0105b8a <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010592d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105930:	8b 70 04             	mov    0x4(%eax),%esi
f0105933:	85 f6                	test   %esi,%esi
f0105935:	74 06                	je     f010593d <mp_init+0x9d>
f0105937:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010593b:	74 15                	je     f0105952 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f010593d:	83 ec 0c             	sub    $0xc,%esp
f0105940:	68 74 7d 10 f0       	push   $0xf0107d74
f0105945:	e8 0a df ff ff       	call   f0103854 <cprintf>
f010594a:	83 c4 10             	add    $0x10,%esp
f010594d:	e9 38 02 00 00       	jmp    f0105b8a <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105952:	89 f0                	mov    %esi,%eax
f0105954:	c1 e8 0c             	shr    $0xc,%eax
f0105957:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f010595d:	72 15                	jb     f0105974 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010595f:	56                   	push   %esi
f0105960:	68 64 62 10 f0       	push   $0xf0106264
f0105965:	68 90 00 00 00       	push   $0x90
f010596a:	68 01 7f 10 f0       	push   $0xf0107f01
f010596f:	e8 cc a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105974:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010597a:	83 ec 04             	sub    $0x4,%esp
f010597d:	6a 04                	push   $0x4
f010597f:	68 16 7f 10 f0       	push   $0xf0107f16
f0105984:	53                   	push   %ebx
f0105985:	e8 c5 fc ff ff       	call   f010564f <memcmp>
f010598a:	83 c4 10             	add    $0x10,%esp
f010598d:	85 c0                	test   %eax,%eax
f010598f:	74 15                	je     f01059a6 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105991:	83 ec 0c             	sub    $0xc,%esp
f0105994:	68 a4 7d 10 f0       	push   $0xf0107da4
f0105999:	e8 b6 de ff ff       	call   f0103854 <cprintf>
f010599e:	83 c4 10             	add    $0x10,%esp
f01059a1:	e9 e4 01 00 00       	jmp    f0105b8a <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01059a6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01059aa:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01059ae:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01059b1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01059b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01059bb:	eb 0d                	jmp    f01059ca <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01059bd:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01059c4:	f0 
f01059c5:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01059c7:	83 c0 01             	add    $0x1,%eax
f01059ca:	39 c7                	cmp    %eax,%edi
f01059cc:	75 ef                	jne    f01059bd <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01059ce:	84 d2                	test   %dl,%dl
f01059d0:	74 15                	je     f01059e7 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01059d2:	83 ec 0c             	sub    $0xc,%esp
f01059d5:	68 d8 7d 10 f0       	push   $0xf0107dd8
f01059da:	e8 75 de ff ff       	call   f0103854 <cprintf>
f01059df:	83 c4 10             	add    $0x10,%esp
f01059e2:	e9 a3 01 00 00       	jmp    f0105b8a <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01059e7:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01059eb:	3c 01                	cmp    $0x1,%al
f01059ed:	74 1d                	je     f0105a0c <mp_init+0x16c>
f01059ef:	3c 04                	cmp    $0x4,%al
f01059f1:	74 19                	je     f0105a0c <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01059f3:	83 ec 08             	sub    $0x8,%esp
f01059f6:	0f b6 c0             	movzbl %al,%eax
f01059f9:	50                   	push   %eax
f01059fa:	68 fc 7d 10 f0       	push   $0xf0107dfc
f01059ff:	e8 50 de ff ff       	call   f0103854 <cprintf>
f0105a04:	83 c4 10             	add    $0x10,%esp
f0105a07:	e9 7e 01 00 00       	jmp    f0105b8a <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a0c:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105a10:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a14:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105a19:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105a1e:	01 ce                	add    %ecx,%esi
f0105a20:	eb 0d                	jmp    f0105a2f <mp_init+0x18f>
f0105a22:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105a29:	f0 
f0105a2a:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a2c:	83 c0 01             	add    $0x1,%eax
f0105a2f:	39 c7                	cmp    %eax,%edi
f0105a31:	75 ef                	jne    f0105a22 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a33:	89 d0                	mov    %edx,%eax
f0105a35:	02 43 2a             	add    0x2a(%ebx),%al
f0105a38:	74 15                	je     f0105a4f <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105a3a:	83 ec 0c             	sub    $0xc,%esp
f0105a3d:	68 1c 7e 10 f0       	push   $0xf0107e1c
f0105a42:	e8 0d de ff ff       	call   f0103854 <cprintf>
f0105a47:	83 c4 10             	add    $0x10,%esp
f0105a4a:	e9 3b 01 00 00       	jmp    f0105b8a <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105a4f:	85 db                	test   %ebx,%ebx
f0105a51:	0f 84 33 01 00 00    	je     f0105b8a <mp_init+0x2ea>
		return;
	ismp = 1;
f0105a57:	c7 05 00 00 23 f0 01 	movl   $0x1,0xf0230000
f0105a5e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105a61:	8b 43 24             	mov    0x24(%ebx),%eax
f0105a64:	a3 00 10 27 f0       	mov    %eax,0xf0271000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105a69:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105a6c:	be 00 00 00 00       	mov    $0x0,%esi
f0105a71:	e9 85 00 00 00       	jmp    f0105afb <mp_init+0x25b>
		switch (*p) {
f0105a76:	0f b6 07             	movzbl (%edi),%eax
f0105a79:	84 c0                	test   %al,%al
f0105a7b:	74 06                	je     f0105a83 <mp_init+0x1e3>
f0105a7d:	3c 04                	cmp    $0x4,%al
f0105a7f:	77 55                	ja     f0105ad6 <mp_init+0x236>
f0105a81:	eb 4e                	jmp    f0105ad1 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105a83:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105a87:	74 11                	je     f0105a9a <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105a89:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f0105a90:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105a95:	a3 c0 03 23 f0       	mov    %eax,0xf02303c0
			if (ncpu < NCPU) {
f0105a9a:	a1 c4 03 23 f0       	mov    0xf02303c4,%eax
f0105a9f:	83 f8 07             	cmp    $0x7,%eax
f0105aa2:	7f 13                	jg     f0105ab7 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105aa4:	6b d0 74             	imul   $0x74,%eax,%edx
f0105aa7:	88 82 20 00 23 f0    	mov    %al,-0xfdcffe0(%edx)
				ncpu++;
f0105aad:	83 c0 01             	add    $0x1,%eax
f0105ab0:	a3 c4 03 23 f0       	mov    %eax,0xf02303c4
f0105ab5:	eb 15                	jmp    f0105acc <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105ab7:	83 ec 08             	sub    $0x8,%esp
f0105aba:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105abe:	50                   	push   %eax
f0105abf:	68 4c 7e 10 f0       	push   $0xf0107e4c
f0105ac4:	e8 8b dd ff ff       	call   f0103854 <cprintf>
f0105ac9:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105acc:	83 c7 14             	add    $0x14,%edi
			continue;
f0105acf:	eb 27                	jmp    f0105af8 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105ad1:	83 c7 08             	add    $0x8,%edi
			continue;
f0105ad4:	eb 22                	jmp    f0105af8 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105ad6:	83 ec 08             	sub    $0x8,%esp
f0105ad9:	0f b6 c0             	movzbl %al,%eax
f0105adc:	50                   	push   %eax
f0105add:	68 74 7e 10 f0       	push   $0xf0107e74
f0105ae2:	e8 6d dd ff ff       	call   f0103854 <cprintf>
			ismp = 0;
f0105ae7:	c7 05 00 00 23 f0 00 	movl   $0x0,0xf0230000
f0105aee:	00 00 00 
			i = conf->entry;
f0105af1:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105af5:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105af8:	83 c6 01             	add    $0x1,%esi
f0105afb:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105aff:	39 c6                	cmp    %eax,%esi
f0105b01:	0f 82 6f ff ff ff    	jb     f0105a76 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105b07:	a1 c0 03 23 f0       	mov    0xf02303c0,%eax
f0105b0c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105b13:	83 3d 00 00 23 f0 00 	cmpl   $0x0,0xf0230000
f0105b1a:	75 26                	jne    f0105b42 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105b1c:	c7 05 c4 03 23 f0 01 	movl   $0x1,0xf02303c4
f0105b23:	00 00 00 
		lapicaddr = 0;
f0105b26:	c7 05 00 10 27 f0 00 	movl   $0x0,0xf0271000
f0105b2d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105b30:	83 ec 0c             	sub    $0xc,%esp
f0105b33:	68 94 7e 10 f0       	push   $0xf0107e94
f0105b38:	e8 17 dd ff ff       	call   f0103854 <cprintf>
		return;
f0105b3d:	83 c4 10             	add    $0x10,%esp
f0105b40:	eb 48                	jmp    f0105b8a <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105b42:	83 ec 04             	sub    $0x4,%esp
f0105b45:	ff 35 c4 03 23 f0    	pushl  0xf02303c4
f0105b4b:	0f b6 00             	movzbl (%eax),%eax
f0105b4e:	50                   	push   %eax
f0105b4f:	68 1b 7f 10 f0       	push   $0xf0107f1b
f0105b54:	e8 fb dc ff ff       	call   f0103854 <cprintf>

	if (mp->imcrp) {
f0105b59:	83 c4 10             	add    $0x10,%esp
f0105b5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b5f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105b63:	74 25                	je     f0105b8a <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105b65:	83 ec 0c             	sub    $0xc,%esp
f0105b68:	68 c0 7e 10 f0       	push   $0xf0107ec0
f0105b6d:	e8 e2 dc ff ff       	call   f0103854 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105b72:	ba 22 00 00 00       	mov    $0x22,%edx
f0105b77:	b8 70 00 00 00       	mov    $0x70,%eax
f0105b7c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105b7d:	ba 23 00 00 00       	mov    $0x23,%edx
f0105b82:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105b83:	83 c8 01             	or     $0x1,%eax
f0105b86:	ee                   	out    %al,(%dx)
f0105b87:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105b8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b8d:	5b                   	pop    %ebx
f0105b8e:	5e                   	pop    %esi
f0105b8f:	5f                   	pop    %edi
f0105b90:	5d                   	pop    %ebp
f0105b91:	c3                   	ret    

f0105b92 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105b92:	55                   	push   %ebp
f0105b93:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105b95:	8b 0d 04 10 27 f0    	mov    0xf0271004,%ecx
f0105b9b:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105b9e:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105ba0:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105ba5:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105ba8:	5d                   	pop    %ebp
f0105ba9:	c3                   	ret    

f0105baa <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105baa:	55                   	push   %ebp
f0105bab:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105bad:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105bb2:	85 c0                	test   %eax,%eax
f0105bb4:	74 08                	je     f0105bbe <cpunum+0x14>
		return lapic[ID] >> 24;
f0105bb6:	8b 40 20             	mov    0x20(%eax),%eax
f0105bb9:	c1 e8 18             	shr    $0x18,%eax
f0105bbc:	eb 05                	jmp    f0105bc3 <cpunum+0x19>
	return 0;
f0105bbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105bc3:	5d                   	pop    %ebp
f0105bc4:	c3                   	ret    

f0105bc5 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105bc5:	a1 00 10 27 f0       	mov    0xf0271000,%eax
f0105bca:	85 c0                	test   %eax,%eax
f0105bcc:	0f 84 21 01 00 00    	je     f0105cf3 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105bd2:	55                   	push   %ebp
f0105bd3:	89 e5                	mov    %esp,%ebp
f0105bd5:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105bd8:	68 00 10 00 00       	push   $0x1000
f0105bdd:	50                   	push   %eax
f0105bde:	e8 d3 b7 ff ff       	call   f01013b6 <mmio_map_region>
f0105be3:	a3 04 10 27 f0       	mov    %eax,0xf0271004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105be8:	ba 27 01 00 00       	mov    $0x127,%edx
f0105bed:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105bf2:	e8 9b ff ff ff       	call   f0105b92 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105bf7:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105bfc:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105c01:	e8 8c ff ff ff       	call   f0105b92 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105c06:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105c0b:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105c10:	e8 7d ff ff ff       	call   f0105b92 <lapicw>
	lapicw(TICR, 10000000); 
f0105c15:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105c1a:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105c1f:	e8 6e ff ff ff       	call   f0105b92 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105c24:	e8 81 ff ff ff       	call   f0105baa <cpunum>
f0105c29:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c2c:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105c31:	83 c4 10             	add    $0x10,%esp
f0105c34:	39 05 c0 03 23 f0    	cmp    %eax,0xf02303c0
f0105c3a:	74 0f                	je     f0105c4b <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105c3c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c41:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105c46:	e8 47 ff ff ff       	call   f0105b92 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105c4b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c50:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105c55:	e8 38 ff ff ff       	call   f0105b92 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105c5a:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105c5f:	8b 40 30             	mov    0x30(%eax),%eax
f0105c62:	c1 e8 10             	shr    $0x10,%eax
f0105c65:	3c 03                	cmp    $0x3,%al
f0105c67:	76 0f                	jbe    f0105c78 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105c69:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c6e:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105c73:	e8 1a ff ff ff       	call   f0105b92 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105c78:	ba 33 00 00 00       	mov    $0x33,%edx
f0105c7d:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105c82:	e8 0b ff ff ff       	call   f0105b92 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105c87:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c8c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105c91:	e8 fc fe ff ff       	call   f0105b92 <lapicw>
	lapicw(ESR, 0);
f0105c96:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c9b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ca0:	e8 ed fe ff ff       	call   f0105b92 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105ca5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105caa:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105caf:	e8 de fe ff ff       	call   f0105b92 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105cb4:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cb9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105cbe:	e8 cf fe ff ff       	call   f0105b92 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105cc3:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105cc8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ccd:	e8 c0 fe ff ff       	call   f0105b92 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105cd2:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105cd8:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105cde:	f6 c4 10             	test   $0x10,%ah
f0105ce1:	75 f5                	jne    f0105cd8 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105ce3:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ce8:	b8 20 00 00 00       	mov    $0x20,%eax
f0105ced:	e8 a0 fe ff ff       	call   f0105b92 <lapicw>
}
f0105cf2:	c9                   	leave  
f0105cf3:	f3 c3                	repz ret 

f0105cf5 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105cf5:	83 3d 04 10 27 f0 00 	cmpl   $0x0,0xf0271004
f0105cfc:	74 13                	je     f0105d11 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105cfe:	55                   	push   %ebp
f0105cff:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105d01:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d06:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d0b:	e8 82 fe ff ff       	call   f0105b92 <lapicw>
}
f0105d10:	5d                   	pop    %ebp
f0105d11:	f3 c3                	repz ret 

f0105d13 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105d13:	55                   	push   %ebp
f0105d14:	89 e5                	mov    %esp,%ebp
f0105d16:	56                   	push   %esi
f0105d17:	53                   	push   %ebx
f0105d18:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105d1e:	ba 70 00 00 00       	mov    $0x70,%edx
f0105d23:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105d28:	ee                   	out    %al,(%dx)
f0105d29:	ba 71 00 00 00       	mov    $0x71,%edx
f0105d2e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105d33:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d34:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f0105d3b:	75 19                	jne    f0105d56 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d3d:	68 67 04 00 00       	push   $0x467
f0105d42:	68 64 62 10 f0       	push   $0xf0106264
f0105d47:	68 98 00 00 00       	push   $0x98
f0105d4c:	68 38 7f 10 f0       	push   $0xf0107f38
f0105d51:	e8 ea a2 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105d56:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105d5d:	00 00 
	wrv[1] = addr >> 4;
f0105d5f:	89 d8                	mov    %ebx,%eax
f0105d61:	c1 e8 04             	shr    $0x4,%eax
f0105d64:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105d6a:	c1 e6 18             	shl    $0x18,%esi
f0105d6d:	89 f2                	mov    %esi,%edx
f0105d6f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d74:	e8 19 fe ff ff       	call   f0105b92 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105d79:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105d7e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d83:	e8 0a fe ff ff       	call   f0105b92 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105d88:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105d8d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d92:	e8 fb fd ff ff       	call   f0105b92 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d97:	c1 eb 0c             	shr    $0xc,%ebx
f0105d9a:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105d9d:	89 f2                	mov    %esi,%edx
f0105d9f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105da4:	e8 e9 fd ff ff       	call   f0105b92 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105da9:	89 da                	mov    %ebx,%edx
f0105dab:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105db0:	e8 dd fd ff ff       	call   f0105b92 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105db5:	89 f2                	mov    %esi,%edx
f0105db7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105dbc:	e8 d1 fd ff ff       	call   f0105b92 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105dc1:	89 da                	mov    %ebx,%edx
f0105dc3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dc8:	e8 c5 fd ff ff       	call   f0105b92 <lapicw>
		microdelay(200);
	}
}
f0105dcd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105dd0:	5b                   	pop    %ebx
f0105dd1:	5e                   	pop    %esi
f0105dd2:	5d                   	pop    %ebp
f0105dd3:	c3                   	ret    

f0105dd4 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105dd4:	55                   	push   %ebp
f0105dd5:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105dd7:	8b 55 08             	mov    0x8(%ebp),%edx
f0105dda:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105de0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105de5:	e8 a8 fd ff ff       	call   f0105b92 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105dea:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105df0:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105df6:	f6 c4 10             	test   $0x10,%ah
f0105df9:	75 f5                	jne    f0105df0 <lapic_ipi+0x1c>
		;
}
f0105dfb:	5d                   	pop    %ebp
f0105dfc:	c3                   	ret    

f0105dfd <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105dfd:	55                   	push   %ebp
f0105dfe:	89 e5                	mov    %esp,%ebp
f0105e00:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105e03:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105e09:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e0c:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105e0f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105e16:	5d                   	pop    %ebp
f0105e17:	c3                   	ret    

f0105e18 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105e18:	55                   	push   %ebp
f0105e19:	89 e5                	mov    %esp,%ebp
f0105e1b:	56                   	push   %esi
f0105e1c:	53                   	push   %ebx
f0105e1d:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105e20:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105e23:	74 14                	je     f0105e39 <spin_lock+0x21>
f0105e25:	8b 73 08             	mov    0x8(%ebx),%esi
f0105e28:	e8 7d fd ff ff       	call   f0105baa <cpunum>
f0105e2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e30:	05 20 00 23 f0       	add    $0xf0230020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105e35:	39 c6                	cmp    %eax,%esi
f0105e37:	74 07                	je     f0105e40 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105e39:	ba 01 00 00 00       	mov    $0x1,%edx
f0105e3e:	eb 20                	jmp    f0105e60 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105e40:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105e43:	e8 62 fd ff ff       	call   f0105baa <cpunum>
f0105e48:	83 ec 0c             	sub    $0xc,%esp
f0105e4b:	53                   	push   %ebx
f0105e4c:	50                   	push   %eax
f0105e4d:	68 48 7f 10 f0       	push   $0xf0107f48
f0105e52:	6a 41                	push   $0x41
f0105e54:	68 ac 7f 10 f0       	push   $0xf0107fac
f0105e59:	e8 e2 a1 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105e5e:	f3 90                	pause  
f0105e60:	89 d0                	mov    %edx,%eax
f0105e62:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105e65:	85 c0                	test   %eax,%eax
f0105e67:	75 f5                	jne    f0105e5e <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105e69:	e8 3c fd ff ff       	call   f0105baa <cpunum>
f0105e6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e71:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105e76:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105e79:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105e7c:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105e7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e83:	eb 0b                	jmp    f0105e90 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105e85:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105e88:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105e8b:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105e8d:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105e90:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105e96:	76 11                	jbe    f0105ea9 <spin_lock+0x91>
f0105e98:	83 f8 09             	cmp    $0x9,%eax
f0105e9b:	7e e8                	jle    f0105e85 <spin_lock+0x6d>
f0105e9d:	eb 0a                	jmp    f0105ea9 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105e9f:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105ea6:	83 c0 01             	add    $0x1,%eax
f0105ea9:	83 f8 09             	cmp    $0x9,%eax
f0105eac:	7e f1                	jle    f0105e9f <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105eae:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105eb1:	5b                   	pop    %ebx
f0105eb2:	5e                   	pop    %esi
f0105eb3:	5d                   	pop    %ebp
f0105eb4:	c3                   	ret    

f0105eb5 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105eb5:	55                   	push   %ebp
f0105eb6:	89 e5                	mov    %esp,%ebp
f0105eb8:	57                   	push   %edi
f0105eb9:	56                   	push   %esi
f0105eba:	53                   	push   %ebx
f0105ebb:	83 ec 4c             	sub    $0x4c,%esp
f0105ebe:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105ec1:	83 3e 00             	cmpl   $0x0,(%esi)
f0105ec4:	74 18                	je     f0105ede <spin_unlock+0x29>
f0105ec6:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105ec9:	e8 dc fc ff ff       	call   f0105baa <cpunum>
f0105ece:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ed1:	05 20 00 23 f0       	add    $0xf0230020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105ed6:	39 c3                	cmp    %eax,%ebx
f0105ed8:	0f 84 a5 00 00 00    	je     f0105f83 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105ede:	83 ec 04             	sub    $0x4,%esp
f0105ee1:	6a 28                	push   $0x28
f0105ee3:	8d 46 0c             	lea    0xc(%esi),%eax
f0105ee6:	50                   	push   %eax
f0105ee7:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105eea:	53                   	push   %ebx
f0105eeb:	e8 e4 f6 ff ff       	call   f01055d4 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105ef0:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105ef3:	0f b6 38             	movzbl (%eax),%edi
f0105ef6:	8b 76 04             	mov    0x4(%esi),%esi
f0105ef9:	e8 ac fc ff ff       	call   f0105baa <cpunum>
f0105efe:	57                   	push   %edi
f0105eff:	56                   	push   %esi
f0105f00:	50                   	push   %eax
f0105f01:	68 74 7f 10 f0       	push   $0xf0107f74
f0105f06:	e8 49 d9 ff ff       	call   f0103854 <cprintf>
f0105f0b:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105f0e:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105f11:	eb 54                	jmp    f0105f67 <spin_unlock+0xb2>
f0105f13:	83 ec 08             	sub    $0x8,%esp
f0105f16:	57                   	push   %edi
f0105f17:	50                   	push   %eax
f0105f18:	e8 69 ec ff ff       	call   f0104b86 <debuginfo_eip>
f0105f1d:	83 c4 10             	add    $0x10,%esp
f0105f20:	85 c0                	test   %eax,%eax
f0105f22:	78 27                	js     f0105f4b <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105f24:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105f26:	83 ec 04             	sub    $0x4,%esp
f0105f29:	89 c2                	mov    %eax,%edx
f0105f2b:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105f2e:	52                   	push   %edx
f0105f2f:	ff 75 b0             	pushl  -0x50(%ebp)
f0105f32:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105f35:	ff 75 ac             	pushl  -0x54(%ebp)
f0105f38:	ff 75 a8             	pushl  -0x58(%ebp)
f0105f3b:	50                   	push   %eax
f0105f3c:	68 bc 7f 10 f0       	push   $0xf0107fbc
f0105f41:	e8 0e d9 ff ff       	call   f0103854 <cprintf>
f0105f46:	83 c4 20             	add    $0x20,%esp
f0105f49:	eb 12                	jmp    f0105f5d <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105f4b:	83 ec 08             	sub    $0x8,%esp
f0105f4e:	ff 36                	pushl  (%esi)
f0105f50:	68 d3 7f 10 f0       	push   $0xf0107fd3
f0105f55:	e8 fa d8 ff ff       	call   f0103854 <cprintf>
f0105f5a:	83 c4 10             	add    $0x10,%esp
f0105f5d:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105f60:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105f63:	39 c3                	cmp    %eax,%ebx
f0105f65:	74 08                	je     f0105f6f <spin_unlock+0xba>
f0105f67:	89 de                	mov    %ebx,%esi
f0105f69:	8b 03                	mov    (%ebx),%eax
f0105f6b:	85 c0                	test   %eax,%eax
f0105f6d:	75 a4                	jne    f0105f13 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105f6f:	83 ec 04             	sub    $0x4,%esp
f0105f72:	68 db 7f 10 f0       	push   $0xf0107fdb
f0105f77:	6a 67                	push   $0x67
f0105f79:	68 ac 7f 10 f0       	push   $0xf0107fac
f0105f7e:	e8 bd a0 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105f83:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105f8a:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105f91:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f96:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105f99:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105f9c:	5b                   	pop    %ebx
f0105f9d:	5e                   	pop    %esi
f0105f9e:	5f                   	pop    %edi
f0105f9f:	5d                   	pop    %ebp
f0105fa0:	c3                   	ret    
f0105fa1:	66 90                	xchg   %ax,%ax
f0105fa3:	66 90                	xchg   %ax,%ax
f0105fa5:	66 90                	xchg   %ax,%ax
f0105fa7:	66 90                	xchg   %ax,%ax
f0105fa9:	66 90                	xchg   %ax,%ax
f0105fab:	66 90                	xchg   %ax,%ax
f0105fad:	66 90                	xchg   %ax,%ax
f0105faf:	90                   	nop

f0105fb0 <__udivdi3>:
f0105fb0:	55                   	push   %ebp
f0105fb1:	57                   	push   %edi
f0105fb2:	56                   	push   %esi
f0105fb3:	53                   	push   %ebx
f0105fb4:	83 ec 1c             	sub    $0x1c,%esp
f0105fb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105fbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105fbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105fc7:	85 f6                	test   %esi,%esi
f0105fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105fcd:	89 ca                	mov    %ecx,%edx
f0105fcf:	89 f8                	mov    %edi,%eax
f0105fd1:	75 3d                	jne    f0106010 <__udivdi3+0x60>
f0105fd3:	39 cf                	cmp    %ecx,%edi
f0105fd5:	0f 87 c5 00 00 00    	ja     f01060a0 <__udivdi3+0xf0>
f0105fdb:	85 ff                	test   %edi,%edi
f0105fdd:	89 fd                	mov    %edi,%ebp
f0105fdf:	75 0b                	jne    f0105fec <__udivdi3+0x3c>
f0105fe1:	b8 01 00 00 00       	mov    $0x1,%eax
f0105fe6:	31 d2                	xor    %edx,%edx
f0105fe8:	f7 f7                	div    %edi
f0105fea:	89 c5                	mov    %eax,%ebp
f0105fec:	89 c8                	mov    %ecx,%eax
f0105fee:	31 d2                	xor    %edx,%edx
f0105ff0:	f7 f5                	div    %ebp
f0105ff2:	89 c1                	mov    %eax,%ecx
f0105ff4:	89 d8                	mov    %ebx,%eax
f0105ff6:	89 cf                	mov    %ecx,%edi
f0105ff8:	f7 f5                	div    %ebp
f0105ffa:	89 c3                	mov    %eax,%ebx
f0105ffc:	89 d8                	mov    %ebx,%eax
f0105ffe:	89 fa                	mov    %edi,%edx
f0106000:	83 c4 1c             	add    $0x1c,%esp
f0106003:	5b                   	pop    %ebx
f0106004:	5e                   	pop    %esi
f0106005:	5f                   	pop    %edi
f0106006:	5d                   	pop    %ebp
f0106007:	c3                   	ret    
f0106008:	90                   	nop
f0106009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106010:	39 ce                	cmp    %ecx,%esi
f0106012:	77 74                	ja     f0106088 <__udivdi3+0xd8>
f0106014:	0f bd fe             	bsr    %esi,%edi
f0106017:	83 f7 1f             	xor    $0x1f,%edi
f010601a:	0f 84 98 00 00 00    	je     f01060b8 <__udivdi3+0x108>
f0106020:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106025:	89 f9                	mov    %edi,%ecx
f0106027:	89 c5                	mov    %eax,%ebp
f0106029:	29 fb                	sub    %edi,%ebx
f010602b:	d3 e6                	shl    %cl,%esi
f010602d:	89 d9                	mov    %ebx,%ecx
f010602f:	d3 ed                	shr    %cl,%ebp
f0106031:	89 f9                	mov    %edi,%ecx
f0106033:	d3 e0                	shl    %cl,%eax
f0106035:	09 ee                	or     %ebp,%esi
f0106037:	89 d9                	mov    %ebx,%ecx
f0106039:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010603d:	89 d5                	mov    %edx,%ebp
f010603f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106043:	d3 ed                	shr    %cl,%ebp
f0106045:	89 f9                	mov    %edi,%ecx
f0106047:	d3 e2                	shl    %cl,%edx
f0106049:	89 d9                	mov    %ebx,%ecx
f010604b:	d3 e8                	shr    %cl,%eax
f010604d:	09 c2                	or     %eax,%edx
f010604f:	89 d0                	mov    %edx,%eax
f0106051:	89 ea                	mov    %ebp,%edx
f0106053:	f7 f6                	div    %esi
f0106055:	89 d5                	mov    %edx,%ebp
f0106057:	89 c3                	mov    %eax,%ebx
f0106059:	f7 64 24 0c          	mull   0xc(%esp)
f010605d:	39 d5                	cmp    %edx,%ebp
f010605f:	72 10                	jb     f0106071 <__udivdi3+0xc1>
f0106061:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106065:	89 f9                	mov    %edi,%ecx
f0106067:	d3 e6                	shl    %cl,%esi
f0106069:	39 c6                	cmp    %eax,%esi
f010606b:	73 07                	jae    f0106074 <__udivdi3+0xc4>
f010606d:	39 d5                	cmp    %edx,%ebp
f010606f:	75 03                	jne    f0106074 <__udivdi3+0xc4>
f0106071:	83 eb 01             	sub    $0x1,%ebx
f0106074:	31 ff                	xor    %edi,%edi
f0106076:	89 d8                	mov    %ebx,%eax
f0106078:	89 fa                	mov    %edi,%edx
f010607a:	83 c4 1c             	add    $0x1c,%esp
f010607d:	5b                   	pop    %ebx
f010607e:	5e                   	pop    %esi
f010607f:	5f                   	pop    %edi
f0106080:	5d                   	pop    %ebp
f0106081:	c3                   	ret    
f0106082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106088:	31 ff                	xor    %edi,%edi
f010608a:	31 db                	xor    %ebx,%ebx
f010608c:	89 d8                	mov    %ebx,%eax
f010608e:	89 fa                	mov    %edi,%edx
f0106090:	83 c4 1c             	add    $0x1c,%esp
f0106093:	5b                   	pop    %ebx
f0106094:	5e                   	pop    %esi
f0106095:	5f                   	pop    %edi
f0106096:	5d                   	pop    %ebp
f0106097:	c3                   	ret    
f0106098:	90                   	nop
f0106099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01060a0:	89 d8                	mov    %ebx,%eax
f01060a2:	f7 f7                	div    %edi
f01060a4:	31 ff                	xor    %edi,%edi
f01060a6:	89 c3                	mov    %eax,%ebx
f01060a8:	89 d8                	mov    %ebx,%eax
f01060aa:	89 fa                	mov    %edi,%edx
f01060ac:	83 c4 1c             	add    $0x1c,%esp
f01060af:	5b                   	pop    %ebx
f01060b0:	5e                   	pop    %esi
f01060b1:	5f                   	pop    %edi
f01060b2:	5d                   	pop    %ebp
f01060b3:	c3                   	ret    
f01060b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01060b8:	39 ce                	cmp    %ecx,%esi
f01060ba:	72 0c                	jb     f01060c8 <__udivdi3+0x118>
f01060bc:	31 db                	xor    %ebx,%ebx
f01060be:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01060c2:	0f 87 34 ff ff ff    	ja     f0105ffc <__udivdi3+0x4c>
f01060c8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01060cd:	e9 2a ff ff ff       	jmp    f0105ffc <__udivdi3+0x4c>
f01060d2:	66 90                	xchg   %ax,%ax
f01060d4:	66 90                	xchg   %ax,%ax
f01060d6:	66 90                	xchg   %ax,%ax
f01060d8:	66 90                	xchg   %ax,%ax
f01060da:	66 90                	xchg   %ax,%ax
f01060dc:	66 90                	xchg   %ax,%ax
f01060de:	66 90                	xchg   %ax,%ax

f01060e0 <__umoddi3>:
f01060e0:	55                   	push   %ebp
f01060e1:	57                   	push   %edi
f01060e2:	56                   	push   %esi
f01060e3:	53                   	push   %ebx
f01060e4:	83 ec 1c             	sub    $0x1c,%esp
f01060e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01060eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01060ef:	8b 74 24 34          	mov    0x34(%esp),%esi
f01060f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01060f7:	85 d2                	test   %edx,%edx
f01060f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01060fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106101:	89 f3                	mov    %esi,%ebx
f0106103:	89 3c 24             	mov    %edi,(%esp)
f0106106:	89 74 24 04          	mov    %esi,0x4(%esp)
f010610a:	75 1c                	jne    f0106128 <__umoddi3+0x48>
f010610c:	39 f7                	cmp    %esi,%edi
f010610e:	76 50                	jbe    f0106160 <__umoddi3+0x80>
f0106110:	89 c8                	mov    %ecx,%eax
f0106112:	89 f2                	mov    %esi,%edx
f0106114:	f7 f7                	div    %edi
f0106116:	89 d0                	mov    %edx,%eax
f0106118:	31 d2                	xor    %edx,%edx
f010611a:	83 c4 1c             	add    $0x1c,%esp
f010611d:	5b                   	pop    %ebx
f010611e:	5e                   	pop    %esi
f010611f:	5f                   	pop    %edi
f0106120:	5d                   	pop    %ebp
f0106121:	c3                   	ret    
f0106122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106128:	39 f2                	cmp    %esi,%edx
f010612a:	89 d0                	mov    %edx,%eax
f010612c:	77 52                	ja     f0106180 <__umoddi3+0xa0>
f010612e:	0f bd ea             	bsr    %edx,%ebp
f0106131:	83 f5 1f             	xor    $0x1f,%ebp
f0106134:	75 5a                	jne    f0106190 <__umoddi3+0xb0>
f0106136:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010613a:	0f 82 e0 00 00 00    	jb     f0106220 <__umoddi3+0x140>
f0106140:	39 0c 24             	cmp    %ecx,(%esp)
f0106143:	0f 86 d7 00 00 00    	jbe    f0106220 <__umoddi3+0x140>
f0106149:	8b 44 24 08          	mov    0x8(%esp),%eax
f010614d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106151:	83 c4 1c             	add    $0x1c,%esp
f0106154:	5b                   	pop    %ebx
f0106155:	5e                   	pop    %esi
f0106156:	5f                   	pop    %edi
f0106157:	5d                   	pop    %ebp
f0106158:	c3                   	ret    
f0106159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106160:	85 ff                	test   %edi,%edi
f0106162:	89 fd                	mov    %edi,%ebp
f0106164:	75 0b                	jne    f0106171 <__umoddi3+0x91>
f0106166:	b8 01 00 00 00       	mov    $0x1,%eax
f010616b:	31 d2                	xor    %edx,%edx
f010616d:	f7 f7                	div    %edi
f010616f:	89 c5                	mov    %eax,%ebp
f0106171:	89 f0                	mov    %esi,%eax
f0106173:	31 d2                	xor    %edx,%edx
f0106175:	f7 f5                	div    %ebp
f0106177:	89 c8                	mov    %ecx,%eax
f0106179:	f7 f5                	div    %ebp
f010617b:	89 d0                	mov    %edx,%eax
f010617d:	eb 99                	jmp    f0106118 <__umoddi3+0x38>
f010617f:	90                   	nop
f0106180:	89 c8                	mov    %ecx,%eax
f0106182:	89 f2                	mov    %esi,%edx
f0106184:	83 c4 1c             	add    $0x1c,%esp
f0106187:	5b                   	pop    %ebx
f0106188:	5e                   	pop    %esi
f0106189:	5f                   	pop    %edi
f010618a:	5d                   	pop    %ebp
f010618b:	c3                   	ret    
f010618c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106190:	8b 34 24             	mov    (%esp),%esi
f0106193:	bf 20 00 00 00       	mov    $0x20,%edi
f0106198:	89 e9                	mov    %ebp,%ecx
f010619a:	29 ef                	sub    %ebp,%edi
f010619c:	d3 e0                	shl    %cl,%eax
f010619e:	89 f9                	mov    %edi,%ecx
f01061a0:	89 f2                	mov    %esi,%edx
f01061a2:	d3 ea                	shr    %cl,%edx
f01061a4:	89 e9                	mov    %ebp,%ecx
f01061a6:	09 c2                	or     %eax,%edx
f01061a8:	89 d8                	mov    %ebx,%eax
f01061aa:	89 14 24             	mov    %edx,(%esp)
f01061ad:	89 f2                	mov    %esi,%edx
f01061af:	d3 e2                	shl    %cl,%edx
f01061b1:	89 f9                	mov    %edi,%ecx
f01061b3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01061b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01061bb:	d3 e8                	shr    %cl,%eax
f01061bd:	89 e9                	mov    %ebp,%ecx
f01061bf:	89 c6                	mov    %eax,%esi
f01061c1:	d3 e3                	shl    %cl,%ebx
f01061c3:	89 f9                	mov    %edi,%ecx
f01061c5:	89 d0                	mov    %edx,%eax
f01061c7:	d3 e8                	shr    %cl,%eax
f01061c9:	89 e9                	mov    %ebp,%ecx
f01061cb:	09 d8                	or     %ebx,%eax
f01061cd:	89 d3                	mov    %edx,%ebx
f01061cf:	89 f2                	mov    %esi,%edx
f01061d1:	f7 34 24             	divl   (%esp)
f01061d4:	89 d6                	mov    %edx,%esi
f01061d6:	d3 e3                	shl    %cl,%ebx
f01061d8:	f7 64 24 04          	mull   0x4(%esp)
f01061dc:	39 d6                	cmp    %edx,%esi
f01061de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01061e2:	89 d1                	mov    %edx,%ecx
f01061e4:	89 c3                	mov    %eax,%ebx
f01061e6:	72 08                	jb     f01061f0 <__umoddi3+0x110>
f01061e8:	75 11                	jne    f01061fb <__umoddi3+0x11b>
f01061ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01061ee:	73 0b                	jae    f01061fb <__umoddi3+0x11b>
f01061f0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01061f4:	1b 14 24             	sbb    (%esp),%edx
f01061f7:	89 d1                	mov    %edx,%ecx
f01061f9:	89 c3                	mov    %eax,%ebx
f01061fb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01061ff:	29 da                	sub    %ebx,%edx
f0106201:	19 ce                	sbb    %ecx,%esi
f0106203:	89 f9                	mov    %edi,%ecx
f0106205:	89 f0                	mov    %esi,%eax
f0106207:	d3 e0                	shl    %cl,%eax
f0106209:	89 e9                	mov    %ebp,%ecx
f010620b:	d3 ea                	shr    %cl,%edx
f010620d:	89 e9                	mov    %ebp,%ecx
f010620f:	d3 ee                	shr    %cl,%esi
f0106211:	09 d0                	or     %edx,%eax
f0106213:	89 f2                	mov    %esi,%edx
f0106215:	83 c4 1c             	add    $0x1c,%esp
f0106218:	5b                   	pop    %ebx
f0106219:	5e                   	pop    %esi
f010621a:	5f                   	pop    %edi
f010621b:	5d                   	pop    %ebp
f010621c:	c3                   	ret    
f010621d:	8d 76 00             	lea    0x0(%esi),%esi
f0106220:	29 f9                	sub    %edi,%ecx
f0106222:	19 d6                	sbb    %edx,%esi
f0106224:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010622c:	e9 18 ff ff ff       	jmp    f0106149 <__umoddi3+0x69>
